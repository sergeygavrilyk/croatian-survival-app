#!/usr/bin/env python3
"""
Генератор SQL для програми A1 (curriculum_a1_v1, 2026-10-13).

  python3 scripts/gen_curriculum_a1.py            →  supabase/data_fixes/20261013_curriculum_a1_v1_part1.sql і …_part2.sql
  python3 scripts/gen_curriculum_a1.py --review   →  таблиця вправ на слова (для звіту)

Дані: scripts/curriculum_a1_data.py; переклади слів — scripts/curriculum_a1_snapshot.json (знімок бази).

Що робить SQL:
  * нові слова A1 і 2 виправлення перекладів (стара версія — у content_versions);
  * 13 граматичних тем A1 (вже є як DRAFT): опис, правила з прикладами, PUBLISHED;
  * 10 модулів A1 (вже є як DRAFT): опис, юніт, PUBLISHED;
  * уроки: 10–12 слів (нові — до 14), 2 діалоги, граматика, 12 вправ (~12 хв).
    Базові 30 уроків + додаткові (рішення власника 2026-10-13: +1–2 уроки в модуль, де тема неповна).
Скрипт спершу перевіряє дані й зупиняється з помилкою, якщо щось не так.
SQL ідемпотентний (детерміновані id). Потребує міграції M13.

Дві частини (2026-10-13): цілий файл (~1 МБ) SQL Editor Supabase не приймав («Query is too large»).
Частина 1 — слова, виправлення, правила граматики, юніти, уроки модулів A1.1–A1.5;
частина 2 — уроки A1.6–A1.10, публікація модулів і тем граматики, самоперевірка.
Уроки записано коротко (допоміжні функції pg_temp — full_lessons.HELPERS_SQL).
"""
import json
import re
import sys
from pathlib import Path

sys.dont_write_bytecode = True  # без __pycache__ у репозиторії
sys.path.insert(0, str(Path(__file__).parent))
import curriculum_a1_data as D  # noqa: E402
from full_lessons import HELPERS_SQL, Course, ordered_places, q, qj, uid  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
OUT_DIR = ROOT / 'supabase' / 'data_fixes'
OUT_NAMES = ('20261013_curriculum_a1_v1_part1.sql', '20261013_curriculum_a1_v1_part2.sql')
PART1_MODULES = range(1, 6)  # A1.1–A1.5 у частині 1, решта — у частині 2
SNAPSHOT = json.loads((Path(__file__).parent / 'curriculum_a1_snapshot.json').read_text(encoding='utf-8'))
SOURCE = 'claude_curriculum_a1_v1'
LEVEL = 'A1'
MINUTES = 12
# Перемикач публікації: 'PUBLISHED' — бета (як A0); 'DRAFT' — бачить лише адмін до перевірки носієм.
STATUS = 'PUBLISHED'
REVIEW_NOTE = 'Бета: програма A1 за запитом власника 2026-10-13 (curriculum_a1_v1). Потрібна перевірка носієм.'
SITUATIONS = set(re.findall(r"code: '([a-z_]+)'", (ROOT / 'lib' / 'situations.ts').read_text(encoding='utf-8')))

errors: list[str] = []


def base_order(key) -> tuple[int, int]:
    """Ключ уроку → (модуль, місце в юніті). Базові уроки 1–30 — по 3 на модуль; додаткові — рядок 'модуль.місце'."""
    if isinstance(key, int):
        return (key - 1) // 3 + 1, (key - 1) % 3 + 1
    m, o = key.split('.')
    return int(m), int(o)


# ---------------------------------------------------------------- переклади
NEW = {lex[0].lower(): lex for lex in D.NEW_LEXEMES}
LEX: dict[str, tuple[str, str]] = {k: (v[0], v[1]) for k, v in SNAPSHOT['lexemes'].items()}
for low, lex in NEW.items():
    LEX[low] = (lex[0], lex[2])
for low, (old, new) in D.TRANSLATION_FIXES.items():
    if low in LEX and LEX[low][1] == old:
        LEX[low] = (LEX[low][0], new)
for low, (old, new) in D.LEMMA_FIXES.items():
    if low in LEX and LEX[low][0] == old:
        LEX[low] = (new, LEX[low][1])

