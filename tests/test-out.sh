#!/bin/bash
set -e

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
    "path": "app",
    "manifest": "manifest-good.yml",
    "environment_variables": {
      "TEST": "This is a test"
    }
  }
}
JSON

cat <<JSON | ${DIR}/../out.js ${DIR} && exit 1 || echo "passed"
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
    "path": "app",
    "manifest": "manifest-bad.yml",
    "environment_variables": {
      "TEST": "This is a test"
    }
  }
}
JSON
