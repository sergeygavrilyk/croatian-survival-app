#!/usr/bin/env python3
"""
Регістр наявних слів словника (`lexemes.register`): informal / colloquial / slang · 2026-11-12.

Рішення власника 2026-11-12 (перед подальшими правками рівня B1): «Необхідно зробити скріпт, який порівняє лексеми
в DB supabase та проставить їм визначеннями в CONTENT_PIPELINE.md: informal — літературне, але неофіційне
(bok, ćao, Kako si? замість Kako ste?); colloquial — розмовне, нелітературне (kužiti, frka); slang — мова групи
(frend, fora)».

Як працює:
  1. Знімок робочої бази (лише читання) — запит друкує `python3 -B scripts/lexeme_register.py --query`;
     результат (JSON-масив рядків) → scripts/lexeme_register_20261112_snapshot.json.
  2. `python3 -B scripts/gen_lexeme_register_20261112.py` порівнює кожне слово знімка з правилами
     scripts/lexeme_register.py (словник правил + ознака «звертання на ти») і пише:
       → supabase/data_fixes/20261112_lexeme_register.sql   (ставить register лише там, де він порожній)
       → content/reviews/2026-11-12_lexeme_register.md      (звіт: що позначено, що сумнівне — для носія)
Генератор не змінює наявний register (slang у ae / onak, regional у pomidor…), не чіпає переклади, regionality
й не DEPRECATED слова. Повторний запуск SQL нічого не змінює.
"""
from __future__ import annotations

import json
import sys
from collections import Counter
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).parent))
from lexeme_checks import normalize  # noqa: E402
from lexeme_register import ALLOWED, DOUBT, LEGACY, NOT_TI, REGISTERS, RULES, suggest_register  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
SNAP = ROOT / 'scripts' / 'lexeme_register_20261112_snapshot.json'
OUT = ROOT / 'supabase' / 'data_fixes' / '20261112_lexeme_register.sql'
REPORT = ROOT / 'content' / 'reviews' / '2026-11-12_lexeme_register.md'
PUBLISHED_TOTAL = 6185  # опублікованих слів у робочій базі на момент знімка (select count(*) … status = 'PUBLISHED')
NOTE = ('lexeme_register 2026-11-12: позначено регістр за визначеннями docs/CONTENT_PIPELINE.md «Регістр лексем» '
        '(рішення власника 2026-11-12); скрипт scripts/gen_lexeme_register_20261112.py, бета — носій перевіряє після.')
UA = {'informal': 'неофіційне', 'colloquial': 'розмовне', 'slang': 'сленг', 'formal': 'офіційне', 'vulgar': 'грубе',
      'regional': 'regional (старе)', 'non_standard': 'non_standard (старе)'}


def q(s) -> str:
    return 'null' if s is None else "'" + str(s).replace("'", "''") + "'"


def classify(rows: list[dict]) -> dict[str, list]:
    g: dict[str, list] = {k: [] for k in ('apply', 'same', 'conflict', 'legacy', 'doubt', 'mark', 'regional_std',
                                          'not_ti', 'skipped')}
    for r in rows:
        lemma = r['lemma'].lower()
        reg = r.get('register')
        sug, why, src = suggest_register(r)
        if reg in LEGACY:
            g['legacy'].append((r, sug, why))
        elif src in ('rule', 'ti'):
            if reg is None:
                g['apply'].append((r, sug, why, src))
            elif reg == sug:
                g['same'].append((r, sug, why))
            else:
                g['conflict'].append((r, sug, why))
        elif reg is not None:
            g['skipped'].append(r)  # уже має регістр, правила для слова немає — лишаю
        elif src == 'doubt':
            g['doubt'].append((r, why))
        elif src == 'mark':
            g['mark'].append((r, why))
        elif lemma in NOT_TI:
            g['not_ti'].append((r, NOT_TI[lemma]))
        elif r.get('regionality') and reg is None:
            g['regional_std'].append(r)
        else:
            g['skipped'].append(r)
    return g


def validate(rows: list[dict], g: dict) -> list[str]:
    errors = []
    seen = Counter(r['lemma'].lower() for r in rows)
    errors += [f'{l}: повтор у знімку' for l, n in seen.items() if n > 1]
    for r in rows:
        if r.get('register') is not None and r['register'] not in ALLOWED + LEGACY:
            errors.append(f'{r["lemma"]}: невідоме значення register «{r["register"]}»')
    for r, sug, *_ in g['apply']:
        if sug not in REGISTERS:
            errors.append(f'{r["lemma"]}: позначка «{sug}» поза informal / colloquial / slang')
    for r, sug, _ in g['conflict']:
        errors.append(f'{r["lemma"]}: у базі «{r["register"]}», правило каже «{sug}» — вирішити вручну (правило або DOUBT)')
    if not g['apply']:
        errors.append('нічого позначати — знімок порожній чи застарілий?')
    return errors


