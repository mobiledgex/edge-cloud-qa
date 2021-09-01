FROM python:3.9.7

RUN apt-get update && apt-get install -y vim && apt-get install -y net-tools && apt-get install -y lsof

ENV PYTHONPATH=/usr/local/lib/python3.9/site-packages/
RUN pip install tornado

ADD server_ping_threaded.py /
ADD automation.html /
ADD VERSION /

ENTRYPOINT ["./server_ping_threaded.py"]
