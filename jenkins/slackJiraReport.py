import os
#from flask import Flask, request
from slackclient import SlackClient
import argparse
import json
import logging
import sys

import zapi
import jiraapi

zephyrBaseUrl = "https://mobiledgex.atlassian.net/rest/zapi/latest/"
username = 'andy.anderson@mobiledgex.com'
access_key = '***REMOVED***'
secret_key = '***REMOVED***'
jira_token = '***REMOVED***'

#project_name = 'ECQ'
#version_name = 'Nimbus'
#cycle_name = 'Nimbus_automation_20181229'

parser = argparse.ArgumentParser(description='post jira automation report to slack')
parser.add_argument('--version', default='Nimbus', help='jira version. default is \'Nimbus\'')
parser.add_argument('--project', default='ECQ', help='jira project. default is \'ECQ\'')
parser.add_argument('--cycle', help='jira cycle. no default')

args = parser.parse_args()

project_name = args.project
version_name = args.version
cycle_name = args.cycle

logging.basicConfig(
    level=logging.DEBUG,
    format = "%(asctime)s - %(filename)s %(funcName)s() line %(lineno)d - %(levelname)s -  - %(message)s")
logging.getLogger('urllib3').setLevel(logging.ERROR)
logging.getLogger('zapi').setLevel(logging.DEBUG)

z = zapi.Zapi(username=username, access_key=access_key, secret_key=secret_key, debug=True)
j = jiraapi.Jiraapi(username=username, token=jira_token)

api_token = '***REMOVED***'
channel_id = 'DF3JVL43W'

# appid = AF3JU3F0U
client_id = '313978814983.513640117028'
client_secret = 'd0a665344a7d8f0d6333d6a5d794e24e'
oauth_scope = 'chat:write:bot'

#app = Flask(__name__)
#@app.route("/begin_auth", methods=["GET"])
#def pre_install():
#  return '''
#      <a href="https://slack.com/oauth/authorize?scope={0}&client_id={1}">
#          Add to Slack
#      </a>
#  '''.format(oauth_scope, client_id)

# signing_secret = ***REMOVED***
# verification_token = ***REMOVED***

#client_id = os.environ["SLACK_CLIENT_ID"]
#client_secret = os.environ["SLACK_CLIENT_SECRET"]
#oauth_scope = os.environ["SLACK_BOT_SCOPE"]

#slack_token = os.environ["SLACK_API_TOKEN"]
slack_token = api_token
sc = SlackClient(slack_token)

project_info = j.get_project(project_name)
content = json.loads(project_info)
project_id = content['id']
version_id = None
for v in content['versions']:
    if v['name'] == version_name:
        version_id = v['id']
print('p', project_id)
#version_id = z.get_version_id(project_id, version)
logging.info("project_id=%s version_id=%s" % (project_id, version_id))

cycle_id = z.get_cycle_id(name=cycle_name, project_id=project_id, version_id=version_id)


jiraQueryUrl = 'project="' + project_name + '" AND fixVersion="' + version_name + '" ORDER BY Issue ASC'
offset = 0
max_allowed = 0
total_count = 1
total_counted = 0
total_pass = 0
total_fail = 0
total_fail_bugs = 0
total_fail_nobugs = 0
total_unexecuted = 0
total_wip = 0
total_blocked = 0
total_na = 0
total_wontexec = 0
offset = 0
unexecuted_string = ''
failed_string = ''
failed_bugs_string = ''
failed_nobugs_string = ''
while offset < total_count:
    result = z.get_execution_list_by_cycleid(cycle_id=cycle_id, version_id=version_id,  project_id=project_id, offset=offset)
    query_content = json.loads(result)

    print('length',len(query_content['searchObjectList']))
    
    total_count =  query_content['totalCount']
    #max_allowed =  query_content['maxAllowed']
    #offset = query_content['currentOffset'] + query_content['maxAllowed']
    offset = offset + query_content['maxAllowed']
    for tc in query_content['searchObjectList']:
        print(tc['issueKey'], tc['execution']['status']['name'], tc['execution']['defects'])
        if tc['execution']['status']['name'] == 'PASS': total_pass += 1
        if tc['execution']['status']['name'] == 'FAIL':
            total_fail += 1
            if len(tc['execution']['defects']) == 0:
                total_fail_nobugs += 1
                failed_nobugs_string += tc['issueKey'] + '\t' +  tc['issueSummary'] + '\n'
            else:
                failed_bugs_string += tc['issueKey'] + '\t' +  tc['issueSummary'] + '\n'
            failed_string +=  tc['issueKey'] + '\t' + tc['issueSummary'] + '\n'
        if tc['execution']['status']['name'] == 'UNEXECUTED':
            total_unexecuted += 1
            unexecuted_string += tc['issueKey'] + '\t' +  tc['issueSummary'] + '\n'
            
        total_counted += 1
    
print('totalcount', total_count, 'totalcounted', total_counted, 'pass', total_pass, 'fail', total_fail, 'unexec', total_unexecuted)


report_string = f'Cycle:\t{cycle_name}\n\n'
report_string += f'Total TCs:\t\t{total_counted}\n'
report_string += f'Total Passed:\t\t{total_pass}\t{(total_pass/total_counted)*100:.2f}%\n'
report_string += f'Total Failed:\t\t{total_fail}\t{(total_fail/total_counted)*100:.2f}%\n'
report_string += f'Total Failed w/bugs:\t{total_fail_bugs}\t{(total_fail_bugs/total_counted)*100:.2f}%\n'
report_string += f'Total Failed wo/bugs:\t{total_fail_nobugs}\t{(total_fail_nobugs/total_counted)*100:.2f}%\n'
report_string += f'Total Unexec:\t\t{total_unexecuted}\t{(total_unexecuted/total_counted)*100:.2f}%\n'
report_string += f'Total WIP:\t\t{total_wip}\t{(total_wip/total_counted)*100:.2f}%\n'
report_string += f'Total Blocked:\t\t{total_blocked}\t{(total_blocked/total_counted)*100:.2f}%\n'
report_string += f'Total NA:\t\t{total_na}\t{(total_na/total_counted)*100:.2f}%\n'
report_string += f'Total WontExec:\t\t{total_wontexec}\t{(total_wontexec/total_counted)*100:.2f}%\n'

if total_count != total_counted:
    report_string += f'WARNING - total count did not add up. counted={total_counted} expected={total_count}\n'
if (total_pass + total_fail + total_unexecuted + total_wip + total_blocked + total_na + total_wontexec) != total_counted:
    report_string += f'WARNING - sum of exectution types did not add up. counted={total_pass + total_fail + total_unexecuted + total_wip + total_blocked + total_na + total_wontexec} expected={total_counted}\n'

report_string += '\n\n\nFailed testcases without bugs:\n' + failed_nobugs_string
report_string += '\n\n\nFailed testcases with bugs:\n' + failed_bugs_string
report_string += '\n\n\nUnexecuted testcases:\n' + unexecuted_string

print(report_string)
#sys.exit(1)

sc.api_call(
    "chat.postMessage",
    channel="DF3JVL43W",
    #text="Hello from Python! :tada:"
    text=report_string
)
