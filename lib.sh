#!/bin/bash
set -eu
set -o pipefail


REGION=$(jq -r '.current_config_name' ~/.config/ovhai/config.json)
TEAMS_JSON=teams_$REGION.json

export REGION
export TEAMS_JSON
