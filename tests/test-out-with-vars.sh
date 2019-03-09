#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
RAND="$(< /dev/random tr -dc 'a-zA-Z0-9' | head -c 32)"

echo "test: should start app with inline manifest, substituting variables"

# this function allows us to see the stderr output in red. Make it easy to see if 
color()(set -o pipefail;"$@" 2>&1>&3|sed $'s,.*,\e[31m&\e[m,'>&2)3>&1

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
      "random_value": "((value))"
    },
    "vars": {
      "value": "$RAND"
    }
  }
}
JSON

test "$(cf app cf-zero-downtime-test | awk '/^instances:/{print $2}')" == "1/1"
test "$(cf env cf-zero-downtime-test | awk '/^random_value:/ { print $2 }')" == "$RAND"
