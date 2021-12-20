from console.base_page import BasePage
from console.locators import DetailsPageLocators, DetailsFullPageLocators, CloudletDetailsPageLocators, AppsPageLocators

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
            logging.error('header NOT present')
            elements_present = False

        if self.is_close_button_present():
            logging.info('close button present')
        else:
            logging.error('close button NOT present')
            elements_present = False

#        if self.is_region_label_present():
#            logging.info('region present')
#        else:
#            logging.error('region NOT present')
#            elements_present = False

        return elements_present

    def get_details(self, choice=None):
        #data = self.driver.find_element(*DetailsPageLocators.details_row)
        data_dict = {}
        if choice == 'user':
            for row in self.driver.find_elements(*DetailsFullPageLocators.details_row):
                #key = self.get_element_text(DetailsPageLocators.details_row_key)
                key = row.find_element(*DetailsFullPageLocators.details_row_key).text
                value = row.find_element(*DetailsFullPageLocators.details_row_value).text
                data_dict[key] = value
        else:
            totals_rows = self.driver.find_elements(*DetailsPageLocators.details_row)
            total_rows_length = len(totals_rows)
            if not self.is_element_present(AppsPageLocators.apps_details_configs):
                total_rows_length = total_rows_length + 1
            for row in range(1, total_rows_length):
            #for row in self.driver.find_elements(*DetailsPageLocators.details_row):
                #key = self.get_element_text(DetailsPageLocators.details_row_key)
                #key = row.find_element(*DetailsPageLocators.details_row_key).text
                #value = row.find_element(*DetailsPageLocators.details_row_value).text
                table_row =  f'//tbody/tr[{row}]/td'
                table_column =  f'//tbody/tr[{row}]/td/div'
                table_column1 = f'//tbody/tr[{row}]/td[2]'
                key = self.driver.find_element_by_xpath(table_row).text
                if key == 'Auto Provisioning Policies' or key == 'Created' or key == 'Updated':
                    value = self.driver.find_element_by_xpath(table_column1).text
                else:
                    value = self.driver.find_element_by_xpath(table_column).text
                data_dict[key] = value

        return data_dict

class DetailsFullPage(BasePage):
    def click_close_button(self):
        element = self.driver.find_element(*DetailsFullPageLocators.close_button).click()

    def is_close_button_present(self):
        return self.is_element_present(DetailsFullPageLocators.close_button)

    def is_heading_present(self, name):
        return self.is_element_present(DetailsFullPageLocators.details_title, name)

    def is_table_heading_present(self):
        return self.is_element_present(DetailsFullPageLocators.subject_heading) and self.is_element_present(DetailsFullPageLocators.value_heading)

    def is_region_label_present(self):
        return self.is_element_present(DetailsFullPageLocators.region_label)

    def are_elements_present(self, name):
        elements_present = True

        if self.is_heading_present(name):
            logging.info('header present')
        else:
            logging.error('header NOT present')
            elements_present = False

        if self.is_close_button_present():
            logging.info('close button present')
        else:
            logging.error('close button NOT present')
            elements_present = False

        if self.is_table_heading_present():
            logging.info('table header present')
        else:
            logging.error('table header NOT present')
            elements_present = False

        if self.is_region_label_present():
            logging.info('region present')
        else:
            logging.error('region NOT present')
            elements_present = False

        return elements_present

    def get_details(self):
        #data = self.driver.find_element(*DetailsPageLocators.details_row)

        data_dict = {}
        for row in self.driver.find_elements(*DetailsFullPageLocators.details_row):
            #key = self.get_element_text(DetailsPageLocators.details_row_key)
            key = row.find_element(*DetailsFullPageLocators.details_row_key).text
            if key == 'Updated':
                value = row.find_element(*DetailsFullPageLocators.details_row_value_updated).text
            else:
                value = row.find_element(*DetailsFullPageLocators.details_row_value).text
            data_dict[key] = value

        return data_dict

class ControllerDetailsPage(BasePage):
    def are_elements_present(self):
        elements_present = True

        elements_present = super().are_elements_present()

        if self.is_region_label_present():
            logging.info('region present')
        else:
            logging.error('region NOT present')
            elements_present = False

        return elements_present

#class CloudletDetailsPage(DetailsPage):
#    def is_cloudletname_label_present(self):
#        return self.is_element_present(CloudletDetailsPageLocators.cloudletname_label)
#
#    def is_operator_label_present(self):
#        return self.is_element_present(CloudletDetailsPageLocators.operator_label)
#
#    def is_cloudletlocation_label_present(self):
#        return self.is_element_present(CloudletDetailsPageLocators.cloudletlocation_label)
#
#    def is_ipsupport_label_present(self):
#        return self.is_element_present(CloudletDetailsPageLocators.ipsupport_label)
#
#    def is_numdynamicips_label_present(self):
#        return self.is_element_present(CloudletDetailsPageLocators.numdynamicips_label)
#
#    def is_cloudletname_value_present(self, cloudlet_name):
#        return self.is_element_text_present(CloudletDetailsPageLocators.cloudletname_field, cloudlet_name)
#
#    def is_ram_label_present(self):
#        return self.is_element_present(NewPageLocators.flavor_ram)
#
#    def is_ram_input_present(self):
#        return self.is_element_present(NewPageLocators.flavor_ram_input)
#
#    def is_vcpus_label_present(self):
#        return self.is_element_present(NewPageLocators.flavor_vcpus)
#
#    def is_vcpus_input_present(self):
#        return self.is_element_present(NewPageLocators.flavor_vcpus_input)
#
#    def is_disk_label_present(self):
#        return self.is_element_present(NewPageLocators.flavor_disk)
#
#    def is_disk_input_present(self):
#        return self.is_element_present(NewPageLocators.flavor_disk_input)
#
#    def are_elements_present(self, cloudlet_name):
#        elements_present = True
#
#        elements_present = super().are_elements_present()
#
#        if self.is_cloudletname_label_present() and self.is_cloudletname_value_present(cloudlet_name):
#            logging.info('CloudletName present')
#        else:
#            elements_present = False
#
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
#
#        return elements_present
#
#    def create_flavor(self, region=None, flavor_name=None, ram=None, vcpus=None, disk=None):
#        self.region = region
#        self.flavor_name = flavor_name
#        self.ram = ram
#        self.vcpus = vcpus
#        self.disk = disk
#
#        self.take_screenshot('add_new_flavor_settings.png')
#
#        self.click_save_button()
