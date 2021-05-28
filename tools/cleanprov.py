#!/usr/local/bin/python3

import os
import sys
import argparse
import logging
import re
import MexMasterController as mex_master_controller

#print('loggers', logging.root.manager.loggerDict)

logging.basicConfig(format='%(asctime)s %(levelname)s %(module)s %(funcName)s xline:%(lineno)d - %(message)s',datefmt='%d-%b-%y %H:%M:%S')
loglevel = logging.WARNING

logging.getLogger('MexMasterController').setLevel(loglevel)
logging.getLogger('mex_rest').setLevel(loglevel)
logging.getLogger('webservice').setLevel(loglevel)
logging.getLogger('mex_master_controller.MexOperation').setLevel(loglevel)

table_list = ['appinst', 'app', 'clusterinst', 'flavor', 'autoscalepolicy', 'autoprovpolicy', 'orgcloudletpool', 'cloudletpool', 'cloudlet', 'org', 'user']
table_list_str = ','.join(table_list)

region_list = ['US', 'EU']
region_list_str = ','.join(region_list)

automation_regex = '.*16\d{8}\d*'

parser = argparse.ArgumentParser(description='clean prov from controller')
parser.add_argument('--mcaddress', default='console-qa.mobiledgex.net:443', help='master controller address:port. Default is console-qa.mobiledgex.net:443')
parser.add_argument('--region', default=region_list_str, help=f'master controller region. Default is {region_list_str}')
parser.add_argument('--tables',default=table_list_str, help=f'comma seperated list of tables in the order to be deleted: Default is {table_list_str}')
parser.add_argument('--cloudlet', default=None, help='cloudlet to filter the delete by')
parser.add_argument('--keypattern',default='*',help='pattern to filter the key delete by')
parser.add_argument('--automation',action='store_true', help=f'delete automation objects that have {automation_regex} regular expression')

#parser.add_argument('--outfile',required=False, default='tc_import.csv', help='csv outfile to write to. default is tc_import.csv')
#parser.add_argument('--filepattern',required=False, default='test_*.py', help='file match pattern for testcase parsing. default is test_*.py')

args = parser.parse_args()

mc_address = args.mcaddress
region_arg = args.region
#controller_address = args.address
tables_arg = args.tables.split(',')
cloudlet = args.cloudlet
key_pattern = args.keypattern
automation_set = args.automation

if automation_set:
   key_pattern = automation_regex

pattern_re = re.compile(key_pattern)

mex_root_cert = 'mex-ca.crt'
mex_cert = 'localserver.crt'
mex_key = 'localserver.key'

#appinst_keep = [{'app_name':'automation_api_app'}, {'app_name':'MEXPrometheusAppName'}, {'app_name':'MEXMetricsExporter'}]
#app_keep = [{'app_name':'automation_api_auth_app'}, {'app_name':'automation_api_app'},{'app_name':'MEXPrometheusAppName'}, {'app_name':'MEXMetricsExporter'}]
appinst_keep = [{'app_name':'automation_api_app'},{'app_name':'MEXPrometheusAppName'}]
app_keep = [{'app_name':'automation_api_auth_app'}, {'app_name':'automation_api_app'}]
clusterinst_keep = []
cluster_keep = [{'cluster_name':'automationapicluster'}]
#clusterflavor_keep = [{'cluster_flavor_name':'automation_api_cluster_flavor'},{'cluster_flavor_name':'x1.medium'}]
cloudlet_keep = [{'cloudlet_name': 'automationMunichCloudlet', 'operator_name': 'TDG'},{'cloudlet_name': 'automationBonnCloudlet', 'operator_name': 'TDG'},{'cloudlet_name': 'automationBerlinCloudlet', 'operator_name': 'TDG'},{'cloudlet_name': 'automationHamburgCloudlet', 'operator_name': 'TDG'},{'cloudlet_name': 'automationFrankfurtCloudlet', 'operator_name': 'TDG'},{'cloudlet_name': 'attcloud-1', 'operator_name': 'att'},{'cloudlet_name': 'tmocloud-1', 'operator_name': 'tmus'},{'cloudlet_name': 'tmocloud-2', 'operator_name': 'tmus'},{'cloudlet_name': 'automationProdHamburgCloudlet', 'operator_name': 'TDG'},{'cloudlet_name': 'automationAzureCentralCloudlet', 'operator_name': 'azure'},{'cloudlet_name': 'automationGcpCentralCloudlet', 'operator_name': 'gcp'}]
flavor_keep = [{'flavor_name':'x1.medium'},{'flavor_name':'automation_api_flavor'}]
developer_keep = [{'developer_name':'automation_api'},{'developer_name':'mexinfradev_'}]
operator_keep = [{'operator_name': 'TDG'},{'operator_name': 'gcp'},{'operator_name': 'tmus'},{'operator_name': 'att'},{'operator_name': 'azure'}]

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

