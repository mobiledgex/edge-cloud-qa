/**
 * Copyright 2018-2020 MobiledgeX, Inc. All rights and licenses reserved.
 * MobiledgeX, Inc. 156 2nd Street #408, San Francisco, CA 94105
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.mobiledgex.melvalidator;

import android.app.UiAutomation;
import android.content.Context;
import android.location.Location;
import android.os.Build;
import android.os.Looper;
import android.util.Log;
import android.util.Pair;

import androidx.test.ext.junit.runners.AndroidJUnit4;
import androidx.test.platform.app.InstrumentationRegistry;

import com.google.android.gms.location.FusedLocationProviderClient;
import com.mobiledgex.matchingengine.DmeDnsException;
import com.mobiledgex.matchingengine.MatchingEngine;
import com.mobiledgex.mel.MelMessaging;

import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.List;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Future;

import distributed_match_engine.AppClient;
import distributed_match_engine.Appcommon;
import io.grpc.Status;
import io.grpc.StatusRuntimeException;

import static junit.framework.TestCase.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

/*
  these tests are for when wifi is connected (mel disabled) for:
  1) without SIM card
  2) with SIM card

  these tests go to wifi.dme.mobiledgex.net which is mapped to mexdemo-eu.dme.mobiledgex.net

  edgectl controller --addr mexdemo-eu.ctrl.mobiledgex.net:55001 --tls ~/mex-ca.crt CreateCloudlet cloudlet=cerustfake cloudlet-org=TELUS location.latitude=1 location.longitude=1 numdynamicips=254 platformtype=PlatformTypeFake
  edgectl controller --addr mexdemo-us.ctrl.mobiledgex.net:55001 --tls ~/mex-ca.crt CreateApp appname=automation-sdk-docker-app app-org=MobiledgeX appvers=1.0 imagepath=docker.mobiledgex.net/adevorg/images/server-ping-threaded:6.0 accessports=tcp:1234,udp:1,tcp:1-5:tls,tcp:8080 deployment=docker defaultflavor=x1.medium androidpackagename=com.mobiledgex.sdkvalidator officialfqdn=stackoverflow.com
  edgectl controller --addr mexdemo-eu.ctrl.mobiledgex.net:55001 --tls ~/mex-ca.crt CreateAppInst appname=automation-sdk-docker-app app-org=MobiledgeX appvers=1.0 cloudlet=cerustfake cloudlet-org=TELUS  cluster-org=MobiledgeX cluster=autoclustersdkdocker

 */
@RunWith(AndroidJUnit4.class)
public class FindCloudletMelDisabledWifiOnTest {
    public static final String TAG = "EngineCallTest";
    public static final long GRPC_TIMEOUT_MS = 21000;

    // production
    public static final String organizationName = "MobiledgeX-Samples";
    public static final String applicationName = "sdktest";
    public static final String appVersion = "9.0";

    // qa
    //public static final String organizationName = "MobiledgeX";
    //public static final String applicationName = "automation-sdk-porttest";
    //public static final String appVersion = "1.0";

    FusedLocationProviderClient fusedLocationClient;

    public static String hostOverride = "eu-qa.dme.mobiledgex.net";
    public static int portOverride = 50051;
    public static String findCloudletCarrierOverride = "GDDT"; // Allow "Any" if using "", but this likely breaks test cases.
    public static String foundCloudletFqdn1 = "fairview-main.gddt.mobiledgex.net";
    public static String foundCloudletFqdn = "edmonton-main.cerust.mobiledgex.net";
    //public static String foundCloudletFqdn = "automation-sdk-porttest10-udp.automationhawkinscloudlet.gddt.mobiledgex.net";
    //public static String foundCloudletFqdn1 = "automationbeaconcloudlet.gddt.mobiledgex.net";
    //public static String officialFqdn = "automation-sdk-porttest10-udp.automationhawkinscloudlet.gddt.mobiledgex.net";
    public boolean useHostOverride = false;

    // "useWifiOnly = true" also disables network switching, since the android default is WiFi.
    // Must be set to true if you are running tests without a SIM card.
    public boolean useWifiOnly = true;

    private int getCellId(Context context, MatchingEngine me) {
        int cellId = 0;
        List<Pair<String, Long>> cellIdList = me.retrieveCellId(context);
        if (cellIdList != null && cellIdList.size() > 0) {
            cellId = cellIdList.get(0).second.intValue();
        }
        return cellId;
    }

    private Location getTestLocation(Double latitude, Double longitude) {
        Location location = new Location("MobiledgeX_Test");
        if (latitude != null) {
            location.setLatitude(latitude);
        }
        if (longitude != null) {
            location.setLongitude(longitude);
        }
        return location;
    }

//    private Location getTestLocation(double latitude) {
//        Location location = new Location("MobiledgeX_Test");
//        location.setLatitude(latitude);
//        return location;
//    }

 //   private Location getTestLocation(double longitude) {
 //       Location location = new Location("MobiledgeX_Test");
 //       location.setLongitude(longitude);
 //       return location;
 //   }

    @Before
    public void LooperEnsure() {
        // SubscriberManager needs a thread. Start one:
        if (Looper.myLooper()==null)
            Looper.prepare();
    }

    @Before
    public void grantPermissions() {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            UiAutomation uiAutomation = InstrumentationRegistry.getInstrumentation().getUiAutomation();
            uiAutomation.grantRuntimePermission(
                    InstrumentationRegistry.getInstrumentation().getTargetContext().getPackageName(),
                    "android.permission.READ_PHONE_STATE");
            uiAutomation.grantRuntimePermission(
                    InstrumentationRegistry.getInstrumentation().getTargetContext().getPackageName(),
                    "android.permission.ACCESS_COARSE_LOCATION");
            uiAutomation.grantRuntimePermission(
                    InstrumentationRegistry.getInstrumentation().getTargetContext().getPackageName(),
                    "android.permission.ACCESS_FINE_LOCATION"
            );
        }
    }

    /**
     * Enable or Disable MockLocation.
     * @param context
     * @param enableMock
     * @return
     */
    public boolean enableMockLocation(Context context, boolean enableMock) {
        if (fusedLocationClient == null) {
            fusedLocationClient = new FusedLocationProviderClient(context);
        }
        if (enableMock == false) {
            fusedLocationClient.setMockMode(false);
            return false;
        } else {
            fusedLocationClient.setMockMode(true);
            return true;
        }
    }

    /**
     * Utility Func. Single point mock location, fills in some extra fields. Does not calculate speed, nor update interval.
     * @param context
     * @param location
     */
    public void setMockLocation(Context context, Location location) throws InterruptedException {
        if (fusedLocationClient == null) {
            fusedLocationClient = new FusedLocationProviderClient(context);
        }

        location.setTime(System.currentTimeMillis());
        location.setElapsedRealtimeNanos(1000);
        location.setAccuracy(3f);
        fusedLocationClient.setMockLocation(location);
        synchronized (location) {
            try {
                location.wait(1500); // Give Mock a bit of time to take effect.
            } catch (InterruptedException ie) {
                throw ie;
            }
        }
        fusedLocationClient.flushLocations();
    }

    // Every call needs registration to be called first at some point.
    public void registerClient(MatchingEngine me) {
        Context context = InstrumentationRegistry.getInstrumentation().getTargetContext();

        AppClient.RegisterClientReply registerReply;
        AppClient.RegisterClientRequest regRequest;

        try {
            // The app version will be null, but we can build from scratch for test
            List<Pair<String, Long>> ids = me.retrieveCellId(context);
            AppClient.RegisterClientRequest.Builder regRequestBuilder = AppClient.RegisterClientRequest.newBuilder()
                    .setOrgName(organizationName)
                    .setAppName(applicationName)
                    .setAppVers(appVersion);
                    //.setCellId(getCellId(context, me));
            regRequest = regRequestBuilder.build();
            if (useHostOverride) {
                registerReply = me.registerClient(regRequest, hostOverride, portOverride, GRPC_TIMEOUT_MS);
            } else {
                registerReply = me.registerClient(regRequest, GRPC_TIMEOUT_MS);
            }
            // TODO: Validate JWT
        } catch (DmeDnsException dde) {
            Log.e(TAG, Log.getStackTraceString(dde));
            assertTrue("ExecutionException registering client.", false);
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
            assertTrue("ExecutionException registering client", false);
        } catch (InterruptedException ioe) {
            Log.e(TAG, Log.getStackTraceString(ioe));
            assertTrue("InterruptedException registering client", false);
        }
    }

