﻿//ECQ-1182

using System;
using System.Threading.Tasks;
using System.Collections.Generic;
using DistributedMatchEngine;
namespace RestSample
{
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

    class DummyDeviceInfo : DeviceInfo
    {
        DummyCarrierInfo carrierInfo = new DummyCarrierInfo();

        Dictionary<string, string> DeviceInfo.GetDeviceInfo()
        {
            Dictionary<string, string> dict = new Dictionary<string, string>();
            dict["DataNetworkPath"] = carrierInfo.GetDataNetworkPath();
            dict["CarrierName"] = carrierInfo.GetCurrentCarrierName();
            dict["SignalStrength"] = carrierInfo.GetSignalStrength().ToString();
            dict["DeviceModel"] = "C#SDK";
            dict["DeviceOS"] = "TestOS";
            return dict;
        }

        public bool IsPingSupported()
        {
            return true;
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

        public string GetDataNetworkPath()
        {
            return "GSM";
        }

        public ulong GetSignalStrength()
        {
            return 2;
        }
    }

    class Program
    {
        static string tokenServerURI = "http://mexdemo.tok.mobiledgex.net:9999/its?followURL=https://dme.mobiledgex.net/verifyLoc";
        static string carrierName = "tmus";
        //static string appName = "EmptyMatchEngineApp";
        //static string orgName = "EmptyMatchEngineApp";
        static string orgName = "automation_dev_org";
        static string appName = "automation_api_app";
        static string appVers = "1.0";
        static string developerAuthToken = "";

        //static string host = "tdg.dme.mobiledgex.net";
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

                Console.WriteLine("FindCloudletBadSessionCookieRest Testcase");

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
                    longitude = 13.405,
                    latitude = 52.52,
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

                me.sessionCookie = "XX";
                //Console.WriteLine("sessionCookie = " + sessionCookie);

                var findCloudletRequest = me.CreateFindCloudletRequest(loc, carrierName);

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
                if (findCloudletReply.status.ToString() == "FIND_NOTFOUND")
                {
                    Console.WriteLine("FindCloudlet Reply: " + findCloudletReply.status);
                    Console.WriteLine("Test Case Failed!!!");
                    Environment.Exit(1);
                }
            }
            catch (InvalidTokenServerTokenException itste)
            {
                Console.WriteLine(itste.StackTrace);
            }
            catch (Exception e)
            {
                Console.WriteLine("Error Message: " + e.Message);
                if (e.InnerException != null)
                {
                    Console.WriteLine("Inner Exception: " + e.InnerException.Message);
                }
                Console.WriteLine("Test Case Passed!");
                Environment.Exit(0);
            }

        }
    };
}