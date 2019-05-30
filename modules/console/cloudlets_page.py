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

    def is_flavor_present(self, region=None, flavor_name=None, ram=None, vcpus=None, disk=None, wait=5):
        self.take_screenshot('is_flavor_present_pre.png')

        rows = self.get_table_rows()
        for r in rows:
            print('*WARN*', 'flavorr', r, r[2], region, flavor_name, ram, vcpus, disk)
            if r[0] == region and r[1] == flavor_name and r[2] == str(ram) and r[3] == str(vcpus) and r[4] == str(disk):
                print('*WARN*', 'found flavor')
                return True

        return False

    def wait_for_flavor(self, region=None, flavor_name=None, ram=None, vcpus=None, disk=None, wait=5):
        for attempt in range(wait):
            if self.is_flavor_present(region, flavor_name, ram, vcpus, disk):
                return True
            else:
                time.sleep(1)

        return False

    
