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
sh '''
          set -e

          # Securely write secrets to temp files
          jf_user_file=$(mktemp)
          jf_token_file=$(mktemp)

          cat <<< "$JF_USERNAME" > "$jf_user_file"
          cat <<< "$JF_TOKEN" > "$jf_token_file"

          # Docker BuildKit build with mounted secrets
          DOCKER_BUILDKIT=1 docker build \
            --no-cache \
            --secret id=jf_username,src="$jf_user_file" \
            --secret id=jf_token,src="$jf_token_file" \
            -t demonuget:1.0.0 .

          # Clean up
          rm -f "$jf_user_file" "$jf_token_file"
        '''
                  }
                }
              }
            }
            stage ('Docker push') {
                steps {
                    script {
                        // docker.build (local/myimage);
                        creds = jfrog.getCredentials()
                        jfrog.publish(
                            type: 'docker',
                            env: 'dev',
                            credentials: creds,
                            dockerImage: 'nopcommerce:1.0.0', //could also include a tag 'local/image:customTag'
                            tag:'v1.0.0',
                            projectPrefix: 'my_project', //defaults to mahindra but can remove completely with '' or redefine
                            pushLatest: false, // defaults to true, will always push latest tag unless set to false
                        )
                    }
                }
            }

}
