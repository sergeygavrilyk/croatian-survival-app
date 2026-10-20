-- =====================================================================
-- Тести: уроки A0 за темою (curriculum_a0_v4) · модуль A0.4 «Vrijeme» · 2026-10-19
-- Запускати ПІСЛЯ supabase/data_fixes/20261019_curriculum_a0_v4_m04.sql.
-- БЕЗПЕЧНО для робочої бази: одна транзакція, у кінці ROLLBACK.
-- Запуск: Supabase → SQL Editor → вставити файл → Run. Успіх: «ALL TESTS PASSED».
-- =====================================================================
begin;

create or replace function pg_temp.ok(cond boolean, msg text) returns text language plpgsql as $$
begin
  if cond is distinct from true then raise exception 'FAIL: %', msg; end if;
  return 'ok - ' || msg;
end $$;

create or replace function pg_temp.n(q text) returns bigint language plpgsql as $$
declare r bigint;
begin
  execute 'select count(*) from (' || q || ') s' into r;
  return r;
end $$;

-- уроки модуля A0.4 у новому порядку (id, місце)
create or replace function pg_temp.m4() returns table (lid uuid, o int) language sql as $$
  select * from (values ('8e372ece-ae10-50ae-9cf3-07b52ef2f72d'::uuid, 1), ('238d9508-3c2e-5ee6-910f-0ae8863c2dc7'::uuid, 2), ('39b1e31f-b573-5000-9713-1660688c3cc9'::uuid, 3), ('036fc4fb-1bf2-5100-9fd0-6f6a612554a1'::uuid, 4), ('b36b4550-ff36-50cb-89fb-8246b351c8d6'::uuid, 5), ('efcf49e0-c058-5986-9cf7-aee921887a81'::uuid, 6), ('d7cf3059-0d92-5215-8ef4-ad699e317b10'::uuid, 7)) as t(lid, o)
$$;

-- ---------------------------------------------------------------- модуль і порядок
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
  where m.level_code = 'A0' and m.order_index = 4 and l.status = 'PUBLISHED'$q$) = 7, 'у модулі A0.4 — 7 опублікованих уроків');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m4() t join public.lessons l on l.id = t.lid and l.order_index = t.o$q$) = 7,
  'уроки A0.4 стоять у новому порядку (5 наявних + 2 нові)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where level_code = 'A0' and status = 'PUBLISHED'$q$) >= 58, 'A0: щонайменше 58 уроків');
select pg_temp.ok(pg_temp.n($q$select 1 from (
    select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
      from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
     where l.level_code = 'A0' and l.status = 'PUBLISHED') t
  where t.title_ua not like 'Урок ' || t.n || ':%' or t.title_hr not like 'Lekcija ' || t.n || ':%'$q$) = 0,
  'назви уроків A0 пронумеровано підряд');
select pg_temp.ok((select title_ua from public.lessons where id = '8e372ece-ae10-50ae-9cf3-07b52ef2f72d') = 'Урок 24: Дні тижня'
  and (select title_ua from public.lessons where id = 'd7cf3059-0d92-5215-8ef4-ad699e317b10') = 'Урок 30: Свята й привітання', 'модуль A0.4 — уроки 24–30');

-- ---------------------------------------------------------------- склад уроків
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m4() v
  where (select count(*) from public.lesson_items i where i.lesson_id = v.lid and i.item_type = 'lexeme') not between 20 and 25$q$) = 0,
  'у кожному уроці 20–25 слів і виразів');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m4() v
  where (select count(*) from public.lesson_items i join public.exercises e on e.id = i.item_id
         where i.lesson_id = v.lid and i.item_type = 'exercise' and e.status = 'PUBLISHED') <> 15
     or (select count(*) from public.lesson_items i where i.lesson_id = v.lid and i.item_type = 'exercise') <> 15$q$) = 0,
  'у кожному уроці 15 опублікованих вправ');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m4() v
  where (select count(distinct e.exercise_type) from public.lesson_items i join public.exercises e on e.id = i.item_id
         where i.lesson_id = v.lid and i.item_type = 'exercise') < 6$q$) = 0, 'у кожному уроці всі 6 типів вправ');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m4() v
  where (select count(*) from public.conversations c where c.lesson_id = v.lid and c.status = 'PUBLISHED' and c.source = 'claude_curriculum_a0_v4') <> 2
     or exists (select 1 from public.conversations c where c.lesson_id = v.lid and c.status = 'PUBLISHED' and c.source is distinct from 'claude_curriculum_a0_v4')
     or (select count(*) from public.conversation_turns t join public.conversations c on c.id = t.conversation_id
         where c.lesson_id = v.lid and c.status = 'PUBLISHED') not between 8 and 12$q$) = 0,
  'у кожному уроці 2 нові діалоги по 4–6 реплік, старі не показуються');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where id in (select lid from pg_temp.m4())
  and (estimated_minutes <> 15 or jsonb_array_length(objectives) < 2 or status <> 'PUBLISHED')$q$) = 0, 'урок — 15 хвилин, щонайменше 2 цілі');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m4() v
  where not exists (select 1 from public.lesson_items i where i.lesson_id = v.lid and i.item_type = 'grammar')
     or not exists (select 1 from public.lesson_grammar g where g.lesson_id = v.lid)$q$) = 0,
  'у кожному уроці є тема граматики («Котра година?» і «Місяці й пори року» отримали «Час: дні, години, місяці»)');
