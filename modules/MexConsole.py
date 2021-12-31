from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as ec
from selenium.webdriver.chrome.options import Options
from robot.api import logger
import time
import imaplib
import email
import logging

from console.base_page import BasePage
from console.apps_page import AppsPage
from console.main_page import MainPage
from console.login_page import LoginPage
from console.signup_page import SignupPage
from console.compute_page import ComputePage
from console.locators import BasePageLocators
from console.flavors_page import FlavorsPage
from console.details_page import DetailsPage
from console.cloudlets_page import CloudletsPage
from console.app_instances_page import AppInstancesPage
from console.organizations_page import OrganizationsPage
from console.details_cloudlet_page import CloudletDetailsPage
from console.cluster_instances_page import ClusterInstancesPage
from console.cluster_details_page import ClusterDetailsPage
from console.accounts_settings_page import AccountsSettingsPage
from console.accounts_details_page import AccountsDetailsPage
from console.users_settings_page import UsersPage, NewUsersPage
from console.new_flavor_settings_page import NewFlavorSettingsPage
from console.organization_details_page import OrganizationDetailsPage
from console.new_cloudlet_settings_page import NewCloudletSettingsPage
from console.new_organization_settings_page import NewOrganizationSettingsPage
from console.new_clusterinst_settings_page import NewClusterInstSettingsPage
from console.new_apps_settings_page import NewAppsSettingsPage
from console.new_appinst_settings_page import NewAppInstSettingsPage
from console.apps_details_page import AppsDetailsPage
from console.auto_scale_policy_page import AutoScalePolicyPage
from console.new_auto_scale_policy_page import NewAutoScalePolicyPage
from console.privacy_policy_page import PrivacyPolicyPage
from console.new_privacy_policy_page import NewPrivacyPolicyPage
from mex_controller_classes import Flavor, Cloudlet, Organization, App, AppInstance, AutoScalePolicy
from mex_master_controller.ClusterInstance import ClusterInstance
from mex_master_controller.TrustPolicy import TrustPolicy

import shared_variables_mc

logging.basicConfig(format='%(asctime)s %(levelname)s %(funcName)s line:%(lineno)d - %(message)s',datefmt='%d-%b-%y %H:%M:%S')
#logger = logging.getLogger('mexInfluxDb')

#############################################################################
# To run on Firefox
# Download geckodriver "brew install geckodriver"
# Add geckodriver to $PATH and specify location
# Ex: geckodriver = '/usr/local/Cellar/geckodriver/0.24.0/bin/geckodriver'
# In Open_Browser() define web browser Firefox for WebDriver
# In login_to_mex_console() change browser to 'Firefox'
# edit & uncomment below v

#firefox_options = webdriver.FirefoxOptions()
#geckodriver = '/usr/local/Cellar/geckodriver/0.24.0/bin/geckodriver'
############################################################################

