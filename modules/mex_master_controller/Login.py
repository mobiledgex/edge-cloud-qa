import logging
import time
import shared_variables_mc
import base64
import struct
import hmac
import hashlib
import pyotp

from mex_master_controller.MexOperation import MexOperation

logger = logging.getLogger(__name__)


class Login(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None, thread_queue=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token, thread_queue=thread_queue)

        self.login_url = '/login'

    def _build(self, username=None, password=None, totp=None, apikey_id=None, apikey=None, use_defaults=True):
        if use_defaults:
            if username is None:
                username = shared_variables_mc.username_default
            if password is None:
                password = shared_variables_mc.password_default

        # shared_variables_mc.username_default = username
        # shared_variables_mc.password_default = password

        login_dict = {}

        if username is not None:
            login_dict['username'] = username
            shared_variables_mc.username_default = username
        if password is not None:
            login_dict['password'] = password
            shared_variables_mc.password_default = password
        if totp is not None:
            login_dict['totp'] = str(totp)
        if apikey_id is not None:
            login_dict['apikeyid'] = str(apikey_id)
        if apikey is not None:
            login_dict['apikey'] = str(apikey)

        return login_dict

    def login(self, username=None, password=None, totp=None, apikey_id=None, apikey=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(username=username, password=password, totp=totp, apikey_id=apikey_id, apikey=apikey, use_defaults=use_defaults)
        msg_dict = msg

        return self.create(token=None, url=self.login_url, json_data=json_data, use_defaults=False, use_thread=use_thread, create_msg=msg_dict)

    def get_totp(self, totp_shared_key):
        totp = pyotp.TOTP(totp_shared_key)
        return totp.now() 