select pg_temp.ok(pg_temp.n($q$select i.item_id from public.lesson_items i
  where i.lesson_id in (select lid from pg_temp.m4()) and i.item_type = 'lexeme' group by 1 having count(*) > 1$q$) = 0,
  'жодне слово не повторюється в різних уроках модуля');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items i
  where i.lesson_id in (select lid from pg_temp.m4()) and i.item_type = 'lexeme'
    and i.item_id in (select i1.item_id from public.lesson_items i1 join public.lessons l on l.id = i1.lesson_id
                       join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
                      where m.level_code = 'A0' and m.order_index in (1, 2, 3) and i1.item_type = 'lexeme')$q$) = 0,
  'слова A0.4 не повторюють слів A0.1–A0.3');

-- ---------------------------------------------------------------- тема модуля
select pg_temp.ok(pg_temp.n($q$select distinct lower(x.lemma) from public.lesson_items i join public.lexemes x on x.id = i.item_id
  where i.lesson_id in (select lid from pg_temp.m4()) and i.item_type = 'lexeme'
    and lower(x.lemma) in ('ponedjeljak', 'utorak', 'srijeda', 'četvrtak', 'petak', 'subota', 'nedjelja',
                           'siječanj', 'veljača', 'ožujak', 'travanj', 'svibanj', 'lipanj', 'srpanj', 'kolovoz', 'rujan', 'listopad', 'studeni', 'prosinac',
                           'proljeće', 'ljeto', 'jesen', 'zima', 'jučer', 'danas', 'sutra', 'koliko je sati')$q$) = 27,
  'у модулі всі дні тижня, 12 місяців, 4 пори року, учора / сьогодні / завтра й «котра година»');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items i join public.lexemes x on x.id = i.item_id
  where i.lesson_id = 'efcf49e0-c058-5986-9cf7-aee921887a81' and i.item_type = 'lexeme'
    and lower(x.lemma) in ('vrijeme', 'kakvo je vrijeme', 'sunčano', 'kiša', 'snijeg', 'vjetar', 'hladno', 'toplo', 'bura', 'jugo')$q$) = 10,
  'урок «Погода»: погода, сонячно, дощ, сніг, вітер, холодно, тепло, бура, юго');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items i join public.lexemes x on x.id = i.item_id
  where i.lesson_id = 'd7cf3059-0d92-5215-8ef4-ad699e317b10' and i.item_type = 'lexeme'
    and lower(x.lemma) in ('božić', 'nova godina', 'uskrs', 'sretan božić', 'sretna nova godina', 'sretni blagdani', 'neradni dan')$q$) = 7,
  'урок «Свята»: Різдво, Новий рік, Великдень, привітання, неробочий день');
