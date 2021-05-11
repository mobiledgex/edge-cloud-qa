package com.mobiledgex.sdkexerciser;

import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffColorFilter;
import android.location.Location;
import android.net.ConnectivityManager;
import android.net.Network;
import android.net.NetworkCapabilities;
import android.net.NetworkInfo;
import android.os.AsyncTask;
import android.os.Bundle;

import com.auth0.android.jwt.Claim;
import com.auth0.android.jwt.DecodeException;
import com.google.android.material.floatingactionbutton.FloatingActionButton;
import com.google.android.material.snackbar.Snackbar;
import com.google.gson.JsonObject;
import com.mobiledgex.matchingengine.AppConnectionManager;
import com.mobiledgex.matchingengine.DmeDnsException;
import com.mobiledgex.matchingengine.MatchingEngine;
import com.mobiledgex.matchingengine.util.RequestPermissions;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;

import android.os.NetworkOnMainThreadException;
import android.util.Log;
import android.util.TypedValue;
import android.view.View;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

import java.io.IOException;
import java.net.InetAddress;
import java.net.Socket;
import java.net.UnknownHostException;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;

import distributed_match_engine.AppClient;
import distributed_match_engine.Appcommon;
import io.grpc.StatusRuntimeException;

import com.auth0.android.jwt.JWT;
import com.mobiledgex.mel.MelMessaging;
//import static org.junit.Assert.assertEquals;

/*
this is for DT sim card
edgectl controller --addr mexdemo-us.ctrl.mobiledgex.net:55001 --tls ~/mex-ca.crt CreateOperatorCode  code=310260 organization=TELUS

edgectl controller --addr mexdemo-us.ctrl.mobiledgex.net:55001 --tls ~/mex-ca.crt CreateApp appname=automation-sdk-docker-app2 app-org=MobiledgeX appvers=1.0 imagepath=docker.mobiledgex.net/adevorg/images/server-ping-threaded:6.0 accessports=tcp:1234,udp:1,tcp:1-5:tls,tcp:8080 deployment=docker defaultflavor=x1.medium androidpackagename=com.mobiledgex.sdkexerciser officialfqdn=stackoverflow1.com
edgectl controller --addr mexdemo-us.ctrl.mobiledgex.net:55001 --tls ~/mex-ca.crt CreateAppInst appname=automation-sdk-docker-app2 app-org=MobiledgeX appvers=1.0 cloudlet=cerustfake cloudlet-org=TELUS  cluster-org=MobiledgeX cluster=autoclustersdkdocker2

 */
public class MainActivity extends AppCompatActivity {

    private static final String TAG = "MainActivity";
    public static final long GRPC_TIMEOUT_MS = 21000;
    private MatchingEngine matchingEngine;
    private RequestPermissions mRpUtil;

    private String appName = "automation-sdk-docker-app2";
    private String appVersion = "1.0";

    //private String appName = "MobiledgeX SDK Demo";
    //private String appVersion = "2.0";

    private String organizationName = "MobiledgeX";

    private String uuidType = "platos:platosEnablingLayer";

    public static String foundCloudletFqdn = "autoclustersdkdocker2.cerustfake.cerust.mobiledgex.net";
    public static String officialFqdn = "stackoverflow1.com";
    public int transportType = -1;

    private Activity ctx;

    private String host;
    private int port;

    private AppClient.FindCloudletReply mClosestCloudlet;

    private TextView mTextView;
    private LinearLayout mButtonLayout;
    private String statusText = "";

    private int testCount = 0;
    private Button[] testList = new Button[100];

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        mTextView = findViewById(R.id.textView);
        mButtonLayout = findViewById(R.id.linear_layout_buttons);

        //FloatingActionButton fab = findViewById(R.id.fab);
        //fab.setOnClickListener(new View.OnClickListener() {
        //    @Override
        //    public void onClick(View view) {
        //        Snackbar.make(view, "Replace with your own action", Snackbar.LENGTH_LONG)
        //                .setAction("Action", null).show();
        //    }
        //});
        //fab.setVisibility(View.INVISIBLE);

        ctx = this;
        mRpUtil = new RequestPermissions();

        addWifiInfo();

        addMelInfo();

        addButton("RegisterClient");
        //addButton("RegisterClientMissingOrg");
        //addButton("RegisterClientEmptyAppVers");
        boolean melenabled = MelMessaging.isMelEnabled();
        if (melenabled) {
            addButton("FindCloudlet MEL Enabled");
            addButton("RegisterClientFindCloudlet MEL Enabled");
        } else {
            addButton("FindCloudlet MEL Disabled");
            addButton("RegisterClientFindCloudlet MEL Disabled");
        }
        //addButton("FindCloudletBadAppName");
        //addButton("VerifyLocationSuccess");
        //addButton("RegisterAndFindCloudlet");


