#!/usr/local/bin/python3

# copy needed proto files into 1 directory
# I originally tried building these from the original path but ran into problems

import os
import sys
import argparse
import logging
import MexController as mex_controller

parser = argparse.ArgumentParser(description='clean prov from controller')
parser.add_argument('--address', default='127.0.0.1:55001', help='controller address:port default is 127.0.0.1:55001')
#parser.add_argument('--components',required=True, help='comma seperated list of components. example: Automated,Controller,Operator')
#parser.add_argument('--versions',required=True, help='comma seperated list of versions. example: Nimbus')
#parser.add_argument('--outfile',required=False, default='tc_import.csv', help='csv outfile to write to. default is tc_import.csv')
#parser.add_argument('--filepattern',required=False, default='test_*.py', help='file match pattern for testcase parsing. default is test_*.py')

args = parser.parse_args()

controller_address = args.address

mex_root_cert = 'mex-ca.crt'
mex_cert = 'localserver.crt'
mex_key = 'localserver.key'

#appinst_keep = [{'app_name':'automation_api_app'}, {'app_name':'MEXPrometheusAppName'}, {'app_name':'MEXMetricsExporter'}]
#app_keep = [{'app_name':'automation_api_auth_app'}, {'app_name':'automation_api_app'},{'app_name':'MEXPrometheusAppName'}, {'app_name':'MEXMetricsExporter'}]
appinst_keep = [{'app_name':'automation_api_app'}]
app_keep = [{'app_name':'automation_api_auth_app'}, {'app_name':'automation_api_app'}]
clusterinst_keep = []
cluster_keep = [{'cluster_name':'automationapicluster'}]
clusterflavor_keep = [{'cluster_flavor_name':'automation_api_cluster_flavor'},{'cluster_flavor_name':'x1.medium'}]
cloudlet_keep = [{'cloudlet_name': 'automationBonnCloudlet', 'operator_name': 'TDG'},{'cloudlet_name': 'automationBerlinCloudlet', 'operator_name': 'TDG'},{'cloudlet_name': 'automationHamburgCloudlet', 'operator_name': 'TDG'},{'cloudlet_name': 'attcloud-1', 'operator_name': 'att'},{'cloudlet_name': 'tmocloud-1', 'operator_name': 'tmus'},{'cloudlet_name': 'tmocloud-2', 'operator_name': 'tmus'},{'cloudlet_name': 'automationProdHamburgCloudlet', 'operator_name': 'TDG'},{'cloudlet_name': 'automationAzureCentralCloudlet', 'operator_name': 'azure'}]
flavor_keep = [{'flavor_name':'x1.medium'},{'flavor_name':'automation_api_flavor'}]
developer_keep = [{'developer_name':'automation_api'},{'developer_name':'mexinfradev_'}]
operator_keep = [{'operator_name': 'TDG'},{'operator_name': 'gcp'},{'operator_name': 'tmus'},{'operator_name': 'att'},{'operator_name': 'azure'}]

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

controller = mex_controller.MexController(controller_address = controller_address,
                                       root_cert = mex_root_cert,
                                       key = mex_key,
                                       client_cert = mex_cert
)

def clean_appinst():
    print('clean appinst')
    appinst_list = controller.show_app_instances()
    if len(appinst_list) == 0:
        print('nothing to delete')
    else:
        for a in appinst_list:
            print('aaa',a.key.app_key.name)
            if in_appinst_list(a):
                print('keeping', a.key.app_key.name)
            else:
                print('deleting', a.key.app_key.name)
                a.crm_override = 1
                controller.delete_app_instance(a)

def clean_app():
    print('clean app')
    app_list = controller.show_apps()
    if len(app_list) == 0:
        print('nothing to delete')
    else:
        for a in app_list:
            print('aaa',a.key.name, a.key.version, a.key.developer_key.name)
            if in_app_list(a):
                print('keeping', a.key.name)
            else:
                print('deleting', a.key.name)
                controller.delete_app(a)

def clean_clusterinst():
    print('clean cluster instance')
    app_list = controller.show_cluster_instances()
    if len(app_list) == 0:
        print('nothing to delete')
    else:
        for a in app_list:
            print('aaa',a.key.cluster_key.name, a.key.cloudlet_key.name, a.key.cloudlet_key.operator_key.name)
            if in_clusterinst_list(a):
                print('keeping', a.key.cluster_key.name)
            else:
                print('deleting', a.key.cluster_key.name)
                a.crm_override = 1
                try:
                    controller.delete_cluster_instance(a)
                except:
                    print('error deleting.continuing to next item')

