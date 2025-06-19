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
        echo 'Restoring NuGet packages...'
        sh '''#!/bin/bash
          dotnet restore ${SOLUTION_FILE} --configfile ${NUGET_CONFIG_FILE}
        '''
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

    stage('Pack Selected Projects') {
      steps {
        echo 'Packing selected plugin projects into .nupkg files...'
        sh '''#!/bin/bash
          mkdir -p ${NUGET_OUTPUT_DIR}

          # List of plugin projects to pack
          PLUGINS=(
            src/Plugins/Nop.Plugin.Misc.Omnisend/Nop.Plugin.Misc.Omnisend.csproj
            src/Plugins/Nop.Plugin.Payments.Manual/Nop.Plugin.Payments.Manual.csproj
            src/Plugins/Nop.Plugin.Shipping.UPS/Nop.Plugin.Shipping.UPS.csproj
            # Add more .csproj paths here as needed
          )

          for csproj in "${PLUGINS[@]}"; do
            echo "Packing $csproj ..."
            dotnet pack "$csproj" -c Release -o ${NUGET_OUTPUT_DIR}
          done
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