        addButton("RunAllTests");

    }

    private void addWifiInfo() {
        ConnectivityManager connectivityManager = (ConnectivityManager) super.getSystemService(Context.CONNECTIVITY_SERVICE);
        //NetworkInfo mWifi = connectivityManager.getNetworkInfo(ConnectivityManager.TYPE_WIFI);
        //boolean wifiEnabled = mWifi.isConnected();

        //Network net = connectivityManager.getActiveNetwork();
        NetworkCapabilities cap = connectivityManager.getNetworkCapabilities(connectivityManager.getActiveNetwork());

        LinearLayout.LayoutParams lparams = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT);

        TextView wifistatus = new TextView(this);
        wifistatus.setLayoutParams(lparams);
        if (cap == null) {
            //transportType = -2;
            wifistatus.setText("NO Wifi/cellular data Connected");
        } else {
            if (cap.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR)) {
                transportType = NetworkCapabilities.TRANSPORT_CELLULAR;
                wifistatus.setText("Cellular data Connected");
            } else if (cap.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)) {
                wifistatus.setText("Wifi data Connected");
                transportType = NetworkCapabilities.TRANSPORT_WIFI;
            } else {
                wifistatus.setText("Cannnot determine data connection");
            }
        }
//        if(wifiEnabled) {
//            wifistatus.setText("WIFI Connected: Yes");
//        } else {
//           wifistatus.setText("WIFI Connected: No");
//        }
        wifistatus.setPadding(20, 20, 20, 20);
        wifistatus.setTextSize(TypedValue.COMPLEX_UNIT_SP, 18);
        mButtonLayout.addView(wifistatus);

    }

    //private boolean isConnectedViaWifi() {
    //    ConnectivityManager connectivityManager = (ConnectivityManager) super.getSystemService(Context.CONNECTIVITY_SERVICE);
    //    NetworkInfo mWifi = connectivityManager.getNetworkInfo(ConnectivityManager.TYPE_WIFI);
    //    return mWifi.isConnected();
    //}

    private void addMelInfo() {
        LinearLayout.LayoutParams lparams = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT);

        boolean melenabled = MelMessaging.isMelEnabled();
        String meluuid = MelMessaging.getUid();
        String melVersion = MelMessaging.getMelVersion();
        String melCookie = MelMessaging.getCookie("automation-sdk-docker-app");

        TextView melstatus = new TextView(this);
        melstatus.setLayoutParams(lparams);
        if(melenabled) {
            melstatus.setText("MEL Enabled: Yes");
        } else {
            melstatus.setText("MEL Enabled: No");
        }
        melstatus.setPadding(20, 20, 20, 20);
        melstatus.setTextSize(TypedValue.COMPLEX_UNIT_SP, 18);
        mButtonLayout.addView(melstatus);

        TextView meluuidv = new TextView(this);
        meluuidv.setLayoutParams(lparams);
        meluuidv.setPadding(20, 20, 20, 20);
        meluuidv.setTextSize(TypedValue.COMPLEX_UNIT_SP, 18);
        meluuidv.setText("MEL UUID: " + meluuid);
        mButtonLayout.addView(meluuidv);

        TextView melversionv = new TextView(this);
        melversionv.setLayoutParams(lparams);
        melversionv.setPadding(20, 20, 20, 20);
        melversionv.setTextSize(TypedValue.COMPLEX_UNIT_SP, 18);
        melversionv.setText("MEL Version: " + melVersion);
        mButtonLayout.addView(melversionv);

        //TextView melcookiev = new TextView(this);
        //melcookiev.setLayoutParams(lparams);
        //melcookiev.setPadding(20, 20, 20, 20);
        //melcookiev.setTextSize(TypedValue.COMPLEX_UNIT_SP, 18);
        //melcookiev.setText("MEL Cookie: " + melCookie);
        //mButtonLayout.addView(melcookiev);

    }

    private void addButton(final String testcaseName) {
        final Button button = new Button(this);
        button.setText(testcaseName);
        button.setTransformationMethod(null);
        button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                new BackgroundRequest().executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR, button, testcaseName);
            }
        });
        mButtonLayout.addView(button);
        testList[testCount] = button;
        testCount = testCount + 1;
    }

    private void setStatusText(final String text) {
        Log.i(TAG, text);
        statusText = text;
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                mTextView.setText(text);
            }
        });

    }

    private void appendStatusText(final String text) {
        Log.i(TAG, text);
        statusText = text;
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                mTextView.setText(mTextView.getText() + "\n" + text);
            }
        });

    }

    private void setTestcasePassed(final boolean passed, final Button button) {
        Log.i(TAG, "setTestcasePassed("+passed+")");
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (passed) {
                    button.getBackground().setColorFilter(new PorterDuffColorFilter(Color.GREEN, PorterDuff.Mode.MULTIPLY));
                } else {
                    button.getBackground().setColorFilter(new PorterDuffColorFilter(Color.RED, PorterDuff.Mode.MULTIPLY));
                }
            }
        });

    }

    private void setTestcaseCleared(final Button button) {
        Log.i(TAG, "setTestcaseCleared");
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                button.getBackground().setColorFilter(new PorterDuffColorFilter(Color.LTGRAY, PorterDuff.Mode.MULTIPLY));
            }
        });

    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            Snackbar.make(mTextView, "There are no settings", Snackbar.LENGTH_LONG).show();
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    @Override
    protected void onResume() {
        super.onResume();
        /*
         * Check permissions here, as the user has the ability to change them on the fly through
         * system settings
         */
        if (mRpUtil.getNeededPermissions(this).size() > 0) {
            // Opens a UI. When it returns, onResume() is called again.
            mRpUtil.requestMultiplePermissions(this);
            return;
        }
        // Ensures that user can switch from wifi to cellular network data connection (required to verifyLocation)
        matchingEngine = new MatchingEngine(this);
        MatchingEngine.setMatchingEngineLocationAllowed(true);

        matchingEngine.setNetworkSwitchingEnabled(false);  //false-> wifi (Use wifi for demo)
    }

    private AppClient.RegisterClientReply registerClient(String appName, String orgName, String appVersion) throws ExecutionException, InterruptedException,
            io.grpc.StatusRuntimeException, DmeDnsException, PackageManager.NameNotFoundException {

        AppClient.RegisterClientReply registerStatus = null;

        //MatchingEngine.setMatchingEngineLocationAllowed(true);

        host = matchingEngine.generateDmeHostAddress();
        if(host == null) {
            Log.e(TAG, "Could not generate host");
            host = "wifi.dme.mobiledgex.net";   //fallback host
        }
        //host = "wifi.dme.mobiledgex.net";
        //Log.i(TAG, "host="+host);
        port = matchingEngine.getPort(); // Keep same port.
        try {
            AppClient.RegisterClientRequest registerClientRequest;
            registerClientRequest = matchingEngine.createDefaultRegisterClientRequest(ctx, orgName)
                    //.setAppName(appName).setAppVers(appVersion)
                    .build();
            //AppClient.RegisterClientReply registerStatus
            //        = matchingEngine.registerClient(registerClientRequest, host, port, 10000);
            registerStatus = matchingEngine.registerClient(registerClientRequest, 10000);
            Log.i(TAG, "registerClientRequest="+registerClientRequest);
            Log.i(TAG, "registerStatus.getStatus()="+registerStatus.getStatus());
        } catch (PackageManager.NameNotFoundException nnfe) {
            Log.e(TAG, Log.getStackTraceString(nnfe));
            //assertFalse("ExecutionException registering using PackageManager.", true);
        } catch (DmeDnsException dde) {
            Log.e(TAG, Log.getStackTraceString(dde));
            //assertFalse("registerClientTest: DmeDnsException!", true);
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
            throw new AssertionError(ee.getLocalizedMessage());
            //assertEquals("com.mobiledgex.matchingengine.NetworkRequestTimeoutException: NetworkRequest timed out with no availability.", ee.getLocalizedMessage());
        } catch (StatusRuntimeException sre) {
            Log.e(TAG, Log.getStackTraceString(sre));
            //assertFalse("registerClientTest: StatusRuntimeException!", true);
        } catch (InterruptedException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
            //assertFalse("registerClientTest: InterruptedException!", true);
        }


        if (registerStatus.getStatus() != AppClient.ReplyStatus.RS_SUCCESS) {
            setStatusText("Registration Failed. Error: " + registerStatus.getStatus());
        //    return false;
        }
        setStatusText("SessionCookie:" + registerStatus.getSessionCookie());

        return registerStatus;

        //return true;
    }

    public AppClient.FindCloudletReply findCloudlet(Location loc) throws ExecutionException, InterruptedException, PackageManager.NameNotFoundException {
        AppClient.FindCloudletRequest findCloudletRequest;

        try {
            findCloudletRequest = matchingEngine.createDefaultFindCloudletRequest(ctx, loc).build();
            mClosestCloudlet = matchingEngine.findCloudlet(findCloudletRequest, host, port, 10000);


            if (mClosestCloudlet.getStatus() != AppClient.FindCloudletReply.FindStatus.FIND_FOUND) {
                setStatusText("findCloudlet Failed. Error: " + mClosestCloudlet.getStatus());
                //return false;
            }
            Log.i(TAG, "REQ_FIND_CLOUDLET mClosestCloudlet.uri=" + mClosestCloudlet.getFqdn());

            // Populate cloudlet details.
            String statusText = "";
            statusText += "Lat,Lng=(" + mClosestCloudlet.getCloudletLocation().getLatitude();
            statusText += "," + mClosestCloudlet.getCloudletLocation().getLongitude() + ")\n";
            statusText += "FQDN=" + mClosestCloudlet.getFqdn() + "\n";

            // Extract cloudlet name from FQDN
            //String[] parts = mClosestCloudlet.getFqdn().split("\\.");
            //statusText += parts[0];

            //Find FqdnPrefix from Port structure.
            String FqdnPrefix = "";
            statusText += "Ports:";
            List<distributed_match_engine.Appcommon.AppPort> ports = mClosestCloudlet.getPortsList();
            String appPortFormat = "{Protocol: %d, FqdnPrefix: %s, Container Port: %d, External Port: %d, Public Path: '%s'}";
            for (Appcommon.AppPort aPort : ports) {
                FqdnPrefix = aPort.getFqdnPrefix();
                statusText += String.format(Locale.getDefault(), appPortFormat,
                        aPort.getProto().getNumber(),
                        aPort.getFqdnPrefix(),
                        aPort.getInternalPort(),
                        aPort.getPublicPort(),
                        aPort.getPathPrefix());
            }
            // Build full hostname.
            //statusText += "\n" + FqdnPrefix + mClosestCloudlet.getFqdn() + "\n";
            setStatusText(statusText);
        //} catch (DmeDnsException dde) {
        //    Log.e(TAG, Log.getStackTraceString(dde));
            //assertFalse("FindCloudlet: DmeDnsException", true);
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
            //assertFalse("FindCloudlet: ExecutionException!", true);
            //} catch (PackageManager.NameNotFoundException ee) {
            //    Log.e(TAG, Log.getStackTraceString(ee));
            //    assertFalse("FindCloudlet: ExecutionException!", true);
        } catch (StatusRuntimeException sre) {
            Log.e(TAG, sre.getMessage());
            Log.e(TAG, Log.getStackTraceString(sre));
            //assertFalse("FindCloudlet: StatusRunTimeException!", true);
        } catch (IllegalArgumentException iae) {
            Log.e(TAG, Log.getStackTraceString(iae));
            throw new AssertionError(iae.getLocalizedMessage());
        } catch (InterruptedException ie) {
            Log.e(TAG, Log.getStackTraceString(ie));
            //assertFalse("FindCloudlet: InterruptedException!", true);
        }

        return mClosestCloudlet;

        //return true;
    }

    public AppClient.FindCloudletReply registerAndFindCloudlet(String appName, String orgName, String appVersion, String carrierName, Location location) throws ExecutionException, InterruptedException {
        //MatchingEngine.setMatchingEngineLocationAllowed(true);
        //matchingEngine.setAllowSwitchIfNoSubscriberInfo(true);

        try {
            //AppConnectionManager appConnectionManager = matchingEngine.getAppConnectionManager();
            Future<AppClient.FindCloudletReply> findCloudletReplyFuture = matchingEngine.registerAndFindCloudlet(ctx, orgName, appName, appVersion, location, null, 0, null, null, null);
            // Just wait:
            mClosestCloudlet = findCloudletReplyFuture.get();
            //HashMap<Integer, Appcommon.AppPort> appTcpPortMap = appConnectionManager.getTCPMap(findCloudletReply);
            //Appcommon.AppPort appPort = appTcpPortMap.get(3001);
            //Future<Socket> socketFuture = matchingEngine.getAppConnectionManager().getTcpSocket(findCloudletReply, appPort, appPort.getPublicPort(), (int)GRPC_TIMEOUT_MS);
            //Socket socket = socketFuture.get();
        } catch (ExecutionException ee) {
            Log.e(TAG, Log.getStackTraceString(ee));
            throw new AssertionError(ee.getLocalizedMessage());
        }

        if (mClosestCloudlet.getStatus() != AppClient.FindCloudletReply.FindStatus.FIND_FOUND) {
            setStatusText("findCloudlet Failed. Error: " + mClosestCloudlet.getStatus());
            //return false;
        }
        Log.i(TAG, "REQ_FIND_CLOUDLET mClosestCloudlet.uri=" + mClosestCloudlet.getFqdn());

        // Populate cloudlet details.
        String statusText = "";
        statusText += "Lat,Lng=(" + mClosestCloudlet.getCloudletLocation().getLatitude();
        statusText += "," + mClosestCloudlet.getCloudletLocation().getLongitude() + ")\n";
        statusText += "FQDN=" + mClosestCloudlet.getFqdn() + "\n";

        // Extract cloudlet name from FQDN
        //String[] parts = mClosestCloudlet.getFqdn().split("\\.");
        //statusText += parts[0];

        //Find FqdnPrefix from Port structure.
        String FqdnPrefix = "";
        statusText += "Ports:";
        List<distributed_match_engine.Appcommon.AppPort> ports = mClosestCloudlet.getPortsList();
        String appPortFormat = "{Protocol: %d, FqdnPrefix: %s, Container Port: %d, External Port: %d, Public Path: '%s'}";
        for (Appcommon.AppPort aPort : ports) {
            FqdnPrefix = aPort.getFqdnPrefix();
            statusText += String.format(Locale.getDefault(), appPortFormat,
                    aPort.getProto().getNumber(),
                    aPort.getFqdnPrefix(),
                    aPort.getInternalPort(),
                    aPort.getPublicPort(),
                    aPort.getPathPrefix());
        }
        // Build full hostname.
        //statusText += "\n" + FqdnPrefix + mClosestCloudlet.getFqdn() + "\n";
        setStatusText(statusText);

        return mClosestCloudlet;
        //return true;
    }

    private boolean verifyLocation(Location loc, String carrierName) throws InterruptedException, IOException, ExecutionException {
        AppClient.VerifyLocationRequest verifyLocationRequest
                = matchingEngine.createDefaultVerifyLocationRequest(ctx, loc)
                .setCarrierName(carrierName).build();
        if (verifyLocationRequest != null) {
            try {
                AppClient.VerifyLocationReply verifyLocationReply = matchingEngine.verifyLocation(verifyLocationRequest, host, port, 10000);
                setStatusText("[Location Verified: Tower: " + verifyLocationReply.getTowerStatus() +
                        ", GPS LocationStatus: " + verifyLocationReply.getGpsLocationStatus() +
                        ", Location Accuracy: " + verifyLocationReply.getGpsLocationAccuracyKm() + " ]");
                return true;
            } catch(NetworkOnMainThreadException ne) {
                setStatusText("Network thread exception");
                return false;
            }
        } else {
            setStatusText("Cannot verify location");
            return false;
        }
    }
    private void clickTestButton(final int i) {
        int delay = 1000 + (i *1000);
        testList[testCount - 1].postDelayed(new Runnable() {
            @Override
            public void run() {
                testList[i].performClick();
            }
        },delay);
    }

    private void clearTestButton(final int i) {
        setTestcaseCleared(testList[i]);
    }

    private void clearTestButton(Button b) {
        setTestcaseCleared(b);
    }

    public class BackgroundRequest extends AsyncTask<Object, Void, Void> {
        @Override
        protected Void doInBackground(Object... params) {
            Button button = (Button) params[0];
            String testCaseName = (String) params[1];
            Location location = new Location("MobiledgeX");
            location.setLatitude(52.52);
            location.setLongitude(13.4040);    //Beacon

            boolean tcPassed = false;
            String passMessage = "";


            Log.i(TAG, "BackgroundRequest testCaseName="+testCaseName);
            clearTestButton(button);
            try {
                switch (testCaseName) {
                    case "RegisterClient":
                        try {
                            tcPassed = runRegisterClientTest();
                        } catch (AssertionError e) {
                            Log.e(TAG, e.toString());
                            appendStatusText(e.toString());
                            if (transportType == -1) {
                                passMessage = "java.lang.AssertionError: com.mobiledgex.matchingengine.NetworkRequestTimeoutException: NetworkRequest timed out with no availability.";
                            }
                        }
                        break;

/*
                    case "RegisterClientMissingOrg":
                        passMessage = "RegisterClientRequest requires a organization name.";
                        registerClient(appName, "", "2.0");
                        break;

                    case "RegisterClientEmptyAppVers":
                        passMessage = "INVALID_ARGUMENT: AppVers cannot be empty";
                        registerClient(appName, "MobiledgeX", "");
                        break;
*/


                    case "FindCloudlet MEL Enabled":
                    case "RegisterClientFindCloudlet MEL Enabled":
                        try {
                            tcPassed = runFindCloudletTestMelEnabled(location, testCaseName);
                        } catch (AssertionError e) {
                            Log.e(TAG, e.toString());
                            appendStatusText(e.toString());
                        }
                        break;

                    case "FindCloudlet MEL Disabled":
                    case "RegisterClientFindCloudlet MEL Disabled":
                        try {
                            tcPassed = runFindCloudletTestMelDisabled(location, testCaseName);
                        } catch (AssertionError e) {
                            Log.e(TAG, e.toString());
                            appendStatusText(e.getLocalizedMessage());
                            if (transportType == -1) {
                                passMessage = "NetworkRequest timed out with no availability.";
                            }

                        }

                        //registerClient(appName, "MobiledgeX", "2.0");
                        //tcPassed = findCloudlet(location);
                        break;

                    case "FindCloudletBadAppName":
                        passMessage = "NOT_FOUND: app not found";
                        registerClient(appName, "MobiledgeX", "1.0");
                        findCloudlet(location);
                        break;

                    case "VerifyLocationSuccess":
                        registerClient("MobiledgeX SDK Demo", "MobiledgeX", "2.0");
                        tcPassed = verifyLocation(location, "GDDT");
                        break;

                    //case "RegisterAndFindCloudlet":
                    //    tcPassed = registerAndFindCloudlet("MobiledgeX SDK Demo", "MobiledgeX", "2.0", "GDDT", location);
                    //    break;

                    case "RunAllTests":
                        passMessage = "nopass";
                        for(int i=0; i<testCount; i++) {
                            Log.i(TAG, "clickbutton"+i);
                            clearTestButton(i);
                        }

                        for(int i=0; i<testCount-1; i++) {
                            Log.i(TAG, "clickbutton"+i);
                            clickTestButton(i);
                        }
                        //new Handler().postDelayed(new Runnable() {
                        //    @Override
                        //    public void run() {
                        //        testList[0].performClick();
                        //    }
                        //}, 5000);

                        //testList[0].performClick();
                        break;

                    default:
                        Log.e(TAG, "Unknown testCaseName: "+testCaseName);
                }

            } catch (StatusRuntimeException | IllegalArgumentException | ExecutionException | InterruptedException | DmeDnsException | PackageManager.NameNotFoundException | IOException exc) {
                setStatusText(exc.getMessage());
                exc.printStackTrace();
            }

            Log.i(TAG, "passMessage="+passMessage);
            Log.i(TAG, "statusText="+statusText);
            if (passMessage.length() > 0) {
                tcPassed = statusText.contains(passMessage);
            }
            if (testCaseName != "RunAllTests") {
                setTestcasePassed(tcPassed, button);
            }
            return null;
        }
    }

    private boolean runRegisterClientTest() {
        try {
            AppClient.RegisterClientReply reply = registerClient(appName, "MobiledgeX", "2.0");

            JWT jwt = null;
            try {
                jwt = new JWT(reply.getSessionCookie());
            } catch (DecodeException e) {
                Log.e(TAG, Log.getStackTraceString(e));
                setStatusText(Log.getStackTraceString(e));
                //assert "registerClientTest: DecodeException!" == true;
            }

            if (0 != reply.getVer()) throw new AssertionError("reply vers does not match");
            if (AppClient.ReplyStatus.RS_SUCCESS != reply.getStatus()) throw new AssertionError("reply status does not match");

            // verify uuid and type is empty since we sent values in RegisterClient
            if (!reply.getUniqueIdType().equals("")) throw new AssertionError("reply uuid type does not match");
            if (!reply.getUniqueId().equals("")) throw new AssertionError("reply uuid does not match");
            if (!reply.getUniqueIdTypeBytes().toStringUtf8().equals("")) throw new AssertionError("reply uuidtype bytes does not match");
            if (!reply.getUniqueIdBytes().toStringUtf8().equals("")) throw new AssertionError("reply uuid bytes does not match");

            long difftime = (jwt.getExpiresAt().getTime() - jwt.getIssuedAt().getTime());
            if (TimeUnit.HOURS.convert(difftime, TimeUnit.MILLISECONDS) != 24)
                throw new AssertionError("jwt time does not match");
            if (jwt.isExpired(10) == true)
                throw new AssertionError("jwt expired"); // 10 seconds leeway

            // verify claim
            Claim c = jwt.getClaim("key");
            JsonObject claimJson = c.asObject(JsonObject.class);
            if (!claimJson.get("orgname").getAsString().equals(organizationName)) throw new AssertionError("claim orgname does not match. Got " + claimJson.get("orgname").getAsString() + " expected " + organizationName);
            if (!claimJson.get("appname").getAsString().equals(appName)) throw new AssertionError("claim appname does not match");
            if (!claimJson.get("appvers").getAsString().equals(appVersion)) throw new AssertionError("claim appvers does not match");
            if (!claimJson.get("uniqueidtype").getAsString().equals(uuidType)) throw new AssertionError("claim uuidtype does not match");
            if (27 != claimJson.get("uniqueid").getAsString().length()) throw new AssertionError("claim uuid does not match");
            if (!claimJson.get("peerip").getAsString().matches("\\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b")) throw new AssertionError("claim peerip does not match");

            //assert (!isExpired);
        } catch (ExecutionException | InterruptedException | DmeDnsException | PackageManager.NameNotFoundException exc) {
            setStatusText(exc.getMessage());
            exc.printStackTrace();
            return false;
        }

        return true;

    }

    private boolean runFindCloudletTestMelEnabled(Location location, String testcaseName) {
        AppClient.FindCloudletReply reply = null;

        try {
            if (testcaseName.equals("FindCloudlet MEL Enabled")) {
                runRegisterClientTest();
                reply = findCloudlet(location);
            } else if (testcaseName.equals("RegisterClientFindCloudlet MEL Enabled")) {
                reply = registerAndFindCloudlet(appName,organizationName, appVersion, null, location);
            } else {
                throw new AssertionError("Unknown test:" + testcaseName);
            }

        } catch (ExecutionException | InterruptedException | PackageManager.NameNotFoundException exc) {
            setStatusText(exc.getMessage());
            exc.printStackTrace();
        }

        try {
            String cloudletAddress = InetAddress.getByName(foundCloudletFqdn).getHostAddress();
            String findCloudletReplyFqdn = reply.getFqdn();
            String officialAddress = InetAddress.getByName(findCloudletReplyFqdn).getHostAddress();

            if (!officialAddress.equals(cloudletAddress)) throw new AssertionError("IP address does not match officialfqdn=" + officialAddress + ". cloudletAddress=" + cloudletAddress);
        } catch (UnknownHostException var6) {
            throw new AssertionError("caught UnknownHostException");
        }
        if (null == reply) throw new AssertionError("FindCloudlet is null");

        if (!reply.getFqdn().equals(officialFqdn)) throw new AssertionError("App's expected test cloudlet FQDN doesn't match. Got " + reply.getFqdn() + " expected " + officialFqdn);
        if (!reply.getFqdnBytes().toStringUtf8().equals(officialFqdn)) throw new AssertionError("App's expected test cloudlet FQDN Bytes doesn't match.");
        if (1 != reply.getPortsCount()) throw new AssertionError("App's expected test cloudlet Ports Count doesn't match.");

        if (!reply.getPorts(0).getFqdnPrefix().equals("")) throw new AssertionError("App's expected test Port fqdn prefix doesn't match.");
        if (0 != reply.getPorts(0).getEndPort()) throw new AssertionError("App's expected test Port endport doesn't match.");
        if (0 != reply.getPorts(0).getInternalPort()) throw new AssertionError("App's expected test Port internalport doesn't match.");
        if (0 != reply.getPorts(0).getPublicPort()) throw new AssertionError("App's expected test Port publicport doesn't match.");
        if (Appcommon.LProto.L_PROTO_UNKNOWN != reply.getPorts(0).getProto()) throw new AssertionError("App's expected test Port proto doesn't match.");
        if (false != reply.getPorts(0).getTls()) throw new AssertionError("App's expected test Port tls doesn't match.");
        if (1 != reply.getPortsCount()) throw new AssertionError("App's expected test cloudlet Ports Count doesn't match.");
        if (AppClient.FindCloudletReply.FindStatus.FIND_FOUND != reply.getStatus()) throw new AssertionError("App's expected test cloudlet Status doesn't match.");
        if (AppClient.FindCloudletReply.FindStatus.FIND_FOUND_VALUE != reply.getStatusValue()) throw new AssertionError("App's expected test cloudlet Status Value doesn't match.");

        return true;

    }

    private boolean runFindCloudletTestMelDisabled(Location location, String testcaseName) {
        AppClient.FindCloudletReply reply = null;

        try {
            if (testcaseName.equals("FindCloudlet MEL Disabled")) {
                runRegisterClientTest();
                reply = findCloudlet(location);
            } else if (testcaseName.equals("RegisterClientFindCloudlet MEL Disabled")) {
                reply = registerAndFindCloudlet(appName,organizationName, appVersion, null, location);
            } else {
                throw new AssertionError("Unknown test:" + testcaseName);
            }
        } catch (ExecutionException | InterruptedException | PackageManager.NameNotFoundException exc) {
            setStatusText(exc.getMessage());
            exc.printStackTrace();
        }

        if (AppClient.FindCloudletReply.FindStatus.FIND_FOUND != reply.getStatus()) throw new AssertionError("App's expected test cloudlet Status doesn't match. got=" + reply.getStatus() + " expected=" + AppClient.FindCloudletReply.FindStatus.FIND_FOUND );

        try {
            String cloudletAddress = InetAddress.getByName(foundCloudletFqdn).getHostAddress();
            String findCloudletReplyFqdn = reply.getFqdn();
            String officialAddress = InetAddress.getByName(findCloudletReplyFqdn).getHostAddress();

            if (!officialAddress.equals(cloudletAddress)) throw new AssertionError("address does not match. expected=" + cloudletAddress + " reply=" + officialAddress);
        } catch (UnknownHostException var6) {
            throw new AssertionError("caught UnknownHostException");
        }
        if (null == reply) throw new AssertionError("FindCloudlet is null");

        if (AppClient.FindCloudletReply.FindStatus.FIND_FOUND_VALUE != reply.getStatusValue()) throw new AssertionError("App's expected test cloudlet Status Value doesn't match.");

        if (!reply.getFqdn().equals(foundCloudletFqdn)) throw new AssertionError("App's expected test cloudlet FQDN doesn't match.");
        if (!reply.getFqdnBytes().toStringUtf8().equals(foundCloudletFqdn)) throw new AssertionError("App's expected test cloudlet FQDN Bytes doesn't match.");
        if (4 != reply.getPortsCount()) throw new AssertionError("App's expected test cloudlet Ports Count doesn't match.");

        if (!reply.getPorts(0).getFqdnPrefix().equals("")) throw new AssertionError("App's expected test Port 0 fqdn prefix doesn't match.");
        if (0 != reply.getPorts(0).getEndPort()) throw new AssertionError("App's expected test Port endport 0 doesn't match.");
        if (1234 != reply.getPorts(0).getInternalPort()) throw new AssertionError("App's expected test Port 0 internalport doesn't match.");
        if (1234 != reply.getPorts(0).getPublicPort()) throw new AssertionError("App's expected test Port 0 publicport doesn't match.");
        if (Appcommon.LProto.L_PROTO_TCP != reply.getPorts(0).getProto()) throw new AssertionError("App's expected test Port 0 proto doesn't match.");
        if (false != reply.getPorts(0).getTls()) throw new AssertionError("App's expected test Port 0 tls doesn't match.");

        if (!reply.getPorts(1).getFqdnPrefix().equals("")) throw new AssertionError("App's expected test Port 1 fqdn prefix doesn't match.");
        if (0 != reply.getPorts(1).getEndPort()) throw new AssertionError("App's expected test Port 1 endport doesn't match.");
        if (1 != reply.getPorts(1).getInternalPort()) throw new AssertionError("App's expected test Port 1 internalport doesn't match.");
        if (1 != reply.getPorts(1).getPublicPort()) throw new AssertionError("App's expected test Port 1 publicport doesn't match.");
        if (Appcommon.LProto.L_PROTO_UDP != reply.getPorts(1).getProto()) throw new AssertionError("App's expected test Port 1 proto doesn't match.");
        if (false != reply.getPorts(1).getTls()) throw new AssertionError("App's expected test Port 1 tls doesn't match.");

        if (!reply.getPorts(2).getFqdnPrefix().equals("")) throw new AssertionError("App's expected test Port 2 fqdn prefix doesn't match.");
        if (5 != reply.getPorts(2).getEndPort()) throw new AssertionError("App's expected test Port 2 endport doesn't match.");
        if (1 != reply.getPorts(2).getInternalPort()) throw new AssertionError("App's expected test Port 2 internalport doesn't match.");
        if (1 != reply.getPorts(2).getPublicPort()) throw new AssertionError("App's expected test Port 2 publicport doesn't match.");
        if (Appcommon.LProto.L_PROTO_TCP != reply.getPorts(2).getProto()) throw new AssertionError("App's expected test Port 2 proto doesn't match.");
        if (true != reply.getPorts(2).getTls()) throw new AssertionError("App's expected test Port 2 tls doesn't match.");

        if (!reply.getPorts(3).getFqdnPrefix().equals("")) throw new AssertionError("App's expected test Port 3 fqdn prefix doesn't match.");
        if (0 != reply.getPorts(3).getEndPort()) throw new AssertionError("App's expected test Port endport 3 doesn't match.");
        if (8080 != reply.getPorts(3).getInternalPort()) throw new AssertionError("App's expected test Port 3 internalport doesn't match.");
        if (8080 != reply.getPorts(3).getPublicPort()) throw new AssertionError("App's expected test Port 3 publicport doesn't match.");
        if (Appcommon.LProto.L_PROTO_TCP != reply.getPorts(3).getProto()) throw new AssertionError("App's expected test Port 3 proto doesn't match.");
        if (false != reply.getPorts(3).getTls()) throw new AssertionError("App's expected test Port 3 tls doesn't match.");

        return true;

    }

}
