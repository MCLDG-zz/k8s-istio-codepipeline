region='us-east-1' #region to deploy the CloudFormation stacks
ApplicationName='bookinfo'  #a name for your application

aws cloudformation delete-stack --stack-name bookinfo --region $region