select pg_temp.ok(pg_temp.n($q$select 1 from public.grammar_topics g where g.id = '8feb6432-33f0-5645-ad22-b4215fe3771f' and g.status = 'PUBLISHED' and g.cefr = 'A0'
  and (select count(*) from public.grammar_rules r where r.topic_id = g.id and jsonb_array_length(r.examples) >= 3) = 3$q$) = 1,
  'нова тема граматики «Погода: безособові речення» — 3 правила з прикладами');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_grammar lg join public.grammar_topics g on g.id = lg.grammar_topic_id
  where (lg.lesson_id = 'efcf49e0-c058-5986-9cf7-aee921887a81' and g.id = '8feb6432-33f0-5645-ad22-b4215fe3771f')
     or (lg.lesson_id = 'd7cf3059-0d92-5215-8ef4-ad699e317b10' and g.title_ua = 'Прикметники: узгодження з іменником')$q$) = 2,
  'урок «Погода» — тема «Погода», урок «Свята» — узгодження прикметника (Sretan Božić / Sretna Nova godina)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where source = 'claude_curriculum_a0_v4' and status = 'PUBLISHED' and cefr = 'A0'
  and normalized !~ '[čćđšž]' and normalized = lower(normalized) and lemma !~ '[Ѐ-ӿ]' and ukrainian_translation ~ '[Ѐ-ӿ]'
  and jsonb_array_length(examples) = 1 and lower(lemma) in ('radni dan', 'jutros', 'sinoć', 'noću', 'u koliko sati', 'četvrt', 'i pol', 'sat vremena', 'zakasniti', 'godišnje doba', 'ljeti', 'zimi', 'u proljeće', 'na jesen', 'koji je danas datum', 'rok trajanja', 'produžiti', 'boravišna dozvola', 'početkom', 'krajem', 'za tjedan dana', 'ove godine', 'prošle godine', 'sljedeće godine', 'kakvo je vrijeme', 'sunčano', 'oblačno', 'pada kiša', 'koliko je stupnjeva', 'sretan uskrs', 'sretni blagdani', 'valentinovo', 'majčin dan', 'sve najbolje', 'želim ti')$q$) = 35,
  '35 нових слів і виразів A0.4: без кирилиці в лемі, normalized без діакритики, переклад і приклад');

-- ---------------------------------------------------------------- стара версія збережена
select pg_temp.ok(pg_temp.n($q$select 1 from (values ('8e372ece-ae10-50ae-9cf3-07b52ef2f72d'::uuid), ('238d9508-3c2e-5ee6-910f-0ae8863c2dc7'::uuid), ('39b1e31f-b573-5000-9713-1660688c3cc9'::uuid), ('036fc4fb-1bf2-5100-9fd0-6f6a612554a1'::uuid), ('b36b4550-ff36-50cb-89fb-8246b351c8d6'::uuid)) v(lid)
  where not exists (select 1 from public.content_versions cv where cv.entity_type = 'lesson' and cv.entity_id = v.lid
                    and cv.change_reason like 'curriculum_a0_v4: урок перебудовано%' and jsonb_array_length(cv.payload->'items') > 0)$q$) = 0,
  'стара версія кожного перебудованого уроку — у content_versions');
select pg_temp.ok(pg_temp.n($q$select 1 from public.conversations c
  where c.id in (select jsonb_array_elements_text(v.payload->'conversations')::uuid from public.content_versions v
                 where v.change_reason like 'curriculum_a0_v4%' and v.entity_id in ('8e372ece-ae10-50ae-9cf3-07b52ef2f72d', '238d9508-3c2e-5ee6-910f-0ae8863c2dc7', '39b1e31f-b573-5000-9713-1660688c3cc9', '036fc4fb-1bf2-5100-9fd0-6f6a612554a1', 'b36b4550-ff36-50cb-89fb-8246b351c8d6'))
    and c.status <> 'DEPRECATED'$q$) = 0, 'старі діалоги — DEPRECATED (не видалені)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.exercises e
  where e.id in (select b.item_id from backup.lesson_items_20261015 b where b.item_type = 'exercise' and b.lesson_id in ('8e372ece-ae10-50ae-9cf3-07b52ef2f72d', '238d9508-3c2e-5ee6-910f-0ae8863c2dc7', '39b1e31f-b573-5000-9713-1660688c3cc9', '036fc4fb-1bf2-5100-9fd0-6f6a612554a1', 'b36b4550-ff36-50cb-89fb-8246b351c8d6'))
    and e.status <> 'DEPRECATED'$q$) = 0, 'старі вправи — DEPRECATED (не видалені)');

-- ---------------------------------------------------------------- видимість
set local role anon;
select pg_temp.ok(pg_temp.n($q$select 1 from public.conversations where source = 'claude_curriculum_a0_v4' and lesson_id in (select lid from pg_temp.m4())$q$) = 14,
  'гість бачить 14 нових діалогів A0.4');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where id in ('efcf49e0-c058-5986-9cf7-aee921887a81', 'd7cf3059-0d92-5215-8ef4-ad699e317b10')$q$) = 2, 'гість бачить 2 нові уроки');
select pg_temp.ok(pg_temp.n($q$select 1 from public.grammar_rules where topic_id = '8feb6432-33f0-5645-ad22-b4215fe3771f'$q$) = 3, 'гість бачить 3 нові правила граматики');
reset role;

select 'ALL TESTS PASSED' as result;
rollback;
