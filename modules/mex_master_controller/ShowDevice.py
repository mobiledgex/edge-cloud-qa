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

class ShowDevice(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.show_url = '/auth/ctrl/ShowDevice'

    #{"device":{"first_seen":{"nanos":1,"seconds":10},"key":{"unique_id":"123","unique_id_type":"abc"},"last_seen":{"nanos":2,"seconds":20}},"region":"US"}
    def _build(self, unique_id_type=None, unique_id=None, first_seen_seconds=None, first_seen_nanos=None, last_seen_seconds=None, last_seen_nanos=None, notify_id=None):
        first_dict = {}
        last_dict = {}
        key_dict = {}
        dev_dict = {}

        if unique_id is not None:
           key_dict['unique_id'] = str(unique_id)
        if unique_id_type is not None:
           key_dict['unique_id_type'] = unique_id_type

        if first_seen_seconds is not None:
           try:
              first_dict['seconds'] = int(first_seen_seconds)
           except:
              first_dict['seconds'] = first_seen_seconds 
        if last_seen_seconds is not None:
           last_dict['seconds'] = int(last_seen_seconds)
        if first_seen_nanos is not None:
           first_dict['nanos'] = int(first_seen_nanos)
        if last_seen_nanos is not None:
           last_dict['nanos'] = int(last_seen_nanos)

        if notify_id is not None:
           key_dict['notify_id'] = notify_id

        if key_dict:
           dev_dict['key'] = key_dict
        if first_dict:
           dev_dict['first_seen'] = first_dict
        if last_dict:
           dev_dict['last_seen'] = last_dict

        return dev_dict

    def show_device(self, token=None, region=None, unique_id=None, unique_id_type=None, first_seen_seconds=None, first_seen_nanos=None, last_seen_seconds=None, last_seen_nanos=None, notify_id=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(unique_id=unique_id, unique_id_type=unique_id_type, first_seen_seconds=first_seen_seconds, first_seen_nanos=first_seen_nanos, last_seen_seconds=last_seen_seconds, last_seen_nanos=last_seen_nanos, notify_id=notify_id)
        msg_dict = {'device':msg}
        
        return self.show(token=token, url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)
 
