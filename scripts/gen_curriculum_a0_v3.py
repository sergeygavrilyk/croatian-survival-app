#!/usr/bin/env python3
"""
Генератор SQL для доповнення програми A0 (curriculum_a0_v3, 2026-10-13).

  python3 scripts/gen_curriculum_a0_v3.py            →  supabase/data_fixes/20261013_curriculum_a0_v3.sql
  python3 scripts/gen_curriculum_a0_v3.py --review   →  таблиця вправ на слова (для звіту)

Дані: scripts/curriculum_a0_v3_data.py; переклади — знімки бази
(curriculum_a0_v2_snapshot.json, curriculum_a0_v3_snapshot.json, curriculum_a1_snapshot.json).

Що робить SQL:
  * нові слова A0 і виправлення словника (стара версія — у content_versions);
  * нова тема граматики A0 «Порядок слів» з правилами;
  * 17 нових уроків на місцях 4–5 у юнітах модулів (повна структура, ~12 хв);
  * перенумеровує назви всіх уроків A0 («Урок N: …»), щоб номери йшли підряд.
SQL ідемпотентний (детерміновані id). Потребує M13 і curriculum_a0_v2.
"""
import json
import re
import sys
from pathlib import Path

sys.dont_write_bytecode = True  # без __pycache__ у репозиторії
sys.path.insert(0, str(Path(__file__).parent))
import curriculum_a0_v3_data as D  # noqa: E402
import curriculum_a0_v2_data as V2  # noqa: E402
from full_lessons import Course, Place, q, qj, uid  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
HERE = Path(__file__).parent
OUT = ROOT / 'supabase' / 'data_fixes' / '20261013_curriculum_a0_v3.sql'
SNAP_V2 = json.loads((HERE / 'curriculum_a0_v2_snapshot.json').read_text(encoding='utf-8'))
SNAP_V3 = json.loads((HERE / 'curriculum_a0_v3_snapshot.json').read_text(encoding='utf-8'))
SNAP_A1 = json.loads((HERE / 'curriculum_a1_snapshot.json').read_text(encoding='utf-8'))
SOURCE = 'claude_curriculum_a0_v3'
LEVEL = 'A0'
MINUTES = 12
STATUS = 'PUBLISHED'  # бета, як решта A0 (рішення власника 2026-10-12)
REVIEW_NOTE = 'Бета: додатковий урок A0 за рішенням власника 2026-10-13 (curriculum_a0_v3). Потрібна перевірка носієм.'
LESSON1_ID = 'c0000000-0000-0000-0000-000000000001'
SITUATIONS = set(re.findall(r"code: '([a-z_]+)'", (ROOT / 'lib' / 'situations.ts').read_text(encoding='utf-8')))

errors: list[str] = []


def base_order(key: str) -> tuple[int, int]:
    m, o = key.split('.')
    return int(m), int(o)


def existing_lesson_id(m: int, o: int) -> str:
    return LESSON1_ID if (m, o) == (1, 1) else uid('lesson', LEVEL, m, o)


# ---------------------------------------------------------------- місця й номери
# Наявні уроки A0: по 3 в кожному з 10 модулів. Нові — місця 4–5.
ALL_SLOTS = sorted([(m, o) for m in range(1, 11) for o in (1, 2, 3)] + [base_order(k) for k in D.LESSONS])
NUMBER = {slot: n for n, slot in enumerate(ALL_SLOTS, 1)}
PLACES = {k: Place(*base_order(k), NUMBER[base_order(k)]) for k in D.LESSONS}
KEYS = sorted(D.LESSONS, key=base_order)

# ---------------------------------------------------------------- слова й переклади
LEX: dict[str, tuple[str, str]] = {}
for low, (lemma, tr) in SNAP_A1['lexemes'].items():
    LEX[low] = (lemma, tr)
_case = {w.lower(): w for ws in SNAP_V2['lesson_words'].values() for w in ws}
_case.update({'hrvatska': 'Hrvatska'})
for low, tr in SNAP_V2['translations'].items():
    LEX[low] = (_case.get(low, low), tr)
for lex in V2.NEW_LEXEMES:
    LEX[lex[0].lower()] = (lex[0], lex[2])
for low, (old, new) in V2.TRANSLATION_FIXES.items():   # v2 уже застосовано в базі
    if low in LEX and LEX[low][1] == old:
        LEX[low] = (LEX[low][0], new)
for low, (lemma, tr) in SNAP_V3['lexemes'].items():
    LEX[low] = (lemma, tr)
