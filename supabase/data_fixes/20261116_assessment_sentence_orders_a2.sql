-- =====================================================================
-- «Складіть» у перевірках A2: інші правильні порядки слів · 2026-11-16
-- Згенеровано: python3 -B scripts/gen_sentence_orders_20261116.py (не редагуйте вручну).
-- Рішення власника 2026-11-15: «Складіть» приймає кілька порядків слів; інші порядки — колонка answer_alternatives (M27).
--
--   * 17 з 24 завдань «Складіть» A2 отримують 19 інших порядків (у решти природний лише один порядок).
--   * Лише заповнює порожню answer_alternatives; тексти завдань і відповіді не змінюються.
--   * Стара версія — у content_versions, запис — у content_reviews. Повторний запуск нічого не змінює.
--   * Потрібна міграція 20261116100000_m27_assessment_answer_alternatives.sql. A0 / A1 — у пакетах 20261116_assessments_a*_v5*.sql.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника.
-- Очікуване повідомлення: «Готово: «Складіть» A2 — з іншими порядками 17 завдань».
-- =====================================================================

begin;

-- a2-final: 3
do $$
declare v_aid uuid; v_n int;
begin
  select id into v_aid from public.assessments where slug = 'a2-final' and cefr = 'A2';
  if v_aid is null then raise exception 'Немає тесту a2-final'; end if;
  if not exists (select 1 from public.assessment_items i
                  join (values
    ('a7cb2965-f22b-50c9-bd6e-e503d20f5e8d'::uuid, 'Tvoja poruka me jako obradovala.', array['Tvoja me poruka jako obradovala.', 'Jako me obradovala tvoja poruka.']::text[]),
    ('b56d7940-25be-568b-8ae7-b8ffa52af64b'::uuid, 'Zabranjeno je hraniti životinje.', array['Hraniti životinje je zabranjeno.']::text[]),
    ('cf3d9e63-ec26-5d1c-9e16-3b41420fb5ce'::uuid, 'Na sljedećem izlazu skrenite desno.', array['Skrenite desno na sljedećem izlazu.']::text[])
                  ) d(id, answer, alts) on d.id = i.id
                  where i.answer_alternatives = '{}') then return; end if;  -- уже заповнено
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
         jsonb_build_object('items', (select jsonb_agg(to_jsonb(i) order by i.order_index) from public.assessment_items i
                                       where i.assessment_id = v_aid and i.status = 'PUBLISHED' and i.item_type = 'sentence_builder')),
         'sentence_orders_20261116: до «Складіть» додано інші правильні порядки слів — стара версія завдань';
  update public.assessment_items i set answer_alternatives = d.alts
    from (values
    ('a7cb2965-f22b-50c9-bd6e-e503d20f5e8d'::uuid, 'Tvoja poruka me jako obradovala.', array['Tvoja me poruka jako obradovala.', 'Jako me obradovala tvoja poruka.']::text[]),
    ('b56d7940-25be-568b-8ae7-b8ffa52af64b'::uuid, 'Zabranjeno je hraniti životinje.', array['Hraniti životinje je zabranjeno.']::text[]),
    ('cf3d9e63-ec26-5d1c-9e16-3b41420fb5ce'::uuid, 'Na sljedećem izlazu skrenite desno.', array['Skrenite desno na sljedećem izlazu.']::text[])
    ) d(id, answer, alts)
   where i.id = d.id and i.assessment_id = v_aid and i.item_type = 'sentence_builder' and i.status = 'PUBLISHED'
     and i.answer_text = d.answer and i.answer_alternatives = '{}';
  get diagnostics v_n = row_count;
  if v_n <> 3 then raise exception 'Тест a2-final: оновлено % завдань «Складіть», очікувалось 3 — звірте базу', v_n; end if;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: «Складіть» приймає інші правильні порядки слів (answer_alternatives, M27; рішення власника 2026-11-15). Потрібна перевірка носієм.');
end $$;

