#!/usr/bin/env python3
"""
Пакет 2026-11-04 за аудитом A0 + A1 (content/reviews/2026-11-04_a0_a1_audit.md, рішення власника 2026-11-04):

  1. 34 базові слова (dobar, vidjeti, čuti, reći, ali, jer, ako, kada… + нові svaki, vrlo) — у списки слів уроків, де вони
     вже звучать у діалогах (slušati, vrlo — у тематичні уроки «Хобі», «Корисні слова»); виправлення перекладів і
     прикладів цих слів (dom — «гуртожиток» → «дім; заклад…», приклади-словосполучення → речення);
  2. 3 нові правила граматики: множина gradovi / stolovi (A0), зміна k, g, h → c, z, s (A1 Lokativ),
     займенники після прийменників kod nas, o tebi (A1 Genitiv);
  3. довші пояснення (150–320 знаків) і 4–5 прикладів у правилах A0 / A1;
  4. мітка cefr слова = рівень уроку, де його вперше вчать (A0 або A1).

  python3 -B scripts/gen_core_words_grammar_20261104.py           →  supabase/data_fixes/20261104_core_words_grammar.sql
  python3 -B scripts/gen_core_words_grammar_20261104.py --report  →  таблиці для звіту носію

Нічого не видаляється: стара версія слова / правила — у content_versions, запис — у content_reviews;
повторний запуск нічого не змінює. Дані — scripts/core_words_grammar_20261104_data.py.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).parent))
import core_words_grammar_20261104_data as D  # noqa: E402
from lexeme_checks import check_example, normalize  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / 'supabase' / 'data_fixes' / '20261104_core_words_grammar.sql'
SOURCE = 'claude_core_words_20261104'
CYR = re.compile(r'[Ѐ-ӿ]')
NOTE_WORD = 'Аудит A0 + A1 2026-11-04: базове слово додано в урок / виправлено переклад чи приклад. Потрібна перевірка носієм.'
NOTE_RULE = 'Аудит A0 + A1 2026-11-04: довше пояснення й приклади / нове правило. Потрібна перевірка носієм.'
NOTE_CEFR = 'Аудит A0 + A1 2026-11-04: cefr = рівень уроку, де слово вперше вчать (рішення власника).'


def q(s) -> str:
    return 'null' if s is None else "'" + str(s).replace("'", "''") + "'"


def qj(v) -> str:
    return q(json.dumps(v, ensure_ascii=False)) + '::jsonb'


# ---------------------------------------------------------------- перевірки даних
def validate() -> list[str]:
    errors = []
    seen = set()
    per_lesson: dict[str, int] = {}
    for w in D.WORDS:
        lemma = w['lemma']
        if lemma in seen:
            errors.append(f'{lemma}: двічі')
        seen.add(lemma)
        if w['lesson'] not in D.LESSONS:
            errors.append(f'{lemma}: невідомий урок {w["lesson"]}')
        per_lesson[w['lesson']] = per_lesson.get(w['lesson'], 0) + 1
        if not CYR.search(w.get('fix_tr') or w['tr']):
            errors.append(f'{lemma}: переклад без кирилиці')
        for ex in w.get('fix_ex') or w['ex']:
            if w.get('fix_ex') or w.get('new'):
                for e in check_example(lemma, ex):
                    errors.append(f'{lemma}: «{ex}» — {e}')
    if len(D.WORDS) != 34:
        errors.append(f'слів {len(D.WORDS)}, а має бути 34 (32 наявні + нові svaki, vrlo)')

    def check_rule(where, expl, examples, need_len=True):
        if expl is not None and need_len and not 150 <= len(expl) <= 400:
            errors.append(f'{where}: пояснення {len(expl)} знаків (150–400)')
        if expl and not CYR.search(expl):
            errors.append(f'{where}: пояснення не українською')
        for hr, ua in examples:
            if CYR.search(hr):
                errors.append(f'{where}: кирилиця в хорватському прикладі «{hr}»')
            if not CYR.search(ua):
                errors.append(f'{where}: переклад прикладу не українською «{ua}»')
            if not re.search(r'[.!?]$', hr) or not re.match(r'^[A-ZČĆĐŠŽ0-9]', hr):
                errors.append(f'{where}: приклад має бути реченням «{hr}»')

    for r in D.NEW_RULES:
        check_rule(f'нове «{r["title"]}»', r['expl'], r['ex'])
        if len(r['ex']) < 4:
            errors.append(f'нове «{r["title"]}»: < 4 прикладів')
    for (topic, title), r in D.RULES.items():
        check_rule(f'{topic} / {title}', r.get('e'), list(r.get('add', [])) + list(r.get('fix', {}).values()))
    return errors


# ---------------------------------------------------------------- SQL
def sql() -> str:
    words = [{'lemma': w['lemma'], 'norm': normalize(w['lemma']), 'pos': w['pos'], 'cefr': w.get('cefr', 'A1'),
              'tr': w['tr'], 'vt': w['vt'], 'forms': w['forms'], 'ex': w['ex'], 'lesson': w['lesson'],
              'fix_tr': w.get('fix_tr'), 'fix_ex': w.get('fix_ex'), 'fix_forms': w.get('fix_forms')} for w in D.WORDS]
    new_rules = [{'topic': r['topic'], 'after': r['after'], 'title': r['title'], 'expl': r['expl'], 'pattern': r['pattern'],
                  'ex': [{'hr': hr, 'ua': ua} for hr, ua in r['ex']]} for r in D.NEW_RULES]
    rules = [{'topic': t, 'title': ti, 'e': r.get('e'),
              'fix': {str(i): {'hr': hr, 'ua': ua} for i, (hr, ua) in r.get('fix', {}).items()},
              'add': [{'hr': hr, 'ua': ua} for hr, ua in r.get('add', [])]} for (t, ti), r in D.RULES.items()]
    lessons_sql = ', '.join(q(x) + '::uuid' for x in D.LESSONS)
    return f"""-- =====================================================================
