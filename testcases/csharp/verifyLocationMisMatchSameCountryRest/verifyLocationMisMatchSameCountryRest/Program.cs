//ECQ-1188

using System;
using System.Net;
using System.IO;
using System.Text;
using System.Collections.Generic;
using System.Threading.Tasks;
using DistributedMatchEngine;

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
        public bool IsPingSupported()
        {
            return true;
        }

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

        public string GetDataNetworkPath()
        {
            return "GSM";
        }

        public string GetMccMnc()
        {
            return "26201";
        }

        public ulong GetSignalStrength()
        {
            return 0;
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

        static String setLocation(string locLat, string locLong)
        {
            string clientIP = "";

            System.Diagnostics.ProcessStartInfo psi = new System.Diagnostics.ProcessStartInfo("curl");
            psi.Arguments = " ifconfig.me";
            psi.RedirectStandardOutput = true;
            System.Diagnostics.Process ipCurl;
            ipCurl = System.Diagnostics.Process.Start(psi);
            ipCurl.WaitForExit();
            System.IO.StreamReader reader = ipCurl.StandardOutput;
            ipCurl.WaitForExit();
            if (ipCurl.HasExited)
            {
                clientIP = reader.ReadToEnd();
            }
            //Console.WriteLine(clientIP);

            string resp = null;
            string serverURL = "http://mexdemo.locsim.mobiledgex.net:8888/updateLocation";
            string payload = "{" + '"' + "latitude" + '"' + ':' + locLat + ',' + ' ' + '"' + "longitude" + '"' + ':' + locLong + ',' + ' ' + '"' + "ipaddr" + '"' + ':' + '"' + clientIP + '"' + "}";
            Console.WriteLine(payload);
            byte[] postBytes = Encoding.UTF8.GetBytes(payload);
            WebRequest request = WebRequest.Create(serverURL);
            request.Method = "POST";
            request.ContentType = "application/json; charset=UTF-8";
            //request.ContentType = "text/html; charset=utf-8";
            request.ContentLength = postBytes.Length;
            Stream dataStream = request.GetRequestStream();
            dataStream.Write(postBytes, 0, postBytes.Length);
            dataStream.Close();
            try
            {
                WebResponse response = request.GetResponse();
                Console.WriteLine("Response: " + ((HttpWebResponse)response).StatusDescription);
                dataStream = response.GetResponseStream();
                StreamReader sReader = new StreamReader(dataStream);
                string responseFromServer = sReader.ReadToEnd();
                if (((HttpWebResponse)response).StatusDescription == "OK")
                {
                    Console.WriteLine(responseFromServer);
                }
                sReader.Close();
                dataStream.Close();
                response.Close();
                return resp;
            }
            catch (System.Net.WebException we)
            {
                WebResponse respon = (HttpWebResponse)we.Response;
                Console.WriteLine("Response: " + we.Status);
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


        async static Task Main(string[] args)
        {
            try
            {
                carrierName = await getCurrentCarrierName();

                Console.WriteLine("VerifyLocationMisMatchSameCountryRest Testcase");

                //MatchingEngine me = new MatchingEngine(null, new SimpleNetInterface(new MacNetworkInterfaceName()), new DummyUniqueID(), new DummyDeviceInfo());
                MatchingEngine me = new MatchingEngine(null, new SimpleNetInterface(new LinuxNetworkInterfaceName()), new DummyUniqueID(), new DummyDeviceInfo());
                //port = MatchingEngine.defaultDmeRestPort;

                //Set the location in the location server
                Console.WriteLine("Seting the location in the Location Server");
                setLocation("52.52", "10.405");
                Console.WriteLine("Location Set\n");

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
                    longitude = 10.405,
                    latitude = 53.42,
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

                var verifyLocationRequest = me.CreateVerifyLocationRequest(loc, carrierName);
                var verfiyLocationTask = me.VerifyLocation(host, port, verifyLocationRequest);

                // Awaits:
                var verifyLocationReply = await verfiyLocationTask;
                Console.WriteLine("Location Reply Status: " + verifyLocationReply.gps_location_status.ToString());
               // Console.WriteLine("Location Reply Full: " + verifyLocationReply.);
                if (verifyLocationReply.gps_location_status.ToString() == "LOC_UNKNOWN")
                {
                    Console.WriteLine("Verify Location Failed!!");
                    Environment.Exit(1);
                }
                if (verifyLocationReply.gps_location_status.ToString() == "LOC_MISMATCH_SAME_COUNTRY")
                {
                    Console.WriteLine("VerifyLocation Reply - Status: " + verifyLocationReply.gps_location_status);
                    Console.WriteLine("VerifyLocation Reply - Accuracy: " + verifyLocationReply.gps_location_accuracy_km + "KM");
                    Console.WriteLine("Test Case Passed!!!");
                    Environment.Exit(0);

                }
                else
                {
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
                Console.WriteLine(e.Message);
            }

        }
    };
}
