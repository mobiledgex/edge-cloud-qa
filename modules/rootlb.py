import os
import logging
from linux import Linux
from kubernetes import Kubernetes

class Rootlb(Linux):
    def __init__(self, kubeconfig=None, host=None, port=22, username='ubuntu', key_file='id_rsa', cluster_name=None, verbose=False, signed_key='signed-key', proxy_to_node=None):
        logging.debug('init')

        self.kubeconfig = kubeconfig
        
        if kubeconfig is None:
            self.kubeconfig = host + '.kubeconfig'
            
        if not os.path.isfile(key_file):
            key_file_pre = key_file
            key_file = os.environ['HOME'] + '/.ssh/' + os.path.basename(key_file)
            signed_key = os.environ['HOME'] + '/.ssh/' + os.path.basename(signed_key)
            logging.warning('{} not found. using {}'.format(key_file_pre, key_file))

        try:
            super().__init__(host=host, port=port, username=username, key_file=key_file, verbose=verbose, signed_key=signed_key, proxy_to_node=proxy_to_node)
        except ConnectionError as err1:
            logging.error('caught ssh error:' + str(err1))
            raise ConnectionError


    def get_pods(self):
        cmd = f'KUBECONFIG={self.kubeconfig} kubectl get pods'
        logging.info('executing ' + cmd)
        (output, err, errcode) = self.command(cmd)
        logging.debug('output=' + str(output))

        if errcode != 0:
            raise Exception("cmd returned non-zero status of " + errcode)

        return output


    def get_deploy(self):
        cmd = f'KUBECONFIG={self.kubeconfig} kubectl get deploy -o name'
        logging.info('executing ' + cmd)
        (output, err, errcode) = self.command(cmd)
        logging.debug('output=' + str(output))

        if errcode != 0:
            raise Exception("cmd returned non-zero status of " + errcode)

        return output

    def k8s_scale_replicas(self, instance, no_of_replicas):
        cmd = f'KUBECONFIG={self.kubeconfig} kubectl scale --replicas={no_of_replicas} deploy/{instance}'
        logging.info('executing ' + cmd)
        (output, err, errcode) = self.command(cmd)
        logging.debug('output=' + str(output))

        if errcode != 0:
            raise Exception("cmd returned non-zero status of " + errcode)

        return output

    def get_pod(self, pod_name, pod_state=None):
        pod_list = self.get_pods()

        for pod in pod_list:
            if pod_state:
                state_found = pod.split()[2]
            else:
                state_found = pod_state
            logging.info(f'looking for pod={pod_name} and state={state_found}')
            if pod_name in pod and pod_state == state_found:
                logging.info(f'found pod={pod_name}')
                return pod.split()[0]

        raise Exception(f'pod with name={pod_name} not found')

    def delete_pod(self, pod_name):
        real_pod_name = self.get_pod(pod_name)
        
        cmd = f'KUBECONFIG={self.kubeconfig} kubectl delete pod {real_pod_name}'
        logging.info('executing ' + cmd)
        (output, err, errcode) = self.command(cmd)
        logging.debug('output=' + str(output))

        logging.info(f'waiting for pod restart of {pod_name}')
        new_pod_name = None
        for count in range(30):
            try:
                new_pod_name = self.get_pod(pod_name=pod_name, pod_state='Running')
                if new_pod_name != real_pod_name:
                    break
            except:
                sleep(1)
                
        if not new_pod_name:
            raise Exception(f'pod={pod_name} of Running status not found')
        
    def helm_list(self):
        cmd = f'KUBECONFIG={self.kubeconfig} helm list'
        logging.info('executing ' + cmd)
        (output, err, errcode) = self.command(cmd)
        logging.debug('output=' + str(output))

        if errcode != 0:
            raise Exception("cmd returned non-zero status of " + errcode)

        return output

    def stop_docker_container(self, container_id, background=False):
        cmd = f'docker stop {container_id}'

        logging.info('executing ' + cmd)
        (output, err, errcode) = self.command(cmd, background=background)
        logging.debug('output=' + str(output))

        if errcode != 0:
            raise Exception("cmd returned non-zero status of " + errcode)

        return output

    def start_docker_container(self, container_id):
        cmd = f'docker start {container_id}'

        logging.info('executing ' + cmd)
        (output, err, errcode) = self.command(cmd)
        logging.debug('output=' + str(output))

        if errcode != 0:
            raise Exception("cmd returned non-zero status of " + errcode)

        return output

    def restart_docker_container(self, container_id):
        cmd = f'docker restart {container_id}'

        logging.info('executing ' + cmd)
        (output, err, errcode) = self.command(cmd)
        logging.debug('output=' + str(output))

        if errcode != 0:
            raise Exception("cmd returned non-zero status of " + errcode)

        return output

    def get_stopped_docker_container_id(self, name=None):
        cmd = 'docker ps -a --format "{{.ID}}"'
        if name:
            cmd = cmd + f' --filter name=^{name}'

        logging.info('executing ' + cmd)
        (output, err, errcode) = self.command(cmd)
        logging.debug('output=' + str(output))

        if errcode != 0:
            raise Exception("cmd returned non-zero status of " + errcode)

        output = [id.rstrip() for id in output]

        return output

    def get_docker_container_id(self, name=None):
        cmd = 'docker ps --format "{{.ID}}"'
        if name:
            cmd = cmd + f' --filter name=^{name}'
            
        logging.info('executing ' + cmd)
        (output, err, errcode) = self.command(cmd)
        logging.debug('output=' + str(output))

        if errcode != 0:
            raise Exception("cmd returned non-zero status of " + errcode)

        output = [id.rstrip() for id in output]

        #ps_list = []
        #output.pop(0)  #remove header
        #for line in output:
        #    print('*WARN*', line)
        #    ps_dict = {'container_id': 
        #return output[0].rstrip()
        
        return output

    def get_docker_container_info(self, container_id):
        cmd = f'docker inspect --format="{{{{.State.Status}}}} {{{{.Config.Image}}}} {{{{.Path}}}}" {container_id}'
        logging.info('executing ' + cmd)
        (output, err, errcode) = self.command(cmd)
        logging.debug('output=' + str(output))

        if errcode != 0:
            raise Exception("cmd returned non-zero status of " + errcode)

        print(output)
        (status, image, path) = output[0].split(' ')
        info_dict = {'status': status, 'image': image, 'path': path} 

        return info_dict

    def block_port(self, port, target):
        logging.info(f'blocking port={port} target={target}')

        cmd = f'sudo iptables -A INPUT -p tcp --dport {port} -j DROP'

        output = self.run_command(cmd)
        
        return output

    def unblock_port(self, port, target):
        logging.info(f'blocking port={port} target={target}')

        cmd = f'sudo iptables -D INPUT -p tcp --dport {port} -j DROP'

        output = self.run_command(cmd)
        
        return output

    def reboot(self):
        try:
            logging.info('rebooting rootlb')
            self.run_command('sudo reboot')
        except:
            logging.info('caught reboot exception')

            
    def mount_exists_on_pod(self, pod, mount):
        logging.info(f'checking if mount exists on pod={pod} mount={mount}')

        cmd = f'df {mount}'

        real_pod = self.get_pod(pod)
        self.run_command_on_pod(real_pod, cmd)
        
        #k8s = Kubernetes(kubeconfig=self.kubeconfig)

        #k8s.exec_command(pod_name=real_pod, command=command)

    def write_file_to_pod(self, pod, mount, data=None):
        logging.info(f'writing file on pod pod={pod} mount={mount}')

        real_pod = self.get_pod(pod)
        
        data_to_write = None
        if data:
            data_to_write = data
        else:
            data_to_write = pod

        filename = f'{mount}/{pod}.txt'
        cmd = f'echo {data_to_write} > {filename}'

        self.run_command_on_pod(real_pod, cmd)

        return filename

    def read_file_from_pod(self, pod, filename):
        logging.info(f'reading file on pod pod={pod} file={filename}')

        real_pod = self.get_pod(pod)
        
        cmd = f'cat {filename}'

        output = self.run_command_on_pod(real_pod, cmd)

        return output
    
    def run_command_on_pod(self, pod_name, command):
        kubectl_cmd = f'KUBECONFIG={self.kubeconfig} kubectl exec -it {pod_name} -- bash -c "{command}"'

        output = self.run_command(kubectl_cmd)
        return output

    def run_command_on_container(self, container_name, command):
        cmd = f'docker exec -it {container_name} bash -c "{command}"'

        output = self.run_command(cmd)
        return output

    def write_file_to_node(self, node, mount, data=None):
        logging.info(f'write file to node={node} mount={mount}')
        #network, ip = node.split('=')

        data_to_write = None
        if data:
            data_to_write = data
        else:
            data_to_write = ip

        command = f'sudo bash -c "echo {data_to_write} > /var/opt/{data_to_write}_node.txt"'
        self.run_command_on_node(node, command)
        
    def run_command_on_node(self, node, command):
        #network, ip = node.split('=')
        #command = f'ssh -i id_rsa_mex ubuntu@{ip} \'{command}\''
        #command = f'ubuntu@{ip} \'{command}\''

        output = self.run_command(command)

        return output
    
    def run_command(self, cmd):
        (output, err, errcode) = self.command(cmd)
        logging.debug('output=' + str(output))

        if errcode != 0:
            raise Exception("cmd returned non-zero status of " + str(errcode))

        print(output)

        return output
