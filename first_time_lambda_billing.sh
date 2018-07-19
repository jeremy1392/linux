#!/bin/bash -eux

# Upload the lambda code for the first time to S3

AWSPROFILE_S3="project-operations" # Name of AWS Profile to use to upload the new code
BUCKETNAME="operations-project-conf" # Example: operations-project-conf
KEYNAME="billing-mngt"
ZIP_NAME="lambda_billing.py.zip" # Example: ebs-snapshot-scheduler.zip
FOLDER="project-billing/" # Example: ebs-snapshot-scheduler/

cd $FOLDER
zip -r $ZIP_NAME .
aws s3api put-object --bucket $BUCKETNAME --key $KEYNAME/$ZIP_NAME --body $ZIP_NAME --profile $AWSPROFILE_S3; echo "Lambda uploaded."
rm $ZIP_NAME; echo "Zip cleaned up."
