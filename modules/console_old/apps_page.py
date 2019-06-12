from console.compute_page import ComputePage
from console.locators import AppsPageLocators

import logging
import time

class AppsPage(ComputePage):
    def is_apps_table_header_present(self):
        header_present = True
        
        if self.is_element_present(AppsPageLocators.apps_table_header_region):
            logging.info('region header present')
        else:
            header_present = False

        if self.is_element_present(AppsPageLocators.apps_table_header_orgname):
            logging.info('orgname header present')
        else:
            header_present = False
            
        if self.is_element_present(AppsPageLocators.apps_table_header_appname):
            logging.info('appname header present')
        else:
            header_present = False

        if self.is_element_present(AppsPageLocators.apps_table_header_version):
            logging.info('version header present')
        else:
            header_present = False

        if self.is_element_present(AppsPageLocators.apps_table_header_deploymenttype):
            logging.info('deployment header present')
        else:
            header_present = False

        if self.is_element_present(AppsPageLocators.apps_table_header_defaultflavor):
            logging.info('defaultflavor header present')
        else:
            header_present = False

        if self.is_element_present(AppsPageLocators.apps_table_header_ports):
            logging.info('ports header present')
        else:
            header_present = False

            
        return header_present

    def is_app_present(self, region=None, org_name=None, app_name=None, version=None, deployment_type=None, default_flavor=None, ports=None):
        #self.take_screenshot('is_app_present_pre.png')

        rows = self.get_table_rows()
        for r in rows:
            print('*WARN*', 'app', r, r[2], org_name, app_name, version, deployment_type)
            if r[0] == region and r[1] == org_name and r[2] == app_name and r[3] == version and r[4] == deployment_type and r[5] == default_flavor and r[6] == ports:
                print('*WARN*', 'found app')
                return True

        return False

    def wait_for_app(self, region=None, org_name=None, app_name=None, version=None, deployment_type=None, default_flavor=None, ports=None, wait=5):
        logging.info(f'wait_for_app region={region} org_name={org_name} app_name={app_name} version={version}  deployment_type={deployment_type} default_flavor={default_flavor} ports={ports} wait={wait}')
        for attempt in range(wait):
            if self.is_app_present(region=region, org_name=org_name, app_name=app_name, version=version, deployment_type=deployment_type, default_flavor=default_flavor, ports=ports):
                return True
            else:
                time.sleep(1)

        logging.error(f'wait_for_app timedout region={region} org_name={org_name} app_name={app_name} version={version}  deployment_type={deployment_type} default_flavor={default_flavor} ports={ports} wait={wait}')
        return False

    
