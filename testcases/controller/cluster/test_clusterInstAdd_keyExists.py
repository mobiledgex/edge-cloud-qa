#!/usr/bin/python3

#
# create the same cluster twice
# verify error of 'Key already exists' is retruned
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
        stamp = str(time.time())
        cluster_name = 'cluster' + stamp
        operator_name = 'dmuus'
        cloud_name = 'tmocloud-1'
        flavor_name = 'c1.small' + stamp

        self.operator = mex_controller.Operator(operator_name = operator_name)        
        self.cloudlet = mex_controller.Cloudlet(cloudlet_name = cloud_name,
                                                operator_name = operator_name,
                                                number_of_dynamic_ips = 254)
        self.flavor = mex_controller.Flavor(flavor_name=flavor_name, ram=1024, vcpus=1, disk=1)
        self.cluster_flavor = mex_controller.ClusterFlavor(cluster_flavor_name=flavor_name, node_flavor_name=flavor_name, master_flavor_name=flavor_name, number_nodes=1, max_nodes=1, number_masters=1)
        self.controller = mex_controller.MexController(controller_address = controller_address,
                                                    root_cert = mex_root_cert,
                                                    key = mex_key,
                                                    client_cert = mex_cert
                                                   )
        self.cluster = mex_controller.Cluster(cluster_name=cluster_name,
                                              default_flavor_name=flavor_name)

        self.cluster_instance = mex_controller.ClusterInstance(cluster_name=cluster_name,
                                                             cloudlet_name=cloud_name,
                                                             operator_name=operator_name,
                                                             flavor_name=flavor_name)

        self.controller.create_flavor(self.flavor.flavor)
        self.controller.create_cluster_flavor(self.cluster_flavor.cluster_flavor)
        #self.controller.create_operator(self.operator.operator)
        #self.controller.create_cloudlet(self.cloudlet.cloudlet)

    def test_CreateClusterTwice(self):
        # [Documentation] ClusterInst - User shall not be a to create the same cluster instance twice
        # ... create the same cluster twice
        # ... verify error of 'Key already exists' is retruned

        # print the existing cluster instances
        clusterinst_pre = self.controller.show_cluster_instances()

        # create a new cluster and cluster instance
        create_cluster_resp = self.controller.create_cluster(self.cluster.cluster)
        self.controller.create_cluster_instance(self.cluster_instance.cluster_instance)
        #time.sleep(1)

        # create the cluster instance which already exists
        try:
            resp = self.controller.create_cluster_instance(self.cluster_instance.cluster_instance)
        except:
            print('create cluster instance failed')
        # print the cluster instances after error
        clusterinst_post = self.controller.show_cluster_instances()

        expect_equal(self.controller.response.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(self.controller.response.details(), 'Key already exists', 'error details')
        expect_equal(len(clusterinst_pre)+1, len(clusterinst_post), 'same number of cluster')
        assert_expectations()

    def tearDown(self):
        self.controller.delete_cluster_instance(self.cluster_instance.cluster_instance)
        self.controller.delete_cluster(self.cluster.cluster)
        self.controller.delete_cluster_flavor(self.cluster_flavor.cluster_flavor)
        self.controller.delete_flavor(self.flavor.flavor)
        #self.controller.delete_cloudlet(self.cloudlet.cloudlet)
        #self.controller.delete_operator(self.operator.operator)

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

