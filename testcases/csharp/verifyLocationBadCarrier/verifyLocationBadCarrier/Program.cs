// Copyright 2022 MobiledgeX, Inc
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

﻿// ECQ-1101


using System;
using System.Diagnostics;
using System.IdentityModel.Tokens.Jwt;
using System.Net;
using System.Security.Claims;
using System.Threading.Tasks;

// MobiledgeX Matching Engine API.
using DistributedMatchEngine;

namespace MexGrpcSampleConsoleApp
{
    class Program
    {
        static async Task Main(string[] args)
        {
            // This test case still passes with a bac carrier
            Console.WriteLine("VerifyLocationBadCarrier Test Case");

            var mexGrpcLibApp = new MexGrpcLibApp();
            try
            {
                await mexGrpcLibApp.RunSampleFlow();
            }
            catch (AggregateException ae)
            {
                Console.Error.WriteLine("Exception running sample: " + ae.Message);
                Console.Error.WriteLine("Excetpion stack trace: " + ae.StackTrace);
            }
            catch (Exception e)
            {
                Console.Error.WriteLine("Exception running sample: " + e.Message);
                Console.Error.WriteLine("Excetpion stack trace: " + e.StackTrace);
            }
        }
    }

    public class TokenException : Exception
    {
        public TokenException(string message)
            : base(message)
        {
        }

        public TokenException(string message, Exception innerException)
            : base(message, innerException)
        {
        }
    }

    class DummyCarrierInfo : CarrierInfo
    {
        public ulong GetCellID()
        {
            return 0;
        }

        public string GetCurrentCarrierName()
        {
            return "";
        }

        public string GetMccMnc()
        {
            return "";
        }

        public string GetDataNetworkType()
        {
            return "";
        }

        public ulong GetSignalStrength()
        {
            return 0;
        }
    }

    // This interface is optional but is used in the sample.
    class DummyUniqueID : UniqueID
    {
        string UniqueID.GetUniqueIDType()
        {
            return "dummyModel";
        }

        string UniqueID.GetUniqueID()
        {
            return "abcdef0123456789";
        }
    }

    class DummyDeviceInfo : DeviceInfoApp
    {

        public DeviceInfoDynamic GetDeviceInfoDynamic()
        {
            DeviceInfoDynamic DeviceInfoDynamic = new DeviceInfoDynamic()
            {
                CarrierName = "dmuus",
                DataNetworkType = "GSM",
                SignalStrength = 0
            };
            return DeviceInfoDynamic;
        }

        public DeviceInfoStatic GetDeviceInfoStatic()
        {
            DeviceInfoStatic DeviceInfoStatic = new DeviceInfoStatic()
            {
                DeviceModel = "platos",
                DeviceOs = "Android 11"
            };
            return DeviceInfoStatic;
        }

        public bool IsPingSupported()
        {
            return true;
        }
    }

    class MexGrpcLibApp
    {
        Loc location;
        string sessionCookie;
        //string expSessionCookie = "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NDk1Njc1MzcsImlhdCI6MTU0OTQ4MTEzNywia2V5Ijp7InBlZXJpcCI6IjEwLjEzOC4wLjkiLCJkZXZuYW1lIjoiYXV0b21hdGlvbl9hcGkiLCJhcHBuYW1lIjoiYXV0b21hdGlvbl9hcGlfYXBwIiwiYXBwdmVycyI6IjEuMCIsImtpZCI6Nn19.d_UaPU9LJSqowEQfPHnXNgtpmTj84HTGL5t8PDpyz5ZBuIXxWKjd4YYdOa2qWe5sQrLy594fdmo-Pi-8Hp8sSg";

        string dmeHost = "us-qa.dme.mobiledgex.net"; // DME server hostname or ip.
        uint dmePort = 50051; // DME port.
        
        MatchingEngine me;

