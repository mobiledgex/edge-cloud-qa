import json
import logging
import shared_variables

from mex_master_controller.MexOperation import MexOperation

logger = logging.getLogger('mex_mastercontroller rest')
class Config(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.update_url = '/auth/config/update'
        self.show_url = '/auth/config/show'

     #curl -X POST "https://console-qa.mobiledgex.net:443/api/v1/auth/config/update" -H "Content-Type: application/json" -H "Authorization: Bearer ${TOKEN}" -k --data-raw '{"adminpasswordmincracktimesec":63072000,"locknewaccounts":true,"notifyemailaddress":"mexcontester@gmail.com","passwordmincracktimesec":2592000,"skipverifyemail":true}'

    def _build(self, skip_verify_email=None, lock_accounts=None, notify_email=None, user_pass=None, admin_pass=None, max_metrics_data_points=None, billing_enable=None):
        configverify_dict = {}

        if skip_verify_email is not None:
            configverify_dict['skipverifyemail'] = skip_verify_email
        if lock_accounts is not None:
            configverify_dict['locknewaccounts'] = lock_accounts
        if notify_email is not None:
            configverify_dict['notifyemailaddress'] = notify_email
        if user_pass is not None:
            configverify_dict['passwordmincracktimesec'] = user_pass
        if admin_pass is not None:
            configverify_dict['adminpasswordmincracktimesec'] = admin_pass
        if billing_enable is not None:
            configverify_dict['billingenable'] = billing_enable
        if max_metrics_data_points is not None:
            configverify_dict['maxmetricsdatapoints'] = int(max_metrics_data_points)

        return configverify_dict

    def show_config(self, token=None,  use_defaults=False, use_thread=False):
        msg = self._build()
        msg_show = msg

        return self.show(token=token, url=self.show_url, use_defaults=True, use_thread=use_thread, message=msg_show)[0]

    def update_config(self, token=None, skip_verify_email=None, lock_accounts=None, notify_email=None,  user_pass=None, admin_pass=None, max_metrics_data_points=None, billing_enable=None, use_defaults=True, use_thread=False):
        msg = self._build(skip_verify_email=skip_verify_email, lock_accounts = lock_accounts, notify_email= notify_email, user_pass = user_pass, admin_pass = admin_pass, max_metrics_data_points=max_metrics_data_points, billing_enable=billing_enable)
        msg_show = msg 

        return self.update(token=token, show_msg=msg_show, url=self.update_url, show_url=self.show_url, use_defaults=use_defaults, use_thread=use_thread, message=msg)

