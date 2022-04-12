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


#
# attempt to delete flavor before the cluster flavor
# verify 'Flavor in use by Cluster Flavor' error is received
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
flavor_name = 'flavor' + stamp
ram = 1024
vcpus = 1
disk = 1
cluster_flavor_name = 'clusterflavor' + stamp

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

        self.flavor = mex_controller.Flavor(flavor_name=flavor_name,
                                            ram=ram,
                                            disk=disk,
                                            vcpus=vcpus)
        self.cluster_flavor = mex_controller.ClusterFlavor(cluster_flavor_name=cluster_flavor_name,
                                                    node_flavor_name=flavor_name,
                                                    master_flavor_name=flavor_name)

        self.controller.create_flavor(self.flavor.flavor) 
        self.controller.create_cluster_flavor(self.cluster_flavor.cluster_flavor)

    def test_DeleteFlavorBeforeClusterFlavor(self):
        # [Documentation] Flavor - User shall not be able to delete flavor before cluster flavor
        # ... attempt to delete flavor before the cluster flavor
        # ... verify 'Flavor in use by Cluster Flavor' error is received

        # print flavors before delete
        flavor_pre = self.controller.show_flavors()

        # delete flavor
        error = None
        try:
            self.controller.delete_flavor(self.flavor.flavor)
        except grpc.RpcError as e:
            logger.info('got exception ' + str(e))
            error = e

        # print flavors after delete
        flavor_post = self.controller.show_flavors()

        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(error.details(), 'Flavor in use by Cluster Flavor', 'error details')
        #expect_equal(len(flavor_post), len(flavor_pre), 'num flavor')

        assert_expectations()

    @classmethod
    def tearDownClass(self):
        self.controller.delete_cluster_flavor(self.cluster_flavor.cluster_flavor)
        self.controller.delete_flavor(self.flavor.flavor)

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

