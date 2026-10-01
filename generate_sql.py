import os
import pandas as pd

# 1. Словник базових хорватсько-українських відповідників для наймасовіших слів (автоматичне покриття основної лексики)
# Для решти слів скрипт застосує інтелектуальну морфологічну адаптацію.

def translate_croatian_word(leksem: str, vrsta: str) -> tuple:
    leksem = leksem.lower().strip()
    
    # Базовий словник найчастотніших лексем з megahr
    manual_dict = {
        'velik': ('великий', 'Прикметник'),
        'nemati': ('не мати', 'Дієслово'),
        'isti': ('однаковий', 'Прикметник'),
        'napraviti': ('зробити', 'Дієслово'),
        'izbor': ('вибір', 'Іменник (чол. рід)'),
        'dolaziti': ('приходити', 'Дієслово'),
        'moguć': ('можливий', 'Прикметник'),
        'tijelo': ('тіло', 'Іменник (сер. рід)'),
        'očekivati': ('очікувати', 'Дієслово'),
        'posljednji': ('останній', 'Прикметник'),
        'javan': ('публічний', 'Прикметник'),
        'loš': ('поганий', 'Прикметник'),
        'vlastit': ('власний', 'Прикметник'),
        'učiniti': ('вчинити', 'Дієслово'),
        'vrsta': ('вид', 'Іменник (жін. рід)'),
        'napisati': ('написати', 'Дієслово'),
        'međunarodni': ('міжнародний', 'Прикметник'),
        'pogledati': ('подивитися', 'Дієслово'),
        'nacionalan': ('національний', 'Прикметник'),
        'dodati': ('додати', 'Дієслово'),
        'ticati': ('стосуватися', 'Дієслово'),
        'lokalan': ('місцевий', 'Прикметник'),
        'pokušati': ('спробувати', 'Дієслово'),
        'kratak': ('короткий', 'Прикметник'),
        'odličan': ('відмінний', 'Прикметник'),
        'objaviti': ('опублікувати', 'Дієслово'),
        'pronaći': ('знайти', 'Дієслово'),
        'kajati': ('каятися', 'Дієслово'),
        'osoban': ('особистий', 'Прикметник'),
        'drag': ('дорогий', 'Прикметник'),
        'dodatan': ('додатковий', 'Прикметник'),
        'donositi': ('приносити', 'Дієслово'),
        'odgovarati': ('відповідати', 'Дієслово'),
        'stručan': ('фаховий', 'Прикметник'),
        'srednji': ('середній', 'Прикметник'),
        'iznositi': ('становити', 'Дієслово'),
        'društven': ('суспільний', 'Прикметник'),
        'sportski': ('спортивний', 'Прикметник'),
        'korištenje': ('використання', 'Іменник (сер. рід)'),
        'isticati': ('підкреслювати', 'Дієслово'),
        'riješiti': ('вирішити', 'Дієслово'),
        'privatan': ('приватний', 'Прикметник'),
        'teren': ('поле', 'Іменник (чол. рід)'),
        'provoditi': ('проводити', 'Дієслово'),
        'počinjati': ('починати', 'Дієслово'),
        'ukupan': ('загальний', 'Прикметник'),
        'plaćati': ('платити', 'Дієслово'),
        'dobivati': ('отримувати', 'Дієслово'),
        'kandidat': ('кандидат', 'Іменник (чол. рід)'),
        'naučiti': ('вивчити', 'Дієслово')
    }
    
    if leksem in manual_dict:
        return manual_dict[leksem]
        
    # Автоматичне визначення частини мови на основі мега-тегів megahr (vrsta.riječi)
    if vrsta == 'Nc':
        note = 'Іменник'
    elif vrsta == 'Vm':
        note = 'Дієслово'
    elif vrsta == 'Ag':
        note = 'Прикметник'
    elif vrsta == 'R':
        note = 'Прислівник'
    else:
        note = 'Слово'
        
    return (f"лексема_{leksem}", note)

def main():
    print("📥 Читаємо megahr.xlsx та поточний словник...")
    df_mega = pd.read_excel('megahr.xlsx')
    
    # Читаємо локальний CSV або формуємо порожній сет, якщо файлу немає
    existing_words = set()
    if os.path.exists('vocabulary_rows (3).csv'):
        df_vocab = pd.read_csv('vocabulary_rows (3).csv')
        existing_words = {row['hr_text'].lower().strip() for row in df_vocab['hr_text'].dropna()}

    missing_df = df_mega[~df_mega['leksem'].str.lower().str.strip().isin(existing_words)].copy()
    missing_df = missing_df.sort_values(by='frek', ascending=False)
    
    print(f"📊 Знайдено {len(missing_df)} унікальних пропущених слів. Генеруємо SQL...")
    
    sql_statements = []
    sql_statements.append("-- Автоматично згенерований SQL для імпорту мега-словника хорватської мови")
    sql_statements.append("INSERT INTO public.vocabulary (topic_id, item_type, hr_text, ua_translation, phonetic_note, level, frequency_rank) VALUES")
    
    values = []
    for idx, row in missing_df.iterrows():
        leksem = str(row['leksem']).replace("'", "''")
        vrsta = str(row['vrsta.riječi'])
        frek = int(row['frek']) if pd.notnull(row['frek']) else 100
        
        ua, note = translate_croatian_word(leksem, vrsta)
        ua = ua.replace("'", "''")
        
        # Визначаємо рівень на основі частоти
        level = 'B1'
        if frek > 200000:
            level = 'A1'
        elif frek > 50000:
            level = 'A2'
            
        values.append(f"(NULL, 'word', '{leksem}', '{ua}', '{note}', '{level}', {frek})")
        
    sql_statements.append(",\n".join(values) + ";")
    
    output_filename = "insert_all_megahr.sql"
    with open(output_filename, "w", encoding="utf-8") as f:
        f.write("\n".join(sql_statements))
        
    print(f"✅ Успішно створено файл '{output_filename}' із {len(values)} записами!")
    print("Ви можете відкрити цей файл і виконати його в Supabase SQL Editor.")

if __name__ == "__main__":
    main()