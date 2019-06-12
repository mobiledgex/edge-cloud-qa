from console.base_page import BasePage, BasePageElement, BasePagePulldownElement
from console.locators import NewPageLocators
from console.new_settings_page import NewSettingsPage

import logging

class CloudletNameElement(BasePageElement):
    locator = NewPageLocators.cloudlet_cloudletname_input

class OperatorNameElement(BasePageElement):
    locator = NewPageLocators.cloudlet_operatorname_input

class LatitudeElement(BasePageElement):
    locator = NewPageLocators.cloudlet_latitude_input

class LongitudeElement(BasePageElement):
    locator = NewPageLocators.cloudlet_longitude_input

class IpSupportElement(BasePageElement):
    locator = NewPageLocators.cloudlet_ipsupport_input

class NumDynamicIpsElement(BasePageElement):
    locator = NewPageLocators.cloudlet_numdynamicips_input

class NewCloudletSettingsPage(NewSettingsPage):
    cloudlet_name = CloudletNameElement()
    operator_name = OperatorNameElement()
    latitude = LatitudeElement()
    longitude = LongitudeElement()
    ip_support = IpSupportElement()
    number_dynamic_ips = NumDynamicIpsElement()

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

    def are_elements_present(self):
        settings_present = True

        settings_present = super().are_elements_present()

        if self.is_cloudletname_label_present() and self.is_cloudletname_input_present():
            logging.info('CloudletName present')
        else:
            settings_present = False

        if self.is_operatorname_label_present() and self.is_operatorname_input_present():
            logging.info('OperatorName present')
        else:
            settings_present = False

        if self.is_location_label_present():
            logging.info('Location present')
        else:
            settings_present = False

        if self.is_latitude_label_present() and self.is_latitude_input_present():
            logging.info('Latitude present')
        else:
            settings_present = False

        if self.is_longitude_label_present() and self.is_longitude_input_present():
            logging.info('Longitude present')
        else:
            settings_present = False

        if self.is_ipsupport_label_present() and self.is_ipsupport_input_present():
            logging.info('Ipsupport present')
        else:
            settings_present = False

        if self.is_numdynamicips_label_present() and self.is_numdynamicips_input_present():
            logging.info('NumDynamicIps present')
        else:
            settings_present = False

        return settings_present

    def create_cloudlet(self, region=None, cloudlet_name=None, operator_name=None, latitude=None, longitude=None, ip_support=None, number_dynamic_ips=None):
        logging.info('creating cloudlet')
        
        self.region = region
        self.cloudlet_name = cloudlet_name
        self.operator_name = operator_name
        self.latitude = str(latitude)
        self.longitude = str(longitude)
        self.ip_support = str(ip_support)
        self.number_dynamic_ips = str(number_dynamic_ips)
        
        self.take_screenshot('add_new_cloudlet_settings.png')

        self.click_save_button()
