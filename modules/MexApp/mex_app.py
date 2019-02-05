import logging
import socket
import sys
import os
import subprocess
import time

import rootlb
import kubernetes
import shared_variables

class MexApp(object):
    def __init__(self):
        self.kubeconfig_dir = os.getenv('HOME') + '/.mobiledgex'
        
    def ping_udp_port(self, host, port):
        data = 'ping'
        exp_return_data = 'pong'
        data_size = sys.getsizeof(bytes(data, 'utf-8'))
        data_to_send = data.encode('ascii')

        client_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        client_socket.settimeout(1)

        return_data = ''
        try:
            client_socket.sendto(data_to_send,(host, int(port)))
            (return_data, addr) = client_socket.recvfrom(data_size)
            logging.info('received this data from {}:{}'.format(addr, return_data.decode('utf-8')))
            client_socket.close()
        except Exception as e:
            client_socket.close()
            raise Exception('error=', e)
            
        if return_data.decode('utf-8') != exp_return_data:
            raise Exception('correct data not received from server. expected=' + exp_return_data + ' got=' + return_data.decode('utf-8'))

    def ping_tcp_port(self, host, port):
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
            client_socket.close()
        except Exception as e:
            print('caught exception')
            #print(sys.exc_info())
            #e = sys.exc_info()[0]
            client_socket.close()
            raise Exception('error=', e)
            
        if return_data.decode('utf-8') != exp_return_data:
            raise Exception('correct data not received from server. expected=' + exp_return_data + ' got=' + return_data.decode('utf-8'))

    def udp_port_should_be_alive(self, host, port):
        logging.info('host:' + host + ' port:' + str(port))

        self.wait_for_dns(host)
        
        self.ping_udp_port(host, int(port))
        return True

    def tcp_port_should_be_alive(self, host, port):
        logging.info('host:' + host + ' port:' + str(port))
        self.ping_tcp_port(host, port)
        return True

    def wait_for_dns(self, dns, wait_time=600):
        logging.info('waiting for dns=' + dns + ' to be ready')

        addr = None
        for t in range(wait_time):
            try:
                addr = socket.gethostbyname(dns)
                logging.info('dns is ready at ' + addr)
            except:
                logging.debug('dns not ready yet')
                time.sleep(1)

        return addr
    
    def wait_for_k8s_pod_to_be_running(self, root_loadbalancer=None, kubeconfig=None, wait_time=600):

        rb = None
        if root_loadbalancer is not None:
            rb = rootlb.Rootlb(host=root_loadbalancer)
        else:
            rb = kubernetes.Kubernetes(self.kubeconfig_dir + '/' + kubeconfig)
            
        #shared_variables.cluster_name_default = 'cluster1544640562'
        #kubeconfig_file = self.kubeconfig_dir + '/' + shared_variables.cluster_name_default + '.kubeconfig'
        #kubeconfig_file = self.kubeconfig_dir + '/' + kubeconfig
        #logging.info('kubeconfig=' + kubeconfig_file)

        #kubectl_cmd = 'export KUBECONFIG={};kubectl get pods'.format(kubeconfig_file)
        #logging.info(kubectl_cmd)

        for t in range(wait_time):
            #kubectl_return = subprocess.run(kubectl_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
            #kubectl_out = kubectl_return.stdout.decode('utf-8')
            kubectl_out = rb.get_pods()
            logging.debug(kubectl_out)

            for line in kubectl_out:
                if line.split()[2] == 'Running':
                    logging.info('Found running pod:' + line)
                    return True;
            time.sleep(1)

        raise Exception('Running k8s pod not found')
