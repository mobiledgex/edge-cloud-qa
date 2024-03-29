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
# show flavor with ram/disk/vcpus only
# verify matching flavor is returned
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

stamp = str(int(time.time()))
flavor_name = 'flavor' + stamp
flavor_name_2 = 'flavor2' + stamp
ram = int(stamp)
disk = int(stamp)
vcpus = int(stamp)

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

        # create flavor
        self.flavor = mex_controller.Flavor(flavor_name = flavor_name,
                                            ram=ram,
                                            disk=disk,
                                            vcpus=vcpus
        )
        self.flavor_2 = mex_controller.Flavor(flavor_name = flavor_name_2,
                                            ram=ram,
                                            disk=disk,
                                            vcpus=vcpus
        )

        self.controller.create_flavor(self.flavor.flavor)
        self.controller.create_flavor(self.flavor_2.flavor)

        # print flavors before add
        self.flavor_pre = self.controller.show_flavors()

    def test_showFlavor_ram(self):
        # [Documentation] Flavor - User shall be able to show flavor by ram only
        # ... show flavor with ram only
        # ... verify matching flavor is returned

        # print flavors before add
        flavor_pre = self.controller.show_flavors()

        # print flavors after add
        flavor_post = self.controller.show_flavors(mex_controller.Flavor(ram = ram, use_defaults=False).flavor)
        
        # find flavor
        found_flavor = self.flavor.exists(flavor_post)
        found_flavor_2 = self.flavor_2.exists(flavor_post)


        expect_equal(found_flavor, True, 'find flavor')
        expect_equal(found_flavor_2, True, 'find flavor 2')
        #expect(len(self.flavor_pre) > 1, 'find flavor count pre')
        #expect_equal(len(flavor_post), 2, 'find single flavor count')

        assert_expectations()

    def test_showFlavor_disk(self):
        # [Documentation] Flavor - User shall be able to show flavor by disk only
        # ... show flavor with disk only
        # ... verify matching flavor is returned

        # print flavors before add
        flavor_pre = self.controller.show_flavors()

        # print flavors after add
        flavor_post = self.controller.show_flavors(mex_controller.Flavor(disk=disk, use_defaults=False).flavor)

        # find flavor
        found_flavor = self.flavor.exists(flavor_post)
        found_flavor_2 = self.flavor_2.exists(flavor_post)


        expect_equal(found_flavor, True, 'find flavor')
        expect_equal(found_flavor_2, True, 'find flavor 2')
        #expect(len(self.flavor_pre) > 1, 'find flavor count pre')
        #expect_equal(len(flavor_post), 2, 'find single flavor count')

        assert_expectations()

    def test_showFlavor_vcpus(self):
        # [Documentation] Flavor - User shall be able to show flavor by vcpus only
        # ... show flavor with vcpus only
        # ... verify matching flavor is returned

        # print flavors before add
        flavor_pre = self.controller.show_flavors()

        # print flavors after add
        flavor_post = self.controller.show_flavors(mex_controller.Flavor(vcpus=vcpus, use_defaults=False).flavor)

        # find flavor
        found_flavor = self.flavor.exists(flavor_post)
        found_flavor_2 = self.flavor_2.exists(flavor_post)


        expect_equal(found_flavor, True, 'find flavor')
        expect_equal(found_flavor_2, True, 'find flavor 2')
        #expect(len(self.flavor_pre) > 1, 'find flavor count pre')
        #expect_equal(len(flavor_post), 2, 'find single flavor count')

        assert_expectations()

    @classmethod
    def tearDownClass(self):
        self.controller.delete_flavor(self.flavor.flavor)
        self.controller.delete_flavor(self.flavor_2.flavor)

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

