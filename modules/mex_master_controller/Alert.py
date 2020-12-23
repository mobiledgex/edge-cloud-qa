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
    def _build(self, region=None, alert_name=None, app_name=None, app_version=None, app_cloudlet_name=None, app_cloudlet_org=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, port=None, use_defaults=True):
        alert_dict = {}
        labels_dict = {}

        if region is not None:
            labels_dict['region'] = region
        if alert_name is not None:
            labels_dict['alertname'] = alert_name
        if app_name is not None:
            labels_dict['app'] = app_name
        if app_version is not None:
            labels_dict['appver'] = app_version
        if developer_org_name is not None:
            labels_dict['apporg'] = developer_org_name
        if cloudlet_name is not None:
            labels_dict['cloudlet'] = cloudlet_name
        if operator_org_name is not None:
            labels_dict['cloudletorg'] = operator_org_name
        if cluster_instance_name is not None:
            labels_dict['cluster'] = cluster_instance_name
        if cluster_instance_developer_org_name is not None:
            labels_dict['clusterorg'] = cluster_instance_developer_org_name

        if port is not None:
            labels_dict['port'] = str(port)


        if labels_dict:
            alert_dict['labels'] = labels_dict

        return alert_dict

    def show_alert(self, alert_name=None, region=None, app_name=None, app_version=None, developer_org_name=None, cloudlet_name=None, operator_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, port=None, token=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(region=region, alert_name=alert_name, app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, developer_org_name=developer_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, port=port, use_defaults=use_defaults)
        msg_dict = {'alert': msg}

        return self.show(token=token, url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)
