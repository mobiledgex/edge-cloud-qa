#!/usr/local/bin/python3

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

from MexController import mex_controller

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
mex_cert = 'localserver.crt'
mex_key = 'localserver.key'

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

class tc(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        self.controller = mex_controller.Controller(controller_address = controller_address,
                                                    root_cert = mex_root_cert,
                                                    key = mex_key,
                                                    client_cert = mex_cert
                                                   )

        self.flavor = mex_controller.Flavor(flavor_name=flavor_name, ram=1024, vcpus=1, disk=1)
        self.cluster_flavor = mex_controller.ClusterFlavor(cluster_flavor_name=flavor_name, node_flavor_name=flavor_name, master_flavor_name=flavor_name, number_nodes=1, max_nodes=1, number_masters=1)
        self.developer = mex_controller.Developer(developer_name=developer_name,
                                                  developer_address=developer_address,
                                                  developer_email=developer_email)
        self.cluster = mex_controller.Cluster(cluster_name=cluster_name,
                                              default_flavor_name=flavor_name)

        self.controller.create_flavor(self.flavor.flavor)
        self.controller.create_cluster_flavor(self.cluster_flavor.cluster_flavor)
        self.controller.create_developer(self.developer.developer) 
        self.controller.create_cluster(self.cluster.cluster)

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
                                             cluster_name=cluster_name,
                                             developer_name=developer_name,
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
                                             cluster_name=cluster_name,
                                             developer_name=developer_name,
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
                                             cluster_name=cluster_name,
                                             developer_name=developer_name,
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
                                             cluster_name=cluster_name,
                                             developer_name=developer_name,
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

    def test_CreateAppDockerIpAccessDedicatedOrSharedHTTP2Ports(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicatedOrShared/ImageTypeDocker and 2 http ports
        # ... create app with ip_access=IpAccessDedicatedOrShared, type=Docker, and 2 http ports
        # ... verify app is created

        # print the existing apps 
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicatedOrShared and 2 http ports
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                             app_name=app_name,
                                             app_version=app_version,
                                             cluster_name=cluster_name,
                                             developer_name=developer_name,
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

    def test_CreateAppDockerIpAccessDedicatedOrSharedHTTP10Ports(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicatedOrShared/ImageTypeDocker and 10 http ports
        # ... create app with ip_access=IpAccessDedicatedOrShared, type=Docker, and 10 http ports
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicatedOrShared and 10 http ports
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                             app_name=app_name,
                                             app_version=app_version,
                                             cluster_name=cluster_name,
                                             developer_name=developer_name,
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

    def test_CreateAppDockerIpAccessDedicatedOrSharedHTTP100Ports(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicatedOrShared/ImageTypeDocker and 100 http ports
        # ... create app with ip_access=IpAccessDedicatedOrShared, type=Docker, and 100 http ports
        # ... verify app is created

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
                                             cluster_name=cluster_name,
                                             developer_name=developer_name,
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

    def test_CreateAppDockerIpAccessDedicatedOrSharedTCPUDPHTTPPorts(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicatedOrShared/ImageTypeDocker and multiple tcp/udp/http ports
        # ... create app with ip_access=IpAccessDedicatedOrShared, type=Docker, and multiple tcp/udp/http ports
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicatedOrShared and tcp and udp and http ports
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                             app_name=app_name,
                                             app_version=app_version,
                                             cluster_name=cluster_name,
                                             developer_name=developer_name,
                                             ip_access = 'IpAccessDedicatedOrShared',
                                             access_ports = 'tcp:1,udp:1,http:8080,tcp:2,udp:2,http:80,udp:3,tcp:3',
                                             default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)
        
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
                                             cluster_name=cluster_name,
                                             developer_name=developer_name,
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
                                             cluster_name=cluster_name,
                                             developer_name=developer_name,
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
                                             cluster_name=cluster_name,
                                             developer_name=developer_name,
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

    def test_CreateAppQCOWIpAccessDedicatedOrSharedTCP2Ports(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicatedOrShared/ImageTypeQCOW and 2 tcp ports
        # ... create app with ip_access=IpAccessDedicatedOrShared, type=QCOW, and 2 tcp ports
        # ... verify app is created

        # print the existing apps 
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicatedOrShared and 2 tcp ports
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                             app_name=app_name,
                                             app_version=app_version,
                                             cluster_name=cluster_name,
                                             developer_name=developer_name,
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
                                             app_name=app_name,
                                             app_version=app_version,
                                             cluster_name=cluster_name,
                                             developer_name=developer_name,
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
                                             app_name=app_name,
                                             app_version=app_version,
                                             cluster_name=cluster_name,
                                             developer_name=developer_name,
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
                                             app_name=app_name,
                                             app_version=app_version,
                                             cluster_name=cluster_name,
                                             developer_name=developer_name,
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
                                             app_name=app_name,
                                             app_version=app_version,
                                             cluster_name=cluster_name,
                                             developer_name=developer_name,
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
                                             app_name=app_name,
                                             app_version=app_version,
                                             cluster_name=cluster_name,
                                             developer_name=developer_name,
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
                                             app_name=app_name,
                                             app_version=app_version,
                                             cluster_name=cluster_name,
                                             developer_name=developer_name,
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

    def test_CreateAppQCOWIpAccessDedicatedOrSharedHTTP2Ports(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicatedOrShared/ImageTypeQCOW and 2 http ports
        # ... create app with ip_access=IpAccessDedicatedOrShared, type=QCOW, and 2 http ports
        # ... verify app is created

        # print the existing apps 
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicatedOrShared and 2 http ports
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                             app_name=app_name,
                                             app_version=app_version,
                                             cluster_name=cluster_name,
                                             developer_name=developer_name,
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

    def test_CreateAppQCOWIpAccessDedicatedOrSharedHTTP10Ports(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicatedOrShared/ImageTypeQCOW and 10 http ports
        # ... create app with ip_access=IpAccessDedicatedOrShared, type=QCOW, and 10 http ports
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicatedOrShared and 10 http ports
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                             app_name=app_name,
                                             app_version=app_version,
                                             cluster_name=cluster_name,
                                             developer_name=developer_name,
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

    def test_CreateAppQCOWIpAccessDedicatedOrSharedHTTP100Ports(self):
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
                                             app_name=app_name,
                                             app_version=app_version,
                                             cluster_name=cluster_name,
                                             developer_name=developer_name,
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

    def test_CreateAppQCOWIpAccessDedicatedOrSharedTCPUDPHTTPPorts(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicatedOrShared/ImageTypeQCOW and multiple tcp/udp/http ports
        # ... create app with ip_access=IpAccessDedicatedOrShared, type=QCOW, and tcp/udp/http ports
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicatedOrShared and tcp and udp ports
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                             app_name=app_name,
                                             app_version=app_version,
                                             cluster_name=cluster_name,
                                             developer_name=developer_name,
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
        self.controller.delete_cluster(self.cluster.cluster)
        self.controller.delete_developer(self.developer.developer)
        self.controller.delete_cluster_flavor(self.cluster_flavor.cluster_flavor)
        self.controller.delete_flavor(self.flavor.flavor)

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

