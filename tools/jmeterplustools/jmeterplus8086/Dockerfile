FROM ubuntu:18.04
MAINTAINER Tom Dunkle
RUN apt-get update \
&& apt-get install -y curl \
&& apt-get install -y vim \
&& apt-get install -y netcat \
&& apt-get install -y jmeter \
&& apt-get install -y stress-ng && apt-get install -y stress \
&& apt-get install -y apache2 && apt-get install -y net-tools \
&& apt-get clean && rm -rf /var/lib/apt/lists/*   
COPY stressngbash.sh /
COPY jmeterx8086.jmx /
COPY jmeterbash.sh /
COPY diskbash.sh /
RUN chmod +x /*.sh
ENV APACHE_RUN_USER  www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR   /var/log/apache2
ENV APACHE_PID_FILE  /var/run/apache2/apache2.pid
ENV APACHE_RUN_DIR   /var/run/apache2
ENV APACHE_LOCK_DIR  /var/lock/apache2
ENV APACHE_LOG_DIR   /var/log/apache2
RUN mkdir -p $APACHE_RUN_DIR
RUN mkdir -p $APACHE_LOCK_DIR
RUN mkdir -p $APACHE_LOG_DIR
COPY ports.conf /etc/apache2
COPY 000-default.conf /etc/apache2/sites-enabled
COPY index.html /var/www/html
EXPOSE 8086
CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]
