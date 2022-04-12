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
# create a cluster instance with and without flavor_name
# delete the cluster instance
# verify cluster instance is deleted
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
operator_name = 'dmuus'
cloud_name = 'tmocloud-1'
flavor_name = 'c1.small' + stamp

mex_root_cert = 'mex-ca.crt'
mex_cert = 'mex-client.crt'
mex_key = 'mex-client.key'

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

class tc(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        self.cluster_name = 'cluster' + str(time.time())

        self.controller = mex_controller.MexController(controller_address = controller_address,
#                                                    root_cert = mex_root_cert,
#                                                    key = mex_key,
#                                                    client_cert = mex_cert
                                                   ) 

        #self.operator = mex_controller.Operator(operator_name = operator_name)        
        self.flavor = mex_controller.Flavor(flavor_name=flavor_name, ram=1024, vcpus=1, disk=1)
        #self.cluster = mex_controller.Cluster(cluster_name=self.cluster_name,
        #                                 default_flavor_name=flavor_name)
        self.cluster_instance_flavor = mex_controller.ClusterInstance(cluster_name=self.cluster_name,
                                                                      cloudlet_name=cloud_name,
                                                                      operator_org_name=operator_name,
                                                                      flavor_name=flavor_name)
        self.cluster_instance_noflavor = mex_controller.ClusterInstance(cluster_name=self.cluster_name,
                                                                        cloudlet_name=cloud_name,
                                                                        operator_org_name=operator_name,
                                                                        developer_org_name='mydev',
                                                                        number_masters=1,
                                                                        number_nodes=1,
                                                                        use_defaults=False)
        self.cloudlet = mex_controller.Cloudlet(cloudlet_name = cloud_name,
                                                operator_org_name = operator_name,
                                                number_of_dynamic_ips = 254)

        #self.controller.create_operator(self.operator.operator)
        self.controller.create_flavor(self.flavor.flavor)
        #self.controller.create_cloudlet(self.cloudlet.cloudlet)
        #self.controller.create_cluster(self.cluster.cluster)

    def test_DeleteClusterInstanceFlavor(self):
        # [Documentation] ClusterInst - User shall be able to delete a cluster instance with flavor name
        # ... create a cluster instance with flavor_name
        # ... delete the cluster instance
        # ... verify cluster instance is deleted

        # print the existing cluster instances
        clusterinst_before = self.controller.show_cluster_instances()

        # create a new cluster for adding the instance
        #create_cluster_resp = self.controller.create_cluster(self.cluster.cluster)

        # create the cluster instance
        self.controller.create_cluster_instance(self.cluster_instance_flavor.cluster_instance)

        # print the cluster instances after adding 
        #time.sleep(1)
        clusterinst_after_add = self.controller.show_cluster_instances()

        # look for the cluster
        found_cluster_after_add = self.cluster_instance_flavor.exists(clusterinst_after_add)

        expect_equal(found_cluster_after_add, True, 'found new cluster after add')
        #expect_equal(len(clusterinst_after_add), len(clusterinst_before)+1, 'count after add')

        #delete the clusterinst
        self.controller.delete_cluster_instance(self.cluster_instance_flavor.cluster_instance)

        # print the cluster instances after adding
        #time.sleep(1)
        clusterinst_after_delete = self.controller.show_cluster_instances()

        # look for the cluster after delete
        found_cluster_after_delete = self.cluster_instance_flavor.exists(clusterinst_after_delete)

        expect_equal(found_cluster_after_delete, False, 'found new cluster after delete')
        #expect_equal(len(clusterinst_after_delete), len(clusterinst_before), 'count after delete')

        assert_expectations()

    def unsupported_test_DeleteClusterInstanceNoFlavor(self):
        # [Documentation] ClusterInst - User shall be able to delete a cluster instance with no flavor name
        # ... create a cluster instance with no flavor_name
        # ... delete the cluster instance
        # ... verify cluster instance is deleted

        # removed from Stratus since can no longer create a clusterInst without a flavor name

        print('XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX')
        # print the existing cluster instances
        clusterinst_before = self.controller.show_cluster_instances()

        # create a new cluster for adding the instance
        #create_cluster_resp = self.controller.create_cluster(self.cluster.cluster)

        # create the cluster instance
        self.controller.create_cluster_instance(self.cluster_instance_noflavor.cluster_instance)

        # print the cluster instances after adding
        #time.sleep(1)
        clusterinst_after_add = self.controller.show_cluster_instances()

        # look for the cluster
        clusterinst_temp = self.cluster_instance_noflavor
        clusterinst_temp.flavor_name = flavor_name
        clusterinst_temp.liveness = 1   #LivenessStatic
        found_cluster_after_add = clusterinst_temp.exists(clusterinst_after_add)

        expect_equal(found_cluster_after_add, True, 'found new cluster after add')
        #expect_equal(len(clusterinst_after_add), len(clusterinst_before)+1, 'count after add')

        #delete the clusterinst
        self.controller.delete_cluster_instance(self.cluster_instance_noflavor.cluster_instance)

        # print the cluster instances after adding
        #time.sleep(1)
        clusterinst_after_delete = self.controller.show_cluster_instances()

        # look for the cluster after delete
        found_cluster_after_delete = clusterinst_temp.exists(clusterinst_after_delete)

        expect_equal(found_cluster_after_delete, False, 'found new cluster after delete')
        #expect_equal(len(clusterinst_after_delete), len(clusterinst_before), 'count after delete')

        assert_expectations()

    @classmethod
    def tearDownClass(self):
        #self.controller.delete_cluster(self.cluster.cluster)
        self.controller.delete_flavor(self.flavor.flavor)
        #self.controller.delete_cloudlet(self.cloudlet.cloudlet)
        #self.controller.delete_operator(self.operator.operator)

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

