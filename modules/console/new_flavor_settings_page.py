from console.base_page import BasePage, BasePageElement, BasePagePulldownElement
from console.locators import NewPageLocators
from console.new_settings_page import NewSettingsPage

import time
import logging

class RegionElement(BasePagePulldownElement):
    locator = NewPageLocators.region_pulldown_option

class FlavorNameElement(BasePageElement):
    locator = NewPageLocators.flavor_flavorname_input

class RamElement(BasePageElement):
    locator = NewPageLocators.flavor_ram_input

class VcpusElement(BasePageElement):
    locator = NewPageLocators.flavor_vcpus_input

class DiskElement(BasePageElement):
    locator = NewPageLocators.flavor_disk_input

class NewFlavorSettingsPage(NewSettingsPage):
    flavor_name = FlavorNameElement()
    ram = RamElement()
    vcpus = VcpusElement()
    disk = DiskElement()

    def is_flavorname_label_present(self):
        return self.is_element_present(NewPageLocators.flavor_flavorname)

    def is_flavorname_input_present(self):
        return self.is_element_present(NewPageLocators.flavor_flavorname_input)

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

    def are_elements_present(self):
        settings_present = True

        settings_present = super().are_elements_present()

        if self.is_flavorname_label_present() and self.is_flavorname_input_present():
            logging.info('FlavorName present')
        else:
            logging.error('FlavorName not present')
            settings_present = False

        if self.is_ram_label_present() and self.is_ram_input_present():
            logging.info('RAM present')
        else:
            logging.error('RAM not present')
            settings_present = False

        if self.is_vcpus_label_present() and self.is_vcpus_input_present():
            logging.info('VCPUS present')
        else:
            logging.error('VCPUS present')
            settings_present = False

        if self.is_disk_label_present() and self.is_disk_input_present():
            logging.info('Disk present')
        else:
            logging.error('Disk present')
            settings_present = False

        return settings_present

    def create_flavor(self, region=None, flavor_name=None, ram=None, vcpus=None, disk=None):
        logging.info('creating flavor')

        self.region = region
        self.flavor_name = flavor_name
        self.ram = ram
        self.vcpus = vcpus
        self.disk = disk
        time.sleep(5)
        self.take_screenshot('add_new_flavor_settings.png')
        self.click_save_button()

    def dont_create_flavor(self, region=None, flavor_name=None, ram=None, vcpus=None, disk=None):
        self.region = region
        self.flavor_name = flavor_name
        self.ram = ram
        self.vcpus = vcpus
        self.disk = disk
        time.sleep(5)
        self.click_cancel_button()
