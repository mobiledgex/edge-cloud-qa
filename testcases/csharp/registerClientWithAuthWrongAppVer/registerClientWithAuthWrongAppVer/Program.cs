// ECQ-1095


using System;
using System.Threading.Tasks;

// MobiledgeX Matching Engine API.
using DistributedMatchEngine;

namespace MexGrpcSampleConsoleApp
{
    class Program
    {
        static async Task Main(string[] args)
        {
            Console.WriteLine("RegisterClientWithAuthWrongAppVer Test Case");

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
            psi.Arguments = "-appname automation_api_auth_app -appvers 3.0 -devname automation_dev_org -privkeyfile " + pubkey;
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
                    Console.WriteLine("Test Case Failed!");
                    Environment.Exit(1);
                }

                // Store sessionCookie, for later use in future requests.
                sessionCookie = regReply.SessionCookie;
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