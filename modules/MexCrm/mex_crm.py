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

import kubernetes
import subprocess
import logging
import time
#import mex_app

class CRM(object):
    def __init__(self, kubeconfig, crm_pod_name):
        self.k8s = kubernetes.Kubernetes(kubeconfig=kubeconfig)

        self.pod_name = self.k8s.get_pod(crm_pod_name)

    def wait_for_pod_to_be_running_on_crm(self, cluster_name, operator_name, pod_name, wait_time=600):
        logging.info(f'cluster_name={cluster_name} operator_name={operator_name} pod_name={pod_name}')
        #cluster_name = cluster_name.replace('.', '') #remove any dots
        pod_name = pod_name.replace('.', '') #remove any dots
                    
        kubeconfig = f'{cluster_name}.{operator_name}.kubeconfig' 
        logging.info('kubeconfig=' + kubeconfig)
        
        for t in range(wait_time):
            kubectl_out = self.get_pods(kubeconfig)
            logging.debug(f'try {t} of {wait_time}')
            logging.debug(kubectl_out)

            for line in kubectl_out:
                try:
                    name, ready, status, restarts, age = line.split()
                    logging.debug(f'fields {name} {ready} {status} {restarts} {age}')
                    if pod_name in name:
                        if status == 'Running':
                            logging.info('Found running pod:' + line)
                            return True
                except:
                    logging.debug('Failed splitting line:' + line)
            time.sleep(1)

        raise Exception('Running k8s pod not found')
        
    def get_pods(self, kubeconfig):
        #kubectl_cmd = f'kubectl exec -it {self.pod_name} -- bash -c "KUBECONFIG={kubeconfig} kubectl get pods"'
        #logging.debug('kubectl_cmd=' + kubectl_cmd)
        
        #kubectl_return = subprocess.run(kubectl_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
        #kubectl_out = kubectl_return.stdout.decode('utf-8')

        kubectl_cmd = f'KUBECONFIG={kubeconfig} kubectl get pods'        
        kubectl_out, kubectl_err, kubectl_returncode  = self.k8s.exec_command(pod_name=self.pod_name, command=kubectl_cmd)

        pod_list = kubectl_out.split('\n')[1:]
        
        return pod_list

