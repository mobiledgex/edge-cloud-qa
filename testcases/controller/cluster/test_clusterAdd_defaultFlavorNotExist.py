#!/usr/bin/python3

#
# create a cluster with a defaultflavor that does not exist
# verify 'default flavor not found' is returned
#
 
import unittest
import grpc
import sys
import time
from delayedassert import expect, expect_equal, assert_expectations
import logging
import os

from MexController import mex_controller

controller_address = os.getenv('AUTOMATION_CONTROLLER_ADDRESS', '127.0.0.1:55001')

stamp = str(time.time())
cluster_name = 'cluster' + stamp
operator_name = 'operator' + stamp
cloud_name = 'cloudlet' + stamp 
flavor_name = 'c1.small' + stamp

mex_root_cert = 'mex-ca.crt'
mex_cert = 'localserver.crt'
mex_key = 'localserver.key'

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

class tc(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        self.controller = mex_controller.Controller(controller_address = controller_address,
                                                    root_cert = mex_root_cert,
                                                    key = mex_key,
                                                    client_cert = mex_cert
                                                   )
      
        self.operator = mex_controller.Operator(operator_name = operator_name)
        self.flavor = mex_controller.Flavor(flavor_name=flavor_name, ram=1024, vcpus=1, disk=1)
        self.cluster_flavor = mex_controller.ClusterFlavor(cluster_flavor_name=flavor_name, node_flavor_name=flavor_name, master_flavor_name=flavor_name, number_nodes=1, max_nodes=1, number_masters=1)
        self.cloudlet = mex_controller.Cloudlet(cloudlet_name = cloud_name,
                                                operator_name = operator_name,
                                                number_of_dynamic_ips = 254)
        self.cluster = mex_controller.Cluster(cluster_name=cluster_name,
                                              default_flavor_name='dummyflavor')
        self.controller.create_operator(self.operator.operator)
        self.controller.create_flavor(self.flavor.flavor)
        self.controller.create_cluster_flavor(self.cluster_flavor.cluster_flavor)
 
    def test_CreateClusterFlavorNotFound(self):
        # [Documentation] Cluster - User shall not be able to create a cluster with a defaultflavor that does not exist
        # ... create a cluster with defaultflavor that does not exist
        # ... verify 'default flavor not found' is returned

        # create the cluster
        try:
            resp = self.controller.create_cluster(self.cluster.cluster)
        except grpc.RpcError as e:
            logger.info('got exception ' + str(e))
            error = e

        expect_equal(error.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(error.details(), 'default flavor dummyflavor not found', 'error details')
        assert_expectations()

    def tearDown(self):
        self.controller.delete_cluster_flavor(self.cluster_flavor.cluster_flavor)
        self.controller.delete_flavor(self.flavor.flavor)
        self.controller.delete_operator(self.operator.operator)

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