def sql(g: dict) -> str:
    items = [{'lemma': r['lemma'].lower(), 'register': sug} for r, sug, *_ in g['apply']]
    c = Counter(i['register'] for i in items)
    summary = ', '.join(f'{k} {c[k]}' for k in REGISTERS)
    return f"""-- =====================================================================
-- Регістр наявних слів словника · 2026-11-12
-- Згенеровано: python3 -B scripts/gen_lexeme_register_20261112.py (не редагуйте вручну).
-- Рішення власника 2026-11-12: «Необхідно зробити скріпт, який порівняє лексеми в DB supabase та проставить їм
--   визначеннями в CONTENT_PIPELINE.md: informal — літературне, але неофіційне (bok, ćao, Kako si? замість Kako ste?);
--   colloquial — розмовне, нелітературне (kužiti, frka); slang — мова групи (frend, fora)».
-- Що робить: ставить lexemes.register {len(items)} опублікованим словам ({summary}) — ЛИШЕ там, де register порожній.
--   Не змінює: наявний register (ae, onak — slang; pomidor, kapula, šugaman — regional, нормалізує пакет M24),
--   переклади, regionality, DEPRECATED слова. Стара версія — у content_versions, запис — у content_reviews.
--   Слова, яких немає в базі, пропускає. Повторний запуск нічого не змінює.
-- Звіт для носія: content/reviews/2026-11-12_lexeme_register.md.
-- Після нього: тест supabase/tests/lexeme_register.test.sql → «ALL TESTS PASSED».
-- Очікуване повідомлення: «Готово: позначено …, уже було …, пропущено (немає / інший регістр) …».
-- =====================================================================

begin;

do $fix$
declare
  w record;
  x public.lexemes%rowtype;
  v_set int := 0;
  v_same int := 0;
  v_skip int := 0;
begin
  for w in select * from jsonb_to_recordset({q(json.dumps(items, ensure_ascii=False))}::jsonb) as t(lemma text, register text)
  loop
    select * into x from public.lexemes where lower(lemma) = w.lemma and status = 'PUBLISHED';
    if x.id is null or (x.register is not null and x.register <> w.register) then
      v_skip := v_skip + 1;
      continue;
    end if;
    if x.register = w.register then
      v_same := v_same + 1;
      continue;
    end if;
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', x.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = x.id), 0) + 1,
            to_jsonb(x), {q(NOTE)});
    update public.lexemes
       set register = w.register, version = coalesce(version, 1) + 1, updated_at = now()
     where id = x.id;
    insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
    values ('lexeme', x.id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, {q(NOTE)} || ' register: ' || w.register || '.');
    v_set := v_set + 1;
  end loop;

  -- Самоперевірка: у опублікованих словах лише дозволені й старі значення
  if exists (select 1 from public.lexemes where status = 'PUBLISHED' and register is not null
              and register not in ({', '.join(q(v) for v in ALLOWED + LEGACY)})) then
    raise exception 'register поза переліком: %', (select string_agg(distinct register, ', ') from public.lexemes
      where status = 'PUBLISHED' and register not in ({', '.join(q(v) for v in ALLOWED + LEGACY)}));
  end if;
  raise notice 'Готово: позначено %, уже було %, пропущено (немає / інший регістр) %', v_set, v_same, v_skip;
end
$fix$;

commit;
"""


def row_md(r: dict) -> str:
    return f"*{r['lemma']}* ({r['cefr']}) — {r['ukrainian_translation']}"


