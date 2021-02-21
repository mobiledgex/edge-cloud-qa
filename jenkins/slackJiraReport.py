import os
#from flask import Flask, request
#from slackclient import SlackClient
from slack import WebClient
from slack.errors import SlackApiError
import argparse
import json
import logging
import sys

import zapi
import jiraapi

channel_number = 'CF67W3QH5'
#channel_number = 'DF3JVL43W'

zephyrBaseUrl = "https://mobiledgex.atlassian.net/rest/zapi/latest/"
username = 'andy.anderson@mobiledgex.com'
#access_key = 'MDAzZTcyMTMtNGY3ZS0zMmMwLWIxZDAtYjZlM2Y1MTljNmNlIGFuZHkuYW5kZXJzb24gVVNFUl9ERUZBVUxUX05BTUU'
#secret_key = 'S_KlvniknmZ1EPVVJij70fIsm8V7UqrAgxC3MGQqCqA'

#systemkey
#access_key = 'MDAzZTcyMTMtNGY3ZS0zMmMwLWIxZDAtYjZlM2Y1MTljNmNlIGFuZHkuYW5kZXJzb24gYW5keS5hbmRlcnNvbg';
#secret_key = 'PckHXrGmx7pHzt-_-uAEBAK7fGP3dk3rI5BbVQLb5oU'
accountid = '5b85c5f93cee7729fa0660a8'
access_key = 'MDAzZTcyMTMtNGY3ZS0zMmMwLWIxZDAtYjZlM2Y1MTljNmNlIDViODVjNWY5M2NlZTc3MjlmYTA2NjBhOCBVU0VSX0RFRkFVTFRfTkFNRQ'
secret_key = '_1x9j2jdzPGHmpQTs9myoiz76wFTl1f_MC3iBXP0mFg'

jira_token = 'Qoi6yaqSNTvjdyJAhgNz1AE4'

#project_name = 'ECQ'
#version_name = 'Nimbus'
#cycle_name = 'Nimbus_automation_20181229'

parser = argparse.ArgumentParser(description='post jira automation report to slack')
parser.add_argument('--version', default='Nimbus', help='jira version. default is \'Nimbus\'')
parser.add_argument('--project', default='ECQ', help='jira project. default is \'ECQ\'')
parser.add_argument('--cycle', help='jira cycle. no default')
parser.add_argument('--folder', default=None, help='jira folder under the cycle. no default')
parser.add_argument('--jobduration', default=0, help='duration of job. default is 0')
parser.add_argument('--summaryonly', action='store_true', help='print summary only')
parser.add_argument('--cyclesummary', action='store_true', help='print cycle summary of all folders only')
parser.add_argument('--slack', action='store_true', help='print report to slack')

args = parser.parse_args()

project_name = args.project
version_name = args.version
cycle_name = args.cycle
job_duration = int(args.jobduration)
folder_name = args.folder
summary_only = args.summaryonly
slack = args.slack
cycle_summary = args.cyclesummary

logging.basicConfig(
    level=logging.DEBUG,
    format = "%(asctime)s - %(filename)s %(funcName)s() line %(lineno)d - %(levelname)s -  - %(message)s")
logging.getLogger('urllib3').setLevel(logging.ERROR)
logging.getLogger('zapi').setLevel(logging.DEBUG)

