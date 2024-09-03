import json
from pathlib import Path
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import Select

# Configurar el driver de Chrome en modo headless
chrome_options = Options()
chrome_options.add_argument("--headless")
driver = webdriver.Chrome(options=chrome_options)

# Cargar datos del archivo JSON
json_path = Path(r'C:\Users\daviann\Documents\Scripts\PROGRAMACION\Carta_astral\scrapping\wheel3\carta_natal.json')
with json_path.open('r') as file:
    data = json.load(file)

# Extraer datos necesarios
latitude = data['native']['coordinates']['latitude']['raw']
longitude = data['native']['coordinates']['longitude']['raw']
date = data['native']['date_time']['datetime'].split()[0]
time = data['native']['date_time']['datetime'].split()[1].split('-')[0]

# Cargar la página HTML
html_path = Path(r'C:\Users\daviann\Documents\Scripts\PROGRAMACION\Carta_astral\scrapping\wheel3\demo.html').absolute()
driver.get(f"file:///{html_path}")

# Rellenar el formulario
driver.find_element(By.ID, "latitude").clear()
driver.find_element(By.ID, "latitude").send_keys(str(latitude))
driver.find_element(By.ID, "longitude").clear()
driver.find_element(By.ID, "longitude").send_keys(str(longitude))
driver.find_element(By.ID, "date").clear()
driver.find_element(By.ID, "date").send_keys(date)
driver.find_element(By.ID, "time").clear()
driver.find_element(By.ID, "time").send_keys(time)

# Seleccionar el idioma español
#select = Select(driver.find_element(By.ID, "language-select"))
#select.select_by_visible_text("español")


# Hacer clic en el botón Submit
driver.find_element(By.CSS_SELECTOR, "button[type='submit']").click()

# Esperar a que se genere el SVG
wait = WebDriverWait(driver, 10)
svg = wait.until(EC.presence_of_element_located((By.TAG_NAME, "svg")))

# Obtener el contenido del SVG
svg_content = svg.get_attribute("outerHTML")

# Guardar el SVG en un archivo
svg_path = Path('carta_natal.svg')
svg_path.write_text(svg_content, encoding='utf-8')

print(f"SVG guardado como '{svg_path.absolute()}'")

# Cerrar el navegador
driver.quit()