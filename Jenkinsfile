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
                
                export GH_TOKEN=$GITHUB_TOKEN
                /opt/homebrew/bin/gh auth setup-git

                if [ -n "$TAG_NAME" ]; then
                    TAG=$TAG_NAME
                elif [ -n "$GITHUB_REF" ]; then
                    TAG=$(echo $GITHUB_REF | sed 's/refs\\/tags\\///')
                else
                    TAG=$(git describe --tags --exact-match 2>/dev/null || true)
                fi

                if [ -z "$TAG" ]; then
                    DATE=$(date +%Y.%m.%d)
                    TAG="v${DATE}-b${BUILD_NUMBER}"
                    echo "⚠️ New tag: $TAG"
                    
                    git tag "$TAG"
                    /opt/homebrew/bin/gh repo fork --remote 2>/dev/null || true
                    git push origin "$TAG" || true
                else
                    echo "✅ Detected tag: $TAG"
                fi

                PREV_TAG=$(git describe --tags --abbrev=0 "$TAG"^ 2>/dev/null || true)
                if [ -z "$PREV_TAG" ]; then
                    CHANGELOG=$(git log -n 10 --pretty=format:"- %s")
                else
                    CHANGELOG=$(git log ${PREV_TAG}..${TAG} --pretty=format:"- %s")
                fi

                echo "===== Release Notes ====="
                echo "$CHANGELOG"

                echo "Creating or Updating GitHub Release..."
                if /opt/homebrew/bin/gh release view "$TAG" --repo "${GITHUB_OWNER}/${GITHUB_REPO}" >/dev/null 2>&1; then
                    /opt/homebrew/bin/gh release edit "$TAG" --repo "${GITHUB_OWNER}/${GITHUB_REPO}" --title "$TAG" --notes "$CHANGELOG"
                    /opt/homebrew/bin/gh release upload "$TAG" release/MyPomodoro.dmg --repo "${GITHUB_OWNER}/${GITHUB_REPO}" --clobber
                else
                    /opt/homebrew/bin/gh release create "$TAG" release/MyPomodoro.dmg --repo "${GITHUB_OWNER}/${GITHUB_REPO}" --title "$TAG" --notes "$CHANGELOG"
                fi
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
