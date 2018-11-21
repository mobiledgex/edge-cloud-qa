import logging
import sys
import os
import grpc

logging.basicConfig(format='%(asctime)s %(levelname)s %(funcName)s line:%(lineno)d - %(message)s',datefmt='%d-%b-%y %H:%M:%S')
logger = logging.getLogger()

class MexGrpc(object):
    def __init__(self, address, root_cert=None, key=None, client_cert=None):
        self.grpc_channel = None
        self.address = address
        self.response = None

        if root_cert:
            root_cert_real = self._findFile(root_cert)
            key_real = self._findFile(key)
            client_cert_real = self._findFile(client_cert)
            with open(root_cert_real, 'rb') as f:
                logger.debug('using root_cert=' + root_cert_real)
                #trusted_certs = f.read().encode()
                trusted_certs = f.read()
            with open(key_real,'rb') as f:
                logger.debug('using key='+key_real)
                trusted_key = f.read()
            with open(client_cert_real, 'rb') as f:
                logger.debug('using client cert=' + client_cert_real)
                cert = f.read()
            # create credentials
            credentials = grpc.ssl_channel_credentials(root_certificates=trusted_certs, private_key=trusted_key, certificate_chain=cert)
            self.grpc_channel = grpc.secure_channel(address, credentials)
            print('grpc channel', self.grpc_channel)
        else:
                self.grpc_channel = grpc.insecure_channel(address)
        logger.info('xxxxxx1' + str(self.grpc_channel))

    def _findFile(self, path):
        for dirname in sys.path:
            candidate = os.path.join(dirname, path)
            if os.path.isfile(candidate):
                return candidate
        raise Error('cant find file {}'.format(path))
