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

from webservice import WebService
import logging
import json
import sys
import os

class MexAzure(WebService) :
    grant_type = 'client_credentials'
    app_id = '097ee991-3485-434f-ab2b-faef98ee03ce'
    client_secret = '70xBsqeSQytUthfMKPQ9eex2W8whHaaJHlKSJDdTa/g='
    auth_key = '***REMOVED***'
    subscription_id = '902e8722-dc5f-469e-b218-da958e7e25e5'
    
    def __init__(self):
        super().__init__(http_trace=True)

        self.token = None
        self.decoded_data = None
        self.resource = None
        
    def login(self):
        """ Sends a login REST request to Azure with mobiledgex credentials to get toke to be used for future requests

        Uses the following credentials:
        | grant_type      | 'client_credentials' |
        | app_id          | '097ee991-3485-434f-ab2b-faef98ee03ce' |
        | client_secret   | '70xBsqeSQytUthfMKPQ9eex2W8whHaaJHlKSJDdTa/g=' |
        | auth_key        | '***REMOVED***' |
        | subscription_id | '902e8722-dc5f-469e-b218-da958e7e25e5' |

        Returns to access_token

        Examples:
        | Login     |       |
        | ${token}= | Login |
        """
        
        url = f'https://login.microsoftonline.com/{self.auth_key}/oauth2/token'
        data = {'grant_type': self.grant_type, 'client_id': self.app_id, 'client_secret': self.client_secret, 'resource': 'https://management.azure.com/'}

        resp = self.post(url=url, data=data)
        
        if str(self.resp.status_code) != '200':
            raise Exception("ws did not return a 200 response. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())

        self._decode_content()
        self.token = self.decoded_data['access_token']
        self.resource = self.decoded_data['resource']
        
        return self.decoded_data['access_token']

    def get_vm_sizes(self, location='centralus'):
        """ Sends a REST request to Azure to get the VM sizes available

        Will automatically send a Login request to get a token if a login has not previously been done

        Returns a dictionary with the VM size information

        Examples:
        | ${vm_info}= | Get VM Sizes |                       |
        | ${vm_info}= | Get VM Sizes | location='westeurope' |
        """

        url = f'subscriptions/{self.subscription_id}/providers/Microsoft.Compute/locations/{location}/vmSizes?api-version=2018-06-01'
        print('*WARN*', 'url', url)

        self._get(url)

        return self.decoded_data
    
    def get_azure_cluster_info(self, cluster, resource_group=None, cloudlet=None):
        """ Sends a REST request to Azure to get cluster information

        Must provide a cluster and either a resource_group or a cloudlet.  If cloudlet is provided then the resource group will be built with the cloudlet name and cluster name.
        Will automatically send a Login request to get a token if a login has not previously been done

        Returns a dictionary with the cluster information

        Examples:
        | ${vm_info}= | Get Azure Cluster Info | cluster=MyCluster | cloudlet=automationAzureCentralCloudlet |                       |
        """

        if cloudlet and not resource_group:
            resource_group = f'{cloudlet}-{cluster}'
            
        #url = f'subscriptions/{self.subscription_id}/resourceGroups/{resource_group}/providers/Microsoft.ContainerService/managedClusters/{cluster}?api-version=2019-02-01'
        url = f'subscriptions/{self.subscription_id}/resourceGroups/{resource_group}/providers/Microsoft.ContainerService/managedClusters/{resource_group}?api-version=2019-02-01'
        print('*WARN*', 'url', url)

        self._get(url)

        return self.decoded_data
    
    def _get(self, url):
        if not self.token:
            print('*WARN*', 'login')
            self.login()

        headers = {'Content-type': 'application/json', 'Authorization': f'Bearer {self.token}'}
        url = self.resource + url
        print('*WARN*', url)
        resp = self.get(url=url, headers=headers)
        
        if str(self.resp.status_code) != '200':
            raise Exception("ws did not return a 200 response. responseCode = " + str(self.resp.status_code) + ". ResponseBody=" + str(self.resp.text).rstrip())

        self._decode_content()
        print('*WARN*', self.decoded_data)
        
    def _decode_content(self):
        logging.debug('content=' + self.resp.content.decode("utf-8"))
        
        self.decoded_data = json.loads(self.resp.content.decode("utf-8"))

