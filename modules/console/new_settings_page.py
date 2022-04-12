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
from console.locators import NewPageLocators, OrganizationsPageLocators, UsersPageLocators

import logging

class RegionElement(BasePagePulldownElement):
    locator = NewPageLocators.region_pulldown_option

#class FlavorNameElement(BasePageElement):
#    locator = NewPageLocators.flavor_flavorname_input

#class RamElement(BasePageElement):
#    locator = NewPageLocators.flavor_ram_input

#class VcpusElement(BasePageElement):
#    locator = NewPageLocators.flavor_vcpus_input

#class DiskElement(BasePageElement):
#    locator = NewPageLocators.flavor_disk_input

class RoleElement(BasePagePulldownElement):
    locator = OrganizationsPageLocators.role_pulldown

class FilterElement(BasePageElement):
    locator = UsersPageLocators.user_pulldown_input

class NewSettingsPage(BasePage):
    region = RegionElement()
    role = RoleElement()
    filter = FilterElement()

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

        #if self.is_heading_present():
        #    logging.info('Settings header present')
        #else:
        #    logging.error('Settings header not present')
        #    settings_present = False

        if self.is_region_label_present() and self.is_region_pulldown_present():
            logging.info('Settings region present')
        else:
            logging.error('Settings region not present')
            settings_present = False

        if self.is_cancel_button_present() and self.is_save_button_present():
            logging.info('Settings Cancel/Save button present')
        else:
            logging.error('Settings Cancel/Save button not present')
            settings_present = False

        return settings_present
