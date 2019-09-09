# patspets

This is a Simple python flask app that also contains TF infrastructure as code meant to validated through a CI/CD Pipeline and then merged to master.

## Requirements
Refer to [githun.com/ppresto/myJenkins](https://github.com/ppresto/myJenkins) for the server setup and organization discovery job.

## Process Overview
1. In this example we are developing on the branch: stage.  
2. We commit our changes and create a PR to merge them to master.
3. The jenkins Org will scan every day for new Repos with a Jenkinsfile and create jobs for them.
4. These child jobs will scan every hour for new or updated PR's in these repos. We can speed this up by manually kicking off a scan.
5. If changes are found the pipeline will run.  If successful changes will be validated and merged to the master branch. 
