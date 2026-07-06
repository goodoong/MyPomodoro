pipeline {
    agent any

    environment {
        DEVELOPER_DIR = '/Applications/Xcode.app/Contents/Developer'

        PROJECT_NAME = 'MyPomodoro'
        SCHEME_NAME  = 'MyPomodoro'
        XCODE_PROJ   = 'MyPomodoro.xcodeproj'
    }

    stages {

        stage('Checkout') {
            steps {
                echo '===== Checkout ====='
                sh 'ls -la'
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

    }

    post {

        success {
            echo '===== Build Success ====='

            // archiveArtifacts(
            //     artifacts: 'build/**/*',
            //     fingerprint: true
            // )
        }

        failure {
            echo '===== Build Failed ====='
        }

        always {
            echo '===== Clean Workspace ====='
            cleanWs()
        }
    }
}
