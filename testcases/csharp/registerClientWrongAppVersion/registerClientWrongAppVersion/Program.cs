using System;

using Grpc.Core;
using System.Net;
using System.Diagnostics;
//using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

// MobiledgeX Matching Engine API.
using DistributedMatchEngine;

namespace MexGrpcSampleConsoleApp
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("RegisterClientWrongAppVersion Test Case");


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

        string dmeHost = "automationbonn.dme.mobiledgex.net"; // DME server hostname or ip.
        //string dmeHost = "mexdemo.dme.mobiledgex.net"; // DME server hostname or ip.
        int dmePort = 50051; // DME port.

        MatchEngineApi.MatchEngineApiClient client;

        public void RunSampleFlow()
        {
            location = getLocation();
            //string tokenServerURI = "http://mextest.tok.mobiledgex.net:9999/its?followURL=https://dme.mobiledgex.net/verifyLoc";
            string uri = dmeHost + ":" + dmePort;
            //string devName = "MobiledgeX”;
            //string appName = "MobiledgeX SDK Demo”;
            string devName = "automation_api";
            string appName = "automation_api_app";

            // Channel:
            ChannelCredentials channelCredentials = new SslCredentials();
            Channel channel = new Channel(uri, channelCredentials);

            client = new DistributedMatchEngine.MatchEngineApi.MatchEngineApiClient(channel);

            var registerClientRequest = CreateRegisterClientRequest(devName, appName, "2.0");
            try
            {
                var regReply = client.RegisterClient(registerClientRequest);
            }
            catch (Grpc.Core.RpcException regReplyError)
            {
                //Console.WriteLine(regReplyError.Status);
                if (regReplyError.Status.Detail == "app not found")
                {
                    Console.WriteLine("Register Client Wrong App Version Return: " + regReplyError.Status.Detail);
                    Console.WriteLine("TestCase Passed!!!");
                    Environment.Exit(0);
                }
                else
                {
                    Console.WriteLine("Register Client Wrong App Version Failed Return: " + regReplyError.Status.Detail);
                    Environment.Exit(1);
                }

            }

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



        // TODO: The app must retrieve form they platform this case sensitive value before each DME GRPC call.
        // The device is potentially mobile and may have data roaming.
        String getCarrierName()
        {
            return "TDG";
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
