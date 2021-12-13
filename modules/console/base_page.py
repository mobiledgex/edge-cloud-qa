from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions
from selenium.webdriver.common.keys import Keys
import sys
import logging
import time
import math
from robot.api import logger

from console.locators import BasePageLocators
from selenium.webdriver.common.action_chains import ActionChains

class BasePage(object):
    def __init__(self, driver):
        self.driver = driver
        self.driver.implicitly_wait(5)
        self.timeout = 30
        self.timestamp = str(time.time())
        
    def find_element(self, element):
        try:
            return WebDriverWait(self.driver, 5).until(expected_conditions.visibility_of_element_located((element)))            
        except:
            raise Exception('Error finding element', element)

    def find_number_of_entries(self):
        value = self.driver.find_element(*BasePageLocators.page_number).text
        list = value.split(" of ")
        number = int(list[1])
        return number

    def find_number_of_pages(self):
        value = self.driver.find_element(*BasePageLocators.page_number).text
        list = value.split(" of ")
        number = int(list[1])
        result = number/75
        num_pages = math.ceil(result)
        return num_pages
        
    def click_element(self, element):
        self.find_element(element).click()

    def is_element_present(self, element, text=None, timeout=5):
        element_found = None
        
        try:
            logging.info(f'looking for element={element} with timeout={timeout}')
            element_found = WebDriverWait(self.driver, timeout).until(expected_conditions.visibility_of_element_located((element)))
            #element_found = self.driver.find_element(*element) #WebDriverWait(self.driver, 5).until(expected_conditions.visibility_of_element_located((element)))
            #print('*WARN*', element_found.is_displayed(), element_found.is_enabled())
            logging.info(f'element={element} is found')
        except:
            logging.info(f'element={element} is not found')
            return False

        if text and element_found.text != text:
            logging.error(f'Expected text={text} but got {element_found.text}')
            return False
        else:
            logging.info(f'Found {element} with text={text}. Expected {element_found.text}')

        #return element_found.is_enabled() and element_found.is_displayed()
        return True

    def is_element_present_in_list(self, element, text=None):
        found = False
        logging.debug('looking for {element} in list with text={text}')

        element_list = self.driver.find_elements(*element)

        for element in element_list:
            if text and element.text != text:
                logging.warning(f'Expected text={text} but got {element.text}')
            else:
                if element.is_enabled() and element.is_displayed():
                    logging.info('found element ', element.text)
                    found = True
                    break
        return found

    def take_screenshot(self, name):
        #self.driver.save_screenshot(name)
        new_name = name + '_' + self.timestamp + '.png'
        self.driver.save_screenshot(new_name)
        logger.info(f'<img src="{new_name}">', html=True)

    def send_keys(self, element, keys):
        logger.info('sending keys:' + keys)
        self.driver.find_element(*element).send_keys(keys)

    def is_dialog_box_present(self, timeout=30):
        return self.is_element_present(BasePageLocators.dialog_box, timeout=timeout)

    def is_alert_box_present(self, timeout=5):
        return self.is_element_present(BasePageLocators.alert_box, timeout=timeout)

    def is_warning_box_present(self, timeout=5):
        return self.is_element_present(BasePageLocators.text_box, timeout=timeout)

    def get_warning_box_text(self, timeout=5):
        text = self.driver.find_element(*BasePageLocators.text_box).text
        logger.info(f'dialogbox text={text}')
        if text == '':  # if is empty, wait and check again
            time.sleep(1)
            text = self.driver.find_element(*BasePageLocators.text_box).text
        return text

    def get_dialog_box_text(self):
        text = self.driver.find_element(*BasePageLocators.dialog_box).text
        logger.info(f'dialogbox text={text}')
        if text == '':  # if is empty, wait and check again
            time.sleep(1)
            text = self.driver.find_element(*BasePageLocators.dialog_box).text
        return text

    def get_alert_box_text(self):
        text = self.driver.find_element(*BasePageLocators.alert_box).text
        logger.info(f'alertbox text={text}')
        if text == '':  # if is empty, wait and check again
            time.sleep(1)
            text = self.driver.find_element(*BasePageLocators.alert_box).text
        return text

    def get_all_elements(self, element):
        return  self.driver.find_elements(*element)

    def get_element_text(self, element):
        return self.driver.find_element(*element).text

    def get_input_value(self, element):
        return self.driver.find_element(*element).get_attribute('value')

    def is_element_text_present(self, element, text):
        logging.info(f'looking for element={element} and text={text}')

        found_text = self.get_element_text(element) 
        if found_text == text:
            logging.info(f'text={text} found')
            return True
        else:
            logging.info(f'text={text} NOT found. found={found_text}')
            return False

    def wait_for_dialog_box(self, text=None, wait=None):
        print(wait)
        found = False
        if self.is_dialog_box_present():
            for seconds in range(wait):
                if self.get_dialog_box_text() != '':
                    output = self.get_dialog_box_text()
                    list = output.splitlines()
                    for i in range(0, len(list)):
                        logging.info('Indices are ' + list[i])
                        if list[i] == text:
                            logging.info(f'dialog box text found: {text}')
                            return True
                else:
                    logging.error(f'No text found in dialog box')
                    return False
                time.sleep(1)
        else:
            logging.error(f'dialog box not found')
            return False

        logging.error('dialog box text not found. got ' + self.get_dialog_box_text())
        return False

    def wait_for_alert_box(self, text=None, wait=None):
        print(wait)
        found = False
       # must_end = time.time() + wait
        for seconds in range(wait):
            if self.is_alert_box_present():
                if self.get_alert_box_text() == text:
                    logging.info(f'SUCCESS alert box found: {text}')
                    return True
                else:
                    logging.error('SUCCESS alert box not found. got ' + self.get_alert_box_text())
                    return False
                break
            time.sleep(1)
       # while time.time() < must_end:
            #count += 1
            
            #if self.is_alert_box_present():
            #    logging.info('SUCCESS alert box found')
             #   #else:
            #else:
               # logging.info('alert box NOT found. got ' + self.get_alert_box_text())
                #time.sleep(1)
               # self.wait_for_alert_box()
                #if count > wait:
                    #sys.exit("Error message")
                #print("*WARN*", count)

        logging.error(f'wait_for_alert box timedout')
        return False

