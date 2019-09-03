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
            stage('TFE Init') {
                  steps {
                        // List env vars for ref
                        echo sh(returnStdout: true, script: 'env')
                        setBuildStatus("Initializing Terraform", "PENDING");
                        dir("${env.WORKSPACE}/${env.TFE_DIRECTORY}"){
                              sh '''
                                    curl -o tf.zip https://releases.hashicorp.com/terraform/0.11.14/terraform_0.11.14_linux_amd64.zip ; yes | unzip tf.zip
                                    ./terraform version
                                    cat <<CONFIG | tee remote.tf
terraform { 
      backend "remote" { 
            hostname     = "${TFE_NAME}"
            organization = "${TFE_ORGANIZATION}"
            token        = "${TFE_API_TOKEN}"
            
            workspaces { 
                  name = "${TFE_WORKSPACE}" 
            }
      }
}
CONFIG
                                    cat remote.tf
                                    terraform init
                                    terraform plan
                              '''
                        }
                        notifySlack("TFE Content Planned: http://localhost:8080/job/$JOB_NAME/$BUILD_NUMBER/console \nTFE:${TFE_URL}/app/${TFE_ORGANIZATION}/workspaces/${TFE_WORKSPACE}/runs/", notification_channel, [])
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