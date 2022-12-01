#!/bin/bash
set -eu
set -o pipefail

ovhai token list -o json | jq -r  '.spec.name '