import logging
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import Select
from selenium.common.exceptions import NoSuchElementException, TimeoutException, ElementClickInterceptedException
from selenium.webdriver.chrome.options import Options
import json
import time
import argparse

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def wait_for_element(driver, by, value, timeout=20):
    return WebDriverWait(driver, timeout).until(
        EC.presence_of_element_located((by, value))
    )

def get_select_options(select_element):
    return [{"name": option.text, "code": option.get_attribute("value")}
            for option in select_element.options if option.get_attribute("value")]

def save_data(data):
    with open('locaciones_astrologicas.json', 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    logging.info("Datos actualizados guardados en 'locaciones_astrologicas.json'")

def click_element(driver, element):
    try:
        element.click()
    except ElementClickInterceptedException:
        driver.execute_script("arguments[0].click();", element)

def scrape_locations(target_country=None):
    chrome_options = Options()
    chrome_options.add_argument("--disable-notifications")
    chrome_options.add_argument("--disable-infobars")
    chrome_options.add_argument("--disable-extensions")
    chrome_options.add_argument("--disable-gpu")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    chrome_options.add_argument("--start-maximized")

    driver = webdriver.Chrome(options=chrome_options)
    url = "https://www.losarcanos.com/carta-astral-2.php"
    data = {"countries": []}

    try:
        driver.get(url)
        WebDriverWait(driver, 3).until(EC.presence_of_element_located((By.TAG_NAME, "body")))

        country_select = wait_for_element(driver, By.ID, "pais")
        countries = get_select_options(Select(country_select))
        time.sleep(10)

        for country in countries:  
            if target_country and country['name'] != target_country:
                continue

            logging.info(f"Procesando país: {country['name']}")
            country_data = {"name": country['name'], "code": country['code'], "provinces": []}

            Select(driver.find_element(By.ID, "pais")).select_by_value(country['code'])
            time.sleep(2)

            try:
                calcular_button = wait_for_element(driver, By.XPATH, "//button[contains(text(), 'Calcular tu Carta Astral')]")
                click_element(driver, calcular_button)
                time.sleep(2)

                province_select = wait_for_element(driver, By.ID, "ciudad", timeout=5)
                provinces = get_select_options(Select(province_select))

                for province in provinces: 
                    logging.info(f"  Procesando provincia: {province['name']}")
                    province_data = {"name": province['name'], "code": province['code'], "cities": []}

                    Select(driver.find_element(By.ID, "ciudad")).select_by_value(province['code'])
                    time.sleep(2)
                    
                    city = ""

                    province_data["cities"].append({
                        "name": city,
                        "code": ""
                    })

                    # Guardar datos después de procesar todas las ciudades de una provincia
                    if province_data not in country_data["provinces"]:
                        country_data["provinces"].append(province_data)
                    if country_data not in data["countries"]:
                        data["countries"].append(country_data)
                    save_data(data)                    

                # Guardar datos después de procesar cada país
                save_data(data)

                # Volver a la página inicial para el siguiente país
                driver.get(url)
                WebDriverWait(driver, 3).until(EC.presence_of_element_located((By.ID, "pais")))
                time.sleep(2)

            except (NoSuchElementException, TimeoutException) as e:
                logging.error(f"  Error al procesar {country['name']}: {str(e)}")
                driver.get(url)
                WebDriverWait(driver, 3).until(EC.presence_of_element_located((By.ID, "pais")))

    except Exception as e:
        logging.error(f"Se produjo un error: {e}")
        logging.error(f"URL actual: {driver.current_url}")
        logging.error(f"Código fuente de la página:")
        logging.error(driver.page_source[:1000])

    finally:
        driver.quit()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Scrape astrological locations')
    parser.add_argument('--pais', type=str, help='Nombre del país para hacer scraping (opcional)')
    args = parser.parse_args()

    scrape_locations(args.pais)