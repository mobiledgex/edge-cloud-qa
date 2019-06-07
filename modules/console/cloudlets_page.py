from console.compute_page import ComputePage
from console.locators import CloudletsPageLocators

import logging
import time

class CloudletsPage(ComputePage):
    def is_cloudlets_table_header_present(self):
        header_present = True
        
        if self.is_element_present(CloudletsPageLocators.cloudlets_table_header_region):
            logging.info('region header present')
        else:
            header_present = False
            
        if self.is_element_present(CloudletsPageLocators.cloudlets_table_header_cloudletname):
            logging.info('cloudletname header present')
        else:
            header_present = False

        if self.is_element_present(CloudletsPageLocators.cloudlets_table_header_operator):
            logging.info('operator header present')
        else:
            header_present = False

        if self.is_element_present(CloudletsPageLocators.cloudlets_table_header_cloudletlocation):
            logging.info('location header present')
        else:
            header_present = False

        if self.is_element_present(CloudletsPageLocators.cloudlets_table_header_edit):
            logging.info('edit header present')
        else:
            header_present = False

        return header_present

    def is_cloudlet_present(self, region=None, cloudlet_name=None, operator=None, latitude=None, longitude=None):
        #self.take_screenshot('is_cloudlet_present_pre.png')

        rows = self.get_table_rows()
        for r in rows:
            print('*WARN*', 'cloudlet', r, r[2], region, cloudlet_name, operator)
            location = f'Latitude : {latitude} Longitude : {longitude}'
            if r[0] == region and r[1] == cloudlet_name and r[2] == operator and r[3] == location:
                logging.info('found app')
                return True

        return False

    def wait_for_cloudlet(self, region=None, cloudlet_name=None, operator=None, latitude=None, longitude=None, wait=5):
        logging.info(f'wait_for_cloudlet region={region} cloudlet={cloudlet_name} operator={operator} latitude={latitude} longitude={longitude}')
        for attempt in range(wait):
            if self.is_cloudlet_present(region=region, cloudlet_name=cloudlet_name, operator=operator, latitude=latitude, longitude=longitude ):
                return True
            else:
                time.sleep(1)

        logging.error(f'timeout waiting for cloudlet region={region} cloudlet={cloudlet_name} operator={operator} latitude={latitude} longitude={longitude}')
        return False

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

    def click_cloudlet_name_heading(self):
        self.driver.find_element(*CloudletsPageLocators.cloudlets_table_header_cloudletname).click()

    def click_region_heading(self):
        self.driver.find_element(*CloudletsPageLocators.cloudlets_table_header_region).click()

    def click_operator_heading(self):
        self.driver.find_element(*CloudletsPageLocators.cloudlets_table_header_operator).click()
