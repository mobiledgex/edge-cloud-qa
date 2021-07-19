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

// ECQ-2186

using System;
using System.Threading.Tasks;
using System.Net.Sockets;
using System.Collections.Generic;
using System.Text;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using DistributedMatchEngine;

namespace RestSample
{
    // This interface is optional but is used in the sample.
    class DummyUniqueID : UniqueID
    {
        string UniqueID.GetUniqueIDType()
        {
            return "Mine";
        }

        string UniqueID.GetUniqueID()
        {
            return "62";
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
        static string carrierName = "TDG";

        // QA env
        static string orgName = "automation_dev_org";
        static string appName = "automation-sdk-porttest";
        static string appVersion = "1.0";

        // Production env
        //static string orgName = "MobiledgeX";
        //static string appName = "automation-sdk-k8-app";
        //static string appVersion = "7.0";

        // For SDK purposes only, this allows continued operation against default app insts.
        // A real app will get exceptions, and need to skip the DME, and fallback to public cloud.
        // static string fallbackDmeHost = "wifi.dme.mobiledgex.net";

        // QA env 
        static string host = "eu-qa.dme.mobiledgex.net";
        //static string fallbackDmeHost = "eu-qa.dme.mobiledgex.net";

        // Production env
        //static string host = "us-mexdemo.dme.mobiledgex.net";
        //static string fallbackDmeHost = "us-mexdemo.dme.mobiledgex.net";


        static UInt32 port = 38001;
        //static string developerAuthToken = "";
        static string sessionCookie;

        static Timestamp createTimestamp(int futureSeconds)
        {
            long ticks = DateTime.Now.Ticks;
            long sec = ticks / TimeSpan.TicksPerSecond; // Truncates.
            long remainderTicks = ticks - (sec * TimeSpan.TicksPerSecond);
            int nanos = (int)(remainderTicks / TimeSpan.TicksPerMillisecond) * 1000000;

            var timestamp = new Timestamp
            {
                seconds = (sec + futureSeconds).ToString(),
                nanos = nanos
            };

            return timestamp;
        }

        static List<QosPosition> CreateQosPositionList(Loc firstLocation, double direction_degrees, double totalDistanceKm, double increment)
        {
            var req = new List<QosPosition>();
            double kmPerDegreeLong = 111.32; // at Equator
            double kmPerDegreeLat = 110.57; // at Equator
            double addLongitude = (Math.Cos(direction_degrees / (Math.PI / 180)) * increment) / kmPerDegreeLong;
            double addLatitude = (Math.Sin(direction_degrees / (Math.PI / 180)) * increment) / kmPerDegreeLat;
            double i = 0d;
            double longitude = firstLocation.longitude;
            double latitude = firstLocation.latitude;

            long id = 1;

            while (i < totalDistanceKm)
            {
                longitude += addLongitude;
                latitude += addLatitude;
                i += increment;

                // FIXME: No time is attached to GPS location, as that breaks the server!
                var qloc = new QosPosition
                {
                    positionid = id.ToString(),
                    gps_location = new Loc
                    {
                        longitude = longitude,
                        latitude = latitude,
                        timestamp = createTimestamp(100)
                    }
                };


                req.Add(qloc);
                id++;
            }

            return req;
        }


        async static Task Main(string[] args)
        {
            // Flag for connections
            bool check = false;

            try
            {
                Console.WriteLine("GetConnectionWorkflowRest Testcase");

                //MatchingEngine me = new MatchingEngine(null, new SimpleNetInterface(new MacNetworkInterfaceName()), new DummyUniqueID(), new DummyDeviceInfo());
                MatchingEngine me = new MatchingEngine(null, new SimpleNetInterface(new LinuxNetworkInterfaceName()), new DummyUniqueID(), new DummyDeviceInfo());
                me.SetTimeout(15000);
                //port = MatchingEngine.defaultDmeRestPort;

                // Start location task:
                var locTask = Util.GetLocationFromDevice();

                // var registerClientRequest = me.CreateRegisterClientRequest( devName, appName, appVers, developerAuthToken);
                var registerClientRequest = me.CreateRegisterClientRequest(orgName, appName, appVersion);

                // Await synchronously.
                //Console.WriteLine("Port: " + port);
                var registerClientReply = await me.RegisterClient(host, port, registerClientRequest);

                Console.WriteLine("RC Reply:  " + registerClientReply.status.ToString());

                if (registerClientReply.status.ToString() != "RS_SUCCESS")
                {
                    Console.WriteLine("RegisterClient Failed!!!" + registerClientReply.status.ToString());
                    Console.WriteLine("Test Case Failed!!!");
                    Environment.Exit(1);
                }

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
                    longitude = -91.405,
                    latitude = 31.52,
                    vertical_accuracy = 20,
                    timestamp = ts
                };


                //Verify the Token Server URI is correct
                if (registerClientReply.token_server_uri != tokenServerURI)
                {
                    Console.WriteLine("Token Server URI Is NOT Correct!");
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

                //var findCloudletRequest = me.CreateFindCloudletRequest(carrierName, loc);

                // Async:
                var getConnectionWorkflowTask = me.RegisterAndFindCloudlet(host, port, orgName, appName, appVersion, loc);

                // Awaits:
                var findCloudletReply = await getConnectionWorkflowTask;

                if (findCloudletReply.status.ToString() == "FIND_FOUND")
                {
                    Console.WriteLine("FindCloudlet Reply: " + findCloudletReply.status);
                    Console.WriteLine("FindCloudlet Reply: " + findCloudletReply.fqdn);
                    Console.WriteLine("FindCloudlet Reply: " + findCloudletReply.cloudlet_location.latitude);
                    Console.WriteLine("FindCloudlet Reply: " + findCloudletReply.cloudlet_location.longitude + "\n");
                }
                if (findCloudletReply.status.ToString() == "FIND_NOTFOUND")
                {
                    Console.WriteLine("FindCloudlet Reply: " + findCloudletReply.status);
                    Console.WriteLine("Test Case Failed!!!");
                    Environment.Exit(1);
                }


                // The app has 4 ports 2015 UDP, 2016 TCP, 3015 TLS, and a HTTP port 8085 TCP
                // To test the UDP, TCP, and TLS ports send a "ping" to each port and recieve a "pong"
                // To test the HTTP port send "automation.html" and get the automation.html file
                string message = "";
                string test = "ping";
                string aWebSocketServerFqdn = appName + "-tcp." + findCloudletReply.fqdn;
                string receiveMessage = "";

                Dictionary<int, DistributedMatchEngine.AppPort> tcpAppPortDict = new Dictionary<int, DistributedMatchEngine.AppPort>();

                Console.WriteLine("TCP Port Testing\n");
                tcpAppPortDict = me.GetTCPAppPorts(findCloudletReply);
                check = false;
                foreach (KeyValuePair<int, DistributedMatchEngine.AppPort> kvp in tcpAppPortDict)
                {
                    if (kvp.Key == 2016)
                    {
                        try
                        {
                            Console.WriteLine("Starting TCP Port Testing");
                            Console.WriteLine("Key = {0}, Value = {1}", kvp.Key, kvp.Value);
                            message = test;
                            byte[] bytesMessage = Encoding.ASCII.GetBytes(message);
                            Socket tcpConnection = await me.GetTCPConnection(findCloudletReply, kvp.Value, kvp.Key, 10000);

                            tcpConnection.Send(bytesMessage);

                            Console.WriteLine("\nMessage Sent: " + message);
                            byte[] buffer = new byte[message.Length * 2]; // C# chars are unicode-16 bits
                            int numRead = tcpConnection.Receive(buffer);
                            byte[] readBuffer = new byte[numRead];
                            Array.Copy(buffer, readBuffer, numRead);
                            receiveMessage = Encoding.ASCII.GetString(readBuffer);

                            if (receiveMessage == "pong")
                            {
                                Console.WriteLine("TCP Get Connection worked!: ");
                                Console.WriteLine("Received Message: " + receiveMessage);
                                check = true;
                                tcpConnection.Close();
                            }
                            else
                            {
                                Console.WriteLine("TCP Get Connection DID NOT work!: " + receiveMessage);
                                tcpConnection.Close();
                                Environment.Exit(1);
                            }
                        }
                        catch (GetConnectionException e)
                        {
                            Console.WriteLine("TCP GetConnectionException is " + e.Message);
                            Console.WriteLine("Test Case Failed!!!");
                            Environment.Exit(1);
                        }
                        catch (Exception e)
                        {
                            Console.WriteLine("TCP socket exception is " + e);
                            Console.WriteLine("Test Case Failed!!!");
                            Environment.Exit(1);
                        }
                        Console.WriteLine("\nTCP Connection Port " + kvp.Key + " finished.");
                    }
                }
            }
            catch (InvalidTokenServerTokenException itste)
            {
                Console.WriteLine(itste.StackTrace);
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
            }
            if (check == true)
            {
                Console.WriteLine("\nGetConnectionWorkflowRest Testcase Passed!!");
                Environment.Exit(0);
            }
            else
            {
                Console.WriteLine("\nGetConnectionWorkflowRest Testcase Failed!!");
                Environment.Exit(1);
            }
        }
    };
}