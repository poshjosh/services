#!/usr/bin/env groovy
/**
 * https://github.com/poshjosh/services
 * @see https://hub.docker.com/_/maven
 */
library(
    identifier: 'jenkins-shared-library@master',
    retriever: modernSCM(
        [
            $class: 'GitSCMSource',
            remote: 'https://github.com/poshjosh/jenkins-shared-library.git'
        ]
    )
)

pipelineForMavenDockerfile(gitUrl : 'https://github.com/poshjosh/services.git')