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

    def get_flavor_sort(self, type):  # START HERE MONDAY! CAN U PASS A STRING AS AN ATTRIBUTE
        resp = []
                    # type is flavorname/ram/vcpus/disk
        rows = self.get_table_rows()
        if (type == "flavorname"):
            for r in rows:
                resp.append([FlavorsPageLocators.flavors_table_header_flavorname, FlavorsPageLocators.flavors_table_header_ram,FlavorsPageLocators.flavors_table_header_vcpus,FlavorsPageLocators.flavors_table_header_disk,'Edit'])
                print('*WARN*', 'flavor: ', r)
                resp = sorted(resp)  # only need alphabetically
        elif (type == "ram"):
            for r in rows:
                resp.append(FlavorsPageLocators.flavors_table_header_ram)
                print('*WARN*', 'flavor: ', r)
                resp = sorted(resp)  # only need #ers
        elif type == "vcpus":
            for r in rows:
                resp.append(FlavorsPageLocators.flavors_table_header_vcpus)
                print('*WARN*', 'flavor: ', r)
                resp = sorted(resp)
        elif type == "disk":
            for r in rows:
                resp.append(FlavorsPageLocators.flavors_table_header_disk)
                print('*WARN*', 'flavor: ', r)
                resp = sorted(resp)
        else:  # edit passed in (or a weird error)
            print('*WARN*', 'flavor sort FAILED: ', rows)

        logging.info('Flavor list sorted')
        print(resp)  # for Edit should be identical
        return resp

    def check_numerical_sorted(self, inList, type):
        for entryOfType in inList:
            if entryOfType >= entryOfType + 1:
                variable = 0
        # if I can find out how table is ordered, like, inList[ram][0]

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
