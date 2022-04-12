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

import subprocess
import shlex
import sys
import logging
import time
import os
import re
import json

logging.basicConfig(format='%(asctime)s %(levelname)s %(funcName)s line:%(lineno)d - %(message)s',datefmt='%d-%b-%y %H:%M:%S')
logger = logging.getLogger()

class MexProcessHandler():
    def __init__(self):
        self.etcd_clients = []
        self.crm_clients = []
        self.dme_clients = []
    
    def start_etcd(self, *args):
        etcd = Etcd()
        self.etcd_clients = etcd.start(*args)

    def start_controller(self):
        controller = Controller()
        controller.start(etcd_client_list = self.etcd_clients)

    def start_crm(self, cloudlet_name, operator_name, api_address=None, environment=None):
        crm = CRM()
        crm.start(cloudlet_name, operator_name, api_address, environment)
        self.crm_clients.append(crm)
        
    def start_dme(self, carrier=None, cloudlet_name=None, operator_name=None, cloudlet_key=None, certificate=None):
        """ Starts a DME process with the specified parameters

        Examples:

        | Start DME | carrier=${cloudlet_name} | cloudlet_name=${cloudlet_name} | operator_name=${operator_name} |
        | Run Keyword and Expect Error | * | Start DME | carrier=${cloudlet_name} | cloudlet_name=${cloudlet_name} | operator_name=${operator_name} | certificate=xx |

        """

        dme = DME()
        self.dme_clients.append(dme)
        pid = dme.start(carrier, cloudlet_name, operator_name, cloudlet_key, certificate)

        return pid
    
    def kill_dme(self):
        """ Kills the previously started DME

        Examples:

        | Start DME | carrier=${cloudlet_name} | cloudlet_name=${cloudlet_name} | operator_name=${operator_name} |
        | Kill DME |

        """
        dme = self.dme_clients[-1]
        dme.kill()

    def kill_process(self, pid):
        """ Kills the process with the given pid

        Examples:

        | ${pid}= | Start DME | carrier=${cloudlet_name} | cloudlet_name=${cloudlet_name} | operator_name=${operator_name} |
        | Kill Process | pid=${pid}

        """

        process = Mexprocess()
        process.kill(pid=pid)
        
    def crm_vm_should_be_up(self, timeout=600):
        crm = self.crm_clients[-1]
        print('crm', self.crm_clients)
        lines = crm._followFile(crm.log_file, crm.vm_up_line, time_secs=int(timeout))

        for line in lines:
            pass
            #print('line', line)
            #if crm.vm_up_line in line:
            #    print('VM is UP')
            #    crm._stop_followFile()

    def dme_log_file_should_contain(self, string, timeout=600):
        """ Waits for the specified string in the DME log file from the previous Start DME. It will wait for 5 minutes or the specified timeout in seconds

        Examples:

        | Run Keyword and Expect Error | * | Start DME | carrier=${cloudlet_name} | cloudlet_name=${cloudlet_name} | operator_name=${operator_name} | certificate=xx |
        | DME Log File Should Contain | get TLS Credentials |

        """

        dme = self.dme_clients[-1]
        print('dme', self.dme_clients)
        lines = dme._followFile(dme.log_file, string, time_secs=int(timeout))

        for line in lines:
            pass
            print('line', line)
            #if crm.vm_up_line in line:
            #    print('VM is UP')
            #    crm._stop_followFile()

