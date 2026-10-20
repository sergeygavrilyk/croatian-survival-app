-- =====================================================================
-- Тести: уроки A0 за темою (curriculum_a0_v4) · модуль A0.10 «Survival» · 2026-10-20
-- Запускати ПІСЛЯ supabase/data_fixes/20261020_curriculum_a0_v4_m10.sql.
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

-- уроки модуля A0.10 у новому порядку (id, місце): 5 перебудованих + 2 нові (частини тіла; «Допоможіть!»)
create or replace function pg_temp.m10() returns table (lid uuid, o int) language sql as $$
  select * from (values ('edbae9ca-c4f4-575d-b876-d50b0a1fd9b5'::uuid, 1), ('599fba4f-4cee-5a88-9f9b-5ce32a445554'::uuid, 2), ('fbc71f82-e715-5bab-a990-b8542fb0fe01'::uuid, 3), ('48f26e9d-96c5-5189-8ec6-db1f9d58e200'::uuid, 4), ('d2689a70-cb73-515f-9d81-6bb0f0fc1cff'::uuid, 5), ('b095637e-0644-507e-8f3d-d323483dd3e4'::uuid, 6), ('19df3241-90f3-5450-94ac-642d79fb2869'::uuid, 7)) as t(lid, o)
$$;

-- ---------------------------------------------------------------- модуль і порядок
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
  where m.level_code = 'A0' and m.order_index = 10 and l.status = 'PUBLISHED'$q$) = 7, 'у модулі A0.10 — 7 опублікованих уроків');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m10() t join public.lessons l on l.id = t.lid and l.order_index = t.o$q$) = 7,
  'уроки A0.10 стоять у новому порядку (5 наявних + 2 нові)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where level_code = 'A0' and status = 'PUBLISHED'$q$) >= 66, 'A0: щонайменше 66 уроків');
select pg_temp.ok(pg_temp.n($q$select 1 from (
    select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
      from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
     where l.level_code = 'A0' and l.status = 'PUBLISHED') t
  where t.title_ua not like 'Урок ' || t.n || ':%' or t.title_hr not like 'Lekcija ' || t.n || ':%'$q$) = 0,
  'назви уроків A0 пронумеровано підряд');
select pg_temp.ok((select title_ua from public.lessons where id = 'edbae9ca-c4f4-575d-b876-d50b0a1fd9b5') = 'Урок 60: У готелі'
  and (select title_ua from public.lessons where id = '599fba4f-4cee-5a88-9f9b-5ce32a445554') = 'Урок 61: Частини тіла'
  and (select title_ua from public.lessons where id = '48f26e9d-96c5-5189-8ec6-db1f9d58e200') = 'Урок 63: Допоможіть!'
  and (select title_ua from public.lessons where id = '19df3241-90f3-5450-94ac-642d79fb2869') = 'Урок 66: Документи в MUP', 'модуль A0.10 — уроки 60–66');

-- ---------------------------------------------------------------- склад уроків
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m10() v
  where (select count(*) from public.lesson_items i where i.lesson_id = v.lid and i.item_type = 'lexeme') not between 20 and 25$q$) = 0,
  'у кожному уроці 20–25 слів і виразів');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m10() v
  where (select count(*) from public.lesson_items i join public.exercises e on e.id = i.item_id
         where i.lesson_id = v.lid and i.item_type = 'exercise' and e.status = 'PUBLISHED') <> 15
     or (select count(*) from public.lesson_items i where i.lesson_id = v.lid and i.item_type = 'exercise') <> 15$q$) = 0,
  'у кожному уроці 15 опублікованих вправ');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m10() v
  where (select count(distinct e.exercise_type) from public.lesson_items i join public.exercises e on e.id = i.item_id
         where i.lesson_id = v.lid and i.item_type = 'exercise') < 6$q$) = 0, 'у кожному уроці всі 6 типів вправ');
