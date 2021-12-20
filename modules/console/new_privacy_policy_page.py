from console.base_page import BasePage, BasePageElement, BasePagePulldownElement, BasePagePulldownMultiElement
from console.locators import NewPageLocators, PrivacyPolicyPageLocators, ComputePageLocators
from console.new_settings_full_page import NewSettingsFullPage
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.by import By
import console.compute_page
import mex_controller_classes
import time

import logging

class RegionElement(BasePagePulldownElement):
    locator = NewPageLocators.region_pulldown_option

class DeveloperNameElement(BasePagePulldownElement):
    locator = PrivacyPolicyPageLocators.orgname_pulldown

class PolicyNameElement(BasePageElement):
    locator = PrivacyPolicyPageLocators.trustpolicy_name_input

class ProtocolElement(BasePagePulldownMultiElement):
    locator = PrivacyPolicyPageLocators.protocol_pulldown
    locator2 = PrivacyPolicyPageLocators.protocol_option

class PortRangeMinElement(BasePageElement):
    locator = PrivacyPolicyPageLocators.port_range_min_input

class PortRangeMaxElement(BasePageElement):
    locator = PrivacyPolicyPageLocators.port_range_max_input

class RemoteCidrElement(BasePageElement):
    locator = PrivacyPolicyPageLocators.remote_cidr_input

class RemoteCidrIcmpElement(BasePageElement):
    locator = PrivacyPolicyPageLocators.remote_cidr_icmp_input

