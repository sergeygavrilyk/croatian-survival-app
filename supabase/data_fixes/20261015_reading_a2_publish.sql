-- =====================================================================
-- Опублікувати тексти для читання A2 (reading_a2_v1) · 2026-10-15
-- Запускає ВЛАСНИК, коли вирішить: одразу як бету (як A0/A1) або після перевірки носієм.
-- Що змінює: статус 20 текстів A2 DRAFT → PUBLISHED (їх побачать усі користувачі в «Практиці» → «Читання» → A2).
-- Запис рішення — у content_reviews. Повторний запуск безпечний.
-- =====================================================================

do $publish$
declare v_count int;
begin
  with changed as (
    update public.reading_texts set status = 'PUBLISHED'
     where source = 'claude_reading_a2_v1' and status in ('DRAFT', 'AI_GENERATED', 'AUTO_VALIDATED', 'NEEDS_REVIEW', 'APPROVED')
    returning id
  ), logged as (
    insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
    select 'reading_text', c.id, 'DRAFT', 'PUBLISHED', 'approved', 'human', '[]'::jsonb, 'Рішення власника: тексти для читання A2 (reading_a2_v1) — публікувати як бету. Потрібна перевірка носієм.'
    from changed c
    returning 1
  )
  select count(*) into v_count from logged;
  raise notice 'Опубліковано текстів A2: % (усього опублікованих A2: %)', v_count,
    (select count(*) from public.reading_texts where source = 'claude_reading_a2_v1' and status = 'PUBLISHED');
end
$publish$;
