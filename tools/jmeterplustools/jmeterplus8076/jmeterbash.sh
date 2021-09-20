#!/bin/bash
#command stty rows 40 cols 100
echo $normal;clear
i=1
jmjmxfile="/jmeterx8076.jmx"
jmeterlog="/jmeterlog.log"
Jdelay="-Jdelay=900"
Jloops="-Jloops=35"
Jusers="-Jusers=10"
Jramptime="-Jramptime=10"
Jport="-Jport=8076"
Jdomain="-Jdomain=clusterdallask8s.automationdallascloudlet.packet.mobiledgex.net"
blue=$(tput setaf 4)
yellow=$(tput setaf 3)
red=$(tput setaf 1)
green=$(tput setaf 2)
normal=$(tput sgr0)
echo $normal
if [ $# -eq 0 ]
then
printf "$normal No args entered Using defaults. Next time customize and enter 7 arguments\n"
echo
printf "This script designed to work with a k8s cluster named $Jdomain \n"
printf "However you can still use this script on any cluster if you use the app jmeterk8sapp8076 just change the Jdomain as the port will be the same\n"
printf "$normal Eenter 7 args $green filename.jmx -Jdelay -Jloops -Jusers -Jramptime -Jport -Jdomain$normal\n"
echo
printf "$normal\t./jmeterbash.sh \$1 \$2 \$3 \$4 \$5 \$6 \$7 <===== customize the 7 arguments as follows\n"
printf "$normal\t./jmeterbash.sh jmeterx8076.jmx 900 35 5 5 8076 clusterdallask8s.automationdallascloudlet.packet.mobiledgex.net  <=== bash values only\n"
printf "$normal\t./jmeterbash.sh <jmx file> <delay ms> <seconds/loops> <users> <ramptime> <http port> <http url>  <=== \$1 \$2 \$3 \$4 \$5 \$6 \$7 value info\n"
printf "$green \tjmeter -n -t  $jmjmxfile $Jdelay $Jloops $Jusers $Jramptime $Jport $Jdomain $normal  <==== this is jmeter with the J vars\n"
echo
printf "$yellow This bash file is using jmeter with input args with a modified jmx file to make sending mcctl commands$normal\n"
printf "$yellow easier or run predefined tests that can have some tweeks on the fly using -J substitute variables setup in jmx file. $normal\n"
echo
printf "$green The bash file lets you send the values and logs the values and time you ran it\n"
printf "$green \tjmeter -n -t  $jmjmxfile $Jdelay $Jloops $Jusers $Jramptime $Jport $Jdomain $normal  <==== jmeter with the -J vars\n"
printf "$normal\t./jmeterbash.sh jmeterx8076.jmx 900 35 5 5 8076 clusterdallask8s.automationdallascloudlet.packet.mobiledgex.net  <=== bash values only\n"
echo $normal
echo
sleep 1
command jmeter \-\n \-\t $jmjmxfile $Jdelay $Jloops $Jusers $Jramptime $jport $Jdomain &
PID=$!
i=1
sp="::..::..::..::..::.."
#echo -n ' '
while [ -d /proc/$PID ]
do
printf "\r$yellow $Jusers $Jloops $normal Jmetering \b${sp:i++%${#sp}:3}\t:"
done
today=$(date +"%Y-%m-%d_%R_%r_%s")
printf "Run Info \t$jmjmxfile\t$Jdelay\t$Jloops\t$Jusers\t$Jramptime\t$Jport\t$Jdomain'%s'\n" "$jmeterlog-${today}.log" >> $jmeterlog
printf "Run Info \t$jmjmxfile\t$Jdelay\t$Jloops\t$Jusers\t$Jramptime\t$Jport\t$Jdomain\tLog$jmeterlog-${today}.log"
echo
elif [ $# -eq 7 ]
then
echo "Using 7 entered args\n"
printf "\t./jmeterbash $1 -Jdelay=$2 -Jloops=$3 -Jusers=$4 -Jramptime=$5 -Jport=$6 -Jdomain=$7\n"
echo $normal
printf "$normal\t./jmeterbash.sh \$1 \$2 \$3 \$4 \$5 \$6 \$7 <===== customize the 7 arguments as follows\n"
printf "$normal\t./jmeterbash.sh jmeterx8076.jmx 900 35 5 5 8076 clusterdallask8s.automationdallascloudlet.packet.mobiledgex.net <=== bash values only\n"
printf "$normal\t./jmeterbash.sh jmeterx8076.jmx 900 35 5 5 8076 somecluster.somecloudlet.packet.mobiledgex.net                  <=== change cluster and dedicatedLB \n"
printf "$normal\t./jmeterbash.sh <jmx file> <delay ms> <seconds/loops> <users> <ramptime> <http port> <http url>  <=== \$1 \$2 \$3 \$4 \$5 \$6 \$7 value info\n"
printf "$green \tjmeter -n -t  $jmjmxfile $Jdelay $Jloops $Jusers $Jramptime $Jport $Jdomain $normal  <==== this is jmeter with the J vars\n"
echo
printf "$yellow This bash file is using jmeter with input args with a modified jmx file to make sending mcctl commands$normal\n"
printf "$yellow easier or run predefined tests that can have some tweeks on the fly using -J substitute variables setup in jmx file. $normal\n"
echo
printf "$green The bash file lets you send the values and logs the values and time you ran it\n"
printf "$green \tjmeter -n -t  $jmjmxfile $Jdelay $Jloops $Jusers $Jramptime $Jport $Jdomain $normal  <==== jmeter with the -J vars\n"
printf "$normal\t./jmeterbash.sh jmeterx8076.jmx 900 35 5 5 8076 clusterdallask8s.automationdallascloudlet.packet.mobiledgex.net  <=== bash values only\n"
echo $normali
sleep 1
command  jmeter \-\n \-\t $1 -Jdelay=$2 -Jloops=$3 -Jusers=$4 -Jramptime=$5 -Jport=$6 -Jdomain=$7 &
PID=$!
i=1
sp="::..::..::..::..::.."
echo -n ' '
while [ -d /proc/$PID ]
do
printf "\r$yellow $Jusers $Jloops $normal Jmetering \b${sp:i++%${#sp}:3}\t:"
done
echo
today=$(date +"%Y-%m-%d_%R_%r_%s")
printf "\nRun Info \tjmxfile:$1\tJdelay:$2\tJloops:$3\tJusers:$4\tJramptime:$5\tJport:$6\tJdomain:$7'%s'\n" "$jmeterlog-${today}.log" >> $jmeterlog
printf "\nRun Info \tjmxfile:$1\tJdelay:$2\tJloops:$3\tJusers:$4\tJramptime:$5\tJport:$6\tJdomain:$7\tLog$jmeterlog-${today}.log"
echo
# command stty rows 40 cols 100
exit;
elif [ $# -eq 6 ]
then
echo "Using 6 entered args and default Jdomain for this app $Jdomain \n"
printf "\t./jmeterbash $1 -Jdelay=$2 -Jloops=$3 -Jusers=$4 -Jramptime=$5 -Jport=$6\n"
echo $normal
printf "$normal\t./jmeterbash.sh \$1 \$2 \$3 \$4 \$5 \$6  <===== customize the 6 arguments as follows\n"
printf "$normal\t./jmeterbash.sh jmeterx8076.jmx 900 35 5 5 8076 <=== bash values only\n"
printf "$normal\t./jmeterbash.sh <jmx file> <delay ms> <seconds/loops> <users> <ramptime> <http port>  <=== \$1 \$2 \$3 \$4 \$5 \$6 value info\n"
printf "$green \tjmeter -n -t  $jmjmxfile $Jdelay $Jloops $Jusers $Jramptime $Jport $normal  <==== this is jmeter with the J vars\n"
echo
printf "$yellow This bash file is using jmeter with input args with a modified jmx file to make sending mcctl commands$normal\n"
printf "$yellow easier or run predefined tests that can have some tweeks on the fly using -J substitute variables setup in jmx file. $normal\n"
echo
printf "$green The bash file lets you send the values and logs the values and time you ran it\n"
printf "$green \tjmeter -n -t  $jmjmxfile $Jdelay $Jloops $Jusers $Jramptime $Jport $normal  <==== jmeter with the -J vars\n"
printf "$normal\t./jmeterbash.sh jmeterx8076.jmx 900 35 5 5 8076   <=== bash values only\n"
echo $normali
sleep 1
command  jmeter \-\n \-\t $1 -Jdelay=$2 -Jloops=$3 -Jusers=$4 -Jramptime=$5 -Jport=$6 -Jdomain=$Jdomain &
PID=$!
i=1
sp="::..::..::..::..::.."
echo -n ' '
while [ -d /proc/$PID ]
do
printf "\r$yellow $Jusers $Jloops $normal Jmetering \b${sp:i++%${#sp}:3}\t:"
done
echo
today=$(date +"%Y-%m-%d_%R_%r_%s")
printf "\nRun Info \tjmxfile:$1\tJdelay:$2\tJloops:$3\tJusers:$4\tJramptime:$5\tJport:$6\t$Jdomain'%s'\n" "$jmeterlog-${today}.log" >> $jmeterlog
printf "\nRun Info \tjmxfile:$1\tJdelay:$2\tJloops:$3\tJusers:$4\tJramptime:$5\tJport:$6\t$Jdomain\tLog$jmeterlog-${today}.log"
echo
# command stty rows 40 cols 100
exit;
elif [ $# -lt 7 ]
printf "Help Info:\n";echo
then
printf "$normal Eenter 7 args $green filename.jmx -Jdelay -Jloops -Jusers -Jramptime -Jport -Jdomain$normal\n"
echo
printf "$normal\t./jmeterbash.sh \$1 \$2 \$3 \$4 \$5 \$6 \$7 <===== customize the 7 arguments as follows\n"
printf "$normal\t./jmeterbash.sh jmeterx8076.jmx 900 35 5 5 8076 clusterdallask8s.automationdallascloudlet.packet.mobiledgex.net  <=== bash values only\n"
printf "$normal\t./jmeterbash.sh <jmx file> <delay ms> <seconds/loops> <users> <ramptime> <http port> <http url>  <=== \$1 \$2 \$3 \$4 \$5 \$6 \$7 value info\n"
printf "$green \tjmeter -n -t  $jmjmxfile $Jdelay $Jloops $Jusers $Jramptime $Jport $Jdomain $normal  <==== this is jmeter with the J vars\n"
echo
printf "$yellow This bash file is using jmeter with input args with a modified jmx file to make sending mcctl commands$normal\n"
printf "$yellow easier or run predefined tests that can have some tweeks on the fly using -J substitute variables setup in jmx file. $normal\n"
echo
printf "$green The bash file lets you send the values and logs the values and time you ran it\n"
printf "$green \tjmeter -n -t  $jmjmxfile $Jdelay $Jloops $Jusers $Jramptime $Jport $Jdomain $normal  <==== jmeter with the -J vars\n"
printf "$normal\t./jmeterbash.sh jmeterx8076.jmx 900 35 5 5 8076 clusterdallask8s.automationdallascloudlet.packet.mobiledgex.net  <=== bash values only\n"
echo $normal
exit;
# command stty rows 40 cols 100
fi
