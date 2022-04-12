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

import logging

import shared_variables

from mex_master_controller.MexOperation import MexOperation

logger = logging.getLogger(__name__)


class CloudletPoolAccess(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.invite_create_url = '/auth/cloudletpoolaccessinvitation/create'
        self.invite_delete_url = '/auth/cloudletpoolaccessinvitation/delete'
        self.invite_show_url = '/auth/cloudletpoolaccessinvitation/show'

        self.response_create_url = '/auth/cloudletpoolaccessresponse/create'
        self.response_delete_url = '/auth/cloudletpoolaccessresponse/delete'
        self.response_show_url = '/auth/cloudletpoolaccessresponse/show'

        self.show_granted_url = '/auth/cloudletpoolaccessgranted/show'
        self.show_pending_url = '/auth/cloudletpoolaccesspending/show'

    def _build(self, cloudlet_pool_name=None, cloudlet_pool_org_name=None, developer_org_name=None, decision=None, use_defaults=True):
        if cloudlet_pool_name == 'default':
            cloudlet_pool_name = shared_variables.cloudletpool_name_default

        if use_defaults:
            if cloudlet_pool_name is None:
                cloudlet_pool_name = shared_variables.cloudletpool_name_default
            if developer_org_name is None:
                developer_org_name = shared_variables.developer_name_default
            if cloudlet_pool_org_name is None:
                cloudlet_pool_org_name = shared_variables.operator_name_default

        invite_dict = {}
        if cloudlet_pool_name is not None:
            invite_dict['cloudletpool'] = cloudlet_pool_name
        if developer_org_name is not None:
            invite_dict['org'] = developer_org_name
        if cloudlet_pool_org_name is not None:
            invite_dict['cloudletpoolorg'] = cloudlet_pool_org_name
        if decision is not None:
            invite_dict['decision'] = decision

        return invite_dict

    def create_cloudlet_pool_access_invitation(self, token=None, region=None, cloudlet_pool_name=None, developer_org_name=None, cloudlet_pool_org_name=None, json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        msg = self._build(cloudlet_pool_name=cloudlet_pool_name, developer_org_name=developer_org_name, cloudlet_pool_org_name=cloudlet_pool_org_name, use_defaults=use_defaults)
        msg_dict = msg

        msg_dict_delete = None
        if auto_delete and 'cloudletpool' in msg_dict and 'cloudletpoolorg' in msg_dict and 'org' in msg_dict:
            msg_delete = self._build(cloudlet_pool_name=msg['cloudletpool'], cloudlet_pool_org_name=msg['cloudletpoolorg'], developer_org_name=msg['org'], use_defaults=False)
            msg_dict_delete = msg_delete

        msg_dict_show = None
        if 'cloudletpool' in msg_dict and 'cloudletpoolorg' in msg_dict and 'org' in msg_dict:
            msg_show = self._build(cloudlet_pool_name=msg['cloudletpool'], cloudlet_pool_org_name=msg['cloudletpoolorg'], developer_org_name=msg['org'], use_defaults=False)
            msg_dict_show = msg_show

        return self.create(token=token, url=self.invite_create_url, delete_url=self.invite_delete_url, show_url=self.invite_show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, create_msg=msg_dict, delete_msg=msg_dict_delete, show_msg=msg_dict_show)[0]

    def delete_cloudlet_pool_access_invitation(self, token=None, region=None, cloudlet_pool_name=None, developer_org_name=None, cloudlet_pool_org_name=None, json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        msg = self._build(cloudlet_pool_name=cloudlet_pool_name, developer_org_name=developer_org_name, cloudlet_pool_org_name=cloudlet_pool_org_name, use_defaults=use_defaults)
        msg_dict = msg

        return self.delete(token=token, url=self.invite_delete_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def create_cloudlet_pool_access_response(self, token=None, region=None, cloudlet_pool_name=None, developer_org_name=None, cloudlet_pool_org_name=None, decision=None, json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        msg = self._build(cloudlet_pool_name=cloudlet_pool_name, developer_org_name=developer_org_name, cloudlet_pool_org_name=cloudlet_pool_org_name, decision=decision, use_defaults=use_defaults)
        msg_dict = msg

        msg_dict_delete = None
        if auto_delete and 'cloudletpool' in msg_dict and 'cloudletpoolorg' in msg_dict and 'org' in msg_dict:
            msg_delete = self._build(cloudlet_pool_name=msg['cloudletpool'], cloudlet_pool_org_name=msg['cloudletpoolorg'], developer_org_name=msg['org'], use_defaults=False)
            msg_dict_delete = msg_delete

        msg_dict_show = None
        if 'cloudletpool' in msg_dict and 'cloudletpoolorg' in msg_dict and 'org' in msg_dict:
            msg_show = self._build(cloudlet_pool_name=msg['cloudletpool'], cloudlet_pool_org_name=msg['cloudletpoolorg'], developer_org_name=msg['org'], use_defaults=False)
            msg_dict_show = msg_show

        return self.create(token=token, url=self.response_create_url, delete_url=self.response_delete_url, show_url=self.response_show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, create_msg=msg_dict, delete_msg=msg_dict_delete, show_msg=msg_dict_show)[0]

    def delete_cloudlet_pool_access_response(self, token=None, region=None, cloudlet_pool_name=None, developer_org_name=None, cloudlet_pool_org_name=None, json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        msg = self._build(cloudlet_pool_name=cloudlet_pool_name, developer_org_name=developer_org_name, cloudlet_pool_org_name=cloudlet_pool_org_name, use_defaults=use_defaults)
        msg_dict = msg

        return self.delete(token=token, url=self.response_delete_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def show_cloudlet_pool_access_granted(self, token=None, region=None, cloudlet_pool_name=None, developer_org_name=None, cloudlet_pool_org_name=None, json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        msg = self._build(cloudlet_pool_name=cloudlet_pool_name, developer_org_name=developer_org_name, cloudlet_pool_org_name=cloudlet_pool_org_name, use_defaults=use_defaults)
        msg_dict = msg

        return self.show(token=token, url=self.show_granted_url, region=region, json_data=json_data, use_defaults=True, use_thread=use_thread, message=msg_dict)

    def show_cloudlet_pool_access_pending(self, token=None, region=None, cloudlet_pool_name=None, developer_org_name=None, cloudlet_pool_org_name=None, json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        msg = self._build(cloudlet_pool_name=cloudlet_pool_name, developer_org_name=developer_org_name, cloudlet_pool_org_name=cloudlet_pool_org_name, use_defaults=use_defaults)
        msg_dict = msg

        return self.show(token=token, url=self.show_pending_url, region=region, json_data=json_data, use_defaults=True, use_thread=use_thread, message=msg_dict)

    def show_cloudlet_pool_access_invitation(self, token=None, region=None, cloudlet_pool_name=None, developer_org_name=None, cloudlet_pool_org_name=None, json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        msg = self._build(cloudlet_pool_name=cloudlet_pool_name, developer_org_name=developer_org_name, cloudlet_pool_org_name=cloudlet_pool_org_name, use_defaults=use_defaults)
        msg_dict = msg

        return self.show(token=token, url=self.invite_show_url, region=region, json_data=json_data, use_defaults=True, use_thread=use_thread, message=msg_dict)

    def show_cloudlet_pool_access_response(self, token=None, region=None, cloudlet_pool_name=None, developer_org_name=None, cloudlet_pool_org_name=None, json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        msg = self._build(cloudlet_pool_name=cloudlet_pool_name, developer_org_name=developer_org_name, cloudlet_pool_org_name=cloudlet_pool_org_name, use_defaults=use_defaults)
        msg_dict = msg

        return self.show(token=token, url=self.response_show_url, region=region, json_data=json_data, use_defaults=True, use_thread=use_thread, message=msg_dict)
