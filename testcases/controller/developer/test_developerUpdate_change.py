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
# update developer by changing the values
# verify it is updated
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

    def test_updateDeveloperNameOnly(self):
        # print developers before add
        developer_pre = self.controller.show_developers()

        # create developer
        self.developer = mex_controller.Developer(developer_name = developer_name)
        self.controller.create_developer(self.developer.developer)

        # update developer
        self.controller.update_developer(self.developer.developer)
        
        # print developers after add
        developer_post = self.controller.show_developers()
        
        # found developer
        found_developer = self.developer.exists(developer_post)

        expect_equal(found_developer, True, 'find developer')
        assert_expectations()

    def unsupported_test_updateDeveloperSameParms(self):
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

        # update the developer
        self.controller.update_developer(self.developer.developer)
        
        # print developers after add
        developer_post = self.controller.show_developers()
        
        # found developer
        found_developer = self.developer.exists(developer_post)

        expect_equal(found_developer, True, 'find developer')
        assert_expectations()

    def unsupported_test_updateDeveloperAllParms(self):
        # print developers before add
        developer_pre = self.controller.show_developers()

        # create developer
        self.developer = mex_controller.Developer(developer_name = developer_name,
                                                  developer_email = developer_email,
                                                  developer_address = developer_address,
                                                  developer_username = developer_username,
                                                  developer_passhash = developer_passhash,
        )
        self.controller.create_developer(self.developer.developer)

        # update the developer
        self.developer_new = mex_controller.Developer(developer_name = developer_name,
                                                      developer_email = developer_email + 'new',
                                                      developer_address = developer_address + 'new',
                                                      developer_username = developer_username + 'new',
                                                      developer_passhash = developer_passhash + 'new',
                                                      include_fields = True
        )        
        self.controller.update_developer(self.developer_new.developer)
        
        # print developers after add
        developer_post = self.controller.show_developers()
        
        # found developer
        found_developer = self.developer_new.exists(developer_post)

        expect_equal(found_developer, True, 'find developer')
        assert_expectations()

    def unsupported_test_updateDeveloperEmail(self):
        # print developers before add
        developer_pre = self.controller.show_developers()

        # create developer
        self.developer = mex_controller.Developer(developer_name = developer_name,
                                                  developer_email = developer_email,
                                                  developer_address = developer_address,
                                                  developer_username = developer_username,
                                                  developer_passhash = developer_passhash,
        )
        self.controller.create_developer(self.developer.developer)

        # update the developer
        self.developer_new = mex_controller.Developer(developer_name = developer_name,
                                                      developer_email = developer_email + 'new',
                                                      include_fields = True
        )        
        self.controller.update_developer(self.developer_new.developer)
        
        # print developers after add
        developer_post = self.controller.show_developers()
        
        # found developer
        self.developer_search = self.developer_new
        self.developer_search.developer_address = developer_address
        self.developer_search.developer_username = developer_username
        self.developer_search.developer_passhash = developer_passhash
        found_developer = self.developer_search.exists(developer_post)

        expect_equal(found_developer, True, 'find developer')
        assert_expectations()

    def unsupported_test_updateDeveloperAddress(self):
        # print developers before add
        developer_pre = self.controller.show_developers()

        # create developer
        self.developer = mex_controller.Developer(developer_name = developer_name,
                                                  developer_email = developer_email,
                                                  developer_address = developer_address,
                                                  developer_username = developer_username,
                                                  developer_passhash = developer_passhash,
        )
        self.controller.create_developer(self.developer.developer)

        # update the developer
        self.developer_new = mex_controller.Developer(developer_name = developer_name,
                                                      developer_address = developer_address + 'new',
                                                      include_fields = True
        )        
        self.controller.update_developer(self.developer_new.developer)
        
        # print developers after add
        developer_post = self.controller.show_developers()
        
        # found developer
        self.developer_search = self.developer_new
        self.developer_search.developer_email = developer_email
        self.developer_search.developer_username = developer_username
        self.developer_search.developer_passhash = developer_passhash
        found_developer = self.developer_search.exists(developer_post)

        expect_equal(found_developer, True, 'find developer')
        assert_expectations()

    def unsupported_test_updateDeveloperUsername(self):
        # print developers before add
        developer_pre = self.controller.show_developers()

        # create developer
        self.developer = mex_controller.Developer(developer_name = developer_name,
                                                  developer_email = developer_email,
                                                  developer_address = developer_address,
                                                  developer_username = developer_username,
                                                  developer_passhash = developer_passhash,
        )
        self.controller.create_developer(self.developer.developer)

        # update the developer
        self.developer_new = mex_controller.Developer(developer_name = developer_name,
                                                      developer_username = developer_username + 'new',
                                                      include_fields = True
        )        
        self.controller.update_developer(self.developer_new.developer)
        
        # print developers after add
        developer_post = self.controller.show_developers()
        
        # found developer
        self.developer_search = self.developer_new
        self.developer_search.developer_address = developer_address
        self.developer_search.developer_email = developer_email
        self.developer_search.developer_passhash = developer_passhash
        found_developer = self.developer_search.exists(developer_post)

        expect_equal(found_developer, True, 'find developer')
        assert_expectations()

    def unsupported_test_updateDeveloperPasshash(self):
        # print developers before add
        developer_pre = self.controller.show_developers()

        # create developer
        self.developer = mex_controller.Developer(developer_name = developer_name,
                                                  developer_email = developer_email,
                                                  developer_address = developer_address,
                                                  developer_username = developer_username,
                                                  developer_passhash = developer_passhash,
        )
        self.controller.create_developer(self.developer.developer)

        # update the developer
        self.developer_new = mex_controller.Developer(developer_name = developer_name,
                                                      developer_passhash = developer_passhash + 'new',
                                                      include_fields = True
        )        
        self.controller.update_developer(self.developer_new.developer)
        
        # print developers after add
        developer_post = self.controller.show_developers()
        
        # found developer
        self.developer_search = self.developer_new
        self.developer_search.developer_address = developer_address
        self.developer_search.developer_username = developer_username
        self.developer_search.developer_email = developer_email
        found_developer = self.developer_search.exists(developer_post)

        expect_equal(found_developer, True, 'find developer')
        assert_expectations()

    def tearDown(self):
        self.controller.delete_developer(self.developer.developer)

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

