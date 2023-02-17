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

source lib.sh

jq -r -n --argfile jobs <( ovhai job list  -o json )  --argfile tokens <( ovhai token list  -o json ) 'include "lib"; teams_to_start_or_restart($jobs;$tokens)' | xargs -S 10000 -n 1 -L 1 -I {} bash -c "echo run {} ; ovhai job run --name "{}" --gpu 1 --label 'kili_challenge_team={}' -o json -v "kili_{}@GRA:/backup:RO:cache"  -v "kili_fixed_{}@${REGION}:/workspace:RWD:cache" $IMAGE > /dev/null"
