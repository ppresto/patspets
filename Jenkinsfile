import groovy.json.JsonOutput
// Global Variables
env.slack_url = 'https://hooks.slack.com/services/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'
env.notification_channel = 'ppresto-alerts'

//Slack - Send Slack Notifications at important stages of your pipeline
def notifySlack(text, channel, attachments) {
    def payload = JsonOutput.toJson([text: text,
        channel: channel,
        username: "Jenkins",
        attachments: attachments
    ])
    sh "curl -X POST --data-urlencode \'payload=${payload}\' ${slack_url}"
}


//Github - Dynamically Set Build Status per phase in your Github PR Page
void setBuildStatus(String message, String state) {
  step([
      $class: "GitHubCommitStatusSetter",
      reposSource: [$class: "ManuallyEnteredRepositorySource", url: env.GIT_URL],
      contextSource: [$class: "ManuallyEnteredCommitContextSource", context: "ci/jenkins/build-status"],
      errorHandlers: [[$class: "ChangingBuildStatusErrorHandler", result: "UNSTABLE"]],
      statusResultSource: [ $class: "ConditionalStatusResultSource", results: [[$class: "AnyBuildResult", message: message, state: state]] ]
  ]);
}

// Github - Merge and close your PR
def mergeThenPush(repo, toBranch) {
  withCredentials([usernamePassword(credentialsId: 'github-ppresto', passwordVariable: 'gitPass', usernameVariable: 'gitUser')]) {
      sh "git config --global user.email \"ppresto@hashicorp.com\""
      sh "git config --global user.name \"Patrick Presto\""
      sh "git checkout ${toBranch}"
      sh "git pull https://${gitUser}:${gitPass}@${repo} ${toBranch}"
      sh "git merge origin/${env.BRANCH_NAME} --no-ff --no-edit"
      sh "git push https://${gitUser}:${gitPass}@${repo} origin/${toBranch}"
  }
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
            UPLOAD_FILE_NAME = "./content.${TFE_WORKSPACE}.tar.gz"
            TERRAFORM_CONFIG = "${WORKSPACE}/${TFE_DIRECTORY}/.terraformrc"
      }

      stages {
            stage('initialize') {
                  steps {
                        notifySlack("${TFE_WORKSPACE} - Initializing Job http://localhost:8080/job/cicd/job/patspets/view/change-requests/job/${env.BRANCH_NAME}/$BUILD_NUMBER/console", notification_channel, [])

                        // List env vars for ref
                        setBuildStatus("Initializing Terraform", "Initializing");
                        dir("${env.WORKSPACE}/${env.TFE_DIRECTORY}"){
                              sh '''
                                    if [[ ! -f terraform ]]; then curl -o tf.zip https://releases.hashicorp.com/terraform/0.11.14/terraform_0.11.14_linux_amd64.zip ; yes | unzip tf.zip; fi
                                    env
                                    ./terraform version
cat <<CONFIG | tee .terraformrc
credentials "${TFE_NAME}" {
  token = "${TFE_API_TOKEN}"
}
CONFIG
                                    ./terraform init
                              '''
                        }
                  }
            }

            stage('Terraform Plan') {
                  steps {
                        echo "Running terraform plan"
                  }
            }
            stage('Sentinal Policy Check') {
                  steps {
                        echo "Checking Sentinel Policies"
                  }
            }
            stage('Terraform Apply') {
                  steps {
                        setBuildStatus("Terraform Apply", "PENDING");
                        dir("${env.WORKSPACE}/${env.TFE_DIRECTORY}"){
                              sh '''                                   
                                    ./terraform apply
                              '''
                        }
                        notifySlack("${TFE_WORKSPACE} - Terraform Apply - ${TFE_URL}/app/${TFE_ORGANIZATION}/workspaces/${TFE_WORKSPACE}/runs/", notification_channel, [])
                  }        
            }

            stage('Post Validation') {
                  parallel { 
                        stage('Integration Tests') {
                              steps {
                                    echo "Running test cases"
                              }
                        }
                        stage('Security Tests') {
                              steps {
                                    echo "Running test cases"
                              }
                        }
                        stage('Functional Tests') {
                              steps {
                                    echo "Running test cases"
                              }      
                        }
                  }
            }
            stage('Merge') {
                  steps {
                        echo "Merging ${env.BRANCH_NAME} to master"
                        mergeThenPush("github.com/ppresto/patspets", "master")
                        notifySlack("${TFE_WORKSPACE} - PR Merged - ${TFE_URL}/app/${TFE_ORGANIZATION}/workspaces/${TFE_WORKSPACE}/runs/", notification_channel, [])

                  }
            }
            stage('Clean Up') {
                  steps {
                        sh '''                                   
                              rm -rf ${WORKSPACE}/.git*
                        '''
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