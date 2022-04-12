#!/usr/bin/python3
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


import socket
import _thread
# import datetime
import time
import http.server
import socketserver
# import pprint
import tornado.ioloop
# from tornado.iostream import IOStream
import tornado.httpserver
import tornado.websocket
import tornado.ioloop
import tornado.web
import sys
import logging

http_port = 8085

# protocol = 'tcp'
outfile = 'server_ping_outfile.txt'

thread_count = 1

server_cert = '/Users/andyanderson/go/src/github.com/mobiledgex/edge-cloud/tls/out/mex-server.crt'
server_key = '/Users/andyanderson/go/src/github.com/mobiledgex/edge-cloud/tls/out/mex-server.key'
client_cert = '/Users/andyanderson/go/src/github.com/mobiledgex/edge-cloud/tls/out/mex-client.crt'
client_key = '/Users/andyanderson/go/src/github.com/mobiledgex/edge-cloud/tls/out/mex-client.key'

ca_cert = '~/mex-ca.crt'
ca_key = '~/mex-ca.key'

logging.basicConfig(format="%(asctime)s line:%(lineno)d %(message)s",
                    level=logging.INFO,
                    datefmt='%d-%b-%y %H:%M:%S',
                    handlers=[logging.FileHandler(outfile),
                              logging.StreamHandler()])

logger = logging.getLogger(__name__)


class MyHttpRequestHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        print('path=', self.path)
        if self.path != '/automation.html':
            self.path = 'pagenotfound.html'
        return http.server.SimpleHTTPRequestHandler.do_GET(self)


# def writefile(s):
#    with open(outfile, 'a+') as f:
#        datenow = str(datetime.datetime.now())
#        #print(datenow + ' ' + s, flush=True)
#        logger.info(s)
#        f.write(datenow + ' ' + s + '\n')

def start_http_server(thread_name, port):
    # handler = http.server.SimpleHTTPRequestHandler
    handler = MyHttpRequestHandler

    logger.info('start_http_server thread={} protocol=http servertport={}'.format(thread_name, port))
    httpd = socketserver.TCPServer(("", port), handler)
    httpd.serve_forever()
    # with socketserver.TCPServer(("", port), handler) as httpd:
    #    writefile('thread={} protocol=http servertport={} server starting'.format(thread_name, port))
    #    httpd.serve_forever()


def start_udp_ping(thread_name, port):
    ssocket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    ssocket.bind(('', port))
    logger.info('start_udp_ping thread={} protocol=udp serverport={}'.format(thread_name, port))

    while True:
        data, client_addr = ssocket.recvfrom(port)
        logger.info(f'start_udp_ping recved udp data from address={client_addr}thread={thread_name} port={port} data={data}')

        try:
            decoded_data = data.decode('utf8', 'strict')
            if decoded_data == 'exit':
                logger.info('start_udp_ping shutdown/close socket thread={} port={}'.format(thread_name, port))
                ssocket.sendto(bytes('bye', encoding='utf-8'), client_addr)
                ssocket.shutdown(socket.SHUT_RDWR)
                ssocket.close()
                sys.exit()
            elif decoded_data.startswith('ping'):
                logger.info(f'start_udp_ping ping received thread={thread_name} port={port} data={decoded_data}')
                cmd, app_name = decoded_data.split(':')
                if app_name != 'None':
                    if not hostname.startswith(app_name):
                        ssocket.sendto(bytes(f'appname={app_name} doesnt match hostname={hostname}'), encoding='utf-8')
                        logger.error(f'app name {app_name} doesnt match hostname {hostname}')
                    else:
                        logger.info(f'start_udp_ping app={app_name} matches hostname={hostname}')
                        ssocket.sendto(bytes('pong', encoding='utf-8'), client_addr)
                else:
                    ssocket.sendto(bytes('pong', encoding='utf-8'), client_addr)
                    logger.info('sent data')
            else:
                ssocket.sendto(bytes('unknown', encoding='utf-8'), client_addr)

        except UnicodeDecodeError as e:
            logger.error(f'start_udp_ping unicodecode error from address={client_addr} thread={thread_name} port={port} data={data}: {e}')
            continue
        except Exception as e:
            logger.error(f'start_udp_ping unknown exception error from address={client_addr} thread={thread_name} port={port} data={data}: {e}')
            continue

        # datasplit = decoded_data.split(':')
        # ssocket.sendto(bytes(f'pong:{datasplit[1]}', encoding='utf-8'), client_addr)
        # print('recved', data)


