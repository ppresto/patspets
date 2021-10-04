# patspets

This is a Simple python flask app that also contains TF infrastructure as code meant to validated through a CI/CD Pipeline and then merged to master.

## TFCB Demo
* Use vCode to show VCS driven workflow
* [PR/MR workflow](https://github.com/ppresto/patspets/pull/55)
* [Github Actions workflow](https://github.com/ppresto/patspets/pull/50)
## Requirements
Refer to [githun.com/ppresto/myJenkins](https://github.com/ppresto/myJenkins) for the docker image setup and organization discovery job.

## Process Overview
1. In this example we are developing on the branch: stage.  
2. We commit our changes and create a PR to merge them to master.
3. The jenkins Org will scan every day for new Repos with a Jenkinsfile and create jobs for them.
4. These child jobs will scan every hour for new or updated PR's in these repos. We can speed this up by manually kicking off a scan.
5. If changes are found the pipeline will run.  If successful changes will be validated and merged to the master branch. 

## CI Workflow

### Start Jenkins Container (Development Mode - Not saving Jenkins_home)
This container is pre configured with the organizational discovery job that is looking for **ppresto/patspets** repo.

```
docker run -d --rm --name jenkins -p 8080:8080  \
-e TRY_UPGRADE_IF_NO_MARKER=true \
-e JENKINS_SMTP=mail.google.com \
-e JENKINS_EMAIL=ppresto@hashicorp.com \
-e setUIProxy=false \
-e JENKINS_UI_URL=https://localhost:8080 \
myjenkins:latest

docker logs -f jenkins  #tail the logs
```

### Login
Review and Update your Jenkins Jobs by accessing the [Jenkins Console](http://localhost:8080).
1. Security is not enabled so not login credentails required.
2. Review the cicd organizational discovery job
   1. ensure it is configured with your org and looking for a Jenkinsfile in the repos you want.
   2. Verify the ref specs are setup for the proper branches and types of commits/PRs you want trigging your pipeline.
   3. Verify the tokens for TFE and Github are setup for your repo.
3. Go to Jobs -> cicd 

### Github Repo
Clone your repo locally and take a look at it with your code editor.
1. Branch: stage
2. Review Jenkinsfile
3. Make a change to app or infra code
4. commit change locally
5. create PR to master from your code editor or using Github.com

### Jenkins Job
Your jenkins cicd Job is scheduled to scan your organization every hour.  It will automatically scan your repos that have a Jenkinsfile.  It is looking for PR's from stage to master and any new or updated PR's will trigger the pipeline to run.  You can speed this up by initiating a manual scan.
* localhost:8080 -> Jobs -> cicd -> Click on "Scan Organization"

You can now click on View Output or watch the docker logs you are tailing to verify Jenkins is finding your changes.  Once your changes are found you can watch the pipeline run by going back to your Jobs -> cicd.
1. Go to the repo your cicd job found (ex: patspets)
2. Go to the PR tab
3. Click on the latest PR.  To see streaming console output click on the jobs output icon (blinking red dot).

### Jenkinsfile examples
This example repo has Jenkinsfile examples showing how to use the TFE API, or CLI to automate your Terraform pipelines.  The default one is using the CLI because this is how most teams start.  As your pipeline matures many times we see heavier use of the API.


[Jenkinsfile CLI](https://github.com/ppresto/patspets/blob/master/Jenkinsfile)


[Jenkinsfile API](https://github.com/ppresto/patspets/blob/master/Jenkinsfile-TFE_API)


The example Jenkinsfile has a few functions defined.  Supporting...
* Sending notifications to slack
* Sending status updates to the Github PR
* Final PR merge from stage to master to complete the cycle