NEW = {lex[0].lower(): lex for lex in D.NEW_LEXEMES}
for low, lex in NEW.items():
    LEX[low] = (lex[0], lex[2])
for low, (old, new) in D.TRANSLATION_FIXES.items():
    if low in LEX and LEX[low][1] == old:
        LEX[low] = (LEX[low][0], new)
for low, (old, new) in D.LEMMA_FIXES.items():
    if low in LEX and LEX[low][0] == old:
        LEX[low] = (new, LEX[low][1])

# Слова наявних уроків A0 — для хибних варіантів і перевірки неоднозначності
EXISTING_WORDS: dict[int, list[str]] = {}
for n in range(1, 31):
    base = V2.LESSON1_BASE_WORDS if n == 1 else SNAP_V2['lesson_words'][str(n)]
    EXISTING_WORDS.setdefault((n - 1) // 3 + 1, []).extend([*base, *V2.LESSONS[n]['words']])

GRAMMAR_KEYS = set(D.EXISTING_GRAMMAR) | set(D.NEW_GRAMMAR)
C = Course(level=LEVEL, lessons=D.LESSONS, place=PLACES, lex=LEX, situations=SITUATIONS,
           grammar_keys=GRAMMAR_KEYS, seed_prefix='a0v3', no_vocab=D.NO_VOCAB_EXERCISE,
           extra_pool=[w for ws in EXISTING_WORDS.values() for w in ws],
           extra_module_words=EXISTING_WORDS, words_range=(10, 12), errors=errors)


def validate():
    for m in range(1, 11):
        orders = sorted(o for (mm, o) in ALL_SLOTS if mm == m)
        if orders != list(range(1, len(orders) + 1)) or len(orders) > 5:
            errors.append(f'A0.{m}: місця уроків {orders}')
        if len(orders) < 4:
            errors.append(f'A0.{m}: немає жодного нового уроку')
    for key, g in D.NEW_GRAMMAR.items():
        w = f'grammar[{key}]'
        C.check_ua(g['title_ua'], w)
        C.check_hr(g['title_hr'], w)
        C.check_ua(g['description'], w)
        if len(g['rules']) < 2:
            errors.append(f'{w}: менше двох правил')
        for i, (title, expl, pattern, examples) in enumerate(g['rules'], 1):
            C.check_ua(title, f'{w}.rule{i}')
            C.check_ua(expl, f'{w}.rule{i}')
            C.check_hr(pattern, f'{w}.rule{i}.pattern')
            if len(examples) < 2:
                errors.append(f'{w}.rule{i}: менше двох прикладів')
            for hr, ua in examples:
                C.check_hr(hr, f'{w}.rule{i}.example')
                C.check_ua(ua, f'{w}.rule{i}.example')
    known = set(SNAP_A1['lexemes']) | set(SNAP_V2['translations']) | set(SNAP_V3['lexemes']) | {x[0].lower() for x in V2.NEW_LEXEMES}
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
        if lemma.lower() in known:
            errors.append(f'{w}: уже є в базі (знімок) — не додаємо вдруге')
    if len(NEW) != len(D.NEW_LEXEMES):
        errors.append('NEW_LEXEMES: леми повторюються')
    # спільні з A1 нові слова мають бути однакові (хто перший — той і створить)
    try:
        import curriculum_a1_data as A1
        a1new = {x[0].lower(): x for x in A1.NEW_LEXEMES}
        for low, lex in NEW.items():
            if low in a1new and a1new[low][:3] != lex[:3]:
                errors.append(f'lexeme {low}: інакше, ніж у curriculum_a1_data (переклад має збігатися)')
    except ImportError:
        pass
    for low, (old, new) in D.TRANSLATION_FIXES.items():
        if LEX.get(low) is None:
            errors.append(f'виправлення перекладу {low}: слова немає в знімку')
        C.check_ua(new, f'виправлення {low}')
    for low, (old, new) in D.LEMMA_FIXES.items():
        if new.lower() != low or old.lower() != low:
            errors.append(f'виправлення леми {low}: можна міняти лише регістр')
    for key in KEYS:
        C.validate_lesson(key)


# ---------------------------------------------------------------- SQL
def lexemes_sql(out: list[str]):
    out.append('-- 1. Нові слова A0 (яких ще немає у словнику)')
    for lemma, norm, ua, pos, vtype, forms, example in D.NEW_LEXEMES:
        out.append(
            'insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)\n'
            f"values ({q(lemma)}, {q(norm)}, 'hr', {q(pos)}, {q(LEVEL)}, {q(ua)}, {q(vtype)}, {qj(forms)}, {qj([example])}, 'PUBLISHED', {q(SOURCE)})\n"
            'on conflict do nothing;'
        )
    out.append('')


def fix_block(where: str, set_sql: str, note: str) -> str:
    return f"""do $$
declare v_id uuid; v_payload jsonb;
begin
  select id, to_jsonb(l) into v_id, v_payload from public.lexemes l where {where};
  if v_id is null then return; end if;  -- уже виправлено або змінено вручну
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lexeme', v_id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = v_id), 0) + 1,
          v_payload, {q(note)});
  update public.lexemes set {set_sql} where id = v_id;
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lexeme', v_id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, {q(note)});
end $$;"""


def fixes_sql(out: list[str]):
    out.append('-- 2. Виправлення словника (стара версія — у content_versions)')
    for low, (old, new) in D.TRANSLATION_FIXES.items():
        out.append(fix_block(f'lower(lemma) = lower({q(low)}) and ukrainian_translation = {q(old)}',
                             f'ukrainian_translation = {q(new)}', f'curriculum_a0_v3: переклад «{old}» → «{new}»'))
    for low, (old, new) in D.LEMMA_FIXES.items():
        out.append(fix_block(f'lemma = {q(old)}', f'lemma = {q(new)}', f'curriculum_a0_v3: лема «{old}» → «{new}»'))
    out.append('')


def grammar_sql(out: list[str]):
    out.append('-- 3. Нова тема граматики A0')
    for key, g in D.NEW_GRAMMAR.items():
        gid = uid('grammar', LEVEL, key)
        out.append(
            'insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)\n'
            f"select {q(gid)}, {q(LEVEL)}, {q(g['title_ua'])}, {q(g['title_hr'])}, {q(g['description'])}, {q(STATUS)}\n"
            f"where not exists (select 1 from public.grammar_topics where cefr = {q(LEVEL)} and title_ua = {q(g['title_ua'])});"
        )
        for i, (title, expl, pattern, examples) in enumerate(g['rules'], 1):
            ex = [{'hr': hr, 'ua': ua} for hr, ua in examples]
            out.append(
                'insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)\n'
                f"select {q(uid('grammar_rule', LEVEL, key, i))}, {q(gid)}, {q(title)}, {q(expl)}, {q(pattern)}, {qj(ex)}, {i}\n"
                f'where exists (select 1 from public.grammar_topics where id = {q(gid)})\n'
                'on conflict (id) do nothing;'
            )
        out.append(
            'insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)\n'
            f"select 'grammar_topic', {q(gid)}, null, {q(STATUS)}, 'auto_passed', 'ai', '[]'::jsonb, {q(REVIEW_NOTE)}\n"
            f'where exists (select 1 from public.grammar_topics where id = {q(gid)})\n'
            f'  and not exists (select 1 from public.content_reviews where entity_id = {q(gid)} and notes = {q(REVIEW_NOTE)});'
        )
    out.append('')


def grammar_lookup(key: str) -> str:
    if key in D.NEW_GRAMMAR:
        title = D.NEW_GRAMMAR[key]['title_ua']
    else:
        title = D.EXISTING_GRAMMAR[key]
    return (f"select id into v_gid from public.grammar_topics where cefr = 'A0' and title_ua = {q(title)} "
            "and status = 'PUBLISHED' order by created_at limit 1;")


def renumber_sql(out: list[str]):
    out.append('-- 5. Наскрізні номери уроків A0 («Урок N: …» / «Lekcija N: …»); стара назва — у content_versions')
    rows = []
    for (m, o), n in NUMBER.items():
        if (m, o) in {base_order(k) for k in D.LESSONS}:
            continue  # нові уроки вже створено з правильним номером
        rows.append(f"({q(existing_lesson_id(m, o))}::uuid, {n})")
    out.append(f"""do $$
declare r record; v_payload jsonb; v_new_ua text; v_new_hr text;
begin
  for r in select * from (values
    {(',' + chr(10) + '    ').join(rows)}
  ) as t(id, n) loop
    select to_jsonb(l), regexp_replace(l.title_ua, '^Урок [0-9]+:', 'Урок ' || r.n || ':'),
           regexp_replace(l.title_hr, '^Lekcija [0-9]+:', 'Lekcija ' || r.n || ':')
      into v_payload, v_new_ua, v_new_hr
      from public.lessons l where l.id = r.id;
    if v_payload is null then continue; end if;
    if v_new_ua is not distinct from (v_payload->>'title_ua') and v_new_hr is not distinct from (v_payload->>'title_hr') then continue; end if;
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lesson', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = r.id), 0) + 1,
            v_payload, 'curriculum_a0_v3: новий номер уроку ' || r.n);
    update public.lessons set title_ua = v_new_ua, title_hr = v_new_hr where id = r.id;
  end loop;
end $$;
""")


def build() -> str:
    n_new = len(KEYS)
    total = len(ALL_SLOTS)
    n_turns = sum(len(t) for L in D.LESSONS.values() for _, _, t in L['scenes'])
    out: list[str] = [f"""-- =====================================================================
-- Доповнення програми A0 · curriculum_a0_v3 · 2026-10-13
-- Згенеровано: python3 scripts/gen_curriculum_a0_v3.py (не редагуйте вручну).
--
--   * +{n_new} уроків (місця 4–5 у модулях, де тема була неповна) → разом {total} уроків A0.
--     Кожен: 10–12 слів, 2 діалоги ({n_turns} реплік разом), граматика, 12 вправ, ~{MINUTES} хв.
--   * Нова тема граматики «Порядок слів» (§21 ТЗ).
--   * Нові слова: {len(D.NEW_LEXEMES)}. Виправлення словника: {len(D.TRANSLATION_FIXES)} переклади + {len(D.LEMMA_FIXES)} написання леми.
--   * Назви всіх уроків A0 перенумеровано підряд («Урок N»); старі назви — у content_versions.
--   * Статус {STATUS}: бета, як решта A0. Носій ще не перевіряв.
--   * Наявні дані не видаляються. Повторний запуск безпечний.
--   * Потрібні M13 і curriculum_a0_v2.
-- =====================================================================

begin;

do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'exercises_type_check'
                 and pg_get_constraintdef(oid) like '%speaking%') then
    raise exception 'Спершу запустіть міграцію M13 (20261013140000_m13_exercise_types.sql)';
  end if;
  if (select count(*) from public.lessons where level_code = 'A0' and status = 'PUBLISHED') < 30 then
    raise exception 'Немає 30 уроків A0 — спершу curriculum_a0_v1';
  end if;
  if not exists (select 1 from public.conversations where source = 'claude_curriculum_v2') then
    raise exception 'Спершу запустіть 20261013_curriculum_a0_v2.sql';
  end if;
end $$;
"""]
    lexemes_sql(out)
    fixes_sql(out)
    grammar_sql(out)
    out.append('-- 4. Нові уроки A0')
    for key in KEYS:
        out.extend(C.lesson_sql(key, status=STATUS, source=SOURCE, note=REVIEW_NOTE, minutes=MINUTES,
                                grammar_lookup=grammar_lookup(D.LESSONS[key]['grammar'])))
    renumber_sql(out)
    out.append(f"""-- 6. Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_lessons int; v_short int; v_bad_title int;
begin
  select count(*) into v_lessons from public.lessons where level_code = 'A0' and status = 'PUBLISHED';
  select count(*) into v_short from public.lessons l where l.level_code = 'A0' and l.status = 'PUBLISHED'
     and (select count(*) from public.lesson_items i where i.lesson_id = l.id and i.item_type = 'exercise') < 12;
  select count(*) into v_bad_title from (
     select l.title_ua, row_number() over (order by m.order_index, l.order_index) as n
       from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
      where l.level_code = 'A0' and l.status = 'PUBLISHED') t
   where t.title_ua not like 'Урок ' || t.n || ':%';
  if v_lessons < {total} then raise exception 'A0: уроків %, очікувалось {total}', v_lessons; end if;
  if v_short > 0 then raise exception 'A0: % уроків мають менше 12 вправ', v_short; end if;
  if v_bad_title > 0 then raise exception 'A0: % уроків з неправильним номером у назві', v_bad_title; end if;
  raise notice 'Готово: A0 — % уроків', v_lessons;
end $$;

commit;
""")
    return '\n'.join(out)


def review_table() -> str:
    return '| Урок | Тип | Завдання | Відповідь | Варіанти |\n|---|---|---|---|---|\n' + '\n'.join(C.review_rows(KEYS))


if __name__ == '__main__':
    validate()
    if errors:
        print('ПОМИЛКИ В ДАНИХ:', *errors, sep='\n  ')
        sys.exit(1)
    sql = build()
    if errors:
        print('ПОМИЛКИ В ДАНИХ:', *errors, sep='\n  ')
        sys.exit(1)
    if '--review' in sys.argv:
        print(review_table())
        sys.exit(0)
    OUT.write_text(sql, encoding='utf-8')
    print(f'OK → {OUT.relative_to(ROOT)}')
