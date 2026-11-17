-- Знімок для scripts/gen_a0_pets_module.py (модуль A0.6 «Kućni ljubimci», 2026-11-17). Лише читання.
-- a0 — уроки A0 (до пакета): модуль, місце, назва, слова з перекладом; lessons — усі слова всіх опублікованих уроків (усі рівні).
select jsonb_build_object(
  'a0', (select jsonb_agg(jsonb_build_object('id', l.id, 'module', m.order_index, 'order', l.order_index, 'title', l.title_ua,
           'words', (select jsonb_agg(jsonb_build_array(x.lemma, x.ukrainian_translation) order by li.order_index)
                       from public.lesson_items li join public.lexemes x on x.id = li.item_id
                      where li.lesson_id = l.id and li.item_type = 'lexeme'))
         order by m.order_index, l.order_index)
         from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
        where m.level_code = 'A0' and l.status = 'PUBLISHED'),
  'lessons', (select jsonb_object_agg(k, v) from (
      select lower(x.lemma) k, min(l.level_code || ' ' || split_part(l.title_ua, ':', 1)) v
        from public.lesson_items li join public.lessons l on l.id = li.lesson_id and l.status = 'PUBLISHED'
        join public.lexemes x on x.id = li.item_id where li.item_type = 'lexeme' group by 1) t)
)::text;