PLACES = ordered_places(D.LESSONS, base_order)
KEYS = list(PLACES)  # у порядку програми
C = Course(level=LEVEL, lessons=D.LESSONS, place=PLACES, lex=LEX, situations=SITUATIONS,
           grammar_keys=set(D.GRAMMAR_A1), seed_prefix='a1', no_vocab=D.NO_VOCAB_EXERCISE,
           words_range=(10, 14), errors=errors)


def validate():
    for m in range(1, 11):
        orders = sorted(p.order for p in PLACES.values() if p.module == m)
        if orders[:3] != [1, 2, 3] or orders != list(range(1, len(orders) + 1)) or len(orders) > 5:
            errors.append(f'A1.{m}: місця уроків {orders} (мають бути 1..3, 1..4 або 1..5)')
    if [m['order'] for m in D.MODULES_A1] != list(range(1, 11)):
        errors.append('модулі A1 мають бути 1..10')
    for m in D.MODULES_A1:
        w = f"A1.{m['order']}"
        C.check_ua(m['description'], w)
        ut_ua, ut_hr, objectives = m['unit']
        C.check_ua(ut_ua, w + '.unit')
        C.check_hr(ut_hr, w + '.unit')
        for o in objectives:
            C.check_ua(o, w + '.unit.objective')

    skeleton = sorted(g['skeleton'] for g in D.GRAMMAR_A1.values())
    if skeleton != list(range(1, 14)):
        errors.append(f'граматика A1: потрібні теми каркаса 1..13, а є {skeleton}')
    for key, g in D.GRAMMAR_A1.items():
        w = f'grammar[{key}]'
        C.check_ua(g['description'], w)
        if len(g['rules']) < 2:
            errors.append(f'{w}: менше двох правил')
        for i, (title, expl, pattern, examples) in enumerate(g['rules'], 1):
            if not title.strip():
                errors.append(f'{w}.rule{i}: порожня назва')
            C.check_ua(expl, f'{w}.rule{i}')
            C.check_hr(re.sub(r'«[^»]*»', '', pattern), f'{w}.rule{i}.pattern')
            if len(examples) < 2:
                errors.append(f'{w}.rule{i}: менше двох прикладів')
            for hr, ua in examples:
                C.check_hr(hr, f'{w}.rule{i}.example')
                C.check_ua(ua, f'{w}.rule{i}.example')

    for lemma, norm, ua, pos, vtype, forms, example in D.NEW_LEXEMES:
        w = f'lexeme {lemma}'
        C.check_hr(lemma, w)
        C.check_ua(ua, w)
        C.check_hr(example, w)
        if vtype not in ('core', 'function_word', 'formulaic', 'collocation', 'chunk'):
            errors.append(f'{w}: vocabulary_type {vtype!r}')
        plain = lemma.lower().translate(str.maketrans('čćđšž', 'ccdsz'))
        if norm != plain:
            errors.append(f'{w}: normalized {norm!r}, а має бути {plain!r}')
        if lemma.lower() in SNAPSHOT['lexemes']:
            errors.append(f'{w}: уже є в базі (знімок) — не додаємо вдруге')
    if len(NEW) != len(D.NEW_LEXEMES):
        errors.append('NEW_LEXEMES: леми повторюються')
    for low, (old, new) in D.TRANSLATION_FIXES.items():
        if SNAPSHOT['lexemes'].get(low, [None, None])[1] != old:
            errors.append(f'виправлення перекладу {low}: у знімку не {old!r}')
        C.check_ua(new, f'виправлення {low}')
    for low, (old, new) in D.LEMMA_FIXES.items():
        if SNAPSHOT['lexemes'].get(low, [None])[0] != old:
            errors.append(f'виправлення леми {low}: у знімку не {old!r}')
        if new.lower() != low or old.lower() != low:
            errors.append(f'виправлення леми {low}: можна міняти лише регістр')

    for key in KEYS:
        C.validate_lesson(key)
    unused = set(D.GRAMMAR_A1) - {L['grammar'] for L in D.LESSONS.values()}
    if unused:
        errors.append(f'граматика без уроків: {sorted(unused)}')


