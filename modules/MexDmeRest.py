import json
import logging

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
        self.root_cert = root_cert
        
    def register_client(self, developer_name=None, app_name=None, app_version=None, auth_token=None, use_defaults=True):
        client = mex_dme_classes.RegisterClientObject(developer_name=developer_name, app_name=app_name, app_version=app_version, auth_token=auth_token, use_defaults=use_defaults)

        url = self.root_url + '/v1/registerclient'
        payload = MessageToJson(client.request)

        #payload = json.dumps(client.register_client_dict)
        
        logger.info('register rest client on {}. \n\t{}'.format(url, payload))

        self.post(url=url, data=payload)

        logger.info('response:\n' + str(self.resp.text))
                    
        if str(self.resp.status_code) != '200':
            raise Exception("ws did not return a 200 response. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
        
        #global session_cookie_global
        #global token_server_uri_global

        print('*WARN*', 'xxx',self.decoded_data)
        shared_variables.session_cookie_default = self.decoded_data['SessionCookie']
        #token_server_uri_global = resp.TokenServerURI
        
    def find_cloudlet(self, session_cookie=None, carrier_name=None, latitude=None, longitude=None, app_name=None, app_version=None, developer_name=None, seconds=None, nanos=None, use_defaults=True):
        
        client = mex_dme_classes.FindCloudletRequestObject(session_cookie=session_cookie, carrier_name=carrier_name, latitude=latitude, longitude=longitude, app_name=app_name, app_version=app_version, developer_name=developer_name, timestamp_seconds=seconds, timestamp_nanos=nanos, use_defaults=use_defaults)

        url = self.root_url + '/v1/findcloudlet'
        payload = MessageToJson(client.request)
        
        logger.info('findcloudlet rest client on {}. \n\t{}'.format(url, payload))

        self.post(url=url, data=payload)

        logger.info('response:\n' + str(self.resp.text))
                    
        if str(self.resp.status_code) != '200':
            raise Exception("ws did not return a 200 response. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())

        for data in self.decoded_data:
            print('*WARN*', 'xxx2',data)
            print('*WARN*', 'xxx3',self.decoded_data[data])
        return self.decoded_data

    def verify_location(self, session_cookie=None, token=None, carrier_name=None, latitude=None, longitude=None, use_defaults=True):
        
        client = mex_dme_classes.VerifyLocationRequestObject(session_cookie=session_cookie, token=token, carrier_name=carrier_name, latitude=latitude, longitude=longitude, use_defaults=use_defaults)

        url = self.root_url + '/v1/verifylocation'
        payload = MessageToJson(client.request)
        
        logger.info('verifylocation rest client on {}. \n\t{}'.format(url, payload))

        self.post(url=url, data=payload)

        logger.info('response:\n' + str(self.resp.text))
                    
        if str(self.resp.status_code) != '200':
            raise Exception("ws did not return a 200 response. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())

        for data in self.decoded_data:
            print('*WARN*', 'xxx2',data)
            print('*WARN*', 'xxx3',self.decoded_data[data])
        return self.decoded_data
