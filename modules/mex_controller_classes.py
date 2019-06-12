import shared_variables

class Flavor():
    flavor = None
    
    def __init__(self, flavor_name=None, ram=None, vcpus=None, disk=None, use_defaults=True):
        flavor_dict = {}

        self.flavor_name = flavor_name
        self.ram = ram
        self.vcpus = vcpus
        self.disk = disk

        if use_defaults:
            if flavor_name is None: self.flavor_name = shared_variables.flavor_name_default
            if ram is None: self.ram = 1024 
            if vcpus is None: self.vcpus = 1 
            if disk is None: self.disk = 1

        shared_variables.flavor_name_default = self.flavor_name

        #"{\"flavor\":{\"key\":{\"name\":\"uu\"},\"ram\":1,\"vcpus\":1,\"disk\":1}}", "resp": "{}", "took": "85.424786ms"}
        
        if self.flavor_name is not None:
            flavor_dict['key'] = {'name': flavor_name}
        if self.ram is not None:
            flavor_dict['ram'] = int(self.ram)
        if self.vcpus is not None:
            flavor_dict['vcpus'] = int(self.vcpus)
        if self.disk is not None:
            flavor_dict['disk'] = int(self.disk)

        
        self.flavor = flavor_dict

class Cloudlet():
    cloudlet = None
    
    def __init__(self, cloudlet_name=None, operator_name=None, number_dynamic_ips=None, latitude=None, longitude=None, ip_support=None, access_uri=None, static_ips=None, use_defaults=True):

        self.cloudlet_name = cloudlet_name
        self.operator_name = operator_name
        self.access_uri = access_uri
        self.latitude = latitude
        self.longitude = longitude
        self.ip_support = ip_support
        self.static_ips = static_ips
        self.number_dynamic_ips = number_dynamic_ips

        if use_defaults:
            if cloudlet_name is None: self.cloudlet_name = shared_variables.cloudlet_name_default
            if operator_name is None: self.operator_name = shared_variables.operator_name_default
            if latitude is None: self.latitude = shared_variables.latitude_default
            if longitude is None: self.longitude = shared_variables.longitude_default
            if number_dynamic_ips is None: self.number_dynamic_ips = shared_variables.number_dynamic_ips_default
            if ip_support is None: self.ip_support = shared_variables.ip_support_default
            #if accessuri is None: self.accessuri = shared_variables.access_uri_default
            #if staticips is None: self.staticips = shared_variables.static_ips_default

        if self.ip_support == "IpSupportUnknown":
            self.ip_support = 0
        if self.ip_support == "IpSupportStatic":
            self.ip_support = 1
        if self.ip_support == "IpSupportDynamic":
            self.ip_support = 2

        print('*WARN*', 'before key')
        #"{\"cloudlet\":{\"key\":{\"operator_key\":{\"name\":\"rrrr\"},\"name\":\"rrrr\"},\"location\":{\"latitude\":5,\"longitude\":5,\"timestamp\":{}},\"ip_support\":2,\"num_dynamic_ips\":2}}"
        cloudlet_dict = {}
        cloudlet_key_dict = {}
        if self.operator_name is not None:
            print('*WARN*', 'before key op')
            cloudlet_key_dict['operator_key'] = {'name': self.operator_name}
            print('*WARN*', 'after key op')
        if self.cloudlet_name is not None:
            print('*WARN*', 'before key cl')
            cloudlet_key_dict['name'] = self.cloudlet_name
            print('*WARN*', 'after key cl')
        print('*WARN*', 'after key')

        loc_dict = {}
        if self.latitude is not None:
            loc_dict['latitude'] = float(self.latitude)
        if self.longitude is not None:
            loc_dict['longitude'] = float(self.longitude)

        if cloudlet_key_dict:
            cloudlet_dict['key'] = cloudlet_key_dict
        if loc_dict:
            cloudlet_dict['location'] = loc_dict
        if self.number_dynamic_ips is not None:
            cloudlet_dict['num_dynamic_ips'] = int(self.number_dynamic_ips)
        if self.ip_support is not None:
            cloudlet_dict['ip_support'] = self.ip_support
        #if self.accessuri is not None:
        #    cloudlet_dict['access_uri'] = self.accessuri
        #    _fields_list.append(self._cloudlet_accessuri_field)
        #if self.staticips is not None:
        #    cloudlet_dict['static_ips'] = self.staticips
        #    _fields_list.append(self._cloudlet_staticips_field)

        print("In the class before", cloudlet_dict)
        self.cloudlet = cloudlet_dict
        print("In the class after", cloudlet_dict)
