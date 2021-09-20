#!/bin/bash
command stty rows 50 cols 132
echo $normal;clear
i=1
hog="diskloadfile.hog"
pig="loadfile1.pig"
ddloop="10"
ddbs="1024k"
ddcount="1024"
ddsleep="1"
pighoglog="diskpighog.log"
blue=$(tput setaf 4)
yellow=$(tput setaf 3)
red=$(tput setaf 1)
green=$(tput setaf 2)
normal=$(tput sgr0)
echo $normal
if [ $# -eq 0 ]
then
printf "No arguments so using defaults ./diskbash.sh $normal $green 10 1024k 1024 1 $normal\n";echo
command  dd if=/dev/zero of=$hog bs=$ddbs count=$ddcount &
PID=$!
i=1
sp="::..::..::..::..::.."
#echo -n ' '
while [ -d /proc/$PID ]
do
printf "\r\tCreating file\t:\b${sp:i++%${#sp}:10}\t\t:$hog\t\t:\b${sp:i++%${#sp}:10}"
done
echo
i=1
while [ "10" -ge "$i" ]; do
	printf cp $hog > $pig
        sleep 1
showhog="$(ls -sh $hog)"
showpig="$(ls -sh $pig)"
printf "\rOverwrite $green $showpig $normal \t$i =======> $normal  $green $showhog $red $i $normal \tcounter: $yellow $i $normal"
        i=$(($i + 1))
done
echo $yellow
today=$(date +"%Y-%m-%d_%R_%r_%s")
printf "Overwrite file $ddloop times \tsleep $ddsleep secs \tcopy $showpig \t=======>,\
	$showhog \tbs= $ddbs \tcount= $ddcount \tlook in $pighoglog \t'%s'\n" "diskpighog-${today}.log" >> /$pighoglog
if [[ $hog != "" && -f $hog ]]; then
   # Print remove message
   rm -v $hog
else
   printf "$normal $red Filename not found or file does not existi $normal"
fi
if [[ $pig != "" && -f $pig ]]; then
   # Print remove message
   rm -v $pig
echo $normal
else
   echo "$normal $red Filename not found or file does not exist $normal"
fi
elif [ $# -eq 4 ]
then
printf "$normal Using script with ddloop=$1 ddbs=$2 ddcount=$3 ddsleep=$4\n";echo
command  dd if=/dev/zero of=$hog bs=$2 count=$3 &
PID=$!
i=1
sp="::..::..::..::..::.."
echo -n ' '
while [ -d /proc/$PID ]
do
printf "\r\tCreating file\t:\b${sp:i++%${#sp}:10}\t\t:$hog\t\t:\b${sp:i++%${#sp}:10}\tcommand:$PID"
done
echo
i=1
while [ "$1" -ge "$i" ]; do
        printf cp $hog > $pig
        sleep $4
showhog="$(ls -sh $hog)"
showpig="$(ls -sh $pig)"
printf "\rOverwrite $green $showpig $normal \t$i ======> $green $showhog $normal $red $i \tcounter: $yellow $i $normal"
        i=$(($i + 1))
done
echo $yellow
today=$(date +"%Y-%m-%d_%R_%r_%s")
printf "Overwrite file $1 times \tsleep $4 secs \tcopy $showpig \t=======>,\
	$showhog \tbs= $2 \tcount= $3 \tlook in $pighoglog \t'%s'\n" "diskpighog-${today}.log" >> /$pighoglog
if [[ $hog != "" && -f $hog ]]; then
   # Print remove message
   rm -v $hog
else
   printf "$normal $red Filename not found or file does not existi $normal"
fi
if [[ $pig != "" && -f $pig ]]; then
   # Print remove message
   rm -v $pig
echo $normal
else
   echo "$normal $red Filename not found or file does not exist $normal"
echo $normal
fi
   exit;
elif [ $# -lt 4 ]
then
command stty rows 50 cols 132
printf "$normal Eenter 4 arguments $normal\n";echo
printf "$green ddloop=$normal 10 $green ddbs=$normal 1024k$green ddcount=$normal 1024$greent ddsleep=$normal 1$normal\n";echo
printf "$normal\t./diskbash.sh$green 10 1024k 1024 1$normal $yellow  or default values$normal\t./diskbash.sh$normali\n";echo
printf "$yellow Size of file to create and for how long to continually write this space $normal\n"
printf "$yellow Output you will see Using script for a 128MB file being created & copied to\n"
printf "$Yellow another file for 4 seconds$normal\n";echo
printf "$normal \tl128+0 records in$normal\n"
printf "$normal \t128+0 records out$normal\n"
printf "$normal \t134217728 bytes \t(134 MB, 128 MiB) copied, 0.103346 s, 1.3 GB/s$normal\n";echo
printf "$normal \tOverwrite  4.0K loadfile1.pig$green ======>$normal 128M diskloadfile.hog\tcounter:$yellow 4$normal\n"
printf "$normal \tremoved 'diskloadfile.hog'$normal\n"
printf "$normal \tremoved 'loadfile1.pig'$normal\n";echo
printf "\t$green./diskbash.sh$green 10 1024k 1024 1$normal\n"
echo $normal
exit;
elif [ $# -gt 4 ]
then
command stty rows 50 cols 132
printf "$normal Eenter 4 arguments $normal\n";echo
printf "$green ddloop=$normal 10 $green ddbs=$normal 1024k$green ddcount=$normal 1024$greent ddsleep=$normal 1$normal\n";echo
printf "$normal\t./diskbash.sh$green 10 1024k 1024 1$normal $yellow  or default values$normal\t./diskbash.sh$normali\n";echo
printf "$yellow Size of file to create and for how long to continually write this space $normal\n"
printf "$yellow Output you will see Using script for a 128MB file being created & copied to\n"
printf "$Yellow another file for 4 seconds$normal\n";echo
printf "$normal \tl128+0 records in$normal\n"
printf "$normal \t128+0 records out$normal\n"
printf "$normal \t134217728 bytes \t(134 MB, 128 MiB) copied, 0.103346 s, 1.3 GB/s$normal\n";echo
printf "$normal \tOverwrite  4.0K loadfile1.pig$green ======>$normal 128M diskloadfile.hog\tcounter:$yellow 4$normal\n"
printf "$normal \tremoved 'diskloadfile.hog'$normal\n"
printf "$normal \tremoved 'loadfile1.pig'$normal\n";echo
printf "\t$green./diskbash.sh$green 10 1024k 1024 1$normal\n"
echo $normal
exit;
echo $normal
command stty rows 50 cols 132
fi
