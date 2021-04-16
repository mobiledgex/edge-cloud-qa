#!/usr/bin/python3

#
# create an app instance for various ways the cloudlet is not sent or not found
# verify 'Specified cloudlet not found' is returned
#
 
import unittest
import grpc
import sys
import time
from delayedassert import expect, expect_equal, assert_expectations
import os
import logging

import MexController as mex_controller

controller_address = os.getenv('AUTOMATION_CONTROLLER_ADDRESS', '127.0.0.1:55001')

mex_root_cert = 'mex-ca.crt'
mex_cert = 'mex-client.crt'
mex_key = 'mex-client.key'

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

class tc(unittest.TestCase):
    def setUp(self):

        self.controller = mex_controller.MexController(controller_address = controller_address,
#                                                    root_cert = mex_root_cert,
#                                                    key = mex_key,
#                                                    client_cert = mex_cert
                                                   )

    def test_CreateAppInstCloudletNotFound_nodata(self):
        # [Documentation] AppInst - User shall not be able to create an app instance with no parms
        # ... create an app instance with no parms
        # ... verify 'Specified cloudlet not found' is returned

        # print the existing app instances
        appinst_pre = self.controller.show_app_instances()
           
        # create the app instance
        app_instance = mex_controller.AppInstance(use_defaults=False)

        resp = None
        try:
            resp = self.controller.create_app_instance(app_instance.app_instance)
        except:
            print('create app instance failed')

        # print the cluster instances after error
        appinst_post = self.controller.show_app_instances()

        expect_equal(self.controller.response.code(), grpc.StatusCode.UNKNOWN, 'status code')
        #expect_equal(self.controller.response.details(), 'Cloudlet operator_key:<>  not ready, state is CLOUDLET_STATE_NOT_PRESENT', 'error details')
        expect_equal(self.controller.response.details(), 'Invalid app name', 'error details')
        #expect_equal(len(appinst_pre), len(appinst_post), 'same number of app ainst')
        assert_expectations()

    def test_CreateAppInstCloudletNotFound_idonly(self):
        # [Documentation] AppInst - User shall not be able to create an app instance with id only
        # ... create an app instance with id only
        # ... verify 'Specified cloudlet not found' is returned

        # print the existing app instances
        appinst_pre = self.controller.show_app_instances()

        # create the app instance
        app_instance = mex_controller.AppInstance(appinst_id=1, use_defaults=False)

        resp = None
        try:
            resp = self.controller.create_app_instance(app_instance.app_instance)
        except:
            print('create app instance failed')

        # print the cluster instances after error
        appinst_post = self.controller.show_app_instances()

        expect_equal(self.controller.response.code(), grpc.StatusCode.UNKNOWN, 'status code')
        #expect_equal(self.controller.response.details(), 'Cloudlet operator_key:<>  not ready, state is CLOUDLET_STATE_NOT_PRESENT', 'error details')
        expect_equal(self.controller.response.details(), 'Invalid app name', 'error details')

        #expect_equal(len(appinst_pre), len(appinst_post), 'same number of app ainst')
        assert_expectations()

    def test_CreateAppInstCloudletNotFound_appnameonly(self):
        # [Documentation] AppInst - User shall not be able to create an app instance with app name only 
        # ... create an app instance with app name only
        # ... verify 'Specified cloudlet not found' is returned

        # print the existing app instances
        appinst_pre = self.controller.show_app_instances()

        # create the app instance
        app_instance = mex_controller.AppInstance(app_name='someApplication', use_defaults=False)

        resp = None
        try:
            resp = self.controller.create_app_instance(app_instance.app_instance)
        except:
            print('create app instance failed')

        # print the cluster instances after error
        appinst_post = self.controller.show_app_instances()

        expect_equal(self.controller.response.code(), grpc.StatusCode.UNKNOWN, 'status code')
        #expect_equal(self.controller.response.details(), 'Cloudlet operator_key:<>  not ready, state is CLOUDLET_STATE_NOT_PRESENT', 'error details')

        #expect_equal(len(appinst_pre), len(appinst_post), 'same number of app ainst')
        assert_expectations()

    def test_CreateAppInstCloudletNotFound_versiononly(self):
        # [Documentation] AppInst - User shall not be able to create an app instance with version only
        # ... create an app instance with version only
        # ... verify 'Specified cloudlet not found' is returned

        # print the existing app instances
        appinst_pre = self.controller.show_app_instances()

        # create the app instance
        app_instance = mex_controller.AppInstance(app_version='1.0', use_defaults=False)

        resp = None
        try:
            resp = self.controller.create_app_instance(app_instance.app_instance)
        except:
            print('create app instance failed')

        # print the cluster instances after error
        appinst_post = self.controller.show_app_instances()

        expect_equal(self.controller.response.code(), grpc.StatusCode.UNKNOWN, 'status code')
        #expect_equal(self.controller.response.details(), 'Cloudlet operator_key:<>  not ready, state is CLOUDLET_STATE_NOT_PRESENT', 'error details')
        expect_equal(self.controller.response.details(), 'Invalid app name', 'error details')

        #expect_equal(len(appinst_pre), len(appinst_post), 'same number of app ainst')
        assert_expectations()

    def test_CreateAppInstCloudletNotFound_developeronly(self):
        # [Documentation] AppInst - User shall not be able to create an app instance with developer name only
        # ... create an app instance with developer name only 
        # ... verify 'Specified cloudlet not found' is returned

        # print the existing app instances
        appinst_pre = self.controller.show_app_instances()

        # create the app instance
        app_instance = mex_controller.AppInstance(developer_org_name='dev', use_defaults=False)

        resp = None
        try:
            resp = self.controller.create_app_instance(app_instance.app_instance)
        except:
            print('create app instance failed')

        # print the cluster instances after error
        appinst_post = self.controller.show_app_instances()

        expect_equal(self.controller.response.code(), grpc.StatusCode.UNKNOWN, 'status code')
        #expect_equal(self.controller.response.details(), 'Cloudlet operator_key:<>  not ready, state is CLOUDLET_STATE_NOT_PRESENT', 'error details')
        expect_equal(self.controller.response.details(), 'Invalid app name', 'error details')

        #expect_equal(len(appinst_pre), len(appinst_post), 'same number of app ainst')
        assert_expectations()

    def test_CreateAppInstCloudletNotFound_nameVesrsionDeveloperonly(self):
        # [Documentation] AppInst - User shall not be able to create an app instance with name/version/developer name only
        # ... create an app instance with id and developer name only
        # ... verify 'Specified cloudlet not found' is returned

        # print the existing app instances
        appinst_pre = self.controller.show_app_instances()

        # create the app instance
        app_instance = mex_controller.AppInstance(app_name='someApplication',
                                                  app_version='1.0',
                                                  developer_org_name='automation_dev_org',
                                                  use_defaults=False)

        resp = None
        try:
            resp = self.controller.create_app_instance(app_instance.app_instance)
        except:
            print('create app instance failed')

        # print the cluster instances after error
        appinst_post = self.controller.show_app_instances()

        expect_equal(self.controller.response.code(), grpc.StatusCode.UNKNOWN, 'status code')
        #expect_equal(self.controller.response.details(), 'Cloudlet operator_key:<>  not ready, state is CLOUDLET_STATE_NOT_PRESENT', 'error details')
        expect_equal(self.controller.response.details(), 'Invalid organization name', 'error details')

        #expect_equal(len(appinst_pre), len(appinst_post), 'same number of app ainst')
        assert_expectations()

    # ECQ-1128
    def test_CreateAppInstCloudletNotFound_cloudletNotFound(self):
        # [Documentation] AppInst - User shall not be able to create an app instance with cloudlet not found
        # ... create an app instance with cloudlet that does not exist
        # ... verify 'Specified cloudlet not found' is returned

        # print the existing app instances
        appinst_pre = self.controller.show_app_instances()

        # create the app instance
        app_instance = mex_controller.AppInstance(app_name='automation_api_app',
                                                  app_version='1.0',
                                                  developer_org_name='automation_dev_org',
                                                  cloudlet_name='nocloud',
                                                  operator_org_name='TMUS')

        resp = None
        try:
            resp = self.controller.create_app_instance(app_instance.app_instance)
        except:
            print('create app instance failed')

        # print the cluster instances after error
        appinst_post = self.controller.show_app_instances()

        expect_equal(self.controller.response.code(), grpc.StatusCode.UNKNOWN, 'status code')
        #expect_equal(self.controller.response.details(), 'Cloudlet key {"organization":"TMUS","name":"nocloud"} not found', 'error details')
        expect_equal(self.controller.response.details(), 'Specified Cloudlet not found', 'error details')
        #expect_equal(self.controller.response.details(), 'Cloudlet operator_key:<name:"TMUS" > name:"nocloud"  not ready, state is CLOUDLET_STATE_NOT_PRESENT', 'error details')
        #expect_equal(len(appinst_pre), len(appinst_post), 'same number of app ainst')
        assert_expectations()

    def test_CreateAppInstCloudletNotFound_noCloudlet(self):
        # [Documentation] AppInst - User shall not be able to create an app instance without cloudlet name
        # ... create an app instance without cloudlet name
        # ... verify 'Specified cloudlet not found' is returned

        # print the existing app instances
        appinst_pre = self.controller.show_app_instances()

        # create the app instance
        app_instance = mex_controller.AppInstance(app_name='someApplication',
                                                  app_version='1.0',
                                                  developer_org_name='dev',
                                                  operator_org_name='TMUS',
                                                  cluster_instance_name='mycluster',
                                                  use_defaults=False)

        resp = None
        try:
            resp = self.controller.create_app_instance(app_instance.app_instance)
        except:
            print('create app instance failed')

        # print the cluster instances after error
        appinst_post = self.controller.show_app_instances()

        expect_equal(self.controller.response.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(self.controller.response.details(), 'Invalid cloudlet name', 'error details')

        #expect_equal(self.controller.response.details(), 'Cloudlet operator_key:<name:"TMUS" >  not ready, state is CLOUDLET_STATE_NOT_PRESENT', 'error details')
        #expect_equal(len(appinst_pre), len(appinst_post), 'same number of app ainst')
        assert_expectations()

    def test_CreateAppInstCloudletNotFound_cloudletNameOnly(self):
        # [Documentation] AppInst - User shall not be able to create an app instance without operator name
        # ... create an app instance without operator name
        # ... verify 'Specified cloudlet not found' is returned

        # print the existing app instances
        appinst_pre = self.controller.show_app_instances()

        # create the app instance
        app_instance = mex_controller.AppInstance(app_name='someApplication',
                                                  app_version='1.0',
                                                  developer_org_name='dev',
                                                  cloudlet_name='tmocloud-1',
                                                  use_defaults=False)

        resp = None
        try:
            resp = self.controller.create_app_instance(app_instance.app_instance)
        except:
            print('create app instance failed')

        # print the cluster instances after error
        appinst_post = self.controller.show_app_instances()

        expect_equal(self.controller.response.code(), grpc.StatusCode.UNKNOWN, 'status code')
        #expect_equal(self.controller.response.details(), 'Cloudlet operator_key:<> name:"tmocloud-1"  not ready, state is CLOUDLET_STATE_NOT_PRESENT', 'error details')
        expect_equal(self.controller.response.details(), 'Invalid organization name', 'error details')

        #expect_equal(len(appinst_pre), len(appinst_post), 'same number of app ainst')
        assert_expectations()

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

