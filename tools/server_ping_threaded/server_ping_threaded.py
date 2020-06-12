#!/usr/bin/python3

import socket
#import random
import _thread
import datetime
import time
import http.server
import socketserver
import ssl
import pprint
import tornado.ioloop
from tornado.iostream import IOStream
import tornado.httpserver
import tornado.websocket
import tornado.ioloop
import tornado.web

http_port = 8085

#port = 2015
protocol = 'tcp'
#protocol = 'udp'
outfile = 'server_ping_outfile.txt'

server_cert = '/Users/andyanderson/go/src/github.com/mobiledgex/edge-cloud/tls/out/mex-server.crt'
server_key = '/Users/andyanderson/go/src/github.com/mobiledgex/edge-cloud/tls/out/mex-server.key'
client_cert = '/Users/andyanderson/go/src/github.com/mobiledgex/edge-cloud/tls/out/mex-client.crt'
client_key = '/Users/andyanderson/go/src/github.com/mobiledgex/edge-cloud/tls/out/mex-client.key'

ca_cert = '~/mex-ca.crt'
ca_key = '~/mex-ca.key'

#_thread.start_new_thread(start_ping, ("Thread-1", 2015))

def writefile(s):
    with open(outfile,'a+') as f:
        print(s, flush=True)
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

def start_tls_tcp_ping(thread_name, port):
    context = ssl.create_default_context(ssl.Purpose.CLIENT_AUTH)
    pprint.pprint(context.get_ciphers())
    #context.verify_mode = ssl.CERT_REQUIRED
    context.load_cert_chain(certfile=server_cert, keyfile=server_key)
    #context.load_verify_locations(cafile=client_cert)

    ssocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    ssocket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)   # SO_REUSEADDR flag tells the kernel to reuse a local socket in TIME_WAIT state, without waiting for its natural timeout to expire
    ssocket.bind(('', port))
    ssocket.listen(1)
    writefile('thread={} protocol=tcpservertport={}'.format(thread_name, port))

    context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)

    while True:
        conn, addr = ssocket.accept()

        sslconn = context.wrap_socket(conn, server_side=True) 
        print('cipher', sslconn.cipher())

        while True:
            #print('waiting for data')
            data = sslconn.recv(1024)
            #print('conn after recv')
            if not data:
               #print('no data')
               break

            writefile('recved tcp data from thread={} port={}'.format(thread_name, port))

            sslconn.sendall(bytes('pong', encoding='utf-8'))
    #    print('recved', data)

def xstart_tls_tcp_ping(thread_name, port):
    context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as ssocket:
       #ssocket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)   # SO_REUSEADDR flag tells the kernel to reuse a local socket in TIME_WAIT state, without waiting for its natural timeout to expire
       ssocket.bind(('', port))
       ssocket.listen(1)
       with context.wrap_socket(ssocket, server_side=True) as swrap:
          writefile('thread={} protocol=tcpservertport={}'.format(thread_name, port))

          while True:
             conn, addr = ssocket.accept()

             while True:
                #print('waiting for data')
                data = swrap.recv(1024)
                #print('conn after recv')
                if not data:
                   #print('no data')
                   break

                writefile('recved tls tcp data from thread={} port={}'.format(thread_name, port))

                swrap.sendall(bytes('pong', encoding='utf-8'))
    #    print('recved', data)


class WSHandler(tornado.websocket.WebSocketHandler):
    def open(self):
        print('new connection')
      
    def on_message(self, message):
        print('message received:  %s' % message)
        # Reverse Message and send it back
        print('sending back message: %s' % message[::-1])
        self.write_message(message[::-1])
 
    def on_close(self):
        print('connection closed')
 
    def check_origin(self, origin):
        return True
 
application = tornado.web.Application([
    (r'/ws', WSHandler)
])



    
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
_thread.start_new_thread(start_tls_tcp_ping, ("Thread-1", 3015))
writefile('starting websocket server')
http_server = tornado.httpserver.HTTPServer(application)
http_server.listen(3765)
myIP = socket.gethostbyname(socket.gethostname())
print('*** Websocket Server Started at %s***' % myIP)

writefile('all threads started')

while 1:
   time.sleep(1) 
