#!/bin/bash
printf "\nThis is for runcommand to exit command quickly passing off both scripts in background to create mem cpu disk and active connections measurements stats for 50 seconds. Specify one two or three args $1 $2 $3 \n\n"
#Clear out nohup.out before test begins set file size to zero
command true > 'nohup.out'
printf "\nJust enter number of seconds to run all_measurements.sh <seconds> <cluster path> <delayed start>"
printf " example using runcommand:  mcctl --addr https://console-qa.mobiledgex.net:443 runcommand app-org=automation_dev_org appname=jmeterplus8086 appvers=9.8.6 cloudlet-org=packet cloudlet=automationDallasCloudlet cluster=clusterdallask8s region=US command=\"sh all_measurements.sh 50 clusterdallask8s.automationdallascloudlet.packet.mobiledgex.net 45\""
printf "\ncommand nohup ./jmeterbash.sh jmeterx8086.jmx 900 $1 10 10 8086 $2 $3 & <=== a script to send to background to exit runcommand quickly and pass parameters to jmeterbash.sh on cluster and delayed start is need so diskbash.sh can prep disk files and usage to be in the same timeframe currently 35 to 45 second delay will cover all stats in the same overlaping timeframe to trigger  alerts thresholds"
printf "./jmeterbash.sh <jmx file> <delay ms> <seconds/loops> <users> <ramptime> <http port> <http url> <delaystart>  <=== \$1 \$2 \$3 \$4 \$5 \$6 \$7 \$8 value info\n"
#If no parameters you will get disk stats cpu mem and network no active connections unless this cluster matches
if [ $# -eq 0 ]
then
        command nohup ./diskbash.sh 50 1024k 1024 1 &
sleep 1
        command nohup ./jmeterbash.sh jmeterx8086.jmx 900 50 10 10 8086 clusterdallask8s.automationdallascloudlet.packet.mobiledgex.net &
sleep 1
#If one parameter you can change the duration of the test in seconds to run disk cpu mem and network active connetions only if this cluster mataches
elif [ $# -eq 1 ]
then
        command nohup ./diskbash.sh $1 1024k 1024 1 &
sleep 1
        command nohup ./jmeterbash.sh jmeterx8086.jmx 900 $1 10 10 8086 clusterdallask8s.automationdallascloudlet.packet.mobiledgex.net &
sleep 1
#Two parameters for duration in seconds $1 and the cluster $2 you want to target
elif [ $# -eq 2 ]
then
        command nohup ./jmeterbash.sh jmeterx8086.jmx 900 $1 10 10 8086 $2 &
sleep 1
        command nohup ./diskbash.sh $1 1024k 1024 1 &
sleep 1
#Three parameters to control duration in seconds $1 the cluster $2  and the delay in seconds $3 for active connections to allowd disk utilization to start early to sync all stats
elif [ $# -eq 3 ]
then
        command nohup ./diskbash.sh $1 1024k 1024 1 &
sleep 1
        command nohup ./jmeterbash.sh jmeterx8086.jmx 900 $1 10 10 8086 $2 $3 &
sleep 1
fi
