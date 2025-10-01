def setupFlutterAndroid(envDir) {
  sh """
    set -e
    export FLUTTER_HOME='${envDir}/.flutter'
    export ANDROID_SDK_ROOT='${envDir}/.android-sdk'
    export PATH="\$FLUTTER_HOME/bin:\$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:\$ANDROID_SDK_ROOT/platform-tools:\$PATH"

    # --- base tools (once) ---
    if ! command -v git >/dev/null 2>&1 || ! command -v curl >/dev/null 2>&1 || ! command -v unzip >/dev/null 2>&1 || ! command -v rsync >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
      apt-get update -y
      DEBIAN_FRONTEND=noninteractive apt-get install -y git curl unzip rsync jq
    fi

    # --- flutter (cached) ---
    if [ ! -x "\$FLUTTER_HOME/bin/flutter" ]; then
      rm -rf "\$FLUTTER_HOME"
      git clone --depth=1 -b ${env.FLUTTER_CHANNEL} https://github.com/flutter/flutter "\$FLUTTER_HOME"
      "\$FLUTTER_HOME/bin/flutter" config --enable-web
    fi

    # --- android cmdline-tools (versioned) ---
    mkdir -p "\$ANDROID_SDK_ROOT"
    if [ ! -d "\$ANDROID_SDK_ROOT/cmdline-tools/latest/bin" ]; then
      tmpzip=\$(mktemp /tmp/cmdtools.XXXXXX.zip)
      curl -L -o "\$tmpzip" "${env.ANDROID_CMDLINE_TOOLS_ZIP_URL}"
      mkdir -p "\$ANDROID_SDK_ROOT/cmdline-tools/_dl"
      unzip -q "\$tmpzip" -d "\$ANDROID_SDK_ROOT/cmdline-tools/_dl"
      rm -f "\$tmpzip"
      mkdir -p "\$ANDROID_SDK_ROOT/cmdline-tools/latest"
      cp -r "\$ANDROID_SDK_ROOT/cmdline-tools/_dl/cmdline-tools/"* "\$ANDROID_SDK_ROOT/cmdline-tools/latest/" || true
      rm -rf "\$ANDROID_SDK_ROOT/cmdline-tools/_dl"
    fi

    yes | sdkmanager --licenses >/dev/null 2>&1 || true
    sdkmanager --install ${env.ANDROID_SDK_PACKAGES} >/dev/null || true

    "\$FLUTTER_HOME/bin/flutter" doctor || true
  """
  env.FLUTTER_HOME = "${envDir}/.flutter"
  env.ANDROID_SDK_ROOT = "${envDir}/.android-sdk"
  env.PATH = "${env.FLUTTER_HOME}/bin:${env.ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${env.ANDROID_SDK_ROOT}/platform-tools:${env.PATH}"
}