-- a2-m01: 1
do $$
declare v_aid uuid; v_n int;
begin
  select id into v_aid from public.assessments where slug = 'a2-m01' and cefr = 'A2';
  if v_aid is null then raise exception 'Немає тесту a2-m01'; end if;
  if not exists (select 1 from public.assessment_items i
                  join (values
    ('02912ac9-8400-54f6-a1c4-11ff810a13a4'::uuid, 'U posezoni su cijene niže.', array['Cijene su niže u posezoni.']::text[])
                  ) d(id, answer, alts) on d.id = i.id
                  where i.answer_alternatives = '{}') then return; end if;  -- уже заповнено
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
         jsonb_build_object('items', (select jsonb_agg(to_jsonb(i) order by i.order_index) from public.assessment_items i
                                       where i.assessment_id = v_aid and i.status = 'PUBLISHED' and i.item_type = 'sentence_builder')),
         'sentence_orders_20261116: до «Складіть» додано інші правильні порядки слів — стара версія завдань';
  update public.assessment_items i set answer_alternatives = d.alts
    from (values
    ('02912ac9-8400-54f6-a1c4-11ff810a13a4'::uuid, 'U posezoni su cijene niže.', array['Cijene su niže u posezoni.']::text[])
    ) d(id, answer, alts)
   where i.id = d.id and i.assessment_id = v_aid and i.item_type = 'sentence_builder' and i.status = 'PUBLISHED'
     and i.answer_text = d.answer and i.answer_alternatives = '{}';
  get diagnostics v_n = row_count;
  if v_n <> 1 then raise exception 'Тест a2-m01: оновлено % завдань «Складіть», очікувалось 1 — звірте базу', v_n; end if;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: «Складіть» приймає інші правильні порядки слів (answer_alternatives, M27; рішення власника 2026-11-15). Потрібна перевірка носієм.');
end $$;

-- a2-m02: 2
do $$
declare v_aid uuid; v_n int;
begin
  select id into v_aid from public.assessments where slug = 'a2-m02' and cefr = 'A2';
  if v_aid is null then raise exception 'Немає тесту a2-m02'; end if;
  if not exists (select 1 from public.assessment_items i
                  join (values
    ('cd4f5076-dd57-535c-a15d-b692af64dffc'::uuid, 'Za nezaposlene je tečaj besplatan.', array['Tečaj je besplatan za nezaposlene.']::text[]),
    ('7affede8-9ee9-54db-b088-ba56e65eb050'::uuid, 'Iz matematike ide na instrukcije.', array['Ide na instrukcije iz matematike.']::text[])
                  ) d(id, answer, alts) on d.id = i.id
                  where i.answer_alternatives = '{}') then return; end if;  -- уже заповнено
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
         jsonb_build_object('items', (select jsonb_agg(to_jsonb(i) order by i.order_index) from public.assessment_items i
                                       where i.assessment_id = v_aid and i.status = 'PUBLISHED' and i.item_type = 'sentence_builder')),
         'sentence_orders_20261116: до «Складіть» додано інші правильні порядки слів — стара версія завдань';
  update public.assessment_items i set answer_alternatives = d.alts
    from (values
    ('cd4f5076-dd57-535c-a15d-b692af64dffc'::uuid, 'Za nezaposlene je tečaj besplatan.', array['Tečaj je besplatan za nezaposlene.']::text[]),
    ('7affede8-9ee9-54db-b088-ba56e65eb050'::uuid, 'Iz matematike ide na instrukcije.', array['Ide na instrukcije iz matematike.']::text[])
    ) d(id, answer, alts)
   where i.id = d.id and i.assessment_id = v_aid and i.item_type = 'sentence_builder' and i.status = 'PUBLISHED'
     and i.answer_text = d.answer and i.answer_alternatives = '{}';
  get diagnostics v_n = row_count;
  if v_n <> 2 then raise exception 'Тест a2-m02: оновлено % завдань «Складіть», очікувалось 2 — звірте базу', v_n; end if;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: «Складіть» приймає інші правильні порядки слів (answer_alternatives, M27; рішення власника 2026-11-15). Потрібна перевірка носієм.');
end $$;

