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
# delete flavor with flavor name only
# verify flavor is deleted
# 

import unittest
import sys
import time
from delayedassert import expect, expect_equal, assert_expectations
import logging
import os

import MexController as mex_controller

controller_address = os.getenv('AUTOMATION_CONTROLLER_ADDRESS', '127.0.0.1:55001')

flavor_name = 'flavor' + str(int(time.time()))
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

    def test_deleteFlavorNameOnly(self):
        # [Documentation] Flavor - User shall be able to delete flavor with name only
        # ... delete flavor with flavor name only
        # ... verify flavor is deleted

        # print flavors before add
        flavor_pre = self.controller.show_flavors()

        # create flavor
        error = None
        self.flavor = mex_controller.Flavor(flavor_name=flavor_name, ram=ram, vcpus=vcpus, disk=disk)
        self.controller.create_flavor(self.flavor.flavor)

        # print flavors after add
        flavor_post = self.controller.show_flavors()

        # found flavor
        found_flavor = self.flavor.exists(flavor_post)

        # delete flavor by name only
        flavor_delete = mex_controller.Flavor(flavor_name=flavor_name)
        self.controller.delete_flavor(flavor_delete.flavor)

        # print flavors after delete
        flavor_delete_post = self.controller.show_flavors()

        # found flavor after delete
        found_flavor_delete = self.flavor.exists(flavor_delete_post)

        expect_equal(found_flavor, True, 'find flavor')
        #expect_equal(len(flavor_post), len(flavor_pre)+1, 'num flavor')

        expect_equal(found_flavor_delete, False, 'find flavor after delete')
        #expect_equal(len(flavor_delete_post), len(flavor_pre), 'num flavor after delete')

        assert_expectations()

#    def tearDown(self):
#        flavor_delete = mex_controller.Flavor(flavor_name=flavor_name)
#        self.controller.delete_flavor(flavor_delete.flavor)

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

