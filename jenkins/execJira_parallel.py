#!/usr/bin/python3

import sys
import os
import threading
#print(sys.path)

import zapi
import jiraapi
import urllib
import logging
import json
import time
import subprocess
import argparse

username = 'andy.anderson@mobiledgex.com'
#jira_token = 'cop6UQnmK4mwodXzijsY407F'
jira_token = 'Qoi6yaqSNTvjdyJAhgNz1AE4'
#userkey
#access_key = 'MDAzZTcyMTMtNGY3ZS0zMmMwLWIxZDAtYjZlM2Y1MTljNmNlIGFuZHkuYW5kZXJzb24gVVNFUl9ERUZBVUxUX05BTUU'
#secret_key = 'S_KlvniknmZ1EPVVJij70fIsm8V7UqrAgxC3MGQqCqA'

#systemkey
access_key = 'MDAzZTcyMTMtNGY3ZS0zMmMwLWIxZDAtYjZlM2Y1MTljNmNlIGFuZHkuYW5kZXJzb24gYW5keS5hbmRlcnNvbg';
secret_key = 'PckHXrGmx7pHzt-_-uAEBAK7fGP3dk3rI5BbVQLb5oU'

python_path = '$WORKSPACE/go/src/github.com/mobiledgex/protos:$WORKSPACE/go/src/github.com/mobiledgex/modules:$WORKSPACE/go/src/github.com/mobiledgex/certs:$WORKSPACE/go/src/github.com/mobiledgex/testcases:$WORKSPACE/go/src/github.com/mobiledgex/testcases/config'
#python_path = '/Users/andyanderson/go/src/github.com/mobiledgex/edge-cloud-qa/protos:/Users/andyanderson/go/src/github.com/mobiledgex/edge-cloud-qa/modules:/Users/andyanderson/go/src/github.com/mobiledgex/edge-cloud-qa/certs:/Users/andyanderson/go/src/github.com/mobiledgex/edge-cloud-qa/testcases'

found_failure = -1
number_failed = 0
number_passed = 0

