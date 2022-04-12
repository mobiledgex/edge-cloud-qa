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
# create app with image_type=ImageTypeQCOW and empty/no imagepath
# verify image_path='qcow path not determined yet' 
# 

import unittest
import grpc
import sys
import time
import logging
from delayedassert import expect, expect_equal, assert_expectations
import os

import MexController as mex_controller

controller_address = os.getenv('AUTOMATION_CONTROLLER_ADDRESS', '127.0.0.1:55001')

stamp = str(time.time())
developer_name = 'developer' + stamp
developer_address = 'allen tx'
developer_email = 'dev@dev.com'
flavor_name = 'x1.small' + stamp
cluster_name = 'cluster' + stamp
app_name = 'app' + stamp
app_version = '1.0'
access_ports = 'udp:2'

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

    def test_CreateAppQCOWNoImagePath(self):
        # [Documentation] App - User shall not be able to create an app of type QCOW and no image path
        # ... create an app with image_type=ImageTypeQCOW and no image path
        # ... verify error='imagepath is required for imagetype ImageTypeQCOW'

        # print the existing apps 
        app_pre = self.controller.show_apps()

        # create the app
        # contains image_type=QCOW
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                      app_name=app_name,
                                      app_version=app_version,
                                      #ip_access='IpAccessDedicatedOrShared',
                                      access_ports=access_ports,
                                      #cluster_name=cluster_name,
                                      developer_org_name=developer_name,
                                      default_flavor_name=flavor_name,
                                      use_defaults=False)
        #resp = self.controller.create_app(self.app.app)

        error = None
        try:
            resp = self.controller.create_app(self.app.app)
        except grpc.RpcError as e:
            logger.info('got exception ' + str(e))
            error = e

        # print the cluster instances after error
        apps_post = self.controller.show_apps()

        # find app in list
        found_app = self.app.exists(apps_post)

        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        #expect_equal(error.details(), 'imagepath is required for imagetype IMAGE_TYPE_QCOW', 'error details')
        expect_equal(error.details(), 'Md5sum should be provided if imagepath is not specified', 'error details')
        expect_equal(found_app, False, 'find app')

        assert_expectations()

    def test_CreateAppQCOWEmptyImagePath(self):
        # [Documentation] App - User shall not be able to create an app of type QCOW and empty image path
        # ... create an app with image_type=ImageTypeQCOW and empty image path
        # ... verify error='imagepath is required for imagetype ImageTypeQCOW'

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains image_type=QCOW
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                      image_path='',
                                      app_name=app_name,
                                      app_version=app_version,
                                      #ip_access='IpAccessDedicated',
                                      access_ports=access_ports,
                                      #cluster_name=cluster_name,
                                      developer_org_name=developer_name,
                                      default_flavor_name=flavor_name,
                                      use_defaults=False)
        #resp = self.controller.create_app(self.app.app)

        error = None
        try:
            resp = self.controller.create_app(self.app.app)
        except grpc.RpcError as e:
            logger.info('got exception ' + str(e))
            error = e

        # print the cluster instances after error
        apps_post = self.controller.show_apps()

        # find app in list
        found_app = self.app.exists(apps_post)

        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        #expect_equal(error.details(), 'imagepath is required for imagetype IMAGE_TYPE_QCOW', 'error details')
        expect_equal(error.details(), 'Md5sum should be provided if imagepath is not specified', 'error details')
        expect_equal(found_app, False, 'find app')

        assert_expectations()

    @classmethod
    def tearDownClass(self):
        #self.controller.delete_cluster(self.cluster.cluster)
#        self.controller.delete_developer(self.developer.developer)
        self.controller.delete_flavor(self.flavor.flavor)

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

