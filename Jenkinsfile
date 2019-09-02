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
                              git "${GIT_REPO}"
                              sh "ls"
                              sh '''
                                    #curl -o tf.zip https://releases.hashicorp.com/terraform/0.11.14/terraform_0.11.14_linux_amd64.zip ; yes | unzip tf.zip
                                    terraform version
                                    pwd
                                    ls 
                                    echo $TFE_API_TOKEN
                                    
                              '''
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
                        sh "echo ${TFE_API_TOKEN}"
                        sh "sed -i 's/TFE_API_TOKEN/${TFE_API_TOKEN}/' main.tf"
                        sh "cat main.tf"
                        sh "./terraform init"
                        }
                  }
                  stage('One') {
                  steps {
                        echo 'Hello from HashiCorp'
                  }
                  }
                  stage('Three') {
                  when {
                        not {
                              branch "master"
                        }
                  }
                  steps {
                        echo "Hello"
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