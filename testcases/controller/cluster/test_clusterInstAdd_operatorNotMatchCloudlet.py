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
# create cluster
# create cloudinst with cloudletname that exists in cloudlets but does not match operator_name 
# verify Specified Cloudlet not found 
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
operator_name = 'ATT'
cloud_name = 'tmocloud-1'
flavor_name = 'c1.small' + stamp
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

        self.flavor = mex_controller.Flavor(flavor_name=flavor_name, ram=1024, vcpus=1, disk=1)
        #self.cluster = mex_controller.Cluster(cluster_name=cluster_name,
        #                                 default_flavor_name=flavor_name)

        self.cluster_instance = mex_controller.ClusterInstance(cluster_name=cluster_name,
                                                             cloudlet_name=cloud_name,
                                                             operator_org_name=operator_name,
                                                             flavor_name=flavor_name)

        self.controller.create_flavor(self.flavor.flavor)

    def test_OperatorNotMatchCloudlet(self):
        # [Documentation] ClusterInst - User shall not be able to create a cluster instance with cloudlet that does not match operator 
        # ... create cluster
        # ... create cloudinst with cloudletname that exists in cloudlets but does not match operator_name
        # ... verify Specified Cloudlet not found

        # print the existing cluster instances
        clusterinst_pre = self.controller.show_cluster_instances()

        # create a new cluster for adding the instance
        #create_cluster_resp = self.controller.create_cluster(self.cluster.cluster)

        # create the cluster instance with operator name that does not match cloudlet operator name 
        try:
            resp = self.controller.create_cluster_instance(self.cluster_instance.cluster_instance)
        except Exception as e:
            print('got exception', e)

        # print the cluster instances after error
        clusterinst_post = self.controller.show_cluster_instances()

        expect_equal(self.controller.response.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(self.controller.response.details(), 'Cloudlet key {"organization":"' + operator_name + '","name":"' + cloud_name + '"} not found', 'error details')
        #expect_equal(self.controller.response.details(), 'Cloudlet operator_key:<name:"' + operator_name + '" > name:"' + cloud_name + '"  not ready, state is CLOUDLET_STATE_NOT_PRESENT', 'error details')
        #expect_equal(len(clusterinst_pre), len(clusterinst_post), 'same number of cluster')
        assert_expectations()

    def tearDown(self):
        #self.controller.delete_cluster(self.cluster.cluster)
        self.controller.delete_flavor(self.flavor.flavor)


if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

