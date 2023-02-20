#!/bin/bash
set -eu
set -o pipefail

# returns an error if there is not one and only one argument
if [ $# -lt 1 ]; then
    echo "Usage: $0 <IMAGE> [<ARGS>]"
    echo "IMAGE: docker image to run"
    echo "ARGS: additionnal args to pass to the 'ovhai job run' command, like --gpu, --cpu, or anything you like"
    exit 1
fi

IMAGE=$1
shift

source lib.sh


IFS=$'\n'
for i in $(jq -r -n --argfile jobs <( ovhai job list  -o json )  --argfile tokens <( ovhai token list  -o json ) 'include "lib"; teams_to_start_or_restart($jobs;$tokens)')
do 
    echo "run $i"
    ovhai job run --name $i --label ai_challenge_team=$i -v ai_volume_$i@${REGION}/workspace.tar:/workspace:RWD:cache $IMAGE > /dev/null
done


