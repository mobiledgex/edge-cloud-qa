from console.compute_page import ComputePage
from console.locators import NetworksPageLocators
from console.locators import DeleteConfirmationPageLocators
from console.locators import ComputePageLocators
from console.locators import NewPageLocators
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.by import By
import logging
import time

class NetworksPage(ComputePage):
    def is_networks_table_header_present(self):
        header_present = True

        if self.is_element_present(NetworksPageLocators.networks_table_header_region):
            logging.info('region header present')
        else:
            logging.error('region header not present')
            header_present = False

        if self.is_element_present(NetworksPageLocators.networks_table_header_networkname):
            logging.info('networkname header present')
        else:
            logging.error('networkname header not present')
            header_present = False

        if self.is_element_present(NetworksPageLocators.networks_table_connection_type):
            logging.info('connection type header present')
        else:
            logging.error('connection type not present')
            header_present = False

        if self.is_element_present(NetworksPageLocators.networks_table_header_cloudlet):
            logging.info('cloudlet header present')
        else:
            logging.error('cloudlet header not present')
            header_present = False

        if self.is_element_present(NetworksPageLocators.networks_table_header_operator):
            logging.info('operator header present')
        else:
            logging.error('operator header not present')
            header_present = False

        if self.is_element_present(NetworksPageLocators.networks_table_header_actions):
            logging.info('actions header present')
        else:
            logging.error('actions header not present')
            header_present = False

        return header_present

    def are_network_details_present(self):
        settings_present = True

        if self.is_element_present(NetworksPageLocators.networks_networknamelabel_detail):
            logging.info('Network name label detail present')
        else:
            logging.error('Network name label NOT present')
            settings_present = False

        if self.is_element_present(NetworksPageLocators.networks_connectiontypelabel_detail):
            logging.info('Connection Type label detail present')
        else:
            logging.error('Connection Type label detail NOT present')
            settings_present = False

        if self.is_element_present(NetworksPageLocators.networks_operatorlabel_detail):
            logging.info('Operator label detail present')
        else:
            logging.error('Operator label detail NOT present')
            settings_present = False

        if self.is_element_present(NetworksPageLocators.networks_cloudletlabel_detail):
            logging.info('Cloudlet label detail present')
        else:
            logging.error('Cloudlet label detail NOT present')
            settings_present = False

        return settings_present

    def is_network_present(self, region=None, network_name=None, connection_type=None, cloudlet=None, organization=None, wait=5):
        self.take_screenshot('is_network_present_pre.png')

        logging.info(f'Looking for region={region} network_name={network_name} connection_type={connection_type} cloudlet={cloudlet} organization={organization} ')

        rows = self.get_table_rows()
        for r in rows:
            logging.info("Table values - r1 = " + r[1] + ", r2 = " + r[2] + " ,r3 = " + r[3] + ", r4 = " + r[4] + ", r5 = " + r[5] )
            if r[1] == region and r[2] == network_name and r[3] == connection_type and r[4] == cloudlet and r[5] == organization  :
                logging.info('found network')
                return True

        logging.warning('network not found')
        return False


    def perform_search(self, searchstring):
        time.sleep(1)
        logging.info("Clicking Search button and performing search for value - " + searchstring)
        we = self.driver.find_element(*NetworksPageLocators.networks_searchbutton)
        ActionChains(self.driver).click(on_element=we).perform()
        time.sleep(1)
        we_Input = self.driver.find_element(*NetworksPageLocators.networks_searchInput)
        self.driver.execute_script("arguments[0].value = '';", we_Input)
        we_Input.send_keys(searchstring)
        time.sleep(1)

    def wait_for_network(self, region=None, network_name=None, organization=None, cloudlet=None, connection_type=None):
        index = 0
        logging.info(f'Wait for network  region={region} network_name={network_name} connection_type={connection_type} cloudlet={cloudlet} organization={organization}')

        for attempt in range(2):
            if self.is_network_present(region, network_name, connection_type, cloudlet, organization):
                return True
            else:
                time.sleep(1)

        return False

    def delete_network(self, region=None, network_name=None, connection_type=None, cloudlet=None, organization=None):

        logging.info(f'deleting network region={region} flavor_name={network_name} ')
        self.perform_search(network_name)
        row = self.get_table_row_by_value([(network_name, 3)])
        print('*WARN*', 'row = ', row)
        e = row.find_element(*ComputePageLocators.table_action)
        ActionChains(self.driver).click(on_element=e).perform()
        self.driver.find_element(*ComputePageLocators.table_delete).click()

        time.sleep(1)
        row.find_element(*DeleteConfirmationPageLocators.yes_button).click()


    def click_deleteNo(self):
        self.driver.find_element(*DeleteConfirmationPageLocators.no_button).click()

    def click_close_network_details(self):
        self.driver.find_element(*NetworksPageLocators.close_button).click()

    def click_network_row(self, network_name, region):
        try:
            row = self.get_table_row_by_value([(region, 2), (network_name, 3)])
        except:
            logging.warning('row is not found')
            return False

        time.sleep(1)
        e = row.find_element_by_xpath(f'//span[contains(.,"{network_name}")]')
        e.click()
        return True



