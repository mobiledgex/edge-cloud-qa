import logging
import subprocess

class Kubernetes(object):
    def __init__(self, kubeconfig=None):
        self.kubeconfig = kubeconfig
        
    def get_pods(self):
        kubectl_cmd = f'KUBECONFIG={self.kubeconfig} kubectl get pods'
        logging.info(kubectl_cmd)

        kubectl_return = subprocess.run(kubectl_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
        kubectl_out = kubectl_return.stdout.decode('utf-8')

        return kubectl_out
