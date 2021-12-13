from console.base_page import BasePage, BasePageElement, BasePagePulldownElement, BasePagePulldownMultiElement
from console.locators import NewPageLocators, AutoScalePolicyPageLocators, ComputePageLocators
from console.new_settings_full_page import NewSettingsFullPage
from selenium.webdriver.common.action_chains import ActionChains
import console.compute_page
import mex_controller_classes
import time

import logging

class RegionElement(BasePagePulldownElement):
    locator = NewPageLocators.region_pulldown_option

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

class NewAutoScalePolicyPage(NewSettingsFullPage):
    developer_org_name = DeveloperNameElement()
    policy_name = PolicyNameElement()
    min_nodes = MinNodesElement()
    max_nodes = MaxNodesElement()
    scaledown_value = ScaleDownElement()
    scaleup_value = ScaleUpElement()
    trigger_time = TriggerTimeElement()

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

    def is_triggertime_label_present(self):
        return self.is_element_present(AutoScalePolicyPageLocators.triggertime_label)

    def is_triggertime_input_present(self):
        return self.is_element_present(AutoScalePolicyPageLocators.triggertime_input)

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

        if self.is_scaledown_label_present() and self.is_scaledown_input_present():
            logging.info('Scale Down CPU Threshold present')
        else:
            logging.error('Scale Down CPU Threshold not present')
            settings_present = False

        if self.is_scaleup_label_present() and self.is_scaleup_input_present():
            logging.info('Scale Up CPU Threshold present')
        else:
            logging.error('Scale Up CPU Threshold not present')
            settings_present = False

        if self.is_triggertime_label_present() and self.is_triggertime_input_present():
            logging.info('Trigger Time present')
        else:
            logging.error('Trigger Time  not present')
            settings_present = False
    
        return settings_present

    def click_create_policy(self):
        e = self.driver.find_element(*AutoScalePolicyPageLocators.create_button)
        ActionChains(self.driver).click(on_element=e).perform()

    def click_update_policy(self):
        e = self.driver.find_element(*AutoScalePolicyPageLocators.update_button)
        ActionChains(self.driver).click(on_element=e).perform()

    def create_policy(self, region=None, developer_org_name=None, policy_name=None, min_nodes=None, max_nodes=None, scale_down_threshold=None, scale_up_threshold=None, trigger_time=None):
        logging.info('creating app')

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
        self.scaledown_value = scale_down_threshold
        time.sleep(1)
        self.scaleup_value = scale_up_threshold
        time.sleep(1)
        self.trigger_time = trigger_time
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
 
