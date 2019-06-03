from selenium.webdriver.common.by import By

class LoginPageLocators(object):
    username_field = (By.NAME, 'username')
    password_field = (By.NAME, 'password')
    login_button = (By.XPATH, '//button[text()="Log In"]')
    login_switch_button = (By.XPATH, '//button/span[text()="Login"]')
    signup_switch_button = (By.XPATH, '//button/span[text()="SignUp"]')
    forgot_password_link = (By.CSS_SELECTOR, 'div.login-text')

class MainPageLocators(object):
    compute_button = (By.XPATH, '//button[text()="MobiledgeX Compute"]')
    monitoring_button = (By.XPATH, '//button[text()="MobiledgeX Monitoring"]')
    avatar = (By.XPATH, '//img[@src="/assets/avatar/avatar_default.svg"]')
    username = (By.XPATH, '//*[@class="navbar_right"]//span')

class ComputePageLocators(object):
    brand_class = (By.CSS_SELECTOR, 'div.content.brand')
    icons_class = (By.CSS_SELECTOR, 'i.material-icons.md-24.md-dark')
    avatar = (By.XPATH, '//img[@src="/assets/avatar/avatar_default.svg"]')
    username_div = (By.XPATH, '//*[@class="ui avatar image"]/..')
    support = (By.XPATH, '//span[text()="Support"]')

    table_title = (By.CSS_SELECTOR, 'div.column.title_align')
    table_new_button = (By.XPATH, '//button[@class="ui teal button" and contains(text(), "New")]')
    table_help_button = (By.CSS_SELECTOR, 'i.question.circle.outline.small.icon')
    table_region_label = (By.XPATH, '//div[@class="row"]/label[text()="Region"]')
    table_region_pulldown = (By.XPATH, '//div[@class="row"]/div[@class="ui dropdown selection"]')
    table_region_pulldown_option_all = (By.XPATH, '//div[@class="row"]/div[@class="ui active visible dropdown selection"]//div[@role="option"]/span[text()="ALL"]')
    table_region_pulldown_option_us = (By.XPATH, '//div[@class="row"]/div[@class="ui active visible dropdown selection"]//div[@role="option"]/span[text()="US"]')
    table_region_pulldown_option_eu = (By.XPATH, '//div[@class="row"]/div[@class="ui active visible dropdown selection"]//div[@role="option"]/span[text()="EU"]')
    table_class = (By.CSS_SELECTOR, 'div.grid_table')
    table_data = (By.CSS_SELECTOR, 'tbody.tbBodyList')

    cloudlets_button = (By.XPATH, '//*[@class="left_menu_item"]//div[text()="Cloudlets"]')
    flavors_button = (By.XPATH, '//*[@class="left_menu_item"]//div[text()="Flavors"]')
    cluster_instances_button = (By.XPATH, '//*[@class="left_menu_item"]//div[text()="Cluster Instances"]')
    apps_button = (By.XPATH, '//*[@class="left_menu_item"]//div[text()="Apps"]')
    app_instances_button = (By.XPATH, '//*[@class="left_menu_item"]//div[text()="App Instances"]')

class FlavorsPageLocators(object):
    flavors_table_header_region = (By.XPATH, '//div[@class="grid_table"]/table/thead/tr/th[text()="Region"]')
    flavors_table_header_flavorname = (By.XPATH, '//div[@class="grid_table"]/table/thead/tr/th[text()="FlavorName"]')
    flavors_table_header_ram = (By.XPATH, '//div[@class="grid_table"]/table/thead/tr/th[text()="RAM"]')
    flavors_table_header_vcpus = (By.XPATH, '//div[@class="grid_table"]/table/thead/tr/th[text()="VCPUS"]')
    flavors_table_header_disk = (By.XPATH, '//div[@class="grid_table"]/table/thead/tr/th[text()="DISK"]')
    flavors_table_header_edit = (By.XPATH, '//div[@class="grid_table"]/table/thead/tr/th[text()="Edit"]')
    flavors_table_button_edit = (By.XPATH, '//div[@class="grid_table"]/table/thead/tbody/tr/td/div[@class="ui teal disabled button"][text()="Edit"]')

