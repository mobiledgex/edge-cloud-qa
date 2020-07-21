FROM python:3.7
MAINTAINER molguin <molguin@kth.se>

RUN apt-get update -q && apt-get install git && apt-get clean
RUN apt-get install -y vim
RUN cd / && git clone https://github.com/molguin92/CPULoadGenerator.git /CPULoadGenerator
RUN pip install -r /CPULoadGenerator/requirements.txt

ADD cpugenerator.py /

WORKDIR /CPULoadGenerator
#ENTRYPOINT ["./CPULoadGenerator.py"]
ENTRYPOINT ["/cpugenerator.py"]
