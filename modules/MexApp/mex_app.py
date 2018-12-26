import logging
import socket
import sys

class MexApp(object):
    def ping_udp_port(self, host, port):
        data = 'ping'
        data_size = sys.getsizeof(bytes(data, 'utf-8'))
        data_to_send = data.encode('ascii')

        client_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        client_socket.settimeout(1)

        return_data = ''
        try:
            client_socket.sendto(data_to_send,(host, int(port)))
            (return_data, addr) = client_socket.recvfrom(data_size)
            logging.info('received this data from {}:{}'.format(addr, return_data.decode('utf-8')))
        except:
            e = sys.exc_info()[0]
            client_socket.close()
            raise Exception('error=', e)
            
        if return_data.decode('utf-8') != 'ping':
            raise Exception('correct data not received from server')

    def ping_tcp_port(self, host, port):
        data = 'ping'

        client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        client_socket.connect((host, int(port)))

        return_data = ''
        try:
            client_socket.sendall(bytes(data, encoding='utf-8'))
            return_data = client_socket.recv(data_size)
        except Exception as e:
            print('caught exception')
            #print(sys.exc_info())
            #e = sys.exc_info()[0]
            client_socket.close()
            raise Exception('error=', e)
            
        if return_data.decode('utf-8') != 'ping':
            raise Exception('correct data not received from server')

    def udp_port_should_be_alive(self, host, port):
        logging.info('host:' + host + ' port:' + str(port))
        self.ping_udp_port(host, port)
        return True

    def tcp_port_should_be_alive(self, host, port):
        logging.info('host:' + host + ' port:' + str(port))
        self.ping_tcp_port(host, port)
        return True
