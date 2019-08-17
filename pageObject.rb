require 'rubygems'
require 'selenium-webdriver'



$page = {
    URL: {
        home: "http://automationpractice.com/index.php",
        account: "http://automationpractice.com/index.php?controller=my-account"
    },
    topBar: {
        login: Proc.new do |driver| driver.find_element(:class, 'login') end,
        logout: Proc.new do |driver| driver.find_element(:class, 'logout') end
    },
    login: {
        title: "Login - My Store",
        email: Proc.new do |driver| driver.find_element(:id, 'email') end,
        passwd: Proc.new do |driver| driver.find_element(:id, "passwd") end,
        submitLogin: Proc.new {|driver| driver.find_element(:id, "SubmitLogin")},
        forgotPW: Proc.new {|driver| driver.find_element(:link_text, "Forgot your password?")},
        emailCreate: Proc.new {|driver| driver.find_element(:id,"email_create")},
        submitCreate: Proc.new{|driver| driver.find_element(:id,"SubmitCreate")},
        alert: Proc.new {|driver| driver.find_element(:class, "alert")}
    },
    account: {
        title: "My account - My Store"
    },
    forgotPW: {
        title: "Forgot your password - My Store"
    },
    createAccount: {
        firstname: Proc.new {|driver| driver.find_element(:id,"customer_firstname")},
        lastname: Proc.new {|driver| driver.find_element(:id,"customer_lastname")},
        password: Proc.new {|driver| driver.find_element(:id,"passwd")},
        address1: Proc.new {|driver| driver.find_element(:id,"address1")},
        city: Proc.new {|driver| driver.find_element(:id,"city")},
        state: Proc.new {|driver| driver.find_element(:name,"id_state")},
        stateNY: Proc.new {|driver| driver.find_element(:xpath,'//*[@id="id_state"]/option[34]')},
        postcode: Proc.new {|driver| driver.find_element(:id,"postcode")},
        mobile: Proc.new {|driver| driver.find_element(:id,"phone_mobile")},
        alias: Proc.new {|driver| driver.find_element(:id,"alias")},
        submitAccount: Proc.new {|driver| driver.find_element(:id,"submitAccount")}
    }
}

