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

import logging
import subprocess
import time
import sys
import os


class MexKnife:
    def __init__(self, policy_group='qa'):
        self.policy_group = policy_group
        

    def upgrade_cloudlet(self, cloudlet_names=None, container_version=None):
        for i in cloudlet_names:
            logging.info('cloudlet name is ' + i)
        self._before_upgrade(cloudlet_names)
        self._start_upgrade()
        self._verify_upgrade(cloudlet_names,container_version)

    def get_node_status(self, node):
        #cmd_knife = f'knife node run-list status {node} | grep Status | awk ' + "'{{print $2}}'"
        cmd_knife = f'knife node run-list status {node}'
        logging.debug(f'getting node status with cmd={cmd_knife}')
        output = self._run_cmd(cmd_knife).split('\n')
        logging.debug(f'output={output}')
        success_line = output[0].split()
        return success_line[1]
        #return output.rstrip()

    def node_status_should_be_success(self, node):
        try:
            for i in range(60):
                status = self.get_node_status(node)
                if status == 'success':
                    logging.info('node status is success')
                    return status
                else:
                    time.sleep(10)
            raise Exception(status)
        except Exception as err:
            raise Exception(f'node status is not success:{err}') 

    def node_status_should_not_exist(self, node):
        try:
            status = self.get_node_status(node)
            raise Exception(f'node status exists with {status}')
        except Exception as err:
            logging.debug(f'err:{err}')
            if 'ERROR: The object you are looking for could not be found' in str(err):
                logging.info('node not found')
                return err
            else:
                raise Exception(f'node status returned:{err}')

    def _before_upgrade(self, cloudlets):
        cmd_knife = 'knife exec -E \'nodes.find("name:qa*pf") {|n| puts n.name+"="+n["edgeCloudVersion"]}\''
        output = self._run_cmd(cmd_knife)
        crm_list = output.splitlines()
        for line in crm_list:
            logging.info(str(line))

 
    def _start_upgrade(self):
        policy_group = self.policy_group
        workdir = "/home/jenkins/workspace/runRegression"
        if not os.path.exists(workdir):
            workdir = os.environ.get("HOME")
        chef_dir = os.path.join(workdir, 'go/src/github.com/mobiledgex/edge-cloud-infra/chef/policyfiles')
        os.chdir(chef_dir)
        retval = os.getcwd() 
        logging.info('Current directory is ' + str(retval))
        cmdchef = f'chef push {policy_group} docker_crm.rb'
        output = self._run_cmd(cmdchef)
        list1 = output.splitlines()
        for line in list1:
            if 'Failed to upload policy' in line:
                logging.error(line)
                raise Exception('ERROR: line')  


    def _run_cmd(self, command):
        logging.info(f'running cmd: {command}')
        cmd_return = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
        cmd_out = cmd_return.stdout.decode('utf-8')
        cmd_err = cmd_return.stderr.decode('utf-8')
        if cmd_err:
            raise Exception(cmd_err)
        return cmd_out


    def _verify_upgrade(self, cloudlets, version):
        logging.info('version to be upgraded to is ' + str(version))

        cloudlet_list = []
        x = 0
        while((x < 30) and (len(cloudlet_list) < 4)): 
            cmd_knife = 'knife exec -E \'nodes.find("name:qa*pf") {|n| puts n.name+"="+n["edgeCloudVersion"]}\''
            output = self._run_cmd(cmd_knife)
            crm_list = output.splitlines()
            logging.debug(output)           

            for i in cloudlets:
                for line in crm_list:
                    if i in line and version in line:
                        logging.info(i + ' has been upgraded to ' + version)
                        cloudlet_list.append(i)                    
            time.sleep(30)
            x+=1

        length = len(cloudlet_list)            
        logging.info('Length of cloudlet_list is ' + str(length))

        if not cloudlet_list:
            raise Exception('ERROR: None of the cloudlets got upgraded to ' + version)
        
        elif(len(cloudlet_list) < 4): 
            for j in cloudlets:
               for names in cloudlet_list:
                   if j not in names:
                       logging.error(j + ' failed to upgrade to ' + version)           
            raise Exception('ERROR: Not all the cloudlets not upgraded to ' + version) 

        else:
             logging.info('All the cloudlets got upgraded to ' + version)


    
