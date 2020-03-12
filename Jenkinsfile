#!/usr/bin/env groovy
/**
 * https://github.com/poshjosh/services
 * @see https://hub.docker.com/_/maven
 */
def IMAGE_NAME = 'poshjosh/services:latest'
pipeline {
    agent {
        docker {
            additionalBuildArgs "-t ${IMAGE_NAME}"
        }
    }
    environment {
        ARTIFACTID = readMavenPom().getArtifactId();
        VERSION = readMavenPom().getVersion()
        PROJECT_NAME = "${ARTIFACTID}:${VERSION}"
        IMAGE_REF = "poshjosh/${PROJECT_NAME}";
//        IMAGE_NAME = IMAGE_REF.toLowerCase()
    }
    options {
        timestamps()
        timeout(time: 30, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '4'))
        skipStagesAfterUnstable()
        disableConcurrentBuilds()
    }
    triggers {
// @TODO use webhooks from GitHub
// Once in every 2 hours slot between 0900 and 1600 every Monday - Friday
        pollSCM('H H(8-16)/2 * * 1-5')
    }
    stages {
        stage('Clean & Install') {
            steps {
                sh 'mvn -B clean:clean install:install'
            }
        }
        stage('Deploy Image') {
            when {
                branch 'master'
            }
            steps {
                script {
                    docker.withRegistry('', 'dockerhub-creds') { // Must have been specified in Jenkins
                        sh "docker push ${IMAGE_NAME}"
                    }
                }
            }
        }
    }
    post {
        always {
            deleteDir() /* clean up workspace */
            sh "docker system prune -f --volumes"
        }
        failure {
            mail(
                to: 'posh.bc@gmail.com',
                subject: "$IMAGE_NAME - Build # $BUILD_NUMBER - FAILED!",
                body: "$IMAGE_NAME - Build # $BUILD_NUMBER - FAILED:\n\nCheck console output at ${env.BUILD_URL} to view the results."
            )
        }
    }
}
