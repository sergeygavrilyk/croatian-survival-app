-- =====================================================================
-- Тексти для читання модуля A0.6 «Kućni ljubimci» · 2026-11-17 (план «Дублі й сенс уроків», PR 2б)
-- Згенеровано: python3 -B scripts/gen_a0_dupes.py (не редагуйте вручну).
--
--   * 2 тексти (RD-A0-021, RD-A0-022): табличка в парку для собак і оголошення про загублену кішку.
--   * У кожного: переклад, словничок «слово → лема → переклад» з граматичною підказкою, 3 питання, частка знайомих слів
--     з уроків A0 (known_ratio). Бета: PUBLISHED. Повторний запуск безпечний (наявні коди не перезаписуються).
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника (після 20261117_a0_dupes_1_lessons.sql).
-- Очікуване повідомлення: «Готово: 20261117_a0_dupes_2_reading.sql — текстів A0.6: 2».
-- =====================================================================

begin;

insert into public.reading_texts (code, cefr, text_type, situation, module_order, title_ua, title_hr, body_hr, body_ua, glossary, questions, word_count, known_ratio, order_index, status, source)
values ('RD-A0-021', 'A0', 'sign', 'small_talk', 6, 'Табличка в парку для собак', 'Natpis u parku za pse',
        'PARK ZA PSE
Ovdje psi smiju bez povodca.
Molimo, počistite za svojim psom!
Opasni psi – samo s brnjicom.',
        'ПАРК ДЛЯ СОБАК
Тут собакам можна без повідця.
Просимо, прибирайте за своїм собакою!
Небезпечні собаки — лише в наморднику.',
        '[{"form": "park", "lemma": "park za pse", "ua": "парк для собак", "lesson": true, "pos": "сталий вираз", "gram": "частина виразу «park za pse»"}, {"form": "za", "lemma": "za", "ua": "для; за", "lesson": false, "pos": "прийменник: + знахідний — для, за («za strance» — для іноземців)", "gram": "у «park za pse» — «для»; у «za svojim psom» — + орудний: «за (своїм собакою)»"}, {"form": "pse", "lemma": "pas", "ua": "собака; пес", "lesson": true, "pos": "іменник, чоловічий рід", "gram": "знахідний відмінок (кого? що?), множина"}, {"form": "ovdje", "lemma": "ovdje", "ua": "тут", "lesson": true, "pos": "прислівник"}, {"form": "psi", "lemma": "pas", "ua": "собака; пес", "lesson": true, "pos": "іменник, чоловічий рід", "gram": "називний відмінок (хто? що?), множина"}, {"form": "smiju", "lemma": "smjeti", "ua": "можна, мати дозвіл", "lesson": true, "pos": "дієслово, недоконаний вид (що робити?)", "gram": "теперішній час: вони. «smiju» — їм можна"}, {"form": "bez", "lemma": "bez", "ua": "без", "lesson": false, "pos": "прийменник + родовий відмінок"}, {"form": "povodca", "lemma": "povodac", "ua": "повідець", "lesson": true, "pos": "іменник, чоловічий рід", "gram": "родовий відмінок (кого? чого?), однина (після «bez»)"}, {"form": "molimo", "lemma": "molimo", "ua": "просимо", "lesson": false, "pos": "сталий вираз «просимо»", "gram": "теперішній час: ми (від moliti). На табличках — «просимо»"}, {"form": "počistite", "lemma": "počistiti", "ua": "прибрати", "lesson": true, "pos": "дієслово, доконаний вид (що зробити?)", "gram": "наказовий спосіб: ви (зробіть!)"}, {"form": "svojim", "lemma": "svoj", "ua": "свій", "lesson": true, "pos": "присвійний займенник «свій»", "gram": "орудний відмінок (ким? чим?), однина, ч. р."}, {"form": "psom", "lemma": "pas", "ua": "собака; пес", "lesson": true, "pos": "іменник, чоловічий рід", "gram": "орудний відмінок (ким? чим?), однина: «za psom» — за собакою"}, {"form": "opasni", "lemma": "opasan", "ua": "небезпечний", "lesson": true, "pos": "прикметник", "gram": "називний відмінок (хто? що?), множина, ч. р."}, {"form": "samo", "lemma": "samo", "ua": "тільки; лише", "lesson": true, "pos": "прислівник «тільки»"}, {"form": "s", "lemma": "s", "ua": "з (разом із)", "lesson": false, "pos": "прийменник «з»: + орудний — разом із («s obitelji»); + родовий — звідки («s Hvara», «s posla»)"}, {"form": "brnjicom", "lemma": "brnjica", "ua": "намордник", "lesson": true, "pos": "іменник, жіночий рід", "gram": "орудний відмінок (ким? чим?), однина: «s brnjicom» — у наморднику"}]'::jsonb,
        '[{"question_ua": "Чи можна тут відпустити собаку з повідця?", "options": ["Так", "Ні", "Лише вранці"], "answer": "Так"}, {"question_ua": "Що треба робити після свого собаки?", "options": ["Прибирати за ним", "Платити за вхід", "Чекати біля входу"], "answer": "Прибирати за ним"}, {"question_ua": "Яким собакам треба бути в наморднику?", "options": ["Небезпечним", "Усім", "Маленьким"], "answer": "Небезпечним"}]'::jsonb, 18, 0.889, 21, 'PUBLISHED', 'claude_curriculum_a0_dupes')
