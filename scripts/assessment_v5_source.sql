-- Джерела перевірок рівня A0 / A1 (схема 2026-11-07): модулі, уроки, діалоги, вправи, тексти для читання — лише PUBLISHED.
-- Лише читання. Вихід — scripts/assessment_a0_a1_v5_snapshot.json (gen_assessment_a0_a1_v5.py --snapshot).
select (jsonb_build_object('levels', (
  select jsonb_agg(jsonb_build_object('level', lv, 'modules', (
    select jsonb_agg(jsonb_build_object(
      'id', m.id, 'order', m.order_index, 'title_ua', m.title_ua, 'title_hr', m.title_hr,
      'lessons', (
        select coalesce(jsonb_agg(jsonb_build_object(
          'id', l.id, 'order', l.order_index, 'title_ua', l.title_ua, 'title_hr', l.title_hr,
          'dialogues', (
            select coalesce(jsonb_agg(jsonb_build_object('id', c.id, 'title_ua', c.title_ua, 'title_hr', c.title_hr,
              'turns', (select coalesce(jsonb_agg(jsonb_build_object('speaker', t.speaker_name, 'hr', t.hr_text, 'ua', t.ua_translation)
                                                  order by t.order_index), '[]'::jsonb)
                          from public.conversation_turns t where t.conversation_id = c.id)) order by c.order_index, c.id), '[]'::jsonb)
              from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED'),
          'exercises', (
            select coalesce(jsonb_agg(jsonb_build_object('type', e.exercise_type, 'q', e.question_text, 'a', e.correct_answer
                                                         ) order by li.order_index), '[]'::jsonb)
              from public.lesson_items li join public.exercises e on e.id = li.item_id and e.status = 'PUBLISHED'
             where li.lesson_id = l.id and li.item_type = 'exercise'
               and e.exercise_type in ('type_answer', 'sentence_builder', 'speaking'))
        ) order by l.order_index), '[]'::jsonb)
          from public.units u join public.lessons l on l.unit_id = u.id and l.status = 'PUBLISHED' where u.module_id = m.id),
      'reading', (
        select coalesce(jsonb_agg(jsonb_build_object('code', r.code, 'type', r.text_type, 'title_ua', r.title_ua, 'title_hr', r.title_hr,
                                                     'body_hr', replace(r.body_hr, E'\r', ''), 'body_ua', replace(r.body_ua, E'\r', ''),
                                                     'questions', r.questions) order by r.order_index, r.code), '[]'::jsonb)
          from public.reading_texts r where r.cefr = lv and r.module_order = m.order_index and r.status = 'PUBLISHED')
    ) order by m.order_index)
    from public.modules m where m.level_code = lv and m.status = 'PUBLISHED')) order by lv)
  from unnest(array['A0', 'A1']) lv)));
