#!/usr/bin/python3

import sys
import os
import glob
import threading

import zapi
import jiraapi
import logging
import json
import time
import subprocess
import argparse
import html
import itertools
import re

username = 'andy.anderson@mobiledgex.com'
# jira_token = 'cop6UQnmK4mwodXzijsY407F'
jira_token = 'Qoi6yaqSNTvjdyJAhgNz1AE4'
# userkey
# access_key = 'MDAzZTcyMTMtNGY3ZS0zMmMwLWIxZDAtYjZlM2Y1MTljNmNlIGFuZHkuYW5kZXJzb24gVVNFUl9ERUZBVUxUX05BTUU'
# secret_key = 'S_KlvniknmZ1EPVVJij70fIsm8V7UqrAgxC3MGQqCqA'

# systemkey
# access_key = 'MDAzZTcyMTMtNGY3ZS0zMmMwLWIxZDAtYjZlM2Y1MTljNmNlIGFuZHkuYW5kZXJzb24gYW5keS5hbmRlcnNvbg';
# secret_key = 'PckHXrGmx7pHzt-_-uAEBAK7fGP3dk3rI5BbVQLb5oU'
accountid = '5b85c5f93cee7729fa0660a8'
access_key = 'MDAzZTcyMTMtNGY3ZS0zMmMwLWIxZDAtYjZlM2Y1MTljNmNlIDViODVjNWY5M2NlZTc3MjlmYTA2NjBhOCBVU0VSX0RFRkFVTFRfTkFNRQ'
secret_key = '_1x9j2jdzPGHmpQTs9myoiz76wFTl1f_MC3iBXP0mFg'

python_path = '$WORKSPACE/go/src/github.com/mobiledgex/protos:$WORKSPACE/go/src/github.com/mobiledgex/modules:$WORKSPACE/go/src/github.com/mobiledgex/certs:$WORKSPACE/go/src/github.com/mobiledgex/testcases:$WORKSPACE/go/src/github.com/mobiledgex/testcases/config'
# python_path = '/Users/andyanderson/go/src/github.com/mobiledgex/edge-cloud-qa/protos:/Users/andyanderson/go/src/github.com/mobiledgex/edge-cloud-qa/modules:/Users/andyanderson/go/src/github.com/mobiledgex/edge-cloud-qa/certs:/Users/andyanderson/go/src/github.com/mobiledgex/edge-cloud-qa/testcases'

found_failure = -1
number_failed = 0
number_passed = 0
delay_between_tests = 10
testcase_timeout = '60m'

crm_pool_round_robin = None
crm_pool_var = None

logger = logging.getLogger(__name__)
logging.basicConfig(
    level=logging.DEBUG,
    format="%(asctime)s - %(filename)s %(funcName)s() line %(lineno)d - %(levelname)s -  - %(message)s")
logging.getLogger('urllib3').setLevel(logging.ERROR)
logging.getLogger('zapi').setLevel(logging.DEBUG)


