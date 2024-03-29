# Copyright 2022 MobiledgeX, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import logging
import imaplib
import time
import email
import subprocess
import shlex
import json
import shared_variables_mc

from mex_master_controller.MexOperation import MexOperation

logger = logging.getLogger(__name__)


class User(MexOperation):
    def __init__(self, root_url, prov_stack=None, token=None, super_token=None, thread_queue=None):
        super().__init__(root_url=root_url, prov_stack=prov_stack, token=token, super_token=super_token, thread_queue=thread_queue)

        self.create_url = '/usercreate'
        self.delete_url = '/auth/user/delete'
        self.show_url = '/auth/user/show'
        self.current_url = '/auth/user/current'
        self.update_url = '/auth/user/update'
        self.update_restricted_url = '/auth/restricted/user/update'
        self.create_apikey_url = '/auth/user/create/apikey'
        self.delete_apikey_url = '/auth/user/delete/apikey'
        self.show_apikey_url = '/auth/user/show/apikey'
        self.reset_password_url = '/passwordresetrequest'

    def _build(self, username=None, password=None, email_address=None, metadata=None, locked=None, family_name=None, given_name=None, nickname=None, enable_totp=None, email_verified=None, role=None, organization=None, description=None, permission_list=[], apikey_id=None, callback_url=None, use_defaults=True):
        if username == 'default':
            username = shared_variables_mc.username_default

        if use_defaults:
            if username is None:
                username = shared_variables_mc.username_default
            if password is None:
                password = shared_variables_mc.password_default
            if email_address is None:
                email_address = username + '@email.com'

        # shared_variables_mc.username_default = username
        # shared_variables_mc.password_default = password

        user_dict = {}
        verify_dict = {}

        if username is not None:
            user_dict['name'] = username
            shared_variables_mc.username_default = username
        if password is not None:
            user_dict['passhash'] = password
            shared_variables_mc.password_default = password
        if email_address is not None:
            user_dict['email'] = email_address
        if metadata is not None:
            user_dict['metadata'] = metadata
        if locked is not None:
            user_dict['locked'] = locked
        if family_name is not None:
            user_dict['familyname'] = family_name
        if given_name is not None:
            user_dict['givenname'] = given_name
        if nickname is not None:
            user_dict['nickname'] = nickname
        if enable_totp is not None:
            user_dict['enableTOTP'] = enable_totp
        if email_verified is not None:
            user_dict['EmailVerified'] = email_verified
        if role is not None:
            user_dict['role'] = role
        if organization is not None:
            user_dict['org'] = organization
        if description is not None:
            user_dict['description'] = description
        if apikey_id is not None:
            user_dict['Id'] = apikey_id
        if callback_url is not None:
            verify_dict['callbackurl'] = callback_url

        if len(permission_list) > 0:
            perm_dict_list = []
            for x, y in zip(permission_list[::2], permission_list[1::2]):
                perm_dict = {}
                perm_dict['action'] = x
                perm_dict['resource'] = y
                perm_dict_list.append(perm_dict)
            user_dict['permissions'] = perm_dict_list

        if verify_dict:
            user_dict['verify'] = verify_dict

        return user_dict

    def _build_reset(self, email_address=None, callback_url=None, use_defaults=True):
        user_dict = {}

        if email_address is not None:
            user_dict['email'] = email_address
        if callback_url is not None:
            user_dict['callbackurl'] = callback_url

        return user_dict

    def _build_update_restricted(self, username=None, email_address=None, email_verified=None, family_name=None, given_name=None, nickname=None, locked=None, enable_totp=None, failed_logins=None, use_defaults=True):
        if username == 'default':
            username = shared_variables_mc.username_default

        if use_defaults:
            if username is None:
                username = shared_variables_mc.username_default

        shared_variables_mc.username_default = username

        user_dict = {}

        if username is not None:
            user_dict['name'] = username
        if locked is not None:
            user_dict['locked'] = locked
        if email_address is not None:
            user_dict['email'] = email_address
        if family_name is not None:
            user_dict['familyname'] = family_name
        if given_name is not None:
            user_dict['givenname'] = given_name
        if nickname is not None:
            user_dict['nickname'] = nickname
        if email_verified is not None:
            user_dict['emailverified'] = email_verified
        if enable_totp is not None:
            user_dict['enabletotp'] = enable_totp
        if failed_logins is not None:
            user_dict['failedlogins'] = failed_logins

        return user_dict

    def create_user(self, username=None, password=None, email_address=None, family_name=None, given_name=None, nickname=None, email_password=None, enable_totp=None, server='imap.gmail.com', callback_url=None, email_check=False, json_data=None, use_defaults=True, use_thread=False, auto_delete=True, auto_show=True):
        if not email_password:
            email_password = password

        msg = self._build(username=username, password=password, email_address=email_address, family_name=family_name, given_name=given_name, nickname=nickname, enable_totp=enable_totp, callback_url=callback_url, use_defaults=use_defaults)
        msg_dict = msg

        msg_dict_show = None
        if auto_show and username:
            msg_show = self._build(username=username, use_defaults=False)
            msg_dict_show = msg_show

        msg_dict_delete = None
        if auto_delete and username:
            msg_delete = self._build(username=username, use_defaults=False)
            msg_dict_delete = msg_delete

        thread_name = 'create_user'
        if username:
            thread_name += username

        if email_check:
            logger.info(f'checking email with email={email_address} password={email_password}')
            mail = imaplib.IMAP4_SSL(server)
            mail.login(email_address, email_password)
            mail.select('inbox')
            self._mail = mail
            logger.info('login successful')

            status, email_list_pre = mail.search(None, '(SUBJECT "Welcome to MobiledgeX!")')
            mail_ids_pre = email_list_pre[0].split()
            num_emails_pre = len(mail_ids_pre)
            self._mail_count = num_emails_pre
            logger.info(f'number of emails pre is {num_emails_pre}')

        return self.create(token=None, url=self.create_url, delete_url=self.delete_url, show_url=self.show_url, region=None, json_data=json_data, use_defaults=False, use_thread=use_thread, create_msg=msg_dict, delete_msg=msg_dict_delete, show_msg=msg_dict_show, thread_name=thread_name, stream=None, stream_timeout=None)

    def show_user(self, token=None, username=None, email_address=None, given_name=None, family_name=None, nickname=None, role=None, organization=None, locked=None, enable_totp=None, email_verified=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(username=username, email_address=email_address, given_name=given_name, family_name=family_name, nickname=nickname, role=role, organization=organization, locked=locked, enable_totp=enable_totp, email_verified=email_verified, use_defaults=use_defaults)
        msg_dict = msg

        return self.show(token=token, url=self.show_url, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def reset_password(self, email_address=None, email_password=None, callback_url=None, email_check=False, server='imap.gmail.com', json_data=None, use_defaults=True, use_thread=False, auto_show=True):
        msg = self._build_reset(email_address=email_address, callback_url=callback_url, use_defaults=use_defaults)
        msg_dict = msg

        msg_dict_show = None
        if auto_show and email_address:
            msg_show = self._build(email_address=email_address, use_defaults=False)
            msg_dict_show = msg_show

        if email_check:
            logger.info(f'checking email with email={email_address} password={email_password}')
            mail = imaplib.IMAP4_SSL(server)
            mail.login(email_address, email_password)
            mail.select('inbox')
            self._mail = mail
            logger.info('login successful')

            status, email_list_pre = mail.search(None, '(SUBJECT "Password Reset Request")')
            mail_ids_pre = email_list_pre[0].split()
            num_emails_pre = len(mail_ids_pre)
            self._mail_count = num_emails_pre
            logger.info(f'number of emails pre is {num_emails_pre}')

        return self.create(token=None, url=self.reset_password_url, show_url=self.show_url, region=None, json_data=json_data, use_defaults=False, use_thread=use_thread, create_msg=msg_dict, show_msg=msg_dict_show, stream=None, stream_timeout=None)

    def current_user(self, token=None, json_data=None, use_defaults=True, use_thread=False):
        return self.show(token=token, url=self.current_url, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=None)[0]

    def update_user(self, token=None, username=None, email_address=None, family_name=None, given_name=None, nickname=None, enable_totp=None, metadata=None, json_data=None, use_defaults=False, use_thread=False):
        msg = self._build(username=username, email_address=email_address, family_name=family_name, given_name=given_name, nickname=nickname, enable_totp=enable_totp, metadata=metadata, use_defaults=use_defaults)
        msg_dict = msg

        return self.update(token=token, url=self.update_url, show_url=self.show_url, region=None, json_data=json_data, use_defaults=True, use_thread=use_thread, message=msg_dict, show_msg=None)

    def update_user_restricted(self, token=None, username=None, email_address=None, email_verified=None, family_name=None, given_name=None, nickname=None, locked=None, enable_totp=None, failed_logins=None, json_data=None, use_defaults=False, use_thread=False):
        msg = self._build_update_restricted(username=username, email_address=email_address, email_verified=email_verified, family_name=family_name, given_name=given_name, nickname=nickname, locked=locked, enable_totp=enable_totp, failed_logins=failed_logins, use_defaults=use_defaults)
        msg_dict = msg

        thread_name = 'update_user_restricted'
        if username:
            thread_name += username

        msg_show_dict = None
        return self.update(token=token, url=self.update_restricted_url, show_url=self.show_url, region=None, json_data=json_data, use_defaults=True, use_thread=use_thread, thread_name=thread_name, message=msg_dict, show_msg=msg_show_dict)

    def delete_user(self, token=None, username=None, json_data=None, use_defaults=False, use_thread=False):
        msg = self._build(username=username, use_defaults=use_defaults)
        msg_dict = msg
        return self.delete(token=token, url=self.delete_url, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def create_user_api_key(self, organization=None, description=None, permission_list=[], token=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(organization=organization, description=description, permission_list=permission_list, use_defaults=use_defaults)
        msg_dict = msg
        return self.create(token=token, url=self.create_apikey_url, json_data=json_data, use_defaults=False, use_thread=use_thread, create_msg=msg_dict)

    def delete_user_api_key(self, apikey_id=None, token=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(apikey_id=apikey_id, use_defaults=use_defaults)
        msg_dict = msg
        return self.delete(token=token, url=self.delete_apikey_url, json_data=json_data, use_defaults=False, use_thread=use_thread, message=msg_dict)

    def show_user_api_key(self, apikey_id=None, token=None, json_data=None, use_defaults=True, use_thread=False):
        msg = self._build(apikey_id=apikey_id, use_defaults=use_defaults)
        msg_dict = msg
        return self.show(token=token, url=self.show_apikey_url, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def verify_email(self, email_type='newuser', subject='Welcome to MobiledgeX!', username=None, password=None, email_address=None, server='imap.gmail.com', wait=30, mc_address=None):
        if username is None:
            username = self.username
        if password is None:
            password = self.password
        if email_address is None:
            email_address = self.email_address

        if email_type == 'newuser':
            subject = 'Welcome to MobiledgeX!'
            body_to_check = 'Thanks for creating a MobiledgeX account! You are now one step away from utilizing the power of the edge. Please verify this email account by clicking on the link below. Then you\'ll be able to login and get started.'
            link_to_check = f'Click to verify: https://{shared_variables_mc.console_url}/#/verify?token='
            footer1_to_check = f'For security, this request was received for {email_address} from'
            footer2_to_check = 'If you are not expecting this email, please ignore this email or contact MobiledgeX support for assistance.'
        elif email_type == 'passwordreset':
            subject = 'Password Reset Request'
            body_to_check = 'You recently requested to reset your password for your MobiledgeX account. Use the link below to reset it. This password reset is only valid for the next 1 hour.'
            link_to_check = 'Reset your password: https://console-qa.mobiledgex.net/#/passwordreset?token='
            footer1_to_check = 'For security, this request was received from'
            footer2_to_check = 'If you did not request this password reset, please ignore this email or contact MobiledgeX support for assistance.'
        else:
            raise Exception(f'invalid email_type={email_type}')

        self.mc_address = mc_address
        mail = self._mail
        num_emails_pre = self._mail_count
        logging.info(f'verifying email for email={email_address} username={username} password={password}')

        for attempt in range(wait):
            mail.recent()
            logging.info(f'looking for email with SUBJECT "{subject}"')
            status, email_list = mail.search(None, f'(SUBJECT "{subject}")')
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
                        # email_subject = msg['subject']
                        # email_from = msg['from']
                        # date_received = msg['date']
                        payload = msg.get_payload(decode=True).decode('utf-8')
                        logging.info(payload)

                        if f'Hi {username},' in payload:
                            logging.info('greetings found')
                        else:
                            raise Exception('Greetings not found')

                        if body_to_check in payload:
                            logging.info('body1 found')
                        else:
                            raise Exception('Body1 not found')

                        logging.info(f'checking email for {link_to_check}')
                        if link_to_check in payload:
                            logging.info('verify link found')
                            for line in payload.split('\n'):
                                logging.info(f'sdfdsff {link_to_check}')
                                if link_to_check in line:
                                    linksplit = line.split(': ')
                                    url_split = linksplit[1].rstrip().replace('#/verify', 'api/v1/verifyemail').split('?')
                                    token_split = url_split[1].split('=')
                                    token_dict = {'token': f'{token_split[1]}'}
                                    logging.info(f'clicking link={url_split[0]}')
                                    self.post(url_split[0], data=json.dumps(token_dict))
                                    if 'message' in self.decoded_data and self.decoded_data['message'] == 'Email verified, thank you':
                                        logging.info('email successfuly verified')
                                    else:
                                        raise Exception(f'email verify failed link={url_split[0]} Got {self.decoded_data}')
                                    break
                        else:
                            raise Exception('Verify link not found')

                        if footer1_to_check in payload and footer2_to_check in payload and 'Thanks!' in payload and 'MobiledgeX Team' in payload:
                            logging.info('body2 link found')
                        else:
                            raise Exception('Body2 not found')
                        return payload
            time.sleep(1)

        raise Exception('verification email not found')

    def _run_command(self, cmd):
        try:
            process = subprocess.Popen(shlex.split(cmd),
                                       stdout=subprocess.PIPE,
                                       stderr=subprocess.PIPE,
                                       )
            stdout, stderr = process.communicate()
            logging.info(f'stdout:{stdout} stderr:{stderr}')
            # print('*WARN*',stdout, stderr)
            if stderr:
                raise Exception('runCommandee failed:' + stderr.decode('utf-8'))

            return stdout
        except subprocess.CalledProcessError as e:
            raise Exception("runCommanddd failed:", e)
        except Exception as e:
            raise Exception("runCommanddd failed:", e)
