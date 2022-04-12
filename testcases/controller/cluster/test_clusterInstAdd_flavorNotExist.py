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
# create a cluster.
# create a cluster instance with a flavor name that doesnt exist in ShowFlavor.
# verify error "Cluster flavor <flavornamr> not found" is returned because flavor does not exist
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

operator_name = 'tmus'
cloud_name = 'tmocloud-1'
cluster_name = 'cluster' + str(time.time())
flavor_name = 'fakeflavor'

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

        # no default flavor
        #self.operator = mex_controller.Operator(operator_name = operator_name)        
        self.cloudlet = mex_controller.Cloudlet(cloudlet_name = cloud_name,
                                                operator_org_name = operator_name,
                                                number_of_dynamic_ips = 254)
        #self.cluster = mex_controller.Cluster(cluster_name=cluster_name, use_defaults=False)
        self.cluster_instance = mex_controller.ClusterInstance(cluster_name=cluster_name,
                                                               cloudlet_name=cloud_name,
                                                               flavor_name=flavor_name,
                                                               operator_org_name=operator_name
                                                              )

        # create a new cluster for adding the instance
        #create_cluster_resp = self.controller.create_cluster(self.cluster.cluster)
        #self.controller.create_operator(self.operator.operator)
        #self.controller.create_cloudlet(self.cloudlet.cloudlet)

    def test_NoFlavor(self):
        # [Documentation] ClusterInst - User shall not be able to create a cluster instance for flavor that does not exist
        # ... create a cluster.
        # ... create a cluster instance with a flavor name that doesnt exist in ShowFlavor.
        # ... verify error Cluster flavor <flavornamr> not found is returned because flavor does not exist

        # print the existing cluster instances
        self.controller.show_cluster_instances()

        # create the cluster instance withour the flavor_name
        try:
            resp = self.controller.create_cluster_instance(self.cluster_instance.cluster_instance)
        except:
            print('create cluster instance failed')

        # print the cluster instances after adding 
        #time.sleep(1)
        clusterinst_resp = self.controller.show_cluster_instances()

        # verify clusterinst does not exist
        clusterinst_temp = self.cluster_instance
        found_cluster = clusterinst_temp.exists(clusterinst_resp)

        expect_equal(found_cluster, False, 'no flavor found new cluster')
        expect_equal(self.controller.response.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(self.controller.response.details(), 'Flavor {} not found'.format(flavor_name), 'error details')

        assert_expectations()

#    @classmethod
#    def tearDownClass(self):
        # delete cluster instance
        #self.controller.delete_cluster(self.cluster.cluster)
        #time.sleep(1)
        #self.controller.delete_cloudlet(self.cloudlet.cloudlet)
        #self.controller.delete_operator(self.operator.operator)


if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

