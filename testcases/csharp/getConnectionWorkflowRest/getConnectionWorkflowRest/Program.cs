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

// https://mobiledgex.atlassian.net/browse/ECQ-2186

using System;
using System.Threading.Tasks;
using System.Net.Sockets;
using System.Collections.Generic;
using System.Text;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using DistributedMatchEngine;
using System.Net.Http;
using System.Net.WebSockets;
using System.Net.Security;
using System.Security.Authentication;
using System.Linq;

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
    class Program
    {
        static string tokenServerURI = "http://mexdemo.tok.mobiledgex.net:9999/its?followURL=https://dme.mobiledgex.net/verifyLoc";
        static string carrierName = "GDDT";

        // QA env
        //static string orgName = "MobiledgeX";
        //static string appName = "automation-api-app";
        //static string appVersion = "1.0";
        static string orgName = "ladevorg";
        static string appName = "porttestapp";
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

                MatchingEngine me = new MatchingEngine(null, new SimpleNetInterface(new MacNetworkInterfaceName()), new DummyUniqueID());
                me.SetTimeout(15000);
                //port = MatchingEngine.defaultDmeRestPort;

                // Start location task:
                var locTask = Util.GetLocationFromDevice();

                // var registerClientRequest = me.CreateRegisterClientRequest( devName, appName, appVers, developerAuthToken);
                var registerClientRequest = me.CreateRegisterClientRequest(orgName, appName, appVersion);

                // Await synchronously.
                //Console.WriteLine("Port: " + port);
                var registerClientReply = await me.RegisterClient(host, port, registerClientRequest);

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
                string test = "{\"Data\": \"ping\"}";
                string aWebSocketServerFqdn = appName + "-tcp." + findCloudletReply.fqdn;
                string receiveMessage = "";

                Dictionary<int, DistributedMatchEngine.AppPort> tcpAppPortDict = new Dictionary<int, DistributedMatchEngine.AppPort>();

                Dictionary<int, DistributedMatchEngine.AppPort> udpAppPortDict = new Dictionary<int, DistributedMatchEngine.AppPort>();

                Console.WriteLine("TCP Port Testing\n");
                tcpAppPortDict = me.GetTCPAppPorts(findCloudletReply);
                foreach (KeyValuePair<int, DistributedMatchEngine.AppPort> kvp in tcpAppPortDict)
                {
                    check = false;
                    if (kvp.Key == 8085)
                    {
                        Console.WriteLine("Starting HTTP Port Testing");
                        Console.WriteLine("Key = {0}, Value = {1}", kvp.Key, kvp.Value);
                        message = "/automation.html";
                        string uriString = aWebSocketServerFqdn;
                        UriBuilder uriBuilder = new UriBuilder("http", uriString, kvp.Key);
                        Uri uri = uriBuilder.Uri;

                        try
                        {
                            HttpClient httpClient = await me.GetHTTPClient(uri);
                            //Assert.ByVal(httpClient, Is.Not.Null);
                            HttpResponseMessage response = await httpClient.GetAsync(message);
                            response.EnsureSuccessStatusCode();
                            string responseBody = await response.Content.ReadAsStringAsync();
                            //Assert.ByVal(responseBody, Is.Not.Null);
                            Console.WriteLine("http response body is " + responseBody);
                            //Assert.True(responseBody.Contains("HTTP Connection Test"));
                        }
                        catch (HttpRequestException e)
                        {
                            Console.WriteLine("HttpRequestException is " + e.Message);
                            Console.WriteLine("Test Case Failed!!!");
                            Environment.Exit(1);
                        }
                        check = true;
                        Console.WriteLine("Http Connection Port " + kvp.Key + " finished.\n");

                    }
                    check = false;
                    if (kvp.Key == 3765)
                    {
                        try
                        {
                            Console.WriteLine("Starting WEBSocket Testing");
                            Console.WriteLine("Key = {0}, Value = {1}", kvp.Key, kvp.Value);
                            message = "noeL";
                            string path = "/ws";
                            byte[] bytesMessage = Encoding.ASCII.GetBytes(message);
                            System.Threading.CancellationToken cToken;
                            var buffer = new ArraySegment<byte>(new byte[128]);
                            WebSocketReceiveResult wsResult;

                            ClientWebSocket webSocket = await me.GetWebsocketConnection(findCloudletReply, kvp.Value, kvp.Key, 10000, path);

                            await webSocket.SendAsync(bytesMessage, WebSocketMessageType.Text, true, cToken);
                            wsResult = await webSocket.ReceiveAsync(buffer, cToken);
                            byte[] msgBytes = buffer.Skip(buffer.Offset).Take(wsResult.Count).ToArray();
                            string rcvMsg = Encoding.UTF8.GetString(msgBytes);


                            //receiveMessage = ms.Write(buffer.Array, buffer.Offset, wsResult.Count);

                            if (rcvMsg == "Leon")
                            {
                                Console.WriteLine("Sent: " + message);
                                Console.WriteLine("Received: " + rcvMsg);
                                Console.WriteLine("GetWebSocket Connection worked!:");

                            }
                            else
                            {

                                Console.WriteLine("GetWebSocket Connection DID NOT work!: " + rcvMsg);
                                Environment.Exit(1);
                            }
                        }
                        catch (GetConnectionException e)
                        { 
                            Console.WriteLine("GetWebSocket Connection Exception is " + e.Message);
                            Console.WriteLine("Test Case Failed!!!");
                            Environment.Exit(1);
                        }
                        catch (Exception e)
                        {
                            Console.WriteLine("GetWebSocket Connection exception is " + e);
                            Console.WriteLine("Test Case Failed!!!");
                            Environment.Exit(1);
                        }
                        check = true;
                        //Assert.True(receiveMessage.Contains("tcp test string"));
                        Console.WriteLine("GetWebSocket Connection Port " + kvp.Key + " finished.\n");

                    }
                    check = false;
                    if (kvp.Key == 2016)
                    {

                        try
                        {
                            Console.WriteLine("Starting TCP Port Testing");
                            Console.WriteLine("Key = {0}, Value = {1}", kvp.Key, kvp.Value);
                            message = test;
                            byte[] bytesMessage = Encoding.ASCII.GetBytes(message);
                            Socket tcpConnection = await me.GetTCPConnection(aWebSocketServerFqdn, kvp.Key, 10000);

                            tcpConnection.Send(bytesMessage);

                            byte[] buffer = new byte[message.Length * 2]; // C# chars are unicode-16 bits
                            int numRead = tcpConnection.Receive(buffer);
                            byte[] readBuffer = new byte[numRead];
                            Array.Copy(buffer, readBuffer, numRead);
                            receiveMessage = Encoding.ASCII.GetString(readBuffer);

                            if (receiveMessage == "pong")
                            {
                                Console.WriteLine("TCP Get Connection worked!: " + receiveMessage);
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
                        check = true;
                        //Assert.True(receiveMessage.Contains("tcp test string"));
                        Console.WriteLine("TCP Connection Port " + kvp.Key + " finished.\n");
                    }
                    check = false;
                    if(kvp.Key == 2015)
                    {
                        Console.WriteLine("Starting TLS Port Testing");
                        Console.WriteLine("Key = {0}, Value = {1}", kvp.Key, kvp.Value);
                        message = test;
                        byte[] bytesMessage = Encoding.ASCII.GetBytes(message);
                        //SslStream stream = await me.GetTCPTLSConnection(aWebSocketServerFqdn, kvp.Key, 10000);
                        //try
                        //{
                            //Console.WriteLine("Starting Authentication");
                            //stream.AuthenticateAsClient(aWebSocketServerFqdn);
                            //Console.WriteLine("Endinging Authentication");
                        //}
                        //catch (AuthenticationException e)
                        //{
                            //Console.WriteLine("Exception: {0}", e.Message);
                            //if (e.InnerException != null)
                            //{
                                //Console.WriteLine("Inner exception: {0}", e.InnerException.Message);
                            //}
                            //Console.WriteLine("Auth failed - closing the connection.");
                            //stream.Close();
                            //return;
                        //}

                        //stream.Write(bytesMessage);
                        //stream.Flush();
                        //string serverMessage = ReadMessage(stream);
                        //Console.WriteLine("\n\nReceived: " + serverMessage);
                        check = true;
                        Console.WriteLine("TLS Connection Port " + kvp.Key + " finished.\n");
                    }
                }

                 string ReadMessage(SslStream sslStream)
                {
                    // Read the  message sent by the server.
                    // The end of the message is signaled using the
                    // "<EOF>" marker.
                    byte[] buffer = new byte[2048];
                    StringBuilder messageData = new StringBuilder();
                    int bytes = -1;
                    do
                    {
                        bytes = sslStream.Read(buffer, 0, buffer.Length);

                        // Use Decoder class to convert from bytes to UTF8
                        // in case a character spans two buffers.
                        Decoder decoder = Encoding.UTF8.GetDecoder();
                        char[] chars = new char[decoder.GetCharCount(buffer, 0, bytes)];
                        decoder.GetChars(buffer, 0, bytes, chars, 0);
                        messageData.Append(chars);
                        // Check for EOF.
                        if (messageData.ToString().IndexOf("<EOF>") != -1)
                        {
                            break;
                        }
                    } while (bytes != 0);

                    return messageData.ToString();
                }

                Console.WriteLine("Starting UDP Port Testing");
                aWebSocketServerFqdn = appName + "-udp." + findCloudletReply.fqdn;
                udpAppPortDict = me.GetUDPAppPorts(findCloudletReply);
                foreach (KeyValuePair<int, DistributedMatchEngine.AppPort> kvp in udpAppPortDict)
                {
                    check = false;
                    try
                    {
                        Console.WriteLine("Key = {0}, Value = {1}", kvp.Key, kvp.Value);
                        message = test;
                        byte[] bytesMessage = Encoding.ASCII.GetBytes(message);
                        Socket udpConnection = await me.GetUDPConnection(aWebSocketServerFqdn, kvp.Key, 10000);
                        //Assert.ByVal(tcpConnection, Is.Not.Null);

                        udpConnection.Send(bytesMessage);

                        byte[] buffer = new byte[message.Length * 2]; // C# chars are unicode-16 bits
                        int numRead = udpConnection.Receive(buffer);
                        byte[] readBuffer = new byte[numRead];
                        Array.Copy(buffer, readBuffer, numRead);
                        receiveMessage = Encoding.ASCII.GetString(readBuffer);
                        if (receiveMessage == "pong")
                        {
                            Console.WriteLine("UDP Get Connection worked!: " + receiveMessage);
                            udpConnection.Close();
                        }
                        else
                        {
                            Console.WriteLine("UDP Get Connection DID NOT work!: " + receiveMessage);
                            udpConnection.Close();
                            Environment.Exit(1);
                        }
                    }
                    catch (GetConnectionException e)
                    {
                        Console.WriteLine("UDP GetConnectionException is " + e.Message);
                        Console.WriteLine("Test Case Failed!!!");
                        Environment.Exit(1);
                    }
                    catch (Exception e)
                    {
                        Console.WriteLine("UDP socket exception is " + e);
                        Console.WriteLine("Test Case Failed!!!");
                        Environment.Exit(1);
                    }
                    check = true;
                    //Assert.True(receiveMessage.Contains("tcp test string"));
                    Console.WriteLine("Test UDP Connection Port " + kvp.Key + " finished.\n");

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