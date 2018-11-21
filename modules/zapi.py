from webservice import WebService
#from base64 import b64encode
import base64
from pprint import pprint
import json
import logging
import subprocess
import string
import jwt
import hashlib
import time
import urllib

class Zapi(WebService):
    #base_url = 'https://issues.prodea.com:8443/rest/zapi/latest/'
    base_url = 'https://prod-api.zephyr4jiracloud.com/connect/'
    #zephyr_base_url = 'https://issues.prodea.com:8443/jira/rest/zephyr/latest/'
    zephyr_base_url = 'https://prod-api.zephyr4jiracloud.com/connect'
    headers = None
    auth64_string = None
    #auth = None

    def __init__(self, username = 'eng-dashboard', password = 'DallasDallas5', http_trace=False, access_key=None, secret_key=None, debug=False):
        WebService.__init__(self, http_trace=http_trace, debug=debug)
        self.username = username
        self.access_key = access_key
        self.secret_key = secret_key
        
        #        logging.getLogger(__name__).addHandler(logging.NullHandler())
        logging.getLogger(__name__)
        #if username is None:
        #    username = self.username
        #if password is None:
        #    password = self.password

        #auth_string = username + ':' + password
        #auth = base64.b64encode(auth_string.encode('ascii'))
        #auth64_string = base64.b64decode(auth).decode('utf-8')
        #self.auth64_string = str(auth, 'utf-8')
        #self.headers = {'Authorization': 'Basic ' + self.auth64_string, 'Content-Type': 'application/json'}

        #logging.debug("username=" + username + " password=" + password + " auth=" + self.auth64_string)
        logging.debug("username=" + username + " access_key=" + access_key + " secret_key=" + secret_key)

        #jwt = self._generate_jwt(username=username, access_key=access_key, secret_key=secret_key, url=self.zephyr_base_url)
        #logging.debug('jwt=' + str(jwt))
        #self.headers = {'Authorization': 'JWT ' + jwt, 'Content-Type': 'application/json', 'zapiAccessKey': access_key}
        self.headers = {'Authorization': 'JWT notset', 'Content-Type': 'application/json', 'zapiAccessKey': access_key}
        
    def query_zql(self, query = None):
        url = self.base_url + 'search' + '?' + urlencode

    def get_projects(self):
        url = self.base_url + 'util/project-list'
        logging.debug('url=' + url)

        self.get(url,headers = self.headers)
        content = self.resp.content.decode('utf-8')

        if "errorDesc" in content:
            logging.error('ERROR:' + content)
            return None
        else:
            return content

    def get_project_id(self, name=None):
        logging.debug('project name=' + name)

        project_list = self.get_projects()
        content = json.loads(project_list)

        pid = -1
        for i in content['options']:
            logging.debug('checking ' + i['label'].strip() + ' against ' + name.strip())
            if i['label'].strip() == name.strip():
                logging.debug('found:' + i['label'])
                pid = i['value']
                break

        return pid

    def get_cycles(self, project_id=None, version_id=None):
        relative_path = '/public/rest/api/1.0/cycles/search'
        query = 'projectId=' + str(project_id) + '&versionId=' + str(version_id)

        url = self.zephyr_base_url + relative_path + '?' + query
        logging.debug('url=' + url)

        jwt = self._generate_jwt('GET&' + relative_path + '&' + query)

        self.headers['Content-Type'] = 'text/plain'
        self.get(url,headers = self.headers)
        
        content = self.resp.content.decode('utf-8')

        if "errorDesc" in content:
            logging.error('ERROR:' + content)
            return None
        else:
            logging.debug('respxx=' + content)
            return content

    def get_cycle_id(self, name=None, project_id=None, version_id=None):
        logging.debug('name=' + name)

        cycle_list = self.get_cycles(project_id=project_id, version_id=version_id)
        content = json.loads(cycle_list)
        #print('cycle content')
        #pprint(content)
        #print('keys=%s' % content.keys())
        pid = -1
        for i in content:
            if i != 'recordsCount':
                print('key=' + i)
                logging.debug('checking ' + content[i]['name'] + ' against ' + name)
                if content[i]['name'] == name:
                    logging.debug('found:' + content[i]['name'])
                    pid = i
                    break

        return pid

    def get_versions(self, project_id=None):
        #url = self.base_url + 'util/versionBoard-list?projectId=' + project_id + '&versionId=10.1'
        url = self.base_url + 'util/versionBoard-list?projectId=' + str(project_id)
        logging.debug('url=' + url)

        self.get(url,headers = self.headers)
        content = self.resp.content.decode('utf-8')

        if "errorDesc" in content:
            logging.error('ERROR:' + content)
            return None
        else:
            #print(content)
            return content

    def get_version_id(self, project_id=None, version_name=None):
        logging.debug('name=' + version_name)

        version_list = self.get_versions(project_id=project_id)
        content = json.loads(version_list)

        vid = -1
        for i in content['unreleasedVersions']:
            logging.debug('checking ' + i['label'] + ' against ' + version_name)
            if i['label'] == version_name:
                logging.debug('found:' + i['label'])
                vid = i['value']
                break

        return vid

    def get_execution_list(self, project_id=None, version_id=None, cycle_id=None, issue_id=None, limit=None):
        logging.debug('issue id=' + str(issue_id))
        
