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

import json
import logging
import time

import shared_variables

from mex_master_controller.MexOperation import MexOperation

logger = logging.getLogger(__name__)

class Stream(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.cloudlet_url = '/auth/ctrl/StreamCloudlet'
        self.clusterinst_url = '/auth/ctrl/StreamClusterInst'
        self.appinst_url = '/auth/ctrl/StreamAppInst'

    def _build_cloudlet(self, cloudlet_name=None, operator_org_name=None, use_defaults=True):

        if use_defaults:
            if cloudlet_name is None: cloudlet_name = shared_variables.cloudlet_name_default
            if operator_org_name is None: operator_org_name = shared_variables.operator_name_default

        #'{"cloudletkey":{"name":"andybonn","organization":"TDG"},"region":"EU"}'
        stream_dict = {}
        cloudlet_key_dict = {}

        if cloudlet_name is not None:
            cloudlet_key_dict['name'] = cloudlet_name
        if operator_org_name is not None:
            cloudlet_key_dict['organization'] = operator_org_name

        if cloudlet_key_dict:
            stream_dict['cloudletkey'] = cloudlet_key_dict

        return stream_dict

    def _build_clusterinst(self, cluster_name=None, developer_org_name=None, cloudlet_dict=None, use_defaults=True):

        if use_defaults:
            if cluster_name is None: cluster_name = shared_variables.cluster_name_default
            if developer_org_name is None: developer_org_name = shared_variables.developer_name_default

        #'{"clusterinstkey":{"cloudlet_key":{"name":"cloudlet1603909082-905556","organization":"TDG"},"cluster_key":{"name":"mycluster"},"organization":"MobiledgeX"},"region":"EU"}'
        stream_dict = {}
        cluster_key_dict = {}
        cloudlet_key_dict = {}

        if cluster_name:
            cluster_key_dict['cluster_key'] = {'name':cluster_name}
        if developer_org_name is not None:
            cluster_key_dict['organization'] = developer_org_name

        if cloudlet_dict is not None:
            cluster_key_dict['cloudlet_key'] = cloudlet_dict['cloudletkey']

        if cluster_key_dict:
            stream_dict['clusterinstkey'] = cluster_key_dict

        return stream_dict

    def _build_appinst(self, app_name=None, app_version=None, developer_org_name=None, cloudlet_dict=None, cluster_dict=None, use_defaults=True):

        if use_defaults:
            if app_version is None: app_version = shared_variables.app_version_default
            if app_name is None: app_name = shared_variables.app_name_default
            if developer_org_name is None: developer_org_name = shared_variables.developer_name_default

        #'{"appinstkey":{"app_key":{"name":"myname,","organization":"MobiledgeX","version":"1.0"},"cluster_inst_key":{"cloudlet_key":{"name":"automationHamburgCloudlet","organization":"TDG"},"cluster_key":{"name":"cluster1603915771-749813"}}},"region":"EU"}'
        stream_dict = {}
        app_key_dict = {}
        appinst_key_dict = {}
        cloudlet_key_dict = {}
        cluster_key_dict = {}
  
        if app_name:
            app_key_dict['name'] = app_name
        if app_version:
            app_key_dict['version'] = app_version
        if developer_org_name is not None:
            app_key_dict['organization'] = developer_org_name

        if cloudlet_dict is not None:
            cluster_key_dict['cloudlet_key'] = cloudlet_dict['cloudletkey']

        if cluster_dict is not None:
            cluster_key_dict['cluster_key'] = cluster_dict['clusterinstkey']['cluster_key']

        if app_key_dict:
           appinst_key_dict['app_key'] = app_key_dict

        if cluster_key_dict:
            appinst_key_dict['cluster_inst_key'] = cluster_key_dict

        if appinst_key_dict:
            stream_dict['appinstkey'] = appinst_key_dict

        return stream_dict

    def stream_cloudlet(self, token=None, region=None, cloudlet_name=None, operator_org_name=None, json_data=None, auto_delete=True, use_defaults=True, use_thread=False):
        msg = self._build_cloudlet(cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, use_defaults=use_defaults)
        msg_dict = msg

        return self.show(token=token, url=self.cloudlet_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def stream_appinst(self, token=None, region=None, app_name=None, developer_org_name=None, app_version=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, cloudlet_name=None, operator_org_name=None, json_data=None, auto_delete=True, use_defaults=True, use_thread=False):
        msg_cloudlet = self._build_cloudlet(cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, use_defaults=use_defaults)
        msg_cluster = self._build_clusterinst(cloudlet_dict=msg_cloudlet, cluster_name=cluster_instance_name, developer_org_name=cluster_instance_developer_org_name, use_defaults=use_defaults)
        msg = self._build_appinst(cloudlet_dict=msg_cloudlet, cluster_dict=msg_cluster, app_name=app_name, app_version=app_version, developer_org_name=developer_org_name, use_defaults=use_defaults)

        msg_dict = msg

        return self.show(token=token, url=self.appinst_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def stream_clusterinst(self, token=None, region=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, cloudlet_name=None, operator_org_name=None, json_data=None, auto_delete=True, use_defaults=True, use_thread=False):
        msg_cloudlet = self._build_cloudlet(cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, use_defaults=use_defaults)
        msg = self._build_clusterinst(cloudlet_dict=msg_cloudlet, cluster_name=cluster_instance_name, developer_org_name=cluster_instance_developer_org_name, use_defaults=use_defaults)
        msg_dict = msg

        return self.show(token=token, url=self.clusterinst_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)
