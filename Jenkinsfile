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
pipeline {
    agent any
    environment {
        ARTIFACTID = readMavenPom().getArtifactId();
        VERSION = readMavenPom().getVersion()
        PROJECT_NAME = "${ARTIFACTID}:${VERSION}"
        IMAGE = "poshjosh/${PROJECT_NAME}";
        IMAGE_NAME = IMAGE.toLowerCase()
        PATH = "C:\Program Files\Docker\Docker\resources\bin:$PATH"
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
            stages{
                stage('Print PATH') {
                    steps {
                        echo "PATH = $PATH";
                    }    
                }
//                stage('Clean & Install') {
//                    agent {
//                        docker { image 'maven:3-alpine' }
//                    }
//                    steps {
//                        sh 'mvn -B install'
//                    }    
//                }
                stage('Build & Deploy Image') {
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
                stage('Remove Local Image') {
                    steps{
                        sh "docker rmi $IMAGE_NAME"
                    }
                }
//                stage('Build Image') {
//                    script {
//                        docker.build IMAGE_NAME
//                    }
//                }
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
