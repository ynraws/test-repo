pipeline {
    agent { label 'jenkins' }

    environment {
        GOOGLE_APPLICATION_CREDENTIALS = credentials('gcp-service-account')
        GOOGLE_CLOUD_PROJECT = credentials('gcp-project-id')
    }

    stages {
        stage('Node.js') {
            steps {
                container('nodejs') {
                    sh 'echo Hello from Kubernetes using Node.js container!'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                container('docker') {
                    script {
                        def imageName = "netflix"
                        def tag = "latest"
                        def registryUrl = "us-central1-docker.pkg.dev"
                        def fullImageName = "${registryUrl}/${GOOGLE_CLOUD_PROJECT}/netflix-repo/${imageName}:${tag}"
                        
                        // Login to Google Container Registry
                        sh """
                        cat ${GOOGLE_APPLICATION_CREDENTIALS} | docker login -u _json_key --password-stdin https://${registryUrl}
                        """
                        
                        // Build and Tag Docker Image
                        sh "docker build -t ${imageName}:${tag} ."
                        sh "docker tag ${imageName}:${tag} ${fullImageName}"
                        
                        // Push Docker Image to GCP
                        sh "docker push ${fullImageName}"
                        sh "docker image prune -f && docker volume prune -f"
                    }
                }
            }
        }

        stage('Install Trivy and Scan') {
            steps {
                container('docker') {
                    sh '''
                    wget -qO- https://github.com/aquasecurity/trivy/releases/download/v0.26.0/trivy_0.26.0_Linux-64bit.tar.gz | tar xz -C /usr/local/bin/
                    trivy image --exit-code 1 --severity HIGH,CRITICAL us-central1-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/netflix-repo/netflix:latest
                    '''
                }
            }
        }
    }
}
