from console.base_page import BasePage
from console.locators import MainPageLocators

import logging

class MainPage(BasePage):
    def click_compute_button(self):
        element = self.driver.find_element(*MainPageLocators.compute_button).click()
    
    def click_logout_button(self):
        element = self.driver.find_element(*MainPageLocators.avatar).click()
        element = self.driver.find_element(*MainPageLocators.logout_button).click()

    def is_compute_button_present(self):
        return self.is_element_present(MainPageLocators.compute_button)
        
    def is_monitoring_button_present(self):
        return self.is_element_present(MainPageLocators.monitoring_button)

    def is_avatar_present(self):
        return self.is_element_present(MainPageLocators.avatar)

    def is_username_present(self, username):
        return self.is_element_present(MainPageLocators.username, text=username)

    def are_elements_present(self, username):
        elements_present = True

        if self.is_compute_button_present():
            logging.info('Compute button present')
        else:
            elements_present = False
        #if main_page.is_monitoring_button_present():
        #    logging.info('Monitoring button present')
        #else:
        #    raise Exception('Monitoring button not present')
        if self.is_avatar_present():
            logging.info('Avatar present')
        else:
            elements_present = False
        #if self.is_username_present(username):
        #    logging.info(f'Username {username} present')
        #else:
        #    elements_present = False

        return elements_present

    
