import os
import logging
from linux import Linux

class Rootlb(Linux):
    def __init__(self, kubeconfig=None, host=None, port=22, username='ubuntu', key_file='id_rsa_mex', cluster_name=None, verbose=False):
        logging.debug('init')

        self.kubeconfig = kubeconfig

        if kubeconfig is None:
            self.kubeconfig = host + '.kubeconfig'
            
        if not os.path.isfile(key_file):
            key_file_pre = key_file
            key_file = os.environ['HOME'] + '/.mobiledgex/' + os.path.basename(key_file)
            logging.warning('{} not found. using {}'.format(key_file_pre, key_file))
        try:
            super().__init__(host=host, port=port, username=username, key_file=key_file, verbose=verbose)
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

        print(output)

        return output

    def get_docker_container_id(self):
        cmd = 'docker ps --format "{{.ID}}"'
        logging.info('executing ' + cmd)
        (output, err, errcode) = self.command(cmd)
        logging.debug('output=' + str(output))

        if errcode != 0:
            raise Exception("cmd returned non-zero status of " + errcode)

        print(output)
        
        #ps_list = []
        #output.pop(0)  #remove header
        #for line in output:
        #    print('*WARN*', line)
        #    ps_dict = {'container_id': 
        return output[0].rstrip()

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

    def run_command(self, cmd):
        (output, err, errcode) = self.command(cmd)
        logging.debug('output=' + str(output))

        if errcode != 0:
            raise Exception("cmd returned non-zero status of " + str(errcode))

        print(output)

        return output
