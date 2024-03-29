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

from webservice import WebService
import logging
import json
import sys
import os
from pathlib import Path

logger = logging.getLogger(__name__)


class MexRest(WebService):
    decoded_data = None

    def __init__(self, address='127.0.0.1:50051', root_cert='mex-ca.crt', key='localserver.key', client_cert='localserver.crt'):
        super().__init__()

        # self.root_cert = self._findFile(root_cert)

    def post(self, url, data=None, bearer=None, stream=False, stream_timeout=60, connection_timeout=3.05):
        # logging.debug(f'url={url} data={data} cert={self.root_cert}')
        logger.debug(f'url={url} data={data} stream={stream} stream_timeout={stream_timeout}')
        headers = {'Content-type': 'application/json', 'accept': 'application/json'}
        if bearer is not None:
            headers['Authorization'] = 'Bearer ' + bearer

        # self.resp = super().post(url=url, data=data, verify_cert=self.root_cert, headers=headers)
        # self.resp = super().post(url=url, data=data, headers=headers, stream=stream, stream_timeout=stream_timeout, connection_timeout=connection_timeout)
        self.resp = super().post(url=url, data=data, headers=headers, stream=stream, stream_timeout=stream_timeout)
        self._decode_content(stream=stream)

        if str(self.resp.status_code) != '200':
            raise Exception(f'ws did not return a 200 response. responseCode = {self.resp.status_code}. ResponseBody={self.resp_text.rstrip()}')

    def _decode_content(self, stream=False):
        try:
            if stream:
                for line in self.stream_output_bytes:
                    logger.debug(f'stream decode {line}')
                    self.stream_output.append(json.loads(line.decode("utf-8")))
                logger.debug('decoded stream_output=' + str(self.stream_output))
            else:
                logger.debug('content=' + self.resp.content.decode("utf-8"))
                self.decoded_data = json.loads(self.resp.content.decode("utf-8"))
        except Exception as e:
            logger.info(f'exception decoding result {e} as json')
            try:
                datasplit = self.resp.content.decode("utf-8").splitlines()
                if len(datasplit) == 1:
                    self.decoded_data = self.resp.content.decode("utf-8")
                else:
                    data_list = []
                    for data in datasplit:
                        data_list.append(json.loads(data))
                    self.decoded_data = data_list
                    self.resp_text = self.decoded_data
            except Exception:
                logging.debug('error decoding response content')

#        datasplit = self.resp.content.decode("utf-8").splitlines()
#        print('*WARN*', 'datasplit',datasplit)
#        if len(datasplit) == 1:
#            try:
#                self.decoded_data = json.loads(self.resp.content.decode("utf-8"))
#            except:
#                self.decoded_data = self.resp.content.decode("utf-8")
#        else:
#            data_list = []
#            for data in datasplit:
#                print('*WARN*', 'ddddd', data)
#                data_list.append(json.loads(data))
#            self.decoded_data = data_list

    def response_status_code(self):
        return self.resp.status_code

    def response_body(self):
        return self.resp.text

    def _findFile(self, path):
        for dirname in sys.path:
            for ppath in Path(dirname).rglob(path):
                if os.path.isfile(ppath) and ppath.name == path:
                    return ppath
        raise Exception('cant find file {}'.format(path))
