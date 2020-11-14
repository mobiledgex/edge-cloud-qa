import json
import logging
import email
import imaplib
import time
from slack import WebClient

import shared_variables

from mex_master_controller.MexOperation import MexOperation

logger = logging.getLogger('mex alertreceiver rest')


class AlertReceiver(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token)

        self.create_url = '/auth/alertreceiver/create'
        self.delete_url = '/auth/alertreceiver/delete'
        self.show_url = '/auth/alertreceiver/show'

        self.slack_token = 'xoxb-313978814983-1439649519408-2VLnGtw8kG7Krl3aGudkQoww' 
        self.slack_channel = 'C01CE9BNV6J'  # qa-alertreceiver

    def _build(self, receiver_name=None, type=None, severity=None, email_address=None, slack_channel=None, slack_api_url=None, app_name=None, app_version=None, app_cloudlet_name=None, app_cloudlet_org=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, use_defaults=True):
        logging.info(f'usedef {use_defaults}')
        if use_defaults:
            if receiver_name is None: receiver_name = shared_variables.alert_receiver_name_default
            if type is None: type = shared_variables.alert_receiver_type_default
            if severity is None: severity = shared_variables.alert_receiver_severity_default
            #if app_name is None: app_name = shared_variables.app_name_default
            #if developer_org_name is None: developer_org_name = shared_variables.developer_name_default
            #if app_version is None: app_version = shared_variables.app_version_default
        
        #{"name":"DevOrgReceiver1","type":"email","severity":"error","appinst":{"app_key":{"organization":"DevOrg","name":"Face Detection Demo","version":"1.0"},"clusterinstkey":{"clusterkey":{"name":"AppCluster"},"cloudlet_key":{"organization":"mexdev","name":"localtest"},"organization":"DevOrg"}}}
        receiver_dict = {}
        app_key_dict = {}
        appinst_key_dict = {}
        cloudlet_key_dict = {}
        cluster_key_dict = {}
        app_cloudlet_key_dict = {}
 
        if receiver_name is not None:
            receiver_dict['name'] = receiver_name
        if type is not None:
            receiver_dict['type'] = type
        if severity is not None:
            receiver_dict['severity'] = severity

        if slack_channel is not None:
            receiver_dict['slackchannel'] = slack_channel
        if slack_api_url is not None:
            receiver_dict['slackwebhook'] = slack_api_url
        if email_address is not None:
            receiver_dict['email'] = email_address

        if app_name:
            app_key_dict['name'] = app_name
        if app_version:
            app_key_dict['version'] = app_version
        if developer_org_name is not None:
            app_key_dict['organization'] = developer_org_name

        if app_cloudlet_name:
            app_cloudlet_key_dict['name'] = app_cloudlet_name
        if app_cloudlet_org:
            app_cloudlet_key_dict['organization'] = app_cloudlet_org

        if cloudlet_name is not None:
            cloudlet_key_dict['name'] = cloudlet_name
        if operator_org_name is not None:
            cloudlet_key_dict['organization'] = operator_org_name

        if cluster_instance_name is not None:
            cluster_key_dict['cluster_key'] = {'name': cluster_instance_name}
        if cluster_instance_developer_org_name is not None:
            cluster_key_dict['organization'] = cluster_instance_developer_org_name
        if app_cloudlet_key_dict:
            cluster_key_dict['cloudlet_key'] = app_cloudlet_key_dict

        if app_key_dict:
           appinst_key_dict['app_key'] = app_key_dict
        if cluster_key_dict:
           appinst_key_dict['cluster_inst_key'] = cluster_key_dict

        if cloudlet_key_dict:
            receiver_dict['cloudlet'] = cloudlet_key_dict
        if appinst_key_dict:
            receiver_dict['appinst'] = appinst_key_dict

        return receiver_dict

    def create_alert_receiver(self, token=None, receiver_name=None, type=None, severity=None, email_address=None, slack_channel=None, slack_api_url=None, app_name=None, app_version=None, app_cloudlet_name=None, app_cloudlet_org=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, json_data=None, auto_delete=True, use_defaults=True, use_thread=False):
        msg = self._build(receiver_name=receiver_name, type=type, severity=severity, email_address=email_address, slack_channel=slack_channel, slack_api_url=slack_api_url, app_name=app_name, app_version=app_version, app_cloudlet_name=app_cloudlet_name, app_cloudlet_org=app_cloudlet_org, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, developer_org_name=developer_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, use_defaults=use_defaults)
        msg_dict = msg

        msg_dict_delete = None
        if auto_delete and 'name' in msg:
            #msg_delete = self._build(receiver_name=msg['name'], type=msg['type'], use_defaults=False)
            msg_delete = self._build(receiver_name=receiver_name, type=type, severity=severity, app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, developer_org_name=developer_org_name, use_defaults=use_defaults)
            msg_dict_delete = msg_delete

        msg_dict_show = None
        if 'name' in msg and 'type' in msg and 'severity' in msg:
            msg_show = self._build(receiver_name=msg['name'], type=msg['type'], severity=msg['severity'], use_defaults=False)
            msg_dict_show = msg_show
 
        return self.create(token=token, url=self.create_url, delete_url=self.delete_url, show_url=self.show_url, region=None, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, create_msg=msg_dict, delete_msg=msg_dict_delete, show_msg=msg_dict_show)[0]

    def delete_alert_receiver(self, token=None, region=None, receiver_name=None,  type=None, severity=None, json_data=None, auto_delete=True, use_defaults=True, use_thread=False):
        msg = self._build(receiver_name=receiver_name, type=type, severity=severity, use_defaults=use_defaults)
        msg_dict = msg

        return self.delete(token=token, url=self.delete_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def show_alert_receiver(self, token=None, region=None, receiver_name=None, type=None, severity=None, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, json_data=None, auto_delete=True, use_defaults=True, use_thread=False):
        msg = self._build(receiver_name=receiver_name, type=type, severity=severity, app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, developer_org_name=developer_org_name, use_defaults=use_defaults)
        msg_dict = msg

        return self.show(token=token, url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def verify_slack(self, alert_type, alert_name, status=None, region=None, app_name=None, app_version=None, developer_org_name=None, cloudlet_name=None, operator_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, wait=30):
        now = time.time() - 30

        client = WebClient(token=self.slack_token)

        def check_payload(text):
            if text in response['messages'][0]['attachments'][0]['text']:
                logging.info(f'{text} found in alert slack message')
            else:
                raise Exception(f'{text} not found in alert slack message')

        for attempt in range(wait):
            logging.debug(f'checking slack attempt {attempt}/{wait}')
            #response = client.conversations_history(channel=self.slack_channel, oldest=now)
            response = client.conversations_history(channel=self.slack_channel, limit=1)

            if len(response['messages']) > 0:
               subject = response['messages'][0]['attachments'][0]['fallback']
               if alert_type in subject and f'{alert_name} Application: {app_name} Version: {app_version}' in subject: 
                   logging.info('new slack message found')
                   logging.debug(f'slack message found:{response}')

                   if alert_name: check_payload(f'*alertname:* {alert_name}')
                   if app_name: check_payload(f'*app:* {app_name}')
                   if app_version: check_payload(f'*appver:* {app_version}')
                   if developer_org_name: check_payload(f'*apporg:* {developer_org_name}')
                   if cloudlet_name: check_payload(f'*cloudlet:* {cloudlet_name}')
                   if operator_org_name: check_payload(f'*cloudletorg:* {operator_org_name}')
                   if cluster_instance_name: check_payload(f'*cluster:* {cluster_instance_name}')
                   if cluster_instance_developer_org_name: check_payload(f'*clusterorg:* {cluster_instance_developer_org_name}')
                   if region: check_payload(f'*region:* {region}')
                   if status: check_payload(f'*status:* {status}')
                   if alert_type == 'RESOLVED':
                       if response['messages'][0]['attachments'][0]['color'] == '2eb886':
                           logging.info(f'color 2eb886 found in resolved alert slack message')
                       else:
                           raise Exception(f'color 2eb886 not found in resolved alert slack message')
                   elif alert_type == 'FIRING':
                       if response['messages'][0]['attachments'][0]['color'] == 'a30200':
                           logging.info(f'color a30200 found in firing alert slack message')
                       else:
                           raise Exception(f'color a30200 not found in firing alert slack message')

                   return True 
               else:
                   logging.debug('slack message found but doenst match yet. sleeping')
                   time.sleep(1)
            else:
                logging.debug('no slack message not found yet. sleeping')
                time.sleep(1)

        raise Exception('slack message not found')

    def verify_email(self, email_address, email_password, alert_type, alert_receiver_name, alert_name, status=None, region=None, app_name=None, app_version=None, developer_org_name=None, cloudlet_name=None, operator_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, server='imap.gmail.com', wait=30):
        mail = imaplib.IMAP4_SSL(server)
        mail.login(email_address, email_password)
        mail.select('inbox')
        logger.debug(f'successfully logged into {email_address}')

        emailstatus, email_list = mail.search(None, f'(SUBJECT "{alert_name}")')
        mail_ids_pre = email_list[0].split()
        num_emails_pre = len(mail_ids_pre)
        logger.debug(f'originally found {num_emails_pre} with {alert_name}')
        #num_emails_pre=0
        
        for attempt in range(wait):
            mail.recent()
            emailstatus, email_list = mail.search(None, f'(SUBJECT "{alert_name}")')
            mail_ids = email_list[0].split()
            num_emails = len(mail_ids)
            logging.info(f'number of emails found is {num_emails}')
            if num_emails > num_emails_pre:
                logging.info('new email found')
                mail_id = email_list[0].split()
                typ, data = mail.fetch(mail_id[-1], '(RFC822)')
                for response_part in data:
                    if isinstance(response_part, tuple):
                        msg = email.message_from_string(response_part[1].decode('utf-8'))
                        email_subject = msg['subject'].replace('\r\n','')
                        email_from = msg['from']
                        date_received = msg['date']
                        logger.debug(f'subject={email_subject}')
 
                        #if email_subject == f'[{alert_type}:1] {alert_name} Application: {app_name} Version: {app_version}':
                        subject_to_check = f'Alert for {alert_receiver_name}: {alert_name} Application: {app_name} Version: {app_version}'
                        if alert_type in email_subject and subject_to_check in email_subject:
                            logger.info(f'subject{email_subject}  verified')
                        else:
                            raise Exception(f'subject not found. Expected:alert_type={alert_type} subject={subject_to_check}. Got {email_subject}')
 
                        if msg.is_multipart():
                            for part in msg.walk():
                                ctype = part.get_content_type()
                                logger.debug(f'type={ctype}')
                                if ctype == 'text/html':  # found html part of the message
                                    payload = part.get_payload(decode=True).decode('utf-8')
                                    logger.debug(f'payload={payload}')

                        def check_payload(text):
                            if text in payload:
                                logging.info(f'{text} found in alert email')
                            else:
                                raise Exception(f'{text} not found in alert email')

                        if alert_name: check_payload(f'alertname = {alert_name}')
                        if app_name: check_payload(f'app = {app_name}')
                        if app_version: check_payload(f'appver = {app_version}')
                        if developer_org_name: check_payload(f'apporg = {developer_org_name}')
                        if cloudlet_name: check_payload(f'cloudlet = {cloudlet_name}')
                        if operator_org_name: check_payload(f'cloudletorg = {operator_org_name}')
                        if cluster_instance_name: check_payload(f'cluster = {cluster_instance_name}')
                        if cluster_instance_developer_org_name: check_payload(f'clusterorg = {cluster_instance_developer_org_name}')
                        if region: check_payload(f'region = {region}')
                        if status: check_payload(f'status = {status}')

                        return True
            time.sleep(1)

        raise Exception('email not found')

