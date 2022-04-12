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
# create app with no ports and IpAccessDedicated, IpAccessDedicatedOrShared, IpAccessShared
# verify 'Please specify access ports' is received
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
app_name = 'appname' + stamp
app_version = '1.0'
developer_name = 'developer' + stamp
developer_address = 'allen tx'
developer_email = 'dev@dev.com'
flavor_name = 'x1.small' + stamp
cluster_name = 'cluster' + stamp
docker_image = 'docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0'

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

#        self.developer = mex_controller.Developer(developer_org_name=developer_name)#,
#                                                  #developer_address=developer_address,
#                                                  #developer_email=developer_email)
        #self.cluster = mex_controller.Cluster(cluster_name=cluster_name,
        #                                      default_flavor_name=flavor_name)

        self.controller.create_flavor(self.flavor.flavor)
#        self.controller.create_developer(self.developer.developer)
        #self.controller.create_cluster(self.cluster.cluster)

    def test_CreateAppNoPortsDedicated(self):
        # [Documentation] App - User shall be able to create an app with no ports and ipaccess=IpAccessDedicated 
        # ... create app with no ports and IpAccessDedicated
        # ... verify app is created

        # print the existing apps 
        app_pre = self.controller.show_apps()

        # create the app with no parms
        error = None
        app = mex_controller.App(image_type='ImageTypeDocker',
                                 developer_org_name=developer_name,
                                 app_name=app_name,
                                 app_version=app_version,
                                 image_path=docker_image,
                                 #ip_access='IpAccessDedicated',
                                 #cluster_name=cluster_name,
                                 default_flavor_name=flavor_name,
                                 use_defaults=False)

        resp = self.controller.create_app(app.app)
            
        #try:
        #    resp = self.controller.create_app(app.app)
        #except grpc.RpcError as e:
        #    logger.info('got exception ' + str(e))
        #    error = e

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        #expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        #expect_equal(error.details(), 'Please specify access ports', 'error details')
        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
        #assert_expectations()

        # look for app
        #app.image_path = 'docker.mobiledgex.net/' + developer_name + '/images/' + app_name + ':1.0'
        app.access_ports = ''
        found_app = app.exists(app_post)

        self.controller.delete_app(app.app)
        
        expect_equal(found_app, True, 'find app')
        assert_expectations()

#    def test_CreateAppNoPortsIpAccessDedicatedorShared(self):
#        # [Documentation] App - User shall be able to create an app with no ports and ipaccess=IpAccessDedicatedOrShared
#        # ... create app with no ports and IpAccessDedicatedOrShared
#        # ... verify app is created
#
#        # print the existing apps
#        app_pre = self.controller.show_apps()
#
#        # create the app with no parms
#        error = None
#        app = mex_controller.App(image_type='ImageTypeDocker',
#                                 developer_org_name=developer_name,
#                                 app_name=app_name,
#                                 app_version=app_version,
#                                 ip_access='IpAccessDedicatedOrShared',
#                                 cluster_name=cluster_name,
#                                 default_flavor_name=flavor_name,
#                                 use_defaults=False)
#
#        resp = self.controller.create_app(app.app)
#                
#        #try:
#        #    resp = self.controller.create_app(app.app)
#        #except grpc.RpcError as e:
#        #    logger.info('got exception ' + str(e))
#        #    error = e
#
#        # print the cluster instances after error
#        app_post = self.controller.show_apps()
#
#        #expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
#        #expect_equal(error.details(), 'Please specify access ports', 'error details')
#        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
#        #assert_expectations()
#
#
#        # look for app
#        app.image_path = 'registry.mobiledgex.net:5000/' + developer_name + '/' + app_name + ':1.0'
#        app.access_ports = ''
#        found_app = app.exists(app_post)
#
#        self.controller.delete_app(app.app)
#        
#        expect_equal(found_app, True, 'find app')
#        assert_expectations()
#
#    def test_CreateAppNoPortsIpAccessShared(self):
#        # [Documentation] App - User shall be able to create an app with no ports and ipaccess=IpAccessShared
#        # ... create app with no ports and IpAccessShared
#        # ... verify app is created
#
#        # print the existing apps
#        app_pre = self.controller.show_apps()
#
#        # create the app with no parms
#        error = None
#        app = mex_controller.App(image_type='ImageTypeDocker',
#                                 developer_org_name=developer_name,
#                                 app_name=app_name,
#                                 app_version=app_version,
#                                 ip_access='IpAccessShared',
#                                 cluster_name=cluster_name,
#                                 default_flavor_name=flavor_name,
#                                 use_defaults=False)
#
#        resp = self.controller.create_app(app.app)
#
#        #try:
#        #    resp = self.controller.create_app(app.app)
#        #except grpc.RpcError as e:
#        #    logger.info('got exception ' + str(e))
#        #    error = e
#
#        # print the cluster instances after error
#        app_post = self.controller.show_apps()
#
#        #expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
#        #expect_equal(error.details(), 'Please specify access ports', 'error details')
#        #expect_equal(len(app_pre), len(app_post), 'same number of apps')
#        #assert_expectations()
#
#        # look for app
#        app.image_path = 'registry.mobiledgex.net:5000/' + developer_name + '/' + app_name + ':1.0'
#        app.access_ports = ''
#        found_app = app.exists(app_post)
#
#        self.controller.delete_app(app.app)
#        
#        expect_equal(found_app, True, 'find app')
#        assert_expectations()
#
    @classmethod
    def tearDownClass(self):
        #self.controller.delete_cluster(self.cluster.cluster)
#        self.controller.delete_developer(self.developer.developer)
        self.controller.delete_flavor(self.flavor.flavor)


if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

