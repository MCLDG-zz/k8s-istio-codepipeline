# Using AWS CodePipeline to demonstrate deployment strategies on Kubernetes/Istio
CodePipeline that demo's different deployment strategies using Istio on K8s. I use this to demo Canary and Blue/Green
deployments on Kubernetes.

## Preparing for the demo
The demo is a combination of:
* Running the CodePipeline to deploy the app, first a Canary, then a Blue/Green deployment
* Showing the application web page in a browser so we can see the results of the deployment
* Showing the slides (deck titled DevOps Breakout Sessions - kept internally), and explaining the concepts

Getting the timing right requires some practice

Prepare the CodePipeline:
* Clone the repo: https://github.com/MCLDG/k8s-istio-codepipeline
* Follow the instructions in the README to create the CodePipeline

* I use this Firefox add-on to automatically reload web pages. This show the effects of the deployment on the app - http://reloadevery.mozdev.org/
* Trigger the pipeline, either manually in the AWS CodePipeline console or by pushing code to the repo
* In the CodePipeline console, disable the transition between DeployV1 and CanaryV2 (click the arrow in the CodePipeline)
* Explain the slides in the associated deck verbally while the pipeline is progressing: 
    * CodePipeline – a CI/CD Pipeline
    * Review the Bookinfo application
* Enable the transition between DeployV1 and CanaryV2 and:
    * Explain the slide Canary deployment – v1 to v2, and how the health checks work
    * Show the pipeline progress; view the app in the browser using auto-reload. You’ll see some pages with no ratings, and others with black star ratings. 
* As AllV2 continues and complete, only black stars will appear in the ratings section
* Continue to Blue/GreenV3
    * Explain the slide Blue/Green deployment – v2 to v3
* As the web page auto-refreshes, you’ll see black stars, then suddenly red stars as Istio switches traffic from V2 (black stars) to V3 (red stars)
* The V3HealthCheck will start and fail.
* I’ve programmed V3HealthCheck to fail to simulate rollback. You’ll suddenly see black stars again as it rolls back to V2

## Kubernetes Cluster
This demo pipeline requires a Kubernetes cluster on AWS. To deploy a Kubernetes cluster following the
instructions here: https://github.com/aws-samples/aws-workshop-for-kubernetes/tree/master/cluster-install

When you get to the choice on which type of cluster to create, in the section titled `Create a Gossip Based Kubernetes Cluster with kops`,
use a `Default Gossip Based Cluster`. This will create a single master, multi-node and multi-az configuration, which
is sufficient for the demo.

## Update kubeconfig
CodePipeline uses CodeBuild projects to update the Kubernetes cluster. To connect to Kubernetes, CodeBuild will
need a kubeconfig.conf with the connection information for the Kubernetes cluster. After you have created your Kubernetes
cluster, follow these instructions to update the kubeconfig.conf:

* Creating your Kubernetes cluster will create a file on your workstation called <home directory>/.kube/config. On
the Mac this will be ~/.kube/config. Open this file in an editor.
* In this repo, you'll find a file called kubeconfig.conf.template. Copy this file as kubeconfig.conf (in the same folder).
* If this is the first Kubernetes cluster you have created, you can simply copy ~/.kube/config as kubeconfig.conf, overwriting the
file in this repo.
* Otherwise you'll need to follow the steps below, which will update the kubeconfig.conf file with some of the 
configuration from ~/.kube/config.

In a separate editor, open the file kubeconfig.conf. You should now have both config files open. Copy the following sections:

Copy this section from ~/.kube/config to kubeconfig.conf, where the name equals the name of your newly created Kubernetes cluster.
```
- cluster:
    certificate-authority-data: <key>
    server: https://<URL>
  name: demo.cluster.k8s.local
```

Copy this section from ~/.kube/config to kubeconfig.conf, where the name equals the name of your newly created Kubernetes cluster.
```
- context:
    cluster: demo.cluster.k8s.local
    user: demo.cluster.k8s.local
  name: demo.cluster.k8s.local
```

Set the current-context in kubeconfig.conf to the name of your newly created Kubernetes cluster.
```
current-context: demo.cluster.k8s.local
```

Find the line titled `kind: Config`. Under this find `users`.
Copy this section from ~/.kube/config to kubeconfig.conf, where the name equals the name of your newly created Kubernetes cluster.
```
- name: demo.cluster.k8s.local
  user:
    as-user-extra: {}
    client-certificate-data: <key>
    client-key-data: <key>
    password: <pwd>
    username: admin
- name: demo.cluster.k8s.local-basic-auth
  user:
    as-user-extra: {}
    password: <pwd>
    username: admin
```

## Create the CodePipeline
Use the script provided to create the AWS CodePipeline. Edit `create-stack.sh` and update the region to your default 
region - the same region in which you created your Kubernetes cluster. If you aren't sure which region you created
your Kubernetes cluster in, go back to your command line and run the following command, checking the AZ's where your
nodes were created:

```bash
kops validate cluster
```

Run the following from the repo directory on your workstation:

```bash
cd codepipeline
./create-stack.sh
```

## Trigger the CodePipeline
The AWS CodePipeline will be triggered by copying the code from this repo and pushing it to the repo created by the `create-stack.sh`
script above. In the AWS CloudFormation console, in the same account/region in which you created your Kubernetes, 
find the `bookinfo` stack. Look at the Output variables. 

Copy the value of this stack output variable: `SourceCodeCommitCloneUrlHttp`

In a directory in your terminal application (command line) where you want to clone the application repository, 
execute the commands below. 
Note that this clones an empty GIT repo into which you'll copy the source code from this k8s-istio-codepipeline repo 
(you may have to adjust the cp -R statement below if you use a different directory structure):

```bash
git clone <value of the SourceCodeCommitCloneUrlHttp stack output variable>
cp -R k8s-istio-codepipeline/ <cloned repo directory>/   ### note that 'cp' works differently on Mac and Linux. In Linux you may have to use cp -R blg-svlss-msvc/Booking/* <cloned repo directory>/
cd <cloned repo directory>
git add .
git commit -m 'new'
git push
```

It's quite important to use the 'cp' command as specified above, to make sure you do not overwrite the .git file that will already
exist in the directory you cloned into.

This will push the source code to CodeCommit, and trigger the CodePipeline. Each time you want to trigger the CodePipeline,
 you can make a dummy change to any file in the CodeCommit repo and push it to CodeCommit. 

## Checking CodePipeline progress
You can find the CodePipeline in the AWS CloudFormation console by clicking the value of the PipelineUrl stack 
output variable in the 'bookinfo' stack. This will open the AWS CodePipeline in the console and you can watch the
pipeline progressing through the Source, Deploy, Canary steps, etc. If a step fails you can click on 'Details' to see
details of the error.

What I will do during a demo is to run the pipeline before I start talking, and pause it at a particular point. You 
can disable the transition between the CodePipeline steps in the console by clicking the arrow between steps. You can
then enable the step once you are ready to continue.

## Getting the URL for the Bookinfo application
View the CodePipeline in the AWS Console, as explained above. Once the DeployV1 step succeeds, click the `Details` link.
In the `Build logs` section of the CodeBuild page, you'll see a comment `getting the DNS for the productpage endpoint`.
The following line is the URL. Use this URL in a browser, as in 
`http://a0ad9717cf44811e7b1100aff8c57637-1956509818.us-east-1.elb.amazonaws.com/productpage`

This will display the home page for the bookinfo application. You'll see the Reviewer Ratings change (from no ratings,
to black stars to red stars) as the pipeline progresses. This is done by the CodePipeline deploying different versions
of the ratings application, and using Istio to route traffic to these.