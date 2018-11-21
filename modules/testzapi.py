#!/usr/local/bin/python3

import sys
import os
import logging

import zapi
import jiraapi

access_key = 'MDAzZTcyMTMtNGY3ZS0zMmMwLWIxZDAtYjZlM2Y1MTljNmNlIGFuZHkuYW5kZXJzb24gYW5keS5hbmRlcnNvbg'
secret_key  = 'PckHXrGmx7pHzt-_-uAEBAK7fGP3dk3rI5BbVQLb5oU'
username = 'andy.anderson@mobiledgex.com'
jira_token = 'cop6UQnmK4mwodXzijsY407F'

logging.basicConfig(
    level=logging.DEBUG,
    format = "%(asctime)s - %(filename)s %(funcName)s() line %(lineno)d - %(levelname)s -  - %(message)s")
#format = "%(message)s")
#logging.getLogger('requests.packages.urllib3.connectionpool').setLevel(logging.ERROR)
logging.getLogger('urllib3').setLevel(logging.ERROR)
logging.getLogger('zapi').setLevel(logging.DEBUG)

z = zapi.Zapi(username=username, access_key=access_key, secret_key=secret_key, debug=True)
#z.get_server_info()
#z.get_cycles(project_id=10006, version_id=10007)
z.execute_query('fixVersion=Nimbus')
sys.exit(1)

#j = jiraapi.Jiraapi(username=username, token=jira_token)
#j.search('project=10006')