pipeline {
  agent any
  tools { jdk 'jdk17' }
  options { timestamps(); skipDefaultCheckout(true) }

  environment {
    DEPLOY_BRANCH = "master"

    ANDROID_CLT_REV = "11076708"
    ANDROID_CMDLINE_TOOLS_ZIP_URL = "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_CLT_REV}_latest.zip"
    ANDROID_SDK_PACKAGES = "\"platform-tools\" \"platforms;android-34\" \"build-tools;34.0.0\""

    FLUTTER_CHANNEL = "stable"

    GRADLE_USER_HOME = "/opt/jenkins-cache/gradle"
    PUB_CACHE        = "/opt/jenkins-cache/flutter-pub"

    BE_COMPOSE_DIR_DEFAULT = "kdkd_BE"
    BE_COMPOSE_FILE_NAME   = "docker-compose.yml"

    DOCKER_BUILDKIT = "1"
    COMPOSE_DOCKER_CLI_BUILD = "1"

    CACHE_ROOT = "/opt/jenkins-cache"

    APK_PUB_VOL = "kdkd-downloads-vol"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
        script {
          def guess = sh(script: '''
            git symbolic-ref --short -q HEAD 2>/dev/null || \
            (git branch -r --contains HEAD | sed -n "1{s#.*/##;p}") || \
            echo HEAD
          ''', returnStdout: true).trim()
          env.CUR_BRANCH = guess.replaceFirst(/^origin\\//,'').replaceFirst(/^refs\\/heads\\//,'')
          echo "Detected branch: ${env.CUR_BRANCH}"
        }

        sh '''
cat >/tmp/find_pubspec_dir.sh <<'EOS'
find_pubspec_dir() {
  if [ -f pubspec.yaml ]; then
    echo .
    return 0
  fi
  p="$(find . -maxdepth 5 -type f -name pubspec.yaml -print -quit 2>/dev/null)"
  [ -n "$p" ] && dirname "$p" || echo ""
}
EOS
chmod +x /tmp/find_pubspec_dir.sh
'''
      }
    }

    stage('변경사항 감지') {
      steps {
        script {
          def current = sh(script: "git rev-parse HEAD", returnStdout: true).trim()
          def isMaster = (env.CUR_BRANCH == env.DEPLOY_BRANCH)
          def base = (isMaster && env.GIT_PREVIOUS_SUCCESSFUL_COMMIT?.trim())
            ? env.GIT_PREVIOUS_SUCCESSFUL_COMMIT.trim()
            : sh(script: "git rev-parse HEAD~1 2>/dev/null || echo ${current}", returnStdout: true).trim()
          env.DIFF_RANGE = (base == current) ? "" : "${base}..${current}"

          if (env.DIFF_RANGE) {
            env.CHANGED = sh(script: "git diff --name-only ${env.DIFF_RANGE}", returnStdout: true).trim()
          } else {
            env.CHANGED = sh(script: "git ls-tree -r --name-only ${current}", returnStdout: true).trim()
          }

          env.CHANGED_BACKEND   = sh(script: "echo \"$CHANGED\" | grep -E '^kdkd_BE/'             || true", returnStdout: true).trim()
          env.CHANGED_FE_WEB    = sh(script: "echo \"$CHANGED\" | grep -E '^kdkd_FE/kdkd_web/'    || true", returnStdout: true).trim()
          env.CHANGED_FE_MOBILE = sh(script: "echo \"$CHANGED\" | grep -E '^kdkd_FE/kdkd_mobile/' || true", returnStdout: true).trim()

          def nonInfraChanged = sh(
            script: '''echo "$CHANGED" | grep -Ev '^(Jenkinsfile|\\.gitlab-ci\\.yml|README(\\.md)?|docs/|\\.github/|\\.gitignore)$' || true''',
            returnStdout: true
          ).trim()
          env.FORCE_ALL = nonInfraChanged ? "false" : "true"

          echo """[DEBUG]
Branch     : ${env.CUR_BRANCH} (Deploy=${env.DEPLOY_BRANCH})
Changed    :
${env.CHANGED}

Flags -> BE:${env.CHANGED_BACKEND?'Y':'N'} FE_WEB:${env.CHANGED_FE_WEB?'Y':'N'} FE_MOBILE:${env.CHANGED_FE_MOBILE?'Y':'N'}
FORCE_ALL : ${env.FORCE_ALL}
"""
        }
      }
    }

    stage('백엔드 - 빌드') {
      when { anyOf { expression { return env.CHANGED_BACKEND?.trim() }; expression { return env.FORCE_ALL == 'true' } } }
      steps {
        withCredentials([file(credentialsId: 'firebase_adminsdk_json', variable: 'FIREBASE_JSON')]) {
          dir('kdkd_BE') {
            sh """
              set -e
              mkdir -p src/main/resources

              FIREBASE_JSON_NAME="kdkd-471601-firebase-adminsdk-fbsvc-7aef684b70.json"

              cp "\$FIREBASE_JSON" "src/main/resources/\$FIREBASE_JSON_NAME"
              echo "[BE] Firebase credential copied to src/main/resources/\$FIREBASE_JSON_NAME"

              mkdir -p "${GRADLE_USER_HOME}"
              export GRADLE_USER_HOME="${GRADLE_USER_HOME}"

              chmod +x gradlew || true
              ./gradlew --no-daemon -Dorg.gradle.jvmargs="-Xmx2g" clean bootJar -x test

              test -f "build/resources/main/\$FIREBASE_JSON_NAME" || { echo "[BE][ERROR] resource not packaged"; exit 1; }
            """
          }
        }
        archiveArtifacts artifacts: 'kdkd_BE/build/libs/*.jar', fingerprint: true
      }
    }


    stage('백엔드 - docker-compose 배포') {
      when {
        allOf {
          expression { return env.CUR_BRANCH == env.DEPLOY_BRANCH }
          anyOf {
            expression { return env.CHANGED_BACKEND?.trim() }
            expression { return env.FORCE_ALL == 'true' }
          }
        }
      }
      steps {
        withCredentials([file(credentialsId: 'env_secretfile_credential', variable: 'ENVFILE')]) {
          sh '''
            set -e
            # compose 파일 주소
            BE_COMPOSE_DIR="kdkd_BE"
            COMPOSE_FILE_NAME="${BE_COMPOSE_FILE_NAME:-docker-compose.yml}"

            [ -f "$BE_COMPOSE_DIR/$COMPOSE_FILE_NAME" ] || { echo "[BE][ERROR] not found: $BE_COMPOSE_DIR/$COMPOSE_FILE_NAME"; exit 1; }

            # docker, docker compose 가용성 체크
            command -v docker >/dev/null 2>&1 || { echo "[BE][ERROR] docker 미설치"; exit 1; }
            docker compose version >/dev/null 2>&1 || command -v docker-compose >/dev/null 2>&1 || { echo "[BE][ERROR] docker compose 미설치"; exit 1; }

            export DOCKER_BUILDKIT=${DOCKER_BUILDKIT}
            export COMPOSE_DOCKER_CLI_BUILD=${COMPOSE_DOCKER_CLI_BUILD}

            # .env 로드
            mkdir -p "$BE_COMPOSE_DIR"
            tr -d '\\r' < "$ENVFILE" > "$BE_COMPOSE_DIR/.env"

            cd "$BE_COMPOSE_DIR"

            # 이미지 빌드 & 컨테이너 재기동
            if docker compose version >/dev/null 2>&1; then
              docker compose --env-file .env pull || true
              docker compose --env-file .env build --parallel
              docker compose --env-file .env up -d --remove-orphans
              docker compose --env-file .env ps
            else
              docker-compose --env-file .env pull || true
              docker-compose --env-file .env build
              docker-compose --env-file .env up -d --remove-orphans
              docker-compose --env-file .env ps
            fi
          '''
        }
      }
    }

    stage('프론트엔드 웹 - 빌드 및 docker-compose 배포') {
      when { anyOf { expression { env.CHANGED_FE_WEB?.trim() }; expression { env.FORCE_ALL == 'true' } } }
      steps {
        withCredentials([file(credentialsId: 'env_secretfile_credential_front', variable: 'ENVFILE')]) {
          sh '''
            set -eu

            CDIR="kdkd_FE/kdkd_web"
            [ -d "$CDIR" ] || { echo "[FE][ERROR] not found: $CDIR"; exit 1; }
            cd "$CDIR"

            tr -d '\\r' < "$ENVFILE" > .env.production

            [ -f Dockerfile ]   || { echo "[FE][ERROR] Dockerfile missing"; exit 1; }
            [ -f nginx.conf ]   || { echo "[FE][ERROR] nginx.conf missing"; exit 1; }

            IMAGE_NAME="${DOCKER_IMAGE_NAME:-kdkd-frontend}"
            CONTAINER_NAME="${CONTAINER_NAME:-kdkd-fe}"
            HOST_PORT="${FE_HOST_PORT:-81}"
            INNER_PORT=80

            export DOCKER_BUILDKIT=0

            docker volume create "${APK_PUB_VOL}" >/dev/null 2>&1 || true

            docker build -t "${IMAGE_NAME}:${BUILD_NUMBER}" .

            # 기존 컨테이너 정리
            docker stop "${CONTAINER_NAME}" 2>/dev/null || true
            docker rm   "${CONTAINER_NAME}" 2>/dev/null || true
            # 실행
            docker run -d --name "${CONTAINER_NAME}" \
              -p "${HOST_PORT}:${INNER_PORT}" \
              -v "${APK_PUB_VOL}:/usr/share/nginx/html/downloads:ro" \
              --restart unless-stopped \
              "${IMAGE_NAME}:${BUILD_NUMBER}"
            docker ps --filter "name=${CONTAINER_NAME}"
          '''
        }
      }
    }

    stage('프론트엔드 모바일 - 빌드') {
      when {
        anyOf {
          expression { return env.CHANGED_FE_MOBILE?.trim() }
          expression { return env.FORCE_ALL == 'true' }
        }
      }
      steps {
        withCredentials([
          file(credentialsId: 'env_secretfile_credential_front',   variable: 'ENVFILE'),
          file(credentialsId: 'google-service',   variable: 'GSVC'),
          file(credentialsId: 'my-release-key', variable: 'RELEASE_KS')
        ]) {
          dir('kdkd_FE/kdkd_mobile') {
            script { setupFlutterAndroid(env.CACHE_ROOT) }
            sh '''
              set -e
              . /tmp/find_pubspec_dir.sh
              export PUB_CACHE="${PUB_CACHE}"
              mkdir -p "${PUB_CACHE}"

              MODDIR="$(find_pubspec_dir)"
              [ -n "$MODDIR" ] || { echo "[mobile][WARN] pubspec.yaml not found → skip mobile build."; exit 0; }
              cd "$MODDIR"

              echo "[mobile] module dir: $MODDIR"

              # env 주입 (CRLF 제거) + 환경변수 로드
              tr -d '\\r' < "$ENVFILE" > .env.ci
              set -a; . ./.env.ci; set +a

              # google-services.json 주입 (필수 경로)
              mkdir -p android/app
              cp "$GSVC" android/app/google-services.json

              # release keystore 주입
              #    - KEYSTORE_BASENAME 미설정 시, 업로드된 파일명으로 자동 설정
              mkdir -p android/keystore
              ksbase="$(basename "$RELEASE_KS")"
              : "${KEYSTORE_BASENAME:=$ksbase}"
              cp "$RELEASE_KS" "android/keystore/${KEYSTORE_BASENAME}"

          # key.properties 생성 (rootProject: android/key.properties 를 읽음)
          #    - KEY_PASSWORD가 비어있으면 store 비번을 기본값으로 사용
          mkdir -p android
          : "${KEY_PASSWORD:=${KEYSTORE_PASSWORD:-}}"
          cat > android/key.properties <<EOF
storeFile=../keystore/${KEYSTORE_BASENAME}
storePassword=${KEYSTORE_PASSWORD}
keyAlias=${KEY_ALIAS}
keyPassword=${KEY_PASSWORD}
EOF

              # keystore/alias/비번
              if [ -n "${KEY_ALIAS:-}" ] && [ -n "${KEYSTORE_PASSWORD:-}" ]; then
                keytool -list -v -keystore "android/keystore/${KEYSTORE_BASENAME}" \
                  -alias "${KEY_ALIAS}" \
                  -storepass "${KEYSTORE_PASSWORD}" \
                  -keypass "${KEY_PASSWORD}" >/dev/null 2>&1 || {
                  echo "[mobile][ERROR] keystore/alias/password mismatch"; exit 1;
                }
              fi

              # 빌드
              flutter --version
              yes | sdkmanager --licenses >/dev/null || true
              flutter pub get

              # Dart 환경변수 주입
              flutter build apk --release --dart-define-from-file=.env.ci
            '''

            script {
              def apkGlob = sh(script: '''
                set -e
                . /tmp/find_pubspec_dir.sh
                MODDIR="$(find_pubspec_dir)"
                if [ -n "$MODDIR" ] && ls "$MODDIR/build/app/outputs/flutter-apk/"*.apk >/dev/null 2>&1; then
                      G="$MODDIR/build/app/outputs/flutter-apk/*.apk"
                      echo "${G#./}"
                else
                  echo ""
                fi
              ''', returnStdout: true).trim()
              if (apkGlob) {
                archiveArtifacts artifacts: apkGlob, fingerprint: true
              } else {
                echo "[mobile] no apk to archive (skipped)."
              }
            }
          }
        }
      }
    }

stage('프론트엔드 모바일 - APK 배포') {
  when {
    anyOf {
      expression { return env.CHANGED_FE_MOBILE?.trim() }
      expression { return env.FORCE_ALL == 'true' }
    }
  }
  steps {
    sh '''
      set -eu
      . /tmp/find_pubspec_dir.sh
      MODDIR="$(find_pubspec_dir)"
      [ -n "$MODDIR" ] || { echo "[mobile] no module"; exit 0; }

      APK="$(ls -1 "$MODDIR"/build/app/outputs/flutter-apk/*.apk | head -n1 || true)"
      [ -f "$APK" ] || { echo "[mobile] no apk built"; exit 0; }

      APK_PUB_VOL="kdkd-downloads-vol"
      BASENAME="kdkd-${BUILD_NUMBER}.apk"

      SHA256=$(sha256sum "$APK" | awk '{print $1}')
      SIZE=$(stat -c %s "$APK")
      VN="" ; VC=""
      if command -v apkanalyzer >/dev/null 2>&1; then
        MANI="$(apkanalyzer manifest print "$APK" || true)"
        VN="$(printf "%s" "$MANI" | awk -F\\" '/android:versionName=/{print $2; exit}')"
        VC="$(printf "%s" "$MANI" | awk -F\\" '/android:versionCode=/{print $2; exit}')"
      fi
      if [ -z "${VN}" ] && command -v aapt >/dev/null 2>&1; then
        VN="$(aapt dump badging "$APK" | awk -F"'" '/versionName=/{print $4; exit}')"
        VC="$(aapt dump badging "$APK" | awk -F"'" '/versionCode=/{print $2; exit}')"
      fi
      VN="${VN:-unknown}" ; VC="${VC:-0}"

      cat > metadata.json <<EOF
{
  "buildNumber": ${BUILD_NUMBER},
  "versionName": "${VN}",
  "versionCode": ${VC},
  "fileName": "${BASENAME}",
  "sha256": "${SHA256}",
  "size": ${SIZE},
  "url": "/downloads/${BASENAME}",
  "latestUrl": "/downloads/app-latest.apk",
  "uploadedAt": "$(date -u +%FT%TZ)"
}
EOF

      docker volume create "${APK_PUB_VOL}" >/dev/null 2>&1 || true

      cat "$APK" | docker run --rm -i \
        -e BASENAME="${BASENAME}" \
        -v "${APK_PUB_VOL}:/dst" \
        alpine:3.20 sh -lc 'cat > "/dst/$BASENAME"'

      cat metadata.json | docker run --rm -i \
        -v "${APK_PUB_VOL}:/dst" \
        alpine:3.20 sh -lc 'cat > /dst/metadata.json'

      # 오래된 파일 정리
      docker run --rm \
        -e BASENAME="${BASENAME}" \
        -v "${APK_PUB_VOL}:/dst" \
        alpine:3.20 sh -lc '
          set -e
          ln -sf "$BASENAME" /dst/app-latest.apk
          ls -1t /dst/kdkd-*.apk 2>/dev/null | tail -n +11 | xargs -r rm -f
        '

      echo "[mobile] published: /downloads/${BASENAME} (and app-latest.apk, metadata.json)"
    '''
  }
}
  } // stages

  post {
    success { echo "${env.CUR_BRANCH} 파이프라인 성공" }
    failure { echo "파이프라인 실패" }
    always  {
      cleanWs(deleteDirs: true)
    }
  }
}