from flask import Flask, render_template_string, request
import time
import requests
from datetime import datetime, timedelta 
import json
from pathlib import Path
import logging

LAST_CHECK_TIME = 0
THROTTLE_TIME = 30  # segundos

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

monitor_app = Flask(__name__)

STATUS_FILE = 'monitor_status.json'

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
        let lastCheckTime = new Date().getTime();
        const THROTTLE_TIME = 30000; // 30 segundos entre verificaciones
        
        function updateCountdown() {
            const nextCheckElement = document.getElementById('next-check-time');
            if (!nextCheckElement) return;
            
            const nextCheck = new Date(nextCheckElement.dataset.time);
            const now = new Date();
            const diff = Math.max(0, nextCheck - now);
            
            const minutes = Math.floor(diff / 60000);
            const seconds = Math.floor((diff % 60000) / 1000);
            
            const countdownElement = document.getElementById('countdown');
            if (countdownElement) {
                countdownElement.textContent = `${minutes}m ${seconds}s`;
            }
        }

        function checkNow() {
            const now = new Date().getTime();
            const timeSinceLastCheck = now - lastCheckTime;
            
            if (timeSinceLastCheck < THROTTLE_TIME) {
                alert(`Por favor espera ${Math.ceil((THROTTLE_TIME - timeSinceLastCheck) / 1000)} segundos antes de verificar nuevamente.`);
                return;
            }
            
            lastCheckTime = now;
            window.location.href = '/monitor';
        }

        // Actualizar el contador cada segundo sin recargar
        setInterval(updateCountdown, 1000);

        // Primera actualización
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
                <span id="countdown"></span>
                <span id="next-check-time" 
                      data-time="{{next_check}}" 
                      style="display: none;">{{next_check}}</span>
            </div>

            <button class="button" onclick="window.location.reload()">
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

def load_status():
    try:
        if Path(STATUS_FILE).exists():
            with open(STATUS_FILE, 'r') as f:
                return json.load(f)
    except Exception:
        pass
    
    return {
        'last_check': None,
        'current_status': 'unknown',
        'response_time': 0,
        'success_count': 0,
        'error_count': 0,
        'history': []
    }

def save_status(status_data):
    with open(STATUS_FILE, 'w') as f:
        json.dump(status_data, f)

def check_api():
    # Ruta absoluta para el archivo de bloqueo
    lock_file = Path('/tmp/api_check.lock')
    
    # Verificar bloqueo con tiempo de expiración
    if lock_file.exists():
        try:
            lock_time = datetime.fromtimestamp(lock_file.stat().st_mtime)
            if (datetime.now() - lock_time).total_seconds() < 30:
                logger.info("Verificación omitida - muy reciente")
                # Usar el último estado conocido
                status_data = load_status()
                return {
                    'status': status_data.get('current_status', 'unknown'),
                    'response_time': status_data.get('response_time', 0),
                    'error': 'Verificación en progreso'
                }
        except Exception as e:
            logger.error(f"Error al verificar bloqueo: {e}")
            # Si hay error al verificar el bloqueo, intentamos eliminarlo
            try:
                lock_file.unlink()
            except Exception:
                pass

    try:
        # Crear archivo de bloqueo
        lock_file.touch()
        
        logger.info("Iniciando verificación de API")
        response = requests.post(
            "http://127.0.0.1:5000/generate_carta_natal",  # Cambiado a 127.0.0.1
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
            headers={"Content-Type": "application/json"},
            timeout=300
        )
        
        # Loguear la respuesta completa para debug
        logger.info(f"Respuesta completa: {response.text[:500]}")
        
        try:
            response_data = response.json()
            is_success = (
                response.status_code == 200 and
                isinstance(response_data, dict) and
                'success' in response_data
            )
            
            result = {
                'status': 'online' if is_success else 'offline',
                'response_time': round(response.elapsed.total_seconds(), 3),
                'status_code': response.status_code,
                'details': response_data
            }
        except json.JSONDecodeError as e:
            logger.error(f"Error decodificando JSON: {e}")
            result = {
                'status': 'offline',
                'response_time': round(response.elapsed.total_seconds(), 3),
                'status_code': response.status_code,
                'error': 'Invalid JSON response'
            }

    except requests.exceptions.Timeout:
        logger.error("Timeout al verificar la API")
        result = {
            'status': 'offline',
            'response_time': 300,
            'error': 'Timeout'
        }
    except Exception as e:
        logger.error(f"Error al verificar la API: {str(e)}")
        result = {
            'status': 'offline',
            'response_time': 0,
            'error': str(e)
        }
    
    finally:
        # Eliminar el archivo de bloqueo
        try:
            if lock_file.exists():
                lock_file.unlink()
        except Exception as e:
            logger.error(f"Error eliminando archivo de bloqueo: {e}")
    
    return result

@monitor_app.route('/monitor')
def monitor():
    global LAST_CHECK_TIME
    current_time = time.time()
    
    # Si ha pasado menos del tiempo mínimo, usar datos existentes
    if current_time - LAST_CHECK_TIME < THROTTLE_TIME:
        status_data = load_status()
        if status_data['last_check'] is not None:  # Si tenemos datos previos
            return render_template_string(
                HTML_TEMPLATE,
                current_status=status_data['current_status'],
                last_check=status_data['last_check'],
                response_time=status_data['response_time'],
                success_count=status_data['success_count'],
                error_count=status_data['error_count'],
                history='\n'.join(
                    f"[{h['time']}] {'✅' if h['status'] == 'online' else '❌'} ({h['response_time']}s)"
                    for h in reversed(status_data.get('history', []))
                ),
                next_check=(datetime.fromtimestamp(LAST_CHECK_TIME + THROTTLE_TIME)).strftime('%Y-%m-%d %H:%M:%S')
            )
    
    # Actualizar el tiempo de la última verificación
    LAST_CHECK_TIME = current_time
    
    # Realizar la verificación
    status_data = load_status()
    check_result = check_api()
    
    now = datetime.now()
    status_data['last_check'] = now.strftime('%Y-%m-%d %H:%M:%S')
    status_data['current_status'] = check_result['status']
    status_data['response_time'] = check_result['response_time']
    
    if check_result['status'] == 'online':
        status_data['success_count'] = status_data.get('success_count', 0) + 1
    else:
        status_data['error_count'] = status_data.get('error_count', 0) + 1
    
    status_data['history'] = status_data.get('history', [])[-9:]
    status_data['history'].append({
        'time': now.strftime('%H:%M:%S'),
        'status': check_result['status'],
        'response_time': check_result['response_time']
    })
    
    save_status(status_data)
    
    next_check = (now + timedelta(seconds=THROTTLE_TIME)).strftime('%Y-%m-%d %H:%M:%S')
    
    history_text = '\n'.join(
        f"[{h['time']}] {'✅' if h['status'] == 'online' else '❌'} ({h['response_time']}s)"
        for h in reversed(status_data['history'])
    )
    
    return render_template_string(
        HTML_TEMPLATE,
        current_status=check_result['status'],
        last_check=status_data['last_check'],
        response_time=check_result['response_time'],
        success_count=status_data['success_count'],
        error_count=status_data['error_count'],
        history=history_text,
        next_check=next_check
    )
    
 

if __name__ == '__main__':
    monitor_app.run(host='127.0.0.1', port=5001)