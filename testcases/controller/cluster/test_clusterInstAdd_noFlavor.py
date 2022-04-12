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
# create a cluster instance without a flavor name.
# verify the default flavor name from the cluster is added to the cluster instance when it is created
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
operator_name = 'tmus'
cloud_name = 'tmocloud-1'
flavor_name = 'c1.tiny' + stamp
cluster_name = 'cluster' + stamp

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

        #self.operator = mex_controller.Operator(operator_name = operator_name)        
        self.flavor = mex_controller.Flavor(flavor_name=flavor_name, ram=1024, vcpus=1, disk=1)
        #self.cluster = mex_controller.Cluster(cluster_name=cluster_name,
        #                                 default_flavor_name=flavor_name)
        self.cloudlet = mex_controller.Cloudlet(cloudlet_name = cloud_name,
                                                operator_org_name = operator_name,
                                                number_of_dynamic_ips = 254)

        # flavor_name  does not exist
        self.cluster_instance_noFlavor = mex_controller.ClusterInstance(cluster_name=cluster_name,
                                                                        cloudlet_name=cloud_name,
                                                                        operator_org_name=operator_name,
                                                                        developer_org_name='mydev',
                                                                        number_masters=1,
                                                                        number_nodes=1,
                                                                        use_defaults=False
                                                                       )
        # flavor_name is empty
        self.cluster_instance_emptyFlavor = mex_controller.ClusterInstance(cluster_name=cluster_name,
                                                                           cloudlet_name=cloud_name,
                                                                           flavor_name='',
                                                                           developer_org_name='mydev',
                                                                           operator_org_name=operator_name
                                                                          )

        # create a new cluster for adding the instance
        #self.controller.create_operator(self.operator.operator)
        self.controller.create_flavor(self.flavor.flavor)
        #create_cluster_resp = self.controller.create_cluster(self.cluster.cluster)
        #self.controller.create_cloudlet(self.cloudlet.cloudlet)

    def test_NoFlavor(self):
        # [Documentation] ClusterInst - User shall be able to create a cluster instance with no flavor name
        # ... create a cluster instance without a flavor name.
        # ... verify the default flavor name from the cluster is added to the cluster instance when it is created

        # print the existing cluster instances
        self.controller.show_cluster_instances()

        # create the cluster instance withour the flavor_name
        try:
           self.controller.create_cluster_instance(self.cluster_instance_noFlavor.cluster_instance)
        except:
           print('create clusterInst successful')

        # print the cluster instances after adding 
        #time.sleep(1)
        clusterinst_resp = self.controller.show_cluster_instances()

        # delete cluster instance
        #self.controller.delete_cluster_instance(self.cluster_instance_noFlavor.cluster_instance)

        # verify ci.tiny is picked up from the default_flavor_name
        #clusterinst_temp = self.cluster_instance_noFlavor
        #clusterinst_temp.flavor_name = flavor_name
        #clusterinst_temp.liveness = 1  # LivenessStatic
        #found_cluster = clusterinst_temp.exists(clusterinst_resp)

        #expect_equal(found_cluster, True, 'no flavor found new cluster')

        expect_equal(self.controller.response.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(self.controller.response.details(), 'No Flavor specified', 'error details')

        assert_expectations()

    def test_EmptyFlavor(self):
        # [Documentation] ClusterInst - User shall be able to create a cluster instance with empty flavor name
        # ... create a cluster instance with empty flavor name.
        # ... verify the default flavor name from the cluster is added to the cluster instance when it is created

        # print the existing cluster instances
        self.controller.show_cluster_instances()

        # create the cluster instance with flavor_name empty
        try:
           self.controller.create_cluster_instance(self.cluster_instance_emptyFlavor.cluster_instance)
        except:
           print('clusterInst created succesfully')

        # print the cluster instances after adding
        #time.sleep(1)
        #clusterinst_resp = self.controller.show_cluster_instances()

        # delete cluster instance
        #self.controller.delete_cluster_instance(self.cluster_instance_emptyFlavor.cluster_instance)

        # verify ci.tiny is picked up from the default_flavor_name
        #clusterinst_temp = self.cluster_instance_emptyFlavor
        #clusterinst_temp.flavor_name = flavor_name
        #found_cluster = clusterinst_temp.exists(clusterinst_resp)

        #expect_equal(found_cluster, True, 'empty flavor found new cluster')

        expect_equal(self.controller.response.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(self.controller.response.details(), 'No Flavor specified', 'error details')

        assert_expectations()

    @classmethod
    def tearDownClass(self):
        # delete cluster instance
        #self.controller.delete_cluster(self.cluster.cluster)
        self.controller.delete_flavor(self.flavor.flavor)
        #self.controller.delete_cloudlet(self.cloudlet.cloudlet)
        #self.controller.delete_operator(self.operator.operator)

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

