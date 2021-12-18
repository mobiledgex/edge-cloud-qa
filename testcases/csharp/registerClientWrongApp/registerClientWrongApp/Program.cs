// ECQ-1086


using System;
using System.Net;

// MobiledgeX Matching Engine API.
using DistributedMatchEngine;
using System.Threading.Tasks;

namespace MexGrpcSampleConsoleApp
{
    class Program
    {
        static async Task Main(string[] args)
        {
            Console.WriteLine("RegisterClientWrongApp Test Case");

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
                CarrierName = "GDDT",
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
            //string tokenServerURI = "http://mexdemo.tok.mobiledgex.net:9999/its?followURL=https://dme.mobiledgex.net/verifyLoc";
            string uri = dmeHost + ":" + dmePort;
            string orgName = "automation_dev_org";
            string appName = "automation_api_leon";
            string appVers = "1.0";

            var registerClientRequest = me.CreateRegisterClientRequest(orgName, appName, appVers);
            try
            {
                var regReply = await me.RegisterClient(host: dmeHost, port: dmePort, registerClientRequest);
                Console.WriteLine("RegisterClient Reply Status :  " + regReply.Status);
            }
            catch (Grpc.Core.RpcException regReplyError)
            {
                if(regReplyError.Status.Detail == "app not found")
                {
                    Console.WriteLine("Register Client Wrong App Return: " + regReplyError.Status.Detail);
                    Console.WriteLine("Test Case Passed!!");
                    Environment.Exit(0);
                }
                else
                {
                    Console.WriteLine("Register Client Wrong App Failed Return: " + regReplyError.Status.Detail);
                    Console.WriteLine("Test Case Failed!!");
                    Environment.Exit(1);
                }

            }

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
            return "dmuus";
        }

        // TODO: The client must retrieve a real GPS location from the platform, even if it is just the last known location,
        // possibly asynchronously.
        Loc getLocation()
        {
            return new DistributedMatchEngine.Loc
            {
                Longitude = -122.149349,
                Latitude = 37.459609
            };
        }

    }
}