#!/usr/bin/python3

#
# delte cluster instance before deleting the app instance that is using it
# verify 'ClusterInst in use by Application Instance' is received
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
developer_name = 'developer' + stamp
developer_address = 'allen tx'
developer_email = 'dev@dev.com'
flavor = 'x1.small'
cluster_name = 'cluster' + stamp
app_name = 'app' + stamp
app_version = '1.0'
cloud_name = 'tmocloud-1'
operator_name = 'dmuus'
flavor_name = 'c1.small' + stamp
access_ports = 'tcp:1'

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

        #self.operator = mex_controller.Operator(operator_name = operator_name)        
        self.cloudlet = mex_controller.Cloudlet(cloudlet_name = cloud_name,
                                                operator_org_name = operator_name,
                                                number_of_dynamic_ips = 254)
        self.flavor = mex_controller.Flavor(flavor_name=flavor_name, ram=1024, vcpus=1, disk=1)
#        self.developer = mex_controller.Developer(developer_name=developer_name)#,
#                                                  #developer_address=developer_address,
#                                                  #developer_email=developer_email)
        #self.cluster = mex_controller.Cluster(cluster_name=cluster_name,
        #                                      default_flavor_name=flavor_name)
        self.app = mex_controller.App(image_type='ImageTypeDocker',
                                      app_name=app_name,
                                      app_version=app_version,
                                      ip_access='IpAccessDedicatedOrShared',
                                      access_ports=access_ports,
                                      cluster_name=cluster_name,
                                      developer_org_name=developer_name,
                                      default_flavor_name=flavor_name)

#        self.controller.create_developer(self.developer.developer) 
        self.controller.create_flavor(self.flavor.flavor)
        #self.controller.create_operator(self.operator.operator)
        #self.controller.create_cloudlet(self.cloudlet.cloudlet)

        # create the cluster
        #self.controller.create_cluster(self.cluster.cluster)

        # create the app
        resp = self.controller.create_app(self.app.app)

    def test_DeleteClusterBeforeApp(self):
        # [Documentation] ClusterInst - User shall not be able to delete a cluster instance before the app
        # ... delete cluster instance before deleting the app instance that is using it
        # ... verify 'ClusterInst in use by Application Instance' is received

        # print the existing cluster instances
        cluster_pre = self.controller.show_cluster_instances()
        

        # create cluster instance
        self.cluster_instance = mex_controller.ClusterInstance(cluster_name=cluster_name,
                                                               cloudlet_name=cloud_name,
                                                               operator_org_name=operator_name,
                                                               flavor_name=flavor_name)
        self.controller.create_cluster_instance(self.cluster_instance.cluster_instance)

        # create the app instance
        self.app_instance = mex_controller.AppInstance(cloudlet_name=cloud_name,
                                                       app_name=app_name,
                                                       app_version=app_version,
                                                       cluster_instance_name=cluster_name, 
                                                       operator_org_name=operator_name)
        resp = self.controller.create_app_instance(self.app_instance.app_instance)
        
        # attempt to delete the cluster instance
        try:
            self.controller.delete_cluster_instance(self.cluster_instance.cluster_instance)
        except grpc.RpcError as e:
            print('error', type(e.code()), e.details())
            expect_equal(e.code(), grpc.StatusCode.UNKNOWN, 'status code')
            #expect_equal(e.details(), 'ClusterInst in use by Application Instance', 'error details')
            expect_equal(e.details(), 'ClusterInst in use by AppInst {"app_key":{"organization":"' + developer_name + '","name":"' + app_name + '","version":"' + app_version + '"},"cluster_inst_key":{"cluster_key":{"name":"' + cluster_name + '"},"cloudlet_key":{"organization":"' + operator_name + '","name":"' + cloud_name + '"},"organization":"' + developer_name +'"}}', 'error details')
        else:
            print('cluster deleted')

        
        # print the cluster instances after error
        cluster_post = self.controller.show_cluster_instances()

        # find cluster in list
        found_cluster = self.cluster_instance.exists(cluster_post)

        expect_equal(found_cluster, True, 'find cluster instance')
        assert_expectations()

    def tearDown(self):
        try: self.controller.delete_app_instance(self.app_instance.app_instance)
        except: print('delete_app_instance failed')
        #time.sleep(1) # wait till app instance is actually deleted else delete app will fail
        try: self.controller.delete_app(self.app.app)
        except: print('delete_app failed')
        try: self.controller.delete_cluster_instance(self.cluster_instance.cluster_instance)
        except: print('delete_cluster_instance failed')
        #self.controller.delete_cluster(self.cluster.cluster)
#        try: self.controller.delete_developer(self.developer.developer)
#        except: print('delete_developer failed')
        try: self.controller.delete_flavor(self.flavor.flavor)
        except: print('delete_flavor failed')
        #self.controller.delete_cloudlet(self.cloudlet.cloudlet)
        #self.controller.delete_operator(self.operator.operator)

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

