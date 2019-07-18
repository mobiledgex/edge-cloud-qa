# Script that extracts testcase names and filenames from .py and .robot files in BASE_DIRECTORY
# DIRECTORY = /Users/mexloaner/go/src/github.com/mobiledgex/edge-cloud-qa/tools

import os
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
        line_previous = ''
        list_tests = []
        list_tests2 = []
        file_name = os.path.basename(files)
        txtfile = open(files, 'r')
        for line in txtfile:
            if '[Documentation]' in line:
                testname= line_previous 
                list_tests2.append(testname)
                type_of_file = "robot"
            if "def test" in line:
                testname = line
                testname1 = line[4:]
                testname = testname1[0:-8]
                list_tests.append(testname)
                type_of_file ="python"
                line_previous = line
                if testname != None:
                  if type_of_file == 'robot':
                      for test in list_tests2:
                          testname3 = test[0:-1]
                          list_tests.append(testname3)
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
   #  logging.basicConfig(
    #    level=logging.INFO,
    #    format = "%(asctime)s - %(filename)s %(funcName)s() line %(lineno)d - %(levelname)s -  - %(message)s")
  #  logging.getLogger('urllib3').setLevel(logging.ERROR)
  #  logging.getLogger('zapi').setLevel(logging.DEBUG)

   # z = zapi.Zapi(username=username, access_key=access_key, secret_key=secret_key, debug=False)
   # j = jiraapi.Jiraapi(username=username, token=jira_token)
