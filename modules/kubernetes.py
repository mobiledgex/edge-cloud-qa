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

import logging
import subprocess

class Kubernetes(object):
    def __init__(self, kubeconfig=None):
        self.kubeconfig = kubeconfig
        
    def get_pods(self):
        kubectl_cmd = f'KUBECONFIG={self.kubeconfig} kubectl get pods'
        logging.info(kubectl_cmd)
        print('*WARN*', kubectl_cmd)

        kubectl_return = subprocess.run(kubectl_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
        kubectl_out = kubectl_return.stdout.decode('utf-8')
        kubectl_err = kubectl_return.stderr.decode('utf-8')
        if kubectl_err:
            raise Exception(kubectl_err)

        logging.debug(kubectl_out)
        
        return kubectl_out

    def get_pod(self, pod_name):
        pod_list = self.get_pods().split('\n')

        for pod in pod_list:
            if pod_name in pod:
                return pod.split()[0]

        raise Exception(f'pod with name={pod_name} not found')

    def exec_command(self, pod_name, command):
        kubectl_cmd = f'KUBECONFIG={self.kubeconfig} kubectl exec -it {pod_name} -- bash -c "{command}"'
        logging.debug('kubectl_cmd=' + kubectl_cmd)
        
        kubectl_return = subprocess.run(kubectl_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
        kubectl_out = kubectl_return.stdout.decode('utf-8')
        logging.debug('exec_command return=' + str(kubectl_return))

        if kubectl_return.returncode != 0:
            raise Exception('exec_command failed:' + kubectl_return.stderr.decode('utf-8'))
        
        return kubectl_return.stdout.decode('utf-8'), kubectl_return.stderr.decode('utf-8'), kubectl_return.returncode
        
    def restart_pod(self, pod_name, process_name):
        logging.info('restarting ' + pod_name)

        returnvalue = None
        try:
            returnvalue = self.exec_command(pod_name=pod_name, command='pkill ' + process_name)
        except Exception as e:
            print('*WARN*', e)
            logging.info('e:' + str(e))
            if 'exit code 137' in str(e) :
                logging.debug('got error code 137')
            else:
                logging.error('restarting pod failed. Didnt receive 137 error code.' + str(e))
                raise Exception('restart_pod failed:' + str(e))
                
        
