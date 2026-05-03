<!DOCTYPE html>
<html>
<head>
    <style>
        body { background-color: transparent; margin: 0; padding: 5px; }
        
        .container {
            background: #1a1a1a;
            color: #00ff00;
            padding: 20px;
            border-radius: 12px;
            font-family: 'Courier New', monospace;
            border: 2px solid #333;
            text-align: center;
            box-shadow: 0 4px 15px rgba(0,0,0,0.5);
        }

        .header {
            font-size: 10px;
            color: #888;
            text-align: left;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 10px;
            border-bottom: 1px solid #333;
            padding-bottom: 5px;
        }

        #display {
            font-size: 60px;
            font-weight: bold;
            margin: 20px 0;
            text-shadow: 0 0 10px rgba(0, 255, 0, 0.5);
        }

        .unit { font-size: 24px; margin-left: 5px; color: #00aa00; }

        .console {
            text-align: left;
            font-size: 11px;
            background: #000;
            padding: 12px;
            border-radius: 6px;
            color: #ffaa00;
            border: 1px solid #222;
        }

        .status-dot {
            height: 8px;
            width: 8px;
            border-radius: 50%;
            display: inline-block;
            margin-right: 5px;
        }

        .log-item { margin-bottom: 4px; }
        .val { color: #ffffff; font-weight: bold; }
        #debug-raw { color: #444; font-size: 9px; margin-top: 8px; word-break: break-all; }
    </style>
</head>
<body>

<div class="container">
    <div class="header">SISTEMA DE DIAGNÓSTICO v6.5.10-BETA</div>
    
    <div id="display">--<span class="unit">cm</span></div>
    
    <div class="console">
        <div class="log-item">● DISPOSITIVO: <span id="debug-device" class="val">...</span></div>
        <div class="log-item">● RECURSO: <span id="debug-res" class="val">...</span></div>
        <div class="log-item">
            <span id="dot" class="status-dot" style="background: #555;"></span>
            ESTADO: <span id="debug-status" class="val">Iniciando...</span>
        </div>
        <div id="debug-raw">Esperando datos de Thinger.io...</div>
    </div>
</div>

<script>
    // --- CONFIGURACIÓN ---
    const MI_USUARIO = "dilancas2008";
    const MI_DEVICE_ID = "esp32_dilan"; // <--- ¡CAMBIA ESTO!
    const MI_RECURSO = "distancia"; 
    const MI_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiJkaXN0YW5jaWEiLCJzdnIiOiJ1cy1lYXN0LmF3cy50aGluZ2VyLmlvIiwidXNyIjoiZGlsYW5jYXMyMDA4In0.AYZYhsTj9YPzkKVv2IRW-wapc_2-COd-EL0iPX52SEY";
    // ---------------------

    document.getElementById('debug-device').innerText = MI_DEVICE_ID;
    document.getElementById('debug-res').innerText = MI_RECURSO;

    async function updateDashboard() {
        const url = `https://us-east.aws.thinger.io/v2/users/${MI_USUARIO}/devices/${MI_DEVICE_ID}/${MI_RECURSO}`;
        const statusText = document.getElementById('debug-status');
        const display = document.getElementById('display');
        const raw = document.getElementById('debug-raw');
        const dot = document.getElementById('dot');

        try {
            const response = await fetch(url, {
                headers: { "Authorization": `Bearer ${MI_TOKEN}` }
            });

            if (response.status === 404) {
                statusText.innerText = "ERROR 404: No encontrado";
                statusText.style.color = "#ff4444";
                dot.style.background = "#ff4444";
                return;
            }

            if (response.status === 401) {
                statusText.innerText = "ERROR 401: Token inválido";
                statusText.style.color = "#ff4444";
                dot.style.background = "#ff4444";
                return;
            }

            const data = await response.json();
            raw.innerText = "RAW JSON: " + JSON.stringify(data);

            // Extraer valor (funciona si es objeto o valor simple)
            let valor = (typeof data === 'object' && data !== null) 
                        ? data[Object.keys(data)[0]] 
                        : data;

            // Verificamos si es un número válido
            if (valor !== null && !isNaN(valor)) {
                // FORMATEO A 2 DECIMALES
                const numeroFormateado = Number(valor).toFixed(2);
                
                display.innerHTML = numeroFormateado + '<span class="unit">cm</span>';
                statusText.innerText = "ONLINE / RECIBIENDO";
                statusText.style.color = "#00ff00";
                dot.style.background = "#00ff00";
            } else {
                statusText.innerText = "ERROR: Dato no numérico";
                dot.style.background = "#ffaa00";
            }

        } catch (err) {
            statusText.innerText = "ERROR DE RED";
            statusText.style.color = "#ff4444";
            dot.style.background = "#ff4444";
            console.error(err);
        }
    }

    // Actualizar cada 2 segundos
    setInterval(updateDashboard, 2000);
    updateDashboard(); // Ejecución inicial
</script>

</body>
</html>