class BasePageElement(object):
    def __set__(self, obj, value):
        logging.debug(f'setting {self.locator} to {value}')
        driver = obj.driver
        
        WebDriverWait(driver, 100).until(
            lambda driver: driver.find_element(*self.locator))

        text = driver.find_element(*self.locator).get_attribute('value')
        #print('*WARN*', 'text=', text)
        for i in range(len(text)):
            driver.find_element(*self.locator).send_keys(Keys.BACKSPACE)
        #driver.find_element(*self.locator).send_keys(Keys.COMMAND, "a")
        
        #time.sleep(5)
        
        driver.find_element(*self.locator).send_keys(value)

    def __get__(self, obj, owner):
        driver = obj.driver
        WebDriverWait(driver, 100).until(
            #lambda driver: driver.find_element_by_name(self.locator))
            lambda driver: driver.find_element(self.locator))
        element = driver.find_element_by_name(self.locator)
        return element.get_attribute("value")

class BasePagePulldownElement(object):
    def __set__(self, obj, value):
        driver = obj.driver

        pulldown = driver.find_element(*self.locator)
        wait = WebDriverWait(driver, 50, poll_frequency=1)

        pulldownelement = wait.until(expected_conditions.element_to_be_clickable((self.locator)))
        ActionChains(driver).click(on_element=pulldown).perform()
        print('*INFO*', 'clicked pulldown - ', self.locator )
        time.sleep(1)

        choice = f'{self.locator[1]}//span[text()="{value}"]'
        print('*INFO*', 'Selecting the option from Pulldown - ' + choice)

        try:
            wait.until(expected_conditions.element_to_be_clickable((By.XPATH, choice)))
        except Exception as e:
            raise Exception("Could not find dropdown value :", value, e)
        driver.find_element_by_xpath(choice).click()

        wait.until(expected_conditions.invisibility_of_element_located((By.XPATH,"//div[contains(@class,'MuiLinearProgress-bar2')]")))

class BasePagePulldownMultiElement(object):
    def __set__(self, obj, value):
        driver = obj.driver

        pulldown = driver.find_element(*self.locator)
        ActionChains(driver).click(on_element=pulldown).perform()
        print('*WARN*', 'clicked MultiELement pulldown - ', pulldown)

        choice = f'{self.locator2[1]}//span[text()="{value}"]'
        print('*WARN*', choice)
        driver.find_element_by_xpath(choice).click()
        pulldown = driver.find_element(*self.locator)
        pulldown.click()
        #print('*WARN*', 'clicked it')

class BasePageRadioElement(object):
    def __set__(self, obj, value):
        driver = obj.driver

        radio = driver.find_element(*self.locator)

        choice = f'{self.locator[1]}//div[@class="ui radio checkbox"]/label[text()="{value}"]'
        logging.debug('clicking ' + choice)
        driver.find_element_by_xpath(choice).click()

#class TextBoxElement(BasePageElement):
#    locator
