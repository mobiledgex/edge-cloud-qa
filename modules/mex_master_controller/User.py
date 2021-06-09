import json
import logging
import imaplib
import time
import email
import subprocess
import shlex
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

    def _build(self, username=None, password=None, email_address=None, metadata=None, locked=None, family_name=None, given_name=None, nickname=None, enable_totp=None, email_verified=None, role=None, organization=None, use_defaults=True):
        if username == 'default':
            username = shared_variables_mc.username_default
            
        if use_defaults:
            if username is None: username = shared_variables_mc.username_default
            if password is None: password = shared_variables_mc.password_default
            if email_address is None: email_address = username + '@email.com'

        shared_variables_mc.username_default = username
        shared_variables_mc.password_default = password

        user_dict = {}

        if username is not None:
            user_dict['name'] = username
        if password is not None:
            user_dict['passhash'] = password
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

        return user_dict

    def _build_update_restricted(self, username=None, locked=None, use_defaults=True):
        #pool = None

        if username == 'default':
            username = shared_variables_mc.username_default

        if use_defaults:
            if username is None: username = shared_variables_mc.username_default

        shared_variables_mc.username_default = username

        user_dict = {}

        if username is not None:
            user_dict['name'] = username
        if locked is not None:
            user_dict['locked'] = locked

        return user_dict

    def create_user(self, username=None, password=None, email_address=None, family_name=None, given_name=None, nickname=None, email_password=None, enable_totp=None, server='imap.gmail.com', email_check=False, json_data=None, use_defaults=True, use_thread=False, auto_delete=True):
        if not email_password:
            email_password = password

        msg = self._build(username=username, password=password, email_address=email_address, family_name=family_name, given_name=given_name, nickname=nickname, enable_totp=enable_totp, use_defaults=use_defaults)
        msg_dict = msg

        msg_dict_show = None
        if username:
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
            logger.info(f'checking email with email={email_address} password={password}')
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

    def current_user(self, token=None, json_data=None, use_defaults=True, use_thread=False):
        return self.show(token=token, url=self.current_url, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=None)[0]

    def update_user(self, token=None, metadata=None, json_data=None, use_defaults=False, use_thread=False):
        msg = self._build(metadata=metadata, use_defaults=use_defaults)
        msg_dict = msg

        return self.update(token=token, url=self.update_url, show_url=self.show_url, region=None, json_data=json_data, use_defaults=True, use_thread=use_thread, message=msg_dict, show_msg=None)

    def update_user_restricted(self, token=None, username=None, locked=None, json_data=None, use_defaults=False, use_thread=False):
        msg = self._build_update_restricted(username=username, locked=locked, use_defaults=use_defaults)
        msg_dict = msg

        thread_name = 'update_user_restricted'
        if username:
            thread_name += username
        
        #msg_show_dict = {}
        msg_show_dict = None
        return self.update(token=token, url=self.update_restricted_url, show_url=self.show_url, region=None, json_data=json_data, use_defaults=True, use_thread=use_thread, thread_name=thread_name, message=msg_dict, show_msg=msg_show_dict)

    def delete_user(self, token=None, username=None, json_data=None, use_defaults=False, use_thread=False):
        msg = self._build(username=username, use_defaults=use_defaults)
        msg_dict = msg

        return self.delete(token=token, url=self.delete_url, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=msg_dict)

    def verify_email(self, username=None, password=None, email_address=None, server='imap.gmail.com', wait=30, mc_address=None):
        if username is None: username = self.username
        if password is None: password = self.password
        if email_address is None: email_address = self.email_address
        
        self.mc_address = mc_address
        mail = self._mail
        num_emails_pre = self._mail_count
        for attempt in range(wait):
            mail.recent()
            status, email_list = mail.search(None, '(SUBJECT "Welcome to MobiledgeX!")')
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
                        email_subject = msg['subject']
                        email_from = msg['from']
                        date_received = msg['date']
                        payload = msg.get_payload(decode=True).decode('utf-8')
                        logging.info(payload)

                        if f'Hi {username},' in payload:
                            logging.info('greetings found')
                        else:
                            raise Exception('Greetings not found')

                        if 'Thanks for creating a MobiledgeX account! You are now one step away from utilizing the power of the edge. Please verify this email account by clicking on the link below. Then you\'ll be able to login and get started.' in payload:
                            logging.info('body1 found')
                        else:
                            raise Exception('Body1 not found')

                        #if f'Click to verify: {self.console_url}/verify?token=' in payload:
                        if f'Copy and paste to verify your email:' in payload:
                            for line in payload.split('\n'):
                                if 'mcctl user verifyemail token=' in line:
                                    #label, link = line.split('Click to verify:')
                                    self._verify_link = line.rstrip()

                                    cmd = f'docker run registry.mobiledgex.net:5000/mobiledgex/edge-cloud:latest mcctl login --addr https://{self.mc_address} username=mexadmin password=mexadminfastedgecloudinfra --skipverify'
                                    logging.info('login with:' + cmd)
                                    self._run_command(cmd)
                                    cmd = f'docker run registry.mobiledgex.net:5000/mobiledgex/edge-cloud:latest {line} --addr https://{self.mc_address} --skipverify '
                                    logging.info('verifying email with:' + cmd)
                                    self._run_command(cmd)    

                                    break
                            logging.info('verify link found')
                        else:
                            raise Exception('Verify link not found')

                        if f'For security, this request was received for {email_address} from' in payload and 'If you are not expecting this email, please ignore this email or contact MobiledgeX support for assistance.' in payload and 'Thanks!' in payload and 'MobiledgeX Team' in payload:
                            logging.info('body2 link found')
                        else:
                            raise Exception('Body2 not found')
                        return True
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
            #print('*WARN*',stdout, stderr)
            if stderr:
                raise Exception('runCommandee failed:' + stderr.decode('utf-8'))

            return stdout
        except subprocess.CalledProcessError as e:
            raise Exception("runCommanddd failed:", e)
        except Exception as e:
            raise Exception("runCommanddd failed:", e)
 