class Mexprocess(object):
    def __init__(self, cmd=None, log_file=None):
        print('calling mexprocess')
        self.pid = None
        #self.cmd = cmd
        homedir = os.environ.get('HOME')
        self.bin_path = homedir + '/go/bin'
        self.certificate = homedir + '/go/src/github.com/mobiledgex/edge-cloud/tls/out/mex-server.crt'
        self.log_file = None
        
    def start(self, cmd, log_file, environment=None):
        logger.debug('starting {}'.format(cmd))
                     
        process = None
        try:
            my_env = os.environ.copy()
            env_dict = my_env
            if environment:
                print('running environment', environment)
                with open(environment) as f:
                    for line in f:
                        if line.startswith('export'):
                            var, value = line.split()[1].split('=')
                            env_dict[var] = value.replace('~', my_env['HOME'])
                            env_dict[var] = env_dict[var].replace('\\', '')
                            env_dict[var] = env_dict[var].replace('"', '')

            self.log_file = log_file
            print('env', env_dict)
            process = subprocess.Popen(shlex.split(cmd),
                                       #stdout=subprocess.DEVNULL,
                                       #stderr=subprocess.DEVNULL,
                                       stdout=open(log_file, 'w'),
                                       shell=False,
                                       env=env_dict,
                                       preexec_fn=os.setpgrp)
            logger.debug('Running process with pid=' + str(process.pid) + ' and logfile=' + log_file)
            time.sleep(1)
            if process.poll() is not None:
                raise ProcessFailed('process is not alive')

            self.pid = process.pid
            return self.pid
        
        except subprocess.CalledProcessError as e:
            raise ProcessFailed(e.stderr.decode('utf-8'))

    def kill(self, pid=None):
        pid_to_kill = None
        log_file_kill = None

        if pid:
            pid_to_kill = pid
            log_file_kill = '/tmp/kill.log'
        else:
            pid_to_kill = self.pid
            log_file_kill = self.log_file + 'kill'

        if pid_to_kill:
            cmd = 'kill ' + str(pid_to_kill)

            process = subprocess.Popen(shlex.split(cmd),
                                       stdout=open(log_file_kill, 'w'),
                                       shell=False,
                                       preexec_fn=os.setpgrp)
            logger.debug('Running kill process with pid=' + str(pid_to_kill) + ' and logfile=' + log_file_kill)
            time.sleep(1)
            if process.poll() is None:
                raise ProcessFailed('process is still alive')
        else:
            raise ProcessFailed('cannot kill process since pid is not set')
        
    def _followFile(self, theFile, line_to_find, time_secs=60):
        start_time = time.time()
        with open(theFile, 'r') as f:
            #f.seek(0,2)  # seek to end of file
            f.seek(0)
            while True:
                line = f.readline()
                #print('line',line)
                elapsed_time = time.time() - start_time
                if elapsed_time > time_secs:
                    logger.error('timout waiting for line in file={}. timout={}'.format(theFile, time_secs))
                    raise FindLineInFileFailed('Timeout waiting for:\"{}\" in {}. timeout={} secs'.format(line_to_find, theFile, time_secs)) 
                    #break

                if not line:
                    time.sleep(0.1)
                    continue
                
                if line_to_find in line:
                    logging.info('Found matching line:' + line)
                    yield line
                    break
                yield line


