#!/bin/bash
printf "\nSpecify one two or three args $1 $2 $3 for all_measurements.sh <duration seconds> <cluster url of appinst> <delay seconds for jmeter to start> example sh all_measurements.sh 50 testappalertcluster.automationdallascloudlet.packet.mobiledgex.net 35 \n\n "
#Clear out nohup.out before test begins set file size to zero
command true > 'nohup.out'
# INFORMATION BREIF
# Just enter number of seconds to run all_measurements.sh <seconds> <cluster path> <delayed start>"
# This is what runs for actve connections ==> command nohup ./jmeterbash.sh jmeterx8086.jmx 900 $1 10 10 8086 $2 $3 & <=== a script to send to background to exit runcommand quickly and pass parameters to jmeterbash.sh on the appinst with a delayed start so diskbash.sh can prep disk files and usage will be in the same timeframe use 25 to 35 second delay to cover all stats cpu,mem,disk,active connections in the same overlaping timeframe to trigger  alerts thresholds"
# This is what runs for jmeter ./jmeterbash.sh <jmx file> <delay ms> <seconds/loops> <users> <ramptime> <http port> <http url> <delaystart>  <=== $1 $2 $3 $4 $5 $6 $7 $8 value info
# If no parameters you will get disk stats cpu mem and network no active connections unless this cluster matches
# This is what runs for diskbash.sh
# Eenter 4 arguments
#
# ddloop= 10  ddbs= 1024k ddcount= 1024 ddsleep= 1
#
#	./diskbash.sh 10 1024k 1024 1   or default values	./diskbash.sh
#
# Size of file to create and for how long to continually write this space
# Output you will see Using script for a 128MB file being created & copied to
# another file for 4 seconds
# Output you will see:
# 	l128+0 records in
# 	128+0 records out
# 	134217728 bytes 	(134 MB, 128 MiB) copied, 0.103346 s, 1.3 GB/s
# The script cleans itslef up and checks that files are removed and logs you run to a file.  look at script for details.
# 	Overwrite  4.0K loadfile1.pig ======> 128M diskloadfile.hog	counter: 4
# 	removed 'diskloadfile.hog'
# 	removed 'loadfile1.pig'
#
#	./diskbash.sh 10 1024k 1024 1
if [ $# -eq 0 ]
then
        command nohup ./diskbash.sh 50 1024k 1024 1 &
sleep 1
        command nohup ./jmeterbash.sh jmeterx8086.jmx 900 50 10 10 8086 testappalertcluster.automationdallascloudlet.packet.mobiledgex.net &
sleep 1
#If one parameter you can change the duration of the test in seconds to run disk cpu mem and network active connetions only if this cluster mataches
elif [ $# -eq 1 ]
then
        command nohup ./diskbash.sh $1 1024k 1024 1 &
sleep 1
        command nohup ./jmeterbash.sh jmeterx8086.jmx 900 $1 10 10 8086 testappalertcluster.automationdallascloudlet.packet.mobiledgex.net &
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