-- Базові слова в уроки, нові правила граматики, довші пояснення, мітки cefr · 2026-11-04
-- Згенеровано: python3 -B scripts/gen_core_words_grammar_20261104.py (не редагуйте вручну).
-- За аудитом content/reviews/2026-11-04_a0_a1_audit.md і рішеннями власника 2026-11-04.
--
--   1. {len(words)} базові слова (dobar, vidjeti, čuti, reći, trebati, ali, jer, ako, kada…, нові svaki, vrlo) — у списки слів
--      {len(D.LESSONS)} уроків A0 / A1, де вони вже звучать у діалогах; виправлено переклади й приклади цих слів.
--   2. 3 нові правила: gradovi / stolovi (A0 «Rod, množina»), ruka — u ruci (A1 «Lokativ»),
--      kod nas, o tebi (A1 «Genitiv»).
--   3. {len(rules)} правил A0 / A1: довші пояснення (150–320 знаків) і щонайменше 4 приклади.
--   4. cefr кожного слова з уроків = рівень уроку, де його вперше вчать (A0 / A1).
--   Нічого не видаляється. Стара версія слова / правила — у content_versions, запис — у content_reviews.
--   Повторний запуск нічого не змінює. Бета — потрібна перевірка носієм.
-- Після нього тест supabase/tests/core_words_grammar.test.sql має пройти («ALL TESTS PASSED»).
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

-- ---------------------------------------------------------------- 1. Слова → уроки
do $words$
declare
  w record;
  x public.lexemes%rowtype;
  v_ord int;
  v_items int := 0;
  v_fixed int := 0;
