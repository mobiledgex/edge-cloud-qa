import grpc
import sys
import os
import subprocess
import shlex
import logging
import jwt
from mex_grpc import MexGrpc

import app_client_pb2
import app_client_pb2_grpc
import loc_pb2

logging.basicConfig(format='%(asctime)s %(levelname)s %(funcName)s line:%(lineno)d - %(message)s',datefmt='%d-%b-%y %H:%M:%S')
logger = logging.getLogger('mex_dme')

class Client():
    def __init__(self, developer_name=None, app_name=None, app_version=None, auth_token=None):
        client_dict = {}
        self.dev_name = developer_name
        self.app_name = app_name
        self.app_vers = app_version
        self.auth_token = auth_token

        #if auth_token == 'default':
        #    self.auth_token = 
        if self.dev_name is not None:
            client_dict['DevName'] = self.dev_name
        if self.app_name is not None:
            client_dict['AppName'] = self.app_name
        if self.app_vers is not None:
            client_dict['AppVers'] = self.app_vers
        if self.auth_token is not None:
            client_dict['AuthToken'] = self.auth_token
            
        self.client = app_client_pb2.RegisterClientRequest(**client_dict)

class FindCloudletRequest():
    def __init__(self, session_cookie=None, carrier_name=None, latitude=None, longitude=None):
        request_dict = {}
        self.session_cookie = session_cookie
        self.carrier_name = carrier_name
        self.latitude = latitude
        self.longitude = longitude

        loc_dict = {}
        if self.latitude:
            loc_dict['lat'] = int(self.latitude)
        if self.longitude:
            loc_dict['long'] = int(self.longitude)

        if self.session_cookie is not None:
            request_dict['SessionCookie'] = self.session_cookie
        if self.carrier_name is not None:
            request_dict['CarrierName'] = self.carrier_name
        if loc_dict:
            request_dict['GpsLocation'] = loc_pb2.Loc(**loc_dict)

        self.request = app_client_pb2.FindCloudletRequest(**request_dict)

class Dme(MexGrpc):
    def __init__(self, dme_address='127.0.0.1:50051', root_cert='mex-ca.crt', key='localserver.key', client_cert='localserver.crt'):
        #self.developer_list = []
        #self.operator_list = []
        #self.app_list = []

        self.session_cookie = None
        self._decoded_session_cookie = None
        self._token_server_uri = None
        self._auth_token = None
        
        super(Dme, self).__init__(address=dme_address, root_cert=root_cert, key=key, client_cert=client_cert)

        self.match_engine_stub = app_client_pb2_grpc.Match_Engine_ApiStub(self.grpc_channel)

    #@property
    def decoded_session_cookie(self):
        return self._decoded_session_cookie

    def token_server_uri(self):
        return self._token_server_uri
    
    #@decoded_session_cookie.setter
    #def decoded_session_cookie(self, value):
    #    self.__decoded_session_cookie = value
        
    def register_client(self, register_client_obj=None, **kwargs):
        resp = None

        if not register_client_obj:
            if len(kwargs) == 0:
                kwargs = {'use_defaults': True}
                if 'auth_token' not in kwargs:
                    kwargs['auth_token'] = self._auth_token

            request = Client(**kwargs).client

        logger.info('register client on {}. \n\t{}'.format(self.address, str(request).replace('\n','\n\t')))
                    
        resp = self.match_engine_stub.RegisterClient(request)
        self.session_cookie = resp.SessionCookie
        self._token_server_uri = resp.TokenServerURI
        logger.debug('session_cookie=' + self.session_cookie)
        logger.debug('token server uri=' + self._token_server_uri)

        self._decoded_session_cookie = jwt.decode(self.session_cookie, verify=False)

        return resp

    def find_cloudlet(self, find_cloudlet_obj=None, **kwargs):
        resp = None

        if not find_cloudlet_obj:
            if len(kwargs) == 0:
                kwargs = {'use_defaults': True}
            if 'session_cookie' not in kwargs:
                kwargs['session_cookie'] = self.session_cookie
            request = FindCloudletRequest(**kwargs).request

        logger.info('find cloudlet on {}. \n\t{}'.format(self.address, str(request).replace('\n','\n\t')))
                    
        resp = self.match_engine_stub.FindCloudlet(request)

        if resp.status != 1: # FIND_FOUND
            raise Exception('find cloudlet not found:{}'.format(str(resp)))

        return resp
        
    def get_app_instance_list(self, match_engine_request_obj=None, **kwargs):
        logger.info('get app instance list on {}. \n\t{}'.format(self.address, str(match_engine_request_obj).replace('\n','\n\t')))

    def generate_auth_token(self, app_name, app_version, developer_name):
        logger.info('generating token for {} {} {}'.format(app_name, app_version, developer_name))
                    
        cmd = 'genauthtoken -appname ' + app_name + ' -appvers ' + app_version + ' -devname ' + developer_name + ' -privkeyfile ~/go/src/github.com/mobiledgex/edge-cloud-qa/certs/authtoken_private.pem'

        #process = subprocess.Popen(shlex.split(cmd),
        process = subprocess.run(cmd,
                                   #stdout=subprocess.DEVNULL,
                                   #stderr=subprocess.DEVNULL,
                                   #stdout=open(log_file, 'w'),
                                   shell=True,
                                 text=True,
                                   capture_output=True
        )
        token = process.stdout.lstrip('Token:').lstrip().rstrip()
        #token = token.lstrip().rstrip()
        logger.debug('generated token: ' + token)

        self._auth_token = token
        
        return token
        
    #def calculate_distance(latitude1=None, longitude1=None, latitude2=None, longitude2=None):
    def calculate_distance(origin=None, destination=None):
        lat1, lon1 = origin
        lat2, lon2 = destination
        radius = 6371  # km
        
        dlat = math.radians(lat2 - lat1)
        dlon = math.radians(lon2 - lon1)
        a = (math.sin(dlat / 2) * math.sin(dlat / 2) +
             math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) *
             math.sin(dlon / 2) * math.sin(dlon / 2))
        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
        d = radius * c
        
        return d
