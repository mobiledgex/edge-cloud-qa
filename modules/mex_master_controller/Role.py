import json
import logging
import imaplib
import time
import email
import subprocess
import shlex
import shared_variables_mc

from mex_master_controller.MexOperation import MexOperation

logger = logging.getLogger(__name__)


class Role(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None, thread_queue=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token, thread_queue=thread_queue)

        #self.create_url = '/usercreate'
        #self.delete_url = '/auth/user/delete'
        self.showuser_url = '/auth/role/showuser'
        #self.current_url = '/auth/user/current'
        #self.update_url = '/auth/user/update'
        #self.update_restricted_url = '/auth/restricted/user/update'

#    def _build(self, username=None, password=None, email_address=None, metadata=None, locked=None, family_name=None, given_name=None, nickname=None, enable_totp=None, role=None, organization=None, use_defaults=True):
#        if username == 'default':
#            username = shared_variables_mc.username_default
#            
#        if use_defaults:
#            if username is None: username = shared_variables_mc.username_default
#            if password is None: password = shared_variables_mc.password_default
#            if email_address is None: email_address = username + '@email.com'
#
#        shared_variables_mc.username_default = username
#        shared_variables_mc.password_default = password
#
#        user_dict = {}
#
#        if username is not None:
#            user_dict['name'] = username
#        if password is not None:
#            user_dict['passhash'] = password
#        if email_address is not None:
#            user_dict['email'] = email_address
#        if metadata is not None:
#            user_dict['metadata'] = metadata
#        if locked is not None:
#            user_dict['locked'] = locked
#        if family_name is not None:
#            user_dict['familyname'] = family_name
#        if given_name is not None:
#            user_dict['givenname'] = given_name
#        if nickname is not None:
#            user_dict['nickname'] = nickname
#        if enable_totp is not None:
#            user_dict['enabletotp'] = enable_totp
#        if role is not None:
#            user_dict['role'] = role
#        if organization is not None:
#            user_dict['orginaztion'] = organization 
#
#        return user_dict

    def role_show(self, token=None, role=None, organization=None, json_data=None, use_defaults=True, use_thread=False):
        msg_dict = {}

        return_show = self.show(token=token, url=self.showuser_url, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)
        return_list = []
 
        if role:
            for user in return_show:
               if user['role'] == role:
                   return_list.append(user)

        elif organization:
            for user in return_show:
               if user['org'] == organization:
                   return_list.append(user)

        else:
            return_list = return_show

        return return_list