def main():
    starttime = time.time()

    parser = argparse.ArgumentParser(description='copy tests to release')
    parser.add_argument('--version_from_load', action='store_true')
    parser.add_argument('--failed_only', action='store_true')

    args = parser.parse_args()

    num_executors = 1

    global crm_pool_round_robin
    global crm_pool_var

    print(os.environ)
    cycle = os.environ['Cycle']
    version = os.environ['Version']
    project = os.environ['Project']
    folder = None
    component = os.environ['Components']
    crm_pool_name = 'CRMPool'
    if 'Platform' in os.environ:
        component = component + ' ,' + os.environ['Platform']
        folder = os.environ['Platform'].lower()
        crm_pool_name = crm_pool_name + os.environ['Platform']
    if 'Folder' in os.environ:
        folder = os.environ['Folder']

    workspace = os.environ['WORKSPACE']
    # httpTrace = os.environ['httpTrace']
    if 'NumberParallelExecutions' in os.environ:
        num_executors = int(os.environ['NumberParallelExecutions'])

    # export CRMPool="{\"cloudlet_name_openstack_shared\":[{\"cloudlet\":\"automationHamburgCloudlet\",\"operator\":\"TDG\",\"region\":\"EU\"},{\"cloudlet\":\"packet-qaregression\",\"operator\":\"packet\",\"region\":\"US\"},{\"cloudlet\":\"automationDusseldorfCloudlet\",\"operator\":\"TDG\",\"region\":\"EU\"}]}"
    crm_pool_dict = None
    if crm_pool_name in os.environ:
        try:
            crm_pool_dict = json.loads(os.environ[crm_pool_name])
            logging.info(f'crm_pool_dict={crm_pool_dict}')
        except Exception as e:
            logging.error(f'error loading CRMPool:{e}')
            sys.exit(1)
        crm_pool_var = list(crm_pool_dict)[0]
        crm_pool_round_robin = itertools.cycle(crm_pool_dict[list(crm_pool_dict)[0]])

    # if httpTrace == 'true':
    #     httpTrace = 1
    # else:
    #     httpTrace = 0

    # zephyrBaseUrl = "https://mobiledgex.atlassian.net/rest/zapi/latest/"

    logger.info(f'cycle={cycle} version={version} project={project} folder={folder} component={component} numexecutors={num_executors} workspace={workspace} cmrpool={crm_pool_dict} crm_pool_round_robin={crm_pool_round_robin}')

    z = zapi.Zapi(username=accountid, access_key=access_key, secret_key=secret_key, debug=False)
    j = jiraapi.Jiraapi(username=username, token=jira_token)

    project_info = j.get_project(project)
    content = json.loads(project_info)
    project_id = content['id']
    version_id = None
    for v in content['versions']:
        if v['name'] == version:
            version_id = v['id']
    cycle_id = z.get_cycle_id(name=cycle, project_id=project_id, version_id=version_id)
    if not cycle_id:
        logger.error(f'cycle id not for found for cycle={cycle}')
        sys.exit(1)

    folder_id = None
    if folder:
        folder_id = z.get_folder_id(name=folder, project_id=project_id, version_id=version_id, cycle_id=cycle_id)
        if not folder_id:
            logger.error(f'folder id not for found for folder={folder}')
            sys.exit(1)

    # zephyrQueryUrl = zephyrBaseUrl + "zql/executeSearch?zqlQuery=" + urllib.parse.quote_plus("project=$project AND fixVersion=\"$version\" AND cycleName in (\"$cycle\") AND summary ~ \"$summary\" ORDER BY Issue ASC") + "&maxRecords=2000"
    # zephyrQueryUrl = "project=" + project + " AND fixVersion=\"" + version + "\" AND cycleName in (\"" + cycle + "\") AND summary ~ \"" + summary + "\" ORDER BY Issue ASC"
    # zephyrQueryUrl = "project=" + project
    # zephyrQueryUrl = "fixVersion=Nimbus"
    # jiraTestcaseQuery = "project=" + project + " AND fixVersion=\"" + version + "\" AND cycleName in (\"" + cycle + "\") AND summary ~ \"" + summary + "\" ORDER BY Issue ASC"
    component_list = component.split(',')
    component_query = ''
    z_component_query = ''
    for component in component_list:
        component_query += f' AND component = \"{component.strip()}\"'
        z_component_query += f' AND component = \\\"{component.strip()}\\\"'

    zephyrQueryUrl = 'project=\\\"' + project + '\\\" AND fixVersion=\\\"' + version + '\\\"' + component_query + ' ORDER BY Issue ASC'
    jiraQueryUrlPre = 'project="' + project + '" AND fixVersion="' + version + '"' + component_query

    if args.failed_only:
        logger.info('Only executing failed testcases')
        zephyrQueryUrl = f'project=\\\"edge-cloud QA\\\" AND fixVersion=\\\"{version}\\\"{z_component_query} AND cycleName=\\\"{cycle}\\\" AND executionStatus=Fail ORDER BY Issue ASC'
        failed_tcids = get_zephyr_failed_testcases(z, zephyrQueryUrl, zephyrQueryUrl)
        if len(failed_tcids) <= 0:
            failed_tcids = ['EC-1']
        jiraQueryUrlPre += ' AND key in ('
        for key in failed_tcids:
            jiraQueryUrlPre += f'{key},'
        jiraQueryUrlPre = re.sub(r',$', '', jiraQueryUrlPre)
        jiraQueryUrlPre += ')'

    jiraQueryUrl = jiraQueryUrlPre + ' ORDER BY Issue ASC'

    logger.info("zephyrQueryUrl=" + zephyrQueryUrl)

    # result = z.execute_query(zephyrQueryUrl)
    startat = 0
    maxresults = 0
    total = 1
    tc_list = []
    while (startat + maxresults) < total:
        # jiraQueryUrl = jiraQueryUrlPre + ' startAt=' + str(startat + maxresults) + ' ORDER By Issue ASC'
        result = j.search(query=jiraQueryUrl, start_at=startat + maxresults)
        query_content = json.loads(result)
        startat = query_content['startAt']
        maxresults = query_content['maxResults']
        total = query_content['total']
        print(startat, maxresults, total)
        tc_list += get_testcases(z, result, cycle_id, project_id, version_id, folder_id)

    print('tc_list', tc_list)
    print('lentclist', len(tc_list))

    # exec_status = exec_testcases(z, tc_list, rhc, httpTrace, summary)
    exec_status = exec_testcases_parallel(z, tc_list, num_executors, args.failed_only)
    logger.info("exec_status=" + str(exec_status))

    endtime = time.time()
    logger.info(f'test duration is {(endtime-starttime)/60} minutes')

    sys.exit(exec_status)


