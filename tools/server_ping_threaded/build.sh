echo "version=$1"

echo $1 > VERSION

docker build -t server_ping_threaded:$1 .
docker tag server_ping_threaded:9.0 docker-qa.mobiledgex.net/mobiledgex/images/server_ping_threaded:$1
