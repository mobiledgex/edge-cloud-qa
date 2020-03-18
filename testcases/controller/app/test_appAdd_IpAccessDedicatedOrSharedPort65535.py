#!/usr/local/bin/python3

#
# create app with ip_access=IpAccessDedicatedOrShared with port 65535 and with Docker and QCOW
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
                                                    root_cert = mex_root_cert,
                                                    key = mex_key,
                                                    client_cert = mex_cert
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

    def test_CreateAppDockerIpAccessDedicatedOrSharedTCP65535(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicatedOrShared/ImageTypeDocker/tcp:65535
        # ... create app with ip_access=IpAccessDedicatedOrShared with tcp:65535 and with Docker
        # ... verify app is created

        # print the existing apps 
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicatedOrShared and port=tcp:65535
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessDedicatedOrShared',
                                             access_ports = 'tcp:65535',
                                             default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)

        port_match = 'ports:\n        - containerPort: 65535\n          protocol: TCP'
        expect(port_match in resp.deployment_manifest, 'manifest ports')
        
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppDockerIpAccessDedicatedOrSharedTCP065535(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicatedOrShared/ImageTypeDocker/tcp:065535
        # ... create app with ip_access=IpAccessDedicatedOrShared with tcp:065535 and with Docker
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicatedOrShared and port=tcp:01
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessDedicatedOrShared',
                                             access_ports = 'tcp:065535',
                                             default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)
       
        port_match = 'ports:\n        - containerPort: 65535\n          protocol: TCP'
        expect(port_match in resp.deployment_manifest, 'manifest ports')
 
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppDockerIpAccessDedicatedOrSharedUDP65535(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicatedOrShared/ImageTypeDocker/udp:65535
        # ... create app with ip_access=IpAccessDedicatedOrShared with udp:65535 and with Docker
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicatedOrShared and port=udp65535:
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessDedicatedOrShared',
                                             access_ports = 'udp:65535',
                                             default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)
       
        port_match = 'ports:\n        - containerPort: 65535\n          protocol: UDP'
        expect(port_match in resp.deployment_manifest, 'manifest ports')
 
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppDockerIpAccessDedicatedOrSharedUDP065535(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicatedOrShared/ImageTypeDocker/udp:065535
        # ... create app with ip_access=IpAccessDedicatedOrShared with udp:065535 and with Docker
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicatedOrShared and port=udp:065535
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessDedicatedOrShared',
                                             access_ports = 'udp:065535',
                                             default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)
       
        port_match = 'ports:\n        - containerPort: 65535\n          protocol: UDP'
        expect(port_match in resp.deployment_manifest, 'manifest ports')
 
        expect_equal(found_app, True, 'find app')
        assert_expectations()


    def test_CreateAppDockerIpAccessDedicatedOrSharedHTTP65535(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicatedOrShared/ImageTypeDocker/http:65535
        # ... create app with ip_access=IpAccessDedicatedOrShared with http:65535 and with Docker
        # ... verify app is created

        # EDGECLOUD-371 - CreateApp with accessports of http shows protocol as TCP on ShowApp

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicatedOrShared and port=http65535:
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessDedicatedOrShared',
                                             access_ports = 'http:65535',
                                             default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)
       
        port_match = 'ports:\n        - containerPort: 65535\n          protocol: TCP' 
        expect(port_match in resp.deployment_manifest, 'manifest ports')
 
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppDockerIpAccessDedicatedOrSharedHTTP065535(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicatedOrShared/ImageTypeDocker/http:065535
        # ... create app with ip_access=IpAccessDedicatedOrShared with http:065535 and with Docker
        # ... verify app is created

        # EDGECLOUD-371 - CreateApp with accessports of http shows protocol as TCP on ShowApp

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicatedOrShared and port=http:065535
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessDedicatedOrShared',
                                             access_ports = 'http:065535',
                                             default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)

        port_match = 'ports:\n        - containerPort: 65535\n          protocol: TCP'
        expect(port_match in resp.deployment_manifest, 'manifest ports')
        
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppQCOWIpAccessDedicatedOrSharedTCP65535(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicatedOrShared/ImageTypeQCOW/tcp:65535
        # ... create app with ip_access=IpAccessDedicatedOrShared with tcp:65535 and with QCOW
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicatedOrShared QCOW tcp:65535
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessDedicatedOrShared',
                                             access_ports = 'tcp:65535',
                                             default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)
        
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppQCOWIpAccessDedicatedOrSharedTCP065535(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicatedOrShared/ImageTypeQCOW/tcp:065535
        # ... create app with ip_access=IpAccessDedicatedOrShared with tcp:065535 and with QCOW
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicatedOrShared QCOW tcp65535:
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessDedicatedOrShared',
                                             access_ports = 'tcp:065535',
                                             default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)
        
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppQCOWIpAccessDedicatedOrSharedUDP65535(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicatedOrShared/ImageTypeQCOW/udp:65535
        # ... create app with ip_access=IpAccessDedicatedOrShared with udp:65535 and with QCOW
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicatedOrShared QCOW udp:65535
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessDedicatedOrShared',
                                             access_ports = 'udp:65535',
                                             default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)
        
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppQCOWIpAccessDedicatedOrSharedUDP065535(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicatedOrShared/ImageTypeQCOW/udp:065535
        # ... create app with ip_access=IpAccessDedicatedOrShared with udp:065535 and with QCOW
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicatedOrShared QCOW udp:065535
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessDedicatedOrShared',
                                             access_ports = 'udp:065535',
                                             default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)
        
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def unsupported_test_CreateAppQCOWIpAccessDedicatedOrSharedHTTP65535(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicatedOrShared/ImageTypeQCOW/http:65535
        # ... create app with ip_access=IpAccessDedicatedOrShared with http:65535 and with QCOW
        # ... verify app is created

        # print the existing apps 
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicatedOrShared and port=http:65535
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessDedicatedOrShared',
                                             access_ports = 'http:65535',
                                             default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)
        
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def unsupported_test_CreateAppQCOWIpAccessDedicatedOrSharedHTTP065535(self):
        # [Documentation] App - User shall be able to create an app with IpAccessDedicatedOrShared/ImageTypeQCOW/http:065535
        # ... create app with ip_access=IpAccessDedicatedOrShared with http:065535 and with QCOW
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains ip_access=IpAccessDedicatedOrShared and port=http:01
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                             app_name=app_name,
                                             app_version=app_version,
                                             #cluster_name=cluster_name,
                                             developer_org_name=developer_name,
                                             ip_access = 'IpAccessDedicatedOrShared',
                                             access_ports = 'http:065535',
                                             default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)
        
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    @classmethod
    def tearDownClass(self):
        #self.controller.delete_cluster(self.cluster.cluster)
#        self.controller.delete_developer(self.developer.developer)
        self.controller.delete_flavor(self.flavor.flavor)

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

