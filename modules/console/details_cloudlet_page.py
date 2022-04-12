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

from console.base_page import BasePage
from console.locators import CloudletDetailsPageLocators
from console.details_page import DetailsFullPage

import logging

class CloudletDetailsPage(DetailsFullPage):
    def is_cloudlet_header_present(self):
        return self.is_element_present(CloudletDetailsPageLocators.cloudlet_header)

    def is_cloudletname_label_present(self):
        return self.is_element_present(CloudletDetailsPageLocators.cloudletname_label)

    def is_operator_label_present(self):
        return self.is_element_present(CloudletDetailsPageLocators.operator_label)

    def is_cloudletlocation_label_present(self):
        return self.is_element_present(CloudletDetailsPageLocators.cloudletlocation_label)

    def is_ipsupport_label_present(self):
        return self.is_element_present(CloudletDetailsPageLocators.ipsupport_label)

    def is_numdynamicips_label_present(self):
        return self.is_element_present(CloudletDetailsPageLocators.numdynamicips_label)

    def is_cloudletname_value_present(self, cloudlet_name):
        return self.is_element_text_present(CloudletDetailsPageLocators.cloudletname_field, cloudlet_name)

    def are_elements_present(self, cloudlet_name):
        elements_present = True

        #elements_present = super().are_elements_present(name='Cloudlets')
       
        if self.is_cloudlet_header_present():
            logging.info('Cloudlets header present')
        else:
            logging.info('Cloudlets header not present')
            elements_present = False 

        if self.is_cloudletname_label_present() and self.is_cloudletname_value_present(cloudlet_name):
            logging.info('CloudletName present')
        else:
            logging.error('CloudletName NOT present')
            elements_present = False

        if self.is_operator_label_present():
            logging.info('Operarator present')
        else:
            logging.error('Operator NOT present')
            elements_present = False

        if self.is_cloudletlocation_label_present():
            logging.info('cloudlet location present')
        else:
            logging.error('Cloudlet location NOT present')
            elements_present = False

        if self.is_ipsupport_label_present():
            logging.info('ip support present')
        else:
            logging.error('IP support NOT present')
            elements_present = False

        if self.is_numdynamicips_label_present():
            logging.info('number dynamic ips present')
        else:
            logging.error('number dynamic IPs NOT present')
            elements_present = False

        return elements_present
