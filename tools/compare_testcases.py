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

# Script that extracts testcase names and filenames from .py and .robot files in BASE_DIRECTORY and Jira and compares tests
# DIRECTORY = /Users/mexloaner/go/src/github.com/mobiledgex/edge-cloud-qa/tools

import os
import logging
import zapi
import jiraapi
import difflib
import sys
import urllib
import json
import time
import subprocess
import argparse

#Extracts Testcases and filenames from base_directory
#Change base directory
BASE_DIRECTORY = "/Users/mexloaner/go/src/github.com/mobiledgex/edge-cloud-qa/testcases"

file_dict = {}             # List of files that are .py or .robot

def extract_testcases():
    count = 0
    count2 = 0
    for (dirpath, dirnames, filenames) in os.walk(BASE_DIRECTORY):
        for f in filenames:
            if f[0] == ".":
                pass
            elif ".pyc" in str(f):
                pass
            elif '.py' in str(f):
                e = os.path.join(str(dirpath), str(f))
                file_dict.update({e : 'python file'})
            elif '.robot' in str(f):
                e = os.path.join(str(dirpath), str(f))
                file_dict.update({e : 'robot file'})
    #appends all paths into a file_dict 
    filehandle = open('Testcases and files.txt', 'w')
    #filehandle.write('All Files and Testcase names:\n')
    #print(file_dict)
    for files, typeOfFile in file_dict.items():
        testname= None
        lines_previous = ''
        python_tests = []
        robot_tests = []
        file_name = os.path.basename(files)
        print(files)
        txtfile = open(files, 'r')
        if typeOfFile == 'python file':
            for lines in txtfile:
                if "def test" in lines:
                    testname = lines
                    testname1 = lines[4:]
                    testname = testname1[0:-8]
                    python_tests.append(testname)
                    count += 1
        elif typeOfFile =='robot file':
            for lines in txtfile:
                if '[Documentation]' in lines:
                    testname= lines_previous 
                    robot_tests.append(testname)
                    type_of_file = "robot"
                    count2 += 1
                lines_previous = lines
        newpath = files.replace('/', '.')
        if testname != None:
            if typeOfFile == 'python file':
                for tests in python_tests:
                    tests = tests[4:]
                    string2 = ''
                    string2 += 'controller'
                    string2 += '.'
                    pfiles_name = (newpath[81:-3])
                    string2 += pfiles_name
                    string2 += '.tc.'
                    string2 += tests.strip()
                    filehandle.write('%s' % string2.rstrip())
                    filehandle.write('\n')
            elif typeOfFile =='robot file':
                count2 +=1
                for rtests in robot_tests:
                    testname3 = rtests[0:-1]
                    string1 = ''
                    rfiles_name = file_name
                    string1 += rfiles_name
                    string1 += ': '
                    string1 += testname3
                    filehandle.write('%s' % string1.rstrip())
                    filehandle.write('\n')
            else:
                print('something wrong')
    print(count +count2)
    filehandle.close()
            #filehandle.write('%s\n' % "File Path: ")
            #filehandle.write('%s:%s' % file_name)
            #filehandle.write('%s\n' % "Testname: ")
            #filehandle.write('%s\n' % list_tests)
            #filehandle.write('\n')
#extract_testcases()
#_____________________________________________________________________________________________________________________
# Extracts from Jira
# Not working? Try: export Cycle=Stratus_automation_2019-07-16;export Version=Stratus;export Project=ECQ;export “Components=Automated, Controller, Flavor”;export WORKSPACE=.

username = 'andy.anderson@mobiledgex.com'
jira_token = 'Qoi6yaqSNTvjdyJAhgNz1AE4'
access_key = 'MDAzZTcyMTMtNGY3ZS0zMmMwLWIxZDAtYjZlM2Y1MTljNmNlIGFuZHkuYW5kZXJzb24gYW5keS5hbmRlcnNvbg';
secret_key = 'PckHXrGmx7pHzt-_-uAEBAK7fGP3dk3rI5BbVQLb5oU'

