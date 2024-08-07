import PyPDF2
import re
import json
from datetime import datetime


def extract_text_from_page(pdf_path, page_number):
    try:
        with open(pdf_path, 'rb') as file:
            reader = PyPDF2.PdfReader(file)
            if page_number <= len(reader.pages):
                return reader.pages[page_number - 1].extract_text()
            else:
                print(f"El PDF no tiene la página {page_number}.")
                return ""
    except Exception as e:
        print(f"Error al leer la página {page_number} del PDF: {e}")
        return ""
    
def extract_text_from_pdf(pdf_path):
    with open(pdf_path, 'rb') as file:
        reader = PyPDF2.PdfReader(file)
        text = ""
        for page in reader.pages:
            text += page.extract_text()
    return text

def extraer_tablas_casas(text):
    casas = {}
    patron = r'Casa (\d+)(?:\s*\((?:AC|MC)\))?\s*(\d+°\d+\')\s*(\w+)'
    matches = re.findall(patron, text)
    for match in matches:
        casa, grados, signo = match
        casas[f"Casa {casa}"] = {"grados": grados, "signo": signo}
    
    # Corregir el problema de "CapricornioAspectos"
    if "Casa 12" in casas and casas["Casa 12"]["signo"].endswith("Aspectos"):
        casas["Casa 12"]["signo"] = casas["Casa 12"]["signo"].replace("Aspectos", "")
    
    return casas

def extract_text_from_first_page(pdf_path):
    with open(pdf_path, 'rb') as file:
        reader = PyPDF2.PdfReader(file)
        if len(reader.pages) > 0:
            return reader.pages[0].extract_text()
    return ""

def extraer_aspectos(text):
    aspectos = []
    # Buscar la sección de Aspectos
    seccion_aspectos = re.search(r'Aspectos(.*?)(?:\n\n|\Z)', text, re.DOTALL)
    if seccion_aspectos:
        texto_aspectos = seccion_aspectos.group(1)
    else:
        texto_aspectos = text  # Si no se encuentra la sección, usar todo el texto

    # Patrón mejorado para capturar los aspectos
    patron = r'(\w+)\s*([eqtrw])\s*(\w+)'
    matches = re.findall(patron, texto_aspectos)
    
    planetas_validos = ['Sol', 'Luna', 'Mercurio', 'Venus', 'Marte', 'Jupiter', 'Saturno', 'Urano', 'Neptuno', 'Pluton', 'Ascendente', 'Mediocielo']
    
    for match in matches:
        planeta1, aspecto, planeta2 = match
        if planeta1 in planetas_validos and planeta2 in planetas_validos:
            aspecto_significado = {
                'e': 'Trígono',
                'q': 'Conjunción',
                't': 'Sextil',
                'r': 'Cuadratura',
                'w': 'Oposición'
            }.get(aspecto, aspecto)
            
            aspectos.append({
                "planeta1": planeta1,
                "aspecto": aspecto_significado,
                "planeta2": planeta2
            })
    
    return aspectos



def parse_carta_astral_pagina1(text):
    data = {}
    
    # Extraer datos personales
    data['nombre'] = re.search(r'Carta Astral de (.+)', text).group(1)
    data['fecha_nacimiento'] = re.search(r'(\w+ \d+ \w+ \d{4})', text).group(1)
    
    # Separar lugar de nacimiento y signo lunar
    lugar_y_signo = re.search(r'(\w+ - .+) Signo Lunar: (\w+)', text)
    if lugar_y_signo:
        data['lugar_nacimiento'] = lugar_y_signo.group(1)
        data['signo_lunar'] = lugar_y_signo.group(2)
    
    # Extraer coordenadas
    coordenadas = re.search(r'Long:(\d+\w\d+) - Lat:(\d+\w\d+)', text)
    if coordenadas:
        data['coordenadas'] = {
            'longitud': coordenadas.group(1),
            'latitud': coordenadas.group(2)
        }
    
    data['hora_nacimiento'] = re.search(r'Hora nacimiento: (\d{2}:\d{2})', text).group(1)
    data['tiempo_universal'] = re.search(r'Tiempo Universal: (\d{2}:\d{2})', text).group(1)

    # Extraer signos principales
    data['signo_solar'] = re.search(r'Signo Solar: (\w+)', text).group(1)
    data['signo_ascendente'] = re.search(r'Signo Ascendente: (\w+)', text).group(1)

    # Extraer posiciones planetarias
    planetas = ['Sol', 'Luna', 'Mercurio', 'Venus', 'Marte', 'Jupiter', 'Saturno', 'Urano', 'Neptuno', 'Pluton', 'Ascendente', 'Medio Cielo']
    data['posiciones_planetarias'] = {}
    for planeta in planetas:
        match = re.search(rf'{planeta}\s+(\d+°\d+\')\s+(\w+)\s+(\d+)?', text)
        if match:
            data['posiciones_planetarias'][planeta] = {
                'grados': match.group(1),
                'signo': match.group(2),
                'casa': match.group(3)
            }
            
    # Extraer Tablas de Casas
    data['tablas_casas'] = extraer_tablas_casas(text)

    # Extraer Aspectos
    data['aspectos'] = extraer_aspectos(text)

    return data

