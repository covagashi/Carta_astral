import svgwrite
import math
import json

def load_chart_data(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        return json.load(file)

def degree_to_xy(degree, radius, center):
    radian = math.radians(degree - 90)
    return (center + math.cos(radian) * radius, center + math.sin(radian) * radius)

def draw_advanced_wheel_chart(data, file_name='carta_natal_avanzada.svg', size=600):
    dwg = svgwrite.Drawing(file_name, size=(size, size))
    center = size / 2
    outer_radius = size * 0.45
    inner_radius = outer_radius * 0.7

    # Dibujar círculos
    dwg.add(dwg.circle(center=(center, center), r=outer_radius, fill='none', stroke='black'))
    dwg.add(dwg.circle(center=(center, center), r=inner_radius, fill='none', stroke='black'))
    
    # Dibujar líneas de las casas
    for i in range(12):
        angle = i * 30
        start = degree_to_xy(angle, inner_radius, center)
        end = degree_to_xy(angle, outer_radius, center)
        dwg.add(dwg.line(start=start, end=end, stroke='black'))

    # Dibujar signos zodiacales
    zodiac_signs = ['♈', '♉', '♊', '♋', '♌', '♍', '♎', '♏', '♐', '♑', '♒', '♓']
    for i, sign in enumerate(zodiac_signs):
        angle = i * 30 + 15
        pos = degree_to_xy(angle, (outer_radius + inner_radius) / 2, center)
        dwg.add(dwg.text(sign, insert=pos, text_anchor="middle", dominant_baseline="central", font_size=20))

    # Añadir planetas
    planet_symbols = {
        'Sol': '☉', 'Luna': '☽', 'Mercurio': '☿', 'Venus': '♀', 'Marte': '♂',
        'Júpiter': '♃', 'Saturno': '♄', 'Urano': '♅', 'Neptuno': '♆', 'Plutón': '♇'
    }
    
    for obj in data['objects'].values():
        if obj['name'] in planet_symbols:
            angle = obj['longitude']['raw']
            symbol = planet_symbols[obj['name']]
            pos = degree_to_xy(angle, (outer_radius + inner_radius) / 2, center)
            
            dwg.add(dwg.text(symbol, insert=pos, text_anchor="middle", dominant_baseline="central", font_size=16))
            
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
    dwg.add(dwg.text("AC", insert=asc_pos, text_anchor="middle", dominant_baseline="central", font_size=12, fill='red'))
    dwg.add(dwg.text("MC", insert=mc_pos, text_anchor="middle", dominant_baseline="central", font_size=12, fill='red'))

    dwg.save()
    print(f"La carta natal avanzada ha sido generada como '{file_name}'")

# Uso del script
chart_data = load_chart_data('carta_natal.json')
draw_advanced_wheel_chart(chart_data)