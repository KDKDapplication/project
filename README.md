## 🦆 키득키득 (E106)

> 부모 자녀간 용돈 관리 및 자녀의 경제관념 확립 서비스


## 📆 프로젝트 기간

**2025.08.25 ~ 2025.10.03**


## 📔 프로젝트 개요

1. 부모-자녀 계정 연동
    - 부모는 자녀의 경제 활동을 모니터링하면서도 직접적인 개입 없이 관리 가능

2. 용돈 관리 및 자동이체
    - 부모가 자녀에게 정기적/일회성으로 용돈을 지급할 수 있으며, 자동 이체 기능을 통해 계획적인 금전 관리를 지원

3. 저축(모으기 통장) 기능
    - 자녀가 목표를 설정하고 저축을 통해 성취감을 느낄 수 있도록 설계

4. SSAFY 금융망 기반 가상 카드 발급
    - 자녀가 부모 명의 카드를 직접 쓰지 않고도 안전하게 결제할 수 있는 가상 카드 제공

5. 미션/보상 시스템
    - 부모가 설정한 미션(예: 집안일, 학습 목표)을 달성하면 용돈 또는 보상 지급

6. 소비/저축 내역 시각화
    - 자녀 및 부모가 본인또는 자녀의 소비 및 저축 내역을 앱에서 카드·그래프 UI로 쉽게 확인

7. 캐릭터 키우기(아바타 성장)기능
    - 자녀의 흥미 유발 키덕이 키우기


## 👥 팀원 소개

### 👤 장준혁 (팀장)

![장준혁](exec/readMePng/junhyeok.png)

- **이메일**
    - wnsgur9578@naver.com
- **담당**
    - BACKEND
        - 자동이체 로직 작성
        - 소비 내역 카드 및 계좌 통합 구현
        - 싸피 금융망 연결
        - DB 로직 작성  

---

### 👤 전원균

<img src="exec/readMePng/JeonWongyun.jpg" alt="전원균" width="250"/>

- **이메일**
    - spotydol7@gmail.com
- **담당**
    - INFRA
        - 서버 환경 설정
        - CI/CD 파이프라인 구축
    - BACKEND
        - FCM 알림 전송 기능 작성
        - 자녀 API 설계 및 구현

---

### 👤 윤지욱

![윤지욱]()

- **이메일**
    - 이메일
- **담당**
    - FRONTEND
        - 프론트
    - BACKEND
        - 백엔드


---

### 👤 신유빈

<img src="exec/readMePng/yubin.jpg" alt="신유빈" width="200"/>

- **이메일**
    - syb0317timo12@gmail.com
- **담당**
    - BACKEND
        - spring scheduler를 이용한 자동이체 및 자동 적금 로직 구현
        - Google OAuth 2.0 소셜 로그인 구현
        - JWT기반 인증/인가 체계 구현
        - 유저 정보 관리

---

### 👤 강태욱
<img src="exec/readMePng/taewook.jpg" alt="강태욱" width="200"/>


- **이메일**
    - sunshinemoongit@gmail.com
- **담당**
    - FRONTEND
        - APP : 소셜 로그인 + 회원가입
        - APP : 부모 부분 제작
        - APP : BLE 태깅
        - APP : FCM 연결
    - DESIGN 
        - 피그마 디자인


---

### 👤 이지언
<img src="exec/readMePng/jiun.jpg" alt="이지언" width="200"/>


- **이메일**
    - leejiun0102@naver.com
- **담당**
    - FRONTEND
        - WEB : Guide 페이지 제작
        - APP : 자녀 부분 제작
        - APP : QR 결제 
    - DESIGN
        - 피그마 디자인 
        - 발표 PPT 제작
        - 영상 포트폴리오 제작

---

## 🧰 기술 스택

| 분류 | 사용 기술                                                                    |
|------|--------------------------------------------------------------------------|
| **Language** | `Java`, `Dart`                                                        |
| **Backend** | `Spring Boot 3.4.5`, `Spring Security`, `JPA`, `JWT`, `Gradle` |
| **Frontend-Web** | `React`, `TypeScript`, `npm`                       |
| **Frontend-Mobile** | `Flutter`, `Riverpod`                          |
| **DB** | `MySQL`, `Redis`                                                         |
| **DevOps** | `Git`, `Docker`, `AWS EC2`, `Jenkins`, `Nginx`        |

---


## 📁 문서

### 🛠 시스템 아키텍처
<img src="exec/readMePng/structure.png" alt="시스템 아키텍처" width="600"/>

### 🧩 ERD
<img src="exec/readMePng/ERD.png" alt="ERD" width="600"/>

---

## **🖥️ 주요 기능**

## 🏠**초기 화면(Web)**

| ![초기화면_Web](exec/readMePng/Main.png)|
| --- |
| **초기 화면** <br> 웹에서 키득키득 어플리케이션 다운로드가 가능합니다. |

## 🏠**초기 화면(Mobile)**

| <img src="exec/readMePng/Screenshot_20250926_103619.jpg" alt="초기화면_Mobile" width="300"/> |
| --- |
| **초기 화면** <br> 구글 계정을 통하여 소셜 로그인을 지원합니다. |