select pg_temp.ok(pg_temp.n($q$select 1 from pg_temp.m10() v
  where (select count(*) from public.conversations c where c.lesson_id = v.lid and c.status = 'PUBLISHED' and c.source = 'claude_curriculum_a0_v4') <> 2
     or exists (select 1 from public.conversations c where c.lesson_id = v.lid and c.status = 'PUBLISHED' and c.source is distinct from 'claude_curriculum_a0_v4')
     or (select count(*) from public.conversation_turns t join public.conversations c on c.id = t.conversation_id
         where c.lesson_id = v.lid and c.status = 'PUBLISHED') not between 8 and 12$q$) = 0,
  'у кожному уроці 2 нові діалоги по 4–6 реплік, старі не показуються');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where id in (select lid from pg_temp.m10())
  and (estimated_minutes <> 15 or jsonb_array_length(objectives) < 2 or status <> 'PUBLISHED')$q$) = 0, 'урок — 15 хвилин, щонайменше 2 цілі');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items i
  where i.lesson_id in ('599fba4f-4cee-5a88-9f9b-5ce32a445554', '48f26e9d-96c5-5189-8ec6-db1f9d58e200') and i.item_type = 'grammar'$q$) = 2
  and pg_temp.n($q$select 1 from public.lesson_grammar g where g.lesson_id in ('599fba4f-4cee-5a88-9f9b-5ce32a445554', '48f26e9d-96c5-5189-8ec6-db1f9d58e200')$q$) = 2,
  'нові уроки мають тему граматики');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_grammar lg join public.grammar_topics g on g.id = lg.grammar_topic_id
  where lg.lesson_id = 'fbc71f82-e715-5bab-a990-b8542fb0fe01' and g.title_ua = 'Дієслово «imati» (мати)'$q$) = 1
  and pg_temp.n($q$select 1 from public.lesson_grammar lg join public.grammar_topics g on g.id = lg.grammar_topic_id
  where lg.lesson_id = '48f26e9d-96c5-5189-8ec6-db1f9d58e200' and g.title_ua = 'Ввічливість: ti і Vi'$q$) = 1,
  'урок «У лікаря» отримав тему «imati», урок «Допоможіть!» — «ti і Vi»');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
  where m.level_code = 'A0' and m.order_index = 10 and l.id not in (select lid from pg_temp.m10())$q$) = 0, 'інших уроків у модулі немає');
select pg_temp.ok(pg_temp.n($q$select i.item_id from public.lesson_items i
  where i.lesson_id in (select lid from pg_temp.m10()) and i.item_type = 'lexeme' group by 1 having count(*) > 1$q$) = 0,
  'жодне слово не повторюється в різних уроках модуля');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items i
  where i.lesson_id in (select lid from pg_temp.m10()) and i.item_type = 'lexeme'
    and i.item_id in (select i1.item_id from public.lesson_items i1 join public.lessons l on l.id = i1.lesson_id
                       join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
                      where m.level_code = 'A0' and m.order_index between 1 and 9 and i1.item_type = 'lexeme')$q$) = 0,
  'слова A0.10 не повторюють слів A0.1–A0.9');

-- ---------------------------------------------------------------- тема модуля
select pg_temp.ok(pg_temp.n($q$select distinct lower(x.lemma) from public.lesson_items i join public.lexemes x on x.id = i.item_id
  where i.lesson_id in (select lid from pg_temp.m10()) and i.item_type = 'lexeme'
    and lower(x.lemma) in ('hotel', 'recepcija', 'glava', 'ruka', 'noga', 'liječnik', 'ljekarna', 'upomoć', 'hitna pomoć',
                           'policija', 'krađa', 'obrazac', 'potpisati', 'mup', 'zahtjev')$q$) = 15,
  'у модулі готель, частини тіла, лікар і аптека, надзвичайні ситуації, поліція, анкета, MUP');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items i join public.lexemes x on x.id = i.item_id
  where i.lesson_id = '599fba4f-4cee-5a88-9f9b-5ce32a445554' and i.item_type = 'lexeme'
    and lower(x.lemma) in ('glava', 'grlo', 'ruka', 'noga', 'leđa', 'trbuh', 'zub', 'koljeno', 'boljeti')$q$) = 9,
  'урок «Частини тіла»: голова, горло, рука, нога, спина, живіт, зуб, коліно, болити');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_items i join public.lexemes x on x.id = i.item_id
  where i.lesson_id = '48f26e9d-96c5-5189-8ec6-db1f9d58e200' and i.item_type = 'lexeme'
    and lower(x.lemma) in ('upomoć', 'trebam pomoć', 'zovite hitnu', 'zovite policiju', 'vatrogasac', 'požar', 'izgubio sam se')$q$) = 7,
  'урок «Допоможіть!»: upomoć, trebam pomoć, викликати швидку, поліцію, пожежників, «я заблукав»');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lesson_grammar lg join public.grammar_topics g on g.id = lg.grammar_topic_id
  where lg.lesson_id = '599fba4f-4cee-5a88-9f9b-5ce32a445554' and g.title_ua = 'Що болить? Boli me…, bole me…' and g.cefr = 'A0' and g.status = 'PUBLISHED'$q$) = 1
  and pg_temp.n($q$select 1 from public.grammar_rules r join public.grammar_topics g on g.id = r.topic_id
                  where g.cefr = 'A0' and g.title_ua = 'Що болить? Boli me…, bole me…' and jsonb_array_length(r.examples) = 3$q$) = 3
  and pg_temp.n($q$select 1 from public.grammar_topics where cefr = 'A0' and title_ua = 'Що болить? Boli me…, bole me…'$q$) = 1,
  'нова тема граматики «Що болить?»: одна, 3 правила по 3 приклади, в уроці «Частини тіла»');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lexemes where source = 'claude_curriculum_a0_v4' and status = 'PUBLISHED' and cefr = 'A0'
  and normalized !~ '[čćđšž]' and normalized = lower(normalized) and lemma !~ '[Ѐ-ӿ]' and ukrainian_translation ~ '[Ѐ-ӿ]'
  and jsonb_array_length(examples) = 1 and lower(lemma) in ('jednokrevetna soba', 'dvokrevetna soba', 'sef', 'odsjesti', 'prenoćiti', 'lakat', 'prsa', 'stopalo', 'protiv bolova', 'ozlijeđen', 'onesvijestiti se', 'ukrasti', 'džeparoš', 'blokirati', 'zapisnik', 'provala', 'sumnjiv', 'odjednom', 'osobni podaci', 'mjesto rođenja', 'spol', 'muški', 'ženski', 'bračno stanje', 'e-pošta', 'tiskanim slovima', 'rubrika', 'ovjeriti', 'obvezno', 'privremeni boravak', 'uplatiti', 'osobno')$q$) = 32,
  '32 нових слів і виразів A0.10: без кирилиці в лемі, normalized без діакритики, переклад і приклад');
