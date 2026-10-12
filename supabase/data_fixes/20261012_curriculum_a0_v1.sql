-- =====================================================================
-- Програма A0 (повна) + каркас A1–B2 · curriculum_a0_v1 · 2026-10-12
-- Згенеровано: python3 scripts/gen_curriculum_a0.py (не редагуйте вручну).
--
--   * A0: 10 модулів, 30 уроків (урок 1 вже був), 11 граматичних тем,
--     у кожному новому уроці — діалог, 4–12 слів, 3 вправи. Статус PUBLISHED:
--     бета за рішенням власника 2026-10-12 (§64 — виняток, записаний у PROJECT_STATE).
--   * A1–B2: 42 модулів і 43 граматичних тем — DRAFT (без уроків).
--   * Наявні дані НЕ змінюються і НЕ видаляються. Повторний запуск безпечний.
--   * Потрібна міграція M10 (20261012240000_m10_lesson_order.sql).
--   * Нових уроків у цьому файлі: 29.
-- =====================================================================

begin;

do $$
begin
  if not exists (select 1 from information_schema.columns
                 where table_schema = 'public' and table_name = 'lessons' and column_name = 'order_index') then
    raise exception 'Спершу запустіть міграцію M10 (20261012240000_m10_lesson_order.sql)';
  end if;
  if not exists (select 1 from public.modules where level_code = 'A0' and order_index = 1) then
    raise exception 'Немає модуля A0.1 — дані не схожі на робочу базу';
  end if;
end $$;

-- 1. Нові слова (яких ще немає у словнику)
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('doviđenja', 'dovidenja', 'hr', 'interjection', 'A0', 'до побачення', 'formulaic', '{}'::jsonb, '["Hvala, doviđenja!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_v1')
on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
values ('upomoć', 'upomoc', 'hr', 'interjection', 'A0', 'допоможіть!; на допомогу!', 'formulaic', '{}'::jsonb, '["Upomoć! Zovite hitnu!"]'::jsonb, 'PUBLISHED', 'claude_curriculum_v1')
on conflict do nothing;

