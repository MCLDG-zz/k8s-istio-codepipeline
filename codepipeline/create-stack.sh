region='us-east-1' #region to deploy the CloudFormation stacks
ApplicationName='bookinfo'  #a name for your application

aws cloudformation deploy --stack-name bookinfo --template-file codepipeline.yml --capabilities CAPABILITY_NAMED_IAM --region $region
