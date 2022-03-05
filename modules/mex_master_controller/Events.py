import logging

from mex_master_controller.MexOperation import MexOperation

logger = logging.getLogger(__name__)


class Events(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.show_url = '/auth/events/show'

    def _build(self, use_defaults=True):
        events_dict = {}

        return events_dict

    def show_events(self, token=None, region=None, app_name=None, developer_name=None, app_version=None, selector=None, last=None, start_time=None, end_time=None, cellid=None, json_data=None, use_defaults=True, use_thread=False):
        msg_dict = self._build()

        return self.show(token=token, url=self.show_url, region=region, json_data=json_data, use_defaults=True, use_thread=use_thread, message=msg_dict)
