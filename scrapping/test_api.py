import requests
import json
import base64
from pathlib import Path

# Datos de la solicitud
data = {
    "nombre": "Test",
    "dia": "01",
    "mes": "01",
    "ano": "2000",
    "hora": "12",
    "minutos": "00",
    "pais": "España",
    "estado": "Madrid",
    "ciudad": "Madrid",
    "latitud": "40.4168",
    "longitud": "-3.7038"
}

# Realizar la solicitud
print("Enviando solicitud a la API...")
response = requests.post(
    "https://covaga.xyz/generate_carta_natal",
    json=data,
    headers={"Content-Type": "application/json"}
)

if response.status_code == 200:
    # Guardar la respuesta completa
    response_data = response.json()
    
    # Guardar los datos JSON (sin la imagen)
    data_without_image = {k: v for k, v in response_data.items() if k != 'image'}
    with open('carta_natal_data.json', 'w', encoding='utf-8') as f:
        json.dump(data_without_image, f, ensure_ascii=False, indent=2)
    
    # Guardar la imagen
    image_data = base64.b64decode(response_data['image'])
    with open('carta_natal.png', 'wb') as f:
        f.write(image_data)
    
    print("\nArchivos generados:")
    print("- carta_natal_data.json: Datos de la carta natal")
    print("- carta_natal.png: Imagen de la carta natal")
    
    # Mostrar tamaños de archivos
    data_file = Path('carta_natal_data.json')
    image_file = Path('carta_natal.png')
    print(f"\nTamaños de archivos:")
    print(f"JSON: {data_file.stat().st_size:,} bytes")
    print(f"Imagen: {image_file.stat().st_size:,} bytes")
else:
    print(f"Error: {response.status_code}")
    print(response.text)
