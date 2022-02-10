from console.base_page import BasePage, BasePageElement, BasePagePulldownElement, BasePagePulldownMultiElement
from console.locators import NewPageLocators, ComputePageLocators, CloudletsPageLocators
from console.new_settings_full_page import NewSettingsFullPage
from console.compute_page import ComputePage
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.by import By
import logging
import time

class CloudletNameElement(BasePageElement):
    locator = NewPageLocators.cloudlet_cloudletname_input

class OperatorNameElement(BasePagePulldownElement):
    locator = NewPageLocators.cloudlet_operator_pulldown

class LatitudeElement(BasePageElement):
    locator = NewPageLocators.cloudlet_latitude_input

class LongitudeElement(BasePageElement):
    locator = NewPageLocators.cloudlet_longitude_input

class IpSupportElement(BasePagePulldownElement):
    locator = NewPageLocators.cloudlet_ipsupport_pulldown

class NumDynamicIpsElement(BasePageElement):
    locator = NewPageLocators.cloudlet_numdynamicips_input

class PhysicalNameElement(BasePageElement):
    locator = NewPageLocators.cloudlet_physicalname_input

class PlatformTypeElement(BasePagePulldownElement):
    locator = NewPageLocators.cloudlet_platformtype_pulldown

class SearchBoxElement(BasePageElement):
    locator = ComputePageLocators.search_box

class InfraAccessElement(BasePagePulldownMultiElement):
    locator = NewPageLocators.access_mode_input
    locator2 = NewPageLocators.access_mode_option

class ExternalNetworkElement(BasePageElement):
    locator = NewPageLocators.external_network_input

class FlavorNameElement(BasePageElement):
    locator = NewPageLocators.infra_flavor_input

class TrustPolicyElement(BasePagePulldownElement):
    locator = NewPageLocators.trust_policy_pulldown

