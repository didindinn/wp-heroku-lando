#!/bin/bash

set -e

USAGE="sync-s3-uploads.sh <source env> <target env>"

export AWS_ACCESS_KEY_ID=`heroku config:get BUCKETEER_AWS_ACCESS_KEY_ID`
export AWS_SECRET_ACCESS_KEY=`heroku config:get BUCKETEER_AWS_SECRET_ACCESS_KEY`
export AWS_REGION=`heroku config:get BUCKETEER_AWS_REGION`

# Check args
if [ -z "$1" ] || [ -z "$2" ]; then
  echo $USAGE >&2;
  [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1;
fi

UPLOADS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../web/app/uploads" && pwd)"

# Get bucket urls
if [[ $1 == 'local' ]]; then
  SOURCE_URL=$UPLOADS_DIR
else
  SOURCE_URL=s3://`heroku config:get BUCKETEER_BUCKET_NAME -r $1`/uploads;
fi;

if [[ $2 == 'local' ]]; then
  TARGET_URL=$UPLOADS_DIR
else
  TARGET_URL=s3://`heroku config:get BUCKETEER_BUCKET_NAME -r $2`/uploads;
fi;

echo "You are about to copy all files from $SOURCE_URL to $TARGET_URL";
read -p "Are you sure you want to do this? (y/n)
";
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1;
fi

# Use aws-cli to synchronize buckets
aws s3 sync $SOURCE_URL $TARGET_URL

echo "Success!"

