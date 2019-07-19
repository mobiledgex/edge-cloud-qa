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
    
extract_testcases()


username = 'andy.anderson@mobiledgex.com'
access_key = '***REMOVED***';
secret_key = '***REMOVED***'
jira_token = '***REMOVED***'

#def extract_Jiracases():
    # logging.basicConfig(
    #    level=logging.INFO,
    #    format = "%(asctime)s - %(filename)s %(funcName)s() line %(lineno)d - %(levelname)s -  - %(message)s")
  #  logging.getLogger('urllib3').setLevel(logging.ERROR)
  #  logging.getLogger('zapi').setLevel(logging.DEBUG)

  #  z = zapi.Zapi(username=username, access_key=access_key, secret_key=secret_key, debug=False)
  #  j = jiraapi.Jiraapi(username=username, token=jira_token)



first_file = "/Users/mexloaner/compare1.txt"  #Change location to file 1
second_file = "/Users/mexloaner/compare2.txt"  #Change location to file 2

# Compares 2 text files returns differences into another .txt file
import difflib

f1 = "/Users/mexloaner/compare1.txt"
f2 = "/Users/mexloaner/compare2.txt"

list_tests1 = []
list_tests2 = []

def compare(f1,f2):
    text1 = open(f1).readlines() 
    text2 = open(f2).readlines()
    difference_report = open("/Users/mexloaner/difference_file.txt", 'w')  #Change file for differences
    difference_report.write('%s\n' % "Things not in file2.txt: ")
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
    difference_report.write('%s\n' % "Things not in file1.txt: ")
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