class MexConsole() :
    #ROBOT_LIBRARY_SCOPE = 'GLOBAL'
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self, url):

        print('*WARN*', 'INIT mexconsole')
        self.url = url
        self.username = None

        self._newuser_username = None
        self._newuser_password = None
        self._newuser_email = None

        self._region = None
        self._flavor = None
        self._cloudlet = None

        self._mail = None
        self._mail_count = 9999999
        self._verify_link = None

        self.chrome_options = Options()
        #self.chrome_options.add_argument("--window-size=1600,900")
        self.chrome_options.add_argument("--disable-extensions")


        #self.chrome_options.add_argument("--headless")
        #self.chrome_options.add_argument("--disable-gpu")
        #self.chrome_options.add_argument("--remote-debugging-port=9222")
        #self.chrome_options.add_argument("--proxy-server='direct://'")
        #chrome_options.add_argument("--proxy-server=")
        #self.chrome_options.add_argument("--proxy-bypass-list=*")
        #self.chrome_options.add_argument("--proxy-server='direct://'")
        #self.chrome_options.add_argument("--proxy-bypass-list=*")
        #self.chrome_options.add_argument("--start-maximized")
        #self.chrome_options.add_argument('--disable-dev-shm-usage')
        #self.chrome_options.add_argument('--no-sandbox')
        #self.chrome_options.add_argument("--allow-insecure-localhost")
        #chrome_options.add_argument('disable-infobars')
        #self.chrome_options.add_argument('--no-proxy-server')
        #self.chrome_options.add_argument('--enable-logging=stderr')

        self.driver = None


        #self.login_page = LoginPage(self.driver)
        #self.signup_page = SignupPage(self.driver)
        #self.compute_page = ComputePage(self.driver)
        #self.flavors_page = FlavorsPage(self.driver)
        #self.cloudlets_page = CloudletsPage(self.driver)
        #self.apps_page = AppsPage(self.driver)
        #self.new_flavor_page = NewFlavorSettingsPage(self.driver)
        #self.new_cloudlet_page = NewCloudletSettingsPage(self.driver)
        #self.cloudlet_details_page = CloudletDetailsPage(self.driver)

        self.main_page = None
        self.apps_page = None
        self.login_page = None
        self.signup_page = None
        self.compute_page = None
        self.flavors_page = None
        self.cloudlets_page = None
        self.cluster_instances_page = None
        self.app_instances_page = None
        self.new_flavor_page = None
        self.new_cloudlet_page = None
        self.organizations_page = None
        self.new_organization_page = None
        self.cloudlet_details_page = None
        self.cluster_details_page = None
        self.organization_details_page = None
        self._init_shared_variables()

    def open_browser(self):
        self.driver = webdriver.Chrome(chrome_options=self.chrome_options)
        self.driver.maximize_window()
        #self.driver = webdriver.Firefox(executable_path=geckodriver, firefox_options=firefox_options)

        self.driver.get(self.url)

        self.base_page = BasePage(self.driver)
        self.main_page = MainPage(self.driver)
        self.apps_page = AppsPage(self.driver)
        self.login_page = LoginPage(self.driver)
        self.users_page = UsersPage(self.driver)
        self.signup_page = SignupPage(self.driver)
        self.details_page = DetailsPage(self.driver)
        self.compute_page = ComputePage(self.driver)
        self.flavors_page = FlavorsPage(self.driver)
        self.new_users_page = NewUsersPage(self.driver)
        self.cloudlets_page = CloudletsPage(self.driver)
        self.accounts_page = AccountsSettingsPage(self.driver)
        self.accounts_details_page = AccountsDetailsPage(self.driver)
        self.app_instances_page = AppInstancesPage(self.driver)
        self.organizations_page = OrganizationsPage(self.driver)
        self.new_flavor_page = NewFlavorSettingsPage(self.driver)
        self.new_cloudlet_page = NewCloudletSettingsPage(self.driver)
        self.cloudlet_details_page = CloudletDetailsPage(self.driver)
        self.cluster_details_page = ClusterDetailsPage(self.driver)
        self.cluster_instances_page = ClusterInstancesPage(self.driver)
        self.new_clusterinst_page = NewClusterInstSettingsPage(self.driver)
        self.new_apps_page = NewAppsSettingsPage(self.driver)
        self.new_appinst_page = NewAppInstSettingsPage(self.driver)
        self.new_organization_page = NewOrganizationSettingsPage(self.driver)
        self.organization_details_page = OrganizationDetailsPage(self.driver)
        self.apps_details_page = AppsDetailsPage(self.driver)
        self.autoscalepolicy_page = AutoScalePolicyPage(self.driver)
        self.new_autoscalepolicy_page = NewAutoScalePolicyPage(self.driver)
        self.privacy_policy_page = PrivacyPolicyPage(self.driver)
        self.new_privacy_policy_page = NewPrivacyPolicyPage(self.driver)

    # Change browser to 'Chrome'/'Firefox' when desired
    def login_to_mex_console(self, browser='Chrome', username=None, password=None, enter_key=False, use_defaults=True):
        self.take_screenshot('loginpage_pre')

        self.username = username
        self.password = password

        assert 'MobiledgeX Console' in self.driver.title, 'Page title is not correct'

        #login_page = LoginPage(self.driver)
        #login_validation_text = login_page.get_login_validation_text()
        #print('*WARN*', 'logintext1', login_validation_text)

        if self.login_page.are_elements_present():
            logging.info('login page verification succeeded')
        else:
            raise Exception('login page verification failed')

        #if username: self.login_page.username = username
        #if password: self.login_page.password = password

        if use_defaults:
            if username is None: self.username = shared_variables_mc.username_default
            if password is None: self.password = shared_variables_mc.password_default

        self.login_page.username = self.username
        self.login_page.password = self.password
        logging.info(f'login with username={self.username} password={self.password}')

        if enter_key:
            logging.info('logging in with ENTER key')
            self.login_page.hit_enter_key()
        else:
            logging.info('logging in with Login button')
            self.login_page.click_login_button()

        if self.login_page.is_alert_box_present():
            alert_text = self.login_page.get_alert_box_text()
            logging.error(f'alert present box present with text={alert_text}')
            self.take_screenshot('loginpage_alert')
            raise Exception(alert_text)
        else:
            logging.info('login alert box not found')

        if self.login_page.is_login_validation_present():
            login_validation_text = self.login_page.get_login_validation_text()
            if login_validation_text:
                logging.error(f'login validation text present with text={login_validation_text}')
                self.take_screenshot('login_validation')
                raise Exception(login_validation_text)
            else:
                logging.info('login validation text not present')
        else:
            logging.info('login validation not present')

        #if self.main_page.are_elements_present(username):
        #    logging.info('main page verification succeeded')
        #else:
        #    self.take_screenshot('loginpage_verify_fail')
        #    raise Exception('main page verification failed')

        self.take_screenshot('loginpage_post')

    def logout_of_account(self):
        self.take_screenshot('logout_pre')
        self.main_page.click_logout_button()


    def open_signup(self):
        self.take_screenshot('open_signup_pre')

        self.login_page.click_signup_switch_button()

        if self.signup_page.are_elements_present():
            logging.info('click signup button verification succeeded')
        else:
            raise Exception('click signup button verification failed')

        self.take_screenshot('open_signup_post')

    def signup_new_user(self, username=None, account_password=None, email_password=None, email_address=None, confirm_password=None, server='imap.gmail.com', use_defaults=True):
        self.take_screenshot('signup_new_user_pre')

        if use_defaults:
            confirm_password = account_password

        if username: self.signup_page.username = username
        if account_password: self.signup_page.password = account_password
        if confirm_password: self.signup_page.confirm_password = confirm_password
        if email_address: self.signup_page.email = email_address

        self.take_screenshot('signup_new_user_post')
        self.signup_page.click_signup_button()

        logging.info(f'checking email with email={email_address} password={email_password}')
        mail = imaplib.IMAP4_SSL(server)
        mail.login(email_address, email_password)
        mail.select('inbox')
        self._mail = mail
        logging.info('login successful')

        status, email_list_pre = mail.search(None, '(SUBJECT "Welcome to MobiledgeX!")')
        mail_ids_pre = email_list_pre[0].split()
        num_emails_pre = len(mail_ids_pre)
        self._mail_count = num_emails_pre
        logging.info(f'number of emails pre is {num_emails_pre}')

        if self.signup_page.is_alert_box_present():
            if self.signup_page.get_alert_box_text() != f'Please validate captcha':
                raise Exception('user created alert box not found. got ' + self.signup_page.get_alert_box_text())

        shared_variables_mc.username_default = username

        self._newuser_username = username
        self._newuser_password = email_password
        self._newuser_email = email_address

        #self.signup_page.click_signup_button()

        #if self.signup_page.is_alert_box_present():
        #    if self.signup_page.get_alert_box_text() != f'User {username} created successfully':
        #        raise Exception('user created alert box not found. got ' + self.signup_page.get_alert_box_text())

    def open_compute(self, role=None):
        self.take_screenshot('open_compute_pre')

        #self.main_page.click_compute_button()

        #self.take_screenshot('compute_clicked')

        if self.compute_page.are_elements_present(self.username, role=role):
            logging.info('compute page verification succeeded')
        else:
            raise Exception('compute page verification failed')
        #self.compute_page.click_i_icon()

        time.sleep(3)


    #def get_organization_data(self):
    #    self.take_screenshot('get_organization_pre')

    #    rows = self.compute_page.get_table_rows()
    #    for r in rows:
    #        print('*WARN*', 'r', r)

    def open_organizations(self, contains_organizations=True, change_rows_per_page=False):
        self.take_screenshot('open_organizations_pre')

        if contains_organizations:
            self.compute_page.click_organizations()
       
        if change_rows_per_page:
            self.compute_page.org_rows_per_page()

        if self.compute_page.is_table_heading_present('Organizations'):
            logging.info('organization heading present')
        else:
            raise Exception('organization heading not present')

        if contains_organizations:
            if self.organizations_page.is_organizations_table_header_present():
                logging.info('organization table header present')
            else:
                raise Exception('organization header not present')

        #time.sleep(3)  # wait for table to load. maybe a better way to do this

        self.take_screenshot('open_organizations_post')

    def open_users(self):
        self.take_screenshot('open_users_pre')
        self.compute_page.click_users()

        #if self.compute_page.is_table_heading_present('Users'):
        #    logging.info('user heading present')
        #else:
        #    raise Exception('user heading not present')
        # Will need to upgrade compute_page is table heading to have just Users
        # and then the 2 search boxes. if label != Users (everything else. Not pretty but)
        time.sleep(1)
        if self.users_page.is_users_table_header_present():
            logging.info('user table header present')
        else:
            raise Exception('user header not present')

    def open_accounts(self):
        self.take_screenshot('open_accounts_pre')
        self.compute_page.click_accounts()

        if self.accounts_page.is_accounts_table_header_present():
            logging.info('Account table header present')
        else:
            raise Exception('An Account header not present')
        #if self.compute_page.is_table_heading_present('Accounts'):
        #    logging.info('Accounts heading present')
        #else:
        #    raise Exception('Accounts heading not present')
        #if self.users_page.is_users_table_header_present():
        #    logging.info('user table header present')
        #else:
        #    raise Exception('user header not present')

    def open_accounts_page(self):
        self.take_screenshot('open_accounts_pre')
        self.compute_page.click_accounts()
    

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
            raise Exception('flavor table header not present')

        time.sleep(3)  # wait for table to load. maybe a better way to do this

        self.take_screenshot('open_flavors_post')

    def open_flavors_page(self):
        self.take_screenshot('open_flavors_pre')
    
        self.compute_page.click_flavors()

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

    def open_cloudlets_page(self):
        self.take_screenshot('open_cloudlets_pre')
    
        self.compute_page.click_cloudlets()

    def open_cluster_instances(self):

        time.sleep(3)

        self.take_screenshot('open_clustinsts_pre')

        self.compute_page.click_cluster_instances()
        time.sleep(3)

        if self.compute_page.is_table_heading_present('Cluster Instances'):
            logging.info('cluster instances heading present')
        else:
            raise Exception('cluster instances heading not present')

        if self.cluster_instances_page.is_cluster_instances_table_header_present():
            logging.info('cluster instances table header present')
        else:
            raise Exception('cluster instances header not present')

        time.sleep(3)  # wait for table to load. maybe a better way to do this

        self.take_screenshot('open_cluster_instances_post')

    def open_cluster_instances_page(self):
        self.take_screenshot('open_clustinsts_pre')
    
        self.compute_page.click_cluster_instances()
 
    def open_policies(self):
        self.take_screenshot('open_policies_pre')

        self.compute_page.click_policies()

    def open_autoscalepolicy(self):
        self.compute_page.click_autoscalepolicy()

    def open_trustpolicy(self):
        self.compute_page.click_trustpolicy()

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
            raise Exception('apps table header not present')

        time.sleep(3)  # wait for table to load. maybe a better way to do this

        self.take_screenshot('open_apps_post')

    def open_apps_page(self):
        self.take_screenshot('open_apps_pre')
    
        self.compute_page.click_apps()

    def open_app_instances(self):
        self.take_screenshot('open_appinsts_pre')

        self.compute_page.click_app_instances()

        if self.compute_page.is_table_heading_present('App Instances'):
            logging.info('app instances heading present')
        else:
            raise Exception('app instances heading not present')

        if self.app_instances_page.is_app_instances_table_header_present():
            logging.info('app instances table header present')
        else:
            raise Exception('app instances header not present')

        time.sleep(3)  # wait for table to load. maybe a better way to do this

        self.take_screenshot('open_app_instances_post')

    def open_app_instances_page(self):
        self.take_screenshot('open_appinsts_pre')

        self.compute_page.click_app_instances()


    def add_new_organization(self, organization_name=None, address=None, phone=None, organization_type=None):
        self.take_screenshot('add_new_organization_pre')

        if organization_type is not None:
            if organization_type == "Developer":
                self.compute_page.click_developer_org()
            else:
                self.compute_page.click_operator_org()
        else:
            raise Exception('Type of organization not specified')

        #self.compute_page.click_new_button()

        if self.new_organization_page.are_elements_present(organization_type):
            logging.info('click New Organization button verification succeeded')
        else:
            raise Exception('click New Organization button verification failed')

        org = Organization(organization_name=organization_name, phone=phone, address=address, organization_type=organization_type).organization
        logging.info(f'Adding new organinzation organization={org["name"]} address={org["address"]} phone={org["phone"]} type={org["type"]}')

        #self._cloudlet = cloudlet
        #self._region = region
        #print('*WARN*', 'cloudlet', cloudlet)

        #self.new_organization_page.create_organization(organization_name=org['name'], organization_type=org['type'], phone=org['phone'], address=org['address'])
        self.new_organization_page.create_organization(organization_name=org['name'], phone=org['phone'], address=org['address'])

        if self.compute_page.is_alert_box_present(timeout=20):
            if self.compute_page.get_alert_box_text() != 'Organization ' + org['name'] + ' created successfully':
                raise Exception('Success alert box not found. got ' + self.compute_page.get_alert_box_text())
        else:
            raise Exception('Success alert box not found')

        self.take_screenshot('add_new_organization_post')

    def organization_should_exist(self, organization=None, type=None, phone=None, address=None, wait=5):
        self.take_screenshot('organization_should_exist_pre')

        if self.organizations_page.wait_for_organization(organization=organization, type=type, phone=phone, address=address, wait=wait):
            logging.info(f'organization={organization} found')
        else:
            raise Exception(f'organization={organization} NOT found')

    def verify_instructions(self, orgtype=None, organization=None):
        variable = "EMPTY"
        if orgtype is not None:
            if orgtype == "operator":
                return variable
            else:
                if self.organization_details_page.verify_instructions(organization=organization):
                    logging.info(f'instructions found for organization={organization}')
                    variable = "True"
                    return variable
                else:
                    logging.info(f'instructions not found for organization={organization}')
                    variable = "False"
                    return variable

    def open_organization_details(self, organization):
        self.compute_page.click_organizations()
        self.change_number_of_rows()
        logging.info('Opening organization details for organization=' + organization)

        self.organizations_page.click_organization_row(organization=organization)

        if self.organization_details_page.are_elements_present(organization=organization):
            logging.info('organization details page verification succeeded')
        else:
            raise Exception('organization details page verification failed')

        details = self.organization_details_page.get_details()
        logging.info('andy')
        return details

    def close_organization_details(self):
        self.details_page.click_close_button()

    def select_organization(self, organization=None):
        if organization != None:
            self.organizations_page.click_user_check(organization=organization)
        else:
            self.organizations_page.click_user_check()

    def organizations_menu_should_exist(self):
        self.organizations_page.organizations_menu_should_exist()

    def new_button_should_be_enabled(self):
        is_enabled = self.compute_page.get_new_button_status()
        print('*WARN*', 'newbutton', is_enabled)
        if not is_enabled:
            logging.info('new button is disabled')
        else:
            raise Exception('new button is enabled')

    def organization_new_button_should_be_enabled(self):
        #is_enabled = self.organizations_page.get_add_user_button_status()
        #print('*WARN*', 'newbutton', is_enabled)
        #if not is_enabled:
        #    logging.info('user button is disabled')
        #else:
        #    raise Exception('user button is enabled')

        self.organizations_page.organization_new_button_should_be_enabled()

    def organization_manage_button_should_be_enabled(self):
        self.organizations_page.organization_manage_button_should_be_enabled()

    def organization_add_user_button_should_be_enabled(self):
        self.organizations_page.organization_add_user_button_should_be_enabled()

    def organization_add_user_button_should_be_disabled(self):
        is_enabled = self.organizations_page.get_add_user_button_status()
        print('*WARN*', 'newbutton', is_enabled)
        if not is_enabled:
            logging.info('user button is disabled')
        else:
            raise Exception('user button is enabled')
        #self.organizations_page.organization_add_user_button_should_be_disabled()

    def organization_trash_icon_should_be_enabled(self):
        self.organizations_page.organization_trash_icon_should_be_enabled()

    def organization_trash_icon_should_be_disabled(self):
        is_enabled = self.organizations_page.get_trash_button_status()
        print('*WARN*', 'trashbutton', is_enabled)
        if not is_enabled:
            logging.info('trash button is disabled')
        else:
            raise Exception('trash button is enabled')

        #self.organizations_page.organization_trash_icon_should_be_disabled()

    def organizations_menu_should_not_exist(self):
        self.organizations_page.organizations_menu_should_not_exist()

    def users_menu_should_exist(self):
        self.users_page.users_menu_should_exist()

    def users_menu_should_not_exist(self):
        self.users_page.users_menu_should_not_exist()

    def users_trash_icon_should_be_disabled(self):
        self.users_page.users_trash_icon_should_be_disabled()

    def users_trash_icon_should_be_enabled(self):
        self.users_page.users_trash_icon_should_be_enabled()

    def cloudlet_menu_should_exist(self):
        self.cloudlets_page.cloudlets_menu_should_exist()

    def cloudlet_menu_should_not_exist(self):
        self.cloudlets_page.cloudlets_menu_should_not_exist()

    def cloudlet_new_button_should_be_enabled(self):
        self.cloudlets_page.cloudlets_new_button_should_be_enabled()

    def cloudlet_new_button_should_be_disabled(self):
        self.cloudlets_page.cloudlets_new_button_should_be_disabled()

    def cloudlet_trash_icon_should_be_enabled(self):
        self.cloudlets_page.cloudlets_trash_icon_should_be_enabled()

    def cloudlet_trash_icon_should_be_disabled(self):
        self.cloudlets_page.cloudlets_trash_icon_should_be_disabled()

    def flavor_menu_should_exist(self):
        self.flavors_page.flavors_menu_should_exist()

    def flavor_menu_should_not_exist(self):
        self.flavors_page.flavors_menu_should_not_exist()

    def flavor_new_button_should_be_enabled(self):
        self.flavors_page.flavors_new_button_should_be_enabled()
    
    def flavor_new_button_should_be_disabled(self):
        self.flavors_page.flavors_new_button_should_be_disabled()

    def flavor_trash_icon_should_be_enabled(self):
        self.flavors_page.flavors_trash_icon_should_be_enabled()

    def flavor_trash_icon_should_be_disabled(self):
        self.flavors_page.flavors_trash_icon_should_be_disabled()

    def cluster_instances_menu_should_exist(self):
        self.cluster_instances_page.clustersInst_menu_should_exist()

    def cluster_instances_menu_should_not_exist(self):
        self.cluster_instances_page.clustersInst_menu_should_not_exist()

    def cluster_instances_new_button_should_be_enabled(self):
        self.cluster_instances_page.clusterInst_new_button_should_be_enabled()

    def cluster_instances_new_button_should_be_disabled(self):
        self.cluster_instances_page.clusterInst_new_button_should_be_disabled()

    def cluster_instances_trash_icon_should_be_enabled(self):
        self.cluster_instances_page.clusterInst_trash_icon_should_be_enabled()

    def cluster_instances_trash_icon_should_be_disabled(self):
        self.cluster_instances_page.clusterInst_trash_icon_should_be_disabled()

    def apps_menu_should_exist(self):
        self.apps_page.apps_menu_should_exist()

    def apps_menu_should_not_exist(self):
        self.apps_page.apps_menu_should_not_exist()

    def apps_new_button_should_be_enabled(self):
        self.apps_page.apps_new_button_should_be_enabled()

    def apps_new_button_should_be_disabled(self):
        self.apps_page.apps_new_button_should_be_disabled()

    def apps_trash_icon_should_be_enabled(self):
        self.apps_page.apps_trash_icon_should_be_enabled()
    
    def apps_trash_icon_should_be_disabled(self):
        self.apps_page.apps_trash_icon_should_be_disabled()

    def app_instances_menu_should_exist(self):
        self.app_instances_page.appsInst_menu_should_exist()

    def app_instances_menu_should_not_exist(self):
        self.app_instances_page.appsInst_menu_should_not_exist()

    def app_instances_new_button_should_be_enabled(self):
        self.app_instances_page.appInst_new_button_should_be_enabled()

    def app_instances_new_button_should_be_disabled(self):
        self.app_instances_page.appInst_new_button_should_be_disabled()

    def app_instances_trash_icon_should_be_enabled(self):
        self.app_instances_page.appInst_trash_icon_should_be_enabled()

    def app_instances_trash_icon_should_be_disabled(self):
        self.app_instances_page.appInst_trash_icon_should_be_disabled()

    def add_new_organization_user(self, username=None, organization=None, role=None, flag=None):
        logging.info('Adding user to organization=' + organization)
        if role == None:
            role = 'Contributor'

        if flag == 'after_org_create':
            self.new_users_page.click_skip()
            self.new_users_page.click_return_to_org()
            self.new_users_page.add_organization_user(username=username, organization=organization, role=role, flag=flag)
            self.verify_alert_box(username)
            self.new_users_page.click_close()
        else:
            self.new_users_page.add_organization_user(username=username, organization=organization, role=role, flag=flag)
            self.verify_alert_box(username)
            self.new_users_page.click_skip()
            self.new_users_page.click_return_to_org()

        self.compute_page.click_manage()
        self.take_screenshot('add_new_user_to_organization_post')

    def verify_alert_box(self, username):
        # Add check for the "new user added successfully"
        if self.compute_page.is_alert_box_present():
            if self.compute_page.get_alert_box_text() != 'User ' + username + ' added successfully':
                raise Exception('Success alert box not found. got ' + self.compute_page.get_alert_box_text())
            logging.info('Success alert box found:' + self.compute_page.get_alert_box_text())
        else:
            raise Exception('Success alert box not found')

    def sort_organization_name(self, count):
        count = int(count)
        while count != 0:
            self.organizations_page.click_organization_name()
            count -= 1
            time.sleep(1)

    def sort_organization_type(self, count):
        count = int(count)
        while count != 0:
            self.organizations_page.click_organization_type()
            count -= 1
            time.sleep(1)

    def add_new_flavor(self, region=None, flavor_name=None, ram=None, vcpus=None, disk=None, decision=None):
        self.take_screenshot('add_new_flavor_pre')
        if decision != None:
            decision = decision.lower()
        self.compute_page.click_add_button()
        if self.new_flavor_page.are_elements_present():
            logging.info('click New Flavor button verification succeeded')
        else:
            raise Exception('click New Flavor button verification failed')
        # this function are_elements_present doesnt work for flavor page yet. Will create!!!

        flavor = Flavor(flavor_name=flavor_name, ram=ram, vcpus=vcpus, disk=disk).flavor
        logging.info(f'flavor created:{flavor}')
        self._flavor = flavor
        self._region = region
        shared_variables_mc.region_default = region
        
        if (decision == 'no' or decision == "dont"):
            print('*WARN*', 'Not Creating flavor ', flavor)
            self.new_flavor_page.dont_create_flavor(region, flavor['key']['name'], flavor['ram'], flavor['vcpus'], flavor['disk'])
            time.sleep(3)
            self.take_screenshot('didnt_add_new_flavor_post')
        elif (decision == 'test' or decision == "testing"):
            print('*WARN*', 'Attempting to create bad flavor ', flavor)
            self.new_flavor_page.dont_create_flavor(region, flavor['key']['name'], flavor['ram'], flavor['vcpus'], flavor['disk'])
            time.sleep(3)
            self.take_screenshot('flavor_failed_expected')
        else:
            logging.info(f'Adding new flavor region={region} flavor_name={flavor["key"]["name"]}  ram={flavor["ram"]}  vcpus={flavor["vcpus"]}  disk={flavor["disk"]}')
            self.new_flavor_page.create_flavor(region=region, flavor_name=flavor['key']['name'], ram=flavor['ram'], vcpus=flavor['vcpus'], disk=flavor['disk'])
            time.sleep(3)
            self.take_screenshot('add_new_flavor_post')

            if self.compute_page.is_alert_box_present():
                if self.compute_page.get_alert_box_text() != 'Flavor ' + flavor['key']['name'] + ' created successfully':
                    raise Exception('SUCCESS alert box not found. got ' + self.compute_page.get_alert_box_text())
            else:
                raise Exception('success alert box not found')
  
    def change_number_of_rows(self):
        self.flavors_page.flavor_rows_per_page()

    def flavor_should_exist(self, region=None, flavor_name=None, ram=None, vcpus=None, disk=None, wait=5, change_rows_per_page=False, number_of_pages=None):
        if change_rows_per_page:
            self.flavors_page.flavor_rows_per_page()
        if number_of_pages is None:
            number_of_pages = 1
        logging.info('number of pages is ' + str(number_of_pages))
        self.take_screenshot('flavor_should_exist_pre')
        logging.info(f'flavor_should_exist region={region} flavor={flavor_name} ram={ram} vcpus={vcpus} disk={disk} wait={wait}')

        if region is None: region = self._region
        if flavor_name is None: flavor_name = self._flavor['key']['name']
        if ram is None: ram = self._flavor['ram']
        if vcpus is None: vcpus = self._flavor['vcpus']
        if disk is None: disk = self._flavor['disk']

        self.flavors_page.perform_search(flavor_name)
        if self.flavors_page.wait_for_flavor(region, flavor_name, ram, vcpus, disk, number_of_pages):
            logging.info('Flavor found')
        else:
            raise Exception('Flavor NOT found')


    def flavor_should_not_exist(self, region=None, flavor_name=None, ram=None, vcpus=None, disk=None, wait=5):
        self.take_screenshot('flavor_should_not_exist_pre')
        logging.info(f'flavor_should_not_exist region={region} flavor={flavor_name} ram={ram} vcpus={vcpus} disk={disk} wait={wait}')

        if region is None: region = self._region
        if flavor_name is None: flavor_name = self._flavor['key']['name']
        if ram is None: ram = self._flavor['ram']
        if vcpus is None: vcpus = self._flavor['vcpus']
        if disk is None: disk = self._flavor['disk']

        self.flavors_page.perform_search(flavor_name)
        if self.flavors_page.wait_for_flavor(region, flavor_name, ram, vcpus, disk, 1):
            raise Exception('Flavor found. Expected to be not found')
        else:
            logging.info('Flavor not found as expected')


    def open_flavor_details(self, flavor_name, region='US'):
        index = 0
        k = 0
        self.change_number_of_rows()
        logging.info('Opening flavor details for flavorname=' + flavor_name)

        for i in range(2):
            if self.flavors_page.click_flavor_row(flavor_name=flavor_name, region=region):
                k += 1
                break

        if k == 0:
           index += 1
           self.flavors_page.click_next_page()
           for j in range(2):
               if self.flavors_page.click_flavor_row(flavor_name=flavor_name, region=region):
                   break

        if self.flavors_page.are_flavor_details_present():
            logging.info('Flavor details page verification succeeded')
        else:
            raise Exception('Flavor details page verification failed')

        #details = self.organization_details_page.get_details()
        details = self.details_page.get_details()
     
        if (index>0):
            self.flavors_page.click_close_flavor_details()
            self.flavors_page.click_previous_page()

        return details

    def close_flavor_details(self):
        #self.flavors_page.click_close_flavor_details()
        self.details_page.click_close_button()

    def find_number_of_pages(self):
        pages = self.base_page.find_number_of_pages()
        return pages

    def find_number_of_entries(self):
        entries = self.base_page.find_number_of_entries()
        return entries

    def delete_flavor(self, region=None, flavor_name=None, ram=None, vcpus=None, disk=None, decision=None, number_of_pages=None, click_previous_page=None):

        if region is None: region = self._region
        if flavor_name is None: flavor_name = self._flavor['key']['name']
        if ram is None: ram = self._flavor['ram']
        if vcpus is None: vcpus = self._flavor['vcpus']
        if disk is None: disk = self._flavor['disk']

        self.flavors_page.wait_for_flavor(region=region, flavor_name=flavor_name, ram=ram, vcpus=vcpus, disk=disk, number_of_pages=number_of_pages, click_previous_page=click_previous_page)
        logging.info(f'Deleting flavor region={region} flavor_name={flavor_name} ram={ram} vcpus={vcpus} disk={disk}')
        self.take_screenshot('delete_flavor_pre')

        self.flavors_page.delete_flavor(region=region, flavor_name=flavor_name, ram=ram, vcpus=vcpus, disk=disk, decision=decision)

        time.sleep(1)
        if decision != 'no':
            if self.compute_page.is_alert_box_present():
                logging.info('alert box present')
                if self.compute_page.get_alert_box_text() != 'Flavor ' + flavor_name + ' deleted successfully':
                    raise Exception('delete alert box not found. got ' + self.compute_page.get_alert_box_text())
            else:
                raise Exception('delete alert box not found')
        else:
            logging.info('not checking for alert box')

        #time.sleep(2)  # wait for table to show again

    def sort_flavors_by_region(self):
        self.flavors_page.click_flavorRegion()

    def order_flavor_names(self, count):
        logging.info('Sorting flavors alphabetically')
        count = int(count)
        while count != 0:
            self.flavors_page.click_flavorName()
            count -= 1
            time.sleep(1)

        self.take_screenshot('Flavor table sorted')

    def order_flavor_ram(self, count):
        logging.info('Sorting flavors numerically by ram')
        count = int(count)
        while count != 0:
            self.flavors_page.click_flavorRAM()
            count -= 1
            time.sleep(1)

    def order_flavor_vcpus(self, count):
        logging.info('Sorting flavors numerically by vcpus')
        count = int(count)
        while count != 0:
            self.flavors_page.click_flavorVCPUS()
            count -= 1
            time.sleep(1)

    def order_flavor_disk(self, count):
        logging.info('Sorting flavors numerically by disk')
        count = int(count)
        while count != 0:
            self.flavors_page.click_flavorDisk()
            count -= 1
            time.sleep(1)

    def update_cloudlet(self, region=None, cloudlet_name=None, operator=None, latitude=None, longitude=None, number_dynamic_ips=None, maintenance_state=None, trust_policy=None):
        if region is None: region = self._region
        if cloudlet_name is None: cloudlet_name = self._cloudlet['key']['name']
        if operator is None: operator = self._cloudlet['key']['organization'] 

        logging.info(f'Updating cloudlet region={region} cloudlet_name={cloudlet_name} operator={operator}')

        if self.new_cloudlet_page.update_cloudlet(region=region, cloudlet_name=cloudlet_name, operator=operator, latitude=latitude, longitude=longitude, number_dynamic_ips=number_dynamic_ips, maintenance_state=maintenance_state, trust_policy=trust_policy):
            if maintenance_state == 'Maintenance Start' or maintenance_state == 'Maintenance Start No Failover':
                if self.compute_page.wait_for_dialog_box(text="Cloudlet is in maintenance", wait=60):
                    time.sleep(2)
                    self.new_cloudlet_page.close_alert_box()
                    logging.info(f'Cloudlet {cloudlet_name} updated successfully')
                else:
                    raise Exception('Dialog box text not found')  
            elif maintenance_state == 'Normal Operation':
                if self.compute_page.is_alert_box_present():
                    if self.compute_page.get_alert_box_text() != 'Cloudlet updated successfully':
                        raise Exception('SUCCESS alert box not found. got ' + self.compute_page.get_alert_box_text())  
                else:
                    raise Exception('success alert box not found')
            elif trust_policy is not None:
                if trust_policy == 'RemovePolicy':
                    if self.compute_page.wait_for_dialog_box(text=f'Successful TrustPolicy: Update for Cloudlet: organization:"{operator}" name:"{cloudlet_name}"', wait=60):
                        time.sleep(2)
                        self.new_cloudlet_page.close_alert_box()
                        logging.info(f'Cloudlet {cloudlet_name} updated successfully')
                    else:
                        raise Exception('Dialog box text not found')
                else:
                    if self.compute_page.wait_for_dialog_box(text=f'Successful TrustPolicy: {trust_policy} Update for Cloudlet: organization:"{operator}" name:"{cloudlet_name}"', wait=60):
                        time.sleep(2)
                        self.new_cloudlet_page.close_alert_box()
                        logging.info(f'Cloudlet {cloudlet_name} updated successfully')
                    else:
                        raise Exception('Dialog box text not found')
            else:
                if self.compute_page.wait_for_dialog_box(text="Cloudlet updated successfully", wait=60):
                    time.sleep(2)
                    self.new_cloudlet_page.close_alert_box()
                    logging.info(f'Cloudlet {cloudlet_name} updated successfully')
                else:
                    raise Exception('Dialog box text not found')
        else:
            raise Exception(f'Cloudlet {cloudlet_name} updation failed')

    def add_new_cloudlet(self, region=None, cloudlet_name=None, operator=None, latitude=None, longitude=None, ip_support=None, number_dynamic_ips=None, physical_name=None, platform_type=None, infra_api_access=None, trust_policy=None):
        if infra_api_access is None:
            mode = 'Direct'
        else:
            mode = 'Restricted'

        self.take_screenshot('add_new_cloudlet_pre')

        self.compute_page.click_add_button()
        self.take_screenshot('add_new_cloudlet_clicked')
        if self.new_cloudlet_page.are_elements_present():
            logging.info('click New Cloudlet button verification succeeded')
        else:
            raise Exception('click New Cloudlet button verification failed')

        cloudlet = Cloudlet(cloudlet_name=cloudlet_name, operator_org_name=operator, latitude=latitude, longitude=longitude, ip_support=ip_support, number_dynamic_ips=number_dynamic_ips, physical_name=physical_name, platform_type=platform_type).cloudlet
        self._cloudlet = cloudlet
        self._region = region
        print('*WARN*', 'cloudlet', cloudlet)
        logging.info(f"Adding new cloudlet region={region} cloudlet_name={cloudlet['key']['name']} operator={cloudlet['key']['organization']} latitude={cloudlet['location']['latitude']} longitude={cloudlet['location']['longitude']} ip_support={cloudlet['ip_support']} number_dynamic_ips={cloudlet['num_dynamic_ips']} physical_name={cloudlet['physical_name']} platform_type={cloudlet['platform_type']} infra_api_access={mode} trust_policy={trust_policy}")
        self.new_cloudlet_page.create_cloudlet(region=region, cloudlet_name=cloudlet['key']['name'], operator_name=cloudlet['key']['organization'], latitude=cloudlet['location']['latitude'], longitude=cloudlet['location']['longitude'], ip_support=cloudlet['ip_support'], number_dynamic_ips=cloudlet['num_dynamic_ips'], physical_name=cloudlet['physical_name'], platform_type=cloudlet['platform_type'], infra_api_access=mode, trust_policy=trust_policy)
   
        if mode == 'Direct':
            if self.compute_page.wait_for_dialog_box(text="Waiting for run lists to be executed on Platform Server", wait=300):
                self.new_cloudlet_page.close_alert_box()
            else:
                raise Exception('Dialog box test NOT found')
        else:
            self.compute_page.wait_for_dialog_box(text="Cloudlet configured successfully, please wait requesting cloudlet manifest to bring up Platform VM(s) for cloudlet service", wait=60)
            if self.new_cloudlet_page.get_cloudlet_manifest(cloudlet_name=cloudlet['key']['name']):
                logging.info('Cloudlet Manifest displayed')
                self.new_cloudlet_page.close_manifest()
            else:
                raise Exception('Cloudlet Manifest NOT displayed')

        #if self.compute_page.wait_for_alert_box(text='Cloudlet ' + cloudlet['key']['name'] + ' created successfully', wait=120):
        #    logging.info('Cloudlet success alert box not found')
        #else:
        #    raise Exception('Cloudl success alert box NOT found')
            
        #time.sleep(5)

        #if self.compute_page.is_alert_box_present():
           # if self.compute_page.get_alert_box_text() != 'Cloudlet ' + cloudlet['key']['name'] + ' created successfully':
               # raise Exception('SUCCESS alert box not found. got ' + self.compute_page.get_alert_box_text())
        #else:
           # raise Exception('Success alert box not found')

        #self.take_screenshot('add_new_cloudlet_post')

    def search_cloudlet(self, cloudlet_name=None):
        if cloudlet_name is None: cloudlet_name = self._cloudlet['key']['name']
        self.new_cloudlet_page.search_cloudlet(cloudlet_name=cloudlet_name)

    def cloudlet_should_exist(self, region=None, cloudlet_name=None, operator_name=None, latitude=None, longitude=None, state=None):
        self.take_screenshot('cloudlet_should_exist_pre')

        if region is None: region = self._region
        if cloudlet_name is None: cloudlet_name = self._cloudlet['key']['name']
        if operator_name is None: operator_name = self._cloudlet['key']['organization']
        if state is None: state = '5'
        #if latitude is None: latitude = self._cloudlet['location']['latitude']
        #if longitude is None: longitude = self._cloudlet['location']['longitude']

        self.refresh_page()
        logging.info(f'cloudlet_should_exist {region} {cloudlet_name} {operator_name} {latitude} {longitude} {state}')

        if self.cloudlets_page.wait_for_cloudlet(region=region, cloudlet_name=cloudlet_name, operator=operator_name, latitude=latitude, longitude=longitude, state=state, wait=30):
            logging.info(f'cloudlet={cloudlet_name} found')
        else:
            raise Exception(f'cloudlet={cloudlet_name} NOT found')

    def cloudlet_should_not_exist(self, region=None, cloudlet_name=None, operator_name=None):  
        self.take_screenshot('cloudlet_should_not_exist_pre')

        if region is None: region = self._region
        if cloudlet_name is None: cloudlet_name = self._cloudlet['key']['name']
        if operator_name is None: operator_name = self._cloudlet['key']['organization']
        #if latitude is None: latitude = self._cloudlet['location']['latitude']
        #if longitude is None: longitude = self._cloudlet['location']['longitude']
        #logging.info(f'cloudlet_should_not_exist {region} {cloudlet_name} {operator} {latitude} {longitude}')

        self.refresh_page()
        logging.info(f'cloudlet_should_not_exist {region} {cloudlet_name} {operator_name}')

        #if self.cloudlets_page.wait_for_cloudlet(region=region, cloudlet_name=cloudlet_name, operator=operator, latitude=latitude, longitude=longitude):
        if self.cloudlets_page.wait_for_cloudlet(region=region, cloudlet_name=cloudlet_name, operator=operator_name, wait=1):
            raise Exception(f'cloudlet={cloudlet_name} found')
        else:
            logging.info(f'cloudlet={cloudlet_name} NOT found')

    def cloudlets_should_show_on_map(self, number_cloudlets):
        self.cloudlets_page.zoom_out_map(2)
        time.sleep(1)
        cloudlets = self.cloudlets_page.get_cloudlet_icon_numbers()
        if cloudlets == number_cloudlets:
            logging.info(f'number of cloudlet icons match. found {number_cloudlets} cloudlets')
        else:
            logging.error(f'didnot find all cloudlets. looking for {number_cloudlets} but found {cloudlets}')
            raise Exception('not all cloudlets found on map')

    #def click_cloudlet_icon(self, icon_number):

    def sort_cloudlets_by_cloudlet_name(self, count=1):
        for num in range(0,count):
            logging.info('clicking sort by cloudlet name')
            self.cloudlets_page.click_cloudlet_name_heading()

    def sort_cloudlets_by_region(self):
        self.cloudlets_page.click_region_heading()

    def close_cloudlet_details(self):
        self.details_page.click_close_button()

    def open_cloudlet_details(self, cloudlet_name=None, region=None):
        if region is None: region = self._region
        if cloudlet_name is None: cloudlet_name =  self._cloudlet['key']['name']
        self.change_number_of_rows()
        logging.info('Opening cloudlet details for cloudletname=' + cloudlet_name)

        self.cloudlets_page.click_cloudlet_row(cloudlet_name=cloudlet_name, region=region)
        time.sleep(1)
        self.take_screenshot('open_cloudlet_details')

        if self.cloudlet_details_page.are_elements_present(cloudlet_name=cloudlet_name):
            logging.info('cloudlet details page verification succeeded')
        else:
            raise Exception('cloudlet details page verification failed')

        details = self.details_page.get_details()

        return details

    def show_cloudlet_manifest(self, region=None, cloudlet_name=None, operator=None, option=None):
        self.take_screenshot('show_cloudlet_manifest_pre')

        if region is None: region = self._region
        if cloudlet_name is None: cloudlet_name = self._cloudlet['key']['name']
        if operator is None: operator = self._cloudlet['key']['organization']
        logging.info(f'Show Cloudlet Manifest region={region} cloudlet_name={cloudlet_name} operator={operator}')

        self.cloudlets_page.show_cloudlet_manifest(region=region, cloudlet_name=cloudlet_name, operator=operator)

        if self.compute_page.is_warning_box_present():
            if self.compute_page.get_warning_box_text() != 'Cloudlet has access key registered, click on yes if you would like to revoke the current access key, so a new one can be generated for the manifest':
                raise Exception('Failure alert box text NOT found. got ' + self.compute_page.get_warning_box_text())
        else:
            raise Exception('Failure alert box not found')

        if self.cloudlets_page.select_show_manifest_option(option=option):
            logging.info('Verified Show Manifest')
        else:
            raise Exception('Verfication of Show Manifest FAILED')

    def delete_cloudlet(self, region=None, cloudlet_name=None, operator=None):
        self.take_screenshot('delete_cloudlet_pre')

        if region is None: region = self._region
        if cloudlet_name is None: cloudlet_name = self._cloudlet['key']['name']
        if operator is None: operator = self._cloudlet['key']['organization']
        logging.info(f'Deleting cloudlet region={region} cloudlet_name={cloudlet_name} operator={operator}')

        self.cloudlets_page.delete_cloudlet(region=region, cloudlet_name=cloudlet_name, operator=operator)

        #if self.compute_page.is_alert_box_present():
        #    if self.compute_page.get_alert_box_text() != 'Cloudlet ' + cloudlet_name + ' deleted successfully.':
        #        raise Exception('delete alert box not found. got ' + self.compute_page.get_alert_box_text())
        #else:
        #    raise Exception('Delete alert box not found')

        #time.sleep(2)  # wait for table to show again

    def close_cloudlet_details(self):
        self.details_page.click_close_button()

    def add_new_cluster_instance(self, region=None, cluster_name=None, developer_name=None, operator_name=None, cloudlet_name=None, deployment=None, ip_access=None, flavor_name=None, number_masters=None, number_nodes=None, wait=None):
        #driver = webdriver.Chrome()
        #self.driver = driver
        self.take_screenshot('add_new_clusterinst_pre')

        wait = int(wait)

        self.compute_page.click_new_button()

        if self.new_clusterinst_page.are_elements_present():
            logging.info('click New Cluster Instance button verification succeeded')
        else:
            raise Exception('click New Cluster Instance button verification failed')

        clusterInst = ClusterInstance.create_cluster_instance(cluster_name=cluster_name, operator_org_name=operator_name, cloudlet_name=cloudlet_name, developer_org_name=developer_name, flavor_name=flavor_name, ip_access=ip_access, number_nodes = number_nodes, deployment = deployment)        
        self._clusterInst = clusterInst
        #logging.info('HERE')
        self._region = region

        logging.info(f'Adding new clusterInst region={region} cluster_name={cluster_name} operator_name={operator_name} developer_name={developer_name}  cloudlet_name={cloudlet_name} deployment={deployment}  ip_access={ip_access}  flavor_name={flavor_name}  number_nodes={number_nodes}  number_masters={number_masters}')
        self.new_clusterinst_page.create_clusterInst(region=region, cluster_name=clusterInst['key']['cluster_key']['name'], operator_name=clusterInst['key']['cloudlet_key']['operator_key']['name'], developer_name=clusterInst['key']['developer'], cloudlet_name =clusterInst['key']['cloudlet_key']['name'], deployment=clusterInst['deployment'], flavor_name=clusterInst['flavor']['name'], ip_access=ip_access, number_nodes=clusterInst['num_nodes'])

        self.take_screenshot('add_new_clusterinst_post')
        
        #self.compute_page.wait_for_alert_box(wait=wait)

        #for seconds in range(wait):
            #if self.compute_page.get_alert_box_text() == 'Cluster Instance created successfully':
                #raise Exception('SUCCESS alert box found')
           # else:
               # raise Exception('SUCCESS alert box not found. got ' + self.compute_page.get_alert_box_text())


        #wait = WebDriverWait(driver, 350)
        #element = wait.until(ec.alert_is_present())

    def cluster_should_exist(self, region=None, cluster_name=None, developer_name=None, operator_name=None, cloudlet_name=None, flavor_name=None, ip_access=None, wait=5):
        self.take_screenshot('cluster_should_exist_pre')

        wait = int(wait)

        if region is None: region = self._region
        if cluster_name is None: cluster_name = self._clusterInst['key']['cluster_key']['name']
        if operator_name is None: operator_name = self._clusterInst['key']['cloudlet_key']['operator_key']['name']
        if developer_name is None: developer_name= self._clusterInst['key']['developer']
        if cloudlet_name is None: cloudlet_name = self._clusterInst['key']['cloudlet_key']['name']
        if flavor_name is None: flavor_name= self._clusterInst['flavor']['name']
        if ip_access is None: ip_access=ip_access

        logging.info(f'cluster_should_exist region={region}  cluster_name={cluster_name}  developer_name={developer_name}  operator_name={operator_name}  cloudlet_name={cloudlet_name}  flavor_name={flavor_name}  ip_access={ip_access}')
        
        if self.cluster_instances_page.is_cluster_instance_present(region=region,  cluster_name=cluster_name,  developer_name=developer_name,  operator_name=operator_name,  cloudlet_name=cloudlet_name,  flavor_name=flavor_name,  ip_access=ip_access):
            logging.info(f'cluster={cluster_name} found') 
        else:
            raise Exception(f'cluster={cluster_name} NOT found')
        #time.sleep(450)
        #wait = WebDriverWait(driver, 10)
        #element = wait.until(ec.self.self.compute_page.is_alert_box_present())
        
        #if self.compute_page.get_alert_box_text() == 'Cluster Instance created successfully':
         #       raise Exception('SUCCESS alert box found')
        #else:
         #   raise Exception('SUCCESS alert box not found. got ' + self.compute_page.get_alert_box_text())

        #self.refresh_page()
        #if self.base_page.wait_for_alert_box(wait=wait, cluster_name=cluster_name):
           # logging.info('alert box found') 
       # else:
            #raise Exception('alert box NOT found')

    def cluster_should_not_exist(self, region=None, cluster_name=None, developer_name=None, operator_name=None, cloudlet_name=None, flavor_name=None, ip_access=None, wait=5): 
        self.take_screenshot('cluster_should_exist_pre')

        wait = int(wait)

        if region is None: region = self._region
        if cluster_name is None: cluster_name = self._clusterInst['key']['cluster_key']['name']
        if operator_name is None: operator_name = self._clusterInst['key']['cloudlet_key']['operator_key']['name']
        if developer_name is None: developer_name= self._clusterInst['key']['developer']
        if cloudlet_name is None: cloudlet_name = self._clusterInst['key']['cloudlet_key']['name']
        if flavor_name is None: flavor_name= self._clusterInst['flavor']['name']
        if ip_access is None: ip_access= self._clusterInst['ip_access']

        logging.info(f'cluster_should_not_exist region={region}  cluster_name={cluster_name}  developer_name={developer_name}  operator_name={operator_name}  cloudlet_name={cloudlet_name}  flavor_name={flavor_name}  ip_access={ip_access}')
        #for seconds in range(wait):
        if self.cluster_instances_page.is_cluster_instance_present(region=region,  cluster_name=cluster_name,  developer_name=developer_name,  operator_name=operator_name,  cloudlet_name=cloudlet_name,  flavor_name=flavor_name,  ip_access=ip_access):
            raise Exception(f'cluster={cluster_name} found')
        else:
            logging.info(f'cluster={cluster_name} NOT found')

    def cluster_progress_is_done(self, region=None, cluster_name=None, developer_name=None, operator_name=None, cloudlet_name=None, flavor_name=None, ip_access=None):
        self.take_screenshot('cluster_should_exist_pre')

        if region is None: region = self._region
        if cluster_name is None: cluster_name = self._clusterInst['key']['cluster_key']['name']
        if operator_name is None: operator_name = self._clusterInst['key']['cloudlet_key']['operator_key']['name']
        if developer_name is None: developer_name= self._clusterInst['key']['developer']
        if cloudlet_name is None: cloudlet_name = self._clusterInst['key']['cloudlet_key']['name']
        if flavor_name is None: flavor_name= self._clusterInst['flavor']['name']
        if ip_access is None: ip_access= self._clusterInst['ip_access']

        logging.info(f'cluster_progress_should_be_done region={region}  cluster_name={cluster_name}  developer_name={developer_name}  operator_name={operator_name}  cloudlet_name={cloudlet_name}  flavor_name={flavor_name}  ip_access={ip_access}')
        if self.cluster_instances_page.is_cluster_instance_progress_done(region=region,  cluster_name=cluster_name,  developer_name=developer_name,  operator_name=operator_name,  cloudlet_name=cloudlet_name,  flavor_name=flavor_name,  ip_access=ip_access):
            logging.info(f'cluster={cluster_name} is finished creating')
        else:
            raise Exception(f'cluster={cluster_name} not found')

    def cluster_should_show_on_map(self, number_clusters):
        self.cluster_instances_page.zoom_out_map(2)
        time.sleep(1)
        clusters = self.cluster_instances_page.get_cluster_icon_numbers()
        if clusters == number_clusters:
            logging.info(f'number of cluster icons match. found {number_clusters} clusters')
        else:
            logging.error(f'did NOT find all clusters. Looking for {number_clusters} but found {clusters}')
            raise Exception('not all clusters found on map')

    def sort_clusters_by_cluster_name(self):
        self.cluster_instances_page.click_cluster_name_heading()

    def sort_clusters_by_region(self):
        self.cluster_instances_page.click_region_heading()

    def open_cluster_details(self, cluster_name, region):
        logging.info('Opening cluster details for clustername=' + cluster_name)

        self.cluster_instances_page.click_cluster_row(cluster_name=cluster_name, region=region)
        time.sleep(1)

        if self.new_clusterinst_page.are_cluster_details_present():
            logging.info('cluster details page verification succeeded')
        else:
            raise Exception('cluster details page verification failed')

        details = self.cluster_details_page.get_details()
        print('*WARN*', details)
        return details
   
    def close_cluster_details(self):
        self.cluster_details_page.click_close_button()

    def delete_cluster(self, cluster_name=None, developer_name=None, operator_name=None, wait=None):
        #driver = webdriver.Chrome()
       # self.driver = driver
        self.refresh_page()
        self.take_screenshot('delete_cluster_pre')
        
        wait = int(wait)

        if cluster_name is None: cluster_name =self._clusterInst['key']['cluster_key']['name']
        if developer_name is None: developer_name=self._clusterInst['key']['developer']
        if operator_name is None: operator_name=self._clusterInst['key']['cloudlet_key']['operator_key']['name']

        logging.info(f'Deleting cluster cluster_name={cluster_name} developer_name={developer_name} operator={operator_name}')

        self.cluster_instances_page.delete_cluster(cluster_name=cluster_name, operator_name=operator_name, developer_name=developer_name)

        logging.info('Deleted cluster')
        #time.sleep(20)
        #self.refresh_page()

        #wait = WebDriverWait(driver, 350)
        #element = wait.until(ec.alert_is_present())
       # self.compute_page.wait_for_alert_box(wait=wait)
        #if self.compute_page.get_alert_box_text() == 'Cluster Instance deleted successfully':
                #raise Exception('SUCCESS alert box found')
       # else:
            #raise Exception('SUCCESS alert box not found. got ' + self.compute_page.get_alert_box_text())

       # time.sleep(5)  # wait for table to show again

    def add_new_trustpolicy(self, region=None, developer_org_name=None, policy_name=None, rule_list=None, full_isolation=None, mode=None, delete_rule=None):
        self.take_screenshot('add_new_privacypolicy_pre')

        self.compute_page.click_new_button()

        if self.new_privacy_policy_page.are_elements_present():
            logging.info('click New Trust Policy button verification succeeded')
        else:
            raise Exception('click New Trust Policy button verification failed')

        self.privacy_policy = TrustPolicy(root_url='x')
        policy = self.privacy_policy._build(policy_name=policy_name, operator_org_name=developer_org_name, rule_list=rule_list)
        logging.info(f'Policy is {policy}')
        self._policy = policy
        self._region = region

        if self.new_privacy_policy_page.create_policy(region=region, developer_org_name=policy['key']['organization'], policy_name=policy['key']['name'], rule_list=policy['outbound_security_rules'], full_isolation=full_isolation, mode=mode, delete_rule=delete_rule):
            logging.info('create New Privacy Policy succeeded')
        else:
            raise Exception('did NOT create')

        if mode is None:
            if self.compute_page.is_alert_box_present():
                if self.compute_page.get_alert_box_text() != 'Trust Policy ' + policy['key']['name'] + ' created successfully':
                    print('*WARN*', 'SUCCESSFUL')
                    raise Exception('success alert box NOT found. got ' + self.compute_page.get_alert_box_text())
            else:
                raise Exception('Success alert box not found')

        self.take_screenshot('add_new_privacypolicy_post')

    def add_new_autoscalepolicy(self, region=None, developer_org_name=None, policy_name=None, min_nodes=None, max_nodes=None, scale_down_threshold=None, scale_up_threshold=None, trigger_time=None):
        self.take_screenshot('add_new_autoscalepolicy_pre')

        self.compute_page.click_new_button()
      
        if self.new_autoscalepolicy_page.are_elements_present():
            logging.info('click New Auto Scale Policy button verification succeeded')
        else:
            raise Exception('click New Auto Scale Policy button verification failed')

        policy = AutoScalePolicy(policy_name=policy_name, developer_name=developer_org_name, min_nodes=min_nodes, max_nodes=max_nodes, scale_up_cpu_threshold=scale_up_threshold, scale_down_cpu_threshold=scale_down_threshold, trigger_time=trigger_time).policy
        logging.info(f'Policy is {policy}')
        self._policy = policy
        self._region = region

        if self.new_autoscalepolicy_page.create_policy(region=region, developer_org_name=policy['key']['organization'], policy_name=policy['key']['name'], min_nodes=policy['min_nodes'], max_nodes=policy['max_nodes'], scale_down_threshold=policy['scale_down_cpu_thresh'], scale_up_threshold=policy['scale_up_cpu_thresh'], trigger_time=policy['trigger_time_sec']):
            logging.info('create New Auto Scale Policy succeeded')
        else:
            raise Exception('did NOT create')

        if self.compute_page.is_alert_box_present():
            if self.compute_page.get_alert_box_text() != 'Auto Scale Policy ' + policy['key']['name'] + ' created successfully':
                print('*WARN*', 'SUCCESSFUL')
                raise Exception('success alert box NOT found. got ' + self.compute_page.get_alert_box_text())
        else:
            raise Exception('Success alert box not found')

        self.take_screenshot('add_new_autoscalepolicy_post')

    def add_new_app(self, region=None, app_name=None, app_version=None, developer_name=None, deployment_type=None, flavor_name=None, access_ports=None, scale_with_cluster=False, auth_public_key=None, envvar=None, official_fqdn=None, android_package=None, access_type=None, skip_hc=None, trusted=False, outbound_connections=[]):
        logging.info(f'list is {outbound_connections}')
        if flavor_name is None: flavor_name = 'automation_api_flavor'    
        self.take_screenshot('add_new_app_pre')

        self.compute_page.click_add_button()
        if self.new_apps_page.are_elements_present():
            logging.info('click New App button verification succeeded')
        else:
            raise Exception('click New App button verification failed')

        app = App(app_name=app_name, app_version=app_version, developer_org_name=developer_name, default_flavor_name=flavor_name, deployment=deployment_type, access_ports=access_ports, scale_with_cluster=scale_with_cluster, auth_public_key=auth_public_key, official_fqdn=official_fqdn).app
        self._app = app
        #logging.info('HERE')
        self._region = region
        port_details = app['access_ports']
        print('*WARN*', 'image_path=', app['image_path'])

        image_path_docker_default = 'docker-qa.mobiledgex.net/' + app['key']['organization'].lower() + '/images/' + app['key']['name'] + ':' + app['key']['version']
        image_path_vm_default = 'https://artifactory.mobiledgex.net/artifactory/repo-' + app['key']['organization']
        image_path_helm_default = 'https://chart.registry.com/charts:' + app['key']['organization'] + "/" + app['key']['name']
        print('*WARN*', 'image_path_default =', image_path_vm_default)
        logging.info ("image_path_helm_default = " + image_path_helm_default)
        logging.info(f'Adding new app region={region} app_name={app["key"]["name"]} app_version={app["key"]["version"]} developer_org_name={app["key"]["organization"]} flavor_name={app["default_flavor"]["name"]} deployment_type={app["deployment"]} access_ports={port_details} scale_with_cluster={scale_with_cluster} auth_public_key={auth_public_key} official_fqdn={official_fqdn} android_package={android_package} trusted={trusted} outbound_connections={outbound_connections}')
        if self.new_apps_page.create_app(region=region, app_name=app['key']['name'], app_version=app['key']['version'], developer_name=app['key']['organization'], flavor_name=app['default_flavor']['name'], deployment_type=app['deployment'], image_path=app['image_path'], image_path_docker_default=image_path_docker_default, image_path_vm_default=image_path_vm_default, image_path_helm_default=image_path_helm_default, port_number=port_details, scale_with_cluster=scale_with_cluster, auth_public_key=auth_public_key, envvar=envvar, official_fqdn=official_fqdn, android_package=android_package, access_type=access_type, skip_hc=skip_hc, trusted=trusted, outbound_connections=outbound_connections):
            logging.info('create New App succeeded')
        else:
            raise Exception('create New App did NOT succeed')

        if self.compute_page.is_alert_box_present():
            if self.compute_page.get_alert_box_text() != 'App ' + app['key']['name'] + ' added successfully':
                print('*WARN*', 'SUCCESSFUL')
                raise Exception('success alert box NOT found. got ' + self.compute_page.get_alert_box_text())
        else:
            raise Exception('Success alert box not found')

        self.take_screenshot('add_new_app_post')

    def update_trustpolicy(self, region=None, developer_org_name=None, policy_name=None, rule_list=None, full_isolation=None, delete_rule=None, cloudlets=[]):
        if region is None: region = self._region
        if policy_name is None: policy_name = self._policy['key']['name']
        if developer_org_name is None: developer_org_name = self._policy['key']['organization']

        logging.info(f'Updating trust policy policy_name={policy_name} developer_org_name={developer_org_name}')

        self.change_number_of_rows()
        if self.new_privacy_policy_page.update_policy(policy_name=policy_name, rule_list=rule_list, delete_rule=delete_rule):
            logging.info('Updated trust policy')
        else:
            raise Exception('did NOT update')

        if not cloudlets:
            if self.compute_page.wait_for_dialog_box(text="Trust policy updated, no cloudlets affected", wait=10):
                time.sleep(2)
                self.new_cloudlet_page.close_alert_box()
            else:
                raise Exception('Dialog box text NOT found')
        else:
            num_cloudlets = len(cloudlets)
            if self.compute_page.wait_for_dialog_box(text=f"Processed: {num_cloudlets} Cloudlets. Passed: {num_cloudlets} Failed: 0", wait=60):
                time.sleep(2)
                self.new_cloudlet_page.close_alert_box()
            else:
                raise Exception('Dialog box text NOT found')
    
        #if self.compute_page.is_alert_box_present():
        #    if self.compute_page.get_alert_box_text() != 'Trust Policy ' + policy_name + ' updated successfully':
        #        print('*WARN*', 'SUCCESSFUL')
        #        raise Exception('success alert box NOT found. got ' + self.compute_page.get_alert_box_text())
        #else:
        #    raise Exception('Success alert box not found')

        self.take_screenshot('update_privacypolicy_post')

    def update_autoscalepolicy(self, region=None, developer_org_name=None, policy_name=None, min_nodes=None, max_nodes=None, scale_down_threshold=None, scale_up_threshold=None, trigger_time=None):
        if region is None: region = self._region
        if policy_name is None: policy_name = self._policy['key']['name']
        if developer_org_name is None: developer_org_name = self._policy['key']['organization']

        logging.info(f'Updating auto scale policy policy_name={policy_name} developer_org_name={developer_org_name}') 

        self.change_number_of_rows() 
        if self.new_autoscalepolicy_page.update_policy(policy_name=policy_name, min_nodes=min_nodes, max_nodes=max_nodes, scale_down_threshold=scale_down_threshold, scale_up_threshold=scale_up_threshold, trigger_time=trigger_time):
            logging.info('Updated auto scale policy')
        else:
            raise Exception('did NOT update')

        if self.compute_page.is_alert_box_present():
            if self.compute_page.get_alert_box_text() != 'Auto Scale Policy ' + policy_name + ' updated successfully':
                print('*WARN*', 'SUCCESSFUL')
                raise Exception('success alert box NOT found. got ' + self.compute_page.get_alert_box_text())
        else:
            raise Exception('Success alert box not found')

        self.take_screenshot('update_autoscalepolicy_post')

    def update_app(self, region=None, app_name=None, app_version=None, developer_name=None, deployment_type=None, flavor_name=None, access_ports=None, scale_with_cluster=False, auth_public_key=None, envvar=None, official_fqdn=None, android_package=None, trusted=False, skip_hc=None, outbound_connections=[], number_of_pages=2):
        if region is None: region = self._region
        if app_name is None: app_name = self._app['key']['name']
        if developer_name is None: developer_name = self._app['key']['organization']
        if app_version is None: app_version = self._app['key']['version'] 
        if deployment_type is None: deployment_type = self._app['deployment']

        logging.info(f'Updating app app_name={app_name} developer_name={developer_name} app_version={app_version}')

        self.change_number_of_rows()
        self.apps_page.wait_for_app(region=region, org_name=developer_name, app_name=app_name, app_version=app_version, deployment_type=deployment_type, number_of_pages=number_of_pages)

        if self.apps_page.update_app(app_name=app_name, access_ports=access_ports, scale_with_cluster=scale_with_cluster, auth_public_key=auth_public_key, envvar=envvar, official_fqdn=official_fqdn, android_package=android_package, trusted=trusted, skip_hc=skip_hc, outbound_connections=outbound_connections):
            logging.info('Updated app')
        else:
            raise Exception('did NOT update')

        if self.compute_page.is_alert_box_present():
            if self.compute_page.get_alert_box_text() != 'App ' + app_name + ' updated successfully':
                print('*WARN*', 'SUCCESSFUL')
                raise Exception('success alert box NOT found. got ' + self.compute_page.get_alert_box_text())
        else:
            raise Exception('Success alert box not found')


    def sort_apps_by_app_name(self):
        self.apps_page.click_app_name_heading()

    def sort_apps_by_region(self):
        self.apps_page.click_region_heading()

    def trustpolicy_should_not_exist(self, region=None, developer_org_name=None, policy_name=None, rules_count=None, change_rows_per_page=False):
        if change_rows_per_page:
            self.change_number_of_rows()
        self.take_screenshot('privacypolicy_should_exist_pre')

        if region is None: region = self._region
        if policy_name is None: policy_name = self._policy['key']['name']
        if developer_org_name is None: developer_org_name = self._policy['key']['organization']

        if self.privacy_policy_page.wait_for_policy(region=region, developer_org_name=developer_org_name, policy_name=policy_name, rules_count=rules_count):
            raise Exception('Privacy Policy found')
        else:
            logging.info('Privacy Policy not found')

    def trustpolicy_should_exist(self, region=None, developer_org_name=None, policy_name=None, rules_count=None, change_rows_per_page=False):
        if change_rows_per_page:
            self.change_number_of_rows()
        self.take_screenshot('privacypolicy_should_exist_pre')

        if region is None: region = self._region
        if policy_name is None: policy_name = self._policy['key']['name']
        if developer_org_name is None: developer_org_name = self._policy['key']['organization']

        if self.privacy_policy_page.wait_for_policy(region=region, developer_org_name=developer_org_name, policy_name=policy_name, rules_count=rules_count):
            logging.info('Policy found')
        else:
            raise Exception('Policy NOT found')

    def autoscalepolicy_should_exist(self, region=None, developer_org_name=None, policy_name=None, min_nodes=None, max_nodes=None, change_rows_per_page=False):
        if change_rows_per_page:
            self.change_number_of_rows()
        self.take_screenshot('autoscalepolicy_should_exist_pre')

        if region is None: region = self._region
        if policy_name is None: policy_name = self._policy['key']['name']
        if developer_org_name is None: developer_org_name = self._policy['key']['organization']
        if min_nodes is None: min_nodes = self._policy['min_nodes']
        if max_nodes is None: max_nodes = self._policy['max_nodes']

        if self.autoscalepolicy_page.wait_for_policy(region=region, developer_org_name=developer_org_name, policy_name=policy_name, min_nodes=min_nodes, max_nodes=max_nodes):
            logging.info('Policy found')
        else:
            raise Exception('Policy NOT found')
 
    def app_should_exist(self, region=None, org_name=None, app_name=None, app_version=None, deployment_type=None, default_flavor_name=None, ports=None, change_rows_per_page=False, number_of_pages=2, wait=5):
        if change_rows_per_page:
            self.change_number_of_rows()
        self.take_screenshot('app_should_exist_pre')
        #logging.info(f'Verifying new app exists region={region} app_name={app_name} app_version={app_version} org_name={org_name}  default_flavor_name={default_flavor_name} deployment_type={deployment_type} ports={ports}')
        
        if region is None: region = self._region
        if app_name is None: app_name = self._app['key']['name']
        if org_name is None: org_name = self._app['key']['organization']
        if app_version is None: app_version = self._app['key']['version']
        if deployment_type is None: deployment_type = self._app['deployment']
        if default_flavor_name is None: default_flavor_name = self._app['default_flavor']['name']

        self.apps_page.perform_search(app_name)
        if self.apps_page.wait_for_app(region=region, org_name=org_name, app_name=app_name, app_version=app_version, deployment_type=deployment_type, number_of_pages=number_of_pages):
            logging.info('*** App Found ***')
        else:
            raise Exception('*** App NOT found ***')


    def app_should_not_exist(self, region=None, developer_name=None, app_name=None, app_version=None, deployment_type=None, flavor_name=None, number_of_pages=1, wait=5):
        self.take_screenshot('app_should_exist_pre')
        #logging.info(f'Verifying new app exists region={region} app_name={app_name} app_version={app_version} developer_name={developer_name}  flavor_name={flavor_name} deployment_type={deployment_type}')
        
        if region is None: region = self._region
        if app_name is None: app_name = self._app['key']['name']
        if developer_name is None: developer_name = self._app['key']['organization']
        if app_version is None: app_version = self._app['key']['version']
        if deployment_type is None: deployment_type = self._app['deployment']
        if flavor_name is None: flavor_name = self._app['default_flavor']['name']

        self.apps_page.perform_search(app_name)
        if self.apps_page.wait_for_app(region=region, app_name=app_name, app_version=app_version, org_name=developer_name, deployment_type=deployment_type, number_of_pages=number_of_pages):
            raise Exception('*** App was found. Expected to be not found ***')
        else:
            logging.info('*** App NOT found as expected ***')


    def sort_apps_by_app_name(self):
        self.apps_page.click_app_name_heading()

    def sort_apps_by_region(self):
        self.apps_page.click_region_heading()

    def open_appinst_details(self, app_name=None, region=None, app_version=None, cluster_name=None, cloudlet_name=None):
        if region is None: region = self._region
        if app_name is None: app_name = self._appInst['key']['app_key']['name']
        if app_version is None: app_version = self._appInst['key']['app_key']['version']
        if cluster_name is None: cluster_name = self._appInst['key']['cluster_inst_key']['cluster_key']['name']
        if cloudlet_name is None: cloudlet_name = self._appInst['key']['cluster_inst_key']['cloudlet_key']['name']

        self.change_number_of_rows()
        self.refresh_page()
        time.sleep(2)

        if self.app_instances_page.click_appinst_row(app_name=app_name, region=region, app_version=app_version, cluster_name=cluster_name, cloudlet_name=cloudlet_name):
            details = self.details_page.get_details()
        else:
            raise Exception('appinst NOT found')

        return details

    def open_app_details(self, app_name=None, region=None, app_version=None, app_org=None, deployment_type=None):
        if region is None: region = self._region
        if app_name is None: app_name = self._app['key']['name']
        if app_org is None: app_org = self._app['key']['organization']
        if app_version is None: app_version = self._app['key']['version']
        if deployment_type is None: deployment_type = self._app['deployment']

        index = 0

        self.apps_page.perform_search(app_name)
        if self.apps_page.wait_for_app(region=region, org_name=app_org, app_name=app_name, app_version=app_version, number_of_pages=2,
                                       deployment_type=deployment_type):
            logging.info('*** App Found ***')
        else:
            raise Exception('*** App NOT found ***')

        logging.info('Opening app details for appname=' + app_name + ' region=' + region + ' appversion=' + app_version + ' app-org=' + app_org)

        if not self.apps_page.click_app_row(app_name=app_name, region=region, app_version=app_version, app_org=app_org):
            index += 1
            self.apps_page.click_next_page()
            self.apps_page.click_app_row(app_name=app_name, region=region, app_version=app_version, app_org=app_org)

        if self.new_apps_page.are_app_details_present():
            logging.info('app details page verification succeeded')
        else:
            raise Exception('app details page verification failed')

        details = self.details_page.get_details()
        print('*WARN*', details)

        return details
  
    def close_details(self):
        self.details_page.click_close_button()
 
    def close_apps_details(self):
        self.details_page.click_close_button()

    def delete_trustpolicy(self, region=None, developer_org_name=None, policy_name=None, change_rows_per_page=False, result='pass', cloudlet_name=None):
        if change_rows_per_page:
            self.change_number_of_rows()
        self.take_screenshot('delete_autoscalepolicy_pre')
        if region is None: region = self._region
        if policy_name is None: policy_name = self._policy['key']['name']
        if developer_org_name is None: developer_org_name = self._policy['key']['organization']

        self.privacy_policy_page.delete_privacypolicy(region=region, developer_org_name=developer_org_name, policy_name=policy_name)

        if result == 'pass':
            if self.compute_page.is_alert_box_present():
                if self.compute_page.get_alert_box_text() != 'Trust Policy ' + policy_name + ' deleted successfully':
                    print('*WARN*', 'SUCCESSFUL')
                    raise Exception('success alert box NOT found. got ' + self.compute_page.get_alert_box_text())
            else:
                raise Exception('Success alert box not found')
        else:
            if self.compute_page.is_alert_box_present():
                if self.compute_page.get_alert_box_text() != 'Policy in use by Cloudlet' and self.compute_page.get_alert_box_text() != f'Policy in use by Cloudlet {cloudlet_name}':
                    print('*WARN*', 'SUCCESSFUL')
                    raise Exception('failure alert box NOT found. got ' + self.compute_page.get_alert_box_text())
            else:
                raise Exception('Failure alert box not found')
    
    def delete_autoscalepolicy(self, region=None, developer_org_name=None, policy_name=None, change_rows_per_page=False):
        if change_rows_per_page:
            self.change_number_of_rows()
        self.take_screenshot('delete_autoscalepolicy_pre')
        if region is None: region = self._region
        if policy_name is None: policy_name = self._policy['key']['name']
        if developer_org_name is None: developer_org_name = self._policy['key']['organization']

        self.autoscalepolicy_page.delete_autoscalepolicy(region=region, developer_org_name=developer_org_name, policy_name=policy_name)
        logging.info('Deleted Auto Scale Policy')

        if self.compute_page.is_alert_box_present():
            if self.compute_page.get_alert_box_text() != 'Auto Scale Policy ' + policy_name + ' deleted successfully':
                print('*WARN*', 'SUCCESSFUL')
                raise Exception('success alert box NOT found. got ' + self.compute_page.get_alert_box_text())
        else:
            raise Exception('Success alert box not found')

    def delete_app(self, region=None, app_name=None, app_version=None, developer_name=None, deployment_type=None, number_of_pages=2, click_previous_page=None, change_rows_per_page=False):
        if change_rows_per_page:
            self.change_number_of_rows()
        self.take_screenshot('delete_app_pre')
        
        if region is None: region = self._region
        if app_name is None: app_name = self._app['key']['name']
        if developer_name is None: developer_name = self._app['key']['organization']
        if app_version is None: app_version = self._app['key']['version']
        if deployment_type is None: deployment_type = self._app['deployment']
        logging.info(f'Deleting app app_name={app_name} developer_name={developer_name} app_version={app_version}')

        self.driver.refresh
        self.apps_page.perform_search(app_name)
        self.apps_page.wait_for_app(region=region, org_name=developer_name, app_name=app_name, app_version=app_version, deployment_type=deployment_type, number_of_pages=number_of_pages, click_previous_page=click_previous_page)

        self.apps_page.delete_app(region=region, developer_name=developer_name, app_name=app_name, app_version=app_version, deployment_type=deployment_type)
        logging.info('Deleted app')

        if self.compute_page.is_alert_box_present():
            if self.compute_page.get_alert_box_text() != 'App ' + self._app['key']['name'] + ' deleted successfully':
                print('*WARN*', 'SUCCESSFUL')
                raise Exception('success alert box NOT found. got ' + self.compute_page.get_alert_box_text())
        else:
            raise Exception('Success alert box not found')

    def add_new_app_instance(self, region=None, app_name=None, app_version=None, developer_name=None, operator_name=None, cloudlet_name=None, cluster_instance=None, type=None, ip_access=None):
        
        self.take_screenshot('add_new_app_pre')
        self.compute_page.click_add_button()

        if self.new_appinst_page.are_elements_present():
            logging.info('click New AppInst button verification succeeded')
        else:
            raise Exception('click New AppInst button verification failed')

        appInst = AppInstance(app_name=app_name, app_version=app_version, developer_name=developer_name, operator_name=operator_name, cloudlet_name=cloudlet_name, cluster_instance_name=cluster_instance).app_instance      
        self._appInst = appInst
        print('*WARN*', 'appInst', appInst)
        self._region = region

        logging.info(f'Adding new app instance region={region} app_name={app_name} app_version={app_version} developer_name={developer_name}  operator_name={operator_name} cloudlet_name={cloudlet_name} cluster_instance_name={cluster_instance}')
        if self.new_appinst_page.create_appinst(region=region, app_name=app_name, app_version=app_version, developer_name=developer_name, operator_name=operator_name, cloudlet_name=cloudlet_name, cluster_instance=cluster_instance, type=type, ip_access=ip_access):
            #if self.compute_page.wait_for_dialog_box(text="Waiting for Cluster to Initialize, Checking Master for Available Nodes", wait=300):
            if self.compute_page.wait_for_dialog_box(text="Created AppInst successfully", wait=300):
                self.new_appinst_page.close_alert_box()
                logging.info('Dialog box text found, Created AppInst successfully')
            else:
                raise Exception('Dialog box test NOT found')
        else:
            raise Exception('did NOT create')

        #if self.compute_page.wait_for_alert_box(text='Cloudlet ' + app_name + ' created successfully', wait=120):
        #    logging.info('App Inst success alert box not found')
        #else:
        #    raise Exception('App Inst success alert box NOT found')

        # ALERT BOX DOES NOT POP UP
        #time.sleep(5)
        #if self.compute_page.is_alert_box_present():
        #    if self.compute_page.get_alert_box_text() != 'Your app instance created successfully':
        #        'SUCCESSFUL')
        #        raise Exception('success alert box NOT found. got ' + 
        #    print('*WARN*', self.compute_page.get_alert_box_text())
        #else:
        #    raise Exception('Success alert box not found')

        self.take_screenshot('add_new_app_post')

    def add_app_instance_from_apps_page(self, region=None, app_name=None, app_version=None, developer_name=None, operator_name=None, cloudlet_name=None, cluster_instance=None, deployment_type=None, type=None, ip_access=None, envvar=None):       
        self.change_number_of_rows()

        if self.apps_page.wait_for_app(region=region, org_name=developer_name, app_name=app_name, app_version=app_version, deployment_type=deployment_type, number_of_pages=2, click_previous_page='off'):
            if self.apps_page.create_instance(region=region, developer_name=developer_name, app_name=app_name, app_version=app_version, deployment_type=deployment_type):
                if self.new_appinst_page.create_appinst(operator_name=operator_name, cloudlet_name=cloudlet_name, cluster_instance=cluster_instance, type=type, ip_access=ip_access, envvar=envvar, created_from='Apps Page'):
                    if self.compute_page.wait_for_dialog_box(text="Created AppInst successfully", wait=30):
                        self.new_appinst_page.close_alert_box()
                        logging.info('Dialog box text found, Created AppInst successfully')
                    else:
                        raise Exception('Dialog box test NOT found')
                else:
                    raise Exception('App Instance NOT created')
            else:
                raise Exception('Create Instance NOT found')
        else:
            raise Exception('App NOT found')
    
        
    def app_instance_should_exist(self, region=None, org_name=None, app_name=None, app_version=None, operator_name=None, cloudlet_name=None, cluster_instance=None, latitude=None, longitude=None, state=None, progress=None, wait=5):
        self.take_screenshot('appinstance_should_exist_pre')
        logging.info(f'app_instance_should_exist {region} {app_name} {org_name} {app_version} {operator_name} {cloudlet_name} {cluster_instance}')

        if region is None: region = self._region
        if app_name is None: flavor_name = self._app['key']['name']
        if org_name is None: ram = self._flavor['ram']
        if app_version is None: vcpus = self._flavor['vcpus']
        #if deployment_type is None: disk = self._flavor['disk']
        #if default_flavor is None: disk = self._flavor['disk']
        #if ports is None: disk = self._flavor['disk']

        if self.app_instances_page.wait_for_app_instance(region=region, org_name=org_name, app_name=app_name, version=app_version, operator=operator_name, cloudlet=cloudlet_name, cluster_instance=cluster_instance, wait=5):
            logging.info('app instance found')
        else:
            raise Exception('App instance NOT found')

    def app_instance_should_not_exist(self, region=None, developer_name=None, app_name=None, app_version=None, operator_name=None, cloudlet_name=None, cluster_instance=None):
        self.refresh_page()
        time.sleep(2)
        self.take_screenshot('appinstance_should_not_exist_pre')

        if region is None: region = self._region
        if app_name is None: app_name = self._appInst['key']['app_key']['name']
        if app_version is None: app_version = self._appInst['key']['app_key']['version']
        if cluster_instance is None: cluster_instance = self._appInst['key']['cluster_inst_key']['cluster_key']['name']
        if cloudlet_name is None: cloudlet_name = self._appInst['key']['cluster_inst_key']['cloudlet_key']['name']
        if operator_name is None: operator_name = self._appInst['key']['cluster_inst_key']['cloudlet_key']['operator_key']['name']
        if developer_name is None: developer_name = self._appInst['key']['app_key']['developer_key']['name']

        logging.info(f'app_instance_should_not_exist {region} {app_name} {developer_name} {app_version} {operator_name} {cloudlet_name} {cluster_instance}')
        #print('*WARN*', 'checking for app instance')
        self.app_instances_page.perform_search(cluster_instance)
        if self.app_instances_page.wait_for_app_instance(region=region, org_name=developer_name, app_name=app_name, version=app_version, operator=operator_name, cloudlet=cloudlet_name, cluster_instance=cluster_instance, wait=1):
            raise Exception('App instance found. Expected it to be not found')
        else:
            logging.info('App Instance NOT found as expected')
            return True

    def delete_app_instance(self, region=None, developer_name=None, app_name=None, app_version=None, operator_name=None, cloudlet_name=None, cluster_instance=None, change_rows_per_page=True):
        if change_rows_per_page:
            self.change_number_of_rows()
        self.refresh_page()
        time.sleep(2)
        self.take_screenshot('delete_appinst_pre')
       
        if region is None: region = self._region
        if app_name is None: app_name = self._appInst['key']['app_key']['name']
        if app_version is None: app_version = self._appInst['key']['app_key']['version']
        if cluster_instance is None: cluster_instance = self._appInst['key']['cluster_inst_key']['cluster_key']['name']
        if cloudlet_name is None: cloudlet_name = self._appInst['key']['cluster_inst_key']['cloudlet_key']['name']
        if operator_name is None: operator_name = self._appInst['key']['cluster_inst_key']['cloudlet_key']['operator_key']['name']
 
        logging.info(f'Deleting app instance app_name={app_name} app_version={app_version} cloudlet_name={cloudlet_name} cluster_instance={cluster_instance} operator_name={operator_name}')
        if self.app_instances_page.delete_appinst(region=region, app_name=app_name, app_version=app_version, developer_name=developer_name, operator_name=operator_name, cloudlet_name=cloudlet_name, cluster_instance=cluster_instance):
            time.sleep(10)
            logging.info('Deleted app instance')
        else:
            raise Exception('Did NOT Delete')

       # time.sleep(2)

        #if self.compute_page.is_alert_box_present():
           # if self.compute_page.get_alert_box_text() != 'Application Instance ' + app_name + ' successfully deleted':
             #   print('*WARN*', 'SUCCESSFUL')
               # raise Exception('success alert box NOT found. got ' + self.compute_page.get_alert_box_text())
       # else:
           # raise Exception('Success alert box not found')


    def find_new_button(self):
        self.accounts_page.new_icon_present()
        
    def account_should_exist(self, account_name=None, email=None, email_verified=None, locked=None, rowsize=None):
        if rowsize is None:
            self.change_number_of_rows()
        logging.info(f'account should exist name={account_name} email={email} email_verified={email_verified} locked={locked}')
        if account_name is None:
            # account_name = self._account['key']['name']
            if self.accounts_page.wait_for_account(email=email):
                logging.info(f'Found account with email {email}')
            else:
                raise Exception(f'Account with email {email} NOT found')
        else:
            if self.accounts_page.wait_for_account(account_name=account_name, email=email, email_verified=email_verified, locked=locked):
                logging.info(f'Found account name {account_name} {email} {email_verified} {locked}')
            else:
                raise Exception(f'Account={account_name} NOT found')

    def account_should_match(self, row, account_name=None, email=None, email_verified=None, locked=None, row_number=None):
        #row = self.compute_page.get_table_row_by_value([(account_name, 1)])
        
        if self.accounts_page.account_matches(row, account_name=account_name, email=email, email_verified=email_verified, locked=locked):
            logging.info('account matches')
        else:
            raise Exception('account does NOT match')
        
    def delete_account(self, account_name=None, email=None, tempName=None):
        self.take_screenshot('delete_account_pre')

        # ALWAYS call account should exist first in TC
        if tempName is None and account_name is None:
            # account_name = self._account['key']['name']
            self.accounts_page.delete_account(email=email)
            logging.info(f'Deleting account with email {email}')
        else:
            logging.info(f'Deleting account name {account_name}')
            # Once the "New\n XaccountnameX" is solved, have to use email and tempname
            #self.accounts_page.delete_account(tempName=tempName)
            self.accounts_page.delete_account(tempName=account_name)
            logging.info(f'Deleting account name {account_name}')

        # once "new" tag mastered, change tempName -> account_name
        if self.compute_page.is_alert_box_present():
            if 'New\n' in account_name:
                account_name = account_name.replace('New\n','')
            if self.compute_page.get_alert_box_text() == 'Account ' + account_name + ' deleted successfully':
                logging.info('account delete alert box found')
                #self.take_screenshot('delete_account_error')
            else:
                raise Exception('account delete alert box not found. got ' + self.compute_page.get_alert_box_text())
        else:
            raise Exception('account Delete alert box not found')

    def sort_account_name(self, count):
        count = int(count)
        if count != None:
            while count != 0:
                self.accounts_page.click_accounts_name_heading()
                count -= 1
                time.sleep(1)
        else:
            self.accounts_page.click_accounts_name_heading()

    def sort_account_email(self, count):
        count = int(count)
        if count != None:
            while count != 0:
                self.accounts_page.click_accounts_email_heading()
                count -= 1
                time.sleep(1)
        else:
            self.accounts_page.click_accounts_email_heading()

    def view_account_details(self, account_name=None, email=None):        
        if account_name == None:
            logging.info('Opening account details for user: ' + email)
            self.accounts_page.click_account_row(email=email)
        else:
            logging.info('Opening account details for user: ' + account_name)
            self.accounts_page.click_account_row(account_name=account_name)
        if self.accounts_details_page.are_account_details_present():
            logging.info('Account details page verification succeeded')
        else:
            raise Exception('Account details page verification failed')

        #details = self.organization_details_page.get_details(choice='user')
        details = self.accounts_details_page.get_details(choice='user')
        details2 = {}
        for key, value in details.items():
            logging.info(key)
            if key == "Email Verified":
                if value == "-":
                    details2['EmailVerified'] = False
                elif value == 'Yes':
                    details2['EmailVerified'] = True
                else:
                    details2['EmailVerified'] = False
            elif key == "Family Name":
                if value == "-":
                    details2['FamilyName'] = ''
                else:
                    details2['FamilyName'] = value
            elif key == "Updated At":
                if value == "-":
                    details2['UpdatedAt'] = ''
                else:
                    value2 = value[:10]
                    details2['UpdatedAt'] = value2
            elif key == "Created At":
                if value == "-":
                    details2['CreatedAt'] = ''
                else:
                    value2 = value[:10]
                    details2['CreatedAt'] = value2
            elif key == "Locked":
                if value == "-":
                    details2[key] = False
                else:
                    details2[key] = True
            elif key == "Iter":
                if value == "-":
                    details2[key] = 0
                else:
                    details2[key] = value
            elif key == "Username":
                details2[key] = value
            else:
                if value == "-":
                    details2[key] = ''
                else:
                    details2[key] = value

        return details2

    def close_account_details(self):
        #self.accounts_page.click_close_account_details()
        self.details_page.click_close_button()

    def view_user_details(self, username):
        logging.info('Opening details for user: ' + username)
        self.users_page.click_user_row(username=username)

        if self.users_page.are_account_details_present():
            logging.info('Account details page verification succeeded')
        else:
            raise Exception('Account details page verification failed')

        time.sleep(2)
        details = self.organization_details_page.get_details(choice='user')
        return details

    def filter_users(self, choice=None):
        logging.info('Changing search box to ' + choice)
        if choice == None: choice = 'Username'
        self.new_users_page.change_filter(choice=choice)
        self.take_screenshot('changed_user_filterbox')

    def search_users(self, username=None, organization=None):
        if username == None:
            logging.info('Searching for ' + organization)
            self.new_users_page.search_for_user(organization=organization)
        elif username != None:
            logging.info('Searching for ' + username)
            self.new_users_page.search_for_user(username=username)
        else:
            raise Exception('Username or Organization input needed')
        self.take_screenshot('userpage_input_in_searchbar')

    def sort_user_name(self, count):
        count = int(count)
        if count != None:
            while count != 0:
                self.users_page.click_users_name_heading()
                count -= 1
                time.sleep(1)
        else:
            self.users_page.click_users_name_heading()

    def sort_user_orgs(self, count):
        count = int(count)
        while count != 0:
            self.users_page.click_users_organization_heading()
            count -= 1
            time.sleep(1)

    def sort_user_roletypes(self, count):
        count = int(count)
        while count != 0:
            self.users_page.click_users_roletype_heading()
            count -= 1
            time.sleep(1)

    def  trim_first_char(self, role):
        role = role[1:]
        return role

    def close_user_details(self):
        self.users_page.click_close_user_details()

    def refresh_page(self):
        self.compute_page.click_refresh()
        time.sleep(1)

    def get_table_data(self):
        self.take_screenshot('get_table_data_pre')

        rows = self.compute_page.get_table_rows()
        #for r in rows:
        #    print('*WARN*', 'r', r)

        return rows

    def verification_email_should_be_received(self, username=None, password=None, email_address=None, server='imap.gmail.com', wait=30):
        if username is None: username = self._newuser_username
        if password is None: password = self._newuser_password
        if email_address is None: email_address = self._newuser_email

        #logging.info(f'checking email with email={email_address} password={password}')
        #mail = imaplib.IMAP4_SSL(server)
        #mail.login(email_address,password)
        #mail.select('inbox')
        #logging.info('login successful')

        #status, email_list_pre = mail.search(None, '(SUBJECT "Welcome to MobiledgeX!")')
        #mail_ids_pre = email_list_pre[0].split()
        #num_emails_pre = len(mail_ids_pre)
        #logging.info(f'number of emails pre is {num_emails_pre}')
        #time.sleep(3)

        mail = self._mail
        num_emails_pre = self._mail_count
        for attempt in range(wait):
            mail.recent()
            status, email_list = mail.search(None, '(SUBJECT "Welcome to MobiledgeX!")')
            mail_ids = email_list[0].split()
            num_emails = len(mail_ids)
            logging.info(f'number of emails found is {num_emails}')
            if num_emails > num_emails_pre:
                logging.info('new email found')
                mail_id = email_list[0].split()
                typ, data = mail.fetch(mail_id[-1], '(RFC822)')
                for response_part in data:
                    if isinstance(response_part, tuple):
                        msg = email.message_from_string(response_part[1].decode('utf-8'))
                        email_subject = msg['subject']
                        email_from = msg['from']
                        date_received = msg['date']
                        payload = msg.get_payload(decode=True).decode('utf-8')
                        logging.info(payload)

                        if f'Hi {username},' in payload:
                            logging.info('greetings found')
                        else:
                            raise Exception('Greetings not found')

                        if 'Thanks for creating a MobiledgeX account! You are now one step away from utilizing the power of the edge. Please verify this email account by clicking on the link below. Then you\'ll be able to login and get started.' in payload:
                            logging.info('body1 found')
                        else:
                            raise Exception('Body1 not found')
                        print('*WARN*', f'{self.url}/verify?token=')
                        url = self.url.replace('http://', 'https://')
                        if f'Click to verify: {url}/#/verify?token=' in payload:
                            for line in payload.split('\n'):
                                if 'Click to verify' in line:
                                    label, link = line.split('Click to verify:')
                                    self._verify_link = link
                                    break
                            logging.info('verify link found')
                        else:
                            raise Exception('Verify link not found')

                        if f'For security, this request was received for {email_address} from' in payload and 'If you are not expecting this email, please ignore this email or contact MobiledgeX support for assistance.' in payload and 'Thanks!' in payload and 'MobiledgeX Team' in payload:
                            logging.info('body2 link found')
                        else:
                            logging.info(f'email= {email_address}')
                            raise Exception('Body2 not found')
                        return True
            time.sleep(1)

        raise Exception('verification email not found')

    def verify_new_user(self):
        logging.info(f'Verifying user with {self._verify_link}')

        self.driver.get(self._verify_link)

        if self.compute_page.is_alert_box_present():
            if self.compute_page.get_alert_box_text() != 'email verified, thank you':
                raise Exception('email verification alert box not found. got ' + self.compute_page.get_alert_box_text())
        else:
            raise Exception('Email verification alert box not found')

    def change_region(self, region):
        logging.info(f'Changing region to {region}')

        self.compute_page.click_region_pulldown()
        self.compute_page.click_region_pulldown_option(region)

        time.sleep(3)

    def take_screenshot(self, name):
        #self.compute_page.take_screenshot(name + '_' + self.timestamp + '.png')
        self.base_page.take_screenshot(name)
        #self.driver.save_screenshot(name+'.png')
        #logger.info(f'<img src="{name}.png">', html=True)

    def close_browser(self):
        self.take_screenshot('closebrowser')
        #self.compute_page.take_screenshot('closebrowser.png')
        self.driver.close()
        time.sleep(5)

    def _init_shared_variables(self):
        shared_variables_mc.default_time_stamp = str(time.time())
        shared_variables_mc.username_default = 'mexadmin'
        shared_variables_mc.password_default = 'mexadminfastedgecloudinfra'
        shared_variables_mc.email_default = shared_variables_mc.username_default + '@email.com'
        shared_variables_mc.region_default = None
