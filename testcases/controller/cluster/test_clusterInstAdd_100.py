#!/usr/bin/python3

#
# create 100 clusters and 100 cluster instances
# verify all cluster instance is created
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
flavor_name = 'c1.small' + str(time.time()) 
mex_root_cert = 'mex-ca.crt'
mex_cert = 'localserver.crt'
mex_key = 'localserver.key'

number_of_clusterInsts = 100 

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

        #self.operator = mex_controller.Operator(operator_name = operator_name)        
        self.flavor = mex_controller.Flavor(flavor_name=flavor_name, ram=1024, vcpus=1, disk=1)
        self.cluster_flavor = mex_controller.ClusterFlavor(cluster_flavor_name=flavor_name, node_flavor_name=flavor_name, master_flavor_name=flavor_name, number_nodes=1, max_nodes=1, number_masters=1)
        self.cluster = mex_controller.Cluster(cluster_name=self.cluster_name,
                                         default_flavor_name=flavor_name)
        self.cloudlet = mex_controller.Cloudlet(cloudlet_name = cloud_name,
                                                operator_name = operator_name,
                                                number_of_dynamic_ips = 254)

        self.cluster_list = []
        self.clusterinst_list = []

        self.stamp = str(time.time())

        #self.controller.create_operator(self.operator.operator)
        self.controller.create_flavor(self.flavor.flavor)
        self.controller.create_cluster_flavor(self.cluster_flavor.cluster_flavor)
        #self.controller.create_cloudlet(self.cloudlet.cloudlet)

        for i in range(number_of_clusterInsts):
            cluster_name = 'cluster' + str(i) + '-' + self.stamp
            self.cluster_list.append(mex_controller.Cluster(cluster_name=cluster_name,
                                                            default_flavor_name=flavor_name))
            self.clusterinst_list.append(mex_controller.ClusterInstance(cluster_name=cluster_name,
                                                                        cloudlet_name=cloud_name,
                                                                        operator_name=operator_name,
                                                                        flavor_name=flavor_name))

    def test_AddClusterInstance(self):
        # [Documentation] ClusterInst - User shall be able to create 100 cluster instances
        # ... create 100 clusters and 100 cluster instances
        # ... verify all cluster instance is created

        # print the existing cluster and cluster instances
        clusters_before = self.controller.show_clusters()
        cluster_instances_before = self.controller.show_cluster_instances()

        # create a new cluster for adding the instance
        for i in self.cluster_list:
            self.controller.create_cluster(i.cluster)

        # create the cluster instance
        for i in self.clusterinst_list:
            self.controller.create_cluster_instance(i.cluster_instance)

        # print the cluster instances after adding 
        #time.sleep(1)
        clusters_after = self.controller.show_clusters()
        cluster_instances_after = self.controller.show_cluster_instances()

        # look for the cluster
        for c in self.clusterinst_list:
            found_cluster = c.exists(cluster_instances_after)
            expect_equal(found_cluster, True, 'find new cluster' + c.cluster_name)
        
        assert_expectations()

    def tearDown(self):
        for c in self.clusterinst_list:
            self.controller.delete_cluster_instance(c.cluster_instance)
        for c in self.cluster_list:
            self.controller.delete_cluster(c.cluster)
        self.controller.delete_cluster_flavor(self.cluster_flavor.cluster_flavor)
        self.controller.delete_flavor(self.flavor.flavor)
        #self.controller.delete_cloudlet(self.cloudlet.cloudlet)
        #self.controller.delete_operator(self.operator.operator)

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

