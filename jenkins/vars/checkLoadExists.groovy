def call(dateValue) {
    def s = 'curl -s https://robot\\$qa:RIuSwsdA9naFkunkDtg7TrPOHG3YoqS8@harbor.mobiledgex.net/v2/mobiledgex/edge-cloud/tags/list | jq ".tags | index(\\"' + dateValue + '\\")"'
    def index  = sh(script: s, returnStdout: true);
    println "xxxx ${index}"
    if(index == null) {
        println "${s} failed"
        currentBuild.result = 'FAILURE'
    } else {
        println "load ${dateValue} found"
    }
}
