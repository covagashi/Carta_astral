import re
import os
import html

def remove_tags(html_content, tags_to_remove):
    for tag in tags_to_remove:
        # Patrón para etiquetas con contenido
        pattern = f'<{tag}[^>]*>.*?</{tag}>'
        html_content = re.sub(pattern, '', html_content, flags=re.DOTALL)
        
        # Patrón para etiquetas de cierre automático (como <hr>, <br>, <img/>)
        pattern = f'<{tag}[^>]*/?>'
        html_content = re.sub(pattern, '', html_content)
        
        # Patrón específico para etiquetas <a> con atributos variables
        if tag == 'a':
            pattern = r'<a\s+[^>]*>.*?</a>'
            html_content = re.sub(pattern, '', html_content, flags=re.DOTALL)
    
    return html_content

def remove_content_after_epilogo(html_content):
    # Decodificar entidades HTML
    decoded_content = html.unescape(html_content)
    
    # Buscar "Epílogo" con o sin etiquetas HTML
    pattern = r'<h3>\s*Ep(?:í|&iacute;)logo\s*</h3>.*'
    match = re.search(pattern, decoded_content, re.DOTALL | re.IGNORECASE)
    
    if match:
        # Obtener la posición de inicio del match
        start = match.start()
        # Cortar el contenido hasta esa posición y añadir el encabezado de Epílogo
        return decoded_content[:start] + '<h3>Epílogo</h3>'
    else:
        # Si no se encuentra "Epílogo", devolver el contenido original
        return html_content

def remove_content_before_prologo(html_content):
    # Buscar "Prólogo" con o sin etiquetas HTML
    pattern = r'<h3>\s*Pr(?:ó|&oacute;)logo\s*</h3>'
    match = re.search(pattern, html_content, re.IGNORECASE)
    
    if match:
        # Obtener la posición de inicio del match
        start = match.start()
        # Devolver el contenido desde "Prólogo" en adelante
        return html_content[start:]
    else:
        # Si no se encuentra "Prólogo", devolver el contenido original
        return html_content

def clean_abandoned_characters(html_content):
    # Eliminar caracteres "abandonados" como ->, <-, grados, minutos, etc.
    patterns_to_remove = [
        r'\s*->\s*',
        r'\s*<-\s*',
        r'\s*\d+°\s*\d+\s*',  # Patrón para grados y minutos
        r'\s+en\s+',  # Patrón para "en" rodeado de espacios
        r'\s+',  # Reemplazar múltiples espacios con uno solo
    ]
    
    for pattern in patterns_to_remove:
        html_content = re.sub(pattern, ' ', html_content)
    
    # Eliminar espacios extra entre etiquetas
    html_content = re.sub(r'>\s+<', '><', html_content)
    
    # Eliminar espacios al principio y al final de cada línea
    html_content = re.sub(r'^\s+|\s+$', '', html_content, flags=re.MULTILINE)
    
    # Eliminar líneas en blanco
    html_content = re.sub(r'\n\s*\n', '\n', html_content)
    
    return html_content.strip()

def main():
    # Etiquetas predefinidas para eliminar
    tags_to_remove = ['img', 'button', 'head', 'script', 'ins', 'hr', 'button', 'style', 'svg', 'footer', 'a', 'br', 'table', 'ul']
    
    # Nombres de los archivos
    input_file = 'response.html'
    output_file = 'output.html'
    
    # Obtener la ruta del directorio actual
    current_dir = os.path.dirname(os.path.abspath(__file__))
    
    # Construir las rutas completas
    input_path = os.path.join(current_dir, input_file)
    output_path = os.path.join(current_dir, output_file)
    
    try:
        with open(input_path, 'r', encoding='utf-8') as file:
            html_content = file.read()

        # Primero, eliminar el contenido antes de "Prólogo"
        modified_content = remove_content_before_prologo(html_content)
        
        # Luego, eliminar el contenido después de "Epílogo"
        modified_content = remove_content_after_epilogo(modified_content)
        
        # Después, eliminar las etiquetas HTML especificadas
        modified_content = remove_tags(modified_content, tags_to_remove)

        # Finalmente, limpiar caracteres abandonados y espacios extra
        modified_content = clean_abandoned_characters(modified_content)

        with open(output_path, 'w', encoding='utf-8') as file:
            file.write(modified_content)

        print("Todo el contenido antes de 'Prólogo' ha sido eliminado.")
        print(f"Las etiquetas {', '.join(tags_to_remove)} han sido eliminadas.")
        print("Todo el contenido después de 'Epílogo' ha sido eliminado.")
        print("Los caracteres abandonados y espacios extra han sido limpiados.")
        print(f"El resultado se ha guardado en {output_file}")
    except FileNotFoundError:
        print(f"Error: No se pudo encontrar el archivo {input_file}")
    except Exception as e:
        print(f"Error: {str(e)}")

if __name__ == "__main__":
    main()