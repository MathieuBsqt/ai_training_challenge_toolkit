#!/bin/bash
set -eu
set -o pipefail

# returns an error if there is not one and only one argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <IMAGE>"
    echo "IMAGE: docker image to run"
    exit 1
fi

IMAGE=$1

jq -r -n --slurpfile jobs <( ovhai job list  -o json )  --slurpfile tokens <( ovhai token list  -o json ) 'include "lib"; teams_to_start_or_restart($jobs;$tokens)' | xargs -n 1 -L 1 -I {} bash -c "echo run {} ;  ovhai job run --name "{}" --gpu 1 --label 'kili_challenge_team={}' -o json -v "kili_{}@GRA:/workspace:RWD:cache" $IMAGE > /dev/null"