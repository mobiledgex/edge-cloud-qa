import sys
import os
import logging
import jwt
import requests
import math
import time
import base64
import json
import queue
import subprocess

from mex_grpc import MexGrpc

import shared_variables

import app_client_pb2
import app_client_pb2_grpc
import loc_pb2
import appcommon_pb2

logging.basicConfig(format='%(asctime)s %(levelname)s %(funcName)s line:%(lineno)d - %(message)s', datefmt='%d-%b-%y %H:%M:%S')
logger = logging.getLogger('mex_dme')

auth_token_global = None
session_cookie_global = None
edge_events_cookie_global = None
token_server_uri_global = None
token_global = None


class Client():
    def __init__(self, developer_org_name=None, app_name=None, app_version=None, auth_token=None, use_defaults=True):
        client_dict = {}
        self.dev_name = developer_org_name
        self.app_name = app_name
        self.app_vers = app_version
        self.auth_token = auth_token

        global auth_token_global

        if use_defaults:
            if not app_name:
                self.app_name = shared_variables.app_name_default
            if not app_version:
                self.app_vers = shared_variables.app_version_default
            if not developer_org_name:
                self.dev_name = shared_variables.developer_name_default
            if not auth_token:
                self.auth_token = auth_token_global

        if self.dev_name is not None:
            client_dict['org_name'] = self.dev_name
        if self.app_name is not None:
            client_dict['app_name'] = self.app_name
        if self.app_vers is not None:
            client_dict['app_vers'] = self.app_vers
        if self.auth_token is not None:
            client_dict['auth_token'] = self.auth_token

        self.client = app_client_pb2.RegisterClientRequest(**client_dict)


class FindCloudletRequest():
    def __init__(self, session_cookie=None, carrier_name=None, latitude=None, longitude=None, data_network_type=None, device_os=None, device_model=None, signal_strength=None, use_defaults=True):
        request_dict = {}
        self.session_cookie = session_cookie
        self.carrier_name = carrier_name
        self.latitude = latitude
        self.longitude = longitude
        self.device_os = device_os
        self.device_model = device_model
        self.signal_strength = signal_strength
        self.data_network_type = data_network_type

        if session_cookie == 'default':
            self.session_cookie = session_cookie_global

        if use_defaults:
            if not session_cookie:
                self.session_cookie = session_cookie_global
            if not carrier_name:
                self.carrier_name = shared_variables.operator_name_default

        loc_dict = {}
        if self.latitude is not None:
            loc_dict['latitude'] = float(self.latitude)
        if self.longitude is not None:
            loc_dict['longitude'] = float(self.longitude)

        if self.session_cookie is not None:
            request_dict['session_cookie'] = self.session_cookie
        if self.carrier_name is not None:
            request_dict['carrier_name'] = self.carrier_name

        device_dict = {}
        if self.device_os is not None:
            device_dict['device_os'] = self.device_os
        if self.device_model is not None:
            device_dict['device_model'] = self.device_model
        if self.signal_strength is not None:
            device_dict['signal_strength'] = int(self.signal_strength)
        if self.data_network_type is not None:
            device_dict['data_network_type'] = self.data_network_type

        if loc_dict:
            request_dict['gps_location'] = loc_pb2.Loc(**loc_dict)

        if device_dict:
            request_dict['device_info'] = appcommon_pb2.DeviceInfo(**device_dict)

        self.request = app_client_pb2.FindCloudletRequest(**request_dict)


