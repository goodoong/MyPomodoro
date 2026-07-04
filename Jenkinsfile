pipeline {
    agent any

    environment {
        // Path to the Xcode developer tools on the macOS agent
        DEVELOPER_DIR        = '/Applications/Xcode.app/Contents/Developer'
        
        // Project configuration variables
        PROJECT_NAME        = 'MyPomodoro'
        SCHEME_NAME         = 'MyPomodoro'
        XCODE_PROJ          = 'MyPomodoro.xcodeproj'
        
        // Placeholder variables for App Store Connect deployment
        EXPORT_OPTIONS_PLIST = 'ExportOptions.plist'
        APPLE_ID            = 'your-apple-id@example.com'
    }

    stages {
        stage('Checkout') {
            steps {
                echo '=== Checking repository files ==='
                sh 'ls -la'
            }
        }

        // stage('Verify Python MCP Server') {
        //     steps {
        //         echo '=== Setting up Python Virtual Environment & Dependencies ==='
        //         sh '''
        //             cd agents
        //             chmod +x setup_venv.sh
        //             ./setup_venv.sh
                    
        //             echo '=== Testing MCP Server Import Integrity ==='
        //             source venv/bin/activate
        //             python3 -c "import mcp_server; print('Import check successful! MCP server compiled cleanly.')"
        //         '''
        //     }
        // }

        stage('Build iOS App (Simulator Verification)') {
            steps {
                echo '=== Running Xcode Compilation for Simulator ==='
                sh '''
                    xcodebuild -project "${XCODE_PROJ}" \
                               -scheme "${SCHEME_NAME}" \
                               -sdk iphonesimulator \
                               -destination 'generic/platform=iOS Simulator' \
                               clean build
                '''
            }
        }

        stage('Archive iOS App') {
            // Disabled by default. Change this condition to true once code-signing certificates 
            // and provisioning profiles are configured on your macOS Jenkins agent.
            when {
                expression { return false }
            }
            steps {
                echo '=== Archiving Release Build ==='
                sh '''
                    xcodebuild -project "${XCODE_PROJ}" \
                               -scheme "${SCHEME_NAME}" \
                               -archivePath "build/${PROJECT_NAME}.xcarchive" \
                               archive
                '''
            }
        }

        stage('Export IPA & Deploy') {
            // Disabled by default. Update the expression condition when ready to deploy.
            when {
                expression { return false }
            }
            steps {
                echo '=== Exporting IPA and Uploading to TestFlight ==='
                sh '''
                    # Exporting the IPA using custom export options
                    # xcodebuild -exportArchive \
                    #            -archivePath "build/${PROJECT_NAME}.xcarchive" \
                    #            -exportPath "build/exported" \
                    #            -exportOptionsPlist "${EXPORT_OPTIONS_PLIST}"
                    
                    # Upload to App Store Connect / TestFlight
                    # xcrun altool --upload-app --type ios --file "build/exported/${PROJECT_NAME}.ipa" --username "${APPLE_ID}" --password "${APP_SPECIFIC_PASSWORD}"
                '''
            }
        }
    }

    post {
        always {
            echo '=== Cleaning up workspace ==='
            cleanWs()
        }
        success {
            echo 'CI/CD Pipeline executed successfully!'
        }
        failure {
            echo 'CI/CD Pipeline failed. Please check build logs for details.'
        }
    }
}
