import json
import logging
import os
import subprocess
import sys


class MexOpenstack():
    def __init__(self, environment_file):
        self.env_file = self._findFile(environment_file)

    def get_openstack_server_list(self, name=None):
        cmd = f'source {self.env_file};openstack server list -f json'

        if name:
            cmd += f' --name {name}'

        logging.debug(f'getting openstack server list with cmd = {cmd}')
        o_return = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True, executable='/bin/bash')
        o_out = o_return.stdout.decode('utf-8')
        o_err = o_return.stderr.decode('utf-8')

        if o_err:
            raise Exception(o_err)

        logging.debug(o_out)
        
        return json.loads(o_out)

    def get_openstack_image_list(self, name=None):
        cmd = f'source {self.env_file};openstack image list -f json'

        if name:
            cmd += f' --name {name}'

        logging.debug(f'getting openstack image list with cmd = {cmd}')
        o_return = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True, executable='/bin/bash')
        o_out = o_return.stdout.decode('utf-8')
        o_err = o_return.stderr.decode('utf-8')

        if o_err:
            raise Exception(o_err)

        logging.debug(o_out)
        
        return json.loads(o_out)


    def delete_openstack_image(self, name=None):
        cmd = f'source {self.env_file};openstack image delete {name}'

        logging.debug(f'deleting openstack image with cmd = {cmd}')
        o_return = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True, executable='/bin/bash')
        o_out = o_return.stdout.decode('utf-8')
        o_err = o_return.stderr.decode('utf-8')

        if o_err:
            raise Exception(o_err)

        logging.debug(o_out)
        
        #return json.loads(o_out)

    def get_openstack_limits(self):
        cmd = f'source {self.env_file};openstack limits show -f json --absolute'

        logging.debug(f'getting limits with cmd = {cmd}')
        o_return = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True, executable='/bin/bash')
        o_out = o_return.stdout.decode('utf-8')
        o_err = o_return.stderr.decode('utf-8')

        if o_err:
            raise Exception(o_err)

        logging.debug(o_out)

        limit_dict = {}
        for name in json.loads(o_out):
            limit_dict[name['Name']] = name['Value']
            
        return limit_dict

    def get_flavor_list(self):
        cmd = f'source {self.env_file};openstack flavor list -f json'

        logging.debug(f'getting flavor list with cmd = {cmd}')
        output = self._execute_cmd(cmd)
        
        return json.loads(output)

    def flavor_should_exist(self, flavors, ram, disk, cpu):
        for flavor in flavors:
            print('*WARN*', flavor['RAM'], flavor['Disk'], flavor['VCPUs'], ram, disk, cpu)
            if int(flavor['RAM']) == int(ram) and int(flavor['Disk']) == int(disk) and int(flavor['VCPUs']) == int(cpu):
                logging.info('found matching flavor', flavor)
                return True

        raise Exception(f'No flavor found matching ram={ram}, disk={disk}, cpu={cpu}')
    
    def _execute_cmd(self, cmd):
        o_return = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True, executable='/bin/bash')
        o_out = o_return.stdout.decode('utf-8')
        o_err = o_return.stderr.decode('utf-8')

        if o_err:
            raise Exception(o_err)

        logging.debug(o_out)

        return o_out
    
    def _findFile(self, path):
        for dirname in sys.path:
            candidate = os.path.join(dirname, path)
            if os.path.isfile(candidate):
                return candidate
        raise Exception('cant find file {}'.format(path))


    def get_openstack_network_list(self,name=None):
        cmd = f'source {self.env_file};openstack network list -f json'

        if name:
            cmd += f' --name {name}'

        logging.debug(f'getting network server list with cmd = {cmd}')
        o_return = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True, executable='/bin/bash')
        o_out = o_return.stdout.decode('utf-8')
        o_err = o_return.stderr.decode('utf-8')

        if o_err:
            raise Exception(o_err)

        logging.debug(o_out)
        
        return json.loads(o_out)

    def get_openstack_subnet_list(self,name=None):
        cmd = f'source {self.env_file};openstack subnet list -f json'

        if name:
            cmd += f' --name {name}'

        logging.debug(f'getting flavour subnet list with cmd = {cmd}')
        o_return = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True, executable='/bin/bash')
        o_out = o_return.stdout.decode('utf-8')
        o_err = o_return.stderr.decode('utf-8')

        if o_err:
            raise Exception(o_err)

        logging.debug(o_out)
        
        return json.loads(o_out)
  
    def get_openstack_router_list(self,name=None):
        cmd = f'source {self.env_file};openstack router list -f json'

        if name:
            cmd += f' --name {name}'

        logging.debug(f'getting router router list with cmd = {cmd}')
        o_return = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True, executable='/bin/bash')
        o_out = o_return.stdout.decode('utf-8')
        o_err = o_return.stderr.decode('utf-8')

        if o_err:
            raise Exception(o_err)

        logging.debug(o_out)
        
        return json.loads(o_out)

    def get_openstack_flavour_list(self,name=None):
        cmd = f'source {self.env_file};openstack flavor list -f json'

        if name:
            cmd += f' --name {name}'

        logging.debug(f'getting router flavor list with cmd = {cmd}')
        o_return = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True, executable='/bin/bash')
        o_out = o_return.stdout.decode('utf-8')
        o_err = o_return.stderr.decode('utf-8')

        if o_err:
            raise Exception(o_err)

        logging.debug(o_out)
        
        return json.loads(o_out)


    def get_openstack_security_list(self,name=None):
        cmd = f'source {self.env_file};openstack security group list -f json'

        if name:
            cmd += f' --name {name}'

        logging.debug(f'getting security security group  list with cmd = {cmd}')
        o_return = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True, executable='/bin/bash')
        o_out = o_return.stdout.decode('utf-8')
        o_err = o_return.stderr.decode('utf-8')

        if o_err:
            raise Exception(o_err)

        logging.debug(o_out)
        
        return json.loads(o_out)
