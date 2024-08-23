import json
from bs4 import BeautifulSoup
from datetime import datetime

def html_to_json(html_file):
    with open(html_file, 'r', encoding='utf-8') as file:
        soup = BeautifulSoup(file, 'html.parser')

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

# Uso del script
html_file = 'output.html'
json_data = html_to_json(html_file)

# Guardar el resultado en un archivo JSON
with open('output.json', 'w', encoding='utf-8') as json_file:
    json.dump(json_data, json_file, ensure_ascii=False, indent=4)

print("Conversión completada. El resultado se ha guardado en 'output.json'.")