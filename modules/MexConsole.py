from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import logging
from robot.api import logger
import time
from console.login_page import LoginPage
from console.main_page import MainPage
from console.compute_page import ComputePage
from console.new_settings_page import NewFlavorSettingsPage

logging.basicConfig(format='%(asctime)s %(levelname)s %(funcName)s line:%(lineno)d - %(message)s',datefmt='%d-%b-%y %H:%M:%S')
#logger = logging.getLogger('mexInfluxDb')

class MexConsole() :
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'
    
    def __init__(self, url):
        print('*WARN*', 'INIT')
        self.url = url
        self.username = None
        chrome_options = Options()
        #chrome_options.add_argument("--disable-extensions")
        #chrome_options.add_argument("--disable-gpu")
        #chrome_options.add_argument("--headless")
        
        self.driver = webdriver.Chrome(chrome_options=chrome_options)

        self.driver.get(url)

        self.compute_page = ComputePage(self.driver)
        self.new_flavor_page = NewFlavorSettingsPage(self.driver)
        
    def login_to_mex_console(self, browser='Chrome', username='mexadmin', password='mexadmin123'):
        self.take_screenshot('loginpage_pre')

        self.username = username
        
        assert 'MEX MONITORING' in self.driver.title, 'Page title is not correct'

        login_page = LoginPage(self.driver)

        if login_page.is_login_switch_button_present:
            logging.info('login switch button is present')
        else:
            raise Exception('Login switch button not found')

        if login_page.is_signup_switch_button_present:
            logging.info('signup switch button is present')
        else:
            raise Exception('signup switch button not found')

        login_page.username = username
        login_page.password = password

        login_page.click_login_button()
                
        main_page = MainPage(self.driver)
        if main_page.is_compute_button_present():
            logging.info('Compute button present')
        else:
            raise Exception('Compute button not present')
        #if main_page.is_monitoring_button_present():
        #    logging.info('Monitoring button present')
        #else:
        #    raise Exception('Monitoring button not present')
        if main_page.is_avatar_present():
            logging.info('Avatar present')
        else:
            raise Exception('Avatar not present')
        if main_page.is_username_present(username):
            logging.info(f'Username {username} present')
        else:
            raise Exception(f'Username {username} not present')
        
        self.take_screenshot('loginpage_post')

    def open_compute(self):
        self.take_screenshot('open_compute_pre')

        main_page = MainPage(self.driver)
        main_page.click_compute_button()

        compute_page = ComputePage(self.driver)
        if compute_page.is_branding_present():
            logging.info('branding present')
        else:
            raise Exception('Branding not present')

        if compute_page.is_refresh_icon_present():
            logging.info('refresh icon present')
        else:
            raise Exception('Refresh icon not present')

        if compute_page.is_public_icon_present():
            logging.info('public icon present')
        else:
            raise Exception('public icon not present')

        if compute_page.is_notifications_icon_present():
            logging.info('notifications icon present')
        else:
            raise Exception('notifications icon not present')

        if compute_page.is_add_icon_present():
            logging.info('add icon present')
        else:
            raise Exception('add icon not present')

        if compute_page.is_avatar_present():
            logging.info('avatar present')
        else:
            raise Exception('avatar not present')

        if compute_page.is_username_present(self.username):
            logging.info('username present')
        else:
            raise Exception('username not present')

        if compute_page.is_support_present():
            logging.info('support present')
        else:
            raise Exception('support not present')

    #def get_organization_data(self):
    #    self.take_screenshot('get_organization_pre')

    #    rows = self.compute_page.get_table_rows()
    #    for r in rows:
    #        print('*WARN*', 'r', r)

    def change_region(self, region):
        logging.info(f'Changing region to {region}')

        self.compute_page.click_region_pulldown()
        self.compute_page.click_region_pulldown_option(region)

        time.sleep(3)
        
    def open_flavors(self):
        self.take_screenshot('open_flavors_pre')

        self.compute_page.click_flavors()

        if self.compute_page.is_table_heading_present('Flavors'):
            logging.info('flavor heading present')
        else:
            raise Exception('flavor heading not present')

        if self.compute_page.is_flavor_table_header_present():
            logging.info('flavor table header present')
        else:
            raise Exception('flavor header not present')

        time.sleep(3)  # wait for table to load. maybe a better way to do this

        self.take_screenshot('open_flavors_post')
        
    def add_new_flavor(self, region, flavor_name, ram, vcpus, disk):
        self.take_screenshot('add_new_flavor_pre')

        self.compute_page.click_new_button()

        if self.new_flavor_page.are_elements_present():
            logging.info('click New button verification succeeded')
        else:
            raise Exception('click New button verifcation failed')

        self.take_screenshot('add_new_flavor_post')
        
    def get_table_data(self):
        self.take_screenshot('get_table_data_pre')

        rows = self.compute_page.get_table_rows()
        for r in rows:
            print('*WARN*', 'r', r)

    def take_screenshot(self, name):
        self.driver.save_screenshot(name+'.png')
        logger.info(f'<img src="{name}.png">', html=True)
        
    def close_browser(self):
        self.take_screenshot('closebrowser')
        self.driver.close()
        
