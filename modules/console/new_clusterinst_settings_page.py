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
from console.locators import NewPageFullLocators, NewPageLocators, ClusterInstancesPageLocators
from console.new_settings_full_page import NewSettingsFullPage
import console.compute_page
import time

import logging

from selenium.webdriver import Keys, ActionChains
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions
from selenium.webdriver.support.wait import WebDriverWait


class ClusterNameElement(BasePageElement):
    locator = ClusterInstancesPageLocators.clusterinst_clustername_input

class DeveloperNameElement(BasePagePulldownElement):
    locator = ClusterInstancesPageLocators.clusterinst_developername_pulldownbox

class OperatorNameElement(BasePagePulldownElement):
    locator = ClusterInstancesPageLocators.clusterinst_operatorname_pulldownbox

class CloudletNameElement(BasePagePulldownMultiElement):
    locator = ClusterInstancesPageLocators.clusterinst_cloudletname_pulldown
    locator2 = ClusterInstancesPageLocators.clusterinst_cloudletname_pulldown2

class DeploymentTypeElement(BasePagePulldownElement):
    locator = ClusterInstancesPageLocators.clusterinst_deploymenttype_pulldownbox

class IpAccessElement(BasePagePulldownElement):
    locator = ClusterInstancesPageLocators.clusterinst_ipaccess_pulldownbox

class FlavorNameElement(BasePagePulldownElement):
    locator = ClusterInstancesPageLocators.clusterinst_flavor_pulldownbox

class AutoScalePolicyElement(BasePagePulldownElement):
    locator = ClusterInstancesPageLocators.clusterinst_autoscalepolicy_pulldown

class NetworkElement(BasePagePulldownElement):
    locator = ClusterInstancesPageLocators.clusterinst_network_pulldown

