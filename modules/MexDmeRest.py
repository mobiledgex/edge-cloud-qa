import json
import logging
import jwt
import threading
import requests
import sys

from google.protobuf.json_format import MessageToJson

from mex_rest import MexRest
import mex_dme_classes
import shared_variables

import app_client_pb2
import app_client_pb2_grpc
import loc_pb2

logging.basicConfig(format='%(asctime)s %(levelname)s %(funcName)s line:%(lineno)d - %(message)s',datefmt='%d-%b-%y %H:%M:%S')
logger = logging.getLogger('mex_dme rest')

class MexDmeRest(MexRest):
    def __init__(self, dme_address='127.0.0.1:50051', root_cert='mex-ca.crt'):
        super().__init__(address=dme_address, root_cert=root_cert)

        self.root_url = 'https://' + dme_address
        #self.root_cert = root_cert
        self._decoded_session_cookie = None
        self._token_server_uri = None

        self._number_register_requests = 0
        self._number_register_requests_success = 0
        self._number_register_requests_fail = 0

        self._number_findCloudlet_requests = 0
        self._number_findCloudlet_requests_success = 0
        self._number_findCloudlet_requests_fail = 0

        self._number_verifyLocation_requests = 0
        self._number_verifyLocation_requests_success = 0
        self._number_verifyLocation_requests_fail = 0

    def number_of_register_requests(self):
        return self._number_register_requests

    def number_of_successful_register_requests(self):
        return self._number_register_requests_success

    def number_of_failed_register_requests(self):
        return self._number_register_requests_fail

    def number_of_find_cloudlet_requests(self):
        return self._number_findCloudlet_requests

    def number_of_successful_find_cloudlet_requests(self):
        return self._number_findCloudlet_requests_success

    def number_of_failed_find_cloudlet_requests(self):
        return self._number_findCloudlet_requests_fail

    def number_of_verify_location_requests(self):
        return self._number_verifyLocation_requests

    def number_of_successful_verify_location_requests(self):
        return self._number_verifyLocation_requests_success

    def number_of_failed_verify_location_requests(self):
        return self._number_verifyLocation_requests_fail

    def decoded_session_cookie(self):
        return self._decoded_session_cookie

    def token_server_uri(self):
        return self._token_server_uri

    def register_client(self, developer_name=None, app_name=None, app_version=None, auth_token=None, use_defaults=True, use_thread=False):
        client = mex_dme_classes.RegisterClientObject(developer_name=developer_name, app_name=app_name, app_version=app_version, auth_token=auth_token, use_defaults=use_defaults)

        url = self.root_url + '/v1/registerclient'
        payload = MessageToJson(client.request)

        #payload = json.dumps(client.register_client_dict)
        
        logger.info('register rest client on {}. \n\t{}'.format(url, payload))

        def send_message():
            self._number_register_requests += 1

            try:
                self.post(url=url, data=payload)

                logger.info('response:\n' + str(self.resp.text))
                    
                if str(self.resp.status_code) != '200':
                    self._number_register_requests_fail += 1
                    raise Exception("ws did not return a 200 response. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
            except Exception as e:
                self._number_register_requests_fail += 1
                raise Exception("post failed:", e)
                
            self._number_register_requests_success += 1

            #global session_cookie_global
            #global token_server_uri_global

            logger.debug(self.decoded_data)
            shared_variables.session_cookie_default = self.decoded_data['SessionCookie']

            self._decoded_session_cookie = jwt.decode(self.decoded_data['SessionCookie'], verify=False)
            self._token_server_uri = self.decoded_data['TokenServerURI']
            
            shared_variables.token_server_uri_default = self.decoded_data['TokenServerURI']

        if use_thread is True:
            t = threading.Thread(target=send_message)
            t.start()
            return t
        else:
            print('sending message')
            resp = send_message()
            return resp

    def find_cloudlet(self, session_cookie=None, carrier_name=None, latitude=None, longitude=None, app_name=None, app_version=None, developer_name=None, seconds=None, nanos=None, use_defaults=True, use_thread=False):
        
        client = mex_dme_classes.FindCloudletRequestObject(session_cookie=session_cookie, carrier_name=carrier_name, latitude=latitude, longitude=longitude, app_name=app_name, app_version=app_version, developer_name=developer_name, timestamp_seconds=seconds, timestamp_nanos=nanos, use_defaults=use_defaults)

        url = self.root_url + '/v1/findcloudlet'
        payload = MessageToJson(client.request)
        
        logger.info('findcloudlet rest client on {}. \n\t{}'.format(url, payload))

        def send_message():
            self._number_findCloudlet_requests += 1

            try:
                self.post(url=url, data=payload)
                print('*WARN', 'post')
                
                logger.info('response:\n' + str(self.resp.text))
                
                if str(self.resp.status_code) != '200':
                    self._number_findCloudlet_requests_fail += 1
                    raise Exception("ws did not return a 200 response. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
                
                #for data in self.decoded_data:
                #    print('*WARN*', 'xxx2',data)
                #    print('*WARN*', 'xxx3',self.decoded_data[data])

            except Exception as e:
                self._number_findCloudlet_requests_fail += 1
                raise Exception("post failed:", e)

            self._number_findCloudlet_requests_success += 1

            return self.decoded_data
        
        if use_thread is True:
            t = threading.Thread(target=send_message)
            t.start()
            return t
        else:
            print('sending message')
            resp = send_message()
            return resp

    def verify_location(self, session_cookie=None, token=None, carrier_name=None, latitude=None, longitude=None, use_defaults=True, use_thread=False):
        
        client = mex_dme_classes.VerifyLocationRequestObject(session_cookie=session_cookie, token=token, carrier_name=carrier_name, latitude=latitude, longitude=longitude, use_defaults=use_defaults)

        url = self.root_url + '/v1/verifylocation'
        payload = MessageToJson(client.request)
        
        logger.info('verifylocation rest client on {}. \n\t{}'.format(url, payload))

        def send_message():
            self._number_verifyLocation_requests += 1

            try:
                self.post(url=url, data=payload)

                logger.info('response:\n' + str(self.resp.text))
                    
                if str(self.resp.status_code) != '200':
                    self._number_verifyLocation_requests_fail += 1
                    raise Exception("ws did not return a 200 response. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())

                #for data in self.decoded_data:
                #    print('*WARN*', 'xxx2',data)
                #    print('*WARN*', 'xxx3',self.decoded_data[data])

            except Exception as e:
                self._number_verifyLocation_requests_fail += 1
                raise Exception("post failed:", e)

            self._number_verifyLocation_requests_success += 1

            return self.decoded_data

        if use_thread is True:
            t = threading.Thread(target=send_message)
            t.start()
            return t
        else:
            print('sending message')
            resp = send_message()
            return resp

    def get_token(self, token_server=None):
        #global token_global
        #global token_server_uri_global
        
        if token_server is None:
            token_server = shared_variables.token_server_uri_default
            
        logger.info('getting token from {}'.format(token_server))

        resp = requests.get(token_server, allow_redirects=False)

        location = resp.headers['Location']
        logger.debug('location header:{}'.format(location))

        token = location.split('dt-id=')[1]
        shared_variables.token_default = token
        logger.debug('token={}'.format(token))

        return token

    def wait_for_replies(self, *args):
        for x in args:
            if isinstance(x, list):
                for x2 in x:
                    x.join()
            x.join()
