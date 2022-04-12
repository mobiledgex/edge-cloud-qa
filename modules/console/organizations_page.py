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
from console.locators import OrganizationsPageLocators, ComputePageLocators, DeleteConfirmationPageLocators, CloudletsPageLocators
from selenium.webdriver.common.action_chains import ActionChains
import logging
import time

class OrganizationsPage(ComputePage):

    def is_organizations_table_header_present(self):
        header_present = True

        if self.is_element_present(OrganizationsPageLocators.table_header_organization):
            logging.info('organization header present')
        else:
            logging.error('organization header NOT present')
            header_present = False

        if self.is_element_present(OrganizationsPageLocators.table_header_type):
            logging.info('type header present')
        else:
            logging.error('type header NOT present')
            header_present = False

        if self.is_element_present(OrganizationsPageLocators.table_header_phone):
            logging.info('phone header present')
        else:
            logging.error('phone header NOT present')
            header_present = False

        if self.is_element_present(OrganizationsPageLocators.table_header_publicimage):
            logging.info('public image header present')
        else:
            logging.error('public image header NOT present')
            header_present = False

        if self.is_element_present(OrganizationsPageLocators.table_header_edit):
            logging.info('actions header present')
        else:
            logging.error('actions header NOT present')
            header_present = False

        return header_present

    def is_organization_manage_button_present(self):
        return self.is_element_present(OrganizationsPageLocators.manage_button)

    def is_organization_present(self, organization=None, type=None, phone=None, address=None):
        #self.take_screenshot('is_cloudlet_present_pre.png')
        found = False

        rows = self.get_table_rows()
        for r in rows:
            if phone is not None and address is not None:
                if r[0] == organization and r[1] == type and r[2] == phone and r[3] == address:
                    found = True
                    logging.info('found organization')
                    return True
            else:
                if r[0] == organization and r[1] == type:
                    found = True
                    logging.info('found organization')
                    return True
        return False

    def wait_for_organization(self, organization=None, type=None, phone=None, address=None, wait=5):
        #logging.info(f'wait_for_cloudlet region={region} cloudlet={cloudlet_name} operator={operator} latitude={latitude} longitude={longitude}')
        for attempt in range(wait):
            if self.is_organization_present(organization=organization, type=type, phone=phone, address=address):
                return True
            else:
                time.sleep(1)

        logging.error(f'timeout waiting for organization {organization}')
        return False

    def get_add_user_button_status(self):
        return self.find_element(ComputePageLocators.add_user_button).is_enabled()

    def get_trash_button_status(self):
        return self.find_element(ComputePageLocators.trash_button).is_enabled()

    def delete_cloudlet(self, region=None, cloudlet_name=None, operator=None):
        logging.info(f'delete cloudlet region={region} cloudlet_name={cloudlet_name} operator={operator}')
        row = self.get_table_row_by_value([(region, 1), (cloudlet_name, 2), (operator, 3)])
        #row = self.get_table_row_by_value([(region, 1)])
        row.find_element(*ComputePageLocators.table_delete).click()

        time.sleep(1)
        row.find_element(*DeleteConfirmationPageLocators.yes_button).click()

    def get_cloudlet_icon_numbers(self):
        number_cloudlets = 0
        elements = self.get_all_elements(CloudletsPageLocators.cloudlets_map_icon)
        for e in elements:
            print('*WARN*', e, e.text)
            if len(e.text) > 0:
                number_cloudlets += int(e.text)

        return number_cloudlets

    def zoom_out_map(self, number_zooms=1):
        print('*WARN*', 'zoomoutmap')
        element = self.driver.find_element(*CloudletsPageLocators.cloudlets_zoom_out_icon)
        for num in range(number_zooms):
            print('*WARN*', 'zoomoutmap click')
            element.click()

    def organizations_menu_should_exist(self):
        is_present = ComputePage.is_organizations_menu_present(self)
        if is_present:
            logging.info('organizations button is present')
        else:
            raise Exception('organizations button NOT present')

    def organizations_menu_should_not_exist(self):
        is_present = ComputePage.is_organizations_menu_present(self)
        if not is_present:
            logging.info('organizations button is NOT present')
        else:
            raise Exception('organizations button IS present')

    def organization_new_button_should_be_enabled(self):
        is_present = ComputePage.is_organization_new_button_present(self)
        if is_present:
            logging.info('organization new button IS present')
        else:
            raise Exception('organization new button NOT present')

    def organization_add_user_button_should_be_enabled(self):
        is_present = ComputePage.is_organization_add_user_button_present(self)
        if is_present:
            logging.info('organization add user button IS present')
        else:
            raise Exception('organization add user button NOT present')

    def organization_add_user_button_should_be_disabled(self):
        is_present = ComputePage.is_organization_add_user_button_present(self)
        if not is_present:
            logging.info('organizations add user is NOT present')
        else:
            raise Exception('organizations add user IS present')

    def organization_trash_icon_should_be_enabled(self):
        is_present = ComputePage.is_organization_trash_icon_present(self)
        if is_present:
            logging.info('organization trash icon IS present')
        else:
            raise Exception('organization trash icon NOT present')

    def organization_manage_button_should_be_enabled(self):
        is_present = ComputePage.is_organization_manage_button_present(self)
        if is_present:
            logging.info('organization manage button IS present')
        else:
            raise Exception('organization manage button NOT present')

    def organization_trash_icon_should_be_disabled(self):
        is_present = ComputePage.is_organization_trash_icon_present(self)
        if not is_present:
            logging.info('organizations trash icon is NOT present')
        else:
            raise Exception('organizations trash icon IS present')

    def click_organization_type(self):
        self.driver.find_element(*OrganizationsPageLocators.table_header_type).click()

    def click_organization_name(self):
        self.driver.find_element(*OrganizationsPageLocators.table_header_organization).click()

    def click_cloudlet_name_heading(self):
        self.driver.find_element(*CloudletsPageLocators.cloudlets_table_header_cloudletname).click()

    def click_region_heading(self):
        self.driver.find_element(*CloudletsPageLocators.cloudlets_table_header_region).click()

    def click_operator_heading(self):
        self.driver.find_element(*CloudletsPageLocators.cloudlets_table_header_operator).click()

    def click_organization_row(self, organization):
        try:
            row = self.get_table_row_by_value([(organization, 2)])
            print('*WARN*', 'row = ', row)
            e = row.find_element_by_xpath(f'//span[contains(.,"{organization}")]')
            e.click()
        except:
            raise Exception('row is not found while trying to click app row or could not click row')

        time.sleep(1)
        return True

    def perform_search(self, searchstring):
        time.sleep(1)
        logging.info("Clicking Search button and performing search for value - " + searchstring)
        we = self.driver.find_element(*OrganizationsPageLocators.organizationpage_searchbutton)
        ActionChains(self.driver).click(on_element=we).perform()
        time.sleep(1)
        we_Input = self.driver.find_element(*OrganizationsPageLocators.organizationpage_searchInput)
        self.driver.execute_script("arguments[0].value = '';", we_Input)
        we_Input.send_keys(searchstring)
        time.sleep(1)

    def click_user_check(self, organization=None):
        if organization != None:
            row = self.get_table_row_by_value([(organization, 1)])
            row.find_element(*OrganizationsPageLocators.manage_button).click()
        else:
            self.driver.find_element(*OrganizationsPageLocators.manage_button).click()
