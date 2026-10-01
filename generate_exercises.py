import random
import json
import os
from dotenv import load_dotenv
from supabase import create_client, Client

# Конфігурація
# Завантажуємо ключі з файлу .env.local
load_dotenv('.env.local')

SUPABASE_URL = os.getenv("NEXT_PUBLIC_SUPABASE_URL")
SUPABASE_KEY = os.getenv("NEXT_PUBLIC_SUPABASE_ANON_KEY") # Або створити окрему змінну для Service Key
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

print("Завантаження реплік з бази...")
response = supabase.table("conversations").select("*").execute()
conversations = response.data

exercises_to_insert = []

for conv in conversations:
    hr_text = conv['hr_text']
    words = hr_text.split()
    
    # Фільтруємо слова довші за 3 літери для пропусків (щоб не ховати прийменники)
    valid_words = [w for w in words if len(w) > 3 and w.isalpha()]
    
    if valid_words:
        # 1. ГЕНЕРАЦІЯ "FILL IN THE BLANK"
        target_word = random.choice(valid_words)
        question_text = hr_text.replace(target_word, "______")
        
        # Створюємо фейкові варіанти (в ідеалі брати з таблиці vocabulary)
        options = [target_word, target_word+"o", target_word[:-1]+"i", target_word+"a"]
        random.shuffle(options)
        
        exercises_to_insert.append({
            "topic_id": conv['topic_id'],
            "conversation_id": conv['id'],
            "exercise_type": "fill_in_the_blank",
            "question_text": question_text,
            "correct_answer": target_word,
            "options": options,
            "level": conv.get('level', 'A1')
        })

    # 2. ГЕНЕРАЦІЯ "SENTENCE BUILDER"
    # Перемішуємо слова оригінального речення для масиву options
    shuffled_words = words.copy()
    random.shuffle(shuffled_words)
    
    exercises_to_insert.append({
        "topic_id": conv['topic_id'],
        "conversation_id": conv['id'],
        "exercise_type": "sentence_builder",
        "question_text": f"Складіть речення: {conv['ua_translation']}",
        "correct_answer": hr_text,
        "options": shuffled_words,
        "level": conv.get('level', 'A1')
    })

# Запис у базу
print(f"Генеруємо {len(exercises_to_insert)} вправ...")
if exercises_to_insert:
    # Supabase API підтримує масовий insert
    supabase.table("exercises").insert(exercises_to_insert).execute()
    print("Успіх! Вправи додано до бази.")