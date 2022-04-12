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
# create the same cluster twice
# verify error of 'Key already exists' is retruned
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
        stamp = str(time.time())
        self.cluster_name = 'cluster' + stamp
        self.operator_name = 'tmus'
        self.cloud_name = 'tmocloud-1'
        self.flavor_name = 'c1.small' + stamp
        self.developer_name = 'developer' + stamp

#        self.operator = mex_controller.Operator(operator_name = self.operator_name)        
        self.cloudlet = mex_controller.Cloudlet(cloudlet_name = self.cloud_name,
                                                operator_org_name = self.operator_name,
                                                number_of_dynamic_ips = 254)
        self.flavor = mex_controller.Flavor(flavor_name=self.flavor_name, ram=1024, vcpus=1, disk=1)
        self.controller = mex_controller.MexController(controller_address = controller_address,
#                                                    root_cert = mex_root_cert,
#                                                    key = mex_key,
#                                                    client_cert = mex_cert
                                                   )
        #self.cluster = mex_controller.Cluster(cluster_name=cluster_name,
        #                                      default_flavor_name=flavor_name)

        self.cluster_instance = mex_controller.ClusterInstance(cluster_name=self.cluster_name,
                                                             cloudlet_name=self.cloud_name,
                                                             operator_org_name=self.operator_name,
                                                             developer_org_name=self.developer_name,
                                                             flavor_name=self.flavor_name)

        self.controller.create_flavor(self.flavor.flavor)
        #self.controller.create_operator(self.operator.operator)
        #self.controller.create_cloudlet(self.cloudlet.cloudlet)

    def test_CreateClusterTwice(self):
        # [Documentation] ClusterInst - User shall not be a to create the same cluster instance twice
        # ... create the same cluster twice
        # ... verify error of 'Key already exists' is retruned

        # print the existing cluster instances
        clusterinst_pre = self.controller.show_cluster_instances()

        # create a new cluster and cluster instance
        #create_cluster_resp = self.controller.create_cluster(self.cluster.cluster)
        self.controller.create_cluster_instance(self.cluster_instance.cluster_instance)
        #time.sleep(1)

        # create the cluster instance which already exists
        try:
            resp = self.controller.create_cluster_instance(self.cluster_instance.cluster_instance)
        except:
            print('create cluster instance failed')
        # print the cluster instances after error
        clusterinst_post = self.controller.show_cluster_instances()

        expect_equal(self.controller.response.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(self.controller.response.details(), 'ClusterInst key {"cluster_key":{"name":"' + self.cluster_name + '"},"cloudlet_key":{"organization":"' + self.operator_name + '","name":"' + self.cloud_name + '"},"organization":"' + self.developer_name + '"} already exists', 'error details')
        expect_equal(len(clusterinst_pre)+1, len(clusterinst_post), 'same number of cluster')
        assert_expectations()

    def tearDown(self):
        self.controller.delete_cluster_instance(self.cluster_instance.cluster_instance)
        #self.controller.delete_cluster(self.cluster.cluster)
        self.controller.delete_flavor(self.flavor.flavor)
        #self.controller.delete_cloudlet(self.cloudlet.cloudlet)
        #self.controller.delete_operator(self.operator.operator)

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