begin
  if (select count(*) from public.lessons where id in ({lessons_sql}) and status = 'PUBLISHED') <> {len(D.LESSONS)} then
    raise exception 'Не всі {len(D.LESSONS)} уроків A0 / A1 є серед опублікованих — спершу пакети curriculum_a0_v4 / a1_v3';
  end if;
  for w in select * from jsonb_to_recordset({qj(words)})
      as t(lemma text, norm text, pos text, cefr text, tr text, vt text, forms jsonb, ex jsonb, lesson uuid,
           fix_tr text, fix_ex jsonb, fix_forms jsonb)
  loop
    -- у робочій базі слова вже є (крім svaki, vrlo); у локальній / CI — створюються
    insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type,
                                forms, examples, status, source)
    values (w.lemma, w.norm, 'hr', w.pos, w.cefr, w.tr, w.vt, w.forms, w.ex, 'PUBLISHED', '{SOURCE}')
    on conflict do nothing;
    select * into x from public.lexemes where lower(lemma) = lower(w.lemma);
    if x.id is null or x.status <> 'PUBLISHED' then
      raise exception 'Слово % не опубліковане — перевірте словник', w.lemma;
    end if;
    -- виправлення перекладу / прикладів / форм
    if (w.fix_tr is not null and x.ukrainian_translation is distinct from w.fix_tr)
       or (w.fix_ex is not null and x.examples is distinct from w.fix_ex)
       or (w.fix_forms is not null and x.forms is distinct from w.fix_forms) then
      insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
      values ('lexeme', x.id,
              coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = x.id), 0) + 1,
              to_jsonb(x), 'core_words_20261104: переклад / приклади / форми — стара версія');
      update public.lexemes set
        ukrainian_translation = coalesce(w.fix_tr, ukrainian_translation),
        examples = coalesce(w.fix_ex, examples),
        forms = coalesce(w.fix_forms, forms),
        version = coalesce(version, 1) + 1
      where id = x.id;
      insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
      values ('lexeme', x.id, x.status, x.status, 'auto_passed', 'ai',
              jsonb_build_array(jsonb_build_object('old_tr', x.ukrainian_translation, 'new_tr', w.fix_tr,
                                                   'old_ex', x.examples, 'new_ex', w.fix_ex)), '{NOTE_WORD}');
      v_fixed := v_fixed + 1;
    end if;
    -- у список слів уроку (після наявних елементів)
    if not exists (select 1 from public.lesson_items where lesson_id = w.lesson and item_type = 'lexeme' and item_id = x.id) then
      select coalesce(max(order_index), 0) + 1 into v_ord from public.lesson_items where lesson_id = w.lesson;
      insert into public.lesson_items (id, lesson_id, item_type, item_id, order_index, required, target_skill)
      values (gen_random_uuid(), w.lesson, 'lexeme', x.id, v_ord, true, 'vocabulary');
      v_items := v_items + 1;
    end if;
  end loop;
  raise notice 'Слова: додано в уроки %, виправлено %', v_items, v_fixed;
end
$words$;

-- ---------------------------------------------------------------- 2. Нові правила граматики
do $newrules$
declare
  r record;
  v_topic uuid;
  v_after int;
  v_new int := 0;
begin
  for r in select * from jsonb_to_recordset({qj(new_rules)})
      as t(topic text, after text, title text, expl text, pattern text, ex jsonb)
  loop
    select id into v_topic from public.grammar_topics
     where title_hr = r.topic and cefr in ('A0', 'A1') and status = 'PUBLISHED';
    if v_topic is null then raise exception 'Тему граматики «%» не знайдено', r.topic; end if;
    if exists (select 1 from public.grammar_rules where topic_id = v_topic and title_ua = r.title) then
      continue;
    end if;
    if r.after is null then
      select coalesce(max(order_index), 0) into v_after from public.grammar_rules where topic_id = v_topic;
    else
      select order_index into v_after from public.grammar_rules where topic_id = v_topic and title_ua = r.after;
      if v_after is null then raise exception 'У темі «%» немає правила «%»', r.topic, r.after; end if;
      update public.grammar_rules set order_index = order_index + 1 where topic_id = v_topic and order_index > v_after;
    end if;
    insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)
    values (gen_random_uuid(), v_topic, r.title, r.expl, r.pattern, r.ex, v_after + 1);
    v_new := v_new + 1;
  end loop;
  raise notice 'Нових правил: %', v_new;
