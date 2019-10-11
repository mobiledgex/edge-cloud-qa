import logging
import subprocess

logging.basicConfig(format='%(asctime)s %(levelname)s %(funcName)s line:%(lineno)d - %(message)s',datefmt='%d-%b-%y %H:%M:%S')
logger = logging.getLogger('mex_mastercontroller rest')

class MexArtifactory():

    def __init__(self):
        # self.username = 'mexadmin'
        # self.password = 'mexadmin123'
        # self.image = 
        pass

    def curl_image_to_artifactory(self, username, password, server, org_name, image_name):
        cmd = f'curl -u{username}:{password} -T {image_name} "https://{server}/artifactory/repo-{org_name}/{image_name}" --fail -v'

        logging.info(cmd)
        #cmd2 = shlex.split(cmd)
        #print('*WARN*', 'cmd2', cmd2)
        
        process = subprocess.Popen(cmd,
                                   stdout=subprocess.PIPE,
                                   stderr=subprocess.PIPE,
                                   shell=True
        )                
        stdout = process.stdout.readlines()
        stderr = process.stderr.readlines()
        process.wait()
        
        print('*WARN*', 'std', stdout)
        print('*WARN*', 'stderr=' ,stderr)
        print('*WARN*', 'return code=' ,process.returncode)
        
        if process.returncode != 0 or f'"createdBy" : "{username}"' not in stdout[4].decode('utf-8'):
            raise Exception(f'artifactory curl failed:  {stderr} {stdout}')

        return stdout
