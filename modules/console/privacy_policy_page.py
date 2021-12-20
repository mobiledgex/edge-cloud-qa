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

    def wait_for_policy(self, region=None, developer_org_name=None, policy_name=None, rules_count=None, wait=3):
        logging.info(f'wait_for_app region={region} developer_org_name={developer_org_name} policy_name={policy_name} rules_count={rules_count}')

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
        logging.info(f'deleting Auto Scale Policy policy_name={policy_name}')
        totals_rows = self.driver.find_elements(*ComputePageLocators.details_row)
        total_rows_length = len(totals_rows)
        total_rows_length += 1
        for row in range(1, total_rows_length):
            table_column =  f'//tbody/tr[{row}]/td[4]/div'
            value = self.driver.find_element_by_xpath(table_column).text
            if value == policy_name:
                i = row
                break

        table_action = f'//tbody/tr[{i}]/td[6]//button[@aria-label="Action"]'
        e = self.driver.find_element_by_xpath(table_action)
        ActionChains(self.driver).click(on_element=e).perform()
        self.driver.find_element(*ComputePageLocators.table_delete).click()
        self.driver.find_element(*DeleteConfirmationPageLocators.yes_button).click()    