mc = mex_master_controller.MexMasterController(mc_address = mc_address)

def clean_autoscalepolicy():
    print('clean autoscalepolicy')
    org_list = mc.show_autoscale_policy(region=region, token=mc.super_token, use_defaults=False)
    if len(org_list) == 0:
        print('nothing to delete')
    else:
        for a in org_list:
            name = a['data']['key']['name']
            org = a['data']['key']['organization']
            if in_autoscalepolicy_list(a):
                print(f'keeping {name}')
            else:
                if pattern_re.match(name):
                    print(f'deleting {name}')
                    try:
                        mc.delete_autoscale_policy(region=region, policy_name=name, developer_org_name=org, use_defaults=False, token=mc.super_token)
                    except Exception as e:
                        print(f'error deleting {name}, {e}.continuing to next item')
                else:
                    print(f'keeping {name} since doesnt match keypattern={key_pattern}')

def clean_autoprovpolicy():
    print('clean orgcloudletpool')
    org_list = mc.show_auto_provisioning_policy(region=region, token=mc.super_token, use_defaults=False)
    if len(org_list) == 0:
        print('nothing to delete')
    else:
        for a in org_list:
            name = a['data']['key']['name']
            org = a['data']['key']['organization']
            if in_autoprovpolicy_list(a):
                print(f'keeping {name}')
            else:
                if pattern_re.match(name):
                    print(f'deleting {name}')
                    try:
                        mc.delete_auto_provisioning_policy(region=region, policy_name=name, developer_org_name=org, use_defaults=False, token=mc.super_token)
                    except Exception as e:
                        print(f'error deleting {name}, {e}.continuing to next item')
                else:
                    print(f'keeping {name} since doesnt match keypattern={key_pattern}')

def clean_orgcloudletpool():
    print('clean orgcloudletpool')
    org_list = mc.show_org_cloudlet_pool(region=region, token=mc.super_token, use_defaults=False)
    if len(org_list) == 0:
        print('nothing to delete')
    else:
        for a in org_list:
            org = a['Org']
            cloudletpool = a['CloudletPool']
            cloudletpoolorg = a['CloudletPoolOrg']
            if in_orgcloudletpool_list(a):
                print(f'keeping {cloudletpoolorg}')
            else:
                if pattern_re.match(cloudletpool):
                    print(f'deleting pool={cloudletpool} org={cloudletpoolorg}')
                    try:
                        mc.delete_org_cloudlet_pool(region=region, org_name=org, cloudlet_pool_name=cloudletpool, cloudlet_pool_org_name=cloudletpoolorg, use_defaults=False, token=mc.super_token)
                    except Exception as e:
                        print(f'error deleting {cloudletpool}, {e}.continuing to next item')
                else:
                    print(f'keeping {cloudletpool} since doesnt match keypattern={key_pattern}')

def clean_org():
    print('clean org')
    org_list = mc.show_organizations(token=mc.super_token, use_defaults=False)
    if len(org_list) == 0:
        print('nothing to delete')
    else:
        for a in org_list:
            name = a['Name']
            if in_org_list(a):
                print(f'keeping {name}')
            else:
                if pattern_re.match(name):
                    print(f'deleting {name}')
                    crm_override = 1
                    try:
                        mc.delete_org(orgname=name, use_defaults=False, token=mc.super_token)
                    except Exception as e:
                        print(f'error deleting {name}. {e}. .continuing to next item')
                else:
                    print(f'keeping {name} since doesnt match keypattern={key_pattern}')

