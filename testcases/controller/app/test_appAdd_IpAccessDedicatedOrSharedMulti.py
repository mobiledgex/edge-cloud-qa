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
# create app with ip_access=IpAccessDedicatedOrShared with various ports for Docker and QCOW
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
qcow_image = 'https://artifactory-qa.mobiledgex.net/artifactory/mobiledgex/server_ping_threaded_centos7.qcow2#md5:eddafc541f1642b76a1c30062116719d'

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

    def test_CreateAppDockerIpAccessDedicatedOrSharedTCP2Ports(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicatedOrShared/ImageTypeDocker and 2 tcp ports
        # ... create app with ip_access=IpAccessDedicatedOrShared, type=Docker, and 2 tcp ports
        # ... verify app is created

        # print the existing apps 
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicatedOrShared and 2 tcp ports
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessDedicatedOrShared',
                                             access_ports = 'tcp:655,tcp:2',
                                             default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)

        port_match = 'ports:\n        - containerPort: 655\n          protocol: TCP\n        - containerPort: 2\n          protocol: TCP'
        expect(port_match in resp.deployment_manifest, 'manifest ports')
        
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppDockerIpAccessDedicatedOrSharedTCP10Ports(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicatedOrShared/ImageTypeDocker and 10 tcp ports
        # ... create app with ip_access=IpAccessDedicatedOrShared, type=Docker, and 10 tcp ports
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicatedOrShared and 10 tcp ports
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessDedicatedOrShared',
                                             access_ports = 'tcp:1,tcp:2,tcp:3,tcp:4,tcp:5,tcp:6,tcp:7,tcp:8,tcp:9,tcp:10',
                                             default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)

        port_match = 'ports:\n        - containerPort: 1\n          protocol: TCP\n        - containerPort: 2\n          protocol: TCP\n        - containerPort: 3\n          protocol: TCP\n        - containerPort: 4\n          protocol: TCP\n        - containerPort: 5\n          protocol: TCP\n        - containerPort: 6\n          protocol: TCP\n        - containerPort: 7\n          protocol: TCP\n        - containerPort: 8\n          protocol: TCP\n        - containerPort: 9\n          protocol: TCP\n        - containerPort: 10\n          protocol: TCP'
        expect(port_match in resp.deployment_manifest, 'manifest ports')
        
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppDockerIpAccessDedicatedOrSharedTCP100Ports(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicatedOrShared/ImageTypeDocker and 100 tcp ports
        # ... create app with ip_access=IpAccessDedicatedOrShared, type=Docker, and 100 tcp ports
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicatedOrShared and 100 tcp ports
        tcp_list = ''
        for i in range(100):
            tcp_list += 'tcp:' + str(i+1) + ','
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessDedicatedOrShared',
                                             access_ports = tcp_list[:-1],
                                             default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)
       
        port_match = 'ports:\n        - containerPort: 1\n          protocol: TCP\n        - containerPort: 2\n          protocol: TCP\n        - containerPort: 3\n          protocol: TCP\n        - containerPort: 4\n          protocol: TCP\n        - containerPort: 5\n          protocol: TCP\n        - containerPort: 6\n          protocol: TCP\n        - containerPort: 7\n          protocol: TCP\n        - containerPort: 8\n          protocol: TCP\n        - containerPort: 9\n          protocol: TCP\n        - containerPort: 10\n          protocol: TCP\n        - containerPort: 11\n          protocol: TCP\n        - containerPort: 12\n          protocol: TCP\n        - containerPort: 13\n          protocol: TCP\n        - containerPort: 14\n          protocol: TCP\n        - containerPort: 15\n          protocol: TCP\n        - containerPort: 16\n          protocol: TCP\n        - containerPort: 17\n          protocol: TCP\n        - containerPort: 18\n          protocol: TCP\n        - containerPort: 19\n          protocol: TCP\n        - containerPort: 20\n          protocol: TCP\n        - containerPort: 21\n          protocol: TCP\n        - containerPort: 22\n          protocol: TCP\n        - containerPort: 23\n          protocol: TCP\n        - containerPort: 24\n          protocol: TCP\n        - containerPort: 25\n          protocol: TCP\n        - containerPort: 26\n          protocol: TCP\n        - containerPort: 27\n          protocol: TCP\n        - containerPort: 28\n          protocol: TCP\n        - containerPort: 29\n          protocol: TCP\n        - containerPort: 30\n          protocol: TCP\n        - containerPort: 31\n          protocol: TCP\n        - containerPort: 32\n          protocol: TCP\n        - containerPort: 33\n          protocol: TCP\n        - containerPort: 34\n          protocol: TCP\n        - containerPort: 35\n          protocol: TCP\n        - containerPort: 36\n          protocol: TCP\n        - containerPort: 37\n          protocol: TCP\n        - containerPort: 38\n          protocol: TCP\n        - containerPort: 39\n          protocol: TCP\n        - containerPort: 40\n          protocol: TCP\n        - containerPort: 41\n          protocol: TCP\n        - containerPort: 42\n          protocol: TCP\n        - containerPort: 43\n          protocol: TCP\n        - containerPort: 44\n          protocol: TCP\n        - containerPort: 45\n          protocol: TCP\n        - containerPort: 46\n          protocol: TCP\n        - containerPort: 47\n          protocol: TCP\n        - containerPort: 48\n          protocol: TCP\n        - containerPort: 49\n          protocol: TCP\n        - containerPort: 50\n          protocol: TCP\n        - containerPort: 51\n          protocol: TCP\n        - containerPort: 52\n          protocol: TCP\n        - containerPort: 53\n          protocol: TCP\n        - containerPort: 54\n          protocol: TCP\n        - containerPort: 55\n          protocol: TCP\n        - containerPort: 56\n          protocol: TCP\n        - containerPort: 57\n          protocol: TCP\n        - containerPort: 58\n          protocol: TCP\n        - containerPort: 59\n          protocol: TCP\n        - containerPort: 60\n          protocol: TCP\n        - containerPort: 61\n          protocol: TCP\n        - containerPort: 62\n          protocol: TCP\n        - containerPort: 63\n          protocol: TCP\n        - containerPort: 64\n          protocol: TCP\n        - containerPort: 65\n          protocol: TCP\n        - containerPort: 66\n          protocol: TCP\n        - containerPort: 67\n          protocol: TCP\n        - containerPort: 68\n          protocol: TCP\n        - containerPort: 69\n          protocol: TCP\n        - containerPort: 70\n          protocol: TCP\n        - containerPort: 71\n          protocol: TCP\n        - containerPort: 72\n          protocol: TCP\n        - containerPort: 73\n          protocol: TCP\n        - containerPort: 74\n          protocol: TCP\n        - containerPort: 75\n          protocol: TCP\n        - containerPort: 76\n          protocol: TCP\n        - containerPort: 77\n          protocol: TCP\n        - containerPort: 78\n          protocol: TCP\n        - containerPort: 79\n          protocol: TCP\n        - containerPort: 80\n          protocol: TCP\n        - containerPort: 81\n          protocol: TCP\n        - containerPort: 82\n          protocol: TCP\n        - containerPort: 83\n          protocol: TCP\n        - containerPort: 84\n          protocol: TCP\n        - containerPort: 85\n          protocol: TCP\n        - containerPort: 86\n          protocol: TCP\n        - containerPort: 87\n          protocol: TCP\n        - containerPort: 88\n          protocol: TCP\n        - containerPort: 89\n          protocol: TCP\n        - containerPort: 90\n          protocol: TCP\n        - containerPort: 91\n          protocol: TCP\n        - containerPort: 92\n          protocol: TCP\n        - containerPort: 93\n          protocol: TCP\n        - containerPort: 94\n          protocol: TCP\n        - containerPort: 95\n          protocol: TCP\n        - containerPort: 96\n          protocol: TCP\n        - containerPort: 97\n          protocol: TCP\n        - containerPort: 98\n          protocol: TCP\n        - containerPort: 99\n          protocol: TCP\n        - containerPort: 100\n          protocol: TCP'
        expect(port_match in resp.deployment_manifest, 'manifest ports')
 
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppDockerIpAccessDedicatedOrSharedTCPUDPPorts(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicatedOrShared/ImageTypeDocker and multiple tcp/udp ports
        # ... create app with ip_access=IpAccessDedicatedOrShared, type=Docker, and multiple tcp/udp ports
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicatedOrShared and tcp and udp ports
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessDedicatedOrShared',
                                             access_ports = 'tcp:1,udp:1,tcp:2,udp:2,udp:3,tcp:3',
                                             default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)

        port_match = 'ports:\n        - containerPort: 1\n          protocol: TCP\n        - containerPort: 1\n          protocol: UDP\n        - containerPort: 2\n          protocol: TCP\n        - containerPort: 2\n          protocol: UDP\n        - containerPort: 3\n          protocol: UDP\n        - containerPort: 3\n          protocol: TCP'
        expect(port_match in resp.deployment_manifest, 'manifest ports')
        
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppDockerIpAccessDedicatedOrSharedHTTP2Ports(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicatedOrShared/ImageTypeDocker and 2 http ports
        # ... create app with ip_access=IpAccessDedicatedOrShared, type=Docker, and 2 http ports
        # ... verify app is created

        # EDGECLOUD-371 - CreateApp with accessports of http shows protocol as TCP on ShowApp

        # print the existing apps 
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicatedOrShared and 2 http ports
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessDedicatedOrShared',
                                             access_ports = 'http:655,http:2',
                                             default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)

        #update after bug fix
        port_match = 'ports:\n        - containerPort: 655\n          protocol: TCP\n        - containerPort: 2\n          protocol: TCP'
        expect(port_match in resp.deployment_manifest, 'manifest ports')
        
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppDockerIpAccessDedicatedOrSharedHTTP10Ports(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicatedOrShared/ImageTypeDocker and 10 http ports
        # ... create app with ip_access=IpAccessDedicatedOrShared, type=Docker, and 10 http ports
        # ... verify app is created

        # EDGECLOUD-371 - CreateApp with accessports of http shows protocol as TCP on ShowApp

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicatedOrShared and 10 http ports
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessDedicatedOrShared',
                                             access_ports = 'http:1,http:2,http:3,http:4,http:5,http:6,http:7,http:8,http:9,http:10',
                                             default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)

        #update after bug fix
        port_match = 'ports:\n        - containerPort: 1\n          protocol: TCP\n        - containerPort: 2\n          protocol: TCP\n        - containerPort: 3\n          protocol: TCP\n        - containerPort: 4\n          protocol: TCP\n        - containerPort: 5\n          protocol: TCP\n        - containerPort: 6\n          protocol: TCP\n        - containerPort: 7\n          protocol: TCP\n        - containerPort: 8\n          protocol: TCP\n        - containerPort: 9\n          protocol: TCP\n        - containerPort: 10\n          protocol: TCP'
        expect(port_match in resp.deployment_manifest, 'manifest ports')
        
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppDockerIpAccessDedicatedOrSharedHTTP100Ports(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicatedOrShared/ImageTypeDocker and 100 http ports
        # ... create app with ip_access=IpAccessDedicatedOrShared, type=Docker, and 100 http ports
        # ... verify app is created

        # EDGECLOUD-371 - CreateApp with accessports of http shows protocol as TCP on ShowApp

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicatedOrShared and 100 http ports
        tcp_list = ''
        for i in range(100):
            tcp_list += 'http:' + str(i+1) + ','
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessDedicatedOrShared',
                                             access_ports = tcp_list[:-1],
                                             default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)

        #update after bug fix
        port_match = 'ports:\n        - containerPort: 1\n          protocol: TCP\n        - containerPort: 2\n          protocol: TCP\n        - containerPort: 3\n          protocol: TCP\n        - containerPort: 4\n          protocol: TCP\n        - containerPort: 5\n          protocol: TCP\n        - containerPort: 6\n          protocol: TCP\n        - containerPort: 7\n          protocol: TCP\n        - containerPort: 8\n          protocol: TCP\n        - containerPort: 9\n          protocol: TCP\n        - containerPort: 10\n          protocol: TCP\n        - containerPort: 11\n          protocol: TCP\n        - containerPort: 12\n          protocol: TCP\n        - containerPort: 13\n          protocol: TCP\n        - containerPort: 14\n          protocol: TCP\n        - containerPort: 15\n          protocol: TCP\n        - containerPort: 16\n          protocol: TCP\n        - containerPort: 17\n          protocol: TCP\n        - containerPort: 18\n          protocol: TCP\n        - containerPort: 19\n          protocol: TCP\n        - containerPort: 20\n          protocol: TCP\n        - containerPort: 21\n          protocol: TCP\n        - containerPort: 22\n          protocol: TCP\n        - containerPort: 23\n          protocol: TCP\n        - containerPort: 24\n          protocol: TCP\n        - containerPort: 25\n          protocol: TCP\n        - containerPort: 26\n          protocol: TCP\n        - containerPort: 27\n          protocol: TCP\n        - containerPort: 28\n          protocol: TCP\n        - containerPort: 29\n          protocol: TCP\n        - containerPort: 30\n          protocol: TCP\n        - containerPort: 31\n          protocol: TCP\n        - containerPort: 32\n          protocol: TCP\n        - containerPort: 33\n          protocol: TCP\n        - containerPort: 34\n          protocol: TCP\n        - containerPort: 35\n          protocol: TCP\n        - containerPort: 36\n          protocol: TCP\n        - containerPort: 37\n          protocol: TCP\n        - containerPort: 38\n          protocol: TCP\n        - containerPort: 39\n          protocol: TCP\n        - containerPort: 40\n          protocol: TCP\n        - containerPort: 41\n          protocol: TCP\n        - containerPort: 42\n          protocol: TCP\n        - containerPort: 43\n          protocol: TCP\n        - containerPort: 44\n          protocol: TCP\n        - containerPort: 45\n          protocol: TCP\n        - containerPort: 46\n          protocol: TCP\n        - containerPort: 47\n          protocol: TCP\n        - containerPort: 48\n          protocol: TCP\n        - containerPort: 49\n          protocol: TCP\n        - containerPort: 50\n          protocol: TCP\n        - containerPort: 51\n          protocol: TCP\n        - containerPort: 52\n          protocol: TCP\n        - containerPort: 53\n          protocol: TCP\n        - containerPort: 54\n          protocol: TCP\n        - containerPort: 55\n          protocol: TCP\n        - containerPort: 56\n          protocol: TCP\n        - containerPort: 57\n          protocol: TCP\n        - containerPort: 58\n          protocol: TCP\n        - containerPort: 59\n          protocol: TCP\n        - containerPort: 60\n          protocol: TCP\n        - containerPort: 61\n          protocol: TCP\n        - containerPort: 62\n          protocol: TCP\n        - containerPort: 63\n          protocol: TCP\n        - containerPort: 64\n          protocol: TCP\n        - containerPort: 65\n          protocol: TCP\n        - containerPort: 66\n          protocol: TCP\n        - containerPort: 67\n          protocol: TCP\n        - containerPort: 68\n          protocol: TCP\n        - containerPort: 69\n          protocol: TCP\n        - containerPort: 70\n          protocol: TCP\n        - containerPort: 71\n          protocol: TCP\n        - containerPort: 72\n          protocol: TCP\n        - containerPort: 73\n          protocol: TCP\n        - containerPort: 74\n          protocol: TCP\n        - containerPort: 75\n          protocol: TCP\n        - containerPort: 76\n          protocol: TCP\n        - containerPort: 77\n          protocol: TCP\n        - containerPort: 78\n          protocol: TCP\n        - containerPort: 79\n          protocol: TCP\n        - containerPort: 80\n          protocol: TCP\n        - containerPort: 81\n          protocol: TCP\n        - containerPort: 82\n          protocol: TCP\n        - containerPort: 83\n          protocol: TCP\n        - containerPort: 84\n          protocol: TCP\n        - containerPort: 85\n          protocol: TCP\n        - containerPort: 86\n          protocol: TCP\n        - containerPort: 87\n          protocol: TCP\n        - containerPort: 88\n          protocol: TCP\n        - containerPort: 89\n          protocol: TCP\n        - containerPort: 90\n          protocol: TCP\n        - containerPort: 91\n          protocol: TCP\n        - containerPort: 92\n          protocol: TCP\n        - containerPort: 93\n          protocol: TCP\n        - containerPort: 94\n          protocol: TCP\n        - containerPort: 95\n          protocol: TCP\n        - containerPort: 96\n          protocol: TCP\n        - containerPort: 97\n          protocol: TCP\n        - containerPort: 98\n          protocol: TCP\n        - containerPort: 99\n          protocol: TCP\n        - containerPort: 100\n          protocol: TCP'
        expect(port_match in resp.deployment_manifest, 'manifest ports')
        
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppDockerIpAccessDedicatedOrSharedTCPUDPHTTPPorts(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicatedOrShared/ImageTypeDocker and multiple tcp/udp/http ports
        # ... create app with ip_access=IpAccessDedicatedOrShared, type=Docker, and multiple tcp/udp/http ports
        # ... verify app is created

        # EDGECLOUD-371 - CreateApp with accessports of http shows protocol as TCP on ShowApp

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicatedOrShared and tcp and udp and http ports
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessDedicatedOrShared',
                                             access_ports = 'tcp:1,udp:1,http:8080,tcp:2,udp:2,http:80,udp:3,tcp:3',
                                             default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)

        #update after bug fix
        port_match = 'ports:\n        - containerPort: 1\n          protocol: TCP\n        - containerPort: 1\n          protocol: UDP\n        - containerPort: 8080\n          protocol: TCP\n        - containerPort: 2\n          protocol: TCP\n        - containerPort: 2\n          protocol: UDP\n        - containerPort: 80\n          protocol: TCP\n        - containerPort: 3\n          protocol: UDP\n        - containerPort: 3\n          protocol: TCP'
        expect(port_match in resp.deployment_manifest, 'manifest ports')
        
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppDockerIpAccessDedicatedOrSharedUDP2Ports(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicatedOrShared/ImageTypeDocker and 2 udp ports
        # ... create app with ip_access=IpAccessDedicatedOrShared, type=Docker, and 2 udp ports
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicatedOrShared and 2 udp ports:
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessDedicatedOrShared',
                                             access_ports = 'udp:5535,udp:55',
                                             default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)

        port_match = 'ports:\n        - containerPort: 5535\n          protocol: UDP\n        - containerPort: 55\n          protocol: UDP'
        expect(port_match in resp.deployment_manifest, 'manifest ports')
        
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppDockerIpAccessDedicatedOrSharedUDP10Ports(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicatedOrShared/ImageTypeDocker and 10 udp ports
        # ... create app with ip_access=IpAccessDedicatedOrShared, type=Docker, and 2 udp ports
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicatedOrShared and 10 udp ports
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessDedicatedOrShared',
                                             access_ports = 'udp:10,udp:9,udp:8,udp:7,udp:6,udp:5,udp:4,udp:3,udp:2,udp:1',
                                             default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)
       
        port_match = 'ports:\n        - containerPort: 10\n          protocol: UDP\n        - containerPort: 9\n          protocol: UDP\n        - containerPort: 8\n          protocol: UDP\n        - containerPort: 7\n          protocol: UDP\n        - containerPort: 6\n          protocol: UDP\n        - containerPort: 5\n          protocol: UDP\n        - containerPort: 4\n          protocol: UDP\n        - containerPort: 3\n          protocol: UDP\n        - containerPort: 2\n          protocol: UDP\n        - containerPort: 1\n          protocol: UDP'
        expect(port_match in resp.deployment_manifest, 'manifest ports')
 
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppDockerIpAccessDedicatedOrSharedUDP100Ports(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicatedOrShared/ImageTypeDocker and 100 udp ports
        # ... create app with ip_access=IpAccessDedicatedOrShared, type=Docker, and 100 udp ports
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicatedOrShared and 100 upd ports
        udp_list = ''
        for i in range(100):
            udp_list += 'udp:' + str(i+1) + ','
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessDedicatedOrShared',
                                             access_ports = udp_list[:-1],
                                             default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)
       
        port_match = 'ports:\n        - containerPort: 1\n          protocol: UDP\n        - containerPort: 2\n          protocol: UDP\n        - containerPort: 3\n          protocol: UDP\n        - containerPort: 4\n          protocol: UDP\n        - containerPort: 5\n          protocol: UDP\n        - containerPort: 6\n          protocol: UDP\n        - containerPort: 7\n          protocol: UDP\n        - containerPort: 8\n          protocol: UDP\n        - containerPort: 9\n          protocol: UDP\n        - containerPort: 10\n          protocol: UDP\n        - containerPort: 11\n          protocol: UDP\n        - containerPort: 12\n          protocol: UDP\n        - containerPort: 13\n          protocol: UDP\n        - containerPort: 14\n          protocol: UDP\n        - containerPort: 15\n          protocol: UDP\n        - containerPort: 16\n          protocol: UDP\n        - containerPort: 17\n          protocol: UDP\n        - containerPort: 18\n          protocol: UDP\n        - containerPort: 19\n          protocol: UDP\n        - containerPort: 20\n          protocol: UDP\n        - containerPort: 21\n          protocol: UDP\n        - containerPort: 22\n          protocol: UDP\n        - containerPort: 23\n          protocol: UDP\n        - containerPort: 24\n          protocol: UDP\n        - containerPort: 25\n          protocol: UDP\n        - containerPort: 26\n          protocol: UDP\n        - containerPort: 27\n          protocol: UDP\n        - containerPort: 28\n          protocol: UDP\n        - containerPort: 29\n          protocol: UDP\n        - containerPort: 30\n          protocol: UDP\n        - containerPort: 31\n          protocol: UDP\n        - containerPort: 32\n          protocol: UDP\n        - containerPort: 33\n          protocol: UDP\n        - containerPort: 34\n          protocol: UDP\n        - containerPort: 35\n          protocol: UDP\n        - containerPort: 36\n          protocol: UDP\n        - containerPort: 37\n          protocol: UDP\n        - containerPort: 38\n          protocol: UDP\n        - containerPort: 39\n          protocol: UDP\n        - containerPort: 40\n          protocol: UDP\n        - containerPort: 41\n          protocol: UDP\n        - containerPort: 42\n          protocol: UDP\n        - containerPort: 43\n          protocol: UDP\n        - containerPort: 44\n          protocol: UDP\n        - containerPort: 45\n          protocol: UDP\n        - containerPort: 46\n          protocol: UDP\n        - containerPort: 47\n          protocol: UDP\n        - containerPort: 48\n          protocol: UDP\n        - containerPort: 49\n          protocol: UDP\n        - containerPort: 50\n          protocol: UDP\n        - containerPort: 51\n          protocol: UDP\n        - containerPort: 52\n          protocol: UDP\n        - containerPort: 53\n          protocol: UDP\n        - containerPort: 54\n          protocol: UDP\n        - containerPort: 55\n          protocol: UDP\n        - containerPort: 56\n          protocol: UDP\n        - containerPort: 57\n          protocol: UDP\n        - containerPort: 58\n          protocol: UDP\n        - containerPort: 59\n          protocol: UDP\n        - containerPort: 60\n          protocol: UDP\n        - containerPort: 61\n          protocol: UDP\n        - containerPort: 62\n          protocol: UDP\n        - containerPort: 63\n          protocol: UDP\n        - containerPort: 64\n          protocol: UDP\n        - containerPort: 65\n          protocol: UDP\n        - containerPort: 66\n          protocol: UDP\n        - containerPort: 67\n          protocol: UDP\n        - containerPort: 68\n          protocol: UDP\n        - containerPort: 69\n          protocol: UDP\n        - containerPort: 70\n          protocol: UDP\n        - containerPort: 71\n          protocol: UDP\n        - containerPort: 72\n          protocol: UDP\n        - containerPort: 73\n          protocol: UDP\n        - containerPort: 74\n          protocol: UDP\n        - containerPort: 75\n          protocol: UDP\n        - containerPort: 76\n          protocol: UDP\n        - containerPort: 77\n          protocol: UDP\n        - containerPort: 78\n          protocol: UDP\n        - containerPort: 79\n          protocol: UDP\n        - containerPort: 80\n          protocol: UDP\n        - containerPort: 81\n          protocol: UDP\n        - containerPort: 82\n          protocol: UDP\n        - containerPort: 83\n          protocol: UDP\n        - containerPort: 84\n          protocol: UDP\n        - containerPort: 85\n          protocol: UDP\n        - containerPort: 86\n          protocol: UDP\n        - containerPort: 87\n          protocol: UDP\n        - containerPort: 88\n          protocol: UDP\n        - containerPort: 89\n          protocol: UDP\n        - containerPort: 90\n          protocol: UDP\n        - containerPort: 91\n          protocol: UDP\n        - containerPort: 92\n          protocol: UDP\n        - containerPort: 93\n          protocol: UDP\n        - containerPort: 94\n          protocol: UDP\n        - containerPort: 95\n          protocol: UDP\n        - containerPort: 96\n          protocol: UDP\n        - containerPort: 97\n          protocol: UDP\n        - containerPort: 98\n          protocol: UDP\n        - containerPort: 99\n          protocol: UDP\n        - containerPort: 100\n          protocol: UDP' 
        expect(port_match in resp.deployment_manifest, 'manifest ports')

        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppQCOWIpAccessDedicatedOrSharedTCP2Ports(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicatedOrShared/ImageTypeQCOW and 2 tcp ports
        # ... create app with ip_access=IpAccessDedicatedOrShared, type=QCOW, and 2 tcp ports
        # ... verify app is created

        # print the existing apps 
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicatedOrShared and 2 tcp ports
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                      image_path = qcow_image,
                                      app_name=app_name,
                                      app_version=app_version,
                                      #cluster_name=cluster_name,
                                      developer_org_name=developer_name,
                                      ip_access = 'IpAccessDedicatedOrShared',
                                      access_ports = 'tcp:655,tcp:2',
                                      default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)
        
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppQCOWIpAccessDedicatedOrSharedTCP10Ports(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicatedOrShared/ImageTypeQCOW and 10 tcp ports
        # ... create app with ip_access=IpAccessDedicatedOrShared, type=QCOW, and 10 tcp ports
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicatedOrShared and 10 tcp ports
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                      image_path = qcow_image,
                                      app_name=app_name,
                                      app_version=app_version,
                                      #cluster_name=cluster_name,
                                      developer_org_name=developer_name,
                                      ip_access = 'IpAccessDedicatedOrShared',
                                      access_ports = 'tcp:1,tcp:2,tcp:3,tcp:4,tcp:5,tcp:6,tcp:7,tcp:8,tcp:9,tcp:10',
                                      default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)
        
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppQCOWIpAccessDedicatedOrSharedTCP100Ports(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicatedOrShared/ImageTypeQCOW and 100 tcp ports
        # ... create app with ip_access=IpAccessDedicatedOrShared, type=QCOW, and 100 tcp ports
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicatedOrShared and 100 tcp ports
        tcp_list = ''
        for i in range(100):
            tcp_list += 'tcp:' + str(i+1) + ','
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                      image_path = qcow_image,
                                      app_name=app_name,
                                      app_version=app_version,
                                      #cluster_name=cluster_name,
                                      developer_org_name=developer_name,
                                      ip_access = 'IpAccessDedicatedOrShared',
                                      access_ports = tcp_list[:-1],
                                      default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)
        
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppQCOWIpAccessDedicatedOrSharedTCPUDPPorts(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicatedOrShared/ImageTypeQCOW and multiple tcp/udp ports
        # ... create app with ip_access=IpAccessDedicatedOrShared, type=QCOW, and multiple tcp/udp ports
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicatedOrShared and tcp and udp ports
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                      image_path = qcow_image,
                                      app_name=app_name,
                                      app_version=app_version,
                                      #cluster_name=cluster_name,
                                      developer_org_name=developer_name,
                                      ip_access = 'IpAccessDedicatedOrShared',
                                      access_ports = 'tcp:1,udp:1,tcp:2,udp:2,udp:3,tcp:3',
                                      default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)
        
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppQCOWIpAccessDedicatedOrSharedUDP2Ports(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicatedOrShared/ImageTypeQCOW and 2 udp ports
        # ... create app with ip_access=IpAccessDedicatedOrShared, type=QCOW, and 2 udp ports
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicatedOrShared and 2 udp ports:
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                      image_path = qcow_image,
                                      app_name=app_name,
                                      app_version=app_version,
                                      #cluster_name=cluster_name,
                                      developer_org_name=developer_name,
                                      ip_access = 'IpAccessDedicatedOrShared',
                                      access_ports = 'udp:5535,udp:55',
                                      default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)
        
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppQCOWIpAccessDedicatedOrSharedUDP10Ports(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicatedOrShared/ImageTypeQCOW and 10 udp ports
        # ... create app with ip_access=IpAccessDedicatedOrShared, type=QCOW, and 10 udp ports
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicatedOrShared and 10 udp ports
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                      image_path = qcow_image,
                                      app_name=app_name,
                                      app_version=app_version,
                                      #cluster_name=cluster_name,
                                      developer_org_name=developer_name,
                                      ip_access = 'IpAccessDedicatedOrShared',
                                      access_ports = 'udp:10,udp:9,udp:8,udp:7,udp:6,udp:5,udp:4,udp:3,udp:2,udp:1',
                                      default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)
        
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppQCOWIpAccessDedicatedOrSharedUDP100Ports(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicatedOrShared/ImageTypeQCOW and 100 udp ports
        # ... create app with ip_access=IpAccessDedicatedOrShared, type=QCOW, and 100 udp ports
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicatedOrShared and 100 upd ports
        udp_list = ''
        for i in range(100):
            udp_list += 'udp:' + str(i+1) + ','
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                      image_path = qcow_image,
                                      app_name=app_name,
                                      app_version=app_version,
                                      #cluster_name=cluster_name,
                                      developer_org_name=developer_name,
                                      ip_access = 'IpAccessDedicatedOrShared',
                                      access_ports = udp_list[:-1],
                                      default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)
        
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def unsupported_test_CreateAppQCOWIpAccessDedicatedOrSharedHTTP2Ports(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicatedOrShared/ImageTypeQCOW and 2 http ports
        # ... create app with ip_access=IpAccessDedicatedOrShared, type=QCOW, and 2 http ports
        # ... verify app is created

        # print the existing apps 
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicatedOrShared and 2 http ports
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                      image_path = qcow_image,
                                      app_name=app_name,
                                      app_version=app_version,
                                      #cluster_name=cluster_name,
                                      developer_org_name=developer_name,
                                      ip_access = 'IpAccessDedicatedOrShared',
                                      access_ports = 'http:655,http:2',
                                      default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)
        
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def unsupported_test_CreateAppQCOWIpAccessDedicatedOrSharedHTTP10Ports(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicatedOrShared/ImageTypeQCOW and 10 http ports
        # ... create app with ip_access=IpAccessDedicatedOrShared, type=QCOW, and 10 http ports
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicatedOrShared and 10 http ports
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                      image_path = qcow_image,
                                      app_name=app_name,
                                      app_version=app_version,
                                      #cluster_name=cluster_name,
                                      developer_org_name=developer_name,
                                      ip_access = 'IpAccessDedicatedOrShared',
                                      access_ports = 'http:1,http:2,http:3,http:4,http:5,http:6,http:7,http:8,http:9,http:10',
                                      default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)
        
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def unsupported_test_CreateAppQCOWIpAccessDedicatedOrSharedHTTP100Ports(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicatedOrShared/ImageTypeQCOW and 100 http ports
        # ... create app with ip_access=IpAccessDedicatedOrShared, type=QCOW, and 100 http ports
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicatedOrShared and 100 http ports
        tcp_list = ''
        for i in range(100):
            tcp_list += 'http:' + str(i+1) + ','
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                      image_path = qcow_image,
                                      app_name=app_name,
                                      app_version=app_version,
                                      #cluster_name=cluster_name,
                                      developer_org_name=developer_name,
                                      ip_access = 'IpAccessDedicatedOrShared',
                                      access_ports = tcp_list[:-1],
                                      default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)
        
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def unsupported_test_CreateAppQCOWIpAccessDedicatedOrSharedTCPUDPHTTPPorts(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicatedOrShared/ImageTypeQCOW and multiple tcp/udp/http ports
        # ... create app with ip_access=IpAccessDedicatedOrShared, type=QCOW, and tcp/udp/http ports
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicatedOrShared and tcp and udp ports
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                      image_path = qcow_image,
                                      app_name=app_name,
                                      app_version=app_version,
                                      #cluster_name=cluster_name,
                                      developer_org_name=developer_name,
                                      ip_access = 'IpAccessDedicatedOrShared',
                                      access_ports = 'http:80,tcp:1,udp:1,tcp:2,udp:2,udp:3,tcp:3,http:8080',
                                      default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)
        
        expect_equal(found_app, True, 'find app')

    @classmethod
    def tearDownClass(self):
        #self.controller.delete_cluster(self.cluster.cluster)
#        self.controller.delete_developer(self.developer.developer)
        self.controller.delete_flavor(self.flavor.flavor)

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

