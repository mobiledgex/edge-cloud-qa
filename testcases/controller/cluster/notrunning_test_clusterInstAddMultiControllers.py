#!/usr/bin/python3
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
# create a cluster instance  on 2 controllers
# verify both cluster instances show on both controllers
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

controller_address_1 = '127.0.0.1:55001'
controller_address_2 = '127.0.0.1:55002'
operator_name = 'dmuus'
cloud_name_1 = 'tmocloud-1'
cloud_name_2 = 'tmocloud-2'
flavor_name = 'c1.small'

mex_root_cert = 'mex-ca.crt'
mex_cert = 'localserver.crt'
mex_key = 'localserver.key'

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

class tc(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        self.cluster_name = 'cluster' + str(time.time())


        self.controller_1 = mex_controller.MexController(controller_address = controller_address_1,
                                                      root_cert = mex_root_cert,
                                                      key = mex_key,
                                                      client_cert = mex_cert
                                                     ) 
        self.controller_2 = mex_controller.MexController(controller_address = controller_address_2,
                                                      root_cert = mex_root_cert,
                                                      key = mex_key,
                                                      client_cert = mex_cert
                                                     )

#        self.cluster = mex_controller.Cluster(cluster_name=self.cluster_name,
#                                              default_flavor_name=flavor_name)

        self.cluster_instance_1 = mex_controller.ClusterInstance(cluster_name=self.cluster_name,
                                                                 cloudlet_name=cloud_name_1,
                                                                 operator_name=operator_name,
                                                                 flavor_name=flavor_name)
        self.cluster_instance_2 = mex_controller.ClusterInstance(cluster_name=self.cluster_name,
                                                                 cloudlet_name=cloud_name_2,
                                                                 operator_name=operator_name,
                                                                 flavor_name=flavor_name)


    def test_AddClusterInstance(self):
        # print the existing cluster instances
        self.controller_1.show_cluster_instances()

        # create a new cluster for adding the instance
        #create_cluster_resp = self.controller_1.create_cluster(self.cluster.cluster)

        # create the cluster instance
        self.controller_1.create_cluster_instance(self.cluster_instance_1.cluster_instance)
        #time.sleep(1)
        self.controller_2.create_cluster_instance(self.cluster_instance_2.cluster_instance)

        # print the cluster instances after adding 
        #time.sleep(1)
        clusterinst_resp_1 = self.controller_1.show_cluster_instances()
        clusterinst_resp_2 = self.controller_2.show_cluster_instances()

        # look for the cluster
        found_cluster_11 = self.cluster_instance_1.exists(clusterinst_resp_1)
        found_cluster_12 = self.cluster_instance_1.exists(clusterinst_resp_2)
        found_cluster_21 = self.cluster_instance_2.exists(clusterinst_resp_1)
        found_cluster_22 = self.cluster_instance_2.exists(clusterinst_resp_2)

        expect_equal(found_cluster_11, True, 'found new cluster 11')
        expect_equal(found_cluster_12, True, 'found new cluster 12')
        expect_equal(found_cluster_21, True, 'found new cluster 21')
        expect_equal(found_cluster_22, True, 'found new cluster 22')

        assert_expectations()

    def tearDown(self):
        self.controller_1.delete_cluster_instance(self.cluster_instance_1.cluster_instance)
        self.controller_2.delete_cluster_instance(self.cluster_instance_2.cluster_instance)
        #self.controller_1.delete_cluster(self.cluster.cluster)

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

