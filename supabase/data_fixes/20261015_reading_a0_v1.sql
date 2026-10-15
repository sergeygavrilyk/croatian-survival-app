-- =====================================================================
-- Тексти для читання A0 (§6 ТЗ «Extensive Reading») · reading_a0_v1 · 2026-10-15
-- Згенеровано: python3 scripts/gen_reading.py (не редагуйте вручну).
-- Запуск: Supabase → SQL Editor → вставити ВЕСЬ файл → Run. Потрібні M15 і M16 (тип «sign»).
--
--   * 20 текстів (RD-A0-001 … RD-A0-020): вивіски, цінники, розклади й короткі записки A0 (кожен рядок вивіски — окрема табличка).
--   * У кожного: повний переклад, словничок «слово → лема → переклад» із граматичною підказкою (§56),
--     3 питання на розуміння, частка знайомих слів з уроків (known_ratio).
--   * Статус PUBLISHED: бета, як уроки A0 (носій ще не перевіряв).
--   * Повторний запуск безпечний (наявні коди не перезаписуються).
-- =====================================================================

begin;

do $$
begin
  if to_regclass('public.reading_texts') is null then
    raise exception 'Спершу запустіть міграцію M15 (20261014100000_m15_reading.sql)';
  end if;
  if not exists (select 1 from pg_constraint where conname = 'reading_texts_text_type_check'
                 and pg_get_constraintdef(oid) like '%sign%') then
    raise exception 'Спершу запустіть міграцію M16 (20261015120000_m16_reading_signs.sql)';
  end if;
end $$;

insert into public.reading_texts (code, cefr, text_type, situation, module_order, title_ua, title_hr, body_hr, body_ua, glossary, questions, word_count, known_ratio, order_index, status, source)
values ('RD-A0-001', 'A0', 'sign', 'basics', 1, 'На дверях магазину', 'Na vratima trgovine',
        'DOBRO DOŠLI!
OTVORENO
Dobar dan! Izvolite.
Hvala i doviđenja!',
        'ЛАСКАВО ПРОСИМО!
ВІДЧИНЕНО
Добрий день! Прошу, заходьте.
Дякуємо і до побачення!',
        '[{"form": "dobro", "lemma": "dobro došli", "ua": "ласкаво просимо", "lesson": true, "pos": "сталий вираз «ласкаво просимо»", "gram": "частина виразу «Dobro došli!» — ласкаво просимо"}, {"form": "došli", "lemma": "dobro došli", "ua": "ласкаво просимо", "lesson": true, "pos": "сталий вираз «ласкаво просимо»", "gram": "частина виразу «Dobro došli!» (došli — дієприкметник від doći, множина)"}, {"form": "otvoreno", "lemma": "otvoren", "ua": "відчинений / відкритий", "lesson": true, "pos": "прикметник", "gram": "с. р.: «Otvoreno» — відчинено"}, {"form": "dobar", "lemma": "dobar", "ua": "добрий; гарний", "lesson": false, "pos": "прикметник"}, {"form": "dan", "lemma": "dan", "ua": "день", "lesson": false, "pos": "іменник, чоловічий рід"}, {"form": "izvolite", "lemma": "izvolite", "ua": "прошу (вам)", "lesson": true, "pos": "сталий вираз «прошу; будь ласка (пропонуючи)»"}, {"form": "hvala", "lemma": "hvala", "ua": "дякую", "lesson": true, "pos": "частка"}, {"form": "i", "lemma": "i", "ua": "і; та", "lesson": false, "pos": "сполучник"}, {"form": "doviđenja", "lemma": "doviđenja", "ua": "до побачення", "lesson": true, "pos": "вигук"}]'::jsonb,
        '[{"question_ua": "Що означає «OTVORENO»?", "options": ["Відчинено", "Зачинено", "Перерва"], "answer": "Відчинено"}, {"question_ua": "Що вам кажуть, коли ви заходите?", "options": ["Dobar dan! Izvolite.", "Laku noć!", "Oprostite!"], "answer": "Dobar dan! Izvolite."}, {"question_ua": "Як магазин прощається з покупцями?", "options": ["Hvala i doviđenja!", "Dobro došli!", "Vidimo se sutra!"], "answer": "Hvala i doviđenja!"}]'::jsonb, 9, 0.778, 1, 'PUBLISHED', 'claude_reading_a0_v1')
on conflict (code) do nothing;
insert into public.reading_texts (code, cefr, text_type, situation, module_order, title_ua, title_hr, body_hr, body_ua, glossary, questions, word_count, known_ratio, order_index, status, source)
values ('RD-A0-002', 'A0', 'sign', 'cafe_restaurant', 1, 'Табличка на дверях кафе', 'Natpis na vratima kafića',
        'ZATVORENO
Oprostite, danas ne radimo.
Vidimo se sutra!
Hvala!',
        'ЗАЧИНЕНО
Вибачте, сьогодні ми не працюємо.
Побачимося завтра!
Дякуємо!',
        '[{"form": "zatvoreno", "lemma": "zatvoren", "ua": "зачинений", "lesson": false, "pos": "прикметник «зачинений»", "gram": "с. р.: «Zatvoreno» — зачинено"}, {"form": "oprostite", "lemma": "oprostite", "ua": "Вибачте / Перепрошую.", "lesson": true, "pos": "сталий вираз «вибачте»"}, {"form": "danas", "lemma": "danas", "ua": "сьогодні", "lesson": true, "pos": "прислівник"}, {"form": "ne", "lemma": "ne", "ua": "ні", "lesson": true, "pos": "частка"}, {"form": "radimo", "lemma": "raditi", "ua": "працювати, робити", "lesson": true, "pos": "дієслово, недоконаний вид (що робити?)", "gram": "теперішній час: ми"}, {"form": "vidimo", "lemma": "vidjeti", "ua": "бачити", "lesson": false, "pos": "дієслово, доконаний і недоконаний вид", "gram": "теперішній час: ми. «Vidimo se!» — побачимося"}, {"form": "se", "lemma": "se", "ua": "себе; -ся (частка дієслова)", "lesson": false, "pos": "зворотний займенник «себе / -ся» (коротка форма; стоїть на другому місці в реченні)"}, {"form": "sutra", "lemma": "sutra", "ua": "завтра", "lesson": true, "pos": "прислівник"}, {"form": "hvala", "lemma": "hvala", "ua": "дякую", "lesson": true, "pos": "частка"}]'::jsonb,
        '[{"question_ua": "Чи працює кафе сьогодні?", "options": ["Ні, зачинено", "Так, до вечора", "Тільки вранці"], "answer": "Ні, зачинено"}, {"question_ua": "Коли кафе знову працюватиме?", "options": ["Завтра", "Через тиждень", "У понеділок"], "answer": "Завтра"}, {"question_ua": "Що означає «Oprostite»?", "options": ["Вибачте", "Дякую", "Привіт"], "answer": "Вибачте"}]'::jsonb, 9, 0.889, 2, 'PUBLISHED', 'claude_reading_a0_v1')
