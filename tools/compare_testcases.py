#!/usr/bin/python3
# Recursive function to look for .XX type of files

import sys
import os
import logging
import json
import time
import zapi
import jiraapi
import subprocess
import argparse
import unittest
import glob

username = 'andy.anderson@mobiledgex.com'
access_key = '***REMOVED***';
secret_key = '***REMOVED***'

jira_token = '***REMOVED***'

python_path = '/Users/mexloaner/go/src/github.com/mobiledgex/edge-cloud-qa/testcases'

edge_cloudqa = []

# r=root, d=directories, f = files
def get_tests():
    for r, d, f in os.walk(python_path):
        for files in f:
            if '.py' in files:
                with open(files, 'r') as o:
                    if "testcases" in files:

                        
                        edge_cloudqa.append(line.strip() for line in o)
             #   edge_cloudqa.append(os.path.join(files))
           # elif ".robot" in files:
             #   edge_cloudqa.append(os.path.join(files))
    edge_cloudqa.sort()
    print(edge_cloudqa)
get_tests()

    # logging.basicConfig(
  #      level=logging.DEBUG,
  #      format = "%(asctime)s - %(filename)s %(funcName)s() line %(lineno)d - %(levelname)s -  - %(message)s")
   # logging.getLogger('urllib3').setLevel(logging.ERROR)
   # logging.getLogger('zapi').setLevel(logging.DEBUG)

   # z = zapi.Zapi(username=username, access_key=access_key, secret_key=secret_key, debug=False)
   # j = jiraapi.Jiraapi(username=username, token=jira_token)

    
  #  jiraQueryUrl = f'key={tcid}'
   # result = j.search(query=jiraQueryUrl)
  #  query_content = json.loads(result)
  #  issue_id = query_content['issues'][0]['id']

    
#if __name__ == '__main__':
         #     get_all_tests()
   # parser = argparse.ArgumentParser(description='update cycle')
