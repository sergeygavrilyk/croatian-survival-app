-- =====================================================================
-- Перевірки рівня A1 наново після плану «Дублі й сенс уроків» (PR 3–4) · 2026-11-19 · частина 1 з 2
-- Згенеровано: python3 -B scripts/gen_a2_dupes.py assessments (не редагуйте вручну).
--
-- Задача власника 2026-11-19: «Перезібрати перевірки рівнів A1 і A2 після цих змін». Усі 15 тестів A1 — наново
-- генератором v5 (схема 2026-11-07: модуль — 2 завдання на урок (12–20), середина — 30, фінал — 48, кожен модуль — щонайменше 2)
-- з уроків і текстів, які є в курсі зараз: хибні варіанти більше не беруться з прибраних діалогів і слів.
-- Запускати після 20261119_a2_dupes_1_lessons.sql (назва файлу стоїть після нього — «Apply SQL» запускає за назвою).
-- У цій частині 128 нових завдань: a1-m01 — 20, a1-m02 — 20, a1-m03 — 16, a1-m04 — 20, a1-m05 — 20, a1-m06 — 18, a1-m07 — 14.
--   * Завдання — з діалогів, вправ і текстів уроків; нових хорватських речень немає. Старі завдання — у content_versions і DEPRECATED.
--   * Спроби й результати користувачів не змінюються. Повторний запуск нічого не змінює.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника.
-- Очікуване повідомлення: «Готово: 20261119_a2_dupes_2_tests_a1_part1.sql — 7 тестів, 128 нових завдань».
-- =====================================================================

begin;

