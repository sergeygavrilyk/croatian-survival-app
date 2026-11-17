-- =====================================================================
-- Тести: перевірки рівня A0 / A1 за схемою 2026-11-07, «Складіть» з кількома порядками слів (M27), skill_progress · 2026-11-16
-- Запускати ПІСЛЯ: 20261116100000_m27_assessment_answer_alternatives.sql, 20261116_assessment_sentence_orders_a2.sql,
--   20261116_assessments_a0_v5.sql, 20261116_assessments_a1_v5_part1.sql, 20261116_assessments_a1_v5_part2.sql.
-- БЕЗПЕЧНО для робочої бази: одна транзакція, у кінці ROLLBACK.
-- Успіх: «ALL TESTS PASSED».
-- =====================================================================
begin;

create or replace function pg_temp.raises(q text) returns boolean language plpgsql as $$
begin
  execute q;
  return false;
exception when others then
  return true;
end $$;

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

-- Опубліковані завдання перевірок A0 / A1 з модулем уроку-джерела
create temp view v5 as
select a.slug, a.kind, a.cefr as test_cefr, a.module_id as test_module, i.*, m.order_index as src_module, m.id as src_module_id,
       l.status as lesson_status, m.level_code as lesson_level
from public.assessment_items i
join public.assessments a on a.id = i.assessment_id
left join public.lessons l on l.id = i.lesson_id
left join public.units u on u.id = l.unit_id
left join public.modules m on m.id = u.module_id
where a.cefr in ('A0', 'A1') and a.status = 'PUBLISHED' and i.status = 'PUBLISHED';

-- ---------------------------------------------------------------- M27: answer_alternatives
select pg_temp.ok(exists (select 1 from information_schema.columns where table_schema = 'public' and table_name = 'assessment_items'
  and column_name = 'answer_alternatives' and is_nullable = 'NO'), 'M27: колонка answer_alternatives (text[], не null)');
select pg_temp.ok(pg_temp.raises($q$update public.assessment_items set answer_alternatives = array['Hvala.']
  where id = (select id from public.assessment_items where item_type = 'type_answer' and status = 'PUBLISHED' limit 1)$q$),
  'інші порядки — лише для «Складіть»');
select pg_temp.ok(pg_temp.raises($q$update public.assessment_items set answer_alternatives = array['Привіт']
  where id = (select id from public.assessment_items where item_type = 'sentence_builder' and status = 'PUBLISHED' limit 1)$q$),
  'інші порядки — без кирилиці');
select pg_temp.ok(pg_temp.raises($q$update public.assessment_items set answer_alternatives = array['']
  where id = (select id from public.assessment_items where item_type = 'sentence_builder' and status = 'PUBLISHED' limit 1)$q$),
  'інші порядки — без порожніх рядків');
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessment_items i, unnest(i.answer_alternatives) alt
  where (select string_agg(w, ' ' order by w) from regexp_split_to_table(lower(regexp_replace(alt, '[^[:alnum:]]+', ' ', 'g')), '\s+') w where w <> '')
     <> (select string_agg(w, ' ' order by w) from regexp_split_to_table(lower(regexp_replace(i.answer_text, '[^[:alnum:]]+', ' ', 'g')), '\s+') w where w <> '')
     or lower(alt) = lower(i.answer_text)$q$) = 0,
  'кожен інший порядок — ті самі слова (плитки), що й головна відповідь, і не повтор її');
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id
  where a.cefr = 'A2' and i.status = 'PUBLISHED' and cardinality(i.answer_alternatives) > 0$q$) = 17
  and (select sum(cardinality(i.answer_alternatives)) from public.assessment_items i join public.assessments a on a.id = i.assessment_id
       where a.cefr = 'A2' and i.status = 'PUBLISHED') = 19,
  'A2: 17 з 24 завдань «Складіть» мають інші порядки (разом 19)');
select pg_temp.ok(pg_temp.n($q$select 1 from v5 where item_type = 'sentence_builder' and cardinality(answer_alternatives) > 0$q$) = 26
  and pg_temp.n($q$select 1 from v5 where item_type = 'sentence_builder'$q$) = 59,
  'A0 / A1: 26 з 59 завдань «Складіть» мають інші порядки (2026-11-17: нові a0-m05, a0-m06; PR 2б — нові a0-m09, a0-m11, a0-final; PR 3 — нові a1-m06, m08, m11, m12, a1-final)');

