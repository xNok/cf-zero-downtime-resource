#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

ALIAS=${1:-emerald-squad}
PIPELINE_NAME=${3:-cf-zero-downtime-resource}

fly -t "${ALIAS}" sp --non-interactive -p "${PIPELINE_NAME}" -c $DIR/pipeline.yml 
fly -t "$ALIAS" expose-pipeline -p "$PIPELINE_NAME"
