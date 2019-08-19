#!/usr/bin/python3

#
# create cloudinst with flavor_name only
# create cloudinst with operator_name only
# create cloudinst with cloudlet_name only
# create cloudinst with cluster_name only
# create cloudinst with no parms
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

        #self.cluster_instance = mex_controller.ClusterInstance(flavor_name='flavor_name')

    def test_CreateClusterInstFlavorOnly(self):
        # [Documentation] ClusterInst - User shall not be able to create a cluster instance with flavor name only
        # ... create cloudinst with flavor_name only
        # ... verify error is received

        # print the existing cluster instances
        clusterinst_pre = self.controller.show_cluster_instances()

        # create the cluster instance with flavor_name only
        self.cluster_instance = mex_controller.ClusterInstance(flavor_name='flavor_name', use_defaults=False)
        try:
            resp = self.controller.create_cluster_instance(self.cluster_instance.cluster_instance)
        except Exception as e:
            print('got exception', e)

        # print the cluster instances after error
        clusterinst_post = self.controller.show_cluster_instances()

        expect_equal(self.controller.response.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(self.controller.response.details(), 'Invalid cluster name', 'error details')
        #expect_equal(self.controller.response.details(), 'Cloudlet operator_key:<>  not ready, state is CLOUDLET_STATE_NOT_PRESENT', 'error details')
        #expect_equal(len(clusterinst_pre), len(clusterinst_post), 'same number of cluster')
        assert_expectations()

    def test_CreateClusterInstOperatorOnly(self):
        # [Documentation] ClusterInst - User shall not be able to create a cluster instance with operator name only
        # ... create cloudinst with operator_name only
        # ... verify error is received

        # print the existing cluster instances
        clusterinst_pre = self.controller.show_cluster_instances()

        # create the cluster instance with flavor_name only
        self.cluster_instance = mex_controller.ClusterInstance(operator_name='tmus', use_defaults=False)
        try:
            resp = self.controller.create_cluster_instance(self.cluster_instance.cluster_instance)
        except Exception as e:
            print('got exception', e)

        # print the cluster instances after error
        clusterinst_post = self.controller.show_cluster_instances()

        expect_equal(self.controller.response.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(self.controller.response.details(), 'Invalid cluster name', 'error details')

        #expect_equal(self.controller.response.details(), 'Cloudlet operator_key:<name:"tmus" >  not ready, state is CLOUDLET_STATE_NOT_PRESENT', 'error details')
        #expect_equal(len(clusterinst_pre), len(clusterinst_post), 'same number of cluster')
        assert_expectations()

    def test_CreateClusterInstCloudletNameOnly(self):
        # [Documentation] ClusterInst - User shall not be able to create a cluster instance with cloudlet name only
        # ... create cloudinst with cloudlet_name only
        # ... verify error is received

        # print the existing cluster instances
        clusterinst_pre = self.controller.show_cluster_instances()

        # create the cluster instance with cloudlet_name only
        self.cluster_instance = mex_controller.ClusterInstance(cloudlet_name='tmocloud-1', use_defaults=False)
        try:
            resp = self.controller.create_cluster_instance(self.cluster_instance.cluster_instance)
        except Exception as e:
            print('got exception', e)

        # print the cluster instances after error
        clusterinst_post = self.controller.show_cluster_instances()

        expect_equal(self.controller.response.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(self.controller.response.details(), 'Invalid cluster name', 'error details')

        #expect_equal(self.controller.response.details(), 'Cloudlet operator_key:<> name:"tmocloud-1"  not ready, state is CLOUDLET_STATE_NOT_PRESENT', 'error details')
        #expect_equal(len(clusterinst_pre), len(clusterinst_post), 'same number of cluster')
        assert_expectations()

    def test_CreateClusterInstClusterNameOnly(self):
        # [Documentation] ClusterInst - User shall not be able to create a cluster instance with cluster name only
        # ... create cloudinst with cluster_name only
        # ... verify error is received

        # print the existing cluster instances
        clusterinst_pre = self.controller.show_cluster_instances()

        # create the cluster instance with cluste_name only
        self.cluster_instance = mex_controller.ClusterInstance(cluster_name='SmallCluster', use_defaults=False)
        try:
            resp = self.controller.create_cluster_instance(self.cluster_instance.cluster_instance)
        except Exception as e:
            print('got exception', e)

        # print the cluster instances after error
        clusterinst_post = self.controller.show_cluster_instances()

        expect_equal(self.controller.response.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(self.controller.response.details(), 'Invalid operator name', 'error details')

        #expect_equal(self.controller.response.details(), 'Cloudlet operator_key:<>  not ready, state is CLOUDLET_STATE_NOT_PRESENT', 'error details')
        #expect_equal(len(clusterinst_pre), len(clusterinst_post), 'same number of cluster')
        assert_expectations()

    def test_CreateClusterInstNoParms(self):
        # [Documentation] ClusterInst - User shall not be able to create a cluster instance with no parms
        # ... create cloudinst with no parms 
        # ... verify error is received

        # print the existing cluster instances
        clusterinst_pre = self.controller.show_cluster_instances()

        # create the cluster instance with flavor_name only
        self.cluster_instance = mex_controller.ClusterInstance(use_defaults=False)
        try:
            resp = self.controller.create_cluster_instance(self.cluster_instance.cluster_instance)
        except Exception as e:
            print('got exception', e)

        # print the cluster instances after error
        clusterinst_post = self.controller.show_cluster_instances()

        expect_equal(self.controller.response.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(self.controller.response.details(), 'Invalid cluster name', 'error details')

        #expect_equal(self.controller.response.details(), 'Cloudlet operator_key:<>  not ready, state is CLOUDLET_STATE_NOT_PRESENT', 'error details')
        #expect_equal(len(clusterinst_pre), len(clusterinst_post), 'same number of cluster')
        assert_expectations()

    def test_CreateClusterInstNoDeveloper(self):
        # [Documentation] ClusterInst - User shall not be able to create a cluster instance with no developer
        # ... create clusterinst with no developer
        # ... verify error is received

        # print the existing cluster instances
        clusterinst_pre = self.controller.show_cluster_instances()

        # create the cluster instance with no develeper 
        self.cluster_instance = mex_controller.ClusterInstance(cluster_name='mycluster',
                                                             cloudlet_name='tmocloud-1',
                                                             operator_name='tmus',
                                                             flavor_name='flavor_name',
                                                             use_defaults=False)
        try:
            resp = self.controller.create_cluster_instance(self.cluster_instance.cluster_instance)
        except Exception as e:
            print('got exception', e)

        # print the cluster instances after error
        clusterinst_post = self.controller.show_cluster_instances()

        expect_equal(self.controller.response.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(self.controller.response.details(), 'Developer cannot be empty', 'error details')
        assert_expectations()

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

