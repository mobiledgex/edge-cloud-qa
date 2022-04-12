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
# attempt to delete an operator which is in use by a cloudlet
# verify 'Operator in use by Cloudlet' error is received
# 

import unittest
import grpc
import sys
import time
import os
from delayedassert import expect, expect_equal, assert_expectations
import logging

import MexController as mex_controller

controller_address = os.getenv('AUTOMATION_CONTROLLER_ADDRESS', '127.0.0.1:55001')

stamp = str(time.time())
operator_name = 'operator' + stamp
cloudlet_name = 'cloudlet' + stamp

mex_root_cert = 'mex-ca.crt'
mex_cert = 'mex-client.crt'
mex_key = 'mex-client.key'

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
        
        self.operator = mex_controller.Operator(operator_name = operator_name)
        self.cloudlet = mex_controller.Cloudlet(cloudlet_name = cloudlet_name,
                                                operator_name = operator_name,
                                                latitude = 10,
                                                longitude = 10,
                                                number_of_dynamic_ips = 254)

        self.controller.create_operator(self.operator.operator)
        self.controller.create_cloudlet(self.cloudlet.cloudlet)

    def test_DeleteOperatorBeforeCloudlet(self):
        # print operators before delete
        operator_pre = self.controller.show_operators()

        # delete operator
        error = None
        try:
            self.controller.delete_operator(self.operator.operator)
        except grpc.RpcError as e:
            print('got exception', e)
            error = e

        # print operators after delete
        operator_post = self.controller.show_operators()
        
        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(error.details(), 'Operator in use by Cloudlet', 'error details')
        expect_equal(len(operator_post), len(operator_pre), 'num operator')

        assert_expectations()

    @classmethod
    def tearDownClass(self):
        self.controller.delete_cloudlet(self.cloudlet.cloudlet)
        #time.sleep(1) # wait for cloudlet to be deleted
        self.controller.delete_operator(self.operator.operator)

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