## 👧 **자녀화면**

| <img src="exec/readMePng/Screenshot_20250926_104006.jpg" alt="메인" width="300"/> |
| --- |
| **메인** <br> 계좌, 용돈 등의 정보를 한 눈에 볼 수 있습니다. |

| <img src="exec/readMePng/KakaoTalk_20250926_122818008.jpg" alt="알림" width="300"/> |
| --- |
| **알림** <br> 부모가 등록한 미션을 실시간 알림으로 받을 수 있습니다. |

| <img src="exec/readMePng/Screenshot_20250926_103945.jpg" alt="프로필" width="300"/> |
| --- |
| **프로필** <br> 이름, 이메일, 나이, 생일 정보를 찾아볼 수 있습니다. |

| <img src="exec/readMePng/Screenshot_20250926_103644.jpg" alt="키우기" width="300"/> |
| --- |
| **키우기** <br> 키덕이 키우기를 통해 경험치를 확인할 수 있습니다. |

| <img src="exec/readMePng/Screenshot_20250926_103918.jpg" alt="모으기 통장" width="300"/> | <img src="exec/readMePng/KakaoTalk_20250926_122922422.jpg" alt="모으기 통장 완료" width="300"/> |
| --- | --- |
| **모으기 통장** <br> 모으기 통장 생성 및 진행중인 모으기 통장을 확인할 수 있습니다. | **모으기 통장 완료** <br> 완료된 모으기 통장을 확인할 수 있습니다. |

| <img src="exec/readMePng/Screenshot_20250926_103939.jpg" alt="진행 중 미션" width="300"/> | <img src="exec/readMePng/Screenshot_20250926_103942.jpg" alt="완료 미션" width="300"/> |
| --- | --- |
| **진행 중 미션** <br> 진행중인 모으기 미션을 확인할 수 있습니다. | **완료 미션** <br> 완료된 미션을 확인할 수 있습니다. |

| <img src="exec/readMePng/Screenshot_20250926_103952.jpg" alt="키득 페이" width="300"/> | <img src="exec/readMePng/Screenshot_20250926_103955.jpg" alt="키득 태깅" width="300"/> |
| --- | --- |
| **키득 페이** <br> QR을 통해 결제가 가능합니다. | **키득 태깅** <br> 부모와 태깅을 통해서 용돈을 받을 수 있습니다. |


## 🏠 **부모 화면**

| <img src="exec/readMePng/KakaoTalk_20250926_121225412_12.jpg" alt="메인" width="300"/> |
| --- |
| **메인** <br> 자녀 계좌, 내 계좌 잔고 등의 정보를 한 눈에 볼 수 있습니다. |

| <img src="exec/readMePng/KakaoTalk_20250926_121225412_13.jpg" alt="프로필" width="300"/> |
| --- |
| **프로필** <br> 이름, 이메일, 나이, 생일 정보를 찾아볼 수 있습니다. |

| <img src="exec/readMePng/KakaoTalk_20250926_121225412_11.jpg" alt="알림" width="300"/> |
| --- |
| **알림** <br> 자녀의 알림을 실시간으로 받아 볼 수 있습니다. |

| <img src="exec/readMePng/KakaoTalk_20250926_121225412.jpg" alt="진행중 미션" width="300"/> | <img src="exec/readMePng/KakaoTalk_20250926_121225412_02.jpg" alt="완료된 미션" width="300"/> |
| --- | --- |
| **진행 중 미션** <br> 진행중인 미션을 확인할 수 있습니다. | **완료된 미션** <br> 자녀의 완료된 미션을 확인할 수 있습니다. |

| <img src="exec/readMePng/KakaoTalk_20250926_121225412_01.jpg" alt="자동이체 등록" width="300"/> | <img src="exec/readMePng/KakaoTalk_20250926_121225412_06.jpg" alt="자동이체 목록" width="300"/> |
| --- | --- |
| **자동이체 등록** <br> 원하는 날짜와 시간, 금액을 선택할 수 있습니다. | **자동이체 목록** <br> 자녀에게 이체되는 자동이체를 확인할 수 있습니다. |

| <img src="exec/readMePng/KakaoTalk_20250926_121225412_10.jpg" alt="소비 목록" width="300"/> | <img src="exec/readMePng/KakaoTalk_20250926_121225412_08.jpg" alt="소비 세부 내용" width="300"/> |
| --- | --- |
| **자녀 소비 목록** <br> 자녀의 소비 내역을 확인할 수 있습니다. | **자녀 소비 세부 내용** <br> 시간, 가게위치, 금액등을 확인할 수 있습니다. |

| <img src="exec/readMePng/KakaoTalk_20250926_121225412_09.jpg" alt="자녀 지갑" width="300"/> | <img src="exec/readMePng/KakaoTalk_20250926_121225412_07.jpg" alt="소비 패턴 분석" width="300"/> |
| --- | --- |
| **자녀 지갑** <br> 자녀의 소비 내역과 빌리기 금액을 확인할 수 있습니다. | **소비 패턴 분석** <br> 자녀의 소비 패턴을 한눈에 확인할 수 있습니다. |


