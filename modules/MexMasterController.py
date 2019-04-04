import json
import jwt
import logging
import time

from mex_rest import MexRest

logging.basicConfig(format='%(asctime)s %(levelname)s %(funcName)s line:%(lineno)d - %(message)s',datefmt='%d-%b-%y %H:%M:%S')
logger = logging.getLogger('mex_dme rest')

class MexMasterController(MexRest):

    def __init__(self, mc_address='127.0.0.1:9900', root_cert='mex-ca.crt'):
        super().__init__(address=mc_address, root_cert=root_cert)
        print('*WARN*', 'mcinit')
        self.root_url = f'https://{mc_address}/api/v1'
        self.root_cert = root_cert
        self.token = None

        self.username = 'mexadmin'
        self.password = 'mexadmin123'
        
        self._decoded_token = None

    def decoded_token(self):
        return self._decoded_token

    def created_username(self):
        return self.username

    def created_password(self):
        return self.password
    
    def login(self, username=None, password=None, json_data=None, use_defaults=True):
        url = self.root_url + '/login'
        payload = None
        
        if json_data:
            payload = json_data
        else:
            if use_defaults:
                if username is None: username = self.username
                if password is None: password = self.password
                
            login_dict = {}
            if username is not None:
                login_dict['username'] = username
            if password is not None:
                login_dict['password'] = password
            payload = json.dumps(login_dict)

        logger.info('login to mc at {}. \n\t{}'.format(url, payload))

        self.post(url=url, data=payload)
        
        logger.info('response:\n' + str(self.resp.text))

        self.token = self.decoded_data['token']
        self._decoded_token = jwt.decode(self.token, verify=False)

    def create_user(self, username=None, password=None, email=None, json_data=None):
        timestamp = str(time.time())
        url = self.root_url + '/usercreate'
        payload = None
        
        if username is None:
            username = 'name' + timestamp
        if password is None:
            password = 'password' + timestamp
        if email is None:
            email = username + '@email.com'

        
        if json_data:
            payload = json_data
        else:
            user_dict = {}
            if username is not None:
                user_dict['name'] = username
            if password is not None:
                user_dict['passhash'] = password
            if email is not None:
                user_dict['email'] = email
                
            payload = json.dumps(user_dict)

        logger.info('usercreate on mc at {}. \n\t{}'.format(url, payload))

        self.post(url=url, data=payload)
        
        logger.info('response:\n' + str(self.resp.text))
            
        if str(self.resp.text) != '{"message":"user created"}':
            raise Exception("error creating user. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())

        self.username = username
        self.password = password
        self.email = email
        
        return username, password, email
        
    def get_current_user(self, token=None, use_defaults=True):
        url = self.root_url + '/auth/user/current'

        logger.info('user/current on mc at {}'.format(url))

        if use_defaults:
            if token is None: token = self.token

        if token is None:
            self.post(url=url)
        else:
            self.post(url=url, bearer=token)
                
        
        logger.info('response:\n' + str(self.resp.text))

        return self.decoded_data
