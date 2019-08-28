using System;
using Grpc.Core;
using System.Net;
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
            // This test case still passes with a bac carrier
            Console.WriteLine("VerifyLocationBadCarrier Test Case");


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
        string dmeHost = "automationbuckhorn.dme.mobiledgex.net"; // DME server hostname or ip.
        //string dmeHost = "mexdemo.dme.mobiledgex.net"; // DME server hostname or ip.
        int dmePort = 50051; // DME port.

        MatchEngineApi.MatchEngineApiClient client;

        public void RunSampleFlow()
        {
            location = getLocation();
            string tokenServerURI = "http://mextest.tok.mobiledgex.net:9999/its?followURL=https://dme.mobiledgex.net/verifyLoc";
            string uri = dmeHost + ":" + dmePort;
            //string devName = "MobiledgeX”;
            //string appName = "MobiledgeX SDK Demo”;
            string devName = "automation_api";
            string appName = "automation_api_app";

            // Channel:

            ChannelCredentials channelCredentials = new SslCredentials();
            Channel channel = new Channel(uri, channelCredentials);

            client = new DistributedMatchEngine.MatchEngineApi.MatchEngineApiClient(channel);

            var registerClientRequest = CreateRegisterClientRequest(devName, appName, "1.0");
            var regReply = client.RegisterClient(registerClientRequest);

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
                Console.WriteLine("Verifying Location:");
                var verifyResponse = VerifyLocation(token);
                Console.WriteLine("VerifyLocation Status: " + verifyResponse.GpsLocationStatus);
                Console.WriteLine("VerifyLocation Accuracy: " + verifyResponse.GpsLocationAccuracyKm);
                Console.WriteLine("Testcase Pass!");
                Environment.Exit(0);
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


        RegisterClientRequest CreateRegisterClientRequest(string devName, string appName, string appVersion)
        {
            var request = new RegisterClientRequest
            {
                Ver = 1,
                DevName = devName,
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

        VerifyLocationReply VerifyLocation(string token)
        {
            var verifyLocationRequest = CreateVerifyLocationRequest(getCarrierName(), getLocation(), token);
            var verifyResult = client.VerifyLocation(verifyLocationRequest);
            Console.WriteLine("Using Carrier: " + getCarrierName());
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
            // This test case still passes with a bac carrier
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