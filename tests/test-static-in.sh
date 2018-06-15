#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

guid=`cf app cf-zero-downtime-test --guid`

cat <<JSON | ${DIR}/../in.js ${DIR}
{
  "source": {
    "api": "",
    "username": "",
    "password": "",
    "organization": null,
    "space": null
  },
  "version": {
    "guid": "${guid}"
  },
  "params": {
    "name": "cf-zero-downtime-test"
  }
}
JSON
