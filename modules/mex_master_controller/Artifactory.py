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

from mex_master_controller.MexOperation import MexOperation

logger = logging.getLogger(__name__)


class Artifactory(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.summary_url = '/auth/artifactory/summary'

    def show_summary(self, token=None, region=None, controller_address=None, influxdb_address=None, json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        return self.show(token=token, url=self.summary_url, region=region, json_data=json_data, use_defaults=True, use_thread=use_thread)[0]
