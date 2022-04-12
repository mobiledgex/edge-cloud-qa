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
# create app with image_type=ImageTypeDocker and empty/no imagepath
# verify image_path='mobiledgex_' 
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
developer_name = 'developer' + stamp
developer_address = 'allen tx'
developer_email = 'dev@dev.com'
flavor_name = 'x1.small' + stamp
cluster_name = 'cluster' + stamp
app_name = 'app' + stamp
app_version = '1.0'
#ip_access = 'IpAccessDedicatedOrShared'
access_ports = 'tcp:1,tcp:2'

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

        # create the app
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                      app_name=app_name,
                                      app_version=app_version,
                                      #ip_access=ip_access,
                                      access_ports=access_ports,
                                      #cluster_name=cluster_name,
                                      developer_org_name=developer_name,
                                      default_flavor_name=flavor_name)

        self.controller.create_flavor(self.flavor.flavor)
#        self.controller.create_developer(self.developer.developer) 
        #self.controller.create_cluster(self.cluster.cluster)
        self.controller.create_app(self.app.app)


    def test_QueryAppName(self):
        # [Documentation] App - User shall be able to show an app by app name only
        # ... show app by app name only
        # ... verify proper app is shown

        # print the existing apps 
        app = mex_controller.App(app_name=app_name, use_defaults=False)
        app_show = self.controller.show_apps(app.app)

        # find app in list
        found_app = self.app.exists(app_show)

        expect_equal(len(app_show), 1, 'number of apps')
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_QueryDeveloperName(self):
        # [Documentation] App - User shall be able to show an app by developer name only
        # ... show app by developer name only
        # ... verify proper app is shown

        # print the existing apps
        print('devvvvvvvvvvvvvvvvvv', developer_name)
        app = mex_controller.App(developer_org_name=developer_name, use_defaults=False)
        print('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$', app.app)
        app_show = self.controller.show_apps(app.app)

        # find app in list
        found_app = self.app.exists(app_show)

        expect_equal(len(app_show), 1, 'number of apps')
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_QueryAppNameVersion(self):
        # [Documentation] App - User shall be able to show an app by app name and version
        # ... show app by app name and version
        # ... verify proper app is shown

        # print the existing apps
        app = mex_controller.App(app_name=app_name, app_version=app_version, use_defaults=False)
        app_show = self.controller.show_apps(app.app)

        # find app in list
        found_app = self.app.exists(app_show)

        expect_equal(len(app_show), 1, 'number of apps')
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    @classmethod
    def tearDownClass(self):
        self.controller.delete_app(self.app.app)
        #self.controller.delete_cluster(self.cluster.cluster)
#        self.controller.delete_developer(self.developer.developer)
        self.controller.delete_flavor(self.flavor.flavor)

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

