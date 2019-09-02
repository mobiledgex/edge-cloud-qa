#!/bin/bash

export Cycle=Stratus_automation_2019-09-01
export  Version=Stratus
export  Project=ECQ
export Components=Automated,Controller,Flavor
export WORKSPACE=/home/andy

python3 ./execJira.py 
