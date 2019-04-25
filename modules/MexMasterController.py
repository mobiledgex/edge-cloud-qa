import json
import jwt
import logging
import time
import re
import threading
import requests

from mex_rest import MexRest

logging.basicConfig(format='%(asctime)s %(levelname)s %(funcName)s line:%(lineno)d - %(message)s',datefmt='%d-%b-%y %H:%M:%S')
logger = logging.getLogger('mex_mastercontroller rest')

timestamp = str(time.time())

class MexMasterController(MexRest):

    def __init__(self, mc_address='127.0.0.1:9900', root_cert='mex-ca.crt'):
        super().__init__(address=mc_address, root_cert=root_cert)
        #print('*WARN*', 'mcinit')
        self.root_url = f'https://{mc_address}/api/v1'
        self.root_cert = root_cert
        self.token = None
        self.prov_stack = []

        self.username = 'mexadmin'
        self.password = 'mexadmin123'
        
        self.super_token = None
        self._decoded_token = None
        self.orgname = None
        self.orgtype = None
        self.address = None
        self.phone = None

        self._number_login_requests = 0
        self._number_login_requests_success = 0
        self._number_login_requests_fail = 0
        self._number_createuser_requests = 0
        self._number_createuser_requests_success = 0
        self._number_createuser_requests_fail = 0
        self._number_currentuser_requests = 0
        self._number_currentuser_requests_success = 0
        self._number_currentuser_requests_fail = 0
        self._number_showrole_requests = 0
        self._number_showrole_requests_success = 0
        self._number_showrole_requests_fail = 0
        self._number_createorg_requests = 0
        self._number_createorg_requests_success = 0
        self._number_createorg_requests_fail = 0
        self._number_showorg_requests = 0
        self._number_showorg_requests_success = 0
        self._number_showorg_requests_fail = 0
        self._number_adduserrole_requests = 0
        self._number_adduserrole_requests_success = 0
        self._number_adduserrole_requests_fail = 0
        
                
        
        self.super_token = self.login(self.username, self.password, None, False)

    def get_supertoken(self):
        return self.supe_token

    def get_token(self):
        return self.token

    def get_roletype(self):
        if self.orgtype == 'developer': return 'DeveloperContributor'
        else: return 'OperatorContributor'

    def number_of_login_requests(self):
        return self._number_login_requests

    def number_of_successful_login_requests(self):
        return self._number_login_requests_success

    def number_of_failed_login_requests(self):
        return self._number_login_requests_fail

    def number_of_createuser_requests(self):
        return self._number_createuser_requests

    def number_of_successful_createuser_requests(self):
        return self._number_createuser_requests_success

    def number_of_failed_createuser_requests(self):
        return self._number_createuser_requests_fail
    
    def number_of_currentuser_requests(self):
        return self._number_currentuser_requests
    
    def number_of_successful_currentuser_requests(self):
        return self._number_currentuser_requests_success
    
    def number_of_failed_currentuser_requests(self):
        return self._number_currentuser_requests_fail

    def number_of_showrole_requests(self):
        return self._number_showrole_requests
    
    def number_of_successful_showrole_requests(self):
        return self._number_showrole_requests_success
    
    def number_of_failed_showrole_requests(self):
        return self._number_showrole_requests_fail

    def number_of_createorg_requests(self):
        return self._number_createorg_requests

    def number_of_successful_createorg_requests(self):
        return self._number_createorg_requests_success
    
    def number_of_failed_createorg_requests(self):
        return self._number_createorg_requests_fail

    def number_of_showorg_requests(self):
        return self._number_showorg_requests

    def number_of_successful_showorg_requests(self):
        return self._number_showorg_requests_success
    
    def number_of_failed_showorg_requests(self):
        return self._number_showorg_requests_fail

    def reset_user_count(self):
        self._number_createuser_requests = 0
        self._number_createuser_requests_success = 0
        self._number_createuser_requests_fail = 0

    def number_of_adduserrole_requests(self):
        return self._number_adduserrole_requests

    def number_of_successful_adduserrole_requests(self):
        return self._number_adduserrole_requests_success

    def number_of_failed_adduserrole_requests(self):
        return self._number_adduserrole_requests_fail
    
    def decoded_token(self):
        return self._decoded_token

    def created_username(self):
        return self.username

    def created_password(self):
        return self.password

    def created_org(self):
        orginfo = 'Name:' + self.org + '  Type:' + self.orgtype + '  Address:' + self.address + '  Phone:' + self.phone
        return orginfo
    
    def login(self, username=None, password=None, json_data=None, use_defaults=True, use_thread=False):
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

        def send_message():
            self._number_login_requests += 1

            try:
                self.post(url=url, data=payload)
        
                logger.info('response:\n' + str(self.resp.text))

                self.token = self.decoded_data['token']
                self._decoded_token = jwt.decode(self.token, verify=False)
                
                if str(self.resp.status_code) != '200':
                    self._number_login_requests_fail += 1
                    raise Exception("ws did not return a 200 response. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
            except Exception as e:
                self._number_login_requests_fail += 1
                raise Exception("post failed:", e)

        self._number_login_requests_success += 1
            
        if use_thread is True:
            t = threading.Thread(target=send_message)
            t.start()
            return t, self.token
        else:
            print('sending message')
            resp = send_message()
            return self.token

    def create_user(self, username=None, password=None, email=None, json_data=None, use_defaults=True, use_thread=False):
        namestamp = str(time.time())
        url = self.root_url + '/usercreate'
        payload = None

        if use_defaults == True:
            if username == None: username = 'name' + namestamp
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

        def send_message():
            self._number_createuser_requests += 1

            try:
                self.post(url=url, data=payload)
        
                logger.info('response:\n' + str(self.resp.text))
            
                if str(self.resp.status_code) != '200':
                    self._number_createuser_requests_fail += 1
                    raise Exception("ws did not return a 200 response. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
            except Exception as e:
                self._number_createuser_requests_fail += 1
                raise Exception("post failed:", e)

        self.prov_stack.append(lambda:self.delete_user(username, password, email, self.super_token))

        self.username = username
        self.password = password
        self.email = email

        self._number_createuser_requests_success += 1
        
        if use_thread is True:
            t = threading.Thread(target=send_message)
            t.start()
            return t, username, password
        else:
            print('sending message')
            resp = send_message()
            return username, password, email
        
    def get_current_user(self, token=None, use_defaults=True, use_thread=False):
        url = self.root_url + '/auth/user/current'

        logger.info('user/current on mc at {}'.format(url))

        if use_defaults == True:
            if token is None: token = self.token

        def send_message():
            self._number_currentuser_requests += 1
            
            try:
                self.post(url=url, bearer=token)                
        
                logger.info('response:\n' + str(self.resp.text))
                
                if str(self.resp.status_code) != '200':
                    self._number_currentuser_requests_fail += 1
                    raise Exception("ws did not return a 200 response. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
            except Exception as e:
                self._number_currentuser_requests_fail += 1
                raise Exception("post failed:", e)

        self._number_currentuser_requests_success += 1
        
        if use_thread is True:
            t = threading.Thread(target=send_message)
            t.start()
            return t
        else:
            print('sending message')
            resp = send_message()
            return resp
        
    def delete_user(self, username=None, password=None, email=None, token=None, json_data=None, use_defaults=True):
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
            raise Exception("error deleting  user. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())

    def new_password(self, password=None, token=None, json_data=None, use_defaults=True):
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

    def show_role(self, token=None, use_defaults=True, use_thread=False):    
        url = self.root_url + '/auth/role/show'
     
        if use_defaults == True:
            if token == None: token = self.token
            
        #print('*WARN*',token)
        
        def send_message():
            self._number_showrole_requests += 1
            
            try:
                self.post(url=url, bearer=token)
        
                logger.info('response:\n' + str(self.resp.text))

                if str(self.resp.status_code) != '200':
                    self._number_showrole_requests_fail += 1
                    raise Exception("ws did not return a 200 response. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
            except Exception as e:
                self._number_showrole_requests_fail += 1
                raise Exception("post failed:", e)

        self._number_showrole_requests_success += 1

        if use_thread is True:
            t = threading.Thread(target=send_message)
            t.start()
            return t
        else:
            print('sending message')
            resp = send_message()
            if str(self.resp.text) != '["AdminContributor","AdminManager","AdminViewer","DeveloperContributor","DeveloperManager","DeveloperViewer","OperatorContributor","OperatorManager","OperatorViewer"]':
                raise Exception("error showing roles. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
            return str(self.resp.text)

    def show_role_assignment(self, token=None, use_defaults=True):    
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

    def create_org(self, orgname=None, orgtype=None, address=None, phone=None, token=None, json_data=None, use_defaults=True, use_thread=False):
        orgstamp = str(time.time())
        url = self.root_url + '/auth/org/create'
        payload = None
        
        if use_defaults == True:
            if token == None: token = self.token
            if orgname == None: orgname = 'orgname' + orgstamp
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
                
            payload = json.dumps(org_dict)

        logger.info('create org on mc at {}. \n\t{}'.format(url, payload))

        #print('*WARN*', orgname, token)

        def send_message():
            self._number_createorg_requests += 1

            try:
                self.post(url=url, data=payload, bearer=token)
        
                logger.info('response:\n' + str(self.resp.text))
                
                if str(self.resp.status_code) != '200':
                    self._number_createorg_requests_fail += 1
                    raise Exception("ws did not return a 200 response. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
            except Exception as e:
                self._number_createorg_requests_fail += 1
                raise Exception("post failed:", e)

            self._number_createorg_requests_success += 1

        self.prov_stack.append(lambda:self.delete_org(orgname, self.super_token))

        self.orgname = orgname
        self.orgtype = orgtype
        self.address = address
        self.phone = phone

        if use_thread is True:
            t = threading.Thread(target=send_message)
            t.start()
            return t
        else:
            print('sending message')
            resp = send_message()
            if str(self.resp.text) != '{"message":Organization created","name":"' + orgname + '"}':
                if str(self.resp.text) == '{"message":"Organization type must be developer, or operator"}':
                    raise Exception("error creating organization. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
            return orgname

    def show_org(self, token=None, use_defaults=True, use_thread=False):              
        url = self.root_url + '/auth/org/show'
     
        if use_defaults == True:
            if token == None: token = self.token

        def send_message():
            self._number_showorg_requests += 1

            try:
                self.post(url=url, bearer=token)
        
                logger.info('response:\n' + str(self.resp.text))

                respText = str(self.resp.text)
                
                if str(self.resp.status_code) != '200':
                    self._number_showorg_requests_fail += 1
                    raise Exception("ws did not return a 200 response. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
            except Exception as e:
                self._number_showorg_requests_fail += 1
                raise Exception("post failed:", e)

            self._number_showorg_requests_success += 1
        

        if use_thread is True:
            t = threading.Thread(target=send_message)
            t.start()
            return t
        else:
            print('sending message')
            resp = send_message()
            if respText != '[]':
                match = re.search('.*Name.*Type.*Address.*Phone.*AdminUsername.*CreatedAt.*UpdatedAt.*', respText)
            # print('*WARN*',match)    
            if not match:
                raise Exception("error showing organization. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
            return self.decoded_data


    def delete_org(self, orgname=None, token=None, json_data=None, use_defaults=True):
        url = self.root_url + '/auth/org/delete'
        payload = None

        if use_defaults == True:
            if token is None: token = self.token
            if orgname is None: orgname = self.orgname
        
        if json_data !=  None:
            payload = json_data
        else:
            org_dict = {}
            if orgname is not None:
                org_dict['name'] = orgname
                
            payload = json.dumps(org_dict)

        logger.info('delete org on mc at {}. \n\t{}'.format(url, payload))

        self.post(url=url, data=payload, bearer=token)
        
        logger.info('response:\n' + str(self.resp.text))
            
        if str(self.resp.text) != '{"message":"Organization deleted"}':
            raise Exception("error deleting org. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())

    def adduser_role(self, orgname= None, username=None, role=None, token=None, json_data=None, use_defaults=True, use_thread=False):
        url = self.root_url + '/auth/role/adduser'
        payload = None

        if use_defaults == True:
            if token is None: token = self.token
            if orgname is None: orgname = self.orgname
            if username is None: username = self.username
            if role is None: role = self.get_roletype()
        
        if json_data !=  None:
            payload = json_data
        else:
            adduser_dict = {}
            if orgname is not None:
                adduser_dict['org'] = orgname
            if username is not None:
                adduser_dict['username'] = username
            if role is not None:
                adduser_dict['role'] = role
                
            payload = json.dumps(adduser_dict)

        logger.info('role adduser  on mc at {}. \n\t{}'.format(url, payload))

        print('*WARN*', orgname, token)

        def send_message():
            self._number_adduserrole_requests += 1
            
            try:
                self.post(url=url, data=payload, bearer=token)
        
                logger.info('response:\n' + str(self.resp.text))
            
                if str(self.resp.status_code) != '200':
                    self._number_adduserrole_requests_fail += 1
                    raise Exception("ws did not return a 200 response. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
            except Exception as e:
                self._number_adduserrole_requests_fail += 1
                raise Exception("post failed:", e)

            self._number_adduserrole_requests_success += 1

        if use_thread is True:
            t = threading.Thread(target=send_message)
            t.start()
            return t
        else:
            print('sending message')
            resp = send_message()
            if str(self.resp.text) != '{"message":"Role added to user"}':
                raise Exception("error adding user role. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())

        
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


    def wait_for_replies(self, *args):
        for x in args:
            if isinstance(x, list):
                for x2 in x:
                    x.join()
            #x.join()
           
