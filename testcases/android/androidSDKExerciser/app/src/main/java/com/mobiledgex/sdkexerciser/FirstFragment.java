package com.mobiledgex.sdkexerciser;

import android.content.pm.PackageManager;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;

import com.mobiledgex.matchingengine.DmeDnsException;
import com.mobiledgex.matchingengine.MatchingEngine;
import com.mobiledgex.matchingengine.util.RequestPermissions;

import java.util.concurrent.ExecutionException;

import distributed_match_engine.AppClient;

public class FirstFragment extends Fragment {

    private static final String TAG = "FirstFragment";
    private MatchingEngine matchingEngine;
    private RequestPermissions mRpUtil;

    private TextView mTextView;
    private LinearLayout mButtonLayout;


    @Override
    public View onCreateView(
            LayoutInflater inflater, ViewGroup container,
            Bundle savedInstanceState
    ) {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_first, container, false);
    }

    public void onViewCreated(@NonNull View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        mRpUtil = new RequestPermissions();

        mTextView = view.findViewById(R.id.textView);
        mButtonLayout = view.findViewById(R.id.linear_layout_buttons);

        addButton("RegisterClient", new Runnable() { public void run() { testRegisterClientSuccess(); } });
        addButton("RegisterClientBadAppName", new Runnable() { public void run() { testRegisterClientAppName(); } });
        addButton("RegisterClientBadVersion", new Runnable() { public void run() { testRegisterClientBadVersion(); } });
    }

    @Override
    public void onResume() {
        Log.i(TAG, "onResume()");
        super.onResume();
        /*
         * Check permissions here, as the user has the ability to change them on the fly through
         * system settings
         */
        if (mRpUtil.getNeededPermissions((AppCompatActivity) getActivity()).size() > 0) {
            // Opens a UI. When it returns, onResume() is called again.
            mRpUtil.requestMultiplePermissions((AppCompatActivity) getActivity());
            return;
        }
        // Ensures that user can switch from wifi to cellular network data connection (required to verifyLocation)
        matchingEngine = new MatchingEngine(getContext());
        matchingEngine.setNetworkSwitchingEnabled(false);  //false-> wifi (Use wifi for demo)
    }

    private void addButton(String text, final Runnable r) {
        Log.i(TAG, "r="+r);
        Button button = new Button(getContext());
        button.setText(text);
        button.setTransformationMethod(null);
        button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                r.run();
            }
        });
        mButtonLayout.addView(button);
    }

    private void setStatusText(String statusText) {
        Log.i(TAG, statusText);
        mTextView.setText(statusText);
    }

    private void testRegisterClientSuccess() {
        String appName = "MobiledgeX SDK Demo";
        String orgName = "MobiledgeX";
        String appVersion = "2.0";

        MatchingEngine.setMatchingEngineLocationAllowed(true);

        String host = null;
        try {
            host = matchingEngine.generateDmeHostAddress();

            if(host == null) {
                Log.e(TAG, "Could not generate host");
                host = "wifi.dme.mobiledgex.net";   //fallback host
            }
            int port = matchingEngine.getPort(); // Keep same port.
            AppClient.RegisterClientRequest registerClientRequest;
            registerClientRequest = matchingEngine.createDefaultRegisterClientRequest(getContext(), orgName)
                    .setAppName(appName).setAppVers(appVersion).build();
            AppClient.RegisterClientReply registerStatus
                    = matchingEngine.registerClient(registerClientRequest, host, port, 10000);

            if(matchingEngine == null) {
                setStatusText("matchingEngine uninitialized");
                return;
            }

            Log.i(TAG, "registerClientRequest="+registerClientRequest);
            Log.i(TAG, "registerStatus.getStatus()="+registerStatus.getStatus());

            if (registerStatus.getStatus() != AppClient.ReplyStatus.RS_SUCCESS) {
                setStatusText("Registration Failed. Error: " + registerStatus.getStatus());
                return;
            }
            Log.i(TAG, "SessionCookie:" + registerStatus.getSessionCookie());
            mTextView.setText("SessionCookie:" + registerStatus.getSessionCookie());
        } catch (DmeDnsException e) {
            e.printStackTrace();
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        } catch (InterruptedException e) {
            e.printStackTrace();
        } catch (ExecutionException e) {
            e.printStackTrace();
        }

    }

    private void testRegisterClientAppName() {
        mTextView.setText("Test passed");
    }

    private void testRegisterClientBadVersion() {
        mTextView.setText("Test failed");
    }
}
