#!/bin/bash -eux

# Force update of a lambda on all accounts in one region
SEARCH_LAMBDA="billing"
REGION="eu-west-1"
S3_BUCKET="operations-project-conf"
S3_KEY="billing-mngt/lambda_billing.py.zip"

# Make use of AWS MFA to avoid typing MFA for each account
/usr/local/bin/aws-mfa --profile project-mfa && export AWS_PROFILE=project-mfa

# List of roles to assume
array=(
    'project-security!arn:aws:iam::376784669955:role/AccountManagement'
    'project-operations!arn:aws:iam::609599400603:role/AccountManagement'
    'project-msi-prod!arn:aws:iam::750807515549:role/AccountManagement'
    'project-bp-dev!arn:aws:iam::357908572257:role/AccountManagement'
    'project-bp-qa!arn:aws:iam::497436304185:role/AccountManagement'
    'project-bp-prod!arn:aws:iam::291640506852:role/AccountManagement'
    'project-ec-prod!arn:aws:iam::713455933410:role/AccountManagement'
    'project-ec-staging!arn:aws:iam::545189154929:role/AccountManagement'
    'project-ec-dev!arn:aws:iam::864998192381:role/AccountManagement'
    'project-bp-staging!arn:aws:iam::129432942334:role/AccountManagement'
    'project-gp-dev!arn:aws:iam::334073175487:role/AccountManagement'
    'project-gp-prod!arn:aws:iam::704980350482:role/AccountManagement'
    'project-gp-staging!arn:aws:iam::690567541202:role/AccountManagement'
    'project-msi-dev!arn:aws:iam::209627535499:role/AccountManagement'
    'project-msi-staging!arn:aws:iam::250466553988:role/AccountManagement'
)

# Loop over all accounts
for index in "${array[@]}" ; do
    KEY="${index%%!*}"
    VALUE="${index##*!}"

    # Assume role
    KST=(`aws --profile 'project-mfa' sts assume-role --role-arn $VALUE \
                          --role-session-name "Session" \
                          --duration-seconds 3600 \
                          --query '[Credentials.AccessKeyId,Credentials.SecretAccessKey,Credentials.SessionToken]' \
                          --output text`)
                          
    export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-$REGION}
    export AWS_ACCESS_KEY_ID=${KST[0]}
    export AWS_ACCESS_KEY=${KST[0]}
    export AWS_SECRET_ACCESS_KEY=${KST[1]}
    export AWS_SECRET_KEY=${KST[1]}
    export AWS_SESSION_TOKEN=${KST[2]}
    export AWS_SECURITY_TOKEN=${KST[2]}
    export AWS_DELEGATION_TOKEN=${KST[2]}

    # Update lambda functions
    echo Updating $SEARCH_LAMBDA Lambda with profile: $KEY...
    FUNCTION_NAME=(`aws lambda list-functions --region $REGION | grep $SEARCH_LAMBDA | grep FunctionName | awk '{print $2}' | cut -d'"' -f2`)
    aws lambda update-function-code --function-name $FUNCTION_NAME --region $REGION --s3-bucket $S3_BUCKET --s3-key $S3_KEY --publish
done
