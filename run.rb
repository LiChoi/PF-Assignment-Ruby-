require 'rubygems'
require 'selenium-webdriver'
require './pageObject'
require './tests'
include Tests

driver = Selenium::WebDriver.for :firefox

# To run, navigate to folder containing this file, then in command line type: .\run.rb

# You can run each test separately or run the full test suite
Tests::createAccount(driver)
Tests::testSignIn(driver)
Tests::testForgotPW(driver)
Tests::postAccountURLTest(driver)
Tests::testEnterButton(driver)
Tests::multiLoginAttempt(driver)
Tests::copyPastePassword(driver)
Tests::getPasswordByValue(driver)
Tests::openNewBrowser(driver)
