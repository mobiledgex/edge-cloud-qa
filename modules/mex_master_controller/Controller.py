import logging

import shared_variables

from mex_master_controller.MexOperation import MexOperation

logger = logging.getLogger(__name__)


class Controller(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.create_url = '/auth/controller/create'
        self.delete_url = '/auth/controller/delete'
        self.show_url = '/auth/controller/show'

    def _build(self, controller_address=None, influxdb_address=None, use_defaults=True):
        controller_dict = {}
        if controller_address is not None:
            controller_dict['Address'] = controller_address
        if influxdb_address is not None:
            controller_dict['InfluxDB'] = influxdb_address

        return controller_dict

    def create_controller(self, token=None, region=None, controller_address=None, influxdb_address=None, json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        msg = self._build(controller_address=controller_address, influxdb_address=influxdb_address, use_defaults=use_defaults)
        msg_dict = msg

        msg_dict_delete = None
        #if auto_delete:
        #    msg_delete = self._build(cloudlet_pool_name=msg['cloudletpool'], cloudlet_pool_org_name=msg['cloudletpoolorg'], developer_org_name=msg['org'], use_defaults=False)
        #    msg_dict_delete = msg_delete

        msg_dict_show = None
        if 'Address' in msg_dict:
            msg_show = self._build(controller_address=msg['Address'], influxdb_address=influxdb_address, use_defaults=False)
            msg_dict_show = msg_show

        return self.create(token=token, url=self.create_url, delete_url=self.delete_url, show_url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, create_msg=msg_dict, delete_msg=msg_dict_delete, show_msg=msg_dict_show)[0]


    def show_controller(self, token=None, region=None, controller_address=None, influxdb_address=None, json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        msg = self._build(controller_address=controller_address, influxdb_address=influxdb_address, use_defaults=use_defaults)
        msg_dict = msg

        return self.show(token=token, url=self.show_url, region=region, json_data=json_data, use_defaults=True, use_thread=use_thread, message=msg_dict)

