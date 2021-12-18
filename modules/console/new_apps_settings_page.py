from console.base_page import BasePage, BasePageElement, BasePagePulldownElement, BasePagePulldownMultiElement
from console.locators import NewPageFullLocators, NewPageLocators, AppsPageLocators
from console.new_settings_full_page import NewSettingsFullPage
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
import console.compute_page
import mex_controller_classes
import time

import logging

from selenium.webdriver.support import expected_conditions
from selenium.webdriver.support.wait import WebDriverWait


class RegionElement(BasePagePulldownMultiElement):
    locator = AppsPageLocators.apps_region_pulldown
    locator2 = AppsPageLocators.apps_region_pulldown_options

class AppNameElement(BasePageElement):
    locator = AppsPageLocators.apps_appname_input

class DeveloperNameElement(BasePagePulldownElement):
    locator = AppsPageLocators.apps_orgname_pulldown

class AppVersionElement(BasePageElement):
    locator = AppsPageLocators.apps_appversion_input

class DeploymentTypeElement(BasePagePulldownElement):
    locator = AppsPageLocators.apps_deploymenttype_pulldown

class FlavorNameElement(BasePagePulldownElement):
    locator = AppsPageLocators.apps_flavor_pulldown

class ImagePathElement(BasePageElement):
    locator = AppsPageLocators.apps_imagepath_input

class PortNumberElement(BasePageElement):
    locator = AppsPageLocators.apps_portnumber_input

class AccessTypeElement(BasePagePulldownMultiElement):
    locator = AppsPageLocators.apps_access_type_input
    locator2 = AppsPageLocators.apps_access_type_option

