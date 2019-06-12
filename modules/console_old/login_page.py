from console.base_page import BasePage, BasePageElement
from console.locators import LoginPageLocators
from selenium.webdriver.common.keys import Keys

class UserNameElement(BasePageElement):
    locator = LoginPageLocators.username_field

class PasswordElement(BasePageElement):
    locator = LoginPageLocators.password_field
    
class LoginPage(BasePage):
    username = UserNameElement()
    password = PasswordElement()
    
    def click_login_button(self):
        element = self.driver.find_element(*LoginPageLocators.login_button).click()

    def click_signup_switch_button(self):
        element = self.driver.find_element(*LoginPageLocators.signup_switch_button).click()

    def hit_enter_key(self):
        self.send_keys(LoginPageLocators.password_field, Keys.RETURN)

    def is_login_switch_button_present(self):
        return self.is_element_present(LoginPageLocators.login_switch_button)

    def is_signup_switch_button_present(self):
        return self.is_element_present(LoginPageLocators.signup_switch_button)

    def get_login_switch_button(self):
        return self.driver.find_element(*LoginPageLocators.login_switch_button)

    def get_signup_switch_button(self):
        return self.driver.find_element(*LoginPageLocators.signup_switch_button)

    def click_forgot_password_link(self):
        element = self.driver.find_element(*LoginPageLocators.forgot_password_link).click()

    def get_login_validation_text(self):
        return self.driver.find_element(*LoginPageLocators.login_validation).text