class StreamEdgeEvent():
    def __init__(self, session_cookie=None, edge_events_cookie=None, event_type=None, carrier_name=None, latitude=None, longitude=None, samples=None, device_info_data_network_type=None, device_info_os=None, device_info_model=None, device_info_signal_strength=None, use_defaults=True):
        request_dict = {}
        self.session_cookie = session_cookie
        self.edge_events_cookie = edge_events_cookie
        self.event_type = event_type
        self.carrier_name = carrier_name
        self.latitude = latitude
        self.longitude = longitude
        self.samples = samples
        self.device_info_data_network_type = device_info_data_network_type
        self.device_info_os = device_info_os
        self.device_info_model = device_info_model
        self.device_info_signal_strength = device_info_signal_strength

        if session_cookie == 'default':
            self.session_cookie = session_cookie_global

        if use_defaults:
            if not session_cookie:
                self.session_cookie = session_cookie_global
            if not edge_events_cookie:
                self.edge_events_cookie = edge_events_cookie_global
            if not carrier_name:
                self.carrier_name = shared_variables.operator_name_default

        loc_dict = {}
        if self.latitude is not None:
            loc_dict['latitude'] = float(self.latitude)
        if self.longitude is not None:
            loc_dict['longitude'] = float(self.longitude)

        if self.session_cookie is not None:
            request_dict['session_cookie'] = self.session_cookie
        if self.carrier_name is not None:
            request_dict['carrier_name'] = self.carrier_name
        if self.edge_events_cookie is not None:
            request_dict['edge_events_cookie'] = self.edge_events_cookie
        if self.event_type is not None:
            request_dict['event_type'] = int(self.event_type)

        samples_list = []
        if self.samples is not None:
            for s in self.samples:
                sample_dict = {'value': float(s)}
                samples_list.append(loc_pb2.Sample(**sample_dict))

            request_dict['samples'] = samples_list

        device_dict = {}
        if self.device_info_data_network_type:
            device_dict['data_network_type'] = self.device_info_data_network_type
        if self.device_info_os:
            device_dict['device_os'] = self.device_info_os
        if self.device_info_model:
            device_dict['device_model'] = self.device_info_model
        if self.device_info_signal_strength:
            device_dict['signal_strength'] = int(self.device_info_signal_strength)

        if loc_dict:
            request_dict['gps_location'] = loc_pb2.Loc(**loc_dict)

        if device_dict:
            request_dict['device_info'] = appcommon_pb2.DeviceInfo(**device_dict)

        self.request = app_client_pb2.ClientEdgeEvent(**request_dict)


class PlatformFindCloudletRequest():
    def __init__(self, session_cookie=None, carrier_name=None, client_token=None, use_defaults=True):
        request_dict = {}
        self.session_cookie = session_cookie
        self.carrier_name = carrier_name
        self.client_token = client_token

        if session_cookie == 'default':
            self.session_cookie = session_cookie_global

        if use_defaults:
            if not session_cookie:
                self.session_cookie = session_cookie_global
            if not carrier_name:
                self.carrier_name = shared_variables.operator_name_default

        if self.session_cookie is not None:
            request_dict['session_cookie'] = self.session_cookie
        if self.carrier_name is not None:
            request_dict['carrier_name'] = self.carrier_name
        if self.client_token is not None:
            request_dict['client_token'] = self.client_token

        self.request = app_client_pb2.PlatformFindCloudletRequest(**request_dict)


class GetAppOfficialFqdnRequest():
    def __init__(self, session_cookie=None, latitude=None, longitude=None, use_defaults=True):
        request_dict = {}
        self.session_cookie = session_cookie
        self.latitude = latitude
        self.longitude = longitude

        if session_cookie == 'default':
            self.session_cookie = session_cookie_global

        if use_defaults:
            if not session_cookie:
                self.session_cookie = session_cookie_global

        loc_dict = {}
        if self.latitude is not None:
            loc_dict['latitude'] = float(self.latitude)
        if self.longitude is not None:
            loc_dict['longitude'] = float(self.longitude)

        if self.session_cookie is not None:
            request_dict['session_cookie'] = self.session_cookie

        if loc_dict:
            request_dict['gps_location'] = loc_pb2.Loc(**loc_dict)

        print('*WARN*', app_client_pb2)
        self.request = app_client_pb2.AppOfficialFqdnRequest(**request_dict)


class GetFqdnList():
    def __init__(self, session_cookie=None, use_defaults=True):

        request_dict = {}
        self.session_cookie = session_cookie

        if session_cookie == 'default':
            self.session_cookie = session_cookie_global

        if use_defaults:
            if not session_cookie:
                self.session_cookie = session_cookie_global

        if self.session_cookie is not None:
            request_dict['session_cookie'] = self.session_cookie

        self.request = app_client_pb2.FqdnListRequest(**request_dict)