on conflict (code) do nothing;
insert into public.reading_texts (code, cefr, text_type, situation, module_order, title_ua, title_hr, body_hr, body_ua, glossary, questions, word_count, known_ratio, order_index, status, source)
values ('RD-A0-003', 'A0', 'sign', 'cafe_restaurant', 2, 'Бейдж офіціантки', 'Pločica s imenom',
        'ANA
Zovem se Ana. Ja sam konobarica.
Govorim hrvatski i engleski.
Pitajte me!',
        'АНА
Мене звати Ана. Я офіціантка.
Я говорю хорватською та англійською.
Запитуйте мене!',
        '[{"form": "ana", "lemma": "Ana", "ua": "Ана (ім’я)", "lesson": false, "pos": "ім’я (жіноче)"}, {"form": "zovem", "lemma": "zovem se", "ua": "мене звати", "lesson": true, "pos": "сталий вираз «мене звати» (від zvati se)", "gram": "теперішній час: я. «zovem se» — мене звати"}, {"form": "se", "lemma": "se", "ua": "себе; -ся (частка дієслова)", "lesson": false, "pos": "зворотний займенник «себе / -ся» (коротка форма; стоїть на другому місці в реченні)"}, {"form": "ja", "lemma": "ja", "ua": "я", "lesson": true, "pos": "особовий займенник «я»"}, {"form": "sam", "lemma": "biti", "ua": "бути; є", "lesson": false, "pos": "дієслово «бути» (недоконаний вид); короткі форми sam, si, je, smo, ste, su", "gram": "теперішній час: я. Коротка форма; також допоміжне в минулому часі («došla sam» — я приїхала)"}, {"form": "konobarica", "lemma": "konobarica", "ua": "офіціантка", "lesson": false, "pos": "іменник, жіночий рід"}, {"form": "govorim", "lemma": "govoriti", "ua": "говорити", "lesson": true, "pos": "дієслово, недоконаний вид (що робити?)", "gram": "теперішній час: я"}, {"form": "hrvatski", "lemma": "hrvatski", "ua": "хорватська (мова)", "lesson": true, "pos": "прикметник «хорватський»; як іменник — хорватська мова"}, {"form": "i", "lemma": "i", "ua": "і; та", "lesson": false, "pos": "сполучник"}, {"form": "engleski", "lemma": "engleski", "ua": "англійська (мова)", "lesson": true, "pos": "прикметник «англійський»; як іменник — англійська мова"}, {"form": "pitajte", "lemma": "pitati", "ua": "питати", "lesson": true, "pos": "дієслово, недоконаний вид (що робити?)", "gram": "наказовий спосіб: ви (зробіть!)"}, {"form": "me", "lemma": "ja", "ua": "я", "lesson": true, "pos": "особовий займенник «я»", "gram": "знахідний відмінок (кого? що?), однина. Коротка форма від mene: «Pitajte me!», «nazvala me»"}]'::jsonb,
        '[{"question_ua": "Ким працює Ана?", "options": ["Офіціанткою", "Лікаркою", "Продавчинею"], "answer": "Офіціанткою"}, {"question_ua": "Якими мовами вона говорить?", "options": ["Хорватською й англійською", "Тільки хорватською", "Українською"], "answer": "Хорватською й англійською"}, {"question_ua": "Що означає «Pitajte me!»?", "options": ["Запитуйте мене!", "Чекайте мене!", "Платіть тут!"], "answer": "Запитуйте мене!"}]'::jsonb, 13, 0.846, 3, 'PUBLISHED', 'claude_reading_a0_v1')
on conflict (code) do nothing;
insert into public.reading_texts (code, cefr, text_type, situation, module_order, title_ua, title_hr, body_hr, body_ua, glossary, questions, word_count, known_ratio, order_index, status, source)
values ('RD-A0-004', 'A0', 'sign', 'health', 2, 'Табличка на дверях кабінету', 'Natpis na vratima ordinacije',
        'Dr. Ivo Kovač
liječnik obiteljske medicine
Soba 3
Molimo, pokucajte!',
        'Д-р Іво Ковач
лікар сімейної медицини
Кабінет 3
Просимо, постукайте!',
        '[{"form": "dr", "lemma": "dr", "ua": "лікар (скорочення «доктор»)", "lesson": false, "pos": "скорочення: doktor / doktorica"}, {"form": "ivo", "lemma": "Ivo", "ua": "Іво (ім’я)", "lesson": false, "pos": "ім’я (чоловіче)"}, {"form": "kovač", "lemma": "Kovač", "ua": "Ковач (прізвище)", "lesson": false, "pos": "прізвище"}, {"form": "liječnik", "lemma": "liječnik", "ua": "лікар", "lesson": true, "pos": "іменник, чоловічий рід"}, {"form": "obiteljske", "lemma": "obiteljski", "ua": "сімейний", "lesson": false, "pos": "прикметник", "gram": "родовий відмінок (кого? чого?), однина, ж. р."}, {"form": "medicine", "lemma": "medicina", "ua": "медицина", "lesson": false, "pos": "іменник, жіночий рід", "gram": "родовий відмінок (кого? чого?), однина"}, {"form": "soba", "lemma": "soba", "ua": "кімната", "lesson": true, "pos": "іменник, жіночий рід"}, {"form": "molimo", "lemma": "moliti", "ua": "просити («molimo» — просимо)", "lesson": false, "pos": "дієслово, недоконаний вид (що робити?)", "gram": "теперішній час: ми. «Molimo …» — просимо"}, {"form": "pokucajte", "lemma": "pokucati", "ua": "постукати", "lesson": false, "pos": "дієслово, доконаний вид (що зробити?)", "gram": "наказовий спосіб: ви (зробіть!)"}]'::jsonb,
        '[{"question_ua": "Хто працює в цьому кабінеті?", "options": ["Лікар", "Учитель", "Продавець"], "answer": "Лікар"}, {"question_ua": "Який номер кабінету?", "options": ["3", "13", "30"], "answer": "3"}, {"question_ua": "Що треба зробити, перш ніж зайти?", "options": ["Постукати", "Подзвонити", "Почекати на вулиці"], "answer": "Постукати"}]'::jsonb, 9, 0.556, 4, 'PUBLISHED', 'claude_reading_a0_v1')
on conflict (code) do nothing;
insert into public.reading_texts (code, cefr, text_type, situation, module_order, title_ua, title_hr, body_hr, body_ua, glossary, questions, word_count, known_ratio, order_index, status, source)
values ('RD-A0-005', 'A0', 'sign', 'shopping', 3, 'Цінники на ринку', 'Cijene na tržnici',
        'JABUKE 1,50 € / kg
KRUŠKE 2 € / kg
JAJA – 10 komada 3 €
SIR 8 € / kg',
        'ЯБЛУКА 1,50 € / кг
ГРУШІ 2 € / кг
ЯЙЦЯ – 10 штук 3 €
СИР 8 € / кг',
        '[{"form": "jabuke", "lemma": "jabuka", "ua": "яблуко", "lesson": true, "pos": "іменник, жіночий рід", "gram": "називний відмінок (хто? що?), множина"}, {"form": "kg", "lemma": "kg", "ua": "кг (кілограм)", "lesson": false, "pos": "скорочення: kilogram"}, {"form": "kruške", "lemma": "kruška", "ua": "груша", "lesson": true, "pos": "іменник, жіночий рід", "gram": "називний відмінок (хто? що?), множина"}, {"form": "jaja", "lemma": "jaje", "ua": "яйце", "lesson": true, "pos": "іменник, середній рід", "gram": "називний відмінок (хто? що?), множина"}, {"form": "komada", "lemma": "komad", "ua": "шматок, штука", "lesson": true, "pos": "іменник, чоловічий рід", "gram": "родовий відмінок (кого? чого?), множина. Після 5 і більше: «10 komada» — 10 штук"}, {"form": "sir", "lemma": "sir", "ua": "сир", "lesson": true, "pos": "іменник, чоловічий рід"}]'::jsonb,
        '[{"question_ua": "Скільки коштує кілограм яблук?", "options": ["1,50 €", "2 €", "8 €"], "answer": "1,50 €"}, {"question_ua": "Що найдорожче?", "options": ["Сир", "Груші", "Яйця"], "answer": "Сир"}, {"question_ua": "Скільки яєць можна купити за 3 €?", "options": ["10", "5", "3"], "answer": "10"}]'::jsonb, 8, 0.750, 5, 'PUBLISHED', 'claude_reading_a0_v1')
