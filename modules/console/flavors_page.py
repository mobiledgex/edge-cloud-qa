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
            header_present = False

        if self.is_element_present(FlavorsPageLocators.flavors_table_header_flavorname):
            logging.info('flavorname header present')
        else:
            header_present = False

        if self.is_element_present(FlavorsPageLocators.flavors_table_header_ram):
            logging.info('ram header present')
        else:
            header_present = False

        if self.is_element_present(FlavorsPageLocators.flavors_table_header_vcpus):
            logging.info('vcpus header present')
        else:
            header_present = False

        if self.is_element_present(FlavorsPageLocators.flavors_table_header_disk):
            logging.info('disk header present')
        else:
            header_present = False

        if self.is_element_present(FlavorsPageLocators.flavors_table_header_gpu):
            logging.info('GPU header present')
        else:
            header_present = False

        if self.is_element_present(FlavorsPageLocators.flavors_table_header_edit):
            logging.info('edit header present')
        else:
            header_present = False

        return header_present

    def are_flavor_details_present(self):
        settings_present = True

        if self.is_element_present(NewPageLocators.flavor_flavorname_detail):
            logging.info('Flavorname detail present')
        else:
            settings_present = False

        if self.is_element_present(NewPageLocators.flavor_ram_detail):
            logging.info('Flavor RAM detail present')
        else:
            settings_present = False

        if self.is_element_present(NewPageLocators.flavor_vcpus_detail):
            logging.info('Flavor vCPUs detail present')
        else:
            settings_present = False

        if self.is_element_present(NewPageLocators.flavor_disk_detail):
            logging.info('Flavor Disk detail present')
        else:
            settings_present = False

        if self.is_element_present(NewPageLocators.flavor_gpu_detail):
            logging.info('Flavor GPU detail present')
        else:
            settings_present = False

        return settings_present

    def is_flavor_present(self, region=None, flavor_name=None, ram=None, vcpus=None, disk=None, wait=5):
        self.take_screenshot('is_flavor_present_pre.png')

        logging.info(f'Looking for region={region} flavor={flavor_name} ram={ram} vcpus={vcpus} disk={disk}')

        rows = self.get_table_rows()
        for r in rows:
            #print('*WARN*', 'flavorr', r, r[2], region, flavor_name, ram, vcpus, disk)
            if r[1] == region and r[2] == flavor_name and r[3] == str(ram) and r[4] == str(vcpus) and r[5] == str(disk):
                logging.info('found flavor')
                return True

        logging.error('flavor not found')
        return False

    def click_next_page(self):
        e = self.driver.find_element(*FlavorsPageLocators.next_page_button)
        ActionChains(self.driver).click(on_element=e).perform()

    def click_previous_page(self):
         e = self.driver.find_element(*FlavorsPageLocators.previous_page_button)
         ActionChains(self.driver).click(on_element=e).perform()

    def wait_for_flavor(self, region=None, flavor_name=None, ram=None, vcpus=None, disk=None, number_of_pages=None, click_previous_page=None):
        index = 0
        #e = self.driver.find_element(*FlavorsPageLocators.next_page_button)
        for x in range(0, number_of_pages):
            for attempt in range(2):
                #print('*WARN*', 'Searching across flavors')
                if self.is_flavor_present(region, flavor_name, ram, vcpus, disk):
                    if ((index>0) and (click_previous_page is None)):
                        self.click_previous_page()
                    return True
                else:
                    time.sleep(1)
            #self.driver.find_element(*FlavorsPageLocators.next_page_button).click()
            self.click_next_page()
            index += 1
            
        return False

    def delete_flavor(self, region=None, flavor_name=None, ram=None, vcpus=None, disk=None, decision=None):
        #row = self.get_table_row_by_value([(region, 1), (flavor_name, 2)])  # don't use INTs bc it reads text_value as string
        #print('*WARN*', 'found row')
        #row.find_element(*ComputePageLocators.table_action).click()
        #print('*WARN*', 'clicked action')

        totals_rows = self.driver.find_elements(*FlavorsPageLocators.details_row)
        total_rows_length = len(totals_rows)
        total_rows_length = total_rows_length + 1
        for row in range(1, total_rows_length):
            table_column =  f'//tbody/tr[{row}]/td[3]/div'
            value = self.driver.find_element_by_xpath(table_column).text
            if value == flavor_name:
                i = row
                break

        table_action = f'//tbody/tr[{i}]/td[8]//button[@aria-label="Action"]' 
        e = self.driver.find_element_by_xpath(table_action)
        ActionChains(self.driver).click(on_element=e).perform()
        self.driver.find_element(*ComputePageLocators.table_delete).click()
        print('*WARN*', 'clicked delete')
        #time.sleep(10)
        if (decision != None):
            decision = decision.lower()
        if (decision == 'no' or decision == 'cant'):
            print('*WARN*', 'Not deleting row ', row)
            time.sleep(3)
            self.driver.find_element(*DeleteConfirmationPageLocators.no_button).click()
        else:
            #print('*WARN*', 'delete row ', row)
            time.sleep(3)
            self.driver.find_element(*DeleteConfirmationPageLocators.yes_button).click()

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

    def click_flavor_row(self, flavor_name, region='US'):
        try:
            row = self.get_table_row_by_value([(region, 2), (flavor_name, 3)])
        except:
            logging.info('row is not found')
            return False

        time.sleep(1)
        ActionChains(self.driver).click(on_element=row).perform()
        return True
        #row.click()

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
    

    
