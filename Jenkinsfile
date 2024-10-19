pipeline {
    agent any
    environment {
        DOCKER_CREDENTIALS_ID = 'docker_credentials'
        DOCKER_IMAGE_NAME = 'shazly3/webapp'
        ANSIBLE_INVENTORY = '/home/ec2-user/' // Update this path
    }
    stages {
        stage('Checkout Code') {
            steps {
                git url: 'https://github.com/shazly3/depi.git', branch: 'main'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    app = docker.build(DOCKER_IMAGE_NAME)
                }
            }
        }
        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', DOCKER_CREDENTIALS_ID) {
                        app.push('latest')
                    }
                }
            }
        }
        stage('Run Docker Compose with Ansible') {
            steps {
                sshagent(['ssh']) {  // Replace with your credentials ID
                script {
                    sh '''
                        ansible-playbook -i hosts playbook.yaml
                    '''
                }
                }
            }
        }
    }
    post {
        
        success {
            slackSend (channel: 'jenkins', message: "Pipeline succeeded: ${env.JOB_NAME} #${env.BUILD_NUMBER}")
        }
        failure {
            slackSend (channel: 'jenkins', message: "Pipeline failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}")
        }
        always {
            slackSend (channel: 'jenkins', message: "Pipeline finished: ${env.JOB_NAME} #${env.BUILD_NUMBER}")
        }
    }

}
