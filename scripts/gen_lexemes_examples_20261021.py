#!/usr/bin/env python3
"""
Приклади для слів словника без прикладів · 2026-10-21.

  python3 -B scripts/gen_lexemes_examples_20261021.py
    → supabase/data_fixes/20261021_lexemes_examples_a0_a1.sql   (A0 / A1 — бета, запускати одразу)
    → supabase/data_fixes/20261021_lexemes_examples_a2_b1.sql   (A2 / B1 — лише після «ок» власника)
    → content/reviews/2026-10-21_lexemes_examples.md            (усі речення для перевірки носієм)

Дані — scripts/lexemes_examples_data.py. Запускати ПІСЛЯ 20261021_lexemes_grammar_fields.sql.
SQL додає приклад лише слову, у якого прикладів досі немає (examples = '[]'), тож нічого не перезаписує
і повторний запуск нічого не змінює. Стара версія — у content_versions, запис у content_reviews.
"""
import json
import re
import sys
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).parent))
from full_lessons import q  # noqa: E402
import lexemes_examples_data as D  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
FIXES = ROOT / 'supabase' / 'data_fixes'
REVIEW_MD = ROOT / 'content' / 'reviews' / '2026-10-21_lexemes_examples.md'
CYR = re.compile(r'[Ѐ-ӿ]')
PLACEHOLDER = re.compile(r'(Važno je .* u ovoj situaciji|dio svakodnevnog života|često se koristi|Primjer rečenice'
                         r'|To je vrlo [a-zčćđšž]+\.|\btodo\b|\bxxx\b|\.\.\.)', re.I)
FOLD = str.maketrans('čćđšž', 'ccdsz')


def fold(t: str) -> str:
    return t.lower().translate(FOLD)


def contains_lemma(lemma: str, sentence: str) -> bool:
    """Груба перевірка: кожне змістове слово леми (≥ 3 літер) трапляється в реченні хоча б основою з 3–4 літер."""
    words = [w for w in re.findall(r'[a-zčćđšž]+', lemma.lower()) if len(w) >= 3 and w not in ('sam', 'se')]
    text = fold(sentence)
    for w in words or re.findall(r'[a-zčćđšž]+', lemma.lower()):
        stem = fold(w)[:4 if len(w) >= 6 else 3]
        if stem not in text:
            return False
    return True


def validate() -> list[tuple[str, str]]:
    errors, unsure = [], []
    for part in (D.BETA, D.REVIEW):
        for lemma, s in part.items():
            if CYR.search(s):
                errors.append(f'{lemma}: кирилиця в прикладі')
            if PLACEHOLDER.search(s):
                errors.append(f'{lemma}: схоже на заглушку')
            if not re.match(r'^[A-ZČĆĐŠŽ„]', s) or not re.search(r'[.!?]$', s):
                errors.append(f'{lemma}: речення має починатися з великої й закінчуватися . ! ?')
            if not 8 <= len(s) <= 110:
                errors.append(f'{lemma}: довжина {len(s)}')
            if not contains_lemma(lemma, s):
                unsure.append((lemma, s))
    sentences = [s for p in (D.BETA, D.REVIEW) for s in p.values()]
    if len(sentences) != len(set(sentences)):
        errors.append('однакові речення в різних слів')
    if errors:
        raise SystemExit('Помилки:\n  ' + '\n  '.join(errors))
    return unsure


