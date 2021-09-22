#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export TERRAFORM_CONFIG="${DIR}/.terraformrc"

# This is for the time to wait when using demo_magic.sh
if [[ -z ${DEMO_WAIT} ]];then
  DEMO_WAIT=0
fi

# Demo magic gives wrappers for running commands in demo mode.   Also good for learning via CLI.
. ${DIR}/demo-magic.sh -d -p -w ${DEMO_WAIT}

source $HOME/awsSetEnv.sh

if [[ -z ${ATLAS_TOKEN} ]]; then
  echo "Missing Required Env Variable: ATLAS_TOKEN"
  echo "please set ATLAS_TOKEN so this script can create the necessary .terraformrc"
  echo "export ATLAS_TOKEN=<Terraform Enterprise App Token>"
  exit 1
fi

# look for my org and app tokens and switch for this shell env
if [[ ! -z ${APP_TFE_TOKEN} && ! -z ${ATLAS_TOKEN} ]]; then
  ATLAS_TOKEN=${APP_TFE_TOKEN} 
fi

cd ../

echo
lblue "###########################################"
lcyan "  CLI Workflow with Terraform Enterprise"
lblue "###########################################"
echo 
cyan "#"
cyan "### Configure your backend to point to your TFE Workspace"
cyan "#"
echo
cat backend.tf
p ""
echo
cyan "#"
cyan "### Create .terraformrc file with your TFE credentials"
cyan "#"
p "
# .terraformrc

credentials \"app.terraform.io\" {
  token = "xxxxxxx"
}

"

# Create .terraformrc to enable TFE backend
cat <<- CONFIG > ${DIR}/.terraformrc
credentials "app.terraform.io" {
  token = "${ATLAS_TOKEN}"
}
CONFIG

echo
cyan "Set TERRAFORM_CONFIG in your Environment"
p "export TERRAFORM_CONFIG=\"${DIR}/.terraformrc\""
echo 

echo
cyan "#"
cyan "### Now Run Terraform like normal"
cyan "#"
echo
cyan "Initialize the remote backend and download module dependencies"
pe "terraform init"

echo
cyan "Now Run your Terraform Commands"
pe "terraform apply"

# clean up sensitive files
rm -rf ${DIR}/../.terraform*
