from console.base_page import BasePage, BasePageElement
from console.locators import SignupPageLocators

class UserNameElement(BasePageElement):
    locator = SignupPageLocators.username_field

class PasswordElement(BasePageElement):
    locator = SignupPageLocators.password_field

class ConfirmPasswordElement(BasePageElement):
    locator = SignupPageLocators.confimpassword_field

class EmailElement(BasePageElement):
    locator = SignupPageLocators.email_field
    
class SignupPage(BasePage):
    username = UserNameElement()
    password = PasswordElement()
    confirmpassword = ConfirmPasswordElement()
    email = EmailElement()

    def click_signup_button(self):
        element = self.driver.find_element(*SignupPageLocators.signup_button).click()

    def is_login_switch_button_present(self):
        return self.is_element_present(SignupPageLocators.login_switch_button)

    def is_signup_switch_button_present(self):
        return self.is_element_present(SignupPageLocators.signup_switch_button)

    def get_login_switch_button(self):
        return self.driver.find_element(*SignupPageLocators.login_switch_button)

    def get_signup_switch_button(self):
        return self.driver.find_element(*SignupPageLocators.signup_switch_button)

    def is_term_link_present(self):
        return self.is_element_present(SignupPageLocators.terms_link)

    def is_data_policy_link_present(self):
        return self.is_element_present(SignupPageLocators.datapolicy_link)

    def is_cookie_policy_link_present(self):
        return self.is_element_present(SignupPageLocators.cookiesploicy_link)

