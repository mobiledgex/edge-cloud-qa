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
from console.locators import UsersPageLocators, ComputePageLocators, DeleteConfirmationPageLocators, OrganizationsPageLocators
from console.base_page import BasePage, BasePageElement, BasePagePulldownElement
from console.new_settings_page import NewSettingsPage
from console.details_page import DetailsPage


import logging
import time

class FilterElement(BasePageElement):
    locator = UsersPageLocators.user_pulldown_input

class UserNameElement(BasePageElement):
    locator = UsersPageLocators.user_name_input

class UserName2Element(BasePageElement):
    locator = OrganizationsPageLocators.username_input

class RoleElement(BasePagePulldownElement):
    locator = OrganizationsPageLocators.role_input

class UsersPage(ComputePage):

    def is_users_table_header_present(self):
        header_present = True

        if self.is_element_present(UsersPageLocators.users_table_header_username):
            logging.info('user header present')
        else:
            logging.error('User header NOT present')
            header_present = False

        if self.is_element_present(UsersPageLocators.users_table_header_organization):
            logging.info('organization header present')
        else:
            logging.error('organization header NOT present')
            header_present = False

        if self.is_element_present(UsersPageLocators.users_table_header_roletype):
            logging.info('role type header present')
        else:
            logging.error('role type header NOT present')
            header_present = False

        return header_present

    def are_account_details_present(self):
        detail_present = True

        if self.is_element_present(UsersPageLocators.users_image):
            logging.info('user image present')
        else:
            logging.error('user image NOT present')
            detail_present = False

        #if self.is_element_present(UsersPageLocators.users_name):
        #    logging.info('username present')
        #else:
        #    logging.error('username NOT present')
        #    detail_present = False
        # Username changes per element, passing in the username to locators.py is hard

        if self.is_element_present(UsersPageLocators.users_organization):
            logging.info('organization present')
        else:
            logging.error('organization NOT present')
            detail_present = False

        if self.is_element_present(UsersPageLocators.users_role_type):
            logging.info('role type present')
        else:
            logging.error('role type NOT present')
            detail_present = False

        return detail_present

    def is_user_present(self, user_name=None, organization=None, role_type=None):
        found = False

        rows = self.get_table_rows()
        for r in rows:
            if r[0] == user_name and r[1] == organization and r[2] == role_type:
                found = True
                logging.info('found user')
                return True

        return False

    def wait_for_user(self, user_name=None, organization=None, role_type=None, wait=5):
        logging.info(f'wait_for_user user_name={user_name} organization={organization} role_type={role_type}')
        for attempt in range(wait):
            if self.is_user_present(user_name=user_name, organization=organization, role_type=role_type):
                return True
            else:
                time.sleep(1)

        logging.error(f'timeout waiting for user {user_name}')
        return False

    def click_user_row(self, username):
        row = self.get_table_row_by_value([(username, 1)]).click()
        #user_details = '//div[@class="grid_table"]/table/tbody/tr/td/div[text()='
        #user_plus = user_details + '"' + username + '"' + ']'
        #logging.info(user_plus)
        #row.find_element(By.XPATH, user_plus).click()

    def click_users_name_heading(self):
        self.driver.find_element(*UsersPageLocators.users_table_header_username).click()

    def click_users_organization_heading(self):
        self.driver.find_element(*UsersPageLocators.users_table_header_organization).click()

    def click_users_roletype_heading(self):
        self.driver.find_element(*UsersPageLocators.users_table_header_roletype).click()

    def click_close_user_details(self):
        self.driver.find_element(*UsersPageLocators.close_button).click()

    def users_menu_should_exist(self):
        is_present = ComputePage.is_users_menu_present(self)
        if is_present:
            logging.info('users button is present')
        else:
            raise Exception('users button NOT present')
    
    def users_menu_should_not_exist(self):
        is_present = ComputePage.is_users_menu_present(self)
        if not is_present:
            logging.info('users button is NOT present')
        else:
            raise Exception('users button IS present')
    
    def users_trash_icon_should_be_enabled(self):
        is_present = ComputePage.is_users_trash_icon_present(self)
        if is_present:
            logging.info('users trash icon IS present')
        else:
            raise Exception('users trash icon NOT present')
    
    def users_trash_icon_should_be_disabled(self):
        is_present = ComputePage.is_users_trash_icon_present(self)
        if not is_present:
            logging.info('users trash icon is NOT present')
        else:
            raise Exception('users trash icon IS present')

class NewUsersPage(NewSettingsPage):
    #username = UserNameElement()
    #filter = FilterElement()
    username2 = UserName2Element()
    role = RoleElement()
    # Something with dependancies wasn't working so needed to build on the settings Page
    # That built on the BASE_page not COMPUTE_page and so on the new settings page
    # The inheriting worked
    def add_organization_user(self, username=None, organization=None, role=None, flag=None):
          if flag == 'after_org_create':
              row = ComputePage.get_table_row_by_value(self, [(organization, 1)])
              row.find_element(*OrganizationsPageLocators.table_action).click()
              self.driver.find_element(*OrganizationsPageLocators.add_organization_user).click()

          logging.info('Adding user to Organization')

          self.username2 = username
          self.role = role
          self.take_screenshot('add_new_userrole.png')
          logging.info('Added role to Organization')

          #self.take_screenshot('add_new_flavor_settings.png')
          time.sleep(3)
          self.driver.find_element(*OrganizationsPageLocators.add_organization_user_confirm).click()
          #self.driver.find_element(*OrganizationsPageLocators.add_organization_user_finished).click()

    def click_return_to_org(self):
        self.driver.find_element(*OrganizationsPageLocators.return_to_org).click()

    def click_skip(self):
        self.driver.find_element(*OrganizationsPageLocators.add_organization_user_finished).click()

    def click_close(self):
        self.driver.find_element(*OrganizationsPageLocators.close_button).click()

    def change_filter(self, choice=None):
        logging.info('Selecting filter choice from pulldown:' + choice)
        self.filter = choice
        logging.info('Filter successfully selected')
        time.sleep(2)

    def search_for_user(self, username=None, organization=None):
        logging.info('Inputting username in searchbox')
        if username == None:
            self.username = organization
        else:
            self.username = username
        logging.info('successfully input username')
        time.sleep(2)
