#!/usr/bin/env python3
"""
Генератор SQL для текстів читання (§6 ТЗ «Extensive Reading»), reading_a1_v1 · 2026-10-14.

  python3 scripts/gen_reading.py            →  supabase/data_fixes/20261015_reading_a1_grammar.sql (оновлення словничка вже
                                               завантажених текстів A1: граматичні підказки, точніші леми; стара версія — у content_versions)
                                             + supabase/data_fixes/20261015_reading_a0_v1.sql (вивіски A0, PUBLISHED — бета, як A0)
                                             + supabase/data_fixes/20261015_reading_a2_v1_part1.sql, _part2.sql (тексти A2, DRAFT — до рішення власника)
                                             + supabase/data_fixes/20261015_reading_a2_publish.sql (опублікувати A2 — запускає власник)
                                             + supabase/data_fixes/20261015_reading_a0_questions.sql (оновити вже завантажені тексти A0 до поточних даних)
  python3 scripts/gen_reading.py --v1       →  ще й supabase/data_fixes/20261014_reading_a1_v1.sql (перший пакет, уже застосований)
  python3 scripts/gen_reading.py --unknown  →  слова текстів, яких ще немає в словничку (для наповнення reading_lexicon.py)
  python3 scripts/gen_reading.py --stats    →  частка знайомих слів у кожному тексті
  python3 -B scripts/gen_reading.py --known-sync m03  →  supabase/data_fixes/20261019_reading_known_a0v4_m03_part1.sql… (m10 — 20261020_…; лише словничок і частка
                                               знайомих слів уже завантажених текстів — після зміни слів уроків; решту файлів не чіпає)

Дані: scripts/reading_data.py (A1), reading_data_a0.py (A0), reading_data_a2.py (A2), scripts/reading_lexicon.py (форми слів і переклади),
scripts/reading_lexicon_snapshot.json (слова уроків A0–A1 з перекладами — знімок бази).
Кожне слово тексту має бути в словничку: форма → лема → переклад (переклад за дотиком, §56).
«Знайомі» слова — ті, що є в уроках A0–A1, і службові слова граматики A0; їх частка — known_ratio.
Потрібна міграція M15 (reading_texts). SQL ідемпотентний (code унікальний).
"""
import json
import re
import sys
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).parent))
import reading_data as D  # noqa: E402
import reading_data_a0 as D0  # noqa: E402
import reading_data_a2 as D2  # noqa: E402
import reading_lexicon as X  # noqa: E402
import reading_grammar as G  # noqa: E402
from full_lessons import q, qj  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / 'supabase' / 'data_fixes' / '20261014_reading_a1_v1.sql'
OUT_GRAMMAR = ROOT / 'supabase' / 'data_fixes' / '20261015_reading_a1_grammar.sql'
LEX = json.loads((Path(__file__).parent / 'reading_lexicon_snapshot.json').read_text(encoding='utf-8'))['lexemes']
SITUATIONS = set(re.findall(r"code: '([a-z_]+)'", (ROOT / 'lib' / 'situations.ts').read_text(encoding='utf-8')))
SOURCE = 'claude_reading_a1_v1'
STATUS = 'PUBLISHED'  # бета, як уроки A0/A1 (рішення власника)
REVIEW_NOTE = 'Бета: тексти для читання A1 (§6) за запитом власника 2026-10-14 (reading_a1_v1). Потрібна перевірка носієм.'
TYPES = {'message', 'chat', 'email', 'notice', 'ad', 'menu', 'instruction', 'form', 'story', 'article', 'news', 'dialogue', 'sign'}  # sign — M16
PLACEHOLDERS = {'переклад', 'translation', 'todo', 'tbd', '?'}
MIN_KNOWN = 0.75  # мікротексти A1: щонайменше 75 % слів — знайомі з уроків A0–A1 (решту пояснює словничок за дотиком)
CYR = re.compile(r'[Ѐ-ӿ]')
# Те саме правило розбиття, що й у застосунку (lib/reading.ts → tokenize): слова з літер, можна з дефісом
WORD = re.compile(r"[A-Za-zČĆĐŠŽčćđšžÀ-ž]+(?:-[A-Za-zČĆĐŠŽčćđšžÀ-ž]+)*")

errors: list[str] = []

# Рівні текстів. known — уроки яких рівнів вважаються знайомими; words — межі довжини (слів); min_known — мінімальна частка знайомих.
LEVELS = {
    'A0': dict(texts=D0.TEXTS, source='claude_reading_a0_v1', status='PUBLISHED', known={'A0'}, words=(6, 40), min_known=0.4,  # вивіски — нові слова за задумом
               out=ROOT / 'supabase' / 'data_fixes' / '20261015_reading_a0_v1.sql',
               note='Бета: вивіски й написи A0 (§6) за запитом власника 2026-10-15 (reading_a0_v1), як уроки A0. Потрібна перевірка носієм.'),
    'A1': dict(texts=D.TEXTS, source=SOURCE, status=STATUS, known={'A0', 'A1'}, words=(20, 120), min_known=MIN_KNOWN,
               out=OUT, note=REVIEW_NOTE),
    'A2': dict(texts=D2.TEXTS, source='claude_reading_a2_v1', status='DRAFT', known={'A0', 'A1'}, words=(60, 200), min_known=0.7,
               out=None,  # дві частини: 20261015_reading_a2_v1_part1.sql, _part2.sql
               note='Тексти для читання A2 (§6) за запитом власника 2026-10-15 (reading_a2_v1). DRAFT: публікує власник після перевірки.'),
}
ALL_TEXTS = [t for cfg in LEVELS.values() for t in cfg['texts']]
# Тимчасові винятки з мінімуму знайомих слів (поки уроки A0 перебудовуються за темою), код → мінімум.
# RD-A0-020 «Заборони й попередження» (*pas*) — виняток прибрано 2026-10-19: *pas* знову в уроці «Домашні тварини» (A0.5), 45 %.
KNOWN_EXCEPTIONS: dict = {}


