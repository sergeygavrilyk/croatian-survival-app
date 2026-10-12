#!/usr/bin/env python3
"""
Генератор SQL для програми A0 і каркаса A1–B2.

  python3 scripts/gen_curriculum_a0.py  →  supabase/data_fixes/20261012_curriculum_a0_v1.sql

Дані — у scripts/curriculum_a0_data.py. Скрипт спершу перевіряє дані
(хорватський текст без кирилиці, вправи сумісні з LessonView тощо) і зупиняється
з помилкою, якщо щось не так.

SQL ідемпотентний: усі id детерміновані (uuid5), повторний запуск нічого не дублює.
Потребує міграції M10 (lessons.order_index).
"""
import json
import random
import re
import sys
import uuid
from pathlib import Path

sys.dont_write_bytecode = True  # без __pycache__ у репозиторії
sys.path.insert(0, str(Path(__file__).parent))
import curriculum_a0_data as D  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / 'supabase' / 'data_fixes' / '20261012_curriculum_a0_v1.sql'
SOURCE = 'claude_curriculum_v1'
NS = uuid.UUID('6f1c7a52-9a43-4b0e-9d1e-0c2a0a0a0a01')
REVIEW_NOTE = 'Бета: опубліковано за рішенням власника 2026-10-12 (curriculum_a0_v1). Потрібна перевірка носієм.'

SITUATIONS = set(re.findall(r"code: '([a-z_]+)'", (ROOT / 'lib' / 'situations.ts').read_text(encoding='utf-8')))
CYR = re.compile(r'[Ѐ-ӿ]')
LESSON_TYPES = {'fill': 'fill_in_the_blank', 'build': 'sentence_builder', 'listen': 'listening'}
TARGET_SKILL = {'fill': 'reading', 'build': 'writing', 'listen': 'listening'}

errors: list[str] = []


def uid(*parts) -> str:
    return str(uuid.uuid5(NS, ':'.join(str(p) for p in parts)))


def q(s) -> str:
    """SQL-літерал."""
    if s is None:
        return 'null'
    return "'" + str(s).replace("'", "''") + "'"


def qj(v) -> str:
    return q(json.dumps(v, ensure_ascii=False)) + '::jsonb'


# ---------------------------------------------------------------- перевірки
def check_hr(text: str, where: str):
    if not text or not text.strip():
        errors.append(f'{where}: порожній хорватський текст')
    elif CYR.search(text):
        errors.append(f'{where}: кирилиця в хорватському тексті: {text!r}')


def check_ua(text: str, where: str):
    if not text or not CYR.search(text):
        errors.append(f'{where}: український текст без кирилиці: {text!r}')


def shuffled(items: list[str], seed: str) -> list[str]:
    """Детерміноване перемішування, яке гарантовано відрізняється від оригіналу."""
    if len(set(items)) < 2:
        return list(items)
    for n in range(50):
        out = list(items)
        random.Random(f'{seed}:{n}').shuffle(out)
        if out != items:
            return out
    return list(reversed(items))


def tokens(sentence: str, where: str) -> list[str]:
    toks = sentence.split(' ')
    if any(t == '' for t in toks):
        errors.append(f'{where}: подвійний пробіл у {sentence!r}')
    if len(toks) != len(set(toks)):
        errors.append(f'{where}: слова повторюються (LessonView так не вміє): {sentence!r}')
    if len(toks) < 2:
        errors.append(f'{where}: замало слів для вправи: {sentence!r}')
    return toks


