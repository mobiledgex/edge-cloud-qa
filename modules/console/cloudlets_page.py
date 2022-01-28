from console.compute_page import ComputePage
from console.locators import CloudletsPageLocators, ComputePageLocators, DeleteConfirmationPageLocators
from selenium.webdriver.common.action_chains import ActionChains
import logging
import time

class CloudletsPage(ComputePage):
    def is_cloudlets_table_header_present(self):
        header_present = True
        
        if self.is_element_present(CloudletsPageLocators.cloudlets_table_header_region):
            logging.info('region header present')
        else:
            logging.error('region header not present')
            header_present = False
            
        if self.is_element_present(CloudletsPageLocators.cloudlets_table_header_cloudletname):
            logging.info('cloudletname header present')
        else:
            logging.error('cloudletname header not present')
            header_present = False

        if self.is_element_present(CloudletsPageLocators.cloudlets_table_header_operator):
            logging.info('operator header present')
        else:
            logging.error('operator header not present')
            header_present = False

        if self.is_element_present(CloudletsPageLocators.cloudlets_table_header_status):
            logging.info('status header present')
        else:
            logging.error('status header not present')
            header_present = False

        if self.is_element_present(CloudletsPageLocators.cloudlets_table_header_progress):
            logging.info('progress header present')
        else:
            logging.error('progress header not present')
            header_present = False

            
