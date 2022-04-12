#!/usr/local/bin/python3
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


import os
import sys
import logging
import socket

host = 'andycpu.automationfrankfurtcloudlet.tdg.mobiledgex.net'
#host = '127.0.0.1'
tcp_port = 2017
cpu = 70

def ping_udp_port(host, port):
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
        client_socket.close()
    except Exception as e:
        client_socket.close()
        raise Exception('error=', e)
            
    if return_data.decode('utf-8') != exp_return_data:
        raise Exception('correct data not received from server. expected=' + exp_return_data + ' got=' + return_data.decode('utf-8'))

def ping_tcp_port(host, port):
    data = 'ping'
    exp_return_data = 'pong'
    data_size = sys.getsizeof(bytes(data, 'utf-8'))

    try:
       logging.debug(f'connecting to {host}:{port}')      
       client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
       client_socket.connect((host, int(port)))
    except Exception as e:
       logging.error(f'Error connectinng to socket')
       exit(1)
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

def set_cpu(host, port, cpu):
    data = f'load={cpu}'
    exp_return_data = 'pong'
    data_size = sys.getsizeof(bytes(data, 'utf-8'))

    try:
       logging.debug(f'connecting to {host}:{port}')

       client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
       client_socket.connect((host, int(port)))
    except Exception as e:
       logging.error(f'Error connectinng to socket')
       exit(1)

    print('cccccc')
    return_data = ''
    try:
        logging.debug('sending data')
        client_socket.sendall(bytes(data, encoding='utf-8'))
        return_data = client_socket.recv(data_size)
        print(f'xxx={return_data}')
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

def udp_port_should_be_alive(host, port):
    logging.info('host:' + host + ' port:' + str(port))

    ping_udp_port(host, int(port))
    return True

def tcp_port_should_be_alive(host, port):
    logging.info('host:' + host + ' port:' + str(port))

    ping_tcp_port(host, port)
    return True

#tcp_port_should_be_alive(host, tcp_port)
#set_cpu('andycpu.automationfrankfurtcloudlet.tdg.mobiledgex.net', 2017, 50)
set_cpu(host, tcp_port, cpu)

