#!/usr/bin/env python3
"""
Генератор SQL: 56 фраз A2 (public.phrases) за програмою A2 v2 — 4 на модуль · 2026-11-13.

  python3 -B scripts/gen_phrases_a2.py   →  supabase/data_fixes/20261113_phrases_a2_v2.sql

Дані: scripts/phrases_a2_data.py. Перевірки: ситуація з lib/situations.ts, без кирилиці в хорватському,
переклад українською, без дублів (зокрема з наявними фразами — scripts/phrases_existing_snapshot.txt,
знімок робочої бази 2026-11-13), мітки register / regionality / usage_tags (check_labels, LEARNING_SPEC §18).
SQL: один DO-блок через jsonb_to_recordset, id — uuid5, on conflict do nothing (унікальний lower(text_hr)),
журнал content_reviews, самоперевірка. Статус PUBLISHED — бета, як уроки A2.
"""
import json
import re
import sys
import unicodedata
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).parent))
from full_lessons import q, uid  # noqa: E402
from lexeme_checks import check_labels  # noqa: E402
from phrases_a2_data import PHRASES  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / 'supabase' / 'data_fixes' / '20261113_phrases_a2_v2.sql'
EXISTING = Path(__file__).parent / 'phrases_existing_snapshot.txt'
SITUATIONS = set(re.findall(r"code: '([a-z_]+)'", (ROOT / 'lib' / 'situations.ts').read_text(encoding='utf-8')))
SOURCE = 'claude_phrases_a2_v2'
NOTE = ('Бета: фрази A2 за програмою A2 v2 (4 на модуль), phrases_a2_v2 2026-11-13. '
        'Потрібна перевірка носієм.')
CYR = re.compile(r'[Ѐ-ӿ]')
SERBIAN = re.compile(r'\b(hiljad\w*|tačno|uopšte|ko|šta|gde|lep\w*|treba da|da li|biti ću|hleb|grešk\w*|nedelj\w*|voz)\b', re.I)


def normalized(text: str) -> str:
    """Як у словнику: малими літерами, без діакритики (đ → d), пробіли — по одному."""
    t = text.lower().replace('đ', 'd')
    t = ''.join(c for c in unicodedata.normalize('NFD', t) if unicodedata.category(c) != 'Mn')
    return re.sub(r'\s+', ' ', t).strip()


def rows() -> list[dict]:
    out = []
    for module, situation, hr, ua, register, tags in PHRASES:
        out.append(dict(id=uid('phrase_a2_v2', hr), module=module, text_hr=hr, normalized=normalized(hr),
                        ukrainian_translation=ua, situation=situation,
                        phrase_type='question' if hr.endswith('?') else 'phrase',
                        register=register, regionality='general', usage_tags=tags))
    return out


def validate(data: list[dict]) -> list[str]:
    errors = []
    if len(data) != 56:
        errors.append(f'фраз {len(data)}, очікувалось 56')
    per_module: dict[int, int] = {}
    existing = {line.strip().lower() for line in EXISTING.read_text(encoding='utf-8').splitlines()
                if line.strip() and not line.startswith('#')}
    seen = set()
    for r in data:
        w = r['text_hr']
        per_module[r['module']] = per_module.get(r['module'], 0) + 1
        if r['situation'] not in SITUATIONS:
            errors.append(f'{w}: ситуація {r["situation"]!r} — немає в lib/situations.ts')
        if CYR.search(w) or not CYR.search(r['ukrainian_translation']):
            errors.append(f'{w}: хорватське без кирилиці, переклад — українською')
        if re.search(r'[ыэъё]', r['ukrainian_translation'].lower()) or re.search(r'[a-zčćđšž]{3,}', r['ukrainian_translation'].replace('OIB', '')):
            errors.append(f'{w}: у перекладі російські літери чи латиниця')
        if not re.search(r'[.!?]$', w) or w[0] != w[0].upper():
            errors.append(f'{w}: речення — з великої літери і з розділовим знаком у кінці')
        if (w.endswith('?')) != r['ukrainian_translation'].endswith('?'):
            errors.append(f'{w}: питання ↔ переклад (знак питання)')
        if SERBIAN.search(w):
            errors.append(f'{w}: сербізм / не хорватська норма ({SERBIAN.search(w).group(0)})')
        key = w.lower()
        if key in seen:
            errors.append(f'{w}: повтор у пакеті')
        if key in existing:
            errors.append(f'{w}: така фраза вже є в базі')
        seen.add(key)
        e, _ = check_labels(r)
        errors += [f'{w}: {x}' for x in e]
    for m in range(1, 15):
        if per_module.get(m, 0) != 4:
            errors.append(f'модуль A2.{m}: фраз {per_module.get(m, 0)}, очікувалось 4')
    return errors


