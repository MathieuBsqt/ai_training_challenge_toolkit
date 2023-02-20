#!/bin/bash

ovhai job list -o json | jq '.[] | select( .status.state == "RUNNING") | .id ' | xargs -L1 ovhai job stop
