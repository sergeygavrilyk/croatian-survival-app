-- =====================================================================
-- Стандартні відповідники (standard_lexeme_id) і чистка позначок у перекладах · 2026-11-13
-- Згенеровано: python3 -B scripts/gen_lexeme_standard_links_20261113.py (не редагуйте вручну).
-- Модель — docs/LEARNING_SPEC.md §18; останній крок «перед B1» плану маркування (docs/PROJECT_STATE.md).
-- Потрібні M24 (standard_lexeme_id) і M25 (мітки обов'язкові).
-- Що робить:
--   1. 18 зв'язків «розмовне / регіональне → стандартне» (pomidor → rajčica, kila → kilogram, tegla → staklenka…).
--      Зв'язок — лише до PUBLISHED-слова з register = standard і regionality = general.
--   2. 13 перекладів без позначок, які дублюють мітки («помідор (регіонально: Далмація…; стандартно — rajčica)» →
--      «помідор»); переклад міняється, лише якщо він дорівнює старому. Пояснення (ukrainian_explanation) не змінює.
--   3. 1 регістр: kesa standard → colloquial (у перекладі було «регіонально»).
--   4. Вправи: старий переклад у відповіді, варіантах чи питанні («…«кілограм (розм.)»?») → новий.
--   Кожна зміна — стара версія в content_versions, запис у content_reviews; копія рядка до зміни — у
--   backup.lexemes_standard_links_20261113 / backup.exercises_standard_links_20261113. Повторний запуск нічого не змінює.
-- Звіт: content/reviews/2026-11-13_lexeme_standard_links.md. Тест: supabase/tests/lexeme_standard_links.test.sql.
-- Очікуване повідомлення (робоча база): «Готово: слів змінено 22, зв'язків 18, перекладів 13,
--   регістр 1, вправ 4, уже було 0, немає в базі 0, немає відповідника 0, переклад змінено раніше 0».
-- =====================================================================

begin;

create schema if not exists backup;
create table if not exists backup.lexemes_standard_links_20261113 as select * from public.lexemes where false;
create table if not exists backup.exercises_standard_links_20261113 as select * from public.exercises where false;

do $fix$
declare
  w record;
  x public.lexemes%rowtype;
  e public.exercises%rowtype;
  v_std uuid;
  v_new_std uuid;
  v_tr text;
  v_reg text;
  v_opts jsonb;
  v_changed int := 0;
  v_links int := 0;
  v_tr_n int := 0;
  v_reg_n int := 0;
  v_ex int := 0;
  v_same int := 0;
  v_missing int := 0;
  v_std_missing int := 0;
  v_tr_other int := 0;
  v_bad int;
  c_reason constant text := 'lexeme_standard_links 2026-11-13: стандартний відповідник (standard_lexeme_id) і переклад без позначок, які дублюють мітки (LEARNING_SPEC §18); скрипт scripts/gen_lexeme_standard_links_20261113.py';
begin
  if not exists (select 1 from information_schema.columns where table_schema = 'public' and table_name = 'lexemes'
                   and column_name = 'standard_lexeme_id') then
    raise exception 'Спершу міграція M24 (20261113100000_m24_lexeme_labels.sql): колонки standard_lexeme_id ще немає';
  end if;

  for w in select * from jsonb_to_recordset('[{"k": "pomidor", "std": "rajčica", "old_tr": "помідор (регіонально: Далмація, діалект; стандартно — rajčica)", "new_tr": "помідор", "reg": null, "why": "далматинське слово; регіон і регістр — у мітках"}, {"k": "kapula", "std": "luk", "old_tr": "цибуля (регіонально: Далмація, діалект; стандартно — luk)", "new_tr": "цибуля", "reg": null, "why": "далматинське слово; регіон і регістр — у мітках"}, {"k": "šugaman", "std": "ručnik", "old_tr": "рушник (регіонально: Далмація, діалект; стандартно — ručnik)", "new_tr": "рушник", "reg": null, "why": "далматинське слово; регіон і регістр — у мітках"}, {"k": "ae", "std": "da", "old_tr": "так, ага (регіонально: Далмація; сленг)", "new_tr": "так, ага", "reg": null, "why": "далматинський сленг; нейтрально — da (пояснення)"}, {"k": "onak", "std": null, "old_tr": "ну, типу; якось так (регіонально: Загреб; сленг)", "new_tr": "ну, типу; якось так", "reg": null, "why": "загребський сленг; onako в словнику немає — відповідник лише в поясненні"}, {"k": "kila", "std": "kilogram", "old_tr": "кілограм (розм.)", "new_tr": "кілограм", "reg": null, "why": "розмовне — у мітці colloquial"}, {"k": "gablec", "std": null, "old_tr": "гарячий обід на роботі (загреб.)", "new_tr": "гарячий обід на роботі", "reg": null, "why": "загребське слово — у мітці regionality = Zagreb; відповідника одним словом немає"}, {"k": "kesa", "std": "vrećica", "old_tr": "пакет (регіонально)", "new_tr": "пакет", "reg": "colloquial", "why": "у перекладі «регіонально», мітка була standard → colloquial; стандартно — vrećica; регіон — носію"}, {"k": "dućan", "std": null, "old_tr": "магазин (розмовно)", "new_tr": "магазин", "reg": null, "why": "dućan — стандартне слово (мітка standard); позначка «розмовно» суперечила мітці"}, {"k": "bilježnik", "std": null, "old_tr": "нотаріус (розм.)", "new_tr": "нотаріус", "reg": null, "why": "(javni) bilježnik — офіційний термін (мітка standard); позначка «розм.» суперечила мітці"}, {"k": "apoteka", "std": "ljekarna", "old_tr": "аптека (розмовне; стандартно — ljekarna)", "new_tr": "аптека", "reg": null, "why": "DEPRECATED; розмовне — у мітці, відповідник — зв''язок"}, {"k": "kompjuter", "std": "računalo", "old_tr": "комп’ютер (розмовне; стандартно — računalo)", "new_tr": "комп’ютер", "reg": null, "why": "DEPRECATED; розмовне — у мітці, відповідник — зв''язок"}, {"k": "da li govorite engleski", "std": "govorite li engleski", "old_tr": "чи розмовляєте ви англійською (сербська конструкція; хорватською — Govorite li engleski?)", "new_tr": "чи розмовляєте ви англійською", "reg": null, "why": "DEPRECATED; «сербська конструкція» — у поясненні, відповідник — зв''язок"}, {"k": "cura", "std": "djevojka", "old_tr": null, "new_tr": null, "reg": null, "why": "розмовне «дівчина»"}, {"k": "pegla", "std": "glačalo", "old_tr": null, "new_tr": null, "reg": null, "why": "розмовне (германізм)"}, {"k": "tastatura", "std": "tipkovnica", "old_tr": null, "new_tr": null, "reg": null, "why": "розмовне"}, {"k": "tegla", "std": "staklenka", "old_tr": null, "new_tr": null, "reg": null, "why": "розмовне"}, {"k": "kusur", "std": "ostatak", "old_tr": null, "new_tr": null, "reg": null, "why": "розмовне (туркізм) «решта»"}, {"k": "mušterija", "std": "kupac", "old_tr": null, "new_tr": null, "reg": null, "why": "розмовне (туркізм) «клієнт, покупець»"}, {"k": "mail", "std": "e-pošta", "old_tr": null, "new_tr": null, "reg": null, "why": "розмовне (англіцизм)"}, {"k": "kvart", "std": "gradska četvrt", "old_tr": null, "new_tr": null, "reg": null, "why": "розмовне «район міста»"}, {"k": "marenda", "std": "užina", "old_tr": null, "new_tr": null, "reg": null, "why": "далматинське «перекус»"}]'::jsonb)
             as t(k text, std text, old_tr text, new_tr text, reg text, why text)
  loop
    select * into x from public.lexemes where lower(lemma) = w.k;
    if x.id is null then
      v_missing := v_missing + 1;
      continue;
    end if;

    -- стандартний відповідник
    v_std := null;
    if w.std is not null then
      select id into v_std from public.lexemes
       where lower(lemma) = w.std and status = 'PUBLISHED' and register = 'standard' and regionality = 'general';
      if v_std is null then
        v_std_missing := v_std_missing + 1;
      end if;
    end if;
    v_new_std := coalesce(v_std, x.standard_lexeme_id);

    -- переклад: лише якщо він досі той, що в знімку
    v_tr := x.ukrainian_translation;
    if w.new_tr is not null then
      if x.ukrainian_translation = w.old_tr then
        v_tr := w.new_tr;
      elsif x.ukrainian_translation is distinct from w.new_tr then
        v_tr_other := v_tr_other + 1;
      end if;
    end if;

    -- регістр: лише якщо слово ще standard
    v_reg := x.register;
    if w.reg is not null and x.register = 'standard' then
      v_reg := w.reg;
    end if;

    if v_new_std is not distinct from x.standard_lexeme_id and v_tr is not distinct from x.ukrainian_translation
       and v_reg is not distinct from x.register then
      v_same := v_same + 1;
      continue;
    end if;

    insert into backup.lexemes_standard_links_20261113 select * from public.lexemes where id = x.id;
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', x.id, coalesce((select max(version) from public.content_versions
                                      where entity_type = 'lexeme' and entity_id = x.id), 0) + 1,
            to_jsonb(x), c_reason || ' — ' || w.why);
    update public.lexemes
       set standard_lexeme_id = v_new_std, ukrainian_translation = v_tr, register = v_reg,
           version = coalesce(version, 1) + 1, updated_at = now()
     where id = x.id;
    insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
    values ('lexeme', x.id, x.status, x.status, 'auto_passed', 'script',
            jsonb_build_array(jsonb_build_object('standard_lemma', w.std, 'ukrainian_translation', v_tr, 'register', v_reg)),
            c_reason || ' — ' || w.why);
    v_changed := v_changed + 1;
    if v_new_std is distinct from x.standard_lexeme_id then v_links := v_links + 1; end if;
    if v_reg is distinct from x.register then v_reg_n := v_reg_n + 1; end if;

    -- вправи зі старим перекладом
    if v_tr is distinct from x.ukrainian_translation then
      v_tr_n := v_tr_n + 1;
      for e in select * from public.exercises ex
                where ex.correct_answer = x.ukrainian_translation
                   or (jsonb_typeof(ex.options) = 'array' and ex.options ? x.ukrainian_translation)
                   or ex.question_text like '%«' || x.ukrainian_translation || '»%'
      loop
        v_opts := e.options;
        if jsonb_typeof(e.options) = 'array' then
          select jsonb_agg(case when o.value = to_jsonb(x.ukrainian_translation) then to_jsonb(v_tr) else o.value end
                           order by o.ord)
            into v_opts
            from jsonb_array_elements(e.options) with ordinality as o(value, ord);
          if (select count(*) from jsonb_array_elements(v_opts)) <> (select count(distinct value) from jsonb_array_elements(v_opts)) then
            raise exception 'Вправа %: після заміни перекладу «%» варіанти повторюються', e.id, x.ukrainian_translation;
          end if;
        end if;
        insert into backup.exercises_standard_links_20261113 select * from public.exercises where id = e.id;
        insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
        values ('exercise', e.id, coalesce((select max(version) from public.content_versions
                                            where entity_type = 'exercise' and entity_id = e.id), 0) + 1,
                to_jsonb(e), c_reason || ' — переклад слова ' || x.lemma || ' без позначки');
        update public.exercises
           set correct_answer = case when correct_answer = x.ukrainian_translation then v_tr else correct_answer end,
               options = v_opts,
               question_text = replace(question_text, '«' || x.ukrainian_translation || '»', '«' || v_tr || '»')
         where id = e.id;
        insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
        values ('exercise', e.id, e.status, e.status, 'auto_passed', 'script', '[]'::jsonb,
                c_reason || ' — переклад слова ' || x.lemma || ' без позначки');
        v_ex := v_ex + 1;
      end loop;
    end if;
  end loop;

  -- Самоперевірка: зв'язок — лише «нестандартне → стандартне опубліковане»
  select count(*) into v_bad
    from public.lexemes l join public.lexemes s on s.id = l.standard_lexeme_id
   where s.status <> 'PUBLISHED' or s.register <> 'standard' or s.regionality <> 'general'
      or (l.register = 'standard' and l.regionality = 'general');
  if v_bad > 0 then
    raise exception 'Зв''язків standard_lexeme_id не за правилом: %', v_bad;
  end if;
  raise notice 'Готово: слів змінено %, зв''язків %, перекладів %, регістр %, вправ %, уже було %, немає в базі %, немає відповідника %, переклад змінено раніше %',
    v_changed, v_links, v_tr_n, v_reg_n, v_ex, v_same, v_missing, v_std_missing, v_tr_other;
end
$fix$;

commit;