def main():
    parser = argparse.ArgumentParser(description='copy tests to release')
    parser.add_argument('--version_from_load', action='store_true')
    args = parser.parse_args()

    num_executors = 1
    
    print(os.environ)
    cycle = os.environ['Cycle']
    version = os.environ['Version']
    project = os.environ['Project']
    #project = 'ECQ'
    #summary = os.environ['testsetname']
    component = os.environ['Components']
    #rhc = os.environ['rhc']
    workspace = os.environ['WORKSPACE']
    #httpTrace = os.environ['httpTrace']
    if 'NumberParallelExecutions' in os.environ:
        num_executors = int(os.environ['NumberParallelExecutions'])
    
    #print(httpTrace)
    #if httpTrace == 'true':
    #    httpTrace = 1
    #else:
    #    httpTrace = 0
 
    zephyrBaseUrl = "https://mobiledgex.atlassian.net/rest/zapi/latest/"

    #project = "QA"
    #cycle = "Supported"
    #version = "Automation"
    #summary = "totalplayws"
    #rhc = "tp5555555555.testlab-ncc5.com"
    #workspace = "www"
    
    #
    # setup logging
    #
    logging.basicConfig(
        level=logging.DEBUG,
        format = "%(asctime)s - %(filename)s %(funcName)s() line %(lineno)d - %(levelname)s -  - %(message)s")
        #format = "%(message)s")
    #logging.getLogger('requests.packages.urllib3.connectionpool').setLevel(logging.ERROR)
    logging.getLogger('urllib3').setLevel(logging.ERROR)
    logging.getLogger('zapi').setLevel(logging.DEBUG)
    #if verbose:
    #    logging.getLogger().setLevel(logging.DEBUG)

    #logging.info("cycle=%s version=%s project=%s summary=%s rhc=%s workspace=%s httpTrace=%s" % (cycle, version, project, summary, rhc, workspace, httpTrace))
    logging.info("cycle=%s version=%s project=%s component=%s workspace=%s" % (cycle, version, project, component, workspace))
        
    #z = zapi.Zapi(username = username, password = password)
    z = zapi.Zapi(username=username, access_key=access_key, secret_key=secret_key, debug=False)
    j = jiraapi.Jiraapi(username=username, token=jira_token)

    project_info = j.get_project(project)
    content = json.loads(project_info)
    project_id = content['id']
    version_id = None
    for v in content['versions']:
        if v['name'] == version:
            version_id = v['id']
    cycle_id = z.get_cycle_id(name=cycle, project_id=project_id, version_id=version_id)

    #z.get_server_info()
    #z.get_cycles(project_id=10006, version_id=10007)
    #sys.exit(1)
    
    # if version_from_load flag is set, copy from "Automation" to "Automation xx.yy"
    #if cycle != 'Supported' and args.version_from_load:
    #    logging.info("version_from_load flag is set. find new version")
    #    hardware,vendor,release = cycle.split('_')
    #    major_release,minor_release,sub_release = release.split('.')
    #    version = 'Automation {}.{}'.format(major_release, minor_release)
    #    logging.error("using version=%s" % version)

    #zephyrQueryUrl = zephyrBaseUrl + "zql/executeSearch?zqlQuery=" + urllib.parse.quote_plus("project=$project AND fixVersion=\"$version\" AND cycleName in (\"$cycle\") AND summary ~ \"$summary\" ORDER BY Issue ASC") + "&maxRecords=2000"
    #zephyrQueryUrl = "project=" + project + " AND fixVersion=\"" + version + "\" AND cycleName in (\"" + cycle + "\") AND summary ~ \"" + summary + "\" ORDER BY Issue ASC"
    #zephyrQueryUrl = "project=" + project
    #zephyrQueryUrl = "fixVersion=Nimbus"
    #jiraTestcaseQuery = "project=" + project + " AND fixVersion=\"" + version + "\" AND cycleName in (\"" + cycle + "\") AND summary ~ \"" + summary + "\" ORDER BY Issue ASC"
    component_list = component.split(',')
    component_query = ''
    for component in component_list:
        component_query += ' AND component = ' + component
    zephyrQueryUrl = 'project=\\\"' + project + '\\\" AND fixVersion=\\\"' + version + '\\\"' + component_query + ' ORDER BY Issue ASC'
    jiraQueryUrlPre = 'project="' + project + '" AND fixVersion="' + version + '"' + component_query
    jiraQueryUrl = jiraQueryUrlPre + ' ORDER BY Issue ASC'
        
    #zephyrQueryUrl = "project=\\\"" + project + "\\\" AND fixVersion=\\\"" + version + "\\\" AND component in (" + component + ") ORDER BY Issue ASC"
    #zephyrQueryUrl = "project=\\\"" + project + "\\\" AND fixVersion=\\\"" + version +  "\\\" ORDER BY Issue ASC"
    logging.info("zephyrQueryUrl=" + zephyrQueryUrl)

    #result = z.execute_query(zephyrQueryUrl)
    startat = 0
    maxresults = 0
    total = 1
    tc_list = []
    while (startat + maxresults) < total:
        #jiraQueryUrl = jiraQueryUrlPre + ' startAt=' + str(startat + maxresults) + ' ORDER By Issue ASC'
        result = j.search(query=jiraQueryUrl, start_at=startat+maxresults)
        #print(result)
        #sys.exit(1)
        query_content = json.loads(result)
        startat = query_content['startAt']
        maxresults = query_content['maxResults']
        total = query_content['total']
        print(startat,maxresults,total)
        #sys.exit(1)
        tc_list += get_testcases(z, result, cycle_id, project_id, version_id)

        
    print('tc_list',tc_list)
    print('lentclist', len(tc_list))
    #sys.exit(1)

    #update_defects(z, tc_list)
    #sys.exit(1)
    
    #exec_status = exec_testcases(z, tc_list, rhc, httpTrace, summary)
    exec_status = exec_testcases_parallel(z, tc_list, num_executors)
    print("exec_status=" + str(exec_status))
          
    sys.exit(exec_status)

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

