from flask import Flask
import time

app = Flask(__name__)


@app.route('/check-stock')
def check_stock():
    # Simulamos un proceso lento (latencia de red o DB pesada)
    time.sleep(10)
    return {"status": "disponible", "item_id": 101}


if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5001)
