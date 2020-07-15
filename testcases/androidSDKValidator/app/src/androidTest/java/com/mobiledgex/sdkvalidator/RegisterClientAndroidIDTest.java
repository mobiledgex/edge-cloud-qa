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

package com.mobiledgex.sdkvalidator;

import android.app.UiAutomation;
import android.content.Context;
import android.content.pm.PackageManager;
import android.location.Location;
import android.os.Build;
import android.os.Looper;
import android.text.TextUtils;
import android.util.Log;
import android.util.Pair;
import android.provider.Settings.Secure;

import androidx.test.ext.junit.runners.AndroidJUnit4;
import androidx.test.platform.app.InstrumentationRegistry;

import com.auth0.android.jwt.Claim;
import com.auth0.android.jwt.DecodeException;
import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.gson.JsonObject;
import com.google.protobuf.ByteString;
import com.mobiledgex.matchingengine.DmeDnsException;
import com.mobiledgex.matchingengine.MatchingEngine;

import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import java.lang.reflect.Method;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;

import com.auth0.android.jwt.JWT;
import com.mobiledgex.mel.MelMessaging;

import distributed_match_engine.AppClient;
import io.grpc.StatusRuntimeException;

import static java.lang.System.getProperty;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

@RunWith(AndroidJUnit4.class)
public class RegisterClientAndroidIDTest {
    public static final String TAG = "EngineCallTest";
    public static final long GRPC_TIMEOUT_MS = 21000;

    public static final String organizationName = "MobiledgeX";
    public static final String organizationNameSamsung = "Samsung";
    // Other globals:
    //public static final String applicationName = "automation-sdk-app";
    public static final String applicationName = "automation-sdk-docker-app";
    public static final String applicationNameAuth = "automation_api_auth_app";
    public static final String applicationNameSamsung = "SamsungEnablingLayer";

    public static final String appVersion = "1.0";

    /*
    andy-mac:cloudletverification andyanderson$ genauthtoken -appname automation_api_auth_app -appvers 1.0 -devname MobiledgeX  -privkeyfile ../../certs/authtoken_private.pem
    Token:
       eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1OTQzMTg1NjQsImlhdCI6MTU5NDMxODUwNCwib3JnbmFtZSI6Ik1vYmlsZWRnZVgiLCJhcHBuYW1lIjoiYXV0b21hdGlvbl9hcGlfYXV0aF9hcHAiLCJhcHB2ZXJzIjoiMS4wIn0.cCdAhAsi4SIGiLEAuD4ire4kmeQ4VI01Mhg4Ho8uMicT3qd9TyX4ntdsVfY2spDK40rqhtZjlaunKBbrv1l1QUrZ3r-7VFskm73sx4_czNJPqu637BhdFOvq1iXptLbB3IB0OrczZhuXhgAT6dyqatHjJvj9bC-v4tdMCWYVd3C8cVoKylAqwvnGjilr5r_exnM_HxZGki_QzjBB_eQ0YJNMfJMW0VBZZbpYjriepjxj4Esg222tv0xYUVRoklTrpy92KTP3plv-3ZlDSR3PcB3KIDvV2ltSP7nvxZiKNrCLqOiW2P3NIcHa9gG000wzNM8qY7saQ6VcLzV9aF0_vQ
     */
    public static final String appAuthKey = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1OTQzMTg1NjQsImlhdCI6MTU5NDMxODUwNCwib3JnbmFtZSI6Ik1vYmlsZWRnZVgiLCJhcHBuYW1lIjoiYXV0b21hdGlvbl9hcGlfYXV0aF9hcHAiLCJhcHB2ZXJzIjoiMS4wIn0.cCdAhAsi4SIGiLEAuD4ire4kmeQ4VI01Mhg4Ho8uMicT3qd9TyX4ntdsVfY2spDK40rqhtZjlaunKBbrv1l1QUrZ3r-7VFskm73sx4_czNJPqu637BhdFOvq1iXptLbB3IB0OrczZhuXhgAT6dyqatHjJvj9bC-v4tdMCWYVd3C8cVoKylAqwvnGjilr5r_exnM_HxZGki_QzjBB_eQ0YJNMfJMW0VBZZbpYjriepjxj4Esg222tv0xYUVRoklTrpy92KTP3plv-3ZlDSR3PcB3KIDvV2ltSP7nvxZiKNrCLqOiW2P3NIcHa9gG000wzNM8qY7saQ6VcLzV9aF0_vQ";