def level_of(code: str) -> str:
    return code.split('-')[1]


def known_lemma(key: str, level: str) -> bool:
    """Чи знайома лема читачеві цього рівня: слово з уроків потрібних рівнів, службове слово або видова пара."""
    if key in X.KNOWN:
        return True
    return key in LEX and LEX[key][2] in LEVELS[level]['known']

# ---------------------------------------------------------------- граматичні підказки (§56)
POS_CODES = {
    'n.m': 'іменник, чоловічий рід', 'n.f': 'іменник, жіночий рід', 'n.n': 'іменник, середній рід',
    'n.pl.f': 'іменник, ж. р., лише множина', 'n.pl.m': 'іменник, ч. р., лише множина',
    'v.ipf': 'дієслово, недоконаний вид (що робити?)', 'v.pf': 'дієслово, доконаний вид (що зробити?)',
    'v.bi': 'дієслово, доконаний і недоконаний вид', 'adj': 'прикметник', 'adv': 'прислівник', 'num': 'числівник',
    'ord': 'порядковий числівник', 'conj': 'сполучник', 'part': 'частка', 'interj': 'вигук', 'phr': 'сталий вираз',
    'name.m': 'ім’я (чоловіче)', 'name.f': 'ім’я (жіноче)', 'surname': 'прізвище', 'place': 'назва місця',
    'prep:G': 'прийменник + родовий відмінок', 'prep:D': 'прийменник + давальний відмінок',
    'prep:A': 'прийменник + знахідний відмінок', 'prep:L': 'прийменник + місцевий відмінок',
    'prep:I': 'прийменник + орудний відмінок',
}
CASES = {'N': 'називний', 'G': 'родовий', 'D': 'давальний', 'A': 'знахідний', 'V': 'кличний', 'L': 'місцевий', 'I': 'орудний'}
CASE_Q = {'N': 'хто? що?', 'G': 'кого? чого?', 'D': 'кому? чому?', 'A': 'кого? що?', 'V': 'звертання',
          'L': 'де? про кого? про що?', 'I': 'ким? чим?'}
NUMBER = {'sg': 'однина', 'pl': 'множина'}
GENDER = {'m': 'ч. р.', 'f': 'ж. р.', 'n': 'с. р.'}
PERSON = {'1s': 'я', '2s': 'ти', '3s': 'він / вона / воно', '1p': 'ми', '2p': 'ви (і ввічливе «Ви»)', '3p': 'вони'}
CASE_RE = re.compile(r'^([NGDAVLI])\.(sg|pl)(?:\.([mfn]))?$')
VERB_RE = re.compile(r'^(pr|im)([123][sp])$')
LP_RE = re.compile(r'^lp\.([mfn])\.(sg|pl)$')
FUT_RE = re.compile(r'^fut([123][sp])$')


def render_pos(code: str) -> str:
    return POS_CODES.get(code, code)


def render_gram(code: str) -> str:
    head, _, note = code.partition(' | ')
    m = CASE_RE.match(head)
    v = VERB_RE.match(head)
    if m:
        c, num, gen = m.groups()
        text = f'{CASES[c]} відмінок ({CASE_Q[c]}), {NUMBER[num]}' + (f', {GENDER[gen]}' if gen else '')
    elif head == 'pauc':
        text = 'форма після 2, 3, 4 (як родовий однини)'
    elif LP_RE.match(head):
        g_, n_ = LP_RE.match(head).groups()
        text = f'минулий час (форма на -l): {GENDER[g_]}, {NUMBER[n_]}'
    elif FUT_RE.match(head):
        text = f'майбутній час: {PERSON[FUT_RE.match(head).group(1)]} (+ інфінітив: «ću raditi» — працюватиму)'
    elif v and v.group(1) == 'pr':
        text = f'теперішній час: {PERSON[v.group(2)]}'
    elif v and v.group(1) == 'im' and v.group(2) in ('2s', '2p'):
        text = 'наказовий спосіб: ' + ('ти (зроби!)' if v.group(2) == '2s' else 'ви (зробіть!)')
    else:
        return code  # готовий текст українською
    if not note:
        return text
    return f"{text}{' ' if text.endswith('.') else '. '}{note[0].upper()}{note[1:]}"


def gram_code(code: str, form: str, lemma: str) -> str | None:
    """Підказка форми: текст → «форма@лема» → форма (лише якщо форма відрізняється від леми:
    «sam» — це biti в «radila sam», але прикметник «сам» в «Andrij više nije sam»)."""
    own = G.TEXT_GRAM.get(code, {}).get(form)
    if own:
        return own
    by_lemma = G.GRAM.get(f'{form}@{lemma}')
    if by_lemma:
        return by_lemma
    return G.GRAM.get(form) if form != lemma.lower() else None


EMAIL_URL = re.compile(r'\S+@\S+|https?://\S+')


def words(text: str) -> list[str]:
    return WORD.findall(EMAIL_URL.sub(' ', text))


def resolve(code: str, token: str):
    """Слово тексту → (лема, переклад, знайоме?) або None."""
    low = token.lower()
    own = X.TEXT_FORMS.get(code, {})
    level = level_of(code)
    if low in own:
        lemma, ua = own[low]
        return lemma, ua, known_lemma(lemma.lower(), level)
    for name in (token, token.capitalize()):
        if name in X.NAMES:
            return name, X.NAMES[name], True
    if low in X.NAMES_LOWER:
        return X.NAMES_LEMMA.get(low, low), X.NAMES_LOWER[low], True
    lemma = X.FORMS.get(low, low)
    key = lemma.lower()
    if key in X.EXTRA:
        return lemma, X.EXTRA[key], key in X.KNOWN
    if key in LEX:
        return LEX[key][0], LEX[key][1], known_lemma(key, level)
    return None


