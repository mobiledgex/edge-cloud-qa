FROM python:3.7

RUN apt-get update && apt-get install -y vim && apt-get install -y net-tools && apt-get install -y lsof

ENV PYTHONPATH=/usr/local/lib/python3.7/site-packages/
RUN pip3 install tornado

ADD server_ping_threaded.py /
ADD automation.html /
ADD VERSION /

ENTRYPOINT ["./server_ping_threaded.py"]
