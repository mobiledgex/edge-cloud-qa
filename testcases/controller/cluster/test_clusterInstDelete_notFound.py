#!/usr/bin/python3

#
# create a cluster instance with flavor_name
# delete the cluster instance with key not found error
# verify  proper error is generated
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

operator_name = 'tmus'
cloud_name = 'tmocloud-1'
flavor_name = 'c1.small'

mex_root_cert = 'mex-ca.crt'
mex_cert = 'localserver.crt'
mex_key = 'localserver.key'

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

class tc(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        self.cluster_name = 'cluster' + str(time.time())

        self.controller = mex_controller.MexController(controller_address = controller_address,
                                                    root_cert = mex_root_cert,
                                                    key = mex_key,
                                                    client_cert = mex_cert
                                                   ) 

        self.cluster_instance_clusterNameOnly = mex_controller.ClusterInstance(cluster_name=self.cluster_name, use_defaults=False)

        self.cluster_instance_noflavor = mex_controller.ClusterInstance(cluster_name=self.cluster_name,
                                                                        cloudlet_name=cloud_name,
                                                                        operator_name=operator_name,
                                                                        use_defaults=False
                                                                       )

        self.cluster_instance_noName = mex_controller.ClusterInstance(
                                                                        cloudlet_name=cloud_name,
                                                                        operator_name=operator_name,
                                                                        use_defaults=False
                                                                       )

    def test_DeleteClusterNameOnly(self):
        # [Documentation] ClusterInst - User shall receieve error when deleting cluster instance with name only and cluster not found
        # ... delete the cluster instance with name only and key not found error
        # ... verify proper error is generated

        # print the existing cluster instances
        clusterinst_before = self.controller.show_cluster_instances()

        # create the cluster instance
        try:
            self.controller.delete_cluster_instance(self.cluster_instance_clusterNameOnly.cluster_instance)
        except Exception as e:
            print('delete cluster failed:', e)

        # print the cluster instances after adding 
        #time.sleep(1)
        clusterinst_after_add = self.controller.show_cluster_instances()

        expect_equal(self.controller.response.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(self.controller.response.details(), 'Invalid operator name', 'error details')

        #expect_equal(self.controller.response.details(), 'Cloudlet operator_key:<>  not ready, state is CLOUDLET_STATE_NOT_PRESENT', 'error details')

        #expect_equal(len(clusterinst_after_add), len(clusterinst_before), 'count after add')

        assert_expectations()

    def test_DeleteClusterNoFlavor(self):
        # [Documentation] ClusterInst - User shall receieve error when deleting cluster instance with no flavor and cluster not found
        # ... delete the cluster instance with no flavor and key not found error
        # ... verify proper error is generated

        # print the existing cluster instances
        clusterinst_before = self.controller.show_cluster_instances()

        # create the cluster instance
        try:
            self.controller.delete_cluster_instance(self.cluster_instance_noflavor.cluster_instance)
        except:
            print('delete cluster failed')

        # print the cluster instances after adding
        #time.sleep(1)
        clusterinst_after_add = self.controller.show_cluster_instances()

        expect_equal(self.controller.response.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(self.controller.response.details(), 'Key not found', 'error details')

        #expect_equal(len(clusterinst_after_add), len(clusterinst_before), 'count after add')

        assert_expectations()

    def test_DeleteClusterNoName(self):
        # [Documentation] ClusterInst - User shall receieve error when deleting cluster instance with no name and cluster not found
        # ... delete the cluster instance with no name and key not found error
        # ... verify proper error is generated

        # print the existing cluster instances
        clusterinst_before = self.controller.show_cluster_instances()

        # create the cluster instance
        try:
            self.controller.delete_cluster_instance(self.cluster_instance_noName.cluster_instance)
        except:
            print('delete cluster failed')

        # print the cluster instances after adding
        #time.sleep(1)
        clusterinst_after_add = self.controller.show_cluster_instances()

        expect_equal(self.controller.response.code(), grpc.StatusCode.UNKNOWN, 'status code')
        #expect_equal(self.controller.response.details(), 'Key not found', 'error details')
        expect_equal(self.controller.response.details(), 'Invalid cluster name', 'error details')


        #expect_equal(len(clusterinst_after_add), len(clusterinst_before), 'count after add')

        assert_expectations()

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

