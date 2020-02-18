pipeline {
    agent any
    tools{
        maven 'M3'
        jdk 'JDK8'
    }
    stages {
        stage ('Initialize') {
            steps {
                script{
                    bat '''
                    echo 'M2_HOME = %M2_HOME%'
                    echo 'JAVA_HOME = %JAVA_HOME%'
                    '''
                }
            }
        }
        stage('Build') {
            steps {
                script{
                    bat "cd %M2_HOME%/bin"
                    bat "mvn package"
                }
            }
        }
    }
}
