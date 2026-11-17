-- =====================================================================
-- Пакет 20261117_pelena_a1_5.sql — урок A1 5 «З дитиною вдома»: лема pelena, а не pelene
-- (рішення власника 2026-11-17: «Лишити pelena»).
--
-- Чому: робоча база з 2026-10-26 має в уроці A1 5 слово pelena («підгузок», множина pelene — у forms),
-- а репозиторій (20261026_curriculum_a1_v3_m01.sql) і тест curriculum_a1_v3 — окреме слово pelene
-- (форма множини як лема). «Apply SQL» 2026-11-17 показав це розходження. Вирівнюємо до робочої бази.
--
-- Що робить (у робочій базі — лише крок 4; кроки 1–3 вирівнюють копії бази для тестів і CI):
--   1. немає лексеми pelena — додає її (той самий id, що в робочій базі);
--   2. в уроці A1 5 слово pelene → pelena на тому самому місці (стара версія рядка — backup.lesson_items_20261117);
--   3. вправа «Як хорватською…» — на pelena (стара версія — content_versions);
--   4. pelene — DEPRECATED, якщо її немає в жодному уроці й опублікованій вправі (стара версія — content_versions,
--      запис — content_reviews). Прогресу учнів на pelene в робочій базі немає.
-- Повторний запуск нічого не змінює.
-- Тест: supabase/tests/pelena_a1_5.test.sql → «ALL TESTS PASSED».
-- =====================================================================
do $pelena$
declare
  c_lesson   constant uuid := 'd43d6c65-1ce3-5c72-9ecd-cce2ed200fc2';
  c_pelena   constant uuid := 'fb9bb831-7279-4185-94e7-012eefef7d9d';
  c_exercise constant uuid := '1d5daffe-3020-54c1-84fa-24022a8e56c9';
  c_note     constant text := 'pelena_a1_5 2026-11-17: в уроці A1 5 — лема pelena (однина, множина pelene у forms), pelene — форма слова; рішення власника 2026-11-17 «Лишити pelena»';
  v_pelena uuid;
  v_pelene uuid;
begin
  if not exists (select 1 from public.lessons where id = c_lesson and level_code = 'A1' and title_ua like 'Урок 5: З дитиною вдома%') then
    raise exception 'Немає уроку A1 5 «З дитиною вдома» (%)', c_lesson;
  end if;

  -- 1. лексема pelena
  select id into v_pelena from public.lexemes where lemma = 'pelena' order by (id = c_pelena) desc, created_at limit 1;
  if v_pelena is null then
    insert into public.lexemes (id, lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, forms, examples,
                                phrases, collocations, vocabulary_type, register, regionality, usage_tags, status, source, version, published_at)
    values (c_pelena, 'pelena', 'pelena', 'hr', 'noun', 'A1', 'підгузок', '{"gender": "f", "plural": "pelene"}'::jsonb,
            '["Trebamo kupiti pelene i maramice."]'::jsonb, '[]'::jsonb, '[]'::jsonb, 'core', 'standard', 'general', '{}',
            'PUBLISHED', 'claude_curriculum_a1_v3', 1, now());
    v_pelena := c_pelena;
  end if;
  select id into v_pelene from public.lexemes where lemma = 'pelene' order by created_at limit 1;

  -- 2. слово уроку: pelene → pelena на тому самому місці
  if v_pelene is not null and exists (select 1 from public.lesson_items where lesson_id = c_lesson and item_type = 'lexeme' and item_id = v_pelene) then
    create table if not exists backup.lesson_items_20261117 as table public.lesson_items with no data;
    insert into backup.lesson_items_20261117
      select * from public.lesson_items where lesson_id = c_lesson and item_type = 'lexeme' and item_id = v_pelene;
    update public.lesson_items set item_id = v_pelena
      where lesson_id = c_lesson and item_type = 'lexeme' and item_id = v_pelene;
  end if;

  -- 3. вправа на слово
  if exists (select 1 from public.exercises where id = c_exercise
             and (lexeme_id, correct_answer, question_text, options) is distinct from
                 (v_pelena, 'pelena', 'Як хорватською «підгузок»?', '["ljuljačka", "plakati", "pelena", "pijesak"]'::jsonb)) then
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    select 'exercise', e.id, coalesce((select max(version) from public.content_versions where entity_type = 'exercise' and entity_id = e.id), 0) + 1,
           to_jsonb(e), c_note || ' — стара версія'
    from public.exercises e where e.id = c_exercise;
    update public.exercises set lexeme_id = v_pelena, correct_answer = 'pelena', question_text = 'Як хорватською «підгузок»?',
           options = '["ljuljačka", "plakati", "pelena", "pijesak"]'::jsonb
      where id = c_exercise;
  end if;

  -- 4. pelene — форма слова → DEPRECATED, якщо ніде не вживається
  if v_pelene is not null
     and exists (select 1 from public.lexemes where id = v_pelene and status <> 'DEPRECATED')
     and not exists (select 1 from public.lesson_items where item_id = v_pelene)
     and not exists (select 1 from public.exercises where lexeme_id = v_pelene and status = 'PUBLISHED') then
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    select 'lexeme', x.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = x.id), 0) + 1,
           to_jsonb(x), c_note || ' — стара версія'
    from public.lexemes x where x.id = v_pelene;
    update public.lexemes set status = 'DEPRECATED', version = version + 1, updated_at = now() where id = v_pelene;
    insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
    values ('lexeme', v_pelene, 'PUBLISHED', 'DEPRECATED', 'approved', 'ai',
            jsonb_build_array(jsonb_build_object('lemma', 'pelene', 'reason', 'форма множини слова pelena', 'replacement', 'pelena')), c_note);
  end if;

  raise notice 'pelena_a1_5: pelena — %, pelene — %', v_pelena, coalesce(v_pelene::text, 'немає');
end $pelena$;

-- ---------------------------------------------------------------- самоперевірка
do $check$
declare n int;
begin
  select count(*) into n from public.lesson_items li join public.lexemes x on x.id = li.item_id
    where li.lesson_id = 'd43d6c65-1ce3-5c72-9ecd-cce2ed200fc2' and li.item_type = 'lexeme' and x.lemma = 'pelena' and x.status = 'PUBLISHED';
  if n <> 1 then raise exception 'В уроці A1 5 очікувано одне слово pelena, є %', n; end if;
  select count(*) into n from public.lesson_items li join public.lexemes x on x.id = li.item_id where x.lemma = 'pelene';
  if n <> 0 then raise exception 'pelene ще в % уроках', n; end if;
  select count(*) into n from public.lexemes where lemma = 'pelene' and status <> 'DEPRECATED';
  if n <> 0 then raise exception 'pelene не DEPRECATED (%)', n; end if;
  select count(*) into n from public.exercises e join public.lexemes x on x.id = e.lexeme_id
    where e.id = '1d5daffe-3020-54c1-84fa-24022a8e56c9' and x.lemma = 'pelena' and e.correct_answer = 'pelena' and e.options ? 'pelena';
  if n <> 1 then raise exception 'Вправа «Як хорватською «підгузок»?» не на pelena'; end if;
  raise notice 'Готово: 20261117_pelena_a1_5.sql — в уроці A1 5 pelena, pelene — DEPRECATED';
end $check$;
