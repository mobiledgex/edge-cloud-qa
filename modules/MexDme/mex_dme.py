import grpc
import sys
import os
import subprocess
import shlex
import logging
import jwt
import requests
import subprocess

from mex_grpc import MexGrpc

import shared_variables

import app_client_pb2
import app_client_pb2_grpc
import loc_pb2

logging.basicConfig(format='%(asctime)s %(levelname)s %(funcName)s line:%(lineno)d - %(message)s',datefmt='%d-%b-%y %H:%M:%S')
logger = logging.getLogger('mex_dme')

auth_token_global = None
session_cookie_global = None
token_server_uri_global = None
token_global = None

class Client():
    def __init__(self, developer_name=None, app_name=None, app_version=None, auth_token=None, use_defaults=True):
        client_dict = {}
        self.dev_name = developer_name
        self.app_name = app_name
        self.app_vers = app_version
        self.auth_token = auth_token

        global auth_token_global
        
        if use_defaults:
            if not app_name: self.app_name = shared_variables.app_name_default
            if not app_version: self.app_vers = shared_variables.app_version_default
            if not developer_name: self.dev_name = shared_variables.developer_name_default
            if not auth_token: self.auth_token = auth_token_global
            
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
    def __init__(self, session_cookie=None, carrier_name=None, latitude=None, longitude=None, app_name=None, app_version=None, developer_name=None, use_defaults=True):
        request_dict = {}
        self.session_cookie = session_cookie
        self.carrier_name = carrier_name
        self.latitude = latitude
        self.longitude = longitude
        self.app_name = app_name
        self.app_version = app_version
        self.developer_name = developer_name

        if session_cookie == 'default':
            self.session_cookie = session_cookie_global
            
        if use_defaults:
            if not session_cookie: self.session_cookie = session_cookie_global
            if not carrier_name: self.carrier_name = shared_variables.operator_name_default

        loc_dict = {}
        if self.latitude is not None:
            loc_dict['latitude'] = float(self.latitude)
        if self.longitude is not None:
            loc_dict['longitude'] = float(self.longitude)

        if self.session_cookie is not None:
            request_dict['SessionCookie'] = self.session_cookie
        if self.carrier_name is not None:
            request_dict['CarrierName'] = self.carrier_name
        if self.app_name is not None:
            request_dict['AppName'] = self.app_name
        if self.app_version is not None:
            request_dict['AppVers'] = self.app_version
        if self.developer_name is not None:
            request_dict['DevName'] = self.developer_name

        if loc_dict:
            request_dict['GpsLocation'] = loc_pb2.Loc(**loc_dict)

        #print(loc_dict)
        self.request = app_client_pb2.FindCloudletRequest(**request_dict)

class GetFqdnList():
    def __init__(self, session_cookie=None, use_defaults=True):

        request_dict = {}
        self.session_cookie = session_cookie

        if session_cookie == 'default':
            self.session_cookie = session_cookie_global
            
        if use_defaults:
            if not session_cookie: self.session_cookie = session_cookie_global

        if self.session_cookie is not None:
            request_dict['SessionCookie'] = self.session_cookie

        self.request = app_client_pb2.FqdnListRequest(**request_dict)

class GetAppInstList():
    def __init__(self, session_cookie=None, latitude=None, longitude=None, use_defaults=True):

        request_dict = {}
        self.session_cookie = session_cookie
        self.latitude = latitude
        self.longitude = longitude

        if session_cookie == 'default':
            self.session_cookie = session_cookie_global
            
        if use_defaults:
            if not session_cookie: self.session_cookie = session_cookie_global

        loc_dict = {}
        if self.latitude is not None:
            loc_dict['latitude'] = float(self.latitude)
        if self.longitude is not None:
            loc_dict['longitude'] = float(self.longitude)

        if self.session_cookie is not None:
            request_dict['SessionCookie'] = self.session_cookie    
        if loc_dict:
            request_dict['GpsLocation'] = loc_pb2.Loc(**loc_dict)

        self.request = app_client_pb2.AppInstListRequest(**request_dict)

class VerifyLocation():
    def __init__(self, session_cookie=None, token=None, carrier_name=None, latitude=None, longitude=None, use_defaults=True):
        request_dict = {}
        self.session_cookie = session_cookie
        self.latitude = latitude
        self.longitude = longitude
        self.carrier_name = carrier_name
        self.token = token

        if session_cookie == 'default':
            self.session_cookie = session_cookie_global

        if token == 'default':
            self.token = token_global

        if use_defaults:
            if not session_cookie: self.session_cookie = session_cookie_global
            if token is None: self.token = token_global

        loc_dict = {}
        if self.latitude is not None:
            loc_dict['latitude'] = float(self.latitude)
        if self.longitude is not None:
            loc_dict['longitude'] = float(self.longitude)

        if self.session_cookie is not None:
            request_dict['SessionCookie'] = self.session_cookie
        if self.carrier_name is not None:
            request_dict['CarrierName'] = self.carrier_name    
        if loc_dict:
            request_dict['GpsLocation'] = loc_pb2.Loc(**loc_dict)
        if self.token is not None:
            request_dict['VerifyLocToken'] = self.token

        print(request_dict)
        self.request = app_client_pb2.VerifyLocationRequest(**request_dict)