on conflict (code) do nothing;

insert into public.reading_texts (code, cefr, text_type, situation, module_order, title_ua, title_hr, body_hr, body_ua, glossary, questions, word_count, known_ratio, order_index, status, source)
values ('RD-A0-022', 'A0', 'notice', 'housing', 6, 'Оголошення: загубилася кішка', 'Oglas: izgubljena mačka',
        'IZGUBLJENA MAČKA
Zove se Mica. Siva je i prugasta.
Pobjegla je u petak s balkona.
Ako je vidite, javite se!
Nagrada!',
        'ЗАГУБИЛАСЯ КІШКА
Її звати Міца. Вона сіра й смугаста.
Втекла в п’ятницю з балкона.
Якщо побачите її, дайте знати!
Винагорода!',
        '[{"form": "izgubljena", "lemma": "izgubljen", "ua": "загублений", "lesson": true, "pos": "прикметник", "gram": "називний відмінок (хто? що?), однина, ж. р."}, {"form": "mačka", "lemma": "mačka", "ua": "кішка", "lesson": true, "pos": "іменник, жіночий рід"}, {"form": "zove", "lemma": "zovem se", "ua": "мене звати", "lesson": true, "pos": "сталий вираз «мене звати» (від zvati se)", "gram": "теперішній час: вона. «zove se» — її звати"}, {"form": "se", "lemma": "se", "ua": "себе; -ся (частка дієслова)", "lesson": false, "pos": "зворотний займенник «себе / -ся» (коротка форма; стоїть на другому місці в реченні)"}, {"form": "mica", "lemma": "Mica", "ua": "Міца (кличка кішки)", "lesson": false, "pos": "ім’я (кличка кішки)"}, {"form": "siva", "lemma": "siv", "ua": "сірий", "lesson": true, "pos": "прикметник", "gram": "називний відмінок (хто? що?), однина, ж. р."}, {"form": "je", "lemma": "biti", "ua": "бути; є", "lesson": true, "pos": "дієслово «бути» (недоконаний вид); короткі форми sam, si, je, smo, ste, su", "gram": "теперішній час: він / вона / воно. У «pobjegla je» — допоміжне дієслово минулого часу; у «ako je vidite» — «її» (знахідний від ona)"}, {"form": "i", "lemma": "i", "ua": "і; та", "lesson": false, "pos": "сполучник"}, {"form": "prugasta", "lemma": "prugast", "ua": "смугастий", "lesson": true, "pos": "прикметник", "gram": "називний відмінок (хто? що?), однина, ж. р."}, {"form": "pobjegla", "lemma": "pobjeći", "ua": "втекти", "lesson": true, "pos": "дієслово, доконаний вид (що зробити?)", "gram": "минулий час, ж. р.: «pobjegla je» — втекла"}, {"form": "u", "lemma": "u", "ua": "у; в", "lesson": false, "pos": "прийменник: + знахідний — куди? («u školu»), + місцевий — де? («u Zagrebu»)", "gram": "у «u petak» — коли? (знахідний)"}, {"form": "petak", "lemma": "petak", "ua": "п’ятниця", "lesson": true, "pos": "іменник, чоловічий рід", "gram": "знахідний відмінок: «u petak» — у п’ятницю"}, {"form": "s", "lemma": "s", "ua": "з (звідки)", "lesson": false, "pos": "прийменник «з»: + орудний — разом із («s obitelji»); + родовий — звідки («s Hvara», «s posla»)"}, {"form": "balkona", "lemma": "balkon", "ua": "балкон", "lesson": true, "pos": "іменник, чоловічий рід", "gram": "родовий відмінок (кого? чого?), однина: «s balkona» — з балкона"}, {"form": "ako", "lemma": "ako", "ua": "якщо", "lesson": true, "pos": "сполучник"}, {"form": "vidite", "lemma": "vidjeti", "ua": "бачити", "lesson": true, "pos": "дієслово, доконаний і недоконаний вид", "gram": "теперішній час: ви"}, {"form": "javite", "lemma": "javiti se", "ua": "дати знати; озватися", "lesson": true, "pos": "дієслово, доконаний вид (що зробити?)", "gram": "наказовий спосіб: ви (зробіть!). «Javite se!» — дайте знати, озвіться"}, {"form": "nagrada", "lemma": "nagrada", "ua": "нагорода; винагорода", "lesson": false, "pos": "іменник, жіночий рід"}]'::jsonb,
        '[{"question_ua": "Яка кішка загубилася?", "options": ["Сіра й смугаста", "Чорна", "Біла з плямами"], "answer": "Сіра й смугаста"}, {"question_ua": "Коли вона втекла?", "options": ["У п’ятницю", "У неділю", "Сьогодні вранці"], "answer": "У п’ятницю"}, {"question_ua": "Що отримає той, хто знайде кішку?", "options": ["Винагороду", "Кошеня", "Квиток у кіно"], "answer": "Винагороду"}]'::jsonb, 21, 0.857, 22, 'PUBLISHED', 'claude_curriculum_a0_dupes')
