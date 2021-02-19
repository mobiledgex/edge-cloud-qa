#include <grpcpp/grpcpp.h>
#include <iostream>
#include <sstream>
#include <string>
#include <regex>

#include <curl/curl.h>

#include "app-client.grpc.pb.h"
#include "jwt.h"

using namespace std;
using namespace std::chrono;
using namespace distributed_match_engine;
using distributed_match_engine::MatchEngineApi;

using grpc::Channel;
using grpc::ClientContext;
using grpc::Status;


class MexGrpcClient {
  public:
    unsigned long timeoutSec = 5000;
    const string appName = "automation_api_app"; // Your application name
    const string orgName = "automation_dev_org"; // Your developer org name
    //const string appName = "EmptyMatchEngineApp"; // Your application name
    //const string orgName = "EmptyMatchEngineApp"; // Your developer org name
    const string appVersionStr = "1.0";

    MexGrpcClient(std::shared_ptr<Channel> channel)
        : stub_(MatchEngineApi::NewStub(channel)) {}

    // Retrieve the carrier name of the cellular network interface.
    string getCarrierName() {
        return string("dmuus");
    }

    // A C++ GPS location provider/binding is needed here.
    //unique_ptr<Loc> location = // make_unique --> C++14...
    unique_ptr<Loc> retrieveLocation() {
        auto location = unique_ptr<Loc>(new Loc());
        if (location == NULL) {
            throw "Location allocation failed!";
        }
        location->set_longitude(-122.149349);
        location->set_latitude(37.459609);
        location->set_horizontal_accuracy(5);
        location->set_vertical_accuracy(20);
        location->set_altitude(100);
        location->set_course(0);
        location->set_speed(2);

        // Google's protobuf timestamp
        auto timestampPtr = new Timestamp();
        auto ts_micro = std::chrono::system_clock::now().time_since_epoch();
        auto ts_sec = duration_cast<std::chrono::seconds>(ts_micro);
        auto ts_micro_remainder = ts_micro % std::chrono::microseconds(1000000);
        auto ts_nano_remainder = duration_cast<std::chrono::nanoseconds>(ts_micro_remainder);

        timestampPtr->set_seconds(ts_sec.count());
        timestampPtr->set_nanos(ts_nano_remainder.count());

        location->set_allocated_timestamp(timestampPtr);
        return location;
    }


    // A C++ GPS location provider/binding is needed here.
    //unique_ptr<Loc> location = // make_unique --> C++14...
    unique_ptr<Loc> retrieveBadLocation() {
        auto badLocation = unique_ptr<Loc>(new Loc());
        if (badLocation == NULL) {
            throw "Bad Location allocation failed!";
        }
        badLocation->set_longitude(0);
        badLocation->set_latitude(0);
        badLocation->set_horizontal_accuracy(5);
        badLocation->set_vertical_accuracy(20);
        badLocation->set_altitude(100);
        badLocation->set_course(0);
        badLocation->set_speed(2);

        // Google's protobuf timestamp
        auto timestampPtr = new Timestamp();
        auto ts_micro = std::chrono::system_clock::now().time_since_epoch();
        auto ts_sec = duration_cast<std::chrono::seconds>(ts_micro);
        auto ts_micro_remainder = ts_micro % std::chrono::microseconds(1000000);
        auto ts_nano_remainder = duration_cast<std::chrono::nanoseconds>(ts_micro_remainder);

        timestampPtr->set_seconds(ts_sec.count());
        timestampPtr->set_nanos(ts_nano_remainder.count());

        badLocation->set_allocated_timestamp(timestampPtr);
        return badLocation;
    }

  
    unique_ptr<RegisterClientRequest> createRegisterClientRequest(const string &authToken) {
        unique_ptr<RegisterClientRequest> request = unique_ptr<RegisterClientRequest>(new RegisterClientRequest());

        request->set_ver(1);

        request->set_org_name(orgName);
        request->set_app_name(appName);
        request->set_app_vers(appVersionStr);
        request->set_auth_token(authToken);

        return request;
    }

    // Carrier name can change depending on cell tower.
    unique_ptr<VerifyLocationRequest> createVerifyLocationRequest(const string carrierName, const shared_ptr<Loc> gpslocation, const string verifyloctoken) {
        unique_ptr<VerifyLocationRequest> request = unique_ptr<VerifyLocationRequest>(new VerifyLocationRequest());

        request->set_ver(1);

        request->set_session_cookie(sessioncookie);
        request->set_carrier_name(carrierName);

        Loc *ownedLocation = gpslocation->New();
        ownedLocation->CopyFrom(*gpslocation);
        request->set_allocated_gps_location(ownedLocation);

        // This is a carrier supplied token.
        if (verifyloctoken.length() != 0) {
            request->set_verify_loc_token(verifyloctoken);
        }

        return request;
    }

