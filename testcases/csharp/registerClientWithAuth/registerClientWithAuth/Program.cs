// ECQ-1094


using System;
using System.IdentityModel.Tokens.Jwt;
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
            Console.WriteLine("RegisterClientWithAuth Test Case");

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
        string sessionCookie;

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

            string tokenServerURI = "http://mexdemo.tok.mobiledgex.net:9999/its?followURL=https://dme.mobiledgex.net/verifyLoc";
            string uri = dmeHost + ":" + dmePort;
            string orgName = "automation_dev_org";
            string appName = "automation_api_auth_app";
            string appVers = "1.0";
            string developerAuthToken = "";


            // Generate the authToken
            var pubkey = "/home/jenkins/go/src/github.com/mobiledgex/edge-cloud-qa/certs/authtoken_private.pem";
            //var pubkey = "/Users/leon.adams/go/src/github.com/mobiledgex/edge-cloud-qa/certs/authtoken_private.pem";
            System.Diagnostics.ProcessStartInfo psi = new System.Diagnostics.ProcessStartInfo("genauthtoken");
            psi.Arguments = "-appname automation_api_auth_app -appvers 1.0 -devname automation_dev_org -privkeyfile " + pubkey;
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


            var registerClientRequest = me.CreateRegisterClientRequest(orgName, appName, appVers, developerAuthToken);
            try
            {
                var regReply = await me.RegisterClient(host: dmeHost, port: dmePort, registerClientRequest);

                Console.WriteLine("RegisterClient Reply Status :  " + regReply.Status);

                Console.WriteLine("AuthToken is correct!");
                if (regReply.TokenServerUri != tokenServerURI)
                {
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

            }
            catch (Grpc.Core.RpcException regReplyError)
            {
                if (regReplyError.Status.Detail == "app not found")
                {
                    Console.WriteLine("Register Client With Auth Return: " + regReplyError.Status.Detail);
                    Console.WriteLine("Test Case Failed!!!");
                    Environment.Exit(1);
                }
                else
                {
                    Console.WriteLine("Register Client With Auth Failed Return: " + regReplyError.Status.Detail);
                    Console.WriteLine("Test Case Failed!!!");
                    Environment.Exit(1);
                }

            }
            Console.WriteLine("Test Case Passed!!!");
            Environment.Exit(0);
        }


        RegisterClientRequest CreateRegisterClientRequest(string orgName, string appName, string appVersion, string authToken)
        {
            var request = new RegisterClientRequest
            {
                Ver = 1,
                OrgName = orgName,
                AppName = appName,
                AppVers = appVersion,
                AuthToken = authToken
            };
            return request;
        }


    }
}