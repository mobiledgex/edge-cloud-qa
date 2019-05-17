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

    table_class = (By.CSS_SELECTOR, 'div.grid_table')
    table_data = (By.CSS_SELECTOR, 'tbody.tbBodyList')

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
