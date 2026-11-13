#!/usr/bin/env python3
"""
Генератор SQL: 36 нових текстів для читання A2 (програма A2 v2, 4 тексти на модуль) · 2026-11-13.

  python3 -B scripts/gen_reading_a2_v2.py           →  supabase/data_fixes/20261113_reading_a2_v2_part1.sql … _part3.sql
  python3 -B scripts/gen_reading_a2_v2.py --todo    →  слова текстів, яким бракує леми, перекладу, частини мови чи граматики
  python3 -B scripts/gen_reading_a2_v2.py --stats   →  частка знайомих слів і довжина кожного тексту
  python3 -B scripts/gen_reading_a2_v2.py --export  →  словничок кожного тексту для ручної перевірки (друкує в консоль)

Дані: scripts/reading_data_a2_v2.py (тексти й словничок форм кожного тексту), scripts/reading_lexicon_a2_v2.py
(переклади й частини мови слів поза уроками, власні назви), scripts/reading_a2_v2_snapshot.json (слова уроків A0–A2,
які трапляються в текстах: лема, переклад, рівень, модуль A2, частина мови — знімок робочої бази 2026-11-13).
Спільне зі старим генератором (scripts/gen_reading.py): службові слова, форми й граматичні підказки попередніх текстів.
Старий генератор і його файли (уже запущені) цей скрипт не змінює.

Знайомі слова тексту модуля A2.N — слова уроків A0, A1 і уроків A2.1…A2.N, службові слова граматики A0 і власні назви.
Ціль — ≥ 90 % знайомих (як у нових текстах A1, 2026-11-04). SQL ідемпотентний: code унікальний, on conflict do nothing.
"""
import json
import re
import sys
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).parent))
import gen_reading as R  # noqa: E402  (лише функції й словники; main не запускається)
import reading_data_a2_v2 as D  # noqa: E402
import reading_lexicon_a2_v2 as L  # noqa: E402
from full_lessons import q, qj  # noqa: E402

X, G = R.X, R.G
ROOT = Path(__file__).resolve().parent.parent
SNAP_PATH = Path(__file__).parent / 'reading_a2_v2_snapshot.json'
SNAP: dict = json.loads(SNAP_PATH.read_text(encoding='utf-8'))['lexemes'] if SNAP_PATH.exists() else {}
OUT = ROOT / 'supabase' / 'data_fixes' / '20261113_reading_a2_v2_part{}.sql'
FIRST = 21          # RD-A2-021 … RD-A2-056
MIN_KNOWN = 0.9
WORDS = (60, 140)
PART_MAX = 240_000  # байтів на частину (ліміт SQL Editor ~300 КБ)
SOURCE = 'claude_reading_a2_v2'
NOTE = ('Бета: тексти для читання A2 за програмою A2 v2 (4 на модуль), reading_a2_v2 2026-11-13. '
        'Знайомі слова — уроки A0, A1 і A2 до модуля тексту. Потрібна перевірка носієм.')
EXPECT_PER_MODULE = {m: (4 if m in (2, 8, 11, 12) else 2) for m in range(1, 15)}

errors: list[str] = []

# ---------------------------------------------------------------- тексти й коди
TEXTS = sorted(D.TEXTS, key=lambda t: t['module'])  # стабільне сортування: у межах модуля — порядок у файлі
for _i, _t in enumerate(TEXTS):
    _t['code'] = f'RD-A2-{FIRST + _i:03d}'
BY_KEY = {t['key']: t for t in TEXTS}


def parse_ann(text: str, where: str) -> dict[str, tuple[str, str | None, str | None]]:
    """«форма = лема | граматика | переклад» → {форма: (лема, граматика, переклад)}."""
    out: dict = {}
    for raw in text.strip().splitlines():
        line = raw.strip()
        if not line or line.startswith('#'):
            continue
        if ' = ' not in line:
            errors.append(f'{where}: рядок словничка без « = »: {line!r}')
            continue
        form, rest = line.split(' = ', 1)
        parts = [p.strip() for p in rest.split(' | ')]
        lemma = parts[0]
        gram = parts[1] if len(parts) > 1 and parts[1] else None
        ua = parts[2] if len(parts) > 2 and parts[2] else None
        if ua and ua.startswith('~'):  # «~пояснення» — це не переклад, а пояснення до граматики форми
            gram, ua = f'{gram} | {ua[1:].strip()}', None
        form = form.strip().lower()
        if form in out:
            errors.append(f'{where}: форма «{form}» двічі')
        out[form] = (lemma, gram, ua)
    return out


