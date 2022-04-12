#!/usr/local/bin/python3
# Copyright 2022 MobiledgeX, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# copy needed proto files into 1 directory
# I originally tried building these from the original path but ran into problems

import os
import sys
import argparse
import logging
import MexController as mex_controller

parser = argparse.ArgumentParser(description='clean prov from controller')
parser.add_argument('--address', default='127.0.0.1:55001', help='controller address:port default is 127.0.0.1:55001')

args = parser.parse_args()

controller_address = args.address

mex_root_cert = 'mex-ca.crt'
mex_cert = 'localserver.crt'
mex_key = 'localserver.key'


appinst_delete = [{'cloudlet_name':'automationBonnCloudlet'},{'cloudlet_name':'automationMunichCloudlet'}]
clusterinst_delete = [{'cloudlet_name':'automationBonnCloudlet'},{'cloudlet_name':'automationMunichCloudlet'}]

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
            #print('aaa',a.key.app_key.name)
            if not in_appinst_list(a):
                print('keeping', a.key.app_key.name)
            else:
                print('***deleting', a.key.app_key.name)
                #a.crm_override = 1
                controller.delete_app_instance(a)

def clean_clusterinst():
    print('clean cluster instance')
    app_list = controller.show_cluster_instances()
    if len(app_list) == 0:
        print('nothing to delete')
    else:
        for a in app_list:
            #print('aaa',a.key.cluster_key.name, a.key.cloudlet_key.name, a.key.cloudlet_key.operator_key.name)
            if not in_clusterinst_list(a):
                print('keeping', a.key.cluster_key.name)
            else:
                print('**** deleting', a.key.cluster_key.name)
                #a.crm_override = 4
                try:
                    controller.delete_cluster_instance(a)
                except:
                    print('error deleting.continuing to next item')

def in_appinst_list(app):
    for a in appinst_delete:
        #print(a['cloudlet_name'], app.key.cluster_inst_key.cloudlet_key.name)
        if a['cloudlet_name'] == app.key.cluster_inst_key.cloudlet_key.name:
            #print('found app in appinst_del_list', app.key.name)
            return True

def in_clusterinst_list(app):
    for a in clusterinst_delete:
        print()
        if a['cloudlet_name'] == app.key.cloudlet_key.name:
            print('found clusterinst in clusterinst_keep_list', app.key.cluster_key.name)
            return True

clean_appinst()
clean_clusterinst()
