#!/usr/bin/env groovy
/**
 * https://github.com/poshjosh/services
 * @see https://hub.docker.com/_/maven
 *
 * Only double quoted strings support the dollar-sign ($) based string interpolation.
 *
 * Do not use --rm in args as the container will be removed by Jenkins after being
 * run, and jenkins will complain about not being able to remove the container if
 * already removed due to --rm option in args.
 */
//def IMAGE_NAME = 'poshjosh/services:latest'
pipeline {
    agent any
    environment {
        IMAGE = readMavenPom().getArtifactId()
        VERSION = readMavenPom().getVersion()
        IMAGE_NAME = "${IMAGE}:${VERSION}" 
    }
    options {
        timeout(time: 1, unit: 'HOURS')
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
        stage('All') {
            agent {
                dockerfile {
                    filename 'Dockerfile'
                    registryCredentialsId 'dockerhub-creds' // Must have been specified in Jenkins
                    args '-v /root/.m2:/root/.m2 -v /var/run/docker.sock:/var/run/docker.sock -v "$PWD":/usr/src/app -v "$HOME/.m2":/root/.m2 -v "$PWD/target:/usr/src/app/target" -w /usr/src/app'
                    additionalBuildArgs "-t ${IMAGE_NAME}"
                }
            }
            parallel {
                stage('Install Maven Artifact - Local') {
                    stages{
                        stage('Init') {
                            steps {
                                echo "IMAGE_NAME = $IMAGE_NAME"
                            }    
                        }
                        stage('Clean') {
                            steps {
                                sh 'mvn -B clean'
                            }    
                        }
                        stage('Install') {
                            steps {
                                sh 'mvn -B install'
                            }    
                        }
                    }
                }
                stage('Build & Deploy Docker Image - Remote') {
                    steps {
                        echo 'Running Script in Declarative'
                        script {
                            docker.withRegistry('', 'dockerhub-creds') {

                                def customImage = docker.build("${IMAGE_NAME}")

                                /* Push the container to the custom Registry */
                                customImage.push()
                            }
                        }
                    }
                }
            }
        }
    }
    post {
        always {
            echo 'COMPLETED'
            deleteDir() /* clean up workspace */
        }
        success {
            echo 'SUCCESS!'
        }
        unstable {
            echo 'UNSTABLE :/'
        }
        failure {
            echo 'FAILED :('
            mail(
                to: 'posh.bc@gmail.com', 
                subject: "$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS!", 
                body: "$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS:\n\nImage: ${IMAGE_NAME}\n\nCheck console output at $BUILD_URL to view the results."
            )
        }
        changed {
            echo 'CHANGES MADE'
        }
    }
}