COMMON = parse_ann(L.COMMON, 'COMMON')
ANN = {t['key']: parse_ann(L.TEXT_ANN.get(t['key'], ''), t['key']) for t in TEXTS}
for _k in L.TEXT_ANN:
    if _k not in BY_KEY:
        errors.append(f'TEXT_ANN: тексту «{_k}» немає')

# ---------------------------------------------------------------- граматика: додаткові коди
PERSON = {'1s': 'я', '2s': 'ти', '3s': 'він / вона / воно', '1p': 'ми', '2p': 'ви (і ввічливе «Ви»)', '3p': 'вони'}
COND_RE = re.compile(r'^cond([123][sp])$')


def render_gram(code: str, lemma: str) -> str:
    head, _, note = code.partition(' | ')
    if head.endswith('+mw'):
        return render_gram(head[:-3] + (' | ' + note if note else ''), lemma) + f'; частина виразу «{lemma}»'
    text = None
    if head == 'mw':
        text = f'частина сталого виразу «{lemma}»'
    elif head == 'inf':
        text = 'інфінітив (неозначена форма дієслова)'
    elif head == 'comp':
        text = 'вищий ступінь (який? — більш …)'
    elif head == 'sup':
        text = 'найвищий ступінь (най…)'
    elif head == 'adv':
        text = 'прислівник (як?), утворений від прикметника'
    elif head == 'im1p':
        text = 'наказовий спосіб: ми (зробімо!)'
    elif COND_RE.match(head):
        text = f'умовний спосіб: {PERSON[COND_RE.match(head).group(1)]} (+ форма на -l: «htjela bih» — я хотіла б)'
    if text is None:
        return R.render_gram(code)
    if not note:
        return text
    return f"{text}. {note[0].upper()}{note[1:]}"


# ---------------------------------------------------------------- слова
def name_info(tok: str):
    """Власна назва → (лема, переклад, частина мови) або None."""
    if tok in L.NAMES:
        pos, ua = L.NAMES[tok]
        return tok, ua, pos
    for name in (tok, tok.capitalize()):
        if name in X.NAMES:
            return name, X.NAMES[name], G.POS.get(name, 'place')
    return None


def lemma_ua(lemma: str) -> str | None:
    key = lemma.lower()
    for src in (L.EXTRA, X.EXTRA):
        if key in src:
            return src[key]
    if key in SNAP:
        return SNAP[key][1]
    if key in R.LEX and R.LEX[key][2]:
        return R.LEX[key][1]
    if lemma in L.NAMES:
        return L.NAMES[lemma][1]
    return None


def lemma_pos(lemma: str) -> str | None:
    key = lemma.lower()
    if lemma in L.NAMES:
        return L.NAMES[lemma][0]
    for src in (L.POS, G.POS):
        if lemma in src:
            return src[lemma]
        if key in src:
            return src[key]
    if key in SNAP and SNAP[key][4]:
        return SNAP[key][4]
    return None


def is_known(lemma: str, module: int) -> bool:
    key = lemma.lower()
    if lemma in L.NAMES or key in X.KNOWN or key in L.KNOWN:
        return True
    if key in SNAP and SNAP[key][2]:
        lvl, mod = SNAP[key][2], SNAP[key][3]
        return lvl in ('A0', 'A1') or (lvl == 'A2' and mod is not None and mod <= module)
    # слова, яких немає в уроках окремо, але старий знімок рахує знайомими (prijevod — у виразі уроку A1 «ovjereni prijevod»)
    return key in R.LEX and R.LEX[key][2] in ('A0', 'A1')


def resolve(t, tok: str):
    """Слово тексту → dict(lemma, ua, known, gram, pos, lesson) або None (з причиною в 'why')."""
    low = tok.lower()
    a = ANN[t['key']].get(low) or COMMON.get(low)
    gram = None
    if a:
        lemma, gram, ua = a
        ua = ua or lemma_ua(lemma)
        pos = lemma_pos(lemma)
    else:
        nm = name_info(tok)
        if nm:
            lemma, ua, pos = nm
        else:
            lemma = X.FORMS.get(low, low)
            ua = lemma_ua(lemma)
            pos = lemma_pos(lemma)
            if low != lemma.lower():
                gram = G.GRAM.get(f'{low}@{lemma}') or G.GRAM.get(low)
    key = lemma.lower()
    lesson = bool(SNAP[key][2]) if key in SNAP else bool(key in R.LEX and R.LEX[key][2])
    return dict(lemma=lemma, ua=ua, pos=pos, gram=gram, known=is_known(lemma, t['module']), lesson=lesson)


