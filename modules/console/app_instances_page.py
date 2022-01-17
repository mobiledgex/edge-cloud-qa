from console.compute_page import ComputePage
from console.locators import AppInstancesPageLocators, ComputePageLocators, DeleteConfirmationPageLocators
from selenium.webdriver.common.action_chains import ActionChains
import logging
import time

class AppInstancesPage(ComputePage):
    def is_delete_button_present(self, row):
        row.find_element(*AppInstancesPageLocators.table_delete)
        return True
        #if self.is_element_present(AppsPageLocators.table_delete):
        #    logging.info('delete button present')
        #    return True
        #else:
        #    logging.error('delete button NOT present')
        #    return False
        
    def is_app_instances_table_header_present(self):
        header_present = True
        
        if self.is_element_present(AppInstancesPageLocators.app_instances_table_header_region):
            logging.info('region header present')
        else:
            logging.error('region header NOT present')
            header_present = False

        if self.is_element_present(AppInstancesPageLocators.app_instances_table_header_orgname):
            logging.info('orgname header present')
        else:
            logging.error('orgname header NOT present')
            header_present = False
            
        if self.is_element_present(AppInstancesPageLocators.app_instances_table_header_appname):
            logging.info('appname with version header present')
        else:
            logging.error('appname with version header NOT present')
            header_present = False

        if self.is_element_present(AppInstancesPageLocators.app_instances_table_header_operator_cloudlet):
            logging.info('operator[Cloudlet] header present')
        else:
            logging.error('operator[Cloudlet] header NOT present')
            header_present = False

        if self.is_element_present(AppInstancesPageLocators.app_instances_table_header_cluster):
            logging.info('cluster instance header present')
        else:
            logging.error('cluster instance header NOT present')
            header_present = False

        #if self.is_element_present(AppInstancesPageLocators.app_instances_table_header_location):
        #    logging.info('cloudlet location header present')
        #else:
        #    logging.error('cloudlet location header NOT present')
        #    header_present = False

        if self.is_element_present(AppInstancesPageLocators.app_instances_table_header_health_status):
            logging.info('Health Status header present')
        else:
            logging.error('Health Status header NOT present')
            header_present = False

        if self.is_element_present(AppInstancesPageLocators.app_instances_table_header_progress):
            logging.info('progress header present')
        else:
            logging.error('progress header NOT present')
            header_present = False

        if self.is_element_present(AppInstancesPageLocators.app_instances_table_header_actions):
            logging.info('actions header present')
        else:
            logging.error('actions header NOT present')
            header_present = False

        if self.is_element_present(AppInstancesPageLocators.app_instances_table_header_deployment):
            logging.info('Deployment header present')
        else:
            logging.error('Deployment header NOT present')
            header_present = False

        return header_present

    def is_app_instance_present(self, region=None, org_name=None, app_name=None, version=None, operator=None, cloudlet=None, cluster_instance=None, latitude=None, longitude=None, state=None, progress=None,):
        logging.info(f'is_app_instance_present region={region} org_name={org_name} app_name={app_name} version={version} operator={operator} cloudlet={cloudlet} cluster={cluster_instance}')

        rows = self.get_table_rows()
        for r in rows:
            logging.info("Table values  - r[1] = " + r[1] + " r[2] = " + r[2] +
                         " r[3] = " + r[3] + " r[4] = " + r[4] + " r[5] = " + r[5])
            if r[2] == org_name and r[3] == app_name + " [" + version + "]"  and r[4] == cloudlet + " [" + operator + "]"  and r[5] == cluster_instance:
                logging.info('found app instance')
                return True
            else: 
                logging.info('app instance NOT found')          

        return False

    def wait_for_app_instance(self, region=None, org_name=None, app_name=None, version=None, operator=None, cloudlet=None, cluster_instance=None, wait=None):
        logging.info(f'wait_for_app instance region={region} org_name={org_name} app_name={app_name} version={version}  operator={operator} cloudlet={cloudlet} cluster_instance={cluster_instance} wait={wait}')
        for attempt in range(wait):
            if self.is_app_instance_present(region=region, org_name=org_name, app_name=app_name, version=version, operator=operator, cloudlet=cloudlet, cluster_instance=cluster_instance):
                return True
            else:
                time.sleep(1)

        logging.info(f'wait_for_app_instance timedout region={region} org_name={org_name} app_name={app_name} version={version} operator={operator} cloudlet={cloudlet} cluster_instance={cluster_instance} wait={wait}')
        return False

    def perform_search(self, searchstring):
        time.sleep(1)
        logging.info("Clicking Search button and performing search for value on App Instances page - " + searchstring)
        we = self.driver.find_element(*ComputePageLocators.searchbutton)
        ActionChains(self.driver).click(on_element=we).perform()
        time.sleep(1)
        we_Input = self.driver.find_element(*ComputePageLocators.searchInput)
        self.driver.execute_script("arguments[0].value = '';", we_Input)
        we_Input.send_keys(searchstring)
        time.sleep(1)

    def delete_appinst(self, region=None, developer_name=None, app_name=None, app_version=None, operator_name=None, cloudlet_name=None, cluster_instance=None):
        logging.info('deleting app instance')

        if cluster_instance is not None:
            self.perform_search(cluster_instance)
        else:
            self.perform_search(app_name)
        row = self.get_table_row_by_value([(app_name + " [" + app_version + "]", 4), (cloudlet_name + " [" + operator_name + "]", 5)])
        print('*WARN*', 'row = ', row)
        e = row.find_element(*ComputePageLocators.table_action)
        ActionChains(self.driver).click(on_element=e).perform()
        self.driver.find_element(*ComputePageLocators.table_delete).click()

        time.sleep(1)
        row.find_element(*DeleteConfirmationPageLocators.yes_button).click()

        return True

    def appsInst_menu_should_exist(self):
        is_present = ComputePage.is_appsInst_menu_present(self)
        if is_present:
            logging.info('appsInst button is present')
        else:
            raise Exception('appsInst button NOT present')

    def appsInst_menu_should_not_exist(self):
        is_present = ComputePage.is_appsInst_menu_present(self)
        if not is_present:
            logging.info('appsInst button is NOT present')
        else:
            raise Exception('appsInst button IS present')
    
    def appInst_new_button_should_be_enabled(self):
        is_present = ComputePage.is_appInst_new_button_present(self)
        if is_present:
            logging.info('app instances new button IS present')
        else:
            raise Exception('app instances new button is NOT present')

    def appInst_new_button_should_be_disabled(self):
        is_present = ComputePage.is_appInst_new_button_present(self)
        if not is_present:
            logging.info('app instances new button is NOT present')
        else:
            raise Exception('app instances new button IS present')

    def appInst_trash_icon_should_be_enabled(self):
        is_present = ComputePage.is_appInst_trash_icon_present(self)
        if is_present:
            logging.info('app instances trash icon IS present')
        else:
            raise Exception('app instances trash icon is NOT present')

    def appInst_trash_icon_should_be_disabled(self):
        is_present = ComputePage.is_appInst_trash_icon_present(self)
        if not is_present:
            logging.info('app instances trash icon is NOT present')
        else:
            raise Exception('app instances trash icon IS present')
    
    def click_appinst_row(self, app_name, region=None, app_version=None, cluster_name=None, cloudlet_name=None):
        try:
            r = self.get_table_row_by_value([(region, 2), (app_name, 4), (app_version, 5), (cluster_name, 8), (cloudlet_name, 7)])
        except:
            logging.info('row is not found')
            return False
        time.sleep(1)
        ActionChains(self.driver).click(on_element=r).perform()
        return True



    
