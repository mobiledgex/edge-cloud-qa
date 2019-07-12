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
access_key = 'MDAzZTcyMTMtNGY3ZS0zMmMwLWIxZDAtYjZlM2Y1MTljNmNlIGFuZHkuYW5kZXJzb24gYW5keS5hbmRlcnNvbg';
secret_key = 'PckHXrGmx7pHzt-_-uAEBAK7fGP3dk3rI5BbVQLb5oU'

jira_token = 'Qoi6yaqSNTvjdyJAhgNz1AE4'

python_path = '/Users/mexloaner/go/src/github.com/mobiledgex/edge-cloud-qa/testcases'

p = ".py"
r = ".robot"

edge_cloudqa = []
testcases_files = os.listdir(python_path)


def get_all_tests(path):
    testcases_files = os.listdir(path)
    for files in testcases_files:
        panic = False
        if files[0] == ".":
            pass
           # print("Hidden file: " + files)
        else:
            if p in files:
                edge_cloudqa.append(files)
            elif r in files:
                edge_cloudqa.append(files)
            else:
                if not(p or r):
                    panic = True
                for letter in files:
                    if letter == ".":
                      #  print(files)
                        panic = True
                if panic == False:
                    one_step_deeper_path = path + "/" + files
                 #   print(one_step_deeper_path)
                    get_all_tests(one_step_deeper_path)
    return(edge_cloudqa)
returned_List = get_all_tests(python_path)
print(returned_List)



def get_all_tests():
    for files in testcases_files:
        if files[0]==".":
            pass
        else:
            tempString = python_path + '/' + files
            testcases_in_files = os.listdir(tempString)
            for tests in testcases_in_files:
                 if tests[0]==".":
                     pass
                 else:
                     if (p and r) in tests:
                         edge_cloudqa.append(tests)
                     if (p or r) in tests:
                         edge_cloudqa.append(tests)

    print(edge_cloudqa)

#get_all_tests()


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
