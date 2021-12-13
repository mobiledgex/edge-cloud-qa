from console.base_page import BasePage, BasePageElement, BasePagePulldownElement
from console.locators import NewPageFullLocators
from selenium.webdriver.common.keys import Keys

import logging

class RegionElement(BasePagePulldownElement):
    locator = NewPageFullLocators.region_pulldown

class NewSettingsFullPage(BasePage):
    region = RegionElement()

    def click_cancel_button(self):
        element = self.driver.find_element(*NewPageLocators.cancel_button).click()

    def click_save_button(self):
        element = self.driver.find_element(*NewPageFullLocators.save_button).click()

    def click_create_button(self):
        element = self.driver.find_element(*NewPageFullLocators.create_button).click()

    def is_cancel_button_present(self):
        #self.driver.find_element(*NewPageFullLocators.settings_window)   #.send_keys(Keys.END)
        self.driver.find_element(*NewPageFullLocators.cancel_button).location_once_scrolled_into_view
        return self.is_element_present(NewPageFullLocators.cancel_button)

    def is_save_button_present(self):
        return self.is_element_present(NewPageFullLocators.save_button)

    def is_create_button_present(self):
        return self.is_element_present(NewPageFullLocators.create_button)

    def is_heading_present(self):
        return self.is_element_present(NewPageFullLocators.heading)

    def is_region_label_present(self):
        return self.is_element_present(NewPageFullLocators.region)

    def is_region_pulldown_present(self):
        return self.is_element_present(NewPageFullLocators.region_pulldown, 'Select Region')

    def are_elements_present(self):
        settings_present = True

        #if self.is_heading_present():
        #    logging.info('Settings header present')
        #else:
        #    logging.error('Settings header not present')
        #    settings_present = False

        if self.is_region_label_present() and self.is_region_pulldown_present():
            logging.info('Settings region present')
        else:
            logging.error('Settings region not present')
            settings_present = False

        if self.is_cancel_button_present() and self.is_create_button_present():
            logging.info('Settings Cancel/Create button present')
        else:
            logging.error('Settings Cancel/Create not button present')
            settings_present = False

        return settings_present
