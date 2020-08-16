#!/bin/sh

set -ex

AWS_S3_BUCKET=testbox-"$(echo $GITHUB_REF | sed 's:.*/::')"

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

else

  sh -c "aws s3 sync ${GITHUB_WORKSPACE} s3://${AWS_S3_BUCKET}/ \
              --no-progress"
  echo "syncing files"

fi