class GetAppInstList():
    def __init__(self, session_cookie=None, carrier_name=None, latitude=None, longitude=None, limit=None, use_defaults=True):

        request_dict = {}
        self.session_cookie = session_cookie
        self.latitude = latitude
        self.longitude = longitude
        self.carrier_name = carrier_name
        self.limit = limit

        if session_cookie == 'default':
            self.session_cookie = session_cookie_global

        if use_defaults:
            if not session_cookie:
                self.session_cookie = session_cookie_global

        loc_dict = {}
        if self.latitude is not None:
            loc_dict['latitude'] = float(self.latitude)
        if self.longitude is not None:
            loc_dict['longitude'] = float(self.longitude)

        if self.session_cookie is not None:
            request_dict['session_cookie'] = self.session_cookie
        if loc_dict:
            request_dict['gps_location'] = loc_pb2.Loc(**loc_dict)
        if self.carrier_name is not None:
            request_dict['carrier_name'] = self.carrier_name
        if self.limit is not None:
            request_dict['limit'] = int(self.limit)

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
            if not session_cookie:
                self.session_cookie = session_cookie_global
            if token is None:
                self.token = token_global

        loc_dict = {}
        if self.latitude is not None:
            loc_dict['latitude'] = float(self.latitude)
        if self.longitude is not None:
            loc_dict['longitude'] = float(self.longitude)

        if self.session_cookie is not None:
            request_dict['session_cookie'] = self.session_cookie
        if self.carrier_name is not None:
            request_dict['carrier_name'] = self.carrier_name
        if loc_dict:
            request_dict['gps_location'] = loc_pb2.Loc(**loc_dict)
        if self.token is not None:
            request_dict['verify_loc_token'] = self.token

        self.request = app_client_pb2.VerifyLocationRequest(**request_dict)


class GetLocation():
    def __init__(self, session_cookie=None, carrier_name=None, use_defaults=True):
        request_dict = {}
        self.session_cookie = session_cookie
        self.carrier_name = carrier_name

        if session_cookie == 'default':
            self.session_cookie = session_cookie_global

        if use_defaults:
            if not session_cookie:
                self.session_cookie = session_cookie_global

        if self.session_cookie is not None:
            request_dict['session_cookie'] = self.session_cookie
        if self.carrier_name is not None:
            request_dict['carrier_name'] = self.carrier_name

        self.request = app_client_pb2.GetLocationRequest(**request_dict)

# class EdgeEventClient():
#    def __init__(self, address, client_edge_event_obj=None, **kwargs):
#        self.edge_event_queue = queue.SimpleQueue()
#        self.edge_event_stream = None
#
#        self.create_dme_persistent_connection(address, client_edge_event_obj, **kwargs)
#
#    def create_dme_persistent_connection(self, address, client_edge_event_obj=None, **kwargs):
#        response = None
#
#        if not client_edge_event_obj:
#            kwargs['event_type'] = 1
#            request = StreamEdgeEvent(**kwargs).request
#
#        logger.info('stream edge event on {}. \n\t{}'.format(address, str(request).replace('\n','\n\t')))
#
#        #send_queue = queue.SimpleQueue()
#        #my_event_stream = self.match_engine_stub.StreamEdgeEvent(iter(send_queue.get, None))
#        self.edge_event_stream = self.match_engine_stub.StreamEdgeEvent(iter(self.edge_event_queue.get, None))
#        print('*WARN*', 'stream created')
#        self.edge_event_queue.put(request)
#        print('*WARN*', 'stream in queue')
#
#        response = next(self.edge_event_stream)
#        logger.info(f'response={response}')
#        #print('*WARN*', 'edgeresp', response, type(response), dir(response))
#        #print('*WARN*', repr(response), app_client_pb2.ServerEdgeEvent.EVENT_INIT_CONNECTION, type(response), type(app_client_pb2.ServerEdgeEvent.EVENT_INIT_CONNECTION), dir(app_client_pb2.ServerEdgeEvent.EVENT_INIT_CONNECTION))
#
#        if response.event_type != app_client_pb2.ServerEdgeEvent.EVENT_INIT_CONNECTION: # FIND_FOUND
#            raise Exception(f'stream edge event error. expected event_type: {app_client_pb2.ServerEdgeEvent.EVENT_INIT_CONNECTION}, got {response}')
#
#        #return edge_event_stream, send_queue


