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

import websocket
import logging
import json

websocket.enableTrace(True)

logger = logging.getLogger(__name__)


class MexWebSocket:
    def __init__(self, url, token, origin=None):
        # self.wsurl = url.replace('http', 'ws').replace('api', 'ws/api')

        try:
            logger.debug(f'creating websocket to {url}')
            self.ws = websocket.WebSocket()
            self.ws.connect(url, origin=origin)
            logger.debug(f'created websocket to {url}')
        except Exception as e:
            logger.error(f'websocket connection to {url} failed: {e}')
            raise

        logger.debug(f'sending token={token}')
        self.ws.send(f'{{"token": "{token}"}}')

        self.resp_text = ''
        self.status_code = None
        self.last_resp = ''

    def send_data(self, data):
        logger.debug(f'sending data={data}')
        self.ws.send(data)

    def receive_data(self):
        try:
            while True:
                received_data = self.ws.recv()
                logger.debug(f'received: {received_data}')
                self.resp_text += received_data
                if received_data:
                    self.last_resp = received_data

                self.status_code = json.loads(self.last_resp)['code']
        except websocket.WebSocketConnectionClosedException as e:
            logger.info(f'ws connection closed {e}')
            self.ws.close()