class NewClusterInstSettingsPage(NewSettingsFullPage):
    cluster_name = ClusterNameElement()
    developer_name = DeveloperNameElement()
    operator_name = OperatorNameElement()
    cloudlet_name = CloudletNameElement()
    deployment = DeploymentTypeElement()
    ip_access = IpAccessElement()
    flavor_name = FlavorNameElement()
    autoscalepolicy = AutoScalePolicyElement()
    network = NetworkElement()

    def is_region_label_present(self):
        return self.is_element_present(ClusterInstancesPageLocators.clusterinst_region)

    def is_region_input_present(self):
        return self.is_element_present(ClusterInstancesPageLocators.clusterinst_region_input)
    
    def is_clustername_label_present(self):
        return self.is_element_present(ClusterInstancesPageLocators.clusterinst_clustername)

    def is_clustername_input_present(self):
        return self.is_element_present(ClusterInstancesPageLocators.clusterinst_clustername_input)

    def is_developername_label_present(self):
        return self.is_element_present(ClusterInstancesPageLocators.clusterinst_developername)

    def is_developername_input_present(self):
        return self.is_element_present(ClusterInstancesPageLocators.clusterinst_developername_pulldown)

    def is_operatorname_label_present(self):
        return self.is_element_present(ClusterInstancesPageLocators.clusterinst_operatorname)

    def is_operatorname_input_present(self):
        return self.is_element_present(ClusterInstancesPageLocators.clusterinst_operatorname_pulldown)

    def is_cloudlet_label_present(self):
        return self.is_element_present(ClusterInstancesPageLocators.clusterinst_cloudletname)

    def is_cloudlet_input_present(self):
        return self.is_element_present(ClusterInstancesPageLocators.clusterinst_cloudletname_pulldown)

    def is_deployment_label_present(self):
        return self.is_element_present(ClusterInstancesPageLocators.clusterinst_deploymenttype)

    def is_deployment_input_present(self):
        return self.is_element_present(ClusterInstancesPageLocators.clusterinst_deploymenttype_pulldown)
    
    def is_ipaccess_label_present(self):
        return self.is_element_present(ClusterInstancesPageLocators.clusterinst_ipaccess)

    def is_ipaccess_input_present(self):
        return self.is_element_present(ClusterInstancesPageLocators.clusterinst_ipaccess_pulldown)

    def is_flavor_label_present(self):
        return self.is_element_present(ClusterInstancesPageLocators.clusterinst_flavor)

    def is_flavor_input_present(self):
        return self.is_element_present(ClusterInstancesPageLocators.clusterinst_flavor_pulldown)

    def is_autoscalepolicy_label_present(self):
        return self.is_element_present(ClusterInstancesPageLocators.clusterinst_autoscalepolicy)

    def is_autoscalepolicy_input_present(self):
        return self.is_element_present(ClusterInstancesPageLocators.clusterinst_autoscalepolicy_pulldown)

    def is_network_label_present(self):
        return self.is_element_present(ClusterInstancesPageLocators.clusterinst_network)

    def is_network_input_present(self):
        return self.is_element_present(ClusterInstancesPageLocators.clusterinst_network_pulldown)

    def are_elements_present(self):
        settings_present = True

        #settings_present = super().are_elements_present()

        if self.is_region_label_present() and self.is_region_input_present():
            logging.info('Region present')
        else:
            logging.error('Region not present')
            settings_present = False

        if self.is_clustername_label_present() and self.is_clustername_input_present():
            logging.info('ClusterName present')
        else:
            logging.error('ClusterName not present')
            settings_present = False

        if self.is_developername_label_present() and self.is_developername_input_present():
            logging.info('DeveloperName present')
        else:
            logging.error('DeveloperName not present')
            settings_present = False

        if self.is_operatorname_label_present() and self.is_operatorname_input_present():
            logging.info('OperatorName present')
        else:
            logging.error('OperatorName not present')
            settings_present = False

        if self.is_cloudlet_label_present() and self.is_cloudlet_input_present():
            logging.info('cloudlet present')
        else:
            logging.error('cloudlet not present')
            settings_present = False

        if self.is_deployment_label_present() and self.is_deployment_input_present():
            logging.info('deployment present')
        else:
            logging.error('deployment not present')
            settings_present = False

        if self.is_ipaccess_label_present() and self.is_ipaccess_input_present():
            logging.info('IpAccess present')
        else:
            logging.error('IpAccess not present')
            settings_present = False

        if self.is_flavor_label_present() and self.is_flavor_input_present():
            logging.info('Flavor present')
        else:
            logging.error('Flavor not present')
            settings_present = False

        if self.is_autoscalepolicy_label_present() and self.is_autoscalepolicy_input_present():
            logging.info('Autoscalepolicy present')
        else:
            logging.error('Autoscalepolicy not present')
            settings_present = False

        if self.is_network_label_present() and self.is_network_input_present():
            logging.info('Network present')
        else:
            logging.error('Network not present')
            settings_present = False

        return settings_present

    def are_cluster_details_present(self):
        settings_present = True

        if self.is_element_present(ClusterInstancesPageLocators.clusterinst_details_clustername):
            logging.info('Clustername detail present')
        else:
            settings_present = False

        if self.is_element_present(ClusterInstancesPageLocators.clusterinst_details_developername):
            logging.info('Developer detail present')
        else:
            settings_present = False

        if self.is_element_present(ClusterInstancesPageLocators.clusterinst_details_operatorname):
            logging.info('Operator detail present')
        else:
            settings_present = False

        if self.is_element_present(ClusterInstancesPageLocators.clusterinst_details_cloudletname):
            logging.info('Cloudlet detail present')
        else:
            settings_present = False

        if self.is_element_present(ClusterInstancesPageLocators.clusterinst_details_flavorname):
            logging.info('Flavor detail present')
        else:
            settings_present = False

        if self.is_element_present(ClusterInstancesPageLocators.clusterinst_details_deploymenttype):
            logging.info('Deployment detail present')
        else:
            settings_present = False

        return settings_present

    def create_clusterInst(self, region=None, cluster_name=None, developer_name=None, operator_name=None, cloudlet_name=None, deployment=None, ip_access=None, flavor_name=None, number_nodes=None):
        logging.info('creating clusterInst')

        self.region = region
        time.sleep(2)
        self.cluster_name = cluster_name
        self.developer_name = developer_name
        time.sleep(10)
        self.operator_name = operator_name
        print('*WARN*', cloudlet_name)
        self.cloudlet_name = cloudlet_name
        self.deployment = deployment
        self.ip_access = ip_access
        self.selectFlavor (flavor_name)
        #self.flavor_name = flavor_name

        if deployment == 'Kubernetes':
            self.number_nodes = number_nodes
            #self.number_masters = number_masters
        else: 
            pass

        self.take_screenshot('add_new_cloudlet_settings.png')
        self.click_create_button()

    def selectFlavor(self, flavorname):
        self.driver.find_element(*ClusterInstancesPageLocators.clusterinst_flavor_pulldown).click()
        self.driver.find_element(*ClusterInstancesPageLocators.clusterinst_flavor_input).send_keys(flavorname)
        self.driver.find_element(*ClusterInstancesPageLocators.clusterinst_flavor_input).send_keys(Keys.ENTER)

        wait = WebDriverWait(self.driver, 10, poll_frequency=1)
        flavor_value = f".//button[@class='mex_select_tree_detail' and text()='{flavorname}']"
        wait.until(expected_conditions.visibility_of_element_located((By.XPATH, flavor_value))).click()

    def click_create_button(self):
        e = self.driver.find_element(*NewPageFullLocators.create_button)
        ActionChains(self.driver).click(on_element=e).perform()