def validate():
    for key, g in D.GRAMMAR_A0.items():
        w = f'grammar[{key}]'
        check_ua(g['title_ua'], w)
        check_hr(g['title_hr'], w)
        check_ua(g['description'], w)
        if not g['rules']:
            errors.append(f'{w}: немає правил')
        for i, (title, expl, pattern, examples) in enumerate(g['rules'], 1):
            if not title.strip():
                errors.append(f'{w}.rule{i}: порожня назва')
            check_ua(expl, f'{w}.rule{i}')
            if not examples:
                errors.append(f'{w}.rule{i}: немає прикладів')
            for hr, ua in examples:
                check_ua(ua, f'{w}.rule{i}.example')
                # приклад може містити українське слово в лапках («хліб») — перевіряємо без нього
                check_hr(re.sub(r'«[^»]*»', '', hr), f'{w}.rule{i}.example')

    used_grammar = set()
    orders = [m['order'] for m in D.MODULES_A0]
    if orders != list(range(1, 11)):
        errors.append(f'модулі A0 мають бути 1..10, а є {orders}')
    lesson_count = 1  # урок 1 уже є в базі
    for m in D.MODULES_A0:
        mw = f"A0.{m['order']}"
        if not m.get('existing'):
            check_hr(m['title_hr'], mw)
            check_ua(m['description'], mw)
            ut_ua, ut_hr, objectives = m['unit']
            check_ua(ut_ua, mw + '.unit')
            check_hr(ut_hr, mw + '.unit')
            for o in objectives:
                check_ua(o, mw + '.unit.objective')
        expected = 2 if m.get('existing') else 3
        if len(m['lessons']) != expected:
            errors.append(f'{mw}: очікується {expected} уроки, а є {len(m["lessons"])}')
        for li, lesson in enumerate(m['lessons'], 1):
            lesson_count += 1
            lw = f'{mw}.L{li}'
            t_ua, t_hr, objectives, situation, dialog, lemmas, gkey, exercises = lesson
            check_ua(t_ua, lw)
            check_hr(t_hr, lw)
            for o in objectives:
                check_ua(o, lw + '.objective')
            if situation not in SITUATIONS:
                errors.append(f'{lw}: невідома ситуація {situation!r}')
            d_ua, d_hr, turns = dialog
            check_ua(d_ua, lw + '.dialog')
            check_hr(d_hr, lw + '.dialog')
            if len(turns) < 4:
                errors.append(f'{lw}: діалог коротший за 4 репліки')
            for speaker, hr, ua in turns:
                check_hr(speaker, lw + '.speaker')
                check_hr(hr, lw + '.turn')
                check_ua(ua, lw + '.turn')
            if not (4 <= len(lemmas) <= 12):
                errors.append(f'{lw}: слів у уроці {len(lemmas)} (має бути 4–12)')
            if len(set(x.lower() for x in lemmas)) != len(lemmas):
                errors.append(f'{lw}: слова повторюються')
            if gkey is not None:
                if gkey not in D.GRAMMAR_A0:
                    errors.append(f'{lw}: невідома граматика {gkey!r}')
                used_grammar.add(gkey)
            kinds = [e[0] for e in exercises]
            if sorted(kinds) != ['build', 'fill', 'listen']:
                errors.append(f'{lw}: потрібні рівно fill + build + listen, а є {kinds}')
            for ei, ex in enumerate(exercises, 1):
                ew = f'{lw}.ex{ei}'
                if ex[0] == 'fill':
                    _, question, answer, distractors = ex
                    if len(distractors) != 3:
                        errors.append(f'{ew}: потрібно 3 дистрактори')
                    opts = [answer, *distractors]
                    if len(set(opts)) != 4:
                        errors.append(f'{ew}: варіанти повторюються {opts}')
                    if not question.strip():
                        errors.append(f'{ew}: порожнє питання')
                elif ex[0] == 'build':
                    _, hint, sentence = ex
                    check_ua(hint, ew)
                    check_hr(sentence, ew)
                    tokens(sentence, ew)
                elif ex[0] == 'listen':
                    _, sentence = ex
                    check_hr(sentence, ew)
                    tokens(sentence, ew)
                else:
                    errors.append(f'{ew}: невідомий тип {ex[0]!r}')
    if lesson_count != 30:
        errors.append(f'A0 має 30 уроків, а виходить {lesson_count}')
    unused = set(D.GRAMMAR_A0) - used_grammar
    if unused:
        errors.append(f'граматика без уроків: {sorted(unused)}')

    for lemma, norm, ua, pos, vtype, forms, example in D.NEW_LEXEMES:
        check_hr(lemma, f'lexeme {lemma}')
        check_ua(ua, f'lexeme {lemma}')
        check_hr(example, f'lexeme {lemma}')
        if vtype not in ('core', 'function_word', 'formulaic', 'collocation', 'chunk'):
            errors.append(f'lexeme {lemma}: vocabulary_type {vtype!r}')

    for level, mods in D.SKELETON_MODULES.items():
        for ua, hr in mods:
            check_ua(ua, f'skeleton {level}')
            check_hr(hr, f'skeleton {level}')
    for level, topics in D.SKELETON_GRAMMAR.items():
        for ua, hr in topics:
            check_ua(ua, f'skeleton grammar {level}')
            check_hr(hr, f'skeleton grammar {level}')


