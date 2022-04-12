#!/usr/local/bin/python3
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


import os
import sys
import argparse
import logging
import subprocess
import time
import re

def main():
    parser = argparse.ArgumentParser(description='clean openstack subnets')
    parser.add_argument('--serverSubstring', required=False, help='substring to match server name, such as automationhawkinscloudlet')
    parser.add_argument('--stackSubstring', required=False, help='substring to match server name, such as automationhawkinscloudlet')

    args = parser.parse_args()

    if args.serverSubstring:
        server_list = get_server_list(args.serverSubstring)
        print(server_list)
        delete_server(server_list)

#    time.sleep(120)   # wait for router delete to be done ?

    if args.stackSubstring:
        stack_list = get_stack_list(args.stackSubstring)
        delete_stack(stack_list)

def delete_server(server_list):
    for server in server_list:
        cmd = f'openstack server delete {server}'
        print(cmd)
        try:
            r = subprocess.run(cmd, shell=True, capture_output=True, encoding='utf8', check=True)
        except subprocess.CalledProcessError as err:
            logging.info("   exec cmd failed. return code=: " + str(err.returncode))
            logging.info("   exec cmd failed. stdout=: " + str(err.stdout))
            logging.info("   exec cmd failed. stderr=: " + str(err.stderr))
    
def delete_stack(server_list):
    for server in server_list:
        cmd = f'openstack stack delete -y {server}'
        print(cmd)
        try:
            r = subprocess.run(cmd, shell=True, capture_output=True, encoding='utf8', check=True)
        except subprocess.CalledProcessError as err:
            logging.info("   exec cmd failed. return code=: " + str(err.returncode))
            logging.info("   exec cmd failed. stdout=: " + str(err.stdout))
            logging.info("   exec cmd failed. stderr=: " + str(err.stderr))

def get_server_list(substring):
    cmd = 'openstack server list'

    regex =re.compile(substring)
    #print(regex)
    subnetid_list = []
    
    r = subprocess.run(cmd, shell=True, capture_output=True, encoding='utf8', check=True)

    stdout = r.stdout.split('\n')

    #print('stdout', stdout)
    print('substring', substring)
    for line in stdout:
        #print('line',line)
        if re.search(regex, line):
            #print(line)
            subnetid = line.split('|')[2]
            subnetid_list.append(subnetid)

    #print(subnetid_list)

    return subnetid_list

def get_stack_list(substring):
    cmd = 'openstack stack list'

    regex =re.compile(substring)
    #print(regex)
    subnetid_list = []
    
    r = subprocess.run(cmd, shell=True, capture_output=True, encoding='utf8', check=True)

    stdout = r.stdout.split('\n')

    #print('stdout', stdout)
    print('substring', substring)
    for line in stdout:
        #print('line',line)
        if re.search(regex, line):
            #print(line)
            subnetid = line.split('|')[2]
            subnetid_list.append(subnetid)

    #print(subnetid_list)

    return subnetid_list

    

if __name__ == '__main__':
    main()
