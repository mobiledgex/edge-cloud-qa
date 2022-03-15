import websocket
import logging
import json

logger = logging.getLogger(__name__)


class MexWebSocket:
    def __init__(self, url, token):
        # self.wsurl = url.replace('http', 'ws').replace('api', 'ws/api')

        logger.debug(f'creating websocket to {url}')
        self.ws = websocket.WebSocket()
        self.ws.connect(url)
        logger.debug(f'created websocket to {url}')

        logger.debug(f'sending token={token}')
        self.ws.send(f'{{"token": "{token}"}}')

        self.resp_text = ''
        self.status_code = None
        self.last_resp = ''

    def send_data(self, data):
        logger.debug(f'sending data={data}')
        self.ws.send(data)

    def receive_data(self):
        try:
            while True:
                received_data = self.ws.recv()
                logger.debug(f'received: {received_data}')
                self.resp_text += received_data
                if received_data:
                    self.last_resp = received_data
                print('*WARN*', 'lastr', self.last_resp)
                self.status_code = json.loads(self.last_resp)['code']
        except websocket.WebSocketConnectionClosedException as e:
            logger.info(f'ws connection closed {e}')
            self.ws.close()
