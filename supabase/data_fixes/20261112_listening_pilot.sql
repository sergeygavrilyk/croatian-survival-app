-- =====================================================================
-- Пілот: вправа «Прослухайте діалог чи оголошення» в уроці A1 «На острів: пором і море» · 2026-11-12
-- Згенеровано: python3 -B scripts/gen_listening_pilot_20261112.py (не редагуйте вручну).
-- Рішення власника 2026-11-12: вправа замінює одну з двох «Прослухайте і складіть фразу» (у уроці лишається 15 вправ);
--   до 3 прослуховувань і «Повільніше»; запитання українською; пізніше — і в кінець A1.
--
--   * Нова вправа listening_dialogue (оголошення в порту Спліт → Брач) стає на місце вправи
--     «Прослухайте і складіть фразу: Smijem li se kupati odmah?» (той самий порядок, обов'язкова).
--   * Стара вправа лишається в базі (не видаляємо); зв'язок «урок — вправа» — у backup.lesson_items_20261112.
--   * Потрібна міграція M23 (20261112100000_m23_listening_dialogue.sql). Повторний запуск нічого не змінює.
-- Після нього: тест supabase/tests/listening_dialogue.test.sql → «ALL TESTS PASSED».
-- Очікуване повідомлення: «Готово: вправа «Прослухайте оголошення в порту» в уроці 90 …».
-- =====================================================================

begin;

create schema if not exists backup;
create table if not exists backup.lesson_items_20261112 (like public.lesson_items including defaults);
do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'lesson_items_20261112_pkey') then
    alter table backup.lesson_items_20261112 add constraint lesson_items_20261112_pkey primary key (id);
  end if;
end $$;
revoke all on backup.lesson_items_20261112 from anon, authenticated;

do $pilot$
declare
  v_new boolean := false;
  v_swapped int := 0;
begin
  if not exists (select 1 from pg_constraint where conname = 'exercises_type_check' and conrelid = 'public.exercises'::regclass
                  and pg_get_constraintdef(oid) like '%listening_dialogue%') then
    raise exception 'Спершу запустіть міграцію M23 (supabase/migrations/20261112100000_m23_listening_dialogue.sql)';
  end if;
  if not exists (select 1 from public.lessons where id = '71ab330d-abbe-57a7-870e-77e59daf3627'::uuid and status = 'PUBLISHED') then
    raise exception 'Немає опублікованого уроку A1 «На острів: пором і море»';
  end if;

  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, task)
  values ('3898d412-dd1a-5ced-8f57-6cca8f274db2'::uuid, 'listening_dialogue', 'Прослухайте оголошення в порту', 'через буру; о 9:30; катамаран сьогодні не ходить', null, 'A1', 0, 'PUBLISHED',
          '{"kind": "announcement", "situation_ua": "Ви з Дашею в порту в Спліті, їдете на Брач автомобілем. Послухайте оголошення.", "script": [{"hr": "Poštovani putnici, trajekt za Supetar danas kasni trideset minuta jer je bura.", "ua": "Шановні пасажири, пором до Супетара сьогодні запізнюється на тридцять хвилин, бо дме бура."}, {"hr": "Trajekt polazi u devet i trideset, a ne u devet.", "ua": "Пором відправляється о дев’ятій тридцять, а не о дев’ятій."}, {"hr": "Ukrcaj automobila počinje u devet sati.", "ua": "Посадка автомобілів починається о дев’ятій."}, {"hr": "Katamaran za Bol danas ne vozi jer ima puno valova.", "ua": "Катамаран до Бола сьогодні не ходить, бо великі хвилі."}], "questions": [{"q_ua": "Чому пором запізнюється?", "options": ["через буру (сильний вітер)", "через ремонт у порту", "бо мало пасажирів"], "correct": 0, "answer_turn": 0}, {"q_ua": "О котрій відправляється пором?", "options": ["о 9:00", "о 9:30", "о 10:00"], "correct": 1, "answer_turn": 1}, {"q_ua": "Що з катамараном до Бола?", "options": ["відправляється о 10:00", "запізнюється на 30 хвилин", "сьогодні не ходить"], "correct": 2, "answer_turn": 3}], "max_plays": 3}'::jsonb)
  on conflict (id) do nothing;
  if found then
    v_new := true;
    insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
    values ('exercise', '3898d412-dd1a-5ced-8f57-6cca8f274db2'::uuid, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'listening_pilot 2026-11-12: «Прослухайте діалог чи оголошення» замість однієї «Прослухайте і складіть фразу» (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  end if;

  -- Заміна в уроці: та сама позиція й обов'язковість; спершу копія зв'язку
  insert into backup.lesson_items_20261112
  select li.* from public.lesson_items li
   where li.lesson_id = '71ab330d-abbe-57a7-870e-77e59daf3627'::uuid and li.item_type = 'exercise' and li.item_id = '640a2f04-03dd-503e-8ae9-8b347259a081'::uuid
  on conflict do nothing;
  update public.lesson_items li
     set item_id = '3898d412-dd1a-5ced-8f57-6cca8f274db2'::uuid, target_skill = 'listening'
   where li.lesson_id = '71ab330d-abbe-57a7-870e-77e59daf3627'::uuid and li.item_type = 'exercise' and li.item_id = '640a2f04-03dd-503e-8ae9-8b347259a081'::uuid
     and exists (select 1 from backup.lesson_items_20261112 b where b.id = li.id)
     and not exists (select 1 from public.lesson_items x where x.lesson_id = '71ab330d-abbe-57a7-870e-77e59daf3627'::uuid and x.item_id = '3898d412-dd1a-5ced-8f57-6cca8f274db2'::uuid);
  get diagnostics v_swapped = row_count;

  -- Самоперевірка: 15 обов'язкових вправ, одна «складіть фразу на слух» і одна «прослухайте оголошення»
  if (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
       where li.lesson_id = '71ab330d-abbe-57a7-870e-77e59daf3627'::uuid and li.item_type = 'exercise' and li.required and e.status = 'PUBLISHED') <> 15 then
    raise exception 'В уроці не 15 обов''язкових вправ';
  end if;
  if (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
       where li.lesson_id = '71ab330d-abbe-57a7-870e-77e59daf3627'::uuid and li.item_type = 'exercise' and e.exercise_type = 'listening_dialogue') <> 1
     or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
       where li.lesson_id = '71ab330d-abbe-57a7-870e-77e59daf3627'::uuid and li.item_type = 'exercise' and e.exercise_type = 'listening') <> 1 then
    raise exception 'В уроці має бути одна вправа listening і одна listening_dialogue';
  end if;
  raise notice 'Готово: вправа «Прослухайте оголошення в порту» в уроці 90 (нова: %, замінено зв''язків: %)', v_new, v_swapped;
end
$pilot$;

commit;
