import logging
import socket
import sys
import os
import subprocess
import time
import requests
import re

import rootlb
import kubernetes
import shared_variables

class MexApp(object):
    def __init__(self):
        self.kubeconfig_dir = os.getenv('HOME') + '/.mobiledgex'
        self.rootlb = None
        
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

    def ping_tcp_port(self, host, port, wait_time=0):
        data = 'ping'
        exp_return_data = 'pong'
        data_size = sys.getsizeof(bytes(data, 'utf-8'))
        
        client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        client_socket.connect((host, int(port)))
        print('cccccc')
        return_data = ''
        try:
            logging.debug('sending data')
            client_socket.sendall(bytes(data, encoding='utf-8'))
            return_data = client_socket.recv(data_size)
            logging.debug('data recevied back:' + return_data.decode('utf-8'))
            logging.info(f'holding port for {wait_time}s')
            time.sleep(wait_time)
            client_socket.close()
        except Exception as e:
            print('caught exception')
            #print(sys.exc_info())
            #e = sys.exc_info()[0]
            client_socket.close()
            raise Exception('error=', e)
            
        if return_data.decode('utf-8') != exp_return_data:
            raise Exception('correct data not received from server. expected=' + exp_return_data + ' got=' + return_data.decode('utf-8'))

    def make_http_request(self, host, port, page):
        url = f'http://{host}:{port}/{page}'
        logging.info(f'checking for {url}')

        resp = requests.get(url)
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
        
        self.ping_udp_port(host, int(port))
        return True

    def tcp_port_should_be_alive(self, host, port, wait_time=0):
        logging.info('host:' + host + ' port:' + str(port))

        self.wait_for_dns(host)
        
        self.ping_tcp_port(host, port, wait_time)
        return True

    def http_port_should_be_alive(self, host, port, page):
        logging.info('host:' + host + ' port:' + str(port))

        self.wait_for_dns(host)
        
        resp = self.make_http_request(host, port, page)
        return True          

    def wait_for_dns(self, dns, wait_time=900):
        logging.info('waiting for dns=' + dns + ' to be ready')

        addr = None
        for t in range(wait_time):
            try:
                addr = socket.gethostbyname(dns)
                logging.info('dns is ready at ' + addr)
                return
            except OSError as err:
                logging.debug(f'dns not ready yet:{err}')
                time.sleep(1)
            except:
                logging.debug(f'dns not ready yet:{sys.exc_info()[0]}')
                time.sleep(1)


        return addr
    
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

    def wait_for_docker_container_to_be_running(self, root_loadbalancer=None, docker_image=None, wait_time=600):

        self.wait_for_dns(root_loadbalancer)
        
        rb = None
        if root_loadbalancer is not None:
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

        try:
            rb.mount_exists_on_pod(pod=pod_name, mount=mount)
            logging.info(f'mount={mount} exists on pod={pod_name}')
        except:
            raise Exception(f'mount={mount} DOES NOT exist on pod={pod_name}')
        try:
            rb.write_file_to_pod(pod=pod_name, mount=mount)
            logging.info(f'successfully wrote file to pod={pod_name} on mount={mount}')
        except:
            raise Exception(f'error writing file to mount={mount} and pod={pod_name}. {sys.exc_info()[0]}')

        node_file = f'/data/{cluster_name}_node.txt'
        try:
            output = rb.read_file_from_pod(pod=pod_name, filename=node_file)
            #logging.info('output', output)
            assert output[0].rstrip() == cluster_name
        except:
            raise Exception(f'error. file not found on node for file={node_file} and pod={pod_name}. {sys.exc_info()[0]}')


        
    def write_file_to_node(self, node, mount='/var/opt/', root_loadbalancer=None, data=None):
        rb = None
        if root_loadbalancer is not None:
            rb = rootlb.Rootlb(host=root_loadbalancer)
        else:
            rb = self.rootlb

        rb.write_file_to_node(node=node, mount=mount, data=data)
        
