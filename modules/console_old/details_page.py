from console.base_page import BasePage
from console.locators import DetailsPageLocators, CloudletDetailsPageLocators

import logging

class DetailsPage(BasePage):
    def click_close_button(self):
        element = self.driver.find_element(*DetailsPageLocators.close_button).click()

    def is_close_button_present(self):
        return self.is_element_present(DetailsPageLocators.close_button)

    def is_heading_present(self):
        return self.is_element_present(DetailsPageLocators.details_title)

    def is_region_label_present(self):
        return self.is_element_present(DetailsPageLocators.region_label)

    def are_elements_present(self):
        elements_present = True
        
        if self.is_heading_present():
            logging.info('header present')
        else:
            elements_present = False

        if self.is_close_button_present():
            logging.info('close button present')
        else:
            elements_present = False

        if self.is_region_label_present():
            logging.info('region present')
        else:
            elements_present = False

        return elements_present

    def get_details(self):
        #data = self.driver.find_element(*DetailsPageLocators.details_row)

        data_dict = {}
        
        for row in self.driver.find_elements(*DetailsPageLocators.details_row):
            #key = self.get_element_text(DetailsPageLocators.details_row_key)
            print('*WARN*', 'row',row)
            key = row.find_element(*DetailsPageLocators.details_row_key).text
            value = row.find_element(*DetailsPageLocators.details_row_value).text
            print('*WARN*', 'kv',key, value)
            data_dict[key] = value

        return data_dict


class CloudletDetailsPage(DetailsPage):
    def is_cloudletname_label_present(self):
        return self.is_element_present(CloudletDetailsPageLocators.cloudletname_label)

    def is_operator_label_present(self):
        return self.is_element_present(CloudletDetailsPageLocators.operator_label)

    def is_cloudletlocation_label_present(self):
        return self.is_element_present(CloudletDetailsPageLocators.cloudletlocation_label)

    def is_ipsupport_label_present(self):
        return self.is_element_present(CloudletDetailsPageLocators.ipsupport_label)

    def is_numdynamicips_label_present(self):
        return self.is_element_present(CloudletDetailsPageLocators.numdynamicips_label)

    def is_cloudletname_value_present(self, cloudlet_name):
        return self.is_element_text_present(CloudletDetailsPageLocators.cloudletname_field, cloudlet_name)

    def is_ram_label_present(self):
        return self.is_element_present(NewPageLocators.flavor_ram)

    def is_ram_input_present(self):
        return self.is_element_present(NewPageLocators.flavor_ram_input)

    def is_vcpus_label_present(self):
        return self.is_element_present(NewPageLocators.flavor_vcpus)

    def is_vcpus_input_present(self):
        return self.is_element_present(NewPageLocators.flavor_vcpus_input)

    def is_disk_label_present(self):
        return self.is_element_present(NewPageLocators.flavor_disk)

    def is_disk_input_present(self):
        return self.is_element_present(NewPageLocators.flavor_disk_input)

    def are_elements_present(self, cloudlet_name):
        elements_present = True

        elements_present = super().are_elements_present()
        
        if self.is_cloudletname_label_present() and self.is_cloudletname_value_present(cloudlet_name):
            logging.info('CloudletName present')
        else:
            elements_present = False

        #if self.is_ram_label_present() and self.is_ram_input_present():
        #    logging.info('RAM present')
        #else:
        #    settings_present = False

        #if self.is_vcpus_label_present() and self.is_vcpus_input_present():
        #    logging.info('VCPUS present')
        #else:
        #    settings_present = False

        #if self.is_disk_label_present() and self.is_disk_input_present():
        #    logging.info('Disk present')
        #else:
        #    settings_present = False

        return elements_present

    def create_flavor(self, region=None, flavor_name=None, ram=None, vcpus=None, disk=None):
        self.region = region
        self.flavor_name = flavor_name
        self.ram = ram
        self.vcpus = vcpus
        self.disk = disk

        self.take_screenshot('add_new_flavor_settings.png')

        self.click_save_button()
