import logging

from mex_master_controller.MexOperation import MexOperation

logger = logging.getLogger(__name__)


class WebSocketToken(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.wstoken_url = '/auth/wstoken'

    def create_token(self, token=None, use_thread=False):
        return self.create(token=token, url=self.wstoken_url, use_defaults=True, use_thread=use_thread)['token']
