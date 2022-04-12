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

FROM python:3

RUN apt-get update
#RUN apt-get -y install software-properties-common
#RUN add-apt-repository ppa:git-core/ppa
#RUN apt-get update

RUN apt-get -y install vim
RUN apt-get -y install dnsutils
#RUN apt-get install git 

RUN python -m pip install --upgrade pip
RUN pip3 install robotframework
RUN pip3 install PyJWT 
RUN pip3 install requests
#RUN pip3 install grpcio
#RUN pip3 install grpcio-tools
RUN pip3 install paramiko
RUN pip3 install opencv-python  # used for facedetection client
RUN pip3 install websockets
RUN pip3 install cloudflare
RUN pip3 install websocket-client

#RUN git clone --depth 1 https://16a8cf8e79fad4a98bba2e59544d8faf78fca71d:@github.com/mobiledgex/edge-cloud-qa.git modules 
#RUN cd modules 
#RUN git filter-branch --prune-empty --subdirectory-filter modules HEAD

RUN useradd -ms /bin/bash automation
USER automation
WORKDIR /home/automation

RUN mkdir edge-cloud-qa;cd edge-cloud-qa;git init;git remote add -f origin https://16a8cf8e79fad4a98bba2e59544d8faf78fca71d:@github.com/mobiledgex/edge-cloud-qa.git
RUN cd edge-cloud-qa;git config core.sparseCheckout true
RUN cd edge-cloud-qa;echo "modules\ntestcases/cloudletverification" >> .git/info/sparse-checkout
RUN cd edge-cloud-qa;git pull origin master
RUN mkdir edge-cloud-qa/testcases/cloudletverification/logs

RUN cd /home/automation; cp edge-cloud-qa/testcases/cloudletverification/README README

#RUN git clone https://16a8cf8e79fad4a98bba2e59544d8faf78fca71d:@github.com/mobiledgex/edge-cloud-qa.git

ENV PYTHONPATH=/home/automation/edge-cloud-qa/modules
#ENV AUTOMATION_MC_ADDRESS=console-qa.mobiledgex.net:443
#ENV AUTOMATION_MC_CERT=

ENTRYPOINT ["bash", "-c", "source /home/automation/edge-cloud-qa/testcases/cloudletverification/cloudletverification.env && \"$@\"", "-s"]


