-- =====================================================================
-- Сумнівні слова запасу A2 / B1 · 2026-11-12
-- Згенеровано: python3 -B scripts/gen_vocab_a2_fix_20261112.py (не редагуйте вручну).
-- Рішення власника 2026-11-12 (аудит content/reviews/2026-11-12_a2_audit.md, питання 5):
--   «Сумнівні слова в запасі (utisak, kompjuter, apoteka, da li…) виправити. Позначити "регіонально" —
--    далматинські діалектні: pomidor, kapula, šugaman».
--   1. Виправити лему: utisak → dojam, talenat → talent, dogoditi / događati / baviti → … se;
--      klasično, moderno — прислівники.
--   2. DEPRECATED (приховати, НЕ видалити) 11 дублікатів стандартних слів: apoteka, kompjuter, «da li govorite engleski»,
--      sistem, «dijaloz -> dijalog», podaci, usluge, družiti, navići, smijeti, posati.
--      Лише якщо слово не стоїть в уроці, у вправі й не має прогресу користувачів — інакше файл зупиниться.
--   3. «Регіонально» в перекладі: pomidor, kapula, šugaman, ae, onak.
--   Стара версія — у content_versions, запис — у content_reviews. Повторний запуск нічого не змінює.
-- Після нього: тест supabase/tests/vocab_a2_fix.test.sql → «ALL TESTS PASSED».
-- Очікуване повідомлення: «Готово: виправлено лем …, DEPRECATED …, «регіонально» …».
-- =====================================================================

begin;

do $fix$
declare
  w record;
  x public.lexemes%rowtype;
  v_ren int := 0;
  v_dep int := 0;
  v_reg int := 0;
  v_dep_list jsonb := '["apoteka", "kompjuter", "da li govorite engleski", "sistem", "dijaloz -> dijalog", "podaci", "usluge", "družiti", "navići", "smijeti", "posati"]'::jsonb;