-- a2-m03: 1
do $$
declare v_aid uuid; v_n int;
begin
  select id into v_aid from public.assessments where slug = 'a2-m03' and cefr = 'A2';
  if v_aid is null then raise exception 'Немає тесту a2-m03'; end if;
  if not exists (select 1 from public.assessment_items i
                  join (values
    ('d3d32fdf-58ef-5619-9098-348a77008fdd'::uuid, 'Izgubili smo se u starom gradu.', array['U starom gradu smo se izgubili.']::text[])
                  ) d(id, answer, alts) on d.id = i.id
                  where i.answer_alternatives = '{}') then return; end if;  -- уже заповнено
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
         jsonb_build_object('items', (select jsonb_agg(to_jsonb(i) order by i.order_index) from public.assessment_items i
                                       where i.assessment_id = v_aid and i.status = 'PUBLISHED' and i.item_type = 'sentence_builder')),
         'sentence_orders_20261116: до «Складіть» додано інші правильні порядки слів — стара версія завдань';
  update public.assessment_items i set answer_alternatives = d.alts
    from (values
    ('d3d32fdf-58ef-5619-9098-348a77008fdd'::uuid, 'Izgubili smo se u starom gradu.', array['U starom gradu smo se izgubili.']::text[])
    ) d(id, answer, alts)
   where i.id = d.id and i.assessment_id = v_aid and i.item_type = 'sentence_builder' and i.status = 'PUBLISHED'
     and i.answer_text = d.answer and i.answer_alternatives = '{}';
  get diagnostics v_n = row_count;
  if v_n <> 1 then raise exception 'Тест a2-m03: оновлено % завдань «Складіть», очікувалось 1 — звірте базу', v_n; end if;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: «Складіть» приймає інші правильні порядки слів (answer_alternatives, M27; рішення власника 2026-11-15). Потрібна перевірка носієм.');
end $$;

-- a2-m05: 1
do $$
declare v_aid uuid; v_n int;
begin
  select id into v_aid from public.assessments where slug = 'a2-m05' and cefr = 'A2';
  if v_aid is null then raise exception 'Немає тесту a2-m05'; end if;
  if not exists (select 1 from public.assessment_items i
                  join (values
    ('9b2fd4fe-1f35-5908-ab31-7dcdf7226ac7'::uuid, 'Svakom kupcu treba izdati račun.', array['Račun treba izdati svakom kupcu.']::text[])
                  ) d(id, answer, alts) on d.id = i.id
                  where i.answer_alternatives = '{}') then return; end if;  -- уже заповнено
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
         jsonb_build_object('items', (select jsonb_agg(to_jsonb(i) order by i.order_index) from public.assessment_items i
                                       where i.assessment_id = v_aid and i.status = 'PUBLISHED' and i.item_type = 'sentence_builder')),
         'sentence_orders_20261116: до «Складіть» додано інші правильні порядки слів — стара версія завдань';
  update public.assessment_items i set answer_alternatives = d.alts
    from (values
    ('9b2fd4fe-1f35-5908-ab31-7dcdf7226ac7'::uuid, 'Svakom kupcu treba izdati račun.', array['Račun treba izdati svakom kupcu.']::text[])
    ) d(id, answer, alts)
   where i.id = d.id and i.assessment_id = v_aid and i.item_type = 'sentence_builder' and i.status = 'PUBLISHED'
     and i.answer_text = d.answer and i.answer_alternatives = '{}';
  get diagnostics v_n = row_count;
  if v_n <> 1 then raise exception 'Тест a2-m05: оновлено % завдань «Складіть», очікувалось 1 — звірте базу', v_n; end if;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: «Складіть» приймає інші правильні порядки слів (answer_alternatives, M27; рішення власника 2026-11-15). Потрібна перевірка носієм.');
end $$;