def clean_user():
    print('clean user')
    org_list = mc.show_users(token=mc.super_token, use_defaults=False)
    
    if len(org_list) == 0:
        print('nothing to delete')
    else:
        for a in org_list:
            name = a['Name']
            if in_org_list(a):
                print(f'keeping {name}')
            else:
                if pattern_re.match(name):
                    print(f'deleting {name}')
                    crm_override = 1
                    try:
                        mc.delete_user(username=name, use_defaults=False, token=mc.super_token)
                    except Exception as e:
                        print(f'error deleting {name}. {e}. .continuing to next item')
                else:
                    print(f'keeping {name} since doesnt match keypattern={key_pattern}')
 
def clean_appinst():
    print('clean appinst')
    appinst_list = mc.show_app_instances(cloudlet_name=cloudlet, region=region, token=mc.super_token, use_defaults=False)
    if len(appinst_list) == 0:
        print('nothing to delete')
    else:
        for a in appinst_list:
            name = a['data']['key']['app_key']['name']
            version = a['data']['key']['app_key']['version']
            org = a['data']['key']['app_key']['organization']
            clustername = a['data']['key']['cluster_inst_key']['cluster_key']['name']
            clusterorg = a['data']['key']['cluster_inst_key']['organization']
            cloudletname = a['data']['key']['cluster_inst_key']['cloudlet_key']['name']
            cloudletorg = a['data']['key']['cluster_inst_key']['cloudlet_key']['organization']

            if in_appinst_list(a):
                print(f'keeping {name}')
            else:
                if pattern_re.match(name):
                    print(f'deleting {name}')
                    crm_override = 1
                    try:
                        mc.delete_app_instance(region=region, app_name=name, app_version=version, developer_org_name=org, cluster_instance_name=clustername, cluster_instance_developer_org_name=clusterorg, cloudlet_name=cloudletname, operator_org_name=cloudletorg, use_defaults=False, token=mc.super_token, crm_override=crm_override)
                    except Exception as e:
                        print(f'error deleting {name}, {e}.continuing to next item')
                        mc.delete_app_instance(region=region, app_name=name, app_version=version, developer_org_name=org, cluster_instance_name=clustername, cluster_instance_developer_org_name=clusterorg, cloudlet_name=cloudletname, operator_org_name=cloudletorg, use_defaults=False, token=mc.super_token, crm_override='IgnoreCrmAndTransientState')
                else:
                    print(f'keeping {name} since doesnt match keypattern={key_pattern}')

def clean_app():
    print('clean app')
    app_list = mc.show_apps(region=region, token=mc.super_token, use_defaults=False)
    if len(app_list) == 0:
        print('nothing to delete')
    else:
        for a in app_list:
            name = a['data']['key']['name']
            version = a['data']['key']['version']
            org = a['data']['key']['organization']

            if in_app_list(a):
                print(f'keeping {name}')
            else:
                if pattern_re.match(name):
                    print(f'deleting {name} {version} {org}')
                    #mc.delete_app(region=region, app_name=name, app_version=version, developer_org_name=org, use_defaults=False)

                    try:
                       mc.delete_app(region=region, token=mc.super_token, app_name=name, app_version=version, developer_org_name=org, use_defaults=False)
                       #pass
                    except Exception as e:
                        print(f'error deleting, {e}.continuing to next item')
                else:
                    print(f'keeping {name} since doesnt match keypattern={key_pattern}')

def clean_clusterinst():
    print('clean cluster instance')
    app_list = mc.show_cluster_instances(cloudlet_name=cloudlet, region=region, token=mc.super_token, use_defaults=False)
    if len(app_list) == 0:
        print('nothing to delete')
    else:
        for a in app_list:
            name = a['data']['key']['cluster_key']['name']
            cloudletname = a['data']['key']['cloudlet_key']['name']
            cloudletorg = a['data']['key']['cloudlet_key']['organization']
            org = a['data']['key']['organization']

            if in_clusterinst_list(a):
                print('keeping', name)
            else:
                if pattern_re.match(name):
                    print('deleting', name)
                    crm_override = 1
                    try:
                        mc.delete_cluster_instance(region=region, token=mc.super_token, cluster_name=name, developer_org_name=org, cloudlet_name=cloudletname, operator_org_name=cloudletorg, crm_override=crm_override, use_defaults=False)
                    except Exception as e:
                        print(f'error deleting, {e}.trying with override')
                        try:
                           mc.delete_cluster_instance(region=region, token=mc.super_token, cluster_name=name, developer_org_name=org, cloudlet_name=cloudletname, operator_org_name=cloudletorg, crm_override='IgnoreCrmAndTransientState', use_defaults=False)
                        except Exception as e:
                           print(f'error deleting, {e}.continuing to next item')
                else:
                    print(f'keeping {name} since doesnt match keypattern={key_pattern}')