#def build_report_blocks(project_id, version, cycle_name, cycle_summary=None, folder_name=None):
def build_report_blocks():
    report_url = f'https://mobiledgex.atlassian.net/plugins/servlet/ac/com.thed.zephyr.je/general-executions-enav?project.id={project_id}6#!view=list&offset=0&zql=project%20%3D%20%22edge-cloud%20QA%22%20AND%20fixVersion%20%3D%20%22{version_name}%22%20AND%20cycleName%20in%20(%22{cycle_name}%22)'
    if folder_name:
        report_url += f'%20AND%20folderName%20in%20(%22{folder_name}%22)'
    status_url = report_url + '%20AND%20executionStatus%20%3D%20'
    fail_url = status_url + 'FAIL'
    pass_url = status_url + 'PASS'
    wip_url = status_url + 'WIP'
    blocked_url = status_url + 'BLOCKED'
    unexecuted_url = status_url + 'UNEXECUTED'

    if folder_name:
        title = f'Automation {folder_name} Report for {cycle_name}'
    else:
        title = f'Automation Summary Report for {cycle_name}'

    total_string = f'*Total TCs:* <{report_url}|{total_counted}>'
    pass_string =  f'*Total Passed:* <{pass_url}|{total_pass}>   {pass_perc}%'
    fail_string =  f'*Total Failed:* <{fail_url}|{total_fail}>   {fail_perc}%'
    if not cycle_summary: fail_string += f'\\n*Total Failed w/bugs:* {total_fail_bugs}   {fail_bugs_perc}%'
    if not cycle_summary: fail_string += f'\\n*Total Failed wo/bugs:* {total_fail_nobugs}   {fail_nobugs_perc}%'
    unexec_string =  f'*Total Unexec:* <{unexecuted_url}|{total_unexecuted}>   {unexec_perc}%'
    wip_string =     f'*Total WIP:* <{wip_url}|{total_wip}>   {wip_perc}%'
    blocked_string = f'*Total Blocked:* <{blocked_url}|{total_blocked}>   {blocked_perc}%'
       
    block = f'''[
                  {{
                     "type": "header",
                     "text": {{
                        "type": "plain_text",
                        "text": "{title}"
                     }}
                  }},
                  {{
                     "type": "section",
                     "text": {{
                        "type": "mrkdwn",
                        "text": "{total_string}\\n{pass_string}\\n{fail_string}\\n{unexec_string}\\n{wip_string}\\n{blocked_string}"

			}}
		}}]'''

    print('block', block)

    return block

z = zapi.Zapi(username=accountid, access_key=access_key, secret_key=secret_key, debug=True)
j = jiraapi.Jiraapi(username=username, token=jira_token)

api_token = 'xoxb-313978814983-514011267477-U1J6wkdyA1lSRmTakKQ27R8e'
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

# signing_secret = 6a3ca8f7241de0a0d095fa35046a6e41
# verification_token = gzkFn7fnw5VDQ8JmUcqiWpJM

#client_id = os.environ["SLACK_CLIENT_ID"]
#client_secret = os.environ["SLACK_CLIENT_SECRET"]
#oauth_scope = os.environ["SLACK_BOT_SCOPE"]

#slack_token = os.environ["SLACK_API_TOKEN"]
slack_token = api_token
#sc = SlackClient(slack_token)
sc = WebClient(token=slack_token)

jiraQuery = f'project={project_name} AND fixVersion={version_name} AND (component=Automated AND component!=WebUI)'
jira_result = json.loads(j.search(jiraQuery, max_results=1))
total_jira_tests = jira_result['total']
logging.info(f'total automated jira tests is {total_jira_tests}')

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

folder_id = None
if folder_name:
    folder_id = z.get_folder_id(name=folder_name, project_id=project_id, version_id=version_id, cycle_id=cycle_id)
    if not folder_id:
        logger.error(f'folder id not for found for folder={folder_name}')
        sys.exit(1)

#jiraQueryUrl = 'project="' + project_name + '" AND fixVersion="' + version_name + '" ORDER BY Issue ASC'
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
failed_bugs_string_bytestcase = ''
failed_bugs_string_bybug = ''
failed_nobugs_string = ''
bug_dict = {}
report_warning = ''

if cycle_summary:
    result = json.loads(z.get_folders(project_id=project_id, version_id=version_id, cycle_id=cycle_id, expand=True))
    print('rrrrrrr', result)
    for folder in result:
        print('ffff', folder)
        for status in folder['executionSummaries']:
            if status['executionStatusName'] == 'FAIL':
                total_fail += status['count']
            elif status['executionStatusName'] == 'PASS':
                total_pass += status['count']
            elif status['executionStatusName'] == 'UNEXECUTED':
                total_unexecuted += status['count']
            elif status['executionStatusName'] == 'WIP':
                total_wip += status['count']
            elif status['executionStatusName'] == 'BLOCKED':
                total_blocked += status['count']
    total_counted = total_fail + total_pass + total_unexecuted + total_wip + total_blocked
    total_count = total_jira_tests
    logging.info(f'folders total={total_counted} pass={total_fail} fail={total_fail} unexec={total_unexecuted} wip={total_wip} blocked={total_blocked}')

    if total_counted != total_jira_tests:
        logging.error(f'mismatch in number of tests folder={total_counted} jira={total_jira_tests}')
        #report_warning = f'mismatch in number of tests folder={total_counted} jira={total_jira_tests}'
