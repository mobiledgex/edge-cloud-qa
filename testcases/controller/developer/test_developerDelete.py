#!/usr/local/bin/python3

#
# delete develpor
# verify it is deleted 
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

    def test_deleteDeveloper(self):
        # print developers before add
        developer_pre = self.controller.show_developers()

        # create developer
        self.developer = mex_controller.Developer(developer_name = developer_name)
        self.controller.create_developer(self.developer.developer)

        # print developers after add
        developer_post = self.controller.show_developers()
        
        # find developer
        found_developer = self.developer.exists(developer_post)

        self.controller.delete_developer(self.developer.developer)

        # print developers after delete
        developer_delete = self.controller.show_developers()

        # find developer after delete
        found_developer_delete = self.developer.exists(developer_delete)

        expect_equal(found_developer, True, 'find developer')
        expect_equal(found_developer_delete, False, 'find developer delete')
        #expect_equal(len(developer_delete), len(developer_post) - 1, 'num developer')  # remove since causes problem with parallel execution. cheching it is gone anyway above


        assert_expectations()

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

