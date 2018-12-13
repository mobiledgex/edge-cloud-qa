#!/usr/bin/python3

#
# create a cluster instance without a flavor name.
# verify the default flavor name from the cluster is added to the cluster instance when it is created
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
operator_name = 'dmuus'
cloud_name = 'tmocloud-1'
flavor_name = 'c1.tiny' + stamp
cluster_name = 'cluster' + stamp

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
        self.flavor = mex_controller.Flavor(flavor_name=flavor_name, ram=1024, vcpus=1, disk=1)
        self.cluster_flavor = mex_controller.ClusterFlavor(cluster_flavor_name=flavor_name, node_flavor_name=flavor_name, master_flavor_name=flavor_name, number_nodes=1, max_nodes=1, number_masters=1)
        self.cluster = mex_controller.Cluster(cluster_name=cluster_name,
                                         default_flavor_name=flavor_name)
        # flavor_name  does not exist
        self.cluster_instance_noFlavor = mex_controller.ClusterInstance(cluster_name=cluster_name,
                                                                        cloudlet_name=cloud_name,
                                                                        operator_name=operator_name,
                                                                        use_defaults=False
                                                                       )
        # flavor_name is empty
        self.cluster_instance_emptyFlavor = mex_controller.ClusterInstance(cluster_name=cluster_name,
                                                                           cloudlet_name=cloud_name,
                                                                           flavor_name='',
                                                                           operator_name=operator_name
                                                                          )

        # create a new cluster for adding the instance
        self.controller.create_flavor(self.flavor.flavor)
        self.controller.create_cluster_flavor(self.cluster_flavor.cluster_flavor)
        create_cluster_resp = self.controller.create_cluster(self.cluster.cluster)

    def test_NoFlavor(self):
        # [Documentation] ClusterInst - User shall be able to create a cluster instance with no flavor name
        # ... create a cluster instance without a flavor name.
        # ... verify the default flavor name from the cluster is added to the cluster instance when it is created

        # print the existing cluster instances
        self.controller.show_cluster_instances()

        # create the cluster instance withour the flavor_name
        self.controller.create_cluster_instance(self.cluster_instance_noFlavor.cluster_instance)

        # print the cluster instances after adding 
        #time.sleep(1)
        clusterinst_resp = self.controller.show_cluster_instances()

        # delete cluster instance
        self.controller.delete_cluster_instance(self.cluster_instance_noFlavor.cluster_instance)

        # verify ci.tiny is picked up from the default_flavor_name
        clusterinst_temp = self.cluster_instance_noFlavor
        clusterinst_temp.flavor_name = flavor_name
        found_cluster = clusterinst_temp.exists(clusterinst_resp)

        expect_equal(found_cluster, True, 'no flavor found new cluster')
        assert_expectations()

    def test_EmptyFlavor(self):
        # [Documentation] ClusterInst - User shall be able to create a cluster instance with empty flavor name
        # ... create a cluster instance with empty flavor name.
        # ... verify the default flavor name from the cluster is added to the cluster instance when it is created

        # print the existing cluster instances
        self.controller.show_cluster_instances()

        # create the cluster instance with flavor_name empty
        self.controller.create_cluster_instance(self.cluster_instance_emptyFlavor.cluster_instance)

        # print the cluster instances after adding
        #time.sleep(1)
        clusterinst_resp = self.controller.show_cluster_instances()

        # delete cluster instance
        self.controller.delete_cluster_instance(self.cluster_instance_emptyFlavor.cluster_instance)

        # verify ci.tiny is picked up from the default_flavor_name
        clusterinst_temp = self.cluster_instance_emptyFlavor
        clusterinst_temp.flavor_name = flavor_name
        found_cluster = clusterinst_temp.exists(clusterinst_resp)

        expect_equal(found_cluster, True, 'empty flavor found new cluster')
        assert_expectations()

    @classmethod
    def tearDownClass(self):
        # delete cluster instance
        self.controller.delete_cluster(self.cluster.cluster)
        self.controller.delete_cluster_flavor(self.cluster_flavor.cluster_flavor)
        self.controller.delete_flavor(self.flavor.flavor)

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