    // Carrier name can change depending on cell tower.
    unique_ptr<FindCloudletRequest> createFindCloudletRequest(const string carrierName, const shared_ptr<Loc> gpslocation) {
        unique_ptr<FindCloudletRequest> request = unique_ptr<FindCloudletRequest>(new FindCloudletRequest());

        request->set_ver(1);

        request->set_session_cookie(sessioncookie);
        request->set_carrier_name(carrierName);

        Loc *ownedLocation = gpslocation->New();
        ownedLocation->CopyFrom(*gpslocation);
        request->set_allocated_gps_location(ownedLocation);

        return request;
    }

    grpc::Status RegisterClient(const shared_ptr<RegisterClientRequest> request, RegisterClientReply &reply) {
        // As per GRPC documenation, DO NOT REUSE contexts across RPCs.
        ClientContext context;

        // Context deadline is in seconds.
        system_clock::time_point deadline = chrono::system_clock::now() + chrono::seconds(timeoutSec);
        context.set_deadline(deadline);

        grpc::Status grpcStatus = stub_->RegisterClient(&context, *request, &reply);

        // Save some Mex state info for other calls.
        this->sessioncookie = reply.session_cookie();
        this->tokenserveruri = reply.token_server_uri();

        return grpcStatus;
    }

    grpc::Status VerifyLocation(const shared_ptr<VerifyLocationRequest> request, VerifyLocationReply &reply) {
        string token = getToken(tokenserveruri);

        ClientContext context;
        // Context deadline is in seconds.
        system_clock::time_point deadline = chrono::system_clock::now() + chrono::seconds(timeoutSec);
        context.set_deadline(deadline);

        // Recreate request with the new token:
        unique_ptr<VerifyLocationRequest> tokenizedRequest = unique_ptr<VerifyLocationRequest>(new VerifyLocationRequest());
        tokenizedRequest->CopyFrom(*request);

        tokenizedRequest->set_verify_loc_token(token);
        grpc::Status grpcStatus = stub_->VerifyLocation(&context, *tokenizedRequest, &reply);

        return grpcStatus;
    }

    grpc::Status FindCloudlet(const shared_ptr<FindCloudletRequest> request, FindCloudletReply &reply) {
        ClientContext context;
        // Context deadline is in seconds.
        system_clock::time_point deadline = chrono::system_clock::now() + chrono::seconds(timeoutSec);
        context.set_deadline(deadline);

        grpc::Status grpcStatus = stub_->FindCloudlet(&context, *request, &reply);

        return grpcStatus;
    }

    string getToken(const string &uri) {
        cout << "In getToken" << endl;
        if (uri.length() == 0) {
            cerr << "No URI to get token!" << endl;
            return NULL;
        }

        // Since GPRC's Channel is somewhat hidden
        // we can use CURL here instead.
        CURL *curl = curl_easy_init();
        if (curl == NULL) {
            cerr << "Curl could not be initialized." << endl;
            return NULL;
        }
        CURLcode res;
        cout << "uri: " << uri << endl;
        curl_easy_setopt(curl, CURLOPT_URL, uri.c_str());
        curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, false);  // Do not follow redirect.
        curl_easy_setopt(curl, CURLOPT_HEADER, 1);              // Keep headers.

        // Set return pointer (the token), for the header callback.
        curl_easy_setopt(curl, CURLOPT_HEADERDATA, &(this->token));
        curl_easy_setopt(curl, CURLOPT_HEADERFUNCTION, header_callback);

