from flask import Flask, request, jsonify
from carta_natal import main as generate_carta_natal
import os
import logging

app = Flask(__name__)

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@app.route('/generate_carta_natal', methods=['POST'])
def generate_carta_natal_endpoint():
    data = request.json
    logger.info(f"Datos recibidos: {data}")

    # Extraer los datos del JSON recibido
    nombre = data.get('nombre')
    dia = data.get('dia')
    mes = data.get('mes')
    ano = data.get('ano')
    hora = data.get('hora')
    minutos = data.get('minutos')
    pais = data.get('pais')
    estado = data.get('estado')
    ciudad = data.get('ciudad')

    logger.info(f"Generando carta natal para: {nombre}, nacido el {dia}/{mes}/{ano} a las {hora}:{minutos} en {ciudad}, {estado}, {pais}")

    # Llamar a la función principal del script carta_natal.py
    output_file = generate_carta_natal(nombre, dia, mes, ano, hora, minutos, pais, estado, ciudad)

    if output_file:
        logger.info(f"Carta natal generada exitosamente. Archivo de salida: {output_file}")
        # Leer el contenido del archivo JSON generado
        with open(output_file, 'r', encoding='utf-8') as file:
            carta_natal_data = file.read()

        # Eliminar el archivo temporal
       # os.remove(output_file)
        #logger.info("Archivo temporal eliminado")

        return jsonify({"success": True, "data": carta_natal_data})
    else:
        logger.error("No se pudo generar la carta natal")
        return jsonify({"success": False, "error": "No se pudo generar la carta natal"}), 400

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')