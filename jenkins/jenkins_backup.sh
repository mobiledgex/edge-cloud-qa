#!/bin/bash
# used jenkins backup job
pwd
echo $JENKINS_HOME
cd $JENKINS_HOME
cd edge-cloud-qa/jenkins/jenkins_backup
whoami
git config -l

# copy general config
cp $JENKINS_HOME/*.xml .

# copy jobs config
for dir in $JENKINS_HOME/jobs/*
do
    realdir=${dir##*/}
    echo mkdir jobs/${realdir} cp $JENKINS_HOME/jobs/${realdir}/*.xml jobs/${realdir}
    mkdir -p jobs/"${realdir}" && cp $JENKINS_HOME/jobs/"${realdir}"/*.xml jobs/"${realdir}"
done

# copy userContent
mkdir -p userContent && cp $JENKINS_HOME/userContent/* userContent

# copy users config
mkdir -p users && cp $JENKINS_HOME/users/*.xml users
for dir in $JENKINS_HOME/users/*/ 
do
    realdir=${dir::-1}
    realdir=${realdir##*/}
    echo mkdir users/${realdir} cp $JENKINS_HOME/users/${realdir}/*.xml users/${realdir}
    mkdir -p users/"${realdir}" && cp $JENKINS_HOME/users/"${realdir}"/*.xml users/"${realdir}"
done


git status
git add .
git status

# this is from an script I found which was used as an example for the above
# Add general configurations, job configurations, and user content
#git add -- *.xml jobs/*/*.xml userContent/* ansible/*

# only add user configurations if they exist
#if [ -d users ]; then
#    user_configs=`ls users/*/config.xml`

#    if [ -n "$user_configs" ]; then
#        git add $user_configs
#    fi
#fi

# mark as deleted anything that's been, well, deleted
#to_remove=`git status | grep "deleted" | awk '{print $3}'`

#if [ -n "$to_remove" ]; then
#    git rm --ignore-unmatch $to_remove
#fi
#
#
git commit -m "Automated Jenkins commit"
#
git push -q -u origin master
