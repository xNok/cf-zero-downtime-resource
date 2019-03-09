#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TEMP_DIR="$(mktemp -d -p "$DIR")"
RAND="$(< /dev/urandom tr -dc 'a-zA-Z0-9' | head -c 32)"

if [[ -z "$TEMP_DIR" || ! -d "$TEMP_DIR" ]]; then
  echo "Failed to create temporary directory"
  exit 1
fi

function cleanup {
  rm -rf "$TEMP_DIR"
}

trap cleanup EXIT

echo "test: should start app with inline manifest, substituting variables from files"

cat <<EOF > $TEMP_DIR/vars-file-1.yml
---
value: incorrect
file_1_var: file_1_val
EOF

cat <<EOF > $TEMP_DIR/vars-file-2.yml
---
value: still_incorrect
file_2_var: file_2_val
EOF

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
      "random_value": "((value))",
      "file_1_var": "((file_1_var))",
      "file_2_var": "((file_2_var))",
      "inline_var": "((inline_var))"
    },
    "vars_files": [
      "$TEMP_DIR/vars-file-1.yml",
      "$TEMP_DIR/vars-file-2.yml"
    ],
    "vars": {
      "value": "$RAND",
      "inline_var": "inline_val"
    }
  }
}
JSON

test "$(cf app cf-zero-downtime-test | awk '/^instances:/{print $2}')" == "1/1"

env="$(cf env cf-zero-downtime-test)"
test "$(awk '/^random_value:/ { print $2 }' <<< "$env")" == "$RAND"
test "$(awk '/^file_1_var:/ { print $2 }' <<< "$env")" == "file_1_val"
test "$(awk '/^file_2_var:/ { print $2 }' <<< "$env")" == "file_2_val"
test "$(awk '/^inline_var:/ { print $2 }' <<< "$env")" == "inline_val"
