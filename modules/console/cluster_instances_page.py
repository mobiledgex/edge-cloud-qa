from console.compute_page import ComputePage
from console.locators import ClusterInstancesPageLocators
from console.locators import ComputePageLocators
from console.locators import DeleteConfirmationPageLocators

import logging
import time

class ClusterInstancesPage(ComputePage):
    def is_delete_button_present(self, row):
        row.find_element(*ClusterInstancesPageLocators.table_delete)
        return True
        #if self.is_element_present(AppsPageLocators.table_delete):
        #    logging.info('delete button present')
        #    return True
        #else:
        #    logging.error('delete button NOT present')
        #    return False

    def is_action_button_present(self, row):
        row.find_element(*ClusterInstancesPageLocators.table_action)
        return True

    def is_cluster_instances_table_header_present(self):
        header_present = True
        
        if self.is_element_present(ClusterInstancesPageLocators.cluster_instances_table_header_region):
            logging.info('region header present')
        else:
            logging.error('region header NOT present')
            header_present = False

        if self.is_element_present(ClusterInstancesPageLocators.cluster_instances_table_header_orgname):
            logging.info('orgname header present')
        else:
            logging.error('orgname header NOT present')
            header_present = False
            
        if self.is_element_present(ClusterInstancesPageLocators.cluster_instances_table_header_clustername):
            logging.info('clustername header present')
        else:
            logging.error('clustename header NOT present')
            header_present = False

        if self.is_element_present(ClusterInstancesPageLocators.cluster_instances_table_header_operator):
            logging.info('operator header present')
        else:
            logging.error('operator header NOT present')
            header_present = False

        if self.is_element_present(ClusterInstancesPageLocators.cluster_instances_table_header_flavor):
            logging.info('flavor header present')
        else:
            logging.error('flavor header NOT present')
            header_present = False

        if self.is_element_present(ClusterInstancesPageLocators.cluster_instances_table_header_cloudlet):
            logging.info('cloudlet header present')
        else:
            logging.error('cloudlet header NOT present')
            header_present = False

        if self.is_element_present(ClusterInstancesPageLocators.cluster_instances_table_header_ipaccess):
            logging.info('ipaccess header present')
        else:
            logging.error('ipaccess header NOT present')
            header_present = False

        #if self.is_element_present(ClusterInstancesPageLocators.cluster_instances_table_header_location):
        #    logging.info('cloudlet location header present')
        #else:
        #    logging.error('cloudlet location header NOT present')
        #    header_present = False

        #if self.is_element_present(ClusterInstancesPageLocators.cluster_instances_table_header_state):
        #    logging.info('state header present')
        #else:
        #    logging.error('state header NOT present')
        #    header_present = False

        if self.is_element_present(ClusterInstancesPageLocators.cluster_instances_table_header_progress):
            logging.info('progress header present')
        else:
            logging.error('progress header NOT present')
            header_present = False

        if self.is_element_present(ClusterInstancesPageLocators.cluster_instances_table_header_edit):
            logging.info('edit header present')
        else:
            logging.error('edit header NOT present')
            header_present = False

        return header_present

    def is_cluster_instance_present(self,region=None, cluster_name=None, developer_name=None, operator_name=None, cloudlet_name=None, flavor_name=None, ip_access=None, wait=None):
        logging.info(f'is_cluster_instance_present region={region}  cluster_name={cluster_name}  developer_name={developer_name}  operator_name={operator_name}  cloudlet_name={cloudlet_name}  ip_access={ip_access}  flavor_name={flavor_name}')
        #self.take_screenshot('is_app_present_pre.png')

        rows = self.get_table_rows()
        for r in rows:
            #location = f'Latitude : {latitude}\nLongitude : {longitude}'
            if r[0] == region and r[1] == cluster_name and r[2] == developer_name and r[3] == operator_name and r[4] == cloudlet_name and r[5] == flavor_name and self.is_action_button_present(r[-1]):
                logging.info('found cluster instance')
                return True
            else: 
                logging.info('cluster instance NOT found')

        return False
        
    def is_cluster_instance_progress_done(self,region=None, cluster_name=None, developer_name=None, operator_name=None, cloudlet_name=None, flavor_name=None, ip_access=None):
        logging.info(f'is_cluster_instance_progress_done region={region}  cluster_name={cluster_name}  developer_name={developer_name}  operator_name={operator_name}  cloudlet_name={cloudlet_name}  ip_access={ip_access}  flavor_name={flavor_name}')

        rows = self.get_table_rows()
        for r in rows:
            #location = f'Latitude : {latitude}\nLongitude : {longitude}'
            if r[0] == region and r[1] == cluster_name and r[2] == developer_name and r[3] == operator_name and r[4] == cloudlet_name and r[5] == flavor_name and self.is_delete_button_present(r[-1]):
                logging.info('found cluster instance')
                return True
            else: 
                logging.info('cluster instance NOT found')

        return False


    def wait_for_cluster_instance(self, region=None, cluster_name=None, developer_name=None, operator_name=None, cloudlet_name=None, ip_access=None, flavor_name=None, wait=5):
        logging.info(f'wait_for_cluster_instance region={region}  cluster_name={cluster_name}  operator_name={operator_name}  cloudlet_name={cloudlet_name}  ip_access={ip_access}  flavor_name={flavor_name}')
        for attempt in range(wait):
            if self.is_cluster_instance_present(region=region, cluster_name=cluster_name, developer_name=developer_name, operator_name=operator_name, cloudlet_name=cloudlet_name, ip_access=ip_access, flavor_name=flavor_name):
                return True
            else:
                time.sleep(1)

        logging.error(f'wait_for_app_instance timedout region={region} org_name={org_name} app_name={app_name} version={version} operator={operator} cloudlet={cloudlet} cluster_instance={cluster_instance} wait={wait}')
        return False

    def delete_cluster(self, cluster_name=None, operator_name=None, developer_name=None):
        logging.info(f'deleting cluster cluster_name={cluster_name} operator_name={operator_name} developer_name={developer_name}')
        row = self.get_table_row_by_value([(cluster_name, 2), (developer_name, 3), (operator_name, 4)])
        #row = self.get_table_row_by_value([(region, 1)])
        print('*WARN*', row)
        row.find_element(*ComputePageLocators.trash_button).click()
        
        time.sleep(1)
        row.find_element(*DeleteConfirmationPageLocators.yes_button).click()

    def click_cluster_name_heading(self):
        self.driver.find_element(*ClusterInstancesPageLocators.cluster_instances_table_header_clustername).click()
    
    def click_region_heading(self):
        self.driver.find_element(*ClusterInstancesPageLocators.cluster_instances_table_header_region).click()
    
    def click_operator_heading(self):
        self.driver.find_element(*ClusterInstancesPageLocators.cluster_instances_table_header_operator).click()
    
    def click_cluster_row(self, cluster_name, region='US'):
        #print('*WARN*', cluster_name, region)
        r = self.get_table_row_by_value([(region, 1), (cluster_name, 2)])
        time.sleep(5)
        #print('*WARN*', r)
        r.click()
    
    def get_cluster_icon_numbers(self):
        number_clusters = 0
        elements = self.get_all_elements(ClusterInstancesPageLocators.cluster_map_icon)
        for e in elements:
            logging.info(f'found cluster icon {e.text}')
            if len(e.text) > 0:
                number_clusters += int(e.text)
    
        return number_clusters

    def zoom_out_map(self, number_zooms=1):
        logging.info(f'zoomoutmap {number_zooms} times')
        element = self.driver.find_element(*ClusterInstancesPageLocators.cluster_zoom_out_icon)
        for num in range(number_zooms):
            element.click()
    
    def clustersInst_menu_should_exist(self):
        is_present = ComputePage.is_clustersInst_menu_present(self)
        if is_present:
            logging.info('clustersInst button is present')
        else:
            raise Exception('clustersInst button NOT present')

    def clustersInst_menu_should_not_exist(self):
        is_present = ComputePage.is_clustersInst_menu_present(self)
        if not is_present:
            logging.info('clustersInst button is NOT present')
        else:
            raise Exception('clustersInst button IS present')

    def clusterInst_new_button_should_be_enabled(self):
        is_present = ComputePage.is_clusterInst_new_button_present(self)
        if is_present:
            logging.info('cluster instances new button IS present')
        else:
            raise Exception('cluster instances new button is NOT present')

    def clusterInst_new_button_should_be_disabled(self):
        is_present = ComputePage.is_clusterInst_new_button_present(self)
        if not is_present:
            logging.info('cluster instances new button is NOT present')
        else:
            raise Exception('cluster instances new button IS present')

    def clusterInst_trash_icon_should_be_enabled(self):
        is_present = ComputePage.is_clusterInst_trash_icon_present(self)
        if is_present:
            logging.info('cluster instances trash icon IS present')
        else:
            raise Exception('cluster instances trash icon is NOT present')

    def clusterInst_trash_icon_should_be_disabled(self):
        is_present = ComputePage.is_clusterInst_trash_icon_present(self)
        if not is_present:
            logging.info('cluster instances trash icon is NOT present')
        else:
            raise Exception('cluster instances trash icon IS present')
    

    
