-- =====================================================================
-- Перевірки рівня A0 після плану «Дублі й сенс уроків» (PR 2б) · 2026-11-17
-- Згенеровано: python3 -B scripts/gen_a0_dupes.py assessments (не редагуйте вручну).
--
-- Запускати після 20261117_a0_dupes_1_lessons.sql і _2_reading.sql (назва файлу стоїть після них — «Apply SQL» запускає за назвою).
-- Схема 2026-11-07: модуль — 2 завдання на урок (12–20), фінал — 48 (кожен модуль — щонайменше 2). У файлі 76 нових завдань:
--   a0-m09 — 12, a0-m11 — 16, a0-final — 48.
--   * a0-m09 — наново (одне завдання було з діалогу «U trgovini odjećom», який замінено); a0-m11 — 8 уроків з новим «В аптеці»;
--   * a0-final — наново з усіх 11 модулів (з A0.6 «Kućni ljubimci» і новими текстами A0.6), без джерел і речень тестів модулів
--     і середини. Середина (a0-mid) і решта тестів модулів не змінюються.
--   * Завдання — з діалогів, вправ і текстів уроків; нових хорватських речень немає. Старі завдання — у content_versions і DEPRECATED.
--   * Спроби й результати користувачів не змінюються. Повторний запуск нічого не змінює.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника.
-- Очікуване повідомлення: «Готово: 20261117_a0_dupes_3_tests.sql — 3 тести, 76 нових завдань».
-- =====================================================================

begin;

