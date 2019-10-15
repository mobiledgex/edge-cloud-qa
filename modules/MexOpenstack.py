import json
import logging
import os
import subprocess
import sys


class MexOpenstack():
    def __init__(self, environment_file):
        self.env_file = self._findFile(environment_file)

#global helpers functions on the head of class

    def _execute_cmd(self, cmd):
        o_return = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True, executable='/bin/bash')
        o_out = o_return.stdout.decode('utf-8')
        o_err = o_return.stderr.decode('utf-8')

        if o_err:
            raise Exception(o_err)

        logging.debug(o_out)

        return o_out
    
    def _findFile(self, path):
        for dirname in sys.path:
            candidate = os.path.join(dirname, path)
            if os.path.isfile(candidate):
                return candidate
        raise Exception('cant find file {}'.format(path))

    def delete_image(self, name=None):
        cmd = f'source {self.env_file};openstack image delete {name}'

        logging.debug(f'deleting openstack image with cmd = {cmd}')
        self._execute_cmd(cmd)

    def get_server_list(self, name=None):
        cmd = f'source {self.env_file};openstack server list -f json'

        if name:
            cmd += f' --name {name}'

        logging.debug(f'getting openstack server list with cmd = {cmd}')
        o_out = self._execute_cmd(cmd)
        
        return json.loads(o_out)

    def delete_stack(self, name=None):
        cmd = f'source {self.env_file};openstack stack delete {name} -y'
        logging.debug(f'deleting openstack stack with cmd = {cmd}')

        self._execute_cmd(cmd)

    def get_flavor_list(self):
        cmd = f'source {self.env_file};openstack flavor list -f json'

        logging.debug(f'getting flavor list with cmd = {cmd}')
        output = self._execute_cmd(cmd)
        
        return json.loads(output)

    def flavor_should_exist(self, flavors, ram, disk, cpu):
        for flavor in flavors:
            print('*WARN*', flavor['RAM'], flavor['Disk'], flavor['VCPUs'], ram, disk, cpu)
            if int(flavor['RAM']) == int(ram) and int(flavor['Disk']) == int(disk) and int(flavor['VCPUs']) == int(cpu):
                logging.info('found matching flavor', flavor)
                return True

        raise Exception(f'No flavor found matching ram={ram}, disk={disk}, cpu={cpu}')
    
    def get_openstack_flavour_list_oryg(self,name=None):
        cmd = f'source {self.env_file};openstack flavor list -f json'

        if name:
            cmd += f' --name {name}'

        logging.debug(f'getting router flavor list with cmd = {cmd}')
        o_return = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True, executable='/bin/bash')
        o_out = o_return.stdout.decode('utf-8')
        o_err = o_return.stderr.decode('utf-8')

        if o_err:
            raise Exception(o_err)

        logging.debug(o_out)
        
        return json.loads(o_out)


    def get_openstack_security_list(self,name=None):
        cmd = f'source {self.env_file};openstack security group list -f json'

        if name:
            cmd += f' --name {name}'

        logging.debug(f'getting security security group  list with cmd = {cmd}')
        o_return = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True, executable='/bin/bash')
        o_out = o_return.stdout.decode('utf-8')
        o_err = o_return.stderr.decode('utf-8')

        if o_err:
            raise Exception(o_err)

        logging.debug(o_out)
        
        return json.loads(o_out)

#------------------done functions

#//TODO sanity checking for input json
#//TODO logic issue: outcome is hashmap propbably it shall be simple list
#//TODO could be better
#//TOOD values min, max could be empty,null,string, non numeric and numeric (the only last is valid)
    def _checkConditions(self,param,dict,value):
        result={}
        ifmax=False
        ifmin=False
        if 'max' in dict:
            ifmax=True
            max=dict['max']
        if 'min' in dict:
            ifmin=True
            min=dict['min']

        if ifmax and ifmin:
            if (min <= value) and (max>=value):
                result['result']='PASS'
                result['comment']=""
            else:
                result['result']='FAILED'
                result['comment']=""
            return result
        if ifmax and not ifmin:
            if  max>=value:
                result['result']='PASS'
                result['comment']=""
            else:
                result['result']='FAILED'
                result['comment']=""
            return result
        if not ifmax and ifmin:
            if min <= value :
                result['result']='PASS'
                result['comment']=""
            else:
                result['result']='FAILED'
                result['comment']=""
            return result
