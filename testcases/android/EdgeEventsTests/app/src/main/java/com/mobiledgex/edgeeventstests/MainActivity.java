package com.mobiledgex.edgeeventstests;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import android.Manifest;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.app.UiAutomation;
import android.content.Context;
import android.location.Location;
import android.os.Build;
import android.os.Looper;
//import androidx.test.platform.app.InstrumentationRegistry;

//import android.telephony.TelephonyManager;
import android.util.Log;
import android.util.Pair;
import android.app.Activity;

//import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationCallback;
import com.google.android.gms.location.LocationResult;

import com.google.common.eventbus.Subscribe;
import com.mobiledgex.matchingengine.MatchingEngine;
import distributed_match_engine.AppClient;
import com.mobiledgex.matchingengine.edgeeventsconfig.UpdateConfig;
import com.mobiledgex.matchingengine.EdgeEventsConnection;
import com.mobiledgex.matchingengine.edgeeventsconfig.EdgeEventsConfig;
import com.mobiledgex.matchingengine.edgeeventsconfig.FindCloudletEvent;
import com.mobiledgex.matchingengine.edgeeventsconfig.FindCloudletEventTrigger;
import com.mobiledgex.matchingengine.performancemetrics.NetTest;
import com.mobiledgex.matchingengine.DmeDnsException;
import com.mobiledgex.mel.MelMessaging;
import com.mobiledgex.matchingengine.util.RequestPermissions;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;

import com.google.android.gms.location.LocationServices;
import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationRequest;
//import android.content.SharedPreferences;
//import android.preference.PreferenceManager;



//import static com.mobiledgex.matchingengine.util.RequestPermissions.REQUEST_MULTIPLE_PERMISSION;
//import static com.mobiledgex.matchingengine.util.RequestPermissions.permissions;
//import static distributed_match_engine.AppClient.FindCloudletReply.FindStatus.FIND_FOUND;

public class MainActivity extends AppCompatActivity {

    String TAG = "MainActivity";
    public static final long GRPC_TIMEOUT_MS = 15000;
    private Activity context;

    // QA
//    public static String carrierName = "GDDT";
//    public static final String organizationName = "automation_dev_org";
//    public static final String applicationName = "automation-sdk-porttest";
//    public static final String appVersion = "1.0";
//    public static String hostOverride = "eu-qa.dme.mobiledgex.net";
//    public static String findCloudletCarrierOverride = "GDDT"; // Allow "Any" if using "", but this likely breaks test cases.

    public static String carrierName = "GDDT";
    public static final String organizationName = "automation_dev_org";
    public static final String applicationName = "automation-sdk-porttest";
    public static final String appVersion = "1.0";
    public static String hostOverride = "eu-qa.dme.mobiledgex.net";
    public static String findCloudletCarrierOverride = "GDDT"; // Allow "Any" if using "", but this likely breaks test cases.

    // Production
    //public static String carrierName = "TELUS";
    //public static final String organizationName = "MobiledgeX-Samples";
    //public static final String applicationName = "ComputerVision";
    //public static final String applicationName = "sdktest";
    //public static final String appVersion = "9.0";
    //public static final String appVersion = "2.2";
    //public static String hostOverride = "wifi.dme.mobiledgex.net";
    //public static String findCloudletCarrierOverride = "TELUS"; // Allow "Any" if using "", but this likely breaks test cases.

    MatchingEngine me;


    public static int portOverride = 50051;
    public boolean useHostOverride = true;
    public boolean useWifiOnly = true; // This also disables network switching, since the android default is WiFi.

    public static final int REQUEST_MULTIPLE_PERMISSION = 1001;
    public static final String[] permissions = new String[] { // Special Enhanced security requests.
            Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.ACCESS_COARSE_LOCATION,
            Manifest.permission.READ_PHONE_STATE, // Get network state.
    };

    private LocationCallback mLocationCallback;
    private LocationResult mLocationResult;
    FusedLocationProviderClient fusedLocationClient;
    private LocationRequest mLocationRequest = new LocationRequest();

    private void startLocationUpdates() {
        try {
            if (fusedLocationClient == null) {
                fusedLocationClient = LocationServices.getFusedLocationProviderClient(this);
            }
            mLocationCallback = new LocationCallback() {
                @Override
                public void onLocationResult(LocationResult locationResult) {
                    if (locationResult == null) {
                        return;
                    }
                    String clientLocText = "";
                    mLocationResult = locationResult;
                    // Post into edgeEvents updater:
                    for (Location location : locationResult.getLocations()) {
                        // Update UI with client location data
                        clientLocText += "[" + location.toString() + "]";
                    }
                }
            };
            fusedLocationClient.requestLocationUpdates(
                    mLocationRequest,
                    mLocationCallback,
                    Looper.getMainLooper() /* Looper */);
        } catch (SecurityException se) {
            Log.e(TAG, "SecurityException message: " + se.getLocalizedMessage());
            se.printStackTrace();
            Log.i(TAG, "App should Request location permissions during onResume() or onCreate().");
        }
    }

    private MatchingEngine resetMatchingEngine(MatchingEngine me){
        if (me != null) {
            Log.i(TAG, "Closing matching engine...");
            me.close();
            Log.i(TAG, "MatchingEngine closed for test.");
        }
        return me = new MatchingEngine(context);

    }