class Etcd(Mexprocess):
    name = 'etcd'
    name_num = 1
    listen_peer_port = 30011
    listen_client_port = 30001
    advertising_client_port = 30001
    initial_advertise_peer_port = 30011
    
    #def __init__(self, name=None, data_dir=None, listen_peer_urls=None, listen_client_urls=None, advertise_client_urls=None, initial_advertise_peer_urls=None, initial_cluster=None, etcd_path='/usr/local/bin', log_dir='/tmp'):
    def __init__(self, name='etcd', data_dir=None, listen_peer_urls='http://127.0.0.1:30011', listen_client_urls='http://127.0.0.1:30001', advertise_client_urls='http://127.0.0.1:30001', initial_advertise_peer_urls='http://127.0.0.1:30011', initial_cluster='etcd1=http://127.0.0.1:30011', etcd_path='/usr/local/bin', log_dir='/tmp'):
        logger.debug('starting etcd process')
        print('andyu')
        #self.name = name
        if data_dir is None and name is not None:
            data_dir = '/var/tmp/edge-cloud-local-etcd/' + name
        #self.listen_peer_urls = listen_peer_urls
        #self.listen_client_urls = listen_client_urls
        #self.advertise_client_urls=advertise_client_urls
        #self.initial_advertise_peer_urls = initial_advertise_peer_urls
        #self.initial_cluster = initial_cluster

        self.etcd_path = etcd_path
        
        if name is not None:
            self.log_file = log_dir + '/etcd_' + name + '_' + str(int(time.time())) + '.log'
        else:
            self.log_file = log_dir + '/etcd_' + str(int(time.time())) + '.log'
            
        self.etcd_cmd = 'nohup {}/etcd --name {} --data-dir {} --listen-peer-urls {} --listen-client-urls {} --advertise-client-urls {} --initial-advertise-peer-urls {} --initial-cluster {}'.format(etcd_path, name, data_dir, listen_peer_urls, listen_client_urls, advertise_client_urls, initial_advertise_peer_urls, initial_cluster)

        #super(Etcd, self).__init__(cmd=self.etcd_cmd, log_file=self.log_file)
        super(Etcd, self).__init__()
        #self.start()

    def start(self, *args):
        print('create etcd', self.listen_peer_port, *args)
        
        url_ip = 'http://127.0.0.1'

        initial_cluster = ''
        for index,name in enumerate(args):
            initial_cluster = initial_cluster + name + '=' + url_ip + ':' + str(self.listen_peer_port+index) + ','
        initial_cluster = initial_cluster[:-1]
            
        #name = self.name + str(self.name_num)
        listen_client_list = []
        for name in args:
            data_dir = '/var/tmp/edge-cloud-local-etcd/' + name
            listen_peer_urls = url_ip + ':' + str(self.listen_peer_port)
            listen_client_urls = url_ip + ':' + str(self.listen_client_port) 
            advertise_client_urls = url_ip + ':' + str(self.advertising_client_port)
            initial_advertise_peer_urls = url_ip + ':' + str(self.initial_advertise_peer_port)
            #initial_cluster = name + '=' + listen_peer_urls
            listen_client_list.append(listen_client_urls)
            
            self.etcd_cmd = 'nohup {}/etcd --name {} --data-dir {} --listen-peer-urls {} --listen-client-urls {} --advertise-client-urls {} --initial-advertise-peer-urls {} --initial-cluster {}'.format(self.etcd_path, name, data_dir, listen_peer_urls, listen_client_urls, advertise_client_urls, initial_advertise_peer_urls, initial_cluster)

            #super(Etcd, self).__init__(cmd=self.etcd_cmd, log_file=self.log_file)
            super(Etcd,self).start(cmd=self.etcd_cmd, log_file=self.log_file)

            #self.name_num += 1
            self.listen_peer_port += 1
            self.listen_client_port += 1
            self.advertising_client_port += 1
            self.initial_advertise_peer_port += 1

        return listen_client_list
    
class Controller(Mexprocess):
    notify_port = 37001
    api_port = 55001
    http_port = 36001

    def __init__(self, etcd_urls='http://127.0.0.1:30001', notify_address='127.0.0.1:37001', api_address='0.0.0.0:55001', http_address='0.0.0.0:36001', certificate='~/go/src/github.com/mobiledgex/edge-cloud/tls/out/mex-server.crt', debug_options=None, short_timeouts=True, ctrl_path='~/go/bin', log_dir='/tmp'):

        logger.debug('starting controller process')

        self.ip = '127.0.0.1'
        self.log_dir = '/tmp'
        self.debug_options = 'etcd,api,notify'
        self.short_timeouts = True
        
        super(Controller, self).__init__()
        
    def start(self, etcd_client_list):
        print('start controller', etcd_client_list)

        etcd_urls = ''
        for etcd in etcd_client_list:
            etcd_urls += etcd + ','
        etcd_urls = etcd_urls[:-1]

        notify_address = self.ip + ':' + str(Controller.notify_port)
        api_address = self.ip + ':' + str(Controller.api_port)
        http_address = self.ip + ':' + str(Controller.http_port)
        log_file = self.log_dir + '/controller_' + api_address + '_' + str(int(time.time())) + '.log'
        
        controller_cmd = 'nohup {}/controller --etcdUrls {} --notifyAddr {} --apiAddr {} --httpAddr {} --tls {}'.format(self.bin_path, etcd_urls, notify_address, api_address, http_address, self.certificate)
        if self.debug_options:
            controller_cmd += ' -d ' + self.debug_options
        if self.short_timeouts:
            controller_cmd += ' -shortTimeouts'

        #super(Controller, self).__init__(cmd=controller_cmd, log_file=log_file)
        super(Controller, self).start(cmd=controller_cmd, log_file=log_file)

        Controller.notify_port += 1
        Controller.api_port += 1
        Controller.http_port += 1
        