-- a2-m06: 1
do $$
declare v_aid uuid; v_n int;
begin
  select id into v_aid from public.assessments where slug = 'a2-m06' and cefr = 'A2';
  if v_aid is null then raise exception 'Немає тесту a2-m06'; end if;
  if not exists (select 1 from public.assessment_items i
                  join (values
    ('d40fe759-3288-5a5e-a68a-31bdfe11e9e3'::uuid, 'Slavina kapa cijelu noć.', array['Slavina cijelu noć kapa.']::text[])
                  ) d(id, answer, alts) on d.id = i.id
                  where i.answer_alternatives = '{}') then return; end if;  -- уже заповнено
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
         jsonb_build_object('items', (select jsonb_agg(to_jsonb(i) order by i.order_index) from public.assessment_items i
                                       where i.assessment_id = v_aid and i.status = 'PUBLISHED' and i.item_type = 'sentence_builder')),
         'sentence_orders_20261116: до «Складіть» додано інші правильні порядки слів — стара версія завдань';
  update public.assessment_items i set answer_alternatives = d.alts
    from (values
    ('d40fe759-3288-5a5e-a68a-31bdfe11e9e3'::uuid, 'Slavina kapa cijelu noć.', array['Slavina cijelu noć kapa.']::text[])
    ) d(id, answer, alts)
   where i.id = d.id and i.assessment_id = v_aid and i.item_type = 'sentence_builder' and i.status = 'PUBLISHED'
     and i.answer_text = d.answer and i.answer_alternatives = '{}';
  get diagnostics v_n = row_count;
  if v_n <> 1 then raise exception 'Тест a2-m06: оновлено % завдань «Складіть», очікувалось 1 — звірте базу', v_n; end if;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: «Складіть» приймає інші правильні порядки слів (answer_alternatives, M27; рішення власника 2026-11-15). Потрібна перевірка носієм.');
end $$;

-- a2-m07: 1
do $$
declare v_aid uuid; v_n int;
begin
  select id into v_aid from public.assessments where slug = 'a2-m07' and cefr = 'A2';
  if v_aid is null then raise exception 'Немає тесту a2-m07'; end if;
  if not exists (select 1 from public.assessment_items i
                  join (values
    ('b3b5ea28-a898-58b6-8a52-191faea836b3'::uuid, 'Na pregled dođite natašte.', array['Dođite na pregled natašte.']::text[])
                  ) d(id, answer, alts) on d.id = i.id
                  where i.answer_alternatives = '{}') then return; end if;  -- уже заповнено
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
         jsonb_build_object('items', (select jsonb_agg(to_jsonb(i) order by i.order_index) from public.assessment_items i
                                       where i.assessment_id = v_aid and i.status = 'PUBLISHED' and i.item_type = 'sentence_builder')),
         'sentence_orders_20261116: до «Складіть» додано інші правильні порядки слів — стара версія завдань';
  update public.assessment_items i set answer_alternatives = d.alts
    from (values
    ('b3b5ea28-a898-58b6-8a52-191faea836b3'::uuid, 'Na pregled dođite natašte.', array['Dođite na pregled natašte.']::text[])
    ) d(id, answer, alts)
   where i.id = d.id and i.assessment_id = v_aid and i.item_type = 'sentence_builder' and i.status = 'PUBLISHED'
     and i.answer_text = d.answer and i.answer_alternatives = '{}';
  get diagnostics v_n = row_count;
  if v_n <> 1 then raise exception 'Тест a2-m07: оновлено % завдань «Складіть», очікувалось 1 — звірте базу', v_n; end if;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: «Складіть» приймає інші правильні порядки слів (answer_alternatives, M27; рішення власника 2026-11-15). Потрібна перевірка носієм.');
end $$;

-- a2-m08: 1
do $$
declare v_aid uuid; v_n int;
begin
  select id into v_aid from public.assessments where slug = 'a2-m08' and cefr = 'A2';
  if v_aid is null then raise exception 'Немає тесту a2-m08'; end if;
  if not exists (select 1 from public.assessment_items i
                  join (values
    ('edf4c8ba-3acc-5046-a79b-5878f9412f25'::uuid, 'Parking možete platiti SMS-om.', array['Možete platiti parking SMS-om.']::text[])
                  ) d(id, answer, alts) on d.id = i.id
                  where i.answer_alternatives = '{}') then return; end if;  -- уже заповнено
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
         jsonb_build_object('items', (select jsonb_agg(to_jsonb(i) order by i.order_index) from public.assessment_items i
                                       where i.assessment_id = v_aid and i.status = 'PUBLISHED' and i.item_type = 'sentence_builder')),
         'sentence_orders_20261116: до «Складіть» додано інші правильні порядки слів — стара версія завдань';
  update public.assessment_items i set answer_alternatives = d.alts
    from (values
    ('edf4c8ba-3acc-5046-a79b-5878f9412f25'::uuid, 'Parking možete platiti SMS-om.', array['Možete platiti parking SMS-om.']::text[])
    ) d(id, answer, alts)
   where i.id = d.id and i.assessment_id = v_aid and i.item_type = 'sentence_builder' and i.status = 'PUBLISHED'
     and i.answer_text = d.answer and i.answer_alternatives = '{}';
  get diagnostics v_n = row_count;
  if v_n <> 1 then raise exception 'Тест a2-m08: оновлено % завдань «Складіть», очікувалось 1 — звірте базу', v_n; end if;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: «Складіть» приймає інші правильні порядки слів (answer_alternatives, M27; рішення власника 2026-11-15). Потрібна перевірка носієм.');
