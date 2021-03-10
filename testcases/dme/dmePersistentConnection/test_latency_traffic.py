#!/usr/local/bin/python3

import unittest
import grpc
import sys
import time
from delayedassert import expect, expect_equal, assert_expectations
import logging
import os
import statistics

import MexDme as mex_dme

dme_address = os.getenv('AUTOMATION_DME_ADDRESS', '127.0.0.1:55001')

developer_name = 'automation_dev_org'
app_name = 'automation_api_app'
app_version = '1.0'
operator = 'tmus'
cloudlet = 'tmocloud-1'

num_dmes = 1000

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

class tc(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        self.dme_list = []
  
        for x in range(1,num_dmes+1):
            print('creating dme', x)
            dme = mex_dme.MexDme(dme_address = dme_address)
            self.dme_list.append(dme)

# ECQ-3240 
    def test_dmePersistentConnection_latency_multiple(self):
        # [Documentation] DMEPersistentConnection - shall be able to make multiple connections and latency edge events
        # ...  - make multiple persistent connections
        # ...  - send a latency edge event on each connection

        for x in range(1,num_dmes+1):
            print('creating persist connection', x)
            self.register = mex_dme.Client(app_name=app_name, app_version=app_version, developer_org_name=developer_name)
            self.dme_list[x-1].register_client(self.register.client)

            self.find_cloudlet = mex_dme.FindCloudletRequest(carrier_name=operator, latitude=36, longitude=-96)
            self.dme_list[x-1].find_cloudlet(self.find_cloudlet.request)


        for x in range(1,num_dmes+1): 
            self.dme_list[x-1].create_dme_persistent_connection(carrier_name=operator, latitude=36,  longitude=-96)

            samples = [x, 10.4, 4.20, 30, 440, 0.50, 6.00, 70.45]
            average = round(statistics.mean(samples)) 

            stdev = round(statistics.stdev(samples)) 

            variance = round(statistics.variance(samples))
            num_samples =  len(samples)
            min_value = min(samples)
            max_value =  max(samples)
            print('xxxxxx', min_value, max_value)
            latency = self.dme_list[x-1].send_latency_edge_event(carrier_name=operator, latitude=36, longitude=-96, samples=samples)

            latency_avg = round(latency.statistics.avg)
            latency_std_dev = round(latency.statistics.std_dev)
            latency_variance = round(latency.statistics.variance)

            expect_equal(latency_avg, average)
            expect_equal(latency.statistics.min, min_value)
            expect_equal(latency.statistics.max, max_value)
            expect_equal(latency_std_dev, stdev)
            expect_equal(latency_variance, variance)
            expect_equal(latency.statistics.num_samples, num_samples)
            #expect_true(latency.statistics.timestamp.seconds > 0)
            #expect_true(latency.statistics.timestamp.nanos > 0)
            assert_expectations()

    @classmethod
    def tearDownClass(self):
        for x in range(1,num_dmes+1):
            self.dme_list[x-1].terminate_dme_persistent_connection()

        print(f'created {num_dmes} persistent connections')

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