def get_testcases_z(z, result, cycle):
    query_content = json.loads(result)
    tc_list = []
    
    #for s in query_content['executions']:
    for s in query_content['searchObjectList']:
        print('cycleName', s['execution']['cycleName'], cycle)
        if s['execution']['cycleName'] == cycle:
            logging.info("getting script for:" + s['issueSummary'])
            #sresult = z.get_teststeps(s['issueId'])
            sresult = z.get_teststeps(s['execution']['issueId'],s['execution']['projectId'])
            sresult_content = json.loads(sresult)
            #logging.info("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
            #logging.info("sresult=" + sresult_content)
            #logging.info("YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY")
            #logging.info("stepLength=%d" % int(len(sresult_content)))
            if sresult_content: # list is not empty;therefore, has a teststep
                logging.info("found a teststep")
                #tmp_list = {'id': s['id'], 'tc': sresult_content[0]['step'], 'issue_key': s['issueKey'], 'issue_id': s['issueId']}
                tmp_list = {'id': s['execution']['id'], 'tc': sresult_content[0]['step'], 'issue_key': s['issueKey'], 'issue_id': s['execution']['issueId'], 'defects': s['execution']['defects'], 'project_id': s['execution']['projectId'], 'version_id':s['execution']['versionId'], 'cycle_id':s['execution']['cycleId']}
                if 'totalDefectCount' in s['execution']: # totalDefectCount only exists if the test has previously been executed
                    tmp_list['defect_count'] = s['execution']['totalDefectCount']
                else:
                    tmp_list['defect_count'] = 0
                    logging.info("script is " + sresult_content[0]['step'])
            else:
                logging.info("did NOT find a teststep")
                tmp_list = {'id': s['id'], 'tc': 'noTestcaseInStep', 'issue_key': s['issueKey']}
            
            tc_list.append(tmp_list)

    return tc_list

def update_defects(z, l):
    logging.info('updating defects')
    #logging.info('execution_id=' + str(exec_id))
    for t in l:
        logging.info("checking defects for " + t['issue_key'])
        #print(t)
        #elist = z.get_execution_list(execution_id = t['issue_id'])
        #elist = z.get_execution_list(execution_id = t['id'])
        #elist_string = json.loads(elist)
        #print(elist_string)
        #execList = elist_string['executions']
        #if len(execList) > 1 and execList[1]['totalDefectCount'] > 0:
        print('t', t)
        if 'defect_count' not in t:
            t['defect_count'] = 0
        if t['defect_count'] > 0:
            #logging.info('defects found = ' + str(execList[1]['totalDefectCount']))
            logging.info('defects found = ' + str(t['defect_count']))
            #sys.exit(1)
            #previous_exec_defects = execList[1]['defects']
            previous_exec_defects = t['defects']
            print(previous_exec_defects)
            d_list = []
            for ped in previous_exec_defects:
                #print(ped['key'], ped['status'])
                print('status',ped['inwardIssue']['fields']['status']['name'])
                if ped['inwardIssue']['fields']['status']['name'] != 'Closed':
                    print(ped['inwardIssue']['key'])
                    d_list.append(ped['inwardIssue']['key'])

                    print(d_list)
                    
            logging.info('updating defect list for ' + t['issue_key'] + ' to ' + str(d_list))
            elist = z.get_execution_list(execution_id = t['issue_id'])
            elist_string = json.loads(elist)
            print(elist_string)
            execList = elist_string['executions']

            z.update_execution_details(execution_id=execList[0]['id'], defect_list = d_list)
            #time.sleep(5)
            sys.exit(1)
        else:
            logging.info('no defects found')

def find(name, path):
    logging.debug('finding file {} in {}'.format(name, path))
    for root, dirs, files in os.walk(path):
        if name in files:
            logging.debug('found {} {}'.format(root, name))
            return os.path.join(root, name)
    return 'fileNotFound'

