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
# create 100 flavors
# verify all 100 are created
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

number_of_flavors = 100

flavor_name = 'flavor' + str(time.time())
ram = 1024
disk = 1
vcpus = 1

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

        self.flavor_list = []
        for i in range(number_of_flavors):
            self.flavor_list.append(mex_controller.Flavor(flavor_name = flavor_name + str(i),
                                                          ram = ram,
                                                          disk = disk,
                                                          vcpus = vcpus
            ))
            
    def test_createFlavor(self):
        # [Documentation]  Flavor - User shall be able to create 100 flavors
        # ... Create 100 flavors
        # ... Verify all 100 are created

        # print flavors before add
        flavor_pre = self.controller.show_flavors()

        # create flavor
        for i in self.flavor_list:
            self.controller.create_flavor(i.flavor)

        # print flavorss after add
        flavor_post = self.controller.show_flavors()
        
        # find flavor in list
        for a in self.flavor_list:
            found_op = a.exists(flavor_post)
            expect_equal(found_op, True, 'find op' + a.flavor_name)

        # remove since causes problems with parallel execution. checking for all 100 above anyway
        #expect_equal(len(flavor_post), len(flavor_pre) + number_of_flavors, 'number of flavors')

        assert_expectations()

    @classmethod
    def tearDownClass(self):
        for a in self.flavor_list:
            self.controller.delete_flavor(a.flavor)

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

