# Jenkins Pipeline Syntax Reference

## Declarative Pipeline

```groovy
pipeline {
    agent any
    
    options {
        timeout(time: 1, unit: 'HOURS')
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }
    
    environment {
        DEPLOY_ENV = 'production'
        CREDS = credentials('my-credentials')
    }
    
    stages {
        stage('Build') {
            steps {
                sh 'make build'
            }
        }
        
        stage('Test') {
            parallel {
                stage('Unit Tests') {
                    steps {
                        sh 'make test-unit'
                    }
                }
                stage('Integration Tests') {
                    steps {
                        sh 'make test-integration'
                    }
                }
            }
        }
        
        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                sh 'make deploy'
            }
        }
    }
    
    post {
        always {
            junit 'reports/**/*.xml'
            cleanWs()
        }
        success {
            slackSend color: 'good', message: 'Build succeeded'
        }
        failure {
            slackSend color: 'danger', message: 'Build failed'
        }
    }
}
```

## Scripted Pipeline

```groovy
node('linux') {
    try {
        stage('Checkout') {
            checkout scm
        }
        
        stage('Build') {
            sh 'make build'
        }
        
        if (env.BRANCH_NAME == 'main') {
            stage('Deploy') {
                sh 'make deploy'
            }
        }
    } catch (e) {
        currentBuild.result = 'FAILURE'
        throw e
    } finally {
        cleanWs()
    }
}
```

## Shared Libraries

```groovy
// vars/buildPipeline.groovy
def call(Map config) {
    pipeline {
        agent any
        stages {
            stage('Build') {
                steps {
                    sh config.buildCommand ?: 'make build'
                }
            }
        }
    }
}

// Jenkinsfile
@Library('my-shared-library') _
buildPipeline(buildCommand: 'npm run build')
```

## Credentials

```groovy
withCredentials([
    usernamePassword(
        credentialsId: 'docker-hub',
        usernameVariable: 'DOCKER_USER',
        passwordVariable: 'DOCKER_PASS'
    )
]) {
    sh 'docker login -u $DOCKER_USER -p $DOCKER_PASS'
}
```