else:
    while offset < total_count:
        if folder_id:
            result = z.get_execution_list_by_folderid(folder_id=folder_id, cycle_id=cycle_id, version_id=version_id,  project_id=project_id, offset=offset)
        else:
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
            elif tc['execution']['status']['name'] == 'FAIL':
                total_fail += 1
                if len(tc['execution']['defects']) == 0:
                    total_fail_nobugs += 1
                    failed_nobugs_string += '>' + tc['issueKey'] + '\t' +  tc['issueSummary'] + '\n'
                else:
                    failed_bugs_string_bytestcase += '>' + tc['issueKey'] + '\t' +  tc['issueSummary'] + '\n'
                    for defect in tc['execution']['defects']:
                        failed_bugs_string_bytestcase += '>      ' + defect['key'] + ' - ' + defect['summary'] + '\n'
                        if (defect['key'] + ' - ' + defect['summary']) in bug_dict:
                            #print('bd', bug_dict[defect['key']])
                            bug_dict[defect['key'] + ' - ' + defect['summary']].append(tc['issueKey'] + '\t' +  tc['issueSummary'])
                        else:
                            bug_dict[defect['key'] + ' - ' + defect['summary']] = [tc['issueKey'] + '\t' +  tc['issueSummary']]
                    total_fail_bugs += 1
                failed_string +=  tc['issueKey'] + '\t' + tc['issueSummary'] + '\n'
            elif tc['execution']['status']['name'] == 'UNEXECUTED':
                total_unexecuted += 1
                unexecuted_string += '>' + tc['issueKey'] + '\t' +  tc['issueSummary'] + '\n'
            elif tc['execution']['status']['name'] == 'WIP': total_wip += 1
            elif tc['execution']['status']['name'] == 'BLOCKED': total_blocked += 1

            total_counted += 1
    
print('totalcount', total_count, 'totalcounted', total_counted, 'pass', total_pass, 'fail', total_fail, 'unexec', total_unexecuted)

pass_perc = 0
fail_perc = 0
fail_bugs_perc = 0
fail_nobugs_perc = 0
unexec_perc = 0
wip_perc = 0
blocked_perc = 0
na_perc = 0
wontexec_perc = 0
if total_counted > 0:
    pass_perc = round((total_pass/total_counted)*100, 2)
    fail_perc = round((total_fail/total_counted)*100, 2)
    fail_bugs_perc = round((total_fail_bugs/total_counted)*100, 2)
    fail_nobugs_perc = round((total_fail_nobugs/total_counted)*100, 2)
    unexec_perc = round((total_unexecuted/total_counted)*100, 2)
    wip_perc = round((total_wip/total_counted)*100, 2)
    blocked_perc = round((total_blocked/total_counted)*100, 2)
    na_perc = round((total_na/total_counted)*100, 2)
    wontexec_perc = round((total_wontexec/total_counted)*100, 2)

#report_string = build_report_string()
report_blocks = build_report_blocks()

#print(report_string)

#sys.exit(1)

#report_attachment = json.dumps(
#    [
#        {
#            #'pretext':'Automation Report For ' + cycle_name,
#            'text': '',
#            'title':'Automation Report For ' + cycle_name,
#            'fields': [
#                {
#                    'title':'Summary',
#                    'value': summary_string
#                },
#                {
#                    'title':'Failed testcases without bugs:',
#                    'value': failed_nobugs_string
#                },
#                {
#                    'title':'Failed testcases with bugs by testcase:',
#                    'value': failed_bugs_string_bytestcase
#                },
#                {
#                    'title':'Failed testcases with bugs by bug:',
#                    'value': failed_bugs_string_bybug
#                },
#                {
#                    'title':'Unexecuted testcases:',
#                    'value': unexecuted_string
#                }
#
#            ]
#        }
#    ])    

#sc.api_call(
#    "chat.postMessage",
#    channel=channel_number,
#    #text="Hello from Python! :tada:"
#    text=report_string,
#    #attachments=report_attachment 
#)



