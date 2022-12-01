#!/bin/bash
set -eu
set -o pipefail

# returns an error if there is not one and only one argument
if [ $# -eq 0 ]; then
    echo "Usage: <TEAM_NAME_1> <TEAM_NAME_2> ..."
    echo "TEAM_NAME: name of the team"
    echo "You may use the seq command to generate a list of team names"
    exit 1
fi

NB_TOKENS=$1

(
    for team_number in $@; do
        team_name="team_${team_number}"
        ovhai token create -o json -r "read" -l "kili_challenge_team=$team_name" $team_name
    done
) | jq  '{team:.spec.name, token:.status.value}' >> teams.json