# ---------------------------------------------------------------- SQL
def review_sql(entity: str, entity_id: str, to_status: str = STATUS) -> str:
    return ('insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)\n'
            f"select {q(entity)}, {q(entity_id)}, null, {q(to_status)}, 'auto_passed', 'ai', '[]'::jsonb, {q(REVIEW_NOTE)}\n"
            f'where not exists (select 1 from public.content_reviews where entity_id = {q(entity_id)} and notes = {q(REVIEW_NOTE)});')


def lexemes_sql(out: list[str]):
    out.append('-- 1. Нові слова A1 (яких ще немає у словнику)')
    for lemma, norm, ua, pos, vtype, forms, example in D.NEW_LEXEMES:
        out.append(
            'insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)\n'
            f"values ({q(lemma)}, {q(norm)}, 'hr', {q(pos)}, {q(LEVEL)}, {q(ua)}, {q(vtype)}, {qj(forms)}, {qj([example])}, 'PUBLISHED', {q(SOURCE)})\n"
            'on conflict do nothing;'
        )
    out.append('')


def fixes_sql(out: list[str]):
    out.append('-- 2. Виправлення словника (стара версія — у content_versions)')
    for low, (old, new) in D.TRANSLATION_FIXES.items():
        note = f'curriculum_a1_v1: переклад «{old}» → «{new}»'
        out.append(f"""do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l
   where lower(lemma) = lower({q(low)}) and ukrainian_translation = {q(old)};
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, {q(note)});
  update public.lexemes set ukrainian_translation = {q(new)} where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, {q(note)});
end $$;""")
    for low, (old, new) in D.LEMMA_FIXES.items():
        note = f'curriculum_a1_v1: лема «{old}» → «{new}»'
        out.append(f"""do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l where lemma = {q(old)};
  if v_id is null then return; end if;  -- уже виправлено
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, {q(note)});
  update public.lexemes set lemma = {q(new)} where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, {q(note)});
end $$;""")
    out.append('')


def grammar_publish_sql(out: list[str]):
    out.append('-- Граматика A1: опис і публікація тем (теми вже є в каркасі як DRAFT; правила — у частині 1)')
    for key, g in D.GRAMMAR_A1.items():
        gid = uid('grammar', LEVEL, g['skeleton'])
        out.append(
            f"update public.grammar_topics set description = {q(g['description'])}, status = {q(STATUS)}\n"
            f"where id = {q(gid)} and cefr = {q(LEVEL)} and status in ('DRAFT', 'AI_GENERATED', 'AUTO_VALIDATED', 'NEEDS_REVIEW', 'APPROVED');"
        )
        out.append(review_sql('grammar_topic', gid))
    out.append('')


def grammar_rules_sql(out: list[str]):
    out.append('-- 3. Граматика A1: правила з прикладами (теми публікуються в частині 2)')
    for key, g in D.GRAMMAR_A1.items():
        gid = uid('grammar', LEVEL, g['skeleton'])
        for i, (title, expl, pattern, examples) in enumerate(g['rules'], 1):
            ex = [{'hr': hr, 'ua': ua} for hr, ua in examples]
            out.append(
                'insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)\n'
                f"select {q(uid('grammar_rule', LEVEL, key, i))}, {q(gid)}, {q(title)}, {q(expl)}, {q(pattern)}, {qj(ex)}, {i}\n"
                f'where exists (select 1 from public.grammar_topics where id = {q(gid)})\n'
                'on conflict (id) do nothing;'
            )
    out.append('')


def modules_publish_sql(out: list[str]):
    out.append('-- Модулі A1: опис і публікація (модулі вже є в каркасі як DRAFT; юніти — у частині 1)')
    for m in D.MODULES_A1:
        out.append(
            f"update public.modules set description = {q(m['description'])}, status = {q(STATUS)}\n"
            f"where level_code = {q(LEVEL)} and order_index = {m['order']} and status <> 'DEPRECATED';"
        )
    out.append('')


def units_sql(out: list[str]):
    out.append('-- 4. Юніти модулів A1 (модулі публікуються в частині 2)')
    for m in D.MODULES_A1:
        n = m['order']
        ut_ua, ut_hr, objectives = m['unit']
        out.append(
            'insert into public.units (id, module_id, title_ua, title_hr, objectives, order_index, status)\n'
            f"select {q(uid('unit', LEVEL, n, 1))}, m.id, {q(ut_ua)}, {q(ut_hr)}, {qj(objectives)}, 1, {q(STATUS)}\n"
            f"from public.modules m where m.level_code = {q(LEVEL)} and m.order_index = {n}\n"
            'on conflict do nothing;'
        )
    out.append('')


