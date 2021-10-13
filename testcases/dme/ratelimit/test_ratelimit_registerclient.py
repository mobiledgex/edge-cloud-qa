#!/usr/local/bin/python3

import unittest
import sys
import time
from delayedassert import expect, expect_equal, assert_expectations
import logging
import os
import threading

import MexDme as mex_dme
import MexMasterController as mex_master

dme_address = os.getenv('AUTOMATION_DME_ADDRESS', '127.0.0.1:55001')
mc_address = os.getenv('AUTOMATION_MC_ADDRESS', '127.0.0.1:55001')

developer_name = 'automation_dev_org'
app_name = 'automation_api_app'
app_version = '1.0'

num_requests = 1
num_threads = 500  # 500
starttime = -1

logger = logging.getLogger()
logger.setLevel(logging.INFO)

fail_list = []


class tc_registerclient_ratelimit(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        self.dme = mex_dme.MexDme(dme_address=dme_address)

        self. rate_diff_percent = 15

        self.mc = mex_master.MexMasterController(mc_address=mc_address)
        self.flow_name_token = self.mc.get_default_rate_limiting_flow_name() + 'token'

    def calculate_rate_percent(self, requests_per_second):
        rate_minus_percent = (requests_per_second - (requests_per_second * self.rate_diff_percent / 100))
        rate_plus_percent = (requests_per_second + (requests_per_second * self.rate_diff_percent / 100))

        return rate_minus_percent, rate_plus_percent

    def set_leakybucket_flow(self, requests_per_second, target):
        print('setting leakybucket flow')
        self.mc.create_rate_limit_flow(region='US', api_name='RegisterClient', api_endpoint_type='Dme', rate_limit_target=target, flow_algorithm='LeakyBucketAlgorithm', requests_per_second=requests_per_second)
        self.mc.create_rate_limit_flow(region='US', api_name='FindCloudlet', api_endpoint_type='Dme', rate_limit_target=target, flow_algorithm='LeakyBucketAlgorithm', requests_per_second=requests_per_second * 2)
        self.mc.create_rate_limit_flow(region='US', api_name='VerifyLocation', api_endpoint_type='Dme', rate_limit_target=target, flow_algorithm='LeakyBucketAlgorithm', requests_per_second=requests_per_second * 3)

        return self.calculate_rate_percent(requests_per_second)

    def set_tokenbucket_flow(self, requests_per_second, target):
        print('setting tokenbucket flow')
        self.mc.create_rate_limit_flow(region='US', flow_settings_name=self.flow_name_token, api_name='RegisterClient', api_endpoint_type='Dme', rate_limit_target=target, flow_algorithm='TokenBucketAlgorithm', requests_per_second=requests_per_second, burst_size=15)
        self.mc.create_rate_limit_flow(region='US', flow_settings_name=self.flow_name_token, api_name='FindCloudlet', api_endpoint_type='Dme', rate_limit_target=target, flow_algorithm='TokenBucketAlgorithm', requests_per_second=requests_per_second * 2, burst_size=2)
        self.mc.create_rate_limit_flow(region='US', flow_settings_name=self.flow_name_token, api_name='VerifyLocation', api_endpoint_type='Dme', rate_limit_target=target, flow_algorithm='TokenBucketAlgorithm', requests_per_second=requests_per_second * 3, burst_size=2)

    def set_maxreqs(self, max_requests, interval, target):
        print('setting maxreqs')
        self.mc.create_rate_limit_max_requests(region='US', api_name='RegisterClient', api_endpoint_type='Dme', rate_limit_target=target, max_requests_algorithm='FixedWindowAlgorithm', max_requests=max_requests, interval=interval)

    def send_registerclient(self, rate=None):
        def send_message():
            global fail_list

            self.register = mex_dme.Client(app_name=app_name, app_version=app_version, developer_org_name=developer_name)

            for r in range(1, num_requests + 1):
                # print('sending register client', r)
                try:
                    result = self.dme.register_client(self.register.client)
                    self.success_count += 1
                    print('PASS', time.time(), result)
                except Exception as e:
                    self.fail_count += 1
                    fail_list.append(str(e))
                    print('FAIL', time.time(), e)

        t_list = []

        if rate:
            print('message rate', rate, 'sleep', rate / 60)
        for z in range(num_threads):
            t = threading.Thread(target=send_message)
            t.start()
            t_list.append(t)
            if rate:
                time.sleep(1 / rate)
        for z in t_list:
            z.join()

    def registerclient_leakybucket(self, target):
        self.fail_count = 0
        self.success_count = 0

        rate_minus_percent, rate_plus_percent = self.set_leakybucket_flow(requests_per_second=40, target=target)

        starttime = time.time()
        self.send_registerclient()
        endtime = time.time()
        req_rate = (num_requests * num_threads) / (endtime - starttime)

        print('numrequests', num_requests, 'numthreads', num_threads, 'start', starttime, 'end', endtime, 'diff', endtime - starttime, 'successcount', self.success_count, 'failcount', self.fail_count, 'rate', req_rate, 'reqs/s', 'rate_minus_percent', rate_minus_percent, 'rate_plus_percent', rate_plus_percent)

        expect_equal(self.success_count, num_requests * num_threads, 'number of successes')
        expect_equal(self.fail_count, 0, 'number of failures')

        expect((req_rate < rate_plus_percent) and (req_rate > rate_minus_percent), 'error details')
        assert_expectations()

    def registerclient_tokenbucket_belowrate(self, target):
        self.fail_count = 0
        self.success_count = 0

        self.set_tokenbucket_flow(requests_per_second=50, target=target)

        starttime = time.time()
        self.send_registerclient(rate=40)
        endtime = time.time()
        req_rate = (num_requests * num_threads) / (endtime - starttime)
        print('numrequests', num_requests, 'numthreads', num_threads, 'start', starttime, 'end', endtime, 'diff', endtime - starttime, 'successcount', self.success_count, 'failcount', self.fail_count, 'rate', req_rate, 'reqs/s')

        expect_equal(self.success_count, num_requests * num_threads, 'number of successes')
        expect_equal(self.fail_count, 0, 'number of failures')
        assert_expectations()

    def registerclient_tokenbucket_aboverate(self, target):
        # EDGECLOUD-5502 rate limit error from DME has incorrect punctuation

        self.fail_count = 0
        self.success_count = 0

        self.set_tokenbucket_flow(requests_per_second=50, target=target)

        starttime = time.time()
        self.send_registerclient(rate=60)
        endtime = time.time()
        req_rate = (num_requests * num_threads) / (endtime - starttime)
        print('numrequests', num_requests, 'numthreads', num_threads, 'start', starttime, 'end', endtime, 'diff', endtime - starttime, 'successcount', self.success_count, 'failcount', self.fail_count, 'rate', req_rate, 'reqs/s')

        expect(self.success_count < num_requests * num_threads, 'number of successes')
        expect(self.fail_count > 0, 'number of failures')

        for r in fail_list:
            correct_error = False
            if 'status = StatusCode.RESOURCE_EXHAUSTED' in r:
                if target == 'PerIp':
                    if 'details = "Request for /distributed_match_engine.MatchEngineApi/RegisterClient rate limited, please retry later. Error is: Client exceeded api rate limit per ip. Exceeded rate of 50.000000 requests per second."' in r:
                        correct_error = True
                elif target == 'AllRequests':
                    if 'details = "Request for /distributed_match_engine.MatchEngineApi/RegisterClient rate limited, please retry later. Error is: Exceeded rate of 50.000000 requests per second."' in r:
                        correct_error = True
            expect(correct_error == True, 'status code fail. got ' + r)
        assert_expectations()

    def registerclient_maxreqs(self, target):
        self.fail_count = 0
        self.success_count = 0

        self.set_maxreqs(max_requests=50, interval='10s', target=target)

        starttime = time.time()
        self.send_registerclient(rate=40)
        endtime = time.time()
        req_rate = (num_requests * num_threads) / (endtime - starttime)
        print('numrequests', num_requests, 'numthreads', num_threads, 'start', starttime, 'end', endtime, 'diff', endtime - starttime, 'successcount', self.success_count, 'failcount', self.fail_count, 'rate', req_rate, 'reqs/s')

        expect_equal(self.success_count, 100, 'number of successes')
        expect_equal(self.fail_count, 400, 'number of failures')
        for r in fail_list:
            correct_error = False
            if 'status = StatusCode.RESOURCE_EXHAUSTED' in r:
                if target == 'PerIp':
                    if 'details = "Request for /distributed_match_engine.MatchEngineApi/RegisterClient rate limited, please retry later. Error is: Client exceeded api rate limit per ip. Exceeded limit of 50, retry again in ' in r:
                        correct_error = True
                elif target == 'AllRequests':
                    if 'details = "Request for /distributed_match_engine.MatchEngineApi/RegisterClient rate limited, please retry later. Error is: Exceeded limit of 50, retry again in ' in r:
                        correct_error = True

            expect(correct_error == True, 'status code fail. got ' + r)

        assert_expectations()

    def registerclient_leakybucket_maxreqs(self, target):
        self.fail_count = 0
        self.success_count = 0

        self.set_leakybucket_flow(requests_per_second=8, target=target)
        self.set_maxreqs(max_requests=100, interval='1m', target=target)

        starttime = time.time()
        self.send_registerclient(rate=40)
        endtime = time.time()
        req_rate = (num_requests * num_threads) / (endtime - starttime)
        print('numrequests', num_requests, 'numthreads', num_threads, 'start', starttime, 'end', endtime, 'diff', endtime - starttime, 'successcount', self.success_count, 'failcount', self.fail_count, 'rate', req_rate, 'reqs/s')

        expect(self.success_count > 100, 'number of successes')
        expect(self.fail_count < 400, 'number of failures')
        expect(endtime - starttime > 60, 'time diff')
        for r in fail_list:
            correct_error = False
            if 'status = StatusCode.RESOURCE_EXHAUSTED' in r:
                if target == 'PerIp':
                    if 'details = "Request for /distributed_match_engine.MatchEngineApi/RegisterClient rate limited, please retry later. Error is: Client exceeded api rate limit per ip. Exceeded limit of 100, retry again in ' in r:
                        correct_error = True
                elif target == 'AllRequests':
                    if 'details = "Request for /distributed_match_engine.MatchEngineApi/RegisterClient rate limited, please retry later. Error is: Exceeded limit of 100, retry again in ' in r:
                        correct_error = True

            expect(correct_error == True, 'status code fail. got ' + r)

        assert_expectations()

    def registerclient_tokenbucket_maxreqs(self, target):
        self.fail_count = 0
        self.success_count = 0

        self.set_tokenbucket_flow(requests_per_second=80, target=target)
        self.set_maxreqs(max_requests=100, interval='1m', target=target)

        starttime = time.time()
        self.send_registerclient(rate=8)
        endtime = time.time()
        req_rate = (num_requests * num_threads) / (endtime - starttime)
        print('numrequests', num_requests, 'numthreads', num_threads, 'start', starttime, 'end', endtime, 'diff', endtime - starttime, 'successcount', self.success_count, 'failcount', self.fail_count, 'rate', req_rate, 'reqs/s')

        expect(self.success_count > 100, 'number of successes')
        expect(self.fail_count < 400, 'number of failures')
        expect(endtime - starttime > 60, 'time diff')
        for r in fail_list:
            correct_error = False
            if 'status = StatusCode.RESOURCE_EXHAUSTED' in r:
                if target == 'PerIp':
                    if 'details = "Request for /distributed_match_engine.MatchEngineApi/RegisterClient rate limited, please retry later. Error is: Client exceeded api rate limit per ip. Exceeded limit of 100, retry again in ' in r:
                        correct_error = True
                elif target == 'AllRequests':
                    if 'details = "Request for /distributed_match_engine.MatchEngineApi/RegisterClient rate limited, please retry later. Error is: Exceeded limit of 100, retry again in ' in r:
                        correct_error = True
            expect(correct_error == True, 'status code fail. got ' + r)

        assert_expectations()

    # ECQ-3739
    def test_registerclient_leakybucket_perip(self):
        # [Documentation] RateLimiting - DME shall ratelimit RegisterClient with LeakyBucket PerIp
        # ...  - configure ratelimit RegisterClient with LeakyBucket PerIp
        # ...  - send high rate of RegisterClient messages and verify they are processaed at configured rate

        self.registerclient_leakybucket('PerIp')

    # ECQ-3740
    def test_registerclient_leakybucket_allrequests(self):
        # [Documentation] RateLimiting - DME shall ratelimit RegisterClient with LeakyBucket AllRequests
        # ...  - configure ratelimit RegisterClient with LeakyBucket AllRequests
        # ...  - send high rate of RegisterClient messages and verify they are processed at configured rate

        self.registerclient_leakybucket('AllRequests')

    # ECQ-3741
    def test_registerclient_tokenbucket_belowrate_perip(self):
        # [Documentation] RateLimiting - DME shall not ratelimit RegisterClient with TokenBucket PerIp
        # ...  - configure ratelimit RegisterClient with TokenBucket PerIp
        # ...  - send rate of RegisterClient messages below the configured rate and verify they are all processed

        self.registerclient_tokenbucket_belowrate('PerIp')

    # ECQ-3742
    def test_registerclient_tokenbucket_belowrate_allrequests(self):
        # [Documentation] RateLimiting - DME shall not ratelimit RegisterClient with TokenBucket AllRequests
        # ...  - configure ratelimit RegisterClient with TokenBucket AllRequests
        # ...  - send rate of RegisterClient messages below the configured rate and verify they are all processed

        self.registerclient_tokenbucket_belowrate('AllRequests')

    # ECQ-3743
    def test_registerclient_tokenbucket_aboverate_perip(self):
        # [Documentation] RateLimiting - DME shall ratelimit RegisterClient with TokenBucket PerIp
        # ...  - configure ratelimit RegisterClient with TokenBucket PerIp
        # ...  - send rate of RegisterClient messages above the configured rate and verify they fail with the correct error

        self.registerclient_tokenbucket_aboverate('PerIp')

    # ECQ-3744
    def test_registerclient_tokenbucket_aboverate_allrequests(self):
        # [Documentation] RateLimiting - DME shall ratelimit RegisterClient with TokenBucket AllRequests
        # ...  - configure ratelimit RegisterClient with TokenBucket AllRequests
        # ...  - send rate of RegisterClient messages above the configured rate and verify they fail with the correct error

        self.registerclient_tokenbucket_aboverate('AllRequests')

    # ECQ-3745
    def test_registerclient_maxreqs_perip(self):
        # [Documentation] RateLimiting - DME shall ratelimit RegisterClient with MaxRequests PerIp
        # ...  - configure ratelimit RegisterClient with MaxRequests PerIp
        # ...  - send rate of RegisterClient messages above the configured rate and verify they fail with the correct error

        self.registerclient_maxreqs('PerIp')

    # ECQ-3746
    def test_registerclient_maxreqs_allrequests(self):
        # [Documentation] RateLimiting - DME shall ratelimit RegisterClient with MaxRequests AllRequests
        # ...  - configure ratelimit RegisterClient with MaxRequests AllRequests
        # ...  - send rate of RegisterClient messages above the configured rate and verify they fail with the correct error

        self.registerclient_maxreqs('AllRequests')

    # ECQ-3747
    def test_registerclient_leakybucket_maxreqs_perip(self):
        # [Documentation] RateLimiting - DME shall ratelimit RegisterClient with LeakyBucket/MaxReqs PerIp
        # ...  - configure ratelimit RegisterClient with LeakyBucket/MaxReqs PerIp
        # ...  - send high rate of RegisterClient messages and verify they fail for MaxReqs limit

        self.registerclient_leakybucket_maxreqs('PerIp')

    # ECQ-3748
    def test_registerclient_leakybucket_maxreqs_allrequests(self):
        # [Documentation] RateLimiting - DME shall ratelimit RegisterClient with LeakyBucket/MaxReqs AllRequests
        # ...  - configure ratelimit RegisterClient with LeakyBucket/MaxReqs AllRequests
        # ...  - send high rate of RegisterClient messages and verify they fail for MaxReqs limit

        self.registerclient_leakybucket_maxreqs('AllRequests')

    # ECQ-3749
    def test_registerclient_tokenbucket_maxreqs_perip(self):
        # [Documentation] RateLimiting - DME shall ratelimit RegisterClient with TokenBucket/MaxReqs PerIp
        # ...  - configure ratelimit RegisterClient with TokenBucket/MaxReqs PerIp
        # ...  - send high rate of RegisterClient messages and verify they fail for MaxReqs limit

        self.registerclient_tokenbucket_maxreqs('PerIp')

    # ECQ-3750
    def test_registerclient_tokenbucket_maxreqs_allrequests(self):
        # [Documentation] RateLimiting - DME shall ratelimit RegisterClient with TokenBucket/MaxReqs AllRequests
        # ...  - configure ratelimit RegisterClient with TokenBucket/MaxReqs AllRequests
        # ...  - send high rate of RegisterClient messages and verify they fail for MaxReqs limit

        self.registerclient_tokenbucket_maxreqs('AllRequests')

    @classmethod
    def tearDownClass(self):
        self.mc.cleanup_provisioning()
        print('ffff', fail_list)


if __name__ == '__main__':
    # suite = unittest.TestLoader().loadTestsFromTestCase(tc_registerclient)
    suite = unittest.TestLoader().loadTestsFromTestCase(sys.modules(__name__))
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())
