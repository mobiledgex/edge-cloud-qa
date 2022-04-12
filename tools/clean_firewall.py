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
    #parser.add_argument('--serverSubstring', required=False, help='substring to match server name, such as automationhawkinscloudlet')
    #parser.add_argument('--stackSubstring', required=False, help='substring to match server name, such as automationhawkinscloudlet')

    args = parser.parse_args()

    server_list = get_firewall_list()
    print(server_list)
    delete_rule(server_list)

#    time.sleep(120)   # wait for router delete to be done ?

def delete_rule(server_list):
    for server in server_list:
        cmd = f'openstack security group rule delete {server}'
        print(cmd)
        try:
            r = subprocess.run(cmd, shell=True, capture_output=True, encoding='utf8', check=True)
        except subprocess.CalledProcessError as err:
            logging.info("   exec cmd failed. return code=: " + str(err.returncode))
            logging.info("   exec cmd failed. stdout=: " + str(err.stdout))
            logging.info("   exec cmd failed. stderr=: " + str(err.stderr))
    
def get_firewall_list():
    cmd = 'openstack security group rule list'

#    regex =re.compile(substring)
    #print(regex)
    subnetid_list = []
    
    r = subprocess.run(cmd, shell=True, capture_output=True, encoding='utf8', check=True)

    stdout = r.stdout.split('\n')

    print('stdout', stdout)

    del stdout[0:3]
    del stdout[-1]
    del stdout[-1]

    print('stdout', stdout)
    #print('substring', substring)
    for line in stdout:
        print('line',line)
        subnetid = line.split('|')[1]
        subnetid_list.append(subnetid)

    print(subnetid_list)

    return subnetid_list


if __name__ == '__main__':
    main()