def glossary(t) -> tuple[list[dict], float, int]:
    seen: dict[str, dict] = {}
    known = 0
    toks = words(t['hr'])
    for tok in toks:
        r = resolve(t['code'], tok)
        if r is None:
            continue
        lemma, ua, is_known = r
        known += is_known
        # lesson — слово з уроків A0–A1 (є у словнику застосунку): його можна зберегти в тренажер
        if tok.lower() in seen:
            continue
        entry = {'form': tok.lower(), 'lemma': lemma, 'ua': ua, 'lesson': lemma.lower() in LEX}
        if lemma in G.POS:
            entry['pos'] = render_pos(G.POS[lemma])
        gc = gram_code(t['code'], tok.lower(), lemma)
        if gc:
            entry['gram'] = render_gram(gc)
        seen[tok.lower()] = entry
    return list(seen.values()), (known / len(toks) if toks else 0.0), len(toks)


def validate():
    codes = [t['code'] for t in ALL_TEXTS]
    if len(codes) != len(set(codes)):
        errors.append('коди текстів повторюються')
    for level, cfg in LEVELS.items():
        validate_level(level, cfg)
    validate_common()


def validate_level(level: str, cfg: dict):
    lo, hi = cfg['words']
    for i, t in enumerate(cfg['texts'], 1):
        w = t['code']
        if w != f'RD-{level}-{i:03d}':
            errors.append(f'{w}: код має бути RD-{level}-{i:03d} (за порядком)')
        if t['type'] not in TYPES:
            errors.append(f'{w}: тип {t["type"]!r}')
        if t['situation'] is not None and t['situation'] not in SITUATIONS:
            errors.append(f'{w}: ситуація {t["situation"]!r}')
        if not (1 <= t['module'] <= 10):
            errors.append(f'{w}: модуль {t["module"]}')
        ua_title, hr_title = t['title']
        if not CYR.search(ua_title) or CYR.search(hr_title):
            errors.append(f'{w}: назва (ua, hr)')
        if CYR.search(t['hr']):
            errors.append(f'{w}: кирилиця в хорватському тексті')
        if not CYR.search(t['ua']):
            errors.append(f'{w}: переклад має бути українською')
        n = len(words(t['hr']))
        if not (lo <= n <= hi):
            errors.append(f'{w}: {n} слів (для {level}: {lo}–{hi})')
        if t['type'] == 'sign' and level != 'A0':
            errors.append(f'{w}: вивіски (sign) — лише для A0')
        if len(t['questions']) != 3:
            errors.append(f'{w}: потрібно 3 питання')
        for qu, opts, ans in t['questions']:
            # варіанти — усі українською або всі хорватською (коли треба знайти напис на вивісці)
            if (not CYR.search(qu) or len(opts) != 3 or len(set(opts)) != 3 or ans not in opts
                    or {'ua', 'hr'} <= {('ua' if CYR.search(o) else 'hr') for o in opts if re.search(r'[^\W\d_]', o)}):
                errors.append(f'{w}: питання «{qu}» — 3 різні варіанти, серед них відповідь')
        unknown = sorted({tok for tok in words(t['hr']) if resolve(w, tok) is None})
        if unknown:
            errors.append(f'{w}: немає в словничку: {", ".join(unknown)}')
        entries, ratio, _ = glossary(t)
        for e in entries:
            ua = e['ua'].strip()
            # Заглушки на кшталт «переклад» (так було в локальній копії бази) — не пропускаємо
            if (not CYR.search(ua) or ua.lower() in PLACEHOLDERS and e['lemma'].lower() != 'prijevod'
                    or 'базовий термін' in ua.lower()):
                errors.append(f'{w}: «{e["form"]}» — переклад-заглушка {ua!r}')
            if 'pos' not in e:
                errors.append(f'{w}: «{e["lemma"]}» — немає частини мови (POS у reading_grammar.py)')
            if e['form'] != e['lemma'].lower() and 'gram' not in e:
                errors.append(f'{w}: «{e["form"]}» ({e["lemma"]}) — немає граматичної підказки (GRAM у reading_grammar.py)')
            for key in ('pos', 'gram'):
                if key in e and (len(e[key]) > 160 or not CYR.search(e[key])):
                    errors.append(f'{w}: «{e["form"]}» — {key} має бути українською, до 160 символів')
            if e['lemma'] == e['form'] and e['lemma'] in X.NAMES_LOWER:
                errors.append(f'{w}: «{e["form"]}» — для назви потрібна початкова форма (NAMES_LEMMA)')
        if ratio < KNOWN_EXCEPTIONS.get(t['code'], cfg['min_known']):
            errors.append(f'{w}: знайомих слів {ratio:.0%} (потрібно ≥ {cfg["min_known"]:.0%})')


