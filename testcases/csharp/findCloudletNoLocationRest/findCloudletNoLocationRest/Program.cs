//ECQ-1194

using System;
using System.Threading.Tasks;
using System.Collections.Generic;
using DistributedMatchEngine;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace RestSample
{
    // This interface is optional but is used in the sample.
    class DummyUniqueID : UniqueID
    {
        string UniqueID.GetUniqueIDType()
        {
            return "";
        }

        string UniqueID.GetUniqueID()
        {
            return "";
        }
    }

    class DummyDeviceInfo : DeviceInfo
    {
        Dictionary<string, string> DeviceInfo.GetDeviceInfo()
        {
            Dictionary<string, string> dict = new Dictionary<string, string>();
            dict["one"] = "ONE";
            dict["two"] = "TWO";
            return dict;
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
            return "26201";
        }

        public string GetMccMnc()
        {
            return "26201";
        }
    }

    class Program
    {
        static string tokenServerURI = "http://mexdemo.tok.mobiledgex.net:9999/its?followURL=https://dme.mobiledgex.net/verifyLoc";
        static string carrierName = "dmuus";
        //static string appName = "EmptyMatchEngineApp";
        //static string orgName = "EmptyMatchEngineApp";
        static string orgName = "automation_dev_org";
        static string appName = "automation_api_app";
        static string appVers = "1.0";
        static string developerAuthToken = "";

        //static string host = "gddt.dme.mobiledgex.net";
        static string host = "us-qa.dme.mobiledgex.net";
        static UInt32 port = 38001;
        static string sessionCookie;

        // Get the ephemerial carriername from device specific properties.
        async static Task<string> getCurrentCarrierName()
        {
            var dummy = await Task.FromResult(0);
            return carrierName;
        }

        async static Task Main(string[] args)
        {
            try
            {
                carrierName = await getCurrentCarrierName();

                Console.WriteLine("FindCloudletNoLocationRest Testcase");

                //MatchingEngine me = new MatchingEngine(null, new SimpleNetInterface(new MacNetworkInterfaceName()), new DummyUniqueID(), new DummyDeviceInfo());
                MatchingEngine me = new MatchingEngine(null, new SimpleNetInterface(new LinuxNetworkInterfaceName()), new DummyUniqueID(), new DummyDeviceInfo());
                //port = MatchingEngine.defaultDmeRestPort;

                // Start location task:
                var locTask = Util.GetLocationFromDevice();

                var registerClientRequest = me.CreateRegisterClientRequest(orgName, appName, appVers, developerAuthToken);

                // Await synchronously.
                //Console.WriteLine("Port: " + port);
                var registerClientReply = await me.RegisterClient(host, port, registerClientRequest);


                //var loc = await locTask;
                long timeLongMs = new DateTimeOffset(DateTime.UtcNow).ToUnixTimeMilliseconds();
                long seconds = timeLongMs / 1000;
                int nanoSec = (int)(timeLongMs % 1000) * 1000000;
                var ts = new Timestamp { nanos = nanoSec, seconds = seconds.ToString() };
                var loc = new Loc()
                {
                    course = 0,
                    altitude = 100,
                    horizontal_accuracy = 5,
                    speed = 2,
                    longitude = 0,
                    latitude = 0,
                    vertical_accuracy = 20,
                    timestamp = ts
                };

                //Verify the Token Server URI is correct
                if (registerClientReply.token_server_uri != tokenServerURI)
                {
                    Environment.Exit(1);
                }
                else
                {
                    Console.WriteLine("Token Server URI Correct!");
                }

                // Store sessionCookie, for later use in future requests.
                sessionCookie = registerClientReply.session_cookie;

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

                //Console.WriteLine(jwtPayload);

                //Console.WriteLine("\n\n"); 

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
                var findCloudletRequest = me.CreateFindCloudletRequest(loc,                                                    carrierName);

                // Async:
                var findCloudletTask = me.FindCloudlet(host, port, findCloudletRequest);

                // Awaits:
                var findCloudletReply = await findCloudletTask;
                if (findCloudletReply.status.ToString() == "FIND_FOUND")
                {
                    Console.WriteLine("FindCloudlet Reply: " + findCloudletReply.status);
                    Console.WriteLine("FindCloudlet Reply: " + findCloudletReply.fqdn);
                    Console.WriteLine("FindCloudlet Reply: " + findCloudletReply.cloudlet_location.latitude);
                    Console.WriteLine("FindCloudlet Reply: " + findCloudletReply.cloudlet_location.longitude);
                    Console.WriteLine("Test Case Failed!!!");
                    Environment.Exit(1);
                }
                if (findCloudletReply.status.ToString() == "FIND_UNKNOWN")
                {
                    Console.WriteLine("FindCloudlet Reply: " + findCloudletReply.status);
                    Console.WriteLine("FindCloudlet Reply: " + findCloudletReply.fqdn);
                    Console.WriteLine("FindCloudlet Reply: " + findCloudletReply.cloudlet_location.latitude);
                    Console.WriteLine("FindCloudlet Reply: " + findCloudletReply.cloudlet_location.longitude);
                    Console.WriteLine("Test Case Failed!!!");
                    Environment.Exit(1);
                }
                if (findCloudletReply.status.ToString() == "FIND_NOTFOUND")
                {
                    Console.WriteLine("FindCloudlet Reply: " + findCloudletReply.status);
                    Console.WriteLine("Test Case Passed!!!");
                }
            }
            catch (InvalidTokenServerTokenException itste)
            {
                Console.WriteLine(itste.StackTrace);
            }
            catch (Exception e)
            {
                Console.WriteLine("Error Message: " + e.Message);
                Console.WriteLine("Test Case Passed!");
                Environment.Exit(0);
            }

        }
    };
}