end $$;

-- a2-m09: 1
do $$
declare v_aid uuid; v_n int;
begin
  select id into v_aid from public.assessments where slug = 'a2-m09' and cefr = 'A2';
  if v_aid is null then raise exception 'Немає тесту a2-m09'; end if;
  if not exists (select 1 from public.assessment_items i
                  join (values
    ('7c19ef44-a584-52fd-9574-6658bd7ed325'::uuid, 'Moramo čuvati okoliš.', array['Okoliš moramo čuvati.']::text[])
                  ) d(id, answer, alts) on d.id = i.id
                  where i.answer_alternatives = '{}') then return; end if;  -- уже заповнено
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
         jsonb_build_object('items', (select jsonb_agg(to_jsonb(i) order by i.order_index) from public.assessment_items i
                                       where i.assessment_id = v_aid and i.status = 'PUBLISHED' and i.item_type = 'sentence_builder')),
         'sentence_orders_20261116: до «Складіть» додано інші правильні порядки слів — стара версія завдань';
  update public.assessment_items i set answer_alternatives = d.alts
    from (values
    ('7c19ef44-a584-52fd-9574-6658bd7ed325'::uuid, 'Moramo čuvati okoliš.', array['Okoliš moramo čuvati.']::text[])
    ) d(id, answer, alts)
   where i.id = d.id and i.assessment_id = v_aid and i.item_type = 'sentence_builder' and i.status = 'PUBLISHED'
     and i.answer_text = d.answer and i.answer_alternatives = '{}';
  get diagnostics v_n = row_count;
  if v_n <> 1 then raise exception 'Тест a2-m09: оновлено % завдань «Складіть», очікувалось 1 — звірте базу', v_n; end if;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: «Складіть» приймає інші правильні порядки слів (answer_alternatives, M27; рішення власника 2026-11-15). Потрібна перевірка носієм.');
end $$;

-- a2-m11: 1
do $$
declare v_aid uuid; v_n int;
begin
  select id into v_aid from public.assessments where slug = 'a2-m11' and cefr = 'A2';
  if v_aid is null then raise exception 'Немає тесту a2-m11'; end if;
  if not exists (select 1 from public.assessment_items i
                  join (values
    ('0026b933-a456-5b5e-93ad-df4dc134fde7'::uuid, 'Starijima se persira.', array['Persira se starijima.']::text[])
                  ) d(id, answer, alts) on d.id = i.id
                  where i.answer_alternatives = '{}') then return; end if;  -- уже заповнено
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
         jsonb_build_object('items', (select jsonb_agg(to_jsonb(i) order by i.order_index) from public.assessment_items i
                                       where i.assessment_id = v_aid and i.status = 'PUBLISHED' and i.item_type = 'sentence_builder')),
         'sentence_orders_20261116: до «Складіть» додано інші правильні порядки слів — стара версія завдань';
  update public.assessment_items i set answer_alternatives = d.alts
    from (values
    ('0026b933-a456-5b5e-93ad-df4dc134fde7'::uuid, 'Starijima se persira.', array['Persira se starijima.']::text[])
    ) d(id, answer, alts)
   where i.id = d.id and i.assessment_id = v_aid and i.item_type = 'sentence_builder' and i.status = 'PUBLISHED'
     and i.answer_text = d.answer and i.answer_alternatives = '{}';
  get diagnostics v_n = row_count;
  if v_n <> 1 then raise exception 'Тест a2-m11: оновлено % завдань «Складіть», очікувалось 1 — звірте базу', v_n; end if;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: «Складіть» приймає інші правильні порядки слів (answer_alternatives, M27; рішення власника 2026-11-15). Потрібна перевірка носієм.');
