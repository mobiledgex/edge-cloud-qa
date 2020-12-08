import json
import logging

import shared_variables_mc

from mex_master_controller.MexOperation import MexOperation

logger = logging.getLogger(__name__)


class User(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.create_url = '/auth/user/create'
        self.delete_url = '/auth/user/delete'
        self.show_url = '/auth/user/show'
        self.current_url = '/auth/user/current'
        self.update_url = '/auth/user/update'

    def _build(self, username=None, metadata=None, use_defaults=True):
        pool = None

        if username == 'default':
            username = shared_variables_mc.username_default
            
        if use_defaults:
            if username is None: username = shared_variables_mc.username_default

        pool_dict = {}

        if username is not None:
            pool_dict['username'] = username
        if metadata is not None:
            pool_dict['metadata'] = metadata

        return pool_dict

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


