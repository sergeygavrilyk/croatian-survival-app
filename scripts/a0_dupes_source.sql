-- Знімок для scripts/gen_a0_dupes.py (план «Дублі й сенс уроків», PR 2б — дублі A0, 2026-11-17). Лише читання.
-- Зроблено з локальної бази (scripts/dev/curdb.sh) до пакетів PR 2б; збіг з робочою базою для уроків 26, 30, 58, 64, 68, 69
-- перевірено хешами (вправи, діалоги, назви) 2026-11-17.
-- a0 — уроки A0: модуль, місце, назва, слова з перекладом; lessons — перший урок кожного слова (усі рівні);
-- items — склад уроків, які змінює пакет (вправи — з типом, питанням, відповіддю й варіантами);
-- conversations — діалоги цих уроків з репліками.
select jsonb_build_object(
  'a0', (select jsonb_agg(jsonb_build_object('id', l.id, 'module', m.order_index, 'order', l.order_index, 'title', l.title_ua,
           'words', (select coalesce(jsonb_agg(jsonb_build_array(x.lemma, x.ukrainian_translation) order by li.order_index), '[]'::jsonb)
                       from public.lesson_items li join public.lexemes x on x.id = li.item_id
                      where li.lesson_id = l.id and li.item_type = 'lexeme'))
         order by m.order_index, l.order_index)
         from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
        where m.level_code = 'A0' and l.status = 'PUBLISHED'),
  'lessons', (select jsonb_object_agg(k, v) from (
      select lower(x.lemma) k, min(l.level_code || ' ' || split_part(l.title_ua, ':', 1)) v
        from public.lesson_items li join public.lessons l on l.id = li.lesson_id and l.status = 'PUBLISHED'
        join public.lexemes x on x.id = li.item_id where li.item_type = 'lexeme' group by 1) t),
  'items', (select jsonb_agg(jsonb_build_object('lesson', li.lesson_id, 'order', li.order_index, 'type', li.item_type, 'item', li.item_id,
              'required', li.required, 'skill', li.target_skill, 'lemma', x.lemma, 'ex_type', e.exercise_type, 'question', e.question_text,
              'answer', e.correct_answer, 'options', e.options, 'ex_order', e.order_index, 'lexeme', xe.lemma)
            order by li.lesson_id, li.order_index)
      from public.lesson_items li
      left join public.lexemes x on li.item_type = 'lexeme' and x.id = li.item_id
      left join public.exercises e on li.item_type = 'exercise' and e.id = li.item_id
      left join public.lexemes xe on xe.id = e.lexeme_id
     where li.lesson_id in ('39b1e31f-b573-5000-9713-1660688c3cc9', 'd7cf3059-0d92-5215-8ef4-ad699e317b10', 'b01e2f67-3e7a-5ab6-99bb-fae374f431e0',
                            'e5b81eb1-8ea8-5ff4-a987-e5e46421302b', 'fbc71f82-e715-5bab-a990-b8542fb0fe01', '48f26e9d-96c5-5189-8ec6-db1f9d58e200',
                            '7fb1b6e5-93b4-5776-b82b-25e7769fd32d')),
  'conversations', (select jsonb_agg(jsonb_build_object('id', c.id, 'lesson', c.lesson_id, 'title_ua', c.title_ua, 'title_hr', c.title_hr,
              'order', c.order_index, 'situation', c.situation,
              'turns', (select jsonb_agg(jsonb_build_array(t.speaker_name, t.hr_text, t.ua_translation) order by t.order_index)
                          from public.conversation_turns t where t.conversation_id = c.id)) order by c.order_index)
      from public.conversations c
     where c.status = 'PUBLISHED'
       and c.lesson_id in ('39b1e31f-b573-5000-9713-1660688c3cc9', 'd7cf3059-0d92-5215-8ef4-ad699e317b10', 'b01e2f67-3e7a-5ab6-99bb-fae374f431e0',
                           'e5b81eb1-8ea8-5ff4-a987-e5e46421302b', 'fbc71f82-e715-5bab-a990-b8542fb0fe01', '48f26e9d-96c5-5189-8ec6-db1f9d58e200'))
)::text;
