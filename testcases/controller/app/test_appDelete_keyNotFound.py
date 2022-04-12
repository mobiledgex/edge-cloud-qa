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


#
# EDGECLOUD-191 - No error is given when running DeleteApp for an app it cannot find - fixed
#
# delete an app where the key is not found
# verify 'Key not found' error is received
# 

import unittest
import grpc
import sys
import time
from delayedassert import expect, expect_equal, assert_expectations
import logging
import os

import MexController as mex_controller

controller_address = os.getenv('AUTOMATION_CONTROLLER_ADDRESS', '127.0.0.1:55001')

stamp = str(time.time())
image_type = 'ImageTypeDocker'
app_name = 'app' + stamp
app_version = '1.0'
developer_name = 'developer' + stamp
developer_address = 'allen tx'
developer_email = 'dev@dev.com'
flavor_name = 'x1.small' + stamp
cluster_name = 'cluster' + stamp
access_ports = 'tcp:1'

mex_root_cert = 'mex-ca.crt'
mex_cert = 'mex-client.crt'
mex_key = 'mex-client.key'

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

class tc(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        self.controller = mex_controller.MexController(controller_address = controller_address,
#                                                    root_cert = mex_root_cert,
#                                                    key = mex_key,
#                                                    client_cert = mex_cert
                                                   )

        self.flavor = mex_controller.Flavor(flavor_name=flavor_name, ram=1024, vcpus=1, disk=1)
#        self.developer = mex_controller.Developer(developer_name=developer_name)#,
#                                                  #developer_address=developer_address,
#                                                  #developer_email=developer_email)
        #self.cluster = mex_controller.Cluster(cluster_name=cluster_name,
        #                                      default_flavor_name=flavor_name)

        self.controller.create_flavor(self.flavor.flavor)
#        self.controller.create_developer(self.developer.developer) 
        #self.controller.create_cluster(self.cluster.cluster)

    def test_DeleteAppUnknown_noKey(self):
        # [Documentation] App - User shall not be able to delete an app with no parms 
        # ... delete an app with no parms
        # ... verify 'Key not found' error is received

        # print apps before add
        apps_pre = self.controller.show_apps()

        # create the app
        self.app = mex_controller.App(image_type=image_type,
                                      app_name=app_name,
                                      app_version=app_version,
                                      access_ports=access_ports,
                                      #cluster_name=cluster_name,
                                      developer_org_name=developer_name,
                                      default_flavor_name=flavor_name)
        self.controller.create_app(self.app.app)

        # delete app
        error = None
        self.app_delete = mex_controller.App(use_defaults=False)
        try:
            self.controller.delete_app(self.app_delete.app)
        except grpc.RpcError as e:
            logger.info('got exception ' + str(e))
            error = e

        # print developers after add
        apps_post = self.controller.show_apps()

        # find app in list
        found_app = self.app.exists(apps_post)

        self.controller.delete_app(self.app.app)
        
        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(error.details(), 'App key {} not found', 'error details')
        #expect_equal(len(apps_post), len(apps_pre)+1, 'num developer')
        expect_equal(found_app, True, 'find app')

        assert_expectations()

    def test_DeleteAppUnknown_appNameOnly(self):
        # [Documentation] App - User shall not be able to delete an app with name only 
        # ... delete an app by giving name only
        # ... verify 'Key not found' error is received

        # print apps before add
        apps_pre = self.controller.show_apps()

        # create the app
        self.app = mex_controller.App(image_type=image_type,
                                      app_name=app_name,
                                      app_version=app_version,
                                      access_ports=access_ports,
                                      #cluster_name=cluster_name,
                                      developer_org_name=developer_name,
                                      default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # delete app
        error = None
        self.app_delete = mex_controller.App(app_name=app_name,
                                             use_defaults=False)

        try:
            self.controller.delete_app(self.app_delete.app)
        except grpc.RpcError as e:
            print('got exception', e)
            error = e

        # print developers after add
        apps_post = self.controller.show_apps()

        # find app in list
        found_app = self.app.exists(apps_post)

        self.controller.delete_app(self.app.app)
        
        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(error.details(), 'App key {"name":"' + app_name + '"} not found', 'error details')
        #expect_equal(len(apps_post), len(apps_pre)+1, 'num developer')
        expect_equal(found_app, True, 'find app')

        assert_expectations()


    def test_DeleteAppUnknown_wrongVersion(self):
        # [Documentation] App - User shall not be able to delete an app with the wrong version
        # ... delete an app by giving the wrong version
        # ... verify 'Key not found' error is received

        # print apps before add
        apps_pre = self.controller.show_apps()

        # create the app
        self.app = mex_controller.App(image_type=image_type,
                                      app_name=app_name,
                                      app_version=app_version,
                                      #image_path='myimagepath',
                                      access_ports=access_ports,
                                      #cluster_name=cluster_name,
                                      developer_org_name=developer_name,
                                      default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # delete app
        error = None
        self.app_delete = mex_controller.App(app_name=app_name,
                                             developer_org_name=developer_name,
                                             app_version="1.1",
                                             use_defaults=False)

        try:
            self.controller.delete_app(self.app_delete.app)
        except grpc.RpcError as e:
            print('got exception', e)
            error = e

        # print developers after add
        apps_post = self.controller.show_apps()

        # find app in list
        found_app = self.app.exists(apps_post)

        self.controller.delete_app(self.app.app)
        
        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(error.details(), 'App key {"organization":"' + developer_name + '","name":"' + app_name + '","version":"1.1"} not found', 'error details')
        #expect_equal(len(apps_post), len(apps_pre)+1, 'num developer')
        expect_equal(found_app, True, 'find app')

        assert_expectations()

    def test_DeleteAppUnknown_wrongDeveloperName(self):
        # [Documentation] App - User shall not be able to delete an app with the wrong developer
        # ... delete an app by giving the wrong developer
        # ... verify 'Key not found' error is received

        # print apps before add
        apps_pre = self.controller.show_apps()

        # create the app
        self.app = mex_controller.App(image_type=image_type,
                                      app_name=app_name,
                                      app_version=app_version,
                                      #image_path='myimagepath',
                                      access_ports=access_ports,
                                      #cluster_name=cluster_name,
                                      developer_org_name=developer_name,
                                      default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # delete app
        error = None
        self.app_delete = mex_controller.App(app_name=app_name,
                                             developer_org_name=developer_name + 'wrong',
                                             app_version=app_version,
                                             use_defaults=False)

        try:
            self.controller.delete_app(self.app_delete.app)
        except grpc.RpcError as e:
            print('got exception', e)
            error = e

        # print developers after add
        apps_post = self.controller.show_apps()

        # find app in list
        found_app = self.app.exists(apps_post)

        self.controller.delete_app(self.app.app)
        
        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(error.details(), 'App key {"organization":"' + developer_name + 'wrong","name":"' + app_name + '","version":"1.0"} not found', 'error details')
        #expect_equal(len(apps_post), len(apps_pre)+1, 'num developer')
        expect_equal(found_app, True, 'find app')


    @classmethod
    def tearDownClass(self):
        #self.controller.delete_cluster(self.cluster.cluster)
#        self.controller.delete_developer(self.developer.developer)
        self.controller.delete_flavor(self.flavor.flavor)

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

