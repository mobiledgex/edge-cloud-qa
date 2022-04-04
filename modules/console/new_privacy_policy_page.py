from console.base_page import BasePage, BasePageElement, BasePagePulldownElement, BasePagePulldownMultiElement
from console.compute_page import ComputePage
from console.locators import NewPageLocators, AppsPageLocators, PrivacyPolicyPageLocators, ComputePageLocators
from console.new_settings_full_page import NewSettingsFullPage
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.by import By
import console.compute_page
import mex_controller_classes
import time

import logging

class RegionElement(BasePagePulldownMultiElement):
    locator = AppsPageLocators.apps_region_pulldown
    locator2 = AppsPageLocators.apps_region_pulldown_options

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
    region = RegionElement()
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

    def is_operator_label_present(self):
        return self.is_element_present(PrivacyPolicyPageLocators.operator_label)

    def is_operator_input_present(self):
        return self.is_element_present(PrivacyPolicyPageLocators.operator_input)

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

        if self.is_operator_label_present() and self.is_operator_input_present():
            logging.info('Operator present')
        else:
            logging.error('Operator not present')
            settings_present = False

        if self.is_policyname_label_present() and self.is_policyname_input_present():
            logging.info('Trust Policy Name present')
        else:
            logging.error('Trust Policy Name not present')
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

        rule_list_count = len(rule_list)
        logging.info('Rules list count = ' + str(rule_list_count))

        if full_isolation is None:
            # Delete existing empty rule list while leaving 1
            while len(self.driver.find_elements(By.XPATH,'//div[@id="outboundSecurityRuleMulti"]//button[@class="MuiButtonBase-root MuiIconButton-root"]')) > 1:
                ele = self.driver.find_element(By.XPATH,'//div[@id="outboundSecurityRuleMulti"]//button[@class="MuiButtonBase-root MuiIconButton-root"]')
                ele.click()
                time.sleep(1)

            for i in range(rule_list_count):
                protocol = rule_list[i]['protocol'].upper()
                protocol_pulldown = f'(//div[@id="protocol"])[{i+1}]'
                protocol_option = f'(//div[@id="protocol"])[{i+1}]//div[@role="listbox"]//span[text()="{protocol}"]'
                self.driver.find_element_by_xpath(protocol_pulldown).click()
                time.sleep(1)
                try:
                    self.driver.find_element_by_xpath(protocol_option).click()
                except Exception as e:
                    logging.info('Error finding element')
                    print(e)

                if rule_list[i]['protocol'] != 'ICMP':
                    port_range_min_input = (By.XPATH,
                    f'(//div[@id="outboundSecurityRuleMulti"])[{i+1}]//p[text()="Port Range Min *"]/../../../div/following-sibling::div//input')
                    port_range_max_input = (By.XPATH,
                    f'(//div[@id="outboundSecurityRuleMulti"])[{i + 1}]//p[text()="Port Range Max *"]/../../../div/following-sibling::div//input')
                    remote_cidr_input = (By.XPATH, f'(//p[text()="Remote CIDR *"]/../../../div/following-sibling::div//input)[{i+1}]')
                    self.driver.find_element(*port_range_min_input).send_keys(rule_list[i]['port_range_min'])
                    time.sleep(1)
                    self.driver.find_element(*port_range_max_input).send_keys(rule_list[i]['port_range_max'])
                    time.sleep(1)
                    self.driver.find_element(*remote_cidr_input).send_keys(rule_list[i]['remote_cidr'])
                else:
                    remote_cidr_icmp_input = (By.XPATH, f'(//p[text()="Remote CIDR *"]/../../../div/following-sibling::div//input)[{i+1}]')
                    e = self.driver.find_element(*remote_cidr_icmp_input)
                    e.clear()
                    e.send_keys(rule_list[i]['remote_cidr'])

                if i < (rule_list_count-1):
                    e = self.driver.find_element(*PrivacyPolicyPageLocators.security_rules_button)
                    ActionChains(self.driver).click(on_element=e).perform()
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

    def update_policy(self, policy_name=None, rule_list=[], delete_rule=None, verify_fields=[]):
        logging.info(f'Updating trust policy policy_name={policy_name}')

        self.compute_page = ComputePage(self.driver)
        row = self.compute_page.get_table_row_by_value([(policy_name, 4)])
        print('*WARN*', 'row = ', row)
        e = row.find_element(*ComputePageLocators.table_action)
        ActionChains(self.driver).click(on_element=e).perform()

        self.driver.find_element(*ComputePageLocators.table_update).click()
        time.sleep(5)

        ### Verify values of fields before updation
        if verify_fields:
            for i in range(len(verify_fields)):
                if 'protocol' in verify_fields[i]:
                    elements = self.driver.find_elements(By.XPATH,'//div[@id="protocol"]')
                    found = False
                    for ele in elements:
                        textvalue = ele.get_attribute("innerText")
                        print(' Textvalue = ', textvalue)
                        if verify_fields[i]['protocol'] in textvalue:
                            found = True
                            break
                    if not found:
                        raise Exception("Expected value not found for Protocol before updation")

                if 'remote_cidr' in verify_fields[i]:
                    elements = self.driver.find_elements(By.XPATH,'//p[text()="Remote CIDR *"]/../../../div/following-sibling::div//input')
                    found = False
                    for ele in elements:
                        textvalue = ele.get_attribute("value")
                        print(' Textvalue = ', textvalue)
                        if verify_fields[i]['remote_cidr'] in textvalue:
                            found = True
                            break
                    if not found:
                        raise Exception("Expected value not found for Remote CIDR before updation")

                if 'port_range_minimum' in verify_fields[i]:
                    elements = self.driver.find_elements(By.XPATH,'//p[text()="Port Range Min *"]/../../../div/following-sibling::div//input')
                    found = False
                    for ele in elements:
                        textvalue = ele.get_attribute("value")
                        print(' Textvalue = ', textvalue)
                        if verify_fields[i]['port_range_minimum'] in textvalue:
                            found = True
                            break
                    if not found:
                        raise Exception("Expected value not found for Port Range Minimum before updation")

                if 'port_range_maximum' in verify_fields[i]:
                    elements = self.driver.find_elements(By.XPATH,'//p[text()="Port Range Max *"]/../../../div/following-sibling::div//input')
                    found = False
                    for ele in elements:
                        textvalue = ele.get_attribute("value")
                        print(' Textvalue = ', textvalue)
                        if verify_fields[i]['port_range_maximum'] in textvalue:
                            found = True
                            break
                    if not found:
                        raise Exception("Expected value not found for Port Range Maximum before updation")

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
