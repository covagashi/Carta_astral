import json
import os

def split_json_by_country(input_file, output_directory):
    # Crear el directorio de salida si no existe
    if not os.path.exists(output_directory):
        os.makedirs(output_directory)

    # Leer el archivo JSON grande
    with open(input_file, 'r', encoding='utf-8') as f:
        data = json.load(f)

    # Iterar sobre cada país y crear un archivo separado
    for country in data['countries']:
        country_name = country['name'].replace(' ', '_').lower()
        output_file = os.path.join(output_directory, f'{country_name}.json')
        
        # Crear un nuevo diccionario con solo la información del país actual
        country_data = {
            "name": country['name'],
            "code": country['code'],
            "provinces": country['provinces']
        }
        
        # Escribir el archivo JSON para el país actual
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(country_data, f, ensure_ascii=False, indent=2)
        
        print(f"Archivo creado: {output_file}")

    print("Proceso completado.")

# Uso del script
input_file = 'locaciones_astrologicas.json'  # Reemplaza con el nombre de tu archivo JSON grande
output_directory = 'paises'  # Directorio donde se guardarán los archivos divididos

split_json_by_country(input_file, output_directory)
