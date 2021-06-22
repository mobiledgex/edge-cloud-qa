from slack import WebClient
from slack.errors import SlackApiError
import argparse
import json
import logging
import sys
import html
import os
import datetime
import time
import matplotlib.pyplot as plt

import zapi
import jiraapi

channel_number = 'CF67W3QH5'

zephyrBaseUrl = "https://mobiledgex.atlassian.net/rest/zapi/latest/"
username = 'andy.anderson@mobiledgex.com'
accountid = '5b85c5f93cee7729fa0660a8'
access_key = 'MDAzZTcyMTMtNGY3ZS0zMmMwLWIxZDAtYjZlM2Y1MTljNmNlIDViODVjNWY5M2NlZTc3MjlmYTA2NjBhOCBVU0VSX0RFRkFVTFRfTkFNRQ'
secret_key = '_1x9j2jdzPGHmpQTs9myoiz76wFTl1f_MC3iBXP0mFg'

jira_token = 'Qoi6yaqSNTvjdyJAhgNz1AE4'

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

timings_output_file = f'/tmp/timings_{cycle_name}.html'
timings_html_file = f'/var/www/html/timings/timings_{cycle_name}.html'
timings_url = f'http://40.122.108.233/timings/timings_{cycle_name}.html'

logger = logging.getLogger(__name__)
logging.basicConfig(
    level=logging.DEBUG,
    format="%(asctime)s - %(filename)s %(funcName)s() line %(lineno)d - %(levelname)s - - %(message)s")
