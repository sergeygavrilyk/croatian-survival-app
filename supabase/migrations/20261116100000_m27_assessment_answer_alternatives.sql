-- =====================================================================
-- M27 · Перевірки рівня: «Складіть» приймає кілька правильних порядків слів · 2026-11-16
-- Рішення власника 2026-11-15 (пункт 5 плану): інші правильні порядки — у новій колонці, не в answer_text.
--
--   * assessment_items.answer_alternatives — інші правильні відповіді «Складіть» (sentence_builder):
--     ті самі плитки в іншому порядку («Sutra idem u Split.» — «U Split idem sutra.»).
--     answer_text лишається головною відповіддю (її показує розбір).
--   * Лише додає колонку з порожнім масивом за замовчуванням: наявні завдання працюють як були.
--   * Обмеження: альтернативи — лише для «Складіть», до 6, латиницею, без порожніх рядків.
--   * Повторний запуск безпечний. RLS assessment_items не змінюється.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника.
-- =====================================================================

alter table public.assessment_items add column if not exists answer_alternatives text[] not null default '{}';

do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'assessment_items_alternatives_check'
                 and conrelid = 'public.assessment_items'::regclass) then
    alter table public.assessment_items add constraint assessment_items_alternatives_check check (
      cardinality(answer_alternatives) <= 6
      and (item_type = 'sentence_builder' or cardinality(answer_alternatives) = 0)
      and array_to_string(answer_alternatives, '|') !~ '[Ѐ-ӿ]'
      and array_position(answer_alternatives, '') is null
      and array_position(answer_alternatives, null) is null);
  end if;
end $$;

comment on column public.assessment_items.answer_alternatives is
  'Інші правильні порядки слів для «Складіть» (sentence_builder): ті самі плитки, що й answer_text; перевіряє сервер (lib/assessment.ts)';