-- Перевірка модуля A1.1 · 20 завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = 'a1-m01' and cefr = 'A1';
  if v_aid is null then raise exception 'Немає тесту a1-m01 — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = 'e1f7b598-659f-51eb-a976-02287b0be19a') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from '329c44d2-afb3-5e9e-a04e-0ab31405ad9f'::uuid then
    raise exception 'Тест a1-m01 прив’язаний не до модуля A1.1 — звірте базу';
  end if;
  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
          v_payload, 'assessment_rebuild_20261119: перевірку зібрано наново після плану «Дублі й сенс уроків» — старі завдання');
  select (coalesce(max(order_index), 0) / 100 + 1) * 100 into v_shift from public.assessment_items where assessment_id = v_aid;
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + v_shift
   where assessment_id = v_aid and status = 'PUBLISHED';
  update public.assessments set description_ua = 'Після модуля: 20 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~10 хв.', estimated_minutes = 10 where id = v_aid;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, answer_alternatives, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('e1f7b598-659f-51eb-a976-02287b0be19a', v_aid, 1, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Розумію. Здебільшого він у саду, а ввечері — в хаті.", "Справді? Тоді я навіть встигну випити кави.", "Час від часу, раз чи двічі на місяць."]'::jsonb, 0, null, '{}'::text[], 'Razumijem. Uglavnom je u vrtu, a navečer je unutra.', null, null, 'Прозвучало: «Razumijem. Uglavnom je u vrtu, a navečer je unutra.» — «Розумію. Здебільшого він у саду, а ввечері — в хаті.».', (select id from public.lessons where id = '959e879f-a28d-5bed-9c09-16cff91ef456'), 'PUBLISHED', 'claude_assessment_v5'),
  ('4f075458-a32f-54f0-955e-fae69b02b13f', v_aid, 2, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["А ти регулярно плаваєш?", "Коли ти повертаєшся з роботи?", "А що робиш потім?"]'::jsonb, 2, null, '{}'::text[], 'A što radiš zatim?', null, null, 'Прозвучало: «A što radiš zatim?» — «А що робиш потім?».', (select id from public.lessons where id = '4bf48151-be83-5108-bc92-645c0603a1a3'), 'PUBLISHED', 'claude_assessment_v5'),
  ('b8dd2ecb-62b4-5b58-9f9b-c43e34c204db', v_aid, 3, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["О котрій ти виходиш з дому?", "Добре. Де підгузки, якщо треба буде її перевдягнути?", "Дашо, сьогодні субота. Розподілимо домашні справи?"]'::jsonb, 1, null, '{}'::text[], 'Dobro. Gdje su pelene, ako je trebam presvući?', null, null, 'Прозвучало: «Dobro. Gdje su pelene, ako je trebam presvući?» — «Добре. Де підгузки, якщо треба буде її перевдягнути?».', (select id from public.lessons where id = 'd43d6c65-1ce3-5c72-9ecd-cce2ed200fc2'), 'PUBLISHED', 'claude_assessment_v5'),
  ('0efa35d0-585a-5a8a-a6bb-5f2c4438e47d', v_aid, 4, 'A1', 'reading', 'understand', 'multiple_choice', 'Як Тарас їде на роботу?', 'Tarasov običan dan', '["Автобусом", "Пішки", "Трамваєм"]'::jsonb, 2, null, '{}'::text[], null, 'Taras živi u Zagrebu. Svaki dan se budi u šest i pol. Prvo se tušira, a onda doručkuje s obitelji. Na posao ide tramvajem. Radi u skladištu od osam do četiri. Poslije posla ide u trgovinu ili u park sa psom. Navečer obično čita ili gleda film. Spava u jedanaest, jer je ujutro opet rano.', 'Тарас живе в Загребі. Щодня він прокидається о пів на сьому. Спочатку приймає душ, а потім снідає з родиною. На роботу їде трамваєм. Працює на складі з восьмої до четвертої. Після роботи йде в магазин або в парк із собакою. Увечері зазвичай читає або дивиться фільм. Лягає спати об одинадцятій, бо вранці знову рано.', 'Текст «Звичайний день Тараса». Правильна відповідь: «Трамваєм».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('f24853f8-cd88-5020-8310-20fe2d9a8a20', v_aid, 5, 'A1', 'reading', 'understand', 'multiple_choice', 'Чому Данило не може?', 'Obiteljska grupa', '["Він має тренування", "Він хворий", "Він на роботі"]'::jsonb, 0, null, '{}'::text[], null, 'Mama: Tko danas kupuje kruh?
Danilo: Ja ne mogu, imam trening do sedam.
Tata: Ja kupujem kruh i mlijeko poslije posla.
Mama: Hvala! Večera je u osam. Danilo, ne zaboravi: danas ti pereš suđe!
Danilo: Dobro, mama 🙂', 'Мама: Хто сьогодні купує хліб?
Данило: Я не можу, у мене тренування до сьомої.
Тато: Я куплю хліб і молоко після роботи.
Мама: Дякую! Вечеря о восьмій. Данило, не забудь: сьогодні ти миєш посуд!
Данило: Добре, мамо 🙂', 'Текст «Сімейний чат». Правильна відповідь: «Він має тренування».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('c18ea603-a4c3-52cb-ac93-84658139dac5', v_aid, 6, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Darja! Radiš li još u hotelu?', '["Pola kile pilećih prsa i četiri svinjska kotleta.", "Jednu kavu za van i jedan čaj s limunom.", "Više ne, sada radim u školi."]'::jsonb, 2, null, '{}'::text[], 'Darja! Radiš li još u hotelu?', null, null, 'Діалог «Стара знайома»: «Darja! Radiš li još u hotelu?» (Дар’є! Ти ще працюєш у готелі?) — «Više ne, sada radim u školi.» (Уже ні, тепер працюю в школі.).', (select id from public.lessons where id = 'ad0bc1f4-2808-5b24-969d-9da64d4a7a4d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('94a9e44c-c583-5ae0-b55c-90711fa23201', v_aid, 7, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Dašo, subota je. Podijelimo kućanske poslove?', '["Može. Ja usisavam i brišem prašinu.", "Ocat je kod ulja, u trećem redu.", "Jedem, ali moj brat je vegan."]'::jsonb, 0, null, '{}'::text[], 'Dašo, subota je. Podijelimo kućanske poslove?', null, null, 'Діалог «Хто що робить?»: «Dašo, subota je. Podijelimo kućanske poslove?» (Дашо, сьогодні субота. Розподілимо домашні справи?) — «Može. Ja usisavam i brišem prašinu.» (Давай. Я пилососю й витираю пил.).', (select id from public.lessons where id = '9c38f909-9275-5194-9a6e-f799c6e416ce'), 'PUBLISHED', 'claude_assessment_v5'),
  ('2579b5a9-27a3-5347-aa16-931f497e2479', v_aid, 8, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Naravno. Kada joj dajem mlijeko?', '["Pekmez od marelica, ako ga još imamo.", "Trešnje, smokve i prve dinje.", "U pet joj daj bočicu s mlijekom."]'::jsonb, 2, null, '{}'::text[], 'Naravno. Kada joj dajem mlijeko?', null, null, 'Діалог «Сусідка допомагає»: «Naravno. Kada joj dajem mlijeko?» (Звісно. Коли їй дати молоко?) — «U pet joj daj bočicu s mlijekom.» (О п’ятій дай їй пляшечку з молоком.).', (select id from public.lessons where id = 'd43d6c65-1ce3-5c72-9ecd-cce2ed200fc2'), 'PUBLISHED', 'claude_assessment_v5'),
  ('1a44d65a-afe5-54d7-a396-7590dc61afc7', v_aid, 9, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Super! Valjda ti je tamo lakše?', '["Skoro. Grah mora još malo prokuhati.", "Lakše je, ali ipak puno radim.", "Ružmarin i češnjak. Meso posoli i popapri."]'::jsonb, 1, null, '{}'::text[], 'Super! Valjda ti je tamo lakše?', null, null, 'Діалог «Стара знайома»: «Super! Valjda ti je tamo lakše?» (Чудово! Мабуть, тобі там легше?) — «Lakše je, ali ipak puno radim.» (Легше, але я все одно багато працюю.).', (select id from public.lessons where id = 'ad0bc1f4-2808-5b24-969d-9da64d4a7a4d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('5b12301b-5349-58e8-99fb-9403713ef78d', v_aid, 10, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Drijemate li poslijepodne?', '["Іноді, бо я постійно виснажена.", "Не дрімайте і ввечері не пийте кави.", "Уже тиждень маю безсоння. Лягаю об одинадцятій, але не можу заснути."]'::jsonb, 0, null, '{}'::text[], null, 'Liječnica: Što vas muči?
Daša: Već tjedan dana imam nesanicu. Liježem u jedanaest, ali ne mogu zaspati.
Liječnica: Drijemate li poslijepodne?
Daša: Ponekad, jer sam stalno iscrpljena.
Liječnica: Nemojte drijemati i navečer ne pijte kavu.
Daša: Dobro. Nadam se da ću se uskoro naspavati.', 'Liječnica: Що вас турбує?
Daša: Уже тиждень маю безсоння. Лягаю об одинадцятій, але не можу заснути.
Liječnica: Ви дрімаєте вдень?
Daša: Іноді, бо я постійно виснажена.
Liječnica: Не дрімайте і ввечері не пийте кави.
Daša: Добре. Сподіваюся, що скоро висплюся.', 'Діалог «Безсоння»: «Drijemate li poslijepodne?» — «Ponekad, jer sam stalno iscrpljena.», тобто «Іноді, бо я постійно виснажена.».', (select id from public.lessons where id = '63a4a6d8-1cae-5e0e-90ff-98efcfe8b4c7'), 'PUBLISHED', 'claude_assessment_v5'),
  ('beabf65f-bb9a-55b9-bfa0-b77019aa670e', v_aid, 11, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Kada se vraćaš s posla?', '["Готую вечерю, а потім граюся з дітьми.", "Щовечора повертаюся близько шостої.", "Так. Наприкінці дня читаю пів години й рано лягаю."]'::jsonb, 1, null, '{}'::text[], null, 'Marko: Kada se vraćaš s posla?
Darja: Svake večeri se vraćam oko šest.
Marko: A što radiš nakon toga?
Darja: Kuham večeru, a zatim se igram s djecom.
Marko: Imaš li neku večernju rutinu?
Darja: Imam. Na kraju dana čitam pola sata i rano liježem.', 'Marko: Коли ти повертаєшся з роботи?
Darja: Щовечора повертаюся близько шостої.
Marko: А що робиш після цього?
Darja: Готую вечерю, а потім граюся з дітьми.
Marko: У тебе є якийсь вечірній ритуал?
Darja: Так. Наприкінці дня читаю пів години й рано лягаю.', 'Діалог «Увечері»: «Kada se vraćaš s posla?» — «Svake večeri se vraćam oko šest.», тобто «Щовечора повертаюся близько шостої.».', (select id from public.lessons where id = '4bf48151-be83-5108-bc92-645c0603a1a3'), 'PUBLISHED', 'claude_assessment_v5'),
  ('2e63066e-271d-51b1-a9bc-dd5f73f90435', v_aid, 12, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Što planiraš za sljedeći tjedan?', '["Дякую, що нагадуєш! Мені треба купити подарунок.", "Не забудь, у суботу день народження Марка.", "На початку тижня в мене лікар, а в середу курси."]'::jsonb, 2, null, '{}'::text[], null, 'Luka: Što planiraš za sljedeći tjedan?
Darja: Početkom tjedna imam liječnika, a u srijedu tečaj.
Luka: Ne zaboravi, u subotu je Markov rođendan.
Darja: Hvala što me podsjećaš! Moram kupiti poklon.
Luka: A sastanak s majstorom? Trebamo li ga otkazati?
Darja: Ne, samo ga moramo odgoditi za utorak.', 'Luka: Що ти плануєш на наступний тиждень?
Darja: На початку тижня в мене лікар, а в середу курси.
Luka: Не забудь, у суботу день народження Марка.
Darja: Дякую, що нагадуєш! Мені треба купити подарунок.
Luka: А зустріч з майстром? Нам треба її скасувати?
Darja: Ні, нам треба лише перенести її на вівторок.', 'Діалог «Розклад на тиждень»: «Što planiraš za sljedeći tjedan?» — «Početkom tjedna imam liječnika, a u srijedu tečaj.», тобто «На початку тижня в мене лікар, а в середу курси.».', (select id from public.lessons where id = '3365f423-e694-5b55-baa1-3205fba11aff'), 'PUBLISHED', 'claude_assessment_v5'),
  ('663d795d-fd6b-5d92-bf4f-d5843e193fd3', v_aid, 13, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Мені треба вмитися». Що ви скажете?', null, '["Usisavam u dnevnom boravku.", "Moram se umiti.", "Koliko često kuhaš?"]'::jsonb, 1, null, '{}'::text[], null, null, null, '«Мені треба вмитися.» — «Moram se umiti.».', (select id from public.lessons where id = '54f17cf7-3c17-5978-b400-b6b6888c9f84'), 'PUBLISHED', 'claude_assessment_v5'),
  ('43019ee9-010d-529d-9a09-ed79cbf57a2d', v_aid, 14, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Мені треба скасувати запис». Що ви скажете?', null, '["Presvuci bebu, molim te.", "Obično se budim u sedam.", "Moram otkazati termin."]'::jsonb, 2, null, '{}'::text[], null, null, null, '«Мені треба скасувати запис.» — «Moram otkazati termin.».', (select id from public.lessons where id = '3365f423-e694-5b55-baa1-3205fba11aff'), 'PUBLISHED', 'claude_assessment_v5'),
  ('8bff161a-4c6d-5df9-a503-1344892f41aa', v_aid, 15, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «пісок»', null, '[]'::jsonb, null, 'pijesak', '{}'::text[], null, null, null, '«пісок» — pijesak.', (select id from public.lessons where id = 'd43d6c65-1ce3-5c72-9ecd-cce2ed200fc2'), 'PUBLISHED', 'claude_assessment_v5'),
  ('1bbe3b6d-75e1-5706-bc6f-374d8c282f39', v_aid, 16, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «згадати»', null, '[]'::jsonb, null, 'sjetiti se', '{}'::text[], null, null, null, '«згадати» — sjetiti se.', (select id from public.lessons where id = '3365f423-e694-5b55-baa1-3205fba11aff'), 'PUBLISHED', 'claude_assessment_v5'),
  ('a2c10919-ab36-5a16-b15e-c06dbed104cd', v_aid, 17, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Дай їй соску, будь ласка.»', null, '["molim", "te.", "Daj", "dudu,", "joj"]'::jsonb, null, 'Daj joj dudu, molim te.', array['Molim te, daj joj dudu.']::text[], null, null, null, '«Дай їй соску, будь ласка.» — «Daj joj dudu, molim te.».', (select id from public.lessons where id = 'd43d6c65-1ce3-5c72-9ecd-cce2ed200fc2'), 'PUBLISHED', 'claude_assessment_v5'),
  ('07a081e7-3a8e-5dc5-bbc8-ba53581e8e3b', v_aid, 18, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Потім я збираюся на роботу.»', null, '["posao.", "za", "spremam", "Zatim", "se"]'::jsonb, null, 'Zatim se spremam za posao.', '{}'::text[], null, null, null, '«Потім я збираюся на роботу.» — «Zatim se spremam za posao.».', (select id from public.lessons where id = '4bf48151-be83-5108-bc92-645c0603a1a3'), 'PUBLISHED', 'claude_assessment_v5'),
  ('fddd4816-8ffe-58f7-a6ab-9fd7b44e4141', v_aid, 19, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Я вигулюю пса в парку.»', null, '["u", "parku.", "psa", "Šetam"]'::jsonb, null, 'Šetam psa u parku.', array['U parku šetam psa.']::text[], null, null, null, '«Я вигулюю пса в парку.» — «Šetam psa u parku.».', (select id from public.lessons where id = '1968c7d5-4e3a-5b1e-92f6-88df711e9c54'), 'PUBLISHED', 'claude_assessment_v5'),
  ('68bb4502-7bc1-5ce5-a8ab-b728f8d5b2d4', v_aid, 20, 'A1', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Ходімо прогуляємося!»', null, '[]'::jsonb, null, 'Idemo prošetati!', '{}'::text[], null, null, null, '«Ходімо прогуляємося!» — «Idemo prošetati!».', (select id from public.lessons where id = '458b73de-d6b3-5bd3-98ad-c243a2fff03f'), 'PUBLISHED', 'claude_assessment_v5');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірки рівня A1 наново за схемою 2026-11-07 після плану «Дублі й сенс уроків» (PR 3–4) — завдання й хибні варіанти лише з уроків і текстів, які є в курсі зараз (задача власника 2026-11-19). Потрібна перевірка носієм.');
end $$;

-- Перевірка модуля A1.2 · 20 завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = 'a1-m02' and cefr = 'A1';
  if v_aid is null then raise exception 'Немає тесту a1-m02 — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = 'a38f632a-ab56-55db-bea6-da6f23aa7fa6') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from '8d02296d-bc46-5537-9a9b-c678fe5ff1c9'::uuid then
    raise exception 'Тест a1-m02 прив’язаний не до модуля A1.2 — звірте базу';
  end if;
  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
          v_payload, 'assessment_rebuild_20261119: перевірку зібрано наново після плану «Дублі й сенс уроків» — старі завдання');
  select (coalesce(max(order_index), 0) / 100 + 1) * 100 into v_shift from public.assessment_items where assessment_id = v_aid;
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + v_shift
   where assessment_id = v_aid and status = 'PUBLISHED';
  update public.assessments set description_ua = 'Після модуля: 20 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~10 хв.', estimated_minutes = 10 where id = v_aid;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, answer_alternatives, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('a38f632a-ab56-55db-bea6-da6f23aa7fa6', v_aid, 1, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Змішай борошно, яйця, цукор і трохи олії.", "Дві головки салату й пучок петрушки.", "Добре. Зустрінемося біля заморожених овочів."]'::jsonb, 1, null, '{}'::text[], 'Dvije glavice zelene salate i vezicu peršina.', null, null, 'Прозвучало: «Dvije glavice zelene salate i vezicu peršina.» — «Дві головки салату й пучок петрушки.».', (select id from public.lessons where id = '46a89cf5-41e0-50a2-99b1-f4e66a5ff146'), 'PUBLISHED', 'claude_assessment_v5'),
  ('1f0787c1-5091-5de8-80a4-5037aa1afbd9', v_aid, 2, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["А брецелі у вас є? Син їх обожнює.", "Пів кіло курячих грудок і чотири свинячі відбивні.", "А я їм цільнозерновий хліб і варене яйце."]'::jsonb, 2, null, '{}'::text[], 'Ja jedem integralni kruh i kuhano jaje.', null, null, 'Прозвучало: «Ja jedem integralni kruh i kuhano jaje.» — «А я їм цільнозерновий хліб і варене яйце.».', (select id from public.lessons where id = 'bb7bc159-cb40-5a8a-91b7-c6da05c6342a'), 'PUBLISHED', 'claude_assessment_v5'),
  ('fc4540cb-ecb2-5a24-9eeb-b12c241b4f16', v_aid, 3, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["На кухні в нас є мікрохвильовка.", "Вечеря була чудова! Я допоможу тобі прибрати зі столу.", "Візьми візок, а я піду по молочні продукти."]'::jsonb, 0, null, '{}'::text[], 'U kuhinji imamo mikrovalnu.', null, null, 'Прозвучало: «U kuhinji imamo mikrovalnu.» — «На кухні в нас є мікрохвильовка.».', (select id from public.lessons where id = '2c192d05-f259-53b6-a6ec-55ebfb25ec01'), 'PUBLISHED', 'claude_assessment_v5'),
  ('14e97dc5-3f39-5b7d-9880-12cd29a85636', v_aid, 4, 'A1', 'reading', 'understand', 'multiple_choice', 'Скільки коштує денне меню?', 'Dnevni meni', '["9 €", "16 €", "11 €"]'::jsonb, 0, null, '{}'::text[], null, 'DNEVNI MENI – 9 €
Juha od rajčice
Pečena piletina, krumpir i salata
ili
Varivo od graha s kobasicom
Kolač dana
Kruh i voda su besplatni. Kavu plaćate posebno.
Radimo od 11 do 16 sati.', 'ДЕННЕ МЕНЮ – 9 €
Томатний суп
Запечена курка, картопля й салат
або
Рагу з квасолі з ковбаскою
Тістечко дня
Хліб і вода безкоштовні. За каву платите окремо.
Працюємо з 11 до 16 години.', 'Текст «Денне меню». Правильна відповідь: «9 €».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('9d6d9cd8-67eb-594b-bb43-0dae03cffc9e', v_aid, 5, 'A1', 'reading', 'understand', 'multiple_choice', 'Який хліб є без цукру?', 'Nova pekara', '["Цільнозерновий", "Білий", "Домашній"]'::jsonb, 0, null, '{}'::text[], null, 'NOVA PEKARA U VAŠEM KVARTU!
Svaki dan svježi kruh, peciva i burek.
Otvoreno od 6 do 20 sati, nedjeljom od 7 do 13.
Ovaj tjedan: kava za van i kroasan samo 2 €!
Imamo i integralni kruh bez šećera.
Dođite i probajte!', 'НОВА ПЕКАРНЯ У ВАШОМУ РАЙОНІ!
Щодня свіжий хліб, булочки й бурек.
Відчинено з 6 до 20 години, у неділю з 7 до 13.
Цього тижня: кава з собою і круасан лише 2 €!
У нас є й цільнозерновий хліб без цукру.
Приходьте й скуштуйте!', 'Текст «Нова пекарня». Правильна відповідь: «Цільнозерновий».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('822d1fe3-8f37-560c-b787-04c7c8191b7d', v_aid, 6, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Mogu li maknuti poklopac?', '["Ne diraj, lonac je vruć!", "Subotom se izležavam, a nedjeljom idem na izlet.", "Više ne, sada radim u školi."]'::jsonb, 0, null, '{}'::text[], 'Mogu li maknuti poklopac?', null, null, 'Діалог «Обережно, гаряче!»: «Mogu li maknuti poklopac?» (Можна зняти кришку?) — «Ne diraj, lonac je vruć!» (Не чіпай, каструля гаряча!).', (select id from public.lessons where id = '17fcd38a-e295-5849-9ba3-1ef240c6be78'), 'PUBLISHED', 'claude_assessment_v5'),
  ('83b68aad-4aac-5ea7-a757-2779300cef13', v_aid, 7, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Dajte mi dvije orade. Možete li ih očistiti?', '["Na balkonu. Ja ću peglati košulje.", "Svaki dan, a mačića redovito četkajte.", "Naravno. Imamo i lignje i srdele."]'::jsonb, 2, null, '{}'::text[], 'Dajte mi dvije orade. Možete li ih očistiti?', null, null, 'Діалог «На рибному ринку»: «Dajte mi dvije orade. Možete li ih očistiti?» (Дайте мені дві доради. Можете їх почистити?) — «Naravno. Imamo i lignje i srdele.» (Звісно. Є ще кальмари й сардини.).', (select id from public.lessons where id = 'ae33e31a-f937-5305-908e-3d957df15f6a'), 'PUBLISHED', 'claude_assessment_v5'),
  ('fd8b5134-2a33-582f-b021-4595b4f86ede', v_aid, 8, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Može nedjelja. Što je specijalitet kuće? Imate li neku preporuku?', '["Početkom tjedna imam liječnika, a u srijedu tečaj.", "Nažalost nemam, imam sastanak cijeli dan.", "Riba na žaru. Potvrdit ću vam rezervaciju porukom."]'::jsonb, 2, null, '{}'::text[], 'Može nedjelja. Što je specijalitet kuće? Imate li neku preporuku?', null, null, 'Діалог «Зміна планів»: «Može nedjelja. Što je specijalitet kuće? Imate li neku preporuku?» (Неділя підходить. Яка у вас фірмова страва? Що порадите?) — «Riba na žaru. Potvrdit ću vam rezervaciju porukom.» (Риба на грилі. Я підтверджу вам бронювання повідомленням.).', (select id from public.lessons where id = '5e4a1c56-3931-58bb-81af-cb598966da77'), 'PUBLISHED', 'claude_assessment_v5'),
  ('f68dc37e-cadd-5eae-84b7-5435260da40b', v_aid, 9, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Gdje da stavim čaše za vino?', '["U ormar, ali prvo ih operi rukom.", "Radimo roštilj u vrtu, a u nedjelju idemo planinariti.", "Treba. Uzmi metlu i krpu, hvala što mi pomažeš!"]'::jsonb, 0, null, '{}'::text[], 'Gdje da stavim čaše za vino?', null, null, 'Діалог «Після вечері»: «Gdje da stavim čaše za vino?» (Куди поставити келихи для вина?) — «U ormar, ali prvo ih operi rukom.» (У шафу, але спершу помий їх руками.).', (select id from public.lessons where id = '213ab10f-63a4-5e1c-8b2e-156c433de874'), 'PUBLISHED', 'claude_assessment_v5'),
  ('db2003e8-58f3-5665-afc7-7580155d8a3d', v_aid, 10, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Darja, jedeš li meso?', '["Їм, а от мій брат — веган.", "Прочитай склад на упаковці, там усе написано.", "Добре, приготую щось неперчене. Сподіваюся, не буде прісним."]'::jsonb, 0, null, '{}'::text[], null, 'Mia: Darja, jedeš li meso?
Darja: Jedem, ali moj brat je vegan.
Mia: A smije li jesti sir?
Darja: Ne, ni sir ni jaja. I ne podnosi začinjenu hranu.
Mia: Dobro, kuham nešto blago. Nadam se da neće biti bljutavo.
Darja: Pročitaj sastav na pakiranju, tamo sve piše.', 'Mia: Дар’є, ти їси м’ясо?
Darja: Їм, а от мій брат — веган.
Mia: А сир йому можна?
Darja: Ні, ні сиру, ні яєць. І він погано переносить гостру їжу.
Mia: Добре, приготую щось неперчене. Сподіваюся, не буде прісним.
Darja: Прочитай склад на упаковці, там усе написано.', 'Діалог «Що ти не їси?»: «Darja, jedeš li meso?» — «Jedem, ali moj brat je vegan.», тобто «Їм, а от мій брат — веган.».', (select id from public.lessons where id = '6af82dd3-beb1-54cf-9c1b-44ec3cb12a35'), 'PUBLISHED', 'claude_assessment_v5'),
  ('657c2215-16c7-5d52-baee-3110e0966545', v_aid, 11, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Dašo, imaš li popis za kupovinu?', '["Шість глибоких тарілок для супу й шість мілких для другої страви.", "А в нас на вихідних яєчня-глазунья й млинці.", "Є. Нам треба дві банки помідорів і літр олії."]'::jsonb, 2, null, '{}'::text[], null, 'Luka: Dašo, imaš li popis za kupovinu?
Daša: Imam. Trebamo dvije konzerve rajčice i litru ulja.
Luka: A brašno?
Daša: Jedan kilogram brašna i deset jaja.
Luka: Uzmi kolica, ja idem po mliječne proizvode.
Daša: Dobro. Nađimo se kod smrznutog povrća.', 'Luka: Дашо, у тебе є список покупок?
Daša: Є. Нам треба дві банки помідорів і літр олії.
Luka: А борошно?
Daša: Кілограм борошна і десять яєць.
Luka: Візьми візок, а я піду по молочні продукти.
Daša: Добре. Зустрінемося біля заморожених овочів.', 'Діалог «Що купити?»: «Dašo, imaš li popis za kupovinu?» — «Imam. Trebamo dvije konzerve rajčice i litru ulja.», тобто «Є. Нам треба дві банки помідорів і літр олії.».', (select id from public.lessons where id = '0c19643d-57ff-5030-820f-ba330833ea88'), 'PUBLISHED', 'claude_assessment_v5'),
  ('57f4390d-d0e3-5648-80f0-7e59182d6032', v_aid, 12, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Hvala. Imate li gotova jela?', '["Оцет біля олії, у третьому ряду.", "Є, в холодильнику в кінці магазину.", "Там само, біля спецій."]'::jsonb, 1, null, '{}'::text[], null, 'Darja: Oprostite, na kojem je odjelu ocat?
Prodavačica: Ocat je kod ulja, u trećem redu.
Darja: A sol i papar?
Prodavačica: Isto tamo, pored začina.
Darja: Hvala. Imate li gotova jela?
Prodavačica: Imamo, u hladnjaku na kraju trgovine.', 'Darja: Перепрошую, у якому відділі оцет?
Prodavačica: Оцет біля олії, у третьому ряду.
Darja: А сіль і перець?
Prodavačica: Там само, біля спецій.
Darja: Дякую. У вас є готові страви?
Prodavačica: Є, в холодильнику в кінці магазину.', 'Діалог «Де знайти?»: «Hvala. Imate li gotova jela?» — «Imamo, u hladnjaku na kraju trgovine.», тобто «Є, в холодильнику в кінці магазину.».', (select id from public.lessons where id = '0c19643d-57ff-5030-820f-ba330833ea88'), 'PUBLISHED', 'claude_assessment_v5'),
  ('9aa126eb-d0df-50ba-a3ce-91ebb99c7a17', v_aid, 13, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Що сьогодні сезонне?». Що ви скажете?', null, '["Što je danas sezonsko?", "Hoćemo li naručiti dostavu hrane?", "Daj mi žličicu."]'::jsonb, 0, null, '{}'::text[], null, null, null, '«Що сьогодні сезонне?» — «Što je danas sezonsko?».', (select id from public.lessons where id = '46a89cf5-41e0-50a2-99b1-f4e66a5ff146'), 'PUBLISHED', 'claude_assessment_v5'),
  ('adb8cf49-5b3c-5b7d-877e-2bf85fa3140f', v_aid, 14, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Що ти вариш?». Що ви скажете?', null, '["Što kuhaš?", "Gdje je odjel mliječnih proizvoda?", "Imate li nešto slatko?"]'::jsonb, 0, null, '{}'::text[], null, null, null, '«Що ти вариш?» — «Što kuhaš?».', (select id from public.lessons where id = '17fcd38a-e295-5849-9ba3-1ef240c6be78'), 'PUBLISHED', 'claude_assessment_v5'),
  ('05ad6c25-7199-5b5a-8edf-8f21eb5be2fa', v_aid, 15, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «яєчня-бовтанка»', null, '[]'::jsonb, null, 'kajgana', '{}'::text[], null, null, null, '«яєчня-бовтанка» — kajgana.', (select id from public.lessons where id = 'bb7bc159-cb40-5a8a-91b7-c6da05c6342a'), 'PUBLISHED', 'claude_assessment_v5'),
  ('e91f2033-c0d6-5fed-916b-e6b14e8e957c', v_aid, 16, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «мішати; перемішувати»', null, '[]'::jsonb, null, 'miješati', '{}'::text[], null, null, null, '«мішати; перемішувати» — miješati.', (select id from public.lessons where id = '3e652232-866b-5edf-ac05-d61ee7a325fe'), 'PUBLISHED', 'claude_assessment_v5'),
  ('427c7dfc-9747-5108-9396-b54a1a622a2d', v_aid, 17, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Розігрій духовку до двохсот градусів.»', null, '["na", "Zagrij", "pećnicu", "stupnjeva.", "dvjesto"]'::jsonb, null, 'Zagrij pećnicu na dvjesto stupnjeva.', array['Pećnicu zagrij na dvjesto stupnjeva.']::text[], null, null, null, '«Розігрій духовку до двохсот градусів.» — «Zagrij pećnicu na dvjesto stupnjeva.».', (select id from public.lessons where id = '3e652232-866b-5edf-ac05-d61ee7a325fe'), 'PUBLISHED', 'claude_assessment_v5'),
  ('f59ce918-f672-5d85-ab3e-9bd3c172ffc1', v_aid, 18, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Принеси тацю з кухні.»', null, '["pladanj", "Donesi", "iz", "kuhinje."]'::jsonb, null, 'Donesi pladanj iz kuhinje.', array['Iz kuhinje donesi pladanj.']::text[], null, null, null, '«Принеси тацю з кухні.» — «Donesi pladanj iz kuhinje.».', (select id from public.lessons where id = '213ab10f-63a4-5e1c-8b2e-156c433de874'), 'PUBLISHED', 'claude_assessment_v5'),
  ('fc1243f1-8fb7-5d79-8bc1-b714f099e61e', v_aid, 19, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Де відкривачка для пляшок?»', null, '["otvarač", "boce?", "je", "Gdje", "za"]'::jsonb, null, 'Gdje je otvarač za boce?', '{}'::text[], null, null, null, '«Де відкривачка для пляшок?» — «Gdje je otvarač za boce?».', (select id from public.lessons where id = '213ab10f-63a4-5e1c-8b2e-156c433de874'), 'PUBLISHED', 'claude_assessment_v5'),
  ('dffb0ee0-6266-5d78-abd2-9d590b12f955', v_aid, 20, 'A1', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «У вас є хліб без глютену?»', null, '[]'::jsonb, null, 'Imate li kruh bez glutena?', '{}'::text[], null, null, null, '«У вас є хліб без глютену?» — «Imate li kruh bez glutena?».', (select id from public.lessons where id = '6af82dd3-beb1-54cf-9c1b-44ec3cb12a35'), 'PUBLISHED', 'claude_assessment_v5');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірки рівня A1 наново за схемою 2026-11-07 після плану «Дублі й сенс уроків» (PR 3–4) — завдання й хибні варіанти лише з уроків і текстів, які є в курсі зараз (задача власника 2026-11-19). Потрібна перевірка носієм.');
end $$;

-- Перевірка модуля A1.3 · 16 завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = 'a1-m03' and cefr = 'A1';
  if v_aid is null then raise exception 'Немає тесту a1-m03 — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = '7dce849f-bf84-5341-b37e-a646e11cd73e') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from '88e77a6f-1140-5f26-b724-0ae15477637a'::uuid then
    raise exception 'Тест a1-m03 прив’язаний не до модуля A1.3 — звірте базу';
  end if;
  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
          v_payload, 'assessment_rebuild_20261119: перевірку зібрано наново після плану «Дублі й сенс уроків» — старі завдання');
  select (coalesce(max(order_index), 0) / 100 + 1) * 100 into v_shift from public.assessment_items where assessment_id = v_aid;
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + v_shift
   where assessment_id = v_aid and status = 'PUBLISHED';
  update public.assessments set description_ua = 'Після модуля: 16 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~8 хв.', estimated_minutes = 8 where id = v_aid;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, answer_alternatives, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('7dce849f-bf84-5341-b37e-a646e11cd73e', v_aid, 1, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Порівняйте їх спокійно, ми не поспішаємо.", "Згодна. Краще заплатити більше, ніж купувати двічі.", "Срібло вона любить більше, ніж золото."]'::jsonb, 0, null, '{}'::text[], 'Usporedite ih na miru, ne žurimo se.', null, null, 'Прозвучало: «Usporedite ih na miru, ne žurimo se.» — «Порівняйте їх спокійно, ми не поспішаємо.».', (select id from public.lessons where id = '7042ff57-9a20-514a-ab80-71b6f63579f7'), 'PUBLISHED', 'claude_assessment_v5'),
  ('f1cab5a7-5265-503d-a869-b4ee24d498b8', v_aid, 2, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["А якщо буде дощ?", "Мені шкода. Етикетка ще на ньому?", "Я йду в дрогерію. Що нам треба?"]'::jsonb, 0, null, '{}'::text[], 'A ako pada kiša?', null, null, 'Прозвучало: «A ako pada kiša?» — «А якщо буде дощ?».', (select id from public.lessons where id = 'c8297811-44ed-55a2-8cb5-d1bd9b8a6a73'), 'PUBLISHED', 'claude_assessment_v5'),
  ('097f188c-629c-5c51-a540-cb2e8f27cd4f', v_aid, 3, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Не можу, оплата післяплатою.", "Вибір великий, важко обрати.", "Майже однакова. Інша дорожча через назву."]'::jsonb, 0, null, '{}'::text[], 'Ne mogu, plaćanje je pouzećem.', null, null, 'Прозвучало: «Ne mogu, plaćanje je pouzećem.» — «Не можу, оплата післяплатою.».', (select id from public.lessons where id = '91d4c9b3-c9a8-5e94-8691-6683835c375b'), 'PUBLISHED', 'claude_assessment_v5'),
  ('3a3d1886-74e7-5828-b1fb-8038f76fd257', v_aid, 4, 'A1', 'reading', 'understand', 'multiple_choice', 'Коли пакет безкоштовний?', 'Akcija u supermarketu', '["Якщо покупка понад 50 €", "Завжди", "У суботу"]'::jsonb, 0, null, '{}'::text[], null, 'AKCIJA OD PONEDJELJKA DO SUBOTE!
Mlijeko 1 l – 0,99 €
Jabuke 1 kg – 1,49 €
Sir 500 g – 3,99 €
Deterdžent za rublje – minus 30 %
Za kupnju veću od 50 € dobivate vrećicu besplatno.
Plaćanje karticom ili gotovinom.', 'АКЦІЯ З ПОНЕДІЛКА ДО СУБОТИ!
Молоко 1 л – 0,99 €
Яблука 1 кг – 1,49 €
Сир 500 г – 3,99 €
Пральний засіб – мінус 30 %
За покупку понад 50 € отримуєте пакет безкоштовно.
Оплата карткою або готівкою.', 'Текст «Знижки в супермаркеті». Правильна відповідь: «Якщо покупка понад 50 €».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('d8f24cef-eeaf-5426-9d8a-332e1b02a28f', v_aid, 5, 'A1', 'reading', 'understand', 'multiple_choice', 'Що не можна робити з одягом до повернення?', 'Povrat robe', '["Прати його", "Носити його", "Приміряти його"]'::jsonb, 1, null, '{}'::text[], null, 'POVRAT I ZAMJENA ROBE
Stvari možete vratiti ili zamijeniti u roku od 14 dana.
Trebate račun i originalno pakiranje.
Odjeću prije toga ne smijete nositi.
Novac vraćamo na karticu ili u gotovini.
Pitajte prodavača na blagajni.', 'ПОВЕРНЕННЯ Й ОБМІН ТОВАРУ
Речі можна повернути або обміняти протягом 14 днів.
Потрібні чек і оригінальна упаковка.
Одяг до цього не можна носити.
Гроші повертаємо на картку або готівкою.
Запитайте продавця на касі.', 'Текст «Повернення товару». Правильна відповідь: «Носити його».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('95961061-d97f-538b-a608-c5ad54d26908', v_aid, 6, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Koju marku mi preporučujete?', '["Jesu, iz mog vrta. I patlidžani su domaći.", "Ove dvije su slične, ali ova je povoljnija.", "Početkom tjedna imam liječnika, a u srijedu tečaj."]'::jsonb, 1, null, '{}'::text[], 'Koju marku mi preporučujete?', null, null, 'Діалог «Дві марки»: «Koju marku mi preporučujete?» (Яку марку ви мені радите?) — «Ove dvije su slične, ali ova je povoljnija.» (Ці дві схожі, але ця вигідніша.).', (select id from public.lessons where id = '7042ff57-9a20-514a-ab80-71b6f63579f7'), 'PUBLISHED', 'claude_assessment_v5'),
  ('bf541529-bc7e-599a-9e4a-35da6ec0942a', v_aid, 7, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Ima li velike razlike u materijalu?', '["Ima. Crne su od kože i puno su trajnije.", "Riba na žaru. Potvrdit ću vam rezervaciju porukom.", "Svake večeri se vraćam oko šest."]'::jsonb, 0, null, '{}'::text[], 'Ima li velike razlike u materijalu?', null, null, 'Діалог «Які кросівки?»: «Ima li velike razlike u materijalu?» (А матеріал сильно відрізняється?) — «Ima. Crne su od kože i puno su trajnije.» (Так. Чорні шкіряні й набагато міцніші.).', (select id from public.lessons where id = '7042ff57-9a20-514a-ab80-71b6f63579f7'), 'PUBLISHED', 'claude_assessment_v5'),
  ('d6349275-7289-53dd-a9bc-5858021f75b1', v_aid, 8, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Darja, kakav je tvoj stil?', '["Ružmarin i češnjak. Meso posoli i popapri.", "Volim sportsku odjeću. Visoke pete mi se ne sviđaju.", "Napravi mi kajganu i jedan tost, molim te."]'::jsonb, 1, null, '{}'::text[], 'Darja, kakav je tvoj stil?', null, null, 'Діалог «Про смаки»: «Darja, kakav je tvoj stil?» (Даріє, який у тебе стиль?) — «Volim sportsku odjeću. Visoke pete mi se ne sviđaju.» (Люблю спортивний одяг. Високі підбори мені не подобаються.).', (select id from public.lessons where id = '9a979d32-2f4b-5127-bc22-7292763c7de4'), 'PUBLISHED', 'claude_assessment_v5'),
  ('7473a9ec-b810-599e-b283-755a19722fe4', v_aid, 9, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Predivan je! Možete li ga zamotati?', '["Не забудь капелюх, сонце сильне.", "Звісно, у подарунковий папір із червоною стрічкою.", "Добрий день, я шукаю подарунок для мами."]'::jsonb, 1, null, '{}'::text[], null, 'Daša: Dobar dan, tražim poklon za mamu.
Zlatar: Imamo lijepe ogrlice i narukvice. Što ona voli?
Daša: Srebro voli više nego zlato.
Zlatar: Pogledajte ovaj srebrni lančić s malim privjeskom.
Daša: Predivan je! Možete li ga zamotati?
Zlatar: Naravno, u ukrasni papir s crvenom vrpcom.', 'Daša: Добрий день, я шукаю подарунок для мами.
Zlatar: У нас є гарні намиста й браслети. Що вона любить?
Daša: Срібло вона любить більше, ніж золото.
Zlatar: Подивіться на цей срібний ланцюжок з маленьким кулоном.
Daša: Чудовий! Можете його загорнути?
Zlatar: Звісно, у подарунковий папір із червоною стрічкою.', 'Діалог «У ювелірному»: «Predivan je! Možete li ga zamotati?» — «Naravno, u ukrasni papir s crvenom vrpcom.», тобто «Звісно, у подарунковий папір із червоною стрічкою.».', (select id from public.lessons where id = '86d268a5-7193-53c5-955b-cf6cc69116f1'), 'PUBLISHED', 'claude_assessment_v5'),
  ('f964acaf-b6f2-52a9-b417-d6380160b780', v_aid, 10, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Kakve su recenzije?', '["У тебе є промокод? Введи його перед оплатою.", "Чудові. Додаю її в кошик.", "Чорну розпродали, але сині є."]'::jsonb, 1, null, '{}'::text[], null, 'Daša: Luka, ova internetska trgovina ima besplatnu dostavu.
Luka: Je li ta jakna na zalihi?
Daša: Crna je rasprodana, ali plave ima.
Luka: Kakve su recenzije?
Daša: Odlične. Dodajem je u košaricu.
Luka: Imaš li kod za popust? Upiši ga prije plaćanja.', 'Daša: Луко, в цьому інтернет-магазині безкоштовна доставка.
Luka: А ця куртка є в наявності?
Daša: Чорну розпродали, але сині є.
Luka: А які відгуки?
Daša: Чудові. Додаю її в кошик.
Luka: У тебе є промокод? Введи його перед оплатою.', 'Діалог «Замовляємо онлайн»: «Kakve su recenzije?» — «Odlične. Dodajem je u košaricu.», тобто «Чудові. Додаю її в кошик.».', (select id from public.lessons where id = '91d4c9b3-c9a8-5e94-8691-6683835c375b'), 'PUBLISHED', 'claude_assessment_v5'),
  ('2cfe1442-668e-5be2-88de-8f2f70bca499', v_aid, 11, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Можете вкоротити ці штани?». Що ви скажете?', null, '["Kako mi stoji ova jakna?", "Možete li skratiti ove hlače?", "Zamotajte u ukrasni papir, molim."]'::jsonb, 1, null, '{}'::text[], null, null, null, '«Можете вкоротити ці штани?» — «Možete li skratiti ove hlače?».', (select id from public.lessons where id = '7fb1b6e5-93b4-5776-b82b-25e7769fd32d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('945943b2-263d-55e6-8233-fbe9e612591b', v_aid, 12, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Я беру купальник і шорти». Що ви скажете?', null, '["Više volim sportsku odjeću.", "Uzimam kupaći kostim i kratke hlače.", "Ova jakna je bolja i jeftinija."]'::jsonb, 1, null, '{}'::text[], null, null, null, '«Я беру купальник і шорти.» — «Uzimam kupaći kostim i kratke hlače.».', (select id from public.lessons where id = 'c8297811-44ed-55a2-8cb5-d1bd9b8a6a73'), 'PUBLISHED', 'claude_assessment_v5'),
  ('9c790a32-552f-53b5-9150-f1e007ac65f9', v_aid, 13, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «якість»', null, '[]'::jsonb, null, 'kvaliteta', '{}'::text[], null, null, null, '«якість» — kvaliteta.', (select id from public.lessons where id = '7042ff57-9a20-514a-ab80-71b6f63579f7'), 'PUBLISHED', 'claude_assessment_v5'),
  ('c7515d41-dc3f-54a3-8810-845adb186bf0', v_aid, 14, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Мені подобається твій стиль.»', null, '["tvoj", "se", "Sviđa", "stil.", "mi"]'::jsonb, null, 'Sviđa mi se tvoj stil.', array['Tvoj stil mi se sviđa.']::text[], null, null, null, '«Мені подобається твій стиль.» — «Sviđa mi se tvoj stil.».', (select id from public.lessons where id = '9a979d32-2f4b-5127-bc22-7292763c7de4'), 'PUBLISHED', 'claude_assessment_v5'),
  ('9ebbff80-ee90-5533-b48e-fe2500b3342d', v_aid, 15, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «У нас немає гелю для душу.»', null, '["tuširanje.", "gela", "za", "Nemamo"]'::jsonb, null, 'Nemamo gela za tuširanje.', array['Gela za tuširanje nemamo.']::text[], null, null, null, '«У нас немає гелю для душу.» — «Nemamo gela za tuširanje.».', (select id from public.lessons where id = '9ba8e62a-83fd-5b08-9e01-760bc0f7219f'), 'PUBLISHED', 'claude_assessment_v5'),
  ('b55a75ab-de2e-5e81-8991-a614b9d4581e', v_aid, 16, 'A1', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Мені потрібен дезодорант і гель для душу.»', null, '[]'::jsonb, null, 'Trebam dezodorans i gel za tuširanje.', '{}'::text[], null, null, null, '«Мені потрібен дезодорант і гель для душу.» — «Trebam dezodorans i gel za tuširanje.».', (select id from public.lessons where id = '9ba8e62a-83fd-5b08-9e01-760bc0f7219f'), 'PUBLISHED', 'claude_assessment_v5');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірки рівня A1 наново за схемою 2026-11-07 після плану «Дублі й сенс уроків» (PR 3–4) — завдання й хибні варіанти лише з уроків і текстів, які є в курсі зараз (задача власника 2026-11-19). Потрібна перевірка носієм.');
end $$;

-- Перевірка модуля A1.4 · 20 завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = 'a1-m04' and cefr = 'A1';
  if v_aid is null then raise exception 'Немає тесту a1-m04 — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = '8608fe47-7921-57c6-86d7-ba5daaa6fbe4') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from 'e092e4e7-b706-5e70-84b6-eaa665020394'::uuid then
    raise exception 'Тест a1-m04 прив’язаний не до модуля A1.4 — звірте базу';
  end if;
  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
          v_payload, 'assessment_rebuild_20261119: перевірку зібрано наново після плану «Дублі й сенс уроків» — старі завдання');
  select (coalesce(max(order_index), 0) / 100 + 1) * 100 into v_shift from public.assessment_items where assessment_id = v_aid;
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + v_shift
   where assessment_id = v_aid and status = 'PUBLISHED';
  update public.assessments set description_ua = 'Після модуля: 20 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~10 хв.', estimated_minutes = 10 where id = v_aid;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, answer_alternatives, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('8608fe47-7921-57c6-86d7-ba5daaa6fbe4', v_aid, 1, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Так, квиток в один бік і бронювання місця.", "Є, але він дорожчий — двадцять п’ять євро.", "Добре. До п’ятниці все буде готово."]'::jsonb, 2, null, '{}'::text[], 'Može. Sve je gotovo do petka.', null, null, 'Прозвучало: «Može. Sve je gotovo do petka.» — «Добре. До п’ятниці все буде готово.».', (select id from public.lessons where id = 'cd5db261-a421-511d-8100-f86bf2335bbe'), 'PUBLISHED', 'claude_assessment_v5'),
  ('00e6e03e-b5d3-56b9-856d-30e0712cb26c', v_aid, 2, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Можна. За багажне відділення беремо два євро.", "Мені здається, у нього блохи.", "Добрий день. Ваш паспорт, будь ласка."]'::jsonb, 2, null, '{}'::text[], 'Dobar dan. Vašu putovnicu, molim.', null, null, 'Прозвучало: «Dobar dan. Vašu putovnicu, molim.» — «Добрий день. Ваш паспорт, будь ласка.».', (select id from public.lessons where id = '69ec0776-4f69-5f86-afac-6652234a7da5'), 'PUBLISHED', 'claude_assessment_v5'),
  ('3163834b-2f69-5e62-a163-db453664965a', v_aid, 3, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Можна, але це перша зона, щонайбільше дві години.", "Є, о десятій, без пересадки.", "Зупиніться перед готелем і почекайте мене п’ять хвилин."]'::jsonb, 0, null, '{}'::text[], 'Smijete, ali ovo je prva zona, najviše dva sata.', null, null, 'Прозвучало: «Smijete, ali ovo je prva zona, najviše dva sata.» — «Можна, але це перша зона, щонайбільше дві години.».', (select id from public.lessons where id = 'd6ca64d8-4c71-5936-a930-51e400f5681d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('028587f4-67e3-5079-ae01-26a3d1e6e330', v_aid, 4, 'A1', 'reading', 'understand', 'multiple_choice', 'Коли паркування безкоштовне?', 'Parkiranje u gradu', '["У суботу", "У неділю та у свята", "Щодня після 15"]'::jsonb, 1, null, '{}'::text[], null, 'ZONA 1 – PARKIRANJE SE PLAĆA
Ponedjeljak – petak: od 7 do 21 sat
Subota: od 7 do 15 sati
Nedjeljom i praznikom parkiranje je besplatno.
Najduže dva sata. Cijena: 1,60 € na sat.
Platite na automatu ili SMS-om. Bez karte – kazna!', 'ЗОНА 1 – ПАРКУВАННЯ ПЛАТНЕ
Понеділок – п’ятниця: з 7 до 21 години
Субота: з 7 до 15 години
У неділю та у свята паркування безкоштовне.
Найдовше дві години. Ціна: 1,60 € за годину.
Платіть в автоматі або через SMS. Без квитка — штраф!', 'Текст «Паркування в місті». Правильна відповідь: «У неділю та у свята».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('2a091165-0678-578c-811c-c44ffa127a90', v_aid, 5, 'A1', 'reading', 'understand', 'multiple_choice', 'Коли авто має бути в порту?', 'Ljetni red plovidbe', '["За п’ять хвилин", "За пів години до відправлення", "За дві години"]'::jsonb, 1, null, '{}'::text[], null, 'Od lipnja do rujna trajekti iz Splita za Brač voze svaki sat, od pet ujutro do ponoći. Ljeti je velika gužva, zato putnici trebaju kupiti karte na internetu. Auti moraju biti u luci pola sata prije polaska. Pješaci mogu doći petnaest minuta prije.', 'З червня до вересня пороми зі Спліта на Брач ходять щогодини, з п’ятої ранку до опівночі. Улітку велика черга, тому пасажирам треба купувати квитки в інтернеті. Автомобілі мають бути в порту за пів години до відправлення. Пішоходи можуть прийти за п’ятнадцять хвилин до відправлення.', 'Текст «Літній розклад поромів». Правильна відповідь: «За пів години до відправлення».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('c6133fa8-1350-5686-840a-80fd73cef9b4', v_aid, 6, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Gdje mogu platiti gorivo?', '["Unutra na blagajni, karticom ili gotovinom.", "Treba. Uzmi metlu i krpu, hvala što mi pomažeš!", "Zagrij pećnicu na sto osamdeset i peci ga četrdeset minuta."]'::jsonb, 0, null, '{}'::text[], 'Gdje mogu platiti gorivo?', null, null, 'Діалог «На заправці»: «Gdje mogu platiti gorivo?» (Де можна заплатити за пальне?) — «Unutra na blagajni, karticom ili gotovinom.» (Усередині на касі, карткою чи готівкою.).', (select id from public.lessons where id = 'd6ca64d8-4c71-5936-a930-51e400f5681d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('a0913753-fa0f-5978-adc4-c52a60191b44', v_aid, 7, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Kolika je cijena vožnje do zračne luke?', '["Više ne, sada radim u školi.", "Ponekad, jer sam stalno iscrpljena.", "Oko trideset eura, prema taksimetru."]'::jsonb, 2, null, '{}'::text[], 'Kolika je cijena vožnje do zračne luke?', null, null, 'Діалог «Викликаю таксі»: «Kolika je cijena vožnje do zračne luke?» (Скільки коштує поїздка до аеропорту?) — «Oko trideset eura, prema taksimetru.» (Близько тридцяти євро, за таксометром.).', (select id from public.lessons where id = '458ee6ec-31d1-5758-adef-03612626088a'), 'PUBLISHED', 'claude_assessment_v5'),
  ('757f7153-ef3c-551d-bf3c-e046173bc791', v_aid, 8, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Je li dnevna karta važeća i u autobusu?', '["Za pola sata. Pratim pošiljku u aplikaciji.", "Jest, do ponoći, i tramvajem i autobusom.", "Na ime Kovalenko. Hvala!"]'::jsonb, 1, null, '{}'::text[], 'Je li dnevna karta važeća i u autobusu?', null, null, 'Діалог «У трамваї»: «Je li dnevna karta važeća i u autobusu?» (Денний квиток дійсний і в автобусі?) — «Jest, do ponoći, i tramvajem i autobusom.» (Так, до опівночі — і трамваєм, і автобусом.).', (select id from public.lessons where id = '0ef458c5-53cf-530a-99cf-4ccd6e0132e5'), 'PUBLISHED', 'claude_assessment_v5'),
  ('42e3bad3-e001-5651-b41f-88df2c2903ae', v_aid, 9, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'U četiri popodne. Želite li drugi razred?', '["Da, jednosmjernu kartu i rezervaciju sjedala.", "Gotovo ista. Druga je skuplja zbog imena.", "Trebaš. I obuj nepromočive čizme, pada snijeg."]'::jsonb, 0, null, '{}'::text[], 'U četiri popodne. Želite li drugi razred?', null, null, 'Діалог «На касі вокзалу»: «U četiri popodne. Želite li drugi razred?» (О четвертій дня. Бажаєте другий клас?) — «Da, jednosmjernu kartu i rezervaciju sjedala.» (Так, квиток в один бік і бронювання місця.).', (select id from public.lessons where id = 'cae7a47d-7fb4-5b03-a8cc-5a0df2ccd92f'), 'PUBLISHED', 'claude_assessment_v5'),
  ('326299d6-07c1-514d-91e2-7edf1b056428', v_aid, 10, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Dobar dan, koliko košta iznajmljivanje bicikla na dan?', '["Покажи. Треба його накачати, у мене є насос.", "П’ятнадцять євро, із шоломом і замком.", "Працюють. Перевірте й дзвоник перед поїздкою."]'::jsonb, 1, null, '{}'::text[], null, 'Daša: Dobar dan, koliko košta iznajmljivanje bicikla na dan?
Radnik: Petnaest eura, s kacigom i lokotom.
Daša: Imate li i električni bicikl?
Radnik: Imamo, ali je skuplji, dvadeset pet eura.
Daša: Dobro, uzimam obični. Rade li kočnice?
Radnik: Rade. Provjerite i zvonce prije vožnje.', 'Daša: Добрий день, скільки коштує прокат велосипеда на день?
Radnik: П’ятнадцять євро, із шоломом і замком.
Daša: У вас є й електровелосипед?
Radnik: Є, але він дорожчий — двадцять п’ять євро.
Daša: Добре, беру звичайний. Гальма працюють?
Radnik: Працюють. Перевірте й дзвоник перед поїздкою.', 'Діалог «Прокат велосипедів»: «Dobar dan, koliko košta iznajmljivanje bicikla na dan?» — «Petnaest eura, s kacigom i lokotom.», тобто «П’ятнадцять євро, із шоломом і замком.».', (select id from public.lessons where id = '0b04119b-4d38-5d99-8237-caa95fdcfd95'), 'PUBLISHED', 'claude_assessment_v5'),
  ('c6de6f6e-d893-584c-8326-d9e852a18d18', v_aid, 11, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Dašo, koliko je još do izlaza za Zadar?', '["Близько п’ятдесяти кілометрів. Обережно, тут дорожні роботи.", "По радіо кажуть, що в лівій смузі зіткнення.", "Тоді зупинимося на першій зоні відпочинку."]'::jsonb, 0, null, '{}'::text[], null, 'Luka: Dašo, koliko je još do izlaza za Zadar?
Daša: Oko pedeset kilometara. Pazi, ovdje su radovi na cesti.
Luka: Vidim znak, ograničenje je osamdeset.
Daša: Na radiju kažu da je sudar u lijevoj traci.
Luka: Onda stajemo na prvom odmorištu.
Daša: Dobro, ionako trebam kavu.', 'Luka: Дашо, скільки ще до з’їзду на Задар?
Daša: Близько п’ятдесяти кілометрів. Обережно, тут дорожні роботи.
Luka: Бачу знак, обмеження — вісімдесят.
Daša: По радіо кажуть, що в лівій смузі зіткнення.
Luka: Тоді зупинимося на першій зоні відпочинку.
Daša: Добре, мені однаково треба кави.', 'Діалог «Магістраллю на море»: «Dašo, koliko je još do izlaza za Zadar?» — «Oko pedeset kilometara. Pazi, ovdje su radovi na cesti.», тобто «Близько п’ятдесяти кілометрів. Обережно, тут дорожні роботи.».', (select id from public.lessons where id = '06f927cf-f38c-51b5-a1f9-696698ad23fb'), 'PUBLISHED', 'claude_assessment_v5'),
  ('0c024ba4-b116-5e9d-8c02-cdd0b8864fde', v_aid, 12, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Oprostite, kuda se ide na plažu?', '["Так, або автобусом номер два, він їде сюди до площі.", "Ні, десять хвилин пішки.", "Ідіть прямо, а потім у бік церкви."]'::jsonb, 2, null, '{}'::text[], null, 'Darja: Oprostite, kuda se ide na plažu?
Prolaznik: Idite naprijed, pa prema crkvi.
Darja: Je li plaža daleko odavde?
Prolaznik: Nije, deset minuta pješice.
Darja: A natrag? Isto ovim putem?
Prolaznik: Da, ili autobusom broj dva, vozi ovamo do trga.', 'Darja: Перепрошую, як пройти на пляж?
Prolaznik: Ідіть прямо, а потім у бік церкви.
Darja: Пляж далеко звідси?
Prolaznik: Ні, десять хвилин пішки.
Darja: А назад? Так само цією дорогою?
Prolaznik: Так, або автобусом номер два, він їде сюди до площі.', 'Діалог «Як пройти на пляж?»: «Oprostite, kuda se ide na plažu?» — «Idite naprijed, pa prema crkvi.», тобто «Ідіть прямо, а потім у бік церкви.».', (select id from public.lessons where id = '12012395-7359-503b-89c9-ee1807f89d6b'), 'PUBLISHED', 'claude_assessment_v5'),
  ('7069c282-f018-5a47-ad1c-2190a6dfee62', v_aid, 13, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Я йду в місто». Що ви скажете?', null, '["Mogu li dobiti sjedalo do prolaza?", "Idem u grad.", "Pun rezervoar, molim."]'::jsonb, 1, null, '{}'::text[], null, null, null, '«Я йду в місто.» — «Idem u grad.».', (select id from public.lessons where id = '12012395-7359-503b-89c9-ee1807f89d6b'), 'PUBLISHED', 'claude_assessment_v5'),
  ('ef240d70-a96f-52a1-b9c6-a76f643a555b', v_aid, 14, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Візьми шолом і замок». Що ви скажете?', null, '["Moram nadoplatiti pokaznu kartu.", "Gdje je traka za prtljagu?", "Uzmi kacigu i lokot."]'::jsonb, 2, null, '{}'::text[], null, null, null, '«Візьми шолом і замок.» — «Uzmi kacigu i lokot.».', (select id from public.lessons where id = '0b04119b-4d38-5d99-8237-caa95fdcfd95'), 'PUBLISHED', 'claude_assessment_v5'),
  ('6f623630-af99-5146-92c9-9a659aca8855', v_aid, 15, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «обганяти»', null, '[]'::jsonb, null, 'pretjecati', '{}'::text[], null, null, null, '«обганяти» — pretjecati.', (select id from public.lessons where id = '06f927cf-f38c-51b5-a1f9-696698ad23fb'), 'PUBLISHED', 'claude_assessment_v5'),
  ('c7f60d47-a169-51a6-8045-e75744164ef0', v_aid, 16, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «ручна поклажа»', null, '[]'::jsonb, null, 'ručna prtljaga', '{}'::text[], null, null, null, '«ручна поклажа» — ručna prtljaga.', (select id from public.lessons where id = '69ec0776-4f69-5f86-afac-6652234a7da5'), 'PUBLISHED', 'claude_assessment_v5'),
  ('a6b4e70a-4a17-5837-a398-87187fb9e941', v_aid, 17, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Коли прибуває потяг?»', null, '["stiže", "vlak?", "Kada"]'::jsonb, null, 'Kada stiže vlak?', array['Kada vlak stiže?']::text[], null, null, null, '«Коли прибуває потяг?» — «Kada stiže vlak?».', (select id from public.lessons where id = 'cae7a47d-7fb4-5b03-a8cc-5a0df2ccd92f'), 'PUBLISHED', 'claude_assessment_v5'),
  ('112fa59f-9385-5bf1-8d72-71bae57bc5e8', v_aid, 18, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Це моя валіза.»', null, '["Ovo", "moj", "kofer.", "je"]'::jsonb, null, 'Ovo je moj kofer.', '{}'::text[], null, null, null, '«Це моя валіза.» — «Ovo je moj kofer.».', (select id from public.lessons where id = '69ec0776-4f69-5f86-afac-6652234a7da5'), 'PUBLISHED', 'claude_assessment_v5'),
  ('9722f66d-c24d-5351-aa21-3aa900c3c34c', v_aid, 19, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Мені треба заправити бак.»', null, '["natočiti", "Moram", "gorivo."]'::jsonb, null, 'Moram natočiti gorivo.', '{}'::text[], null, null, null, '«Мені треба заправити бак.» — «Moram natočiti gorivo.».', (select id from public.lessons where id = 'd6ca64d8-4c71-5936-a930-51e400f5681d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('ea79bb5f-cd4d-5077-940a-74d7ca9c1480', v_aid, 20, 'A1', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Ти вже на роботі?»', null, '[]'::jsonb, null, 'Jesi li već na poslu?', '{}'::text[], null, null, null, '«Ти вже на роботі?» — «Jesi li već na poslu?».', (select id from public.lessons where id = '12012395-7359-503b-89c9-ee1807f89d6b'), 'PUBLISHED', 'claude_assessment_v5');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірки рівня A1 наново за схемою 2026-11-07 після плану «Дублі й сенс уроків» (PR 3–4) — завдання й хибні варіанти лише з уроків і текстів, які є в курсі зараз (задача власника 2026-11-19). Потрібна перевірка носієм.');
end $$;

-- Перевірка модуля A1.5 · 20 завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = 'a1-m05' and cefr = 'A1';
  if v_aid is null then raise exception 'Немає тесту a1-m05 — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = 'e5a2a0ed-e218-591b-aaf1-bc39a539db14') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from '82ce9ca7-ea90-5413-94a6-d69b1a1cd72b'::uuid then
    raise exception 'Тест a1-m05 прив’язаний не до модуля A1.5 — звірте базу';
  end if;
  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
          v_payload, 'assessment_rebuild_20261119: перевірку зібрано наново після плану «Дублі й сенс уроків» — старі завдання');
  select (coalesce(max(order_index), 0) / 100 + 1) * 100 into v_shift from public.assessment_items where assessment_id = v_aid;
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + v_shift
   where assessment_id = v_aid and status = 'PUBLISHED';
  update public.assessments set description_ua = 'Після модуля: 20 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~10 хв.', estimated_minutes = 10 where id = v_aid;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, answer_alternatives, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('e5a2a0ed-e218-591b-aaf1-bc39a539db14', v_aid, 1, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Запобіжник у порядку. Може, коротке замикання.", "Здебільшого так, цей житловий будинок спокійний.", "Спочатку фарбуємо стелю, потім стіни."]'::jsonb, 0, null, '{}'::text[], 'Osigurač je u redu. Možda je kratki spoj.', null, null, 'Прозвучало: «Osigurač je u redu. Možda je kratki spoj.» — «Запобіжник у порядку. Може, коротке замикання.».', (select id from public.lessons where id = '8fc3399d-0405-5517-9358-d3ad6308d860'), 'PUBLISHED', 'claude_assessment_v5'),
  ('257a317b-59b8-5ce0-abd2-e8ad8fbb53ce', v_aid, 2, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Добре. І постав термостат на двадцять два.", "Так, і напиши на коробці: «Обережно, крихке!»", "Тримай. Для картин вистачить молотка й цвяха."]'::jsonb, 2, null, '{}'::text[], 'Izvoli. Za slike je dosta čekić i čavao.', null, null, 'Прозвучало: «Izvoli. Za slike je dosta čekić i čavao.» — «Тримай. Для картин вистачить молотка й цвяха.».', (select id from public.lessons where id = 'dd2c0f3c-19f2-5c73-b448-a0631cd97e69'), 'PUBLISHED', 'claude_assessment_v5'),
  ('2a8054b6-da1b-50aa-9537-e8c414199652', v_aid, 3, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Це ремонтує завгосп, треба замінити лампочку.", "Можна. Довкола фонтана — найгарніша частина міста.", "Так. Потримай драбину, будь ласка, а я свердлитиму."]'::jsonb, 1, null, '{}'::text[], 'Može. Okolica fontane je najljepši dio grada.', null, null, 'Прозвучало: «Može. Okolica fontane je najljepši dio grada.» — «Можна. Довкола фонтана — найгарніша частина міста.».', (select id from public.lessons where id = '3ea9520d-2baa-56b2-aa85-402e3e3ecb9b'), 'PUBLISHED', 'claude_assessment_v5'),
  ('d8d5ab61-41d7-5217-9090-058771aa8fa3', v_aid, 4, 'A1', 'reading', 'understand', 'multiple_choice', 'Коли Олена вдома?', 'Poruka stanodavcu', '["Цілий день", "Лише ввечері", "Лише вранці"]'::jsonb, 0, null, '{}'::text[], null, 'Dobar dan, gospodine Horvat,
grijanje u stanu opet ne radi. Radijatori su hladni od jučer, a vani je vrlo hladno. Djeca su bolesna. Možete li danas poslati majstora? Mi smo kod kuće cijeli dan.
Hvala,
Olena Kovalenko, stan broj 4', 'Добрий день, пане Горват,
опалення в квартирі знову не працює. Батареї холодні з учорашнього дня, а надворі дуже холодно. Діти хворі. Чи можете ви сьогодні прислати майстра? Ми вдома цілий день.
Дякую,
Олена Коваленко, квартира номер 4', 'Текст «Повідомлення орендодавцю». Правильна відповідь: «Цілий день».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('227ea469-89a6-553e-bb2d-a893daa85505', v_aid, 5, 'A1', 'reading', 'understand', 'multiple_choice', 'Скільки кімнат у квартирі?', 'Oglas: stan za najam', '["Три", "Дві", "Одна"]'::jsonb, 1, null, '{}'::text[], null, 'IZNAJMLJUJEM STAN
Dvosoban stan, 55 m², drugi kat, Trešnjevka.
Namješten, s balkonom i perilicom rublja.
Najamnina: 650 € mjesečno + režije.
Polog: jedna najamnina.
Blizu tramvaja, škole i trgovine.
Kućni ljubimci nisu dopušteni.
Zovite na 091 234 5678.', 'ЗДАЮ КВАРТИРУ
Двокімнатна квартира, 55 м², другий поверх, Трешнєвка.
Мебльована, з балконом і пральною машиною.
Орендна плата: 650 € на місяць + комунальні.
Застава: одна орендна плата.
Поруч трамвай, школа й магазин.
Домашні тварини заборонені.
Телефонуйте на 091 234 5678.', 'Текст «Оголошення: квартира в оренду». Правильна відповідь: «Дві».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('8f75f2db-8cb9-58c7-b739-1330d118b2f8', v_aid, 6, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Dašo, kako ti je novi kvart?', '["Stavim piletinu u veliki lonac i zakuham vodu.", "Više ne, sada radim u školi.", "Odličan! U blizini su dućan, kiosk i pekara."]'::jsonb, 2, null, '{}'::text[], 'Dašo, kako ti je novi kvart?', null, null, 'Діалог «Що в тебе поруч?»: «Dašo, kako ti je novi kvart?» (Дашо, як тобі новий район?) — «Odličan! U blizini su dućan, kiosk i pekara.» (Чудовий! Поруч магазин, кіоск і пекарня.).', (select id from public.lessons where id = '3ea9520d-2baa-56b2-aa85-402e3e3ecb9b'), 'PUBLISHED', 'claude_assessment_v5'),
  ('6d74d9a8-32da-53c7-b944-7dc07b80f44a', v_aid, 7, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Gdje je ovdje pješačka zona?', '["Trebaš. I obuj nepromočive čizme, pada snijeg.", "Idite naprijed, pa prema crkvi.", "Odmah iza spomenika počinje stara jezgra."]'::jsonb, 2, null, '{}'::text[], 'Gdje je ovdje pješačka zona?', null, null, 'Діалог «Прогулянка старим містом»: «Gdje je ovdje pješačka zona?» (Де тут пішохідна зона?) — «Odmah iza spomenika počinje stara jezgra.» (Одразу за пам’ятником починається старе місто.).', (select id from public.lessons where id = '3ea9520d-2baa-56b2-aa85-402e3e3ecb9b'), 'PUBLISHED', 'claude_assessment_v5'),
  ('d4a412e5-c2eb-5655-8f65-66c195d4e2c6', v_aid, 8, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Gdje bacamo otpad?', '["Kontejneri su iza zgrade. Papir i plastiku odvajamo.", "Napravi mi kajganu i jedan tost, molim te.", "Ružmarin i češnjak. Meso posoli i popapri."]'::jsonb, 0, null, '{}'::text[], 'Gdje bacamo otpad?', null, null, 'Діалог «Сміття й переробка»: «Gdje bacamo otpad?» (Куди викидаємо сміття?) — «Kontejneri su iza zgrade. Papir i plastiku odvajamo.» (Контейнери за будинком. Папір і пластик сортуємо.).', (select id from public.lessons where id = 'f296bc84-8059-5981-a5b9-9d4531627e18'), 'PUBLISHED', 'claude_assessment_v5'),
  ('082a019f-fe26-57ea-bd8b-91bd373eb70b', v_aid, 9, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Dašo, gdje su upute za komodu?', '["S drugog, ali danas kasni dvadeset minuta.", "U kutiji, na dnu. I vijci su u maloj vrećici.", "Izlaz sedam. Evo vaše ukrcajne propusnice."]'::jsonb, 1, null, '{}'::text[], 'Dašo, gdje su upute za komodu?', null, null, 'Діалог «Збираємо комод»: «Dašo, gdje su upute za komodu?» (Дашо, де інструкція до комода?) — «U kutiji, na dnu. I vijci su u maloj vrećici.» (У коробці, на дні. І гвинти в маленькому пакетику.).', (select id from public.lessons where id = 'de93d3ab-6769-5daf-9560-8858285a8136'), 'PUBLISHED', 'claude_assessment_v5'),
  ('13ee62a4-c76d-5cc9-99ec-e1a05e18feeb', v_aid, 10, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Kada je rok plaćanja?', '["До п’ятнадцятого. Зараз заплачу через мобільний банкінг.", "Скільки? Цього літа в нас велике споживання.", "Тридцять євро. А вивіз сміття — окремо."]'::jsonb, 0, null, '{}'::text[], null, 'Luka: Dašo, evo računa za vodu.
Daša: Koliko je? Potrošnja nam je velika ovo ljeto.
Luka: Trideset eura. A odvoz smeća je posebno.
Daša: Kada je rok plaćanja?
Luka: Do petnaestog. Platim ga odmah mobilnim bankarstvom.
Daša: Bolje napravi trajni nalog, pa nema opomena.', 'Luka: Дашо, ось рахунок за воду.
Daša: Скільки? Цього літа в нас велике споживання.
Luka: Тридцять євро. А вивіз сміття — окремо.
Daša: Коли термін оплати?
Luka: До п’ятнадцятого. Зараз заплачу через мобільний банкінг.
Daša: Краще зроби автоплатіж, тоді не буде нагадувань.', 'Діалог «Рахунки за місяць»: «Kada je rok plaćanja?» — «Do petnaestog. Platim ga odmah mobilnim bankarstvom.», тобто «До п’ятнадцятого. Зараз заплачу через мобільний банкінг.».', (select id from public.lessons where id = 'b69a8cca-4918-562f-8ae5-22f8d7ba2f76'), 'PUBLISHED', 'claude_assessment_v5'),
  ('64e5ef0f-2904-5ec3-8d38-1190236a9fe6', v_aid, 11, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Kada se moramo iseliti iz starog stana?', '["Склянки треба пакувати окремо, вони крихкі.", "Дякую! Якщо вам щось треба, стукайте без вагань.", "До кінця місяця. Компанія з перевезень приїде в суботу."]'::jsonb, 2, null, '{}'::text[], null, 'Luka: Kada se moramo iseliti iz starog stana?
Daša: Do kraja mjeseca. Selidbena tvrtka dolazi u subotu.
Luka: Imamo li dovoljno kartonskih kutija?
Daša: Nemamo, a trebamo i ljepljivu traku.
Luka: Čaše moramo pakirati posebno, lomljive su.
Daša: Da, i na kutiju napiši: «Pažljivo, lomljivo!»', 'Luka: Коли нам треба виїхати зі старої квартири?
Daša: До кінця місяця. Компанія з перевезень приїде в суботу.
Luka: У нас вистачає картонних коробок?
Daša: Ні, і ще потрібен скотч.
Luka: Склянки треба пакувати окремо, вони крихкі.
Daša: Так, і напиши на коробці: «Обережно, крихке!»', 'Діалог «Готуємося до переїзду»: «Kada se moramo iseliti iz starog stana?» — «Do kraja mjeseca. Selidbena tvrtka dolazi u subotu.», тобто «До кінця місяця. Компанія з перевезень приїде в суботу.».', (select id from public.lessons where id = '23f3aad6-4447-5b75-9dd1-891773457f7e'), 'PUBLISHED', 'claude_assessment_v5'),
  ('a9122483-2455-5b38-8d43-638b3276d456', v_aid, 12, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Mogu. Imaš li kombi?', '["Є, але я не можу сама перенести шафу.", "Добре, але спочатку піца!", "Без проблем, удвох ми її піднімемо."]'::jsonb, 0, null, '{}'::text[], null, 'Darja: Marko, možeš li mi pomoći u subotu? Selim se.
Marko: Mogu. Imaš li kombi?
Darja: Imam, ali ne mogu sama prenijeti ormar.
Marko: Nema problema, nas dvoje ga možemo podići.
Darja: Hvala ti! Poslije moramo sve raspakirati.
Marko: Može, ali prvo pizza!', 'Darja: Марку, можеш мені допомогти в суботу? Я переїжджаю.
Marko: Можу. У тебе є бус?
Darja: Є, але я не можу сама перенести шафу.
Marko: Без проблем, удвох ми її піднімемо.
Darja: Дякую! Потім треба все розпакувати.
Marko: Добре, але спочатку піца!', 'Діалог «Допоможеш?»: «Mogu. Imaš li kombi?» — «Imam, ali ne mogu sama prenijeti ormar.», тобто «Є, але я не можу сама перенести шафу.».', (select id from public.lessons where id = '23f3aad6-4447-5b75-9dd1-891773457f7e'), 'PUBLISHED', 'claude_assessment_v5'),
  ('9eb633db-9f97-58a5-9a50-1afd1f033029', v_aid, 13, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Наш район тихий і безпечний». Що ви скажете?', null, '["Naš kvart je miran i siguran.", "Upali ventilator.", "Slavina curi."]'::jsonb, 0, null, '{}'::text[], null, null, null, '«Наш район тихий і безпечний.» — «Naš kvart je miran i siguran.».', (select id from public.lessons where id = '3ea9520d-2baa-56b2-aa85-402e3e3ecb9b'), 'PUBLISHED', 'claude_assessment_v5'),
  ('1329ef46-2d89-5750-85ff-6ffe8068e441', v_aid, 14, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Де правила будинку?». Що ви скажете?', null, '["Treba nam blagovaonski stol.", "Gdje je kućni red?", "Selim se u subotu."]'::jsonb, 1, null, '{}'::text[], null, null, null, '«Де правила будинку?» — «Gdje je kućni red?».', (select id from public.lessons where id = 'f296bc84-8059-5981-a5b9-9d4531627e18'), 'PUBLISHED', 'claude_assessment_v5'),
  ('67e1dd33-a439-5051-bb29-833582f82501', v_aid, 15, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «вибачитися»', null, '[]'::jsonb, null, 'ispričati se', '{}'::text[], null, null, null, '«вибачитися» — ispričati se.', (select id from public.lessons where id = 'a42b9121-2ec0-5064-909b-f59f315b3c4a'), 'PUBLISHED', 'claude_assessment_v5'),
  ('d5c6ebd3-a1ef-5125-ba59-c6ef24839307', v_aid, 16, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «зливний бачок»', null, '[]'::jsonb, null, 'vodokotlić', '{}'::text[], null, null, null, '«зливний бачок» — vodokotlić.', (select id from public.lessons where id = '8fc3399d-0405-5517-9358-d3ad6308d860'), 'PUBLISHED', 'claude_assessment_v5'),
  ('b68eb41a-54b7-5c9d-af7b-ddf52926f378', v_aid, 17, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Потримай драбину, будь ласка.»', null, '["ljestve,", "Drži", "molim", "te."]'::jsonb, null, 'Drži ljestve, molim te.', array['Molim te, drži ljestve.']::text[], null, null, null, '«Потримай драбину, будь ласка.» — «Drži ljestve, molim te.».', (select id from public.lessons where id = 'dd2c0f3c-19f2-5c73-b448-a0631cd97e69'), 'PUBLISHED', 'claude_assessment_v5'),
  ('7dee189e-fe87-560a-9fd3-880aa1650ad9', v_aid, 18, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Треба провітрити ванну.»', null, '["kupaonicu.", "prozračiti", "Treba"]'::jsonb, null, 'Treba prozračiti kupaonicu.', array['Kupaonicu treba prozračiti.']::text[], null, null, null, '«Треба провітрити ванну.» — «Treba prozračiti kupaonicu.».', (select id from public.lessons where id = '62b118f9-a5e0-587b-82f8-39de181ddeba'), 'PUBLISHED', 'claude_assessment_v5'),
  ('fcad656e-cc1a-5448-9477-744f99c0769c', v_aid, 19, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Подай мені викрутку.»', null, '["Dodaj", "odvijač.", "mi"]'::jsonb, null, 'Dodaj mi odvijač.', '{}'::text[], null, null, null, '«Подай мені викрутку.» — «Dodaj mi odvijač.».', (select id from public.lessons where id = 'dd2c0f3c-19f2-5c73-b448-a0631cd97e69'), 'PUBLISHED', 'claude_assessment_v5'),
  ('15b4d325-3418-51c3-b852-2f0d24d62336', v_aid, 20, 'A1', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Яка застава?»', null, '[]'::jsonb, null, 'Koliki je polog?', '{}'::text[], null, null, null, '«Яка застава?» — «Koliki je polog?».', (select id from public.lessons where id = '278947e3-ae50-5818-abd7-7f07b8ab5c44'), 'PUBLISHED', 'claude_assessment_v5');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірки рівня A1 наново за схемою 2026-11-07 після плану «Дублі й сенс уроків» (PR 3–4) — завдання й хибні варіанти лише з уроків і текстів, які є в курсі зараз (задача власника 2026-11-19). Потрібна перевірка носієм.');
end $$;

-- Перевірка модуля A1.6 · 18 завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = 'a1-m06' and cefr = 'A1';
  if v_aid is null then raise exception 'Немає тесту a1-m06 — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = '64890629-186b-512b-8303-bba8e4cf5c55') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from '03c65998-2648-5d02-9254-f67ce765fe27'::uuid then
    raise exception 'Тест a1-m06 прив’язаний не до модуля A1.6 — звірте базу';
  end if;
  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
          v_payload, 'assessment_rebuild_20261119: перевірку зібрано наново після плану «Дублі й сенс уроків» — старі завдання');
  select (coalesce(max(order_index), 0) / 100 + 1) * 100 into v_shift from public.assessment_items where assessment_id = v_aid;
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + v_shift
   where assessment_id = v_aid and status = 'PUBLISHED';
  update public.assessments set description_ua = 'Після модуля: 18 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~9 хв.', estimated_minutes = 9 where id = v_aid;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, answer_alternatives, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('64890629-186b-512b-8303-bba8e4cf5c55', v_aid, 1, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["У тебе багато обов’язків?", "Я переїжджаю. Це оплачувана відпустка?", "Даріє, ти працюєш з дому?"]'::jsonb, 1, null, '{}'::text[], 'Selim se. Je li to plaćeni dopust?', null, null, 'Прозвучало: «Selim se. Je li to plaćeni dopust?» — «Я переїжджаю. Це оплачувана відпустка?».', (select id from public.lessons where id = '99088d92-0f0c-52c2-b51f-548d903fc9ef'), 'PUBLISHED', 'claude_assessment_v5'),
  ('746007fb-3775-55b1-a64a-d69253d57fc2', v_aid, 2, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Ти отримала лікарняний лист?", "Він працює позмінно?", "Мені доведеться працювати позмінно?"]'::jsonb, 1, null, '{}'::text[], 'Radi li u smjenama?', null, null, 'Прозвучало: «Radi li u smjenama?» — «Він працює позмінно?».', (select id from public.lessons where id = 'b369f01f-4a84-57b4-98cb-150d236f4d7f'), 'PUBLISHED', 'claude_assessment_v5'),
  ('88e1d4f3-87c0-5a22-87b2-df52d19ae8af', v_aid, 3, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Де ти перевдягнувся?", "Даріє, що ти робиш у готелі?", "Коли можете почати?"]'::jsonb, 1, null, '{}'::text[], 'Darja, što radiš u hotelu?', null, null, 'Прозвучало: «Darja, što radiš u hotelu?» — «Даріє, що ти робиш у готелі?».', (select id from public.lessons where id = 'b369f01f-4a84-57b4-98cb-150d236f4d7f'), 'PUBLISHED', 'claude_assessment_v5'),
  ('1424e0d9-8846-5fb1-abbd-17e923b7a511', v_aid, 4, 'A1', 'reading', 'understand', 'multiple_choice', 'Що безкоштовне?', 'Oglas: sobarica u hotelu', '["Житло й харчування", "Курси англійської", "Транспорт"]'::jsonb, 0, null, '{}'::text[], null, 'HOTEL MARINA TRAŽI SOBARICU
Posao: čišćenje soba i kupaonica.
Uvjeti: sezonski posao od svibnja do listopada, puno radno vrijeme.
Satnica: 7 € neto. Smještaj i hrana su besplatni.
Iskustvo nije važno, engleski jezik je prednost.
Životopis pošaljite na posao@hotelmarina.hr.', 'ГОТЕЛЬ «МАРИНА» ШУКАЄ ПОКОЇВКУ
Робота: прибирання номерів і ванних кімнат.
Умови: сезонна робота з травня до жовтня, повний робочий день.
Погодинна оплата: 7 € чистими. Житло й харчування безкоштовні.
Досвід не важливий, англійська мова — перевага.
Резюме надсилайте на posao@hotelmarina.hr.', 'Текст «Вакансія: покоївка в готелі». Правильна відповідь: «Житло й харчування».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('b2fee0cf-0cb8-5796-80ea-e0734868c725', v_aid, 5, 'A1', 'reading', 'understand', 'multiple_choice', 'Ким працює Оксана?', 'Oksana na poslu', '["Доглядальницею", "Кухаркою", "Прибиральницею"]'::jsonb, 0, null, '{}'::text[], null, 'Oksana radi kao njegovateljica. Svako jutro dolazi kod gospođe Marije. Gospođa Marija ima osamdeset godina i živi sama. Oksana joj kuha ručak, ide s njom u šetnju i daje joj lijekove. Gospođa Marija joj priča o Zagrebu, a Oksana uči nove riječi. Posao nije lak, ali Oksana ga voli.', 'Оксана працює доглядальницею. Щоранку вона приходить до пані Марії. Пані Марії вісімдесят років, і вона живе сама. Оксана готує їй обід, ходить з нею на прогулянку й дає їй ліки. Пані Марія розповідає їй про Загреб, а Оксана вивчає нові слова. Робота не легка, але Оксана її любить.', 'Текст «Оксана на роботі». Правильна відповідь: «Доглядальницею».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('84c4dcf8-07ad-5c57-b2df-398813196c98', v_aid, 6, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Jeste li završili fakultet?', '["Volim sportsku odjeću. Visoke pete mi se ne sviđaju.", "Jesam, ekonomiju. Diplomu imam i na hrvatskom.", "Početkom tjedna imam liječnika, a u srijedu tečaj."]'::jsonb, 1, null, '{}'::text[], 'Jeste li završili fakultet?', null, null, 'Діалог «Де ви працювали раніше?»: «Jeste li završili fakultet?» (Ви закінчили університет?) — «Jesam, ekonomiju. Diplomu imam i na hrvatskom.» (Так, економічний. Диплом маю й хорватською.).', (select id from public.lessons where id = '92858dbe-ede1-5bc5-b80a-c796c5598019'), 'PUBLISHED', 'claude_assessment_v5'),
  ('7f8e2508-598c-5ddf-8379-0003e8d41860', v_aid, 7, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Moram li raditi u smjenama?', '["Nakon naplatne kućice idite obilaznicom.", "Crna je rasprodana, ali plave ima.", "Ne morate, puno radno vrijeme je od osam do četiri."]'::jsonb, 2, null, '{}'::text[], 'Moram li raditi u smjenama?', null, null, 'Діалог «Підписуємо договір»: «Moram li raditi u smjenama?» (Мені доведеться працювати позмінно?) — «Ne morate, puno radno vrijeme je od osam do četiri.» (Ні, повний робочий день — з восьмої до четвертої.).', (select id from public.lessons where id = '4d6f3498-2cc5-54a0-b4e4-c66add71ef12'), 'PUBLISHED', 'claude_assessment_v5'),
  ('c887e8c2-7bd5-59e9-a6a4-6cc47c257cf4', v_aid, 8, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Zašto ste otišli s prethodnog posla?', '["Došla sam u Hrvatsku, pa sam dala otkaz.", "Unutra na blagajni, karticom ili gotovinom.", "Riba na žaru. Potvrdit ću vam rezervaciju porukom."]'::jsonb, 0, null, '{}'::text[], 'Zašto ste otišli s prethodnog posla?', null, null, 'Діалог «Де ви працювали раніше?»: «Zašto ste otišli s prethodnog posla?» (Чому ви пішли з попередньої роботи?) — «Došla sam u Hrvatsku, pa sam dala otkaz.» (Я приїхала до Хорватії, тож звільнилася.).', (select id from public.lessons where id = '92858dbe-ede1-5bc5-b80a-c796c5598019'), 'PUBLISHED', 'claude_assessment_v5'),
  ('55dd9aab-060f-5c95-bd21-57ba02953027', v_aid, 9, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Je li voditeljica stroga?', '["Nije, ali traži da budemo točni.", "Subotom se izležavam, a nedjeljom idem na izlet.", "Jednu kavu za van i jedan čaj s limunom."]'::jsonb, 0, null, '{}'::text[], 'Je li voditeljica stroga?', null, null, 'Діалог «Як було?»: «Je li voditeljica stroga?» (Керівниця сувора?) — «Nije, ali traži da budemo točni.» (Ні, але вимагає пунктуальності.).', (select id from public.lessons where id = '2c56a486-dbbb-5102-b7cb-754c59cf94c3'), 'PUBLISHED', 'claude_assessment_v5'),
  ('16b0d08d-4513-5127-9a8f-52f773d5cb19', v_aid, 10, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Može. Trebate li i kopiju?', '["Дашо, роздрукуй мені таблицю для наради, будь ласка.", "Так, дві. Ксерокс у кінці коридору.", "Папір у шафі. І відскануй договір."]'::jsonb, 1, null, '{}'::text[], null, 'Šefica: Dašo, ispiši mi tablicu za sastanak, molim te.
Daša: Pisač opet nema papira.
Šefica: Papir je u ormaru. Skeniraj i ugovor.
Daša: Može. Trebate li i kopiju?
Šefica: Da, dvije. Fotokopirni aparat je na kraju hodnika.
Daša: Spojit ću ih spajalicom i staviti u plavu mapu.', 'Šefica: Дашо, роздрукуй мені таблицю для наради, будь ласка.
Daša: У принтері знову немає паперу.
Šefica: Папір у шафі. І відскануй договір.
Daša: Добре. Вам потрібна ще й копія?
Šefica: Так, дві. Ксерокс у кінці коридору.
Daša: Скріплю їх скріпкою й покладу в синю папку.', 'Діалог «Допоможи з документами»: «Može. Trebate li i kopiju?» — «Da, dvije. Fotokopirni aparat je na kraju hodnika.», тобто «Так, дві. Ксерокс у кінці коридору.».', (select id from public.lessons where id = 'ee016ba8-5160-581d-b440-1bcb7647173d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('f708d89d-1d2b-586d-b930-e0a93017b844', v_aid, 11, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Kada možete početi?', '["З першого числа наступного місяця.", "Є. На колишній роботі я керував командою з п’яти людей.", "Організація. Я люблю відповідальність."]'::jsonb, 0, null, '{}'::text[], null, 'Šef: Imate li iskustva s timskim radom?
Luka: Imam. Na bivšem poslu vodio sam tim od pet ljudi.
Šef: Koja je vaša najjača vještina?
Luka: Organizacija. Volim odgovornost.
Šef: Kada možete početi?
Luka: Od prvog sljedećeg mjeseca.', 'Šef: У вас є досвід командної роботи?
Luka: Є. На колишній роботі я керував командою з п’яти людей.
Šef: Яка ваша найсильніша навичка?
Luka: Організація. Я люблю відповідальність.
Šef: Коли можете почати?
Luka: З першого числа наступного місяця.', 'Діалог «Навички й досвід»: «Kada možete početi?» — «Od prvog sljedećeg mjeseca.», тобто «З першого числа наступного місяця.».', (select id from public.lessons where id = '92858dbe-ede1-5bc5-b80a-c796c5598019'), 'PUBLISHED', 'claude_assessment_v5'),
  ('3e460ebc-f79e-5eb7-8fd1-7e73b433e4a8', v_aid, 12, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Як минув перший день?». Що ви скажете?', null, '["Gdje je sala za sastanke?", "Puno sam naučio.", "Kako je bio prvi dan?"]'::jsonb, 2, null, '{}'::text[], null, null, null, '«Як минув перший день?» — «Kako je bio prvi dan?».', (select id from public.lessons where id = '2c56a486-dbbb-5102-b7cb-754c59cf94c3'), 'PUBLISHED', 'claude_assessment_v5'),
  ('a497209c-6f86-54a4-94e1-46ec23458976', v_aid, 13, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Я працюю з дому». Що ви скажете?', null, '["Radim od kuće.", "Radio sam kao vozač.", "Kada počinješ raditi?"]'::jsonb, 0, null, '{}'::text[], null, null, null, '«Я працюю з дому.» — «Radim od kuće.».', (select id from public.lessons where id = 'd813e9c0-2331-59d8-90f1-cea7e9a61c7d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('094511aa-a7eb-54e3-b632-83a984aac700', v_aid, 14, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «одужати»', null, '[]'::jsonb, null, 'ozdraviti', '{}'::text[], null, null, null, '«одужати» — ozdraviti.', (select id from public.lessons where id = 'e806dd39-4d38-5781-ad2d-949961dd95f9'), 'PUBLISHED', 'claude_assessment_v5'),
  ('34dc04e2-d4f9-5aaf-95ad-c0fe909b4ced', v_aid, 15, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «закінчувати»', null, '[]'::jsonb, null, 'završavati', '{}'::text[], null, null, null, '«закінчувати» — završavati.', (select id from public.lessons where id = 'd813e9c0-2331-59d8-90f1-cea7e9a61c7d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('781d4f09-0f5c-5fde-acbd-e24d6bb0048b', v_aid, 16, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Тобі не обов’язково працювати в суботу.»', null, '["Ne", "raditi", "moraš", "u", "subotu."]'::jsonb, null, 'Ne moraš raditi u subotu.', array['U subotu ne moraš raditi.']::text[], null, null, null, '«Тобі не обов’язково працювати в суботу.» — «Ne moraš raditi u subotu.».', (select id from public.lessons where id = '4d6f3498-2cc5-54a0-b4e4-c66add71ef12'), 'PUBLISHED', 'claude_assessment_v5'),
  ('1f002ea7-8e1d-525c-b8a7-98d0cfe3f722', v_aid, 17, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Наставник мені все пояснив.»', null, '["mi", "objasnio.", "Mentor", "je", "sve"]'::jsonb, null, 'Mentor mi je sve objasnio.', '{}'::text[], null, null, null, '«Наставник мені все пояснив.» — «Mentor mi je sve objasnio.».', (select id from public.lessons where id = '2c56a486-dbbb-5102-b7cb-754c59cf94c3'), 'PUBLISHED', 'claude_assessment_v5'),
  ('ef1c2cbd-5db2-5954-a30f-87b7d3b05c0b', v_aid, 18, 'A1', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Можна мені взяти вихідний?»', null, '[]'::jsonb, null, 'Smijem li uzeti slobodan dan?', '{}'::text[], null, null, null, '«Можна мені взяти вихідний?» — «Smijem li uzeti slobodan dan?».', (select id from public.lessons where id = '99088d92-0f0c-52c2-b51f-548d903fc9ef'), 'PUBLISHED', 'claude_assessment_v5');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірки рівня A1 наново за схемою 2026-11-07 після плану «Дублі й сенс уроків» (PR 3–4) — завдання й хибні варіанти лише з уроків і текстів, які є в курсі зараз (задача власника 2026-11-19). Потрібна перевірка носієм.');
end $$;

-- Перевірка модуля A1.7 · 14 завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = 'a1-m07' and cefr = 'A1';
  if v_aid is null then raise exception 'Немає тесту a1-m07 — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = '69666ecc-691f-58b0-8bc2-6118379bcedc') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from '09e7c668-b622-56b2-82e9-b1c0c0db54c6'::uuid then
    raise exception 'Тест a1-m07 прив’язаний не до модуля A1.7 — звірте базу';
  end if;
  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
          v_payload, 'assessment_rebuild_20261119: перевірку зібрано наново після плану «Дублі й сенс уроків» — старі завдання');
  select (coalesce(max(order_index), 0) / 100 + 1) * 100 into v_shift from public.assessment_items where assessment_id = v_aid;
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + v_shift
   where assessment_id = v_aid and status = 'PUBLISHED';
  update public.assessments set description_ua = 'Після модуля: 14 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~7 хв.', estimated_minutes = 7 where id = v_aid;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, answer_alternatives, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('69666ecc-691f-58b0-8bc2-6118379bcedc', v_aid, 1, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Видали рекламу, а важливі прочитай.", "Це полагодимо вдома. Зараз їдь повільно.", "Добрий день, мій акаунт заблоковано."]'::jsonb, 2, null, '{}'::text[], 'Dobar dan, korisnički račun mi je blokiran.', null, null, 'Прозвучало: «Dobar dan, korisnički račun mi je blokiran.» — «Добрий день, мій акаунт заблоковано.».', (select id from public.lessons where id = 'f355be7d-c423-5651-938e-71b8ca970a62'), 'PUBLISHED', 'claude_assessment_v5'),
  ('92ec5196-2c3d-5414-a08f-75c582ce9af7', v_aid, 2, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Ні, на острові немає сигналу.", "Мобільним токеном банку або ID-карткою із сертифікатом.", "Пише, що його треба перезавантажити."]'::jsonb, 0, null, '{}'::text[], 'Nisam, na otoku nema signala.', null, null, 'Прозвучало: «Nisam, na otoku nema signala.» — «Ні, на острові немає сигналу.».', (select id from public.lessons where id = '35203547-5f9a-5857-95a0-3a0d596f715d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('b00a3f34-66a9-55cc-83f5-75c1cae23c85', v_aid, 3, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Натисни «Забули пароль?».", "Мене хтось зламав? Я боюся хакерів.", "Батарея розряджена. Спершу зарядь його."]'::jsonb, 1, null, '{}'::text[], 'Je li me netko hakirao? Bojim se hakera.', null, null, 'Прозвучало: «Je li me netko hakirao? Bojim se hakera.» — «Мене хтось зламав? Я боюся хакерів.».', (select id from public.lessons where id = 'f355be7d-c423-5651-938e-71b8ca970a62'), 'PUBLISHED', 'claude_assessment_v5'),
  ('dc6d62fb-70d9-5ff8-838c-81c7cbe21c85', v_aid, 4, 'A1', 'reading', 'understand', 'multiple_choice', 'Що можна робити після входу?', 'Prijava u e-Građane', '["Бачити документи й заповнити форму", "Купувати квитки", "Дзвонити лікареві"]'::jsonb, 0, null, '{}'::text[], null, 'Kako se prijaviti u e-Građane?
1. Otvorite web-stranicu e-Građani.
2. Kliknite na «Prijava».
3. Odaberite osobnu iskaznicu ili mobilni token.
4. Unesite PIN ili kod za potvrdu.
5. Sada možete vidjeti svoje dokumente i ispuniti obrazac na internetu.', 'Як увійти в e-Građani?
1. Відкрийте сайт e-Građani.
2. Натисніть «Вхід».
3. Виберіть особисте посвідчення або мобільний токен.
4. Введіть PIN або код підтвердження.
5. Тепер ви можете бачити свої документи й заповнити форму в інтернеті.', 'Текст «Як увійти в e-Građani». Правильна відповідь: «Бачити документи й заповнити форму».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('219109f1-140f-5b1f-9707-8481a41d0fb9', v_aid, 5, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Ivana, kako mogu dobiti potvrdu o prebivalištu?', '["Preko e-Građana, ne moraš ići u ured.", "Super! Upoznala sam cijeli tim.", "Uglavnom da, ova stambena zgrada je mirna."]'::jsonb, 0, null, '{}'::text[], 'Ivana, kako mogu dobiti potvrdu o prebivalištu?', null, null, 'Діалог «Довідка через e-Građani»: «Ivana, kako mogu dobiti potvrdu o prebivalištu?» (Івано, як мені отримати довідку про місце проживання?) — «Preko e-Građana, ne moraš ići u ured.» (Через e-Građani, не треба йти в установу.).', (select id from public.lessons where id = '953e12fb-a6f6-5ae5-aa7a-ebfe248d24da'), 'PUBLISHED', 'claude_assessment_v5'),
  ('036d66aa-76fa-5faa-979a-cb202e7e9727', v_aid, 6, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Nisam. Gdje se to radi?', '["Od prvog sljedećeg mjeseca.", "Više ne, sada radim u školi.", "Klikni mišem na postavke, pa na «Ažuriranje»."]'::jsonb, 2, null, '{}'::text[], 'Nisam. Gdje se to radi?', null, null, 'Діалог «Комп’ютер гальмує»: «Nisam. Gdje se to radi?» (Ні. Де це робиться?) — «Klikni mišem na postavke, pa na «Ažuriranje».» (Клацни мишкою на налаштування, а потім на «Оновлення».).', (select id from public.lessons where id = '8e08a8e3-8969-52fc-bc82-5a403dd7ad35'), 'PUBLISHED', 'claude_assessment_v5'),
  ('ae81e833-acb6-5f25-82a5-3abc765a58b4', v_aid, 7, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Dobro, uzimam njega. Treba li mi adapter?', '["Ne treba, kabel je u kutiji.", "U Kijevu sam radila kao računovođa šest godina.", "Odlične. Dodajem je u košaricu."]'::jsonb, 0, null, '{}'::text[], 'Dobro, uzimam njega. Treba li mi adapter?', null, null, 'Діалог «Ноутбук для навчання»: «Dobro, uzimam njega. Treba li mi adapter?» (Добре, беру його. Мені потрібен перехідник?) — «Ne treba, kabel je u kutiji.» (Не потрібен, кабель у коробці.).', (select id from public.lessons where id = '31bbedca-4b51-5478-8513-df5cb996ffd9'), 'PUBLISHED', 'claude_assessment_v5'),
  ('5e8db7ef-3c56-5870-ae04-b996266c2dd7', v_aid, 8, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Jesam! Snimila si ga na Plitvicama?', '["Дякую! Тепер у мене двісті нових підписників.", "Так. Я опублікувала його вчора, і вже сто коментарів.", "Чудово, але твій профіль публічний, обережно."]'::jsonb, 1, null, '{}'::text[], null, 'Ivana: Dašo, jesi li vidjela moj novi video?
Daša: Jesam! Snimila si ga na Plitvicama?
Ivana: Da. Objavila sam ga jučer i već ima sto komentara.
Daša: Podijelila sam ga u grupi Ukrajinci u Zagrebu.
Ivana: Hvala! Sad imam dvjesto novih pratitelja.
Daša: Super, ali tvoj profil je javan, pazi.', 'Ivana: Дашо, ти бачила моє нове відео?
Daša: Так! Ти зняла його на Плітвіцях?
Ivana: Так. Я опублікувала його вчора, і вже сто коментарів.
Daša: Я поширила його в групі «Українці в Загребі».
Ivana: Дякую! Тепер у мене двісті нових підписників.
Daša: Чудово, але твій профіль публічний, обережно.', 'Діалог «Ти бачила моє відео?»: «Jesam! Snimila si ga na Plitvicama?» — «Da. Objavila sam ga jučer i već ima sto komentara.», тобто «Так. Я опублікувала його вчора, і вже сто коментарів.».', (select id from public.lessons where id = '4edd1556-f088-5d14-8f59-529b35747609'), 'PUBLISHED', 'claude_assessment_v5'),
  ('6e6c57a2-3503-5625-8c35-acc4231c6117', v_aid, 9, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Pametno. Što si zadnje objavila?', '["Допис про курси хорватської, шукаю партнера для розмов.", "Тому мій профіль приватний.", "Іноді, але не коментую."]'::jsonb, 0, null, '{}'::text[], null, 'Marko: Čitaš li vijesti na društvenim mrežama?
Darja: Ponekad, ali ne komentiram.
Marko: Ja sam jučer napisao komentar i svi su me napali.
Darja: Zato je moj profil privatan.
Marko: Pametno. Što si zadnje objavila?
Darja: Objavu o tečaju hrvatskog, tražim partnera za razgovor.', 'Marko: Ти читаєш новини в соцмережах?
Darja: Іноді, але не коментую.
Marko: А я вчора написав коментар, і всі на мене накинулися.
Darja: Тому мій профіль приватний.
Marko: Розумно. Що ти останнє опублікувала?
Darja: Допис про курси хорватської, шукаю партнера для розмов.', 'Діалог «Новини й коментарі»: «Pametno. Što si zadnje objavila?» — «Objavu o tečaju hrvatskog, tražim partnera za razgovor.», тобто «Допис про курси хорватської, шукаю партнера для розмов.».', (select id from public.lessons where id = '4edd1556-f088-5d14-8f59-529b35747609'), 'PUBLISHED', 'claude_assessment_v5'),
  ('a6193189-3362-57a3-858e-e4450637cdc0', v_aid, 10, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Мені потрібна SIM-картка». Що ви скажете?', null, '["Učitajte dokument.", "Trebam SIM karticu.", "Poslao sam ti mail."]'::jsonb, 1, null, '{}'::text[], null, null, null, '«Мені потрібна SIM-картка.» — «Trebam SIM karticu.».', (select id from public.lessons where id = '35203547-5f9a-5857-95a0-3a0d596f715d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('a2c6c0ae-b1a8-5c55-a814-a77ac6da2391', v_aid, 11, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Збережи вкладення». Що ви скажете?', null, '["Ponovno pokreni računalo.", "Spremi privitak.", "Kako mogu dobiti potvrdu preko interneta?"]'::jsonb, 1, null, '{}'::text[], null, null, null, '«Збережи вкладення.» — «Spremi privitak.».', (select id from public.lessons where id = '71537166-9f48-503f-b564-3a4f99a192c5'), 'PUBLISHED', 'claude_assessment_v5'),
  ('74b19bdd-05c4-5c63-95fd-6e965df9fc77', v_aid, 12, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «планшет»', null, '[]'::jsonb, null, 'tablet', '{}'::text[], null, null, null, '«планшет» — tablet.', (select id from public.lessons where id = '31bbedca-4b51-5478-8513-df5cb996ffd9'), 'PUBLISHED', 'claude_assessment_v5'),
  ('52bf06af-5c02-56ba-bb83-d29cc97e7778', v_aid, 13, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Спершу зарядь телефон.»', null, '["Prvo", "mobitel.", "napuni"]'::jsonb, null, 'Prvo napuni mobitel.', array['Napuni prvo mobitel.']::text[], null, null, null, '«Спершу зарядь телефон.» — «Prvo napuni mobitel.».', (select id from public.lessons where id = '8e08a8e3-8969-52fc-bc82-5a403dd7ad35'), 'PUBLISHED', 'claude_assessment_v5'),
  ('77bc10f1-619d-5de6-af96-02bab3fc6f26', v_aid, 14, 'A1', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Ти бачила моє відео?»', null, '[]'::jsonb, null, 'Jesi li vidjela moj video?', '{}'::text[], null, null, null, '«Ти бачила моє відео?» — «Jesi li vidjela moj video?».', (select id from public.lessons where id = '4edd1556-f088-5d14-8f59-529b35747609'), 'PUBLISHED', 'claude_assessment_v5');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірки рівня A1 наново за схемою 2026-11-07 після плану «Дублі й сенс уроків» (PR 3–4) — завдання й хибні варіанти лише з уроків і текстів, які є в курсі зараз (задача власника 2026-11-19). Потрібна перевірка носієм.');
end $$;

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_new int; v_bad int;
begin
  select count(*) into v_new from public.assessment_items where id in ('e1f7b598-659f-51eb-a976-02287b0be19a', '4f075458-a32f-54f0-955e-fae69b02b13f', 'b8dd2ecb-62b4-5b58-9f9b-c43e34c204db', '0efa35d0-585a-5a8a-a6bb-5f2c4438e47d', 'f24853f8-cd88-5020-8310-20fe2d9a8a20', 'c18ea603-a4c3-52cb-ac93-84658139dac5', '94a9e44c-c583-5ae0-b55c-90711fa23201', '2579b5a9-27a3-5347-aa16-931f497e2479', '1a44d65a-afe5-54d7-a396-7590dc61afc7', '5b12301b-5349-58e8-99fb-9403713ef78d', 'beabf65f-bb9a-55b9-bfa0-b77019aa670e', '2e63066e-271d-51b1-a9bc-dd5f73f90435', '663d795d-fd6b-5d92-bf4f-d5843e193fd3', '43019ee9-010d-529d-9a09-ed79cbf57a2d', '8bff161a-4c6d-5df9-a503-1344892f41aa', '1bbe3b6d-75e1-5706-bc6f-374d8c282f39', 'a2c10919-ab36-5a16-b15e-c06dbed104cd', '07a081e7-3a8e-5dc5-bbc8-ba53581e8e3b', 'fddd4816-8ffe-58f7-a6ab-9fd7b44e4141', '68bb4502-7bc1-5ce5-a8ab-b728f8d5b2d4', 'a38f632a-ab56-55db-bea6-da6f23aa7fa6', '1f0787c1-5091-5de8-80a4-5037aa1afbd9', 'fc4540cb-ecb2-5a24-9eeb-b12c241b4f16', '14e97dc5-3f39-5b7d-9880-12cd29a85636', '9d6d9cd8-67eb-594b-bb43-0dae03cffc9e', '822d1fe3-8f37-560c-b787-04c7c8191b7d', '83b68aad-4aac-5ea7-a757-2779300cef13', 'fd8b5134-2a33-582f-b021-4595b4f86ede', 'f68dc37e-cadd-5eae-84b7-5435260da40b', 'db2003e8-58f3-5665-afc7-7580155d8a3d', '657c2215-16c7-5d52-baee-3110e0966545', '57f4390d-d0e3-5648-80f0-7e59182d6032', '9aa126eb-d0df-50ba-a3ce-91ebb99c7a17', 'adb8cf49-5b3c-5b7d-877e-2bf85fa3140f', '05ad6c25-7199-5b5a-8edf-8f21eb5be2fa', 'e91f2033-c0d6-5fed-916b-e6b14e8e957c', '427c7dfc-9747-5108-9396-b54a1a622a2d', 'f59ce918-f672-5d85-ab3e-9bd3c172ffc1', 'fc1243f1-8fb7-5d79-8bc1-b714f099e61e', 'dffb0ee0-6266-5d78-abd2-9d590b12f955', '7dce849f-bf84-5341-b37e-a646e11cd73e', 'f1cab5a7-5265-503d-a869-b4ee24d498b8', '097f188c-629c-5c51-a540-cb2e8f27cd4f', '3a3d1886-74e7-5828-b1fb-8038f76fd257', 'd8f24cef-eeaf-5426-9d8a-332e1b02a28f', '95961061-d97f-538b-a608-c5ad54d26908', 'bf541529-bc7e-599a-9e4a-35da6ec0942a', 'd6349275-7289-53dd-a9bc-5858021f75b1', '7473a9ec-b810-599e-b283-755a19722fe4', 'f964acaf-b6f2-52a9-b417-d6380160b780', '2cfe1442-668e-5be2-88de-8f2f70bca499', '945943b2-263d-55e6-8233-fbe9e612591b', '9c790a32-552f-53b5-9150-f1e007ac65f9', 'c7515d41-dc3f-54a3-8810-845adb186bf0', '9ebbff80-ee90-5533-b48e-fe2500b3342d', 'b55a75ab-de2e-5e81-8991-a614b9d4581e', '8608fe47-7921-57c6-86d7-ba5daaa6fbe4', '00e6e03e-b5d3-56b9-856d-30e0712cb26c', '3163834b-2f69-5e62-a163-db453664965a', '028587f4-67e3-5079-ae01-26a3d1e6e330', '2a091165-0678-578c-811c-c44ffa127a90', 'c6133fa8-1350-5686-840a-80fd73cef9b4', 'a0913753-fa0f-5978-adc4-c52a60191b44', '757f7153-ef3c-551d-bf3c-e046173bc791', '42e3bad3-e001-5651-b41f-88df2c2903ae', '326299d6-07c1-514d-91e2-7edf1b056428', 'c6de6f6e-d893-584c-8326-d9e852a18d18', '0c024ba4-b116-5e9d-8c02-cdd0b8864fde', '7069c282-f018-5a47-ad1c-2190a6dfee62', 'ef240d70-a96f-52a1-b9c6-a76f643a555b', '6f623630-af99-5146-92c9-9a659aca8855', 'c7f60d47-a169-51a6-8045-e75744164ef0', 'a6b4e70a-4a17-5837-a398-87187fb9e941', '112fa59f-9385-5bf1-8d72-71bae57bc5e8', '9722f66d-c24d-5351-aa21-3aa900c3c34c', 'ea79bb5f-cd4d-5077-940a-74d7ca9c1480', 'e5a2a0ed-e218-591b-aaf1-bc39a539db14', '257a317b-59b8-5ce0-abd2-e8ad8fbb53ce', '2a8054b6-da1b-50aa-9537-e8c414199652', 'd8d5ab61-41d7-5217-9090-058771aa8fa3', '227ea469-89a6-553e-bb2d-a893daa85505', '8f75f2db-8cb9-58c7-b739-1330d118b2f8', '6d74d9a8-32da-53c7-b944-7dc07b80f44a', 'd4a412e5-c2eb-5655-8f65-66c195d4e2c6', '082a019f-fe26-57ea-bd8b-91bd373eb70b', '13ee62a4-c76d-5cc9-99ec-e1a05e18feeb', '64e5ef0f-2904-5ec3-8d38-1190236a9fe6', 'a9122483-2455-5b38-8d43-638b3276d456', '9eb633db-9f97-58a5-9a50-1afd1f033029', '1329ef46-2d89-5750-85ff-6ffe8068e441', '67e1dd33-a439-5051-bb29-833582f82501', 'd5c6ebd3-a1ef-5125-ba59-c6ef24839307', 'b68eb41a-54b7-5c9d-af7b-ddf52926f378', '7dee189e-fe87-560a-9fd3-880aa1650ad9', 'fcad656e-cc1a-5448-9477-744f99c0769c', '15b4d325-3418-51c3-b852-2f0d24d62336', '64890629-186b-512b-8303-bba8e4cf5c55', '746007fb-3775-55b1-a64a-d69253d57fc2', '88e1d4f3-87c0-5a22-87b2-df52d19ae8af', '1424e0d9-8846-5fb1-abbd-17e923b7a511', 'b2fee0cf-0cb8-5796-80ea-e0734868c725', '84c4dcf8-07ad-5c57-b2df-398813196c98', '7f8e2508-598c-5ddf-8379-0003e8d41860', 'c887e8c2-7bd5-59e9-a6a4-6cc47c257cf4', '55dd9aab-060f-5c95-bd21-57ba02953027', '16b0d08d-4513-5127-9a8f-52f773d5cb19', 'f708d89d-1d2b-586d-b930-e0a93017b844', '3e460ebc-f79e-5eb7-8fd1-7e73b433e4a8', 'a497209c-6f86-54a4-94e1-46ec23458976', '094511aa-a7eb-54e3-b632-83a984aac700', '34dc04e2-d4f9-5aaf-95ad-c0fe909b4ced', '781d4f09-0f5c-5fde-acbd-e24d6bb0048b', '1f002ea7-8e1d-525c-b8a7-98d0cfe3f722', 'ef1c2cbd-5db2-5954-a30f-87b7d3b05c0b', '69666ecc-691f-58b0-8bc2-6118379bcedc', '92ec5196-2c3d-5414-a08f-75c582ce9af7', 'b00a3f34-66a9-55cc-83f5-75c1cae23c85', 'dc6d62fb-70d9-5ff8-838c-81c7cbe21c85', '219109f1-140f-5b1f-9707-8481a41d0fb9', '036d66aa-76fa-5faa-979a-cb202e7e9727', 'ae81e833-acb6-5f25-82a5-3abc765a58b4', '5e8db7ef-3c56-5870-ae04-b996266c2dd7', '6e6c57a2-3503-5625-8c35-acc4231c6117', 'a6193189-3362-57a3-858e-e4450637cdc0', 'a2c6c0ae-b1a8-5c55-a814-a77ac6da2391', '74b19bdd-05c4-5c63-95fd-6e965df9fc77', '52bf06af-5c02-56ba-bb83-d29cc97e7778', '77bc10f1-619d-5de6-af96-02bab3fc6f26') and status = 'PUBLISHED';
  select count(*) into v_bad from (values ('a1-m01', 20), ('a1-m02', 20), ('a1-m03', 16), ('a1-m04', 20), ('a1-m05', 20), ('a1-m06', 18), ('a1-m07', 14)) e(slug, n) left join public.assessments a on a.slug = e.slug and a.cefr = 'A1' and a.status = 'PUBLISHED'
   where a.id is null
      or (select count(*) from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED') <> e.n
      or exists (select 1 from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED' and i.id not in ('e1f7b598-659f-51eb-a976-02287b0be19a', '4f075458-a32f-54f0-955e-fae69b02b13f', 'b8dd2ecb-62b4-5b58-9f9b-c43e34c204db', '0efa35d0-585a-5a8a-a6bb-5f2c4438e47d', 'f24853f8-cd88-5020-8310-20fe2d9a8a20', 'c18ea603-a4c3-52cb-ac93-84658139dac5', '94a9e44c-c583-5ae0-b55c-90711fa23201', '2579b5a9-27a3-5347-aa16-931f497e2479', '1a44d65a-afe5-54d7-a396-7590dc61afc7', '5b12301b-5349-58e8-99fb-9403713ef78d', 'beabf65f-bb9a-55b9-bfa0-b77019aa670e', '2e63066e-271d-51b1-a9bc-dd5f73f90435', '663d795d-fd6b-5d92-bf4f-d5843e193fd3', '43019ee9-010d-529d-9a09-ed79cbf57a2d', '8bff161a-4c6d-5df9-a503-1344892f41aa', '1bbe3b6d-75e1-5706-bc6f-374d8c282f39', 'a2c10919-ab36-5a16-b15e-c06dbed104cd', '07a081e7-3a8e-5dc5-bbc8-ba53581e8e3b', 'fddd4816-8ffe-58f7-a6ab-9fd7b44e4141', '68bb4502-7bc1-5ce5-a8ab-b728f8d5b2d4', 'a38f632a-ab56-55db-bea6-da6f23aa7fa6', '1f0787c1-5091-5de8-80a4-5037aa1afbd9', 'fc4540cb-ecb2-5a24-9eeb-b12c241b4f16', '14e97dc5-3f39-5b7d-9880-12cd29a85636', '9d6d9cd8-67eb-594b-bb43-0dae03cffc9e', '822d1fe3-8f37-560c-b787-04c7c8191b7d', '83b68aad-4aac-5ea7-a757-2779300cef13', 'fd8b5134-2a33-582f-b021-4595b4f86ede', 'f68dc37e-cadd-5eae-84b7-5435260da40b', 'db2003e8-58f3-5665-afc7-7580155d8a3d', '657c2215-16c7-5d52-baee-3110e0966545', '57f4390d-d0e3-5648-80f0-7e59182d6032', '9aa126eb-d0df-50ba-a3ce-91ebb99c7a17', 'adb8cf49-5b3c-5b7d-877e-2bf85fa3140f', '05ad6c25-7199-5b5a-8edf-8f21eb5be2fa', 'e91f2033-c0d6-5fed-916b-e6b14e8e957c', '427c7dfc-9747-5108-9396-b54a1a622a2d', 'f59ce918-f672-5d85-ab3e-9bd3c172ffc1', 'fc1243f1-8fb7-5d79-8bc1-b714f099e61e', 'dffb0ee0-6266-5d78-abd2-9d590b12f955', '7dce849f-bf84-5341-b37e-a646e11cd73e', 'f1cab5a7-5265-503d-a869-b4ee24d498b8', '097f188c-629c-5c51-a540-cb2e8f27cd4f', '3a3d1886-74e7-5828-b1fb-8038f76fd257', 'd8f24cef-eeaf-5426-9d8a-332e1b02a28f', '95961061-d97f-538b-a608-c5ad54d26908', 'bf541529-bc7e-599a-9e4a-35da6ec0942a', 'd6349275-7289-53dd-a9bc-5858021f75b1', '7473a9ec-b810-599e-b283-755a19722fe4', 'f964acaf-b6f2-52a9-b417-d6380160b780', '2cfe1442-668e-5be2-88de-8f2f70bca499', '945943b2-263d-55e6-8233-fbe9e612591b', '9c790a32-552f-53b5-9150-f1e007ac65f9', 'c7515d41-dc3f-54a3-8810-845adb186bf0', '9ebbff80-ee90-5533-b48e-fe2500b3342d', 'b55a75ab-de2e-5e81-8991-a614b9d4581e', '8608fe47-7921-57c6-86d7-ba5daaa6fbe4', '00e6e03e-b5d3-56b9-856d-30e0712cb26c', '3163834b-2f69-5e62-a163-db453664965a', '028587f4-67e3-5079-ae01-26a3d1e6e330', '2a091165-0678-578c-811c-c44ffa127a90', 'c6133fa8-1350-5686-840a-80fd73cef9b4', 'a0913753-fa0f-5978-adc4-c52a60191b44', '757f7153-ef3c-551d-bf3c-e046173bc791', '42e3bad3-e001-5651-b41f-88df2c2903ae', '326299d6-07c1-514d-91e2-7edf1b056428', 'c6de6f6e-d893-584c-8326-d9e852a18d18', '0c024ba4-b116-5e9d-8c02-cdd0b8864fde', '7069c282-f018-5a47-ad1c-2190a6dfee62', 'ef240d70-a96f-52a1-b9c6-a76f643a555b', '6f623630-af99-5146-92c9-9a659aca8855', 'c7f60d47-a169-51a6-8045-e75744164ef0', 'a6b4e70a-4a17-5837-a398-87187fb9e941', '112fa59f-9385-5bf1-8d72-71bae57bc5e8', '9722f66d-c24d-5351-aa21-3aa900c3c34c', 'ea79bb5f-cd4d-5077-940a-74d7ca9c1480', 'e5a2a0ed-e218-591b-aaf1-bc39a539db14', '257a317b-59b8-5ce0-abd2-e8ad8fbb53ce', '2a8054b6-da1b-50aa-9537-e8c414199652', 'd8d5ab61-41d7-5217-9090-058771aa8fa3', '227ea469-89a6-553e-bb2d-a893daa85505', '8f75f2db-8cb9-58c7-b739-1330d118b2f8', '6d74d9a8-32da-53c7-b944-7dc07b80f44a', 'd4a412e5-c2eb-5655-8f65-66c195d4e2c6', '082a019f-fe26-57ea-bd8b-91bd373eb70b', '13ee62a4-c76d-5cc9-99ec-e1a05e18feeb', '64e5ef0f-2904-5ec3-8d38-1190236a9fe6', 'a9122483-2455-5b38-8d43-638b3276d456', '9eb633db-9f97-58a5-9a50-1afd1f033029', '1329ef46-2d89-5750-85ff-6ffe8068e441', '67e1dd33-a439-5051-bb29-833582f82501', 'd5c6ebd3-a1ef-5125-ba59-c6ef24839307', 'b68eb41a-54b7-5c9d-af7b-ddf52926f378', '7dee189e-fe87-560a-9fd3-880aa1650ad9', 'fcad656e-cc1a-5448-9477-744f99c0769c', '15b4d325-3418-51c3-b852-2f0d24d62336', '64890629-186b-512b-8303-bba8e4cf5c55', '746007fb-3775-55b1-a64a-d69253d57fc2', '88e1d4f3-87c0-5a22-87b2-df52d19ae8af', '1424e0d9-8846-5fb1-abbd-17e923b7a511', 'b2fee0cf-0cb8-5796-80ea-e0734868c725', '84c4dcf8-07ad-5c57-b2df-398813196c98', '7f8e2508-598c-5ddf-8379-0003e8d41860', 'c887e8c2-7bd5-59e9-a6a4-6cc47c257cf4', '55dd9aab-060f-5c95-bd21-57ba02953027', '16b0d08d-4513-5127-9a8f-52f773d5cb19', 'f708d89d-1d2b-586d-b930-e0a93017b844', '3e460ebc-f79e-5eb7-8fd1-7e73b433e4a8', 'a497209c-6f86-54a4-94e1-46ec23458976', '094511aa-a7eb-54e3-b632-83a984aac700', '34dc04e2-d4f9-5aaf-95ad-c0fe909b4ced', '781d4f09-0f5c-5fde-acbd-e24d6bb0048b', '1f002ea7-8e1d-525c-b8a7-98d0cfe3f722', 'ef1c2cbd-5db2-5954-a30f-87b7d3b05c0b', '69666ecc-691f-58b0-8bc2-6118379bcedc', '92ec5196-2c3d-5414-a08f-75c582ce9af7', 'b00a3f34-66a9-55cc-83f5-75c1cae23c85', 'dc6d62fb-70d9-5ff8-838c-81c7cbe21c85', '219109f1-140f-5b1f-9707-8481a41d0fb9', '036d66aa-76fa-5faa-979a-cb202e7e9727', 'ae81e833-acb6-5f25-82a5-3abc765a58b4', '5e8db7ef-3c56-5870-ae04-b996266c2dd7', '6e6c57a2-3503-5625-8c35-acc4231c6117', 'a6193189-3362-57a3-858e-e4450637cdc0', 'a2c6c0ae-b1a8-5c55-a814-a77ac6da2391', '74b19bdd-05c4-5c63-95fd-6e965df9fc77', '52bf06af-5c02-56ba-bb83-d29cc97e7778', '77bc10f1-619d-5de6-af96-02bab3fc6f26'));
  if v_new <> 128 or v_bad > 0 then raise exception 'Перевірки A1: нових завдань % (очікувалось 128), тестів з помилкою %', v_new, v_bad; end if;
  if exists (select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id and a.cefr = 'A1' and a.kind = 'module'
               join public.lessons l on l.id = i.lesson_id join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
              where i.status = 'PUBLISHED' and i.id in ('e1f7b598-659f-51eb-a976-02287b0be19a', '4f075458-a32f-54f0-955e-fae69b02b13f', 'b8dd2ecb-62b4-5b58-9f9b-c43e34c204db', '0efa35d0-585a-5a8a-a6bb-5f2c4438e47d', 'f24853f8-cd88-5020-8310-20fe2d9a8a20', 'c18ea603-a4c3-52cb-ac93-84658139dac5', '94a9e44c-c583-5ae0-b55c-90711fa23201', '2579b5a9-27a3-5347-aa16-931f497e2479', '1a44d65a-afe5-54d7-a396-7590dc61afc7', '5b12301b-5349-58e8-99fb-9403713ef78d', 'beabf65f-bb9a-55b9-bfa0-b77019aa670e', '2e63066e-271d-51b1-a9bc-dd5f73f90435', '663d795d-fd6b-5d92-bf4f-d5843e193fd3', '43019ee9-010d-529d-9a09-ed79cbf57a2d', '8bff161a-4c6d-5df9-a503-1344892f41aa', '1bbe3b6d-75e1-5706-bc6f-374d8c282f39', 'a2c10919-ab36-5a16-b15e-c06dbed104cd', '07a081e7-3a8e-5dc5-bbc8-ba53581e8e3b', 'fddd4816-8ffe-58f7-a6ab-9fd7b44e4141', '68bb4502-7bc1-5ce5-a8ab-b728f8d5b2d4', 'a38f632a-ab56-55db-bea6-da6f23aa7fa6', '1f0787c1-5091-5de8-80a4-5037aa1afbd9', 'fc4540cb-ecb2-5a24-9eeb-b12c241b4f16', '14e97dc5-3f39-5b7d-9880-12cd29a85636', '9d6d9cd8-67eb-594b-bb43-0dae03cffc9e', '822d1fe3-8f37-560c-b787-04c7c8191b7d', '83b68aad-4aac-5ea7-a757-2779300cef13', 'fd8b5134-2a33-582f-b021-4595b4f86ede', 'f68dc37e-cadd-5eae-84b7-5435260da40b', 'db2003e8-58f3-5665-afc7-7580155d8a3d', '657c2215-16c7-5d52-baee-3110e0966545', '57f4390d-d0e3-5648-80f0-7e59182d6032', '9aa126eb-d0df-50ba-a3ce-91ebb99c7a17', 'adb8cf49-5b3c-5b7d-877e-2bf85fa3140f', '05ad6c25-7199-5b5a-8edf-8f21eb5be2fa', 'e91f2033-c0d6-5fed-916b-e6b14e8e957c', '427c7dfc-9747-5108-9396-b54a1a622a2d', 'f59ce918-f672-5d85-ab3e-9bd3c172ffc1', 'fc1243f1-8fb7-5d79-8bc1-b714f099e61e', 'dffb0ee0-6266-5d78-abd2-9d590b12f955', '7dce849f-bf84-5341-b37e-a646e11cd73e', 'f1cab5a7-5265-503d-a869-b4ee24d498b8', '097f188c-629c-5c51-a540-cb2e8f27cd4f', '3a3d1886-74e7-5828-b1fb-8038f76fd257', 'd8f24cef-eeaf-5426-9d8a-332e1b02a28f', '95961061-d97f-538b-a608-c5ad54d26908', 'bf541529-bc7e-599a-9e4a-35da6ec0942a', 'd6349275-7289-53dd-a9bc-5858021f75b1', '7473a9ec-b810-599e-b283-755a19722fe4', 'f964acaf-b6f2-52a9-b417-d6380160b780', '2cfe1442-668e-5be2-88de-8f2f70bca499', '945943b2-263d-55e6-8233-fbe9e612591b', '9c790a32-552f-53b5-9150-f1e007ac65f9', 'c7515d41-dc3f-54a3-8810-845adb186bf0', '9ebbff80-ee90-5533-b48e-fe2500b3342d', 'b55a75ab-de2e-5e81-8991-a614b9d4581e', '8608fe47-7921-57c6-86d7-ba5daaa6fbe4', '00e6e03e-b5d3-56b9-856d-30e0712cb26c', '3163834b-2f69-5e62-a163-db453664965a', '028587f4-67e3-5079-ae01-26a3d1e6e330', '2a091165-0678-578c-811c-c44ffa127a90', 'c6133fa8-1350-5686-840a-80fd73cef9b4', 'a0913753-fa0f-5978-adc4-c52a60191b44', '757f7153-ef3c-551d-bf3c-e046173bc791', '42e3bad3-e001-5651-b41f-88df2c2903ae', '326299d6-07c1-514d-91e2-7edf1b056428', 'c6de6f6e-d893-584c-8326-d9e852a18d18', '0c024ba4-b116-5e9d-8c02-cdd0b8864fde', '7069c282-f018-5a47-ad1c-2190a6dfee62', 'ef240d70-a96f-52a1-b9c6-a76f643a555b', '6f623630-af99-5146-92c9-9a659aca8855', 'c7f60d47-a169-51a6-8045-e75744164ef0', 'a6b4e70a-4a17-5837-a398-87187fb9e941', '112fa59f-9385-5bf1-8d72-71bae57bc5e8', '9722f66d-c24d-5351-aa21-3aa900c3c34c', 'ea79bb5f-cd4d-5077-940a-74d7ca9c1480', 'e5a2a0ed-e218-591b-aaf1-bc39a539db14', '257a317b-59b8-5ce0-abd2-e8ad8fbb53ce', '2a8054b6-da1b-50aa-9537-e8c414199652', 'd8d5ab61-41d7-5217-9090-058771aa8fa3', '227ea469-89a6-553e-bb2d-a893daa85505', '8f75f2db-8cb9-58c7-b739-1330d118b2f8', '6d74d9a8-32da-53c7-b944-7dc07b80f44a', 'd4a412e5-c2eb-5655-8f65-66c195d4e2c6', '082a019f-fe26-57ea-bd8b-91bd373eb70b', '13ee62a4-c76d-5cc9-99ec-e1a05e18feeb', '64e5ef0f-2904-5ec3-8d38-1190236a9fe6', 'a9122483-2455-5b38-8d43-638b3276d456', '9eb633db-9f97-58a5-9a50-1afd1f033029', '1329ef46-2d89-5750-85ff-6ffe8068e441', '67e1dd33-a439-5051-bb29-833582f82501', 'd5c6ebd3-a1ef-5125-ba59-c6ef24839307', 'b68eb41a-54b7-5c9d-af7b-ddf52926f378', '7dee189e-fe87-560a-9fd3-880aa1650ad9', 'fcad656e-cc1a-5448-9477-744f99c0769c', '15b4d325-3418-51c3-b852-2f0d24d62336', '64890629-186b-512b-8303-bba8e4cf5c55', '746007fb-3775-55b1-a64a-d69253d57fc2', '88e1d4f3-87c0-5a22-87b2-df52d19ae8af', '1424e0d9-8846-5fb1-abbd-17e923b7a511', 'b2fee0cf-0cb8-5796-80ea-e0734868c725', '84c4dcf8-07ad-5c57-b2df-398813196c98', '7f8e2508-598c-5ddf-8379-0003e8d41860', 'c887e8c2-7bd5-59e9-a6a4-6cc47c257cf4', '55dd9aab-060f-5c95-bd21-57ba02953027', '16b0d08d-4513-5127-9a8f-52f773d5cb19', 'f708d89d-1d2b-586d-b930-e0a93017b844', '3e460ebc-f79e-5eb7-8fd1-7e73b433e4a8', 'a497209c-6f86-54a4-94e1-46ec23458976', '094511aa-a7eb-54e3-b632-83a984aac700', '34dc04e2-d4f9-5aaf-95ad-c0fe909b4ced', '781d4f09-0f5c-5fde-acbd-e24d6bb0048b', '1f002ea7-8e1d-525c-b8a7-98d0cfe3f722', 'ef1c2cbd-5db2-5954-a30f-87b7d3b05c0b', '69666ecc-691f-58b0-8bc2-6118379bcedc', '92ec5196-2c3d-5414-a08f-75c582ce9af7', 'b00a3f34-66a9-55cc-83f5-75c1cae23c85', 'dc6d62fb-70d9-5ff8-838c-81c7cbe21c85', '219109f1-140f-5b1f-9707-8481a41d0fb9', '036d66aa-76fa-5faa-979a-cb202e7e9727', 'ae81e833-acb6-5f25-82a5-3abc765a58b4', '5e8db7ef-3c56-5870-ae04-b996266c2dd7', '6e6c57a2-3503-5625-8c35-acc4231c6117', 'a6193189-3362-57a3-858e-e4450637cdc0', 'a2c6c0ae-b1a8-5c55-a814-a77ac6da2391', '74b19bdd-05c4-5c63-95fd-6e965df9fc77', '52bf06af-5c02-56ba-bb83-d29cc97e7778', '77bc10f1-619d-5de6-af96-02bab3fc6f26') and m.id is distinct from a.module_id) then
    raise exception 'Перевірки модулів A1: завдання з уроку іншого модуля';
  end if;
  raise notice 'Готово: 20261119_a2_dupes_2_tests_a1_part1.sql — 7 тестів, % нових завдань', v_new;
end $$;

commit;
