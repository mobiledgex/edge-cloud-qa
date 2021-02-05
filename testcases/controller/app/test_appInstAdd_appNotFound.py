#!/usr/bin/python3

#
# create an app instance for various ways the app is not sent or not found
# verify 'Specified app not found' is returned
#
 
import unittest
import grpc
import sys
import time
import os
from delayedassert import expect, expect_equal, assert_expectations

import MexController as mex_controller

controller_address = os.getenv('AUTOMATION_CONTROLLER_ADDRESS', '127.0.0.1:55001')

stamp = str(time.time())
cloud_name = 'tmocloud-1'
operator_name = 'tmus'
app_name = 'app' + stamp
developer_name = 'developer' + stamp
version = '1.0'

mex_root_cert = 'mex-ca.crt'
mex_cert = 'mex-client.crt'
mex_key = 'mex-client.key'

class tc(unittest.TestCase):
    def setUp(self):

        self.controller = mex_controller.MexController(controller_address = controller_address,
#                                                    root_cert = mex_root_cert,
#                                                    key = mex_key,
#                                                    client_cert = mex_cert
                                                   )

        #self.operator = mex_controller.Operator(operator_name = operator_name)
        #self.cloudlet = mex_controller.Cloudlet(cloudlet_name = cloud_name,
        #                                        operator_name = operator_name,
        #                                        number_of_dynamic_ips = 254)

        #self.controller.create_operator(self.operator.operator)
        #self.controller.create_cloudlet(self.cloudlet.cloudlet)

    # ECQ-1116
    def test_CreateAppInstAppNotFound_nodata(self):
        # [Documentation] AppInst - User shall be not be able to create app instance with no app data
        # ... create an app instance sending no app data
        # ... verify 'Specified app not found' is received

        # print the existing app instances
        appinst_pre = self.controller.show_app_instances()
           
        # create the app instance
        app_instance = mex_controller.AppInstance(cloudlet_name=cloud_name,
                                                  app_name=app_name,
                                                  developer_org_name=developer_name,
                                                  app_version=version,
                                                  cluster_instance_name='autocluster',
                                                  cluster_instance_developer_org_name='MobiledgeX',
                                                  operator_org_name=operator_name)

        resp = None
        try:
            resp = self.controller.create_app_instance(app_instance.app_instance)
        except:
            print('create app instance failed')

        # print the cluster instances after error
        appinst_post = self.controller.show_app_instances()

        expect_equal(self.controller.response.code(), grpc.StatusCode.UNKNOWN, 'status code')
        expect_equal(self.controller.response.details(), 'App key {"organization":"' + developer_name + '","name":"' + app_name + '","version":"' + version + '"} not found', 'error details')
        #expect_equal(len(appinst_pre), len(appinst_post), 'same number of app ainst')
        assert_expectations()

    # ECQ-1117
    def test_CreateAppInstAppNotFound_idonly(self):
        # [Documentation] AppInst - User shall be not be able to create app instance with appInstId only
        # ... create an app instance sending appInstId only
        # ... verify 'Specified app not found' is received

        # print the existing app instances
        appinst_pre = self.controller.show_app_instances()

        # create the app instance
        app_instance = mex_controller.AppInstance(appinst_id=1,
                                                  app_name=app_name,
                                                  developer_org_name=developer_name,
                                                  app_version=version,
                                                  cluster_instance_developer_org_name='MobiledgeX',
                                                  cloudlet_name=cloud_name,
                                                  cluster_instance_name='autocluster',
                                                  operator_org_name=operator_name)

        resp = None
        try:
            resp = self.controller.create_app_instance(app_instance.app_instance)
        except:
            print('create app instance failed')

        # print the cluster instances after error
        appinst_post = self.controller.show_app_instances()

        expect_equal(self.controller.response.code(), grpc.StatusCode.UNKNOWN, 'status code')
        #expect_equal(self.controller.response.details(), 'Specified app not found', 'error details')
        expect_equal(self.controller.response.details(), 'App key {"organization":"' + developer_name + '","name":"' + app_name + '","version":"' + version + '"} not found', 'error details')
        #expect_equal(len(appinst_pre), len(appinst_post), 'same number of app ainst')
        assert_expectations()

    # ECQ-1118
    def test_CreateAppInstAppNotFound_appnameonly(self):
        # [Documentation] AppInst - User shall be not be able to create app instance with unknown app name
        # ... create an app instance sending unknown app name
        # ... verify 'Specified app not found' is received

        # print the existing app instances
        appinst_pre = self.controller.show_app_instances()

        # create the app instance
        app_instance = mex_controller.AppInstance(app_name='smeApplication',
                                                  developer_org_name=developer_name,
                                                  app_version=version,
                                                  cloudlet_name=cloud_name,
                                                  cluster_instance_developer_org_name='MobiledgeX',
                                                  cluster_instance_name='autocluster',
                                                  operator_org_name=operator_name)

        resp = None
        try:
            resp = self.controller.create_app_instance(app_instance.app_instance)
        except:
            print('create app instance failed')

        # print the cluster instances after error
        appinst_post = self.controller.show_app_instances()

        expect_equal(self.controller.response.code(), grpc.StatusCode.UNKNOWN, 'status code')
        #expect_equal(self.controller.response.details(), 'Specified app not found', 'error details')
        expect_equal(self.controller.response.details(), 'App key {"organization":"' + developer_name + '","name":"' + 'smeApplication' + '","version":"' + version + '"} not found', 'error details')
        #expect_equal(len(appinst_pre), len(appinst_post), 'same number of app ainst')
        assert_expectations()

    # ECQ-1119
    def test_CreateAppInstAppNotFound_versiononly(self):
        # [Documentation] AppInst - User shall be not be able to create app instance with appVersion only
        # ... create an app instance sending appVersion only
        # ... verify 'Specified app not found' is received

        # print the existing app instances
        appinst_pre = self.controller.show_app_instances()

        # create the app instance
        app_instance = mex_controller.AppInstance(app_version='1.0',
                                                  app_name=app_name,
                                                  developer_org_name=developer_name,
                                                  cloudlet_name=cloud_name,
                                                  cluster_instance_developer_org_name='MobiledgeX',
                                                  cluster_instance_name='autocluster',
                                                  operator_org_name=operator_name)

        resp = None
        try:
            resp = self.controller.create_app_instance(app_instance.app_instance)
        except:
            print('create app instance failed')

        # print the cluster instances after error
        appinst_post = self.controller.show_app_instances()

        expect_equal(self.controller.response.code(), grpc.StatusCode.UNKNOWN, 'status code')
        #expect_equal(self.controller.response.details(), 'Specified app not found', 'error details')
        expect_equal(self.controller.response.details(), 'App key {"organization":"' + developer_name + '","name":"' + app_name + '","version":"' + '1.0' + '"} not found', 'error details')
        #expect_equal(len(appinst_pre), len(appinst_post), 'same number of app ainst')
        assert_expectations()

    # ECQ-1120
    def test_CreateAppInstAppNotFound_developeronly(self):
        # [Documentation] AppInst - User shall be not be able to create app instance with appDeveloper only
        # ... create an app instance sending appDeveloper only
        # ... verify 'Specified app not found' is received

        # print the existing app instances
        appinst_pre = self.controller.show_app_instances()

        # create the app instance
        app_instance = mex_controller.AppInstance(developer_org_name='dev',
                                                  app_name=app_name,
                                                  app_version=version,
                                                  cloudlet_name=cloud_name,
                                                  cluster_instance_name='autocluster',
                                                  cluster_instance_developer_org_name='MobiledgeX',
                                                  operator_org_name=operator_name)

        resp = None
        try:
            resp = self.controller.create_app_instance(app_instance.app_instance)
        except:
            print('create app instance failed')

        # print the cluster instances after error
        appinst_post = self.controller.show_app_instances()

        expect_equal(self.controller.response.code(), grpc.StatusCode.UNKNOWN, 'status code')
        #expect_equal(self.controller.response.details(), 'Specified app not found', 'error details')
        expect_equal(self.controller.response.details(), 'App key {"organization":"' + 'dev' + '","name":"' + app_name + '","version":"' + version + '"} not found', 'error details')
        #expect_equal(len(appinst_pre), len(appinst_post), 'same number of app ainst')
        assert_expectations()

    # ECQ-1121
    def test_CreateAppInstAppNotFound_nameVersionDeveloperonly(self):
        # [Documentation] AppInst - User shall be not be able to create app instance with appName/appVersion/appDeveloper only
        # ... create an app instance sending appName/appVersion/appDeveloper only
        # ... verify 'Specified app not found' is received

        # print the existing app instances
        appinst_pre = self.controller.show_app_instances()

        # create the app instance
        app_instance = mex_controller.AppInstance(app_name='smeApplication',
                                                  app_version='1.0',
                                                  developer_org_name='dev',
                                                  cloudlet_name=cloud_name,
                                                  cluster_instance_name='autocluster',
                                                  cluster_instance_developer_org_name='MobiledgeX',
                                                  operator_org_name=operator_name)

        resp = None
        try:
            resp = self.controller.create_app_instance(app_instance.app_instance)
        except:
            print('create app instance failed')

        # print the cluster instances after error
        appinst_post = self.controller.show_app_instances()

        expect_equal(self.controller.response.code(), grpc.StatusCode.UNKNOWN, 'status code')
        #expect_equal(self.controller.response.details(), 'Specified app not found', 'error details')
        expect_equal(self.controller.response.details(), 'App key {"organization":"' + 'dev' + '","name":"' + 'smeApplication' + '","version":"' + '1.0' + '"} not found', 'error details')
        #expect_equal(len(appinst_pre), len(appinst_post), 'same number of app ainst')
        assert_expectations()

#    def tearDown(self):
#        self.controller.delete_cloudlet(self.cloudlet.cloudlet)
#        time.sleep(1)
#        self.controller.delete_operator(self.operator.operator)

if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(tc)
    sys.exit(not unittest.TextTestRunner().run(suite).wasSuccessful())

