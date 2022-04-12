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
from console.locators import AutoScalePolicyPageLocators, ComputePageLocators, DeleteConfirmationPageLocators
from selenium.webdriver.common.action_chains import ActionChains
import logging
import time

class AutoScalePolicyPage(ComputePage):

    def is_policy_present(self, region=None, developer_org_name=None, policy_name=None, min_nodes=None, max_nodes=None):
        logging.info(f'is_policy_present region={region} developer_org_name={developer_org_name} policy_name={policy_name} min_nodes={min_nodes} max_nodes={max_nodes}')

        rows = self.get_table_rows()
        for r in rows:
            if r[1] == region and r[2] == developer_org_name and r[3] == policy_name and int(r[4]) == min_nodes and int(r[5]) == max_nodes and self.is_action_button_present(r[-1]):
                logging.info('found policy')
                return True

        return False

    def perform_search(self, searchstring):
        time.sleep(1)
        logging.info("Clicking Search button and performing search for value - " + searchstring)
        we = self.driver.find_element(*AutoScalePolicyPageLocators.searchbutton)
        ActionChains(self.driver).click(on_element=we).perform()
        time.sleep(1)
        we_Input = self.driver.find_element(*AutoScalePolicyPageLocators.searchInput)
        self.driver.execute_script("arguments[0].value = '';", we_Input)
        we_Input.send_keys(searchstring)
        time.sleep(1)

    def wait_for_policy(self, region=None, developer_org_name=None, policy_name=None, min_nodes=None, max_nodes=None,  wait=3):
        logging.info(f'wait_for_app region={region} developer_org_name={developer_org_name} policy_name={policy_name} min_nodes={min_nodes} max_nodes={max_nodes}')

        for attempt in range(wait):
            if self.is_policy_present(region=region, developer_org_name=developer_org_name, policy_name=policy_name, min_nodes=min_nodes, max_nodes=max_nodes):
                return True
            else:
                time.sleep(1)

        logging.info(f'wait_for_policy timedout region={region} developer_org_name={developer_org_name} policy_name={policy_name} wait={wait}')
        return False

    def is_action_button_present(self, row):
        row.find_element(*AutoScalePolicyPageLocators.table_action)
        return True

    def delete_autoscalepolicy(self, region=None, developer_org_name=None, policy_name=None):
        logging.info(f'deleting Auto Scale Policy policy_name={policy_name}')

        self.perform_search(policy_name)
        row = self.get_table_row_by_value([(policy_name, 4)])
        print('*WARN*', 'row = ', row)
        e = row.find_element(*ComputePageLocators.table_action)
        ActionChains(self.driver).click(on_element=e).perform()
        self.driver.find_element(*ComputePageLocators.table_delete).click()

        time.sleep(1)
        row.find_element(*DeleteConfirmationPageLocators.yes_button).click()

