#!/usr/local/bin/python3

import os
import sys
import logging
import socket
import _thread
import time

#host = '35.199.188.102'
#tcp_port = 2016

def ping_udp_port(host, port):
    data = 'ping'
    exp_return_data = 'pong'
    data_size = sys.getsizeof(bytes(data, 'utf-8'))
    data_to_send = data.encode('ascii')

    client_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    client_socket.settimeout(1)

    return_data = ''
    try:
        print(f'sending {data} to {host}:{port}', flush=True)
        client_socket.sendto(data_to_send,(host, int(port)))
        print(f'waiting for {exp_return_data}', flush=True)
        (return_data, addr) = client_socket.recvfrom(data_size)
        logging.info('received this data from {}:{}'.format(addr, return_data.decode('utf-8')))
        client_socket.close()
    except Exception as e:
        client_socket.close()
        raise Exception('error=', e)
            
    if return_data.decode('utf-8') != exp_return_data:
        raise Exception('correct data not received from server. expected=' + exp_return_data + ' got=' + return_data.decode('utf-8'))

def ping_tcp_port(host, port, hostname=None):
    data = f'ping:{hostname}'
    exp_return_data = 'pong'
    data_size = sys.getsizeof(bytes(data, 'utf-8'))

    print(f'opening tcp socket {host}:{port}', flush=True)      
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client_socket.settimeout(1)
    try:
        client_socket.connect((host, int(port)))
    except Exception as e:
        msg = f'error connecting to socket host={host} port={port} error={e}'
        print(msg)
        raise Exception(msg)

    return_data = ''
    try:
        print(f'sending data {data}', flush=True)
        client_socket.sendall(bytes(data, encoding='utf-8'))
        return_data = client_socket.recv(data_size)
        print('data recevied back:' + return_data.decode('utf-8'), flush=True)
        client_socket.close()
    except Exception as e:
        msg = f'error sending data host={host} port={port} error={e}'
        print(msg, flush=True)
        #print(sys.exc_info())
        #e = sys.exc_info()[0]
        client_socket.close()
        raise Exception(msg)
            
    if return_data.decode('utf-8') != exp_return_data:
        raise Exception('correct data not received from server. expected=' + exp_return_data + ' got=' + return_data.decode('utf-8'))

def udp_port_should_be_alive(host, port):
    logging.info('host:' + host + ' port:' + str(port))

    ping_udp_port(host, int(port))

def tcp_port_should_be_alive(host, port, hostname=None):
    print(f'host:{host} port:{port} hostname={hostname}', flush=True)

    ping_tcp_port(host, port, hostname)

def start_server(thread_name, server_port, hostname):
    ssocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    ssocket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)   # SO_REUSEADDR flag tells the kernel to reuse a local socket in TIME_WAIT state, without waiting for its natural timeout to expire
    ssocket.bind(('', server_port))
    ssocket.listen(1)
    print(f'thread={thread_name} protocol=tcp servertport={server_port}', flush=True)

    while True:
        conn, addr = ssocket.accept()
        while True:
            #print('waiting for data')
            data = conn.recv(1024).decode('utf-8')
            #print('conn after recv')
            if not data:
               #print('no data')
               break

            print('recved tcp data={} from thread={} port={}'.format(data, thread_name, server_port), flush=True)
            try:
               host,protocol,port = data.split(':')
            except Exception as e:
               print(f'error: split failed for data={data} {e}', flush=True)
               conn.sendall(bytes('error', encoding='utf-8')) 
               break

            try:
               if protocol == 'tcp':
                  tcp_port_should_be_alive(host, port, hostname)
               elif protocol == 'udp':
                  udp_port_should_be_alive(host, port, hostname)
            except Exception as e:
               print(f'error: send failed {e}', flush=True)
               conn.sendall(bytes('error', encoding='utf-8'))
               break
  
            conn.sendall(bytes('success', encoding='utf-8'))
    #    print('recved', data)

try:
    hostname = socket.gethostname()
    print(f'hostname={hostname}')
except Exception as e:
    print(f'gethostname failed with {e}')

print('starting server', flush=True)
_thread.start_new_thread(start_server, ("Thread-1", 3015, None))  # not sending hostname since it wont ever match egress simulator
print('server started', flush=True)

while 1:
   time.sleep(1)