def report(rows: list[dict], g: dict) -> str:
    c = Counter(sug for _, sug, *_ in g['apply'])
    in_db = {r['lemma'].lower() for r in rows}
    future = sorted(l for l in RULES if l not in in_db)
    lines = [
        '# Регістр наявних слів словника (2026-11-12)',
        '',
        '> Рішення власника 2026-11-12: скрипт, який порівнює лексеми робочої бази й ставить `register` за визначеннями '
        '`docs/CONTENT_PIPELINE.md` → «Регістр лексем». Згенеровано: `python3 -B scripts/gen_lexeme_register_20261112.py` '
        '(не редагуйте вручну). Правила — `scripts/lexeme_register.py`, знімок бази — `scripts/lexeme_register_20261112_snapshot.json`.',
        '> SQL: `supabase/data_fixes/20261112_lexeme_register.sql` (після мержу й Approve). Бета: позначки ставимо одразу, носій перевіряє після.',
        '',
        '## Визначення',
        '',
        '| `register` | Що означає | Приклади |',
        '|---|---|---|',
        '| порожньо | стандартне, нейтральне | *hvala, kuća, Kako ste?* |',
        '| `informal` | літературне, але неофіційне (друзі, родина, «ти») | *bok, ćao, Kako si?* (замість *Kako ste?*) |',
        '| `colloquial` | розмовне, нелітературне (у словниках — «razg.»), зокрема регіональні діалектні слова | *kužiti, frka, fjaka* |',
        '| `slang` | мова групи (молодь, інтернет, професія) | *frend, fora* |',
        '',
        '## Підсумок',
        '',
        f'- Опублікованих слів у базі: **{PUBLISHED_TOTAL}**; скрипт переглянув **{len(rows)}** — ті, яких стосуються правила, '
        'ознака «звертання на ти», позначки стилю в перекладі, а також усі з `register` чи `regionality`. Решта — стандартні (порожньо).',
        f'- **Позначити: {len(g["apply"])}** — informal {c["informal"]}, colloquial {c["colloquial"]}, slang {c["slang"]}.',
        f'- Уже позначено правильно: {len(g["same"])}; старі значення (нормалізує пакет M24): {len(g["legacy"])}; '
        f'сумнівні (не позначаю, питання носію): {len(g["doubt"]) + len(g["mark"])}.',
        '- Сленгу (*frend, fora, kul…*) у базі поки немає — він з\'явиться з рубрикою «Živi hrvatski» (B1 / B2); '
        'правила для нього вже в `scripts/lexeme_register.py`.',
        '',
        '## 1. Позначити (SQL)',
        '',
        '| Слово | Переклад | `register` | Чому | Джерело |',
        '|---|---|---|---|---|',
    ]
    src_ua = {'rule': 'словник правил', 'ti': 'ознака «ти»'}
    for r, sug, why, src in sorted(g['apply'], key=lambda t: (REGISTERS.index(t[1]), normalize(t[0]['lemma']))):
        lines.append(f"| *{r['lemma']}* ({r['cefr']}) | {r['ukrainian_translation']} | `{sug}` — {UA[sug]} | {why} | {src_ua[src]} |")
    lines += ['', '## 2. Уже позначено — не змінюю', '']
    lines += [f"- {row_md(r)} — `{r['register']}`" for r, *_ in g['same']] or ['- немає']
    lines += [f"- {row_md(r)} — `{r['register']}`{' · ' + r['regionality'] if r.get('regionality') else ''} (правил для слова немає, лишаю)"
              for r in g['skipped'] if r.get('register')]
    lines += ['', '## 3. Старі значення — нормалізує пакет M24 (не в цьому SQL)', '',
              'За планом `docs/proposals/2026-11-12_b1_b2_dialogues_reading_situations.md` §4.2: `regional` → `colloquial` + '
              '`regionality` (уже є) + тег `italianism`; `non_standard` → `colloquial` — разом із `CHECK` у міграції M24.', '']
    lines += [f"- {row_md(r)} — зараз `{r['register']}` → буде `colloquial`" for r, *_ in g['legacy']] or ['- немає']
    lines += ['', '## 4. Питання носію — позначку не ставлю', '']
    lines += [f'- {row_md(r)} — {why}' for r, why in g['doubt']]
    lines += [f'- {row_md(r)} — {why}' for r, why in g['mark']]
    lines += [f'- {row_md(r)} — {why}' for r, why in g['not_ti']]
    lines += ['', '## 5. Регіональні, але стандартні — `register` порожній', '',
              'Регіон (`regionality`) — окремий вимір: ці слова — звичайні назви, не розмовні.', '']
    lines += [f"- {row_md(r)} — {r['regionality']}" for r in g['regional_std']] or ['- немає']
    lines += ['', '## 6. Правила для майбутніх батчів (слів ще немає в базі)', '',
              'Новий батч слів (B1, «Živi hrvatski») перед видачею проганяє `check_register()` з `scripts/lexeme_register.py`: '
              'якщо слово є в правилах, а `register` інший — попередження.', '']
    for reg in REGISTERS:
        ws = [l for l in future if RULES[l][0] == reg]
        lines.append(f"- `{reg}`: " + (', '.join(f'*{w}*' for w in ws) if ws else '—'))
    lines += ['', '## Що варто глянути носію', '',
              '1. Розділ 1: чи справді *super*, *kila*, *cura*, *cimerica*, *gušt* — розмовні (а не нейтральні); '
              'чи *vidimo se*, *čujemo se*, *može* — неофіційні.',
              '2. Розділ 4: *pauk*, *kvadrat* (омоніми), *dečko*, *pomalo*, *ne da mi se*; і чи прибрати «(розм.)» з перекладу '
              '*dućan*, *bilježnik*; *kesa* — регіон і стандартний відповідник.',
              '3. Ввічливі вирази (*Kako ste?, molim vas, izvolite, oprostite*) зараз порожні (стандартні). Позначати їх `formal` — '
              'окреме рішення (визначення `formal` ще немає).',
              '']
    return '\n'.join(lines)


def main() -> int:
    rows = json.loads(SNAP.read_text(encoding='utf-8'))
    g = classify(rows)
    errors = validate(rows, g)
    if errors:
        print('ПОМИЛКИ:\n' + '\n'.join(errors))
        return 1
    OUT.write_text(sql(g), encoding='utf-8')
    REPORT.write_text(report(rows, g), encoding='utf-8')
    c = Counter(sug for _, sug, *_ in g['apply'])
    print(f'OK: {OUT.relative_to(ROOT)}, {REPORT.relative_to(ROOT)}; позначити {len(g["apply"])} '
          f'(informal {c["informal"]}, colloquial {c["colloquial"]}, slang {c["slang"]}); уже {len(g["same"])}, '
          f'старі {len(g["legacy"])}, сумнівні {len(g["doubt"]) + len(g["mark"])}')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
