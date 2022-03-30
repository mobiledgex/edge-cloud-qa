from console.compute_page import ComputePage
from console.locators import PrivacyPolicyPageLocators, ComputePageLocators, DeleteConfirmationPageLocators
from selenium.webdriver.common.action_chains import ActionChains
import logging
import time

class PrivacyPolicyPage(ComputePage):

    def is_policy_present(self, region=None, developer_org_name=None, policy_name=None, rules_count=None):
        logging.info(f'is_policy_present region={region} developer_org_name={developer_org_name} policy_name={policy_name} rules_count={rules_count}')

        rows = self.get_table_rows()
        for r in rows:
            if r[1] == region and r[2] == developer_org_name and r[3] == policy_name and r[4] == rules_count and self.is_action_button_present(r[-1]):
                logging.info('found policy')
                return True

        return False

    def perform_search(self, searchstring):
        time.sleep(1)
        logging.info("Clicking Search button and performing search for value - " + searchstring)
        we = self.driver.find_element(*ComputePageLocators.searchbutton)
        ActionChains(self.driver).click(on_element=we).perform()
        time.sleep(1)
        we_Input = self.driver.find_element(*ComputePageLocators.searchInput)
        self.driver.execute_script("arguments[0].value = '';", we_Input)
        we_Input.send_keys(searchstring)
        time.sleep(1)

    def wait_for_policy(self, region=None, developer_org_name=None, policy_name=None, rules_count=None, wait=3):
        logging.info(f'wait_for_trust policy region={region} developer_org_name={developer_org_name} policy_name={policy_name} rules_count={rules_count}')

        for attempt in range(wait):
            if self.is_policy_present(region=region, developer_org_name=developer_org_name, policy_name=policy_name, rules_count=rules_count):
                return True
            else:
                time.sleep(1)

        logging.info(f'wait_for_policy timedout region={region} developer_org_name={developer_org_name} policy_name={policy_name} wait={wait}')
        return False

    def is_action_button_present(self, row):
        row.find_element(*PrivacyPolicyPageLocators.table_action)
        return True

    def delete_privacypolicy(self, region=None, developer_org_name=None, policy_name=None):
        logging.info(f'deleting Trust Policy policy_name={policy_name}')

        self.perform_search(policy_name)
        row = self.get_table_row_by_value([(policy_name , 4)])
        print('*WARN*', 'row = ', row)
        e = row.find_element(*ComputePageLocators.table_action)
        ActionChains(self.driver).click(on_element=e).perform()
        self.driver.find_element(*ComputePageLocators.table_delete).click()
        time.sleep(1)
        row.find_element(*DeleteConfirmationPageLocators.yes_button).click()

    def click_trust_policy_row(self, policy_name, region):
        try:
            row = self.get_table_row_by_value([(region, 2), (policy_name, 4)])
            print('*WARN*', 'row = ', row)
            e = row.find_element_by_xpath(f'//span[contains(.,"{policy_name}")]')
            e.click()
        except:
            raise Exception('row is not found while trying to click row or could not click row')

        time.sleep(1)
        return True