#and weird case
#        if not ifmax and not ifmin:
#            if min <= value :
#                result['result']=1
#            else:
#                result['result']=0
#            return result
        result['result']='UNDEFINED'
        result['comment']='There is no valid condition to check parameter: '+param
        return result
    
    def _json2hash(self,data):
        outJson={}
        for x in data: 
            outJson[x["Name"]]=x["Value"]
        return outJson

    def get_openstack_limits(self,limit_dict_global):
        cmd = f'source {self.env_file};openstack limits show -f json --absolute'
        logging.debug(f'getting openstack limits show with cmd = {cmd}')
        o_out=self._execute_cmd(cmd)
        data = self._json2hash(json.loads(o_out))
        outcome={}
        limit_dict=limit_dict_global["get_openstack_limits"]
        for param in limit_dict:
            if param not in data:
                print("*Warn* ",param," not found in the openstack environment")
                result={}
                result['result']='ERROR'
                result['comment']="Parameter ["+param+"] not found in the openstack environment"
                outcome[param]=result
                continue
            outcome[param]=self._checkConditions(param,limit_dict[param],data[param])
 #       for x in outcome:
 #           print(x,":",outcome[x])
        return outcome



#design assumptions:
#in openstack server list -f json we have the following list of fields
# | ID  | Name     | Status | Networks   | Image     | Flavor      |
#it looks that only ID and Name can be unique

    def get_openstack_server_list(self, limit_dict_global):
        cmd = f'source {self.env_file};openstack server list -f json'
        logging.debug(f'getting openstack server list with cmd = {cmd}')
        o_out=self._execute_cmd(cmd)
        rawJson=json.loads(o_out)

#structures for faster access
        IDs={}
        idx=0
        for x in rawJson: 
            IDs[x["ID"]]=idx
            idx+=1
        
        outcome={}
        limit_dict=limit_dict_global["get_openstack_server_list"]
        for testEntry in limit_dict:
            test=testEntry["test"]
            result={}
            #generic assumption
            result['result']='ERROR'
            #we are looking if ID exist in openstack output
            if test["ID"] not in IDs:
                result['comment']="ID ["+test["ID"]+"] not found in the openstack server list"
                outcome[testEntry["testID"]]=result
                continue
            rec=rawJson[IDs[test["ID"]]]
            if test["ID"]!=rec["ID"]:
                result['comment']="ID ["+test["ID"]+"] not found in the openstack server list"
                outcome[testEntry["testID"]]=result
                continue
            if test["Status"]!=rec["Status"]:
                result['comment']="Status ["+test["ID"]+"] not found in the openstack server list"
                outcome[testEntry["testID"]]=result
                continue
            if test["Name"]!=rec["Name"]:
                result['comment']="Name ["+test["ID"]+"] not found in the openstack server list"
                outcome[testEntry["testID"]]=result
                continue
            if test["Image"]!=rec["Image"]:
                result['comment']="Image ["+test["ID"]+"] not found in the openstack server list"
                outcome[testEntry["testID"]]=result
                continue
            if test["Flavor"]!=rec["Flavor"]:
                result['comment']="Flavor ["+test["ID"]+"] not found in the openstack server list"
                outcome[testEntry["testID"]]=result
                continue
            if test["Networks"]!=rec["Networks"]:
                result['comment']="Networks ["+test["ID"]+"] not found in the openstack server list"
                outcome[testEntry["testID"]]=result
                continue
            result={}
            result['result']='PASS'
            result['comment']=""
            outcome[testEntry["testID"]]=result

        return outcome


