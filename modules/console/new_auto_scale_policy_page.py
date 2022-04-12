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

from console.base_page import BasePage, BasePageElement, BasePagePulldownElement, BasePagePulldownMultiElement
from console.locators import NewPageLocators, AppsPageLocators, AutoScalePolicyPageLocators, ComputePageLocators
from console.new_settings_full_page import NewSettingsFullPage
from selenium.webdriver.common.action_chains import ActionChains
import console.compute_page
import mex_controller_classes
import time

import logging


class RegionElement(BasePagePulldownMultiElement):
    locator = AppsPageLocators.apps_region_pulldown
    locator2 = AppsPageLocators.apps_region_pulldown_options

class DeveloperNameElement(BasePagePulldownElement):
    locator = AutoScalePolicyPageLocators.orgname_pulldown

class PolicyNameElement(BasePageElement):
    locator = AutoScalePolicyPageLocators.autoscalepolicy_name_input

class MinNodesElement(BasePageElement):
    locator = AutoScalePolicyPageLocators.minnodes_input

class MaxNodesElement(BasePageElement):
    locator = AutoScalePolicyPageLocators.maxnodes_input

class ScaleDownElement(BasePageElement):
    locator = AutoScalePolicyPageLocators.scaledown_input

class ScaleUpElement(BasePageElement):
    locator = AutoScalePolicyPageLocators.scaleup_input

class TriggerTimeElement(BasePageElement):
    locator = AutoScalePolicyPageLocators.triggertime_input

class StabilizationWindowElement(BasePageElement):
    locator = AutoScalePolicyPageLocators.stabilizationWindow_input

class TargetCPUElement(BasePageElement):
    locator = AutoScalePolicyPageLocators.targetCPU_input

class TargetMemoryElement(BasePageElement):
    locator = AutoScalePolicyPageLocators.targetMemory_input

class TargetActiveConnectionElement(BasePageElement):
    locator = AutoScalePolicyPageLocators.targetActiveConnections_input

