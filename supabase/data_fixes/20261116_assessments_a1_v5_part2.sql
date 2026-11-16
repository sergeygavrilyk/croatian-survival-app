-- =====================================================================
-- Перевірки рівня A1 за схемою 2026-11-07 · частина 2 з 2 · 2026-11-16
-- Згенеровано: python3 -B scripts/gen_assessment_a0_a1_v5.py (не редагуйте вручну).
--
-- Схема (рішення власника 2026-11-07): модуль — 2 завдання на урок (12–20), середина — 30, фінал — 48.
-- Було: модуль — 10, середина — 20, фінал — 30. У цьому файлі 172 нових завдань:
--   a1-m08 — 20, a1-m09 — 20, a1-m10 — 14, a1-m11 — 12, a1-m12 — 16, a1-m13 — 12, a1-mid — 30, a1-final — 48.
--   * Завдання — з діалогів, вправ і текстів для читання уроків A1; нових хорватських речень немає. 4 навички §60.
--   * «Складіть» — з іншими правильними порядками слів (answer_alternatives), де вони є. Потрібна міграція M27.
--   * Стара версія завдань — у content_versions; старі завдання → DEPRECATED (не видаляються). Нові — PUBLISHED (бета).
--   * Спроби й результати користувачів не змінюються. Повторний запуск нічого не змінює.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника. Очікуване повідомлення:
--   «Готово: 20261116_assessments_a1_v5_part2.sql — 8 тестів, 172 нових завдань».
-- =====================================================================