def clean_cluster():
    print('clean cluster')
    app_list = controller.show_clusters()
    if len(app_list) == 0:
        print('nothing to delete')
    else:
        for a in app_list:
            print('aaa',a.key.name)
            if in_cluster_list(a):
                print('keeping', a.key.name)
            else:
                print('deleting', a.key.name)
                try:
                    controller.delete_cluster(a)
                except:
                    print('error deleting.continuing to next item')
                    

def clean_clusterflavor():
    print('clean cluster flavor')
    app_list = controller.show_cluster_flavors()
    if len(app_list) == 0:
        print('nothing to delete')
    else:
        for a in app_list:
            print('aaa',a.key.name)
            if in_clusterflavor_list(a):
                print('keeping', a.key.name)
            else:
                print('deleting', a.key.name)
                controller.delete_cluster_flavor(a)

def clean_cloudlet():
    print('clean cloudlet')
    app_list = controller.show_cloudlets()
    if len(app_list) == 0:
        print('nothing to delete')
    else:
        for a in app_list:
            print('aaa',a.key.name)
            if in_cloudlet_list(a):
                print('keeping', a.key.name)
            else:
                print('deleting', a.key.name)
                controller.delete_cloudlet(a)

def clean_flavor():
    print('clean flavor')
    app_list = controller.show_flavors()
    if len(app_list) == 0:
        print('nothing to delete')
    else:
        for a in app_list:
            print('aaa',a.key.name)
            if in_flavor_list(a):
                print('keeping', a.key.name)
            else:
                print('deleting', a.key.name)
                try:
                    controller.delete_flavor(a)
                except:
                    print('error deleting.continuing to next item')

def clean_developer():
    print('clean developer')
    app_list = controller.show_developers()
    if len(app_list) == 0:
        print('nothing to delete')
    else:
        for a in app_list:
            print('aaa',a.key.name)
            if in_developer_list(a):
                print('keeping', a.key.name)
            else:
                print('deleting', a.key.name)
                controller.delete_developer(a)

def clean_operator():
    print('clean operator')
    app_list = controller.show_operators()
    if len(app_list) == 0:
        print('nothing to delete')
    else:
        for a in app_list:
            print('aaa',a.key.name)
            if in_operator_list(a):
                print('keeping', a.key.name)
            else:
                print('deleting', a.key.name)
                controller.delete_operator(a)

def in_app_list(app):
    for a in app_keep:
        if a['app_name'] == app.key.name:
            print('found app in app_keep_list', app.key.name)
            return True

def in_appinst_list(app):
    for a in appinst_keep:
        if a['app_name'] == app.key.app_key.name:
            print('found app in appinst_keep_list', app.key.app_key.name)
            return True

def in_clusterinst_list(app):
    for a in clusterinst_keep:
        if a['app_name'] == app.key.name:
            print('found clusterinst in clusterinst_keep_list', app.key.name)
            return True

def in_cluster_list(cluster):
    for a in cluster_keep:
        if a['cluster_name'] == cluster.key.name:
            print('found cluster in cluster_keep_list', cluster.key.name)
            return True

def in_clusterflavor_list(app):
    for a in clusterflavor_keep:
        if a['cluster_flavor_name'] == app.key.name:
            print('found cluster flavor in clusterflavor_keep_list', app.key.name)
            return True

def in_flavor_list(app):
    for a in flavor_keep:
        if a['flavor_name'] == app.key.name:
            print('found flavor in flavor_keep_list', app.key.name)
            return True

def in_cloudlet_list(app):
    for a in cloudlet_keep:
        if a['cloudlet_name'] == app.key.name and a['operator_name'] == app.key.operator_key.name:
            print('found cloudlet in cloudlet_keep list', app.key.name, app.key.operator_key.name)
            return True

def in_developer_list(app):
    for a in developer_keep:
        if a['developer_name'] == app.key.name:
            print('found developer in developer_keep list', app.key.name)
            return True

def in_operator_list(app):
    for a in operator_keep:
        if a['operator_name'] == app.key.name:
            print('found operator in operator_keep list', app.key.name)
            return True

clean_appinst()
clean_app()
clean_clusterinst()
clean_cluster()
clean_clusterflavor()
clean_flavor()
clean_cloudlet()
clean_developer()
clean_operator()



