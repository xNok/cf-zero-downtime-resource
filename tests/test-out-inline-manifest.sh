#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# this function allows us to see the stderr output in red. Make it easy to see if 
color()(set -o pipefail;"$@" 2>&1>&3|sed $'s,.*,\e[31m&\e[m,'>&2)3>&1

echo "test successful app deploy"

cat <<JSON | color ${DIR}/../out.js ${DIR}
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
    "manifest": {
      "applications": [
        {
          "name": "cf-zero-downtime-test",
          "buildpack": "nodejs_buildpack",
          "memory": "64M",
          "health-check-type": "http",
          "health-check-http-endpoint": "/good"
        }
      ]
    },
    "environment_variables": {
      "TEST": "This is a test"
    }
  }
}
JSON
