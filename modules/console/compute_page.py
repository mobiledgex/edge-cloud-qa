from console.base_page import BasePage
from console.locators import ComputePageLocators

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