def validate_common():
    for pair, partner in X.ASPECT_PAIRS.items():
        if partner.lower() not in LEX:
            errors.append(f'видова пара {pair}: «{partner}» немає в уроках A0–A1')
    for low, lemma in X.FORMS.items():
        key = lemma.lower()
        if key not in LEX and key not in X.EXTRA:
            errors.append(f'FORMS: {low} → {lemma}, але леми немає ні в уроках, ні в EXTRA')
    used_forms = {(t['code'], tok.lower()) for t in ALL_TEXTS for tok in words(t['hr'])}
    all_forms = {f for _, f in used_forms}
    for key, code in G.GRAM.items():
        form = key.split('@')[0]
        if form not in all_forms:
            errors.append(f'GRAM: «{form}» немає в жодному тексті')
        head = code.partition(' | ')[0]
        if re.fullmatch(r'[A-Z]\.\w+(\.\w+)?|pr\w+|im\w+|lp\.\w+\.\w+|fut\w+', head) and render_gram(code) == code:
            errors.append(f'GRAM: «{form}» — невідомий код {head!r}')
    for code, forms in G.TEXT_GRAM.items():
        for form in forms:
            if (code, form) not in used_forms:
                errors.append(f'TEXT_GRAM: {code} «{form}» — немає в тексті')
    for key, ua in X.EXTRA.items():
        if not CYR.search(ua):
            errors.append(f'EXTRA: {key} — переклад українською')


def build() -> str:
    out = [f"""-- =====================================================================
-- Тексти для читання A1 (§6 ТЗ «Extensive Reading») · reading_a1_v1 · 2026-10-14
-- Згенеровано: python3 scripts/gen_reading.py (не редагуйте вручну).
-- Запуск: Supabase → SQL Editor → вставити ВЕСЬ файл → Run. Потрібна міграція M15.
--
--   * {len(D.TEXTS)} мікротекстів A1: повідомлення, чати, листи, оголошення, меню, інструкції, анкета, історії, новини.
--   * У кожного: повний переклад, словничок «слово → лема → переклад» (переклад за дотиком), 3 питання на розуміння,
--     частка знайомих слів з уроків (known_ratio).
--   * Статус {STATUS}: бета, як уроки A0/A1 (носій ще не перевіряв). Повторний запуск безпечний.
-- =====================================================================

begin;

do $$
begin
  if to_regclass('public.reading_texts') is null then
    raise exception 'Спершу запустіть міграцію M15 (20261014100000_m15_reading.sql)';
  end if;
end $$;
"""]
    for i, t in enumerate(D.TEXTS, 1):
        gl, ratio, n = glossary(t)
        qs = [{'question_ua': qu, 'options': opts, 'answer': ans} for qu, opts, ans in t['questions']]
        ua_title, hr_title = t['title']
        out.append(
            'insert into public.reading_texts (code, cefr, text_type, situation, module_order, title_ua, title_hr, body_hr, body_ua, glossary, questions, word_count, known_ratio, order_index, status, source)\n'
            f"values ({q(t['code'])}, 'A1', {q(t['type'])}, {q(t['situation'])}, {t['module']}, {q(ua_title)}, {q(hr_title)},\n"
            f"        {q(t['hr'])},\n        {q(t['ua'])},\n"
            f"        {qj(gl)},\n        {qj(qs)}, {n}, {ratio:.3f}, {i}, {q(STATUS)}, {q(SOURCE)})\n"
            'on conflict (code) do nothing;'
        )
    out.append(f"""
-- Журнал перевірки (один запис на текст)
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'reading_text', r.id, null, '{STATUS}', 'auto_passed', 'ai', '[]'::jsonb, {q(REVIEW_NOTE)}
from public.reading_texts r
where r.source = {q(SOURCE)}
  and not exists (select 1 from public.content_reviews c where c.entity_id = r.id and c.notes = {q(REVIEW_NOTE)});

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_total int; v_bad int;
begin
  select count(*) into v_total from public.reading_texts where source = {q(SOURCE)} and status = '{STATUS}';
  select count(*) into v_bad from public.reading_texts where source = {q(SOURCE)}
     and (jsonb_array_length(questions) <> 3 or jsonb_array_length(glossary) < 10 or known_ratio < {MIN_KNOWN});
  if v_total < {len(D.TEXTS)} then raise exception 'Текстів %, очікувалось {len(D.TEXTS)}', v_total; end if;
  if v_bad > 0 then raise exception '% текстів без питань чи словничка', v_bad; end if;
  raise notice 'Готово: текстів для читання A1 — %', v_total;
end $$;

commit;
""")
    return '\n'.join(out)


GRAMMAR_NOTE = 'reading_a1_grammar 2026-10-15: граматичні підказки (частина мови, форма) і точніші леми у словничку. Бета, потрібна перевірка носієм.'


