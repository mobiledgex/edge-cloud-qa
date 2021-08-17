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
import re

import MexController as mex_controller

controller_address = os.getenv('AUTOMATION_CONTROLLER_ADDRESS', '127.0.0.1:55001')

controller1_address = '0.0.0.0:55001' # will only be 1 controller shown since k8s runs it on the same port with replicas
#controller2_address = '0.0.0.0:55002'

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

    def test_showControllersAll(self):
        # [Documentation] Controller - User shall be able to show all contollers
        # ... show all controller
        # ... verify all controllers are shown

        # show controllers
        resp = self.controller.show_controllers()

#   ${build_head}=  Catenate  SEPARATOR=  ${nodes[0]['data']['build_master']}  +
#   Should Match Regexp             ${nodes[0]['data']['key']['name']}  \\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b:55001
#   Should Be Equal As Integers     ${nodes[0]['data']['key']['node_type']}  3
#   Should Be Equal As Integers     ${op_len}  0
#   Should Match Regexp             ${nodes[0]['data']['build_master']}  v\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\-\\d{1,3}-\\b
#   Should Be Equal                 ${nodes[0]['data']['build_head']}  ${build_head}
#   Should Match Regexp             ${nodes[0]['data']['hostname']}  ^controller-

#- key:
#    addr: 10.12.0.207:55001
#  buildmaster: v1.0.2-4-gab9d724
#  buildhead: v1.0.2-4-gab9d724+
#  hostname: controller-654688f58-chsrk

        re_master = re.compile('v\d{1,3}\.\d{0,3}\.\d{1,3}\-\d{1,9}-*')
        re_master2 = re.compile('v\d{1,3}\.\d{0,3}\-\d{1,9}-*')
        re_master3 = re.compile('v\d{1,3}\.\d{0,3}\.\d{1,3}\-rc\d{1,9}-*')
        re_master4 = re.compile('v\d{1,3}\.\d{0,3}\.\d{1,9}-*')

        re_host = re.compile('^controller-')
        re_ip = re.compile('\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}:\d{1,5}')

        build_head0 = resp[0].build_master + '+'
#        build_head1 = resp[1].build_master + '+'
 
        foundmaster0 = False
        foundhead0 = False
        foundhost0 = False
        foundip0 = False
        foundmaster1 = False
        foundhead1 = False
        foundhost1 = False
        foundip1 = False

        if re_master.match(resp[0].build_master) or re_master2.match(resp[0].build_master) or re_master3.match(resp[0].build_master) or re_master4.match(resp[0].build_master):
           foundmaster0=True
        if re_host.match(resp[0].hostname):
           foundhost0=True
        if re_ip.match(resp[0].key.addr):
           foundip0=True
        if resp[0].build_head == build_head0 or resp[0].build_head == resp[0].build_master:
           foundhead0 = True

# only have 1 controller now
#        if re_master.match(resp[1].build_master):
#           foundmaster1=True
#        if re_host.match(resp[1].hostname):
#           foundhost1=True
#        if re_ip.match(resp[1].key.addr):
#           foundip1=True
#        if resp[1].build_head == build_head1 or resp[1].build_head == resp[1].build_master:
#           foundhead1 = True
 
        expect_equal(len(resp), 2, 'number of controllers')
        expect_equal(foundmaster0, True, 'buildmaster')
        expect_equal(foundhost0, True, 'host')
        expect_equal(foundip0, True, 'host')
        expect_equal(foundhead0, True, 'buildhead0')

#        expect_equal(foundmaster1, True, 'buildmaster')
#        expect_equal(foundhost1, True, 'host')
#        expect_equal(foundip1, True, 'host')
#        expect_equal(foundhead1, True, 'buildhead1')

        #expect_equal(len(resp), 1, 'number of controllers')
        #expect_equal(resp[0].key.addr, controller1_address, 'addr 1')
        #expect_equal(resp[1].key.addr, controller2_address, 'addr 1')

        assert_expectations()

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

