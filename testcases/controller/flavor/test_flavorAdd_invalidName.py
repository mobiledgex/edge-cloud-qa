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
# create flavor with invalid name. should match "^[0-9a-zA-Z][-_0-9a-zA-Z .&,!]*$"
# verify 'Invalid flavor name' is created
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
        self.controller = mex_controller.MexController(controller_address = controller_address,
#                                                    root_cert = mex_root_cert,
#                                                    key = mex_key,
#                                                    client_cert = mex_cert
                                                   )

    def test_createFlavorStartUnderscore(self):
        # [Documentation] Flavor - User shall not be able to create a flavor starting with underscore 
        # ... create flavor with starting with underscore. should match '^[0-9a-zA-Z][-_0-9a-zA-Z .&,!]*$'
        # ... verify 'Invalid flavor name' is created

        # print flavors before add
        flavor_pre = self.controller.show_flavors()

        # create flavor
        error = None
        self.flavor = mex_controller.Flavor(flavor_name = '_myflavor')
        try:
            self.controller.create_flavor(self.flavor.flavor)
        except grpc.RpcError as e:
            logger.info('got exception ' + str(e))
            error = e

        # print flavors after add
        flavor_post = self.controller.show_flavors()
        
        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(error.details(), 'Invalid flavor name', 'error details')
        #expect_equal(len(flavor_post), len(flavor_pre), 'num flavor')

        assert_expectations()

    def test_createFlavorParenthesis(self):
        # [Documentation] Flavor - User shall not be able to create a flavor with parenthesis 
        # ... create flavor with parenthesis in the name. should match '^[0-9a-zA-Z][-_0-9a-zA-Z .&,!]*$'
        # ... verify 'Invalid flavor name' is created

        # print flavors before add
        flavor_pre = self.controller.show_flavors()

        # create flavor
        error = None
        self.flavor = mex_controller.Flavor(flavor_name='my(flavor)')
        try:
            self.controller.create_flavor(self.flavor.flavor)
        except grpc.RpcError as e:
            logger.info('got exception ' + str(e))
            error = e

        # print flavors after add
        flavor_post = self.controller.show_flavors()
        
        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(error.details(), 'Invalid flavor name', 'error details')
        #expect_equal(len(flavor_post), len(flavor_pre), 'num flavor')

    def test_createFlavorDollarsign(self):
        # [Documentation] Flavor - User shall not be able to create a flavor with a $ 
        # ... create flavor with with a $. should match '^[0-9a-zA-Z][-_0-9a-zA-Z .&,!]*$'
        # ... verify 'Invalid flavor name' is created

        # print flavors before add
        flavor_pre = self.controller.show_flavors()

        # create flavor
        error = None
        self.flavor = mex_controller.Flavor(flavor_name='my$flavor')
        try:
            self.controller.create_flavor(self.flavor.flavor)
        except grpc.RpcError as e:
            logger.info('got exception ' + str(e))
            error = e

        # print flavors after add
        flavor_post = self.controller.show_flavors()
        
        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(error.details(), 'Invalid flavor name', 'error details')
        #expect_equal(len(flavor_post), len(flavor_pre), 'num flavor')

    def test_createFlavorOtherInvalidChars(self):
        # [Documentation] Flavor - User shall not be able to create a flavor with multiple invalid chars
        # ... create flavor with invalid characters.  should match '^[0-9a-zA-Z][-_0-9a-zA-Z .&,!]*$'
        # ... verify 'Invalid flavor name' is created

        # print flavors before add
        flavor_pre = self.controller.show_flavors()

        # create flavor
        error = None
        self.flavor = mex_controller.Flavor(flavor_name='my@#%^*<>flavor')
        try:
            self.controller.create_flavor(self.flavor.flavor)
        except grpc.RpcError as e:
            logger.info('got exception ' + str(e))
            error = e

        # print flavors after add
        flavor_post = self.controller.show_flavors()
        
        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(error.details(), 'Invalid flavor name', 'error details')
        #expect_equal(len(flavor_post), len(flavor_pre), 'num flavor')


if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

