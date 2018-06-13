#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cat <<JSON | ${DIR}/../in.js ${DIR}
{
  "source": {
    "api": "",
    "username": "",
    "password": "",
    "organization": null,
    "space": null
  },
  "params": {
    "name": "cf-zero-downtime-test"
  }
}
JSON
