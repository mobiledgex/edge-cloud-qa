import json
import logging

import shared_variables_mc

from mex_master_controller.MexOperation import MexOperation

logger = logging.getLogger(__name__)


class User(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None, thread_queue=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token, thread_queue=thread_queue)

        self.create_url = '/usercreate'
        self.delete_url = '/auth/user/delete'
        self.show_url = '/auth/user/show'
        self.current_url = '/auth/user/current'
        self.update_url = '/auth/user/update'
        self.update_restricted_url = '/auth/restricted/user/update'

    def _build(self, username=None, password=None, email_address=None, metadata=None, locked=None, use_defaults=True):
        if username == 'default':
            username = shared_variables_mc.username_default
            
        if use_defaults:
            if username is None: username = shared_variables_mc.username_default
            if password is None: password = shared_variables_mc.password_default
            if email_address is None: email_address = username + '@email.com'

        shared_variables_mc.username_default = username
        shared_variables_mc.password_default = password

        user_dict = {}

        if username is not None:
            user_dict['name'] = username
        if password is not None:
            user_dict['passhash'] = password
        if email_address is not None:
            user_dict['email'] = email_address
        if metadata is not None:
            user_dict['metadata'] = metadata
        if locked is not None:
            user_dict['locked'] = locked

        return user_dict

    def _build_update_restricted(self, username=None, locked=None, use_defaults=True):
        #pool = None

        if username == 'default':
            username = shared_variables_mc.username_default

        if use_defaults:
            if username is None: username = shared_variables_mc.username_default

        shared_variables_mc.username_default = username

        user_dict = {}

        if username is not None:
            user_dict['name'] = username
        if locked is not None:
            user_dict['locked'] = locked

        return user_dict

    def create_user(self, username=None, password=None, email_address=None, email_password=None, server='imap.gmail.com', email_check=False, json_data=None, use_defaults=True, use_thread=False, auto_delete=True):
        if not email_password:
            email_password = password

        msg = self._build(username=username, password=password, email_address=email_address, use_defaults=use_defaults)
        msg_dict = msg

        msg_dict_show = None
        if username:
            msg_show = self._build(username=username, use_defaults=False)
            msg_dict_show = msg_show

        msg_dict_delete = None
        if auto_delete and username:
            msg_delete = self._build(username=username, use_defaults=False)
            msg_dict_delete = msg_delete

        thread_name = 'create_user'
        if username:
            thread_name += username

        if email_check:
            logger.info(f'checking email with email={email_address} password={password}')
            mail = imaplib.IMAP4_SSL(server)
            mail.login(email_address, email_password)
            mail.select('inbox')
            self._mail = mail
            logger.info('login successful')

            status, email_list_pre = mail.search(None, '(SUBJECT "Welcome to MobiledgeX!")')
            mail_ids_pre = email_list_pre[0].split()
            num_emails_pre = len(mail_ids_pre)
            self._mail_count = num_emails_pre
            logger.info(f'number of emails pre is {num_emails_pre}')

        return self.create(token=None, url=self.create_url, delete_url=self.delete_url, show_url=self.show_url, region=None, json_data=json_data, use_defaults=False, use_thread=use_thread, create_msg=msg_dict, delete_msg=msg_dict_delete, show_msg=msg_dict_show, thread_name=thread_name, stream=None, stream_timeout=None)


    def show_user(self, token=None, username=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(username=username, use_defaults=use_defaults)
        msg_dict = msg

        return self.show(token=token, url=self.show_url, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def current_user(self, token=None, json_data=None, use_defaults=True, use_thread=False):
        return self.show(token=token, url=self.current_url, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=None)[0]

    def update_user(self, token=None, metadata=None, json_data=None, use_defaults=False, use_thread=False):
        msg = self._build(metadata=metadata, use_defaults=use_defaults)
        msg_dict = msg

        return self.update(token=token, url=self.update_url, show_url=self.show_url, region=None, json_data=json_data, use_defaults=True, use_thread=use_thread, message=msg_dict, show_msg=None)

    def update_user_restricted(self, token=None, username=None, locked=None, json_data=None, use_defaults=False, use_thread=False):
        msg = self._build_update_restricted(username=username, locked=locked, use_defaults=use_defaults)
        msg_dict = msg

        thread_name = 'update_user_restricted'
        if username:
            thread_name += username
        
        #msg_show_dict = {}
        msg_show_dict = None
        return self.update(token=token, url=self.update_restricted_url, show_url=self.show_url, region=None, json_data=json_data, use_defaults=True, use_thread=use_thread, thread_name=thread_name, message=msg_dict, show_msg=msg_show_dict)

    def delete_user(self, token=None, username=None, json_data=None, use_defaults=False, use_thread=False):
        msg = self._build(username=username, use_defaults=use_defaults)
        msg_dict = msg

        return self.delete(token=token, url=self.delete_url, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

