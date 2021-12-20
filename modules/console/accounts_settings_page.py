from console.compute_page import ComputePage
from console.locators import DeleteConfirmationPageLocators, AccountsPageLocators, ComputePageLocators
from console.new_settings_page import NewSettingsPage
from selenium.webdriver.common.action_chains import ActionChains
import logging
import time

class AccountsSettingsPage(ComputePage):
    def is_accounts_table_header_present(self):
        header_present = True

        if self.is_element_present(AccountsPageLocators.accounts_table_header_username):
            logging.info('Username header present')
        else:
            logging.error('Username header NOT present')
            header_present = False

        if self.is_element_present(AccountsPageLocators.accounts_table_header_email):
            logging.info('email header present')
        else:
            logging.error('email header NOT present')
            header_present = False

        if self.is_element_present(AccountsPageLocators.accounts_table_header_emailverified):
            logging.info('email verified type header present')
        else:
            logging.error('email verified header NOT present')
            header_present = False

        if self.is_element_present(AccountsPageLocators.accounts_table_header_locked):
            logging.info('lock sign header present')
        else:
            logging.error('lock sign header NOT present')
            header_present = False

        return header_present


    def is_account_present(self, account_name=None, email=None, email_verified=None, locked=None):
        found = False

        rows = self.get_table_rows()
        for r in rows:
            if self.account_matches(r, account_name, email, email_verified, locked):
                logging.info('found account')
                return True
            #if account_name is None:
            #    r[0] = None
            #if email is None:
            #    r[1] = None
            #if email_verified is None:
            #    r[2] = None
            #else:
            #    if r[2] == 'Yes':
            #        r[2] = True
            #    elif r[2] == 'Send verification email':
            #        r[2] = False
            #    
            #if locked is None:
            #    r[3] = None 
            #else:
            #    print('*WARN*', 'lock', r[3].find_element_by_xpath('./i').get_attribute('class'))
            #    xpath_lock = r[3].find_element_by_xpath('./i').get_attribute('class')
            #    if 'lock open' in xpath_lock:
            #        r[3] = False
            #    else: 
            #        r[3] = True
            #
            #print('*WARN*', 'account', r, account_name, email, email_verified, locked)
            #if r[0] == account_name and r[1] == email and r[2] == email_verified and r[3] == locked:
            #    found = True
            #    logging.info('found account')
            #    return True

        return False

    def account_matches(self, row, account_name=None, email=None, email_verified=None, locked=None):
        logging.info(f'account should match name={account_name} email={email} email_verified={email_verified} locked={locked}')
        print('*WARN*', 'accountrow', row)
        if account_name is None:
            row[0] = None
        if email is None:
            row[1] = None
        if email_verified is None:
            row[3] = None
        else:
            if row[2] == 'Yes':
                row[2] = True
            elif row[2] == 'Send verification email':
                row[2] = False
                
        if locked is None:
            row[4] = None 
        else:
            print('*WARN*', 'lock', row[4].find_element_by_xpath('.//i').get_attribute('class'))
            xpath_lock = row[4].find_element_by_xpath('.//i').get_attribute('class')
            if 'lock open' in xpath_lock:
                row[4] = False
            else: 
                row[4] = True

        if email_verified is None:
            row[3] = None 
        else:
            if row[3] == 'Verify':
                row[3] = False
            else:
                print('*WARN*', 'lock', row[3].find_element_by_xpath('.//i').get_attribute('class'))
                xpath_verified = row[3].find_element_by_xpath('.//i').get_attribute('class')
                if 'check icon' in xpath_verified:
                    row[3] = True
                else: 
                    row[3] = False

        print('*WARN*', 'account', row, account_name, email, email_verified, locked)
        if row[1].replace('New\n','') == account_name and row[2] == email and row[3] == email_verified and row[4] == locked:
            logging.info('account matches')
            return True
        else:
            logging.info('account does NOT match')
            return False

    
    def new_icon_present(self):
        is_present = ComputePage.is_new_icon_present(self)
        if is_present:
            logging.info('accounts new icon IS present')
        else:
            raise Exception('accounts new icon NOT present')

    def click_next_page(self):
        e = self.driver.find_element(*AccountsPageLocators.next_page_button)
        ActionChains(self.driver).click(on_element=e).perform()

    def wait_for_account(self, account_name=None, email=None, email_verified=None, locked=None, wait=2):
        for pages in range(2):
            for attempt in range(wait):
                if self.is_account_present(account_name=account_name, email=email, email_verified=email_verified, locked=locked):
                    logging.info('found account ' + account_name)
                    return True

                #if self.is_account_present(account_name=account_name):
                #    logging.info('found account ' + account_name)
                #    return True
                #if self.is_account_present(email=email):
                #    logging.info('found account with email ' + email)
                #    return True
                else:
                    time.sleep(1)
            self.click_next_page()
        
        return False

    def delete_account(self, tempName=None, email=None):
        # while the darn NEW tag exists and adds a \n character
        totals_rows = self.driver.find_elements(*ComputePageLocators.details_row)
        total_rows_length = len(totals_rows)
        total_rows_length += 1
        if tempName == None:
            logging.info('Email passed ' + email)
            #row = self.get_table_row_by_value([(email, 2)])  # don't use INTs bc it reads text_value as string
            for row in range(1, total_rows_length):
                table_column =  f'//tbody/tr[{row}]/td[2]/div'
                value = self.driver.find_element_by_xpath(table_column).text
                if value == email:
                    i = row
                    break
        else:
            logging.info('Account name passed: ' + tempName)
            #row = self.get_table_row_by_value([(tempName, 1)])  # don't use INTs bc it reads text_value as string
            for row in range(1, total_rows_length):
                table_column =  f'//tbody/tr[{row}]/td[1]'
                value = self.driver.find_element_by_xpath(table_column).text
                if value == tempName:
                    i = row
                    break

        #logging.info('found account row')
        table_action = f'//tbody/tr[{i}]/td[5]//button[@aria-label="Action"]'
        e = self.driver.find_element_by_xpath(table_action)
        ActionChains(self.driver).click(on_element=e).perform()
        #row.find_element(*ComputePageLocators.table_action).click()
        self.driver.find_element(*ComputePageLocators.table_delete).click()
        #time.sleep(3)
        #row.find_element(*DeleteConfirmationPageLocators .yes_button).click()
        self.driver.find_element(*DeleteConfirmationPageLocators.yes_button).click()
        logging.info('account deleted ')

    def click_accounts_name_heading(self):
        self.driver.find_element(*AccountsPageLocators.accounts_table_header_username).click()

    def click_accounts_email_heading(self):
        self.driver.find_element(*AccountsPageLocators.accounts_table_header_email).click()

    def click_close_account_details(self):
        self.driver.find_element(*AccountsPageLocators.close_button).click()

    def click_account_row(self, account_name=None, email=None):
        if account_name == None:
            logging.info('clicking by email')
            self.get_table_row_by_value([(email, 3)]).click()
            row = self.get_table_row_by_value([(email, 3)])
            row.find_element(*AccountsPageLocators.account_details).click()
        else:
            logging.info('clicking by account name')
            row = self.get_table_row_by_value([(account_name, 2)])
            time.sleep(1)
            ActionChains(self.driver).click(on_element=row).perform()
            #row.find_element_by_xpath(f'.//div[text()="{account_name}"]').click()
            
            #row.find_element_by_xpath('.//i').click()
            #row = self.get_table_row_by_value([(account_name, 1)])
            #row.find_element(*AccountsPageLocators.account_details).click()