        public async Task RunSampleFlow()
        {
            me = new MatchingEngine(
                //netInterface: new SimpleNetInterface(new MacNetworkInterfaceName()),
                netInterface: new SimpleNetInterface(new LinuxNetworkInterfaceName()),
                carrierInfo: new DummyCarrierInfo(),
                deviceInfo: new DummyDeviceInfo(),
                uniqueID: new DummyUniqueID());
            me.useOnlyWifi = true;
            me.useSSL = true; // false --> Local testing only.

            location = getLocation();
            string tokenServerURI = "http://mexdemo.tok.mobiledgex.net:9999/its?followURL=https://dme.mobiledgex.net/verifyLoc";
            string uri = dmeHost + ":" + dmePort;
            string orgName = "automation_dev_org";
            string appName = "automation_api_app";
            string appVers = "1.0";

            var registerClientRequest = me.CreateRegisterClientRequest(orgName, appName, appVers);
            var regReply = await me.RegisterClient(host: dmeHost, port: dmePort, registerClientRequest);
            Console.WriteLine("RegisterClient Reply Status :  " + regReply.Status);

            //Console.WriteLine("RegisterClient Reply: " + regReply);
            //Console.WriteLine("RegisterClient TokenServerURI: " + regReply.TokenServerURI);

            //Verify the Token Server URI is correct
            if (regReply.TokenServerUri != tokenServerURI)
            {
                Environment.Exit(1);
            }

            // Store sessionCookie, for later use in future requests.
            sessionCookie = regReply.SessionCookie;
            //sessionCookie = expSessionCookie;
            //essionCookie = missingApp_SessionCookie;

            //Setup to handle the sessiontoken
            var jwtHandler = new JwtSecurityTokenHandler();
            System.IdentityModel.Tokens.Jwt.JwtSecurityToken secToken = null;
            secToken = jwtHandler.ReadJwtToken(sessionCookie);
            var claims = secToken.Claims;
            var jwtPayload = "";
            foreach (Claim c in claims)
            {
                jwtPayload += '"' + c.Type + "\":\"" + c.Value + "\",";
            }


            //Extract the sessiontoken contents
            char[] delimiterChars = { ',', '{', '}' };
            string[] words = jwtPayload.Split(delimiterChars);
            long expTime = 0;
            long iatTime = 0;
            bool expParse = false;
            bool iatParse = false;
            string peer;
            string org;
            string app;
            string appver;

            foreach (var word in words)
            {
                if (word.Length > 7)
                {
                    //Console.WriteLine(word);
                    if (word.Substring(1, 3) == "exp")
                    {
                        expParse = long.TryParse(word.Substring(7, 10), out expTime);
                    }
                    if (word.Substring(1, 3) == "iat")
                    {
                        iatParse = long.TryParse(word.Substring(7, 10), out iatTime);
                    }
                    if (expParse && iatParse)
                    {
                        int divider = 60;
                        long tokenTime = expTime - iatTime;
                        tokenTime /= divider;
                        tokenTime /= divider;
                        int expLen = 24;
                        expParse = false;
                        if (tokenTime != expLen)
                        {
                            Console.WriteLine("Session Cookie Exparation Time not 24 Hours:  " + tokenTime);
                            Environment.Exit(1);
                        }
                        else
                        {
                            Console.WriteLine("Session Cookie Exparation Time correct:  " + tokenTime);
                        }
                    }
                    if (word.Substring(1, 6) == "peerip")
                    {
                        peer = word.Substring(10);
                        peer = peer.Substring(0, peer.Length - 1);
                        string pattern = "^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$";
                        if (System.Text.RegularExpressions.Regex.IsMatch(peer, pattern))
                        {
                            Console.WriteLine("Peerip Expression Matched!  " + peer);
                        }
                        else
                        {
                            Console.WriteLine("Peerip Expression Didn't Match!  " + peer);
                            Environment.Exit(1);
                        }
                    }
                    if (word.Substring(1, 7) == "orgname")
                    {
                        org = word.Substring(11);
                        org = org.Substring(0, org.Length - 1);
                        if (org != orgName)
                        {
                            Console.WriteLine("Orgname Didn't Match!  " + org);
                            Environment.Exit(1);
                        }
                        else
                        {
                            Console.WriteLine("Orgname Matched!  " + org);
                        }
                    }
                    if (word.Substring(1, 7) == "appname")
                    {
                        app = word.Substring(11);
                        app = app.Substring(0, app.Length - 1);
                        if (app != appName)
                        {
                            Console.WriteLine("AppName Didn't Match!  " + app);
                            Environment.Exit(1);
                        }
                        else
                        {
                            Console.WriteLine("AppName Matched!  " + app);
                        }
                    }
                    if (word.Substring(1, 7) == "appvers")
                    {
                        appver = word.Substring(11, 3);
                        if (appver != "1.0")
                        {
                            Console.WriteLine("App Version Didn't Match!  " + appver);
                            Environment.Exit(1);
                        }
                        else
                        {
                            Console.WriteLine("App Version Matched!  " + appver);
                        }
                    }

                }


            }

            // Request the token from the TokenServer:
            string token = null;
            try
            {
                token = RetrieveToken(regReply.TokenServerUri);
                //Console.WriteLine("VerifyLocation pre-query sessionCookie: " + sessionCookie);
                //Console.WriteLine("VerifyLocation pre-query TokenServer token: " + token);
            }
            catch (System.Net.WebException we)
            {
                Debug.WriteLine(we.ToString());

            }
            if (token == null)
            {
                return;
            }


            // Call the remainder. Verify and Find cloudlet.
            try
            {
                // Async version can also be used. Blocking:
                // This test case still passes with a bac carrier
                var carrierName = getCarrierName();
                Console.WriteLine("\nVerifying Location:");
                var verifyLocationRequest = me.CreateVerifyLocationRequest(location);
                var verifyResponse = await me.VerifyLocation(host: dmeHost, port: dmePort, verifyLocationRequest);
                if(verifyResponse.GpsLocationStatus == VerifyLocationReply.Types.GPSLocationStatus.LocVerified)
                {
                    Console.WriteLine("VerifyLocation Status: " + verifyResponse.GpsLocationStatus);
                    Console.WriteLine("VerifyLocation Accuracy: " + verifyResponse.GpsLocationAccuracyKm);
                    Console.WriteLine("Testcase Pass!");
                    Environment.Exit(0);
                }
                else
                {
                    Console.WriteLine("VerifyLocation Status: " + verifyResponse.GpsLocationStatus);
                    Console.WriteLine("Testcase Fail!");
                    Environment.Exit(1);
                }
            }
            catch (Grpc.Core.RpcException replyerror)
            {
                //Console.WriteLine(replyerror.Status.Detail.Substring(0, 19));
                if (replyerror.Status.Detail.ToString() != "")
                {
                    Console.WriteLine("Testcase Failed!" + replyerror.Status.Detail  );
                    Environment.Exit(1);
                }
            }

            // Blocking GRPC call:
            //Console.WriteLine("FindCloudlet Status: " + findCloudletResponse.Status);
            //Console.WriteLine("FindCloudlet Response: " + findCloudletResponse);

            Environment.Exit(0);
        }