logging.getLogger('urllib3').setLevel(logging.ERROR)
logging.getLogger('zapi').setLevel(logging.DEBUG)


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
    pass_string = f'*Total Passed:* <{pass_url}|{total_pass}>   {pass_perc}%'
    fail_string = f'*Total Failed:* <{fail_url}|{total_fail}>   {fail_perc}%'
    if not cycle_summary:
        fail_string += f'\\n*Total Failed w/bugs:* {total_fail_bugs}   {fail_bugs_perc}%'
    if not cycle_summary:
        fail_string += f'\\n*Total Failed wo/bugs:* {total_fail_nobugs}   {fail_nobugs_perc}%'
    unexec_string = f'*Total Unexec:* <{unexecuted_url}|{total_unexecuted}>   {unexec_perc}%'
    wip_string = f'*Total WIP:* <{wip_url}|{total_wip}>   {wip_perc}%'
    blocked_string = f'*Total Blocked:* <{blocked_url}|{total_blocked}>   {blocked_perc}%'

    exec_time_string = None
    if job_duration > 0:
        exec_time_string = f'*Execution Time:* <{timings_url}|{round(job_duration/1000/60/60, 2)}> hrs\n'

    report_text = f'{total_string}\\n{pass_string}\\n{fail_string}\\n{unexec_string}\\n{wip_string}\\n{blocked_string}'
    if exec_time_string:
        report_text += f'\\n{exec_time_string}'
    if report_warning:
        report_text += f'\\n{report_warning}'
    print(report_text)

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
                        "text": "{report_text}"
                     }}
                  }}
                ]'''

    print('block', block)

    return block


def create_graph(time_dict):
    start_sorted_dict = dict(sorted(time_dict.items(), key=lambda item: item[1]['start_time'], reverse=False))
    end_sorted_dict = dict(sorted(time_dict.items(), key=lambda item: item[1]['end_time'], reverse=True))

    start_dict_list = list(start_sorted_dict.values())
    end_dict_list = list(end_sorted_dict.values())
    reg_start = start_dict_list[0]['start_time']
    reg_end = end_dict_list[0]['end_time']
    reg_start_date = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(reg_start))
    reg_end_date = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(reg_end))
    num_tests = len(start_dict_list)

    logger.info(f'graph starttime={reg_start_date} {reg_start} endtime={reg_end_date} {reg_end} num_tests={num_tests}')

#    fig, gnt = plt.subplots()
#    gnt.set_ylim(0, num_tests)
#    gnt.set_xlim(reg_start, reg_end)
#    gnt.set_xlabel('Regression time')
#    gnt.set_ylabel('Test')
#
#    gnt.set_xticks([reg_start, reg_end])
#    gnt.set_xticklabels([reg_start_date, reg_end_date])
#
#    gnt.set_yticks([1, num_tests])
#    gnt.set_yticklabels(['1', str(num_tests)])
#
#    counter = 0
#    for key in start_sorted_dict:
#        if start_sorted_dict[key]["duration"] > 0:
#            print(f'broken_barh {start_sorted_dict[key]["start_time"]} {start_sorted_dict[key]["duration"]} {counter}')
#            gnt.broken_barh([(start_sorted_dict[key]["start_time"], start_sorted_dict[key]["duration"])], (counter, 1), facecolors =('tab:orange'))
#        counter += 1

    x = []
    y = []
    sizes = []
    counter = 0
    for key in start_sorted_dict:
        if start_sorted_dict[key]["duration"] > 0:
            x.append(start_sorted_dict[key]["start_time"] + start_sorted_dict[key]["duration"] / 2)
            sizes.append(start_sorted_dict[key]["duration"])
            y.append(counter)
            counter += 1
    plt.scatter(x, y, s=sizes)

    plt.savefig("gantt1.png")


def write_exec_time_file(time_dict_string):
    time_dict = {}

    with open('time_dict.txt', "w") as file1:
        for comment in time_dict_string:
            # print(f'fffffff "{comment}": "{time_dict_string}", ')
            # print(f'fffffff "{comment}" "{time_dict_string[comment]}"')
            file1.write(f'"{comment}": "{time_dict_string[comment]}", ')

            comment_dict = json.loads(html.unescape(time_dict_string[comment]))
            time_dict[comment] = comment_dict

    time_sorted_dict = dict(sorted(time_dict.items(), key=lambda item: item[1]['duration'], reverse=True))

    with open(timings_output_file, "w") as file1:
        file1.write('<table style="width:100%">\n')
        file1.write('<tr><th>TCID</th><th>Title</th><th>Duration (h:m:s)</th></tr>')
        for key in time_sorted_dict:
            duration = str(datetime.timedelta(seconds=time_sorted_dict[key]["duration"]))
            file1.write(f'<tr><td align=left>{key}</td><td align=left>{time_sorted_dict[key]["summary"]}</td><td align=left>{duration}</td></tr>\n')
        file1.write('</table>')

    cmd = f'cp {timings_output_file} {timings_html_file}'
    logger.info(f'copy timings file cmd={cmd}')
    os.system(cmd)

    # create_graph(time_dict)


def find_missing_tests():
    cycle_list = []
    expected_list = []
    time_dict = {}

    offset = 0
    total_count = 1
    startat = 0
    maxresults = 500
    while offset < total_count:
        query_content = json.loads(j.search(jiraQuery_all, start_at=startat + maxresults, max_results=maxresults))
        total_count = query_content['total']
        startat = query_content['startAt']
        maxresults = query_content['maxResults']
        offset = offset + maxresults
        for tc in query_content['issues']:
            print(tc['key'])
            expected_list.append(tc['key'])

    result = json.loads(z.get_folders(project_id=project_id, version_id=version_id, cycle_id=cycle_id, expand=True))
    for folder in result:
        offset = 0
        total_count = 1

        logging.debug('query folder=' + folder['name'])
        # folder_id = z.get_folder_id(name=folder['name'], project_id=project_id, version_id=version_id, cycle_id=cycle_id)
        while offset < total_count:
            result = z.get_execution_list_by_folderid(folder_id=folder['id'], cycle_id=cycle_id, version_id=version_id, project_id=project_id, offset=offset)
            query_content = json.loads(result)
            print('length of exec list by folderid', len(query_content['searchObjectList']))
            # if len(query_content['searchObjectList']) > 0:
            #    print('length greater than 0')
            #    sys.exit(1)
            total_count = query_content['totalCount']
            offset = offset + query_content['maxAllowed']
            for tc in query_content['searchObjectList']:
                print('tccc', tc)
                print(tc['issueKey'], tc['execution']['status']['name'], tc['execution']['defects'])
                cycle_list.append(tc['issueKey'])
                time_dict_key = tc['issueKey']
                if tc['issueKey'] in time_dict:
                    time_dict_key = tc['issueKey'] + '_' + tc['execution']['id']
                if 'comment' in tc['execution'] and tc['execution']['comment'] != 'None':
                    time_dict[time_dict_key] = tc['execution']['comment'].replace('}', ', "summary": "' + tc['issueSummary'].rstrip() + '"}')
                else:
                    time_dict[time_dict_key] = '{"cloudlet": "nocomment", "start_time": 0, "end_time": 0, "duration": 0, "summary": "' + tc['issueSummary'].rstrip() + '"}'

    print('expected count', len(expected_list), 'expected set count', len(set(expected_list)), 'cycle count', len(cycle_list), 'cycle set count', len(set(cycle_list)))
    print('expected_list', expected_list)
    print('cycle_list', cycle_list)

    seen = []
    duplicate_tests = []
    for x in cycle_list:
        if x not in seen:
            seen.append(x)
        else:
            duplicate_tests.append(x)

    print('duplicates', duplicate_tests)
    missing_tests = set(expected_list) - set(cycle_list)
    logging.info(f'total jira tests={total_jira_tests} missing len={len(missing_tests)} missing tests {missing_tests}')

    write_exec_time_file(time_dict)

    return missing_tests, duplicate_tests


z = zapi.Zapi(username=accountid, access_key=access_key, secret_key=secret_key, debug=True)
j = jiraapi.Jiraapi(username=username, token=jira_token)

api_token = 'xoxb-313978814983-514011267477-U1J6wkdyA1lSRmTakKQ27R8e'
channel_id = 'DF3JVL43W'

# appid = AF3JU3F0U
client_id = '313978814983.513640117028'
client_secret = 'd0a665344a7d8f0d6333d6a5d794e24e'
oauth_scope = 'chat:write:bot'
slack_token = api_token
# sc = SlackClient(slack_token)
sc = WebClient(token=slack_token)

jiraQuery_all = f'project={project_name} AND fixVersion={version_name} AND (component=Automated AND component!=WebUI)'
jira_result = json.loads(j.search(jiraQuery_all, max_results=1))
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
logging.info("project_id=%s version_id=%s" % (project_id, version_id))

cycle_id = z.get_cycle_id(name=cycle_name, project_id=project_id, version_id=version_id)

folder_id = None
if folder_name:
    folder_id = z.get_folder_id(name=folder_name, project_id=project_id, version_id=version_id, cycle_id=cycle_id)
    if not folder_id:
        logging.error(f'folder id not for found for folder={folder_name}')
        sys.exit(1)

# jiraQueryUrl = 'project="' + project_name + '" AND fixVersion="' + version_name + '" ORDER BY Issue ASC'
offset = 0
max_allowed = 0
total_count = 1
total_counted = 0
total_missing = 0
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
    logging.info(f'folders totaljira={total_count} totalcounted={total_counted} pass={total_pass} fail={total_fail} unexec={total_unexecuted} wip={total_wip} blocked={total_blocked} missing={total_jira_tests-total_counted}')

    missing_tests, duplicate_tests = find_missing_tests()
    if missing_tests:
        report_warning = f'Found missing tests. CountedInFolders={total_counted} TotalInJira={total_jira_tests}\nMissingTests={missing_tests}'

#    if total_counted != total_jira_tests:
#        logging.error(f'mismatch in number of tests folder={total_counted} jira={total_jira_tests}')
#        missing_tests, duplicate_tests = find_missing_tests()
#        report_warning = f'Mismatch in number of tests. CountedInFolders={total_counted} TotalInJira={total_jira_tests}\nMissingTests={missing_tests}\nDuplicateTests={duplicate_tests}'
else:
    while offset < total_count:
        if folder_id:
            result = z.get_execution_list_by_folderid(folder_id=folder_id, cycle_id=cycle_id, version_id=version_id, project_id=project_id, offset=offset)
        else:
            result = z.get_execution_list_by_cycleid(cycle_id=cycle_id, version_id=version_id, project_id=project_id, offset=offset)
        query_content = json.loads(result)

        print('length', len(query_content['searchObjectList']))

        total_count = query_content['totalCount']
        # max_allowed =  query_content['maxAllowed']
        # offset = query_content['currentOffset'] + query_content['maxAllowed']
        offset = offset + query_content['maxAllowed']
        for tc in query_content['searchObjectList']:
            print(tc['issueKey'], tc['execution']['status']['name'], tc['execution']['defects'])
            if tc['execution']['status']['name'] == 'PASS':
                total_pass += 1
            elif tc['execution']['status']['name'] == 'FAIL':
                total_fail += 1
                if len(tc['execution']['defects']) == 0:
                    total_fail_nobugs += 1
                    failed_nobugs_string += '>' + tc['issueKey'] + '\t' + tc['issueSummary'] + '\n'
                else:
                    failed_bugs_string_bytestcase += '>' + tc['issueKey'] + '\t' + tc['issueSummary'] + '\n'
                    for defect in tc['execution']['defects']:
                        failed_bugs_string_bytestcase += '>      ' + defect['key'] + ' - ' + defect['summary'] + '\n'
                        if (defect['key'] + ' - ' + defect['summary']) in bug_dict:
                            # print('bd', bug_dict[defect['key']])
                            bug_dict[defect['key'] + ' - ' + defect['summary']].append(tc['issueKey'] + '\t' + tc['issueSummary'])
                        else:
                            bug_dict[defect['key'] + ' - ' + defect['summary']] = [tc['issueKey'] + '\t' + tc['issueSummary']]
                    total_fail_bugs += 1
                failed_string += tc['issueKey'] + '\t' + tc['issueSummary'] + '\n'
            elif tc['execution']['status']['name'] == 'UNEXECUTED':
                total_unexecuted += 1
                unexecuted_string += '>' + tc['issueKey'] + '\t' + tc['issueSummary'] + '\n'
            elif tc['execution']['status']['name'] == 'WIP':
                total_wip += 1
            elif tc['execution']['status']['name'] == 'BLOCKED':
                total_blocked += 1

            total_counted += 1

print('totalcount', total_count, 'totalcounted', total_counted, 'pass', total_pass, 'fail', total_fail, 'wip', total_wip, 'blocked', total_blocked, 'unexec', total_unexecuted)

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
    pass_perc = round((total_pass / total_counted) * 100, 2)
    fail_perc = round((total_fail / total_counted) * 100, 2)
    fail_bugs_perc = round((total_fail_bugs / total_counted) * 100, 2)
    fail_nobugs_perc = round((total_fail_nobugs / total_counted) * 100, 2)
    unexec_perc = round((total_unexecuted / total_counted) * 100, 2)
    wip_perc = round((total_wip / total_counted) * 100, 2)
    blocked_perc = round((total_blocked / total_counted) * 100, 2)
    na_perc = round((total_na / total_counted) * 100, 2)
    wontexec_perc = round((total_wontexec / total_counted) * 100, 2)

# report_string = build_report_string()
report_blocks = build_report_blocks()

# print(report_string)

# report_attachment = json.dumps(
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

# sc.api_call(
#    "chat.postMessage",
#    channel=channel_number,
#    #text="Hello from Python! :tada:"
#    text=report_string,
#    #attachments=report_attachment
# )

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
        # response = sc.chat_postMessage(channel='#qa-automation', text=report_string)
        response = sc.chat_postMessage(channel='#qa-automation', blocks=report_blocks)

        print('slack message:', response)
        if 'response_metadata' in response and response['response_metadata']['messages']:
            response = sc.chat_postMessage(channel='#qa-automation', text=response['response_metadata']['messages'])
    except SlackApiError as e:
        # You will get a SlackApiError if "ok" is False
        assert e.response["ok"] is False
        assert e.response["error"]  # str like 'invalid_auth', 'channel_not_found'
        print(f"Got an error: {e.response['error']}")


# def build_report_string():
#    report_string = ''
#    #report_string = f'*Cycle:*\t{cycle_name}\n\n'
#    report_string += f'*Automation Report for'
#    if folder_name:
#        report_string += f' {folder_name}'
#
#    report_string += f' {cycle_name}*\n\n'
#    report_string += f'>*Total TCs:* {total_counted}\n'
#    report_string += f'>*Total Passed:* {total_pass}   {pass_perc}%\n'
#    report_string += f'>*Total Failed:* {total_fail}   {fail_perc}%\n'
#    if not cycle_summary: report_string += f'>*Total Failed w/bugs:* {total_fail_bugs}   {fail_bugs_perc}%\n'
#    if not cycle_summary: report_string += f'>*Total Failed wo/bugs:* {total_fail_nobugs}   {fail_nobugs_perc}%\n'
#    report_string += f'>*Total Unexec:* {total_unexecuted}   {unexec_perc}%\n'
#    report_string += f'>*Total WIP:* {total_wip}   {wip_perc}%\n'
#    report_string += f'>*Total Blocked:* {total_blocked}   {blocked_perc}%\n'
#    #report_string += f'>*Total NA:* {total_na}   {na_perc}%\n'  # dont think jira reports this
#    #report_string += f'>*Total WontExec:* {total_wontexec}   {wontexec_perc}%\n'  # dont think jira reports this
#    if job_duration > 0:
#        report_string += f'>*Execution Time:* {round(job_duration/1000/60/60, 2)} hrs\n'
#
#    if total_count != total_counted:
#        report_string += f'*WARNING - total count did not add up. counted={total_counted} expected={total_count}*\n'
#    if (total_pass + total_fail + total_unexecuted + total_wip + total_blocked + total_na + total_wontexec) != total_counted:
#        report_string += f'*WARNING - sum of exectution types did not add up. counted={total_pass + total_fail + total_unexecuted + total_wip + total_blocked + total_na + total_wontexec} expected={total_counted}*\n'
#    summary_string = report_string
#
#    if not summary_only and not cycle_summary:
#        if len(failed_nobugs_string) == 0:
#            failed_nobugs_string = '>None\n'
#        if len(failed_bugs_string_bytestcase) == 0:
#            failed_bugs_string_bytestcase = '>None\n'
#        if len(failed_bugs_string_bybug) == 0:
#            failed_bugs_string_bybug = '>None\n'
#        if len(unexecuted_string) == 0:
#            unexecuted_string = '>None\n'
#
#        report_string += '>\n*Failed testcases without bugs:*\n' + failed_nobugs_string
#        report_string += '>\n*Failed testcases with bugs by testcase:*\n' + failed_bugs_string_bytestcase
#        report_string += '>\n*Failed testcases with bugs by bug:*\n'
#        if bug_dict:
#            for bug in bug_dict:
#                report_string += '>' + bug + '\n'
#                for tc in bug_dict[bug]:
#                    report_string += '>      ' + tc + '\n'
#        else:
#            report_string += '>None\n'
#        report_string += '>\n*Unexecuted testcases:*\n' + unexecuted_string
#        # print(failed_bugs_string_bybug)
#
#    if report_warning:
#        report_string += '\n' + report_warning
