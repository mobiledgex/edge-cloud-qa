def addTestsToFolder(version, project, cycle, folder, components=null, components_omit=null) {
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

def call(version, project, cycle) {
    dir('go/src/github.com/mobiledgex/jenkins') {
        def add_pre = 'export PYTHONPATH=$WORKSPACE/go/src/github.com/mobiledgex/modules;./createCycleAddTestcases.py --version ' + params.Version + ' --project ' + params.Project + ' --cycle ' + cycle
        echo "createcycle build resutl ${currentBuild.result}"
        echo "addpre ${add_pre}"

//        sh add_pre    
                    
        sh add_pre + ' --folder controller'
        addTestsToFolder(params.Version, params.Project, cycle, 'controller', 'Automated,Controller', null)
                    
        sh add_pre + ' --folder mastercontroller'
        addTestsToFolder(params.Version, params.Project, cycle, 'mastercontroller', 'Automated,MasterController', null)
        addTestsToFolder(params.Version, params.Project, cycle, 'mastercontroller', 'Automated,Mcctl', null)

        sh add_pre + ' --folder dme'
        addTestsToFolder(params.Version, params.Project, cycle, 'dme', 'Automated,DME', 'SDK,Metrics,Performance')

        sh add_pre + ' --folder sdk'
        addTestsToFolder(params.Version, params.Project, cycle, 'sdk', 'Automated,SDK', null)
                   
        sh add_pre + ' --folder openstack'
        addTestsToFolder(params.Version, params.Project, cycle, 'openstack', 'Automated,CRM,Openstack', null)

        sh add_pre + ' --folder vsphere'
        addTestsToFolder(params.Version, params.Project, cycle, 'vsphere', 'Automated,CRM,Vsphere', null)
                    
        sh add_pre + ' --folder vcd'
        addTestsToFolder(params.Version, params.Project, cycle, 'vcd', 'Automated,CRM,VCD', null)
                    
        sh add_pre + ' --folder anthos'
        addTestsToFolder(params.Version, params.Project, cycle, 'anthos', 'Automated,CRM,Anthos', null)

        sh add_pre + ' --folder metrics'
        addTestsToFolder(params.Version, params.Project, cycle, 'metrics', 'Automated,Metrics', null)

        sh add_pre + ' --folder performance/security'
        addTestsToFolder(params.Version, params.Project, cycle, 'performance/security', 'Automated,Performance', null)
        addTestsToFolder(params.Version, params.Project, cycle, 'performance/security', 'Automated,Security', null)
                    
        sh add_pre + ' --folder webui'
        addTestsToFolder(params.Version, params.Project, cycle, 'webui', 'Automated,WebUI', null)

        sh add_pre + ' --folder frm'
        addTestsToFolder(params.Version, params.Project, cycle, 'frm', 'Automated,FRM', null)

    }
}
