#!/bin/bash

for dir in $JENKINS_HOME/users/*/
do
   echo ${dir}
   realdir=${dir::-1}
   echo ${realdir}
   realdir=${realdir##*/}
   echo ${realdir}
done

#for dir in $JENKINS_HOME/jobs/*
#do
#    realdir=${dir##*/}
#    echo mkdir jobs/${realdir} cp $JENKINS_HOME/jobs/${realdir}/*.xml jobs/${realdir}
#    mkdir -p jobs/"${realdir}" && cp $JENKINS_HOME/jobs/"${realdir}"/*.xml jobs/"${realdir}"
#done

