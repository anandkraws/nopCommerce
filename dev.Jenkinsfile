@Library('mySharedLibrary@plugin') _

pipeline {
  agent { label 'agent-nuget' }

  environment {
    ARTIFACTORY_URL = 'https://aingress.jfrog.io/artifactory/api/nuget/nuget-local/'
    NUGET_CONFIG_FILE = 'nuget.config'
    JF_USERNAME = 'ajit'
    NUGET_OUTPUT_DIR = './nupkgs'
    SOLUTION_FILE = 'src/NopCommerce.sln'
  }

  stages {

stage('Restore NuGet Packages') {
      steps {
        withCredentials([string(credentialsId: 'jenkins-integration-awsingress', variable: 'JF_TOKEN')]) {
          sh '''#!/bin/bash
            dotnet restore ${SOLUTION_FILE} \
              --configfile ${NUGET_CONFIG_FILE}
          '''
        }
      }
    }

    stage('Build Solution') {
      steps {
        echo 'Building the solution in Release mode...'
        sh '''#!/bin/bash
          dotnet build ${SOLUTION_FILE} -c Release --no-incremental
        '''
      }
    }

stage('Pack Projects from Solution') {
  steps {
    echo '📦 Packing all NuGet-packable projects from NopCommerce.sln ...'
    sh '''#!/bin/bash
      set -euo pipefail

      NUGET_OUTPUT_DIR="${NUGET_OUTPUT_DIR:-./nupkgs}"
      mkdir -p "${NUGET_OUTPUT_DIR}"

      echo "🔍 Running dotnet pack on solution ..."
      dotnet pack src/NopCommerce.sln -c Release -o "${NUGET_OUTPUT_DIR}"

      echo "✅ All .nupkg files are located in ${NUGET_OUTPUT_DIR}"
    '''
  }
}


    stage('Push NuGet Packages to Artifactory') {
      steps {
        echo 'Publishing .nupkg packages to JFrog Artifactory...'
        withCredentials([string(credentialsId: 'jenkins-integration-awsingress', variable: 'JF_TOKEN')]) {
          sh '''#!/bin/bash
            for pkg in ${NUGET_OUTPUT_DIR}/*.nupkg; do
              echo "Pushing $pkg ..."
              dotnet nuget push "$pkg" \
                --source "${ARTIFACTORY_URL}" \
                --api-key "Basic $(echo -n ${JF_USERNAME}:${JF_TOKEN} | base64)"
            done
          '''
        }
      }
    }

    stage('Docker Build (Nop.Web)') {
      steps {
        echo 'Building Docker image for Nop.Web app...'
        withCredentials([string(credentialsId: 'jenkins-integration-awsingress', variable: 'JF_TOKEN')]) {
          sh '''#!/bin/bash
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

  post {
    failure {
      echo '❌ Build failed. Check logs above.'
    }
    success {
      echo '✅ Build pipeline completed successfully!'
    }
  }
}
