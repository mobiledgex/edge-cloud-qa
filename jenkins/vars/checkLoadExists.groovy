import java.text.SimpleDateFormat

def call() {
    date = new Date()
    sdate = new SimpleDateFormat("yyy-MM-dd")
    Calendar cal = Calendar.getInstance()
                
    if(params.BuildDate == "today") {
        dateValue = sdate.format(date)
    } else {
        dateValue = params.BuildDate
    }
    echo dateValue

    cycle = dateValue + '_' + params.Version
    currentBuild.displayName = cycle

    slackMessage.good('Starting regression for ' + cycle)

    def s = 'curl -s https://robot\\$qa:RIuSwsdA9naFkunkDtg7TrPOHG3YoqS8@harbor.mobiledgex.net/v2/mobiledgex/edge-cloud/tags/list | jq ".tags | index(\\"' + dateValue + '\\")"'
    def index  = sh(script: s, returnStdout: true);
    if(index == 'null') {
        println "${s} failed"
        currentBuild.result = 'FAILURE'
    }
}
