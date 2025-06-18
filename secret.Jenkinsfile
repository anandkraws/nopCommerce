@Library('mySharedLibrary@plugin') _

pipeline {
    agent { label 'agent-nuget' }
    // tools { jfrog 'myJFROG' }

    environment {
        ARTIFACTORY_URL = 'https://aingress.jfrog.io/artifactory/nuget-virtual/'
        NUGET_CONFIG_FILE = 'nuget.config'
        JF_USERNAME='ajit'
        //JF_TOKEN=credentials('jenkins-integration-awsingress')
        //DOCKER_BUILDKIT = '1'   
    }
  stages {
    stage('Docker Build') {
      steps {
        withCredentials([string(credentialsId: 'jenkins-integration-awsingress', variable: 'JF_TOKEN')]) {
          script {
            // Use bash explicitly since <(…) is a bash feature
            sh '''#!/bin/bash
              export DOCKER_BUILDKIT=1
              docker build \
                --no-cache \
                --secret id=jf_username,src=<(echo "$JF_USERNAME") \
                --secret id=jf_token,src=<(echo "$JF_TOKEN") \
                -t nopCommerce:prod .
            '''
          }
        }
      }
    }
  }
}
