import requests
from bs4 import BeautifulSoup
import json
import logging
import re
import os
import html
from datetime import datetime
import time
import hashlib
import traceback
from pathlib import Path
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from io import BytesIO
from PIL import Image
import cairosvg

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def fetch_astrology_data(nombre, dia, mes, ano, hora, minutos, pais, estado, ciudad, latitud, longitud):
    url = "https://www.losarcanos.com/carta-astral-2.php"
    session = requests.Session()
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.5',
        'Referer': 'https://www.losarcanos.com/',
        'DNT': '1',
        'Connection': 'keep-alive',
        'Upgrade-Insecure-Requests': '1',
    }

    try:
        response = session.get(url, headers=headers)
        soup = BeautifulSoup(response.text, 'html.parser')
        hidden_inputs = soup.find_all("input", type="hidden")
        form_data = {input.get('name'): input.get('value') for input in hidden_inputs}
        form_data.update({
            "nombre": nombre,
            "dia": dia,
            "mes": mes,
            "ano": ano,
            "hora": hora,
            "minutos": minutos,
            "pais": pais,
            "estado": estado,
            "ciudad": ciudad,
            "action": "",
            "geoloc": "2",
        })

        submit_url = "https://www.losarcanos.com/carta-astral-resu-m.php"
        response = session.post(submit_url, data=form_data, headers=headers)
        logger.info(f"Formulario enviado. Status code: {response.status_code}")
        logger.info(f"URL final: {response.url}")

        return response.text
    except Exception as e:
        logger.error(f"Error en el script: {str(e)}")
        import traceback
        logger.error(f"Traceback: {traceback.format_exc()}")
        return None
def clean_html_content(html_content):
    tags_to_remove = ['img', 'button', 'head', 'script', 'ins', 'hr', 'button', 'style', 'svg', 'footer', 'a', 'br', 'table', 'ul']

    def remove_tags(content, tags):
        for tag in tags:
            pattern = f'<{tag}[^>]*>.*?</{tag}>'
            content = re.sub(pattern, '', content, flags=re.DOTALL)
            pattern = f'<{tag}[^>]*/?>'
            content = re.sub(pattern, '', content)
            if tag == 'a':
                pattern = r'<a\s+[^>]*>.*?</a>'
                content = re.sub(pattern, '', content, flags=re.DOTALL)
        return content

    def remove_content_after_epilogo(content):
        decoded_content = html.unescape(content)
        pattern = r'<h3>\s*Ep(?:í|&iacute;)logo\s*</h3>.*'
        match = re.search(pattern, decoded_content, re.DOTALL | re.IGNORECASE)
        if match:
            start = match.start()
            return decoded_content[:start] + '<h3>Epílogo</h3>'
        return content

    def remove_content_before_prologo(content):
        pattern = r'<h3>\s*Pr(?:ó|&oacute;)logo\s*</h3>'
        match = re.search(pattern, content, re.IGNORECASE)
        if match:
            start = match.start()
            return content[start:]
        return content

    def clean_abandoned_characters(content):
        patterns_to_remove = [
            r'\s*->\s*',
            r'\s*<-\s*',
            r'\s*\d+°\s*\d+\s*',
            r'\s+en\s+',
            r'\s+',
        ]
        for pattern in patterns_to_remove:
            content = re.sub(pattern, ' ', content)
        content = re.sub(r'>\s+<', '><', content)
        content = re.sub(r'^\s+|\s+$', '', content, flags=re.MULTILINE)
        content = re.sub(r'\n\s*\n', '\n', content)
        return content.strip()

    modified_content = remove_content_before_prologo(html_content)
    modified_content = remove_content_after_epilogo(modified_content)
    modified_content = remove_tags(modified_content, tags_to_remove)
    modified_content = clean_abandoned_characters(modified_content)

    return modified_content
def html_to_json(html_content):
    soup = BeautifulSoup(html_content, 'html.parser')
    content = []
    current_section = None

    for element in soup.find_all(['h3', 'p']):
        if element.name == 'h3':
            if current_section:
                content.append(current_section)
            current_section = {
                "id": f"section{len(content) + 1}",
                "title": element.text.strip(),
                "paragraphs": []
            }
        elif element.name == 'p' and current_section:
            current_section["paragraphs"].append(element.text.strip())

    if current_section:
        content.append(current_section)

    result = {
        "metadata": {
            "version": "1.0",
            "lastUpdated": datetime.now().isoformat()
        },
        "content": content
    }

    return result

def generate_optimized_chart_id(nombre, fecha_nacimiento, hora_nacimiento):
    
    input_data = f"{nombre}{fecha_nacimiento}{hora_nacimiento}"

    
    hash_object = hashlib.md5(input_data.encode())
    hash_hex = hash_object.hexdigest()
    
    timestamp = int(time.time() * 1000)

    return f"{timestamp}_{hash_hex[:8]}"


