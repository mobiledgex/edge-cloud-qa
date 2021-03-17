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

    def _build(self, region=None, receiver_name=None, type=None, severity=None, email_address=None, user=None, pagerduty_integration_key=None, slack_channel=None, slack_api_url=None, app_name=None, app_version=None, app_cloudlet_name=None, app_cloudlet_org=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, use_defaults=True):

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

        if region is not None:
            receiver_dict['region'] = region
 
        if receiver_name is not None:
            receiver_dict['name'] = receiver_name
        if type is not None:
            receiver_dict['type'] = type
        if severity is not None:
            receiver_dict['severity'] = severity
        if user is not None:
            receiver_dict['user'] = user 

        if pagerduty_integration_key is not None:
            receiver_dict['pagerdutyintegrationkey'] = pagerduty_integration_key

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

    def create_alert_receiver(self, token=None, region=None, receiver_name=None, type=None, severity=None, email_address=None, pagerduty_integration_key=None, slack_channel=None, slack_api_url=None, app_name=None, app_version=None, app_cloudlet_name=None, app_cloudlet_org=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, json_data=None, auto_delete=True, use_defaults=True, use_thread=False):
        msg = self._build(region=region, receiver_name=receiver_name, type=type, severity=severity, email_address=email_address, pagerduty_integration_key=pagerduty_integration_key, slack_channel=slack_channel, slack_api_url=slack_api_url, app_name=app_name, app_version=app_version, app_cloudlet_name=app_cloudlet_name, app_cloudlet_org=app_cloudlet_org, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, developer_org_name=developer_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, use_defaults=use_defaults)
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

    def delete_alert_receiver(self, token=None, region=None, receiver_name=None,  type=None, severity=None, user=None, developer_org_name=None, json_data=None, auto_delete=True, use_defaults=True, use_thread=False):
        msg = self._build(receiver_name=receiver_name, type=type, severity=severity, user=user, developer_org_name=developer_org_name, use_defaults=use_defaults)
        msg_dict = msg

        return self.delete(token=token, url=self.delete_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def show_alert_receiver(self, token=None, region=None, receiver_name=None, type=None, severity=None, app_name=None, app_version=None, cloudlet_name=None, operator_org_name=None, developer_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, user=None, json_data=None, auto_delete=True, use_defaults=True, use_thread=False):
        msg = self._build(receiver_name=receiver_name, type=type, severity=severity, app_name=app_name, app_version=app_version, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, developer_org_name=developer_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, user=user, use_defaults=use_defaults)
        msg_dict = msg

        return self.show(token=token, url=self.show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def verify_slack(self, alert_type, alert_receiver_name, alert_name, status=None, region=None, app_name=None, app_version=None, developer_org_name=None, cloudlet_name=None, operator_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, port=None, scope=None, description=None, title=None, wait=30, num_messages_to_check=3):
        now = time.time() - 30

        client = WebClient(token=self.slack_token)

        def check_payload(msg, text):
            if text in msg['attachments'][0]['text']:
                logger.info(f'{text} found in alert slack message')
            else:
                raise Exception(f'{text} not found in alert slack message')

        for attempt in range(wait):
            logger.debug(f'checking slack attempt {attempt}/{wait}')
            #response = client.conversations_history(channel=self.slack_channel, oldest=now)
            try:
                response = client.conversations_history(channel=self.slack_channel, limit=num_messages_to_check)
            except Exception as e:
                logger.info(f'slack error caught:{e}')

            if len(response['messages']) > 0:
               logger.info(f"checking {len(response['messages'])} messages")
               for slack_msg in response['messages']:
                   if scope == 'Cloudlet':
                       subject_to_check = f'Alert for {alert_receiver_name}: {alert_name} Cloudlet: {cloudlet_name}'
                   else:
                       subject_to_check = f'Alert for {alert_receiver_name}: {alert_name} Application: {app_name} Version: {app_version}'
                   logger.info(f'checking message for alert_type={alert_type} subject={subject_to_check}') 
                   #subject = response['messages'][0]['attachments'][0]['fallback']
                   subject = slack_msg['attachments'][0]['title']
                   logger.info(f'message to check: {subject}')

                   if alert_type in subject and subject_to_check in subject: 
                       logger.info('new slack message found')
                       logger.debug(f'slack message found:{response}')

                       try:
                           if alert_name: check_payload(slack_msg, f'*alertname:* {alert_name}')
                           if app_name: check_payload(slack_msg, f'*app:* {app_name}')
                           if app_version: check_payload(slack_msg, f'*appver:* {app_version}')
                           if developer_org_name: check_payload(slack_msg, f'*apporg:* {developer_org_name}')
                           if cloudlet_name: check_payload(slack_msg, f'*cloudlet:* {cloudlet_name}')
                           if operator_org_name: check_payload(slack_msg, f'*cloudletorg:* {operator_org_name}')
                           if cluster_instance_name: check_payload(slack_msg, f'*cluster:* {cluster_instance_name}')
                           if cluster_instance_developer_org_name: check_payload(slack_msg, f'*clusterorg:* {cluster_instance_developer_org_name}')
                           if region: check_payload(slack_msg, f'*region:* {region}')
                           if status: check_payload(slack_msg, f'*status:* {status}')
                           if scope: check_payload(slack_msg, f'*scope:* {scope}')
                           if port: check_payload(slack_msg, f'*port:* {port}')
                           if description: check_payload(slack_msg, f'*Description:* {description}')
                           if title: check_payload(slack_msg, f'*Alert:* {title}')
                           #check_payload(slack_msg, '*job:* MobiledgeX Monitoring')
                           if 'job:' in slack_msg['attachments'][0]['text']:
                               raise Exception(f'job found in alert slack message')

                       except Exception as e:
                           logger.info(f'check payload failed:{e}')
                           continue

                       if alert_type == 'RESOLVED':
                           if slack_msg['attachments'][0]['color'] == '2eb886':
                               logger.info(f'color 2eb886 found in resolved alert slack message')
                           else:
                               raise Exception(f'color 2eb886 not found in resolved alert slack message')
                       elif alert_type == 'FIRING':
                           if slack_msg['attachments'][0]['color'] == 'a30200':
                               logger.info(f'color a30200 found in firing alert slack message')
                           else:
                               raise Exception(f'color a30200 not found in firing alert slack message')

                       return True 
                   else:
                       logger.debug('slack message found but doenst match yet. sleeping')
                       time.sleep(1)
            else:
                logger.debug('no slack message not found yet. sleeping')
                time.sleep(1)

        raise Exception('slack message not found')

    def verify_email(self, email_address, email_password, alert_type, alert_receiver_name, alert_name, status=None, region=None, app_name=None, app_version=None, developer_org_name=None, cloudlet_name=None, operator_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, port=None, scope=None, description=None, title=None, server='imap.gmail.com', wait=30):
        mail = imaplib.IMAP4_SSL(server)
        mail.login(email_address, email_password)
        mail.select('inbox')
        logger.debug(f'successfully logged into {email_address}')

        emailstatus, email_list = mail.search(None, f'(SUBJECT "{alert_receiver_name}")')
        mail_ids_pre = email_list[0].split()
        num_emails_pre = len(mail_ids_pre)
        logger.debug(f'originally found {num_emails_pre} with {alert_receiver_name}')
        #num_emails_pre=0
        
        for attempt in range(wait):
            mail.recent()
            emailstatus, email_list = mail.search(None, f'(SUBJECT "{alert_receiver_name}")')
            #print('*WARN*', 'email_list', email_list)
            mail_ids = email_list[0].split()
            #print('*WARN*', 'mail_ids', mail_ids)
            num_emails = len(mail_ids)
            logger.info(f'number of emails found is {num_emails}')
            if num_emails > num_emails_pre:
                def check_payload(text):
                    if text in payload:
                        logger.info(f'{text} found in alert email')
                    else:
                        raise Exception(f'{text} not found in alert email')

                for newemail in email_list:
                    mail_id = newemail.split()
                    logger.info(f'checking new email with id={mail_id}')

                    typ, data = mail.fetch(mail_id[-1], '(RFC822)')
                    for response_part in data:
                        print('*WARN*', 'response_part', response_part)
                        if isinstance(response_part, tuple):
                            msg = email.message_from_string(response_part[1].decode('utf-8'))
                            email_subject = msg['subject'].replace('\r\n','')
                            email_from = msg['from']
                            date_received = msg['date']
                            logger.debug(f'subject={email_subject} scope={scope}')
 
                            #if email_subject == f'[{alert_type}:1] {alert_name} Application: {app_name} Version: {app_version}':
                            if scope == 'Cloudlet':
                                if 'PagerDuty' in email_subject:
                                    logger.debug(f'pagerduty')
                                    subject_to_check = f'TRIGGERED Incidents'
                                else:
                                    subject_to_check = f'Alert for {alert_receiver_name}: {alert_name} Cloudlet: {cloudlet_name}'
                            else:
                                print('*WARN*', email_subject)
                                if 'PagerDuty' in email_subject:
                                    logger.debug(f'pagerduty')
                                    subject_to_check = f'TRIGGERED Incidents'
                                else:
                                    logger.debug(f'not pagerduty')
                                    subject_to_check = f'Alert for {alert_receiver_name}: {alert_name} Application: {app_name} Version: {app_version}'
                            if alert_type in email_subject and subject_to_check in email_subject:
                                logger.info(f'subject{email_subject}  verified')
                            else:
                                #raise Exception(f'subject not found. Expected:alert_type={alert_type} subject={subject_to_check}. Got {email_subject}')
                                logger.info(f'subject not found. Expected: subject={subject_to_check}. Got {email_subject}')
                                continue 
 
                            if msg.is_multipart():
                                for part in msg.walk():
                                    ctype = part.get_content_type()
                                    logger.debug(f'type={ctype}')
                                    if ctype == 'text/html':  # found html part of the message
                                        payload = part.get_payload(decode=True).decode('utf-8')
                                        logger.debug(f'payload={payload}')
                            try:    
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
                                if port: check_payload(f'port = {port}')
                                if scope: check_payload(f'scope = {scope}')
                                if description: check_payload(f'description = {description}')
                                if title: check_payload(f'title = {title}')
                                #check_payload('job = MobiledgeX Monitoring')

                                if 'job =' in payload:
                                    raise Exception(f'job found in alert email')

                            except Exception as e:
                                logger.info(f'check payload failed:{e}')
                                continue

                            return True
            time.sleep(1)

        raise Exception('email not found')

