import os
import sys
import argparse
import logging
import subprocess
import time
import re
import json
 
def main():
    parser = argparse.ArgumentParser(description='clean az groups')
    parser.add_argument('--groupSubstring', required=True, help='substring to match group name, such as automationAzureCentralCloudlett')


    args = parser.parse_args()
    print(args)

    if args.groupSubstring:
        group_list = get_group_list(args.groupSubstring)
        print(group_list)
        delete_group(group_list)

#    time.sleep(120)   # wait for router delete to be done ?

def get_group_list(substring):
    cmd = 'az group list'

    group_list = []
    
    r = subprocess.run(cmd, shell=True, capture_output=True, encoding='utf8', check=True)

    stdout = r.stdout

  #  print('stdout', stdout)
 #   print('substring', substring)
    group_dict =  json.loads(r.stdout)
  #  print(group_dict)
    for group in group_dict:
       # print('group',group["name"])
        if substring in group["name"]:
          #  print("g",group["name"])
           # subnetid = line.split('|')[2]
            group_list.append(group["name"])

    #print(subnetid_list)

    return group_list

def delete_group(group_list):
    for group in group_list:
        cmd = f'az group delete --name {group} --yes --no-wait'
        print(cmd)
        try:
            r = subprocess.run(cmd, shell=True, capture_output=True, encoding='utf8', check=True)
        except subprocess.CalledProcessError as err:
            logging.info("   exec cmd failed. return code=: " + str(err.returncode))
            logging.info("   exec cmd failed. stdout=: " + str(err.stdout))
            logging.info("   exec cmd failed. stderr=: " + str(err.stderr))
            
if __name__ == '__main__':
    main()