class Dme(MexGrpc):
    def __init__(self, dme_address='127.0.0.1:50051', root_cert='mex-ca.crt', key='localserver.key', client_cert='localserver.crt'):
        #self.developer_list = []
        #self.operator_list = []
        #self.app_list = []

        self.session_cookie = None
        self._decoded_session_cookie = None
        self._token_server_uri = None
        #self._auth_token = None
        
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
        global session_cookie_global
        global token_server_uri_global
        
        resp = None

        if not register_client_obj:
            #if len(kwargs) == 0:
            #    kwargs = {'use_defaults': True}
            #    if 'auth_token' not in kwargs:
            #        kwargs['auth_token'] = self._auth_token

            request = Client(**kwargs).client

        logger.info('register client on {}. \n\t{}'.format(self.address, str(request).replace('\n','\n\t')))
                    
        resp = self.match_engine_stub.RegisterClient(request)
        self.session_cookie = resp.SessionCookie
        session_cookie_global = resp.SessionCookie
        token_server_uri_global = resp.TokenServerURI
        self._token_server_uri = resp.TokenServerURI
        logger.debug('session_cookie=' + self.session_cookie)
        logger.debug('token server uri=' + self._token_server_uri)

        self._decoded_session_cookie = jwt.decode(self.session_cookie, verify=False)

        return resp

    def find_cloudlet(self, find_cloudlet_obj=None, **kwargs):
        resp = None

        if not find_cloudlet_obj:
            #if len(kwargs) == 0:
            #    kwargs = {'use_defaults': True}
            #if 'session_cookie' not in kwargs:
            #    kwargs['session_cookie'] = self.session_cookie
            request = FindCloudletRequest(**kwargs).request

        logger.info('find cloudlet on {}. \n\t{}'.format(self.address, str(request).replace('\n','\n\t')))
                    
        resp = self.match_engine_stub.FindCloudlet(request)

        if resp.status != 1: # FIND_FOUND
            raise Exception('find cloudlet not found:{}'.format(str(resp)))

        return resp

    def get_fqdn_list(self, get_fqdn_list_obj=None, **kwargs):
        resp = None

        if not get_fqdn_list_obj:
            request = GetFqdnList(**kwargs).request

        logger.info('get fqdn list on {}. \n\t{}'.format(self.address, str(request).replace('\n','\n\t')))
                    
        resp = self.match_engine_stub.GetFqdnList(request)

        if resp.Status != 1: # FL_SUCCESS
            raise Exception('get fqdn list failed:{}'.format(str(resp)))

        resp = sorted(resp.AppFqdns, key=lambda x: x.FQDN) # sorting since need to check for may apps. this return the sorted list instead of the response itself
        print(resp)

        return resp

    def get_app_instance_list(self, get_app_instance_request_obj=None, **kwargs):
        resp = None

        if not get_app_instance_request_obj:
            request = GetAppInstList(**kwargs).request

        logger.info('get app instance list on {}. \n\t{}'.format(self.address, str(get_app_instance_request_obj).replace('\n','\n\t')))

        resp = self.match_engine_stub.GetAppInstList(request)

        if resp.Status != 1: # FL_SUCCESS
            raise Exception('get app inst list failed:{}'.format(str(resp)))

        #resp = sorted(resp.AppFqdns, key=lambda x: x.FQDN) # sorting since need to check for may apps. this return the sorted list instead of the response itself
        #print(resp)

        return resp

    def verify_location(self, verify_location_request_obj=None, **kwargs):
        resp = None

        if not verify_location_request_obj:
            request = VerifyLocation(**kwargs).request

        logger.info('verify location on {}. \n\t{}'.format(self.address, str(request).replace('\n','\n\t')))

        resp = self.match_engine_stub.VerifyLocation(request)

        return resp

    def update_location(self, latitude, longitude, ip_address=None):
        if ip_address is None:
            ip_address = subprocess.run('curl ifconfig.me', shell=True, check=True, capture_output=True).stdout.decode('ascii')

        logger.info('updating location with ipaddr={} lat={} long={}'.format(ip_address, latitude, longitude))

        location_server = 'http://mextest.locsim.mobiledgex.net:8888/updateLocation'
        payload = '{"latitude":' + str(latitude) + ', "longitude":' + longitude + ', "ipaddr": "' + ip_address + '"}'
        
        requests.post(location_server, data=payload)
            

    def generate_auth_token(self, app_name, app_version, developer_name, key_file='authtoken_private.pem'):
        global auth_token_global
        
        logger.info('generating token for {} {} {} {}'.format(app_name, app_version, developer_name, key_file))

        key_file = self._findFile(key_file)

        if not os.path.isfile(key_file):
            logger.error(f'key_file={key_file} does not exist')
            return None
        
        cmd = 'genauthtoken -appname ' + app_name + ' -appvers ' + app_version + ' -devname ' + developer_name + ' -privkeyfile ' + key_file
        logger.debug('cmd=' + cmd)
        
        #process = subprocess.Popen(shlex.split(cmd),
        process = subprocess.run(cmd,
                                   #stdout=subprocess.DEVNULL,
                                   #stderr=subprocess.DEVNULL,
                                   #stdout=open(log_file, 'w'),
                                   shell=True,
                                 text=True,
                                   capture_output=True
        )
        
        logger.debug('stdout=' + process.stdout)
        token = process.stdout.lstrip('Token:').lstrip().rstrip()
        #token = token.lstrip().rstrip()
        logger.debug('generated token: ' + token)

        #self._auth_token = token
        auth_token_global = token
        
        return token

    def get_token(self, token_server=None):
        global token_global
        
        if token_server is None:
            token_server = token_server_uri_global
            
        logger.info('getting token from {}'.format(token_server))

        resp = requests.get(token_server, allow_redirects=False)

        location = resp.headers['Location']
        logger.debug('location header:{}'.format(location))

        token = location.split('dt-id=')[1]
        token_global = token
        logger.debug('token={}'.format(token))

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

    def _findFile(self, path):
        for dirname in sys.path:
            candidate = os.path.join(dirname, path)
            if os.path.isfile(candidate):
                return candidate
        raise Error('cant find file {}'.format(path))
