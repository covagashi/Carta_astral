import requests
import json
from datetime import datetime, timedelta
import os

def get_horoscope(locale='es_ES'):
    url = 'https://www.losarcanos.com/wp-remote/horoscopowp.php'
    params = {
        'l': locale,
        'u': 'http://example.com'
    }
    response = requests.get(url, params=params)
    
    if response.status_code == 200:
        return response.json()
    else:
        return f"Error: {response.status_code}"

def save_weekly_horoscope(horoscope_data):
    # Obtener la fecha del próximo domingo
    today = datetime.now()
    days_until_sunday = (6 - today.weekday()) % 7
    next_sunday = today + timedelta(days=days_until_sunday)
    filename = f"horoscope_latest.json"

    # Agregar metadatos a los datos
    horoscope_data['timestamp'] = datetime.now().isoformat()
    horoscope_data['valid_from'] = next_sunday.isoformat()
    horoscope_data['valid_until'] = (next_sunday + timedelta(days=6)).isoformat()

    # Guardar los datos en un archivo JSON !
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(horoscope_data, f, ensure_ascii=False, indent=4)

    print(f"Horóscopo semanal guardado en {filename}")

def get_and_save_weekly_horoscope():
    horoscope_data = get_horoscope()
    
    if isinstance(horoscope_data, dict):
        save_weekly_horoscope(horoscope_data)
        print("El horóscopo semanal ha sido actualizado.")
    else:
        print(horoscope_data)  # Imprime el mensaje de error si algo salió mal

if __name__ == "__main__":
    get_and_save_weekly_horoscope()