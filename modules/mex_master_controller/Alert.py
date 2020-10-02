import json
import logging
import shared_variables

from mex_master_controller.MexOperation import MexOperation

logger = logging.getLogger(__name__)

class Alert(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.show_url = '/auth/ctrl/ShowAlert'

    #curl -X POST "https://console-qa.mobiledgex.net/api/v1/auth/ctrl/ShowAlert" -H "Content-Type: application/json" -H "Authorization: Bearer ${TOKEN}" -k --data-raw '{"region":"EU"}'

    def show_alert(self, region=None, token=None, json_data=None, use_defaults=True, use_thread=False):
        return self.show(token=token, url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message={})
