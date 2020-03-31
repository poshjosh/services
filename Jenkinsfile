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
        VOLUME_BINDINGS = '-v /home/.m2:/root/.m2'
        FAILURE_EMAIL_RECIPIENT = 'posh.bc@gmail.com'
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
        stage('Build Image') {
            steps {
                echo " = = = = = = = BUILDING IMAGE = = = = = = = "
                script {
                    def additionalBuildArgs = "--pull"
                    if (env.BRANCH_NAME == "master") {
                        additionalBuildArgs = "--no-cache ${additionalBuildArgs}"
                    }
                    docker.build("${IMAGE_NAME}", "${additionalBuildArgs} .")
                }
            }
        }
        stage('Clean & Install') {
            steps {
                echo " = = = = = = = CLEAN & INSTALL = = = = = = = "
                script{
                    docker.image("${IMAGE_NAME}").inside("${VOLUME_BINDINGS}"){
                        sh 'mvn -B clean:clean install:install'
                   }
                }
            }
        }
        stage('Deploy Image') {
            when {
//                branch 'master' // Only works for multibranch pipeline
                expression {
                    return env.GIT_BRANCH == "origin/master"
                }
            }
            steps {
                echo " = = = = = = = DEPLOYING IMAGE = = = = = = = "
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
            script{
                retry(3) {
                    try {
                        timeout(time: 60, unit: 'SECONDS') {
                            deleteDir() // Clean up workspace
                        }
                    } catch (org.jenkinsci.plugins.workflow.steps.FlowInterruptedException e) {
                        // we re-throw as a different error, that would not
                        // cause retry() to fail (workaround for issue JENKINS-51454)
                        error 'Timeout!'
                    }
                } // retry ends
            }
            sh "docker system prune -f --volumes"
        }
        failure {
            mail(
                to: "${FAILURE_EMAIL_RECIPIENT}",
                subject: "$IMAGE_NAME - Build # $BUILD_NUMBER - FAILED!",
                body: "$IMAGE_NAME - Build # $BUILD_NUMBER - FAILED:\n\nCheck console output at ${env.BUILD_URL} to view the results."
            )
        }
    }
}