        // verify peer or disconnect
        curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 1L);

        res = curl_easy_perform(curl);
        if (res != CURLE_OK) {
           cerr << "Error getting token: " << res << endl;
        }

        curl_easy_cleanup(curl);

        return token;
    }

  private:
    std::unique_ptr<MatchEngineApi::Stub> stub_;
    string token;  // short lived carrier dt-id token.
    string tokenserveruri;
    string sessioncookie;

    static string parseParameter(const string &queryParameter, const string keyFind) {
        string value;
        string foundToken;
        size_t vpos = queryParameter.find("=");

        string key = queryParameter.substr(0, vpos);
        cout << "Key: " << key << endl;
        vpos += 1; // skip over '='
        string valPart = queryParameter.substr(vpos, queryParameter.length() - vpos);
        cout << "ValPart: " << valPart << endl;
        if ((key == keyFind) && (vpos != std::string::npos)) {

            if (vpos < queryParameter.length()) {
                foundToken = queryParameter.substr(vpos, queryParameter.length() - vpos);
                cout << "Found Token: " << foundToken << endl;
            }
        }
        return foundToken;
    }

    static string parseToken(const string &locationUri) {
        // Looking for carrier dt-id: <token> in the URL, and ignoring everything else.
        size_t pos = locationUri.find("?");
        pos += 1;
        string uriParameters = locationUri.substr(pos, locationUri.length() - pos);
        pos = 0;
        size_t start = 0;
        string foundToken;

        // Carrier token.
        string keyFind = "dt-id";

        string queryParameter;
        do {
            pos = uriParameters.find("&", start);
            if (pos+1 >= uriParameters.length()) {
                break;
            }

            if (pos == std::string::npos) {  // Last one, or no terminating &
                queryParameter = uriParameters.substr(start, uriParameters.length() - start);
                foundToken = parseParameter(queryParameter, keyFind);
                break;
            } else {
                queryParameter = uriParameters.substr(start, pos - start);
                cout << "Substring: " << queryParameter << endl;
                foundToken = parseParameter(queryParameter, keyFind);
            }

            // Next.
            start = pos+1;
            if (foundToken != "") {
                break;
            }
        } while (pos != std::string::npos);

        return foundToken;
    }

    static string trimStringEol(const string &stringBuf) {
        size_t size = stringBuf.length();

        // HTTP/1.1 RFC 2616: Should only be "\r\n" (and not '\n')
        if (size >= 2 && (stringBuf[size-2] == '\r' && stringBuf[size-1] == '\n')) {
            size_t seol = size-2;
            return stringBuf.substr(0,seol);
        } else {
            // Not expected EOL format, returning as-is.
            return stringBuf;
        }

    }

    // Callback function to retrieve headers, called once per header line.
    static size_t header_callback(const char *buffer, size_t size, size_t n_items, void *userdata) {
        size_t bufferLen = n_items * size;

        // Need to get "Location: ....dt-id=ABCDEF01234"
        string stringBuf(buffer);
        stringBuf = trimStringEol(stringBuf);

        string key = "";
        string value = "";
        string *token = (string *)userdata;

        // split buffer:
        size_t colonPos = stringBuf.find(":");
        size_t blankPos;

        if (colonPos != std::string::npos) {
            key = stringBuf.substr(0, colonPos);
            if (key == "Location") {
                // Skip blank
                blankPos = stringBuf.find(" ") + 1;
                if ((blankPos != std::string::npos) &&
                    (blankPos < stringBuf.length())) {
                    value = stringBuf.substr(blankPos, stringBuf.length() - blankPos);
                    cout << "Location Header Value: " << value << endl;
                    *token = parseToken(value);
                }
            }
        }

        // Return number of bytes read thus far from reply stream.
        return bufferLen;
    }
};

