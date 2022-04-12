#!/usr/bin/python3
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


import sys
import os
import logging
import json
import time
import zapi
import jiraapi

import subprocess
import argparse

username = 'andy.anderson@mobiledgex.com'
access_key = 'MDAzZTcyMTMtNGY3ZS0zMmMwLWIxZDAtYjZlM2Y1MTljNmNlIGFuZHkuYW5kZXJzb24gYW5keS5hbmRlcnNvbg';
secret_key = 'PckHXrGmx7pHzt-_-uAEBAK7fGP3dk3rI5BbVQLb5oU'

jira_token = 'Qoi6yaqSNTvjdyJAhgNz1AE4'

def main():

    #version = os.environ['version']
    #project = os.environ['project']
    #new_cycle = os.environ['cycle']

    parser = argparse.ArgumentParser(description='update cycle')
    parser.add_argument('--project', default='ECQ')
    parser.add_argument('--version', default= 'Stratus')
    parser.add_argument('--cycle')
    parser.add_argument('--tcid')
    parser.add_argument('--status')

    args = parser.parse_args()
    project = args.project
    new_cycle = args.cycle
    tcid = args.tcid
    version = args.version
    status = args.status

    if status and (not new_cycle or not tcid):
        print(parser.print_help())
        sys.exit()

    if not (status and not new_cycle and not tcid):
        print(parser.print_help())
        sys.exit()

    
    logging.basicConfig(
        level=logging.DEBUG,
        format = "%(asctime)s - %(filename)s %(funcName)s() line %(lineno)d - %(levelname)s -  - %(message)s")
    logging.getLogger('urllib3').setLevel(logging.ERROR)
    logging.getLogger('zapi').setLevel(logging.DEBUG)

    z = zapi.Zapi(username=username, access_key=access_key, secret_key=secret_key, debug=False)
    j = jiraapi.Jiraapi(username=username, token=jira_token)

    project_info = j.get_project(project)
    content = json.loads(project_info)
    project_id = content['id']
    version_id = None
    status_var = None

    
    jiraQueryUrl = f'key={tcid}'
    result = j.search(query=jiraQueryUrl)
    query_content = json.loads(result)
    issue_id = query_content['issues'][0]['id']

    if status:
        
        for v in content['versions']:
            if v['name'] == version:
                version_id = v['id']
                # print('project_id=', project_id)
                # version_id = z.get_version_id(project_id, version)

        cycle_id = z.get_cycle_id(name=new_cycle, project_id=project_id, version_id=version_id)
        logging.info("project_id=%s version_id=%s cycle_id=%s" % (project_id, version_id, cycle_id))

        if status.lower() =='pass':
            status_var = 1
        elif status.lower() =='fail':
            status_var = 2
        elif status.lower() =='wip':
            status_var = 3

        status_create = z.create_execution(issue_id=issue_id, project_id=project_id, cycle_id=cycle_id, version_id=version_id, status=status_var)
        query_content = json.loads(status_create)
        exec_id = query_content['execution']['id']
   # print('exec_id', exec_id)

        z.update_status(execution_id=exec_id, issue_id=issue_id, project_id=project_id, cycle_id=cycle_id, version_id=version_id, status=status_var)
        print('TCID changed to', status)

    sresult = z.get_teststeps(issue_id,project_id)
    sresult_content = json.loads(sresult)
    step = sresult_content[0]['step']
    if "robot" in step:
        filename,title = step.split('\n')
        print('File Name=', filename, 'Title=',title)
    else:
        print("testcase =", step)
        
if __name__ == '__main__':
    main()