def build(data: list[dict]) -> str:
    payload = [{k: r[k] for k in ('id', 'text_hr', 'normalized', 'ukrainian_translation', 'situation', 'phrase_type',
                                  'register', 'regionality', 'usage_tags')} for r in data]
    js = json.dumps(payload, ensure_ascii=False, indent=1)
    ids = ', '.join(q(r['id']) for r in data)
    return f"""-- =====================================================================
-- Фрази A2 (public.phrases) · програма A2 v2 · phrases_a2_v2 · 2026-11-13
-- Згенеровано: python3 -B scripts/gen_phrases_a2.py (не редагуйте вручну).
-- Запускає workflow «Apply SQL (production)» після мержу й Approve власника.
--   * {len(data)} фраз рівня A2, по 4 на кожен із 14 модулів: готові висловлювання для туризму, навчання,
--     роботи, установ, здоров'я, авто, неприємностей, звичаїв, життя українців у Хорватії, планів.
--   * Ситуація — код з lib/situations.ts (фрази з'являються в розділі «Ситуації»).
--   * Мітки (LEARNING_SPEC §18): register, regionality = general, usage_tags.
--   * Статус PUBLISHED — бета, як уроки A2. Наявні фрази не змінюються; повторний запуск нічого не додає.
-- =====================================================================

begin;

do $phr$
declare v_new int;
begin
  insert into public.phrases (id, text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples,
                              status, source, register, regionality, usage_tags, published_at)
  select x.id, x.text_hr, x.normalized, x.ukrainian_translation, 'A2', x.situation, x.phrase_type, '[]'::jsonb,
         'PUBLISHED', {q(SOURCE)}, x.register, x.regionality, x.usage_tags, now()
  from jsonb_to_recordset($json${js}$json$::jsonb)
       as x(id uuid, text_hr text, normalized text, ukrainian_translation text, situation text, phrase_type text,
            register text, regionality text, usage_tags text[])
  on conflict do nothing;
  get diagnostics v_new = row_count;
  raise notice 'Додано фраз: %', v_new;
end $phr$;

-- Журнал перевірки (один запис на фразу)
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'phrase', p.id, null, p.status, 'auto_passed', 'ai', '[]'::jsonb, {q(NOTE)}
from public.phrases p
where p.id in ({ids})
  and not exists (select 1 from public.content_reviews c where c.entity_id = p.id and c.notes = {q(NOTE)});

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_total int; v_bad int;
begin
  select count(*) into v_total from public.phrases
   where id in ({ids}) and cefr = 'A2' and status = 'PUBLISHED' and source = {q(SOURCE)};
  select count(*) into v_bad from public.phrases
   where id in ({ids}) and (register is null or regionality is null or usage_tags is null or situation is null);
  if v_total <> {len(data)} then
    raise exception 'Фраз A2 з цього пакета %, очікувалось {len(data)} (така фраза вже є з іншим id?)', v_total;
  end if;
  if v_bad > 0 then raise exception '% фраз без міток чи ситуації', v_bad; end if;
  raise notice 'Готово: фраз A2 — % (по 4 на модуль)', v_total;
end $$;

commit;
"""


if __name__ == '__main__':
    data = rows()
    errs = validate(data)
    if errs:
        print('ПОМИЛКИ В ДАНИХ:', *errs, sep='\n  ')
        sys.exit(1)
    sql = build(data)
    OUT.write_text(sql, encoding='utf-8')
    print(f'OK → {OUT.relative_to(ROOT)}: {len(data)} фраз, {len(sql.encode()) // 1024} КБ')
