import json
import jwt
import logging
import time
import re
import threading
import requests
import subprocess
import shlex
import os
import imaplib
import email
import queue
import sys
import importlib

from mex_rest import MexRest
from mex_controller_classes import Organization

from mex_master_controller.OrgCloudletPool import OrgCloudletPool
from mex_master_controller.OrgCloudlet import OrgCloudlet
from mex_master_controller.CloudletPool import CloudletPool
from mex_master_controller.VMPool import VMPool
from mex_master_controller.CloudletPoolMember import CloudletPoolMember
from mex_master_controller.Cloudlet import Cloudlet
from mex_master_controller.App import App
from mex_master_controller.AppInstance import AppInstance
from mex_master_controller.ClusterInstance import ClusterInstance
from mex_master_controller.AutoScalePolicy import AutoScalePolicy
from mex_master_controller.Metrics import Metrics
from mex_master_controller.Flavor import Flavor
from mex_master_controller.OperatorCode import OperatorCode
from mex_master_controller.TrustPolicy import TrustPolicy
from mex_master_controller.AutoProvisioningPolicy import AutoProvisioningPolicy
from mex_master_controller.RunCommand import RunCommand
from mex_master_controller.ShowDevice import ShowDevice
from mex_master_controller.ShowDeviceReport import ShowDeviceReport
from mex_master_controller.RunDebug import RunDebug
from mex_master_controller.Config import Config
from mex_master_controller.VerifyEmail import VerifyEmail
from mex_master_controller.AlertReceiver import AlertReceiver
from mex_master_controller.Alert import Alert
from mex_master_controller.User import User
from mex_master_controller.Stream import Stream 
from mex_master_controller.Settings import Settings
from mex_master_controller.Role import Role 
from mex_master_controller.RequestAppInstLatency import RequestAppInstLatency
from mex_master_controller.CloudletPoolAccess import CloudletPoolAccess
from mex_master_controller.RestrictedOrgUpdate import RestrictedOrgUpdate
from mex_master_controller.Controller import Controller
from mex_master_controller.Org import Org
from mex_master_controller.BillingOrg import BillingOrg
from mex_master_controller.GpuDriver import GpuDriver
from mex_master_controller.RateLimitSettings import RateLimitSettings
from mex_master_controller.AlertPolicy import AlertPolicy
from mex_master_controller.OperatorReporting import OperatorReporting
from mex_master_controller.Usage import Usage
from mex_master_controller.Federation import Federation
from mex_master_controller.Login import Login

import shared_variables_mc
import shared_variables

#logging.basicConfig(format='%(asctime)s %(levelname)s %(funcName)s xline:%(lineno)d - %(message)s',datefmt='%d-%b-%y %H:%M:%S')
logger = logging.getLogger(__name__)
#logging.getLogger('webservice').setLevel(logging.WARNING)

timestamp = str(time.time())

class MexMasterController(MexRest):
    """Library for talking to the Master Controller
    """
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'

    def __init__(self, mc_address='127.0.0.1:9900', root_cert=None, mc_password='mexadminfastedgecloudinfra', auto_login=True):
        """The MC address should be given at import time. The default is the local address
        
        Examples:
        | =Setting= | =Value=             | =Value=                             | =Comment= |
        | Library   | MexMasterController | mc_address=%{AUTOMATION_MC_ADDRESS} | # Read mc address from environment variable |
        """
        self.root_cert = None

        if root_cert and len(root_cert) > 0:
            self.root_cert = self._findFile(root_cert)

        super().__init__(address=mc_address, root_cert=self.root_cert)
        
        #print('*WARN*', 'mcinit')
        self.root_url = f'https://{mc_address}/api/v1'
        self.mc_address = mc_address
        
        self.token = None
        self.prov_stack = []

        self.username = 'mexadmin'
        #self.password = 'mexadmin123'
        #self.password = 'mexadminfastedgecloudinfra'
        self.password = mc_password
        self.admin_username = self.username
        self.admin_password = self.password
       
        self.super_token = None
        self._decoded_token = None
        self.orgname = None
        self.orgtype = None
        self.address = None
        self.phone = None
        self.email_address = None
        self.organization_name = None
        self._mail = None

        self._queue_obj = queue.Queue()

        self._number_login_requests = 0
        self._number_login_requests_success = 0
        self._number_login_requests_fail = 0
        self._number_createuser_requests = 0
        self._number_createuser_requests_success = 0
        self._number_createuser_requests_fail = 0
        self._number_currentuser_requests = 0
        self._number_currentuser_requests_success = 0
        self._number_currentuser_requests_fail = 0
        self._number_showrole_requests = 0
        self._number_showrole_requests_success = 0
        self._number_showrole_requests_fail = 0
        self._number_createorg_requests = 0
        self._number_createorg_requests_success = 0
        self._number_createorg_requests_fail = 0
        self._number_showorg_requests = 0
        self._number_showorg_requests_success = 0
        self._number_showorg_requests_fail = 0
        self._number_adduserrole_requests = 0
        self._number_adduserrole_requests_success = 0
        self._number_adduserrole_requests_fail = 0
        self._number_removeuserrole_requests = 0
        self._number_removeuserrole_requests_success = 0
        self._number_removeuserrole_requests_fail = 0

#        self._number_showclusterinst_requests = 0
#        self._number_showclusterinst_requests_success = 0
#        self._number_showclusterinst_requests_fail = 0
#        self._number_createclusterinst_requests = 0
#        self._number_createclusterinst_requests_success = 0
#        self._number_createclusterinst_requests_fail = 0
#        self._number_deleteclusterinst_requests = 0
#        self._number_deleteclusterinst_requests_success = 0
#        self._number_deleteclusterinst_requests_fail = 0

