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

import os
from slackclient import SlackClient
import argparse
import json
import logging
import sys

api_token = 'xoxb-313978814983-514011267477-U1J6wkdyA1lSRmTakKQ27R8e'
#channel_number = 'DF3JVL43W'
#channel_number = 'DF6DPUATG'
channel_number = 'CF67W3QH5'

slack_token = api_token
sc = SlackClient(slack_token)

message = sys.argv[1]

sc.api_call(
    "chat.postMessage",
    channel=channel_number,
    #text="Hello from Python! :tada:"
    text=message
)
