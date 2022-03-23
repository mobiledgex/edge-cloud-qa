# used on mexdemo.locsim.mobiledgex.net for egress port testing
docker run --name egress_simulator -d -p 2016:2016/udp -p 2015:2015/udp -p 2016:2016 -p 2015:2015 docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded:11.0