def get_zephyr_failed_testcases(z, url, query):
    print(f'execututing zephyr query={query}')
    total_count = 9999999
    num_returned = 0
    total_returned = 0
    tc_list = []
    while total_returned < total_count:
        result = z.execute_query(url, offset=total_returned)
        query_content = json.loads(result)
        total_count = query_content['totalCount']
        num_returned = len(query_content['searchObjectList'])
        total_returned += num_returned

        for exec in query_content['searchObjectList']:
            print(f"tcid={exec['issueKey']} defects={exec['execution']['defects']}")
            if len(exec['execution']['defects']) == 0:
                tc_list.append(exec['issueKey'])
            else:
                tc_list.append(exec['issueKey'])
                for defect in exec['execution']['defects']:
                    if defect['status']['name'] != 'Closed' and defect['status']['name'] != 'Ready To Verify':
                        tc_list.pop()
                        break

    print(f'found {len(tc_list)} failed testcases')

    return tc_list


def get_testcases(z, result, cycle_id, project_id, version_id, folder_id):
    query_content = json.loads(result)
    tc_list = []

    for s in query_content['issues']:
        print('issueKey', s['key'])
        logger.info("getting script for:" + s['key'])
        sresult = z.get_teststeps(s['id'], s['fields']['project']['id'])
        sresult_content = json.loads(sresult)

        if sresult_content:  # list is not empty;therefore, has a teststep
            logger.info("found a teststep")
            # tmp_list = {'id': s['id'], 'tc': sresult_content[0]['step'], 'issue_key': s['issueKey'], 'issue_id': s['issueId']}
            # tmp_list = {'id': s['execution']['id'], 'tc': sresult_content[0]['step'], 'issue_key': s['issueKey'], 'issue_id': s['execution']['issueId'], 'defects': s['execution']['defects'], 'project_id': s['execution']['projectId'], 'version_id':s['execution']['versionId'], 'cycle_id':s['execution']['cycleId']}
            tmp_list = {'tc': sresult_content[0]['step'], 'issue_key': s['key'], 'issue_id': s['id'], 'project_id': project_id, 'version_id': version_id, 'cycle_id': cycle_id, 'folder_id': folder_id, 'defects': s['fields']['issuelinks']}
            print(s)
            tmp_list['defect_count'] = len(s['fields']['issuelinks'])  # need to check for issueslink section
            # if 'totalDefectCount' in s['execution']: # totalDefectCount only exists if the test has previously been executed
            #     tmp_list['defect_count'] = s['execution']['totalDefectCount']
            # else:
            #     tmp_list['defect_count'] = 0
            logger.info("script is " + sresult_content[0]['step'])
        else:
            logger.info("did NOT find a teststep")
            tmp_list = {'id': s['id'], 'tc': 'noTestcaseInStep', 'issue_key': s['key']}

        tc_list.append(tmp_list)
    print(tc_list)

    return tc_list


