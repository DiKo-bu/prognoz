import sqlite3
import json
import paho.mqtt.client as mqtt
from datetime import datetime

# Настройки
DB_NAME = "forest_data.db"
TOPIC_IN = "forest/inbox"
TOPIC_OUT = "forest/broadcast"

# Инициализация базы данных SQLite
def init_db():
    conn = sqlite3.connect(DB_NAME)
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS reports (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            work_id TEXT,
            work_type TEXT,
            raw_data TEXT,
            timestamp DATETIME
        )
    ''')
    conn.commit()
    conn.close()

# Логика при получении сообщения
def on_message(client, userdata, msg):
    try:
        payload = msg.payload.decode()
        data = json.loads(payload)
        
        # Если пришел массив (как в твоем примере), берем первый элемент
        report = data[0] if isinstance(data, list) else data
        
        # Сохранение в SQLite
        conn = sqlite3.connect(DB_NAME)
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO reports (work_id, work_type, raw_data, timestamp) VALUES (?, ?, ?, ?)",
            (report.get('id', 'N/A'), report.get('workType', 'N/A'), payload, datetime.now())
        )
        conn.commit()
        conn.close()

        print(f"[LOG] Сохранено: {report.get('workType')} в {datetime.now()}")

        # "Роутинг": пересылаем сообщение в общий канал для других клиентов
        client.publish(TOPIC_OUT, payload)
        
    except Exception as e:
        print(f"[ERR] Ошибка обработки: {e}")

# Настройка MQTT клиента
client = mqtt.Client()
client.on_message = on_message

init_db()
client.connect("127.0.0.1", 1883, 60)
client.subscribe(TOPIC_IN)

print("--- Роутер запущен и слушает топик forest/inbox ---")
client.loop_forever()
