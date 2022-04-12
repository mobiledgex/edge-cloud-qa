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

FROM ubuntu:18.04
MAINTAINER Tom Dunkle
RUN apt-get update \
&& apt-get install -y curl \
&& apt-get install -y vim \
&& apt-get install -y netcat \
&& apt-get install -y jmeter \
&& apt-get install -y stress-ng && apt-get install -y stress \
&& apt-get install -y apache2 && apt-get install -y net-tools && apt-get install -y iputils-ping \
&& apt-get clean && rm -rf /var/lib/apt/lists/*   
COPY stressngbash.sh /
COPY jmeterx8076.jmx /
COPY jmeterbash.sh /
COPY diskbash.sh /
COPY all_measurements.sh /
RUN chmod +x /*.sh
ENV APACHE_RUN_USER  www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR   /var/log/apache2
ENV APACHE_PID_FILE  /var/run/apache2/apache2.pid
ENV APACHE_RUN_DIR   /var/run/apache2
ENV APACHE_LOCK_DIR  /var/lock/apache2
ENV APACHE_LOG_DIR   /var/log/apache2
ENV APACHE_WEB1_DIR   /var/www/8076
ENV APACHE_WEB2_DIR   /var/www/8077
ENV APACHE_WEB3_DIR   /var/www/9090
RUN mkdir -p $APACHE_RUN_DIR
RUN mkdir -p $APACHE_LOCK_DIR
RUN mkdir -p $APACHE_LOG_DIR
RUN mkdir -p $APACHE_WEB1_DIR
RUN mkdir -p $APACHE_WEB2_DIR
RUN mkdir -p $APACHE_WEB3_DIR
COPY ports.conf /etc/apache2
COPY 000-default.conf /etc/apache2/sites-enabled
COPY index1.html /var/www/8076/index.html
COPY index2.html /var/www/8077/index.html
COPY index3.html /var/www/9090/index.html
EXPOSE 8076
EXPOSE 8077
EXPOSE 9090
CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]
