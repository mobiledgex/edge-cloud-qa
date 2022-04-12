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

from console.base_page import BasePage
from console.locators import MainPageLocators

import logging

class MainPage(BasePage):
    def click_compute_button(self):
        element = self.driver.find_element(*MainPageLocators.compute_button).click()
    
    def click_logout_button(self):
        element = self.driver.find_element(*MainPageLocators.avatar).click()
        element = self.driver.find_element(*MainPageLocators.logout_button).click()

    def is_compute_button_present(self):
        return self.is_element_present(MainPageLocators.compute_button)
        
    def is_monitoring_button_present(self):
        return self.is_element_present(MainPageLocators.monitoring_button)

    def is_avatar_present(self):
        return self.is_element_present(MainPageLocators.avatar)

    def is_username_present(self, username):
        return self.is_element_present(MainPageLocators.username, text=username)

    def are_elements_present(self, username):
        elements_present = True

        if self.is_compute_button_present():
            logging.info('Compute button present')
        else:
            elements_present = False
        #if main_page.is_monitoring_button_present():
        #    logging.info('Monitoring button present')
        #else:
        #    raise Exception('Monitoring button not present')
        if self.is_avatar_present():
            logging.info('Avatar present')
        else:
            elements_present = False
        #if self.is_username_present(username):
        #    logging.info(f'Username {username} present')
        #else:
        #    elements_present = False

        return elements_present

    
