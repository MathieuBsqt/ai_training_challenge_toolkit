#!/bin/bash
set -eu
set -o pipefail

if [ $# -ne 0 ]; then
    echo "You should not pass any argument"
    exit 1
fi

jq -n --argfile jobs <( ovhai job list  -o json )  --argfile tokens <( ovhai token list  -o json ) 'include "lib"; list_jobs($jobs;$tokens)'