#!/bin/bash
set -eu
set -o pipefail

# returns an error if there is not one and only one argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <IMAGE> <ARGS>"
    echo "IMAGE: docker image to run"
    exit 1
fi

IMAGE=$1
running=$(ovhai job list -o json)
(
    for team_name in $(jq -sr '.[] | .team ' teams.json) ; do 
        # Filter out termination states
        status=$(jq -r 'select(.spec.name == "'$team_name'") | select(.status.state != "FAILED" and .status.state != "INTERRUPTED" and .status.state != "DONE" and .status.state != "ERROR" ) | .status.state' <(echo "$running") )

        if [ -z "$status" ]; then
            status=$(ovhai job run --name "$team_name" --gpu 1 --label "kili_challenge_team=$team_name" -o json -v "kili_$team_name@GRA:/workspace:RWD" $@ | jq -r '.status.state')
            echo "$team_name: I just relaunched the job : $status"
        else
            echo "$team_name" : "$status"
        fi

    done
) 

