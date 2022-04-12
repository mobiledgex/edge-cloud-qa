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

from console.base_page import BasePage, BasePageElement, BasePagePulldownElement
from console.locators import NewPageLocators, NetworksPageLocators
from console.new_settings_page import NewSettingsPage

import time
import logging

class RegionElement(BasePagePulldownElement):
    locator = NewPageLocators.region_pulldown_option

class NetworkNameElement(BasePageElement):
    locator = NewPageLocators.network_networkname_input

class CloudletNameElement(BasePagePulldownElement):
    locator = NewPageLocators.network_cloudletname_pulldown

class OperatorNameElement(BasePagePulldownElement):
    locator = NewPageLocators.network_operator_pulldown

class ConnectionType(BasePagePulldownElement):
    locator = NewPageLocators.network_connectiontype_pulldown

class DestCIDRElement(BasePageElement):
    locator = NewPageLocators.network_routes_destcidr

class DestHopIPElement(BasePageElement):
    locator = NewPageLocators.network_routes_desthopIP


class NewNetworkPage(NewSettingsPage):
    network_name = NetworkNameElement()
    operator = OperatorNameElement()
    cloudlet = CloudletNameElement()
    connectiontype = ConnectionType()
    destcidr = DestCIDRElement()
    desthopip = DestHopIPElement()

    def is_operator_label_present(self):
        return self.is_element_present(NewPageLocators.network_operator_label_name)

    def is_operator_input_present(self):
        return self.is_element_present(NewPageLocators.network_operator_input)

    def is_cloudlet_label_present(self):
        return self.is_element_present(NewPageLocators.network_cloudlet_label_name)

    def is_cloudlet_input_present(self):
        return self.is_element_present(NewPageLocators.network_cloudletname_pulldown)

    def is_networkname_label_present(self):
        return self.is_element_present(NewPageLocators.network_networkname_label_name)

    def is_networkname_input_present(self):
        return self.is_element_present(NewPageLocators.network_networkname_input)

    def is_connectiontype_label_present(self):
        return self.is_element_present(NewPageLocators.network_connectiontype_label_name)

    def is_connectiontype_input_present(self):
        return self.is_element_present(NewPageLocators.network_connectiontype_pulldown)

    def is_routes_add_presnt(self):
        return self.is_element_present(NewPageLocators.network_routes_add)

    def are_elements_present(self):
        settings_present = True

        settings_present = super().are_elements_present()

        if self.is_operator_label_present() and self.is_operator_input_present():
            logging.info('Operator Name present')
        else:
            logging.error('Operator Name not present')
            settings_present = False

        if self.is_cloudlet_label_present() and self.is_cloudlet_input_present():
            logging.info('Cloudlet Name present')
        else:
            logging.error('Cloudlet Name not present')
            settings_present = False

        if self.is_networkname_label_present() and self.is_networkname_input_present():
            logging.info('Network Name present')
        else:
            logging.error('Network Name not present')
            settings_present = False

        if self.is_connectiontype_label_present() and self.is_connectiontype_input_present():
            logging.info('Connection Type present')
        else:
            logging.error('Connection Type not present')
            settings_present = False

        if self.is_routes_add_presnt():
            logging.info('Routes add present')
        else:
            logging.error('Routes add not present')
            settings_present = False

        return settings_present

    def create_network(self, region=None, network_name=None, operator=None, cloudlet=None, connectiontype=None, route_list=None):
        logging.info('Creating Network')

        self.region = region
        time.sleep(1)
        self.operator = operator
        time.sleep(1)
        self.cloudlet = cloudlet
        time.sleep(1)
        self.network_name = network_name
        self.connectiontype = connectiontype

        if route_list is not None:
            logging.info('Input routes - ' + route_list )
            routes_info = route_list.split(',')
            for i in range(len(routes_info)):
                route_details = routes_info[i].split(':')
                dest_cidr_value = route_details[0]
                dest_hop_ip_value = route_details[1]
                self.driver.find_element(*NewPageLocators.network_routes_add).click()
                self.destcidr = dest_cidr_value
                self.desthopip = dest_hop_ip_value

        time.sleep(3)
        self.take_screenshot('add_new_network.png')
        self.click_save_button()