def build_grammar() -> str:
    """Оновлення словничка вже завантажених текстів (reading_a1_v1 застосовано 2026-10-15).
    Стара версія словничка — у content_versions, кожна зміна — запис у content_reviews.
    Увесь файл — один блок DO (без тимчасової таблиці): SQL Editor виконує його як одну дію,
    тож або змінюється все, або нічого (перша версія з temp table падала в SQL Editor: «rd_grammar does not exist»)."""
    data = []
    for t in D.TEXTS:
        gl, ratio, _ = glossary(t)
        data.append({'code': t['code'], 'glossary': gl, 'known_ratio': round(ratio, 3)})
    n_gram = sum(1 for d in data for e in d['glossary'] if 'gram' in e)
    payload = json.dumps(data, ensure_ascii=False).replace("'", "''")
    if '$grammar$' in payload:
        raise SystemExit('у даних трапився роздільник $grammar$')
    return f"""-- =====================================================================
-- Граматичні підказки в картці слова (§56 ТЗ) · reading_a1_grammar · 2026-10-15 (v2: один блок)
-- Згенеровано: python3 scripts/gen_reading.py (не редагуйте вручну).
-- Запуск: Supabase → SQL Editor → вставити ВЕСЬ файл → Run. Потрібен 20261014_reading_a1_v1.sql.
--
--   * Словничок {len(D.TEXTS)} текстів A1: у кожного слова — частина мови (рід іменника, вид дієслова),
--     у {n_gram} змінених форм — що це за форма (відмінок і число, особа й час): «subotu — знахідний відмінок, однина».
--   * Точніші леми видових пар: dobivate → dobivati, iznesi → iznijeti, ostavljamo → ostavljati тощо;
--     «se plaća» (RD-A1-015) — дієслово plaćati, а не іменник plaća.
--   * Стара версія словничка кожного тексту — у content_versions, запис — у content_reviews.
--   * Увесь файл — одна дія: або оновлюється все, або нічого. Повторний запуск безпечний:
--     змінює лише тексти, словничок яких відрізняється (якщо вже оновлено — «змінено текстів: 0»).
-- =====================================================================

do $grammar$
declare
  v_data jsonb := '{payload}'::jsonb;
  v_changed int;
  v_texts int;
  v_no_pos int;
  v_no_gram int;
  v_gram int;
begin
  if (select count(*) from public.reading_texts where source = {q(SOURCE)}) < {len(D.TEXTS)} then
    raise exception 'Спершу запустіть 20261014_reading_a1_v1.sql (тексти для читання A1)';
  end if;

  -- 1. Знімок старої версії (лише для текстів, які змінюються)
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'reading_text', r.id, r.version,
         jsonb_build_object('code', r.code, 'glossary', r.glossary, 'known_ratio', r.known_ratio),
         {q(GRAMMAR_NOTE)}
  from public.reading_texts r
  join jsonb_to_recordset(v_data) as g(code text, glossary jsonb, known_ratio numeric) on g.code = r.code
  where r.source = {q(SOURCE)} and r.glossary is distinct from g.glossary
  on conflict (entity_type, entity_id, version) do nothing;

  -- 2. Новий словничок; версія тексту +1; 3. запис у журнал перевірки
  with changed as (
    update public.reading_texts r
       set glossary = g.glossary, known_ratio = g.known_ratio, version = r.version + 1
      from jsonb_to_recordset(v_data) as g(code text, glossary jsonb, known_ratio numeric)
     where g.code = r.code and r.source = {q(SOURCE)} and r.glossary is distinct from g.glossary
    returning r.id, r.status
  ), logged as (
    insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
    select 'reading_text', c.id, c.status, c.status, 'auto_passed', 'ai', '[]'::jsonb, {q(GRAMMAR_NOTE)}
    from changed c
    returning 1
  )
  select count(*) into v_changed from logged;

  -- Самоперевірка: у кожного слова є частина мови, у змінених форм — підказка; інакше все відкочується
  select count(*) into v_texts
    from public.reading_texts r
    join jsonb_to_recordset(v_data) as g(code text, glossary jsonb, known_ratio numeric) on g.code = r.code
   where r.glossary = g.glossary;
  select count(*) filter (where e->>'pos' is null),
         count(*) filter (where e->>'gram' is null and e->>'form' <> lower(e->>'lemma')),
         count(*) filter (where e->>'gram' is not null)
    into v_no_pos, v_no_gram, v_gram
    from public.reading_texts r, jsonb_array_elements(r.glossary) e where r.source = {q(SOURCE)};
  if v_texts < {len(D.TEXTS)} then raise exception 'Оновлено текстів %, очікувалось {len(D.TEXTS)}', v_texts; end if;
  if v_no_pos > 0 or v_no_gram > 0 then raise exception 'Без частини мови: %, без підказки форми: %', v_no_pos, v_no_gram; end if;
  raise notice 'Готово: граматичні підказки в % текстах (форм із підказкою — %), змінено текстів зараз: %', v_texts, v_gram, v_changed;
end
$grammar$;
"""


LEVEL_INTRO = {
    'A0': 'вивіски, цінники, розклади й короткі записки A0 (кожен рядок вивіски — окрема табличка)',
    'A2': 'тексти A2: історії в минулому часі, листи, чати, інструкції, новини, думки',
}


