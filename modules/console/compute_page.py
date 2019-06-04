from console.base_page import BasePage
from console.new_settings_page import NewSettingsPage, NewFlavorSettingsPage
from console.locators import ComputePageLocators

import logging

class ComputePage(BasePage):
    def is_branding_present(self):
        image_present = False
        class_present = self.is_element_present(ComputePageLocators.brand_class)
        if class_present:
            image = self.driver.find_element(*ComputePageLocators.brand_class)
            brand_image = image.value_of_css_property('background-image')
            if '/assets/brand/logo_mex.svg' in brand_image:
                image_present = True

        return image_present

    def is_refresh_icon_present(self):
        return self.is_element_present_in_list(ComputePageLocators.icons_class, 'refresh')

    def is_public_icon_present(self):
        return self.is_element_present_in_list(ComputePageLocators.icons_class, 'public')

    def is_notifications_icon_present(self):
        return self.is_element_present_in_list(ComputePageLocators.icons_class, 'notifications_none')

    def is_add_icon_present(self):
        return self.is_element_present_in_list(ComputePageLocators.icons_class, 'add')

    def is_avatar_present(self):
        return self.is_element_present(ComputePageLocators.avatar)

    def is_support_present(self):
        return self.is_element_present(ComputePageLocators.support)

    def is_username_present(self, username):
        div = self.driver.find_element(*ComputePageLocators.username_div)
        print('*WARN*', 'div', div)

        div_username = div.find_element_by_xpath('./span')
        print('*WARN*', 'username', div_username, div_username.text, username)
        if div_username.text == username:
            return True
        else:
            return False
        #return self.is_element_present(username, text=username)

    def is_table_heading_present(self, label):
        header_present = True

        if self.is_element_present(ComputePageLocators.table_title, label):
            logging.info('heading title present')
        else:
            header_present = False

        if self.is_element_present(ComputePageLocators.table_new_button):
            logging.info('new button present')
        else:
            header_present = False

        if self.is_element_present(ComputePageLocators.table_region_label):
            logging.info('region label present')
        else:
            header_present = False

        if self.is_element_present(ComputePageLocators.table_region_pulldown):
            logging.info('region pulldown label present')
        else:
            header_present = False


        return header_present


    def get_table_rows(self):
        table = self.driver.find_element(*ComputePageLocators.table_data)

        row_list = []
        cell_data = []

        for row in table.find_elements_by_css_selector('tr'):
            cell_data = []
            for cell in row.find_elements_by_css_selector('td'):
                cell_data.append(cell.text)
            row_list.append(list(cell_data))

        return row_list

    def click_new_button(self):
        self.driver.find_element(*ComputePageLocators.table_new_button).click()

    def click_region_pulldown(self):
        self.driver.find_element(*ComputePageLocators.table_region_pulldown).click()

    def click_region_pulldown_option(self, option):
        self.driver.find_element(*ComputePageLocators.table_region_pulldown_option_us).click()

    def click_flavors(self):
        self.driver.find_element(*ComputePageLocators.flavors_button).click()

    def click_cloudlets(self):
        self.driver.find_element(*ComputePageLocators.cloudlets_button).click()

    def click_cluster_instances(self):
        self.driver.find_element(*ComputePageLocators.cluster_instances_button).click()

    def click_apps(self):
        self.driver.find_element(*ComputePageLocators.apps_button).click()

    def click_app_instances(self):
        self.driver.find_element(*ComputePageLocators.app_instances_button).click()
