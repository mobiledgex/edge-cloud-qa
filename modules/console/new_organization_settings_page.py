from console.base_page import BasePage, BasePageElement, BasePageRadioElement, BasePagePulldownElement
from console.locators import  NewOrganizationPageLocators, OrganizationsPageLocators

import logging

class OrganizationNameElement(BasePageElement):
    locator = NewOrganizationPageLocators.organization_name_input

class AddressElement(BasePageElement):
    locator = NewOrganizationPageLocators.address_input

class PhoneElement(BasePageElement):
    locator = NewOrganizationPageLocators.phone_input

class OrganizationTypeElement(BasePageRadioElement):
    locator = NewOrganizationPageLocators.type_radio

#class IpSupportElement(BasePagePulldownElement):
#    locator = NewPageLocators.cloudlet_ipsupport_input

#class NumDynamicIpsElement(BasePageElement):
#    locator = NewPageLocators.cloudlet_numdynamicips_input

class NewOrganizationSettingsPage(BasePage):
    organization_name = OrganizationNameElement()
    address = AddressElement()
    phone = PhoneElement()
    organization_type = OrganizationTypeElement()

    #def is_title_present(self):
    #    return self.is_element_present(NewOrganizationPageLocators.title)

    def is_heading_present(self):
        return self.is_element_present(NewOrganizationPageLocators.heading)

    def is_type_label_present(self):
        return self.is_element_present(NewOrganizationPageLocators.type_label)

    def is_type_developer_label_present(self):
        return self.is_element_present(NewOrganizationPageLocators.type_developer_label)

    def is_type_operator_label_present(self):
        return self.is_element_present(NewOrganizationPageLocators.type_operator_label)

    def is_step1_active_present(self):
        return self.is_element_present(NewOrganizationPageLocators.step1_active)

    def is_step2_inactive_present(self):
        return self.is_element_present(NewOrganizationPageLocators.step2_inactive)

    def is_step3_inactive_present(self):
        return self.is_element_present(NewOrganizationPageLocators.step3_inactive)

    def click_cancel_button(self):
        element = self.driver.find_element(*NewOrganizationPageLocators.cancel_button).click()

    def click_continue_button(self):
        element = self.driver.find_element(*NewOrganizationPageLocators.create_button).click()

    def is_cancel_button_present(self):
        return self.is_element_present(NewOrganizationPageLocators.cancel_button)

    #def is_continue_button_present(self):
    #    return self.is_element_present(NewOrganizationPageLocators.save_button)

    def is_create_organization_button_present(self):
        return self.is_element_present(NewOrganizationPageLocators.create_button)

    def is_organizationname_label_present(self):
        return self.is_element_present(NewOrganizationPageLocators.organization_name_label)

    def is_organizationname_input_present(self):
        return self.is_element_present(NewOrganizationPageLocators.organization_name_input)

    def is_address_label_present(self):
        return self.is_element_present(NewOrganizationPageLocators.address_label)

    def is_address_input_present(self):
        return self.is_element_present(NewOrganizationPageLocators.address_input)

    def is_phone_label_present(self):
        return self.is_element_present(NewOrganizationPageLocators.phone_label)

    def is_phone_input_present(self):
        return self.is_element_present(NewOrganizationPageLocators.phone_input)

    def are_elements_present(self, org_type):
        settings_present = True
        logging.info('org type is ' + org_type)
        #if self.is_title_present():
        #    logging.info('title present')
        #else:
        #    logging.error('title not present')
        #    settings_present = False

        if self.is_heading_present():
            logging.info('heading present')
        else:
            logging.error('heading not present')
            settings_present = False

        if self.is_cancel_button_present():
            logging.info('cancel button present')
        else:
            logging.error('cancel button not present')
            settings_present = False

        #if self.is_continue_button_present():
        #    logging.info('continue button present')
        #else:
        #    logging.error('continue button not present')
        #    settings_present = False

        if self.is_create_organization_button_present():
            logging.info('create organization button present')
        else:
            logging.error('create organization button not present')
            settings_present = False

        if org_type == "Developer":
            if self.is_type_label_present() :
                logging.info('Type Developer label present')
            else:
                logging.error('Type Developer label not present')
                settings_present = False
        else:
            if self.is_type_label_present():
                logging.info('Type Operator label present')
            else:
                logging.error('Type Operator label not present')
                settings_present = False

        if self.is_organizationname_label_present() and self.is_organizationname_input_present():
            logging.info('Organization label/input present')
        else:
            logging.error('Organization label/input not present')
            settings_present = False

        if self.is_address_label_present() and self.is_address_input_present():
            logging.info('address label/input present')
        else:
            logging.error('address label/input not present')
            settings_present = False

        if self.is_phone_label_present() and self.is_phone_input_present():
            logging.info('phone label/input present')
        else:
            logging.error('phone label/input not present')
            settings_present = False

        if self.is_step1_active_present():
            logging.info('step1 active present')
        else:
            logging.error('step1 active not present')
            settings_present = False

        if self.is_step2_inactive_present():
            logging.info('step2 inactive present')
        else:
            logging.error('step2 inactive not present')
            settings_present = False

        if self.is_step3_inactive_present():
            logging.info('step3 inactive present')
        else:
            logging.error('step3 inactive not present')
            settings_present = False


        return settings_present

    #def create_organization(self, organization_type=None, organization_name=None, address=None, phone=None):
    def create_organization(self, organization_name=None, address=None, phone=None):   
        logging.info('creating organization')

        #self.organization_type = organization_type
        self.organization_name = organization_name
        self.address = address
        self.phone = phone

        self.take_screenshot('add_new_organization_settings.png')

        self.click_continue_button()