def build_level(level: str, part: int = 0, parts: int = 1) -> str:
    """Тексти рівня (або частина): вставка (не перезаписує наявні коди), журнал перевірки, самоперевірка."""
    cfg = LEVELS[level]
    all_texts, source, status, note = cfg['texts'], cfg['source'], cfg['status'], cfg['note']
    size = -(-len(all_texts) // parts)
    texts = all_texts[part * size:(part + 1) * size]
    first = part * size
    codes = ', '.join(q(t['code']) for t in texts)
    part_label = f' · частина {part + 1} з {parts}' if parts > 1 else ''
    out = [f"""-- =====================================================================
-- Тексти для читання {level} (§6 ТЗ «Extensive Reading») · reading_{level.lower()}_v1{part_label} · 2026-10-15
-- Згенеровано: python3 scripts/gen_reading.py (не редагуйте вручну).
-- Запуск: Supabase → SQL Editor → вставити ВЕСЬ файл → Run. Потрібні M15 і M16 (тип «sign»).
--
--   * {len(texts)} текстів ({texts[0]['code']} … {texts[-1]['code']}): {LEVEL_INTRO[level]}.{chr(10) + '--   * Частини незалежні, запускати можна в будь-якому порядку.' if parts > 1 else ''}
--   * У кожного: повний переклад, словничок «слово → лема → переклад» із граматичною підказкою (§56),
--     3 питання на розуміння, частка знайомих слів з уроків (known_ratio).
--   * Статус {status}{': бета, як уроки A0 (носій ще не перевіряв)' if status == 'PUBLISHED' else ': бачить лише адмін; опублікувати — 20261015_reading_a2_publish.sql'}.
--   * Повторний запуск безпечний (наявні коди не перезаписуються).
-- =====================================================================

begin;

do $$
begin
  if to_regclass('public.reading_texts') is null then
    raise exception 'Спершу запустіть міграцію M15 (20261014100000_m15_reading.sql)';
  end if;
  if not exists (select 1 from pg_constraint where conname = 'reading_texts_text_type_check'
                 and pg_get_constraintdef(oid) like '%sign%') then
    raise exception 'Спершу запустіть міграцію M16 (20261015120000_m16_reading_signs.sql)';
  end if;
end $$;
"""]
    for i, t in enumerate(texts, first + 1):
        gl, ratio, n = glossary(t)
        qs = [{'question_ua': qu, 'options': opts, 'answer': ans} for qu, opts, ans in t['questions']]
        ua_title, hr_title = t['title']
        out.append(
            'insert into public.reading_texts (code, cefr, text_type, situation, module_order, title_ua, title_hr, body_hr, body_ua, glossary, questions, word_count, known_ratio, order_index, status, source)\n'
            f"values ({q(t['code'])}, {q(level)}, {q(t['type'])}, {q(t['situation'])}, {t['module']}, {q(ua_title)}, {q(hr_title)},\n"
            f"        {q(t['hr'])},\n        {q(t['ua'])},\n"
            f"        {qj(gl)},\n        {qj(qs)}, {n}, {ratio:.3f}, {i}, {q(status)}, {q(source)})\n"
            'on conflict (code) do nothing;'
        )
    out.append(f"""
-- Журнал перевірки (один запис на текст)
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'reading_text', r.id, null, r.status, 'auto_passed', 'ai', '[]'::jsonb, {q(note)}
from public.reading_texts r
where r.source = {q(source)} and r.code in ({codes})
  and not exists (select 1 from public.content_reviews c where c.entity_id = r.id and c.notes = {q(note)});

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_total int; v_bad int;
begin
  select count(*) into v_total from public.reading_texts where source = {q(source)} and code in ({codes});
  select count(*) into v_bad from public.reading_texts r where r.source = {q(source)} and r.code in ({codes})
     and (jsonb_array_length(r.questions) <> 3 or r.known_ratio < {cfg['min_known']}
          or exists (select 1 from jsonb_array_elements(r.glossary) e
                     where e->>'pos' is null or (e->>'gram' is null and e->>'form' <> lower(e->>'lemma'))));
  if v_total < {len(texts)} then raise exception 'Текстів %, очікувалось {len(texts)}', v_total; end if;
  if v_bad > 0 then raise exception '% текстів без питань, словничка чи граматичних підказок', v_bad; end if;
  raise notice 'Готово: текстів для читання {level}{part_label} — %', v_total;
end $$;

commit;
""")
    return '\n'.join(out)


A0_QUESTIONS_NOTE = 'reading_a0_questions 2026-10-15: RD-A0-001 — варіанти відповідей хорватською (знайти напис на вивісці), запит власника. Бета.'


def build_sync(level: str, tag: str, note: str, what: str) -> str:
    """Оновлення вже завантажених текстів рівня до поточних даних (питання, словничок, частка знайомих слів).
    Один блок DO (SQL Editor не тримає тимчасові таблиці): стара версія — у content_versions, запис — у content_reviews;
    змінює лише тексти, що відрізняються; повторний запуск нічого не змінює."""
    cfg = LEVELS[level]
    data = []
    for t in cfg['texts']:
        gl, ratio, _ = glossary(t)
        qs = [{'question_ua': qu, 'options': opts, 'answer': ans} for qu, opts, ans in t['questions']]
        data.append({'code': t['code'], 'glossary': gl, 'questions': qs, 'known_ratio': round(ratio, 3)})
    payload = json.dumps(data, ensure_ascii=False).replace("'", "''")
    if '$sync$' in payload:
        raise SystemExit('у даних трапився роздільник $sync$')
    src = q(cfg['source'])
    return f"""-- =====================================================================
-- Тексти для читання {level}: {what} · {tag} · 2026-10-15
-- Згенеровано: python3 scripts/gen_reading.py (не редагуйте вручну).
-- Запуск: Supabase → SQL Editor → вставити ВЕСЬ файл → Run. Потрібен 20261015_reading_{level.lower()}_v1.sql.
--   * Змінює лише тексти, у яких питання чи словничок відрізняються від поточних даних; стара версія — у content_versions.
--   * Увесь файл — одна дія (або все, або нічого). Повторний запуск безпечний («змінено текстів: 0»).
-- =====================================================================

do $sync$
declare
  v_data jsonb := '{payload}'::jsonb;
  v_changed int;
  v_same int;
begin
  if (select count(*) from public.reading_texts where source = {src}) < {len(cfg['texts'])} then
    raise exception 'Спершу запустіть 20261015_reading_{level.lower()}_v1.sql';
  end if;

  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'reading_text', r.id, r.version,
         jsonb_build_object('code', r.code, 'questions', r.questions, 'glossary', r.glossary, 'known_ratio', r.known_ratio),
         {q(note)}
  from public.reading_texts r
  join jsonb_to_recordset(v_data) as g(code text, glossary jsonb, questions jsonb, known_ratio numeric) on g.code = r.code
  where r.source = {src} and (r.glossary is distinct from g.glossary or r.questions is distinct from g.questions)
  on conflict (entity_type, entity_id, version) do nothing;

  with changed as (
    update public.reading_texts r
       set glossary = g.glossary, questions = g.questions, known_ratio = g.known_ratio, version = r.version + 1
      from jsonb_to_recordset(v_data) as g(code text, glossary jsonb, questions jsonb, known_ratio numeric)
     where g.code = r.code and r.source = {src}
       and (r.glossary is distinct from g.glossary or r.questions is distinct from g.questions)
    returning r.id, r.status
  ), logged as (
    insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
    select 'reading_text', c.id, c.status, c.status, 'auto_passed', 'ai', '[]'::jsonb, {q(note)}
    from changed c
    returning 1
  )
  select count(*) into v_changed from logged;

  select count(*) into v_same
    from public.reading_texts r
    join jsonb_to_recordset(v_data) as g(code text, glossary jsonb, questions jsonb, known_ratio numeric) on g.code = r.code
   where r.glossary = g.glossary and r.questions = g.questions;
  if v_same < {len(cfg['texts'])} then raise exception 'Оновлено текстів %, очікувалось {len(cfg['texts'])}', v_same; end if;
  raise notice 'Готово: тексти {level} відповідають поточним даним (змінено текстів зараз: %)', v_changed;
end
$sync$;
"""


KNOWN_SYNC_OUT = ROOT / 'supabase' / 'data_fixes' / '{}_reading_known_a0v4{}_part{}.sql'  # дата, тег модуля: '' (A0.2), '_m03'…
KNOWN_SYNC_DATE = {'m10': '20261020'}  # інші модулі — 20261019
KNOWN_SYNC_NOTE = ('reading_known_a0v4 2026-10-19: словничок і частка знайомих слів перераховано після перебудови уроків A0 '
                   'за темою (curriculum_a0_v4). Тексти й питання не змінено.')
KNOWN_SYNC_MAX = 240_000  # байтів даних на частину: SQL Editor не приймає файли понад ~300 КБ


def known_sync_data() -> list[dict]:
    """Усі тексти A0–A2 зі словничком і часткою знайомих слів за поточним знімком. SQL змінює в базі лише ті, що відрізняються.
    (До A0.6 тут були лише тексти, що відрізнялися від знімка 2026-10-15, — але тоді текст, який попередній пакет змінив,
    а наступний модуль повернув до початкового стану (RD-A0-020, *pas*), лишався б у базі зі старою часткою.)"""
    return [{'code': t['code'], 'glossary': g, 'known_ratio': round(r, 3)}
            for cfg in LEVELS.values() for t in cfg['texts'] for g, r, _ in [glossary(t)]]


def build_known_sync() -> list[str]:
    """Після зміни слів уроків: оновити в уже завантажених текстах (A0, A1, A2) лише словничок (позначка «з уроків»)
    і частку знайомих слів. Тексти й питання не змінюються. Стара версія — у content_versions; запис — у content_reviews.
    Змінює лише ті тексти, що відрізняються; повторний запуск нічого не змінює. Кілька частин — через ліміт SQL Editor."""
    parts: list[list[dict]] = [[]]
    size = 0
    for d in known_sync_data():
        n = len(json.dumps(d, ensure_ascii=False).encode())
        if parts[-1] and size + n > KNOWN_SYNC_MAX:
            parts.append([])
            size = 0
        parts[-1].append(d)
        size += n
    out = []
    for pi, data in enumerate(parts, 1):
        payload = json.dumps(data, ensure_ascii=False).replace("'", "''")
        if '$known$' in payload:
            raise SystemExit('у даних трапився роздільник $known$')
        codes = f"{data[0]['code']} … {data[-1]['code']}"
        out.append(f"""-- =====================================================================
-- Тексти для читання A0–A2: словничок і частка знайомих слів після уроків A0 за темою · частина {pi} з {len(parts)} · 2026-10-19
-- Згенеровано: python3 -B scripts/gen_reading.py --known-sync (не редагуйте вручну).
-- Навіщо: уроки A0 перебудовано за темою (curriculum_a0_v4) — частина слів текстів тепер є в уроках («знайомі»),
--   деяких слів в уроках більше немає. Дані — за поточним знімком scripts/reading_lexicon_snapshot.json.
--   * У цій частині — {len(data)} текстів ({codes}). Змінює лише glossary і known_ratio; тексти й питання — ні.
--   * Стара версія — у content_versions, запис — у content_reviews. Статус текстів не змінюється (A2 лишається DRAFT).
--   * Одна дія (або все, або нічого). Повторний запуск безпечний («змінено текстів: 0»).
-- Запуск: Supabase → SQL Editor → вставити ВЕСЬ файл → Run. Частини — у будь-якому порядку.
-- =====================================================================

do $known$
declare
  v_data jsonb := '{payload}'::jsonb;
  v_changed int;
  v_same int;
begin
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'reading_text', r.id, r.version,
         jsonb_build_object('code', r.code, 'glossary', r.glossary, 'known_ratio', r.known_ratio),
         {q(KNOWN_SYNC_NOTE)}
  from public.reading_texts r
  join jsonb_to_recordset(v_data) as g(code text, glossary jsonb, known_ratio numeric) on g.code = r.code
  where r.glossary is distinct from g.glossary or r.known_ratio is distinct from g.known_ratio
  on conflict (entity_type, entity_id, version) do nothing;

  with changed as (
    update public.reading_texts r
       set glossary = g.glossary, known_ratio = g.known_ratio, version = r.version + 1
      from jsonb_to_recordset(v_data) as g(code text, glossary jsonb, known_ratio numeric)
     where g.code = r.code and (r.glossary is distinct from g.glossary or r.known_ratio is distinct from g.known_ratio)
    returning r.id, r.status
  ), logged as (
    insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
    select 'reading_text', c.id, c.status, c.status, 'auto_passed', 'script', '[]'::jsonb, {q(KNOWN_SYNC_NOTE)}
    from changed c
    returning 1
  )
  select count(*) into v_changed from logged;

  select count(*) into v_same
    from public.reading_texts r
    join jsonb_to_recordset(v_data) as g(code text, glossary jsonb, known_ratio numeric) on g.code = r.code
   where r.glossary = g.glossary and r.known_ratio = g.known_ratio;
  if v_same < {len(data)} then raise exception 'Узгоджено текстів %, очікувалось {len(data)} (чи завантажено тексти A0, A1, A2?)', v_same; end if;
  raise notice 'Готово: частина {pi} з {len(parts)} — {len(data)} текстів відповідають урокам (змінено зараз: %)', v_changed;
end
$known$;
""")
    return out


A2_PUBLISH_NOTE = 'Рішення власника: тексти для читання A2 (reading_a2_v1) — публікувати як бету. Потрібна перевірка носієм.'


def build_a2_publish() -> str:
    cfg = LEVELS['A2']
    return f"""-- =====================================================================
-- Опублікувати тексти для читання A2 (reading_a2_v1) · 2026-10-15
-- Запускає ВЛАСНИК, коли вирішить: одразу як бету (як A0/A1) або після перевірки носієм.
-- Що змінює: статус {len(cfg['texts'])} текстів A2 DRAFT → PUBLISHED (їх побачать усі користувачі в «Практиці» → «Читання» → A2).
-- Запис рішення — у content_reviews. Повторний запуск безпечний.
-- =====================================================================

do $publish$
declare v_count int;
begin
  with changed as (
    update public.reading_texts set status = 'PUBLISHED'
     where source = {q(cfg['source'])} and status in ('DRAFT', 'AI_GENERATED', 'AUTO_VALIDATED', 'NEEDS_REVIEW', 'APPROVED')
    returning id
  ), logged as (
    insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
    select 'reading_text', c.id, 'DRAFT', 'PUBLISHED', 'approved', 'human', '[]'::jsonb, {q(A2_PUBLISH_NOTE)}
    from changed c
    returning 1
  )
  select count(*) into v_count from logged;
  raise notice 'Опубліковано текстів A2: % (усього опублікованих A2: %)', v_count,
    (select count(*) from public.reading_texts where source = {q(cfg['source'])} and status = 'PUBLISHED');
end
$publish$;
"""


def stats() -> str:
    rows = []
    for t in ALL_TEXTS:
        gl, ratio, n = glossary(t)
        rows.append(f"{t['code']} {t['type']:<11} {n:>3} слів, знайомих {ratio:.0%}, словничок {len(gl)} — {t['title'][0]}")
    return '\n'.join(rows)


if __name__ == '__main__':
    if '--unknown' in sys.argv:
        unk: dict[str, set] = {}
        for t in ALL_TEXTS:
            for tok in words(t['hr']):
                if resolve(t['code'], tok) is None:
                    unk.setdefault(tok.lower(), set()).add(t['code'][3:])
        for k in sorted(unk):
            print(f'{k}\t{",".join(sorted(unk[k]))}')
        print(f'— {len(unk)} форм', file=sys.stderr)
        sys.exit(0)
    validate()
    if errors:
        print('ПОМИЛКИ В ДАНИХ:', *errors, sep='\n  ')
        sys.exit(1)
    if '--stats' in sys.argv:
        print(stats())
        sys.exit(0)
    if '--known-sync' in sys.argv:
        # лише цей файл: решта виходів уже застосована в робочій базі
        # --known-sync [m03]: тег — останній перебудований модуль (без тегу — файли A0.2, уже в базі)
        i = sys.argv.index('--known-sync')
        tag = sys.argv[i + 1] if len(sys.argv) > i + 1 and not sys.argv[i + 1].startswith('--') else ''
        for pi, sql in enumerate(build_known_sync(), 1):
            out = Path(str(KNOWN_SYNC_OUT).format(KNOWN_SYNC_DATE.get(tag, '20261019'), '_' + tag if tag else '', pi))
            out.write_text(sql, encoding='utf-8')
            print(f'OK → {out.relative_to(ROOT)}: {len(sql.encode()) // 1024} КБ')
        sys.exit(0)
    if '--v1' in sys.argv:
        # Перший пакет текстів уже застосовано (2026-10-15) — файл не перезаписуємо без потреби;
        # з граматичними підказками він більший за ліміт SQL Editor (~300 КБ), тож на чистій базі: v1 → grammar.
        sql = build()
        OUT.write_text(sql, encoding='utf-8')
        print(f'OK → {OUT.relative_to(ROOT)}: {len(D.TEXTS)} текстів, {len(sql.encode()) // 1024} КБ')
    outputs = [(OUT_GRAMMAR, build_grammar(), len(D.TEXTS))]
    outputs.append((LEVELS['A0']['out'], build_level('A0'), len(D0.TEXTS)))
    for part in range(2):  # A2 одним файлом — понад 300 КБ
        out_path = ROOT / 'supabase' / 'data_fixes' / f'20261015_reading_a2_v1_part{part + 1}.sql'
        outputs.append((out_path, build_level('A2', part, 2), len(D2.TEXTS) // 2))
    outputs.append((ROOT / 'supabase' / 'data_fixes' / '20261015_reading_a2_publish.sql', build_a2_publish(), len(D2.TEXTS)))
    outputs.append((ROOT / 'supabase' / 'data_fixes' / '20261015_reading_a0_questions.sql',
                    build_sync('A0', 'reading_a0_questions', A0_QUESTIONS_NOTE, 'варіанти відповідей хорватською (RD-A0-001)'), len(D0.TEXTS)))
    for path, sql, n in outputs:
        size = len(sql.encode())
        if size > 300 * 1024:
            raise SystemExit(f'{path.name}: {size // 1024} КБ — більше за ліміт SQL Editor (~300 КБ), розбийте на частини')
        path.write_text(sql, encoding='utf-8')
        print(f'OK → {path.relative_to(ROOT)}: {n} текстів, {size // 1024} КБ')
