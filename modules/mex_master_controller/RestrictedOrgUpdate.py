import json
import logging

import shared_variables

from mex_master_controller.MexOperation import MexOperation

class RestrictedOrgUpdate(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.enable_url = '/auth/restricted/org/update'

    def _build(self, org_name=None, edgeboxonly=False, use_defaults=True):

        if use_defaults:
            if org_name is None: org_name = shared_variables.organization_name_default

        org_dict = {}

        if org_name is not None:
            org_dict['name'] = org_name

        if not edgeboxonly:
            org_dict['edgeboxonly'] = False
        else:
            org_dict['edgeboxonly'] = True

        return org_dict

    def update_org(self, token=None, org_name=None, edgeboxonly=False, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(org_name=org_name, edgeboxonly=edgeboxonly, use_defaults=use_defaults)
        msg_dict = msg

        return self.show(token=token, url=self.enable_url, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

