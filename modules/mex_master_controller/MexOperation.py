import json
import logging
import time
import threading
import sys
import subprocess

import shared_variables

from mex_rest import MexRest

logger = logging.getLogger(__name__)

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
                               'req_fail': 0},
                    'run': {'req_attempts': 0,
                            'req_success': 0,
                            'req_fail': 0}
                    }

    def __init__(self, root_url, prov_stack=None, token=None, super_token=None, thread_queue=None):
        super().__init__()

        self.root_url = root_url
        self.prov_stack = prov_stack
        self.super_token = super_token
        self.token = token
        self.thread_queue = thread_queue

    def create(self, token=None, url=None, delete_url=None, show_url=None, region=None, use_thread=False, json_data=None, use_defaults=False, create_msg=None, delete_msg=None, show_msg=None, thread_name=None):
        return self.send(message_type='create', token=token, url=url, delete_url=delete_url, show_url=show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=create_msg, delete_message=delete_msg, show_message=show_msg, thread_name=thread_name)

    def delete(self, token=None, url=None, region=None, json_data=None, use_defaults=True, use_thread=False, message=None):
        return self.send(message_type='delete', token=token, url=url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=message)

    def show(self, token=None, url=None, region=None, json_data=None, use_defaults=True, use_thread=False, message=None, stream=False):
        resp = self.send(message_type='show', token=token, url=url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=message, stream=stream)
 
        if isinstance(resp, dict):
            return [resp]
        else:
            return resp

    def update(self, token=None, url=None, show_url=None, region=None, json_data=None, use_defaults=True, use_thread=False, message=None, show_msg=None):
        return self.send(message_type='update', token=token, url=url, show_url=show_url, region=region, json_data=json_data, use_defaults=use_defaults, use_thread=use_thread, message=message, show_message=show_msg)

    def send(self, message_type, token=None, url=None, delete_url=None, show_url=None, region=None, json_data=None, use_defaults=True, use_thread=False, message=None, delete_message=None, show_message=None, thread_name='thread_name', stream=False):
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

        def send_message(thread_name='Thread'):
            self.counter_dict[message_type]['req_attempts'] += 1
        
            try:
                self.post(url=url, bearer=token, data=payload, stream=stream)
                logger.info('response:\n' + str(self.resp.status_code) + '\n' + str(self.resp.text))

                # failures return a 200 for http streaming, so have to check the output for failure
                if 'CreateAppInst' in url:
                    if 'Created AppInst successfully' not in str(self.resp.text):
                        raise Exception('ERROR: AppInst not created successfully:' + str(self.resp.text))
                if 'UpdateAppInst' in url:
                    if 'Ready' not in str(self.resp.text):
                        raise Exception('ERROR: AppInst not updated successfully:' + str(self.resp.text))
                if 'RefreshAppInst' in url:
                    if 'Failed: 0' not in str(self.resp.text):
                        raise Exception('ERROR: AppInst not refreshed successfully:' + str(self.resp.text))
                if 'CreateClusterInst' in url:
                    if 'Created ClusterInst successfully' not in str(self.resp.text):
                        raise Exception('ERROR: ClusterInst not created successfully:' + str(self.resp.text))
                if 'UpdateClusterInst' in url:
                    if 'Updated ClusterInst successfully' not in str(self.resp.text):
                        raise Exception('ERROR: ClusterInst not updated successfully:' + str(self.resp.text))
                elif url.endswith('CreateCloudlet'):
                    if 'Created Cloudlet successfully' not in str(self.resp.text):
                        raise Exception('ERROR: Cloudlet not created successfully:' + str(self.resp.text))
                elif url.endswith('DeleteCloudlet'):
                    if 'Deleted Cloudlet successfully' not in str(self.resp.text):
                        raise Exception('ERROR: Cloudlet not deleted successfully:' + str(self.resp.text))
                elif url.endswith('UpdateCloudlet'):
                    if 'Updated Cloudlet successfully' in str(self.resp.text) or 'Upgraded Cloudlet successfully' in str(self.resp.text) or 'Cloudlet updated successfully' in str(self.resp.text):
                        pass
                    else:
                        raise Exception('ERROR: Cloudlet not updated successfully:' + str(self.resp.text))
            except Exception as e:
                logger.info('operation failed:' + str(sys.exc_info()))
                self.counter_dict[message_type]['req_fail'] += 1

                if self.thread_queue:
                    logger.info(f'adding {thread_name} to thread_queue')
                    self.thread_queue.put({thread_name:sys.exc_info()})
                  
                # have seen case where timeout exception is thrown but post was successful. Dont throw exception if 200 anyway 
                #if self.resp.status_code:
                #    if self.resp.status_code != 200: 
                #        #if self.thread_queue:
                #        #    logging.info(f'adding {thread_name} to thread_queue')
                #        #    self.thread_queue.put({thread_name:sys.exc_info()})
                #        raise Exception(f'code={self.resp.status_code}', f'error={self.resp.text}')

                raise Exception(f'code={self.resp.status_code}', f'error={self.resp.text}')

            if message and delete_message:
                logger.debug(f'adding message to delete stack: {delete_message}')
                self.prov_stack.append(lambda:self.send(message_type='delete', url=delete_url, region=region, token=token, message=delete_message, use_defaults=False))
            self.counter_dict[message_type]['req_success'] += 1

            if message and show_message:
                logger.debug(f'showing:{show_message}')
                #resp = self.send(message_type='show', region=region, url=show_url, token=self.super_token, message=show_message, use_defaults=False)
                resp = self.send(message_type='show', region=region, url=show_url, token=token, message=show_message, use_defaults=False)
        if use_thread is True:
            thread_name = f'Thread-{thread_name}-{str(time.time())}'
            t = threading.Thread(target=send_message, name=thread_name, args=(thread_name,))
            t.start()
            return t
        else:
            resp = send_message()
            return self.decoded_data

    def run(self, message_type='run', token=None, command=None, region=None, timeout=120, json_data=None, use_defaults=True, use_thread=False, thread_name='thread_name'):
        if use_defaults == True:
            if token == None: token = self.token

        cmd_docker = 'docker pull registry.mobiledgex.net:5000/mobiledgex/edge-cloud:latest > /dev/null && docker run registry.mobiledgex.net:5000/mobiledgex/edge-cloud:latest'
        cmd = f'{cmd_docker} {command} --token {token}'
        logger.info(f'running cmd: {cmd}')
        
        def send_message():
            self.counter_dict[message_type]['req_attempts'] += 1

            try:
                process = subprocess.Popen(cmd,
                                           stdout=subprocess.PIPE,
                                           stderr=subprocess.PIPE,
                                           #timeout=timeout,
                                           shell=True
                )                

                stdout = [line.decode('utf-8') for line in process.stdout.readlines()]
                stderr = [line.decode('utf-8') for line in process.stderr.readlines()]
                if stderr:
                    raise Exception(f'error={stderr}')
                for line in stdout:
                    if 'Error' in line:
                        raise Exception(f'error={stdout}')
            except subprocess.CalledProcessError as e:
                print('*WARN*','cpe',e)
            except Exception as e:
                self.counter_dict[message_type]['req_fail'] += 1
                #raise Exception(f'error3={e}')
                raise

            self.counter_dict[message_type]['req_success'] += 1

            return stdout
        
        if use_thread is True:
            t = threading.Thread(target=send_message)
            t.start()
            return t
        else:
            resp = send_message()
            return resp

