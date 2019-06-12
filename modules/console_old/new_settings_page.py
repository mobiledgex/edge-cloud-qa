from console.base_page import BasePage, BasePageElement, BasePagePulldownElement
from console.locators import NewPageLocators

import logging

class RegionElement(BasePagePulldownElement):
    locator = NewPageLocators.region_pulldown

class FlavorNameElement(BasePageElement):
    locator = NewPageLocators.flavor_flavorname_input

class RamElement(BasePageElement):
    locator = NewPageLocators.flavor_ram_input

class VcpusElement(BasePageElement):
    locator = NewPageLocators.flavor_vcpus_input

class DiskElement(BasePageElement):
    locator = NewPageLocators.flavor_disk_input

class NewSettingsPage(BasePage):
    region = RegionElement()

    def click_cancel_button(self):
        element = self.driver.find_element(*NewPageLocators.cancel_button).click()

    def click_save_button(self):
        element = self.driver.find_element(*NewPageLocators.save_button).click()

    def is_cancel_button_present(self):
        return self.is_element_present(NewPageLocators.cancel_button)

    def is_save_button_present(self):
        return self.is_element_present(NewPageLocators.save_button)

    def is_heading_present(self):
        return self.is_element_present(NewPageLocators.heading)

    def is_region_label_present(self):
        return self.is_element_present(NewPageLocators.region)
    
    def is_region_pulldown_present(self):
        return self.is_element_present(NewPageLocators.region_pulldown, 'Select Region')
    
    def are_elements_present(self):
        settings_present = True
        
        if self.is_heading_present():
            logging.info('Settings header present')
        else:
            settings_present = False

        if self.is_region_label_present() and self.is_region_pulldown_present():
            logging.info('Settings region present')
        else:
            settings_present = False

        if self.is_cancel_button_present() and self.is_save_button_present():
            logging.info('Settings Cancel/Save button present')
        else:
            settings_present = False

        return settings_present

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
            settings_present = False

        if self.is_ram_label_present() and self.is_ram_input_present():
            logging.info('RAM present')
        else:
            settings_present = False

        if self.is_vcpus_label_present() and self.is_vcpus_input_present():
            logging.info('VCPUS present')
        else:
            settings_present = False

        if self.is_disk_label_present() and self.is_disk_input_present():
            logging.info('Disk present')
        else:
            settings_present = False

        return settings_present

    def create_flavor(self, region=None, flavor_name=None, ram=None, vcpus=None, disk=None):
        self.region = region
        self.flavor_name = flavor_name
        self.ram = ram
        self.vcpus = vcpus
        self.disk = disk

        self.take_screenshot('add_new_flavor_settings.png')

        self.click_save_button()
