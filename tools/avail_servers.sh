#!/bin/bash

FILES="
/Users/andyanderson/go/src/github.com/mobiledgex/edge-cloud-qa/testcases/config/openrc_beacon.mex
/Users/andyanderson/go/src/github.com/mobiledgex/edge-cloud-qa/testcases/config/openrc_buckhorn.mex
/Users/andyanderson/go/src/github.com/mobiledgex/edge-cloud-qa/testcases/config/openrc_paradise.mex
/Users/andyanderson/go/src/github.com/mobiledgex/edge-cloud-qa/testcases/config/openrc_fairview.mex
/Users/andyanderson/go/src/github.com/mobiledgex/edge-cloud-qa/testcases/config/openrc_hawkins.mex
/Users/andyanderson/go/src/github.com/mobiledgex/edge-cloud-qa/testcases/config/openrc_sunnydale.mex
"
#FILES="/Users/andyanderson/go/src/github.com/mobiledgex/edge-cloud-qa/testcases/config/openrc_*.mex"

for f in $FILES
do
   source $f
   rc="${f##*/}"
   openstack limits show --absolute | awk -F'|' '/maxTotalCores/ {total=$3} /totalCoresUsed/ {used=$3} END {printf("%s avail cores=%d\n", rc, total-used)}' rc=$rc
done
