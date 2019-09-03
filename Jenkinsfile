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
            TFE_API_URL = "${TFE_URL}/api/v2"
            TFE_API_TOKEN = credentials("tfe_api_token")
      }

            stages {
                  stage('Preparation') {
                        steps {
                            git branch: 'master',
                                credentialsId: 'github-myjenkins-token',
                                url: "${GIT_REPO}"

                            dir("${env.WORKSPACE}/tfe"){
                                sh '''
                                curl -o tf.zip https://releases.hashicorp.com/terraform/0.11.14/terraform_0.11.14_linux_amd64.zip ; yes | unzip tf.zip
                                pwd
                                ./terraform version
                              '''
                            }

                        }
                  }
                  stage('TFE Workstation list ') {
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
                  stage('Terraform Init') {
                        steps {
                            dir("${env.WORKSPACE}/tfe"){
                                sh '''
                                ./terraform init -backend-config="TF_ACTION_TFE_TOKEN=${TFE_API_TOKEN}" 
                                '''
                            notifySlack("Terriform Init complete! http://localhost:8080/job/$JOB_NAME/$BUILD_NUMBER/console", notification_channel, [])
                            }
                        }
                  }
                  stage('Terraform Plan/Apply') {
                      steps {
                            dir("${env.WORKSPACE}/tfe"){
                                sh '''
                                ./terraform apply
                                '''
                            }
                      }
                  }
                  stage('Three') {
                  when {
                        not {
                              branch "master"
                        }
                  }
                  steps {
                        echo "Not Master Branch"
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