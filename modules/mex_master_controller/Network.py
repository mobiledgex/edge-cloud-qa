import logging

import shared_variables

from mex_master_controller.MexOperation import MexOperation

logger = logging.getLogger(__name__)


class Network(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.create_url = '/auth/ctrl/CreateNetwork'
        self.delete_url = '/auth/ctrl/DeleteNetwork'
        self.show_url = '/auth/ctrl/ShowNetwork'
        self.update_url = '/auth/ctrl/UpdateNetwork'

    def _build(self, network_name=None, cloudlet_name=None, cloudlet_org=None, connection_type=None, federated_org=None,  route_list=[], include_fields=False, use_defaults=True):

        network_dict = {}
        cloudlet_key_dict = {}
        node_dict = {}

        if connection_type is not None:
            network_dict['connection_type'] = connection_type

        if federated_org is not None:
            cloudlet_key_dict['federated_organization'] = federated_org
        if cloudlet_name is not None:
            cloudlet_key_dict['name'] = cloudlet_name
        if cloudlet_org is not None:
            cloudlet_key_dict['organization'] = cloudlet_org
        if cloudlet_key_dict:
            node_dict['cloudlet_key'] = cloudlet_key_dict

        if network_name:
            node_dict['name'] = network_name

        if node_dict:
            network_dict['key'] = node_dict

        route_dict_list = []

        if 'empty' not in route_list:
            for route in route_list:
                route_dict = {}
                if 'destination_cidr' in route and route['destination_cidr'] is not None:
                    route_dict['destination_cidr'] = route['destination_cidr']
                if 'next_hop_ip' in route and route['next_hop_ip'] is not None:
                    route_dict['next_hop_ip'] = route['next_hop_ip']
                if route_dict:
                    route_dict_list.append(route_dict)
            network_dict['routes'] = route_dict_list
        else:
            network_dict['routes'] = []

        return network_dict

    def create_network(self, token=None, region=None, network_name=None, cloudlet_name=None, cloudlet_org=None, connection_type=None, federated_org=None, route_list=None, json_data=None, auto_delete=True, use_defaults=True, use_thread=False):
        msg = self._build(network_name=network_name, cloudlet_name=cloudlet_name, cloudlet_org=cloudlet_org, connection_type=connection_type, federated_org=federated_org, route_list=route_list, use_defaults=use_defaults)
        msg_dict = {'Network': msg}

        msg_dict_delete = None
        if auto_delete and 'key' in msg and 'name' in msg['key'] and 'organization' in msg['key']['cloudlet_key'] and 'name' in msg['key']['cloudlet_key']:
            msg_delete = self._build(network_name=msg['key']['name'], cloudlet_name=msg['key']['cloudlet_key']['name'], cloudlet_org=msg['key']['cloudlet_key']['organization'], use_defaults=False)
            msg_dict_delete = {'Network': msg_delete}

        msg_dict_show = None
        if 'key' in msg and 'name' in msg['key'] and 'organization' in msg['key']['cloudlet_key'] and 'name' in msg['key']['cloudlet_key']:
            msg_show = self._build(network_name=msg['key']['name'], cloudlet_name=msg['key']['cloudlet_key']['name'], cloudlet_org=msg['key']['cloudlet_key']['organization'], use_defaults=False)
            msg_dict_show = {'Network': msg_show}

        return self.create(token=token, url=self.create_url, delete_url=self.delete_url, show_url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, create_msg=msg_dict, delete_msg=msg_dict_delete, show_msg=msg_dict_show)

    def delete_network(self, token=None, region=None, network_name=None, cloudlet_name=None, cloudlet_org=None, connection_type=None, federated_org=None, route_list=[], json_data=None, auto_delete=True, use_defaults=True, use_thread=False):
        msg = self._build(network_name=network_name, cloudlet_name=cloudlet_name, cloudlet_org=cloudlet_org, connection_type=connection_type, federated_org=federated_org, route_list=route_list, use_defaults=use_defaults)
        msg_dict = {'Network': msg}

        return self.delete(token=token, url=self.delete_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def show_network(self, token=None, region=None, network_name=None, cloudlet_name=None, cloudlet_org=None, json_data=None, auto_delete=True, use_defaults=True, use_thread=False):
        msg = self._build(network_name=network_name, cloudlet_name=cloudlet_name, cloudlet_org=cloudlet_org, use_defaults=use_defaults)
        msg_dict = {'Network': msg}

        return self.show(token=token, url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def update_network(self, token=None, region=None, network_name=None, cloudlet_name=None, cloudlet_org=None, connection_type=None, federated_org=None, route_list=None, json_data=None, auto_delete=True, use_defaults=True, use_thread=False):
        msg = self._build(network_name=network_name, cloudlet_name=cloudlet_name, cloudlet_org=cloudlet_org, connection_type=connection_type, federated_org=federated_org, route_list=route_list, use_defaults=use_defaults)
        msg_dict = {'Network': msg}

        msg_dict_show = None
        if 'name' in msg['name']:
            msg_show = self._build(network_name=msg['name'], use_defaults=False)
            msg_dict_show = {'Network': msg_show}

        return self.update(token=token, url=self.update_url, show_url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict, show_msg=msg_dict_show)