#        url = self.base_url + 'execution?issueId=' + issue_id + '&projectId=' + project_id + '&versionId=' + version_id + 'cycleId=' + cycle_id
        url = self.base_url + 'execution?issueId=' + str(issue_id)
        if limit is not None:
            url = url + '&limit=' + str(limit)
        logging.debug('url=' + url)

        self.get(url,headers = self.headers)
        content = self.resp.content.decode('utf-8')

        if "errorDesc" in content:
            logging.error('ERROR:' + content)
            return None
        else:
            logging.debug('resp=' + content)
            return content

    def get_defect_list(self, execution_id=None):
        logging.info('execution id=' + execution_id)
        url = self.base_url + 'execution/' + execution_id + '/defects'
        logging.debug('url=' + url)

        self.get(url,headers = self.headers)

        if "errorDesc" in self.resp.content:
            logging.error('ERROR:' + self.resp.content)
            return None
        else:
            print(self.resp.content)
            return self.resp.content

    def execute_query(self, query=None):
        logging.debug('query=' + query)
        relative_path = '/public/rest/api/1.0/zql/search'
        #url = self.base_url + 'zql/executeSearch?zqlQuery=' + query + '&maxRecords=2000'
        url = self.zephyr_base_url + relative_path  + '?isAdvanced=true'# + '?zqlQuery=' + query # + '&maxRecords=2000'
        logging.debug('url=' + url)

        #query = '{"maxRecords":20,"offset":0,"zqlQuery":"fixVersion = Version","fields":{"fixVersion":[{"id":10002,"name":"Version 3.0","projectId":10000,"released":false,"archived":false}]}}'
        #query = '{"maxRecords":20,"offset":0,"zqlQuery":"fixVersion = Nimbus"}' #project = "edge-cloud QA" AND fixVersion = "Nimbus"'# AND cycleName = "Supported"'
        data = '{"maxRecords":20,"offset":0, "zqlQuery":' + '"' + query + '"}'
        #data = query
        #post_data = '{"zqlQuery":"project=edge-cloud"}'
        #path = 'POST&/public/rest/api/1.0/zql/search&zqlQuery=' + query
        #path = 'POST&/public/rest/api/1.0/zql/search&' + urllib.parse.quote(data)
        path = 'POST&/public/rest/api/1.0/zql/search&isAdvanced=true'
        #path = 'POST&' + relative_path + '&%7B%22zqlQuery%22%3A%22project%3Dandy%22%7D'
        #path = 'POST&' + relative_path + '&' + 'zqlQuery=fixVersio%3DNimbus'
        #path = 'POST&' + relative_path + '&' + urllib.parse.quote('zqlQuery=' + query)
        #path = 'GET&/public/rest/api/1.0/zql/fields/values&'
        #POST&/public/rest/api/1.0/zql/search&%7B%22zqlQuery%22%3A%22project%3Dandy%22%7D
        print('path',path)

        jwt = self._generate_jwt(path)


        logging.debug('url=' + url + ' data=' + data)

        #self.headers['Content-Type'] = 'text/plain'
        self.headers['Content-Type'] = 'application/json'
        self.post(url, headers = self.headers, data=data)
        #self.post(url, headers = self.headers)

        
        #self.get(url,headers = self.headers)

        content = self.resp.content.decode('utf-8')

        if "errorDesc" in content:
            logging.error('ERROR:' + content)
            return None
        else:
            logging.debug('resp=' + content)
            return content

    def get_zql_field_values(self):
        relative_path = '/public/rest/api/1.0/zql/fields/values'
        url = self.zephyr_base_url + relative_path
        logging.debug('url=' + url)

        path = 'GET&' + relative_path + '&'
        jwt = self._generate_jwt(path)

        self.get(url,headers = self.headers)

        content = self.resp.content.decode('utf-8')

        return content
    
    def get_execution_summary_by_sprint_and_issue(self, id=None):
        url = self.zephyr_base_url + 'execution/executionSummariesBySprintAndIssue?sprintId=' + id
        logging.debug('url=' + url)
        self.post(url,headers = self.headers)

    def get_teststeps(self, issue_id=None, project_id=None):
        logging.info('issue id=' + str(issue_id))
        relative_path = '/public/rest/api/1.0/teststep/' + str(issue_id)
        parms = 'projectId=' + str(project_id)
        url = self.zephyr_base_url + relative_path + '?' + parms
        logging.debug('url=' + url)

        path = 'GET&' + relative_path + '&' + parms
        self._generate_jwt(path)

        self.headers['Content-Type'] = 'application/json'
        self.get(url,headers = self.headers)
        content = self.resp.content.decode('utf-8')

        if "errorDesc" in content:
            logging.error('ERROR:' + content)
            return None
        else:
            print(content)
            return content


    def update_status(self, id=None, status=None):
        logging.info('status=' + str(status))
        url = self.base_url + 'execution/updateBulkStatus'
        data = '{"executions":["' + str(id) + '"], "status": "' + str(status) + '"}'
        #data_json = json.dumps(data)
        logging.debug('url=' + url + ' data=' + data)

        #h = self.headers
        #h['content-type'] = 'application/json'
        print(self.headers)
        self.put(url,headers = self.headers, data=data)
        content = self.resp.content.decode('utf-8')

        if "errorDesc" in content:
            logging.error('ERROR:' + content)
            return None
        else:
            print(content)
            return content

    def update_execution_details(self, execution_id=None, defect_list=None):
        """Update the execution details for a given execution id

        Example:
           >>> z.update_execution_details(execution_id=94969, defect_list=['PSR-12345', 'PSR-46383'])

        Args:
           - **execution_id** (str, mandatory): execution id of the issue to update. No default
           - **defect_list** (list of str, mandatory): list of the defects to add to the execution id. No default.

        Returns:
           dict: A dictionary result from zephyr

        Notes:
           execution id is not the same as the tcid (QA-1116). It is an internal id used by zephyr. You can get the id by executing a zquery:
              >>> zephyrQueryUrl = "project=" + project + " AND fixVersion=\"" + version + "\" AND cycleName in (\"" + cycle + "\") AND summary ~ \"" + summary + "\" ORDER BY Issue ASC"
              >>> result = z.execute_query(zephyrQueryUrl)

           PUT https://issues.prodea.com:8443/rest/zapi/latest/execution/94969/execute 
           data={"defectList":["PSR-12345", "PSR-46383"], "updateDefectList": "true"}
        """

        logging.info('id=' + str(execution_id) + ' defect_list=' + str(defect_list))
        url = self.base_url + 'execution/' + str(execution_id) + '/execute'

        defect_list_string = str(defect_list).replace("\'", "\"")
        data = '{"defectList":' + defect_list_string + ', "updateDefectList": "true"}'
        logging.debug('url=' + url + ' data=' + data)

        self.put(url,headers = self.headers, data=data)
        content = self.resp.content.decode('utf-8')

        if "errorDesc" in content:
            logging.error('ERROR:' + content)
            return None
        else:
            #print(content)
            return content

    def create_cycle(self, project_id=None, version_id=None, cycle_name=None, build=None):
        """Create a new cycle in a given project and version

        Example:
           >>> project_id = z.get_project_id('QA')
           >>> version_id = z.get_version_id(project_id, 'Automation')
           >>> z.create_cycle(project_id=project_id, version_id=version_id, cycle_name=new_cycle, build=new_cycle)

        Args:
           - **project_id** (str, mandatory): project id of the project to create the cycle as returned by get_project_id(). No default
           - **version_id** (str, mandatory): version id of the version to create the cycle as returned by get_version_id(). No default
           - **cycle_name** (str, mandatory): cycle name to create. No default.
           - **build** (str, optional): value to set the cycle Build field. Default is empty string.

        Returns:
           str or None: response from the web service call or None if the response contains an errDesc value
           
        """

        logging.info("cycle_name=%s, project_id=%s, version_id=%s, build=%s" % (cycle_name, project_id, version_id, build))

        build_to_set = ''
        if build:
            build_to_set = build
            
        url = self.base_url + 'cycle'
        data = '{"name":"' + cycle_name + '", "projectId": "' + project_id + '", "versionId":"' + version_id + '", "build":"' + build_to_set +'"}'
        logging.debug('url=' + url + ' data=' + data)

        self.post(url, headers = self.headers, data=data)

        content = self.resp.content.decode('utf-8')

        if "errorDesc" in content:
            logging.error('ERROR:' + content)
            return None
        else:
            print(content)
            return content

    def update_cycle(self, cycle_id=None, name=None, build=None, start_date=None, end_date=None):
        """Update a cycle with the given data

        Example:
           >>> start_date = time.strftime('%d/%b/%y', time.gmtime())
           >>> cycle_id = z.get_cycle_id('ROS6000_Prodea_11.0.786')
           >>> z.update_cycle(cycle_id=cycle_id, start_data=start_date)

        Args:
           - **cycle_id** (str, mandatory): cycle id of the cycle as returned by get_cycle_id(). No default
           - **name** (str, optional): value to update the cycle name.
           - **build** (str, optional): value to update the cycle Build field.
           - **start_date** (str, optional): value to update the cycle start date field.
           - **end_date** (str, optional): value to update the cycle end date field.

        Returns:
           str or None: response from the web service call or None if the response contains an errDesc value
           
        """

        logging.info("cycle_id=%s, name=%s, build=%s, start_date=%s, end_data=%s" % (cycle_id, name, build, start_date, end_date))

        build_to_set = ''
        if build:
            build_to_set = build
            
        url = self.base_url + 'cycle'
        data = '{"id":"' + cycle_id + '"'
        if name:
            data = data + ', "name": "' + name + '"'
        if start_date:
            data = data + ', "startDate": "' + start_date + '"'
        if end_date:
            data = data + ', "endDate": "' + end_date + '"'
        data = data + '}'
        logging.debug('url=' + url + ' data=' + data)

        self.put(url, headers = self.headers, data=data)

        content = self.resp.content.decode('utf-8')
        print(content)
        if "updated successfully" not in content:
            logging.error('ERROR:' + content)
            return None
        else:
            print(content)
            return content

    def add_tests_to_cycle(self, project_id=None, version_id=None, cycle_id=None, issues=None):
        logging.info("cycle_id=%s, project_id=%s, version_id=%s" % (cycle_id, project_id, version_id))

        url = self.base_url + 'execution/addTestsToCycle'
        logging.debug('url=' + url)

        i = str(issues).replace('\'', '"')
        #data = '{"cycleId":"' + cycle_id + '", "projectId": "' + project_id + '", "versionId":"' + version_id + '", "method": "1", "issues":' + i + '}'
        data = '{"assigneetype":0, "cycleId":"' + cycle_id + '", "projectId": "' + project_id + '", "versionId":"' + version_id + '", "method": "1", "issues":' + i + '}'

        print(data)
        #print(str(issues))

        self.post(url, headers = self.headers, data=data)

        content = self.resp.content.decode('utf-8')

        if "errorDesc" in content:
            logging.error('ERROR:' + content)
            return None
        else:
            print(content)
            return content

        
    def add_attachment(self, id=None,  file=None, type='execution'):
        logging.info('id=' + str(id) + " type=" + type + " file=" + file)

        url = self.base_url + 'attachment?entityId=' + str(id) + '&entityType=' + type
        logging.debug('url=' + url)

        #h = self.headers
        #h['X-Atlassian-Token'] = 'nocheck'
        #h['Content-Type'] = 'multipart/form-data'
        #h['Accept'] = 'application/json'
        #del h['Content-Type'] # delete the 
        #print(h)
        #f = {'file': open(file, 'rb')}
        #fo = open(file, 'rb')
        #f = {'file': ('andy', open(file, 'rb'), "multipart/form-data")}
        #f = {'file': ('andy.txt', open(file, 'r'), "multipart/form-data")}
        #print(f)
        #self.post(url,headers = h, files=f)
        #content = self.resp.content.decode('utf-8')
        exec_cmd = 'curl -k -X POST -H "Authorization: Basic ' + self.auth64_string + '" "' + url + '" -H "X-Atlassian-Token: nocheck" -F "file=@' + file + '"'
        try:
            logging.info("curlcmd=" + exec_cmd)
            r = subprocess.run(exec_cmd, shell=True, check=True)
        except subprocess.CalledProcessError as err:
            #print(err)
            print("curl failed. return code=: " + str(err.returncode))


        #if "errorDesc" in content:
        #    logging.error('ERROR:' + content)
        #    return None
        #else:
        #    print(content)
        #    return content

    def create_teststep(self, issue_id = None, step = None, data = '', result = ''):
        logging.info('issue_id =' + issue_id)
        
        url = self.base_url + 'teststep/' + issue_id
        logging.debug('url=' + url)

        data_hash = {}
        data_hash['step'] = step
        data_hash['data'] = data
        data_hash['result'] = result
        data_fields_json = json.dumps(data_hash)

        resp = super().post(url, data = data_fields_json, headers = self.headers)
        self.decoded_data = json.loads(resp.content.decode("utf-8"))

    def get_server_info(self):
        logging.info('get_server_info')

        #url = self.base_url + 'public/rest/api/1.0/serverinfo'
        #url = 'https://prod-api.zephyr4jiracloud.com/connect/' + 'public/rest/api/1.0/serverinfo'
        url = self.zephyr_base_url + 'public/rest/api/1.0/serverinfo'

        jwt = self._generate_jwt('GET&/public/rest/api/1.0/serverinfo&')

        self.get(url,headers = self.headers)
        content = self.resp.content.decode('utf-8')
        print(content)

        return content
    
    #def _generate_jwt(self, username, access_key, secret_key, url):
    def _generate_jwt(self, canonical_path):
        #print(username,access_key,secret_key,url)
        #canonical_path = 'GET&' + '/public/rest/api/1.0/cycles/search' + '&' + 'projectId=10004&versionId=10004'
        #canonical_path = 'GET&' + '/public/rest/api/1.0/serverinfo' + '&'# + '/'
        #ce = hashlib.sha256('foo'.encode('utf-8')).hexdigest()
        #print('ce',ce)
        print(canonical_path)
        payload = {
            'sub': self.username,
            #'qsh': hashlib.sha256(url.encode('utf-8')).hexdigest(),
            'qsh': hashlib.sha256(canonical_path.encode('utf-8')).hexdigest(),
            #'qsh': hashlib.sha256(canonical_path.encode('utf-8')),
            'iss': self.access_key,
            'exp': time.time() + 3600,
            'iat': time.time()
        }
        #token = jwt.encode(payload, secret_key, algorithm='HS256')
        token = jwt.encode(payload, self.secret_key, algorithm='HS256').strip().decode('utf-8')
        #print('t1',token)
        #token2 = jwt.encode(payload, secret_key, algorithm='HS256').decode('utf-8')
        #print('t2',token2)
        #token3 = jwt.encode(payload, secret_key, algorithm='HS256')
        #print('t3',token3)
        
        logging.debug('jwt=' + str(token))
        #self.headers = {'Authorization': 'JWT ' + token, 'Content-Type': 'application/json', 'zapiAccessKey': self.access_key}
        print('h', self.headers['Authorization'])
        self.headers['Authorization'] = 'JWT ' + token
        
        return token