on conflict (code) do nothing;
insert into public.reading_texts (code, cefr, text_type, situation, module_order, title_ua, title_hr, body_hr, body_ua, glossary, questions, word_count, known_ratio, order_index, status, source)
values ('RD-A0-006', 'A0', 'sign', 'travel', 3, 'Номери в готелі', 'Sobe u hotelu',
        'Sobe 1 – 10: prvi kat
Sobe 11 – 20: drugi kat
Recepcija: prizemlje
Lift je desno.',
        'Номери 1–10: перший поверх (над входом)
Номери 11–20: другий поверх
Рецепція: партер (поверх біля входу)
Ліфт праворуч.',
        '[{"form": "sobe", "lemma": "soba", "ua": "кімната", "lesson": true, "pos": "іменник, жіночий рід", "gram": "називний відмінок (хто? що?), множина"}, {"form": "prvi", "lemma": "prvi", "ua": "перший", "lesson": true, "pos": "порядковий числівник"}, {"form": "kat", "lemma": "kat", "ua": "поверх", "lesson": true, "pos": "іменник, чоловічий рід"}, {"form": "drugi", "lemma": "drugi", "ua": "другий; інший", "lesson": false, "pos": "прикметник «другий; інший»"}, {"form": "recepcija", "lemma": "recepcija", "ua": "рецепція", "lesson": true, "pos": "іменник, жіночий рід"}, {"form": "prizemlje", "lemma": "prizemlje", "ua": "партер (поверх біля входу)", "lesson": false, "pos": "іменник, середній рід"}, {"form": "lift", "lemma": "lift", "ua": "ліфт", "lesson": false, "pos": "іменник, чоловічий рід"}, {"form": "je", "lemma": "biti", "ua": "бути; є", "lesson": false, "pos": "дієслово «бути» (недоконаний вид); короткі форми sam, si, je, smo, ste, su", "gram": "теперішній час: він / вона / воно. Коротка форма"}, {"form": "desno", "lemma": "desno", "ua": "направо / праворуч", "lesson": true, "pos": "прислівник"}]'::jsonb,
        '[{"question_ua": "Де рецепція?", "options": ["На поверсі біля входу (prizemlje)", "На першому поверсі", "На другому поверсі"], "answer": "На поверсі біля входу (prizemlje)"}, {"question_ua": "Ваш номер — 15. Який це поверх?", "options": ["Другий (drugi kat)", "Перший (prvi kat)", "Біля входу"], "answer": "Другий (drugi kat)"}, {"question_ua": "Де ліфт?", "options": ["Праворуч", "Ліворуч", "Ліфта немає"], "answer": "Праворуч"}]'::jsonb, 11, 0.636, 6, 'PUBLISHED', 'claude_reading_a0_v1')
on conflict (code) do nothing;
insert into public.reading_texts (code, cefr, text_type, situation, module_order, title_ua, title_hr, body_hr, body_ua, glossary, questions, word_count, known_ratio, order_index, status, source)
values ('RD-A0-007', 'A0', 'sign', 'administration', 4, 'Години роботи пошти', 'Radno vrijeme pošte',
        'POŠTA
Radno vrijeme:
ponedjeljak – petak: 7 – 19 h
subota: 8 – 13 h
nedjelja: zatvoreno',
        'ПОШТА
Години роботи:
понеділок – п’ятниця: 7–19
субота: 8–13
неділя: зачинено',
        '[{"form": "pošta", "lemma": "pošta", "ua": "пошта", "lesson": true, "pos": "іменник, жіночий рід"}, {"form": "radno", "lemma": "radno vrijeme", "ua": "робочий час", "lesson": true, "pos": "сталий вираз", "gram": "с. р.: частина виразу «radno vrijeme»"}, {"form": "vrijeme", "lemma": "vrijeme", "ua": "погода / час", "lesson": true, "pos": "іменник, середній рід"}, {"form": "ponedjeljak", "lemma": "ponedjeljak", "ua": "понеділок", "lesson": true, "pos": "іменник, чоловічий рід"}, {"form": "petak", "lemma": "petak", "ua": "п''ятниця", "lesson": true, "pos": "іменник, чоловічий рід"}, {"form": "h", "lemma": "h", "ua": "скорочення: sat (година)", "lesson": false, "pos": "скорочення: sat (година)"}, {"form": "subota", "lemma": "subota", "ua": "субота", "lesson": true, "pos": "іменник, жіночий рід"}, {"form": "nedjelja", "lemma": "nedjelja", "ua": "неділя", "lesson": true, "pos": "іменник, жіночий рід"}, {"form": "zatvoreno", "lemma": "zatvoren", "ua": "зачинений", "lesson": false, "pos": "прикметник «зачинений»", "gram": "с. р.: «Zatvoreno» — зачинено"}]'::jsonb,
        '[{"question_ua": "Чи працює пошта в неділю?", "options": ["Ні", "Так, до 13", "Так, увесь день"], "answer": "Ні"}, {"question_ua": "До котрої пошта працює в суботу?", "options": ["До 13", "До 19", "До 8"], "answer": "До 13"}, {"question_ua": "О котрій пошта відчиняється в понеділок?", "options": ["О 7", "О 8", "О 13"], "answer": "О 7"}]'::jsonb, 10, 0.600, 7, 'PUBLISHED', 'claude_reading_a0_v1')
on conflict (code) do nothing;
insert into public.reading_texts (code, cefr, text_type, situation, module_order, title_ua, title_hr, body_hr, body_ua, glossary, questions, word_count, known_ratio, order_index, status, source)
values ('RD-A0-008', 'A0', 'sign', 'transport', 4, 'Розклад автобуса', 'Vozni red autobusa',
        'AUTOBUS 6
Smjer: Kolodvor
Polasci: 7:15 • 7:45 • 8:15
Vikendom: svaki sat',
        'АВТОБУС 6
Напрямок: вокзал
Відправлення: 7:15 • 7:45 • 8:15
На вихідних: щогодини',
        '[{"form": "autobus", "lemma": "autobus", "ua": "автобус", "lesson": true, "pos": "іменник, чоловічий рід"}, {"form": "smjer", "lemma": "smjer", "ua": "напрямок", "lesson": true, "pos": "іменник, чоловічий рід"}, {"form": "kolodvor", "lemma": "kolodvor", "ua": "вокзал", "lesson": true, "pos": "іменник, чоловічий рід"}, {"form": "polasci", "lemma": "polazak", "ua": "відправлення", "lesson": true, "pos": "іменник, чоловічий рід", "gram": "називний відмінок (хто? що?), множина"}, {"form": "vikendom", "lemma": "vikend", "ua": "вихідні", "lesson": true, "pos": "іменник, чоловічий рід", "gram": "орудний відмінок (ким? чим?), однина. «vikendom» — на вихідних"}, {"form": "svaki", "lemma": "svaki", "ua": "кожен", "lesson": false, "pos": "займенник «кожен»"}, {"form": "sat", "lemma": "sat", "ua": "годинник / година", "lesson": true, "pos": "іменник, чоловічий рід"}]'::jsonb,
        '[{"question_ua": "Куди їде автобус 6?", "options": ["До вокзалу", "До аеропорту", "До лікарні"], "answer": "До вокзалу"}, {"question_ua": "Як часто він їздить на вихідних?", "options": ["Щогодини", "Кожні 30 хвилин", "Не їздить"], "answer": "Щогодини"}, {"question_ua": "Коли перший автобус?", "options": ["О 7:15", "О 7:45", "О 8:15"], "answer": "О 7:15"}]'::jsonb, 7, 0.571, 8, 'PUBLISHED', 'claude_reading_a0_v1')