blocks = '''[
		{
			"type": "section",
			"text": {
				"type": "mrkdwn",
				"text": "*Total TCs*: 1823\n*Total Passed*: <https://mobiledgex.atlassian.net/plugins/servlet/ac/com.thed.zephyr.je/general-executions-enav?project.id=10006#!view=list&offset=0&zql=project%20%3D%20%22edge-cloud%20QA%22%20AND%20fixVersion%20%3D%20%22CirrusR3%22%20AND%20cycleName%20in%20(%222021-02-20_CirrusR3%22)%20AND%20folderName%20in%20(%22dme%22)%20AND%20executionStatus%20%3D%20FAIL|1410>   77.35%"
			}
		}]'''
if slack:
    print('slacking report')
    try:
        #response = sc.chat_postMessage(channel='#qa-automation', text=report_string)
        response = sc.chat_postMessage(channel='#qa-automation', blocks=report_blocks)

        print('slack message:', response)
        if 'response_metadata' in response and response['response_metadata']['messages']:
            response = sc.chat_postMessage(channel='#qa-automation', text=response['response_metadata']['messages'])
    except SlackApiError as e:
        # You will get a SlackApiError if "ok" is False
        assert e.response["ok"] is False
        assert e.response["error"]  # str like 'invalid_auth', 'channel_not_found'
        print(f"Got an error: {e.response['error']}")

    
def build_report_string():
    report_string = ''
    #report_string = f'*Cycle:*\t{cycle_name}\n\n'
    report_string += f'*Automation Report for'
    if folder_name:
        report_string += f' {folder_name}'

    report_string += f' {cycle_name}*\n\n'
    report_string += f'>*Total TCs:* {total_counted}\n'
    report_string += f'>*Total Passed:* {total_pass}   {pass_perc}%\n'
    report_string += f'>*Total Failed:* {total_fail}   {fail_perc}%\n'
    if not cycle_summary: report_string += f'>*Total Failed w/bugs:* {total_fail_bugs}   {fail_bugs_perc}%\n'
    if not cycle_summary: report_string += f'>*Total Failed wo/bugs:* {total_fail_nobugs}   {fail_nobugs_perc}%\n'
    report_string += f'>*Total Unexec:* {total_unexecuted}   {unexec_perc}%\n'
    report_string += f'>*Total WIP:* {total_wip}   {wip_perc}%\n'
    report_string += f'>*Total Blocked:* {total_blocked}   {blocked_perc}%\n'
    #report_string += f'>*Total NA:* {total_na}   {na_perc}%\n'  # dont think jira reports this
    #report_string += f'>*Total WontExec:* {total_wontexec}   {wontexec_perc}%\n'  # dont think jira reports this
    if job_duration > 0:
        report_string += f'>*Execution Time:* {round(job_duration/1000/60/60, 2)} hrs\n'

    if total_count != total_counted:
        report_string += f'*WARNING - total count did not add up. counted={total_counted} expected={total_count}*\n'
    if (total_pass + total_fail + total_unexecuted + total_wip + total_blocked + total_na + total_wontexec) != total_counted:
        report_string += f'*WARNING - sum of exectution types did not add up. counted={total_pass + total_fail + total_unexecuted + total_wip + total_blocked + total_na + total_wontexec} expected={total_counted}*\n'
    summary_string = report_string

    if not summary_only and not cycle_summary:
        if len(failed_nobugs_string) == 0:
            failed_nobugs_string = '>None\n'
        if len(failed_bugs_string_bytestcase) == 0:
            failed_bugs_string_bytestcase = '>None\n'
        if len(failed_bugs_string_bybug) == 0:
            failed_bugs_string_bybug = '>None\n'
        if len(unexecuted_string) == 0:
            unexecuted_string = '>None\n'

    
        report_string += '>\n*Failed testcases without bugs:*\n' + failed_nobugs_string
        report_string += '>\n*Failed testcases with bugs by testcase:*\n' + failed_bugs_string_bytestcase
        report_string += '>\n*Failed testcases with bugs by bug:*\n'
        if bug_dict:
            for bug in bug_dict:
                report_string += '>' + bug + '\n'
                for tc in bug_dict[bug]:
                    report_string += '>      ' + tc + '\n'
        else:
            report_string += '>None\n'
        report_string += '>\n*Unexecuted testcases:*\n' + unexecuted_string
        #print(failed_bugs_string_bybug)

    if report_warning:
        report_string += '\n' + report_warning

