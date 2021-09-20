read -e -p "enter version for build x.x or x.x.x : " version
echo "version=$version"

echo $version > VERSION

docker build -t jmeterplus8076:$version .
docker tag jmeterplus8076:$version docker-qa.mobiledgex.net/automation_dev_org/images/jmeterplus8076:$version
