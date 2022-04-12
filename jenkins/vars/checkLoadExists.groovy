// Copyright 2022 MobiledgeX, Inc
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

def call(dateValue) {
    def s = 'curl -s https://robot\\$qa:RIuSwsdA9naFkunkDtg7TrPOHG3YoqS8@harbor.mobiledgex.net/v2/mobiledgex/edge-cloud/tags/list | jq ".tags | index(\\"' + dateValue + '\\")"'
    def index  = sh(script: s, returnStdout: true);
    println "curloutput=${index}"
    if(index.trim() == 'null') {
        println "${s} failed"
        currentBuild.result = 'FAILURE'
        error("load ${dateValue} not found")
    } else {
        println "load ${dateValue} found"
    }
}