begin
  -- 1. Виправити лему / частину мови
  for w in select * from jsonb_to_recordset('[{"old": "utisak", "lemma": "dojam", "pos": "noun", "tr": "враження", "forms": {"gender": "m", "gen": "dojma"}, "expl": "Хорватською — dojam (родовий dojma). Utisak — сербська форма.", "ex": ["Ostavio je dobar dojam.", "Kakav je tvoj prvi dojam o Zagrebu?"], "norm": "dojam"}, {"old": "talenat", "lemma": "talent", "pos": "noun", "tr": "талант", "forms": {"gender": "m", "gen": "talenta"}, "expl": "Хорватською — talent (родовий talenta). Talenat — сербська форма.", "ex": ["Ima talenta za jezike.", "Darja ima talent za crtanje."], "norm": "talent"}, {"old": "dogoditi", "lemma": "dogoditi se", "pos": "verb", "tr": "статися", "forms": {"aspect": "pfv", "past": "dogodilo se"}, "expl": "Завжди з se. Пара: događati se (недоконаний вид).", "ex": ["Što se dogodilo?", "Jučer mi se dogodila čudna stvar."], "norm": "dogoditi se"}, {"old": "događati", "lemma": "događati se", "pos": "verb", "tr": "відбуватися", "forms": {"aspect": "ipfv"}, "expl": "Завжди з se. Пара: dogoditi se (доконаний вид).", "ex": ["Što se događa?", "To se događa svaki dan."], "norm": "dogadati se"}, {"old": "baviti", "lemma": "baviti se", "pos": "verb", "tr": "займатися", "forms": {"aspect": "ipfv"}, "expl": "Завжди з se й орудним відмінком: baviti se sportom, baviti se glazbom.", "ex": ["Bavim se sportom.", "Čime se baviš u slobodno vrijeme?"], "norm": "baviti se"}, {"old": "klasično", "lemma": "klasično", "pos": "adverb", "tr": "класично", "forms": {}, "expl": "Прислівник (як? — klasično). Прикметник — klasičan.", "ex": ["Uvijek se oblači klasično."], "norm": "klasicno"}, {"old": "moderno", "lemma": "moderno", "pos": "adverb", "tr": "сучасно", "forms": {}, "expl": "Прислівник (як? — moderno). Прикметник — moderan.", "ex": ["Stan je moderno uređen."], "norm": "moderno"}]'::jsonb)
           as t(old text, lemma text, norm text, pos text, tr text, forms jsonb, expl text, ex jsonb)
  loop
    select * into x from public.lexemes where lower(lemma) = w.old and status = 'PUBLISHED';
    continue when x.id is null;
    continue when x.lemma = w.lemma and x.part_of_speech = w.pos and x.examples = w.ex and x.ukrainian_explanation is not distinct from w.expl;
    if w.lemma <> w.old and exists (select 1 from public.lexemes where lower(lemma) = w.lemma) then
      raise exception 'Лема % уже є в словнику — % не перейменовую', w.lemma, w.old;
    end if;
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', x.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = x.id), 0) + 1,
            to_jsonb(x), 'vocab_a2_fix 2026-11-12: виправлено лему / частину мови (хорватська норма), рішення власника за аудитом A2.');
    update public.lexemes
       set lemma = w.lemma, normalized = w.norm, part_of_speech = w.pos, ukrainian_translation = w.tr,
           ukrainian_explanation = w.expl, forms = w.forms, examples = w.ex, register = null,
           version = coalesce(version, 1) + 1, updated_at = now()
     where id = x.id;
    insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
    values ('lexeme', x.id, 'PUBLISHED', 'PUBLISHED', 'approved', 'human', '[]'::jsonb, 'vocab_a2_fix 2026-11-12: виправлено лему / частину мови (хорватська норма), рішення власника за аудитом A2.' || ' Було: ' || x.lemma || '.');
    v_ren := v_ren + 1;
  end loop;

  -- 2. DEPRECATED: лише запас (не в уроці, не у вправі, без прогресу користувачів)
  if exists (select 1 from public.lexemes lx
              where lower(lx.lemma) in (select jsonb_array_elements_text(v_dep_list)) and lx.status = 'PUBLISHED'
                and (exists (select 1 from public.lesson_items li where li.item_type = 'lexeme' and li.item_id = lx.id)
                     or exists (select 1 from public.exercises ex where ex.lexeme_id = lx.id and ex.status = 'PUBLISHED')
                     or exists (select 1 from public.user_progress up where up.lexeme_id = lx.id)
                     or exists (select 1 from public.srs_reviews sr where sr.lexeme_id = lx.id))) then
    raise exception 'Слово зі списку DEPRECATED стоїть в уроці, у вправі або в повтореннях користувача: %',
      (select string_agg(lx.lemma, ', ') from public.lexemes lx
        where lower(lx.lemma) in (select jsonb_array_elements_text(v_dep_list)) and lx.status = 'PUBLISHED'
          and (exists (select 1 from public.lesson_items li where li.item_type = 'lexeme' and li.item_id = lx.id)
               or exists (select 1 from public.exercises ex where ex.lexeme_id = lx.id and ex.status = 'PUBLISHED')
               or exists (select 1 from public.user_progress up where up.lexeme_id = lx.id)
               or exists (select 1 from public.srs_reviews sr where sr.lexeme_id = lx.id)));
  end if;
  for w in select * from jsonb_to_recordset('[{"old": "apoteka", "std": "ljekarna"}, {"old": "kompjuter", "std": "računalo"}, {"old": "da li govorite engleski", "std": "govorite li engleski"}, {"old": "sistem", "std": "sustav"}, {"old": "dijaloz -> dijalog", "std": "dijalog"}, {"old": "podaci", "std": "podatak"}, {"old": "usluge", "std": "usluga"}, {"old": "družiti", "std": "družiti se"}, {"old": "navići", "std": "naviknuti se"}, {"old": "smijeti", "std": "smjeti"}, {"old": "posati", "std": "poslati"}]'::jsonb) as t(old text, std text)
  loop
    select * into x from public.lexemes where lower(lemma) = w.old and status = 'PUBLISHED';
    continue when x.id is null;
    if not exists (select 1 from public.lexemes where lower(lemma) = w.std and status = 'PUBLISHED') then
      raise exception 'Немає опублікованого стандартного слова % (для %)', w.std, w.old;
    end if;
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', x.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = x.id), 0) + 1,
            to_jsonb(x), 'vocab_a2_fix 2026-11-12: DEPRECATED за рішенням власника — дублікат стандартного слова, яке вже є в словнику.');
    update public.lexemes set status = 'DEPRECATED', version = coalesce(version, 1) + 1, updated_at = now() where id = x.id;
    insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
    values ('lexeme', x.id, 'PUBLISHED', 'DEPRECATED', 'approved', 'human', '[]'::jsonb, 'vocab_a2_fix 2026-11-12: DEPRECATED за рішенням власника — дублікат стандартного слова, яке вже є в словнику.' || ' Стандартно — ' || w.std || '.');
    v_dep := v_dep + 1;
  end loop;

  -- 3. «Регіонально»
  for w in select * from jsonb_to_recordset('[{"lemma": "pomidor", "tr": "помідор (регіонально: Далмація, діалект; стандартно — rajčica)", "expl": "Регіонально (Далмація), діалектне слово. У стандартній хорватській — rajčica."}, {"lemma": "kapula", "tr": "цибуля (регіонально: Далмація, діалект; стандартно — luk)", "expl": "Регіонально (Далмація), діалектне слово. У стандартній хорватській — luk."}, {"lemma": "šugaman", "tr": "рушник (регіонально: Далмація, діалект; стандартно — ručnik)", "expl": "Регіонально (Далмація), діалектне слово. У стандартній хорватській — ručnik."}, {"lemma": "ae", "tr": "так, ага (регіонально: Далмація; сленг)", "expl": "Регіонально (Далмація), сленг: «так, ага». Нейтрально — da."}, {"lemma": "onak", "tr": "ну, типу; якось так (регіонально: Загреб; сленг)", "expl": "Регіонально (Загреб), розмовне слово-паразит (від onako — «так, отак»). Нейтрально — onako."}]'::jsonb) as t(lemma text, tr text, expl text)
  loop
    select * into x from public.lexemes where lower(lemma) = w.lemma and status = 'PUBLISHED';
    continue when x.id is null or (x.ukrainian_translation = w.tr and x.ukrainian_explanation is not distinct from w.expl);
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', x.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = x.id), 0) + 1,
            to_jsonb(x), 'vocab_a2_fix 2026-11-12: позначено «регіонально» за рішенням власника.');
    update public.lexemes set lemma = w.lemma, ukrainian_translation = w.tr, ukrainian_explanation = w.expl,
           register = case when coalesce(register, '') in ('slang', 'regional') then register else 'regional' end,
           version = coalesce(version, 1) + 1, updated_at = now()
     where id = x.id;
    insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
    values ('lexeme', x.id, 'PUBLISHED', 'PUBLISHED', 'approved', 'human', '[]'::jsonb, 'vocab_a2_fix 2026-11-12: позначено «регіонально» за рішенням власника.');
    v_reg := v_reg + 1;
  end loop;

  -- Самоперевірка
  if exists (select 1 from public.lexemes where lower(lemma) in (select jsonb_array_elements_text(v_dep_list)) and status = 'PUBLISHED') then
    raise exception 'Не всі дублікати стали DEPRECATED';
  end if;
  if exists (select 1 from public.lexemes where lower(lemma) in ('utisak', 'talenat', 'dogoditi', 'događati', 'baviti') and status = 'PUBLISHED') then
    raise exception 'Лишилась опублікована стара лема (utisak, talenat, dogoditi, događati, baviti)';
  end if;
  if exists (select 1 from public.lexemes where lower(lemma) in ('klasično', 'moderno') and status = 'PUBLISHED' and part_of_speech <> 'adverb') then
    raise exception 'klasično / moderno — ще не прислівники';
  end if;
  if exists (select 1 from public.lexemes where lower(lemma) in ('pomidor', 'kapula', 'šugaman', 'ae', 'onak') and status = 'PUBLISHED'
              and ukrainian_translation not like '%регіонально%') then
    raise exception 'Не всі регіональні слова мають «регіонально» в перекладі';
  end if;
  if exists (select 1 from public.lesson_items li join public.lexemes lx on lx.id = li.item_id
              where li.item_type = 'lexeme' and lx.status <> 'PUBLISHED') then
    raise exception 'В уроці лишилося неопубліковане слово';
  end if;
  raise notice 'Готово: виправлено лем %, DEPRECATED %, «регіонально» %', v_ren, v_dep, v_reg;
end
$fix$;

commit;