on conflict (code) do nothing;

-- Журнал перевірки (один запис на текст)
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'reading_text', r.id, null, r.status, 'auto_passed', 'ai', '[]'::jsonb, 'Бета: тексти для читання модуля A0.6 «Kućni ljubimci» (план «Дублі й сенс уроків», PR 2б, 2026-11-17). Знайомі слова — уроки A0. Потрібна перевірка носієм.'
  from public.reading_texts r
 where r.source = 'claude_curriculum_a0_dupes' and r.code in ('RD-A0-021', 'RD-A0-022')
   and not exists (select 1 from public.content_reviews c where c.entity_id = r.id and c.notes = 'Бета: тексти для читання модуля A0.6 «Kućni ljubimci» (план «Дублі й сенс уроків», PR 2б, 2026-11-17). Знайомі слова — уроки A0. Потрібна перевірка носієм.');

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_total int; v_bad int;
begin
  select count(*) into v_total from public.reading_texts where cefr = 'A0' and module_order = 6 and status = 'PUBLISHED' and code in ('RD-A0-021', 'RD-A0-022');
  select count(*) into v_bad from public.reading_texts r where r.code in ('RD-A0-021', 'RD-A0-022')
     and (jsonb_array_length(r.questions) <> 3 or r.known_ratio < 0.8
          or exists (select 1 from jsonb_array_elements(r.glossary) e
                     where e->>'pos' is null or (e->>'gram' is null and e->>'form' <> lower(e->>'lemma'))));
  if v_total <> 2 then raise exception 'Текстів A0.6: % (очікувалось 2)', v_total; end if;
  if v_bad > 0 then raise exception '% текстів без питань, словничка чи граматичних підказок', v_bad; end if;
  raise notice 'Готово: 20261117_a0_dupes_2_reading.sql — текстів A0.6: %', v_total;
end $$;

commit;