def get_testcases_z(z, result, cycle):
    query_content = json.loads(result)
    tc_list = []

    for s in query_content['searchObjectList']:
        print('cycleName', s['execution']['cycleName'], cycle)
        if s['execution']['cycleName'] == cycle:
            logger.info("getting script for:" + s['issueSummary'])
            # sresult = z.get_teststeps(s['issueId'])
            sresult = z.get_teststeps(s['execution']['issueId'], s['execution']['projectId'])
            sresult_content = json.loads(sresult)
            # logging.info("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
            # logging.info("sresult=" + sresult_content)
            # logging.info("YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY")
            # logging.info("stepLength=%d" % int(len(sresult_content)))
            if sresult_content:  # list is not empty;therefore, has a teststep
                logger.info("found a teststep")
                # tmp_list = {'id': s['id'], 'tc': sresult_content[0]['step'], 'issue_key': s['issueKey'], 'issue_id': s['issueId']}
                tmp_list = {'id': s['execution']['id'], 'tc': sresult_content[0]['step'], 'issue_key': s['issueKey'], 'issue_id': s['execution']['issueId'], 'defects': s['execution']['defects'], 'project_id': s['execution']['projectId'], 'version_id': s['execution']['versionId'], 'cycle_id': s['execution']['cycleId']}
                if 'totalDefectCount' in s['execution']:  # totalDefectCount only exists if the test has previously been executed
                    tmp_list['defect_count'] = s['execution']['totalDefectCount']
                else:
                    tmp_list['defect_count'] = 0
                    logger.info("script is " + sresult_content[0]['step'])
            else:
                logger.info("did NOT find a teststep")
                tmp_list = {'id': s['id'], 'tc': 'noTestcaseInStep', 'issue_key': s['issueKey']}

            tc_list.append(tmp_list)

    return tc_list


# def update_defects(z, l):
#    logger.info('updating defects')
#    for t in l:
#        logger.info("checking defects for " + t['issue_key'])
#        # elist = z.get_execution_list(execution_id = t['issue_id'])
#        # elist = z.get_execution_list(execution_id = t['id'])
#        # elist_string = json.loads(elist)
#        # execList = elist_string['executions']
#        # if len(execList) > 1 and execList[1]['totalDefectCount'] > 0:
#        print('t', t)
#        if 'defect_count' not in t:
#            t['defect_count'] = 0
#        if t['defect_count'] > 0:
#            logger.info('defects found = ' + str(t['defect_count']))
#            # previous_exec_defects = execList[1]['defects']
#            previous_exec_defects = t['defects']
#            print(previous_exec_defects)
#            d_list = []
#            for ped in previous_exec_defects:
#                print('status', ped['inwardIssue']['fields']['status']['name'])
#                if ped['inwardIssue']['fields']['status']['name'] != 'Closed':
#                    print(ped['inwardIssue']['key'])
#                    d_list.append(ped['inwardIssue']['key'])
#
#                    print(d_list)
#
#            logger.info('updating defect list for ' + t['issue_key'] + ' to ' + str(d_list))
#            elist = z.get_execution_list(execution_id=t['issue_id'])
#            elist_string = json.loads(elist)
#            print(elist_string)
#            execList = elist_string['executions']
#
#            z.update_execution_details(execution_id=execList[0]['id'], defect_list=d_list)
#            #time.sleep(5)
#            sys.exit(1)
#        else:
#            logger.info('no defects found')