end
$newrules$;

-- ---------------------------------------------------------------- 3. Довші пояснення й приклади
do $rules$
declare
  r record;
  g public.grammar_rules%rowtype;
  v_ex jsonb;
  k text;
  a jsonb;
  v_changed int := 0;
begin
  for r in select * from jsonb_to_recordset({qj(rules)}) as t(topic text, title text, e text, fix jsonb, "add" jsonb)
  loop
    -- тему, якої немає в цій базі (локальна / CI без базових тем), пропускаємо; у робочій базі всі є —
    -- це перевіряє самоперевірка нижче (жодного правила A0 / A1 < 150 знаків чи < 4 прикладів)
    if not exists (select 1 from public.grammar_topics where title_hr = r.topic and cefr in ('A0', 'A1') and status = 'PUBLISHED') then
      raise notice 'Теми «%» немає — пропущено', r.topic;
      continue;
    end if;
    g := null;
    select gr.* into g from public.grammar_rules gr join public.grammar_topics gt on gt.id = gr.topic_id
     where gt.title_hr = r.topic and gt.cefr in ('A0', 'A1') and gt.status = 'PUBLISHED' and gr.title_ua = r.title;
    if g.id is null then raise exception 'Правило «%» / «%» не знайдено', r.topic, r.title; end if;
    v_ex := coalesce(g.examples, '[]'::jsonb);
    for k in select jsonb_object_keys(r.fix) loop
      v_ex := jsonb_set(v_ex, array[k], r.fix -> k);
    end loop;
    for a in select * from jsonb_array_elements(r."add") loop
      if not exists (select 1 from jsonb_array_elements(v_ex) e where e ->> 'hr' = a ->> 'hr') then
        v_ex := v_ex || jsonb_build_array(a);
      end if;
    end loop;
    if v_ex is distinct from g.examples or (r.e is not null and r.e is distinct from g.explanation_ua) then
      insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
      values ('grammar_rule', g.id,
              coalesce((select max(version) from public.content_versions where entity_type = 'grammar_rule' and entity_id = g.id), 0) + 1,
              to_jsonb(g), 'core_words_20261104: довше пояснення й приклади — стара версія');
      update public.grammar_rules set explanation_ua = coalesce(r.e, explanation_ua), examples = v_ex where id = g.id;
      insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
      values ('grammar_rule', g.id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, '{NOTE_RULE}');
      v_changed := v_changed + 1;
    end if;
  end loop;
  raise notice 'Оновлено правил: %', v_changed;
end
$rules$;

-- ---------------------------------------------------------------- 4. cefr = рівень першого уроку
do $cefr$
declare
  x record;
  v_changed int := 0;
begin
  for x in
    select l.*, f.lv from public.lexemes l
    join (select li.item_id, min(le.level_code) lv from public.lesson_items li
            join public.lessons le on le.id = li.lesson_id and le.status = 'PUBLISHED' and le.level_code in ('A0', 'A1')
           where li.item_type = 'lexeme' group by li.item_id) f on f.item_id = l.id
    where l.cefr is distinct from f.lv
  loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', x.id,
            coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = x.id), 0) + 1,
            to_jsonb(x) - 'lv', 'core_words_20261104: cefr ' || coalesce(x.cefr, 'null') || ' → ' || x.lv || ' — стара версія');
    update public.lexemes set cefr = x.lv, version = coalesce(version, 1) + 1 where id = x.id;
    v_changed := v_changed + 1;
  end loop;
  if v_changed > 0 then
    insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
    select 'lexeme', id, status, status, 'auto_passed', 'script', '[]'::jsonb, '{NOTE_CEFR}'
      from public.lexemes l
     where exists (select 1 from public.content_versions v where v.entity_type = 'lexeme' and v.entity_id = l.id
                     and v.change_reason like 'core_words_20261104: cefr%')
       and not exists (select 1 from public.content_reviews r where r.entity_type = 'lexeme' and r.entity_id = l.id
                         and r.notes = '{NOTE_CEFR}');
  end if;
  raise notice 'Мітки cefr: змінено %', v_changed;
