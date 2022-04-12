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

class ShowDeviceReport(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.show_url = '/auth/ctrl/ShowDeviceReport'

    #{"device":{"begin":{"nanos":1,"seconds":10},"key":{"unique_id":"123","unique_id_type":"abc"},"end":{"nanos":2,"seconds":20}},"region":"US"}
    def _build(self, unique_id_type=None, unique_id=None, begin_seconds=None, begin_nanos=None, end_seconds=None, end_nanos=None, notify_id=None):
        begin_dict = {}
        end_dict = {}
        key_dict = {}
        dev_dict = {}

        if unique_id is not None:
           key_dict['unique_id'] = str(unique_id)
        if unique_id_type is not None:
           key_dict['unique_id_type'] = unique_id_type

        if begin_seconds is not None:
           try:
              begin_dict['seconds'] = int(begin_seconds)
           except:
              begin_dict['seconds'] = begin_seconds 
        if end_seconds is not None:
           end_dict['seconds'] = int(end_seconds)
        if begin_nanos is not None:
           begin_dict['nanos'] = int(begin_nanos)
        if end_nanos is not None:
           end_dict['nanos'] = int(end_nanos)

        if notify_id is not None:
           key_dict['notify_id'] = notify_id

        if key_dict:
           dev_dict['key'] = key_dict
        if begin_dict:
           dev_dict['begin'] = begin_dict
        if end_dict:
           dev_dict['end'] = end_dict

        return dev_dict

    def show_device_report(self, token=None, region=None, unique_id=None, unique_id_type=None, begin_seconds=None, begin_nanos=None, end_seconds=None, end_nanos=None, notify_id=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(unique_id=unique_id, unique_id_type=unique_id_type, begin_seconds=begin_seconds, begin_nanos=begin_nanos, end_seconds=end_seconds, end_nanos=end_nanos, notify_id=notify_id)
        msg_dict = {'devicereport':msg}
        
        return self.show(token=token, url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)
 
