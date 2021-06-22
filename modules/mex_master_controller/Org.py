import json
import logging
import imaplib
import time
import email
import subprocess
import shlex
import shared_variables
import shared_variables_mc

from mex_master_controller.MexOperation import MexOperation

logger = logging.getLogger(__name__)

class Org(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None, thread_queue=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token, thread_queue=thread_queue)

        self.show_url = '/auth/org/show'

    def _build(self, org_name=None, org_type=None, address=None, phone=None, public_images=None, delete_in_progress=None, edgebox_only=None, use_defaults=True):
        if org_name == 'default':
            org_name = shared_variables.organization_name_default
            
        if use_defaults:
            if org_name is None:
                org_name = shared_variables.organization_name_default
            if org_type is None:
                org_type = shared_variables_mc.organization_type_default

        org_dict = {}

        if org_name is not None:
            org_dict['name'] = org_name
        if org_type is not None:
            org_dict['type'] = org_type
        if address is not None:
            org_dict['address'] = address
        if phone is not None:
            org_dict['phone'] = phone
        if public_images is not None:
            org_dict['publicimages'] = public_images
        if delete_in_progress is not None:
            org_dict['deleteinprogress'] = delete_in_progress
        if edgebox_only is not None:
            org_dict['edgeboxonly'] = edgebox_only

        return org_dict

    def show_org(self, token=None, org_name=None, org_type=None, address=None, phone=None, public_images=None, delete_in_progress=None, edgebox_only=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(org_name=org_name, org_type=org_type, address=address, phone=phone, public_images=public_images, delete_in_progress=delete_in_progress, edgebox_only=edgebox_only, use_defaults=use_defaults)
        msg_dict = msg

        return self.show(token=token, url=self.show_url, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)
