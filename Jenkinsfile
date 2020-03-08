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
        timeout(time: 2, unit: 'HOURS')
        buildDiscarder(logRotator(numToKeepStr: '4'))
        skipStagesAfterUnstable()
//        disableConcurrentBuilds()
    }
//    triggers {
// MINUTE HOUR DOM MONTH DOW
//        pollSCM('H 6-18/4 * * 1-5')
//    }
    stages {
        stage('Install Local') {
            agent {
                docker { image 'maven:3-alpine' }
            }
            steps {
                echo "IMAGE_NAME = $IMAGE_NAME"
                sh 'mvn -B install'
            }
        }
        stage('Build Image') {
            agent {
                dockerfile {
                    filename 'Dockerfile'
                    registryCredentialsId 'dockerhub-creds' // Must have been specified in Jenkins
                    args '-v /root/.m2:/root/.m2 -v /var/run/docker.sock:/var/run/docker.sock -v "$PWD":/usr/src/app -v "$HOME/.m2":/root/.m2 -v "$PWD/target:/usr/src/app/target" -w /usr/src/app'
                    additionalBuildArgs "-t ${IMAGE_NAME}"
                }
            }
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
    post {
        always {
            sh "if rm -rf target; then echo 'target dir removed'; else echo 'failed to remove target dir'; fi"
        }
        failure {
            mail(
                to: 'posh.bc@gmail.com', 
                subject: "$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS!", 
                body: "
                    $PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS:

                    Image: ${IMAGE_NAME}

                    Check console output at $BUILD_URL to view the results.
                "
            )
        }
    }
}
