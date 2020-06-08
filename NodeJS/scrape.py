import pandas as pd
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.expected_conditions import (
    presence_of_element_located)
from selenium.webdriver.support.wait import WebDriverWait


#*******************************************************************************
#*****************************WORLD MAP******************************************
#*******************************************************************************

#define webdriver as Chrome webdriver
driver = webdriver.Chrome()
url = 'https://coronavirus.jhu.edu/map.html'
driver.get(url)
iframe = driver.find_element_by_tag_name('iframe')
iframe_url = iframe.get_attribute('src')
driver.get(iframe_url)
wait = WebDriverWait(driver, 60)

# wait for the web elements to be uploaded
world_newCases_Present = presence_of_element_located(
    (By.CLASS_NAME, 'amcharts-graph-column'))
wait.until(world_newCases_Present)

world_ccnum_daily_Present = presence_of_element_located(
    (By.CLASS_NAME, 'amcharts-chart-div'))
wait.until(world_ccnum_daily_Present)

country_ccnum_Present = presence_of_element_located(
    (By.CLASS_NAME, 'feature-list'))
wait.until(country_ccnum_Present)

country_tot_deaths_Present = presence_of_element_located(
    (By.ID, 'ember111'))
wait.until(country_tot_deaths_Present)

states_tot_deaths_Present = presence_of_element_located(
    (By.ID, 'ember139'))
wait.until(states_tot_deaths_Present)



# scrape the data and save them to CSV files for each index


#*******************************************************************************
#*****************************World Level******************************************


#*****************************Cumulated Cases******************************************

# get world daily confirmed cases count
# world_ccnum_daily_Present = presence_of_element_located(
#     (By.CLASS_NAME, 'amcharts-chart-div'))
# wait.until(world_ccnum_daily_Present)

world_ccnum_daily_top_element = driver.find_element_by_class_name('amcharts-chart-div')
# print(a)
world_ccnum_daily_leave_element = world_ccnum_daily_top_element.find_elements_by_tag_name('circle')

cal = {'Jan':'01', 'Feb':'02', 'Mar':'03', 'Apr':'04', 'May':'05',
      'Jun':'06', 'Jul':'07', 'Aug':'08', 'Sep':'09', 'Oct':'10', 
      'Nov':'11', 'Dec':'12'}

world_ccnum_daily = []
for cir in world_ccnum_daily_leave_element:
    s = cir.get_attribute('aria-label')
    l = s.replace(',', '').split(' ')
    l[1] = cal[l[1]]
    date = int(l[3] + l[1] + l[2])
    confirmed = int(l[4])
#     ccnum =
#     print(type(country))
#     print(type(ccnum))
    world_ccnum_daily.append((date, confirmed))
# print(world_ccnum_daily)

df_world_ccnum_daily = pd.DataFrame(world_ccnum_daily, columns= ['date', 'confirmed'])
df_world_ccnum_daily.to_csv(r'./data/world_cumulative_confirmed.csv', index = False)



#*****************************New Cases******************************************


#get daily confirmed new cases -- world level
# world_newCases_Present = presence_of_element_located(
#     (By.CLASS_NAME, 'amcharts-graph-column'))
# wait.until(world_newCases_Present)

world_newCases_top_element= driver.find_elements_by_class_name('amcharts-graph-column')
world_newCases = []
# print(type(a))
for i in world_newCases_top_element:      
    s = i.get_attribute('aria-label')
    if( s == None ):
        continue  
    l = s.replace(',', '').split(' ')
#     print(l)
    l[1] = cal[l[1]]
    date = int(l[3] + l[1] + l[2])
    newCases = int(l[4])
#     ccnum =
#     print(type(country))
#     print(type(ccnum))
    world_newCases.append((date, newCases))
# print(world_newCases)

df_world_newCases = pd.DataFrame(world_newCases, columns= ['date', 'newCases'])
df_world_newCases.to_csv(r'./data/world_newCases.csv', index = False)


