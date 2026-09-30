import os
from gtts import gTTS
from supabase import create_client

# Функція для автоматичного читання змінних з .env.local
def load_env(filepath):
    env = {}
    if os.path.exists(filepath):
        with open(filepath, 'r', encoding='utf-8') as f:
            for line in f:
                if '=' in line and not line.startswith('#'):
                    parts = line.strip().split('=', 1)
                    if len(parts) == 2:
                        k, v = parts
                        env[k.strip()] = v.strip().strip('"\'')
    return env

# Зчитуємо конфігурацію з кореня проєкту Next.js
env_vars = load_env('.env.local')
SUPABASE_URL = env_vars.get('NEXT_PUBLIC_SUPABASE_URL')
SUPABASE_KEY = env_vars.get('NEXT_PUBLIC_SUPABASE_ANON_KEY')

if not SUPABASE_URL or not SUPABASE_KEY:
    print("Помилка: не вдалося знайти ключі Supabase у файлі .env.local!")
    exit(1)

supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

# Створюємо папку public/audio, якщо її немає
os.makedirs("public/audio", exist_ok=True)

# Завантажуємо всі слова з бази
response = supabase.table("vocabulary").select("id, hr_text").execute()
words = response.data

print(f"Знайдено слів для озвучення: {len(words)}")

for item in words:
    word_id = str(item["id"])
    text = item["hr_text"]
    
    filename = f"public/audio/{word_id}.mp3"
    
    # Генеруємо аудіо лише якщо файл ще не створено
    if not os.path.exists(filename):
        try:
            tts = gTTS(text=text, lang="hr")
            tts.save(filename)
            print(f"Згенеровано: {text} -> {filename}")
        except Exception as e:
            print(f"Помилка для '{text}': {e}")
    else:
        print(f"Вже існує: {text}")

print("Аудіогенерацію успішно завершено!")