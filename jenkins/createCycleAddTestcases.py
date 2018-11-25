#!/usr/bin/python3

import sys
import os
import logging
import json
import zapi
import jiraapi

import subprocess
import argparse

username = 'andy.anderson@mobiledgex.com'
access_key = 'MDAzZTcyMTMtNGY3ZS0zMmMwLWIxZDAtYjZlM2Y1MTljNmNlIGFuZHkuYW5kZXJzb24gVVNFUl9ERUZBVUxUX05BTUU'
secret_key = 'S_KlvniknmZ1EPVVJij70fIsm8V7UqrAgxC3MGQqCqA'
jira_token = 'Qoi6yaqSNTvjdyJAhgNz1AE4'

def main():
    #version = os.environ['version']
    #project = os.environ['project']
    #new_cycle = os.environ['cycle']

    parser = argparse.ArgumentParser(description='create cycle in jira')
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
    logging.info("project_id=%s version_id=%s" % (project_id, version_id))

    new_cycle_exists_id = z.get_cycle_id(name=new_cycle, project_id=project_id, version_id=version_id)

    #create the new cycle
    if(int(new_cycle_exists_id) < 0): # cycle does not exist
        logging.info("cycle=%s does NOT exist. creating the cycle" % new_cycle)
        new_cycle_resp = z.create_cycle(project_id=project_id, version_id=version_id, cycle_name=new_cycle, build=new_cycle)
        new_cycle_id = json.loads(new_cycle_resp)['id']
        print(new_cycle_id)
    else:
        logging.info("cycle=%s DOES exist. NOT creating the cycle" % new_cycle)

if __name__ == '__main__':
    main()
