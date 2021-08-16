import logging
import re

import shared_variables

from mex_master_controller.MexOperation import MexOperation

logger = logging.getLogger(__name__)


class OperatorReporting(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.create_url = '/auth/reporter/create'
        self.delete_url = '/auth/reporter/delete'
        self.show_url = '/auth/reporter/show'
        self.update_url = '/auth/reporter/update'

    def _build(self, reporter_name=None, organization=None, email=None, schedule=None, start_schedule_date=None, timezone=None,  use_defaults=True):

        if use_defaults:
            if reporter_name is None:
                reporter_name = shared_variables.reporter_name_default
            if organization is None:
                organization = shared_variables.operator_name_default

        reporter_dict = {}
        if reporter_name is not None:
            reporter_dict['Name'] = reporter_name

        if organization is not None:
            reporter_dict['Org'] = organization

        if email is not None:
            reporter_dict['Email'] = email

        if schedule is not None:
            reporter_dict['Schedule'] = schedule

        if start_schedule_date is not None:
            reporter_dict['StartScheduleDate'] = start_schedule_date           

        if timezone is not None:
            reporter_dict['Timezone'] = timezone

        return reporter_dict

    def create_reporter(self, token=None, reporter_name=None, organization=None, email=None, schedule=None, start_schedule_date=None, timezone=None, use_defaults=True, use_thread=False, auto_delete=True, json_data=None, stream=False, stream_timeout=100):
        msg = self._build(reporter_name=reporter_name, organization=organization, email=email, schedule=schedule, start_schedule_date=start_schedule_date, timezone=timezone, use_defaults=use_defaults)
        msg_dict = msg

        thread_name = None
        msg_dict_delete = None
        if auto_delete and 'Name' in msg and 'Org' in msg:
            msg_delete = self._build(reporter_name=msg['Name'], organization=msg['Org'], use_defaults=False)
            msg_dict_delete =  msg_delete

        msg_dict_show = None
        if 'Name' in msg and 'Org' in msg:
            msg_show = self._build(reporter_name=msg['Name'], organization=msg['Org'], use_defaults=False)
            msg_dict_show =  msg_show

        return self.create(token=token, url=self.create_url, delete_url=self.delete_url, show_url=self.show_url, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, create_msg=msg_dict, delete_msg=msg_dict_delete, show_msg=msg_dict_show, thread_name=thread_name, stream=stream, stream_timeout=stream_timeout)[0]

    def update_reporter(self, token=None, reporter_name=None, organization=None, email=None, schedule=None, start_schedule_date=None, timezone=None, use_defaults=True, use_thread=False, json_data=None):
        msg = self._build(reporter_name=reporter_name, organization=organization, email=email, schedule=schedule, start_schedule_date=start_schedule_date, timezone=timezone, use_defaults=use_defaults)
        msg_dict = msg

        msg_dict_show = None
        if 'Name' in msg and 'Org' in msg:
            msg_show = self._build(reporter_name=msg['Name'], organization=msg['Org'], use_defaults=False)
            msg_dict_show =  msg_show

        return self.update(token=token, url=self.update_url, show_url=self.show_url, json_data=json_data, use_defaults=True, use_thread=use_thread, message=msg_dict, show_msg=msg_dict_show)

    def delete_reporter(self, token=None, reporter_name=None, organization=None, use_defaults=True, use_thread=False, json_data=None):
        msg = self._build(reporter_name=reporter_name, organization=organization, use_defaults=use_defaults)
        msg_dict = msg

        return self.delete(token=token, url=self.delete_url, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def show_reporter(self, token=None, reporter_name=None, organization=None, use_defaults=True, use_thread=False, json_data=None):
        msg = self._build(reporter_name=reporter_name, organization=organization, use_defaults=use_defaults)
        msg_dict = msg

        return self.show(token=token, url=self.show_url, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

