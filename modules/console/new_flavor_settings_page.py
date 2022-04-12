# Copyright 2022 MobiledgeX, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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

    def create_flavor(self, region=None, flavor_name=None, ram=None, vcpus=None, disk=None, gpu=None):
        logging.info('creating flavor')

        self.region = region
        self.flavor_name = flavor_name
        self.ram = ram
        self.vcpus = vcpus
        self.disk = disk

        if gpu == 'true':
            logging.info('Clicking GPU slider')
            self.driver.find_element(*NewPageLocators.flavor_gpu_slider).click()
            ischecked = self.driver.find_element(*NewPageLocators.flavor_gpu_slider).get_attribute("value")
            if not (ischecked):
                logging.warning("GPU Slider not checked. Expected to be checked")
            else:
                logging.info("GPU Slider checked as expected.")
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
