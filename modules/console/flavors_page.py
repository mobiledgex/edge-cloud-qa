from console.compute_page import ComputePage
from console.locators import FlavorsPageLocators

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

        if self.is_element_present(FlavorsPageLocators.flavors_table_header_edit):
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
            print('*WARN*', 'WWWWW')
            if self.is_flavor_present(region, flavor_name, ram, vcpus, disk):
                return True
            else:
                time.sleep(1)

        return False

    
