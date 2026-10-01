import os
import tempfile
from supabase import create_client, Client
from gtts import gTTS

# 1. КОНФІГУРАЦІЯ SUPABASE
SUPABASE_URL = "" # або "your-key-here"
SUPABASE_KEY = "" # або "your-key-here"
BUCKET_NAME = "audio"

# Ініціалізація клієнта
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

def generate_and_upload_audio(table_name, text_column):
    print(f"\n--- Починаємо обробку таблиці: {table_name} ---")
    
    # Вибираємо записи без аудіо
    response = supabase.table(table_name).select("id", text_column).is_("audio_url", "null").execute()
    records = response.data
    
    if not records:
        print(f"У таблиці {table_name} немає записів без аудіо.")
        return

    print(f"Знайдено {len(records)} записів для озвучення.")

    for record in records:
        record_id = record['id']
        text_to_speak = record[text_column]
        storage_path = f"{table_name}/{record_id}.mp3"
        
        with tempfile.NamedTemporaryFile(delete=False, suffix=".mp3") as tmp_file:
            tmp_filename = tmp_file.name

        try:
            # 1. Генерація аудіо через Google TTS (lang='hr' - хорватська мова)
            tts = gTTS(text=text_to_speak, lang='hr', slow=False)
            tts.save(tmp_filename)

            # 2. Завантаження файлу в Supabase Storage
            with open(tmp_filename, 'rb') as f:
                supabase.storage.from_(BUCKET_NAME).upload(
                    path=storage_path,
                    file=f,
                    file_options={"content-type": "audio/mpeg"}
                )

            # 3. Отримання публічного посилання на файл
            public_url = supabase.storage.from_(BUCKET_NAME).get_public_url(storage_path)

            # 4. Оновлення запису в базі даних
            supabase.table(table_name).update({"audio_url": public_url}).eq("id", record_id).execute()

            print(f"✅ Успіх: '{text_to_speak}'")

        except Exception as e:
            print(f"❌ Помилка для '{text_to_speak}': {e}")
        
        finally:
            if os.path.exists(tmp_filename):
                os.remove(tmp_filename)

# Запускаємо процес для обох таблиць
generate_and_upload_audio("vocabulary", "hr_text")
generate_and_upload_audio("conversations", "hr_text")

print("\n🎉 Озвучення завершено!")