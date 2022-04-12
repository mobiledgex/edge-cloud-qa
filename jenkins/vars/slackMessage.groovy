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

import groovy.transform.Field

@Field slackurl = 'https://mobiledgex.slack.com/services/hooks/jenkins-ci/'
@Field slackcred = 'cdda7d70-b701-4983-b287-e3f46dde02e9'
@Field slackchannel = '#qa-automation'

def good(message) {
    print('good')
    slackSend baseUrl: slackurl, tokenCredentialId: slackcred, channel: slackchannel, color: "good", message: message
}
def fail(message) {
    print('fail')
    slackSend baseUrl: slackurl, tokenCredentialId: slackcred, channel: slackchannel, color: "danger", message: message
}
def warning(message) {
    print('warning')
    slackSend baseUrl: slackurl, tokenCredentialId: slackcred, channel: slackchannel, color: "warning", message: message
}