def start_tcp_ping(thread_name, port):
    logger.info('start_tcp_ping thread={} protocol=tcp serverport={}'.format(thread_name, port))

    try:
        ssocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        ssocket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)   # SO_REUSEADDR flag tells the kernel to reuse a local socket in TIME_WAIT state, without waiting for its natural timeout to expire
        ssocket.bind(('', int(port)))
        ssocket.listen(1)
    except socket.error as e:
        logger.error('start_tcp_ping error starting socket thread={} protocol=tcp serverport={} error={}'.format(thread_name, port, e))
    except socket.gaierror as e:
        logger.error('start_tcp_ping error starting socket thread={} protocol=tcp serverport={} error={}'.format(thread_name, port, e))
    except Exception as e:
        logger.error('start_tcp_ping error starting socket thread={} protocol=tcp serverport={} error={}'.format(thread_name, port, e))

    while True:
        conn, addr = ssocket.accept()
        while True:
            # print('waiting for data')
            try:
                data = conn.recv(1024)
            except Exception as e:
                logger.error(f'caught exception receiving data {e}')
                break
            # print('conn after recv')
            if not data:
                # print('no data')
                break

            logger.info(f'start_tcp_ping recved tcp data from address={addr} thread={thread_name} port={port} data={data}')

            try:
                decoded_data = data.decode('utf8', 'strict')
                if decoded_data == 'exit':
                    logger.info(f'start_tcp_ping shutdown/close socket thread={thread_name} port={port}')
                    conn.sendall(bytes('bye', encoding='utf-8'))
                    ssocket.shutdown(socket.SHUT_RDWR)
                    ssocket.close()
                    sys.exit()
                elif decoded_data == 'version':
                    logger.info(f'start_tcp_ping version requested thread={thread_name} port={port}')
                    version_data = '0'
                    with open('VERSION') as version_file:
                        version_data = version_file.read()
                    logger.info(f'start_tcp_ping version is {version_data} thread={thread_name} port={port}')
                    conn.sendall(bytes(version_data, encoding='utf-8'))
                elif 'writefile' in decoded_data:
                    command, path, data = decoded_data.split(':')
                    logger.info(f'write {data} to {path}')
                    read_data = ''
                    try:
                        with open(path, 'a') as data_file:
                            data_file.write(data)
                        with open(path, 'r') as data_file_read:
                            read_data = data_file_read.read()
                    except Exception as e:
                        logger.error(f'writefile error {e}')
                        read_data = f'error: {e}'
                    conn.sendall(bytes(f'{path},{read_data}', encoding='utf-8'))
                elif 'readfile' in decoded_data:
                    command, path = decoded_data.split(':')
                    logger.info(f'read from {path}')
                    read_data = ''
                    try:
                        with open(path, 'r') as data_file_read:
                            read_data = data_file_read.read()
                    except Exception as e:
                        logger.error(f'readfile error {e}')
                        read_data = f'error: {e}'
                    conn.sendall(bytes(f'{path},{read_data}', encoding='utf-8'))
                elif decoded_data.startswith('ping'):
                    logger.info(f'start_tcp_ping ping received thread={thread_name} port={port} data={decoded_data}')
                    cmd, app_name = decoded_data.split(':')
                    if app_name != 'None':
                        if not hostname.startswith(app_name):
                            conn.sendall(bytes(f'appname={app_name} doesnt match hostname={hostname}', encoding='utf-8'))
                            logger.error(f'app name {app_name} doesnt match hostname {hostname}')
                        else:
                            logger.info(f'start_tcp_ping app={app_name} matches hostname={hostname}')
                            conn.sendall(bytes('pong', encoding='utf-8'))
                    else:
                        conn.sendall(bytes('pong', encoding='utf-8'))
                        logger.info('sent data')
                else:
                    conn.sendall(bytes('unknown', encoding='utf-8'))
            except UnicodeDecodeError as e:
                logger.error(f'start_tcp_ping unicodecode error from address={addr} thread={thread_name} port={port} data={data}: {e}')
                continue
            except Exception as e:
                logger.error(f'start_tcp_ping unknown exception error from address={addr} thread={thread_name} port={port} data={data}: {e}')
                continue

    #    print('recved', data)


