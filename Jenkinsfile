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
                    args '-v /usr/bin/docker:/usr/bin/docker -v /root/.m2:/root/.m2 -v /var/run/docker.sock:/var/run/docker.sock -v "$PWD":/usr/src/app -v "$HOME/.m2":/root/.m2 -v "$PWD/target:/usr/src/app/target" -w /usr/src/app'
                    additionalBuildArgs "-t ${IMAGE_NAME}"
                }
            }
            stages{
//                stage('Clean & Install') {
//                    steps {
//                        sh 'mvn -B clean install'
//                    }    
//                }
//                stage('Deploy Image') {
//                    steps {
//                        withDockerRegistry([url: '', credentialsId: 'dockerhub-creds']) {
//                            sh "docker push $IMAGE_NAME"
//                        }
//                    }
//                }
                stage('Remove Local Image') {
                    steps {
                        sh "./deploy.sh"
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
