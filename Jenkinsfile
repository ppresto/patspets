import groovy.json.JsonOutput

//slack
env.slack_url = 'https://hooks.slack.com/services/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'
env.notification_channel = 'ppresto-alerts'

//Github - Setting Build Status
void setBuildStatus(String message, String state) {
  step([
      $class: "GitHubCommitStatusSetter",
      reposSource: [$class: "ManuallyEnteredRepositorySource", url: env.GIT_URL],
      contextSource: [$class: "ManuallyEnteredCommitContextSource", context: "ci/jenkins/build-status"],
      errorHandlers: [[$class: "ChangingBuildStatusErrorHandler", result: "UNSTABLE"]],
      statusResultSource: [ $class: "ConditionalStatusResultSource", results: [[$class: "AnyBuildResult", message: message, state: state]] ]
  ]);
}

def notifySlack(text, channel, attachments) {
    def payload = JsonOutput.toJson([text: text,
        channel: channel,
        username: "Jenkins",
        attachments: attachments
    ])
    sh "curl -X POST --data-urlencode \'payload=${payload}\' ${slack_url}"
}

//def WORKSPACE_ID = "unknown"

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
            UPLOAD_FILE_NAME = "./content.${TFE_WORKSPACE}.tar.gz"
            
      }

      stages {
            stage('Create TFE Content') {
                  steps {
                        // List env vars for ref
                        echo sh(returnStdout: true, script: 'env')
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
                        script {
                              env.WORKSPACE_ID = sh(returnStdout: true, script: 'curl \
                              --header "Authorization: Bearer $TFE_API_TOKEN" \
                              --header "Content-Type: application/vnd.api+json" \
                              ${TFE_API_URL}/organizations/$TFE_ORGANIZATION/workspaces/$TFE_WORKSPACE \
                              | jq -r ".data.id"').trim()
                        }
                  }
            }
            stage('Create New Config Version') {
                  steps {
                        echo "WORKSPACE_ID: ${WORKSPACE_ID}"                           
                        sh '''
                              echo '{"data":{"type":"configuration-version"}}' > ./create_config_version.json
                        '''
                        script {
                              env.UPLOAD_URL = sh(returnStdout: true, script: 'curl \
                              --header "Authorization: Bearer $TFE_API_TOKEN" \
                              --header "Content-Type: application/vnd.api+json" \
                              --request POST \
                              --data @create_config_version.json \
                              ${TFE_API_URL}/workspaces/$WORKSPACE_ID/configuration-versions \
                              | jq -r \'.data.attributes."upload-url"\'').trim()
                        }
                  }
            }
            stage('Upload Content') {
                  steps {
                        setBuildStatus("Uploading Content to ${UPLOAD_URL}", "PENDING");
                        echo "URL: ${UPLOAD_URL}"
                        sh '''
                              curl \
                              --header "Content-Type: application/octet-stream" \
                              --request PUT \
                              --data-binary @"$UPLOAD_FILE_NAME" \
                              ${UPLOAD_URL}
                        '''
                        notifySlack("New Content Uploaded from Job: http://localhost:8080/job/$JOB_NAME/$BUILD_NUMBER/console \nTFE:${TFE_URL}/app/${TFE_ORGANIZATION}/workspaces/${TFE_WORKSPACE}/runs/", notification_channel, [])
                  }
            }
            
            stage('Four') {
                  parallel { 
                        stage('Cleanup') {
                              steps {
                                    sh '''
                                    rm "${UPLOAD_FILE_NAME}"
                                    rm ./create_config_version.json
                                    rm -rf ${WORKSPACE}/*
                                    rm -rf ${WORKSPACE}/.git*
                                    '''
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

      post {
    success {
        setBuildStatus("Build Succeeded", "SUCCESS");
    }
    failure {
        setBuildStatus("Build Failed", "FAILURE");
    }
  }

}