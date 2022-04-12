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


# EDGECLOUD-208 - now has lower case 'autocluster' - fixed
# EDGECLOUD-240 - creating an autocluster doesnot always pick the same default_flavor
# create app with empty cluster and no cluster parm  
# verify AutoCluster is created in Cluster and has smallest flavor
# 
# updated testcases for EDGECLOUD-295

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
flavor_name = 'x1.tiny' + stamp
cluster_name = 'AutoCluster'
app_name = 'app' + stamp
app_version = '1.0'
cluster_flavor_name = 'c1.medium_2' + stamp
node_flavor_name = 'x1.tiny'
master_flavor_name = 'x1.small'
number_nodes = 1
max_nodes = 1
number_masters = 9
access_ports = 'tcp:1'

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
        self.controller.create_flavor(self.flavor.flavor)
        self.controller.create_developer(self.developer.developer) 
        
    def test_CreateAppNoCluster(self):
        # [Documentation] App - User shall not able to create an app with no cluster 
        # ... create app with no cluster parm
        # ... verify autocluster is created in Cluster and has smallest flavor

        # print the existing apps 
        app_pre = self.controller.show_apps()

        # print the clusters
        cluster_pre = self.controller.show_clusters()

        # create the app
        # contains no cluster and image_type=Docker
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                      app_name=app_name,
                                      image_path = 'myimagepath',
                                      app_version=app_version,
                                      access_ports=access_ports,
                                      #ip_access='IpAccessShared',
                                      #cluster_name='',
                                      developer_name=developer_name,
                                      default_flavor_name=flavor_name,
                                      use_defaults=False)

        resp = self.controller.create_app(self.app.app)

        # print the apps instances after error
        app_post = self.controller.show_apps()

        # print the cluster after add app
        cluster_post = self.controller.show_clusters()

        # find app in list
        apptemp = self.app
        # controller creates cluster with AutoCluster + app_name since cluster is empty
        #apptemp.cluster_name = 'autocluster' + app_name  
        apptemp.cluster_name = ''
        found_app = apptemp.exists(app_post)

        # find autocluster in list
        #time.sleep(1)
        cluster = mex_controller.Cluster(cluster_name='autocluster' + app_name,
                                         default_flavor_name=cluster_flavor_name)
        found_cluster = cluster.exists(cluster_post)

        self.controller.delete_app(self.app.app)
        
        expect_equal(found_cluster, False, 'find cluster')
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    def test_CreateAppEmptyCluster(self):
        # [Documentation] App - User shall be able to create an app with empty cluster
        # ... create app with empty cluster parm
        # ... verify autocluster is created in Cluster and has smallest flavor

        # print the existing apps
        app_pre = self.controller.show_apps()

        # print the clusters
        cluster_pre = self.controller.show_clusters()

        # create the app
        # contains no cluster and image_type=Docker
        self.app = mex_controller.App(image_type='ImageTypeQCOW',
                                      app_name=app_name,
                                      app_version=app_version,
                                      image_path = 'myimagepath#md5:12345678901234567890123456789012',
                                      access_ports=access_ports,
                                      cluster_name='',
                                      developer_name=developer_name,
                                      #ip_access='IpAccessShared',
                                      default_flavor_name=flavor_name,
                                      use_defaults=False)

        resp = self.controller.create_app(self.app.app)

        # print the apps instances after error
        app_post = self.controller.show_apps()

        # print the cluster after add app
        cluster_post = self.controller.show_clusters()

        # find app in list
        apptemp = self.app
        # controller creates cluster with AutoCluster + app_name since cluster is empty
        #apptemp.cluster_name = 'autocluster' + app_name
        apptemp.cluster_name = ''
        found_app = apptemp.exists(app_post)

        # find autocluster in list
        #time.sleep(1)
        cluster = mex_controller.Cluster(cluster_name='autocluster' + app_name,
                                         default_flavor_name=cluster_flavor_name)
        found_cluster = cluster.exists(cluster_post)

        self.controller.delete_app(self.app.app)
        
        expect_equal(found_cluster, False, 'find cluster')
        expect_equal(found_app, True, 'find app')
        assert_expectations()

    @classmethod
    def tearDownClass(self):
        self.controller.delete_developer(self.developer.developer)
        self.controller.delete_flavor(self.flavor.flavor)

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

