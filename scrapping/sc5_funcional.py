import requests
import json
import logging
from bs4 import BeautifulSoup

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# URL del formulario
url = "https://www.losarcanos.com/carta-astral-pdf.php"

# Datos del formulario
data = {
    "nombre": "Ejemplo Nombre",
    "dia": "04",
    "mes": "05",
    "ano": "1994",
    "hora": "11",
    "minutos": "40",
    "pais": "100",  # España
    "estado": "166",  # Barcelona
    "ciudad": "62800",  # Agell
    "action": "",
    "geoloc": "2",
    "V5": ""
}

try:
    # Enviar solicitud POST
    response = requests.post(url, data=data)
    logger.info("Solicitud POST enviada")

    # Verificar si la solicitud fue exitosa
    if response.status_code == 200:
        logger.info("Solicitud exitosa")
        
        
        
        with open("carta_astral.pdf", "wb") as f:
            f.write(response.content)
        logger.info("PDF guardado como 'carta_astral.pdf'")
        
      
        
       
       

except Exception as e:
    logger.error(f"Error en el script: {str(e)}")
    import traceback
    logger.error(f"Traceback: {traceback.format_exc()}")