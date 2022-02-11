#!/usr/local/bin/python3

#EDGECLOUD-192 - fixed
#create an app with app name this is not docker compliant
#verify imagename is converted to docker compliant  - compiancy is checked in the mex_controller module

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
#developer_name = 'developer' + stamp
developer_name = 'mobiledgex'
developer_address = 'allen tx'
developer_email = 'dev@dev.com'
flavor_name = 'x1.small' + stamp
cluster_name = 'cluster' + stamp
#app_name = 'app' + stamp
app_name = 'server_ping_threaded'
app = 'server_ping_threaded' + stamp
app_version = '12.0'
access_ports = 'tcp:1'
docker = 'docker-qa.mobiledgex.net'

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
        #self.controller.create_developer(self.developer.developer) 
        #self.controller.create_cluster(self.cluster.cluster)

    def test_CreateNameSpace(self):
        # [Documentation] App - appname with spaces shall remove spaces in imagepath (docker compliant)
        # ... create an app with app name with spaces that is not docker compliant
        # ... verify imagename is converted to docker compliant with spaces removed

        # print the existing apps 
        apps_pre = self.controller.show_apps()

        # create the app
        self.app = mex_controller.App(image_type=image_type,
                                      #app_name='andy dandy',
                                      app_name='server_ ping_ threaded',
                                      app_version=app_version,
                                      access_ports=access_ports,
                                      #ip_access='IpAccessShared',
                                      #cluster_name=cluster_name,
                                      developer_org_name=developer_name,
                                      default_flavor_name=flavor_name,
                                      use_defaults=False)

        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        apps_post = self.controller.show_apps()

        # find app in list
        self.app.image_path = docker + '/' + developer_name + '/images/server_ping_threaded:' + app_version
        found_app = self.app.exists(apps_post)

        self.controller.delete_app(self.app.app)
        
        expect_equal(found_app, True, 'find app')
        #expect_equal(len(apps_post), len(apps_pre)+1, 'num developer')
                
        assert_expectations()

    def test_CreateAndSymbol(self):
        # [Documentation] App - appname with '&' shall convert them to dashes (docker compliant)
        # ... create an app with app name with '&' that is not docker compliant
        # ... verify imagename is converted to docker compliant with '&' converted to '-'

        # print the existing apps 
        apps_pre = self.controller.show_apps()

        # create the app
        self.app = mex_controller.App(image_type=image_type,
                                      app_name='server_ping&threaded',
                                      app_version=app_version,
                                      access_ports=access_ports,
                                      #cluster_name=cluster_name,
                                      developer_org_name=developer_name,
                                      default_flavor_name=flavor_name,
                                      use_defaults=False
                                    )

        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        apps_post = self.controller.show_apps()

        # find app in list
        self.app.image_path = docker + '/' + developer_name + '/images/server_ping-threaded:' + app_version
        found_app = self.app.exists(apps_post)

        self.controller.delete_app(self.app.app)
        
        expect_equal(found_app, True, 'find app')
        #expect_equal(len(apps_post), len(apps_pre)+1, 'num developer')
                
        assert_expectations()

    def test_CreateComma(self):
        # [Documentation] App - appname with commas shall remove them in imagepath (docker compliant)
        # ... create an app with app name with commas that is not docker compliant
        # ... verify imagename is converted to docker compliant with commas removed

        # print the existing apps 
        apps_pre = self.controller.show_apps()

        # create the app
        self.app = mex_controller.App(image_type=image_type,
                                      #app_name='andy,dandy',
                                      app_name='server_ping,_threaded',
                                      app_version=app_version,
                                      access_ports=access_ports,
                                      #cluster_name=cluster_name,
                                      developer_org_name=developer_name,
                                      default_flavor_name=flavor_name,
                                      use_defaults=False)

        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        apps_post = self.controller.show_apps()

        # find app in list
        self.app.image_path = docker + '/' + developer_name + '/images/server_ping_threaded:' + app_version
        found_app = self.app.exists(apps_post)

        self.controller.delete_app(self.app.app)
        
        expect_equal(found_app, True, 'find app')
        #expect_equal(len(apps_post), len(apps_pre)+1, 'num developer')
                
        assert_expectations()

    def test_CreateBang(self):
        # [Documentation] App - appname with '!' shall convert them to '.' (docker compliant)
        # ... create an app with app name with '!' that is not docker compliant
        # ... verify imagename is converted to docker compliant with '!' converted to '.'

        # print the existing apps 
        apps_pre = self.controller.show_apps()

        # create the app
        self.app = mex_controller.App(image_type=image_type,
                                      app_name='server_ping!threaded',
                                      app_version=app_version,
                                      access_ports=access_ports,
                                      #cluster_name=cluster_name,
                                      developer_org_name=developer_name,
                                      default_flavor_name=flavor_name,
                                      use_defaults=False)

        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        apps_post = self.controller.show_apps()

        # find app in list
        self.app.image_path = docker + '/' + developer_name + '/images/server_ping.threaded:' + app_version
        found_app = self.app.exists(apps_post)

        self.controller.delete_app(self.app.app)
        
        expect_equal(found_app, True, 'find app')
        #expect_equal(len(apps_post), len(apps_pre)+1, 'num developer')
                
        assert_expectations()

    @classmethod
    def tearDownClass(self):
        #self.controller.delete_cluster(self.cluster.cluster)
        #self.controller.delete_developer(self.developer.developer)
        self.controller.delete_flavor(self.flavor.flavor)

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

