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
            steps {
                sh '''
                    ./deploy.sh \
                        --kube-context 'gcp-cameronhudson8'
                '''
            }
        }
    }
}