-- 2. Граматика A0 (PUBLISHED, з правилами)
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select 'c4bea760-d6db-5b5c-a71b-773f8bd2b84e', 'A0', 'Ввічливість: ti і Vi', 'Persiranje: ti i Vi', 'Коли казати «ti», а коли «Vi», і універсальне слово «molim».', 'PUBLISHED'
where not exists (select 1 from public.grammar_topics where cefr = 'A0' and title_ua = 'Ввічливість: ti і Vi');
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'aea765bd-2620-5cc1-bcd1-546c57e8c46c', 'c4bea760-d6db-5b5c-a71b-773f8bd2b84e', 'Ti — своїм, Vi — незнайомим', 'До друзів, родини й дітей звертаються на «ti». До незнайомих, старших, у магазині, банку чи установі — на «Vi».', 'Kako si? · Kako ste?', '[{"hr": "Kako si, Marko?", "ua": "Як ти, Марку?"}, {"hr": "Kako ste, gospođo?", "ua": "Як ви, пані?"}, {"hr": "Izvoli! / Izvolite!", "ua": "Прошу! (тобі / вам)"}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = 'c4bea760-d6db-5b5c-a71b-773f8bd2b84e')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '9babe3b9-1a62-5069-8e15-4a5ad46818d4', 'c4bea760-d6db-5b5c-a71b-773f8bd2b84e', 'Molim — на всі випадки', '«Molim» означає і «будь ласка», і «прошу» у відповідь на «дякую», і «перепрошую?», коли ви не почули.', 'Molim. · Molim? · Molim vas…', '[{"hr": "Hvala! — Molim.", "ua": "Дякую! — Прошу."}, {"hr": "Molim? Ne razumijem.", "ua": "Перепрошую? Не розумію."}, {"hr": "Molim vas, jednu kavu.", "ua": "Будь ласка, одну каву."}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = 'c4bea760-d6db-5b5c-a71b-773f8bd2b84e')
on conflict (id) do nothing;
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', 'c4bea760-d6db-5b5c-a71b-773f8bd2b84e', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.'
where exists (select 1 from public.grammar_topics where id = 'c4bea760-d6db-5b5c-a71b-773f8bd2b84e')
  and not exists (select 1 from public.content_reviews where entity_id = 'c4bea760-d6db-5b5c-a71b-773f8bd2b84e' and notes = 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '21f2008f-cb5c-5f9e-9562-5a1e7e5b2a2e', 'A0', 'Вимова: хорватські літери', 'Izgovor: hrvatska slova', 'Хорватська пишеться так, як вимовляється. Головне — кілька особливих літер.', 'PUBLISHED'
where not exists (select 1 from public.grammar_topics where cefr = 'A0' and title_ua = 'Вимова: хорватські літери');
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'c25483fb-06d0-5aa8-9bd6-3ca6bf03a19f', '21f2008f-cb5c-5f9e-9562-5a1e7e5b2a2e', 'Одна літера — один звук', 'Слова читаються так, як написані. Наголос на письмі не позначається.', 'Zagreb · Hrvatska · dobro', '[{"hr": "Zagreb", "ua": "Загреб"}, {"hr": "Hrvatska", "ua": "Хорватія"}, {"hr": "dobro", "ua": "добре"}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = '21f2008f-cb5c-5f9e-9562-5a1e7e5b2a2e')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'c9172330-4e33-5252-9c19-43bc10a169d8', '21f2008f-cb5c-5f9e-9562-5a1e7e5b2a2e', 'Č і Ć', '«Č» — тверде «ч», як в українському «час». «Ć» — м’якше, ближче до «чь».', 'č = ч · ć ≈ чь', '[{"hr": "čaj", "ua": "чай"}, {"hr": "kuća", "ua": "дім"}, {"hr": "noć", "ua": "ніч"}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = '21f2008f-cb5c-5f9e-9562-5a1e7e5b2a2e')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '30b85783-ea15-50e2-9b76-da7ffd0c53c2', '21f2008f-cb5c-5f9e-9562-5a1e7e5b2a2e', 'Š, Ž, Đ, Dž, Lj, Nj', '«Š» = ш, «ž» = ж, «đ» ≈ дь, «dž» = дж, «lj» = ль, «nj» = нь.', 'š · ž · đ · dž · lj · nj', '[{"hr": "žena", "ua": "жінка"}, {"hr": "ljubav", "ua": "любов"}, {"hr": "konj", "ua": "кінь"}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = '21f2008f-cb5c-5f9e-9562-5a1e7e5b2a2e')
on conflict (id) do nothing;
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', '21f2008f-cb5c-5f9e-9562-5a1e7e5b2a2e', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.'
where exists (select 1 from public.grammar_topics where id = '21f2008f-cb5c-5f9e-9562-5a1e7e5b2a2e')
  and not exists (select 1 from public.content_reviews where entity_id = '21f2008f-cb5c-5f9e-9562-5a1e7e5b2a2e' and notes = 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '9c401616-b70c-5d88-9275-f2b7a9f3bfc3', 'A0', 'Заперечення і питання з «biti»', 'Niječni i upitni oblici glagola biti', 'Як сказати «я не…» і як запитати «ти…?».', 'PUBLISHED'
where not exists (select 1 from public.grammar_topics where cefr = 'A0' and title_ua = 'Заперечення і питання з «biti»');
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '63ba2479-8d14-5921-a5cf-a6ecf53681c1', '9c401616-b70c-5d88-9275-f2b7a9f3bfc3', 'Заперечення: nisam, nisi, nije…', 'Заперечну форму «бути» пишуть разом: ne + sam = nisam.', 'nisam · nisi · nije · nismo · niste · nisu', '[{"hr": "Nisam Hrvat.", "ua": "Я не хорват."}, {"hr": "Ona nije ovdje.", "ua": "Її тут немає."}, {"hr": "Nismo umorni.", "ua": "Ми не втомлені."}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = '9c401616-b70c-5d88-9275-f2b7a9f3bfc3')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '4430bd22-2088-55b0-9a6b-62caf7235145', '9c401616-b70c-5d88-9275-f2b7a9f3bfc3', 'Питання з «li»', 'Питання починається з повної форми «бути» і частки «li».', 'Jesi li…? · Je li…? · Jeste li…?', '[{"hr": "Jesi li dobro?", "ua": "Ти в порядку?"}, {"hr": "Je li to tvoj brat?", "ua": "Це твій брат?"}, {"hr": "Jeste li iz Ukrajine?", "ua": "Ви з України?"}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = '9c401616-b70c-5d88-9275-f2b7a9f3bfc3')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '85aaedd8-2c4b-5850-86ab-769f40ae9aa5', '9c401616-b70c-5d88-9275-f2b7a9f3bfc3', 'Коротка відповідь', 'На питання з «li» коротко відповідають повною формою: «Jesam» — так, «Nisam» — ні.', 'Jesam. · Nisam.', '[{"hr": "Jesi li umoran? — Jesam.", "ua": "Ти втомлений? — Так."}, {"hr": "Jeste li Hrvat? — Nisam.", "ua": "Ви хорват? — Ні."}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = '9c401616-b70c-5d88-9275-f2b7a9f3bfc3')
on conflict (id) do nothing;
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', '9c401616-b70c-5d88-9275-f2b7a9f3bfc3', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.'
where exists (select 1 from public.grammar_topics where id = '9c401616-b70c-5d88-9275-f2b7a9f3bfc3')
  and not exists (select 1 from public.content_reviews where entity_id = '9c401616-b70c-5d88-9275-f2b7a9f3bfc3' and notes = 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '122dde87-f462-5170-99bf-a6e3efeefbe3', 'A0', 'Числа 0–100', 'Brojevi od 0 do 100', 'Числа для цін, віку й номерів телефону.', 'PUBLISHED'
where not exists (select 1 from public.grammar_topics where cefr = 'A0' and title_ua = 'Числа 0–100');
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'eb2a40af-7614-52a9-b4dd-9cf42c4166c2', '122dde87-f462-5170-99bf-a6e3efeefbe3', '0–10', 'Основа для всіх інших чисел.', 'nula, jedan, dva, tri, četiri, pet, šest, sedam, osam, devet, deset', '[{"hr": "Moj broj je nula devet jedan.", "ua": "Мій номер — нуль дев’ять один."}, {"hr": "Imam tri sestre.", "ua": "У мене три сестри."}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = '122dde87-f462-5170-99bf-a6e3efeefbe3')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '948565ec-bbf7-52e6-8d02-a9a1e375563a', '122dde87-f462-5170-99bf-a6e3efeefbe3', '11–19: «-naest»', 'Числа від 11 до 19 закінчуються на «-naest».', 'jedanaest · dvanaest · petnaest · devetnaest', '[{"hr": "jedanaest", "ua": "одинадцять"}, {"hr": "dvanaest", "ua": "дванадцять"}, {"hr": "petnaest", "ua": "п’ятнадцять"}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = '122dde87-f462-5170-99bf-a6e3efeefbe3')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '60c3597b-c601-5a12-a440-eb7ce799fb29', '122dde87-f462-5170-99bf-a6e3efeefbe3', 'Десятки й сто', 'Десятки: dvadeset, trideset, četrdeset, pedeset, šezdeset, sedamdeset, osamdeset, devedeset, sto. Складені числа: dvadeset jedan або dvadeset i jedan.', 'trideset pet = 35', '[{"hr": "trideset pet", "ua": "тридцять п’ять"}, {"hr": "pedeset", "ua": "п’ятдесят"}, {"hr": "sto", "ua": "сто"}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = '122dde87-f462-5170-99bf-a6e3efeefbe3')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '7060165c-d62c-59b4-a8e3-d319f65a92b3', '122dde87-f462-5170-99bf-a6e3efeefbe3', 'Число + іменник', 'Після 1 — називний відмінок, після 2, 3, 4 — родовий однини, після 5 і більше — родовий множини.', 'jedan euro · dva eura · pet eura', '[{"hr": "jedan euro", "ua": "один євро"}, {"hr": "tri kave", "ua": "три кави"}, {"hr": "deset godina", "ua": "десять років"}]'::jsonb, 4
where exists (select 1 from public.grammar_topics where id = '122dde87-f462-5170-99bf-a6e3efeefbe3')
on conflict (id) do nothing;
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', '122dde87-f462-5170-99bf-a6e3efeefbe3', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.'
where exists (select 1 from public.grammar_topics where id = '122dde87-f462-5170-99bf-a6e3efeefbe3')
  and not exists (select 1 from public.content_reviews where entity_id = '122dde87-f462-5170-99bf-a6e3efeefbe3' and notes = 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '89c1493b-4ec4-5d52-8834-b1c027e2a6a5', 'A0', 'Час: дні, години, місяці', 'Vrijeme: dani, sati, mjeseci', 'Коли? О котрій? У який день і місяць?', 'PUBLISHED'
where not exists (select 1 from public.grammar_topics where cefr = 'A0' and title_ua = 'Час: дні, години, місяці');
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '44b96997-b586-555d-996e-3a58d8c1d242', '89c1493b-4ec4-5d52-8834-b1c027e2a6a5', 'У який день? — u + день', 'Із днями тижня вживається «u», а день стоїть у знахідному відмінку: srijeda → u srijedu.', 'u ponedjeljak · u srijedu · u nedjelju', '[{"hr": "U subotu radim.", "ua": "У суботу я працюю."}, {"hr": "U nedjelju idemo na more.", "ua": "У неділю ми їдемо на море."}, {"hr": "Vidimo se u petak!", "ua": "Побачимося в п’ятницю!"}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = '89c1493b-4ec4-5d52-8834-b1c027e2a6a5')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '348e8f88-7a85-5462-8b7a-c24842485a75', '89c1493b-4ec4-5d52-8834-b1c027e2a6a5', 'Учора, сьогодні, завтра', 'Слова без прийменників.', 'prekjučer · jučer · danas · sutra · prekosutra', '[{"hr": "Danas je utorak.", "ua": "Сьогодні вівторок."}, {"hr": "Sutra radim.", "ua": "Завтра я працюю."}, {"hr": "Jučer je bila nedjelja.", "ua": "Учора була неділя."}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = '89c1493b-4ec4-5d52-8834-b1c027e2a6a5')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '040aa321-65f5-5cd2-b798-570c8278ef91', '89c1493b-4ec4-5d52-8834-b1c027e2a6a5', 'Котра година? О котрій?', 'Відповідь: число + sat / sata / sati. «О котрій» — u + число.', 'jedan sat · tri sata · pet sati · u osam sati', '[{"hr": "Koliko je sati? — Deset sati.", "ua": "Котра година? — Десята."}, {"hr": "Autobus ide u devet sati.", "ua": "Автобус їде о дев’ятій."}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = '89c1493b-4ec4-5d52-8834-b1c027e2a6a5')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'd80ab771-4f09-5dd5-99cc-f5dde243aade', '89c1493b-4ec4-5d52-8834-b1c027e2a6a5', 'У якому місяці? — u + місцевий відмінок', 'Місяці мають хорватські назви. «У січні» — u siječnju.', 'u siječnju · u srpnju · u prosincu', '[{"hr": "Rođendan mi je u svibnju.", "ua": "Мій день народження в травні."}, {"hr": "U kolovozu idemo na more.", "ua": "У серпні ми їдемо на море."}, {"hr": "U prosincu je hladno.", "ua": "У грудні холодно."}]'::jsonb, 4
where exists (select 1 from public.grammar_topics where id = '89c1493b-4ec4-5d52-8834-b1c027e2a6a5')
on conflict (id) do nothing;
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', '89c1493b-4ec4-5d52-8834-b1c027e2a6a5', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.'
where exists (select 1 from public.grammar_topics where id = '89c1493b-4ec4-5d52-8834-b1c027e2a6a5')
  and not exists (select 1 from public.content_reviews where entity_id = '89c1493b-4ec4-5d52-8834-b1c027e2a6a5' and notes = 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select 'bbe632d0-d072-59ae-aa3c-235fba1a9537', 'A0', 'Рід, множина і «мій / моя / моє»', 'Rod, množina i posvojne zamjenice', 'Три роди іменників, як утворити множину і як сказати «мій».', 'PUBLISHED'
where not exists (select 1 from public.grammar_topics where cefr = 'A0' and title_ua = 'Рід, множина і «мій / моя / моє»');
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'cafe1b34-b624-53d2-a4f3-79ed908181ac', 'bbe632d0-d072-59ae-aa3c-235fba1a9537', 'Три роди', 'Чоловічий рід зазвичай закінчується на приголосний, жіночий — на -a, середній — на -o або -e.', 'brat (ч.) · sestra (ж.) · selo, more (с.)', '[{"hr": "brat", "ua": "брат (ч. р.)"}, {"hr": "sestra", "ua": "сестра (ж. р.)"}, {"hr": "more", "ua": "море (с. р.)"}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = 'bbe632d0-d072-59ae-aa3c-235fba1a9537')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'd13a4cd8-38ef-50c7-8b11-889c823add06', 'bbe632d0-d072-59ae-aa3c-235fba1a9537', 'Мій / моя / моє', 'Присвійний займенник має той самий рід, що й іменник. Так само tvoj / tvoja / tvoje.', 'moj brat · moja sestra · moje dijete', '[{"hr": "Ovo je moj brat.", "ua": "Це мій брат."}, {"hr": "Ovo je moja sestra.", "ua": "Це моя сестра."}, {"hr": "Ovo je moje dijete.", "ua": "Це моя дитина."}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = 'bbe632d0-d072-59ae-aa3c-235fba1a9537')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'e493ed58-f9c4-51d0-b87b-706e910fa6b6', 'bbe632d0-d072-59ae-aa3c-235fba1a9537', 'Множина', 'Чоловічий рід: -i, жіночий: -e, середній: -a. Є винятки: brat → braća, dijete → djeca.', 'prijatelj → prijatelji · kuća → kuće · selo → sela', '[{"hr": "Moji prijatelji žive u Zagrebu.", "ua": "Мої друзі живуть у Загребі."}, {"hr": "Ove kuće su nove.", "ua": "Ці будинки нові."}, {"hr": "Djeca su u školi.", "ua": "Діти в школі."}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = 'bbe632d0-d072-59ae-aa3c-235fba1a9537')
on conflict (id) do nothing;
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', 'bbe632d0-d072-59ae-aa3c-235fba1a9537', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.'
where exists (select 1 from public.grammar_topics where id = 'bbe632d0-d072-59ae-aa3c-235fba1a9537')
  and not exists (select 1 from public.content_reviews where entity_id = 'bbe632d0-d072-59ae-aa3c-235fba1a9537' and notes = 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '4386347b-377b-5dd2-bd18-9b5f8e858fde', 'A0', 'Де? Прийменники місця', 'Gdje? Prijedlozi mjesta', 'Як сказати, де щось лежить або де хтось є.', 'PUBLISHED'
where not exists (select 1 from public.grammar_topics where cefr = 'A0' and title_ua = 'Де? Прийменники місця');
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '7128626e-a2ec-582a-8835-1635f5d05336', '4386347b-377b-5dd2-bd18-9b5f8e858fde', 'U і na + місцевий відмінок', '«U» — всередині (u sobi), «na» — на поверхні (na stolu). Іменник змінює закінчення.', 'u sobi · u torbi · na stolu', '[{"hr": "Ključevi su na stolu.", "ua": "Ключі на столі."}, {"hr": "Mačka je u kuhinji.", "ua": "Кішка на кухні."}, {"hr": "Torba je u sobi.", "ua": "Сумка в кімнаті."}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = '4386347b-377b-5dd2-bd18-9b5f8e858fde')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'abd9f14d-7387-5747-8277-d01cd6559f8c', '4386347b-377b-5dd2-bd18-9b5f8e858fde', 'Ispod, iznad, pored + родовий відмінок', 'Після цих прийменників іменник стоїть у родовому відмінку.', 'ispod stola · iznad kreveta · pored prozora', '[{"hr": "Pas je ispod stola.", "ua": "Собака під столом."}, {"hr": "Slika je iznad kreveta.", "ua": "Картина над ліжком."}, {"hr": "Stol je pored prozora.", "ua": "Стіл біля вікна."}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = '4386347b-377b-5dd2-bd18-9b5f8e858fde')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'f0ca4ed7-e428-5cb0-9d01-de5eab4ea7e4', '4386347b-377b-5dd2-bd18-9b5f8e858fde', 'Ліворуч, праворуч, прямо', 'Ці слова не змінюються.', 'lijevo · desno · ravno', '[{"hr": "Kupaonica je lijevo.", "ua": "Ванна ліворуч."}, {"hr": "Kuhinja je desno.", "ua": "Кухня праворуч."}, {"hr": "Idite ravno.", "ua": "Ідіть прямо."}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = '4386347b-377b-5dd2-bd18-9b5f8e858fde')
on conflict (id) do nothing;
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', '4386347b-377b-5dd2-bd18-9b5f8e858fde', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.'
where exists (select 1 from public.grammar_topics where id = '4386347b-377b-5dd2-bd18-9b5f8e858fde')
  and not exists (select 1 from public.content_reviews where entity_id = '4386347b-377b-5dd2-bd18-9b5f8e858fde' and notes = 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '017cf20e-e27a-5cab-bad3-89d61d6933ae', 'A0', 'Дієслово «imati» (мати)', 'Glagol imati', 'Як сказати «у мене є» і «у мене немає».', 'PUBLISHED'
where not exists (select 1 from public.grammar_topics where cefr = 'A0' and title_ua = 'Дієслово «imati» (мати)');
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '4c90eab4-c909-588b-b36d-b5b042b0f84c', '017cf20e-e27a-5cab-bad3-89d61d6933ae', 'Imam, imaš, ima…', 'Хорватською кажуть «я маю», а не «у мене є».', 'imam · imaš · ima · imamo · imate · imaju', '[{"hr": "Imam kruh.", "ua": "У мене є хліб."}, {"hr": "Imate li vodu?", "ua": "У вас є вода?"}, {"hr": "Oni imaju djecu.", "ua": "У них є діти."}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = '017cf20e-e27a-5cab-bad3-89d61d6933ae')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '3fa28f51-911f-5626-9f0c-772b3c603c39', '017cf20e-e27a-5cab-bad3-89d61d6933ae', 'Nemam, nemaš, nema…', 'Заперечення пишеться разом: ne + imam = nemam. «Nema» також означає «немає» взагалі.', 'nemam · nemaš · nema', '[{"hr": "Nemam vremena.", "ua": "У мене немає часу."}, {"hr": "Nema problema.", "ua": "Немає проблем."}, {"hr": "Nema mlijeka.", "ua": "Немає молока."}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = '017cf20e-e27a-5cab-bad3-89d61d6933ae')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '99b58ad9-af9e-5d9c-a67a-527391f2ac46', '017cf20e-e27a-5cab-bad3-89d61d6933ae', 'Питання: дієслово + li', 'Частка «li» стоїть одразу після дієслова.', 'Imate li…? · Imaš li…?', '[{"hr": "Imate li jelovnik?", "ua": "У вас є меню?"}, {"hr": "Imaš li vremena?", "ua": "У тебе є час?"}, {"hr": "Ima li kruha?", "ua": "Хліб є?"}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = '017cf20e-e27a-5cab-bad3-89d61d6933ae')
on conflict (id) do nothing;
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', '017cf20e-e27a-5cab-bad3-89d61d6933ae', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.'
where exists (select 1 from public.grammar_topics where id = '017cf20e-e27a-5cab-bad3-89d61d6933ae')
  and not exists (select 1 from public.content_reviews where entity_id = '017cf20e-e27a-5cab-bad3-89d61d6933ae' and notes = 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '70b7a2a1-a3ab-5787-b4e0-1f943f4028b6', 'A0', 'Цей, той, он той: ovaj, taj, onaj', 'Pokazne zamjenice: ovaj, taj, onaj', 'У хорватській три вказівні займенники — за відстанню.', 'PUBLISHED'
where not exists (select 1 from public.grammar_topics where cefr = 'A0' and title_ua = 'Цей, той, он той: ovaj, taj, onaj');
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '095ef952-9585-52a9-8149-2ef9adcd234b', '70b7a2a1-a3ab-5787-b4e0-1f943f4028b6', 'Ovaj / ova / ovo — біля мене', 'Те, що поруч із тим, хто говорить.', 'ovaj kruh · ova majica · ovo jaje', '[{"hr": "Ovaj kruh je svjež.", "ua": "Цей хліб свіжий."}, {"hr": "Ova majica je skupa.", "ua": "Ця футболка дорога."}, {"hr": "Ovo je moj stan.", "ua": "Це моя квартира."}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = '70b7a2a1-a3ab-5787-b4e0-1f943f4028b6')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '184e70ae-1679-55d1-9742-e96d00553a01', '70b7a2a1-a3ab-5787-b4e0-1f943f4028b6', 'Taj / ta / to — біля співрозмовника', 'Те, що поруч із тим, до кого звертаєтесь, або про що щойно говорили.', 'taj sir · ta torba · to', '[{"hr": "Taj sir je dobar.", "ua": "Цей (твій) сир хороший."}, {"hr": "Ta torba je lijepa.", "ua": "Ця (твоя) сумка гарна."}, {"hr": "To je točno.", "ua": "Це правда."}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = '70b7a2a1-a3ab-5787-b4e0-1f943f4028b6')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '985b4b50-23e9-5d74-a1f2-15fce91fbb84', '70b7a2a1-a3ab-5787-b4e0-1f943f4028b6', 'Onaj / ona / ono — далеко', 'Те, що далеко від обох.', 'onaj čovjek · ona kuća · ono', '[{"hr": "Onaj čovjek je moj susjed.", "ua": "Он той чоловік — мій сусід."}, {"hr": "Ona kuća je stara.", "ua": "Он той будинок старий."}, {"hr": "Što je ono tamo?", "ua": "Що он там?"}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = '70b7a2a1-a3ab-5787-b4e0-1f943f4028b6')
on conflict (id) do nothing;
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', '70b7a2a1-a3ab-5787-b4e0-1f943f4028b6', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.'
where exists (select 1 from public.grammar_topics where id = '70b7a2a1-a3ab-5787-b4e0-1f943f4028b6')
  and not exists (select 1 from public.content_reviews where entity_id = '70b7a2a1-a3ab-5787-b4e0-1f943f4028b6' and notes = 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '87d9e203-7b7e-5937-a36b-46e64d4ab14a', 'A0', 'Прикметники: узгодження з іменником', 'Pridjevi: slaganje s imenicom', 'Прикметник має той самий рід і число, що й іменник.', 'PUBLISHED'
where not exists (select 1 from public.grammar_topics where cefr = 'A0' and title_ua = 'Прикметники: узгодження з іменником');
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'a22d8af9-1ada-5bd3-a8f7-f9968a6c9184', '87d9e203-7b7e-5937-a36b-46e64d4ab14a', 'Перед іменником: -i / -a / -o', 'Перед іменником чоловічий рід зазвичай має закінчення -i.', 'novi muzej · nova crkva · novo kino', '[{"hr": "Ovo je novi stan.", "ua": "Це нова квартира."}, {"hr": "Ovo je nova crkva.", "ua": "Це нова церква."}, {"hr": "Ovo je novo kino.", "ua": "Це новий кінотеатр."}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = '87d9e203-7b7e-5937-a36b-46e64d4ab14a')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select 'ed0a659f-91ab-50b9-a271-393237929c9b', '87d9e203-7b7e-5937-a36b-46e64d4ab14a', 'Після «je»: коротка форма', 'Коли прикметник стоїть після «je», чоловічий рід часто без -i.', 'Grad je velik. · Crkva je velika. · Kino je veliko.', '[{"hr": "Stan je nov.", "ua": "Квартира нова."}, {"hr": "Muzej je star.", "ua": "Музей старий."}, {"hr": "More je toplo.", "ua": "Море тепле."}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = '87d9e203-7b7e-5937-a36b-46e64d4ab14a')
on conflict (id) do nothing;
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', '87d9e203-7b7e-5937-a36b-46e64d4ab14a', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.'
where exists (select 1 from public.grammar_topics where id = '87d9e203-7b7e-5937-a36b-46e64d4ab14a')
  and not exists (select 1 from public.content_reviews where entity_id = '87d9e203-7b7e-5937-a36b-46e64d4ab14a' and notes = 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '303fb08c-7749-5076-a37f-e30f7a16487f', 'A0', 'Питальні слова', 'Upitne riječi', 'Хто? Що? Де? Куди? Коли? Як? Скільки?', 'PUBLISHED'
where not exists (select 1 from public.grammar_topics where cefr = 'A0' and title_ua = 'Питальні слова');
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '52a41358-8781-59b9-a45c-b8bebc5d1762', '303fb08c-7749-5076-a37f-e30f7a16487f', 'Основні питання', 'Питальне слово стоїть на початку речення.', 'tko · što · gdje · kada · kako · koliko · zašto', '[{"hr": "Tko je to?", "ua": "Хто це?"}, {"hr": "Gdje je hotel?", "ua": "Де готель?"}, {"hr": "Kada ide autobus?", "ua": "Коли їде автобус?"}]'::jsonb, 1
where exists (select 1 from public.grammar_topics where id = '303fb08c-7749-5076-a37f-e30f7a16487f')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '70c47f9d-70c0-5497-9816-b090e1dca823', '303fb08c-7749-5076-a37f-e30f7a16487f', 'Де? Куди? Звідки?', '«Gdje» — де (місце), «kamo» — куди (напрямок), «odakle» — звідки.', 'gdje · kamo · odakle', '[{"hr": "Gdje živiš?", "ua": "Де ти живеш?"}, {"hr": "Kamo ideš?", "ua": "Куди ти йдеш?"}, {"hr": "Odakle ste?", "ua": "Звідки ви?"}]'::jsonb, 2
where exists (select 1 from public.grammar_topics where id = '303fb08c-7749-5076-a37f-e30f7a16487f')
on conflict (id) do nothing;
insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
select '51f1f147-7f26-5aa2-b8da-8d72bdf18770', '303fb08c-7749-5076-a37f-e30f7a16487f', 'Коли ви не зрозуміли', 'Ці фрази рятують у будь-якій розмові.', 'Molim? · Možete li ponoviti? · Polako, molim vas.', '[{"hr": "Možete li ponoviti, molim vas?", "ua": "Можете повторити, будь ласка?"}, {"hr": "Govorite polako, molim vas.", "ua": "Говоріть повільно, будь ласка."}, {"hr": "Kako se kaže «хліб» na hrvatskom?", "ua": "Як сказати «хліб» хорватською?"}]'::jsonb, 3
where exists (select 1 from public.grammar_topics where id = '303fb08c-7749-5076-a37f-e30f7a16487f')
on conflict (id) do nothing;
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'grammar_topic', '303fb08c-7749-5076-a37f-e30f7a16487f', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.'
where exists (select 1 from public.grammar_topics where id = '303fb08c-7749-5076-a37f-e30f7a16487f')
  and not exists (select 1 from public.content_reviews where entity_id = '303fb08c-7749-5076-a37f-e30f7a16487f' and notes = 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.');

-- 3. Модулі A0.2–A0.10 і їхні юніти (PUBLISHED)
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('993b3c7b-d1ee-5a63-bbf1-75590b68c263', 'A0', 'Модуль A0.2 — Ja sam…', 'Modul A0.2 — Ja sam...', 'Ім''я, звідки ви, де живете і ким працюєте.', 2, 'PUBLISHED')
on conflict do nothing;
insert into public.units (id, module_id, title_ua, title_hr, objectives, order_index, status)
select '05f37152-3b3d-5c44-9057-8ce4b863581b', m.id, 'Про себе', 'O sebi', '["Представитися", "Розповісти, звідки ви і де живете", "Назвати професію"]'::jsonb, 1, 'PUBLISHED'
from public.modules m where m.level_code = 'A0' and m.order_index = 2
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('9367556f-1e3f-52c4-9a05-65efc8a2dc6b', 'A0', 'Модуль A0.3 — Brojevi (числа)', 'Modul A0.3 — Brojevi', 'Числа 0–100: вік, ціни, номери телефонів.', 3, 'PUBLISHED')
on conflict do nothing;
insert into public.units (id, module_id, title_ua, title_hr, objectives, order_index, status)
select 'e36dc685-25e8-59ae-b3e0-26bacf0b7217', m.id, 'Числа', 'Brojevi', '["Рахувати до 100", "Назвати номер телефону", "Запитати ціну"]'::jsonb, 1, 'PUBLISHED'
from public.modules m where m.level_code = 'A0' and m.order_index = 3
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('7e7aa512-46f3-50d8-b95a-7ba4b9e6f148', 'A0', 'Модуль A0.4 — Vrijeme (час)', 'Modul A0.4 — Vrijeme', 'Дні тижня, місяці, години; сьогодні, завтра, учора.', 4, 'PUBLISHED')
on conflict do nothing;
insert into public.units (id, module_id, title_ua, title_hr, objectives, order_index, status)
select '2687d8ee-a7f1-542e-b84a-6cdc286712f8', m.id, 'Час і дні', 'Vrijeme i dani', '["Назвати день тижня", "Запитати, котра година", "Говорити про місяці й пори року"]'::jsonb, 1, 'PUBLISHED'
from public.modules m where m.level_code = 'A0' and m.order_index = 4
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('03537c9e-b657-5004-a254-389abb5c8dfc', 'A0', 'Модуль A0.5 — Obitelj (сім’я)', 'Modul A0.5 — Obitelj', 'Члени родини, «мій / моя / моє», множина.', 5, 'PUBLISHED')
on conflict do nothing;
insert into public.units (id, module_id, title_ua, title_hr, objectives, order_index, status)
select 'c7d8fd8f-de48-5ab6-8822-3c9ed4d2fb87', m.id, 'Моя сім’я', 'Moja obitelj', '["Розповісти про родину", "Сказати «мій / моя / моє»", "Утворювати множину"]'::jsonb, 1, 'PUBLISHED'
from public.modules m where m.level_code = 'A0' and m.order_index = 5
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('c65b21ca-4c8b-5b74-8b12-7014e57210db', 'A0', 'Модуль A0.6 — Moj dom (мій дім)', 'Modul A0.6 — Moj dom', 'Кімнати, речі вдома і де що знаходиться.', 6, 'PUBLISHED')
on conflict do nothing;
insert into public.units (id, module_id, title_ua, title_hr, objectives, order_index, status)
select '76c74777-ba10-5670-aca4-8eb57b0c8c42', m.id, 'Дім', 'Dom', '["Назвати кімнати й меблі", "Сказати, де щось лежить"]'::jsonb, 1, 'PUBLISHED'
from public.modules m where m.level_code = 'A0' and m.order_index = 6
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('0d928777-015b-58ca-a55f-65892de684d0', 'A0', 'Модуль A0.7 — Hrana (їжа)', 'Modul A0.7 — Hrana', 'Їжа й напої, замовлення в кафе, рахунок.', 7, 'PUBLISHED')
on conflict do nothing;
insert into public.units (id, module_id, title_ua, title_hr, objectives, order_index, status)
select 'f5cf2495-b41c-5318-95bc-bedc872f55a5', m.id, 'Їжа й напої', 'Hrana i piće', '["Сказати, що ви голодні", "Замовити в кафе", "Попросити рахунок"]'::jsonb, 1, 'PUBLISHED'
from public.modules m where m.level_code = 'A0' and m.order_index = 7
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('3fbf61ad-1d1b-5447-8c67-5896b1cc1f59', 'A0', 'Модуль A0.8 — Kupovina (покупки)', 'Modul A0.8 — Kupovina', 'Ринок, магазин, ціни й кількість, оплата.', 8, 'PUBLISHED')
on conflict do nothing;
insert into public.units (id, module_id, title_ua, title_hr, objectives, order_index, status)
select 'e5ee94f5-0a7e-50dc-a6ff-b946b1378396', m.id, 'Покупки', 'Kupovina', '["Купити на ринку", "Запитати ціну речі", "Розрахуватися на касі"]'::jsonb, 1, 'PUBLISHED'
from public.modules m where m.level_code = 'A0' and m.order_index = 8
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('5dec9cd3-0f02-5fc1-b8ef-8bec96b7ade8', 'A0', 'Модуль A0.9 — Grad (місто)', 'Modul A0.9 — Grad', 'Дорога, місця в місті, транспорт і квитки.', 9, 'PUBLISHED')
on conflict do nothing;
insert into public.units (id, module_id, title_ua, title_hr, objectives, order_index, status)
select '3522c0c0-fb96-5108-95fb-ed3e88d3fd66', m.id, 'Місто й транспорт', 'Grad i prijevoz', '["Запитати дорогу", "Описати місто", "Купити квиток"]'::jsonb, 1, 'PUBLISHED'
from public.modules m where m.level_code = 'A0' and m.order_index = 9
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('588b0086-831d-5577-b992-b00f68e9dd87', 'A0', 'Модуль A0.10 — Survival Croatian (виживання)', 'Modul A0.10 — Survival Croatian', 'Попросити допомоги, екстрені ситуації, перші документи.', 10, 'PUBLISHED')
on conflict do nothing;
insert into public.units (id, module_id, title_ua, title_hr, objectives, order_index, status)
select '7c5becd1-c264-59f4-972e-fd095492d394', m.id, 'Виживання', 'Snalaženje', '["Попросити допомоги", "Діяти в екстреній ситуації", "Назвати свої дані в установі"]'::jsonb, 1, 'PUBLISHED'
from public.modules m where m.level_code = 'A0' and m.order_index = 10
on conflict do nothing;

-- 4. Уроки A0
-- A0.1 · урок 2: Добрий день і до побачення
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'd8cffb46-8a62-538a-b864-e227a6d8b863';
  v_id uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 1 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.1'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise notice 'A0.1: місце уроку 2 вже зайняте — пропускаю'; return;
  end if;

  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 2: Добрий день і до побачення', 'Lekcija 2: Dobar dan i doviđenja', '["Вітатися в різний час доби", "Прощатися і бажати гарного дня", "Розрізняти «ti» і «Vi»"]'::jsonb, 10, 'PUBLISHED', 2);

  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('dobro jutro') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'dobro jutro'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 1, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('dobar dan') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'dobar dan'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 2, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('dobra večer') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'dobra večer'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 3, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('laku noć') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'laku noć'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 4, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('doviđenja') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'doviđenja'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 5, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ugodan dan') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ugodan dan'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 6, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('izvolite') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'izvolite'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 7, 'vocabulary');
  -- граматика
  select id into v_id from public.grammar_topics where cefr = 'A0' and title_ua = 'Ввічливість: ti і Vi' order by created_at limit 1;
  if v_id is null then raise exception 'Немає граматичної теми «%»', 'Ввічливість: ti і Vi'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_id, 8, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_id) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('17cbb9db-ab7e-5fd0-83b9-968f72479e04', 'fill_in_the_blank', 'Як привітатися ввечері?', 'Dobra večer', '["Dobro jutro", "Laku noć", "Dobra večer", "Dobar dan"]'::jsonb, 'A0', 1, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '17cbb9db-ab7e-5fd0-83b9-968f72479e04', 9, 'reading');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('c5642852-7da9-533c-8b6d-04cf83dd90b7', 'sentence_builder', 'Складіть: «Добрий день! Прошу.»', 'Dobar dan! Izvolite.', '["Izvolite.", "dan!", "Dobar"]'::jsonb, 'A0', 2, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c5642852-7da9-533c-8b6d-04cf83dd90b7', 10, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('9b9e873a-757e-5675-8b59-e45564ac8cc2', 'listening', 'Прослухайте і складіть фразу', 'Hvala, doviđenja!', '["doviđenja!", "Hvala,"]'::jsonb, 'A0', 3, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9b9e873a-757e-5675-8b59-e45564ac8cc2', 11, 'listening');
  -- діалог
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('7d02c908-d449-52fe-a332-090dda8bbd94', v_lesson, 'У кав’ярні', 'U kafiću', 2, 'A0', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('61d7f527-337b-5d55-bc53-d207fcc4bb7a', '7d02c908-d449-52fe-a332-090dda8bbd94', 'Gost', 'Dobar dan!', 'Добрий день!', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('80d7e9f1-88f6-526d-87da-a3b25ea25987', '7d02c908-d449-52fe-a332-090dda8bbd94', 'Konobarica', 'Dobar dan! Izvolite.', 'Добрий день! Прошу.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('4d24dabd-6c0e-5084-b7e5-ae7a4cf10c38', '7d02c908-d449-52fe-a332-090dda8bbd94', 'Gost', 'Jednu kavu, molim.', 'Одну каву, будь ласка.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('d83cfa87-8d5a-5469-8a61-c423fc579459', '7d02c908-d449-52fe-a332-090dda8bbd94', 'Konobarica', 'Izvolite. Ugodan dan!', 'Прошу. Гарного дня!', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('87edb0af-8c6e-5ab5-bb0d-9103cba8d0c9', '7d02c908-d449-52fe-a332-090dda8bbd94', 'Gost', 'Hvala, doviđenja!', 'Дякую, до побачення!', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.');
end $$;

-- A0.1 · урок 3: Вибачте, я не розумію
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'a17f2f16-1be9-50f2-8e16-2bebfcced33b';
  v_id uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 1 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.1'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise notice 'A0.1: місце уроку 3 вже зайняте — пропускаю'; return;
  end if;

  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 3: Вибачте, я не розумію', 'Lekcija 3: Oprostite, ne razumijem', '["Просити повторити й говорити повільніше", "Дякувати і відповідати на подяку", "Читати хорватські літери"]'::jsonb, 10, 'PUBLISHED', 3);

  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('oprostite') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'oprostite'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 1, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ne razumijem') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ne razumijem'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 2, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('možete li ponoviti') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'možete li ponoviti'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 3, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('naravno') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'naravno'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 4, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('nema na čemu') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'nema na čemu'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 5, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('molim') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'molim'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 6, 'vocabulary');
  -- граматика
  select id into v_id from public.grammar_topics where cefr = 'A0' and title_ua = 'Вимова: хорватські літери' order by created_at limit 1;
  if v_id is null then raise exception 'Немає граматичної теми «%»', 'Вимова: хорватські літери'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_id, 7, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_id) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('3c1332b3-2727-515c-a4cd-95e3a4c07f0a', 'fill_in_the_blank', 'Що означає «Ne razumijem»?', 'Я не розумію', '["Я не знаю", "Я не чую", "Я не розумію", "Я не хочу"]'::jsonb, 'A0', 1, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '3c1332b3-2727-515c-a4cd-95e3a4c07f0a', 8, 'reading');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('f1c55c72-267b-5f80-8773-7020ea8c0f1f', 'sentence_builder', 'Складіть: «Можете повторити?»', 'Možete li ponoviti?', '["ponoviti?", "Možete", "li"]'::jsonb, 'A0', 2, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f1c55c72-267b-5f80-8773-7020ea8c0f1f', 9, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('b7a3860c-065c-53c7-8d36-7ed8b5bf4963', 'listening', 'Прослухайте і складіть фразу', 'Nema na čemu.', '["na", "čemu.", "Nema"]'::jsonb, 'A0', 3, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'b7a3860c-065c-53c7-8d36-7ed8b5bf4963', 10, 'listening');
  -- діалог
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('515ad33b-53ec-5475-8aa1-d81afd3add16', v_lesson, 'Турист у Загребі', 'Turist u Zagrebu', 3, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('fd65db6c-3666-5fe5-bde3-fee4fb869b6c', '515ad33b-53ec-5475-8aa1-d81afd3add16', 'Turist', 'Oprostite, govorite li engleski?', 'Вибачте, ви розмовляєте англійською?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('63b880c5-3ea9-5e7c-9701-9819b1d6a3a5', '515ad33b-53ec-5475-8aa1-d81afd3add16', 'Prolaznik', 'Malo. Izvolite?', 'Трохи. Слухаю вас?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('19e23e91-24d9-53ce-85a4-3bc4c550bc39', '515ad33b-53ec-5475-8aa1-d81afd3add16', 'Turist', 'Ne razumijem dobro hrvatski. Možete li govoriti polako?', 'Я погано розумію хорватську. Можете говорити повільно?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('d962776c-3f27-5dd4-a9bb-06db568419d9', '515ad33b-53ec-5475-8aa1-d81afd3add16', 'Prolaznik', 'Naravno. Dobro došli u Zagreb!', 'Звісно. Ласкаво просимо до Загреба!', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('a6647433-6190-56fc-9a4b-8dd79c9bf1d3', '515ad33b-53ec-5475-8aa1-d81afd3add16', 'Turist', 'Hvala lijepa!', 'Щиро дякую!', 5) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('70919e30-a6a9-5bff-ab5a-6359f1f22153', '515ad33b-53ec-5475-8aa1-d81afd3add16', 'Prolaznik', 'Nema na čemu.', 'Нема за що.', 6) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.');
end $$;

-- A0.2 · урок 4: Як тебе звати?
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '2b6ed342-cc80-5bd9-baf0-b66109624d62';
  v_id uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 2 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.2'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise notice 'A0.2: місце уроку 1 вже зайняте — пропускаю'; return;
  end if;

  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 4: Як тебе звати?', 'Lekcija 4: Kako se zoveš?', '["Назвати своє ім’я", "Запитати ім’я", "Сказати «приємно познайомитися»"]'::jsonb, 10, 'PUBLISHED', 1);

  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('zovem se') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'zovem se'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 1, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kako se zoveš') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kako se zoveš'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 2, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kako se zovete') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kako se zovete'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 3, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('drago mi je') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'drago mi je'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 4, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ime') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ime'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 5, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('prezime') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'prezime'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 6, 'vocabulary');
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('7b467372-5d29-5115-9422-a27b41b24dda', 'fill_in_the_blank', 'Ja ___ Ivan.', 'sam', '["si", "smo", "sam", "je"]'::jsonb, 'A0', 1, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '7b467372-5d29-5115-9422-a27b41b24dda', 7, 'reading');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('8e86bcdf-c2e9-590f-a176-5edd9ed1a9b7', 'sentence_builder', 'Складіть: «Мене звати Мая.»', 'Zovem se Maja.', '["Maja.", "Zovem", "se"]'::jsonb, 'A0', 2, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '8e86bcdf-c2e9-590f-a176-5edd9ed1a9b7', 8, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('96d86554-c307-5f65-a982-59f010ac809f', 'listening', 'Прослухайте і складіть фразу', 'Drago mi je.', '["mi", "je.", "Drago"]'::jsonb, 'A0', 3, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '96d86554-c307-5f65-a982-59f010ac809f', 9, 'listening');
  -- діалог
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('32f19ec0-b572-5e32-9995-123fd68b702f', v_lesson, 'Знайомство на курсі', 'Upoznavanje na tečaju', 4, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('a2dfd4bb-03b6-5e04-9362-04ec766bb75c', '32f19ec0-b572-5e32-9995-123fd68b702f', 'Ivan', 'Bok! Ja sam Ivan. Kako se zoveš?', 'Привіт! Я Іван. Як тебе звати?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('f9635a90-b7f7-582e-a848-9fefda90c736', '32f19ec0-b572-5e32-9995-123fd68b702f', 'Maja', 'Bok, Ivane! Zovem se Maja.', 'Привіт, Іване! Мене звати Мая.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('47da78ea-09d1-5451-9680-08d54889db3e', '32f19ec0-b572-5e32-9995-123fd68b702f', 'Ivan', 'Drago mi je, Majo.', 'Приємно познайомитися, Має.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('9b68b8f8-d34c-5260-905e-f58287ebc377', '32f19ec0-b572-5e32-9995-123fd68b702f', 'Maja', 'I meni.', 'Мені теж.', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.');
end $$;

-- A0.2 · урок 5: Звідки ви?
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '04167753-db83-5163-a91c-9f71dac18ab5';
  v_id uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 2 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.2'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise notice 'A0.2: місце уроку 2 вже зайняте — пропускаю'; return;
  end if;

  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 5: Звідки ви?', 'Lekcija 5: Odakle ste?', '["Сказати, звідки ви", "Сказати, де живете", "Заперечувати: «я не…»"]'::jsonb, 10, 'PUBLISHED', 2);

  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('odakle ste') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'odakle ste'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 1, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ukrajina') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ukrajina'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 2, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ukrajinac') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ukrajinac'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 3, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('hrvat') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'hrvat'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 4, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('živjeti') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'živjeti'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 5, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('grad') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'grad'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 6, 'vocabulary');
  -- граматика
  select id into v_id from public.grammar_topics where cefr = 'A0' and title_ua = 'Заперечення і питання з «biti»' order by created_at limit 1;
  if v_id is null then raise exception 'Немає граматичної теми «%»', 'Заперечення і питання з «biti»'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_id, 7, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_id) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('b456a455-d2fd-5c60-b3dc-bfd0b300a468', 'fill_in_the_blank', 'Ne, ja ___ Hrvat.', 'nisam', '["nisam", "nismo", "nisi", "nije"]'::jsonb, 'A0', 1, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'b456a455-d2fd-5c60-b3dc-bfd0b300a468', 8, 'reading');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('3269bf07-7ec9-5fe2-929b-9cb99f4df7b1', 'sentence_builder', 'Складіть: «Я живу в Загребі.»', 'Živim u Zagrebu.', '["u", "Zagrebu.", "Živim"]'::jsonb, 'A0', 2, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '3269bf07-7ec9-5fe2-929b-9cb99f4df7b1', 9, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('a23ffd99-7670-5d65-a677-7bdc0a7504c7', 'listening', 'Прослухайте і складіть фразу', 'Ja sam iz Ukrajine.', '["sam", "iz", "Ukrajine.", "Ja"]'::jsonb, 'A0', 3, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a23ffd99-7670-5d65-a677-7bdc0a7504c7', 10, 'listening');
  -- діалог
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('827ddcc7-4529-5a4b-905a-5307a46a208c', v_lesson, 'В установі', 'U uredu', 5, 'A0', 'administration', 'PUBLISHED', 'claude_curriculum_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('d3344cce-8071-5a32-85fa-e382ebdfa015', '827ddcc7-4529-5a4b-905a-5307a46a208c', 'Službenica', 'Odakle ste?', 'Звідки ви?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('f8e79014-26a5-5ada-a7d0-50c1df3cbe21', '827ddcc7-4529-5a4b-905a-5307a46a208c', 'Oleg', 'Ja sam iz Ukrajine.', 'Я з України.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('8fff70c4-0834-5910-9947-0eff2ff07003', '827ddcc7-4529-5a4b-905a-5307a46a208c', 'Službenica', 'Gdje živite?', 'Де ви живете?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('921ebb90-7f76-5c24-aa83-d14ad6fc7514', '827ddcc7-4529-5a4b-905a-5307a46a208c', 'Oleg', 'Živim u Zagrebu.', 'Я живу в Загребі.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('904d5b89-b244-5e34-a734-6ce992bb0c4c', '827ddcc7-4529-5a4b-905a-5307a46a208c', 'Službenica', 'Jeste li Hrvat?', 'Ви хорват?', 5) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('d1289593-91a3-5caf-8c84-2af065af6660', '827ddcc7-4529-5a4b-905a-5307a46a208c', 'Oleg', 'Ne, nisam Hrvat. Ja sam Ukrajinac.', 'Ні, я не хорват. Я українець.', 6) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.');
end $$;

-- A0.2 · урок 6: Ким ви працюєте?
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '2fa5fa38-9641-5dc5-9156-6a3f7fe8035b';
  v_id uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 2 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.2'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise notice 'A0.2: місце уроку 3 вже зайняте — пропускаю'; return;
  end if;

  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 6: Ким ви працюєте?', 'Lekcija 6: Što radite?', '["Назвати свою професію", "Запитати про роботу"]'::jsonb, 10, 'PUBLISHED', 3);

  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('raditi') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'raditi'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 1, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('programer') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'programer'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 2, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('profesor') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'profesor'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 3, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('zanimanje') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'zanimanje'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 4, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('posao') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'posao'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 5, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('škola') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'škola'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 6, 'vocabulary');
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('e400a5db-6002-580d-8299-2ac2ec2e8765', 'fill_in_the_blank', 'Що означає «Što radiš?»', 'Чим ти займаєшся?', '["Чим ти займаєшся?", "Як справи?", "Де ти живеш?", "Звідки ти?"]'::jsonb, 'A0', 1, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e400a5db-6002-580d-8299-2ac2ec2e8765', 7, 'reading');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('f2afc642-6fc2-53a5-8cd4-569f15797470', 'sentence_builder', 'Складіть: «Я працюю з дому.»', 'Radim od kuće.', '["kuće.", "Radim", "od"]'::jsonb, 'A0', 2, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f2afc642-6fc2-53a5-8cd4-569f15797470', 8, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('60b0e11f-f6b3-50a5-90b1-e8b43536d010', 'listening', 'Прослухайте і складіть фразу', 'Ja sam programer.', '["Ja", "programer.", "sam"]'::jsonb, 'A0', 3, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '60b0e11f-f6b3-50a5-90b1-e8b43536d010', 9, 'listening');
  -- діалог
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d4e87078-b14f-5da3-825a-71148d9e6b40', v_lesson, 'Розмова з сусідкою', 'Razgovor sa susjedom', 6, 'A0', 'work', 'PUBLISHED', 'claude_curriculum_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('06276d63-cc9d-5222-b7c7-799a180b945d', 'd4e87078-b14f-5da3-825a-71148d9e6b40', 'Petra', 'Što radiš?', 'Чим ти займаєшся?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('69a717bc-be3b-5c9a-a88e-d3350fdcbe34', 'd4e87078-b14f-5da3-825a-71148d9e6b40', 'Andrij', 'Ja sam programer. A ti?', 'Я програміст. А ти?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('102d29ca-944a-5381-8e64-f3025717cc53', 'd4e87078-b14f-5da3-825a-71148d9e6b40', 'Petra', 'Ja sam profesorica. Radim u školi.', 'Я вчителька. Працюю в школі.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('bc5ad2d1-a5ba-5fd0-9e25-a4de8587d29c', 'd4e87078-b14f-5da3-825a-71148d9e6b40', 'Andrij', 'Super! Ja radim od kuće.', 'Супер! А я працюю з дому.', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.');
end $$;

-- A0.3 · урок 7: Числа від 0 до 10
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'c0941bd8-57b5-5e7e-981f-9be423f24208';
  v_id uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 3 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.3'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise notice 'A0.3: місце уроку 1 вже зайняте — пропускаю'; return;
  end if;

  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 7: Числа від 0 до 10', 'Lekcija 7: Brojevi od nula do deset', '["Рахувати від 0 до 10", "Продиктувати номер телефону"]'::jsonb, 10, 'PUBLISHED', 1);

  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('nula') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'nula'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 1, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('jedan') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'jedan'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 2, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('dva') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'dva'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 3, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('tri') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'tri'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 4, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('četiri') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'četiri'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 5, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('pet') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'pet'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 6, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('šest') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'šest'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 7, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sedam') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'sedam'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 8, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('osam') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'osam'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 9, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('devet') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'devet'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 10, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('deset') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'deset'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 11, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('broj') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'broj'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 12, 'vocabulary');
  -- граматика
  select id into v_id from public.grammar_topics where cefr = 'A0' and title_ua = 'Числа 0–100' order by created_at limit 1;
  if v_id is null then raise exception 'Немає граматичної теми «%»', 'Числа 0–100'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_id, 13, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_id) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('f88f6910-af01-5e79-b9bd-f4950edf4715', 'fill_in_the_blank', 'Як хорватською «сім»?', 'sedam', '["šest", "osam", "sedam", "deset"]'::jsonb, 'A0', 1, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f88f6910-af01-5e79-b9bd-f4950edf4715', 14, 'reading');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('c17a057f-59b2-5185-984c-2102a8fef0b5', 'sentence_builder', 'Складіть: «Повтори, будь ласка.»', 'Ponovi, molim te.', '["molim", "te.", "Ponovi,"]'::jsonb, 'A0', 2, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c17a057f-59b2-5185-984c-2102a8fef0b5', 15, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('0fc0860e-9c5c-5d82-ab24-c448bbc559b5', 'listening', 'Прослухайте і складіть фразу', 'Nula, devet, jedan.', '["jedan.", "Nula,", "devet,"]'::jsonb, 'A0', 3, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '0fc0860e-9c5c-5d82-ab24-c448bbc559b5', 16, 'listening');
  -- діалог
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('ab9c1ba1-ce99-51d0-b204-863eb1feb1ca', v_lesson, 'Номер телефону', 'Broj telefona', 7, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ae4772b3-9cfb-53cf-83e3-806df4eb478e', 'ab9c1ba1-ce99-51d0-b204-863eb1feb1ca', 'Ana', 'Koji je tvoj broj telefona?', 'Який у тебе номер телефону?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('41d4ee32-f56a-5b5d-a1a1-51f6c4b64dcc', 'ab9c1ba1-ce99-51d0-b204-863eb1feb1ca', 'Luka', 'Nula, devet, jedan, dva, tri, četiri, pet.', 'Нуль, дев’ять, один, два, три, чотири, п’ять.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('d76d167d-9895-53c3-a0f2-a1cc2d721adb', 'ab9c1ba1-ce99-51d0-b204-863eb1feb1ca', 'Ana', 'Molim? Ponovi, molim te.', 'Перепрошую? Повтори, будь ласка.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('643a94d6-45e5-5bdc-b2ba-4150a4bfdf10', 'ab9c1ba1-ce99-51d0-b204-863eb1feb1ca', 'Luka', 'Nula, devet, jedan… dva, tri, četiri, pet.', 'Нуль, дев’ять, один… два, три, чотири, п’ять.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('6b1ce001-887c-5a40-a7df-f1c9a1af3a6e', 'ab9c1ba1-ce99-51d0-b204-863eb1feb1ca', 'Ana', 'Hvala!', 'Дякую!', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.');
end $$;

-- A0.3 · урок 8: Скільки вам років?
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '4c5db9c0-aa58-55c5-b647-7f7cfc8396c2';
  v_id uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 3 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.3'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise notice 'A0.3: місце уроку 2 вже зайняте — пропускаю'; return;
  end if;

  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 8: Скільки вам років?', 'Lekcija 8: Koliko imate godina?', '["Сказати свій вік", "Запитати про вік"]'::jsonb, 10, 'PUBLISHED', 2);

  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('koliko godina imate') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'koliko godina imate'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 1, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('koliko') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'koliko'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 2, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('imati') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'imati'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 3, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('trideset') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'trideset'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 4, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('godina') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'godina'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 5, 'vocabulary');
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('7091ab09-d82e-5e71-8cdc-fc5042873de4', 'fill_in_the_blank', 'Imam pet ___.', 'godina', '["godine", "godinu", "godina", "godini"]'::jsonb, 'A0', 1, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '7091ab09-d82e-5e71-8cdc-fc5042873de4', 6, 'reading');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('d6c2aa30-15f6-51b4-9a84-9b63e9cccc96', 'sentence_builder', 'Складіть: «Їй сім років.»', 'Ona ima sedam godina.', '["Ona", "godina.", "sedam", "ima"]'::jsonb, 'A0', 2, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd6c2aa30-15f6-51b4-9a84-9b63e9cccc96', 7, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('f2c440e8-db25-5d1c-bdd5-4494402aac28', 'listening', 'Прослухайте і складіть фразу', 'Imam trideset pet godina.', '["godina.", "Imam", "pet", "trideset"]'::jsonb, 'A0', 3, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f2c440e8-db25-5d1c-bdd5-4494402aac28', 8, 'listening');
  -- діалог
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('8994f8a3-5bb1-5e39-80d7-068759a9fbb6', v_lesson, 'У лікарки', 'Kod liječnice', 8, 'A0', 'health', 'PUBLISHED', 'claude_curriculum_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('764174d7-ff0a-589c-8a9f-75cabbe18729', '8994f8a3-5bb1-5e39-80d7-068759a9fbb6', 'Liječnica', 'Koliko imate godina?', 'Скільки вам років?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('0ab4b7ea-bf21-541a-a2b6-904ac79ded81', '8994f8a3-5bb1-5e39-80d7-068759a9fbb6', 'Pacijent', 'Imam trideset pet godina.', 'Мені тридцять п’ять років.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('093bf0d3-4f5e-553a-8ddd-542594af3a82', '8994f8a3-5bb1-5e39-80d7-068759a9fbb6', 'Liječnica', 'A vaša kći?', 'А вашій доньці?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('f49735d1-d164-51d9-b551-2dd8e037bef9', '8994f8a3-5bb1-5e39-80d7-068759a9fbb6', 'Pacijent', 'Ona ima sedam godina.', 'Їй сім років.', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.');
end $$;

-- A0.3 · урок 9: Скільки це коштує?
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '427e5058-7381-58a0-8f21-bd170866dbae';
  v_id uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 3 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.3'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise notice 'A0.3: місце уроку 3 вже зайняте — пропускаю'; return;
  end if;

  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 9: Скільки це коштує?', 'Lekcija 9: Koliko to košta?', '["Запитати ціну", "Розуміти ціни в євро"]'::jsonb, 10, 'PUBLISHED', 3);

  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('koliko to košta') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'koliko to košta'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 1, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('koštati') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'koštati'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 2, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('euro') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'euro'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 3, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('cent') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'cent'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 4, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('cijena') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'cijena'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 5, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kava') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kava'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 6, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sok') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'sok'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 7, 'vocabulary');
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('6030fd13-cbfc-5cca-b64e-fffb607833c0', 'fill_in_the_blank', 'Tri ___, molim. (кава)', 'kave', '["kavi", "kave", "kava", "kavu"]'::jsonb, 'A0', 1, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '6030fd13-cbfc-5cca-b64e-fffb607833c0', 8, 'reading');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('a1693b9f-4d99-5573-831a-d86bf2100876', 'sentence_builder', 'Складіть: «Скільки це коштує?»', 'Koliko to košta?', '["košta?", "Koliko", "to"]'::jsonb, 'A0', 2, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a1693b9f-4d99-5573-831a-d86bf2100876', 9, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('3df3929d-bdc1-53f5-8302-ce0befe24b14', 'listening', 'Прослухайте і складіть фразу', 'Dva eura, molim.', '["molim.", "Dva", "eura,"]'::jsonb, 'A0', 3, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '3df3929d-bdc1-53f5-8302-ce0befe24b14', 10, 'listening');
  -- діалог
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d73ba1a3-6b1c-5d85-904c-4b11f8571d5a', v_lesson, 'У кіоску', 'Na kiosku', 9, 'A0', 'shopping', 'PUBLISHED', 'claude_curriculum_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('548e221c-893f-593e-a6e5-5389fe2fce24', 'd73ba1a3-6b1c-5d85-904c-4b11f8571d5a', 'Kupac', 'Oprostite, koliko košta ova kava?', 'Перепрошую, скільки коштує ця кава?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('146a60a5-c3b2-51f2-8680-5a0b68b5cecb', 'd73ba1a3-6b1c-5d85-904c-4b11f8571d5a', 'Prodavač', 'Dva eura.', 'Два євро.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ca6fc3c6-bbc7-5a51-9b59-8bb849fff49f', 'd73ba1a3-6b1c-5d85-904c-4b11f8571d5a', 'Kupac', 'A sok?', 'А сік?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('233169b0-593c-59fc-af21-fddb26f8b89b', 'd73ba1a3-6b1c-5d85-904c-4b11f8571d5a', 'Prodavač', 'Tri eura i pedeset centi.', 'Три євро п’ятдесят центів.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('54b8adc4-b746-5853-8698-c93d1aa980aa', 'd73ba1a3-6b1c-5d85-904c-4b11f8571d5a', 'Kupac', 'Dobro, oboje, molim.', 'Добре, і те, і те, будь ласка.', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.');
end $$;

-- A0.4 · урок 10: Дні тижня
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '8e372ece-ae10-50ae-9cf3-07b52ef2f72d';
  v_id uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 4 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.4'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise notice 'A0.4: місце уроку 1 вже зайняте — пропускаю'; return;
  end if;

  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 10: Дні тижня', 'Lekcija 10: Dani u tjednu', '["Назвати дні тижня", "Сказати, що буде завтра"]'::jsonb, 10, 'PUBLISHED', 1);

  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('ponedjeljak') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ponedjeljak'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 1, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('utorak') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'utorak'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 2, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('srijeda') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'srijeda'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 3, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('četvrtak') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'četvrtak'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 4, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('petak') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'petak'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 5, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('subota') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'subota'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 6, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('nedjelja') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'nedjelja'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 7, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('danas') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'danas'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 8, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sutra') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'sutra'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 9, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('koji je danas dan') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'koji je danas dan'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 10, 'vocabulary');
  -- граматика
  select id into v_id from public.grammar_topics where cefr = 'A0' and title_ua = 'Час: дні, години, місяці' order by created_at limit 1;
  if v_id is null then raise exception 'Немає граматичної теми «%»', 'Час: дні, години, місяці'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_id, 11, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_id) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('c7f27cd3-2bc4-5796-a147-c71e30df321e', 'fill_in_the_blank', 'Danas je ___. (середа)', 'srijeda', '["nedjelja", "subota", "srijeda", "utorak"]'::jsonb, 'A0', 1, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c7f27cd3-2bc4-5796-a147-c71e30df321e', 12, 'reading');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('6b817861-0aec-5da5-bf11-c1294060c267', 'sentence_builder', 'Складіть: «Сьогодні середа.»', 'Danas je srijeda.', '["Danas", "srijeda.", "je"]'::jsonb, 'A0', 2, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '6b817861-0aec-5da5-bf11-c1294060c267', 13, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('78abf216-48a6-5c2f-b4e0-6e1548b12192', 'listening', 'Прослухайте і складіть фразу', 'Sutra je četvrtak.', '["je", "četvrtak.", "Sutra"]'::jsonb, 'A0', 3, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '78abf216-48a6-5c2f-b4e0-6e1548b12192', 14, 'listening');
  -- діалог
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('557b6d7e-4b64-5c11-8a3d-02a0665ef948', v_lesson, 'Плани на тиждень', 'Planovi za tjedan', 10, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('8dc46401-10ad-52cc-938e-2032dd9f2337', '557b6d7e-4b64-5c11-8a3d-02a0665ef948', 'Marko', 'Koji je danas dan?', 'Який сьогодні день?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('bb2c818d-8949-579f-970b-5a8a7cc1ede3', '557b6d7e-4b64-5c11-8a3d-02a0665ef948', 'Ana', 'Danas je srijeda.', 'Сьогодні середа.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('3408f1c9-ae97-5df3-b2fc-c44860ad2a25', '557b6d7e-4b64-5c11-8a3d-02a0665ef948', 'Marko', 'A sutra?', 'А завтра?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('660ea2a4-55db-560f-b2e2-6532f678db27', '557b6d7e-4b64-5c11-8a3d-02a0665ef948', 'Ana', 'Sutra je četvrtak. U petak idemo na more!', 'Завтра четвер. У п’ятницю їдемо на море!', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.');
end $$;

-- A0.4 · урок 11: Котра година?
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '39b1e31f-b573-5000-9713-1660688c3cc9';
  v_id uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 4 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.4'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise notice 'A0.4: місце уроку 2 вже зайняте — пропускаю'; return;
  end if;

  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 11: Котра година?', 'Lekcija 11: Koliko je sati?', '["Запитати, котра година", "Розуміти розклад"]'::jsonb, 10, 'PUBLISHED', 2);

  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('koliko je sati') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'koliko je sati'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 1, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sat') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'sat'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 2, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('minuta') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'minuta'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 3, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('rano') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'rano'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 4, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kasno') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kasno'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 5, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('autobus') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'autobus'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 6, 'vocabulary');
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('c8a497ea-e3a9-5180-bbf8-3c69dd493a1e', 'fill_in_the_blank', 'Autobus ide u pet ___.', 'sati', '["satu", "sati", "sata", "sat"]'::jsonb, 'A0', 1, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c8a497ea-e3a9-5180-bbf8-3c69dd493a1e', 7, 'reading');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('7aa2eb04-71f3-5a00-8f40-36a2197ef632', 'sentence_builder', 'Складіть: «Котра година?»', 'Koliko je sati?', '["sati?", "je", "Koliko"]'::jsonb, 'A0', 2, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '7aa2eb04-71f3-5a00-8f40-36a2197ef632', 8, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('b4c2ae75-5bed-590d-9eb2-4867b71fa649', 'listening', 'Прослухайте і складіть фразу', 'U jedanaest sati.', '["sati.", "U", "jedanaest"]'::jsonb, 'A0', 3, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'b4c2ae75-5bed-590d-9eb2-4867b71fa649', 9, 'listening');
  -- діалог
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('569dce68-c95a-59f2-b37b-6ee46beb1094', v_lesson, 'На зупинці', 'Na stanici', 11, 'A0', 'transport', 'PUBLISHED', 'claude_curriculum_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('a6d66301-6b58-5fa8-8550-0f694344095d', '569dce68-c95a-59f2-b37b-6ee46beb1094', 'Turist', 'Oprostite, koliko je sati?', 'Вибачте, котра година?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('9cdbe052-d11d-5727-bab5-de6088ff04b6', '569dce68-c95a-59f2-b37b-6ee46beb1094', 'Prolaznica', 'Deset sati.', 'Десята.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('d84913c7-08b8-5335-8534-1b9ca67c84ba', '569dce68-c95a-59f2-b37b-6ee46beb1094', 'Turist', 'Kada ide autobus za Split?', 'Коли їде автобус до Спліта?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('c8c1a42e-3a55-5492-8e4d-9a7c165af1eb', '569dce68-c95a-59f2-b37b-6ee46beb1094', 'Prolaznica', 'U jedanaest sati.', 'Об одинадцятій.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('44116739-817d-5d36-980b-e64a3fe63ae7', '569dce68-c95a-59f2-b37b-6ee46beb1094', 'Turist', 'Hvala!', 'Дякую!', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.');
end $$;

-- A0.4 · урок 12: Місяці й пори року
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '036fc4fb-1bf2-5100-9fd0-6f6a612554a1';
  v_id uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 4 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.4'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise notice 'A0.4: місце уроку 3 вже зайняте — пропускаю'; return;
  end if;

  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 12: Місяці й пори року', 'Lekcija 12: Mjeseci i godišnja doba', '["Назвати місяці й пори року", "Сказати, коли день народження"]'::jsonb, 10, 'PUBLISHED', 3);

  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('siječanj') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'siječanj'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 1, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('srpanj') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'srpanj'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 2, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ljeto') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ljeto'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 3, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('zima') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'zima'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 4, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('proljeće') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'proljeće'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 5, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('jesen') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'jesen'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 6, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('voljeti') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'voljeti'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 7, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('rođendan') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'rođendan'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 8, 'vocabulary');
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('db09ad45-c03c-55d0-b391-085684f4986f', 'fill_in_the_blank', 'Volim ___. (літо)', 'ljeto', '["ljeto", "jesen", "zimu", "proljeće"]'::jsonb, 'A0', 1, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'db09ad45-c03c-55d0-b391-085684f4986f', 9, 'reading');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('afde41e0-36fc-5324-86ee-df3c033f0a56', 'sentence_builder', 'Складіть: «Я люблю зиму!»', 'Volim zimu!', '["zimu!", "Volim"]'::jsonb, 'A0', 2, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'afde41e0-36fc-5324-86ee-df3c033f0a56', 10, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('5d747587-a044-5668-89f8-65c9283555eb', 'listening', 'Прослухайте і складіть фразу', 'Rođendan mi je u srpnju.', '["mi", "Rođendan", "srpnju.", "u", "je"]'::jsonb, 'A0', 3, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '5d747587-a044-5668-89f8-65c9283555eb', 11, 'listening');
  -- діалог
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('7d5d0c0f-f7f7-5792-96e9-3751f285bc4e', v_lesson, 'День народження', 'Rođendan', 12, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('d0a62f30-e5f5-512d-bd53-716e54c7d028', '7d5d0c0f-f7f7-5792-96e9-3751f285bc4e', 'Petra', 'Kada imaš rođendan?', 'Коли в тебе день народження?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('3d2eb423-e6d2-5d57-ac0e-323adb101485', '7d5d0c0f-f7f7-5792-96e9-3751f285bc4e', 'Oleg', 'U srpnju. A ti?', 'У липні. А в тебе?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('6bf2d68a-7ded-55dc-9d9a-83819a270803', '7d5d0c0f-f7f7-5792-96e9-3751f285bc4e', 'Petra', 'U siječnju. Volim zimu!', 'У січні. Я люблю зиму!', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('697f6a63-03d7-5eec-b50d-7c4d22c15a1a', '7d5d0c0f-f7f7-5792-96e9-3751f285bc4e', 'Oleg', 'Ja volim ljeto i more.', 'А я люблю літо і море.', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.');
end $$;

-- A0.5 · урок 13: Моя сім’я
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '4e003796-1ce0-5a02-8a2d-59a0de38f3dd';
  v_id uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 5 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.5'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise notice 'A0.5: місце уроку 1 вже зайняте — пропускаю'; return;
  end if;

  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 13: Моя сім’я', 'Lekcija 13: Moja obitelj', '["Представити членів сім’ї", "Запитати «хто це?»"]'::jsonb, 10, 'PUBLISHED', 1);

  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('obitelj') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'obitelj'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 1, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('brat') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'brat'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 2, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sestra') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'sestra'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 3, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('majka') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'majka'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 4, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('otac') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'otac'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 5, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('roditelji') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'roditelji'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 6, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('tko je to') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'tko je to'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 7, 'vocabulary');
  -- граматика
  select id into v_id from public.grammar_topics where cefr = 'A0' and title_ua = 'Рід, множина і «мій / моя / моє»' order by created_at limit 1;
  if v_id is null then raise exception 'Немає граматичної теми «%»', 'Рід, множина і «мій / моя / моє»'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_id, 8, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_id) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('823935c5-1379-5a52-949a-8b2ed74ec1f0', 'fill_in_the_blank', 'Ovo je ___ sestra.', 'moja', '["moja", "moje", "moji", "moj"]'::jsonb, 'A0', 1, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '823935c5-1379-5a52-949a-8b2ed74ec1f0', 9, 'reading');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('868b8b8c-5125-5483-bbcd-8129dc29e1fd', 'sentence_builder', 'Складіть: «Хто це?»', 'Tko je to?', '["je", "to?", "Tko"]'::jsonb, 'A0', 2, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '868b8b8c-5125-5483-bbcd-8129dc29e1fd', 10, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('b847eae8-c29d-5479-8731-1e2a3c5cceef', 'listening', 'Прослухайте і складіть фразу', 'Ovo je moja obitelj.', '["obitelj.", "je", "moja", "Ovo"]'::jsonb, 'A0', 3, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'b847eae8-c29d-5479-8731-1e2a3c5cceef', 11, 'listening');
  -- діалог
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('f7f1f609-a958-506c-aef0-423ebde5563a', v_lesson, 'Фото родини', 'Obiteljska fotografija', 13, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('5b846903-0257-5440-8c01-ef18bf0a576a', 'f7f1f609-a958-506c-aef0-423ebde5563a', 'Ana', 'Ovo je moja obitelj.', 'Це моя сім’я.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('bd86b9e8-3ae9-55c5-8b88-3153221bfc3d', 'f7f1f609-a958-506c-aef0-423ebde5563a', 'Ivan', 'Tko je to?', 'Хто це?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('46519658-e70c-5bfb-b9c6-47778363336a', 'f7f1f609-a958-506c-aef0-423ebde5563a', 'Ana', 'To je moj brat Luka, a ovo je moja sestra Maja.', 'Це мій брат Лука, а це моя сестра Мая.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('e86a847f-2c06-5671-aecd-de136aef5936', 'f7f1f609-a958-506c-aef0-423ebde5563a', 'Ivan', 'A tko je ovo?', 'А це хто?', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('2b116691-dc81-54f2-972d-0365321a02e1', 'f7f1f609-a958-506c-aef0-423ebde5563a', 'Ana', 'To su moji roditelji.', 'Це мої батьки.', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.');
end $$;

-- A0.5 · урок 14: Брати й сестри
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'f9ca38e4-3a61-56a6-b5f5-060933516c9a';
  v_id uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 5 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.5'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise notice 'A0.5: місце уроку 2 вже зайняте — пропускаю'; return;
  end if;

  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 14: Брати й сестри', 'Lekcija 14: Braća i sestre', '["Сказати, скільки у вас братів і сестер", "Розповісти, де вони живуть"]'::jsonb, 10, 'PUBLISHED', 2);

  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('brat') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'brat'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 1, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sestra') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'sestra'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 2, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('imati') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'imati'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 3, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('muž') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'muž'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 4, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('žena') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'žena'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 5, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('dijete') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'dijete'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 6, 'vocabulary');
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('c7fc6c06-0ba2-5671-8a14-afc239756413', 'fill_in_the_blank', 'Imam dva ___.', 'brata', '["braća", "bratu", "brat", "brata"]'::jsonb, 'A0', 1, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c7fc6c06-0ba2-5671-8a14-afc239756413', 7, 'reading');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('b95d9ef2-a2e4-5af5-91fa-bf34da6b33c9', 'sentence_builder', 'Складіть: «У мене одна сестра.»', 'Imam jednu sestru.', '["Imam", "sestru.", "jednu"]'::jsonb, 'A0', 2, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'b95d9ef2-a2e4-5af5-91fa-bf34da6b33c9', 8, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('e295ac55-e927-57fc-83d9-677ed01414be', 'listening', 'Прослухайте і складіть фразу', 'Imaš li brata ili sestru?', '["ili", "brata", "li", "Imaš", "sestru?"]'::jsonb, 'A0', 3, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e295ac55-e927-57fc-83d9-677ed01414be', 9, 'listening');
  -- діалог
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('08cf27e4-9e39-518c-8b72-1ae7e96f46a7', v_lesson, 'Про родину', 'O obitelji', 14, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('84f19550-04d1-56bf-a270-b08d39200042', '08cf27e4-9e39-518c-8b72-1ae7e96f46a7', 'Maja', 'Imaš li brata ili sestru?', 'У тебе є брат чи сестра?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('330f880e-591c-54b3-a817-a0b80625e45b', '08cf27e4-9e39-518c-8b72-1ae7e96f46a7', 'Oleg', 'Imam jednu sestru. Ona živi u Kijevu.', 'У мене одна сестра. Вона живе в Києві.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('9875136a-5c07-5f21-bc9a-1c9ddb4bbdc7', '08cf27e4-9e39-518c-8b72-1ae7e96f46a7', 'Maja', 'Ja imam dva brata.', 'А в мене два брати.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ca9e36fc-ab4d-5e6c-8782-74e05073ec2a', '08cf27e4-9e39-518c-8b72-1ae7e96f46a7', 'Oleg', 'Koliko imaju godina?', 'Скільки їм років?', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('4f495468-f395-5ea4-a644-dc8916bb7b04', '08cf27e4-9e39-518c-8b72-1ae7e96f46a7', 'Maja', 'Deset i dvanaest.', 'Десять і дванадцять.', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.');
end $$;

-- A0.5 · урок 15: Діти й друзі
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '2b0e9742-99e1-57e1-a574-67ffb78d2607';
  v_id uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 5 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.5'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise notice 'A0.5: місце уроку 3 вже зайняте — пропускаю'; return;
  end if;

  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 15: Діти й друзі', 'Lekcija 15: Djeca i prijatelji', '["Говорити про дітей", "Утворювати множину"]'::jsonb, 10, 'PUBLISHED', 3);

  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('dijete') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'dijete'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 1, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sin') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'sin'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 2, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kći') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kći'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 3, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('prijatelj') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'prijatelj'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 4, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('dječak') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'dječak'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 5, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('djevojčica') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'djevojčica'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 6, 'vocabulary');
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('1908947a-f2b8-5062-94f1-657121234bc8', 'fill_in_the_blank', 'Moji ___ žive u Zagrebu.', 'prijatelji', '["prijatelj", "prijateljem", "prijatelja", "prijatelji"]'::jsonb, 'A0', 1, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '1908947a-f2b8-5062-94f1-657121234bc8', 7, 'reading');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('52fd4d22-5a2d-58ea-91f3-ea41467e0107', 'sentence_builder', 'Складіть: «У тебе є діти?»', 'Imaš li djecu?', '["li", "djecu?", "Imaš"]'::jsonb, 'A0', 2, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '52fd4d22-5a2d-58ea-91f3-ea41467e0107', 8, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('75171f1f-c456-5f89-965d-d5be6d580f63', 'listening', 'Прослухайте і складіть фразу', 'Imam sina i kćer.', '["kćer.", "Imam", "sina", "i"]'::jsonb, 'A0', 3, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '75171f1f-c456-5f89-965d-d5be6d580f63', 9, 'listening');
  -- діалог
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('e2786d18-5964-5556-b63f-f471840fbd56', v_lesson, 'У парку', 'U parku', 15, 'A0', 'small_talk', 'PUBLISHED', 'claude_curriculum_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('f89a65f2-818f-5c41-9526-b48cb3bfe180', 'e2786d18-5964-5556-b63f-f471840fbd56', 'Ivan', 'Imaš li djecu?', 'У тебе є діти?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('c4b76a9f-6f79-5cb7-97cc-b6af28d636b2', 'e2786d18-5964-5556-b63f-f471840fbd56', 'Petra', 'Da, imam sina i kćer.', 'Так, у мене син і донька.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('c6ea2b0b-8440-5148-bd47-bb012ff9fc57', 'e2786d18-5964-5556-b63f-f471840fbd56', 'Ivan', 'Koliko su stari?', 'Скільки їм років?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('460d0627-8d6e-5677-bb93-ff9bcd46ae79', 'e2786d18-5964-5556-b63f-f471840fbd56', 'Petra', 'Sin ima pet, a kći osam godina.', 'Синові п’ять, а доньці вісім років.', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.');
end $$;

-- A0.6 · урок 16: Моя квартира
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '78f28f85-dd8b-5e81-8a52-1b2dbce4eb34';
  v_id uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 6 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.6'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise notice 'A0.6: місце уроку 1 вже зайняте — пропускаю'; return;
  end if;

  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 16: Моя квартира', 'Lekcija 16: Moj stan', '["Назвати кімнати", "Запитати, де кухня чи ванна"]'::jsonb, 10, 'PUBLISHED', 1);

  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('stan') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'stan'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 1, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('dnevni boravak') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'dnevni boravak'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 2, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kuhinja') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kuhinja'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 3, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kupaonica') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kupaonica'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 4, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('soba') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'soba'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 5, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('lijevo') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'lijevo'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 6, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('desno') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'desno'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 7, 'vocabulary');
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('2c147571-52ee-57ed-818e-f90035d67fb6', 'fill_in_the_blank', 'Gdje je ___? (кухня)', 'kuhinja', '["soba", "stan", "kuhinja", "kupaonica"]'::jsonb, 'A0', 1, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2c147571-52ee-57ed-818e-f90035d67fb6', 8, 'reading');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('36b12ad8-caab-56cb-b1a8-2ff6b184f348', 'sentence_builder', 'Складіть: «Де кухня?»', 'Gdje je kuhinja?', '["Gdje", "kuhinja?", "je"]'::jsonb, 'A0', 2, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '36b12ad8-caab-56cb-b1a8-2ff6b184f348', 9, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('678ab77d-c5c4-5ee2-945f-b4a60477e2ca', 'listening', 'Прослухайте і складіть фразу', 'Ovo je dnevni boravak.', '["dnevni", "je", "Ovo", "boravak."]'::jsonb, 'A0', 3, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '678ab77d-c5c4-5ee2-945f-b4a60477e2ca', 10, 'listening');
  -- діалог
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('9a7cec7e-7ce1-55ae-a8a8-d4ad4ccff9b5', v_lesson, 'Огляд квартири', 'Razgledavanje stana', 16, 'A0', 'housing', 'PUBLISHED', 'claude_curriculum_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('9612f216-4c24-5a91-9985-73bd6bb47b7b', '9a7cec7e-7ce1-55ae-a8a8-d4ad4ccff9b5', 'Agentica', 'Ovo je dnevni boravak.', 'Це вітальня.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('1be15c1f-b221-5b9d-9c64-c80a495bda19', '9a7cec7e-7ce1-55ae-a8a8-d4ad4ccff9b5', 'Oleg', 'Lijepo! A gdje je kuhinja?', 'Гарно! А де кухня?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('600f7b95-665e-5c32-8c04-1f24854ab9b3', '9a7cec7e-7ce1-55ae-a8a8-d4ad4ccff9b5', 'Agentica', 'Kuhinja je lijevo, a kupaonica desno.', 'Кухня ліворуч, а ванна праворуч.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('d463d8ef-c982-5852-a963-8cbff9ad95a7', '9a7cec7e-7ce1-55ae-a8a8-d4ad4ccff9b5', 'Oleg', 'Koliko soba ima stan?', 'Скільки кімнат у квартирі?', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('9d29b341-d074-5fe0-8c54-2fbb16b706c1', '9a7cec7e-7ce1-55ae-a8a8-d4ad4ccff9b5', 'Agentica', 'Dvije sobe.', 'Дві кімнати.', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.');
end $$;

-- A0.6 · урок 17: Де мої ключі?
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '0ecb6f19-2630-533d-9f1b-85102442af08';
  v_id uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 6 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.6'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise notice 'A0.6: місце уроку 2 вже зайняте — пропускаю'; return;
  end if;

  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 17: Де мої ключі?', 'Lekcija 17: Gdje su moji ključevi?', '["Сказати, де лежить річ", "Вживати u, na, ispod"]'::jsonb, 10, 'PUBLISHED', 2);

  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('ključ') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ključ'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 1, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('stol') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'stol'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 2, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('torba') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'torba'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 3, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('krevet') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'krevet'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 4, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ispod') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ispod'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 5, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('iznad') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'iznad'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 6, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('pored') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'pored'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 7, 'vocabulary');
  -- граматика
  select id into v_id from public.grammar_topics where cefr = 'A0' and title_ua = 'Де? Прийменники місця' order by created_at limit 1;
  if v_id is null then raise exception 'Немає граматичної теми «%»', 'Де? Прийменники місця'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_id, 8, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_id) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('125ef0f8-2394-503f-9bee-c68a178c6960', 'fill_in_the_blank', 'Ključevi su na ___. (стіл)', 'stolu', '["stola", "stolom", "stolu", "stol"]'::jsonb, 'A0', 1, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '125ef0f8-2394-503f-9bee-c68a178c6960', 9, 'reading');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('addbfe57-5d94-5b00-bbd1-a60050ed3276', 'sentence_builder', 'Складіть: «Ось вони!»', 'Evo ih!', '["ih!", "Evo"]'::jsonb, 'A0', 2, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'addbfe57-5d94-5b00-bbd1-a60050ed3276', 10, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('76724ac7-8f1f-5955-a0df-a4f1ac5c85aa', 'listening', 'Прослухайте і складіть фразу', 'Ključevi su u torbi.', '["Ključevi", "su", "torbi.", "u"]'::jsonb, 'A0', 3, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '76724ac7-8f1f-5955-a0df-a4f1ac5c85aa', 11, 'listening');
  -- діалог
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('41b58b3c-a8ec-54ee-bfdf-6bf4c2ae48d6', v_lesson, 'Ранок удома', 'Jutro kod kuće', 17, 'A0', 'housing', 'PUBLISHED', 'claude_curriculum_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('eb1dc9ba-6e78-590b-816d-a4f2d671ec58', '41b58b3c-a8ec-54ee-bfdf-6bf4c2ae48d6', 'Maja', 'Gdje su moji ključevi?', 'Де мої ключі?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('0fc7be69-a40d-5910-a604-dc0ad2d69a34', '41b58b3c-a8ec-54ee-bfdf-6bf4c2ae48d6', 'Luka', 'Na stolu.', 'На столі.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('c993425c-a4ba-5c3f-a5da-866733585ee2', '41b58b3c-a8ec-54ee-bfdf-6bf4c2ae48d6', 'Maja', 'Nisu na stolu.', 'На столі їх немає.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('bd19581b-ee59-5ce2-92fb-02f14959eaa8', '41b58b3c-a8ec-54ee-bfdf-6bf4c2ae48d6', 'Luka', 'Možda su u torbi ili ispod kreveta.', 'Може, вони в сумці або під ліжком.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('7ce98c90-c9ed-53ab-8a09-17e31e21caa0', '41b58b3c-a8ec-54ee-bfdf-6bf4c2ae48d6', 'Maja', 'Evo ih! U torbi su.', 'Ось вони! У сумці.', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.');
end $$;

-- A0.6 · урок 18: Що є в кімнаті?
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '1436c20e-0aea-550a-b66d-fb3149a1c2e2';
  v_id uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 6 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.6'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise notice 'A0.6: місце уроку 3 вже зайняте — пропускаю'; return;
  end if;

  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 18: Що є в кімнаті?', 'Lekcija 18: Što ima u sobi?', '["Назвати меблі", "Сказати, що є і чого немає"]'::jsonb, 10, 'PUBLISHED', 3);

  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('krevet') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'krevet'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 1, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('stol') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'stol'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 2, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('stolica') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'stolica'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 3, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ormar') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ormar'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 4, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kauč') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kauč'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 5, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('slika') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'slika'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 6, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('televizor') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'televizor'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 7, 'vocabulary');
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('3240ccc6-f2c0-55da-ae16-679883bcd86d', 'fill_in_the_blank', 'Slika je iznad ___. (ліжко)', 'kreveta', '["krevet", "krevetom", "kreveta", "krevetu"]'::jsonb, 'A0', 1, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '3240ccc6-f2c0-55da-ae16-679883bcd86d', 8, 'reading');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('2869b5df-bfe8-5dae-a2bb-f809bfb99dca', 'sentence_builder', 'Складіть: «Що є у твоїй кімнаті?»', 'Što ima u tvojoj sobi?', '["sobi?", "u", "tvojoj", "Što", "ima"]'::jsonb, 'A0', 2, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2869b5df-bfe8-5dae-a2bb-f809bfb99dca', 9, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('c4015020-3e13-55b9-a0ff-bbff0ad73a65', 'listening', 'Прослухайте і складіть фразу', 'Imam krevet i stol.', '["stol.", "Imam", "krevet", "i"]'::jsonb, 'A0', 3, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'c4015020-3e13-55b9-a0ff-bbff0ad73a65', 10, 'listening');
  -- діалог
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('e64be160-c99b-570a-be4b-d89966969aaa', v_lesson, 'Нова кімната', 'Nova soba', 18, 'A0', 'housing', 'PUBLISHED', 'claude_curriculum_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('1c89d4ee-f935-504f-bc87-519bad6a4852', 'e64be160-c99b-570a-be4b-d89966969aaa', 'Ana', 'Što ima u tvojoj sobi?', 'Що є у твоїй кімнаті?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('72da87cb-65a5-5b23-97a7-5fd223441959', 'e64be160-c99b-570a-be4b-d89966969aaa', 'Ivan', 'Krevet, stol, stolica i ormar.', 'Ліжко, стіл, стілець і шафа.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('5beb4f29-22b9-5f71-94eb-a5ab96c03595', 'e64be160-c99b-570a-be4b-d89966969aaa', 'Ana', 'Imaš li i televizor?', 'А телевізор є?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('256d4b52-f921-55fc-a075-b14807bfad2a', 'e64be160-c99b-570a-be4b-d89966969aaa', 'Ivan', 'Nemam. Imam laptop.', 'Немає. У мене є ноутбук.', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.');
end $$;

-- A0.7 · урок 19: Я голодний
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '7bbaf7ff-10bb-512a-91c5-798b59ec92a5';
  v_id uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 7 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.7'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise notice 'A0.7: місце уроку 1 вже зайняте — пропускаю'; return;
  end if;

  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 19: Я голодний', 'Lekcija 19: Gladan sam', '["Сказати «я голодний / хочу пити»", "Сказати, що у вас є"]'::jsonb, 10, 'PUBLISHED', 1);

  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('gladan') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'gladan'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 1, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('žedan') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'žedan'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 2, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('hrana') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'hrana'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 3, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('kruh') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kruh'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 4, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('sir') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'sir'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 5, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('jabuka') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'jabuka'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 6, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('voda') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'voda'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 7, 'vocabulary');
  -- граматика
  select id into v_id from public.grammar_topics where cefr = 'A0' and title_ua = 'Дієслово «imati» (мати)' order by created_at limit 1;
  if v_id is null then raise exception 'Немає граматичної теми «%»', 'Дієслово «imati» (мати)'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_id, 8, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_id) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('62fa27a2-966d-5a27-833f-646ff5e9e7d6', 'fill_in_the_blank', 'Ja ___ kruh i sir.', 'imam', '["imaju", "imam", "ima", "imamo"]'::jsonb, 'A0', 1, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '62fa27a2-966d-5a27-833f-646ff5e9e7d6', 9, 'reading');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('84a6030a-aacb-5abc-a224-9b9693b1a054', 'sentence_builder', 'Складіть: «Я дуже голодний.»', 'Jako sam gladan.', '["sam", "Jako", "gladan."]'::jsonb, 'A0', 2, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '84a6030a-aacb-5abc-a224-9b9693b1a054', 10, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('a632ab7a-99ca-500e-89b3-59e0013ab6e7', 'listening', 'Прослухайте і складіть фразу', 'Imam kruh i sir.', '["kruh", "sir.", "i", "Imam"]'::jsonb, 'A0', 3, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a632ab7a-99ca-500e-89b3-59e0013ab6e7', 11, 'listening');
  -- діалог
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('1c37edf0-8226-5d3b-8056-7210525510bd', v_lesson, 'Удома', 'Kod kuće', 19, 'A0', 'basics', 'PUBLISHED', 'claude_curriculum_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('762af042-170d-59be-b262-f0c823062e3c', '1c37edf0-8226-5d3b-8056-7210525510bd', 'Maja', 'Gladan si?', 'Ти голодний?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('145e5155-0aee-54f7-a9b0-8026f776464e', '1c37edf0-8226-5d3b-8056-7210525510bd', 'Ivan', 'Da, jako sam gladan. I žedan.', 'Так, я дуже голодний. І хочу пити.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('f046b13e-a463-5f26-9471-200d01423200', '1c37edf0-8226-5d3b-8056-7210525510bd', 'Maja', 'Imam kruh, sir i jabuke.', 'У мене є хліб, сир і яблука.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('4afc6ed5-3dbb-5514-b996-e309aac33e83', '1c37edf0-8226-5d3b-8056-7210525510bd', 'Ivan', 'Super, hvala!', 'Супер, дякую!', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.');
end $$;

-- A0.7 · урок 20: У кафе
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'c9e045fb-91ff-52a2-9916-1b698d30eb19';
  v_id uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 7 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.7'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise notice 'A0.7: місце уроку 2 вже зайняте — пропускаю'; return;
  end if;

  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 20: У кафе', 'Lekcija 20: U kafiću', '["Замовити напій", "Відповісти на «Ще щось?»"]'::jsonb, 10, 'PUBLISHED', 2);

  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('kava') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kava'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 1, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('s mlijekom') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 's mlijekom'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 2, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('mlijeko') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'mlijeko'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 3, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('voda bez plina') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'voda bez plina'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 4, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('jelovnik') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'jelovnik'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 5, 'vocabulary');
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('2943853d-a1fe-55cd-a706-43d34297f0ea', 'fill_in_the_blank', 'Kavu s ___, molim.', 'mlijekom', '["mlijeka", "mlijeku", "mlijekom", "mlijeko"]'::jsonb, 'A0', 1, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2943853d-a1fe-55cd-a706-43d34297f0ea', 6, 'reading');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('83cb6d3c-26ef-54df-9e61-6def5854f322', 'sentence_builder', 'Складіть: «Каву з молоком, будь ласка.»', 'Kavu s mlijekom, molim.', '["Kavu", "molim.", "mlijekom,", "s"]'::jsonb, 'A0', 2, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '83cb6d3c-26ef-54df-9e61-6def5854f322', 7, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('a8c14b74-fd80-595b-830b-9d8276fe5950', 'listening', 'Прослухайте і складіть фразу', 'Vodu bez plina, molim.', '["bez", "molim.", "Vodu", "plina,"]'::jsonb, 'A0', 3, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a8c14b74-fd80-595b-830b-9d8276fe5950', 8, 'listening');
  -- діалог
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('b2969a7a-9762-51f4-9622-3ff6732adb89', v_lesson, 'Замовлення', 'Narudžba', 20, 'A0', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('92c41ea7-b68b-5036-938b-4ff1ca2a5853', 'b2969a7a-9762-51f4-9622-3ff6732adb89', 'Konobar', 'Dobar dan! Izvolite?', 'Добрий день! Що бажаєте?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('0f981db9-34f0-556e-839a-c71d042ed837', 'b2969a7a-9762-51f4-9622-3ff6732adb89', 'Gost', 'Kavu s mlijekom, molim.', 'Каву з молоком, будь ласка.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('4960b829-5876-553e-ac73-95cacf39d99d', 'b2969a7a-9762-51f4-9622-3ff6732adb89', 'Konobar', 'Još nešto?', 'Ще щось?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('e275c352-4ebb-50bd-b3a8-c86589423f68', 'b2969a7a-9762-51f4-9622-3ff6732adb89', 'Gost', 'I vodu bez plina.', 'І воду без газу.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('23c95fdf-8728-57ca-b932-6f551c135377', 'b2969a7a-9762-51f4-9622-3ff6732adb89', 'Konobar', 'Odmah.', 'Зараз.', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.');
end $$;

-- A0.7 · урок 21: Рахунок, будь ласка
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '8b30911e-4e57-5648-9ff6-bd11c1b0e27e';
  v_id uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 7 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.7'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise notice 'A0.7: місце уроку 3 вже зайняте — пропускаю'; return;
  end if;

  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 21: Рахунок, будь ласка', 'Lekcija 21: Račun, molim', '["Попросити рахунок", "Заплатити карткою", "Подякувати за їжу"]'::jsonb, 10, 'PUBLISHED', 3);

  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('račun') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'račun'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 1, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('molim račun') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'molim račun'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 2, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('mogu li platiti karticom') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'mogu li platiti karticom'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 3, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('naravno') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'naravno'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 4, 'vocabulary');
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('eae12d80-c5a6-5a6f-aea6-2ea8f05c3b90', 'fill_in_the_blank', 'Mogu li platiti ___?', 'karticom', '["kartica", "karticom", "karticu", "kartice"]'::jsonb, 'A0', 1, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'eae12d80-c5a6-5a6f-aea6-2ea8f05c3b90', 5, 'reading');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('13beb00c-925f-54c7-b68d-b46b05ab3016', 'sentence_builder', 'Складіть: «Було дуже смачно!»', 'Bilo je jako ukusno!', '["je", "jako", "ukusno!", "Bilo"]'::jsonb, 'A0', 2, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '13beb00c-925f-54c7-b68d-b46b05ab3016', 6, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('e9e6856b-dedc-5977-928e-f587ec04c10c', 'listening', 'Прослухайте і складіть фразу', 'Mogu li platiti karticom?', '["karticom?", "platiti", "Mogu", "li"]'::jsonb, 'A0', 3, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'e9e6856b-dedc-5977-928e-f587ec04c10c', 7, 'listening');
  -- діалог
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('e65c8abe-a449-58b7-a281-7f4a3ffcc680', v_lesson, 'Наприкінці обіду', 'Na kraju ručka', 21, 'A0', 'cafe_restaurant', 'PUBLISHED', 'claude_curriculum_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('e47c08b2-7438-5bb8-a452-04cb0dff0ac2', 'e65c8abe-a449-58b7-a281-7f4a3ffcc680', 'Gost', 'Molim vas, račun.', 'Рахунок, будь ласка.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('d45d87fa-2475-5a08-b922-7510ce63e358', 'e65c8abe-a449-58b7-a281-7f4a3ffcc680', 'Konobarica', 'Izvolite. Petnaest eura.', 'Прошу. П’ятнадцять євро.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('47c1d727-8681-53f6-ac3a-5796cf1dac53', 'e65c8abe-a449-58b7-a281-7f4a3ffcc680', 'Gost', 'Mogu li platiti karticom?', 'Можна заплатити карткою?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('048592f2-eb70-5761-ac62-abe875814740', 'e65c8abe-a449-58b7-a281-7f4a3ffcc680', 'Konobarica', 'Naravno.', 'Звісно.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('151a9292-e520-5bf4-838e-97e63eaa9a5a', 'e65c8abe-a449-58b7-a281-7f4a3ffcc680', 'Gost', 'Hvala. Bilo je jako ukusno!', 'Дякую. Було дуже смачно!', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.');
end $$;

-- A0.8 · урок 22: На ринку
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'e495a4dd-a963-5a5f-af8c-09b2ea6a2ea0';
  v_id uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 8 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.8'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise notice 'A0.8: місце уроку 1 вже зайняте — пропускаю'; return;
  end if;

  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 22: На ринку', 'Lekcija 22: Na tržnici', '["Купити фрукти й овочі", "Назвати кількість"]'::jsonb, 10, 'PUBLISHED', 1);

  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('voće') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'voće'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 1, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('povrće') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'povrće'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 2, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('jabuka') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'jabuka'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 3, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('rajčica') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'rajčica'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 4, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('cijena') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'cijena'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 5, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('koliko to košta') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'koliko to košta'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 6, 'vocabulary');
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('322e6951-e54a-5810-98e1-73e0dae800e3', 'fill_in_the_blank', 'Kilu ___, molim. (яблука)', 'jabuka', '["jabuke", "jabuku", "jabukom", "jabuka"]'::jsonb, 'A0', 1, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '322e6951-e54a-5810-98e1-73e0dae800e3', 7, 'reading');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('01524167-db8e-5c12-ae58-a567b3507839', 'sentence_builder', 'Складіть: «Ще щось?»', 'Još nešto?', '["nešto?", "Još"]'::jsonb, 'A0', 2, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '01524167-db8e-5c12-ae58-a567b3507839', 8, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('053a7df4-397d-588b-b800-3b8a3fd2f908', 'listening', 'Прослухайте і складіть фразу', 'Pola kile rajčica, molim.', '["rajčica,", "Pola", "kile", "molim."]'::jsonb, 'A0', 3, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '053a7df4-397d-588b-b800-3b8a3fd2f908', 9, 'listening');
  -- діалог
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('0e508f4d-1f4f-5243-b026-f67bdcf493c7', v_lesson, 'Овочі й фрукти', 'Voće i povrće', 22, 'A0', 'shopping', 'PUBLISHED', 'claude_curriculum_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('9549e53c-740e-55f4-909c-1c2bf7934282', '0e508f4d-1f4f-5243-b026-f67bdcf493c7', 'Prodavačica', 'Izvolite!', 'Прошу!', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('502e1097-52c5-5c49-8ece-1bd6c079cfdd', '0e508f4d-1f4f-5243-b026-f67bdcf493c7', 'Kupac', 'Kilu jabuka, molim.', 'Кілограм яблук, будь ласка.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('07923bce-48dc-5d49-8d53-47175dbc5160', '0e508f4d-1f4f-5243-b026-f67bdcf493c7', 'Prodavačica', 'Još nešto?', 'Ще щось?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('471ac038-bfbb-5dba-aa74-152f3f8a8de0', '0e508f4d-1f4f-5243-b026-f67bdcf493c7', 'Kupac', 'Pola kile rajčica.', 'Пів кілограма помідорів.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('cbf9b83d-ba10-5f37-bcb8-a818da150aa7', '0e508f4d-1f4f-5243-b026-f67bdcf493c7', 'Prodavačica', 'Tri eura, molim.', 'Три євро, будь ласка.', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.');
end $$;

-- A0.8 · урок 23: Скільки коштує ця футболка?
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'b01e2f67-3e7a-5ab6-99bb-fae374f431e0';
  v_id uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 8 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.8'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise notice 'A0.8: місце уроку 2 вже зайняте — пропускаю'; return;
  end if;

  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 23: Скільки коштує ця футболка?', 'Lekcija 23: Koliko košta ova majica?', '["Запитати ціну речі", "Вибрати: ця, та, он та"]'::jsonb, 10, 'PUBLISHED', 2);

  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('majica') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'majica'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 1, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('plav') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'plav'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 2, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('popust') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'popust'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 3, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('koštati') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'koštati'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 4, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ovaj') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ovaj'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 5, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('taj') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'taj'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 6, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('onaj') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'onaj'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 7, 'vocabulary');
  -- граматика
  select id into v_id from public.grammar_topics where cefr = 'A0' and title_ua = 'Цей, той, он той: ovaj, taj, onaj' order by created_at limit 1;
  if v_id is null then raise exception 'Немає граматичної теми «%»', 'Цей, той, он той: ovaj, taj, onaj'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_id, 8, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_id) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('1606e01d-6aeb-5adb-837d-5a99ee68785e', 'fill_in_the_blank', '___ majica košta deset eura. (ця, біля мене)', 'Ova', '["Ova", "Ovaj", "Ovi", "Ovo"]'::jsonb, 'A0', 1, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '1606e01d-6aeb-5adb-837d-5a99ee68785e', 9, 'reading');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('8ef916d6-bc2a-51da-bac9-eb6e9600962a', 'sentence_builder', 'Складіть: «Скільки коштує ця футболка?»', 'Koliko košta ova majica?', '["Koliko", "košta", "majica?", "ova"]'::jsonb, 'A0', 2, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '8ef916d6-bc2a-51da-bac9-eb6e9600962a', 10, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('f3ffe2a3-9fb2-590d-af1b-d5c346a4cbf7', 'listening', 'Прослухайте і складіть фразу', 'Uzet ću plavu.', '["plavu.", "ću", "Uzet"]'::jsonb, 'A0', 3, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'f3ffe2a3-9fb2-590d-af1b-d5c346a4cbf7', 11, 'listening');
  -- діалог
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('36b23e7c-ba02-52b2-bb49-9caf2f98736a', v_lesson, 'У магазині одягу', 'U trgovini odjećom', 23, 'A0', 'shopping', 'PUBLISHED', 'claude_curriculum_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('e7a1f7ae-e4c8-5570-be30-a4f6800d3c57', '36b23e7c-ba02-52b2-bb49-9caf2f98736a', 'Kupac', 'Koliko košta ova majica?', 'Скільки коштує ця футболка?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('c20c8c9a-a21f-50e1-928c-e351e6d4753d', '36b23e7c-ba02-52b2-bb49-9caf2f98736a', 'Prodavač', 'Ta majica košta dvadeset eura.', 'Ця футболка коштує двадцять євро.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('a02936b1-2d5f-530f-bfa9-c1e6b447c0a1', '36b23e7c-ba02-52b2-bb49-9caf2f98736a', 'Kupac', 'A ona plava?', 'А он та синя?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('d39ae05f-56ee-51dd-81ca-afd1060295d3', '36b23e7c-ba02-52b2-bb49-9caf2f98736a', 'Prodavač', 'Ona je na popustu, deset eura.', 'Вона зі знижкою, десять євро.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('aeeb1f9e-56f6-517a-bd0e-a5b214db6f84', '36b23e7c-ba02-52b2-bb49-9caf2f98736a', 'Kupac', 'Uzet ću plavu.', 'Візьму синю.', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.');
end $$;

-- A0.8 · урок 24: На касі
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '28913ad6-490f-5d89-bad7-9b303c673fcd';
  v_id uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 8 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.8'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise notice 'A0.8: місце уроку 3 вже зайняте — пропускаю'; return;
  end if;

  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 24: На касі', 'Lekcija 24: Na blagajni', '["Відповісти про пакет", "Обрати готівку чи картку"]'::jsonb, 10, 'PUBLISHED', 3);

  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('vrećica') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'vrećica'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 1, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('karticom ili gotovinom') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'karticom ili gotovinom'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 2, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('blagajna') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'blagajna'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 3, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('euro') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'euro'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 4, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('cent') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'cent'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 5, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('doviđenja') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'doviđenja'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 6, 'vocabulary');
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('0533b219-324c-563f-80a7-03bdc05d5cc8', 'fill_in_the_blank', 'Trebate li ___? (пакет)', 'vrećicu', '["vrećice", "vrećicu", "vrećici", "vrećica"]'::jsonb, 'A0', 1, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '0533b219-324c-563f-80a7-03bdc05d5cc8', 7, 'reading');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('fdae5cac-1905-5951-b83a-643336b9eccc', 'sentence_builder', 'Складіть: «Готівкою чи карткою?»', 'Gotovinom ili karticom?', '["Gotovinom", "karticom?", "ili"]'::jsonb, 'A0', 2, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'fdae5cac-1905-5951-b83a-643336b9eccc', 8, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('2f72071c-1d7a-5319-8ef4-b2afe873c484', 'listening', 'Прослухайте і складіть фразу', 'Trebate li vrećicu?', '["li", "vrećicu?", "Trebate"]'::jsonb, 'A0', 3, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '2f72071c-1d7a-5319-8ef4-b2afe873c484', 9, 'listening');
  -- діалог
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('2e16cd99-b86e-59ab-ba44-f5d11e2f712b', v_lesson, 'У супермаркеті', 'U supermarketu', 24, 'A0', 'shopping', 'PUBLISHED', 'claude_curriculum_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('a254f8d2-e3ee-5c02-b632-0a6ffe0e006c', '2e16cd99-b86e-59ab-ba44-f5d11e2f712b', 'Blagajnica', 'Trebate li vrećicu?', 'Вам потрібен пакет?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('90d00f6a-b9d4-50c8-8c30-dc2124b8b28b', '2e16cd99-b86e-59ab-ba44-f5d11e2f712b', 'Kupac', 'Da, jednu, molim.', 'Так, один, будь ласка.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('0f123c7f-2410-5674-a407-2b4ce145247e', '2e16cd99-b86e-59ab-ba44-f5d11e2f712b', 'Blagajnica', 'Dvanaest eura i trideset centi. Gotovinom ili karticom?', 'Дванадцять євро тридцять центів. Готівкою чи карткою?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('a4ef8a40-1e62-5704-b358-9642d7505b0a', '2e16cd99-b86e-59ab-ba44-f5d11e2f712b', 'Kupac', 'Karticom.', 'Карткою.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('e4a2f09e-8470-5843-a8d9-2150c25e31b1', '2e16cd99-b86e-59ab-ba44-f5d11e2f712b', 'Blagajnica', 'Hvala, doviđenja!', 'Дякую, до побачення!', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.');
end $$;

-- A0.9 · урок 25: Де вокзал?
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'e0b9d742-0418-597b-9482-b6e2d82469da';
  v_id uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 9 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.9'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise notice 'A0.9: місце уроку 1 вже зайняте — пропускаю'; return;
  end if;

  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 25: Де вокзал?', 'Lekcija 25: Gdje je kolodvor?', '["Запитати дорогу", "Розуміти «прямо, ліворуч, праворуч»"]'::jsonb, 10, 'PUBLISHED', 1);

  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('kolodvor') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'kolodvor'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 1, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('ravno') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ravno'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 2, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('lijevo') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'lijevo'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 3, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('desno') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'desno'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 4, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('daleko') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'daleko'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 5, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('blizu') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'blizu'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 6, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('pješice') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'pješice'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 7, 'vocabulary');
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('9b5900d2-3fbd-51a9-8a6a-499b5f7739b6', 'fill_in_the_blank', 'Idite ___, pa lijevo. (прямо)', 'ravno', '["gore", "desno", "dolje", "ravno"]'::jsonb, 'A0', 1, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9b5900d2-3fbd-51a9-8a6a-499b5f7739b6', 8, 'reading');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('4fb970f4-6a04-5249-8d33-23b74dc63c74', 'sentence_builder', 'Складіть: «Це далеко?»', 'Je li daleko?', '["li", "daleko?", "Je"]'::jsonb, 'A0', 2, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '4fb970f4-6a04-5249-8d33-23b74dc63c74', 9, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('bff9ec21-22b7-58e4-a821-6e0f97c692ee', 'listening', 'Прослухайте і складіть фразу', 'Pet minuta pješice.', '["Pet", "pješice.", "minuta"]'::jsonb, 'A0', 3, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'bff9ec21-22b7-58e4-a821-6e0f97c692ee', 10, 'listening');
  -- діалог
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('d8f59b60-f893-5ffc-a262-ad6f69ec65a0', v_lesson, 'На вулиці', 'Na ulici', 25, 'A0', 'transport', 'PUBLISHED', 'claude_curriculum_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('7fcdf173-37cc-5793-9139-91a059478ee1', 'd8f59b60-f893-5ffc-a262-ad6f69ec65a0', 'Turistica', 'Oprostite, gdje je autobusni kolodvor?', 'Вибачте, де автовокзал?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('932c98e7-07b1-5959-a6f4-a04f138d065e', 'd8f59b60-f893-5ffc-a262-ad6f69ec65a0', 'Prolaznik', 'Idite ravno, pa lijevo.', 'Ідіть прямо, потім ліворуч.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('8fd8f717-5cc8-5076-a363-f14d27c27297', 'd8f59b60-f893-5ffc-a262-ad6f69ec65a0', 'Turistica', 'Je li daleko?', 'Це далеко?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('d6d89ec3-3600-5e45-b604-f6fbf4bfe9f7', 'd8f59b60-f893-5ffc-a262-ad6f69ec65a0', 'Prolaznik', 'Ne, blizu je. Pet minuta pješice.', 'Ні, близько. П’ять хвилин пішки.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('0811336b-1eb1-5941-bb65-6c74682ea5c3', 'd8f59b60-f893-5ffc-a262-ad6f69ec65a0', 'Turistica', 'Hvala lijepa!', 'Щиро дякую!', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.');
end $$;

-- A0.9 · урок 26: Старе місто
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := '1e0384e5-6097-56ed-ab56-cf530f02ab73';
  v_id uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 9 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.9'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise notice 'A0.9: місце уроку 2 вже зайняте — пропускаю'; return;
  end if;

  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 26: Старе місто', 'Lekcija 26: Stari grad', '["Описати місто простими прикметниками", "Узгоджувати прикметник з іменником"]'::jsonb, 10, 'PUBLISHED', 2);

  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('grad') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'grad'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 1, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('star') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'star'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 2, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('nov') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'nov'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 3, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('velik') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'velik'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 4, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('lijep') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'lijep'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 5, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('crkva') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'crkva'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 6, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('muzej') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'muzej'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 7, 'vocabulary');
  -- граматика
  select id into v_id from public.grammar_topics where cefr = 'A0' and title_ua = 'Прикметники: узгодження з іменником' order by created_at limit 1;
  if v_id is null then raise exception 'Немає граматичної теми «%»', 'Прикметники: узгодження з іменником'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_id, 8, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_id) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('4be37b09-e2c6-520f-a629-c0cac0c99394', 'fill_in_the_blank', 'Ovo je ___ crkva. (стара)', 'stara', '["stari", "staro", "stara", "stare"]'::jsonb, 'A0', 1, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '4be37b09-e2c6-520f-a629-c0cac0c99394', 9, 'reading');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('9b299673-8c6b-58fc-a794-089f047a61bc', 'sentence_builder', 'Складіть: «Ходімо в музей!»', 'Idemo u muzej!', '["u", "muzej!", "Idemo"]'::jsonb, 'A0', 2, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '9b299673-8c6b-58fc-a794-089f047a61bc', 10, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('d63f9f6e-718b-5433-b443-582b78cd839d', 'listening', 'Прослухайте і складіть фразу', 'Ovo je stari grad.', '["je", "stari", "grad.", "Ovo"]'::jsonb, 'A0', 3, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'd63f9f6e-718b-5433-b443-582b78cd839d', 11, 'listening');
  -- діалог
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('89296018-9840-51eb-867b-ad3b31f9d1f1', v_lesson, 'Прогулянка', 'Šetnja', 26, 'A0', 'travel', 'PUBLISHED', 'claude_curriculum_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('397d24c0-de42-52dc-8a81-8e3028815818', '89296018-9840-51eb-867b-ad3b31f9d1f1', 'Ana', 'Ovo je stari grad.', 'Це старе місто.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('cb9b5e49-87c3-535c-b196-49eade361bf2', '89296018-9840-51eb-867b-ad3b31f9d1f1', 'Oleg', 'Jako je lijep! Je li ova crkva stara?', 'Дуже гарне! Ця церква стара?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('b2884361-e63d-59c0-a0e3-a8f15273131b', '89296018-9840-51eb-867b-ad3b31f9d1f1', 'Ana', 'Da, jako stara. A ono je novi muzej.', 'Так, дуже стара. А он там — новий музей.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('31af100d-fd23-52dd-af49-68723c82ebdf', '89296018-9840-51eb-867b-ad3b31f9d1f1', 'Oleg', 'Super. Idemo u muzej!', 'Супер. Ходімо в музей!', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.');
end $$;

-- A0.9 · урок 27: Квиток на автобус
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'e5b81eb1-8ea8-5ff4-a987-e5e46421302b';
  v_id uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 9 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.9'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise notice 'A0.9: місце уроку 3 вже зайняте — пропускаю'; return;
  end if;

  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 27: Квиток на автобус', 'Lekcija 27: Karta za autobus', '["Купити квиток", "Запитати, коли й звідки автобус"]'::jsonb, 10, 'PUBLISHED', 3);

  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('karta') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'karta'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 1, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('karta u jednom smjeru') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'karta u jednom smjeru'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 2, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('jedan smjer') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'jedan smjer'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 3, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('autobus') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'autobus'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 4, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('peron') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'peron'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 5, 'vocabulary');
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('51baf11f-2975-5571-a6b6-f1a9d8ac629e', 'fill_in_the_blank', 'Jednu ___ za Split, molim.', 'kartu', '["karte", "kartu", "karti", "karta"]'::jsonb, 'A0', 1, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '51baf11f-2975-5571-a6b6-f1a9d8ac629e', 6, 'reading');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('4e245420-1d29-52cc-93e4-8db54d795b7c', 'sentence_builder', 'Складіть: «Коли їде автобус?»', 'Kada ide autobus?', '["autobus?", "Kada", "ide"]'::jsonb, 'A0', 2, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '4e245420-1d29-52cc-93e4-8db54d795b7c', 7, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('4eaa6195-6db7-5e68-b49d-1b97142a3178', 'listening', 'Прослухайте і складіть фразу', 'Jednu kartu za Split, molim.', '["molim.", "za", "Jednu", "kartu", "Split,"]'::jsonb, 'A0', 3, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '4eaa6195-6db7-5e68-b49d-1b97142a3178', 8, 'listening');
  -- діалог
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('447c6ac3-9c29-50c9-a53c-37d1a9391a96', v_lesson, 'На автовокзалі', 'Na autobusnom kolodvoru', 27, 'A0', 'transport', 'PUBLISHED', 'claude_curriculum_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('0a340f3c-b2be-5e14-82f9-e81a3f6d0b34', '447c6ac3-9c29-50c9-a53c-37d1a9391a96', 'Putnik', 'Jednu kartu za Split, molim.', 'Один квиток до Спліта, будь ласка.', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('f8cb8fdf-cf91-5baa-8163-a4687c299e05', '447c6ac3-9c29-50c9-a53c-37d1a9391a96', 'Blagajnik', 'U jednom smjeru ili povratnu?', 'В один бік чи туди й назад?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('8536e264-5b2a-5d0f-9fc4-1686ac5eb461', '447c6ac3-9c29-50c9-a53c-37d1a9391a96', 'Putnik', 'U jednom smjeru. Kada ide autobus?', 'В один бік. Коли їде автобус?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('b58c3d0e-68a1-5a1b-9b6f-33e1cbfb27fa', '447c6ac3-9c29-50c9-a53c-37d1a9391a96', 'Blagajnik', 'U devet sati, s perona tri.', 'О дев’ятій, з платформи три.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('a7ea15b1-0d4d-5cd6-9cd7-ced255660ebd', '447c6ac3-9c29-50c9-a53c-37d1a9391a96', 'Putnik', 'Hvala!', 'Дякую!', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.');
end $$;

-- A0.10 · урок 28: Можете мені допомогти?
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'edbae9ca-c4f4-575d-b876-d50b0a1fd9b5';
  v_id uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 10 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.10'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise notice 'A0.10: місце уроку 1 вже зайняте — пропускаю'; return;
  end if;

  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 28: Можете мені допомогти?', 'Lekcija 28: Možete li mi pomoći?', '["Попросити допомоги", "Сказати, що ви заблукали"]'::jsonb, 10, 'PUBLISHED', 1);

  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('možete li mi pomoći') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'možete li mi pomoći'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 1, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('izgubio sam se') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'izgubio sam se'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 2, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('tražiti') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'tražiti'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 3, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('hotel') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'hotel'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 4, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('pomoći') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'pomoći'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 5, 'vocabulary');
  -- граматика
  select id into v_id from public.grammar_topics where cefr = 'A0' and title_ua = 'Питальні слова' order by created_at limit 1;
  if v_id is null then raise exception 'Немає граматичної теми «%»', 'Питальні слова'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_id, 6, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_id) on conflict do nothing;
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('80b99b7b-80f1-571b-ab38-2bd4f1a71037', 'fill_in_the_blank', '___ je hotel? (де)', 'Gdje', '["Gdje", "Kada", "Kamo", "Tko"]'::jsonb, 'A0', 1, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '80b99b7b-80f1-571b-ab38-2bd4f1a71037', 7, 'reading');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('a6d4fe3d-cab7-525a-aa15-9b700e699656', 'sentence_builder', 'Складіть: «Можете мені допомогти?»', 'Možete li mi pomoći?', '["mi", "Možete", "li", "pomoći?"]'::jsonb, 'A0', 2, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a6d4fe3d-cab7-525a-aa15-9b700e699656', 8, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('76f2b22f-f2ed-58c2-beea-4149a5373182', 'listening', 'Прослухайте і складіть фразу', 'Izgubio sam se.', '["se.", "Izgubio", "sam"]'::jsonb, 'A0', 3, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '76f2b22f-f2ed-58c2-beea-4149a5373182', 9, 'listening');
  -- діалог
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('a20e9d48-2272-5b70-bfcb-414dffe3bd68', v_lesson, 'Я заблукав', 'Izgubio sam se', 28, 'A0', 'transport', 'PUBLISHED', 'claude_curriculum_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('86ca2c03-8eaa-55aa-b5b6-93b8d91ba8d9', 'a20e9d48-2272-5b70-bfcb-414dffe3bd68', 'Oleg', 'Oprostite, možete li mi pomoći?', 'Вибачте, можете мені допомогти?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('28168a49-7824-51ef-a45c-959969431ca8', 'a20e9d48-2272-5b70-bfcb-414dffe3bd68', 'Policajac', 'Naravno. Što se dogodilo?', 'Звісно. Що сталося?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('9a57bd7c-5a47-5782-93b2-301bd331bdd6', 'a20e9d48-2272-5b70-bfcb-414dffe3bd68', 'Oleg', 'Izgubio sam se. Tražim hotel Central.', 'Я заблукав. Шукаю готель «Централ».', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('d8e2b108-3e08-56f2-a78b-22a0c9f122bf', 'a20e9d48-2272-5b70-bfcb-414dffe3bd68', 'Policajac', 'To je blizu. Idite desno pa ravno.', 'Це близько. Ідіть праворуч, а потім прямо.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('6c823074-eca3-56f5-9cd0-20b2c34d8e27', 'a20e9d48-2272-5b70-bfcb-414dffe3bd68', 'Oleg', 'Hvala vam puno!', 'Дуже вам дякую!', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.');
end $$;

-- A0.10 · урок 29: Викличте швидку!
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'fbc71f82-e715-5bab-a990-b8542fb0fe01';
  v_id uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 10 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.10'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise notice 'A0.10: місце уроку 2 вже зайняте — пропускаю'; return;
  end if;

  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 29: Викличте швидку!', 'Lekcija 29: Zovite hitnu!', '["Покликати на допомогу", "Викликати швидку чи поліцію"]'::jsonb, 10, 'PUBLISHED', 2);

  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('upomoć') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'upomoć'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 1, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('zovite hitnu') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'zovite hitnu'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 2, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('hitna') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'hitna'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 3, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('trebam pomoć') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'trebam pomoć'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 4, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('trebam doktora') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'trebam doktora'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 5, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('zovite policiju') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'zovite policiju'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 6, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('noga') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'noga'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 7, 'vocabulary');
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('bdc480a0-1704-5af4-b4cc-9093797b4d9e', 'fill_in_the_blank', 'Zovite ___! (швидку)', 'hitnu', '["hitnu", "hitne", "hitna", "hitnoj"]'::jsonb, 'A0', 1, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'bdc480a0-1704-5af4-b4cc-9093797b4d9e', 8, 'reading');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('1cd2b8bf-5d7c-5cb0-8d19-06f51f243d95', 'sentence_builder', 'Складіть: «Що сталося?»', 'Što se dogodilo?', '["dogodilo?", "se", "Što"]'::jsonb, 'A0', 2, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '1cd2b8bf-5d7c-5cb0-8d19-06f51f243d95', 9, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('effbfeb3-f749-5c51-99fe-3bf7f73b2cc0', 'listening', 'Прослухайте і складіть фразу', 'Trebam pomoć.', '["pomoć.", "Trebam"]'::jsonb, 'A0', 3, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'effbfeb3-f749-5c51-99fe-3bf7f73b2cc0', 10, 'listening');
  -- діалог
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('77a400bb-caaa-5bfe-9294-1b9f1403a1ab', v_lesson, 'На вулиці', 'Na ulici', 29, 'A0', 'health', 'PUBLISHED', 'claude_curriculum_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('645f1dbb-d554-5fb3-b288-1cc00099656b', '77a400bb-caaa-5bfe-9294-1b9f1403a1ab', 'Ana', 'Upomoć! Zovite hitnu!', 'Допоможіть! Викличте швидку!', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('9442a817-5fb0-5b15-bc84-bb5b87483f88', '77a400bb-caaa-5bfe-9294-1b9f1403a1ab', 'Prolaznik', 'Što se dogodilo?', 'Що сталося?', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('2bbce4b8-d2bc-5818-8fe5-27415e3539a4', '77a400bb-caaa-5bfe-9294-1b9f1403a1ab', 'Ana', 'Moj prijatelj je pao. Boli ga noga.', 'Мій друг упав. У нього болить нога.', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('82dad7d3-35e6-5020-ac2f-8c8ee12456c4', '77a400bb-caaa-5bfe-9294-1b9f1403a1ab', 'Prolaznik', 'Zovem 112.', 'Дзвоню на 112.', 4) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.');
end $$;

-- A0.10 · урок 30: Ваші документи
do $$
declare
  v_unit uuid;
  v_lesson constant uuid := 'b095637e-0644-507e-8f3d-d323483dd3e4';
  v_id uuid;
begin
  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id
   where m.level_code = 'A0' and m.order_index = 10 and u.order_index = 1;
  if v_unit is null then raise exception 'Немає юніта для модуля A0.10'; end if;
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise notice 'A0.10: місце уроку 3 вже зайняте — пропускаю'; return;
  end if;

  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A0', 'Урок 30: Ваші документи', 'Lekcija 30: Vaši dokumenti', '["Назвати ім’я, прізвище й адресу", "Розуміти прохання підписати"]'::jsonb, 10, 'PUBLISHED', 3);

  -- слова
  select id into v_id from public.lexemes where lower(lemma) = lower('ime') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'ime'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 1, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('prezime') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'prezime'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 2, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('adresa') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'adresa'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 3, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('putovnica') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'putovnica'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 4, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('potpisati') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'potpisati'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 5, 'vocabulary');
  select id into v_id from public.lexemes where lower(lemma) = lower('broj') and status = 'PUBLISHED';
  if v_id is null then raise exception 'Немає опублікованого слова «%»', 'broj'; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, 6, 'vocabulary');
  -- вправи
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('a34e81d3-8ae6-507f-98f8-dfb7c2c3e578', 'fill_in_the_blank', 'Imate li ___? (паспорт)', 'putovnicu', '["putovnica", "putovnicu", "putovnice", "putovnici"]'::jsonb, 'A0', 1, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a34e81d3-8ae6-507f-98f8-dfb7c2c3e578', 7, 'reading');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('a8e03b6c-cc54-513b-8090-4dd05e0df9ca', 'sentence_builder', 'Складіть: «Підпишіть тут, будь ласка.»', 'Potpišite ovdje, molim.', '["molim.", "ovdje,", "Potpišite"]'::jsonb, 'A0', 2, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', 'a8e03b6c-cc54-513b-8090-4dd05e0df9ca', 8, 'writing');
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  values ('8f545812-dd13-5c2d-bd32-9f3f9458a080', 'listening', 'Прослухайте і складіть фразу', 'Ovdje je moja adresa.', '["je", "adresa.", "moja", "Ovdje"]'::jsonb, 'A0', 3, 'PUBLISHED') on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', '8f545812-dd13-5c2d-bd32-9f3f9458a080', 9, 'listening');
  -- діалог
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('b58a8646-850b-51e9-967c-636904022627', v_lesson, 'В установі', 'U uredu', 30, 'A0', 'administration', 'PUBLISHED', 'claude_curriculum_v1') on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('ba743c1e-578f-5657-aefd-51465ed4932c', 'b58a8646-850b-51e9-967c-636904022627', 'Službenica', 'Dobar dan. Vaše ime i prezime?', 'Добрий день. Ваше ім’я та прізвище?', 1) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('d9dcb421-c255-5d16-b9f4-53d28b7fa2e5', 'b58a8646-850b-51e9-967c-636904022627', 'Oleg', 'Oleg Kovalenko.', 'Олег Коваленко.', 2) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('d27af9fc-678c-59c7-895f-1cf16e6e6263', 'b58a8646-850b-51e9-967c-636904022627', 'Službenica', 'Imate li putovnicu?', 'У вас є паспорт?', 3) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('30a76776-a218-56d1-8442-1fc5738280b2', 'b58a8646-850b-51e9-967c-636904022627', 'Oleg', 'Da, izvolite. Ovdje je i moja adresa.', 'Так, прошу. Ось і моя адреса.', 4) on conflict (id) do nothing;
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values ('2c8ca147-82a9-5476-9d97-6418e7348992', 'b58a8646-850b-51e9-967c-636904022627', 'Službenica', 'Hvala. Potpišite ovdje, molim.', 'Дякую. Підпишіть тут, будь ласка.', 5) on conflict (id) do nothing;
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.');
end $$;

-- 5. Каркас A1–B2: модулі й граматичні теми (DRAFT — користувачі їх не бачать)
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('329c44d2-afb3-5e9e-a04e-0ab31405ad9f', 'A1', 'Модуль A1.1 — Повсякденне життя', 'Modul A1.1 — Svakodnevni život', null, 1, 'DRAFT')
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('8d02296d-bc46-5537-9a9b-c678fe5ff1c9', 'A1', 'Модуль A1.2 — Їжа й ресторани', 'Modul A1.2 — Hrana i restorani', null, 2, 'DRAFT')
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('88e77a6f-1140-5f26-b724-0ae15477637a', 'A1', 'Модуль A1.3 — Покупки', 'Modul A1.3 — Kupovina', null, 3, 'DRAFT')
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('e092e4e7-b706-5e70-84b6-eaa665020394', 'A1', 'Модуль A1.4 — Транспорт', 'Modul A1.4 — Prijevoz', null, 4, 'DRAFT')
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('82ce9ca7-ea90-5413-94a6-d69b1a1cd72b', 'A1', 'Модуль A1.5 — Житло', 'Modul A1.5 — Stanovanje', null, 5, 'DRAFT')
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('03c65998-2648-5d02-9254-f67ce765fe27', 'A1', 'Модуль A1.6 — Робота', 'Modul A1.6 — Posao', null, 6, 'DRAFT')
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('e4b28ab0-2aa7-5d37-885b-6908dc14e17b', 'A1', 'Модуль A1.7 — Здоров’я', 'Modul A1.7 — Zdravlje', null, 7, 'DRAFT')
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('4fae6fe1-6bf2-5eef-9023-f7425b151c9e', 'A1', 'Модуль A1.8 — Соціальне життя', 'Modul A1.8 — Društveni život', null, 8, 'DRAFT')
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('4a99a045-1da4-5ac1-be05-74811dd7d630', 'A1', 'Модуль A1.9 — Хорватія', 'Modul A1.9 — Hrvatska', null, 9, 'DRAFT')
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('34064af4-9715-5f07-b87c-a5e28eb8127b', 'A1', 'Модуль A1.10 — Підсумок A1', 'Modul A1.10 — Ponavljanje i provjera A1', null, 10, 'DRAFT')
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('38b2ee69-f7d3-5de2-8208-b1fa31501558', 'A2', 'Модуль A2.1 — Досвід', 'Modul A2.1 — Iskustva', null, 1, 'DRAFT')
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('2cfdcacf-767e-5f3f-bb15-9b245bd598c9', 'A2', 'Модуль A2.2 — Подорожі', 'Modul A2.2 — Putovanja', null, 2, 'DRAFT')
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('aa10630b-c7e4-5d3a-b3dc-739e9eea9e06', 'A2', 'Модуль A2.3 — Робота', 'Modul A2.3 — Posao', null, 3, 'DRAFT')
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('f811eff6-8d8a-5fac-8ae7-6b78020976f1', 'A2', 'Модуль A2.4 — Установи й документи', 'Modul A2.4 — Uredi i dokumenti', null, 4, 'DRAFT')
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('d66361ac-89bc-5021-99ad-c3f61c71145c', 'A2', 'Модуль A2.5 — Здоров’я', 'Modul A2.5 — Zdravlje', null, 5, 'DRAFT')
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('8fad33b4-f461-5119-b5e5-f94b700e283c', 'A2', 'Модуль A2.6 — Стосунки', 'Modul A2.6 — Odnosi', null, 6, 'DRAFT')
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('a198575a-bafc-51b5-b325-95aa7d6c9d8a', 'A2', 'Модуль A2.7 — Проблеми', 'Modul A2.7 — Problemi', null, 7, 'DRAFT')
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('47c98d89-5811-5425-af88-26e8249d361b', 'A2', 'Модуль A2.8 — Плани', 'Modul A2.8 — Planovi', null, 8, 'DRAFT')
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('285d2a27-68a4-5302-afc3-9595d071647a', 'A2', 'Модуль A2.9 — Думки', 'Modul A2.9 — Mišljenja', null, 9, 'DRAFT')
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('a22f1345-0879-5cde-ad47-4a76556dcf7e', 'A2', 'Модуль A2.10 — Підсумок A2', 'Modul A2.10 — Ponavljanje i provjera A2', null, 10, 'DRAFT')
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('53b6c6b2-1604-5136-a718-05fbbf94d99d', 'B1', 'Модуль B1.1 — Особисте життя', 'Modul B1.1 — Osobni život', null, 1, 'DRAFT')
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('461a1f78-6455-58c9-870d-82a0b1c69526', 'B1', 'Модуль B1.2 — Кар’єра', 'Modul B1.2 — Karijera', null, 2, 'DRAFT')
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('1a118e11-c8c3-5fc2-be05-363010e27140', 'B1', 'Модуль B1.3 — Суспільство', 'Modul B1.3 — Društvo', null, 3, 'DRAFT')
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('be39aff7-b84b-5567-b663-8ec420da7564', 'B1', 'Модуль B1.4 — Медіа', 'Modul B1.4 — Mediji', null, 4, 'DRAFT')
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('8545e8cb-4736-59c6-9992-a27cdc7b2d13', 'B1', 'Модуль B1.5 — Культура', 'Modul B1.5 — Kultura', null, 5, 'DRAFT')
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('c01245e4-edd6-55e9-83e0-89a24c48cbda', 'B1', 'Модуль B1.6 — Здоров’я', 'Modul B1.6 — Zdravlje', null, 6, 'DRAFT')
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('a107139b-5555-5946-ba84-d4c392b9e258', 'B1', 'Модуль B1.7 — Довкілля', 'Modul B1.7 — Okoliš', null, 7, 'DRAFT')
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('b046b17d-233f-5d00-a522-f99d03e334e4', 'B1', 'Модуль B1.8 — Стосунки', 'Modul B1.8 — Odnosi', null, 8, 'DRAFT')
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('1a59f32d-1286-5d67-91c4-6f2b79e10f52', 'B1', 'Модуль B1.9 — Дискусія', 'Modul B1.9 — Rasprava', null, 9, 'DRAFT')
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('27546586-5001-571f-a4d3-63bd81a8a10f', 'B1', 'Модуль B1.10 — Підсумок B1', 'Modul B1.10 — Ponavljanje i provjera B1', null, 10, 'DRAFT')
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('8cec4dd3-8af1-5197-847f-0117dba11752', 'B2', 'Модуль B2.1 — Складна комунікація', 'Modul B2.1 — Složena komunikacija', null, 1, 'DRAFT')
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('be37cfb4-9e0d-54f0-b538-f4873d3ebf26', 'B2', 'Модуль B2.2 — Професійна хорватська', 'Modul B2.2 — Poslovni hrvatski', null, 2, 'DRAFT')
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('cb222831-17b4-5ac8-8eb0-6077ffcc66d7', 'B2', 'Модуль B2.3 — Суспільство', 'Modul B2.3 — Društvo', null, 3, 'DRAFT')
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('4c1bff72-daee-554b-afcd-91eff2362f9e', 'B2', 'Модуль B2.4 — Політика як мовна тема', 'Modul B2.4 — Politika kao jezična tema', null, 4, 'DRAFT')
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('4a3ac50e-2c88-59ab-8649-9c8307d423d3', 'B2', 'Модуль B2.5 — Економіка', 'Modul B2.5 — Gospodarstvo', null, 5, 'DRAFT')
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('3d8f56ef-2145-5206-9cd9-d154ac1095a3', 'B2', 'Модуль B2.6 — Медіа', 'Modul B2.6 — Mediji', null, 6, 'DRAFT')
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('bffd1cdb-7e66-5aa6-ab34-41b42840d79e', 'B2', 'Модуль B2.7 — Культура', 'Modul B2.7 — Kultura', null, 7, 'DRAFT')
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('f79689d4-73d6-5449-9cf5-c3099ca745ef', 'B2', 'Модуль B2.8 — Наука й технології', 'Modul B2.8 — Znanost i tehnologija', null, 8, 'DRAFT')
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('ef91a0de-ce73-55d1-9993-1634dba5540c', 'B2', 'Модуль B2.9 — Абстрактні теми', 'Modul B2.9 — Apstraktne teme', null, 9, 'DRAFT')
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('6e837a1b-98d6-5d43-96d3-d17036c3c245', 'B2', 'Модуль B2.10 — Аргументація', 'Modul B2.10 — Argumentacija', null, 10, 'DRAFT')
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('edb56aa9-3668-5873-a0cc-5618970e01b2', 'B2', 'Модуль B2.11 — Переговори', 'Modul B2.11 — Pregovaranje', null, 11, 'DRAFT')
on conflict do nothing;
insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
values ('c93968ca-5aa2-5e76-a93a-e5a8dc3641ad', 'B2', 'Модуль B2.12 — Підсумок B2', 'Modul B2.12 — Ponavljanje i provjera B2', null, 12, 'DRAFT')
on conflict do nothing;
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '387f7bea-839e-56ae-bbfd-213aacbe7c26', 'A1', 'Теперішній час', 'Prezent', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'A1' and title_ua = 'Теперішній час');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '318b394b-c622-5dd6-8494-4c1472b6df62', 'A1', 'Правильні дієслова', 'Pravilni glagoli', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'A1' and title_ua = 'Правильні дієслова');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '6ba7fa0f-46cc-5679-85bb-23c1329bfa18', 'A1', 'Часті неправильні дієслова', 'Česti nepravilni glagoli', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'A1' and title_ua = 'Часті неправильні дієслова');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '0db658cb-b2ed-5719-bced-f95a93cf15ce', 'A1', 'Знахідний відмінок', 'Akuzativ', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'A1' and title_ua = 'Знахідний відмінок');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select 'f891e65a-d7be-5542-ae6e-dbee5bfe415c', 'A1', 'Місцевий відмінок', 'Lokativ', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'A1' and title_ua = 'Місцевий відмінок');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select 'd27ae527-a8d6-512f-acd2-a6cfec39c01f', 'A1', 'Родовий відмінок: основи', 'Genitiv: osnove', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'A1' and title_ua = 'Родовий відмінок: основи');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '94ab9b5e-95b0-5edb-8322-52293bdb5d05', 'A1', 'Присвійні займенники', 'Posvojne zamjenice', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'A1' and title_ua = 'Присвійні займенники');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '61247c65-c284-51c5-a9ed-1626afbd77ac', 'A1', 'Модальні дієслова', 'Modalni glagoli', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'A1' and title_ua = 'Модальні дієслова');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '45c5cb39-daf7-5dab-8413-9a5302b33553', 'A1', 'Наказовий спосіб', 'Imperativ', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'A1' and title_ua = 'Наказовий спосіб');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select 'b58103b4-a259-5384-aa65-ffc0e2a195c8', 'A1', 'Ступені порівняння', 'Komparacija pridjeva', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'A1' and title_ua = 'Ступені порівняння');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '1435d343-6721-5eb7-8dc2-af7f9a027716', 'A1', 'Побудова питань', 'Upitne rečenice', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'A1' and title_ua = 'Побудова питань');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select 'b89a9004-2c03-567a-b23e-31db18f92dea', 'A1', 'Заперечення', 'Nijekanje', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'A1' and title_ua = 'Заперечення');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '765ac66f-d54b-505b-9b11-c48e5ad26018', 'A1', 'Сполучники', 'Veznici', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'A1' and title_ua = 'Сполучники');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select 'feaaa674-66e6-5521-ba6e-b5d1507cd351', 'A2', 'Минулий час (perfekt)', 'Perfekt', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'A2' and title_ua = 'Минулий час (perfekt)');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '17b75bc6-fca0-5f09-830c-ab7f37279022', 'A2', 'Майбутній час', 'Futur I.', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'A2' and title_ua = 'Майбутній час');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '78491f05-4871-51e6-aa8e-7f81fe2f6099', 'A2', 'Давальний відмінок', 'Dativ', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'A2' and title_ua = 'Давальний відмінок');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select 'd777c847-266e-57ef-a5a2-f417f12f1b3e', 'A2', 'Орудний відмінок', 'Instrumental', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'A2' and title_ua = 'Орудний відмінок');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select 'b7103d09-8e69-53f7-8f17-a90c771fa1a2', 'A2', 'Родовий відмінок: розширення', 'Genitiv: proširenje', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'A2' and title_ua = 'Родовий відмінок: розширення');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '0b2de584-05a6-5570-a129-366fcb94766d', 'A2', 'Вид дієслова', 'Glagolski vid', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'A2' and title_ua = 'Вид дієслова');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '4101ee05-3efe-5a98-a9e5-f0f327436268', 'A2', 'Зворотні дієслова', 'Povratni glagoli', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'A2' and title_ua = 'Зворотні дієслова');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '59c6c708-59b5-5781-bf5d-4ecd5aa8b7dc', 'A2', 'Підрядні речення', 'Zavisne rečenice', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'A2' and title_ua = 'Підрядні речення');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '0c68352a-803a-5410-a59b-91f2c1ddc49f', 'A2', 'Умовний спосіб', 'Kondicional I.', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'A2' and title_ua = 'Умовний спосіб');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '926638d7-1396-512e-8a05-065c4464b85a', 'A2', 'Порівняльні конструкції', 'Poredbene konstrukcije', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'A2' and title_ua = 'Порівняльні конструкції');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '2d4021eb-fd3e-5388-a44b-3f541c5990f8', 'A2', 'Займенники: повні й короткі форми', 'Zamjenice: naglašeni i nenaglašeni oblici', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'A2' and title_ua = 'Займенники: повні й короткі форми');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select 'fdf834b3-cd8d-559e-be08-4be5ad2483d9', 'B1', 'Складні підрядні речення', 'Složene zavisne rečenice', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'B1' and title_ua = 'Складні підрядні речення');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '4105c55a-751b-5ae0-bda4-d177bc399626', 'B1', 'Означальні речення', 'Odnosne rečenice', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'B1' and title_ua = 'Означальні речення');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select 'dcd304bf-15d6-5dfe-a870-25624a93cc4e', 'B1', 'Вид дієслова: нюанси', 'Glagolski vid: nijanse', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'B1' and title_ua = 'Вид дієслова: нюанси');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select 'c53ee5f0-c7a0-5172-b7b6-b6fa2364163b', 'B1', 'Умовний спосіб II', 'Kondicional II.', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'B1' and title_ua = 'Умовний спосіб II');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select 'db3342ab-4071-5d6a-b65b-8cd877aad95f', 'B1', 'Пасив', 'Pasiv', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'B1' and title_ua = 'Пасив');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select 'f0985746-784e-5188-9e52-f57d61047f36', 'B1', 'Непряма мова', 'Neupravni govor', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'B1' and title_ua = 'Непряма мова');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '41acab0a-5a84-5a58-9f96-d1adf54e4f4f', 'B1', 'Сполучні слова в тексті', 'Diskursni veznici', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'B1' and title_ua = 'Сполучні слова в тексті');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '770e71d6-9597-59d6-8a0f-b5a189b36962', 'B1', 'Складні прийменникові конструкції', 'Složeni prijedložni izrazi', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'B1' and title_ua = 'Складні прийменникові конструкції');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '62aa271b-9548-52f2-aa6a-01845b5edd97', 'B1', 'Дієприслівники', 'Glagolski prilozi', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'B1' and title_ua = 'Дієприслівники');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select 'bb933735-69ac-5e32-8100-468ea1f17b9d', 'B1', 'Офіційний і розмовний стиль', 'Formalni i neformalni stil', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'B1' and title_ua = 'Офіційний і розмовний стиль');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select 'b414c5cf-26a7-556f-a8fc-0d66a1a63e9c', 'B2', 'Вид дієслова: складні випадки', 'Glagolski vid: složeni slučajevi', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'B2' and title_ua = 'Вид дієслова: складні випадки');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select 'c5d933da-8203-5dfb-9ec4-c72ff7826586', 'B2', 'Модальність', 'Modalnost', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'B2' and title_ua = 'Модальність');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '91e03c04-e8a2-5ff2-ae61-25d7625a0332', 'B2', 'Фразеологія', 'Frazeologija', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'B2' and title_ua = 'Фразеологія');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '1288ed9e-983b-540e-9c6c-1025e4b0982f', 'B2', 'Складний синтаксис', 'Složena sintaksa', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'B2' and title_ua = 'Складний синтаксис');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select 'c731216f-3593-59d9-bcf2-19d32936e858', 'B2', 'Мовні регістри', 'Funkcionalni stilovi', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'B2' and title_ua = 'Мовні регістри');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '0251abca-14f6-5e67-bf5a-3e16b3c63906', 'B2', 'Аргументація', 'Argumentacija', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'B2' and title_ua = 'Аргументація');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '55c9527b-3a6d-5051-bfd6-83fe7772b00a', 'B2', 'Номіналізація', 'Nominalizacija', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'B2' and title_ua = 'Номіналізація');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '43802c3f-671a-5383-bbc5-49ed9d31b8b2', 'B2', 'Зв’язність тексту', 'Kohezija teksta', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'B2' and title_ua = 'Зв’язність тексту');
insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)
select '0e0a1c2b-889b-5753-9dff-fc3aafe0f6ec', 'B2', 'Прагматика', 'Pragmatika', null, 'DRAFT'
where not exists (select 1 from public.grammar_topics where cefr = 'B2' and title_ua = 'Прагматика');

-- 6. Самоперевірка: якщо щось не так — усе відкочується
do $$
declare
  v_modules int; v_lessons int; v_empty int;
begin
  select count(*) into v_modules from public.modules where level_code = 'A0' and status = 'PUBLISHED';
  select count(*) into v_lessons from public.lessons l join public.units u on u.id = l.unit_id
    join public.modules m on m.id = u.module_id where m.level_code = 'A0' and l.status = 'PUBLISHED';
  select count(*) into v_empty from public.lessons l
    where l.level_code = 'A0' and l.status = 'PUBLISHED'
      and not exists (select 1 from public.lesson_items i where i.lesson_id = l.id and i.item_type = 'exercise');
  if v_modules < 10 then raise exception 'A0: опубліковано модулів %, очікувалось 10', v_modules; end if;
  if v_lessons < 30 then raise exception 'A0: опубліковано уроків %, очікувалось 30', v_lessons; end if;
  if v_empty > 0 then raise exception 'A0: % уроків без вправ', v_empty; end if;
  raise notice 'Готово: A0 — % модулів, % уроків', v_modules, v_lessons;
end $$;

commit;

-- Перевірка (окремим запитом після запуску):
-- select m.order_index as модуль, m.title_ua, count(l.id) as уроків
-- from public.modules m join public.units u on u.module_id = m.id
-- left join public.lessons l on l.unit_id = u.id and l.status = 'PUBLISHED'
-- where m.level_code = 'A0' group by m.order_index, m.title_ua order by 1;
