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

#$1 number of times to run, $2 sleep before test start in seconds, $3 durration of the trigger time and wait to clear, use $2 to tweak resting time if you want a longer wait duration
#$1=loop $2=sleep $3=timeout and sleep --cpu $4 --hdd $5 --vm $6 --io $7 defult stress-ng --cpu 4 --hdd 4 --vm 4 --io 4 --metrics-brief --timeout 35
#while $1; use true and remove for to make run all the time with same timings
if [ $# -eq 0 ]
then
        echo "No arguments supplied using default values of 1 loop 5second pause before 35s runtime 35s wait time"
for var in "1"
  do
        sleep 1
        command stress-ng --cpu 4 --hdd 4 --vm 4 --io 4 --metrics-brief --timeout 35
      for i in {35..1}
        do
                printf "\rDefault wait time to clear alerts in $i seconds"
                sleep 1
      done
done
else
for var in "$1"
  do
        sleep $2
        command stress-ng --cpu $4 --hdd $5 --vm $6 --io $7 --metrics-brief --timeout $3
      for i in {$3..1}
        do
                printf "\rWaiting $3 seconds to clear alerts $i seconds left"
                sleep 1
      done
done
fi
today=$(date +"%Y-%m-%d_%R_%r_%s")
mytoday="+ 7 hour"
printf " Completed $1 loop, $2 sec sleep, test durration $3 secs, sleep before exit $3 sec, --cpu $4, --hdd $5, --vm $6, --io $7, --timeout $3 '%s'\n" "-/bashscripts/runlog-${today}.log" >> /stresrunlog.log
echo "Completed $1 loop, $2 sec sleep, test durration $3 secs, sleep before exit $3 sec, --cpu $4, --hdd $5, --vm $6, --io $7, --timeout $3, look for ${today} local ${mytoday}  /stressrunlog.log"
