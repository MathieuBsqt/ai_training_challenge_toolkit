#!/bin/bash

source ./lib.sh

ovhai token list -o json  | jq -r 'include "lib"; select_only_team_tokens | .id' | xargs -L1 -I{} ovhai token delete {}
echo "" > $TEAMS_JSON
