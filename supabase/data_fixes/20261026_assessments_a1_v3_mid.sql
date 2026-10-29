-- =====================================================================
-- Рівень A1 під програму A1 v3: a1-mid · 2026-10-26
-- Згенеровано: python3 -B scripts/gen_assessment_a1_v3.py level (не редагуйте вручну).
--
-- Тести: a1-mid (A1.1–A1.6, 20 завдань) — з нових діалогів і вправ; джерел і речень перевірок модулів тут немає.
--   Завдань за модулями: A1.1 — 2, A1.2 — 5, A1.3 — 4, A1.4 — 2, A1.5 — 2, A1.6 — 5.
--   * Стара версія завдань — у content_versions; старі завдання → DEPRECATED (не видаляються).
--   * Нові завдання — PUBLISHED (бета). Прогрес і результати користувачів не змінюються.
--   * Потрібні: 20261026_curriculum_a1_v3_structure.sql і SQL модулів A1.1–A1.6.
--   * Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

-- Перевірка середини рівня A1 · 20 завдань
do $$
declare v_aid uuid; v_payload jsonb;
begin
  select id into v_aid from public.assessments where slug = 'a1-mid';
  if v_aid is null then raise exception 'Немає тесту a1-mid'; end if;
  if exists (select 1 from public.assessment_items where id = '093fd0b7-dc77-5294-a893-ae5a1d447680') then return; end if;  -- уже оновлено
  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
          v_payload, 'curriculum_a1_v3: перевірку модуля оновлено під нові уроки — старі завдання');
  update public.assessments set description_ua = 'Середина рівня (модулі A1.1–A1.6): 20 завдань на 4 навички. ~10 хв.' where id = v_aid;
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + 100
   where assessment_id = v_aid and status = 'PUBLISHED' and order_index <= 100;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('093fd0b7-dc77-5294-a893-ae5a1d447680', v_aid, 1, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Вихід сім. Ось ваш посадковий талон.", "Квиток недійсний, місяць закінчився.", "Прошу. Ваш вагон — номер три."]'::jsonb, 2, null, 'Izvolite. Vaš vagon je broj tri.', null, null, 'Прозвучало: «Izvolite. Vaš vagon je broj tri.» — «Прошу. Ваш вагон — номер три.».', (select id from public.lessons where id = 'cae7a47d-7fb4-5b03-a8cc-5a0df2ccd92f'), 'PUBLISHED', 'claude_assessment_v1'),
  ('436c506e-a3ec-52e1-8d94-d1797f9c519c', v_aid, 2, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Де ти хочеш полицю — над ліжком?", "Куди викидаємо сміття?", "Можна сушити білизну на горищі?"]'::jsonb, 1, null, 'Gdje bacamo otpad?', null, null, 'Прозвучало: «Gdje bacamo otpad?» — «Куди викидаємо сміття?».', (select id from public.lessons where id = 'f296bc84-8059-5981-a5b9-9d4531627e18'), 'PUBLISHED', 'claude_assessment_v1'),
  ('00715c9c-012d-5fde-bb1f-a66f16702dbe', v_aid, 3, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Дашо, як минув перший день?", "Дашо, коли ти починаєш працювати?", "Як я можу подати заявку?"]'::jsonb, 2, null, 'Kako se mogu prijaviti?', null, null, 'Прозвучало: «Kako se mogu prijaviti?» — «Як я можу подати заявку?».', (select id from public.lessons where id = 'c9b87882-5e31-5485-aea7-0169216466a8'), 'PUBLISHED', 'claude_assessment_v1'),
  ('0604cf22-a4f0-55f9-84a5-4c0b583c1f13', v_aid, 4, 'A1', 'reading', 'understand', 'multiple_choice', 'Скільки років пані Марії?', 'Oksana na poslu', '["Дев’яносто", "Шістдесят", "Вісімдесят"]'::jsonb, 2, null, null, 'Oksana radi kao njegovateljica. Svako jutro dolazi kod gospođe Marije. Gospođa Marija ima osamdeset godina i živi sama. Oksana joj kuha ručak, ide s njom u šetnju i daje joj lijekove. Gospođa Marija joj priča o Zagrebu, a Oksana uči nove riječi. Posao nije lak, ali Oksana ga voli.', 'Оксана працює доглядальницею. Щоранку вона приходить до пані Марії. Пані Марії вісімдесят років, і вона живе сама. Оксана готує їй обід, ходить з нею на прогулянку й дає їй ліки. Пані Марія розповідає їй про Загреб, а Оксана вивчає нові слова. Робота не легка, але Оксана її любить.', 'Текст «Оксана на роботі». Правильна відповідь: «Вісімдесят».', null, 'PUBLISHED', 'claude_assessment_v1'),
  ('13c09720-78b2-5445-a94e-c22256072b12', v_aid, 5, 'A1', 'reading', 'understand', 'multiple_choice', 'Хто купує хліб?', 'Obiteljska grupa', '["Мама", "Тато", "Данило"]'::jsonb, 1, null, null, 'Mama: Tko danas kupuje kruh?
Danilo: Ja ne mogu, imam trening do sedam.
Tata: Ja kupujem kruh i mlijeko poslije posla.
Mama: Hvala! Večera je u osam. Danilo, ne zaboravi: danas ti pereš suđe!
Danilo: Dobro, mama 🙂', 'Мама: Хто сьогодні купує хліб?
Данило: Я не можу, у мене тренування до сьомої.
Тато: Я куплю хліб і молоко після роботи.
Мама: Дякую! Вечеря о восьмій. Данило, не забудь: сьогодні ти миєш посуд!
Данило: Добре, мамо 🙂', 'Текст «Сімейний чат». Правильна відповідь: «Тато».', null, 'PUBLISHED', 'claude_assessment_v1'),
  ('0f812efc-b6b7-5da1-af3f-33aa4d38efab', v_aid, 6, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Kakve su recenzije?', '["Ja sam danas na poslu do pet.", "Šetaj psa dvaput dnevno, ujutro i navečer.", "Odlične. Dodajem je u košaricu."]'::jsonb, 2, null, 'Kakve su recenzije?', null, null, 'Діалог «Замовляємо онлайн»: «Kakve su recenzije?» (А які відгуки?) — «Odlične. Dodajem je u košaricu.» (Чудові. Додаю її в кошик.).', (select id from public.lessons where id = '91d4c9b3-c9a8-5e94-8691-6683835c375b'), 'PUBLISHED', 'claude_assessment_v1'),
  ('327a60a9-ea0d-5edf-80c7-10c73fe151ae', v_aid, 7, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Mi u petak naručujemo dostavu hrane. Hoćeš li i ti?', '["Hoću! Ali bez graška, molim.", "Od bruto plaće se plaćaju porez i doprinosi.", "Za vrijeme probnog rada samo tjedan dana."]'::jsonb, 0, null, 'Mi u petak naručujemo dostavu hrane. Hoćeš li i ti?', null, null, 'Діалог «Обід із собою»: «Mi u petak naručujemo dostavu hrane. Hoćeš li i ti?» (Ми в п’ятницю замовляємо доставку їжі. Будеш і ти?) — «Hoću! Ali bez graška, molim.» (Буду! Але без горошку, будь ласка.).', (select id from public.lessons where id = '2c192d05-f259-53b6-a6ec-55ebfb25ec01'), 'PUBLISHED', 'claude_assessment_v1'),
  ('f799d55b-9c1e-53c7-823b-551931519749', v_aid, 8, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Kada se vraćaš s posla?', '["Super! Upoznala sam cijeli tim.", "Do kraja mjeseca. Selidbena tvrtka dolazi u subotu.", "Svake večeri se vraćam oko šest."]'::jsonb, 2, null, 'Kada se vraćaš s posla?', null, null, 'Діалог «Увечері»: «Kada se vraćaš s posla?» (Коли ти повертаєшся з роботи?) — «Svake večeri se vraćam oko šest.» (Щовечора повертаюся близько шостої.).', (select id from public.lessons where id = '4bf48151-be83-5108-bc92-645c0603a1a3'), 'PUBLISHED', 'claude_assessment_v1'),
  ('d2f9aa7b-30b8-515d-ba81-78f423aa9aba', v_aid, 9, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Trideset eura. Kada ste kod kuće?', '["Pošaljite životopis i kratko motivacijsko pismo.", "Za pola sata. Pratim pošiljku u aplikaciji.", "Treba. Uzmi metlu i krpu, hvala što mi pomažeš!"]'::jsonb, 1, null, 'Trideset eura. Kada ste kod kuće?', null, null, 'Діалог «Дзвонить кур’єр»: «Trideset eura. Kada ste kod kuće?» (Тридцять євро. Коли ви будете вдома?) — «Za pola sata. Pratim pošiljku u aplikaciji.» (За пів години. Я відстежую посилку в застосунку.).', (select id from public.lessons where id = '91d4c9b3-c9a8-5e94-8691-6683835c375b'), 'PUBLISHED', 'claude_assessment_v1'),
  ('60e98725-d58a-5d43-9d6d-3c8807c181d8', v_aid, 10, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Dašo, kako ti kuhaš pileću juhu?', '["Još ne, upravo se oblačim.", "Stavim piletinu u veliki lonac i zakuham vodu.", "Samo vani. U zgradi vrijedi zabrana pušenja."]'::jsonb, 1, null, 'Dašo, kako ti kuhaš pileću juhu?', null, null, 'Діалог «Курячий суп»: «Dašo, kako ti kuhaš pileću juhu?» (Дашо, як ти вариш курячий суп?) — «Stavim piletinu u veliki lonac i zakuham vodu.» (Кладу курку у велику каструлю й закип’ячую воду.).', (select id from public.lessons where id = '17fcd38a-e295-5849-9ba3-1ef240c6be78'), 'PUBLISHED', 'claude_assessment_v1'),
  ('75f412a7-335b-584d-b554-61b96a9eb973', v_aid, 11, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Bako, kako se radi tvoj kolač s jabukama?', '["Розігрій духовку до ста вісімдесяти й печи сорок хвилин.", "Спочатку почисть яблука й поріж їх.", "Змішай борошно, яйця, цукор і трохи олії."]'::jsonb, 1, null, null, 'Daša: Bako, kako se radi tvoj kolač s jabukama?
Baka: Prvo oguli jabuke i nasjeckaj ih.
Daša: A tijesto?
Baka: Izmiješaj brašno, jaja, šećer i malo ulja.
Daša: Koliko ga dugo pečeš?
Baka: Zagrij pećnicu na sto osamdeset i peci ga četrdeset minuta.', 'Daša: Бабусю, як робиться твій пиріг з яблуками?
Baka: Спочатку почисть яблука й поріж їх.
Daša: А тісто?
Baka: Змішай борошно, яйця, цукор і трохи олії.
Daša: Скільки часу ти його печеш?
Baka: Розігрій духовку до ста вісімдесяти й печи сорок хвилин.', 'Діалог «Бабусин рецепт»: «Bako, kako se radi tvoj kolač s jabukama?» — «Prvo oguli jabuke i nasjeckaj ih.», тобто «Спочатку почисть яблука й поріж їх.».', (select id from public.lessons where id = '3e652232-866b-5edf-ac05-d61ee7a325fe'), 'PUBLISHED', 'claude_assessment_v1'),
  ('0da2557a-a45b-5661-9d4c-275b30e8a81b', v_aid, 12, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Je li ulica prometna?', '["Навпроти будинку спортивний центр із басейном.", "Ні, тиха й безпечна, і багато зелені.", "Чудовий! Поруч магазин, кіоск і пекарня."]'::jsonb, 1, null, null, 'Ivana: Dašo, kako ti je novi kvart?
Daša: Odličan! U blizini su dućan, kiosk i pekara.
Ivana: A za djecu?
Daša: Nasuprot zgrade je sportski centar s bazenom.
Ivana: Je li ulica prometna?
Daša: Nije, mirna je i sigurna, i ima puno zelenila.', 'Ivana: Дашо, як тобі новий район?
Daša: Чудовий! Поруч магазин, кіоск і пекарня.
Ivana: А для дітей?
Daša: Навпроти будинку спортивний центр із басейном.
Ivana: Вулиця жвава?
Daša: Ні, тиха й безпечна, і багато зелені.', 'Діалог «Що в тебе поруч?»: «Je li ulica prometna?» — «Nije, mirna je i sigurna, i ima puno zelenila.», тобто «Ні, тиха й безпечна, і багато зелені.».', (select id from public.lessons where id = '3ea9520d-2baa-56b2-aa85-402e3e3ecb9b'), 'PUBLISHED', 'claude_assessment_v1'),
  ('651b0d9b-0294-5a2b-9ee3-ffb67043c97d', v_aid, 13, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Ivana, sviđa li ti se ova haljina?', '["Колір мені подобається, але візерунок трохи старомодний.", "Знаю, ти обожнюєш джинси й кросівки.", "А мені подобається. Вона елегантна й недорога."]'::jsonb, 0, null, null, 'Daša: Ivana, sviđa li ti se ova haljina?
Ivana: Boja mi se sviđa, ali uzorak je malo staromodan.
Daša: Meni se sviđa. Elegantna je, a nije skupa.
Ivana: Istina, ali ja više volim ležeran stil.
Daša: Znam, ti obožavaš traperice i tenisice.
Ivana: Tako je. Ako ti se svidi, uzmi je!', 'Daša: Івано, тобі подобається ця сукня?
Ivana: Колір мені подобається, але візерунок трохи старомодний.
Daša: А мені подобається. Вона елегантна й недорога.
Ivana: Правда, але я більше люблю невимушений стиль.
Daša: Знаю, ти обожнюєш джинси й кросівки.
Ivana: Саме так. Якщо тобі сподобається — бери!', 'Діалог «Тобі подобається?»: «Ivana, sviđa li ti se ova haljina?» — «Boja mi se sviđa, ali uzorak je malo staromodan.», тобто «Колір мені подобається, але візерунок трохи старомодний.».', (select id from public.lessons where id = '9a979d32-2f4b-5127-bc22-7292763c7de4'), 'PUBLISHED', 'claude_assessment_v1'),
  ('df844400-2d17-5d29-bc9e-b0a37d37673c', v_aid, 14, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Додайте трохи солі». Що ви скажете?', null, '["Dva kruha, molim.", "Dodaj mi pekmez, molim te.", "Dodajte malo soli."]'::jsonb, 2, null, null, null, null, '«Додайте трохи солі.» — «Dodajte malo soli.».', (select id from public.lessons where id = '3e652232-866b-5edf-ac05-d61ee7a325fe'), 'PUBLISHED', 'claude_assessment_v1'),
  ('f3baf67b-0f06-534a-a82d-32855b2a9c68', v_aid, 15, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Як минув перший день?». Що ви скажете?', null, '["Kako je bio prvi dan?", "Mogu li ostaviti poruku?", "Je li posao na nepuno radno vrijeme?"]'::jsonb, 0, null, null, null, null, '«Як минув перший день?» — «Kako je bio prvi dan?».', (select id from public.lessons where id = '2c56a486-dbbb-5102-b7cb-754c59cf94c3'), 'PUBLISHED', 'claude_assessment_v1'),
  ('dfbddf31-ad4b-5a00-adaf-8062c9fb28a8', v_aid, 16, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «у паніровці»', null, '[]'::jsonb, null, 'pohan', null, null, null, '«у паніровці» — pohan.', (select id from public.lessons where id = '2c192d05-f259-53b6-a6ec-55ebfb25ec01'), 'PUBLISHED', 'claude_assessment_v1'),
  ('dfeea71b-9af4-55b7-8f9e-2f8f031ab4af', v_aid, 17, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «умова»', null, '[]'::jsonb, null, 'uvjet', null, null, null, '«умова» — uvjet.', (select id from public.lessons where id = 'c9b87882-5e31-5485-aea7-0169216466a8'), 'PUBLISHED', 'claude_assessment_v1'),
  ('79f74894-1cce-5483-aa33-b94623ca5abf', v_aid, 18, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Поставте зимові шини.»', null, '["zimske", "Stavite", "gume."]'::jsonb, null, 'Stavite zimske gume.', null, null, null, '«Поставте зимові шини.» — «Stavite zimske gume.».', (select id from public.lessons where id = 'cd5db261-a421-511d-8100-f86bf2335bbe'), 'PUBLISHED', 'claude_assessment_v1'),
  ('c45d6455-4c6f-5bd6-8a5f-dba07c0b2a2b', v_aid, 19, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «На светрі є пляма.»', null, '["džemperu", "je", "mrlja.", "Na"]'::jsonb, null, 'Na džemperu je mrlja.', null, null, null, '«На светрі є пляма.» — «Na džemperu je mrlja.».', (select id from public.lessons where id = '6a7b0f42-510b-521e-9cc0-f77b2659d838'), 'PUBLISHED', 'claude_assessment_v1'),
  ('e55f36a2-63d4-54c1-a20e-9b5c17036f78', v_aid, 20, 'A1', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Договір строковий?»', null, '[]'::jsonb, null, 'Je li ugovor na određeno?', null, null, null, '«Договір строковий?» — «Je li ugovor na određeno?».', (select id from public.lessons where id = '4d6f3498-2cc5-54a0-b4e4-c66add71ef12'), 'PUBLISHED', 'claude_assessment_v1');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірку модуля оновлено під програму A1 v3 — завдання з нових діалогів і вправ. Потрібна перевірка носієм.');
end $$;

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_new int; v_bad int;
begin
  select count(*) into v_new from public.assessment_items where id in ('093fd0b7-dc77-5294-a893-ae5a1d447680', '436c506e-a3ec-52e1-8d94-d1797f9c519c', '00715c9c-012d-5fde-bb1f-a66f16702dbe', '0604cf22-a4f0-55f9-84a5-4c0b583c1f13', '13c09720-78b2-5445-a94e-c22256072b12', '0f812efc-b6b7-5da1-af3f-33aa4d38efab', '327a60a9-ea0d-5edf-80c7-10c73fe151ae', 'f799d55b-9c1e-53c7-823b-551931519749', 'd2f9aa7b-30b8-515d-ba81-78f423aa9aba', '60e98725-d58a-5d43-9d6d-3c8807c181d8', '75f412a7-335b-584d-b554-61b96a9eb973', '0da2557a-a45b-5661-9d4c-275b30e8a81b', '651b0d9b-0294-5a2b-9ee3-ffb67043c97d', 'df844400-2d17-5d29-bc9e-b0a37d37673c', 'f3baf67b-0f06-534a-a82d-32855b2a9c68', 'dfbddf31-ad4b-5a00-adaf-8062c9fb28a8', 'dfeea71b-9af4-55b7-8f9e-2f8f031ab4af', '79f74894-1cce-5483-aa33-b94623ca5abf', 'c45d6455-4c6f-5bd6-8a5f-dba07c0b2a2b', 'e55f36a2-63d4-54c1-a20e-9b5c17036f78') and status = 'PUBLISHED';
  select count(*) into v_bad from (values ('a1-mid', 20)) e(slug, n) join public.assessments a on a.slug = e.slug
   where (select count(*) from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED') <> e.n
      or exists (select 1 from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'
                 and i.id not in ('093fd0b7-dc77-5294-a893-ae5a1d447680', '436c506e-a3ec-52e1-8d94-d1797f9c519c', '00715c9c-012d-5fde-bb1f-a66f16702dbe', '0604cf22-a4f0-55f9-84a5-4c0b583c1f13', '13c09720-78b2-5445-a94e-c22256072b12', '0f812efc-b6b7-5da1-af3f-33aa4d38efab', '327a60a9-ea0d-5edf-80c7-10c73fe151ae', 'f799d55b-9c1e-53c7-823b-551931519749', 'd2f9aa7b-30b8-515d-ba81-78f423aa9aba', '60e98725-d58a-5d43-9d6d-3c8807c181d8', '75f412a7-335b-584d-b554-61b96a9eb973', '0da2557a-a45b-5661-9d4c-275b30e8a81b', '651b0d9b-0294-5a2b-9ee3-ffb67043c97d', 'df844400-2d17-5d29-bc9e-b0a37d37673c', 'f3baf67b-0f06-534a-a82d-32855b2a9c68', 'dfbddf31-ad4b-5a00-adaf-8062c9fb28a8', 'dfeea71b-9af4-55b7-8f9e-2f8f031ab4af', '79f74894-1cce-5483-aa33-b94623ca5abf', 'c45d6455-4c6f-5bd6-8a5f-dba07c0b2a2b', 'e55f36a2-63d4-54c1-a20e-9b5c17036f78'));
  if v_new <> 20 or v_bad > 0 then raise exception 'Рівень A1: нових завдань %, тестів з помилкою %', v_new, v_bad; end if;
  raise notice 'Готово: a1-mid оновлено — % нових завдань', v_new;
end $$;

commit;
