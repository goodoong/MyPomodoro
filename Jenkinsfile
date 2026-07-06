pipeline {
    agent any

    environment {
        DEVELOPER_DIR = '/Applications/Xcode.app/Contents/Developer'
        PROJECT_NAME  = 'MyPomodoro'
        SCHEME_NAME   = 'MyPomodoro'
        XCODE_PROJ    = 'MyPomodoro.xcodeproj'
        GITHUB_OWNER  = 'goodoong'
        GITHUB_REPO   = 'MyPomodoro'
    }

    stages {
        stage('Checkout') {
            steps {
                echo '===== Checkout ====='
                checkout scm
                sh 'git fetch --tags'
            }
        }

        stage('Build') {
            steps {
                echo '===== Build macOS ====='
                sh '''
                xcodebuild \
                    -project "${XCODE_PROJ}" \
                    -scheme "${SCHEME_NAME}" \
                    -destination 'platform=macOS' \
                    clean build
                '''
            }
        }

        stage('Unit Test') {
            steps {
                echo '===== Running Unit Tests ====='
                sh '''
                xcodebuild test \
                    -project "${XCODE_PROJ}" \
                    -scheme "${SCHEME_NAME}" \
                    -destination 'platform=macOS'
                '''
            }
        }

        stage('Archive') {
            steps {
                echo '===== Archive App ====='
                sh '''
                mkdir -p build

                xcodebuild archive \
                    -project "${XCODE_PROJ}" \
                    -scheme "${SCHEME_NAME}" \
                    -destination 'platform=macOS' \
                    -archivePath build/${PROJECT_NAME}.xcarchive
                '''
            }
        }

        stage('Extract App') {
            steps {
                echo '===== Extract App ====='
                sh '''
                mkdir -p release

                cp -R \
                    build/MyPomodoro.xcarchive/Products/Applications/${PROJECT_NAME}.app \
                    release/
                '''
            }
        }

        stage('Create DMG') {
            steps {
                echo '===== Create DMG ====='
                sh '''
                hdiutil create \
                    -volname "${PROJECT_NAME}" \
                    -srcfolder release/${PROJECT_NAME}.app \
                    -ov \
                    -format UDZO \
                    release/${PROJECT_NAME}.dmg
                '''
            }
        }

     stage('GitHub Release') {
            environment {
                GITHUB_TOKEN = credentials('github-token')
            }
            steps {
                sh '''
                set -e
                
                # 1. GitHub CLI 인증 토큰 강제 적용
                export GH_TOKEN=$GITHUB_TOKEN
                /opt/homebrew/bin/gh auth setup-git

                # 2. 태그 감지 및 변수 지정
                if [ -n "$TAG_NAME" ]; then
                    TAG=$TAG_NAME
                elif [ -n "$GITHUB_REF" ]; then
                    TAG=$(echo $GITHUB_REF | sed 's/refs\\/tags\\///')
                else
                    TAG=$(git describe --tags --exact-match 2>/dev/null || true)
                fi

                # 3. 태그가 없다면 날짜+빌드번호 조합으로 생성
                if [ -z "$TAG" ]; then
                    DATE=$(date +%Y.%m.%d)
                    TAG="v${DATE}-b${BUILD_NUMBER}"
                    echo "⚠️ 태그를 감지하지 못해 새 태그를 생성합니다: $TAG"
                    
                    git tag "$TAG"
                    # gh CLI의 인증 체계를 이용해 안전하게 푸시
                    /opt/homebrew/bin/gh repo fork --remote 2>/dev/null || true # 인증 컨텍스트 유지용
                    git push origin "$TAG" || true
                else
                    echo "✅ 릴리즈용 태그 감지 성공: $TAG"
                fi

                # 4. 변경 로그(Changelog) 생성
                PREV_TAG=$(git describe --tags --abbrev=0 "$TAG"^ 2>/dev/null || true)
                if [ -z "$PREV_TAG" ]; then
                    CHANGELOG=$(git log -n 10 --pretty=format:"- %s")
                else
                    CHANGELOG=$(git log ${PREV_TAG}..${TAG} --pretty=format:"- %s")
                fi

                echo "===== Release Notes ====="
                echo "$CHANGELOG"

                # 5. GitHub Release 생성 및 DMG 파일 업로드
                echo "Creating GitHub Release..."
                /opt/homebrew/bin/gh release create "$TAG" \
                    release/MyPomodoro.dmg \
                    --repo "${GITHUB_OWNER}/${GITHUB_REPO}" \
                    --title "$TAG" \
                    --notes "$CHANGELOG"
                '''
            }
        }
    }

    post {
        success {
            echo '===== Build Success ====='
            archiveArtifacts(
                artifacts: 'release/**/*',
                fingerprint: true
            )
        }
        failure {
            echo '===== Build Failed ====='
        }
        cleanup {
            echo '===== Clean Workspace ====='
            cleanWs()
        }
    }
}
