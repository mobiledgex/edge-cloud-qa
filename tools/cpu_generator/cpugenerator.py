#!/usr/bin/python3
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


import socket
#import random
import _thread
import datetime
import time
import socketserver
import string
import subprocess

port = 2017
protocol = 'tcp'
outfile = 'cpugenerator_outfile.txt'

def writefile(s):
    with open(outfile,'a+') as f:
        print(s, flush=True)
        #print('writing')
        f.write(str(datetime.datetime.now()) + ' ' + s + '\n')

def start_tcp_ping(thread_name, port):
    ssocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    ssocket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)   # SO_REUSEADDR flag tells the kernel to reuse a local socket in TIME_WAIT state, without waiting for its natural timeout to expire
    ssocket.bind(('', port))
    ssocket.listen(1)
    writefile('thread={} protocol=tcpservertport={}'.format(thread_name, port))

    while True:
        conn, addr = ssocket.accept()

        while True:
            #print('waiting for data')
            data = conn.recv(1024)
            #print('conn after recv')
            if not data: 
               #print('no data')
               break

            writefile(f'recved tcp data from thread={thread_name} port={port}')
            print(data,'xx',data.decode('utf-8'))
            if 'load=' in data.decode('utf-8'):
               load_value = data.decode('utf-8').split('=')[1]
               writefile(f'setting load to {load_value}% from thread={thread_name} port={port}')

               try:
                  kill_cmd = "kill -9 $(ps -ef | grep CPULoadGenerator |  grep -v grep | awk '{{print $2}}')"
                  writefile(f'executing:{kill_cmd}')
                  cp = subprocess.run(kill_cmd, shell=True, check=True)
                  writefile(f'cp={cp}')
                  writefile(f'killcmd returned {cp.returncode}')
               except subprocess.CalledProcessError as e:
                  writefile(f'Error killing cpugenerator, caught {e}')

               try:
                  #load_cmd = f'docker run cpuloadgenerator:latest -l {load_value} &'
                  load_value_cmd = int(load_value)/100
                  load_cmd = f'python3 CPULoadGenerator.py -l {load_value_cmd} &'
                  writefile(f'starting cpuloadgenerator cmd={load_cmd}')
                  cprun = subprocess.run(load_cmd, shell=True, check=True)
                  writefile(f'cprun={cprun}')
               except Exception as e:
                  writefile(f'caught calledpe')
                  conn.sendall(bytes(f'error{e}', encoding='utf-8'))
               except subprocess.CalledProcessError as e:
                  writefile(f'caught calledpe')
                  conn.sendall(bytes(f'error{e}', encoding='utf-8'))

               try:
                  time.sleep(1)
                  ps_cmd = "ps -ef | grep '[C]PULoadGenerator'"
                  writefile(f'checking process cmd={ps_cmd}')
                  psrun = subprocess.run(ps_cmd, shell=True, check=True)
                  writefile(f'psrun={psrun}')
               except subprocess.CalledProcessError as e:
                  writefile(f'caught pserror:{e}')
                  conn.sendall(bytes(f'error{e}', encoding='utf-8'))

            conn.sendall(bytes('pong', encoding='utf-8'))
    #    print('recved', data)

writefile('starting tcp thread')
_thread.start_new_thread(start_tcp_ping, ("Thread-1", port))
writefile('all threads started')

while 1:
   time.sleep(1) 