int main() {
    cout << "FindCloudletNoLocation Test Case" << endl;
    cout << endl;
    string host = "us-qa.dme.mobiledgex.net:50051";
    const string tokenURI = "http://mexdemo.tok.mobiledgex.net:9999/its?followURL=https://dme.mobiledgex.net/verifyLoc";
    double expTime = 0;
    double iatTime = 0;
    int sessionTime = 0;
    int expCatch = 0;
    int iatCatch = 0;
    const std::regex regexPat("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$");
    
    // Credentials, Mutual Authentication:
    stringstream ssUri;
    ssUri << host;
    auto channel_creds = grpc::SslCredentials(grpc::SslCredentialsOptions());
    shared_ptr<Channel> channel = grpc::CreateChannel(ssUri.str(), channel_creds);

    cout << "Url to use: " << ssUri.str() << endl;
    unique_ptr<MexGrpcClient> mexClient = unique_ptr<MexGrpcClient>(new MexGrpcClient(channel));

    try {
        shared_ptr<Loc> loc = mexClient->retrieveLocation();

        RegisterClientReply registerClientReply;
        shared_ptr<RegisterClientRequest> registerClientRequest = unique_ptr<RegisterClientRequest>(mexClient->createRegisterClientRequest(""));
        grpc::Status grpcStatus = mexClient->RegisterClient(registerClientRequest, registerClientReply);

        if (!grpcStatus.ok()) {
            cerr << "GPRC RegisterClient Error: " << grpcStatus.error_message() << endl;
            return 1;
        } else {
            // Get the token (and wait for it)
            // GPRC uses "Channel". But, we can use libcurl here.
	  if(tokenURI == registerClientReply.token_server_uri()){
            cout << "Token Server URI Matches!" << endl;
          } else {
	    cout << "Token Server URI Does Not Match!" << endl;
	    exit (EXIT_FAILURE);
	  }   
	  
	    auto decoded = jwt::decode(registerClientReply.session_cookie());

	    for(auto& e : decoded.get_payload_claims()){
	      if (e.first == "exp"){
		  expCatch = (int)e.second.to_json().get<double>();		  
              }
	      if (e.first == "iat"){
		  iatCatch = (int)e.second.to_json().get<double>();
	      }
	      if (e.first == "key") {
		  //std::cout << "KEY: " << e.first << " = " << e.second.to_json() << std::endl;
		  //cout << e.second.to_json().get("appname") << endl;
		string appName = e.second.to_json().get("appname").get<string>().c_str();
		if(appName == "automation_api_app") {
		    cout << "APP NAME CORRECT! " << appName << endl;
		} else {
		    cout << "APP NAME INCORRECT! " << appName << endl;
		    exit (EXIT_FAILURE);
		}
		string orgName =  e.second.to_json().get("orgname").get<string>().c_str();
		if(orgName == "MobiledgeX") {
		    cout << "ORG NAME CORRECT! " << orgName << endl;
		} else {
		    cout << "ORG NAME INCORRECT! " << orgName << endl;
		    exit (EXIT_FAILURE);
		}
		string appVers =  e.second.to_json().get("appvers").get<string>().c_str();
		if(appVers == "1.0") {
		    cout << "APP VERSION CORRECT! " << appVers << endl;
		} else {
		    cout << "APP VERSION INCORRECT! " << appVers << endl;
		    exit (EXIT_FAILURE);
		}
		string peerIP =  e.second.to_json().get("peerip").get<string>().c_str();
		if(std::regex_match(peerIP, regexPat)) {
		    cout << "PEER IP PATTEREN IS CORRECT! " << peerIP << endl;
		} else {
		    cout << "PEER IP PATTEREN IS INCORRECT! " << peerIP << endl;
		    exit (EXIT_FAILURE);
		}

	      }
	      
	    }
	    sessionTime =  expCatch - iatCatch;
	    sessionTime /= 60;
	    sessionTime /= 60;
	    if (sessionTime == 24){
		cout << "Session Time Correct! " << sessionTime << endl;
	    } else {
		cout << "Session Time Not Correct! " << sessionTime << endl;
		exit (EXIT_FAILURE);
	    }

	    
	    cout << endl << "Finding nearest Cloudlet appInsts matching this Mex client." << endl;

	    FindCloudletReply findCloudletReply;
	    loc = mexClient->retrieveBadLocation();
	    shared_ptr<FindCloudletRequest> findCloudletRequest = unique_ptr<FindCloudletRequest>(
	    mexClient->createFindCloudletRequest(mexClient->getCarrierName(), loc));
	    grpcStatus = mexClient->FindCloudlet(findCloudletRequest, findCloudletReply);

	    if (!grpcStatus.ok()) {
	      cerr << "Test Case Pass!!  Received Error: " << grpcStatus.error_message() << endl << endl;
	      exit(0);
	    } else {
	      cout << "Location Found Status: " << findCloudletReply.status() << endl
		   << "Location of cloudlet. Latitude: " << findCloudletReply.cloudlet_location().latitude() << endl
		   << "Longitude: " << findCloudletReply.cloudlet_location().longitude() << endl
		   << "Cloudlet FQDN: " << findCloudletReply.fqdn() << endl
		   << "Test Case Pass!! " << endl;

	      for (int i = 0; i < findCloudletReply.ports_size(); i++) {
                cout << ", AppPort: Protocol: " << findCloudletReply.ports().Get(i).proto()
                     << ", AppPort: Internal Port: " << findCloudletReply.ports().Get(i).internal_port()
                     << ", AppPort: Public Port: " << findCloudletReply.ports().Get(i).public_port()
                     << endl;
	      }
	      cout << endl;	    	    
	    
	    }
	}
	    
	} catch (std::runtime_error &re) {
	  cerr << "Runtime error occurred: " << re.what() << endl;
	} catch (std::exception &ex) {
	  cerr << "Exception ocurred: " << ex.what() << endl;
	} catch (char *what) {
	  cerr << "Exception: " << what << endl;
	} catch (...) {
	  cerr << "Unknown failure happened." << endl;
	}
	
	return 0;
    
}
