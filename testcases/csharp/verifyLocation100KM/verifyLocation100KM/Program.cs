using System;
using Grpc.Core;
using System.Net;
using System.IO;
using System.Text;
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
            Console.WriteLine("VerifyLocation100KM Test Case");


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
        string sessionCookie;
        //string expSessionCookie = "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NDk1Njc1MzcsImlhdCI6MTU0OTQ4MTEzNywia2V5Ijp7InBlZXJpcCI6IjEwLjEzOC4wLjkiLCJkZXZuYW1lIjoiYXV0b21hdGlvbl9hcGkiLCJhcHBuYW1lIjoiYXV0b21hdGlvbl9hcGlfYXBwIiwiYXBwdmVycyI6IjEuMCIsImtpZCI6Nn19.d_UaPU9LJSqowEQfPHnXNgtpmTj84HTGL5t8PDpyz5ZBuIXxWKjd4YYdOa2qWe5sQrLy594fdmo-Pi-8Hp8sSg";

        //string dmeHost = null; // DME server hostname or ip.
        string dmeHost = "automationbuckhorn.dme.mobiledgex.net"; // DME server hostname or ip.
        //string dmeHost = "gddt2.dme.mobiledgex.net"; // DME server hostname or ip.
        int dmePort = 50051; // DME port.

        MatchEngineApi.MatchEngineApiClient client;

        public void RunSampleFlow()
        {
            location = getLocation();
            string tokenServerURI = "http://mextest.tok.mobiledgex.net:9999/its?followURL=https://dme.mobiledgex.net/verifyLoc";
            string uri = dmeHost + ":" + dmePort;
            //string devName = "EmptyMatchEngineApp";
            //string appName = "EmptyMatchEngineApp";
            string devName = "automation_api";
            string appName = "automation_api_app";

            // Channel:
            // TODO: Load from file or iostream, securely generate keys, etc.
            var clientKeyPair = new KeyCertificatePair(Credentials.clientCrt, Credentials.clientKey);
            var sslCredentials = new SslCredentials(Credentials.caCrt, clientKeyPair);
            Channel channel = new Channel(uri, sslCredentials);

            client = new DistributedMatchEngine.MatchEngineApi.MatchEngineApiClient(channel);

            var registerClientRequest = CreateRegisterClientRequest(devName, appName, "1.0");
            var regReply = client.RegisterClient(registerClientRequest);

            //Console.WriteLine("RegisterClient Reply: " + regReply);
            //Console.WriteLine("RegisterClient TokenServerURI: " + regReply.TokenServerURI);

            //Verify the Token Server URI is correct
            if (regReply.TokenServerUri != tokenServerURI)
            {
                Environment.Exit(1);
            }

            //Set the location in the location server
            Console.WriteLine("Seting the location in the Location Server");
            setLocation("52.52", "13.405");
            Console.WriteLine("Location Set\n\n");

            // Store sessionCookie, for later use in future requests.
            sessionCookie = regReply.SessionCookie;
            //sessionCookie = expSessionCookie;
            //essionCookie = missingApp_SessionCookie;

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



            // Request the token from the TokenServer:
            string token = null;
            try
            {
                token = RetrieveToken(regReply.TokenServerUri);
                //Console.WriteLine("VerifyLocation pre-query sessionCookie: " + sessionCookie);
                //Console.WriteLine("VerifyLocation pre-query TokenServer token: " + token);
            }
            catch (System.Net.WebException we)
            {
                Debug.WriteLine(we.ToString());

            }
            if (token == null)
            {
                return;
            }


            // Call the remainder. Verify and Find cloudlet.

            // Async version can also be used. Blocking:
            try
            {
                // Async version can also be used. Blocking:
                Console.WriteLine("\nVerifying Location:");
                var verifyResponse = VerifyLocation(token);
                string locationStatus = verifyResponse.GpsLocationStatus.ToString();
                string locationAccuracy = verifyResponse.GpsLocationAccuracyKm.ToString();
                if (locationStatus == "LocVerified" && locationAccuracy == "100")
                {
                    Console.WriteLine("Testcase Passed!");
                    Console.WriteLine("VerifyLocation Status: " + verifyResponse.GpsLocationStatus);
                    Console.WriteLine("VerifyLocation Accuracy: " + verifyResponse.GpsLocationAccuracyKm);
                    Environment.Exit(0);
                }
                else
                {
                    Console.WriteLine("Testcase Failed!");
                    Console.WriteLine("VerifyLocation Status: " + verifyResponse.GpsLocationStatus);
                    Console.WriteLine("VerifyLocation Accuracy: " + verifyResponse.GpsLocationAccuracyKm);
                    Environment.Exit(1);
                }

            }
            catch (Grpc.Core.RpcException replyerror)
            {
                Console.WriteLine("Testcase Failed!" + replyerror.StatusCode + replyerror.Status);
                Environment.Exit(1);
            }

            // Blocking GRPC call:
            //Console.WriteLine("FindCloudlet Status: " + findCloudletResponse.Status);
            //Console.WriteLine("FindCloudlet Response: " + findCloudletResponse);

            Environment.Exit(0);
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

        VerifyLocationRequest CreateVerifyLocationRequest(string carrierName, Loc gpsLocation, string verifyLocationToken)
        {
            var request = new VerifyLocationRequest
            {
                Ver = 1,
                SessionCookie = sessionCookie,
                CarrierName = carrierName,
                GpsLocation = gpsLocation,
                VerifyLocToken = verifyLocationToken
            };
            return request;
        }

        FindCloudletRequest CreateFindCloudletRequest(string carrierName, Loc gpsLocation)
        {
            var request = new FindCloudletRequest
            {
                Ver = 1,
                SessionCookie = sessionCookie,
                CarrierName = carrierName,
                GpsLocation = gpsLocation
            };
            return request;
        }

        static String setLocation(string locLat, string locLong)
        {
            var config = "";
            System.Diagnostics.ProcessStartInfo psi = new System.Diagnostics.ProcessStartInfo("curl");
            psi.Arguments = " ifconfig.me";
            psi.UseShellExecute = false;
            psi.RedirectStandardOutput = true;
            System.Diagnostics.Process curl;
            curl = System.Diagnostics.Process.Start(psi);
            curl.WaitForExit();
            System.IO.StreamReader ipReader = curl.StandardOutput;
            curl.WaitForExit();
            if (curl.HasExited)
            {
                config = ipReader.ReadToEnd();
            }


            string resp = null;
            string ipAddr = config;
            //string ipAddr = "40.122.108.233";
            string serverURL = "http://mextest.locsim.mobiledgex.net:8888/updateLocation";
            string payload = "{" + '"' + "latitude" + '"' + ':' + locLat + ',' + ' ' + '"' + "longitude" + '"' + ':' + locLong + ',' + ' ' + '"' + "ipaddr" + '"' + ':' + '"' + ipAddr + '"' + "}";
            Console.WriteLine(payload);
            byte[] postBytes = Encoding.UTF8.GetBytes(payload);
            WebRequest request = WebRequest.Create(serverURL);
            request.Method = "POST";
            request.ContentType = "application/jason; charset=UTF-8";
            //request.ContentType = "text/html; charset=utf-8";
            request.ContentLength = postBytes.Length;
            Stream dataStream = request.GetRequestStream();
            dataStream.Write(postBytes, 0, postBytes.Length);
            dataStream.Close();
            try
            {
                WebResponse response = request.GetResponse();
                //Console.WriteLine("Response: " + ((HttpWebResponse)response).StatusDescription);
                dataStream = response.GetResponseStream();
                StreamReader reader = new StreamReader(dataStream);
                string responseFromServer = reader.ReadToEnd();
                if (((HttpWebResponse)response).StatusDescription == "OK")
                {
                    Console.WriteLine(responseFromServer);
                }
                reader.Close();
                dataStream.Close();
                response.Close();
                return resp;
            }
            catch (System.Net.WebException we)
            {
                WebResponse respon = (HttpWebResponse)we.Response;
                //Console.WriteLine("Response: " + we.Status);
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
                string keyValue = keyValueStr.Substring(6);
                //Console.WriteLine("\n\nToken?: " + keyValue.ToString());
                //    string[] keyValue = keyValueStr.Split('=');
                //    if (keyValue[0].Equals("dt-id"))
                //    {
                return keyValue;
                //    }
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

        VerifyLocationReply VerifyLocation(string token)
        {
            var verifyLocationRequest = CreateVerifyLocationRequest(getCarrierName(), getLocation(), token);
            var verifyResult = client.VerifyLocation(verifyLocationRequest);
            return verifyResult;
        }

        FindCloudletReply FindCloudlet()
        {
            // Create a synchronous request for FindCloudlet using RegisterClient reply's Session Cookie (TokenServerURI is now invalid):
            var findCloudletRequest = CreateFindCloudletRequest(getCarrierName(), getLocation());
            var findCloudletReply = client.FindCloudlet(findCloudletRequest);

            return findCloudletReply;
        }

        // TODO: The app must retrieve form they platform this case sensitive value before each DME GRPC call.
        // The device is potentially mobile and may have data roaming.
        String getCarrierName()
        {
            return "GDDT";
        }

        // TODO: The client must retrieve a real GPS location from the platform, even if it is just the last known location,
        // possibly asynchronously.
        Loc getLocation()
        {
            return new DistributedMatchEngine.Loc
            {
                Longitude = 13.4050,
                Latitude = 53.4100
            };
        }

    }


    static class Credentials
    {
        // Root CA:
        public static string caCrt = @"-----BEGIN CERTIFICATE-----
MIIE4jCCAsqgAwIBAgIBATANBgkqhkiG9w0BAQsFADARMQ8wDQYDVQQDEwZtZXgt
Y2EwHhcNMTgwODIwMDMwNzQwWhcNMjAwMjIwMDMwNzQwWjARMQ8wDQYDVQQDEwZt
ZXgtY2EwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCk45wuENmZk/ok
u41JjBwC3PBRWA8SRIGjVbHHIGA6uORNY/GaKU1mgBengzvOqT9DrnwsHjQGoLEl
f3J3d/KF3rhm60ZVtHGi3FUuZc9N/8E3ABBivd31gGcv30b25UyxcE9TNiqJJ7z2
t1RmLT5+KSP7Mg9l+H1lhBRukdmAIym+pQsiFaKTxiZ9VbCfget+QP4mn1G1VdLD
j9LV7UIS8OO3EwslU4yYT0ycaHoUZEKWUYu9+D+nL/L9X3lruk2vNg0ieiFBAeoM
hAmQy8sQ+nsLPQlzWr7nyi2AMCwL8DQyKFVkGETaCmmTrDhoy+TWE6wkX5nsw90t
EIaaE4/BpEc4irXT8lUdLXEovYWaFcGxTDMJkFKjtPFACO8ck8r0GQ1C24FWqU4B
7kQoCj9BRtTGfRAozBIOroZ2/k2lig+FGIVnSUPIvc0F2axFgzlg8k2RVrPrdkQ2
VYWG7FLfZ9Wo8SkkenmnejguBEKOXs0Q4kEjh/qjDx5MZgIvjRCiamUt2MnBm7ky
j1EA1lZ7A8f2FmbCLthvcu5knpI1w/yvADXC2i+dBa/r8pIIlZv/9Mb7IlkBBF95
p0ES3rXAMTVbTrYKnwPSiZoES5zuLHOKCrNLg2zO2nqYE69a6FEPjkA+aoOs/KZG
JauZzTvtP25hViMnuee9QckcwS/mzwIDAQABo0UwQzAOBgNVHQ8BAf8EBAMCAQYw
EgYDVR0TAQH/BAgwBgEB/wIBADAdBgNVHQ4EFgQU0JOPAC7G5mw7G7W0e6GtHn7r
S3gwDQYJKoZIhvcNAQELBQADggIBAIDFI/SbMNIy1nskp4TNKv6YwMMgWUO7tfXs
obLrwGfneOR8lA9GJlpab47aohWcTxua6iwzUNqowq0x5wwmWwbSLeyiMY4TJj2E
C6Lla7uuC6WeY3RIS1XjjvOIvW6Mq2n3JElIwtGnm5qmr6CzfqiZenxY+UU1nBbI
eRw/V36ikJAQz5kj7wskUVwhAPEPnHr1hYmyu8t2Ue7zERwHzRIs0nwERQaV32aI
f//bV/kqhzueDiwqXqwFSHGreEefhUGUYEtiC8etLUZHe5ts3627pTjr0FZ2F+pt
OkQB9A+yuTPeJQJTMCLuyHxsiDQkT0On/Mky6ffdWSAwWXbcNVfO1If8Wi6yXvRz
Xe9dvyiIVwvG4VAtuwGEmTXd/fh4J/OpqxjLcXe/3k1ibX+y6zClV4REp4ygm6Kr
minVSTY4o4f1H39tIth9LZqpZKzOC4QJu0CWI4rLb6sCUlo8nWOmAktyua3xSAjs
k59JzlMIfdZ8z0SZq0Hy5Bf5XhZY0WcvWLc89RGslDibMtg6qweO43F23lV8w+Xn
mbSi8TUL2D7kA5StYElnJ4G2o4Bmymu8XxcZhDfeH0LJ8lqP7TyRnkL2jmNYm6be
3u/yuyFCrwRluMzwEzAY+3FPuhfHWCmlSZhx1gsXQIXtmKT0l2xU9dlF8fPBYC5e
LggXHNeu
-----END CERTIFICATE-----";

        // Client Crt:
        public static string clientCrt = @"-----BEGIN CERTIFICATE-----
MIIEOjCCAiKgAwIBAgIQMCuDiDXhpNOKRvn69uSbCjANBgkqhkiG9w0BAQsFADAR
MQ8wDQYDVQQDEwZtZXgtY2EwHhcNMTgwODIwMDMxMDI0WhcNMjAwMjIwMDMwNzM5
WjAVMRMwEQYDVQQDEwptZXgtY2xpZW50MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8A
MIIBCgKCAQEAzLaPAPOAUzV49VXgiYsDZTQ/zyCtsr0w3Ge/tvIck2Mm2FtAZ88r
oRV2UPrviEZPBL+o/JPiShfgqj1cLU1GyRr4uyezYl9AIig9/2xjYnkcXg6e3QG7
5lOaX2zH9mrYAm/N2hNzJwe9ZWBibXMDwFN4cptyygZuQ86SnK4j+6h1SVmN+F1j
ma18RzSU2rOjHK0InFgILSOlcjYYD/ds3HiL+vY6CVSNfuul5IMvQ/R8B8GwZpGG
34vl4AsDYM6FK+qW/ncFEt9rAOfu9AOeDWciKxPjzB4bX5G0dWAk5IU3VoGafEXe
Yt1xyeK25KHkw4kSh57BRkJKSuyvPWUqewIDAQABo4GJMIGGMA4GA1UdDwEB/wQE
AwIDuDAdBgNVHSUEFjAUBggrBgEFBQcDAQYIKwYBBQUHAwIwHQYDVR0OBBYEFGoT
cCzivXGPbeBD14sTusqjamkbMB8GA1UdIwQYMBaAFNCTjwAuxuZsOxu1tHuhrR5+
60t4MBUGA1UdEQQOMAyCCm1leC1jbGllbnQwDQYJKoZIhvcNAQELBQADggIBABSb
ZdZE9zh7vgT3cNr0gLVWk4We43VRlSa5JgdzWixi63qYTVIjHUE0BZo9yBMm3cx8
w327wAMVdlImUl/0Sv1NLi0IyC7EtxHfNhmUsgDa9oXuZwXM/RNmite1emS0ZYLE
fh7lNYUwnU/DHRPlZbIu08/7jYfyqxYKJSkP9HUBGOreGmMg+xARifr1Wb9uQDnx
12zK2uSG0Np8SbZV6FykNp7HeXG0jzOW+1Kg/NSxzYtScbSj3PfHIIHCiPhLd630
jVFsRUSfKMsM2+mDotVMvFlGyKoQUkQpS9RT/WsbKsSgLuW/WP1Zskh692DchMxI
YIASjJnwgidLwVen5uwj6h9vX9L1jb8CjV8w+SPjTqo6Hw8veQnqZV1nI1PgE17P
wjBlAmrCzfhbpNoMrktglWhpi/NJtCfQWwNkkGpd547NA1WXTRRqbxGc9Mg4GALb
6G9Hzp7nUpC3tC78jwZtsiw6oyPreYQc+O1XVD7qrvfcKabDStOIYcyenLmv82CL
ciCxLZGwVZ+5ABTuOsch7Sg3ZFnCJHvJqn00ZH7YBvTeoCfeelEiFCn7ehEbX8kn
y9MuVRwaDfGMKBYZ8Urr+RDxoDQwObvYQNIW9wVLoCGRuj3qt0BtTLkOuHvNCox1
GJJmmOKzRetckg3+ZSu7ET2YDuB3TDxPvDyc4Tq8
-----END CERTIFICATE-----";

        // Client Private Key:
        public static string clientKey = @"-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAzLaPAPOAUzV49VXgiYsDZTQ/zyCtsr0w3Ge/tvIck2Mm2FtA
Z88roRV2UPrviEZPBL+o/JPiShfgqj1cLU1GyRr4uyezYl9AIig9/2xjYnkcXg6e
3QG75lOaX2zH9mrYAm/N2hNzJwe9ZWBibXMDwFN4cptyygZuQ86SnK4j+6h1SVmN
+F1jma18RzSU2rOjHK0InFgILSOlcjYYD/ds3HiL+vY6CVSNfuul5IMvQ/R8B8Gw
ZpGG34vl4AsDYM6FK+qW/ncFEt9rAOfu9AOeDWciKxPjzB4bX5G0dWAk5IU3VoGa
fEXeYt1xyeK25KHkw4kSh57BRkJKSuyvPWUqewIDAQABAoIBACePjBk59W2fIs3+
l5LdC33uV/p2LTsidqPRZOo85arR+XrMP6kQDzVlCWVi6RFjzPd09npBNfTtolwj
2YFjsq9AiBra9D6pe6JeNoT69EXec831c1vwbth3BZk1U3tacH4gDx76rUE4rLA/
rSXLmUj8mIVFZyyFi5+M9yZSPN/v+J7VfE2b3dRVw+oBa4GEGpR9IcEGyGgjzz/2
qc4e+iphCW10ZfLl6ZuVIErJgoGEDlilZhNMLlGIu/4/0Pd2DH+pYE4JaVKHIltW
WChDIWh1Ad+fZvVB/+M27GOaavHKm64z5/46Oj/n6lhwL/GDi1CQeMHBSFn4xsf0
rloEvNkCgYEA3rChHJlq7xxHnAyCjR+VVWjS409DQHFM2KntbX7mv2lMS8t4jpf9
sV/tyX5CWrlbk4Ntyxzz8Z8hi6VYhRsLVDbWL5g3fHMK76mj1JtbDLUw/w28twEm
d1wit0i+5Un6i3i7Wig8g+y31xAqobI4/5mhehEhjjSQP7H8JQ7M2dUCgYEA61WM
x5QGAzYIi+y59rFITfk6x7DNW7dOk0z3B6caF1HBoUzIh/uZrKaGxHLUcPNUprBG
vhSCpYdsXPVZgqxibnjPwrbYCPBZoN4DXsvOosbUcK4aDwvAX/i0RH77eBM5M+J4
5DbNxoS8y0ALjjgj85LQv4fFQeFXy2VtVGvHSw8CgYAyrTtcyMT++Q6KwoYLG37e
WuZy+Byz05TLUZBIdLKKKKpGLV2YBZqj/NKeIe9zue7PGP+pU0NoXvBBWTVVxRvE
5F3Fovwtg/ifJZm0zk3gDHPD9xpVAxv/2aXE0/ctMrKjfqwUDkgHNZ14gaNR/L7f
29RVdQSP2gJhnF1nCYEwqQKBgQDBd+Vytfhzb1p7XjRL4Ncmczylqm5Jdlt8sYts
mS3T+fyLlMpPMMLXs1eb7SNFcGYpW0XtQoNdfgXSLkpWKU4Kr/ttgk/8mUu1+o8e
wcKxA3Dm6dq2f9y5iYb5wMMPpg4i346vX3awO7PSDGbzlqfHuO0waHf8fztkFZBa
FPkUdQKBgGhCavU72BxbSIFBsLuw07+DQ7aU00JFkqEFYrK2Y0KbtRzi5s0f8sTQ
m67Ck9nZhhvdpunWWeynM8rjJy4MPUJWZeJmo8OAxOAdmdXs8cmykqfNb+0uC35b
i4CrX+qG6rq9Y4/kVJ4jWdUbpAN7gp+vCMBUGZ0HuYtxlkRH4y6G
-----END RSA PRIVATE KEY-----";
    }
}