#design assumptions:
#in openstack image list -f json we have the following list of fields
#ID  | Name  | Status
#it looks that only ID and Name can be unique

    def get_openstack_image_list(self, limit_dict_global):
        cmd = f'source {self.env_file};openstack image list -f json'
        logging.debug(f'getting openstack image list with cmd = {cmd}')
        o_out=self._execute_cmd(cmd)
        rawJson=json.loads(o_out)

#structures for faster access
        Names={}
        idx=0
        for x in rawJson: 
            Names[x["Name"]]=idx
            idx+=1
        
        outcome={}
        limit_dict=limit_dict_global["get_openstack_image_list"]
        for testEntry in limit_dict:
            test=testEntry["test"]
            result={}
            #generic assumption
            result['result']='ERROR'
            #we are looking if Name exist in openstack output
            if test["Name"] not in Names:
                result['comment']="Name ["+test["Name"]+"] not found in the openstack image list"
                outcome[testEntry["testID"]]=result
                continue
            rec=rawJson[Names[test["Name"]]]
            if test["Name"]!=rec["Name"]:
                result['comment']="Name ["+test["Name"]+"] not found in the openstack image list"
                outcome[testEntry["testID"]]=result
                continue
            if test["Status"]!=rec["Status"]:
                result['comment']="Status ["+test["Status"]+"] not found in the openstack image list"
                outcome[testEntry["testID"]]=result
                continue
            if test["ID"]!=rec["ID"]:
                result['comment']="ID ["+test["ID"]+"] not found in the openstack image list"
                outcome[testEntry["testID"]]=result
                continue
            result={}
            result['result']='PASS'
            result['comment']=""
            outcome[testEntry["testID"]]=result

        return outcome
    

#warning: format for subnets field is string of subnets, not array or list
    def _check_subnets(self,testInput,openstackInput):
        jsonTestInput=testInput.replace(' ','').split(',')
        jsonOpenstackInput=openstackInput.replace(' ','').split(',')
        outcome=[]
        hashMap={}
        for x in jsonOpenstackInput:
            hashMap[x]=0
        for x in jsonTestInput:
            if x not in hashMap:
                outcome.append(x)
        return outcome

#design assumptions:
#in openstack network list -f json we have the following list of fields
#ID  | Name  | Subnets
#it looks that only ID and Name can be unique

    def get_openstack_network_list(self, limit_dict_global):
        cmd = f'source {self.env_file};openstack network list -f json'
        logging.debug(f'getting openstack network list with cmd = {cmd}')
        o_out=self._execute_cmd(cmd)
        rawJson=json.loads(o_out)

#structures for faster access
        Names={}
        idx=0
        for x in rawJson: 
            Names[x["Name"]]=idx
            idx+=1
        
        outcome={}
        limit_dict=limit_dict_global["get_openstack_network_list"]
        for testEntry in limit_dict:
            test=testEntry["test"]
            result={}
            #generic assumption
            result['result']='ERROR'
            #we are looking if Name exist in openstack output
            if test["Name"] not in Names:
                result['comment']="Name ["+test["Name"]+"] not found in the openstack network list"
                outcome[testEntry["testID"]]=result
                continue
            rec=rawJson[Names[test["Name"]]]
            if test["Name"]!=rec["Name"]:
                result['comment']="Name ["+test["Name"]+"] not found in the openstack network list"
                outcome[testEntry["testID"]]=result
                continue
            if test["ID"]!=rec["ID"]:
                result['comment']="ID ["+test["ID"]+"] not found in the openstack network list"
                outcome[testEntry["testID"]]=result
                continue
            checkRes=self._check_subnets(test["Subnets"],rec["Subnets"])
            if len(checkRes)>0:
                result['comment']="The following subnets "+json.dumps(checkRes)+" not found in the openstack network list"
                outcome[testEntry["testID"]]=result
                continue

            result={}
            result['result']='PASS'
            result['comment']=""
            outcome[testEntry["testID"]]=result

        return outcome


