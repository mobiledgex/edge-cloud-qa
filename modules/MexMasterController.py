import json
import jwt
import logging
import time
import re

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
        self.prov_stack = []

        self.username = 'mexadmin'
        self.password = 'mexadmin123'
        
        self.super_token = None
        self._decoded_token = None
        self.org = None
        self.orgtype = None
        self.address = None
        self.phone = None

        self.super_token = self.login(self.username, self.password, None, False)

    def get_supertoken(self):
        return self.supe_token

    def get_token(self):
        return self.token

    def decoded_token(self):
        return self._decoded_token

    def created_username(self):
        return self.username

    def created_password(self):
        return self.password

    def created_org(self):
        orginfo = 'Name:' + self.org + '  Type:' + self.orgtype + '  Address:' + self.address + '  Phone:' + self.phone
        return orginfo
    
    def login(self, username=None, password=None, json_data=None, use_defaults=True):
        url = self.root_url + '/login'
        payload = None
        
        if json_data is not None:
            payload = json_data
        else:
            if use_defaults == True:
                if username == None: username = self.username
                if password == None: password = self.password
                
            login_dict = {}
            if username != None:
                login_dict['username'] = username
            if password != None:
                login_dict['password'] = password
            payload = json.dumps(login_dict)

        logger.info('login to mc at {}. \n\t{}'.format(url, payload))

        self.post(url=url, data=payload)
        
        logger.info('response:\n' + str(self.resp.text))

        self.token = self.decoded_data['token']
        self._decoded_token = jwt.decode(self.token, verify=False)

        return self.token

    def create_user(self, username=None, password=None, email=None, json_data=None, use_defaults=True):
        timestamp = str(time.time())
        url = self.root_url + '/usercreate'
        payload = None

        if use_defaults == True:
            if username == None: username = 'name' + timestamp
            if password == None: password = 'password' + timestamp
            if email == None: email = username + '@email.com'

        if json_data != None:
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

        self.prov_stack.append(lambda:self.delete_user(username, password, email, self.super_token))

        self.username = username
        self.password = password
        self.email = email
        
        return username, password, email
        
    def get_current_user(self, token=None, use_defaults=True):
        url = self.root_url + '/auth/user/current'

        logger.info('user/current on mc at {}'.format(url))

        if use_defaults == True:
            if token is None: token = self.token

        if token == None:
            self.post(url=url)
        else:
            self.post(url=url, bearer=token)
                
        
        logger.info('response:\n' + str(self.resp.text))

        return self.decoded_data

    def delete_user(self, username=None, password=None, email=None, token=None, json_data=None, use_defaults=True):
        timestamp = str(time.time())
        url = self.root_url + '/auth/user/delete'
        payload = None

        if use_defaults == True:
            if token is None: token = self.token
            if username is None: username = self.username
            if password is None: password = self.password
            if email is None: email = self.username
        
        if json_data !=  None:
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

        logger.info('delete/user on mc at {}. \n\t{}'.format(url, payload))

        self.post(url=url, data=payload, bearer=token)
        
        logger.info('response:\n' + str(self.resp.text))
            
        if str(self.resp.text) != '{"message":"user deleted"}':
            raise Exception("error creating user. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())

    def new_password(self, password=None, token=None, json_data=None, use_defaults=True):
        timestamp = str(time.time())
        url = self.root_url + '/auth/user/newpass'
     
        if use_defaults == True:
            if token == None: token = self.token
            if password == None: password = self.password

        if json_data != None:
            payload = json_data
        else:
            user_dict = {}
            if password != None:
                user_dict['password'] = password
                
            payload = json.dumps(user_dict)

        #print('*WARN*',token) 

        self.post(url=url, data=payload, bearer=token)
        
        logger.info('response:\n' + str(self.resp.text))
            
        if str(self.resp.text) != '{"message":"password updated"}':
            raise Exception("error changing password. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())

    def show_role(self, token=None, use_defaults=None):    
        timestamp = str(time.time())
        url = self.root_url + '/auth/role/show'
     
        if use_defaults == True:
            if token == None: token = self.token

        self.post(url=url, bearer=token)
        
        logger.info('response:\n' + str(self.resp.text))
            
        if str(self.resp.text) != '["AdminContributor","AdminManager","AdminViewer","DeveloperContributor","DeveloperManager","DeveloperViewer","OperatorContributor","OperatorManager","OperatorViewer"]':
            raise Exception("error showing roles. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())

        return str(self.resp.text)

    def show_role_assignment(self, token=None, use_defaults=None):    
        timestamp = str(time.time())
        url = self.root_url + '/auth/role/assignment/show'
     
        if use_defaults == True:
            if token == None: token = self.token

        self.post(url=url, bearer=token)
        
        logger.info('response:\n' + str(self.resp.text))

        respText = str(self.resp.text)
        #print('*WARN*', respText)
        
        if respText != '[]':
            match = re.search('.*org.*username.*role.*', respText)
            # print('*WARN*',match)    
            if not match:
                raise Exception("error showing role assignments. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
        
        return str(self.resp.text)

    def create_org(self, orgname=None, orgtype=None, address=None, phone=None, token=None, json_data=None, use_defaults=None):
        timestamp = str(time.time())
        url = self.root_url + '/auth/org/create'
        payload = None
        
        if use_defaults == True:
            if token == None: token = self.token
            if orgname == None: orgname = 'orgname' + timestamp
            if orgtype == None: orgtype = 'developer'
            if address == None: address = '111 somewhere dr'
            if phone == None: phone = '123-456-7777'

        if json_data !=  None:
            payload = json_data
        else:
            org_dict = {}
            if orgname is not None:
                org_dict['name'] = orgname
            if orgtype is not None:
                org_dict['type'] = orgtype
            if address is not None:
                org_dict['address'] = address
            if phone is not None:
                org_dict['phone'] = phone
                
            payload = json.dumps(user_dict)

        logger.info('delete org on mc at {}. \n\t{}'.format(url, payload))

        self.post(url=url, data=payload, bearer=token)
        
        logger.info('response:\n' + str(self.resp.text))
            
        if str(self.resp.text) != '{"message":Organization created","name":"' + name + '"}':
            raise Exception("error creating organization. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())

        self.prov_stack.append(lambda:self.org_delete(name, self.super_token))

        self.org = orgname
        self.orgtype = orgtype
        self.address = address
        self.phone = phone

    def org_show(self, token=None, use_defaults=None):              
        timestamp = str(time.time())
        url = self.root_url + '/auth/org/show'
     
        if use_defaults == True:
            if token == None: token = self.token

        self.post(url=url, bearer=token)
        
        logger.info('response:\n' + str(self.resp.text))

        #[{"Name":"bigorg","Type":"developer","Address":"123 abc st","Phone":"123-456-1234","AdminUsername":"leon","CreatedAt":"2019-04-12T16:07:49.879607-05:00","UpdatedAt":"2019-04-12T16:07:49.879607-05:00"}]
            
        if respText != '[]':
            match = re.search('.*Name.*Type.*Address.*Phoen.*AdminUsername.*CreatedAt.*UpdatedAt.*', respText)
            # print('*WARN*',match)    
            if not match:
                raise Exception("error showing organization. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())

        return str(self.resp.text)

    def org_delete(self, orgname=None, token=None, json_data=None, use_defaults=None):
        timestamp = str(time.time())
        url = self.root_url + '/auth/org/delete'
        payload = None

        if use_defaults == True:
            if token is None: token = self.token
            if orgname is None: name = self.org
        
        if json_data !=  None:
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

        logger.info('delete org on mc at {}. \n\t{}'.format(url, payload))

        self.post(url=url, data=payload, bearer=token)
        
        logger.info('response:\n' + str(self.resp.text))
            
        if str(self.resp.text) != '{"message":"Organization deleted"}':
            raise Exception("error creating user. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())

        
        
    def cleanup_provisioning(self):
        logging.info('cleaning up provisioning')
        print(self.prov_stack)
        #temp_prov_stack = self.prov_stack
        temp_prov_stack = list(self.prov_stack)
        temp_prov_stack.reverse()
        for obj in temp_prov_stack:
            logging.debug('deleting obj' + str(obj))
            obj()
            del self.prov_stack[-1]