-- ---------------------------------------------------------------- склад за схемою 2026-11-07
select pg_temp.ok(pg_temp.n($q$select 1 from v5 where source <> 'claude_assessment_v5'$q$) = 0
  and pg_temp.n($q$select 1 from v5$q$) = 534,
  'усі опубліковані завдання A0 / A1 — нові (v5): A0 — 232 (2026-11-17: + модуль A0.6; a0-m11 — 8 уроків, 16 завдань), A1 — 302 (PR 3: a1-m11 — 8 уроків, 16; a1-m12 — 7 уроків, 14)');
select pg_temp.ok(pg_temp.n($q$select slug from v5 group by slug, kind, test_module
  having count(*) <> case kind when 'module' then greatest(12, least(20, 2 * (select count(*) from public.lessons l join public.units u on u.id = l.unit_id
                                                                                where u.module_id = test_module and l.status = 'PUBLISHED')))
                               when 'mid' then 30 else 48 end$q$) = 0
  and pg_temp.n($q$select distinct slug from v5$q$) = 28,
  '28 тестів (A0 — 13, A1 — 15): модуль — 2 завдання на урок (12–20), середина — 30, фінал — 48');
select pg_temp.ok(pg_temp.n($q$select slug from v5 group by slug having min(order_index) <> 1 or max(order_index) <> count(*)$q$) = 0,
  'місця завдань 1…N без пропусків');
select pg_temp.ok(pg_temp.n($q$select slug from v5 where kind <> 'module' group by slug, kind
  having count(*) filter (where area = 'understand') <> case kind when 'mid' then 8 else 13 end
      or count(*) filter (where area = 'interact') <> case kind when 'mid' then 7 else 11 end
      or count(*) filter (where area = 'mediate') <> case kind when 'mid' then 7 else 11 end
      or count(*) filter (where area = 'produce') <> case kind when 'mid' then 8 else 13 end$q$) = 0,
  'середина: 8 / 7 / 7 / 8, фінал: 13 / 11 / 11 / 13 завдань на 4 навички §60');
select pg_temp.ok(pg_temp.n($q$select slug from v5 where kind = 'module' group by slug
  having count(distinct area) <> 4 or count(*) filter (where item_type = 'speaking') < 1$q$) = 0,
  'кожен тест модуля — усі 4 навички і «скажіть уголос»');

-- ---------------------------------------------------------------- джерела
select pg_temp.ok(pg_temp.n($q$select 1 from v5 where skill <> 'reading' and (lesson_id is null or lesson_status <> 'PUBLISHED' or lesson_level <> test_cefr)$q$) = 0,
  'кожне завдання, крім читання, — з опублікованого уроку свого рівня');
select pg_temp.ok(pg_temp.n($q$select 1 from v5 where kind = 'module' and skill <> 'reading' and src_module_id <> test_module$q$) = 0,
  'тест модуля — лише з уроків цього модуля');
select pg_temp.ok(pg_temp.n($q$select 1 from v5 where kind = 'mid' and src_module > case test_cefr when 'A1' then 6 else 5 end$q$) = 0,
  'середина: A0 — модулі 1–5, A1 — 1–6');
select pg_temp.ok(pg_temp.n($q$select slug, src_module from v5 where kind = 'final' and src_module is not null group by 1, 2$q$) >= 21,
  'фінал: завдання з уроків майже всіх модулів (A0 — 10, A1 — 13; читання — без уроку)');
select pg_temp.ok(pg_temp.n($q$select 1 from v5 x join v5 y on y.cefr = x.cefr and y.kind = 'module' and x.kind <> 'module'
  where coalesce(x.audio_hr, x.answer_text) is not null
    and lower(coalesce(x.audio_hr, x.answer_text)) in (lower(y.audio_hr), lower(y.answer_text), lower(y.prompt_hr))$q$) = 0,
  'репліки й відповіді середини та фіналу не повторюють перевірок модулів');

-- ---------------------------------------------------------------- якість
select pg_temp.ok(pg_temp.n($q$select 1 from v5 where coalesce(audio_hr, '') || coalesce(answer_text, '') || coalesce(passage_hr, '')
  || array_to_string(answer_alternatives, ' ') ~ '[Ѐ-ӿ]'$q$) = 0, 'хорватське без кирилиці');
select pg_temp.ok(pg_temp.n($q$select 1 from v5 where prompt_ua !~ '[А-Яа-яІіЇїЄєҐґ]' or (prompt_ua || coalesce(explanation_ua, '')) ~* 'placeholder|todo|osnovni_pojam|базовий термін'$q$) = 0,
  'питання українською, без заглушок');