# ---------------------------------------------------------------- SQL
def grammar_sql(out: list[str]):
    out.append('-- 2. Граматика A0 (PUBLISHED, з правилами)')
    for key, g in D.GRAMMAR_A0.items():
        gid = uid('grammar', 'A0', key)
        out.append(
            'insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)\n'
            f"select {q(gid)}, 'A0', {q(g['title_ua'])}, {q(g['title_hr'])}, {q(g['description'])}, 'PUBLISHED'\n"
            f"where not exists (select 1 from public.grammar_topics where cefr = 'A0' and title_ua = {q(g['title_ua'])});"
        )
        for i, (title, expl, pattern, examples) in enumerate(g['rules'], 1):
            ex = [{'hr': hr, 'ua': ua} for hr, ua in examples]
            out.append(
                'insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)\n'
                f"select {q(uid('grammar_rule', 'A0', key, i))}, {q(gid)}, {q(title)}, {q(expl)}, {q(pattern)}, {qj(ex)}, {i}\n"
                f'where exists (select 1 from public.grammar_topics where id = {q(gid)})\n'
                'on conflict (id) do nothing;'
            )
        out.append(
            'insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)\n'
            f"select 'grammar_topic', {q(gid)}, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, {q(REVIEW_NOTE)}\n"
            f'where exists (select 1 from public.grammar_topics where id = {q(gid)})\n'
            f"  and not exists (select 1 from public.content_reviews where entity_id = {q(gid)} and notes = {q(REVIEW_NOTE)});"
        )
    out.append('')


def lexemes_sql(out: list[str]):
    out.append('-- 1. Нові слова (яких ще немає у словнику)')
    for lemma, norm, ua, pos, vtype, forms, example in D.NEW_LEXEMES:
        out.append(
            'insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)\n'
            f"values ({q(lemma)}, {q(norm)}, 'hr', {q(pos)}, 'A0', {q(ua)}, {q(vtype)}, {qj(forms)}, {qj([example])}, 'PUBLISHED', {q(SOURCE)})\n"
            'on conflict do nothing;'
        )
    out.append('')


def modules_sql(out: list[str]):
    out.append('-- 3. Модулі A0.2–A0.10 і їхні юніти (PUBLISHED)')
    for m in D.MODULES_A0:
        if m.get('existing'):
            continue
        n = m['order']
        mid = uid('module', 'A0', n)
        out.append(
            'insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)\n'
            f"values ({q(mid)}, 'A0', {q(f'Модуль A0.{n} — ' + m['title_ua'])}, {q(f'Modul A0.{n} — ' + m['title_hr'])}, {q(m['description'])}, {n}, 'PUBLISHED')\n"
            'on conflict do nothing;'
        )
        ut_ua, ut_hr, objectives = m['unit']
        out.append(
            'insert into public.units (id, module_id, title_ua, title_hr, objectives, order_index, status)\n'
            f"select {q(uid('unit', 'A0', n, 1))}, m.id, {q(ut_ua)}, {q(ut_hr)}, {qj(objectives)}, 1, 'PUBLISHED'\n"
            f"from public.modules m where m.level_code = 'A0' and m.order_index = {n}\n"
            'on conflict do nothing;'
        )
    out.append('')