select pg_temp.ok((select ukrainian_translation from public.lexemes where lower(lemma) = 'nesreća' and status = 'PUBLISHED' order by created_at limit 1)
                  = 'нещастя; аварія, нещасний випадок'
  and (select ukrainian_translation from public.lexemes where lower(lemma) = 'prijava' and status = 'PUBLISHED' order by created_at limit 1)
                  = 'реєстрація; заява (в поліцію, установу)'
  and pg_temp.n($q$select 1 from public.content_versions v join public.lexemes x on x.id = v.entity_id
                  where v.entity_type = 'lexeme' and lower(x.lemma) in ('nesreća', 'prijava')
                    and v.payload->>'ukrainian_translation' in ('нещастя', 'реєстрація / заява / донос')$q$) >= 2,
  'переклади nesreća («аварія») і prijava (без «донос») виправлено, стара версія — у content_versions');

-- ---------------------------------------------------------------- стара версія збережена
select pg_temp.ok(pg_temp.n($q$select 1 from (values ('edbae9ca-c4f4-575d-b876-d50b0a1fd9b5'::uuid), ('fbc71f82-e715-5bab-a990-b8542fb0fe01'::uuid), ('d2689a70-cb73-515f-9d81-6bb0f0fc1cff'::uuid), ('b095637e-0644-507e-8f3d-d323483dd3e4'::uuid), ('19df3241-90f3-5450-94ac-642d79fb2869'::uuid)) v(lid)
  where not exists (select 1 from public.content_versions cv where cv.entity_type = 'lesson' and cv.entity_id = v.lid
                    and cv.change_reason like 'curriculum_a0_v4: урок перебудовано%' and jsonb_array_length(cv.payload->'items') > 0)$q$) = 0,
  'стара версія кожного перебудованого уроку — у content_versions');
select pg_temp.ok(pg_temp.n($q$select 1 from public.conversations c
  where c.id in (select jsonb_array_elements_text(v.payload->'conversations')::uuid from public.content_versions v
                 where v.change_reason like 'curriculum_a0_v4%' and v.entity_id in ('edbae9ca-c4f4-575d-b876-d50b0a1fd9b5', 'fbc71f82-e715-5bab-a990-b8542fb0fe01', 'd2689a70-cb73-515f-9d81-6bb0f0fc1cff', 'b095637e-0644-507e-8f3d-d323483dd3e4', '19df3241-90f3-5450-94ac-642d79fb2869'))
    and c.status <> 'DEPRECATED'$q$) = 0, 'старі діалоги — DEPRECATED (не видалені)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.exercises e
  where e.id in (select b.item_id from backup.lesson_items_20261015 b where b.item_type = 'exercise' and b.lesson_id in ('edbae9ca-c4f4-575d-b876-d50b0a1fd9b5', 'fbc71f82-e715-5bab-a990-b8542fb0fe01', 'd2689a70-cb73-515f-9d81-6bb0f0fc1cff', 'b095637e-0644-507e-8f3d-d323483dd3e4', '19df3241-90f3-5450-94ac-642d79fb2869'))
    and e.status <> 'DEPRECATED'$q$) = 0, 'старі вправи — DEPRECATED (не видалені)');

-- ---------------------------------------------------------------- видимість
set local role anon;
select pg_temp.ok(pg_temp.n($q$select 1 from public.conversations where source = 'claude_curriculum_a0_v4' and lesson_id in (select lid from pg_temp.m10())$q$) = 14,
  'гість бачить 14 нових діалогів A0.10');
select pg_temp.ok(pg_temp.n($q$select 1 from public.lessons where id in ('599fba4f-4cee-5a88-9f9b-5ce32a445554', '48f26e9d-96c5-5189-8ec6-db1f9d58e200')$q$) = 2, 'гість бачить нові уроки');
reset role;

select 'ALL TESTS PASSED' as result;
rollback;