def build(rows: dict[str, str], *, tag: str, title: str, levels: str, note: str) -> str:
    data = json.dumps([{'k': k, 'e': v} for k, v in sorted(rows.items())], ensure_ascii=False, indent=0)
    version_note = f'lexemes_examples_20261021_{tag}: додано приклад — стара версія'
    review = (f'Приклад додано 2026-10-21 ({levels}; scripts/lexemes_examples_data.py). {note} '
              'Потрібна перевірка носієм: content/reviews/2026-10-21_lexemes_examples.md.')
    return f"""-- =====================================================================
-- {title} · 2026-10-21
-- Згенеровано: python3 -B scripts/gen_lexemes_examples_20261021.py (не редагуйте вручну).
--
--   * {len(rows)} слів ({levels}), у яких не було жодного прикладу, отримують одне природне речення.
--   * Змінюється лише слово, у якого прикладів досі немає (examples = '[]'): наявні приклади не чіпаємо,
--     повторний запуск нічого не змінює. Стара версія → content_versions, запис у content_reviews.
--   * {note}
-- Спершу має бути запущено 20261021_lexemes_grammar_fields.sql.
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

do $fix$
declare
  d record;
  r record;
  v_changed int := 0;
  v_missing text := '';
begin
  if exists (select 1 from public.lexemes where lower(lemma) in ('vzdahnuti', 'ravnatitelj')) then
    raise exception 'Спершу запустіть supabase/data_fixes/20261021_lexemes_grammar_fields.sql';
  end if;
  for d in select * from jsonb_to_recordset({q(data)}::jsonb) as t(k text, e text)
  loop
    select * into r from public.lexemes
     where lower(lemma) = d.k and status <> 'DEPRECATED';
    if not found then
      v_missing := v_missing || d.k || '; ';
      continue;
    end if;
    if coalesce(r.examples, '[]'::jsonb) <> '[]'::jsonb then
      continue;
    end if;
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id,
            coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), {q(version_note)});
    update public.lexemes set examples = jsonb_build_array(d.e), version = coalesce(version, 1) + 1 where id = r.id;
    insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
    values ('lexeme', r.id, r.status, r.status, 'auto_passed', 'ai', '[]'::jsonb, {q(review)});
    v_changed := v_changed + 1;
  end loop;
  if v_missing <> '' then raise notice 'Немає в словнику (пропущено): %', v_missing; end if;
  raise notice 'Додано прикладів зараз: %', v_changed;
end
$fix$;

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_empty int; v_done int;
begin
  select count(*) into v_empty from public.lexemes l
   where l.status <> 'DEPRECATED' and l.examples = '[]'::jsonb
     and lower(l.lemma) in (select t.k from jsonb_to_recordset({q(json.dumps([{'k': k} for k in sorted(rows)], ensure_ascii=False))}::jsonb) as t(k text));
  select count(*) into v_done from public.content_reviews where notes = {q(review)};
  if v_empty > 0 then raise exception 'Лишилось слів без прикладу: %', v_empty; end if;
  raise notice 'Готово: приклади ({levels}) додано (записів у журналі перевірки: %)', v_done;
end $$;

commit;
"""


def review_md(unsure: list[tuple[str, str]]) -> str:
    lines = [
        '# Приклади для слів словника — перевірка носієм (2026-10-21)',
        '',
        'Пакет: `scripts/lexemes_examples_data.py` → `supabase/data_fixes/20261021_lexemes_examples_a0_a1.sql` (бета, A0/A1) '
        'і `20261021_lexemes_examples_a2_b1.sql` (A2/B1, після «ок» власника).',
        f'Усього: {len(D.BETA)} речень A0/A1 і {len(D.REVIEW)} речень A2/B1. Кожне слово, у якого не було прикладу, '
        'отримало одне речення; наявні приклади не змінювались.',
        '',
        '## Що варто глянути носію насамперед',
        '',
        '- Речення, де слово стоїть у формі, далекій від леми (автоматична перевірка не знайшла основу леми) — список нижче.',
        '- Розмовні / регіональні слова: *kusur*, *pasoš*, *apoteka*, *greška*, *onak* — речення природні, але слово не стандартне.',
        '- Вид дієслова в реченні (доконаний / недоконаний) — особливо для пар на кшталт *dogovarati / dogovoriti*.',
        '',
        '### Основу леми в реченні не знайдено автоматично',
        '',
        'Переглянуто вручну 2026-10-21: усі нижче — звичайні відмінкові чи особові форми (lipnju, drži, plače, kišem…), '
        'слово в реченні є. *glatak* — варіант стандартного *gladak* (у словнику обидва; у реченні — *gladak*).',
        '',
        '| Лема | Речення |',
        '|---|---|',
    ]
    lines += [f'| {k} | {s} |' for k, s in unsure] or ['| — | — |']
    for title, part in (('A0 / A1 (бета)', D.BETA), ('A2 / B1 (після «ок» власника)', D.REVIEW)):
        lines += ['', f'## {title}', '', '| Лема | Приклад |', '|---|---|']
        lines += [f'| {k} | {v} |' for k, v in sorted(part.items())]
    return '\n'.join(lines) + '\n'


if __name__ == '__main__':
    unsure = validate()
    FIXES.mkdir(parents=True, exist_ok=True)
    a = FIXES / '20261021_lexemes_examples_a0_a1.sql'
    b = FIXES / '20261021_lexemes_examples_a2_b1.sql'
    a.write_text(build(D.BETA, tag='a0_a1', title='Приклади для слів A0 / A1 без прикладів', levels='A0 / A1',
                       note='Бета, як уроки A0 / A1 (рішення власника 2026-10-12): носій перевіряє після публікації.'),
                 encoding='utf-8')
    b.write_text(build(D.REVIEW, tag='a2_b1', title='Приклади для слів A2 / B1 без прикладів', levels='A2 / B1',
                       note='Запускати лише після «ок» власника (A2+ — не бета).'), encoding='utf-8')
    REVIEW_MD.parent.mkdir(parents=True, exist_ok=True)
    REVIEW_MD.write_text(review_md(unsure), encoding='utf-8')
    for f in (a, b, REVIEW_MD):
        print(f'{f.relative_to(ROOT)}: {f.stat().st_size // 1024} КБ')
    print(f'Перевірити вручну (основу леми не знайдено): {len(unsure)}')
