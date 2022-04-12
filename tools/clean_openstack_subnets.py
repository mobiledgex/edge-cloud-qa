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

def main():
    parser = argparse.ArgumentParser(description='clean openstack subnets')
    parser.add_argument('--subnetSubstring', required=True, help='substring to match subnet name, such as automationhamburgcloudlet')

    args = parser.parse_args()

    subnetid_list = get_subnet_list(args.subnetSubstring)

    delete_router_subnet(subnetid_list)

    time.sleep(120)   # wait for router delete to be done ?
    
    delete_subnet(subnetid_list)

def delete_subnet(subnetid_list):
    for subnet in subnetid_list:
        cmd = f'openstack subnet delete {subnet}'
        print(cmd)
        try:
            r = subprocess.run(cmd, shell=True, capture_output=True, encoding='utf8', check=True)
        except subprocess.CalledProcessError as err:
            logging.info("   exec cmd failed. return code=: " + str(err.returncode))
            logging.info("   exec cmd failed. stdout=: " + str(err.stdout))
            logging.info("   exec cmd failed. stderr=: " + str(err.stderr))
    
def delete_router_subnet(subnetid_list):
    for subnet in subnetid_list:
        cmd = f'openstack router remove subnet mex-k8s-router-1 {subnet}'
        print(cmd)
        try:
            r = subprocess.run(cmd, shell=True, capture_output=True, encoding='utf8', check=True)
        except subprocess.CalledProcessError as err:
            logging.info("   exec cmd failed. return code=: " + str(err.returncode))
            logging.info("   exec cmd failed. stdout=: " + str(err.stdout))
            logging.info("   exec cmd failed. stderr=: " + str(err.stderr))

def get_subnet_list(substring):
    cmd = 'openstack subnet list'

    subnetid_list = []
    
    r = subprocess.run(cmd, shell=True, capture_output=True, encoding='utf8', check=True)

    stdout = r.stdout.split('\n')

    #print('stdout', stdout)

    for line in stdout:
        if substring in line:
            subnetid = line.split()[1]
            subnetid_list.append(subnetid)

    print(subnetid_list)

    return subnetid_list
    
    

if __name__ == '__main__':
    main()
