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

logger = logging.getLogger('mex_mastercontroller rest')
class VerifyEmail(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.update_url = '/verifyemail'

     # curl -X POST "https://console-qa.mobiledgex.net:443/api/v1/verifyemail" -H "Content-Type: application/json" -H "Authorization: Bearer ${TOKEN}" -k --data-raw '{"token":"eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1OTcyNTY0OTEsImlhdCI6MTU5NzE3MDA5MSwidXNlcm5hbWUiOiJtZXh0ZXN0ZXIwNjE1OTcxNjg0NTUiLCJlbWFpbCI6Im1leHRlc3RlcjA2KzE1OTcxNjg0NTVAZ21haWwuY29tIiwia2lkIjoyfQ.pIcr7feYdy73aMaSRH_qvcPnpdYMgXr04Uk30JGiPIfbilWmsqioAFpjY7mQ6hdJsehCS_iAgzf_gH4p619Khw"}'

    def _build(self, token=None):
        build_dict = {}

        if token:
            build_dict['token'] = token
            
        return build_dict

    def verify_email(self, token=None):
        msg = self._build(token=token)
        msg_show = msg 

        return self.update(token=token, url=self.update_url, message=msg)