select pg_temp.ok(pg_temp.n($q$select 1 from v5 where item_type = 'sentence_builder'
  and (select string_agg(o, ' ' order by o) from jsonb_array_elements_text(options) o)
      <> (select string_agg(w, ' ' order by w) from regexp_split_to_table(trim(answer_text), '\s+') w)$q$) = 0,
  '«Складіть»: плитки — рівно слова головної відповіді');

-- ---------------------------------------------------------------- старе не видалено
select pg_temp.ok(pg_temp.n($q$select 1 from public.content_versions where entity_type = 'assessment'
  and change_reason like 'assessment_v5:%' and jsonb_array_length(payload->'items') > 0$q$) = 27,
  'стара версія всіх 27 тестів A0 / A1 — у content_versions');
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id
  where a.cefr in ('A0', 'A1') and i.status = 'DEPRECATED' and i.source = 'claude_assessment_v1'
    and exists (select 1 from public.content_versions v where v.entity_id = a.id and v.change_reason like 'assessment_v5:%'
                and v.payload->'items' @> jsonb_build_array(jsonb_build_object('id', i.id)))$q$) = 330,
  'завдання, опубліковані до v5 (A0 — 150, A1 — 180), — DEPRECATED, не видалені');
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessments a where a.cefr in ('A0', 'A1')
  and not exists (select 1 from public.content_reviews r where r.entity_id = a.id and r.notes like 'Бета: перевірки рівня A_ за схемою 2026-11-07%')$q$) = 0,
  'запис у журналі перевірки для кожного тесту');

-- ---------------------------------------------------------------- гість бачить лише опубліковане
set local role anon;
select set_config('request.jwt.claims', '{"role":"anon"}', true);
select pg_temp.ok(pg_temp.n($q$select 1 from public.assessment_items i join public.assessments a on a.id = i.assessment_id
  where a.cefr in ('A0', 'A1')$q$) = 534, 'гість бачить 534 опублікованих завдання A0 / A1, старих — ні');
reset role;

-- ---------------------------------------------------------------- skill_progress: лише свої рядки
insert into auth.users (id, email) values
  ('a2700000-0000-4000-8000-0000000000a1', 'm27-user-a@example.invalid'),
  ('b2700000-0000-4000-8000-0000000000b1', 'm27-user-b@example.invalid');
insert into public.skill_progress (user_id, skill, level_estimate, xp_or_score)
values ('b2700000-0000-4000-8000-0000000000b1', 'listening', 'A1', 80);

set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"a2700000-0000-4000-8000-0000000000a1","role":"authenticated"}', true);
select pg_temp.ok(not pg_temp.raises($q$insert into public.skill_progress (user_id, skill, level_estimate, xp_or_score, updated_at)
  values ('a2700000-0000-4000-8000-0000000000a1', 'listening', null, 67, now())
  on conflict (user_id, skill) do update set xp_or_score = excluded.xp_or_score, updated_at = excluded.updated_at$q$),
  'користувач записує (upsert) свій стан навички');
select pg_temp.ok(not pg_temp.raises($q$insert into public.skill_progress (user_id, skill, level_estimate, xp_or_score, updated_at)
  values ('a2700000-0000-4000-8000-0000000000a1', 'listening', 'A0', 90, now())
  on conflict (user_id, skill) do update set xp_or_score = excluded.xp_or_score, level_estimate = excluded.level_estimate$q$),
  'повторний запис без помилки');
select pg_temp.ok((select xp_or_score from public.skill_progress where skill = 'listening') = 90,
  'повторний запис оновлює той самий рядок (user_id, skill)');
select pg_temp.ok(pg_temp.n($q$select 1 from public.skill_progress$q$) = 1, 'користувач бачить лише свій рядок');
select pg_temp.ok(pg_temp.raises($q$insert into public.skill_progress (user_id, skill, xp_or_score)
  values ('b2700000-0000-4000-8000-0000000000b1', 'reading', 50)$q$), 'чужий рядок записати не можна');
update public.skill_progress set xp_or_score = 0 where user_id = 'b2700000-0000-4000-8000-0000000000b1';
reset role;
select pg_temp.ok((select xp_or_score from public.skill_progress where user_id = 'b2700000-0000-4000-8000-0000000000b1') = 80,
  'чужий рядок змінити не можна');

select 'ALL TESTS PASSED' as result;
rollback;
