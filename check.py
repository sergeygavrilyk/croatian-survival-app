import pandas as pd

# Переконайтеся, що файл називається саме так, або змініть на актуальну назву
df = pd.read_csv("lexemes_rows (2).csv")
print("Total A1:", len(df[df['cefr'] == 'A1']))
print("Total rows in file:", len(df))