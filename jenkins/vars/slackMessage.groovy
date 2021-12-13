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

