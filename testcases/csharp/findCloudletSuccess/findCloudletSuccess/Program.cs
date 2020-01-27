﻿using System;
using Grpc.Core;
using System.Net;
using System.IO;
using System.Text;
using System.Diagnostics;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

// MobiledgeX Matching Engine API.
using DistributedMatchEngine;

namespace MexGrpcSampleConsoleApp
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("FindCloudletSuccess Test Case");


            var mexGrpcLibApp = new MexGrpcLibApp();
            mexGrpcLibApp.RunSampleFlow();
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

    class MexGrpcLibApp
    {
        Loc location;
        string sessionCookie;
        //string expSessionCookie = "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NDk1Njc1MzcsImlhdCI6MTU0OTQ4MTEzNywia2V5Ijp7InBlZXJpcCI6IjEwLjEzOC4wLjkiLCJkZXZuYW1lIjoiYXV0b21hdGlvbl9hcGkiLCJhcHBuYW1lIjoiYXV0b21hdGlvbl9hcGlfYXBwIiwiYXBwdmVycyI6IjEuMCIsImtpZCI6Nn19.d_UaPU9LJSqowEQfPHnXNgtpmTj84HTGL5t8PDpyz5ZBuIXxWKjd4YYdOa2qWe5sQrLy594fdmo-Pi-8Hp8sSg";

        //string dmeHost = null; // DME server hostname or ip.
        string dmeHost = "us-qa.dme.mobiledgex.net"; // DME server hostname or ip.
        //string dmeHost = "mexdemo.dme.mobiledgex.net"; // DME server hostname or ip.
        int dmePort = 50051; // DME port.

        MatchEngineApi.MatchEngineApiClient client;

        public void RunSampleFlow()
        {
            location = getLocation();
            string tokenServerURI = "http://mexdemo.tok.mobiledgex.net:9999/its?followURL=https://dme.mobiledgex.net/verifyLoc";
            string uri = dmeHost + ":" + dmePort;
            //string devName = "MobiledgeX”;
            //string appName = "MobiledgeX SDK Demo”;
            string devName = "automation_api";
            string appName = "automation_api_app";
            string developerAuthToken = "";

            // Channel:
            // TODO: Load from file or iostream, securely generate keys, etc.
            ChannelCredentials channelCredentials = new SslCredentials();
            Channel channel = new Channel(uri, channelCredentials);

            client = new DistributedMatchEngine.MatchEngineApi.MatchEngineApiClient(channel);


            var registerClientRequest = CreateRegisterClientRequest(devName, appName, "1.0", developerAuthToken);
            var regReply = client.RegisterClient(registerClientRequest);

            //Console.WriteLine("RegisterClient Reply: " + regReply);
            //Console.WriteLine("RegisterClient TokenServerURI: " + regReply.TokenServerURI);

            //Verify the Token Server URI is correct
            if (regReply.TokenServerUri != tokenServerURI)
            {
                Environment.Exit(1);
            }

            //Set the location in the location server
            //Console.WriteLine("Seting the location in the Location Server");
            setLocation("52.52", "13.405");
            //Console.WriteLine("Location Set\n\n");

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
            string dev;
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
                            //Console.WriteLine("Session Cookie Exparation Time correct:  " + tokenTime);
                        }
                    }
                    if (word.Substring(1, 6) == "peerip")
                    {
                        peer = word.Substring(10);
                        peer = peer.Substring(0, peer.Length - 1);
                        string pattern = "^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$";
                        if (System.Text.RegularExpressions.Regex.IsMatch(peer, pattern))
                        {
                            //Console.WriteLine("Peerip Expression Matched!  " + peer);
                        }
                        else
                        {
                            Console.WriteLine("Peerip Expression Didn't Match!  " + peer);
                            Environment.Exit(1);
                        }
                    }
                    if (word.Substring(1, 7) == "devname")
                    {
                        dev = word.Substring(11);
                        dev = dev.Substring(0, dev.Length - 1);
                        if (dev != devName)
                        {
                            Console.WriteLine("Devname Didn't Match!  " + dev);
                            Environment.Exit(1);
                        }
                        else
                        {
                            //Console.WriteLine("Devname Matched!  " + dev);
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
                            //Console.WriteLine("AppName Matched!  " + app);
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
                            //Console.WriteLine("App Version Matched!  " + appver);
                        }
                    }

                }


            }



            // Request the token from the TokenServer:
            string token = null;
            try
            {
                token = RetrieveToken(regReply.TokenServerUri);
                //Console.WriteLine("Received Token: " + token);
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

            //try
            //{
            // Async version can also be used. Blocking:
            //Console.WriteLine("\nVerifying Location: " + getLocation());
            //var verifyResponse = VerifyLocation(token);
            //string locationStatus = verifyResponse.GpsLocationStatus.ToString();
            //string locationAccuracy = verifyResponse.GPSLocationAccuracyKM.ToString();
            //if (locationStatus == "LocVerified")
            //{
            //Console.WriteLine("Testcase Passed!");
            //   Console.WriteLine("VerifyLocation Status: " + verifyResponse.GpsLocationStatus);
            //  Console.WriteLine("VerifyLocation Accuracy: " + verifyResponse.GPSLocationAccuracyKM);
            //Environment.Exit(0);
            //}
            //else
            //{
            //Console.WriteLine("Testcase Failed!");
            //Console.WriteLine("VerifyLocation Status: " + verifyResponse.GpsLocationStatus);
            //Console.WriteLine("VerifyLocation Accuracy: " + verifyResponse.GPSLocationAccuracyKM);
            //Environment.Exit(1);
            //}

            //}
            //catch (Grpc.Core.RpcException replyerror)
            //{
            //   Console.WriteLine("Testcase Failed!" + replyerror.StatusCode + replyerror.Status);
            //   Environment.Exit(1);
            //}

            // Blocking GRPC call:
            var findCloudletResponse = FindCloudlet();
            string fcStatus = findCloudletResponse.Status.ToString();
            if (fcStatus == "FindFound")
            {
                Console.WriteLine("Testcase Passed!");
                Console.WriteLine("FindCloudlet Status: " + findCloudletResponse.Status);
                Console.WriteLine("FindCloudlet Response: " + findCloudletResponse);
                Environment.Exit(0);
            }
            else
            {
                Console.WriteLine("Testcase Failed!");
                Console.WriteLine("FindCloudlet Status: " + findCloudletResponse.Status);
                Console.WriteLine("FindCloudlet Response: " + findCloudletResponse);
                Environment.Exit(1);
            }


            Environment.Exit(0);
        }


        RegisterClientRequest CreateRegisterClientRequest(string devName, string appName, string appVersion, string authToken)
        {
            var request = new RegisterClientRequest
            {
                Ver = 1,
                DevName = devName,
                AppName = appName,
                AppVers = appVersion,
                AuthToken = authToken
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

        static String setLocation(string locLat, string locLong)
        {
            var config = "";
            System.Diagnostics.ProcessStartInfo psi = new System.Diagnostics.ProcessStartInfo("curl");
            psi.Arguments = " ifconfig.me";
            psi.UseShellExecute = false;
            psi.RedirectStandardOutput = true;
            System.Diagnostics.Process curl;
            curl = System.Diagnostics.Process.Start(psi);
            curl.WaitForExit();
            System.IO.StreamReader ipReader = curl.StandardOutput;
            curl.WaitForExit();
            if (curl.HasExited)
            {
                config = ipReader.ReadToEnd();
            }


            string resp = null;
            string ipAddr = config;
            //string ipAddr = "40.122.108.233";
            string serverURL = "http://mextest.locsim.mobiledgex.net:8888/updateLocation";
            string payload = "{" + '"' + "latitude" + '"' + ':' + locLat + ',' + ' ' + '"' + "longitude" + '"' + ':' + locLong + ',' + ' ' + '"' + "ipaddr" + '"' + ':' + '"' + ipAddr + '"' + "}";
            Console.WriteLine(payload);
            byte[] postBytes = Encoding.UTF8.GetBytes(payload);
            WebRequest request = WebRequest.Create(serverURL);
            request.Method = "POST";
            request.ContentType = "application/jason; charset=UTF-8";
            //request.ContentType = "text/html; charset=utf-8";
            request.ContentLength = postBytes.Length;
            Stream dataStream = request.GetRequestStream();
            dataStream.Write(postBytes, 0, postBytes.Length);
            dataStream.Close();
            try
            {
                WebResponse response = request.GetResponse();
                //Console.WriteLine("Response: " + ((HttpWebResponse)response).StatusDescription);
                dataStream = response.GetResponseStream();
                StreamReader reader = new StreamReader(dataStream);
                string responseFromServer = reader.ReadToEnd();
                if (((HttpWebResponse)response).StatusDescription == "OK")
                {
                    Console.WriteLine(responseFromServer);
                }
                reader.Close();
                dataStream.Close();
                response.Close();
                return resp;
            }
            catch (System.Net.WebException we)
            {
                WebResponse respon = (HttpWebResponse)we.Response;
                //Console.WriteLine("Response: " + we.Status);
                Stream dStream = respon.GetResponseStream();
                StreamReader sr = new StreamReader(dStream);
                string responseFromServer = sr.ReadToEnd();
                Console.WriteLine(responseFromServer);
                sr.Close();
                dStream.Close();
                respon.Close();
                return resp;
            }


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

        VerifyLocationReply VerifyLocation(string token)
        {
            var verifyLocationRequest = CreateVerifyLocationRequest(getCarrierName(), getLocation(), token);
            var verifyResult = client.VerifyLocation(verifyLocationRequest);
            return verifyResult;
        }

        FindCloudletReply FindCloudlet()
        {
            // Create a synchronous request for FindCloudlet using RegisterClient reply's Session Cookie (TokenServerURI is now invalid):
            var findCloudletRequest = CreateFindCloudletRequest(getCarrierName(), getLocation());
            var findCloudletReply = client.FindCloudlet(findCloudletRequest);

            return findCloudletReply;
        }

        // TODO: The app must retrieve form they platform this case sensitive value before each DME GRPC call.
        // The device is potentially mobile and may have data roaming.
        String getCarrierName()
        {
            return "tmus";
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