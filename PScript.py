import pandas as pd

# Завантаження файлів (точні назви збережено)
csv_file = 'vocabulary_rows (1).csv'
excel_file = 'megahr.xlsx'

df_vocab = pd.read_csv(csv_file)
df_megahr = pd.read_excel(excel_file)

# --- ПРАВИЛЬНІ НАЗВИ КОЛОНОК ---
vocab_word_col = 'hr_text'       # Колонка зі словом у CSV
megahr_word_col = 'leksem'       # Колонка зі словом у Excel
megahr_freq_col = 'frek'         # Колонка з частотністю у Excel

print("Вираховуємо ранги на основі частотності (frek)...")
# Переводимо слова в нижній регістр для точного співпадіння та видаляємо можливі пробіли
df_megahr[megahr_word_col] = df_megahr[megahr_word_col].astype(str).str.lower().str.strip()

# Сортуємо датафрейм за частотністю (від найуживаніших до найменш уживаних)
df_megahr = df_megahr.sort_values(by=megahr_freq_col, ascending=False).reset_index(drop=True)

# Створюємо колонку з рангом (1 - найчастіше слово, 2 - наступне і т.д.)
# method='min' означає, що якщо слова мають однакову частоту, вони отримають однаковий ранг
df_megahr['calculated_rank'] = df_megahr[megahr_freq_col].rank(method='min', ascending=False).astype(int)

# Створення словника відповідності: слово -> вирахуваний ранг
rank_dict = dict(zip(
    df_megahr[megahr_word_col], 
    df_megahr['calculated_rank']
))

print("Оновлюємо значення у файлі словника...")
# Переводимо слова у CSV теж у нижній регістр для порівняння
vocab_words_lower = df_vocab[vocab_word_col].astype(str).str.lower().str.strip()

# Якщо слово знайдено в megahr_2.xlsx, його frequency_rank оновлюється. 
# Якщо ні — залишається старим (fillna).
df_vocab['frequency_rank'] = vocab_words_lower.map(rank_dict).fillna(df_vocab['frequency_rank'])

# За бажанням, можна привести frequency_rank до цілого числа, якщо там немає пустих значень
df_vocab['frequency_rank'] = df_vocab['frequency_rank'].astype(int)

# Збереження результату у новий файл
output_filename = 'vocabulary_rows_updated.csv'
df_vocab.to_csv(output_filename, index=False)

print(f"Готово! Оновлений словник збережено у файл: {output_filename}")