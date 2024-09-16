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
    # Crear una cadena con los datos de entrada
    input_data = f"{nombre}{fecha_nacimiento}{hora_nacimiento}"
    
    # Generar un hash MD5 de los datos de entrada
    hash_object = hashlib.md5(input_data.encode())
    hash_hex = hash_object.hexdigest()
    
    # Obtener un timestamp actual en milisegundos
    timestamp = int(time.time() * 1000)
    
    # Combinar el timestamp con los primeros 8 caracteres del hash
    return f"{timestamp}_{hash_hex[:8]}"



def generate_png_from_data(data):
    chrome_options = Options()
    chrome_options.add_argument("--headless")
    driver = webdriver.Chrome(options=chrome_options)

    try:
        latitude = data['latitud']  # Usamos la latitud recibida
        longitude = data['longitud']  # Usamos la longitud recibida
        date = f"{data['ano']}-{data['mes'].zfill(2)}-{data['dia'].zfill(2)}"
        time_str = f"{data['hora'].zfill(2)}:{data['minutos'].zfill(2)}:00"

        logger.info(f"Generando PNG con: Lat: {latitude}, Long: {longitude}, Fecha: {date}, Hora: {time_str}")

        html_path = Path(r'C:\Users\daviann\Documents\Scripts\PROGRAMACION\Carta_astral\scrapping\demo.html').absolute()
        driver.get(f"file:///{html_path}")

        WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.TAG_NAME, "body")))

        driver.execute_script(f"""
            document.getElementById('latitude').value = '{latitude}';
            document.getElementById('longitude').value = '{longitude}';
            document.getElementById('date').value = '{date}';
            document.getElementById('time').value = '{time_str}';
            document.querySelector('button[type="submit"]').click();
        """)

        WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.TAG_NAME, "svg")))

        svg_content = driver.find_element(By.TAG_NAME, "svg").get_attribute("outerHTML")

        png_data = cairosvg.svg2png(bytestring=svg_content)

        timestamp = int(time.time() * 1000)
        png_filename = f'carta_natal_{timestamp}.png'
        png_path = Path(png_filename)

        with png_path.open('wb') as f:
            f.write(png_data)

        logger.info(f"PNG guardado como '{png_path.absolute()}'")
        return png_path

    except Exception as e:
        logger.error(f"Error al generar PNG: {str(e)}")
        logger.error(f"Traceback: {traceback.format_exc()}")
        return None

    finally:
        driver.quit()

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
    latitud = data['latitud']  # Nueva línea
    longitud = data['longitud']  # Nueva línea

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