def main():
    filehandle = open('Jira testcases.txt', 'w')               # change to different text file
    parser = argparse.ArgumentParser(description='copy tests to release')
    parser.add_argument('--version_from_load', action='store_true')
    args = parser.parse_args()

    cycle = os.environ['Cycle']
    version = os.environ['Version']
    project = os.environ['Project']

    component = os.environ['Components']
    workspace = os.environ['WORKSPACE']
 
    zephyrBaseUrl = "https://mobiledgex.atlassian.net/rest/zapi/latest/"

    logging.basicConfig(
        level=logging.DEBUG,
        format = "%(asctime)s - %(filename)s %(funcName)s() line %(lineno)d - %(levelname)s -  - %(message)s")
       
    z = zapi.Zapi(username=username, access_key=access_key, secret_key=secret_key, debug=True)
    j = jiraapi.Jiraapi(username=username, token=jira_token)

    project_info = j.get_project(project)
    content = json.loads(project_info)
    project_id = content['id']
    version_id = None
    for v in content['versions']:
        if v['name'] == version:
            version_id = v['id']
    cycle_id = z.get_cycle_id(name=cycle, project_id=project_id, version_id=version_id)

    component_list = component.split(',')
    component_query = ''
    for component in component_list:
        component_query += ' AND component = ' + component
    zephyrQueryUrl = 'project=\\\"' + project + '\\\" AND fixVersion=\\\"' + version + '\\\"' + component_query + ' ORDER BY Issue ASC'
    jiraQueryUrlPre = 'project="' + project + '" AND fixVersion="' + version + '"' + component_query
    jiraQueryUrl = jiraQueryUrlPre + ' ORDER BY Issue ASC'
    print(jiraQueryUrl)
    #sys.exit(1)
  
    startat = 0
    maxresults = 0
    total = 800
    tc_list = []
    while (startat + maxresults) < total:
        result = j.search(query=jiraQueryUrl, start_at=startat+maxresults)
        #print(result)
        #sys.exit(1)
        query_content = json.loads(result)
        startat = query_content['startAt']
        maxresults = query_content['maxResults']
        total = query_content['total']
        #print(startat,maxresults,total)
        #sys.exit(1)
        our_list = get_testcases_x(z, result)
        ourlist = [x.replace('\n', ': ') for x in our_list]
        tc_list += ourlist
        for i in ourlist:
            filehandle.write(i)
            filehandle.write('\n')
    filehandle.close()
    print('lentclist', len(tc_list))

    test = "test"
    return test

def get_testcases_x(z, result):
    query_content = json.loads(result)
    tc_list = []
    
    for s in query_content['issues']:
        sresult = z.get_teststeps(s['id'],s['fields']['project']['id'])
        sresult_content = json.loads(sresult)
        if sresult_content: # list is not empty;therefore, has a teststep
            tmp_list = {}
            tmp_list['defect_count'] = len(s['fields']['issuelinks']) # need to check for issueslink section
            logging.info("script is " + sresult_content[0]['step'])
            tc_list.append(sresult_content[0]['step'])

        else:
            logging.info("did NOT find a teststep")
            tmp_list = {'id': s['id'], 'tc': 'noTestcaseInStep', 'issue_key': s['key']}

    return tc_list

#if __name__ == '__main__':
    main()
  
#____________________________________________________________________________________________________________________________________
# Compares 2 text files returns differences into another .txt file


f1 = "/Users/mexloaner/go/src/github.com/mobiledgex/edge-cloud-qa/tools/testcases and files.txt"  # Change file to file needed for comparison
f2 = "/Users/mexloaner/go/src/github.com/mobiledgex/edge-cloud-qa/tools/Jira testcases.txt"  # Change file to file needed for comparison
difference = "/Users/mexloaner/go/src/github.com/mobiledgex/edge-cloud-qa/tools/Differences in Jira and github.txt"  # Change file to file for the differences

list_tests1 = []
list_tests2 = []

def compare(f1,f2):
    text1 = open(f1).readlines() 
    text2 = open(f2).readlines()
    difference_report = open(difference, 'w') 
    difference_report.write('%s\n' % "Things not in file 2 (jira): ")
    for QA_lines in text1:
        #if '.robot' in lines:
        QA_lines.strip()
        list_tests1.append(QA_lines)
        #if '.tc.' in lines:
            #lines.strip()
            #list_tests1.append(lines)
    for Jira_lines in text2:
        #if '.robot' in lines:
        Jira_lines.strip()
        list_tests2.append(Jira_lines)
       # if '.tc.' in lines:
            #lines.strip()
            #list_tests2.append(lines)
    for Jira_testnames in list_tests1:
        if Jira_testnames =='\n':
            list_tests1.remove(Jira_testnames)
        if Jira_testnames in list_tests2:
            pass
        else:
            difference_report.write(Jira_testnames)
    difference_report.write('\n')
    difference_report.write('%s\n' % "Things not in file 1 (testcases and files): ")
    for QAtestnames in list_tests2:
        if QAtestnames == '':
            list_tests2.remove(QAtestnames)
        if QAtestnames in list_tests1:
            pass
        else:
            difference_report.write(QAtestnames)
    #print(list_tests1)
    difference_report.write('\n')
    difference_report.close()

#compare(f1,f2)
