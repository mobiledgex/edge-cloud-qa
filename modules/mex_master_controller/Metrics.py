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

import shared_variables

from mex_master_controller.MexOperation import MexOperation
from mex_master_controller.AppInstance import AppInstance

logger = logging.getLogger('mex_mastercontroller rest')


class Metrics(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.client_url = '/auth/metrics/client'

    # '{"region":"local","appinst":{"app_key":{"developer_key":{"name":"AcmeAppCo"},"name":"someapplication1","version":"1.0"}},"method":"FindCloudlet","cellid":1234,"selector":"api","last":2}
    def _build(self, type_dict=None, method=None, cellid=None, selector=None, last=None, start_time=None, end_time=None, use_defaults=True):
        metric_dict = {}

        if type_dict is not None:
            metric_dict.update(type_dict)
        if selector is not None:
            metric_dict['selector'] = selector
        if last is not None:
            try:
                metric_dict['last'] = int(last)
            except:
                metric_dict['last'] = last
        if start_time is not None:
            metric_dict['starttime'] = start_time
        if end_time is not None:
            metric_dict['endtime'] = end_time

        return metric_dict

    def get_find_cloudlet_api_metrics(self, token=None, region=None, app_name=None, developer_name=None, app_version=None, selector=None, last=None, start_time=None, end_time=None, cellid=None, json_data=None, use_defaults=True, use_thread=False):
        app_inst = AppInstance(app_name=app_name, developer_name=developer_name, app_version=app_version, use_defaults=False)
        
        print('*WARN*', app_inst)
        msg_dict = self._build(type_dict=app_inst, method='FindCloudlet', cellid=cellid, selector='api', last=last, start_time=start_time, end_time=end_time)

        return self.show(token=token, url=self.client_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)
