//ECQ-117

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
            Console.WriteLine("RegisterClientWithAuthWrongAppVer Test Case");


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
        string sessionCookie;

        string dmeHost = "us-qa.dme.mobiledgex.net"; // DME server hostname or ip.
        //string dmeHost = "mexdemo.dme.mobiledgex.net"; // DME server hostname or ip.
        int dmePort = 50051; // DME port.

        MatchEngineApi.MatchEngineApiClient client;

        public void RunSampleFlow()
        {
            string tokenServerURI = "http://mexdemo.tok.mobiledgex.net:9999/its?followURL=https://dme.mobiledgex.net/verifyLoc";
            string uri = dmeHost + ":" + dmePort;
            //string devName = "MobiledgeX”;
            //string appName = "MobiledgeX SDK Demo”;
            string appName = "automation_api_auth_app";
            string devName = "mobiledgex";
            string developerAuthToken = "";

            // Channel:
            // TODO: Load from file or iostream, securely generate keys, etc.
            ChannelCredentials channelCredentials = new SslCredentials();
            Channel channel = new Channel(uri, channelCredentials);

            client = new DistributedMatchEngine.MatchEngineApi.MatchEngineApiClient(channel);

            // Generate the authToken
            var pubkey = "/home/jenkins/go/src/github.com/mobiledgex/edge-cloud-qa/certs/authtoken_private.pem";
            //var pubkey = "/Users/leon.adams/go/src/github.com/mobiledgex/edge-cloud-qa/certs/authtoken_private.pem";
            System.Diagnostics.ProcessStartInfo psi = new System.Diagnostics.ProcessStartInfo("genauthtoken");
            psi.Arguments = "-appname automation_api_auth_app -appvers 3.0 -devname mobiledgex -privkeyfile " + pubkey;
            psi.RedirectStandardOutput = true;
            System.Diagnostics.Process genauthtoken;
            genauthtoken = System.Diagnostics.Process.Start(psi);
            genauthtoken.WaitForExit();
            System.IO.StreamReader reader = genauthtoken.StandardOutput;
            genauthtoken.WaitForExit();
            if (genauthtoken.HasExited)
            {
                developerAuthToken = reader.ReadToEnd();
            }
            developerAuthToken = developerAuthToken.Substring(6);
            developerAuthToken = developerAuthToken.Trim();
            //Console.WriteLine(developerAuthToken);
            //developerAuthToken = "";


            var registerClientRequest = CreateRegisterClientRequest(devName, appName, "1.0", developerAuthToken);
            try
            {
                var regReply = client.RegisterClient(registerClientRequest);

                Console.WriteLine("AuthToken is correct!");
                if (regReply.TokenServerUri != tokenServerURI)
                {
                    Console.WriteLine("Test Case Failed!");
                    Environment.Exit(1);
                }

                // Store sessionCookie, for later use in future requests.
                sessionCookie = regReply.SessionCookie;

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
                                Console.WriteLine("Devname Matched!  " + dev);
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

            }
            catch (Grpc.Core.RpcException regReplyError)
            {
                if (regReplyError.Status.Detail == "failed to verify token - token appvers mismatch")
                {
                    Console.WriteLine("AuthToken Incorrect!");
                    Console.WriteLine("Register Client With Auth Wrong App Version Return: " + regReplyError.Status.Detail);
                    Console.WriteLine("Test Case Passed!");
                    Environment.Exit(0);
                }
                else
                {
                    Console.WriteLine("Register Client With Auth Wrong App Version Failed Return: " + regReplyError.Status.Detail);
                    Console.WriteLine("Test Case Failed!");
                    Environment.Exit(1);
                }

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


    }
}