class NewPrivacyPolicyPage(NewSettingsFullPage):
    developer_org_name = DeveloperNameElement()
    policy_name = PolicyNameElement()
    protocol = ProtocolElement()
    port_range_min = PortRangeMinElement()
    port_range_max = PortRangeMaxElement()
    remote_cidr = RemoteCidrElement()
    remote_cidr_icmp = RemoteCidrIcmpElement()

    def is_region_label_present(self):
        return self.is_element_present(PrivacyPolicyPageLocators.region_label)

    def is_region_input_present(self):
        return self.is_element_present(PrivacyPolicyPageLocators.region_input)

    def is_organization_label_present(self):
        return self.is_element_present(PrivacyPolicyPageLocators.orgname_label)

    def is_organization_input_present(self):
        return self.is_element_present(PrivacyPolicyPageLocators.orgname_input)

    def is_policyname_label_present(self):
        return self.is_element_present(PrivacyPolicyPageLocators.trustpolicy_name_label)

    def is_policyname_input_present(self):
        return self.is_element_present(PrivacyPolicyPageLocators.trustpolicy_name_input)

    def is_security_rules_header_present(self):
        return self.is_element_present(PrivacyPolicyPageLocators.security_rules_header)

    def is_protocol_label_present(self):
        return self.is_element_present(PrivacyPolicyPageLocators.protocol_label)

    def is_protocol_input_present(self):
        return self.is_element_present(PrivacyPolicyPageLocators.protocol_pulldown)

    def is_port_range_min_label_present(self):
        return self.is_element_present(PrivacyPolicyPageLocators.port_range_min_label)

    def is_port_range_min_input_present(self):
        return self.is_element_present(PrivacyPolicyPageLocators.port_range_min_input)
   
    def is_port_range_max_label_present(self):
        return self.is_element_present(PrivacyPolicyPageLocators.port_range_max_label)
 
    def is_port_range_max_input_present(self):
        return self.is_element_present(PrivacyPolicyPageLocators.port_range_max_input)
 
    def is_remote_cidr_label_present(self):
        return self.is_element_present(PrivacyPolicyPageLocators.remote_cidr_label)

    def is_remote_cidr_input_present(self):
        return self.is_element_present(PrivacyPolicyPageLocators.remote_cidr_input)

    def is_create_policy_button_present(self):
        return self.is_element_present(PrivacyPolicyPageLocators.create_button)

    def is_cancel_button_present(self):
        return self.is_element_present(PrivacyPolicyPageLocators.cancel_button)

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
            logging.info('Privacy Policy Name present')
        else:
            logging.error('Privacy Policy Name not present')
            settings_present = False

        if self.is_security_rules_header_present():
            logging.info('Outbound Security Rules Header present')
        else:
            logging.error('Outbound Security Rules Header not present')
            settings_present = False

        if self.is_protocol_label_present() and self.is_protocol_input_present():
            logging.info('Protocol present')
        else:
            logging.error('Protocol not present')
            settings_present = False

        if self.is_port_range_min_label_present() and self.is_port_range_min_input_present():
            logging.info('Port Range Min present')
        else:
            logging.error('Port Range Min not present')
            settings_present = False

        if self.is_port_range_max_label_present() and self.is_port_range_max_input_present():
            logging.info('Port Range Max present')
        else:
            logging.error('Port Range Max not present')
            settings_present = False

        if self.is_remote_cidr_label_present() and self.is_remote_cidr_input_present():
            logging.info('Remote CIDR present')
        else:
            logging.error('Remote CIDR not present')
            settings_present = False

        if self.is_create_policy_button_present():
            logging.info('Create Policy button present')
        else:
            logging.error('Create Policy button not present')
            settings_present = False

        if self.is_cancel_button_present():
            logging.info('Cancel button present')
        else:
            logging.error('Cancel button not present')
            settings_present = False
    
        return settings_present

    def click_create_policy(self):
        e = self.driver.find_element(*PrivacyPolicyPageLocators.create_button)
        ActionChains(self.driver).click(on_element=e).perform()

    def click_cancel_policy(self):
        e = self.driver.find_element(*PrivacyPolicyPageLocators.cancel_button)
        ActionChains(self.driver).click(on_element=e).perform()

    def click_update_policy(self):
        e = self.driver.find_element(*PrivacyPolicyPageLocators.update_button)
        ActionChains(self.driver).click(on_element=e).perform()

    def create_policy(self, region=None, developer_org_name=None, policy_name=None, rule_list=[], full_isolation=None, mode=None, delete_rule=None):
        logging.info('creating policy')

        self.region = region
        time.sleep(1)
        self.developer_org_name = developer_org_name
        time.sleep(1)
        self.policy_name = policy_name
        time.sleep(1)
        if (len(rule_list) > 1):
            e = self.driver.find_element(*PrivacyPolicyPageLocators.security_rules_button)
            ActionChains(self.driver).click(on_element=e).perform()
        if full_isolation is None:
            for i in range(len(rule_list)):
                k = i + 7
                protocol = rule_list[i]['protocol'].upper()
                protocol_pulldown = (By.XPATH, f'//div[{k}][@id="outboundSecurityRuleMulti"]/div[1]/div[@id="protocol"]//i[@class="dropdown icon"]')
                protocol_option = (By.XPATH, f'.//div[@role="listbox"]//span[text()="{protocol}"]')
                self.driver.find_element(*protocol_pulldown).click()
                time.sleep(1)
                try:
                    self.driver.find_element(*protocol_option).click()
                except:
                    logging.info('Error finding element')
                if rule_list[i]['protocol'] != 'icmp':
                    port_range_min_input = (By.XPATH, f'//div[{k}][@id="outboundSecurityRuleMulti"]/div[2]//input[@type="number"]')
                    port_range_max_input = (By.XPATH, f'//div[{k}][@id="outboundSecurityRuleMulti"]/div[3]//input[@type="number"]')
                    remote_cidr_input = (By.XPATH, f'//div[{k}][@id="outboundSecurityRuleMulti"]/div[4]//input[@type="text"]')
                    self.driver.find_element(*port_range_min_input).send_keys(rule_list[i]['port_range_min'])
                    #self.port_range_min = rule_list[i]['port_range_min']
                    time.sleep(1)
                    self.driver.find_element(*port_range_max_input).send_keys(rule_list[i]['port_range_max'])
                    #self.port_range_max = rule_list[i]['port_range_max']
                    time.sleep(1)
                    self.driver.find_element(*remote_cidr_input).send_keys(rule_list[i]['remote_cidr'])
                    #self.remote_cidr = rule_list[i]['remote_cidr']
                else:
                    remote_cidr_icmp_input = (By.XPATH, f'//div[{k}][@id="outboundSecurityRuleMulti"]/div[2]//input[@type="text"]')
                    self.driver.find_element(*remote_cidr_icmp_input).send_keys(rule_list[i]['remote_cidr'])
                    #self.remote_cidr_icmp = rule_list[i]['remote_cidr']                
        else:
            e = self.driver.find_element(*PrivacyPolicyPageLocators.full_isolation_button)       
            ActionChains(self.driver).click(on_element=e).perform()
        time.sleep(1)
        if delete_rule is not None:
            self.driver.find_element(*PrivacyPolicyPageLocators.delete_rules_button).click()
        if mode is None:
            self.click_create_policy()
        else:
            self.click_cancel_policy() 
        return True

    def click_update_policy(self):
        e = self.driver.find_element(*PrivacyPolicyPageLocators.update_button)
        ActionChains(self.driver).click(on_element=e).perform()

    def update_policy(self, policy_name=None, rule_list=[], delete_rule=None):
        logging.info(f'Updating trust policy policy_name={policy_name}')

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
        self.driver.find_element(*ComputePageLocators.table_update).click()
        time.sleep(5)
        logging.info('updating policy')

        if rule_list:
            if 'protocol' in rule_list[0]:
                self.protocol = rule_list[0]['protocol'].upper()

            if 'port_range_minimum' in rule_list[0]:
                self.port_range_min = rule_list[0]['port_range_minimum']
      
            if 'port_range_maximum' in rule_list[0]:
                self.port_range_max = rule_list[0]['port_range_maximum']

            if 'remote_cidr' in rule_list[0]:
                self.remote_cidr = rule_list[0]['remote_cidr']

            if 'full_isolation' in rule_list[0]:
                e = self.driver.find_element(*PrivacyPolicyPageLocators.full_isolation_button)
                ActionChains(self.driver).click(on_element=e).perform()
 
        if delete_rule is not None:
            self.driver.find_element(*PrivacyPolicyPageLocators.delete_rules_button).click()
 
        time.sleep(2)
        self.click_update_policy()
        return True
