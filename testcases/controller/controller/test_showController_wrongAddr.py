#!/usr/local/bin/python3

#
# show controllers  with wrong address
# verify no controllers are listed
#

import unittest
import sys
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
                                                    root_cert = mex_root_cert,
                                                    key = mex_key,
                                                    client_cert = mex_cert
                                                   )

    def test_showControllersWrongAddr(self):
        # [Documentation] Controller - User shall be not be able to show contoller with wrong address
        # ... show controller with wrong address
        # ... verify no controllers are shown

        # show controllers
        resp = self.controller.show_controllers(address='0.0.0.0:999999')

        expect_equal(len(resp), 0, 'number of controllers')

        assert_expectations()

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

