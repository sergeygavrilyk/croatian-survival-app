-- =====================================================================
-- Перевірки рівня A1 за схемою 2026-11-07 · частина 1 з 2 · 2026-11-16
-- Згенеровано: python3 -B scripts/gen_assessment_a0_a1_v5.py (не редагуйте вручну).
--
-- Схема (рішення власника 2026-11-07): модуль — 2 завдання на урок (12–20), середина — 30, фінал — 48.
-- Було: модуль — 10, середина — 20, фінал — 30. У цьому файлі 128 нових завдань:
--   a1-m01 — 20, a1-m02 — 20, a1-m03 — 16, a1-m04 — 20, a1-m05 — 20, a1-m06 — 18, a1-m07 — 14.
--   * Завдання — з діалогів, вправ і текстів для читання уроків A1; нових хорватських речень немає. 4 навички §60.
--   * «Складіть» — з іншими правильними порядками слів (answer_alternatives), де вони є. Потрібна міграція M27.
--   * Стара версія завдань — у content_versions; старі завдання → DEPRECATED (не видаляються). Нові — PUBLISHED (бета).
--   * Спроби й результати користувачів не змінюються. Повторний запуск нічого не змінює.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника. Очікуване повідомлення:
--   «Готово: 20261116_assessments_a1_v5_part1.sql — 7 тестів, 128 нових завдань».
-- =====================================================================

