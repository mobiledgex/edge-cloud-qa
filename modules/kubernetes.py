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

        return kubectl_out
        
