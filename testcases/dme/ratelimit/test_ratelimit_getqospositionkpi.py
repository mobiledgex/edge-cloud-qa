#!/usr/local/bin/python3

import unittest
import sys
import time
from delayedassert import expect, expect_equal, assert_expectations
import logging
import os
# import threading
from tornado import ioloop, httpclient
import json

import MexDmeRest as mex_dme
import MexMasterController as mex_master

dme_address = os.getenv('AUTOMATION_DME_REST_ADDRESS', '127.0.0.1:55001')
mc_address = os.getenv('AUTOMATION_MC_ADDRESS', '127.0.0.1:55001')

developer_name = 'platos'
app_name = 'platosEnablingLayer'
app_version = '1.0'
operator = 'dmuus'

num_requests = 1
num_threads = 500  # 500
starttime = -1

logger = logging.getLogger()
logger.setLevel(logging.INFO)

fail_list = []

counted_threads = 0


class tc_getqospositionkpi_ratelimit(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        self.dme = mex_dme.MexDmeRest(dme_address=dme_address)

        self. rate_diff_percent = 15

        self.mc = mex_master.MexMasterController(mc_address=mc_address)
        self.flow_name_token = self.mc.get_default_rate_limiting_flow_name() + 'token'

        # register = mex_dme.Client(app_name=app_name, app_version=app_version, developer_org_name=developer_name)
        # self.register_result = self.dme.register_client(register.client)
        self.register_result = self.dme.register_client(app_name=app_name, app_version=app_version, developer_org_name=developer_name)

    def calculate_rate_percent(self, requests_per_second):
        rate_minus_percent = (requests_per_second - (requests_per_second * self.rate_diff_percent / 100))
        rate_plus_percent = (requests_per_second + (requests_per_second * self.rate_diff_percent / 100))

        return rate_minus_percent, rate_plus_percent

    def set_leakybucket_flow(self, requests_per_second, target):
        print('setting leakybucket flow')
        self.mc.create_rate_limit_flow(region='US', api_name='RegisterClient', api_endpoint_type='Dme', rate_limit_target=target, flow_algorithm='LeakyBucketAlgorithm', requests_per_second=requests_per_second / 2)
        self.mc.create_rate_limit_flow(region='US', api_name='FindCloudlet', api_endpoint_type='Dme', rate_limit_target=target, flow_algorithm='LeakyBucketAlgorithm', requests_per_second=requests_per_second * 3)
        self.mc.create_rate_limit_flow(region='US', api_name='VerifyLocation', api_endpoint_type='Dme', rate_limit_target=target, flow_algorithm='LeakyBucketAlgorithm', requests_per_second=requests_per_second * 2)
        self.mc.create_rate_limit_flow(region='US', api_name='GetAppInstList', api_endpoint_type='Dme', rate_limit_target=target, flow_algorithm='LeakyBucketAlgorithm', requests_per_second=requests_per_second * 4)
        self.mc.create_rate_limit_flow(region='US', api_name='GetFqdnList', api_endpoint_type='Dme', rate_limit_target=target, flow_algorithm='LeakyBucketAlgorithm', requests_per_second=requests_per_second / 3)
        self.mc.create_rate_limit_flow(region='US', api_name='GetQosPositionKpi', api_endpoint_type='Dme', rate_limit_target=target, flow_algorithm='LeakyBucketAlgorithm', requests_per_second=requests_per_second)

        return self.calculate_rate_percent(requests_per_second)

    def set_tokenbucket_flow(self, requests_per_second, target):
        print('setting tokenbucket flow')
        self.mc.create_rate_limit_flow(region='US', flow_settings_name=self.flow_name_token, api_name='RegisterClient', api_endpoint_type='Dme', rate_limit_target=target, flow_algorithm='TokenBucketAlgorithm', requests_per_second=requests_per_second / 2, burst_size=2)
        self.mc.create_rate_limit_flow(region='US', flow_settings_name=self.flow_name_token, api_name='FindCloudlet', api_endpoint_type='Dme', rate_limit_target=target, flow_algorithm='TokenBucketAlgorithm', requests_per_second=requests_per_second * 3, burst_size=2)
        self.mc.create_rate_limit_flow(region='US', flow_settings_name=self.flow_name_token, api_name='VerifyLocation', api_endpoint_type='Dme', rate_limit_target=target, flow_algorithm='TokenBucketAlgorithm', requests_per_second=requests_per_second * 2, burst_size=2)
        self.mc.create_rate_limit_flow(region='US', flow_settings_name=self.flow_name_token, api_name='GetAppInstList', api_endpoint_type='Dme', rate_limit_target=target, flow_algorithm='TokenBucketAlgorithm', requests_per_second=requests_per_second * 4, burst_size=2)
        self.mc.create_rate_limit_flow(region='US', flow_settings_name=self.flow_name_token, api_name='GetFqdnList', api_endpoint_type='Dme', rate_limit_target=target, flow_algorithm='TokenBucketAlgorithm', requests_per_second=requests_per_second / 3, burst_size=2)
        self.mc.create_rate_limit_flow(region='US', flow_settings_name=self.flow_name_token, api_name='GetQosPositionKpi', api_endpoint_type='Dme', rate_limit_target=target, flow_algorithm='TokenBucketAlgorithm', requests_per_second=requests_per_second, burst_size=15)

    def set_maxreqs(self, max_requests, interval, target):
        print('setting maxreqs')
        self.mc.create_rate_limit_max_requests(region='US', api_name='GetQosPositionKpi', api_endpoint_type='Dme', rate_limit_target=target, max_requests_algorithm='FixedWindowAlgorithm', max_requests=max_requests, interval=interval)

# this is used for the GRPC version which doesnt work
#    def send_getqospositionkpi(self, rate=None):
#        def send_message():
#            global fail_list
#
#            self.getqospositionkpi = mex_dme.GetQosPositionKpi()
#            print('RRRRR', self.getqospositionkpi, self.getqospositionkpi.request)
#            for r in range(1, num_requests + 1):
#                try:
#                    result = self.dme.get_qos_position_kpi(self.getqospositionkpi.request)
#                    self.success_count += 1
#                    print('PASS', time.time(), result)
#                except Exception as e:
#                    self.fail_count += 1
#                    fail_list.append(str(e))
#                    print('FAIL', time.time(), e)
#
#        t_list = []
#
#        if rate:
#            print('message rate', rate, 'sleep', 1 / rate)
#        for z in range(num_threads):
#            t = threading.Thread(target=send_message)
#            t.start()
#            t_list.append(t)
#            if rate:
#                time.sleep(1 / rate)
#        for z in t_list:
#            z.join()

#    async def fetch_url(self, client, body):
#        resp = client.fetch('https://us-qa.dme.mobiledgex.net:38001/v1/getqospositionkpi', body=body, headers=headers, method='POST', connect_timeout=240, request_timeout=240)
#        print('QQQQQQQ', resp)

    def send_getqospositionkpi(self, rate=None):
        global counted_threads
        # i = 0

        def handle_request(response):
            global counted_threads
            global starttime
            global fail_list
            if counted_threads == num_threads:
                starttime = time.time()
            print('XXXXXXtornado resp', response)
            if 'error' in str(response):
                self.fail_count += 1
                fail_list.append(response.decode('utf-8'))
                print('FAIL', time.time(), response)
            else:
                self.success_count += 1
            counted_threads -= 1
            print('count def', counted_threads)
            if counted_threads == 0:
                ioloop.IOLoop.instance().stop()
        http_client = httpclient.AsyncHTTPClient(max_clients=num_threads)
        headers = {'Content-type': 'application/json', 'accept': 'application/json'}
        body = f'{{"session_cookie": "{self.dme.session_cookie()}"}}'

#        responses = await multi ([http_client.fetch('https://us-qa.dme.mobiledgex.net:38001/v1/getqospositionkpi', body=body, headers=headers, method='POST', connect_timeout=240, request_timeout=240) for z in range(num_threads)])

        for z in range(num_threads):
            counted_threads += 1
            headers = {'Content-type': 'application/json', 'accept': 'application/json'}
            body = f'{{"session_cookie": "{self.dme.session_cookie()}"}}'
            # print('hh', headers, body)
            try:
                print(f'sending request {z} of {num_threads} {body}')
                http_client.fetch('https://us-qa.dme.mobiledgex.net:38001/v1/getqospositionkpi', streaming_callback=handle_request, body=body, headers=headers, method='POST', connect_timeout=240, request_timeout=240)
                # self.fetch_url(http_client, body)
                if rate:
                    time.sleep(1 / rate)

            except Exception as e:
                print('ERRORRRR', e)
                self.fail_count += 1
                counted_threads -= 1
                print('count try', counted_threads)
                if counted_threads == 0:
                    ioloop.IOLoop.instance().stop()

        ioloop.IOLoop.instance().start()

    def getqospositionkpi_leakybucket(self, target):
        global starttime
        self.fail_count = 0
        self.success_count = 0

        rate_minus_percent, rate_plus_percent = self.set_leakybucket_flow(requests_per_second=100, target=target)
        # rate_minus_percent, rate_plus_percent = [0, 0]

        # starttime = time.time()
        self.send_getqospositionkpi()
        endtime = time.time()
        req_rate = (num_requests * num_threads) / (endtime - starttime)

        print('numrequests', num_requests, 'numthreads', num_threads, 'start', starttime, 'end', endtime, 'diff', endtime - starttime, 'successcount', self.success_count, 'failcount', self.fail_count, 'rate', req_rate, 'reqs/s', 'rate_minus_percent', rate_minus_percent, 'rate_plus_percent', rate_plus_percent)

        expect_equal(self.success_count, num_requests * num_threads, 'number of successes')
        expect_equal(self.fail_count, 0, 'number of failures')

        # expect((req_rate < rate_plus_percent) and (req_rate > rate_minus_percent), 'error details')
        assert_expectations()

    def getqospositionkpi_tokenbucket_belowrate(self, target):
        self.fail_count = 0
        self.success_count = 0

        self.set_tokenbucket_flow(requests_per_second=70, target=target)

        starttime = time.time()
        self.send_getqospositionkpi(rate=50)
        endtime = time.time()
        req_rate = (num_requests * num_threads) / (endtime - starttime)
        print('numrequests', num_requests, 'numthreads', num_threads, 'start', starttime, 'end', endtime, 'diff', endtime - starttime, 'successcount', self.success_count, 'failcount', self.fail_count, 'rate', req_rate, 'reqs/s')

        expect_equal(self.success_count, num_requests * num_threads, 'number of successes')
        expect_equal(self.fail_count, 0, 'number of failures')
        assert_expectations()

    def getqospositionkpi_tokenbucket_aboverate(self, target):
        # EDGECLOUD-5502 rate limit error from DME has incorrect punctuation

        self.fail_count = 0
        self.success_count = 0

        self.set_tokenbucket_flow(requests_per_second=70.25, target=target)

        starttime = time.time()
        self.send_getqospositionkpi(rate=100)
        endtime = time.time()
        req_rate = (num_requests * num_threads) / (endtime - starttime)
        print('numrequests', num_requests, 'numthreads', num_threads, 'start', starttime, 'end', endtime, 'diff', endtime - starttime, 'successcount', self.success_count, 'failcount', self.fail_count, 'rate', req_rate, 'reqs/s')

        expect(self.success_count < num_requests * num_threads, 'number of successes')
        expect(self.fail_count > 0, 'number of failures')

        for f in fail_list:
            correct_error = False
            r = json.loads(f)
            print('KKKKKK', r, type(r), r['error']['grpc_code'])
            if r['error']['grpc_code'] == 8 and r['error']['http_code'] == 429:  # RESOURCE_EXHAUSTED and Too Many Requests
                if target == 'PerIp':
                    if r['error']['message'] == "Request for /distributed_match_engine.MatchEngineApi/GetQosPositionKpi rate limited, please retry later. error is client exceeded api rate limit per ip. Exceeded rate of 70.25 requests per second.":
                        correct_error = True
                elif target == 'AllRequests':
                    if r['error']['message'] == "Request for /distributed_match_engine.MatchEngineApi/GetQosPositionKpi rate limited, please retry later. error is Exceeded rate of 70.25 requests per second.":
                        correct_error = True
            expect(correct_error == True, 'status code fail. got ' + f)
        assert_expectations()

    def getqospositionkpi_maxreqs(self, target):
        self.fail_count = 0
        self.success_count = 0

        self.set_maxreqs(max_requests=50, interval='10s', target=target)

        starttime = time.time()
        self.send_getqospositionkpi(rate=40)
        endtime = time.time()
        req_rate = (num_requests * num_threads) / (endtime - starttime)
        print('numrequests', num_requests, 'numthreads', num_threads, 'start', starttime, 'end', endtime, 'diff', endtime - starttime, 'successcount', self.success_count, 'failcount', self.fail_count, 'rate', req_rate, 'reqs/s')

        expect(self.success_count > 100, 'number of successes')
        expect(self.fail_count < 400, 'number of failures')
        for f in fail_list:
            correct_error = False
            r = json.loads(f)
            if r['error']['grpc_code'] == 8 and r['error']['http_code'] == 429:  # RESOURCE_EXHAUSTED and Too Many Requests
                if target == 'PerIp':
                    if 'Request for /distributed_match_engine.MatchEngineApi/GetQosPositionKpi rate limited, please retry later. error is client exceeded api rate limit per ip. exceeded limit of 50, retry again in ' in r['error']['message']:
                        correct_error = True
                elif target == 'AllRequests':
                    if 'Request for /distributed_match_engine.MatchEngineApi/GetQosPositionKpi rate limited, please retry later. error is exceeded limit of 50, retry again in ' in r['error']['message']:
                        correct_error = True

            expect(correct_error == True, 'status code fail. got ' + f)

        assert_expectations()

    def getqospositionkpi_leakybucket_maxreqs(self, target):
        self.fail_count = 0
        self.success_count = 0

        self.set_leakybucket_flow(requests_per_second=8, target=target)
        self.set_maxreqs(max_requests=100, interval='1m', target=target)

        starttime = time.time()
        self.send_getqospositionkpi(rate=40)
        endtime = time.time()
        req_rate = (num_requests * num_threads) / (endtime - starttime)
        print('numrequests', num_requests, 'numthreads', num_threads, 'start', starttime, 'end', endtime, 'diff', endtime - starttime, 'successcount', self.success_count, 'failcount', self.fail_count, 'rate', req_rate, 'reqs/s')

        expect(self.success_count > 100, 'number of successes')
        expect(self.fail_count < 400, 'number of failures')
        expect(endtime - starttime > 60, 'time diff')
        for f in fail_list:
            correct_error = False
            r = json.loads(f)
            if r['error']['grpc_code'] == 8 and r['error']['http_code'] == 429:  # RESOURCE_EXHAUSTED and Too Many Requests
                if target == 'PerIp':
                    if 'Request for /distributed_match_engine.MatchEngineApi/GetQosPositionKpi rate limited, please retry later. error is client exceeded api rate limit per ip. exceeded limit of 100, retry again in ' in r['error']['message']:
                        correct_error = True
                elif target == 'AllRequests':
                    if 'Request for /distributed_match_engine.MatchEngineApi/GetQosPositionKpi rate limited, please retry later. error is exceeded limit of 100, retry again in ' in r['error']['message']:
                        correct_error = True

            expect(correct_error == True, 'status code fail. got ' + f)

        assert_expectations()

    def getqospositionkpi_tokenbucket_maxreqs(self, target):
        self.fail_count = 0
        self.success_count = 0

        self.set_tokenbucket_flow(requests_per_second=80, target=target)
        self.set_maxreqs(max_requests=100, interval='1m', target=target)

        starttime = time.time()
        self.send_getqospositionkpi(rate=8)
        endtime = time.time()
        req_rate = (num_requests * num_threads) / (endtime - starttime)
        print('numrequests', num_requests, 'numthreads', num_threads, 'start', starttime, 'end', endtime, 'diff', endtime - starttime, 'successcount', self.success_count, 'failcount', self.fail_count, 'rate', req_rate, 'reqs/s')

        expect(self.success_count > 100, 'number of successes')
        expect(self.fail_count < 400, 'number of failures')
        expect(endtime - starttime > 60, 'time diff')
        for f in fail_list:
            correct_error = False
            r = json.loads(f)
            if r['error']['grpc_code'] == 8 and r['error']['http_code'] == 429:  # RESOURCE_EXHAUSTED and Too Many Requests
                if target == 'PerIp':
                    if 'Request for /distributed_match_engine.MatchEngineApi/GetQosPositionKpi rate limited, please retry later. error is client exceeded api rate limit per ip. exceeded limit of 100, retry again in ' in r['error']['message']:
                        correct_error = True
                elif target == 'AllRequests':
                    if 'Request for /distributed_match_engine.MatchEngineApi/GetQosPositionKpi rate limited, please retry later. error is exceeded limit of 100, retry again in ' in r['error']['message']:
                        correct_error = True
            expect(correct_error == True, 'status code fail. got ' + f)

        assert_expectations()

    # ECQ-3877
    def test_getqospositionkpi_leakybucket_perip(self):
        # [Documentation] RateLimiting - DME shall ratelimit GetQosPositionKpi with LeakyBucket PerIp
        # ...  - configure ratelimit GetQosPositionKpi with LeakyBucket PerIp
        # ...  - send high rate of GetQosPositionKpi messages and verify they are processaed at configured rate

        self.getqospositionkpi_leakybucket('PerIp')

    # ECQ-3878
    def test_getqospositionkpi_leakybucket_allrequests(self):
        # [Documentation] RateLimiting - DME shall ratelimit GetQosPositionKpi with LeakyBucket AllRequests
        # ...  - configure ratelimit GetQosPositionKpi with LeakyBucket AllRequests
        # ...  - send high rate of GetQosPositionKpi messages and verify they are processed at configured rate

        self.getqospositionkpi_leakybucket('AllRequests')

#   removed these tests since I dont real control on the rate of the connections
#    def test_getqospositionkpi_tokenbucket_belowrate_perip(self):
#        # [Documentation] RateLimiting - DME shall not ratelimit GetFqdnList with TokenBucket PerIp
#        # ...  - configure ratelimit GetFqdnList with TokenBucket PerIp
#        # ...  - send rate of GetFqdnList messages below the configured rate and verify they are all processed
#
#        self.getqospositionkpi_tokenbucket_belowrate('PerIp')
#
#    def test_getqospositionkpi_tokenbucket_belowrate_allrequests(self):
#        # [Documentation] RateLimiting - DME shall not ratelimit GetFqdnList with TokenBucket AllRequests
#        # ...  - configure ratelimit GetFqdnList with TokenBucket AllRequests
#        # ...  - send rate of GetFqdnList messages below the configured rate and verify they are all processed
#
#        self.getqospositionkpi_tokenbucket_belowrate('AllRequests')

    # ECQ-3880
    def test_getqospositionkpi_tokenbucket_aboverate_perip(self):
        # [Documentation] RateLimiting - DME shall ratelimit GetQosPositionKpi with TokenBucket PerIp
        # ...  - configure ratelimit GetQosPositionKpi with TokenBucket PerIp
        # ...  - send rate of GetQosPositionKpi messages above the configured rate and verify they fail with the correct error

        self.getqospositionkpi_tokenbucket_aboverate('PerIp')

    # ECQ-3881
    def test_getqospositionkpi_tokenbucket_aboverate_allrequests(self):
        # [Documentation] RateLimiting - DME shall ratelimit GetQosPositionKpi with TokenBucket AllRequests
        # ...  - configure ratelimit GetQosPositionKpi with TokenBucket AllRequests
        # ...  - send rate of GetQosPositionKpi messages above the configured rate and verify they fail with the correct error

        self.getqospositionkpi_tokenbucket_aboverate('AllRequests')

    # ECQ-3882
    def test_getqospositionkpi_maxreqs_perip(self):
        # [Documentation] RateLimiting - DME shall ratelimit GetQosPositionKpi with MaxRequests PerIp
        # ...  - configure ratelimit GetQosPositionKpi with MaxRequests PerIp
        # ...  - send rate of GetQosPositionKpi messages above the configured rate and verify they fail with the correct error

        self.getqospositionkpi_maxreqs('PerIp')

    # ECQ-3883
    def test_getqospositionkpi_maxreqs_allrequests(self):
        # [Documentation] RateLimiting - DME shall ratelimit GetQosPositionKpi with MaxRequests AllRequests
        # ...  - configure ratelimit GetQosPositionKpi with MaxRequests AllRequests
        # ...  - send rate of GetQosPositionKpi messages above the configured rate and verify they fail with the correct error

        self.getqospositionkpi_maxreqs('AllRequests')

    # ECQ-3884
    def test_getqospositionkpi_leakybucket_maxreqs_perip(self):
        # [Documentation] RateLimiting - DME shall ratelimit GetQosPositionKpi with LeakyBucket/MaxReqs PerIp
        # ...  - configure ratelimit GetQosPositionKpi with LeakyBucket/MaxReqs PerIp
        # ...  - send high rate of GetQosPositionKpi messages and verify they fail for MaxReqs limit

        self.getqospositionkpi_leakybucket_maxreqs('PerIp')

    # ECQ-3885
    def test_getqospositionkpi_leakybucket_maxreqs_allrequests(self):
        # [Documentation] RateLimiting - DME shall ratelimit GetQosPositionKpi with LeakyBucket/MaxReqs AllRequests
        # ...  - configure ratelimit GetQosPositionKpi with LeakyBucket/MaxReqs AllRequests
        # ...  - send high rate of GetQosPositionKpi messages and verify they fail for MaxReqs limit

        self.getqospositionkpi_leakybucket_maxreqs('AllRequests')

# removed these tests as I dont have real control on the message rate
#    def test_getqospositionkpi_tokenbucket_maxreqs_perip(self):
#        # [Documentation] RateLimiting - DME shall ratelimit GetFqdnList with TokenBucket/MaxReqs PerIp
#        # ...  - configure ratelimit GetFqdnList with TokenBucket/MaxReqs PerIp
#        # ...  - send high rate of GetFqdnList messages and verify they fail for MaxReqs limit
#
#        self.getqospositionkpi_tokenbucket_maxreqs('PerIp')
#
#    def test_getqospositionkpi_tokenbucket_maxreqs_allrequests(self):
#        # [Documentation] RateLimiting - DME shall ratelimit GetFqdnList with TokenBucket/MaxReqs AllRequests
#        # ...  - configure ratelimit GetFqdnList with TokenBucket/MaxReqs AllRequests
#        # ...  - send high rate of GetFqdnList messages and verify they fail for MaxReqs limit
#
#        self.getqospositionkpi_tokenbucket_maxreqs('AllRequests')

    @classmethod
    def tearDownClass(self):
        self.mc.cleanup_provisioning()
        print('fail_list', fail_list)


if __name__ == '__main__':
    # suite = unittest.TestLoader().loadTestsFromTestCase(tc_registerclient)
    suite = unittest.TestLoader().loadTestsFromTestCase(sys.modules(__name__))
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())
