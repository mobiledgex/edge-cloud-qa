//
//  ViewController.swift
//  EdgeEventsTestApp
//
//  Created by Leon Adams on 5/14/21.
//

import UIKit
import MobiledgeXiOSGrpcLibrary
import CoreLocation
import Promises
import os.log


@available(iOS 13.4, *)
class ViewController: UIViewController , CLLocationManagerDelegate {
    @IBOutlet weak var Button1: UIButton!
    @IBOutlet weak var Button2: UIButton!
    @IBOutlet weak var Button3: UIButton!
    @IBOutlet weak var Button4: UIButton!
    @IBOutlet weak var Button5: UIButton!
    @IBOutlet weak var Button6: UIButton!
    @IBOutlet weak var Button7: UIButton!
    @IBOutlet weak var Button8: UIButton!
    @IBOutlet weak var Button9: UIButton!
    @IBOutlet weak var Button10: UIButton!
    @IBAction func Button1Click(_ sender: Any) {
        let queue = DispatchQueue.init(label: "testqueue", qos: .background)
        queue.async {
            print("Starting Tests")
            self.dotest()

        }
    }

    @IBAction func Button2Click(_ sender: Any) {
        let queue = DispatchQueue.init(label: "testqueue", qos: .background)
        queue.async {
            print("\n\nStarting Latency Too High Trigger Test")
            self.doHighLatency()
        }
    }

    @IBAction func Button3Click(_ sender: Any) {
        let queue = DispatchQueue.init(label: "testqueue", qos: .background)
        queue.async {
            print("\n\nStarting App Instance Health Trigger Test")
            self.doAppHealth()
        }
    }

    @IBAction func Button4Click(_ sender: Any) {
        let queue = DispatchQueue.init(label: "testqueue", qos: .background)
        queue.async {
            print("\n\nStarting Cloudlet State Change Trigger Test")
            self.doCloudState()
        }
    }

    @IBAction func Button5Click(_ sender: Any) {
        let queue = DispatchQueue.init(label: "testqueue", qos: .background)
        queue.async {
            print("\n\nStarting Cloudlet Maintenance Trigger Test")
            self.doCloudMaint()
        }
    }

    @IBAction func Button6Click(_ sender: Any) {
        let queue = DispatchQueue.init(label: "testqueue", qos: .background)
        queue.async {
            print("\n\nStarting Single Instance Latency Too High Trigger Test")
            self.doSingleInstLatencyTooHigh()
        }
    }

    @IBAction func Button7Click(_ sender: Any) {
        let queue = DispatchQueue.init(label: "testqueue", qos: .background)
        queue.async {
            print("\n\nStarting Single Instance App Health Trigger Test")
            self.doSingleInstAppHealth()
        }
    }

    @IBAction func Button8Click(_ sender: Any) {
        let queue = DispatchQueue.init(label: "testqueue", qos: .background)
        queue.async {
            print("\n\nStarting Single Instance Cloudlet State Trigger Test")
            self.doSingleInstCloudletState()
        }
    }

    @IBAction func Button9Click(_ sender: Any) {
        let queue = DispatchQueue.init(label: "testqueue", qos: .background)
        queue.async {
            print("\n\nStarting Single Instance CLoudlet Maintenance Trigger Test")
            self.doSingleInstCloudletMaintenance()
        }
    }

    @IBAction func Button10Click(_ sender: Any) {
        let queue = DispatchQueue.init(label: "testqueue", qos: .background)
        queue.async {
            print("\n\nStarting AutoMigrate Off Test")
            self.doAutoMigrateOff()
        }
    }

