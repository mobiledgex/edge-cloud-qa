#!/usr/bin/python3

import socket
import _thread
import datetime
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


class MyHttpRequestHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        print('path=', self.path)
        if self.path != '/automation.html':
            self.path = 'pagenotfound.html'
        return http.server.SimpleHTTPRequestHandler.do_GET(self)


def writefile(s):
    with open(outfile, 'a+') as f:
        print(s, flush=True)
        f.write(str(datetime.datetime.now()) + ' ' + s + '\n')


def start_http_server(thread_name, port):
    # handler = http.server.SimpleHTTPRequestHandler
    handler = MyHttpRequestHandler

    writefile('start_http_server thread={} protocol=http servertport={}'.format(thread_name, port))
    httpd = socketserver.TCPServer(("", port), handler)
    httpd.serve_forever()
    # with socketserver.TCPServer(("", port), handler) as httpd:
    #    writefile('thread={} protocol=http servertport={} server starting'.format(thread_name, port))
    #    httpd.serve_forever()


def start_udp_ping(thread_name, port):
    ssocket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    ssocket.bind(('', port))
    writefile('start_udp_ping thread={} protocol=udp serverport={}'.format(thread_name, port))

    while True:
        data, client_addr = ssocket.recvfrom(port)
        writefile(f'start_udp_ping recved udp data from address={client_addr}thread={thread_name} port={port} data={data}')

        try:
            if data.decode('utf8') == 'exit':
                writefile('start_udp_ping shutdown/close socket thread={} port={}'.format(thread_name, port))
                ssocket.sendto(bytes('bye', encoding='utf-8'), client_addr)
                ssocket.shutdown(socket.SHUT_RDWR)
                ssocket.close()
                sys.exit()
        except UnicodeDecodeError as e:
            writefile(f'start_udp_ping unicodecode error from address={client_addr} thread={thread_name} port={port} data={data}: {e}')
            continue
        except Exception as e:
            writefile(f'start_udp_ping unknown exception error from address={client_addr} thread={thread_name} port={port} data={data}: {e}')
            continue

        ssocket.sendto(bytes('pong', encoding='utf-8'), client_addr)
    #    print('recved', data)


def start_tcp_ping(thread_name, port):
    writefile('start_tcp_ping thread={} protocol=tcp serverport={}'.format(thread_name, port))

    try:
        ssocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        ssocket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)   # SO_REUSEADDR flag tells the kernel to reuse a local socket in TIME_WAIT state, without waiting for its natural timeout to expire
        ssocket.bind(('', int(port)))
        ssocket.listen(1)
    except socket.error as e:
        writefile('start_tcp_ping error starting socket thread={} protocol=tcp serverport={} error={}'.format(thread_name, port, e))
    except socket.gaierror as e:
        writefile('start_tcp_ping error starting socket thread={} protocol=tcp serverport={} error={}'.format(thread_name, port, e))
    except Exception as e:
        writefile('start_tcp_ping error starting socket thread={} protocol=tcp serverport={} error={}'.format(thread_name, port, e))

    while True:
        conn, addr = ssocket.accept()
        while True:
            # print('waiting for data')
            data = conn.recv(1024)
            # print('conn after recv')
            if not data:
                # print('no data')
                break

            writefile(f'start_tcp_ping recved tcp data from address={addr} thread={thread_name} port={port} data={data}')

            try:
                decoded_data = data.decode('utf8', 'strict')
                if decoded_data == 'exit':
                    writefile('start_tcp_ping shutdown/close socket thread={thread_name} port={port}')
                    conn.sendall(bytes('bye', encoding='utf-8'))
                    ssocket.shutdown(socket.SHUT_RDWR)
                    ssocket.close()
                    sys.exit()
                elif decoded_data == 'version':
                    writefile(f'start_tcp_ping version requested thread={thread_name} port={port}')
                    version_data = '0'
                    with open('VERSION') as version_file:
                        version_data = version_file.read()
                    writefile(f'start_tcp_ping version is {version_data} thread={thread_name} port={port}')
                    conn.sendall(bytes(version_data, encoding='utf-8'))
                elif decoded_data == 'ping':
                    writefile('start_tcp_ping ping received thread={thread_name} port={port}')
                    conn.sendall(bytes('pong', encoding='utf-8'))
                else:
                    conn.sendall(bytes('unknown', encoding='utf-8'))
            except UnicodeDecodeError as e:
                writefile(f'start_tcp_ping unicodecode error from address={addr} thread={thread_name} port={port} data={data}: {e}')
                continue
            except Exception as e:
                writefile(f'start_tcp_ping unknown exception error from address={addr} thread={thread_name} port={port} data={data}: {e}')
                continue

    #    print('recved', data)


def start_port_thread(thread_name, port):
    global thread_count
    ssocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    ssocket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)   # SO_REUSEADDR flag tells the kernel to reuse a local socket in TIME_WAIT state, without waiting for its natural timeout to expire
    ssocket.bind(('', port))
    ssocket.listen(1)
    writefile('start_port_thread thread={} protocol=tcp port={}'.format(thread_name, port))

    port_start = 0
    while True:
        conn, addr = ssocket.accept()
        while True:
            data = conn.recv(1024).decode('utf8')
            if not data:
                break

            writefile('start_port_thread recved tcp data from thread={} port={} data={}'.format(thread_name, port, data))

            try:
                protocol, port_start = data.split(':')
            except Exception:
                print('error: split failed for data=' + data, flush=True)
                conn.sendall(bytes('error', encoding='utf-8'))
                break

            try:
                if protocol == 'tcp':
                    writefile('start_port_thread starting tcp thread thread={} port={}'.format('Thread-' + str(thread_count), port_start))
                    _thread.start_new_thread(start_tcp_ping, ('Thread-' + str(thread_count), port_start))
                    thread_count += 1
                elif protocol == 'udp':
                    writefile('start_port_thread starting udp thread thread={} port={}'.format('Thread-' + str(thread_count), port_start))
                    _thread.start_new_thread(start_udp_ping, ('Thread-' + str(thread_count), port_start))
                    thread_count += 1
            except Exception:
                writefile('start_port_thread error: start thread failed thread={} port={}'.format('Thread-' + str(thread_count), port))
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


writefile('starting http thread')
_thread.start_new_thread(start_http_server, ('Thread-' + str(thread_count), http_port))
thread_count += 1

writefile('starting udp thread')
_thread.start_new_thread(start_udp_ping, ('Thread-' + str(thread_count), 2015))
thread_count += 1
_thread.start_new_thread(start_udp_ping, ('Thread-' + str(thread_count), 2016))
thread_count += 1

writefile('starting tcp thread')
_thread.start_new_thread(start_tcp_ping, ('Thread-' + str(thread_count), 2015))
thread_count += 1
_thread.start_new_thread(start_tcp_ping, ('Thread-' + str(thread_count), 2016))
thread_count += 1
_thread.start_new_thread(start_port_thread, ('Thread-' + str(thread_count), 4015))
thread_count += 1
_thread.start_new_thread(start_tcp_ping, ('Thread-' + str(thread_count), 8000))  # used to be used by backend but customer wanted to use it for app. EDGECLOUD-3833
thread_count += 1

writefile('starting websocket server')
http_server = tornado.httpserver.HTTPServer(application)
http_server.listen(3765)
myIP = socket.gethostbyname(socket.gethostname())
print('*** Websocket Server Started at %s***' % myIP)
writefile('all threads started')

tornado.ioloop.IOLoop.instance().start()

while 1:
    time.sleep(1)
