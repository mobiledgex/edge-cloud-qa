#!/usr/local/bin/python3

import unittest
import grpc
import sys
import time
from delayedassert import expect, expect_equal, assert_expectations
import logging
import os
import statistics
import threading

import MexDme as mex_dme

dme_address = os.getenv('AUTOMATION_DME_ADDRESS', '127.0.0.1:55001')

developer_name = 'automation_dev_org'
app_name = 'automation_api_app'
app_version = '1.0'
operator = 'tmus'
cloudlet = 'tmocloud-1'

num_dmes = 1
num_requests = 1
num_threads = 1200
starttime = -1

logger = logging.getLogger()
logger.setLevel(logging.INFO)

class tc(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        self.dme_list = []
  
        for x in range(1,num_dmes+1):
            print('creating dme', x)
            dme = mex_dme.MexDme(dme_address = dme_address)
            self.dme_list.append(dme)

    def test_registerclient_multiple(self):
        # [Documentation] DMEPersistentConnection - shall be able to make multiple connections and latency edge events
        # ...  - make multiple persistent connections
        # ...  - send a latency edge event on each connection

        #global starttime
        #starttime  = -1
        def send_message():
            for x in range(1,num_dmes+1):

                #starttime = time.time()
                for r in range(1,num_requests+1):
                    print('sending register client', r)
                    self.register = mex_dme.Client(app_name=app_name, app_version=app_version, developer_org_name=developer_name)
                    self.dme_list[x-1].register_client(self.register.client)

                    #self.find_cloudlet = mex_dme.FindCloudletRequest(carrier_name=operator, latitude=36, longitude=-96)
                    #self.dme_list[x-1].find_cloudlet(self.find_cloudlet.request)

        t_list = []
        starttime = time.time()
        for z in range(num_threads+1):
           t = threading.Thread(target=send_message)
           t.start()
           t_list.append(t)

        for z in t_list:
           z.join()

        endtime = time.time()
        print('numrequests', num_requests, 'start', starttime, 'end', endtime, 'diff', endtime-starttime)

    def test_verifylocation_multiple(self):
        # [Documentation] DMEPersistentConnection - shall be able to make multiple connections and latency edge events
        # ...  - make multiple persistent connections
        # ...  - send a latency edge event on each connection

        self.register = mex_dme.Client(app_name=app_name, app_version=app_version, developer_org_name=developer_name)
        self.dme_list[0].register_client(self.register.client)
        self.find_cloudlet = mex_dme.FindCloudletRequest(carrier_name=operator, latitude=36, longitude=-96)
        self.dme_list[0].find_cloudlet(self.find_cloudlet.request)

        def send_message():
            for x in range(1,num_dmes+1):

                #starttime = time.time()
                for r in range(1,num_requests+1):
                    self.verify_location = mex_dme.VerifyLocation(carrier_name=operator, latitude=36, longitude=-96)
                    self.dme_list[x-1].verify_location(self.verify_location.request)

        t_list = []
        starttime = time.time()
        for z in range(num_threads+1):
           t = threading.Thread(target=send_message)
           t.start()
           t_list.append(t)

        for z in t_list:
           z.join()

        endtime = time.time()
        print('numrequests', num_requests, 'start', starttime, 'end', endtime, 'diff', endtime-starttime)

    def test_dmePersistentConnection_multiple(self):
        # [Documentation] DMEPersistentConnection - shall be able to make multiple connections and latency edge events
        # ...  - make multiple persistent connections
        # ...  - send a latency edge event on each connection

        self.register = mex_dme.Client(app_name=app_name, app_version=app_version, developer_org_name=developer_name)
        self.dme_list[0].register_client(self.register.client)
        self.find_cloudlet = mex_dme.FindCloudletRequest(carrier_name=operator, latitude=36, longitude=-96)
        self.dme_list[0].find_cloudlet(self.find_cloudlet.request)
        self.dme_list[0].create_dme_persistent_connection(carrier_name=operator, latitude=36,  longitude=-96)

        samples = [10,7,1]
        #starttime = time.time()

        #for a in range(num_requests+1):
        #    self.dme_list[0].send_latency_edge_event(latitude=36, longitude=-96, samples=samples)

        samples = [10,7,1] 
        def send_message():
            for x in range(1,num_dmes+1):
            
                #starttime = time.time()
                for r in range(1,num_requests+1):
                    print('creating dme persist connnection', r)
                    self.dme_list[x-1].send_latency_edge_event(latitude=36, longitude=-96, samples=samples)

        t_list = []
        starttime = time.time()
        for z in range(num_threads+1):
           t = threading.Thread(target=send_message, daemon=True)
           t.start()
           t_list.append(t)

        for z in t_list:
           z.join()

        time.sleep(10)
        endtime = time.time()
        print('numrequests', num_requests, 'start', starttime, 'end', endtime, 'diff', endtime-starttime)

    @classmethod
    def tearDownClass(self):
        for x in range(1,num_dmes+1):
            for r in range(1,num_requests+1):
                print('terminate dme persist conn')
                self.dme_list[x-1].terminate_dme_persistent_connection()

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

