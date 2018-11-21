#!/usr/local/bin/python3

import sys
import os
import logging

import zapi
import jiraapi

access_key = '***REMOVED***'
secret_key  = '***REMOVED***'
username = 'andy.anderson@mobiledgex.com'
jira_token = '***REMOVED***'

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
