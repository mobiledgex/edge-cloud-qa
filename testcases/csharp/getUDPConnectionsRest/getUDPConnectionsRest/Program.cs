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

// ECQ-2801


using System;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Text;
using System.Net.Sockets;
using DistributedMatchEngine;
using System.Security.Authentication;

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
        //static string tokenServerURI = "http://mexdemo.tok.mobiledgex.net:9999/its?followURL=https://dme.mobiledgex.net/verifyLoc";
        //QA env
        static string carrierName = "TDG";
        static string orgName = "automation_dev_org";
        static string appName = "automation-sdk-porttest";
        static string appVers = "1.0";
        static string host = "eu-qa.dme.mobiledgex.net";
        static string fallbackDmeHost = "eu-qa.dme.mobiledgex.net";

        //Main
        // Production env
        //static string orgName = "ladevorg";
        //static string appName = "porttestapp";
        //static string appVers = "1.0";
        //static string host = "us-mexdemo.dme.mobiledgex.net";
        //static string fallbackDmeHost = "eu-mexdemo.dme.mobiledgex.net";


        static string developerAuthToken = "";
        static UInt32 cellID = 0;
        //static Tag[] tags = new Tag[0];
        //const string connectionTestFqdn = "mextest-app-cluster.frankfurt-main.tdg.mobiledgex.net";
        //const string aWebSocketServerFqdn = "pingpong-tcp.frankfurt-main.tdg.mobiledgex.net"; // or, localhost.
        //const string connectionTestFqdn = "autoclusterautomation-api-app.automationdusseldorfcloudlet.tdg.mobiledgex.net";
        static string aWebSocketServerFqdn = "";
        static AppPort appPort = null;
        static int myPort = 0;
            



        // For SDK purposes only, this allows continued operation against default app insts.
        // A real app will get exceptions, and need to skip the DME, and fallback to public cloud.
        //static string fallbackDmeHost = "wifi.dme.mobiledgex.net";

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
            try
            {
                Console.WriteLine("Get UDP Connections Testcase!!");

                //MatchingEngine me = new MatchingEngine(null, new SimpleNetInterface(new MacNetworkInterfaceName()), new DummyUniqueID(), new DummyDeviceInfo());
                MatchingEngine me = new MatchingEngine(null, new SimpleNetInterface(new LinuxNetworkInterfaceName()), new DummyUniqueID(), new DummyDeviceInfo());
                me.SetTimeout(15000);

                FindCloudletReply findCloudletInfo = null;

                // Start location task. This is for test use only. The source of the
                // location in an Unity application should be from an application context
                // LocationService.
                var locTask = Util.GetLocationFromDevice();
                var registerClientRequest = me.CreateRegisterClientRequest(orgName, appName, appVers, developerAuthToken, cellID, me.GetUniqueIDType(), me.GetUniqueIDType());
                // APIs depend on Register client to complete successfully:
                RegisterClientReply registerClientReply;
                try
                {
                    try
                    {
                        registerClientReply = await me.RegisterClient(host, MatchingEngine.defaultDmeRestPort, registerClientRequest);
                        if (registerClientReply.status != ReplyStatus.RS_SUCCESS)
                        {
                            Console.WriteLine("RegisterClient Failed! " + registerClientReply.status);
                            Console.WriteLine("Test Case Failed!!!");
                            Environment.Exit(1);
                        }
                    }
                    catch (DmeDnsException)
                    {
                        // DME doesn't exist in DNS. This is not a normal path if the SIM card is supported. Fallback to public cloud here.
                        registerClientReply = await me.RegisterClient(fallbackDmeHost, MatchingEngine.defaultDmeRestPort, registerClientRequest);
                        Console.WriteLine("RegisterClient Reply Status: " + registerClientReply.status);
                    }
                    catch (NotImplementedException)
                    {
                        registerClientReply = await me.RegisterClient(fallbackDmeHost, MatchingEngine.defaultDmeRestPort, registerClientRequest);
                        Console.WriteLine("RegisterClient Reply Status: " + registerClientReply.status);
                    }
                }
                catch (HttpException httpe) // HTTP status, and REST API call error codes.
                {
                    // server error code, and human readable message:
                    Console.WriteLine("RegisterClient Exception: " + httpe.Message + ", HTTP StatusCode: " + httpe.HttpStatusCode + ", API ErrorCode: " + httpe.ErrorCode + "\nStack: " + httpe.StackTrace);
                    Console.WriteLine("Test Case Failed!!!");
                    Environment.Exit(1);
                }
                // Do Verify and FindCloudlet in concurrent tasks:
                var loc = await locTask;

                // Independent requests:
                var verifyLocationRequest = me.CreateVerifyLocationRequest(loc, carrierName, cellID);
                var findCloudletRequest = me.CreateFindCloudletRequest(loc);
                //var getLocationRequest = me.CreateGetLocationRequest(carrierName, cellID, tags);


                // These are asynchronious calls, of independent REST APIs.

                // FindCloudlet:
                try
                {
                    FindCloudletReply findCloudletReply = null;
                    try
                    {
                        findCloudletReply = await me.FindCloudlet(host, MatchingEngine.defaultDmeRestPort, findCloudletRequest);
                        if (findCloudletReply.status != FindCloudletReply.FindStatus.FIND_FOUND)
                        {
                            Console.WriteLine("FindCloudlet Failed! " + findCloudletReply.status);
                            Console.WriteLine("Test Case Failed!!!");
                            Environment.Exit(1);
                        }
                    }
                    catch (DmeDnsException)
                    {
                        // DME doesn't exist in DNS. This is not a normal path if the SIM card is supported. Fallback to public cloud here.
                        findCloudletReply = await me.FindCloudlet(fallbackDmeHost, MatchingEngine.defaultDmeRestPort, findCloudletRequest);
                    }
                    catch (NotImplementedException)
                    {
                        findCloudletReply = await me.FindCloudlet(fallbackDmeHost, MatchingEngine.defaultDmeRestPort, findCloudletRequest);
                    }
                    Console.WriteLine("\nFindCloudlet Reply: " + findCloudletReply);
                    findCloudletInfo = findCloudletReply;

                    if (findCloudletReply != null)
                    {
                        if (findCloudletReply.status.ToString() == "FIND_NOTFOUND")
                        {
                            Console.WriteLine("No App Instance Found!!! Test Case Failed!!");
                            Environment.Exit(1);
                        }
                        else
                        {
                            Console.WriteLine("FindCloudlet Reply Status: " + findCloudletReply.status);
                            Console.WriteLine("FindCloudlet:" +
                                    " ver: " + findCloudletReply.ver +
                                    ", fqdn: " + findCloudletReply.fqdn +
                                    ", cloudlet_location: " +
                                    " long: " + findCloudletReply.cloudlet_location.longitude +
                                    ", lat: " + findCloudletReply.cloudlet_location.latitude);
                            // App Ports:
                            foreach (AppPort p in findCloudletReply.ports)
                            {
                                if(p.public_port == 2015)
                                {
                                    appPort = p;
                                }
                                Console.WriteLine("Port: fqdn_prefix: " + p.fqdn_prefix +
                                      ", protocol: " + p.proto +
                                      ", public_port: " + p.public_port +
                                      ", internal_port: " + p.internal_port +
                                      ", end_port: " + p.end_port);
                            }
                        }
                    }
                    aWebSocketServerFqdn = me.GetHost(findCloudletInfo, appPort);
                    myPort = me.GetPort(appPort, 2015);
                }
                catch (HttpException httpe)
                {
                    Console.WriteLine("\nFindCloudlet Exception: " + httpe.Message + ", HTTP StatusCode: " + httpe.HttpStatusCode + ", API ErrorCode: " + httpe.ErrorCode + "\nStack: " + httpe.StackTrace);
                    Console.WriteLine("Test Case Failed!!!");
                    Environment.Exit(1);
                }

                // Get Location:
                //GetLocationReply getLocationReply = null;


                // Verify Location:
                try
                {
                    Console.WriteLine("\nVerifyLocation() may timeout, due to reachability of carrier verification servers from your network.");
                    VerifyLocationReply verifyLocationReply = null;
                    try
                    {
                        verifyLocationReply = await me.VerifyLocation(host, MatchingEngine.defaultDmeRestPort, verifyLocationRequest);
                    }
                    catch (DmeDnsException)
                    {
                        verifyLocationReply = await me.VerifyLocation(fallbackDmeHost, MatchingEngine.defaultDmeRestPort, verifyLocationRequest);
                    }
                    catch (NotImplementedException)
                    {
                        verifyLocationReply = await me.VerifyLocation(fallbackDmeHost, MatchingEngine.defaultDmeRestPort, verifyLocationRequest);
                    }
                    if (verifyLocationReply != null)
                    {
                        Console.WriteLine("VerifyLocation Reply GPS location status: " + verifyLocationReply.gps_location_status);
                        Console.WriteLine("VerifyLocation Reply Tower Status: " + verifyLocationReply.tower_status);
                    }
                }
                catch (HttpException httpe)
                {
                    Console.WriteLine("\nVerifyLocation Exception: " + httpe.Message + ", HTTP StatusCode: " + httpe.HttpStatusCode + ", API ErrorCode: " + httpe.ErrorCode + "\nStack: " + httpe.StackTrace);
                    Console.WriteLine("Test Case Failed!!!");
                    Environment.Exit(1);
                }
                catch (InvalidTokenServerTokenException itste)
                {
                    Console.WriteLine(itste.Message + "\n" + itste.StackTrace);
                    Console.WriteLine("Test Case Failed!!!");
                    Environment.Exit(1);
                }


                Console.WriteLine("\nTest UDP 2015 Connection Starting.");

                string test = "ping";
                string message = test;
                byte[] bytesMessage = Encoding.ASCII.GetBytes(message);

                // TCP Connection Test
                string receiveMessage = "";
                try
                {
                    Socket stream = await me.GetUDPConnection(findCloudletInfo, appPort, myPort, 10000);

                    stream.Send(bytesMessage);
                    Console.WriteLine("Message Sent: " + message.ToString());

                    byte[] buffer = new byte[message.Length * 2]; // C# chars are unicode-16 bits 
                    int numRead = stream.Receive(buffer);

                    byte[] readBuffer = new byte[numRead];
                    Array.Copy(buffer, readBuffer, numRead);
                    receiveMessage = Encoding.ASCII.GetString(readBuffer);

                    if (receiveMessage == "pong")
                    {
                        Console.WriteLine("UDP Get Connection worked!: ");
                        Console.WriteLine("Recieved Message: " + receiveMessage);
                        stream.Close();
                    }
                    else
                    {
                        Console.WriteLine("UDP Get Connection DID NOT work!");
                        Console.WriteLine("Recieved Message: " + receiveMessage);
                        stream.Close();
                        Environment.Exit(1);
                    }

                }
                catch (AuthenticationException e)
                {
                    Console.WriteLine("Authentication Exception is " + e.Message);
                    Console.WriteLine("UDP Test Case Failed!!!");
                    Environment.Exit(1);
                }
                catch (GetConnectionException e)
                {
                    Console.WriteLine("UDP GetConnectionException is " + e.Message);
                    Console.WriteLine("UDP Test Case Failed!!!");
                    Environment.Exit(1);
                }
            }
            catch (Exception e)
            {
                Console.WriteLine("UDP socket exception is " + e);
                Console.WriteLine("UDP Test Case Failed!!!");
                Environment.Exit(1);
            }
            Console.WriteLine("Test UDP Connection finished.\n");

            Console.WriteLine("UDP Connections Test Case Passed!!!");

        }
    };
}