    FusedLocationProviderClient fusedLocationClient;

    public static String hostOverride = "us-qa.dme.mobiledgex.net";
    public static String hostOverrideSamsung = "eu-qa.dme.mobiledgex.net";

    public static int portOverride = 50051;
    public static String findCloudletCarrierOverride = "TDG"; // Allow "Any" if using "", but this likely breaks test cases.

    public boolean useHostOverride = false;

    // "useWifiOnly = true" also disables network switching, since the android default is WiFi.
    // Must be set to true if you are running tests without a SIM card.
    public boolean useWifiOnly = true;

    String meluuid = MelMessaging.getUid();
    String uuidType = "Samsung:ANDROID_ID";

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

        if (Build.VERSION.SDK_INT == 24) {
            UiAutomation uiAutomation = InstrumentationRegistry.getInstrumentation().getUiAutomation();

            uiAutomation.executeShellCommand(
                    "pm grant " + InstrumentationRegistry.getInstrumentation().getTargetContext().getPackageName()
                            + " android.permission.READ_PHONE_STATE");
            uiAutomation.executeShellCommand(
                    "pm grant " + InstrumentationRegistry.getInstrumentation().getTargetContext().getPackageName()
                            + " android.permission.ACCESS_COARSE_LOCATION");
        } else {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                UiAutomation uiAutomation = InstrumentationRegistry.getInstrumentation().getUiAutomation();

                uiAutomation.grantRuntimePermission(
                        InstrumentationRegistry.getInstrumentation().getTargetContext().getPackageName(),
                        "android.permission.READ_PHONE_STATE");
                uiAutomation.grantRuntimePermission(
                        InstrumentationRegistry.getInstrumentation().getTargetContext().getPackageName(),
                        "android.permission.ACCESS_COARSE_LOCATION");
/*
            uiAutomation.grantRuntimePermission(
                    InstrumentationRegistry.getInstrumentation().getTargetContext().getPackageName(),
                    "android.permission.INTERNET");
*/
                uiAutomation.grantRuntimePermission(
                        InstrumentationRegistry.getInstrumentation().getTargetContext().getPackageName(),
                        "android.permission.ACCESS_FINE_LOCATION"
                );
            }
        }
    }


    @Test
    public void registerClientAndroidIDTest() {
        Context context = InstrumentationRegistry.getInstrumentation().getTargetContext();
        MatchingEngine me = new MatchingEngine(context);
        me.setUseWifiOnly(useWifiOnly);
        me.setMatchingEngineLocationAllowed(true);
        me.setAllowSwitchIfNoSubscriberInfo(true);

        AppClient.RegisterClientReply reply = null;

        final String androidId = Secure.getString(
                context.getContentResolver(), Secure.ANDROID_ID);
        try {
            //Location location = getTestLocation( 47.6062,122.3321);

            AppClient.RegisterClientRequest request = me.createDefaultRegisterClientRequest(context, organizationName)
                    .setAppName(applicationName)
                    .setAppVers(appVersion)
                    .setCarrierName("TDG")
                    //.setCellId(getCellId(context, me))
                    .build();
            if (useHostOverride) {
                reply = me.registerClient(request, hostOverride, portOverride, GRPC_TIMEOUT_MS);
            } else {
                String host = me.generateDmeHostAddress();
                int port = me.getPort();
                Log.i(TAG, "registerClientRequest: host="+host+" port="+port
                        +" getAppName()="+request.getAppName()
                        +" getAppVers()="+request.getAppVers()
                        +" getOrgName()="+request.getOrgName()
                        +" getCarrierName()="+request.getCarrierName());

                reply = me.registerClient(request, me.generateDmeHostAddress(), me.getPort(), GRPC_TIMEOUT_MS);
                //reply = me.registerClient(request, "eu-mexdemo.dme.mobiledgex.net", port, GRPC_TIMEOUT_MS);
            }

            JWT jwt = null;
            try {
                jwt = new JWT(reply.getSessionCookie());
            } catch (DecodeException e) {
                Log.e(TAG, Log.getStackTraceString(e));
                assertFalse("registerClientTest: DecodeException!", true);
            }

            // verify expire timer
            long difftime = (jwt.getExpiresAt().getTime() - jwt.getIssuedAt().getTime());
            assertEquals("Token expires failed:",24, TimeUnit.HOURS.convert(difftime, TimeUnit.MILLISECONDS));
            boolean isExpired = jwt.isExpired(10); // 10 seconds leeway
            assertTrue(!isExpired);

            // verify claim
            Claim c = jwt.getClaim("key");
            JsonObject claimJson = c.asObject(JsonObject.class);
            assertEquals("orgname doesn't match!", organizationName, claimJson.get("orgname").getAsString());
            assertEquals("appname doesn't match!", applicationName, claimJson.get("appname").getAsString());
            assertEquals("appvers doesn't match!", appVersion, claimJson.get("appvers").getAsString());
            assertEquals("uuid type doesn't match!", uuidType, claimJson.get("uniqueidtype").getAsString());
            assertEquals("uuid doesn't match!", androidId, claimJson.get("uniqueid").getAsString());
            //assertEquals("uuid doesn't match!", 27, claimJson.get("uniqueid").getAsString().length());
            assertTrue(claimJson.get("peerip").getAsString().matches("\\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b"));

            // verify success
            Log.i(TAG, "registerReply.getSessionCookie()="+reply.getSessionCookie());
            assertTrue(reply != null);
            assertTrue(reply.getStatus() == AppClient.ReplyStatus.RS_SUCCESS);
            assertTrue( reply.getSessionCookie().length() > 0);

            // verify uuid has DME generated values since we didnt send any values in RegisterClient
            assertEquals("uuid type doesn't match!", "", reply.getUniqueIdType());
            assertEquals("uuid doesn't match!", "", reply.getUniqueId());
            assertEquals("uuid bytes type doesn't match!", "", reply.getUniqueIdTypeBytes().toStringUtf8());
            assertEquals("uuid bytes doesn't match!", "", reply.getUniqueIdBytes().toStringUtf8());

        } catch (PackageManager.NameNotFoundException nnfe) {
            Log.e(TAG, Log.getStackTraceString(nnfe));
            assertFalse("ExecutionException registering using PackageManager.", true);
        } catch (DmeDnsException dde) {
            Log.e(TAG, Log.getStackTraceString(dde));
            assertFalse("registerClientTest: DmeDnsException!", true);
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
            assertFalse("registerClientTest: ExecutionException!", true);
        } catch (StatusRuntimeException sre) {
            Log.e(TAG, Log.getStackTraceString(sre));
            assertFalse("registerClientTest: StatusRuntimeException!", true);
        } catch (InterruptedException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
            assertFalse("registerClientTest: InterruptedException!", true);
        }

        Log.i(TAG, "registerClientTest reply: " + reply.toString());
        assertEquals(0, reply.getVer());
        assertEquals(AppClient.ReplyStatus.RS_SUCCESS, reply.getStatus());
    }


    @Test
    public void registerClientAndroidIDFutureTest() {
        Context context = InstrumentationRegistry.getInstrumentation().getTargetContext();
        MatchingEngine me = new MatchingEngine(context);
        me.setUseWifiOnly(useWifiOnly);
        me.setMatchingEngineLocationAllowed(true);
        me.setAllowSwitchIfNoSubscriberInfo(true);

        Future<AppClient.RegisterClientReply> registerReplyFuture;
        AppClient.RegisterClientReply reply = null;

        final String androidId = Secure.getString(
                context.getContentResolver(), Secure.ANDROID_ID);

        try {
            //Location location = getTestLocation( 47.6062,122.3321);

            AppClient.RegisterClientRequest request = me.createDefaultRegisterClientRequest(context, organizationName)
                    .setAppName(applicationName)
                    .setAppVers(appVersion)
                    //.setCellId(getCellId(context, me))
                    .build();
            if (useHostOverride) {
                registerReplyFuture = me.registerClientFuture(request, hostOverride, portOverride, GRPC_TIMEOUT_MS);
            } else {
                registerReplyFuture = me.registerClientFuture(request, GRPC_TIMEOUT_MS);
            }
            reply = registerReplyFuture.get();
            assert(reply != null);
        } catch (PackageManager.NameNotFoundException nnfe) {
            Log.e(TAG, Log.getStackTraceString(nnfe));
            assertFalse("ExecutionException registering using PackageManager.", true);
        } catch (DmeDnsException dde) {
            Log.e(TAG, Log.getStackTraceString(dde));
            assertFalse("ExecutionException registering client.", true);
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
            assertFalse("registerClientFutureTest: ExecutionException!", true);
        } catch (InterruptedException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
            assertFalse("registerClientFutureTest: InterruptedException!", true);
        }

        JWT jwt = null;
        try {
            jwt = new JWT(reply.getSessionCookie());
        } catch (DecodeException e) {
            Log.e(TAG, Log.getStackTraceString(e));
            assertFalse("registerClientTest: DecodeException!", true);
        }

        // verify expire timer
        long difftime = (jwt.getExpiresAt().getTime() - jwt.getIssuedAt().getTime());
        assertEquals("Token expires failed:",24, TimeUnit.HOURS.convert(difftime, TimeUnit.MILLISECONDS));
        boolean isExpired = jwt.isExpired(10); // 10 seconds leeway
        assertTrue(!isExpired);

        // verify claim
        Claim c = jwt.getClaim("key");
        JsonObject claimJson = c.asObject(JsonObject.class);
        assertEquals("orgname doesn't match!", organizationName, claimJson.get("orgname").getAsString());
        assertEquals("appname doesn't match!", applicationName, claimJson.get("appname").getAsString());
        assertEquals("appvers doesn't match!", appVersion, claimJson.get("appvers").getAsString());
        assertEquals("uuid type in claim doesn't match!", uuidType, claimJson.get("uniqueidtype").getAsString());
        assertEquals("uuid doesn't match!", androidId, claimJson.get("uniqueid").getAsString());
        //assertEquals("uuid in claim doesn't match!", 27, claimJson.get("uniqueid").getAsString().length());
        assertTrue(claimJson.get("peerip").getAsString().matches("\\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b"));

        // TODO: Validate JWT
        Log.i(TAG, "registerClientFutureTest() response: " + reply.toString());
        assertEquals(0, reply.getVer());
        assertEquals(AppClient.ReplyStatus.RS_SUCCESS, reply.getStatus());

        // verify uuid and type is empty since we sent values in RegisterClient
        assertEquals("uuid type doesn't match!", "", reply.getUniqueIdType());
        assertEquals("uuid doesn't match!", "", reply.getUniqueId());
        assertEquals("uuid bytes type doesn't match!", "", reply.getUniqueIdTypeBytes().toStringUtf8());
        assertEquals("uuid bytes doesn't match!", "", reply.getUniqueIdBytes().toStringUtf8());
    }

}

