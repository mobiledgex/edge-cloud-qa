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
access_key = 'MDAzZTcyMTMtNGY3ZS0zMmMwLWIxZDAtYjZlM2Y1MTljNmNlIGFuZHkuYW5kZXJzb24gYW5keS5hbmRlcnNvbg';
secret_key = 'PckHXrGmx7pHzt-_-uAEBAK7fGP3dk3rI5BbVQLb5oU'

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
    args = parser.parse_args()

    version = args.version
    project = args.project
    new_cycle = args.cycle
    
    logging.basicConfig(
        level=logging.DEBUG,
        format = "%(asctime)s - %(filename)s %(funcName)s() line %(lineno)d - %(levelname)s -  - %(message)s")
    logging.getLogger('urllib3').setLevel(logging.ERROR)
    logging.getLogger('zapi').setLevel(logging.DEBUG)

    z = zapi.Zapi(username=username, access_key=access_key, secret_key=secret_key, debug=True)
    j = jiraapi.Jiraapi(username=username, token=jira_token)

    project_info = j.get_project('ECQ')
    content = json.loads(project_info)
    project_id = content['id']
    version_id = None
    for v in content['versions']:
        if v['name'] == version:
            version_id = v['id']
    print('p', project_id)
    #version_id = z.get_version_id(project_id, version)

    cycle_id = z.get_cycle_id(name=new_cycle, project_id=project_id, version_id=version_id)
    print('andy')
    logging.info("project_id=%s version_id=%s cycle_id=%s" % (project_id, version_id, cycle_id))

    if cycle_id: 
        #add tests to cycle
        jql = 'project={} and type=Test and component=Automated'.format(project)
        print('jql', jql)
        z.add_tests_to_cycle(project_id=project_id, version_id=version_id, cycle_id=cycle_id, jql=jql)
        #start_date = time.strftime('%Y-%m-%d', time.gmtime())
        #z.update_cycle(name=new_cycle, project_id=project_id, version_id=version_id, cycle_id=cycle_id, build=new_cycle, start_date=start_date)
    else:
        logging.error('cycle_id NOT found')
        
if __name__ == '__main__':
    main()
