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
# create developer with optional parms
# verify it is created
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

developer_name = 'developer' + str(time.time())
developer_address = '502 creekside ln, Allen, TX 75002'
developer_email = 'tester@automation.com'
developer_username = 'username'
developer_passhash = 'sdfasfadfafasfafafafafaeffsdffasfafafafadafafafafdafafafaerqwerqwrasfasfasf'

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

    def unsupported_test_createDeveloper_nameAddress(self):
        # print developers before add
        developer_pre = self.controller.show_developers()

        # create developer
        self.developer = mex_controller.Developer(developer_name = developer_name,
                                                  developer_address = developer_address)
        self.controller.create_developer(self.developer.developer)

        # print developers after add
        developer_post = self.controller.show_developers()
        
        # find developer
        found_developer = self.developer.exists(developer_post)

        expect_equal(found_developer, True, 'find developer')
        assert_expectations()

    def unsupported_test_createDeveloper_nameEmail(self):
        # print developers before add
        developer_pre = self.controller.show_developers()

        # create developer
        self.developer = mex_controller.Developer(developer_name = developer_name,
                                                  developer_email = developer_email,
        )
        self.controller.create_developer(self.developer.developer)

        # print developers after add
        developer_post = self.controller.show_developers()
        
        # find developer
        found_developer = self.developer.exists(developer_post)

        expect_equal(found_developer, True, 'find developer')
        assert_expectations()

    def unsupported_test_createDeveloper_nameUsername(self):
        # print developers before add
        developer_pre = self.controller.show_developers()

        # create developer
        self.developer = mex_controller.Developer(developer_name = developer_name,
                                                  developer_username = developer_username,
        )
        self.controller.create_developer(self.developer.developer)

        # print developers after add
        developer_post = self.controller.show_developers()
        
        # find developer
        found_developer = self.developer.exists(developer_post)

        expect_equal(found_developer, True, 'find developer')
        assert_expectations()

    def unsupported_test_createDeveloper_namePasshash(self):
        # print developers before add
        developer_pre = self.controller.show_developers()

        # create developer
        self.developer = mex_controller.Developer(developer_name = developer_name,
                                                  developer_passhash = developer_passhash,
        )
        self.controller.create_developer(self.developer.developer)

        # print developers after add
        developer_post = self.controller.show_developers()
        
        # find developer
        found_developer = self.developer.exists(developer_post)

        expect_equal(found_developer, True, 'find developer')
        assert_expectations()

    def unsupported_test_createDeveloper_nameAllOptional(self):
        # print developers before add
        developer_pre = self.controller.show_developers()

        # create developer
        self.developer = mex_controller.Developer(developer_name = developer_name,
                                                  developer_email = developer_email,
                                                  developer_address = developer_address,
                                                  developer_username = developer_email,
                                                  developer_passhash = developer_passhash,
        )
        self.controller.create_developer(self.developer.developer)

        # print developers after add
        developer_post = self.controller.show_developers()
        
        # find developer
        found_developer = self.developer.exists(developer_post)

        expect_equal(found_developer, True, 'find developer')
        assert_expectations()

    def tearDown(self):
        self.controller.delete_developer(self.developer.developer)

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

