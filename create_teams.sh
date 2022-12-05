#!/bin/bash
set -eu
set -o pipefail

source ./lib.sh

# returns an error if there is not one and only one argument
if [ $# -lt 2 ]; then
    echo "Usage: <PREFIX> <TEAM_NAME_1> <TEAM_NAME_2> ..."
    echo "TEAM_NAME: name of the team"
    echo "You may use the seq command to generate a list of team names"
    exit 1
fi

PREFIX=$1
echo "PREFIX: $PREFIX"
shift
echo "TEAM_NAMES: $@"

(
    for team_number in $@; do
        team_name="${PREFIX}_team_${team_number}"
        ovhai token create -o json -r "read" -l "kili_challenge_team=$team_name" $team_name
    done
) | jq  '{team:.spec.name, token:.status.value}' >> $TEAMS_JSON