on conflict (code) do nothing;
insert into public.reading_texts (code, cefr, text_type, situation, module_order, title_ua, title_hr, body_hr, body_ua, glossary, questions, word_count, known_ratio, order_index, status, source)
values ('RD-A0-009', 'A0', 'message', 'small_talk', 5, 'Листівка на день народження', 'Čestitka za rođendan',
        'Draga mama,
sretan rođendan!
Volimo te puno.
Tvoji Ana i Marko',
        'Люба мамо,
з днем народження!
Ми тебе дуже любимо.
Твої Ана і Марко',
        '[{"form": "draga", "lemma": "drag", "ua": "дорогий; милий, приємний", "lesson": true, "pos": "прикметник", "gram": "називний відмінок (хто? що?), однина, ж. р. Звертання в листі"}, {"form": "mama", "lemma": "mama", "ua": "мама", "lesson": true, "pos": "іменник, жіночий рід"}, {"form": "sretan", "lemma": "sretan", "ua": "щасливий", "lesson": true, "pos": "прикметник"}, {"form": "rođendan", "lemma": "rođendan", "ua": "день народження", "lesson": true, "pos": "іменник, чоловічий рід"}, {"form": "volimo", "lemma": "voljeti", "ua": "любити, подобатися", "lesson": true, "pos": "дієслово, недоконаний вид (що робити?)", "gram": "теперішній час: ми"}, {"form": "te", "lemma": "te", "ua": "тебе (займенник)", "lesson": false, "pos": "займенник «тебе» — коротка форма знахідного від ti"}, {"form": "puno", "lemma": "puno", "ua": "багато", "lesson": true, "pos": "прислівник «багато» + родовий («puno turista»)"}, {"form": "tvoji", "lemma": "tvoj", "ua": "твій", "lesson": false, "pos": "присвійний займенник «твій»", "gram": "називний відмінок (хто? що?), множина, ч. р."}, {"form": "ana", "lemma": "Ana", "ua": "Ана (ім’я)", "lesson": false, "pos": "ім’я (жіноче)"}, {"form": "i", "lemma": "i", "ua": "і; та", "lesson": false, "pos": "сполучник"}, {"form": "marko", "lemma": "Marko", "ua": "Марко (ім’я)", "lesson": false, "pos": "ім’я (чоловіче)"}]'::jsonb,
        '[{"question_ua": "Кому листівка?", "options": ["Мамі", "Татові", "Сестрі"], "answer": "Мамі"}, {"question_ua": "Яке свято?", "options": ["День народження", "Новий рік", "Великдень"], "answer": "День народження"}, {"question_ua": "Хто пише листівку?", "options": ["Ана і Марко", "Тільки Ана", "Мама"], "answer": "Ана і Марко"}]'::jsonb, 11, 0.909, 9, 'PUBLISHED', 'claude_reading_a0_v1')
on conflict (code) do nothing;
insert into public.reading_texts (code, cefr, text_type, situation, module_order, title_ua, title_hr, body_hr, body_ua, glossary, questions, word_count, known_ratio, order_index, status, source)
values ('RD-A0-010', 'A0', 'sign', 'small_talk', 5, 'Дитячий майданчик', 'Dječje igralište',
        'DJEČJE IGRALIŠTE
Za djecu do 12 godina.
Roditelji, pazite na djecu!
Psi ne smiju ući.',
        'ДИТЯЧИЙ МАЙДАНЧИК
Для дітей до 12 років.
Батьки, наглядайте за дітьми!
Собакам заходити не можна.',
        '[{"form": "dječje", "lemma": "dječji", "ua": "дитячий", "lesson": false, "pos": "прикметник", "gram": "називний відмінок (хто? що?), однина, с. р."}, {"form": "igralište", "lemma": "igralište", "ua": "дитячий майданчик", "lesson": true, "pos": "іменник, середній рід"}, {"form": "za", "lemma": "za", "ua": "для; за", "lesson": false, "pos": "прийменник: + знахідний — для, за («za strance» — для іноземців)"}, {"form": "djecu", "lemma": "djeca", "ua": "діти", "lesson": true, "pos": "іменник «діти» (множина до dijete); прикметник при ньому — як при ж. р. однини: «moja djeca»", "gram": "знахідний відмінок (кого? що?), однина. «za djecu» — для дітей (djeca відмінюється як ж. р. однини)"}, {"form": "do", "lemma": "do", "ua": "до", "lesson": false, "pos": "прийменник + родовий відмінок"}, {"form": "godina", "lemma": "godina", "ua": "рік", "lesson": true, "pos": "іменник, жіночий рід", "gram": "родовий відмінок (кого? чого?), множина. «do 12 godina» — до 12 років"}, {"form": "roditelji", "lemma": "roditelji", "ua": "батьки", "lesson": true, "pos": "іменник «батьки» (множина від roditelj), ч. р."}, {"form": "pazite", "lemma": "paziti", "ua": "стежити, наглядати; остерігатися («pazi!» — обережно!)", "lesson": false, "pos": "дієслово, недоконаний вид (що робити?)", "gram": "наказовий спосіб: ви (зробіть!). «pazite na djecu» — наглядайте за дітьми"}, {"form": "na", "lemma": "na", "ua": "на", "lesson": false, "pos": "прийменник: + знахідний — куди? («na posao»), + місцевий — де? («na poslu»)"}, {"form": "psi", "lemma": "pas", "ua": "собака", "lesson": true, "pos": "іменник, чоловічий рід", "gram": "називний відмінок (хто? що?), множина"}, {"form": "ne", "lemma": "ne", "ua": "ні", "lesson": true, "pos": "частка"}, {"form": "smiju", "lemma": "smjeti", "ua": "сміти, мати дозвіл («ne smiju» — не можна)", "lesson": true, "pos": "дієслово, недоконаний вид (що робити?)", "gram": "теперішній час: вони"}, {"form": "ući", "lemma": "ući", "ua": "увійти", "lesson": false, "pos": "дієслово, доконаний вид (що зробити?)"}]'::jsonb,
        '[{"question_ua": "Для кого цей майданчик?", "options": ["Для дітей до 12 років", "Для всіх", "Для собак"], "answer": "Для дітей до 12 років"}, {"question_ua": "Що мають робити батьки?", "options": ["Наглядати за дітьми", "Платити", "Чекати надворі"], "answer": "Наглядати за дітьми"}, {"question_ua": "Чи можна прийти із собакою?", "options": ["Ні", "Так", "Тільки ввечері"], "answer": "Ні"}]'::jsonb, 14, 0.643, 10, 'PUBLISHED', 'claude_reading_a0_v1')