def parse_carta_astral_pagina2(text):
    data = {}
    
    # Extraer Aspectario
    aspectario_match = re.search(r'Aspectario(.*?)Distribución de Planetas', text, re.DOTALL)
    if aspectario_match:
        aspectario_text = aspectario_match.group(1).strip()
        data['aspectario'] = parse_aspectario(aspectario_text)
    
    # Extraer Distribución de Planetas
    distribucion_match = re.search(r'Distribución de Planetas(.*?)Prólogo', text, re.DOTALL)
    if distribucion_match:
        distribucion_text = distribucion_match.group(1)
        data['distribucion_planetas'] = parse_distribucion_planetas(distribucion_text)
    
    return data

def parse_aspectario(text):
    aspectario = {}
    planetas = ['Sol', 'Luna', 'Mercurio', 'Venus', 'Marte', 'Jupiter', 'Saturno', 'Urano', 'Neptuno', 'Pluton', 'AC', 'MC']
    aspectos = ['Conjunción', 'Oposición', 'Cuadratura', 'Trígono', 'Sextil']
    
    lines = text.split('\n')
    for i, line in enumerate(lines):
        if i == 0:  # Encabezado
            continue
        planeta = planetas[i-1]
        aspectario[planeta] = {}
        for j, aspecto in enumerate(line.split()):
            if aspecto != '-':
                aspectario[planeta][planetas[j]] = aspectos[aspectos.index(aspecto)]
    
    return aspectario

def parse_distribucion_planetas(text):
    distribucion = {
        'modalidades': {},
        'elementos': {},
        'temperamento': {}
    }
    
    # Mapeo de símbolos a nombres de planetas
    simbolos_planetas = {
        'Q': 'Sol', 'W': 'Luna', 'E': 'Mercurio', 'R': 'Venus', 'T': 'Marte',
        'Y': 'Jupiter', 'U': 'Saturno', 'I': 'Urano', 'O': 'Neptuno', '…': 'Pluton',
        'Z': 'AC', 'X': 'MC'
    }
    
    # Extraer modalidades
    modalidades_match = re.search(r'Modalidades(.*?)Elementos', text, re.DOTALL)
    if modalidades_match:
        modalidades = modalidades_match.group(1).strip().split('\n')
        for modalidad in modalidades:
            tipo, planetas = modalidad.split(' ', 1)
            distribucion['modalidades'][tipo] = [simbolos_planetas.get(p, p) for p in planetas.split()]
    
    # Extraer elementos
    elementos_match = re.search(r'Elementos(.*?)Temperamento', text, re.DOTALL)
    if elementos_match:
        elementos = elementos_match.group(1).strip().split('\n')
        for elemento in elementos:
            tipo, planetas = elemento.split(' ', 1)
            distribucion['elementos'][tipo] = [simbolos_planetas.get(p, p) for p in planetas.split()]
    
    # Extraer temperamento
    temperamento_match = re.search(r'Temperamento(.*)', text, re.DOTALL)
    if temperamento_match:
        temperamentos = temperamento_match.group(1).strip().split('\n')
        for temperamento in temperamentos:
            tipo, planetas = temperamento.split(' ', 1)
            distribucion['temperamento'][tipo] = [simbolos_planetas.get(p, p) for p in planetas.split()]
    
    return distribucion

def main():
    pdf_path = 'C:/Users/daviann/Documents/Scripts/PROGRAMACION/Carta_astral/scrapping/carta_astraal.pdf'
    
    # Procesar página 1
    text_page1 = extract_text_from_page(pdf_path, 1)
    data_page1 = parse_carta_astral_pagina1(text_page1)
    
    # Procesar página 2
    text_page2 = extract_text_from_page(pdf_path, 2)
    data_page2 = parse_carta_astral_pagina2(text_page2)
    
    # Combinar datos de ambas páginas
    carta_astral_data = {**data_page1, **data_page2}
    
    # Añadir metadatos
    carta_astral_data['fecha_generacion'] = datetime.now().isoformat()

    # Guardar en JSON
    try:
        with open('carta_astral.json', 'w', encoding='utf-8') as f:
            json.dump(carta_astral_data, f, ensure_ascii=False, indent=4)
        print("Archivo JSON de la carta astral generado con éxito: carta_astral.json")
    except Exception as e:
        print(f"Error al guardar el archivo JSON: {e}")

if __name__ == "__main__":
    main()