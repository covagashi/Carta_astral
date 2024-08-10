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

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def fetch_astrology_data(nombre, dia, mes, ano, hora, minutos, pais, estado, ciudad):
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


def main(nombre, dia, mes, ano, hora, minutos, pais, estado, ciudad):
    # Paso 1: Obtener datos astrológicos
    html_content = fetch_astrology_data(nombre, dia, mes, ano, hora, minutos, pais, estado, ciudad)
    
    if html_content:
        # Paso 2: Limpiar el contenido HTML
        cleaned_html = clean_html_content(html_content)
        
        # Paso 3: Convertir HTML a JSON
        json_data = html_to_json(cleaned_html)
        
        # Generar un ID optimizado
        fecha_nacimiento = f"{dia}/{mes}/{ano}"
        hora_nacimiento = f"{hora}:{minutos}"
        carta_natal_id = generate_optimized_chart_id(nombre, fecha_nacimiento, hora_nacimiento)
        
        # Guardar el resultado en un archivo JSON con ID optimizado
        output_filename = f'carta_natal_{carta_natal_id}.json'
        with open(output_filename, 'w', encoding='utf-8') as json_file:
            json.dump(json_data, json_file, ensure_ascii=False, indent=4)
        
        print(f"Proceso completado. El resultado se ha guardado en '{output_filename}'.")
        return output_filename
    else:
        print("No se pudo obtener los datos astrológicos.")
        return None

if __name__ == "__main__":
    # Ejemplo de uso
    nombre = "Ejemplo Nombre"
    dia = "05"
    mes = "04"
    ano = "1994"
    hora = "11"
    minutos = "40"
    pais = "100"
    estado = "166"
    ciudad = "62800"
    
    output_file = main(nombre, dia, mes, ano, hora, minutos, pais, estado, ciudad)
    if output_file:
        print(f"Archivo JSON generado: {output_file}")
    else:
        print("No se pudo generar el archivo JSON.")
