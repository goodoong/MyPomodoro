pipeline {
    agent any

    environment {
        DEVELOPER_DIR = '/Applications/Xcode.app/Contents/Developer'

        PROJECT_NAME = 'MyPomodoro'
        SCHEME_NAME  = 'MyPomodoro'
        XCODE_PROJ   = 'MyPomodoro.xcodeproj'
        GITHUB_OWNER = 'goodoong'
        GITHUB_REPO = 'MyPomodoro'

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

                echo "===== Workspace ====="
                pwd

                echo "===== Build Folder ====="
                ls -R build || true

                echo "===== XCArchive ====="
                find . -name "*.xcarchive"

                echo "===== Archive Structure ====="

                find build/MyPomodoro.xcarchive -maxdepth 3
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

                echo "===== Release Folder ====="
                ls -R release
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

                echo "===== Release Files ====="
                ls -lh release
                '''
            }
        }

       stage('GitHub Release') {
            when {
                expression {
                    return sh(
                        script: 'git describe --tags --exact-match >/dev/null 2>&1',
                        returnStatus: true
                    ) == 0
                }
            }
        
            environment {
                GITHUB_TOKEN = credentials('github-token')
            }
        
            steps {
                sh '''
                set -e
        
                export GH_TOKEN=$GITHUB_TOKEN
        
                # 현재 태그 가져오기
                TAG=$(git describe --tags --exact-match)
        
                # 이전 태그 가져오기
                PREV_TAG=$(git describe --tags --abbrev=0 $(git rev-list --tags --skip=1 --max-count=1) 2>/dev/null || true)
        
                # Release Notes 생성
                if [ -z "$PREV_TAG" ]; then
                    echo "First release"
                    CHANGELOG=$(git log --pretty=format:"- %s")
                else
                    CHANGELOG=$(git log ${PREV_TAG}..${TAG} --pretty=format:"- %s")
                fi
        
                echo "===== Release Notes ====="
                echo "$CHANGELOG"
        
                # GitHub Release 생성 + DMG 업로드
                gh release create "$TAG" \
                    release/MyPomodoro.dmg \
                    --repo ${GITHUB_OWNER}/${GITHUB_REPO} \
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