def generate_png_from_data(data):
    chrome_options = Options()
    chrome_options.add_argument("--headless")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    chrome_options.add_argument("--disable-gpu")
    chrome_options.add_argument("--window-size=1920,1080")
    chrome_options.add_argument("--disable-extensions")
    chrome_options.add_argument("--disable-setuid-sandbox")
    chrome_options.add_argument("--disable-web-security")
    chrome_options.add_argument('--remote-debugging-port=9222')
    chrome_options.binary_location = "/usr/bin/chromium-browser"  

    service = webdriver.chrome.service.Service('/usr/bin/chromedriver')  
    try:
        driver = webdriver.Chrome(service=service, options=chrome_options)

        latitude = data['latitud']
        longitude = data['longitud']
        date = f"{data['ano']}-{data['mes'].zfill(2)}-{data['dia'].zfill(2)}"
        time_str = f"{data['hora'].zfill(2)}:{data['minutos'].zfill(2)}:00"

        logger.info(f"Generando PNG con: Lat: {latitude}, Long: {longitude}, Fecha: {date}, Hora: {time_str}")

        html_path = Path(r'/home/ubuntu/carta_astral/demo.html').absolute()
        if not html_path.exists():
            raise FileNotFoundError(f"No se encontró el archivo HTML en {html_path}")

        driver.get(f"file:///{html_path}")
        logger.info("HTML cargado correctamente")

        
        try:
            WebDriverWait(driver, 20).until(EC.presence_of_element_located((By.TAG_NAME, "body")))
            logger.info("Body encontrado")
        except Exception as e:
            logger.error(f"Timeout esperando el body: {str(e)}")
            raise
 
        try:
            driver.execute_script(f"""
                document.getElementById('latitude').value = '{latitude}';
                document.getElementById('longitude').value = '{longitude}';
                document.getElementById('date').value = '{date}';
                document.getElementById('time').value = '{time_str}';
                document.querySelector('button[type="submit"]').click();
            """)
            logger.info("Script ejecutado correctamente")
        except Exception as e:
            logger.error(f"Error ejecutando script: {str(e)}")
            raise

       
        try:
            WebDriverWait(driver, 20).until(EC.presence_of_element_located((By.TAG_NAME, "svg")))
            logger.info("SVG encontrado")
        except Exception as e:
            logger.error(f"Timeout esperando el SVG: {str(e)}")
            raise

        svg_content = driver.find_element(By.TAG_NAME, "svg").get_attribute("outerHTML")
        logger.info("SVG extraído correctamente")

        
        try:
            png_data = cairosvg.svg2png(bytestring=svg_content.encode('utf-8'))
            logger.info("SVG convertido a PNG correctamente")
        except Exception as e:
            logger.error(f"Error convirtiendo SVG a PNG: {str(e)}")
            raise

        timestamp = int(time.time() * 1000)
        png_filename = f'carta_natal_{timestamp}.png'
        png_path = Path(png_filename)

        with png_path.open('wb') as f:
            f.write(png_data)

        logger.info(f"PNG guardado como '{png_path.absolute()}'")
        return png_path

    except Exception as e:
        logger.error(f"Error al generar PNG: {str(e)}")
        logger.error(f"Traceback completo: {traceback.format_exc()}")
        return None

    finally:
            if 'driver' in locals():
                try:
                    driver.quit()
                    logger.info("Driver cerrado correctamente")
                except Exception as e:
                    logger.error(f"Error al cerrar el driver: {str(e)}")


def main(data):


    nombre = data['nombre']
    dia = data['dia']
    mes = data['mes']
    ano = data['ano']
    hora = data['hora']
    minutos = data['minutos']
    pais = data['pais']
    estado = data['estado']
    ciudad = data['ciudad']
    latitud = data['latitud'] 
    longitud = data['longitud'] 
    html_content = fetch_astrology_data(nombre, dia, mes, ano, hora, minutos, pais, estado, ciudad, latitud, longitud)

    if html_content:
        cleaned_content = clean_html_content(html_content)
        json_data = html_to_json(cleaned_content)

        chart_id = generate_optimized_chart_id(nombre, f"{dia}/{mes}/{ano}", f"{hora}:{minutos}")
        json_filename = f"carta_natal_{chart_id}.json"

        with open(json_filename, 'w', encoding='utf-8') as json_file:
            json.dump(json_data, json_file, ensure_ascii=False, indent=2)

        logger.info(f"JSON guardado como '{json_filename}'")

        png_path = generate_png_from_data(data)

        if png_path:
            logger.info(f"PNG generado correctamente: {png_path}")
            return json_filename, png_path
        else:
            logger.error("No se pudo generar el PNG")
            return json_filename, None
    else:
        logger.error("No se pudo obtener el contenido HTML")
        return None, None