class CRM(Mexprocess):
    notify_port = 37001
    api_port = 55091
    name_num = 1
    
    def __init__(self, notify_address=None, api_address=None, cloudlet_key=None, certificate=None, name='crm', debug_options=None, crm_path='~/go/bin', log_dir='/tmp'):
        logger.debug('starting crm process')

        self.ip = '127.0.0.1'
        self.log_dir = '/tmp'
        self.debug_options = 'mexos,api,notify'
        self.name = 'crm'
        self.vm_up_line = 'init platform with cloudlet key ok'
        
        super(CRM, self).__init__()
        
    def start(self,cloudlet_name, operator_name, api_address=None, environment=None):
        name = self.name + str(CRM.name_num)
        notify_address = self.ip + ':' + str(CRM.notify_port)
        if not api_address:
            api_address = self.ip + ':' + str(CRM.api_port)
        log_file = self.log_dir + '/crm_' + name + '_' + api_address + '_' + str(int(time.time())) + '.log'
        #cloudlet_key = '\'{\\"operator_key\\":{\\"name\\":\\"' + operator_name + '\\"},\\"name\\":\\"' + cloudlet_name + '\\"}\''
        cloudlet_key = '\'{"operator_key":{"name":"' + operator_name + '"},"name":"' + cloudlet_name + '"}\''

        
        self.crm_cmd = 'nohup {}/crmserver --notifyAddrs {} --apiAddr {} --cloudletKey {} --tls {} --hostname {}'.format(self.bin_path, notify_address, api_address, cloudlet_key, self.certificate, name)
        if self.debug_options:
            self.crm_cmd += ' -d ' + self.debug_options

        super(CRM, self).start(cmd=self.crm_cmd, log_file = log_file, environment=environment)

        CRM.notify_port += 1
        CRM.api_port += 1
        CRM.name_num += 1
        
class DME(Mexprocess):
    notify_port = 37001
    api_port = 50051

    def __init__(self, notify_address=None, api_address=None, location_server_url=None, token_server_url=None, carrier=None, cloudlet_key=None, certificate=None, debug_options=None, dme_path='~/go/bin', log_dir='/tmp'):
        logger.debug('starting dme process')

        super(DME, self).__init__()
        
        self.ip = '127.0.0.1'
        self.api_ip = '0.0.0.0'
        self.log_dir = '/tmp'
        self.debug_options = 'locapi,dmedb,dmereq'
        self.location_server = ' http://127.0.0.1:8888/verifyLocation'
        self.token_server = 'http://127.0.0.1:9999/its?followURL=https://dme.mobiledgex.net/verifyLoc'
        self.certificate = certificate

    def start(self,carrier=None, cloudlet_name=None, operator_name=None, cloudlet_key=None, certificate=None):
        notify_address = self.ip + ':' + str(DME.notify_port)
        api_address = self.api_ip + ':' + str(DME.api_port)
        log_file = self.log_dir + '/dme_' + api_address + '_' + str(int(time.time())) + '.log'

        cloudlet_key_string = None
        if cloudlet_key:
            cloudlet_key_string = cloudlet_key
        else:
            cloudlet_dict = {}
            if operator_name is not None:
                cloudlet_dict['operator_key'] = {'name':operator_name}
            if cloudlet_name is not None:
                cloudlet_dict['name'] = cloudlet_name
            if cloudlet_dict:
                cloudlet_key_string = json.dumps(cloudlet_dict)
        #cloudlet_key = '{\\"operator_key\\":{\\"name\\":\\"' + operator_name + '\\"},\\"name\\":\\"' + cloudlet_name + '\\"}'
            
        self.dme_cmd = 'nohup {}/dme-server --notifyAddrs {} --apiAddr {} --locverurl {} --toksrvurl {} --carrier {}'.format(self.bin_path, notify_address, api_address, self.location_server, self.token_server, carrier)


        if cloudlet_key_string:
            self.dme_cmd += f' --cloudletKey \'{cloudlet_key_string}\''
            
        if certificate is not None:
            self.dme_cmd += f' --tls {certificate}'
        if self.debug_options:
            self.dme_cmd += ' -d ' + self.debug_options
        
        pid = super(DME, self).start(cmd=self.dme_cmd, log_file = log_file)

        DME.notify_port += 1
        DME.api_port += 1

        return pid
    
class ProcessFailed(Exception):
    def __init__(self, message):
        self.message = message

class FindLineInFileFailed(Exception):
    def __init__(self, message):
        self.message = message

