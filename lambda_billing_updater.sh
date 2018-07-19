#!/bin/bash -eux
AWSPROFILE_S3="project-operations" # Name of AWS Profile to use to upload the new code
AWSPROFILE_LAMBDA="project-security" # Name of AWS Profile to use to update the lambda

BUCKETNAME="operations-project-conf" # Example: operations-project-conf
FUNCTION_NAME="TestBilling" # Example: project-security-tagchimp-TagchimpFunction-NY0RTN7NSPVL
KEYNAME="billing-mngt"
ZIP_NAME="lambda_billing.py.zip" # Example: ebs-snapshot-scheduler.zip
REGION="eu-west-1" # Example: eu-west-1
FOLDER="project-billing/" # Example: ebs-snapshot-scheduler/

cd $FOLDER
zip -r $ZIP_NAME .
aws s3api put-object --bucket $BUCKETNAME --key $KEYNAME/$ZIP_NAME --body $ZIP_NAME --profile $AWSPROFILE_S3; echo "Lambda uploaded."
aws lambda update-function-code --function-name $FUNCTION_NAME --zip-file fileb://$ZIP_NAME --publish --region $REGION --profile $AWSPROFILE_LAMBDA; echo "Lambda updated."
rm $ZIP_NAME; echo "Zip cleaned up."
