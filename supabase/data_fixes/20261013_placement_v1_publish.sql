-- =====================================================================
-- Тест рівня v1: правка носія мови + публікація · 2026-10-13
--
--   * Носій перевірив питання із середньою впевненістю (15, 16, 18):
--       15 — «pomaknuti sastanak na sutra» → «za sutra» (так природніше);
--       16 — «Unatoč kiši, utakmica je održana prema planu.» — правильно;
--       18 — «postupio bih» — правильно.
--   * Після правки тест і всі 24 питання → PUBLISHED: новий користувач проходить
--     тест рівня в онбордингу. Рішення власника; звіт — content/reviews/2026-10-12_placement_v1.md.
--   * Ідемпотентно: повторний запуск нічого не змінює. Дані не видаляються.
-- =====================================================================
begin;

-- 1. Питання 15: «na sutra» → «za sutra» (лише якщо ще стара версія)
update public.assessment_items i
set options = (
      select jsonb_agg(
               case when v = 'Bismo li mogli pomaknuti sastanak na sutra?'
                    then 'Bismo li mogli pomaknuti sastanak za sutra?' else v end
               order by ord)
      from jsonb_array_elements_text(i.options) with ordinality as t(v, ord)
    ),
    version = i.version + 1,
    updated_at = now()
from public.assessments a
where a.id = i.assessment_id
  and a.slug = 'placement-v1'
  and i.order_index = 15
  and i.options ? 'Bismo li mogli pomaknuti sastanak na sutra?';

-- 2. Публікація питань і самого тесту
update public.assessment_items i
set status = 'PUBLISHED', updated_at = now()
from public.assessments a
where a.id = i.assessment_id and a.slug = 'placement-v1' and i.status = 'NEEDS_REVIEW';

update public.assessments
set status = 'PUBLISHED', updated_at = now()
where slug = 'placement-v1' and status <> 'PUBLISHED';

-- 3. Самоперевірка: якщо щось не так — усе відкочується
do $$
declare
  v_published int;
  v_q15 jsonb;
  v_q15_correct int;
begin
  select count(*) into v_published
  from public.assessment_items i join public.assessments a on a.id = i.assessment_id
  where a.slug = 'placement-v1' and a.status = 'PUBLISHED' and i.status = 'PUBLISHED';
  select i.options, i.correct_index into v_q15, v_q15_correct
  from public.assessment_items i join public.assessments a on a.id = i.assessment_id
  where a.slug = 'placement-v1' and i.order_index = 15;

  if v_published <> 24 then raise exception 'Опубліковано питань %, очікувалось 24', v_published; end if;
  if v_q15 ->> v_q15_correct <> 'Bismo li mogli pomaknuti sastanak za sutra?' then
    raise exception 'Питання 15: правильна відповідь «%», очікувалось «…za sutra?»', v_q15 ->> v_q15_correct;
  end if;
  raise notice 'Готово: тест рівня опубліковано, 24 питання';
end $$;

commit;
