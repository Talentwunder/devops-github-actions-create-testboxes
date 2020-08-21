#!/bin/sh

set -ex

echo "THIS IS THE BRANCH ENV VAR: $GITHUB_REF"

AWS_S3_BUCKET=testbox-"$(echo $GITHUB_REF | sed 's/refs//' | sed 's/heads//' | sed 's@//@@' | sed 's/\//-/g')"

echo "THIS IS THE AWS BUCKET ENV VAR: $AWS_S3_BUCKET"

# Create S3 bucket
BUCKET_NAME=$(aws s3 ls | grep ${AWS_S3_BUCKET} | awk '{print $3}')

if [ -z "${BUCKET_NAME}" ];
then

  sh -c "aws s3 mb s3://${AWS_S3_BUCKET} \
                --region ${AWS_REGION}"
  echo "creating the bucket"

  sh -c "aws s3 cp ${GITHUB_WORKSPACE} s3://${AWS_S3_BUCKET}/ \
                --recursive"
  echo "Copying files"

# Enable static website hosting on the bucket
  sh -c "aws s3 website s3://${AWS_S3_BUCKET} \
                --index-document index.html \
                --error-document error.html"

# Invoke lambda function to list buckets
  sh -c "aws lambda invoke \
                --function-name arn:aws:lambda:eu-central-1:518986006376:function:listTestboxBuckets \
                --invocation-type Event \
                response.json"
else

  sh -c "aws s3 sync ${GITHUB_WORKSPACE} s3://${AWS_S3_BUCKET}/ \
              --no-progress"
  echo "syncing files"

fi