on conflict (code) do nothing;
insert into public.reading_texts (code, cefr, text_type, situation, module_order, title_ua, title_hr, body_hr, body_ua, glossary, questions, word_count, known_ratio, order_index, status, source)
values ('RD-A0-011', 'A0', 'sign', 'housing', 6, 'Табличка біля входу в будинок', 'Natpis na ulazu u zgradu',
        'ULAZ B
Stanovi 1 – 12
Lift ne radi. Oprostite!
Molimo, zatvorite vrata.',
        'ВХІД B
Квартири 1–12
Ліфт не працює. Вибачте!
Будь ласка, зачиняйте двері.',
        '[{"form": "ulaz", "lemma": "ulaz", "ua": "вхід; під’їзд", "lesson": true, "pos": "іменник, чоловічий рід"}, {"form": "b", "lemma": "B", "ua": "B (літера, позначення входу)", "lesson": false, "pos": "літера (позначення входу)"}, {"form": "stanovi", "lemma": "stan", "ua": "квартира", "lesson": true, "pos": "іменник, чоловічий рід", "gram": "називний відмінок (хто? що?), множина"}, {"form": "lift", "lemma": "lift", "ua": "ліфт", "lesson": false, "pos": "іменник, чоловічий рід"}, {"form": "ne", "lemma": "ne", "ua": "ні", "lesson": true, "pos": "частка"}, {"form": "radi", "lemma": "raditi", "ua": "працювати, робити", "lesson": true, "pos": "дієслово, недоконаний вид (що робити?)", "gram": "теперішній час: він / вона / воно"}, {"form": "oprostite", "lemma": "oprostite", "ua": "Вибачте / Перепрошую.", "lesson": true, "pos": "сталий вираз «вибачте»"}, {"form": "molimo", "lemma": "moliti", "ua": "просити («molimo» — просимо)", "lesson": false, "pos": "дієслово, недоконаний вид (що робити?)", "gram": "теперішній час: ми. «Molimo …» — просимо"}, {"form": "zatvorite", "lemma": "zatvoriti", "ua": "зачинити; закрити", "lesson": false, "pos": "дієслово, доконаний вид (що зробити?)", "gram": "наказовий спосіб: ви (зробіть!)"}, {"form": "vrata", "lemma": "vrata", "ua": "двері", "lesson": true, "pos": "іменник «двері», с. р., лише множина"}]'::jsonb,
        '[{"question_ua": "Які квартири в цьому під’їзді?", "options": ["1–12", "13–24", "Усі"], "answer": "1–12"}, {"question_ua": "Що з ліфтом?", "options": ["Не працює", "Новий", "Працює тільки вранці"], "answer": "Не працює"}, {"question_ua": "Про що просять мешканців?", "options": ["Зачиняти двері", "Не шуміти", "Платити за ліфт"], "answer": "Зачиняти двері"}]'::jsonb, 10, 0.600, 11, 'PUBLISHED', 'claude_reading_a0_v1')
on conflict (code) do nothing;
insert into public.reading_texts (code, cefr, text_type, situation, module_order, title_ua, title_hr, body_hr, body_ua, glossary, questions, word_count, known_ratio, order_index, status, source)
values ('RD-A0-012', 'A0', 'message', 'housing', 6, 'Записка в апартаментах', 'Poruka u apartmanu',
        'Dobro došli!
Ključ je na stolu.
Lozinka za Wi-Fi je na hladnjaku.
Kupaonica je lijevo, kuhinja je desno.
Ugodan boravak!',
        'Ласкаво просимо!
Ключ — на столі.
Пароль від Wi-Fi — на холодильнику.
Ванна кімната ліворуч, кухня праворуч.
Приємного перебування!',
        '[{"form": "dobro", "lemma": "dobro došli", "ua": "ласкаво просимо", "lesson": true, "pos": "сталий вираз «ласкаво просимо»", "gram": "частина виразу «Dobro došli!» — ласкаво просимо"}, {"form": "došli", "lemma": "dobro došli", "ua": "ласкаво просимо", "lesson": true, "pos": "сталий вираз «ласкаво просимо»", "gram": "частина виразу «Dobro došli!» (došli — дієприкметник від doći, множина)"}, {"form": "ključ", "lemma": "ključ", "ua": "ключ", "lesson": true, "pos": "іменник, чоловічий рід"}, {"form": "je", "lemma": "biti", "ua": "бути; є", "lesson": false, "pos": "дієслово «бути» (недоконаний вид); короткі форми sam, si, je, smo, ste, su", "gram": "теперішній час: він / вона / воно. Коротка форма"}, {"form": "na", "lemma": "na", "ua": "на", "lesson": false, "pos": "прийменник: + знахідний — куди? («na posao»), + місцевий — де? («na poslu»)"}, {"form": "stolu", "lemma": "stol", "ua": "стіл", "lesson": true, "pos": "іменник, чоловічий рід", "gram": "місцевий відмінок (де? про кого? про що?), однина"}, {"form": "lozinka", "lemma": "lozinka", "ua": "пароль", "lesson": true, "pos": "іменник, жіночий рід"}, {"form": "za", "lemma": "za", "ua": "для; за", "lesson": false, "pos": "прийменник: + знахідний — для, за («za strance» — для іноземців)"}, {"form": "wi-fi", "lemma": "wi-fi", "ua": "Wi-Fi (бездротовий інтернет)", "lesson": false, "pos": "іменник, чоловічий рід"}, {"form": "hladnjaku", "lemma": "hladnjak", "ua": "холодильник", "lesson": true, "pos": "іменник, чоловічий рід", "gram": "місцевий відмінок (де? про кого? про що?), однина"}, {"form": "kupaonica", "lemma": "kupaonica", "ua": "ванна кімната", "lesson": true, "pos": "іменник, жіночий рід"}, {"form": "lijevo", "lemma": "lijevo", "ua": "наліво / ліворуч", "lesson": true, "pos": "прислівник"}, {"form": "kuhinja", "lemma": "kuhinja", "ua": "кухня", "lesson": true, "pos": "іменник, жіночий рід"}, {"form": "desno", "lemma": "desno", "ua": "направо / праворуч", "lesson": true, "pos": "прислівник"}, {"form": "ugodan", "lemma": "ugodan", "ua": "приємний", "lesson": false, "pos": "прикметник"}, {"form": "boravak", "lemma": "boravak", "ua": "перебування; проживання", "lesson": true, "pos": "іменник, чоловічий рід"}]'::jsonb,
        '[{"question_ua": "Де ключ?", "options": ["На столі", "На холодильнику", "У ванній"], "answer": "На столі"}, {"question_ua": "Де пароль від Wi-Fi?", "options": ["На холодильнику", "На столі", "Біля дверей"], "answer": "На холодильнику"}, {"question_ua": "Де кухня?", "options": ["Праворуч", "Ліворуч", "Нагорі"], "answer": "Праворуч"}]'::jsonb, 20, 0.750, 12, 'PUBLISHED', 'claude_reading_a0_v1')
on conflict (code) do nothing;
insert into public.reading_texts (code, cefr, text_type, situation, module_order, title_ua, title_hr, body_hr, body_ua, glossary, questions, word_count, known_ratio, order_index, status, source)
values ('RD-A0-013', 'A0', 'menu', 'cafe_restaurant', 7, 'Ціни в кафе', 'Cjenik kafića',
        'CJENIK
Kava 1,80 €
Kava s mlijekom 2,20 €
Čaj 1,50 €
Sok 2,50 €
Voda 1,20 €',
        'ЦІНИ
Кава 1,80 €
Кава з молоком 2,20 €
Чай 1,50 €
Сік 2,50 €
Вода 1,20 €',
        '[{"form": "cjenik", "lemma": "cjenik", "ua": "ціни, прайс", "lesson": false, "pos": "іменник, чоловічий рід"}, {"form": "kava", "lemma": "kava", "ua": "кава", "lesson": true, "pos": "іменник, жіночий рід"}, {"form": "s", "lemma": "s", "ua": "з (разом із)", "lesson": false, "pos": "прийменник «з»: + орудний — разом із («s obitelji»); + родовий — звідки («s Hvara», «s posla»)"}, {"form": "mlijekom", "lemma": "mlijeko", "ua": "молоко", "lesson": true, "pos": "іменник, середній рід", "gram": "орудний відмінок (ким? чим?), однина"}, {"form": "čaj", "lemma": "čaj", "ua": "чай", "lesson": true, "pos": "іменник, чоловічий рід"}, {"form": "sok", "lemma": "sok", "ua": "сік", "lesson": true, "pos": "іменник, чоловічий рід"}, {"form": "voda", "lemma": "voda", "ua": "вода", "lesson": true, "pos": "іменник, жіночий рід"}]'::jsonb,
        '[{"question_ua": "Скільки коштує чай?", "options": ["1,50 €", "1,80 €", "2,50 €"], "answer": "1,50 €"}, {"question_ua": "Що коштує 2,20 €?", "options": ["Кава з молоком", "Сік", "Вода"], "answer": "Кава з молоком"}, {"question_ua": "Що найдешевше?", "options": ["Вода", "Чай", "Кава"], "answer": "Вода"}]'::jsonb, 8, 0.875, 13, 'PUBLISHED', 'claude_reading_a0_v1')
