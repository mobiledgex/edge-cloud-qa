#!/bin/bash
# Copyright 2022 MobiledgeX, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


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