def glossary(t):
    seen: dict[str, dict] = {}
    known = 0
    toks = R.words(t['hr'])
    for tok in toks:
        r = resolve(t, tok)
        known += r['known']
        low = tok.lower()
        if low in seen:
            continue
        e = {'form': low, 'lemma': r['lemma'], 'ua': r['ua'], 'lesson': r['lesson']}
        if r['pos']:
            e['pos'] = R.render_pos(r['pos'])
        if r['gram']:
            e['gram'] = render_gram(r['gram'], r['lemma'])
        seen[low] = e
    return list(seen.values()), (known / len(toks) if toks else 0.0), len(toks)


# ---------------------------------------------------------------- перевірки
def validate():
    per_module: dict[int, int] = {}
    keys = [t['key'] for t in TEXTS]
    if len(keys) != len(set(keys)):
        errors.append('ключі текстів повторюються')
    if len(TEXTS) != 36:
        errors.append(f'текстів {len(TEXTS)}, очікувалось 36')
    old_titles = {t['title'][1].lower() for t in R.D2.TEXTS}
    for t in TEXTS:
        w = f"{t['code']} ({t['key']})"
        per_module[t['module']] = per_module.get(t['module'], 0) + 1
        if t['type'] not in R.TYPES or t['type'] == 'sign':
            errors.append(f'{w}: тип {t["type"]!r}')
        if t['situation'] is not None and t['situation'] not in R.SITUATIONS:
            errors.append(f'{w}: ситуація {t["situation"]!r}')
        ua_title, hr_title = t['title']
        if not R.CYR.search(ua_title) or R.CYR.search(hr_title) or hr_title.lower() in old_titles:
            errors.append(f'{w}: назва (ua, hr; не як у наявних текстах)')
        if R.CYR.search(t['hr']):
            errors.append(f'{w}: кирилиця в хорватському тексті')
        if not R.CYR.search(t['ua']) or re.search(r'[ыэъё]', t['ua'].lower()):
            errors.append(f'{w}: переклад має бути українською (без ы, э, ъ, ё)')
        n = len(R.words(t['hr']))
        if not (WORDS[0] <= n <= WORDS[1]):
            errors.append(f'{w}: {n} слів (для A2: {WORDS[0]}–{WORDS[1]})')
        if len(re.findall(r'\b[A-Z]\d\b', t['hr'])):
            errors.append(f'{w}: позначка рівня (A1, B1…) у тексті розбивається на слова — краще словами')
        if len(t['questions']) != 3:
            errors.append(f'{w}: потрібно 3 питання')
        for qu, opts, ans in t['questions']:
            if (not R.CYR.search(qu) or len(opts) != 3 or len(set(opts)) != 3 or ans not in opts
                    or any(re.search(r'[A-Za-zČĆĐŠŽčćđšž]{3,}', o) for o in opts)):
                errors.append(f'{w}: питання «{qu}» — 3 різні варіанти українською, серед них відповідь')
        used = {tok.lower() for tok in R.words(t['hr'])}
        for form in ANN[t['key']]:
            if form not in used:
                errors.append(f'{w}: у словничку є «{form}», але в тексті такого слова немає')
        entries, ratio, _ = glossary(t)
        for e in entries:
            ua = (e['ua'] or '').strip()
            if (not ua or not R.CYR.search(ua) or ua.lower() in R.PLACEHOLDERS and e['lemma'].lower() != 'prijevod'
                    or 'базовий термін' in ua.lower()):
                errors.append(f'{w}: «{e["form"]}» ({e["lemma"]}) — немає перекладу')
            if R.CYR.search(e['lemma']):
                errors.append(f'{w}: «{e["form"]}» — лема кирилицею')
            if 'pos' not in e:
                errors.append(f'{w}: «{e["lemma"]}» — немає частини мови')
            if e['form'] != e['lemma'].lower() and 'gram' not in e:
                errors.append(f'{w}: «{e["form"]}» ({e["lemma"]}) — немає граматичної підказки')
            for k in ('pos', 'gram'):
                if k in e and (len(e[k]) > 160 or not R.CYR.search(e[k])):
                    errors.append(f'{w}: «{e["form"]}» — {k} має бути українською, до 160 символів: {e[k]!r}')
        if ratio < MIN_KNOWN:
            errors.append(f'{w}: знайомих слів {ratio:.0%} (потрібно ≥ {MIN_KNOWN:.0%})')
    for m, n in EXPECT_PER_MODULE.items():
        if per_module.get(m, 0) != n:
            errors.append(f'модуль A2.{m}: нових текстів {per_module.get(m, 0)}, очікувалось {n}')
    for key, ua in L.EXTRA.items():
        if not R.CYR.search(ua):
            errors.append(f'EXTRA: {key} — переклад українською')
    for key in L.EXTRA:
        if key in SNAP and key not in ('oko', 'izdati'):  # oko, izdati — інше значення, ніж у словнику застосунку
            errors.append(f'EXTRA: «{key}» є в словнику застосунку — переклад беремо з бази, з EXTRA прибрати')