        RegisterClientRequest CreateRegisterClientRequest(string orgName, string appName, string appVersion)
        {
            var request = new RegisterClientRequest
            {
                Ver = 1,
                OrgName = orgName,
                AppName = appName,
                AppVers = appVersion
            };
            return request;
        }

        VerifyLocationRequest CreateVerifyLocationRequest(string carrierName, Loc gpsLocation, string verifyLocationToken)
        {
            var request = new VerifyLocationRequest
            {
                Ver = 1,
                SessionCookie = sessionCookie,
                CarrierName = carrierName,
                GpsLocation = gpsLocation,
                VerifyLocToken = verifyLocationToken
            };
            return request;
        }

        FindCloudletRequest CreateFindCloudletRequest(string carrierName, Loc gpsLocation)
        {
            var request = new FindCloudletRequest
            {
                Ver = 1,
                SessionCookie = sessionCookie,
                CarrierName = carrierName,
                GpsLocation = gpsLocation
            };
            return request;
        }

        static String parseToken(String uri)
        {
            string[] uriandparams = uri.Split('?');
            if (uriandparams.Length < 1)
            {
                return null;
            }
            string parameterStr = uriandparams[1];
            if (parameterStr.Equals(""))
            {
                return null;
            }

            string[] parameters = parameterStr.Split('&');
            if (parameters.Length < 1)
            {
                return null;
            }

            foreach (string keyValueStr in parameters)
            {
                string[] keyValue = keyValueStr.Split('=');
                if (keyValue[0].Equals("dt-id"))
                {
                    return keyValue[1];
                }
            }

            return null;
        }

        string RetrieveToken(string tokenServerURI)
        {
            HttpWebRequest httpWebRequest = (HttpWebRequest)WebRequest.Create(tokenServerURI);
            httpWebRequest.AllowAutoRedirect = false;

            HttpWebResponse response = null;
            string token = null;
            string uriLocation = null;
            // 303 See Other is behavior is different between standard C#
            // and what's potentially in Unity.
            try
            {
                response = (HttpWebResponse)httpWebRequest.GetResponse();
                if (response != null)
                {
                    if (response.StatusCode != HttpStatusCode.SeeOther)
                    {
                        throw new TokenException("Expected an HTTP 303 SeeOther.");
                    }
                    uriLocation = response.Headers["Location"];
                }
            }
            catch (System.Net.WebException we)
            {
                response = (HttpWebResponse)we.Response;
                if (response != null)
                {
                    if (response.StatusCode != HttpStatusCode.SeeOther)
                    {
                        throw new TokenException("Expected an HTTP 303 SeeOther.", we);
                    }
                    uriLocation = response.Headers["Location"];
                }
            }

            if (uriLocation != null)
            {
                token = parseToken(uriLocation);
            }
            return token;
        }


        // TODO: The app must retrieve form they platform this case sensitive value before each DME GRPC call.
        // The device is potentially mobile and may have data roaming.
        String getCarrierName()
        {
            // This test case still passes with a bad carrier
            return "xx";
        }

        // TODO: The client must retrieve a real GPS location from the platform, even if it is just the last known location,
        // possibly asynchronously.
        Loc getLocation()
        {
            return new DistributedMatchEngine.Loc
            {
                Longitude = 13.4050,
                Latitude = 52.5200
            };
        }

    }
}