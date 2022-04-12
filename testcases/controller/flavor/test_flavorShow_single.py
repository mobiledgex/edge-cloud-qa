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
# show flavor with name only
# verify only 1 flavor is returned
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
disk = 20
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

    def test_showFlavor_nameOnly(self):
        # [Documentation] Flavor - User shall be able to show flavor by name only
        # ... show flavor with name only
        # ... verify 1 flavor is returned

        # print flavors before add
        flavor_pre = self.controller.show_flavors()

        # create flavor
        self.flavor = mex_controller.Flavor(flavor_name = flavor_name,
                                            ram=ram,
                                            disk=disk,
                                            vcpus=vcpus
        )
        self.flavor2 = mex_controller.Flavor(flavor_name = flavor_name + '_2',
                                            ram=ram,
                                            disk=disk,
                                            vcpus=vcpus
        )
        self.flavor3 = mex_controller.Flavor(flavor_name = flavor_name + '_3',
                                            ram=ram,
                                            disk=disk,
                                            vcpus=vcpus
        )

        self.controller.create_flavor(self.flavor.flavor)
        self.controller.create_flavor(self.flavor2.flavor)
        self.controller.create_flavor(self.flavor3.flavor)
        # print flavors after add
        flavor_post = self.controller.show_flavors(mex_controller.Flavor(flavor_name = flavor_name).flavor)
        
        # find flavor
        found_flavor = self.flavor.exists(flavor_post)

        expect_equal(found_flavor, True, 'find flavor')
        #expect(len(flavor_pre) > 1, 'find flavor count pre')
        expect_equal(len(flavor_post), 1, 'find single flavor count')

        assert_expectations()

    def tearDown(self):
        self.controller.delete_flavor(self.flavor.flavor)
        self.controller.delete_flavor(self.flavor2.flavor)
        self.controller.delete_flavor(self.flavor3.flavor)

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

