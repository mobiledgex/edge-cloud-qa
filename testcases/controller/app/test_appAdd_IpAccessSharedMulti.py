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
# create app with ip_access=IpAccessShared with various ports for Docker and QCOW
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

    def test_CreateAppDockerIpAccessSharedTCP2Ports(self):
        # [Documentation] App - User shall be able to create an app with IpAccessShared/ImageTypeDocker and 2 tcp ports
        # ... create app with ip_access=IpAccessShared with 2 tcp ports and with Docker
        # ... verify app is created

        # print the existing apps 
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessShared and 2 tcp ports
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessShared',
                                             access_ports = 'tcp:655,tcp:2',
                                             default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)

        #ports:\n        - containerPort: 655\n          protocol: TCP\n        - containerPort: 2\n          protocol: TCP
        port_match = 'ports:\n        - containerPort: 655\n          protocol: TCP\n        - containerPort: 2\n          protocol: TCP'
        expect(port_match in resp.deployment_manifest, 'manifest ports')
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppDockerIpAccessSharedTCP10Ports(self):
        # [Documentation] App - User shall be able to create an app with IpAccessShared/ImageTypeDocker and 10 tcp ports
        # ... create app with ip_access=IpAccessShared with 10 tcp ports and with Docker
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessShared and 10 tcp ports
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessShared',
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

    def test_CreateAppDockerIpAccessSharedTCP100Ports(self):
        # [Documentation] App - User shall be able to create an app with IpAccessShared/ImageTypeDocker and 100 tcp ports
        # ... create app with ip_access=IpAccessShared with 100 tcp ports and with Docker
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessShared and 100 tcp ports
        tcp_list = ''
        for i in range(100,200):
            tcp_list += 'tcp:' + str(i+1) + ','
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessShared',
                                             access_ports = tcp_list[:-1],
                                             default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)

        port_match = 'ports:\n        - containerPort: 101\n          protocol: TCP\n        - containerPort: 102\n          protocol: TCP\n        - containerPort: 103\n          protocol: TCP\n        - containerPort: 104\n          protocol: TCP\n        - containerPort: 105\n          protocol: TCP\n        - containerPort: 106\n          protocol: TCP\n        - containerPort: 107\n          protocol: TCP\n        - containerPort: 108\n          protocol: TCP\n        - containerPort: 109\n          protocol: TCP\n        - containerPort: 110\n          protocol: TCP\n        - containerPort: 111\n          protocol: TCP\n        - containerPort: 112\n          protocol: TCP\n        - containerPort: 113\n          protocol: TCP\n        - containerPort: 114\n          protocol: TCP\n        - containerPort: 115\n          protocol: TCP\n        - containerPort: 116\n          protocol: TCP\n        - containerPort: 117\n          protocol: TCP\n        - containerPort: 118\n          protocol: TCP\n        - containerPort: 119\n          protocol: TCP\n        - containerPort: 120\n          protocol: TCP\n        - containerPort: 121\n          protocol: TCP\n        - containerPort: 122\n          protocol: TCP\n        - containerPort: 123\n          protocol: TCP\n        - containerPort: 124\n          protocol: TCP\n        - containerPort: 125\n          protocol: TCP\n        - containerPort: 126\n          protocol: TCP\n        - containerPort: 127\n          protocol: TCP\n        - containerPort: 128\n          protocol: TCP\n        - containerPort: 129\n          protocol: TCP\n        - containerPort: 130\n          protocol: TCP\n        - containerPort: 131\n          protocol: TCP\n        - containerPort: 132\n          protocol: TCP\n        - containerPort: 133\n          protocol: TCP\n        - containerPort: 134\n          protocol: TCP\n        - containerPort: 135\n          protocol: TCP\n        - containerPort: 136\n          protocol: TCP\n        - containerPort: 137\n          protocol: TCP\n        - containerPort: 138\n          protocol: TCP\n        - containerPort: 139\n          protocol: TCP\n        - containerPort: 140\n          protocol: TCP\n        - containerPort: 141\n          protocol: TCP\n        - containerPort: 142\n          protocol: TCP\n        - containerPort: 143\n          protocol: TCP\n        - containerPort: 144\n          protocol: TCP\n        - containerPort: 145\n          protocol: TCP\n        - containerPort: 146\n          protocol: TCP\n        - containerPort: 147\n          protocol: TCP\n        - containerPort: 148\n          protocol: TCP\n        - containerPort: 149\n          protocol: TCP\n        - containerPort: 150\n          protocol: TCP\n        - containerPort: 151\n          protocol: TCP\n        - containerPort: 152\n          protocol: TCP\n        - containerPort: 153\n          protocol: TCP\n        - containerPort: 154\n          protocol: TCP\n        - containerPort: 155\n          protocol: TCP\n        - containerPort: 156\n          protocol: TCP\n        - containerPort: 157\n          protocol: TCP\n        - containerPort: 158\n          protocol: TCP\n        - containerPort: 159\n          protocol: TCP\n        - containerPort: 160\n          protocol: TCP\n        - containerPort: 161\n          protocol: TCP\n        - containerPort: 162\n          protocol: TCP\n        - containerPort: 163\n          protocol: TCP\n        - containerPort: 164\n          protocol: TCP\n        - containerPort: 165\n          protocol: TCP\n        - containerPort: 166\n          protocol: TCP\n        - containerPort: 167\n          protocol: TCP\n        - containerPort: 168\n          protocol: TCP\n        - containerPort: 169\n          protocol: TCP\n        - containerPort: 170\n          protocol: TCP\n        - containerPort: 171\n          protocol: TCP\n        - containerPort: 172\n          protocol: TCP\n        - containerPort: 173\n          protocol: TCP\n        - containerPort: 174\n          protocol: TCP\n        - containerPort: 175\n          protocol: TCP\n        - containerPort: 176\n          protocol: TCP\n        - containerPort: 177\n          protocol: TCP\n        - containerPort: 178\n          protocol: TCP\n        - containerPort: 179\n          protocol: TCP\n        - containerPort: 180\n          protocol: TCP\n        - containerPort: 181\n          protocol: TCP\n        - containerPort: 182\n          protocol: TCP\n        - containerPort: 183\n          protocol: TCP\n        - containerPort: 184\n          protocol: TCP\n        - containerPort: 185\n          protocol: TCP\n        - containerPort: 186\n          protocol: TCP\n        - containerPort: 187\n          protocol: TCP\n        - containerPort: 188\n          protocol: TCP\n        - containerPort: 189\n          protocol: TCP\n        - containerPort: 190\n          protocol: TCP\n        - containerPort: 191\n          protocol: TCP\n        - containerPort: 192\n          protocol: TCP\n        - containerPort: 193\n          protocol: TCP\n        - containerPort: 194\n          protocol: TCP\n        - containerPort: 195\n          protocol: TCP\n        - containerPort: 196\n          protocol: TCP\n        - containerPort: 197\n          protocol: TCP\n        - containerPort: 198\n          protocol: TCP\n        - containerPort: 199\n          protocol: TCP\n        - containerPort: 200\n          protocol: TCP'
        expect(port_match in resp.deployment_manifest, 'manifest ports')
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppDockerIpAccessSharedTCPUDPPorts(self):
        # [Documentation] App - User shall be able to create an app with IpAccessShared/ImageTypeDocker and multiple tcp/udp ports
        # ... create app with ip_access=IpAccessShared with multiple tcp/udp ports and with Docker
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessShared and tcp and udp ports
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessShared',
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

    def test_CreateAppDockerIpAccessSharedHTTP2Ports(self):
        # [Documentation] App - User shall be able to create an app with IpAccessShared/ImageTypeDocker and 2 http ports
        # ... create app with ip_access=IpAccessShared with 2 http ports and with Docker
        # ... verify app is created

        # EDGECLOUD-371 - CreateApp with accessports of http shows protocol as TCP on ShowApp
        
        # print the existing apps 
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessShared and 2 http ports
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessShared',
                                             access_ports = 'http:655,http:2',
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

    def test_CreateAppDockerIpAccessSharedHTTP10Ports(self):
        # [Documentation] App - User shall be able to create an app with IpAccessShared/ImageTypeDocker and 10 http ports
        # ... create app with ip_access=IpAccessShared with 10 http ports and with Docker
        # ... verify app is created

        # EDGECLOUD-371 - CreateApp with accessports of http shows protocol as TCP on ShowApp
        
        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessShared and 10 http ports
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessShared',
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

    def test_CreateAppDockerIpAccessSharedHTTP100Ports(self):
        # [Documentation] App - User shall be able to create an app with IpAccessShared/ImageTypeDocker and 100 http ports
        # ... create app with ip_access=IpAccessShared with 100 http ports and with Docker
        # ... verify app is created

        # EDGECLOUD-371 - CreateApp with accessports of http shows protocol as TCP on ShowApp

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessShared and 100 http ports
        tcp_list = ''
        for i in range(100):
            tcp_list += 'http:' + str(i+1) + ','
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessShared',
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

    def test_CreateAppDockerIpAccessSharedTCPUDPHTTPPorts(self):
        # [Documentation] App - User shall be able to create an app with IpAccessShared/ImageTypeDocker and multiple tcp/udp/http ports
        # ... create app with ip_access=IpAccessShared with multiple tcp/udp/http ports and with Docker
        # ... verify app is created

        # EDGECLOUD-371 - CreateApp with accessports of http shows protocol as TCP on ShowApp

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessShared and tcp and udp and http ports
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessShared',
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

    def test_CreateAppDockerIpAccessSharedUDP2Ports(self):
        # [Documentation] App - User shall be able to create an app with IpAccessShared/ImageTypeDocker and 2 udp ports
        # ... create app with ip_access=IpAccessShared with 2 udp ports and with Docker
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessShared and 2 udp ports:
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessShared',
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

    def test_CreateAppDockerIpAccessSharedUDP10Ports(self):
        # [Documentation] App - User shall be able to create an app with IpAccessShared/ImageTypeDocker and 10 udp ports
        # ... create app with ip_access=IpAccessShared with 10 udp ports and with Docker
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessShared and 10 udp ports
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessShared',
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

    def test_CreateAppDockerIpAccessSharedUDP100Ports(self):
        # [Documentation] App - User shall be able to create an app with IpAccessShared/ImageTypeDocker and 100 udp ports
        # ... create app with ip_access=IpAccessShared with 100 udp ports and with Docker
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessShared and 100 upd ports
        udp_list = ''
        for i in range(54,154):
            udp_list += 'udp:' + str(i+1) + ','
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessShared',
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

    def test_CreateAppQCOWIpAccessSharedTCP2Ports(self):
        # [Documentation] App - User shall be able to create an app with IpAccessShared/ImageTypeQCOW and 2 tcp ports
        # ... create app with ip_access=IpAccessShared with 2 tcp ports and with QCOW 
        # ... verify app is created

        # print the existing apps 
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessShared and 2 tcp ports
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessShared',
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

    def test_CreateAppQCOWIpAccessSharedTCP10Ports(self):
        # [Documentation] App - User shall be able to create an app with IpAccessShared/ImageTypeQCOW and 10 tcp ports
        # ... create app with ip_access=IpAccessShared with 10 tcp ports and with QCOW
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessShared and 10 tcp ports
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessShared',
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

    def test_CreateAppQCOWIpAccessSharedTCP100Ports(self):
        # [Documentation] App - User shall be able to create an app with IpAccessShared/ImageTypeQCOW and 100 tcp ports
        # ... create app with ip_access=IpAccessShared with 100 tcp ports and with QCOW
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessShared and 100 tcp ports
        tcp_list = ''
        for i in range(100,200):
            tcp_list += 'tcp:' + str(i+1) + ','
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessShared',
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

    def test_CreateAppQCOWIpAccessSharedTCPUDPPorts(self):
        # [Documentation] App - User shall be able to create an app with IpAccessShared/ImageTypeQCOW and multiple tcp/udp ports
        # ... create app with ip_access=IpAccessShared with multiple tcp/udp ports and with QCOW
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessShared and tcp and udp ports
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessShared',
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

    def test_CreateAppQCOWIpAccessSharedUDP2Ports(self):
        # [Documentation] App - User shall be able to create an app with IpAccessShared/ImageTypeQCOW and 2 udp ports
        # ... create app with ip_access=IpAccessShared with 2 udp ports and with QCOW
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessShared and 2 udp ports:
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessShared',
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

    def test_CreateAppQCOWIpAccessSharedUDP10Ports(self):
        # [Documentation] App - User shall be able to create an app with IpAccessShared/ImageTypeQCOW and 10 udp ports
        # ... create app with ip_access=IpAccessShared with 10 udp ports and with QCOW
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessShared and 10 udp ports
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessShared',
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

    def test_CreateAppQCOWIpAccessSharedUDP100Ports(self):
        # [Documentation] App - User shall be able to create an app with IpAccessShared/ImageTypeQCOW and 100 udp ports
        # ... create app with ip_access=IpAccessShared with 100 udp ports and with QCOW
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessShared and 100 upd ports
        udp_list = ''
        for i in range(54,154):
            udp_list += 'udp:' + str(i+1) + ','
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessShared',
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

    def test_CreateAppQCOWIpAccessSharedHTTP2Ports(self):
        # [Documentation] App - User shall be able to create an app with IpAccessShared/ImageTypeQCOW and 2 http ports
        # ... create app with ip_access=IpAccessShared with 2 http ports and with QCOW
        # ... verify app is created

        # print the existing apps 
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessShared and 2 http ports
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessShared',
                                             access_ports = 'http:655,http:2',
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

    def test_CreateAppQCOWIpAccessSharedHTTP10Ports(self):
        # [Documentation] App - User shall be able to create an app with IpAccessShared/ImageTypeQCOW and 10 http ports
        # ... create app with ip_access=IpAccessShared with 10 http ports and with QCOW
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessShared and 10 http ports
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessShared',
                                             access_ports = 'http:1,http:2,http:3,http:4,http:5,http:6,http:7,http:8,http:9,http:10',
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

    def test_CreateAppQCOWIpAccessSharedHTTP100Ports(self):
        # [Documentation] App - User shall be able to create an app with IpAccessShared/ImageTypeQCOW and 100 http ports
        # ... create app with ip_access=IpAccessShared with 100 http ports and with QCOW
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessShared and 100 http ports
        tcp_list = ''
        for i in range(100):
            tcp_list += 'http:' + str(i+1) + ','
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessShared',
                                             access_ports = tcp_list[:-1],
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

    def test_CreateAppQCOWIpAccessSharedTCPUDPHTTPPorts(self):
        # [Documentation] App - User shall be able to create an app with IpAccessShared/ImageTypeQCOW and multiple tcp/udp/http ports
        # ... create app with ip_access=IpAccessShared with multiple tcp/udp/http ports and with QCOW
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessShared and tcp and udp ports
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessShared',
                                             access_ports = 'http:80,tcp:1,udp:1,tcp:2,udp:2,udp:3,tcp:3,http:8080',
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

    @classmethod
    def tearDownClass(self):
        #self.controller.delete_cluster(self.cluster.cluster)
#        self.controller.delete_developer(self.developer.developer)
        self.controller.delete_flavor(self.flavor.flavor)

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

