from webservice import WebService
import base64
from pprint import pprint
import json
import logging

class Jiraapi(WebService):
    base_url = 'https://mobiledgex.atlassian.net/rest/api/2'
                
    headers = None
    decoded_data = None
    #auth = None

    def __init__(self, username = 'eng-dashboard', password = 'DallasDallas5', token=None):
        WebService.__init__(self)

        #if username is None:
        #    username = self.username
        #if password is None:
        #    password = self.password

        #auth_string = username + ':' + password
        #auth = base64.b64encode(auth_string.encode('ascii'))
        #auth64_string = str(auth, 'utf-8')
        auth_string = username + ':' + token
        auth = base64.b64encode(auth_string.encode('ascii'))
        auth64_string = str(auth, 'utf-8')        
        print(auth_string, auth, auth64_string)
        
        #self.headers = {'Authorization': 'Basic ' + auth64_string, 'Content-Type': 'application/json;charset=UTF-8', 'Accept': 'application/json'}
        self.headers = {'Authorization': 'Basic ' + auth64_string, 'Content-Type': 'application/json', 'Accept': 'application/json'}


        #logging.debug("username=" + username + " password=" + password + " auth=" + auth64_string)
        logging.debug("username=" + username + "token=" + token)

    def search(self, query = None, start_at=0, max_results=100):
        url = self.base_url + '/search' + '?startAt=' + str(start_at) + '&jql=' + query + '&maxResults=' + str(max_results)
        logging.debug('url=' + url)

        self.get(url,headers = self.headers)
        content = self.resp.content.decode('utf-8')

        if "errorDesc" in content:
            logging.error('ERROR:' + content)
            return None
        else:
            logging.debug('resp=' + content)
            return content

    def create_issue(self, project = None, issue_type = None, summary = None, description = None, components = None):
        url = self.base_url + 'issue' 
        logging.debug('url=' + url)

        data = {}
        data['project'] = {'key' : project}
        if summary:
            data['summary'] = summary
        if description:
            data['description'] = description
        data['issuetype'] = {'name': issue_type }
        data['components'] = components
        data_fields = {'fields': data}
        data_fields_json = json.dumps(data_fields)
        print(data_fields_json)

        resp = super().post(url, data = data_fields_json, headers = self.headers)
        self.decoded_data = json.loads(resp.content.decode("utf-8"))

        print(resp.text)

        if str(resp.status_code) != '200' and str(resp.status_code) != '201':
            raise Exception("ws did return a 200 response. responseCode = " + str(self.resp.status_code) + ". ReponseBody=" + str(self.resp.text))


    def create_version(self, name = None, description = '', project = None):
        url = self.base_url + 'version' 
        logging.debug('url=' + url)

        data = {}
        data['description'] = description
        data['name'] = name
        data['project'] = project
        
        data_fields_json = json.dumps(data)
        print(data_fields_json)

        resp = super().post(url, data = data_fields_json, headers = self.headers)

    def create_component(self, project = None, name = None):
        url = self.base_url + 'component' 

        data = {}
        data['project'] = project
        data['name'] = name

        data_fields_json = json.dumps(data)
        print(data_fields_json)

        resp = super().post(url, data = data_fields_json, headers = self.headers)

        
    def get_project(self, name=None):
        url = self.base_url + '/project/' + name
        logging.debug('url=' + url)

        resp = super().get(url, headers = self.headers)

        content = self.resp.content.decode('utf-8')

        #print('content',content)

        return content

    def get_project_id(self, name):
        info = self.get_project(name)

        content = json.loads(info)

        pid = content['id']

        return pid
                
        
