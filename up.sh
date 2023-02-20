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


IFS=$'\n'
for i in $(jq -r -n --argfile jobs <( ovhai job list  -o json )  --argfile tokens <( ovhai token list  -o json ) 'include "lib"; teams_to_start_or_restart($jobs;$tokens)')
do 
    echo "run $i"
    ovhai job run --name $i --gpu 1 --label kili_challenge_team=$i -o json -v kili_$i@GRA:/backup:RO:cache -v kili_fixed_$i@${REGION}:/workspace:RWD:cache $IMAGE > /dev/null
done


