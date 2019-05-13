import logging
import subprocess
import json
import os
import sys

class MexOpenstack():
    def __init__(self, environment_file):
        self.env_file = self._findFile(environment_file)

    def get_openstack_server_list(self, name=None):
        cmd = f'source {self.env_file};openstack server list -f json'

        if name:
            cmd += f' --name {name}'

        logging.debug(f'getting openstack server list with cmd = {cmd}')
        o_return = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
        o_out = o_return.stdout.decode('utf-8')
        o_err = o_return.stderr.decode('utf-8')

        if o_err:
            raise Exception(o_err)

        logging.debug(o_out)
        
        return json.loads(o_out)


    def _findFile(self, path):
        for dirname in sys.path:
            candidate = os.path.join(dirname, path)
            if os.path.isfile(candidate):
                return candidate
        raise Exception('cant find file {}'.format(path))