def lesson_sql(out: list[str], key):
    gid = uid('grammar', LEVEL, D.GRAMMAR_A1[D.LESSONS[key]['grammar']]['skeleton'])
    out.extend(C.lesson_sql(key, status=STATUS, source=SOURCE, note=REVIEW_NOTE, minutes=MINUTES,
                            grammar_lookup=f'select id into v_gid from public.grammar_topics where id = {q(gid)};', compact=True))


def header(part: int, lines: list[str]) -> str:
    return '\n'.join([
        '-- =====================================================================',
        f'-- Програма A1 · curriculum_a1_v1 · частина {part} з 2 · 2026-10-13',
        '-- Згенеровано: python3 scripts/gen_curriculum_a1.py (не редагуйте вручну).',
        '-- Запуск: Supabase → SQL Editor → вставити ВЕСЬ файл → Run. Спершу частина 1, потім частина 2.',
        '--', *[f'--   * {x}' for x in lines],
        '--   * Наявні дані не видаляються. Повторний запуск безпечний.',
        '-- =====================================================================', '', 'begin;', ''])


def build() -> tuple[str, str]:
    n_rules = sum(len(g['rules']) for g in D.GRAMMAR_A1.values())
    k1 = [k for k in KEYS if PLACES[k].module in PART1_MODULES]
    k2 = [k for k in KEYS if PLACES[k].module not in PART1_MODULES]
    n_lessons = len(KEYS)

    def stats(keys):
        turns = sum(len(t) for k in keys for _, _, t in D.LESSONS[k]['scenes'])
        return f'{len(keys)} уроків (№ {PLACES[keys[0]].number}–{PLACES[keys[-1]].number}), {2 * len(keys)} діалогів ({turns} реплік), {12 * len(keys)} вправ'

    # ------------------------------------------------ частина 1
    p1: list[str] = [header(1, [
        f'Нові слова: {len(D.NEW_LEXEMES)}. Виправлення словника: {len(D.TRANSLATION_FIXES)} переклади + {len(D.LEMMA_FIXES)} написання леми (старі — у content_versions).',
        f'13 граматичних тем A1 → {n_rules} правил з прикладами (теми публікуються в частині 2).',
        'Юніти 10 модулів A1.',
        f'Модулі A1.{PART1_MODULES[0]}–A1.{PART1_MODULES[-1]}: {stats(k1)}.',
        'Після цієї частини A1 ще НЕ видно користувачам — модулі публікує частина 2.',
        'Потрібна міграція M13 (типи вправ type_answer і speaking).']), f"""do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'exercises_type_check'
                 and pg_get_constraintdef(oid) like '%speaking%') then
    raise exception 'Спершу запустіть міграцію M13 (20261013140000_m13_exercise_types.sql)';
  end if;
  if (select count(*) from public.modules where level_code = 'A1') < 10 then
    raise exception 'Немає 10 модулів A1 (каркас) — спершу curriculum_a0_v1';
  end if;
end $$;
""", HELPERS_SQL]
    lexemes_sql(p1)
    fixes_sql(p1)
    grammar_rules_sql(p1)
    units_sql(p1)
    p1.append('-- 5. Уроки A1, частина 1')
    for key in k1:
        lesson_sql(p1, key)
    p1.append(f"""-- Самоперевірка частини 1: якщо щось не так — усе відкочується
do $$
declare v_lessons int;
begin
  select count(*) into v_lessons from public.lessons l join public.units u on u.id = l.unit_id
    join public.modules m on m.id = u.module_id
   where m.level_code = '{LEVEL}' and m.order_index between {PART1_MODULES[0]} and {PART1_MODULES[-1]};
  if v_lessons < {len(k1)} then raise exception 'A1.{PART1_MODULES[0]}–A1.{PART1_MODULES[-1]}: уроків %, очікувалось {len(k1)}', v_lessons; end if;
  raise notice 'Частина 1 готова: уроків у A1.{PART1_MODULES[0]}–A1.{PART1_MODULES[-1]} — %. Тепер запустіть частину 2.', v_lessons;
end $$;

commit;
""")

    # ------------------------------------------------ частина 2
    last1 = uid('lesson', LEVEL, PLACES[k1[-1]].module, PLACES[k1[-1]].order)
    p2: list[str] = [header(2, [
        f'Модулі A1.{PART1_MODULES[-1] + 1}–A1.10: {stats(k2)}.',
        f'Публікація 10 модулів і 13 тем граматики A1 (статус {STATUS}: бета, як A0; носій ще не перевіряв).',
        f'Самоперевірка всієї програми: {n_lessons} уроків.',
        'Потрібна частина 1 (20261013_curriculum_a1_v1_part1.sql).']), f"""do $$
begin
  if not exists (select 1 from public.lessons where id = {q(last1)}) then
    raise exception 'Спершу запустіть частину 1 (20261013_curriculum_a1_v1_part1.sql)';
  end if;
end $$;
""", HELPERS_SQL]
    p2.append('-- 5. Уроки A1, частина 2')
    for key in k2:
        lesson_sql(p2, key)
    modules_publish_sql(p2)
    grammar_publish_sql(p2)
    p2.append(f"""-- 6. Самоперевірка: якщо щось не так — уся частина 2 відкочується
do $$
declare
  v_modules int; v_lessons int; v_short int; v_scenes int; v_grammar int; v_rules int;
begin
  select count(*) into v_modules from public.modules where level_code = '{LEVEL}' and status = '{STATUS}';
  select count(*) into v_lessons from public.lessons where level_code = '{LEVEL}' and status = '{STATUS}';
  select count(*) into v_short from public.lessons l where l.level_code = '{LEVEL}'
     and (select count(*) from public.lesson_items i where i.lesson_id = l.id and i.item_type = 'exercise') < 12;
  select count(*) into v_scenes from public.lessons l where l.level_code = '{LEVEL}'
     and (select count(*) from public.conversations c where c.lesson_id = l.id) < 2;
  select count(*) into v_grammar from public.grammar_topics where cefr = '{LEVEL}' and status = '{STATUS}';
  select count(*) into v_rules from public.grammar_topics g where g.cefr = '{LEVEL}'
     and not exists (select 1 from public.grammar_rules r where r.topic_id = g.id);
  if v_modules < 10 then raise exception 'A1: модулів %, очікувалось 10', v_modules; end if;
  if v_lessons < {n_lessons} then raise exception 'A1: уроків %, очікувалось {n_lessons}', v_lessons; end if;
  if v_short > 0 then raise exception 'A1: % уроків мають менше 12 вправ', v_short; end if;
  if v_scenes > 0 then raise exception 'A1: % уроків без двох діалогів', v_scenes; end if;
  if v_grammar < 13 or v_rules > 0 then raise exception 'A1: граматика — тем %, без правил %', v_grammar, v_rules; end if;
  raise notice 'Готово: A1 — % модулів, % уроків, % граматичних тем', v_modules, v_lessons, v_grammar;
end $$;

commit;

-- Перевірка (окремим запитом після запуску):
-- select m.order_index as модуль, m.title_ua, count(l.id) as уроків
-- from public.modules m join public.units u on u.module_id = m.id
-- left join public.lessons l on l.unit_id = u.id
-- where m.level_code = 'A1' group by m.order_index, m.title_ua order by 1;
""")
    return '\n'.join(p1), '\n'.join(p2)


def review_table() -> str:
    return '| Урок | Тип | Завдання | Відповідь | Варіанти |\n|---|---|---|---|---|\n' + '\n'.join(C.review_rows(KEYS))


if __name__ == '__main__':
    validate()
    if errors:
        print('ПОМИЛКИ В ДАНИХ:', *errors, sep='\n  ')
        sys.exit(1)
    parts = build()
    if errors:
        print('ПОМИЛКИ В ДАНИХ:', *errors, sep='\n  ')
        sys.exit(1)
    if '--review' in sys.argv:
        print(review_table())
        sys.exit(0)
    for name, sql in zip(OUT_NAMES, parts):
        (OUT_DIR / name).write_text(sql, encoding='utf-8')
        print(f'OK → supabase/data_fixes/{name}: {len(sql.encode()) // 1024} КБ')
