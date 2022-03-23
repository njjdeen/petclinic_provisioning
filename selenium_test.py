'''
This script executes a UI test on petclinic website using selenium. This is done by checking if every webpage can be accessed correctly.
'''



from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import Select
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
options = Options()
options.headless = True


## Get URL of testing VM

with open('/home/VMadmin/testvm_public_IP', 'r') as file:
    base_url = file.read().rstrip()

url = "http://" + base_url + ":8080/petclinic"

print(f"Connecting to {url}")

def petclinic_test():
    #initialize driver
    driver = webdriver.Chrome("/usr/bin/chromedriver", options=options)

    driver.get(url)

    #driver waits 5 seconds when necesarry to load the pages
    driver.implicitly_wait(30)


    #check if homebutton works
    #driver.find_element(By.XPATH,"//div[@id='main-navbar']/ul/li/a/span[2]").click()

    #navigate to find owners section and search for last name
    #driver.find_element(By.LINK_TEXT, "Find owners").click()
    driver.find_element(By.XPATH,'//*[@title="find owners"]').click()

    driver.find_element(By.NAME,"lastName").click()
    driver.find_element(By.NAME,"lastName").clear()
    driver.find_element(By.NAME,"lastName").send_keys("Deen")
    #driver.find_element(By.XPATH,"//button[@type='submit']").click()

    #check if edit owner button works, edit and update data (name, address, city, phone number)
    driver.find_element(By.LINK_TEXT,"Add Owner").click()
    driver.find_element(By.ID,"firstName").clear()
    driver.find_element(By.ID,"firstName").send_keys("Niels")
    driver.find_element(By.ID,"lastName").click()
    driver.find_element(By.ID,"lastName").clear()
    driver.find_element(By.ID,"lastName").send_keys("Deen")
    driver.find_element(By.ID,"address").click()
    driver.find_element(By.ID,"address").clear()
    driver.find_element(By.ID,"address").send_keys("Sesamstraat")
    driver.find_element(By.ID,"city").click()
    driver.find_element(By.ID,"city").clear()
    driver.find_element(By.ID,"city").send_keys("Volendam")
    driver.find_element(By.ID,"telephone").click()
    driver.find_element(By.ID,"telephone").clear()
    driver.find_element(By.ID,"telephone").send_keys("042330923")
    driver.find_element(By.XPATH,"//button[@type='submit']").click()

    #add new pet for current owner
    driver.find_element(By.LINK_TEXT,"Add New Pet").click()
    Select(driver.find_element(By.ID,"type")).select_by_visible_text("dog")
    driver.find_element(By.XPATH,"//option[@value='dog']").click()
    driver.find_element(By.ID,"name").click()

    #find original name for new dog pet
    correct_name = False
    i = 1
    while correct_name == False:
        try: 
            driver.find_element(By.ID,"name").clear()
            driver.find_element(By.ID,"name").send_keys(f"hond{i}")
            driver.find_element(By.ID,"birthDate").click()
            driver.find_element(By.LINK_TEXT,"17").click()
            driver.find_element(By.XPATH,"//button[@type='submit']").click()
            i = i + 1

            #if it didn't work the following line will raise an exception
            correct_name = True
        except:
            print("name was already taken, trying a different name...")
    #add visit for one of the pets with description "mauw"
    driver.find_element(By.LINK_TEXT,"Add Visit").click()
    driver.find_element(By.ID,"description").click()
    driver.find_element(By.ID,"description").clear()
    driver.find_element(By.ID,"description").send_keys("whoof waf")
    driver.find_element(By.XPATH,"//button[@type='submit']").click()

    #search for veterinarians by clicking on the corresponding tab and request a JSON file for them
    driver.find_element(By.XPATH,"//div[@id='main-navbar']/ul/li[3]/a/span[2]").click()
    driver.find_element(By.LINK_TEXT,"View as JSON").click()
    driver.back()
    #navigate to final error tab
    driver.find_element(By.XPATH,'//*[@title="trigger a RuntimeException to see how it is handled"]').click()

#execute the function, if exceptions occur print the exception

if __name__ == "__main__":
    try:
        petclinic_test()
    except Exception as e:
        print(f"EXCEPTION OCCURRED: {e}")


