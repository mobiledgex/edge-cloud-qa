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
# send update cluster instance
# verify error of unsupported is retruned
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
        flavor_name = 'c1.small'

        self.controller = mex_controller.MexController(controller_address = controller_address,
#                                                    root_cert = mex_root_cert,
#                                                    key = mex_key,
#                                                    client_cert = mex_cert
                                                   )
        self.cluster_instance = mex_controller.ClusterInstance(cluster_name=cluster_name,
                                                             cloudlet_name=cloud_name,
                                                             operator_org_name=operator_name,
                                                             flavor_name=flavor_name)

    def test_UpdateClusterInst(self):
        # [Documentation] ClusterInst - User shall not be able to update an unsupported field in cluster instance
        # ... send update cluster instance
        # ... verify error of unsupported is retruned

        # create a new cluster and cluster instance
        resp = self.controller.update_cluster_instance(self.cluster_instance.cluster_instance)

        expect_equal(resp.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(resp.details(), 'Nothing specified to update', 'error details')
        assert_expectations()

#    def tearDown(self):
#        self.controller.delete_cluster_instance(self.cluster_instance.cluster_instance)
#        self.controller.delete_cluster(self.cluster.cluster)

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

