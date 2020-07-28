#!/bin/sh

set -e

AWS_S3_BUCKET="$(echo $GITHUB_REF | sed 's:.*/::')"

if [ -z "$AWS_S3_BUCKET" ]; then
  echo "AWS_S3_BUCKET is not set. Quitting."
  exit 1
fi

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
  echo "AWS_ACCESS_KEY_ID is not set. Quitting."
  exit 1
fi

if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "AWS_SECRET_ACCESS_KEY is not set. Quitting."
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
${AWS_ACCESS_KEY_ID}
${AWS_SECRET_ACCESS_KEY}
${AWS_REGION}
text
EOF

# Create S3 bucket
sh -c "aws s3 create-bucket ${SOURCE_DIR:-.} s3://${AWS_S3_BUCKET} \
              --profile s3-action \
              --no-progress \
              ${ENDPOINT_APPEND} $*"

# Sync using our dedicated profile and suppress verbose messages.
# All other flags are optional via the `args:` directive.
sh -c "aws s3 cp ${SOURCE_DIR:-.} s3://${AWS_S3_BUCKET} \
              --profile s3-action \
              --no-progress \
              ${ENDPOINT_APPEND} $*"

# Clear out credentials after we're done.
aws configure --profile s3-action <<-EOF > /dev/null 2>&1
null
null
null
text
EOF
