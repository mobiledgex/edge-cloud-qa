from selenium.webdriver.support.ui import WebDriverWait
import logging
import time
from robot.api import logger

class BasePage(object):
    def __init__(self, driver):
        self.driver = driver
        self.driver.implicitly_wait(5)
        self.timeout = 30

    def is_element_present(self, element, text=None):
        try:
            element = self.driver.find_element(*element)
        except:
            logging.error(f'element={element} is not found')
            return False
        
        print('*WARN*', 'iselmentpresent', element, text, element.text)
        if text and element.text != text:
            logging.error(f'Expected text={text} but got {element.text}')
            return False
        print('*WARN*', 'iselmentpresentenabled', text, element.is_enabled(), element.is_displayed())
        return element.is_enabled() and element.is_displayed()

    def is_element_present_in_list(self, element, text=None):
        found = False
        
        element_list = self.driver.find_elements(*element)
        print('*WARN*', 'iselmentpresent', element_list, text)
        for element in element_list:
            if text and element.text != text:
                logging.warning(f'Expected text={text} but got {element.text}')
            else:
                if element.is_enabled() and element.is_displayed():
                    print('*WARN*', 'found', element.text)
                    found = True
                    break
        return found

    def take_screenshot(self, name):
        self.driver.save_screenshot(name)
        logger.info(f'<img src="{name}">', html=True)
        
class BasePageElement(object):
    def __set__(self, obj, value):
        print('*WARN*', '__set__', value, *self.locator)
        driver = obj.driver
        print('*WARN*', 'driver', driver)
        WebDriverWait(driver, 100).until(
            lambda driver: driver.find_element(*self.locator))
        print('*WARN*', 'found')
        driver.find_element(*self.locator).clear()
        print('*WARN*', 'cleared')
        print('*WARN*', '__set__2', value, type(value))
        driver.find_element(*self.locator).send_keys(value)

    def __get__(self, obj, owner):
        print('*WARN*', '__get__')
        driver = obj.driver
        WebDriverWait(driver, 100).until(
            #lambda driver: driver.find_element_by_name(self.locator))
            lambda driver: driver.find_element(self.locator))
        element = driver.find_element_by_name(self.locator)
        return element.get_attribute("value")

class BasePagePulldownElement(object):
    def __set__(self, obj, value):
        print('*WARN*', '__set__', value, *self.locator)
        driver = obj.driver

        pulldown = driver.find_element(*self.locator)
        print('*WARN*', 'pulldown', pulldown, self.locator[1])
        pulldown.click()
        #driver.find_element_by_xpath(f'{self.locator}')
        #elem = pulldown.find_element_by_xpath(f'//span[text()="{value}"]/parent::div')
        #elem = driver.find_element_by_xpath(f'//span[text()="{value}"]')
        #elem = driver.find_element_by_xpath('//span[text()="EU"]')
        time.sleep(2)
        choice = f'{self.locator[1]}//span[text()="{value}"]'
        print('*WARN*', 'choice', choice)
        #elem = driver.find_element_by_xpath('//*[@class="ui modal transition visible active"]//div[@name="Region" and @role="listbox"]//div[@role="option"]/span[text()="US"]')
        driver.find_element_by_xpath(choice).click()
        #print('*WARN*', 'pulldown2', elem)
        #elem.click()
        #driver.find_element(*NewPageLocators.region_pulldown_option_us).click()

#class TextBoxElement(BasePageElement):
#    locator
