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
# create 100 operators
# verify all 100 are created
# 

import unittest
import grpc
import sys
import time
import os
from delayedassert import expect, expect_equal, assert_expectations
import logging

import MexController as mex_controller

number_of_operators = 100

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

        self.operator_list = []
        for i in range(number_of_operators):
            self.operator_list.append(mex_controller.Operator(operator_name = 'operator ' + str(i)))
            
    def test_createOperator(self):
        # print operators before add
        operator_pre = self.controller.show_operators()

        # create operator
        for i in self.operator_list:
            self.controller.create_operator(i.operator)

        # print operators after add
        operator_post = self.controller.show_operators()
        
        # find operator in list
        for a in self.operator_list:
            found_op = a.exists(operator_post)
            expect_equal(found_op, True, 'find op' + a.operator_name)

        expect_equal(len(operator_post), len(operator_pre) + number_of_operators, 'number of operators')

        assert_expectations()

    @classmethod
    def tearDownClass(self):
        for a in self.operator_list:
            self.controller.delete_operator(a.operator)

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

