#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

docker build -t cf-zero-downtime-resource-test $DIR/..

jq -n "
{
  \"source\": {
    \"api\": \"${CF_API}\",
    \"username\": \"${CF_USERNAME}\",
    \"password\": \"${CF_PASSWORD}\",
    \"organization\": \"${CF_ORG}\",
    \"space\": \"${CF_SPACE}\"
  },
  \"params\": {
    \"name\": \"cf-zero-downtime-test\"
  }
}" | docker run -v ${DIR}:/tmp/build -i cf-zero-downtime-resource-test /opt/resource/in /tmp/build
