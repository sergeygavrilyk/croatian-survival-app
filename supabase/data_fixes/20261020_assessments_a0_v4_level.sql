-- =====================================================================
-- Середина й фінал рівня A0 під уроки за темою (curriculum_a0_v4) · 2026-10-20
-- Згенеровано: python3 -B scripts/gen_assessment_a0_v4.py level (не редагуйте вручну).
--
-- Тести: a0-mid (модулі A0.1–A0.5, 20 завдань) і a0-final (усі 10 модулів, 30 завдань) —
--   з нових діалогів і вправ; завдань, які вже є в перевірках модулів, тут немає.
--   Завдань за модулями: A0.1 — 8, A0.2 — 6, A0.3 — 6, A0.4 — 7, A0.5 — 7, A0.6 — 3, A0.7 — 4, A0.8 — 5, A0.9 — 2, A0.10 — 2.
--   * Стара версія завдань — у content_versions; старі завдання → DEPRECATED (не видаляються).
--   * Нові завдання — PUBLISHED (бета, як уроки A0). Прогрес і результати користувачів не змінюються.
--   * Потрібні: 20261015_assessments_a0_v1.sql і уроки curriculum_a0_v4 усіх модулів A0.1–A0.10.
--   * Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

-- Перевірка середини рівня A0 · 20 завдань
do $$
declare v_aid uuid; v_payload jsonb;
begin
  select id into v_aid from public.assessments where slug = 'a0-mid';
  if v_aid is null then raise exception 'Немає тесту a0-mid — спершу 20261015_assessments_a0_v1.sql'; end if;
  if exists (select 1 from public.assessment_items where id = '2d56a326-7e81-5ff2-954b-81c5d2d60d11') then return; end if;  -- уже оновлено
  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
          v_payload, 'curriculum_a0_v4: перевірку рівня оновлено під нові уроки — старі завдання');
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + 100
   where assessment_id = v_aid and status = 'PUBLISHED' and order_index <= 100;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('2d56a326-7e81-5ff2-954b-81c5d2d60d11', v_aid, 1, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Дякую. Можна відчинити вікно?", "Привіт, Дашо! Чудово, дякую. А ти?", "Привіт, Марку! Як справи?"]'::jsonb, 0, null, 'Hvala. Smijem li otvoriti prozor?', null, null, 'Прозвучало: «Hvala. Smijem li otvoriti prozor?» — «Дякую. Можна відчинити вікно?».', (select id from public.lessons where id = 'e704760a-f743-5762-9c1a-027b10ca030a'), 'PUBLISHED', 'claude_assessment_v1'),
  ('f4c2dc5c-aa5d-514f-ad4f-5e1aee000d31', v_aid, 2, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Ні, це п’ятдесят шість, вісімдесят три.", "На другому поверсі, треті двері ліворуч.", "Ні, двох досить. Половина людей не їсть солодкого."]'::jsonb, 0, null, 'Nije, ovo je pedeset šest, osamdeset tri.', null, null, 'Прозвучало: «Nije, ovo je pedeset šest, osamdeset tri.» — «Ні, це п’ятдесят шість, вісімдесят три.».', (select id from public.lessons where id = 'ffb92726-2fb1-5070-bf5c-5d2fb3b9393a'), 'PUBLISHED', 'claude_assessment_v1'),
  ('ad14c9b4-f13c-5e99-9cbd-487780a52800', v_aid, 3, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Добре. Зараз ви не працюєте?", "Добрий день, слухаю вас. Як вас звати?", "Ви переїхали сюди з родиною?"]'::jsonb, 1, null, 'Dobar dan, izvolite. Kako se zovete?', null, null, 'Прозвучало: «Dobar dan, izvolite. Kako se zovete?» — «Добрий день, слухаю вас. Як вас звати?».', (select id from public.lessons where id = '2b6ed342-cc80-5bd9-baf0-b66109624d62'), 'PUBLISHED', 'claude_assessment_v1'),
  ('80a57894-1059-5263-b760-fbc4f364604b', v_aid, 4, 'A0', 'reading', 'understand', 'multiple_choice', 'Де рецепція?', 'Sobe u hotelu', '["На першому поверсі", "На другому поверсі", "На поверсі біля входу (prizemlje)"]'::jsonb, 2, null, null, 'Sobe 1 – 10: prvi kat
Sobe 11 – 20: drugi kat
Recepcija: prizemlje
Lift je desno.', 'Номери 1–10: перший поверх (над входом)
Номери 11–20: другий поверх
Рецепція: партер (поверх біля входу)
Ліфт праворуч.', 'Текст «Номери в готелі». Правильна відповідь: «На поверсі біля входу (prizemlje)».', null, 'PUBLISHED', 'claude_assessment_v1'),
  ('f76d242c-28e5-5b75-9395-02e5b8c16b64', v_aid, 5, 'A0', 'reading', 'understand', 'multiple_choice', 'Що означає «OTVORENO»?', 'Na vratima trgovine', '["Відчинено", "Зачинено", "Перерва"]'::jsonb, 0, null, null, 'DOBRO DOŠLI!
OTVORENO
Dobar dan! Izvolite.
Hvala i doviđenja!', 'ЛАСКАВО ПРОСИМО!
ВІДЧИНЕНО
Добрий день! Прошу, заходьте.
Дякуємо і до побачення!', 'Текст «На дверях магазину». Правильна відповідь: «Відчинено».', null, 'PUBLISHED', 'claude_assessment_v1'),
  ('ee06901f-aec1-5863-9de7-d686f6502b6a', v_aid, 6, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Dobar dan, dostava! Koji je broj Vašeg stana?', '["Zato što uvijek kasno ustaješ!", "Broj sedam.", "Darja, Ukrajinka sam. Materinski jezik mi je ukrajinski."]'::jsonb, 1, null, 'Dobar dan, dostava! Koji je broj Vašeg stana?', null, null, 'Діалог «Номер квартири»: «Dobar dan, dostava! Koji je broj Vašeg stana?» (Добрий день, доставка! Який номер вашої квартири?) — «Broj sedam.» (Номер сім.).', (select id from public.lessons where id = 'c0941bd8-57b5-5e7e-981f-9be423f24208'), 'PUBLISHED', 'claude_assessment_v1'),
  ('b9f63ba0-ab31-5b5c-93c2-f2d28d07fffa', v_aid, 7, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Oprostite, što znači »sutra«?', '["Ja imam psa. Svako jutro ga šetam u parku.", "Na trećem katu, stan broj 8.", "Danas je ponedjeljak, a sutra je utorak."]'::jsonb, 2, null, 'Oprostite, što znači »sutra«?', null, null, 'Діалог «На курсі хорватської»: «Oprostite, što znači »sutra«?» (Вибачте, що означає «sutra»?) — «Danas je ponedjeljak, a sutra je utorak.» (Сьогодні понеділок, а завтра вівторок.).', (select id from public.lessons where id = 'a17f2f16-1be9-50f2-8e16-2bebfcced33b'), 'PUBLISHED', 'claude_assessment_v1'),
  ('c5ed5cac-7428-52f2-98b1-08b639b674d7', v_aid, 8, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Koji je rok?', '["Broj dvadeset jedan, a ja imam trideset šest.", "Dođite najkasnije početkom veljače.", "Brojimo zajedno: jedan, dva, tri…"]'::jsonb, 1, null, 'Koji je rok?', null, null, 'Діалог «Дозвіл на проживання»: «Koji je rok?» (Який термін?) — «Dođite najkasnije početkom veljače.» (Прийдіть не пізніше початку лютого.).', (select id from public.lessons where id = 'b36b4550-ff36-50cb-89fb-8246b351c8d6'), 'PUBLISHED', 'claude_assessment_v1'),
  ('b14e7f58-aba4-51d0-999f-8e40f78cbdf6', v_aid, 9, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Je li velik?', '["Nije, mali je, ali puno laje!", "Na drugom katu, treća vrata lijevo.", "Devedeset drugo."]'::jsonb, 0, null, 'Je li velik?', null, null, 'Діалог «У тебе є тварина?»: «Je li velik?» (Він великий?) — «Nije, mali je, ali puno laje!» (Ні, маленький, але багато гавкає!).', (select id from public.lessons where id = '40b9da1d-1686-5b78-8317-0439067d5f8e'), 'PUBLISHED', 'claude_assessment_v1'),
  ('5a2d4112-8e42-5a41-adf3-a77da80c56f6', v_aid, 10, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Razumijem te. Želiš li na kavu?', '["Hvala, rado.", "Dolazi mi svekrva iz Ukrajine, mama mog muža.", "Desetak, možda dvadesetak."]'::jsonb, 0, null, 'Razumijem te. Želiš li na kavu?', null, null, 'Діалог «Поганий день»: «Razumijem te. Želiš li na kavu?» (Розумію тебе. Хочеш на каву?) — «Hvala, rado.» (Дякую, із задоволенням.).', (select id from public.lessons where id = '3b51b1bf-47f4-5709-96d9-c518d36440e6'), 'PUBLISHED', 'claude_assessment_v1'),
  ('dcd0bf1c-309e-5516-a019-4c7e61868bec', v_aid, 11, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Bok, Dašo! Kakvo je vrijeme u Splitu?', '["Тоді не забудь парасолю!", "Лише десять. Холодно й хмарно.", "Сонячно й тепло, двадцять градусів."]'::jsonb, 2, null, null, 'Ivana: Bok, Dašo! Kakvo je vrijeme u Splitu?
Daša: Sunčano je i toplo, dvadeset stupnjeva.
Ivana: Blago tebi! U Zagrebu pada kiša cijeli dan.
Daša: A koliko je stupnjeva?
Ivana: Samo deset. Hladno je i oblačno.
Daša: Onda ne zaboravi kišobran!', 'Ivana: Привіт, Дашо! Яка погода в Спліті?
Daša: Сонячно й тепло, двадцять градусів.
Ivana: Щаслива ти! У Загребі цілий день іде дощ.
Daša: А скільки градусів?
Ivana: Лише десять. Холодно й хмарно.
Daša: Тоді не забудь парасолю!', 'Діалог «Яка погода?»: «Bok, Dašo! Kakvo je vrijeme u Splitu?» — «Sunčano je i toplo, dvadeset stupnjeva.», тобто «Сонячно й тепло, двадцять градусів.».', (select id from public.lessons where id = 'efcf49e0-c058-5986-9cf7-aee921887a81'), 'PUBLISHED', 'claude_assessment_v1'),
  ('6c3547ef-13bb-5c1f-ab6e-8cd886841c64', v_aid, 12, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Dobar dan. Imate li iskustva kao prodavačica?', '["Можу, звісно!", "Так. Два роки я працювала в магазині в Києві.", "Так, шукаю роботу."]'::jsonb, 1, null, null, 'Gospodin Kovačević: Dobar dan. Imate li iskustva kao prodavačica?
Daša: Imam. Dvije godine sam radila u trgovini u Kijevu.
Gospodin Kovačević: Dobro. Sada ste nezaposleni?
Daša: Da, tražim posao.
Gospodin Kovačević: Naša tvrtka traži prodavačicu. Možete li početi u ponedjeljak?
Daša: Mogu, naravno!', 'Gospodin Kovačević: Добрий день. У вас є досвід роботи продавчинею?
Daša: Так. Два роки я працювала в магазині в Києві.
Gospodin Kovačević: Добре. Зараз ви не працюєте?
Daša: Так, шукаю роботу.
Gospodin Kovačević: Наша фірма шукає продавчиню. Можете почати в понеділок?
Daša: Можу, звісно!', 'Діалог «Співбесіда»: «Dobar dan. Imate li iskustva kao prodavačica?» — «Imam. Dvije godine sam radila u trgovini u Kijevu.», тобто «Так. Два роки я працювала в магазині в Києві.».', (select id from public.lessons where id = '2fa5fa38-9641-5dc5-9156-6a3f7fe8035b'), 'PUBLISHED', 'claude_assessment_v1'),
  ('b60778cf-cfd8-5db2-8616-c43a0423bf87', v_aid, 13, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Dobar dan! Što se dogodilo Vašem psu?', '["Це собака моєї сусідки. З учора нічого не їсть.", "Добре. Зараз я його огляну.", "Так, ось його книжечка щеплень."]'::jsonb, 0, null, null, 'Veterinarka: Dobar dan! Što se dogodilo Vašem psu?
Daša: To je pas moje susjede. Od jučer ne jede.
Veterinarka: Je li cijepljen?
Daša: Jest, evo njegove knjižice cijepljenja.
Veterinarka: Dobro. Sada ću ga pregledati.', 'Veterinarka: Добрий день! Що сталося з вашим собакою?
Daša: Це собака моєї сусідки. З учора нічого не їсть.
Veterinarka: Він щеплений?
Daša: Так, ось його книжечка щеплень.
Veterinarka: Добре. Зараз я його огляну.', 'Діалог «У ветеринара»: «Dobar dan! Što se dogodilo Vašem psu?» — «To je pas moje susjede. Od jučer ne jede.», тобто «Це собака моєї сусідки. З учора нічого не їсть.».', (select id from public.lessons where id = '40b9da1d-1686-5b78-8317-0439067d5f8e'), 'PUBLISHED', 'claude_assessment_v1'),
  ('d71d6f8a-443f-580a-9f10-16c0d1093b5e', v_aid, 14, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Говоріть повільніше, будь ласка». Що ви скажете?', null, '["Govorite sporije, molim.", "Ne razumijem.", "Dobro jutro!"]'::jsonb, 0, null, null, null, null, '«Говоріть повільніше, будь ласка.» — «Govorite sporije, molim.».', (select id from public.lessons where id = 'a17f2f16-1be9-50f2-8e16-2bebfcced33b'), 'PUBLISHED', 'claude_assessment_v1'),
  ('56a326fd-76c0-5d2e-81ff-871d6c9a5986', v_aid, 15, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Чия це куртка?». Що ви скажете?', null, '["Čija je ovo jakna?", "Imam alergiju na mačke.", "Jako sličiš mami."]'::jsonb, 0, null, null, null, null, '«Чия це куртка?» — «Čija je ovo jakna?».', (select id from public.lessons where id = '18efed0f-53a5-5717-9c4e-319627da2360'), 'PUBLISHED', 'claude_assessment_v1'),
  ('d6d38fe2-3716-58aa-93e9-7efe90708d89', v_aid, 16, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «сонячно»', null, '[]'::jsonb, null, 'sunčano', null, null, null, '«сонячно» — sunčano.', (select id from public.lessons where id = 'efcf49e0-c058-5986-9cf7-aee921887a81'), 'PUBLISHED', 'claude_assessment_v1'),
  ('38e85534-fca2-5d92-9f1b-a8d5988d67f9', v_aid, 17, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «дешево»', null, '[]'::jsonb, null, 'jeftino', null, null, null, '«дешево» — jeftino.', (select id from public.lessons where id = '427e5058-7381-58a0-8f21-bd170866dbae'), 'PUBLISHED', 'claude_assessment_v1'),
  ('3dc60cc2-9ecf-59db-977c-94ae825f4735', v_aid, 18, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Гарного дня!»', null, '["dan!", "Ugodan"]'::jsonb, null, 'Ugodan dan!', null, null, null, '«Гарного дня!» — «Ugodan dan!».', (select id from public.lessons where id = 'd8cffb46-8a62-538a-b864-e227a6d8b863'), 'PUBLISHED', 'claude_assessment_v1'),
  ('d39ad2c0-0b73-5d6b-a76d-da683ea46662', v_aid, 19, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Як виглядає твій брат?»', null, '["izgleda", "brat?", "tvoj", "Kako"]'::jsonb, null, 'Kako izgleda tvoj brat?', null, null, null, '«Як виглядає твій брат?» — «Kako izgleda tvoj brat?».', (select id from public.lessons where id = '60130364-d731-5f5a-8b12-ac4d8d6d92e9'), 'PUBLISHED', 'claude_assessment_v1'),
  ('1b76eb49-d9bd-5589-8662-31fd6d64cfd0', v_aid, 20, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Який сьогодні день?»', null, '[]'::jsonb, null, 'Koji je danas dan?', null, null, null, '«Який сьогодні день?» — «Koji je danas dan?».', (select id from public.lessons where id = '8e372ece-ae10-50ae-9cf3-07b52ef2f72d'), 'PUBLISHED', 'claude_assessment_v1');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірку рівня оновлено під уроки за темою (curriculum_a0_v4) — завдання з нових діалогів і вправ усіх модулів A0. Потрібна перевірка носієм.');
end $$;

-- Фінальна перевірка рівня A0 · 30 завдань
do $$
declare v_aid uuid; v_payload jsonb;
begin
  select id into v_aid from public.assessments where slug = 'a0-final';
  if v_aid is null then raise exception 'Немає тесту a0-final — спершу 20261015_assessments_a0_v1.sql'; end if;
  if exists (select 1 from public.assessment_items where id = '7a85998e-ee0a-5584-8c33-405fb107ac8e') then return; end if;  -- уже оновлено
  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
          v_payload, 'curriculum_a0_v4: перевірку рівня оновлено під нові уроки — старі завдання');
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + 100
   where assessment_id = v_aid and status = 'PUBLISHED' and order_index <= 100;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('7a85998e-ee0a-5584-8c33-405fb107ac8e', v_aid, 1, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Ти чула прогноз погоди на завтра?", "Дашо, ти вільна сьогодні ввечері?", "Дар’є, коли у вас відпустка?"]'::jsonb, 0, null, 'Jesi li čula vremensku prognozu za sutra?', null, null, 'Прозвучало: «Jesi li čula vremensku prognozu za sutra?» — «Ти чула прогноз погоди на завтра?».', (select id from public.lessons where id = 'efcf49e0-c058-5986-9cf7-aee921887a81'), 'PUBLISHED', 'claude_assessment_v1'),
  ('c646b0f0-257f-5fa9-a71c-57e703003bc6', v_aid, 2, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Зелений. А твій?", "Шукаєте щось конкретне?", "Карткою. Можна безконтактно?"]'::jsonb, 0, null, 'Zelena. A tvoja?', null, null, 'Прозвучало: «Zelena. A tvoja?» — «Зелений. А твій?».', (select id from public.lessons where id = '288e7610-99c8-5696-989a-86f60ce38b0a'), 'PUBLISHED', 'claude_assessment_v1'),
  ('6af56d46-fb70-5fe2-94f8-4d2576a269a2', v_aid, 3, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Це біля мосту?", "Перепрошую, як дістатися до вокзалу?", "А це безпечно?"]'::jsonb, 2, null, 'Je li to sigurno?', null, null, 'Прозвучало: «Je li to sigurno?» — «А це безпечно?».', (select id from public.lessons where id = 'e0b9d742-0418-597b-9482-b6e2d82469da'), 'PUBLISHED', 'claude_assessment_v1'),
  ('62369ea1-447a-5ac8-96e1-40dac3b4cc68', v_aid, 4, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Узимку близько ста п’ятдесяти євро, через опалення.", "Добре, хай майстер огляне і його.", "Унизу, біля входу, за сходами."]'::jsonb, 1, null, 'Dobro, neka majstor pogleda i njega.', null, null, 'Прозвучало: «Dobro, neka majstor pogleda i njega.» — «Добре, хай майстер огляне і його.».', (select id from public.lessons where id = 'e8f4a2ca-af87-5d99-9f9e-a24cfadf73c9'), 'PUBLISHED', 'claude_assessment_v1'),
  ('519a38dc-3c84-54ac-aeeb-ab8bc3c1a4ea', v_aid, 5, 'A0', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Давай! Після такого мені треба чогось солодкого.", "Зазвичай я не обідаю. Увечері вечеряю з сім’єю.", "Скуштуй цей соус. Обережно, він гострий!"]'::jsonb, 2, null, 'Probaj ovaj umak. Pazi, ljut je!', null, null, 'Прозвучало: «Probaj ovaj umak. Pazi, ljut je!» — «Скуштуй цей соус. Обережно, він гострий!».', (select id from public.lessons where id = 'e6925fe5-e7fb-5594-9d3f-87fab1b5598d'), 'PUBLISHED', 'claude_assessment_v1'),
  ('2c4e1935-8119-5c2c-b467-537a11193536', v_aid, 6, 'A0', 'reading', 'understand', 'multiple_choice', 'Що треба зробити, перш ніж зайти?', 'Natpis na vratima ordinacije', '["Подзвонити", "Почекати на вулиці", "Постукати"]'::jsonb, 2, null, null, 'Dr. Ivo Kovač
liječnik obiteljske medicine
Soba 3
Molimo, pokucajte!', 'Д-р Іво Ковач
лікар сімейної медицини
Кабінет 3
Просимо, постукайте!', 'Текст «Табличка на дверях кабінету». Правильна відповідь: «Постукати».', null, 'PUBLISHED', 'claude_assessment_v1'),
  ('f4538812-9db5-59c3-b0aa-5cdf72382165', v_aid, 7, 'A0', 'reading', 'understand', 'multiple_choice', 'Скільки яєць можна купити за 3 €?', 'Cijene na tržnici', '["5", "3", "10"]'::jsonb, 2, null, null, 'JABUKE 1,50 € / kg
KRUŠKE 2 € / kg
JAJA – 10 komada 3 €
SIR 8 € / kg', 'ЯБЛУКА 1,50 € / кг
ГРУШІ 2 € / кг
ЯЙЦЯ – 10 штук 3 €
СИР 8 € / кг', 'Текст «Цінники на ринку». Правильна відповідь: «10».', null, 'PUBLISHED', 'claude_assessment_v1'),
  ('3934f94c-022d-5326-b70e-c59497fac78a', v_aid, 8, 'A0', 'reading', 'understand', 'multiple_choice', 'Що означає «Oprostite»?', 'Natpis na vratima kafića', '["Дякую", "Привіт", "Вибачте"]'::jsonb, 2, null, null, 'ZATVORENO
Oprostite, danas ne radimo.
Vidimo se sutra!
Hvala!', 'ЗАЧИНЕНО
Вибачте, сьогодні ми не працюємо.
Побачимося завтра!
Дякуємо!', 'Текст «Табличка на дверях кафе». Правильна відповідь: «Вибачте».', null, 'PUBLISHED', 'claude_assessment_v1'),
  ('bd6df4ee-ef76-54b4-b175-bfb4d65eb837', v_aid, 9, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Imam, evo ga. Mogu li je zamijeniti?', '["Možete je zamijeniti ili dobiti povrat novca.", "Zahtjev je odobren. Rješenje možete preuzeti na šalteru tri.", "Prvo upišite osobne podatke, tiskanim slovima."]'::jsonb, 0, null, 'Imam, evo ga. Mogu li je zamijeniti?', null, null, 'Діалог «Обмін куртки»: «Imam, evo ga. Mogu li je zamijeniti?» (Є, ось він. Можна її обміняти?) — «Možete je zamijeniti ili dobiti povrat novca.» (Можете її обміняти або отримати гроші назад.).', (select id from public.lessons where id = '28913ad6-490f-5d89-bad7-9b303c673fcd'), 'PUBLISHED', 'claude_assessment_v1'),
  ('27e481a3-2a57-5c1b-9a40-1a151faa9a16', v_aid, 10, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Ne razumijem dobro hrvatski. Možete li govoriti polako?', '["Malo je ozbiljna, ali i smiješna. Svi je vole.", "Početkom sljedećeg mjeseca, ako može.", "Naravno. Tramvaj broj šest ide u centar."]'::jsonb, 2, null, 'Ne razumijem dobro hrvatski. Možete li govoriti polako?', null, null, 'Діалог «Турист у Загребі»: «Ne razumijem dobro hrvatski. Možete li govoriti polako?» (Я погано розумію хорватську. Можете говорити повільно?) — «Naravno. Tramvaj broj šest ide u centar.» (Звісно. Трамвай номер шість їде в центр.).', (select id from public.lessons where id = 'a17f2f16-1be9-50f2-8e16-2bebfcced33b'), 'PUBLISHED', 'claude_assessment_v1'),
  ('b809726c-c3a6-5d6e-b918-7a41d0a942b1', v_aid, 11, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Imate li rezervaciju?', '["Nemamo, nažalost.", "Sedamsto. Za najam stana.", "Dosta je. Hvala ti!"]'::jsonb, 0, null, 'Imate li rezervaciju?', null, null, 'Діалог «Столик на двох»: «Imate li rezervaciju?» (Ви бронювали?) — «Nemamo, nažalost.» (На жаль, ні.).', (select id from public.lessons where id = '8b30911e-4e57-5648-9ff6-bd11c1b0e27e'), 'PUBLISHED', 'claude_assessment_v1'),
  ('adb9f6f3-4143-52da-96b4-efac02ed3b3a', v_aid, 12, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Dobar dan, je li to frizerski salon?', '["U subotu radim, ali u nedjelju sam slobodna.", "Ne, nazvali ste krivi broj.", "Dosta je. Hvala ti!"]'::jsonb, 1, null, 'Dobar dan, je li to frizerski salon?', null, null, 'Діалог «Не той номер»: «Dobar dan, je li to frizerski salon?» (Добрий день, це перукарня?) — «Ne, nazvali ste krivi broj.» (Ні, ви набрали не той номер.).', (select id from public.lessons where id = 'ffb92726-2fb1-5070-bf5c-5d2fb3b9393a'), 'PUBLISHED', 'claude_assessment_v1'),
  ('099a217c-74eb-5a3d-84e9-30fe888bad1c', v_aid, 13, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Ima li bradu?', '["Ima malu bradu i nosi naočale.", "Malo manje od četiri milijuna.", "Zimi oko sto pedeset eura, zbog grijanja."]'::jsonb, 0, null, 'Ima li bradu?', null, null, 'Діалог «Як він виглядає?»: «Ima li bradu?» (У нього є борода?) — «Ima malu bradu i nosi naočale.» (Має невелику бороду й носить окуляри.).', (select id from public.lessons where id = '60130364-d731-5f5a-8b12-ac4d8d6d92e9'), 'PUBLISHED', 'claude_assessment_v1'),
  ('de763c6d-b902-53bc-a2dd-10bdcd3a9396', v_aid, 14, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Lijepa je, ali tražim jednobojnu. Imate li tamnoplavu?', '["Kovalenko. Prvo slovo je K. Izvolite moju posjetnicu.", "Miran je. Živim u predgrađu, u maloj zgradi.", "Nažalost, samo crnu i sivu."]'::jsonb, 2, null, 'Lijepa je, ali tražim jednobojnu. Imate li tamnoplavu?', null, null, 'Діалог «Сорочка для роботи»: «Lijepa je, ali tražim jednobojnu. Imate li tamnoplavu?» (Гарна, але я шукаю однотонну. Темно-синя є?) — «Nažalost, samo crnu i sivu.» (На жаль, лише чорна й сіра.).', (select id from public.lessons where id = '288e7610-99c8-5696-989a-86f60ce38b0a'), 'PUBLISHED', 'claude_assessment_v1'),
  ('8d9eadad-320f-5ab8-b4f7-37d1236124d5', v_aid, 15, 'A0', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Bok, Dašo! Super, hvala. A ti?', '["Trideset eura.", "Ja sam zadnji. Vi ste iza mene.", "Ne baš dobro. Umorna sam."]'::jsonb, 2, null, 'Bok, Dašo! Super, hvala. A ti?', null, null, 'Діалог «Зустріч на вулиці»: «Bok, Dašo! Super, hvala. A ti?» (Привіт, Дашо! Чудово, дякую. А ти?) — «Ne baš dobro. Umorna sam.» (Не дуже добре. Я втомлена.).', (select id from public.lessons where id = 'c0000000-0000-0000-0000-000000000001'), 'PUBLISHED', 'claude_assessment_v1'),
  ('0b58be26-11fc-58ed-a0cd-4755ccc68fd2', v_aid, 16, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Lijepo! Je li ona tvoja najbolja prijateljica?', '["Мамо, Луція запросила мене на день народження!", "Так! Ми сидимо разом у класі.", "Звісно! Купимо їй гарну іграшку."]'::jsonb, 1, null, null, 'Mia: Mama, Lucija me pozvala na rođendansku zabavu!
Daša: Lijepo! Je li ona tvoja najbolja prijateljica?
Mia: Jest! Sjedimo zajedno u razredu.
Daša: Kada je zabava?
Mia: U subotu u četiri. Smijem li ići?
Daša: Naravno! Kupit ćemo joj lijepu igračku.', 'Mia: Мамо, Луція запросила мене на день народження!
Daša: Чудово! Вона твоя найкраща подруга?
Mia: Так! Ми сидимо разом у класі.
Daša: Коли свято?
Mia: У суботу о четвертій. Можна мені піти?
Daša: Звісно! Купимо їй гарну іграшку.', 'Діалог «Запрошення на день народження»: «Lijepo! Je li ona tvoja najbolja prijateljica?» — «Jest! Sjedimo zajedno u razredu.», тобто «Так! Ми сидимо разом у класі.».', (select id from public.lessons where id = '2b0e9742-99e1-57e1-a574-67ffb78d2607'), 'PUBLISHED', 'claude_assessment_v1'),
  ('f54e394d-739b-5c4e-b8f0-fe19b89f16c0', v_aid, 17, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Koliko se obično čeka?', '["Близько пів години. Будьте терплячі.", "Заяву схвалено. Рішення можна забрати у віконці номер три.", "Так, із паспортом. Візьміть номерок і чекайте в залі очікування."]'::jsonb, 0, null, null, 'Darja: Dobar dan, kada će biti gotovo rješenje za moj boravak?
Službenica: Zahtjev je odobren. Rješenje možete preuzeti na šalteru tri.
Darja: Moram li doći osobno?
Službenica: Da, s putovnicom. Uzmite broj i čekajte u čekaonici.
Darja: Koliko se obično čeka?
Službenica: Oko pola sata. Budite strpljivi.', 'Darja: Добрий день, коли буде готове рішення щодо мого проживання?
Službenica: Заяву схвалено. Рішення можна забрати у віконці номер три.
Darja: Мені треба прийти особисто?
Službenica: Так, із паспортом. Візьміть номерок і чекайте в залі очікування.
Darja: Скільки зазвичай доводиться чекати?
Službenica: Близько пів години. Будьте терплячі.', 'Діалог «Коли буде рішення?»: «Koliko se obično čeka?» — «Oko pola sata. Budite strpljivi.», тобто «Близько пів години. Будьте терплячі.».', (select id from public.lessons where id = '19df3241-90f3-5450-94ac-642d79fb2869'), 'PUBLISHED', 'claude_assessment_v1'),
  ('83c8443b-cc8c-56df-9dd5-0161e3d71c4b', v_aid, 18, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Dašo, kakva ti je nova soba?', '["Маєш рацію. У суботу піду в меблевий магазин.", "Тобі ще потрібні лампа й килим.", "Маленька, але гарна. Є ліжко, шафа й письмовий стіл."]'::jsonb, 2, null, null, 'Ivana: Dašo, kakva ti je nova soba?
Daša: Mala je, ali lijepa. Ima krevet, ormar i radni stol.
Ivana: A gdje držiš knjige?
Daša: Na polici iznad stola.
Ivana: Treba ti još jedna lampa i tepih.
Daša: Imaš pravo. U subotu idem u trgovinu namještajem.', 'Ivana: Дашо, яка в тебе нова кімната?
Daša: Маленька, але гарна. Є ліжко, шафа й письмовий стіл.
Ivana: А де ти тримаєш книжки?
Daša: На полиці над столом.
Ivana: Тобі ще потрібні лампа й килим.
Daša: Маєш рацію. У суботу піду в меблевий магазин.', 'Діалог «Нова кімната»: «Dašo, kakva ti je nova soba?» — «Mala je, ali lijepa. Ima krevet, ormar i radni stol.», тобто «Маленька, але гарна. Є ліжко, шафа й письмовий стіл.».', (select id from public.lessons where id = '1436c20e-0aea-550a-b66d-fb3149a1c2e2'), 'PUBLISHED', 'claude_assessment_v1'),
  ('87036e3e-0eff-5ae8-be14-20e3e258ae17', v_aid, 19, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Povratnu. Kada polazi sljedeći autobus?', '["О чотирнадцятій тридцять, з п’ятого перону.", "Близько п’яти годин.", "Добрий день, один квиток до Спліта, будь ласка."]'::jsonb, 0, null, null, 'Daša: Dobar dan, jednu kartu za Split, molim.
Blagajnik: U jednom smjeru ili povratnu?
Daša: Povratnu. Kada polazi sljedeći autobus?
Blagajnik: U četrnaest i trideset, s petog perona.
Daša: Koliko traje putovanje?
Blagajnik: Oko pet sati.', 'Daša: Добрий день, один квиток до Спліта, будь ласка.
Blagajnik: В один бік чи туди й назад?
Daša: Туди й назад. Коли відправляється наступний автобус?
Blagajnik: О чотирнадцятій тридцять, з п’ятого перону.
Daša: Скільки триває поїздка?
Blagajnik: Близько п’яти годин.', 'Діалог «На автовокзалі»: «Povratnu. Kada polazi sljedeći autobus?» — «U četrnaest i trideset, s petog perona.», тобто «О чотирнадцятій тридцять, з п’ятого перону.».', (select id from public.lessons where id = 'e5b81eb1-8ea8-5ff4-a987-e5e46421302b'), 'PUBLISHED', 'claude_assessment_v1'),
  ('4bcb4af7-afe9-5e5d-b86f-5ddf4652b023', v_aid, 20, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Котра година?». Що ви скажете?', null, '["Koliko je sati?", "Sljedeće godine.", "Jučer, danas, sutra."]'::jsonb, 0, null, null, null, null, '«Котра година?» — «Koliko je sati?».', (select id from public.lessons where id = '39b1e31f-b573-5000-9713-1660688c3cc9'), 'PUBLISHED', 'claude_assessment_v1'),
  ('61ef3c19-e3da-596a-b7af-327e120570e2', v_aid, 21, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Я трохи розмовляю хорватською». Що ви скажете?', null, '["Govorim malo hrvatski.", "Ja sam iz Europe.", "Drago mi je!"]'::jsonb, 0, null, null, null, null, '«Я трохи розмовляю хорватською.» — «Govorim malo hrvatski.».', (select id from public.lessons where id = 'a9944193-2dfb-5944-b94c-41c41fdb7ca1'), 'PUBLISHED', 'claude_assessment_v1'),
  ('e58f8915-4129-5955-91ad-a032f58ac41a', v_aid, 22, 'A0', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Будьмо!». Що ви скажете?', null, '["Živjeli!", "Molim račun.", "Što želite?"]'::jsonb, 0, null, null, null, null, '«Будьмо!» — «Živjeli!».', (select id from public.lessons where id = '77d640c4-4190-544a-8094-4e699f9a0a10'), 'PUBLISHED', 'claude_assessment_v1'),
  ('64329000-86c1-58bf-9232-38b28b3c7576', v_aid, 23, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «хорватка»', null, '[]'::jsonb, null, 'Hrvatica', null, null, null, '«хорватка» — Hrvatica.', (select id from public.lessons where id = 'a9944193-2dfb-5944-b94c-41c41fdb7ca1'), 'PUBLISHED', 'claude_assessment_v1'),
  ('95283d84-6788-5630-b8de-714c28cf358c', v_aid, 24, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «нарізати»', null, '[]'::jsonb, null, 'narezati', null, null, null, '«нарізати» — narezati.', (select id from public.lessons where id = '0e925295-2766-5931-b031-2412682bc6f8'), 'PUBLISHED', 'claude_assessment_v1'),
  ('23c5dc88-f501-5836-adfc-572ecb609aa8', v_aid, 25, 'A0', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «заповнити»', null, '[]'::jsonb, null, 'ispuniti', null, null, null, '«заповнити» — ispuniti.', (select id from public.lessons where id = 'b095637e-0644-507e-8f3d-d323483dd3e4'), 'PUBLISHED', 'claude_assessment_v1'),
  ('b2d07aa1-752d-5a41-b813-4dba4c67e7a9', v_aid, 26, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Що є на сніданок?»', null, '["ima", "za", "doručak?", "Što"]'::jsonb, null, 'Što ima za doručak?', null, null, null, '«Що є на сніданок?» — «Što ima za doručak?».', (select id from public.lessons where id = '7bbaf7ff-10bb-512a-91c5-798b59ec92a5'), 'PUBLISHED', 'claude_assessment_v1'),
  ('df15cc98-ff04-5f54-93cf-f0edb5519ef8', v_aid, 27, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «Це моя сім’я.»', null, '["je", "To", "obitelj.", "moja"]'::jsonb, null, 'To je moja obitelj.', null, null, null, '«Це моя сім’я.» — «To je moja obitelj.».', (select id from public.lessons where id = '4e003796-1ce0-5a02-8a2d-59a0de38f3dd'), 'PUBLISHED', 'claude_assessment_v1'),
  ('e9ca052b-5574-5e13-ac10-2f1a79bac899', v_aid, 28, 'A0', 'writing', 'produce', 'sentence_builder', 'Складіть: «У кімнаті є ліжко й шафа.»', null, '["U", "i", "ormar.", "su", "sobi", "krevet"]'::jsonb, null, 'U sobi su krevet i ormar.', null, null, null, '«У кімнаті є ліжко й шафа.» — «U sobi su krevet i ormar.».', (select id from public.lessons where id = '1436c20e-0aea-550a-b66d-fb3149a1c2e2'), 'PUBLISHED', 'claude_assessment_v1'),
  ('e6b849a6-f82d-57ad-ba52-03faf820bda3', v_aid, 29, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Домовилися!»', null, '[]'::jsonb, null, 'Dogovoreno!', null, null, null, '«Домовилися!» — «Dogovoreno!».', (select id from public.lessons where id = '6836e57c-030c-59f8-9818-b44c08b126a6'), 'PUBLISHED', 'claude_assessment_v1'),
  ('c8eb3746-7bd3-5390-92bf-0d55a330e76d', v_aid, 30, 'A0', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Веселих свят!»', null, '[]'::jsonb, null, 'Sretni blagdani!', null, null, null, '«Веселих свят!» — «Sretni blagdani!».', (select id from public.lessons where id = 'd7cf3059-0d92-5215-8ef4-ad699e317b10'), 'PUBLISHED', 'claude_assessment_v1');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірку рівня оновлено під уроки за темою (curriculum_a0_v4) — завдання з нових діалогів і вправ усіх модулів A0. Потрібна перевірка носієм.');
end $$;

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_new int; v_bad int;
begin
  select count(*) into v_new from public.assessment_items where id in ('2d56a326-7e81-5ff2-954b-81c5d2d60d11', 'f4c2dc5c-aa5d-514f-ad4f-5e1aee000d31', 'ad14c9b4-f13c-5e99-9cbd-487780a52800', '80a57894-1059-5263-b760-fbc4f364604b', 'f76d242c-28e5-5b75-9395-02e5b8c16b64', 'ee06901f-aec1-5863-9de7-d686f6502b6a', 'b9f63ba0-ab31-5b5c-93c2-f2d28d07fffa', 'c5ed5cac-7428-52f2-98b1-08b639b674d7', 'b14e7f58-aba4-51d0-999f-8e40f78cbdf6', '5a2d4112-8e42-5a41-adf3-a77da80c56f6', 'dcd0bf1c-309e-5516-a019-4c7e61868bec', '6c3547ef-13bb-5c1f-ab6e-8cd886841c64', 'b60778cf-cfd8-5db2-8616-c43a0423bf87', 'd71d6f8a-443f-580a-9f10-16c0d1093b5e', '56a326fd-76c0-5d2e-81ff-871d6c9a5986', 'd6d38fe2-3716-58aa-93e9-7efe90708d89', '38e85534-fca2-5d92-9f1b-a8d5988d67f9', '3dc60cc2-9ecf-59db-977c-94ae825f4735', 'd39ad2c0-0b73-5d6b-a76d-da683ea46662', '1b76eb49-d9bd-5589-8662-31fd6d64cfd0', '7a85998e-ee0a-5584-8c33-405fb107ac8e', 'c646b0f0-257f-5fa9-a71c-57e703003bc6', '6af56d46-fb70-5fe2-94f8-4d2576a269a2', '62369ea1-447a-5ac8-96e1-40dac3b4cc68', '519a38dc-3c84-54ac-aeeb-ab8bc3c1a4ea', '2c4e1935-8119-5c2c-b467-537a11193536', 'f4538812-9db5-59c3-b0aa-5cdf72382165', '3934f94c-022d-5326-b70e-c59497fac78a', 'bd6df4ee-ef76-54b4-b175-bfb4d65eb837', '27e481a3-2a57-5c1b-9a40-1a151faa9a16', 'b809726c-c3a6-5d6e-b918-7a41d0a942b1', 'adb9f6f3-4143-52da-96b4-efac02ed3b3a', '099a217c-74eb-5a3d-84e9-30fe888bad1c', 'de763c6d-b902-53bc-a2dd-10bdcd3a9396', '8d9eadad-320f-5ab8-b4f7-37d1236124d5', '0b58be26-11fc-58ed-a0cd-4755ccc68fd2', 'f54e394d-739b-5c4e-b8f0-fe19b89f16c0', '83c8443b-cc8c-56df-9dd5-0161e3d71c4b', '87036e3e-0eff-5ae8-be14-20e3e258ae17', '4bcb4af7-afe9-5e5d-b86f-5ddf4652b023', '61ef3c19-e3da-596a-b7af-327e120570e2', 'e58f8915-4129-5955-91ad-a032f58ac41a', '64329000-86c1-58bf-9232-38b28b3c7576', '95283d84-6788-5630-b8de-714c28cf358c', '23c5dc88-f501-5836-adfc-572ecb609aa8', 'b2d07aa1-752d-5a41-b813-4dba4c67e7a9', 'df15cc98-ff04-5f54-93cf-f0edb5519ef8', 'e9ca052b-5574-5e13-ac10-2f1a79bac899', 'e6b849a6-f82d-57ad-ba52-03faf820bda3', 'c8eb3746-7bd3-5390-92bf-0d55a330e76d') and status = 'PUBLISHED';
  select count(*) into v_bad from (values ('a0-mid', 20), ('a0-final', 30)) e(slug, n) join public.assessments a on a.slug = e.slug
   where (select count(*) from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED') <> e.n
      or exists (select 1 from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'
                 and i.id not in ('2d56a326-7e81-5ff2-954b-81c5d2d60d11', 'f4c2dc5c-aa5d-514f-ad4f-5e1aee000d31', 'ad14c9b4-f13c-5e99-9cbd-487780a52800', '80a57894-1059-5263-b760-fbc4f364604b', 'f76d242c-28e5-5b75-9395-02e5b8c16b64', 'ee06901f-aec1-5863-9de7-d686f6502b6a', 'b9f63ba0-ab31-5b5c-93c2-f2d28d07fffa', 'c5ed5cac-7428-52f2-98b1-08b639b674d7', 'b14e7f58-aba4-51d0-999f-8e40f78cbdf6', '5a2d4112-8e42-5a41-adf3-a77da80c56f6', 'dcd0bf1c-309e-5516-a019-4c7e61868bec', '6c3547ef-13bb-5c1f-ab6e-8cd886841c64', 'b60778cf-cfd8-5db2-8616-c43a0423bf87', 'd71d6f8a-443f-580a-9f10-16c0d1093b5e', '56a326fd-76c0-5d2e-81ff-871d6c9a5986', 'd6d38fe2-3716-58aa-93e9-7efe90708d89', '38e85534-fca2-5d92-9f1b-a8d5988d67f9', '3dc60cc2-9ecf-59db-977c-94ae825f4735', 'd39ad2c0-0b73-5d6b-a76d-da683ea46662', '1b76eb49-d9bd-5589-8662-31fd6d64cfd0', '7a85998e-ee0a-5584-8c33-405fb107ac8e', 'c646b0f0-257f-5fa9-a71c-57e703003bc6', '6af56d46-fb70-5fe2-94f8-4d2576a269a2', '62369ea1-447a-5ac8-96e1-40dac3b4cc68', '519a38dc-3c84-54ac-aeeb-ab8bc3c1a4ea', '2c4e1935-8119-5c2c-b467-537a11193536', 'f4538812-9db5-59c3-b0aa-5cdf72382165', '3934f94c-022d-5326-b70e-c59497fac78a', 'bd6df4ee-ef76-54b4-b175-bfb4d65eb837', '27e481a3-2a57-5c1b-9a40-1a151faa9a16', 'b809726c-c3a6-5d6e-b918-7a41d0a942b1', 'adb9f6f3-4143-52da-96b4-efac02ed3b3a', '099a217c-74eb-5a3d-84e9-30fe888bad1c', 'de763c6d-b902-53bc-a2dd-10bdcd3a9396', '8d9eadad-320f-5ab8-b4f7-37d1236124d5', '0b58be26-11fc-58ed-a0cd-4755ccc68fd2', 'f54e394d-739b-5c4e-b8f0-fe19b89f16c0', '83c8443b-cc8c-56df-9dd5-0161e3d71c4b', '87036e3e-0eff-5ae8-be14-20e3e258ae17', '4bcb4af7-afe9-5e5d-b86f-5ddf4652b023', '61ef3c19-e3da-596a-b7af-327e120570e2', 'e58f8915-4129-5955-91ad-a032f58ac41a', '64329000-86c1-58bf-9232-38b28b3c7576', '95283d84-6788-5630-b8de-714c28cf358c', '23c5dc88-f501-5836-adfc-572ecb609aa8', 'b2d07aa1-752d-5a41-b813-4dba4c67e7a9', 'df15cc98-ff04-5f54-93cf-f0edb5519ef8', 'e9ca052b-5574-5e13-ac10-2f1a79bac899', 'e6b849a6-f82d-57ad-ba52-03faf820bda3', 'c8eb3746-7bd3-5390-92bf-0d55a330e76d'));
  if v_new <> 50 or v_bad > 0 then raise exception 'Середина й фінал A0: нових завдань %, тестів з помилкою %', v_new, v_bad; end if;
  raise notice 'Готово: середину й фінал рівня A0 оновлено — % нових завдань', v_new;
end $$;

commit;