//    protected class rc extends AsyncTask<MatchingEngine, null, null> {
//        @Override
//        protected Object doInBackground(MatchingEngine... params) {
//            registerClient(params[0]);
//        }
//    }

    @Test
    public void melDisabledTest() {
        boolean melenabled = MelMessaging.isMelEnabled();
        assertFalse("mel not disabled", melenabled);
    }

    @Test
    public void findCloudletTest() {
        Context context = InstrumentationRegistry.getInstrumentation().getTargetContext();
        AppClient.FindCloudletReply findCloudletReply1 = null;
        AppClient.FindCloudletReply findCloudletReply2 = null;
        final MatchingEngine me = new MatchingEngine(context);
        //me.setUseWifiOnly(useWifiOnly);
        me.setMatchingEngineLocationAllowed(true);
        //me.setAllowSwitchIfNoSubscriberInfo(true);

        try {
            Location location = getTestLocation( 33.00,-96.54);

            //String carrierName = me.getCarrierName(context);
            //rc r = new rc(me).execute();
            registerClient(me);
            //AsyncTask.execute(new Runnable() {
            //                      @Override
            //                      public void run() {
            //                         registerClient(me);
            //                      }
            //                  });

            //Object aMon = new Object(); // Some arbitrary object Monitor.
            //synchronized (aMon) {
            //    aMon.wait(1000);
           // }


            //wait(3000);

            // Set orgName and location, then override the rest for testing:
            AppClient.FindCloudletRequest findCloudletRequest = me.createDefaultFindCloudletRequest(context, location)
                    //.setCarrierName(findCloudletCarrierOverride)
                    .build();
            if (useHostOverride) {
                findCloudletReply1 = me.findCloudlet(findCloudletRequest, hostOverride, portOverride, GRPC_TIMEOUT_MS);
            } else {
                findCloudletReply1 = me.findCloudlet(findCloudletRequest, GRPC_TIMEOUT_MS);
            }

            // Second try:
            me.setThreadedPerformanceTest(true);
            if (useHostOverride) {
                findCloudletReply2 = me.findCloudlet(findCloudletRequest, hostOverride, portOverride, GRPC_TIMEOUT_MS);
            } else {
                findCloudletReply2 = me.findCloudlet(findCloudletRequest, GRPC_TIMEOUT_MS);
            }

        } catch (DmeDnsException dde) {
            Log.e(TAG, Log.getStackTraceString(dde));
            assertFalse("FindCloudlet: DmeDnsException", true);
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
            assertFalse("FindCloudlet: ExecutionException!", true);
        } catch (StatusRuntimeException sre) {
            Log.e(TAG, sre.getMessage());
            Log.e(TAG, Log.getStackTraceString(sre));
            assertFalse("FindCloudlet: StatusRunTimeException!", true);
        } catch (InterruptedException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
            assertFalse("FindCloudlet: InterruptedException!", true);
        }

        try {
            String cloudletAddress = "";
            if(foundCloudletFqdn.equals(findCloudletReply1.getFqdn())){
                cloudletAddress = InetAddress.getByName(foundCloudletFqdn).getHostAddress();
            }
            if(foundCloudletFqdn1.equals(findCloudletReply1.getFqdn())){
                cloudletAddress = InetAddress.getByName(foundCloudletFqdn1).getHostAddress();
            }

            String findCloudletReplyFqdn = findCloudletReply1.getFqdn();
            String officialAddress = InetAddress.getByName(findCloudletReplyFqdn).getHostAddress();
            assertEquals("App's expected DNS resolutaion doesn't match.", cloudletAddress, officialAddress);
        } catch (UnknownHostException var6) {
            assertFalse("InetAddressFailed!", true);
        }
        assertNotNull("FindCloudletReply1 is null!", findCloudletReply1);
        assertNotNull("FindCloudletReply2 is null!", findCloudletReply2);

        // Might also fail, since the network is not under test control:
        assertTrue("App's expected test cloudlet FQDN doesn't match. " + findCloudletReply1.getFqdn(), foundCloudletFqdn.equals(findCloudletReply1.getFqdn()) || foundCloudletFqdn1.equals(findCloudletReply1.getFqdn()));
        assertEquals("App's expected test cloudlet FQDN Bytes doesn't match.", foundCloudletFqdn, findCloudletReply1.getFqdnBytes().toStringUtf8());
        assertEquals("App's expected test cloudlet Ports Count doesn't match.", 5, findCloudletReply1.getPortsCount());
        assertEquals("App's expected test cloudlet Status doesn't match.", AppClient.FindCloudletReply.FindStatus.FIND_FOUND, findCloudletReply1.getStatus());
        assertEquals("App's expected test cloudlet Status Value doesn't match.", AppClient.FindCloudletReply.FindStatus.FIND_FOUND_VALUE, findCloudletReply1.getStatusValue());

        //assertEquals("App's expected test Port fqdn prefix doesn't match.", "sdktest90-udp.", findCloudletReply1.getPorts(0).getFqdnPrefix());
        assertEquals("App's expected test Port fqdn prefix doesn't match.", "", findCloudletReply1.getPorts(0).getFqdnPrefix());
        assertEquals("App's expected test Port endport doesn't match.", 0, findCloudletReply1.getPorts(0).getEndPort());
        assertEquals("App's expected test Port internalport doesn't match.", 2016, findCloudletReply1.getPorts(0).getInternalPort());
        assertEquals("App's expected test Port publicport doesn't match.", 2016, findCloudletReply1.getPorts(0).getPublicPort());
        assertEquals("App's expected test Port proto doesn't match.", Appcommon.LProto.L_PROTO_TCP, findCloudletReply1.getPorts(0).getProto());
        assertEquals("App's expected test Port tls doesn't match.", false, findCloudletReply1.getPorts(0).getTls());

        //assertEquals("App's expected test Port fqdn prefix doesn't match.", "automation-sdk-porttest10-tcp.", findCloudletReply1.getPorts(1).getFqdnPrefix());
        assertEquals("App's expected test Port fqdn prefix doesn't match.", "", findCloudletReply1.getPorts(1).getFqdnPrefix());
        assertEquals("App's expected test Port endport doesn't match.", 0, findCloudletReply1.getPorts(1).getEndPort());
        assertEquals("App's expected test Port internalport doesn't match.", 3765, findCloudletReply1.getPorts(1).getInternalPort());
        assertEquals("App's expected test Port publicport doesn't match.", 3765, findCloudletReply1.getPorts(1).getPublicPort());
        assertEquals("App's expected test Port proto doesn't match.", Appcommon.LProto.L_PROTO_TCP, findCloudletReply1.getPorts(1).getProto());
        assertEquals("App's expected test Port tls doesn't match.", false, findCloudletReply1.getPorts(1).getTls());

        //assertEquals("App's expected test Port fqdn prefix doesn't match.", "automation-sdk-porttest10-tcp.", findCloudletReply1.getPorts(2).getFqdnPrefix());
        assertEquals("App's expected test Port fqdn prefix doesn't match.", "", findCloudletReply1.getPorts(2).getFqdnPrefix());
        assertEquals("App's expected test Port endport doesn't match.", 0, findCloudletReply1.getPorts(2).getEndPort());
        assertEquals("App's expected test Port internalport doesn't match.", 2015, findCloudletReply1.getPorts(2).getInternalPort());
        assertEquals("App's expected test Port publicport doesn't match.", 2015, findCloudletReply1.getPorts(2).getPublicPort());
        assertEquals("App's expected test Port proto doesn't match.", Appcommon.LProto.L_PROTO_TCP, findCloudletReply1.getPorts(2).getProto());
        assertEquals("App's expected test Port tls doesn't match.", true, findCloudletReply1.getPorts(2).getTls());

        //assertEquals("App's expected test Port fqdn prefix doesn't match.", "automation-sdk-porttest10-tcp.", findCloudletReply1.getPorts(3).getFqdnPrefix());
        assertEquals("App's expected test Port fqdn prefix doesn't match.", "", findCloudletReply1.getPorts(3).getFqdnPrefix());
        assertEquals("App's expected test Port endport doesn't match.", 0, findCloudletReply1.getPorts(3).getEndPort());
        assertEquals("App's expected test Port internalport doesn't match.", 2015, findCloudletReply1.getPorts(3).getInternalPort());
        assertEquals("App's expected test Port publicport doesn't match.", 2015, findCloudletReply1.getPorts(3).getPublicPort());
        assertEquals("App's expected test Port proto doesn't match.", Appcommon.LProto.L_PROTO_UDP, findCloudletReply1.getPorts(3).getProto());
        assertEquals("App's expected test Port tls doesn't match.", false, findCloudletReply1.getPorts(3).getTls());

        //assertEquals("App's expected test Port fqdn prefix doesn't match.", "automation-sdk-porttest10-tcp.", findCloudletReply1.getPorts(3).getFqdnPrefix());
        assertEquals("App's expected test Port fqdn prefix doesn't match.", "", findCloudletReply1.getPorts(4).getFqdnPrefix());
        assertEquals("App's expected test Port endport doesn't match.", 0, findCloudletReply1.getPorts(4).getEndPort());
        assertEquals("App's expected test Port internalport doesn't match.", 8085, findCloudletReply1.getPorts(4).getInternalPort());
        assertEquals("App's expected test Port publicport doesn't match.", 8085, findCloudletReply1.getPorts(4).getPublicPort());
        assertEquals("App's expected test Port proto doesn't match.", Appcommon.LProto.L_PROTO_TCP, findCloudletReply1.getPorts(4).getProto());
        assertEquals("App's expected test Port tls doesn't match.", false, findCloudletReply1.getPorts(4).getTls());

    }

    @Test
    public void findCloudletPerformanceTest() {
        Context context = InstrumentationRegistry.getInstrumentation().getTargetContext();
        AppClient.FindCloudletReply findCloudletReply1 = null;
        AppClient.FindCloudletReply findCloudletReply2 = null;
        final MatchingEngine me = new MatchingEngine(context);
        //me.setUseWifiOnly(useWifiOnly);
        me.setMatchingEngineLocationAllowed(true);
        //me.setAllowSwitchIfNoSubscriberInfo(true);

        try {
            Location location = getTestLocation( 33.00,-96.54);

            registerClient(me);

            // Set orgName and location, then override the rest for testing:
            AppClient.FindCloudletRequest findCloudletRequest = me.createDefaultFindCloudletRequest(context, location)
                    //.setCarrierName(findCloudletCarrierOverride)
                    .build();
            if (useHostOverride) {
                findCloudletReply1 = me.findCloudlet(findCloudletRequest, hostOverride, portOverride, GRPC_TIMEOUT_MS, MatchingEngine.FindCloudletMode.PERFORMANCE);
            } else {
                findCloudletReply1 = me.findCloudlet(findCloudletRequest, GRPC_TIMEOUT_MS, MatchingEngine.FindCloudletMode.PERFORMANCE);
            }

            // Second try:
            me.setThreadedPerformanceTest(true);
            if (useHostOverride) {
                findCloudletReply2 = me.findCloudlet(findCloudletRequest, hostOverride, portOverride, GRPC_TIMEOUT_MS);
            } else {
                findCloudletReply2 = me.findCloudlet(findCloudletRequest, GRPC_TIMEOUT_MS);
            }

        } catch (DmeDnsException dde) {
            Log.e(TAG, Log.getStackTraceString(dde));
            assertFalse("FindCloudlet: DmeDnsException", true);
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
            assertFalse("FindCloudlet: ExecutionException!", true);
        } catch (StatusRuntimeException sre) {
            Log.e(TAG, sre.getMessage());
            Log.e(TAG, Log.getStackTraceString(sre));
            assertFalse("FindCloudlet: StatusRunTimeException!", true);
        } catch (InterruptedException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
            assertFalse("FindCloudlet: InterruptedException!", true);
        }

        try {
            String cloudletAddress = InetAddress.getByName(foundCloudletFqdn).getHostAddress();
            String findCloudletReplyFqdn = findCloudletReply1.getFqdn();
            String officialAddress = InetAddress.getByName(findCloudletReplyFqdn).getHostAddress();
            assertEquals("App's expected DNS resolutaion doesn't match.", cloudletAddress, officialAddress);
        } catch (UnknownHostException var6) {
            assertFalse("InetAddressFailed!", true);
        }

        assertNotNull("FindCloudletReply1 is null!", findCloudletReply1);
        assertNotNull("FindCloudletReply2 is null!", findCloudletReply2);

        // Might also fail, since the network is not under test control:
        assertTrue((foundCloudletFqdn.equals(findCloudletReply1.getFqdn())) || (foundCloudletFqdn1.equals(findCloudletReply1.getFqdn())));
        assertEquals("App's expected test cloudlet FQDN Bytes doesn't match.", foundCloudletFqdn, findCloudletReply1.getFqdnBytes().toStringUtf8());
        assertEquals("App's expected test cloudlet Ports Count doesn't match.", 5, findCloudletReply1.getPortsCount());
        assertEquals("App's expected test cloudlet Status doesn't match.", AppClient.FindCloudletReply.FindStatus.FIND_FOUND, findCloudletReply1.getStatus());
        assertEquals("App's expected test cloudlet Status Value doesn't match.", AppClient.FindCloudletReply.FindStatus.FIND_FOUND_VALUE, findCloudletReply1.getStatusValue());
        assertEquals("App's expected test cloudlet Latitude Value doesn't match.", 53.5461, findCloudletReply1.getCloudletLocation().getLatitude());
        assertEquals("App's expected test cloudlet Longitude Value doesn't match.", -113.4938, findCloudletReply1.getCloudletLocation().getLongitude());

        //assertEquals("App's expected test Port fqdn prefix doesn't match.", "sdktest90-udp.", findCloudletReply1.getPorts(0).getFqdnPrefix());
        assertEquals("App's expected test Port fqdn prefix doesn't match.", "", findCloudletReply1.getPorts(0).getFqdnPrefix());
        assertEquals("App's expected test Port endport doesn't match.", 0, findCloudletReply1.getPorts(0).getEndPort());
        assertEquals("App's expected test Port internalport doesn't match.", 2016, findCloudletReply1.getPorts(0).getInternalPort());
        assertEquals("App's expected test Port publicport doesn't match.", 2016, findCloudletReply1.getPorts(0).getPublicPort());
        assertEquals("App's expected test Port proto doesn't match.", Appcommon.LProto.L_PROTO_TCP, findCloudletReply1.getPorts(0).getProto());
        assertEquals("App's expected test Port tls doesn't match.", false, findCloudletReply1.getPorts(0).getTls());

        //assertEquals("App's expected test Port fqdn prefix doesn't match.", "automation-sdk-porttest10-tcp.", findCloudletReply1.getPorts(1).getFqdnPrefix());
        assertEquals("App's expected test Port fqdn prefix doesn't match.", "", findCloudletReply1.getPorts(1).getFqdnPrefix());
        assertEquals("App's expected test Port endport doesn't match.", 0, findCloudletReply1.getPorts(1).getEndPort());
        assertEquals("App's expected test Port internalport doesn't match.", 3765, findCloudletReply1.getPorts(1).getInternalPort());
        assertEquals("App's expected test Port publicport doesn't match.", 3765, findCloudletReply1.getPorts(1).getPublicPort());
        assertEquals("App's expected test Port proto doesn't match.", Appcommon.LProto.L_PROTO_TCP, findCloudletReply1.getPorts(1).getProto());
        assertEquals("App's expected test Port tls doesn't match.", false, findCloudletReply1.getPorts(1).getTls());

        //assertEquals("App's expected test Port fqdn prefix doesn't match.", "automation-sdk-porttest10-tcp.", findCloudletReply1.getPorts(2).getFqdnPrefix());
        assertEquals("App's expected test Port fqdn prefix doesn't match.", "", findCloudletReply1.getPorts(2).getFqdnPrefix());
        assertEquals("App's expected test Port endport doesn't match.", 0, findCloudletReply1.getPorts(2).getEndPort());
        assertEquals("App's expected test Port internalport doesn't match.", 2015, findCloudletReply1.getPorts(2).getInternalPort());
        assertEquals("App's expected test Port publicport doesn't match.", 2015, findCloudletReply1.getPorts(2).getPublicPort());
        assertEquals("App's expected test Port proto doesn't match.", Appcommon.LProto.L_PROTO_TCP, findCloudletReply1.getPorts(2).getProto());
        assertEquals("App's expected test Port tls doesn't match.", true, findCloudletReply1.getPorts(2).getTls());

        //assertEquals("App's expected test Port fqdn prefix doesn't match.", "automation-sdk-porttest10-tcp.", findCloudletReply1.getPorts(3).getFqdnPrefix());
        assertEquals("App's expected test Port fqdn prefix doesn't match.", "", findCloudletReply1.getPorts(3).getFqdnPrefix());
        assertEquals("App's expected test Port endport doesn't match.", 0, findCloudletReply1.getPorts(3).getEndPort());
        assertEquals("App's expected test Port internalport doesn't match.", 2015, findCloudletReply1.getPorts(3).getInternalPort());
        assertEquals("App's expected test Port publicport doesn't match.", 2015, findCloudletReply1.getPorts(3).getPublicPort());
        assertEquals("App's expected test Port proto doesn't match.", Appcommon.LProto.L_PROTO_UDP, findCloudletReply1.getPorts(3).getProto());
        assertEquals("App's expected test Port tls doesn't match.", false, findCloudletReply1.getPorts(3).getTls());

        //assertEquals("App's expected test Port fqdn prefix doesn't match.", "automation-sdk-porttest10-tcp.", findCloudletReply1.getPorts(3).getFqdnPrefix());
        assertEquals("App's expected test Port fqdn prefix doesn't match.", "", findCloudletReply1.getPorts(4).getFqdnPrefix());
        assertEquals("App's expected test Port endport doesn't match.", 0, findCloudletReply1.getPorts(4).getEndPort());
        assertEquals("App's expected test Port internalport doesn't match.", 8085, findCloudletReply1.getPorts(4).getInternalPort());
        assertEquals("App's expected test Port publicport doesn't match.", 8085, findCloudletReply1.getPorts(4).getPublicPort());
        assertEquals("App's expected test Port proto doesn't match.", Appcommon.LProto.L_PROTO_TCP, findCloudletReply1.getPorts(4).getProto());
        assertEquals("App's expected test Port tls doesn't match.", false, findCloudletReply1.getPorts(4).getTls());

    }

    @Test
    public void mexDisabledTest() {
        Context context = InstrumentationRegistry.getInstrumentation().getTargetContext();
        MatchingEngine me = new MatchingEngine(context);
        me.setMatchingEngineLocationAllowed(true);
        //me.setAllowSwitchIfNoSubscriberInfo(true);

        Location location = getTestLocation( 47.6062,122.3321);

        registerClient(me);

        //me.setUseWifiOnly(useWifiOnly);
        me.setMatchingEngineLocationAllowed(false);
        //me.setAllowSwitchIfNoSubscriberInfo(true);

        try {

            AppClient.FindCloudletRequest.Builder findCloudletRequest = me.createDefaultFindCloudletRequest(context, location);
            assert(findCloudletRequest == null);


        } catch (StatusRuntimeException sre) {
            Log.e(TAG, Log.getStackTraceString(sre));
            assertFalse("mexDisabledTest: StatusRuntimeException!", true);
        }
    }

    @Test
    public void findCloudletNoCookie() {
        Context context = InstrumentationRegistry.getInstrumentation().getTargetContext();
        AppClient.FindCloudletReply findCloudletReply1 = null;
        AppClient.FindCloudletReply findCloudletReply2 = null;
        MatchingEngine me = new MatchingEngine(context);
        //me.setUseWifiOnly(useWifiOnly);
        me.setMatchingEngineLocationAllowed(true);
        //me.setAllowSwitchIfNoSubscriberInfo(true);

        try {
            Location location = getTestLocation( 47.6062,122.3321);

            //String carrierName = me.getCarrierName(context);
            registerClient(me);

            // Set orgName and location, then override the rest for testing:
            AppClient.FindCloudletRequest findCloudletRequest = me.createDefaultFindCloudletRequest(context, location)
                    .setSessionCookie("")
                    .build();
            if (useHostOverride) {
                findCloudletReply1 = me.findCloudlet(findCloudletRequest, hostOverride, portOverride, GRPC_TIMEOUT_MS);
            } else {
                findCloudletReply1 = me.findCloudlet(findCloudletRequest, GRPC_TIMEOUT_MS);
            }

        } catch (DmeDnsException dde) {
            Log.e(TAG, Log.getStackTraceString(dde));
            assertFalse("FindCloudlet: DmeDnsException", true);
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
            assertFalse("FindCloudlet: ExecutionException!", true);
        } catch (IllegalArgumentException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
            assertEquals("status code not correct", "An unexpired RegisterClient sessionCookie is required.", ie.getLocalizedMessage());
        } catch (StatusRuntimeException sre) {
            Log.e(TAG, sre.getMessage());
            Log.e(TAG, Log.getStackTraceString(sre));
            assertFalse("FindCloudlet: StatusRuntimeException!", true);
            assertEquals("status code not correct", Status.Code.UNAUTHENTICATED, sre.getStatus().getCode());
            assertEquals("status desc not correct", "VerifyCookie failed: missing cookie", sre.getStatus().getDescription());
            assertEquals("message not correct", "UNAUTHENTICATED: VerifyCookie failed: missing cookie", sre.getMessage());
        } catch (InterruptedException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
            assertFalse("FindCloudlet: InterruptedException!", true);

        }

        assertEquals("findCloudletReply is not null", findCloudletReply1,null);
    }

    @Test
    public void findCloudletWrongCookie() {
        Context context = InstrumentationRegistry.getInstrumentation().getTargetContext();
        AppClient.FindCloudletReply findCloudletReply1 = null;
        MatchingEngine me = new MatchingEngine(context);
        //me.setUseWifiOnly(useWifiOnly);
        me.setMatchingEngineLocationAllowed(true);
        //me.setAllowSwitchIfNoSubscriberInfo(true);

        try {
            Location location = getTestLocation( 33.00,-96.54);

           // String carrierName = me.getCarrierName(context);
            registerClient(me);

            // Set orgName and location, then override the rest for testing:
            AppClient.FindCloudletRequest findCloudletRequest = me.createDefaultFindCloudletRequest(context, location)
                    //.setCarrierName("GDDT")
                    .setSessionCookie("xxxxxxx")
                    .build();
            if (useHostOverride) {
                findCloudletReply1 = me.findCloudlet(findCloudletRequest, hostOverride, portOverride, GRPC_TIMEOUT_MS);
            } else {
                findCloudletReply1 = me.findCloudlet(findCloudletRequest, GRPC_TIMEOUT_MS);
            }

        } catch (DmeDnsException dde) {
            Log.e(TAG, Log.getStackTraceString(dde));
            assertFalse("FindCloudlet: DmeDnsException", true);
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
            assertFalse("FindCloudlet: ExecutionException!", true);
        } catch (StatusRuntimeException sre) {
            Log.e(TAG, sre.getMessage());
            Log.e(TAG, Log.getStackTraceString(sre));
            assertEquals("status code not correct", Status.Code.UNAUTHENTICATED, sre.getStatus().getCode());
            assertEquals("status desc not correct", "token contains an invalid number of segments", sre.getStatus().getDescription());
            assertEquals("message not correct", "UNAUTHENTICATED: token contains an invalid number of segments", sre.getMessage());
        } catch (InterruptedException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
            assertFalse("FindCloudlet: InterruptedException!", true);

        }

        assert(findCloudletReply1 == null);
    }

    @Test
    public void findCloudletNoRegisterClient() {
        Context context = InstrumentationRegistry.getInstrumentation().getTargetContext();
        AppClient.FindCloudletReply findCloudletReply1 = null;
        AppClient.FindCloudletReply findCloudletReply2 = null;
        MatchingEngine me = new MatchingEngine(context);
        //me.setUseWifiOnly(useWifiOnly);
        me.setMatchingEngineLocationAllowed(true);
        //me.setAllowSwitchIfNoSubscriberInfo(true);

        /// EDGECLOUD-2920 android SDK gives NullPointerException when sending FindCloudlet without RegisterClient

        try {
            Location location = getTestLocation( 33.00,-96.54);

            //String carrierName = me.getCarrierName(context);
            //registerClient(me);

            // Set orgName and location, then override the rest for testing:
            AppClient.FindCloudletRequest findCloudletRequest = me.createDefaultFindCloudletRequest(context, location)
                    //.setCarrierName("GDDT")
                    .build();
            if (useHostOverride) {
                findCloudletReply1 = me.findCloudlet(findCloudletRequest, hostOverride, portOverride, GRPC_TIMEOUT_MS);
            } else {
                findCloudletReply1 = me.findCloudlet(findCloudletRequest, GRPC_TIMEOUT_MS);
            }

        } catch (DmeDnsException dde) {
            Log.e(TAG, Log.getStackTraceString(dde));
            assertFalse("FindCloudlet: DmeDnsException", true);
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
            assertFalse("FindCloudlet: ExecutionException!", true);
        } catch (StatusRuntimeException sre) {
            Log.e(TAG, sre.getMessage());
            Log.e(TAG, Log.getStackTraceString(sre));
            assertFalse("FindCloudlet: ExecutionException!", true);
        } catch (IllegalArgumentException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
            assertEquals("status code not correct", "An unexpired RegisterClient sessionCookie is required.", ie.getLocalizedMessage());
        } catch (InterruptedException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
            assertFalse("FindCloudlet: InterruptedException!", true);

        }

        assert(findCloudletReply1 == null);
    }

    @Test
    public void findCloudletLatitudeTooSmall() {
        Context context = InstrumentationRegistry.getInstrumentation().getTargetContext();
        AppClient.FindCloudletReply findCloudletReply1 = null;
        MatchingEngine me = new MatchingEngine(context);
        //me.setUseWifiOnly(useWifiOnly);
        me.setMatchingEngineLocationAllowed(true);
        //me.setAllowSwitchIfNoSubscriberInfo(true);

        try {
            Location location = getTestLocation( -93.00,-96.54);

            //String carrierName = me.getCarrierName(context);
            registerClient(me);

            // Set orgName and location, then override the rest for testing:
            AppClient.FindCloudletRequest findCloudletRequest = me.createDefaultFindCloudletRequest(context, location)
                    //.setCarrierName("Leon's Fly-by-night Carrier")
                    .build();
            if (useHostOverride) {
                findCloudletReply1 = me.findCloudlet(findCloudletRequest, hostOverride, portOverride, GRPC_TIMEOUT_MS);
            } else {
                findCloudletReply1 = me.findCloudlet(findCloudletRequest, GRPC_TIMEOUT_MS);
            }

        } catch (DmeDnsException dde) {
            Log.e(TAG, Log.getStackTraceString(dde));
            assertFalse("FindCloudlet: DmeDnsException", true);
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
            assertFalse("FindCloudlet: ExecutionException!", true);
        } catch (StatusRuntimeException sre) {
            Log.e(TAG, sre.getMessage());
            Log.e(TAG, Log.getStackTraceString(sre));
            assertEquals("status code not correct", Status.Code.INVALID_ARGUMENT, sre.getStatus().getCode());
            assertEquals("status desc not correct", "Invalid GpsLocation", sre.getStatus().getDescription());
            assertEquals("message not correct", "INVALID_ARGUMENT: Invalid GpsLocation", sre.getMessage());
        } catch (InterruptedException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
            assertFalse("FindCloudlet: InterruptedException!", true);

        }

        assert(findCloudletReply1 == null);
    }

    @Test
    public void findCloudletLatitudeTooLarge() {
        Context context = InstrumentationRegistry.getInstrumentation().getTargetContext();
        AppClient.FindCloudletReply findCloudletReply1 = null;
        MatchingEngine me = new MatchingEngine(context);
        //me.setUseWifiOnly(useWifiOnly);
        me.setMatchingEngineLocationAllowed(true);
        //me.setAllowSwitchIfNoSubscriberInfo(true);

        try {
            Location location = getTestLocation( 91.00,-96.54);

            //String carrierName = me.getCarrierName(context);
            registerClient(me);

            // Set orgName and location, then override the rest for testing:
            AppClient.FindCloudletRequest findCloudletRequest = me.createDefaultFindCloudletRequest(context, location)
                    //.setCarrierName("Leon's Fly-by-night Carrier")
                    .build();
            if (useHostOverride) {
                findCloudletReply1 = me.findCloudlet(findCloudletRequest, hostOverride, portOverride, GRPC_TIMEOUT_MS);
            } else {
                findCloudletReply1 = me.findCloudlet(findCloudletRequest, GRPC_TIMEOUT_MS);
            }

        } catch (DmeDnsException dde) {
            Log.e(TAG, Log.getStackTraceString(dde));
            assertFalse("FindCloudlet: DmeDnsException", true);
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
            assertFalse("FindCloudlet: ExecutionException!", true);
        } catch (StatusRuntimeException sre) {
            Log.e(TAG, sre.getMessage());
            Log.e(TAG, Log.getStackTraceString(sre));
            assertEquals("status code not correct", Status.Code.INVALID_ARGUMENT, sre.getStatus().getCode());
            assertEquals("status desc not correct", "Invalid GpsLocation", sre.getStatus().getDescription());
            assertEquals("message not correct", "INVALID_ARGUMENT: Invalid GpsLocation", sre.getMessage());
        } catch (InterruptedException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
            assertFalse("FindCloudlet: InterruptedException!", true);

        }

        assert(findCloudletReply1 == null);
    }

    @Test
    public void findCloudletLongitudeTooSmall() {
        Context context = InstrumentationRegistry.getInstrumentation().getTargetContext();
        AppClient.FindCloudletReply findCloudletReply1 = null;
        MatchingEngine me = new MatchingEngine(context);
        //me.setUseWifiOnly(useWifiOnly);
        me.setMatchingEngineLocationAllowed(true);
        //me.setAllowSwitchIfNoSubscriberInfo(true);

        try {
            Location location = getTestLocation( 1.1,-181.3321);

            //String carrierName = me.getCarrierName(context);
            registerClient(me);

            // Set orgName and location, then override the rest for testing:
            AppClient.FindCloudletRequest findCloudletRequest = me.createDefaultFindCloudletRequest(context, location)
                    //.setCarrierName("Leon's Fly-by-night Carrier")
                    .build();
            if (useHostOverride) {
                findCloudletReply1 = me.findCloudlet(findCloudletRequest, hostOverride, portOverride, GRPC_TIMEOUT_MS);
            } else {
                findCloudletReply1 = me.findCloudlet(findCloudletRequest, GRPC_TIMEOUT_MS);
            }

        } catch (DmeDnsException dde) {
            Log.e(TAG, Log.getStackTraceString(dde));
            assertFalse("FindCloudlet: DmeDnsException", true);
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
            assertFalse("FindCloudlet: ExecutionException!", true);
        } catch (StatusRuntimeException sre) {
            Log.e(TAG, sre.getMessage());
            Log.e(TAG, Log.getStackTraceString(sre));
            assertEquals("status code not correct", Status.Code.INVALID_ARGUMENT, sre.getStatus().getCode());
            assertEquals("status desc not correct", "Invalid GpsLocation", sre.getStatus().getDescription());
            assertEquals("message not correct", "INVALID_ARGUMENT: Invalid GpsLocation", sre.getMessage());
        } catch (InterruptedException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
            assertFalse("FindCloudlet: InterruptedException!", true);

        }

        assert(findCloudletReply1 == null);
    }

    @Test
    public void findCloudletLongitudeTooLarge() {
        Context context = InstrumentationRegistry.getInstrumentation().getTargetContext();
        AppClient.FindCloudletReply findCloudletReply1 = null;
        MatchingEngine me = new MatchingEngine(context);
        //me.setUseWifiOnly(useWifiOnly);
        me.setMatchingEngineLocationAllowed(true);
        //me.setAllowSwitchIfNoSubscriberInfo(true);

        try {
            Location location = getTestLocation( 1.1,181.3321);

            //String carrierName = me.getCarrierName(context);
            registerClient(me);

            // Set orgName and location, then override the rest for testing:
            AppClient.FindCloudletRequest findCloudletRequest = me.createDefaultFindCloudletRequest(context, location)
                    //.setCarrierName("Leon's Fly-by-night Carrier")
                    .build();
            if (useHostOverride) {
                findCloudletReply1 = me.findCloudlet(findCloudletRequest, hostOverride, portOverride, GRPC_TIMEOUT_MS);
            } else {
                findCloudletReply1 = me.findCloudlet(findCloudletRequest, GRPC_TIMEOUT_MS);
            }

        } catch (DmeDnsException dde) {
            Log.e(TAG, Log.getStackTraceString(dde));
            assertFalse("FindCloudlet: DmeDnsException", true);
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
            assertFalse("FindCloudlet: ExecutionException!", true);
        } catch (StatusRuntimeException sre) {
            Log.e(TAG, sre.getMessage());
            Log.e(TAG, Log.getStackTraceString(sre));
            assertEquals("status code not correct", Status.Code.INVALID_ARGUMENT, sre.getStatus().getCode());
            assertEquals("status desc not correct", "Invalid GpsLocation", sre.getStatus().getDescription());
            assertEquals("message not correct", "INVALID_ARGUMENT: Invalid GpsLocation", sre.getMessage());
        } catch (InterruptedException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
            assertFalse("FindCloudlet: InterruptedException!", true);

        }

        assert(findCloudletReply1 == null);
    }

    @Test
    public void findCloudletLatitudeLongitudeOutOfRange() {
        Context context = InstrumentationRegistry.getInstrumentation().getTargetContext();
        AppClient.FindCloudletReply findCloudletReply1 = null;
        MatchingEngine me = new MatchingEngine(context);
        //me.setUseWifiOnly(useWifiOnly);
        me.setMatchingEngineLocationAllowed(true);
        //me.setAllowSwitchIfNoSubscriberInfo(true);

        try {
            Location location = getTestLocation( 999999999.1,-99999999.1);

            //String carrierName = me.getCarrierName(context);
            registerClient(me);

            // Set orgName and location, then override the rest for testing:
            AppClient.FindCloudletRequest findCloudletRequest = me.createDefaultFindCloudletRequest(context, location)
                    //.setCarrierName("Leon's Fly-by-night Carrier")
                    .build();
            if (useHostOverride) {
                findCloudletReply1 = me.findCloudlet(findCloudletRequest, hostOverride, portOverride, GRPC_TIMEOUT_MS);
            } else {
                findCloudletReply1 = me.findCloudlet(findCloudletRequest, GRPC_TIMEOUT_MS);
            }
            String fcrstatus = findCloudletReply1.getStatus().toString();
            Log.i("FCRStatus",fcrstatus);
        } catch (DmeDnsException dde) {
            Log.e(TAG, Log.getStackTraceString(dde));
            assertFalse("FindCloudlet: DmeDnsException", true);
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
            assertFalse("FindCloudlet: ExecutionException!", true);
        } catch (StatusRuntimeException sre) {
            Log.e(TAG, sre.getMessage());
            Log.e(TAG, Log.getStackTraceString(sre));
            assertEquals("status code not correct", Status.Code.INVALID_ARGUMENT, sre.getStatus().getCode());
            assertEquals("status desc not correct", "Invalid GpsLocation", sre.getStatus().getDescription());
            assertEquals("message not correct", "INVALID_ARGUMENT: Invalid GpsLocation", sre.getMessage());
        } catch (InterruptedException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
            assertFalse("FindCloudlet: InterruptedException!", true);

        }

        assert(findCloudletReply1 == null);
    }

    @Test
    public void findCloudletLatitudeLongitudeMissing() {
        Context context = InstrumentationRegistry.getInstrumentation().getTargetContext();
        AppClient.FindCloudletReply findCloudletReply1 = null;
        MatchingEngine me = new MatchingEngine(context);
        //me.setUseWifiOnly(useWifiOnly);
        me.setMatchingEngineLocationAllowed(true);
        //me.setAllowSwitchIfNoSubscriberInfo(true);

        try {
            Location location = null;
            //String carrierName = me.getCarrierName(context);
            registerClient(me);

            // Set orgName and location, then override the rest for testing:
            AppClient.FindCloudletRequest findCloudletRequest = me.createDefaultFindCloudletRequest(context, location)
                    //.setCarrierName("GDDT")
                    .build();
            if (useHostOverride) {
                findCloudletReply1 = me.findCloudlet(findCloudletRequest, hostOverride, portOverride, GRPC_TIMEOUT_MS);
            } else {
                findCloudletReply1 = me.findCloudlet(findCloudletRequest, GRPC_TIMEOUT_MS);
            }

        } catch (DmeDnsException dde) {
            Log.e(TAG, Log.getStackTraceString(dde));
            assertFalse("FindCloudlet: DmeDnsException", true);
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
            assertFalse("FindCloudlet: ExecutionException!", true);
        } catch (StatusRuntimeException sre) {
            Log.e(TAG, sre.getMessage());
            Log.e(TAG, Log.getStackTraceString(sre));
            assertEquals("status code not correct", Status.Code.INVALID_ARGUMENT, sre.getStatus().getCode());
            assertEquals("status desc not correct", "Missing GpsLocation", sre.getStatus().getDescription());
            assertEquals("message not correct", "INVALID_ARGUMENT: Missing GpsLocation", sre.getMessage());
        } catch (InterruptedException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
            assertFalse("FindCloudlet: InterruptedException!", true);

        }

        assert(findCloudletReply1 == null);
    }


    @Test
    public void findCloudletBadCarrier() {
        Context context = InstrumentationRegistry.getInstrumentation().getTargetContext();
        AppClient.FindCloudletReply findCloudletReply1 = null;
        AppClient.FindCloudletReply findCloudletReply2 = null;
        MatchingEngine me = new MatchingEngine(context);
        //me.setUseWifiOnly(useWifiOnly);
        me.setMatchingEngineLocationAllowed(true);
        //me.setAllowSwitchIfNoSubscriberInfo(true);

        try {
            Location location = getTestLocation( 33.00,-96.54);

            //String carrierName = me.getCarrierName(context);
            registerClient(me);

            // Set orgName and location, then override the rest for testing:
            AppClient.FindCloudletRequest findCloudletRequest = me.createDefaultFindCloudletRequest(context, location)
                    .setCarrierName("Leon")
                    .build();
            if (useHostOverride) {
                findCloudletReply1 = me.findCloudlet(findCloudletRequest, hostOverride, portOverride, GRPC_TIMEOUT_MS);
            } else {
                findCloudletReply1 = me.findCloudlet(findCloudletRequest, GRPC_TIMEOUT_MS);
            }

            // Second try:
            me.setThreadedPerformanceTest(true);
            if (useHostOverride) {
                findCloudletReply2 = me.findCloudlet(findCloudletRequest, hostOverride, portOverride, GRPC_TIMEOUT_MS);
            } else {
                findCloudletReply2 = me.findCloudlet(findCloudletRequest, GRPC_TIMEOUT_MS);
            }

        } catch (DmeDnsException dde) {
            Log.e(TAG, Log.getStackTraceString(dde));
            assertFalse("FindCloudlet: DmeDnsException", true);
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
            assertFalse("FindCloudlet: ExecutionException!", true);
        } catch (StatusRuntimeException sre) {
            Log.e(TAG, sre.getMessage());
            Log.e(TAG, Log.getStackTraceString(sre));
            assertFalse("FindCloudlet: StatusRunTimeException!", true);
        } catch (InterruptedException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
            assertFalse("FindCloudlet: InterruptedException!", true);

        }

        Log.i(TAG, "findCloudletReply1="+findCloudletReply1);
        Log.i(TAG, "findCloudletReply2="+findCloudletReply2);
        assertNotNull("FindCloudletReply1 is null!", findCloudletReply1);
        assertNotNull("FindCloudletReply2 is null!", findCloudletReply2);

        assertEquals("status doesn't match", AppClient.FindCloudletReply.FindStatus.FIND_NOTFOUND, findCloudletReply1.getStatus());

    }

    // This test only tests "" any, and not subject to the global override.
    @Test
    public void findCloudletTestSetCarrierNameAnyOverride() {
        Context context = InstrumentationRegistry.getInstrumentation().getTargetContext();
        AppClient.FindCloudletReply findCloudletReply = null;
        MatchingEngine me = new MatchingEngine(context);
        //me.setUseWifiOnly(useWifiOnly);
        me.setMatchingEngineLocationAllowed(true);
        //me.setAllowSwitchIfNoSubscriberInfo(true);

        boolean expectedExceptionHit = false;
        try {
            Location location = getTestLocation( 47.6062,122.3321);

            //String carrierName = me.get(context);
            registerClient(me);

            // Set NO carrier name, as if there's no SIM card. This should tell DME to return
            // any edge AppInst from any carrier, for this app, version, orgName keyset.
            AppClient.FindCloudletRequest findCloudletRequest2 = me.createDefaultFindCloudletRequest(context, location)
                    .setCarrierName("")
                    .build();
            if (useHostOverride) {
                findCloudletReply = me.findCloudlet(findCloudletRequest2, hostOverride, portOverride, GRPC_TIMEOUT_MS);
            } else {
                findCloudletReply = me.findCloudlet(findCloudletRequest2, GRPC_TIMEOUT_MS);
            }
            assertTrue(findCloudletReply != null);
            assertTrue(findCloudletReply.getStatus().equals(AppClient.FindCloudletReply.FindStatus.FIND_FOUND));
        } catch (DmeDnsException dde) {
            Log.e(TAG, Log.getStackTraceString(dde));
            assertFalse("FindCloudlet: DmeDnsException", true);
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
            assertFalse("FindCloudlet: ExecutionException!", true);
        } catch (StatusRuntimeException sre) {
            /* This is expected! */
            Log.e(TAG, sre.getMessage());
            Log.e(TAG, Log.getStackTraceString(sre));
            expectedExceptionHit = true;
            assertTrue("FindCloudlet: Expected StatusRunTimeException!", true);
        } catch (InterruptedException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
            assertFalse("FindCloudlet: InterruptedException!", true);

        }

        assertFalse("findCloudletTestSetAllOptionalDevAppNameVers: NO Expected StatusRunTimeException about 'NO PERMISSION'", expectedExceptionHit);
    }

    @Test
    public void findCloudletFutureTest() {
        Context context = InstrumentationRegistry.getInstrumentation().getTargetContext();
        Future<AppClient.FindCloudletReply> response;
        AppClient.FindCloudletReply findCloudletReply1 = null;
        AppClient.FindCloudletReply findCloudletReply2 = null;
        MatchingEngine me = new MatchingEngine(context);
        //me.setUseWifiOnly(useWifiOnly);
        me.setMatchingEngineLocationAllowed(true);
        //me.setAllowSwitchIfNoSubscriberInfo(true);

        try {
            Location location = getTestLocation( 33.00,-96.54);

            registerClient(me);

            // Cannot use the older API if overriding.
            AppClient.FindCloudletRequest findCloudletRequest = me.createDefaultFindCloudletRequest(context, location)
                    //.setCarrierName(findCloudletCarrierOverride)
                    .build();

            if (useHostOverride) {
                response = me.findCloudletFuture(findCloudletRequest, hostOverride, portOverride, GRPC_TIMEOUT_MS);
            } else {
                response = me.findCloudletFuture(findCloudletRequest, 10000);
            }
            findCloudletReply1 = response.get();

            // Second try:
            me.setThreadedPerformanceTest(true);
            if (useHostOverride) {
                response = me.findCloudletFuture(findCloudletRequest, hostOverride, portOverride, GRPC_TIMEOUT_MS, MatchingEngine.FindCloudletMode.PROXIMITY);
            } else {
                response = me.findCloudletFuture(findCloudletRequest, GRPC_TIMEOUT_MS);
            }
            findCloudletReply2 = response.get();
        } catch (DmeDnsException dde) {
            Log.e(TAG, Log.getStackTraceString(dde));
            assertFalse("FindCloudletFuture: DmeDnsException", true);
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
            assertFalse("FindCloudletFuture: ExecutionExecution!", true);
        } catch (InterruptedException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
            assertFalse("FindCloudletFuture: InterruptedException!", true);

        } //finally {
          //  enableMockLocation(context,false);
        //}

        assertNotNull("FindCloudletReply1 is null!", findCloudletReply1);
        assertNotNull("FindCloudletReply2 is null!", findCloudletReply2);

        assertEquals(findCloudletReply1.getFqdn(), findCloudletReply2.getFqdn());

        assertEquals("App's expected test cloudlet Status doesn't match.", AppClient.FindCloudletReply.FindStatus.FIND_FOUND, findCloudletReply1.getStatus());

        // Might also fail, since the network is not under test control:
        assertTrue("App's expected test cloudlet FQDN doesn't match. " + findCloudletReply1.getFqdn(), foundCloudletFqdn.equals(findCloudletReply1.getFqdn()) || foundCloudletFqdn1.equals(findCloudletReply1.getFqdn()));

        try {
            String cloudletAddress = "";
            if(foundCloudletFqdn.equals(findCloudletReply1.getFqdn())){
                cloudletAddress = InetAddress.getByName(foundCloudletFqdn).getHostAddress();
            }
            if(foundCloudletFqdn1.equals(findCloudletReply1.getFqdn())){
                cloudletAddress = InetAddress.getByName(foundCloudletFqdn1).getHostAddress();
            }


            String findCloudletReplyFqdn = findCloudletReply1.getFqdn();
            String officialAddress = InetAddress.getByName(findCloudletReplyFqdn).getHostAddress();
            assertEquals("App's expected DNS resolutaion doesn't match.", cloudletAddress, officialAddress);
        } catch (UnknownHostException var6) {
            assertFalse("InetAddressFailed!", true);
        }
        assertNotNull("FindCloudletReply1 is null!", findCloudletReply1);
        assertNotNull("FindCloudletReply2 is null!", findCloudletReply2);

        // Might also fail, since the network is not under test control:
        assertEquals("App's expected test cloudlet FQDN doesn't match.", foundCloudletFqdn, findCloudletReply1.getFqdn());
        assertEquals("App's expected test cloudlet FQDN Bytes doesn't match.", foundCloudletFqdn, findCloudletReply1.getFqdnBytes().toStringUtf8());
        assertEquals("App's expected test cloudlet Ports Count doesn't match.", 5, findCloudletReply1.getPortsCount());
        assertEquals("App's expected test cloudlet Status doesn't match.", AppClient.FindCloudletReply.FindStatus.FIND_FOUND, findCloudletReply1.getStatus());
        assertEquals("App's expected test cloudlet Status Value doesn't match.", AppClient.FindCloudletReply.FindStatus.FIND_FOUND_VALUE, findCloudletReply1.getStatusValue());
        assertEquals("App's expected test cloudlet Latitude Value doesn't match.", 53.5461, findCloudletReply1.getCloudletLocation().getLatitude());
        assertEquals("App's expected test cloudlet Longitude Value doesn't match.", -113.4938, findCloudletReply1.getCloudletLocation().getLongitude());

        //assertEquals("App's expected test Port fqdn prefix doesn't match.", "sdktest90-udp.", findCloudletReply1.getPorts(0).getFqdnPrefix());
        assertEquals("App's expected test Port fqdn prefix doesn't match.", "", findCloudletReply1.getPorts(0).getFqdnPrefix());
        assertEquals("App's expected test Port endport doesn't match.", 0, findCloudletReply1.getPorts(0).getEndPort());
        assertEquals("App's expected test Port internalport doesn't match.", 2016, findCloudletReply1.getPorts(0).getInternalPort());
        assertEquals("App's expected test Port publicport doesn't match.", 2016, findCloudletReply1.getPorts(0).getPublicPort());
        assertEquals("App's expected test Port proto doesn't match.", Appcommon.LProto.L_PROTO_TCP, findCloudletReply1.getPorts(0).getProto());
        assertEquals("App's expected test Port tls doesn't match.", false, findCloudletReply1.getPorts(0).getTls());

        //assertEquals("App's expected test Port fqdn prefix doesn't match.", "automation-sdk-porttest10-tcp.", findCloudletReply1.getPorts(1).getFqdnPrefix());
        assertEquals("App's expected test Port fqdn prefix doesn't match.", "", findCloudletReply1.getPorts(1).getFqdnPrefix());
        assertEquals("App's expected test Port endport doesn't match.", 0, findCloudletReply1.getPorts(1).getEndPort());
        assertEquals("App's expected test Port internalport doesn't match.", 3765, findCloudletReply1.getPorts(1).getInternalPort());
        assertEquals("App's expected test Port publicport doesn't match.", 3765, findCloudletReply1.getPorts(1).getPublicPort());
        assertEquals("App's expected test Port proto doesn't match.", Appcommon.LProto.L_PROTO_TCP, findCloudletReply1.getPorts(1).getProto());
        assertEquals("App's expected test Port tls doesn't match.", false, findCloudletReply1.getPorts(1).getTls());

        //assertEquals("App's expected test Port fqdn prefix doesn't match.", "automation-sdk-porttest10-tcp.", findCloudletReply1.getPorts(2).getFqdnPrefix());
        assertEquals("App's expected test Port fqdn prefix doesn't match.", "", findCloudletReply1.getPorts(2).getFqdnPrefix());
        assertEquals("App's expected test Port endport doesn't match.", 0, findCloudletReply1.getPorts(2).getEndPort());
        assertEquals("App's expected test Port internalport doesn't match.", 2015, findCloudletReply1.getPorts(2).getInternalPort());
        assertEquals("App's expected test Port publicport doesn't match.", 2015, findCloudletReply1.getPorts(2).getPublicPort());
        assertEquals("App's expected test Port proto doesn't match.", Appcommon.LProto.L_PROTO_TCP, findCloudletReply1.getPorts(2).getProto());
        assertEquals("App's expected test Port tls doesn't match.", true, findCloudletReply1.getPorts(2).getTls());

        //assertEquals("App's expected test Port fqdn prefix doesn't match.", "automation-sdk-porttest10-tcp.", findCloudletReply1.getPorts(3).getFqdnPrefix());
        assertEquals("App's expected test Port fqdn prefix doesn't match.", "", findCloudletReply1.getPorts(3).getFqdnPrefix());
        assertEquals("App's expected test Port endport doesn't match.", 0, findCloudletReply1.getPorts(3).getEndPort());
        assertEquals("App's expected test Port internalport doesn't match.", 2015, findCloudletReply1.getPorts(3).getInternalPort());
        assertEquals("App's expected test Port publicport doesn't match.", 2015, findCloudletReply1.getPorts(3).getPublicPort());
        assertEquals("App's expected test Port proto doesn't match.", Appcommon.LProto.L_PROTO_UDP, findCloudletReply1.getPorts(3).getProto());
        assertEquals("App's expected test Port tls doesn't match.", false, findCloudletReply1.getPorts(3).getTls());

        //assertEquals("App's expected test Port fqdn prefix doesn't match.", "automation-sdk-porttest10-tcp.", findCloudletReply1.getPorts(3).getFqdnPrefix());
        assertEquals("App's expected test Port fqdn prefix doesn't match.", "", findCloudletReply1.getPorts(4).getFqdnPrefix());
        assertEquals("App's expected test Port endport doesn't match.", 0, findCloudletReply1.getPorts(4).getEndPort());
        assertEquals("App's expected test Port internalport doesn't match.", 8085, findCloudletReply1.getPorts(4).getInternalPort());
        assertEquals("App's expected test Port publicport doesn't match.", 8085, findCloudletReply1.getPorts(4).getPublicPort());
        assertEquals("App's expected test Port proto doesn't match.", Appcommon.LProto.L_PROTO_TCP, findCloudletReply1.getPorts(4).getProto());
        assertEquals("App's expected test Port tls doesn't match.", false, findCloudletReply1.getPorts(4).getTls());

    }

    @Test
    public void findCloudletPerformanceFutureTest() {
        Context context = InstrumentationRegistry.getInstrumentation().getTargetContext();
        Future<AppClient.FindCloudletReply> response;
        AppClient.FindCloudletReply findCloudletReply1 = null;
        AppClient.FindCloudletReply findCloudletReply2 = null;
        MatchingEngine me = new MatchingEngine(context);
        //me.setUseWifiOnly(useWifiOnly);
        me.setMatchingEngineLocationAllowed(true);
        //me.setAllowSwitchIfNoSubscriberInfo(true);

        try {
            Location location = getTestLocation( 33.00,-96.54);

            registerClient(me);

            // Cannot use the older API if overriding.
            AppClient.FindCloudletRequest findCloudletRequest = me.createDefaultFindCloudletRequest(context, location)
                    //.setCarrierName(findCloudletCarrierOverride)
                    .build();

            if (useHostOverride) {
                response = me.findCloudletFuture(findCloudletRequest, hostOverride, portOverride, GRPC_TIMEOUT_MS, MatchingEngine.FindCloudletMode.PERFORMANCE);
            } else {
                response = me.findCloudletFuture(findCloudletRequest, 10000, MatchingEngine.FindCloudletMode.PERFORMANCE);
            }
            findCloudletReply1 = response.get();

            // Second try:
            me.setThreadedPerformanceTest(true);
            if (useHostOverride) {
                response = me.findCloudletFuture(findCloudletRequest, hostOverride, portOverride, GRPC_TIMEOUT_MS, MatchingEngine.FindCloudletMode.PERFORMANCE);
            } else {
                response = me.findCloudletFuture(findCloudletRequest, GRPC_TIMEOUT_MS, MatchingEngine.FindCloudletMode.PERFORMANCE);
            }
            findCloudletReply2 = response.get();
        } catch (DmeDnsException dde) {
            Log.e(TAG, Log.getStackTraceString(dde));
            assertFalse("FindCloudletFuture: DmeDnsException", true);
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
            assertFalse("FindCloudletFuture: ExecutionExecution!", true);
        } catch (InterruptedException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
            assertFalse("FindCloudletFuture: InterruptedException!", true);

        } //finally {
        //  enableMockLocation(context,false);
        //}

        assertNotNull("FindCloudletReply1 is null!", findCloudletReply1);
        assertNotNull("FindCloudletReply2 is null!", findCloudletReply2);

        assertEquals(findCloudletReply1.getFqdn(), findCloudletReply2.getFqdn());
        Log.i(TAG, "FindCloudletReply= "+ findCloudletReply1.getStatus());
        assertEquals("App's expected test cloudlet Status doesn't match.", AppClient.FindCloudletReply.FindStatus.FIND_FOUND, findCloudletReply1.getStatus());

        // Might also fail, since the network is not under test control:
        assertEquals("App's expected test cloudlet FQDN doesn't match.", foundCloudletFqdn, findCloudletReply1.getFqdn());

        try {
            String cloudletAddress = InetAddress.getByName(foundCloudletFqdn).getHostAddress();
            String findCloudletReplyFqdn = findCloudletReply1.getFqdn();
            String officialAddress = InetAddress.getByName(findCloudletReplyFqdn).getHostAddress();
            assertEquals("App's expected DNS resolutaion doesn't match.", cloudletAddress, officialAddress);
        } catch (UnknownHostException var6) {
            assertFalse("InetAddressFailed!", true);
        }
        assertNotNull("FindCloudletReply1 is null!", findCloudletReply1);
        assertNotNull("FindCloudletReply2 is null!", findCloudletReply2);

        // Might also fail, since the network is not under test control:
        assertEquals("App's expected test cloudlet FQDN doesn't match.", foundCloudletFqdn, findCloudletReply1.getFqdn());
        assertEquals("App's expected test cloudlet FQDN Bytes doesn't match.", foundCloudletFqdn, findCloudletReply1.getFqdnBytes().toStringUtf8());
        assertEquals("App's expected test cloudlet Ports Count doesn't match.", 5, findCloudletReply1.getPortsCount());
        assertEquals("App's expected test cloudlet Status doesn't match.", AppClient.FindCloudletReply.FindStatus.FIND_FOUND, findCloudletReply1.getStatus());
        assertEquals("App's expected test cloudlet Status Value doesn't match.", AppClient.FindCloudletReply.FindStatus.FIND_FOUND_VALUE, findCloudletReply1.getStatusValue());
        assertEquals("App's expected test cloudlet Latitude Value doesn't match.", 53.5461, findCloudletReply1.getCloudletLocation().getLatitude());
        assertEquals("App's expected test cloudlet Longitude Value doesn't match.", -113.4938, findCloudletReply1.getCloudletLocation().getLongitude());

        //assertEquals("App's expected test Port fqdn prefix doesn't match.", "sdktest90-udp.", findCloudletReply1.getPorts(0).getFqdnPrefix());
        assertEquals("App's expected test Port fqdn prefix doesn't match.", "", findCloudletReply1.getPorts(0).getFqdnPrefix());
        assertEquals("App's expected test Port endport doesn't match.", 0, findCloudletReply1.getPorts(0).getEndPort());
        assertEquals("App's expected test Port internalport doesn't match.", 2016, findCloudletReply1.getPorts(0).getInternalPort());
        assertEquals("App's expected test Port publicport doesn't match.", 2016, findCloudletReply1.getPorts(0).getPublicPort());
        assertEquals("App's expected test Port proto doesn't match.", Appcommon.LProto.L_PROTO_TCP, findCloudletReply1.getPorts(0).getProto());
        assertEquals("App's expected test Port tls doesn't match.", false, findCloudletReply1.getPorts(0).getTls());

        //assertEquals("App's expected test Port fqdn prefix doesn't match.", "automation-sdk-porttest10-tcp.", findCloudletReply1.getPorts(1).getFqdnPrefix());
        assertEquals("App's expected test Port fqdn prefix doesn't match.", "", findCloudletReply1.getPorts(1).getFqdnPrefix());
        assertEquals("App's expected test Port endport doesn't match.", 0, findCloudletReply1.getPorts(1).getEndPort());
        assertEquals("App's expected test Port internalport doesn't match.", 3765, findCloudletReply1.getPorts(1).getInternalPort());
        assertEquals("App's expected test Port publicport doesn't match.", 3765, findCloudletReply1.getPorts(1).getPublicPort());
        assertEquals("App's expected test Port proto doesn't match.", Appcommon.LProto.L_PROTO_TCP, findCloudletReply1.getPorts(1).getProto());
        assertEquals("App's expected test Port tls doesn't match.", false, findCloudletReply1.getPorts(1).getTls());

        //assertEquals("App's expected test Port fqdn prefix doesn't match.", "automation-sdk-porttest10-tcp.", findCloudletReply1.getPorts(2).getFqdnPrefix());
        assertEquals("App's expected test Port fqdn prefix doesn't match.", "", findCloudletReply1.getPorts(2).getFqdnPrefix());
        assertEquals("App's expected test Port endport doesn't match.", 0, findCloudletReply1.getPorts(2).getEndPort());
        assertEquals("App's expected test Port internalport doesn't match.", 2015, findCloudletReply1.getPorts(2).getInternalPort());
        assertEquals("App's expected test Port publicport doesn't match.", 2015, findCloudletReply1.getPorts(2).getPublicPort());
        assertEquals("App's expected test Port proto doesn't match.", Appcommon.LProto.L_PROTO_TCP, findCloudletReply1.getPorts(2).getProto());
        assertEquals("App's expected test Port tls doesn't match.", true, findCloudletReply1.getPorts(2).getTls());

        //assertEquals("App's expected test Port fqdn prefix doesn't match.", "automation-sdk-porttest10-tcp.", findCloudletReply1.getPorts(3).getFqdnPrefix());
        assertEquals("App's expected test Port fqdn prefix doesn't match.", "", findCloudletReply1.getPorts(3).getFqdnPrefix());
        assertEquals("App's expected test Port endport doesn't match.", 0, findCloudletReply1.getPorts(3).getEndPort());
        assertEquals("App's expected test Port internalport doesn't match.", 2015, findCloudletReply1.getPorts(3).getInternalPort());
        assertEquals("App's expected test Port publicport doesn't match.", 2015, findCloudletReply1.getPorts(3).getPublicPort());
        assertEquals("App's expected test Port proto doesn't match.", Appcommon.LProto.L_PROTO_UDP, findCloudletReply1.getPorts(3).getProto());
        assertEquals("App's expected test Port tls doesn't match.", false, findCloudletReply1.getPorts(3).getTls());

        //assertEquals("App's expected test Port fqdn prefix doesn't match.", "automation-sdk-porttest10-tcp.", findCloudletReply1.getPorts(3).getFqdnPrefix());
        assertEquals("App's expected test Port fqdn prefix doesn't match.", "", findCloudletReply1.getPorts(4).getFqdnPrefix());
        assertEquals("App's expected test Port endport doesn't match.", 0, findCloudletReply1.getPorts(4).getEndPort());
        assertEquals("App's expected test Port internalport doesn't match.", 8085, findCloudletReply1.getPorts(4).getInternalPort());
        assertEquals("App's expected test Port publicport doesn't match.", 8085, findCloudletReply1.getPorts(4).getPublicPort());
        assertEquals("App's expected test Port proto doesn't match.", Appcommon.LProto.L_PROTO_TCP, findCloudletReply1.getPorts(4).getProto());
        assertEquals("App's expected test Port tls doesn't match.", false, findCloudletReply1.getPorts(4).getTls());

    }


}

