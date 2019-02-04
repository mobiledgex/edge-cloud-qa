import paramiko
import logging.config
import logging
import sys

class Linux():
    client = None

    def __init__(self, host = None, port = 22, username = None, password = None, key_file = None, logfile = '/tmp/sshLogfile.txt', verbose=False):
        #logging.config.fileConfig('logging.ini')
        logging.debug("init")

        #logging.getLogger("paramiko").setLevel(logging.INFO)
        logging.info('host=%s port=%d username=%s password=%s key_file=%s logfile=%s', host, port, username, password, key_file, logfile)

        if verbose:
            logging.getLogger("paramiko").setLevel(logging.DEBUG) 

        #paramiko.util.log_to_file(logfile)

        self.client = paramiko.SSHClient()
        self.client.load_system_host_keys()
        self.client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

        try:
            if key_file is not None:
                logging.info('connecting with keyfile=' + key_file)
                if password is not None:
                    k = paramiko.RSAKey.from_private_key_file(key_file, password = password)
                    self.client.connect(hostname = host, port = port, username = username, password = password, pkey = k)
                else:
                    k = paramiko.RSAKey.from_private_key_file(key_file)
                    self.client.connect(hostname = host, port = port, username = username, pkey = k)
            else:
                self.client.connect(hostname = host, port = port, username = username, password = password)
        except ValueError as err1:
            logging.error('caught ssh connect error:' + str(err1))
            raise ConnectionError
        except paramiko.ssh_exception.SSHException as err2:
            logging.error('caught ssh connect error:' + str(err2) + '. Check username/password/keyfile')
            raise ConnectionError

    def command(self, cmd):
        logging.debug('entry')
        logging.info('running ' + cmd)
        stdin, stdout, stderr = self.client.exec_command(cmd)
        exit_status = stdout.channel.recv_exit_status()
        o = stdout.readlines()
        e = stderr.readlines()
        #logging.debug('stdin=' + str(stdin.readlines()) + ' stdout=' + str(stdout.readlines()) + ' stderr=' + str(stderr.readlines()))
        logging.debug('exit_status=' + str(exit_status) + ' stdout=' + str(o) + ' stderr=' + str(e))
        if exit_status != 0 or len(e) > 0:
            #raise Exception("cmd=" + cmd + " returned non-zero status of " + str(exit_status) + " or has stderr of " + str(e))
            logging.error("cmd=" + cmd + " returned non-zero status of " + str(exit_status) + " or has stderr of " + str(e))
        
        return (o, e, exit_status)

    def sftp_put(self, src, dest):
        logging.info('sftp %s to %s' % (src, dest))
        try:
            sftp = self.client.open_sftp()
            sftp.put(src, dest)
        except IOError:
            print("XXXXXX")
        

    def get_processes(self, process_name = None):
        logging.debug('entry')

        cmd = 'ps -ef'
        plist = []
        
        if process_name:
            logging.info('getting processes for ' + process_name)
            cmd = cmd + ' | grep ' + process_name + ' | grep -v grep'
        else:
            logging.info('getting all processes')

        #stdout = ''
        #try:
        (stdout, stderr, rt) = self.command(cmd)
        #except Exception:
            # have seen case where exitcode=0 and stdout has correnct info but stderr='Unknown HZ value!'
            # so try to process the output anyway
            #logging.error('got command error. ignoring.') 
            #if len(stderr) > 0:
        #    raise Exception(stderr)

        print('stdout=' + str(stdout))
        for l in stdout:
            ls = l.rstrip().split()
            print(ls)
            ldict = {'uid': ls[0], 'pid':ls[1], 'ppid':ls[2],'c':ls[3], 'stime':ls[4], 'tty':ls[5], 'time':ls[6], 'cmd': ls[7]}
            plist.append(ldict)

        logging.debug('exit')
        
        return plist

    def get_pid(self, process_name = None):
        logging.debug('entry')
        logging.info('process_name=' + process_name)

        pid = None
        try:
            p = self.get_processes(process_name = process_name)
            pid = p[0]['pid']
        except:
            logging.error('pid for ' + process_name + ' not found')
            
        logging.debug('exit')
        
        return pid

    def kill_pid(self, pid = None, signal = None):
        logging.debug('entry')
        logging.info('pid=' + pid)

        cmd = 'kill '
        if signal:
            cmd = cmd + ' -' + signal
        cmd = cmd + ' ' + pid


        (stdout, stderr, rt) = self.command(cmd)

        logging.debug('exit')

    def kill_process(self, process_name = None):
        logging.debug('entry')
        logging.info('process_name=' + process_name)
        
        pid = self.get_pid(process_name = process_name)
        if pid is not None:
            logging.info('killing pid=' + pid)
            self.kill_pid(pid)
        else:
            logging.error('no pid returned')
            raise ValueError('pid for process={} not found'.format(process_name))

        logging.debug('exit')
        return(pid)

