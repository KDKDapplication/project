# E106 포팅 매뉴얼

## 개요

- **서비스명** : 키득키득
- **팀명** : 영끌
- **주요 구성**
  - **FE(Web)**: React, TypeScript, npm
  - **FE(Mobile)**: Flutter, Dart, Riverpod
  - **BE**: Spring Boot, Java, Gradle
  - **DB**: MySQL, Redis
  - **Infra**: AWS EC2, Docker, Jenkins, Nginx

---

## IDE

- **FE**: Visual Studio Code (Version: 1.101.2 (Universal))
- **BE**: IntelliJ IDEA 2025.2 (Ultimate Edition)

---

## 서버 환경

- **OS**: Ubuntu 22.04 LTS (Jammy)
- **플랫폼 / 플랜**: AWS EC2
- **CPU**: 4 vCPUs
- **메모리**: 16 GiB RAM

### 방화벽 및 포트 설정 (UFW)

서버에 설정된 실제 방화벽 규칙은 다음과 같습니다.

#### 현재 활성화된 포트 목록

| 포트        | 프로토콜 | 연결 서비스          | 비고                      |
| ----------- | -------- | -------------------- | ------------------------|
| 22          | TCP      | SSH                  | 원격 서버 접속           |
| 80          | TCP      | HTTP                 | Nginx HTTPS 리다이렉트   |
| 443         | TCP      | HTTPS                | Nginx 리버스 프록시      |
| 3306        | TCP      | MySQL                | 데이터베이스 직접 접근    |
| 6379        | TCP      | Redis                | 데이터베이스 직접 접근    |
| 8080        | TCP      | Spring Boot          | 백엔드 API 직접 접근     |

---

### 도메인 및 SSL 설정

- **도메인**: `j13e106.p.ssafy.io`
- **SSL 인증서**: Let's Encrypt (Certbot 활용)
  - **인증서 경로**: `/etc/letsencrypt/live/j13e106.p.ssafy.io/`
  - **주요 파일**: `fullchain.pem`, `privkey.pem`
- **적용 범위**: Nginx Reverse Proxy를 통해 HTTPS(443) 적용 및 모든 HTTP(80) 요청은 HTTPS로 자동 리다이렉트
- **만료 주기**: 90일 (갱신 필요)

---

## CI/CD 환경 구성

배포 자동화를 위해 호스트 서버에 Docker, Nginx, Jenkins 설치 및 연동

### 1. Docker 설치 (호스트 서버)

- **Docker**: 20.10.x 이상

```bash
# 1. 시스템 패키지 업데이트
sudo apt-get update && sudo apt-get upgrade -y

# 2. Docker 공식 GPG 키 추가 및 저장소 설정
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL [https://download.docker.com/linux/ubuntu/gpg](https://download.docker.com/linux/ubuntu/gpg) -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] [https://download.docker.com/linux/ubuntu](https://download.docker.com/linux/ubuntu) \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 3. Docker 설치
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin

# 4. 현재 사용자에 Docker 권한 부여
sudo usermod -aG docker $USER
# 터미널 재접속
```

### 2. Nginx 설치 (호스트 서버)

리버스 프록시 서버로 사용할 Nginx 설치

```bash
sudo apt-get update
sudo apt-get install -y nginx
```

### 3. 환경 변수 파일 준비

Jenkins에 배포 시 필요한 환경 변수(`.env` 파일) 등록 후 CI/CD 파이프라인 실행 시 복사해 사용

파일 내용 예시:
```
# /opt/env/be.env
DATABASE_URL=jdbc:mysql://...
DATABASE_USERNAME=user
DATABASE_PASSWORD=password
JWT_SECRET_KEY=your-secret-key
```

### 4. Jenkins 컨테이너 실행

공식 이미지를 사용하여 Jenkins 컨테이너를 실행

**A. docker-compose.yml 파일 작성**

