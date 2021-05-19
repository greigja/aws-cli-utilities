#!/bin/bash
# STS session token for MFA in conjunction with AWS CLI usage

# trim credentials file down to remove previously generated STS credentials
head -n 7 ~/.aws/credentials > ~/.aws/tmp
rm ~/.aws/credentials
more ~/.aws/tmp > ~/.aws/credentials

#collect mfa token to use in collecting STS token
read -p 'Please enter your MFA token for '${AWS_PROFILE}': ' token

# display and run AWS CLI command to retrieve AWS session token and store output in tmp file
echo
echo 'aws sts get-session-token --serial-number '${AWS_MFA_ARN}' --token-code '${token}' \
  --profile default'
echo
aws sts get-session-token --serial-number ${AWS_MFA_ARN} --token-code ${token} \
  --profile default > ~/.aws/tmp

# parse command output to get key values and cleanup tmp file
aaki=`more ~/.aws/tmp | python3 -c "import sys, json; print(json.load(sys.stdin)['Credentials']['AccessKeyId'])"`
asak=`more ~/.aws/tmp | python3 -c "import sys, json; print(json.load(sys.stdin)['Credentials']['SecretAccessKey'])"`
ast=`more ~/.aws/tmp | python3 -c "import sys, json; print(json.load(sys.stdin)['Credentials']['SessionToken'])"`
rm ~/.aws/tmp

#append new key values onto AWS CLI credentials file
echo 'aws_access_key_id = '${aaki} >> ~/.aws/credentials
echo 'aws_secret_access_key = '${asak} >> ~/.aws/credentials
echo 'aws_session_token = '${ast} >> ~/.aws/credentials