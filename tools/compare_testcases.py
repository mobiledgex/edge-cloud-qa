# Script that extracts testcase names and filenames from .py and .robot files in BASE_DIRECTORY and
# Jira and compares tests
# DIRECTORY = /Users/mexloaner/go/src/github.com/mobiledgex/edge-cloud-qa/tools

import os
import logging
import zapi
import jiraapi
import difflib

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
            filehandle.write('%s\n' % "File Path: ")
            filehandle.write('%s\n' % file_name)
            filehandle.write('%s\n' % "Testname: ")
            filehandle.write('%s\n' % list_tests)
            filehandle.write('\n')
    
#extract_testcases()
#_____________________________________________________________________________________________________________________

zephyrBaseUrl = "https://mobiledgex.atlassian.net/rest/zapi/latest/"


component_list = component.split(',')
component_query = ''
for component in component_list:
    component_query += ' AND component = ' + component
zephyrQueryUrl = 'project=\\\"' + project + '\\\" AND fixVersion=\\\"' + version + '\\\"' + component_query + ' ORDER BY Issue ASC'
jiraQueryUrlPre = 'project="' + project + '" AND fixVersion="' + version + '"' + component_query
jiraQueryUrl = jiraQueryUrlPre + ' ORDER BY Issue ASC'

logging.info("zephyrQueryUrl=" + zephyrQueryUrl)

#result = z.execute_query(zephyrQueryUrl)
startat = 0
maxresults = 0
total = 1
tc_list = []
while (startat + maxresults) < total:
    result = j.search(query=jiraQueryUrl, start_at=startat+maxresults)
    query_content = json.loads(result)
    startat = query_content['startAt']
    maxresults = query_content['maxResults']
    total = query_content['total']
    print(startat,maxresults,total)
    #sys.exit(1)
    tc_list += get_testcases(z, result, cycle_id, project_id, version_id)

        
print('tc_list',tc_list)
print('lentclist', len(tc_list))


def get_testcases(z, result, cycle_id, project_id, version_id):
    query_content = json.loads(result)
    tc_list = []
    
    #for s in query_content['executions']:
    for s in query_content['issues']:
        print('issueKey', s['key'])
        logging.info("getting script for:" + s['key'])
        sresult = z.get_teststeps(s['id'],s['fields']['project']['id'])
        sresult_content = json.loads(sresult)

        if sresult_content: # list is not empty;therefore, has a teststep
            logging.info("found a teststep")
            #tmp_list = {'id': s['id'], 'tc': sresult_content[0]['step'], 'issue_key': s['issueKey'], 'issue_id': s['issueId']}
            #tmp_list = {'id': s['execution']['id'], 'tc': sresult_content[0]['step'], 'issue_key': s['issueKey'], 'issue_id': s['execution']['issueId'], 'defects': s['execution']['defects'], 'project_id': s['execution']['projectId'], 'version_id':s['execution']['versionId'], 'cycle_id':s['execution']['cycleId']}
            tmp_list = {'tc': sresult_content[0]['step'], 'issue_key': s['key'], 'issue_id': s['id'], 'project_id': project_id, 'version_id':version_id, 'cycle_id':cycle_id, 'defects': s['fields']['issuelinks']}
            print(s)
            tmp_list['defect_count'] = len(s['fields']['issuelinks']) # need to check for issueslink section
            #if 'totalDefectCount' in s['execution']: # totalDefectCount only exists if the test has previously been executed
            #    tmp_list['defect_count'] = s['execution']['totalDefectCount']
            #else:
            #    tmp_list['defect_count'] = 0
            logging.info("script is " + sresult_content[0]['step'])
        else:
            logging.info("did NOT find a teststep")
            tmp_list = {'id': s['id'], 'tc': 'noTestcaseInStep', 'issue_key': s['key']}

        tc_list.append(tmp_list)
    print(tc_list)
    #sys.exit(1)
    return tc_list


#____________________________________________________________________________________________________________________________________
first_file = "/Users/mexloaner/compare1.txt"  #Change location to file 1
second_file = "/Users/mexloaner/compare2.txt"  #Change location to file 2

# Compares 2 text files returns differences into another .txt file

f1 = "/Users/mexloaner/compare1.txt"  # Change file to file needed for comparison
f2 = "/Users/mexloaner/compare2.txt"  # Change file to file needed for comparison
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
        if stuff == '':
            list_test1.remove('')
        if stuff not in list_tests2:
            difference_report.write(stuff)
        else:
            pass
    difference_report.write('\n')
    difference_report.write('%s\n' % "Things not in file 1: ")
    for things in list_tests2:
        if things == '':
            list_test2.remove('')
        if things not in list_tests1:
            difference_report.write(things)
        else:
            pass
    difference_report.write('\n')
    difference_report.close()

compare(f1,f2)
