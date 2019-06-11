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
from console.apps_page import AppsPage
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
        chrome_options.add_argument("--window-size=1920,1080")
        chrome_options.add_argument("--disable-extensions")
        #chrome_options.add_argument("--disable-gpu")
        #chrome_options.add_argument("--proxy-server='direct://'")
        #chrome_options.add_argument("--proxy-server=")
        #chrome_options.add_argument("--proxy-bypass-list=*")
        chrome_options.add_argument("--proxy-server='direct://'")
        chrome_options.add_argument("--proxy-bypass-list=*")
        chrome_options.add_argument("--start-maximized")
        #chrome_options.add_argument("--headless")
        #chrome_options.add_argument('--disable-dev-shm-usage')
        #chrome_options.add_argument('--no-sandbox')
        #chrome_options.add_argument('disable-infobars')
        #chrome_options.add_argument('--no-proxy-server')
        chrome_options.add_argument('--enable-logging=stderr')


        self.driver = webdriver.Chrome(chrome_options=chrome_options)
        print('*WARN*', self.driver)
        self.driver.get(url)

        self.compute_page = ComputePage(self.driver)
        self.flavors_page = FlavorsPage(self.driver)
        self.cloudlets_page = CloudletsPage(self.driver)
        self.apps_page = AppsPage(self.driver)
        self.new_flavor_page = NewFlavorSettingsPage(self.driver)
        self.new_cloudlet_page = NewCloudletSettingsPage(self.driver)

    def login_to_mex_console(self, browser='Chrome', username='mexadmin', password='mexadmin123', enter_key=False):
        self.take_screenshot('loginpage_pre')

        self.username = username

        assert 'MEX MONITORING' in self.driver.title, 'Page title is not correct'

        login_page = LoginPage(self.driver)
        #login_validation_text = login_page.get_login_validation_text()
        #print('*WARN*', 'logintext1', login_validation_text)

        if login_page.is_login_switch_button_present:
            logging.info('login switch button is present')
        else:
            raise Exception('Login switch button not found')

        if login_page.is_signup_switch_button_present:
            logging.info('signup switch button is present')
        else:
            raise Exception('signup switch button not found')

        if username: login_page.username = username
        if password: login_page.password = password

        if enter_key:
            logging.info('logging in with ENTER key')
            login_page.hit_enter_key()
        else:
            logging.info('logging in with Login button key')
            login_page.click_login_button()

        #time.sleep(1)

        login_validation_text = login_page.get_login_validation_text()
        print('*WARN*', 'logintext', login_validation_text)
        if login_validation_text:
            raise Exception(login_validation_text)

        if login_page.is_alert_box_present():
            alert_text = login_page.get_alert_box_text()
            logging.error(f'alert present box present with text={alert_text}')
            raise Exception(alert_text)

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

        self.take_screenshot('Flavor table sorted')

    def order_flavor_ram(self, count):
        logging.info('Sorting flavors numerically by ram')
        count = int(count)
        while (count != 0):
            self.flavors_page.click_flavorRAM()
            count -= 1
            time.sleep(1)

    def order_flavor_vcpus(self, count):
        logging.info('Sorting flavors numerically by vcpus')
        count = int(count)
        while (count != 0):
            self.flavors_page.click_flavorVCPUS()
            count -= 1
            time.sleep(1)

    def order_flavor_disk(self, count):
        logging.info('Sorting flavors numerically by disk')
        count = int(count)
        while (count != 0):
            self.flavors_page.click_flavorDisk()
            count -= 1
            time.sleep(1)

    def order_flavor_edit(self):
        logging.info('Not Able to Sort by Edit')
        count = 5
        while (count != 0):
            self.flavors_page.click_flavorEdit()
            count -= 1
            time.sleep(1)


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

    def open_apps(self):
        self.take_screenshot('open_apps_pre')

        self.compute_page.click_apps()

        if self.compute_page.is_table_heading_present('Apps'):
            logging.info('apps heading present')
        else:
            raise Exception('apps heading not present')

        if self.apps_page.is_apps_table_header_present():
            logging.info('apps table header present')
        else:
            raise Exception('apps header not present')

        time.sleep(3)  # wait for table to load. maybe a better way to do this

        self.take_screenshot('open_apps_post')

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

    def app_should_exist(self, region=None, org_name=None, app_name=None, version=None, deployment_type=None, default_flavor=None, ports=None, wait=5):
        self.take_screenshot('app_should_exist_pre')
        logging.info(f'app_should_exist {region} {app_name} {org_name} {version} {deployment_type} {default_flavor} {ports}')

        if region is None: region = self._region
        if app_name is None: flavor_name = self._app['key']['name']
        if org_name is None: ram = self._flavor['ram']
        if version is None: vcpus = self._flavor['vcpus']
        if deployment_type is None: disk = self._flavor['disk']
        if default_flavor is None: disk = self._flavor['disk']
        if ports is None: disk = self._flavor['disk']

        if self.apps_page.wait_for_app(region=region, org_name=org_name, app_name=app_name, version=version, deployment_type=deployment_type, default_flavor=default_flavor, ports=ports):
            logging.info('app found')
        else:
            raise Exception('App NOT found')

    def cloudlet_should_exist(self, region=None, cloudlet_name=None, operator=None, latitude=None, longitude=None, wait=5):
        self.take_screenshot('cloudlet_should_exist_pre')
        logging.info(f'cloudlet_should_exist {region} {cloudlet_name} {operator} {latitude} {longitude}')

        if region is None: region = self._region
        if cloudlet_name is None: flavor_name = self._app['key']['name']
        if operator is None: ram = self._flavor['ram']
        if latitude is None: vcpus = self._flavor['vcpus']
        if longitude is None: disk = self._flavor['disk']

        if self.cloudlets_page.wait_for_cloudlet(region=region, cloudlet_name=cloudlet_name, operator=operator, latitude=latitude, longitude=longitude):
            logging.info('cloudlet found')
        else:
            raise Exception('cloudlet NOT found')

    def cloudlets_should_show_on_map(self, number_cloudlets):
        self.cloudlets_page.zoom_out_map(2)

        cloudlets = self.cloudlets_page.get_cloudlet_icon_numbers()
        if cloudlets == number_cloudlets:
            logging.info(f'number of cloudlet icons match. found {number_cloudlets} cloudlets')
        else:
            logging.error(f'didnot find all cloudlets. looking for {number_cloudlets} but found {cloudlets}')
            raise Exception('not all cloudlets found on map')

    def sort_cloudlets_by_cloudlet_name(self):
        self.cloudlets_page.click_cloudlet_name_heading()

    def sort_cloudlets_by_region(self):
        self.cloudlets_page.click_region_heading()

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
        time.sleep(5)
