#!/usr/local/bin/python3

import unittest
import sys
import time
from delayedassert import expect_equal, assert_expectations
import logging
import statistics
import random
# import signal

import MexDme as mex_dme

dme_address = 'us-qa.dme.mobiledgex.net:50051'
# dme_address = 'us-stage.dme.mobiledgex.net:50051'

# app definition
developer_name = 'automation_dev_org'
app_name = 'automation_api_app'
app_version = '1.0'
operator = 'tmus'
cloudlet = 'tmocloud-1'

# developer_name = 'ComputerVisionInc'
# app_name = 'ComputerVision'
# app_version = '1.0'
# operator = ''

num_clients = 500  # number of clients

# random latency values will be generated and sent every x seconds
num_latency_samples = 5   # number of samples to send in latency request
latency_min = 1           # min latency value to send. lower bound of random value
latency_max = 100         # max latency value to send. upper bound of random value
latency_interval = 5     # seconds to wait between sending latency. Every client will send latency then wait x seconds to send them again

# seatle 47/-122
# miami 25/-80
# nyc 40/-74
# san dieao 32/-117
gps_lat_start = 25
gps_lat_end = 47
gps_long_start = -122
gps_long_end = -74

# persistent connection device info
carrier_name = operator
data_network_type = '5G'
device_os = 'Android'
device_model = 'Google Pixel'
signal_strength = '65'

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)


class tc(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        # signal.signal(signal.SIGINT, self.signal_tearDown)

        self.client_list = []

        for x in range(1, num_clients + 1):
            print('creating client', x)
            dme = mex_dme.MexDme(dme_address=dme_address)
            self.client_list.append(dme)

    def test_dmePersistentConnection_latency_multiple(self):
        coord_list = []

        for x in range(1, num_clients + 1):
            lat_random = random.randrange(gps_lat_start, gps_lat_end)
            long_random = random.randrange(gps_long_start, gps_long_end)
            coord_list.append([lat_random, long_random])

            print(f'client {x}/{num_clients}. register/findcloudlet/persistconnection at {lat_random}/{long_random}')

            try:
                self.register = mex_dme.Client(app_name=app_name, app_version=app_version, developer_org_name=developer_name)
                self.client_list[x - 1].register_client(self.register.client)
                self.find_cloudlet = mex_dme.FindCloudletRequest(carrier_name=operator, latitude=lat_random, longitude=long_random)
                self.client_list[x - 1].find_cloudlet(self.find_cloudlet.request)

                self.client_list[x - 1].create_dme_persistent_connection(carrier_name=operator, data_network_type=data_network_type, device_os=device_os, device_model=device_model, signal_strength=signal_strength, latitude=lat_random, longitude=long_random)
            except Exception as e:
                print('register/findcloudlet/persistconnection', x, 'failed:', e)
#        sys.exit(1)
        batch_number = 1
        while True:
            print(f'sending latency batch {batch_number}')
            for x in range(1, num_clients + 1):
                # samples = [x, 10.4, 4.20, 30, 440, 0.50, 6.00, 70.45]
                samples = []
                for latency in range(1, num_latency_samples):
                    latency_random = random.randrange(latency_min, latency_max)
                    samples.append(latency_random)

                average = round(statistics.mean(samples))
                stdev = round(statistics.stdev(samples))
                variance = round(statistics.variance(samples))
                num_samples = len(samples)
                min_value = min(samples)
                max_value = max(samples)

                latency = self.client_list[x - 1].send_latency_edge_event(carrier_name=operator, latitude=coord_list[x - 1][0], longitude=coord_list[x - 1][1], samples=samples)

                latency_avg = round(latency.statistics.avg)
                latency_std_dev = round(latency.statistics.std_dev)
                latency_variance = round(latency.statistics.variance)

                expect_equal(latency_avg, average)
                expect_equal(latency.statistics.min, min_value)
                expect_equal(latency.statistics.max, max_value)
                expect_equal(latency_std_dev, stdev)
                expect_equal(latency_variance, variance)
                expect_equal(latency.statistics.num_samples, num_samples)
                # expect_true(latency.statistics.timestamp.seconds > 0)
                # expect_true(latency.statistics.timestamp.nanos > 0)
                assert_expectations()

            batch_number += 1
            print(f'waiting {latency_interval}s to send next latency')
            time.sleep(latency_interval)

    @classmethod
    def tearDownClass(self):
        for x in range(1, num_clients + 1):
            self.client_list[x - 1].terminate_dme_persistent_connection()

        print(f'created {num_clients} persistent connections')

#    def signal_tearDown(self, signal, frame):
#       self.tearDownClass()
#       # for x in range(1,num_clients+1):
#       #     self.client_list[x-1].terminate_dme_persistent_connection()
#
#       # print(f'created {num_clients} persistent connections')


if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())