begin;
-- Перевірка модуля A1.8 · Модуль A1.8 — Здоров’я · 20 завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = 'a1-m08' and cefr = 'A1';
  if v_aid is null then raise exception 'Немає тесту a1-m08 — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = 'e781fbe7-f966-553a-90c5-da7061e2850a') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from 'e4b28ab0-2aa7-5d37-885b-6908dc14e17b'::uuid then
    raise exception 'Тест a1-m08 прив’язаний не до модуля A1.8 — звірте базу';
  end if;
  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
          v_payload, 'assessment_v5: перевірку переведено на схему 2026-11-07 — старі завдання');
  -- старі завдання → DEPRECATED; місця зсуваються за найбільше наявне (унікальність assessment_id + order_index)
  select (coalesce(max(order_index), 0) / 100 + 1) * 100 into v_shift from public.assessment_items where assessment_id = v_aid;
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + v_shift
   where assessment_id = v_aid and status = 'PUBLISHED';
  update public.assessments set description_ua = 'Після модуля: 20 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~10 хв.', estimated_minutes = 10 where id = v_aid;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, answer_alternatives, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('e781fbe7-f966-553a-90c5-da7061e2850a', v_aid, 1, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Мені вимірювати тиск удома?", "Що ти змінила?", "Скільки маляті?"]'::jsonb, 0, null, '{}'::text[], 'Trebam li mjeriti tlak kod kuće?', null, null, 'Прозвучало: «Trebam li mjeriti tlak kod kuće?» — «Мені вимірювати тиск удома?».', (select id from public.lessons where id = '293af384-4ee2-5746-80a8-e8ffdc7009bc'), 'PUBLISHED', 'claude_assessment_v5'),
  ('dfdf7896-140e-51ca-883d-2e6359f9ded8', v_aid, 2, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Це може бути печінка або жовчний міхур.", "Ви нічого не відчуєте, вам зроблять знеболення.", "Ось тут, праворуч, під ребрами."]'::jsonb, 2, null, '{}'::text[], 'Ovdje s desne strane, ispod rebara.', null, null, 'Прозвучало: «Ovdje s desne strane, ispod rebara.» — «Ось тут, праворуч, під ребрами.».', (select id from public.lessons where id = 'b6859b5e-db71-543a-8d05-db9b43811d8a'), 'PUBLISHED', 'claude_assessment_v5'),
  ('7b19b539-ba96-5c14-9a47-02313950b40d', v_aid, 3, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Я його огляну, може, це запалення вуха.", "Спершу рентген, а там побачимо.", "Можу, але дуже боляче."]'::jsonb, 1, null, '{}'::text[], 'Prvo rendgen, pa vidimo.', null, null, 'Прозвучало: «Prvo rendgen, pa vidimo.» — «Спершу рентген, а там побачимо.».', (select id from public.lessons where id = '293af384-4ee2-5746-80a8-e8ffdc7009bc'), 'PUBLISHED', 'claude_assessment_v5'),
  ('1b2eb7a6-93d0-5b82-ac74-2a50831bed16', v_aid, 4, 'A1', 'reading', 'understand', 'multiple_choice', 'Як записатися на огляд?', 'Radno vrijeme ordinacije', '["Через аптеку", "Лише особисто", "Телефоном або поштою"]'::jsonb, 2, null, '{}'::text[], null, 'ORDINACIJA OBITELJSKE MEDICINE
dr. Ivana Jurić
Ponedjeljak, srijeda, petak: 7 – 14 sati
Utorak, četvrtak: 13 – 20 sati
Na pregled se naručite telefonom ili e-mailom.
Recepte i uputnice možete tražiti e-mailom.
Hitni slučajevi: zovite 194 ili 112.', 'КАБІНЕТ СІМЕЙНОЇ МЕДИЦИНИ
лікарка Івана Юрич
Понеділок, середа, п’ятниця: 7 – 14 година
Вівторок, четвер: 13 – 20 година
На огляд записуйтеся телефоном або електронною поштою.
Рецепти й направлення можна попросити електронною поштою.
Невідкладні випадки: телефонуйте 194 або 112.', 'Текст «Години роботи ординації». Правильна відповідь: «Телефоном або поштою».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('1fedca0d-3e82-55d2-8ac1-255b4d62bc38', v_aid, 5, 'A1', 'reading', 'understand', 'multiple_choice', 'Кому пише Олена?', 'Dijete je bolesno', '["Чоловікові", "Лікареві", "Виховательці"]'::jsonb, 2, null, '{}'::text[], null, 'Olena: Dobro jutro, Sofija danas ne dolazi u vrtić. Ima temperaturu i kašlje.
Odgojiteljica: Dobro jutro! Žao mi je. Neka se odmara.
Olena: Hvala. Trebam li donijeti potvrdu od liječnika?
Odgojiteljica: Da, kad se vrati u vrtić, trebamo potvrdu od pedijatra.
Olena: U redu. Hvala i lijep dan!', 'Олена: Доброго ранку, Софія сьогодні не прийде в садок. У неї температура і кашель.
Вихователька: Доброго ранку! Мені шкода. Нехай відпочиває.
Олена: Дякую. Мені потрібно принести довідку від лікаря?
Вихователька: Так, коли вона повернеться в садок, нам потрібна довідка від педіатра.
Олена: Гаразд. Дякую і гарного дня!', 'Текст «Дитина хворіє». Правильна відповідь: «Виховательці».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('e75f4533-9e17-5285-a873-7c8c26955408', v_aid, 6, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Hoće li boljeti?', '["Dvije najamnine. Ugovor je na godinu dana.", "Nećete ništa osjetiti, dobit ćete anesteziju.", "Preko e-Građana, ne moraš ići u ured."]'::jsonb, 1, null, '{}'::text[], 'Hoće li boljeti?', null, null, 'Діалог «Болить зуб»: «Hoće li boljeti?» (Буде боляче?) — «Nećete ništa osjetiti, dobit ćete anesteziju.» (Ви нічого не відчуєте, вам зроблять знеболення.).', (select id from public.lessons where id = '247c3445-6ba3-50f0-a441-9073d6734451'), 'PUBLISHED', 'claude_assessment_v5'),
  ('ae16ee49-77c2-5bfe-baf1-e0296f887265', v_aid, 7, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Moram li nešto ponijeti?', '["Zdravstvenu iskaznicu i popis lijekova.", "Od prvog sljedećeg mjeseca.", "Plaća, ali možete kupiti poseban paket podataka."]'::jsonb, 0, null, '{}'::text[], 'Moram li nešto ponijeti?', null, null, 'Діалог «Дзвінок в амбулаторію»: «Moram li nešto ponijeti?» (Мені щось треба взяти з собою?) — «Zdravstvenu iskaznicu i popis lijekova.» (Картку медичного страхування й список ліків.).', (select id from public.lessons where id = '08e31e8b-f8f7-5a80-89ed-093bc68dae03'), 'PUBLISHED', 'claude_assessment_v5'),
  ('20a3cf6f-dd33-57ca-902a-3523d61f41b6', v_aid, 8, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Jeste li imali temperaturu?', '["Do petnaestog. Platim ga odmah mobilnim bankarstvom.", "Dva dana tjedno. Šef kaže da je to u redu.", "Jesam, noću sam imala zimicu i jako sam se znojila."]'::jsonb, 2, null, '{}'::text[], 'Jeste li imali temperaturu?', null, null, 'Діалог «Що сталося?»: «Jeste li imali temperaturu?» (У вас була температура?) — «Jesam, noću sam imala zimicu i jako sam se znojila.» (Так, уночі мене морозило, і я дуже пітніла.).', (select id from public.lessons where id = '878c0712-e4e5-5a7d-aab5-510c781da0c7'), 'PUBLISHED', 'claude_assessment_v5'),
  ('851c46ad-a4d1-5381-a56f-9dd432ca52bd', v_aid, 9, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Koji zub vas boli?', '["Iznad stolića u dnevnom boravku.", "Dolje lijevo, kad pijem hladno.", "Smijete, ali ovo je prva zona, najviše dva sata."]'::jsonb, 1, null, '{}'::text[], 'Koji zub vas boli?', null, null, 'Діалог «Болить зуб»: «Koji zub vas boli?» (Який зуб вас болить?) — «Dolje lijevo, kad pijem hladno.» (Знизу ліворуч, коли п’ю холодне.).', (select id from public.lessons where id = '247c3445-6ba3-50f0-a441-9073d6734451'), 'PUBLISHED', 'claude_assessment_v5'),
  ('219e10fe-f603-57ee-a03d-0cd51266e417', v_aid, 10, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Ima li nuspojava?', '["Ось цей спрей для носа, але щонайбільше п’ять днів.", "Ці пастилки добрі. Беріть одну кожні три години.", "Рідко. Прочитайте інструкцію в коробці."]'::jsonb, 2, null, '{}'::text[], null, 'Daša: Dobar dan, trebam nešto za grlo, bez recepta.
Ljekarnica: Ove pastile su dobre. Uzmite jednu svaka tri sata.
Daša: Imam i začepljen nos.
Ljekarnica: Ovaj sprej za nos, ali najviše pet dana.
Daša: Ima li nuspojava?
Ljekarnica: Rijetko. Pročitajte upute u kutiji.', 'Daša: Добрий день, мені щось від горла, без рецепта.
Ljekarnica: Ці пастилки добрі. Беріть одну кожні три години.
Daša: У мене ще закладений ніс.
Ljekarnica: Ось цей спрей для носа, але щонайбільше п’ять днів.
Daša: Є побічні дії?
Ljekarnica: Рідко. Прочитайте інструкцію в коробці.', 'Діалог «Від горла й нежитю»: «Ima li nuspojava?» — «Rijetko. Pročitajte upute u kutiji.», тобто «Рідко. Прочитайте інструкцію в коробці.».', (select id from public.lessons where id = '123e68fa-291f-5ad6-8403-51db7020d641'), 'PUBLISHED', 'claude_assessment_v5'),
  ('0f9b6b97-62c2-5366-a988-5ca86a0130f7', v_aid, 11, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Jesam, evo ga. Kada su nalazi gotovi?', '["Завтра по обіді, побачите їх у e-Građani.", "Так, я нічого не їла з учора.", "Добрий день, у мене направлення на аналіз крові."]'::jsonb, 0, null, '{}'::text[], null, 'Daša: Dobar dan, imam uputnicu za nalaz krvi.
Sestra: Jeste li natašte?
Daša: Jesam, nisam ništa jela od jučer.
Sestra: Dobro. Donijeli ste i uzorak urina?
Daša: Jesam, evo ga. Kada su nalazi gotovi?
Sestra: Sutra poslije podne, vidjet ćete ih u e-Građanima.', 'Daša: Добрий день, у мене направлення на аналіз крові.
Sestra: Ви натщесерце?
Daša: Так, я нічого не їла з учора.
Sestra: Добре. Ви принесли й зразок сечі?
Daša: Так, ось він. Коли будуть готові результати?
Sestra: Завтра по обіді, побачите їх у e-Građani.', 'Діалог «У лабораторії»: «Jesam, evo ga. Kada su nalazi gotovi?» — «Sutra poslije podne, vidjet ćete ih u e-Građanima.», тобто «Завтра по обіді, побачите їх у e-Građani.».', (select id from public.lessons where id = '293af384-4ee2-5746-80a8-e8ffdc7009bc'), 'PUBLISHED', 'claude_assessment_v5'),
  ('91b5d109-d409-575a-97ea-8b95bd4044bc', v_aid, 12, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Kada je počelo?', '["Трохи. Найгірше — втома, я відчуваю сильну слабкість.", "Так, у мене нежить, а вночі закладений ніс.", "У неділю. Я була на морі й замерзла."]'::jsonb, 2, null, '{}'::text[], null, 'Luka: Darja, cijeli dan kišeš.
Darja: Da, curi mi nos, a noću imam začepljen nos.
Luka: Kašlješ li?
Darja: Malo. Najgori je umor, osjećam veliku slabost.
Luka: Kada je počelo?
Darja: U nedjelju. Bila sam na moru i smrzla sam se.', 'Luka: Даріє, ти цілий день чхаєш.
Darja: Так, у мене нежить, а вночі закладений ніс.
Luka: Кашляєш?
Darja: Трохи. Найгірше — втома, я відчуваю сильну слабкість.
Luka: Коли це почалося?
Darja: У неділю. Я була на морі й замерзла.', 'Діалог «Застуда»: «Kada je počelo?» — «U nedjelju. Bila sam na moru i smrzla sam se.», тобто «У неділю. Я була на морі й замерзла.».', (select id from public.lessons where id = '878c0712-e4e5-5a7d-aab5-510c781da0c7'), 'PUBLISHED', 'claude_assessment_v5'),
  ('7f5e83d3-0fc7-59d5-9bfc-e7d3b13e27c5', v_aid, 13, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Як приймати ці ліки?». Що ви скажете?', null, '["Što se dogodilo?", "Kako uzimati ovaj lijek?", "Imam problema s probavom."]'::jsonb, 1, null, '{}'::text[], null, null, null, '«Як приймати ці ліки?» — «Kako uzimati ovaj lijek?».', (select id from public.lessons where id = '123e68fa-291f-5ad6-8403-51db7020d641'), 'PUBLISHED', 'claude_assessment_v5'),
  ('6d66626f-11aa-59a6-be73-f4e4ac2695d1', v_aid, 14, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «У мене запалення горла». Що ви скажете?', null, '["Živim zdravije.", "Imam upalu grla.", "Ovdje se ne smije pušiti."]'::jsonb, 1, null, '{}'::text[], null, null, null, '«У мене запалення горла.» — «Imam upalu grla.».', (select id from public.lessons where id = '431b51ad-baa3-5387-94ac-a7273fdb9263'), 'PUBLISHED', 'claude_assessment_v5'),
  ('cf2abaec-7900-52e8-ad5a-d08a3f667ed2', v_aid, 15, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «нирка»', null, '[]'::jsonb, null, 'bubreg', '{}'::text[], null, null, null, '«нирка» — bubreg.', (select id from public.lessons where id = 'b6859b5e-db71-543a-8d05-db9b43811d8a'), 'PUBLISHED', 'claude_assessment_v5'),
  ('140e45ba-9a94-52df-8cf2-85c076a038ae', v_aid, 16, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «пастилка, льодяник (від горла)»', null, '[]'::jsonb, null, 'pastila', '{}'::text[], null, null, null, '«пастилка, льодяник (від горла)» — pastila.', (select id from public.lessons where id = '123e68fa-291f-5ad6-8403-51db7020d641'), 'PUBLISHED', 'claude_assessment_v5'),
  ('d3f7c59c-5234-59c7-b35a-f5de2df16025', v_aid, 17, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Приймайте натщесерце.»', null, '["natašte.", "Uzimajte", "lijek"]'::jsonb, null, 'Uzimajte lijek natašte.', array['Lijek uzimajte natašte.']::text[], null, null, null, '«Приймайте натщесерце.» — «Uzimajte lijek natašte.».', (select id from public.lessons where id = '123e68fa-291f-5ad6-8403-51db7020d641'), 'PUBLISHED', 'claude_assessment_v5'),
  ('6289dcf1-2afc-540f-af0b-c7f0a7c2fca9', v_aid, 18, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Дитина блює з ранку.»', null, '["od", "jutra.", "povraća", "Dijete"]'::jsonb, null, 'Dijete povraća od jutra.', array['Od jutra dijete povraća.']::text[], null, null, null, '«Дитина блює з ранку.» — «Dijete povraća od jutra.».', (select id from public.lessons where id = '0df023bb-17fb-5006-91bf-3b911dd30295'), 'PUBLISHED', 'claude_assessment_v5'),
  ('58e03128-0e49-5d97-86f8-73b07aceaf30', v_aid, 19, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Який діагноз?»', null, '["je", "Kakva", "dijagnoza?"]'::jsonb, null, 'Kakva je dijagnoza?', '{}'::text[], null, null, null, '«Який діагноз?» — «Kakva je dijagnoza?».', (select id from public.lessons where id = '431b51ad-baa3-5387-94ac-a7273fdb9263'), 'PUBLISHED', 'claude_assessment_v5'),
  ('672c3585-8cd5-5251-b146-e1023da892c3', v_aid, 20, 'A1', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Мені болить праворуч, під ребрами.»', null, '[]'::jsonb, null, 'Boli me s desne strane, ispod rebara.', '{}'::text[], null, null, null, '«Мені болить праворуч, під ребрами.» — «Boli me s desne strane, ispod rebara.».', (select id from public.lessons where id = 'b6859b5e-db71-543a-8d05-db9b43811d8a'), 'PUBLISHED', 'claude_assessment_v5');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірки рівня A1 за схемою 2026-11-07 (модуль — 2 завдання на урок, середина — 30, фінал — 48) з діалогів, вправ і текстів уроків A1. Потрібна перевірка носієм.');
end $$;

-- Перевірка модуля A1.9 · Модуль A1.9 — Люди й вільний час · 20 завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = 'a1-m09' and cefr = 'A1';
  if v_aid is null then raise exception 'Немає тесту a1-m09 — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = '4e4a5295-4749-5619-8e36-201b439c3fa8') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from '4fae6fe1-6bf2-5eef-9023-f7425b151c9e'::uuid then
    raise exception 'Тест a1-m09 прив’язаний не до модуля A1.9 — звірте базу';
  end if;
  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
          v_payload, 'assessment_v5: перевірку переведено на схему 2026-11-07 — старі завдання');
  -- старі завдання → DEPRECATED; місця зсуваються за найбільше наявне (унікальність assessment_id + order_index)
  select (coalesce(max(order_index), 0) / 100 + 1) * 100 into v_shift from public.assessment_items where assessment_id = v_aid;
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + v_shift
   where assessment_id = v_aid and status = 'PUBLISHED';
  update public.assessments set description_ua = 'Після модуля: 20 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~10 хв.', estimated_minutes = 10 where id = v_aid;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, answer_alternatives, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('4e4a5295-4749-5619-8e36-201b439c3fa8', v_aid, 1, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Покажи мені новий малюнок після шахів.", "Правда, вона танцює щосереди.", "Шкода! Начальник хоче відсвяткувати вдалий рік."]'::jsonb, 0, null, '{}'::text[], 'Pokaži mi novi crtež poslije šaha.', null, null, 'Прозвучало: «Pokaži mi novi crtež poslije šaha.» — «Покажи мені новий малюнок після шахів.».', (select id from public.lessons where id = '1c16ceee-5f42-536a-98b4-7dcabaa3be6d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('c43ef766-2143-510b-a697-066381109041', v_aid, 2, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Гандбол або баскетбол, тут вони дуже популярні.", "На жаль, я не можу прийти, у мене немає часу.", "Не хвилюйся, нам вистачить до кінця місяця."]'::jsonb, 1, null, '{}'::text[], 'Nažalost, ne mogu doći, nemam vremena.', null, null, 'Прозвучало: «Nažalost, ne mogu doći, nemam vremena.» — «На жаль, я не можу прийти, у мене немає часу.».', (select id from public.lessons where id = '3ed8282d-b9fa-5151-b184-73fd352f8ba7'), 'PUBLISHED', 'claude_assessment_v5'),
  ('9eca1095-06a0-5162-8bd2-7ae5748cdc0d', v_aid, 3, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Я всюди дивилася!", "Нічого не сказав, тільки що передзвонить.", "Знаю, але я хвилююся через гроші."]'::jsonb, 0, null, '{}'::text[], 'Svugdje sam gledala!', null, null, 'Прозвучало: «Svugdje sam gledala!» — «Я всюди дивилася!».', (select id from public.lessons where id = '3f440ad8-f057-5898-b773-6aa8816fa8a3'), 'PUBLISHED', 'claude_assessment_v5'),
  ('9688a198-6d03-5089-abf7-0a9e1e191128', v_aid, 4, 'A1', 'reading', 'understand', 'multiple_choice', 'Що буде, якщо йде дощ?', 'Koncert u parku', '["Концерт у театрі", "Концерт у неділю", "Концерт скасують"]'::jsonb, 0, null, '{}'::text[], null, 'KONCERT U PARKU ZRINJEVAC
Subota, 20 sati
Svira bend iz Zagreba.
Ulaz je besplatan!
Ako pada kiša, koncert je u kazalištu.
Ponesite deku i dobro raspoloženje.', 'КОНЦЕРТ У ПАРКУ ЗРИНЄВАЦ
Субота, 20 година
Грає гурт із Загреба.
Вхід вільний!
Якщо йде дощ, концерт відбудеться в театрі.
Візьміть ковдру й гарний настрій.', 'Текст «Концерт у парку». Правильна відповідь: «Концерт у театрі».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('c32b35a0-1d7a-5ab5-9ca9-d07ca6c78c54', v_aid, 5, 'A1', 'reading', 'understand', 'multiple_choice', 'Де вечірка?', 'Pozivnica za rođendan', '["У парку", "У ресторані", "У квартирі Івани"]'::jsonb, 2, null, '{}'::text[], null, 'Dragi prijatelji!
U subotu slavim trideseti rođendan i želim vas vidjeti. Zabava je u našem stanu od osam navečer. Imamo hranu i piće, vi donesite dobro raspoloženje! Ako dolazite, javite mi do četvrtka.
Vidimo se,
Ivana', 'Дорогі друзі!
У суботу я святкую тридцятий день народження і хочу вас побачити. Вечірка в нашій квартирі з восьмої вечора. У нас є їжа й напої, а ви принесіть гарний настрій! Якщо прийдете, дайте мені знати до четверга.
До зустрічі,
Івана', 'Текст «Запрошення на день народження». Правильна відповідь: «У квартирі Івани».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('c005b961-788d-5b37-b837-0234a2e95645', v_aid, 6, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Gospodine Kovaču, smijem li vas nešto pitati?', '["Naravno, Dašo. I možemo se tikati, ja sam Ivo.", "Stavim piletinu u veliki lonac i zakuham vodu.", "Šest eura neto, plaćen prijevoz."]'::jsonb, 0, null, '{}'::text[], 'Gospodine Kovaču, smijem li vas nešto pitati?', null, null, 'Діалог «Ти чи Ви?»: «Gospodine Kovaču, smijem li vas nešto pitati?» (Пане Ковач, можна вас щось запитати?) — «Naravno, Dašo. I možemo se tikati, ja sam Ivo.» (Звісно, Дашо. І можемо на «ти», я Іво.).', (select id from public.lessons where id = '6df343ef-4a40-5dfb-9100-7ab47fb1667d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('4c913ccd-c5e9-5fcc-b79d-12d0564407f5', v_aid, 7, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Koliko puta tjedno imaju trening?', '["Oko trideset eura, prema taksimetru.", "Super! Upoznala sam cijeli tim.", "Triput, a vikendom igraju utakmice za momčad škole."]'::jsonb, 2, null, '{}'::text[], 'Koliko puta tjedno imaju trening?', null, null, 'Діалог «Який спорт обрати?»: «Koliko puta tjedno imaju trening?» (Скільки разів на тиждень у них тренування?) — «Triput, a vikendom igraju utakmice za momčad škole.» (Тричі, а на вихідних грають матчі за шкільну команду.).', (select id from public.lessons where id = 'e61e3942-cd86-5f75-9eb5-d878242125bf'), 'PUBLISHED', 'claude_assessment_v5'),
  ('c0f8821f-6a7a-5a4a-966c-44a705839e22', v_aid, 8, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Kako ti se svidjela predstava?', '["Odlično! Glavni glumac je bio fantastičan.", "Idite naprijed, pa prema crkvi.", "Dvadeset dva. Imam veliki kofer."]'::jsonb, 0, null, '{}'::text[], 'Kako ti se svidjela predstava?', null, null, 'Діалог «Після вистави»: «Kako ti se svidjela predstava?» (Як тобі вистава?) — «Odlično! Glavni glumac je bio fantastičan.» (Чудово! Головний актор був неймовірний.).', (select id from public.lessons where id = '631c7f59-de43-5081-adb7-77bdf23ce805'), 'PUBLISHED', 'claude_assessment_v5'),
  ('09c1e2f5-0215-533c-b16f-8753e92456be', v_aid, 9, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Jesam. Treba li svečana odjeća?', '["Ne mora, ali bez traperica.", "Na ime Kovalenko. Hvala!", "Od bruto plaće se plaćaju porez i doprinosi."]'::jsonb, 0, null, '{}'::text[], 'Jesam. Treba li svečana odjeća?', null, null, 'Діалог «Корпоратив»: «Jesam. Treba li svečana odjeća?» (Так. Потрібен святковий одяг?) — «Ne mora, ali bez traperica.» (Не обов’язково, але без джинсів.).', (select id from public.lessons where id = '3ed8282d-b9fa-5151-b184-73fd352f8ba7'), 'PUBLISHED', 'claude_assessment_v5'),
  ('f37094d7-9c5b-5edc-a1f2-3b40f429ea5b', v_aid, 10, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Marko, jesi li sinoć gledao utakmicu?', '["Уболівальники святкували всю ніч.", "Так! Хорватія перемогла два — один.", "Чудово! Минулого разу була нічия."]'::jsonb, 1, null, '{}'::text[], null, 'Luka: Marko, jesi li sinoć gledao utakmicu?
Marko: Jesam! Hrvatska je pobijedila dva jedan.
Luka: Tko je zabio drugi gol?
Marko: Mladi igrač iz Dinama, u zadnjoj minuti.
Luka: Super! Prošli put je bilo neriješeno.
Marko: Navijači su slavili cijelu noć.', 'Luka: Марку, ти вчора дивився матч?
Marko: Так! Хорватія перемогла два — один.
Luka: Хто забив другий гол?
Marko: Молодий гравець «Динамо», на останній хвилині.
Luka: Чудово! Минулого разу була нічия.
Marko: Уболівальники святкували всю ніч.', 'Діалог «Ти дивився матч?»: «Marko, jesi li sinoć gledao utakmicu?» — «Jesam! Hrvatska je pobijedila dva jedan.», тобто «Так! Хорватія перемогла два — один.».', (select id from public.lessons where id = 'e61e3942-cd86-5f75-9eb5-d878242125bf'), 'PUBLISHED', 'claude_assessment_v5'),
  ('61e06811-848e-5df8-bd2b-81b2c5aaf346', v_aid, 11, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Je li opera ili balet?', '["Балет. Квитки ще продаються.", "Луко, у Національному театрі в п’ятницю прем’єра нової вистави.", "На Шалаті? Там улітку фестиваль."]'::jsonb, 0, null, '{}'::text[], null, 'Daša: Luka, u HNK-u je u petak premijera nove predstave.
Luka: Je li opera ili balet?
Daša: Balet. Ulaznice su još u prodaji.
Luka: Može. A u subotu je koncert mog omiljenog benda.
Daša: Na Šalati? Tamo je ljeti festival.
Luka: Da, otvoreni koncert. Pjevač je odličan uživo.', 'Daša: Луко, у Національному театрі в п’ятницю прем’єра нової вистави.
Luka: Це опера чи балет?
Daša: Балет. Квитки ще продаються.
Luka: Давай. А в суботу концерт мого улюбленого гурту.
Daša: На Шалаті? Там улітку фестиваль.
Luka: Так, концерт просто неба. Співак чудовий наживо.', 'Діалог «Куди підемо?»: «Je li opera ili balet?» — «Balet. Ulaznice su još u prodaji.», тобто «Балет. Квитки ще продаються.».', (select id from public.lessons where id = '631c7f59-de43-5081-adb7-77bdf23ce805'), 'PUBLISHED', 'claude_assessment_v5'),
  ('59f61add-be7b-5110-ad3c-0c9fb429048b', v_aid, 12, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'U koliko sati?', '["Стежка важка?", "О восьмій. До вершини дві години ходьби.", "Місце зустрічі — на трамвайній зупинці Михалевац."]'::jsonb, 1, null, '{}'::text[], null, 'Marko: Dašo, idemo li u nedjelju na Sljeme?
Daša: Može! Gdje se nalazimo?
Marko: Mjesto sastanka je na tramvajskoj stanici Mihaljevac.
Daša: U koliko sati?
Marko: U osam. Do vrha je dva sata hoda.
Daša: Je li staza teška?', 'Marko: Дашо, підемо в неділю на Слеме?
Daša: Давай! Де зустрічаємося?
Marko: Місце зустрічі — на трамвайній зупинці Михалевац.
Daša: О котрій?
Marko: О восьмій. До вершини дві години ходьби.
Daša: Стежка важка?', 'Діалог «Похід на Слеме»: «U koliko sati?» — «U osam. Do vrha je dva sata hoda.», тобто «О восьмій. До вершини дві години ходьби.».', (select id from public.lessons where id = 'dde31f54-28b8-505b-aba6-3e578601fccb'), 'PUBLISHED', 'claude_assessment_v5'),
  ('8a895493-cf6d-5b42-83bc-45af4c2860ce', v_aid, 13, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Що з тобою?». Що ви скажете?', null, '["Što misliš?", "Što ti je?", "Nađimo se kod ulaza."]'::jsonb, 1, null, '{}'::text[], null, null, null, '«Що з тобою?» — «Što ti je?».', (select id from public.lessons where id = 'fac55dd6-0020-5997-8461-45ee2f94d3c5'), 'PUBLISHED', 'claude_assessment_v5'),
  ('12f86858-a0d6-5327-830f-8b393d0aeb7b', v_aid, 14, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Я граю в шахи з дідусем». Що ви скажете?', null, '["Igram šah s djedom.", "Ponosna sam na tebe.", "Igram tenis."]'::jsonb, 0, null, '{}'::text[], null, null, null, '«Я граю в шахи з дідусем.» — «Igram šah s djedom.».', (select id from public.lessons where id = '1c16ceee-5f42-536a-98b4-7dcabaa3be6d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('aa465352-dcf7-5c0f-b23b-7fcd474fd98c', v_aid, 15, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «розслаблений»', null, '[]'::jsonb, null, 'opušten', '{}'::text[], null, null, null, '«розслаблений» — opušten.', (select id from public.lessons where id = 'fac55dd6-0020-5997-8461-45ee2f94d3c5'), 'PUBLISHED', 'claude_assessment_v5'),
  ('571746cb-180f-572c-9b29-238ae8eca571', v_aid, 16, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «цікавий»', null, '[]'::jsonb, null, 'zanimljiv', '{}'::text[], null, null, null, '«цікавий» — zanimljiv.', (select id from public.lessons where id = 'ec1b7982-c092-5504-a233-4162f92f512a'), 'PUBLISHED', 'claude_assessment_v5'),
  ('732cb6d3-b93a-5a39-b647-606571ae7a8d', v_aid, 17, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Я вболіваю за Хорватію.»', null, '["Navijam", "Hrvatsku.", "za"]'::jsonb, null, 'Navijam za Hrvatsku.', '{}'::text[], null, null, null, '«Я вболіваю за Хорватію.» — «Navijam za Hrvatsku.».', (select id from public.lessons where id = 'e61e3942-cd86-5f75-9eb5-d878242125bf'), 'PUBLISHED', 'claude_assessment_v5'),
  ('e4c6edc6-af1a-500d-a622-c8350006fb0d', v_aid, 18, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Яке в тебе хобі?»', null, '["hobi?", "tvoj", "je", "Koji"]'::jsonb, null, 'Koji je tvoj hobi?', '{}'::text[], null, null, null, '«Яке в тебе хобі?» — «Koji je tvoj hobi?».', (select id from public.lessons where id = '1c16ceee-5f42-536a-98b4-7dcabaa3be6d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('078c7f43-2783-5afb-913a-2cc89185fd1d', v_aid, 19, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Дякую за запрошення!»', null, '["na", "pozivu!", "Hvala"]'::jsonb, null, 'Hvala na pozivu!', '{}'::text[], null, null, null, '«Дякую за запрошення!» — «Hvala na pozivu!».', (select id from public.lessons where id = '3ed8282d-b9fa-5151-b184-73fd352f8ba7'), 'PUBLISHED', 'claude_assessment_v5'),
  ('63bf30e1-39c4-52d0-9b91-cf468ab65f7a', v_aid, 20, 'A1', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Підемо на концерт?»', null, '[]'::jsonb, null, 'Idemo li na koncert?', '{}'::text[], null, null, null, '«Підемо на концерт?» — «Idemo li na koncert?».', (select id from public.lessons where id = '631c7f59-de43-5081-adb7-77bdf23ce805'), 'PUBLISHED', 'claude_assessment_v5');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірки рівня A1 за схемою 2026-11-07 (модуль — 2 завдання на урок, середина — 30, фінал — 48) з діалогів, вправ і текстів уроків A1. Потрібна перевірка носієм.');
end $$;

-- Перевірка модуля A1.10 · Модуль A1.10 — Подорожуємо Хорватією · 14 завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = 'a1-m10' and cefr = 'A1';
  if v_aid is null then raise exception 'Немає тесту a1-m10 — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = 'a98e6caa-e694-58cb-bf06-92b870231c53') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from '4a99a045-1da4-5ac1-be05-74811dd7d630'::uuid then
    raise exception 'Тест a1-m10 прив’язаний не до модуля A1.10 — звірте базу';
  end if;
  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
          v_payload, 'assessment_v5: перевірку переведено на схему 2026-11-07 — старі завдання');
  -- старі завдання → DEPRECATED; місця зсуваються за найбільше наявне (унікальність assessment_id + order_index)
  select (coalesce(max(order_index), 0) / 100 + 1) * 100 into v_shift from public.assessment_items where assessment_id = v_aid;
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + v_shift
   where assessment_id = v_aid and status = 'PUBLISHED';
  update public.assessments set description_ua = 'Після модуля: 14 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~7 хв.', estimated_minutes = 7 where id = v_aid;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, answer_alternatives, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('a98e6caa-e694-58cb-bf06-92b870231c53', v_aid, 1, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Чудово! Ми слухали Морський орган на набережній.", "Тоді поїдемо на прогулянку в суботу зранку.", "Я складу план подорожі сьогодні ввечері."]'::jsonb, 0, null, '{}'::text[], 'Predivno! Slušali smo morske orgulje na rivi.', null, null, 'Прозвучало: «Predivno! Slušali smo morske orgulje na rivi.» — «Чудово! Ми слухали Морський орган на набережній.».', (select id from public.lessons where id = '9a44edc5-7e46-5377-bfcb-20cd93ac333b'), 'PUBLISHED', 'claude_assessment_v5'),
  ('efe60c38-6622-5d52-8f5f-269665e98d32', v_aid, 2, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Я впав з велосипеда й ударив руку.", "Ми гуляли набережною до римського форуму.", "Зранку проясниться, але по обіді можливі зливи."]'::jsonb, 2, null, '{}'::text[], 'Ujutro će se razvedriti, ali popodne su mogući pljuskovi.', null, null, 'Прозвучало: «Ujutro će se razvedriti, ali popodne su mogući pljuskovi.» — «Зранку проясниться, але по обіді можливі зливи.».', (select id from public.lessons where id = '0cb42e87-0ece-5e12-a07c-05cb5c370157'), 'PUBLISHED', 'claude_assessment_v5'),
  ('3fb37c1c-89ae-5e0f-8155-e1819883051f', v_aid, 3, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Тату, тут живуть ведмеді?", "Де ви були вчора ввечері?", "Даріє, ти була в природному парку Велебіт?"]'::jsonb, 2, null, '{}'::text[], 'Darja, jesi li bila u parku prirode Velebit?', null, null, 'Прозвучало: «Darja, jesi li bila u parku prirode Velebit?» — «Даріє, ти була в природному парку Велебіт?».', (select id from public.lessons where id = '84a20a00-701a-5ce5-a3c8-fca72986f912'), 'PUBLISHED', 'claude_assessment_v5'),
  ('98c0ef1c-5835-5051-9947-40b09d53c3cd', v_aid, 4, 'A1', 'reading', 'understand', 'multiple_choice', 'Як вони повертаються?', 'Razglednica s otoka', '["Літаком", "Поромом", "Автобусом"]'::jsonb, 1, null, '{}'::text[], null, 'Draga Marija,
pozdrav s Hvara! More je toplo i čisto, a plaže su prekrasne. Svaki dan se kupamo i jedemo svježu ribu. Navečer šetamo uz rivu. Grad je mali, ali ima puno ljudi. Vraćamo se u nedjelju trajektom. Jedva čekam da se vidimo!
Grli te Oksana', 'Дорога Маріє,
привіт із Хвару! Море тепле й чисте, а пляжі чудові. Щодня ми купаємося і їмо свіжу рибу. Увечері гуляємо набережною. Місто маленьке, але людей багато. Повертаємося в неділю поромом. Не можу дочекатися нашої зустрічі!
Обіймаю, Оксана', 'Текст «Листівка з острова». Правильна відповідь: «Поромом».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('64f400d5-e09c-5e6c-a40e-20c9492ffa16', v_aid, 5, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Je li bilo glazbe?', '["Da, pjevala je klapa. A u kafiću smo probali maraskino.", "Prvi slobodni termin je u četvrtak u deset.", "Šest eura, a juha je besplatna."]'::jsonb, 0, null, '{}'::text[], 'Je li bilo glazbe?', null, null, 'Діалог «Далматинський вечір»: «Je li bilo glazbe?» (Була музика?) — «Da, pjevala je klapa. A u kafiću smo probali maraskino.» (Так, співала клапа. А в кафе ми скуштували мараскіно.).', (select id from public.lessons where id = '9a44edc5-7e46-5377-bfcb-20cd93ac333b'), 'PUBLISHED', 'claude_assessment_v5'),
  ('aa525570-fff3-5633-865a-5ec4671ce348', v_aid, 6, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Hoćemo li kampirati ili uzeti privatni smještaj?', '["U kutiji, na dnu. I vijci su u maloj vrećici.", "Djeca žele kamp i šator!", "U osam. Do vrha je dva sata hoda."]'::jsonb, 1, null, '{}'::text[], 'Hoćemo li kampirati ili uzeti privatni smještaj?', null, null, 'Діалог «Куди поїдемо?»: «Hoćemo li kampirati ili uzeti privatni smještaj?» (Будемо жити в наметі чи візьмемо приватне житло?) — «Djeca žele kamp i šator!» (Діти хочуть кемпінг і намет!).', (select id from public.lessons where id = '373074e1-3c4b-5d0f-a4f3-3ed06e0904f2'), 'PUBLISHED', 'claude_assessment_v5'),
  ('974ac4f1-ff69-5f28-826d-7254dce6edbb', v_aid, 7, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Dašo, kamo ćemo ići na godišnji ove godine?', '["Rade. Provjerite i zvonce prije vožnje.", "Mislim da ćemo putovati u Dalmaciju, u predsezoni.", "Sutra poslije podne, vidjet ćete ih u e-Građanima."]'::jsonb, 1, null, '{}'::text[], 'Dašo, kamo ćemo ići na godišnji ove godine?', null, null, 'Діалог «Куди поїдемо?»: «Dašo, kamo ćemo ići na godišnji ove godine?» (Дашо, куди поїдемо у відпустку цього року?) — «Mislim da ćemo putovati u Dalmaciju, u predsezoni.» (Думаю, поїдемо в Далмацію, на початку сезону.).', (select id from public.lessons where id = '373074e1-3c4b-5d0f-a4f3-3ed06e0904f2'), 'PUBLISHED', 'claude_assessment_v5'),
  ('f101ff1d-73a6-5a7e-9faa-a35e9f83572c', v_aid, 8, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Zašto ljudi u Zagorju drugačije govore?', '["Для мене приморський, Далмація — один із найгарніших регіонів.", "Ліка — континентальна, зими там найхолодніші.", "Це кайкавське наріччя. У Далмації звучить знову інакше."]'::jsonb, 2, null, '{}'::text[], null, 'Darja: Zašto ljudi u Zagorju drugačije govore?
Marko: To je kajkavsko narječje. U Dalmaciji zvuči opet drugačije.
Darja: A Lika?
Marko: Lika je kontinentalna, zime su najhladnije.
Darja: Koji je kraj najljepši?
Marko: Za mene primorski, Dalmacija je jedna od najljepših regija.', 'Darja: Чому люди в Загор’ї говорять інакше?
Marko: Це кайкавське наріччя. У Далмації звучить знову інакше.
Darja: А Ліка?
Marko: Ліка — континентальна, зими там найхолодніші.
Darja: Який край найгарніший?
Marko: Для мене приморський, Далмація — один із найгарніших регіонів.', 'Діалог «Як вони говорять?»: «Zašto ljudi u Zagorju drugačije govore?» — «To je kajkavsko narječje. U Dalmaciji zvuči opet drugačije.», тобто «Це кайкавське наріччя. У Далмації звучить знову інакше.».', (select id from public.lessons where id = '8633c234-d638-57f1-ad92-1c78be43fb07'), 'PUBLISHED', 'claude_assessment_v5'),
  ('507b3173-c09c-5cf5-a91d-db67d3789a89', v_aid, 9, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Tata, žive li ovdje medvjedi?', '["Живуть, і вовки, і рисі, але вони дуже полохливі.", "Мабуть, ні. Але зранку я бачив козулю й оленя.", "Білка! А вночі почуємо сову."]'::jsonb, 0, null, '{}'::text[], null, 'Filip: Tata, žive li ovdje medvjedi?
Luka: Žive, i vukovi i risovi, ali su jako plahi.
Filip: Hoćemo li vidjeti nekog medvjeda?
Luka: Vjerojatno nećemo. Ali jutros sam vidio srnu i jelena.
Filip: A što je ono na drvetu?
Luka: Vjeverica! A noću ćemo čuti sovu.', 'Filip: Тату, тут живуть ведмеді?
Luka: Живуть, і вовки, і рисі, але вони дуже полохливі.
Filip: Ми побачимо якогось ведмедя?
Luka: Мабуть, ні. Але зранку я бачив козулю й оленя.
Filip: А що ото на дереві?
Luka: Білка! А вночі почуємо сову.', 'Діалог «У Горському Котарі»: «Tata, žive li ovdje medvjedi?» — «Žive, i vukovi i risovi, ali su jako plahi.», тобто «Живуть, і вовки, і рисі, але вони дуже полохливі.».', (select id from public.lessons where id = '88e6f563-29dd-5e5d-865b-67fa47474b07'), 'PUBLISHED', 'claude_assessment_v5'),
  ('5754ebbf-311d-595e-a214-e26595e20c7f', v_aid, 10, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Звідки ти, з якого краю?». Що ви скажете?', null, '["Kakvo će biti vrijeme sutra?", "Koliko košta ležaljka?", "Iz kojeg si kraja?"]'::jsonb, 2, null, '{}'::text[], null, null, null, '«Звідки ти, з якого краю?» — «Iz kojeg si kraja?».', (select id from public.lessons where id = '8633c234-d638-57f1-ad92-1c78be43fb07'), 'PUBLISHED', 'claude_assessment_v5'),
  ('38bb4954-7f25-5566-beb6-f37e21886710', v_aid, 11, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Далмація найгарніша». Що ви скажете?', null, '["Volim prirodu.", "Gledaj, dupini!", "Dalmacija je najljepša."]'::jsonb, 2, null, '{}'::text[], null, null, null, '«Далмація найгарніша.» — «Dalmacija je najljepša.».', (select id from public.lessons where id = '8633c234-d638-57f1-ad92-1c78be43fb07'), 'PUBLISHED', 'claude_assessment_v5'),
  ('5088a719-38bf-5f3e-9efd-9700e3fffb45', v_aid, 12, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «пірнання; дайвінг»', null, '[]'::jsonb, null, 'ronjenje', '{}'::text[], null, null, null, '«пірнання; дайвінг» — ronjenje.', (select id from public.lessons where id = '71ab330d-abbe-57a7-870e-77e59daf3627'), 'PUBLISHED', 'claude_assessment_v5'),
  ('b983944b-500c-5511-a467-e6c37294ed2c', v_aid, 13, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Коли відправляється пором?»', null, '["trajekt?", "polazi", "Kada"]'::jsonb, null, 'Kada polazi trajekt?', array['Kada trajekt polazi?']::text[], null, null, null, '«Коли відправляється пором?» — «Kada polazi trajekt?».', (select id from public.lessons where id = '71ab330d-abbe-57a7-870e-77e59daf3627'), 'PUBLISHED', 'claude_assessment_v5'),
  ('914769b8-3144-5643-92d7-f6b1be460bd4', v_aid, 14, 'A1', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Як було в Задарі?»', null, '[]'::jsonb, null, 'Kako je bilo u Zadru?', '{}'::text[], null, null, null, '«Як було в Задарі?» — «Kako je bilo u Zadru?».', (select id from public.lessons where id = '9a44edc5-7e46-5377-bfcb-20cd93ac333b'), 'PUBLISHED', 'claude_assessment_v5');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірки рівня A1 за схемою 2026-11-07 (модуль — 2 завдання на урок, середина — 30, фінал — 48) з діалогів, вправ і текстів уроків A1. Потрібна перевірка носієм.');
end $$;

-- Перевірка модуля A1.11 · Модуль A1.11 — Хорватська культура · 12 завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = 'a1-m11' and cefr = 'A1';
  if v_aid is null then raise exception 'Немає тесту a1-m11 — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = '55e3e06c-20a8-5027-83f0-270e4875c602') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from '7ed566a6-0272-5422-96e4-1ee69a1c41f1'::uuid then
    raise exception 'Тест a1-m11 прив’язаний не до модуля A1.11 — звірте базу';
  end if;
  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
          v_payload, 'assessment_v5: перевірку переведено на схему 2026-11-07 — старі завдання');
  -- старі завдання → DEPRECATED; місця зсуваються за найбільше наявне (унікальність assessment_id + order_index)
  select (coalesce(max(order_index), 0) / 100 + 1) * 100 into v_shift from public.assessment_items where assessment_id = v_aid;
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + v_shift
   where assessment_id = v_aid and status = 'PUBLISHED';
  update public.assessments set description_ua = 'Після модуля: 12 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~6 хв.', estimated_minutes = 6 where id = v_aid;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, answer_alternatives, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('55e3e06c-20a8-5027-83f0-270e4875c602', v_aid, 1, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["А Тіла Христового? Воно завжди в четвер.", "На балконі. А я попрасую сорочки.", "Прийде, шостого грудня. Залиш чобіток на вікні!"]'::jsonb, 2, null, '{}'::text[], 'Hoće, šestog prosinca. Ostavi čizmicu na prozoru!', null, null, 'Прозвучало: «Hoće, šestog prosinca. Ostavi čizmicu na prozoru!» — «Прийде, шостого грудня. Залиш чобіток на вікні!».', (select id from public.lessons where id = 'f67bd38c-a41c-51df-b9c0-081737600fce'), 'PUBLISHED', 'claude_assessment_v5'),
  ('1c8fe3d0-602f-5716-8f7a-d3a0872c3535', v_aid, 2, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Бакалар, а опівночі підемо на різдвяну месу.", "Ні, було забагато людей. Піду завтра зранку.", "Це Ловрієнац. Колись там жили вояки."]'::jsonb, 2, null, '{}'::text[], 'To je Lovrijenac. Nekada su ondje živjeli vojnici.', null, null, 'Прозвучало: «To je Lovrijenac. Nekada su ondje živjeli vojnici.» — «Це Ловрієнац. Колись там жили вояки.».', (select id from public.lessons where id = 'd9ef1de4-f4db-590e-bafd-474f84c8e03f'), 'PUBLISHED', 'claude_assessment_v5'),
  ('36ad1d31-e5bf-5eb4-b99e-a351650dfdfa', v_aid, 3, 'A1', 'reading', 'understand', 'multiple_choice', 'Що варто принести в гості?', 'Hrvatski običaji: kava i gosti', '["Щось невелике, наприклад тістечко", "Нічого", "Дорогий подарунок"]'::jsonb, 0, null, '{}'::text[], null, 'U Hrvatskoj ljudi često idu na kavu. Kava nije samo kava – to je vrijeme za prijatelje. Kad idete u goste, donesite nešto malo, na primjer kolač. U puno kuća gosti se izuju. Domaćica uvijek nudi jelo i piće, jer su Hrvati vrlo gostoljubivi.', 'У Хорватії люди часто ходять на каву. Кава — це не просто кава, це час для друзів. Коли йдете в гості, принесіть щось невелике, наприклад тістечко. У багатьох домах гості знімають взуття. Господиня завжди пропонує їжу й напої, бо хорвати дуже гостинні.', 'Текст «Хорватські звичаї: кава й гості». Правильна відповідь: «Щось невелике, наприклад тістечко».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('b1937105-4cfc-5edc-b405-3c7de14f50d1', v_aid, 4, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Jesi li vidjela kip Grgura Ninskog?', '["Samo jednom, na odmorištu.", "Jesam, i protrljala sam mu nožni palac za sreću.", "Moj dečko me pitao na plaži, za zalazak sunca."]'::jsonb, 1, null, '{}'::text[], 'Jesi li vidjela kip Grgura Ninskog?', null, null, 'Діалог «Прогулянка Сплітом»: «Jesi li vidjela kip Grgura Ninskog?» (Ти бачила статую Григорія Нинського?) — «Jesam, i protrljala sam mu nožni palac za sreću.» (Так, і потерла йому великий палець ноги на щастя.).', (select id from public.lessons where id = 'd9ef1de4-f4db-590e-bafd-474f84c8e03f'), 'PUBLISHED', 'claude_assessment_v5'),
  ('ac5a4c1d-a93a-5f06-a58e-7686887646e5', v_aid, 5, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Gdje ćete dočekati Novu godinu?', '["Na trgu, bit će koncert i vatromet u ponoć.", "Tri godine. A prvi spoj nam je bio u kinu.", "Mladi igrač iz Dinama, u zadnjoj minuti."]'::jsonb, 0, null, '{}'::text[], 'Gdje ćete dočekati Novu godinu?', null, null, 'Діалог «Новорічна ніч»: «Gdje ćete dočekati Novu godinu?» (Де ви зустрічатимете Новий рік?) — «Na trgu, bit će koncert i vatromet u ponoć.» (На площі, буде концерт і феєрверк опівночі.).', (select id from public.lessons where id = '33c041a0-e71a-55c1-94c8-64941876c6d2'), 'PUBLISHED', 'claude_assessment_v5'),
  ('b2bd7c82-439e-5d39-b484-5c4fa11ea7bd', v_aid, 6, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Marko, radiš li tridesetog svibnja?', '["Ne, to je Dan državnosti, neradni dan.", "Prvo oguli jabuke i nasjeckaj ih.", "To je kajkavsko narječje. U Dalmaciji zvuči opet drugačije."]'::jsonb, 0, null, '{}'::text[], 'Marko, radiš li tridesetog svibnja?', null, null, 'Діалог «Календар свят»: «Marko, radiš li tridesetog svibnja?» (Марко, ти працюєш тридцятого травня?) — «Ne, to je Dan državnosti, neradni dan.» (Ні, це День державності, неробочий день.).', (select id from public.lessons where id = '33c041a0-e71a-55c1-94c8-64941876c6d2'), 'PUBLISHED', 'claude_assessment_v5'),
  ('c93a48c4-b892-5dce-b342-b60c5ec7ac7d', v_aid, 7, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Hoćemo li bojiti jaja?', '["Будемо! Діти зроблять писанки.", "Трохи, дітям даруємо солодощі. Це гарна традиція.", "Перед Великоднем — Великий піст, а за тиждень до нього — Квітна неділя."]'::jsonb, 0, null, '{}'::text[], null, 'Darja: Ivana, kako se ovdje slavi Uskrs?
Ivana: Prije Uskrsa je korizma, a tjedan prije je Cvjetnica.
Darja: Hoćemo li bojiti jaja?
Ivana: Hoćemo! Djeca će napraviti pisanice.
Darja: A darivate li se?
Ivana: Malo, djeci darujemo slatkiše. To je lijepa tradicija.', 'Darja: Іванно, як тут святкують Великдень?
Ivana: Перед Великоднем — Великий піст, а за тиждень до нього — Квітна неділя.
Darja: Будемо фарбувати яйця?
Ivana: Будемо! Діти зроблять писанки.
Darja: А ви даруєте одне одному подарунки?
Ivana: Трохи, дітям даруємо солодощі. Це гарна традиція.', 'Діалог «Великдень»: «Hoćemo li bojiti jaja?» — «Hoćemo! Djeca će napraviti pisanice.», тобто «Будемо! Діти зроблять писанки.».', (select id from public.lessons where id = 'f67bd38c-a41c-51df-b9c0-081737600fce'), 'PUBLISHED', 'claude_assessment_v5'),
  ('19b0116c-ede7-5a0a-86ac-aa41bb5d6fc8', v_aid, 8, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Kako se ovdje ljudi pozdravljaju?', '["Дашо, заходь! Не треба роззуватися.", "Дякую! У нас звичай роззуватися.", "Чоловіки тиснуть руки, а друзі цілуються двічі в щоку."]'::jsonb, 2, null, '{}'::text[], null, 'Ivana: Dašo, uđi! Ne moraš se izuti.
Daša: Hvala! Kod nas je običaj da se izujemo.
Ivana: I kod nas, ali domaćica ti uvijek da papuče.
Daša: Kako se ovdje ljudi pozdravljaju?
Ivana: Muškarci se rukuju, a prijatelji se ljube dvaput u obraz.
Daša: Dobro je znati!', 'Ivana: Дашо, заходь! Не треба роззуватися.
Daša: Дякую! У нас звичай роззуватися.
Ivana: І в нас так, але господиня завжди дасть тобі тапочки.
Daša: Як тут люди вітаються?
Ivana: Чоловіки тиснуть руки, а друзі цілуються двічі в щоку.
Daša: Добре знати!', 'Діалог «У гостях»: «Kako se ovdje ljudi pozdravljaju?» — «Muškarci se rukuju, a prijatelji se ljube dvaput u obraz.», тобто «Чоловіки тиснуть руки, а друзі цілуються двічі в щоку.».', (select id from public.lessons where id = '2fabcd03-324d-5355-b96e-022723fbeda7'), 'PUBLISHED', 'claude_assessment_v5'),
  ('9b610e0b-22d2-52b5-9e4e-c5204aedf085', v_aid, 9, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Щасливого Нового року!». Що ви скажете?', null, '["Kada su izgradili ove zidine?", "Šetala sam starim gradom.", "Sretna Nova godina!"]'::jsonb, 2, null, '{}'::text[], null, null, null, '«Щасливого Нового року!» — «Sretna Nova godina!».', (select id from public.lessons where id = '33c041a0-e71a-55c1-94c8-64941876c6d2'), 'PUBLISHED', 'claude_assessment_v5'),
  ('a76af275-5657-5673-85aa-51b11704bafb', v_aid, 10, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «кулен (гостра славонська ковбаса)»', null, '[]'::jsonb, null, 'kulen', '{}'::text[], null, null, null, '«кулен (гостра славонська ковбаса)» — kulen.', (select id from public.lessons where id = 'f1b2093d-9699-59af-92b9-ed7bdf7fad49'), 'PUBLISHED', 'claude_assessment_v5'),
  ('9b5d8f90-e5ef-5c1a-a1bf-40771de86e9d', v_aid, 11, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Пршут смачніший за шинку.»', null, '["ukusniji", "je", "od", "Pršut", "šunke."]'::jsonb, null, 'Pršut je ukusniji od šunke.', '{}'::text[], null, null, null, '«Пршут смачніший за шинку.» — «Pršut je ukusniji od šunke.».', (select id from public.lessons where id = 'f1b2093d-9699-59af-92b9-ed7bdf7fad49'), 'PUBLISHED', 'claude_assessment_v5'),
  ('6f7a4ea0-8fc8-5291-8e8e-71111e4e7a0e', v_aid, 12, 'A1', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Ми підемо на різдвяну месу.»', null, '[]'::jsonb, null, 'Ići ćemo na polnoćku.', '{}'::text[], null, null, null, '«Ми підемо на різдвяну месу.» — «Ići ćemo na polnoćku.».', (select id from public.lessons where id = 'f67bd38c-a41c-51df-b9c0-081737600fce'), 'PUBLISHED', 'claude_assessment_v5');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірки рівня A1 за схемою 2026-11-07 (модуль — 2 завдання на урок, середина — 30, фінал — 48) з діалогів, вправ і текстів уроків A1. Потрібна перевірка носієм.');
end $$;

-- Перевірка модуля A1.12 · Модуль A1.12 — Діти, навчання й документи · 16 завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = 'a1-m12' and cefr = 'A1';
  if v_aid is null then raise exception 'Немає тесту a1-m12 — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = '74696b91-4be4-5f6e-a402-198f25a19db8') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from '5a6eadc1-9da1-52c0-a50d-943a3fbffe70'::uuid then
    raise exception 'Тест a1-m12 прив’язаний не до модуля A1.12 — звірте базу';
  end if;
  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
          v_payload, 'assessment_v5: перевірку переведено на схему 2026-11-07 — старі завдання');
  -- старі завдання → DEPRECATED; місця зсуваються за найбільше наявне (унікальність assessment_id + order_index)
  select (coalesce(max(order_index), 0) / 100 + 1) * 100 into v_shift from public.assessment_items where assessment_id = v_aid;
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + v_shift
   where assessment_id = v_aid and status = 'PUBLISHED';
  update public.assessments set description_ua = 'Після модуля: 16 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~8 хв.', estimated_minutes = 8 where id = v_aid;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, answer_alternatives, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('74696b91-4be4-5f6e-a402-198f25a19db8', v_aid, 1, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Добрий день, я хотіла б записати сина в садок.", "Так, денний сон — з першої до третьої.", "Покажіть, будь ласка, посвідчення особи."]'::jsonb, 1, null, '{}'::text[], 'Da, popodnevni odmor je od jedan do tri.', null, null, 'Прозвучало: «Da, popodnevni odmor je od jedan do tri.» — «Так, денний сон — з першої до третьої.».', (select id from public.lessons where id = '42c31cfb-8680-5450-8453-245f3abd475a'), 'PUBLISHED', 'claude_assessment_v5'),
  ('e8046723-d989-5f44-8f18-1da3fe79bdd6', v_aid, 2, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["У третьому «б». Твоя класна керівниця — учителька Ана.", "Як у неї справи? Вона ще погано говорить хорватською.", "Так, після курсу всі слухачі складають іспит."]'::jsonb, 0, null, '{}'::text[], 'U trećem b. Tvoja razrednica je učiteljica Ana.', null, null, 'Прозвучало: «U trećem b. Tvoja razrednica je učiteljica Ana.» — «У третьому «б». Твоя класна керівниця — учителька Ана.».', (select id from public.lessons where id = '7c8e16ec-03f3-55dd-a61a-fb59c2401692'), 'PUBLISHED', 'claude_assessment_v5'),
  ('8291833d-436d-5eaf-9dba-c0d5043d56e3', v_aid, 3, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Чудово, завтра приведу його о восьмій.", "Нічого не відбувається.", "Можна, до суми однієї зарплати."]'::jsonb, 0, null, '{}'::text[], 'Super, sutra ću ga dovesti u osam.', null, null, 'Прозвучало: «Super, sutra ću ga dovesti u osam.» — «Чудово, завтра приведу його о восьмій.».', (select id from public.lessons where id = '42c31cfb-8680-5450-8453-245f3abd475a'), 'PUBLISHED', 'claude_assessment_v5'),
  ('06c9e3c3-ea9d-56c4-bc07-5afa489de1a3', v_aid, 4, 'A1', 'reading', 'understand', 'multiple_choice', 'Який номер екстреної служби?', 'Što raditi kod potresa', '["112", "01 456 7890", "1313"]'::jsonb, 0, null, '{}'::text[], null, 'ŠTO RADITI KOD POTRESA?
Ostanite mirni.
Idite pod stol i čekajte kraj potresa.
Ne idite u lift.
Poslije potresa izađite iz zgrade.
Za pomoć zovite 112 – hitna služba radi 24 sata.', 'ЩО РОБИТИ ПІД ЧАС ЗЕМЛЕТРУСУ?
Зберігайте спокій.
Сховайтеся під стіл і чекайте кінця землетрусу.
Не заходьте в ліфт.
Після землетрусу вийдіть із будівлі.
По допомогу дзвоніть 112 — екстрена служба працює цілодобово.', 'Текст «Що робити під час землетрусу». Правильна відповідь: «112».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('57640148-343e-5b54-bd3a-2e87f5271d15', v_aid, 5, 'A1', 'reading', 'understand', 'multiple_choice', 'До котрої можна забрати дітей?', 'Obavijest u vrtiću', '["До 17:00", "До 13:00", "До 14:30"]'::jsonb, 0, null, '{}'::text[], null, 'OBAVIJEST RODITELJIMA
U ponedjeljak u 17 sati je roditeljski sastanak u vrtiću.
Donesite rezervnu odjeću za dijete i kutiju za užinu.
Popodnevni odmor je od 13 do 14:30.
Djecu možete pokupiti do 17 sati.
Odgojiteljica Ana', 'ОГОЛОШЕННЯ ДЛЯ БАТЬКІВ
У понеділок о 17:00 — батьківські збори в садку.
Принесіть запасний одяг для дитини й коробку для перекусу.
Денний сон — з 13:00 до 14:30.
Дітей можна забрати до 17:00.
Вихователька Ана', 'Текст «Оголошення в садку». Правильна відповідь: «До 17:00».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('88e69743-3f9b-571c-863d-c28f72654dfa', v_aid, 6, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'A preslika putovnice? Mora li biti ovjerena?', '["Ovjeru možeš napraviti kod javnog bilježnika, blizu je.", "Tri godine. A prvi spoj nam je bio u kinu.", "Treba. Uzmi metlu i krpu, hvala što mi pomažeš!"]'::jsonb, 0, null, '{}'::text[], 'A preslika putovnice? Mora li biti ovjerena?', null, null, 'Діалог «Переклад документів»: «A preslika putovnice? Mora li biti ovjerena?» (А копія паспорта? Вона має бути засвідчена?) — «Ovjeru možeš napraviti kod javnog bilježnika, blizu je.» (Засвідчити можна в нотаріуса, це поруч.).', (select id from public.lessons where id = 'fe2839bc-fd72-5e8b-bc0e-937d48a90aa8'), 'PUBLISHED', 'claude_assessment_v5'),
  ('3481db4f-a8cb-5b09-a050-56bffcc53293', v_aid, 7, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'U redu. Moram li donijeti rezervnu odjeću?', '["Oko sat vremena. Za početak preporučujem pršut i paški sir.", "Morate, i papuče. Djeca se često zaprljaju.", "Više ne, sada radim u školi."]'::jsonb, 1, null, '{}'::text[], 'U redu. Moram li donijeti rezervnu odjeću?', null, null, 'Діалог «Перший тиждень»: «U redu. Moram li donijeti rezervnu odjeću?» (Гаразд. Чи треба принести запасний одяг?) — «Morate, i papuče. Djeca se često zaprljaju.» (Так, і тапочки. Діти часто забруднюються.).', (select id from public.lessons where id = '42c31cfb-8680-5450-8453-245f3abd475a'), 'PUBLISHED', 'claude_assessment_v5'),
  ('49db07a0-49f3-51fa-97ce-c573d45a6fd8', v_aid, 8, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Mogu li otvoriti i devizni račun?', '["Smiješ, a poslije ćemo probati ronjenje uz obalu.", "Naravno. Evo vašeg IBAN-a, dajte ga poslodavcu za plaću.", "Boja mi se sviđa, ali uzorak je malo staromodan."]'::jsonb, 1, null, '{}'::text[], 'Mogu li otvoriti i devizni račun?', null, null, 'Діалог «Відкриваю рахунок»: «Mogu li otvoriti i devizni račun?» (Можна відкрити й валютний рахунок?) — «Naravno. Evo vašeg IBAN-a, dajte ga poslodavcu za plaću.» (Звісно. Ось ваш IBAN, дайте його роботодавцю для зарплати.).', (select id from public.lessons where id = 'fee5b77b-dc3b-5fd5-818a-c5496e95c23b'), 'PUBLISHED', 'claude_assessment_v5'),
  ('6de484c1-2512-5db3-afdc-995dc35e162e', v_aid, 9, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Što trebam donijeti?', '["Добрий день, у мене наступного місяця спливає тимчасове проживання.", "Сплатіть його до подання. Рішення отримаєте поштою.", "Паспорт, підтвердження житла й підтвердження коштів на утримання."]'::jsonb, 2, null, '{}'::text[], null, 'Daša: Dobar dan, moj privremeni boravak istječe sljedeći mjesec.
Službenica: Zahtjev za produljenje predajte najkasnije šezdeset dana prije isteka.
Daša: Što trebam donijeti?
Službenica: Putovnicu, dokaz o smještaju i dokaz o sredstvima za uzdržavanje.
Daša: A upravna pristojba?
Službenica: Platite je prije predaje. Rješenje dobivate poštom.', 'Daša: Добрий день, у мене наступного місяця спливає тимчасове проживання.
Službenica: Заяву на продовження подайте не пізніше ніж за шістдесят днів до закінчення терміну.
Daša: Що мені треба принести?
Službenica: Паспорт, підтвердження житла й підтвердження коштів на утримання.
Daša: А адміністративний збір?
Službenica: Сплатіть його до подання. Рішення отримаєте поштою.', 'Діалог «У відділі для іноземців»: «Što trebam donijeti?» — «Putovnicu, dokaz o smještaju i dokaz o sredstvima za uzdržavanje.», тобто «Паспорт, підтвердження житла й підтвердження коштів на утримання.».', (select id from public.lessons where id = 'fe2839bc-fd72-5e8b-bc0e-937d48a90aa8'), 'PUBLISHED', 'claude_assessment_v5'),
  ('8892735c-161e-5fa6-8ed3-f0781696a2d7', v_aid, 10, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Četiri. Ima li slobodnih mjesta?', '["Зараз немає, але можете поставити його в список очікування.", "І цю посилку в Україну, будь ласка.", "Свідоцтво про народження, медичну довідку й ваш OIB."]'::jsonb, 0, null, '{}'::text[], null, 'Daša: Dobar dan, htjela bih upisati sina u vrtić.
Ravnateljica: Koliko godina ima vaš sin?
Daša: Četiri. Ima li slobodnih mjesta?
Ravnateljica: Trenutno nema, ali možete ga staviti na listu čekanja.
Daša: Što moram donijeti za upis?
Ravnateljica: Rodni list, liječničku potvrdu i vaš OIB.', 'Daša: Добрий день, я хотіла б записати сина в садок.
Ravnateljica: Скільки років вашому синові?
Daša: Чотири. Чи є вільні місця?
Ravnateljica: Зараз немає, але можете поставити його в список очікування.
Daša: Що я маю принести для запису?
Ravnateljica: Свідоцтво про народження, медичну довідку й ваш OIB.', 'Діалог «Запис у садок»: «Četiri. Ima li slobodnih mjesta?» — «Trenutno nema, ali možete ga staviti na listu čekanja.», тобто «Зараз немає, але можете поставити його в список очікування.».', (select id from public.lessons where id = '42c31cfb-8680-5450-8453-245f3abd475a'), 'PUBLISHED', 'claude_assessment_v5'),
  ('1dd595a9-969f-5287-ab07-d9df04c47124', v_aid, 11, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Де нотаріус?». Що ви скажете?', null, '["Gdje je javni bilježnik?", "Trebam debitnu karticu.", "Preporučeno, molim."]'::jsonb, 0, null, '{}'::text[], null, null, null, '«Де нотаріус?» — «Gdje je javni bilježnik?».', (select id from public.lessons where id = 'fe2839bc-fd72-5e8b-bc0e-937d48a90aa8'), 'PUBLISHED', 'claude_assessment_v5'),
  ('74dace8c-7180-5617-a05d-036d87015e26', v_aid, 12, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Подзвоніть на 112!». Що ви скажете?', null, '["Idem na tečaj za početnike.", "Kolika je naknada za račun?", "Nazovite sto dvanaest!"]'::jsonb, 2, null, '{}'::text[], null, null, null, '«Подзвоніть на 112!» — «Nazovite sto dvanaest!».', (select id from public.lessons where id = '692e9310-7a5b-5adf-9f0a-a66b72fc5459'), 'PUBLISHED', 'claude_assessment_v5'),
  ('0bc69fb6-241c-5ad9-ad25-7a5bb1880158', v_aid, 13, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «ощадний вклад»', null, '[]'::jsonb, null, 'štedni račun', '{}'::text[], null, null, null, '«ощадний вклад» — štedni račun.', (select id from public.lessons where id = 'fee5b77b-dc3b-5fd5-818a-c5496e95c23b'), 'PUBLISHED', 'claude_assessment_v5'),
  ('7d3c3b29-adc0-587a-9303-6f4aaa85229e', v_aid, 14, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Я хочу відкрити рахунок.»', null, '["račun.", "otvoriti", "Želim"]'::jsonb, null, 'Želim otvoriti račun.', '{}'::text[], null, null, null, '«Я хочу відкрити рахунок.» — «Želim otvoriti račun.».', (select id from public.lessons where id = 'fee5b77b-dc3b-5fd5-818a-c5496e95c23b'), 'PUBLISHED', 'claude_assessment_v5'),
  ('2a53ab53-edfa-5163-bb17-b2a4b54feee8', v_aid, 15, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «У будинку пожежа!»', null, '["zgradi", "požar!", "U", "je"]'::jsonb, null, 'U zgradi je požar!', array['Požar je u zgradi!']::text[], null, null, null, '«У будинку пожежа!» — «U zgradi je požar!».', (select id from public.lessons where id = '692e9310-7a5b-5adf-9f0a-a66b72fc5459'), 'PUBLISHED', 'claude_assessment_v5'),
  ('fcfef40b-69f1-530f-8cde-57ee253392a2', v_aid, 16, 'A1', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Коли спливає ваш дозвіл?»', null, '[]'::jsonb, null, 'Kada vam istječe dozvola?', '{}'::text[], null, null, null, '«Коли спливає ваш дозвіл?» — «Kada vam istječe dozvola?».', (select id from public.lessons where id = 'fe2839bc-fd72-5e8b-bc0e-937d48a90aa8'), 'PUBLISHED', 'claude_assessment_v5');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірки рівня A1 за схемою 2026-11-07 (модуль — 2 завдання на урок, середина — 30, фінал — 48) з діалогів, вправ і текстів уроків A1. Потрібна перевірка носієм.');
end $$;

-- Перевірка модуля A1.13 · Модуль A1.13 — Підсумок A1: моє життя в Хорватії · 12 завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = 'a1-m13' and cefr = 'A1';
  if v_aid is null then raise exception 'Немає тесту a1-m13 — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = '0428d914-caee-56c8-be1c-b91ec744a9d6') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from '34064af4-9715-5f07-b87c-a5e28eb8127b'::uuid then
    raise exception 'Тест a1-m13 прив’язаний не до модуля A1.13 — звірте базу';
  end if;
  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
          v_payload, 'assessment_v5: перевірку переведено на схему 2026-11-07 — старі завдання');
  -- старі завдання → DEPRECATED; місця зсуваються за найбільше наявне (унікальність assessment_id + order_index)
  select (coalesce(max(order_index), 0) / 100 + 1) * 100 into v_shift from public.assessment_items where assessment_id = v_aid;
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + v_shift
   where assessment_id = v_aid and status = 'PUBLISHED';
  update public.assessments set description_ua = 'Після модуля: 12 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~6 хв.', estimated_minutes = 6 where id = v_aid;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, answer_alternatives, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('0428d914-caee-56c8-be1c-b91ec744a9d6', v_aid, 1, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Даріє, чим ти займаєшся у вільний час?", "Даріє, ти сумуєш за Україною?", "Маєш якусь пораду для тих, хто тільки приїжджає?"]'::jsonb, 2, null, '{}'::text[], 'Imaš li neki savjet za one koji tek dolaze?', null, null, 'Прозвучало: «Imaš li neki savjet za one koji tek dolaze?» — «Маєш якусь пораду для тих, хто тільки приїжджає?».', (select id from public.lessons where id = 'dbb91fa1-4a97-5c04-99a8-8ac1d508b952'), 'PUBLISHED', 'claude_assessment_v5'),
  ('158f628a-ef5d-5042-a8bd-897c38698d50', v_aid, 2, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Дашо, коли ти переїхала до Хорватії?", "Який у тебе найгарніший спогад з першого року?", "Як ти тут подружилася з людьми?"]'::jsonb, 1, null, '{}'::text[], 'Koje ti je najljepše sjećanje iz prve godine?', null, null, 'Прозвучало: «Koje ti je najljepše sjećanje iz prve godine?» — «Який у тебе найгарніший спогад з першого року?».', (select id from public.lessons where id = '4b2bf351-c5fc-57ca-9fd9-24fb8a4bfc0d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('229c7a84-5161-5803-b063-97738db76064', v_aid, 3, 'A1', 'reading', 'understand', 'multiple_choice', 'Коли заняття?', 'Prijavnica za tečaj', '["У суботу", "У вівторок і четвер", "У понеділок і середу"]'::jsonb, 1, null, '{}'::text[], null, 'PRIJAVNICA ZA TEČAJ HRVATSKOGA JEZIKA
Ime i prezime: Olena Kovalenko
Datum rođenja: 12. 3. 1990.
Državljanstvo: ukrajinsko
Adresa: Ilica 25, Zagreb
Broj mobitela: 091 765 4321
Razina: A1
Termin: utorak i četvrtak, 18 – 20 sati
Potpis: Olena Kovalenko', 'АНКЕТА НА КУРС ХОРВАТСЬКОЇ МОВИ
Ім’я та прізвище: Олена Коваленко
Дата народження: 12.03.1990
Громадянство: українське
Адреса: Іліца, 25, Загреб
Номер мобільного: 091 765 4321
Рівень: A1
Час занять: вівторок і четвер, 18 – 20 година
Підпис: Олена Коваленко', 'Текст «Анкета на курс». Правильна відповідь: «У вівторок і четвер».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('b3bc0b47-ce18-5fdb-92fb-46bcbde4daea', v_aid, 4, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Koja je vaša struka?', '["Triput, a vikendom igraju utakmice za momčad škole.", "Temperatura zraka do trideset osam.", "Po struci sam knjigovođa, a sada radim u trgovini."]'::jsonb, 2, null, '{}'::text[], 'Koja je vaša struka?', null, null, 'Діалог «Співбесіда»: «Koja je vaša struka?» (Яка ваша спеціальність?) — «Po struci sam knjigovođa, a sada radim u trgovini.» (За фахом я бухгалтерка, а зараз працюю в магазині.).', (select id from public.lessons where id = 'fc1baff0-0e48-5676-bd3c-47d88d31e582'), 'PUBLISHED', 'claude_assessment_v5'),
  ('b9c6f368-806f-5d13-b1d7-628b7e0245d1', v_aid, 5, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Dašo, koji su tvoji ciljevi za sljedeću godinu?', '["Unesi kod i promijeni lozinku. Napravi jaku!", "Željeznica ima zamjenski autobus ispred kolodvora.", "Usavršit ću hrvatski i položiti ispit B1."]'::jsonb, 2, null, '{}'::text[], 'Dašo, koji su tvoji ciljevi za sljedeću godinu?', null, null, 'Діалог «Плани на рік»: «Dašo, koji su tvoji ciljevi za sljedeću godinu?» (Дашо, які в тебе цілі на наступний рік?) — «Usavršit ću hrvatski i položiti ispit B1.» (Я вдосконалю хорватську й складу іспит B1.).', (select id from public.lessons where id = 'dbb91fa1-4a97-5c04-99a8-8ac1d508b952'), 'PUBLISHED', 'claude_assessment_v5'),
  ('bf6b7f3a-b00f-5812-b0b2-b1d711ab2058', v_aid, 6, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Koja je najveća prednost života ovdje?', '["Drži ovu tipku sa strane, bako.", "Sigurnost i more. A nedostatak — birokracija!", "Pekmez od marelica, ako ga još imamo."]'::jsonb, 1, null, '{}'::text[], 'Koja je najveća prednost života ovdje?', null, null, 'Діалог «Залишитися чи ні?»: «Koja je najveća prednost života ovdje?» (Яка найбільша перевага життя тут?) — «Sigurnost i more. A nedostatak — birokracija!» (Безпека й море. А недолік — бюрократія!).', (select id from public.lessons where id = 'dbb91fa1-4a97-5c04-99a8-8ac1d508b952'), 'PUBLISHED', 'claude_assessment_v5'),
  ('33b3a0e5-4446-5e07-95e9-3eab54fb338d', v_aid, 7, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Darja, čime se baviš u slobodno vrijeme?', '["Це одразу видно. І ти дуже відкрита.", "Я комунікабельна, люблю знайомитися з новими людьми.", "Я цікавлюся фотографією та історією."]'::jsonb, 2, null, '{}'::text[], null, 'Ivana: Darja, čime se baviš u slobodno vrijeme?
Darja: Zanimam se za fotografiju i povijest.
Ivana: Vidi se da si znatiželjna!
Darja: Jesam. A ti? Koja je tvoja najbolja osobina?
Ivana: Komunikativna sam, volim upoznavati nove ljude.
Darja: To se odmah vidi. I jako si otvorena.', 'Ivana: Даріє, чим ти займаєшся у вільний час?
Darja: Я цікавлюся фотографією та історією.
Ivana: Видно, що ти допитлива!
Darja: Так. А ти? Яка твоя найкраща риса?
Ivana: Я комунікабельна, люблю знайомитися з новими людьми.
Darja: Це одразу видно. І ти дуже відкрита.', 'Діалог «Нове знайомство»: «Darja, čime se baviš u slobodno vrijeme?» — «Zanimam se za fotografiju i povijest.», тобто «Я цікавлюся фотографією та історією.».', (select id from public.lessons where id = 'fc1baff0-0e48-5676-bd3c-47d88d31e582'), 'PUBLISHED', 'claude_assessment_v5'),
  ('6f0d4eba-06dc-5633-af9c-00a36327e649', v_aid, 8, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Što ti je bilo najteže?', '["Три роки тому. Початок був дуже важкий.", "Так! Мене здивувало, скільки часу люди тут мають на каву.", "Мова й документи. Але крок за кроком я дала собі раду."]'::jsonb, 2, null, '{}'::text[], null, 'Marko: Dašo, kad si se doselila u Hrvatsku?
Daša: Prije tri godine. Početak je bio jako težak.
Marko: Što ti je bilo najteže?
Daša: Jezik i papiri. Ali korak po korak, snašla sam se.
Marko: A jesi li se brzo navikla na naš mentalitet?
Daša: Jesam! Iznenadilo me koliko ljudi ovdje imaju vremena za kavu.', 'Marko: Дашо, коли ти переїхала до Хорватії?
Daša: Три роки тому. Початок був дуже важкий.
Marko: Що тобі було найважче?
Daša: Мова й документи. Але крок за кроком я дала собі раду.
Marko: А ти швидко звикла до нашого менталітету?
Daša: Так! Мене здивувало, скільки часу люди тут мають на каву.', 'Діалог «Перший рік»: «Što ti je bilo najteže?» — «Jezik i papiri. Ali korak po korak, snašla sam se.», тобто «Мова й документи. Але крок за кроком я дала собі раду.».', (select id from public.lessons where id = '4b2bf351-c5fc-57ca-9fd9-24fb8a4bfc0d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('0dfdc574-da2a-5879-973d-01dcfb152a40', v_aid, 9, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Коли ти переїхала?». Що ви скажете?', null, '["Koji su tvoji ciljevi?", "Kada si se doselila?", "Pouzdana sam i strpljiva."]'::jsonb, 1, null, '{}'::text[], null, null, null, '«Коли ти переїхала?» — «Kada si se doselila?».', (select id from public.lessons where id = '4b2bf351-c5fc-57ca-9fd9-24fb8a4bfc0d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('b7ee58f0-023d-50aa-8843-3a356bcce41e', v_aid, 10, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «звикнути»', null, '[]'::jsonb, null, 'naviknuti se', '{}'::text[], null, null, null, '«звикнути» — naviknuti se.', (select id from public.lessons where id = '4b2bf351-c5fc-57ca-9fd9-24fb8a4bfc0d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('2fba6a1d-3c54-5d50-aadf-29c5d4f2313d', v_aid, 11, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Я виросла в Києві.»', null, '["sam", "Kijevu.", "Odrasla", "u"]'::jsonb, null, 'Odrasla sam u Kijevu.', array['U Kijevu sam odrasla.']::text[], null, null, null, '«Я виросла в Києві.» — «Odrasla sam u Kijevu.».', (select id from public.lessons where id = 'fc1baff0-0e48-5676-bd3c-47d88d31e582'), 'PUBLISHED', 'claude_assessment_v5'),
  ('32ab3308-c884-5acc-9ed7-8ae445a323d0', v_aid, 12, 'A1', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Я вдосконалю хорватську.»', null, '[]'::jsonb, null, 'Usavršit ću hrvatski.', '{}'::text[], null, null, null, '«Я вдосконалю хорватську.» — «Usavršit ću hrvatski.».', (select id from public.lessons where id = 'dbb91fa1-4a97-5c04-99a8-8ac1d508b952'), 'PUBLISHED', 'claude_assessment_v5');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірки рівня A1 за схемою 2026-11-07 (модуль — 2 завдання на урок, середина — 30, фінал — 48) з діалогів, вправ і текстів уроків A1. Потрібна перевірка носієм.');
end $$;

-- Перевірка середини рівня A1 · 30 завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = 'a1-mid' and cefr = 'A1';
  if v_aid is null then raise exception 'Немає тесту a1-mid — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = '62c3b7b1-a4fb-57b6-a7e7-2def7950e50f') then return; end if;  -- уже оновлено
  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
          v_payload, 'assessment_v5: перевірку переведено на схему 2026-11-07 — старі завдання');
  -- старі завдання → DEPRECATED; місця зсуваються за найбільше наявне (унікальність assessment_id + order_index)
  select (coalesce(max(order_index), 0) / 100 + 1) * 100 into v_shift from public.assessment_items where assessment_id = v_aid;
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + v_shift
   where assessment_id = v_aid and status = 'PUBLISHED';
  update public.assessments set description_ua = 'Середина рівня (модулі A1.1–A1.6): 30 завдань на 4 навички. ~15 хв.', estimated_minutes = 15 where id = v_aid;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, answer_alternatives, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('62c3b7b1-a4fb-57b6-a7e7-2def7950e50f', v_aid, 1, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Є. Квартира одразу готова до заселення й має великий балкон.", "Добре. І постав термостат на двадцять два.", "Ні, тиха й безпечна, і багато зелені."]'::jsonb, 1, null, '{}'::text[], 'Može. I stavi termostat na dvadeset dva.', null, null, 'Прозвучало: «Može. I stavi termostat na dvadeset dva.» — «Добре. І постав термостат на двадцять два.».', (select id from public.lessons where id = '62b118f9-a5e0-587b-82f8-39de181ddeba'), 'PUBLISHED', 'claude_assessment_v5'),
  ('932d6275-f052-5fc4-98f1-1413a0d85205', v_aid, 2, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["А корм для собак?", "Івано, у тебе є час у четвер?", "А ти регулярно плаваєш?"]'::jsonb, 0, null, '{}'::text[], 'A hrana za pse?', null, null, 'Прозвучало: «A hrana za pse?» — «А корм для собак?».', (select id from public.lessons where id = '1968c7d5-4e3a-5b1e-92f6-88df711e9c54'), 'PUBLISHED', 'claude_assessment_v5'),
  ('d8b1af9c-b8fa-540b-b322-f14f401ca888', v_aid, 3, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Без проблем, вона поміститься в багажник.", "Добрий день, заправте мені повний бак, будь ласка.", "На кільці другий з’їзд, потім перший поворот праворуч."]'::jsonb, 1, null, '{}'::text[], 'Dobar dan, natočite mi pun rezervoar, molim.', null, null, 'Прозвучало: «Dobar dan, natočite mi pun rezervoar, molim.» — «Добрий день, заправте мені повний бак, будь ласка.».', (select id from public.lessons where id = 'd6ca64d8-4c71-5936-a930-51e400f5681d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('f85ae4e8-509a-5ebe-b9d5-a1fbb4d5575b', v_aid, 4, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Тоді беру чорні. Погана якість не окупається.", "Будь-яку чорну. А тобі потрібні нові бритви.", "Можна, але для цього йдіть у службу підтримки клієнтів."]'::jsonb, 2, null, '{}'::text[], 'Možete, ali za to idite u službu za korisnike.', null, null, 'Прозвучало: «Možete, ali za to idite u službu za korisnike.» — «Можна, але для цього йдіть у службу підтримки клієнтів.».', (select id from public.lessons where id = '6a7b0f42-510b-521e-9cc0-f77b2659d838'), 'PUBLISHED', 'claude_assessment_v5'),
  ('f87b6a2a-51d5-5a86-a8ce-6c5109aba404', v_aid, 5, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Центр може оплатити вам курси.", "Шукаємо. Це робота на неповний день.", "На дошці оголошень, біля кухні."]'::jsonb, 2, null, '{}'::text[], 'Na oglasnoj ploči, pored kuhinje.', null, null, 'Прозвучало: «Na oglasnoj ploči, pored kuhinje.» — «На дошці оголошень, біля кухні.».', (select id from public.lessons where id = '99088d92-0f0c-52c2-b51f-548d903fc9ef'), 'PUBLISHED', 'claude_assessment_v5'),
  ('96128980-36c6-53f3-b7ac-f5523df245e5', v_aid, 6, 'A1', 'reading', 'understand', 'multiple_choice', 'Хто чекає на рецепції?', 'Mail od poslodavca', '["Директор", "Охоронець", "Керівниця зміни"]'::jsonb, 2, null, '{}'::text[], null, 'Poštovani gospodine Melnyk,
dobro došli u našu tvrtku! Vaš prvi radni dan je u ponedjeljak. Dođite u osam sati na ulaz B. Na recepciji Vas čeka voditeljica smjene, gospođa Babić. Ponesite osobnu iskaznicu, OIB i broj računa u banci. Radnu odjeću dobivate prvi dan.
Lijep pozdrav,
Ana Perić, ured za ljudske resurse', 'Шановний пане Мельник,
ласкаво просимо до нашої компанії! Ваш перший робочий день — у понеділок. Приходьте о восьмій годині до входу B. На рецепції на вас чекатиме керівниця зміни, пані Бабич. Візьміть із собою посвідчення особи, OIB і номер банківського рахунку. Робочий одяг отримаєте першого дня.
З повагою,
Ана Перич, відділ кадрів', 'Текст «Лист від роботодавця». Правильна відповідь: «Керівниця зміни».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('5738f7a7-4455-50cd-95e0-55db19a560dc', v_aid, 7, 'A1', 'reading', 'understand', 'multiple_choice', 'Що він робить увечері?', 'Tarasov običan dan', '["Працює", "Читає або дивиться фільм", "Тренується"]'::jsonb, 1, null, '{}'::text[], null, 'Taras živi u Zagrebu. Svaki dan se budi u šest i pol. Prvo se tušira, a onda doručkuje s obitelji. Na posao ide tramvajem. Radi u skladištu od osam do četiri. Poslije posla ide u trgovinu ili u park sa psom. Navečer obično čita ili gleda film. Spava u jedanaest, jer je ujutro opet rano.', 'Тарас живе в Загребі. Щодня він прокидається о пів на сьому. Спочатку приймає душ, а потім снідає з родиною. На роботу їде трамваєм. Працює на складі з восьмої до четвертої. Після роботи йде в магазин або в парк із собакою. Увечері зазвичай читає або дивиться фільм. Лягає спати об одинадцятій, бо вранці знову рано.', 'Текст «Звичайний день Тараса». Правильна відповідь: «Читає або дивиться фільм».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('d7116870-293d-5cef-8a32-0c333aacae25', v_aid, 8, 'A1', 'reading', 'understand', 'multiple_choice', 'Що коштує 2 € цього тижня?', 'Nova pekara', '["Кава з собою і круасан", "Хліб", "Бурек"]'::jsonb, 0, null, '{}'::text[], null, 'NOVA PEKARA U VAŠEM KVARTU!
Svaki dan svježi kruh, peciva i burek.
Otvoreno od 6 do 20 sati, nedjeljom od 7 do 13.
Ovaj tjedan: kava za van i kroasan samo 2 €!
Imamo i integralni kruh bez šećera.
Dođite i probajte!', 'НОВА ПЕКАРНЯ У ВАШОМУ РАЙОНІ!
Щодня свіжий хліб, булочки й бурек.
Відчинено з 6 до 20 години, у неділю з 7 до 13.
Цього тижня: кава з собою і круасан лише 2 €!
У нас є й цільнозерновий хліб без цукру.
Приходьте й скуштуйте!', 'Текст «Нова пекарня». Правильна відповідь: «Кава з собою і круасан».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('b2ce4f31-954d-5335-8856-d631d3b5367c', v_aid, 9, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Dašo, gdje radi tvoj brat?', '["Sutra popodne, ako stigne rezervni dio.", "Jako curi, a i odvod u kupaonici je začepljen.", "On je zidar, radi na gradilištu u Novom Zagrebu."]'::jsonb, 2, null, '{}'::text[], 'Dašo, gdje radi tvoj brat?', null, null, 'Діалог «Хто ким працює?»: «Dašo, gdje radi tvoj brat?» (Дашо, де працює твій брат?) — «On je zidar, radi na gradilištu u Novom Zagrebu.» (Він муляр, працює на будові в Новому Загребі.).', (select id from public.lessons where id = 'b369f01f-4a84-57b4-98cb-150d236f4d7f'), 'PUBLISHED', 'claude_assessment_v5'),
  ('6ffdbb93-ede9-5e62-be42-65966de4f96a', v_aid, 10, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Je li ova orada svježa?', '["Jutros je ulovljena, kao i brancin.", "Tražimo. Radno mjesto je na nepuno radno vrijeme.", "Malo, jer dijete spava."]'::jsonb, 0, null, '{}'::text[], 'Je li ova orada svježa?', null, null, 'Діалог «На рибному ринку»: «Je li ova orada svježa?» (Ця дорада свіжа?) — «Jutros je ulovljena, kao i brancin.» (Її впіймали сьогодні вранці, як і сібаса.).', (select id from public.lessons where id = 'ae33e31a-f937-5305-908e-3d957df15f6a'), 'PUBLISHED', 'claude_assessment_v5'),
  ('8dfd5ec6-c71f-5219-8bce-9ad14870bbd7', v_aid, 11, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Što ti jedeš ujutro?', '["Plave su jeftinije, ali crne su kvalitetnije.", "Obično zobene pahuljice s voćem i malo meda.", "Kupaći kostim, kratke hlače i nekoliko tankih majica."]'::jsonb, 1, null, '{}'::text[], 'Što ti jedeš ujutro?', null, null, 'Діалог «Здоровий сніданок»: «Što ti jedeš ujutro?» (Що ти їси зранку?) — «Obično zobene pahuljice s voćem i malo meda.» (Зазвичай вівсянку з фруктами й трохи меду.).', (select id from public.lessons where id = 'bb7bc159-cb40-5a8a-91b7-c6da05c6342a'), 'PUBLISHED', 'claude_assessment_v5'),
  ('dc82dfa1-93a1-581d-9594-268c5821db97', v_aid, 12, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Oprostite, kako doći do hotela Park?', '["Kroj je lijep, ali rukavi su ti predugi.", "Nakon naplatne kućice idite obilaznicom.", "Jedan dan je plaćen. Trebaš moje odobrenje."]'::jsonb, 1, null, '{}'::text[], 'Oprostite, kako doći do hotela Park?', null, null, 'Діалог «Як доїхати до готелю?»: «Oprostite, kako doći do hotela Park?» (Перепрошую, як доїхати до готелю «Парк»?) — «Nakon naplatne kućice idite obilaznicom.» (Після пункту оплати їдьте об’їзною.).', (select id from public.lessons where id = '06f927cf-f38c-51b5-a1f9-696698ad23fb'), 'PUBLISHED', 'claude_assessment_v5'),
  ('7684b18e-89f1-5a48-8a35-87df42b6ec00', v_aid, 13, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Darja, što da poklonim Ani za rođendan?', '["Ujutro sam imala obuku, a mentorica mi je objasnila program.", "Možda naušnice? Ona obožava nakit.", "Još ne, upravo se oblačim."]'::jsonb, 1, null, '{}'::text[], 'Darja, što da poklonim Ani za rođendan?', null, null, 'Діалог «Що подарувати?»: «Darja, što da poklonim Ani za rođendan?» (Даріє, що мені подарувати Ані на день народження?) — «Možda naušnice? Ona obožava nakit.» (Може, сережки? Вона обожнює прикраси.).', (select id from public.lessons where id = '86d268a5-7193-53c5-955b-cf6cc69116f1'), 'PUBLISHED', 'claude_assessment_v5'),
  ('0701b1c9-b674-5117-adec-9dd89b6ef461', v_aid, 14, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Smijemo li sušiti rublje na tavanu?', '["Smijete, tavan je zajednički prostor.", "Let iz Beča, slijetanje u deset sati.", "Poništač je kod vrata, žuti aparat."]'::jsonb, 0, null, '{}'::text[], 'Smijemo li sušiti rublje na tavanu?', null, null, 'Діалог «Розмова з управителем»: «Smijemo li sušiti rublje na tavanu?» (Можна сушити білизну на горищі?) — «Smijete, tavan je zajednički prostor.» (Можна, горище — місце загального користування.).', (select id from public.lessons where id = 'f296bc84-8059-5981-a5b9-9d4531627e18'), 'PUBLISHED', 'claude_assessment_v5'),
  ('f1a84dec-be51-52d5-8188-ded21b93625a', v_aid, 15, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Dašo, koliko često ideš na trening?', '["Šest eura neto, plaćen prijevoz.", "Brzi vlak polazi u osam i petnaest.", "Svaki drugi dan, a vikendom trčim uz more."]'::jsonb, 2, null, '{}'::text[], 'Dašo, koliko često ideš na trening?', null, null, 'Діалог «Спорт і звички»: «Dašo, koliko često ideš na trening?» (Дашо, як часто ти ходиш на тренування?) — «Svaki drugi dan, a vikendom trčim uz more.» (Через день, а на вихідних бігаю вздовж моря.).', (select id from public.lessons where id = '959e879f-a28d-5bed-9c09-16cff91ef456'), 'PUBLISHED', 'claude_assessment_v5'),
  ('385d3358-1fd2-5fb7-96c5-a1e6e43aac45', v_aid, 16, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Mogu li ponijeti loptu u vrtić?', '["Я ще одягаюся, мамо.", "Можна. І візьми шапку, надворі холодно!", "Причешися і взуйся, я чекаю тебе біля дверей."]'::jsonb, 1, null, '{}'::text[], null, 'Darja: Filipe, jesi li spreman? Za deset minuta krećemo.
Filip: Još se oblačim, mama.
Darja: Počešljaj se i obuj se, čekam te na vratima.
Filip: Mogu li ponijeti loptu u vrtić?
Darja: Možeš. I ponesi kapu, vani je hladno!
Filip: Dobro! Mama, ti se danas ne šminkaš?', 'Darja: Філіпе, ти готовий? Через десять хвилин вирушаємо.
Filip: Я ще одягаюся, мамо.
Darja: Причешися і взуйся, я чекаю тебе біля дверей.
Filip: Можна мені взяти м’яч у садок?
Darja: Можна. І візьми шапку, надворі холодно!
Filip: Добре! Мамо, ти сьогодні не фарбуєшся?', 'Діалог «Збираємо дитину»: «Mogu li ponijeti loptu u vrtić?» — «Možeš. I ponesi kapu, vani je hladno!», тобто «Можна. І візьми шапку, надворі холодно!».', (select id from public.lessons where id = '54f17cf7-3c17-5978-b400-b6b6888c9f84'), 'PUBLISHED', 'claude_assessment_v5'),
  ('a542e489-b013-5a16-880b-e876a7638c66', v_aid, 17, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Moje dijete ima mučninu. Možemo li sjesti naprijed?', '["Добрий день. Будь ласка, пристебніться.", "Звісно, перше сидіння вільне.", "Лише раз, на зоні відпочинку."]'::jsonb, 1, null, '{}'::text[], null, 'Vozač: Dobar dan. Molim vas, vežite pojaseve.
Darja: Oprostite, staje li autobus usput?
Vozač: Samo jednom, na odmorištu.
Darja: Moje dijete ima mučninu. Možemo li sjesti naprijed?
Vozač: Naravno, prvo sjedalo je slobodno.
Darja: Hvala. Stižemo li u Zadar u podne?', 'Vozač: Добрий день. Будь ласка, пристебніться.
Darja: Перепрошую, автобус зупиняється дорогою?
Vozač: Лише раз, на зоні відпочинку.
Darja: Мою дитину нудить. Можемо сісти спереду?
Vozač: Звісно, перше сидіння вільне.
Darja: Дякую. Ми будемо в Задарі опівдні?', 'Діалог «В автобусі»: «Moje dijete ima mučninu. Možemo li sjesti naprijed?» — «Naravno, prvo sjedalo je slobodno.», тобто «Звісно, перше сидіння вільне.».', (select id from public.lessons where id = 'c1b32b15-8f3c-5f75-bba9-e831d544ec7b'), 'PUBLISHED', 'claude_assessment_v5'),
  ('684cdaec-9fad-5e95-9eb9-ec4f5e4da270', v_aid, 18, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Ivana, sviđa li ti se ova haljina?', '["Колір мені подобається, але візерунок трохи старомодний.", "Саме так. Якщо тобі сподобається — бери!", "Знаю, ти обожнюєш джинси й кросівки."]'::jsonb, 0, null, '{}'::text[], null, 'Daša: Ivana, sviđa li ti se ova haljina?
Ivana: Boja mi se sviđa, ali uzorak je malo staromodan.
Daša: Meni se sviđa. Elegantna je, a nije skupa.
Ivana: Istina, ali ja više volim ležeran stil.
Daša: Znam, ti obožavaš traperice i tenisice.
Ivana: Tako je. Ako ti se svidi, uzmi je!', 'Daša: Івано, тобі подобається ця сукня?
Ivana: Колір мені подобається, але візерунок трохи старомодний.
Daša: А мені подобається. Вона елегантна й недорога.
Ivana: Правда, але я більше люблю невимушений стиль.
Daša: Знаю, ти обожнюєш джинси й кросівки.
Ivana: Саме так. Якщо тобі сподобається — бери!', 'Діалог «Тобі подобається?»: «Ivana, sviđa li ti se ova haljina?» — «Boja mi se sviđa, ali uzorak je malo staromodan.», тобто «Колір мені подобається, але візерунок трохи старомодний.».', (select id from public.lessons where id = '9a979d32-2f4b-5127-bc22-7292763c7de4'), 'PUBLISHED', 'claude_assessment_v5'),
  ('7eefce7c-3c81-5f17-8b6d-f5fb6bf687f6', v_aid, 19, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Možete li je dostaviti u subotu?', '["Цей на акції, і до нього є крісло того ж кольору.", "Можемо. Монтаж безкоштовний.", "Чудово. Нам ще потрібен обідній стіл на шістьох."]'::jsonb, 1, null, '{}'::text[], null, 'Daša: Tražimo ugaonu garnituru za dnevni boravak.
Prodavač: Ova je na akciji, a ima i naslonjač u istoj boji.
Daša: Možete li je dostaviti u subotu?
Prodavač: Možemo. Montiranje je besplatno.
Daša: Odlično. Treba nam i blagovaonski stol za šest osoba.
Prodavač: Stolovi su na drugom katu, pored polica za knjige.', 'Daša: Ми шукаємо кутовий диван для вітальні.
Prodavač: Цей на акції, і до нього є крісло того ж кольору.
Daša: Можете доставити його в суботу?
Prodavač: Можемо. Монтаж безкоштовний.
Daša: Чудово. Нам ще потрібен обідній стіл на шістьох.
Prodavač: Столи на другому поверсі, біля книжкових полиць.', 'Діалог «У меблевому магазині»: «Možete li je dostaviti u subotu?» — «Možemo. Montiranje je besplatno.», тобто «Можемо. Монтаж безкоштовний.».', (select id from public.lessons where id = 'de93d3ab-6769-5daf-9560-8858285a8136'), 'PUBLISHED', 'claude_assessment_v5'),
  ('25f19121-face-5148-b2c9-8d72e245b1bf', v_aid, 20, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Можу я їх обміняти?». Що ви скажете?', null, '["Sviđa li ti se ova haljina?", "Gdje je moja pošiljka?", "Mogu li ih zamijeniti?"]'::jsonb, 2, null, '{}'::text[], null, null, null, '«Можу я їх обміняти?» — «Mogu li ih zamijeniti?».', (select id from public.lessons where id = '6a7b0f42-510b-521e-9cc0-f77b2659d838'), 'PUBLISHED', 'claude_assessment_v5'),
  ('14b89d35-8bd7-5be0-af51-59dcf9ff89cd', v_aid, 21, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Кран тече». Що ви скажете?', null, '["Donesi bušilicu.", "Slavina curi.", "U kupaonici nema struje."]'::jsonb, 1, null, '{}'::text[], null, null, null, '«Кран тече.» — «Slavina curi.».', (select id from public.lessons where id = '8fc3399d-0405-5517-9358-d3ad6308d860'), 'PUBLISHED', 'claude_assessment_v5'),
  ('a70ed1aa-1597-58e8-a9b5-89bc0bf6dc82', v_aid, 22, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Коли відправляється потяг до Спліта?». Що ви скажете?', null, '["Motor ima čudan zvuk.", "Je li vlak otkazan?", "Kada polazi vlak za Split?"]'::jsonb, 2, null, '{}'::text[], null, null, null, '«Коли відправляється потяг до Спліта?» — «Kada polazi vlak za Split?».', (select id from public.lessons where id = 'cae7a47d-7fb4-5b03-a8cc-5a0df2ccd92f'), 'PUBLISHED', 'claude_assessment_v5'),
  ('d26ebdb0-0235-503a-95ae-ca80ff317109', v_aid, 23, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «вовна»', null, '[]'::jsonb, null, 'vuna', '{}'::text[], null, null, null, '«вовна» — vuna.', (select id from public.lessons where id = 'c8297811-44ed-55a2-8cb5-d1bd9b8a6a73'), 'PUBLISHED', 'claude_assessment_v5'),
  ('fcafbc96-f418-5e70-9876-80501f36765f', v_aid, 24, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «каструля»', null, '[]'::jsonb, null, 'lonac', '{}'::text[], null, null, null, '«каструля» — lonac.', (select id from public.lessons where id = '17fcd38a-e295-5849-9ba3-1ef240c6be78'), 'PUBLISHED', 'claude_assessment_v5'),
  ('44e8d096-00db-5200-9cee-d2834f43003e', v_aid, 25, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «цільнозерновий»', null, '[]'::jsonb, null, 'integralni', '{}'::text[], null, null, null, '«цільнозерновий» — integralni.', (select id from public.lessons where id = 'bb7bc159-cb40-5a8a-91b7-c6da05c6342a'), 'PUBLISHED', 'claude_assessment_v5'),
  ('2e4124a4-7880-521e-a4bc-c3ea7069a355', v_aid, 26, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Я йду на роботу.»', null, '["posao.", "na", "Idem"]'::jsonb, null, 'Idem na posao.', '{}'::text[], null, null, null, '«Я йду на роботу.» — «Idem na posao.».', (select id from public.lessons where id = '12012395-7359-503b-89c9-ee1807f89d6b'), 'PUBLISHED', 'claude_assessment_v5'),
  ('369838cf-df84-5d03-8008-2a92c80c29f7', v_aid, 27, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Нам треба перенести зустріч.»', null, '["odgoditi", "Moramo", "sastanak."]'::jsonb, null, 'Moramo odgoditi sastanak.', array['Sastanak moramo odgoditi.']::text[], null, null, null, '«Нам треба перенести зустріч.» — «Moramo odgoditi sastanak.».', (select id from public.lessons where id = '3365f423-e694-5b55-baa1-3205fba11aff'), 'PUBLISHED', 'claude_assessment_v5'),
  ('4fb8d2a3-ed73-5de4-97f6-fdbfd6811792', v_aid, 28, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Ми живемо біля школи.»', null, '["škole.", "blizu", "Živimo"]'::jsonb, null, 'Živimo blizu škole.', array['Blizu škole živimo.']::text[], null, null, null, '«Ми живемо біля школи.» — «Živimo blizu škole.».', (select id from public.lessons where id = '3ea9520d-2baa-56b2-aa85-402e3e3ecb9b'), 'PUBLISHED', 'claude_assessment_v5'),
  ('3df5d146-afc0-55bb-8697-a2dd2f9a6e5e', v_aid, 29, 'A1', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Договір строковий?»', null, '[]'::jsonb, null, 'Je li ugovor na određeno?', '{}'::text[], null, null, null, '«Договір строковий?» — «Je li ugovor na određeno?».', (select id from public.lessons where id = '4d6f3498-2cc5-54a0-b4e4-c66add71ef12'), 'PUBLISHED', 'claude_assessment_v5'),
  ('eeddbee4-f944-5a97-ac9f-341009149836', v_aid, 30, 'A1', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Ким ти працюєш?»', null, '[]'::jsonb, null, 'Što radiš po zanimanju?', '{}'::text[], null, null, null, '«Ким ти працюєш?» — «Što radiš po zanimanju?».', (select id from public.lessons where id = 'b369f01f-4a84-57b4-98cb-150d236f4d7f'), 'PUBLISHED', 'claude_assessment_v5');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірки рівня A1 за схемою 2026-11-07 (модуль — 2 завдання на урок, середина — 30, фінал — 48) з діалогів, вправ і текстів уроків A1. Потрібна перевірка носієм.');
end $$;

-- Фінальна перевірка рівня A1 · 48 завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = 'a1-final' and cefr = 'A1';
  if v_aid is null then raise exception 'Немає тесту a1-final — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = 'e9f2ca76-7c3b-53d9-b552-2e0ef00ffdab') then return; end if;  -- уже оновлено
  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
          v_payload, 'assessment_v5: перевірку переведено на схему 2026-11-07 — старі завдання');
  -- старі завдання → DEPRECATED; місця зсуваються за найбільше наявне (унікальність assessment_id + order_index)
  select (coalesce(max(order_index), 0) / 100 + 1) * 100 into v_shift from public.assessment_items where assessment_id = v_aid;
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + v_shift
   where assessment_id = v_aid and status = 'PUBLISHED';
  update public.assessments set description_ua = 'Кінець рівня (усі 13 модулів A1): 48 завдань на 4 навички. ~25 хв.', estimated_minutes = 25 where id = v_aid;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, answer_alternatives, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('e9f2ca76-7c3b-53d9-b552-2e0ef00ffdab', v_aid, 1, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Що ти змінила?", "Де саме ви відчуваєте біль?", "А може бути нирка?"]'::jsonb, 2, null, '{}'::text[], 'A može li biti bubreg?', null, null, 'Прозвучало: «A može li biti bubreg?» — «А може бути нирка?».', (select id from public.lessons where id = 'b6859b5e-db71-543a-8d05-db9b43811d8a'), 'PUBLISHED', 'claude_assessment_v5'),
  ('589389a2-873d-5c4e-b320-5671fe4e3682', v_aid, 2, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Добрий день, мені потрібна SIM-картка з хорватським номером.", "Луко, я забула пароль від банку!", "Торкнися екрана ось тут, у налаштуваннях."]'::jsonb, 0, null, '{}'::text[], 'Dobar dan, trebam SIM karticu s hrvatskim brojem.', null, null, 'Прозвучало: «Dobar dan, trebam SIM karticu s hrvatskim brojem.» — «Добрий день, мені потрібна SIM-картка з хорватським номером.».', (select id from public.lessons where id = '35203547-5f9a-5857-95a0-3a0d596f715d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('cfeece52-a7f9-5804-ae0b-934ddeb71e78', v_aid, 3, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Організація. Я люблю відповідальність.", "Я приїхала до Хорватії, тож звільнилася.", "Доброго ранку, шефе. На жаль, я захворіла."]'::jsonb, 2, null, '{}'::text[], 'Dobro jutro, šefe. Nažalost, razboljela sam se.', null, null, 'Прозвучало: «Dobro jutro, šefe. Nažalost, razboljela sam se.» — «Доброго ранку, шефе. На жаль, я захворіла.».', (select id from public.lessons where id = 'e806dd39-4d38-5781-ad2d-949961dd95f9'), 'PUBLISHED', 'claude_assessment_v5'),
  ('fa30bca0-54aa-5035-8804-42f5b62291e4', v_aid, 4, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Приємно познайомитися, панночко Ано!", "Давай, а потім настільні ігри з мамою.", "В’яжу й шию. А взимку малюю."]'::jsonb, 1, null, '{}'::text[], 'Može, a poslije društvene igre s mamom.', null, null, 'Прозвучало: «Može, a poslije društvene igre s mamom.» — «Давай, а потім настільні ігри з мамою.».', (select id from public.lessons where id = '1c16ceee-5f42-536a-98b4-7dcabaa3be6d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('608e7d90-ab65-5abe-a9cc-8eedf30bd3f8', v_aid, 5, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Мамо, суп готовий?", "Добрий день, що будете пити?", "Можна. На яке ім’я?"]'::jsonb, 0, null, '{}'::text[], 'Mama, je li juha gotova?', null, null, 'Прозвучало: «Mama, je li juha gotova?» — «Мамо, суп готовий?».', (select id from public.lessons where id = '17fcd38a-e295-5849-9ba3-1ef240c6be78'), 'PUBLISHED', 'claude_assessment_v5'),
  ('cc30520f-9446-5aca-bcc9-5c4c73c1e432', v_aid, 6, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Добрий день, контроль квитків. Ваш квиток, будь ласка.", "З вихлопом усе гаразд, а от фільтр треба міняти.", "Без проблем, вона поміститься в багажник."]'::jsonb, 1, null, '{}'::text[], 'Ispuh je u redu, ali filter treba mijenjati.', null, null, 'Прозвучало: «Ispuh je u redu, ali filter treba mijenjati.» — «З вихлопом усе гаразд, а от фільтр треба міняти.».', (select id from public.lessons where id = 'cd5db261-a421-511d-8100-f86bf2335bbe'), 'PUBLISHED', 'claude_assessment_v5'),
  ('c8025cc5-45ea-54cb-9157-ae919db57852', v_aid, 7, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Де ти хочеш полицю — над ліжком?", "А хто платить внесок на утримання — орендар чи власник?", "Даріє, у тебе є валик і пензель?"]'::jsonb, 1, null, '{}'::text[], 'A tko plaća pričuvu, stanar ili vlasnik?', null, null, 'Прозвучало: «A tko plaća pričuvu, stanar ili vlasnik?» — «А хто платить внесок на утримання — орендар чи власник?».', (select id from public.lessons where id = 'f296bc84-8059-5981-a5b9-9d4531627e18'), 'PUBLISHED', 'claude_assessment_v5'),
  ('e1d15bf5-ae41-59fa-bf39-cf3f614831a8', v_aid, 8, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Я ходжу зранку чи по обіді?", "Скільки триває урок?", "А що робимо, коли землетрус?"]'::jsonb, 1, null, '{}'::text[], 'Koliko traje školski sat?', null, null, 'Прозвучало: «Koliko traje školski sat?» — «Скільки триває урок?».', (select id from public.lessons where id = '7c8e16ec-03f3-55dd-a61a-fb59c2401692'), 'PUBLISHED', 'claude_assessment_v5'),
  ('b3a7d2cf-7e00-5af1-af94-d6c497c618cb', v_aid, 9, 'A1', 'reading', 'understand', 'multiple_choice', 'Яка це робота?', 'Oglas: sobarica u hotelu', '["Лише у вихідні", "Сезонна", "Постійна"]'::jsonb, 1, null, '{}'::text[], null, 'HOTEL MARINA TRAŽI SOBARICU
Posao: čišćenje soba i kupaonica.
Uvjeti: sezonski posao od svibnja do listopada, puno radno vrijeme.
Satnica: 7 € neto. Smještaj i hrana su besplatni.
Iskustvo nije važno, engleski jezik je prednost.
Životopis pošaljite na posao@hotelmarina.hr.', 'ГОТЕЛЬ «МАРИНА» ШУКАЄ ПОКОЇВКУ
Робота: прибирання номерів і ванних кімнат.
Умови: сезонна робота з травня до жовтня, повний робочий день.
Погодинна оплата: 7 € чистими. Житло й харчування безкоштовні.
Досвід не важливий, англійська мова — перевага.
Резюме надсилайте на posao@hotelmarina.hr.', 'Текст «Вакансія: покоївка в готелі». Правильна відповідь: «Сезонна».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('ee960f87-35ca-5eaf-ac5e-afff1db68ac7', v_aid, 10, 'A1', 'reading', 'understand', 'multiple_choice', 'Як отримати код?', 'SMS od kurira', '["У новому повідомленні", "У кур’єра", "На пошті"]'::jsonb, 0, null, '{}'::text[], null, 'Poštovani, Vaša pošiljka stiže danas između 14 i 17 sati. Kurir Vas zove prije dostave. Ako niste kod kuće, paket ostavljamo u paketomatu na adresi Ilica 25. Kod za otvaranje dobivate u novoj poruci. Za praćenje pošiljke posjetite našu stranicu.', 'Шановний(-а), ваша посилка прибуде сьогодні між 14 і 17 годиною. Кур’єр подзвонить вам перед доставкою. Якщо вас немає вдома, посилку залишимо в поштоматі за адресою Іліца, 25. Код для відкриття отримаєте в новому повідомленні. Щоб відстежити посилку, відвідайте наш сайт.', 'Текст «SMS від кур’єра». Правильна відповідь: «У новому повідомленні».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('2e04b106-5d51-52e1-a558-2e37b58db658', v_aid, 11, 'A1', 'reading', 'understand', 'multiple_choice', 'Що радять узяти?', 'Koncert u parku', '["Ковдру", "Квиток", "Парасольку"]'::jsonb, 0, null, '{}'::text[], null, 'KONCERT U PARKU ZRINJEVAC
Subota, 20 sati
Svira bend iz Zagreba.
Ulaz je besplatan!
Ako pada kiša, koncert je u kazalištu.
Ponesite deku i dobro raspoloženje.', 'КОНЦЕРТ У ПАРКУ ЗРИНЄВАЦ
Субота, 20 година
Грає гурт із Загреба.
Вхід вільний!
Якщо йде дощ, концерт відбудеться в театрі.
Візьміть ковдру й гарний настрій.', 'Текст «Концерт у парку». Правильна відповідь: «Ковдру».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('f80c0d32-cf27-5fc7-b713-e07be27583ba', v_aid, 12, 'A1', 'reading', 'understand', 'multiple_choice', 'Скільки коштує година?', 'Parkiranje u gradu', '["1,60 €", "1 €", "2 €"]'::jsonb, 0, null, '{}'::text[], null, 'ZONA 1 – PARKIRANJE SE PLAĆA
Ponedjeljak – petak: od 7 do 21 sat
Subota: od 7 do 15 sati
Nedjeljom i praznikom parkiranje je besplatno.
Najduže dva sata. Cijena: 1,60 € na sat.
Platite na automatu ili SMS-om. Bez karte – kazna!', 'ЗОНА 1 – ПАРКУВАННЯ ПЛАТНЕ
Понеділок – п’ятниця: з 7 до 21 години
Субота: з 7 до 15 години
У неділю та у свята паркування безкоштовне.
Найдовше дві години. Ціна: 1,60 € за годину.
Платіть в автоматі або через SMS. Без квитка — штраф!', 'Текст «Паркування в місті». Правильна відповідь: «1,60 €».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('51684c99-2943-5cb3-915b-bc151d90854d', v_aid, 13, 'A1', 'reading', 'understand', 'multiple_choice', 'Де столик?', 'Potvrda rezervacije', '["На терасі", "Біля вікна", "У залі"]'::jsonb, 0, null, '{}'::text[], null, 'Poštovana gospođo Kovalenko,
hvala na rezervaciji. Vaš stol za četiri osobe je u petak u 19 sati, na terasi.
Ako trebate dječju stolicu ili imate alergiju, javite nam.
Ako ne možete doći, molimo Vas da otkažete rezervaciju dan prije.
Srdačan pozdrav,
Restoran Lungomare', 'Шановна пані Коваленко,
дякуємо за бронювання. Ваш столик на чотирьох — у п’ятницю о 19 годині, на терасі.
Якщо вам потрібен дитячий стілець або у вас алергія, повідомте нам.
Якщо ви не можете прийти, просимо скасувати бронювання за день до того.
З повагою,
Ресторан «Lungomare»', 'Текст «Підтвердження бронювання». Правильна відповідь: «На терасі».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('e4735e61-30a3-5e86-b189-9065565e36d1', v_aid, 14, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Može li se kupati u jezerima?', '["Ljeti je puno gostiju, ali kolege su super.", "Ne, zabranjeno je kupanje, cijeli park je zaštićen.", "Jučer sam se jako loše osjećala. Imala sam vrtoglavicu."]'::jsonb, 1, null, '{}'::text[], 'Može li se kupati u jezerima?', null, null, 'Діалог «Плітвіце»: «Može li se kupati u jezerima?» (Можна купатися в озерах?) — «Ne, zabranjeno je kupanje, cijeli park je zaštićen.» (Ні, купатися заборонено, весь парк заповідний.).', (select id from public.lessons where id = '84a20a00-701a-5ce5-a3c8-fca72986f912'), 'PUBLISHED', 'claude_assessment_v5'),
  ('881b93fc-9263-5cd2-8d84-cac759504d13', v_aid, 15, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Darja, jesi li ikad bila na Hvaru?', '["Nisam, nikad nisam bila na otocima.", "Bolje. Imala je gripu, ali virus je prošao.", "Natašte, ujutro. Progutajte ih s puno vode."]'::jsonb, 0, null, '{}'::text[], 'Darja, jesi li ikad bila na Hvaru?', null, null, 'Діалог «Ти коли-небудь…?»: «Darja, jesi li ikad bila na Hvaru?» (Даріє, ти коли-небудь була на Хварі?) — «Nisam, nikad nisam bila na otocima.» (Ні, я ніколи не була на островах.).', (select id from public.lessons where id = '3f440ad8-f057-5898-b773-6aa8816fa8a3'), 'PUBLISHED', 'claude_assessment_v5'),
  ('5e71fac6-ed40-5636-83fd-9e68f30f8183', v_aid, 16, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Kako se prijavljujem u sustav?', '["Mobilnim tokenom banke ili osobnom iskaznicom s certifikatom.", "Malo. Mentor je rekao da je sigurnost najvažnija.", "Imate upalu grla. To je bakterijska infekcija."]'::jsonb, 0, null, '{}'::text[], 'Kako se prijavljujem u sustav?', null, null, 'Діалог «Довідка через e-Građani»: «Kako se prijavljujem u sustav?» (Як увійти в систему?) — «Mobilnim tokenom banke ili osobnom iskaznicom s certifikatom.» (Мобільним токеном банку або ID-карткою із сертифікатом.).', (select id from public.lessons where id = '953e12fb-a6f6-5ae5-aa7a-ebfe248d24da'), 'PUBLISHED', 'claude_assessment_v5'),
  ('f51ea55b-7685-5b8c-a58d-5c33f93d9b1a', v_aid, 17, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Gdje želiš policu, iznad kreveta?', '["Ubaci karticu i unesi PIN.", "Da. Drži ljestve, molim te, a ja bušim.", "Ultrazvuk srca i kontrolu za tri mjeseca."]'::jsonb, 1, null, '{}'::text[], 'Gdje želiš policu, iznad kreveta?', null, null, 'Діалог «Вішаємо полицю»: «Gdje želiš policu, iznad kreveta?» (Де ти хочеш полицю — над ліжком?) — «Da. Drži ljestve, molim te, a ja bušim.» (Так. Потримай драбину, будь ласка, а я свердлитиму.).', (select id from public.lessons where id = 'dd2c0f3c-19f2-5c73-b448-a0631cd97e69'), 'PUBLISHED', 'claude_assessment_v5'),
  ('131edc97-c65c-56eb-b866-fe52a08581f7', v_aid, 18, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Kako biste se opisali?', '["Tri eura. Uz račun dobivate debitnu karticu i mobilno bankarstvo.", "Pletem i šivam. A zimi slikam.", "Pouzdana sam i samostalna, a kolege kažu da sam strpljiva."]'::jsonb, 2, null, '{}'::text[], 'Kako biste se opisali?', null, null, 'Діалог «Співбесіда»: «Kako biste se opisali?» (Як би ви себе описали?) — «Pouzdana sam i samostalna, a kolege kažu da sam strpljiva.» (Я надійна й самостійна, а колеги кажуть, що я терпляча.).', (select id from public.lessons where id = 'fc1baff0-0e48-5676-bd3c-47d88d31e582'), 'PUBLISHED', 'claude_assessment_v5'),
  ('c4b02cab-c78b-579e-bfde-2116accaab8d', v_aid, 19, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Je li voditeljica stroga?', '["U ormaru, pored vunenih rukavica.", "Nije, ali traži da budemo točni.", "Po mom mišljenju, malo je dosadan."]'::jsonb, 1, null, '{}'::text[], 'Je li voditeljica stroga?', null, null, 'Діалог «Як було?»: «Je li voditeljica stroga?» (Керівниця сувора?) — «Nije, ali traži da budemo točni.» (Ні, але вимагає пунктуальності.).', (select id from public.lessons where id = '2c56a486-dbbb-5102-b7cb-754c59cf94c3'), 'PUBLISHED', 'claude_assessment_v5'),
  ('7663c1a7-5c3e-5d78-8504-0173bb5ab3a1', v_aid, 20, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Darja, jesi li bila u Dioklecijanovoj palači?', '["Obično mjesec dana. Kad ti odobre, dobiješ novu iskaznicu.", "Došla sam u Hrvatsku, pa sam dala otkaz.", "Jesam! Šetala sam uskim kamenim uličicama."]'::jsonb, 2, null, '{}'::text[], 'Darja, jesi li bila u Dioklecijanovoj palači?', null, null, 'Діалог «Прогулянка Сплітом»: «Darja, jesi li bila u Dioklecijanovoj palači?» (Даріє, ти була в Діоклетіановому палаці?) — «Jesam! Šetala sam uskim kamenim uličicama.» (Так! Я гуляла вузькими кам’яними вуличками.).', (select id from public.lessons where id = 'd9ef1de4-f4db-590e-bafd-474f84c8e03f'), 'PUBLISHED', 'claude_assessment_v5'),
  ('32c1051f-eb49-55cf-b838-9d6accf8b621', v_aid, 21, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Kako si se sprijateljila s ljudima ovdje?', '["Duboke špilje, kanjon i šume.", "Volontirala sam u udruzi, a ondje je divna zajednica.", "Četrdeset pet minuta, a veliki odmor dvadeset minuta."]'::jsonb, 1, null, '{}'::text[], 'Kako si se sprijateljila s ljudima ovdje?', null, null, 'Діалог «Спогади»: «Kako si se sprijateljila s ljudima ovdje?» (Як ти тут подружилася з людьми?) — «Volontirala sam u udruzi, a ondje je divna zajednica.» (Я волонтерила в організації, а там чудова спільнота.).', (select id from public.lessons where id = '4b2bf351-c5fc-57ca-9fd9-24fb8a4bfc0d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('fb573ae8-3e5e-5f18-8994-f82a1a3de82f', v_aid, 22, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Koliko košta krunica?', '["Obična. Imam i obavijest, trebam preuzeti pošiljku.", "Ovisi o materijalu. Prvo ga popravljamo, pa vidimo.", "Nudimo, doručak i večera su uključeni."]'::jsonb, 1, null, '{}'::text[], 'Koliko košta krunica?', null, null, 'Діалог «Ясна й коронка»: «Koliko košta krunica?» (Скільки коштує коронка?) — «Ovisi o materijalu. Prvo ga popravljamo, pa vidimo.» (Залежить від матеріалу. Спершу лікуємо, потім побачимо.).', (select id from public.lessons where id = '247c3445-6ba3-50f0-a441-9073d6734451'), 'PUBLISHED', 'claude_assessment_v5'),
  ('17ca2376-79c5-5cd3-90ea-aa8bbaae8e41', v_aid, 23, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Tarifu. Koliko košta paket s neograničenim pozivima?', '["Petnaest eura mjesečno, s dvadeset giga podataka.", "Rukomet ili košarka, ovdje su jako popularni.", "Na Plitvice. Ondje su najljepša jezera i slapovi."]'::jsonb, 0, null, '{}'::text[], 'Tarifu. Koliko košta paket s neograničenim pozivima?', null, null, 'Діалог «У салоні зв’язку»: «Tarifu. Koliko košta paket s neograničenim pozivima?» (Тариф. Скільки коштує пакет з безлімітними дзвінками?) — «Petnaest eura mjesečno, s dvadeset giga podataka.» (П’ятнадцять євро на місяць, з двадцятьма гігабайтами.).', (select id from public.lessons where id = '35203547-5f9a-5857-95a0-3a0d596f715d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('4093357d-6022-5326-b3cd-2eff29dfdb62', v_aid, 24, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Dobro. Mogu li vidjeti i stanje računa?', '["Šetali smo šetnicom do rimskog foruma.", "Stanite ispred hotela i pričekajte me pet minuta.", "Možeš, pritisni tipku za stanje računa."]'::jsonb, 2, null, '{}'::text[], 'Dobro. Mogu li vidjeti i stanje računa?', null, null, 'Діалог «Біля банкомата»: «Dobro. Mogu li vidjeti i stanje računa?» (Добре. Можу ще подивитися залишок на рахунку?) — «Možeš, pritisni tipku za stanje računa.» (Можеш, натисни кнопку «залишок на рахунку».).', (select id from public.lessons where id = '1c468857-b9aa-5143-aa84-6ea02aa2443c'), 'PUBLISHED', 'claude_assessment_v5'),
  ('e41fb1f7-2b3f-5834-a8f6-d6be5432c1b9', v_aid, 25, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Oprostite, imate li šampon za suhu kosu?', '["Чудово. Мені ще потрібен крем для чутливої шкіри.", "На жаль, його немає. Надійде тільки в травні.", "Є. Цей без запаху, і до нього є бальзам."]'::jsonb, 2, null, '{}'::text[], null, 'Daša: Oprostite, imate li šampon za suhu kosu?
Prodavačica: Imamo. Ovaj je bez parfema, a ima i regenerator.
Daša: Super. Trebam i kremu za osjetljivu kožu.
Prodavačica: Ova je dobra i za suhu i za masnu kožu.
Daša: A krema za sunčanje za djecu?
Prodavačica: Nažalost, nema je. Stiže tek u svibnju.', 'Daša: Перепрошую, у вас є шампунь для сухого волосся?
Prodavačica: Є. Цей без запаху, і до нього є бальзам.
Daša: Чудово. Мені ще потрібен крем для чутливої шкіри.
Prodavačica: Цей підходить і для сухої, і для жирної шкіри.
Daša: А дитячий сонцезахисний крем?
Prodavačica: На жаль, його немає. Надійде тільки в травні.', 'Діалог «Для волосся й шкіри»: «Oprostite, imate li šampon za suhu kosu?» — «Imamo. Ovaj je bez parfema, a ima i regenerator.», тобто «Є. Цей без запаху, і до нього є бальзам.».', (select id from public.lessons where id = '9ba8e62a-83fd-5b08-9e01-760bc0f7219f'), 'PUBLISHED', 'claude_assessment_v5'),
  ('5befa49a-f1cd-51f7-94b9-055cb7549d4f', v_aid, 26, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Ima li temperaturu?', '["Пане лікарю, малий з ранку блює, і в нього пронос.", "Дайте йому свічку від температури, і хай п’є багато води.", "Термометр показав тридцять вісім з половиною."]'::jsonb, 2, null, '{}'::text[], null, 'Daša: Doktore, mali od jutros povraća i ima proljev.
Pedijatar: Ima li temperaturu?
Daša: Toplomjer je pokazao trideset osam i pol.
Pedijatar: Dajte mu čepić za temperaturu i neka pije puno vode.
Daša: Plače i drži se za uho.
Pedijatar: Pregledat ću ga, možda je upala uha.', 'Daša: Пане лікарю, малий з ранку блює, і в нього пронос.
Pedijatar: У нього температура?
Daša: Термометр показав тридцять вісім з половиною.
Pedijatar: Дайте йому свічку від температури, і хай п’є багато води.
Daša: Він плаче й тримається за вухо.
Pedijatar: Я його огляну, може, це запалення вуха.', 'Діалог «Дитина хворіє»: «Ima li temperaturu?» — «Toplomjer je pokazao trideset osam i pol.», тобто «Термометр показав тридцять вісім з половиною.».', (select id from public.lessons where id = '0df023bb-17fb-5006-91bf-3b911dd30295'), 'PUBLISHED', 'claude_assessment_v5'),
  ('3f14ae86-598f-521e-ad57-d62de948bc50', v_aid, 27, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Gdje je pribor za jelo?', '["Шість глибоких тарілок для супу й шість мілких для другої страви.", "У шухляді. Поклади ще серветки біля тарілок.", "Філіпе, гості прийдуть через пів години. Накрий на стіл, будь ласка."]'::jsonb, 1, null, '{}'::text[], null, 'Daša: Filipe, gosti dolaze za pola sata. Postavi stol, molim te.
Filip: Koliko tanjura trebam?
Daša: Šest dubokih tanjura za juhu i šest plitkih za glavno jelo.
Filip: Gdje je pribor za jelo?
Daša: U ladici. Stavi i salvete pored tanjura.
Filip: A koji stolnjak, bijeli ili plavi?', 'Daša: Філіпе, гості прийдуть через пів години. Накрий на стіл, будь ласка.
Filip: Скільки тарілок потрібно?
Daša: Шість глибоких тарілок для супу й шість мілких для другої страви.
Filip: Де столові прибори?
Daša: У шухляді. Поклади ще серветки біля тарілок.
Filip: А яку скатертину, білу чи синю?', 'Діалог «Накриваємо на стіл»: «Gdje je pribor za jelo?» — «U ladici. Stavi i salvete pored tanjura.», тобто «У шухляді. Поклади ще серветки біля тарілок.».', (select id from public.lessons where id = '213ab10f-63a4-5e1c-8b2e-156c433de874'), 'PUBLISHED', 'claude_assessment_v5'),
  ('c6b70029-cdfc-5884-a315-4e4631c7503b', v_aid, 28, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Ne, hvala. Mogu li dobiti dopušteno prekoračenje?', '["Можна, до суми однієї зарплати.", "Мені потрібна виписка з рахунку за останні три місяці.", "Прошу. Бачу, у вас регулярні надходження."]'::jsonb, 0, null, '{}'::text[], null, 'Darja: Trebam izvod s računa za zadnja tri mjeseca.
Službenik: Izvolite. Vidim da imate redovite uplate.
Darja: Da. Zanima me i štedni račun. Kolika je kamata?
Službenik: Dva posto godišnje. Želite li i kreditnu karticu?
Darja: Ne, hvala. Mogu li dobiti dopušteno prekoračenje?
Službenik: Možete, do iznosa jedne plaće.', 'Darja: Мені потрібна виписка з рахунку за останні три місяці.
Službenik: Прошу. Бачу, у вас регулярні надходження.
Darja: Так. Мене цікавить і ощадний рахунок. Який відсоток?
Službenik: Два відсотки на рік. Бажаєте також кредитну картку?
Darja: Ні, дякую. А можна дозволений овердрафт?
Službenik: Можна, до суми однієї зарплати.', 'Діалог «Виписка й заощадження»: «Ne, hvala. Mogu li dobiti dopušteno prekoračenje?» — «Možete, do iznosa jedne plaće.», тобто «Можна, до суми однієї зарплати.».', (select id from public.lessons where id = 'fee5b77b-dc3b-5fd5-818a-c5496e95c23b'), 'PUBLISHED', 'claude_assessment_v5'),
  ('e8db4364-b3db-5ac8-a5a9-dd39e99ca7ed', v_aid, 29, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Idem u grad, na tržnicu. A ti?', '["А я сьогодні на роботі до п’ятої.", "Чудово! Дорогою можу заскочити в пекарню.", "Так, у центрі. Можу підвезти тебе машиною."]'::jsonb, 0, null, '{}'::text[], null, 'Luka: Dašo, kamo ideš tako rano?
Daša: Idem u grad, na tržnicu. A ti?
Luka: Ja sam danas na poslu do pet.
Daša: Gdje je tvoj ured, u centru?
Luka: Da, u centru. Mogu te odvesti autom.
Daša: Super! Usput mogu svratiti u pekaru.', 'Luka: Дашо, куди ти так рано?
Daša: Іду в місто, на ринок. А ти?
Luka: А я сьогодні на роботі до п’ятої.
Daša: Де твій офіс, у центрі?
Luka: Так, у центрі. Можу підвезти тебе машиною.
Daša: Чудово! Дорогою можу заскочити в пекарню.', 'Діалог «Куди ти йдеш?»: «Idem u grad, na tržnicu. A ti?» — «Ja sam danas na poslu do pet.», тобто «А я сьогодні на роботі до п’ятої.».', (select id from public.lessons where id = '12012395-7359-503b-89c9-ee1807f89d6b'), 'PUBLISHED', 'claude_assessment_v5'),
  ('4454653b-ca14-5fa6-ad7c-355631b85b94', v_aid, 30, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Hoćeš li mi navečer pročitati bajku?', '["Добре. Не грайся в піску, в тебе нові штани.", "Так, але спершу ти купаєшся й дивишся один мультик.", "Ходімо, але зважай на менших дітей."]'::jsonb, 1, null, '{}'::text[], null, 'Filip: Mama, idemo na tobogan!
Darja: Idemo, ali pazi na mlađu djecu.
Filip: Zaljuljaj me na ljuljački, molim te!
Darja: Može. Nemoj se igrati u pijesku, nove su ti hlače.
Filip: Hoćeš li mi navečer pročitati bajku?
Darja: Hoću, ali prvo se kupaš i gledaš jedan crtić.', 'Filip: Мамо, ходімо на гірку!
Darja: Ходімо, але зважай на менших дітей.
Filip: Погойдай мене на гойдалці, будь ласка!
Darja: Добре. Не грайся в піску, в тебе нові штани.
Filip: А ввечері прочитаєш мені казку?
Darja: Так, але спершу ти купаєшся й дивишся один мультик.', 'Діалог «На майданчику»: «Hoćeš li mi navečer pročitati bajku?» — «Hoću, ali prvo se kupaš i gledaš jedan crtić.», тобто «Так, але спершу ти купаєшся й дивишся один мультик.».', (select id from public.lessons where id = 'd43d6c65-1ce3-5c72-9ecd-cce2ed200fc2'), 'PUBLISHED', 'claude_assessment_v5'),
  ('5805bde0-0b9d-531f-9221-2e6786c343ef', v_aid, 31, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Будьмо!». Що ви скажете?', null, '["Koji je vaš specijalitet?", "Živjeli!", "Radiš li u ponedjeljak?"]'::jsonb, 1, null, '{}'::text[], null, null, null, '«Будьмо!» — «Živjeli!».', (select id from public.lessons where id = '2fabcd03-324d-5355-b96e-022723fbeda7'), 'PUBLISHED', 'claude_assessment_v5'),
  ('2f37f839-6c2b-5f7f-8c4c-ff9e5bb4897d', v_aid, 32, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Квиток на пором, будь ласка». Що ви скажете?', null, '["Volim prirodu.", "Idemo na Plitvice.", "Kartu za trajekt, molim."]'::jsonb, 2, null, '{}'::text[], null, null, null, '«Квиток на пором, будь ласка.» — «Kartu za trajekt, molim.».', (select id from public.lessons where id = '71ab330d-abbe-57a7-870e-77e59daf3627'), 'PUBLISHED', 'claude_assessment_v5'),
  ('9a431587-d9e7-5556-8251-66dc8acb2e1e', v_aid, 33, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Я плачу автоплатежем». Що ви скажете?', null, '["Dobrodošli u susjedstvo!", "Donesi bušilicu.", "Plaćam trajnim nalogom."]'::jsonb, 2, null, '{}'::text[], null, null, null, '«Я плачу автоплатежем.» — «Plaćam trajnim nalogom.».', (select id from public.lessons where id = 'b69a8cca-4918-562f-8ae5-22f8d7ba2f76'), 'PUBLISHED', 'claude_assessment_v5'),
  ('c6c29558-2cd2-5bd2-b4c1-182a831f9bbc', v_aid, 34, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Почитай мені казку!». Що ви скажете?', null, '["Pročitaj mi bajku!", "Ne mogu zaspati.", "Ponesi kišobran!"]'::jsonb, 0, null, '{}'::text[], null, null, null, '«Почитай мені казку!» — «Pročitaj mi bajku!».', (select id from public.lessons where id = 'd43d6c65-1ce3-5c72-9ecd-cce2ed200fc2'), 'PUBLISHED', 'claude_assessment_v5'),
  ('85c88195-e242-5af4-94a8-6d253d316fff', v_aid, 35, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Крок за кроком». Що ви скажете?', null, '["Koliko ste dugo u vezi?", "Putujem u Zadar.", "Korak po korak."]'::jsonb, 2, null, '{}'::text[], null, null, null, '«Крок за кроком.» — «Korak po korak.».', (select id from public.lessons where id = '4b2bf351-c5fc-57ca-9fd9-24fb8a4bfc0d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('bfb42a16-f593-549c-a816-327208609cd9', v_aid, 36, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «дельфін»', null, '[]'::jsonb, null, 'dupin', '{}'::text[], null, null, null, '«дельфін» — dupin.', (select id from public.lessons where id = '88e6f563-29dd-5e5d-865b-67fa47474b07'), 'PUBLISHED', 'claude_assessment_v5'),
  ('bacbc7f9-63d4-5077-8b53-336c36f6fecc', v_aid, 37, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «визнання»', null, '[]'::jsonb, null, 'priznavanje', '{}'::text[], null, null, null, '«визнання» — priznavanje.', (select id from public.lessons where id = '11b565a4-1e2a-50d2-8d9d-c05e84371402'), 'PUBLISHED', 'claude_assessment_v5'),
  ('a4f1b77c-0b64-50a9-82ed-9700601bdd67', v_aid, 38, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «молоток»', null, '[]'::jsonb, null, 'čekić', '{}'::text[], null, null, null, '«молоток» — čekić.', (select id from public.lessons where id = 'dd2c0f3c-19f2-5c73-b448-a0631cd97e69'), 'PUBLISHED', 'claude_assessment_v5'),
  ('1f0d04b8-d306-5c58-a1bb-74b3e8b1eb2c', v_aid, 39, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «попередній»', null, '[]'::jsonb, null, 'prethodni', '{}'::text[], null, null, null, '«попередній» — prethodni.', (select id from public.lessons where id = '92858dbe-ede1-5bc5-b80a-c796c5598019'), 'PUBLISHED', 'claude_assessment_v5'),
  ('faa2da0c-b654-502e-8bad-9cff25b191f2', v_aid, 40, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «надійний»', null, '[]'::jsonb, null, 'pouzdan', '{}'::text[], null, null, null, '«надійний» — pouzdan.', (select id from public.lessons where id = 'fc1baff0-0e48-5676-bd3c-47d88d31e582'), 'PUBLISHED', 'claude_assessment_v5'),
  ('08078a8d-d762-5371-afff-8f540828ee25', v_aid, 41, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Де зустрічаємося?»', null, '["nalazimo", "se", "Gdje", "sutra?"]'::jsonb, null, 'Gdje se nalazimo sutra?', array['Gdje se sutra nalazimo?']::text[], null, null, null, '«Де зустрічаємося?» — «Gdje se nalazimo sutra?».', (select id from public.lessons where id = 'dde31f54-28b8-505b-aba6-3e578601fccb'), 'PUBLISHED', 'claude_assessment_v5'),
  ('d524ed19-3273-59e7-9b7d-1e0a3e7a52b5', v_aid, 42, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Я прийшла здати кров.»', null, '["vaditi", "sam", "Došla", "krv."]'::jsonb, null, 'Došla sam vaditi krv.', '{}'::text[], null, null, null, '«Я прийшла здати кров.» — «Došla sam vaditi krv.».', (select id from public.lessons where id = '293af384-4ee2-5746-80a8-e8ffdc7009bc'), 'PUBLISHED', 'claude_assessment_v5'),
  ('96c110ee-724f-5b88-8af8-d364b9f36f8c', v_aid, 43, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Наступного тижня я працюю з дому.»', null, '["od", "Sljedeći", "kuće.", "tjedan", "radim"]'::jsonb, null, 'Sljedeći tjedan radim od kuće.', array['Radim od kuće sljedeći tjedan.']::text[], null, null, null, '«Наступного тижня я працюю з дому.» — «Sljedeći tjedan radim od kuće.».', (select id from public.lessons where id = '3365f423-e694-5b55-baa1-3205fba11aff'), 'PUBLISHED', 'claude_assessment_v5'),
  ('a2868e9e-64dc-5f00-b6aa-c7531bfdc971', v_aid, 44, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Мені потрібен новий акумулятор.»', null, '["akumulator.", "novi", "Trebam"]'::jsonb, null, 'Trebam novi akumulator.', '{}'::text[], null, null, null, '«Мені потрібен новий акумулятор.» — «Trebam novi akumulator.».', (select id from public.lessons where id = 'cd5db261-a421-511d-8100-f86bf2335bbe'), 'PUBLISHED', 'claude_assessment_v5'),
  ('618f840f-614e-5684-a36d-6267a164f087', v_aid, 45, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Я не отримала лист.»', null, '["primila", "mail.", "Nisam"]'::jsonb, null, 'Nisam primila mail.', array['Mail nisam primila.']::text[], null, null, null, '«Я не отримала лист.» — «Nisam primila mail.».', (select id from public.lessons where id = '71537166-9f48-503f-b564-3a4f99a192c5'), 'PUBLISHED', 'claude_assessment_v5'),
  ('5fad6abe-68e0-5258-b463-a61ede9c3e55', v_aid, 46, 'A1', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Це найкраща страва.»', null, '[]'::jsonb, null, 'Ovo je najbolje jelo.', '{}'::text[], null, null, null, '«Це найкраща страва.» — «Ovo je najbolje jelo.».', (select id from public.lessons where id = 'f1b2093d-9699-59af-92b9-ed7bdf7fad49'), 'PUBLISHED', 'claude_assessment_v5'),
  ('021c7772-0e91-567e-b221-4c8b22289c28', v_aid, 47, 'A1', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Передай мені джем, будь ласка.»', null, '[]'::jsonb, null, 'Dodaj mi pekmez, molim te.', '{}'::text[], null, null, null, '«Передай мені джем, будь ласка.» — «Dodaj mi pekmez, molim te.».', (select id from public.lessons where id = 'bb7bc159-cb40-5a8a-91b7-c6da05c6342a'), 'PUBLISHED', 'claude_assessment_v5'),
  ('107d0f44-3516-5ed0-8da8-d174749abf9b', v_aid, 48, 'A1', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Я шукаю подарунок для мами.»', null, '[]'::jsonb, null, 'Tražim poklon za mamu.', '{}'::text[], null, null, null, '«Я шукаю подарунок для мами.» — «Tražim poklon za mamu.».', (select id from public.lessons where id = '86d268a5-7193-53c5-955b-cf6cc69116f1'), 'PUBLISHED', 'claude_assessment_v5');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірки рівня A1 за схемою 2026-11-07 (модуль — 2 завдання на урок, середина — 30, фінал — 48) з діалогів, вправ і текстів уроків A1. Потрібна перевірка носієм.');
end $$;

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_new int; v_bad int;
begin
  select count(*) into v_new from public.assessment_items where id in ('e781fbe7-f966-553a-90c5-da7061e2850a', 'dfdf7896-140e-51ca-883d-2e6359f9ded8', '7b19b539-ba96-5c14-9a47-02313950b40d', '1b2eb7a6-93d0-5b82-ac74-2a50831bed16', '1fedca0d-3e82-55d2-8ac1-255b4d62bc38', 'e75f4533-9e17-5285-a873-7c8c26955408', 'ae16ee49-77c2-5bfe-baf1-e0296f887265', '20a3cf6f-dd33-57ca-902a-3523d61f41b6', '851c46ad-a4d1-5381-a56f-9dd432ca52bd', '219e10fe-f603-57ee-a03d-0cd51266e417', '0f9b6b97-62c2-5366-a988-5ca86a0130f7', '91b5d109-d409-575a-97ea-8b95bd4044bc', '7f5e83d3-0fc7-59d5-9bfc-e7d3b13e27c5', '6d66626f-11aa-59a6-be73-f4e4ac2695d1', 'cf2abaec-7900-52e8-ad5a-d08a3f667ed2', '140e45ba-9a94-52df-8cf2-85c076a038ae', 'd3f7c59c-5234-59c7-b35a-f5de2df16025', '6289dcf1-2afc-540f-af0b-c7f0a7c2fca9', '58e03128-0e49-5d97-86f8-73b07aceaf30', '672c3585-8cd5-5251-b146-e1023da892c3', '4e4a5295-4749-5619-8e36-201b439c3fa8', 'c43ef766-2143-510b-a697-066381109041', '9eca1095-06a0-5162-8bd2-7ae5748cdc0d', '9688a198-6d03-5089-abf7-0a9e1e191128', 'c32b35a0-1d7a-5ab5-9ca9-d07ca6c78c54', 'c005b961-788d-5b37-b837-0234a2e95645', '4c913ccd-c5e9-5fcc-b79d-12d0564407f5', 'c0f8821f-6a7a-5a4a-966c-44a705839e22', '09c1e2f5-0215-533c-b16f-8753e92456be', 'f37094d7-9c5b-5edc-a1f2-3b40f429ea5b', '61e06811-848e-5df8-bd2b-81b2c5aaf346', '59f61add-be7b-5110-ad3c-0c9fb429048b', '8a895493-cf6d-5b42-83bc-45af4c2860ce', '12f86858-a0d6-5327-830f-8b393d0aeb7b', 'aa465352-dcf7-5c0f-b23b-7fcd474fd98c', '571746cb-180f-572c-9b29-238ae8eca571', '732cb6d3-b93a-5a39-b647-606571ae7a8d', 'e4c6edc6-af1a-500d-a622-c8350006fb0d', '078c7f43-2783-5afb-913a-2cc89185fd1d', '63bf30e1-39c4-52d0-9b91-cf468ab65f7a', 'a98e6caa-e694-58cb-bf06-92b870231c53', 'efe60c38-6622-5d52-8f5f-269665e98d32', '3fb37c1c-89ae-5e0f-8155-e1819883051f', '98c0ef1c-5835-5051-9947-40b09d53c3cd', '64f400d5-e09c-5e6c-a40e-20c9492ffa16', 'aa525570-fff3-5633-865a-5ec4671ce348', '974ac4f1-ff69-5f28-826d-7254dce6edbb', 'f101ff1d-73a6-5a7e-9faa-a35e9f83572c', '507b3173-c09c-5cf5-a91d-db67d3789a89', '5754ebbf-311d-595e-a214-e26595e20c7f', '38bb4954-7f25-5566-beb6-f37e21886710', '5088a719-38bf-5f3e-9efd-9700e3fffb45', 'b983944b-500c-5511-a467-e6c37294ed2c', '914769b8-3144-5643-92d7-f6b1be460bd4', '55e3e06c-20a8-5027-83f0-270e4875c602', '1c8fe3d0-602f-5716-8f7a-d3a0872c3535', '36ad1d31-e5bf-5eb4-b99e-a351650dfdfa', 'b1937105-4cfc-5edc-b405-3c7de14f50d1', 'ac5a4c1d-a93a-5f06-a58e-7686887646e5', 'b2bd7c82-439e-5d39-b484-5c4fa11ea7bd', 'c93a48c4-b892-5dce-b342-b60c5ec7ac7d', '19b0116c-ede7-5a0a-86ac-aa41bb5d6fc8', '9b610e0b-22d2-52b5-9e4e-c5204aedf085', 'a76af275-5657-5673-85aa-51b11704bafb', '9b5d8f90-e5ef-5c1a-a1bf-40771de86e9d', '6f7a4ea0-8fc8-5291-8e8e-71111e4e7a0e', '74696b91-4be4-5f6e-a402-198f25a19db8', 'e8046723-d989-5f44-8f18-1da3fe79bdd6', '8291833d-436d-5eaf-9dba-c0d5043d56e3', '06c9e3c3-ea9d-56c4-bc07-5afa489de1a3', '57640148-343e-5b54-bd3a-2e87f5271d15', '88e69743-3f9b-571c-863d-c28f72654dfa', '3481db4f-a8cb-5b09-a050-56bffcc53293', '49db07a0-49f3-51fa-97ce-c573d45a6fd8', '6de484c1-2512-5db3-afdc-995dc35e162e', '8892735c-161e-5fa6-8ed3-f0781696a2d7', '1dd595a9-969f-5287-ab07-d9df04c47124', '74dace8c-7180-5617-a05d-036d87015e26', '0bc69fb6-241c-5ad9-ad25-7a5bb1880158', '7d3c3b29-adc0-587a-9303-6f4aaa85229e', '2a53ab53-edfa-5163-bb17-b2a4b54feee8', 'fcfef40b-69f1-530f-8cde-57ee253392a2', '0428d914-caee-56c8-be1c-b91ec744a9d6', '158f628a-ef5d-5042-a8bd-897c38698d50', '229c7a84-5161-5803-b063-97738db76064', 'b3bc0b47-ce18-5fdb-92fb-46bcbde4daea', 'b9c6f368-806f-5d13-b1d7-628b7e0245d1', 'bf6b7f3a-b00f-5812-b0b2-b1d711ab2058', '33b3a0e5-4446-5e07-95e9-3eab54fb338d', '6f0d4eba-06dc-5633-af9c-00a36327e649', '0dfdc574-da2a-5879-973d-01dcfb152a40', 'b7ee58f0-023d-50aa-8843-3a356bcce41e', '2fba6a1d-3c54-5d50-aadf-29c5d4f2313d', '32ab3308-c884-5acc-9ed7-8ae445a323d0', '62c3b7b1-a4fb-57b6-a7e7-2def7950e50f', '932d6275-f052-5fc4-98f1-1413a0d85205', 'd8b1af9c-b8fa-540b-b322-f14f401ca888', 'f85ae4e8-509a-5ebe-b9d5-a1fbb4d5575b', 'f87b6a2a-51d5-5a86-a8ce-6c5109aba404', '96128980-36c6-53f3-b7ac-f5523df245e5', '5738f7a7-4455-50cd-95e0-55db19a560dc', 'd7116870-293d-5cef-8a32-0c333aacae25', 'b2ce4f31-954d-5335-8856-d631d3b5367c', '6ffdbb93-ede9-5e62-be42-65966de4f96a', '8dfd5ec6-c71f-5219-8bce-9ad14870bbd7', 'dc82dfa1-93a1-581d-9594-268c5821db97', '7684b18e-89f1-5a48-8a35-87df42b6ec00', '0701b1c9-b674-5117-adec-9dd89b6ef461', 'f1a84dec-be51-52d5-8188-ded21b93625a', '385d3358-1fd2-5fb7-96c5-a1e6e43aac45', 'a542e489-b013-5a16-880b-e876a7638c66', '684cdaec-9fad-5e95-9eb9-ec4f5e4da270', '7eefce7c-3c81-5f17-8b6d-f5fb6bf687f6', '25f19121-face-5148-b2c9-8d72e245b1bf', '14b89d35-8bd7-5be0-af51-59dcf9ff89cd', 'a70ed1aa-1597-58e8-a9b5-89bc0bf6dc82', 'd26ebdb0-0235-503a-95ae-ca80ff317109', 'fcafbc96-f418-5e70-9876-80501f36765f', '44e8d096-00db-5200-9cee-d2834f43003e', '2e4124a4-7880-521e-a4bc-c3ea7069a355', '369838cf-df84-5d03-8008-2a92c80c29f7', '4fb8d2a3-ed73-5de4-97f6-fdbfd6811792', '3df5d146-afc0-55bb-8697-a2dd2f9a6e5e', 'eeddbee4-f944-5a97-ac9f-341009149836', 'e9f2ca76-7c3b-53d9-b552-2e0ef00ffdab', '589389a2-873d-5c4e-b320-5671fe4e3682', 'cfeece52-a7f9-5804-ae0b-934ddeb71e78', 'fa30bca0-54aa-5035-8804-42f5b62291e4', '608e7d90-ab65-5abe-a9cc-8eedf30bd3f8', 'cc30520f-9446-5aca-bcc9-5c4c73c1e432', 'c8025cc5-45ea-54cb-9157-ae919db57852', 'e1d15bf5-ae41-59fa-bf39-cf3f614831a8', 'b3a7d2cf-7e00-5af1-af94-d6c497c618cb', 'ee960f87-35ca-5eaf-ac5e-afff1db68ac7', '2e04b106-5d51-52e1-a558-2e37b58db658', 'f80c0d32-cf27-5fc7-b713-e07be27583ba', '51684c99-2943-5cb3-915b-bc151d90854d', 'e4735e61-30a3-5e86-b189-9065565e36d1', '881b93fc-9263-5cd2-8d84-cac759504d13', '5e71fac6-ed40-5636-83fd-9e68f30f8183', 'f51ea55b-7685-5b8c-a58d-5c33f93d9b1a', '131edc97-c65c-56eb-b866-fe52a08581f7', 'c4b02cab-c78b-579e-bfde-2116accaab8d', '7663c1a7-5c3e-5d78-8504-0173bb5ab3a1', '32c1051f-eb49-55cf-b838-9d6accf8b621', 'fb573ae8-3e5e-5f18-8994-f82a1a3de82f', '17ca2376-79c5-5cd3-90ea-aa8bbaae8e41', '4093357d-6022-5326-b3cd-2eff29dfdb62', 'e41fb1f7-2b3f-5834-a8f6-d6be5432c1b9', '5befa49a-f1cd-51f7-94b9-055cb7549d4f', '3f14ae86-598f-521e-ad57-d62de948bc50', 'c6b70029-cdfc-5884-a315-4e4631c7503b', 'e8db4364-b3db-5ac8-a5a9-dd39e99ca7ed', '4454653b-ca14-5fa6-ad7c-355631b85b94', '5805bde0-0b9d-531f-9221-2e6786c343ef', '2f37f839-6c2b-5f7f-8c4c-ff9e5bb4897d', '9a431587-d9e7-5556-8251-66dc8acb2e1e', 'c6c29558-2cd2-5bd2-b4c1-182a831f9bbc', '85c88195-e242-5af4-94a8-6d253d316fff', 'bfb42a16-f593-549c-a816-327208609cd9', 'bacbc7f9-63d4-5077-8b53-336c36f6fecc', 'a4f1b77c-0b64-50a9-82ed-9700601bdd67', '1f0d04b8-d306-5c58-a1bb-74b3e8b1eb2c', 'faa2da0c-b654-502e-8bad-9cff25b191f2', '08078a8d-d762-5371-afff-8f540828ee25', 'd524ed19-3273-59e7-9b7d-1e0a3e7a52b5', '96c110ee-724f-5b88-8af8-d364b9f36f8c', 'a2868e9e-64dc-5f00-b6aa-c7531bfdc971', '618f840f-614e-5684-a36d-6267a164f087', '5fad6abe-68e0-5258-b463-a61ede9c3e55', '021c7772-0e91-567e-b221-4c8b22289c28', '107d0f44-3516-5ed0-8da8-d174749abf9b') and status = 'PUBLISHED';
  select count(*) into v_bad from (values ('a1-m08', 20), ('a1-m09', 20), ('a1-m10', 14), ('a1-m11', 12), ('a1-m12', 16), ('a1-m13', 12), ('a1-mid', 30), ('a1-final', 48)) e(slug, n) left join public.assessments a on a.slug = e.slug and a.cefr = 'A1' and a.status = 'PUBLISHED'
   where a.id is null
      or (select count(*) from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED') <> e.n
      or exists (select 1 from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED' and i.id not in ('e781fbe7-f966-553a-90c5-da7061e2850a', 'dfdf7896-140e-51ca-883d-2e6359f9ded8', '7b19b539-ba96-5c14-9a47-02313950b40d', '1b2eb7a6-93d0-5b82-ac74-2a50831bed16', '1fedca0d-3e82-55d2-8ac1-255b4d62bc38', 'e75f4533-9e17-5285-a873-7c8c26955408', 'ae16ee49-77c2-5bfe-baf1-e0296f887265', '20a3cf6f-dd33-57ca-902a-3523d61f41b6', '851c46ad-a4d1-5381-a56f-9dd432ca52bd', '219e10fe-f603-57ee-a03d-0cd51266e417', '0f9b6b97-62c2-5366-a988-5ca86a0130f7', '91b5d109-d409-575a-97ea-8b95bd4044bc', '7f5e83d3-0fc7-59d5-9bfc-e7d3b13e27c5', '6d66626f-11aa-59a6-be73-f4e4ac2695d1', 'cf2abaec-7900-52e8-ad5a-d08a3f667ed2', '140e45ba-9a94-52df-8cf2-85c076a038ae', 'd3f7c59c-5234-59c7-b35a-f5de2df16025', '6289dcf1-2afc-540f-af0b-c7f0a7c2fca9', '58e03128-0e49-5d97-86f8-73b07aceaf30', '672c3585-8cd5-5251-b146-e1023da892c3', '4e4a5295-4749-5619-8e36-201b439c3fa8', 'c43ef766-2143-510b-a697-066381109041', '9eca1095-06a0-5162-8bd2-7ae5748cdc0d', '9688a198-6d03-5089-abf7-0a9e1e191128', 'c32b35a0-1d7a-5ab5-9ca9-d07ca6c78c54', 'c005b961-788d-5b37-b837-0234a2e95645', '4c913ccd-c5e9-5fcc-b79d-12d0564407f5', 'c0f8821f-6a7a-5a4a-966c-44a705839e22', '09c1e2f5-0215-533c-b16f-8753e92456be', 'f37094d7-9c5b-5edc-a1f2-3b40f429ea5b', '61e06811-848e-5df8-bd2b-81b2c5aaf346', '59f61add-be7b-5110-ad3c-0c9fb429048b', '8a895493-cf6d-5b42-83bc-45af4c2860ce', '12f86858-a0d6-5327-830f-8b393d0aeb7b', 'aa465352-dcf7-5c0f-b23b-7fcd474fd98c', '571746cb-180f-572c-9b29-238ae8eca571', '732cb6d3-b93a-5a39-b647-606571ae7a8d', 'e4c6edc6-af1a-500d-a622-c8350006fb0d', '078c7f43-2783-5afb-913a-2cc89185fd1d', '63bf30e1-39c4-52d0-9b91-cf468ab65f7a', 'a98e6caa-e694-58cb-bf06-92b870231c53', 'efe60c38-6622-5d52-8f5f-269665e98d32', '3fb37c1c-89ae-5e0f-8155-e1819883051f', '98c0ef1c-5835-5051-9947-40b09d53c3cd', '64f400d5-e09c-5e6c-a40e-20c9492ffa16', 'aa525570-fff3-5633-865a-5ec4671ce348', '974ac4f1-ff69-5f28-826d-7254dce6edbb', 'f101ff1d-73a6-5a7e-9faa-a35e9f83572c', '507b3173-c09c-5cf5-a91d-db67d3789a89', '5754ebbf-311d-595e-a214-e26595e20c7f', '38bb4954-7f25-5566-beb6-f37e21886710', '5088a719-38bf-5f3e-9efd-9700e3fffb45', 'b983944b-500c-5511-a467-e6c37294ed2c', '914769b8-3144-5643-92d7-f6b1be460bd4', '55e3e06c-20a8-5027-83f0-270e4875c602', '1c8fe3d0-602f-5716-8f7a-d3a0872c3535', '36ad1d31-e5bf-5eb4-b99e-a351650dfdfa', 'b1937105-4cfc-5edc-b405-3c7de14f50d1', 'ac5a4c1d-a93a-5f06-a58e-7686887646e5', 'b2bd7c82-439e-5d39-b484-5c4fa11ea7bd', 'c93a48c4-b892-5dce-b342-b60c5ec7ac7d', '19b0116c-ede7-5a0a-86ac-aa41bb5d6fc8', '9b610e0b-22d2-52b5-9e4e-c5204aedf085', 'a76af275-5657-5673-85aa-51b11704bafb', '9b5d8f90-e5ef-5c1a-a1bf-40771de86e9d', '6f7a4ea0-8fc8-5291-8e8e-71111e4e7a0e', '74696b91-4be4-5f6e-a402-198f25a19db8', 'e8046723-d989-5f44-8f18-1da3fe79bdd6', '8291833d-436d-5eaf-9dba-c0d5043d56e3', '06c9e3c3-ea9d-56c4-bc07-5afa489de1a3', '57640148-343e-5b54-bd3a-2e87f5271d15', '88e69743-3f9b-571c-863d-c28f72654dfa', '3481db4f-a8cb-5b09-a050-56bffcc53293', '49db07a0-49f3-51fa-97ce-c573d45a6fd8', '6de484c1-2512-5db3-afdc-995dc35e162e', '8892735c-161e-5fa6-8ed3-f0781696a2d7', '1dd595a9-969f-5287-ab07-d9df04c47124', '74dace8c-7180-5617-a05d-036d87015e26', '0bc69fb6-241c-5ad9-ad25-7a5bb1880158', '7d3c3b29-adc0-587a-9303-6f4aaa85229e', '2a53ab53-edfa-5163-bb17-b2a4b54feee8', 'fcfef40b-69f1-530f-8cde-57ee253392a2', '0428d914-caee-56c8-be1c-b91ec744a9d6', '158f628a-ef5d-5042-a8bd-897c38698d50', '229c7a84-5161-5803-b063-97738db76064', 'b3bc0b47-ce18-5fdb-92fb-46bcbde4daea', 'b9c6f368-806f-5d13-b1d7-628b7e0245d1', 'bf6b7f3a-b00f-5812-b0b2-b1d711ab2058', '33b3a0e5-4446-5e07-95e9-3eab54fb338d', '6f0d4eba-06dc-5633-af9c-00a36327e649', '0dfdc574-da2a-5879-973d-01dcfb152a40', 'b7ee58f0-023d-50aa-8843-3a356bcce41e', '2fba6a1d-3c54-5d50-aadf-29c5d4f2313d', '32ab3308-c884-5acc-9ed7-8ae445a323d0', '62c3b7b1-a4fb-57b6-a7e7-2def7950e50f', '932d6275-f052-5fc4-98f1-1413a0d85205', 'd8b1af9c-b8fa-540b-b322-f14f401ca888', 'f85ae4e8-509a-5ebe-b9d5-a1fbb4d5575b', 'f87b6a2a-51d5-5a86-a8ce-6c5109aba404', '96128980-36c6-53f3-b7ac-f5523df245e5', '5738f7a7-4455-50cd-95e0-55db19a560dc', 'd7116870-293d-5cef-8a32-0c333aacae25', 'b2ce4f31-954d-5335-8856-d631d3b5367c', '6ffdbb93-ede9-5e62-be42-65966de4f96a', '8dfd5ec6-c71f-5219-8bce-9ad14870bbd7', 'dc82dfa1-93a1-581d-9594-268c5821db97', '7684b18e-89f1-5a48-8a35-87df42b6ec00', '0701b1c9-b674-5117-adec-9dd89b6ef461', 'f1a84dec-be51-52d5-8188-ded21b93625a', '385d3358-1fd2-5fb7-96c5-a1e6e43aac45', 'a542e489-b013-5a16-880b-e876a7638c66', '684cdaec-9fad-5e95-9eb9-ec4f5e4da270', '7eefce7c-3c81-5f17-8b6d-f5fb6bf687f6', '25f19121-face-5148-b2c9-8d72e245b1bf', '14b89d35-8bd7-5be0-af51-59dcf9ff89cd', 'a70ed1aa-1597-58e8-a9b5-89bc0bf6dc82', 'd26ebdb0-0235-503a-95ae-ca80ff317109', 'fcafbc96-f418-5e70-9876-80501f36765f', '44e8d096-00db-5200-9cee-d2834f43003e', '2e4124a4-7880-521e-a4bc-c3ea7069a355', '369838cf-df84-5d03-8008-2a92c80c29f7', '4fb8d2a3-ed73-5de4-97f6-fdbfd6811792', '3df5d146-afc0-55bb-8697-a2dd2f9a6e5e', 'eeddbee4-f944-5a97-ac9f-341009149836', 'e9f2ca76-7c3b-53d9-b552-2e0ef00ffdab', '589389a2-873d-5c4e-b320-5671fe4e3682', 'cfeece52-a7f9-5804-ae0b-934ddeb71e78', 'fa30bca0-54aa-5035-8804-42f5b62291e4', '608e7d90-ab65-5abe-a9cc-8eedf30bd3f8', 'cc30520f-9446-5aca-bcc9-5c4c73c1e432', 'c8025cc5-45ea-54cb-9157-ae919db57852', 'e1d15bf5-ae41-59fa-bf39-cf3f614831a8', 'b3a7d2cf-7e00-5af1-af94-d6c497c618cb', 'ee960f87-35ca-5eaf-ac5e-afff1db68ac7', '2e04b106-5d51-52e1-a558-2e37b58db658', 'f80c0d32-cf27-5fc7-b713-e07be27583ba', '51684c99-2943-5cb3-915b-bc151d90854d', 'e4735e61-30a3-5e86-b189-9065565e36d1', '881b93fc-9263-5cd2-8d84-cac759504d13', '5e71fac6-ed40-5636-83fd-9e68f30f8183', 'f51ea55b-7685-5b8c-a58d-5c33f93d9b1a', '131edc97-c65c-56eb-b866-fe52a08581f7', 'c4b02cab-c78b-579e-bfde-2116accaab8d', '7663c1a7-5c3e-5d78-8504-0173bb5ab3a1', '32c1051f-eb49-55cf-b838-9d6accf8b621', 'fb573ae8-3e5e-5f18-8994-f82a1a3de82f', '17ca2376-79c5-5cd3-90ea-aa8bbaae8e41', '4093357d-6022-5326-b3cd-2eff29dfdb62', 'e41fb1f7-2b3f-5834-a8f6-d6be5432c1b9', '5befa49a-f1cd-51f7-94b9-055cb7549d4f', '3f14ae86-598f-521e-ad57-d62de948bc50', 'c6b70029-cdfc-5884-a315-4e4631c7503b', 'e8db4364-b3db-5ac8-a5a9-dd39e99ca7ed', '4454653b-ca14-5fa6-ad7c-355631b85b94', '5805bde0-0b9d-531f-9221-2e6786c343ef', '2f37f839-6c2b-5f7f-8c4c-ff9e5bb4897d', '9a431587-d9e7-5556-8251-66dc8acb2e1e', 'c6c29558-2cd2-5bd2-b4c1-182a831f9bbc', '85c88195-e242-5af4-94a8-6d253d316fff', 'bfb42a16-f593-549c-a816-327208609cd9', 'bacbc7f9-63d4-5077-8b53-336c36f6fecc', 'a4f1b77c-0b64-50a9-82ed-9700601bdd67', '1f0d04b8-d306-5c58-a1bb-74b3e8b1eb2c', 'faa2da0c-b654-502e-8bad-9cff25b191f2', '08078a8d-d762-5371-afff-8f540828ee25', 'd524ed19-3273-59e7-9b7d-1e0a3e7a52b5', '96c110ee-724f-5b88-8af8-d364b9f36f8c', 'a2868e9e-64dc-5f00-b6aa-c7531bfdc971', '618f840f-614e-5684-a36d-6267a164f087', '5fad6abe-68e0-5258-b463-a61ede9c3e55', '021c7772-0e91-567e-b221-4c8b22289c28', '107d0f44-3516-5ed0-8da8-d174749abf9b'));
  if v_new <> 172 or v_bad > 0 then raise exception 'Перевірки A1: нових завдань % (очікувалось 172), тестів з помилкою %', v_new, v_bad; end if;
  raise notice 'Готово: 20261116_assessments_a1_v5_part2.sql — 8 тестів, % нових завдань', v_new;
end $$;

commit;
