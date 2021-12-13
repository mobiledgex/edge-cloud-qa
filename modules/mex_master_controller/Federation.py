import logging
import re
import time
import shared_variables

from mex_master_controller.MexOperation import MexOperation

logger = logging.getLogger(__name__)


class Federation(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.federatorcreate_url = '/auth/federator/self/create'
        self.federatordelete_url = '/auth/federator/self/delete'
        self.federatorshow_url = '/auth/federator/self/show'
        self.federatorupdate_url = '/auth/federator/self/update'

    def _build(self, operatorid=None, countrycode=None, mcc=None, mnc=[], federationid=None, use_defaults=True):

        if use_defaults:
            if operatorid is None:
                operatorid = shared_variables.operator_name_default

        federator_dict = {}

        if operatorid is not None:
            federator_dict['operatorid'] = operatorid

        if countrycode is not None:
            federator_dict['countrycode'] = countrycode

        if mcc is not None:
            federator_dict['mcc'] = mcc

        if mnc:
            federator_dict['mnc'] = mnc           

        if federationid is not None:
            federator_dict['federationid'] = federationid

        return federator_dict

    def create_federator(self, token=None, region=None, operatorid=None, countrycode=None, mcc=None, mnc=[], federationid=None,  use_defaults=True, use_thread=False, auto_delete=True, json_data=None, stream=False, stream_timeout=100):
        msg = self._build(operatorid=operatorid, countrycode=countrycode, mcc=mcc, mnc=mnc, federationid=federationid, use_defaults=use_defaults)
        msg_dict = msg

        thread_name = None
        msg_dict_show = None
        if 'operatorid' in msg and 'federationid' in msg:
            msg_show = self._build(operatorid=msg['operatorid'], federationid=msg['federationid'], use_defaults=False)
            msg_dict_show =  msg_show

        msg_dict_delete = None
        if auto_delete and 'operatorid' in msg and 'federationid' in msg:
            msg_delete = self._build(operatorid=msg['operatorid'], federationid=msg['federationid'], use_defaults=False)
            msg_dict_delete =  msg_delete

        return self.create(token=token, url=self.federatorcreate_url, delete_url=self.federatordelete_url, show_url=self.federatorshow_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, create_msg=msg_dict, delete_msg=msg_dict_delete, show_msg=msg_dict_show, thread_name=thread_name, stream=stream, stream_timeout=stream_timeout)


    def update_federator(self, token=None, operatorid=None, mcc=None, mnc=[], federationid=None, use_defaults=True, use_thread=False, json_data=None):
        msg = self._build(operatorid=operatorid, mcc=mcc, mnc=mnc, federationid=federationid, use_defaults=use_defaults)
        msg_dict = msg

        msg_dict_show = None
        if 'operatorid' in msg and 'federationid' in msg:
            msg_show = self._build(operatorid=msg['operatorid'], federationid=msg['federationid'], use_defaults=False)
            msg_dict_show =  msg_show

        return self.update(token=token, url=self.federatorupdate_url, show_url=self.federatorshow_url, json_data=json_data, use_defaults=True, use_thread=use_thread, message=msg_dict, show_msg=msg_dict_show)

    def delete_federator(self, token=None, operatorid=None, federationid=None, use_defaults=True, use_thread=False, json_data=None):
        msg = self._build(operatorid=operatorid, federationid=federationid, use_defaults=use_defaults)
        msg_dict = msg

        return self.delete(token=token, url=self.federatordelete_url, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def show_federator(self, token=None, operatorid=None, federationid=None, use_defaults=True, use_thread=False, json_data=None):
        msg = self._build(operatorid=operatorid, federationid=federationid, use_defaults=use_defaults)
        msg_dict = msg

        return self.show(token=token, url=self.federatorshow_url, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)
   

