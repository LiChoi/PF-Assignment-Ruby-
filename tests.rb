require 'selenium-webdriver'
require './pageObject'

module Tests

    @randomEmail = "#{rand(1000000000)}@gmail.com"
    @emails = [@randomEmail, "pewpew@hotmail.com", "talosPrinciple@hotmail.com", "next@gmail.com", "marthaTalks@gmail.com", "pingu95@yahoo.com", "mona_lisa@gmail.com", "CommanderShepard@gmail.com"]  
    @password = "password" #password to use to create new account 
    @validEmail = "happy@hotmail.com" #Manually created valid account used for testing 
    @validPW =  "happy" #Valid password for valid happy@hotmail.com account 
    @validEmailUpCase = @validEmail.upcase #Used later for testing
    @validPWUpCase = @validPW.upcase #Used later for testing

    #An array of test values for one of the tests (some objects contain a function for secondary testing) 
    @testCases = [
        {
            case: "Test if valid email and valid password allows login",
            email: @validEmail,
            password: @validPW,
            expect: "logged in"
        },
        {
            case: "Test if valid email and invalid password allows login",
            email: @validEmail,
            password: "wrongPW",
            expect: "unable to login",
            assert: Proc.new {|driver|
                puts "Test if error message displays when login fails"
                testPass = true
                begin
                    $page[:login][:alert].call(driver)
                rescue 
                    testPass = false;
                    puts "Test failed: error message does not appear when login fails"
                end
                puts "Test passed: error message displays when login fails" if testPass
            }
        },
        {
            case: "Test case sensitivity of email using valid login credentials",
            email: @validEmailUpCase,
            password: @validPW,
            expect: "logged in"
        },
        {
            case: "Test case sensitivity of password using valid email and uppercase pw",
            email: @validEmail,
            password: @validPWUpCase,
            expect: "unable to login"
        },
        {
            case: "Test if empy email allows login",
            email: "empty",
            password: @validPW,
            expect: "unable to login"
        },
        {
            case: "Test if empty password allows login",
            email: @validEmail,
            password: "empty",
            expect: "unable to login"
        },
        {
            case: "Test if empy email and empty password allows login by clicking login",
            email: "empty",
            password: "empty",
            expect: "unable to login"
        },
        {
            case: "Test SQL injection attack in email field",
            email: "xxx@xxx.xxx' OR 1 = 1 LIMIT 1 -- ' ]",
            password: @validPW,
            expect: "unable to login"
        },
        {
            case: "Test SQL injection attack into password field",
            email: @validEmail,
            password: "password' OR 1=1",
            expect: "unable to login"
        },
        {
            #I'm not concerned about inserting iframe into login field, but if this were a comment field
            #then database could serve up iframe and/or script to other users if field not sanitized
            case: "Test cross-scripting vulnerability",
            email: 'N"> == $0 <iframe src="http:\/\/www.hotmail.com" class="box"></iframe><input type="text', 
            password: "<script>let i = 0; do{i++}while(true);</script>",      
            expect: "unable to login",
            assert: Proc.new {|driver|
                input = $page[:login][:email].call(driver).attribute("value")
                puts input.match(/[<>=]+/) ? "Secondary test failed: input not sanitized, dangerous characters remain" : "Secondary test passed: dangerous characters sanitized"
            } 
        }
    ]


    #Functions that will be called in the following tests
    def getLoginPage(driver)
        driver.navigate.to $page[:URL][:home]
        $page[:topBar][:login].call(driver).click
    end

    def signOut(driver) 
        $page[:topBar][:logout].call(driver).click
    end

    def validSignIn(driver) 
        $page[:login][:email].call(driver).send_keys @validEmail
        $page[:login][:passwd].call(driver).send_keys @validPW
        $page[:login][:submitLogin].call(driver).click
    end

    #Each of these functions are self-contained tests that can be run individually or as part of test suite
    def createAccount(driver) 
        puts "Test ability to create new account"
        getLoginPage(driver)
        loop = true
        i = 0;
        while loop && i < @emails.length
            loop = false;
            $page[:login][:emailCreate].call(driver).send_keys @emails[i] 
            $page[:login][:submitCreate].call(driver).click
            sleep(2) 
            begin
                $page[:createAccount][:firstname].call(driver) 
            rescue
                puts "Invalid/taken email, try another email"
                i += 1
                loop = true;
            end   
                $page[:login][:emailCreate].call(driver).clear if loop 
        end 

        #Fill out the required fields in create account form
        $page[:createAccount][:firstname].call(driver).send_keys "John"
        $page[:createAccount][:lastname].call(driver).send_keys "Johnson"
        $page[:createAccount][:password].call(driver).send_keys @password
        $page[:createAccount][:address1].call(driver).send_keys "123 Fake St"
        $page[:createAccount][:city].call(driver).send_keys "NYC"
        $page[:createAccount][:state].call(driver).click
        $page[:createAccount][:stateNY].call(driver).click
        $page[:createAccount][:postcode].call(driver).send_keys "12345"
        $page[:createAccount][:mobile].call(driver).send_keys "5194752345"
        $page[:createAccount][:alias].call(driver).send_keys "321 Fake St"
        $page[:createAccount][:submitAccount].call(driver).click
        sleep(2) 
        title = driver.title
        puts title == $page[:account][:title] ? "Test pass: Account successfully created." : "Test fail: Failed to create account" 
        signOut(driver)
    end

    def testSignIn(driver) 
        puts "Initiate test of various email and password values"
        getLoginPage(driver)
        @testCases.each do |x|
            puts x[:case]
            puts "Login with email: #{x[:email]}, password: #{x[:password]}"
            $page[:login][:email].call(driver).send_keys x[:email] if x[:email] != "empty"
            $page[:login][:passwd].call(driver).send_keys x[:password] if x[:password] != "empty"
            $page[:login][:submitLogin].call(driver).click
            title = driver.title
            if title == $page[:account][:title] 
                if x[:expect] == "logged in" 
                    puts "Test passed: login successful"
                else
                    puts "Test failed: login should not be successful"
                end
                $page[:topBar][:logout].call(driver).click
            else
                if x[:expect] == "unable to login" 
                    puts "Test passed: could not login"
                else
                    puts "Test failed: should be able to login"
                end
                if x.has_key? :assert 
                    x[:assert].call(driver);
                end
                $page[:login][:email].call(driver).clear
                $page[:login][:passwd].call(driver).clear
            end #if title       
        end #each 
    end #testSignIn

    def testForgotPW(driver)
        puts "Test if can click forgot password link, which should take you to another page"
        getLoginPage(driver)
        $page[:login][:forgotPW].call(driver).click
        title = driver.title
        puts title == $page[:forgotPW][:title] ? "Test passed: Forgot password link works": "Test failed: Forgot password link does not work"
    end

    def postAccountURLTest(driver)
        puts "Test if can access account after logout by posting account URL"
        getLoginPage(driver)
        validSignIn(driver)
        signOut(driver)
        driver.navigate.to $page[:URL][:home]
        title = driver.title
        puts title == $page[:account][:title] ? "Test failed: Posting account URL after logout allows access back into account" : "Test passed: Posting account URL after logout does not allow re-entry to account"
    end

    def testEnterButton(driver)
        puts "Test enter button after entering valid login credentials"
        getLoginPage(driver)
        $page[:login][:email].call(driver).send_keys @validEmail
        $page[:login][:passwd].call(driver).send_keys @validPW
        $page[:login][:passwd].call(driver).send_keys :enter
        sleep(2) 
        title = driver.title
        if title == $page[:account][:title]
            puts "Test passed: logged in successfully using enter button"
            puts "Test if pressing back logs out user"
            driver.navigate.back
            driver.navigate.forward
            title = driver.title
            puts title == $page[:account][:title] ? "Test passed: pressing back does not log out user" : "Test failed: pressing back logs out user"
            
        else
            puts "Test failed: pressing enter after correct login credentials does not log in user" 
        end
        signOut(driver)
    end

    def multiLoginAttempt(driver)
        puts "Test how many times I can attempt to login with valid email"
        getLoginPage(driver)
        $page[:login][:email].call(driver).send_keys @validEmail
        5.times do 
            $page[:login][:passwd].call(driver).send_keys rand(100)
            $page[:login][:submitLogin].call(driver).click
        end
        $page[:login][:passwd].call(driver).clear
        $page[:login][:passwd].call(driver).send_keys @validPW
        $page[:login][:submitLogin].call(driver).click
        title = driver.title
        puts title == $page[:account][:title] ? "Test failed: Multi-login attempts allowed" : "Test passed: Multi-login attempts not allowed"
        signOut(driver)
    end

    def copyPastePassword(driver)
        puts "Test if password is visible/can be copied"
        getLoginPage(driver)
        elem = $page[:login][:passwd].call(driver)
        elem.send_keys "CopyMe"
        elem.send_keys [:control, 'a']
        elem.send_keys [:control, 'c']
        elem2 = $page[:login][:email].call(driver)
        elem2.send_keys [:control, 'v']
        elem2.send_keys [:enter]
        input = elem2.attribute("value")
        puts input != "CopyMe" ? "Test passed: Cannot copy and paste password" : "Test failed: Password successfully copied and pasted"
    end

    def getPasswordByValue(driver)
        puts "Test if password still stored in history after signing out" 
        getLoginPage(driver)
        elem = $page[:login][:passwd].call(driver)
        elem.send_keys @validPW
        elem.send_keys :enter  
        sleep(2) 
        elem2 = $page[:login][:email].call(driver)
        elem2.send_keys @validEmail
        elem2.send_keys :enter
        sleep(2) 
        signOut(driver)
        sleep(2) 
        driver.navigate.back
        driver.navigate.back
        sleep(2) 
        input = $page[:login][:passwd].call(driver).attribute("value")
        puts input == @validPW ? "Test failed: Your password is: #{@validPW}" : "Test passed: I cannot see your password"
    end

    def openNewBrowser(driver)
        puts "Test if opening new browser while logged-in allows you to sign-in again"
        getLoginPage(driver)
        validSignIn(driver) 
        driver2 = Selenium::WebDriver.for :firefox
        driver2.navigate.to $page[:URL][:home]
        testPass = true;
        begin
            $page[:topBar][:account].call(driver2)
        rescue
            testPass = false;
            puts "Test failed: opening new browser while logged-in allows you to sign in again"
        end    
        puts "Test passed: opening new browser while logged-in does not allow you to sign in again with another account" if testPass
        signOut(driver)
    end

end #Tests module  