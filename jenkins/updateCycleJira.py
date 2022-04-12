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
accountid = '***REMOVED***'
#access_key = '***REMOVED***'
#secret_key = '***REMOVED***'

#systemkey
#access_key = '***REMOVED***';
#secret_key = '***REMOVED***'
#access_key = '***REMOVED***';
access_key = '***REMOVED***'
secret_key = '***REMOVED***'

jira_token = '***REMOVED***'

def main():
    #version = os.environ['version']
    #project = os.environ['project']
    #new_cycle = os.environ['cycle']

    parser = argparse.ArgumentParser(description='update cycle')
    #parser.add_argument('--version_from_load', action='store_true')
    parser.add_argument('--version')
    parser.add_argument('--project')
    parser.add_argument('--cycle')
    parser.add_argument('--startdate', action='store_true')
    parser.add_argument('--enddate', action='store_true')
    parser.add_argument('--build')
    args = parser.parse_args()

    version = args.version
    project = args.project
    new_cycle = args.cycle
    #start_date = args.startdate
    #end_date = args.end_date
    build = args.build
    
    logging.basicConfig(
        level=logging.DEBUG,
        format = "%(asctime)s - %(filename)s %(funcName)s() line %(lineno)d - %(levelname)s -  - %(message)s")
    logging.getLogger('urllib3').setLevel(logging.ERROR)
    logging.getLogger('zapi').setLevel(logging.DEBUG)

    #z = zapi.Zapi(username=username, access_key=access_key, secret_key=secret_key, debug=True)
    z = zapi.Zapi(username=accountid, access_key=access_key, secret_key=secret_key, debug=True)
    j = jiraapi.Jiraapi(username=username, token=jira_token)

    project_info = j.get_project(project)
    content = json.loads(project_info)
    project_id = content['id']
    version_id = None
    for v in content['versions']:
        if v['name'] == version:
            version_id = v['id']
    print('p', project_id)
    #version_id = z.get_version_id(project_id, version)

    cycle_id = z.get_cycle_id(name=new_cycle, project_id=project_id, version_id=version_id)
    logging.info("project_id=%s version_id=%s cycle_id=%s" % (project_id, version_id, cycle_id))

    if cycle_id:
        start_date = None
        end_date = None
        if args.startdate:
            start_date = time.strftime('%Y-%m-%d', time.gmtime())
            z.update_cycle(name=new_cycle, project_id=project_id, version_id=version_id, cycle_id=cycle_id, build=new_cycle, start_date=start_date)
        if args.enddate:
            end_date = time.strftime('%Y-%m-%d', time.gmtime())
            z.update_cycle(name=new_cycle, project_id=project_id, version_id=version_id, cycle_id=cycle_id, build=new_cycle, start_date=end_date, end_date=end_date)
    else:
        logging.error('cycle_id NOT found')
        
if __name__ == '__main__':
    main()
