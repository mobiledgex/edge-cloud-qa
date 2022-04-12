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
# show single operator
# verify it is shown
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

operator_name = 'operator' + str(time.time())

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

    def test_ShowOperatorSingle(self):
        self.operator2 = mex_controller.Operator(operator_name = operator_name + '_2')
        self.operator3 = mex_controller.Operator(operator_name = operator_name + '_3')
        self.controller.create_operator(self.operator2.operator)
        self.controller.create_operator(self.operator3.operator)

        # print operators before add
        operator_pre = self.controller.show_operators()

        # create operator
        self.operator = mex_controller.Operator(operator_name = operator_name)
        self.controller.create_operator(self.operator.operator)

        # print operators after add
        operator_post = self.controller.show_operators(self.operator.operator)
        
        # found operator
        found_operator = self.operator.exists(operator_post)

        self.controller.delete_operator(self.operator.operator)
        self.controller.delete_operator(self.operator2.operator)
        self.controller.delete_operator(self.operator3.operator)

        expect_equal(found_operator, True, 'find operator')
        expect(len(operator_pre) > 1, 'find operator count pre')
        expect_equal(len(operator_post), 1, 'find single operator count')
        assert_expectations()

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

