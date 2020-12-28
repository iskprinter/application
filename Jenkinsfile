pipeline {
    agent {
        kubernetes {
            yamlFile 'jenkins-agent.yaml'
            defaultContainer 'helm'
        }
    }
    environment {
        CLIENT_ID = credentials('eve-app-client-id')
        CLIENT_SECRET = credentials('eve-app-client-secret')
        MONGO_INITDB_ROOT_PASSWORD = credentials('mongo-initdb-root-password')
    }
    stages {
        stage('Test') {
            steps {
                sh '''
                    ./deploy.sh \
                        "--client-id=${CLIENT_ID}" \
                        "--client-secret=${CLIENT_SECRET}" \
                        --host='iskprinter.com' \
                        "--mongo-initdb-root-password=${MONGO_INITDB_ROOT_PASSWORD}" \
                        --dry-run
                '''
            }
        }
        stage('Deploy') {
            when { branch 'main' }
            steps {
                sh '''
                    ./deploy.sh \
                        "--client-id=${CLIENT_ID}" \
                        "--client-secret=${CLIENT_SECRET}" \
                        --host='iskprinter.com' \
                        "--mongo-initdb-root-password=${MONGO_INITDB_ROOT_PASSWORD}"
                '''
            }
        }
    }
}