class CloudletsPageLocators(object):
    cloudlets_table_header_region = (By.XPATH, '//div[@class="grid_table"]/table/thead/tr/th[text()="Region"]')
    cloudlets_table_header_cloudletname = (By.XPATH, '//div[@class="grid_table"]/table/thead/tr/th[text()="CloudletName"]')
    cloudlets_table_header_operator = (By.XPATH, '//div[@class="grid_table"]/table/thead/tr/th[text()="Operator"]')
    cloudlets_table_header_cloudletlocation = (By.XPATH, '//div[@class="grid_table"]/table/thead/tr/th[text()="CloudletLocation"]')
    cloudlets_table_header_edit = (By.XPATH, '//div[@class="grid_table"]/table/thead/tr/th[text()="Edit"]')

class NewPageLocators(object):
    heading = (By.XPATH, '//*[@class="ui modal transition visible active"]/div[text()="Settings"]')
    region =  (By.XPATH, '//*[@class="ui modal transition visible active"]//div[text()="Region"]')
    #region_pulldown = (By.XPATH, '//*[@class="ui modal transition visible active"]//div[@name="Region" and @role="listbox"]/div[text()="Select Region"]')
    region_pulldown = (By.XPATH, '//*[@class="ui modal transition visible active"]//div[@name="Region" and @role="listbox"]')
    region_pulldown_option_us = (By.XPATH, '//*[@class="ui modal transition visible active"]//div[@name="Region" and @role="listbox"]//div[@role="option"]/span[text()="US"]')
    region_pulldown_option_eu = (By.XPATH, '//*[@class="ui modal transition visible active"]//div[@name="Region" and @role="listbox"]//div[@role="option"]/span[text()="EU"]')
    cancel_button = (By.XPATH, '//*[@class="ui modal transition visible active"]//button[text()="Cancel"]')
    save_button = (By.XPATH, '//*[@class="ui modal transition visible active"]//button[text()="Save"]')

    flavor_flavorname = (By.XPATH, '//*[@class="ui modal transition visible active"]//div[text()="FlavorName"]')
    flavor_flavorname_input = (By.NAME, 'FlavorName')
    flavor_ram = (By.XPATH, '//*[@class="ui modal transition visible active"]//div[text()="RAM"]')
    flavor_ram_input = (By.NAME, 'RAM')
    flavor_vcpus = (By.XPATH, '//*[@class="ui modal transition visible active"]//div[text()="VCPUS"]')
    flavor_vcpus_input = (By.NAME, 'VCPUS')
    flavor_disk = (By.XPATH, '//*[@class="ui modal transition visible active"]//div[text()="DISK"]')
    flavor_disk_input = (By.NAME, 'DISK')

    cloudlet_cloudletname = (By.XPATH, '//*[@class="ui modal transition visible active"]//div[text()="CloudletName"]')
    cloudlet_cloudletname_input = (By.NAME, 'CloudletName')
    cloudlet_operatorname = (By.XPATH, '//*[@class="ui modal transition visible active"]//div[text()="OperatorName"]')
    cloudlet_operatorname_input = (By.NAME, 'OperatorName')
    cloudlet_latitude = (By.XPATH, '//*[@class="ui modal transition visible active"]//span[text()="Latitude"]')
    cloudlet_latitude_input = (By.NAME, 'Latitude')
    cloudlet_longitude = (By.XPATH, '//*[@class="ui modal transition visible active"]//span[text()="Longitude"]')
    cloudlet_longitude_input = (By.NAME, 'Longitude')
    cloudlet_location = (By.XPATH, '//*[@class="ui modal transition visible active"]//div[text()="CloudletLocation"]')
    cloudlet_ipsupport = (By.XPATH, '//*[@class="ui modal transition visible active"]//div[text()="Ip_support"]')
    cloudlet_ipsupport_input = (By.NAME, 'Ip_support')
    cloudlet_numdynamicips = (By.XPATH, '//*[@class="ui modal transition visible active"]//div[text()="Num_dynamic_ips"]')
    cloudlet_numdynamicips_input = (By.NAME, 'Num_dynamic_ips')

class SignupPageLocators(object):
    username_field = (By.NAME, 'username')
    password_field = (By.NAME, 'password')
    confirmpassword_field = (By.NAME, 'confirmpassword')
    email_field = (By.NAME, 'email')
    signup_button = (By.XPATH, '//button[text()="Sign Up"]')
    login_switch_button = (By.XPATH, '//button/span[text()="Login"]')
    signup_switch_button = (By.XPATH, '//button/span[text()="SignUp"]')
    terms_link = (By.XPATH, '//a[text()="Terms"]')
    datapolicy_link = (By.XPATH, '//a[text()="Data Policy"]')
    cookiespolicy_link = (By.XPATH, '//a[text()="Cookies Policy"]')
