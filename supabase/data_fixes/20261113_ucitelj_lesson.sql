-- =====================================================================
-- «učitelj» в уроці A1 99 «Школа: класи, уроки, розклад» · 2026-11-13
-- Борг з docs/PROJECT_STATE.md: «učitelj — досі не в уроках (точково — у «Школа: класи, уроки, розклад»)».
--
--   1. Слово učitelj (A1): переклад «вчитель» → «учитель (в основній школі)», щоб відрізнялось від
--      nastavnik («учитель у старших класах») і profesor; пояснення; приклад-речення замість
--      неповного «Moj učitelj hrvatskog jezika.»; cefr — A1 (рівень уроку, де слово вперше вчать; у робочій базі вже A1). Стара версія — у content_versions, запис — у content_reviews.
--   2. Урок A1 99: učitelj стає 21-м словом одразу після učiteljica (інші елементи уроку зсуваються на 1).
--      Правило A1: до 25 слів (рішення 2026-10-21) — було 20, стане 21.
--   Повторний запуск нічого не змінює.
-- Після нього: тест supabase/tests/ucitelj_lesson.test.sql → «ALL TESTS PASSED».
-- Очікуване повідомлення: «Готово: učitelj в уроці A1 99 (слів у уроці — 21), слово оновлено — 1 / додано в урок — 1»
-- (повторний запуск — «… — 0 / … — 0»).
-- =====================================================================

begin;

do $fix$
declare
  c_lesson constant uuid := '7c8e16ec-03f3-55dd-a61a-fb59c2401692';
  c_tr     constant text := 'учитель (в основній школі)';
  c_expl   constant text := 'Učitelj, učiteljica — учитель в основній школі (1–8 клас). У середній школі зазвичай кажуть profesor, profesorica; nastavnik — старіше слово для вчителя-предметника.';
  c_ex     constant jsonb := '["Moj sin ima dobrog učitelja.", "Učitelj nam je zadao zadaću za ponedjeljak."]'::jsonb;
  c_note   constant text := 'ucitelj_lesson 2026-11-13: učitelj у слова уроку A1 99 «Школа: класи, уроки, розклад» (борг PROJECT_STATE); переклад відрізняє від nastavnik; приклад — повне речення. Бета, потрібна перевірка носієм.';
  x public.lexemes%rowtype;
  v_pos int;
  v_words int;
  v_upd int := 0;
  v_added int := 0;
begin
  if not exists (select 1 from public.lessons where id = c_lesson and level_code = 'A1' and title_ua like '%Школа: класи, уроки, розклад%') then
    raise exception 'Немає уроку A1 «Школа: класи, уроки, розклад» (%)', c_lesson;
  end if;
  select * into x from public.lexemes where lower(lemma) = 'učitelj' and status = 'PUBLISHED';
  if x.id is null then
    raise exception 'Немає опублікованого слова učitelj';
  end if;

  -- 1. Слово
  if x.ukrainian_translation is distinct from c_tr or x.examples is distinct from c_ex or x.ukrainian_explanation is distinct from c_expl
     or x.cefr is distinct from 'A1' then
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', x.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = x.id), 0) + 1,
            to_jsonb(x), c_note);
    update public.lexemes
       set ukrainian_translation = c_tr, ukrainian_explanation = c_expl, examples = c_ex, cefr = 'A1',
           version = coalesce(version, 1) + 1, updated_at = now()
     where id = x.id;
    insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
    values ('lexeme', x.id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, c_note || ' Було: ' || x.ukrainian_translation || '.');
    v_upd := 1;
  end if;

  -- 2. Урок: одразу після učiteljica
  if not exists (select 1 from public.lesson_items where lesson_id = c_lesson and item_type = 'lexeme' and item_id = x.id) then
    select li.order_index + 1 into v_pos
      from public.lesson_items li join public.lexemes l on l.id = li.item_id
     where li.lesson_id = c_lesson and li.item_type = 'lexeme' and lower(l.lemma) = 'učiteljica';
    if v_pos is null then
      raise exception 'В уроці A1 99 немає слова učiteljica';
    end if;
    -- зсув у два кроки, щоб не зачепити unique (lesson_id, order_index)
    update public.lesson_items set order_index = order_index + 1000 where lesson_id = c_lesson and order_index >= v_pos;
    update public.lesson_items set order_index = order_index - 999 where lesson_id = c_lesson and order_index >= v_pos + 1000;
    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, required, target_skill)
    values (c_lesson, 'lexeme', x.id, v_pos, true, 'vocabulary');
    v_added := 1;
  end if;

  -- Самоперевірка
  select count(*) into v_words from public.lesson_items where lesson_id = c_lesson and item_type = 'lexeme';
  if v_words not between 20 and 25 then
    raise exception 'В уроці A1 99 слів %, очікувалось 20–25', v_words;
  end if;
  if (select count(*) from public.lesson_items where lesson_id = c_lesson and item_type = 'lexeme' and item_id = x.id) <> 1 then
    raise exception 'učitelj не в уроці A1 99';
  end if;
  raise notice 'Готово: učitelj в уроці A1 99 (слів у уроці — %), слово оновлено — % / додано в урок — %', v_words, v_upd, v_added;
end $fix$;

commit;
