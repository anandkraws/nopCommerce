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
stage('Docker Build') {
  steps {
    withCredentials([string(credentialsId: 'jenkins-integration-awsingress', variable: 'JF_TOKEN')]) {
      script {
        sh '''#!/bin/bash
          set -euo pipefail
          
          echo "🔧 Fixing line endings and permissions for entrypoint.sh"
          sed -i 's/\\r$//' entrypoint.sh
          chmod +x entrypoint.sh
          file entrypoint.sh
          head -n 1 entrypoint.sh | od -c

          echo "🐳 Building Docker image with BuildKit ..."
          export DOCKER_BUILDKIT=1
          docker build \
            --no-cache \
            --secret id=jf_username,src=<(echo "$JF_USERNAME") \
            --secret id=jf_token,src=<(echo "$JF_TOKEN") \
            -t nopcommerce:1.0.0 .
        '''
      }
    }
  }
}

}
