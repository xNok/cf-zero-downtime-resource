#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cat <<JSON | ${DIR}/../out.js ${DIR}
{
  "source": {
    "api": "",
    "username": "",
    "password": "",
    "organization": null,
    "space": null
  },
  "params": {
    "name": "cf-zero-downtime-test",
    "path": "app-good",
    "manifest": "manifest-static.yml",
    "environment_variables": {
      "TEST": "This is a test"
    }
  }
}
JSON
