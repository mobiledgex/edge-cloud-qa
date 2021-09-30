import logging
import sys
import os
import grpc

logging.basicConfig(format='%(asctime)s %(levelname)s %(funcName)s line:%(lineno)d - %(message)s', datefmt='%d-%b-%y %H:%M:%S')
logger = logging.getLogger(__name__)

# export GRPC_VERBOSITY=DEBUG
# export GRPC_TRACE=client_channel,channel,health_check_client,http,http2_stream_state


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
                # trusted_certs = f.read().encode()
                trusted_certs = f.read()
            with open(key_real, 'rb') as f:
                logger.debug('using key=' + key_real)
                trusted_key = f.read()
            with open(client_cert_real, 'rb') as f:
                logger.debug('using client cert=' + client_cert_real)
                cert_chain = f.read()

            # create credentials
            credentials = grpc.ssl_channel_credentials(root_certificates=trusted_certs, private_key=trusted_key, certificate_chain=cert_chain)
            channel_options = [('grpc.keepalive_time_ms', 600000),  # 3mins. seems I cannot do less than 5mins. does 5mins anyway if set lower
                               ('grpc.keepalive_timeout_ms', 5000),
                               ('grpc.http2.min_time_between_pings_ms', 60000),
                               ('grpc.http2.max_pings_without_data', 0),
                               ('grpc.keepalive_permit_without_calls', 1)]
            self.grpc_channel = grpc.secure_channel(address, credentials, options=channel_options)
        else:
            # self.grpc_channel = grpc.insecure_channel(address)
            # added this after some letsencrypt cert change. Not sure why I need to load this
            root_cert_real = self._findFile('isrgrootx1.pem')
            with open(root_cert_real, 'rb') as f:
                logger.debug('using root_cert=' + root_cert_real)
                trusted_certs = f.read()
            credentials = grpc.ssl_channel_credentials(root_certificates=trusted_certs)
            # credentials = grpc.ssl_channel_credentials()
            channel_options = [('grpc.keepalive_time_ms', 600000),  # 3mins. seems I cannot do less than 5mins. does 5mins anyway if set lower
                               ('grpc.keepalive_timeout_ms', 5000),
                               ('grpc.http2.min_time_between_pings_ms', 60000),
                               ('grpc.http2.max_pings_without_data', 0),
                               ('grpc.keepalive_permit_without_calls', 1)]
            self.grpc_channel = grpc.secure_channel(address, credentials, options=channel_options)

    def _findFile(self, path):
        for dirname in sys.path:
            candidate = os.path.join(dirname, path)
            if os.path.isfile(candidate):
                return candidate
        raise Exception('cant find file {}'.format(path))