    var locationManager: CLLocationManager?
    var dmeHost: String = "us-qa.dme.mobiledgex.net"
    var dmePort: UInt16 = 50051
    var appName: String = "automation-sdk-porttest"
    var appVers: String = "1.0"
    var orgName: String = "automation_dev_org"
    var carrierName: String = ""
    var myLocation: DistributedMatchEngine_Loc?
    var stoptest: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        locationManager!.requestWhenInUseAuthorization()

    }

    enum MatchingEngineTestError: Error {
        case registerClientFailed
        case findCloudletFailed
        case setLocationFailed
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        var currLocation: CLLocation!
        if (status == .authorizedAlways || status == .authorizedWhenInUse) {
            print("Good Status! ")

            MobiledgeXiOSLibraryGrpc.MobiledgeXLocation.startLocationServices().then { success in
                if success {
                    print("Started Location Services")
                    let queue = DispatchQueue.init(label: "testqueue", qos: .background)
                    queue.async {
                  //      self.dotest()
                    }
                } else {
                    print("Failed to get Location Services")
                }
            }
        } else {
            print("Bad Status! ")
        }
    }

    func handleNewFindCloudlet(status: MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus, fcEvent: MobiledgeXiOSLibraryGrpc.EdgeEvents.FindCloudletEvent?) {
        switch status {
        case .success:
            guard let event = fcEvent else {
                os_log("nil findcloudlet event", log: OSLog.default, type: .debug)
                return
            }
            print("got new findcloudlet \(event.newCloudlet), on event \(event.trigger)")
        case .fail(let error):
            print("error during edgeevents \(error)")
            // Check the error if status is fail
            switch error {
            case MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsError.eventTriggeredButCurrentCloudletIsBest(let event):
                print("There are no cloudlets that satisfy your latencyThreshold requirement. If needed, fallback to public cloud")
            case MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsError.eventTriggeredButFindCloudletError(let event, let msg):
                print("Event triggered \(event), but error trying to find another cloudlet \(msg). If needed, fallback to public cloud")
            default:
                print("Non fatal error occured during EdgeEventsConnection: \(error)")
            }
        }
    }

    public func startEdgeEvents(matchingEngine:MobiledgeXiOSLibraryGrpc.MatchingEngine, newFindCloudletHandler: @escaping ((MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus, MobiledgeXiOSLibraryGrpc.EdgeEvents.FindCloudletEvent?) -> Void), config: MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsConfig, getLastLocation: (() -> Promise<DistributedMatchEngine_Loc>)? = nil) -> Promise<MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus> {
        let promise = Promise<MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus>.pending()
        var host: String
        do {
            host = try matchingEngine.generateDmeHostAddress()
        } catch {
            promise.reject(error)
            return promise
        }
        let port = MobiledgeXiOSLibraryGrpc.MatchingEngine.DMEConstants.dmeGrpcPort
        return matchingEngine.startEdgeEvents(dmeHost: host, dmePort: port, newFindCloudletHandler: newFindCloudletHandler, config: config)
    }

    func dotest() {
        print("Starting testGetLocation")
        var result = testGetLocation()
        if result.0 != true{
            print("Get Location Failed. Error is \(result.1)")
            print("Exiting")
        } else{
            print("Finished TestGetLocation\n\n")
        }
        print("\n\nStarting Default Config No Changes Test")
        result = testDefaultConfigNoChanges()
        if result.0 != true{
            print("Default Config No Changes Test Failed. Error is \(result.1)")
            print("Exiting")
        } else {
            print("Finished Default Config No Changes Test!\n\n")
        }
        sleep(5)
        print("\n\nStarting Default Config Latency Update 5s Test")
        result = testDefaultConfigLatencyUpdate5s()
        if result.0 != true {
            print("Default Config Latency Update 5s Test Failed. Error is \(result.1)")
            print("Exiting")
        } else {
            print("Finished Default Config Latency Update 5s Test!\n\n")
        }
        sleep(5)
        print("\n\nStarting Default Config Latency Update 60s Test")
        result = testDefaultConfigLatencyUpdate60s()
        if result.0 != true {
            print("Default Config Latency Update 60s Test Failed. Error is \(result.1)")
            print("Exiting")
        } else {
            print("Finished Default Config Latency Update 60s Test!\n\n")
        }
        sleep(5)
        print("\n\nStarting Default Config Location Update 5s Test")
        result = testDefaultConfigLocationUpdate5s()
        if result.0 != true {
            print("Default Config Location Update 5s Test Failed. Error is \(result.1)")
            print("Exiting")
        } else {
            print("Finished Default Config Location Update 5s Test!\n\n")
        }
        sleep(5)
        print("\n\nStarting Default Config Location Update 60s Test")
        result = testDefaultConfigLocationUpdate60s()
        if result.0 != true {
            print("Default Config Location Update 60s Test Failed. Error is \(result.1)")
            print("Exiting")
        } else {
            print("Finished Default Config Location Update 60s Test!\n\n")
        }
        sleep(5)
        print("\n\nStarting Default Config Latencey Threshold Above Test")
        result = testDefaultConfigLatencyThresholdAbove()
        if result.0 != true {
            print("Default Config Latencey Threshold Above Test Failed. Error is \(result.1)")
            print("Exiting")
        } else {
            print("Finished Default Config Latencey Threshold Above Test!\n\n")
        }
        sleep(5)
        print("\n\nStarting Default Config Latencey Threshold Below Test")
        result = testDefaultConfigLatencyThresholdBelow()
        if result.0 != true {
            print("Default Config Latencey Threshold Below Test Failed. Error is \(result.1)")
            print("Exiting")
        } else {
            print("Finished Default Config Latencey Threshold Below Test!\n\n")
        }
        sleep(5)
        print("\n\nStarting Default Config Latencey Test Port 0 Test")
        result = testDefaultConfigLatencyTestPort0()
        if result.0 != true {
            print("Default Config Latencey Test Port 0 Test Failed. Error is \(result.1)")
            print("Exiting")
        } else {
            print("Finished Default Config Latencey Test Port 0 Test!\n\n")
        }
        sleep(5)
        print("\n\nStarting Default Config Latencey Test Port 2015 Test")
        result = testDefaultConfigLatencyTestPort2015()
        if result.0 != true {
            print("Default Config Latencey Test Port 2015 Test Failed. Error is \(result.1)")
            print("Exiting")
        } else {
            print("Finished Default Config Latencey Test Port 2015 Test!\n\n")
        }
        sleep(5)
        print("\n\nStarting Default Config Latencey Test Port 2016 Test")
        result = testDefaultConfigLatencyTestPort2016()
        if result.0 != true {
            print("Default Config Latencey Test Port 2016 Test Failed. Error is \(result.1)")
            print("Exiting")
        } else {
            print("Finished Default Config Latencey Test Port 2016 Test!\n\n")
        }
        sleep(5)
        print("\n\nStarting Default Config Latencey Test Port 3765 Test")
        result = testDefaultConfigLatencyTestPort3765()
        if result.0 != true {
            print("Default Config Latencey Test Port 3765 Test Failed. Error is \(result.1)")
            print("Exiting")
        } else {
            print("Finished Default Config Latencey Test Port 3765 Test!\n\n")
        }
        sleep(5)
        print("\n\nStarting Default Config Latencey Test Port 8085 Test")
        result = testDefaultConfigLatencyTestPort8085()
        if result.0 != true {
            print("Default Config Latencey Test Port 8085 Test Failed. Error is \(result.1)")
            print("Exiting")
        } else {
            print("Finished Default Config Latencey Test Port 8085 Test!\n\n")
        }
        sleep(5)
        print("\n\nStarting Default Config Latencey Test Port 2085 Test")
        result = testDefaultConfigLatencyTestPort2085()
        if result.0 != true {
            print("Default Config Latencey Test Port 2085 Test Failed. Error is \(result.1)")
            print("Exiting")
        } else {
            print("Finished Default Config Latencey Test Port 2085 Test!\n\n")
        }
        sleep(5)

    }

    func testGetLocation() -> (Bool, String) {
        print("In the Function")
        var success = false
        var err = ""
        var loc = DistributedMatchEngine_Loc.init()
        loc.latitude = 53.55
        loc.longitude = 9.99
        let promise = MobiledgeXiOSLibraryGrpc.MobiledgeXLocation.setLastLocation(loc: loc).then{ set -> Promise<DistributedMatchEngine_Loc> in
            print("Leons Location call \(set)")
            print("In testGetLocation")
            print("Promise set")
            return MobiledgeXiOSLibraryGrpc.MobiledgeXLocation.getLastLocation()
            }.then{ location in
                print("Location: \(location)")
                if location.latitude != 0 && location.longitude != 0{
                    self.myLocation = location
                    print("Got the location setting success to true!")
                    success = true
                }else{
                    print("In the else")
                    err = "Invalid location"
                }
            }.catch { error in
                err = "Error doing getLastLocation \(error.localizedDescription)"
                print("testGetLocation In Catch \(err)")
            }
        print("Created Promise")
            // poll
            do {
                try awaitPromise(promise)
            } catch {
                print("error awaiting promise \(error)")
            }
        print("Leaving testGetLocation - Success:  \(success)")
        return (success, err)
    }


    func registerClient(matchingEngine:MobiledgeXiOSLibraryGrpc.MatchingEngine)->Promise<Bool>{
        let registerClientReg = matchingEngine.createRegisterClientRequest(orgName: orgName, appName: appName, appVers: appVers)
        return matchingEngine.registerClient(host: dmeHost, port: dmePort, request: registerClientReg).then { reply -> Bool in
            if reply.status == .rsSuccess {
                print("Got RegisterClient Sucess")
                return true
            } else {
                print("RegisterClient Failed")
                return false
            }
        }.catch { error  in
            print("Error:  \(error)")
        }
    }

    func findCloudlet(matchingEngine:MobiledgeXiOSLibraryGrpc.MatchingEngine)->Promise<Bool>{
        var findCloudletReq: DistributedMatchEngine_FindCloudletRequest?
        do {
            findCloudletReq = try matchingEngine.createFindCloudletRequest(gpsLocation: self.myLocation!, carrierName: self.carrierName)
        } catch {
            let promise = Promise<Bool>.pending()
            promise.reject(error)
            return promise
        }

        return matchingEngine.findCloudlet(host: self.dmeHost, port: self.dmePort, request: findCloudletReq!).then{findReply -> Bool in
            if findReply.status == .findFound  {
                print("Got FindCloudlet Success  FQDN: \(findReply.fqdn)")
                return true
            } else {
                print("FindCloudlet Failed")
                return false
            }
        }.catch { error  in
            print("Error:  \(error)")
        }
    }

    func testDefaultConfigNoChanges() -> (Bool, String) {
        let matchingEngine = MobiledgeXiOSLibraryGrpc.MatchingEngine()
        var success = false
        var err = ""
        var loc = DistributedMatchEngine_Loc.init()
        loc.latitude = 53.55
        loc.longitude = 9.99

        let promise = MobiledgeXiOSLibraryGrpc.MobiledgeXLocation.setLastLocation(loc: loc).then { set -> Promise<Bool> in
            if set {
                print("DefaultNoChanges Location Set To Lat:53 Long:10")
            } else {
                print("DefaultNoChanges Location Not Set!")
                throw MatchingEngineTestError.setLocationFailed
            }
            return self.registerClient(matchingEngine: matchingEngine)
        }.then { regReply -> Promise<Bool> in
            if !regReply {
                print("DefaultNoChanges Register Client Failed!")
                throw MatchingEngineTestError.registerClientFailed
            }
            print("DefaultNoChanges Register Client Done!")
            return self.findCloudlet(matchingEngine: matchingEngine)
        }.then { cloudlet -> Promise<MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus> in
            if !cloudlet {
                print("DefaultNoChanges Find CLoudlet Failed!")
                throw MatchingEngineTestError.findCloudletFailed
            }
            print("DefaultNoChanges Find Cloudlet Done!")
            //let config = matchingEngine.createDefaultEdgeEventsConfig(latencyUpdateIntervalSeconds: 30, locationUpdateIntervalSeconds: 30, latencyThresholdTriggerMs: 250, latencyTestPort: 2016)
            let config = matchingEngine.createDefaultEdgeEventsConfig()
            //let config = matchingEngine.createDefaultEdgeEventsConfig(latencyUpdateIntervalSeconds: 5, locationUpdateIntervalSeconds: 5, latencyThresholdTriggerMs: 50, latencyTestPort: 2016, latencyTestNetwork: MobiledgeXiOSLibraryGrpc.NetworkInterface.WIFI)
            print("DefaultNoChanges Config is \(config)")
            print("DefaultNoChanges Starting Edge Event Connection!")
            return matchingEngine.startEdgeEvents(dmeHost: self.dmeHost, dmePort: self.dmePort, newFindCloudletHandler: self.handleNewFindCloudlet, config: config)
        }.then { status in
            if status == MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus.success {
                print("DefaultNoChanges Edge Events Connection Started!")
                success = true
            } else {
                err = "DefaultNoChanges Edge Events Connection could not start. Bad status"
            }
            print("Out of Promise")
        }.catch { error  in
            print("DefaultNoChanges Error:  \(error)")
            err = "DefaultNoChanges Test Failed "
        }
        do {
            try awaitPromise(promise)
        } catch {
            print("error awaiting promise \(error)")
        }
        sleep(120)
        matchingEngine.close()
        print("Closing DefaultNoChanges EdgeEvents Connection ")
        print("Leaving DefaultNoChanges - Success:  \(success)")
        return (success, err)
    }


    func testDefaultConfigLatencyUpdate5s() -> (Bool, String) {
        let matchingEngine = MobiledgeXiOSLibraryGrpc.MatchingEngine()
        var success = false
        var err = ""
        var loc = DistributedMatchEngine_Loc.init()
        loc.latitude = 53.55
        loc.longitude = 9.99
        let promise = MobiledgeXiOSLibraryGrpc.MobiledgeXLocation.setLastLocation(loc: loc).then { set -> Promise<Bool>in
             if set {
                print("DefaultLatencyUpdate5s Location Set To Lat:53 Long:10")
                success = true
            }else{
                print("DefaultLatencyUpdate5s Location Not Set!")
                throw MatchingEngineTestError.setLocationFailed
            }
            return self.registerClient(matchingEngine: matchingEngine)
        }.then { regReply -> Promise<Bool> in
            if !regReply {
                print("DefaultLatencyUpdate5s Register Client Failed!")
                throw MatchingEngineTestError.registerClientFailed
            }
            print("DefaultLatencyUpdate5s Register Client Done!")
            return self.findCloudlet(matchingEngine: matchingEngine)
        }.then { cloudlet -> Promise<MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus> in
            if !cloudlet {
                print("DefaultLatencyUpdate5s Find CLoudlet Failed!")
                throw MatchingEngineTestError.findCloudletFailed
            }
            print("DefaultLatencyUpdate5s Find Cloudlet Done!")
            //let config = matchingEngine.createDefaultEdgeEventsConfig(latencyUpdateIntervalSeconds: 30, locationUpdateIntervalSeconds: 30, latencyThresholdTriggerMs: 250, latencyTestPort: 2016)
            let config = matchingEngine.createDefaultEdgeEventsConfig(latencyUpdateIntervalSeconds: 5, latencyThresholdTriggerMs: 300)
            print("DefaultLatencyUpdate5s Config is \(config)")
            print("DefaultLatencyUpdate5s Starting Edge Event Connection!")
            return matchingEngine.startEdgeEvents(dmeHost: self.dmeHost, dmePort: self.dmePort, newFindCloudletHandler: self.handleNewFindCloudlet, config: config)
        }.then { status in
            if status == MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus.success {
                print("DefaultLatencyUpdate5s Edge Events Connection Started!")
                success = true
            } else {
                success = false
                err = "DefaultLatencyUpdate5s Edge Events Connection could not start. Bad status!"
            }
        }.catch { error  in
            print("DefaultLatencyUpdate5s Error:  \(error)")
            err = "DefaultLatencyUpdate5s Test Failed "
        }
        do {
            try awaitPromise(promise)
        } catch {
            print("error awaiting promise \(error)")
        }
        sleep(20)
        matchingEngine.close()
        print("Closing DefaultLatencyUpdate5s EdgeEvents Connection ")
        print("Leaving DefaultLatencyUpdate5s - Success:  \(success)")
        return (success, err)
    }

    func testDefaultConfigLatencyUpdate60s() -> (Bool, String) {
        let matchingEngine = MobiledgeXiOSLibraryGrpc.MatchingEngine()
        var success = false
        var err = ""
        var loc = DistributedMatchEngine_Loc.init()
        loc.latitude = 53.55
        loc.longitude = 9.99
        let promise = MobiledgeXiOSLibraryGrpc.MobiledgeXLocation.setLastLocation(loc: loc).then { set -> Promise<Bool>in
             if set {
                print("DefaultLatencyUpdate5s Location Set To Lat:53 Long:10")
                success = true
            }else{
                print("DefaultLatencyUpdate60s Location Not Set!")
                throw MatchingEngineTestError.setLocationFailed
            }
            return self.registerClient(matchingEngine: matchingEngine)
        }.then { regReply -> Promise<Bool> in
            if !regReply {
                print("DefaultLatencyUpdate60s Register Client Failed!")
                throw MatchingEngineTestError.registerClientFailed
            }
            print("DefaultLatencyUpdate60s Register Client Done!")
            return self.findCloudlet(matchingEngine: matchingEngine)
        }.then { cloudlet -> Promise<MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus> in
            if !cloudlet {
                print("DefaultLatencyUpdate60s Find CLoudlet Failed!")
                throw MatchingEngineTestError.findCloudletFailed
            }
            print("DefaultLatencyUpdate60s Find Cloudlet Done!")
            //let config = matchingEngine.createDefaultEdgeEventsConfig(latencyUpdateIntervalSeconds: 30, locationUpdateIntervalSeconds: 30, latencyThresholdTriggerMs: 250, latencyTestPort: 2016)
            let config = matchingEngine.createDefaultEdgeEventsConfig(latencyUpdateIntervalSeconds: 60, latencyThresholdTriggerMs: 300)
            print("DefaultLatencyUpdate60s Config is \(config)")
            print("DefaultLatencyUpdate60s Starting Edge Event Connection!")
            return matchingEngine.startEdgeEvents(dmeHost: self.dmeHost, dmePort: self.dmePort, newFindCloudletHandler: self.handleNewFindCloudlet, config: config)
        }.then { status in
            if status == MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus.success {
                print("DefaultLatencyUpdate60s Edge Events Connection Started!")
                success = true
            } else {
                success = false
                err = "DefaultLatencyUpdate60s Edge Events Connection could not start. Bad status!"
            }
        }.catch { error  in
            print("DefaultLatencyUpdate60s Error:  \(error)")
            err = "DefaultLatencyUpdate60s Test Failed "
        }
        do {
            try awaitPromise(promise)
        } catch {
            print("error awaiting promise \(error)")
        }
        sleep(120)
        matchingEngine.close()
        print("Closing DefaultLatencyUpdate60s EdgeEvents Connection ")
        print("Leaving DefaultLatencyUpdate60s - Success:  \(success)")
        return (success, err)
    }

    func testDefaultConfigLocationUpdate5s() -> (Bool, String) {
        let matchingEngine = MobiledgeXiOSLibraryGrpc.MatchingEngine()
        var success = false
        var err = ""
        var loc = DistributedMatchEngine_Loc.init()
        loc.latitude = 53.55
        loc.longitude = 9.99
        let promise = MobiledgeXiOSLibraryGrpc.MobiledgeXLocation.setLastLocation(loc: loc).then { set -> Promise<Bool>in
             if set {
                print("DefaultLocationUpdate5s Location Set To Lat:53 Long:10")
                success = true
            }else{
                print("DefaultLocationUpdate5s Location Not Set!")
                throw MatchingEngineTestError.setLocationFailed
            }
            return self.registerClient(matchingEngine: matchingEngine)
        }.then { regReply -> Promise<Bool> in
            if !regReply {
                print("DefaultLocationUpdate5s Register Client Failed!")
                throw MatchingEngineTestError.registerClientFailed
            }
            print("DefaultLocationUpdate5s Register Client Done!")
            return self.findCloudlet(matchingEngine: matchingEngine)
        }.then { cloudlet -> Promise<MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus> in
            if !cloudlet {
                print("DefaultLocationUpdate5s Find CLoudlet Failed!")
                throw MatchingEngineTestError.findCloudletFailed
            }
            print("DefaultLocationUpdate5s Find Cloudlet Done!")
            //let config = matchingEngine.createDefaultEdgeEventsConfig(latencyUpdateIntervalSeconds: 30, locationUpdateIntervalSeconds: 30, latencyThresholdTriggerMs: 250, latencyTestPort: 2016)
            let config = matchingEngine.createDefaultEdgeEventsConfig(locationUpdateIntervalSeconds: 5, latencyThresholdTriggerMs: 300)
            print("DefaultLocationUpdate5s Config is \(config)")
            print("DefaultLocationUpdate5s Starting Edge Event Connection!")
            return matchingEngine.startEdgeEvents(dmeHost: self.dmeHost, dmePort: self.dmePort, newFindCloudletHandler: self.handleNewFindCloudlet, config: config)
        }.then { status in
            if status == MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus.success {
                print("DefaultLocationUpdate5s Edge Events Connection Started!")
                success = true
            } else {
                success = false
                err = "DefaultLocationUpdate5s Edge Events Connection could not start. Bad status!"
            }
        }.catch { error  in
            print("DefaultLocationUpdate5s Error:  \(error)")
            err = "DefaultLocationUpdate5s Test Failed "
        }
        do {
            try awaitPromise(promise)
        } catch {
            print("error awaiting promise \(error)")
        }
        sleep(120)
        matchingEngine.close()
        print("Closing DefaultLocationUpdate5s EdgeEvents Connection ")
        print("Leaving DefaultLocationUpdate5s - Success:  \(success)")
        return (success, err)
    }

    func testDefaultConfigLocationUpdate60s() -> (Bool, String) {
        let matchingEngine = MobiledgeXiOSLibraryGrpc.MatchingEngine()
        var success = false
        var err = ""
        var loc = DistributedMatchEngine_Loc.init()
        loc.latitude = 53.55
        loc.longitude = 10
        let promise = MobiledgeXiOSLibraryGrpc.MobiledgeXLocation.setLastLocation(loc: loc).then { set -> Promise<Bool>in
             if set {
                print("DefaultLocationUpdate60s Location Set To Lat:53 Long:10")
                success = true
            }else{
                print("DefaultLocationUpdate60s Location Not Set!")
                throw MatchingEngineTestError.setLocationFailed
            }
            return self.registerClient(matchingEngine: matchingEngine)
        }.then { regReply -> Promise<Bool> in
            if !regReply {
                print("DefaultLocationUpdate60s Register Client Failed!")
                throw MatchingEngineTestError.registerClientFailed
            }
            print("DefaultLocationUpdate60s Register Client Done!")
            return self.findCloudlet(matchingEngine: matchingEngine)
        }.then { cloudlet -> Promise<MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus> in
            if !cloudlet {
                print("DefaultLocationUpdate60s Find CLoudlet Failed!")
                throw MatchingEngineTestError.findCloudletFailed
            }
            print("DefaultLocationUpdate60s Find Cloudlet Done!")
            //let config = matchingEngine.createDefaultEdgeEventsConfig(latencyUpdateIntervalSeconds: 30, locationUpdateIntervalSeconds: 30, latencyThresholdTriggerMs: 250, latencyTestPort: 2016)
            let config = matchingEngine.createDefaultEdgeEventsConfig(locationUpdateIntervalSeconds: 60, latencyThresholdTriggerMs: 300)
            print("DefaultLocationUpdate60s Config is \(config)")
            print("DefaultLocationUpdate60s Starting Edge Event Connection!")
            return matchingEngine.startEdgeEvents(dmeHost: self.dmeHost, dmePort: self.dmePort, newFindCloudletHandler: self.handleNewFindCloudlet, config: config)
        }.then { status in
            if status == MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus.success {
                print("DefaultLocationUpdate60s Edge Events Connection Started!")
                success = true
            } else {
                success = false
                err = "DefaultLocationUpdate60s Edge Events Connection could not start. Bad status!"
            }
        }.catch { error  in
            print("DefaultLocationUpdate60s Error:  \(error)")
            err = "DefaultLocationUpdate60s Test Failed "
        }
        do {
            try awaitPromise(promise)
        } catch {
            print("error awaiting promise \(error)")
        }
        sleep(120)
        matchingEngine.close()
        print("Closing DefaultLocationUpdate60s EdgeEvents Connection ")
        print("Leaving DefaultLocationUpdate60s - Success:  \(success)")
        return (success, err)
    }


    func testDefaultConfigLatencyThresholdAbove() -> (Bool, String) {
        let matchingEngine = MobiledgeXiOSLibraryGrpc.MatchingEngine()
        var success = false
        var err = ""
        var loc = DistributedMatchEngine_Loc.init()
        loc.latitude = 53
        loc.longitude = 10
        let promise = MobiledgeXiOSLibraryGrpc.MobiledgeXLocation.setLastLocation(loc: loc).then { set -> Promise<Bool>in
             if set {
                print("DefaultLatencyThresholdAbove Location Set To Lat:53 Long:10")
                success = true
            }else{
                print("DefaultLatencyThresholdAbove Location Not Set!")
                throw MatchingEngineTestError.setLocationFailed
            }
            return self.registerClient(matchingEngine: matchingEngine)
        }.then { regReply -> Promise<Bool> in
            if !regReply {
                print("DefaultLatencyThresholdAbove Register Client Failed!")
                throw MatchingEngineTestError.registerClientFailed
            }
            print("DefaultLatencyThresholdAbove Register Client Done!")
            return self.findCloudlet(matchingEngine: matchingEngine)
        }.then { cloudlet -> Promise<MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus> in
            if !cloudlet {
                print("DefaultLatencyThresholdAbove Find CLoudlet Failed!")
                throw MatchingEngineTestError.findCloudletFailed
            }
            print("DefaultLatencyThresholdAbove Find Cloudlet Done!")
            //let config = matchingEngine.createDefaultEdgeEventsConfig(latencyUpdateIntervalSeconds: 30, locationUpdateIntervalSeconds: 30, latencyThresholdTriggerMs: 250, latencyTestPort: 2016)
            let config = matchingEngine.createDefaultEdgeEventsConfig(latencyThresholdTriggerMs: 300)
            print("DefaultLatencyThresholdAbove Config is \(config)")
            print("DefaultLatencyThresholdAbove Starting Edge Event Connection!")
            return matchingEngine.startEdgeEvents(dmeHost: self.dmeHost, dmePort: self.dmePort, newFindCloudletHandler: self.handleNewFindCloudlet, config: config)
        }.then { status in
            if status == MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus.success {
                print("DefaultLatencyThresholdAbove Edge Events Connection Started!")
                success = true
            } else {
                success = false
                err = "DefaultLatencyThresholdAbove Edge Events Connection could not start. Bad status!"
            }
        }.catch { error  in
            print("DefaultLatencyThresholdAbove Error:  \(error)")
            err = "DefaultLatencyThresholdAbove Test Failed "
        }
        do {
            try awaitPromise(promise)
        } catch {
            print("error awaiting promise \(error)")
        }
        sleep(120)
        matchingEngine.close()
        print("Closing DefaultLatencyThresholdAbove EdgeEvents Connection ")
        print("Leaving DefaultLatencyThresholdAbove - Success:  \(success)")
        return (success, err)
    }

    func testDefaultConfigLatencyThresholdBelow() -> (Bool, String) {
        let matchingEngine = MobiledgeXiOSLibraryGrpc.MatchingEngine()
        var success = false
        var err = ""
        var loc = DistributedMatchEngine_Loc.init()
        loc.latitude = 53
        loc.longitude = 10
        let promise = MobiledgeXiOSLibraryGrpc.MobiledgeXLocation.setLastLocation(loc: loc).then { set -> Promise<Bool>in
             if set {
                print("DefaultLatencyThresholdBelow Location Set To Lat:53 Long:10")
                success = true
            }else{
                print("DefaultLatencyThresholdBelow Location Not Set!")
                throw MatchingEngineTestError.setLocationFailed
            }
            return self.registerClient(matchingEngine: matchingEngine)
        }.then { regReply -> Promise<Bool> in
            if !regReply {
                print("DefaultLatencyThresholdBelow Register Client Failed!")
                throw MatchingEngineTestError.registerClientFailed
            }
            print("DefaultLatencyThresholdBelow Register Client Done!")
            return self.findCloudlet(matchingEngine: matchingEngine)
        }.then { cloudlet -> Promise<MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus> in
            if !cloudlet {
                print("DefaultLatencyThresholdBelow Find CLoudlet Failed!")
                throw MatchingEngineTestError.findCloudletFailed
            }
            print("DefaultLatencyThresholdBelow Find Cloudlet Done!")
            //let config = matchingEngine.createDefaultEdgeEventsConfig(latencyUpdateIntervalSeconds: 30, locationUpdateIntervalSeconds: 30, latencyThresholdTriggerMs: 250, latencyTestPort: 2016)
            let config = matchingEngine.createDefaultEdgeEventsConfig(latencyThresholdTriggerMs: 150)
            print("DefaultLatencyThresholdBelow Config is \(config)")
            print("DefaultLatencyThresholdBelow Starting Edge Event Connection!")
            return matchingEngine.startEdgeEvents(dmeHost: self.dmeHost, dmePort: self.dmePort, newFindCloudletHandler: self.handleNewFindCloudlet, config: config)
        }.then { status in
            if status == MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus.success {
                print("DefaultLatencyThresholdBelow Edge Events Connection Started!")
                success = true
            } else {
                success = false
                err = "DefaultLatencyThresholdBelow Edge Events Connection could not start. Bad status!"
            }
        }.catch { error  in
            print("DefaultLatencyThresholdBelow Error:  \(error)")
            err = "DefaultLatencyThresholdBelow Test Failed "
        }
        do {
            try awaitPromise(promise)
        } catch {
            print("error awaiting promise \(error)")
        }
        sleep(120)
        matchingEngine.close()
        print("Closing DefaultLatencyThresholdBelow EdgeEvents Connection ")
        print("Leaving DefaultLatencyThresholdBelow - Success:  \(success)")
        return (success, err)
    }

    func testDefaultConfigLatencyTestPort0() -> (Bool, String) {
        let matchingEngine = MobiledgeXiOSLibraryGrpc.MatchingEngine()
        var success = false
        var err = ""
        var loc = DistributedMatchEngine_Loc.init()
        loc.latitude = 53
        loc.longitude = 10
        let promise = MobiledgeXiOSLibraryGrpc.MobiledgeXLocation.setLastLocation(loc: loc).then { set -> Promise<Bool>in
             if set {
                print("DefaultLatencyTestPort0 Location Set To Lat:53 Long:10")
                success = true
            }else{
                print("DefaultLatencyTestPort0 Location Not Set!")
                throw MatchingEngineTestError.setLocationFailed
            }
            return self.registerClient(matchingEngine: matchingEngine)
        }.then { regReply -> Promise<Bool> in
            if !regReply {
                print("DefaultLatencyTestPort0 Register Client Failed!")
                throw MatchingEngineTestError.registerClientFailed
            }
            print("DefaultLatencyTestPort0 Register Client Done!")
            return self.findCloudlet(matchingEngine: matchingEngine)
        }.then { cloudlet -> Promise<MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus> in
            if !cloudlet {
                print("DefaultLatencyTestPort0 Find CLoudlet Failed!")
                throw MatchingEngineTestError.findCloudletFailed
            }
            print("DefaultLatencyTestPort0 Find Cloudlet Done!")
            //let config = matchingEngine.createDefaultEdgeEventsConfig(latencyUpdateIntervalSeconds: 30, locationUpdateIntervalSeconds: 30, latencyThresholdTriggerMs: 250, latencyTestPort: 2016)
            let config = matchingEngine.createDefaultEdgeEventsConfig(latencyThresholdTriggerMs: 300, latencyTestPort: 0)
            print("DefaultLatencyTestPort0 Config is \(config)")
            print("DefaultLatencyTestPort0 Starting Edge Event Connection!")
            return matchingEngine.startEdgeEvents(dmeHost: self.dmeHost, dmePort: self.dmePort, newFindCloudletHandler: self.handleNewFindCloudlet, config: config)
        }.then { status in
            if status == MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus.success {
                print("DefaultLatencyTestPort0 Edge Events Connection Started!")
                success = true
            } else {
                success = false
                err = "DefaultLatencyTestPort0 Edge Events Connection could not start. Bad status!"
            }
        }.catch { error  in
            print("DefaultLatencyTestPort0 Error:  \(error)")
            err = "DefaultLatencyTestPort0 Test Failed "
        }
        do {
            try awaitPromise(promise)
        } catch {
            print("error awaiting promise \(error)")
        }
        sleep(120)
        matchingEngine.close()
        print("Closing DefaultLatencyTestPort0 EdgeEvents Connection ")
        print("Leaving DefaultLatencyTestPort0 - Success:  \(success)")
        return (success, err)
    }

    func testDefaultConfigLatencyTestPort2015() -> (Bool, String) {
        let matchingEngine = MobiledgeXiOSLibraryGrpc.MatchingEngine()
        var success = false
        var err = ""
        var loc = DistributedMatchEngine_Loc.init()
        loc.latitude = 53
        loc.longitude = 10
        let promise = MobiledgeXiOSLibraryGrpc.MobiledgeXLocation.setLastLocation(loc: loc).then { set -> Promise<Bool>in
             if set {
                print("DefaultLatencyTestPort2015 Location Set To Lat:53 Long:10")
                success = true
            }else{
                print("DefaultLatencyTestPort2015 Location Not Set!")
                throw MatchingEngineTestError.setLocationFailed
            }
            return self.registerClient(matchingEngine: matchingEngine)
        }.then { regReply -> Promise<Bool> in
            if !regReply {
                print("DefaultLatencyTestPort2015 Register Client Failed!")
                throw MatchingEngineTestError.registerClientFailed
            }
            print("DefaultLatencyTestPort2015 Register Client Done!")
            return self.findCloudlet(matchingEngine: matchingEngine)
        }.then { cloudlet -> Promise<MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus> in
            if !cloudlet {
                print("DefaultLatencyTestPort2015 Find CLoudlet Failed!")
                throw MatchingEngineTestError.findCloudletFailed
            }
            print("DefaultLatencyTestPort2015 Find Cloudlet Done!")
            //let config = matchingEngine.createDefaultEdgeEventsConfig(latencyUpdateIntervalSeconds: 30, locationUpdateIntervalSeconds: 30, latencyThresholdTriggerMs: 250, latencyTestPort: 2016)
            let config = matchingEngine.createDefaultEdgeEventsConfig(latencyThresholdTriggerMs: 300, latencyTestPort: 2015)
            print("DefaultLatencyTestPort2015 Config is \(config)")
            print("DefaultLatencyTestPort2015 Starting Edge Event Connection!")
            return matchingEngine.startEdgeEvents(dmeHost: self.dmeHost, dmePort: self.dmePort, newFindCloudletHandler: self.handleNewFindCloudlet, config: config)
        }.then { status in
            if status == MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus.success {
                print("DefaultLatencyTestPort2015 Edge Events Connection Started!")
                success = true
            } else {
                success = false
                err = "DefaultLatencyTestPort2015 Edge Events Connection could not start. Bad status!"
            }
        }.catch { error  in
            print("DefaultLatencyTestPort2015 Error:  \(error)")
            err = "DefaultLatencyTestPort2015 Test Failed "
        }
        do {
            try awaitPromise(promise)
        } catch {
            print("error awaiting promise \(error)")
        }
        sleep(120)
        matchingEngine.close()
        print("Closing DefaultLatencyTestPort2015 EdgeEvents Connection ")
        print("Leaving DefaultLatencyTestPort2015 - Success:  \(success)")
        return (success, err)
    }

    func testDefaultConfigLatencyTestPort2016() -> (Bool, String) {
        let matchingEngine = MobiledgeXiOSLibraryGrpc.MatchingEngine()
        var success = false
        var err = ""
        var loc = DistributedMatchEngine_Loc.init()
        loc.latitude = 53
        loc.longitude = 10
        let promise = MobiledgeXiOSLibraryGrpc.MobiledgeXLocation.setLastLocation(loc: loc).then { set -> Promise<Bool>in
             if set {
                print("DefaultLatencyTestPort2016 Location Set To Lat:53 Long:10")
                success = true
            }else{
                print("DefaultLatencyTestPort2016 Location Not Set!")
                throw MatchingEngineTestError.setLocationFailed
            }
            return self.registerClient(matchingEngine: matchingEngine)
        }.then { regReply -> Promise<Bool> in
            if !regReply {
                print("DefaultLatencyTestPort2016 Register Client Failed!")
                throw MatchingEngineTestError.registerClientFailed
            }
            print("DefaultLatencyTestPort2016 Register Client Done!")
            return self.findCloudlet(matchingEngine: matchingEngine)
        }.then { cloudlet -> Promise<MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus> in
            if !cloudlet {
                print("DefaultLatencyTestPort2016 Find CLoudlet Failed!")
                throw MatchingEngineTestError.findCloudletFailed
            }
            print("DefaultLatencyTestPort2016 Find Cloudlet Done!")
            //let config = matchingEngine.createDefaultEdgeEventsConfig(latencyUpdateIntervalSeconds: 30, locationUpdateIntervalSeconds: 30, latencyThresholdTriggerMs: 250, latencyTestPort: 2016)
            let config = matchingEngine.createDefaultEdgeEventsConfig(latencyThresholdTriggerMs: 300, latencyTestPort: 2016)
            print("DefaultLatencyTestPort2016 Config is \(config)")
            print("DefaultLatencyTestPort2016 Starting Edge Event Connection!")
            return matchingEngine.startEdgeEvents(dmeHost: self.dmeHost, dmePort: self.dmePort, newFindCloudletHandler: self.handleNewFindCloudlet, config: config)
        }.then { status in
            if status == MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus.success {
                print("DefaultLatencyTestPort2016 Edge Events Connection Started!")
                success = true
            } else {
                success = false
                err = "DefaultLatencyTestPort2016 Edge Events Connection could not start. Bad status!"
            }
        }.catch { error  in
            print("DefaultLatencyTestPort2016 Error:  \(error)")
            err = "DefaultLatencyTestPort2016 Test Failed "
        }
        do {
            try awaitPromise(promise)
        } catch {
            print("error awaiting promise \(error)")
        }
        sleep(120)
        matchingEngine.close()
        print("Closing DefaultLatencyTestPort2016 EdgeEvents Connection ")
        print("Leaving DefaultLatencyTestPort2016 - Success:  \(success)")
        return (success, err)
    }

    func testDefaultConfigLatencyTestPort3765() -> (Bool, String) {
        let matchingEngine = MobiledgeXiOSLibraryGrpc.MatchingEngine()
        var success = false
        var err = ""
        var loc = DistributedMatchEngine_Loc.init()
        loc.latitude = 53
        loc.longitude = 10
        let promise = MobiledgeXiOSLibraryGrpc.MobiledgeXLocation.setLastLocation(loc: loc).then { set -> Promise<Bool>in
             if set {
                print("DefaultLatencyTestPort3765 Location Set To Lat:53 Long:10")
                success = true
            }else{
                print("DefaultLatencyTestPort3765 Location Not Set!")
                throw MatchingEngineTestError.setLocationFailed
            }
            return self.registerClient(matchingEngine: matchingEngine)
        }.then { regReply -> Promise<Bool> in
            if !regReply {
                print("DefaultLatencyTestPort3765 Register Client Failed!")
                throw MatchingEngineTestError.registerClientFailed
            }
            print("DefaultLatencyTestPort3765 Register Client Done!")
            return self.findCloudlet(matchingEngine: matchingEngine)
        }.then { cloudlet -> Promise<MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus> in
            if !cloudlet {
                print("DefaultLatencyTestPort3765 Find CLoudlet Failed!")
                throw MatchingEngineTestError.findCloudletFailed
            }
            print("DefaultLatencyTestPort3765 Find Cloudlet Done!")
            //let config = matchingEngine.createDefaultEdgeEventsConfig(latencyUpdateIntervalSeconds: 30, locationUpdateIntervalSeconds: 30, latencyThresholdTriggerMs: 250, latencyTestPort: 2016)
            let config = matchingEngine.createDefaultEdgeEventsConfig(latencyThresholdTriggerMs: 300, latencyTestPort: 3765)
            print("DefaultLatencyTestPort3765 Config is \(config)")
            print("DefaultLatencyTestPort3765 Starting Edge Event Connection!")
            return matchingEngine.startEdgeEvents(dmeHost: self.dmeHost, dmePort: self.dmePort, newFindCloudletHandler: self.handleNewFindCloudlet, config: config)
        }.then { status in
            if status == MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus.success {
                print("DefaultLatencyTestPort3765 Edge Events Connection Started!")
                success = true
            } else {
                success = false
                err = "DefaultLatencyTestPort3765 Edge Events Connection could not start. Bad status!"
            }
        }.catch { error  in
            print("DefaultLatencyTestPort3765 Error:  \(error)")
            err = "DefaultLatencyTestPort3765 Test Failed "
        }
        do {
            try awaitPromise(promise)
        } catch {
            print("error awaiting promise \(error)")
        }
        sleep(120)
        matchingEngine.close()
        print("Closing DefaultLatencyTestPort3765 EdgeEvents Connection ")
        print("Leaving DefaultLatencyTestPort3765 - Success:  \(success)")
        return (success, err)
    }

    func testDefaultConfigLatencyTestPort8085() -> (Bool, String) {
        let matchingEngine = MobiledgeXiOSLibraryGrpc.MatchingEngine()
        var success = false
        var err = ""
        var loc = DistributedMatchEngine_Loc.init()
        loc.latitude = 53
        loc.longitude = 10
        let promise = MobiledgeXiOSLibraryGrpc.MobiledgeXLocation.setLastLocation(loc: loc).then { set -> Promise<Bool>in
             if set {
                print("DefaultLatencyTestPort8085 Location Set To Lat:53 Long:10")
                success = true
            }else{
                print("DefaultLatencyTestPort8085 Location Not Set!")
                throw MatchingEngineTestError.setLocationFailed
            }
            return self.registerClient(matchingEngine: matchingEngine)
        }.then { regReply -> Promise<Bool> in
            if !regReply {
                print("DefaultLatencyTestPort8085 Register Client Failed!")
                throw MatchingEngineTestError.registerClientFailed
            }
            print("DefaultLatencyTestPort8085 Register Client Done!")
            return self.findCloudlet(matchingEngine: matchingEngine)
        }.then { cloudlet -> Promise<MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus> in
            if !cloudlet {
                print("DefaultLatencyTestPort8085 Find CLoudlet Failed!")
                throw MatchingEngineTestError.findCloudletFailed
            }
            print("DefaultLatencyTestPort8085 Find Cloudlet Done!")
            //let config = matchingEngine.createDefaultEdgeEventsConfig(latencyUpdateIntervalSeconds: 30, locationUpdateIntervalSeconds: 30, latencyThresholdTriggerMs: 250, latencyTestPort: 2016)
            let config = matchingEngine.createDefaultEdgeEventsConfig(latencyThresholdTriggerMs: 300, latencyTestPort: 8085)
            print("DefaultLatencyTestPort8085 Config is \(config)")
            print("DefaultLatencyTestPort8085 Starting Edge Event Connection!")
            return matchingEngine.startEdgeEvents(dmeHost: self.dmeHost, dmePort: self.dmePort, newFindCloudletHandler: self.handleNewFindCloudlet, config: config)
        }.then { status in
            if status == MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus.success {
                print("DefaultLatencyTestPort8085 Edge Events Connection Started!")
                success = true
            } else {
                success = false
                err = "DefaultLatencyTestPort8085 Edge Events Connection could not start. Bad status!"
            }
        }.catch { error  in
            print("DefaultLatencyTestPort8085 Error:  \(error)")
            err = "DefaultLatencyTestPort8085 Test Failed "
        }
        do {
            try awaitPromise(promise)
        } catch {
            print("error awaiting promise \(error)")
        }
        sleep(120)
        matchingEngine.close()
        print("Closing DefaultLatencyTestPort8085 EdgeEvents Connection ")
        print("Leaving DefaultLatencyTestPort8085 - Success:  \(success)")
        return (success, err)
    }

    func testDefaultConfigLatencyTestPort2085() -> (Bool, String) {
        let matchingEngine = MobiledgeXiOSLibraryGrpc.MatchingEngine()
        var success = false
        var err = ""
        var loc = DistributedMatchEngine_Loc.init()
        loc.latitude = 53
        loc.longitude = 10
        let promise = MobiledgeXiOSLibraryGrpc.MobiledgeXLocation.setLastLocation(loc: loc).then { set -> Promise<Bool>in
             if set {
                print("DefaultLatencyTestPort2085 Location Set To Lat:53 Long:10")
                success = true
            }else{
                print("DefaultLatencyTestPort2085 Location Not Set!")
                throw MatchingEngineTestError.setLocationFailed
            }
            return self.registerClient(matchingEngine: matchingEngine)
        }.then { regReply -> Promise<Bool> in
            if !regReply {
                print("DefaultLatencyTestPort2085 Register Client Failed!")
                throw MatchingEngineTestError.registerClientFailed
            }
            print("DefaultLatencyTestPort2085 Register Client Done!")
            return self.findCloudlet(matchingEngine: matchingEngine)
        }.then { cloudlet -> Promise<MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus> in
            if !cloudlet {
                print("DefaultLatencyTestPort2085 Find CLoudlet Failed!")
                throw MatchingEngineTestError.findCloudletFailed
            }
            print("DefaultLatencyTestPort2085 Find Cloudlet Done!")
            //let config = matchingEngine.createDefaultEdgeEventsConfig(latencyUpdateIntervalSeconds: 30, locationUpdateIntervalSeconds: 30, latencyThresholdTriggerMs: 250, latencyTestPort: 2016)
            let config = matchingEngine.createDefaultEdgeEventsConfig(latencyUpdateIntervalSeconds: 5, latencyThresholdTriggerMs: 300, latencyTestPort: 2085)
            print("DefaultLatencyTestPort2085 Config is \(config)")
            print("DefaultLatencyTestPort2085 Starting Edge Event Connection!")
            return matchingEngine.startEdgeEvents(dmeHost: self.dmeHost, dmePort: self.dmePort, newFindCloudletHandler: self.handleNewFindCloudlet, config: config)
        }.then { status in
            if status == MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus.success {
                print("DefaultLatencyTestPort2085 Edge Events Connection Started!")
                success = true
            } else {
                success = false
                err = "DefaultLatencyTestPort2085 Edge Events Connection could not start. Bad status!"
            }
        }.catch { error  in
            print("DefaultLatencyTestPort2085 Error:  \(error)")
            err = "DefaultLatencyTestPort2085 Test Failed "
        }
        do {
            try awaitPromise(promise)
        } catch {
            print("error awaiting promise \(error)")
        }
        sleep(120)
        matchingEngine.close()
        print("Closing DefaultLatencyTestPort2085 EdgeEvents Connection ")
        print("Leaving DefaultLatencyTestPort2085 - Success:  \(success)")
        return (success, err)
    }

    func doHighLatency() {
        print("Starting testGetLocation")
        var result = testGetLocation()
        if result.0 != true{
            print("Get Location Failed. Error is \(result.1)")
            print("Exiting")
        } else{
            print("Finished TestGetLocation\n\n")
        }
        result = testDefaultConfigLatencyToHighTrigger()
        if result.0 != true{
            print("Latency Too High Trigger Test Failed. Error is \(result.1)")
            print("Exiting")
        } else {
            print("Finished Latency Too High Trigger Test!\n\n")
        }
        sleep(5)

    }

    func testDefaultConfigLatencyToHighTrigger() -> (Bool, String) {
        let matchingEngine = MobiledgeXiOSLibraryGrpc.MatchingEngine()
        var success = false
        var err = ""
        var loc = DistributedMatchEngine_Loc.init()
        loc.latitude = 53
        loc.longitude = 10
        let promise = MobiledgeXiOSLibraryGrpc.MobiledgeXLocation.setLastLocation(loc: loc).then { set -> Promise<Bool>in
             if set {
                print("LatencyTooHigh Trigger Location Set To Lat:53 Long:10")
                success = true
            }else{
                print("LatencyTooHigh Trigger Location Not Set!")
                throw MatchingEngineTestError.setLocationFailed
            }
            return self.registerClient(matchingEngine: matchingEngine)
        }.then { regReply -> Promise<Bool> in
            if !regReply {
                print("LatencyTooHigh Trigger Register Client Failed!")
                throw MatchingEngineTestError.registerClientFailed
            }
            print("LatencyTooHigh Trigger Register Client Done!")
            return self.findCloudlet(matchingEngine: matchingEngine)
        }.then { cloudlet -> Promise<MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus> in
            if !cloudlet {
                print("LatencyTooHigh Trigger Find CLoudlet Failed!")
                throw MatchingEngineTestError.findCloudletFailed
            }
            print("LatencyTooHigh Trigger Find Cloudlet Done!")
            //let config = matchingEngine.createDefaultEdgeEventsConfig(latencyUpdateIntervalSeconds: 30, locationUpdateIntervalSeconds: 30, latencyThresholdTriggerMs: 250, latencyTestPort: 2016)
            let config = matchingEngine.createDefaultEdgeEventsConfig(latencyUpdateIntervalSeconds: 10, latencyThresholdTriggerMs: 350)
            print("LatencyTooHigh Trigger Config is \(config)")
            print("LatencyTooHigh Trigger Starting Edge Event Connection!")
            return matchingEngine.startEdgeEvents(dmeHost: self.dmeHost, dmePort: self.dmePort, newFindCloudletHandler: self.handleNewFindCloudlet, config: config)
        }.then { status in
            if status == MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus.success {
                print("LatencyTooHigh Trigger Edge Events Connection Started!")
                success = true
            } else {
                success = false
                err = "LatencyTooHigh Trigger Edge Events Connection could not start. Bad status!"
            }
        }.catch { error  in
            print("LatencyTooHigh Trigger Error:  \(error)")
            err = "LatencyTooHigh Trigger Test Failed "
        }
        do {
            try awaitPromise(promise)
        } catch {
            print("error awaiting promise \(error)")
        }
        sleep(120)
        matchingEngine.close()
        print("Closing LatencyTooHigh Trigger EdgeEvents Connection ")
        print("Leaving LatencyTooHigh Trigger - Success:  \(success)")
        return (success, err)
    }

    func doAppHealth() {
        print("Starting testGetLocation")
        var result = testGetLocation()
        if result.0 != true{
            print("Get Location Failed. Error is \(result.1)")
            print("Exiting")
        } else{
            print("Finished TestGetLocation\n\n")
        }
        result = testDefaultConfigAppHealthTrigger()
        if result.0 != true{
            print("AppInstanceHealth Trigger Test Failed. Error is \(result.1)")
            print("Exiting")
        } else {
            print("Finished AppInstanceHealth Trigger Test!\n\n")
        }
        sleep(5)

    }

    func testDefaultConfigAppHealthTrigger() -> (Bool, String) {
        let matchingEngine = MobiledgeXiOSLibraryGrpc.MatchingEngine()
        var success = false
        var err = ""
        var loc = DistributedMatchEngine_Loc.init()
        loc.latitude = 53
        loc.longitude = 10
        let promise = MobiledgeXiOSLibraryGrpc.MobiledgeXLocation.setLastLocation(loc: loc).then { set -> Promise<Bool>in
             if set {
                print("AppInstanceHealth Trigger Location Set To Lat:53 Long:10")
                success = true
            }else{
                print("AppInstanceHealth Trigger Location Not Set!")
                throw MatchingEngineTestError.setLocationFailed
            }
            return self.registerClient(matchingEngine: matchingEngine)
        }.then { regReply -> Promise<Bool> in
            if !regReply {
                print("AppInstanceHealth Trigger Register Client Failed!")
                throw MatchingEngineTestError.registerClientFailed
            }
            print("AppInstanceHealth Trigger Register Client Done!")
            return self.findCloudlet(matchingEngine: matchingEngine)
        }.then { cloudlet -> Promise<MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus> in
            if !cloudlet {
                print("AppInstanceHealth Trigger Find CLoudlet Failed!")
                throw MatchingEngineTestError.findCloudletFailed
            }
            print("AppInstanceHealth Trigger Find Cloudlet Done!")
            //let config = matchingEngine.createDefaultEdgeEventsConfig(latencyUpdateIntervalSeconds: 30, locationUpdateIntervalSeconds: 30, latencyThresholdTriggerMs: 250, latencyTestPort: 2016)
            let config = matchingEngine.createDefaultEdgeEventsConfig(latencyUpdateIntervalSeconds: 10, latencyThresholdTriggerMs: 350)
            print("AppInstanceHealth Trigger Config is \(config)")
            print("AppInstanceHealth Trigger Starting Edge Event Connection!")
            return matchingEngine.startEdgeEvents(dmeHost: self.dmeHost, dmePort: self.dmePort, newFindCloudletHandler: self.handleNewFindCloudlet, config: config)
        }.then { status in
            if status == MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus.success {
                print("AppInstanceHealth Trigger Edge Events Connection Started!")
                success = true
            } else {
                success = false
                err = "AppInstanceHealth Trigger Edge Events Connection could not start. Bad status!"
            }
        }.catch { error  in
            print("AppInstanceHealth Trigger Error:  \(error)")
            err = "AppInstanceHealth Trigger Test Failed "
        }
        do {
            try awaitPromise(promise)
        } catch {
            print("error awaiting promise \(error)")
        }
        sleep(120)
        matchingEngine.close()
        print("Closing AppInstanceHealth Trigger EdgeEvents Connection ")
        print("Leaving AppInstanceHealth Trigger - Success:  \(success)")
        return (success, err)
    }

    func doCloudState() {
        print("Starting testGetLocation")
        var result = testGetLocation()
        if result.0 != true{
            print("Get Location Failed. Error is \(result.1)")
            print("Exiting")
        } else{
            print("Finished TestGetLocation\n\n")
        }
        result = testDefaultConfigCloudletStateChangeTrigger()
        if result.0 != true{
            print("CloudletState Trigger Test Failed. Error is \(result.1)")
            print("Exiting")
        } else {
            print("Finished CloudletState Trigger Test!\n\n")
        }
        sleep(5)

    }

    func testDefaultConfigCloudletStateChangeTrigger() -> (Bool, String) {
        let matchingEngine = MobiledgeXiOSLibraryGrpc.MatchingEngine()
        var success = false
        var err = ""
        var loc = DistributedMatchEngine_Loc.init()
        loc.latitude = 53
        loc.longitude = 10
        let promise = MobiledgeXiOSLibraryGrpc.MobiledgeXLocation.setLastLocation(loc: loc).then { set -> Promise<Bool>in
             if set {
                print("CloudletState Trigger Location Set To Lat:53 Long:10")
                success = true
            }else{
                print("CloudletState Trigger Location Not Set!")
                throw MatchingEngineTestError.setLocationFailed
            }
            return self.registerClient(matchingEngine: matchingEngine)
        }.then { regReply -> Promise<Bool> in
            if !regReply {
                print("CloudletState Trigger Register Client Failed!")
                throw MatchingEngineTestError.registerClientFailed
            }
            print("CloudletState Trigger Register Client Done!")
            return self.findCloudlet(matchingEngine: matchingEngine)
        }.then { cloudlet -> Promise<MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus> in
            if !cloudlet {
                print("CloudletState Trigger Find CLoudlet Failed!")
                throw MatchingEngineTestError.findCloudletFailed
            }
            print("CloudletState Trigger Find Cloudlet Done!")
            //let config = matchingEngine.createDefaultEdgeEventsConfig(latencyUpdateIntervalSeconds: 30, locationUpdateIntervalSeconds: 30, latencyThresholdTriggerMs: 250, latencyTestPort: 2016)
            let config = matchingEngine.createDefaultEdgeEventsConfig(latencyUpdateIntervalSeconds: 10, latencyThresholdTriggerMs: 350)
            print("CloudletState Trigger Config is \(config)")
            print("CloudletState Trigger Starting Edge Event Connection!")
            return matchingEngine.startEdgeEvents(dmeHost: self.dmeHost, dmePort: self.dmePort, newFindCloudletHandler: self.handleNewFindCloudlet, config: config)
        }.then { status in
            if status == MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus.success {
                print("CloudletState Trigger Edge Events Connection Started!")
                success = true
            } else {
                success = false
                err = "CloudletState Trigger Edge Events Connection could not start. Bad status!"
            }
        }.catch { error  in
            print("CloudletState Trigger Error:  \(error)")
            err = "CloudletState Trigger Test Failed "
        }
        do {
            try awaitPromise(promise)
        } catch {
            print("error awaiting promise \(error)")
        }
        sleep(300)
        matchingEngine.close()
        print("Closing CloudletState Trigger EdgeEvents Connection ")
        print("Leaving CloudletState Trigger - Success:  \(success)")
        return (success, err)
    }

    func doCloudMaint() {
        print("Starting testGetLocation")
        var result = testGetLocation()
        if result.0 != true{
            print("Get Location Failed. Error is \(result.1)")
            print("Exiting")
        } else{
            print("Finished TestGetLocation\n\n")
        }
        result = testDefaultConfigCloudletMaintenanceTrigger()
        if result.0 != true{
            print("CloudletMaint Trigger Test Failed. Error is \(result.1)")
            print("Exiting")
        } else {
            print("Finished CloudletMaint Trigger Test!\n\n")
        }
        sleep(5)

    }

    func testDefaultConfigCloudletMaintenanceTrigger() -> (Bool, String) {
        let matchingEngine = MobiledgeXiOSLibraryGrpc.MatchingEngine()
        var success = false
        var err = ""
        var loc = DistributedMatchEngine_Loc.init()
        loc.latitude = 53
        loc.longitude = 10
        let promise = MobiledgeXiOSLibraryGrpc.MobiledgeXLocation.setLastLocation(loc: loc).then { set -> Promise<Bool>in
             if set {
                print("CloudletMaint Trigger Location Set To Lat:53 Long:10")
                success = true
            }else{
                print("CloudletMaint Trigger Location Not Set!")
                throw MatchingEngineTestError.setLocationFailed
            }
            return self.registerClient(matchingEngine: matchingEngine)
        }.then { regReply -> Promise<Bool> in
            if !regReply {
                print("CloudletMaint Trigger Register Client Failed!")
                throw MatchingEngineTestError.registerClientFailed
            }
            print("CloudletMaint Trigger Register Client Done!")
            return self.findCloudlet(matchingEngine: matchingEngine)
        }.then { cloudlet -> Promise<MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus> in
            if !cloudlet {
                print("CloudletMaint Trigger Find CLoudlet Failed!")
                throw MatchingEngineTestError.findCloudletFailed
            }
            print("CloudletMaint Trigger Find Cloudlet Done!")
            //let config = matchingEngine.createDefaultEdgeEventsConfig(latencyUpdateIntervalSeconds: 30, locationUpdateIntervalSeconds: 30, latencyThresholdTriggerMs: 250, latencyTestPort: 2016)
            let config = matchingEngine.createDefaultEdgeEventsConfig(latencyUpdateIntervalSeconds: 30, locationUpdateIntervalSeconds: 30, latencyThresholdTriggerMs: 350, latencyTestPort: 2016)
            //let config = matchingEngine.createEdgeEventsConfig(newFindCloudletEventTriggers: Set<MobiledgeXiOSLibraryGrpc.EdgeEvents.FindCloudletEventTrigger>, latencyThresholdTriggerMs: 400, performanceSwitchMargin: 0.05, latencyTestPort: 2016, latencyUpdateConfig: nil, locationUpdateConfig: nil, latencyTestNetwork: "")
            print("CloudletMaint Trigger Config is \(config)")
            print("CloudletMaint Trigger Starting Edge Event Connection!")
            return matchingEngine.startEdgeEvents(dmeHost: self.dmeHost, dmePort: self.dmePort, newFindCloudletHandler: self.handleNewFindCloudlet, config: config)
        }.then { status in
            if status == MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus.success {
                print("CloudletMaint Trigger Edge Events Connection Started!")
                success = true
            } else {
                success = false
                err = "CloudletMaint Trigger Edge Events Connection could not start. Bad status!"
            }
        }.catch { error  in
            print("CloudletMaint Trigger Error:  \(error)")
            err = "CloudletMaint Trigger Test Failed "
        }
        do {
            try awaitPromise(promise)
        } catch {
            print("error awaiting promise \(error)")
        }
        sleep(600)
        matchingEngine.close()
        print("Closing CloudletMaint Trigger EdgeEvents Connection ")
        print("Leaving CloudletMaint Trigger - Success:  \(success)")
        return (success, err)
    }

    func doSingleInstLatencyTooHigh() {
        print("Starting testGetLocation")
        var result = testGetLocation()
        if result.0 != true{
            print("Get Location Failed. Error is \(result.1)")
            print("Exiting")
        } else{
            print("Finished TestGetLocation\n\n")
        }
        result = testSingleInstLatencyTooHigh()
        if result.0 != true{
            print("Single Instance Latency Too High Trigger Test Failed. Error is \(result.1)")
            print("Exiting")
        } else {
            print("Finished Single Instance Latency Too High Trigger Test!\n\n")
        }
        sleep(5)

    }

    func testSingleInstLatencyTooHigh() -> (Bool, String) {
        let matchingEngine = MobiledgeXiOSLibraryGrpc.MatchingEngine()
        var success = false
        var err = ""
        var loc = DistributedMatchEngine_Loc.init()
        loc.latitude = 53
        loc.longitude = 10
        let promise = MobiledgeXiOSLibraryGrpc.MobiledgeXLocation.setLastLocation(loc: loc).then { set -> Promise<Bool>in
             if set {
                print("Single Instance Latency Too High Trigger Location Set To Lat:53 Long:10")
                success = true
            }else{
                print("Single Instance Latency Too High Trigger Location Not Set!")
                throw MatchingEngineTestError.setLocationFailed
            }
            return self.registerClient(matchingEngine: matchingEngine)
        }.then { regReply -> Promise<Bool> in
            if !regReply {
                print("Single Instance Latency Too High Trigger Register Client Failed!")
                throw MatchingEngineTestError.registerClientFailed
            }
            print("Single Instance Latency Too High Trigger Register Client Done!")
            return self.findCloudlet(matchingEngine: matchingEngine)
        }.then { cloudlet -> Promise<MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus> in
            if !cloudlet {
                print("Single Instance Latency Too High Trigger Find CLoudlet Failed!")
                throw MatchingEngineTestError.findCloudletFailed
            }
            print("Single Instance Latency Too High Trigger Find Cloudlet Done!")
            //let config = matchingEngine.createDefaultEdgeEventsConfig(latencyUpdateIntervalSeconds: 30, locationUpdateIntervalSeconds: 30, latencyThresholdTriggerMs: 250, latencyTestPort: 2016)
            let config = matchingEngine.createDefaultEdgeEventsConfig(latencyUpdateIntervalSeconds: 15, locationUpdateIntervalSeconds: 15, latencyThresholdTriggerMs: 350, latencyTestPort: 2016)
            print("Single Instance Latency Too High Trigger Config is \(config)")
            print("Single Instance Latency Too High Trigger Starting Edge Event Connection!")
            return matchingEngine.startEdgeEvents(dmeHost: self.dmeHost, dmePort: self.dmePort, newFindCloudletHandler: self.handleNewFindCloudlet, config: config)
        }.then { status in
            if status == MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus.success {
                print("Single Instance Latency Too High Trigger Edge Events Connection Started!")
                success = true
            } else {
                success = false
                err = "Single Instance Latency Too High Trigger Edge Events Connection could not start. Bad status!"
            }
        }.catch { error  in
            print("Single Instance Latency Too High Trigger Error:  \(error)")
            err = "Single Instance Latency Too High Trigger Test Failed "
        }
        do {
            try awaitPromise(promise)
        } catch {
            print("error awaiting promise \(error)")
        }
        sleep(120)
        matchingEngine.close()
        print("Closing Single Instance Latency Too High Trigger EdgeEvents Connection ")
        print("Leaving Single Instance Latency Too High Trigger - Success:  \(success)")
        return (success, err)
    }

    func doSingleInstAppHealth() {
        print("Starting testGetLocation")
        var result = testGetLocation()
        if result.0 != true{
            print("Get Location Failed. Error is \(result.1)")
            print("Exiting")
        } else{
            print("Finished TestGetLocation\n\n")
        }
        result = testSingleInstAppHealth()
        if result.0 != true{
            print("Single Instance App Health Trigger Test Failed. Error is \(result.1)")
            print("Exiting")
        } else {
            print("Finished Single Instance App Health Trigger Test!\n\n")
        }
        sleep(5)

    }

    func testSingleInstAppHealth() -> (Bool, String) {
        let matchingEngine = MobiledgeXiOSLibraryGrpc.MatchingEngine()
        var success = false
        var err = ""
        var loc = DistributedMatchEngine_Loc.init()
        loc.latitude = 53
        loc.longitude = 10
        let promise = MobiledgeXiOSLibraryGrpc.MobiledgeXLocation.setLastLocation(loc: loc).then { set -> Promise<Bool>in
             if set {
                print("Single Instance App Health Trigger Location Set To Lat:53 Long:10")
                success = true
            }else{
                print("Single Instance App Health Trigger Location Not Set!")
                throw MatchingEngineTestError.setLocationFailed
            }
            return self.registerClient(matchingEngine: matchingEngine)
        }.then { regReply -> Promise<Bool> in
            if !regReply {
                print("Single Instance App Health Trigger Register Client Failed!")
                throw MatchingEngineTestError.registerClientFailed
            }
            print("Single Instance App Health Trigger Register Client Done!")
            return self.findCloudlet(matchingEngine: matchingEngine)
        }.then { cloudlet -> Promise<MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus> in
            if !cloudlet {
                print("Single Instance App Health Trigger Find CLoudlet Failed!")
                throw MatchingEngineTestError.findCloudletFailed
            }
            print("Single Instance App Health Trigger Find Cloudlet Done!")
            //let config = matchingEngine.createDefaultEdgeEventsConfig(latencyUpdateIntervalSeconds: 30, locationUpdateIntervalSeconds: 30, latencyThresholdTriggerMs: 250, latencyTestPort: 2016)
            let config = matchingEngine.createDefaultEdgeEventsConfig(latencyUpdateIntervalSeconds: 15, locationUpdateIntervalSeconds: 15, latencyThresholdTriggerMs: 450, latencyTestPort: 2016)
            print("Single Instance App Health Trigger Config is \(config)")
            print("Single Instance App Health Trigger Starting Edge Event Connection!")
            return matchingEngine.startEdgeEvents(dmeHost: self.dmeHost, dmePort: self.dmePort, newFindCloudletHandler: self.handleNewFindCloudlet, config: config)
        }.then { status in
            if status == MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus.success {
                print("Single Instance App Health Trigger Edge Events Connection Started!")
                success = true
            } else {
                success = false
                err = "Single Instance App Health Trigger Edge Events Connection could not start. Bad status!"
            }
        }.catch { error  in
            print("Single Instance App Health Trigger Error:  \(error)")
            err = "Single Instance App Health Trigger Test Failed "
        }
        do {
            try awaitPromise(promise)
        } catch {
            print("error awaiting promise \(error)")
        }
        sleep(120)
        matchingEngine.close()
        print("Closing Single Instance App Health Trigger EdgeEvents Connection ")
        print("Leaving Single Instance App Health Trigger - Success:  \(success)")
        return (success, err)
    }

    func doSingleInstCloudletState() {
        print("Starting testGetLocation")
        var result = testGetLocation()
        if result.0 != true{
            print("Get Location Failed. Error is \(result.1)")
            print("Exiting")
        } else{
            print("Finished TestGetLocation\n\n")
        }
        result = testSingleInstCloudletState()
        if result.0 != true{
            print("Single Instance Cloudlet State Trigger Test Failed. Error is \(result.1)")
            print("Exiting")
        } else {
            print("Finished Single Instance Cloudlet State Trigger Test!\n\n")
        }
        sleep(5)

    }

    func testSingleInstCloudletState() -> (Bool, String) {
        let matchingEngine = MobiledgeXiOSLibraryGrpc.MatchingEngine()
        var success = false
        var err = ""
        var loc = DistributedMatchEngine_Loc.init()
        loc.latitude = 53
        loc.longitude = 10
        let promise = MobiledgeXiOSLibraryGrpc.MobiledgeXLocation.setLastLocation(loc: loc).then { set -> Promise<Bool>in
             if set {
                print("Single Instance Cloudlet State Trigger Location Set To Lat:53 Long:10")
                success = true
            }else{
                print("Single Instance Cloudlet State Trigger Location Not Set!")
                throw MatchingEngineTestError.setLocationFailed
            }
            return self.registerClient(matchingEngine: matchingEngine)
        }.then { regReply -> Promise<Bool> in
            if !regReply {
                print("Single Instance Cloudlet State Trigger Register Client Failed!")
                throw MatchingEngineTestError.registerClientFailed
            }
            print("Single Instance Cloudlet State Trigger Register Client Done!")
            return self.findCloudlet(matchingEngine: matchingEngine)
        }.then { cloudlet -> Promise<MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus> in
            if !cloudlet {
                print("Single Instance Cloudlet State Trigger Find CLoudlet Failed!")
                throw MatchingEngineTestError.findCloudletFailed
            }
            print("Single Instance Cloudlet State Trigger Find Cloudlet Done!")
            //let config = matchingEngine.createDefaultEdgeEventsConfig(latencyUpdateIntervalSeconds: 30, locationUpdateIntervalSeconds: 30, latencyThresholdTriggerMs: 250, latencyTestPort: 2016)
            let config = matchingEngine.createDefaultEdgeEventsConfig(latencyUpdateIntervalSeconds: 15, locationUpdateIntervalSeconds: 15, latencyThresholdTriggerMs: 350, latencyTestPort: 2016)
            print("Single Instance Cloudlet State Trigger Config is \(config)")
            print("Single Instance Cloudlet State Trigger Starting Edge Event Connection!")
            return matchingEngine.startEdgeEvents(dmeHost: self.dmeHost, dmePort: self.dmePort, newFindCloudletHandler: self.handleNewFindCloudlet, config: config)
        }.then { status in
            if status == MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus.success {
                print("Single Instance Cloudlet State Trigger Edge Events Connection Started!")
                success = true
            } else {
                success = false
                err = "Single Instance Cloudlet State Trigger Edge Events Connection could not start. Bad status!"
            }
        }.catch { error  in
            print("Single Instance Cloudlet State Trigger Error:  \(error)")
            err = "Single Instance Cloudlet State Trigger Test Failed "
        }
        do {
            try awaitPromise(promise)
        } catch {
            print("error awaiting promise \(error)")
        }
        sleep(120)
        matchingEngine.close()
        print("Closing Single Instance Cloudlet State Trigger EdgeEvents Connection ")
        print("Leaving Single Instance Cloudlet State Trigger - Success:  \(success)")
        return (success, err)
    }

    func doSingleInstCloudletMaintenance() {
        print("Starting testGetLocation")
        var result = testGetLocation()
        if result.0 != true{
            print("Get Location Failed. Error is \(result.1)")
            print("Exiting")
        } else{
            print("Finished TestGetLocation\n\n")
        }
        result = testSingleInstCloudletMaintenance()
        if result.0 != true{
            print("Single Instance Cloudlet Maintence Trigger Test Failed. Error is \(result.1)")
            print("Exiting")
        } else {
            print("Finished Single Instance Cloudlet Maintence Trigger Test!\n\n")
        }
        sleep(5)

    }

    func testSingleInstCloudletMaintenance() -> (Bool, String) {
        let matchingEngine = MobiledgeXiOSLibraryGrpc.MatchingEngine()
        var success = false
        var err = ""
        var loc = DistributedMatchEngine_Loc.init()
        loc.latitude = 53
        loc.longitude = 10
        let promise = MobiledgeXiOSLibraryGrpc.MobiledgeXLocation.setLastLocation(loc: loc).then { set -> Promise<Bool>in
             if set {
                print("Single Instance Cloudlet Maintence Trigger Location Set To Lat:53 Long:10")
                success = true
            }else{
                print("Single Instance Cloudlet Maintence Trigger Location Not Set!")
                throw MatchingEngineTestError.setLocationFailed
            }
            return self.registerClient(matchingEngine: matchingEngine)
        }.then { regReply -> Promise<Bool> in
            if !regReply {
                print("Single Instance Cloudlet Maintence Trigger Register Client Failed!")
                throw MatchingEngineTestError.registerClientFailed
            }
            print("Single Instance Cloudlet Maintence Trigger Register Client Done!")
            return self.findCloudlet(matchingEngine: matchingEngine)
        }.then { cloudlet -> Promise<MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus> in
            if !cloudlet {
                print("Single Instance Cloudlet Maintence Trigger Find CLoudlet Failed!")
                throw MatchingEngineTestError.findCloudletFailed
            }
            print("Single Instance Cloudlet Maintence Trigger Find Cloudlet Done!")
            //let config = matchingEngine.createDefaultEdgeEventsConfig(latencyUpdateIntervalSeconds: 30, locationUpdateIntervalSeconds: 30, latencyThresholdTriggerMs: 250, latencyTestPort: 2016)
            let config = matchingEngine.createDefaultEdgeEventsConfig(latencyUpdateIntervalSeconds: 15, locationUpdateIntervalSeconds: 15, latencyThresholdTriggerMs: 350, latencyTestPort: 2016)
            print("Single Instance Cloudlet Maintence Trigger Config is \(config)")
            print("Single Instance Cloudlet Maintence Trigger Starting Edge Event Connection!")
            return matchingEngine.startEdgeEvents(dmeHost: self.dmeHost, dmePort: self.dmePort, newFindCloudletHandler: self.handleNewFindCloudlet, config: config)
        }.then { status in
            if status == MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus.success {
                print("Single Instance Cloudlet Maintence Trigger Edge Events Connection Started!")
                success = true
            } else {
                success = false
                err = "Single Instance Cloudlet Maintence Trigger Edge Events Connection could not start. Bad status!"
            }
        }.catch { error  in
            print("Single Instance Cloudlet Maintence Trigger Error:  \(error)")
            err = "Single Instance Cloudlet Maintence Trigger Test Failed "
        }
        do {
            try awaitPromise(promise)
        } catch {
            print("error awaiting promise \(error)")
        }
        sleep(120)
        matchingEngine.close()
        print("Closing Single Instance Cloudlet Maintence Trigger EdgeEvents Connection ")
        print("Leaving Single Instance Cloudlet Maintence Trigger - Success:  \(success)")
        return (success, err)
    }


    func doAutoMigrateOff() {
        print("Starting testGetLocation")
        var result = testGetLocation()
        if result.0 != true{
            print("Get Location Failed. Error is \(result.1)")
            print("Exiting")
        } else{
            print("Finished TestGetLocation\n\n")
        }
        result = testDefaultConfigAutoMigrationOff()
        if result.0 != true{
            print("AutoMigrate Off Test Failed. Error is \(result.1)")
            print("Exiting")
        } else {
            print("Finished AutoMigrate Off Test!\n\n")
        }
        sleep(5)

    }

    func testDefaultConfigAutoMigrationOff() -> (Bool, String) {
        let matchingEngine = MobiledgeXiOSLibraryGrpc.MatchingEngine()
        var success = false
        var err = ""
        var loc = DistributedMatchEngine_Loc.init()
        loc.latitude = 53
        loc.longitude = 10
        let promise = MobiledgeXiOSLibraryGrpc.MobiledgeXLocation.setLastLocation(loc: loc).then { set -> Promise<Bool>in
             if set {
                print("AutoMigrate Off Location Set To Lat:53 Long:10")
                success = true
            }else{
                print("AutoMigrate Off Location Not Set!")
                throw MatchingEngineTestError.setLocationFailed
            }
            return self.registerClient(matchingEngine: matchingEngine)
        }.then { regReply -> Promise<Bool> in
            if !regReply {
                print("AutoMigrate Off Register Client Failed!")
                throw MatchingEngineTestError.registerClientFailed
            }
            print("AutoMigrate Off Register Client Done!")
            return self.findCloudlet(matchingEngine: matchingEngine)
        }.then { cloudlet -> Promise<MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus> in
            if !cloudlet {
                print("AutoMigrate Off Find CLoudlet Failed!")
                throw MatchingEngineTestError.findCloudletFailed
            }
            print("AutoMigrate Off Find Cloudlet Done!")
            //let config = matchingEngine.createDefaultEdgeEventsConfig(latencyUpdateIntervalSeconds: 30, locationUpdateIntervalSeconds: 30, latencyThresholdTriggerMs: 250, latencyTestPort: 2016)
            let config = matchingEngine.createDefaultEdgeEventsConfig(latencyUpdateIntervalSeconds: 10, latencyThresholdTriggerMs: 350)
            print("AutoMigrate Off Config is \(config)")
            print("AutoMigrate Off Starting Edge Event Connection!")
            return matchingEngine.startEdgeEvents(dmeHost: self.dmeHost, dmePort: self.dmePort, newFindCloudletHandler: self.handleNewFindCloudlet, config: config)
        }.then { status in
            if status == MobiledgeXiOSLibraryGrpc.EdgeEvents.EdgeEventsStatus.success {
                print("AutoMigrate Off Edge Events Connection Started!")
                success = true
            } else {
                success = false
                err = "AutoMigrate Off Edge Events Connection could not start. Bad status!"
            }
        }.catch { error  in
            print("AutoMigrate Off Error:  \(error)")
            err = "AutoMigrate Off Test Failed "
        }
        do {
            try awaitPromise(promise)
        } catch {
            print("error awaiting promise \(error)")
        }
        sleep(300)
        matchingEngine.close()
        print("Closing AutoMigrate Off EdgeEvents Connection ")
        print("Leaving AutoMigrate Off - Success:  \(success)")
        return (success, err)
    }

}