begin;
-- Перевірка модуля A1.1 · Модуль A1.1 — Мій день · 20 завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = 'a1-m01' and cefr = 'A1';
  if v_aid is null then raise exception 'Немає тесту a1-m01 — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = '15676330-4f1c-52f6-ae93-73ae74ad7d03') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from '329c44d2-afb3-5e9e-a04e-0ab31405ad9f'::uuid then
    raise exception 'Тест a1-m01 прив’язаний не до модуля A1.1 — звірте базу';
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
  ('15676330-4f1c-52f6-ae93-73ae74ad7d03', v_aid, 1, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Розумію. Здебільшого він у саду, а ввечері — в хаті.", "Справді? Тоді я навіть встигну випити кави.", "Час від часу, раз чи двічі на місяць."]'::jsonb, 0, null, '{}'::text[], 'Razumijem. Uglavnom je u vrtu, a navečer je unutra.', null, null, 'Прозвучало: «Razumijem. Uglavnom je u vrtu, a navečer je unutra.» — «Розумію. Здебільшого він у саду, а ввечері — в хаті.».', (select id from public.lessons where id = '959e879f-a28d-5bed-9c09-16cff91ef456'), 'PUBLISHED', 'claude_assessment_v5'),
  ('54a304fb-c687-505a-8fdf-d801e9599204', v_aid, 2, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["А ти регулярно плаваєш?", "Коли ти повертаєшся з роботи?", "А що робиш потім?"]'::jsonb, 2, null, '{}'::text[], 'A što radiš zatim?', null, null, 'Прозвучало: «A što radiš zatim?» — «А що робиш потім?».', (select id from public.lessons where id = '4bf48151-be83-5108-bc92-645c0603a1a3'), 'PUBLISHED', 'claude_assessment_v5'),
  ('847b1aef-67dc-5d49-8533-5361ace111bc', v_aid, 3, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["О котрій ти виходиш з дому?", "Добре. Де підгузки, якщо треба буде її перевдягнути?", "Дашо, сьогодні субота. Розподілимо домашні справи?"]'::jsonb, 1, null, '{}'::text[], 'Dobro. Gdje su pelene, ako je trebam presvući?', null, null, 'Прозвучало: «Dobro. Gdje su pelene, ako je trebam presvući?» — «Добре. Де підгузки, якщо треба буде її перевдягнути?».', (select id from public.lessons where id = 'd43d6c65-1ce3-5c72-9ecd-cce2ed200fc2'), 'PUBLISHED', 'claude_assessment_v5'),
  ('4f518116-4db9-5b33-ac0d-2e08963e7e7a', v_aid, 4, 'A1', 'reading', 'understand', 'multiple_choice', 'Як Тарас їде на роботу?', 'Tarasov običan dan', '["Автобусом", "Пішки", "Трамваєм"]'::jsonb, 2, null, '{}'::text[], null, 'Taras živi u Zagrebu. Svaki dan se budi u šest i pol. Prvo se tušira, a onda doručkuje s obitelji. Na posao ide tramvajem. Radi u skladištu od osam do četiri. Poslije posla ide u trgovinu ili u park sa psom. Navečer obično čita ili gleda film. Spava u jedanaest, jer je ujutro opet rano.', 'Тарас живе в Загребі. Щодня він прокидається о пів на сьому. Спочатку приймає душ, а потім снідає з родиною. На роботу їде трамваєм. Працює на складі з восьмої до четвертої. Після роботи йде в магазин або в парк із собакою. Увечері зазвичай читає або дивиться фільм. Лягає спати об одинадцятій, бо вранці знову рано.', 'Текст «Звичайний день Тараса». Правильна відповідь: «Трамваєм».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('4f06eda3-7f34-5875-9704-cd35d4df9c29', v_aid, 5, 'A1', 'reading', 'understand', 'multiple_choice', 'Чому Данило не може?', 'Obiteljska grupa', '["Він має тренування", "Він хворий", "Він на роботі"]'::jsonb, 0, null, '{}'::text[], null, 'Mama: Tko danas kupuje kruh?
Danilo: Ja ne mogu, imam trening do sedam.
Tata: Ja kupujem kruh i mlijeko poslije posla.
Mama: Hvala! Večera je u osam. Danilo, ne zaboravi: danas ti pereš suđe!
Danilo: Dobro, mama 🙂', 'Мама: Хто сьогодні купує хліб?
Данило: Я не можу, у мене тренування до сьомої.
Тато: Я куплю хліб і молоко після роботи.
Мама: Дякую! Вечеря о восьмій. Данило, не забудь: сьогодні ти миєш посуд!
Данило: Добре, мамо 🙂', 'Текст «Сімейний чат». Правильна відповідь: «Він має тренування».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('d3e8c458-31dd-509a-9671-9f8127601c3e', v_aid, 6, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Darja! Radiš li još u hotelu?', '["Pola kile pilećih prsa i četiri svinjska kotleta.", "Jednu kavu za van i jedan čaj s limunom.", "Više ne, sada radim u školi."]'::jsonb, 2, null, '{}'::text[], 'Darja! Radiš li još u hotelu?', null, null, 'Діалог «Стара знайома»: «Darja! Radiš li još u hotelu?» (Дар’є! Ти ще працюєш у готелі?) — «Više ne, sada radim u školi.» (Уже ні, тепер працюю в школі.).', (select id from public.lessons where id = 'ad0bc1f4-2808-5b24-969d-9da64d4a7a4d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('1502e215-93aa-536a-a69e-326b0bcdf987', v_aid, 7, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Dašo, subota je. Podijelimo kućanske poslove?', '["Može. Ja usisavam i brišem prašinu.", "Ocat je kod ulja, u trećem redu.", "Jedem, ali moj brat je vegan."]'::jsonb, 0, null, '{}'::text[], 'Dašo, subota je. Podijelimo kućanske poslove?', null, null, 'Діалог «Хто що робить?»: «Dašo, subota je. Podijelimo kućanske poslove?» (Дашо, сьогодні субота. Розподілимо домашні справи?) — «Može. Ja usisavam i brišem prašinu.» (Давай. Я пилососю й витираю пил.).', (select id from public.lessons where id = '9c38f909-9275-5194-9a6e-f799c6e416ce'), 'PUBLISHED', 'claude_assessment_v5'),
  ('60d7975a-c196-5951-a124-1925aa0cfb9c', v_aid, 8, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Naravno. Kada joj dajem mlijeko?', '["Pekmez od marelica, ako ga još imamo.", "Trešnje, smokve i prve dinje.", "U pet joj daj bočicu s mlijekom."]'::jsonb, 2, null, '{}'::text[], 'Naravno. Kada joj dajem mlijeko?', null, null, 'Діалог «Сусідка допомагає»: «Naravno. Kada joj dajem mlijeko?» (Звісно. Коли їй дати молоко?) — «U pet joj daj bočicu s mlijekom.» (О п’ятій дай їй пляшечку з молоком.).', (select id from public.lessons where id = 'd43d6c65-1ce3-5c72-9ecd-cce2ed200fc2'), 'PUBLISHED', 'claude_assessment_v5'),
  ('ec5b0df6-f3b4-50d4-9aaf-7b53d351f11a', v_aid, 9, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Super! Valjda ti je tamo lakše?', '["Skoro. Grah mora još malo prokuhati.", "Lakše je, ali ipak puno radim.", "Ružmarin i češnjak. Meso posoli i popapri."]'::jsonb, 1, null, '{}'::text[], 'Super! Valjda ti je tamo lakše?', null, null, 'Діалог «Стара знайома»: «Super! Valjda ti je tamo lakše?» (Чудово! Мабуть, тобі там легше?) — «Lakše je, ali ipak puno radim.» (Легше, але я все одно багато працюю.).', (select id from public.lessons where id = 'ad0bc1f4-2808-5b24-969d-9da64d4a7a4d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('1724f917-1107-537c-8231-36d7bc14ae3a', v_aid, 10, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Drijemate li poslijepodne?', '["Іноді, бо я постійно виснажена.", "Не дрімайте і ввечері не пийте кави.", "Уже тиждень маю безсоння. Лягаю об одинадцятій, але не можу заснути."]'::jsonb, 0, null, '{}'::text[], null, 'Liječnica: Što vas muči?
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
  ('8018686e-2bf5-559b-9ba8-c1c36d3bcd85', v_aid, 11, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Kada se vraćaš s posla?', '["Готую вечерю, а потім граюся з дітьми.", "Щовечора повертаюся близько шостої.", "Так. Наприкінці дня читаю пів години й рано лягаю."]'::jsonb, 1, null, '{}'::text[], null, 'Marko: Kada se vraćaš s posla?
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
  ('3032f3aa-7479-5d20-a36b-2f9da00b854d', v_aid, 12, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Što planiraš za sljedeći tjedan?', '["Дякую, що нагадуєш! Мені треба купити подарунок.", "Не забудь, у суботу день народження Марка.", "На початку тижня в мене лікар, а в середу курси."]'::jsonb, 2, null, '{}'::text[], null, 'Luka: Što planiraš za sljedeći tjedan?
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
  ('3aa1e802-5bb7-58dd-9add-cee86bfc3686', v_aid, 13, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Мені треба вмитися». Що ви скажете?', null, '["Usisavam u dnevnom boravku.", "Moram se umiti.", "Koliko često kuhaš?"]'::jsonb, 1, null, '{}'::text[], null, null, null, '«Мені треба вмитися.» — «Moram se umiti.».', (select id from public.lessons where id = '54f17cf7-3c17-5978-b400-b6b6888c9f84'), 'PUBLISHED', 'claude_assessment_v5'),
  ('c1619d7e-7e6f-5bd0-b5a7-8eb91a7ca596', v_aid, 14, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Мені треба скасувати запис». Що ви скажете?', null, '["Presvuci bebu, molim te.", "Obično se budim u sedam.", "Moram otkazati termin."]'::jsonb, 2, null, '{}'::text[], null, null, null, '«Мені треба скасувати запис.» — «Moram otkazati termin.».', (select id from public.lessons where id = '3365f423-e694-5b55-baa1-3205fba11aff'), 'PUBLISHED', 'claude_assessment_v5'),
  ('b32e622c-118b-547d-ab0e-ef7fbe0e7369', v_aid, 15, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «пісок»', null, '[]'::jsonb, null, 'pijesak', '{}'::text[], null, null, null, '«пісок» — pijesak.', (select id from public.lessons where id = 'd43d6c65-1ce3-5c72-9ecd-cce2ed200fc2'), 'PUBLISHED', 'claude_assessment_v5'),
  ('8eef2566-9652-51d6-9d01-f3518defcd5f', v_aid, 16, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «згадати»', null, '[]'::jsonb, null, 'sjetiti se', '{}'::text[], null, null, null, '«згадати» — sjetiti se.', (select id from public.lessons where id = '3365f423-e694-5b55-baa1-3205fba11aff'), 'PUBLISHED', 'claude_assessment_v5'),
  ('6528306c-c0da-5096-a550-43d2083ef461', v_aid, 17, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Дай їй соску, будь ласка.»', null, '["molim", "te.", "Daj", "dudu,", "joj"]'::jsonb, null, 'Daj joj dudu, molim te.', array['Molim te, daj joj dudu.']::text[], null, null, null, '«Дай їй соску, будь ласка.» — «Daj joj dudu, molim te.».', (select id from public.lessons where id = 'd43d6c65-1ce3-5c72-9ecd-cce2ed200fc2'), 'PUBLISHED', 'claude_assessment_v5'),
  ('4cd402b3-b2a6-568f-a4a5-74d5dff362b4', v_aid, 18, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Потім я збираюся на роботу.»', null, '["posao.", "za", "spremam", "Zatim", "se"]'::jsonb, null, 'Zatim se spremam za posao.', '{}'::text[], null, null, null, '«Потім я збираюся на роботу.» — «Zatim se spremam za posao.».', (select id from public.lessons where id = '4bf48151-be83-5108-bc92-645c0603a1a3'), 'PUBLISHED', 'claude_assessment_v5'),
  ('2f5b5c43-69ab-549e-b196-1e8879af3b05', v_aid, 19, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Я вигулюю пса в парку.»', null, '["u", "parku.", "psa", "Šetam"]'::jsonb, null, 'Šetam psa u parku.', array['U parku šetam psa.']::text[], null, null, null, '«Я вигулюю пса в парку.» — «Šetam psa u parku.».', (select id from public.lessons where id = '1968c7d5-4e3a-5b1e-92f6-88df711e9c54'), 'PUBLISHED', 'claude_assessment_v5'),
  ('eeddbd88-68db-5153-a5dd-e82a15732b64', v_aid, 20, 'A1', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Ходімо прогуляємося!»', null, '[]'::jsonb, null, 'Idemo prošetati!', '{}'::text[], null, null, null, '«Ходімо прогуляємося!» — «Idemo prošetati!».', (select id from public.lessons where id = '458b73de-d6b3-5bd3-98ad-c243a2fff03f'), 'PUBLISHED', 'claude_assessment_v5');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірки рівня A1 за схемою 2026-11-07 (модуль — 2 завдання на урок, середина — 30, фінал — 48) з діалогів, вправ і текстів уроків A1. Потрібна перевірка носієм.');
end $$;

-- Перевірка модуля A1.2 · Модуль A1.2 — Їжа й кухня · 20 завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = 'a1-m02' and cefr = 'A1';
  if v_aid is null then raise exception 'Немає тесту a1-m02 — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = 'bd606cd7-5fc3-59bd-922c-bacbce88aba3') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from '8d02296d-bc46-5537-9a9b-c678fe5ff1c9'::uuid then
    raise exception 'Тест a1-m02 прив’язаний не до модуля A1.2 — звірте базу';
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
  ('bd606cd7-5fc3-59bd-922c-bacbce88aba3', v_aid, 1, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Змішай борошно, яйця, цукор і трохи олії.", "Дві головки салату й пучок петрушки.", "Добре. Зустрінемося біля заморожених овочів."]'::jsonb, 1, null, '{}'::text[], 'Dvije glavice zelene salate i vezicu peršina.', null, null, 'Прозвучало: «Dvije glavice zelene salate i vezicu peršina.» — «Дві головки салату й пучок петрушки.».', (select id from public.lessons where id = '46a89cf5-41e0-50a2-99b1-f4e66a5ff146'), 'PUBLISHED', 'claude_assessment_v5'),
  ('c1f013ec-21d8-51c5-859a-75da3eed1cbf', v_aid, 2, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["А брецелі у вас є? Син їх обожнює.", "Пів кіло курячих грудок і чотири свинячі відбивні.", "А я їм цільнозерновий хліб і варене яйце."]'::jsonb, 2, null, '{}'::text[], 'Ja jedem integralni kruh i kuhano jaje.', null, null, 'Прозвучало: «Ja jedem integralni kruh i kuhano jaje.» — «А я їм цільнозерновий хліб і варене яйце.».', (select id from public.lessons where id = 'bb7bc159-cb40-5a8a-91b7-c6da05c6342a'), 'PUBLISHED', 'claude_assessment_v5'),
  ('4216fd1f-936a-592e-8b65-39b1631e81e3', v_aid, 3, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["На кухні в нас є мікрохвильовка.", "Вечеря була чудова! Я допоможу тобі прибрати зі столу.", "Візьми візок, а я піду по молочні продукти."]'::jsonb, 0, null, '{}'::text[], 'U kuhinji imamo mikrovalnu.', null, null, 'Прозвучало: «U kuhinji imamo mikrovalnu.» — «На кухні в нас є мікрохвильовка.».', (select id from public.lessons where id = '2c192d05-f259-53b6-a6ec-55ebfb25ec01'), 'PUBLISHED', 'claude_assessment_v5'),
  ('bb952a0b-31a2-5660-b055-15797b6e518c', v_aid, 4, 'A1', 'reading', 'understand', 'multiple_choice', 'Скільки коштує денне меню?', 'Dnevni meni', '["9 €", "16 €", "11 €"]'::jsonb, 0, null, '{}'::text[], null, 'DNEVNI MENI – 9 €
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
  ('ca57b200-927e-5495-8f40-35a8f3f24666', v_aid, 5, 'A1', 'reading', 'understand', 'multiple_choice', 'Який хліб є без цукру?', 'Nova pekara', '["Цільнозерновий", "Білий", "Домашній"]'::jsonb, 0, null, '{}'::text[], null, 'NOVA PEKARA U VAŠEM KVARTU!
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
  ('fe5a6014-98dd-5bda-a407-d9b25e688f96', v_aid, 6, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Mogu li maknuti poklopac?', '["Ne diraj, lonac je vruć!", "Subotom se izležavam, a nedjeljom idem na izlet.", "Više ne, sada radim u školi."]'::jsonb, 0, null, '{}'::text[], 'Mogu li maknuti poklopac?', null, null, 'Діалог «Обережно, гаряче!»: «Mogu li maknuti poklopac?» (Можна зняти кришку?) — «Ne diraj, lonac je vruć!» (Не чіпай, каструля гаряча!).', (select id from public.lessons where id = '17fcd38a-e295-5849-9ba3-1ef240c6be78'), 'PUBLISHED', 'claude_assessment_v5'),
  ('daffad3a-7451-5089-afc0-59484d72573c', v_aid, 7, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Dajte mi dvije orade. Možete li ih očistiti?', '["Na balkonu. Ja ću peglati košulje.", "Svaki dan, a mačića redovito četkajte.", "Naravno. Imamo i lignje i srdele."]'::jsonb, 2, null, '{}'::text[], 'Dajte mi dvije orade. Možete li ih očistiti?', null, null, 'Діалог «На рибному ринку»: «Dajte mi dvije orade. Možete li ih očistiti?» (Дайте мені дві доради. Можете їх почистити?) — «Naravno. Imamo i lignje i srdele.» (Звісно. Є ще кальмари й сардини.).', (select id from public.lessons where id = 'ae33e31a-f937-5305-908e-3d957df15f6a'), 'PUBLISHED', 'claude_assessment_v5'),
  ('5d541ca0-71c0-5767-901b-28ba8e14fd7d', v_aid, 8, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Može nedjelja. Što je specijalitet kuće? Imate li neku preporuku?', '["Početkom tjedna imam liječnika, a u srijedu tečaj.", "Nažalost nemam, imam sastanak cijeli dan.", "Riba na žaru. Potvrdit ću vam rezervaciju porukom."]'::jsonb, 2, null, '{}'::text[], 'Može nedjelja. Što je specijalitet kuće? Imate li neku preporuku?', null, null, 'Діалог «Зміна планів»: «Može nedjelja. Što je specijalitet kuće? Imate li neku preporuku?» (Неділя підходить. Яка у вас фірмова страва? Що порадите?) — «Riba na žaru. Potvrdit ću vam rezervaciju porukom.» (Риба на грилі. Я підтверджу вам бронювання повідомленням.).', (select id from public.lessons where id = '5e4a1c56-3931-58bb-81af-cb598966da77'), 'PUBLISHED', 'claude_assessment_v5'),
  ('f869f916-5520-523b-b397-3ea67c5a6a31', v_aid, 9, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Gdje da stavim čaše za vino?', '["U ormar, ali prvo ih operi rukom.", "Radimo roštilj u vrtu, a u nedjelju idemo planinariti.", "Treba. Uzmi metlu i krpu, hvala što mi pomažeš!"]'::jsonb, 0, null, '{}'::text[], 'Gdje da stavim čaše za vino?', null, null, 'Діалог «Після вечері»: «Gdje da stavim čaše za vino?» (Куди поставити келихи для вина?) — «U ormar, ali prvo ih operi rukom.» (У шафу, але спершу помий їх руками.).', (select id from public.lessons where id = '213ab10f-63a4-5e1c-8b2e-156c433de874'), 'PUBLISHED', 'claude_assessment_v5'),
  ('1ed4e1b3-461a-557e-b4da-3d1e023c059b', v_aid, 10, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Darja, jedeš li meso?', '["Їм, а от мій брат — веган.", "Прочитай склад на упаковці, там усе написано.", "Добре, приготую щось неперчене. Сподіваюся, не буде прісним."]'::jsonb, 0, null, '{}'::text[], null, 'Mia: Darja, jedeš li meso?
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
  ('55cf3870-3bef-5ef4-b300-80304e3b1131', v_aid, 11, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Dašo, imaš li popis za kupovinu?', '["Шість глибоких тарілок для супу й шість мілких для другої страви.", "А в нас на вихідних яєчня-глазунья й млинці.", "Є. Нам треба дві банки помідорів і літр олії."]'::jsonb, 2, null, '{}'::text[], null, 'Luka: Dašo, imaš li popis za kupovinu?
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
  ('e8b5b2c0-7f98-52ab-abe0-e93164166806', v_aid, 12, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Hvala. Imate li gotova jela?', '["Оцет біля олії, у третьому ряду.", "Є, в холодильнику в кінці магазину.", "Там само, біля спецій."]'::jsonb, 1, null, '{}'::text[], null, 'Darja: Oprostite, na kojem je odjelu ocat?
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
  ('1adf736b-5b6b-52cf-9eae-4d7eae9c2956', v_aid, 13, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Що сьогодні сезонне?». Що ви скажете?', null, '["Što je danas sezonsko?", "Hoćemo li naručiti dostavu hrane?", "Daj mi žličicu."]'::jsonb, 0, null, '{}'::text[], null, null, null, '«Що сьогодні сезонне?» — «Što je danas sezonsko?».', (select id from public.lessons where id = '46a89cf5-41e0-50a2-99b1-f4e66a5ff146'), 'PUBLISHED', 'claude_assessment_v5'),
  ('6d7b044a-4e28-5276-84c2-bfe28d17bab1', v_aid, 14, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Що ти вариш?». Що ви скажете?', null, '["Što kuhaš?", "Gdje je odjel mliječnih proizvoda?", "Imate li nešto slatko?"]'::jsonb, 0, null, '{}'::text[], null, null, null, '«Що ти вариш?» — «Što kuhaš?».', (select id from public.lessons where id = '17fcd38a-e295-5849-9ba3-1ef240c6be78'), 'PUBLISHED', 'claude_assessment_v5'),
  ('899b25e8-6513-514d-8f71-527466d28ee0', v_aid, 15, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «яєчня-бовтанка»', null, '[]'::jsonb, null, 'kajgana', '{}'::text[], null, null, null, '«яєчня-бовтанка» — kajgana.', (select id from public.lessons where id = 'bb7bc159-cb40-5a8a-91b7-c6da05c6342a'), 'PUBLISHED', 'claude_assessment_v5'),
  ('a49f8115-3568-5d13-b772-8d7010cabf50', v_aid, 16, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «мішати; перемішувати»', null, '[]'::jsonb, null, 'miješati', '{}'::text[], null, null, null, '«мішати; перемішувати» — miješati.', (select id from public.lessons where id = '3e652232-866b-5edf-ac05-d61ee7a325fe'), 'PUBLISHED', 'claude_assessment_v5'),
  ('35b6c8b6-c27a-58fc-bbcb-bf577ee83a73', v_aid, 17, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Розігрій духовку до двохсот градусів.»', null, '["na", "Zagrij", "pećnicu", "stupnjeva.", "dvjesto"]'::jsonb, null, 'Zagrij pećnicu na dvjesto stupnjeva.', array['Pećnicu zagrij na dvjesto stupnjeva.']::text[], null, null, null, '«Розігрій духовку до двохсот градусів.» — «Zagrij pećnicu na dvjesto stupnjeva.».', (select id from public.lessons where id = '3e652232-866b-5edf-ac05-d61ee7a325fe'), 'PUBLISHED', 'claude_assessment_v5'),
  ('a052cdcb-8b5c-5704-ac78-4bdc2e3994c6', v_aid, 18, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Принеси тацю з кухні.»', null, '["pladanj", "Donesi", "iz", "kuhinje."]'::jsonb, null, 'Donesi pladanj iz kuhinje.', array['Iz kuhinje donesi pladanj.']::text[], null, null, null, '«Принеси тацю з кухні.» — «Donesi pladanj iz kuhinje.».', (select id from public.lessons where id = '213ab10f-63a4-5e1c-8b2e-156c433de874'), 'PUBLISHED', 'claude_assessment_v5'),
  ('e94bff69-4391-52e6-bdd5-718925e8b3a9', v_aid, 19, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Де відкривачка для пляшок?»', null, '["otvarač", "boce?", "je", "Gdje", "za"]'::jsonb, null, 'Gdje je otvarač za boce?', '{}'::text[], null, null, null, '«Де відкривачка для пляшок?» — «Gdje je otvarač za boce?».', (select id from public.lessons where id = '213ab10f-63a4-5e1c-8b2e-156c433de874'), 'PUBLISHED', 'claude_assessment_v5'),
  ('0f4eb934-c922-5df6-9450-8ab58dc9d5b0', v_aid, 20, 'A1', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «У вас є хліб без глютену?»', null, '[]'::jsonb, null, 'Imate li kruh bez glutena?', '{}'::text[], null, null, null, '«У вас є хліб без глютену?» — «Imate li kruh bez glutena?».', (select id from public.lessons where id = '6af82dd3-beb1-54cf-9c1b-44ec3cb12a35'), 'PUBLISHED', 'claude_assessment_v5');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірки рівня A1 за схемою 2026-11-07 (модуль — 2 завдання на урок, середина — 30, фінал — 48) з діалогів, вправ і текстів уроків A1. Потрібна перевірка носієм.');
end $$;

-- Перевірка модуля A1.3 · Модуль A1.3 — Покупки · 16 завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = 'a1-m03' and cefr = 'A1';
  if v_aid is null then raise exception 'Немає тесту a1-m03 — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = 'b9fea7ff-1f74-5754-9d98-111634811632') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from '88e77a6f-1140-5f26-b724-0ae15477637a'::uuid then
    raise exception 'Тест a1-m03 прив’язаний не до модуля A1.3 — звірте базу';
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
  ('b9fea7ff-1f74-5754-9d98-111634811632', v_aid, 1, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Порівняйте їх спокійно, ми не поспішаємо.", "Згодна. Краще заплатити більше, ніж купувати двічі.", "Срібло вона любить більше, ніж золото."]'::jsonb, 0, null, '{}'::text[], 'Usporedite ih na miru, ne žurimo se.', null, null, 'Прозвучало: «Usporedite ih na miru, ne žurimo se.» — «Порівняйте їх спокійно, ми не поспішаємо.».', (select id from public.lessons where id = '7042ff57-9a20-514a-ab80-71b6f63579f7'), 'PUBLISHED', 'claude_assessment_v5'),
  ('472b5838-c796-57d3-8397-b3a1870653df', v_aid, 2, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["А якщо буде дощ?", "Мені шкода. Етикетка ще на ньому?", "Я йду в дрогерію. Що нам треба?"]'::jsonb, 0, null, '{}'::text[], 'A ako pada kiša?', null, null, 'Прозвучало: «A ako pada kiša?» — «А якщо буде дощ?».', (select id from public.lessons where id = 'c8297811-44ed-55a2-8cb5-d1bd9b8a6a73'), 'PUBLISHED', 'claude_assessment_v5'),
  ('531abfee-3309-5a78-a66e-a65a7726b019', v_aid, 3, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Не можу, оплата післяплатою.", "Вибір великий, важко обрати.", "Майже однакова. Інша дорожча через назву."]'::jsonb, 0, null, '{}'::text[], 'Ne mogu, plaćanje je pouzećem.', null, null, 'Прозвучало: «Ne mogu, plaćanje je pouzećem.» — «Не можу, оплата післяплатою.».', (select id from public.lessons where id = '91d4c9b3-c9a8-5e94-8691-6683835c375b'), 'PUBLISHED', 'claude_assessment_v5'),
  ('643fb802-1e33-5ef1-80ef-da32d197d76a', v_aid, 4, 'A1', 'reading', 'understand', 'multiple_choice', 'Коли пакет безкоштовний?', 'Akcija u supermarketu', '["Якщо покупка понад 50 €", "Завжди", "У суботу"]'::jsonb, 0, null, '{}'::text[], null, 'AKCIJA OD PONEDJELJKA DO SUBOTE!
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
  ('0a298eb4-d605-5bf4-ab64-afdf72c0b2f9', v_aid, 5, 'A1', 'reading', 'understand', 'multiple_choice', 'Що не можна робити з одягом до повернення?', 'Povrat robe', '["Прати його", "Носити його", "Приміряти його"]'::jsonb, 1, null, '{}'::text[], null, 'POVRAT I ZAMJENA ROBE
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
  ('043d1315-37a6-551a-a6c0-b4f2238e9add', v_aid, 6, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Koju marku mi preporučujete?', '["Jesu, iz mog vrta. I patlidžani su domaći.", "Ove dvije su slične, ali ova je povoljnija.", "Početkom tjedna imam liječnika, a u srijedu tečaj."]'::jsonb, 1, null, '{}'::text[], 'Koju marku mi preporučujete?', null, null, 'Діалог «Дві марки»: «Koju marku mi preporučujete?» (Яку марку ви мені радите?) — «Ove dvije su slične, ali ova je povoljnija.» (Ці дві схожі, але ця вигідніша.).', (select id from public.lessons where id = '7042ff57-9a20-514a-ab80-71b6f63579f7'), 'PUBLISHED', 'claude_assessment_v5'),
  ('f659b8a6-fdf0-5140-9533-947750a61e0e', v_aid, 7, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Ima li velike razlike u materijalu?', '["Ima. Crne su od kože i puno su trajnije.", "Riba na žaru. Potvrdit ću vam rezervaciju porukom.", "Svake večeri se vraćam oko šest."]'::jsonb, 0, null, '{}'::text[], 'Ima li velike razlike u materijalu?', null, null, 'Діалог «Які кросівки?»: «Ima li velike razlike u materijalu?» (А матеріал сильно відрізняється?) — «Ima. Crne su od kože i puno su trajnije.» (Так. Чорні шкіряні й набагато міцніші.).', (select id from public.lessons where id = '7042ff57-9a20-514a-ab80-71b6f63579f7'), 'PUBLISHED', 'claude_assessment_v5'),
  ('16a97acc-1977-556b-86f7-dc599dbff0d6', v_aid, 8, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Darja, kakav je tvoj stil?', '["Ružmarin i češnjak. Meso posoli i popapri.", "Volim sportsku odjeću. Visoke pete mi se ne sviđaju.", "Napravi mi kajganu i jedan tost, molim te."]'::jsonb, 1, null, '{}'::text[], 'Darja, kakav je tvoj stil?', null, null, 'Діалог «Про смаки»: «Darja, kakav je tvoj stil?» (Даріє, який у тебе стиль?) — «Volim sportsku odjeću. Visoke pete mi se ne sviđaju.» (Люблю спортивний одяг. Високі підбори мені не подобаються.).', (select id from public.lessons where id = '9a979d32-2f4b-5127-bc22-7292763c7de4'), 'PUBLISHED', 'claude_assessment_v5'),
  ('3f68ac74-70cc-5db6-89d2-653afba06816', v_aid, 9, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Predivan je! Možete li ga zamotati?', '["Не забудь капелюх, сонце сильне.", "Звісно, у подарунковий папір із червоною стрічкою.", "Добрий день, я шукаю подарунок для мами."]'::jsonb, 1, null, '{}'::text[], null, 'Daša: Dobar dan, tražim poklon za mamu.
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
  ('c55b36b9-1101-5306-8250-e1b4e2274a3e', v_aid, 10, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Kakve su recenzije?', '["У тебе є промокод? Введи його перед оплатою.", "Чудові. Додаю її в кошик.", "Чорну розпродали, але сині є."]'::jsonb, 1, null, '{}'::text[], null, 'Daša: Luka, ova internetska trgovina ima besplatnu dostavu.
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
  ('8484cb44-9634-58aa-b7f7-bfb8ed307364', v_aid, 11, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Можете вкоротити ці штани?». Що ви скажете?', null, '["Kako mi stoji ova jakna?", "Možete li skratiti ove hlače?", "Zamotajte u ukrasni papir, molim."]'::jsonb, 1, null, '{}'::text[], null, null, null, '«Можете вкоротити ці штани?» — «Možete li skratiti ove hlače?».', (select id from public.lessons where id = '7fb1b6e5-93b4-5776-b82b-25e7769fd32d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('61b828c9-88cb-5891-b5ce-84947820dc08', v_aid, 12, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Я беру купальник і шорти». Що ви скажете?', null, '["Više volim sportsku odjeću.", "Uzimam kupaći kostim i kratke hlače.", "Ova jakna je bolja i jeftinija."]'::jsonb, 1, null, '{}'::text[], null, null, null, '«Я беру купальник і шорти.» — «Uzimam kupaći kostim i kratke hlače.».', (select id from public.lessons where id = 'c8297811-44ed-55a2-8cb5-d1bd9b8a6a73'), 'PUBLISHED', 'claude_assessment_v5'),
  ('e935c709-285b-5c2c-912a-768775944dda', v_aid, 13, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «якість»', null, '[]'::jsonb, null, 'kvaliteta', '{}'::text[], null, null, null, '«якість» — kvaliteta.', (select id from public.lessons where id = '7042ff57-9a20-514a-ab80-71b6f63579f7'), 'PUBLISHED', 'claude_assessment_v5'),
  ('80808355-4a64-5430-8e92-7483e3951cdf', v_aid, 14, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Мені подобається твій стиль.»', null, '["tvoj", "se", "Sviđa", "stil.", "mi"]'::jsonb, null, 'Sviđa mi se tvoj stil.', array['Tvoj stil mi se sviđa.']::text[], null, null, null, '«Мені подобається твій стиль.» — «Sviđa mi se tvoj stil.».', (select id from public.lessons where id = '9a979d32-2f4b-5127-bc22-7292763c7de4'), 'PUBLISHED', 'claude_assessment_v5'),
  ('fd851510-09e4-51ac-bedc-af95e6bbf97e', v_aid, 15, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «У нас немає гелю для душу.»', null, '["tuširanje.", "gela", "za", "Nemamo"]'::jsonb, null, 'Nemamo gela za tuširanje.', array['Gela za tuširanje nemamo.']::text[], null, null, null, '«У нас немає гелю для душу.» — «Nemamo gela za tuširanje.».', (select id from public.lessons where id = '9ba8e62a-83fd-5b08-9e01-760bc0f7219f'), 'PUBLISHED', 'claude_assessment_v5'),
  ('3bf6936d-caf5-53eb-98ef-24c665494955', v_aid, 16, 'A1', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Мені потрібен дезодорант і гель для душу.»', null, '[]'::jsonb, null, 'Trebam dezodorans i gel za tuširanje.', '{}'::text[], null, null, null, '«Мені потрібен дезодорант і гель для душу.» — «Trebam dezodorans i gel za tuširanje.».', (select id from public.lessons where id = '9ba8e62a-83fd-5b08-9e01-760bc0f7219f'), 'PUBLISHED', 'claude_assessment_v5');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірки рівня A1 за схемою 2026-11-07 (модуль — 2 завдання на урок, середина — 30, фінал — 48) з діалогів, вправ і текстів уроків A1. Потрібна перевірка носієм.');
end $$;

-- Перевірка модуля A1.4 · Модуль A1.4 — Транспорт · 20 завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = 'a1-m04' and cefr = 'A1';
  if v_aid is null then raise exception 'Немає тесту a1-m04 — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = '5b4ff5be-6c2b-5f96-b7e7-572b3f087ccd') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from 'e092e4e7-b706-5e70-84b6-eaa665020394'::uuid then
    raise exception 'Тест a1-m04 прив’язаний не до модуля A1.4 — звірте базу';
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
  ('5b4ff5be-6c2b-5f96-b7e7-572b3f087ccd', v_aid, 1, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Так, квиток в один бік і бронювання місця.", "Є, але він дорожчий — двадцять п’ять євро.", "Добре. До п’ятниці все буде готово."]'::jsonb, 2, null, '{}'::text[], 'Može. Sve je gotovo do petka.', null, null, 'Прозвучало: «Može. Sve je gotovo do petka.» — «Добре. До п’ятниці все буде готово.».', (select id from public.lessons where id = 'cd5db261-a421-511d-8100-f86bf2335bbe'), 'PUBLISHED', 'claude_assessment_v5'),
  ('0ae04a3d-58cc-5b32-bd4b-d3d3416bcf0a', v_aid, 2, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Можна. За багажне відділення беремо два євро.", "Мені здається, у нього блохи.", "Добрий день. Ваш паспорт, будь ласка."]'::jsonb, 2, null, '{}'::text[], 'Dobar dan. Vašu putovnicu, molim.', null, null, 'Прозвучало: «Dobar dan. Vašu putovnicu, molim.» — «Добрий день. Ваш паспорт, будь ласка.».', (select id from public.lessons where id = '69ec0776-4f69-5f86-afac-6652234a7da5'), 'PUBLISHED', 'claude_assessment_v5'),
  ('e92a88d3-9784-57b7-a64b-88f04da2a345', v_aid, 3, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Можна, але це перша зона, щонайбільше дві години.", "Є, о десятій, без пересадки.", "Зупиніться перед готелем і почекайте мене п’ять хвилин."]'::jsonb, 0, null, '{}'::text[], 'Smijete, ali ovo je prva zona, najviše dva sata.', null, null, 'Прозвучало: «Smijete, ali ovo je prva zona, najviše dva sata.» — «Можна, але це перша зона, щонайбільше дві години.».', (select id from public.lessons where id = 'd6ca64d8-4c71-5936-a930-51e400f5681d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('2a3123f9-f4d3-501d-bcc2-99617da6e8a3', v_aid, 4, 'A1', 'reading', 'understand', 'multiple_choice', 'Коли паркування безкоштовне?', 'Parkiranje u gradu', '["У суботу", "У неділю та у свята", "Щодня після 15"]'::jsonb, 1, null, '{}'::text[], null, 'ZONA 1 – PARKIRANJE SE PLAĆA
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
  ('ace0b0b3-6772-59c1-8aaf-4a69b0c841ad', v_aid, 5, 'A1', 'reading', 'understand', 'multiple_choice', 'Коли авто має бути в порту?', 'Ljetni red plovidbe', '["За п’ять хвилин", "За пів години до відправлення", "За дві години"]'::jsonb, 1, null, '{}'::text[], null, 'Od lipnja do rujna trajekti iz Splita za Brač voze svaki sat, od pet ujutro do ponoći. Ljeti je velika gužva, zato putnici trebaju kupiti karte na internetu. Auti moraju biti u luci pola sata prije polaska. Pješaci mogu doći petnaest minuta prije.', 'З червня до вересня пороми зі Спліта на Брач ходять щогодини, з п’ятої ранку до опівночі. Улітку велика черга, тому пасажирам треба купувати квитки в інтернеті. Автомобілі мають бути в порту за пів години до відправлення. Пішоходи можуть прийти за п’ятнадцять хвилин до відправлення.', 'Текст «Літній розклад поромів». Правильна відповідь: «За пів години до відправлення».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('6114f637-4264-504a-89c5-1cd107802a35', v_aid, 6, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Gdje mogu platiti gorivo?', '["Unutra na blagajni, karticom ili gotovinom.", "Treba. Uzmi metlu i krpu, hvala što mi pomažeš!", "Zagrij pećnicu na sto osamdeset i peci ga četrdeset minuta."]'::jsonb, 0, null, '{}'::text[], 'Gdje mogu platiti gorivo?', null, null, 'Діалог «На заправці»: «Gdje mogu platiti gorivo?» (Де можна заплатити за пальне?) — «Unutra na blagajni, karticom ili gotovinom.» (Усередині на касі, карткою чи готівкою.).', (select id from public.lessons where id = 'd6ca64d8-4c71-5936-a930-51e400f5681d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('1b0886f1-a5fd-5455-b623-dc728d4b97b7', v_aid, 7, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Kolika je cijena vožnje do zračne luke?', '["Više ne, sada radim u školi.", "Ponekad, jer sam stalno iscrpljena.", "Oko trideset eura, prema taksimetru."]'::jsonb, 2, null, '{}'::text[], 'Kolika je cijena vožnje do zračne luke?', null, null, 'Діалог «Викликаю таксі»: «Kolika je cijena vožnje do zračne luke?» (Скільки коштує поїздка до аеропорту?) — «Oko trideset eura, prema taksimetru.» (Близько тридцяти євро, за таксометром.).', (select id from public.lessons where id = '458ee6ec-31d1-5758-adef-03612626088a'), 'PUBLISHED', 'claude_assessment_v5'),
  ('9e3164c5-03a2-5716-ab27-b5f33ec0a30c', v_aid, 8, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Je li dnevna karta važeća i u autobusu?', '["Za pola sata. Pratim pošiljku u aplikaciji.", "Jest, do ponoći, i tramvajem i autobusom.", "Na ime Kovalenko. Hvala!"]'::jsonb, 1, null, '{}'::text[], 'Je li dnevna karta važeća i u autobusu?', null, null, 'Діалог «У трамваї»: «Je li dnevna karta važeća i u autobusu?» (Денний квиток дійсний і в автобусі?) — «Jest, do ponoći, i tramvajem i autobusom.» (Так, до опівночі — і трамваєм, і автобусом.).', (select id from public.lessons where id = '0ef458c5-53cf-530a-99cf-4ccd6e0132e5'), 'PUBLISHED', 'claude_assessment_v5'),
  ('5c18bfb9-f463-5dd0-9e6f-beb6bc86326d', v_aid, 9, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'U četiri popodne. Želite li drugi razred?', '["Da, jednosmjernu kartu i rezervaciju sjedala.", "Gotovo ista. Druga je skuplja zbog imena.", "Trebaš. I obuj nepromočive čizme, pada snijeg."]'::jsonb, 0, null, '{}'::text[], 'U četiri popodne. Želite li drugi razred?', null, null, 'Діалог «На касі вокзалу»: «U četiri popodne. Želite li drugi razred?» (О четвертій дня. Бажаєте другий клас?) — «Da, jednosmjernu kartu i rezervaciju sjedala.» (Так, квиток в один бік і бронювання місця.).', (select id from public.lessons where id = 'cae7a47d-7fb4-5b03-a8cc-5a0df2ccd92f'), 'PUBLISHED', 'claude_assessment_v5'),
  ('066ce988-4272-5382-9fa3-fbfea7802a26', v_aid, 10, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Dobar dan, koliko košta iznajmljivanje bicikla na dan?', '["Покажи. Треба його накачати, у мене є насос.", "П’ятнадцять євро, із шоломом і замком.", "Працюють. Перевірте й дзвоник перед поїздкою."]'::jsonb, 1, null, '{}'::text[], null, 'Daša: Dobar dan, koliko košta iznajmljivanje bicikla na dan?
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
  ('a59fe87b-e7de-5c93-bb3a-4b7ce82fd0f5', v_aid, 11, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Dašo, koliko je još do izlaza za Zadar?', '["Близько п’ятдесяти кілометрів. Обережно, тут дорожні роботи.", "По радіо кажуть, що в лівій смузі зіткнення.", "Тоді зупинимося на першій зоні відпочинку."]'::jsonb, 0, null, '{}'::text[], null, 'Luka: Dašo, koliko je još do izlaza za Zadar?
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
  ('553c682a-9105-58d8-8c94-0e5484c78829', v_aid, 12, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Oprostite, kuda se ide na plažu?', '["Так, або автобусом номер два, він їде сюди до площі.", "Ні, десять хвилин пішки.", "Ідіть прямо, а потім у бік церкви."]'::jsonb, 2, null, '{}'::text[], null, 'Darja: Oprostite, kuda se ide na plažu?
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
  ('e30e8fb0-8a67-5834-a006-d8553b49fd24', v_aid, 13, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Я йду в місто». Що ви скажете?', null, '["Mogu li dobiti sjedalo do prolaza?", "Idem u grad.", "Pun rezervoar, molim."]'::jsonb, 1, null, '{}'::text[], null, null, null, '«Я йду в місто.» — «Idem u grad.».', (select id from public.lessons where id = '12012395-7359-503b-89c9-ee1807f89d6b'), 'PUBLISHED', 'claude_assessment_v5'),
  ('7ece71ba-fe0c-5ad0-a068-38a0f152ee63', v_aid, 14, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Візьми шолом і замок». Що ви скажете?', null, '["Moram nadoplatiti pokaznu kartu.", "Gdje je traka za prtljagu?", "Uzmi kacigu i lokot."]'::jsonb, 2, null, '{}'::text[], null, null, null, '«Візьми шолом і замок.» — «Uzmi kacigu i lokot.».', (select id from public.lessons where id = '0b04119b-4d38-5d99-8237-caa95fdcfd95'), 'PUBLISHED', 'claude_assessment_v5'),
  ('39e363f4-e0ec-5599-887b-b310523deef1', v_aid, 15, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «обганяти»', null, '[]'::jsonb, null, 'pretjecati', '{}'::text[], null, null, null, '«обганяти» — pretjecati.', (select id from public.lessons where id = '06f927cf-f38c-51b5-a1f9-696698ad23fb'), 'PUBLISHED', 'claude_assessment_v5'),
  ('fd668e8b-e45a-5160-9f1a-fdb336768c6d', v_aid, 16, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «ручна поклажа»', null, '[]'::jsonb, null, 'ručna prtljaga', '{}'::text[], null, null, null, '«ручна поклажа» — ručna prtljaga.', (select id from public.lessons where id = '69ec0776-4f69-5f86-afac-6652234a7da5'), 'PUBLISHED', 'claude_assessment_v5'),
  ('116b3859-7088-509b-8c16-3f9eb8732775', v_aid, 17, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Коли прибуває потяг?»', null, '["stiže", "vlak?", "Kada"]'::jsonb, null, 'Kada stiže vlak?', array['Kada vlak stiže?']::text[], null, null, null, '«Коли прибуває потяг?» — «Kada stiže vlak?».', (select id from public.lessons where id = 'cae7a47d-7fb4-5b03-a8cc-5a0df2ccd92f'), 'PUBLISHED', 'claude_assessment_v5'),
  ('2bfab5e1-f315-50fc-9f67-9c659958c9a4', v_aid, 18, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Це моя валіза.»', null, '["Ovo", "moj", "kofer.", "je"]'::jsonb, null, 'Ovo je moj kofer.', '{}'::text[], null, null, null, '«Це моя валіза.» — «Ovo je moj kofer.».', (select id from public.lessons where id = '69ec0776-4f69-5f86-afac-6652234a7da5'), 'PUBLISHED', 'claude_assessment_v5'),
  ('91d0feab-e4a8-57cc-8892-d7a613a90c3c', v_aid, 19, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Мені треба заправити бак.»', null, '["natočiti", "Moram", "gorivo."]'::jsonb, null, 'Moram natočiti gorivo.', '{}'::text[], null, null, null, '«Мені треба заправити бак.» — «Moram natočiti gorivo.».', (select id from public.lessons where id = 'd6ca64d8-4c71-5936-a930-51e400f5681d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('5285e4d3-7396-5635-adf9-4d84a9e84b33', v_aid, 20, 'A1', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Ти вже на роботі?»', null, '[]'::jsonb, null, 'Jesi li već na poslu?', '{}'::text[], null, null, null, '«Ти вже на роботі?» — «Jesi li već na poslu?».', (select id from public.lessons where id = '12012395-7359-503b-89c9-ee1807f89d6b'), 'PUBLISHED', 'claude_assessment_v5');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірки рівня A1 за схемою 2026-11-07 (модуль — 2 завдання на урок, середина — 30, фінал — 48) з діалогів, вправ і текстів уроків A1. Потрібна перевірка носієм.');
end $$;

-- Перевірка модуля A1.5 · Модуль A1.5 — Житло · 20 завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = 'a1-m05' and cefr = 'A1';
  if v_aid is null then raise exception 'Немає тесту a1-m05 — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = '770f9a84-05ba-5edc-b70a-174d3f3767ab') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from '82ce9ca7-ea90-5413-94a6-d69b1a1cd72b'::uuid then
    raise exception 'Тест a1-m05 прив’язаний не до модуля A1.5 — звірте базу';
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
  ('770f9a84-05ba-5edc-b70a-174d3f3767ab', v_aid, 1, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Запобіжник у порядку. Може, коротке замикання.", "Здебільшого так, цей житловий будинок спокійний.", "Спочатку фарбуємо стелю, потім стіни."]'::jsonb, 0, null, '{}'::text[], 'Osigurač je u redu. Možda je kratki spoj.', null, null, 'Прозвучало: «Osigurač je u redu. Možda je kratki spoj.» — «Запобіжник у порядку. Може, коротке замикання.».', (select id from public.lessons where id = '8fc3399d-0405-5517-9358-d3ad6308d860'), 'PUBLISHED', 'claude_assessment_v5'),
  ('3ef1ca1f-dfe9-56f4-a508-62efc6f525ab', v_aid, 2, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Добре. І постав термостат на двадцять два.", "Так, і напиши на коробці: «Обережно, крихке!»", "Тримай. Для картин вистачить молотка й цвяха."]'::jsonb, 2, null, '{}'::text[], 'Izvoli. Za slike je dosta čekić i čavao.', null, null, 'Прозвучало: «Izvoli. Za slike je dosta čekić i čavao.» — «Тримай. Для картин вистачить молотка й цвяха.».', (select id from public.lessons where id = 'dd2c0f3c-19f2-5c73-b448-a0631cd97e69'), 'PUBLISHED', 'claude_assessment_v5'),
  ('ce19ef29-f188-5536-9b81-8c444c5bc28c', v_aid, 3, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Це ремонтує завгосп, треба замінити лампочку.", "Можна. Довкола фонтана — найгарніша частина міста.", "Так. Потримай драбину, будь ласка, а я свердлитиму."]'::jsonb, 1, null, '{}'::text[], 'Može. Okolica fontane je najljepši dio grada.', null, null, 'Прозвучало: «Može. Okolica fontane je najljepši dio grada.» — «Можна. Довкола фонтана — найгарніша частина міста.».', (select id from public.lessons where id = '3ea9520d-2baa-56b2-aa85-402e3e3ecb9b'), 'PUBLISHED', 'claude_assessment_v5'),
  ('6fc8d4d7-72c2-5c63-bc12-0368859c001e', v_aid, 4, 'A1', 'reading', 'understand', 'multiple_choice', 'Коли Олена вдома?', 'Poruka stanodavcu', '["Цілий день", "Лише ввечері", "Лише вранці"]'::jsonb, 0, null, '{}'::text[], null, 'Dobar dan, gospodine Horvat,
grijanje u stanu opet ne radi. Radijatori su hladni od jučer, a vani je vrlo hladno. Djeca su bolesna. Možete li danas poslati majstora? Mi smo kod kuće cijeli dan.
Hvala,
Olena Kovalenko, stan broj 4', 'Добрий день, пане Горват,
опалення в квартирі знову не працює. Батареї холодні з учорашнього дня, а надворі дуже холодно. Діти хворі. Чи можете ви сьогодні прислати майстра? Ми вдома цілий день.
Дякую,
Олена Коваленко, квартира номер 4', 'Текст «Повідомлення орендодавцю». Правильна відповідь: «Цілий день».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('0cdd954a-b70f-5797-b9f3-f1ce45960ec5', v_aid, 5, 'A1', 'reading', 'understand', 'multiple_choice', 'Скільки кімнат у квартирі?', 'Oglas: stan za najam', '["Три", "Дві", "Одна"]'::jsonb, 1, null, '{}'::text[], null, 'IZNAJMLJUJEM STAN
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
  ('ea106a82-8286-5558-80eb-b8ca33ccfff3', v_aid, 6, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Dašo, kako ti je novi kvart?', '["Stavim piletinu u veliki lonac i zakuham vodu.", "Više ne, sada radim u školi.", "Odličan! U blizini su dućan, kiosk i pekara."]'::jsonb, 2, null, '{}'::text[], 'Dašo, kako ti je novi kvart?', null, null, 'Діалог «Що в тебе поруч?»: «Dašo, kako ti je novi kvart?» (Дашо, як тобі новий район?) — «Odličan! U blizini su dućan, kiosk i pekara.» (Чудовий! Поруч магазин, кіоск і пекарня.).', (select id from public.lessons where id = '3ea9520d-2baa-56b2-aa85-402e3e3ecb9b'), 'PUBLISHED', 'claude_assessment_v5'),
  ('18e84abd-6974-5289-bb7f-c876538998c1', v_aid, 7, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Gdje je ovdje pješačka zona?', '["Trebaš. I obuj nepromočive čizme, pada snijeg.", "Idite naprijed, pa prema crkvi.", "Odmah iza spomenika počinje stara jezgra."]'::jsonb, 2, null, '{}'::text[], 'Gdje je ovdje pješačka zona?', null, null, 'Діалог «Прогулянка старим містом»: «Gdje je ovdje pješačka zona?» (Де тут пішохідна зона?) — «Odmah iza spomenika počinje stara jezgra.» (Одразу за пам’ятником починається старе місто.).', (select id from public.lessons where id = '3ea9520d-2baa-56b2-aa85-402e3e3ecb9b'), 'PUBLISHED', 'claude_assessment_v5'),
  ('401a9b5e-8547-5c71-ad42-55d3237e2e9e', v_aid, 8, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Gdje bacamo otpad?', '["Kontejneri su iza zgrade. Papir i plastiku odvajamo.", "Napravi mi kajganu i jedan tost, molim te.", "Ružmarin i češnjak. Meso posoli i popapri."]'::jsonb, 0, null, '{}'::text[], 'Gdje bacamo otpad?', null, null, 'Діалог «Сміття й переробка»: «Gdje bacamo otpad?» (Куди викидаємо сміття?) — «Kontejneri su iza zgrade. Papir i plastiku odvajamo.» (Контейнери за будинком. Папір і пластик сортуємо.).', (select id from public.lessons where id = 'f296bc84-8059-5981-a5b9-9d4531627e18'), 'PUBLISHED', 'claude_assessment_v5'),
  ('5b391b82-586d-5438-a7c3-903a63f42c60', v_aid, 9, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Dašo, gdje su upute za komodu?', '["S drugog, ali danas kasni dvadeset minuta.", "U kutiji, na dnu. I vijci su u maloj vrećici.", "Izlaz sedam. Evo vaše ukrcajne propusnice."]'::jsonb, 1, null, '{}'::text[], 'Dašo, gdje su upute za komodu?', null, null, 'Діалог «Збираємо комод»: «Dašo, gdje su upute za komodu?» (Дашо, де інструкція до комода?) — «U kutiji, na dnu. I vijci su u maloj vrećici.» (У коробці, на дні. І гвинти в маленькому пакетику.).', (select id from public.lessons where id = 'de93d3ab-6769-5daf-9560-8858285a8136'), 'PUBLISHED', 'claude_assessment_v5'),
  ('60c5785c-b8d7-5097-8273-258a90ce3e3a', v_aid, 10, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Kada je rok plaćanja?', '["До п’ятнадцятого. Зараз заплачу через мобільний банкінг.", "Скільки? Цього літа в нас велике споживання.", "Тридцять євро. А вивіз сміття — окремо."]'::jsonb, 0, null, '{}'::text[], null, 'Luka: Dašo, evo računa za vodu.
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
  ('3b86dcc9-5143-507f-be60-b8f6875ec2c6', v_aid, 11, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Kada se moramo iseliti iz starog stana?', '["Склянки треба пакувати окремо, вони крихкі.", "Дякую! Якщо вам щось треба, стукайте без вагань.", "До кінця місяця. Компанія з перевезень приїде в суботу."]'::jsonb, 2, null, '{}'::text[], null, 'Luka: Kada se moramo iseliti iz starog stana?
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
  ('b5d0ae20-ae0b-56a3-8956-74aead96614f', v_aid, 12, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Mogu. Imaš li kombi?', '["Є, але я не можу сама перенести шафу.", "Добре, але спочатку піца!", "Без проблем, удвох ми її піднімемо."]'::jsonb, 0, null, '{}'::text[], null, 'Darja: Marko, možeš li mi pomoći u subotu? Selim se.
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
  ('2536db30-c6a7-51b4-a301-34bfc8b772cb', v_aid, 13, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Наш район тихий і безпечний». Що ви скажете?', null, '["Naš kvart je miran i siguran.", "Upali ventilator.", "Slavina curi."]'::jsonb, 0, null, '{}'::text[], null, null, null, '«Наш район тихий і безпечний.» — «Naš kvart je miran i siguran.».', (select id from public.lessons where id = '3ea9520d-2baa-56b2-aa85-402e3e3ecb9b'), 'PUBLISHED', 'claude_assessment_v5'),
  ('654adeb2-2426-519f-b3ac-64750f8ce9f7', v_aid, 14, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Де правила будинку?». Що ви скажете?', null, '["Treba nam blagovaonski stol.", "Gdje je kućni red?", "Selim se u subotu."]'::jsonb, 1, null, '{}'::text[], null, null, null, '«Де правила будинку?» — «Gdje je kućni red?».', (select id from public.lessons where id = 'f296bc84-8059-5981-a5b9-9d4531627e18'), 'PUBLISHED', 'claude_assessment_v5'),
  ('123a51fe-4796-5c79-ab0b-bd1c63e342bb', v_aid, 15, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «вибачитися»', null, '[]'::jsonb, null, 'ispričati se', '{}'::text[], null, null, null, '«вибачитися» — ispričati se.', (select id from public.lessons where id = 'a42b9121-2ec0-5064-909b-f59f315b3c4a'), 'PUBLISHED', 'claude_assessment_v5'),
  ('4d648c5b-5dd8-5bcd-92f9-c5ed27f06b13', v_aid, 16, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «зливний бачок»', null, '[]'::jsonb, null, 'vodokotlić', '{}'::text[], null, null, null, '«зливний бачок» — vodokotlić.', (select id from public.lessons where id = '8fc3399d-0405-5517-9358-d3ad6308d860'), 'PUBLISHED', 'claude_assessment_v5'),
  ('ba303c1b-b573-5021-8693-1620593fbc3b', v_aid, 17, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Потримай драбину, будь ласка.»', null, '["ljestve,", "Drži", "molim", "te."]'::jsonb, null, 'Drži ljestve, molim te.', array['Molim te, drži ljestve.']::text[], null, null, null, '«Потримай драбину, будь ласка.» — «Drži ljestve, molim te.».', (select id from public.lessons where id = 'dd2c0f3c-19f2-5c73-b448-a0631cd97e69'), 'PUBLISHED', 'claude_assessment_v5'),
  ('5bebc41b-b524-5202-8a04-8d54bd45e58f', v_aid, 18, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Треба провітрити ванну.»', null, '["kupaonicu.", "prozračiti", "Treba"]'::jsonb, null, 'Treba prozračiti kupaonicu.', array['Kupaonicu treba prozračiti.']::text[], null, null, null, '«Треба провітрити ванну.» — «Treba prozračiti kupaonicu.».', (select id from public.lessons where id = '62b118f9-a5e0-587b-82f8-39de181ddeba'), 'PUBLISHED', 'claude_assessment_v5'),
  ('6fd6d69e-a53d-57d7-a1af-49cd22d4c61f', v_aid, 19, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Подай мені викрутку.»', null, '["Dodaj", "odvijač.", "mi"]'::jsonb, null, 'Dodaj mi odvijač.', '{}'::text[], null, null, null, '«Подай мені викрутку.» — «Dodaj mi odvijač.».', (select id from public.lessons where id = 'dd2c0f3c-19f2-5c73-b448-a0631cd97e69'), 'PUBLISHED', 'claude_assessment_v5'),
  ('820a3e8b-65fc-562f-9f99-6686957552a3', v_aid, 20, 'A1', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Яка застава?»', null, '[]'::jsonb, null, 'Koliki je polog?', '{}'::text[], null, null, null, '«Яка застава?» — «Koliki je polog?».', (select id from public.lessons where id = '278947e3-ae50-5818-abd7-7f07b8ab5c44'), 'PUBLISHED', 'claude_assessment_v5');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірки рівня A1 за схемою 2026-11-07 (модуль — 2 завдання на урок, середина — 30, фінал — 48) з діалогів, вправ і текстів уроків A1. Потрібна перевірка носієм.');
end $$;

-- Перевірка модуля A1.6 · Модуль A1.6 — Робота · 18 завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = 'a1-m06' and cefr = 'A1';
  if v_aid is null then raise exception 'Немає тесту a1-m06 — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = '157895d5-87f8-5284-8648-4763294d5208') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from '03c65998-2648-5d02-9254-f67ce765fe27'::uuid then
    raise exception 'Тест a1-m06 прив’язаний не до модуля A1.6 — звірте базу';
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
  update public.assessments set description_ua = 'Після модуля: 18 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~9 хв.', estimated_minutes = 9 where id = v_aid;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, answer_alternatives, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('157895d5-87f8-5284-8648-4763294d5208', v_aid, 1, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Як я можу подати заявку?", "Я бачила оголошення про роботу. Ви ще шукаєте продавчиню?", "Чудово. А до того? Мені шукати підробіток?"]'::jsonb, 2, null, '{}'::text[], 'Super. A do tada? Trebam li honorarni posao?', null, null, 'Прозвучало: «Super. A do tada? Trebam li honorarni posao?» — «Чудово. А до того? Мені шукати підробіток?».', (select id from public.lessons where id = 'c9b87882-5e31-5485-aea7-0169216466a8'), 'PUBLISHED', 'claude_assessment_v5'),
  ('c58095f1-673d-5468-815c-3c9cc7cbf655', v_aid, 2, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Трохи. Наставник сказав, що безпека — найважливіше.", "Першого дня я отримав робочий одяг і захисне спорядження.", "Лише надворі. У будівлі діє заборона куріння."]'::jsonb, 1, null, '{}'::text[], 'Prvi dan sam dobio radnu odjeću i zaštitnu opremu.', null, null, 'Прозвучало: «Prvi dan sam dobio radnu odjeću i zaštitnu opremu.» — «Першого дня я отримав робочий одяг і захисне спорядження.».', (select id from public.lessons where id = '2c56a486-dbbb-5102-b7cb-754c59cf94c3'), 'PUBLISHED', 'claude_assessment_v5'),
  ('92e18ead-32af-5467-b6e7-ebd3ed5544eb', v_aid, 3, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Ти отримала лікарняний лист?", "Коли виплата?", "Яка ваша найсильніша навичка?"]'::jsonb, 0, null, '{}'::text[], 'Jesi li dobila doznaku za bolovanje?', null, null, 'Прозвучало: «Jesi li dobila doznaku za bolovanje?» — «Ти отримала лікарняний лист?».', (select id from public.lessons where id = 'e806dd39-4d38-5781-ad2d-949961dd95f9'), 'PUBLISHED', 'claude_assessment_v5'),
  ('ceab5a3d-ad50-597c-99bc-30d5a4acd1ca', v_aid, 4, 'A1', 'reading', 'understand', 'multiple_choice', 'Коли повідомити про лікарняний?', 'Raspored smjena', '["До початку зміни", "Після зміни", "За тиждень"]'::jsonb, 0, null, '{}'::text[], null, 'RASPORED SMJENA – SKLADIŠTE
Jutarnja smjena: od 6 do 14 sati.
Popodnevna smjena: od 14 do 22 sata.
Pauza: 30 minuta, u kantini na prvom katu.
Zamjenu smjene dogovorite s voditeljem dan prije.
Bolovanje javite voditelju prije početka smjene.', 'РОЗКЛАД ЗМІН – СКЛАД
Ранкова зміна: з 6 до 14 години.
Денна зміна: з 14 до 22 години.
Перерва: 30 хвилин, у їдальні на першому поверсі.
Обмін змінами погоджуйте з керівником за день.
Про лікарняний повідомте керівника до початку зміни.', 'Текст «Розклад змін». Правильна відповідь: «До початку зміни».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('a0789505-00c2-5a61-af5a-68976988fc8f', v_aid, 5, 'A1', 'reading', 'understand', 'multiple_choice', 'Ким працює Оксана?', 'Oksana na poslu', '["Кухаркою", "Прибиральницею", "Доглядальницею"]'::jsonb, 2, null, '{}'::text[], null, 'Oksana radi kao njegovateljica. Svako jutro dolazi kod gospođe Marije. Gospođa Marija ima osamdeset godina i živi sama. Oksana joj kuha ručak, ide s njom u šetnju i daje joj lijekove. Gospođa Marija joj priča o Zagrebu, a Oksana uči nove riječi. Posao nije lak, ali Oksana ga voli.', 'Оксана працює доглядальницею. Щоранку вона приходить до пані Марії. Пані Марії вісімдесят років, і вона живе сама. Оксана готує їй обід, ходить з нею на прогулянку й дає їй ліки. Пані Марія розповідає їй про Загреб, а Оксана вивчає нові слова. Робота не легка, але Оксана її любить.', 'Текст «Оксана на роботі». Правильна відповідь: «Доглядальницею».', null, 'PUBLISHED', 'claude_assessment_v5'),
  ('9e2344f8-fae5-521e-b8c7-268cbfd671cb', v_aid, 6, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Smijem li pušiti u pauzi?', '["Radimo roštilj u vrtu, a u nedjelju idemo planinariti.", "Nažalost nemam, imam sastanak cijeli dan.", "Samo vani. U zgradi vrijedi zabrana pušenja."]'::jsonb, 2, null, '{}'::text[], 'Smijem li pušiti u pauzi?', null, null, 'Діалог «Правила в ресторані»: «Smijem li pušiti u pauzi?» (Можна курити на перерві?) — «Samo vani. U zgradi vrijedi zabrana pušenja.» (Лише надворі. У будівлі діє заборона куріння.).', (select id from public.lessons where id = '99088d92-0f0c-52c2-b51f-548d903fc9ef'), 'PUBLISHED', 'claude_assessment_v5'),
  ('ead3037c-455d-5eef-956a-4874a11c2c65', v_aid, 7, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Kako se mogu prijaviti?', '["Ružmarin i češnjak. Meso posoli i popapri.", "Na košulji nedostaje jedan gumb na ovratniku.", "Pošaljite životopis i kratko motivacijsko pismo."]'::jsonb, 2, null, '{}'::text[], 'Kako se mogu prijaviti?', null, null, 'Діалог «Вакансія в пекарні»: «Kako se mogu prijaviti?» (Як я можу подати заявку?) — «Pošaljite životopis i kratko motivacijsko pismo.» (Надішліть резюме й короткий мотиваційний лист.).', (select id from public.lessons where id = 'c9b87882-5e31-5485-aea7-0169216466a8'), 'PUBLISHED', 'claude_assessment_v5'),
  ('802892fa-7717-5961-8cef-4f6a5e4c999c', v_aid, 8, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Kada možete početi?', '["Kad mijenjam brzinu. I svijetli lampica akumulatora.", "Iznad stolića u dnevnom boravku.", "Od prvog sljedećeg mjeseca."]'::jsonb, 2, null, '{}'::text[], 'Kada možete početi?', null, null, 'Діалог «Навички й досвід»: «Kada možete početi?» (Коли можете почати?) — «Od prvog sljedećeg mjeseca.» (З першого числа наступного місяця.).', (select id from public.lessons where id = '92858dbe-ede1-5bc5-b80a-c796c5598019'), 'PUBLISHED', 'claude_assessment_v5'),
  ('dae9965d-3f96-5e7c-8cf1-f5063d0d777f', v_aid, 9, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Dašo, kako je bio prvi dan?', '["Super! Upoznala sam cijeli tim.", "Subotom se izležavam, a nedjeljom idem na izlet.", "Volim sportsku odjeću. Visoke pete mi se ne sviđaju."]'::jsonb, 0, null, '{}'::text[], 'Dašo, kako je bio prvi dan?', null, null, 'Діалог «Як було?»: «Dašo, kako je bio prvi dan?» (Дашо, як минув перший день?) — «Super! Upoznala sam cijeli tim.» (Чудово! Я познайомилася з усією командою.).', (select id from public.lessons where id = '2c56a486-dbbb-5102-b7cb-754c59cf94c3'), 'PUBLISHED', 'claude_assessment_v5'),
  ('f344d1de-c9db-58e3-b66b-a482eb636a10', v_aid, 10, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Darja, radiš li od kuće?', '["Два дні на тиждень. Начальник каже, що це нормально.", "Бачимося в офісі по вівторках і четвергах.", "Через відеодзвінки й імейл."]'::jsonb, 0, null, '{}'::text[], null, 'Marko: Darja, radiš li od kuće?
Darja: Dva dana tjedno. Šef kaže da je to u redu.
Marko: Kako razgovaraš s klijentima?
Darja: Preko videopoziva i maila.
Marko: A kolege?
Darja: Vidimo se u uredu utorkom i četvrtkom.', 'Marko: Даріє, ти працюєш з дому?
Darja: Два дні на тиждень. Начальник каже, що це нормально.
Marko: Як ти спілкуєшся з клієнтами?
Darja: Через відеодзвінки й імейл.
Marko: А колеги?
Darja: Бачимося в офісі по вівторках і четвергах.', 'Діалог «Робота з дому»: «Darja, radiš li od kuće?» — «Dva dana tjedno. Šef kaže da je to u redu.», тобто «Два дні на тиждень. Начальник каже, що це нормально.».', (select id from public.lessons where id = 'd813e9c0-2331-59d8-90f1-cea7e9a61c7d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('24c959c5-f15e-5ae3-b314-a3d83e0bf971', v_aid, 11, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Zašto je neto plaća toliko manja od bruto?', '["У розрахунковому листку, під основною зарплатою.", "Із брутто сплачуються податок і внески.", "До десятого. У червні отримаєш ще відпускні, а в грудні — різдвяну премію."]'::jsonb, 1, null, '{}'::text[], null, 'Luka: Zašto je neto plaća toliko manja od bruto?
Kolegica: Od bruto plaće se plaćaju porez i doprinosi.
Luka: A gdje vidim prekovremene sate?
Kolegica: Na platnoj listi, ispod osnovne plaće.
Luka: Kada je isplata?
Kolegica: Do desetog. U lipnju dobiješ i regres, a u prosincu božićnicu.', 'Luka: Чому зарплата нетто настільки менша за брутто?
Kolegica: Із брутто сплачуються податок і внески.
Luka: А де я бачу понаднормові години?
Kolegica: У розрахунковому листку, під основною зарплатою.
Luka: Коли виплата?
Kolegica: До десятого. У червні отримаєш ще відпускні, а в грудні — різдвяну премію.', 'Діалог «Перша зарплата»: «Zašto je neto plaća toliko manja od bruto?» — «Od bruto plaće se plaćaju porez i doprinosi.», тобто «Із брутто сплачуються податок і внески.».', (select id from public.lessons where id = '4d6f3498-2cc5-54a0-b4e4-c66add71ef12'), 'PUBLISHED', 'claude_assessment_v5'),
  ('4c75004e-f145-594f-a680-380a42c7ddf3', v_aid, 12, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Я працюю з дому». Що ви скажете?', null, '["Ovdje se ne smije pušiti.", "Kako je bio prvi dan?", "Radim od kuće."]'::jsonb, 2, null, '{}'::text[], null, null, null, '«Я працюю з дому.» — «Radim od kuće.».', (select id from public.lessons where id = 'd813e9c0-2331-59d8-90f1-cea7e9a61c7d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('6e6a7fb1-6f88-56be-b000-26558a8064f4', v_aid, 13, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Коли ти починаєш працювати?». Що ви скажете?', null, '["Kada počinješ raditi?", "Gdje je sala za sastanke?", "Prehlađen sam, danas ne dolazim."]'::jsonb, 0, null, '{}'::text[], null, null, null, '«Коли ти починаєш працювати?» — «Kada počinješ raditi?».', (select id from public.lessons where id = 'd813e9c0-2331-59d8-90f1-cea7e9a61c7d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('236dc0ab-b48f-5d00-b807-99cdc336c2bd', v_aid, 14, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «податок»', null, '[]'::jsonb, null, 'porez', '{}'::text[], null, null, null, '«податок» — porez.', (select id from public.lessons where id = '4d6f3498-2cc5-54a0-b4e4-c66add71ef12'), 'PUBLISHED', 'claude_assessment_v5'),
  ('e410ee0d-01ef-5859-8b9e-4c4697e1a480', v_aid, 15, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «секретарка»', null, '[]'::jsonb, null, 'tajnica', '{}'::text[], null, null, null, '«секретарка» — tajnica.', (select id from public.lessons where id = 'e806dd39-4d38-5781-ad2d-949961dd95f9'), 'PUBLISHED', 'claude_assessment_v5'),
  ('27319fcd-26c9-53d3-bd56-1203c0135e9c', v_aid, 16, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Він працює на будові.»', null, '["na", "On", "gradilištu.", "radi"]'::jsonb, null, 'On radi na gradilištu.', '{}'::text[], null, null, null, '«Він працює на будові.» — «On radi na gradilištu.».', (select id from public.lessons where id = 'b369f01f-4a84-57b4-98cb-150d236f4d7f'), 'PUBLISHED', 'claude_assessment_v5'),
  ('39dc1e42-8b8a-56ef-9979-48d2db1c6c48', v_aid, 17, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Я працюю на рецепції.»', null, '["na", "Radim", "recepciji."]'::jsonb, null, 'Radim na recepciji.', '{}'::text[], null, null, null, '«Я працюю на рецепції.» — «Radim na recepciji.».', (select id from public.lessons where id = 'b369f01f-4a84-57b4-98cb-150d236f4d7f'), 'PUBLISHED', 'claude_assessment_v5'),
  ('ff833f40-75b9-5b26-b4f4-570d7bbf3fdf', v_aid, 18, 'A1', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Надішліть резюме, будь ласка.»', null, '[]'::jsonb, null, 'Pošaljite životopis, molim.', '{}'::text[], null, null, null, '«Надішліть резюме, будь ласка.» — «Pošaljite životopis, molim.».', (select id from public.lessons where id = 'c9b87882-5e31-5485-aea7-0169216466a8'), 'PUBLISHED', 'claude_assessment_v5');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірки рівня A1 за схемою 2026-11-07 (модуль — 2 завдання на урок, середина — 30, фінал — 48) з діалогів, вправ і текстів уроків A1. Потрібна перевірка носієм.');
end $$;

-- Перевірка модуля A1.7 · Модуль A1.7 — Комп’ютер, телефон та інтернет · 14 завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = 'a1-m07' and cefr = 'A1';
  if v_aid is null then raise exception 'Немає тесту a1-m07 — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = '95d7e62b-3440-5abf-b116-a61e4a3e058a') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from '09e7c668-b622-56b2-82e9-b1c0c0db54c6'::uuid then
    raise exception 'Тест a1-m07 прив’язаний не до модуля A1.7 — звірте базу';
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
  ('95d7e62b-3440-5abf-b116-a61e4a3e058a', v_aid, 1, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Видали рекламу, а важливі прочитай.", "Це полагодимо вдома. Зараз їдь повільно.", "Добрий день, мій акаунт заблоковано."]'::jsonb, 2, null, '{}'::text[], 'Dobar dan, korisnički račun mi je blokiran.', null, null, 'Прозвучало: «Dobar dan, korisnički račun mi je blokiran.» — «Добрий день, мій акаунт заблоковано.».', (select id from public.lessons where id = 'f355be7d-c423-5651-938e-71b8ca970a62'), 'PUBLISHED', 'claude_assessment_v5'),
  ('829382b1-fa80-5093-8049-a068093c55c9', v_aid, 2, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Ні, на острові немає сигналу.", "Мобільним токеном банку або ID-карткою із сертифікатом.", "Пише, що його треба перезавантажити."]'::jsonb, 0, null, '{}'::text[], 'Nisam, na otoku nema signala.', null, null, 'Прозвучало: «Nisam, na otoku nema signala.» — «Ні, на острові немає сигналу.».', (select id from public.lessons where id = '35203547-5f9a-5857-95a0-3a0d596f715d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('2381f0e7-6cea-5898-a40c-58b49aeca43d', v_aid, 3, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Натисни «Забули пароль?».", "Мене хтось зламав? Я боюся хакерів.", "Батарея розряджена. Спершу зарядь його."]'::jsonb, 1, null, '{}'::text[], 'Je li me netko hakirao? Bojim se hakera.', null, null, 'Прозвучало: «Je li me netko hakirao? Bojim se hakera.» — «Мене хтось зламав? Я боюся хакерів.».', (select id from public.lessons where id = 'f355be7d-c423-5651-938e-71b8ca970a62'), 'PUBLISHED', 'claude_assessment_v5'),
  ('e955a6b5-7ebb-5f17-a71f-df368d0b4168', v_aid, 4, 'A1', 'reading', 'understand', 'multiple_choice', 'Що можна робити після входу?', 'Prijava u e-Građane', '["Бачити документи й заповнити форму", "Купувати квитки", "Дзвонити лікареві"]'::jsonb, 0, null, '{}'::text[], null, 'Kako se prijaviti u e-Građane?
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
  ('60b0ed19-ee63-5f4a-97d0-4a3b6b00a098', v_aid, 5, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Ivana, kako mogu dobiti potvrdu o prebivalištu?', '["Preko e-Građana, ne moraš ići u ured.", "Od bruto plaće se plaćaju porez i doprinosi.", "Uglavnom da, ova stambena zgrada je mirna."]'::jsonb, 0, null, '{}'::text[], 'Ivana, kako mogu dobiti potvrdu o prebivalištu?', null, null, 'Діалог «Довідка через e-Građani»: «Ivana, kako mogu dobiti potvrdu o prebivalištu?» (Івано, як мені отримати довідку про місце проживання?) — «Preko e-Građana, ne moraš ići u ured.» (Через e-Građani, не треба йти в установу.).', (select id from public.lessons where id = '953e12fb-a6f6-5ae5-aa7a-ebfe248d24da'), 'PUBLISHED', 'claude_assessment_v5'),
  ('251d0924-a7b8-56c7-98a1-9bdab115719d', v_aid, 6, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Nisam. Gdje se to radi?', '["Od prvog sljedećeg mjeseca.", "Više ne, sada radim u školi.", "Klikni mišem na postavke, pa na «Ažuriranje»."]'::jsonb, 2, null, '{}'::text[], 'Nisam. Gdje se to radi?', null, null, 'Діалог «Комп’ютер гальмує»: «Nisam. Gdje se to radi?» (Ні. Де це робиться?) — «Klikni mišem na postavke, pa na «Ažuriranje».» (Клацни мишкою на налаштування, а потім на «Оновлення».).', (select id from public.lessons where id = '8e08a8e3-8969-52fc-bc82-5a403dd7ad35'), 'PUBLISHED', 'claude_assessment_v5'),
  ('9d96e4a5-5cc2-52ac-b56a-37b275cae933', v_aid, 7, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Dobro, uzimam njega. Treba li mi adapter?', '["Ne treba, kabel je u kutiji.", "U Kijevu sam radila kao računovođa šest godina.", "Odlične. Dodajem je u košaricu."]'::jsonb, 0, null, '{}'::text[], 'Dobro, uzimam njega. Treba li mi adapter?', null, null, 'Діалог «Ноутбук для навчання»: «Dobro, uzimam njega. Treba li mi adapter?» (Добре, беру його. Мені потрібен перехідник?) — «Ne treba, kabel je u kutiji.» (Не потрібен, кабель у коробці.).', (select id from public.lessons where id = '31bbedca-4b51-5478-8513-df5cb996ffd9'), 'PUBLISHED', 'claude_assessment_v5'),
  ('ecf7fced-61d6-51c7-9b24-539ead310e48', v_aid, 8, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Jesam! Snimila si ga na Plitvicama?', '["Дякую! Тепер у мене двісті нових підписників.", "Так. Я опублікувала його вчора, і вже сто коментарів.", "Чудово, але твій профіль публічний, обережно."]'::jsonb, 1, null, '{}'::text[], null, 'Ivana: Dašo, jesi li vidjela moj novi video?
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
  ('fa287595-c6c6-5b90-815d-e7850038fea6', v_aid, 9, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Pametno. Što si zadnje objavila?', '["Допис про курси хорватської, шукаю партнера для розмов.", "Тому мій профіль приватний.", "Іноді, але не коментую."]'::jsonb, 0, null, '{}'::text[], null, 'Marko: Čitaš li vijesti na društvenim mrežama?
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
  ('9a69141b-cad1-556b-8e38-3bfe1f207642', v_aid, 10, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Мені потрібна SIM-картка». Що ви скажете?', null, '["Učitajte dokument.", "Trebam SIM karticu.", "Poslao sam ti mail."]'::jsonb, 1, null, '{}'::text[], null, null, null, '«Мені потрібна SIM-картка.» — «Trebam SIM karticu.».', (select id from public.lessons where id = '35203547-5f9a-5857-95a0-3a0d596f715d'), 'PUBLISHED', 'claude_assessment_v5'),
  ('87853e91-566f-5571-980b-26f1cb2769fe', v_aid, 11, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Збережи вкладення». Що ви скажете?', null, '["Ponovno pokreni računalo.", "Spremi privitak.", "Kako mogu dobiti potvrdu preko interneta?"]'::jsonb, 1, null, '{}'::text[], null, null, null, '«Збережи вкладення.» — «Spremi privitak.».', (select id from public.lessons where id = '71537166-9f48-503f-b564-3a4f99a192c5'), 'PUBLISHED', 'claude_assessment_v5'),
  ('2c714ef6-77e6-5d5b-8d63-04fb7fae4651', v_aid, 12, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «планшет»', null, '[]'::jsonb, null, 'tablet', '{}'::text[], null, null, null, '«планшет» — tablet.', (select id from public.lessons where id = '31bbedca-4b51-5478-8513-df5cb996ffd9'), 'PUBLISHED', 'claude_assessment_v5'),
  ('db3640ea-ade4-5f09-9039-3cefa6ff708c', v_aid, 13, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Спершу зарядь телефон.»', null, '["Prvo", "mobitel.", "napuni"]'::jsonb, null, 'Prvo napuni mobitel.', array['Napuni prvo mobitel.']::text[], null, null, null, '«Спершу зарядь телефон.» — «Prvo napuni mobitel.».', (select id from public.lessons where id = '8e08a8e3-8969-52fc-bc82-5a403dd7ad35'), 'PUBLISHED', 'claude_assessment_v5'),
  ('a7480882-aa35-5a31-b6c2-75f0388da214', v_aid, 14, 'A1', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Ти бачила моє відео?»', null, '[]'::jsonb, null, 'Jesi li vidjela moj video?', '{}'::text[], null, null, null, '«Ти бачила моє відео?» — «Jesi li vidjela moj video?».', (select id from public.lessons where id = '4edd1556-f088-5d14-8f59-529b35747609'), 'PUBLISHED', 'claude_assessment_v5');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірки рівня A1 за схемою 2026-11-07 (модуль — 2 завдання на урок, середина — 30, фінал — 48) з діалогів, вправ і текстів уроків A1. Потрібна перевірка носієм.');
end $$;

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_new int; v_bad int;
begin
  select count(*) into v_new from public.assessment_items where id in ('15676330-4f1c-52f6-ae93-73ae74ad7d03', '54a304fb-c687-505a-8fdf-d801e9599204', '847b1aef-67dc-5d49-8533-5361ace111bc', '4f518116-4db9-5b33-ac0d-2e08963e7e7a', '4f06eda3-7f34-5875-9704-cd35d4df9c29', 'd3e8c458-31dd-509a-9671-9f8127601c3e', '1502e215-93aa-536a-a69e-326b0bcdf987', '60d7975a-c196-5951-a124-1925aa0cfb9c', 'ec5b0df6-f3b4-50d4-9aaf-7b53d351f11a', '1724f917-1107-537c-8231-36d7bc14ae3a', '8018686e-2bf5-559b-9ba8-c1c36d3bcd85', '3032f3aa-7479-5d20-a36b-2f9da00b854d', '3aa1e802-5bb7-58dd-9add-cee86bfc3686', 'c1619d7e-7e6f-5bd0-b5a7-8eb91a7ca596', 'b32e622c-118b-547d-ab0e-ef7fbe0e7369', '8eef2566-9652-51d6-9d01-f3518defcd5f', '6528306c-c0da-5096-a550-43d2083ef461', '4cd402b3-b2a6-568f-a4a5-74d5dff362b4', '2f5b5c43-69ab-549e-b196-1e8879af3b05', 'eeddbd88-68db-5153-a5dd-e82a15732b64', 'bd606cd7-5fc3-59bd-922c-bacbce88aba3', 'c1f013ec-21d8-51c5-859a-75da3eed1cbf', '4216fd1f-936a-592e-8b65-39b1631e81e3', 'bb952a0b-31a2-5660-b055-15797b6e518c', 'ca57b200-927e-5495-8f40-35a8f3f24666', 'fe5a6014-98dd-5bda-a407-d9b25e688f96', 'daffad3a-7451-5089-afc0-59484d72573c', '5d541ca0-71c0-5767-901b-28ba8e14fd7d', 'f869f916-5520-523b-b397-3ea67c5a6a31', '1ed4e1b3-461a-557e-b4da-3d1e023c059b', '55cf3870-3bef-5ef4-b300-80304e3b1131', 'e8b5b2c0-7f98-52ab-abe0-e93164166806', '1adf736b-5b6b-52cf-9eae-4d7eae9c2956', '6d7b044a-4e28-5276-84c2-bfe28d17bab1', '899b25e8-6513-514d-8f71-527466d28ee0', 'a49f8115-3568-5d13-b772-8d7010cabf50', '35b6c8b6-c27a-58fc-bbcb-bf577ee83a73', 'a052cdcb-8b5c-5704-ac78-4bdc2e3994c6', 'e94bff69-4391-52e6-bdd5-718925e8b3a9', '0f4eb934-c922-5df6-9450-8ab58dc9d5b0', 'b9fea7ff-1f74-5754-9d98-111634811632', '472b5838-c796-57d3-8397-b3a1870653df', '531abfee-3309-5a78-a66e-a65a7726b019', '643fb802-1e33-5ef1-80ef-da32d197d76a', '0a298eb4-d605-5bf4-ab64-afdf72c0b2f9', '043d1315-37a6-551a-a6c0-b4f2238e9add', 'f659b8a6-fdf0-5140-9533-947750a61e0e', '16a97acc-1977-556b-86f7-dc599dbff0d6', '3f68ac74-70cc-5db6-89d2-653afba06816', 'c55b36b9-1101-5306-8250-e1b4e2274a3e', '8484cb44-9634-58aa-b7f7-bfb8ed307364', '61b828c9-88cb-5891-b5ce-84947820dc08', 'e935c709-285b-5c2c-912a-768775944dda', '80808355-4a64-5430-8e92-7483e3951cdf', 'fd851510-09e4-51ac-bedc-af95e6bbf97e', '3bf6936d-caf5-53eb-98ef-24c665494955', '5b4ff5be-6c2b-5f96-b7e7-572b3f087ccd', '0ae04a3d-58cc-5b32-bd4b-d3d3416bcf0a', 'e92a88d3-9784-57b7-a64b-88f04da2a345', '2a3123f9-f4d3-501d-bcc2-99617da6e8a3', 'ace0b0b3-6772-59c1-8aaf-4a69b0c841ad', '6114f637-4264-504a-89c5-1cd107802a35', '1b0886f1-a5fd-5455-b623-dc728d4b97b7', '9e3164c5-03a2-5716-ab27-b5f33ec0a30c', '5c18bfb9-f463-5dd0-9e6f-beb6bc86326d', '066ce988-4272-5382-9fa3-fbfea7802a26', 'a59fe87b-e7de-5c93-bb3a-4b7ce82fd0f5', '553c682a-9105-58d8-8c94-0e5484c78829', 'e30e8fb0-8a67-5834-a006-d8553b49fd24', '7ece71ba-fe0c-5ad0-a068-38a0f152ee63', '39e363f4-e0ec-5599-887b-b310523deef1', 'fd668e8b-e45a-5160-9f1a-fdb336768c6d', '116b3859-7088-509b-8c16-3f9eb8732775', '2bfab5e1-f315-50fc-9f67-9c659958c9a4', '91d0feab-e4a8-57cc-8892-d7a613a90c3c', '5285e4d3-7396-5635-adf9-4d84a9e84b33', '770f9a84-05ba-5edc-b70a-174d3f3767ab', '3ef1ca1f-dfe9-56f4-a508-62efc6f525ab', 'ce19ef29-f188-5536-9b81-8c444c5bc28c', '6fc8d4d7-72c2-5c63-bc12-0368859c001e', '0cdd954a-b70f-5797-b9f3-f1ce45960ec5', 'ea106a82-8286-5558-80eb-b8ca33ccfff3', '18e84abd-6974-5289-bb7f-c876538998c1', '401a9b5e-8547-5c71-ad42-55d3237e2e9e', '5b391b82-586d-5438-a7c3-903a63f42c60', '60c5785c-b8d7-5097-8273-258a90ce3e3a', '3b86dcc9-5143-507f-be60-b8f6875ec2c6', 'b5d0ae20-ae0b-56a3-8956-74aead96614f', '2536db30-c6a7-51b4-a301-34bfc8b772cb', '654adeb2-2426-519f-b3ac-64750f8ce9f7', '123a51fe-4796-5c79-ab0b-bd1c63e342bb', '4d648c5b-5dd8-5bcd-92f9-c5ed27f06b13', 'ba303c1b-b573-5021-8693-1620593fbc3b', '5bebc41b-b524-5202-8a04-8d54bd45e58f', '6fd6d69e-a53d-57d7-a1af-49cd22d4c61f', '820a3e8b-65fc-562f-9f99-6686957552a3', '157895d5-87f8-5284-8648-4763294d5208', 'c58095f1-673d-5468-815c-3c9cc7cbf655', '92e18ead-32af-5467-b6e7-ebd3ed5544eb', 'ceab5a3d-ad50-597c-99bc-30d5a4acd1ca', 'a0789505-00c2-5a61-af5a-68976988fc8f', '9e2344f8-fae5-521e-b8c7-268cbfd671cb', 'ead3037c-455d-5eef-956a-4874a11c2c65', '802892fa-7717-5961-8cef-4f6a5e4c999c', 'dae9965d-3f96-5e7c-8cf1-f5063d0d777f', 'f344d1de-c9db-58e3-b66b-a482eb636a10', '24c959c5-f15e-5ae3-b314-a3d83e0bf971', '4c75004e-f145-594f-a680-380a42c7ddf3', '6e6a7fb1-6f88-56be-b000-26558a8064f4', '236dc0ab-b48f-5d00-b807-99cdc336c2bd', 'e410ee0d-01ef-5859-8b9e-4c4697e1a480', '27319fcd-26c9-53d3-bd56-1203c0135e9c', '39dc1e42-8b8a-56ef-9979-48d2db1c6c48', 'ff833f40-75b9-5b26-b4f4-570d7bbf3fdf', '95d7e62b-3440-5abf-b116-a61e4a3e058a', '829382b1-fa80-5093-8049-a068093c55c9', '2381f0e7-6cea-5898-a40c-58b49aeca43d', 'e955a6b5-7ebb-5f17-a71f-df368d0b4168', '60b0ed19-ee63-5f4a-97d0-4a3b6b00a098', '251d0924-a7b8-56c7-98a1-9bdab115719d', '9d96e4a5-5cc2-52ac-b56a-37b275cae933', 'ecf7fced-61d6-51c7-9b24-539ead310e48', 'fa287595-c6c6-5b90-815d-e7850038fea6', '9a69141b-cad1-556b-8e38-3bfe1f207642', '87853e91-566f-5571-980b-26f1cb2769fe', '2c714ef6-77e6-5d5b-8d63-04fb7fae4651', 'db3640ea-ade4-5f09-9039-3cefa6ff708c', 'a7480882-aa35-5a31-b6c2-75f0388da214') and status = 'PUBLISHED';
  select count(*) into v_bad from (values ('a1-m01', 20), ('a1-m02', 20), ('a1-m03', 16), ('a1-m04', 20), ('a1-m05', 20), ('a1-m06', 18), ('a1-m07', 14)) e(slug, n) left join public.assessments a on a.slug = e.slug and a.cefr = 'A1' and a.status = 'PUBLISHED'
   where a.id is null
      or (select count(*) from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED') <> e.n
      or exists (select 1 from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED' and i.id not in ('15676330-4f1c-52f6-ae93-73ae74ad7d03', '54a304fb-c687-505a-8fdf-d801e9599204', '847b1aef-67dc-5d49-8533-5361ace111bc', '4f518116-4db9-5b33-ac0d-2e08963e7e7a', '4f06eda3-7f34-5875-9704-cd35d4df9c29', 'd3e8c458-31dd-509a-9671-9f8127601c3e', '1502e215-93aa-536a-a69e-326b0bcdf987', '60d7975a-c196-5951-a124-1925aa0cfb9c', 'ec5b0df6-f3b4-50d4-9aaf-7b53d351f11a', '1724f917-1107-537c-8231-36d7bc14ae3a', '8018686e-2bf5-559b-9ba8-c1c36d3bcd85', '3032f3aa-7479-5d20-a36b-2f9da00b854d', '3aa1e802-5bb7-58dd-9add-cee86bfc3686', 'c1619d7e-7e6f-5bd0-b5a7-8eb91a7ca596', 'b32e622c-118b-547d-ab0e-ef7fbe0e7369', '8eef2566-9652-51d6-9d01-f3518defcd5f', '6528306c-c0da-5096-a550-43d2083ef461', '4cd402b3-b2a6-568f-a4a5-74d5dff362b4', '2f5b5c43-69ab-549e-b196-1e8879af3b05', 'eeddbd88-68db-5153-a5dd-e82a15732b64', 'bd606cd7-5fc3-59bd-922c-bacbce88aba3', 'c1f013ec-21d8-51c5-859a-75da3eed1cbf', '4216fd1f-936a-592e-8b65-39b1631e81e3', 'bb952a0b-31a2-5660-b055-15797b6e518c', 'ca57b200-927e-5495-8f40-35a8f3f24666', 'fe5a6014-98dd-5bda-a407-d9b25e688f96', 'daffad3a-7451-5089-afc0-59484d72573c', '5d541ca0-71c0-5767-901b-28ba8e14fd7d', 'f869f916-5520-523b-b397-3ea67c5a6a31', '1ed4e1b3-461a-557e-b4da-3d1e023c059b', '55cf3870-3bef-5ef4-b300-80304e3b1131', 'e8b5b2c0-7f98-52ab-abe0-e93164166806', '1adf736b-5b6b-52cf-9eae-4d7eae9c2956', '6d7b044a-4e28-5276-84c2-bfe28d17bab1', '899b25e8-6513-514d-8f71-527466d28ee0', 'a49f8115-3568-5d13-b772-8d7010cabf50', '35b6c8b6-c27a-58fc-bbcb-bf577ee83a73', 'a052cdcb-8b5c-5704-ac78-4bdc2e3994c6', 'e94bff69-4391-52e6-bdd5-718925e8b3a9', '0f4eb934-c922-5df6-9450-8ab58dc9d5b0', 'b9fea7ff-1f74-5754-9d98-111634811632', '472b5838-c796-57d3-8397-b3a1870653df', '531abfee-3309-5a78-a66e-a65a7726b019', '643fb802-1e33-5ef1-80ef-da32d197d76a', '0a298eb4-d605-5bf4-ab64-afdf72c0b2f9', '043d1315-37a6-551a-a6c0-b4f2238e9add', 'f659b8a6-fdf0-5140-9533-947750a61e0e', '16a97acc-1977-556b-86f7-dc599dbff0d6', '3f68ac74-70cc-5db6-89d2-653afba06816', 'c55b36b9-1101-5306-8250-e1b4e2274a3e', '8484cb44-9634-58aa-b7f7-bfb8ed307364', '61b828c9-88cb-5891-b5ce-84947820dc08', 'e935c709-285b-5c2c-912a-768775944dda', '80808355-4a64-5430-8e92-7483e3951cdf', 'fd851510-09e4-51ac-bedc-af95e6bbf97e', '3bf6936d-caf5-53eb-98ef-24c665494955', '5b4ff5be-6c2b-5f96-b7e7-572b3f087ccd', '0ae04a3d-58cc-5b32-bd4b-d3d3416bcf0a', 'e92a88d3-9784-57b7-a64b-88f04da2a345', '2a3123f9-f4d3-501d-bcc2-99617da6e8a3', 'ace0b0b3-6772-59c1-8aaf-4a69b0c841ad', '6114f637-4264-504a-89c5-1cd107802a35', '1b0886f1-a5fd-5455-b623-dc728d4b97b7', '9e3164c5-03a2-5716-ab27-b5f33ec0a30c', '5c18bfb9-f463-5dd0-9e6f-beb6bc86326d', '066ce988-4272-5382-9fa3-fbfea7802a26', 'a59fe87b-e7de-5c93-bb3a-4b7ce82fd0f5', '553c682a-9105-58d8-8c94-0e5484c78829', 'e30e8fb0-8a67-5834-a006-d8553b49fd24', '7ece71ba-fe0c-5ad0-a068-38a0f152ee63', '39e363f4-e0ec-5599-887b-b310523deef1', 'fd668e8b-e45a-5160-9f1a-fdb336768c6d', '116b3859-7088-509b-8c16-3f9eb8732775', '2bfab5e1-f315-50fc-9f67-9c659958c9a4', '91d0feab-e4a8-57cc-8892-d7a613a90c3c', '5285e4d3-7396-5635-adf9-4d84a9e84b33', '770f9a84-05ba-5edc-b70a-174d3f3767ab', '3ef1ca1f-dfe9-56f4-a508-62efc6f525ab', 'ce19ef29-f188-5536-9b81-8c444c5bc28c', '6fc8d4d7-72c2-5c63-bc12-0368859c001e', '0cdd954a-b70f-5797-b9f3-f1ce45960ec5', 'ea106a82-8286-5558-80eb-b8ca33ccfff3', '18e84abd-6974-5289-bb7f-c876538998c1', '401a9b5e-8547-5c71-ad42-55d3237e2e9e', '5b391b82-586d-5438-a7c3-903a63f42c60', '60c5785c-b8d7-5097-8273-258a90ce3e3a', '3b86dcc9-5143-507f-be60-b8f6875ec2c6', 'b5d0ae20-ae0b-56a3-8956-74aead96614f', '2536db30-c6a7-51b4-a301-34bfc8b772cb', '654adeb2-2426-519f-b3ac-64750f8ce9f7', '123a51fe-4796-5c79-ab0b-bd1c63e342bb', '4d648c5b-5dd8-5bcd-92f9-c5ed27f06b13', 'ba303c1b-b573-5021-8693-1620593fbc3b', '5bebc41b-b524-5202-8a04-8d54bd45e58f', '6fd6d69e-a53d-57d7-a1af-49cd22d4c61f', '820a3e8b-65fc-562f-9f99-6686957552a3', '157895d5-87f8-5284-8648-4763294d5208', 'c58095f1-673d-5468-815c-3c9cc7cbf655', '92e18ead-32af-5467-b6e7-ebd3ed5544eb', 'ceab5a3d-ad50-597c-99bc-30d5a4acd1ca', 'a0789505-00c2-5a61-af5a-68976988fc8f', '9e2344f8-fae5-521e-b8c7-268cbfd671cb', 'ead3037c-455d-5eef-956a-4874a11c2c65', '802892fa-7717-5961-8cef-4f6a5e4c999c', 'dae9965d-3f96-5e7c-8cf1-f5063d0d777f', 'f344d1de-c9db-58e3-b66b-a482eb636a10', '24c959c5-f15e-5ae3-b314-a3d83e0bf971', '4c75004e-f145-594f-a680-380a42c7ddf3', '6e6a7fb1-6f88-56be-b000-26558a8064f4', '236dc0ab-b48f-5d00-b807-99cdc336c2bd', 'e410ee0d-01ef-5859-8b9e-4c4697e1a480', '27319fcd-26c9-53d3-bd56-1203c0135e9c', '39dc1e42-8b8a-56ef-9979-48d2db1c6c48', 'ff833f40-75b9-5b26-b4f4-570d7bbf3fdf', '95d7e62b-3440-5abf-b116-a61e4a3e058a', '829382b1-fa80-5093-8049-a068093c55c9', '2381f0e7-6cea-5898-a40c-58b49aeca43d', 'e955a6b5-7ebb-5f17-a71f-df368d0b4168', '60b0ed19-ee63-5f4a-97d0-4a3b6b00a098', '251d0924-a7b8-56c7-98a1-9bdab115719d', '9d96e4a5-5cc2-52ac-b56a-37b275cae933', 'ecf7fced-61d6-51c7-9b24-539ead310e48', 'fa287595-c6c6-5b90-815d-e7850038fea6', '9a69141b-cad1-556b-8e38-3bfe1f207642', '87853e91-566f-5571-980b-26f1cb2769fe', '2c714ef6-77e6-5d5b-8d63-04fb7fae4651', 'db3640ea-ade4-5f09-9039-3cefa6ff708c', 'a7480882-aa35-5a31-b6c2-75f0388da214'));
  if v_new <> 128 or v_bad > 0 then raise exception 'Перевірки A1: нових завдань % (очікувалось 128), тестів з помилкою %', v_new, v_bad; end if;
  raise notice 'Готово: 20261116_assessments_a1_v5_part1.sql — 7 тестів, % нових завдань', v_new;
end $$;

commit;
