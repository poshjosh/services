#!/usr/bin/env groovy
/**
 * https://github.com/poshjosh/services
 * @see https://hub.docker.com/_/maven
 */
pipeline {
    agent any
    environment {
        ARTIFACTID = readMavenPom().getArtifactId();
        VERSION = readMavenPom().getVersion()
        PROJECT_NAME = "${ARTIFACTID}:${VERSION}"
        IMAGE_REF = "poshjosh/${PROJECT_NAME}";
        IMAGE_NAME = IMAGE_REF.toLowerCase()
    }
    options {
        timeout(time: 6, unit: 'HOURS')
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
        stage('Install Artifact & Deploy Image') {
            agent {
                dockerfile {
                    filename 'Dockerfile'
                    registryCredentialsId 'dockerhub-creds' // Must have been specified in Jenkins
                    args '-v "$PWD":/usr/src/app -v /home/.m2:/root/.m2 -v "$PWD/target:/usr/src/app/target" -w /usr/src/app'
                    additionalBuildArgs "-t ${IMAGE_NAME}"
                }
            }
            stages{
                stage('Echo') {
                    steps{
                        echo "HOME = $HOME"
                        echo "PATH = $PATH"
                    }
                }
                stage('Clean & Install') {
                    steps {
                        sh 'mvn -B clean:clean install:install'
                    }
                }
                stage('Deploy Image') {
                    environment {
                        PATH = "/usr/bin/docker:$PATH"
                    }
                    steps {
                        withDockerRegistry([url: '', credentialsId: 'dockerhub-creds']) {
                            sh '''
                                "docker push $IMAGE_NAME"
                                "docker rmi $IMAGE_NAME"
                            '''
                        }
                    }
                }
            }
        }
    }
    post {
        always {
            deleteDir() /* clean up workspace */
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
