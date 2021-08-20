import logging
import re
import email
import imaplib
import time
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

    def _build(self, reporter_name=None, organization=None, email_address=None, schedule=None, start_schedule_date=None, timezone=None,  use_defaults=True):

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

        if email_address is not None:
            reporter_dict['Email'] = email_address

        if schedule is not None:
            if schedule == 'EveryWeek':
                value = 0
            elif schedule == 'Every15Days':
                value = 1
            elif schedule == 'EveryMonth':
                value = 3
            else:
                value = 4
            reporter_dict['Schedule'] = int(value)

        if start_schedule_date is not None:
            reporter_dict['StartScheduleDate'] = start_schedule_date           

        if timezone is not None:
            reporter_dict['Timezone'] = timezone

        return reporter_dict

    def create_reporter(self, token=None, reporter_name=None, organization=None, email_address=None, schedule=None, start_schedule_date=None, timezone=None, use_defaults=True, use_thread=False, auto_delete=True, json_data=None, stream=False, stream_timeout=100):
        msg = self._build(reporter_name=reporter_name, organization=organization, email_address=email_address, schedule=schedule, start_schedule_date=start_schedule_date, timezone=timezone, use_defaults=use_defaults)
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

    def update_reporter(self, token=None, reporter_name=None, organization=None, email_address=None, schedule=None, start_schedule_date=None, timezone=None, use_defaults=True, use_thread=False, json_data=None):
        msg = self._build(reporter_name=reporter_name, organization=organization, email_address=email_address, schedule=schedule, start_schedule_date=start_schedule_date, timezone=timezone, use_defaults=use_defaults)
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

    def verify_email(self, email_address=None, email_password=None, reporter_name=None, report_period=None, timezone=None, username=None, organization=None, server='imap.gmail.com', wait=30):
        rp = report_period.split('to')
        start_period = rp[0].strip()
        end_period = rp[1].strip()
        start_period = start_period.replace('/', '')
        end_period = end_period.replace('/', '')
        expected_filename = f'{organization}_{reporter_name}_{start_period}_{end_period}.pdf'
        logger.debug(f'expected filename is {expected_filename}')


        mail = imaplib.IMAP4_SSL(server)
        mail.login(email_address, email_password)
        mail.select('inbox')
        logger.debug(f'successfully logged into {email_address}')

        email_heading_search = f'(SUBJECT "[{reporter_name}]")'

        emailstatus, email_list = mail.search(None, email_heading_search)
        mail_ids_pre = email_list[0].split()
        num_emails_pre = len(mail_ids_pre)
        logger.debug(f'originally found {num_emails_pre} with {email_heading_search}')
        num_emails_pre = 0

        for attempt in range(wait):
            mail.recent()
            emailstatus, email_list = mail.search(None, email_heading_search)
            mail_ids = email_list[0].split()
            num_emails = len(mail_ids)
            logger.info(f'number of emails found is {num_emails}')
            if num_emails > num_emails_pre:
                def check_payload(text):
                    if text in payload:
                        logger.info(f'{text} found in alert email')
                    else:
                        raise Exception(f'{text} not found in alert email')
                num_new_emails = num_emails - num_emails_pre
                logging.info(f'found {num_new_emails} new emails')
                for newemail in email_list:
                    mail_id = newemail.split()
                    logger.info(f'checking new email with id={mail_id}')

                    for i in mail_id:
                        typ, data = mail.fetch(i.decode('utf-8'), '(RFC822)')
                        for response_part in data:
                            if isinstance(response_part, tuple):
                                msg = email.message_from_string(response_part[1].decode('utf-8'))
                                email_subject = msg['subject'].replace('\r\n', '')
                                logger.debug(f'subject={email_subject}')

                                subject_to_check = f'[{reporter_name}] Cloudlet Usage Report for {organization} for the period {report_period} (Timezone: {timezone})'
                                if subject_to_check in email_subject:
                                    logger.info(f'subject{email_subject}  verified')
                                else:
                                    logger.info(f'subject not found. Expected: subject={subject_to_check}. Got {email_subject}')
                                    continue

                                if msg.is_multipart():
                                    for part in msg.walk():
                                        ctype = part.get_content_type()
                                        logger.debug(f'type={ctype}')
                                        content_disposition = str(part.get("Content-Disposition"))
                                        logger.debug(f'Content={content_disposition}')
                                        if ctype == 'text/plain':
                                            payload = part.get_payload(decode=True).decode('utf-8')
                                            logger.debug(f'payload={payload}')
                                        if 'attachment' in content_disposition:
                                            filename = part.get_filename()
                                            logger.debug(f'Attached file={filename}')
                                if f'Hi {username},' in payload:
                                    logging.info('greetings found')
                                else:
                                    raise Exception('Greetings not found')
                                if f'Please find the attached report generated for cloudlets part of {organization} organization for the period {report_period}' in payload:
                                    logging.info('body1 found')
                                else:
                                    raise Exception('Body1 not found')
                                if filename == expected_filename:
                                    logging.info('Found attachment')
                                else:
                                    raise Exception('Attachment NOT found')

                                return True
            time.sleep(1)

        raise Exception('email not found')

