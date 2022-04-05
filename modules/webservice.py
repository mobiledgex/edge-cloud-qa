import requests
from requests.packages.urllib3.exceptions import InsecureRequestWarning

import json
import sys
import os
import logging.config
import logging
# import robot.api.logger
# import requests.packages.urllib3.connectionpool as httplib
# import httplib as http_client
import http.client as http_client
import time
# from robot.libraries.BuiltIn import BuiltIn

logger = logging.getLogger(__name__)
logging.getLogger('urllib3').setLevel(logging.CRITICAL)


class WebService():
    resp = None
    # protocol = 'https'
    # output_format = 'json'
    # httpLogger = None
    debug = False
    trace_file = None
    stream_output_bytes = []
    stream_output_str = []
    stream_output = []
    resp_text = ''

    # def __init__(self, jid = None, password = None, sesid = None, http_or_https = None, output_format = None) :
    def __init__(self, debug=False, http_trace=False):
        requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

        # logging.config.fileConfig('logging.ini')

        # logging.debug("init")

        self.debug = debug
        self.http_trace = http_trace

        if os.getenv('AUTOMATION_HTTPTRACE') == '1':
            self.http_trace = True

        if debug:
            http_client.HTTPConnection.debuglevel = 1

        # if http_or_https is not None:
        #    self.protocol = http_or_https
        # if output_format is not None:
        #    self.output_format = output_format

    def post(self, url, data=None, verify_cert=False, headers=None, files=None, stream=False, connection_timeout=3.05, stream_timeout=60):
        logger.debug(f'post url={url} data={data} headers={headers} verify_cert={verify_cert} stream={stream} connection_timeout={connection_timeout}, stream_timeout={stream_timeout}')

        # url_to_use = self._buildUrl(url)
        self.stream_output_bytes = []
        self.stream_output = []
        self.stream_output_str = []
        self.resp_text = ''
        self.resp_dict = {}

        timeout = (connection_timeout, stream_timeout)
        # if stream and stream_timeout:
        #    timeout = (3.05, int(stream_timeout))

        try:
            self.resp = requests.post(url, data, verify=verify_cert, headers=headers, files=files, stream=stream, timeout=timeout)
            logger.debug(f'post resp={self.resp} stream={stream}')
            if stream:
                logger.debug('checking for stream output')
                for line in self.resp.iter_lines():
                    logging.debug(f'stream line={line}')
                    # BuiltIn().log_to_console(f'console stream line={line}')
                    self.stream_output_str.append(line.decode("utf-8"))
                    self.stream_output.append(json.loads(line.decode("utf-8")))
                    # self.stream_output_bytes.append(line)
                logger.debug('stream_output_bytes=' + str(self.stream_output_bytes))
                self.resp_text = str(self.stream_output_str)
            else:
                logger.debug('resptext=' + str(self.resp.text))
                self.resp_text = str(self.resp.text)
                if url in self.resp_dict:
                    self.resp_dict[url] += self.resp_text
                else:
                    self.resp_dict[url] = self.resp_text
        except requests.exceptions.ConnectionError as e:
            if stream and 'Read timed out' in str(e):
                logging.info(f'Read timeout while steaming:{e}')
            else:
                raise Exception(f'POST ConnectionError exception: {e}')
        except Exception as e:
            raise Exception(f'POST exception: {e}')

        if self.http_trace:
            self._print_trace()

        return self.resp

    def delete(self, url, verify_cert=False, headers=None):
        logging.debug('url=' + url)
        # url_to_use = self._buildUrl(url)
        self.resp = requests.delete(url, verify=verify_cert, headers=headers)
        # print requests.request
        if self.http_trace:
            self._print_trace()

        return self.resp

    def get(self, url, data=None, verify_cert=False, headers=None, params=None):
        logging.debug('url=' + url + ' headers=' + str(headers) + ' data=' + str(data) + ' params=' + str(params))
        # url_to_use = self._buildUrl(url, self.output_format)
        # self.resp = requests.get(url_to_use, verify=verify_cert)
        # print('headers=' + str(headers))
        self.resp = requests.get(url, verify=verify_cert, headers=headers, data=data, params=params)

        if self.http_trace:
            self._print_trace()

        # print(self.resp.request.url, self.resp.request.headers, self.resp.request.body)

        return self.resp

    def put(self, url, data=None, verify_cert=False, headers=None):

        # url_to_use = self._buildUrl(url)
        self.resp = requests.put(url, data, verify=verify_cert, headers=headers)
        # print requests.request

        if self.http_trace:
            self._print_trace()

        return self.resp

    def get_stream_output(self):
        return self.stream_output

    def get_output(self, key):
        return self.resp_dict[key]

    def _build_parms(self, parms):
        s = ''
        for p in parms:
            if '?' not in s:
                s = s + '?' + p + '=' + parms[p]
            else:
                s = s + '&' + p + '=' + parms[p]
        return s

    def _build_arglist(self, arglist):
        del arglist['self']
        arglist_temp = arglist.copy()
        for a in arglist:
            if arglist[a] is None:
                del arglist_temp[a]
        parm_string = self._build_parms(arglist_temp)
        return parm_string

    def _print_trace(self):
        # file = os.path.basename(sys.argv[0])
        if WebService.trace_file:
            WebService.trace_file = open(os.path.basename(sys.argv[-1]) + '.trace', 'a')
        else:
            WebService.trace_file = open(os.path.basename(sys.argv[-1]) + '.trace', 'w')
        WebService.trace_file.write('==================================================================\n\n')
        WebService.trace_file.write('REQUEST: ' + time.strftime("%d %b %Y %H:%M:%S", time.localtime()) + '\n')
        # WebService.httpLogger.info('   GET ' + self.resp.request.url)
        WebService.trace_file.write('   ' + self.resp.request.method + ' ' + self.resp.request.url + '\n')
        WebService.trace_file.write('      headers: ' + str(self.resp.request.headers) + '\n')
        WebService.trace_file.write('      body: ' + str(self.resp.request.body) + '\n')
        WebService.trace_file.write('RESPONSE:\n')
        WebService.trace_file.write('   status_code:' + str(self.resp.status_code) + '\n')
        WebService.trace_file.write('   body:' + self.resp.text + '\n')
        WebService.trace_file.close()

#    def _buildUrl(self, url, output_format = None):
#        if url.startswith('http'):
#            url_to_use = url
#        else:
#            url_to_use = self.protocol + '://' + url
#
#        if output_format is 'json':
#            if '?' not in url_to_use:
#                url_to_use = urlToUse + '?outputFormat=json'
#            else:
#                url_to_use = urlToUse + '&outputFormat=json'
#
#        return url_to_use
