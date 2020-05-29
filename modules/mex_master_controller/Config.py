import json
import logging
import shared_variables

from mex_master_controller.MexOperation import MexOperation

logger = logging.getLogger('mex_mastercontroller rest')
class Config(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.update_url = '/auth/config/update'
        self.show_url = '/auth/config/show'

     #curl -X POST "https://console-qa.mobiledgex.net:443/api/v1/auth/config/update" -H "Content-Type: application/json" -H "Authorization: Bearer ${TOKEN}" -k --data-raw '{"skipverifyemail":true}'
    def _build(self, skip_verify_email=None):
        configverify_dict = {}
  
        if skip_verify_email is not None:
            configverify_dict['skipverifyemail'] = skip_verify_email

        return configverify_dict

    def skip_verify_config(self, token=None, skip_verify_email=None, use_defaults=True, use_thread=False):
        msg = self._build(skip_verify_email=skip_verify_email)
        msg_show = msg 

        return self.update(token=token, show_msg=msg_show, url=self.update_url, show_url=self.show_url, use_defaults=use_defaults, use_thread=use_thread, message=msg)