# ---------------------------------------------------------------- SQL
def header(part: int, parts: int, texts: list) -> str:
    return f"""-- =====================================================================
-- Тексти для читання A2 v2 · частина {part} з {parts} · reading_a2_v2 · 2026-11-13
-- Згенеровано: python3 -B scripts/gen_reading_a2_v2.py (не редагуйте вручну).
-- Запускає workflow «Apply SQL (production)» після мержу й Approve власника. Потрібна міграція M15.
--   * {len(texts)} нових текстів ({texts[0]['code']} … {texts[-1]['code']}) за програмою A2 v2: 4 тексти на модуль
--     (до 20 наявних — по 2 у модулі A2.1, 3, 4, 5, 6, 7, 9, 10, 13, 14 і по 4 у A2.2, 8, 11, 12).
--   * У кожного: повний переклад, словничок «слово → лема → переклад» з частиною мови й граматикою,
--     3 питання, частка знайомих слів (уроки A0–A1 і A2 до модуля тексту, усі ≥ 90 %).
--   * Статус PUBLISHED — бета, як уроки A2 (носій ще не перевіряв). Наявні тексти не змінюються.
--   * Повторний запуск нічого не змінює (code унікальний).
-- =====================================================================

begin;

do $$
begin
  if to_regclass('public.reading_texts') is null then
    raise exception 'Спершу запустіть міграцію M15 (20261014100000_m15_reading.sql)';
  end if;
end $$;
"""


def build_part(part: int, parts: int, texts: list) -> str:
    out = [header(part, parts, texts)]
    for t in texts:
        gl, ratio, n = glossary(t)
        qs = [{'question_ua': qu, 'options': opts, 'answer': ans} for qu, opts, ans in t['questions']]
        ua_title, hr_title = t['title']
        order = int(t['code'][-3:])
        out.append(
            'insert into public.reading_texts (code, cefr, text_type, situation, module_order, title_ua, title_hr, body_hr, body_ua, '
            'glossary, questions, word_count, known_ratio, order_index, status, source, published_at)\n'
            f"values ({q(t['code'])}, 'A2', {q(t['type'])}, {q(t['situation'])}, {t['module']}, {q(ua_title)}, {q(hr_title)},\n"
            f"        {q(t['hr'])},\n        {q(t['ua'])},\n"
            f"        {qj(gl)},\n        {qj(qs)}, {n}, {ratio:.3f}, {order}, 'PUBLISHED', {q(SOURCE)}, now())\n"
            'on conflict (code) do nothing;'
        )
    codes = ', '.join(q(t['code']) for t in texts)
    out.append(f"""
-- Журнал перевірки (один запис на текст)
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'reading_text', r.id, null, r.status, 'auto_passed', 'ai', '[]'::jsonb, {q(NOTE)}
from public.reading_texts r
where r.code in ({codes})
  and not exists (select 1 from public.content_reviews c where c.entity_id = r.id and c.notes = {q(NOTE)});

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_total int; v_bad int;
begin
  select count(*) into v_total from public.reading_texts
   where code in ({codes}) and cefr = 'A2' and status = 'PUBLISHED' and source = {q(SOURCE)} and module_order between 1 and 14;
  select count(*) into v_bad from public.reading_texts r where r.code in ({codes})
     and (jsonb_array_length(r.questions) <> 3 or r.known_ratio < {MIN_KNOWN}
          or exists (select 1 from jsonb_array_elements(r.glossary) e
                     where e->>'pos' is null or coalesce(e->>'ua', '') = ''
                        or (e->>'gram' is null and e->>'form' <> lower(e->>'lemma'))));
  if v_total <> {len(texts)} then raise exception 'Нових текстів A2 %, очікувалось {len(texts)} (код уже зайнятий іншим текстом?)', v_total; end if;
  if v_bad > 0 then raise exception '% текстів без питань, словничка чи граматичних підказок', v_bad; end if;
  raise notice 'Готово: нових текстів A2 у частині {part} — % ({texts[0]['code']} … {texts[-1]['code']})', v_total;
end $$;
""")
    if part == parts:
        out.append(f"""-- Підсумок рівня: 4 тексти в кожному з 14 модулів A2
do $$
declare v_bad int; v_all int;
begin
  select count(*) into v_all from public.reading_texts where cefr = 'A2' and status = 'PUBLISHED';
  select count(*) into v_bad from (
    select m.n, count(r.id) c from generate_series(1, 14) m(n)
    left join public.reading_texts r on r.cefr = 'A2' and r.status = 'PUBLISHED' and r.module_order = m.n
    group by m.n) x where x.c < 4;
  if v_bad > 0 then raise exception 'У % модулях A2 менше 4 текстів (спершу частина 1?)', v_bad; end if;
  raise notice 'Готово: текстів A2 разом — % (по 4 у кожному з 14 модулів)', v_all;
end $$;
""")
    out.append('commit;\n')
    return '\n'.join(out)


