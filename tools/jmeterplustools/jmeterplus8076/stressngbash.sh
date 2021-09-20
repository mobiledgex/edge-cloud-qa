#!/bin/bash
clear
       echo "./stressngbash.sh 1 1 1 1 1 128M 30 1  values are as follows:"
       echo "There are no checks to the values so be careful - not intended for human consumption"
       echo ""
       echo "./stressngbash.sh <loop count \$1> <loop start sleep \$2> <--cpu \$3> <--hdd \$4> <--vm \$5> <--vm-bytes \$6> <--timeout \$7> <loop exit sleep \$8>"
       echo "./stressngbash.sh loopme    will run for 24 hours the following:  stress-ng --cpu 1 --hdd 0 --vm 0 --io 1 --vm-bytes 128M --metrics-brief --timeout 86400"
       echo ""
loopme="loopme"
if [ $# -eq 0 ]
then
        echo "No arguments supplied using defaults 1 loop with stress-ng --cpu 1 --hdd 1 --vm 0 --io 1 --vm-bytes 128M --metrics-brief --timeout 35 and a exit wait of 35s"
for var in "1"
  do
        sleep 1
        command stress-ng --cpu 1 --hdd 1 --vm 0 --io 1 --vm-bytes 128M --metrics-brief --timeout 35
      for i in {35..1}
        do
                printf "\rDefault wait time to clear alerts in $i seconds"
                sleep 1
      done
done
elif [ $# -eq 8 ]
then
       echo "./stressngbash.sh 1 1 1 1 1 128M 30 1  values are as is as follows:"
       echo "./stressngbash.sh <loop count \$1> <loop start sleep \$2> <--cpu \$3> <--hdd \$4> <--vm \$5> <--vm-bytes \$6> <--timeout \$7> <loop exit sleep \$8>"

	for var in "$1"
  do
        sleep $2
        command stress-ng --cpu $3 --hdd $4 --vm $5 --vm-bytes $6 --metrics-brief --timeout $7
      for i in {10..1}
        do
                printf "\rWaiting $7 seconds to clear alerts $i seconds left but is as long as your timeout"
                sleep $8
      done
done
today=$(date +"%Y-%m-%d_%R_%r_%s")
printf "\tCompleted\tloop:$1 \tdelay:$2\ttimeout:$7\texit_delay:$8\t--cpu $3\t--hdd $4\t--vm $5\t--vm-bytes $6\t--timeout $7\t'%s'\n" "stressnglog-${today}.log" >> /$stressnglog
echo "Completed $1 loop, $2 sec delay, test timeout $7 secs, exit delay $8 sec, --cpu $3, --hdd $4, --vm $5, --vm-bytes $6, --timeout $7, look for stressnglog-${today}  $stressnglog"
exit;
#elif [ $# -eq 1 ]
#then
elif [ $1 = $loopme ]
then
        echo "Run test for 24hours "
for var in "1"
  do
        sleep 1
        command stress-ng --cpu 1 --hdd 0 --vm 0 --io 1 --vm-bytes 128M --metrics-brief --timeout 86400
      for i in {1..1}
        do
                printf "\rDefault wait time to clear alerts in $i seconds"
                sleep 1
      done
done
elif [ $# -lt 100 ]
then
clear
       echo "You did something wrong try again";echo
       echo "!!!!!!!!!! There are no checks to the values so be careful - not intended for human consumption !!!!!!"
       echo ""
       echo "./stressngbash.sh 1 1 1 1 1 128M 30 1  values are as follows:"
       echo "./stressngbash.sh <loop count \$1> <loop start sleep \$2> <--cpu \$3> <--hdd \$4> <--vm \$5> <--vm-bytes \$6> <--timeout \$7> <loop exit sleep \$8>"
       echo
       echo "./stressngbash.sh true    will run for 24 hours the following:  stress-ng --cpu 1 --hdd 0 --vm 0 --io 1 --vm-bytes 128M --metrics-brief --timeout 86400"
       echo ""
exit;
fi
