#import app_client_pb2
#import app_client_pb2_grpc
#import loc_pb2
import json

import shared_variables

auth_token_global = None
session_cookie_global = None
token_server_uri_global = None
token_global = None

class RegisterClientObject():
    request = None

    def __init__(self, developer_org_name=None, app_name=None, app_version=None, tags=None, auth_token=None, cell_id=None, unique_id=None, unique_id_type=None, use_defaults=True):
        client_dict = {}
        self.dev_name = developer_org_name
        self.app_name = app_name
        self.app_vers = app_version
        self.auth_token = auth_token
        self.cell_id = cell_id
        self.unique_id = unique_id
        self.unique_id_type = unique_id_type
        self.tags = tags
        global auth_token_global
        
        if use_defaults:
            if not app_name: self.app_name = shared_variables.app_name_default
            if not app_version: self.app_vers = shared_variables.app_version_default
            if not developer_org_name: self.dev_name = shared_variables.developer_name_default
            if not auth_token: self.auth_token = auth_token_global
            
        #if auth_token == 'default':
        #    self.auth_token = 
        if self.dev_name is not None:
            client_dict['org_name'] = self.dev_name
        if self.app_name is not None:
            client_dict['app_name'] = self.app_name
        if self.app_vers is not None:
            client_dict['app_vers'] = self.app_vers
        if self.auth_token is not None:
            client_dict['auth_token'] = self.auth_token
        if self.cell_id is not None:
            client_dict['cell_id'] = int(self.cell_id)
        if self.unique_id is not None:
            client_dict['unique_id'] = str(self.unique_id)
        if self.unique_id_type is not None:
            client_dict['unique_id_type'] = self.unique_id_type
        if self.tags is not None:
            client_dict['tags'] = self.tags

        #self.request = app_client_pb2.RegisterClientRequest(**client_dict)
        self.request = json.dumps(client_dict)
        
class FindCloudletRequestObject():
    request_dict = None
    request_dict_string = None
    request = None
    
    def __init__(self, session_cookie=None, carrier_name=None, latitude=None, longitude=None, app_name=None, app_version=None, developer_org_name=None, cell_id=None, timestamp_seconds=None, timestamp_nanos=None, use_defaults=True):
        request_dict = {}
        self.session_cookie = session_cookie
        self.carrier_name = carrier_name
        self.latitude = latitude
        self.longitude = longitude
        self.app_name = app_name
        self.app_version = app_version
        self.developer_name = developer_org_name
        self.seconds = timestamp_seconds
        self.nanos = timestamp_nanos
        self.cell_id = cell_id
        
        if session_cookie == 'default':
            self.session_cookie = shared_variables.session_cookie_default
            
        if use_defaults:
            if not session_cookie: self.session_cookie = shared_variables.session_cookie_default
            if not carrier_name: self.carrier_name = shared_variables.operator_name_default

        time_dict = {}
        if self.seconds is not None:
            time_dict['seconds'] = int(self.seconds)
        if self.nanos is not None:
            time_dict['nanos'] = int(self.nanos)

        loc_dict = {}
        if self.latitude is not None:
            loc_dict['latitude'] = float(self.latitude)
        if self.longitude is not None:
            loc_dict['longitude'] = float(self.longitude)
        if time_dict:
            #loc_dict['timestamp'] = loc_pb2.Timestamp(**time_dict)
            loc_dict['timestamp'] = time_dict

        if self.session_cookie is not None:
            request_dict['session_cookie'] = self.session_cookie
        if self.carrier_name is not None:
            request_dict['carrier_name'] = self.carrier_name
        if self.app_name is not None:
            request_dict['app_name'] = self.app_name
        if self.app_version is not None:
            request_dict['app_vers'] = self.app_version
        if self.developer_name is not None:
            request_dict['org_name'] = self.developer_name
        if self.cell_id is not None:
            request_dict['cell_id'] = int(self.cell_id)

        if loc_dict:
            #request_dict['gps_location'] = loc_pb2.Loc(**loc_dict)
            request_dict['gps_location'] = loc_dict

        #self.request_dict = request_dict
        #self.request_dict_string = str(request_dict).replace('\n', ',')
        #self.request = app_client_pb2.FindCloudletRequest(**request_dict)
        self.request = json.dumps(request_dict)
        #print('*WARN*', 'aa', str(self.request_dict['GpsLocation'].__dict__))

class VerifyLocationRequestObject():
    def __init__(self, session_cookie=None, token=None, carrier_name=None, latitude=None, longitude=None, use_defaults=True):
        request_dict = {}
        self.session_cookie = session_cookie
        self.latitude = latitude
        self.longitude = longitude
        self.carrier_name = carrier_name
        self.token = token

        if session_cookie == 'default':
            self.session_cookie = shared_variables.session_cookie_default

        if token == 'default':
            self.token = shared_variables.token_default

        if use_defaults:
            if not session_cookie: self.session_cookie = shared_variables.session_cookie_default
            if token is None: self.token = shared_variables.token_default

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
            #request_dict['gps_location'] = loc_pb2.Loc(**loc_dict)
            request_dict['gps_location'] = loc_dict
        if self.token is not None:
            request_dict['verify_loc_token'] = self.token

        print(request_dict)
        #self.request = app_client_pb2.VerifyLocationRequest(**request_dict)
        self.request = json.dumps(request_dict)

class GetQosPositionKpiRequestObject():
    request_dict = None
    request_dict_string = None
    request = None
    
    def __init__(self, session_cookie=None, position_list=[], lte_category=None, band_selection=None, cell_id=None, use_defaults=True):
        request_dict = {}
        self.session_cookie = session_cookie
        self.position_list = position_list
        self.lte_category = lte_category
        self.band_selection = band_selection
        self.cell_id = cell_id
        
        if session_cookie == 'default':
            self.session_cookie = shared_variables.session_cookie_default
            
        if use_defaults:
            if not session_cookie: self.session_cookie = shared_variables.session_cookie_default

        position_dict_list = []
        for position in position_list:
            position_dict = {}
            loc_dict = {}
            if 'position_id' in position and position['position_id'] is not None:
                position_dict['positionid'] = position['position_id']
            if 'latitude' in position and position['latitude'] is not None:
                loc_dict['latitude'] = float(position['latitude'])
            if 'longitude' in position and position['longitude'] is not None:
                loc_dict['longitude'] = float(position['longitude'])
            if loc_dict is not None:
                position_dict['gps_location'] = loc_dict
                
            if position_dict:
                position_dict_list.append(position_dict)    


        if self.session_cookie is not None:
            request_dict['session_cookie'] = self.session_cookie
        if self.cell_id is not None:
            request_dict['cell_id'] = int(self.cell_id)
        if self.lte_category is not None:
            request_dict['lte_category'] = int(self.lte_category)
        if self.band_selection is not None:  # this isnt right
            request_dict['band_selection'] = int(self.band_selection)

        if position_dict_list:
            request_dict['positions'] = position_dict_list

        self.request = json.dumps(request_dict)