#        if self.is_element_present(CloudletsPageLocators.cloudlets_table_header_cloudletlocation):
#            logging.info('location header present')
#        else:
#            logging.error('location header not present')
#            header_present = False

        if self.is_element_present(CloudletsPageLocators.cloudlets_table_header_edit):
            logging.info('actions header present')
        else:
            logging.error('actions header not present')
            header_present = False

        return header_present

    def is_cloudlet_present(self, region=None, cloudlet_name=None, operator=None, latitude=None, longitude=None, state=None):
        #self.take_screenshot('is_cloudlet_present_pre.png')
        logging.info(f'is_cloudlet_present region={region} cloudlet_name={cloudlet_name} operator={operator} latitude={latitude} longitude={longitude} state={state}')
        cloudlet_found = False
        
        # do this because the ui converts 5.0 to 5
        #if latitude is not None and float(latitude).is_integer():
        #    latitude = int(latitude)
        #    #print('*WARN*', latitude)
        #if longitude is not None and float(longitude).is_integer():
        #    longitude = int(longitude)
        #    #print('*WARN*', longitude)
        if state is not None:
            state = int(state)
        if state == 5:
            state = 'Online'
        elif state == 8:
            state = 'Init'
        elif state == 11:
            state = 'Not Present'
        elif state == 13:
            state = 'Error'
            
        rows = self.get_table_rows()
        #print('*WARN*', "GOT HERE", rows)
        for r in rows:
            #location = f'Latitude : {latitude}\nLongitude : {longitude}'
            logging.info("Table values - r1 = " + r[1] + ", r2 = " + r[2] + " ,r3 = " + r[3] + ", r4 = " + r[4]+ ", r5 = " + r[5])

            #print('*WARN*', 'r[3]', r[3], 'location', location)
            if r[2] == region and r[3] == operator and r[4] == cloudlet_name:
                if state:
                    if r[5] == state:
                        cloudlet_found = True
                else:
                    cloudlet_found = False
                #if latitude and longitude:
                    #if r[3] != location:
                        #print('*WARN*', "GOT HERE")
                        #cloudlet_found = False

                if cloudlet_found:
                    logging.info('found cloudlet')
                    return True
                else: 
                    logging.info('did NOT find cloudlet')

        return False

    def perform_search(self, searchstring):
        time.sleep(1)
        logging.info("Clicking Search button and performing search for value - " + searchstring)
        we = self.driver.find_element(*CloudletsPageLocators.cloudlets_searchbutton)
        ActionChains(self.driver).click(on_element=we).perform()
        time.sleep(1)
        we_Input = self.driver.find_element(*CloudletsPageLocators.cloudlets_searchInput)
        self.driver.execute_script("arguments[0].value = '';", we_Input)
        we_Input.send_keys(searchstring)
        time.sleep(1)

    def wait_for_cloudlet(self, region=None, cloudlet_name=None, operator=None, latitude=None, longitude=None, state=None, wait=None):
        logging.info(f'wait_for_cloudlet region={region} cloudlet_name={cloudlet_name} operator={operator} latitude={latitude} longitude={longitude} state={state}')
        self.perform_search(cloudlet_name)
        for attempt in range(wait):
            if self.is_cloudlet_present(region=region, cloudlet_name=cloudlet_name, operator=operator, latitude=latitude, longitude=longitude, state=state ):
                return True
            else:
                time.sleep(1)

        logging.error(f'timeout waiting for cloudlet region={region} cloudlet_name={cloudlet_name} operator={operator} latitude={latitude} longitude={longitude} state={state}')
        return False

    def delete_cloudlet(self, region=None, cloudlet_name=None, operator=None):
        logging.info(f'deleting cloudlet region={region} cloudlet_name={cloudlet_name} operator={operator}')
        self.perform_search(cloudlet_name)
        row = self.get_table_row_by_value([(region, 3), (cloudlet_name, 5)])
        row.find_element(*ComputePageLocators.table_action).click()
        self.driver.find_element(*ComputePageLocators.table_delete).click()
    
        time.sleep(1)
        row.find_element(*DeleteConfirmationPageLocators.yes_button).click()
    
    def show_cloudlet_manifest(self, region=None, cloudlet_name=None, operator=None):
        logging.info(f'Displaying manifest cloudlet region={region} cloudlet_name={cloudlet_name} operator={operator}')
        row = self.get_table_row_by_value([(region, 2), (cloudlet_name, 3), (operator, 4)])
        row.find_element(*ComputePageLocators.table_action).click()
        self.driver.find_element(*ComputePageLocators.show_manifest).click()
    
    def select_show_manifest_option(self, option=None):
        logging.info(f'Selecting {option}')
        if option == 'YES':
            self.driver.find_element(*CloudletsPageLocators.select_yes).click()
        else:
            self.driver.find_element(*CloudletsPageLocators.select_no).click()
        return True

    def get_cloudlet_icon_numbers(self):
        number_cloudlets = 0
        elements = self.get_all_elements(CloudletsPageLocators.cloudlets_map_icon)
        for e in elements:
            logging.info(f'found cloudlet icon {e.text}')
            if len(e.text) > 0:
                number_cloudlets += int(e.text)

        return number_cloudlets
    
    def zoom_out_map(self, number_zooms=1):
        logging.info(f'zoomoutmap {number_zooms} times')
        element = self.driver.find_element(*CloudletsPageLocators.cloudlets_zoom_out_icon)
        for num in range(number_zooms):
            element.click()

    def click_cloudlet_name_heading(self):
        self.driver.find_element(*CloudletsPageLocators.cloudlets_table_header_cloudletname).click()

    def click_region_heading(self):
        self.driver.find_element(*CloudletsPageLocators.cloudlets_table_header_region).click()

    def click_operator_heading(self):
        self.driver.find_element(*CloudletsPageLocators.cloudlets_table_header_operator).click()

    def click_cloudlet_row(self, cloudlet_name, region):
        logging.info('clicking cloudlet' + cloudlet_name + '  ' + region)
        r = self.get_table_row_by_value([(region, 3), (cloudlet_name, 5)])
        time.sleep(1)
        e = r.find_element_by_xpath(f'//span[contains(.,"{cloudlet_name}")]')
        e.click()
        return True
    
    def cloudlets_menu_should_exist(self):
        is_present = ComputePage.is_cloudlets_menu_present(self)
        if is_present:
            logging.info('clouldets button is present')
        else:
            raise Exception('clouldets button NOT present')
    
    def cloudlets_menu_should_not_exist(self):
        is_present = ComputePage.is_cloudlets_menu_present(self)
        if not is_present:
            logging.info('clouldets button is NOT present')
        else:
            raise Exception('clouldets button IS present')
    
    def cloudlets_new_button_should_be_enabled(self):
        is_present = ComputePage.is_cloudlet_new_button_present(self)
        if is_present:
            logging.info('cloudlet new button IS present')
        else:
            raise Exception('cloudlet new button is NOT present')
        
    def cloudlets_new_button_should_be_disabled(self):
        is_present = ComputePage.is_cloudlet_new_button_present(self)
        if not is_present:
            logging.info('cloudlet new button is NOT present')
        else:
            raise Exception('cloudlet new button IS present')
    
    def cloudlets_trash_icon_should_be_enabled(self):
        is_present = ComputePage.is_cloudlet_trash_icon_present(self)
        if is_present:
            logging.info('cloudlet trash icon IS present')
        else:
            raise Exception('cloudlet trash icon is NOT present')

    def cloudlets_trash_icon_should_be_disabled(self):
        is_present = ComputePage.is_cloudlet_trash_icon_present(self)
        if not is_present:
            logging.info('cloudlet trash icon is NOT present')
        else:
            raise Exception('cloudlet trash icon IS present')

   
