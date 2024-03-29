#!/usr/bin/python3
# Copyright 2022 MobiledgeX, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


#
# create 100 clusters
# verify all are created
#

import unittest
import grpc
import sys
import time
import os
from delayedassert import expect, expect_equal, assert_expectations
import logging

import cluster_pb2
import cluster_pb2_grpc
import clusterflavor_pb2
import clusterflavor_pb2_grpc
import flavor_pb2
import flavor_pb2_grpc

controller_address = os.getenv('AUTOMATION_CONTROLLER_ADDRESS', '127.0.0.1:55001')

number_of_clusters = 100

mex_root_cert = 'mex-ca.crt'
mex_cert = 'localserver.crt'
mex_key = 'localserver.key'

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

class tc(unittest.TestCase):
    def setUp(self):
        #controller_channel = grpc.insecure_channel(controller_address)

        self.mex_root_cert = self._findFile(mex_root_cert)
        self.mex_key = self._findFile(mex_key)
        self.mex_cert = self._findFile(mex_cert)

        with open(self.mex_root_cert, 'rb') as f:
            print('using root_cert =',mex_root_cert)
            #trusted_certs = f.read().encode()
            trusted_certs = f.read()
        with open(self.mex_key,'rb') as f:
            print('using key =',mex_key)
            trusted_key = f.read()
        with open(self.mex_cert, 'rb') as f:
            print('using client cert =', mex_cert)
            cert = f.read()

        credentials = grpc.ssl_channel_credentials(root_certificates=trusted_certs, private_key=trusted_key, certificate_chain=cert)
        controller_channel = grpc.secure_channel(controller_address, credentials)

        self.cluster_stub = cluster_pb2_grpc.ClusterApiStub(controller_channel)
        self.flavor_stub = flavor_pb2_grpc.FlavorApiStub(controller_channel)

        self.stamp = str(time.time())
        self.flavor_name = 'flavor' + self.stamp

        self.flavor = flavor_pb2.Flavor(key=flavor_pb2.FlavorKey(name = self.flavor_name),
                                        ram=1024,
                                        vcpus=1,
                                        disk=1)
        self.flavor_stub.CreateFlavor(self.flavor)

        self.cluster_list = []
        for i in range(number_of_clusters):
            cluster_name = 'cluster' + str(i) + '-' + self.stamp
            self.cluster_list.append(cluster_pb2.Cluster(
                                                         key = cluster_pb2.ClusterKey(name = cluster_name),
                                                         default_flavor = flavor_pb2.FlavorKey(name = self.flavor_name)
                                                        ))

    def test_AddMultpleClusters(self):
        # [Documentation] Cluster - User shall be able to create 100 clusters
        # ... create 100 clusters
        # ... verify all are created
 
        show_cluster_resp_pre = self.cluster_stub.ShowCluster(cluster_pb2.Cluster())
        number_of_clusters_before = 0
        for c in show_cluster_resp_pre:
            print('clusterBeforeAdd=', c)
            number_of_clusters_before += 1

        for i in self.cluster_list:
            print('adding cluster', i.key.name)
            create_cluster_resp = self.cluster_stub.CreateCluster(i)

        show_cluster_resp = list(self.cluster_stub.ShowCluster(cluster_pb2.Cluster()))
        #print('sc1', len(show_cluster_resp))
        #for c in show_cluster_resp:
        #    print('s', c.key.name)
        #    pass
        #print('sc2', show_cluster_resp)
#
#        for c in show_cluster_resp:
#            print('s2', c.key.name)
#            pass
#        print('sc3', show_cluster_resp)


        found_cluster = False
        number_of_clusters_after = 0
        #for c in show_cluster_resp:
        for i in self.cluster_list:
            print('checking for cluster=' + i.key.name)
            #print('clusterAfterAdd=', c)
            number_of_clusters_after += 1
            #for i in self.cluster_list:
            for c in show_cluster_resp:
                #print('checking against:' + c.key.name, i.key.name)
                if c.key.name == i.key.name and c.default_flavor.name == i.default_flavor.name:
                    found_cluster = True
                    print('foundkey') 
                    break 
                else:
                    found_cluster = False
            if not found_cluster:
                print('ERROR: did not find:' + i.key.name)
                break

        expect_equal(found_cluster, True, 'found new cluster')
        #expect_equal(number_of_clusters_after, number_of_clusters_before + number_of_clusters, 'number of clusters')
        assert_expectations()

    def _findFile(self, path):
        for dirname in sys.path:
            candidate = os.path.join(dirname, path)
            if os.path.isfile(candidate):
                return candidate
        raise Error('cant find file {}'.format(path))

    def tearDown(self):
        for i in self.cluster_list:
            delete_cluster_resp = self.cluster_stub.DeleteCluster(i)

        self.flavor_stub.DeleteFlavor(self.flavor)

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