def find(name, path):
    logger.debug('finding file {} in {}'.format(name, path))
    for root, dirs, files in os.walk(path):
        if name in files:
            logger.debug('found {} {}'.format(root, name))
            return os.path.join(root, name)
        elif name in dirs:
            logger.debug('found directory {} {}'.format(root, name))
            return os.path.join(root, name)
    logger.error('could not find {}'.format(name))
    return 'fileNotFound'


def update_single_defect(z, t):
    print(t)
    if 'defect_count' not in t:
        t['defect_count'] = 0
    if t['defect_count'] > 0:
        logger.info('defects found = ' + str(t['defect_count']))
        # previous_exec_defects = execList[1]['defects']
        previous_exec_defects = t['defects']
        print(previous_exec_defects)
        d_list = []
        for ped in previous_exec_defects:
            if 'inwardIssue' in ped:
                print('status', ped['inwardIssue']['fields']['status']['name'])
                if ped['inwardIssue']['fields']['status']['name'] != 'Closed':
                    print(ped['inwardIssue']['key'])
                    d_list.append(ped['inwardIssue']['id'])

                    print(d_list)
            else:
                logger.info('not updating issue since no inwardIssue')

        if d_list:
            logger.info('updating defect list for ' + t['issue_key'] + ' to ' + str(d_list))
            # elist = z.get_execution_list(execution_id = t['issue_id'])
            # elist_string = json.loads(elist)
            # execList = elist_string['executions']

            z.update_execution_details(execution_id=t['execution_id'], project_id=t['project_id'], issue_id=t['issue_id'], cycle_id=t['cycle_id'], version_id=t['version_id'], defect_list=d_list)
            # time.sleep(5)
            # sys.exit(1)
        else:
            logger.info('no defects to update, defect list is empty')
    else:
        logger.info('no defects found')


def exec_testcases_parallel(z, tc_list, num_executors, failed_only):
    global found_failure
    global number_passed
    global number_failed
    global crm_pool_round_robin

    threads = []

    logger.info('number of testcases is ' + str(len(tc_list)))
    for t in range(0, len(tc_list), num_executors):
        print('t', t)
        plist = tc_list[t:t + num_executors]
        logger.info('adding this many testcases:' + str(len(plist)))
        for p in plist:
            logger.info('adding thread for tc=' + p['tc'])
            thread = threading.Thread(target=exec_testcase, args=(z, p))
            threads += [thread]
            thread.start()
            time.sleep(delay_between_tests)  # wait between starting each testcase

        for x in threads:
            x.join()

    if failed_only and len(tc_list) == 0:
        print('running failed only and found no failed testcases to execute. setting found_failure to 0')
        found_failure = 0
    print('found_failure', found_failure)
    print('number_testcases', len(tc_list), 'number_passed', number_passed, 'number_failed', number_failed)

    return found_failure