def lesson_sql(out: list[str], module_order: int, lesson_order: int, number: int, lesson):
    t_ua, t_hr, objectives, situation, dialog, lemmas, gkey, exercises = lesson
    lid = uid('lesson', 'A0', module_order, lesson_order)
    d_ua, d_hr, turns = dialog
    tag = f'A0.{module_order} · урок {number}'
    s = []
    s.append(f'-- {tag}: {t_ua}')
    s.append('do $$')
    s.append('declare')
    s.append('  v_unit uuid;')
    s.append(f'  v_lesson constant uuid := {q(lid)};')
    s.append('  v_id uuid;')
    s.append('begin')
    s.append('  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id')
    s.append(f"   where m.level_code = 'A0' and m.order_index = {module_order} and u.order_index = 1;")
    s.append(f"  if v_unit is null then raise exception 'Немає юніта для модуля A0.{module_order}'; end if;")
    s.append('  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;')
    s.append(f'  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = {lesson_order}) then')
    s.append(f"    raise notice 'A0.{module_order}: місце уроку {lesson_order} вже зайняте — пропускаю'; return;")
    s.append('  end if;')
    s.append('')
    s.append('  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)')
    s.append(f"  values (v_lesson, v_unit, 'A0', {q(f'Урок {number}: {t_ua}')}, {q(f'Lekcija {number}: {t_hr}')}, {qj(objectives)}, 10, 'PUBLISHED', {lesson_order});")
    s.append('')
    pos = 0
    s.append('  -- слова')
    for lemma in lemmas:
        pos += 1
        s.append(f"  select id into v_id from public.lexemes where lower(lemma) = lower({q(lemma)}) and status = 'PUBLISHED';")
        s.append(f"  if v_id is null then raise exception 'Немає опублікованого слова «%»', {q(lemma)}; end if;")
        s.append(f"  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, {pos}, 'vocabulary');")
    if gkey:
        g = D.GRAMMAR_A0[gkey]
        pos += 1
        s.append('  -- граматика')
        s.append(f"  select id into v_id from public.grammar_topics where cefr = 'A0' and title_ua = {q(g['title_ua'])} order by created_at limit 1;")
        s.append(f"  if v_id is null then raise exception 'Немає граматичної теми «%»', {q(g['title_ua'])}; end if;")
        s.append(f"  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_id, {pos}, 'grammar');")
        s.append('  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_id) on conflict do nothing;')
    s.append('  -- вправи')
    for ei, ex in enumerate(exercises, 1):
        pos += 1
        seed = f'{module_order}.{lesson_order}.{ei}'
        kind = ex[0]
        if kind == 'fill':
            _, question, answer, distractors = ex
            options = shuffled([answer, *distractors], seed)
        elif kind == 'build':
            _, question, answer = ex
            options = shuffled(answer.split(' '), seed)
        else:
            _, answer = ex
            question = 'Прослухайте і складіть фразу'
            options = shuffled(answer.split(' '), seed)
        eid = uid('exercise', 'A0', module_order, lesson_order, ei)
        s.append('  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)')
        s.append(f"  values ({q(eid)}, {q(LESSON_TYPES[kind])}, {q(question)}, {q(answer)}, {qj(options)}, 'A0', {ei}, 'PUBLISHED') on conflict (id) do nothing;")
        s.append(f"  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', {q(eid)}, {pos}, {q(TARGET_SKILL[kind])});")
    s.append('  -- діалог')
    cid = uid('conversation', 'A0', module_order, lesson_order)
    s.append('  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)')
    s.append(f"  values ({q(cid)}, v_lesson, {q(d_ua)}, {q(d_hr)}, {number}, 'A0', {q(situation)}, 'PUBLISHED', {q(SOURCE)}) on conflict (id) do nothing;")
    for ti, (speaker, hr, ua) in enumerate(turns, 1):
        s.append('  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)')
        s.append(f"  values ({q(uid('turn', 'A0', module_order, lesson_order, ti))}, {q(cid)}, {q(speaker)}, {q(hr)}, {q(ua)}, {ti}) on conflict (id) do nothing;")
    s.append('  -- журнал перевірки')
    s.append('  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)')
    s.append(f"  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, {q(REVIEW_NOTE)});")
    s.append('end $$;')
    s.append('')
    out.extend(s)


def skeleton_sql(out: list[str]):
    out.append('-- 5. Каркас A1–B2: модулі й граматичні теми (DRAFT — користувачі їх не бачать)')
    for level, mods in D.SKELETON_MODULES.items():
        for n, (ua, hr) in enumerate(mods, 1):
            out.append(
                'insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)\n'
                f"values ({q(uid('module', level, n))}, {q(level)}, {q(f'Модуль {level}.{n} — {ua}')}, {q(f'Modul {level}.{n} — {hr}')}, null, {n}, 'DRAFT')\n"
                'on conflict do nothing;'
            )
    for level, topics in D.SKELETON_GRAMMAR.items():
        for n, (ua, hr) in enumerate(topics, 1):
            out.append(
                'insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)\n'
                f"select {q(uid('grammar', level, n))}, {q(level)}, {q(ua)}, {q(hr)}, null, 'DRAFT'\n"
                f'where not exists (select 1 from public.grammar_topics where cefr = {q(level)} and title_ua = {q(ua)});'
            )
    out.append('')


