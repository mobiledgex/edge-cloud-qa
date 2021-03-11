#!/usr/local/bin/python3

#
# show controllers by address
# verify controllers is shown
#

import unittest
import sys
from delayedassert import expect, expect_equal, assert_expectations
import logging
import os
import re

import MexController as mex_controller

controller_address = os.getenv('AUTOMATION_CONTROLLER_ADDRESS', '127.0.0.1:55001')

#controller_address_list = ['0.0.0.0:55001', '0.0.0.0:55002']
controller_address_list = ['0.0.0.0:55001']  # will only be 1 controller shown since k8s runs it on the same port with replicas

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

    def test_showControllersAddr(self):
        # [Documentation] Controller - User shall be able to show contoller by address
        # ... show controller by address
        # ... verify controller is shown

        re_master = re.compile('v\d{1,3}\.\d{0,3}\.\d{1,3}\-\d{1,9}-*')
        re_master2 = re.compile('v\d{1,3}\.\d{0,3}\-\d{1,9}-*')
        re_master3 = re.compile('v\d{1,3}\.\d{0,3}\.\d{1,3}\-rc\d{1,9}-*')
        re_master4 = re.compile('v\d{1,3}\.\d{0,3}\.\d{1,9}-*')

        re_host = re.compile('^controller-')
        re_ip = re.compile('\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}:\d{1,5}')

        resp = self.controller.show_controllers()

        # show controllers
        for controller in resp:
            resp = self.controller.show_controllers(address=controller.key.addr)

            build_head = resp[0].build_master + '+'

            foundmaster = False
            foundhead = False
            foundhost = False
            foundip = False
            foundbuild = False

            if re_master.match(resp[0].build_master) or re_master2.match(resp[0].build_master) or re_master3.match(resp[0].build_master) or re_master4.match(resp[0].build_master):
               foundmaster=True
            if re_host.match(resp[0].hostname):
               foundhost=True
            if re_ip.match(resp[0].key.addr):
               foundip=True
            if resp[0].build_head == build_head or resp[0].build_head == resp[0].build_master:
               foundhead = True

            expect_equal(foundmaster, True, 'buildmaster')
            expect_equal(foundhost, True, 'host')
            expect_equal(foundip, True, 'host')
            expect_equal(foundhead, True, 'buildhead')

            expect_equal(len(resp), 1, 'number of controllers')

        assert_expectations()

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

