-- Знімок для scripts/gen_a2_dupes.py (план «Дублі й сенс уроків», PR 4 — дублі A2, 2026-11-19). Лише читання.
-- Зроблено з локальної бази (scripts/dev/curdb.sh) після пакетів PR 3; збіг з робочою базою перевірено хешами 2026-11-19:
-- уроки A2 (назви, цілі), вправи, діалоги й репліки A1–A2 — однакові; слова й переклади уроків 9, 27, 29, 33, 38, 44, 70 —
-- однакові (8 перекладів локальної копії вирівняно сидом scripts/dev/seed/seed_a2_dupes_supplement.sql).
-- a2 — уроки A2: модуль, місце, назва, слова з перекладом; lessons — перший урок кожного слова (усі рівні);
-- items — склад уроків, які змінює пакет (вправи — з типом, питанням, відповіддю, варіантами й task);
-- conversations — діалоги цих уроків і діалоги з однаковими назвами (A2) з репліками; titles — назви всіх діалогів A0–A2; lex — наявні слова пакета.
select jsonb_build_object(
  'a2', (select jsonb_agg(jsonb_build_object('id', l.id, 'module', m.order_index, 'order', l.order_index, 'title', l.title_ua,
           'title_hr', l.title_hr, 'unit', l.unit_id, 'objectives', l.objectives,
           'words', (select coalesce(jsonb_agg(jsonb_build_array(x.lemma, x.ukrainian_translation) order by li.order_index), '[]'::jsonb)
                       from public.lesson_items li join public.lexemes x on x.id = li.item_id
                      where li.lesson_id = l.id and li.item_type = 'lexeme'))
         order by m.order_index, l.order_index)
         from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
        where m.level_code = 'A2' and l.status = 'PUBLISHED'),
  'lessons', (select jsonb_object_agg(k, v) from (
      select lower(x.lemma) k, min(l.level_code || ' ' || split_part(l.title_ua, ':', 1)) v
        from public.lesson_items li join public.lessons l on l.id = li.lesson_id and l.status = 'PUBLISHED'
        join public.lexemes x on x.id = li.item_id where li.item_type = 'lexeme' group by 1) t),
  'items', (select jsonb_agg(jsonb_build_object('lesson', li.lesson_id, 'order', li.order_index, 'type', li.item_type, 'item', li.item_id,
              'required', li.required, 'skill', li.target_skill, 'lemma', x.lemma, 'ex_type', e.exercise_type, 'question', e.question_text,
              'answer', e.correct_answer, 'options', e.options, 'task', e.task, 'lexeme', xe.lemma)
            order by li.lesson_id, li.order_index)
      from public.lesson_items li
      left join public.lexemes x on li.item_type = 'lexeme' and x.id = li.item_id
      left join public.exercises e on li.item_type = 'exercise' and e.id = li.item_id
      left join public.lexemes xe on xe.id = e.lexeme_id
     where li.lesson_id in ('8190831a-549a-544a-962b-4f716a895a32', 'f029711f-710e-5327-be4d-2310435e6eac', '5252662a-abfc-517a-9bde-8683121a53c5',
                            '0e0d07a2-2a6c-5090-ab84-3089f20a48b8', 'bf43b6bd-d547-596b-8981-55a4043cf238', '8f08356b-8efa-5ebc-906e-f409fbaadaf3',
                            '7d3c3501-a381-5b3c-a0a2-b269f3dff137')),
  'conversations', (select jsonb_agg(jsonb_build_object('id', c.id, 'lesson', c.lesson_id, 'title_ua', c.title_ua, 'title_hr', c.title_hr,
              'order', c.order_index, 'situation', c.situation,
              'turns', (select jsonb_agg(jsonb_build_array(t.speaker_name, t.hr_text, t.ua_translation) order by t.order_index)
                          from public.conversation_turns t where t.conversation_id = c.id)) order by c.order_index)
      from public.conversations c join public.lessons l on l.id = c.lesson_id and l.status = 'PUBLISHED'
     where c.status = 'PUBLISHED'
       and (c.lesson_id in ('8190831a-549a-544a-962b-4f716a895a32', 'f029711f-710e-5327-be4d-2310435e6eac', '5252662a-abfc-517a-9bde-8683121a53c5',
                            '0e0d07a2-2a6c-5090-ab84-3089f20a48b8', 'bf43b6bd-d547-596b-8981-55a4043cf238', '8f08356b-8efa-5ebc-906e-f409fbaadaf3',
                            '7d3c3501-a381-5b3c-a0a2-b269f3dff137')
            or c.id in ('14d9a946-c3e1-58cf-bff8-0c2cca867149', '2c8cd7ee-e3d3-58d3-8ffe-420bf19fdb8e', '9140c599-ceba-5bbb-8214-54c16f55a70c',
                        'b4dd1542-9a39-5b6b-b285-9b12c3a68061', 'dc69dcd8-ddd4-5c6c-b7c8-2d9b9d770f84', '82cdf22b-ae0c-5783-898e-bed827a54a1e'))),
  'titles', (select jsonb_agg(jsonb_build_array(c.id, l.level_code, c.title_hr) order by c.id)
      from public.conversations c join public.lessons l on l.id = c.lesson_id and l.status = 'PUBLISHED'
     where c.status = 'PUBLISHED' and l.level_code in ('A0', 'A1', 'A2')),
  'lex', (select jsonb_object_agg(lower(x.lemma), jsonb_build_array(x.lemma, x.ukrainian_translation, x.cefr))
            from public.lexemes x where x.status = 'PUBLISHED'
             and lower(x.lemma) in ('dokaz', 'ispravljati', 'sudjelovati', 'morska sol', 'šetnja', 'otvoriti bolovanje', 'zatvoriti bolovanje', 'javiti se bolestan'))
)::text;