on conflict (code) do nothing;
insert into public.reading_texts (code, cefr, text_type, situation, module_order, title_ua, title_hr, body_hr, body_ua, glossary, questions, word_count, known_ratio, order_index, status, source)
values ('RD-A0-014', 'A0', 'sign', 'shopping', 7, 'У пекарні', 'U pekari',
        'SVJEŽI KRUH
Bijeli kruh 1,20 €
Crni kruh 1,60 €
Burek sa sirom 2,50 €
Ne dirajte, molim!',
        'СВІЖИЙ ХЛІБ
Білий хліб 1,20 €
Чорний хліб 1,60 €
Бурек із сиром 2,50 €
Не чіпайте, будь ласка!',
        '[{"form": "svježi", "lemma": "svjež", "ua": "свіжий", "lesson": false, "pos": "прикметник", "gram": "називний відмінок (хто? що?), однина, ч. р."}, {"form": "kruh", "lemma": "kruh", "ua": "хліб", "lesson": true, "pos": "іменник, чоловічий рід"}, {"form": "bijeli", "lemma": "bijel", "ua": "білий", "lesson": true, "pos": "прикметник", "gram": "називний відмінок (хто? що?), однина, ч. р."}, {"form": "crni", "lemma": "crn", "ua": "чорний", "lesson": true, "pos": "прикметник", "gram": "називний відмінок (хто? що?), однина, ч. р."}, {"form": "burek", "lemma": "burek", "ua": "бурек (листковий пиріг)", "lesson": true, "pos": "іменник, чоловічий рід"}, {"form": "sa", "lemma": "s", "ua": "з (разом із)", "lesson": false, "pos": "прийменник «з»: + орудний — разом із («s obitelji»); + родовий — звідки («s Hvara», «s posla»)", "gram": "форма прийменника s перед с-, з-, ш-, ж- і «mn-»: «sa mnom», «sa psom»"}, {"form": "sirom", "lemma": "sir", "ua": "сир", "lesson": true, "pos": "іменник, чоловічий рід", "gram": "орудний відмінок (ким? чим?), однина. «sa sirom» — із сиром"}, {"form": "ne", "lemma": "ne", "ua": "ні", "lesson": true, "pos": "частка"}, {"form": "dirajte", "lemma": "dirati", "ua": "чіпати, торкатися", "lesson": false, "pos": "дієслово, недоконаний вид (що робити?)", "gram": "наказовий спосіб: ви (зробіть!). «ne dirajte» — не чіпайте"}, {"form": "molim", "lemma": "molim", "ua": "Прошу / Будь ласка / Що (ви сказали)?", "lesson": true, "pos": "частка «будь ласка; прошу»"}]'::jsonb,
        '[{"question_ua": "Скільки коштує чорний хліб?", "options": ["1,60 €", "1,20 €", "2,50 €"], "answer": "1,60 €"}, {"question_ua": "З чим бурек?", "options": ["Із сиром", "З м’ясом", "З яблуками"], "answer": "Із сиром"}, {"question_ua": "Чого не можна робити?", "options": ["Чіпати хліб руками", "Платити карткою", "Фотографувати"], "answer": "Чіпати хліб руками"}]'::jsonb, 12, 0.750, 14, 'PUBLISHED', 'claude_reading_a0_v1')
on conflict (code) do nothing;
insert into public.reading_texts (code, cefr, text_type, situation, module_order, title_ua, title_hr, body_hr, body_ua, glossary, questions, word_count, known_ratio, order_index, status, source)
values ('RD-A0-015', 'A0', 'sign', 'shopping', 8, 'На касі в супермаркеті', 'Na blagajni u supermarketu',
        'BLAGAJNA 3
Samo kartice
AKCIJA: –20 %
Vrećica 0,10 €
Hvala na kupnji!',
        'КАСА 3
Тільки картки
АКЦІЯ: –20 %
Пакет 0,10 €
Дякуємо за покупку!',
        '[{"form": "blagajna", "lemma": "blagajna", "ua": "каса", "lesson": true, "pos": "іменник, жіночий рід"}, {"form": "samo", "lemma": "samo", "ua": "тільки; лише", "lesson": false, "pos": "прислівник «тільки»"}, {"form": "kartice", "lemma": "kartica", "ua": "банківська картка", "lesson": true, "pos": "іменник, жіночий рід", "gram": "називний відмінок (хто? що?), множина"}, {"form": "akcija", "lemma": "akcija", "ua": "акція; спеціальна пропозиція", "lesson": true, "pos": "іменник, жіночий рід"}, {"form": "vrećica", "lemma": "vrećica", "ua": "пакет", "lesson": true, "pos": "іменник, жіночий рід"}, {"form": "hvala", "lemma": "hvala", "ua": "дякую", "lesson": true, "pos": "частка"}, {"form": "na", "lemma": "na", "ua": "на", "lesson": false, "pos": "прийменник: + знахідний — куди? («na posao»), + місцевий — де? («na poslu»)"}, {"form": "kupnji", "lemma": "kupnja", "ua": "покупка", "lesson": false, "pos": "іменник, жіночий рід", "gram": "місцевий відмінок (де? про кого? про що?), однина. «hvala na kupnji» — дякуємо за покупку"}]'::jsonb,
        '[{"question_ua": "Як можна платити на касі 3?", "options": ["Тільки карткою", "Тільки готівкою", "Як завгодно"], "answer": "Тільки карткою"}, {"question_ua": "Скільки коштує пакет?", "options": ["0,10 €", "1 €", "Безкоштовно"], "answer": "0,10 €"}, {"question_ua": "Яка знижка за акцією?", "options": ["20 %", "10 %", "50 %"], "answer": "20 %"}]'::jsonb, 8, 0.750, 15, 'PUBLISHED', 'claude_reading_a0_v1')