def exec_testcase(z, t):
    # found_failure = -1
    global found_failure
    global number_passed
    global number_failed
    global crm_pool_round_robin
    global crm_pool_var

    region = 'notset'
    cloudlet = 'notset'
    operator = 'notset'

    print('tc', t['tc'])
    last_status = 'unset'

    if t['tc'] == 'noTestcaseInStep':
        logger.info('skipping execution of {}. does not contain a testcase'.format(t['issue_key']))
        found_failure = 1  # consider it a failure if the teststep is missing
        number_failed += 1
        # continue  # go to the next testcase. probably should have put the rest of the code in else statement but this was added later
        return

    logger.info("executing " + t['issue_key'])
    print('xxxxxx', t['project_id'])
    status = z.create_execution(issue_id=t['issue_id'], project_id=t['project_id'], cycle_id=t['cycle_id'], version_id=t['version_id'], folder_id=t['folder_id'], status=3)
    query_content = json.loads(status)
    status_s = json.dumps(status)

    t['execution_id'] = query_content['execution']['id']
    print('execid', t['execution_id'])

    if t['defect_count'] > 0:
        update_single_defect(z, t)

    status = z.update_status(execution_id=t['execution_id'], issue_id=t['issue_id'], project_id=t['project_id'], cycle_id=t['cycle_id'], version_id=t['version_id'], status=3)
    if 'll execution(s) were successfully updated' in status_s:
        logger.info("tc status WIP updated successful")
    else:
        logger.info("tc status WIP update FAIL")

    tc_type = ''
    tc = 'tcnotset'
    robot_tcname = None
    print(t)
    print('xxxxxxxx', t['tc'], 'bbbbbb', os.path.basename(t['tc']))
    if '.robot' in t['tc'] or t['tc'].endswith('_robot'):
        tc_type = 'robot'
        tclines = t['tc'].splitlines()
        tc = tclines[0]
        if len(tclines) > 1:
            robot_tcname = tclines[1]
    elif '.tc.' in os.path.basename(t['tc']):
        tc_type = 'python'
        tc = os.path.basename(t['tc'])
    elif '.sln' in t['tc']:
        tc_type = 'csharp'
        tc = t['tc']
    elif '.cpp' in t['tc']:
        tc_type = 'cpp'
        tc = t['tc']
    else:
        tc = os.path.basename(t['tc'])

    # tmpdir = os.environ['TMPDIR']
    tmpdir = '/tmp/'
    tc_replace = tc.replace('/', '')  # remove slash from filename
    # file_delete = tmpdir + os.environ['Cycle'] + "_" + tc_replace + "_" + t['issue_key'] + "*"
    file_delete = tmpdir + "*" + t['issue_key'] + "*"
    file_output = tmpdir + os.environ['Cycle'] + "_" + tc_replace + "_" + t['issue_key'] + "_" + str(int(time.time())) + ".out"
    file_extension = '.txt'

    # delete old files since /tmp eventually gets filled up
    # delete_cmd = "rm -f " + file_delete
    logger.info("deleting " + file_delete)
    # subprocess.run(delete_cmd, shell=True, check=True)
    for f in glob.glob(file_delete):
        try:
            os.remove(f)
        except Exception as e:
            logging.info(f'remove failed:{e}')

    my_env = os.environ.copy()
    if tc_type == 'robot':
        robot_file = find(tc, os.environ['WORKSPACE'])
        xml_output = file_output + '.xml'
        var_cmd = ''
        variable_file = ''
        var_override_cmd = ''
        region = 'noCRMPoolDefined'
        cloudlet = 'noCRMPoolDefined'
        operator = 'noCRMPoolDefined'

        if 'VariableFile' in os.environ:
            variable_file = os.environ['VariableFile']
        if len(variable_file) > 0:
            variable_file_full = find(variable_file, os.environ['WORKSPACE'])
            var_cmd = f'--variablefile {variable_file_full}'
        if crm_pool_round_robin:
            print('round')
            next_crm = next(crm_pool_round_robin)
            logger.info(f'executing on pool={next_crm}')
            region = next_crm['region']
            cloudlet = next_crm['cloudlet']
            operator = next_crm['operator']
            var_override_cmd = f'--variable {crm_pool_var}:{cloudlet} --variable operator_name_openstack:{operator} --variable operator_name_crm:{operator} --variable region:{region}'

            env_file = find(f'automation_env_{region}.sh', os.environ['WORKSPACE'])
            openstack_file = find(f'openrc_{cloudlet}.mex', os.environ['WORKSPACE'])
            logger.info(f'using env_file={env_file} openstack_file={openstack_file}')

            my_env['AUTOMATION_OPENSTACK_DEDICATED_ENV'] = openstack_file
            my_env['AUTOMATION_OPENSTACK_SHARED_ENV'] = openstack_file
            my_env['AUTOMATION_OPENSTACK_VM_ENV'] = openstack_file
            my_env['AUTOMATION_OPENSTACK_GPU_ENV'] = openstack_file
            my_env['AUTOMATION_OPENSTACK_OFFLINE_ENV'] = openstack_file

            with open(env_file) as f:
                lines = f.readlines()
                for line in lines:
                    if '=' in line:
                        var, value = line.split('=')
                        value = value.strip()
                        logger.info(f'adding env {var}={value}')
                        my_env[var] = value
            logger.debug(f'my_env={my_env}')

        if robot_tcname:
            exec_cmd = f'export PYTHONPATH={python_path};robot --loglevel TRACE {var_cmd} {var_override_cmd} --outputdir /tmp --output {xml_output} --log {file_output} -t \"{robot_tcname}\" {robot_file}'
        else:
            exec_cmd = f'export PYTHONPATH={python_path};robot --loglevel TRACE {var_cmd} {var_override_cmd} --outputdir /tmp --output {xml_output} --log {file_output} {robot_file}'
        # file_output = '/tmp/log.html'
        file_extension = '.html'
    elif tc_type == 'python':
        exec_cmd = 'export PYTHONPATH=' + python_path + ';python3 -m unittest ' + tc + ' > ' + file_output + ' 2>&1'
    elif tc_type == 'csharp':
        dirname, solutionname = tc.split('/')
        tc_file = find(solutionname, os.environ['WORKSPACE'])
        dll = os.path.dirname(tc_file) + f'/{dirname}/bin/Release/netcoreapp2.1/{dirname}.dll'
        csproj = os.path.dirname(tc_file) + f'/{dirname}/{dirname}.csproj'
        exec_cmd = f'dotnet clean {csproj} && dotnet build {tc_file} -c Release /p:Version=1.0 && dotnet {dll} > {file_output} 2>&1'
    elif tc_type == 'cpp':
        dirname, cppname = tc.split('/')
        tc_file = find(cppname, os.environ['WORKSPACE'])
        exec_cmd = f'cd {os.path.dirname(tc_file)};make clean  && make && ./{dirname} > {file_output} 2>&1'
    # else:
    #    exec_cmd = "export AUTOMATION_HTTPTRACE=" + str(httpTrace) + ";export AUTOMATION_RHCIP=" + rhc + ";./" + tc + " " +  t['issue_key'] + " > " + file_output + " 2>&1"
    # exec_cmd = "export AUTOMATION_IP=" + rhc + ";" + "pwd" + " > /tmp/" + file_output + " 2>&1"
    logger.info("executing " + exec_cmd)
    try:
        exec_file = f'{file_output}.exec'
        logger.info(f'writing exec file {exec_file}')
        with open(exec_file, 'w') as f:
            f.write(exec_cmd)
    except Exception as e:
        logger.info(f'exec file write error {e}')

    exec_start = time.time()
    try:
        exec_cmd = f'timeout {testcase_timeout} bash "{exec_file}" && rm {file_output}.exec'
        logger.info("subprocess " + exec_cmd)
        r = subprocess.run(exec_cmd, shell=True, check=True, env=my_env)
        logger.info(f'subprocess returncode={r.returncode}')
        exec_stop = time.time()
        exec_duration = exec_stop - exec_start
        comment = html.escape('{"region":"' + region + '", "cloudlet":"' + cloudlet + '", "operator":"' + operator + '", "start_time":' + str(exec_start) + ', "end_time":' + str(exec_stop) + ', "duration":' + str(exec_duration) + '}')
        status = z.update_status(execution_id=t['execution_id'], issue_id=t['issue_id'], project_id=t['project_id'], cycle_id=t['cycle_id'], version_id=t['version_id'], status=1, comment=comment)
        # status = z.create_execution(issue_id=t['issue_id'], project_id=t['project_id'], cycle_id=t['cycle_id'], version_id=t['version_id'], status=1)
        logger.info(f'test passed:{t["issue_key"]} number_passed={number_passed} number_failed={number_failed}')
        last_status = 'pass'
        if found_failure == -1:
            found_failure = 0
        number_passed += 1
    except subprocess.CalledProcessError as err:
        exec_stop = time.time()
        exec_duration = exec_stop - exec_start
        # comment = html.escape('{"start_time":' + str(exec_start) + ', "end_time":' + str(exec_stop) + ', "duration":' + str(exec_duration) + '}')
        comment = html.escape('{"region":"' + region + '", "cloudlet":"' + cloudlet + '", "operator":"' + operator + '", "start_time":' + str(exec_start) + ', "end_time":' + str(exec_stop) + ', "duration":' + str(exec_duration) + '}')
        logger.info('test failed:' + t['issue_key'])
        found_failure = 1
        number_failed += 1
        logger.info("exec cmd failed. return code=: " + str(err.returncode))
        logger.info("exec cmd failed. stdout=: " + str(err.stdout))
        logger.info("exec cmd failed. stderr=: " + str(err.stderr))
        status = z.update_status(execution_id=t['execution_id'], issue_id=t['issue_id'], project_id=t['project_id'], cycle_id=t['cycle_id'], version_id=t['version_id'], status=2, comment=comment)
        # status = z.create_execution(issue_id=t['issue_id'], project_id=t['project_id'], cycle_id=t['cycle_id'], version_id=t['version_id'], status=2)
        last_status = 'fail'

    try:
        file_output_done = file_output + '_' + str(int(time.time())) + file_extension
        # add ending timestamp to file
        mv_cmd = 'mv {} {}'.format(file_output, file_output_done)
        logger.info("moving " + mv_cmd)
        r = subprocess.run(mv_cmd, shell=True, check=True)
    except subprocess.CalledProcessError as err:
        logger.info("mv cmd failed. return code=: " + str(err.returncode))
        logger.info("mv cmd failed. stdout=: " + str(err.stdout))
        logger.info("mv cmd failed. stderr=: " + str(err.stderr))

    # zip output
    # try:
    #    zip_cmd = 'gzip {}'.format(file_output_done)
    #    logging.info("zipping " + zip_cmd)
    #    r = subprocess.run(zip_cmd, shell=True, check=True)
    # except subprocess.CalledProcessError as err:
    #    logging.info("gz cmd failed. return code=: " + str(err.returncode))
    #    logging.info("gz cmd failed. stdout=: " + str(err.stdout))
    #    logging.info("gz cmd failed. stderr=: " + str(err.stderr))

    # add output file to jira
    # z.add_attachment(id=t['id'], file=file_output_done)
    if os.path.isfile(file_output_done):
        z.add_attachment(id=t['execution_id'], issue_id=t['issue_id'], project_id=t['project_id'], version_id=t['version_id'], cycle_id=t['cycle_id'], file=file_output_done)
    else:
        logger.error('ERROR adding attachment. file {} does not exist'.format(file_output_done))

    # rename trace file to pass or fail for easier debugging
    try:
        mv_cmd = 'mv {} {}.{}'.format(file_output_done, file_output_done, last_status)
        logger.info("moving " + mv_cmd)
        r = subprocess.run(mv_cmd, shell=True, check=True)
    except subprocess.CalledProcessError as err:
        logger.info("mv cmd failed. return code=: " + str(err.returncode))
        logger.info("mv cmd failed. stdout=: " + str(err.stdout))
        logger.info("mv cmd failed. stderr=: " + str(err.stderr))

    # add output file to jira
    # z.add_attachment(id=t['id'], file=file_output_done)

    # if os.path.isfile(t['tc']) and os.access(t['tc'], os.X_OK):
    # else:
    #    print("test case does not exist or not executable, failing tcid=" + t['issue_key'] + " " + t['tc'])
    #    status = z.update_status(t['id'], 2)

    # sys.exit(1)
    # return found_failure


if __name__ == '__main__':
    main()
