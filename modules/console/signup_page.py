from console.base_page import BasePage, BasePageElement
from console.locators import SignupPageLocators

import logging

class UserNameElement(BasePageElement):
    locator = SignupPageLocators.username_field

class PasswordElement(BasePageElement):
    locator = SignupPageLocators.password_field

class ConfirmPasswordElement(BasePageElement):
    locator = SignupPageLocators.confirm_password_field

class EmailElement(BasePageElement):
    locator = SignupPageLocators.email_field

class SignupPage(BasePage):
    username = UserNameElement()
    password = PasswordElement()
    confirm_password = ConfirmPasswordElement()
    email = EmailElement()

    def click_signup_button(self):
        element = self.driver.find_element(*SignupPageLocators.signup_button).click()

    def is_username_field_present(self):
        return self.is_element_present(SignupPageLocators.username_field)

    def is_password_field_present(self):
        return self.is_element_present(SignupPageLocators.password_field)

    def is_confirm_password_field_present(self):
        return self.is_element_present(SignupPageLocators.confirm_password_field)

    def is_email_field_present(self):
        return self.is_element_present(SignupPageLocators.email_field)

    def is_login_switch_button_present(self):
        return self.is_element_present(SignupPageLocators.login_switch_button)

    def is_signup_switch_button_present(self):
        return self.is_element_present(SignupPageLocators.signup_switch_button)

    def is_signup_button_present(self):
        return self.is_element_present(SignupPageLocators.signup_button)

    def is_title_present(self):
        return self.is_element_present(SignupPageLocators.title)

    def is_term_link_present(self):
        return self.is_element_present(SignupPageLocators.terms_link)

    def is_data_policy_link_present(self):
        return self.is_element_present(SignupPageLocators.datapolicy_link)

    def is_cookie_policy_link_present(self):
        return self.is_element_present(SignupPageLocators.cookiespolicy_link)

    def is_privacy_policy_link_present(self):
        return self.is_element_present(SignupPageLocators.privacypolicy_link)

    def is_agree_text_present(self):
        return self.is_element_present(SignupPageLocators.agree_text)

    def are_elements_present(self):
        elements_present = True

        if self.is_title_present():
            logging.info('title present')
        else:
            elements_present = False

        #if self.is_login_switch_button_present():
        #    logging.info('login switch button present')
        #else:
        #    elements_present = False

        if self.is_username_field_present():
            logging.info('username field present')
        else:
            elements_present = False

        if self.is_password_field_present():
            logging.info('password field present')
        else:
            elements_present = False

        if self.is_confirm_password_field_present():
            logging.info('confirm password field present')
        else:
            elements_present = False

        if self.is_email_field_present():
            logging.info('email field present')
        else:
            elements_present = False

        if self.is_signup_button_present():
            logging.info('signup button present')
        else:
            elements_present = False

        #if self.is_signup_switch_button_present():
        #    logging.info('signup switch button present')
        #else:
        #    elements_present = False

        #if self.is_agree_text_present():
        #    logging.info('agree text present')
        #else:
        #    elements_present = False

        if self.is_term_link_present():
            logging.info('term link present')
        else:
            elements_present = False

        #if self.is_data_policy_link_present():
            #logging.info('data policy link present')
        #else:
           # elements_present = False

        #if self.is_cookie_policy_link_present():
            #logging.info('cookie policy link present')
        #else:
            #elements_present = False

        if self.is_privacy_policy_link_present():
            logging.info('privacy policy link present')
        else:
            elements_present = False

        return elements_present

    def get_login_switch_button(self):
        return self.driver.find_element(*SignupPageLocators.login_switch_button)

    def get_signup_switch_button(self):
        return self.driver.find_element(*SignupPageLocators.signup_switch_button)