class MexDme(MexGrpc):
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self, dme_address='127.0.0.1:50051', root_cert='mex-ca.crt', key='localserver.key', client_cert='localserver.crt'):
        self.session_cookie = None
        self._decoded_session_cookie = None
        self._token_server_uri = None

        self.edge_event_queue = queue.SimpleQueue()
        self.edge_event_stream = None

        self.client_token = None
        self._decoded_client_token = None

        if '127.0.0.1' in dme_address:
            super(MexDme, self).__init__(address=dme_address, root_cert=root_cert, key=key, client_cert=client_cert)
        else:
            super(MexDme, self).__init__(address=dme_address)

        self.match_engine_stub = app_client_pb2_grpc.MatchEngineApiStub(self.grpc_channel)

        self._init_globals()

        global auth_token_global

    def decoded_session_cookie(self):
        return self._decoded_session_cookie

    def decoded_client_token(self):
        return self._decoded_client_token

    def token_server_uri(self):
        return self._token_server_uri

    def register_client(self, register_client_obj=None, **kwargs):
        global session_cookie_global
        global token_server_uri_global

        resp = None

        if not register_client_obj:
            register_client_obj = Client(**kwargs).client

        logger.info('register client on {}. \n\t{}'.format(self.address, str(register_client_obj).replace('\n', '\n\t')))

        resp = self.match_engine_stub.RegisterClient(register_client_obj)
        self.session_cookie = resp.session_cookie
        session_cookie_global = resp.session_cookie

        token_server_uri_global = resp.token_server_uri
        self._token_server_uri = resp.token_server_uri
        logger.debug('session_cookie=' + self.session_cookie)
        logger.debug('token server uri=' + self._token_server_uri)

        self._decoded_session_cookie = jwt.decode(self.session_cookie, verify=False)

        return resp

    def find_cloudlet(self, find_cloudlet_obj=None, **kwargs):
        global edge_events_cookie_global

        resp = None

        if not find_cloudlet_obj:
            find_cloudlet_obj = FindCloudletRequest(**kwargs).request

        logger.info('find cloudlet on {}. \n\t{}'.format(self.address, str(find_cloudlet_obj).replace('\n', '\n\t')))

        resp = self.match_engine_stub.FindCloudlet(find_cloudlet_obj)

        if resp.status != 1:  # FIND_FOUND
            raise Exception('find cloudlet not found:{}'.format(str(resp)))

        edge_events_cookie_global = resp.edge_events_cookie

        return resp

    def create_dme_persistent_connection(self, client_edge_event_obj=None, **kwargs):
        response = None

        self.edge_event_stream = None
        self.edge_event_queue = queue.SimpleQueue()

        if not client_edge_event_obj:
            kwargs['event_type'] = 1
            request = StreamEdgeEvent(**kwargs).request

        logger.info('stream edge event on {}. \n\t{}'.format(self.address, str(request).replace('\n', '\n\t')))

        self.edge_event_stream = self.match_engine_stub.StreamEdgeEvent(iter(self.edge_event_queue.get, None))
        logger.info('stream created')
        self.edge_event_queue.put(request)
        logger.info('stream in queue')

        try:
            response = next(self.edge_event_stream)
        except Exception as e:
            self.edge_event_stream = None
            self.edge_event_queue = queue.SimpleQueue()
            raise Exception(e)

        logger.info(f'response={response}')

        if response.event_type != app_client_pb2.ServerEdgeEvent.EVENT_INIT_CONNECTION:
            raise Exception(f'stream edge event error. expected event_type: {app_client_pb2.ServerEdgeEvent.EVENT_INIT_CONNECTION}, got {response}')

    def terminate_dme_persistent_connection(self, client_edge_event_obj=None, **kwargs):
        response = None

        if not client_edge_event_obj:
            kwargs['event_type'] = 2
            request = StreamEdgeEvent(**kwargs).request

        logger.info('terminate dme persistent connection on {}. \n\t{}'.format(self.address, str(request).replace('\n', '\n\t')))

        self.edge_event_queue.put(request)

        try:
            response = next(self.edge_event_stream)
            logger.info(f'terminate connection response:{response}')
        except StopIteration:
            logger.info('stream closed')
        except Exception as e:
            raise Exception(f'terminate stream error. got exception: {e}')

        self.edge_event_stream = None
        self.edge_event_queue = queue.SimpleQueue()

    def create_client_edge_event(self, client_edge_event_obj=None, **kwargs):
        response = None

        if not client_edge_event_obj:
            request = StreamEdgeEvent(**kwargs).request

        logger.info('stream edge event on {}. \n\t{}'.format(self.address, str(request).replace('\n', '\n\t')))

        self.edge_event_queue.put(request)
        response = next(self.edge_event_stream)
        logging.debug(f'response:{response}')
        if kwargs['event_type'] == 3:  # EVENT_LATENCY_REQUEST
            if response.event_type != app_client_pb2.ServerEdgeEvent.EVENT_LATENCY_PROCESSED:
                raise Exception(f'stream edge event error. expected event_type: EVENT_LATENCY_REQUEST, got {response}')
        if kwargs['event_type'] == 4:  # EVENT_CLOUDLET_UPDATE
            if response.event_type != app_client_pb2.ServerEdgeEvent.EVENT_CLOUDLET_UPDATE:
                raise Exception(f'stream edge event error. expected event_type: EVENT_CLOUDLET_UPDATE, got {response}')

        return response

    def send_latency_edge_event(self, client_edge_event_obj=None, **kwargs):
        resp = None

        kwargs['event_type'] = 3
        kwargs['use_defaults'] = False
        resp = self.create_client_edge_event(**kwargs)

        return resp

    def send_location_update_edge_event(self, client_edge_event_obj=None, **kwargs):
        resp = None

        kwargs['event_type'] = 4
        kwargs['use_defaults'] = False
        resp = self.create_client_edge_event(**kwargs)

        return resp

    def receive_edge_event(self, timeout=10):
        logger.info('receive edge event')
        request = next(self.edge_event_stream, 'nothing')
        logger.info(f'received edge event {request}')

        return request

    def receive_latency_edge_request(self):
        request = self.receive_edge_event()

        if request.event_type != app_client_pb2.ServerEdgeEvent.EVENT_LATENCY_REQUEST:
            raise Exception(f'stream edge event request error. expected event_type: {app_client_pb2.ServerEdgeEvent.EVENT_LATENCY_REQUEST}, got {request}')

    def platform_find_cloudlet(self, find_cloudlet_obj=None, **kwargs):
        resp = None

        if not find_cloudlet_obj:
            request = PlatformFindCloudletRequest(**kwargs).request

        logger.info('platform find cloudlet on {}. \n\t{}'.format(self.address, str(request).replace('\n', '\n\t')))

        resp = self.match_engine_stub.PlatformFindCloudlet(request)

        if resp.status != 1:  # FIND_FOUND
            raise Exception('platform find cloudlet not found:{}'.format(str(resp)))

        return resp

    def get_app_official_fqdn(self, get_app_official_fqdn_obj=None, **kwargs):
        resp = None

        if not get_app_official_fqdn_obj:
            request = GetAppOfficialFqdnRequest(**kwargs).request

        logger.info('get app official fqdn request on {}. \n\t{}'.format(self.address, str(request).replace('\n', '\n\t')))

        resp = self.match_engine_stub.GetAppOfficialFqdn(request)
        self.client_token = resp.client_token
        self._decoded_client_token = resp.client_token

        self._decoded_client_token = json.loads(base64.b64decode(self.client_token).decode('ascii'))

        if resp.status != 1:  # FIND_FOUND
            raise Exception('platform find cloudlet not found:{}'.format(str(resp)))

        return resp

    def get_fqdn_list(self, get_fqdn_list_obj=None, **kwargs):
        resp = None

        if not get_fqdn_list_obj:
            request = GetFqdnList(**kwargs).request

        logger.info('get fqdn list on {}. \n\t{}'.format(self.address, str(request).replace('\n', '\n\t')))

        resp = self.match_engine_stub.GetFqdnList(request)

        if resp.status != 1:  # FL_SUCCESS
            raise Exception('get fqdn list failed:{}'.format(str(resp)))

        resp = sorted(resp.app_fqdns, key=lambda x: x.fqdns[0])  # sorting since need to check for may apps. this return the sorted list instead of the response itself

        return resp

    def get_app_instance_list(self, get_app_instance_request_obj=None, **kwargs):
        resp = None

        if not get_app_instance_request_obj:
            request = GetAppInstList(**kwargs).request

        logger.info('get app instance list on {}. \n\t{}'.format(self.address, str(request).replace('\n', '\n\t')))

        resp = self.match_engine_stub.GetAppInstList(request)

        if resp.status != 1:  # AI_SUCCESS
            raise Exception('get app inst list failed:{}'.format(str(resp)))

        # removed this since it now returns a list sorted by distance
        # resp = sorted(resp.cloudlets, key=lambda x: x.cloudlet_name) # sorting since need to check for may apps. this return the sorted list instead of the response itself

        return resp.cloudlets

    def verify_location(self, verify_location_request_obj=None, **kwargs):
        resp = None

        if not verify_location_request_obj:
            request = VerifyLocation(**kwargs).request

        logger.info('verify location on {}. \n\t{}'.format(self.address, str(request).replace('\n', '\n\t')))

        resp = self.match_engine_stub.VerifyLocation(request)

        return resp

    def get_location(self, get_location_request_obj=None, **kwargs):
        resp = None

        if not get_location_request_obj:
            request = GetLocation(**kwargs).request

        logger.info('get location on {}. \n\t{}'.format(self.address, str(request).replace('\n', '\n\t')))

        resp = self.match_engine_stub.GetLocation(request)

        return resp

    def update_location(self, latitude, longitude, ip_address=None):
        if ip_address is None:
            ip_address = subprocess.run('curl ifconfig.me', shell=True, check=True, capture_output=True).stdout.decode('ascii')

        logger.info('updating location with ipaddr={} lat={} long={}'.format(ip_address, latitude, longitude))

        location_server = 'http://mexdemo.locsim.mobiledgex.net:8888/updateLocation'
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

        process = subprocess.run(cmd,
                                 # stdout=subprocess.DEVNULL,
                                 # stderr=subprocess.DEVNULL,
                                 # stdout=open(log_file, 'w'),
                                 shell=True,
                                 text=True,
                                 capture_output=True
                                 )

        logger.debug('stdout=' + process.stdout)
        token = process.stdout.lstrip('Token:').lstrip().rstrip()
        logger.debug('generated token: ' + token)

        auth_token_global = token

        return token

    def generate_session_cookie(self):
        key = '{"key": {"peerip":"10.138.0.10","devname":"developer1553621810-915217","appname":"app1553621810-915217","appvers":"1.0","kid":6}'
        current_time = int(time.time())
        exp_time = int(time.time()) + 10
        payload = {"exp": current_time,
                   "iat": exp_time}
        encoded_jwt = jwt.encode(payload, key, algorithm='HS256')

        return encoded_jwt

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

    def calculate_distance(self, origin=None, destination=None):
        lat1, lon1 = origin
        lat2, lon2 = destination
        lat1 = float(lat1)
        lat2 = float(lat2)
        lon1 = float(lon1)
        lon2 = float(lon2)

        radius = 6371  # km

        dlat = math.radians(lat2 - lat1)
        dlon = math.radians(lon2 - lon1)
        # print(dlat,dlon, math.sin(dlat / 2), math.sin(dlat / 2), math.cos(math.radians(lat1))) #, math.cos(math.radians(lat2)), math.sin(dlon / 2), math.sin(dlon / 2))
        a = (math.sin(dlat / 2) * math.sin(dlat / 2)
             + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2))
             * math.sin(dlon / 2) * math.sin(dlon / 2))
        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
        d = radius * c

        return d

    def _findFile(self, path):
        for dirname in sys.path:
            candidate = os.path.join(dirname, path)
            if os.path.isfile(candidate):
                return candidate
        raise Exception('cant find file {}'.format(path))

    def _init_globals(self):
        global auth_token_global
        global session_cookie_global
        global token_server_uri_global
        global token_global

        auth_token_global = None
        session_cookie_global = None
        token_server_uri_global = None
        token_global = None
