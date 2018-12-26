#!/usr/local/bin/python3

#
# create app with config and with Docker and QCOW
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
#config = 'config' + stamp
access_ports = 'tcp:1'
config = '"template": { "spec": { "hostAliases": [ { "ip": "37.50.143.121", "hostnames": [ "bonnedgecloud.telekom.de" ] }]}}'
config_http = 'http://35.199.188.102/apps/dummyconfig.json'
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

    def test_CreateAppDockerConfig_inline(self):
        # [Documentation] App - User shall be able to create an app with inline config and type Docker
        # ... create an app with inline config and type Docker
        # ... verify app is created

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

        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for AccessLayerL7 since it is not sent in create
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)
        
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppQCOWConfig(self):
        # [Documentation] App - User shall be able to create an app with inline config and type QCOW
        # ... create an app with inline config and type QCOW
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains config
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                      app_name=app_name,
                                      access_ports=access_ports,
                                      app_version=app_version,
                                      cluster_name=cluster_name,
                                      developer_name=developer_name,
                                      config=config,
                                      default_flavor_name=flavor_name)
        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for AccessLayerL7 since it is not sent in create
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)
        
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppDockerConfig_http(self):
        # [Documentation] App - User shall be able to create an app with http config and type Docker
        # ... create an app with http config and type Docker
        # ... verify app is created

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

        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for AccessLayerL7 since it is not sent in create
        self.app.config = config + '\n'
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)

        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppQCOWConfig_http(self):
        # [Documentation] App - User shall be able to create an app with http config and type QCOW
        # ... create an app with http config and type QCOW
        # ... verify app is created

        # print the existing apps
        app_pre = self.controller.show_apps()

        # create the app
        # contains config
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                      app_name=app_name,
                                      access_ports=access_ports,
                                      app_version=app_version,
                                      cluster_name=cluster_name,
                                      developer_name=developer_name,
                                      config=config_http,
                                      default_flavor_name=flavor_name)

        resp = self.controller.create_app(self.app.app)

        # print the cluster instances after error
        app_post = self.controller.show_apps()

        # look for AccessLayerL7 since it is not sent in create
        self.app.config = config + '\n'
        found_app = self.app.exists(app_post)

        self.controller.delete_app(self.app.app)

        expect_equal(found_app, True, 'find app')
        assert_expectations()

    @classmethod
    def tearDownClassxs(self):
        self.controller.delete_cluster(self.cluster.cluster)
        self.controller.delete_developer(self.developer.developer)
        self.controller.delete_cluster_flavor(self.cluster_flavor.cluster_flavor)
        self.controller.delete_flavor(self.flavor.flavor)

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

