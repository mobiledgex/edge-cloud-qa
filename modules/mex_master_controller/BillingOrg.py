import json
import logging
import shared_variables
from mex_master_controller.MexOperation import MexOperation

logger = logging.getLogger(__name__)


class BillingOrg(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.create_url = '/auth/billingorg/create'
        self.delete_url = '/auth/billingorg/delete'
        self.show_url = '/auth/billingorg/show'
        self.update_url = '/auth/billingorg/update'

    def _build(self, billing_org_name=None, billing_org_type=None, first_name=None, last_name=None, email_address=None,
               include_fields=False, use_defaults=True):
        billing_org_dict = {}
        if use_defaults:
            if billing_org_name is None:
                billing_org_name = shared_variables.org_name_default
            if billing_org_type is None:
                billing_org_type = shared_variables.org_type_defualt
            if first_name is None:
                first_name = shared_variables.first_name_default
            if last_name is None:
                last_name = shared_variables.last_name_default
            if email_address is None:
                email_address = shared_variables.email_address_default
        if billing_org_name is not None:
            billing_org_dict['name'] = billing_org_name
        if billing_org_type is not None:
            billing_org_dict['type'] = billing_org_type
        if first_name is not None:
            billing_org_dict['firstname'] = first_name
        if last_name is not None:
            billing_org_dict['lastname'] = last_name
        if email_address is not None:
            billing_org_dict['email'] = email_address

        return billing_org_dict

    def create_billing_org(self, token=None, billing_org_name=None, billing_org_type=None, first_name=None,
                           last_name=None, email_address=None, json_data=None, use_defaults=True, auto_delete=True,
                           use_thread=False, msg_delete=None):
        msg = self._build(billing_org_name=billing_org_name, billing_org_type=billing_org_type, first_name=first_name,
                          last_name=last_name, email_address=email_address, use_defaults=use_defaults)
        msg_dict = msg

        msg_dict_delete = None
        if auto_delete and 'name' in msg_dict and 'type' in msg_dict and 'firstname' in msg_dict and 'lastname' in msg_dict:
            msg_delete = self._build(billing_org_name=msg['name'], billing_org_type=msg['type'],
                                     first_name=msg['firstname'], last_name=msg['lastname'], email_address=msg['email'],
                                     use_defaults=False)
            msg_dict_delete = msg_delete

        msg_dict_show = {}

        return self.create(token=token, url=self.create_url, delete_url=self.delete_url, show_url=self.show_url,
                    json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, create_msg=msg_dict,
                    delete_msg=msg_dict_delete, show_msg=msg_dict_show)[0]

    def delete_billing_org(self, token=None, billing_org_name=None, json_data=None, use_defaults=True, auto_delete=True,
                           use_thread=False):
        msg = self._build(billing_org_name=billing_org_name)
        msg_dict = msg

        return self.delete(token=token, url=self.delete_url, json_data=json_data, use_defaults=use_defaults,
                           use_thread=use_thread, message=msg_dict)

    # def update_billing_org(self, token=None, billing_org_name=None, first_name=None, last_name=None,
    # email_address=None, address=None, city=None, country=None, state=None, postal_code=None, json_data=None,
    # use_defaults=True, auto_delete=True, use_thread=False): msg = self._build(billing_org_name=billing_org_name,
    # first_name=first_name, last_name=last_name, email_address=email_address, address=address, city=city,
    # country=country, state=state, postal_code=postalcode, use_defaults=use_defaults,use_thread=use_thread,
    # message=msg_dict) msg_dict = msg
    #
    # msg_dict_update = None if auto_update and 'name' in msg_dict and 'type' in msg_dict and 'firstname' in msg_dict
    # and 'lastname' and 'address' in msg_dict and 'city' in msg_dict and country in msg_dict and state in msg_dict
    # and  in msg_dict_update: msg_update = self._build(billing_org_name=msg['name'], billing_org_type=msg['type'],
    # first_name=msg['firstname'], last_name=msg['lastname'], email_address=msg['email'], address=msg['address'],
    # city=msg['city'], country=msg['country'], state=['state'], postal_code=['postalcode'], use_defaults=False)
    # msg_dict_update = msg_dict_update
    #
    #
    #
    # return self.update(token=token, url=self.update_url, json_data-json_data, use_defaults=True,
    # use_thread=use_thread, message= msg_dict)
