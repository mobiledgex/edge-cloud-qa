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
# create a cluster instance for a cluster that does not exist
# verify 'Specified Cluster not found' is returned
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

mex_root_cert = 'mex-ca.crt'
mex_cert = 'mex-client.crt'
mex_key = 'mex-client.key'

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

class tc(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        cluster_name = 'cluster' + str(time.time())
        operator_name = 'dmuus'
        cloud_name = 'tmocloud-1'
        flavor_name = 'c1.small' + str(time.time())

        self.controller = mex_controller.MexController(controller_address = controller_address,
#                                                    root_cert = mex_root_cert,
#                                                    key = mex_key,
#                                                    client_cert = mex_cert
                                                   )

        #self.operator = mex_controller.Operator(operator_name = operator_name)        
        self.cloudlet = mex_controller.Cloudlet(cloudlet_name = cloud_name,
                                                operator_org_name = operator_name,
                                                number_of_dynamic_ips = 254)
        self.cluster_instance = mex_controller.ClusterInstance(cluster_name=cluster_name,
                                                             cloudlet_name=cloud_name,
                                                             operator_org_name=operator_name,
                                                             flavor_name=flavor_name)
        self.flavor = mex_controller.Flavor(flavor_name=flavor_name, ram=1024, vcpus=1, disk=1)

        #self.controller.create_operator(self.operator.operator)
        #self.controller.create_cloudlet(self.cloudlet.cloudlet)
        self.controller.create_flavor(self.flavor.flavor)

    def test_CreateClusterInstNoCluster(self):
        # [Documentation] ClusterInst - User shall not be able to create a cluster instance for cluster that does not exist
        # ... create a cluster instance for a cluster that does not exist
        # ... verify 'Specified Cluster not found' is returned

        # print the existing cluster instances
        clusterinst_pre = self.controller.show_cluster_instances()

        # create the cluster instance
        #try:
        #    resp = self.controller.create_cluster_instance(self.cluster_instance.cluster_instance)
        #    print('clusterInst created without cluster')
        #except:
        #    print('error creating cluster instance')

        resp = self.controller.create_cluster_instance(self.cluster_instance.cluster_instance)

        # print the cluster instances after error
        clusterinst_post = self.controller.show_cluster_instances()

        # look for the cluster
        found_cluster_after_add = self.cluster_instance.exists(clusterinst_post)

        expect_equal(found_cluster_after_add, True, 'found new cluster after add')

        #expect_equal(self.controller.response.code(), grpc.StatusCode.UNKNOWN, 'status code')
        #expect_equal(self.controller.response.details(), 'Specified Cluster not found', 'error details')
        #expect_equal(len(clusterinst_pre), len(clusterinst_post), 'same number of cluster')
        assert_expectations()

    @classmethod
    def tearDownClass(self):
        self.controller.delete_cluster_instance(self.cluster_instance.cluster_instance)
        self.controller.delete_flavor(self.flavor.flavor)
    #    self.controller.delete_cloudlet(self.cloudlet.cloudlet)
        #self.controller.delete_operator(self.operator.operator)

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