def clean_cloudlet():
    print('clean cloudlet')
    app_list = mc.show_cloudlets(region=region, token=mc.super_token, use_defaults=False)
    if len(app_list) == 0:
        print('nothing to delete')
    else:
        for a in app_list:
            name = a['data']['key']['name']
            org = a['data']['key']['organization']
            if in_cloudlet_list(a):
                print(f'keeping {name}')
            else:
               if pattern_re.match(name):
                  try:
                     print(f'deleting {name}')
                     mc.delete_cloudlet(region=region, token=mc.super_token, cloudlet_name=name, operator_org_name=org, use_defaults=False)
                  except Exception as e:
                     print(f'error deleting, {e}.trying with override')
                     try:
                        mc.delete_cloudlet(region=region, token=mc.super_token, cloudlet_name=name, operator_org_name=org, use_defaults=False, crm_override='IgnoreCrmAndTransientState')
                     except Exception as e:
                        print(f'error deleting {name}, {e}.continuing to next item')
               else:
                  print(f'keeping {name} since doesnt match keypattern={key_pattern}')

def clean_flavor():
    global key_pattern

    print('clean flavor')
    app_list = mc.show_flavors(region=region, token=mc.super_token, use_defaults=False)
    print('key',key_pattern)
    if len(app_list) == 0:
        print('nothing to delete')
    else:
        for a in app_list:
            name = a['data']['key']['name']
            if in_flavor_list(a):
                print(f'keeping {name}')
            else:
               if pattern_re.match(name):
                  try:
                     print(f'deleting {name}')
                     mc.delete_flavor(region=region, token=mc.super_token, use_defaults=False, flavor_name=name)
                  except Exception as e:
                     print(f'error deleting {name}, {e}.continuing to next item')
               else:
                  print(f'keeping {name} since doesnt match keypattern={key_pattern}')

def in_app_list(app):
    for a in app_keep:
        if a['app_name'] == app['data']['key']['name']:
            print('found app in app_keep_list', app['data']['key']['name'])
            return True

def in_appinst_list(app):
    for a in appinst_keep:
        if a['app_name'] == app['data']['key']['app_key']['name']:
            print('found app in appinst_keep_list ' + app['data']['key']['app_key']['name'])
            return True

def in_clusterinst_list(app):
    for a in clusterinst_keep:
        if a['app_name'] == app.key.name:
            print('found clusterinst in clusterinst_keep_list', app.key.name)
            return True

def in_flavor_list(app):
    for a in flavor_keep:
        if a['flavor_name'] == app['data']['key']['name']:
            print('found flavor in flavor_keep_list', app['data']['key']['name'])
            return True

def in_cloudlet_list(app):
    for a in cloudlet_keep:
        if a['cloudlet_name'] == app['data']['key']['name'] and a['operator_name'] == app['data']['key']['organization']:
            print('found cloudlet in cloudlet_keep list', app['data']['key']['name'], app['data']['key']['organization'])
            return True

def in_org_list(app):
    return False 
    #for a in operator_keep:
    #    if a['operator_name'] == app.key.name:
    #        print('found operator in operator_keep list', app.key.name)
    #        return True

def in_orgcloudletpool_list(app):
    return False

def in_autoprovpolicy_list(app):
    return False

def in_autoscalepolicy_list(app):
    return False
 
for r in region_list:
   if r in region_arg:
      region = r
      for table in table_list:
         if table in tables_arg:
            if table == 'appinst':
               clean_appinst()
            elif table == 'app':
               clean_app()
            elif table == 'clusterinst':
               clean_clusterinst()
            elif table == 'flavor':
               clean_flavor()
            elif table == 'cloudlet':
               clean_cloudlet()
            elif table == 'autoprovpolicy':
               clean_autoprovpolicy()
            elif table == 'autoscalepolicy':
               clean_autoscalepolicy()
            elif table == 'user':
               clean_user()
            #elif table == 'org':
            #   clean_org()
            elif table == 'orgcloudletpool':
               clean_orgcloudletpool()

if 'org' in tables_arg:
   clean_org()