def start_port_thread(thread_name, port):
    global thread_count
    ssocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    ssocket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)   # SO_REUSEADDR flag tells the kernel to reuse a local socket in TIME_WAIT state, without waiting for its natural timeout to expire
    ssocket.bind(('', port))
    ssocket.listen(1)
    logger.info('start_port_thread thread={} protocol=tcp port={}'.format(thread_name, port))

    port_start = 0
    while True:
        conn, addr = ssocket.accept()
        while True:
            data = conn.recv(1024).decode('utf8')
            if not data:
                break

            logger.info('start_port_thread received tcp data from thread={} port={} data={}'.format(thread_name, port, data))

            try:
                protocol, port_start = data.split(':')
            except Exception:
                logger.error('error: split failed for data=' + data)
                conn.sendall(bytes('error', encoding='utf-8'))
                break

            try:
                if protocol == 'tcp':
                    logger.info('start_port_thread starting tcp thread thread={} port={}'.format('Thread-' + str(thread_count), port_start))
                    _thread.start_new_thread(start_tcp_ping, ('Thread-' + str(thread_count), port_start))
                    thread_count += 1
                elif protocol == 'udp':
                    logger.info('start_port_thread starting udp thread thread={} port={}'.format('Thread-' + str(thread_count), port_start))
                    _thread.start_new_thread(start_udp_ping, ('Thread-' + str(thread_count), port_start))
                    thread_count += 1
            except Exception:
                logger.error('start_port_thread error: start thread failed thread={} port={}'.format('Thread-' + str(thread_count), port))
                conn.sendall(bytes('error', encoding='utf-8'))
                break

            conn.sendall(bytes('started', encoding='utf-8'))
    #    print('recved', data)


class WSHandler(tornado.websocket.WebSocketHandler):
    def open(self):
        print('new connection')

    def on_message(self, message):
        if (isinstance(message, str)):
            print('message received:  %s' % message)
            # Reverse Message and send it back
            print('sending back message: %s' % message[::-1])
            self.write_message(message[::-1])
        else:
            print('Binary message received:  %s' % message)
            # Send the Message  back
            print('sending back message: %s' % message)
            self.write_message(message, binary=True)

    def on_close(self):
        print('connection closed')

    def check_origin(self, origin):
        return True


application = tornado.web.Application([
    (r'/ws', WSHandler)
])

try:
    hostname = socket.gethostname()
    logger.info(f'hostname={hostname}')
except Exception as e:
    logger.error(f'gethostname failed with {e}')

logger.info('starting http thread')
_thread.start_new_thread(start_http_server, ('Thread-' + str(thread_count), http_port))
thread_count += 1

logger.info('starting udp thread')
_thread.start_new_thread(start_udp_ping, ('Thread-' + str(thread_count), 2015))
thread_count += 1
_thread.start_new_thread(start_udp_ping, ('Thread-' + str(thread_count), 2016))
thread_count += 1

logger.info('starting tcp thread')
_thread.start_new_thread(start_tcp_ping, ('Thread-' + str(thread_count), 2015))
thread_count += 1
_thread.start_new_thread(start_tcp_ping, ('Thread-' + str(thread_count), 2016))
thread_count += 1
_thread.start_new_thread(start_port_thread, ('Thread-' + str(thread_count), 4015))
thread_count += 1
_thread.start_new_thread(start_tcp_ping, ('Thread-' + str(thread_count), 8000))  # used to be used by backend but customer wanted to use it for app. EDGECLOUD-3833
thread_count += 1

logger.info('starting websocket server')
http_server = tornado.httpserver.HTTPServer(application)
http_server.listen(3765)
myIP = socket.gethostbyname(socket.gethostname())
logger.info(f'websocket Server Started at {myIP}')
logger.info('all threads started')

tornado.ioloop.IOLoop.instance().start()

while 1:
    time.sleep(1)