#        self._number_showcloudlet_requests = 0
#        self._number_showcloudlet_requests_success = 0
#        self._number_showcloudlet_requests_fail = 0
#        self._number_createcloudlet_requests = 0
#        self._number_createcloudlet_requests_success = 0
#        self._number_createcloudlet_requests_fail = 0
#        self._number_deletecloudlet_requests = 0
#        self._number_deletecloudlet_requests_success = 0
#        self._number_deletecloudlet_requests_fail = 0

        self._number_showaccount_requests = 0
        self._number_showaccount_requests_success = 0
        self._number_showaccount_requests_fail = 0

        self.flavor = None
        self.app = None
        self.app_instance = None
        self.cloudlet = None
        self.cloudlet_pool = None
        self.cloudlet_pool_member = None
        self.org_cloudlet_pool = None
        self.org_cloudlet = None
        self.vm_pool = None
        self.operatorcode =  None
        self.trustpolicy =  None
        self.autoprov_policy =  None
        self.run_cmd = None
       
        self.login_class = Login(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token)
 
        if auto_login:
            self.super_token = self.login(username=self.username, password=self.password, use_defaults=False)

        #self.autoscale_policy = AutoScalePolicy(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token)

        #self.flavor = Flavor(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token)
        #self.app = App(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token)
        #self.app_instance = AppInstance(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token, thread_queue=self._queue_obj)
        #self.cloudlet = Cloudlet(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token)
        #self.cloudlet_pool = CloudletPool(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token)
        #self.cloudlet_pool_member = CloudletPoolMember(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token)
        #self.org_cloudlet_pool = OrgCloudletPool(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token)
        #self.org_cloudlet = OrgCloudlet(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token)

    def _create_classes(self):
        self.flavor = Flavor(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token)
        self.app = App(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token)
        self.app_instance = AppInstance(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token, thread_queue=self._queue_obj)
        self.cluster_instance = ClusterInstance(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token, thread_queue=self._queue_obj)
        self.cloudlet = Cloudlet(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token)
        self.cloudlet_pool = CloudletPool(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token)
        self.cloudlet_pool_member = CloudletPoolMember(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token)
        self.org_cloudlet_pool = OrgCloudletPool(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token)
        self.org_cloudlet = OrgCloudlet(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token)
        self.operatorcode = OperatorCode(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token)
        self.trust_policy = TrustPolicy(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token)
        self.run_cmd = RunCommand(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token)
        self.showdevice = ShowDevice(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token)
        self.showdevicereport = ShowDeviceReport(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token)
        self.autoprov_policy = AutoProvisioningPolicy(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token)
        self.rundebug = RunDebug(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token)
        self.config = Config(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token)
        self.vm_pool = VMPool(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token)
        self.verify_email_mc = VerifyEmail(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token)
        self.alert_receiver = AlertReceiver(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token)
        self.alert = Alert(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token)
        self.user = User(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token, thread_queue=self._queue_obj)
        self.stream = Stream(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token)
        self.autoscale_policy = AutoScalePolicy(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token)
        self.settings = Settings(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token)
        self.role = Role(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token, thread_queue=self._queue_obj)
        self.request_appinst_latency = RequestAppInstLatency(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token, thread_queue=self._queue_obj)
        self.cloudlet_pool_access = CloudletPoolAccess(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token)
        self.restricted_org_update = RestrictedOrgUpdate(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token)  
        self.controller = Controller(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token)
        self.org = Org(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token)
        self.billingorg = BillingOrg(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token,
                                     super_token=self.super_token)
        self.gpudriver = GpuDriver(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token)
        self.ratelimitsettings = RateLimitSettings(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token)
        self.alert_policy = AlertPolicy(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token)        
        self.operator_reporting = OperatorReporting(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token)
        self.usage = Usage(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token)
        self.federation = Federation(root_url=self.root_url, prov_stack=self.prov_stack, token=self.token, super_token=self.super_token)

    def reload_defaults(self):
        importlib.reload(shared_variables)

    def find_file(self, filename):
        return str(self._findFile(filename))

    def get_supertoken(self):
        return self.super_token

    def get_token(self):
        return self.token

    def get_default_username(self):
        return shared_variables_mc.username_default

    def get_default_email(self):
        return shared_variables_mc.email_default

    def get_roletype(self):
        if self.orgtype == 'developer': return 'DeveloperContributor'
        else: return 'OperatorContributor'

    def get_default_developer_name(self):
        return shared_variables.developer_name_default

    def get_default_operator_name(self):
        return shared_variables.operator_name_default

    def get_default_cluster_name(self):
        return shared_variables.cluster_name_default

    def set_default_cluster_name(self, name):
        shared_variables.cluster_name_default = name

    def get_default_app_name(self):
        return shared_variables.app_name_default

    def get_default_app_version(self):
        return shared_variables.app_version_default

    def get_default_flavor_name(self):
        return shared_variables.flavor_name_default

    def get_default_cloudlet_name(self):
        return shared_variables.cloudlet_name_default

    def get_default_autoscale_policy_name(self):
        return shared_variables.autoscale_policy_name_default

    def get_default_cloudlet_pool_name(self):
        return shared_variables.cloudletpool_name_default

    def get_default_organization_name(self):
        return shared_variables.organization_name_default

    def get_default_trust_policy_name(self):
        return shared_variables.trust_policy_name_default

    def get_default_autoprov_policy_name(self):
        return shared_variables.autoprov_policy_name_default

    def get_default_vm_pool_name(self):
        return shared_variables.vmpool_name_default

    def get_default_alert_receiver_name(self):
        return shared_variables.alert_receiver_name_default

    def get_default_alert_policy_name(self):
        return shared_variables.alert_policy_name_default

    def get_default_auto_provisioning_policy_name(self):
        return shared_variables.autoprov_policy_name_default

    def get_default_rate_limiting_flow_name(self):
        return shared_variables.flow_settings_name_default

    def get_default_rate_limiting_max_requests_name(self):
        return shared_variables.max_requests_settings_name_default

    def get_default_time_stamp(self):
        return shared_variables.time_stamp_default
  
    def get_default_reporter_name(self):
        return shared_variables.reporter_name_default
 
    def get_default_gpudriver_name(self):
        return shared_variables.gpudriver_name_default

    def get_default_gpudriver_build_name(self):    
        return shared_variables.gpudriver_build_name_default

    def get_default_federation_name(self):
        return shared_variables.federation_name_default

    def get_default_federator_zone(self):
        return shared_variables.federator_zone_default
 
    def number_of_login_requests(self):
        return self._number_login_requests

    def number_of_successful_login_requests(self):
        return self._number_login_requests_success

    def number_of_failed_login_requests(self):
        return self._number_login_requests_fail

    def number_of_createuser_requests(self):
        return self._number_createuser_requests

    def number_of_successful_createuser_requests(self):
        return self._number_createuser_requests_success

    def number_of_failed_createuser_requests(self):
        return self._number_createuser_requests_fail

    def number_of_currentuser_requests(self):
        return self._number_currentuser_requests

    def number_of_successful_currentuser_requests(self):
        return self._number_currentuser_requests_success

    def number_of_failed_currentuser_requests(self):
        return self._number_currentuser_requests_fail

    def number_of_showrole_requests(self):
        return self._number_showrole_requests

    def number_of_successful_showrole_requests(self):
        return self._number_showrole_requests_success

    def number_of_failed_showrole_requests(self):
        return self._number_showrole_requests_fail

    def number_of_createorg_requests(self):
        return self._number_createorg_requests

    def number_of_successful_createorg_requests(self):
        return self._number_createorg_requests_success

    def number_of_failed_createorg_requests(self):
        return self._number_createorg_requests_fail

    def number_of_showorg_requests(self):
        return self._number_showorg_requests

    def number_of_successful_showorg_requests(self):
        return self._number_showorg_requests_success

    def number_of_failed_showorg_requests(self):
        return self._number_showorg_requests_fail

    def reset_user_count(self):
        self._number_createuser_requests = 0
        self._number_createuser_requests_success = 0
        self._number_createuser_requests_fail = 0

    def number_of_adduserrole_requests(self):
        return self._number_adduserrole_requests

    def number_of_successful_adduserrole_requests(self):
        return self._number_adduserrole_requests_success

    def number_of_failed_adduserrole_requests(self):
        return self._number_adduserrole_requests_fail

    def number_of_removeuserrole_requests(self):
        return self._number_removeuserrole_requests

    def number_of_successful_removeuserrole_requests(self):
        return self._number_removeuserrole_requests_success

    def number_of_failed_renmoveuserrole_requests(self):
        return self._number_removeuserrole_requests_fail

    def decoded_token(self):
        return self._decoded_token

    def created_username(self):
        return self.username

    def created_password(self):
        return self.password

    def created_org(self):
        orginfo = 'Name:' + self.org + '  Type:' + self.orgtype + '  Address:' + self.address + '  Phone:' + self.phone
        return orginfo

    def login(self, username=None, password=None, totp=None, apikey_id=None, apikey=None, json_data=None, use_defaults=True, use_thread=False):
        login_return = self.login_class.login(username=username, password=password, totp=totp, apikey_id=apikey_id, apikey=apikey, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

        self.token = login_return['token']
        if username == self.admin_username:
            self.super_token = self.token
        self._decoded_token = jwt.decode(self.token, verify=False)

        self._create_classes()

        return self.token
       
    def get_totp(self, totp_shared_key):
        return self.login_class.get_totp(totp_shared_key)
 
    def login_mexadmin(self):
        return self.login(username=self.admin_username, password=self.admin_password)

    def create_controller(self, region=None, controller_address=None, influxdb_address=None, token=None):
        return self.controller.create_controller(region=region, controller_address=controller_address, influxdb_address=influxdb_address, token=token)

    def create_user(self, username=None, password=None, email_address=None, email_password=None, family_name=None, given_name=None, nickname=None, enable_totp=None, server='imap.gmail.com', email_check=False, json_data=None, use_defaults=True, use_thread=False, auto_delete=True, auto_show=True):
        self.username = username
        self.password = password
        self.email_address = email_address

        return self.user.create_user(username=username, password=password, email_address=email_address, email_password=email_password, family_name=family_name, given_name=given_name, nickname=nickname, enable_totp=enable_totp, server=server, email_check=email_check, auto_delete=auto_delete, auto_show=auto_show, use_defaults=use_defaults, use_thread=use_thread)

    def show_user(self,  username=None, email_address=None, family_name=None, given_name=None, nickname=None, role=None, organization=None, locked=None, enable_totp=None, email_verified=None, token=None, json_data=None, use_defaults=True):
        return self.user.show_user(token=token, username=username, email_address=email_address, family_name=family_name, given_name=given_name, nickname=nickname, role=role, organization=organization, locked=locked, enable_totp=enable_totp, email_verified=email_verified, json_data=json_data, use_defaults=use_defaults)

    def get_current_user(self, token=None, json_data=None, use_defaults=True):
        return self.user.current_user(token=token, json_data=json_data, use_defaults=use_defaults)

    def update_current_user(self, token=None, username=None, email_address=None, family_name=None, given_name=None, nickname=None, enable_totp=None, metadata=None, json_data=None, use_defaults=True, use_thread=False):
        return self.user.update_user(token=token, username=username, email_address=email_address, family_name=family_name, given_name=given_name, nickname=nickname, enable_totp=enable_totp, metadata=metadata, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def delete_user(self, username=None, token=None, json_data=None, use_defaults=True, use_thread=False):
        return self.user.delete_user(token=token, username=username, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def update_restricted_user(self, username=None, email_address=None, email_verified=None, family_name=None, given_name=None, nickname=None, locked=None, enable_totp=None, failed_logins=None, token=None, json_data=None, use_defaults=True, use_thread=False):
        return self.user.update_user_restricted(token=token, username=username, email_address=email_address, email_verified=email_verified, family_name=family_name, given_name=given_name, nickname=nickname, locked=locked, enable_totp=enable_totp, failed_logins=failed_logins, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def unlock_user(self, token=None, username=None, use_thread=False):
        if username is None: username = shared_variables_mc.username_default
        if token is None: token = self.super_token

        logging.info(f'unlocking username={username}')
        return self.update_restricted_user(token=token, username=username, locked=False, use_thread=use_thread)

    def show_user_role(self, role=None, organization=None, token=None, json_data=None, use_defaults=True, use_thread=False):
        return self.role.role_show(token=token, role=role, organization=organization, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def show_role_permissions(self, role=None, token=None, json_data=None, use_defaults=True, use_thread=False):
        return self.role.role_perms(token=token, role=role, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def create_user_api_key(self, organization=None, description=None, permission_list=[], token=None, json_data=None, use_defaults=True, use_thread=False):
        return self.user.create_user_api_key(organization=organization, description=description, permission_list=permission_list, token=token, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def delete_user_api_key(self, apikey_id=None, token=None, json_data=None, use_defaults=True, use_thread=False):
        return self.user.delete_user_api_key(apikey_id=apikey_id, token=token, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def show_user_api_key(self, apikey_id=None, token=None, json_data=None, use_defaults=True, use_thread=False):
        return self.user.show_user_api_key(apikey_id=apikey_id, token=token, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def new_password(self, password=None, token=None, json_data=None, use_defaults=True):
        url = self.root_url + '/auth/user/newpass'

        if use_defaults == True:
            if token == None: token = self.token
            if password == None: password = self.password

        if json_data != None:
            payload = json_data
        else:
            user_dict = {}
            if password != None:
                user_dict['password'] = password

            payload = json.dumps(user_dict)

        #print('*WARN*',token)

        self.post(url=url, data=payload, bearer=token)

        logger.info('response:\n' + str(self.resp.text))

        if str(self.resp.text) != '{"message":"Password updated"}':
            raise Exception("error changing password. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())

    def show_role(self, token=None, use_defaults=True, use_thread=False):
        url = self.root_url + '/auth/role/show'

        if use_defaults == True:
            if token == None: token = self.token

        #print('*WARN*',token)

        def send_message():
            self._number_showrole_requests += 1

            try:
                self.post(url=url, bearer=token)

                logger.info('response:\n' + str(self.resp.text))

                if str(self.resp.status_code) != '200':
                    self._number_showrole_requests_fail += 1
                    raise Exception("ws did not return a 200 response. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
            except Exception as e:
                self._number_showrole_requests_fail += 1
                raise Exception("post failed:", e)

        self._number_showrole_requests_success += 1

        if use_thread is True:
            t = threading.Thread(target=send_message)
            t.start()
            return t
        else:
            resp = send_message()
            #if str(self.resp.text) != '["AdminContributor","AdminManager","AdminViewer","DeveloperContributor","DeveloperManager","DeveloperViewer","OperatorContributor","OperatorManager","OperatorViewer"]':
            #if '"AdminContributor","AdminManager","AdminViewer","BillingManager","DeveloperContributor","DeveloperManager","DeveloperViewer","OperatorContributor","OperatorManager","OperatorViewer"' not in str(self.resp.text):
            #    raise Exception("error showing roles. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
            return str(self.resp.text)

    def show_role_assignment(self, token=None, json_data=None, use_defaults=True, use_thread=False, sort_field='username', sort_order='ascending'):
        url = self.root_url + '/auth/role/assignment/show'

        payload = None

        if use_defaults == True:
            if token == None: token = self.token

        if json_data !=  None:
            payload = json_data
        else:
            user_dict = {}
            #if email is not None:
            #    user_dict['email'] = email
            payload = json.dumps(user_dict)

        logger.info('show users and roles on mc at {}. \n\t{}'.format(url, payload))
        #self.post(url=url, bearer=token)

        #logger.info('response:\n' + str(self.resp.text))

        #respText = str(self.resp.text)
        #print('*WARN*', respText)

        #if respText != '[]':
        #    match = re.search('.*org.*username.*role.*', respText)
            # print('*WARN*',match)
        #    if not match:
        #        raise Exception("error showing role assignments. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())

        #return self.decoded_data

        def send_message():

            try:
                self.post(url=url, bearer=token, data=payload)

                logger.info('response:\n' + str(self.resp.text))

                respText = str(self.resp.text)

                if str(self.resp.status_code) != '200':
                    raise Exception("ws did not return a 200 response. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
            except Exception as e:
                raise Exception("post failed:", e)

            resp_data = self.decoded_data
            if type(resp_data) is dict:
                resp_data = [resp_data]

            reverse = True if sort_order == 'descending' else False
            if sort_field == 'username':
                logging.info('sorting by username')
                resp_data = sorted(resp_data, key=lambda x: x['username'].casefold(),reverse=reverse) # sorting since need to check for may apps. this return the sorted list instead of the response itself
            elif sort_field == 'organization':
                logging.info('sorting by organization')
                resp_data = sorted(resp_data, key=lambda x: x['org'].casefold(),reverse=reverse)
            return resp_data

        if use_thread is True:
            t = threading.Thread(target=send_message)
            t.start()
            return t
        else:
            resp = send_message()
            #if str(self.resp.) != '[]':
            #    #match = re.search('.*Name.*Type.*Address.*Phone.*AdminUsername.*CreatedAt.*UpdatedAt.*', str(self.resp.text))
            #    # print('*WARN*',match)
            #    if not match:
            #        raise Exception("error showing organization. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
            #return self.decoded_data
            return resp

    def create_org(self, orgname=None, orgtype=None, address=None, phone=None, public_images=None, token=None, json_data=None, use_defaults=True, use_thread=False, auto_delete=True):
        #orgstamp = str(time.time())
        url = self.root_url + '/auth/org/create'
        payload = None
        
        if use_defaults == True:
            if token == None: token = self.token
            #if orgname == None: orgname = 'orgname' + orgstamp
            #if orgtype == None: orgtype = 'developer'
            #if address == None: address = '111 somewhere dr'
            #if phone == None: phone = '123-456-7777'

        if json_data !=  None:
            payload = json_data
        else:
            org_dict = Organization(organization_name=orgname, organization_type=orgtype, phone=phone, address=address, public_images=public_images, use_defaults=use_defaults).organization
            if 'name' in org_dict:
                self.organization_name = org_dict['name']
            #org_dict = {}
            #if orgname is not None:
            #    org_dict['name'] = orgname
            #if orgtype is not None:
            #    org_dict['type'] = orgtype
            #if address is not None:
            #    org_dict['address'] = address
            #if phone is not None:
            #    org_dict['phone'] = phone

            payload = json.dumps(org_dict)

        logger.info('create org on mc at {}. \n\t{}'.format(url, payload))

        #print('*WARN*', orgname, token)

        def send_message():
            self._number_createorg_requests += 1

            try:
                self.post(url=url, data=payload, bearer=token)

                logger.info('response:\n' + str(self.resp.text))

                if str(self.resp.status_code) != '200':
                    self._number_createorg_requests_fail += 1
                    raise Exception("ws did not return a 200 response. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())

                shared_variables.operator_name_default = org_dict['name']
                
                if auto_delete == True:
                    self.prov_stack.append(lambda:self.delete_org(orgname=org_dict['name'], token=self.super_token))

            except Exception as e:
                self._number_createorg_requests_fail += 1
                raise Exception("post failed:", e)

            self._number_createorg_requests_success += 1


        #self.orgname = org_dict['name']
        self.orgname = orgname
        self.orgtype = orgtype
        self.address = address
        self.phone = phone

        if use_thread is True:
            t = threading.Thread(target=send_message)
            t.start()
            return t
        else:
            resp = send_message()
            if str(self.resp.text) != '{"message":"Organization created"}':
                #if str(self.resp.text) == '{"message":"Organization type must be developer, or operator"}':
                #    raise Exception("error creating organization. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
                raise Exception("error creating organization. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
            return self.organization_name

    def create_billing_org(self, token=None, billing_org_name=None, billing_org_type=None, first_name=None,
                           last_name=None, email_address=None, json_data=None, use_defaults=True, auto_delete=True,
                           use_thread=False):

        if os.environ.get('AUTOMATION_BILLING_ENABLED') == '1' or not os.environ.get('AUTOMATION_BILLING_ENABLED'):
            return self.billingorg.create_billing_org(token=token, billing_org_name=billing_org_name,
                                                      billing_org_type=billing_org_type, first_name=first_name,
                                                      last_name=last_name, email_address=email_address, json_data=json_data,
                                                      use_defaults=use_defaults, auto_delete=auto_delete,
                                                      use_thread=use_thread)
        else:
            logger.info('AUTOMATION_BILLING_ENABLED not enabled. Skipping billing org create')
 
    def delete_billing_org(self, token=None, billing_org_name=None, json_data=None, use_defaults=True, auto_delete=True,
                           use_thread=False):
        return self.billingorg.delete_billing_org(token=token, billing_org_name=billing_org_name, json_data=json_data,
                                                  use_defaults=use_defaults, auto_delete=auto_delete,
                                                  use_thread=use_thread)

    def show_billing_org(self,token=None, billing_org_name=None, json_data=None, use_defaults=True, auto_delete=True,
                           use_thread=False):

        return self.billingorg.show_billing_org(token=token, billing_org_name=billing_org_name, json_data=json_data,
                                                  use_defaults=use_defaults, auto_delete=auto_delete,
                                                  use_thread=use_thread)

    def show_account_info(self, token=None, json_data=None, use_defaults=True, auto_delete=True,
                           use_thread=False):

        return self.billingorg.show_account_info(token=token, json_data=json_data, use_defaults=use_defaults,auto_delete=auto_delete,
                           use_thread=use_thread)

    def get_invoice(self, token=None, billing_org_name=None, start_date=None, end_date=None, json_data=None, use_defaults=True, auto_delete=True,
                           use_thread=False):

        return self.billingorg.get_invoice(token=token, billing_org_name=billing_org_name, start_date=start_date, end_date=end_date,
                            json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def show_organizations(self, token=None, org_name=None, org_type=None, address=None, phone=None, public_images=None, delete_in_progress=None, edgebox_only=None, json_data=None, use_defaults=False, use_thread=False):
        if use_defaults:
            if org_name is None:
                org_name = self.organization_name
            if org_type is None:
                org_type = self.orgtype
            if address is None:
                address = self.address
            if phone is None:
                phone = self.phone

        return self.org.show_org(token=token, org_name=org_name, org_type=org_type, address=address, phone=phone, public_images=public_images, delete_in_progress=delete_in_progress, edgebox_only=edgebox_only, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def delete_org(self, orgname=None, token=None, json_data=None, use_defaults=True):
        url = self.root_url + '/auth/org/delete'
        payload = None

        if use_defaults == True:
            if token is None: token = self.token
            if orgname is None: orgname = shared_variables.operator_name_default

        if json_data !=  None:
            payload = json_data
        else:
            org_dict = {}
            if orgname is not None:
                org_dict['name'] = orgname
                
            payload = json.dumps(org_dict)

        logger.info('delete org on mc at {}. \n\t{}'.format(url, payload))

        try:
            self.post(url=url, data=payload, bearer=token)

            logger.info('response:\n' + str(self.resp.text))

            if str(self.resp.text) != '{"message":"Organization deleted"}':
                raise Exception("error deleting org. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
        except Exception as e:
            raise Exception(f'code={self.resp.status_code}', f'error={self.resp.text}')

    def adduser_role(self, orgname= None, username=None, role=None, token=None, json_data=None, use_defaults=True, use_thread=False):
        """ Sends role add
        """
        url = self.root_url + '/auth/role/adduser'
        payload = None

        if use_defaults == True:
            if token is None: token = self.token
            #if orgname is None: orgname = self.orgname
            if orgname is None: orgname = shared_variables.organization_name_default
            if username is None: username = self.username
            if role is None: role = self.get_roletype()

        if json_data !=  None:
            payload = json_data
        else:
            adduser_dict = {}
            if orgname is not None:
                adduser_dict['org'] = orgname
            if username is not None:
                adduser_dict['username'] = username
            if role is not None:
                adduser_dict['role'] = role

            payload = json.dumps(adduser_dict)

        logger.info('role adduser on mc at {}. \n\t{}'.format(url, payload))

        #print('*WARN*', orgname, token)

        def send_message():
            self._number_adduserrole_requests += 1

            try:
                self.post(url=url, data=payload, bearer=token)

                logger.info('response:\n' + str(self.resp.text))

                if str(self.resp.status_code) != '200':
                    self._number_adduserrole_requests_fail += 1
                    raise Exception("ws did not return a 200 response. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
            except Exception as e:
                self._number_adduserrole_requests_fail += 1
                raise Exception(f'code={self.resp.status_code}', f'error={self.resp.text}')

            self.prov_stack.append(lambda:self.removeuser_role(orgname, username, role, self.super_token))
            self._number_adduserrole_requests_success += 1

        if use_thread is True:
            t = threading.Thread(target=send_message)
            t.start()
            return t
        else:
            resp = send_message()
            if str(self.resp.text) != '{"message":"Role added to user"}':
                raise Exception("error adding user role. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())


    def removeuser_role(self, orgname= None, username=None, role=None, token=None, json_data=None, use_defaults=True, use_thread=False):
        url = self.root_url + '/auth/role/removeuser'
        payload = None

        if use_defaults == True:
            if token is None: token = self.token
            if orgname is None: orgname = self.orgname
            if username is None: username = self.username
            if role is None: role = self.get_roletype()

        if json_data !=  None:
            payload = json_data
        else:
            removeuser_dict = {}
            if orgname is not None:
                removeuser_dict['org'] = orgname
            if username is not None:
                removeuser_dict['username'] = username
            if role is not None:
                removeuser_dict['role'] = role

            payload = json.dumps(removeuser_dict)

        logger.info('role removeuser on mc at {}. \n\t{}'.format(url, payload))

        #print('*WARN*', orgname, token)

        def send_message():
            self._number_removeuserrole_requests += 1

            try:
                self.post(url=url, data=payload, bearer=token)

                logger.info('response:\n' + str(self.resp.text))

                if str(self.resp.status_code) != '200':
                    self._number_removeuserrole_requests_fail += 1
                    raise Exception("ws did not return a 200 response. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
            except Exception as e:
                self._number_removeuserrole_requests_fail += 1
                raise Exception("post failed:", e)

            self._number_removeuserrole_requests_success += 1

        if use_thread is True:
            t = threading.Thread(target=send_message)
            t.start()
            return t
        else:
            resp = send_message()
            if str(self.resp.text) != '{"message":"Role removed from user"}':
                raise Exception("error adding user role. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
            return str(self.resp.text)

    def show_flavors(self, token=None, region=None, flavor_name=None, ram=None, vcpus=None, disk=None, json_data=None, use_defaults=True, use_thread=False, sort_field='flavor_name', sort_order='ascending'):
        resp = self.flavor.show_flavor(token=token, region=region, flavor_name=flavor_name, ram=ram, vcpus=vcpus, disk=disk, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

        reverse = True if sort_order == 'descending' else False
        if sort_field == 'flavor_name':
            #allregion = sorted(allregion, key=lambda x: (x['data']['region'].casefold(), x['data']['key']['name'].casefold()),reverse=reverse)
            resp_data = sorted(resp, key=lambda x: (x['data']['key']['name'].casefold()),reverse=reverse)
        elif sort_field == 'ram':
            logging.info('sorting by ram')
            resp_data = sorted(resp, key=lambda x: (x['data']['key']['ram'].casefold()),reverse=reverse)
        elif sort_field == 'region':
            resp_data = sorted(resp, key=lambda x: x['data']['region'].casefold(),reverse=reverse)

        return resp_data
    
    def create_flavor(self, token=None, region=None, flavor_name=None, ram=None, vcpus=None, disk=None, optional_resources=None, json_data=None, use_defaults=True, use_thread=False, auto_delete=True):
        return self.flavor.create_flavor(token=token, region=region, flavor_name=flavor_name, ram=ram, vcpus=vcpus, disk=disk, optional_resources=optional_resources, json_data=json_data, use_defaults=use_defaults, auto_delete=auto_delete, use_thread=use_thread)

    def delete_flavor(self, token=None, region=None, flavor_name=None, ram=None, vcpus=None, disk=None, json_data=None, use_defaults=True, use_thread=False):
        return self.flavor.delete_flavor(token=token, region=region, flavor_name=flavor_name, ram=ram, vcpus=vcpus, disk=disk, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)
        
    def show_apps(self, token=None, region=None, app_name=None, app_version=None, developer_org_name=None, json_data=None, use_defaults=False, use_thread=False, sort_field='app_name', sort_order='ascending'):
        if app_name or app_version or developer_org_name:
            resp_data = self.app.show_app(token=token, region=region, app_name=app_name, app_version=app_version, developer_org_name=developer_org_name, use_defaults=use_defaults, use_thread=use_thread)
            if type(resp_data) is dict:
                resp_data = [resp_data]

            reverse = True if sort_order == 'descending' else False
            if sort_field == 'app_name':
                resp_data = sorted(resp_data, key=lambda x: x['data']['key']['name'].casefold(),reverse=reverse)

            return resp_data

        else:
            resp_data = self.app.show_app(token=token, region=region, app_name=app_name, app_version=app_version, developer_org_name=developer_org_name, use_defaults=use_defaults, use_thread=use_thread)
            return resp_data

    def show_cloudlet_info(self, token=None, region=None, operator_org_name=None, cloudlet_name=None, json_data=None, use_defaults=False, use_thread=False, sort_field='cloudlet_name', sort_order='ascending'):
        return self.cloudlet.show_cloudlet_info(token=token, region=region, operator_org_name=operator_org_name, cloudlet_name=cloudlet_name, use_defaults=use_defaults, use_thread=use_thread)

    def inject_cloudlet_info(self, token=None, region=None, operator_org_name=None, cloudlet_name=None, container_version=None, controller=None, notify_id=None, os_max_ram=None, os_max_vcores=None, os_max_vol_gb=None, state=None, status=None, flavor_name=None, flavor_disk=None, flavor_ram=None, flavor_vcpus=None, json_data=None, use_defaults=True, use_thread=False, sort_field='cloudlet_name', sort_order='ascending'):
        return self.cloudlet.inject_cloudlet_info(token=token, region=region, operator_org_name=operator_org_name, cloudlet_name=cloudlet_name, controller=controller, notify_id=notify_id, os_max_ram=os_max_ram, os_max_vcores=os_max_vcores, os_max_vol_gb=os_max_vol_gb, state=state, status=status, flavor_name=flavor_name, flavor_disk=flavor_disk, flavor_ram=flavor_ram, flavor_vcpus=flavor_vcpus, use_defaults=use_defaults, use_thread=use_thread)

    def show_cloudlets(self, token=None, region=None, operator_org_name=None, cloudlet_name=None, latitude=None, longitude=None, number_dynamic_ips=None, ip_support=None, platform_type=None, physical_name=None, env_vars=None, crm_override=None, notify_server_address=None, json_data=None, use_defaults=False, use_thread=False, sort_field='cloudlet_name', sort_order='ascending'):
        return self.cloudlet.show_cloudlet(token=token, region=region, operator_org_name=operator_org_name, cloudlet_name=cloudlet_name, latitude=latitude, longitude=longitude, number_dynamic_ips=number_dynamic_ips, ip_support=ip_support, platform_type=platform_type, physical_name=physical_name, env_vars=env_vars, notify_server_address=notify_server_address, crm_override=crm_override, use_defaults=use_defaults, use_thread=use_thread)

    def wait_for_cloudlet_status(self, status, token=None, region=None, operator_org_name=None, cloudlet_name=None, timeout=180):
        for x in range(1, timeout):
            cloudlet = self.show_cloudlet_info(token=token, region=region, operator_org_name=None, cloudlet_name=cloudlet_name, use_defaults=False)
            if cloudlet:
                if cloudlet[0]['data']['state'] == status:
                    logging.info(f'Cloudlet Instance is {status}')
                    return cloudlet
                else:
                    logging.debug(f'cloudlet state not matching {status}. got {cloudlet[0]["data"]["state"]}. sleeping and trying again')
                    time.sleep(1)
            else:
                logging.debug(f'cloudlet is NOT found. sleeping and trying again')

        raise Exception(f'cloudlet is NOT {state}. Got {cloudlet[0]["data"]["state"]} but expected {status}')

    def wait_for_cloudlet_status_online(self, token=None, region=None, operator_org_name=None, cloudlet_name=None, timeout=180):
        return self.wait_for_cloudlet_status(token=token, region=region, operator_org_name=operator_org_name, cloudlet_name=cloudlet_name, timeout=timeout, status='Ready')

    def wait_for_cloudlet_status_offline(self, token=None, region=None, operator_org_name=None, cloudlet_name=None, timeout=180):
        return self.wait_for_cloudlet_status(token=token, region=region, operator_org_name=operator_org_name, cloudlet_name=cloudlet_name, timeout=timeout, status='Offline')

    def get_cloudlet_platform_type(self, token=None, region=None, operator_org_name=None, cloudlet_name=None):
        cloudlet = self.show_cloudlets(token=token, region=region, operator_org_name=operator_org_name, cloudlet_name=cloudlet_name)
        
        shared_variables.platform_type = cloudlet[0]['data']['platform_type'] 

        return cloudlet[0]['data']['platform_type']

    def show_cluster_instances(self, token=None, region=None, cluster_name=None, cloudlet_name=None, developer_org_name=None, json_data=None, use_thread=False, use_defaults=True, sort_field='cluster_name', sort_order='ascending'):
        resp_data = self.cluster_instance.show_cluster_instance(token=token, region=region, cluster_name=cluster_name, cloudlet_name=cloudlet_name, developer_org_name=developer_org_name, json_data=json_data, use_thread=use_thread, use_defaults=use_defaults)

        if type(resp_data) is dict:
            resp_data = [resp_data]

        reverse = True if sort_order == 'descending' else False
        if sort_field == 'cluster_name':
            resp_data = sorted(resp_data, key=lambda x: x['data']['key']['cluster_key']['name'].casefold(),reverse=reverse)

        return resp_data

    def show_app_instances(self, token=None, region=None, appinst_id=None, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, json_data=None, use_defaults=False, use_thread=False, sort_field='app_name', sort_order='ascending'):
        if app_name or app_version or cloudlet_name or operator_org_name or developer_org_name or cluster_instance_name or cluster_instance_developer_org_name:
            resp_data = self.app_instance.show_app_instance(token=token, region=region, appinst_id=appinst_id, app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, developer_org_name=developer_org_name, use_defaults=use_defaults, use_thread=use_thread)
            if type(resp_data) is dict:
                resp_data = [resp_data]

            reverse = True if sort_order == 'descending' else False
            if sort_field == 'app_name':
                resp_data = sorted(resp_data, key=lambda x: x['data']['key']['app_key']['name'].casefold(),reverse=reverse)

            return resp_data
       
        else:
            resp_data = self.app_instance.show_app_instance(token=token, region=region, appinst_id=appinst_id, app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, developer_org_name=developer_org_name, use_defaults=use_defaults, use_thread=use_thread)
            return resp_data
 
    def show_all_flavors(self, sort_field='flavor_name', sort_order='ascending'):
        # should enhance by querying for the regions. But hardcode for now

        usregion = self.show_flavors(region='US', token=self.token, use_defaults=False)
        euregion = self.show_flavors(region='EU', token=self.token, use_defaults=False)

        for region in usregion:
            region['data']['region'] = 'US'

        for region in euregion:
            region['data']['region'] = 'EU'

        allregion = usregion + euregion
        print('*WARN*', 'pre', allregion)
        reverse = True if sort_order == 'descending' else False
        if sort_field == 'flavor_name':
            #allregion = sorted(allregion, key=lambda x: (x['data']['region'].casefold(), x['data']['key']['name'].casefold()),reverse=reverse)
            allregion = sorted(allregion, key=lambda x: (x['data']['key']['name'].casefold()),reverse=reverse)
            print('*WARN*', 'post', allregion)
        elif sort_field == 'ram':
            allregion = sorted(allregion, key=lambda x: (x['data']['ram'], x['data']['key']['name'].casefold()),reverse=reverse)
        elif sort_field == 'vcpus':
            allregion = sorted(allregion, key=lambda x: (x['data']['vcpus'], x['data']['key']['name'].casefold()),reverse=reverse)
        elif sort_field == 'disk':
            allregion = sorted(allregion, key=lambda x: (x['data']['disk'], x['data']['key']['name'].casefold()),reverse=reverse)
        elif sort_field == 'region':
            allregion = sorted(allregion, key=lambda x: x['data']['region'].casefold(),reverse=reverse)

        return allregion

    def show_all_cloudlets(self, sort_field='cloudlet_name', sort_order='ascending'):
        # should enhance by querying for the regions. But hardcode for now

        usregion = self.show_cloudlets(region='US', token=self.token, use_defaults=False)
        euregion = self.show_cloudlets(region='EU', token=self.token, use_defaults=False)

        for region in usregion:
            region['data']['region'] = 'US'

        for region in euregion:
            region['data']['region'] = 'EU'

        allregion = usregion + euregion

        reverse = True if sort_order == 'descending' else False
        if sort_field == 'cloudlet_name':
            #allregion = sorted(allregion, key=lambda x: (x['data']['region'].casefold(), x['data']['key']['name'].casefold()),reverse=reverse)
            allregion = sorted(allregion, key=lambda x: (x['data']['key']['name'].casefold()),reverse=reverse)
        elif sort_field == 'region':
            allregion = sorted(allregion, key=lambda x: x['data']['region'].casefold(),reverse=reverse)

        return allregion


    def show_all_cluster_instances(self, sort_field='cluster_name', sort_order='ascending'):
        # should enhance by querying for the regions. But hardcode for now

        usregion = self.show_cluster_instances(region='US', token=self.token, use_defaults=False)
        euregion = self.show_cluster_instances(region='EU', token=self.token, use_defaults=False)

        for region in usregion:
            region['data']['region'] = 'US'

        for region in euregion:
            region['data']['region'] = 'EU'

        allregion = usregion + euregion

        reverse = True if sort_order == 'descending' else False
        if sort_field == 'cluster_name':
            allregion = sorted(allregion, key=lambda x: x['data']['key']['cluster_key']['name'].casefold(),reverse=reverse)
        elif sort_field == 'region':
            allregion = sorted(allregion, key=lambda x: x['data']['region'].casefold(),reverse=reverse)

        return allregion

    def show_all_apps(self, sort_field='app_name', sort_order='ascending'):
        # should enhance by querying for the regions. But hardcode for now

        usregion = self.show_apps(region='US')
        euregion = self.show_apps(region='EU')

        for region in usregion:
            region['data']['region'] = 'US'

        for region in euregion:
            region['data']['region'] = 'EU'

        allregion = usregion + euregion

        reverse = True if sort_order == 'descending' else False
        if sort_field == 'app_name':
            allregion = sorted(allregion, key=lambda x: x['data']['key']['name'].casefold(),reverse=reverse)
        elif sort_field == 'region':
            allregion = sorted(allregion, key=lambda x: x['data']['region'].casefold(),reverse=reverse)

        return allregion

    def show_accounts(self, token=None, email=None, json_data=None, use_defaults=True, use_thread=False, sort_field='username', sort_order='ascending'):
        url = self.root_url + '/auth/user/show'

        payload = None

        if use_defaults == True:
            if token == None: token = self.token

        if json_data !=  None:
            payload = json_data
        else:
            account_dict = {}
            if email is not None:
                account_dict['email'] = email

            payload = json.dumps(account_dict)

        logger.info('show account on mc at {}. \n\t{}'.format(url, payload))

        def send_message():
            self._number_showaccount_requests += 1

            try:
                self.post(url=url, bearer=token, data=payload)

                logger.info('response:\n' + str(self.resp.text))

                respText = str(self.resp.text)

                if str(self.resp.status_code) != '200':
                    self._number_showorg_requests_fail += 1
                    raise Exception("ws did not return a 200 response. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
            except Exception as e:
                self._number_showaccount_requests_fail += 1
                raise Exception("post failed:", e)

            self._number_showaccount_requests_success += 1

            resp_data = self.decoded_data
            if type(resp_data) is dict:
                resp_data = [resp_data]

            reverse = True if sort_order == 'descending' else False
            if sort_field == 'username':
                logging.info('sorting by username')
                resp_data = sorted(resp_data, key=lambda x: x['Name'].casefold(),reverse=reverse) # sorting since need to check for may apps. this return the sorted list instead of the response itself
            elif  sort_field == 'email':
                logging.info('sorting by email')
                resp_data = sorted(resp_data, key=lambda x: x['Email'].casefold(),reverse=reverse) # sorting since need to check for may apps. this return the sorted list instead of the response itself

            return resp_data

        if use_thread is True:
            t = threading.Thread(target=send_message)
            t.start()
            return t
        else:
            resp = send_message()
            #if str(self.resp.) != '[]':
            #    #match = re.search('.*Name.*Type.*Address.*Phone.*AdminUsername.*CreatedAt.*UpdatedAt.*', str(self.resp.text))
            #    # print('*WARN*',match)
            #    if not match:
            #        raise Exception("error showing organization. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
            #return self.decoded_data
            return resp

    def show_nodes(self, region=None, token=None, json_data=None, use_defaults=True, sort_field='pod_name', sort_order='ascending'):
        url = self.root_url + '/auth/ctrl/ShowNode'
        payload = None

        if use_defaults == True:
            if token is None: token = self.token
            if region is None: region = self.region
            #if password is None: password = self.password
            #if email is None: email = self.username

        if json_data !=  None:
            payload = json_data
        else:
            region_dict = {}
            if region is not None:
                region_dict['region'] = region
            node_dict = {'node': {'key': region_dict}}
            payload = json.dumps(node_dict)

        logger.info('shownode on mc at {}. \n\t{}'.format(url, payload))

        self.post(url=url, data=payload, bearer=token)

        logger.info('response:\n' + str(self.resp.text))

        #if str(self.resp.text) != '{"message":"user deleted"}':
        #    raise Exception("error deleting  user. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())

        resp_data = self.decoded_data
        if type(resp_data) is dict:
            resp_data = [resp_data]

        reverse = True if sort_order == 'descending' else False
        if sort_field == 'pod_name':
            logging.info('sorting by pod name')
            resp_data = sorted(resp_data, key=lambda x: x['data']['key']['name'].casefold(),reverse=reverse) # sorting since need to check for may apps. this return the sorted list instead of the response itself

        return resp_data

    def create_cluster_instance(self, token=None, region=None, cluster_name=None, operator_org_name=None, cloudlet_name=None, developer_org_name=None, flavor_name=None, liveness=None, ip_access=None, deployment=None, number_masters=None, number_nodes=None, shared_volume_size=None, privacy_policy=None, autoscale_policy_name=None, reservable=None, reservation_ended_at_seconds=None, reservation_ended_at_nanoseconds=None, timeout=900, json_data=None, auto_delete=True, use_defaults=True, use_thread=False):
        if developer_org_name is None:
            if self.organization_name:
                developer_org_name = self.organization_name
                cluster_instance_developer_name = self.organization_name

        return self.cluster_instance.create_cluster_instance(token=token, region=region, cluster_name=cluster_name, operator_org_name=operator_org_name, cloudlet_name=cloudlet_name, developer_org_name=developer_org_name, flavor_name=flavor_name, liveness=liveness, ip_access=ip_access, deployment=deployment, number_masters=number_masters, number_nodes=number_nodes, shared_volume_size=shared_volume_size, privacy_policy=privacy_policy, autoscale_policy_name=autoscale_policy_name, reservable=reservable, reservation_ended_at_seconds=reservation_ended_at_seconds, reservation_ended_at_nanoseconds=reservation_ended_at_nanoseconds, stream_timeout=timeout, auto_delete=auto_delete, use_defaults=use_defaults, use_thread=use_thread)

    def delete_cluster_instance(self, token=None, region=None, cluster_name=None, operator_org_name=None, cloudlet_name=None, developer_org_name=None, flavor_name=None, liveness=None, ip_access=None, crm_override=None, json_data=None, use_defaults=True, use_thread=False):
        return self.cluster_instance.delete_cluster_instance(token=token, region=region, cluster_name=cluster_name, operator_org_name=operator_org_name, cloudlet_name=cloudlet_name, developer_org_name=developer_org_name, flavor_name=flavor_name, liveness=liveness, ip_access=ip_access, crm_override=crm_override, use_defaults=use_defaults, use_thread=use_thread)

    def delete_all_cluster_instances(self, region, cloudlet_name, crm_override=None):
        clusterinstances = self.show_cluster_instances(token=self.token, region=region, cloudlet_name=cloudlet_name, use_defaults=False)
        for cluster in clusterinstances:
            logging.info(f'deleting {cluster}')
            self.cluster_instance.delete_cluster_instance(token=self.token, region=region, cluster_name=cluster['data']['key']['cluster_key']['name'], developer_org_name=cluster['data']['key']['organization'], cloudlet_name=cloudlet_name, operator_org_name=cluster['data']['key']['cloudlet_key']['organization'], crm_override=crm_override, use_defaults=False)

    def delete_idle_reservable_cluster_instances(self, token=None, region=None, idle_time=None, json_data=None, use_defaults=True, use_thread=False):
        return self.cluster_instance.delete_idle_clusters(token=token, region=region, idle_time=idle_time, use_defaults=use_defaults, use_thread=use_thread)

    def cluster_instance_should_exist(self, token=None, region=None, cluster_name=None, operator_org_name=None, cloudlet_name=None, developer_org_name=None, use_defaults=False):
            clusterinstance = self.cluster_instance.show_cluster_instance(token=token, cluster_name=cluster_name, operator_org_name=operator_org_name, cloudlet_name=cloudlet_name, developer_org_name=developer_org_name, use_defaults=use_defaults, use_thread=use_thread)
            if clusterinstance:
                return clusterinstance
            else:
                raise Exception(f'cluster instance does NOT exist.')

    def add_alert_policy_app(self, token=None, region=None, app_org=None, app_name=None, app_version=None, alert_policy=None, json_data=False, use_defaults=False, use_thread=False, auto_delete=True):
        return self.app.add_alert_policy_app(token=token, alert_policy=alert_policy, app_name=app_name, app_org=app_org, app_version=app_version, region=region, use_defaults=False, auto_delete=auto_delete, use_thread=use_thread)

    def remove_alert_policy_app(self, token=None, region=None, app_org=None, app_name=None, app_version=None, alert_policy=None, json_data=False, use_defaults=False, use_thread=False, auto_delete=None):
        return self.app.remove_alert_policy_app(token=token, alert_policy=alert_policy, app_name=app_name, app_org=app_org, app_version=app_version, region=region, use_defaults=False, auto_delete=auto_delete, use_thread=use_thread)

    def create_app(self, token=None, region=None, app_name=None, app_version=None, ip_access=None, access_ports=None, image_type=None, image_path=None, cluster_name=None, developer_org_name=None, default_flavor_name=None, config=None, command=None, app_template=None, auth_public_key=None, permits_platform_apps=None, deployment=None, deployment_manifest=None,  scale_with_cluster=False, official_fqdn=None, annotations=None, auto_prov_policies=None, access_type=None, configs_kind=None, configs_config=None, skip_hc_ports=None, trusted=None, required_outbound_connections_list=[], allow_serverless=None, serverless_config_vcpus=None, serverless_config_ram=None, serverless_config_min_replicas=None, alert_policies=None, md5_sum=None, json_data=None, use_defaults=True, auto_delete=True, use_thread=False, show_app=True):
        """ Send region CreateApp
        """
        if developer_org_name is None:
            if self.organization_name:
                developer_org_name = self.organization_name
                cluster_instance_developer_name = self.organization_name
 
        return self.app.create_app(token=token, region=region, app_name=app_name, app_version=app_version, ip_access=ip_access, access_ports=access_ports, image_type=image_type, image_path=image_path,cluster_name=cluster_name, developer_org_name=developer_org_name, default_flavor_name=default_flavor_name, config=config, command=command, app_template=app_template, auth_public_key=auth_public_key, permits_platform_apps=permits_platform_apps, deployment=deployment, deployment_manifest=deployment_manifest, scale_with_cluster=scale_with_cluster, official_fqdn=official_fqdn, annotations=annotations, auto_prov_policies=auto_prov_policies, access_type=access_type, configs_kind=configs_kind, configs_config=configs_config, skip_hc_ports=skip_hc_ports,  trusted=trusted, required_outbound_connections_list=required_outbound_connections_list, allow_serverless=allow_serverless, serverless_config_vcpus=serverless_config_vcpus, serverless_config_ram=serverless_config_ram, serverless_config_min_replicas=serverless_config_min_replicas, alert_policies=alert_policies, md5_sum=md5_sum, use_defaults=use_defaults, auto_delete=auto_delete, use_thread=use_thread, show_app=True)

    def delete_app(self, token=None, region=None, app_name=None, app_version=None, ip_access=None, access_ports=None, image_type=None, image_path=None, cluster_name=None, developer_org_name=None, default_flavor_name=None, config=None, command=None, app_template=None, auth_public_key=None, permits_platform_apps=None, deployment=None, deployment_manifest=None,  scale_with_cluster=False, official_fqdn=None, json_data=None, use_defaults=True, use_thread=False):
        """ Send region DeleteApp
        """
        return self.app.delete_app(token=token, region=region, app_name=app_name, app_version=app_version, ip_access=ip_access, access_ports=access_ports, image_type=image_type, image_path=image_path,cluster_name=cluster_name, developer_org_name=developer_org_name, default_flavor_name=default_flavor_name, config=config, command=command, app_template=app_template, auth_public_key=auth_public_key, permits_platform_apps=permits_platform_apps, deployment=deployment, deployment_manifest=deployment_manifest, scale_with_cluster=scale_with_cluster, official_fqdn=official_fqdn, use_defaults=use_defaults)

    def update_app(self, token=None, region=None, app_name=None, app_version=None, ip_access=None, access_ports=None, image_type=None, image_path=None, cluster_name=None, developer_org_name=None, default_flavor_name=None, config=None, command=None, app_template=None, auth_public_key=None, permits_platform_apps=None, deployment=None, deployment_manifest=None,  scale_with_cluster=False, official_fqdn=None, annotations=None, auto_prov_policies=None, alert_policies=None, skip_hc_ports=None, trusted=None, required_outbound_connections_list=[], allow_serverless=None, serverless_config_vcpus=None, serverless_config_ram=None, serverless_config_min_replicas=None, json_data=None, use_defaults=True, use_thread=False):
        """ Send region UpdateApp
        """
        return self.app.update_app(token=token, region=region, app_name=app_name, app_version=app_version, ip_access=ip_access, access_ports=access_ports, image_type=image_type, image_path=image_path,cluster_name=cluster_name, developer_org_name=developer_org_name, default_flavor_name=default_flavor_name, config=config, command=command, app_template=app_template, auth_public_key=auth_public_key, permits_platform_apps=permits_platform_apps, auto_prov_policies=auto_prov_policies,  alert_policies=alert_policies, deployment=deployment, deployment_manifest=deployment_manifest, scale_with_cluster=scale_with_cluster, official_fqdn=official_fqdn, skip_hc_ports=skip_hc_ports, annotations=annotations, trusted=trusted, required_outbound_connections_list=required_outbound_connections_list, allow_serverless=allow_serverless, serverless_config_vcpus=serverless_config_vcpus, serverless_config_ram=serverless_config_ram, serverless_config_min_replicas=serverless_config_min_replicas, use_defaults=use_defaults)

    def create_app_instance(self, token=None, region=None, appinst_id = None, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, real_cluster_name=None, flavor_name=None, config=None, uri=None, latitude=None, longitude=None, autocluster_ip_access=None, privacy_policy=None, shared_volume_size=None, dedicated_ip=None, crm_override=None, cleanup_cluster_instance=True, json_data=None, use_defaults=True, auto_delete=True, use_thread=False, timeout=600):
        """ Send region CreateAppInst
        """
        if developer_org_name is None:
            if self.organization_name:
                developer_org_name = self.organization_name
        if cluster_instance_developer_org_name is None:
            if self.organization_name:
                if cluster_instance_name is not None and not cluster_instance_name.startswith('autocluster'): cluster_instance_developer_org_name = self.organization_name
        return self.app_instance.create_app_instance(token=token, region=region, appinst_id=appinst_id, app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, real_cluster_name=real_cluster_name, developer_org_name=developer_org_name, flavor_name=flavor_name, config=config, uri=uri, latitude=latitude, longitude=longitude, autocluster_ip_access=autocluster_ip_access, privacy_policy=privacy_policy, shared_volume_size=shared_volume_size, dedicated_ip=dedicated_ip, crm_override=crm_override, cleanup_cluster_instance=cleanup_cluster_instance, use_defaults=use_defaults, auto_delete=auto_delete, use_thread=use_thread, stream_timeout=timeout)

    def get_create_app_instance_stream(self):
        return self.app_instance.create_app_instance_stream()

    def delete_app_instance(self, token=None, region=None, appinst_id = None, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, flavor_name=None, config=None, uri=None, latitude=None, longitude=None, autocluster_ip_access=None, crm_override=None, json_data=None, use_defaults=True, use_thread=False):
        """ Send region DeleteAppInst
        """
        return self.app_instance.delete_app_instance(token=token, region=region, appinst_id=appinst_id, app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, developer_org_name=developer_org_name, flavor_name=flavor_name, config=config, uri=uri, latitude=latitude, longitude=longitude, autocluster_ip_access=autocluster_ip_access, crm_override=crm_override, use_defaults=use_defaults, use_thread=use_thread)

    def delete_all_app_instances(self, region, cloudlet_name, crm_override=None):
        """ Send region DeleteAppInst for all instances filter by cloudlet
        """
        appinstances = self.show_app_instances(region=region, cloudlet_name=cloudlet_name)

        found_failure = False
        for app in appinstances:
            logging.info(f'deleting {app}')
            try:
                self.app_instance.delete_app_instance(region=region, app_name=app['data']['key']['app_key']['name'], app_version=app['data']['key']['app_key']['version'], developer_org_name=app['data']['key']['app_key']['organization'], cloudlet_name=cloudlet_name, cluster_instance_name=app['data']['key']['cluster_inst_key']['cluster_key']['name'], operator_org_name=app['data']['key']['cluster_inst_key']['cloudlet_key']['organization'], cluster_instance_developer_org_name=app['data']['key']['cluster_inst_key']['organization'], crm_override=crm_override)
            except Exception as e:
                found_failure = True
                logging.error(f'error deleting appinst:{e}')

        if found_failure:
            raise Exception('deleting all app instances failed')

    def app_instance_should_exist(self, token=None, region=None, appinst_id = None, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, flavor_name=None, config=None, uri=None, latitude=None, longitude=None, autocluster_ip_access=None, privacy_policy=None, shared_volume_size=None, crm_override=None, json_data=None, use_defaults=False, auto_delete=True, use_thread=False, timeout=180):
            appinstance = self.app_instance.show_app_instance(token=token, region=region, appinst_id=appinst_id, app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, developer_org_name=developer_org_name, flavor_name=flavor_name, config=config, uri=uri, latitude=latitude, longitude=longitude, autocluster_ip_access=autocluster_ip_access, crm_override=crm_override, use_defaults=use_defaults, use_thread=use_thread)
            if appinstance:
                return appinstance
            else:
                raise Exception(f'app instance does NOT exist.')

    def app_instance_should_not_exist(self, token=None, region=None, appinst_id = None, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, flavor_name=None, config=None, uri=None, latitude=None, longitude=None, autocluster_ip_access=None, privacy_policy=None, shared_volume_size=None, crm_override=None, json_data=None, use_defaults=False, auto_delete=True, use_thread=False, timeout=180):
            try:
                appinstance = self.app_instance_should_exist(token=token, region=region, appinst_id=appinst_id, app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, developer_org_name=developer_org_name, flavor_name=flavor_name, config=config, uri=uri, latitude=latitude, longitude=longitude, autocluster_ip_access=autocluster_ip_access, crm_override=crm_override, use_defaults=use_defaults, use_thread=use_thread)
            except Exception as err:
                logging.info('app instance does NOT exist.')
                return True    
            
            raise Exception(f'app instance DOES exist.')

    def wait_for_cluster_instance_to_be_ready(self, token=None, region=None, cluster_name=None, cloudlet_name=None, use_defaults=False, timeout=180):
        for x in range(1, timeout):
            clusterinstance = self.cluster_instance.show_cluster_instance(token=token, region=region, cloudlet_name=cloudlet_name, cluster_name=cluster_name, use_defaults=use_defaults)
            if clusterinstance:
                if clusterinstance and clusterinstance[0]['data']['state'] == 5:
                    logging.info(f'Cluster Instance is Ready')
                    return clusterinstance
                else:
                    logging.debug(f'cluster instance not ready. got {clusterinstance[0]["data"]["state"]}. sleeping and trying again')
                    time.sleep(1)
            else:
                logging.debug(f'cluster instance is NOT found. sleeping and trying again')

        raise Exception(f'cluster instance is NOT ready. Got {clusterinstance[0]["data"]["state"]} but expected 5')

    def wait_for_cluster_instance_to_be_deleted(self, token=None, region=None, cloudlet_name=None, cluster_name=None, use_defaults=False, use_thread=False, timeout=180):
        for x in range(1, timeout):
            clusterinstance = self.cluster_instance.show_cluster_instance(token=token, region=region, cloudlet_name=cloudlet_name, cluster_name=cluster_name, use_defaults=use_defaults)
            if clusterinstance:
                logging.debug(f'cluster instance still exists. got state={clusterinstance[0]["data"]["state"]}. sleeping and trying again')
                time.sleep(1)
            else:
                logging.info(f'cluster instance is NOT found.')
                return True

        raise Exception(f'cluster instance still exists. Got cluster_name={clusterinstance[0]["data"]["key"]["cluster_key"]["name"]}  state={clusterinstance[0]["data"]["state"]}')

    def wait_for_app_instance_to_be_ready(self, token=None, region=None, appinst_id = None, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, flavor_name=None, config=None, uri=None, latitude=None, longitude=None, autocluster_ip_access=None, privacy_policy=None, shared_volume_size=None, crm_override=None, json_data=None, use_defaults=False, auto_delete=True, use_thread=False, timeout=180):
        for x in range(1, timeout):
            appinstance = self.app_instance.show_app_instance(token=token, region=region, appinst_id=appinst_id, app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, developer_org_name=developer_org_name, flavor_name=flavor_name, config=config, uri=uri, latitude=latitude, longitude=longitude, autocluster_ip_access=autocluster_ip_access, crm_override=crm_override, use_defaults=use_defaults, use_thread=use_thread)
            if appinstance:
                if appinstance[0]['data']['state'] == 'Ready':
                    logging.info(f'App Instance is Ready')
                    return appinstance
                elif appinstance[0]['data']['state'] == 5:
                    logging.info(f'App Instance is Ready')
                    return appinstance
                else:
                    logging.debug(f'app instance not ready. got {appinstance[0]["data"]["state"]}. sleeping and trying again')
                    time.sleep(1)
            else:
                logging.debug(f'app instance is NOT found. sleeping and trying again')
        
        if appinstance:    
            raise Exception(f'app instance is NOT ready. Got {appinstance[0]["data"]["state"]} but expected Ready')
        else:
            raise Exception('app instance is NOT found')

    def wait_for_app_instance_to_be_deleted(self, token=None, region=None, appinst_id = None, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, flavor_name=None, config=None, uri=None, latitude=None, longitude=None, autocluster_ip_access=None, privacy_policy=None, shared_volume_size=None, crm_override=None, json_data=None, use_defaults=False, auto_delete=True, use_thread=False, timeout=180):
        for x in range(1, timeout):
            appinstance = self.app_instance.show_app_instance(token=token, region=region, appinst_id=appinst_id, app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, developer_org_name=developer_org_name, flavor_name=flavor_name, config=config, uri=uri, latitude=latitude, longitude=longitude, autocluster_ip_access=autocluster_ip_access, crm_override=crm_override, use_defaults=use_defaults, use_thread=use_thread)
            if appinstance:
                logging.debug(f'app instance still exists. got state={appinstance[0]["data"]["state"]}. sleeping and trying again')
                time.sleep(1)
            else:
                logging.info(f'app instance is NOT found.')
                return True

        raise Exception(f'app instance still exists. Got app_name={appinstance[0]["data"]["key"]["app_key"]["name"]}  state={appinstance[0]["data"]["state"]}')

    def wait_for_app_instance_health_check(self, status, token=None, region=None, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, use_defaults=False, use_thread=False, timeout=180):
        for x in range(1, timeout):
            appinstance = self.app_instance.show_app_instance(token=token, region=region, app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, developer_org_name=developer_org_name, use_defaults=use_defaults, use_thread=use_thread)
            if appinstance:
                if 'health_check' in appinstance[0]['data']:
                    if appinstance[0]['data']['health_check'] == status:
                        logging.info(f'App Instance is health check {status}')
                        return appinstance
                    else:
                        logging.debug(f'app instance health check not {status}. got {appinstance[0]["data"]["health_check"]}. sleeping and trying again')
                        time.sleep(1)
                else:
                    raise Exception(f'health check not found')
            else:
                logging.debug(f'app instance is NOT found. sleeping and trying again')

        raise Exception(f'app instance health check is NOT {status}. Got {appinstance[0]["data"]["health_check"]} but expected {status}')

    def wait_for_app_instance_health_check_ok(self, token=None, region=None, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, use_defaults=False, use_thread=False, timeout=180):
        self.wait_for_app_instance_health_check(status='Ok', token=token, region=region, app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, developer_org_name=developer_org_name, timeout=timeout)

    def wait_for_app_instance_health_check_server_fail(self, token=None, region=None, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, use_defaults=False, auto_delete=True, use_thread=False, timeout=90):
        self.wait_for_app_instance_health_check(status='ServerFail', token=token, region=region, app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, developer_org_name=developer_org_name, timeout=timeout)

    def wait_for_app_instance_health_check_rootlb_offline(self, token=None, region=None, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, use_defaults=False, auto_delete=True, use_thread=False, timeout=90):
        self.wait_for_app_instance_health_check(status='RootlbOffline', token=token, region=region, app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, developer_org_name=developer_org_name, timeout=timeout)

    def wait_for_app_instance_health_check_cloudlet_offline(self, token=None, region=None, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, use_defaults=False, auto_delete=True, use_thread=False, timeout=90):
        self.wait_for_app_instance_health_check(status='CloudletOffline', token=token, region=region, app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, developer_org_name=developer_org_name, timeout=timeout)

    def run_command(self, token=None, region=None, command=None, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, container_id=None, timeout=120, json_data=None, use_defaults=True, use_thread=False):
        return self.run_cmd.run_command(token=token, region=region, mc_address=self.mc_address, app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, developer_org_name=developer_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, container_id=container_id, command=command, use_defaults=use_defaults, use_thread=use_thread, timeout=timeout)

    def show_logs(self, token=None, region=None, command=None, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, container_id=None, since=None, tail=None, time_stamps=None, follow=None, json_data=None, use_defaults=True, use_thread=False):
        return self.run_cmd.show_logs(token=token, region=region, mc_address=self.mc_address, app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, developer_org_name=developer_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, container_id=container_id, since=since, tail=tail, time_stamps=time_stamps, follow=follow, use_defaults=use_defaults, use_thread=use_thread)

    def run_console(self, token=None, region=None, command=None, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, container_id=None, json_data=None, use_defaults=True, use_thread=False):
        return self.run_cmd.run_console(token=token, region=region, mc_address=self.mc_address, app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, developer_org_name=developer_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, container_id=container_id, use_defaults=use_defaults, use_thread=use_thread)
   
    def verify_email_via_mc(self, token=None):
        return self.verify_email_mc.verify_email(token=token)

    def verify_email(self, username=None, password=None, email_address=None, server='imap.gmail.com', wait=30):
        if username is None: username = self.username
        if password is None: password = self.password
        if email_address is None: email_address = self.email_address
        mc_address = self.mc_address
    
        return self.user.verify_email(username=username, password=password, email_address=email_address, server='imap.gmail.com', wait=30, mc_address=mc_address)

    def _run_command(self, cmd):
        try:
            process = subprocess.Popen(shlex.split(cmd),
                                       stdout=subprocess.PIPE,
                                       stderr=subprocess.PIPE,
                                       )
            stdout, stderr = process.communicate()
            logging.info(f'stdout:{stdout} stderr:{stderr}')
            stderr = stderr.decode('utf-8')

            if stderr:
                raise Exception(stderr)

            return stdout
        except subprocess.CalledProcessError as e:
            raise Exception("runCommanddd failed:", e)
        except Exception as e:
            raise Exception("runCommand failed with stderr:", e)

    def create_cloudlet(self, token=None, region=None, operator_org_name=None, cloudlet_name=None, latitude=None, longitude=None, number_dynamic_ips=None, static_ips=None, ip_support=None, platform_type=None, physical_name=None, env_vars=None, access_vars=None, vm_pool=None, deployment_local=None, container_version=None, override_policy_container_version=None, crm_override=None, notify_server_address=None, infra_api_access=None, infra_config_flavor_name=None, infra_config_external_network_name=None, trust_policy=None, deployment_type=None, resource_list=None, default_resource_alert_threshold=None, gpudriver_name=None, gpudriver_org=None, kafka_cluster=None, kafka_user=None, kafka_password=None, alliance_org_list=None, timeout=600, json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        return self.cloudlet.create_cloudlet(token=token, region=region, operator_org_name=operator_org_name, cloudlet_name=cloudlet_name, latitude=latitude, longitude=longitude, number_dynamic_ips=number_dynamic_ips, static_ips=static_ips, ip_support=ip_support, platform_type=platform_type, physical_name=physical_name, env_vars=env_vars, access_vars=access_vars, vm_pool=vm_pool, container_version=container_version, override_policy_container_version=override_policy_container_version, deployment_local=deployment_local, notify_server_address=notify_server_address, crm_override=crm_override, infra_api_access=infra_api_access, infra_config_flavor_name=infra_config_flavor_name, infra_config_external_network_name=infra_config_external_network_name, trust_policy=trust_policy, deployment_type=deployment_type, resource_list=resource_list, default_resource_alert_threshold=default_resource_alert_threshold, gpudriver_name=gpudriver_name, gpudriver_org=gpudriver_org, kafka_cluster=kafka_cluster, kafka_user=kafka_user, kafka_password=kafka_password, alliance_org_list=alliance_org_list, stream_timeout=timeout, use_defaults=use_defaults, auto_delete=auto_delete, use_thread=use_thread)

    def delete_cloudlet(self, token=None, region=None, operator_org_name=None, cloudlet_name=None, latitude=None, longitude=None, number_dynamic_ips=None, ip_support=None, platform_type=None, physical_name=None, crm_override=None, json_data=None, use_defaults=True, use_thread=False):
        return self.cloudlet.delete_cloudlet(token=token, region=region, operator_org_name=operator_org_name, cloudlet_name=cloudlet_name, latitude=latitude, longitude=longitude, number_dynamic_ips=number_dynamic_ips, ip_support=ip_support, platform_type=platform_type, physical_name=physical_name, crm_override=crm_override, use_defaults=use_defaults, use_thread=use_thread)

    def update_cloudlet(self, token=None, region=None,  operator_org_name=None, cloudlet_name=None, latitude=None, longitude=None, number_dynamic_ips=None, ip_support=None, platform_type=None, physical_name=None, env_vars=None, crm_override=None, notify_server_address=None, container_version=None, package_version=None, maintenance_state=None, static_ips=None, trust_policy=None, resource_list=None, default_resource_alert_threshold=None, gpudriver_name=None, gpudriver_org=None, alliance_org_list=None, json_data=None, use_defaults=True, use_thread=False):
        return self.cloudlet.update_cloudlet(token=token, region=region, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, number_dynamic_ips=number_dynamic_ips, latitude=latitude, longitude=longitude, ip_support=ip_support, platform_type=platform_type, physical_name=physical_name, container_version=container_version, package_version=package_version, static_ips=static_ips, env_vars=env_vars, crm_override=crm_override, notify_server_address=notify_server_address, maintenance_state=maintenance_state, trust_policy=trust_policy, resource_list=resource_list, default_resource_alert_threshold=default_resource_alert_threshold, gpudriver_name=gpudriver_name, gpudriver_org=gpudriver_org, alliance_org_list=alliance_org_list, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def add_cloudlet_alliance_org(self, token=None, region=None, operator_org_name=None, cloudlet_name=None, alliance_org_name=None, json_data=None, use_defaults=True, use_thread=False):
        return self.cloudlet.add_alliance_org(token=token, region=region, operator_org_name=operator_org_name, cloudlet_name=cloudlet_name, alliance_org_name=alliance_org_name, use_defaults=use_defaults, use_thread=use_thread)

    def remove_cloudlet_alliance_org(self, token=None, region=None, operator_org_name=None, cloudlet_name=None, alliance_org_name=None, json_data=None, use_defaults=True, use_thread=False):
        return self.cloudlet.remove_alliance_org(token=token, region=region, operator_org_name=operator_org_name, cloudlet_name=cloudlet_name, alliance_org_name=alliance_org_name, use_defaults=use_defaults, use_thread=use_thread)

    def get_resource_usage(self, token=None, region=None, operator_org_name=None, cloudlet_name=None, infra_usage=False, json_data=None, use_defaults=False, use_thread=False):
        return self.cloudlet.get_resource_usage(token=token, region=region, operator_org_name=operator_org_name, cloudlet_name=cloudlet_name, infra_usage=infra_usage, use_defaults=use_defaults, use_thread=use_thread)

    def get_resourcequota_props(self, token=None, region=None, operator_org_name=None, platform_type=None, json_data=None, use_defaults=False, use_thread=False):
        return self.cloudlet.get_resourcequota_props(token=token, region=region, operator_org_name=operator_org_name, platform_type=platform_type, use_defaults=use_defaults, use_thread=use_thread)

    def show_cloudletrefs(self, token=None, region=None, operator_org_name=None, cloudlet_name=None, json_data=None, use_defaults=False, use_thread=False):
        if token is None:
            token=self.super_token

        return self.cloudlet.show_cloudletrefs(token=token, region=region, operator_org_name=operator_org_name, cloudlet_name=cloudlet_name, use_defaults=use_defaults, use_thread=use_thread)

    def get_cloudlet_manifest(self, token=None, region=None, operator_org_name=None, cloudlet_name=None, json_data=None, use_defaults=True, use_thread=False):
        return self.cloudlet.get_cloudlet_manifest(token=token, region=region, operator_org_name=operator_org_name, cloudlet_name=cloudlet_name, use_defaults=use_defaults, use_thread=use_thread)

    def revoke_access_key(self, token=None, region=None, operator_org_name=None, cloudlet_name=None, json_data=None, use_defaults=True, use_thread=False):
        return self.cloudlet.revoke_access_key(token=token, region=region, operator_org_name=operator_org_name, cloudlet_name=cloudlet_name, use_defaults=use_defaults, use_thread=use_thread)

    def get_cloudlet_metrics(self, token=None, region=None, operator_org_name=None, cloudlet_name=None, selector=None, last=None, start_time=None, end_time=None, json_data=None, use_defaults=True, use_thread=False):
        return self.cloudlet.get_cloudlet_metrics(token=token, region=region, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, selector=selector, last=last, start_time=start_time, end_time=end_time, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def get_cloudletusage_metrics(self, token=None, region=None, operator_org_name=None, cloudlet_name=None, selector=None, limit=None, start_time=None, end_time=None, start_age=None, end_age=None, json_data=None, number_samples=None, cloudlet_list=[], use_defaults=True, use_thread=False):
        return self.cloudlet.get_cloudletusage_metrics(token=token, region=region, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, selector=selector, limit=limit, start_time=start_time, end_time=end_time, start_age=start_age, end_age=end_age, number_samples=number_samples, cloudlet_list=cloudlet_list, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def add_cloudlet_resource_mapping(self, token=None, region=None, operator_org_name=None, cloudlet_name=None, mapping=None, json_data=None, use_defaults=True, use_thread=False):
        """ Sends region AddCloudletResMapping
        """
        return self.cloudlet.add_cloudlet_resource_mapping(token=token, region=region, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, mapping=mapping, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def create_resource_tag_table(self, token=None, region=None, resource_table_name=None, operator_org_name=None, tags=None, json_data=None, use_defaults=True, use_thread=False):
        """ Sends region CreateResTagTable
        """
        return self.cloudlet.create_resource_table(token=token, region=region, resource_table_name=resource_table_name, operator_org_name=operator_org_name, tags=tags, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def add_resource_tag(self, token=None, region=None, resource_name=None, operator_org_name=None, tags=None, json_data=None, use_defaults=True, use_thread=False):
        """ Sends region AddResTag
        """
        return self.cloudlet.add_resource_tag(token=token, region=region, resource_name=resource_name, operator_org_name=operator_org_name, tags=tags, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def find_flavor_match(self, token=None, region=None, cloudlet_name=None, operator_org_name=None, flavor_name=None, json_data=None, use_defaults=True, use_thread=False):
        """ Sends cloudlet findflavormatch
        """
        return self.cloudlet.find_flavor_match(token=token, region=region, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, flavor_name=flavor_name, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def show_flavors_for_cloudlet(self, token=None, region=None, cloudlet_name=None, operator_org_name=None, json_data=None, use_defaults=True, use_thread=False):
        """ Sends cloudlet showflavorsfor
        """
        return self.cloudlet.show_flavors_for_cloudlet(token=token, region=region, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def get_app_usage(self, token=None, region=None, app_name=None, app_version=None, developer_org_name=None, cluster_instance_name=None, operator_org_name=None, cloudlet_name=None, start_time=None, end_time=None, vm_only=None, json_data=None, use_defaults=True, use_thread=False):
        return self.usage.get_app_usage(token=token, region=region, app_name=app_name, app_version=app_version, developer_org_name=developer_org_name, cluster_instance_name=cluster_instance_name, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, start_time=start_time, end_time=end_time, vm_only=vm_only, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def get_cluster_usage(self, token=None, region=None, developer_org_name=None, cluster_instance_name=None, operator_org_name=None, cloudlet_name=None, start_time=None, end_time=None, json_data=None, use_defaults=True, use_thread=False):
        return self.usage.get_cluster_usage(token=token, region=region, developer_org_name=developer_org_name, cluster_instance_name=cluster_instance_name, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, start_time=start_time, end_time=end_time, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def get_cloudlet_pool_usage(self, token=None, region=None, operator_org_name=None, cloudlet_pool_name=None, start_time=None, end_time=None, show_vm_apps_only=None, json_data=None, use_defaults=True, use_thread=False):
        return self.usage.get_cloudlet_pool_usage(token=token, region=region, cloudlet_pool_name=cloudlet_pool_name, operator_org_name=operator_org_name, start_time=start_time, end_time=end_time, show_vm_apps_only=show_vm_apps_only, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def get_cluster_metrics(self, token=None, region=None, cluster_name=None, operator_org_name=None, cloudlet_name=None, developer_org_name=None, selector=None, last=None, start_time=None, end_time=None, json_data=None, use_defaults=True, use_thread=False):
      return self.cluster_instance.get_cluster_metrics(token=token, region=region, cluster_name=cluster_name, operator_org_name=operator_org_name, cloudlet_name=cloudlet_name, developer_org_name=developer_org_name, selector=selector, last=last, start_time=start_time, end_time=end_time, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)
        
    def get_app_metrics(self, token=None, region=None, app_name=None, app_version=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, developer_org_name=None, operator_org_name=None, cloudlet_name=None, selector=None, last=None, start_time=None, end_time=None, json_data=None, use_defaults=True, use_thread=False):
        print('*WARN*', 'mc version', app_version)
        return self.app_instance.get_app_metrics(token=token, region=region, app_name=app_name, app_version=app_version, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, developer_org_name=developer_org_name, operator_org_name=operator_org_name, cloudlet_name=cloudlet_name, selector=selector, last=last, start_time=start_time, end_time=end_time, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def get_dme_metrics(self, token=None, region=None, method=None, app_name=None, developer_org_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, selector=None, limit=None, start_time=None, end_time=None, cell_id=None, json_data=None, use_defaults=True, use_thread=False):
        return self.app_instance.get_api_metrics(method=method, token=token, region=region, selector=selector, app_name=app_name, developer_org_name=developer_org_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cell_id=cell_id, limit=limit, start_time=start_time, end_time=end_time, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def get_client_api_usage_metrics(self, token=None, region=None, method=None, app_name=None, developer_org_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, selector=None, limit=None, number_samples=None, start_time=None, end_time=None, start_age=None, end_age=None, cell_id=None, json_data=None, use_defaults=True, use_thread=False):
        return self.app_instance.get_api_metrics(method=method, token=token, region=region, selector=selector, app_name=app_name, developer_org_name=developer_org_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cell_id=cell_id, limit=limit, number_samples=number_samples, start_time=start_time, end_time=end_time, start_age=start_age, end_age=end_age, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def get_client_app_usage_metrics(self, token=None, region=None, method=None, app_name=None, developer_org_name=None, app_version=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, cloudlet_name=None, operator_org_name=None, selector=None, limit=None, number_samples=None, start_time=None, end_time=None, start_age=None, end_age=None, cell_id=None, location_tile=None, device_os=None, device_model=None, data_network_type=None, json_data=None, use_defaults=True, use_thread=False):
        return self.app_instance.get_client_app_metrics(method=method, token=token, region=region, app_name=app_name, developer_org_name=developer_org_name, app_version=app_version, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cell_id=cell_id, limit=limit, number_samples=number_samples, start_time=start_time, end_time=end_time, start_age=start_age, end_age=end_age, selector=selector, location_tile=location_tile, device_os=device_os, device_model=device_model, data_network_type=data_network_type, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def get_client_cloudlet_usage_metrics(self, token=None, region=None, method=None, cloudlet_name=None, operator_org_name=None, selector=None, limit=None, number_samples=None, start_time=None, end_time=None, start_age=None, end_age=None, cell_id=None, location_tile=None, device_os=None, device_model=None, device_carrier=None, data_network_type=None, json_data=None, use_defaults=True, use_thread=False):
        return self.cloudlet.get_client_cloudlet_metrics(method=method, token=token, region=region, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cell_id=cell_id, limit=limit, number_samples=number_samples, start_time=start_time, end_time=end_time, start_age=start_age, end_age=end_age, selector=selector, location_tile=location_tile, device_os=device_os, device_model=device_model, device_carrier=device_carrier, data_network_type=data_network_type, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def get_find_cloudlet_api_metrics(self, token=None, region=None, app_name=None, developer_org_name=None, app_version=None, selector=None, limit=None, start_time=None, end_time=None, cell_id=None, number_samples=None, json_data=None, use_defaults=True, use_thread=False):
        return self.app_instance.get_api_metrics(method='FindCloudlet', token=token, region=region, selector=selector, app_name=app_name, developer_org_name=developer_org_name, app_version=app_version, cell_id=cell_id, limit=limit, start_time=start_time, end_time=end_time, number_samples=number_samples, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def get_verify_location_api_metrics(self, token=None, region=None, app_name=None, developer_org_name=None, app_version=None, selector=None, limit=None, start_time=None, end_time=None, cell_id=None, number_samples=None, json_data=None, use_defaults=True, use_thread=False):
        return self.app_instance.get_api_metrics(method='VerifyLocation', token=token, region=region, selector=selector, app_name=app_name, developer_org_name=developer_org_name, app_version=app_version, cell_id=cell_id, limit=limit, start_time=start_time, end_time=end_time, number_samples=number_samples, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def get_platform_find_cloudlet_api_metrics(self, token=None, region=None, app_name=None, developer_org_name=None, app_version=None, selector=None, limit=None, start_time=None, end_time=None, cell_id=None, json_data=None, use_defaults=True, use_thread=False):
        return self.app_instance.get_api_metrics(method='PlatformFindCloudlet', token=token, region=region, selector=selector, app_name=app_name, developer_org_name=developer_org_name, app_version=app_version, cell_id=cell_id, limit=limit, start_time=start_time, end_time=end_time, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def get_register_client_api_metrics(self, token=None, region=None, app_name=None, developer_org_name=None, app_version=None, selector=None, limit=None, start_time=None, end_time=None, cell_id=None, number_samples=None, json_data=None, use_defaults=True, use_thread=False):
        return self.app_instance.get_api_metrics(method='RegisterClient', token=token, region=region, selector=selector, app_name=app_name, developer_org_name=developer_org_name, app_version=app_version, cell_id=cell_id, limit=limit, start_time=start_time, end_time=end_time, number_samples=number_samples, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def show_app_instance_client_metrics(self, token=None, region=None, app_name=None, developer_org_name=None, app_version=None, cluster_instance_name=None, operator_org_name=None, cloudlet_name=None, unique_id=None, unique_id_type=None, json_data=None, use_defaults=True, use_thread=False):
        return self.app_instance.show_app_instance_client_metrics(token=token, region=region, app_name=app_name, developer_org_name=developer_org_name, app_version=app_version, cluster_instance_name=cluster_instance_name, operator_org_name=operator_org_name, cloudlet_name=cloudlet_name, uuid=unique_id, uuid_type=unique_id_type, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def get_show_app_instance_client_metrics_output(self):
        return self.app_instance.get_show_app_instance_client_metrics()

    def create_autoscale_policy(self, token=None, region=None, policy_name=None, developer_name=None, developer_org_name=None,  min_nodes=None, max_nodes=None, scale_up_cpu_threshold=None, scale_down_cpu_threshold=None, trigger_time=None, target_cpu=None, target_memory=None, target_active_connections=None, stabilization_window_sec=None, json_data=None, use_defaults=True, use_thread=False):
        return self.autoscale_policy.create_autoscale_policy(token=token, region=region, policy_name=policy_name, developer_name=developer_name, developer_org_name=developer_org_name, min_nodes=min_nodes, max_nodes=max_nodes, scale_up_cpu_threshold=scale_up_cpu_threshold, scale_down_cpu_threshold=scale_down_cpu_threshold, trigger_time=trigger_time, target_cpu=target_cpu, target_memory=target_memory, target_active_connections=target_active_connections, stabilization_window_sec=stabilization_window_sec, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def delete_autoscale_policy(self, token=None, region=None, policy_name=None, developer_org_name=None, min_nodes=None, max_nodes=None, scale_up_cpu_threshold=None, scale_down_cpu_threshold=None, trigger_time=None, json_data=None, use_defaults=True, use_thread=False):
        return self.autoscale_policy.delete_autoscale_policy(token=token, region=region, policy_name=policy_name, developer_org_name=developer_org_name, min_nodes=min_nodes, max_nodes=max_nodes, scale_up_cpu_threshold=scale_up_cpu_threshold, scale_down_cpu_threshold=scale_down_cpu_threshold, trigger_time=trigger_time, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def update_autoscale_policy(self, token=None, region=None, policy_name=None, developer_org_name=None, min_nodes=None, max_nodes=None, scale_up_cpu_threshold=None, scale_down_cpu_threshold=None, trigger_time=None, json_data=None, use_defaults=False, use_thread=False):
        return self.autoscale_policy.update_autoscale_policy(token=token, region=region, policy_name=policy_name, developer_org_name=developer_org_name, min_nodes=min_nodes, max_nodes=max_nodes, scale_up_cpu_threshold=scale_up_cpu_threshold, scale_down_cpu_threshold=scale_down_cpu_threshold, trigger_time=trigger_time, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def show_autoscale_policy(self, token=None, region=None, policy_name=None, developer_org_name=None, min_nodes=None, max_nodes=None, scale_up_cpu_threshold=None, scale_down_cpu_threshold=None, trigger_time=None, json_data=None, use_defaults=True, use_thread=False):
        return self.autoscale_policy.show_autoscale_policy(token=token, region=region, policy_name=policy_name, developer_org_name=developer_org_name, min_nodes=min_nodes, max_nodes=max_nodes, scale_up_cpu_threshold=scale_up_cpu_threshold, scale_down_cpu_threshold=scale_down_cpu_threshold, trigger_time=trigger_time, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def create_operator_code (self, token=None, region=None, operator_org_name=None, code=None, json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        return self.operatorcode.create_operator_code(token=token, region=region, operator_org_name=operator_org_name,code=code, json_data=json_data, use_defaults=use_defaults, auto_delete=auto_delete, use_thread=use_thread)

    def delete_operator_code (self, token=None, region=None, operator_org_name=None, code=None, json_data=None, use_defaults=True, use_thread=False):
        return self.operatorcode.delete_operator_code(token=token, region=region, operator_org_name=operator_org_name,code=code, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def show_operator_code (self, token=None, region=None, operator_org_name=None, code=None, json_data=None, use_defaults=True, use_thread=False):
        return self.operatorcode.show_operator_code(token=token, region=region, operator_org_name=operator_org_name,code=code, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)


    def add_cloudlet_pool_member(self, token=None, region=None, cloudlet_pool_name=None, operator_org_name=None, cloudlet_name=None, json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        return self.cloudlet_pool_member.add_cloudlet_pool_member(token=token, region=region, cloudlet_pool_name=cloudlet_pool_name, operator_org_name=operator_org_name, cloudlet_name=cloudlet_name, json_data=json_data, use_defaults=use_defaults, auto_delete=auto_delete, use_thread=use_thread)

    def remove_cloudlet_pool_member(self, token=None, region=None, cloudlet_pool_name=None, operator_org_name=None, cloudlet_name=None, json_data=None, use_defaults=True, use_thread=False):
        return self.cloudlet_pool_member.remove_cloudlet_pool_member(token=token, region=region, cloudlet_pool_name=cloudlet_pool_name, operator_org_name=operator_org_name, cloudlet_name=cloudlet_name, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    #def show_cloudlet_pool_member(self, token=None, region=None, cloudlet_pool_name=None, operator_org_name=None, cloudlet_name=None, json_data=None, use_defaults=True, use_thread=False):
    #    return self.cloudlet_pool_member.show_cloudlet_pool_member(token=token, region=region, cloudlet_pool_name=cloudlet_pool_name, operator_org_name=operator_org_name, cloudlet_name=cloudlet_name, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def create_cloudlet_pool(self, token=None, region=None, cloudlet_pool_name=None, operator_org_name=None, cloudlet_list=None, json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        return self.cloudlet_pool.create_cloudlet_pool(token=token, region=region, cloudlet_pool_name=cloudlet_pool_name, operator_org_name=operator_org_name, cloudlet_list=cloudlet_list, json_data=json_data, use_defaults=use_defaults, auto_delete=auto_delete, use_thread=use_thread)

    def show_cloudlet_pool(self, token=None, region=None, cloudlet_pool_name=None, cloudlet_list=None, operator_org_name=None, json_data=None, use_defaults=True, use_thread=False):
        return self.cloudlet_pool.show_cloudlet_pool(token=token, region=region, cloudlet_pool_name=cloudlet_pool_name, cloudlet_list=cloudlet_list, operator_org_name=operator_org_name, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def delete_cloudlet_pool(self, token=None, region=None, cloudlet_pool_name=None, operator_org_name=None, json_data=None, use_defaults=True, use_thread=False):
        return self.cloudlet_pool.delete_cloudlet_pool(token=token, region=region, cloudlet_pool_name=cloudlet_pool_name, operator_org_name=operator_org_name, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def update_cloudlet_pool(self, token=None, region=None, cloudlet_pool_name=None, operator_org_name=None, cloudlet_list=None, json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        return self.cloudlet_pool.update_cloudlet_pool(token=token, region=region, cloudlet_pool_name=cloudlet_pool_name, operator_org_name=operator_org_name, cloudlet_list=cloudlet_list, json_data=json_data, use_defaults=use_defaults, auto_delete=auto_delete, use_thread=use_thread)

    def create_org_cloudlet_pool(self, token=None, region=None, cloudlet_pool_name=None, cloudlet_pool_org_name=None, org_name=None, json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        return self.org_cloudlet_pool.create_org_cloudlet_pool(token=token, region=region, cloudlet_pool_name=cloudlet_pool_name, cloudlet_pool_org_name=cloudlet_pool_org_name, org_name=org_name, json_data=json_data, use_defaults=use_defaults, auto_delete=auto_delete, use_thread=use_thread)

    def show_org_cloudlet_pool(self, token=None, region=None, cloudlet_pool_name=None, org_name=None, json_data=None, use_defaults=True, use_thread=False):
        return self.org_cloudlet_pool.show_org_cloudlet_pool(token=token, region=region, cloudlet_pool_name=cloudlet_pool_name, org_name=org_name, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def delete_org_cloudlet_pool(self, token=None, region=None, cloudlet_pool_name=None, cloudlet_pool_org_name=None, org_name=None, json_data=None, use_defaults=True, use_thread=False):
        return self.org_cloudlet_pool.delete_org_cloudlet_pool(token=token, region=region, cloudlet_pool_name=cloudlet_pool_name, cloudlet_pool_org_name=cloudlet_pool_org_name, org_name=org_name, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def show_org_cloudlet(self, token=None, region=None, org_name=None, json_data=None, use_defaults=True, use_thread=False):
        return self.org_cloudlet.show_org_cloudlet(token=token, region=region, org_name=org_name, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def create_cloudlet_pool_access_invitation(self, token=None, region=None, cloudlet_pool_name=None, developer_org_name=None, cloudlet_pool_org_name=None, json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        return self.cloudlet_pool_access.create_cloudlet_pool_access_invitation(token=token, region=region, cloudlet_pool_name=cloudlet_pool_name, developer_org_name=developer_org_name, cloudlet_pool_org_name=cloudlet_pool_org_name, json_data=json_data, use_defaults=use_defaults, auto_delete=auto_delete, use_thread=use_thread)

    def delete_cloudlet_pool_access_invitation(self, token=None, region=None, cloudlet_pool_name=None, developer_org_name=None, cloudlet_pool_org_name=None, json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        return self.cloudlet_pool_access.delete_cloudlet_pool_access_invitation(token=token, region=region, cloudlet_pool_name=cloudlet_pool_name, developer_org_name=developer_org_name, cloudlet_pool_org_name=cloudlet_pool_org_name, json_data=json_data, use_defaults=use_defaults, auto_delete=auto_delete, use_thread=use_thread)

    def create_cloudlet_pool_access_response(self, token=None, region=None, cloudlet_pool_name=None, developer_org_name=None, cloudlet_pool_org_name=None, decision=None, json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        return self.cloudlet_pool_access.create_cloudlet_pool_access_response(token=token, region=region, cloudlet_pool_name=cloudlet_pool_name, developer_org_name=developer_org_name, cloudlet_pool_org_name=cloudlet_pool_org_name, decision=decision, json_data=json_data, use_defaults=use_defaults, auto_delete=auto_delete, use_thread=use_thread)

    def delete_cloudlet_pool_access_response(self, token=None, region=None, cloudlet_pool_name=None, developer_org_name=None, cloudlet_pool_org_name=None, json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        return self.cloudlet_pool_access.delete_cloudlet_pool_access_response(token=token, region=region, cloudlet_pool_name=cloudlet_pool_name, developer_org_name=developer_org_name, cloudlet_pool_org_name=cloudlet_pool_org_name, json_data=json_data, use_defaults=use_defaults, auto_delete=auto_delete, use_thread=use_thread)

    def show_cloudlet_pool_access_granted(self, token=None, region=None, cloudlet_pool_name=None, developer_org_name=None, cloudlet_pool_org_name=None, json_data=None, use_defaults=False, auto_delete=True, use_thread=False):
        return self.cloudlet_pool_access.show_cloudlet_pool_access_granted(token=token, region=region, cloudlet_pool_name=cloudlet_pool_name, developer_org_name=developer_org_name, cloudlet_pool_org_name=cloudlet_pool_org_name, json_data=json_data, use_defaults=use_defaults, auto_delete=auto_delete, use_thread=use_thread)

    def show_cloudlet_pool_access_pending(self, token=None, region=None, cloudlet_pool_name=None, developer_org_name=None, cloudlet_pool_org_name=None, json_data=None, use_defaults=False, auto_delete=True, use_thread=False):
        return self.cloudlet_pool_access.show_cloudlet_pool_access_pending(token=token, region=region, cloudlet_pool_name=cloudlet_pool_name, developer_org_name=developer_org_name, cloudlet_pool_org_name=cloudlet_pool_org_name, json_data=json_data, use_defaults=use_defaults, auto_delete=auto_delete, use_thread=use_thread)

    def show_cloudlet_pool_access_response(self, token=None, region=None, cloudlet_pool_name=None, developer_org_name=None, cloudlet_pool_org_name=None, json_data=None, use_defaults=False, auto_delete=True, use_thread=False):
        return self.cloudlet_pool_access.show_cloudlet_pool_access_response(token=token, region=region, cloudlet_pool_name=cloudlet_pool_name, developer_org_name=developer_org_name, cloudlet_pool_org_name=cloudlet_pool_org_name, json_data=json_data, use_defaults=use_defaults, auto_delete=auto_delete, use_thread=use_thread)

    def show_cloudlet_pool_access_invitation(self, token=None, region=None, cloudlet_pool_name=None, developer_org_name=None, cloudlet_pool_org_name=None, json_data=None, use_defaults=False, auto_delete=True, use_thread=False):
        return self.cloudlet_pool_access.show_cloudlet_pool_access_invitation(token=token, region=region, cloudlet_pool_name=cloudlet_pool_name, developer_org_name=developer_org_name, cloudlet_pool_org_name=cloudlet_pool_org_name, json_data=json_data, use_defaults=use_defaults, auto_delete=auto_delete, use_thread=use_thread)

    def get_public_cloudlets(self, region=None):
        all_cloudlets = self.show_cloudlets(token=self.super_token, region=region, use_defaults=False)
        all_pools = self.show_cloudlet_pool(token=self.super_token, region=region, use_defaults=False)

        pool_cloudlet_list = []
        if 'data' in all_pools:
            if 'cloudlets' in all_pools['data']:
                for cloudlet in all_pools['data']['cloudlets']:
                    pool_cloudlet_list.append(cloudlet)
        else:
            for pool in all_pools:
                if 'cloudlets' in pool['data']:
                    for cloudlet in pool['data']['cloudlets']:
                        pool_cloudlet_list.append(cloudlet)
        logging.debug(f'cloudlets in a pool={pool_cloudlet_list}')

        public_cloudlet_list = []
        for cloudlet in all_cloudlets:
            if cloudlet['data']['key']['name'] not in pool_cloudlet_list:
                logging.debug(cloudlet['data']['key']['name'] + ' IS a public cloudlet')
                public_cloudlet_list.append(cloudlet)
            else:
                logging.debug(cloudlet['data']['key']['name'] + ' is NOT a public cloudlet')

        return public_cloudlet_list
    
    def create_vm_pool(self, token=None, region=None, vm_pool_name=None, org_name=None, vm_list=[], json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        return self.vm_pool.create_vm_pool(token=token, region=region, vm_pool_name=vm_pool_name, organization=org_name, vm_list=vm_list, json_data=json_data, use_defaults=use_defaults, auto_delete=auto_delete, use_thread=use_thread)

    def show_vm_pool(self, token=None, region=None, vm_pool_name=None, org_name=None, json_data=None, use_defaults=True, use_thread=False):
        return self.vm_pool.show_vm_pool(token=token, region=region, vm_pool_name=vm_pool_name, organization=org_name, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def delete_vm_pool(self, token=None, region=None, vm_pool_name=None, org_name=None, json_data=None, use_defaults=True, use_thread=False):
        return self.vm_pool.delete_vm_pool(token=token, region=region, vm_pool_name=vm_pool_name, organization=org_name, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def update_vm_pool(self, token=None, region=None, vm_pool_name=None, org_name=None, vm_list=None, json_data=None, use_defaults=True, use_thread=False):
        return self.vm_pool.update_vm_pool(token=token, region=region, vm_pool_name=vm_pool_name, organization=org_name, vm_list=vm_list, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def add_vm_pool_member(self, token=None, region=None, vm_pool_name=None, org_name=None, vm_name=None, external_ip=None, internal_ip=None, json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        return self.vm_pool.add_vm_pool_member(token=token, region=region, vm_pool_name=vm_pool_name, organization=org_name, vm_name=vm_name, external_ip=external_ip, internal_ip=internal_ip, json_data=json_data, use_defaults=use_defaults, auto_delete=auto_delete, use_thread=use_thread)

    def remove_vm_pool_member(self, token=None, region=None, vm_pool_name=None, org_name=None, vm_name=None, json_data=None, use_defaults=True, use_thread=False):
        return self.vm_pool.remove_vm_pool_member(token=token, region=region, vm_pool_name=vm_pool_name, organization=org_name, vm_name=vm_name, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def vm_should_be_in_use(self, token=None, region=None, vm_pool_name=None, org_name=None, group_name=None, internal_name=None):
        return self.vm_pool.vm_should_be_in_use(token=token, region=region, vm_pool_name=vm_pool_name, organization=org_name, group_name=group_name, internal_name=internal_name)

    def vm_should_not_be_in_use(self, token=None, region=None, vm_pool_name=None, org_name=None, vm_name=None):
        return self.vm_pool.vm_should_not_be_in_use(token=token, region=region, vm_pool_name=vm_pool_name, organization=org_name, vm_name=vm_name)

    def create_trust_policy(self, token=None, region=None, policy_name=None, operator_org_name=None, rule_list=[], json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        return self.trust_policy.create_trust_policy(token=token, region=region, policy_name=policy_name, operator_org_name=operator_org_name, rule_list=rule_list, json_data=json_data, use_defaults=use_defaults, auto_delete=auto_delete, use_thread=use_thread)

    def show_trust_policy(self, token=None, region=None, policy_name=None, operator_org_name=None, json_data=None, use_defaults=True, use_thread=False):
        return self.trust_policy.show_trust_policy(token=token, region=region, policy_name=policy_name, operator_org_name=operator_org_name, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def delete_trust_policy(self, token=None, region=None, policy_name=None, operator_org_name=None, rule_list=[], json_data=None, use_defaults=True, use_thread=False):
        return self.trust_policy.delete_trust_policy(token=token, region=region, policy_name=policy_name, operator_org_name=operator_org_name, rule_list=rule_list, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def update_trust_policy(self, token=None, region=None, policy_name=None, operator_org_name=None, rule_list=[], json_data=None, use_defaults=True, use_thread=False):
        return self.trust_policy.update_trust_policy(token=token, region=region, policy_name=policy_name, operator_org_name=operator_org_name, rule_list=rule_list, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def create_trust_policy_exception(self, token=None, region=None, policy_name=None, app_name=None, developer_org_name=None, app_version=None, cloudlet_pool_name=None, cloudlet_pool_org_name=None, rule_list=[], state=None, json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        return self.trust_policy.create_trust_policy_exception(token=token, region=region, policy_name=policy_name, app_name=app_name, developer_org_name=developer_org_name, app_version=app_version, cloudlet_pool_name=cloudlet_pool_name, cloudlet_pool_org_name=cloudlet_pool_org_name, rule_list=rule_list, state=state, json_data=json_data, use_defaults=use_defaults, auto_delete=auto_delete, use_thread=use_thread)

    def show_trust_policy_exception(self, token=None, region=None, policy_name=None, app_name=None, developer_org_name=None, app_version=None, cloudlet_pool_name=None, cloudlet_pool_org_name=None, json_data=None, use_defaults=True, use_thread=False):
        return self.trust_policy.show_trust_policy_exception(token=token, region=region, policy_name=policy_name, app_name=app_name, developer_org_name=developer_org_name, app_version=app_version, cloudlet_pool_name=cloudlet_pool_name, cloudlet_pool_org_name=cloudlet_pool_org_name, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def delete_trust_policy_exception(self, token=None, region=None, policy_name=None, app_name=None, developer_org_name=None, app_version=None, cloudlet_pool_name=None, cloudlet_pool_org_name=None, rule_list=[], json_data=None, use_defaults=True, use_thread=False):
        return self.trust_policy.delete_trust_policy_exception(token=token, region=region, policy_name=policy_name, app_name=app_name, developer_org_name=developer_org_name, app_version=app_version, cloudlet_pool_name=cloudlet_pool_name, cloudlet_pool_org_name=cloudlet_pool_org_name, rule_list=rule_list, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def update_trust_policy_exception(self, token=None, region=None, policy_name=None, app_name=None, developer_org_name=None, app_version=None, cloudlet_pool_name=None, cloudlet_pool_org_name=None, rule_list=[], state=None, json_data=None, use_defaults=True, use_thread=False):
        return self.trust_policy.update_trust_policy_exception(token=token, region=region, policy_name=policy_name, app_name=app_name, developer_org_name=developer_org_name, app_version=app_version, cloudlet_pool_name=cloudlet_pool_name, cloudlet_pool_org_name=cloudlet_pool_org_name, rule_list=rule_list, state=state, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def create_alert_receiver(self, token=None, region=None, receiver_name=None, type=None, severity=None, email_address=None, pagerduty_integration_key=None, slack_channel=None, slack_api_url=None, app_name=None, app_version=None, app_cloudlet_name=None, app_cloudlet_org=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        return self.alert_receiver.create_alert_receiver(token=token, region=region, receiver_name=receiver_name, type=type, severity=severity, email_address=email_address, pagerduty_integration_key=pagerduty_integration_key, slack_channel=slack_channel, slack_api_url=slack_api_url, app_name=app_name, app_version=app_version, app_cloudlet_name=app_cloudlet_name, app_cloudlet_org=app_cloudlet_org, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name,  developer_org_name=developer_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, json_data=json_data, use_defaults=use_defaults, auto_delete=auto_delete, use_thread=use_thread)

    def show_alert_receivers(self, token=None, receiver_name=None, type=None, severity=None, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, user=None, json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        return self.alert_receiver.show_alert_receiver(token=token, receiver_name=receiver_name, type=type, severity=severity, app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name,  developer_org_name=developer_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, user=user, json_data=json_data, use_defaults=use_defaults, auto_delete=auto_delete, use_thread=use_thread)

    def delete_alert_receiver(self, token=None, receiver_name=None, type=None, severity=None, user=None, developer_org_name=None, json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        return self.alert_receiver.delete_alert_receiver(token=token, receiver_name=receiver_name, type=type, severity=severity, user=user, developer_org_name=developer_org_name, json_data=json_data, use_defaults=use_defaults, auto_delete=auto_delete, use_thread=use_thread)
    
    def show_alerts(self, token=None, alert_name=None, region=None, app_name=None,  app_version=None,  developer_org_name=None, cloudlet_name=None, operator_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, port=None, scope=None, warning=None, description=None, json_data=None, use_defaults=True, use_thread=False):
        return self.alert.show_alert(token=token, alert_name=alert_name, region=region, app_name=app_name, app_version=app_version, developer_org_name=developer_org_name, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, port=port, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, scope=scope, warning=warning, description=description, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def create_auto_provisioning_policy(self, token=None, region=None, policy_name=None, developer_org_name=None, deploy_client_count=None, deploy_interval_count=None,undeploy_client_count=None, undeploy_interval_count=None, min_active_instances=None, max_instances=None, cloudlet_list=[], json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        return self.autoprov_policy.create_autoprov_policy(token=token, region=region, policy_name=policy_name, developer_org_name=developer_org_name, deploy_client_count=deploy_client_count, deploy_interval_count=deploy_interval_count,undeploy_client_count=undeploy_client_count, undeploy_interval_count=undeploy_interval_count, min_active_instances=min_active_instances, max_instances=max_instances, cloudlet_list=cloudlet_list, json_data=json_data, use_defaults=use_defaults, auto_delete=auto_delete, use_thread=use_thread)

    def show_auto_provisioning_policy(self, token=None, region=None, policy_name=None, developer_org_name=None, json_data=None, use_defaults=True, use_thread=False):
        return self.autoprov_policy.show_autoprov_policy(token=token, region=region, policy_name=policy_name, developer_org_name=developer_org_name, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def delete_auto_provisioning_policy(self, token=None, region=None, policy_name=None, developer_org_name=None, json_data=None, use_defaults=True, use_thread=False):
        return self.autoprov_policy.delete_autoprov_policy(token=token, region=region, policy_name=policy_name, developer_org_name=developer_org_name, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def delete_all_auto_provisioning_policies(self, region, cloudlet_name, crm_override=None):
        policies = self.show_auto_provisioning_policy(token=self.token, region=region, use_defaults=False)
        for policy in policies:
            if 'cloudlets' in policy['data']:
                for cloudlet in policy['data']['cloudlets']:
                    if cloudlet['key']['name'] == cloudlet_name:
                        logging.info(f'deleting {policy}')
                        try:
                            self.delete_auto_provisioning_policy(token=self.token, region=region, policy_name=policy['data']['key']['name'], developer_org_name=policy['data']['key']['organization'], use_defaults=False)
                        except Exception as e:
                           if 'in use by App' in str(e):
                               error_split = str(e).split(' App ')
                               error_dict = json.loads(error_split[1][:-4].replace('\\', ''))
                               logging.info(f'deleting app {error_dict}')
                               self.delete_app(token=self.token, region=region, app_name=error_dict['name'], developer_org_name=error_dict['organization'], app_version=error_dict['version'], use_defaults=False)
                               self.delete_auto_provisioning_policy(token=self.token, region=region, policy_name=policy['data']['key']['name'], developer_org_name=policy['data']['key']['organization'], use_defaults=False)

    def update_auto_provisioning_policy(self, token=None, region=None, policy_name=None, developer_org_name=None, deploy_client_count=None, deploy_interval_count=None, undeploy_client_count=None, undeploy_interval_count=None, min_active_instances=None, max_instances=None, cloudlet_list=None, json_data=None, use_defaults=True, use_thread=False):
        return self.autoprov_policy.update_autoprov_policy(token=token, region=region, policy_name=policy_name, developer_org_name=developer_org_name, deploy_client_count=deploy_client_count, deploy_interval_count=deploy_interval_count, undeploy_client_count=undeploy_client_count, undeploy_interval_count=undeploy_interval_count, min_active_instances=min_active_instances, max_instances=max_instances, cloudlet_list=cloudlet_list, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def add_auto_provisioning_policy_cloudlet(self, token=None, region=None, policy_name=None, developer_org_name=None, cloudlet_name=None, operator_org_name=None, json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        return self.autoprov_policy.add_autoprov_policy_cloudlet(token=token, region=region, policy_name=policy_name, developer_org_name=developer_org_name, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, json_data=json_data, use_defaults=use_defaults, auto_delete=auto_delete, use_thread=use_thread)

    def remove_auto_provisioning_policy_cloudlet(self, token=None, region=None, policy_name=None, developer_org_name=None, cloudlet_name=None, operator_org_name=None, json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        return self.autoprov_policy.remove_autoprov_policy_cloudlet(token=token, region=region, policy_name=policy_name, developer_org_name=developer_org_name, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, json_data=json_data, use_defaults=use_defaults, auto_delete=auto_delete, use_thread=use_thread)

    def show_device(self, token=None, region=None, unique_id=None, unique_id_type=None, first_seen_seconds=None, first_seen_nanos=None, last_seen_seconds=None, last_seen_nanos=None, notify_id=None, json_data=None, use_defaults=True, use_thread=False):
        return self.showdevice.show_device(token=token, region=region, unique_id=unique_id, unique_id_type=unique_id_type, first_seen_seconds=first_seen_seconds, first_seen_nanos=first_seen_nanos, last_seen_seconds=last_seen_seconds, last_seen_nanos=last_seen_nanos, notify_id=notify_id, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def show_device_report(self, token=None, region=None, unique_id=None, unique_id_type=None, begin_seconds=None, begin_nanos=None, end_seconds=None, end_nanos=None, notify_id=None, json_data=None, use_defaults=True, use_thread=False):
        return self.showdevicereport.show_device_report(token=token, region=region, unique_id=unique_id, unique_id_type=unique_id_type, begin_seconds=begin_seconds, begin_nanos=begin_nanos, end_seconds=end_seconds, end_nanos=end_nanos, notify_id=notify_id, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def run_debug(self, timeout=None, node_name=None, node_type=None, region=None, cloudlet_name=None, operator_org_name=None, args=None, command=None, pretty=None, token=None, json_data=None, use_defaults=True, use_thread=False):
        return self.rundebug.run_debug(timeout=timeout, node_name=node_name, node_type=node_type, region=region, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, args=args, command=command, pretty=pretty, token=token, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def access_cloudlet(self, region=None, node_name=None, node_type=None, cloudlet_name=None, operator_org_name=None, command=None, token=None, json_data=None, use_defaults=True, use_thread=False):
        return self.run_cmd.access_cloudlet(node_name=node_name, node_type=node_type, region=region, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, command=command, token=token, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread)

    def show_config(self, token=None, use_defaults=True, use_thread=False):
        if token is None:
            token=self.super_token
        return self.config.show_config(token=token, use_defaults=use_defaults, use_thread=use_thread)

    def skip_verify_email(self, skip_verify_email=True, token=None, use_defaults=True, use_thread=False):
        if token is None:
            token=self.super_token
        return self.config.update_config(token=token, skip_verify_email=skip_verify_email, use_defaults=use_defaults, use_thread=use_thread)

    def billing_enable(self, billing_enable=True, token=None, use_defaults=True, use_thread=False):
        if token is None:
            token=self.super_token
        return self.config.update_config(token=token, billing_enable=billing_enable, use_defaults=use_defaults, use_thread=use_thread)

    def set_skip_verify_email(self, skip_verify_email=True, token=None, use_defaults=True, use_thread=False):
        if token is None:
            token=self.super_token
        return self.config.update_config(token=token, skip_verify_email=skip_verify_email, use_defaults=use_defaults, use_thread=use_thread)

    def set_lock_accounts_config(self, lock_accounts=True, token=None, use_defaults=True, use_thread=False):
        if token is None:
            token=self.super_token
        return self.config.update_config(token=token, lock_accounts = lock_accounts, use_defaults=use_defaults, use_thread=use_thread)

    def set_notify_email_config(self, notify_email=None, token=None, use_defaults=True, use_thread=False):
        if token is None:
            token=self.super_token
        return self.config.update_config(token=token, notify_email= notify_email, use_defaults=use_defaults, use_thread=use_thread)
    
    def set_user_pass_strength_config(self, user_pass=None, token=None, use_defaults=True, use_thread=False):
        if token is None:
            token=self.super_token
        return self.config.update_config(token=token, user_pass = user_pass, use_defaults=use_defaults, use_thread=use_thread)
    
    def set_admin_pass_strength_config(self, admin_pass=None, token=None, use_defaults=True, use_thread=False):
        if token is None:
            token=self.super_token
        return self.config.update_config(token=token, admin_pass = admin_pass, use_defaults=use_defaults, use_thread=use_thread)

    def set_max_metrics_data_points_config(self, max_metrics_data_points=None, token=None, use_defaults=True, use_thread=False):
        if token is None:
            token=self.super_token
        return self.config.update_config(token=token, max_metrics_data_points=max_metrics_data_points, use_defaults=use_defaults, use_thread=use_thread)

    def set_apikey_limit_config(self, apikey_limit=None, token=None, use_defaults=True, use_thread=False):
        if token is None:
            token=self.super_token
        return self.config.update_config(token=token, apikey_limit=apikey_limit, use_defaults=use_defaults, use_thread=use_thread)

    def set_rate_limit_ips_config(self, rate_limit_ips=None, token=None, use_defaults=True, use_thread=False):
        if token is None:
            token=self.super_token
        return self.config.update_config(token=token, rate_limit_ips = rate_limit_ips, use_defaults=use_defaults, use_thread=use_thread)

    def set_rate_limit_users_config(self, rate_limit_users=None, token=None, use_defaults=True, use_thread=False):
        if token is None:
            token=self.super_token
        return self.config.update_config(token=token, rate_limit_users = rate_limit_users, use_defaults=use_defaults, use_thread=use_thread)

    def set_fail_threshold1_config(self, fail_threshold1=None, token=None, use_defaults=True, use_thread=False):
        if token is None:
            token=self.super_token
        return self.config.update_config(token=token, fail_threshold1 = fail_threshold1, use_defaults=use_defaults, use_thread=use_thread)

    def set_threshold1_delay_config(self, threshold1_delay=None, token=None, use_defaults=True, use_thread=False):
        if token is None:
            token=self.super_token
        return self.config.update_config(token=token, threshold1_delay = threshold1_delay, use_defaults=use_defaults, use_thread=use_thread)

    def set_fail_threshold2_config(self, fail_threshold2=None, token=None, use_defaults=True, use_thread=False):
        if token is None:
            token=self.super_token
        return self.config.update_config(token=token, fail_threshold2 = fail_threshold2, use_defaults=use_defaults, use_thread=use_thread)

    def set_threshold2_delay_config(self, threshold2_delay=None, token=None, use_defaults=True, use_thread=False):
        if token is None:
            token=self.super_token
        return self.config.update_config(token=token, threshold2_delay = threshold2_delay, use_defaults=use_defaults, use_thread=use_thread)

    
    def update_cluster_instance(self, token=None, region=None, cluster_name=None, operator_org_name=None, cloudlet_name=None, developer_org_name=None, flavor_name=None, liveness=None, ip_access=None, crm_override=None, number_masters=None, number_nodes=None, autoscale_policy_name=None, reservation_ended_at_seconds=None, reservation_ended_at_nanoseconds=None, timeout=None, json_data=None, use_defaults=True, use_thread=False): 
        if developer_org_name is None:
            if self.organization_name:
                developer_org_name = self.organization_name
                cluster_instance_developer_name = self.organization_name
        return self.cluster_instance.update_cluster_instance(token=token, region=region, cluster_name=cluster_name, operator_org_name=operator_org_name, cloudlet_name=cloudlet_name, developer_org_name=developer_org_name, number_masters=number_masters, number_nodes=number_nodes, autoscale_policy_name=autoscale_policy_name, reservation_ended_at_seconds=reservation_ended_at_seconds, reservation_ended_at_nanoseconds=reservation_ended_at_nanoseconds, stream_timeout=timeout, use_defaults=use_defaults)

    def update_app_instance(self, token=None, region=None, appinst_id = None, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, flavor_name=None, config=None, uri=None, privacy_policy=None, shared_volume_size=None, crm_override=None, powerstate=None, configs_kind=None, configs_config=None, json_data=None, use_defaults=True, use_thread=False):
        return self.app_instance.update_app_instance(token=token, region=region, appinst_id=appinst_id, app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, developer_org_name=developer_org_name, flavor_name=flavor_name, config=config, uri=uri, privacy_policy=privacy_policy, shared_volume_size=shared_volume_size, crm_override=crm_override, powerstate=powerstate, configs_kind=configs_kind, configs_config=configs_config, use_defaults=use_defaults, use_thread=use_thread)

    def refresh_app_instance(self, token=None, region=None, appinst_id = None, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, flavor_name=None, config=None, uri=None, privacy_policy=None, shared_volume_size=None, crm_override=None, powerstate=None, configs_kind=None, configs_config=None, json_data=None, use_defaults=True, use_thread=False):
        return self.app_instance.refresh_app_instance(token=token, region=region, appinst_id=appinst_id, app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, developer_org_name=developer_org_name, flavor_name=flavor_name, config=config, uri=uri, privacy_policy=privacy_policy, shared_volume_size=shared_volume_size, crm_override=crm_override, powerstate=powerstate, configs_kind=configs_kind, configs_config=configs_config, use_defaults=use_defaults, use_thread=use_thread)

    def stream_cloudlet(self, token=None, region=None, cloudlet_name=None, operator_org_name=None, json_data=None, use_defaults=True, use_thread=False):
        return self.stream.stream_cloudlet(token=token, region=region, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, use_defaults=use_defaults, use_thread=use_thread)

    def stream_cluster_instance(self, token=None, region=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, cloudlet_name=None, operator_org_name=None, json_data=None, use_defaults=True, use_thread=False):
        return self.stream.stream_clusterinst(token=token, region=region, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, use_defaults=use_defaults, use_thread=use_thread)

    def stream_app_instance(self, token=None, region=None, app_name=None, app_version=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, cloudlet_name=None, operator_org_name=None, json_data=None, use_defaults=True, use_thread=False):
        return self.stream.stream_appinst(token=token, region=region, app_name=app_name, app_version=app_version, developer_org_name=None, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, use_defaults=use_defaults, use_thread=use_thread)

    def show_settings(self, token=None, region=None, json_data=None, use_defaults=True, use_thread=False):
        return self.settings.show_settings(token=token, region=region, use_defaults=use_defaults, use_thread=use_thread)
      
    def update_settings(self, token=None, region=None, shepherd_metrics_collection_interval=None, shepherd_alert_evaluation_interval=None, shepherd_health_check_retries=None, shepherd_health_check_interval=None, shepherd_metrics_scrape_interval=None, auto_deploy_interval_sec=None, auto_deploy_offset_sec=None, auto_deploy_max_intervals=None, create_cloudlet_timeout=None, update_cloudlet_timeout=None, create_app_inst_timeout=None, update_app_inst_timeout=None, delete_app_inst_timeout=None, create_cluster_inst_timeout=None, update_cluster_inst_timeout=None, delete_cluster_inst_timeout=None, master_node_flavor=None, load_balancer_max_port_range=None, max_tracked_dme_clients=None, chef_client_interval=None, influx_db_cloudlet_usage_metrics_retention=None, influx_db_metrics_retention=None, influx_db_downsampled_metrics_retention=None, influx_db_edge_events_metrics_retention=None, cloudlet_maintenance_timeout=None, update_vm_pool_timeout=None, update_trust_policy_timeout=None, dme_api_metrics_collection_interval=None, edge_events_metrics_collection_interval=None, edge_events_metrics_continuous_queries_collection_intervals=[], cleanup_reservable_auto_cluster_idletime=None, location_tile_side_length_km=None, appinst_client_cleanup_interval=None, cluster_auto_scale_averaging_duration_sec=None, cluster_auto_scale_retry_delay=None, alert_policy_min_trigger_time=None, disable_rate_limit=None, rate_limit_max_tracked_ips=None, resource_snapshot_thread_interval=None, json_data=None, use_defaults=True, use_thread=False):
        return self.settings.update_settings(token=token, region=region, use_defaults=use_defaults, use_thread=use_thread, shepherd_metrics_collection_interval=shepherd_metrics_collection_interval, shepherd_alert_evaluation_interval=shepherd_alert_evaluation_interval, shepherd_health_check_retries=shepherd_health_check_retries, shepherd_health_check_interval=shepherd_health_check_interval, shepherd_metrics_scrape_interval=shepherd_metrics_scrape_interval, auto_deploy_interval_sec=auto_deploy_interval_sec, auto_deploy_offset_sec=auto_deploy_offset_sec, auto_deploy_max_intervals=auto_deploy_max_intervals, create_cloudlet_timeout=create_cloudlet_timeout, update_cloudlet_timeout=update_cloudlet_timeout, create_app_inst_timeout=create_app_inst_timeout, update_app_inst_timeout=update_app_inst_timeout, delete_app_inst_timeout=delete_app_inst_timeout, create_cluster_inst_timeout=create_cluster_inst_timeout, update_cluster_inst_timeout=update_cluster_inst_timeout, delete_cluster_inst_timeout=delete_cluster_inst_timeout, master_node_flavor=master_node_flavor, load_balancer_max_port_range=load_balancer_max_port_range, max_tracked_dme_clients=max_tracked_dme_clients, chef_client_interval=chef_client_interval, influx_db_metrics_retention=influx_db_metrics_retention, influx_db_cloudlet_usage_metrics_retention=influx_db_cloudlet_usage_metrics_retention, influx_db_downsampled_metrics_retention=influx_db_downsampled_metrics_retention, influx_db_edge_events_metrics_retention=influx_db_edge_events_metrics_retention, cloudlet_maintenance_timeout=cloudlet_maintenance_timeout, update_vm_pool_timeout=update_vm_pool_timeout, update_trust_policy_timeout=update_trust_policy_timeout, dme_api_metrics_collection_interval=dme_api_metrics_collection_interval, edge_events_metrics_collection_interval=edge_events_metrics_collection_interval, edge_events_metrics_continuous_queries_collection_intervals=edge_events_metrics_continuous_queries_collection_intervals, cleanup_reservable_auto_cluster_idletime=cleanup_reservable_auto_cluster_idletime, location_tile_side_length_km=location_tile_side_length_km, appinst_client_cleanup_interval=appinst_client_cleanup_interval, cluster_auto_scale_averaging_duration_sec=cluster_auto_scale_averaging_duration_sec, cluster_auto_scale_retry_delay=cluster_auto_scale_retry_delay, alert_policy_min_trigger_time=alert_policy_min_trigger_time, disable_rate_limit=disable_rate_limit, rate_limit_max_tracked_ips=rate_limit_max_tracked_ips, resource_snapshot_thread_interval=resource_snapshot_thread_interval)

    def restrictedorg_update(self, token=None, org_name=None, edgeboxonly=False, json_data=None, use_defaults=True, use_thread=False):
        if token is None:
            token=self.super_token

        return self.restricted_org_update.update_org(token=token, org_name=org_name, edgeboxonly=edgeboxonly, use_defaults=use_defaults, use_thread=use_thread)
 
    def reset_settings(self, token=None, region=None, json_data=None, use_defaults=True, use_thread=False):
        return self.settings.reset_settings(token=token, region=region, use_defaults=use_defaults, use_thread=use_thread)

    def request_app_instance_latency(self, token=None, region=None, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, json_data=None, use_defaults=True, use_thread=False):
        return self.request_appinst_latency.request_appinst_latency(token=token, region=region, app_name=app_name, app_version=app_version, developer_org_name=developer_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, use_defaults=use_defaults, use_thread=use_thread)
    
    def create_gpudriver(self, token=None, region=None, gpudriver_name=None, gpudriver_org=None, builds_dict={}, license_config=None, properties={}, use_defaults=True, use_thread=False, auto_delete=True):
        return self.gpudriver.create_gpudriver(token=token, region=region, gpudriver_name=gpudriver_name, gpudriver_org=gpudriver_org, builds_dict=builds_dict, license_config=license_config, properties=properties, use_defaults=use_defaults, use_thread=use_thread, auto_delete=auto_delete)

    def update_gpudriver(self, token=None, region=None, gpudriver_name=None, gpudriver_org=None, license_config=None, properties={}, use_defaults=True, use_thread=False):
        return self.gpudriver.update_gpudriver(token=token, region=region, gpudriver_name=gpudriver_name, gpudriver_org=gpudriver_org, license_config=license_config, properties=properties, use_defaults=use_defaults, use_thread=use_thread)

    def delete_gpudriver(self, token=None, region=None, gpudriver_name=None, gpudriver_org=None, use_defaults=True, use_thread=False):
        return self.gpudriver.delete_gpudriver(token=token, region=region, gpudriver_name=gpudriver_name, gpudriver_org=gpudriver_org, use_defaults=use_defaults, use_thread=use_thread)

    def show_gpudriver(self, token=None, region=None, gpudriver_name=None, gpudriver_org=None, properties={}, use_defaults=True, use_thread=False):
        return self.gpudriver.show_gpudriver(token=token, region=region, gpudriver_name=gpudriver_name, gpudriver_org=gpudriver_org, properties=properties, use_defaults=use_defaults, use_thread=use_thread)

    def addbuild_gpudriver(self, token=None, region=None, gpudriver_name=None, gpudriver_org=None, build_name=None, build_driverpath=None, build_os=None, build_md5sum=None, build_driverpathcreds=None, build_kernelversion=None, build_hypervisorinfo=None, ignorestate=None, use_defaults=True, use_thread=False):
        return self.gpudriver.addbuild_gpudriver(token=token, region=region, gpudriver_name=gpudriver_name, gpudriver_org=gpudriver_org, build_name=build_name, build_driverpath=build_driverpath, build_os=build_os, build_md5sum=build_md5sum, build_driverpathcreds=build_driverpathcreds, build_kernelversion=build_kernelversion, build_hypervisorinfo=build_hypervisorinfo, ignorestate=ignorestate, use_defaults=use_defaults, use_thread=use_thread)

    def removebuild_gpudriver(self, token=None, region=None, gpudriver_name=None, gpudriver_org=None, build_name=None, use_defaults=True, use_thread=False):
        return self.gpudriver.removebuild_gpudriver(token=token, region=region, gpudriver_name=gpudriver_name, gpudriver_org=gpudriver_org, build_name=build_name, use_defaults=use_defaults, use_thread=use_thread)

    def getbuildurl_gpudriver(self, token=None, region=None, gpudriver_name=None, gpudriver_org=None, build_name=None, use_defaults=True, use_thread=False):
        return self.gpudriver.getbuildurl_gpudriver(token=token, region=region, gpudriver_name=gpudriver_name, gpudriver_org=gpudriver_org, build_name=build_name, use_defaults=use_defaults, use_thread=use_thread)

    def show_rate_limit_settings(self, token=None, region=None, flow_settings_name=None, api_name=None, api_endpoint_type=None, rate_limit_target=None, flow_algorithm=None, requests_per_second=None, burst_size=None, use_defaults=True, use_thread=False):
        return self.ratelimitsettings.show_rate_limit_settings(token=token, region=region, flow_settings_name=flow_settings_name, api_name=api_name, api_endpoint_type=api_endpoint_type, rate_limit_target=rate_limit_target, flow_algorithm=flow_algorithm, requests_per_second=requests_per_second, burst_size=burst_size, use_defaults=use_defaults, use_thread=use_thread)

    def create_rate_limit_flow(self, token=None, region=None, flow_settings_name=None, api_name=None, api_endpoint_type=None, rate_limit_target=None, flow_algorithm=None, requests_per_second=None, burst_size=None, use_defaults=True, use_thread=False):
        return self.ratelimitsettings.create_rate_limit_flow(token=token, region=region, flow_settings_name=flow_settings_name, api_name=api_name, api_endpoint_type=api_endpoint_type, rate_limit_target=rate_limit_target, flow_algorithm=flow_algorithm, requests_per_second=requests_per_second, burst_size=burst_size, use_defaults=use_defaults, use_thread=use_thread)

    def show_rate_limit_flow(self, token=None, region=None, flow_settings_name=None, api_name=None, api_endpoint_type=None, rate_limit_target=None, flow_algorithm=None, requests_per_second=None, burst_size=None, use_defaults=True, use_thread=False):
        return self.ratelimitsettings.show_rate_limit_flow(token=token, region=region, flow_settings_name=flow_settings_name, api_name=api_name, api_endpoint_type=api_endpoint_type, rate_limit_target=rate_limit_target, flow_algorithm=flow_algorithm, requests_per_second=requests_per_second, burst_size=burst_size, use_defaults=use_defaults, use_thread=use_thread)

    def delete_rate_limit_flow(self, token=None, region=None, flow_settings_name=None, api_name=None, api_endpoint_type=None, rate_limit_target=None, flow_algorithm=None, requests_per_second=None, burst_size=None, use_defaults=True, use_thread=False):
        return self.ratelimitsettings.delete_rate_limit_flow(token=token, region=region, flow_settings_name=flow_settings_name, api_name=api_name, api_endpoint_type=api_endpoint_type, rate_limit_target=rate_limit_target, flow_algorithm=flow_algorithm, requests_per_second=requests_per_second, burst_size=burst_size, use_defaults=use_defaults, use_thread=use_thread)

    def update_rate_limit_flow(self, token=None, region=None, flow_settings_name=None, api_name=None, api_endpoint_type=None, rate_limit_target=None, flow_algorithm=None, requests_per_second=None, burst_size=None, use_defaults=True, use_thread=False):
        return self.ratelimitsettings.update_rate_limit_flow(token=token, region=region, flow_settings_name=flow_settings_name, api_name=api_name, api_endpoint_type=api_endpoint_type, rate_limit_target=rate_limit_target, flow_algorithm=flow_algorithm, requests_per_second=requests_per_second, burst_size=burst_size, use_defaults=use_defaults, use_thread=use_thread)

    def create_rate_limit_max_requests(self, token=None, region=None, max_requests_settings_name=None, api_name=None, api_endpoint_type=None, rate_limit_target=None, max_requests_algorithm=None, max_requests=None, interval=None, use_defaults=True, use_thread=False):
        return self.ratelimitsettings.create_rate_limit_max_requests(token=token, region=region, max_requests_settings_name=max_requests_settings_name, api_name=api_name, api_endpoint_type=api_endpoint_type, rate_limit_target=rate_limit_target, max_requests_algorithm=max_requests_algorithm, max_requests=max_requests, interval=interval, use_defaults=use_defaults, use_thread=use_thread)

    def show_rate_limit_max_requests(self, token=None, region=None, max_requests_settings_name=None, api_name=None, api_endpoint_type=None, rate_limit_target=None, max_requests_algorithm=None, max_requests=None, interval=None, use_defaults=True, use_thread=False):
        return self.ratelimitsettings.show_rate_limit_max_requests(token=token, region=region, max_requests_settings_name=max_requests_settings_name, api_name=api_name, api_endpoint_type=api_endpoint_type, rate_limit_target=rate_limit_target, max_requests_algorithm=max_requests_algorithm, max_requests=max_requests, interval=interval, use_defaults=use_defaults, use_thread=use_thread)

    def delete_rate_limit_max_requests(self, token=None, region=None, max_requests_settings_name=None, api_name=None, api_endpoint_type=None, rate_limit_target=None, max_requests_algorithm=None, max_requests=None, interval=None, use_defaults=True, use_thread=False):
        return self.ratelimitsettings.delete_rate_limit_max_requests(token=token, region=region, max_requests_settings_name=max_requests_settings_name, api_name=api_name, api_endpoint_type=api_endpoint_type, rate_limit_target=rate_limit_target, max_requests_algorithm=max_requests_algorithm, max_requests=max_requests, interval=interval, use_defaults=use_defaults, use_thread=use_thread)

    def update_rate_limit_max_requests(self, token=None, region=None, max_requests_settings_name=None, api_name=None, api_endpoint_type=None, rate_limit_target=None, max_requests_algorithm=None, max_requests=None, interval=None, use_defaults=True, use_thread=False):
        return self.ratelimitsettings.update_rate_limit_max_requests(token=token, region=region, max_requests_settings_name=max_requests_settings_name, api_name=api_name, api_endpoint_type=api_endpoint_type, rate_limit_target=rate_limit_target, max_requests_algorithm=max_requests_algorithm, max_requests=max_requests, interval=interval, use_defaults=use_defaults, use_thread=use_thread)

    def create_mc_rate_limit_flow(self, token=None, flow_settings_name=None, api_name=None, rate_limit_target=None, flow_algorithm=None, requests_per_second=None, burst_size=None, use_defaults=True, use_thread=False):
        return self.ratelimitsettings.create_mc_rate_limit_flow(token=token, flow_settings_name=flow_settings_name, api_name=api_name, rate_limit_target=rate_limit_target, flow_algorithm=flow_algorithm, requests_per_second=requests_per_second, burst_size=burst_size, use_defaults=use_defaults, use_thread=use_thread)

    def show_mc_rate_limit_flow(self, token=None, flow_settings_name=None, api_name=None, rate_limit_target=None, flow_algorithm=None, requests_per_second=None, burst_size=None, use_defaults=True, use_thread=False):
        return self.ratelimitsettings.show_mc_rate_limit_flow(token=token, flow_settings_name=flow_settings_name, api_name=api_name, rate_limit_target=rate_limit_target, flow_algorithm=flow_algorithm, requests_per_second=requests_per_second, burst_size=burst_size, use_defaults=use_defaults, use_thread=use_thread)

    def delete_mc_rate_limit_flow(self, token=None, flow_settings_name=None, api_name=None, rate_limit_target=None, flow_algorithm=None, requests_per_second=None, burst_size=None, use_defaults=True, use_thread=False):
        return self.ratelimitsettings.delete_mc_rate_limit_flow(token=token, flow_settings_name=flow_settings_name, api_name=api_name, rate_limit_target=rate_limit_target, flow_algorithm=flow_algorithm, requests_per_second=requests_per_second, burst_size=burst_size, use_defaults=use_defaults, use_thread=use_thread)

    def update_mc_rate_limit_flow(self, token=None, flow_settings_name=None, api_name=None, rate_limit_target=None, flow_algorithm=None, requests_per_second=None, burst_size=None, use_defaults=True, use_thread=False):
        return self.ratelimitsettings.update_mc_rate_limit_flow(token=token, flow_settings_name=flow_settings_name, api_name=api_name, rate_limit_target=rate_limit_target, flow_algorithm=flow_algorithm, requests_per_second=requests_per_second, burst_size=burst_size, use_defaults=use_defaults, use_thread=use_thread)
 
    def create_alert_policy(self, token=None, region=None, alertpolicy_name=None, alert_org=None, severity=None, cpu_utilization=None, mem_utilization=None, disk_utilization=None, active_connections=None, trigger_time=None, labels_vars=None, annotations_vars=None, description=None, use_defaults=True, auto_delete=True):
        return self.alert_policy.create_alert_policy(token=token, region=region, alertpolicy_name=alertpolicy_name, alert_org=alert_org, severity=severity, cpu_utilization=cpu_utilization, mem_utilization=mem_utilization, disk_utilization=disk_utilization, active_connections=active_connections, trigger_time=trigger_time, labels_vars=labels_vars, annotations_vars=annotations_vars, description=description, use_defaults=use_defaults, auto_delete=auto_delete)              

    def show_alert_policy(self, token=None, region=None, alertpolicy_name=None, alert_org=None, severity=None, cpu_utilization=None, mem_utilization=None, disk_utilization=None, active_connections=None, trigger_time=None, labels_vars=None, annotations_vars=None, description=None, use_defaults=True, auto_delete=True):
        return self.alert_policy.show_alert_policy(token=token, region=region, alertpolicy_name=alertpolicy_name, alert_org=alert_org, severity=severity, cpu_utilization=cpu_utilization, mem_utilization=mem_utilization, disk_utilization=disk_utilization, active_connections=active_connections, trigger_time=trigger_time, labels_vars=labels_vars, annotations_vars=annotations_vars, description=description, use_defaults=use_defaults, auto_delete=auto_delete)

    def delete_alert_policy(self, token=None, region=None, alertpolicy_name=None, alert_org=None, severity=None, cpu_utilization=None, mem_utilization=None, disk_utilization=None, active_connections=None, trigger_time=None, labels_vars=None, annotations_vars=None, description=None, use_defaults=True, auto_delete=True):
        return self.alert_policy.delete_alert_policy(token=token, region=region, alertpolicy_name=alertpolicy_name, alert_org=alert_org, severity=severity, cpu_utilization=cpu_utilization, mem_utilization=mem_utilization, disk_utilization=disk_utilization, active_connections=active_connections, trigger_time=trigger_time, labels_vars=labels_vars, annotations_vars=annotations_vars, description=description, use_defaults=use_defaults, auto_delete=auto_delete)

    def update_alert_policy(self, token=None, region=None, alertpolicy_name=None, alert_org=None, severity=None, cpu_utilization=None, mem_utilization=None, disk_utilization=None, active_connections=None, trigger_time=None, labels_vars=None, annotations_vars=None, description=None, use_defaults=True, auto_delete=True):
        return self.alert_policy.update_alert_policy(token=token, region=region, alertpolicy_name=alertpolicy_name, alert_org=alert_org, severity=severity, cpu_utilization=cpu_utilization, mem_utilization=mem_utilization, disk_utilization=disk_utilization, active_connections=active_connections, trigger_time=trigger_time, labels_vars=labels_vars, annotations_vars=annotations_vars, description=description, use_defaults=use_defaults, auto_delete=auto_delete)    

    def create_reporter(self, token=None, reporter_name=None, organization=None, email_address=None, schedule=None, start_schedule_date=None, timezone=None, auto_delete=True, use_defaults=True, use_thread=False):
        return self.operator_reporting.create_reporter(token=token, reporter_name=reporter_name, organization=organization, email_address=email_address, schedule=schedule, start_schedule_date=start_schedule_date, timezone=timezone, auto_delete=auto_delete, use_defaults=use_defaults, use_thread=use_thread)

    def update_reporter(self, token=None, reporter_name=None, organization=None, email_address=None, schedule=None, start_schedule_date=None, timezone=None, use_defaults=True, use_thread=False):
        return self.operator_reporting.update_reporter(token=token, reporter_name=reporter_name, organization=organization, email_address=email_address, schedule=schedule, start_schedule_date=start_schedule_date, timezone=timezone, use_defaults=use_defaults, use_thread=use_thread)

    def delete_reporter(self, token=None, reporter_name=None, organization=None, use_defaults=True, use_thread=False):
        return self.operator_reporting.delete_reporter(token=token, reporter_name=reporter_name, organization=organization, use_defaults=use_defaults, use_thread=use_thread)

    def show_reporter(self, token=None, reporter_name=None, organization=None, use_defaults=True, use_thread=False):
        return self.operator_reporting.show_reporter(token=token, reporter_name=reporter_name, organization=organization, use_defaults=use_defaults, use_thread=use_thread)

    def generate_report(self, token=None, organization=None, start_time=None, end_time=None, timezone=None, use_defaults=True, use_thread=False):
        return self.operator_reporting.generate_report(token=token, organization=organization, start_time=start_time, end_time=end_time, timezone=timezone, use_defaults=use_defaults, use_thread=use_thread)

    def show_report(self, token=None, organization=None, use_defaults=False, use_thread=False):
        return self.operator_reporting.show_report(token=token, organization=organization, use_defaults=use_defaults, use_thread=use_thread)

    def download_report(self, token=None, organization=None, filename=None, use_defaults=False, use_thread=False):
        return self.operator_reporting.download_report(token=token, organization=organization, filename=filename, use_defaults=use_defaults, use_thread=use_thread)

    def wait_for_next_schedule_date(self, token=None, reporter_name=None, organization=None, next_schedule_date=None, use_defaults=True, use_thread=False, timeout=100):
        for x in range(1, timeout):
            reporter = self.operator_reporting.show_reporter(token=token, reporter_name=reporter_name, organization=organization, use_defaults=use_defaults, use_thread=use_thread)
            if reporter:
                if reporter[0]['NextScheduleDate'] == next_schedule_date:
                    logging.info(f'Found NextScheduleDate')
                    return reporter
                else:
                    logging.debug(f'NextScheduleDate NOT found, got {reporter[0]["NextScheduleDate"]}. sleeping and trying again')
                    time.sleep(1)
            else:
                logging.debug(f'reporter is NOT found. sleeping and trying again')

        raise Exception(f'NextScheduleDate is NOT correct. Got {reporter[0]["NextScheduleDate"]} but expected {next_schedule_date}')

    def create_federator(self, token=None, region=None, operatorid=None, countrycode=None, mcc=None, mnc=[], federationid=None, use_defaults=True, use_thread=False, auto_delete=True):
        if token is None:
            token=self.super_token

        return self.federation.create_federator(token=token, region=region, operatorid=operatorid, countrycode=countrycode, mcc=mcc, mnc=mnc, federationid=federationid, use_defaults=use_defaults, use_thread=use_thread, auto_delete=auto_delete)

    def show_federator(self, token=None, operatorid=None, federationid=None, use_defaults=True, use_thread=False):
        return self.federation.show_federator(token=token, operatorid=operatorid, federationid=federationid, use_defaults=use_defaults, use_thread=use_thread)

    def delete_federator(self, token=None, operatorid=None, federationid=None, use_defaults=True, use_thread=False):
        return self.federation.delete_federator(token=token, operatorid=operatorid, federationid=federationid, use_defaults=use_defaults, use_thread=use_thread)

    def update_federator(self, token=None, operatorid=None, federationid=None, mcc=None, mnc=[], use_defaults=True, use_thread=False):
        return self.federation.update_federator(token=token, operatorid=operatorid, federationid=federationid, mcc=mcc, mnc=mnc, use_defaults=use_defaults, use_thread=use_thread)

    def generateselfapikey_federator(self, token=None, operatorid=None, federationid=None, use_defaults=True, use_thread=False):
        return self.federation.generateselfapikey_federator(token=token, operatorid=operatorid, federationid=federationid, use_defaults=use_defaults, use_thread=use_thread)

    def create_federation(self, token=None, selfoperatorid=None, selffederationid=None, federation_name=None, operatorid=None, countrycode=None, federationid=None, federationaddr=None, apikey=None, use_defaults=True, use_thread=False, auto_delete=True):
        if token is None:
            token=self.super_token

        return self.federation.create_federation(token=token, selfoperatorid=selfoperatorid, selffederationid=selffederationid, federation_name=federation_name, operatorid=operatorid, countrycode=countrycode, federationid=federationid, federationaddr=federationaddr, apikey=apikey, use_defaults=use_defaults, use_thread=use_thread, auto_delete=auto_delete)

    def show_federation(self, token=None, federation_name=None, selfoperatorid=None, federationid=None, use_defaults=True, use_thread=False):
        return self.federation.show_federation(token=token, federation_name=federation_name, selfoperatorid=selfoperatorid, federationid=federationid, use_defaults=use_defaults, use_thread=use_thread)

    def delete_federation(self, token=None, federation_name=None, selfoperatorid=None, use_defaults=True, use_thread=False):
        return self.federation.delete_federation(token=token, federation_name=federation_name, selfoperatorid=selfoperatorid, use_defaults=use_defaults, use_thread=use_thread)

    def register_federation(self, token=None, federation_name=None, selfoperatorid=None, use_defaults=True, use_thread=False):
        output = self.federation.register_federation(token=token, federation_name=federation_name, selfoperatorid=selfoperatorid, use_defaults=use_defaults, use_thread=use_thread)
        if f'Created directed federation "{federation_name}" successfully' not in str((output['message'])):
            raise Exception('ERROR: Partner Federation not registered successfully:' + str((output['message'])))

        return output

    def deregister_federation(self, token=None, federation_name=None, selfoperatorid=None, use_defaults=True, use_thread=False):
        output = self.federation.deregister_federation(token=token, federation_name=federation_name, selfoperatorid=selfoperatorid, use_defaults=use_defaults, use_thread=use_thread)
        if f'Deregistered federation "{federation_name}" successfully' not in str((output['message'])):
            raise Exception('ERROR: Partner Federation not deregistered successfully:' + str((output['message'])))

        return output

    def setpartnerapikey_federation(self, token=None, federation_name=None, selfoperatorid=None, apikey=None, use_defaults=True, use_thread=False):
        return self.federation.setpartnerapikey_federation(token=token, federation_name=federation_name, selfoperatorid=selfoperatorid, apikey=apikey, use_defaults=use_defaults, use_thread=use_thread)

    def showfederatedpartnerzone_federatorzone(self, token=None, zoneid=None, selfoperatorid=None, federation_name=None, registered=False, use_defaults=False, use_thread=False):
        return self.federation.showpartnerzone_federatorzone(token=token, zoneid=zoneid, selfoperatorid=selfoperatorid, federation_name=federation_name, registered=registered, use_defaults=use_defaults, use_thread=use_thread)
   
    def showfederatedselfzone_federatorzone(self, token=None, zoneid=None, selfoperatorid=None, federation_name=None, use_defaults=False, use_thread=False):
        return self.federation.showselfzone_federatorzone(token=token, zoneid=zoneid, selfoperatorid=selfoperatorid, federation_name=federation_name, use_defaults=use_defaults, use_thread=use_thread)

    def register_federatorzone(self, token=None, zones=[], selfoperatorid=None, federation_name=None, use_defaults=False, use_thread=False):
        return self.federation.register_federatorzone(token=token, zones=zones, selfoperatorid=selfoperatorid, federation_name=federation_name, use_defaults=use_defaults, use_thread=use_thread)

    def deregister_federatorzone(self, token=None, zones=[], selfoperatorid=None, federation_name=None, use_defaults=False, use_thread=False):
        return self.federation.deregister_federatorzone(token=token, zones=zones, selfoperatorid=selfoperatorid, federation_name=federation_name, use_defaults=use_defaults, use_thread=use_thread)

    def create_federatorzone(self, token=None, zoneid=None, operatorid=None, countrycode=None, cloudlets=[], geolocation=None, region=None, city=None, state=None, locality=None, use_defaults=False, use_thread=False, auto_delete=True):
        if token is None:
            token=self.super_token

        return self.federation.create_federatorzone(token=token, zoneid=zoneid, operatorid=operatorid, countrycode=countrycode, cloudlets=cloudlets, geolocation=geolocation, region=region, city=city, state=state, locality=locality, use_defaults=use_defaults, use_thread=use_thread, auto_delete=auto_delete)

    def show_federatorzone(self, token=None, zoneid=None, operatorid=None, countrycode=None, region=None, city=None, use_defaults=False, use_thread=False):
        return self.federation.show_federatorzone(token=token, zoneid=zoneid, operatorid=operatorid, countrycode=countrycode, region=region, city=city, use_defaults=use_defaults, use_thread=use_thread)

    def delete_federatorzone(self, token=None, zoneid=None, operatorid=None, countrycode=None, use_defaults=False, use_thread=False):
        return self.federation.delete_federatorzone(token=token, zoneid=zoneid, operatorid=operatorid, countrycode=countrycode, use_defaults=use_defaults, use_thread=use_thread)

    def share_federatorzone(self, token=None, zoneid=None, selfoperatorid=None, federation_name=None, use_defaults=False, use_thread=False):
        return self.federation.share_federatorzone(token=token, zoneid=zoneid, selfoperatorid=selfoperatorid, federation_name=federation_name, use_defaults=use_defaults)

    def unshare_federatorzone(self, token=None, zoneid=None, selfoperatorid=None, federation_name=None, use_defaults=False, use_thread=False):
        return self.federation.unshare_federatorzone(token=token, zoneid=zoneid, selfoperatorid=selfoperatorid, federation_name=federation_name, use_defaults=use_defaults)

    def run_mcctl(self, parms, version='latest', output_format='json', token=None):
        if token is None:
            token = self.token

        cmd = f'docker run --rm harbor.mobiledgex.net/mobiledgex/edge-cloud:{version} mcctl --addr https://{self.mc_address} --skipverify --token={token} {parms} ' 
        if output_format:
            cmd += f'--output-format {output_format}'

        logging.info(f'executing mcctl: {cmd}')
        output = self._run_command(cmd).decode('utf-8')
        try:
           return json.loads(output)
        except:
           return output

    def cleanup_provisioning(self):
        """ Deletes all the provisiong that was added during the test
        """

        if not os.environ.get('AUTOMATION_NO_CLEANUP') or os.environ.get('AUTOMATION_NO_CLEANUP') != '1':
            logging.info('cleaning up provisioning')
            print(self.prov_stack)
            #temp_prov_stack = self.prov_stack
            temp_prov_stack = list(self.prov_stack)
            temp_prov_stack.reverse()
            found_failure = False
            for obj in temp_prov_stack:
                logging.debug('deleting obj' + str(obj))
                try:
                    obj()
                except:
                    logging.warn(f'cleanup of object failed. Continuing anyway')
                    found_failure = True
                del self.prov_stack[-1]
            if found_failure:
               raise Exception('Cleanup failure found') 
        else:
            logging.info('cleanup disable since AUTOMATION_NO_CLEANUP is set')

    def wait_for_replies(self, *args):
        """ Waits for operations that were sent in threaded mode to complete
        """
        logging.info(f'waiting on {len(args)} threads')
        failed_thread_list = []

        for x in args:
            if isinstance(x, list):
                for x2 in x:
                    x.join()
            x.join()

        while not self._queue_obj.empty():
            try:
                exec = self._queue_obj.get(block=False)
                print('*WARN*', 'exec', exec)
                logging.error(f'thread {list(exec)[0]} failed with {exec[list(exec)[0]]}')
                failed_thread_list.append(exec)
            except queue.Empty:
                pass

        logging.info(f'number of failed threads:{len(failed_thread_list)}')
        if failed_thread_list:
            raise Exception(f'{len(failed_thread_list)} threads failed:', failed_thread_list)
