#!/usr/local/bin/python3

#
# show all controllers 
# verify all controllers are listed
#

import unittest
import sys
from delayedassert import expect, expect_equal, assert_expectations
import logging
import os

import MexController as mex_controller

controller_address = os.getenv('AUTOMATION_CONTROLLER_ADDRESS', '127.0.0.1:55001')

controller1_address = '0.0.0.0:55001' # will only be 1 controller shown since k8s runs it on the same port with replicas
#controller2_address = '0.0.0.0:55002'

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

    def test_showControllersAll(self):
        # [Documentation] Controller - User shall be able to show all contollers
        # ... show all controller
        # ... verify all controllers are shown

        # show controllers
        resp = self.controller.show_controllers()

        #expect_equal(len(resp), 2, 'number of controllers')
        expect_equal(len(resp), 1, 'number of controllers')
        expect_equal(resp[0].key.addr, controller1_address, 'addr 1')
        #expect_equal(resp[1].key.addr, controller2_address, 'addr 1')

        assert_expectations()

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