end $$;

-- a2-m12: 1
do $$
declare v_aid uuid; v_n int;
begin
  select id into v_aid from public.assessments where slug = 'a2-m12' and cefr = 'A2';
  if v_aid is null then raise exception 'Немає тесту a2-m12'; end if;
  if not exists (select 1 from public.assessment_items i
                  join (values
    ('f71c6cdd-58bb-5af3-8e2c-1c41becc451d'::uuid, 'Mama je primila novac jučer.', array['Mama je jučer primila novac.', 'Jučer je mama primila novac.']::text[])
                  ) d(id, answer, alts) on d.id = i.id
                  where i.answer_alternatives = '{}') then return; end if;  -- уже заповнено
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
         jsonb_build_object('items', (select jsonb_agg(to_jsonb(i) order by i.order_index) from public.assessment_items i
                                       where i.assessment_id = v_aid and i.status = 'PUBLISHED' and i.item_type = 'sentence_builder')),
         'sentence_orders_20261116: до «Складіть» додано інші правильні порядки слів — стара версія завдань';
  update public.assessment_items i set answer_alternatives = d.alts
    from (values
    ('f71c6cdd-58bb-5af3-8e2c-1c41becc451d'::uuid, 'Mama je primila novac jučer.', array['Mama je jučer primila novac.', 'Jučer je mama primila novac.']::text[])
    ) d(id, answer, alts)
   where i.id = d.id and i.assessment_id = v_aid and i.item_type = 'sentence_builder' and i.status = 'PUBLISHED'
     and i.answer_text = d.answer and i.answer_alternatives = '{}';
  get diagnostics v_n = row_count;
  if v_n <> 1 then raise exception 'Тест a2-m12: оновлено % завдань «Складіть», очікувалось 1 — звірте базу', v_n; end if;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: «Складіть» приймає інші правильні порядки слів (answer_alternatives, M27; рішення власника 2026-11-15). Потрібна перевірка носієм.');
end $$;

-- a2-m13: 1
do $$
declare v_aid uuid; v_n int;
begin
  select id into v_aid from public.assessments where slug = 'a2-m13' and cefr = 'A2';
  if v_aid is null then raise exception 'Немає тесту a2-m13'; end if;
  if not exists (select 1 from public.assessment_items i
                  join (values
    ('a1141969-356f-583a-9aca-76929a0e8787'::uuid, 'Doći ću, pod uvjetom da ne pada kiša.', array['Pod uvjetom da ne pada kiša, doći ću.']::text[])
                  ) d(id, answer, alts) on d.id = i.id
                  where i.answer_alternatives = '{}') then return; end if;  -- уже заповнено
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
         jsonb_build_object('items', (select jsonb_agg(to_jsonb(i) order by i.order_index) from public.assessment_items i
                                       where i.assessment_id = v_aid and i.status = 'PUBLISHED' and i.item_type = 'sentence_builder')),
         'sentence_orders_20261116: до «Складіть» додано інші правильні порядки слів — стара версія завдань';
  update public.assessment_items i set answer_alternatives = d.alts
    from (values
    ('a1141969-356f-583a-9aca-76929a0e8787'::uuid, 'Doći ću, pod uvjetom da ne pada kiša.', array['Pod uvjetom da ne pada kiša, doći ću.']::text[])
    ) d(id, answer, alts)
   where i.id = d.id and i.assessment_id = v_aid and i.item_type = 'sentence_builder' and i.status = 'PUBLISHED'
     and i.answer_text = d.answer and i.answer_alternatives = '{}';
  get diagnostics v_n = row_count;
  if v_n <> 1 then raise exception 'Тест a2-m13: оновлено % завдань «Складіть», очікувалось 1 — звірте базу', v_n; end if;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: «Складіть» приймає інші правильні порядки слів (answer_alternatives, M27; рішення власника 2026-11-15). Потрібна перевірка носієм.');
