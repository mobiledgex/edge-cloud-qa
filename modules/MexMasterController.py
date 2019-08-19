import json
import jwt
import logging
import time
import re
import threading
import requests

from mex_rest import MexRest
from mex_controller_classes import Flavor, ClusterInstance, App, AppInstance

import shared_variables_mc

logging.basicConfig(format='%(asctime)s %(levelname)s %(funcName)s line:%(lineno)d - %(message)s',datefmt='%d-%b-%y %H:%M:%S')
logger = logging.getLogger('mex_mastercontroller rest')

timestamp = str(time.time())

class MexMasterController(MexRest):
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'

    def __init__(self, mc_address='127.0.0.1:9900', root_cert='mex-ca.crt'):
        self.root_cert = None

        if len(root_cert) > 0:
            self.root_cert = self._findFile(root_cert)

        super().__init__(address=mc_address, root_cert=self.root_cert)
        #print('*WARN*', 'mcinit')
        self.root_url = f'https://{mc_address}/api/v1'

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
        self._number_removeuserrole_requests = 0
        self._number_removeuserrole_requests_success = 0
        self._number_removeuserrole_requests_fail = 0

        self._number_showflavor_requests = 0
        self._number_showflavor_requests_success = 0
        self._number_showflavor_requests_fail = 0
        self._number_createflavor_requests = 0
        self._number_createflavor_requests_success = 0
        self._number_createflavor_requests_fail = 0
        self._number_deleteflavor_requests = 0
        self._number_deleteflavor_requests_success = 0
        self._number_deleteflavor_requests_fail = 0

        self._number_showclusterinst_requests = 0
        self._number_showclusterinst_requests_success = 0
        self._number_showclusterinst_requests_fail = 0
        self._number_createclusterinst_requests = 0
        self._number_createclusterinst_requests_success = 0
        self._number_createclusterinst_requests_fail = 0
        self._number_deleteclusterinst_requests = 0
        self._number_deleteclusterinst_requests_success = 0
        self._number_deleteclusterinst_requests_fail = 0

        self._number_showapp_requests = 0
        self._number_showapp_requests_success = 0
        self._number_showapp_requests_fail = 0
        self._number_createapp_requests = 0
        self._number_createapp_requests_success = 0
        self._number_createapp_requests_fail = 0
        self._number_deleteapp_requests = 0
        self._number_deleteapp_requests_success = 0
        self._number_deleteapp_requests_fail = 0

        self._number_showcloudlet_requests = 0
        self._number_showcloudlet_requests_success = 0
        self._number_showcloudlet_requests_fail = 0

        self._number_showappinsts_requests = 0
        self._number_showappinsts_requests_success = 0
        self._number_showappinsts_requests_fail = 0
        self._number_createappinst_requests = 0
        self._number_createappinst_requests_success = 0
        self._number_createappinst_requests_fail = 0
        self._number_deleteappinst_requests = 0
        self._number_deleteappinst_requests_success = 0
        self._number_deleteappinst_requests_fail = 0

        self._number_showaccount_requests = 0
        self._number_showaccount_requests_success = 0
        self._number_showaccount_requests_fail = 0

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

    def number_of_removeuserrole_requests(self):
        return self._number_removeuserrole_requests

    def number_of_successful_removeuserrole_requests(self):
        return self._number_removeuserrole_requests_success

    def number_of_failed_renmoveuserrole_requests(self):
        return self._number_removeuserrole_requests_fail

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
            return t
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

        shared_variables_mc.username_default = username
        shared_variables_mc.password_default = password

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

            self.prov_stack.append(lambda:self.delete_user(username, self.super_token, None, False))

        self.username = username
        self.password = password
        self.email = email

        self._number_createuser_requests_success += 1

        if use_thread is True:
            t = threading.Thread(target=send_message)
            t.start()
            return t
        else:
            print('sending message')
            resp = send_message()
            return self.decoded_data
            #return username, password, email

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
            return self.decoded_data

    def delete_user(self, username=None, token=None, json_data=None, use_defaults=True):
        url = self.root_url + '/auth/user/delete'
        payload = None

        if use_defaults == True:
            if token is None: token = self.token
            if username is None: username = self.username
            #if password is None: password = self.password
            #if email is None: email = self.username

        if json_data !=  None:
            payload = json_data
        else:
            user_dict = {}
            if username is not None:
                user_dict['name'] = username

            payload = json.dumps(user_dict)

        logger.info('delete/user on mc at {}. \n\t{}'.format(url, payload))

        self.post(url=url, data=payload, bearer=token)

        logger.info('response:\n' + str(self.resp.text))

        if str(self.resp.text) != '{"message":"user deleted"}':
            raise Exception("error deleting  user. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())

    def update_user_restriction(self, username=None, locked=None, token=None, json_data=None, use_defaults=True):
        url = self.root_url + '/auth/restricted/user/update'
        payload = None

        if use_defaults == True:
            if token is None: token = self.token
            if username is None: username = self.username

        if json_data !=  None:
            payload = json_data
        else:
            user_dict = {}
            if username is not None:
                user_dict['name'] = username
            if locked is not None:
                user_dict['locked'] = locked

            payload = json.dumps(user_dict)

        logger.info('update user restriction on mc at {}. \n\t{}'.format(url, payload))

        self.post(url=url, data=payload, bearer=token)

        logger.info('response:\n' + str(self.resp.text))

        #if str(self.resp.text) != '{"message":"user deleted"}':
        #    raise Exception("error deleting  user. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())

    def unlock_user(self, username=None):
        if username is None: username = shared_variables_mc.username_default
        logging.info(f'unlocking username={username}')
        self.update_user_restriction(username=username, locked=False)

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

    def show_role_assignment(self, token=None, json_data=None, use_defaults=True, use_thread=False, sort_field='username', sort_order='ascending'):
        url = self.root_url + '/auth/role/assignment/show'

        payload = None

        if use_defaults == True:
            if token == None: token = self.token

        if json_data !=  None:
            payload = json_data
        else:
            user_dict = {}
            #if email is not None:
            #    user_dict['email'] = email
            payload = json.dumps(user_dict)

        logger.info('show users and roles on mc at {}. \n\t{}'.format(url, payload))
        #self.post(url=url, bearer=token)

        #logger.info('response:\n' + str(self.resp.text))

        #respText = str(self.resp.text)
        #print('*WARN*', respText)

        #if respText != '[]':
        #    match = re.search('.*org.*username.*role.*', respText)
            # print('*WARN*',match)
        #    if not match:
        #        raise Exception("error showing role assignments. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())

        #return self.decoded_data

        def send_message():

            try:
                self.post(url=url, bearer=token, data=payload)

                logger.info('response:\n' + str(self.resp.text))

                respText = str(self.resp.text)

                if str(self.resp.status_code) != '200':
                    raise Exception("ws did not return a 200 response. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
            except Exception as e:
                raise Exception("post failed:", e)

            resp_data = self.decoded_data
            if type(resp_data) is dict:
                resp_data = [resp_data]

            reverse = True if sort_order == 'descending' else False
            if sort_field == 'username':
                logging.info('sorting by username')
                resp_data = sorted(resp_data, key=lambda x: x['username'].casefold(),reverse=reverse) # sorting since need to check for may apps. this return the sorted list instead of the response itself
            elif sort_field == 'organization':
                logging.info('sorting by organization')
                resp_data = sorted(resp_data, key=lambda x: x['org'].casefold(),reverse=reverse)
            return resp_data

        if use_thread is True:
            t = threading.Thread(target=send_message)
            t.start()
            return t
        else:
            print('sending message')
            resp = send_message()
            #if str(self.resp.) != '[]':
            #    #match = re.search('.*Name.*Type.*Address.*Phone.*AdminUsername.*CreatedAt.*UpdatedAt.*', str(self.resp.text))
            #    # print('*WARN*',match)
            #    if not match:
            #        raise Exception("error showing organization. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
            #return self.decoded_data
            return resp

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

                self.prov_stack.append(lambda:self.delete_org(orgname, self.super_token))

            except Exception as e:
                self._number_createorg_requests_fail += 1
                raise Exception("post failed:", e)

            self._number_createorg_requests_success += 1


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

    def show_organizations(self, token=None, use_defaults=True, use_thread=False):
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
            if str(self.resp.text) != '[]':
                match = re.search('.*Name.*Type.*Address.*Phone.*AdminUsername.*CreatedAt.*UpdatedAt.*', str(self.resp.text))
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

        logger.info('role adduser on mc at {}. \n\t{}'.format(url, payload))

        #print('*WARN*', orgname, token)

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

            self.prov_stack.append(lambda:self.removeuser_role(orgname, username, role, self.super_token))
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


    def removeuser_role(self, orgname= None, username=None, role=None, token=None, json_data=None, use_defaults=True, use_thread=False):
        url = self.root_url + '/auth/role/removeuser'
        payload = None

        if use_defaults == True:
            if token is None: token = self.token
            if orgname is None: orgname = self.orgname
            if username is None: username = self.username
            if role is None: role = self.get_roletype()

        if json_data !=  None:
            payload = json_data
        else:
            removeuser_dict = {}
            if orgname is not None:
                removeuser_dict['org'] = orgname
            if username is not None:
                removeuser_dict['username'] = username
            if role is not None:
                removeuser_dict['role'] = role

            payload = json.dumps(removeuser_dict)

        logger.info('role removeuser on mc at {}. \n\t{}'.format(url, payload))

        #print('*WARN*', orgname, token)

        def send_message():
            self._number_removeuserrole_requests += 1

            try:
                self.post(url=url, data=payload, bearer=token)

                logger.info('response:\n' + str(self.resp.text))

                if str(self.resp.status_code) != '200':
                    self._number_removeuserrole_requests_fail += 1
                    raise Exception("ws did not return a 200 response. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
            except Exception as e:
                self._number_removeuserrole_requests_fail += 1
                raise Exception("post failed:", e)

            self._number_removeuserrole_requests_success += 1

        if use_thread is True:
            t = threading.Thread(target=send_message)
            t.start()
            return t
        else:
            print('sending message')
            resp = send_message()
            if str(self.resp.text) != '{"message":"Role removed from user"}':
                raise Exception("error adding user role. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
            return str(self.resp.text)

    def show_flavors(self, token=None, region=None, json_data=None, use_defaults=True, use_thread=False, sort_field='flavor_name', sort_order='ascending'):
        url = self.root_url + '/auth/ctrl/ShowFlavor'

        payload = None

        if use_defaults == True:
            if token == None: token = self.token

        if json_data !=  None:
            payload = json_data
        else:
            flavor_dict = {}
            if region is not None:
                flavor_dict['region'] = region

            payload = json.dumps(flavor_dict)

        logger.info('show flavor on mc at {}. \n\t{}'.format(url, payload))

        def send_message():
            self._number_showflavor_requests += 1

            try:
                self.post(url=url, bearer=token, data=payload)

                logger.info('response:\n' + str(self.resp.text))

                respText = str(self.resp.text)

                if str(self.resp.status_code) != '200':
                    self._number_showorg_requests_fail += 1
                    raise Exception("ws did not return a 200 response. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
            except Exception as e:
                self._number_showflavor_requests_fail += 1
                raise Exception("post failed:", e)

            self._number_showflavor_requests_success += 1

            resp_data = self.decoded_data
            if type(resp_data) is dict:
                resp_data = [resp_data]

            reverse = True if sort_order == 'descending' else False
            if sort_field == 'flavor_name':
                logging.info('sorting by flavor_name')
                resp_data = sorted(resp_data, key=lambda x: x['data']['key']['name'].casefold(),reverse=reverse) # sorting since need to check for may apps. this return the sorted list instead of the response itself

            return resp_data

        if use_thread is True:
            t = threading.Thread(target=send_message)
            t.start()
            return t
        else:
            print('sending message')
            resp = send_message()
            #if str(self.resp.) != '[]':
            #    #match = re.search('.*Name.*Type.*Address.*Phone.*AdminUsername.*CreatedAt.*UpdatedAt.*', str(self.resp.text))
            #    # print('*WARN*',match)
            #    if not match:
            #        raise Exception("error showing organization. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
            #return self.decoded_data
            return resp

    def create_flavor(self, token=None, region=None, flavor_name=None, ram=None, vcpus=None, disk=None, json_data=None, use_defaults=True, use_thread=False):
        url = self.root_url + '/auth/ctrl/CreateFlavor'

        payload = None
        flavor = None

        if use_defaults == True:
            if token == None: token = self.token

        if json_data !=  None:
            payload = json_data
        else:
            flavor = Flavor(flavor_name=flavor_name, ram=ram, vcpus=vcpus, disk=disk).flavor
            flavor_dict = {'flavor': flavor}
            if region is not None:
                flavor_dict['region'] = region

            payload = json.dumps(flavor_dict)

        logger.info('create flavor on mc at {}. \n\t{}'.format(url, payload))

        def send_message():
            self._number_createflavor_requests += 1

            try:
                self.post(url=url, bearer=token, data=payload)
                logger.info('response:\n' + str(self.resp.text))

                if str(self.resp.status_code) != '200':
                    self._number_createflavor_requests_fail += 1
                    raise Exception("ws did not return a 200 response. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
            except Exception as e:
                self._number_createflavor_requests_fail += 1
                raise Exception("post failed:", e)

            self.prov_stack.append(lambda:self.delete_flavor(region=region, flavor_name=flavor['key']['name'], ram=flavor['ram'], disk=flavor['disk'], vcpus=flavor['vcpus']))

            self._number_createflavor_requests_success += 1

        if use_thread is True:
            t = threading.Thread(target=send_message)
            t.start()
            return t
        else:
            resp = send_message()
            return self.decoded_data

    def delete_flavor(self, token=None, region=None, flavor_name=None, ram=None, vcpus=None, disk=None, json_data=None, use_defaults=True, use_thread=False):
        url = self.root_url + '/auth/ctrl/DeleteFlavor'

        payload = None

        if use_defaults == True:
            if token == None: token = self.token

        if json_data !=  None:
            payload = json_data
        else:
            flavor = Flavor(flavor_name=flavor_name, ram=ram, vcpus=vcpus, disk=disk).flavor
            flavor_dict = {'flavor': flavor}
            if region is not None:
                flavor_dict['region'] = region

            payload = json.dumps(flavor_dict)

        logger.info('delete flavor on mc at {}. \n\t{}'.format(url, payload))

        def send_message():
            self._number_deleteflavor_requests += 1

            try:
                self.post(url=url, bearer=token, data=payload)
                logger.info('response:\n' + str(self.resp.text))

                if str(self.resp.status_code) != '200':
                    self._number_deleteflavor_requests_fail += 1
                    raise Exception("ws did not return a 200 response. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
            except Exception as e:
                self._number_deleteflavor_requests_fail += 1
                raise Exception("post failed:", e)

            self._number_deleteflavor_requests_success += 1


        if use_thread is True:
            t = threading.Thread(target=send_message)
            t.start()
            return t
        else:
            resp = send_message()
            return self.decoded_data

    def show_apps(self, token=None, region=None, json_data=None, use_defaults=True, use_thread=False, sort_field='app_name', sort_order='ascending'):
        url = self.root_url + '/auth/ctrl/ShowApp'

        payload = None

        if use_defaults == True:
            if token == None: token = self.token

        if json_data !=  None:
            payload = json_data
        else:
            app_dict = {}
            if region is not None:
                app_dict['region'] = region

            payload = json.dumps(app_dict)

        logger.info('show app on mc at {}. \n\t{}'.format(url, payload))

        def send_message():
            self._number_showapp_requests += 1

            try:
                self.post(url=url, bearer=token, data=payload)

                logger.info('response:\n' + str(self.resp.text))

                respText = str(self.resp.text)

                if str(self.resp.status_code) != '200':
                    self._number_showapp_requests_fail += 1
                    raise Exception("ws did not return a 200 response. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
            except Exception as e:
                self._number_showapp_requests_fail += 1
                raise Exception("post failed:", e)

            self._number_showapp_requests_success += 1

            resp_data = self.decoded_data
            if type(resp_data) is dict:
                resp_data = [resp_data]

            reverse = True if sort_order == 'descending' else False
            if sort_field == 'app_name':
                resp_data = sorted(resp_data, key=lambda x: x['data']['key']['name'].casefold(),reverse=reverse)

            return resp_data

        if use_thread is True:
            t = threading.Thread(target=send_message)
            t.start()
            return t
        else:
            resp = send_message()
            return resp

    def show_cloudlets(self, token=None, region=None, json_data=None, use_defaults=True, use_thread=False, sort_field='cloudlet_name', sort_order='ascending'):
        url = self.root_url + '/auth/ctrl/ShowCloudlet'

        payload = None

        if use_defaults == True:
            if token == None: token = self.token

        if json_data !=  None:
            payload = json_data
        else:
            cloudlet_dict = {}
            if region is not None:
                cloudlet_dict['region'] = region

            payload = json.dumps(cloudlet_dict)

        logger.info('show cloudlet on mc at {}. \n\t{}'.format(url, payload))

        def send_message():
            self._number_showcloudlet_requests += 1

            try:
                self.post(url=url, bearer=token, data=payload)

                logger.info('response:\n' + str(self.resp.text))

                respText = str(self.resp.text)

                if str(self.resp.status_code) != '200':
                    self._number_showcloudlet_requests_fail += 1
                    raise Exception("ws did not return a 200 response. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
            except Exception as e:
                self._number_showcloudlet_requests_fail += 1
                raise Exception("post failed:", e)

            self._number_showcloudlet_requests_success += 1

            resp_data = self.decoded_data
            if type(resp_data) is dict:
                resp_data = [resp_data]

            reverse = True if sort_order == 'descending' else False
            if sort_field == 'cloudlet_name':
                resp_data = sorted(resp_data, key=lambda x: x['data']['key']['name'].casefold(),reverse=reverse)

            return resp_data

        if use_thread is True:
            t = threading.Thread(target=send_message)
            t.start()
            return t
        else:
            resp = send_message()
            return resp

    def show_app_instances(self, token=None, region=None, json_data=None, use_defaults=True, use_thread=False, sort_field='app_name', sort_order='ascending'):
        url = self.root_url + '/auth/ctrl/ShowAppInst'

        payload = None

        if use_defaults == True:
            if token == None: token = self.token

        if json_data !=  None:
            payload = json_data
        else:
            appinst_dict = {}
            if region is not None:
                appinst_dict['region'] = region

            payload = json.dumps(appinst_dict)

        logger.info('show app instances on mc at {}. \n\t{}'.format(url, payload))

        def send_message():
            self._number_showappinsts_requests += 1

            try:
                self.post(url=url, bearer=token, data=payload)

                logger.info('response:\n' + str(self.resp.text))

                respText = str(self.resp.text)

                if str(self.resp.status_code) != '200':
                    self._number_showappinsts_requests_fail += 1
                    raise Exception("ws did not return a 200 response. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
            except Exception as e:
                self._number_showappinsts_requests_fail += 1
                raise Exception("post failed:", e)

            self._number_showcloudlet_requests_success += 1

            resp_data = self.decoded_data
            if type(resp_data) is dict:
                resp_data = [resp_data]

            reverse = True if sort_order == 'descending' else False
            if sort_field == 'app_name':
                resp_data = sorted(resp_data, key=lambda x: x['data']['key']['app_key']['name'].casefold(),reverse=reverse)

            return resp_data

        if use_thread is True:
            t = threading.Thread(target=send_message)
            t.start()
            return t
        else:
            resp = send_message()
            return resp

    def show_all_cloudlets(self, sort_field='cloudlet_name', sort_order='ascending'):
        # should enhance by querying for the regions. But hardcode for now

        usregion = self.show_cloudlets(region='US')
        euregion = self.show_cloudlets(region='EU')

        for region in usregion:
            region['data']['region'] = 'US'

        for region in euregion:
            region['data']['region'] = 'EU'

        allregion = usregion + euregion

        reverse = True if sort_order == 'descending' else False
        if sort_field == 'cloudlet_name':
            allregion = sorted(allregion, key=lambda x: x['data']['key']['name'].casefold(),reverse=reverse)
        elif sort_field == 'region':
            allregion = sorted(allregion, key=lambda x: x['data']['region'].casefold(),reverse=reverse)

        return allregion

    def show_accounts(self, token=None, email=None, json_data=None, use_defaults=True, use_thread=False, sort_field='username', sort_order='ascending'):
        url = self.root_url + '/auth/user/show'

        payload = None

        if use_defaults == True:
            if token == None: token = self.token

        if json_data !=  None:
            payload = json_data
        else:
            account_dict = {}
            if email is not None:
                account_dict['email'] = email

            payload = json.dumps(account_dict)

        logger.info('show account on mc at {}. \n\t{}'.format(url, payload))

        def send_message():
            self._number_showaccount_requests += 1

            try:
                self.post(url=url, bearer=token, data=payload)

                logger.info('response:\n' + str(self.resp.text))

                respText = str(self.resp.text)

                if str(self.resp.status_code) != '200':
                    self._number_showorg_requests_fail += 1
                    raise Exception("ws did not return a 200 response. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
            except Exception as e:
                self._number_showaccount_requests_fail += 1
                raise Exception("post failed:", e)

            self._number_showaccount_requests_success += 1

            resp_data = self.decoded_data
            if type(resp_data) is dict:
                resp_data = [resp_data]

            reverse = True if sort_order == 'descending' else False
            if sort_field == 'username':
                logging.info('sorting by username')
                resp_data = sorted(resp_data, key=lambda x: x['Name'].casefold(),reverse=reverse) # sorting since need to check for may apps. this return the sorted list instead of the response itself

            return resp_data

        if use_thread is True:
            t = threading.Thread(target=send_message)
            t.start()
            return t
        else:
            print('sending message')
            resp = send_message()
            #if str(self.resp.) != '[]':
            #    #match = re.search('.*Name.*Type.*Address.*Phone.*AdminUsername.*CreatedAt.*UpdatedAt.*', str(self.resp.text))
            #    # print('*WARN*',match)
            #    if not match:
            #        raise Exception("error showing organization. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
            #return self.decoded_data
            return resp

    def show_nodes(self, region=None, token=None, json_data=None, use_defaults=True, sort_field='pod_name', sort_order='ascending'):
        url = self.root_url + '/auth/ctrl/ShowNode'
        payload = None

        if use_defaults == True:
            if token is None: token = self.token
            if region is None: region = self.region
            #if password is None: password = self.password
            #if email is None: email = self.username

        if json_data !=  None:
            payload = json_data
        else:
            node_dict = {}
            if region is not None:
                node_dict['region'] = region

            payload = json.dumps(node_dict)

        logger.info('shownode on mc at {}. \n\t{}'.format(url, payload))

        self.post(url=url, data=payload, bearer=token)

        logger.info('response:\n' + str(self.resp.text))

        #if str(self.resp.text) != '{"message":"user deleted"}':
        #    raise Exception("error deleting  user. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())

        resp_data = self.decoded_data
        if type(resp_data) is dict:
            resp_data = [resp_data]

        reverse = True if sort_order == 'descending' else False
        if sort_field == 'pod_name':
            logging.info('sorting by pod name')
            resp_data = sorted(resp_data, key=lambda x: x['data']['key']['name'].casefold(),reverse=reverse) # sorting since need to check for may apps. this return the sorted list instead of the response itself

        return resp_data

    def create_cluster_instance(self, token=None, region=None, cluster_name=None, operator_name=None, cloudlet_name=None, developer_name=None, flavor_name=None, liveness=None, ip_access=None, json_data=None, use_defaults=True, use_thread=False):
        url = self.root_url + '/auth/ctrl/CreateClusterInst'

        payload = None
        clusterInst = None

        if use_defaults == True:
            if token == None: token = self.token

        if json_data !=  None:
            payload = json_data
        else:
            clusterInst = ClusterInstance(cluster_name=cluster_name, operator_name=operator_name, cloudlet_name=cloudlet_name, developer_name=developer_name, flavor_name=flavor_name, liveness=liveness, ip_access=ip_access).cluster_instance
            cluster_dict = {'clusterinst': clusterInst}
            if region is not None:
                cluster_dict['region'] = region

            payload = json.dumps(cluster_dict)

        logger.info('create cluster instance on mc at {}. \n\t{}'.format(url, payload))

        def send_message():
            self._number_createclusterinst_requests += 1

            try:
                self.post(url=url, bearer=token, data=payload)
                logger.info('response:\n' + str(self.resp.text))

                if str(self.resp.status_code) != '200':
                    self._number_createclusterinst_requests_fail += 1
                    raise Exception("ws did not return a 200 response. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
            except Exception as e:
                self._number_createclusterinst_requests_fail += 1
                raise Exception("post failed:", e)

            self.prov_stack.append(lambda:self.delete_cluster_instance(region=region, cluster_name=clusterInst['key']['cluster_key']['name'], cloudlet_name=clusterInst['key']['cloudlet_key']['name'], operator_name=clusterInst['key']['cloudlet_key']['operator_key']['name'], developer_name=clusterInst['key']['developer']))

            self._number_createclusterinst_requests_success += 1

        if use_thread is True:
            t = threading.Thread(target=send_message)
            t.start()
            return t
        else:
            resp = send_message()
            return self.decoded_data

    def delete_cluster_instance(self, token=None, region=None, cluster_name=None, operator_name=None, cloudlet_name=None, developer_name=None, flavor_name=None, liveness=None, ip_access=None, json_data=None, use_defaults=True, use_thread=False):
        url = self.root_url + '/auth/ctrl/DeleteClusterInst'

        payload = None
        clusterInst = None

        if use_defaults == True:
            if token == None: token = self.token

        if json_data !=  None:
            payload = json_data
        else:
            clusterInst = ClusterInstance(cluster_name=cluster_name, operator_name=operator_name, cloudlet_name=cloudlet_name, developer_name=developer_name, flavor_name=flavor_name, liveness=liveness, ip_access=ip_access).cluster_instance
            cluster_dict = {'clusterinst': clusterInst}
            if region is not None:
                cluster_dict['region'] = region

            payload = json.dumps(cluster_dict)

        logger.info('delete cluster instance on mc at {}. \n\t{}'.format(url, payload))

        def send_message():
            self._number_deleteclusterinst_requests += 1

            try:
                self.post(url=url, bearer=token, data=payload)
                logger.info('response:\n' + str(self.resp.text))

                if str(self.resp.status_code) != '200':
                    self._number_deleteclusterinst_requests_fail += 1
                    raise Exception("ws did not return a 200 response. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
            except Exception as e:
                self._number_deleteclusterinst_requests_fail += 1
                raise Exception("post failed:", e)

            self._number_deleteclusterinst_requests_success += 1

        if use_thread is True:
            t = threading.Thread(target=send_message)
            t.start()
            return t
        else:
            resp = send_message()
            return self.decoded_data



    def create_app(self, token=None, region=None, app_name=None, app_version=None, ip_access=None, access_ports=None, image_type=None, image_path=None, cluster_name=None, developer_name=None, default_flavor_name=None, config=None, command=None, app_template=None, auth_public_key=None, permits_platform_apps=None, deployment=None, deployment_manifest=None,  scale_with_cluster=False, official_fqdn=None, json_data=None, use_defaults=True, use_thread=False):
        url = self.root_url + '/auth/ctrl/CreateApp'

        payload = None
        app = None

        if use_defaults == True:
            if token == None: token = self.token

        if json_data !=  None:
            payload = json_data
        else:
            app = App(app_name=app_name, app_version=app_version, ip_access=ip_access, access_ports=access_ports, image_type=image_type, image_path=image_path,cluster_name=cluster_name, developer_name=developer_name, default_flavor_name=default_flavor_name, config=config, command=command, app_template=app_template, auth_public_key=auth_public_key, permits_platform_apps=permits_platform_apps, deployment=deployment, deployment_manifest=deployment_manifest, scale_with_cluster=scale_with_cluster, official_fqdn=official_fqdn).app
            app_dict = {'app': app}
            if region is not None:
                app_dict['region'] = region

            payload = json.dumps(app_dict)

        logger.info('create app on mc at {}. \n\t{}'.format(url, payload))

        def send_message():
            self._number_createapp_requests += 1

            try:
                self.post(url=url, bearer=token, data=payload)
                logger.info('response:\n' + str(self.resp.text))

                if str(self.resp.status_code) != '200':
                    self._number_createapp_requests_fail += 1
                    raise Exception("ws did not return a 200 response. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
            except Exception as e:
                self._number_createapp_requests_fail += 1
                raise Exception("post failed:", e)

            self.prov_stack.append(lambda:self.delete_app(region=region, app_name=app['key']['name'], app_version=app['key']['version'], developer_name=app['key']['developer_key']['name']))

            self._number_createapp_requests_success += 1

        if use_thread is True:
            t = threading.Thread(target=send_message)
            t.start()
            return t
        else:
            resp = send_message()
            return self.decoded_data

    def delete_app(self, token=None, region=None, app_name=None, app_version=None, ip_access=None, access_ports=None, image_type=None, image_path=None, cluster_name=None, developer_name=None, default_flavor_name=None, config=None, command=None, app_template=None, auth_public_key=None, permits_platform_apps=None, deployment=None, deployment_manifest=None,  scale_with_cluster=False, official_fqdn=None, json_data=None, use_defaults=True, use_thread=False):
        url = self.root_url + '/auth/ctrl/DeleteApp'

        payload = None
        app = None

        if use_defaults == True:
            if token == None: token = self.token

        if json_data !=  None:
            payload = json_data
        else:
            app = App(app_name=app_name, app_version=app_version, ip_access=ip_access, access_ports=access_ports, image_type=image_type, image_path=image_path,cluster_name=cluster_name, developer_name=developer_name, default_flavor_name=default_flavor_name, config=config, command=command, app_template=app_template, auth_public_key=auth_public_key, permits_platform_apps=permits_platform_apps, deployment=deployment, deployment_manifest=deployment_manifest, scale_with_cluster=scale_with_cluster, official_fqdn=official_fqdn).app
            app_dict = {'app': app}
            if region is not None:
                app_dict['region'] = region

            payload = json.dumps(app_dict)

        logger.info('delete app on mc at {}. \n\t{}'.format(url, payload))

        def send_message():
            self._number_deleteapp_requests += 1

            try:
                self.post(url=url, bearer=token, data=payload)
                logger.info('response:\n' + str(self.resp.text))

                if str(self.resp.status_code) != '200':
                    self._number_deleteapp_requests_fail += 1
                    raise Exception("ws did not return a 200 response. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
            except Exception as e:
                self._number_deleteapp_requests_fail += 1
                raise Exception("post failed:", e)

            self._number_deleteapp_requests_success += 1

        if use_thread is True:
            t = threading.Thread(target=send_message)
            t.start()
            return t
        else:
            resp = send_message()
            return self.decoded_data

    def create_app_instance(self, token=None, region=None, appinst_id = None, app_name=None, app_version=None, cloudlet_name=None, operator_name=None, developer_name=None, cluster_instance_name=None, cluster_instance_developer_name=None, flavor_name=None, config=None, uri=None, latitude=None, longitude=None, autocluster_ip_access=None, crm_override=None, json_data=None, use_defaults=True, use_thread=False):
        url = self.root_url + '/auth/ctrl/CreateAppInst'

        payload = None
        appinst = None

        if use_defaults == True:
            if token == None: token = self.token

        if json_data !=  None:
            payload = json_data
        else:
            appinst = AppInstance(appinst_id=appinst_id, app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_name=operator_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_name=cluster_instance_developer_name, developer_name=developer_name, flavor_name=flavor_name, config=config, uri=uri, latitude=latitude, longitude=longitude, autocluster_ip_access=autocluster_ip_access, crm_override=crm_override).app_instance
            appinst_dict = {'appinst': appinst}
            if region is not None:
                appinst_dict['region'] = region

            payload = json.dumps(appinst_dict)

        logger.info('create app instance on mc at {}. \n\t{}'.format(url, payload))

        def send_message():
            self._number_createappinst_requests += 1

            try:
                self.post(url=url, bearer=token, data=payload)
                logger.info('response:\n' + str(self.resp.text))

                if str(self.resp.status_code) != '200':
                    self._number_createappinst_requests_fail += 1
                    raise Exception("ws did not return a 200 response. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
            except Exception as e:
                self._number_createappinst_requests_fail += 1
                raise Exception("post failed:", e)

            self.prov_stack.append(lambda:self.delete_app_instance(region=region, app_name=appinst['key']['app_key']['name'], developer_name=appinst['key']['app_key']['developer_key']['name'], app_version=appinst['key']['app_key']['version'], cluster_instance_name=appinst['key']['cluster_inst_key']['cluster_key']['name'], cloudlet_name=appinst['key']['cluster_inst_key']['cloudlet_key']['name'], operator_name=appinst['key']['cluster_inst_key']['cloudlet_key']['operator_key']['name'], cluster_instance_developer_name=appinst['key']['cluster_inst_key']['developer']))

            self._number_createappinst_requests_success += 1

        if use_thread is True:
            t = threading.Thread(target=send_message)
            t.start()
            return t
        else:
            resp = send_message()
            return self.decoded_data

    def delete_app_instance(self, token=None, region=None, appinst_id = None, app_name=None, app_version=None, cloudlet_name=None, operator_name=None, developer_name=None, cluster_instance_name=None, cluster_instance_developer_name=None, flavor_name=None, config=None, uri=None, latitude=None, longitude=None, autocluster_ip_access=None, crm_override=None, json_data=None, use_defaults=True, use_thread=False):
        url = self.root_url + '/auth/ctrl/DeleteAppInst'

        payload = None
        appinst = None

        if use_defaults == True:
            if token == None: token = self.token

        if json_data !=  None:
            payload = json_data
        else:
            appinst = AppInstance(appinst_id=appinst_id, app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_name=operator_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_name=cluster_instance_developer_name, developer_name=developer_name, flavor_name=flavor_name, config=config, uri=uri, latitude=latitude, longitude=longitude, autocluster_ip_access=autocluster_ip_access, crm_override=crm_override).app_instance
            appinst_dict = {'appinst': appinst}
            if region is not None:
                appinst_dict['region'] = region

            payload = json.dumps(appinst_dict)

        logger.info('create app instance on mc at {}. \n\t{}'.format(url, payload))

        def send_message():
            self._number_deleteappinst_requests += 1

            try:
                self.post(url=url, bearer=token, data=payload)
                logger.info('response:\n' + str(self.resp.text))

                if str(self.resp.status_code) != '200':
                    self._number_deleteappinst_requests_fail += 1
                    raise Exception("ws did not return a 200 response. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())
            except Exception as e:
                self._number_deleteappinst_requests_fail += 1
                raise Exception("post failed:", e)

            self._number_deleteappinst_requests_success += 1

        if use_thread is True:
            t = threading.Thread(target=send_message)
            t.start()
            return t
        else:
            resp = send_message()
            return self.decoded_data

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
            x.join()
           
