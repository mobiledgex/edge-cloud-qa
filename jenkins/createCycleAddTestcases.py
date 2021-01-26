#!/usr/bin/python3

import sys
import os
import logging
import json
import zapi
import jiraapi
import time

import subprocess
import argparse

username = 'andy.anderson@mobiledgex.com'

#userkey
#access_key = 'MDAzZTcyMTMtNGY3ZS0zMmMwLWIxZDAtYjZlM2Y1MTljNmNlIGFuZHkuYW5kZXJzb24gVVNFUl9ERUZBVUxUX05BTUU'
#secret_key = '5PG4ErUMoD5U_CtjALv9O6wFnjkiOcVq8DJrTkTW0w4'

#systemkey
#access_key = 'MDAzZTcyMTMtNGY3ZS0zMmMwLWIxZDAtYjZlM2Y1MTljNmNlIGFuZHkuYW5kZXJzb24gYW5keS5hbmRlcnNvbg';
#secret_key = 'PckHXrGmx7pHzt-_-uAEBAK7fGP3dk3rI5BbVQLb5oU'
accountid = '5b85c5f93cee7729fa0660a8'
access_key = 'MDAzZTcyMTMtNGY3ZS0zMmMwLWIxZDAtYjZlM2Y1MTljNmNlIDViODVjNWY5M2NlZTc3MjlmYTA2NjBhOCBVU0VSX0RFRkFVTFRfTkFNRQ'
secret_key = '_1x9j2jdzPGHmpQTs9myoiz76wFTl1f_MC3iBXP0mFg'

#secret_key = 'S_KlvniknmZ1EPVVJij70fIsm8V7UqrAgxC3MGQqCqA'

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
    parser.add_argument('--folder')

    args = parser.parse_args()

    version = args.version
    project = args.project
    new_cycle = args.cycle
    new_folder = args.folder
 
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
    new_cycle_id = None
    for v in content['versions']:
        if v['name'] == version:
            version_id = v['id']
    print('p', project_id)
    #version_id = z.get_version_id(project_id, version)
    logging.info("project_id=%s version_id=%s" % (project_id, version_id))

    new_cycle_exists_id = z.get_cycle_id(name=new_cycle, project_id=project_id, version_id=version_id)

    #create the new cycle
    if(not new_cycle_exists_id): # cycle does not exist
        logging.info("cycle=%s does NOT exist. creating the cycle" % new_cycle)
        new_cycle_resp = z.create_cycle(project_id=project_id, version_id=version_id, cycle_name=new_cycle, build=new_cycle)
        new_cycle_id = json.loads(new_cycle_resp)['id']
        logging.info(f'new_cycle_id={new_cycle_id}')
        time.sleep(1)
        found = False
        num_tries = 1 
        for x in range(num_tries):
           logging.info(f'looking for cycle {x}/{num_tries} tries')
           new_cycle_exists_id = z.get_cycle_id(name=new_cycle, project_id=project_id, version_id=version_id)
           print(f'xxx {new_cycle_id} == {new_cycle_exists_id}')
           if new_cycle_id == new_cycle_exists_id:
               logging.info(f'newly created cycle={new_cycle} found')
               found = True
               break
           else:
               logging.debug(f'newly create cycle={new_cycle} NOT found')
               time.sleep(1)
               #logging.error(f'newly create cycle={new_cycle} NOT found')
        if not found:
            logging.error(f'newly create cycle={new_cycle} NOT found. Done waiting')
            sys.exit(1)
    else:
        logging.info("cycle=%s DOES exist. NOT creating the cycle" % new_cycle)
        new_cycle_id = new_cycle_exists_id

    if new_folder:
        new_folder_exists_id = z.get_folder_id(name=new_folder, project_id=project_id, version_id=version_id, cycle_id=new_cycle_id)
        if(not new_folder_exists_id): # folder does not exist
            logging.info(f'creating folder={new_folder} project_id={project_id} version_id={version_id} cycle_id={new_cycle_id}')
            new_folder_resp = z.create_folder(folder_name=new_folder, project_id=project_id, version_id=version_id, cycle_id=new_cycle_id)
        else:
            logging.info(f'folder={new_folder} DOES exist. NOT creating the folder') 

if __name__ == '__main__':
    main()
