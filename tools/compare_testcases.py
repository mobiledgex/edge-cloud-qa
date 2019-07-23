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

#Change base directory
BASE_DIRECTORY = "/Users/mexloaner/go/src/github.com/mobiledgex/edge-cloud-qa/testcases"

file_list = []             # List of files that are .py or .robot

def extract_testcases():
    for (dirpath, dirnames, filenames) in os.walk(BASE_DIRECTORY):
        for f in filenames:
            if f[0] == ".":
                pass
            elif ".pyc" in str(f):
                pass
            elif '.py' in str(f):
                e = os.path.join(str(dirpath), str(f))
                file_list.append(e)
            elif '.robot' in str(f):
                e = os.path.join(str(dirpath), str(f))
                file_list.append(e)
    #appends all paths into a file_list 
    filehandle = open('Testcases and files.txt', 'w')
    filehandle.write('All Files and Testcase names:\n')
    for files in file_list:
        testname= None
        lines_previous = ''
        list_tests = []
        list_tests2 = []
        file_name = os.path.basename(files)
        txtfile = open(files, 'r')
        for lines in txtfile:
            if '[Documentation]' in lines:
                testname= lines_previous 
                list_tests2.append(testname)
                type_of_file = "robot"
            if "def test" in lines:
                testname = lines
                testname1 = lines[4:]
                testname = testname1[0:-8]
                list_tests.append(testname)
                type_of_file ="python"
            lines_previous = lines
        if testname != None:
            if type_of_file == 'robot':
                for test in list_tests2:
                    testname3 = test[0:-1]
                    list_tests.append(testname3)
        #print(list_tests)
            #filehandle.write('%s\n' % "File Path: ")
            filehandle.write('%s\n' % file_name)
            #filehandle.write('%s\n' % "Testname: ")
            filehandle.write('%s\n' % list_tests)
            #filehandle.write('\n')
    
#extract_testcases()
#_____________________________________________________________________________________________________________________
# Extracts from Jira

username = 'andy.anderson@mobiledgex.com'
jira_token = '***REMOVED***'
access_key = '***REMOVED***';
secret_key = '***REMOVED***'

python_path = '$WORKSPACE/go/src/github.com/mobiledgex/protos:$WORKSPACE/go/src/github.com/mobiledgex/modules:$WORKSPACE/go/src/github.com/mobiledgex/certs:$WORKSPACE/go/src/github.com/mobiledgex/testcases::$WORKSPACE/go/src/github.com/mobiledgex/testcases/config'

def main():
    
    parser = argparse.ArgumentParser(description='copy tests to release')
    parser.add_argument('--version_from_load', action='store_true')
    args = parser.parse_args()

    #print(os.environ)
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
        
    startat = 0
    maxresults = 0
    total = 900
    tc_list = []
    while (startat + maxresults) < total:
        result = j.search(query=jiraQueryUrl, start_at=startat+maxresults)
        #print(result)
        query_content = json.loads(result)
        startat = query_content['startAt']
        maxresults = query_content['maxResults']
        total = query_content['total']
        tc_list += get_testcases(z, result)
        #tempstring = json.dumps(result)
        #filehandle.write(result)
    test = "test"

    return test

def get_testcases(z, result):
    query_content = json.loads(result)
    tc_list = []
    randomlist = []
    filehandle = open('hella_stuff', 'w')               # change to different text file

    for s in query_content['issues']:
        sresult = z.get_teststeps(s['id'],s['fields']['project']['id'])
        sresult_content = json.loads(sresult)
        #print('XXXXXXXXXXXXXXXXXXXX', sresult_content)

        if sresult_content:
            tmp_list = {}
            tmp_list['defect_count'] = len(s['fields']['issuelinks'])
            randomlist.append(sresult_content[0]['step'])
            logging.info("script is " + sresult_content[0]['step'])
        else:
            logging.info("did NOT find a teststep")
            tmp_list = {'id': s['id'], 'tc': 'noTestcaseInStep', 'issue_key': s['key']}
        tc_list.append(tmp_list)
    #print(tc_list)
    #sys.exit(1)
    print(randomlist)
    return tc_list

def get_testcases_z(z, result, cycle):
    query_content = json.loads(result)
    tc_list = []
    
    for s in query_content['searchObjectList']:
        if s['execution']['cycleName'] == cycle:
            sresult = z.get_teststeps(s['execution']['issueId'],s['execution']['projectId'])
            sresult_content = json.loads(sresult)
            if sresult_content:
                tmp_list = {'id': s['execution']['id'], 'tc': sresult_content[0]['step'], 'issue_key': s['issueKey'], 'issue_id': s['execution']['issueId'], 'defects': s['execution']['defects'], 'project_id': s['execution']['projectId'], 'version_id':s['execution']['versionId'], 'cycle_id':s['execution']['cycleId']}
                if 'totalDefectCount' in s['execution']: # totalDefectCount only exists if the test has previously been executed
                    tmp_list['defect_count'] = s['execution']['totalDefectCount']
                else:
                    tmp_list['defect_count'] = 0
            else:
                tmp_list = {'id': s['id'], 'tc': 'noTestcaseInStep', 'issue_key': s['issueKey']}
            
            tc_list.append(tmp_list)

    return tc_list

def find(name, path):
    for root, dirs, files in os.walk(path):
        if name in files:
            return os.path.join(root, name)
    return 'fileNotFound'

#if __name__ == '__main__':
    main()

## Not working? Try: export Cycle=Stratus_automation_2019-07-16;export Version=Stratus;export Project=ECQ;export “Components=Automated, Controller, Flavor”;export WORKSPACE=
#____________________________________________________________________________________________________________________________________
first_file = "/Users/mexloaner/compare1.txt"  #Change location to file 1
second_file = "/Users/mexloaner/compare2.txt"  #Change location to file 2

# Compares 2 text files returns differences into another .txt file

f1 = "/Users/mexloaner/go/src/github.com/mobiledgex/edge-cloud-qa/tools/testcases and files.txt"  # Change file to file needed for comparison
f2 = "/Users/mexloaner/hella_stuff"  # Change file to file needed for comparison
difference = "/Users/mexloaner/difference_file.txt"  # Change file to file for the differences

list_tests1 = []
list_tests2 = []

def compare(f1,f2):
    text1 = open(f1).readlines() 
    text2 = open(f2).readlines()
    difference_report = open(difference, 'w') 
    difference_report.write('%s\n' % "Things not in file 2: ")
    for lines in text1:   
        list_tests1.append(lines)
    for lines in text2:
        list_tests2.append(lines)
    for stuff in list_tests1:
        if stuff =='\n':
            list_tests1.remove(stuff)
        if stuff =='Testname: \n' :
            list_tests1.remove(stuff)
        if stuff =='File Path: \n':
            print('YAAAAAAAAAAAAY FOUND IT')
            list_tests1.remove(stuff)
        if stuff not in list_tests2:
            difference_report.write(stuff)
        else:
            pass
    difference_report.write('\n')
    difference_report.write('%s\n' % "Things not in file 1: ")
    for things in list_tests2:
        if things == '':
            list_tests2.remove(things)

        if things not in list_tests1:
            difference_report.write(things)
        else:
            pass
    print(list_tests1)
    difference_report.write('\n')
    difference_report.close()

compare(f1,f2)
