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
from console.locators import FlavorsPageLocators
from console.locators import DeleteConfirmationPageLocators
from console.locators import ComputePageLocators
from console.locators import NewPageLocators
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.by import By
import logging
import time

class FlavorsPage(ComputePage):
    def is_flavors_table_header_present(self):
        header_present = True

        if self.is_element_present(FlavorsPageLocators.flavors_table_header_region):
            logging.info('region header present')
        else:
            logging.warning('region header not present')
            header_present = False

        if self.is_element_present(FlavorsPageLocators.flavors_table_header_flavorname):
            logging.info('flavorname header present')
        else:
            logging.warning('flavorname header not present')
            header_present = False

        if self.is_element_present(FlavorsPageLocators.flavors_table_header_ram):
            logging.info('ram header present')
        else:
            logging.warning('ram header not present')
            header_present = False

        if self.is_element_present(FlavorsPageLocators.flavors_table_header_vcpus):
            logging.info('vcpus header present')
        else:
            logging.warning('vcpus header not present')
            header_present = False

        if self.is_element_present(FlavorsPageLocators.flavors_table_header_disk):
            logging.info('disk header present')
        else:
            logging.warning('disk header not present')
            header_present = False

        if self.is_element_present(FlavorsPageLocators.flavors_table_header_edit):
            logging.info('edit header present')
        else:
            logging.warning('edit header not present')
            header_present = False

        return header_present

    def are_flavor_details_present(self):
        settings_present = True

        if self.is_element_present(NewPageLocators.flavor_flavorname_detail):
            logging.info('Flavorname detail present')
        else:
            logging.error('Flavorname detail NOT present')
            settings_present = False

        if self.is_element_present(NewPageLocators.flavor_ram_detail):
            logging.info('Flavor RAM detail present')
        else:
            logging.error('Flavor RAM detail NOT present')
            settings_present = False

        if self.is_element_present(NewPageLocators.flavor_vcpus_detail):
            logging.info('Flavor vCPUs detail present')
        else:
            logging.error('Flavor vCPUs detail NOT present')
            settings_present = False

        if self.is_element_present(NewPageLocators.flavor_disk_detail):
            logging.info('Flavor Disk detail present')
        else:
            logging.error('Flavor Disk detail NOT present')
            settings_present = False

        if self.is_element_present(NewPageLocators.flavor_gpu_detail):
            logging.info('Flavor GPU detail present')
        else:
            logging.error('Flavor GPU detail NOT present')
            settings_present = False

        return settings_present

    def is_flavor_present(self, region=None, flavor_name=None, ram=None, vcpus=None, disk=None, wait=5, gpu=None):
        self.take_screenshot('is_flavor_present_pre.png')

        logging.info(f'Looking for region={region} flavor={flavor_name} ram={ram} vcpus={vcpus} disk={disk} gpu={gpu}')

        rows = self.get_table_rows()
        for r in rows:
            logging.info("Table values - r1 = " + r[1] + ", r2 = " + r[2] + " ,r3 = " + r[3] + ", r4 = " + r[4] + ", r5 = " + r[5] + ", r6 = " + r[6])
            if r[2] == region and r[3] == flavor_name and r[4] == str(ram) and r[5] == str(vcpus) and r[6] == str(disk):
                logging.info('found flavor')
                if gpu == 'true':
                    if not self.is_gpu_icon_visible():
                        raise Exception ('GPU icon not visible')
                return True

        logging.warning('flavor not found')
        return False

    def click_next_page(self):
        e = self.driver.find_element(*FlavorsPageLocators.next_page_button)
        ActionChains(self.driver).click(on_element=e).perform()

    def click_previous_page(self):
         e = self.driver.find_element(*FlavorsPageLocators.previous_page_button)
         ActionChains(self.driver).click(on_element=e).perform()

    def perform_search(self, searchstring):
        time.sleep(1)
        logging.info("Clicking Search button and performing search for value - " + searchstring)
        we = self.driver.find_element(*FlavorsPageLocators.flavors_searchbutton)
        ActionChains(self.driver).click(on_element=we).perform()
        time.sleep(1)
        we_Input = self.driver.find_element(*FlavorsPageLocators.flavors_searchInput)
        self.driver.execute_script("arguments[0].value = '';", we_Input)
        we_Input.send_keys(searchstring)
        #self.driver.find_element(*AppsPageLocators.apps_page_searchInput).send_keys(searchstring)
        time.sleep(1)

    def wait_for_flavor(self, region=None, flavor_name=None, ram=None, vcpus=None, disk=None, number_of_pages=None, click_previous_page=None, gpu=None):
        index = 0
        logging.info(f'Wait for flavor  region={region} flavor={flavor_name} ram={ram} vcpus={vcpus} disk={disk} number_of_pages={number_of_pages} click_previous_page={click_previous_page} gpu={gpu}')
        for x in range(0, number_of_pages):
            for attempt in range(2):
                if self.is_flavor_present(region, flavor_name, ram, vcpus, disk, gpu=gpu):
                    if ((index>0) and (click_previous_page is None)):
                        self.click_previous_page()
                    return True
                else:
                    time.sleep(1)
            index += 1
            
        return False

    def delete_flavor(self, region=None, flavor_name=None, ram=None, vcpus=None, disk=None, decision=None):

        logging.info(f'deleting flavor region={region} flavor_name={flavor_name} ')
        self.perform_search(flavor_name)
        row = self.get_table_row_by_value([(flavor_name, 4)])
        print('*WARN*', 'row = ', row)
        #row.find_element(*ComputePageLocators.table_action).click()
        e = row.find_element(*ComputePageLocators.table_action)
        ActionChains(self.driver).click(on_element=e).perform()
        self.driver.find_element(*ComputePageLocators.table_delete).click()

        time.sleep(1)
        row.find_element(*DeleteConfirmationPageLocators.yes_button).click()


    def click_rows_per_page_pulldown(self):
        self.driver.find_element(*FlavorsPageLocators.rows_per_page).click()

    def click_rows_per_page_pulldown_option(self):
        self.driver.find_element(*FlavorsPageLocators.rows_per_page_75).click()

    def change_rows_per_page(self):
        self.click_rows_per_page_pulldown()
        self.click_rows_per_page_pulldown_option()

    def flavor_rows_per_page(self):
        self.change_rows_per_page()

    def click_flavorRegion(self):
        self.driver.find_element(*FlavorsPageLocators.flavors_table_header_region).click()

    def click_flavorName(self):
        self.driver.find_element(*FlavorsPageLocators.flavors_table_header_flavorname).click()

    def click_flavorRAM(self):
        self.driver.find_element(*FlavorsPageLocators.flavors_table_header_ram).click()

    def click_flavorVCPUS(self):
        self.driver.find_element(*FlavorsPageLocators.flavors_table_header_vcpus).click()

    def click_flavorDisk(self):
        self.driver.find_element(*FlavorsPageLocators.flavors_table_header_disk).click()

    def click_flavorEdit(self):
        self.driver.find_element(*FlavorsPageLocators.flavors_table_header_edit).click()

    def click_flavorButtonEdit(self):
        self.driver.find_element(*FlavorsPageLocators.flavors_table_button_edit).click()

    def click_flavorDelete(self):
        self.driver.find_element(*FlavorsPageLocators.table_delete).click()

    def click_deleteNo(self):
        self.driver.find_element(*DeleteConfirmationPageLocators.no_button).click()

    def click_close_flavor_details(self):
        self.driver.find_element(*FlavorsPageLocators.close_button).click()

    def click_flavor_row(self, flavor_name, region):
        try:
            row = self.get_table_row_by_value([(region, 3), (flavor_name, 4)])
        except:
            logging.info('row is not found')
            return False

        time.sleep(1)
        e = row.find_element_by_xpath(f'//span[contains(.,"{flavor_name}")]')
        e.click()
        return True

    def flavors_menu_should_exist(self):
        is_present = ComputePage.is_flavors_menu_present(self)
        if is_present:
            logging.info('flavors button is present')
        else:
            raise Exception('flavors button NOT present')
    
    def flavors_menu_should_not_exist(self):
        is_present = ComputePage.is_flavors_menu_present(self)
        if not is_present:
            logging.info('flavors button is NOT present')
        else:
            raise Exception('flavors button IS present')
    

    def flavors_new_button_should_be_enabled(self):
        is_present = ComputePage.is_flavors_new_button_present(self)
        if is_present:
            logging.info('flavors new button IS present')
        else:
            raise Exception('flavors new button is NOT present')

    def flavors_new_button_should_be_disabled(self):
        is_present = ComputePage.is_flavors_new_button_present(self)
        if not is_present:
            logging.info('flavors new button is NOT present')
        else:
            raise Exception('flavors new button IS present')

    def flavors_trash_icon_should_be_enabled(self):
        is_present = ComputePage.is_flavors_trash_icon_present(self)
        if is_present:
            logging.info('flavors trash icon IS present')
        else:
            raise Exception('flavors trash icon is NOT present')
    
    def flavors_trash_icon_should_be_disabled(self):
        is_present = ComputePage.is_flavors_trash_icon_present(self)
        if not is_present:
            logging.info('flavors trash icon is NOT present')
        else:
            raise Exception('flavors trash icon IS present')
    
    def is_gpu_icon_visible(self):
        if self.is_element_present(FlavorsPageLocators.flavors_table_gpu_icon):
            logging.info('GPU icon visible for flavor row')
            return True
        else:
            logging.info('GPU icon NOT visible for flavor row')
            return False

