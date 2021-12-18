from console.base_page import BasePage
from console.details_page import DetailsPage
from console.locators import DetailsPageLocators, AccountsPageLocators

import logging

class AccountsDetailsPage(DetailsPage):
    def is_organization_label_present(self):
        return self.is_element_present(OrganizationDetailsPageLocators.organization_label)

    def is_type_label_present(self):
        return self.is_element_present(OrganizationDetailsPageLocators.type_label)

    def is_phone_label_present(self):
        return self.is_element_present(OrganizationDetailsPageLocators.phone_label)

    def is_address_label_present(self):
        return self.is_element_present(OrganizationDetailsPageLocators.address_label)

    def is_organization_value_present(self, organization):
        return self.is_element_present(OrganizationDetailsPageLocators.organization_field, organization)

    def is_type_value_present(self):
        return self.is_element_present(OrganizationDetailsPageLocators.type_field)

    def is_phone_value_present(self):
        return self.is_element_present(OrganizationDetailsPageLocators.phone_field)

    def is_address_value_present(self):
        return self.is_element_present(OrganizationDetailsPageLocators.address_field)

    def are_account_details_present(self):
        details_present = True
        #table = self.driver.find_element(*AccountsPageLocators.accounts_details_table)

        #for row in table.find_elements_by_css_selector('ui grid'):
        #    print('*WARN*', 'row')
        #    row.location_once_scrolled_into_view   # cause row to scroll into view

        if self.is_element_present(AccountsPageLocators.accounts_details_username):
            logging.info('username info present')
        else:
            logging.error('username info NOT present')
            header_present = False

        if self.is_element_present(AccountsPageLocators.accounts_details_email_verification):
            logging.info('email verified info present')
        else:
            logging.error('email verified info NOT present')
            header_present = False

        if self.is_element_present(AccountsPageLocators.accounts_details_email):
            logging.info('email info present')
        else:
            logging.error('email info NOT present')
            header_present = False

        # HAVE TO SCROLL TO FIND THE ELEMENTS
        #if self.is_element_present(AccountsPageLocators.accounts_details_passhash):
        #    logging.info('Passhash info present')
        #else:
        #    logging.error('Passhash info NOT present')
        #    header_present = False

        #if self.is_element_present(AccountsPageLocators.accounts_details_salt):
        #    logging.info('Salt info present')
        #else:
        #    logging.error('Salt info NOT present')
        #    header_present = False

        #if self.is_element_present(AccountsPageLocators.accounts_details_iter):
        #    logging.info('Iter info present')
        #else:
        #    logging.error('Iter info NOT present')
        #    header_present = False

        #if self.is_element_present(AccountsPageLocators.accounts_details_family_name):
        #    logging.info('Family Name info present')
        #else:
        #    logging.error('Family name info NOT present')
        #    header_present = False

        #if self.is_element_present(AccountsPageLocators.accounts_details_given_name):
        #    logging.info('Given name info present')
        #else:
        #    logging.error('Given Name info NOT present')
        #    header_present = False

        #if self.is_element_present(AccountsPageLocators.accounts_details_picture):
        #    logging.info('Picture info present')
        #else:
        #    logging.error('Picture info NOT present')
        #    header_present = False

        #if self.is_element_present(AccountsPageLocators.accounts_details_nickname):
        #    logging.info('Nickname info present')
        #else:
        #    logging.error('Nickname info NOT present')
        #    header_present = False

        if self.is_element_present(AccountsPageLocators.accounts_details_created_at):
            logging.info('Created info present')
        else:
            logging.error('Created info NOT present')
            header_present = False
            
        if self.is_element_present(AccountsPageLocators.accounts_details_updated_at):
            logging.info('Updated @ info present')
        else:
            logging.error('Updated @ info NOT present')
            header_present = False

        #if self.is_element_present(AccountsPageLocators.accounts_details_locked):
        #    logging.info('Lock info present')
        #else:
        #    logging.error('Lock info NOT present')
        #    header_present = False

        return details_present

#    def get_details(self):
#        details_dict = super().get_details()
#        details_dict['instructions'] = ''
#        
#        for row in self.driver.find_elements(*OrganizationDetailsPageLocators.instructions_text):
#                print("*WARN*", row, row.text, 'okie')
#                details_dict['instructions'] += row.text + '\n'
#
#        return details_dict