#*******************************************************************************
#*****************************Country Level******************************************

#**************************confirmed cases********************************************
# wait for the target element
# country_ccnum_Present = presence_of_element_located(
#     (By.CLASS_NAME, 'feature-list'))
# wait.until(country_ccnum_Present)
 
country_ccnum_top_element = driver.find_element_by_class_name(
    'feature-list')
country_ccnum_leave_element = country_ccnum_top_element.text.split('\n')
# print(country_ccnum_leave_element)


country_ccnum = []
for i in country_ccnum_leave_element:
    ccnum = int(i.split(' ', 1)[0].replace(',', ''))
    country = i.split(' ', 1)[1].upper()
    if(country == 'KOREA, SOUTH'):
        country = 'SOUTH KOREA'
#     print(type(country))
#     print(ccnum)
    country_ccnum.append((ccnum, country))
# print(country_ccnum)

# country_confirmed.csv
df_country_ccnum = pd.DataFrame(country_ccnum, columns= ['confirmed' , 'country'])
df_country_ccnum.to_csv(r'./data/country_cumulative_confirmed.csv', index = False)


#*****************************Deaths Cases******************************************

# get total deaths cases -- country level
# country_tot_deaths_Present = presence_of_element_located(
#     (By.ID, 'ember111'))
# wait.until(country_tot_deaths_Present)
 
country_tot_deaths_top_element = driver.find_element_by_id(
    'ember111')
country_tot_deaths_second_element = country_tot_deaths_top_element.find_element_by_class_name('feature-list')
country_tot_deaths_leave_element = country_tot_deaths_second_element.text.replace(',', '').split('\n')
# print(comment_count)
le = len(country_tot_deaths_leave_element)
# print(le)
country = []
tot_deaths = []
for i in range(le):
    if(i%2 == 0):
        s = country_tot_deaths_leave_element[i].split(' ')
        cases = int(s[0])
        tot_deaths.append(cases)
    else:
        s = country_tot_deaths_leave_element[i].upper()
        if(s == 'KOREA, SOUTH'):
            s = 'SOUTH KOREA'
        country.append(s)
# print(country)
# print(tot_deaths)

country_tot_deaths = list(zip(country, tot_deaths))  
# print(type(country_tot_deaths))
# print(country_tot_deaths)

df_country_tot_deaths = pd.DataFrame(country_tot_deaths, columns = ['country', 'deaths'])
df_country_tot_deaths.to_csv(r'./data/country_cumulative_deaths.csv', index=False)




#*******************************************************************************
#*****************************US State Level******************************************

#*****************************Deaths Cases******************************************



# get total deaths -- US state level
# states_tot_deaths_Present = presence_of_element_located(
#     (By.ID, 'ember139'))
# wait.until(states_tot_deaths_Present)
 
states_tot_deaths_top_element = driver.find_element_by_id(
    'ember139')
states_tot_deaths_mid_element = states_tot_deaths_top_element.find_element_by_class_name('feature-list')
states_tot_deaths_leave_element = states_tot_deaths_mid_element.text.replace(',', '').split('\n')
# print(states_tot_deaths_leave_element)

le = len(states_tot_deaths_leave_element)
# print(le)
states = []
tot_deaths = []
for i in range(le):
    if(i%2 == 0):
        s = states_tot_deaths_leave_element[i].split(' ')
        deaths = int(s[0])
        tot_deaths.append(deaths)
    else:
        s = states_tot_deaths_leave_element[i].replace(' US', '').upper()
        states.append(s)
# print(states)
# print(tot_deaths)

states_tot_deaths = list(zip(states, tot_deaths))  
# print(type(states_tot_deaths))
# print(states_tot_deaths)

df_states_tot_deaths = pd.DataFrame(states_tot_deaths, columns = ['state', 'deaths'])
df_states_tot_deaths.to_csv(r'./data/states_cumulative_deaths.csv', index=False)



driver.close()
driver.quit()

print('Scraping finished \n')

