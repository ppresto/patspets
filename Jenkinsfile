import groovy.json.JsonOutput

//slack env vars
env.slack_url = 'https://hooks.slack.com/services/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'
env.notification_channel = 'ppresto-alerts'

//jenkins env vars
env.jenkins_node_label = 'master'

def notifySlack(text, channel, attachments) {
    def payload = JsonOutput.toJson([text: text,
        channel: channel,
        username: "Jenkins",
        attachments: attachments
    ])
    sh "curl -X POST --data-urlencode \'payload=${payload}\' ${slack_url}"
}

pipeline {
      agent any
      environment {
            GIT_REPO = "https://github.com/ppresto/patspets"
            TFE_NAME = "app.terraform.io"
            TFE_URL = "https://app.terraform.io"
            TFE_ORGANIZATION = "Patrick"
            TFE_WORKSPACE = "patspets_master"
            TFE_API_URL = "${TFE_URL}/api/v2"
            TFE_API_TOKEN = credentials("tfe_api_token")
            TFE_DIRECTORY = "tfe"
            UPLOAD_FILE_NAME = "./content."sh(script: 'date +%s', , returnStdout: true).trim()".tar.gz"
            
      }

      stages {
            stage('Clone Repo') {
                  steps {
                        git branch: 'master',
                              credentialsId: 'github-myjenkins-token',
                              url: "${GIT_REPO}"
                  }
            }
            stage('Create TFE Content') {
                  steps {
                        sh '''
                              tar -C "$TFE_DIRECTORY" -zcvf "$UPLOAD_FILE_NAME" .
                        '''
                  }
            }
            stage('List TFE Workspaces') {
                  steps {
                  sh '''
                        curl \
                        --silent --show-error --fail \
                        --header "Authorization: Bearer $TFE_API_TOKEN" \
                        --header "Content-Type: application/vnd.api+json" \
                        ${TFE_API_URL}/organizations/${TFE_ORGANIZATION}/workspaces \
                        | jq -r \'.data[] | .attributes.name\'
                  '''
                  }
            }
            stage('Get Workspace ID') {
                  steps {
                        sh '''
                              WORKSPACE_ID=$(curl \
                              --header "Authorization: Bearer $TFE_API_TOKEN" \
                              --header "Content-Type: application/vnd.api+json" \
                              ${TFE_API_URL}/organizations/$TFE_ORGANIZATION/workspaces/$TFE_WORKSPACE \
                              | jq -r '.data.id')
                        '''
                  }
            }
            stage('Create New Config Version') {
                  steps {
                        sh '''
                              echo '{"data":{"type":"configuration-version"}}' > ./create_config_version.json
                              UPLOAD_URL=$(curl \
                              --header "Authorization: Bearer $TFE_API_TOKEN" \
                              --header "Content-Type: application/vnd.api+json" \
                              --request POST \
                              --data @create_config_version.json \
                              ${TFE_API_URL}/workspaces/$WORKSPACE_ID/configuration-versions \
                              | jq -r '.data.attributes."upload-url"')
                        '''
                        notifySlack("New Configuration Version Created! http://localhost:8080/job/$JOB_NAME/$BUILD_NUMBER/console", notification_channel, [])
                  }
            }
            stage('Upload Content') {
                  steps {
                        sh '''
                              curl \
                              --header "Content-Type: application/octet-stream" \
                              --request PUT \
                              --data-binary @"$UPLOAD_FILE_NAME" \
                              $UPLOAD_URL
                        '''
                  }
            }
            
            stage('Four') {
                  parallel { 
                        stage('Unit Test') {
                              steps {
                                    echo "Running the unit test..."
                              }
                        }
                        stage('Parrallel test') {
                              steps {
                                    echo "Running the integration test..."
                              }
                        }
                  }
            }
      }
}