import os
from supabase import create_client, Client
from dotenv import load_dotenv

# Завантажуємо змінні середовища з .env.local
load_dotenv('.env.local')

SUPABASE_URL = os.getenv("NEXT_PUBLIC_SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY") or os.getenv("NEXT_PUBLIC_SUPABASE_ANON_KEY")

if not SUPABASE_URL or not SUPABASE_KEY:
    raise ValueError("Помилка: Не знайдено змінні середовища Supabase у файлі .env.local")

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# Повний масив даних (сюди можна додати стільки модулів, скільки потрібно для тисячі слів)
FULL_CURRICULUM = [
    {
        "order_index": 17,
        "title_hr": "Napredna IT arhitektura",
        "title_ua": "Просунута IT-архітектура",
        "description": "Мікросервіси, масштабування, CI/CD та навантаження на систему.",
        "vocab": [
            {"type": "word", "hr": "Poslužitelj", "ua": "Сервер"},
            {"type": "word", "hr": "Oblak", "ua": "Хмара (Cloud)"},
            {"type": "word", "hr": "Skaliranje", "ua": "Масштабування"},
            {"type": "phrase", "hr": "Imamo li problem s memorijom na poslužitelju?", "ua": "Чи є у нас проблеми з пам'яттю на сервері?"},
            {"type": "dialogue_line", "hr": "Arhitekt: Moramo migrirati bazu u oblak.", "ua": "Архітектор: Ми повинні мігрувати базу в хмару."},
            {"type": "dialogue_line", "hr": "DevOps: Provjerit ću CI/CD pipeline i resurse.", "ua": "DevOps: Я перевірю CI/CD пайплайн та ресурси."}
        ]
    }
]

def seed_database():
    print("🚀 Починаємо масове завантаження даних у Supabase...")
    
    for topic in FULL_CURRICULUM:
        topic_id = f"00000000-0000-0000-0000-0000000000{topic['order_index']:02d}"
        
        topic_payload = {
            "id": topic_id,
            "title_hr": topic["title_hr"],
            "title_ua": topic["title_ua"],
            "description": topic["description"],
            "order_index": topic["order_index"]
        }
        
        supabase.table("topics").upsert(topic_payload).execute()
        print(f"📁 Модуль створено/оновлено: {topic['title_hr']}")
        
        vocab_payload = [
            {
                "topic_id": topic_id,
                "item_type": item["type"],
                "hr_text": item["hr"],
                "ua_translation": item["ua"]
            }
            for item in topic["vocab"]
        ]
        
        supabase.table("vocabulary").insert(vocab_payload).execute()
        print(f"   ✅ Додано елементів лексики: {len(vocab_payload)}")

    print("🎉 Успішно! Усі дані завантажено в базу.")

if __name__ == "__main__":
    seed_database()