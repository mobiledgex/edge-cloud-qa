#!/usr/local/bin/python3

#
# create app with image_path with Docker and QCOW
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
access_ports = 'tcp:1'
docker = 'docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded:5.0'
qcow_image = 'https://artifactory.mobiledgex.net/artifactory/repo-MobiledgeX/server_ping_threaded_centos7.qcow2#md5:5ce8dbcdd8b7c2054779d742f4bf602d'

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

    def test_CreateAppDockerImagePath(self):
        # [Documentation] App - User shall be able to create an app with imagepath and type Docker
        # ... create an app with imagepath and type Docker
        # ... verify app is created

        # print the existing apps 
        app_pre = self.controller.show_apps()

        # create the app
        # contains Docker and image_path
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                      image_path=docker,
                                      app_name=app_name,
                                      app_version=app_version,
                                      #cluster_name=cluster_name,
                                      developer_org_name=developer_name,
                                      access_ports=access_ports,
                                      default_flavor_name=flavor_name)

        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for app
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)
                
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppQCOWImagePath(self):
        # [Documentation] App - User shall be able to create an app with imagepath and type QCOW
        # ... create an app with imagepath and type QCOW
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains QCOW and image_path
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                      image_path=qcow_image,
                                      app_name=app_name,
                                      app_version=app_version,
                                      #cluster_name=cluster_name,
                                      developer_org_name=developer_name,
                                      access_ports=access_ports,
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

