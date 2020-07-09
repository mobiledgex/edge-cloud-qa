#!/bin/bash

FILES="
/Users/andyanderson/go/src/github.com/mobiledgex/edge-cloud-qa/testcases/config/openrc_berlin.mex
/Users/andyanderson/go/src/github.com/mobiledgex/edge-cloud-qa/testcases/config/openrc_bonn.mex
/Users/andyanderson/go/src/github.com/mobiledgex/edge-cloud-qa/testcases/config/openrc_dusseldorf.mex
/Users/andyanderson/go/src/github.com/mobiledgex/edge-cloud-qa/testcases/config/openrc_frankfurt.mex
/Users/andyanderson/go/src/github.com/mobiledgex/edge-cloud-qa/testcases/config/openrc_hamburg.mex
/Users/andyanderson/go/src/github.com/mobiledgex/edge-cloud-qa/testcases/config/openrc_munich.mex
"
#FILES="/Users/andyanderson/go/src/github.com/mobiledgex/edge-cloud-qa/testcases/config/openrc_*.mex"

for f in $FILES
do
   source $f
   rc="${f##*/}"
   openstack limits show --absolute | awk -F'|' '/maxTotalCores/ {total=$3} /totalCoresUsed/ {used=$3} END {printf("%s avail cores=%d\n", rc, total-used)}' rc=$rc
done