def build() -> str:
    out: list[str] = []
    n_lessons = sum(len(m['lessons']) for m in D.MODULES_A0)
    out.append(f"""-- =====================================================================
-- Програма A0 (повна) + каркас A1–B2 · curriculum_a0_v1 · 2026-10-12
-- Згенеровано: python3 scripts/gen_curriculum_a0.py (не редагуйте вручну).
--
--   * A0: 10 модулів, 30 уроків (урок 1 вже був), {len(D.GRAMMAR_A0)} граматичних тем,
--     у кожному новому уроці — діалог, 4–12 слів, 3 вправи. Статус PUBLISHED:
--     бета за рішенням власника 2026-10-12 (§64 — виняток, записаний у PROJECT_STATE).
--   * A1–B2: {sum(len(v) for v in D.SKELETON_MODULES.values())} модулів і {sum(len(v) for v in D.SKELETON_GRAMMAR.values())} граматичних тем — DRAFT (без уроків).
--   * Наявні дані НЕ змінюються і НЕ видаляються. Повторний запуск безпечний.
--   * Потрібна міграція M10 (20261012240000_m10_lesson_order.sql).
--   * Нових уроків у цьому файлі: {n_lessons}.
-- =====================================================================

begin;

do $$
begin
  if not exists (select 1 from information_schema.columns
                 where table_schema = 'public' and table_name = 'lessons' and column_name = 'order_index') then
    raise exception 'Спершу запустіть міграцію M10 (20261012240000_m10_lesson_order.sql)';
  end if;
  if not exists (select 1 from public.modules where level_code = 'A0' and order_index = 1) then
    raise exception 'Немає модуля A0.1 — дані не схожі на робочу базу';
  end if;
end $$;
""")
    lexemes_sql(out)
    grammar_sql(out)
    modules_sql(out)
    out.append('-- 4. Уроки A0')
    number = 1
    for m in D.MODULES_A0:
        for li, lesson in enumerate(m['lessons'], 1):
            number += 1
            lesson_order = li + 1 if m.get('existing') else li
            lesson_sql(out, m['order'], lesson_order, number, lesson)
    skeleton_sql(out)
    out.append("""-- 6. Самоперевірка: якщо щось не так — усе відкочується
do $$
declare
  v_modules int; v_lessons int; v_empty int;
begin
  select count(*) into v_modules from public.modules where level_code = 'A0' and status = 'PUBLISHED';
  select count(*) into v_lessons from public.lessons l join public.units u on u.id = l.unit_id
    join public.modules m on m.id = u.module_id where m.level_code = 'A0' and l.status = 'PUBLISHED';
  select count(*) into v_empty from public.lessons l
    where l.level_code = 'A0' and l.status = 'PUBLISHED'
      and not exists (select 1 from public.lesson_items i where i.lesson_id = l.id and i.item_type = 'exercise');
  if v_modules < 10 then raise exception 'A0: опубліковано модулів %, очікувалось 10', v_modules; end if;
  if v_lessons < 30 then raise exception 'A0: опубліковано уроків %, очікувалось 30', v_lessons; end if;
  if v_empty > 0 then raise exception 'A0: % уроків без вправ', v_empty; end if;
  raise notice 'Готово: A0 — % модулів, % уроків', v_modules, v_lessons;
end $$;

commit;

-- Перевірка (окремим запитом після запуску):
-- select m.order_index as модуль, m.title_ua, count(l.id) as уроків
-- from public.modules m join public.units u on u.module_id = m.id
-- left join public.lessons l on l.unit_id = u.id and l.status = 'PUBLISHED'
-- where m.level_code = 'A0' group by m.order_index, m.title_ua order by 1;
""")
    return '\n'.join(out)


if __name__ == '__main__':
    validate()
    if errors:
        print('ПОМИЛКИ В ДАНИХ:', *errors, sep='\n  ')
        sys.exit(1)
    OUT.write_text(build(), encoding='utf-8')
    print(f'OK → {OUT.relative_to(ROOT)}')
