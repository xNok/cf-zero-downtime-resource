#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

APP_NAME=${APP_NAME:-cf-zero-downtime-test}

guid=`cf app $APP_NAME --guid`

cat <<JSON | ${DIR}/../in.js ${DIR}
{
  "source": {
    "api": "",
    "username": "",
    "password": "",
    "organization": null,
    "space": null,
    "feature_metadata": true
  },
  "version": {
    "guid": "${guid}"
  }
}
JSON
