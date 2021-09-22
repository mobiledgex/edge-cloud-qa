read -e -p "enter version for build x.x or x.x.x : " version
echo "version=$version"

echo $version > VERSION

docker build -t jmeterplus8086:$version .
docker tag jmeterplus8086:10.8.6 docker-qa.mobiledgex.net/automation_dev_org/images/jmeterplus8086:$version
