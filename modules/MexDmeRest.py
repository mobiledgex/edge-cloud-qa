import json
import logging
import jwt
import threading
import requests
import sys
import os
import subprocess

#from google.protobuf.json_format import MessageToJson

from mex_rest import MexRest
import mex_dme_classes
import shared_variables

#import app_client_pb2
#import app_client_pb2_grpc
#import loc_pb2

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

        self._number_getqospositionkpi_requests = 0
        self._number_getqospositionkpi_requests_success = 0
        self._number_getqospositionkpi_requests_fail = 0

        self._number_getappofficialfqdn_requests = 0
        self._number_getappofficialfqdn_requests_success = 0
        self._number_getappofficialfqdn_requests_fail = 0

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

    def register_client(self, developer_org_name=None, app_name=None, app_version=None, auth_token=None, tags=None, cell_id=None, unique_id=None, unique_id_type=None, use_defaults=True, use_thread=False):
        client = mex_dme_classes.RegisterClientObject(developer_org_name=developer_org_name, app_name=app_name, app_version=app_version, tags=tags, auth_token=auth_token, cell_id=cell_id, unique_id=unique_id, unique_id_type=unique_id_type, use_defaults=use_defaults)
        
        url = self.root_url + '/v1/registerclient'
        #payload = MessageToJson(client.request)
        payload = client.request

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
            shared_variables.session_cookie_default = self.decoded_data['session_cookie']

            self._decoded_session_cookie = jwt.decode(self.decoded_data['session_cookie'], verify=False)
            self._token_server_uri = self.decoded_data['token_server_uri']
            
            shared_variables.token_server_uri_default = self.decoded_data['token_server_uri']

            return self.decoded_data

        if use_thread is True:
            t = threading.Thread(target=send_message)
            t.start()
            return t
        else:
            print('sending message')
            resp = send_message()
            return resp

    def find_cloudlet(self, session_cookie=None, carrier_name=None, latitude=None, longitude=None, app_name=None, app_version=None, developer_org_name=None, cell_id=None, seconds=None, nanos=None, use_defaults=True, use_thread=False):
        
        client = mex_dme_classes.FindCloudletRequestObject(session_cookie=session_cookie, carrier_name=carrier_name, latitude=latitude, longitude=longitude, app_name=app_name, app_version=app_version, developer_org_name=developer_org_name, cell_id=cell_id, timestamp_seconds=seconds, timestamp_nanos=nanos, use_defaults=use_defaults)

        url = self.root_url + '/v1/findcloudlet'
        #payload = MessageToJson(client.request)
        payload = client.request
        
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

                if self.decoded_data['status'] != 'FindFound': # FIND_FOUND
                    raise Exception(f'find cloudlet not found:{self.decoded_data}')

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

    def get_qos_position_kpi(self, session_cookie=None, position_list=[] , lte_category=None, band_selection=None, cell_id=None, use_defaults=True, use_thread=False):
        
        client = mex_dme_classes.GetQosPositionKpiRequestObject(session_cookie=session_cookie, position_list=position_list, lte_category=lte_category, band_selection=band_selection, cell_id=cell_id, use_defaults=use_defaults)

        url = self.root_url + '/v1/getqospositionkpi'
        #payload = MessageToJson(client.request)
        payload = client.request
        
        logger.info('getqospositionkpi rest client on {}. \n\t{}'.format(url, payload))

        def send_message():
            self._number_getqospositionkpi_requests += 1

            try:
                self.post(url=url, data=payload)
                
                logger.info('response:\n' + str(self.resp.text))
                
                if str(self.resp.status_code) != '200':
                    self._number_qospositionkpi_requests_fail += 1
                    raise Exception("ws did not return a 200 response. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())

                if self.decoded_data['result']['status'] != 'RS_SUCCESS': 
                    raise Exception(f'get qos position kpi failed:{self.decoded_data}')

            except Exception as e:
                self._number_qospositionkpi_requests_fail += 1
                raise Exception("post failed:", e)

            self._number_getqospositionkpi_requests_success += 1

            return self.decoded_data
        
        if use_thread is True:
            t = threading.Thread(target=send_message)
            t.start()
            return t
        else:
            resp = send_message()
            return resp

    def verify_location(self, session_cookie=None, token=None, carrier_name=None, latitude=None, longitude=None, use_defaults=True, use_thread=False):
        
        client = mex_dme_classes.VerifyLocationRequestObject(session_cookie=session_cookie, token=token, carrier_name=carrier_name, latitude=latitude, longitude=longitude, use_defaults=use_defaults)

        url = self.root_url + '/v1/verifylocation'
        #payload = MessageToJson(client.request)
        payload = client.request
        
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

    def get_app_official_fqdn(self, session_cookie=None, latitude=None, longitude=None, use_defaults=True, use_thread=False):
        
        client = mex_dme_classes.GetAppOfficialFqdnRequestObject(session_cookie=session_cookie, latitude=latitude, longitude=longitude, use_defaults=use_defaults)

        url = self.root_url + '/v1/getappofficialfqdn'
        #payload = MessageToJson(client.request)
        payload = client.request
        
        logger.info('getappofficialfqdn rest client on {}. \n\t{}'.format(url, payload))

        def send_message():
            self._number_getappofficialfqdn_requests += 1

            try:
                self.post(url=url, data=payload)
                
                logger.info('response:\n' + str(self.resp.text))
                
                if str(self.resp.status_code) != '200':
                    self._number_getappofficialfqdn_requests_fail += 1
                    raise Exception("ws did not return a 200 response. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
                
            except Exception as e:
                self._number_getappofficialfqdn_requests_fail += 1
                raise Exception("post failed:", e)

            self._number_getappofficialfqdn_requests_success += 1

            return self.decoded_data
        
        if use_thread is True:
            t = threading.Thread(target=send_message)
            t.start()
            return t
        else:
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

    def generate_auth_token(self, app_name, app_version, developer_name, key_file='authtoken_private.pem'):
        global auth_token_global
        
        logger.info('generating token for {} {} {} {}'.format(app_name, app_version, developer_name, key_file))

        key_file = self._findFile(key_file)

        if not os.path.isfile(key_file):
            logger.error(f'key_file={key_file} does not exist')
            return None
        
        cmd = f'genauthtoken -appname {app_name} -appvers {app_version} -devname {developer_name} -privkeyfile {key_file}'
        logger.debug('cmd=' + cmd)
        
        process = subprocess.run(cmd,
                                 shell=True,
        #                         text=True,
                                 universal_newlines=True,  # same as text option, for older python versions
                                 capture_output=True
        )
        
        logger.debug('stdout=' + process.stdout)
        token = process.stdout.lstrip('Token:').lstrip().rstrip()
        logger.debug('generated token: ' + token)

        auth_token_global = token
        
        return token

    def wait_for_replies(self, *args):
        #print('*WARN*', type(args))
        for x in args:
            if isinstance(x, list):
                for x2 in x:
                    #print('*WARN*', 'list')
                    x.join()
            #print('*WARN*', 'join again')
            x.join()