class NewCloudletSettingsPage(NewSettingsFullPage):
    cloudlet_name = CloudletNameElement()
    operator_name = OperatorNameElement()
    latitude = LatitudeElement()
    longitude = LongitudeElement()
    ip_support = IpSupportElement()
    number_dynamic_ips = NumDynamicIpsElement()
    physical_name = PhysicalNameElement()
    platform_type = PlatformTypeElement()
    cloudletname = SearchBoxElement()    
    infra_api_access = InfraAccessElement()
    external_network = ExternalNetworkElement()
    flavor_name = FlavorNameElement()
    trust_policy = TrustPolicyElement()

    def is_heading_present(self):
        return self.is_element_present(NewPageLocators.cloudlet_cloudletname)
    
    def is_cloudletname_label_present(self):
        return self.is_element_present(NewPageLocators.cloudlet_cloudletname)

    def is_cloudletname_input_present(self):
        return self.is_element_present(NewPageLocators.cloudlet_cloudletname_input)

    def is_operatorname_label_present(self):
        return self.is_element_present(NewPageLocators.cloudlet_operatorname)

    def is_operatorname_input_present(self):
        return self.is_element_present(NewPageLocators.cloudlet_operatorname_input)

    def is_latitude_label_present(self):
        return self.is_element_present(NewPageLocators.cloudlet_latitude)

    def is_latitude_input_present(self):
        return self.is_element_present(NewPageLocators.cloudlet_latitude_input)

    def is_longitude_label_present(self):
        return self.is_element_present(NewPageLocators.cloudlet_longitude)

    def is_longitude_input_present(self):
        return self.is_element_present(NewPageLocators.cloudlet_longitude_input)

    def is_location_label_present(self):
        return self.is_element_present(NewPageLocators.cloudlet_location)

    def is_ipsupport_label_present(self):
        return self.is_element_present(NewPageLocators.cloudlet_ipsupport)

    def is_ipsupport_input_present(self):
        return self.is_element_present(NewPageLocators.cloudlet_ipsupport_input)

    def is_numdynamicips_label_present(self):
        return self.is_element_present(NewPageLocators.cloudlet_numdynamicips)

    def is_numdynamicips_input_present(self):
        return self.is_element_present(NewPageLocators.cloudlet_numdynamicips_input)

    def is_physicalname_label_present(self):
        return self.is_element_present(NewPageLocators.cloudlet_physicalname)

    def is_physicalname_input_present(self):
        return self.is_element_present(NewPageLocators.cloudlet_physicalname_input)

    def is_platformtype_label_present(self):
        return self.is_element_present(NewPageLocators.cloudlet_platformtype)

    def is_platformtype_input_present(self):
        return self.is_element_present(NewPageLocators.cloudlet_platformtype_input)

    def are_elements_present(self):
        settings_present = True

        settings_present = super().are_elements_present()

        if self.is_heading_present():
            logging.info('Settings header present')
        else:
            logging.error('Settings header not present')
            settings_present = False

        if self.is_cloudletname_label_present() and self.is_cloudletname_input_present():
            logging.info('CloudletName present')
        else:
            logging.error('CloudletName not present')
            settings_present = False

        if self.is_operatorname_label_present() and self.is_operatorname_input_present():
            logging.info('OperatorName present')
        else:
            logging.error('OperatorName not present')
            settings_present = False

        if self.is_location_label_present():
            logging.info('Location present')
        else:
            logging.error('Location not present')
            settings_present = False

        if self.is_latitude_label_present() and self.is_latitude_input_present():
            logging.info('Latitude present')
        else:
            logging.error('Latitude not present')
            settings_present = False

        if self.is_longitude_label_present() and self.is_longitude_input_present():
            logging.info('Longitude present')
        else:
            logging.error('Longitude not present')
            settings_present = False

        if self.is_ipsupport_label_present() and self.is_ipsupport_input_present():
            logging.info('Ipsupport present')
        else:
            logging.error('Ipsupport not present')
            settings_present = False

        if self.is_numdynamicips_label_present() and self.is_numdynamicips_input_present():
            logging.info('NumDynamicIps present')
        else:
            logging.error('NumDynamicIps not present')
            settings_present = False

        if self.is_physicalname_label_present() and self.is_physicalname_input_present():
            logging.info('Physical Name present')
        else:
            logging.error('Physical Name not present')
            settings_present = False

        if self.is_platformtype_label_present() and self.is_platformtype_input_present():
            logging.info('Platform Type present')
        else:
            logging.error('Platform Type not present')
            settings_present = False

        return settings_present

    def create_cloudlet(self, region=None, cloudlet_name=None, operator_name=None, latitude=None, longitude=None, ip_support=None, number_dynamic_ips=None, physical_name=None, platform_type=None, infra_api_access=None, trust_policy=None):
        logging.info(f'creating cloudlet region={region} cloudlet_name={cloudlet_name} operator={operator_name} lat={latitude} long={longitude} ipsupport={ip_support} numips={number_dynamic_ips} physical_name={physical_name} platform_type={platform_type} infra_api_access={infra_api_access}, trust_policy={trust_policy}')

        self.region = region
        time.sleep(2)
        self.cloudlet_name = cloudlet_name
        time.sleep(2)
        self.operator_name = operator_name
        time.sleep(2)
        self.number_dynamic_ips = str(number_dynamic_ips)
        time.sleep(2)
        self.physical_name = physical_name
        time.sleep(2)
        self.platform_type = platform_type
        time.sleep(2)

        if ip_support == 2:
            self.ip_support = 'Dynamic'
            time.sleep(2)

        self.infra_api_access = infra_api_access

        if infra_api_access == 'Restricted':
            self.external_network = 'external-network-shared'
            self.flavor_name = 'm4.medium'

        self.latitude = str(latitude)
        self.driver.find_element(*NewPageLocators.cloudlet_longitude_input).click()
        self.longitude = str(longitude)

        if trust_policy is not None:
            self.driver.find_element(*NewPageLocators.cloudlet_advancedsettings_button).click()
            if not self.is_element_present(NewPageLocators.trust_policy_row):
                self.driver.find_element(*NewPageLocators.cloudlet_advancedsettings_button).click()
            self.trust_policy = trust_policy

        self.take_screenshot('add_new_cloudlet_settings.png')

        self.click_create_button()

    def update_cloudlet(self, region=None, cloudlet_name=None, operator=None, latitude=None, longitude=None, number_dynamic_ips=None, maintenance_state=None, trust_policy=None):
        logging.info(f'Updating cloudlet region={region} cloudlet_name={cloudlet_name} operator={operator}')
        self.compute_page = ComputePage(self.driver)
        row = self.compute_page.get_table_row_by_value([(cloudlet_name, 5), (operator, 4)])
        row.find_element(*ComputePageLocators.table_action).click()
        self.driver.find_element(*ComputePageLocators.table_update).click()

        if latitude is not None:
            self.latitude = str(latitude)

        if longitude is not None:
            self.driver.find_element(*NewPageLocators.cloudlet_longitude_input).click()
            self.longitude = str(longitude)
 
        if number_dynamic_ips is not None:
            self.number_dynamic_ips = str(number_dynamic_ips)

        if maintenance_state is not None:
            self.driver.find_element(*CloudletsPageLocators.advancedsettings_button).click()
            self.driver.find_element(*CloudletsPageLocators.maintenance_state_pulldown).click()
            if maintenance_state == 'Maintenance Start':
                self.driver.find_element(*CloudletsPageLocators.maintenance_state_option1).click() 
            elif maintenance_state == 'Maintenance Start No Failover':
                self.driver.find_element(*CloudletsPageLocators.maintenance_state_option2).click()
            else:
                self.driver.find_element(*CloudletsPageLocators.maintenance_state_normal_operation).click()

        if trust_policy is not None:
            self.driver.find_element(*CloudletsPageLocators.advancedsettings_button).click()
            if trust_policy == 'RemovePolicy':
                self.driver.find_element(*CloudletsPageLocators.trustpolicy_dropdown_clear).click()
            else:
                self.trust_policy = trust_policy

        self.click_update_cloudlet()
        return True

    def click_update_cloudlet(self):
        self.driver.find_element(*CloudletsPageLocators.update_button).click()
                              
    def get_cloudlet_manifest(self, cloudlet_name=None):
        yaml_attribute = '-TDG-pf-external-network-shared-port'
        yaml_property = (By.XPATH, f'//pre[@class="yamlDiv"]/code/span[18][text()="{cloudlet_name}{yaml_attribute}"]')
        if not self.is_element_present(NewPageLocators.get_manifest_header):
            return False
        if not self.is_element_present(NewPageLocators.get_manifest_steps):
            return False    
        if not self.is_element_present(NewPageLocators.download_manifest_button):
            return False
        if not self.is_element_present(yaml_property):
            return False
        return True

    def close_manifest(self):
        self.driver.find_element(*NewPageLocators.close_manifest_button).click() 

    def close_alert_box(self):
        self.driver.find_element(*ComputePageLocators.close_button).click()

    def search_cloudlet(self, cloudlet_name):
        e = self.driver.find_element(*ComputePageLocators.search_icon)
        ActionChains(self.driver).click(on_element=e).perform()

        self.cloudletname = cloudlet_name