def build() -> list[str]:
    n = 12  # по 12 текстів: частина ~200 КБ (ліміт SQL Editor ~300 КБ)
    groups = [TEXTS[i:i + n] for i in range(0, len(TEXTS), n)]
    return [build_part(i + 1, len(groups), g) for i, g in enumerate(groups)]


# ---------------------------------------------------------------- допоміжні режими
def todo() -> str:
    lines = []
    for t in TEXTS:
        miss = []
        for tok in dict.fromkeys(R.words(t['hr'])):
            r = resolve(t, tok)
            why = []
            if not r['ua']:
                why.append('лема/переклад')
            if not r['pos']:
                why.append('POS')
            if tok.lower() != r['lemma'].lower() and not r['gram']:
                why.append('gram')
            if why:
                miss.append(f"{tok}→{r['lemma']} [{', '.join(why)}]")
        if miss:
            lines.append(f"## {t['key']} (A2.{t['module']}): " + '; '.join(miss))
    return '\n'.join(lines)


def stats() -> str:
    rows = []
    for t in TEXTS:
        gl, ratio, n = glossary(t)
        unk = sorted({tok.lower() for tok in R.words(t['hr']) if not resolve(t, tok)['known']})
        rows.append(f"{t['code']} A2.{t['module']:<2} {t['key']:<18} {n:>3} сл. {ratio:6.1%}  незнайомі: {', '.join(unk)}")
    return '\n'.join(rows)


def export() -> str:
    out = ['# Тексти A2 v2 — словничок для перевірки (згенеровано gen_reading_a2_v2.py --export)\n']
    for t in TEXTS:
        gl, ratio, n = glossary(t)
        out.append(f"## {t['code']} · A2.{t['module']} · {t['title'][0]} ({n} сл., {ratio:.0%} знайомих)\n")
        for e in gl:
            out.append(f"- **{e['form']}** → {e['lemma']} — {e['ua']} · _{e.get('pos', '?')}_" + (f" · {e['gram']}" if 'gram' in e else ''))
        out.append('')
    return '\n'.join(out)


if __name__ == '__main__':
    if '--todo' in sys.argv:
        print(todo())
        sys.exit(0)
    validate()
    if '--stats' in sys.argv:
        print(stats())
        print('ПОМИЛОК:', len(errors))
        sys.exit(0)
    if errors:
        print('ПОМИЛКИ В ДАНИХ:', *errors, sep='\n  ')
        sys.exit(1)
    if '--export' in sys.argv:
        print(export())
        sys.exit(0)
    for i, sql in enumerate(build(), 1):
        size = len(sql.encode())
        if size > PART_MAX + 40_000:
            raise SystemExit(f'частина {i}: {size // 1024} КБ — забагато, розбийте на більше частин')
        path = Path(str(OUT).format(i))
        path.write_text(sql, encoding='utf-8')
        print(f'OK → {path.relative_to(ROOT)}: {size // 1024} КБ')
