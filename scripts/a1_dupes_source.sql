-- Знімок для scripts/gen_a1_dupes.py (план «Дублі й сенс уроків», PR 3 — дублі A1, 2026-11-17). Лише читання.
-- Зроблено з локальної бази (scripts/dev/curdb.sh) після пакетів PR 2б; збіг з робочою базою для всіх 108 уроків A1
-- (слова, вправи, діалоги й репліки) і перекладів слів уроків A1 перевірено хешами 2026-11-17.
-- a1 — уроки A1: модуль, місце, назва, слова з перекладом; lessons — перший урок кожного слова (усі рівні);
-- items — склад уроків, які змінює пакет (вправи — з типом, питанням, відповіддю й варіантами);
-- conversations — діалоги цих уроків і діалоги з однаковими назвами (A1) з репліками.
select jsonb_build_object(
  'a1', (select jsonb_agg(jsonb_build_object('id', l.id, 'module', m.order_index, 'order', l.order_index, 'title', l.title_ua,
           'unit', l.unit_id,
           'words', (select coalesce(jsonb_agg(jsonb_build_array(x.lemma, x.ukrainian_translation) order by li.order_index), '[]'::jsonb)
                       from public.lesson_items li join public.lexemes x on x.id = li.item_id
                      where li.lesson_id = l.id and li.item_type = 'lexeme'))
         order by m.order_index, l.order_index)
         from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
        where m.level_code = 'A1' and l.status = 'PUBLISHED'),
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
     where li.lesson_id in ('4d6f3498-2cc5-54a0-b4e4-c66add71ef12', '123e68fa-291f-5ad6-8403-51db7020d641', 'd9ef1de4-f4db-590e-bafd-474f84c8e03f',
                            '11b565a4-1e2a-50d2-8d9d-c05e84371402', '692e9310-7a5b-5adf-9f0a-a66b72fc5459', 'dd6c5f39-f66e-5acb-8255-932f822ddcc5', 'b9bcea21-08a3-56cf-be72-edf6b6c7b03f')),
  'conversations', (select jsonb_agg(jsonb_build_object('id', c.id, 'lesson', c.lesson_id, 'title_ua', c.title_ua, 'title_hr', c.title_hr,
              'order', c.order_index, 'situation', c.situation,
              'turns', (select jsonb_agg(jsonb_build_array(t.speaker_name, t.hr_text, t.ua_translation) order by t.order_index)
                          from public.conversation_turns t where t.conversation_id = c.id)) order by c.order_index)
      from public.conversations c
     where c.status = 'PUBLISHED'
       and (c.lesson_id in ('4d6f3498-2cc5-54a0-b4e4-c66add71ef12', '123e68fa-291f-5ad6-8403-51db7020d641', 'd9ef1de4-f4db-590e-bafd-474f84c8e03f',
                            '11b565a4-1e2a-50d2-8d9d-c05e84371402')
            or c.id in ('1515f889-130f-5476-8851-938106d3700a', 'fe918e0d-21ff-5dc9-b37a-fbf2af2bfccd', 'b2e86525-a790-5cf3-87ce-734d9e063a43',
                        '1344654b-470d-5676-b47e-b0001240b17d', '0a6b020d-ea8a-52dd-9cba-22cda92936e5', 'b9fa04a2-e778-57c5-95d9-106b6058ad98',
                        '14858aec-7921-527f-b3c3-e839da3fb494', '6a218fb4-4e02-5825-8744-f5d9813cffa4', '514923a7-f17e-52bd-bf86-ddfff3e51b51')))
)::text;
