from console.base_page import BasePage, BasePageElement, BasePagePulldownElement, BasePagePulldownMultiElement
from console.locators import NewPageFullLocators, NewPageLocators, AppInstancesPageLocators, ComputePageLocators, AppsPageLocators
from console.new_settings_full_page import NewSettingsFullPage
import console.compute_page
from console.compute_page import ComputePage
from selenium.webdriver.common.action_chains import ActionChains
import mex_controller_classes
import time

import logging

from selenium.webdriver.support import expected_conditions
from selenium.webdriver.support.wait import WebDriverWait

class AppNameElement(BasePagePulldownElement):
    locator = AppInstancesPageLocators.appinst_appname_pulldown

class DeveloperNameElement(BasePagePulldownElement):
    locator = AppInstancesPageLocators.appinst_developername_pulldown

class AppVersionElement(BasePagePulldownElement):
    locator = AppInstancesPageLocators.appinst_appversion_pulldown

class OperatorNameElement(BasePagePulldownElement):
    locator = AppInstancesPageLocators.appinst_operator_pulldown

class CloudletNameElement(BasePagePulldownMultiElement):
    locator = AppInstancesPageLocators.appinst_cloudlet_pulldown
    locator2 = AppInstancesPageLocators.appinst_cloudlet_pulldown_options

class ClusterNameElement(BasePagePulldownElement):
    locator = AppInstancesPageLocators.appinst_clusterinst_pulldown

class RegionElement(BasePagePulldownElement):
    locator = AppsPageLocators.apps_region_pulldown
    #locator2 = AppsPageLocators.apps_region_input2