end $$;

-- a2-mid: 2
do $$
declare v_aid uuid; v_n int;
begin
  select id into v_aid from public.assessments where slug = 'a2-mid' and cefr = 'A2';
  if v_aid is null then raise exception 'Немає тесту a2-mid'; end if;
  if not exists (select 1 from public.assessment_items i
                  join (values
    ('c030bc32-db2c-56f6-ae54-1283e240e540'::uuid, 'Natječaj se objavljuje u svibnju.', array['U svibnju se objavljuje natječaj.']::text[]),
    ('e2b44503-dc65-55b6-8b85-08e330c8d7ae'::uuid, 'Brzo smo se priviknuli na novi grad.', array['Na novi grad smo se brzo priviknuli.']::text[])
                  ) d(id, answer, alts) on d.id = i.id
                  where i.answer_alternatives = '{}') then return; end if;  -- уже заповнено
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
         jsonb_build_object('items', (select jsonb_agg(to_jsonb(i) order by i.order_index) from public.assessment_items i
                                       where i.assessment_id = v_aid and i.status = 'PUBLISHED' and i.item_type = 'sentence_builder')),
         'sentence_orders_20261116: до «Складіть» додано інші правильні порядки слів — стара версія завдань';
  update public.assessment_items i set answer_alternatives = d.alts
    from (values
    ('c030bc32-db2c-56f6-ae54-1283e240e540'::uuid, 'Natječaj se objavljuje u svibnju.', array['U svibnju se objavljuje natječaj.']::text[]),
    ('e2b44503-dc65-55b6-8b85-08e330c8d7ae'::uuid, 'Brzo smo se priviknuli na novi grad.', array['Na novi grad smo se brzo priviknuli.']::text[])
    ) d(id, answer, alts)
   where i.id = d.id and i.assessment_id = v_aid and i.item_type = 'sentence_builder' and i.status = 'PUBLISHED'
     and i.answer_text = d.answer and i.answer_alternatives = '{}';
  get diagnostics v_n = row_count;
  if v_n <> 2 then raise exception 'Тест a2-mid: оновлено % завдань «Складіть», очікувалось 2 — звірте базу', v_n; end if;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'Бета: «Складіть» приймає інші правильні порядки слів (answer_alternatives, M27; рішення власника 2026-11-15). Потрібна перевірка носієм.');
end $$;

-- Самоперевірка
do $$
declare v_n int;
begin
  select count(*) into v_n from public.assessment_items where id in ('a7cb2965-f22b-50c9-bd6e-e503d20f5e8d', 'b56d7940-25be-568b-8ae7-b8ffa52af64b', 'cf3d9e63-ec26-5d1c-9e16-3b41420fb5ce', '02912ac9-8400-54f6-a1c4-11ff810a13a4', 'cd4f5076-dd57-535c-a15d-b692af64dffc', '7affede8-9ee9-54db-b088-ba56e65eb050', 'd3d32fdf-58ef-5619-9098-348a77008fdd', '9b2fd4fe-1f35-5908-ab31-7dcdf7226ac7', 'd40fe759-3288-5a5e-a68a-31bdfe11e9e3', 'b3b5ea28-a898-58b6-8a52-191faea836b3', 'edf4c8ba-3acc-5046-a79b-5878f9412f25', '7c19ef44-a584-52fd-9574-6658bd7ed325', '0026b933-a456-5b5e-93ad-df4dc134fde7', 'f71c6cdd-58bb-5af3-8e2c-1c41becc451d', 'a1141969-356f-583a-9aca-76929a0e8787', 'c030bc32-db2c-56f6-ae54-1283e240e540', 'e2b44503-dc65-55b6-8b85-08e330c8d7ae') and cardinality(answer_alternatives) > 0;
  if v_n <> 17 then raise exception '«Складіть» A2: з іншими порядками % завдань, очікувалось 17', v_n; end if;
  raise notice 'Готово: «Складіть» A2 — з іншими порядками % завдань', v_n;
end $$;

commit;
