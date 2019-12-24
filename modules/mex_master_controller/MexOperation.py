import json
import logging

import shared_variables

from mex_rest import MexRest

logger = logging.getLogger('mex_operation rest')

class MexOperation(MexRest):
    counter_dict = {'show': {'req_attempts': 0,
                             'req_success': 0,
                             'req_fail': 0},
                    'create': {'req_attempts': 0,
                               'req_success': 0,
                               'req_fail': 0},
                    'delete': {'req_attempts': 0,
                               'req_success': 0,
                               'req_fail': 0},
                    'update': {'req_attempts': 0,
                               'req_success': 0,
                               'req_fail': 0}
                    }

    def __init__(self, root_url, prov_stack=None, token=None, super_token=None):
        super().__init__()

        self.root_url = root_url
        self.prov_stack = prov_stack
        self.super_token = super_token
        self.token = token
        
    def create(self, token=None, url=None, delete_url=None, show_url=None, region=None, use_thread=False, json_data=None, use_defaults=False, create_msg=None, delete_msg=None, show_msg=None):
        return self.send(message_type='create', token=token, url=url, delete_url=delete_url, show_url=show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=create_msg, delete_message=delete_msg, show_message=show_msg)

    def delete(self, token=None, url=None, region=None, json_data=None, use_defaults=True, use_thread=False, message=None):
        return self.send(message_type='delete', token=token, url=url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=message)

    def show(self, token=None, url=None, region=None, json_data=None, use_defaults=True, use_thread=False, message=None):
        return self.send(message_type='show', token=token, url=url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=message)

    def update(self, token=None, url=None, region=None, json_data=None, use_defaults=True, use_thread=False, message=None):
        return self.send(message_type='update', token=token, url=url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=message)

        
    def send(self, message_type, token=None, url=None, delete_url=None, show_url=None, region=None, json_data=None, use_defaults=True, use_thread=False, message=None, delete_message=None, show_message=None):
        url = self.root_url + url
    
        payload = None
        msg_dict = None
    
        if use_defaults == True:
            if token == None: token = self.token
        
        if json_data !=  None:
            payload = json_data
        else:
            msg_dict = message
        if region is not None:
            msg_dict['region'] = region
            
        payload = json.dumps(msg_dict)
            
        logger.info(f'{message_type} at {url}. \n\t{payload}')

        def send_message():
            self.counter_dict[message_type]['req_attempts'] += 1
        
            try:
                self.post(url=url, bearer=token, data=payload)
            
                logger.info('response:\n' + str(self.resp.status_code) + '\n' + str(self.resp.text))
            
            except Exception as e:
                self.counter_dict[message_type]['req_fail'] += 1
                raise Exception(f'code={self.resp.status_code}', f'error={self.resp.text}')

            if message and delete_message:
                logger.debug(f'adding message to delete stack: {delete_message}')
                self.prov_stack.append(lambda:self.send(message_type='delete', url=delete_url, region=region, token=self.super_token, message=delete_message, use_defaults=False))
            self.counter_dict[message_type]['req_success'] += 1

            if message and show_message:
                logger.debug(f'showing:{show_message}')
                resp = self.send(message_type='show', region=region, url=show_url, token=self.super_token, message=show_message, use_defaults=False)
        if use_thread is True:
            t = threading.Thread(target=send_message)
            t.start()
            return t
        else:
            resp = send_message()
            return self.decoded_data
