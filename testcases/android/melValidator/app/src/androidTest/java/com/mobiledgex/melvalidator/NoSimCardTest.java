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
import android.content.pm.PackageManager;
import android.location.Location;
import android.os.Build;
import android.os.Looper;
import android.text.TextUtils;
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

import java.lang.reflect.Method;
import java.util.List;
import java.util.concurrent.ExecutionException;

import distributed_match_engine.AppClient;
import io.grpc.StatusRuntimeException;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;

/*
   run in 2 configurations:
   1) Remove SIM card and turn off wifi
   2) Remove SIM card and turn on wifi but dont connect to a network(turn off auto-reconnect)
 */
@RunWith(AndroidJUnit4.class)
public class NoSimCardTest {
    public static final String TAG = "EngineCallTest";
    public static final long GRPC_TIMEOUT_MS = 21000;

    public static final String organizationName = "MobiledgeX";
    public static final String organizationNameSamsung = "Samsung";
    // Other globals:
    public static final String applicationName = "automation_api_app";
    public static final String applicationNameAuth = "automation_api_auth_app";
    public static final String applicationNameSamsung = "SamsungEnablingLayer";

    public static final String appVersion = "1.0";

    FusedLocationProviderClient fusedLocationClient;

    public static String hostOverride = "us-qa.dme.mobiledgex.net";
    public static String hostOverrideSamsung = "eu-qa.dme.mobiledgex.net";

    public static int portOverride = 50051;
    public static String findCloudletCarrierOverride = "TDG"; // Allow "Any" if using "", but this likely breaks test cases.

    public boolean useHostOverride = true;

    // "useWifiOnly = true" also disables network switching, since the android default is WiFi.
    // Must be set to true if you are running tests without a SIM card.
    public boolean useWifiOnly = true;

    String meluuid = MelMessaging.getUid();
    String uuidType = "Samsung:SamsungEnablingLayer";

    private int getCellId(Context context, MatchingEngine me) {
        int cellId = 0;
        List<Pair<String, Long>> cellIdList = me.retrieveCellId(context);
        if (cellIdList != null && cellIdList.size() > 0) {
            cellId = cellIdList.get(0).second.intValue();
        }
        return cellId;
    }

    private Location getTestLocation(double latitude, double longitude) {
        Location location = new Location("MobiledgeX_Test");
        location.setLatitude(latitude);
        location.setLongitude(longitude);
        return location;
    }

    public static String getSystemProperty(String property, String defaultValue) {
        try {
            Class sysPropCls = Class.forName("android.os.SystemProperties");
            Method getMethod = sysPropCls.getDeclaredMethod("get", String.class);
            String value = (String)getMethod.invoke(null, property);
            if (!TextUtils.isEmpty(value)) {
                return value;
            }
        } catch (Exception e) {
            Log.e(TAG, "Unable to read system properties.");
            e.printStackTrace();
        }
        return defaultValue;
    }

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


    @Test
    public void melDisabledTest() {
        boolean melenabled = MelMessaging.isMelEnabled();
        assertFalse("mel not disabled", melenabled);
    }

    @Test
    public void registerClientNoSimCardTest() {
        Context context = InstrumentationRegistry.getInstrumentation().getTargetContext();
        MatchingEngine me = new MatchingEngine(context);
        //me.setUseWifiOnly(useWifiOnly);
        me.setMatchingEngineLocationAllowed(true);
        //me.setAllowSwitchIfNoSubscriberInfo(true);

        AppClient.RegisterClientReply reply = null;

        try {
            Location location = getTestLocation( 47.6062,122.3321);

            AppClient.RegisterClientRequest request = me.createDefaultRegisterClientRequest(context, organizationName)
                    .setAppName(applicationName)
                    .setAppVers(appVersion)
                    //.setCellId(getCellId(context, me))
                    .build();

            reply = me.registerClient(request, GRPC_TIMEOUT_MS);
            assertFalse("registerClient passed", true);

        } catch (PackageManager.NameNotFoundException nnfe) {
            Log.e(TAG, Log.getStackTraceString(nnfe));
            assertFalse("ExecutionException registering using PackageManager.", true);
        } catch (DmeDnsException dde) {
            Log.e(TAG, Log.getStackTraceString(dde));
            //assertEquals("SIM not in ready state.", dde.getLocalizedMessage());
            assertFalse("registerClientTest: DmeDnsException!", true);
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
            assertEquals("com.mobiledgex.matchingengine.NetworkRequestTimeoutException: NetworkRequest timed out with no availability.", ee.getLocalizedMessage());
        } catch (StatusRuntimeException sre) {
            Log.e(TAG, Log.getStackTraceString(sre));
            assertFalse("registerClientTest: StatusRuntimeException!", true);
        } catch (InterruptedException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
            assertFalse("registerClientTest: InterruptedException!", true);
        }

    }

    @Test
    public void findCloudletNoSimCardTest() {
        Context context = InstrumentationRegistry.getInstrumentation().getTargetContext();
        AppClient.FindCloudletReply findCloudletReply1 = null;
        AppClient.FindCloudletReply findCloudletReply2 = null;
        MatchingEngine me = new MatchingEngine(context);
        //me.setUseWifiOnly(useWifiOnly);
        me.setMatchingEngineLocationAllowed(true);
        //me.setAllowSwitchIfNoSubscriberInfo(true);

        try {
            Location location = getTestLocation( 47.6062,122.3321);

            AppClient.FindCloudletRequest findCloudletRequest = me.createDefaultFindCloudletRequest(context, location)
                    .setCarrierName(findCloudletCarrierOverride)
                    .build();


            findCloudletReply1 = me.findCloudlet(findCloudletRequest, GRPC_TIMEOUT_MS);
            assertFalse("findCloudlet passed", true);

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
        //} catch (PackageManager.NameNotFoundException ee) {
        //    Log.e(TAG, Log.getStackTraceString(ee));
        //    assertFalse("FindCloudlet: ExecutionException!", true);

        } catch (InterruptedException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
            assertFalse("FindCloudlet: InterruptedException!", true);
        } catch (IllegalArgumentException iae) {
            Log.e(TAG, Log.getStackTraceString(iae));
            assertEquals("An unexpired RegisterClient sessionCookie is required.", iae.getLocalizedMessage());

        }

    }


}

