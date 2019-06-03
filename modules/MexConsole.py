from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import logging
from robot.api import logger
import time
from console.login_page import LoginPage
from console.main_page import MainPage
from console.compute_page import ComputePage
from console.flavors_page import FlavorsPage
from console.cloudlets_page import CloudletsPage
from console.new_settings_page import NewFlavorSettingsPage
from console.new_cloudlet_settings_page import NewCloudletSettingsPage

from mex_controller_classes import Flavor

logging.basicConfig(format='%(asctime)s %(levelname)s %(funcName)s line:%(lineno)d - %(message)s',datefmt='%d-%b-%y %H:%M:%S')
#logger = logging.getLogger('mexInfluxDb')

class MexConsole() :
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'

    def __init__(self, url):
        print('*WARN*', 'INIT')
        self.url = url
        self.username = None

        self._region = None
        self._flavor = None
        self._cloudlet = None

        chrome_options = Options()
        #chrome_options.add_argument("--disable-extensions")
        #chrome_options.add_argument("--disable-gpu")
        #chrome_options.add_argument("--headless")

        self.driver = webdriver.Chrome(chrome_options=chrome_options)

        self.driver.get(url)

        self.compute_page = ComputePage(self.driver)
        self.flavors_page = FlavorsPage(self.driver)
        self.cloudlets_page = CloudletsPage(self.driver)
        self.new_flavor_page = NewFlavorSettingsPage(self.driver)
        self.new_cloudlet_page = NewCloudletSettingsPage(self.driver)

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

        self.take_screenshot('compute_clicked')

        compute_page = ComputePage(self.driver)
        if compute_page.is_branding_present():
            logging.info('branding present')
        else:
            raise Exception('Branding not present')

        #if compute_page.is_refresh_icon_present():
        #    logging.info('refresh icon present')
        #else:
        #    raise Exception('Refresh icon not present')

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

    def order_flavor_names(self, count):
        logging.info('Sorting flavors alphabetically')
        count = int(count)
        while (count != 0):
            self.flavors_page.click_flavorName()
            count -= 1
            time.sleep(1)
        sorted = self.flavors_page.get_flavor_sort("flavorname")

        time.sleep(1)

        self.take_screenshot('Flavor table sorted')

        return(sorted)

    def order_flavor_ram(self):
        logging.info('Sorting flavors numerically by ram')
        count = 5
        while (count != 0):
            self.flavors_page.click_flavorRAM()
            count -= 1
            time.sleep(1)
        sorted = self.flavors_page.get_flavor_sort("ram")

        time.sleep(1)
        self.take_screenshot('Flavor table sorted')

        return(sorted)

    def order_flavor_vcpus(self):
        logging.info('Sorting flavors numerically by vcpus')
        count = 4
        while (count != 0):
            self.flavors_page.click_flavorVCPUS()
            count -= 1
            time.sleep(1)
        sorted = self.flavors_page.get_flavor_sort("vcpus")

        time.sleep(1)
        self.take_screenshot('Flavor table sorted')

        return(sorted)

    def order_flavor_disk(self):
        logging.info('Sorting flavors numerically by disk')
        count = 5
        while (count != 0):
            self.flavors_page.click_flavorDisk()
            count -= 1
            time.sleep(1)
        sorted = self.flavors_page.get_flavor_sort("disk")

        time.sleep(1)
        self.take_screenshot('Flavor table sorted')

        return(sorted)

    def order_flavor_edit(self):
        logging.info('Not Able to Sort by Edit')
        count = 5
        while (count != 0):
            self.flavors_page.click_flavorEdit()
            count -= 1
            time.sleep(1)
        # Unsorted = self.flavors_page.get_flavor_sort("edit")

        time.sleep(1)
        self.take_screenshot('Flavor Table Unsorted')

        # return(Unsorted)

    def flavor_edit_fail(self):
        self.flavors_page.click_flavorButtonEdit()
        self.flavors_page.click_flavorButtonEdit()
        self.flavors_page.click_flavorButtonEdit()
        self.take_screenshot('Flavor Editing Unsupported')

    def open_flavors(self):
        self.take_screenshot('open_flavors_pre')

        self.compute_page.click_flavors()

        if self.compute_page.is_table_heading_present('Flavors'):
            logging.info('flavor heading present')
        else:
            raise Exception('flavor heading not present')

        if self.flavors_page.is_flavors_table_header_present():
            logging.info('flavor table header present')
        else:
            raise Exception('flavor header not present')

        time.sleep(3)  # wait for table to load. maybe a better way to do this

        self.take_screenshot('open_flavors_post')

    def open_cloudlets(self):
        self.take_screenshot('open_cloudlets_pre')

        self.compute_page.click_cloudlets()

        if self.compute_page.is_table_heading_present('Cloudlets'):
            logging.info('cloudlet heading present')
        else:
            raise Exception('cloudlet heading not present')

        if self.cloudlets_page.is_cloudlets_table_header_present():
            logging.info('cloudlet table header present')
        else:
            raise Exception('cloudlet header not present')

        time.sleep(3)  # wait for table to load. maybe a better way to do this

        self.take_screenshot('open_cloudlets_post')

    def add_new_flavor(self, region=None, flavor_name=None, ram=None, vcpus=None, disk=None):
        self.take_screenshot('add_new_flavor_pre')

        self.compute_page.click_new_button()

        if self.new_flavor_page.are_elements_present():
            logging.info('click New Flavor button verification succeeded')
        else:
            raise Exception('click New Flavor button verifcation failed')

        flavor = Flavor(flavor_name=flavor_name, ram=ram, vcpus=vcpus, disk=disk).flavor
        self._flavor = flavor
        self._region = region
        print('*WARN*', 'flavor', flavor)

        self.new_flavor_page.create_flavor(region, flavor['key']['name'], flavor['ram'], flavor['vcpus'], flavor['disk'])

        self.take_screenshot('add_new_flavor_post')

    def add_new_cloudlet(self, region=None, flavor_name=None, ram=None, vcpus=None, disk=None):
        self.take_screenshot('add_new_cloudlet_pre')

        self.compute_page.click_new_button()

        if self.new_cloudlet_page.are_elements_present():
            logging.info('click New Cloudlet button verification succeeded')
        else:
            raise Exception('click New Cloudlet button verifcation failed')

        cloudlet = Cloudlet(flavor_name=flavor_name, ram=ram, vcpus=vcpus, disk=disk).cloudlet
        self._cloudlet = cloudlet
        self._region = region
        print('*WARN*', 'cloudlet', cloudlet)

        self.new_cloudlet_page.create_cloudlet(region, flavor['key']['name'], flavor['ram'], flavor['vcpus'], flavor['disk'])

        self.take_screenshot('add_new_cloudlet_post')

    def flavor_should_exist(self, region=None, flavor_name=None, ram=None, vcpus=None, disk=None, wait=5):
        self.take_screenshot('flavor_should_exist_pre')
        logging.info(f'flavor_should_exist region={region} flavor={flavor_name} ram={ram} vcpus={vcpus} disk={disk} wait={wait}')

        if region is None: region = self._region
        if flavor_name is None: flavor_name = self._flavor['key']['name']
        if ram is None: ram = self._flavor['ram']
        if vcpus is None: vcpus = self._flavor['vcpus']
        if disk is None: disk = self._flavor['disk']

        if self.flavors_page.wait_for_flavor(region, flavor_name, ram, vcpus, disk):
            logging.info('flavor found')
        else:
            raise Exception('Flavor NOT found')

        #rows = self.get_table_data()
        #print('*WARN*', 'sf', self._flavor)
        #for r in rows:
        #    print('*WARN*', 'flavorr', r)
        #    if r[0] == region and r[1] == 'flavor_name':
        #        print('*WARN*', 'found flavor')
        #        return True

        #return False

    #def flavor_should
    def get_table_data(self):
        self.take_screenshot('get_table_data_pre')

        rows = self.compute_page.get_table_rows()
        #for r in rows:
        #    print('*WARN*', 'r', r)

        return rows

    def take_screenshot(self, name):
        self.compute_page.take_screenshot(name + '.png')
        #self.driver.save_screenshot(name+'.png')
        #logger.info(f'<img src="{name}.png">', html=True)

    def close_browser(self):
        #self.take_screenshot('closebrowser')
        self.compute_page.take_screenshot('closebrowser.png')
        self.driver.close()
