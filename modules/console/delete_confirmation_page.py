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

from console.compute_page import ComputePage
from console.locators import DeleteConfirmationPageLocators, ComputePageLocators

import logging
import time

class DeleteConfirmationPage(ComputePage):
    def is_delete_confirmation_present(self):
        present = True
        
        if self.is_element_present(DeleteConfirmationPageLocators.yes_button):
            logging.info('yes button present')
        else:
            present = False
            
        if self.is_element_present(DeleteConfirmationPageLocators.no_button):
            logging.info('no button present')
        else:
            present = False

        return present

    def is_header_present(self, header_string):
        return self.is_element_text_present(DeleteConfirmationPageLocators.header, header_string)

    def is_message_prefix_present(self):
        return self.is_element_present(DeleteConfirmationPageLocators.content)

    def is_message_item_present(self, item):
        return self.is_element_text_present(DeleteConfirmationPageLocators.content_item, item)
    
    def click_no_button(self):
        self.driver.find_element(*DeleteConfirmationPageLocators.no_button).click()

    def click_yes_button(self):
        self.driver.find_element(*DeleteConfirmationPageLocators.yes_button).click()


class FlavorDeleteConfirmationPage(DeleteConfirmationPage):
    def is_header_present(self, header_string):
        return super.is_header_present('Delete Cloudlet')

    def is_message_item_present(self, item):
        return super.is_message_item_present(item)
    
    def is_delete_confirmation_present(self, item):
        present = True
        
        present = super.is_delete_confirmation_present()

        if self.is_header_present():
            logging.info('Header is present')
        else:
            present = False

        if self.is_message_prefix_present():
            logging.info('Message prefix present')
        else:
            present = False

        if self.is_message_item_present(item):
            logging.info('Message item present')
        else:
            present = False

            