end
$cefr$;

-- ---------------------------------------------------------------- Самоперевірка (інакше — усе відкочується)
do $$
declare v_bad int;
begin
  select count(*) into v_bad from jsonb_array_elements_text({qj([w['lemma'] for w in D.WORDS])}) w
   where not exists (select 1 from public.lesson_items li join public.lexemes x on x.id = li.item_id
                     join public.lessons le on le.id = li.lesson_id and le.status = 'PUBLISHED'
                      where li.item_type = 'lexeme' and lower(x.lemma) = w);
  if v_bad > 0 then raise exception 'Базових слів не в уроках: %', v_bad; end if;
  select count(*) into v_bad from (select li.lesson_id from public.lesson_items li join public.lessons le on le.id = li.lesson_id
      where li.item_type = 'lexeme' and le.id in ({lessons_sql}) group by 1 having count(*) > 25) s;
  if v_bad > 0 then raise exception 'Уроків з > 25 словами: %', v_bad; end if;
  select count(*) into v_bad from public.grammar_rules r join public.grammar_topics g on g.id = r.topic_id
   where g.cefr in ('A0', 'A1') and g.status = 'PUBLISHED'
     and (length(r.explanation_ua) < 150 or jsonb_array_length(coalesce(r.examples, '[]'::jsonb)) < 4);
  if v_bad > 0 then raise exception 'Правил A0 / A1 з коротким поясненням або < 4 прикладами: %', v_bad; end if;
  select count(*) into v_bad from public.lexemes l
    join (select li.item_id, min(le.level_code) lv from public.lesson_items li
            join public.lessons le on le.id = li.lesson_id and le.status = 'PUBLISHED' and le.level_code in ('A0', 'A1')
           where li.item_type = 'lexeme' group by li.item_id) f on f.item_id = l.id
   where l.cefr is distinct from f.lv;
  if v_bad > 0 then raise exception 'Слів, у яких cefr ≠ рівень уроку: %', v_bad; end if;
  raise notice 'Готово: 34 базові слова в уроках, правила A0 / A1 — ≥ 150 знаків і ≥ 4 приклади, cefr = рівень уроку';
end $$;

commit;
"""


def report() -> str:
    lines = ['### Слова в уроки', '', '| Урок | Слово | Переклад | Приклади |', '|---|---|---|---|']
    for w in D.WORDS:
        lines.append(f"| {D.LESSONS[w['lesson']]} | *{w['lemma']}*{' (нове)' if w.get('new') else ''} | "
                     f"{w.get('fix_tr') or w['tr']} | {' / '.join(w.get('fix_ex') or w['ex'])} |")
    lines += ['', '### Нові правила', '']
    for r in D.NEW_RULES:
        lines += [f"**{r['topic']} → {r['title']}**", '', r['expl'], '']
        lines += [f'- *{hr}* — {ua}' for hr, ua in r['ex']] + ['']
    lines += ['### Оновлені правила (нові приклади)', '', '| Тема | Правило | Нове пояснення? | Нові / виправлені приклади |', '|---|---|---|---|']
    for (t, ti), r in D.RULES.items():
        exs = [f'*{hr}* — {ua}' for hr, ua in list(r.get('fix', {}).values()) + list(r.get('add', []))]
        lines.append(f"| {t} | {ti} | {'так' if r.get('e') else '—'} | {'; '.join(exs)} |")
    return '\n'.join(lines)


def main():
    errors = validate()
    if errors:
        raise SystemExit('Перевірка не пройдена:\n' + '\n'.join(errors))
    if '--report' in sys.argv:
        print(report())
        return
    OUT.write_text(sql(), encoding='utf-8')
    print(f'{OUT.relative_to(ROOT)}: {len(OUT.read_bytes()) // 1024} КБ; слів {len(D.WORDS)}, нових правил {len(D.NEW_RULES)}, правил {len(D.RULES)}')


if __name__ == '__main__':
    main()
