-- =====================================================================
-- Виправлення пояснення до «učitelj» · 2026-11-13 (після звірки PR #30 зі skills croatian-content-review / content-sql-pack)
-- Пакет 20261113_ucitelj_lesson.sql уже запущено (ops.sql_journal) — його не змінюємо, виправляємо цим файлом.
--
--   Було:  «… У середній школі зазвичай кажуть profesor, profesorica; nastavnik — старіше слово для вчителя-предметника.»
--   Стало: «… і в молодших, і в старших класах. У середній школі офіційно кажуть nastavnik, а учні — profesor, profesorica.»
--   Причина: положення про кваліфікацію називає učitelj і вчителів-предметників основної школи, закон розрізняє
--   «učitelji, nastavnici» — «старіше слово» неточно. Потрібна перевірка носієм (content/reviews/2026-11-13_interference_v2.md).
--   Стара версія — у content_versions, запис — у content_reviews. Повторний запуск нічого не змінює.
-- Після нього: тест supabase/tests/ucitelj_explanation_fix.test.sql → «ALL TESTS PASSED».
-- Очікуване повідомлення: «Готово: пояснення до učitelj виправлено — 1» (повторно — «— 0»).
-- =====================================================================

begin;

do $fix$
declare
  c_expl constant text := 'Učitelj, učiteljica — учитель в основній школі (osnovna škola, 1–8 класи), і в молодших, і в старших класах. У середній школі офіційно кажуть nastavnik, а учні — profesor, profesorica.';
  c_note constant text := 'ucitelj_explanation_fix 2026-11-13: пояснення до učitelj — nastavnik у середній школі, а не «старіше слово для вчителя-предметника» (звірка зі skill croatian-content-review). Бета, потрібна перевірка носієм.';
  x public.lexemes%rowtype;
  v_upd int := 0;
begin
  select * into x from public.lexemes where lower(lemma) = 'učitelj' and status = 'PUBLISHED';
  if x.id is null then
    raise exception 'Немає опублікованого слова učitelj';
  end if;

  if x.ukrainian_explanation is distinct from c_expl then
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', x.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = x.id), 0) + 1,
            to_jsonb(x), c_note);
    update public.lexemes
       set ukrainian_explanation = c_expl, version = coalesce(version, 1) + 1, updated_at = now()
     where id = x.id;
    insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
    values ('lexeme', x.id, x.status, x.status, 'auto_passed', 'ai', '[]'::jsonb, c_note);
    v_upd := 1;
  end if;

  -- Самоперевірка
  if (select ukrainian_explanation from public.lexemes where id = x.id) is distinct from c_expl then
    raise exception 'Пояснення до učitelj не оновлено';
  end if;
  raise notice 'Готово: пояснення до učitelj виправлено — %', v_upd;
end $fix$;

commit;
