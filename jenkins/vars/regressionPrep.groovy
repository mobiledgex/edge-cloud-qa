def regressionPrep1(dateValue, cycle) {
//    try {
    parallel (
        'Create Cycle': {
//            steps {
//                script {
//                    dateValue = determineDateValue()
//                    cycle = dateValue + '_' + params.Version
//                    currentBuild.displayName = cycle
//                    slackMessage.good('Starting regression for ' + cycle)
//                    checkLoadExists(dateValue)
                    createCycle(cycle)
                    addTestsToFolder(params.Version, params.Project, cycle)
//                }
//            }
        },
        'Cleanup/Defrag': {
//            steps{
//                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE', message: 'cleanup provisioning failed') {
                      build job: 'cleanupAutomationProvisioning'
//                    script {
                        defragEtcd()
//                    }
//                }
//            }
        },
        'Deploy Chef': {
            if(params.RunDeploy == true) {
                deployChef(dateValue)
            } else {
                println("skipping Deploy Chef since RunDeploy=${params.RunDeploy}")
            }
        },
        'Pull Image': {
            pullImage(dateValue)
        }, 
        'Delete Openstack': {
            if(params.RunDeploy == true) {
                deleteCrm.openstack(cycle)
            } else {
                println("skipping Delete Openstack since RunDeploy=${params.RunDeploy}")
            }

        },
        'Delete Anthos': {
            if(params.RunDeploy == true) {
                deleteCrm.anthos(cycle)
            } else {
                println("skipping Delete Anthos since RunDeploy=${params.RunDeploy}")
            }
        },
        'Delete Fake') {
            if(params.RunDeploy == true) {
                deleteCrm.fake(cycle)
            } else {
                println("skipping Delete Fake since RunDeploy=${params.RunDeploy}")
            }
        }
    )
//    } catch(e) {
//    post {
//        failure {
//            script {
//                slackMessage.fail("Load check failed or create cycle failed for " + dateValue + ':' + e + '. Aborting')
//                error('Aborting the build')
//            }
//        }
//    }
//}
}

def regressionPrep2(dateValue, cycle) {
    try {
    parallel ({
        stage('Deploy Chef') {
            when { expression { params.RunDeploy == true } }
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE', message: 'deploy chef failed') {
                    script { deployChef(dateValue) }
                }
            }
        }

        stage('Pull Image') {
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE', message: 'pull image failed') {
                    script { pullImage(dateValue) }
                }
            }
        }

        stage('Delete Openstack') {
            when { expression { params.RunDeploy == true } }
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE', message: 'delete openstack failed') {
                    script { deleteCrm.openstack(cycle) }
                }
            }
        }
        stage('Delete Anthos') {
            when { expression { params.RunDeploy == true } }
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE', message: 'delete anthos failed') {
                    script { deleteCrm.anthos(cycle) }
                }
            }
        }
        stage('Delete Fake') {
            when { expression { params.RunDeploy == true } }
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE', message: 'delete fake failed') {
                    script { deleteCrm.fake(cycle) }
                }
            }
        }
    })
    slackMessage.good('Regression Prep successfull')
    } catch (e) { 
//    post {
//        failure {
//            script {
                currentBuild.result = 'SUCCESS'
                 echo "SSSUUUUCCCCEEEESSS"
                 regression_prep_status = false
//            }
//        }
//        success {
//            script { slackMessage.good('Regression Prep successfull') }
//        }
//    }
}
}

def regressionPrepCheck() {
//    steps {
//        script {
            if(regression_prep_status == false) {
                slackMessage.fail('Regression Prep Failed. Waiting for input')
                input message: 'Regression Prep failed. Continue?'
                slackMessage.good('Regression proceeding')
                currentBuild.result = 'SUCCESS'
                echo "SSSUUUUCCCCEEEESSS22222"
            }
//        }
//    }
}