#design assumptions:
#in openstack subnet list -f json we have the following list of fields
#ID  | Name  | Status| Network
#it looks that only ID and Name can be unique

    def get_openstack_subnet_list(self, limit_dict_global):
        cmd = f'source {self.env_file};openstack subnet list -f json'
        logging.debug(f'getting openstack subnet list with cmd = {cmd}')
        o_out=self._execute_cmd(cmd)
        rawJson=json.loads(o_out)

#structures for faster access
        Names={}
        idx=0
        for x in rawJson: 
            Names[x["Name"]]=idx
            idx+=1
        
        outcome={}
        limit_dict=limit_dict_global["get_openstack_subnet_list"]
        for testEntry in limit_dict:
            test=testEntry["test"]
            result={}
            #generic assumption
            result['result']='ERROR'
            #we are looking if Name exist in openstack output
            if test["Name"] not in Names:
                result['comment']="Name ["+test["Name"]+"] not found in the openstack subnet list"
                outcome[testEntry["testID"]]=result
                continue
            rec=rawJson[Names[test["Name"]]]
            if test["Name"]!=rec["Name"]:
                result['comment']="Name ["+test["Name"]+"] not found in the openstack subnet list"
                outcome[testEntry["testID"]]=result
                continue
            if test["Subnet"]!=rec["Subnet"]:
                result['comment']="Subnet ["+test["Subnet"]+"] not found in the openstack subnet list"
                outcome[testEntry["testID"]]=result
                continue
            if test["Network"]!=rec["Network"]:
                result['comment']="Network ["+test["Network"]+"] not found in the openstack subnet list"
                outcome[testEntry["testID"]]=result
                continue
            if test["ID"]!=rec["ID"]:
                result['comment']="ID ["+test["ID"]+"] not found in the openstack subnet list"
                outcome[testEntry["testID"]]=result
                continue
            result={}
            result['result']='PASS'
            result['comment']=""
            outcome[testEntry["testID"]]=result

        return outcome
    

#design assumptions:
#in openstack router list -f json we have the following list of fields
#ID  | Name  | State| Project | Status
#it looks that only ID and Name can be unique

    def get_openstack_router_list(self, limit_dict_global):
        cmd = f'source {self.env_file};openstack router list -f json'
        logging.debug(f'getting openstack router list with cmd = {cmd}')
        o_out=self._execute_cmd(cmd)
        rawJson=json.loads(o_out)

#structures for faster access
        Names={}
        idx=0
        for x in rawJson: 
            Names[x["Name"]]=idx
            idx+=1
        
        outcome={}
        limit_dict=limit_dict_global["get_openstack_router_list"]
        for testEntry in limit_dict:
            test=testEntry["test"]
            result={}
            #generic assumption
            result['result']='ERROR'
            #we are looking if Name exist in openstack output
            if test["Name"] not in Names:
                result['comment']="Name ["+test["Name"]+"] not found in the openstack router list"
                outcome[testEntry["testID"]]=result
                continue
            rec=rawJson[Names[test["Name"]]]
            if test["Name"]!=rec["Name"]:
                result['comment']="Name ["+test["Name"]+"] not found in the openstack router list"
                outcome[testEntry["testID"]]=result
                continue
            if test["State"]!=rec["State"]:
                result['comment']="State ["+test["State"]+"] not found in the openstack router list"
                outcome[testEntry["testID"]]=result
                continue
            if test["Project"]!=rec["Project"]:
                result['comment']="Network ["+test["Project"]+"] not found in the openstack router list"
                outcome[testEntry["testID"]]=result
                continue
            if test["Status"]!=rec["Status"]:
                result['comment']="Status ["+test["Status"]+"] not found in the openstack router list"
                outcome[testEntry["testID"]]=result
                continue
            if test["ID"]!=rec["ID"]:
                result['comment']="ID ["+test["ID"]+"] not found in the openstack router list"
                outcome[testEntry["testID"]]=result
                continue
            result={}
            result['result']='PASS'
            result['comment']=""
            outcome[testEntry["testID"]]=result

        return outcome
    