def update_single_defect(z, t):
    print(t)
    if 'defect_count' not in t:
        t['defect_count'] = 0
    if t['defect_count'] > 0:
        #logging.info('defects found = ' + str(execList[1]['totalDefectCount']))
        logging.info('defects found = ' + str(t['defect_count']))
        #sys.exit(1)
        #previous_exec_defects = execList[1]['defects']
        previous_exec_defects = t['defects']
        print(previous_exec_defects)
        d_list = []
        for ped in previous_exec_defects:
            if 'inwardIssue' in ped:
                #print(ped['key'], ped['status'])
                print('status',ped['inwardIssue']['fields']['status']['name'])
                if ped['inwardIssue']['fields']['status']['name'] != 'Closed':
                    print(ped['inwardIssue']['key'])
                    d_list.append(ped['inwardIssue']['id'])
                
                    print(d_list)
            else:
                logging.info('not updating issue since no inwardIssue')
            
        if d_list:        
            logging.info('updating defect list for ' + t['issue_key'] + ' to ' + str(d_list))
            #elist = z.get_execution_list(execution_id = t['issue_id'])
            #elist_string = json.loads(elist)
            #print(elist_string)
            #execList = elist_string['executions']
        
            z.update_execution_details(execution_id=t['execution_id'], project_id=t['project_id'], issue_id=t['issue_id'], cycle_id=t['cycle_id'], version_id=t['version_id'], defect_list = d_list)
            #time.sleep(5)
            #sys.exit(1)
        else:
            logging.info('no defects to update, defect list is empty')
    else:
        logging.info('no defects found')

def exec_testcases_parallel(z, l, num_executors):
    global found_failure
    global number_passed
    global number_failed
    
    threads = []
    
    logging.info('number of testcases is ' + str(len(l)))
    for t in range(0, len(l), num_executors):
        print('t',t)
        plist = l[t:t+num_executors]
        logging.info('adding this many testcases:' + str(len(plist)))
        for p in plist:
            logging.info('adding thread for tc=' + p['tc'])
            thread = threading.Thread(target=exec_testcase, args=(z,p))
            threads += [thread]
            thread.start()
            time.sleep(30)  # wait between starting each testcase
            #print(l[t]['tc'],l[t+num_executors-1]['tc'])

        for x in threads:
            x.join()

    print('found_failure', found_failure)
    print('number_testcases', len(l), 'number_passed', number_passed, 'number_failed', number_failed)
    
    return found_failure
                  
