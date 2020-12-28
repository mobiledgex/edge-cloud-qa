#!/usr/bin/python3

import sys
import os
import glob
#print(sys.path)

import zapi
import jiraapi
import urllib
import logging
import json
import time
import subprocess
import argparse
import zipfile
import zlib

release = 'CirrusR3'

username = 'andy.anderson@mobiledgex.com'
accountid = '5b85c5f93cee7729fa0660a8'
access_key = 'MDAzZTcyMTMtNGY3ZS0zMmMwLWIxZDAtYjZlM2Y1MTljNmNlIDViODVjNWY5M2NlZTc3MjlmYTA2NjBhOCBVU0VSX0RFRkFVTFRfTkFNRQ'
secret_key = '_1x9j2jdzPGHmpQTs9myoiz76wFTl1f_MC3iBXP0mFg'
jira_token = 'Qoi6yaqSNTvjdyJAhgNz1AE4'

comp_dict = {}
test_dict = {}

def parse(result):
   for test in result:
      #print(test['key'])
      test_dict[test['key']] = []
      for comp in test['fields']['components']:
         #print(comp['name'])
         test_dict[test['key']].append(comp['name'])

def get_stats(type):
   controller_dict = {}
   for test in test_dict:
#      print('test', test)
      if type in test_dict[test]:
#         test_dict[test].remove(type)
#         test_dict[test].remove('Automated')
#         if str(test_dict[test]) in controller_dict:
#            controller_dict[str(test_dict[test])] += 1
#         else:
#            controller_dict[str(test_dict[test])] = 1

         for comp in test_dict[test]:
            if comp in controller_dict:
               controller_dict[comp] += 1
            else:
               controller_dict[comp] = 1

   return controller_dict
 
j = jiraapi.Jiraapi(username=username, token=jira_token)


jiraQueryUrl = f'type=Test and project=ECQ and fixVersion={release} and (component=Automated or component=Performance)'

startat = 0
maxresults = 0
total = 1
tc_list = []
while (startat + maxresults) < total:
   #jiraQueryUrl = jiraQueryUrlPre + ' startAt=' + str(startat + maxresults) + ' ORDER By Issue ASC'
   result = j.search(query=jiraQueryUrl, start_at=startat+maxresults)
   #print(result)

   query_content = json.loads(result)

   parse(query_content['issues'])

   #print(test_dict)
   #sys.exit(1)
   startat = query_content['startAt']
   maxresults = query_content['maxResults']
   total = query_content['total']
   print(startat,maxresults,total)

#print(test_dict)

controller_dict = get_stats('Controller')
print('Controller Tests')
for comp in controller_dict:
   print(f'   {comp}: {controller_dict[comp]}')

print('')

dme_dict = get_stats('DME')
print('DME Tests')
for comp in dme_dict:
   print(f'   {comp}: {dme_dict[comp]}')

print('')

dme_dict = get_stats('MasterController')
print('MC Tests')
for comp in dme_dict:
   print(f'   {comp}: {dme_dict[comp]}')

print('')

dme_dict = get_stats('CRM')
print('CRM Tests')
for comp in dme_dict:
   print(f'   {comp}: {dme_dict[comp]}')

print('')

dme_dict = get_stats('Metrics')
print('Metrics Tests')
for comp in dme_dict:
   print(f'   {comp}: {dme_dict[comp]}')

print('')

dme_dict = get_stats('SDK')
print('SDK Tests')
for comp in dme_dict:
   print(f'   {comp}: {dme_dict[comp]}')

print('')

dme_dict = get_stats('WebUI')
print('Console Tests')
for comp in dme_dict:
   print(f'   {comp}: {dme_dict[comp]}')

print('')

dme_dict = get_stats('Performance')
print('Performance Tests')
for comp in dme_dict:
   print(f'   {comp}: {dme_dict[comp]}')

print('')

dme_dict = get_stats('Security')
print('Security Tests')
for comp in dme_dict:
   print(f'   {comp}: {dme_dict[comp]}')

print('')

dme_dict = get_stats('Mcctl')
print('Mcctl Tests')
for comp in dme_dict:
   print(f'   {comp}: {dme_dict[comp]}')


