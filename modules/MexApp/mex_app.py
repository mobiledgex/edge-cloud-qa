import logging
import socket
import ssl
import sys
import os
import subprocess
import time
import requests
import re
import CloudFlare

import rootlb
import kubernetes
import shared_variables

from mex_master_controller.AlertReceiver import AlertReceiver

logger = logging.getLogger(__name__)

class MexApp(object):
    def __init__(self):
        self.kubeconfig_dir = os.getenv('HOME') + '/.mobiledgex'
        self.rootlb = None
        self.cf_token = '60632181cb3b7419304ffa820b2d99e292092'
        self.cf_user = 'mobiledgex.ops@mobiledgex.com'
        self.cf_zone_name = 'mobiledgex.net'

        self.alert_receiver = AlertReceiver(root_url='dummy')
        
    def ping_udp_port(self, host, port):
        data = 'ping'
        exp_return_data = 'pong'
        data_size = sys.getsizeof(bytes(data, 'utf-8'))
        data_to_send = data.encode('ascii')

        client_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        client_socket.settimeout(1)

        return_data = ''
        try:
            logging.debug(f'sending {data} to {host}:{port}')
            client_socket.sendto(data_to_send,(host, int(port)))
            logging.debug(f'waiting for {exp_return_data}')
            (return_data, addr) = client_socket.recvfrom(data_size)
            logging.info('received this data from {}:{}'.format(addr, return_data.decode('utf-8')))
            #client_socket.shutdown(socket.SHUT_RDWR)
            client_socket.close()
        except Exception as e:
            client_socket.close()
            raise Exception('error=', e)
            
        if return_data.decode('utf-8') != exp_return_data:
            raise Exception('correct data not received from server. expected=' + exp_return_data + ' got=' + return_data.decode('utf-8'))

    def stop_udp_port(self, host, port):
        data = 'exit'
        exp_return_data = 'bye'
        data_size = sys.getsizeof(bytes(data, 'utf-8'))
        data_to_send = data.encode('ascii')

        client_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        client_socket.settimeout(1)

        return_data = ''
        try:
            logging.debug(f'sending {data} to {host}:{port}')
            client_socket.sendto(data_to_send,(host, int(port)))
            logging.debug(f'waiting for {exp_return_data}')
            (return_data, addr) = client_socket.recvfrom(data_size)
            logging.info('received this data from {}:{}'.format(addr, return_data.decode('utf-8')))
            #client_socket.shutdown(socket.SHUT_RDWR)
            client_socket.close()
        except Exception as e:
            client_socket.close()
            raise Exception('error=', e)

        if return_data.decode('utf-8') != exp_return_data:
            raise Exception('correct data not received from server. expected=' + exp_return_data + ' got=' + return_data.decode('utf-8'))

    def start_udp_port(self, host, port, server_port=4015):
        data = f'udp:{port}'
        exp_return_data = 'started'
        data_size = sys.getsizeof(bytes(data, 'utf-8'))
        data_to_send = data.encode('ascii')

        client_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        client_socket.settimeout(1)

        return_data = ''
        try:
            logging.debug(f'sending {data} to {host}:{server_port}')
            client_socket.sendto(data_to_send,(host, int(server_port)))
            logging.debug(f'waiting for {exp_return_data}')
            (return_data, addr) = client_socket.recvfrom(data_size)
            logging.info('received this data from {}:{}'.format(addr, return_data.decode('utf-8')))
            #client_socket.shutdown(socket.SHUT_RDWR)
            client_socket.close()
        except Exception as e:
            client_socket.close()
            raise Exception('error=', e)

        if return_data.decode('utf-8') != exp_return_data:
            raise Exception('correct data not received from server. expected=' + exp_return_data + ' got=' + return_data.decode('utf-8'))

    def stop_tcp_port(self, host, port, tls=False):
        data = 'exit'
        exp_return_data = 'bye'
        data_size = sys.getsizeof(bytes(data, 'utf-8'))

        client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        client_socket.settimeout(10)
        sock = client_socket

        if tls:
            logging.info('creating ssl connection')
            context = ssl.SSLContext()
            context.verify_mode = ssl.CERT_NONE
            context.check_hostname = False

            sock = context.wrap_socket(client_socket)

        sock.connect((host, int(port)))

        return_data = ''
        try:
            logging.debug('sending data')
            sock.sendall(bytes(data, encoding='utf-8'))
            return_data = sock.recv(data_size)

            logging.debug('data recevied back:' + return_data.decode('utf-8'))
            sock.close()
        except Exception as e:
            print('caught exception')
            sock.close()
            raise Exception('error=', e)

        if return_data.decode('utf-8') != exp_return_data:
            raise Exception('correct data not received from server. expected=' + exp_return_data + ' got=' + return_data.decode('utf-8'))

    def start_tcp_port(self, host, port, server_port=4015, tls=False):
        data = f'tcp:{port}'
        exp_return_data = 'started'
        data_size = sys.getsizeof(bytes(data, 'utf-8'))

        client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        client_socket.settimeout(10)
        sock = client_socket

        if tls:
            logging.info('creating ssl connection')
            context = ssl.SSLContext()
            context.verify_mode = ssl.CERT_NONE
            context.check_hostname = False

            sock = context.wrap_socket(client_socket)

        sock.connect((host, int(server_port)))

        return_data = ''
        try:
            logging.debug('sending data')
            sock.sendall(bytes(data, encoding='utf-8'))
            return_data = sock.recv(data_size)

            logging.debug('data recevied back:' + return_data.decode('utf-8'))
            sock.close()
        except Exception as e:
            print('caught exception')
            sock.close()
            raise Exception('error=', e)

        if return_data.decode('utf-8') != exp_return_data:
            raise Exception('correct data not received from server. expected=' + exp_return_data + ' got=' + return_data.decode('utf-8'))

    def ping_tcp_port(self, host, port, wait_time=0, tls=False):
        data = 'ping'
        exp_return_data = 'pong'
        data_size = sys.getsizeof(bytes(data, 'utf-8'))
        
        client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        client_socket.settimeout(10)
        sock = client_socket

        if tls:
            logging.info('creating ssl connection')
            context = ssl.SSLContext()
            context.verify_mode = ssl.CERT_NONE
            context.check_hostname = False

            sock = context.wrap_socket(client_socket)

        sock.connect((host, int(port)))
        
        return_data = ''
        try:
            logging.debug('sending data')
            sock.sendall(bytes(data, encoding='utf-8'))
            return_data = sock.recv(data_size)

            logging.debug('data recevied back:' + return_data.decode('utf-8'))
            logging.info(f'holding port for {wait_time}s')
            time.sleep(wait_time)
            sock.close()
        except Exception as e:
            print('caught exception')
            sock.close()
            raise Exception('error=', e)
            
        if return_data.decode('utf-8') != exp_return_data:
            raise Exception('correct data not received from server. expected=' + exp_return_data + ' got=' + return_data.decode('utf-8'))

    def get_app_version(self, host, port, wait_time=0, tls=False):
        data = 'version'
        logging.info('getting app version')
        return_data = None
        try:
            return_data = self._send_tcp_data(host, port, data).decode('utf-8')
        except Exception as e:
            logging.error(f'tcp exception caught:{e}')
            raise Exception(e)

        if len(return_data) <= 0:
            raise Exception(f'correct data not received from server. expected=version got={return_data}')

        return return_data

    def make_http_request(self, host, port, page, tls=False, verify_cert=None):
        url = f'http://{host}:{port}/{page}'
        if tls:
            url = f'https://{host}:{port}/{page}'

        logging.info(f'checking for {url}')

        if tls and verify_cert:
            logging.info('verifying certs for https connection')
            resp = requests.get(url, verify=tls)
        if tls and not verify_cert:
            logging.info('TLS set with HTTPS but not verifying certs')
            resp = requests.get(url, verify=False)
        else:
            resp = requests.get(url, verify=False)

        logging.info(f'recieved status_code={resp.status_code}')
        logging.info(f'recieved body={resp.text}')
        
        if resp.status_code != 200:
            raise Exception(f'error. got {resp.status_code}. expected 200')

        if '<p>test server is running</p>' not in resp.text:
            raise Exception(f'error. did not get proper html text. got={resp.text}')
        
        return resp
    
    def udp_port_should_be_alive(self, host, port):
        logging.info('host:' + host + ' port:' + str(port))

        self.wait_for_dns(host)

        for attempt in range(1,4):
            logging.debug(f'UDP port attempt {attempt}')
            try:
                self.ping_udp_port(host, int(port))
                return True
            except Exception as e:
                logging.debug(f'udp exception caught:{e}')
                if attempt == 3:
                    raise Exception(e)
                else:
                    time.sleep(1)
                
    def tcp_port_should_be_alive(self, host, port, wait_time=0, tls=False, num_tries=4):
        logging.info(f'host:{host} port:{port} wait_time:{wait_time} tls:{tls} num_tries={num_tries}')

        self.wait_for_dns(host)
        e_return = ''
 
        for attempt in range(1,num_tries):
            logging.debug(f'TCP port attempt {attempt}')
            try:
                self.ping_tcp_port(host, port, wait_time, tls)
                return True
            except Exception as e:
                e_return = e
                logging.debug(f'tcp exception caught:{e}')
                #if attempt == num_tries:
                #    raise Exception(e)
                #else:
                time.sleep(1)
        raise Exception(e_return)

    def http_port_should_be_alive(self, host, port, page, tls=False):
        logging.info(f'host:{host} port:{port} tls:{tls}')

        self.wait_for_dns(host)
        
        resp = self.make_http_request(host, port, page, tls)
        return True          

    def _send_tcp_data(self, host, port, data):
        data_size = sys.getsizeof(bytes(data, 'utf-8'))

        client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        client_socket.connect((host, int(port)))

        return_data = ''
        try:
            logging.debug('sending data')
            client_socket.sendall(bytes(data, encoding='utf-8'))
            return_data = client_socket.recv(data_size)
            logging.debug('data recevied back:' + return_data.decode('utf-8'))
            client_socket.close()
            return return_data
        except Exception as e:
            print('caught exception')
            client_socket.close()
            raise Exception('error=', e)

    def set_cpu_load(self, host, port, load_percentage):
        data = f'load={load_percentage}'
        logging.info(f'setting CPU load to {load_percentage}%')
        return_data = None
        try:
            return_data = self._send_tcp_data(host, port, data).decode('utf-8')
        except Exception as e:
            logging.error(f'tcp exception caught:{e}')
            raise Exception(e)

        if return_data != 'pong':
            raise Exception(f'correct data not received from server. expected=pong got={return_data}')

        return return_data

    def egress_port_should_be_accessible(self, vm, host, protocol, port, vm_port=3015, wait_time=0):
        data = f'{host}:{protocol}:{port}'
        logging.info(f'vm:{vm}:{vm_port} host:{host}:{port} data={data}')

        self.wait_for_dns(vm)

        return_data = None
        for attempt in range(1,4):
            logging.debug(f'TCP port attempt {attempt}')
            try:
                return_data = self._send_tcp_data(vm, vm_port, data).decode('utf-8')
            except Exception as e:
                logging.debug(f'tcp exception caught:{e}')
                if attempt == 3:
                    raise Exception(e)
                else:
                    time.sleep(1)
            if return_data == 'success':
                logging.debug('request was success')
                break

        if return_data == 'success':
            return True
        else:
            raise Exception(f'Egress port is not accessible. Data returned is {return_data}')

    def egress_port_should_not_be_accessible(self, vm, host, protocol, port, vm_port=3015, wait_time=0):
        accessible = False
        try:
            accessible = self.egress_port_should_be_accessible(vm=vm, host=host, protocol=protocol, port=port, vm_port=vm_port, wait_time=wait_time)
        except Exception as e:
            print(e)
            if 'Egress port is not accessible' in str(e):
                return True

        raise Exception('Error: Egress port is accessible')

    def wait_for_dns(self, dns, wait_time=900):
        logging.info('waiting for dns=' + dns + ' to be ready')

        addr = None
        for t in range(wait_time):
            try:
                addr = socket.gethostbyname(dns)
                logging.info('dns is ready at ' + addr)
                return  addr
            except OSError as err:
                logging.debug(f'dns not ready yet:{err}')
                time.sleep(1)
            except:
                logging.debug(f'dns not ready yet:{sys.exc_info()[0]}')
                time.sleep(1)

        raise Exception(f'DNS for {dns} not ready after {wait_time} seconds')
   
    def k8s_scale_replicas(self, root_loadbalancer=None, kubeconfig=None, cluster_name=None, operator_name=None, pod_name=None, number_of_replicas=None): 
        rb = None
        if root_loadbalancer is not None:
            print('*WARN*', 'rootlb')
            rb = rootlb.Rootlb(host=root_loadbalancer, kubeconfig=f'{cluster_name}.{operator_name}.kubeconfig' )
            kubeconfig_file = f'{cluster_name}.{operator_name}.kubeconfig'
        else:
            rb = kubernetes.Kubernetes(self.kubeconfig_dir + '/' + kubeconfig)
            kubeconfig_file = self.kubeconfig_dir + '/' + kubeconfig
        
        self.rootlb = rb
        kubectl_out = rb.get_deploy() 

        for line in kubectl_out:
            if pod_name in line: 
                deployment = line
                logging.info('Deployment is ' + deployment )
                name = line.split('/')
                instance = name[1]

        kubectl_out = rb.k8s_scale_replicas(instance, number_of_replicas)
        logging.debug(kubectl_out)        

        for line in kubectl_out:
            if 'scaled' in line:
                logging.info('Replicas scaled to ' + number_of_replicas )

            
    def wait_for_k8s_pod_to_be_running(self, root_loadbalancer=None, kubeconfig=None, cluster_name=None, operator_name=None, pod_name=None, number_of_pods=1, wait_time=600):

        rb = None
        if root_loadbalancer is not None:
            print('*WARN*', 'rootlb')
            #rb = rootlb.Rootlb(host=root_loadbalancer, kubeconfig=f'{cluster_name}.{operator_name}.mobiledgex.net.kubeconfig' )
            rb = rootlb.Rootlb(host=root_loadbalancer, kubeconfig=f'{cluster_name}.{operator_name}.kubeconfig' )
        else:
            rb = kubernetes.Kubernetes(self.kubeconfig_dir + '/' + kubeconfig)

        self.rootlb = rb
        pod_count = 0
        
        if pod_name:
            pod_name = pod_name.replace('.', '') #remove any dots

        #shared_variables.cluster_name_default = 'cluster1544640562'
        #kubeconfig_file = self.kubeconfig_dir + '/' + shared_variables.cluster_name_default + '.kubeconfig'
        #kubeconfig_file = self.kubeconfig_dir + '/' + kubeconfig
        #logging.info('kubeconfig=' + kubeconfig_file)

        #kubectl_cmd = 'export KUBECONFIG={};kubectl get pods'.format(kubeconfig_file)
        #logging.info(kubectl_cmd)
        
        found_pod_dict = {}
        for t in range(wait_time):
            #kubectl_return = subprocess.run(kubectl_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
            #kubectl_out = kubectl_return.stdout.decode('utf-8')
            kubectl_out = rb.get_pods()
            logging.debug(kubectl_out)

            for line in kubectl_out:
                name, ready, status, restarts, age = line.split()
                logging.debug(f'{name} {ready} {status} {restarts} {age}')
                if pod_name in name:
                    if line.split()[2] == 'Running':
                        logging.info('Found running pod:' + line)
                        if name in found_pod_dict:
                            logging.info(f'already found {name}')
                        else:
                            found_pod_dict[name] = True
                            pod_count += 1
                            if pod_count == number_of_pods:
                                return True
            time.sleep(1)

        if pod_count != number_of_pods:
            raise Exception('All pods not found. expected=' + str(number_of_pods) + ' got=' + str(pod_count))
        
        raise Exception('Running k8s pod not found')

    def stop_crm_docker_container(self, crm_ip=None, background=False):
        rb = rootlb.Rootlb(host=crm_ip)

        output = rb.stop_docker_container('crmserver', background=background)
       
        if background:
            logger.info('no checking cmd return since ran in background') 
        else:
            if output[0] == 'crmserver\n':
                logger.info('Stopped crmserver on ' + crm_ip)
                return True
            else:
                raise Exception('crmserver docker stop failed on ' + crm_ip)

    def start_crm_docker_container(self, crm_ip=None):
        rb = rootlb.Rootlb(host=crm_ip)

        output = rb.start_docker_container('crmserver')

        if output[0] == 'crmserver\n':
            logging.info('Started crmserver on ' + crm_ip)
            return True
        else:
            raise Exception('crmserver docker start failed on ' + crm_ip)

    def stop_docker_container_rootlb(self, root_loadbalancer=None):

        self.wait_for_dns(root_loadbalancer)

        rb = None
        if root_loadbalancer is not None:
            rb = rootlb.Rootlb(host=root_loadbalancer)

        container_id_list = rb.get_docker_container_id()
        logging.debug(f'container_id={container_id_list}')
        container_id = container_id_list[0]

        output = rb.stop_docker_container(container_id)

        for line in output:
            if container_id in line:
                logging.info('Stopped docker container on ' + root_loadbalancer)
                return True

        raise Exception('docker stop failed on ' + root_loadbalancer)
    
    def start_docker_container_rootlb(self, root_loadbalancer=None):

        self.wait_for_dns(root_loadbalancer)

        rb = None
        if root_loadbalancer is not None:
            rb = rootlb.Rootlb(host=root_loadbalancer)

        container_id_list = rb.get_stopped_docker_container_id()
        logging.debug(f'container_id={container_id_list}')
        container_id = container_id_list[0]

        output = rb.start_docker_container(container_id)

        for line in output:
            if container_id in line:
                logging.info('Started docker container on ' + root_loadbalancer)
                return True

        raise Exception('docker start failed on ' + root_loadbalancer)

    def restart_docker_container_rootlb(self, root_loadbalancer=None):

        self.wait_for_dns(root_loadbalancer)

        rb = None
        if root_loadbalancer is not None:
            rb = rootlb.Rootlb(host=root_loadbalancer)

        container_id_list = rb.get_docker_container_id()
        logging.debug(f'container_id={container_id_list}')
        container_id = container_id_list[0]

        output = rb.restart_docker_container(container_id)

        for line in output:
            if container_id in line:
                logging.info('Restarted docker container on ' + root_loadbalancer)
                return True

        raise Exception('Restart of docker container failed on ' + root_loadbalancer)

    def stop_docker_container_clustervm(self, node, root_loadbalancer=None):

        command = 'docker ps -a --format "{{.ID}}"'
        self.wait_for_dns(root_loadbalancer)

        network, node = node.split('=')

        rb = None
        if root_loadbalancer is not None:
            rb = rootlb.Rootlb(host=root_loadbalancer, proxy_to_node=node)

        container_id_list = rb.run_command_on_node(node, command)
        logging.debug(f'container_id={container_id_list}')
        container_id = container_id_list[0]

        command = f'docker stop {container_id}'
        output = rb.run_command_on_node(node, command)

        for line in output:
            if container_id in line:
                logging.info('Stopped docker container on ' + node)
                return True

        raise Exception('docker stop failed on ' + node)

    def start_docker_container_clustervm(self, node, root_loadbalancer=None):
        
        command = 'docker ps -a --format "{{.ID}}"'
        self.wait_for_dns(root_loadbalancer)

        network, node = node.split('=')

        rb = None
        if root_loadbalancer is not None:
            rb = rootlb.Rootlb(host=root_loadbalancer, proxy_to_node=node)
    
        container_id_list = rb.run_command_on_node(node, command)
        logging.debug(f'container_id={container_id_list}')
        container_id = container_id_list[0]

        command = f'docker start {container_id}'
        output = rb.run_command_on_node(node, command)

        for line in output:
            if container_id in line:
                logging.info('Started docker container on ' + node)
                return True

        raise Exception('docker start failed on ' + node)

    def wait_for_docker_container_to_be_running(self, root_loadbalancer=None, docker_image=None, node=None, wait_time=600):

        self.wait_for_dns(root_loadbalancer)
        
        rb = None
        if root_loadbalancer is not None:
            if node is not None:
                network, node = node.split('=')
                rb = rootlb.Rootlb(host=root_loadbalancer, proxy_to_node=node)
            else:
                rb = rootlb.Rootlb(host=root_loadbalancer)
        
        container_ids = rb.get_docker_container_id()
        logging.debug(f'container_ids={container_ids}')

        for t in range(wait_time):
            for container_id in container_ids:
                info = rb.get_docker_container_info(container_id)
                if docker_image == info['image']:
                    if info['status'] == 'running':
                        logging.info('Found running container:' + info['image'])
                        return True
                logging.debug(f'no match. expecting={docker_image} got={info["image"]}')
                time.sleep(1)

        raise Exception('Running docker container not found')

    def wait_for_helm_app_to_be_deployed(self, root_loadbalancer=None, kubeconfig=None, cluster_name=None, operator_name=None, app_name=None, chart_name=None, number_of_apps=1, wait_time=600):

        rb = None
        if root_loadbalancer is not None:
            rb = rootlb.Rootlb(host=root_loadbalancer, kubeconfig=f'{cluster_name}.{operator_name}.kubeconfig' )
        else:
            rb = kubernetes.Kubernetes(self.kubeconfig_dir + '/' + kubeconfig)

        self.rootlb = rb
        app_count = 0
        
        if app_name:
            app_name = app_name.replace('.', '') #remove any dots

        found_app_dict = {}
        for t in range(wait_time):
            kubectl_out = rb.helm_list()
            logging.debug(kubectl_out)

            for line in kubectl_out:
                name, revision, updated, status, chart, version, namespace = [x.strip() for x in line.split('\t')]
                logging.debug(f'{name} {revision} {updated} {status} {chart} {version} {namespace}')
                if app_name in name:
                    if line.split('\t')[3].strip() == 'DEPLOYED' and line.split('\t')[4].strip() == chart_name:
                        logging.info('Found deployed app ' + line)
                        if name in found_app_dict:
                            logging.info(f'already found {name}')
                        else:
                            found_app_dict[name] = True
                            app_count += 1
                            if app_count == number_of_apps:
                                return True
            time.sleep(1)

        if app_count != number_of_apps:
            raise Exception('All apps not found. expected=' + str(number_of_apps) + ' got=' + str(app_count))
        
        raise Exception('Deployed helm app not found')

    def block_rootlb_port(self, root_loadbalancer, port, target):
        rb = rootlb.Rootlb(host=root_loadbalancer)

        rb.block_port(port=port, target=target)
        
    def unblock_rootlb_port(self, root_loadbalancer, port, target):
        rb = rootlb.Rootlb(host=root_loadbalancer)

        rb.unblock_port(port=port, target=target)

    def reboot_rootlb(self, root_loadbalancer):
        rb = rootlb.Rootlb(host=root_loadbalancer)

        rb.reboot()
        
    def mount_should_exist_on_pod(self, root_loadbalancer=None, cluster_name=None, operator_name=None, pod_name=None, mount=None):

        rb = None
        if root_loadbalancer is not None:
            #rb = rootlb.Rootlb(host=root_loadbalancer, kubeconfig=f'{cluster_name}.{operator_name}.mobiledgex.net.kubeconfig' )
            rb = rootlb.Rootlb(host=root_loadbalancer, kubeconfig=f'{cluster_name}.{operator_name}.kubeconfig' )
        else:
            rb = self.rootlb

        filename = None
        try:
            rb.mount_exists_on_pod(pod=pod_name, mount=mount)
            logging.info(f'mount={mount} exists on pod={pod_name}')
        except Exception as e:
            raise Exception(f'mount={mount} DOES NOT exist on pod={pod_name}.{e}')
        try:
            filename = rb.write_file_to_pod(pod=pod_name, mount=mount)
            logging.info(f'successfully wrote file to pod={pod_name} on mount={mount}')
        except:
            raise Exception(f'error writing file to mount={mount} and pod={pod_name}. {sys.exc_info()[0]}')

        #node_file = f'/data/{cluster_name}_node.txt'
        try:
            output = rb.read_file_from_pod(pod=pod_name, filename=filename)
            logging.info(f'output={output} expecting={cluster_name}')
            assert output[0].rstrip() == pod_name
        except:
            raise Exception(f'error. file not found on node for file={filename} and pod={pod_name}. {sys.exc_info()[0]}')

        return filename
    
    def mount_should_persist(self, root_loadbalancer=None, cluster_name=None, operator_name=None, pod_name=None, mount=None):
        rb = None
        if root_loadbalancer is not None:
            rb = rootlb.Rootlb(host=root_loadbalancer, kubeconfig=f'{cluster_name}.{operator_name}.kubeconfig' )
        else:
            rb = self.rootlb

        filename = self.mount_should_exist_on_pod(root_loadbalancer=root_loadbalancer, cluster_name=cluster_name, operator_name=operator_name, pod_name=pod_name, mount=mount)
        rb.delete_pod(pod_name=pod_name)

        try:
            output = rb.read_file_from_pod(pod=pod_name, filename=filename)
            logging.info(f'output={output} expecting={cluster_name}')
            assert output[0].rstrip() == pod_name
        except:
            raise Exception(f'error. file not found on node for file={filename} and pod={pod_name}. {sys.exc_info()[0]}')

    def write_file_to_node(self, node, mount='/var/opt/', root_loadbalancer=None, data=None):
        rb = None
        network, node = node.split('=')

        if root_loadbalancer is not None:
            rb = rootlb.Rootlb(host=root_loadbalancer, proxy_to_node=node)
        else:
            rb = self.rootlb

        self.rootlb = rb

        rb.write_file_to_node(node=node, mount=mount, data=data)
        

    def run_command_on_pod(self, pod_name, command, cluster_name, operator_name, root_loadbalancer=None):
        rb = None
        if root_loadbalancer is not None:
            rb = rootlb.Rootlb(host=root_loadbalancer, kubeconfig=f'{cluster_name}.{operator_name}.kubeconfig')
        else:
            rb = self.rootlb

        pod = rb.get_pod(pod_name)
        return rb.run_command_on_pod(pod, command)

    def run_command_on_container(self, container_name, command, cluster_name, operator_name, root_loadbalancer=None):
        rb = None
        if root_loadbalancer is not None:
            rb = rootlb.Rootlb(host=root_loadbalancer, kubeconfig=f'{cluster_name}.{operator_name}.kubeconfig')
        else:
            rb = self.rootlb

        container_name = rb.get_docker_container_id(name=container_name)
        return rb.run_command_on_container(container_name[0], command)

    def get_dns_ip(self, dns_name):
        cf = CloudFlare.CloudFlare(email=self.cf_user, token=self.cf_token)

        try:
            logging.info(f'getting cloudflare zoneid for zone={self.cf_zone_name}')
            zoneid = cf.zones.get(params = {'name':self.cf_zone_name,'per_page':1})[0]['id']
            logging.info(f'found zoneid={zoneid} for zone={self.cf_zone_name}')
        except CloudFlare.exceptions.CloudFlareAPIError as e:
            #raise Exception(r'/zones.get %d %s - api call failed' % (e, e))
            raise Exception(f'cloudlflare exception get zones failed: {e}')
        except Exception as e:
            #exit('/zones.get - %s - api call failed' % (e))
            raise Exception(f'exception get zones failed: {e}')

        try:
            logging.info(f'getting cloudflare dns record for dns={dns_name}')
            dns_ip = cf.zones.dns_records.get(zoneid, params = {'name':dns_name})[0]['content']
            logging.info(f'found name={dns_name} ip={dns_ip}')
        except CloudFlare.exceptions.CloudFlareAPIError as e:
            #exit('/zones/dns_records.get %d %s - api call failed' % (e, e))
            raise Exception(f'cloudlflaire exception get dns record failed: {sys.exc_info()[0]}')

        return dns_ip

    def convert_govc_to_dictionary(self, output):
        output_list = output.rstrip().split('\n')

        output_dict = {}
        for line in output_list:
          line_split = line.split(':')
          #print('*WARN*', line)
          #print('*WARN*', line_split)
          output_dict[line_split[0].strip()] = line_split[1].strip()

        return output_dict

    def alert_receiver_email_should_be_received(self, email_address, email_password, alert_receiver_name, alert_type, alert_name, region=None, app_name=None, app_version=None, developer_org_name=None, cloudlet_name=None, operator_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, port=None, status=None, scope=None, description=None, title=None, receiver_type=None, pagerduty_status=None, wait=30):
        return self.alert_receiver.verify_email(email_address=email_address, email_password=email_password, alert_receiver_name=alert_receiver_name, alert_type=alert_type, alert_name=alert_name, region=region, app_name=app_name, app_version=app_version, developer_org_name=developer_org_name, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, status=status, port=port, scope=scope, description=description, title=title, receiver_type=receiver_type, pagerduty_status=pagerduty_status, wait=wait)

    def alert_receiver_slack_message_should_be_received(self, alert_type, alert_name, alert_receiver_name, region=None, app_name=None, app_version=None, developer_org_name=None, cloudlet_name=None, operator_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, status=None, port=None, scope=None, description=None, title=None, wait=30):
        return self.alert_receiver.verify_slack(alert_type=alert_type, alert_name=alert_name, region=region, alert_receiver_name=alert_receiver_name, app_name=app_name, app_version=app_version, developer_org_name=developer_org_name, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, status=status, port=port, scope=scope, description=description, title=title, wait=wait)

    def alert_receiver_email_for_firing_appinstdown_healthcheckfailserverfail_should_be_received(self, email_address, email_password, region=None, alert_type='FIRING', alert_receiver_name=None, app_name=None, app_version=None, developer_org_name=None, cloudlet_name=None, operator_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, port=None, description=None, title=None, receiver_type='email', pagerduty_status=None, wait=30):
        self.alert_receiver_email_should_be_received(email_address=email_address, email_password=email_password, alert_receiver_name=alert_receiver_name, alert_type=alert_type, alert_name='AppInstDown', region=region, app_name=app_name, app_version=app_version, developer_org_name=developer_org_name, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, status='HealthCheckFailServerFail', port=port, scope='Application', description='Application server port is not responding', title='AppInstDown', receiver_type=receiver_type, pagerduty_status=pagerduty_status, wait=wait)

    def alert_receiver_email_for_resolved_appinstdown_healthcheckfailserverfail_should_be_received(self, email_address, email_password, region=None, alert_type='RESOLVED', alert_receiver_name=None, app_name=None, app_version=None, developer_org_name=None, cloudlet_name=None, operator_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, port=None, description=None, title=None, receiver_type='email', pagerduty_status=None, wait=180):
        self.alert_receiver_email_should_be_received(email_address=email_address, email_password=email_password, alert_type=alert_type, alert_receiver_name=alert_receiver_name, alert_name='AppInstDown', region=region, app_name=app_name, app_version=app_version, developer_org_name=developer_org_name, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, status='HealthCheckFailServerFail', port=port, scope='Application', description='Application server port is not responding', title='AppInstDown', receiver_type=receiver_type, pagerduty_status=pagerduty_status, wait=wait)

    def alert_receiver_email_for_firing_appinstdown_healthcheckfailrootlboffline_should_be_received(self, email_address, email_password, region=None, alert_type='FIRING', alert_receiver_name=None, app_name=None, app_version=None, developer_org_name=None, cloudlet_name=None, operator_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, port=None, description=None, title=None, receiver_type='email', pagerduty_status=None, wait=30):
        self.alert_receiver_email_should_be_received(email_address=email_address, email_password=email_password, alert_receiver_name=alert_receiver_name, alert_type=alert_type, alert_name='AppInstDown', region=region, app_name=app_name, app_version=app_version, developer_org_name=developer_org_name, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, status='HealthCheckFailRootlbOffline', port=port, scope='Application', description='Root Load Balancer is not responding', title='AppInstDown', receiver_type=receiver_type, pagerduty_status=pagerduty_status, wait=wait)

    def alert_receiver_email_for_resolved_appinstdown_healthcheckfailrootlboffline_should_be_received(self, email_address, email_password, region=None, alert_type='RESOLVED', alert_receiver_name=None, app_name=None, app_version=None, developer_org_name=None, cloudlet_name=None, operator_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, port=None, description=None, title=None, receiver_type='email', pagerduty_status=None, wait=180):
        self.alert_receiver_email_should_be_received(email_address=email_address, email_password=email_password, alert_type=alert_type, alert_receiver_name=alert_receiver_name, alert_name='AppInstDown', region=region, app_name=app_name, app_version=app_version, developer_org_name=developer_org_name, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, status='HealthCheckFailRootlbOffline', port=port, scope='Application', description='Root Load Balancer is not responding', title='AppInstDown', receiver_type=receiver_type, pagerduty_status=pagerduty_status, wait=wait)

    def alert_receiver_pagerduty_email_for_firing_appinstdown_healthcheckfailserverfail_should_be_received(self, email_address, email_password, region=None, alert_receiver_name=None, app_name=None, app_version=None, developer_org_name=None, cloudlet_name=None, operator_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, port=None, description=None, title=None, wait=30):
        self.alert_receiver_email_for_firing_appinstdown_healthcheckfailserverfail_should_be_received(email_address=email_address, email_password=email_password, region=region, alert_type='FIRING', alert_receiver_name=alert_receiver_name, app_name=app_name, app_version=app_version, developer_org_name=developer_org_name, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, port=port, description='Application server port is not responding', title='AppInstDown', receiver_type='pagerduty', pagerduty_status='Triggered', wait=wait)

    def alert_receiver_pagerduty_email_for_resolved_appinstdown_healthcheckfailserverfail_should_be_received(self, email_address, email_password, region=None, alert_receiver_name=None, app_name=None, app_version=None, developer_org_name=None, cloudlet_name=None, operator_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, port=None, description=None, title=None, wait=30):
        self.alert_receiver_email_for_resolved_appinstdown_healthcheckfailserverfail_should_be_received(email_address=email_address, email_password=email_password, region=region, alert_type='RESOLVED', alert_receiver_name=alert_receiver_name, app_name=app_name, app_version=app_version, developer_org_name=developer_org_name, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, port=port, description='Application server port is not responding', title='AppInstDown', receiver_type='pagerduty', pagerduty_status='Resolved', wait=wait)

    def alert_receiver_pagerduty_email_for_firing_appinstdown_healthcheckfailrootlboffline_should_be_received(self, email_address, email_password, region=None, alert_receiver_name='PagerDuty ALERT', app_name=None, app_version=None, developer_org_name=None, cloudlet_name=None, operator_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, port=None, description=None, title=None, wait=30):
        self.alert_receiver_email_for_firing_appinstdown_healthcheckfailrootlboffline_should_be_received(email_address=email_address, email_password=email_password, region=region, alert_type='FIRING', alert_receiver_name=alert_receiver_name, app_name=app_name, app_version=app_version, developer_org_name=developer_org_name, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, port=port, description='Root Load Balancer is not responding', title='AppInstDown', receiver_type='pagerduty', pagerduty_status='Triggered', wait=wait)
        #self.alert_receiver_email_should_be_received(email_address=email_address, email_password=email_password, alert_receiver_name=alert_receiver_name, alert_type='ALERT', alert_name='AppInstDown', region=region, app_name=app_name, app_version=app_version, developer_org_name=developer_org_name, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, status='HealthCheckFailRootlbOffline', port=port, scope='Application', description='Root Load Balancer is not responding', title='AppInstDown', wait=wait)

    def alert_receiver_pagerduty_email_for_resolved_appinstdown_healthcheckfailrootlboffline_should_be_received(self, email_address, email_password, region=None, alert_receiver_name='PagerDuty ALERT', app_name=None, app_version=None, developer_org_name=None, cloudlet_name=None, operator_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, port=None, description=None, title=None, wait=180):
        self.alert_receiver_email_for_resolved_appinstdown_healthcheckfailrootlboffline_should_be_received(email_address=email_address, email_password=email_password, region=region, alert_type='FIRING', alert_receiver_name=alert_receiver_name, app_name=app_name, app_version=app_version, developer_org_name=developer_org_name, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, port=port, description='Root Load Balancer is not responding', title='AppInstDown', receiver_type='pagerduty', pagerduty_status='Resolved', wait=wait)
        #self.alert_receiver_email_should_be_received(email_address=email_address, email_password=email_password, alert_type='ALERT', alert_receiver_name=alert_receiver_name, alert_name='AppInstDown', region=region, app_name=app_name, app_version=app_version, developer_org_name=developer_org_name, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, status='HealthCheckFailRootlbOffline', port=port, scope='Application', description='Root Load Balancer is not responding', title='AppInstDown', wait=wait)

    def alert_receiver_slack_message_for_firing_appinstdown_healthcheckfailserverfail_should_be_received(self, region=None, alert_receiver_name=None, app_name=None, app_version=None, developer_org_name=None, cloudlet_name=None, operator_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, status=None, description=None, title=None, port=None, wait=30):
        self.alert_receiver_slack_message_should_be_received(alert_type='FIRING', alert_name='AppInstDown', alert_receiver_name=alert_receiver_name, region=region, app_name=app_name, app_version=app_version, developer_org_name=developer_org_name, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, status='HealthCheckFailServerFail', port=port, scope='Application', description='Application server port is not responding', title='AppInstDown', wait=wait)

    def alert_receiver_slack_message_for_resolved_appinstdown_healthcheckfailserverfail_should_be_received(self, region=None, alert_receiver_name=None, app_name=None, app_version=None, developer_org_name=None, cloudlet_name=None, operator_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, status=None, port=None, wait=30):
        self.alert_receiver_slack_message_should_be_received(alert_type='RESOLVED', alert_name='AppInstDown', alert_receiver_name=alert_receiver_name, region=region, app_name=app_name, app_version=app_version, developer_org_name=developer_org_name, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, status='HealthCheckFailServerFail', port=port, scope='Application', description='Application server port is not responding', title='AppInstDown', wait=wait)

    def alert_receiver_slack_message_for_firing_appinstdown_healthcheckfailrootlboffline_should_be_received(self, region=None, alert_receiver_name=None, app_name=None, app_version=None, developer_org_name=None, cloudlet_name=None, operator_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, status=None, port=None, wait=30):
        self.alert_receiver_slack_message_should_be_received(alert_type='FIRING', alert_name='AppInstDown', alert_receiver_name=alert_receiver_name, region=region, app_name=app_name, app_version=app_version, developer_org_name=developer_org_name, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, status='HealthCheckFailRootlbOffline', port=port, scope='Application', description='Root Load Balancer is not responding', title='AppInstDown', wait=wait)

    def alert_receiver_slack_message_for_resolved_appinstdown_healthcheckfailrootlboffline_should_be_received(self, alert_receiver_name=None, region=None, app_name=None, app_version=None, developer_org_name=None, cloudlet_name=None, operator_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, status=None, port=None, wait=30):
        self.alert_receiver_slack_message_should_be_received(alert_type='RESOLVED', alert_name='AppInstDown', alert_receiver_name=alert_receiver_name, region=region, app_name=app_name, app_version=app_version, developer_org_name=developer_org_name, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, status='HealthCheckFailRootlbOffline', port=port, scope='Application', description='Root Load Balancer is not responding', title='AppInstDown', wait=wait)

    def alert_receiver_email_for_firing_cloudletdown_should_be_received(self, email_address, email_password, region=None, alert_type='FIRING', alert_receiver_name=None, cloudlet_name=None, operator_org_name=None, receiver_type='email', wait=30):
        self.alert_receiver_email_should_be_received(email_address=email_address, email_password=email_password, alert_receiver_name=alert_receiver_name, alert_type=alert_type, alert_name='CloudletDown', region=region, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, scope='Cloudlet', receiver_type=receiver_type, wait=wait)

    def alert_receiver_email_for_resolved_cloudletdown_should_be_received(self, email_address, email_password, region=None, alert_type='RESOLVED', alert_receiver_name=None, cloudlet_name=None, operator_org_name=None, wait=180):
        self.alert_receiver_email_should_be_received(email_address=email_address, email_password=email_password, alert_type=alert_type, alert_receiver_name=alert_receiver_name, alert_name='CloudletDown', region=region, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, scope='Cloudlet', wait=wait)

    def alert_receiver_slack_message_for_firing_cloudletdown_should_be_received(self, region=None, alert_receiver_name=None, cloudlet_name=None, operator_org_name=None, wait=30):
        self.alert_receiver_slack_message_should_be_received(alert_type='FIRING', alert_name='CloudletDown', alert_receiver_name=alert_receiver_name, region=region, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, scope='Cloudlet', description='Cloudlet resource manager is offline', title='CloudletDown', wait=wait)

    def alert_receiver_slack_message_for_resolved_cloudletdown_should_be_received(self, region=None, alert_receiver_name=None, cloudlet_name=None, operator_org_name=None, wait=30):
        self.alert_receiver_slack_message_should_be_received(alert_type='RESOLVED', alert_name='CloudletDown', alert_receiver_name=alert_receiver_name, region=region, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, scope='Cloudlet', description='Cloudlet resource manager is offline', title='CloudletDown', wait=wait)

    def alert_receiver_pagerduty_email_for_firing_cloudletdown_should_be_received(self, email_address, email_password, region=None, alert_receiver_name=None, cloudlet_name=None, operator_org_name=None, wait=30):
        self.alert_receiver_email_for_firing_cloudletdown_should_be_received(email_address=email_address, email_password=email_password, alert_receiver_name=alert_receiver_name, alert_type='FIRING', region=region, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, receiver_type='pagerduty', wait=wait)

    def alert_receiver_pagerduty_email_for_resolved_cloudletdown_should_be_received(self, email_address, email_password, region=None, alert_receiver_name='PagerDuty ALERT', cloudlet_name=None, operator_org_name=None, wait=30):
        self.alert_receiver_email_for_resolved_cloudletdown_should_be_received(email_address=email_address, email_password=email_password, alert_receiver_name=alert_receiver_name, alert_type='RESOLVED', region=region, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, wait=wait)

    def alert_receiver_email_for_firing_appinstdown_healthcheckfailrootlboffline_should_not_be_received(self, email_address, email_password, region=None, alert_receiver_name=None, app_name=None, app_version=None, developer_org_name=None, cloudlet_name=None, operator_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, port=None, wait=30):
        try:
            self.alert_receiver_email_should_be_received(email_address=email_address, email_password=email_password, alert_receiver_name=alert_receiver_name, alert_type='FIRING', alert_name='AppInstDown', region=region, app_name=app_name, app_version=app_version, developer_org_name=developer_org_name, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, status='HealthCheckFailRootlbOffline', port=port, wait=wait)
        except Exception as e:
            logger.info(f'email not found:{e}')
            return True

        raise Exception('alert receiver email for firing appinstdown healthcheckfailrootlboffline was received')

    def alert_receiver_email_for_resolved_appinstdown_healthcheckfailrootlboffline_should_not_be_received(self, email_address, email_password, region=None, alert_receiver_name=None, app_name=None, app_version=None, developer_org_name=None, cloudlet_name=None, operator_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, port=None, wait=180):
        try:
            self.alert_receiver_email_should_be_received(email_address=email_address, email_password=email_password, alert_type='RESOLVED', alert_receiver_name=alert_receiver_name, alert_name='AppInstDown', region=region, app_name=app_name, app_version=app_version, developer_org_name=developer_org_name, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, status='HealthCheckFailRootlbOffline', port=port, wait=wait)
        except Exception as e:
            logger.info(f'email not found:{e}')
            return True

        raise Exception('alert receiver email for resolved appinstdown healthcheckfailrootlboffline was received')

    def alert_receiver_slack_message_for_firing_appinstdown_healthcheckfailrootlboffline_should_not_be_received(self, region=None, alert_receiver_name=None, app_name=None, app_version=None, developer_org_name=None, cloudlet_name=None, operator_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, status=None, port=None, wait=30):
        try:
            self.alert_receiver_slack_message_should_be_received(alert_type='FIRING', alert_name='AppInstDown', alert_receiver_name=alert_receiver_name, region=region, app_name=app_name, app_version=app_version, developer_org_name=developer_org_name, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, status='HealthCheckFailRootlbOffline', port=port, wait=wait)
        except Exception as e:
            logger.info(f'slack message not found:{e}')
            return True

        raise Exception('alert receiver slack message for firing appinstdown healthcheckfailrootlboffline was received')

    def alert_receiver_slack_message_for_resolved_appinstdown_healthcheckfailrootlboffline_should_not_be_received(self, alert_receiver_name=None, region=None, app_name=None, app_version=None, developer_org_name=None, cloudlet_name=None, operator_org_name=None, cluster_instance_name=None, cluster_instance_developer_org_name=None, status=None, port=None, wait=30):
        try:
            self.alert_receiver_slack_message_should_be_received(alert_type='RESOLVED', alert_name='AppInstDown', alert_receiver_name=alert_receiver_name, region=region, app_name=app_name, app_version=app_version, developer_org_name=developer_org_name, cloudlet_name=cloudlet_name, operator_org_name=operator_org_name, cluster_instance_name=cluster_instance_name, cluster_instance_developer_org_name=cluster_instance_developer_org_name, status='HealthCheckFailRootlbOffline', port=port, wait=wait)
        except Exception as e:
            logger.info(f'slack message not found:{e}')
            return True

        raise Exception('alert receiver slack message for resolved appinstdown healthcheckfailrootlboffline was received')