```yaml
services:
  jenkins:
    image: my-jenkins:latest
    container_name: jenkins
    environment:
      JENKINS_OPTS: "--prefix=/jenkins"
      GRADLE_USER_HOME: "/var/jenkins_home/.cache/gradle"
      PUB_CACHE: "/var/jenkins_home/.cache/flutter-pub"
    ports:
      - "8081:8080"
    volumes:
      - jenkins_home:/var/jenkins_home         # Jenkins 데이터 보존
      - jenkins_cache:/opt/jenkins-cache       # Gradle/Flutter 캐시 보존
      - /var/run/docker.sock:/var/run/docker.sock  # 호스트 Docker 제어
    group_add:
      - "${DOCKER_GID}"

volumes:
  jenkins_home:
    external: true
    name: jenkins_home
  jenkins_cache: {}
```

**B. docker-compose 실행**

```bash
sudo env DOCKER_GID=$(stat -c %g /var/run/docker.sock) docker compose up -d
```

**C. Jenkins 컨테이너 내 경로 생성**

```bash
sudo docker exec -u 0 jenkins bash -lc   'mkdir -p /opt/jenkins-cache/{gradle,flutter-pub} && chown -R jenkins:jenkins /opt/jenkins-cache'
```


### 5. Jenkins 컨테이너 내 Docker CLI 설치 (최초 1회)

공식 Jenkins 이미지는 Docker CLI를 포함하고 있지 않으므로 파이프라인에서 Docker 명령어를 사용하기 위해 컨테이너 내부에 직접 Docker CLI를 설치함

**A. Jenkins 컨테이너 접속**

```bash
docker exec -it -u root jenkins /bin/bash
```

**B. 컨테이너 내부에서 아래 명령어 실행**

필요한 패키지와 Docker CLI 설치

```bash
# 필요한 패키지 설치
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common lsb-release

# Docker 공식 GPG 키 추가
curl -fsSL [https://download.docker.com/linux/debian/gpg](https://download.docker.com/linux/debian/gpg) | apt-key add -

# Docker 저장소 추가
echo "deb [arch=amd64] [https://download.docker.com/linux/debian](https://download.docker.com/linux/debian) $(lsb_release -cs) stable" \
  > /etc/apt/sources.list.d/docker.list

# Docker CLI 설치
apt-get update
apt-get install -y docker-ce-cli

# 종료
exit
```

---

## 데이터베이스 설치

### MySQL 및 Redis 설치

MySQL과 Redis를 Docker 컨테이너로 실행

**A. MySQL 컨테이너 실행**

```bash
docker run -d \
  --name mysql \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=[YOUR_MYSQL_PASSWORD] \
  -e MYSQL_DATABASE=[YOUR_DATABASE_NAME] \
  mysql/mysql-server:latest
```

**B. Redis 컨테이너 실행**

```bash
docker run -d \
  --name redis \
  -p 6379:6379 \
  redis:latest
```

## 서비스별 설정

### Nginx Reverse Proxy

- **설정 파일 경로**: `/etc/nginx/sites-available/kdkd`
- **주요 역할**: SSL 인증서 적용 및 HTTP->HTTPS 리다이렉션, 요청 경로에 따른 서비스 분배
- **프록시 방식**: Jenkins가 각 서비스를 Docker 컨테이너로 실행하고 호스트의 특정 포트와 매핑 후 Nginx는 `127.0.0.1:[호스트 포트]`로 요청 전달

#### 프록시 경로 설정

| 요청 경로     | 전달 대상 주소 (내부)           | 설명                                  |
|--------------|---------------------------------|---------------------------------------|
| `/`          | `http://127.0.0.1:81`           | 프론트엔드(Web) Nginx |
| `/api/`      | `http://127.0.0.1:8080`         | 백엔드 API                 |
| `/jenkins/`  | `http://127.0.0.1:8081/jenkins/`| Jenkins UI (`--prefix=/jenkins` 적용) |
| `/downloads/`| `http://127.0.0.1:81/downloads/`| APK 다운로드 - 프론트엔드(Web) Nginx에서 처리  |