class NewAutoScalePolicyPage(NewSettingsFullPage):
    region = RegionElement()
    developer_org_name = DeveloperNameElement()
    policy_name = PolicyNameElement()
    min_nodes = MinNodesElement()
    max_nodes = MaxNodesElement()
    scaledown_value = ScaleDownElement()
    scaleup_value = ScaleUpElement()
    stabilizationwindow = StabilizationWindowElement()
    targetCPU = TargetCPUElement()
    targetMemory = TargetMemoryElement()
    activeaconnections = TargetActiveConnectionElement()

    def is_region_label_present(self):
        return self.is_element_present(AutoScalePolicyPageLocators.region_label)

    def is_region_input_present(self):
        return self.is_element_present(AutoScalePolicyPageLocators.region_input)

    def is_organization_label_present(self):
        return self.is_element_present(AutoScalePolicyPageLocators.orgname_label)

    def is_organization_input_present(self):
        return self.is_element_present(AutoScalePolicyPageLocators.orgname_input)

    def is_policyname_label_present(self):
        return self.is_element_present(AutoScalePolicyPageLocators.autoscalepolicy_name_label)

    def is_policyname_input_present(self):
        return self.is_element_present(AutoScalePolicyPageLocators.autoscalepolicy_name_input)

    def is_minnodes_label_present(self):
        return self.is_element_present(AutoScalePolicyPageLocators.minnodes_label)

    def is_minnodes_input_present(self):
        return self.is_element_present(AutoScalePolicyPageLocators.minnodes_input)

    def is_maxnodes_label_present(self):
        return self.is_element_present(AutoScalePolicyPageLocators.maxnodes_label)

    def is_maxnodes_input_present(self):
        return self.is_element_present(AutoScalePolicyPageLocators.maxnodes_input)
   
    def is_scaledown_label_present(self):
        return self.is_element_present(AutoScalePolicyPageLocators.scaledown_label)
 
    def is_scaledown_input_present(self):
        return self.is_element_present(AutoScalePolicyPageLocators.scaledown_input)
 
    def is_scaleup_label_present(self):
        return self.is_element_present(AutoScalePolicyPageLocators.scaleup_label)

    def is_scaleup_input_present(self):
        return self.is_element_present(AutoScalePolicyPageLocators.scaleup_input)

    def is_stabilizationWindow_label_present(self):
        return self.is_element_present(AutoScalePolicyPageLocators.stabilizationWindow_label)

    def is_stabilizationWindow_input_present(self):
        return self.is_element_present(AutoScalePolicyPageLocators.stabilizationWindow_input)

    def is_targetCPU_label_present(self):
        return self.is_element_present(AutoScalePolicyPageLocators.targetCPU_label)

    def is_targetCPU_input_present(self):
        return self.is_element_present(AutoScalePolicyPageLocators.targetCPU_input)

    def is_targetMemory_label_present(self):
        return self.is_element_present(AutoScalePolicyPageLocators.targetMemory_label)

    def is_targetMemory_input_present(self):
        return self.is_element_present(AutoScalePolicyPageLocators.targetMemory_input)

    def is_targetActiveConnections_label_present(self):
        return self.is_element_present(AutoScalePolicyPageLocators.targetActiveConnections_label)

    def is_targetActiveConnections_input_present(self):
        return self.is_element_present(AutoScalePolicyPageLocators.targetActiveConnections_input)

    def are_elements_present(self):
        settings_present = True

        if self.is_region_label_present() and self.is_region_input_present():
            logging.info('Region present')
        else:
            logging.error('Region not present')
            settings_present = False

        if self.is_organization_label_present() and self.is_organization_input_present():
            logging.info('OrgName present')
        else:
            logging.error('OrgName not present')
            settings_present = False

        if self.is_policyname_label_present() and self.is_policyname_input_present():
            logging.info('Auto Scale Policy Name present')
        else:
            logging.error('Auto Scale Policy Name  not present')
            settings_present = False

        if self.is_minnodes_label_present() and self.is_minnodes_input_present():
            logging.info('Minimum Nodes present')
        else:
            logging.error('Minimum Nodes not present')
            settings_present = False

        if self.is_maxnodes_label_present() and self.is_maxnodes_input_present():
            logging.info('Maximum Nodes present')
        else:
            logging.error('Maximum Nodes not present')
            settings_present = False

        if self.is_targetCPU_label_present() and self.is_targetCPU_input_present():
            logging.info('Target CPU present')
        else:
            logging.error('Target CPU not present')
            settings_present = False

        if self.is_targetMemory_label_present() and self.is_targetMemory_input_present():
            logging.info('Target Memory present')
        else:
            logging.error('Target Memory not present')
            settings_present = False

        if self.is_stabilizationWindow_label_present() and self.is_stabilizationWindow_input_present():
            logging.info('Stabilization Window present')
        else:
            logging.error('Stabilization Window not present')
            settings_present = False
    
        return settings_present

    def click_create_policy(self):
        e = self.driver.find_element(*AutoScalePolicyPageLocators.create_button)
        ActionChains(self.driver).click(on_element=e).perform()

    def click_update_policy(self):
        e = self.driver.find_element(*AutoScalePolicyPageLocators.update_button)
        ActionChains(self.driver).click(on_element=e).perform()

    def create_policy(self, region=None, developer_org_name=None, policy_name=None, min_nodes=None, max_nodes=None, scale_down_threshold=None, scale_up_threshold=None,
                      stabilization_window=None, targetCPU=None, targetMemory=None, targetActiveConnectiobs=None):
        logging.info('creating policy')

        self.region = region
        time.sleep(1)
        self.developer_org_name = developer_org_name
        time.sleep(1)
        self.policy_name = policy_name
        time.sleep(1)
        self.min_nodes = min_nodes
        time.sleep(1)
        self.max_nodes = max_nodes
        time.sleep(1)
        self.stabilizationwindow = stabilization_window
        time.sleep(1)
        if targetCPU is not None:
            self.targetCPU = targetCPU
            time.sleep(1)
        if targetMemory is not None:
            self.targetMemory = targetMemory
            time.sleep(1)
        if targetActiveConnectiobs is not None:
            self.activeaconnections = targetActiveConnectiobs
            time.sleep(1)

        self.click_create_policy()
        return True

    def update_policy(self, policy_name=None, min_nodes=None, max_nodes=None, scale_down_threshold=None, scale_up_threshold=None, trigger_time=None):
        logging.info(f'Updating auto scale policy policy_name={policy_name}')

        totals_rows = self.driver.find_elements(*ComputePageLocators.details_row)
        total_rows_length = len(totals_rows)
        total_rows_length += 1
        for row in range(1, total_rows_length):
            table_column =  f'//tbody/tr[{row}]/td[4]/div'
            value = self.driver.find_element_by_xpath(table_column).text
            if value == policy_name:
                i = row
                break

        table_action = f'//tbody/tr[{i}]/td[7]//button[@aria-label="Action"]'
        e = self.driver.find_element_by_xpath(table_action)
        ActionChains(self.driver).click(on_element=e).perform()
        self.driver.find_element(*ComputePageLocators.table_update).click()
        time.sleep(5)

        if min_nodes is not None:
            self.min_nodes = min_nodes
   
        if max_nodes is not None:
            self.max_nodes = max_nodes

        if scale_down_threshold is not None:
            self.scaledown_value = scale_down_threshold

        if scale_up_threshold is not None:
            self.scaleup_value = scale_up_threshold

        if trigger_time is not None:
            self.trigger_time = trigger_time
     
        time.sleep(2)
        self.click_update_policy()
        return True
 
