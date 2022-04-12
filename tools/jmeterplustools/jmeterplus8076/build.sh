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

read -e -p "enter version for build x.x or x.x.x : " version
echo "version=$version"

echo $version > VERSION

docker build -t jmeterplus8076:$version .
docker tag jmeterplus8076:$version docker-qa.mobiledgex.net/automation_dev_org/images/jmeterplus8076:$version
docker tag jmeterplus8076:$version docker-qa.mobiledgex.net/mobiledgex/images/jmeterplus8076:$version
docker tag jmeterplus8076:$version docker-qa.mobiledgex.net/wwtdev/images/jmeterplus8076:$version
