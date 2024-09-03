import svgwrite
import math
import json
from xml.etree import ElementTree as ET

def load_chart_data(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        return json.load(file)

def degree_to_xy(degree, radius, center):
    radian = math.radians(degree - 90)
    return (center + math.cos(radian) * radius, center + math.sin(radian) * radius)

def draw_advanced_wheel_chart(data, file_name='carta_natal_avanzada.svg', size=510):
    # Cargar la plantilla SVG
    tree = ET.parse('C:/Users/daviann/Documents/Scripts/PROGRAMACION/Carta_astral/scrapping/wheel/img/wheel_plantilla.svg')
    root = tree.getroot()

    # Crear un nuevo documento SVG
    dwg = svgwrite.Drawing(file_name, size=(size, size))

    # Copiar todos los elementos de la plantilla al nuevo documento
    for elem in root:
        if elem.tag.split('}')[-1] == 'circle':
            dwg.add(dwg.circle(center=(elem.attrib['cx'], elem.attrib['cy']), r=elem.attrib['r'], 
                               fill=elem.attrib.get('fill', 'none'), 
                               stroke=elem.attrib.get('stroke', 'black')))
        elif elem.tag.split('}')[-1] == 'line':
            dwg.add(dwg.line(start=(elem.attrib['x1'], elem.attrib['y1']),
                             end=(elem.attrib['x2'], elem.attrib['y2']),
                             stroke=elem.attrib.get('stroke', 'black')))

    center = size / 2
    outer_radius = size * 0.45
    inner_radius = outer_radius * 0.7

    # Dibujar signos zodiacales
    zodiac_signs = ['aries', 'taurus', 'gemini', 'cancer', 'leo', 'virgo', 'libra', 'scorpio', 'sagittarius', 'capricorn', 'aquarius', 'pisces']
    for i, sign in enumerate(zodiac_signs):
        angle = i * 30
        symbol_pos = degree_to_xy(angle, (outer_radius + inner_radius) / 2, center)
        image_path = f"C:/Users/daviann/Documents/Scripts/PROGRAMACION/Carta_astral/scrapping/wheel/img/{sign}.svg"
        dwg.add(dwg.image(href=image_path, insert=(symbol_pos[0]-10, symbol_pos[1]-10), size=(20, 20)))

    # Añadir planetas
    planet_images = {
        'Sol': 'sun', 'Luna': 'moon', 'Mercurio': 'mercury', 'Venus': 'venus', 'Marte': 'mars',
        'Júpiter': 'jupiter', 'Saturno': 'saturn', 'Urano': 'uranus', 'Neptuno': 'neptune', 'Plutón': 'pluto'
    }
    
    for obj in data['objects'].values():
        if obj['name'] in planet_images:
            angle = obj['longitude']['raw']
            image_name = planet_images[obj['name']]
            pos = degree_to_xy(angle, (outer_radius + inner_radius) / 2, center)
            
            image_path = f"C:/Users/daviann/Documents/Scripts/PROGRAMACION/Carta_astral/scrapping/wheel/img/{image_name}.svg"
            dwg.add(dwg.image(href=image_path, insert=(pos[0]-10, pos[1]-10), size=(20, 20)))
            
            # Añadir grado del planeta
            degree_pos = degree_to_xy(angle, outer_radius * 1.1, center)
            dwg.add(dwg.text(f"{obj['sign_longitude']['degrees']}°{obj['sign_longitude']['minutes']}'", 
                             insert=degree_pos, text_anchor="middle", dominant_baseline="central", font_size=8))

    # Dibujar aspectos
    aspect_colors = {'Conjunción': 'red', 'Oposición': 'blue', 'Trígono': 'green', 'Cuadratura': 'orange', 'Sextil': 'purple'}
    for aspect_group in data['aspects'].values():
        for aspect in aspect_group.values():
            if 'type' in aspect and aspect['type'] in aspect_colors:
                start_angle = data['objects'][str(aspect['active'])]['longitude']['raw']
                end_angle = data['objects'][str(aspect['passive'])]['longitude']['raw']
                start = degree_to_xy(start_angle, inner_radius * 0.9, center)
                end = degree_to_xy(end_angle, inner_radius * 0.9, center)
                dwg.add(dwg.line(start=start, end=end, stroke=aspect_colors[aspect['type']], stroke_width=0.5))

    # Añadir Ascendente y Medio Cielo
    asc = data['objects']['3000001']['longitude']['raw']
    mc = data['objects']['3000003']['longitude']['raw']
    asc_pos = degree_to_xy(asc, outer_radius * 1.12, center)
    mc_pos = degree_to_xy(mc, outer_radius * 1.12, center)
    dwg.add(dwg.text("ASC", insert=asc_pos, text_anchor="middle", dominant_baseline="central", font_size=12, fill='red'))
    dwg.add(dwg.text("MC", insert=mc_pos, text_anchor="middle", dominant_baseline="central", font_size=12, fill='red'))

    dwg.save()
    print(f"La carta natal avanzada ha sido generada como '{file_name}'")

# Uso del script
chart_data = load_chart_data('carta_natal.json')
draw_advanced_wheel_chart(chart_data)