on conflict (code) do nothing;
insert into public.reading_texts (code, cefr, text_type, situation, module_order, title_ua, title_hr, body_hr, body_ua, glossary, questions, word_count, known_ratio, order_index, status, source)
values ('RD-A0-016', 'A0', 'sign', 'shopping', 8, 'Відділи магазину', 'Odjeli u trgovini',
        'Voće i povrće ←
Mlijeko i sir →
Pića →
Kruh ↑
WC i izlaz ↓',
        'Фрукти й овочі ←
Молоко й сир →
Напої →
Хліб ↑
Туалет і вихід ↓',
        '[{"form": "voće", "lemma": "voće", "ua": "фрукти", "lesson": true, "pos": "іменник, с. р. (збірне: «фрукти»)"}, {"form": "i", "lemma": "i", "ua": "і; та", "lesson": false, "pos": "сполучник"}, {"form": "povrće", "lemma": "povrće", "ua": "овочі", "lesson": true, "pos": "іменник, середній рід"}, {"form": "mlijeko", "lemma": "mlijeko", "ua": "молоко", "lesson": true, "pos": "іменник, середній рід"}, {"form": "sir", "lemma": "sir", "ua": "сир", "lesson": true, "pos": "іменник, чоловічий рід"}, {"form": "pića", "lemma": "piće", "ua": "напій", "lesson": true, "pos": "іменник, середній рід", "gram": "називний відмінок (хто? що?), множина"}, {"form": "kruh", "lemma": "kruh", "ua": "хліб", "lesson": true, "pos": "іменник, чоловічий рід"}, {"form": "wc", "lemma": "wc", "ua": "туалет", "lesson": false, "pos": "скорочення: туалет (вимовляють «ve-ce»)"}, {"form": "izlaz", "lemma": "izlaz", "ua": "вихід; виїзд", "lesson": true, "pos": "іменник, чоловічий рід"}]'::jsonb,
        '[{"question_ua": "Де фрукти й овочі?", "options": ["Ліворуч", "Праворуч", "Прямо"], "answer": "Ліворуч"}, {"question_ua": "Куди йти по хліб?", "options": ["Прямо", "Ліворуч", "Униз"], "answer": "Прямо"}, {"question_ua": "Що праворуч?", "options": ["Молоко, сир і напої", "Хліб", "Вихід"], "answer": "Молоко, сир і напої"}]'::jsonb, 11, 0.818, 16, 'PUBLISHED', 'claude_reading_a0_v1')
on conflict (code) do nothing;
insert into public.reading_texts (code, cefr, text_type, situation, module_order, title_ua, title_hr, body_hr, body_ua, glossary, questions, word_count, known_ratio, order_index, status, source)
values ('RD-A0-017', 'A0', 'sign', 'transport', 9, 'На вокзалі', 'Na kolodvoru',
        'ULAZ
IZLAZ
BLAGAJNA – karte
PERONI 1 – 5
ČEKAONICA
WC',
        'ВХІД
ВИХІД
КАСА – квитки
ПЛАТФОРМИ 1–5
ЗАЛ ОЧІКУВАННЯ
ТУАЛЕТ',
        '[{"form": "ulaz", "lemma": "ulaz", "ua": "вхід; під’їзд", "lesson": true, "pos": "іменник, чоловічий рід"}, {"form": "izlaz", "lemma": "izlaz", "ua": "вихід; виїзд", "lesson": true, "pos": "іменник, чоловічий рід"}, {"form": "blagajna", "lemma": "blagajna", "ua": "каса", "lesson": true, "pos": "іменник, жіночий рід"}, {"form": "karte", "lemma": "karta", "ua": "квиток / карта", "lesson": true, "pos": "іменник, жіночий рід", "gram": "називний відмінок (хто? що?), множина"}, {"form": "peroni", "lemma": "peron", "ua": "перон", "lesson": true, "pos": "іменник, чоловічий рід", "gram": "називний відмінок (хто? що?), множина"}, {"form": "čekaonica", "lemma": "čekaonica", "ua": "зал очікування", "lesson": true, "pos": "іменник, жіночий рід"}, {"form": "wc", "lemma": "wc", "ua": "туалет", "lesson": false, "pos": "скорочення: туалет (вимовляють «ve-ce»)"}]'::jsonb,
        '[{"question_ua": "Де купити квиток?", "options": ["Blagajna", "Čekaonica", "Peroni"], "answer": "Blagajna"}, {"question_ua": "Що означає «IZLAZ»?", "options": ["Вихід", "Вхід", "Каса"], "answer": "Вихід"}, {"question_ua": "Де можна посидіти й почекати на поїзд?", "options": ["Čekaonica", "Blagajna", "Ulaz"], "answer": "Čekaonica"}]'::jsonb, 7, 0.429, 17, 'PUBLISHED', 'claude_reading_a0_v1')
on conflict (code) do nothing;
insert into public.reading_texts (code, cefr, text_type, situation, module_order, title_ua, title_hr, body_hr, body_ua, glossary, questions, word_count, known_ratio, order_index, status, source)
values ('RD-A0-018', 'A0', 'sign', 'transport', 9, 'Дороговказ у місті', 'Putokaz u gradu',
        'Centar 1 km →
Kolodvor 500 m ←
Bolnica 2 km ↑
Muzej ←
Ljekarna 100 m →',
        'Центр 1 км →
Вокзал 500 м ←
Лікарня 2 км ↑
Музей ←
Аптека 100 м →',
        '[{"form": "centar", "lemma": "centar", "ua": "центр", "lesson": true, "pos": "іменник, чоловічий рід"}, {"form": "km", "lemma": "km", "ua": "скорочення: kilometar (кілометр)", "lesson": false, "pos": "скорочення: kilometar"}, {"form": "kolodvor", "lemma": "kolodvor", "ua": "вокзал", "lesson": true, "pos": "іменник, чоловічий рід"}, {"form": "m", "lemma": "m", "ua": "м (метр)", "lesson": false, "pos": "скорочення: metar (m² — квадратний метр)"}, {"form": "bolnica", "lemma": "bolnica", "ua": "лікарня", "lesson": true, "pos": "іменник, жіночий рід"}, {"form": "muzej", "lemma": "muzej", "ua": "музей", "lesson": true, "pos": "іменник, чоловічий рід"}, {"form": "ljekarna", "lemma": "ljekarna", "ua": "аптека", "lesson": true, "pos": "іменник, жіночий рід"}]'::jsonb,
        '[{"question_ua": "Що найближче?", "options": ["Аптека", "Вокзал", "Центр"], "answer": "Аптека"}, {"question_ua": "Куди йти до лікарні?", "options": ["Прямо", "Ліворуч", "Праворуч"], "answer": "Прямо"}, {"question_ua": "Як далеко до центру?", "options": ["1 км", "500 м", "2 км"], "answer": "1 км"}]'::jsonb, 9, 0.778, 18, 'PUBLISHED', 'claude_reading_a0_v1')
on conflict (code) do nothing;
insert into public.reading_texts (code, cefr, text_type, situation, module_order, title_ua, title_hr, body_hr, body_ua, glossary, questions, word_count, known_ratio, order_index, status, source)
values ('RD-A0-019', 'A0', 'sign', 'health', 10, 'Аптека і екстрені номери', 'Ljekarna i hitni brojevi',
        'LJEKARNA
Otvoreno 0 – 24 h
HITNA POMOĆ: 194
Policija: 192
Vatrogasci: 193
Svi hitni slučajevi: 112',
        'АПТЕКА
Відчинено цілодобово (0–24)
ШВИДКА ДОПОМОГА: 194
Поліція: 192
Пожежники: 193
Усі екстрені випадки: 112',
        '[{"form": "ljekarna", "lemma": "ljekarna", "ua": "аптека", "lesson": true, "pos": "іменник, жіночий рід"}, {"form": "otvoreno", "lemma": "otvoren", "ua": "відчинений / відкритий", "lesson": true, "pos": "прикметник", "gram": "с. р.: «Otvoreno» — відчинено"}, {"form": "h", "lemma": "h", "ua": "скорочення: sat (година)", "lesson": false, "pos": "скорочення: sat (година)"}, {"form": "hitna", "lemma": "hitna", "ua": "швидка допомога", "lesson": true, "pos": "прикметник hitan у виразі «hitna pomoć» — швидка допомога"}, {"form": "pomoć", "lemma": "pomoć", "ua": "допомога", "lesson": true, "pos": "іменник, жіночий рід"}, {"form": "policija", "lemma": "policija", "ua": "поліція", "lesson": true, "pos": "іменник, жіночий рід"}, {"form": "vatrogasci", "lemma": "vatrogasac", "ua": "пожежник", "lesson": true, "pos": "іменник, чоловічий рід", "gram": "називний відмінок (хто? що?), множина"}, {"form": "svi", "lemma": "sav", "ua": "весь; усі", "lesson": false, "pos": "займенник «весь, усі»", "gram": "називний відмінок (хто? що?), множина, ч. р."}, {"form": "hitni", "lemma": "hitan", "ua": "терміновий", "lesson": true, "pos": "прикметник", "gram": "називний відмінок (хто? що?), множина, ч. р."}, {"form": "slučajevi", "lemma": "slučaj", "ua": "випадок", "lesson": false, "pos": "іменник, чоловічий рід", "gram": "називний відмінок (хто? що?), множина"}]'::jsonb,
        '[{"question_ua": "Який номер швидкої допомоги?", "options": ["194", "192", "193"], "answer": "194"}, {"question_ua": "Коли працює аптека?", "options": ["Цілодобово", "До 20:00", "Тільки вдень"], "answer": "Цілодобово"}, {"question_ua": "Який номер для всіх екстрених випадків?", "options": ["112", "911", "102"], "answer": "112"}]'::jsonb, 10, 0.600, 19, 'PUBLISHED', 'claude_reading_a0_v1')
