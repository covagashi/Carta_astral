from flask import Flask, render_template_string, jsonify, request
import requests
from datetime import datetime, timedelta
import json
from pathlib import Path
import logging
import threading
import time

# Configuración de logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Configuración básica
THROTTLE_TIME = 900  # 15 minutos en segundos
STATUS_FILE = 'monitor_status.json'

monitor_app = Flask(__name__)


HTML_TEMPLATE = '''
<!DOCTYPE html>
<html>
<head>
    <title>Stellar API Monitor</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body { 
            font-family: monospace; 
            background: #1a1a1a; 
            color: #fff; 
            padding: 20px; 
            margin: 0;
            min-height: 100vh;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
        }
        .status-box { 
            background: #2d2d2d; 
            padding: 20px; 
            border-radius: 8px;
            margin-bottom: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.2);
        }
        .status-indicator {
            font-size: 24px;
            margin-bottom: 10px;
        }
        .info-grid {
            display: grid;
            grid-template-columns: auto 1fr;
            gap: 10px;
            margin: 15px 0;
        }
        .info-label {
            color: #888;
        }
        .info-value {
            color: #fff;
        }
        .success { color: #4CAF50; }
        .error { color: #f44336; }
        .button { 
            background: #4CAF50; 
            color: white; 
            padding: 10px 20px; 
            border: none; 
            border-radius: 5px; 
            cursor: pointer;
            font-family: monospace;
            font-size: 14px;
            transition: background-color 0.3s;
        }
        .button:hover {
            background: #45a049;
        }
        .status-history {
            margin-top: 20px;
            padding: 15px;
            background: #222;
            border-radius: 8px;
        }
        .next-check {
            color: #888;
            font-size: 0.9em;
            margin-top: 10px;
        }
        @media (max-width: 600px) {
            body { padding: 10px; }
            .status-box { padding: 15px; }
        }
    </style>
    <script>
        function updateCountdown() {
            // Obtener los segundos restantes del servidor
            let timeLeft = parseInt({{ seconds_left }});

            function tick() {
                if (timeLeft < 0) {
                    location.reload();
                    return;
                }

                const minutes = Math.floor(timeLeft / 60);
                const seconds = timeLeft % 60;
                
                const countdownElement = document.getElementById('countdown');
                if (countdownElement) {
                    countdownElement.textContent = 
                        `${minutes.toString().padStart(2, '0')}m ${seconds.toString().padStart(2, '0')}s`;
                }

                timeLeft--;
                setTimeout(tick, 1000);
            }

            tick();
        }

        // Iniciar el contador cuando carga la página
        document.addEventListener('DOMContentLoaded', updateCountdown);
    </script>
</head>
<body>
    <div class="container">
        <div class="status-box">
            <div class="status-indicator">
                {% if current_status == "online" %}
                    <span class="success">🟢 API ONLINE</span>
                {% else %}
                    <span class="error">🔴 API OFFLINE</span>
                {% endif %}
            </div>
            
            <div class="info-grid">
                <span class="info-label">Última verificación:</span>
                <span class="info-value">{{last_check}}</span>
                
                <span class="info-label">Tiempo de respuesta:</span>
                <span class="info-value">{{response_time}} segundos</span>
                
                <span class="info-label">Peticiones exitosas:</span>
                <span class="info-value">{{success_count}}</span>
                
                <span class="info-label">Fallos:</span>
                <span class="info-value">{{error_count}}</span>
            </div>

            <div class="next-check">
                Próxima verificación en: 
                <span id="countdown">{{ '%02d' % (seconds_left // 60) }}m {{ '%02d' % (seconds_left % 60) }}s</span>
            </div>

            <button class="button" onclick="checkNow()" type="button">
                Verificar ahora
            </button>
        </div>

        <div class="status-history">
            <h3>Últimas verificaciones</h3>
            <pre>{{history}}</pre>
        </div>
    </div>
</body>
</html>
'''


# Configuración básica
THROTTLE_TIME = 900  # 15 minutos en segundos
STATUS_FILE = 'monitor_status.json'

monitor_app = Flask(__name__)

def check_api():
    try:
        response = requests.post(
            "http://127.0.0.1:5000/generate_carta_natal",
            json={
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
            },
            timeout=300
        )
        
        return {
            'status': 'online' if response.status_code == 200 else 'offline',
            'response_time': round(response.elapsed.total_seconds(), 3),
            'status_code': response.status_code
        }
    except Exception as e:
        logger.error(f"API check error: {e}")
        return {
            'status': 'offline',
            'response_time': 0,
            'error': str(e)
        }

def load_status():
    try:
        if Path(STATUS_FILE).exists():
            with open(STATUS_FILE, 'r') as f:
                return json.load(f)
    except Exception as e:
        logger.error(f"Error loading status: {e}")
    
    return {
        'last_check': None,
        'current_status': 'unknown',
        'response_time': 0,
        'success_count': 0,
        'error_count': 0,
        'history': []
    }

def save_status(status_data):
    try:
        with open(STATUS_FILE, 'w') as f:
            json.dump(status_data, f)
    except Exception as e:
        logger.error(f"Error saving status: {e}")

def background_check():
    while True:
        try:
            status_data = load_status()
            check_result = check_api()
            now = datetime.now()
            
            # Actualizar estado
            status_data.update({
                'last_check': now.isoformat(),
                'current_status': check_result['status'],
                'response_time': check_result['response_time'],
                'success_count': status_data.get('success_count', 0) + (1 if check_result['status'] == 'online' else 0),
                'error_count': status_data.get('error_count', 0) + (1 if check_result['status'] == 'offline' else 0),
                'history': (status_data.get('history', [])[-9:] + [{
                    'time': now.strftime('%H:%M:%S'),
                    'status': check_result['status'],
                    'response_time': check_result['response_time']
                }])
            })
            
            save_status(status_data)
            logger.info(f"API Check completed: {check_result['status']}")
            
        except Exception as e:
            logger.error(f"Error in background check: {e}")
        
        # Esperar 15 minutos
        time.sleep(THROTTLE_TIME)


@monitor_app.route('/monitor')
def monitor():
    try:
        status_data = load_status()
        now = datetime.now()
        last_check = datetime.fromisoformat(status_data['last_check'])
        time_since_check = (now - last_check).total_seconds()
        time_until_next = THROTTLE_TIME - time_since_check
        
        # Añadir seconds_left al contexto del template
        return render_template_string(
            HTML_TEMPLATE,
            current_status=status_data.get('current_status', 'unknown'),
            last_check=last_check.strftime('%Y-%m-%d %H:%M:%S'),
            response_time=status_data.get('response_time', 0),
            success_count=status_data.get('success_count', 0),
            error_count=status_data.get('error_count', 0),
            history='\n'.join(
                f"[{h['time']}] {'✅' if h['status'] == 'online' else '❌'} ({h['response_time']}s)"
                for h in reversed(status_data.get('history', []))
            ),
            seconds_left=int(time_until_next)  # Pasar los segundos restantes al frontend
        )
    except Exception as e:
        logger.error(f"Error in monitor route: {e}")
        return "Error loading monitor", 500

if __name__ == '__main__':
    # Iniciar el thread de monitorización
    monitor_thread = threading.Thread(target=background_check, daemon=True)
    monitor_thread.start()
    
    # Iniciar la aplicación Flask
    monitor_app.run(host='127.0.0.1', port=5001)