#design assumptions:
#in openstack flavor list -f json we have the following list of fields
#ID  | Name  | RAM| Ephemeral | VCPUs | Is Public |Disk
#it looks that only ID and Name can be unique

    def get_openstack_flavor_list(self, limit_dict_global):
        cmd = f'source {self.env_file};openstack flavor list -f json'
        logging.debug(f'getting openstack flavor list with cmd = {cmd}')
        o_out=self._execute_cmd(cmd)
        rawJson=json.loads(o_out)

#structures for faster access
        Names={}
        idx=0
        for x in rawJson: 
            Names[x["Name"]]=idx
            idx+=1
        
        outcome={}
        limit_dict=limit_dict_global["get_openstack_flavor_list"]
        for testEntry in limit_dict:
            test=testEntry["test"]
            result={}
            #generic assumption
            result['result']='ERROR'
            #we are looking if Name exist in openstack output
            if test["Name"] not in Names:
                result['comment']="Name ["+test["Name"]+"] not found in the openstack flavor list"
                outcome[testEntry["testID"]]=result
                continue
            rec=rawJson[Names[test["Name"]]]
            if test["Name"]!=rec["Name"]:
                result['comment']="Name ["+test["Name"]+"] not found in the openstack flavor list"
                outcome[testEntry["testID"]]=result
                continue
            if test["RAM"]!=rec["RAM"]:
                result['comment']="RAM ["+test["RAM"]+"] not found in the openstack flavor list"
                outcome[testEntry["testID"]]=result
                continue
            if test["Ephemeral"]!=rec["Ephemeral"]:
                result['comment']="Ephemeral ["+test["Ephemeral"]+"] not found in the openstack flavor list"
                outcome[testEntry["testID"]]=result
                continue
            if test["VCPUs"]!=rec["VCPUs"]:
                result['comment']="VCPUs ["+test["VCPUs"]+"] not found in the openstack flavor list"
                outcome[testEntry["testID"]]=result
                continue
            if test["Is Public"]!=rec["Is Public"]:
                result['comment']="Is Public ["+test["Is Public"]+"] not found in the openstack flavor list"
                outcome[testEntry["testID"]]=result
                continue
            if test["Disk"]!=rec["Disk"]:
                result['comment']="Disk ["+test["Disk"]+"] not found in the openstack flavor list"
                outcome[testEntry["testID"]]=result
                continue
            if test["ID"]!=rec["ID"]:
                result['comment']="ID ["+test["ID"]+"] not found in the openstack flavor list"
                outcome[testEntry["testID"]]=result
                continue
            result={}
            result['result']='PASS'
            result['comment']=""
            outcome[testEntry["testID"]]=result

        return outcome
    


#------------------------- backup functions
    def get_openstack_limitsBCK(self,limit_dict):
        cmd = f'source {self.env_file};openstack limits show -f json --absolute'

        o_out=self._execute_cmd(cmd)
      #  limit_dict = {}
     #   for name in json.loads(o_out):
     #       limit_dict[name['Name']] = name['Value']
#        print('********')
#        print (limit_dict)
#        print('********')
#        print(o_out)
#        print('********')
        data = self._json2hash(json.loads(o_out))
#        print(json.dumps(data))
#        print('********')
#        print(json.dumps(limit_dict))
#        print('********')

#        for x in limit_dict:
#            print(x,":",limit_dict[x])

        outcome={}
        for param in limit_dict:
            if param not in data:
                print("*Warn* ",param," not found in the opestack environment")
#//TODO: generic error when param not found
                #outcome[param]= kinda error
                continue
            outcome[param]=self._checkConditions(param,limit_dict[param],data[param])

#        for x in data:
#            print(x,":",data[x])
       # print(data["maxTotalInstances"])

        for x in outcome:
            print(x,":",outcome[x])

        return outcome
