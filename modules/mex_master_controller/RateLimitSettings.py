import logging

import shared_variables

from mex_master_controller.MexOperation import MexOperation

logger = logging.getLogger(__name__)


class RateLimitSettings(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.showall_url = '/auth/ctrl/ShowRateLimitSettings'

        self.create_url = '/auth/ctrl/CreateFlowRateLimitSettings'
        self.show_url = '/auth/ctrl/ShowFlowRateLimitSettings'
        self.delete_url = '/auth/ctrl/DeleteFlowRateLimitSettings'
        self.update_url = '/auth/ctrl/UpdateFlowRateLimitSettings'

        self.createmaxreqs_url = '/auth/ctrl/CreateMaxReqsRateLimitSettings'
        self.showmaxreqs_url = '/auth/ctrl/ShowMaxReqsRateLimitSettings'
        self.deletemaxreqs_url = '/auth/ctrl/DeleteMaxReqsRateLimitSettings'
        self.updatemaxreqs_url = '/auth/ctrl/UpdateMaxReqsRateLimitSettings'

        self.createmc_url = '/auth/ratelimitsettingsmc/createflow'
        self.showmc_url = '/auth/ratelimitsettingsmc/showflow'
        self.deletemc_url = '/auth/ratelimitsettingsmc/deleteflow'
        self.updatemc_url = '/auth/ratelimitsettingsmc/updateflow'

    def _build(self, flow_settings_name=None, max_requests_settings_name=None, api_name=None, api_endpoint_type=None, rate_limit_target=None, flow_algorithm=None, requests_per_second=None, burst_size=None, max_requests_algorithm=None, max_requests=None, interval=None, use_defaults=True):

        if flow_settings_name == 'default':
            flow_settings_name = shared_variables.flow_settings_name_default

#        if use_defaults:
#            if flow_settings_name is None:
#                flow_settings_name = shared_variables.flow_settings_name_default

        flow_dict = {}
        flow_key_dict = {}
        rate_limit_dict = {}
        if api_endpoint_type is not None:
            try:
                if api_endpoint_type.lower() == 'dme':
                    rate_limit_dict['api_endpoint_type'] = 1
                else:
                    rate_limit_dict['api_endpoint_type'] = api_endpoint_type
            except Exception:
                rate_limit_dict['api_endpoint_type'] = api_endpoint_type
        if api_name is not None:
            rate_limit_dict['api_name'] = api_name
        if rate_limit_target is not None:
            rate_limit_dict['rate_limit_target'] = rate_limit_target

        if max_requests_settings_name is not None:
            flow_key_dict['max_reqs_settings_name'] = max_requests_settings_name
        if flow_settings_name is not None:
            flow_key_dict['flow_settings_name'] = flow_settings_name
        if rate_limit_dict:
            flow_key_dict['rate_limit_key'] = rate_limit_dict

        settings_dict = {}
        if flow_algorithm is not None:
            try:
                if flow_algorithm.lower() == 'tokenbucketalgorithm':
                    settings_dict['flow_algorithm'] = 1
                elif flow_algorithm.lower() == 'leakybucketalgorithm':
                    settings_dict['flow_algorithm'] = 2
                else:
                    settings_dict['flow_algorithm'] = flow_algorithm
            except Exception:
                settings_dict['flow_algorithm'] = flow_algorithm
        if max_requests_algorithm is not None:
            try:
                if max_requests_algorithm.lower() == 'fixedwindowalgorithm':
                    settings_dict['max_reqs_algorithm'] = 1
            except Exception:
                settings_dict['max_reqs_algorithm'] = max_requests_algorithm
        if requests_per_second is not None:
            try:
                settings_dict['reqs_per_second'] = int(requests_per_second)
            except Exception:
                try:
                    settings_dict['reqs_per_second'] = float(requests_per_second)
                except Exception:
                    settings_dict['reqs_per_second'] = requests_per_second
        if max_requests is not None:
            try:
                settings_dict['max_requests'] = int(max_requests)
            except Exception:
                try:
                    settings_dict['max_requests'] = float(max_requests)
                except Exception:
                    settings_dict['max_requests'] = max_requests

        if interval is not None:
            settings_dict['interval'] = interval
        if burst_size is not None:
            try:
                settings_dict['burst_size'] = int(burst_size)
            except Exception:
                try:
                    settings_dict['burst_size'] = float(burst_size)
                except Exception:
                    settings_dict['burst_size'] = burst_size
        if flow_key_dict:
            flow_dict['key'] = flow_key_dict
        if settings_dict:
            flow_dict['settings'] = settings_dict
        print('xxx', flow_dict)
        return flow_dict

    def _buildmc(self, flow_settings_name=None, api_name=None, rate_limit_target=None, flow_algorithm=None, requests_per_second=None, burst_size=None, use_defaults=True):

        if flow_settings_name == 'default':
            flow_settings_name = shared_variables.flow_settings_name_default

        if use_defaults:
            if flow_settings_name is None:
                flow_settings_name = shared_variables.flow_settings_name_default

        flow_dict = {}
        if api_name is not None:
            flow_dict['ApiName'] = api_name
        if rate_limit_target is not None:
            flow_dict['RateLimitTarget'] = rate_limit_target
        if flow_settings_name is not None:
            flow_dict['FlowSettingsName'] = flow_settings_name
        if flow_algorithm is not None:
            try:
                if flow_algorithm.lower() == 'tokenbucketalgorithm':
                    flow_dict['FlowAlgorithm'] = 1
            except Exception:
                flow_dict['FlowAlgorithm'] = flow_algorithm
        if requests_per_second is not None:
            flow_dict['ReqsPerSecond'] = int(requests_per_second)

        return flow_dict

    def show_rate_limit_settings(self, token=None, region=None, flow_settings_name=None, api_name=None, api_endpoint_type=None, rate_limit_target=None, flow_algorithm=None, requests_per_second=None, burst_size=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(flow_settings_name=flow_settings_name, api_name=api_name, api_endpoint_type=api_endpoint_type, rate_limit_target=rate_limit_target, flow_algorithm=flow_algorithm, requests_per_second=requests_per_second, burst_size=burst_size, use_defaults=use_defaults)
        msg_dict = {'RateLimitSettings': {'key': msg['key']['rate_limit_key']}}

        return self.show(token=token, url=self.showall_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def create_rate_limit_flow(self, token=None, region=None, flow_settings_name=None, api_name=None, api_endpoint_type=None, rate_limit_target=None, flow_algorithm=None, requests_per_second=None, burst_size=None, json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        if use_defaults:
            if flow_settings_name is None:
                flow_settings_name = shared_variables.flow_settings_name_default

        msg = self._build(flow_settings_name=flow_settings_name, api_name=api_name, api_endpoint_type=api_endpoint_type, rate_limit_target=rate_limit_target, flow_algorithm=flow_algorithm, requests_per_second=requests_per_second, burst_size=burst_size, use_defaults=use_defaults)
        msg_dict = {'FlowRateLimitSettings': msg}

        msg_dict_delete = None
        if auto_delete and 'key' in msg and 'flow_settings_name' in msg['key'] and 'rate_limit_key' in msg['key'] and 'api_name' in msg['key']['rate_limit_key'] and 'api_endpoint_type' in msg['key']['rate_limit_key'] and 'rate_limit_target' in msg['key']['rate_limit_key']:
            msg_delete = self._build(flow_settings_name=msg['key']['flow_settings_name'], api_name=msg['key']['rate_limit_key']['api_name'], api_endpoint_type=msg['key']['rate_limit_key']['api_endpoint_type'], rate_limit_target=msg['key']['rate_limit_key']['rate_limit_target'], use_defaults=False)
            msg_dict_delete = {'FlowRateLimitSettings': msg_delete}

        msg_dict_show = None
        if 'key' in msg and 'flow_settings_name' in msg['key'] and 'flow_settings_name' in msg['key'] and 'rate_limit_key' in msg['key'] and 'api_name' in msg['key']['rate_limit_key'] and 'api_endpoint_type' in msg['key']['rate_limit_key'] and 'rate_limit_target' in msg['key']['rate_limit_key']:
            msg_show = self._build(flow_settings_name=msg['key']['flow_settings_name'], api_name=msg['key']['rate_limit_key']['api_name'], api_endpoint_type=msg['key']['rate_limit_key']['api_endpoint_type'], rate_limit_target=msg['key']['rate_limit_key']['rate_limit_target'], use_defaults=False)
            msg_dict_show = {'FlowRateLimitSettings': msg_show}

        return self.create(token=token, url=self.create_url, delete_url=self.delete_url, show_url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, create_msg=msg_dict, delete_msg=msg_dict_delete, show_msg=msg_dict_show)

    def show_rate_limit_flow(self, token=None, region=None, flow_settings_name=None, api_name=None, api_endpoint_type=None, rate_limit_target=None, flow_algorithm=None, requests_per_second=None, burst_size=None, json_data=None, use_defaults=True, use_thread=False):
        if use_defaults:
            if flow_settings_name is None:
                flow_settings_name = shared_variables.flow_settings_name_default

        msg = self._build(flow_settings_name=flow_settings_name, api_name=api_name, api_endpoint_type=api_endpoint_type, rate_limit_target=rate_limit_target, flow_algorithm=flow_algorithm, requests_per_second=requests_per_second, burst_size=burst_size, use_defaults=use_defaults)
        msg_dict = {'FlowRateLimitSettings': msg}

        return self.show(token=token, url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def delete_rate_limit_flow(self, token=None, region=None, flow_settings_name=None, api_name=None, api_endpoint_type=None, rate_limit_target=None, flow_algorithm=None, requests_per_second=None, burst_size=None, json_data=None, use_defaults=True, use_thread=False):
        if use_defaults:
            if flow_settings_name is None:
                flow_settings_name = shared_variables.flow_settings_name_default

        msg = self._build(flow_settings_name=flow_settings_name, api_name=api_name, api_endpoint_type=api_endpoint_type, rate_limit_target=rate_limit_target, flow_algorithm=flow_algorithm, requests_per_second=requests_per_second, burst_size=burst_size, use_defaults=use_defaults)
        msg_dict = {'FlowRateLimitSettings': msg}

        return self.delete(token=token, url=self.delete_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def update_rate_limit_flow(self, token=None, region=None, flow_settings_name=None, api_name=None, api_endpoint_type=None, rate_limit_target=None, flow_algorithm=None, requests_per_second=None, burst_size=None, json_data=None, auto_delete=True, use_defaults=True, use_thread=False):
        if use_defaults:
            if flow_settings_name is None:
                flow_settings_name = shared_variables.flow_settings_name_default

        msg = self._build(flow_settings_name=flow_settings_name, api_name=api_name, api_endpoint_type=api_endpoint_type, rate_limit_target=rate_limit_target, flow_algorithm=flow_algorithm, requests_per_second=requests_per_second, burst_size=burst_size, use_defaults=use_defaults)
        msg_dict = {'FlowRateLimitSettings': msg}

        msg_dict_show = None
        if 'key' in msg and 'flow_settings_name' in msg['key'] and 'flow_settings_name' in msg['key'] and 'rate_limit_key' in msg['key'] and 'api_name' in msg['key']['rate_limit_key'] and 'api_endpoint_type' in msg['key']['rate_limit_key'] and 'rate_limit_target' in msg['key']['rate_limit_key']:
            msg_show = self._build(flow_settings_name=msg['key']['flow_settings_name'], api_name=msg['key']['rate_limit_key']['api_name'], api_endpoint_type=msg['key']['rate_limit_key']['api_endpoint_type'], rate_limit_target=msg['key']['rate_limit_key']['rate_limit_target'], use_defaults=False)
            msg_dict_show = {'FlowRateLimitSettings': msg_show}

        return self.update(token=token, url=self.update_url, show_url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict, show_msg=msg_dict_show)

    def create_rate_limit_max_requests(self, token=None, region=None, max_requests_settings_name=None, api_name=None, api_endpoint_type=None, rate_limit_target=None, max_requests_algorithm=None, max_requests=None, interval=None, json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        if use_defaults:
            if max_requests_settings_name is None:
                max_requests_settings_name = shared_variables.max_requests_settings_name_default

        msg = self._build(max_requests_settings_name=max_requests_settings_name, api_name=api_name, api_endpoint_type=api_endpoint_type, rate_limit_target=rate_limit_target, max_requests_algorithm=max_requests_algorithm, max_requests=max_requests, interval=interval, use_defaults=use_defaults)
        msg_dict = {'MaxReqsRateLimitSettings': msg}

        msg_dict_delete = None
        if auto_delete and 'key' in msg and 'max_reqs_settings_name' in msg['key']:
            msg_delete = self._build(max_requests_settings_name=msg['key']['max_reqs_settings_name'], api_name=msg['key']['rate_limit_key']['api_name'], api_endpoint_type=msg['key']['rate_limit_key']['api_endpoint_type'], rate_limit_target=msg['key']['rate_limit_key']['rate_limit_target'], use_defaults=False)
            msg_dict_delete = {'MaxReqsRateLimitSettings': msg_delete}

        msg_dict_show = None
        if 'key' in msg and 'max_reqs_settings_name' in msg['key']:
            msg_show = self._build(max_requests_settings_name=msg['key']['max_reqs_settings_name'], api_name=msg['key']['rate_limit_key']['api_name'], api_endpoint_type=msg['key']['rate_limit_key']['api_endpoint_type'], rate_limit_target=msg['key']['rate_limit_key']['rate_limit_target'], use_defaults=False)
            msg_dict_show = {'MaxReqsRateLimitSettings': msg_show}

        return self.create(token=token, url=self.createmaxreqs_url, delete_url=self.deletemaxreqs_url, show_url=self.showmaxreqs_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, create_msg=msg_dict, delete_msg=msg_dict_delete, show_msg=msg_dict_show)

    def delete_rate_limit_max_requests(self, token=None, region=None, max_requests_settings_name=None, api_name=None, api_endpoint_type=None, rate_limit_target=None, max_requests_algorithm=None, max_requests=None, interval=None, json_data=None, use_defaults=True, use_thread=False):
        if use_defaults:
            if max_requests_settings_name is None:
                max_requests_settings_name = shared_variables.max_requests_settings_name_default

        msg = self._build(max_requests_settings_name=max_requests_settings_name, api_name=api_name, api_endpoint_type=api_endpoint_type, rate_limit_target=rate_limit_target, max_requests_algorithm=max_requests_algorithm, max_requests=max_requests, interval=interval, use_defaults=use_defaults)
        msg_dict = {'MaxReqsRateLimitSettings': msg}

        return self.delete(token=token, url=self.deletemaxreqs_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def update_rate_limit_max_requests(self, token=None, region=None, max_requests_settings_name=None, api_name=None, api_endpoint_type=None, rate_limit_target=None, max_requests_algorithm=None, max_requests=None, interval=None, json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        if use_defaults:
            if max_requests_settings_name is None:
                max_requests_settings_name = shared_variables.max_requests_settings_name_default

        msg = self._build(max_requests_settings_name=max_requests_settings_name, api_name=api_name, api_endpoint_type=api_endpoint_type, rate_limit_target=rate_limit_target, max_requests_algorithm=max_requests_algorithm, max_requests=max_requests, interval=interval, use_defaults=use_defaults)
        msg_dict = {'MaxReqsRateLimitSettings': msg}

        msg_dict_show = None
        if 'key' in msg and 'max_reqs_settings_name' in msg['key']:
            msg_show = self._build(max_requests_settings_name=msg['key']['max_reqs_settings_name'], api_name=msg['key']['rate_limit_key']['api_name'], api_endpoint_type=msg['key']['rate_limit_key']['api_endpoint_type'], rate_limit_target=msg['key']['rate_limit_key']['rate_limit_target'], use_defaults=False)
            msg_dict_show = {'MaxReqsRateLimitSettings': msg_show}

        return self.update(token=token, url=self.updatemaxreqs_url, show_url=self.showmaxreqs_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict, show_msg=msg_dict_show)

    def create_mc_rate_limit_flow(self, token=None, region=None, flow_settings_name=None, api_name=None, rate_limit_target=None, flow_algorithm=None, requests_per_second=None, burst_size=None, json_data=None, use_defaults=True, auto_delete=True, use_thread=False):
        msg = self._buildmc(flow_settings_name=flow_settings_name, api_name=api_name, rate_limit_target=rate_limit_target, flow_algorithm=flow_algorithm, requests_per_second=requests_per_second, burst_size=burst_size, use_defaults=use_defaults)
        msg_dict = msg

        msg_dict_delete = None
        if auto_delete and 'FlowSettingsName' in msg:
            msg_delete = self._buildmc(flow_settings_name=msg['FlowSettingsName'], api_name=msg['ApiName'], rate_limit_target=msg['RateLimitTarget'], flow_algorithm=msg['FlowAlgorithm'], requests_per_second=msg['ReqsPerSecond'], use_defaults=False)
            msg_dict_delete = msg_delete

        msg_dict_show = None
        if 'FlowSettingsName' in msg:
            msg_show = self._buildmc(flow_settings_name=msg['FlowSettingsName'], api_name=msg['ApiName'], rate_limit_target=msg['RateLimitTarget'], flow_algorithm=msg['FlowAlgorithm'], requests_per_second=msg['ReqsPerSecond'], use_defaults=False)
            msg_dict_show = msg_show

        return self.create(token=token, url=self.createmc_url, delete_url=self.deletemc_url, show_url=self.showmc_url, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, create_msg=msg_dict, delete_msg=msg_dict_delete, show_msg=msg_dict_show)

    def show_mc_rate_limit_flow(self, token=None, region=None, flow_settings_name=None, api_name=None, rate_limit_target=None, flow_algorithm=None, requests_per_second=None, burst_size=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._buildmc(flow_settings_name=flow_settings_name, api_name=api_name, rate_limit_target=rate_limit_target, flow_algorithm=flow_algorithm, requests_per_second=requests_per_second, burst_size=burst_size, use_defaults=use_defaults)
        msg_dict = msg

        return self.show(token=token, url=self.showmc_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def delete_mc_rate_limit_flow(self, token=None, region=None, flow_settings_name=None, api_name=None, rate_limit_target=None, flow_algorithm=None, requests_per_second=None, burst_size=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._buildmc(flow_settings_name=flow_settings_name, api_name=api_name, rate_limit_target=rate_limit_target, flow_algorithm=flow_algorithm, requests_per_second=requests_per_second, burst_size=burst_size, use_defaults=use_defaults)
        msg_dict = msg

        return self.delete(token=token, url=self.deletemc_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def update_mc_rate_limit_flow(self, token=None, region=None, flow_settings_name=None, api_name=None, rate_limit_target=None, flow_algorithm=None, requests_per_second=None, burst_size=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._buildmc(flow_settings_name=flow_settings_name, api_name=api_name, rate_limit_target=rate_limit_target, flow_algorithm=flow_algorithm, requests_per_second=requests_per_second, burst_size=burst_size, use_defaults=use_defaults)
        msg_dict = msg

        msg_dict_show = None
        if 'FlowSettingsName' in msg:
            msg_show = self._buildmc(flow_settings_name=msg['FlowSettingsName'], api_name=msg['ApiName'], rate_limit_target=msg['RateLimitTarget'], flow_algorithm=msg['FlowAlgorithm'], requests_per_second=msg['ReqsPerSecond'], use_defaults=False)
            msg_dict = msg_show

        return self.update(token=token, url=self.updatemc_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)
