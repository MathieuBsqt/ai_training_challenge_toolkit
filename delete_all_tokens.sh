#!/bin/bash
ovhai token list -o json  | jq -r ".id" | xargs -L1 -I{} ovhai token delete {}
echo "" > teams.json
