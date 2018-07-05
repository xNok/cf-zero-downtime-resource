#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "test: should bind services with configuration"

# this function allows us to see the stderr output in red. Make it easy to see if 
color()(set -o pipefail;"$@" 2>&1>&3|sed $'s,.*,\e[31m&\e[m,'>&2)3>&1

if ! cf service my-service; then
  echo "You must create a service named my-service that can accept binding configuration before running this test!"
  exit 1
fi

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
    "name": "cf-zero-downtime-test-with-services",
    "path": "app",
    "manifest": "manifest-good.yml",
    "environment_variables": {
      "TEST": "This is a test"
    },
    "services": [
      {
        "name": "my-service",
        "config": {
          "share": "my-share",
          "mount": "/home/cf-zero-downtime-test-with-services/data",
          "uid": "1000",
          "gid": "1000"
        }
      }
    ]
  }
}
JSON