    CompletableFuture<Void> someFuture;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        context = this;
        requestPermissions(this);
        startLocationUpdates();
        me = new MatchingEngine(context);
        someFuture = CompletableFuture.runAsync(() -> {
            // Insert long running code here. Like get().
            //testDefaultConfigNoChanges();                        // ECQ-3629
            //testDefaultConfigLatencyUpdate5s();                  // ECQ-3630
            //testDefaultConfigLatencyUpdate60s();                 // ECQ-3631
            //testDefaultConfigLatencyUpdateNegitiveSeconds();     // ECQ-3639
            testDefaultConfigLocationUpdate5s();                 // ECQ-
            //testDefaultConfigLocationUpdate60s();
            //testDefaultConfigLocationUpdateNegitiveSeconds();
            //testDefaultConfigLatencyThreshold263();
            //testDefaultConfigLatencyThreshold183();
            //testDefaultConfigLatencyThreshold143();
            //testDefaultConfigLatencyTestPort0();
            //testDefaultConfigLatencyTestPort2015();
            //testDefaultConfigLatencyTestPort2016();
            //testDefaultConfigLatencyTestPort3765();
            //testDefaultConfigLatencyTestPort8085();
            //testDefaultConfigLatencyTestPort2085();
            //testDefaultConfigLatencyToHighTrigger();
            //testDefaultConfigAppHealthTrigger();
            //testDefaultConfigCloudletStateChangeTrigger();
            //testDefaultConfigCloudletMaintenanceTrigger();
            //testDefaultConfigAutoMigrationOff();
        });
    }

    public List<String> getNeededPermissions(AppCompatActivity activity) {
        List<String> permissionsNeeded = new ArrayList<>();
        for (String pStr : permissions) {
            int result = ContextCompat.checkSelfPermission(activity, pStr);
            if (result != PackageManager.PERMISSION_GRANTED) {
                permissionsNeeded.add(pStr);
            }
        }
        return permissionsNeeded;
    }
    public void requestMultiplePermissions(AppCompatActivity activity) {
        // Check which ones missing
        List<String> permissionsNeeded = getNeededPermissions(activity);
        String[] permissionArray;
        if (!permissionsNeeded.isEmpty()) {
            permissionArray = permissionsNeeded.toArray(new String[permissionsNeeded.size()]);
        } else {
            permissionArray = permissions; // Nothing was granted. Ask for all.
        }
        ActivityCompat.requestPermissions(activity, permissionArray, REQUEST_MULTIPLE_PERMISSION);
    }
    /*!
     * Check and ask for permissions needed for MobiledgeX MatchingEngine SDK and EdgeEvents.
     */
    private void requestPermissions(AppCompatActivity appCompatActivity) {
        if (getNeededPermissions(appCompatActivity).size() > 0) {
            requestMultiplePermissions(appCompatActivity);
        }
    }


    public Location getTestLocation() {
        Location location = new Location("EngineCallTestLocation");
        location.setLatitude(33.00);
        location.setLongitude(96.54);
        //location.setLongitude(52.3759);
        //location.setLatitude(9.735603);
        return location;
    }

    public void registerClient(MatchingEngine me) {
        AppClient.RegisterClientReply registerReply;
        AppClient.RegisterClientRequest regRequest;

        try {
            // The app version will be null, but we can build from scratch for test
            List<Pair<String, Long>> ids = me.retrieveCellId(context);
            AppClient.RegisterClientRequest.Builder regRequestBuilder = AppClient.RegisterClientRequest.newBuilder()
                    .setOrgName(organizationName)
                    .setAppName(applicationName)
                    .setAppVers(appVersion);
            if (ids.size() > 0) {
                regRequestBuilder.setCellId(me.retrieveCellId(context).get(0).second.intValue());
            }
            regRequest = regRequestBuilder.build();
            if (useHostOverride) {
                registerReply = me.registerClient(regRequest, hostOverride, portOverride, GRPC_TIMEOUT_MS);
            } else {
                registerReply = me.registerClient(regRequest, GRPC_TIMEOUT_MS);
            }
            //assertEquals("Response SessionCookie should equal MatchingEngine SessionCookie",
            //        registerReply.getSessionCookie(), me.getSessionCookie());
        } catch (DmeDnsException dde) {
            Log.e(TAG, Log.getStackTraceString(dde));
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
        } catch (InterruptedException ioe) {
            Log.e(TAG, Log.getStackTraceString(ioe));
        }
    }

    public void testDefaultConfigNoChanges() {
        //MatchingEngine me = new MatchingEngine(context);
        Log.i(TAG, "EdgeEvent Starting Default Config Test No Changes");
        Future<AppClient.FindCloudletReply> response1;
        AppClient.FindCloudletReply findCloudletReply1;
        me.setMatchingEngineLocationAllowed(true);
        me.setAllowSwitchIfNoSubscriberInfo(true);


        ConcurrentLinkedQueue<AppClient.ServerEdgeEvent> responses = new ConcurrentLinkedQueue<>();
        ConcurrentLinkedQueue<FindCloudletEvent> latencyNewCloudletResponses = new ConcurrentLinkedQueue<>();
        ConcurrentLinkedQueue<EdgeEventsConnection.EdgeEventsError> errors = new ConcurrentLinkedQueue<>();
        CountDownLatch latch = new CountDownLatch(1);
        class EventReceiver2 {
            @Subscribe
            void HandleFindCloudlet(FindCloudletEvent fce) {
                latencyNewCloudletResponses.add(fce);
                Log.i(TAG, "EdgeEvent Received a New FindCloudlet FQDN: " + fce.newCloudlet.getFqdn() + " Trigger: " + fce.trigger);
            }

            @Subscribe
            void HandleEdgeEvent(EdgeEventsConnection.EdgeEventsError error) {
                errors.add(error);
                if(error == EdgeEventsConnection.EdgeEventsError.eventTriggeredButCurrentCloudletIsBest){
                    Log.i(TAG,"EdgeEvent Received an Error:  " + error);
                }
            }
        }

        EventReceiver2 er = new EventReceiver2();
        me.getEdgeEventsBus().register(er);
        try {
            Location location = getTestLocation(); // Test needs this configurable in a sensible way.
            registerClient(me);

            // Cannot use the older API if overriding.
            AppClient.FindCloudletRequest findCloudletRequest = me.createDefaultFindCloudletRequest(context, location)
                    .setCarrierName(findCloudletCarrierOverride)
                    .build();
            EdgeEventsConfig edgeEventsConfig = me.createDefaultEdgeEventsConfig();

            Log.i(TAG, "EdgeEvent Config Settings: " + edgeEventsConfig);

            if (useHostOverride) {
                response1 = me.findCloudletFuture(findCloudletRequest, hostOverride, portOverride, GRPC_TIMEOUT_MS,
                        MatchingEngine.FindCloudletMode.PROXIMITY);
                // start on response1
                me.startEdgeEventsFuture(edgeEventsConfig);
            } else {
                response1 = me.findCloudletFuture(findCloudletRequest, GRPC_TIMEOUT_MS, MatchingEngine.FindCloudletMode.PROXIMITY);
                // start on response1
                me.startEdgeEventsFuture(edgeEventsConfig);
            }

            findCloudletReply1 = response1.get();
            if(findCloudletReply1.getStatus().toString() == "FIND_FOUND"){
                Log.i(TAG,"EdgeEvent Got a Cloudlet!: " + findCloudletReply1.getStatus().toString() + "  FQDN: " +  findCloudletReply1.getFqdn());
            }else{
                Log.i(TAG, "EdgeEvent Cloudlet NOT Found!:  " + findCloudletReply1.getStatus().toString());
            }


            latch.await(GRPC_TIMEOUT_MS * 3, TimeUnit.MILLISECONDS);
            // This is actually unbounded, as the default is infinity latency Processed resposnes, should you wait long enough for that many to start arriving.
            long expectedNum = 1; // edgeEventsConfig.latencyUpdateConfig.maxNumberOfUpdates;
            Log.i(TAG, "EdgeEvent Response Size:  " + responses.size());

            //assertEquals("Must get new FindCloudlet responses back from server.", 0, latencyNewCloudletResponses.size());
            for (AppClient.ServerEdgeEvent s : responses) {
                Log.i(TAG,"EdgeEvent Response Type: " + s.getEventType().toString());
                Log.i(TAG,"EdgeEvent Latancy Average:  " + s.getStatistics().getAvg());
            }
        } catch (DmeDnsException dde) {
            Log.e(TAG, Log.getStackTraceString(dde));
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
        } catch (InterruptedException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
        }//finally {
        //   if (me != null) {
        //       Log.i(TAG, "Closing matching engine...");
        //       me.close();
        //       Log.i(TAG, "MatchingEngine closed for test.");
        //    }
        //}
    }


    public void testDefaultConfigLatencyUpdate5s(){
        Log.i(TAG, "EdgeEvent Starting Default Config Test 5s Latency Update");
        Future<AppClient.FindCloudletReply> response1;
        AppClient.FindCloudletReply findCloudletReply1;
        me.setMatchingEngineLocationAllowed(true);
        me.setAllowSwitchIfNoSubscriberInfo(true);

        // This EdgeEventsConnection test requires an EdgeEvents enabled server.
        // me.setSSLEnabled(false);
        // me.setNetworkSwitchingEnabled(false);

        // attach an EdgeEventBus to receive the server response, if any (inline class):
        ConcurrentLinkedQueue<AppClient.ServerEdgeEvent> responses = new ConcurrentLinkedQueue<>();
        ConcurrentLinkedQueue<FindCloudletEvent> latencyNewCloudletResponses = new ConcurrentLinkedQueue<>();
        ConcurrentLinkedQueue<EdgeEventsConnection.EdgeEventsError> errors = new ConcurrentLinkedQueue<>();
        CountDownLatch latch = new CountDownLatch(1);
        class EventReceiver2 {

            @Subscribe
            void HandleFindCloudlet(FindCloudletEvent fce) {
                latencyNewCloudletResponses.add(fce);
                Log.i(TAG, "EdgeEvent Received a New FindCloudlet FQDN: " + fce.newCloudlet.getFqdn() + " Trigger: " + fce.trigger);

            }

            @Subscribe
            void HandleEdgeEvent(EdgeEventsConnection.EdgeEventsError error) {
                errors.add(error);
                if(error == EdgeEventsConnection.EdgeEventsError.eventTriggeredButCurrentCloudletIsBest){
                    Log.i(TAG,"EdgeEvent Received an Error:  " + error);
                }
            }
        }

        EventReceiver2 er = new EventReceiver2();
        me.getEdgeEventsBus().register(er);

        try {
            Location location = getTestLocation(); // Test needs this configurable in a sensible way.
            registerClient(me);

            // Cannot use the older API if overriding.
            AppClient.FindCloudletRequest findCloudletRequest = me.createDefaultFindCloudletRequest(context, location)
                    .setCarrierName(findCloudletCarrierOverride)
                    .build();

            EdgeEventsConfig edgeEventsConfig = me.createDefaultEdgeEventsConfig(
                    5,
                    0,
                    300,0);

            //Log.i(TAG,"EdgeEvent Config Settings: " + edgeEventsConfig.triggers.toString());
            Log.i(TAG, "EdgeEvent Config Settings: " + edgeEventsConfig);

            if (useHostOverride) {
                response1 = me.findCloudletFuture(findCloudletRequest, hostOverride, portOverride, GRPC_TIMEOUT_MS,
                        MatchingEngine.FindCloudletMode.PROXIMITY);
                // start on response1
                me.startEdgeEvents(edgeEventsConfig);
            } else {
                response1 = me.findCloudletFuture(findCloudletRequest, GRPC_TIMEOUT_MS, MatchingEngine.FindCloudletMode.PROXIMITY);
                // start on response1
                me.startEdgeEvents(edgeEventsConfig);
            }
            findCloudletReply1 = response1.get();
            if(findCloudletReply1.getStatus().toString() == "FIND_FOUND"){
                Log.i(TAG,"EdgeEvent Got a Cloudlet!: " + findCloudletReply1.getStatus().toString() + "  FQDN: " +  findCloudletReply1.getFqdn());
            }else{
                Log.i(TAG, "EdgeEvent Cloudlet NOT Found!:  " + findCloudletReply1.getStatus().toString());
            }


            //assertSame("FindCloudlet1 did not succeed!", findCloudletReply1.getStatus(), FIND_FOUND);

            latch.await(GRPC_TIMEOUT_MS * 3, TimeUnit.MILLISECONDS);
            int expectedNum = 2;
            Log.i(TAG, "EdgeEvent :  " + responses.size());
            //assertEquals("Must get [" + expectedNum + "] responses back from server.", expectedNum, responses.size());
            // FIXME: For this test, the location is NON-MOCKED, a MOCK location provider is required to get sensible results here, but the location timer task is going.
            //assertEquals("Must get new FindCloudlet responses back from server.", 0, latencyNewCloudletResponses.size());

            for (AppClient.ServerEdgeEvent s : responses) {
                Log.i(TAG,"EdgeEvent Response Type: " + s.getEventType().toString());
                Log.i(TAG,"EdgeEvent Latancy Average:  " + s.getStatistics().getAvg());
            }

        } catch (DmeDnsException dde) {
            Log.e(TAG, Log.getStackTraceString(dde));
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
        } catch (InterruptedException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
        } //finally {
        //  if (me != null) {
        //      Log.i(TAG, "Closing matching engine...");
        //      me.close();
        //      Log.i(TAG, "MatchingEngine closed for test.");
        //  }
        //}
    }

    public void testDefaultConfigLatencyUpdate60s(){
        Log.i(TAG, "EdgeEvent Starting Default Config Test 60s Latency Update");
        Future<AppClient.FindCloudletReply> response1;
        AppClient.FindCloudletReply findCloudletReply1;
        me.setMatchingEngineLocationAllowed(true);
        me.setAllowSwitchIfNoSubscriberInfo(true);

        // This EdgeEventsConnection test requires an EdgeEvents enabled server.
        // me.setSSLEnabled(false);
        // me.setNetworkSwitchingEnabled(false);

        // attach an EdgeEventBus to receive the server response, if any (inline class):
        ConcurrentLinkedQueue<AppClient.ServerEdgeEvent> responses = new ConcurrentLinkedQueue<>();
        ConcurrentLinkedQueue<FindCloudletEvent> latencyNewCloudletResponses = new ConcurrentLinkedQueue<>();
        ConcurrentLinkedQueue<EdgeEventsConnection.EdgeEventsError> errors = new ConcurrentLinkedQueue<>();
        CountDownLatch latch = new CountDownLatch(1);
        class EventReceiver2 {
            @Subscribe
            void HandleFindCloudlet(FindCloudletEvent fce) {
                latencyNewCloudletResponses.add(fce);
                Log.i(TAG, "EdgeEvent Received a New FindCloudlet FQDN: " + fce.newCloudlet.getFqdn() + " Trigger: " + fce.trigger);
            }

            @Subscribe
            void HandleEdgeEvent(EdgeEventsConnection.EdgeEventsError error) {
                errors.add(error);
                if(error == EdgeEventsConnection.EdgeEventsError.eventTriggeredButCurrentCloudletIsBest){
                    Log.i(TAG,"EdgeEvent Received an Error:  " + error);
                }
            }
        }

        EventReceiver2 er = new EventReceiver2();
        me.getEdgeEventsBus().register(er);

        try {
            Location location = getTestLocation(); // Test needs this configurable in a sensible way.
            registerClient(me);

            // Cannot use the older API if overriding.
            AppClient.FindCloudletRequest findCloudletRequest = me.createDefaultFindCloudletRequest(context, location)
                    .setCarrierName(findCloudletCarrierOverride)
                    .build();

            EdgeEventsConfig edgeEventsConfig = me.createDefaultEdgeEventsConfig(
                    60,
                    0,
                    300, 0);

            Log.i(TAG, "EdgeEvent Config Settings: " + edgeEventsConfig);

            if (useHostOverride) {
                response1 = me.findCloudletFuture(findCloudletRequest, hostOverride, portOverride, GRPC_TIMEOUT_MS,
                        MatchingEngine.FindCloudletMode.PROXIMITY);
                // start on response1
                me.startEdgeEvents(edgeEventsConfig);
            } else {
                response1 = me.findCloudletFuture(findCloudletRequest, GRPC_TIMEOUT_MS, MatchingEngine.FindCloudletMode.PROXIMITY);
                // start on response1
                me.startEdgeEvents(edgeEventsConfig);
            }
            findCloudletReply1 = response1.get();
            if(findCloudletReply1.getStatus().toString() == "FIND_FOUND"){
                Log.i(TAG,"EdgeEvent Got a Cloudlet!: " + findCloudletReply1.getStatus().toString() + "  FQDN: " +  findCloudletReply1.getFqdn());
            }else{
                Log.i(TAG, "EdgeEvent Cloudlet NOT Found!:  " + findCloudletReply1.getStatus().toString());
            }


            //assertSame("FindCloudlet1 did not succeed!", findCloudletReply1.getStatus(), FIND_FOUND);

            latch.await(GRPC_TIMEOUT_MS * 6, TimeUnit.MILLISECONDS);
            int expectedNum = 2;
            Log.i(TAG, "EdgeEvent :  " + responses.size());
            //assertEquals("Must get [" + expectedNum + "] responses back from server.", expectedNum, responses.size());
            // FIXME: For this test, the location is NON-MOCKED, a MOCK location provider is required to get sensible results here, but the location timer task is going.
            //assertEquals("Must get new FindCloudlet responses back from server.", 0, latencyNewCloudletResponses.size());

            for (AppClient.ServerEdgeEvent s : responses) {
                Log.i(TAG,"EdgeEvent Response Type: " + s.getEventType().toString());
                Log.i(TAG,"EdgeEvent Latancy Average:  " + s.getStatistics().getAvg());
            }

        } catch (DmeDnsException dde) {
            Log.e(TAG, Log.getStackTraceString(dde));
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
        } catch (InterruptedException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
        } //finally {
        //  if (me != null) {
        //      Log.i(TAG, "Closing matching engine...");
        //      me.close();
        //      Log.i(TAG, "MatchingEngine closed for test.");
        //  }
        // }
    }

    public void testDefaultConfigLatencyUpdateNegitiveSeconds(){
        Log.i(TAG, "EdgeEvent Starting Default Config Test Neg Latency Update");
        Future<AppClient.FindCloudletReply> response1;
        AppClient.FindCloudletReply findCloudletReply1;
        me.setMatchingEngineLocationAllowed(true);
        me.setAllowSwitchIfNoSubscriberInfo(true);

        // This EdgeEventsConnection test requires an EdgeEvents enabled server.
        // me.setSSLEnabled(false);
        // me.setNetworkSwitchingEnabled(false);

        // attach an EdgeEventBus to receive the server response, if any (inline class):
        ConcurrentLinkedQueue<AppClient.ServerEdgeEvent> responses = new ConcurrentLinkedQueue<>();
        ConcurrentLinkedQueue<FindCloudletEvent> latencyNewCloudletResponses = new ConcurrentLinkedQueue<>();
        ConcurrentLinkedQueue<EdgeEventsConnection.EdgeEventsError> errors = new ConcurrentLinkedQueue<>();
        CountDownLatch latch = new CountDownLatch(1);
        class EventReceiver2 {
            @Subscribe
            void HandleFindCloudlet(FindCloudletEvent fce) {
                latencyNewCloudletResponses.add(fce);
                Log.i(TAG, "EdgeEvent Received a New FindCloudlet FQDN: " + fce.newCloudlet.getFqdn() + " Trigger: " + fce.trigger);
            }

            @Subscribe
            void HandleEdgeEvent(EdgeEventsConnection.EdgeEventsError error) {
                errors.add(error);
                if(error == EdgeEventsConnection.EdgeEventsError.eventTriggeredButCurrentCloudletIsBest){
                    Log.i(TAG,"EdgeEvent Received an Error:  " + error);
                }
            }
        }

        EventReceiver2 er = new EventReceiver2();
        me.getEdgeEventsBus().register(er);

        try {
            Location location = getTestLocation(); // Test needs this configurable in a sensible way.
            registerClient(me);

            // Cannot use the older API if overriding.
            AppClient.FindCloudletRequest findCloudletRequest = me.createDefaultFindCloudletRequest(context, location)
                    .setCarrierName(findCloudletCarrierOverride)
                    .build();

            Log.i(TAG,"EdgeEvent Setting Config");
            EdgeEventsConfig edgeEventsConfig = me.createDefaultEdgeEventsConfig(
                    -1,
                    0,
                    300, 0);

            Log.i(TAG, "EdgeEvent Config Settings: " + edgeEventsConfig);

            if (useHostOverride) {
                response1 = me.findCloudletFuture(findCloudletRequest, hostOverride, portOverride, GRPC_TIMEOUT_MS,
                        MatchingEngine.FindCloudletMode.PROXIMITY);
                // start on response1
                me.startEdgeEvents(edgeEventsConfig);
            } else {
                response1 = me.findCloudletFuture(findCloudletRequest, GRPC_TIMEOUT_MS, MatchingEngine.FindCloudletMode.PROXIMITY);
                // start on response1
                me.startEdgeEvents(edgeEventsConfig);
            }

            findCloudletReply1 = response1.get();

            if(findCloudletReply1.getStatus().toString() == "FIND_FOUND"){
                Log.i(TAG,"EdgeEvent Got a Cloudlet!: " + findCloudletReply1.getStatus().toString() + "  FQDN: " +  findCloudletReply1.getFqdn());
            }else{
                Log.i(TAG, "EdgeEvent Cloudlet NOT Found!:  " + findCloudletReply1.getStatus().toString());
            }


            //assertSame("FindCloudlet1 did not succeed!", findCloudletReply1.getStatus(), FIND_FOUND);

            latch.await(GRPC_TIMEOUT_MS * 3, TimeUnit.MILLISECONDS);
            int expectedNum = 2;
            Log.i(TAG, "EdgeEvent :  " + responses.size());
            //assertEquals("Must get [" + expectedNum + "] responses back from server.", expectedNum, responses.size());
            // FIXME: For this test, the location is NON-MOCKED, a MOCK location provider is required to get sensible results here, but the location timer task is going.
            //assertEquals("Must get new FindCloudlet responses back from server.", 0, latencyNewCloudletResponses.size());

            for (AppClient.ServerEdgeEvent s : responses) {
                Log.i(TAG,"EdgeEvent Response Type: " + s.getEventType().toString());
                Log.i(TAG,"EdgeEvent Latancy Average:  " + s.getStatistics().getAvg());
            }

        } catch (DmeDnsException dde) {
            Log.e(TAG, Log.getStackTraceString(dde));
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
        } catch (InterruptedException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
        } //finally {
        //  if (me != null) {
        //      Log.i(TAG, "Closing matching engine...");
        //      me.close();
        //      Log.i(TAG, "MatchingEngine closed for test.");
        //  }
        //}
    }

    public void testDefaultConfigLocationUpdate5s(){
        Log.i(TAG, "EdgeEvent Starting Default Config Test 5s Location Update");
        Future<AppClient.FindCloudletReply> response1;
        AppClient.FindCloudletReply findCloudletReply1;
        me.setMatchingEngineLocationAllowed(true);
        me.setAllowSwitchIfNoSubscriberInfo(true);

        // This EdgeEventsConnection test requires an EdgeEvents enabled server.
        // me.setSSLEnabled(false);
        // me.setNetworkSwitchingEnabled(false);

        // attach an EdgeEventBus to receive the server response, if any (inline class):
        ConcurrentLinkedQueue<AppClient.ServerEdgeEvent> responses = new ConcurrentLinkedQueue<>();
        ConcurrentLinkedQueue<FindCloudletEvent> latencyNewCloudletResponses = new ConcurrentLinkedQueue<>();
        ConcurrentLinkedQueue<EdgeEventsConnection.EdgeEventsError> errors = new ConcurrentLinkedQueue<>();
        CountDownLatch latch = new CountDownLatch(1);
        class EventReceiver2 {
            @Subscribe
            void HandleFindCloudlet(FindCloudletEvent fce) {
                latencyNewCloudletResponses.add(fce);
                Log.i(TAG, "EdgeEvent Received a New FindCloudlet FQDN: " + fce.newCloudlet.getFqdn() + " Trigger: " + fce.trigger);

            }

            @Subscribe
            void HandleEdgeEvent(EdgeEventsConnection.EdgeEventsError error) {
                errors.add(error);
                if(error == EdgeEventsConnection.EdgeEventsError.eventTriggeredButCurrentCloudletIsBest){
                    Log.i(TAG,"EdgeEvent Received an Error:  " + error);
                }
            }
        }

        EventReceiver2 er = new EventReceiver2();
        me.getEdgeEventsBus().register(er);

        try {
            Location location = getTestLocation(); // Test needs this configurable in a sensible way.
            registerClient(me);

            // Cannot use the older API if overriding.
            AppClient.FindCloudletRequest findCloudletRequest = me.createDefaultFindCloudletRequest(context, location)
                    .setCarrierName(findCloudletCarrierOverride)
                    .build();

            EdgeEventsConfig edgeEventsConfig = me.createDefaultEdgeEventsConfig(
                    0,
                    5,
                    300, 0);

            Log.i(TAG, "EdgeEvent Config Settings: " + edgeEventsConfig);

            if (useHostOverride) {
                response1 = me.findCloudletFuture(findCloudletRequest, hostOverride, portOverride, GRPC_TIMEOUT_MS,
                        MatchingEngine.FindCloudletMode.PROXIMITY);
                // start on response1
                me.startEdgeEvents(edgeEventsConfig);
            } else {
                response1 = me.findCloudletFuture(findCloudletRequest, GRPC_TIMEOUT_MS, MatchingEngine.FindCloudletMode.PROXIMITY);
                // start on response1
                me.startEdgeEvents(edgeEventsConfig);
            }
            findCloudletReply1 = response1.get();
            if(findCloudletReply1.getStatus().toString() == "FIND_FOUND"){
                Log.i(TAG,"EdgeEvent Got a Cloudlet!: " + findCloudletReply1.getStatus().toString() + "  FQDN: " +  findCloudletReply1.getFqdn());
            }else{
                Log.i(TAG, "EdgeEvent Cloudlet NOT Found!:  " + findCloudletReply1.getStatus().toString());
            }


            //assertSame("FindCloudlet1 did not succeed!", findCloudletReply1.getStatus(), FIND_FOUND);

            latch.await(GRPC_TIMEOUT_MS * 3, TimeUnit.MILLISECONDS);
            int expectedNum = 2;
            Log.i(TAG, "EdgeEvent :  " + responses.size());
            //assertEquals("Must get [" + expectedNum + "] responses back from server.", expectedNum, responses.size());
            // FIXME: For this test, the location is NON-MOCKED, a MOCK location provider is required to get sensible results here, but the location timer task is going.
            //assertEquals("Must get new FindCloudlet responses back from server.", 0, latencyNewCloudletResponses.size());

            for (AppClient.ServerEdgeEvent s : responses) {
                Log.i(TAG,"EdgeEvent Response Type: " + s.getEventType().toString());
                Log.i(TAG,"EdgeEvent Latancy Average:  " + s.getStatistics().getAvg());
            }

        } catch (DmeDnsException dde) {
            Log.e(TAG, Log.getStackTraceString(dde));
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
        } catch (InterruptedException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
        } //finally {
        //  if (me != null) {
        //      Log.i(TAG, "Closing matching engine...");
        //      me.close();
        //      Log.i(TAG, "MatchingEngine closed for test.");
        //  }
        // }
    }

    public void testDefaultConfigLocationUpdate60s(){
        Log.i(TAG, "EdgeEvent Starting Default Config Test 60s Location Update");
        Future<AppClient.FindCloudletReply> response1;
        AppClient.FindCloudletReply findCloudletReply1;
        me.setMatchingEngineLocationAllowed(true);
        me.setAllowSwitchIfNoSubscriberInfo(true);

        // This EdgeEventsConnection test requires an EdgeEvents enabled server.
        // me.setSSLEnabled(false);
        // me.setNetworkSwitchingEnabled(false);

        // attach an EdgeEventBus to receive the server response, if any (inline class):
        ConcurrentLinkedQueue<AppClient.ServerEdgeEvent> responses = new ConcurrentLinkedQueue<>();
        ConcurrentLinkedQueue<FindCloudletEvent> latencyNewCloudletResponses = new ConcurrentLinkedQueue<>();
        ConcurrentLinkedQueue<EdgeEventsConnection.EdgeEventsError> errors = new ConcurrentLinkedQueue<>();
        CountDownLatch latch = new CountDownLatch(1);
        class EventReceiver2 {
            @Subscribe
            void HandleFindCloudlet(FindCloudletEvent fce) {
                latencyNewCloudletResponses.add(fce);
                Log.i(TAG, "EdgeEvent Received a New FindCloudlet FQDN: " + fce.newCloudlet.getFqdn() + " Trigger: " + fce.trigger);
            }

            @Subscribe
            void HandleEdgeEvent(EdgeEventsConnection.EdgeEventsError error) {
                errors.add(error);
                if(error == EdgeEventsConnection.EdgeEventsError.eventTriggeredButCurrentCloudletIsBest){
                    Log.i(TAG,"EdgeEvent Received an Error:  " + error);
                }
            }
        }

        EventReceiver2 er = new EventReceiver2();
        me.getEdgeEventsBus().register(er);

        try {
            Location location = getTestLocation(); // Test needs this configurable in a sensible way.
            registerClient(me);

            // Cannot use the older API if overriding.
            AppClient.FindCloudletRequest findCloudletRequest = me.createDefaultFindCloudletRequest(context, location)
                    .setCarrierName(findCloudletCarrierOverride)
                    .build();

            EdgeEventsConfig edgeEventsConfig = me.createDefaultEdgeEventsConfig(
                    0,
                    60,
                    300, 0);

            Log.i(TAG, "EdgeEvent Config Settings: " + edgeEventsConfig);

            if (useHostOverride) {
                response1 = me.findCloudletFuture(findCloudletRequest, hostOverride, portOverride, GRPC_TIMEOUT_MS,
                        MatchingEngine.FindCloudletMode.PROXIMITY);
                // start on response1
                me.startEdgeEvents(edgeEventsConfig);
            } else {
                response1 = me.findCloudletFuture(findCloudletRequest, GRPC_TIMEOUT_MS, MatchingEngine.FindCloudletMode.PROXIMITY);
                // start on response1
                me.startEdgeEvents(edgeEventsConfig);
            }
            findCloudletReply1 = response1.get();
            if(findCloudletReply1.getStatus().toString() == "FIND_FOUND"){
                Log.i(TAG,"EdgeEvent Got a Cloudlet!: " + findCloudletReply1.getStatus().toString() + "  FQDN: " +  findCloudletReply1.getFqdn());
            }else{
                Log.i(TAG, "EdgeEvent Cloudlet NOT Found!:  " + findCloudletReply1.getStatus().toString());
            }


            //assertSame("FindCloudlet1 did not succeed!", findCloudletReply1.getStatus(), FIND_FOUND);

            latch.await(GRPC_TIMEOUT_MS * 3, TimeUnit.MILLISECONDS);
            int expectedNum = 2;
            Log.i(TAG, "EdgeEvent :  " + responses.size());
            //assertEquals("Must get [" + expectedNum + "] responses back from server.", expectedNum, responses.size());
            // FIXME: For this test, the location is NON-MOCKED, a MOCK location provider is required to get sensible results here, but the location timer task is going.
            //assertEquals("Must get new FindCloudlet responses back from server.", 0, latencyNewCloudletResponses.size());

            for (AppClient.ServerEdgeEvent s : responses) {
                Log.i(TAG,"EdgeEvent Response Type: " + s.getEventType().toString());
                Log.i(TAG,"EdgeEvent Latancy Average:  " + s.getStatistics().getAvg());
            }

        } catch (DmeDnsException dde) {
            Log.e(TAG, Log.getStackTraceString(dde));
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
        } catch (InterruptedException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
        } //finally {
        //  if (me != null) {
        //      Log.i(TAG, "Closing matching engine...");
        //      me.close();
        //      Log.i(TAG, "MatchingEngine closed for test.");
        //  }
        // }
    }

    public void testDefaultConfigLocationUpdateNegitiveSeconds(){
        Log.i(TAG, "EdgeEvent Starting Default Config Test Neg Location Update");
        Future<AppClient.FindCloudletReply> response1;
        AppClient.FindCloudletReply findCloudletReply1;
        me.setMatchingEngineLocationAllowed(true);
        me.setAllowSwitchIfNoSubscriberInfo(true);

        // This EdgeEventsConnection test requires an EdgeEvents enabled server.
        // me.setSSLEnabled(false);
        // me.setNetworkSwitchingEnabled(false);

        // attach an EdgeEventBus to receive the server response, if any (inline class):
        ConcurrentLinkedQueue<AppClient.ServerEdgeEvent> responses = new ConcurrentLinkedQueue<>();
        ConcurrentLinkedQueue<FindCloudletEvent> latencyNewCloudletResponses = new ConcurrentLinkedQueue<>();
        ConcurrentLinkedQueue<EdgeEventsConnection.EdgeEventsError> errors = new ConcurrentLinkedQueue<>();
        CountDownLatch latch = new CountDownLatch(1);
        class EventReceiver2 {
            @Subscribe
            void HandleFindCloudlet(FindCloudletEvent fce) {
                latencyNewCloudletResponses.add(fce);
                Log.i(TAG, "EdgeEvent Received a New FindCloudlet FQDN: " + fce.newCloudlet.getFqdn() + " Trigger: " + fce.trigger);
            }

            @Subscribe
            void HandleEdgeEvent(EdgeEventsConnection.EdgeEventsError error) {
                errors.add(error);
                if(error == EdgeEventsConnection.EdgeEventsError.eventTriggeredButCurrentCloudletIsBest){
                    Log.i(TAG,"EdgeEvent Received an Error:  " + error);
                }
            }
        }

        EventReceiver2 er = new EventReceiver2();
        me.getEdgeEventsBus().register(er);

        try {
            Location location = getTestLocation(); // Test needs this configurable in a sensible way.
            registerClient(me);

            // Cannot use the older API if overriding.
            AppClient.FindCloudletRequest findCloudletRequest = me.createDefaultFindCloudletRequest(context, location)
                    .setCarrierName(findCloudletCarrierOverride)
                    .build();

            EdgeEventsConfig edgeEventsConfig = me.createDefaultEdgeEventsConfig(
                    0,
                    -1,
                    300, 0);

            Log.i(TAG, "EdgeEvent Config Settings: " + edgeEventsConfig);

            if (useHostOverride) {
                response1 = me.findCloudletFuture(findCloudletRequest, hostOverride, portOverride, GRPC_TIMEOUT_MS,
                        MatchingEngine.FindCloudletMode.PROXIMITY);
                // start on response1
                me.startEdgeEvents(edgeEventsConfig);
            } else {
                response1 = me.findCloudletFuture(findCloudletRequest, GRPC_TIMEOUT_MS, MatchingEngine.FindCloudletMode.PROXIMITY);
                // start on response1
                me.startEdgeEvents(edgeEventsConfig);
            }
            findCloudletReply1 = response1.get();
            if(findCloudletReply1.getStatus().toString() == "FIND_FOUND"){
                Log.i(TAG,"EdgeEvent Got a Cloudlet!: " + findCloudletReply1.getStatus().toString() + "  FQDN: " +  findCloudletReply1.getFqdn());
            }else{
                Log.i(TAG, "EdgeEvent Cloudlet NOT Found!:  " + findCloudletReply1.getStatus().toString());
            }


            //assertSame("FindCloudlet1 did not succeed!", findCloudletReply1.getStatus(), FIND_FOUND);

            latch.await(GRPC_TIMEOUT_MS * 3, TimeUnit.MILLISECONDS);
            int expectedNum = 2;
            Log.i(TAG, "EdgeEvent :  " + responses.size());
            //assertEquals("Must get [" + expectedNum + "] responses back from server.", expectedNum, responses.size());
            // FIXME: For this test, the location is NON-MOCKED, a MOCK location provider is required to get sensible results here, but the location timer task is going.
            //assertEquals("Must get new FindCloudlet responses back from server.", 0, latencyNewCloudletResponses.size());

            for (AppClient.ServerEdgeEvent s : responses) {
                Log.i(TAG,"EdgeEvent Response Type: " + s.getEventType().toString());
                Log.i(TAG,"EdgeEvent Latancy Average:  " + s.getStatistics().getAvg());
            }

        } catch (DmeDnsException dde) {
            Log.e(TAG, Log.getStackTraceString(dde));
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
        } catch (InterruptedException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
        } //finally {
        //  if (me != null) {
        //      Log.i(TAG, "Closing matching engine...");
        //      me.close();
        //      Log.i(TAG, "MatchingEngine closed for test.");
        //  }
        //}
    }
    public void testDefaultConfigLatencyThreshold263(){
        Log.i(TAG, "EdgeEvent Starting Default Config Test Latency Threshold 263");
        Future<AppClient.FindCloudletReply> response1;
        AppClient.FindCloudletReply findCloudletReply1;
        me.setMatchingEngineLocationAllowed(true);
        me.setAllowSwitchIfNoSubscriberInfo(true);

        // This EdgeEventsConnection test requires an EdgeEvents enabled server.
        // me.setSSLEnabled(false);
        // me.setNetworkSwitchingEnabled(false);

        // attach an EdgeEventBus to receive the server response, if any (inline class):
        ConcurrentLinkedQueue<AppClient.ServerEdgeEvent> responses = new ConcurrentLinkedQueue<>();
        ConcurrentLinkedQueue<FindCloudletEvent> latencyNewCloudletResponses = new ConcurrentLinkedQueue<>();
        ConcurrentLinkedQueue<EdgeEventsConnection.EdgeEventsError> errors = new ConcurrentLinkedQueue<>();
        CountDownLatch latch = new CountDownLatch(1);
        class EventReceiver2 {
            @Subscribe
            void HandleFindCloudlet(FindCloudletEvent fce) {
                latencyNewCloudletResponses.add(fce);
                Log.i(TAG, "EdgeEvent Received a New FindCloudlet FQDN: " + fce.newCloudlet.getFqdn() + " Trigger: " + fce.trigger);
            }

            @Subscribe
            void HandleEdgeEvent(EdgeEventsConnection.EdgeEventsError error) {
                errors.add(error);
                if(error == EdgeEventsConnection.EdgeEventsError.eventTriggeredButCurrentCloudletIsBest){
                    Log.i(TAG,"EdgeEvent Received an Error:  " + error);
                }
            }
        }

        EventReceiver2 er = new EventReceiver2();
        me.getEdgeEventsBus().register(er);

        try {
            Location location = new Location("EngineCallTestLocation");
            location.setLatitude(53.00);
            location.setLongitude(10.00);
            //Location location = getTestLocation(); // Test needs this configurable in a sensible way.

            registerClient(me);

            // Cannot use the older API if overriding.
            AppClient.FindCloudletRequest findCloudletRequest = me.createDefaultFindCloudletRequest(context, location)
                    .setCarrierName(findCloudletCarrierOverride)
                    .build();

            EdgeEventsConfig edgeEventsConfig = me.createDefaultEdgeEventsConfig(
                    0,
                    0,
                    263, 0);

            Log.i(TAG, "EdgeEvent Config Settings: " + edgeEventsConfig);

            if (useHostOverride) {
                response1 = me.findCloudletFuture(findCloudletRequest, hostOverride, portOverride, GRPC_TIMEOUT_MS,
                        MatchingEngine.FindCloudletMode.PROXIMITY);
                // start on response1
                me.startEdgeEvents(edgeEventsConfig);
            } else {
                response1 = me.findCloudletFuture(findCloudletRequest, GRPC_TIMEOUT_MS, MatchingEngine.FindCloudletMode.PROXIMITY);
                // start on response1
                me.startEdgeEvents(edgeEventsConfig);
            }
            findCloudletReply1 = response1.get();
            if(findCloudletReply1.getStatus().toString() == "FIND_FOUND"){
                Log.i(TAG,"EdgeEvent Got a Cloudlet!: " + findCloudletReply1.getStatus().toString() + "  FQDN: " +  findCloudletReply1.getFqdn());
            }else{
                Log.i(TAG, "EdgeEvent Cloudlet NOT Found!:  " + findCloudletReply1.getStatus().toString());
            }


            //assertSame("FindCloudlet1 did not succeed!", findCloudletReply1.getStatus(), FIND_FOUND);

            latch.await(GRPC_TIMEOUT_MS * 3, TimeUnit.MILLISECONDS);
            int expectedNum = 2;
            Log.i(TAG, "EdgeEvent :  " + responses.size());
            //assertEquals("Must get [" + expectedNum + "] responses back from server.", expectedNum, responses.size());
            // FIXME: For this test, the location is NON-MOCKED, a MOCK location provider is required to get sensible results here, but the location timer task is going.
            //assertEquals("Must get new FindCloudlet responses back from server.", 0, latencyNewCloudletResponses.size());

            for (AppClient.ServerEdgeEvent s : responses) {
                Log.i(TAG,"EdgeEvent Response Type: " + s.getEventType().toString());
                Log.i(TAG,"EdgeEvent Latancy Average:  " + s.getStatistics().getAvg());
            }

        } catch (DmeDnsException dde) {
            Log.e(TAG, Log.getStackTraceString(dde));
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
        } catch (InterruptedException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
        }// finally {
        // if (me != null) {
        //     Log.i(TAG, "Closing matching engine...");
        //     me.close();
        //     Log.i(TAG, "MatchingEngine closed for test.");
        // }
        //}
    }

    public void testDefaultConfigLatencyThreshold183(){
        Log.i(TAG, "EdgeEvent Starting Default Config Test Latency Threshold 183 ");
        Future<AppClient.FindCloudletReply> response1;
        AppClient.FindCloudletReply findCloudletReply1;
        me.setMatchingEngineLocationAllowed(true);
        me.setAllowSwitchIfNoSubscriberInfo(true);


        // This EdgeEventsConnection test requires an EdgeEvents enabled server.
        // me.setSSLEnabled(false);
        // me.setNetworkSwitchingEnabled(false);

        // attach an EdgeEventBus to receive the server response, if any (inline class):
        ConcurrentLinkedQueue<AppClient.ServerEdgeEvent> responses = new ConcurrentLinkedQueue<>();
        ConcurrentLinkedQueue<FindCloudletEvent> latencyNewCloudletResponses = new ConcurrentLinkedQueue<>();
        ConcurrentLinkedQueue<EdgeEventsConnection.EdgeEventsError> errors = new ConcurrentLinkedQueue<>();
        CountDownLatch latch = new CountDownLatch(1);
        class EventReceiver2 {
            @Subscribe
            void HandleFindCloudlet(FindCloudletEvent fce) {
                latencyNewCloudletResponses.add(fce);
                Log.i(TAG, "EdgeEvent Received a New FindCloudlet FQDN: " + fce.newCloudlet.getFqdn() + " Trigger: " + fce.trigger);
            }

            @Subscribe
            void HandleEdgeEvent(EdgeEventsConnection.EdgeEventsError error) {
                errors.add(error);
                if(error == EdgeEventsConnection.EdgeEventsError.eventTriggeredButCurrentCloudletIsBest){
                    Log.i(TAG,"EdgeEvent Received an Error:  " + error);
                }
            }
        }

        EventReceiver2 er = new EventReceiver2();
        me.getEdgeEventsBus().register(er);

        try {
            Location location = new Location("EngineCallTestLocation");
            location.setLatitude(53.00);
            location.setLongitude(10.00);

            //Location location = getTestLocation(); // Test needs this configurable in a sensible way.
            registerClient(me);

            // Cannot use the older API if overriding.
            AppClient.FindCloudletRequest findCloudletRequest = me.createDefaultFindCloudletRequest(context, location)
                    .setCarrierName(findCloudletCarrierOverride)
                    .build();

            Log.i(TAG,"EdgeEvent Setting defaultConfig latencyThresholdTriggerMs with 200");
            EdgeEventsConfig edgeEventsConfig = me.createDefaultEdgeEventsConfig(
                    0,
                    0,
                    200, 0);

            Log.i(TAG, "EdgeEvent Config Settings: " + edgeEventsConfig);

            if (useHostOverride) {
                response1 = me.findCloudletFuture(findCloudletRequest, hostOverride, portOverride, GRPC_TIMEOUT_MS,
                        MatchingEngine.FindCloudletMode.PROXIMITY);
                Log.i(TAG,"EdgeEvent FindCloudlet Complete");
                // start on response1
                Log.i(TAG,"Starting EdgeEvent Connection");
                me.startEdgeEvents(edgeEventsConfig);
                Log.i(TAG,"EdgeEvent Connection Started");
            } else {
                response1 = me.findCloudletFuture(findCloudletRequest, GRPC_TIMEOUT_MS, MatchingEngine.FindCloudletMode.PROXIMITY);
                Log.i(TAG,"EdgeEvent FindCloudlet Complete");
                // start on response1
                Log.i(TAG,"Starting EdgeEvent Connection");
                me.startEdgeEvents(edgeEventsConfig);
                Log.i(TAG,"EdgeEvent Connection Started");
            }
            findCloudletReply1 = response1.get();
            if(findCloudletReply1.getStatus().toString() == "FIND_FOUND"){
                Log.i(TAG,"EdgeEvent Got a Cloudlet!: " + findCloudletReply1.getStatus().toString() + "  FQDN: " +  findCloudletReply1.getFqdn());
            }else{
                Log.i(TAG, "EdgeEvent Cloudlet NOT Found!:  " + findCloudletReply1.getStatus().toString());
            }


            //assertSame("FindCloudlet1 did not succeed!", findCloudletReply1.getStatus(), FIND_FOUND);

            latch.await(GRPC_TIMEOUT_MS * 3, TimeUnit.MILLISECONDS);
            int expectedNum = 2;
            Log.i(TAG, "EdgeEvent Response Size:  " + responses.size());
            //assertEquals("Must get [" + expectedNum + "] responses back from server.", expectedNum, responses.size());
            // FIXME: For this test, the location is NON-MOCKED, a MOCK location provider is required to get sensible results here, but the location timer task is going.
            //assertEquals("Must get new FindCloudlet responses back from server.", 0, latencyNewCloudletResponses.size());

            for (AppClient.ServerEdgeEvent s : responses) {
                Log.i(TAG,"EdgeEvent Response Type: " + s.getEventType().toString());
                Log.i(TAG,"EdgeEvent Latancy Average:  " + s.getStatistics().getAvg());
            }

        } catch (DmeDnsException dde) {
            Log.e(TAG, Log.getStackTraceString(dde));
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
        } catch (InterruptedException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
        }// finally {
        // if (me != null) {
        //     Log.i(TAG, "Closing matching engine...");
        //     me.close();
        //     Log.i(TAG, "MatchingEngine closed for test.");
        // }
        //}
    }

    public void testDefaultConfigLatencyThreshold143(){
        Log.i(TAG, "EdgeEvent Starting Default Config Test Latency Threshold 143 ");
        Future<AppClient.FindCloudletReply> response1;
        AppClient.FindCloudletReply findCloudletReply1;
        me.setMatchingEngineLocationAllowed(true);
        me.setAllowSwitchIfNoSubscriberInfo(true);

        // This EdgeEventsConnection test requires an EdgeEvents enabled server.
        // me.setSSLEnabled(false);
        // me.setNetworkSwitchingEnabled(false);

        // attach an EdgeEventBus to receive the server response, if any (inline class):
        ConcurrentLinkedQueue<AppClient.ServerEdgeEvent> responses = new ConcurrentLinkedQueue<>();
        ConcurrentLinkedQueue<FindCloudletEvent> latencyNewCloudletResponses = new ConcurrentLinkedQueue<>();
        ConcurrentLinkedQueue<EdgeEventsConnection.EdgeEventsError> errors = new ConcurrentLinkedQueue<>();
        CountDownLatch latch = new CountDownLatch(1);
        class EventReceiver2 {
            @Subscribe
            void HandleFindCloudlet(FindCloudletEvent fce) {
                latencyNewCloudletResponses.add(fce);
                Log.i(TAG, "EdgeEvent Received a New FindCloudlet FQDN: " + fce.newCloudlet.getFqdn() + " Trigger: " + fce.trigger);
            }

            @Subscribe
            void HandleEdgeEvent(EdgeEventsConnection.EdgeEventsError error) {
                errors.add(error);
                if(error == EdgeEventsConnection.EdgeEventsError.eventTriggeredButCurrentCloudletIsBest){
                    Log.i(TAG,"EdgeEvent Received an Error:  " + error);
                }
            }
        }

        EventReceiver2 er = new EventReceiver2();
        me.getEdgeEventsBus().register(er);

        try {
            Location location = getTestLocation(); // Test needs this configurable in a sensible way.
            registerClient(me);

            // Cannot use the older API if overriding.
            AppClient.FindCloudletRequest findCloudletRequest = me.createDefaultFindCloudletRequest(context, location)
                    .setCarrierName(findCloudletCarrierOverride)
                    .build();

            EdgeEventsConfig edgeEventsConfig = me.createDefaultEdgeEventsConfig(
                    0,
                    60,
                    143, 0);

            Log.i(TAG, "EdgeEvent Config Settings: " + edgeEventsConfig);

            if (useHostOverride) {
                response1 = me.findCloudletFuture(findCloudletRequest, hostOverride, portOverride, GRPC_TIMEOUT_MS,
                        MatchingEngine.FindCloudletMode.PROXIMITY);
                // start on response1
                me.startEdgeEvents(edgeEventsConfig);
            } else {
                response1 = me.findCloudletFuture(findCloudletRequest, GRPC_TIMEOUT_MS, MatchingEngine.FindCloudletMode.PROXIMITY);
                // start on response1
                me.startEdgeEvents(edgeEventsConfig);
            }
            findCloudletReply1 = response1.get();
            if(findCloudletReply1.getStatus().toString() == "FIND_FOUND"){
                Log.i(TAG,"EdgeEvent Got a Cloudlet!: " + findCloudletReply1.getStatus().toString() + "  FQDN: " +  findCloudletReply1.getFqdn());
            }else{
                Log.i(TAG, "EdgeEvent Cloudlet NOT Found!:  " + findCloudletReply1.getStatus().toString());
            }


            //assertSame("FindCloudlet1 did not succeed!", findCloudletReply1.getStatus(), FIND_FOUND);

            latch.await(GRPC_TIMEOUT_MS * 3, TimeUnit.MILLISECONDS);
            int expectedNum = 2;
            Log.i(TAG, "EdgeEvent :  " + responses.size());
            //assertEquals("Must get [" + expectedNum + "] responses back from server.", expectedNum, responses.size());
            // FIXME: For this test, the location is NON-MOCKED, a MOCK location provider is required to get sensible results here, but the location timer task is going.
            //assertEquals("Must get new FindCloudlet responses back from server.", 0, latencyNewCloudletResponses.size());

            for (AppClient.ServerEdgeEvent s : responses) {
                Log.i(TAG,"EdgeEvent Response Type: " + s.getEventType().toString());
                Log.i(TAG,"EdgeEvent Latancy Average:  " + s.getStatistics().getAvg());
            }

        } catch (DmeDnsException dde) {
            Log.e(TAG, Log.getStackTraceString(dde));
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
        } catch (InterruptedException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
        }// finally {
        // if (me != null) {
        //     Log.i(TAG, "Closing matching engine...");
        //     me.close();
        //     Log.i(TAG, "MatchingEngine closed for test.");
        // }
        //}
    }
    public void testDefaultConfigLatencyTestPort0(){
        Log.i(TAG, "EdgeEvent Starting Default Config Test Latency Test Port 0");
        Future<AppClient.FindCloudletReply> response1;
        AppClient.FindCloudletReply findCloudletReply1;
        me.setMatchingEngineLocationAllowed(true);
        me.setAllowSwitchIfNoSubscriberInfo(true);

        // This EdgeEventsConnection test requires an EdgeEvents enabled server.
        // me.setSSLEnabled(false);
        // me.setNetworkSwitchingEnabled(false);

        // attach an EdgeEventBus to receive the server response, if any (inline class):
        ConcurrentLinkedQueue<AppClient.ServerEdgeEvent> responses = new ConcurrentLinkedQueue<>();
        ConcurrentLinkedQueue<FindCloudletEvent> latencyNewCloudletResponses = new ConcurrentLinkedQueue<>();
        ConcurrentLinkedQueue<EdgeEventsConnection.EdgeEventsError> errors = new ConcurrentLinkedQueue<>();
        CountDownLatch latch = new CountDownLatch(1);
        class EventReceiver2 {
            @Subscribe
            void HandleFindCloudlet(FindCloudletEvent fce) {
                latencyNewCloudletResponses.add(fce);
                Log.i(TAG, "EdgeEvent Received a New FindCloudlet FQDN: " + fce.newCloudlet.getFqdn() + " Trigger: " + fce.trigger);
            }

            @Subscribe
            void HandleEdgeEvent(EdgeEventsConnection.EdgeEventsError error) {
                errors.add(error);
                if(error == EdgeEventsConnection.EdgeEventsError.eventTriggeredButCurrentCloudletIsBest){
                    Log.i(TAG,"EdgeEvent Received an Error:  " + error);
                }
            }

        }

        EventReceiver2 er = new EventReceiver2();
        me.getEdgeEventsBus().register(er);

        try {
            Location location = getTestLocation(); // Test needs this configurable in a sensible way.
            registerClient(me);

            // Cannot use the older API if overriding.
            AppClient.FindCloudletRequest findCloudletRequest = me.createDefaultFindCloudletRequest(context, location)
                    .setCarrierName(findCloudletCarrierOverride)
                    .build();

            EdgeEventsConfig edgeEventsConfig = me.createDefaultEdgeEventsConfig(
                    0,
                    0,
                    300, 0);

            Log.i(TAG, "EdgeEvent Config Settings: " + edgeEventsConfig);

            if (useHostOverride) {
                response1 = me.findCloudletFuture(findCloudletRequest, hostOverride, portOverride, GRPC_TIMEOUT_MS,
                        MatchingEngine.FindCloudletMode.PROXIMITY);
                // start on response1
                me.startEdgeEvents(edgeEventsConfig);
            } else {
                response1 = me.findCloudletFuture(findCloudletRequest, GRPC_TIMEOUT_MS, MatchingEngine.FindCloudletMode.PROXIMITY);
                // start on response1
                me.startEdgeEvents(edgeEventsConfig);
            }
            findCloudletReply1 = response1.get();
            if(findCloudletReply1.getStatus().toString() == "FIND_FOUND"){
                Log.i(TAG,"EdgeEvent Got a Cloudlet!: " + findCloudletReply1.getStatus().toString() + "  FQDN: " +  findCloudletReply1.getFqdn());
            }else{
                Log.i(TAG, "EdgeEvent Cloudlet NOT Found!:  " + findCloudletReply1.getStatus().toString());
            }


            //assertSame("FindCloudlet1 did not succeed!", findCloudletReply1.getStatus(), FIND_FOUND);

            latch.await(GRPC_TIMEOUT_MS * 3, TimeUnit.MILLISECONDS);
            int expectedNum = 2;
            Log.i(TAG, "EdgeEvent :  " + responses.size());
            //assertEquals("Must get [" + expectedNum + "] responses back from server.", expectedNum, responses.size());
            // FIXME: For this test, the location is NON-MOCKED, a MOCK location provider is required to get sensible results here, but the location timer task is going.
            //assertEquals("Must get new FindCloudlet responses back from server.", 0, latencyNewCloudletResponses.size());

            for (AppClient.ServerEdgeEvent s : responses) {
                Log.i(TAG,"EdgeEvent Response Type: " + s.getEventType().toString());
                Log.i(TAG,"EdgeEvent Latancy Average:  " + s.getStatistics().getAvg());
            }

        } catch (DmeDnsException dde) {
            Log.e(TAG, Log.getStackTraceString(dde));
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
        } catch (InterruptedException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
        }// finally {
        // if (me != null) {
        //     Log.i(TAG, "Closing matching engine...");
        //     me.close();
        //     Log.i(TAG, "MatchingEngine closed for test.");
        // }
        //}
    }


    public void testDefaultConfigLatencyTestPort2015(){
        Log.i(TAG, "EdgeEvent Starting Default Config Test Latency Test Port 2015");
        Future<AppClient.FindCloudletReply> response1;
        AppClient.FindCloudletReply findCloudletReply1;
        me.setMatchingEngineLocationAllowed(true);
        me.setAllowSwitchIfNoSubscriberInfo(true);

        // This EdgeEventsConnection test requires an EdgeEvents enabled server.
        // me.setSSLEnabled(false);
        // me.setNetworkSwitchingEnabled(false);

        // attach an EdgeEventBus to receive the server response, if any (inline class):
        ConcurrentLinkedQueue<AppClient.ServerEdgeEvent> responses = new ConcurrentLinkedQueue<>();
        ConcurrentLinkedQueue<FindCloudletEvent> latencyNewCloudletResponses = new ConcurrentLinkedQueue<>();
        ConcurrentLinkedQueue<EdgeEventsConnection.EdgeEventsError> errors = new ConcurrentLinkedQueue<>();
        CountDownLatch latch = new CountDownLatch(1);
        class EventReceiver2 {
            @Subscribe
            void HandleFindCloudlet(FindCloudletEvent fce) {
                latencyNewCloudletResponses.add(fce);
                Log.i(TAG, "EdgeEvent Received a New FindCloudlet FQDN: " + fce.newCloudlet.getFqdn() + " Trigger: " + fce.trigger);
            }

            @Subscribe
            void HandleEdgeEvent(EdgeEventsConnection.EdgeEventsError error) {
                errors.add(error);
                if(error == EdgeEventsConnection.EdgeEventsError.eventTriggeredButCurrentCloudletIsBest){
                    Log.i(TAG,"EdgeEvent Received an Error:  " + error);
                }
            }
        }

        EventReceiver2 er = new EventReceiver2();
        me.getEdgeEventsBus().register(er);

        try {
            Location location = getTestLocation(); // Test needs this configurable in a sensible way.
            registerClient(me);

            // Cannot use the older API if overriding.
            AppClient.FindCloudletRequest findCloudletRequest = me.createDefaultFindCloudletRequest(context, location)
                    .setCarrierName(findCloudletCarrierOverride)
                    .build();

            EdgeEventsConfig edgeEventsConfig = me.createDefaultEdgeEventsConfig(
                    0,
                    0,
                    300, 2015);

            Log.i(TAG, "EdgeEvent Config Settings: " + edgeEventsConfig);

            if (useHostOverride) {
                response1 = me.findCloudletFuture(findCloudletRequest, hostOverride, portOverride, GRPC_TIMEOUT_MS,
                        MatchingEngine.FindCloudletMode.PROXIMITY);
                // start on response1
                me.startEdgeEvents(edgeEventsConfig);
            } else {
                response1 = me.findCloudletFuture(findCloudletRequest, GRPC_TIMEOUT_MS, MatchingEngine.FindCloudletMode.PROXIMITY);
                // start on response1
                me.startEdgeEvents(edgeEventsConfig);
            }
            findCloudletReply1 = response1.get();
            if(findCloudletReply1.getStatus().toString() == "FIND_FOUND"){
                Log.i(TAG,"EdgeEvent Got a Cloudlet!: " + findCloudletReply1.getStatus().toString() + "  FQDN: " +  findCloudletReply1.getFqdn());
            }else{
                Log.i(TAG, "EdgeEvent Cloudlet NOT Found!:  " + findCloudletReply1.getStatus().toString());
            }


            //assertSame("FindCloudlet1 did not succeed!", findCloudletReply1.getStatus(), FIND_FOUND);

            latch.await(GRPC_TIMEOUT_MS * 3, TimeUnit.MILLISECONDS);
            int expectedNum = 2;
            Log.i(TAG, "EdgeEvent :  " + responses.size());
            //assertEquals("Must get [" + expectedNum + "] responses back from server.", expectedNum, responses.size());
            // FIXME: For this test, the location is NON-MOCKED, a MOCK location provider is required to get sensible results here, but the location timer task is going.
            //assertEquals("Must get new FindCloudlet responses back from server.", 0, latencyNewCloudletResponses.size());

            for (AppClient.ServerEdgeEvent s : responses) {
                Log.i(TAG,"EdgeEvent Response Type: " + s.getEventType().toString());
                Log.i(TAG,"EdgeEvent Latancy Average:  " + s.getStatistics().getAvg());
            }

        } catch (DmeDnsException dde) {
            Log.e(TAG, Log.getStackTraceString(dde));
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
        } catch (InterruptedException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
        }// finally {
        // if (me != null) {
        //     Log.i(TAG, "Closing matching engine...");
        //     me.close();
        //     Log.i(TAG, "MatchingEngine closed for test.");
        // }
        //}
    }

    public void testDefaultConfigLatencyTestPort2016(){
        Log.i(TAG, "EdgeEvent Starting Default Config Test Latency Test Port 2016");
        Future<AppClient.FindCloudletReply> response1;
        AppClient.FindCloudletReply findCloudletReply1;
        me.setMatchingEngineLocationAllowed(true);
        me.setAllowSwitchIfNoSubscriberInfo(true);

        // This EdgeEventsConnection test requires an EdgeEvents enabled server.
        // me.setSSLEnabled(false);
        // me.setNetworkSwitchingEnabled(false);

        // attach an EdgeEventBus to receive the server response, if any (inline class):
        ConcurrentLinkedQueue<AppClient.ServerEdgeEvent> responses = new ConcurrentLinkedQueue<>();
        ConcurrentLinkedQueue<FindCloudletEvent> latencyNewCloudletResponses = new ConcurrentLinkedQueue<>();
        ConcurrentLinkedQueue<EdgeEventsConnection.EdgeEventsError> errors = new ConcurrentLinkedQueue<>();
        CountDownLatch latch = new CountDownLatch(1);
        class EventReceiver2 {
            @Subscribe
            void HandleFindCloudlet(FindCloudletEvent fce) {
                latencyNewCloudletResponses.add(fce);
                Log.i(TAG, "EdgeEvent Received a New FindCloudlet FQDN: " + fce.newCloudlet.getFqdn() + " Trigger: " + fce.trigger);
            }

            @Subscribe
            void HandleEdgeEvent(EdgeEventsConnection.EdgeEventsError error) {
                errors.add(error);
                if(error == EdgeEventsConnection.EdgeEventsError.eventTriggeredButCurrentCloudletIsBest){
                    Log.i(TAG,"EdgeEvent Received an Error:  " + error);
                }
            }
        }

        EventReceiver2 er = new EventReceiver2();
        me.getEdgeEventsBus().register(er);

        try {
            Location location = getTestLocation(); // Test needs this configurable in a sensible way.
            registerClient(me);

            // Cannot use the older API if overriding.
            AppClient.FindCloudletRequest findCloudletRequest = me.createDefaultFindCloudletRequest(context, location)
                    .setCarrierName(findCloudletCarrierOverride)
                    .build();

            EdgeEventsConfig edgeEventsConfig = me.createDefaultEdgeEventsConfig(
                    0,
                    0,
                    300, 2016);

            Log.i(TAG, "EdgeEvent Config Settings: " + edgeEventsConfig);

            if (useHostOverride) {
                response1 = me.findCloudletFuture(findCloudletRequest, hostOverride, portOverride, GRPC_TIMEOUT_MS,
                        MatchingEngine.FindCloudletMode.PROXIMITY);
                // start on response1
                me.startEdgeEvents(edgeEventsConfig);
            } else {
                response1 = me.findCloudletFuture(findCloudletRequest, GRPC_TIMEOUT_MS, MatchingEngine.FindCloudletMode.PROXIMITY);
                // start on response1
                me.startEdgeEvents(edgeEventsConfig);
            }
            findCloudletReply1 = response1.get();
            if(findCloudletReply1.getStatus().toString() == "FIND_FOUND"){
                Log.i(TAG,"EdgeEvent Got a Cloudlet!: " + findCloudletReply1.getStatus().toString() + "  FQDN: " +  findCloudletReply1.getFqdn());
            }else{
                Log.i(TAG, "EdgeEvent Cloudlet NOT Found!:  " + findCloudletReply1.getStatus().toString());
            }


            //assertSame("FindCloudlet1 did not succeed!", findCloudletReply1.getStatus(), FIND_FOUND);

            latch.await(GRPC_TIMEOUT_MS * 3, TimeUnit.MILLISECONDS);
            int expectedNum = 2;
            Log.i(TAG, "EdgeEvent :  " + responses.size());
            //assertEquals("Must get [" + expectedNum + "] responses back from server.", expectedNum, responses.size());
            // FIXME: For this test, the location is NON-MOCKED, a MOCK location provider is required to get sensible results here, but the location timer task is going.
            //assertEquals("Must get new FindCloudlet responses back from server.", 0, latencyNewCloudletResponses.size());

            for (AppClient.ServerEdgeEvent s : responses) {
                Log.i(TAG,"EdgeEvent Response Type: " + s.getEventType().toString());
                Log.i(TAG,"EdgeEvent Latancy Average:  " + s.getStatistics().getAvg());
            }

        } catch (DmeDnsException dde) {
            Log.e(TAG, Log.getStackTraceString(dde));
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
        } catch (InterruptedException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
        }// finally {
        // if (me != null) {
        //     Log.i(TAG, "Closing matching engine...");
        //     me.close();
        //     Log.i(TAG, "MatchingEngine closed for test.");
        // }
        //}
    }

    public void testDefaultConfigLatencyTestPort3765(){
        Log.i(TAG, "EdgeEvent Starting Default Config Test Latency Test Port 3765");
        Future<AppClient.FindCloudletReply> response1;
        AppClient.FindCloudletReply findCloudletReply1;
        me.setMatchingEngineLocationAllowed(true);
        me.setAllowSwitchIfNoSubscriberInfo(true);

        // This EdgeEventsConnection test requires an EdgeEvents enabled server.
        // me.setSSLEnabled(false);
        // me.setNetworkSwitchingEnabled(false);

        // attach an EdgeEventBus to receive the server response, if any (inline class):
        ConcurrentLinkedQueue<AppClient.ServerEdgeEvent> responses = new ConcurrentLinkedQueue<>();
        ConcurrentLinkedQueue<FindCloudletEvent> latencyNewCloudletResponses = new ConcurrentLinkedQueue<>();
        ConcurrentLinkedQueue<EdgeEventsConnection.EdgeEventsError> errors = new ConcurrentLinkedQueue<>();
        CountDownLatch latch = new CountDownLatch(1);
        class EventReceiver2 {
            @Subscribe
            void HandleFindCloudlet(FindCloudletEvent fce) {
                latencyNewCloudletResponses.add(fce);
                Log.i(TAG, "EdgeEvent Received a New FindCloudlet FQDN: " + fce.newCloudlet.getFqdn() + " Trigger: " + fce.trigger);

            }

            @Subscribe
            void HandleEdgeEvent(EdgeEventsConnection.EdgeEventsError error) {
                errors.add(error);
                if(error == EdgeEventsConnection.EdgeEventsError.eventTriggeredButCurrentCloudletIsBest){
                    Log.i(TAG,"EdgeEvent Received an Error:  " + error);
                }
            }
        }

        EventReceiver2 er = new EventReceiver2();
        me.getEdgeEventsBus().register(er);

        try {
            Location location = getTestLocation(); // Test needs this configurable in a sensible way.
            registerClient(me);

            // Cannot use the older API if overriding.
            AppClient.FindCloudletRequest findCloudletRequest = me.createDefaultFindCloudletRequest(context, location)
                    .setCarrierName(findCloudletCarrierOverride)
                    .build();

            EdgeEventsConfig edgeEventsConfig = me.createDefaultEdgeEventsConfig(
                    0,
                    0,
                    300, 3765);

            Log.i(TAG, "EdgeEvent Config Settings: " + edgeEventsConfig);

            if (useHostOverride) {
                response1 = me.findCloudletFuture(findCloudletRequest, hostOverride, portOverride, GRPC_TIMEOUT_MS,
                        MatchingEngine.FindCloudletMode.PROXIMITY);
                // start on response1
                me.startEdgeEvents(edgeEventsConfig);
            } else {
                response1 = me.findCloudletFuture(findCloudletRequest, GRPC_TIMEOUT_MS, MatchingEngine.FindCloudletMode.PROXIMITY);
                // start on response1
                me.startEdgeEvents(edgeEventsConfig);
            }
            findCloudletReply1 = response1.get();
            if(findCloudletReply1.getStatus().toString() == "FIND_FOUND"){
                Log.i(TAG,"EdgeEvent Got a Cloudlet!: " + findCloudletReply1.getStatus().toString() + "  FQDN: " +  findCloudletReply1.getFqdn());
            }else{
                Log.i(TAG, "EdgeEvent Cloudlet NOT Found!:  " + findCloudletReply1.getStatus().toString());
            }


            //assertSame("FindCloudlet1 did not succeed!", findCloudletReply1.getStatus(), FIND_FOUND);

            latch.await(GRPC_TIMEOUT_MS * 3, TimeUnit.MILLISECONDS);
            int expectedNum = 2;
            Log.i(TAG, "EdgeEvent :  " + responses.size());
            //assertEquals("Must get [" + expectedNum + "] responses back from server.", expectedNum, responses.size());
            // FIXME: For this test, the location is NON-MOCKED, a MOCK location provider is required to get sensible results here, but the location timer task is going.
            //assertEquals("Must get new FindCloudlet responses back from server.", 0, latencyNewCloudletResponses.size());

            for (AppClient.ServerEdgeEvent s : responses) {
                Log.i(TAG,"EdgeEvent Response Type: " + s.getEventType().toString());
                Log.i(TAG,"EdgeEvent Latancy Average:  " + s.getStatistics().getAvg());
            }

        } catch (DmeDnsException dde) {
            Log.e(TAG, Log.getStackTraceString(dde));
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
        } catch (InterruptedException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
        }// finally {
        // if (me != null) {
        //     Log.i(TAG, "Closing matching engine...");
        //     me.close();
        //     Log.i(TAG, "MatchingEngine closed for test.");
        // }
        //}
    }

    public void testDefaultConfigLatencyTestPort8085(){
        Log.i(TAG, "EdgeEvent Starting Default Config Test Latency Test Port 8085");
        Future<AppClient.FindCloudletReply> response1;
        AppClient.FindCloudletReply findCloudletReply1;
        me.setMatchingEngineLocationAllowed(true);
        me.setAllowSwitchIfNoSubscriberInfo(true);

        // This EdgeEventsConnection test requires an EdgeEvents enabled server.
        // me.setSSLEnabled(false);
        // me.setNetworkSwitchingEnabled(false);

        // attach an EdgeEventBus to receive the server response, if any (inline class):
        ConcurrentLinkedQueue<AppClient.ServerEdgeEvent> responses = new ConcurrentLinkedQueue<>();
        ConcurrentLinkedQueue<FindCloudletEvent> latencyNewCloudletResponses = new ConcurrentLinkedQueue<>();
        ConcurrentLinkedQueue<EdgeEventsConnection.EdgeEventsError> errors = new ConcurrentLinkedQueue<>();
        CountDownLatch latch = new CountDownLatch(1);
        class EventReceiver2 {
            @Subscribe
            void HandleFindCloudlet(FindCloudletEvent fce) {
                latencyNewCloudletResponses.add(fce);
                Log.i(TAG, "EdgeEvent Received a New FindCloudlet FQDN: " + fce.newCloudlet.getFqdn() + " Trigger: " + fce.trigger);
            }

            @Subscribe
            void HandleEdgeEvent(EdgeEventsConnection.EdgeEventsError error) {
                errors.add(error);
                if(error == EdgeEventsConnection.EdgeEventsError.eventTriggeredButCurrentCloudletIsBest){
                    Log.i(TAG,"EdgeEvent Received an Error:  " + error);
                }
            }
        }

        EventReceiver2 er = new EventReceiver2();
        me.getEdgeEventsBus().register(er);

        try {
            Location location = getTestLocation(); // Test needs this configurable in a sensible way.
            registerClient(me);

            // Cannot use the older API if overriding.
            AppClient.FindCloudletRequest findCloudletRequest = me.createDefaultFindCloudletRequest(context, location)
                    .setCarrierName(findCloudletCarrierOverride)
                    .build();

            EdgeEventsConfig edgeEventsConfig = me.createDefaultEdgeEventsConfig(
                    0,
                    0,
                    300, 8085);

            Log.i(TAG, "EdgeEvent Config Settings: " + edgeEventsConfig);

            if (useHostOverride) {
                response1 = me.findCloudletFuture(findCloudletRequest, hostOverride, portOverride, GRPC_TIMEOUT_MS,
                        MatchingEngine.FindCloudletMode.PROXIMITY);
                // start on response1
                me.startEdgeEvents(edgeEventsConfig);
            } else {
                response1 = me.findCloudletFuture(findCloudletRequest, GRPC_TIMEOUT_MS, MatchingEngine.FindCloudletMode.PROXIMITY);
                // start on response1
                me.startEdgeEvents(edgeEventsConfig);
            }
            findCloudletReply1 = response1.get();
            if(findCloudletReply1.getStatus().toString() == "FIND_FOUND"){
                Log.i(TAG,"EdgeEvent Got a Cloudlet!: " + findCloudletReply1.getStatus().toString() + "  FQDN: " +  findCloudletReply1.getFqdn());
            }else{
                Log.i(TAG, "EdgeEvent Cloudlet NOT Found!:  " + findCloudletReply1.getStatus().toString());
            }


            //assertSame("FindCloudlet1 did not succeed!", findCloudletReply1.getStatus(), FIND_FOUND);

            latch.await(GRPC_TIMEOUT_MS * 3, TimeUnit.MILLISECONDS);
            int expectedNum = 2;
            Log.i(TAG, "EdgeEvent :  " + responses.size());
            //assertEquals("Must get [" + expectedNum + "] responses back from server.", expectedNum, responses.size());
            // FIXME: For this test, the location is NON-MOCKED, a MOCK location provider is required to get sensible results here, but the location timer task is going.
            //assertEquals("Must get new FindCloudlet responses back from server.", 0, latencyNewCloudletResponses.size());

            for (AppClient.ServerEdgeEvent s : responses) {
                Log.i(TAG,"EdgeEvent Response Type: " + s.getEventType().toString());
                Log.i(TAG,"EdgeEvent Latancy Average:  " + s.getStatistics().getAvg());
            }

        } catch (DmeDnsException dde) {
            Log.e(TAG, Log.getStackTraceString(dde));
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
        } catch (InterruptedException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
        }// finally {
        // if (me != null) {
        //     Log.i(TAG, "Closing matching engine...");
        //     me.close();
        //     Log.i(TAG, "MatchingEngine closed for test.");
        // }
        //}
    }

    public void testDefaultConfigLatencyTestPort2085(){
        Log.i(TAG, "EdgeEvent Starting Default Config Test Latency Test Port 2085");
        Future<AppClient.FindCloudletReply> response1;
        AppClient.FindCloudletReply findCloudletReply1;
        me.setMatchingEngineLocationAllowed(true);
        me.setAllowSwitchIfNoSubscriberInfo(true);

        // This EdgeEventsConnection test requires an EdgeEvents enabled server.
        // me.setSSLEnabled(false);
        // me.setNetworkSwitchingEnabled(false);

        // attach an EdgeEventBus to receive the server response, if any (inline class):
        ConcurrentLinkedQueue<AppClient.ServerEdgeEvent> responses = new ConcurrentLinkedQueue<>();
        ConcurrentLinkedQueue<FindCloudletEvent> latencyNewCloudletResponses = new ConcurrentLinkedQueue<>();
        ConcurrentLinkedQueue<EdgeEventsConnection.EdgeEventsError> errors = new ConcurrentLinkedQueue<>();
        CountDownLatch latch = new CountDownLatch(1);
        class EventReceiver2 {
            @Subscribe
            void HandleFindCloudlet(FindCloudletEvent fce) {
                latencyNewCloudletResponses.add(fce);
                Log.i(TAG, "EdgeEvent Received a New FindCloudlet FQDN: " + fce.newCloudlet.getFqdn() + " Trigger: " + fce.trigger);
            }

            @Subscribe
            void HandleEdgeEvent(EdgeEventsConnection.EdgeEventsError error) {
                errors.add(error);
                if(error == EdgeEventsConnection.EdgeEventsError.eventTriggeredButCurrentCloudletIsBest){
                    Log.i(TAG,"EdgeEvent Received an Error:  " + error);
                }
            }
        }

        EventReceiver2 er = new EventReceiver2();
        me.getEdgeEventsBus().register(er);

        try {
            Location location = getTestLocation(); // Test needs this configurable in a sensible way.
            registerClient(me);

            // Cannot use the older API if overriding.
            AppClient.FindCloudletRequest findCloudletRequest = me.createDefaultFindCloudletRequest(context, location)
                    .setCarrierName(findCloudletCarrierOverride)
                    .build();

            EdgeEventsConfig edgeEventsConfig = me.createDefaultEdgeEventsConfig(
                    0,
                    0,
                    300, 2085);

            Log.i(TAG, "EdgeEvent Config Settings: " + edgeEventsConfig);

            if (useHostOverride) {
                response1 = me.findCloudletFuture(findCloudletRequest, hostOverride, portOverride, GRPC_TIMEOUT_MS,
                        MatchingEngine.FindCloudletMode.PROXIMITY);
                // start on response1
                me.startEdgeEvents(edgeEventsConfig);
            } else {
                response1 = me.findCloudletFuture(findCloudletRequest, GRPC_TIMEOUT_MS, MatchingEngine.FindCloudletMode.PROXIMITY);
                // start on response1
                me.startEdgeEvents(edgeEventsConfig);
            }
            findCloudletReply1 = response1.get();
            if(findCloudletReply1.getStatus().toString() == "FIND_FOUND"){
                Log.i(TAG,"EdgeEvent Got a Cloudlet!: " + findCloudletReply1.getStatus().toString() + "  FQDN: " +  findCloudletReply1.getFqdn());
            }else{
                Log.i(TAG, "EdgeEvent Cloudlet NOT Found!:  " + findCloudletReply1.getStatus().toString());
            }


            //assertSame("FindCloudlet1 did not succeed!", findCloudletReply1.getStatus(), FIND_FOUND);

            latch.await(GRPC_TIMEOUT_MS * 3, TimeUnit.MILLISECONDS);
            int expectedNum = 2;
            Log.i(TAG, "EdgeEvent :  " + responses.size());
            //assertEquals("Must get [" + expectedNum + "] responses back from server.", expectedNum, responses.size());
            // FIXME: For this test, the location is NON-MOCKED, a MOCK location provider is required to get sensible results here, but the location timer task is going.
            //assertEquals("Must get new FindCloudlet responses back from server.", 0, latencyNewCloudletResponses.size());

            for (AppClient.ServerEdgeEvent s : responses) {
                Log.i(TAG,"EdgeEvent Response Type: " + s.getEventType().toString());
                Log.i(TAG,"EdgeEvent Latancy Average:  " + s.getStatistics().getAvg());
            }

        } catch (DmeDnsException dde) {
            Log.e(TAG, Log.getStackTraceString(dde));
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
        } catch (InterruptedException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
        }// finally {
        // if (me != null) {
        //     Log.i(TAG, "Closing matching engine...");
        //     me.close();
        //     Log.i(TAG, "MatchingEngine closed for test.");
        // }
        //}
    }

    public void testDefaultConfigLatencyToHighTrigger() {
        //MatchingEngine me = new MatchingEngine(context);
        Log.i(TAG, "EdgeEvent Starting Latency Too High Test");
        Future<AppClient.FindCloudletReply> response1;
        AppClient.FindCloudletReply findCloudletReply1;
        me.setMatchingEngineLocationAllowed(true);
        me.setAllowSwitchIfNoSubscriberInfo(true);


        ConcurrentLinkedQueue<AppClient.ServerEdgeEvent> responses = new ConcurrentLinkedQueue<>();
        ConcurrentLinkedQueue<FindCloudletEvent> latencyNewCloudletResponses = new ConcurrentLinkedQueue<>();
        ConcurrentLinkedQueue<EdgeEventsConnection.EdgeEventsError> errors = new ConcurrentLinkedQueue<>();
        CountDownLatch latch = new CountDownLatch(1);
        class EventReceiver2 {
            @Subscribe
            void HandleFindCloudlet(FindCloudletEvent fce) {
                latencyNewCloudletResponses.add(fce);
                Log.i(TAG, "EdgeEvent Received a New FindCloudlet FQDN: " + fce.newCloudlet.getFqdn() + " Trigger: " + fce.trigger);
            }

            @Subscribe
            void HandleEdgeEvent(EdgeEventsConnection.EdgeEventsError error) {
                errors.add(error);
                if(error == EdgeEventsConnection.EdgeEventsError.eventTriggeredButCurrentCloudletIsBest){
                    Log.i(TAG,"EdgeEvent Received an Error:  " + error);
                }
            }
        }

        EventReceiver2 er = new EventReceiver2();
        me.getEdgeEventsBus().register(er);
        try {
            Location location = getTestLocation(); // Test needs this configurable in a sensible way.
            registerClient(me);

            // Cannot use the older API if overriding.
            AppClient.FindCloudletRequest findCloudletRequest = me.createDefaultFindCloudletRequest(context, location)
                    .setCarrierName(findCloudletCarrierOverride)
                    .build();


            EdgeEventsConfig edgeEventsConfig = me.createDefaultEdgeEventsConfig(
                    5,
                    0,
                    250, 0);
            //edgeEventsConfig.latencyUpdateConfig = null;

            Log.i(TAG, "EdgeEvent Config Settings: " + edgeEventsConfig);

            if (useHostOverride) {
                response1 = me.findCloudletFuture(findCloudletRequest, hostOverride, portOverride, GRPC_TIMEOUT_MS,
                        MatchingEngine.FindCloudletMode.PROXIMITY);
                // start on response1
                me.startEdgeEventsFuture(edgeEventsConfig);
            } else {
                response1 = me.findCloudletFuture(findCloudletRequest, GRPC_TIMEOUT_MS, MatchingEngine.FindCloudletMode.PROXIMITY);
                // start on response1
                me.startEdgeEventsFuture(edgeEventsConfig);
            }

            findCloudletReply1 = response1.get();
            if(findCloudletReply1.getStatus().toString() == "FIND_FOUND"){
                Log.i(TAG,"EdgeEvent Got a Cloudlet!: " + findCloudletReply1.getStatus().toString() + "  FQDN: " +  findCloudletReply1.getFqdn());
            }else{
                Log.i(TAG, "EdgeEvent Cloudlet NOT Found!:  " + findCloudletReply1.getStatus().toString());
            }


            latch.await(GRPC_TIMEOUT_MS * 3, TimeUnit.MILLISECONDS);
            // This is actually unbounded, as the default is infinity latency Processed resposnes, should you wait long enough for that many to start arriving.
            long expectedNum = 1; // edgeEventsConfig.latencyUpdateConfig.maxNumberOfUpdates;
            Log.i(TAG, "EdgeEvent Response Size:  " + responses.size());

            //assertEquals("Must get new FindCloudlet responses back from server.", 0, latencyNewCloudletResponses.size());
            for (AppClient.ServerEdgeEvent s : responses) {
                Log.i(TAG,"EdgeEvent Response Type: " + s.getEventType().toString());
                Log.i(TAG,"EdgeEvent Latancy Average:  " + s.getStatistics().getAvg());
            }
        } catch (DmeDnsException dde) {
            Log.e(TAG, Log.getStackTraceString(dde));
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
        } catch (InterruptedException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
        }//finally {
        //   if (me != null) {
        //       Log.i(TAG, "Closing matching engine...");
        //       me.close();
        //       Log.i(TAG, "MatchingEngine closed for test.");
        //    }
        //}
    }

    public void testDefaultConfigAppHealthTrigger(){
        Log.i(TAG, "EdgeEvent Starting App Health Trigger Test");
        Future<AppClient.FindCloudletReply> response1;
        AppClient.FindCloudletReply findCloudletReply1;
        me.setMatchingEngineLocationAllowed(true);
        me.setAllowSwitchIfNoSubscriberInfo(true);

        // This EdgeEventsConnection test requires an EdgeEvents enabled server.
        // me.setSSLEnabled(false);
        // me.setNetworkSwitchingEnabled(false);

        // attach an EdgeEventBus to receive the server response, if any (inline class):
        ConcurrentLinkedQueue<AppClient.ServerEdgeEvent> responses = new ConcurrentLinkedQueue<>();
        ConcurrentLinkedQueue<FindCloudletEvent> latencyNewCloudletResponses = new ConcurrentLinkedQueue<>();
        ConcurrentLinkedQueue<EdgeEventsConnection.EdgeEventsError> errors = new ConcurrentLinkedQueue<>();
        CountDownLatch latch = new CountDownLatch(1);
        class EventReceiver2 {
            @Subscribe
            void HandleFindCloudlet(FindCloudletEvent fce) {
                latencyNewCloudletResponses.add(fce);
                Log.i(TAG, "EdgeEvent Received a New FindCloudlet FQDN: " + fce.newCloudlet.getFqdn() + " Trigger: " + fce.trigger);
            }

            @Subscribe
            void HandleEdgeEvent(EdgeEventsConnection.EdgeEventsError error) {
                errors.add(error);
                if(error == EdgeEventsConnection.EdgeEventsError.eventTriggeredButCurrentCloudletIsBest){
                    Log.i(TAG,"EdgeEvent Received an Error:  " + error);
                }
            }
        }

        EventReceiver2 er = new EventReceiver2();
        me.getEdgeEventsBus().register(er);

        try {
            Location location = getTestLocation(); // Test needs this configurable in a sensible way.
            registerClient(me);

            // Cannot use the older API if overriding.
            AppClient.FindCloudletRequest findCloudletRequest = me.createDefaultFindCloudletRequest(context, location)
                    .setCarrierName(findCloudletCarrierOverride)
                    .build();

            EdgeEventsConfig edgeEventsConfig = me.createDefaultEdgeEventsConfig(
                    0,
                    0,
                    160,0);
//            edgeEventsConfig.latencyTriggerTestMode = MatchingEngine.FindCloudletMode.PROXIMITY;

            Log.i(TAG, "EdgeEvent Config Settings: " + edgeEventsConfig);
            //Log.i(TAG,"EdgeEvent Config Settings: " + edgeEventsConfig.triggers.toString());

            if (useHostOverride) {
                response1 = me.findCloudletFuture(findCloudletRequest, hostOverride, portOverride, GRPC_TIMEOUT_MS,
                        MatchingEngine.FindCloudletMode.PROXIMITY);
                // start on response1
                me.startEdgeEvents(edgeEventsConfig);
            } else {
                response1 = me.findCloudletFuture(findCloudletRequest, GRPC_TIMEOUT_MS, MatchingEngine.FindCloudletMode.PROXIMITY);
                // start on response1
                me.startEdgeEvents(edgeEventsConfig);
            }
            findCloudletReply1 = response1.get();
            if(findCloudletReply1.getStatus().toString() == "FIND_FOUND"){
                Log.i(TAG,"EdgeEvent Got a Cloudlet!: " + findCloudletReply1.getStatus().toString() + "  FQDN: " +  findCloudletReply1.getFqdn());
            }else{
                Log.i(TAG, "EdgeEvent Cloudlet NOT Found!:  " + findCloudletReply1.getStatus().toString());
            }


            //assertSame("FindCloudlet1 did not succeed!", findCloudletReply1.getStatus(), FIND_FOUND);

            latch.await(GRPC_TIMEOUT_MS * 6, TimeUnit.MILLISECONDS);
            int expectedNum = 2;
            Log.i(TAG, "EdgeEvent :  " + responses.size());

            for (AppClient.ServerEdgeEvent s : responses) {
                Log.i(TAG,"EdgeEvent Response Type: " + s.getEventType().toString());
                Log.i(TAG,"EdgeEvent Latancy Average:  " + s.getStatistics().getAvg());
            }

        } catch (DmeDnsException dde) {
            Log.e(TAG, Log.getStackTraceString(dde));
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
        } catch (InterruptedException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
        } //finally {
        //  if (me != null) {
        //      Log.i(TAG, "Closing matching engine...");
        //      me.close();
        //      Log.i(TAG, "MatchingEngine closed for test.");
        //  }
        //}
    }

    public void testDefaultConfigCloudletStateChangeTrigger(){
        Log.i(TAG, "EdgeEvent Starting Cloudlet Trigger Test");
        Future<AppClient.FindCloudletReply> response1;
        AppClient.FindCloudletReply findCloudletReply1;
        me.setMatchingEngineLocationAllowed(true);
        me.setAllowSwitchIfNoSubscriberInfo(true);

        // This EdgeEventsConnection test requires an EdgeEvents enabled server.
        // me.setSSLEnabled(false);
        // me.setNetworkSwitchingEnabled(false);

        // attach an EdgeEventBus to receive the server response, if any (inline class):
        ConcurrentLinkedQueue<AppClient.ServerEdgeEvent> responses = new ConcurrentLinkedQueue<>();
        ConcurrentLinkedQueue<FindCloudletEvent> latencyNewCloudletResponses = new ConcurrentLinkedQueue<>();
        ConcurrentLinkedQueue<EdgeEventsConnection.EdgeEventsError> errors = new ConcurrentLinkedQueue<>();
        CountDownLatch latch = new CountDownLatch(1);
        class EventReceiver2 {
            @Subscribe
            void HandleFindCloudlet(FindCloudletEvent fce) {
                latencyNewCloudletResponses.add(fce);
                Log.i(TAG, "EdgeEvent Received a New FindCloudlet FQDN: " + fce.newCloudlet.getFqdn() + " Trigger: " + fce.trigger);
            }

            @Subscribe
            void HandleEdgeEvent(EdgeEventsConnection.EdgeEventsError error) {
                errors.add(error);
                if(error == EdgeEventsConnection.EdgeEventsError.eventTriggeredButCurrentCloudletIsBest){
                    Log.i(TAG,"EdgeEvent Received an Error:  " + error);
                }
            }
        }

        EventReceiver2 er = new EventReceiver2();
        me.getEdgeEventsBus().register(er);

        try {
            Location location = getTestLocation(); // Test needs this configurable in a sensible way.
            registerClient(me);

            // Cannot use the older API if overriding.
            AppClient.FindCloudletRequest findCloudletRequest = me.createDefaultFindCloudletRequest(context, location)
                    .setCarrierName(findCloudletCarrierOverride)
                    .build();

            EdgeEventsConfig edgeEventsConfig = me.createDefaultEdgeEventsConfig(
                    0,
                    0,
                    200,0);
            //edgeEventsConfig.latencyTriggerTestMode = MatchingEngine.FindCloudletMode.PROXIMITY;

            Log.i(TAG, "EdgeEvent Config Settings: " + edgeEventsConfig);
            //Log.i(TAG,"EdgeEvent Config Settings: " + edgeEventsConfig.triggers.toString());

            if (useHostOverride) {
                response1 = me.findCloudletFuture(findCloudletRequest, hostOverride, portOverride, GRPC_TIMEOUT_MS,
                        MatchingEngine.FindCloudletMode.PROXIMITY);
                // start on response1
                me.startEdgeEvents(edgeEventsConfig);
            } else {
                response1 = me.findCloudletFuture(findCloudletRequest, GRPC_TIMEOUT_MS, MatchingEngine.FindCloudletMode.PROXIMITY);
                // start on response1
                me.startEdgeEvents(edgeEventsConfig);
            }
            findCloudletReply1 = response1.get();
            if(findCloudletReply1.getStatus().toString() == "FIND_FOUND"){
                Log.i(TAG,"EdgeEvent Got a Cloudlet!: " + findCloudletReply1.getStatus().toString() + "  FQDN: " +  findCloudletReply1.getFqdn());
            }else{
                Log.i(TAG, "EdgeEvent Cloudlet NOT Found!:  " + findCloudletReply1.getStatus().toString());
            }


            //assertSame("FindCloudlet1 did not succeed!", findCloudletReply1.getStatus(), FIND_FOUND);

            latch.await(GRPC_TIMEOUT_MS * 3, TimeUnit.MILLISECONDS);
            int expectedNum = 2;
            Log.i(TAG, "EdgeEvent :  " + responses.size());
            //assertEquals("Must get [" + expectedNum + "] responses back from server.", expectedNum, responses.size());
            // FIXME: For this test, the location is NON-MOCKED, a MOCK location provider is required to get sensible results here, but the location timer task is going.
            //assertEquals("Must get new FindCloudlet responses back from server.", 0, latencyNewCloudletResponses.size());

            for (AppClient.ServerEdgeEvent s : responses) {
                Log.i(TAG,"EdgeEvent Response Type: " + s.getEventType().toString());
                Log.i(TAG,"EdgeEvent Latancy Average:  " + s.getStatistics().getAvg());
            }

        } catch (DmeDnsException dde) {
            Log.e(TAG, Log.getStackTraceString(dde));
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
        } catch (InterruptedException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
        } //finally {
        //  if (me != null) {
        //      Log.i(TAG, "Closing matching engine...");
        //      me.close();
        //      Log.i(TAG, "MatchingEngine closed for test.");
        //  }
        //}
    }

    public void testDefaultConfigCloudletMaintenanceTrigger(){
        Log.i(TAG, "EdgeEvent Starting Cloudlet Maintenance Trigger Test");
        Future<AppClient.FindCloudletReply> response1;
        AppClient.FindCloudletReply findCloudletReply1;
        me.setMatchingEngineLocationAllowed(true);
        me.setAllowSwitchIfNoSubscriberInfo(true);

        // This EdgeEventsConnection test requires an EdgeEvents enabled server.
        // me.setSSLEnabled(false);
        // me.setNetworkSwitchingEnabled(false);

        // attach an EdgeEventBus to receive the server response, if any (inline class):
        ConcurrentLinkedQueue<AppClient.ServerEdgeEvent> responses = new ConcurrentLinkedQueue<>();
        ConcurrentLinkedQueue<FindCloudletEvent> latencyNewCloudletResponses = new ConcurrentLinkedQueue<>();
        ConcurrentLinkedQueue<EdgeEventsConnection.EdgeEventsError> errors = new ConcurrentLinkedQueue<>();
        CountDownLatch latch = new CountDownLatch(1);
        class EventReceiver2 {
            @Subscribe
            void HandleFindCloudlet(FindCloudletEvent fce) {
                latencyNewCloudletResponses.add(fce);
                Log.i(TAG, "EdgeEvent Received a New FindCloudlet FQDN: " + fce.newCloudlet.getFqdn() + " Trigger: " + fce.trigger);
            }

            @Subscribe
            void HandleEdgeEvent(EdgeEventsConnection.EdgeEventsError error) {
                errors.add(error);
                if(error == EdgeEventsConnection.EdgeEventsError.eventTriggeredButCurrentCloudletIsBest){
                    Log.i(TAG,"EdgeEvent Received an Error:  " + error);
                }
            }
        }

        EventReceiver2 er = new EventReceiver2();
        me.getEdgeEventsBus().register(er);

        try {
            Location location = getTestLocation(); // Test needs this configurable in a sensible way.
            registerClient(me);

            // Cannot use the older API if overriding.
            AppClient.FindCloudletRequest findCloudletRequest = me.createDefaultFindCloudletRequest(context, location)
                    .setCarrierName(findCloudletCarrierOverride)
                    .build();

            EdgeEventsConfig edgeEventsConfig = me.createDefaultEdgeEventsConfig(
                    0,
                    0,
                    200,0);
//            edgeEventsConfig.latencyTriggerTestMode = MatchingEngine.FindCloudletMode.PROXIMITY;

            Log.i(TAG, "EdgeEvent Config Settings: " + edgeEventsConfig);
            //Log.i(TAG,"EdgeEvent Config Settings: " + edgeEventsConfig.triggers.toString());

            if (useHostOverride) {
                response1 = me.findCloudletFuture(findCloudletRequest, hostOverride, portOverride, GRPC_TIMEOUT_MS,
                        MatchingEngine.FindCloudletMode.PROXIMITY);
                // start on response1
                me.startEdgeEvents(edgeEventsConfig);
            } else {
                response1 = me.findCloudletFuture(findCloudletRequest, GRPC_TIMEOUT_MS, MatchingEngine.FindCloudletMode.PROXIMITY);
                // start on response1
                me.startEdgeEvents(edgeEventsConfig);
            }
            findCloudletReply1 = response1.get();
            if(findCloudletReply1.getStatus().toString() == "FIND_FOUND"){
                Log.i(TAG,"EdgeEvent Got a Cloudlet!: " + findCloudletReply1.getStatus().toString() + "  FQDN: " +  findCloudletReply1.getFqdn());
            }else{
                Log.i(TAG, "EdgeEvent Cloudlet NOT Found!:  " + findCloudletReply1.getStatus().toString());
            }


            //assertSame("FindCloudlet1 did not succeed!", findCloudletReply1.getStatus(), FIND_FOUND);

            latch.await(GRPC_TIMEOUT_MS * 3, TimeUnit.MILLISECONDS);
            int expectedNum = 2;
            Log.i(TAG, "EdgeEvent :  " + responses.size());
            //assertEquals("Must get [" + expectedNum + "] responses back from server.", expectedNum, responses.size());
            // FIXME: For this test, the location is NON-MOCKED, a MOCK location provider is required to get sensible results here, but the location timer task is going.
            //assertEquals("Must get new FindCloudlet responses back from server.", 0, latencyNewCloudletResponses.size());

            for (AppClient.ServerEdgeEvent s : responses) {
                Log.i(TAG,"EdgeEvent Response Type: " + s.getEventType().toString());
                Log.i(TAG,"EdgeEvent Latancy Average:  " + s.getStatistics().getAvg());
            }

        } catch (DmeDnsException dde) {
            Log.e(TAG, Log.getStackTraceString(dde));
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
        } catch (InterruptedException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
        } //finally {
        //  if (me != null) {
        //      Log.i(TAG, "Closing matching engine...");
        //      me.close();
        //      Log.i(TAG, "MatchingEngine closed for test.");
        //  }
        //}
    }

    public void testDefaultConfigAutoMigrationOff(){
        Log.i(TAG, "\n\nEdgeEvent Starting AutoMigrate Off Test");
        Future<AppClient.FindCloudletReply> response1;
        AppClient.FindCloudletReply findCloudletReply1;
        me.setMatchingEngineLocationAllowed(true);
        me.setAllowSwitchIfNoSubscriberInfo(true);

        // This EdgeEventsConnection test requires an EdgeEvents enabled server.
        // me.setSSLEnabled(false);
        // me.setNetworkSwitchingEnabled(false);

        // attach an EdgeEventBus to receive the server response, if any (inline class):
        ConcurrentLinkedQueue<AppClient.ServerEdgeEvent> responses = new ConcurrentLinkedQueue<>();
        ConcurrentLinkedQueue<FindCloudletEvent> latencyNewCloudletResponses = new ConcurrentLinkedQueue<>();
        ConcurrentLinkedQueue<EdgeEventsConnection.EdgeEventsError> errors = new ConcurrentLinkedQueue<>();
        CountDownLatch latch = new CountDownLatch(1);
        class EventReceiver2 {
            @Subscribe
            void HandleFindCloudlet(FindCloudletEvent fce) {
                latencyNewCloudletResponses.add(fce);
                Log.i(TAG, "EdgeEvent Received a New FindCloudlet FQDN: " + fce.newCloudlet.getFqdn() + " Trigger: " + fce.trigger);
                try {
                    Log.i(TAG,"Restarting the EdgeEventConnection");
                    me.switchedToNextCloudlet();
                }catch(DmeDnsException dde){
                    Log.i(TAG,"EdgeEvent Caught an exception starting EdgeEventConnection:   " + dde);
                }
            }

            @Subscribe
            void HandleEdgeEvent(EdgeEventsConnection.EdgeEventsError error) {
                errors.add(error);
                if(error == EdgeEventsConnection.EdgeEventsError.eventTriggeredButCurrentCloudletIsBest){
                    Log.i(TAG,"EdgeEvent Received an Error:  " + error);
                }
            }
        }

        EventReceiver2 er = new EventReceiver2();
        me.getEdgeEventsBus().register(er);

        try {
            Location location = getTestLocation(); // Test needs this configurable in a sensible way.
            registerClient(me);

            // Cannot use the older API if overriding.
            AppClient.FindCloudletRequest findCloudletRequest = me.createDefaultFindCloudletRequest(context, location)
                    .setCarrierName(findCloudletCarrierOverride)
                    .build();

            EdgeEventsConfig edgeEventsConfig = me.createDefaultEdgeEventsConfig(
                    15,
                    5,
                    50,0);
//            edgeEventsConfig.latencyTriggerTestMode = MatchingEngine.FindCloudletMode.PROXIMITY;
            me.setEnableEdgeEvents(true);

            me.setAutoMigrateEdgeEventsConnection(false);

            Log.i(TAG, "EdgeEvent Config Settings: " + edgeEventsConfig);
            //Log.i(TAG,"EdgeEvent Config Settings: " + edgeEventsConfig.triggers.toString());

            if (useHostOverride) {
                response1 = me.findCloudletFuture(findCloudletRequest, hostOverride, portOverride, GRPC_TIMEOUT_MS,
                        MatchingEngine.FindCloudletMode.PROXIMITY);
                // start on response1
                me.startEdgeEvents(edgeEventsConfig);
            } else {
                response1 = me.findCloudletFuture(findCloudletRequest, GRPC_TIMEOUT_MS, MatchingEngine.FindCloudletMode.PROXIMITY);
                // start on response1
                me.startEdgeEvents(edgeEventsConfig);
            }
            findCloudletReply1 = response1.get();
            if(findCloudletReply1.getStatus().toString() == "FIND_FOUND"){
                Log.i(TAG,"EdgeEvent Got a Cloudlet!: " + findCloudletReply1.getStatus().toString() + "  FQDN: " +  findCloudletReply1.getFqdn());
            }else{
                Log.i(TAG, "EdgeEvent Cloudlet NOT Found!:  " + findCloudletReply1.getStatus().toString());
            }


            //assertSame("FindCloudlet1 did not succeed!", findCloudletReply1.getStatus(), FIND_FOUND);

            latch.await(GRPC_TIMEOUT_MS * 3, TimeUnit.MILLISECONDS);
            int expectedNum = 2;
            Log.i(TAG, "EdgeEvent :  " + responses.size());
            // FIXME: For this test, the location is NON-MOCKED, a MOCK location provider is required to get sensible results here, but the location timer task is going.

            for (AppClient.ServerEdgeEvent s : responses) {
                Log.i(TAG,"EdgeEvent Response Type: " + s.getEventType().toString());
                Log.i(TAG,"EdgeEvent Latancy Average:  " + s.getStatistics().getAvg());
            }
            Log.i(TAG,"EdgeEvent Finished AutoMigrate Off Test\n\n");

        } catch (DmeDnsException dde) {
            Log.e(TAG, Log.getStackTraceString(dde));
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
        } catch (InterruptedException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
        } //finally {
        //  if (me != null) {
        //      Log.i(TAG, "Closing matching engine...");
        //      me.close();
        //      Log.i(TAG, "MatchingEngine closed for test.");
        //  }
        //}
    }
}
