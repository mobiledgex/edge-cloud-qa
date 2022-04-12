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
#import random
import _thread
import datetime
import time
import http.server
import socketserver

http_port = 8085

#port = 2015
protocol = 'tcp'
#protocol = 'udp'
outfile = 'server_ping_outfile.txt'

#_thread.start_new_thread(start_ping, ("Thread-1", 2015))

def writefile(s):
    with open(outfile,'a+') as f:
        #print('writing')
        f.write(str(datetime.datetime.now()) + ' ' + s + '\n')

def start_http_server(thread_name, port):
    handler = http.server.SimpleHTTPRequestHandler

    writefile('thread={} protocol=http servertport={}'.format(thread_name, port))
    httpd = socketserver.TCPServer(("", port), handler)
    httpd.serve_forever()
    #with socketserver.TCPServer(("", port), handler) as httpd:
    #    writefile('thread={} protocol=http servertport={} server starting'.format(thread_name, port))
    #    httpd.serve_forever()

def start_udp_ping(thread_name, port):
    ssocket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    ssocket.bind(('', port))
    writefile('thread={} protocol=udp servertport={}'.format(thread_name, port))

    while True:
        #num = random.randint(0,10)
        data, client_addr = ssocket.recvfrom(port)
        writefile('recved udp data from thread={} port={}'.format(thread_name, port))
        #new_data = data.upper()

        ssocket.sendto(bytes('pong', encoding='utf-8'), client_addr)
    #    print('recved', data)

def start_tcp_ping(thread_name, port):
    ssocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    ssocket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)   # SO_REUSEADDR flag tells the kernel to reuse a local socket in TIME_WAIT state, without waiting for its natural timeout to expire
    ssocket.bind(('', port))
    ssocket.listen(1)
    writefile('thread={} protocol=tcpservertport={}'.format(thread_name, port))

    while True:
        conn, addr = ssocket.accept()

        while True:
            #print('waiting for data')
            data = conn.recv(1024)
            #print('conn after recv')
            if not data: 
               #print('no data')
               break

            writefile('recved tcp data from thread={} port={}'.format(thread_name, port))

            conn.sendall(bytes('pong', encoding='utf-8'))
    #    print('recved', data)

#if protocol == 'udp':
#   _thread.start_new_thread(start_udp_ping, ("Thread-1", 2015))
#   _thread.start_new_thread(start_udp_ping, ("Thread-2", 2016))
#elif protocol == 'tcp':
#   _thread.start_new_thread(start_tcp_ping, ("Thread-1", 2015))
#   _thread.start_new_thread(start_tcp_ping, ("Thread-2", 2016))

#f = open(outfile, 'w')

writefile('starting http thread')
_thread.start_new_thread(start_http_server, ("Thread-3", http_port))
writefile('starting udp thread')
_thread.start_new_thread(start_udp_ping, ("Thread-1", 2015))
_thread.start_new_thread(start_udp_ping, ("Thread-2", 2016))
writefile('starting tcp thread')
_thread.start_new_thread(start_tcp_ping, ("Thread-1", 2015))
_thread.start_new_thread(start_tcp_ping, ("Thread-2", 2016))
writefile('all threads started')

while 1:
   time.sleep(1) 
