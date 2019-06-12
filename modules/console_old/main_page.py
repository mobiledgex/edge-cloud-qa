from console.base_page import BasePage
from console.locators import MainPageLocators

class MainPage(BasePage):
    def click_compute_button(self):
        element = self.driver.find_element(*MainPageLocators.compute_button).click()

    def is_compute_button_present(self):
        return self.is_element_present(MainPageLocators.compute_button)
        
    def is_monitoring_button_present(self):
        return self.is_element_present(MainPageLocators.monitoring_button)

    def is_avatar_present(self):
        return self.is_element_present(MainPageLocators.avatar)

    def is_username_present(self, username):
        return self.is_element_present(MainPageLocators.username, text=username)
        
    
