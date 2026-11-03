-- =====================================================================
-- Перевірка модуля A1.5 під програму A1 v3 · 2026-10-26
-- Згенеровано: python3 -B scripts/gen_assessment_a1_v3.py 5 (не редагуйте вручну).
--
-- Тести: a1-m05 — по 10 завдань із нових діалогів і вправ модуля.
--   * Стара версія завдань — у content_versions; старі завдання → DEPRECATED (не видаляються).
--   * Нові завдання — PUBLISHED (бета, як уроки A1). Середину й фінал рівня A1 не змінено (їх — після всього A1).
--   * Потрібні: 20261026_curriculum_a1_v3_structure.sql і 20261026_curriculum_a1_v3_m05.sql.
--   * Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

-- Перевірка модуля A1.5 · Модуль A1.5 — Житло
do $$
declare v_aid uuid; v_payload jsonb;
begin
  select id into v_aid from public.assessments where slug = 'a1-m05';
  if v_aid is null then  -- новий модуль програми v3: тесту ще немає
    insert into public.assessments (id, slug, kind, title_ua, version, status, source, cefr, module_id, order_index, pass_ratio,
                                    area_min_ratio, estimated_minutes, description_ua)
    values ('4cf82cb9-3195-5ee5-a26c-3a8d55415318', 'a1-m05', 'module', 'Перевірка модуля A1.5', 1, 'PUBLISHED', 'claude_assessment_v1', 'A1',
            '82ce9ca7-ea90-5413-94a6-d69b1a1cd72b', 5, 0.70, 0.50, 5, 'Після модуля: 10 завдань на 4 навички — розумію, спілкуюся, переказую, кажу. ~5 хв.')
    returning id into v_aid;
  end if;
  if exists (select 1 from public.assessment_items where id = 'ac90351f-7641-5314-a347-48abd42ff3bd') then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from '82ce9ca7-ea90-5413-94a6-d69b1a1cd72b'::uuid then
    raise exception 'Тест a1-m05 прив’язаний не до модуля A1.5 — спершу 20261026_curriculum_a1_v3_structure.sql';
  end if;
  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
          v_payload, 'curriculum_a1_v3: перевірку модуля оновлено під нові уроки — старі завдання');
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + 100
   where assessment_id = v_aid and status = 'PUBLISHED' and order_index <= 100;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
  ('ac90351f-7641-5314-a347-48abd42ff3bd', v_aid, 1, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Добре. А що з плиткою у ванній?", "Де ти хочеш полицю — над ліжком?", "Зрозуміло. Тут усі дотримуються правил?"]'::jsonb, 2, null, 'Razumijem. Ovdje svi poštuju pravila?', null, null, 'Прозвучало: «Razumijem. Ovdje svi poštuju pravila?» — «Зрозуміло. Тут усі дотримуються правил?».', (select id from public.lessons where id = 'f296bc84-8059-5981-a5b9-9d4531627e18'), 'PUBLISHED', 'claude_assessment_v1'),
  ('579a2465-46c1-5ab8-a2e3-0a71ec339d9e', v_aid, 2, 'A1', 'listening', 'understand', 'multiple_choice', 'Послухайте. Що сказали?', null, '["Можна мені взяти м’яч у садок?", "Дякую вам. А вам, може, допомогти зі сходами?", "Добрий день, де можна прочитати правила будинку?"]'::jsonb, 1, null, 'Hvala vam. A trebate li možda pomoć sa stepenicama?', null, null, 'Прозвучало: «Hvala vam. A trebate li možda pomoć sa stepenicama?» — «Дякую вам. А вам, може, допомогти зі сходами?».', (select id from public.lessons where id = 'a42b9121-2ec0-5064-909b-f59f315b3c4a'), 'PUBLISHED', 'claude_assessment_v1'),
  ('bc4faa72-86cc-5d1c-89b3-76de601f2797', v_aid, 3, 'A1', 'reading', 'understand', 'multiple_choice', 'Куди викидати пляшку зі скла?', 'Odvajanje otpada', '["У жовтий", "У зелений контейнер", "У синій"]'::jsonb, 1, null, null, 'ODVAJAJTE OTPAD!
Plava kanta: papir i karton.
Žuta kanta: plastika i limenke.
Zelena kanta: staklo.
Smeđa kanta: ostaci hrane.
Crna kanta: ostalo smeće.
Smeće iznosimo navečer, prije osam sati. Velike stvari ne ostavljajte pored kanti.', 'СОРТУЙТЕ ВІДХОДИ!
Синій контейнер: папір і картон.
Жовтий контейнер: пластик і бляшанки.
Зелений контейнер: скло.
Коричневий контейнер: залишки їжі.
Чорний контейнер: інше сміття.
Сміття виносимо ввечері, до восьмої години. Великих речей не залишайте біля контейнерів.', 'Текст «Сміття й переробка». Правильна відповідь: «У зелений контейнер».', null, 'PUBLISHED', 'claude_assessment_v1'),
  ('c5a6deaf-5fd7-5f94-ae46-9cfe555dc341', v_aid, 4, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Ima li zgrada dvorište za djecu?', '["Napravi mi kajganu i jedan tost, molim te.", "Oko tri i pol sata, sa stankom od petnaest minuta.", "Ima, iza zgrade, s malim igralištem."]'::jsonb, 2, null, 'Ima li zgrada dvorište za djecu?', null, null, 'Діалог «Огляд квартири»: «Ima li zgrada dvorište za djecu?» (А в будинку є подвір’я для дітей?) — «Ima, iza zgrade, s malim igralištem.» (Є, за будинком, з невеликим майданчиком.).', (select id from public.lessons where id = '278947e3-ae50-5818-abd7-7f07b8ab5c44'), 'PUBLISHED', 'claude_assessment_v1'),
  ('d9b23791-1716-518e-aeff-96f108875a6f', v_aid, 5, 'A1', 'interaction', 'interact', 'multiple_choice', 'Вам кажуть. Що доречно відповісти?', 'Je li dopušteno ostaviti stari namještaj pored kontejnera?', '["Nije, to je zabranjeno. Zovite odvoz glomaznog otpada.", "Šest eura, a juha je besplatna.", "Sutra popodne, ako stigne rezervni dio."]'::jsonb, 0, null, 'Je li dopušteno ostaviti stari namještaj pored kontejnera?', null, null, 'Діалог «Сміття й переробка»: «Je li dopušteno ostaviti stari namještaj pored kontejnera?» (Можна залишити старі меблі біля контейнера?) — «Nije, to je zabranjeno. Zovite odvoz glomaznog otpada.» (Ні, це заборонено. Викличте вивіз великогабаритного сміття.).', (select id from public.lessons where id = 'f296bc84-8059-5981-a5b9-9d4531627e18'), 'PUBLISHED', 'claude_assessment_v1'),
  ('63aa7865-f305-5c10-8ae8-e3a5318aa218', v_aid, 6, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг поруч не знає хорватської. Перекажіть йому українською, що відповіли на питання:', 'Gdje je ovdje pješačka zona?', '["Одразу за пам’ятником починається старе місто.", "Це старе кладовище, там тихо й гарно.", "Можна. Довкола фонтана — найгарніша частина міста."]'::jsonb, 0, null, null, 'Darja: Gdje je ovdje pješačka zona?
Marko: Odmah iza spomenika počinje stara jezgra.
Darja: Možemo li sjesti na klupu kod fontane?
Marko: Može. Okolica fontane je najljepši dio grada.
Darja: A što je ono na brdu?
Marko: To je staro groblje, ondje je mirno i lijepo.', 'Darja: Де тут пішохідна зона?
Marko: Одразу за пам’ятником починається старе місто.
Darja: Можемо сісти на лавку біля фонтана?
Marko: Можна. Довкола фонтана — найгарніша частина міста.
Darja: А що ото на пагорбі?
Marko: Це старе кладовище, там тихо й гарно.', 'Діалог «Прогулянка старим містом»: «Gdje je ovdje pješačka zona?» — «Odmah iza spomenika počinje stara jezgra.», тобто «Одразу за пам’ятником починається старе місто.».', (select id from public.lessons where id = '3ea9520d-2baa-56b2-aa85-402e3e3ecb9b'), 'PUBLISHED', 'claude_assessment_v1'),
  ('90056a0b-0ed2-5a73-beec-dd0b2f689aec', v_aid, 7, 'A1', 'mediation', 'mediate', 'multiple_choice', 'Друг-українець просить вас сказати хорватською: «Кран тече». Що ви скажете?', null, '["Možete li zalijevati cvijeće?", "To je zabranjeno.", "Slavina curi."]'::jsonb, 2, null, null, null, null, '«Кран тече.» — «Slavina curi.».', (select id from public.lessons where id = '8fc3399d-0405-5517-9358-d3ad6308d860'), 'PUBLISHED', 'claude_assessment_v1'),
  ('a480221c-dea8-5f2b-aa25-d2acb5f58b4d', v_aid, 8, 'A1', 'writing', 'produce', 'type_answer', 'Напишіть хорватською: «переїзд»', null, '[]'::jsonb, null, 'selidba', null, null, null, '«переїзд» — selidba.', (select id from public.lessons where id = '23f3aad6-4447-5b75-9dd1-891773457f7e'), 'PUBLISHED', 'claude_assessment_v1'),
  ('496ce1eb-ada9-5cd1-b2d4-7969286178d0', v_aid, 9, 'A1', 'writing', 'produce', 'sentence_builder', 'Складіть: «Квартира одразу готова до заселення.»', null, '["Stan", "useljiv.", "je", "odmah"]'::jsonb, null, 'Stan je odmah useljiv.', null, null, null, '«Квартира одразу готова до заселення.» — «Stan je odmah useljiv.».', (select id from public.lessons where id = '278947e3-ae50-5818-abd7-7f07b8ab5c44'), 'PUBLISHED', 'claude_assessment_v1'),
  ('3f403aae-3f64-5690-8bf0-01e7b0bf76fa', v_aid, 10, 'A1', 'speaking', 'produce', 'speaking', 'Скажіть хорватською: «Це крихке, обережно!»', null, '[]'::jsonb, null, 'Ovo je lomljivo, pažljivo!', null, null, null, '«Це крихке, обережно!» — «Ovo je lomljivo, pažljivo!».', (select id from public.lessons where id = '23f3aad6-4447-5b75-9dd1-891773457f7e'), 'PUBLISHED', 'claude_assessment_v1');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: перевірку модуля оновлено під програму A1 v3 — завдання з нових діалогів і вправ. Потрібна перевірка носієм.');
end $$;

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_new int; v_bad int;
begin
  select count(*) into v_new from public.assessment_items where id in ('ac90351f-7641-5314-a347-48abd42ff3bd', '579a2465-46c1-5ab8-a2e3-0a71ec339d9e', 'bc4faa72-86cc-5d1c-89b3-76de601f2797', 'c5a6deaf-5fd7-5f94-ae46-9cfe555dc341', 'd9b23791-1716-518e-aeff-96f108875a6f', '63aa7865-f305-5c10-8ae8-e3a5318aa218', '90056a0b-0ed2-5a73-beec-dd0b2f689aec', 'a480221c-dea8-5f2b-aa25-d2acb5f58b4d', '496ce1eb-ada9-5cd1-b2d4-7969286178d0', '3f403aae-3f64-5690-8bf0-01e7b0bf76fa') and status = 'PUBLISHED';
  select count(*) into v_bad from public.assessments a
   where a.slug in ('a1-m05')
     and ((select count(*) from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED') <> 10
          or exists (select 1 from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED' and i.id not in ('ac90351f-7641-5314-a347-48abd42ff3bd', '579a2465-46c1-5ab8-a2e3-0a71ec339d9e', 'bc4faa72-86cc-5d1c-89b3-76de601f2797', 'c5a6deaf-5fd7-5f94-ae46-9cfe555dc341', 'd9b23791-1716-518e-aeff-96f108875a6f', '63aa7865-f305-5c10-8ae8-e3a5318aa218', '90056a0b-0ed2-5a73-beec-dd0b2f689aec', 'a480221c-dea8-5f2b-aa25-d2acb5f58b4d', '496ce1eb-ada9-5cd1-b2d4-7969286178d0', '3f403aae-3f64-5690-8bf0-01e7b0bf76fa')));
  if v_new <> 10 or v_bad > 0 then raise exception 'Перевірки модулів A1: нових завдань %, тестів з помилкою %', v_new, v_bad; end if;
  raise notice 'Готово: перевірку a1-m05 оновлено — % нових завдань', v_new;
end $$;

commit;
