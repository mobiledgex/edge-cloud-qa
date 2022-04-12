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
# create app with invalid config and with Docker and QCOW
# verify app is not created
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
#config = 'config' + stamp
access_ports = 'tcp:1'
config = '"template":  "spec": { "hostAliases": [ { "ip": "37.50.143.121", "hostnames": [ "bonnedgecloud.telekom.de" ] }]}}'
config_http = 'http://35.199.188.102/apps/dummyconfig_invalid.json'
mex_root_cert = 'mex-ca.crt'
mex_cert = 'localserver.crt'
mex_key = 'localserver.key'

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

class tc(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        self.controller = mex_controller.MexController(controller_address = controller_address,
                                                    root_cert = mex_root_cert,
                                                    key = mex_key,
                                                    client_cert = mex_cert
                                                   )
        self.flavor = mex_controller.Flavor(flavor_name=flavor_name, ram=1024, vcpus=1, disk=1)
        self.developer = mex_controller.Developer(developer_name=developer_name)#,
                                                  #developer_address=developer_address,
                                                  #developer_email=developer_email)
        #self.cluster = mex_controller.Cluster(cluster_name=cluster_name,
        #                                      default_flavor_name=flavor_name)

        self.controller.create_flavor(self.flavor.flavor)
        self.controller.create_developer(self.developer.developer)
        #self.controller.create_cluster(self.cluster.cluster)

    def test_CreateAppDockerConfig_inlineInvalid(self):
        # [Documentation] App - User shall not be able to create an app with invalid inline config
        # ... create an app with invalid inline config and type Docker
        # ... verify proper error is received

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains config
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                      app_name=app_name,
                                      access_ports=access_ports,
                                      app_version=app_version,
                                      cluster_name=cluster_name,
                                      developer_name=developer_name,
                                      config=config,
                                      default_flavor_name=flavor_name)

        error = None
        try:
            resp = self.controller.create_app(self.app.app)
        except grpc.RpcError as e:
            error = e
            logger.info('got exception ' +  str(e))
        
        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect('cannot unmarshal json/yaml config str' in error.details(), 'error details')

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for AccessLayerL7 since it is not sent in create
        found_app = self.app.exists(app_post)

        expect_equal(found_app, False, 'find app')
        assert_expectations()

    def unsupported_test_CreateAppDockerConfig_httpInvalid(self):
        # [Documentation] App - User shall not be able to create an app with invalid http config
        # ... create an app with invalid http config
        # ... verify proper error is received

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains config
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                      app_name=app_name,
                                      access_ports=access_ports,
                                      app_version=app_version,
                                      cluster_name=cluster_name,
                                      developer_name=developer_name,
                                      config=config_http,
                                      default_flavor_name=flavor_name)

        error = None
        try:
            resp = self.controller.create_app(self.app.app)
        except grpc.RpcError as e:
            error = e
            logger.info('got exception ' +  str(e))

        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect('cannot unmarshal json/yaml config str' in error.details(), 'error details')

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for AccessLayerL7 since it is not sent in create
        self.app.config = config + '\n'
        found_app = self.app.exists(app_post)

        expect_equal(found_app, False, 'find app')
        assert_expectations()

    @classmethod
    def tearDownClass(self):
        #self.controller.delete_cluster(self.cluster.cluster)
        self.controller.delete_developer(self.developer.developer)
        self.controller.delete_flavor(self.flavor.flavor)

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