class NewAppsSettingsPage(NewSettingsFullPage):
    region = RegionElement()
    app_name = AppNameElement()
    developer_name = DeveloperNameElement()
    app_version = AppVersionElement()
    deployment_type = DeploymentTypeElement()
    flavor_name = FlavorNameElement()
    image_path = ImagePathElement()
    port_number = PortNumberElement()
    access_type = AccessTypeElement()

    def is_region_label_present(self):
        return self.is_element_present(AppsPageLocators.apps_region)

    def is_region_input_present(self):
        return self.is_element_present(AppsPageLocators.apps_region_input)

    def is_organization_label_present(self):
        return self.is_element_present(AppsPageLocators.apps_orgname)

    def is_organization_input_present(self):
        return self.is_element_present(AppsPageLocators.apps_orgname_pulldown)

    def is_appname_label_present(self):
        return self.is_element_present(AppsPageLocators.apps_appname)

    def is_appname_input_present(self):
        return self.is_element_present(AppsPageLocators.apps_appname_input)

    def is_appversion_label_present(self):
        return self.is_element_present(AppsPageLocators.apps_appversion)

    def is_appversion_input_present(self):
        return self.is_element_present(AppsPageLocators.apps_appversion_input)

    def is_deployment_label_present(self):
        return self.is_element_present(AppsPageLocators.apps_deploymenttype)

    def is_deployment_input_present(self):
        return self.is_element_present(AppsPageLocators.apps_deploymenttype_pulldown)
   
    def is_accesstype_label_present(self):
        return self.is_element_present(AppsPageLocators.apps_accesstype)
 
    def is_accesstype_input_present(self):
        return self.is_element_present(AppsPageLocators.apps_accesstype_pulldown)
 
    def is_imagetype_label_present(self):
        return self.is_element_present(AppsPageLocators.apps_imagetype)

    def is_imagetype_input_present(self):
        return self.is_element_present(AppsPageLocators.apps_imagetype_disabled)

    def is_imagepath_label_present(self):
        return self.is_element_present(AppsPageLocators.apps_imagepath)

    def is_imagepath_input_present(self):
        return self.is_element_present(AppsPageLocators.apps_imagepath_input)

    #def is_authpublickey_label_present(self):
        #print('*WARN*', self.driver.find_element(*AppsPageLocators.apps_authpublickey).get_attribute('innerHTML'))
    #    return self.is_element_present(AppsPageLocators.apps_authpublickey)
        #locator not correct, does not check if text is correct, due to display being disabled

    #def is_authpublickey_input_present(self):
    #    return self.is_element_present(AppsPageLocators.apps_authpublickey_input)

    def is_flavor_label_present(self):
        return self.is_element_present(AppsPageLocators.apps_flavor)

    def is_flavor_input_present(self):
        return self.is_element_present(AppsPageLocators.apps_flavor_pulldown)

    def is_manifest_label_present(self):
        return self.is_element_present(AppsPageLocators.apps_manifest)

    def is_manifest_input_present(self):
        return self.is_element_present(AppsPageLocators.apps_manifest_input)

    def is_ports_label_present(self):
        return self.is_element_present(AppsPageLocators.apps_ports)

    def is_ports_input_present(self):
        return self.is_element_present(AppsPageLocators.apps_portnumber_input)

    def is_fqdn_label_present(self):
        return self.is_element_present(AppsPageLocators.apps_fqdn)
        
    def is_fqdn_input_present(self):
        return self.is_element_present(AppsPageLocators.apps_fqdn_input)

    def is_packagename_label_present(self):
        return self.is_element_present(AppsPageLocators.apps_packagename)
    
    def is_packagename_input_present(self):
        return self.is_element_present(AppsPageLocators.apps_packagename_input)

    def is_scalewithcluster_label_present(self):
        return self.is_element_present(AppsPageLocators.apps_scalewithcluster)
    
    def is_scalewithcluster_input_present(self):
        return self.is_element_present(AppsPageLocators.apps_scalewithcluster_input)

    def is_command_label_present(self):
        return self.is_element_present(AppsPageLocators.apps_command) 

    def is_command_input_present(self):
        return self.is_element_present(AppsPageLocators.apps_command_input)

    def is_deploymentmanifest_label_present(self):
        return self.is_element_present(AppsPageLocators.apps_deploymentmanifest)

    def is_deploymentmanifest_input_present(self):
        return self.is_element_present(AppsPageLocators.apps_deploymentmanifest_input)

    #def is_advanced_settings_label_present(self):
    #    return self.is_element_present(AppsPageLocators.apps_advancedsettings)

    def is_advanced_settings_input_present(self):
        return self.is_element_present(AppsPageLocators.apps_advancedsettings_button)

    def are_elements_present(self):
        settings_present = True

        if self.is_region_label_present() and self.is_region_input_present():
            logging.info('Region present')
        else:
            logging.error('Region not present')
            settings_present = False

        if self.is_organization_label_present() and self.is_organization_input_present():
            logging.info('OrgName present')
        else:
            logging.error('OrgName not present')
            settings_present = False

        if self.is_appname_label_present() and self.is_appname_input_present():
            logging.info('AppName present')
        else:
            logging.error('AppName not present')
            settings_present = False

        if self.is_appversion_label_present() and self.is_appversion_input_present():
            logging.info('AppVersion present')
        else:
            logging.error('AppVersion not present')
            settings_present = False

        if self.is_deployment_label_present() and self.is_deployment_input_present():
            logging.info('deployment present')
        else:
            logging.error('deployment not present')
            settings_present = False

        if self.is_imagetype_label_present() and self.is_imagetype_input_present():
            logging.info('ImageType present')
        else:
            logging.error('ImageType not present')
            settings_present = False

        if self.is_imagepath_label_present() and self.is_imagepath_input_present():
            logging.info('ImagePath present')
        else:
            logging.error('ImagePath not present')
            settings_present = False

        #if self.is_authpublickey_label_present() and self.is_authpublickey_input_present():
            #locators not accurate; display is disabled
        #    logging.info('AuthPublicKey present')
        #else:
        #    logging.error('AuthPublicKey not present')
        #    settings_present = False

        if self.is_flavor_label_present() and self.is_flavor_input_present():
            logging.info('Flavor present')
        else:
            logging.error('Flavor not present')
            settings_present = False

        if self.is_manifest_label_present() and self.is_manifest_input_present():
            logging.info('Deployment Manifest present')
        else:
            logging.error('Deployment Manifest not present')
            settings_present = False

        self.click_port_mapping()
        if self.is_ports_label_present() and self.is_ports_input_present():
            logging.info('Ports present')
        else:
            logging.error('Ports not present')
            settings_present = False

        if self.is_advanced_settings_input_present():
            logging.info('Advanced Settings present')
        else:
            logging.error('Advanced Settings not present')
            settings_present = False

        #if self.is_fqdn_label_present() and self.is_fqdn_input_present():
        #    logging.info('FQDN present')
        #else:
        #    logging.error('FQDN not present')
        #    settings_present = False

        #if self.is_packagename_label_present() and self.is_packagename_input_present():
        #    logging.info('PackageName present')
        #else:
        #    logging.error('PackageName not present')
        #    settings_present = False

        #if self.is_scalewithcluster_label_present() and self.is_scalewithcluster_input_present():
        #    logging.info('ScaleWithCluster present')
        #else:
        #    logging.error('ScaleWithCluster not present')
        #    settings_present = False

        #if self.is_command_label_present() and self.is_command_input_present():
        #    logging.info('Command present')
        #else:
        #    logging.error('Command not present')
        #    settings_present = False

        #if self.is_deploymentmanifest_label_present() and self.is_deploymentmanifest_input_present():
        #    logging.info('DeploymentManifest present')
        #else:
        #    logging.error('DeploymentManifest not present')
        #    settings_present = False
    
        return settings_present

    def are_app_details_present(self):
        settings_present = True

        if self.is_element_present(AppsPageLocators.apps_details_region):
            logging.info('Apps region detail present')
        else:
            settings_present = False

        if self.is_element_present(AppsPageLocators.apps_details_developername):
            logging.info('Developer detail present')
        else:
            settings_present = False

        if self.is_element_present(AppsPageLocators.apps_details_appname):
            logging.info('App name detail present')
        else:
            settings_present = False

        if self.is_element_present(AppsPageLocators.apps_details_version):
            logging.info('Version detail present')
        else:
            settings_present = False

        if self.is_element_present(AppsPageLocators.apps_details_deploymenttype):
            logging.info('Deployment Type detail present')
        else:
            settings_present = False

        if self.is_element_present(AppsPageLocators.apps_details_imagetype):
            logging.info('Image Type detail present')
        else:
            settings_present = False
 
        if self.is_element_present(AppsPageLocators.apps_details_imagepath):
            logging.info('Image Path detail present')
        elif self.is_element_present(AppsPageLocators.apps_details_deployment_manifest):
            logging.info('Deployment Manifest detail present')
        else:
            settings_present = False

        if self.is_element_present(AppsPageLocators.apps_details_flavors):
            logging.info('Flavors detail present')
        else:
            logging.info('Flavors detail NOT present')
            #settings_present = False


        return settings_present

    def is_image_path_correct(self, image_path_default=None):
        #print('*WARN*', 'image_path_default =' , image_path_default)
        value = self.get_input_value(AppsPageLocators.apps_imagepath_input)
        #print('*WARN*', 'value', value)
        if image_path_default == value:
            return True
        else: 
            logging.error('ImagePath created is INCORRECT. Found - ' + value + ' Expected  - ' + image_path_default)
            return False
    def is_image_type_correct(self, image_type):
        #print('*WARN*', 'image_type =' , image_type)
        value = self.get_input_value(AppsPageLocators.apps_imagetype_disabled)
        #print('*WARN*', 'value=', value)
        if image_type == value:
            return True
        else: 
            logging.error('ImageType is INCORRECT')
            return False

    def click_port_input(self):
        e = self.driver.find_element(*AppsPageLocators.apps_portnumber_input)
        ActionChains(self.driver).click(on_element=e).perform()

    def click_port_mapping(self):
        e = self.driver.find_element(*AppsPageLocators.add_ports_button)
        ActionChains(self.driver).click(on_element=e).perform()

    def click_create_app(self):
        e = self.driver.find_element(*AppsPageLocators.create_button)
        ActionChains(self.driver).click(on_element=e).perform()

    def click_protocol_pulldown(self):
        e = self.driver.find_element(*AppsPageLocators.apps_protocol_pulldown)
        e.location_once_scrolled_into_view
        ActionChains(self.driver).click(on_element=e).perform()

    def create_app(self, region=None, developer_name=None, app_name=None, app_version=None, deployment_type=None, flavor_name=None, image_path=None, image_path_docker_default=None, image_path_vm_default=None, image_path_helm_default=None, port_number=None, scale_with_cluster=False, auth_public_key=None, envvar=None, configs_kind=None, official_fqdn=None, android_package=None, access_type=None, skip_hc=None, trusted=False, outbound_connections=[]):
        logging.info('creating app')

        self.region = region
        time.sleep(2)
       # self.driver.find_element(*AppsPageLocators.apps_region_pulldown).click()
        wait = WebDriverWait(self.driver, 5, poll_frequency=1)
        element = wait.until(expected_conditions.visibility_of_element_located((By.XPATH,"//div[@id='organizationName']/input")))
        time.sleep(2)
        self.developer_name = developer_name
        time.sleep(2)
        self.deployment_type = deployment_type
        time.sleep(1)
        self.app_version = app_version
        time.sleep(1)
        e = self.driver.find_element(*AppsPageLocators.apps_appname_input)
        ActionChains(self.driver).click(on_element=e).perform()
        self.app_name = app_name
        self.driver.find_element(*AppsPageLocators.apps_imagepath_input).click()
        if deployment_type == 'docker':
            #print('*WARN*', 'its docker')
            image_type = 'Docker'
            if self.is_image_type_correct(image_type=image_type):
                time.sleep(1)
            if self.is_image_path_correct(image_path_default=image_path_docker_default):
                time.sleep(2)
                self.image_path = image_path
            else:
                return False
        if deployment_type == 'kubernetes':
            #print('*WARN*', 'its docker')
            image_type = 'Docker'
            if self.is_image_type_correct(image_type=image_type):
                time.sleep(1)
            if self.is_image_path_correct(image_path_default=image_path_docker_default):
                time.sleep(2)
                self.image_path = image_path
            else:
                return False
        if deployment_type == 'vm':
            image_type = 'Qcow'
            if self.is_image_type_correct(image_type=image_type):
                time.sleep(1)
            if self.is_image_path_correct(image_path_default=image_path_vm_default):
                time.sleep(2)
                self.image_path = image_path
            else:
                return False
        if deployment_type == 'helm':
            image_type = 'Helm'
            if self.is_image_type_correct(image_type=image_type):
                time.sleep(1)
            if self.is_image_path_correct(image_path_default=image_path_helm_default):
                time.sleep(2)
                self.image_path = image_path
            else:
                return False
        if access_type is not None:
            self.access_type = access_type
        self.driver.find_element(*AppsPageLocators.apps_flavor_pulldown).click()
        self.driver.find_element(*AppsPageLocators.flavor_input).send_keys('automation_api_flavor')
        self.driver.find_element(*AppsPageLocators.flavor_input).send_keys(Keys.ENTER)
        #self.driver.find_element(*AppsPageLocators.select_region).click()
        self.driver.find_element(*AppsPageLocators.select_flavor).click()
        #self.flavor_name = flavor_name
        ports_list = port_number.split(',')
        for i in range(len(ports_list)):
            port_details = ports_list[i].split(':')
            port_number = port_details[1]
            protocol = port_details[0].upper()
            self.click_protocol_pulldown()
            proto = f'.//div[@role="listbox"]//span[text()="{protocol}"]'
            self.driver.find_element_by_xpath(proto).click()
            self.port_number = port_number
            for j in range(len(port_details)):
                if (port_details[j] == 'tls'):
                    self.driver.find_element(*AppsPageLocators.apps_tls_button).click()
            
        if scale_with_cluster:
            self.driver.find_element(*AppsPageLocators.apps_advancedsettings_button).click()
            self.driver.find_element(*AppsPageLocators.toggle_button).click()
        if auth_public_key is not None:
            self.driver.find_element(*AppsPageLocators.apps_advancedsettings_button).click()
            self.driver.find_element(*AppsPageLocators.apps_publickey_input).send_keys(auth_public_key)
        if official_fqdn is not None:
            self.driver.find_element(*AppsPageLocators.apps_advancedsettings_button).click()
            self.driver.find_element(*AppsPageLocators.apps_officialfqdn_input).send_keys(official_fqdn)
        if envvar is not None:
            if deployment_type == 'kubernetes' or deployment_type == 'helm':
                self.driver.find_element(*AppsPageLocators.configs_button).click()
                self.driver.find_element(*AppsPageLocators.configs_input).send_keys(envvar)
                self.driver.find_element(*AppsPageLocators.configs_kind_pulldown).click()
                if deployment_type != 'helm' and configs_kind is None:
                    self.driver.find_element(*AppsPageLocators.configs_kind_input).click()
                if deployment_type == 'helm':
                    self.driver.find_element(*AppsPageLocators.configs_kind_input_helm).click()
        if android_package is not None:
            self.driver.find_element(*AppsPageLocators.apps_advancedsettings_button).click()
            self.driver.find_element(*AppsPageLocators.apps_androidpackage_input).send_keys(android_package)
        if skip_hc is not None:
            self.driver.find_element(*AppsPageLocators.apps_skiphc_button).click()
        if trusted:
            self.driver.find_element(*AppsPageLocators.trusted_app_toggle_button).click()
        if outbound_connections:
            i = len(outbound_connections)
            for j in range(i):
                self.driver.find_element(*AppsPageLocators.outbound_connections_button).click()
                e = self.driver.find_element(*AppsPageLocators.outbound_connections_protocol_pulldown)
                e.location_once_scrolled_into_view
                ActionChains(self.driver).click(on_element=e).perform()
                protocol = outbound_connections[j]['protocol']
                proto = f'.//div[@role="listbox"]//span[text()="{protocol}"]'
                #self.driver.find_element_by_xpath(proto).click()
                if 'portrangemin' in outbound_connections[j]:
                    portvalue = outbound_connections[j]['portrangemin']
                    self.driver.find_element(*AppsPageLocators.outbound_connections_portrangemin_input).send_keys(portvalue)
                if 'portrangemax' in outbound_connections[j]:
                    portvalue = outbound_connections[j]['portrangemax']
                    self.driver.find_element(*AppsPageLocators.outbound_connections_portrangemax_input).send_keys(portvalue)
                remote_ip = outbound_connections[j]['remote_ip']
                self.driver.find_element(*AppsPageLocators.outbound_connections_remoteip_input).send_keys(remote_ip)
        time.sleep(2)
        self.click_create_app()
        return True
