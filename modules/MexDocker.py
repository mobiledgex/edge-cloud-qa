import logging
import subprocess
import shlex


logging.basicConfig(format='%(asctime)s %(levelname)s %(funcName)s line:%(lineno)d - %(message)s',datefmt='%d-%b-%y %H:%M:%S')
logger = logging.getLogger('mex_mastercontroller rest')

class MexDocker():

    def __init__(self):
       # self.username = 'mexadmin'
       # self.password = 'mexadmin123'
       # self.image = 
       pass


    def push_image_to_docker(self, username, password, server, app_name, org_name, app_version):
        org_name= org_name.lower()
        cmd = f'docker login -u {username} -p {password} {server} && docker tag {app_name} {server}/{org_name}/images/{app_name}:{app_version} && docker push {server}/{org_name}/images/{app_name}:{app_version}'
        #cmd=f'docker tag {app_name} {server}/{org_name}/images/{app_name}:{app_version} && docker push {server}/{org_name}/images/{app_name}:{app_version}'
        
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
        
        if process.returncode != 0:
            raise Exception(f'docker push failed:  {stderr} {stdout}')
                
                

