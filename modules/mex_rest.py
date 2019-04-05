from webservice import WebService
import logging
import json

class MexRest(WebService) :
    decoded_data = None
    
    def __init__(self, address='127.0.0.1:50051', root_cert='mex-ca.crt', key='localserver.key', client_cert='localserver.crt'):
        super().__init__()

        self.root_cert = root_cert
        
    def post(self, url, data=None, bearer=None):
        logging.debug(f'url={url} data={data} cert={self.root_cert}')

        headers = {'Content-type': 'application/json', 'accept': 'application/json'}
        if bearer:
            headers['Authorization'] = 'Bearer ' + bearer
            
        self.resp = super().post(url=url, data=data, verify_cert=self.root_cert, headers=headers)
        self._decode_content()

        if str(self.resp.status_code) != '200':
            raise Exception("ws did not return a 200 response. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())

    def _decode_content(self):
        logging.debug('content=' + self.resp.content.decode("utf-8"))
        
        self.decoded_data = json.loads(self.resp.content.decode("utf-8"))

    def response_status_code(self):
        return self.resp.status_code

    def response_body(self):
        return self.resp.text


