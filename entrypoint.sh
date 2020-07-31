#!/bin/sh

set -e

AWS_S3_BUCKET=testbox-"$(echo $GITHUB_REF | sed 's:.*/::')"

if [ -z "$AWS_ACCESS_KEY_ID_TESTBOX" ]; then
  echo "AWS_ACCESS_KEY_ID_TESTBOX is not set. Quitting."
  exit 1
fi

if [ -z "$AWS_SECRET_ACCESS_KEY_TESTBOX" ]; then
  echo "AWS_SECRET_ACCESS_KEY_TESTBOX is not set. Quitting."
  exit 1
fi

# Default to us-east-1 if AWS_REGION not set.
if [ -z "$AWS_REGION" ]; then
  AWS_REGION="eu-central-1"
fi

# Override default AWS endpoint if user sets AWS_S3_ENDPOINT.
if [ -n "$AWS_S3_ENDPOINT" ]; then
  ENDPOINT_APPEND="--endpoint-url $AWS_S3_ENDPOINT"
fi

aws configure --profile s3-action <<-EOF > /dev/null 2>&1
${AWS_ACCESS_KEY_ID_TESTBOX}
${AWS_SECRET_ACCESS_KEY_TESTBOX}
${AWS_REGION}
text
EOF

# Create S3 bucket
sh -c "aws s3 mb s3://${AWS_S3_BUCKET} \
              --profile s3-action \
              --region ${AWS_REGION} > /dev/null"

# Clear out credentials after we're done.
aws configure --profile s3-action <<-EOF > /dev/null 2>&1
null
null
null
text
EOF
