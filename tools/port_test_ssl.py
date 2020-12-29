#!/usr/local/bin/python3

import os
import sys
import logging
import socket
import ssl

host = 'automationhawkinscloudlet.gddt.mobiledgex.net'
#host = 'mobiledgexapp1589470955-622824210.automationparadisecloudlet.gddt.mobiledgex.net'
tcp_port = 2015
tls = True

logging.basicConfig(format='%(asctime)s %(levelname)s %(funcName)s line:%(lineno)d - %(message)s',datefmt='%d-%b-%y %H:%M:%S', level=logging.DEBUG)

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

def ping_tcp_port(host, port, tls=False):
    data = 'ping'
    exp_return_data = 'pong'
    data_size = sys.getsizeof(bytes(data, 'utf-8'))

    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client_socket.settimeout(10)
    sock = client_socket

    if tls:
       #context = ssl.create_default_context()
       context = ssl.SSLContext()
       context.verify_mode = ssl.CERT_NONE
       context.check_hostname = False
   
       sock = context.wrap_socket(client_socket)
    
    sock.connect((host, port))
    
    #client_socket.connect((host, int(port)))
    print('cccccc')
    return_data = ''
    try:
        logging.debug('sending data')
        #client_socket.sendall(bytes(data, encoding='utf-8'))
        sock.sendall(bytes(data, encoding='utf-8'))
        #return_data = client_socket.recv(data_size)
        return_data = sock.recv(data_size)

        print('data recevied back:' + return_data.decode('utf-8'))
        sock.close()
    except Exception as e:
        print('caught exception')
        #print(sys.exc_info())
        #e = sys.exc_info()[0]
        sock.close()
        raise Exception('error=', e)
            
    if return_data.decode('utf-8') != exp_return_data:
        raise Exception('correct data not received from server. expected=' + exp_return_data + ' got=' + return_data.decode('utf-8'))

def udp_port_should_be_alive(host, port):
    logging.info('host:' + host + ' port:' + str(port))

    ping_udp_port(host, int(port))
    return True

def tcp_port_should_be_alive(host, port, tls):
    logging.info('host:' + host + ' port:' + str(port))

    ping_tcp_port(host, port, tls)
    return True

tcp_port_should_be_alive(host, tcp_port, tls)