class NewAppInstSettingsPage(NewSettingsFullPage):
    region = RegionElement()
    developer_name = DeveloperNameElement()
    app_name = AppNameElement()
    app_version = AppVersionElement()
    operator_name = OperatorNameElement()
    cloudlet_name = CloudletNameElement()
    cluster_instance = ClusterNameElement()
   

    def is_region_label_present(self):
        return self.is_element_present(AppInstancesPageLocators.appinst_region)

    def is_region_input_present(self):
        return self.is_element_present(AppInstancesPageLocators.appinst_region_pulldown)

    def is_developername_label_present(self):
        return self.is_element_present(AppInstancesPageLocators.appinst_developername)

    def is_developername_input_present(self):
        return self.is_element_present(AppInstancesPageLocators.appinst_developername_pulldown)

    def is_appname_label_present(self):
        return self.is_element_present(AppInstancesPageLocators.appinst_appname)

    def is_appname_input_present(self):
        return self.is_element_present(AppInstancesPageLocators.appinst_appname_pulldown)

    def is_appversion_label_present(self):
        return self.is_element_present(AppInstancesPageLocators.appinst_appversion)

    def is_appversion_input_present(self):
        return self.is_element_present(AppInstancesPageLocators.appinst_appversion_pulldown)

    def is_operator_label_present(self):
        return self.is_element_present(AppInstancesPageLocators.appinst_operator)

    def is_operator_input_present(self):
        return self.is_element_present(AppInstancesPageLocators.appinst_operator_pulldown)
    
    def is_cloudlet_label_present(self):
        return self.is_element_present(AppInstancesPageLocators.appinst_cloudlet)

    def is_cloudlet_input_present(self):
        return self.is_element_present(AppInstancesPageLocators.appinst_cloudlet_pulldown)

    def is_autoclusterinst_label_present(self):
        return self.is_element_present(AppInstancesPageLocators.appinst_autoclusterinst)

    def is_autoclusterinst_input_present(self):
        return self.is_element_present(AppInstancesPageLocators.appinst_autoclusterinst_checkbox)

    def is_clusterinst_label_present(self):
        return self.is_element_present(AppInstancesPageLocators.appinst_clusterinst)

    def is_clusterinst_input_present(self):
        return self.is_element_present(AppInstancesPageLocators.appinst_clusterinst_pulldown_text)

    def is_flavor_label_present(self):
        return self.is_element_present(AppInstancesPageLocators.appinst_flavor)

    def is_flavor_input_present(self):
        return self.is_element_present(AppInstancesPageLocators.appinst_flavor_pulldown)

    def is_app_inst_create_progress_dialog_present(self):
        return self.is_element_present(AppInstancesPageLocators.appinst_create_progress_dialog)

    def verify_app_inst_progress_dialog_text(self):
        try:
            wait = WebDriverWait(self.driver, 50, poll_frequency=1)
            wait.until(expected_conditions.text_to_be_present_in_element((AppInstancesPageLocators.appinst_create_progress_dialog_text),"Created AppInst successfully"))
            dialogtext = self.driver.find_element(*AppInstancesPageLocators.appinst_create_progress_dialog_text).text
            logging.info(f'dialogtext={dialogtext}')
        except Exception as e:
            logging.error("Caught exception - " + e)
            dialogtext = self.driver.find_element(*AppInstancesPageLocators.appinst_create_progress_dialog_text).text
            logging.error(f'Expected text not found={dialogtext}')

    def are_elements_present(self):
        settings_present = True

        if self.is_region_label_present() and self.is_region_input_present():
            logging.info('Region present')
        else:
            logging.error('Region not present')
            settings_present = False

        if self.is_developername_label_present() and self.is_developername_input_present():
            logging.info('OrgName present')
        else:
            logging.error('OrgName not present')
            settings_present = False

        if self.is_appname_label_present() and self.is_appname_input_present():
            logging.info('AppName present')
        else:
            logging.error('AppName not present')
            settings_present = False

        if self.is_appversion_label_present() and self.is_appversion_input_present():
            logging.info('AppVersion present')
        else:
            logging.error('AppVersion not present')
            settings_present = False

        if self.is_operator_label_present() and self.is_operator_input_present():
            logging.info('operator present')
        else:
            logging.error('operator not present')
            settings_present = False

        if self.is_cloudlet_label_present() and self.is_cloudlet_input_present():
            logging.info('cloudlet present')
        else:
            logging.error('cloudlet not present')
            settings_present = False

        if self.is_flavor_label_present() and self.is_flavor_input_present():
            logging.info('Flavor present')
        else:
            logging.error('Flavor not present')
            settings_present = False

        #if self.is_autoclusterinst_label_present() and self.is_autoclusterinst_input_present():
        #    logging.info('auto cluster instance present')
        #else:
        #    logging.error('auto cluster instance not present')
        #    settings_present = False

        #if self.is_clusterinst_label_present() and self.is_clusterinst_input_present():
        #    logging.info('cluster instance present')
        #else:
        #    logging.error('cluster instance not present')
        #    settings_present = False
    
        return settings_present

    def click_create_button(self):
        e = self.driver.find_element(*AppInstancesPageLocators.appinst_create_button)
        ActionChains(self.driver).click(on_element=e).perform()

    def close_alert_box(self):
        self.driver.find_element(*ComputePageLocators.close_button).click()

    def create_appinst(self, region=None, developer_name=None, app_name=None, app_version=None, operator_name=None, cloudlet_name=None, cluster_instance=None, type=None, ip_access=None, envvar=None, created_from='App Instances Page'):
        logging.info('creating app instance')
        if created_from == 'App Instances Page':
            self.region = region
            time.sleep(2)
            self.developer_name = developer_name
            time.sleep(5)
            self.app_name = app_name
            time.sleep(2)
            self.app_version = app_version
            time.sleep(2)
        self.operator_name = operator_name
        time.sleep(2)
        self.cloudlet_name = cloudlet_name
        time.sleep(15)  #After cloudlet is selected, it takes some time to populate Cluster Instances.
        #print('*WARN*','cloudlet_done')
        if cluster_instance is not None:
            self.cluster_instance = cluster_instance
        else:
            self.driver.find_element(*AppInstancesPageLocators.appinst_autoclusterinst_checkbox).click()
            self.driver.find_element(*AppInstancesPageLocators.appinst_ipaccess_pulldown).click()
            access_type = f'.//div[@role="listbox"]//span[text()="{ip_access}"]'
            self.driver.find_element_by_xpath(access_type).click()
        if envvar is not None:
            self.driver.find_element(*AppInstancesPageLocators.configs_button).click()
            self.driver.find_element(*AppsPageLocators.configs_input).send_keys(envvar)
            self.driver.find_element(*AppsPageLocators.configs_kind_pulldown).click()
            self.driver.find_element(*AppInstancesPageLocators.configs_kind_input).click()
    
        self.take_screenshot('add_new_cloudlet_settings.png')
        self.click_create_button()
        self.is_app_inst_create_progress_dialog_present()
        self.verify_app_inst_progress_dialog_text()
        return True
