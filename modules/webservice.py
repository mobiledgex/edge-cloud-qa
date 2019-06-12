import requests
from requests.packages.urllib3.exceptions import InsecureRequestWarning

import json
import sys
import os
import logging.config
#import logging
import robot.api.logger
#import requests.packages.urllib3.connectionpool as httplib
#import httplib as http_client
import http.client as http_client
import time

class WebService() :
    resp = None
    #protocol = 'https'
    #output_format = 'json'
    #httpLogger = None
    debug = False
    trace_file = None
    
    #def __init__(self, jid = None, password = None, sesid = None, http_or_https = None, output_format = None) :
    def __init__(self, debug = False, http_trace = False) :
        requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

        #logging.config.fileConfig('logging.ini')

        logging.debug("init")

        self.debug = debug
        self.http_trace = http_trace

        if os.getenv('AUTOMATION_HTTPTRACE') == '1':
            self.http_trace = True

        if debug:
            http_client.HTTPConnection.debuglevel = 1

        #if http_or_https is not None:
        #    self.protocol = http_or_https
        #if output_format is not None:
        #    self.output_format = output_format

    def post(self, url, data=None, verify_cert=False, headers=None, files=None):
        logging.debug('url=' + url + ' data=' + str(data) + ' headers=' + str(headers) + ' verify_cert=' + str(verify_cert))

        #url_to_use = self._buildUrl(url)

        self.resp = requests.post(url, data, verify=verify_cert, headers=headers, files=files)
        logging.debug('resp=' + str(self.resp.text))
        
        if self.http_trace:
            self._print_trace()
        
        return self.resp

    def delete(self, url, verify_cert=False, headers=None):
        logging.debug('url=' + url)
        #url_to_use = self._buildUrl(url)
        self.resp = requests.delete(url, verify=verify_cert, headers=headers)
        #print requests.request
        if self.http_trace:
            self._print_trace()

        return self.resp

    def get(self, url, data=None, verify_cert=False, headers=None, params=None):
        logging.debug('url=' + url + ' headers=' + str(headers) + ' data=' + str(data) + ' params=' + str(params))
        #url_to_use = self._buildUrl(url, self.output_format)
        #self.resp = requests.get(url_to_use, verify=verify_cert)
        #print('headers=' + str(headers))
        self.resp = requests.get(url, verify=verify_cert, headers=headers, data=data, params=params)

        if self.http_trace:
            self._print_trace()

        #print(self.resp.request.url, self.resp.request.headers, self.resp.request.body)

        return self.resp

    def put(self, url, data=None, verify_cert=False, headers=None):

        #url_to_use = self._buildUrl(url)
        self.resp = requests.put(url, data, verify=verify_cert, headers=headers)
        #print requests.request

        if self.http_trace:
            self._print_trace()

        return self.resp

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
            if arglist[a] == None:
                del arglist_temp[a]
        parm_string = self._build_parms(arglist_temp)
        return parm_string
            
    def _print_trace(self):
        #file = os.path.basename(sys.argv[0])
        if WebService.trace_file:
            WebService.trace_file = open(os.path.basename(sys.argv[-1]) + '.trace', 'a')
        else:
            WebService.trace_file = open(os.path.basename(sys.argv[-1]) + '.trace', 'w')
        WebService.trace_file.write('==================================================================\n\n')
        WebService.trace_file.write('REQUEST: ' + time.strftime("%d %b %Y %H:%M:%S", time.localtime()) + '\n')
        #WebService.httpLogger.info('   GET ' + self.resp.request.url)
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
