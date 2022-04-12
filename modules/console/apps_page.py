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
from console.locators import AppsPageLocators, ComputePageLocators, DeleteConfirmationPageLocators
from selenium.webdriver import Keys
from selenium.webdriver.common.action_chains import ActionChains
import logging
import time

from selenium.webdriver.remote.webelement import WebElement


class AppsPage(ComputePage):
    def is_delete_button_present(self, row):
        row.find_element(*AppsPageLocators.table_delete)
        return True
        #if self.is_element_present(AppsPageLocators.table_delete):
        #    logging.info('delete button present')
        #    return True
        #else:
        #    logging.error('delete button NOT present')
        #    return False

    def is_launch_button_present(self, row):
        row.find_element(*AppsPageLocators.app_launch)
        return True

        #if self.is_element_present(AppsPageLocators.app_launch):
        #    logging.info('launch button present')
        #    return True
        #else:
        #    logging.error('launch button NOT present')
        #    return False

    def is_apps_table_header_present(self):
        header_present = True

        if self.is_element_present(AppsPageLocators.apps_table_header_region):
            logging.info('region column header present')
        else:
            logging.error('region column header NOT present')
            header_present = False

        if self.is_element_present(AppsPageLocators.apps_table_header_orgname):
            logging.info('orgname column header present')
        else:
            logging.error('orgname column header NOT present')
            header_present = False

        if self.is_element_present(AppsPageLocators.apps_table_header_appname):
            logging.info('appname with version column header present')
        else:
            logging.error('appname with version column header NOT present')
            header_present = False

        if self.is_element_present(AppsPageLocators.apps_table_header_deploymenttype):
            logging.info('deployment column header present')
        else:
            logging.error('deployment column header NOT present')
            header_present = False

        if self.is_element_present(AppsPageLocators.apps_table_header_action):
            logging.info('Actions column header present')
        else:
            logging.error('Actions column header NOT present')
            header_present = False

        #if self.is_element_present(AppsPageLocators.apps_table_header_defaultflavor):
        #    logging.info('defaultflavor header present')
        #else:
        #    logging.error('defaultflavor header NOT present')
        #    header_present = False

        #if self.is_element_present(AppsPageLocators.apps_table_header_ports):
        #    logging.info('ports header present')
        #else:
        #    logging.error('ports header NOT present')
        #    header_present = False

        #if self.is_element_present(AppsPageLocators.apps_table_header_edit):
        #    logging.info('edit header present')
        #else:
        #    logging.error('edit header NOT present')
        #    header_present = False

        return header_present

    def is_app_present(self, region=None, app_name=None, app_version=None, org_name=None, deployment_type=None):
        logging.info(f'is_app_present region={region} org_name={org_name} app_name={app_name} app_version={app_version} deployment_type={deployment_type}')
        self.take_screenshot('is_app_present_pre.png')

        rows = self.get_table_rows()
        for r in rows:
            logging.info("Table values - r1 = " + r[1] + ", r2 = " + r[2] + " ,r3 = " + r[3] + ", r4 = " + r[4])
            if r[1] == region and r[2] == org_name and r[3] == app_name + " [" + app_version + "]" and r[4] == deployment_type:
                logging.info('*** FOUND APP ***')
                return True

        return False

    def perform_search(self, searchstring):
        time.sleep(1)
        logging.info("Clicking Search button and performing search for value - " + searchstring)
        we = self.driver.find_element(*AppsPageLocators.apps_page_searchbutton)
        ActionChains(self.driver).click(on_element=we).perform()
        time.sleep(1)
        we_Input = self.driver.find_element(*AppsPageLocators.apps_page_searchInput)
        self.driver.execute_script("arguments[0].value = '';", we_Input)
        we_Input.send_keys(searchstring)
        #self.driver.find_element(*AppsPageLocators.apps_page_searchInput).send_keys(searchstring)
        time.sleep(1)

    def create_instance(self, region=None, developer_name=None, app_name=None, app_version=None, deployment_type=None):
        logging.info(f'Creating App Instance from Apps page app_name={app_name} app_version={app_version} developer_name={developer_name}')

        self.perform_search(app_name)
        row = self.get_table_row_by_value([(app_name + " [" + app_version + "]", 4)])
        print('*WARN*', 'row = ', row)
        e = row.find_element(*ComputePageLocators.table_action)
        ActionChains(self.driver).click(on_element=e).perform()

        self.driver.find_element(*AppsPageLocators.create_instance).click()
        return True

    def delete_app(self, region=None, developer_name=None, app_name=None, app_version=None, deployment_type=None):
        logging.info(f'deleting app app_name={app_name} app_version={app_version} developer_name={developer_name}')

        self.perform_search(app_name)
        row = self.get_table_row_by_value([(app_name + " [" + app_version + "]", 4)])
        print('*WARN*', 'row = ', row)
        e = row.find_element(*ComputePageLocators.table_action)
        ActionChains(self.driver).click(on_element=e).perform()
        self.driver.find_element(*ComputePageLocators.table_delete).click()

        time.sleep(1)
        row.find_element(*DeleteConfirmationPageLocators.yes_button).click()

    def update_app(self,  app_name=None, access_ports=None, scale_with_cluster=False, auth_public_key=None, envvar=None, official_fqdn=None, android_package=None, configs_kind=None, trusted=False, skip_hc=None, outbound_connections=[], app_version=None,
                   qos_nw_prioritization=None, qos_session_duration=None):
        logging.info(f'Updating app app_name={app_name}')

        self.perform_search(app_name)
        row = self.get_table_row_by_value([(app_name + " [" + app_version + "]", 4)])
        print('*WARN*', 'row = ', row)
        e = row.find_element(*ComputePageLocators.table_action)
        ActionChains(self.driver).click(on_element=e).perform()

        self.driver.find_element(*ComputePageLocators.table_update).click()
        time.sleep(5)
        if scale_with_cluster:
            self.driver.find_element(*AppsPageLocators.apps_advancedsettings_button).click()
            self.driver.find_element(*AppsPageLocators.updateapp_toggle_button).click()
        if auth_public_key is not None:
            self.driver.find_element(*AppsPageLocators.apps_advancedsettings_button).click()
            self.driver.find_element(*AppsPageLocators.apps_publickey_input).send_keys(auth_public_key)
        if official_fqdn is not None:
            self.driver.find_element(*AppsPageLocators.apps_advancedsettings_button).click()
            self.driver.find_element(*AppsPageLocators.apps_officialfqdn_input).send_keys(official_fqdn)
        if envvar is not None:
            self.driver.find_element(*AppsPageLocators.configs_button).click()
            self.driver.find_element(*AppsPageLocators.configs_input).send_keys(envvar)
            self.driver.find_element(*AppsPageLocators.configs_kind_pulldown).click()
            if configs_kind is None:
                self.driver.find_element(*AppsPageLocators.configs_kind_input).click()
        if android_package is not None:
            self.driver.find_element(*AppsPageLocators.apps_advancedsettings_button).click()
            self.driver.find_element(*AppsPageLocators.apps_androidpackage_input).send_keys(android_package)
        if trusted:
            self.driver.find_element(*AppsPageLocators.trusted_app_toggle_button).click()
        if skip_hc is not None:
            self.driver.find_element(*AppsPageLocators.apps_skiphc_button).click()
        if outbound_connections:
            i = len(outbound_connections)
            for j in range(i):
                self.driver.find_element(*AppsPageLocators.outbound_connections_button).click()
                e = self.driver.find_element(*AppsPageLocators.outbound_connections_protocol_pulldown)
                e.location_once_scrolled_into_view
                ActionChains(self.driver).click(on_element=e).perform()
                protocol = outbound_connections[j]['protocol']
                proto = f'.//div[@role="listbox"]//span[text()="{protocol}"]'
                if 'portrangemin' in outbound_connections[j]:
                    portvalue = outbound_connections[j]['portrangemin']
                    self.driver.find_element(*AppsPageLocators.outbound_connections_portrangemin_input).send_keys(
                        portvalue)
                if 'portrangemax' in outbound_connections[j]:
                    portvalue = outbound_connections[j]['portrangemax']
                    self.driver.find_element(*AppsPageLocators.outbound_connections_portrangemax_input).send_keys(
                        portvalue)
                remote_ip = outbound_connections[j]['remote_ip']
                self.driver.find_element(*AppsPageLocators.outbound_connections_remoteip_input).send_keys(remote_ip)

        if qos_nw_prioritization is not None:
            e = self.driver.find_element(*AppsPageLocators.qos_network_prioritization_pulldown)
            e.location_once_scrolled_into_view
            ActionChains(self.driver).click(on_element=e).perform()
            value_to_select = f'.//div[@role="listbox"]//span[text()="{qos_nw_prioritization}"]'
            self.driver.find_element_by_xpath(value_to_select).click()

        if qos_session_duration:
            if 'hour' in qos_session_duration[0]:
                e = self.driver.find_element(*AppsPageLocators.qos_session_duration_hours)
                self.driver.execute_script("arguments[0].value = '';", e)
                e.send_keys(qos_session_duration[0]['hour'])
            if 'min' in qos_session_duration[0]:
                self.driver.find_element(*AppsPageLocators.qos_session_duration_mins).send_keys(qos_session_duration[0]['min'])
            if 'sec' in qos_session_duration[0]:
                self.driver.find_element(*AppsPageLocators.qos_session_duration_seconds).send_keys(qos_session_duration[0]['sec'])

        time.sleep(2)
        self.click_update_app()
        return True

    def click_update_app(self):
        e = self.driver.find_element(*AppsPageLocators.update_button)
        ActionChains(self.driver).click(on_element=e).perform()

    def click_next_page(self):
        e = self.driver.find_element(*AppsPageLocators.next_page_button)
        ActionChains(self.driver).click(on_element=e).perform()

    def click_previous_page(self):
         e = self.driver.find_element(*AppsPageLocators.previous_page_button)
         ActionChains(self.driver).click(on_element=e).perform()

    def wait_for_app(self, region=None, app_name=None, app_version=None, org_name=None, deployment_type=None, number_of_pages=None, click_previous_page=None, wait=3):
        logging.info(f'wait_for_app region={region} org_name={org_name} app_name={app_name} app_version={app_version} deployment_type={deployment_type}')
        self.perform_search(app_name)

        for attempt in range(wait):
            if self.is_app_present(region=region, app_name=app_name, app_version=app_version, org_name=org_name, deployment_type=deployment_type):
                time.sleep(1)
                return True
            else:
                time.sleep(1)

        return False

    def click_app_name_heading(self):
        self.driver.find_element(*AppsPageLocators.apps_table_header_appname).click()

    def click_region_heading(self):
        self.driver.find_element(*AppsPageLocators.apps_table_header_region).click()

    def click_close_app_details(self):
        self.driver.find_element(*AppsPageLocators.close_button).click()

    def click_app_row(self, app_name, region=None, app_version=None, app_org=None):
        try:
            row = self.get_table_row_by_value([(app_name + " [" + app_version + "]", 4)])
            print('*WARN*', 'row = ', row)
            e = row.find_element_by_xpath(f'//span[contains(.,"{app_name}")]')
            e.click()
        except:
            raise Exception('row is not found while trying to click app row or could not click row')

        time.sleep(1)
        return True

    def apps_menu_should_exist(self):
        is_present = ComputePage.is_apps_menu_present(self)
        if is_present:
            logging.info('apps button is present')
        else:
            raise Exception('apps button NOT present')

    def apps_menu_should_not_exist(self):
        is_present = ComputePage.is_apps_menu_present(self)
        if not is_present:
            logging.info('apps button is NOT present')
        else:
            raise Exception('apps button IS present')

    def apps_new_button_should_be_enabled(self):
        is_present = ComputePage.is_apps_new_button_present(self)
        if is_present:
            logging.info('apps new button IS present')
        else:
            raise Exception('apps new button is NOT present')

    def apps_new_button_should_be_disabled(self):
        is_present = ComputePage.is_apps_new_button_present(self)
        if not is_present:
            logging.info('apps new button is NOT present')
        else:
            raise Exception('apps new button IS present')

    def apps_trash_icon_should_be_enabled(self):
        is_present = ComputePage.is_apps_trash_icon_present(self)
        if is_present:
            logging.info('apps trash icon IS present')
        else:
            raise Exception('apps trash icon is NOT present')

    def apps_trash_icon_should_be_disabled(self):
        is_present = ComputePage.is_apps_trash_icon_present(self)
        if not is_present:
            logging.info('apps trash icon is NOT present')
        else:
            raise Exception('apps trash icon IS present')