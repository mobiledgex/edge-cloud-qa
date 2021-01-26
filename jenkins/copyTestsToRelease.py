#!/usr/bin/python3

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
#access_key = 'MDAzZTcyMTMtNGY3ZS0zMmMwLWIxZDAtYjZlM2Y1MTljNmNlIGFuZHkuYW5kZXJzb24gVVNFUl9ERUZBVUxUX05BTUU'
#secret_key = 'S_KlvniknmZ1EPVVJij70fIsm8V7UqrAgxC3MGQqCqA'

#systemkey
#access_key = 'MDAzZTcyMTMtNGY3ZS0zMmMwLWIxZDAtYjZlM2Y1MTljNmNlIGFuZHkuYW5kZXJzb24gYW5keS5hbmRlcnNvbg';
#secret_key = 'PckHXrGmx7pHzt-_-uAEBAK7fGP3dk3rI5BbVQLb5oU'
accountid = '5b85c5f93cee7729fa0660a8'
access_key = 'MDAzZTcyMTMtNGY3ZS0zMmMwLWIxZDAtYjZlM2Y1MTljNmNlIDViODVjNWY5M2NlZTc3MjlmYTA2NjBhOCBVU0VSX0RFRkFVTFRfTkFNRQ'
secret_key = '_1x9j2jdzPGHmpQTs9myoiz76wFTl1f_MC3iBXP0mFg'

jira_token = 'Qoi6yaqSNTvjdyJAhgNz1AE4'

def main():
    #version = os.environ['version']
    #project = os.environ['project']
    #new_cycle = os.environ['cycle']

    parser = argparse.ArgumentParser(description='copy tests to release')
    #parser.add_argument('--version_from_load', action='store_true')
    parser.add_argument('--version')
    parser.add_argument('--project')
    parser.add_argument('--cycle')
    parser.add_argument('--folder')
    parser.add_argument('--component', default='Automated')
    parser.add_argument('--componentOmit')

    args = parser.parse_args()

    version = args.version
    project = args.project
    new_cycle = args.cycle
    component = args.component
    folder = args.folder
    component_omit = args.componentOmit
 
    logging.basicConfig(
        level=logging.DEBUG,
        format = "%(asctime)s - %(filename)s %(funcName)s() line %(lineno)d - %(levelname)s -  - %(message)s")
    logging.getLogger('urllib3').setLevel(logging.ERROR)
    logging.getLogger('zapi').setLevel(logging.DEBUG)

    z = zapi.Zapi(username=accountid, access_key=access_key, secret_key=secret_key, debug=True)
    j = jiraapi.Jiraapi(username=username, token=jira_token)

    project_info = j.get_project('ECQ')
    content = json.loads(project_info)
    project_id = content['id']
    version_id = None
    folder_id = None
    for v in content['versions']:
        if v['name'] == version:
            version_id = v['id']
    print('p', project_id)
    #version_id = z.get_version_id(project_id, version)

    cycle_id = z.get_cycle_id(name=new_cycle, project_id=project_id, version_id=version_id)

    if folder:
        folder_id = z.get_folder_id(name=folder, project_id=project_id, version_id=version_id, cycle_id=cycle_id)

    logging.info("project_id=%s version_id=%s cycle_id=%s folder_id=%s" % (project_id, version_id, cycle_id, folder_id))

    if cycle_id: 
        #add tests to cycle
        jql = f'project={project} and type=Test and fixVersion={version}'
        component_list = component.split(',')
        for comp in component_list:
            jql += f' and component={comp}'
        if component_omit:
            component_omit_list = component_omit.split(',')
            for comp in component_omit_list:
                jql += f' and component!={comp}'
        print('jql', jql)
        z.add_tests_to_cycle(project_id=project_id, version_id=version_id, cycle_id=cycle_id, folder_id=folder_id, jql=jql)
        #start_date = time.strftime('%Y-%m-%d', time.gmtime())
        #z.update_cycle(name=new_cycle, project_id=project_id, version_id=version_id, cycle_id=cycle_id, build=new_cycle, start_date=start_date)
    else:
        logging.error('cycle_id NOT found')
        
if __name__ == '__main__':
    main()
