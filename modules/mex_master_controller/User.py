import json
import logging

import shared_variables

from mex_master_controller.MexOperation import MexOperation

logger = logging.getLogger(__name__)


class User(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.create_url = '/auth/user/create'
        self.delete_url = '/auth/user/delete'
        self.show_url = '/auth/user/show'

    def _build(self, username=None, use_defaults=True):
        pool = None

        if username == 'default':
            username = shared_variables.username_default
            
        if use_defaults:
            if username is None: username = shared_variables.username_default

        pool_dict = {}

        if username is not None:
            pool_dict['username'] = username

        return pool_dict

    def show_user(self, token=None, username=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(username=username, use_defaults=use_defaults)
        msg_dict = msg

        return self.show(token=token, url=self.show_url, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

