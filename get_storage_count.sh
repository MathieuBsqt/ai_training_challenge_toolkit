#!/bin/bash
set -eu
set -o pipefail

source ./lib.sh


ovhai data list $REGION  --output json | jq -s 'map(.bytes | tonumber) | add ' | numfmt --to iec