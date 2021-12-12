def call(version, project, cycle, folder, components=null, components_omit=null) {
    def status = -1
    def s = 'export PYTHONPATH=$WORKSPACE/go/src/github.com/mobiledgex/modules;python3 ./copyTestsToRelease.py --version ' + version + ' --project ' + project + ' --cycle ' + cycle +  ' --folder ' + folder
    if (components != null) {
        s = s + ' --component ' + components
    }
    if (components_omit != null) {
        s = s + ' --componentOmit ' + components_omit
    }
    status = sh(script: s, returnStatus: true);
    println status
    if(status != 0) {
        println "copyTestsToRelease.py failed"
        currentBuild.result = 'FAILURE'
        throw new Exception("Copy tests to release failed")
    }
}

