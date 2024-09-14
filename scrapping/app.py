from flask import Flask, request, jsonify, send_file
from carta_natal import main as generate_carta_natal
import os
import logging
import json
import base64  

app = Flask(__name__)

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@app.route('/generate_carta_natal', methods=['POST'])
def generate_carta_natal_endpoint():
    data = request.json
    logger.info(f"Datos recibidos: {data}")

    json_file, png_file = generate_carta_natal(data)

    if json_file and png_file:
        logger.info(f"Carta natal generada exitosamente. JSON: {json_file}, PNG: {png_file}")
        
        # Leer el contenido del archivo JSON generado
        with open(json_file, 'r', encoding='utf-8') as file:
            carta_natal_data = json.load(file)

        # Leer el contenido del archivo PNG y codificarlo en base64
        with open(png_file, 'rb') as image_file:
            encoded_image = base64.b64encode(image_file.read()).decode('utf-8')

        # Preparar la respuesta
        response = {
            "success": True,
            "data": carta_natal_data,
            "image": encoded_image
        }

        # Eliminar archivos temporales
        os.remove(json_file)
        os.remove(png_file)
        logger.info("Archivos temporales eliminados")

        return jsonify(response)
    else:
        logger.error("No se pudo generar la carta natal")
        return jsonify({"success": False, "error": "No se pudo generar la carta natal"}), 400

@app.route('/get_image/<filename>', methods=['GET'])
def get_image(filename):
    try:
        return send_file(filename, mimetype='image/png')
    except FileNotFoundError:
        return jsonify({"error": "Imagen no encontrada"}), 404

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')