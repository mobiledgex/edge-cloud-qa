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
# create app with ip_access=IpAccessDedicatedw with port 1 and with Docker and QCOW
# verify app is created
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

    def test_CreateAppDockerIpAccessDedicatedTCP1(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicated/ImageTypeDocker/tcp:1
        # ... create app with ip_access=IpAccessDedicated with tcp:1 and with Docker
        # ... verify app is created

        # print the existing apps 
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicated and port=tcp:1
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             #ip_access = 'IpAccessDedicated',
                                             access_ports = 'tcp:1',
                                             default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)

        port_match = 'ports:\n        - containerPort: 1\n          protocol: TCP'
        expect(port_match in resp.deployment_manifest, 'manifest ports')
        
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppDockerIpAccessDedicatedTCP01(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicated/ImageTypeDocker/tcp:01
        # ... create app with ip_access=IpAccessDedicated with tcp:01 and with Docker
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicated and port=tcp:01
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             #ip_access = 'IpAccessDedicated',
                                             access_ports = 'tcp:01',
                                             default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)
       
        port_match = 'ports:\n        - containerPort: 1\n          protocol: TCP'
        expect(port_match in resp.deployment_manifest, 'manifest ports')
 
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppDockerIpAccessDedicatedHTTP1(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicated/ImageTypeDocker/http:1
        # ... create app with ip_access=IpAccessDedicated with http:1 and with Docker
        # ... verify app is created

        # EDGECLOUD-371 - CreateApp with accessports of http shows protocol as TCP on ShowApp

        # print the existing apps 
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicated and port=tcp:1
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             #ip_access = 'IpAccessDedicated',
                                             access_ports = 'http:1',
                                             default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)

        port_match = 'ports:\n        - containerPort: 1\n          protocol: TCP'
        expect(port_match in resp.deployment_manifest, 'manifest ports')
        
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppDockerIpAccessDedicatedHTTP01(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicated/ImageTypeDocker/http:01
        # ... create app with ip_access=IpAccessDedicated with http:01 and with Docker
        # ... verify app is created

        # EDGECLOUD-371 - CreateApp with accessports of http shows protocol as TCP on ShowApp

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicated and port=tcp:01
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             #ip_access = 'IpAccessDedicated',
                                             access_ports = 'http:01',
                                             default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)

        port_match = 'ports:\n        - containerPort: 1\n          protocol: TCP'
        expect(port_match in resp.deployment_manifest, 'manifest ports')
        
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppDockerIpAccessDedicatedUDP1(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicated/ImageTypeDocker/udp:1
        # ... create app with ip_access=IpAccessDedicated with udp:1 and with Docker
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicated and port=udp:1
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             #ip_access = 'IpAccessDedicated',
                                             access_ports = 'udp:1',
                                             default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)
       
        port_match = 'ports:\n        - containerPort: 1\n          protocol: UDP'
        expect(port_match in resp.deployment_manifest, 'manifest ports')
 
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppDockerIpAccessDedicatedUDP01(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicated/ImageTypeDocker/udp:01
        # ... create app with ip_access=IpAccessDedicated with udp:01 and with Docker
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicated and port=udp:01
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             #ip_access = 'IpAccessDedicated',
                                             access_ports = 'udp:01',
                                             default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)
               
        port_match = 'ports:\n        - containerPort: 1\n          protocol: UDP'
        expect(port_match in resp.deployment_manifest, 'manifest ports')
 
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppQCOWIpAccessDedicatedTCP1(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicated/ImageTypeQCOW/tcp:1
        # ... create app with ip_access=IpAccessDedicated with tcp:1 and with QCOW 
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicated QCOW tcp:1
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             #ip_access = 'IpAccessDedicated',
                                             access_ports = 'tcp:1',
                                             default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)
        
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppQCOWIpAccessDedicatedTCP01(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicated/ImageTypeQCOW/tcp:01
        # ... create app with ip_access=IpAccessDedicated with tcp:01 and with QCOW
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicated QCOW tcp:1
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             #ip_access = 'IpAccessDedicated',
                                             access_ports = 'tcp:01',
                                             default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)
        
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppQCOWIpAccessDedicatedUDP1(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicated/ImageTypeQCOW/udp:1
        # ... create app with ip_access=IpAccessDedicated with udp:1 and with QCOW
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicated QCOW udp:1
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             #ip_access = 'IpAccessDedicated',
                                             access_ports = 'udp:1',
                                             default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)
        
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppQCOWIpAccessDedicatedUDP01(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicated/ImageTypeQCOW/udp:01
        # ... create app with ip_access=IpAccessDedicated with udp:01 and with QCOW
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicated QCOW udp:01
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             #ip_access = 'IpAccessDedicated',
                                             access_ports = 'udp:01',
                                             default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)
        
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppQCOWIpAccessDedicatedHTTP1(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicated/ImageTypeQCOW/http:1
        # ... create app with ip_access=IpAccessDedicated with http:1 and with QCOW
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicated QCOW udp:1
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             #ip_access = 'IpAccessDedicated',
                                             access_ports = 'http:1',
                                             default_flavor_name=flavor_name)

        error = None
        try:
            resp = self.controller.create_app(self.app.app)
        except grpc.RpcError as e:
            logger.info('got exception ' + str(e))
            error = e

        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(error.details(), 'Deployment Type and HTTP access ports are incompatible', 'error details')
        assert_expectations()

        #resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        #app_post = self.controller.show_apps()

        # look for app
        #found_app = self.app.exists(app_post)

        #self.controller.delete_app(self.app.app)
        
        #expect_equal(found_app, True, 'find app')
        #assert_expectations()

    def test_CreateAppQCOWIpAccessDedicatedHTTP01(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicated/ImageTypeQCOW/http:01
        # ... create app with ip_access=IpAccessDedicated with http:01 and with QCOW
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicated QCOW udp:01
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             #ip_access = 'IpAccessDedicated',
                                             access_ports = 'http:01',
                                             default_flavor_name=flavor_name)
        error = None
        try:
            resp = self.controller.create_app(self.app.app)
        except grpc.RpcError as e:
            logger.info('got exception ' + str(e))
            error = e

        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(error.details(), 'Deployment Type and HTTP access ports are incompatible', 'error details')
        assert_expectations()

        #resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        #app_post = self.controller.show_apps()

        # look for app
        #found_app = self.app.exists(app_post)

        #self.controller.delete_app(self.app.app)
                
        #expect_equal(found_app, True, 'find app')
        #assert_expectations()

    @classmethod
    def tearDownClass(self):
        #self.controller.delete_cluster(self.cluster.cluster)
#        self.controller.delete_developer(self.developer.developer)
        self.controller.delete_flavor(self.flavor.flavor)

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

