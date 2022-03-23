from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import Select
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
options = Options()
options.headless = True

#find out what the host ip of testing VM is
with open('/home/VMadmin/testvm_public_IP', 'r') as file:
    base_url = file.read().rstrip()

url = "http://" + base_url + ":8080/petclinic"

print(f"Connecting to {url}....")

#initialize chrome driver in headless mode
driver = webdriver.Chrome("/usr/bin/chromedriver", options=options)

no_connection = True

while no_connection:
    try:    
        driver.get(url)

        #driver waits 5 seconds when necesarry to load the pages
        driver.implicitly_wait(10)
        
    except:
        print("Webserver is not up yet, retrying within 10 seconds...")
    else:
        no_connection = False