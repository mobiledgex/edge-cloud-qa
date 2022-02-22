import time

from console.base_page import BasePage
from console.locators import ComputePageLocators

import logging

from selenium.webdriver import ActionChains


class ComputePage(BasePage):
    def is_branding_present(self):
        image_present = False
        #class_present = self.is_element_present(ComputePageLocators.brand_class)
        #if class_present:
        #    image = self.driver.find_element(*ComputePageLocators.brand_class)
        #    brand_image = image.value_of_css_property('background-image')
        #    if '/assets/brand/MobiledgeX_Logo_tm_white.svg' in brand_image:
        #        image_present = True
        image_present = self.is_element_present(ComputePageLocators.brand)
        return image_present

    def is_refresh_icon_present(self):
        #return self.is_element_present_in_list(ComputePageLocators.icons_class, 'refresh')
        logging.info('gett refresh')
        return self.is_element_present(ComputePageLocators.refresh_button)

    def is_public_icon_present(self):
        #return self.is_element_present_in_list(ComputePageLocators.icons_class, 'public')
        return self.is_element_present(ComputePageLocators.public_button)

    def is_help_icon_present(self):
        return self.is_element_present(ComputePageLocators.help_button)

    def is_help_icon_present_developer_view(self):
        return self.is_element_present(ComputePageLocators.help_button1)

    def is_notifications_icon_present(self):
        return self.is_element_present_in_list(ComputePageLocators.icons_class, 'notifications_none')

    def is_add_icon_present(self):
        return self.is_element_present_in_list(ComputePageLocators.icons_class, 'add')

    def is_avatar_present(self):
        return self.is_element_present(ComputePageLocators.avatar)

    def is_avatar_present_developer_view(self):
        return self.is_element_present(ComputePageLocators.avatar1)

    def is_support_present(self):
        return self.is_element_present(ComputePageLocators.support)

    def is_username_present(self, username):
        div = self.driver.find_element(*ComputePageLocators.username_div)

        div_username = div.find_element_by_xpath('./span')
        if div_username.text == username:
            return True
        else:
            return False
        #return self.is_element_present(username, text=username)

    def click_developer_org(self):
        logging.info('click Create Organization to Run Apps on Telco Edge')
        self.click_element(ComputePageLocators.select_developer_org)

    def click_operator_org(self):
        logging.info('click Create Organization to Host Telco Edge')
        self.click_element(ComputePageLocators.select_operator_org)

    def is_table_heading_present(self, label):
        header_present = True

        if self.is_element_present(ComputePageLocators.table_title, label):
            logging.info('heading title present')
        else:
            logging.error('heading title NOT present')
            header_present = False

        if label != 'Organizations' and label != 'Accounts' and label != 'Users':
            elems = self.driver.find_elements_by_xpath(ComputePageLocators.menu_labels)
            menu_region_present = False

            for elem in elems:
                val = elem.get_attribute("innerText")

                if val == "Region:":
                    logging.info('Region label is present')
                    menu_region_present = True
                    break

            if menu_region_present == False:
                logging.error('Region label is NOT present')
                header_present = False


            if self.is_element_present(ComputePageLocators.table_region_pulldown):
                logging.info('region pulldown label present')
            else:
                logging.info('region pulldown label NOT present')
                header_present = False

        return header_present

    def are_elements_present(self, username, role=None):
        elements_present = True
        logging.info(f"role =  {role}")

        if self.is_branding_present():
            logging.info('branding present')
        else:
            logging.error('branding NOT present')
            elements_present = False


        if self.is_help_icon_present():
            logging.info('help icon present')
        else:
            logging.error('help icon NOT present')
            elements_present = False

        return elements_present

    def get_table_rows(self):
        row_list = []
        logging.info(" GETTING TABLE ROWS ")
        try:
            table = self.driver.find_element(*ComputePageLocators.table_data)
        except Exception as excep:
            logging.debug(" *** No rows returned possibly ***")
            return row_list

        cell_data = []
        button_enabled = True
        for row in table.find_elements_by_xpath('//div[@role="row"]'):
                row.location_once_scrolled_into_view   # cause row to scroll into view
                cell_data = []
                for cell in row.find_elements_by_xpath('//div[@role="gridcell"]'):
                    ishidden = cell.get_attribute("hidden")
                    if not (ishidden):
                        cellinnerText = cell.get_attribute("innerText")
                        if cellinnerText == '':
                            cell_data.append(cellinnerText)
                        else:
                            cell_data.append(cellinnerText.strip())
                        logging.info('CELL Text - ' + cellinnerText)
                    # if cell.text == '':
                    #     cell_data.append(cell)
                    # else:
                    #     cell_data.append(cell.text.strip())
                    # logging.info('CELL Text - ' +  cell.text)
                cell_data.append(row)
                row_list.append(list(cell_data))
        logging.info('ROW LIST - ', *row_list)

        if len(table.find_elements_by_xpath('//div[@role="row"]')) > 0:
            table.find_elements_by_xpath('//div[@role="row"]')[0].location_once_scrolled_into_view
            
        return row_list

    def get_table_row_by_value(self, row_values):
        print('*WARN*', 'rowvalues', row_values)
        table = self.driver.find_element(*ComputePageLocators.table_data)
    
        row_found = 0
        row_list = []
        cell_data = []

        for row in table.find_elements_by_xpath('//div[@role="row"]'):
            print('*WARN*', 'checking row', row)
            if not row.is_displayed:
                row.location_once_scrolled_into_view   # cause row to scroll into view
                print('*WARN*', 'row not displayed')
            else:
                row.location_once_scrolled_into_view   # cause row to scroll into view
                print('*WARN*', 'row displayed')
                
            for value in row_values:
                text_value = row.find_element_by_xpath(f'//div[@role="gridcell"][{value[1]}]//span').text
                print('*WARN*', 'text_value=', text_value, 'value[0]=',value[0])
                if text_value == value[0]:
                    row_found += 1
                else:
                    row_found = 0
                    break
                print('*WARN*','row_found', row_found)
                if row_found == len(row_values):
                    print('*WARN*','row', value[0])
                    return row
                

        raise Exception('row not found')

    def click_manage(self):
        self.click_element(ComputePageLocators.manage_button)

    def change_rows_per_page(self):
        self.click_rows_per_page_pulldown()
        self.click_rows_per_page_pulldown_option()
                
    def click_new_button(self):
        self.driver.find_element(*ComputePageLocators.table_new_button).click()

    def click_add_button(self):
        logging.info("Clicking ADD button")
        e = self.driver.find_element(*ComputePageLocators.table_add_button)
        ActionChains(self.driver).click(on_element=e).perform()

    def click_rows_per_page_pulldown(self):
        self.driver.find_element(*ComputePageLocators.rows_per_page).click()

    def click_rows_per_page_pulldown_option(self):
        self.driver.find_element(*ComputePageLocators.rows_per_page_75).click()

    def click_region_pulldown(self):
        self.driver.find_element(*ComputePageLocators.table_region_pulldown).click()

    def click_region_pulldown_option(self, option):
        if option.lower() == 'us':
            self.driver.find_element(*ComputePageLocators.table_region_pulldown_option_us).click()
        elif  option.lower() == 'eu':
            self.driver.find_element(*ComputePageLocators.table_region_pulldown_option_eu).click()

    def org_rows_per_page(self):
        self.change_rows_per_page()
 
    def click_organizations(self):
        logging.info('click Organizations')
        #self.driver.find_element(*ComputePageLocators.organizations_button).click()
        self.click_element(ComputePageLocators.organizations_button)

    def click_organization_details(self):
        logging.info('click Organizations details')
        #self.driver.find_element(*ComputePageLocators.organizations_button).click()
        self.click_element(ComputePageLocators.organization_details)

    def click_users(self):
        #self.driver.find_element(*ComputePageLocators.users_button).click()
        self.click_element(ComputePageLocators.users_button)

    def click_accounts(self):
        #self.driver.find_element(*ComputePageLocators.accounts_button).click()
        self.click_element(ComputePageLocators.accounts_button)
        self.change_rows_per_page()
        
    def click_refresh(self):
        logging.info('click Refresh')
        #self.driver.find_element(*ComputePageLocators.refresh_button).click()
        self.click_element(ComputePageLocators.refresh_button)

    def click_i_icon(self):
        logging.info('click i icon')
        #self.driver.find_element(*ComputePageLocators.refresh_button).click()
        self.click_element(ComputePageLocators.i_icon)

    def click_flavors(self):
        logging.info('click Flavors')
        #self.driver.find_element(*ComputePageLocators.flavors_button).click()
        self.click_element(ComputePageLocators.flavors_button)

    def click_networks(self):
        logging.info('click Networks')
        self.click_element(ComputePageLocators.networks_button)

    def click_cloudlets(self):
        logging.info('click Cloudlets')
        #self.driver.find_element(*ComputePageLocators.cloudlets_button).click()
        self.click_element(ComputePageLocators.cloudlets_button)

    def click_cluster_instances(self):
        logging.info('click Cluster Instances')
        #self.driver.find_element(*ComputePageLocators.cluster_instances_button).click()
        self.click_element(ComputePageLocators.cluster_instances_button)

    def click_policies(self):
        logging.info('click Policies')
        self.click_element(ComputePageLocators.policies_button)

    def click_autoscalepolicy(self):
        logging.info('click Auto Scale Policy')
        self.click_element(ComputePageLocators.autoscalepolicy_option)

    def click_trustpolicy(self):
        logging.info('click Trust Policy')
        self.click_element(ComputePageLocators.trustpolicy_option)

    def click_apps(self):
        logging.info('click Apps')
        #self.driver.find_element(*ComputePageLocators.apps_button).click()
        self.click_element(ComputePageLocators.apps_button)

    def click_app_instances(self):
        logging.info('click App Instances')
        #self.driver.find_element(*ComputePageLocators.app_instances_button).click()
        self.click_element(ComputePageLocators.app_instances_button)

    def get_new_button_status(self):
        return self.find_element(ComputePageLocators.new_button).is_enabled()

    def is_organizations_menu_present(self):
        return self.is_element_present(ComputePageLocators.organizations_button)

    def is_organization_new_button_present(self):
        return self.is_element_present(ComputePageLocators.table_new_button)

    def is_new_icon_present(self):
        return self.is_element_present(ComputePageLocators.new_icon)

    def is_organization_add_user_button_present(self):
        return self.is_element_present(ComputePageLocators.add_user_button)

    def is_organization_trash_icon_present(self):
        return self.is_element_present(ComputePageLocators.trash_button)

    def is_users_menu_present(self):
        return self.is_element_present(ComputePageLocators.users_button)

    def is_users_trash_icon_present(self):
        return self.is_element_present(ComputePageLocators.trash_button)
    
    def is_cloudlets_menu_present(self):
        return self.is_element_present(ComputePageLocators.cloudlets_button)

    def is_cloudlet_new_button_present(self):
        return self.is_element_present(ComputePageLocators.table_new_button)

    def is_cloudlet_trash_icon_present(self):
        return self.is_element_present(ComputePageLocators.trash_button)

    def is_flavors_menu_present(self):
        return self.is_element_present(ComputePageLocators.flavors_button)

    def is_flavors_new_button_present(self):
        return self.is_element_present(ComputePageLocators.table_new_button)

    def is_flavors_trash_icon_present(self):
        return self.is_element_present(ComputePageLocators.trash_button)

    def is_clustersInst_menu_present(self):
        return self.is_element_present(ComputePageLocators.cluster_instances_button)

    def is_clusterInst_new_button_present(self):
        return self.is_element_present(ComputePageLocators.table_new_button)

    def is_clusterInst_trash_icon_present(self):
        return self.is_element_present(ComputePageLocators.trash_button)

    def is_apps_menu_present(self):
        return self.is_element_present(ComputePageLocators.apps_button)

    def is_apps_new_button_present(self):
        return self.is_element_present(ComputePageLocators.table_new_button)

    def is_apps_trash_icon_present(self):
        return self.is_element_present(ComputePageLocators.trash_button)

    def is_appsInst_menu_present(self):
        return self.is_element_present(ComputePageLocators.app_instances_button)

    def is_appInst_new_button_present(self):
        return self.is_element_present(ComputePageLocators.table_new_button)

    def is_appInst_trash_icon_present(self):
        return self.is_element_present(ComputePageLocators.trash_button)
