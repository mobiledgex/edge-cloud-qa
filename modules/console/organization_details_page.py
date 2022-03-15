from console.base_page import BasePage
from console.details_page import DetailsPage
from console.locators import DetailsPageLocators, OrganizationDetailsPageLocators

import logging

class OrganizationDetailsPage(DetailsPage):
    def is_organization_label_present(self):
        return self.is_element_present(OrganizationDetailsPageLocators.organization_label)

    def is_type_label_present(self):
        return self.is_element_present(OrganizationDetailsPageLocators.type_label)

    def is_role_label_present(self):
        return self.is_element_present(OrganizationDetailsPageLocators.role_label)

    def is_phone_label_present(self):
        return self.is_element_present(OrganizationDetailsPageLocators.phone_label)

    def is_address_label_present(self):
        return self.is_element_present(OrganizationDetailsPageLocators.address_label)

    def is_publicimage_label_present(self):
        return self.is_element_present(OrganizationDetailsPageLocators.publicimage_label)

    def is_organization_value_present(self, organization):
        return self.is_element_present(OrganizationDetailsPageLocators.organization_field, organization)

    def is_type_value_present(self):
        return self.is_element_present(OrganizationDetailsPageLocators.type_field)

    def is_role_value_present(self):
        return self.is_element_present(OrganizationDetailsPageLocators.role_field)

    def is_phone_value_present(self):
        return self.is_element_present(OrganizationDetailsPageLocators.phone_field)

    def is_address_value_present(self):
        return self.is_element_present(OrganizationDetailsPageLocators.address_field)

    def is_publicimage_value_present(self):
        return self.is_element_present(OrganizationDetailsPageLocators.publicimage_field)

    def are_elements_present(self, organization):
        elements_present = True

        elements_present = super().are_elements_present()
        
        if self.is_organization_label_present() and self.is_organization_value_present(organization):
            logging.info('organization present')
        else:
            logging.error('organization NOT present')
            elements_present = False

        if self.is_type_label_present() and self.is_type_value_present():
            logging.info('type present')
        else:
            logging.error('type NOT present')
            elements_present = False

        if self.is_role_label_present():
            if self.is_role_value_present():
                logging.info('role present')
            else:
                logging.error('role NOT present')
                elements_present = False
        else:
            logging.info('role label not present')

        if self.is_phone_label_present():
            if self.is_phone_value_present():
                logging.info('phone present')
            else:
                logging.error('phone NOT present')
                elements_present = False
        else:
            logging.info('phone label not present')

        if self.is_address_label_present():
            if self.is_address_value_present():
                logging.info('address present')
            else:
                logging.error('address NOT present')
                elements_present = False
        else:
            logging.info('address label not present')

        if self.is_publicimage_label_present():
            if self.is_publicimage_value_present():
                logging.info('public image present')
            else:
                logging.error('public image NOT present')
                elements_present = False
        else:
            logging.info('public image label not present')

        return elements_present

    def get_details(self):
        details_dict = super().get_details()
        details_dict['instructions'] = ''
        
        for row in self.driver.find_elements(*OrganizationDetailsPageLocators.instructions_text):
                print("*WARN*", row, row.text, 'okie')
                details_dict['instructions'] += row.text + '\n'

        return details_dict
  
    def verify_instructions(self, organization=None):
        organization_lc = organization.lower()
        line1 = "If your image is docker, please upload your image with your MobiledgeX Account Credentials to our docker registry using the following docker commands."
        line2 = "$ docker login -u <username> docker.mobiledgex.net"
        line3 = f'$ docker tag <your application> docker.mobiledgex.net/{organization_lc}/images/<application name>:<version>'
        line4 = f'$ docker push docker.mobiledgex.net/{organization_lc}/images/<application name>:<version>'
        line5 = "$ docker logout docker.mobiledgex.net"
        line6 = "If you image is VM, please upload your image with your MobiledgeX Account Credentials to our VM registry using the following curl command."
        line7 = f'$ curl -u<username> -T <path_to_file> "https://artifactory.mobiledgex.net/artifactory/repo-{organization}/<target_file_path>" --progress-bar -o <upload status filename>'
        list = []

        for index in range(1, 6):
            location = f'//div[@style="margin: 20px; color: white;"]/div[@class="newOrg3-2"]//div[{index}]'
            value = self.driver.find_element_by_xpath(location).text
            logging.info('Value is' + value)
            list.append(value)
  
        for index in range(1, 3):
            location = f'//div[@style="margin: 20px; color: white;"]/div[@class="newOrg3-3"]//div[{index}]'
            value = self.driver.find_element_by_xpath(location).text
            logging.info('Value is' + value)
            list.append(value)

        if ((list[0] == line1) and (list[1] == line2) and (list[2] == line3) and (list[3] == line4) and (list[4] == line5) and (list[5] == line6) and (list[6] == line7)):
            return True
        else:
            return False 
                 
