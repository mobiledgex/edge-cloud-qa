#!/usr/local/bin/python3

#
# create app twice
# verify 'Key already exists' is received
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
flavor_name_2 = 'x1.small' + stamp + '_2'
cluster_name = 'cluster' + stamp
app_name = 'app' + stamp
app_version = '1.0'
access_ports = 'tcp:1'

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
        self.flavor_2 = mex_controller.Flavor(flavor_name=flavor_name_2, ram=1024, vcpus=1, disk=1)
#        self.developer = mex_controller.Developer(developer_org_name=developer_name)#,
#                                                  #developer_address=developer_address,
#                                                  #developer_email=developer_email)
        #self.cluster = mex_controller.Cluster(cluster_name=cluster_name,
        #                                      default_flavor_name=flavor_name)

        self.controller.create_flavor(self.flavor.flavor)
        self.controller.create_flavor(self.flavor_2.flavor)
#        self.controller.create_developer(self.developer.developer) 
        #self.controller.create_cluster(self.cluster.cluster)

    def test_CreateAppDockerKeyExists(self):
        # [Documentation] App - User shall not be able to create the same app twice
        # ... create the same app twice 
        # ... verify 'Key already exists' is received

        # print the existing apps 
        app_pre = self.controller.show_apps()

        # create the app
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                      app_name=app_name,
                                      app_version=app_version,
                                      access_ports=access_ports,
                                      #cluster_name=cluster_name,
                                      developer_org_name=developer_name,
                                      default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        print('XXXXXXXXXXXXXXXXXXXXX')
        # try to add the app again
        err = None
        try:
            resp = self.controller.create_app(self.app.app)
        except grpc.RpcError as e:
            err = e
            logger.debug('got error:' + str(err))

        expect_equal(err.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(err.details(), 'App key {"developer_key":{"name":"' + developer_name + '"},"name":"' + app_name + '","version":"' + app_version + '"} already exists', 'error details')

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # find app in list
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)
        
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppDockerKeyExists_2(self):
        # [Documentation] App - User shall not be able to create an app with the same name but different parms
        # ... create 2 apps with the same name but different other parms 
        # ... verify 'Key already exists' is received

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                      app_name=app_name,
                                      app_version=app_version,
                                      access_ports=access_ports,
                                      #cluster_name=cluster_name,
                                      developer_org_name=developer_name,
                                      default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # create the app
        # contains image_type=Docker and no image_path
        app2 = mex_controller.App(image_type='ImageTypeQCOW',
                                      app_name=app_name,
                                      app_version=app_version,
                                      access_ports='tcp:1',
                                      ##cluster_name=cluster_name,
                                      developer_org_name=developer_name,
                                      default_flavor_name=flavor_name_2)

        # try to add the app again
        err = None
        try:
            resp = self.controller.create_app(app2.app)
        except grpc.RpcError as e:
            err = e
            logger.debug('got error:' + str(err))

        expect_equal(err.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(err.details(), 'App key {"developer_key":{"name":"' + developer_name + '"},"name":"' + app_name + '","version":"' + app_version + '"} already exists', 'error details')

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # find app in list
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)
        
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    @classmethod
    def tearDownClass(self):
        #self.controller.delete_cluster(self.cluster.cluster)
#        self.controller.delete_developer(self.developer.developer)
        self.controller.delete_flavor(self.flavor.flavor)
        self.controller.delete_flavor(self.flavor_2.flavor)

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

