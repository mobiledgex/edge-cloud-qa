slackurl = 'https://mobiledgex.slack.com/services/hooks/jenkins-ci/'
slackcred = 'cdda7d70-b701-4983-b287-e3f46dde02e9'
slackchannel = '#qa-automation'

def good(message) {
    slackSend baseUrl: slackurl, tokenCredentialId: slackcred, channel: slackchannel, color: "good", message: message
}
def fail(message) {
    slackSend baseUrl: slackurl, tokenCredentialId: slackcred, channel: slackchannel, color: "danger", message: message
}
def warning(message) {
    slackSend baseUrl: slackurl, tokenCredentialId: slackcred, channel: slackchannel, color: "warning", message: message
}

