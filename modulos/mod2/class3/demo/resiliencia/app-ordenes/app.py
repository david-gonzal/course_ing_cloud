from flask import Flask
import requests
import time

app = Flask(__name__)

# --------------------------------------------------------------------------------------------
# Parte 1
# ---------------------------------------------------------------------------------------------


@app.route('/comprar')
def comprar():
    start_time = time.time()
    try:
        # Llamada síncrona al inventario
        response = requests.get(
            'http://inventario:5001/check-stock', timeout=15)
        return {"msg": "Compra exitosa", "data": response.json()}
    except Exception as e:
        return {"error": "El inventario no responde", "tiempo": time.time() - start_time}

# --------------------------------------------------------------------------------------------
# Parte 2
# ---------------------------------------------------------------------------------------------

# @app.route('/comprar-resiliente')
# def comprar_resiliente():
#     try:
#         # Ponemos un timeout agresivo de 1 segundo (Circuit Breaker implícito)
#         response = requests.get(
#             'http://inventario:5001/check-stock', timeout=1.0)
#         return {"msg": "Compra exitosa", "data": response.json()}
#     except requests.exceptions.Timeout:
#         # ESTO ES EL FALLBACK
#         return {
#             "msg": "Compra en proceso (Modo Offline)",
#             "nota": "El inventario está lento, pero no te bloqueamos. Usamos stock en caché.",
#             "status": "PROVISIONAL"
#         }

# --------------------------------------------------------------------------------------------


if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
