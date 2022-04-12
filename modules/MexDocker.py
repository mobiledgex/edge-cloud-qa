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
import shlex


logging.basicConfig(format='%(asctime)s %(levelname)s %(funcName)s line:%(lineno)d - %(message)s',datefmt='%d-%b-%y %H:%M:%S')
logger = logging.getLogger('mex_mastercontroller rest')

class MexDocker():

    def __init__(self):
       # self.username = 'mexadmin'
       # self.password = 'mexadmin123'
       # self.image = 
       pass


    def push_image_to_docker(self, username, password, server, app_name, org_name, app_version, gitlab_app_name=None):
        org_name= org_name.lower()

        if not gitlab_app_name:
            gitlab_app_name = f'{app_name}:{app_version}'
    
        cmd = f'docker login -u {username} -p {password} {server} && docker tag {app_name}:{app_version} {server}/{org_name}/images/{gitlab_app_name} && docker push {server}/{org_name}/images/{gitlab_app_name}'
        #cmd=f'docker tag {app_name} {server}/{org_name}/images/{app_name}:{app_version} && docker push {server}/{org_name}/images/{app_name}:{app_version}'
        
        logging.info(cmd)
        #cmd2 = shlex.split(cmd)
        #print('*WARN*', 'cmd2', cmd2)

        process = subprocess.Popen(cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            shell=True
                )                
        stdout = process.stdout.readlines()
        stderr = process.stderr.readlines()
        process.wait()

        print('*WARN*', 'std', stdout)
        print('*WARN*', 'stderr=' ,stderr)
        print('*WARN*', 'return code=' ,process.returncode)
        
        if process.returncode != 0:
            raise Exception(f'docker push failed:  {stderr} {stdout}')
                
    def pull_image_from_docker(self, username, password, server, app_name, org_name, app_version):
        org_name= org_name.lower()
        cmd = f'docker login -u {username} -p {password} {server} && docker pull {server}/{org_name}/images/{app_name}:{app_version}'
        #cmd=f'docker tag {app_name} {server}/{org_name}/images/{app_name}:{app_version} && docker push {server}/{org_name}/images/{app_name}:{app_version}'
        
        logging.info(cmd)
        #cmd2 = shlex.split(cmd)
        #print('*WARN*', 'cmd2', cmd2)

        process = subprocess.Popen(cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            shell=True
                )                
        stdout = process.stdout.readlines()
        stderr = process.stderr.readlines()
        process.wait()

        print('*WARN*', 'std', stdout)
        print('*WARN*', 'stderr=' ,stderr)
        print('*WARN*', 'return code=' ,process.returncode)
        
        if process.returncode != 0:
            raise Exception(f'docker pull failed:  {stderr} {stdout}')

    def tag_image(self, username, password, server, source_name, app_name=None, target_name=None):
        cmd = f'docker login -u {username} -p {password} {server} && docker tag {source_name}'
        if target_name:
           cmd += f' {target_name}'
        else:
           cmd += f' {app_name}'
        logging.info(cmd)

        process = subprocess.Popen(cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            shell=True
                )
        stdout = process.stdout.readlines()
        stderr = process.stderr.readlines()
        process.wait()

        print('*WARN*', 'std', stdout)
        print('*WARN*', 'stderr=' ,stderr)
        print('*WARN*', 'return code=' ,process.returncode)

        if process.returncode != 0:
            raise Exception(f'docker tag failed:  {stderr} {stdout}')
