pipeline {
    agent {
        kubernetes {
            yamlFile 'jenkins-agent.yaml'
            defaultContainer 'helm'
        }
    }
    stages {
        stage('Test') {
            steps {
                sh '''
                    ./deploy.sh \
                        --kube-context 'gcp-cameronhudson8'
                        --dry-run
                '''
            }
        }
        stage('Deploy') {
            when { branch 'main' }
            environment {
                CLIENT_ID = credentials('client-id')
                CLIENT_SECRET = credentials('client-secret')
                MONGO_INITDB_ROOT_PASSWORD = credentials('mongo-initdb-root-password')
            }
            steps {
                sh '''
                    ./deploy.sh \
                        --kube-context 'gcp-cameronhudson8' \
                        "--client-id=${CLIENT_ID}" \
                        "--client-secret=${CLIENT_SECRET}" \
                        --host='iskprinter.com' \
                        "--mongo-initdb-root-password=${MONGO_INITDB_ROOT_PASSWORD}"
                '''
            }
        }
    }
}