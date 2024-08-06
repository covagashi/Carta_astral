import requests
from bs4 import BeautifulSoup
import json
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# URL del formulario
url = "https://www.losarcanos.com/carta-astral-2.php"

# Configurar la sesión
session = requests.Session()

# Headers para simular un navegador
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
    # Obtener la página del formulario
    response = session.get(url, headers=headers)
    soup = BeautifulSoup(response.text, 'html.parser')

    # Buscar tokens ocultos
    hidden_inputs = soup.find_all("input", type="hidden")
    form_data = {input.get('name'): input.get('value') for input in hidden_inputs}

    # Añadir los datos del formulario
    form_data.update({
        "nombre": "Ejemplo Nombre",
        "dia": "05",
        "mes": "04",
        "ano": "1994",
        "hora": "11",
        "minutos": "40",
        "pais": "100",
        "estado": "166",
        "ciudad": "62800",
        "action": "",
        "geoloc": "2",
    })

    # URL para enviar el formulario (puede ser diferente de la URL inicial)
    submit_url = "https://www.losarcanos.com/carta-astral-resu-m.php"

    # Enviar el formulario
    response = session.post(submit_url, data=form_data, headers=headers)
    logger.info(f"Formulario enviado. Status code: {response.status_code}")
    logger.info(f"URL final: {response.url}")

    # Guardar la respuesta HTML para depuración
    with open("response.html", "w", encoding="utf-8") as f:
        f.write(response.text)
    logger.info("Respuesta HTML guardada en 'response.html'")

    # Procesar la respuesta
    soup = BeautifulSoup(response.text, 'html.parser')

    # Extraer información
    info = {}
    # Obtener el nombre
    nombre_elem = soup.find('h3')
    info['nombre'] = nombre_elem.text.strip() if nombre_elem else "No encontrado"

    # Obtener los elementos de la colección
    collection_items = soup.find('div', class_='collection').find_all('li', class_='collection-item')

    # Procesar cada elemento de la colección
    for item in collection_items:
        text = item.text.strip()
        if ':' in text:
            key, value = text.split(':', 1)
            info[key.strip().lower().replace(' ', '_')] = value.strip()

    # Guardar en JSON
    with open("carta_astral.json", "w", encoding="utf-8") as f:
        json.dump(info, f, ensure_ascii=False, indent=4)

    logger.info("Los resultados se han guardado en 'carta_astral.json'")

except Exception as e:
    logger.error(f"Error en el script: {str(e)}")
    import traceback
    logger.error(f"Traceback: {traceback.format_exc()}")