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
import os

logging.basicConfig(format='%(asctime)s %(levelname)s %(funcName)s line:%(lineno)d - %(message)s',datefmt='%d-%b-%y %H:%M:%S')
logger = logging.getLogger(__name__)

class MexArtifactory():

    def __init__(self):
        # self.username = 'mexadmin'
        # self.password = 'mexadmin123'
        # self.image = 
        pass

    def curl_image_to_artifactory(self, username, password, server, org_name, image_name):
        cmd = f'curl -u{username}:{password} -T {image_name} "https://{server}/{org_name}/{os.path.basename(image_name)}" --fail -v'

        logger.info(cmd)
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
        
        if process.returncode != 0 or f'"createdBy": "{username}"' not in stdout[4].decode('utf-8'):
            raise Exception(f'artifactory curl failed:  {stderr} {stdout}')

        return stdout