on conflict (code) do nothing;
insert into public.reading_texts (code, cefr, text_type, situation, module_order, title_ua, title_hr, body_hr, body_ua, glossary, questions, word_count, known_ratio, order_index, status, source)
values ('RD-A0-020', 'A0', 'sign', 'basics', 10, 'Заборони й попередження', 'Zabrane i upozorenja',
        'ZABRANJENO PUŠENJE
PAZI, PAS!
GURAJ
VUCI
NE NAGINJI SE KROZ PROZOR',
        'ПАЛИТИ ЗАБОРОНЕНО
ОБЕРЕЖНО, СОБАКА!
ВІД СЕБЕ (штовхайте)
НА СЕБЕ (тягніть)
НЕ ВИХИЛЯЙТЕСЯ З ВІКНА',
        '[{"form": "zabranjeno", "lemma": "zabranjeno", "ua": "заборонено", "lesson": true, "pos": "від прикметника zabranjen «заборонений»"}, {"form": "pušenje", "lemma": "pušenje", "ua": "куріння", "lesson": true, "pos": "іменник, середній рід"}, {"form": "pazi", "lemma": "paziti", "ua": "стежити, наглядати; остерігатися («pazi!» — обережно!)", "lesson": false, "pos": "дієслово, недоконаний вид (що робити?)", "gram": "наказовий спосіб: ти (зроби!). «Pazi, pas!» — обережно, собака"}, {"form": "pas", "lemma": "pas", "ua": "собака", "lesson": true, "pos": "іменник, чоловічий рід"}, {"form": "guraj", "lemma": "gurati", "ua": "штовхати («guraj» — від себе)", "lesson": false, "pos": "дієслово, недоконаний вид (що робити?)", "gram": "наказовий спосіб: ти (зроби!). На дверях: штовхайте від себе"}, {"form": "vuci", "lemma": "vući", "ua": "тягти («vuci» — на себе)", "lesson": false, "pos": "дієслово, недоконаний вид (що робити?)", "gram": "наказовий спосіб: ти (зроби!). На дверях: тягніть на себе"}, {"form": "ne", "lemma": "ne", "ua": "ні", "lesson": true, "pos": "частка"}, {"form": "naginji", "lemma": "naginjati se", "ua": "нахилятися, вихилятися", "lesson": false, "pos": "дієслово, недоконаний вид (що робити?)", "gram": "наказовий спосіб: ти (зроби!). «Ne naginji se!» — не вихиляйся"}, {"form": "se", "lemma": "se", "ua": "себе; -ся (частка дієслова)", "lesson": false, "pos": "зворотний займенник «себе / -ся» (коротка форма; стоїть на другому місці в реченні)"}, {"form": "kroz", "lemma": "kroz", "ua": "крізь; через", "lesson": false, "pos": "прийменник + знахідний відмінок"}, {"form": "prozor", "lemma": "prozor", "ua": "вікно", "lesson": true, "pos": "іменник, чоловічий рід"}]'::jsonb,
        '[{"question_ua": "Що означає «GURAJ» на дверях?", "options": ["Від себе (штовхайте)", "На себе (тягніть)", "Зачинено"], "answer": "Від себе (штовхайте)"}, {"question_ua": "Що означає «PAZI, PAS!»?", "options": ["Обережно, собака", "Собакам не можна", "Тут вигулюють собак"], "answer": "Обережно, собака"}, {"question_ua": "Що означає «ZABRANJENO PUŠENJE»?", "options": ["Палити заборонено", "Можна палити", "Місце для паління"], "answer": "Палити заборонено"}]'::jsonb, 11, 0.455, 20, 'PUBLISHED', 'claude_reading_a0_v1')
on conflict (code) do nothing;

-- Журнал перевірки (один запис на текст)
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'reading_text', r.id, null, r.status, 'auto_passed', 'ai', '[]'::jsonb, 'Бета: вивіски й написи A0 (§6) за запитом власника 2026-10-15 (reading_a0_v1), як уроки A0. Потрібна перевірка носієм.'
from public.reading_texts r
where r.source = 'claude_reading_a0_v1' and r.code in ('RD-A0-001', 'RD-A0-002', 'RD-A0-003', 'RD-A0-004', 'RD-A0-005', 'RD-A0-006', 'RD-A0-007', 'RD-A0-008', 'RD-A0-009', 'RD-A0-010', 'RD-A0-011', 'RD-A0-012', 'RD-A0-013', 'RD-A0-014', 'RD-A0-015', 'RD-A0-016', 'RD-A0-017', 'RD-A0-018', 'RD-A0-019', 'RD-A0-020')
  and not exists (select 1 from public.content_reviews c where c.entity_id = r.id and c.notes = 'Бета: вивіски й написи A0 (§6) за запитом власника 2026-10-15 (reading_a0_v1), як уроки A0. Потрібна перевірка носієм.');

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_total int; v_bad int;
begin
  select count(*) into v_total from public.reading_texts where source = 'claude_reading_a0_v1' and code in ('RD-A0-001', 'RD-A0-002', 'RD-A0-003', 'RD-A0-004', 'RD-A0-005', 'RD-A0-006', 'RD-A0-007', 'RD-A0-008', 'RD-A0-009', 'RD-A0-010', 'RD-A0-011', 'RD-A0-012', 'RD-A0-013', 'RD-A0-014', 'RD-A0-015', 'RD-A0-016', 'RD-A0-017', 'RD-A0-018', 'RD-A0-019', 'RD-A0-020');
  select count(*) into v_bad from public.reading_texts r where r.source = 'claude_reading_a0_v1' and r.code in ('RD-A0-001', 'RD-A0-002', 'RD-A0-003', 'RD-A0-004', 'RD-A0-005', 'RD-A0-006', 'RD-A0-007', 'RD-A0-008', 'RD-A0-009', 'RD-A0-010', 'RD-A0-011', 'RD-A0-012', 'RD-A0-013', 'RD-A0-014', 'RD-A0-015', 'RD-A0-016', 'RD-A0-017', 'RD-A0-018', 'RD-A0-019', 'RD-A0-020')
     and (jsonb_array_length(r.questions) <> 3 or r.known_ratio < 0.4
          or exists (select 1 from jsonb_array_elements(r.glossary) e
                     where e->>'pos' is null or (e->>'gram' is null and e->>'form' <> lower(e->>'lemma'))));
  if v_total < 20 then raise exception 'Текстів %, очікувалось 20', v_total; end if;
  if v_bad > 0 then raise exception '% текстів без питань, словничка чи граматичних підказок', v_bad; end if;
  raise notice 'Готово: текстів для читання A0 — %', v_total;
end $$;

commit;
