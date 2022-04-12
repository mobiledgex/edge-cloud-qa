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
#from console.details_page import DetailsFullPage
from console.details_page import DetailsPage

import logging

class ClusterDetailsPage(DetailsPage):
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

    def is_nummasters_label_present(self):
        return self.is_element_present(ClusterInstancesPageLocators.clusterinst_nummasters)

    def is_nummasters_input_present(self):
        return self.is_element_present(ClusterInstancesPageLocators.clusterinst_nummasters_input)

    def is_numnodes_label_present(self):
        return self.is_element_present(ClusterInstancesPageLocators.clusterinst_numnodes)

    def is_numnodes_input_present(self):
        return self.is_element_present(ClusterInstancesPageLocators.clusterinst_numnodes_input)

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