def exec_testcase(z, t):
    #found_failure = -1
    global found_failure
    global number_passed
    global number_failed
    
    print('tc',t['tc'])
    last_status = 'unset'

    #print('t',t)
    #sys.exit(1)
    if t['tc'] == 'noTestcaseInStep':
        logging.info('skipping execution of {}. does not contain a testcase'.format(t['issue_key']))
        found_failure = 1  # consider it a failure if the teststep is missing
        number_failed += 1
        #continue  # go to the next testcase. probably should have put the rest of the code in else statement but this was added later
        return

    logging.info("executing " + t['issue_key'])
    print('xxxxxx',t['project_id'])
    status = z.create_execution(issue_id=t['issue_id'], project_id=t['project_id'], cycle_id=t['cycle_id'], version_id=t['version_id'], status=3)
    query_content = json.loads(status)
    status_s = json.dumps(status)

    t['execution_id'] = query_content['execution']['id']
    print('execid', t['execution_id'])

    if t['defect_count'] > 0:
        update_single_defect(z, t)

    status = z.update_status(execution_id=t['execution_id'], issue_id=t['issue_id'], project_id=t['project_id'], cycle_id=t['cycle_id'], version_id=t['version_id'], status=3)
    if 'll execution(s) were successfully updated' in status_s:
        logging.info("tc status WIP updated successful")
    else:
        logging.info("tc status WIP update FAIL")

    tc_type = ''
    tc = 'tcnotset'
    robot_tcname = None
    print(t)
    print('xxxxxxxx', t['tc'], 'bbbbbb', os.path.basename(t['tc']))
    #if '.robot' in os.path.basename(t['tc']):
    if '.robot' in t['tc']:
        tc_type = 'robot'
        tclines = t['tc'].splitlines()
        tc = tclines[0]
        if len(tclines) > 1:
            robot_tcname = tclines[1]
    elif '.tc.' in  os.path.basename(t['tc']):
        tc_type = 'python'
        tc = os.path.basename(t['tc'])
    elif '.sln' in t['tc']:
        tc_type = 'csharp'
        tc = t['tc']
    else:
        tc = os.path.basename(t['tc'])

    #os.environ['AUTOMATION_IP'] = rhc
    #tmpdir = os.environ['TMPDIR']
    tmpdir = '/tmp/'
    tc_replace = tc.replace('/','')  # remove slash from filename
    file_delete = tmpdir + os.environ['Cycle'] + "_" + tc_replace + "_" + t['issue_key'] + "*"
    file_output = tmpdir + os.environ['Cycle'] + "_" + tc_replace + "_" + t['issue_key'] + "_" + str(int(time.time()))
    file_extension = '.txt'

    # delete old files since /tmp eventually gets filled up
    delete_cmd = "rm -f " + file_delete
    logging.info("deleting " + delete_cmd)
    subprocess.run(delete_cmd, shell=True, check=True)

    #exec_cmd = "export AUTOMATION_RHCIP=" + rhc + ";./" + t['tc'] + " " +  t['issue_key'] + " > " + file_output + " 2>&1"
    if tc_type == 'robot':
        robot_file = find(tc, os.environ['WORKSPACE'])
        #exec_cmd = "export AUTOMATION_HTTPTRACE=" + str(httpTrace) + ";export AUTOMATION_RHCIP=" + rhc + ";robot --outputdir /tmp ./" + os.path.basename(t['tc'])
        xml_output = file_output + '.xml'
        var_cmd = ''
        variable_file = ''
        if 'VariableFile' in os.environ:
            variable_file = os.environ['VariableFile']
        if len(variable_file) > 0:
            variable_file_full = find(variable_file, os.environ['WORKSPACE'])
            var_cmd = f'--variablefile {variable_file_full}'
        if robot_tcname:
            exec_cmd = 'export PYTHONPATH=' + python_path + ';robot --loglevel TRACE ' + var_cmd + ' --outputdir /tmp --output ' + xml_output + ' --log ' + file_output + ' -t \"' + robot_tcname + '\" ' + robot_file
        else:
            exec_cmd = "export AUTOMATION_HTTPTRACE=" + str(httpTrace) + ";export AUTOMATION_RHCIP=" + rhc + ";robot --outputdir /tmp --output " + xml_output + " --log " + file_output + " ./" + tc
        #file_output = '/tmp/log.html'
        file_extension = '.html'
    elif tc_type == 'python':
        exec_cmd = 'export PYTHONPATH=' + python_path + ';python3 -m unittest ' + tc + ' > ' + file_output + ' 2>&1'
    elif tc_type == 'csharp':
        dirname,solutionname = tc.split('/')
        tc_file = find(solutionname, os.environ['WORKSPACE'])
        dll = os.path.dirname(tc_file) + f'/{dirname}/bin/Release/netcoreapp2.1/{dirname}.dll'
        csproj = os.path.dirname(tc_file) + f'/{dirname}/{dirname}.csproj'
        exec_cmd = f'dotnet clean {csproj} && dotnet build {tc_file} -c Release /p:Version=1.0 && dotnet {dll} > {file_output} 2>&1'
    else:
        exec_cmd = "export AUTOMATION_HTTPTRACE=" + str(httpTrace) + ";export AUTOMATION_RHCIP=" + rhc + ";./" + tc + " " +  t['issue_key'] + " > " + file_output + " 2>&1"
    #exec_cmd = "export AUTOMATION_IP=" + rhc + ";" + "pwd" + " > /tmp/" + file_output + " 2>&1"
    logging.info("executing " + exec_cmd)
    try:
        r = subprocess.run(exec_cmd, shell=True, check=True)
        status = z.update_status(execution_id=t['execution_id'], issue_id=t['issue_id'], project_id=t['project_id'], cycle_id=t['cycle_id'], version_id=t['version_id'], status=1)
        #status = z.create_execution(issue_id=t['issue_id'], project_id=t['project_id'], cycle_id=t['cycle_id'], version_id=t['version_id'], status=1)
        last_status = 'pass'
        if found_failure == -1:
            found_failure = 0
            number_passed += 1
    except subprocess.CalledProcessError as err:
        #print(err)
        found_failure = 1
        number_failed += 1
        logging.info("exec cmd failed. return code=: " + str(err.returncode))
        logging.info("exec cmd failed. stdout=: " + str(err.stdout))
        logging.info("exec cmd failed. stderr=: " + str(err.stderr))
        status = z.update_status(execution_id=t['execution_id'], issue_id=t['issue_id'], project_id=t['project_id'], cycle_id=t['cycle_id'], version_id=t['version_id'], status=2)
        #status = z.create_execution(issue_id=t['issue_id'], project_id=t['project_id'], cycle_id=t['cycle_id'], version_id=t['version_id'], status=2)
        last_status = 'fail'

    try:
        file_output_done = file_output + '_' + str(int(time.time())) + file_extension
        # add ending timestamp to file
        mv_cmd = 'mv {} {}'.format(file_output, file_output_done)
        logging.info("moving " + mv_cmd)
        r = subprocess.run(mv_cmd, shell=True, check=True)
    except subprocess.CalledProcessError as err:
        logging.info("mv cmd failed. return code=: " + str(err.returncode))
        logging.info("mv cmd failed. stdout=: " + str(err.stdout))
        logging.info("mv cmd failed. stderr=: " + str(err.stderr))

    # zip output
    #try:
    #    zip_cmd = 'gzip {}'.format(file_output_done)
    #    logging.info("zipping " + zip_cmd)
    #    r = subprocess.run(zip_cmd, shell=True, check=True)
    #except subprocess.CalledProcessError as err:
    #    logging.info("gz cmd failed. return code=: " + str(err.returncode))
    #    logging.info("gz cmd failed. stdout=: " + str(err.stdout))
    #    logging.info("gz cmd failed. stderr=: " + str(err.stderr))

    # add output file to jira
    #z.add_attachment(id=t['id'], file=file_output_done)
    if os.path.isfile(file_output_done):
        z.add_attachment(id=t['execution_id'], issue_id=t['issue_id'], project_id=t['project_id'], version_id=t['version_id'], cycle_id=t['cycle_id'], file=file_output_done)
    else:
        logging.error('ERROR adding attachment. file {} does not exist'.format(file_output_done))

    #rename trace file to pass or fail for easier debugging
    try:
        mv_cmd = 'mv {} {}.{}'.format(file_output_done, file_output_done, last_status)
        logging.info("moving " + mv_cmd)
        r = subprocess.run(mv_cmd, shell=True, check=True)
    except subprocess.CalledProcessError as err:
        logging.info("mv cmd failed. return code=: " + str(err.returncode))
        logging.info("mv cmd failed. stdout=: " + str(err.stdout))
        logging.info("mv cmd failed. stderr=: " + str(err.stderr))

    # add output file to jira
    #z.add_attachment(id=t['id'], file=file_output_done)

    #if os.path.isfile(t['tc']) and os.access(t['tc'], os.X_OK):
    #else:
    #    print("test case does not exist or not executable, failing tcid=" + t['issue_key'] + " " + t['tc'])
    #    status = z.update_status(t['id'], 2)

    #print(r)

    #sys.exit(1)
    #return found_failure
    
if __name__ == '__main__':
    main()
