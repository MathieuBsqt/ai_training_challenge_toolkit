#!/bin/bash
set -eu
set -o pipefail

ovhai token list -o json | jq -r  'include "lib"; select_only_team_tokens | .spec.name '