-- Перевірка модуля A0.9 · 12 завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = 'a0-m09' and cefr = 'A0';
  if v_aid is null then raise exception 'Немає тесту a0-m09 — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = 'b9fbf069-538f-5f2b-849a-ae914b27d69e') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from '3fbf61ad-1d1b-5447-8c67-5896b1cc1f59'::uuid then
    raise exception 'Тест a0-m09 прив’язаний не до модуля A0.9 — звірте базу';
  end if;
  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
          v_payload, 'a0_dupes: перевірку оновлено після плану «Дублі й сенс уроків» (PR 2б) — старі завдання');
  select (coalesce(max(order_index), 0) / 100 + 1) * 100 into v_shift from public.assessment_items where assessment_id = v_aid;
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + v_shift
   where assessment_id = v_aid and status = 'PUBLISHED';
  update public.assessments set description_ua = 'Після модуля: 12 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~6 хв.', estimated_minutes = 6 where id = v_aid;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, answer_alternatives, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('b9fbf069-538f-5f2b-849a-ae914b27d69e', v_aid, 1, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Подобається. Маркові потрібен костюм на весілля.", "Напиши мені список, будь ласка.", "Без проблем. Прошу, приміряйте цю."]'::jsonb, 2, null, '{}'::text[], 'Nema problema. Izvolite, probajte ovu.', null, null, 'Прозвучало: «Nema problema. Izvolite, probajte ovu.» — «Без проблем. Прошу, приміряйте цю.».', (select id from public.lessons where id = '28913ad6-490f-5d89-bad7-9b303c673fcd'), 'PUBLISHED', 'claude_assessment_v5'),
  ('021a2544-a257-51a1-a88b-ba498172058a', v_aid, 2, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Дякую! А ти завжди носиш бежеве й сіре.", "Дайте мені дві морквини, одну цибулину й кілограм картоплі.", "Чудово! Заходьмо, у них і нижня білизна зі знижкою."]'::jsonb, 0, null, '{}'::text[], 'Hvala! A ti uvijek nosiš bež i sivo.', null, null, 'Прозвучало: «Hvala! A ti uvijek nosiš bež i sivo.» — «Дякую! А ти завжди носиш бежеве й сіре.».', (select id from public.lessons where id = '288e7610-99c8-5696-989a-86f60ce38b0a'), 'PUBLISHED', 'claude_assessment_v5'),
  ('f9c5fb51-8629-539b-a1c8-9abcd8882019', v_aid, 3, 'A0', 'reading', 'understand', 'multiple_choice', 'Де фрукти й овочі?', 'Odjeli u trgovini', '["Ліворуч", "Прямо", "Праворуч"]'::jsonb, 0, null, '{}'::text[], null, 'Voće i povrće ←
Mlijeko i sir →
Pića →
Kruh ↑
WC i izlaz ↓', 'Фрукти й овочі ←
Молоко й сир →
Напої →
Хліб ↑
Туалет і вихід ↓', 'Текст «Відділи магазину». Правильна відповідь: «Ліворуч».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('05b50b1f-1be0-5c5f-b05c-eb2e4606fc9b', v_aid, 4, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Koliko košta ova stara lampa?', '["Imao je. Nahranio sam ga i nazvao sklonište za životinje.", "Vani, ispred zgrade.", "Trideset eura."]'::jsonb, 2, null, '{}'::text[], 'Koliko košta ova stara lampa?', null, null, 'Діалог «На блошиному ринку»: «Koliko košta ova stara lampa?» (Скільки коштує ця стара лампа?) — «Trideset eura.» (Тридцять євро.).', (select id from public.lessons where id = '6836e57c-030c-59f8-9818-b44c08b126a6'), 'PUBLISHED', 'claude_assessment_v5'),
  ('917540e9-a6fc-5904-b099-b8576c6f95ac', v_aid, 5, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Imam, evo ga. Mogu li je zamijeniti?', '["Možete je zamijeniti ili dobiti povrat novca.", "Obično ne ručam. Navečer večeram s obitelji.", "Loše. Boli me glava i hladno mi je."]'::jsonb, 0, null, '{}'::text[], 'Imam, evo ga. Mogu li je zamijeniti?', null, null, 'Діалог «Обмін куртки»: «Imam, evo ga. Mogu li je zamijeniti?» (Є, ось він. Можна її обміняти?) — «Možete je zamijeniti ili dobiti povrat novca.» (Можете її обміняти або отримати гроші назад.).', (select id from public.lessons where id = '28913ad6-490f-5d89-bad7-9b303c673fcd'), 'PUBLISHED', 'claude_assessment_v5'),
  ('bc0a9701-38fb-5401-bdfe-bc39e09599b0', v_aid, 6, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Naravno. Ovu ili onu?', '["Onu domaću. I pola kile mljevenog mesa.", "Ukusna je, ali malo preslana.", "Ja imam psa. Svako jutro ga šetam u parku."]'::jsonb, 0, null, '{}'::text[], 'Naravno. Ovu ili onu?', null, null, 'Діалог «У м’ясній лавці»: «Naravno. Ovu ili onu?» (Звісно. Цю чи ту?) — «Onu domaću. I pola kile mljevenog mesa.» (Ту, домашню. І пів кіло фаршу.).', (select id from public.lessons where id = '0e925295-2766-5931-b031-2412682bc6f8'), 'PUBLISHED', 'claude_assessment_v5'),
  ('0a7033ff-1104-514e-a819-1826cd7fb376', v_aid, 7, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Lijepa je, ali tražim jednobojnu. Imate li tamnoplavu?', '["Є біла й оця в смужку.", "На жаль, лише чорна й сіра.", "Шукаю сорочку для роботи, білу чи блакитну."]'::jsonb, 1, null, '{}'::text[], null, 'Prodavač: Tražite li nešto određeno?
Daša: Tražim košulju za posao, bijelu ili svijetloplavu.
Prodavač: Imamo bijelu i ovu na pruge.
Daša: Lijepa je, ali tražim jednobojnu. Imate li tamnoplavu?
Prodavač: Nažalost, samo crnu i sivu.
Daša: Onda uzimam bijelu.', 'Prodavač: Шукаєте щось конкретне?
Daša: Шукаю сорочку для роботи, білу чи блакитну.
Prodavač: Є біла й оця в смужку.
Daša: Гарна, але я шукаю однотонну. Темно-синя є?
Prodavač: На жаль, лише чорна й сіра.
Daša: Тоді беру білу.', 'Діалог «Сорочка для роботи»: «Lijepa je, ali tražim jednobojnu. Imate li tamnoplavu?» — «Nažalost, samo crnu i sivu.», тобто «На жаль, лише чорна й сіра.».', (select id from public.lessons where id = '288e7610-99c8-5696-989a-86f60ce38b0a'), 'PUBLISHED', 'claude_assessment_v5'),
  ('73a06ea5-bf85-5204-9a3d-0ca31075691a', v_aid, 8, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Karticom. Može li beskontaktno?', '["Готово. Дякую, до побачення!", "Можна. Прикладіть картку сюди.", "Так, один, будь ласка."]'::jsonb, 1, null, '{}'::text[], null, 'Blagajnica: Dobar dan. Trebate li vrećicu?
Daša: Da, jednu, molim.
Blagajnica: Ukupno dvadeset tri eura. Karticom ili gotovinom?
Daša: Karticom. Može li beskontaktno?
Blagajnica: Može. Prislonite karticu ovdje.
Daša: Gotovo. Hvala, doviđenja!', 'Blagajnica: Добрий день. Вам потрібен пакет?
Daša: Так, один, будь ласка.
Blagajnica: Разом двадцять три євро. Карткою чи готівкою?
Daša: Карткою. Можна безконтактно?
Blagajnica: Можна. Прикладіть картку сюди.
Daša: Готово. Дякую, до побачення!', 'Діалог «Карткою чи готівкою?»: «Karticom. Može li beskontaktno?» — «Može. Prislonite karticu ovdje.», тобто «Можна. Прикладіть картку сюди.».', (select id from public.lessons where id = '28913ad6-490f-5d89-bad7-9b303c673fcd'), 'PUBLISHED', 'claude_assessment_v5'),
  ('6362f3a8-1c48-520d-b8c2-869914f7173c', v_aid, 9, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Ще щось?». Що ви скажете?', null, '["Kakve je boje?", "Deset deka sira, molim.", "Još nešto?"]'::jsonb, 2, null, '{}'::text[], null, null, null, '«Ще щось?» — «Još nešto?».', (select id from public.lessons where id = '0e925295-2766-5931-b031-2412682bc6f8'), 'PUBLISHED', 'claude_assessment_v5'),
  ('6ee47b36-aabe-54a8-b131-450313914534', v_aid, 10, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «нарізати»', null, '[]'::jsonb, null, 'narezati', '{}'::text[], null, null, null, '«нарізати» — narezati.', (select id from public.lessons where id = '0e925295-2766-5931-b031-2412682bc6f8'), 'PUBLISHED', 'claude_assessment_v5'),
  ('f12411bc-25ea-5b46-ae59-3f80a0e6ee9c', v_aid, 11, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Скільки коштує кілограм?»', null, '["Koliko", "kila?", "košta"]'::jsonb, null, 'Koliko košta kila?', array['Koliko kila košta?']::text[], null, null, null, '«Скільки коштує кілограм?» — «Koliko košta kila?».', (select id from public.lessons where id = 'e495a4dd-a963-5a5f-af8c-09b2ea6a2ea0'), 'PUBLISHED', 'claude_assessment_v5'),
  ('73b24486-727d-5051-8248-77184ce0f194', v_aid, 12, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Це свіже?»', null, '[]'::jsonb, null, 'Je li ovo svježe?', '{}'::text[], null, null, null, '«Це свіже?» — «Je li ovo svježe?».', (select id from public.lessons where id = 'e495a4dd-a963-5a5f-af8c-09b2ea6a2ea0'), 'PUBLISHED', 'claude_assessment_v5');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірки рівня A0 за схемою 2026-11-07 після плану «Дублі й сенс уроків» (PR 2б, рішення власника 2026-11-17): тест модуля A0.9 наново (урок 58 — новий діалог). Завдання — з діалогів, вправ і текстів уроків. Потрібна перевірка носієм.');
end $$;

-- Перевірка модуля A0.11 · 16 завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = 'a0-m11' and cefr = 'A0';
  if v_aid is null then raise exception 'Немає тесту a0-m11 — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = 'd41bdf9c-2cd7-5b44-abda-354bf54c7b4d') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from '588b0086-831d-5577-b992-b00f68e9dd87'::uuid then
    raise exception 'Тест a0-m11 прив’язаний не до модуля A0.11 — звірте базу';
  end if;
  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
          v_payload, 'a0_dupes: перевірку оновлено після плану «Дублі й сенс уроків» (PR 2б) — старі завдання');
  select (coalesce(max(order_index), 0) / 100 + 1) * 100 into v_shift from public.assessment_items where assessment_id = v_aid;
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + v_shift
   where assessment_id = v_aid and status = 'PUBLISHED';
  update public.assessments set description_ua = 'Після модуля: 16 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~8 хв.', estimated_minutes = 8 where id = v_aid;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, answer_alternatives, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('d41bdf9c-2cd7-5b44-abda-354bf54c7b4d', v_aid, 1, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Так. Як вас звати і якої ви національності?", "Вибачте, я вас не почула. Можете повторити голосніше?", "Є ось ці таблетки. У вас є алергія на якісь ліки?"]'::jsonb, 2, null, '{}'::text[], 'Imamo ove tablete. Imate li alergiju na neki lijek?', null, null, 'Прозвучало: «Imamo ove tablete. Imate li alergiju na neki lijek?» — «Є ось ці таблетки. У вас є алергія на якісь ліки?».', (select id from public.lessons where id = 'a4455f67-27c7-5ad7-a454-771a94ca4e02'), 'PUBLISHED', 'claude_assessment_v5'),
  ('6e242b34-19f9-5954-b8cf-e9331b65dcbe', v_aid, 2, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Мабуть, кишеньковий злодій. Ви заблокували картку?", "Де це сталося?", "Добрий день, сідайте. Що вас турбує?"]'::jsonb, 2, null, '{}'::text[], 'Dobar dan, izvolite sjesti. Što vas muči?', null, null, 'Прозвучало: «Dobar dan, izvolite sjesti. Što vas muči?» — «Добрий день, сідайте. Що вас турбує?».', (select id from public.lessons where id = 'fbc71f82-e715-5bab-a990-b8542fb0fe01'), 'PUBLISHED', 'claude_assessment_v5'),
  ('e80a4ea1-119a-518a-8e01-b13d11dd1058', v_aid, 3, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Скільки зазвичай доводиться чекати?", "Вам потрібен оригінал чи копія диплома?", "Ой, мені шкода. Що саме сталося?"]'::jsonb, 0, null, '{}'::text[], 'Koliko se obično čeka?', null, null, 'Прозвучало: «Koliko se obično čeka?» — «Скільки зазвичай доводиться чекати?».', (select id from public.lessons where id = '19df3241-90f3-5450-94ac-642d79fb2869'), 'PUBLISHED', 'claude_assessment_v5'),
  ('57625b09-d2bf-5836-9c9b-bb6431093967', v_aid, 4, 'A0', 'reading', 'understand', 'multiple_choice', 'Який номер швидкої допомоги?', 'Ljekarna i hitni brojevi', '["194", "193", "192"]'::jsonb, 0, null, '{}'::text[], null, 'LJEKARNA
Otvoreno 0 – 24 h
HITNA POMOĆ: 194
Policija: 192
Vatrogasci: 193
Svi hitni slučajevi: 112', 'АПТЕКА
Відчинено цілодобово (0–24)
ШВИДКА ДОПОМОГА: 194
Поліція: 192
Пожежники: 193
Усі екстрені випадки: 112', 'Текст «Аптека і екстрені номери». Правильна відповідь: «194».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('8536e911-8258-5e3d-9d1e-5af239f53add', v_aid, 5, 'A0', 'reading', 'understand', 'multiple_choice', 'Який номер для всіх екстрених випадків?', 'Ljekarna i hitni brojevi', '["911", "112", "102"]'::jsonb, 1, null, '{}'::text[], null, 'LJEKARNA
Otvoreno 0 – 24 h
HITNA POMOĆ: 194
Policija: 192
Vatrogasci: 193
Svi hitni slučajevi: 112', 'АПТЕКА
Відчинено цілодобово (0–24)
ШВИДКА ДОПОМОГА: 194
Поліція: 192
Пожежники: 193
Усі екстрені випадки: 112', 'Текст «Аптека і екстрені номери». Правильна відповідь: «112».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('235e75c8-5e22-540d-94bb-022cf8bd4719', v_aid, 6, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Gdje mogu ovjeriti kopiju?', '["Trideset posto na sve jakne.", "To je najpoznatija kula u gradu. Ima dugu povijest.", "Kod javnog bilježnika. Treba vam pečat i potpis."]'::jsonb, 2, null, '{}'::text[], 'Gdje mogu ovjeriti kopiju?', null, null, 'Діалог «Копія чи оригінал?»: «Gdje mogu ovjeriti kopiju?» (Де можна засвідчити копію?) — «Kod javnog bilježnika. Treba vam pečat i potpis.» (У нотаріуса. Потрібні печатка й підпис.).', (select id from public.lessons where id = 'b095637e-0644-507e-8f3d-d323483dd3e4'), 'PUBLISHED', 'claude_assessment_v5'),
  ('5462a8a5-f45e-5dc6-917c-a121d32c40e1', v_aid, 7, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Dobro. I tablete za grlo, molim. Koliko je sve zajedno?', '["Dvanaest eura. Neka kći brzo ozdravi!", "Na kraju hodnika, pored spavaće sobe. Zahod je odvojen.", "Moj dečko Petar. Vjenčanje je u lipnju."]'::jsonb, 0, null, '{}'::text[], 'Dobro. I tablete za grlo, molim. Koliko je sve zajedno?', null, null, 'Діалог «Чергова аптека»: «Dobro. I tablete za grlo, molim. Koliko je sve zajedno?» (Добре. І таблетки для горла, будь ласка. Скільки все разом?) — «Dvanaest eura. Neka kći brzo ozdravi!» (Дванадцять євро. Хай донька швидко одужує!).', (select id from public.lessons where id = 'a4455f67-27c7-5ad7-a454-771a94ca4e02'), 'PUBLISHED', 'claude_assessment_v5'),
  ('4868f8fa-4e90-5e9b-888f-83fef4cfc2ff', v_aid, 8, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'U obrascu imam jednu pogrešku. Mogu li je ispraviti?', '["Tražim kauč za dnevni boravak.", "Zajedno. Danas ja častim!", "Možete, ali bolje ispunite novi."]'::jsonb, 2, null, '{}'::text[], 'U obrascu imam jednu pogrešku. Mogu li je ispraviti?', null, null, 'Діалог «Копія чи оригінал?»: «U obrascu imam jednu pogrešku. Mogu li je ispraviti?» (У бланку в мене одна помилка. Можна її виправити?) — «Možete, ali bolje ispunite novi.» (Можна, але краще заповніть новий.).', (select id from public.lessons where id = 'b095637e-0644-507e-8f3d-d323483dd3e4'), 'PUBLISHED', 'claude_assessment_v5'),
  ('24ced317-11a3-52bc-a176-553b22ab4df8', v_aid, 9, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Jeste li vidjeli lopova?', '["Я його погано бачила. Він був високий, у чорній шапці.", "Добре. У трамваї є камери. Ось протокол, підпишіть тут.", "Дякую. Сподіваюся, ви його знайдете."]'::jsonb, 0, null, '{}'::text[], null, 'Policajka: Jeste li vidjeli lopova?
Darja: Nisam ga dobro vidjela. Bio je visok, s crnom kapom.
Policajka: Je li bio netko sumnjiv u blizini?
Darja: Jedan muškarac je stajao uz mene cijelo vrijeme.
Policajka: Dobro. U tramvaju ima kamera. Evo zapisnika, potpišite ovdje.
Darja: Hvala. Nadam se da ćete ga naći.', 'Policajka: Ви бачили злодія?
Darja: Я його погано бачила. Він був високий, у чорній шапці.
Policajka: Чи був хтось підозрілий поблизу?
Darja: Один чоловік увесь час стояв біля мене.
Policajka: Добре. У трамваї є камери. Ось протокол, підпишіть тут.
Darja: Дякую. Сподіваюся, ви його знайдете.', 'Діалог «Свідок»: «Jeste li vidjeli lopova?» — «Nisam ga dobro vidjela. Bio je visok, s crnom kapom.», тобто «Я його погано бачила. Він був високий, у чорній шапці.».', (select id from public.lessons where id = 'd2689a70-cb73-515f-9d81-6bb0f0fc1cff'), 'PUBLISHED', 'claude_assessment_v5'),
  ('5d0e445f-056f-5a3d-bf69-d491bfc2b27e', v_aid, 10, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Gdje se to dogodilo?', '["Добрий день, я хочу заявити про крадіжку.", "У трамваї. Була тіснява, і раптом гаманець зник.", "Шкіряний гаманець із посвідченням особи й карткою."]'::jsonb, 1, null, '{}'::text[], null, 'Daša: Dobar dan, želim prijaviti krađu.
Policajac: Što vam je ukradeno?
Daša: Kožni novčanik s osobnom iskaznicom i karticom.
Policajac: Gdje se to dogodilo?
Daša: U tramvaju. Bila je gužva i odjednom je novčanik nestao.
Policajac: Vjerojatno džeparoš. Jeste li blokirali karticu?', 'Daša: Добрий день, я хочу заявити про крадіжку.
Policajac: Що у вас украли?
Daša: Шкіряний гаманець із посвідченням особи й карткою.
Policajac: Де це сталося?
Daša: У трамваї. Була тіснява, і раптом гаманець зник.
Policajac: Мабуть, кишеньковий злодій. Ви заблокували картку?', 'Діалог «Крадіжка в трамваї»: «Gdje se to dogodilo?» — «U tramvaju. Bila je gužva i odjednom je novčanik nestao.», тобто «У трамваї. Була тіснява, і раптом гаманець зник.».', (select id from public.lessons where id = 'd2689a70-cb73-515f-9d81-6bb0f0fc1cff'), 'PUBLISHED', 'claude_assessment_v5'),
  ('90715668-ddd7-5074-8651-d2bb7c1f1b8c', v_aid, 11, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «У мене вкрали гаманець». Що ви скажете?', null, '["Gdje je najbliža ljekarna?", "Je li ovaj sirup na recept?", "Ukrali su mi novčanik."]'::jsonb, 2, null, '{}'::text[], null, null, null, '«У мене вкрали гаманець.» — «Ukrali su mi novčanik.».', (select id from public.lessons where id = 'd2689a70-cb73-515f-9d81-6bb0f0fc1cff'), 'PUBLISHED', 'claude_assessment_v5'),
  ('2f0c907c-2cef-5d0a-aa69-ef4c8585ec05', v_aid, 12, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «У мене застуда». Що ви скажете?', null, '["Imam prehladu.", "Želim blokirati karticu.", "Gdje mogu uplatiti pristojbu?"]'::jsonb, 0, null, '{}'::text[], null, null, null, '«У мене застуда.» — «Imam prehladu.».', (select id from public.lessons where id = 'fbc71f82-e715-5bab-a990-b8542fb0fe01'), 'PUBLISHED', 'claude_assessment_v5'),
  ('08ed520e-2f80-58f5-95b3-ff1f0811f062', v_aid, 13, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «ночівля»', null, '[]'::jsonb, null, 'noćenje', '{}'::text[], null, null, null, '«ночівля» — noćenje.', (select id from public.lessons where id = 'edbae9ca-c4f4-575d-b876-d50b0a1fd9b5'), 'PUBLISHED', 'claude_assessment_v5'),
  ('a8843ba6-bc48-5790-b4a9-7c761d1b6666', v_aid, 14, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Де поліцейський відділок?»', null, '["Gdje", "je", "postaja?", "policijska"]'::jsonb, null, 'Gdje je policijska postaja?', '{}'::text[], null, null, null, '«Де поліцейський відділок?» — «Gdje je policijska postaja?».', (select id from public.lessons where id = 'd2689a70-cb73-515f-9d81-6bb0f0fc1cff'), 'PUBLISHED', 'claude_assessment_v5'),
  ('4092bf11-90a9-5328-9a95-481b0392d48e', v_aid, 15, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Я хочу записатися до лікаря.»', null, '["kod", "liječnika.", "Želim", "naručiti", "se"]'::jsonb, null, 'Želim se naručiti kod liječnika.', '{}'::text[], null, null, null, '«Я хочу записатися до лікаря.» — «Želim se naručiti kod liječnika.».', (select id from public.lessons where id = 'fbc71f82-e715-5bab-a990-b8542fb0fe01'), 'PUBLISHED', 'claude_assessment_v5'),
  ('e9464b04-f0e6-5b83-b37e-b47daa34d47f', v_aid, 16, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Можна залишити речі на рецепції?»', null, '[]'::jsonb, null, 'Mogu li ostaviti stvari na recepciji?', '{}'::text[], null, null, null, '«Можна залишити речі на рецепції?» — «Mogu li ostaviti stvari na recepciji?».', (select id from public.lessons where id = 'edbae9ca-c4f4-575d-b876-d50b0a1fd9b5'), 'PUBLISHED', 'claude_assessment_v5');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірки рівня A0 за схемою 2026-11-07 після плану «Дублі й сенс уроків» (PR 2б, рішення власника 2026-11-17): тест модуля A0.11 наново (8 уроків з новим «В аптеці»). Завдання — з діалогів, вправ і текстів уроків. Потрібна перевірка носієм.');
end $$;

-- Фінальна перевірка рівня A0 · 48 завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = 'a0-final' and cefr = 'A0';
  if v_aid is null then raise exception 'Немає тесту a0-final — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = 'd2b63def-450b-5644-aa65-56aa9b655417') then return; end if;  -- уже оновлено
  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
          v_payload, 'a0_dupes: перевірку оновлено після плану «Дублі й сенс уроків» (PR 2б) — старі завдання');
  select (coalesce(max(order_index), 0) / 100 + 1) * 100 into v_shift from public.assessment_items where assessment_id = v_aid;
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + v_shift
   where assessment_id = v_aid and status = 'PUBLISHED';
  update public.assessments set description_ua = 'Кінець рівня (усі 11 модулів A0): 48 завдань на 4 навички. ~25 хв.', estimated_minutes = 25 where id = v_aid;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, answer_alternatives, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('d2b63def-450b-5644-aa65-56aa9b655417', v_aid, 1, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Майже вісімсот тисяч.", "А, я неправильно записала. Дякую!", "Ні, ви набрали не той номер."]'::jsonb, 0, null, '{}'::text[], 'Gotovo osamsto tisuća.', null, null, 'Прозвучало: «Gotovo osamsto tisuća.» — «Майже вісімсот тисяч.».', (select id from public.lessons where id = '1f41cb75-1ce5-57ba-a56f-58561ee1d983'), 'PUBLISHED', 'claude_assessment_v5'),
  ('6259c5bd-d0f1-5d9c-8951-b8c365150281', v_aid, 2, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Коробки залишаємо тут, у кутку?", "Дашо, скільки ти платиш за комунальні?", "Дашо, яка твоя нова квартира?"]'::jsonb, 2, null, '{}'::text[], 'Dašo, kakav je tvoj novi stan?', null, null, 'Прозвучало: «Dašo, kakav je tvoj novi stan?» — «Дашо, яка твоя нова квартира?».', (select id from public.lessons where id = 'f51692d8-cb95-5f2e-8263-f3728f5e10c0'), 'PUBLISHED', 'claude_assessment_v5'),
  ('ea74d666-d94b-5538-b83c-0e669e0fa6c5', v_aid, 3, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Давай! Після такого мені треба чогось солодкого.", "Круасан чудовий! Ще один, будь ласка.", "Ні, дякую, мені цього досить. Але я хочу пити."]'::jsonb, 2, null, '{}'::text[], 'Ne, hvala, to mi je dosta. Ali žedna sam.', null, null, 'Прозвучало: «Ne, hvala, to mi je dosta. Ali žedna sam.» — «Ні, дякую, мені цього досить. Але я хочу пити.».', (select id from public.lessons where id = '7bbaf7ff-10bb-512a-91c5-798b59ec92a5'), 'PUBLISHED', 'claude_assessment_v5'),
  ('00487434-b348-552d-8d00-054a17935927', v_aid, 4, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Дякую. Можна відчинити вікно?", "А, зрозуміло! А як сказати «thank you»?", "Привіт, Дашо! Чудово, дякую. А ти?"]'::jsonb, 0, null, '{}'::text[], 'Hvala. Smijem li otvoriti prozor?', null, null, 'Прозвучало: «Hvala. Smijem li otvoriti prozor?» — «Дякую. Можна відчинити вікно?».', (select id from public.lessons where id = 'e704760a-f743-5762-9c1a-027b10ca030a'), 'PUBLISHED', 'claude_assessment_v5'),
  ('fae5c96c-5d4c-51a1-b6c6-b297bd62455b', v_aid, 5, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Два євро. Є ще свіжа полуниця.", "Я б краще обміняла її на менший розмір.", "Можна за дев’яносто п’ять. Вам це вигідно!"]'::jsonb, 1, null, '{}'::text[], 'Radije bih je zamijenila za manju veličinu.', null, null, 'Прозвучало: «Radije bih je zamijenila za manju veličinu.» — «Я б краще обміняла її на менший розмір.».', (select id from public.lessons where id = '28913ad6-490f-5d89-bad7-9b303c673fcd'), 'PUBLISHED', 'claude_assessment_v5'),
  ('c38544e7-620a-5845-8f4e-fab9f0113f7e', v_aid, 6, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Покажи. Тут болить?", "Мені треба вписати й OIB?", "Це щось небезпечне?"]'::jsonb, 1, null, '{}'::text[], 'Moram li upisati i OIB?', null, null, 'Прозвучало: «Moram li upisati i OIB?» — «Мені треба вписати й OIB?».', (select id from public.lessons where id = 'b095637e-0644-507e-8f3d-d323483dd3e4'), 'PUBLISHED', 'claude_assessment_v5'),
  ('afc400ba-065d-5cd1-adf8-6d02b18b48d1', v_aid, 7, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Салон «Івана», добрий день!", "Дякую, Івано! Заходь, торт на столі.", "Чудово, побачимося в понеділок!"]'::jsonb, 0, null, '{}'::text[], 'Salon Ivana, dobar dan!', null, null, 'Прозвучало: «Salon Ivana, dobar dan!» — «Салон «Івана», добрий день!».', (select id from public.lessons where id = '8e372ece-ae10-50ae-9cf3-07b52ef2f72d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('2991c66b-2663-5f81-bc5c-e6a78de22145', v_aid, 8, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["О чотирнадцятій тридцять, з п’ятого перону.", "Мені треба купити сувенір для мами.", "Близько п’яти годин."]'::jsonb, 1, null, '{}'::text[], 'Moram kupiti suvenir za mamu.', null, null, 'Прозвучало: «Moram kupiti suvenir za mamu.» — «Мені треба купити сувенір для мами.».', (select id from public.lessons where id = '1e0384e5-6097-56ed-ab56-cf530f02ab73'), 'PUBLISHED', 'claude_assessment_v5'),
  ('7f1f8345-5d2e-5a4c-a6e3-ee74ce3b2d0c', v_aid, 9, 'A0', 'reading', 'understand', 'multiple_choice', 'Коли кафе знову працюватиме?', 'Natpis na vratima kafića', '["Через тиждень", "Завтра", "У понеділок"]'::jsonb, 1, null, '{}'::text[], null, 'ZATVORENO
Oprostite, danas ne radimo.
Vidimo se sutra!
Hvala!', 'ЗАЧИНЕНО
Вибачте, сьогодні ми не працюємо.
Побачимося завтра!
Дякуємо!', 'Текст «Табличка на дверях кафе». Правильна відповідь: «Завтра».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('1ab1da14-2f37-5561-8f8f-fbf8477a796c', v_aid, 10, 'A0', 'reading', 'understand', 'multiple_choice', 'Чи можна прийти із собакою?', 'Dječje igralište', '["Тільки ввечері", "Ні", "Так"]'::jsonb, 1, null, '{}'::text[], null, 'DJEČJE IGRALIŠTE
Za djecu do 12 godina.
Roditelji, pazite na djecu!
Psi ne smiju ući.', 'ДИТЯЧИЙ МАЙДАНЧИК
Для дітей до 12 років.
Батьки, наглядайте за дітьми!
Собакам заходити не можна.', 'Текст «Дитячий майданчик». Правильна відповідь: «Ні».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('b8defc06-08cc-564e-ab91-b144bcf77110', v_aid, 11, 'A0', 'reading', 'understand', 'multiple_choice', 'Як часто він їздить на вихідних?', 'Vozni red autobusa', '["Кожні 30 хвилин", "Щогодини", "Не їздить"]'::jsonb, 1, null, '{}'::text[], null, 'AUTOBUS 6
Smjer: Kolodvor
Polasci: 7:15 • 7:45 • 8:15
Vikendom: svaki sat', 'АВТОБУС 6
Напрямок: вокзал
Відправлення: 7:15 • 7:45 • 8:15
На вихідних: щогодини', 'Текст «Розклад автобуса». Правильна відповідь: «Щогодини».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('6fda44b2-2e46-5868-81ab-a7920f3946eb', v_aid, 12, 'A0', 'reading', 'understand', 'multiple_choice', 'Що означає «Oprostite»?', 'Natpis na vratima kafića', '["Вибачте", "Дякую", "Привіт"]'::jsonb, 0, null, '{}'::text[], null, 'ZATVORENO
Oprostite, danas ne radimo.
Vidimo se sutra!
Hvala!', 'ЗАЧИНЕНО
Вибачте, сьогодні ми не працюємо.
Побачимося завтра!
Дякуємо!', 'Текст «Табличка на дверях кафе». Правильна відповідь: «Вибачте».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('7c617b2a-3d9f-5b64-9a1b-7f129e2460d1', v_aid, 13, 'A0', 'reading', 'understand', 'multiple_choice', 'Про що просять мешканців?', 'Natpis na ulazu u zgradu', '["Зачиняти двері", "Не шуміти", "Платити за ліфт"]'::jsonb, 0, null, '{}'::text[], null, 'ULAZ B
Stanovi 1 – 12
Lift ne radi. Oprostite!
Molimo, zatvorite vrata.', 'ВХІД B
Квартири 1–12
Ліфт не працює. Вибачте!
Будь ласка, зачиняйте двері.', 'Текст «Табличка біля входу в будинок». Правильна відповідь: «Зачиняти двері».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('8ba47b72-1d68-5066-901e-fa9752de93b1', v_aid, 14, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Imaju li djecu?', '["Nažalost, ulaz psima je zabranjen. Samo pas vodič smije ući.", "Imaju sina, mog bratića Oleha. I on radi ovdje.", "Točno! Bravo."]'::jsonb, 1, null, '{}'::text[], 'Imaju li djecu?', null, null, 'Діалог «Родичі в Хорватії»: «Imaju li djecu?» (У них є діти?) — «Imaju sina, mog bratića Oleha. I on radi ovdje.» (У них є син, мій двоюрідний брат Олег. Він теж тут працює.).', (select id from public.lessons where id = 'cec08ff0-a97d-5847-88cc-dee22fed2f8c'), 'PUBLISHED', 'claude_assessment_v5'),
  ('ec7d422f-cf3a-5ab5-b5cb-85d93f1a9370', v_aid, 15, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Koliko je kilometara od Zagreba do Splita?', '["Prije dva mjeseca. Imam i veterinarsku potvrdu.", "Otprilike četiristo.", "Malo. Ali najviše me bole stopala."]'::jsonb, 1, null, '{}'::text[], 'Koliko je kilometara od Zagreba do Splita?', null, null, 'Діалог «Скільки кілометрів?»: «Koliko je kilometara od Zagreba do Splita?» (Скільки кілометрів від Загреба до Спліта?) — «Otprilike četiristo.» (Приблизно чотириста.).', (select id from public.lessons where id = 'c0d7b467-acb2-581a-975b-497e63f45aa7'), 'PUBLISHED', 'claude_assessment_v5'),
  ('829d7a54-d977-5f7c-a0b1-dafa16f6632f', v_aid, 16, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Dobar dan, je li to dežurni veterinar?', '["Puno je bolji od starog! Velik je i svijetao.", "Do hotela Park, ali mobitel mi se ugasio.", "Da, izvolite."]'::jsonb, 2, null, '{}'::text[], 'Dobar dan, je li to dežurni veterinar?', null, null, 'Діалог «Кліщ»: «Dobar dan, je li to dežurni veterinar?» (Добрий день, це черговий ветеринар?) — «Da, izvolite.» (Так, слухаю.).', (select id from public.lessons where id = 'fa7fd153-275f-5214-b759-2db31e50a4b4'), 'PUBLISHED', 'claude_assessment_v5'),
  ('3b8fcabc-77a1-570d-aa09-dde8c2575396', v_aid, 17, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Dašo, imaš li plan za vikend?', '["Tvrd je, ali je unutra prostran.", "U subotu radim, ali u nedjelju sam slobodna.", "Hvala, rado."]'::jsonb, 1, null, '{}'::text[], 'Dašo, imaš li plan za vikend?', null, null, 'Діалог «Плани на вихідні»: «Dašo, imaš li plan za vikend?» (Дашо, у тебе є план на вихідні?) — «U subotu radim, ali u nedjelju sam slobodna.» (У суботу я працюю, але в неділю вільна.).', (select id from public.lessons where id = '8e372ece-ae10-50ae-9cf3-07b52ef2f72d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('6b7a33ea-44c9-571b-9b59-38042d47f979', v_aid, 18, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Imate li sve dokumente i uplatnicu za pristojbu?', '["Evo putovnice, ugovora o radu i uplatnice.", "Na prvom katu, lijevo od lifta.", "Dolazi mi svekrva iz Ukrajine, mama mog muža."]'::jsonb, 0, null, '{}'::text[], 'Imate li sve dokumente i uplatnicu za pristojbu?', null, null, 'Діалог «Біля віконця»: «Imate li sve dokumente i uplatnicu za pristojbu?» (У вас є всі документи й квитанція про сплату збору?) — «Evo putovnice, ugovora o radu i uplatnice.» (Ось паспорт, трудовий договір і квитанція.).', (select id from public.lessons where id = '19df3241-90f3-5450-94ac-642d79fb2869'), 'PUBLISHED', 'claude_assessment_v5'),
  ('2f45a865-a55d-5b6a-889f-81419c9d55b3', v_aid, 19, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Darja, voziš li ovdje auto?', '["Dogodila se prometna nesreća! Jedan čovjek je ozlijeđen.", "Piše na kartici pored kreveta.", "Još ne. Moram zamijeniti vozačku dozvolu."]'::jsonb, 2, null, '{}'::text[], 'Darja, voziš li ovdje auto?', null, null, 'Діалог «Автом чи велосипедом?»: «Darja, voziš li ovdje auto?» (Дар’є, ти тут водиш машину?) — «Još ne. Moram zamijeniti vozačku dozvolu.» (Ще ні. Мені треба обміняти водійське посвідчення.).', (select id from public.lessons where id = 'e0b9d742-0418-597b-9482-b6e2d82469da'), 'PUBLISHED', 'claude_assessment_v5'),
  ('14337cc9-d26b-5212-8b27-b09734577b09', v_aid, 20, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Oprostite, možete li ponoviti zadnje brojeve?', '["Sedamdeset dva, devedeset jedan.", "Ženski. A ovdje mjesto rođenja i bračno stanje.", "U spavaću sobu, uz zid, između prozora i vrata."]'::jsonb, 0, null, '{}'::text[], 'Oprostite, možete li ponoviti zadnje brojeve?', null, null, 'Діалог «Продиктуйте номер»: «Oprostite, možete li ponoviti zadnje brojeve?» (Вибачте, можете повторити останні цифри?) — «Sedamdeset dva, devedeset jedan.» (Сімдесят два, дев’яносто один.).', (select id from public.lessons where id = 'ffb92726-2fb1-5070-bf5c-5d2fb3b9393a'), 'PUBLISHED', 'claude_assessment_v5'),
  ('82ac3026-5e84-58b3-ac50-87969ab22170', v_aid, 21, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Dašo, je li to vaša nova maca?', '["Nije maca, to je mačak! Zove se Tigar.", "Brojimo zajedno: jedan, dva, tri…", "Ide, u vrtić pored škole. Odgojiteljice su jako drage."]'::jsonb, 0, null, '{}'::text[], 'Dašo, je li to vaša nova maca?', null, null, 'Діалог «Нова киця»: «Dašo, je li to vaša nova maca?» (Дашо, це ваша нова киця?) — «Nije maca, to je mačak! Zove se Tigar.» (Це не киця, це кіт! Його звати Тигр.).', (select id from public.lessons where id = '5c421c03-f070-538e-b152-8c50b31f4daf'), 'PUBLISHED', 'claude_assessment_v5'),
  ('00edffe5-575e-551a-9579-0c3052443c07', v_aid, 22, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Gdje je Ukrajina na karti?', '["Evo, ovdje. Na istoku Europe.", "Oko dvanaest eura. Vežite pojas, molim.", "Dosta je. Hvala ti!"]'::jsonb, 0, null, '{}'::text[], 'Gdje je Ukrajina na karti?', null, null, 'Діалог «Карта світу»: «Gdje je Ukrajina na karti?» (Де Україна на карті?) — «Evo, ovdje. Na istoku Europe.» (Ось тут. На сході Європи.).', (select id from public.lessons where id = '479784bc-54ab-522d-9c77-55887ae68e33'), 'PUBLISHED', 'claude_assessment_v5'),
  ('7d3a5d24-75bc-5bac-9212-2a3250c904dc', v_aid, 23, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Jesu li lignje svježe?', '["U četrnaest i trideset, s petog perona.", "Jesu, jutros su ulovljene.", "Mala je, ali lijepa. Ima krevet, ormar i radni stol."]'::jsonb, 1, null, '{}'::text[], 'Jesu li lignje svježe?', null, null, 'Діалог «Вечеря в коноби»: «Jesu li lignje svježe?» (Кальмари свіжі?) — «Jesu, jutros su ulovljene.» (Так, їх виловили сьогодні вранці.).', (select id from public.lessons where id = 'e6925fe5-e7fb-5594-9d3f-87fab1b5598d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('de90651e-a0e4-57c9-ab70-ae2e3bd8a620', v_aid, 24, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'To je previše. Može li jeftinije?', '["Prvo upišite osobne podatke, tiskanim slovima.", "Jako je strpljiva i pametna.", "Za vas dvadeset pet. To je zadnja cijena."]'::jsonb, 2, null, '{}'::text[], 'To je previše. Može li jeftinije?', null, null, 'Діалог «На блошиному ринку»: «To je previše. Može li jeftinije?» (Це забагато. Можна дешевше?) — «Za vas dvadeset pet. To je zadnja cijena.» (Для вас двадцять п’ять. Це остання ціна.).', (select id from public.lessons where id = '6836e57c-030c-59f8-9818-b44c08b126a6'), 'PUBLISHED', 'claude_assessment_v5'),
  ('d2fadaa7-0939-584c-ac0e-b7aff4ec5da9', v_aid, 25, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Dašo, idem u supermarket. Trebaš li nešto?', '["Ось: дві бляшанки квасолі, банка меду й пачка кави.", "Вистачить. Дякую тобі!", "Так, літр молока й хліб із пекарні."]'::jsonb, 2, null, '{}'::text[], null, 'Luka: Dašo, idem u supermarket. Trebaš li nešto?
Daša: Da, litru mlijeka i kruh iz pekare.
Luka: Napiši mi popis, molim te.
Daša: Evo: dvije limenke graha, staklenka meda i pakiranje kave.
Luka: Je li jedno pakiranje kave dosta?
Daša: Dosta je. Hvala ti!', 'Luka: Дашо, я йду в супермаркет. Тобі щось треба?
Daša: Так, літр молока й хліб із пекарні.
Luka: Напиши мені список, будь ласка.
Daša: Ось: дві бляшанки квасолі, банка меду й пачка кави.
Luka: Однієї пачки кави вистачить?
Daša: Вистачить. Дякую тобі!', 'Діалог «Список покупок»: «Dašo, idem u supermarket. Trebaš li nešto?» — «Da, litru mlijeka i kruh iz pekare.», тобто «Так, літр молока й хліб із пекарні.».', (select id from public.lessons where id = '0e925295-2766-5931-b031-2412682bc6f8'), 'PUBLISHED', 'claude_assessment_v5'),
  ('717f2057-2195-56bf-9659-4053c3888f7b', v_aid, 26, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Glavni kolodvor. Gdje vi izlazite?', '["На вокзалі. Квиток я купила в автоматі.", "Тоді виходьте зараз, ось зупинка!", "Так, сідайте."]'::jsonb, 0, null, '{}'::text[], null, 'Darja: Oprostite, je li ovo mjesto slobodno?
Gospođa: Jest, izvolite sjesti.
Darja: Hvala. Koja je sljedeća stanica?
Gospođa: Glavni kolodvor. Gdje vi izlazite?
Darja: Na kolodvoru. Kartu sam kupila na automatu.
Gospođa: Onda izađite sada, evo stanice!', 'Darja: Перепрошую, це місце вільне?
Gospođa: Так, сідайте.
Darja: Дякую. Яка наступна зупинка?
Gospođa: Головний вокзал. А ви де виходите?
Darja: На вокзалі. Квиток я купила в автоматі.
Gospođa: Тоді виходьте зараз, ось зупинка!', 'Діалог «Яка наступна зупинка?»: «Glavni kolodvor. Gdje vi izlazite?» — «Na kolodvoru. Kartu sam kupila na automatu.», тобто «На вокзалі. Квиток я купила в автоматі.».', (select id from public.lessons where id = 'e5b81eb1-8ea8-5ff4-a987-e5e46421302b'), 'PUBLISHED', 'claude_assessment_v5'),
  ('de27aefd-0947-5f9e-82a9-aa46b15cf557', v_aid, 27, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Bijelo, ali s mineralnom vodom. Kako se to zove?', '["Це гемішт. А червоне вино зі звичайною водою — беванда.", "Ось. Будьмо!", "Цікаво! Тоді один гемішт, будь ласка."]'::jsonb, 0, null, '{}'::text[], null, 'Ivana: Dašo, piješ li crno ili bijelo vino?
Daša: Bijelo, ali s mineralnom vodom. Kako se to zove?
Ivana: To je gemišt. Crno vino s običnom vodom je bevanda.
Daša: Zanimljivo! Onda jedan gemišt, molim.
Ivana: Evo. Živjeli!', 'Ivana: Дашо, ти п’єш червоне чи біле вино?
Daša: Біле, але з мінеральною водою. Як це називається?
Ivana: Це гемішт. А червоне вино зі звичайною водою — беванда.
Daša: Цікаво! Тоді один гемішт, будь ласка.
Ivana: Ось. Будьмо!', 'Діалог «Вино до вечері»: «Bijelo, ali s mineralnom vodom. Kako se to zove?» — «To je gemišt. Crno vino s običnom vodom je bevanda.», тобто «Це гемішт. А червоне вино зі звичайною водою — беванда.».', (select id from public.lessons where id = '77d640c4-4190-544a-8094-4e699f9a0a10'), 'PUBLISHED', 'claude_assessment_v5'),
  ('73b2cae3-ccfc-51b9-9ab1-0b453d85c52b', v_aid, 28, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Je li namješten?', '["Так, у розмірі місячної оплати. Можете подивитися її завтра.", "Так. Це двокімнатна квартира, шістдесят квадратних метрів, з балконом.", "Так, повністю. Оренда — п’ятсот євро, а комунальні окремо."]'::jsonb, 2, null, '{}'::text[], null, 'Daša: Dobar dan, zovem zbog oglasa. Je li stan još slobodan?
Stanodavac: Jest. To je dvosoban stan, šezdeset kvadrata, s balkonom.
Daša: Je li namješten?
Stanodavac: Jest, potpuno. Najamnina je petsto eura, a režije posebno.
Daša: Tražite li kauciju?
Stanodavac: Da, jednu najamninu. Možete ga pogledati sutra.', 'Daša: Добрий день, я телефоную щодо оголошення. Квартира ще вільна?
Stanodavac: Так. Це двокімнатна квартира, шістдесят квадратних метрів, з балконом.
Daša: Вона мебльована?
Stanodavac: Так, повністю. Оренда — п’ятсот євро, а комунальні окремо.
Daša: Ви берете заставу?
Stanodavac: Так, у розмірі місячної оплати. Можете подивитися її завтра.', 'Діалог «Оголошення»: «Je li namješten?» — «Jest, potpuno. Najamnina je petsto eura, a režije posebno.», тобто «Так, повністю. Оренда — п’ятсот євро, а комунальні окремо.».', (select id from public.lessons where id = '78f28f85-dd8b-5e81-8a52-1b2dbce4eb34'), 'PUBLISHED', 'claude_assessment_v5'),
  ('20ae50d6-72ec-587d-a514-315d15fdf74f', v_aid, 29, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Razumijem te. Želiš li na kavu?', '["Дякую, із задоволенням.", "Дашо, як ти почуваєшся? Ти сумна.", "Мені трохи самотньо. Я сумую за родиною."]'::jsonb, 0, null, '{}'::text[], null, 'Ivana: Dašo, kako se osjećaš? Izgledaš tužno.
Daša: Malo sam usamljena. Nedostaje mi obitelj.
Ivana: Razumijem te. Želiš li na kavu?
Daša: Hvala, rado.
Ivana: Idemo! Bit će ti bolje.', 'Ivana: Дашо, як ти почуваєшся? Ти сумна.
Daša: Мені трохи самотньо. Я сумую за родиною.
Ivana: Розумію тебе. Хочеш на каву?
Daša: Дякую, із задоволенням.
Ivana: Ходімо! Тобі стане краще.', 'Діалог «Поганий день»: «Razumijem te. Želiš li na kavu?» — «Hvala, rado.», тобто «Дякую, із задоволенням.».', (select id from public.lessons where id = '3b51b1bf-47f4-5709-96d9-c518d36440e6'), 'PUBLISHED', 'claude_assessment_v5'),
  ('c8bc6d50-b599-56d1-bbef-3e8219c7679f', v_aid, 30, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Imaš li temperaturu?', '["Здається, ні, але в мене ще й спина болить.", "Тоді негайно в ліжко! Випий чаю з медом.", "У мене болить голова, а ще горло."]'::jsonb, 0, null, '{}'::text[], null, 'Ana: Dašo, što ti je? Izgledaš umorno.
Daša: Boli me glava, a i grlo.
Ana: Imaš li temperaturu?
Daša: Mislim da nemam, ali bole me i leđa.
Ana: Onda odmah u krevet! Popij čaj s medom.', 'Ana: Дашо, що з тобою? Ти виглядаєш утомленою.
Daša: У мене болить голова, а ще горло.
Ana: У тебе є температура?
Daša: Здається, ні, але в мене ще й спина болить.
Ana: Тоді негайно в ліжко! Випий чаю з медом.', 'Діалог «Що в тебе болить?»: «Imaš li temperaturu?» — «Mislim da nemam, ali bole me i leđa.», тобто «Здається, ні, але в мене ще й спина болить.».', (select id from public.lessons where id = '599fba4f-4cee-5a88-9f9b-5ce32a445554'), 'PUBLISHED', 'claude_assessment_v5'),
  ('d7486914-e982-56d3-a3d4-20d72bdf463f', v_aid, 31, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Можна? (просимо дозволу)». Що ви скажете?', null, '["Hvala na pomoći!", "Smijem li?", "Puno hvala!"]'::jsonb, 1, null, '{}'::text[], null, null, null, '«Можна? (просимо дозволу)» — «Smijem li?».', (select id from public.lessons where id = 'e704760a-f743-5762-9c1a-027b10ca030a'), 'PUBLISHED', 'claude_assessment_v5'),
  ('a1708a3b-cb44-5112-937e-ab781033fd62', v_aid, 32, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Мій кіт сірий і смугастий». Що ви скажете?', null, '["Što mu je? Šepa.", "Smije li pas unutra?", "Moj mačak je siv i prugast."]'::jsonb, 2, null, '{}'::text[], null, null, null, '«Мій кіт сірий і смугастий.» — «Moj mačak je siv i prugast.».', (select id from public.lessons where id = '5c421c03-f070-538e-b152-8c50b31f4daf'), 'PUBLISHED', 'claude_assessment_v5'),
  ('175a7678-e8a8-5b9a-b765-5664b759febe', v_aid, 33, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Це мій найкращий друг». Що ви скажете?', null, '["Ovo je moj najbolji prijatelj.", "Ona ima plave oči.", "Čestitam!"]'::jsonb, 0, null, '{}'::text[], null, null, null, '«Це мій найкращий друг.» — «Ovo je moj najbolji prijatelj.».', (select id from public.lessons where id = '2b0e9742-99e1-57e1-a574-67ffb78d2607'), 'PUBLISHED', 'claude_assessment_v5'),
  ('ee6fbcfc-05df-5403-aed4-d87260bf7e88', v_aid, 34, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «О котрій починається екскурсія?». Що ви скажете?', null, '["Gdje trebam izaći?", "Koliko je daleko do centra?", "U koliko sati počinje obilazak?"]'::jsonb, 2, null, '{}'::text[], null, null, null, '«О котрій починається екскурсія?» — «U koliko sati počinje obilazak?».', (select id from public.lessons where id = '1e0384e5-6097-56ed-ab56-cf530f02ab73'), 'PUBLISHED', 'claude_assessment_v5'),
  ('0ec67ee9-919c-5e7f-affe-2160a4de9cd4', v_aid, 35, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «У мене болять ноги». Що ви скажете?', null, '["Boli me trbuh.", "Bole me noge.", "Imam rezervaciju."]'::jsonb, 1, null, '{}'::text[], null, null, null, '«У мене болять ноги.» — «Bole me noge.».', (select id from public.lessons where id = '599fba4f-4cee-5a88-9f9b-5ce32a445554'), 'PUBLISHED', 'claude_assessment_v5'),
  ('bc1d8026-22b3-5a49-a43d-4d56d254475b', v_aid, 36, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «хвилина»', null, '[]'::jsonb, null, 'minuta', '{}'::text[], null, null, null, '«хвилина» — minuta.', (select id from public.lessons where id = '39b1e31f-b573-5000-9713-1660688c3cc9'), 'PUBLISHED', 'claude_assessment_v5'),
  ('f0f6b61e-3ec5-5dfa-8eea-861b465f942b', v_aid, 37, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «теля»', null, '[]'::jsonb, null, 'tele', '{}'::text[], null, null, null, '«теля» — tele.', (select id from public.lessons where id = '5ffbe419-6abc-574e-907e-2dc427276abd'), 'PUBLISHED', 'claude_assessment_v5'),
  ('ad2451ff-67d1-59a8-b571-9da603cbe493', v_aid, 38, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «у горошок»', null, '[]'::jsonb, null, 'na točkice', '{}'::text[], null, null, null, '«у горошок» — na točkice.', (select id from public.lessons where id = '288e7610-99c8-5696-989a-86f60ce38b0a'), 'PUBLISHED', 'claude_assessment_v5'),
  ('5bac3f15-9754-522a-b577-90d344e09e2c', v_aid, 39, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «лікарня»', null, '[]'::jsonb, null, 'bolnica', '{}'::text[], null, null, null, '«лікарня» — bolnica.', (select id from public.lessons where id = '0addd5be-230b-582f-baed-a5d18eb1d619'), 'PUBLISHED', 'claude_assessment_v5'),
  ('1ed60f2a-3410-5e91-9971-d3d43ac58ffa', v_aid, 40, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «подруга»', null, '[]'::jsonb, null, 'prijateljica', '{}'::text[], null, null, null, '«подруга» — prijateljica.', (select id from public.lessons where id = '2b0e9742-99e1-57e1-a574-67ffb78d2607'), 'PUBLISHED', 'claude_assessment_v5'),
  ('4b9a7b64-4df6-51d2-9a38-cdc0d1aa6e41', v_aid, 41, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Ключі на столі.»', null, '["Ključevi", "na", "stolu.", "su"]'::jsonb, null, 'Ključevi su na stolu.', array['Na stolu su ključevi.']::text[], null, null, null, '«Ключі на столі.» — «Ključevi su na stolu.».', (select id from public.lessons where id = '32f5d97b-d6c0-57af-9e48-86f9ee9a932d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('888f961e-992b-5494-8c62-5ddca348bdc3', v_aid, 42, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Що є на сніданок?»', null, '["Što", "doručak?", "ima", "za"]'::jsonb, null, 'Što ima za doručak?', '{}'::text[], null, null, null, '«Що є на сніданок?» — «Što ima za doručak?».', (select id from public.lessons where id = '7bbaf7ff-10bb-512a-91c5-798b59ec92a5'), 'PUBLISHED', 'claude_assessment_v5'),
  ('125a66b9-d252-50d8-b9c0-73fb177df0c1', v_aid, 43, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Мені потрібні овочі на суп.»', null, '["povrće", "juhu.", "Trebam", "za"]'::jsonb, null, 'Trebam povrće za juhu.', '{}'::text[], null, null, null, '«Мені потрібні овочі на суп.» — «Trebam povrće za juhu.».', (select id from public.lessons where id = 'e495a4dd-a963-5a5f-af8c-09b2ea6a2ea0'), 'PUBLISHED', 'claude_assessment_v5'),
  ('6f57071c-f7e4-5bea-8a2d-8dbd0690fd08', v_aid, 44, 'A0', 'writing', 'produce', 'sentence_builder', 'Де чергова аптека?', null, '["Gdje", "dežurna", "ljekarna?", "je"]'::jsonb, null, 'Gdje je dežurna ljekarna?', '{}'::text[], null, null, null, '«Де чергова аптека?» — «Gdje je dežurna ljekarna?».', (select id from public.lessons where id = 'a4455f67-27c7-5ad7-a454-771a94ca4e02'), 'PUBLISHED', 'claude_assessment_v5'),
  ('c683ec59-5bc4-5996-9eef-b49b562cdb17', v_aid, 45, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Хорватія — у Європі.»', null, '["u", "Europi.", "je", "Hrvatska"]'::jsonb, null, 'Hrvatska je u Europi.', '{}'::text[], null, null, null, '«Хорватія — у Європі.» — «Hrvatska je u Europi.».', (select id from public.lessons where id = '479784bc-54ab-522d-9c77-55887ae68e33'), 'PUBLISHED', 'claude_assessment_v5'),
  ('bd805a40-c46b-5e0b-8a71-9fbd153e269d', v_aid, 46, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Холодно.»', null, '[]'::jsonb, null, 'Hladno je.', '{}'::text[], null, null, null, '«Холодно.» — «Hladno je.».', (select id from public.lessons where id = 'efcf49e0-c058-5986-9cf7-aee921887a81'), 'PUBLISHED', 'claude_assessment_v5'),
  ('6a3dd72a-78e2-5ab6-a03f-200a06f41f29', v_aid, 47, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Нас чотирнадцять.»', null, '[]'::jsonb, null, 'Nas je četrnaest.', '{}'::text[], null, null, null, '«Нас чотирнадцять.» — «Nas je četrnaest.».', (select id from public.lessons where id = 'e30c65f2-1a30-5b51-85e7-6a460cd1799f'), 'PUBLISHED', 'claude_assessment_v5'),
  ('7a81d07e-6c1e-5528-b45c-246460ed02a0', v_aid, 48, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Я трохи розмовляю хорватською.»', null, '[]'::jsonb, null, 'Govorim malo hrvatski.', '{}'::text[], null, null, null, '«Я трохи розмовляю хорватською.» — «Govorim malo hrvatski.».', (select id from public.lessons where id = 'a9944193-2dfb-5944-b94c-41c41fdb7ca1'), 'PUBLISHED', 'claude_assessment_v5');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірки рівня A0 за схемою 2026-11-07 після плану «Дублі й сенс уроків» (PR 2б, рішення власника 2026-11-17): фінал A0 наново з усіх 11 модулів (з A0.6 «Kućni ljubimci»). Завдання — з діалогів, вправ і текстів уроків. Потрібна перевірка носієм.');
end $$;

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_new int; v_bad int;
begin
  select count(*) into v_new from public.assessment_items where id in ('b9fbf069-538f-5f2b-849a-ae914b27d69e', '021a2544-a257-51a1-a88b-ba498172058a', 'f9c5fb51-8629-539b-a1c8-9abcd8882019', '05b50b1f-1be0-5c5f-b05c-eb2e4606fc9b', '917540e9-a6fc-5904-b099-b8576c6f95ac', 'bc0a9701-38fb-5401-bdfe-bc39e09599b0', '0a7033ff-1104-514e-a819-1826cd7fb376', '73a06ea5-bf85-5204-9a3d-0ca31075691a', '6362f3a8-1c48-520d-b8c2-869914f7173c', '6ee47b36-aabe-54a8-b131-450313914534', 'f12411bc-25ea-5b46-ae59-3f80a0e6ee9c', '73b24486-727d-5051-8248-77184ce0f194', 'd41bdf9c-2cd7-5b44-abda-354bf54c7b4d', '6e242b34-19f9-5954-b8cf-e9331b65dcbe', 'e80a4ea1-119a-518a-8e01-b13d11dd1058', '57625b09-d2bf-5836-9c9b-bb6431093967', '8536e911-8258-5e3d-9d1e-5af239f53add', '235e75c8-5e22-540d-94bb-022cf8bd4719', '5462a8a5-f45e-5dc6-917c-a121d32c40e1', '4868f8fa-4e90-5e9b-888f-83fef4cfc2ff', '24ced317-11a3-52bc-a176-553b22ab4df8', '5d0e445f-056f-5a3d-bf69-d491bfc2b27e', '90715668-ddd7-5074-8651-d2bb7c1f1b8c', '2f0c907c-2cef-5d0a-aa69-ef4c8585ec05', '08ed520e-2f80-58f5-95b3-ff1f0811f062', 'a8843ba6-bc48-5790-b4a9-7c761d1b6666', '4092bf11-90a9-5328-9a95-481b0392d48e', 'e9464b04-f0e6-5b83-b37e-b47daa34d47f', 'd2b63def-450b-5644-aa65-56aa9b655417', '6259c5bd-d0f1-5d9c-8951-b8c365150281', 'ea74d666-d94b-5538-b83c-0e669e0fa6c5', '00487434-b348-552d-8d00-054a17935927', 'fae5c96c-5d4c-51a1-b6c6-b297bd62455b', 'c38544e7-620a-5845-8f4e-fab9f0113f7e', 'afc400ba-065d-5cd1-adf8-6d02b18b48d1', '2991c66b-2663-5f81-bc5c-e6a78de22145', '7f1f8345-5d2e-5a4c-a6e3-ee74ce3b2d0c', '1ab1da14-2f37-5561-8f8f-fbf8477a796c', 'b8defc06-08cc-564e-ab91-b144bcf77110', '6fda44b2-2e46-5868-81ab-a7920f3946eb', '7c617b2a-3d9f-5b64-9a1b-7f129e2460d1', '8ba47b72-1d68-5066-901e-fa9752de93b1', 'ec7d422f-cf3a-5ab5-b5cb-85d93f1a9370', '829d7a54-d977-5f7c-a0b1-dafa16f6632f', '3b8fcabc-77a1-570d-aa09-dde8c2575396', '6b7a33ea-44c9-571b-9b59-38042d47f979', '2f45a865-a55d-5b6a-889f-81419c9d55b3', '14337cc9-d26b-5212-8b27-b09734577b09', '82ac3026-5e84-58b3-ac50-87969ab22170', '00edffe5-575e-551a-9579-0c3052443c07', '7d3a5d24-75bc-5bac-9212-2a3250c904dc', 'de90651e-a0e4-57c9-ab70-ae2e3bd8a620', 'd2fadaa7-0939-584c-ac0e-b7aff4ec5da9', '717f2057-2195-56bf-9659-4053c3888f7b', 'de27aefd-0947-5f9e-82a9-aa46b15cf557', '73b2cae3-ccfc-51b9-9ab1-0b453d85c52b', '20ae50d6-72ec-587d-a514-315d15fdf74f', 'c8bc6d50-b599-56d1-bbef-3e8219c7679f', 'd7486914-e982-56d3-a3d4-20d72bdf463f', 'a1708a3b-cb44-5112-937e-ab781033fd62', '175a7678-e8a8-5b9a-b765-5664b759febe', 'ee6fbcfc-05df-5403-aed4-d87260bf7e88', '0ec67ee9-919c-5e7f-affe-2160a4de9cd4', 'bc1d8026-22b3-5a49-a43d-4d56d254475b', 'f0f6b61e-3ec5-5dfa-8eea-861b465f942b', 'ad2451ff-67d1-59a8-b571-9da603cbe493', '5bac3f15-9754-522a-b577-90d344e09e2c', '1ed60f2a-3410-5e91-9971-d3d43ac58ffa', '4b9a7b64-4df6-51d2-9a38-cdc0d1aa6e41', '888f961e-992b-5494-8c62-5ddca348bdc3', '125a66b9-d252-50d8-b9c0-73fb177df0c1', '6f57071c-f7e4-5bea-8a2d-8dbd0690fd08', 'c683ec59-5bc4-5996-9eef-b49b562cdb17', 'bd805a40-c46b-5e0b-8a71-9fbd153e269d', '6a3dd72a-78e2-5ab6-a03f-200a06f41f29', '7a81d07e-6c1e-5528-b45c-246460ed02a0') and status = 'PUBLISHED';
  select count(*) into v_bad from (values ('a0-m09', 12), ('a0-m11', 16), ('a0-final', 48)) e(slug, n) left join public.assessments a on a.slug = e.slug and a.cefr = 'A0' and a.status = 'PUBLISHED'
   where a.id is null
      or (select count(*) from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED') <> e.n
      or exists (select 1 from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED' and i.id not in ('b9fbf069-538f-5f2b-849a-ae914b27d69e', '021a2544-a257-51a1-a88b-ba498172058a', 'f9c5fb51-8629-539b-a1c8-9abcd8882019', '05b50b1f-1be0-5c5f-b05c-eb2e4606fc9b', '917540e9-a6fc-5904-b099-b8576c6f95ac', 'bc0a9701-38fb-5401-bdfe-bc39e09599b0', '0a7033ff-1104-514e-a819-1826cd7fb376', '73a06ea5-bf85-5204-9a3d-0ca31075691a', '6362f3a8-1c48-520d-b8c2-869914f7173c', '6ee47b36-aabe-54a8-b131-450313914534', 'f12411bc-25ea-5b46-ae59-3f80a0e6ee9c', '73b24486-727d-5051-8248-77184ce0f194', 'd41bdf9c-2cd7-5b44-abda-354bf54c7b4d', '6e242b34-19f9-5954-b8cf-e9331b65dcbe', 'e80a4ea1-119a-518a-8e01-b13d11dd1058', '57625b09-d2bf-5836-9c9b-bb6431093967', '8536e911-8258-5e3d-9d1e-5af239f53add', '235e75c8-5e22-540d-94bb-022cf8bd4719', '5462a8a5-f45e-5dc6-917c-a121d32c40e1', '4868f8fa-4e90-5e9b-888f-83fef4cfc2ff', '24ced317-11a3-52bc-a176-553b22ab4df8', '5d0e445f-056f-5a3d-bf69-d491bfc2b27e', '90715668-ddd7-5074-8651-d2bb7c1f1b8c', '2f0c907c-2cef-5d0a-aa69-ef4c8585ec05', '08ed520e-2f80-58f5-95b3-ff1f0811f062', 'a8843ba6-bc48-5790-b4a9-7c761d1b6666', '4092bf11-90a9-5328-9a95-481b0392d48e', 'e9464b04-f0e6-5b83-b37e-b47daa34d47f', 'd2b63def-450b-5644-aa65-56aa9b655417', '6259c5bd-d0f1-5d9c-8951-b8c365150281', 'ea74d666-d94b-5538-b83c-0e669e0fa6c5', '00487434-b348-552d-8d00-054a17935927', 'fae5c96c-5d4c-51a1-b6c6-b297bd62455b', 'c38544e7-620a-5845-8f4e-fab9f0113f7e', 'afc400ba-065d-5cd1-adf8-6d02b18b48d1', '2991c66b-2663-5f81-bc5c-e6a78de22145', '7f1f8345-5d2e-5a4c-a6e3-ee74ce3b2d0c', '1ab1da14-2f37-5561-8f8f-fbf8477a796c', 'b8defc06-08cc-564e-ab91-b144bcf77110', '6fda44b2-2e46-5868-81ab-a7920f3946eb', '7c617b2a-3d9f-5b64-9a1b-7f129e2460d1', '8ba47b72-1d68-5066-901e-fa9752de93b1', 'ec7d422f-cf3a-5ab5-b5cb-85d93f1a9370', '829d7a54-d977-5f7c-a0b1-dafa16f6632f', '3b8fcabc-77a1-570d-aa09-dde8c2575396', '6b7a33ea-44c9-571b-9b59-38042d47f979', '2f45a865-a55d-5b6a-889f-81419c9d55b3', '14337cc9-d26b-5212-8b27-b09734577b09', '82ac3026-5e84-58b3-ac50-87969ab22170', '00edffe5-575e-551a-9579-0c3052443c07', '7d3a5d24-75bc-5bac-9212-2a3250c904dc', 'de90651e-a0e4-57c9-ab70-ae2e3bd8a620', 'd2fadaa7-0939-584c-ac0e-b7aff4ec5da9', '717f2057-2195-56bf-9659-4053c3888f7b', 'de27aefd-0947-5f9e-82a9-aa46b15cf557', '73b2cae3-ccfc-51b9-9ab1-0b453d85c52b', '20ae50d6-72ec-587d-a514-315d15fdf74f', 'c8bc6d50-b599-56d1-bbef-3e8219c7679f', 'd7486914-e982-56d3-a3d4-20d72bdf463f', 'a1708a3b-cb44-5112-937e-ab781033fd62', '175a7678-e8a8-5b9a-b765-5664b759febe', 'ee6fbcfc-05df-5403-aed4-d87260bf7e88', '0ec67ee9-919c-5e7f-affe-2160a4de9cd4', 'bc1d8026-22b3-5a49-a43d-4d56d254475b', 'f0f6b61e-3ec5-5dfa-8eea-861b465f942b', 'ad2451ff-67d1-59a8-b571-9da603cbe493', '5bac3f15-9754-522a-b577-90d344e09e2c', '1ed60f2a-3410-5e91-9971-d3d43ac58ffa', '4b9a7b64-4df6-51d2-9a38-cdc0d1aa6e41', '888f961e-992b-5494-8c62-5ddca348bdc3', '125a66b9-d252-50d8-b9c0-73fb177df0c1', '6f57071c-f7e4-5bea-8a2d-8dbd0690fd08', 'c683ec59-5bc4-5996-9eef-b49b562cdb17', 'bd805a40-c46b-5e0b-8a71-9fbd153e269d', '6a3dd72a-78e2-5ab6-a03f-200a06f41f29', '7a81d07e-6c1e-5528-b45c-246460ed02a0'));
  if v_new <> 76 or v_bad > 0 then raise exception 'Перевірки A0: нових завдань % (очікувалось 76), тестів з помилкою %', v_new, v_bad; end if;
  if (select count(distinct m.order_index) from public.assessment_items i join public.assessments a on a.id = i.assessment_id
        join public.lessons l on l.id = i.lesson_id join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
       where a.slug = 'a0-final' and a.cefr = 'A0' and i.status = 'PUBLISHED') <> 11 then
    raise exception 'a0-final: завдання не з усіх 11 модулів';
  end if;
  raise notice 'Готово: 20261117_a0_dupes_3_tests.sql — 3 тести, % нових завдань', v_new;
end $$;

commit;
