#!/usr/bin/python3

#
# create a cloudlet and cluster
# create a cluster instance for a cloudlet that does not exist in CloudletInfo
# verify 'No resource information found for Cloudlet' is returned
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

stamp = str(time.time())
cluster_name = 'cluster' + stamp
operator_name = 'operator' + stamp
cloud_name = 'cloudlet' + stamp 
flavor_name = 'c1.small' + stamp

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
      
#        self.operator = mex_controller.Operator(operator_name = operator_name)
        self.flavor = mex_controller.Flavor(flavor_name=flavor_name, ram=1024, vcpus=1, disk=1)
        self.cloudlet = mex_controller.Cloudlet(cloudlet_name = cloud_name,
                                                operator_org_name = operator_name,
                                                crm_override=2,
                                                number_of_dynamic_ips = 254)
        #self.cluster = mex_controller.Cluster(cluster_name=cluster_name,
        #                                      default_flavor_name=flavor_name)
        self.cluster_instance = mex_controller.ClusterInstance(cluster_name=cluster_name,
                                                             cloudlet_name=cloud_name,
                                                             operator_org_name=operator_name,
                                                             flavor_name=flavor_name)
        #self.controller.create_operator(self.operator.operator)
        self.controller.create_flavor(self.flavor.flavor)
 
    def test_CreateClusterInstCloudletNotFound(self):
        # [Documentation] ClusterInst - User shall not be able to create a cluster instance for cloudlet that does not exist
        # ... create a cloudlet and cluster
        # ... create a cluster instance for a cloudlet that does not exist in CloudletInfo
        # ... verify 'No resource information found for Cloudlet' is returned

        # create a cloudlet
        self.controller.create_cloudlet(self.cloudlet.cloudlet)

        # create a new cluster for adding the instance
        #create_cluster_resp = self.controller.create_cluster(self.cluster.cluster)

        # print the existing cluster instances
        clusterinst_pre = self.controller.show_cluster_instances()

        # create the cluster instance
        resp = None
        try:
            resp = self.controller.create_cluster_instance(self.cluster_instance.cluster_instance)
        except:
            print('create cluster instance failed')

        # print the cluster instances after error
        clusterinst_post = self.controller.show_cluster_instances()

        expect_equal(self.controller.response.code(), grpc.StatusCode.UNKNOWN, 'status code')
        #expect_equal(self.controller.response.details(), 'Cloudlet organization:"' + operator_name + '" name:"' + cloud_name + '"  not ready, state is CLOUDLET_STATE_NOT_PRESENT', 'error details')
        #expect_equal(self.controller.response.details(), 'Cloudlet key {"organization":"' + operator_name + '","name":"' + cloud_name + '"} not found', 'error details')
        expect_equal(self.controller.response.details(), 'CloudletInfo not found for Cloudlet {"organization":"' + operator_name + '","name":"' + cloud_name + '"}', 'error details')
        #expect_equal(len(clusterinst_pre), len(clusterinst_post), 'same number of cluster')
        assert_expectations()

    def tearDown(self):
        #self.controller.delete_cluster(self.cluster.cluster)
        self.controller.delete_cloudlet(self.cloudlet.cloudlet)
        self.controller.delete_flavor(self.flavor.flavor)
#        self.controller.delete_operator(self.operator.operator)



if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

