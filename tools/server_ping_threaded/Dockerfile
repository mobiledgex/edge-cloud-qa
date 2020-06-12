FROM python:3

RUN apt-get update && apt-get install -y vim

ENV PYTHONPATH=/usr/local/lib/python3.7/site-packages/
RUN pip3 install tornado

ADD server_ping_threaded.py /
ADD automation.html /

ENTRYPOINT ["./server_ping_threaded.py"]
