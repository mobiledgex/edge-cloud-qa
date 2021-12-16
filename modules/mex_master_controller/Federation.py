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
        self.federatorgenerateapikey_url = '/auth/federator/self/generateapikey'
        self.federationcreate_url = '/auth/federation/create'
        self.federationshow_url = '/auth/federation/show'
        self.federationdelete_url = '/auth/federation/delete'
        self.federationregister_url = '/auth/federation/register'
        self.federationderegister_url = '/auth/federation/deregister'
        self.federationsetpartnerkey_url = '/auth/federation/partner/setapikey'
        self.showfederatedpartnerzone_url = '/auth/federation/partner/zone/show'
        self.showfederatedselfzone_url = '/auth/federation/self/zone/show'
        self.registerfederatorzone_url = '/auth/federator/partner/zone/register'
        self.federatorzonecreate_url = '/auth/federator/self/zone/create'
        self.federatorzoneshow_url = '/auth/federator/self/zone/show'
        self.federatorzonedelete_url = '/auth/federator/self/zone/delete'

    def _build(self, operatorid=None, countrycode=None, mcc=None, mnc=[], federationid=None, selfoperatorid=None, selffederationid=None, federation_name=None, federationaddr=None, apikey=None, zoneid=None, zones=[], cloudlets=[], geolocation=None, city=None, state=None, locality=None, use_defaults=True):

        if use_defaults:
            if federation_name is None:
                federation_name = shared_variables.federation_name_default

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

        if selfoperatorid is not None:
            federator_dict['selfoperatorid'] = selfoperatorid

        if selffederationid is not None:
            federator_dict['selffederationid'] = selffederationid

        if federation_name is not None:
            federator_dict['name'] = federation_name

        if federationaddr is not None:
            federator_dict['federationaddr'] = federationaddr
        
        if apikey is not None:
            federator_dict['apikey'] = apikey

        if zoneid is not None:
            federator_dict['zoneid'] = zoneid

        if zones:
            federator_dict['zones'] = zones

        if cloudlets:
            federator_dict['cloudlets'] = cloudlets

        if geolocation is not None:
            federator_dict['geolocation'] = geolocation

        if city is not None:
            federator_dict['city'] = city
 
        if state is not None:
            federator_dict['state'] = state
 
        if locality is not None:
            federator_dict['locality'] = locality

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

    def generateselfapikey_federator(self, token=None, operatorid=None, federationid=None, use_defaults=True, use_thread=False, json_data=None):
        msg = self._build(operatorid=operatorid, federationid=federationid, use_defaults=use_defaults)
        msg_dict = msg

        return self.show(token=token, url=self.federatorgenerateapikey_url, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)[0]

    def create_federation(self, token=None, selfoperatorid=None, selffederationid=None, federation_name=None, operatorid=None, countrycode=None, federationid=None, federationaddr=None, apikey=None, use_defaults=True, use_thread=False, auto_delete=True, json_data=None, stream=False, stream_timeout=100):
        msg = self._build(selfoperatorid=selfoperatorid, selffederationid=selffederationid, federation_name=federation_name, operatorid=operatorid, countrycode=countrycode, federationid=federationid, federationaddr=federationaddr, apikey=apikey, use_defaults=use_defaults)
        msg_dict=msg

        thread_name = None
        msg_dict_delete = None
        if auto_delete and 'selfoperatorid' in msg and 'name' in msg:
            msg_delete = self._build(selfoperatorid=msg['selfoperatorid'], federation_name=msg['name'], use_defaults=False)
            msg_dict_delete =  msg_delete

        msg_dict_show = None
        if 'name' in msg:
            msg_show = self._build(federation_name=msg['name'], use_defaults=False)
            msg_dict_show =  msg_show
   
        return self.create(token=token, url=self.federationcreate_url, delete_url=self.federationdelete_url, show_url=self.federationshow_url, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, create_msg=msg_dict, delete_msg=msg_dict_delete, show_msg=msg_dict_show, thread_name=thread_name, stream=stream, stream_timeout=stream_timeout)

    def show_federation(self, token=None, federation_name=None, selfoperatorid=None, federationid=None,  use_defaults=True, use_thread=False, json_data=None):
        msg = self._build(federation_name=federation_name, selfoperatorid=selfoperatorid, federationid=federationid, use_defaults=use_defaults)
        msg_dict = msg

        return self.show(token=token, url=self.federationshow_url, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def delete_federation(self, token=None, federation_name=None, selfoperatorid=None, use_defaults=True, use_thread=False, json_data=None):
        msg = self._build(federation_name=federation_name, selfoperatorid=selfoperatorid, use_defaults=use_defaults)
        msg_dict = msg

        return self.delete(token=token, url=self.federationdelete_url, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def register_federation(self, token=None, federation_name=None, selfoperatorid=None, use_defaults=True, use_thread=False, json_data=None):
        msg = self._build(federation_name=federation_name, selfoperatorid=selfoperatorid, use_defaults=use_defaults)
        msg_dict = msg

        return self.show(token=token, url=self.federationregister_url, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)[0]

    def deregister_federation(self, token=None, federation_name=None, selfoperatorid=None, use_defaults=True, use_thread=False, json_data=None):
        msg = self._build(federation_name=federation_name, selfoperatorid=selfoperatorid, use_defaults=use_defaults)
        msg_dict = msg

        return self.show(token=token, url=self.federationderegister_url, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)[0]

    def setpartnerapikey_federation(self, token=None, federation_name=None, selfoperatorid=None, apikey=None, use_defaults=True, use_thread=False, json_data=None):
        msg = self._build(federation_name=federation_name, selfoperatorid=selfoperatorid, apikey=apikey, use_defaults=use_defaults)
        msg_dict = msg

        return self.show(token=token, url=self.federationsetpartnerkey_url, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)[0]

    def showpartnerzone_federatorzone(self, token=None, zoneid=None, selfoperatorid=None, federation_name=None, use_defaults=True, use_thread=False, json_data=None):
        msg = self._build(federation_name=federation_name, selfoperatorid=selfoperatorid, zoneid=zoneid, use_defaults=use_defaults)
        msg_dict = msg

        return self.show(token=token, url=self.showfederatedpartnerzone_url, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def showselfzone_federatorzone(self, token=None, zoneid=None, selfoperatorid=None, federation_name=None, use_defaults=True, use_thread=False, json_data=None):
        msg = self._build(federation_name=federation_name, selfoperatorid=selfoperatorid, zoneid=zoneid, use_defaults=use_defaults)
        msg_dict = msg

        return self.show(token=token, url=self.showfederatedselfzone_url, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def register_federatorzone(self, token=None, zones=[], selfoperatorid=None, federation_name=None, use_defaults=True, use_thread=False, json_data=None):
        msg = self._build(federation_name=federation_name, selfoperatorid=selfoperatorid, zones=zones, use_defaults=use_defaults)
        msg_dict = msg

        return self.show(token=token, url=self.registerfederatorzone_url, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def create_federatorzone(self, token=None, zoneid=None, operatorid=None, countrycode=None, cloudlets=[], geolocation=None, region=None, city=None, state=None, locality=None, use_defaults=True, use_thread=False, json_data=None, auto_delete=True, stream=False, stream_timeout=100):
        msg = self._build(zoneid=zoneid, operatorid=operatorid, countrycode=countrycode, cloudlets=cloudlets, geolocation=geolocation, city=city, state=state, locality=locality, use_defaults=use_defaults)
        msg_dict = msg

        thread_name = None
        msg_dict_show = None
        if 'zoneid' in msg and 'operatorid' in msg:
            msg_show = self._build(operatorid=msg['operatorid'], zoneid=msg['zoneid'], use_defaults=False)
            msg_dict_show =  msg_show

        msg_dict_delete = None
        if auto_delete and 'operatorid' in msg and 'zoneid' in msg:
            msg_delete = self._build(operatorid=msg['operatorid'], zoneid=msg['zoneid'], countrycode=msg['countrycode'], use_defaults=False)
            msg_dict_delete =  msg_delete

        return self.create(token=token, url=self.federatorzonecreate_url, delete_url=self.federatorzonedelete_url, show_url=self.federatorzoneshow_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, create_msg=msg_dict, delete_msg=msg_dict_delete, show_msg=msg_dict_show, thread_name=thread_name, stream=stream, stream_timeout=stream_timeout)

    def show_federatorzone(self, token=None, zoneid=None, operatorid=None, countrycode=None, region=None, city=None, use_defaults=True, use_thread=False, json_data=None):
        msg = self._build(zoneid=zoneid, operatorid=operatorid, countrycode=countrycode, city=city, use_defaults=use_defaults)
        msg_dict = msg

        return self.show(token=token, url=self.federatorzoneshow_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def delete_federatorzone(self, token=None, zoneid=None, operatorid=None, countrycode=None, use_defaults=True, use_thread=False, json_data=None):
        msg = self._build(zoneid=zoneid, operatorid=operatorid, countrycode=countrycode, use_defaults=use_defaults)
        msg_dict = msg

        return self.delete(token=token, url=self.federatorzonedelete_url, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)
