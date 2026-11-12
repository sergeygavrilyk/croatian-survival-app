#!/usr/bin/env python3
"""
Генератор SQL програми A2 v2 (погоджено власником 2026-11-12): content/reviews/2026-11-12_curriculum_a2_v2_program.md.

  python3 -B scripts/gen_curriculum_a2_v2.py structure   →  supabase/data_fixes/20261112_curriculum_a2_v2_00_structure.sql
                                                            (14 модулів: 10 DRAFT-модулів — нові місця й назви, 4 нові; юніти;
                                                             тексти для читання — за своїм модулем; 22 теми граматики з правилами)
  python3 -B scripts/gen_curriculum_a2_v2.py 1           →  SQL модуля A2.1 (і далі — номер модуля): слова, уроки, вправи,
                                                            «Прослухайте діалог чи оголошення», письмо й переказ; модуль — PUBLISHED
  python3 -B scripts/gen_curriculum_a2_v2.py --review 1  →  звіт для носія (content/reviews/2026-11-12_curriculum_a2_v2_mNN.md)

Дані: scripts/curriculum_a2_v2_data.py (програма, граматика) і scripts/curriculum_a2_v2_mNN.py (уроки модуля).
Знімок: scripts/curriculum_a2_v2_snapshot.json (слова уроків A0 / A1; збіги нових слів із робочою базою).

Правила (власник 2026-11-12): 20–25 нових слів на урок; 90–95 % слів — нові для рівня (зі слів уроків A0 / A1 — не більше 2);
слово не повторюється в уроках A2; 2 діалоги; 15 вправ (1 «вставте», 8 на слова, 2 «складіть», 1 «прослухайте і складіть»,
1 «прослухайте діалог чи оголошення», 2 «скажіть») + «Напишіть повідомлення» і «Перекажіть другу» (ua → hr, необов’язкові);
частіше Даша / Дар’я; бета (PUBLISHED).
"""
from __future__ import annotations

import importlib
import json
import re
import sys
import uuid
from pathlib import Path
from types import SimpleNamespace

sys.dont_write_bytecode = True
HERE = Path(__file__).parent
sys.path.insert(0, str(HERE))
import curriculum_a2_v2_data as D  # noqa: E402
import gen_writing as GW  # noqa: E402
from full_lessons import CYR, HELPERS_SQL, STOP_UA, Course, Place, fold_ua, q, qj, shuffled, typable, uid  # noqa: E402
from lexeme_checks import check_batch, normalize  # noqa: E402

ROOT = HERE.resolve().parent
FIXES = ROOT / 'supabase' / 'data_fixes'
REVIEWS = ROOT / 'content' / 'reviews'
SNAPSHOT = json.loads((HERE / 'curriculum_a2_v2_snapshot.json').read_text(encoding='utf-8'))
LEVEL = 'A2'
DATE = '20261112'
MINUTES = 20
STATUS = 'PUBLISHED'  # бета (рішення власника 2026-11-12)
SOURCE = 'claude_curriculum_a2_v2'
WORDS_RANGE = (20, 25)
OLD_MAX = 2   # слів з уроків A0 / A1 в уроці A2 — не більше
SITUATIONS = set(re.findall(r"code: '([a-z_]+)'", (ROOT / 'lib' / 'situations.ts').read_text(encoding='utf-8')))
STRUCTURE_OUT = FIXES / f'{DATE}_curriculum_a2_v2_00_structure.sql'
POS = {'n': 'noun', 'v': 'verb', 'adj': 'adjective', 'adv': 'adverb', 'ph': 'phrase', 'prep': 'preposition', 'conj': 'conjunction',
       'pron': 'pronoun', 'part': 'particle', 'int': 'interjection', 'num': 'number'}
MEDIATION_SITUATION = 'Ваш друг не говорить хорватською. Передайте його слова хорватською.'
WRITING_NS = uuid.uuid5(uuid.NAMESPACE_URL, 'croatia-survival/writing-pilot-20261105')   # той самий простір, що в gen_writing.py
LISTEN_Q = {'dialogue': 'Прослухайте розмову', 'announcement': 'Прослухайте оголошення', 'voicemail': 'Прослухайте голосове повідомлення',
            'forecast': 'Прослухайте прогноз', 'news': 'Прослухайте новину'}
SHORT_FROM = 8   # коротка відповідь у «прослухайте діалог» — з A2.8 (рішення 2026-11-12)


# ----------------------------------------------------------------------------- програма
def load_module(m: int):
    try:
        return importlib.import_module(f'curriculum_a2_v2_m{m:02d}')
    except ModuleNotFoundError:
        return None


MODULES = {m: mod for m in D.PROGRAM if (mod := load_module(m))}
PLACE: dict = {}
_n = 0
for _m in sorted(D.PROGRAM):
    for _o in range(1, D.PROGRAM[_m]['lessons'] + 1):
        _n += 1
        PLACE[(_m, _o)] = _n
TOTAL = _n


def module_id(m: int) -> str:
    old = D.PROGRAM[m]['old']
    return D.OLD_MODULES[old] if old else uid('module_a2v2', LEVEL, m)


def unit_id(m: int) -> str:
    return uid('unit_a2v2', LEVEL, m, 1)


def lesson_id(m: int, o: int) -> str:
    return uid('lesson_a2v2', LEVEL, m, o)


def topic_id(code: str) -> str:
    return D.GRAMMAR[code]['db'] or uid('grammar_a2v2', LEVEL, code)


def module_title(m: int) -> tuple[str, str]:
    ua, hr = D.PROGRAM[m]['title']
    return f'Модуль A2.{m} — {ua}', f'Modul A2.{m} — {hr}'


def forms_of(code: str) -> dict:
    """'m' → рід; 'ipfv' / 'pfv:upisivati' → вид (+ пара); '' → {}."""
    if not code:
        return {}
    if code.split(':')[0] in ('ipfv', 'pfv', 'biasp'):
        a, _, pair = code.partition(':')
        return {'aspect': a, **({'pair': pair} if pair else {})}
    return {'gender': code}


def vtype_of(pos: str) -> str:
    return {'phrase': 'chunk', 'preposition': 'function_word', 'conjunction': 'function_word', 'particle': 'function_word',
            'pronoun': 'function_word', 'interjection': 'formulaic'}.get(pos, 'core')


def lessons_of(m: int) -> dict:
    """(модуль, місце) → урок (формат full_lessons + vocab, listening, write, mediation)."""
    out = {}
    for o, L in enumerate(MODULES[m].LESSONS, 1):
        L = dict(L)
        L['words'] = [v[0] for v in L['vocab']] + list(L.get('known', []))
        out[(m, o)] = L
    return out


def new_lexemes(m: int) -> list[dict]:
    rows = []
    for L in MODULES[m].LESSONS:
        for lemma, ua, pos, forms, example in L['vocab']:
            p = POS[pos]
            rows.append(dict(lemma=lemma, normalized=normalize(lemma), ukrainian_translation=ua, part_of_speech=p, cefr=LEVEL,
                             vocabulary_type=vtype_of(p), forms=forms_of(forms), examples=[example] if example else []))
    return rows


def lex_base(upto: int) -> dict:
    lex = {k: (v[0], v[1]) for k, v in SNAPSHOT['lex'].items()}
    for m in sorted(MODULES):
        if m > upto:
            break
        for r in new_lexemes(m):
            lex[r['lemma'].lower()] = (r['lemma'], r['ukrainian_translation'])
    for lemma, _old, new in D.FIX_TRANSLATIONS:
        if lemma.lower() in lex:
            lex[lemma.lower()] = (lex[lemma.lower()][0], new)
    return lex


# ----------------------------------------------------------------------------- курс
class CourseA2(Course):
    """Як курс A1 v3 (вправи на слова — спершу однозначні для «як хорватською» / «напишіть»), але одна «прослухайте і складіть»
    замінена на «прослухайте діалог чи оголошення» (рішення власника 2026-11-12)."""

    STOP_A2 = STOP_UA | {'про', 'за', 'по', 'із', 'зі', 'без', 'при', 'після', 'перед', 'або', 'і', 'й', 'та', 'а', 'не', 'щоб', 'через',
                         'під', 'над', 'між', 'кого', 'кому', 'чого', 'когось', 'комусь', 'щось', 'себе', 'собі', 'свій', 'своє'}

    def ua_tokens(self, word: str) -> set[str]:
        """Як у Course, але без приміток у дужках і службових слів: «покривати (про страховку)» не близьке до «довідка про відвідування»."""
        t = re.sub(r'\([^)]*\)', ' ', self.display_ua(word))
        return {x for x in fold_ua(t).replace(';', ' ').replace(',', ' ').split() if x not in self.STOP_A2}

    def vocab_exercises(self, key) -> list[dict]:
        import random
        rng = random.Random(f'{self.seed_prefix}:{key}')
        order = list(self.lessons[key]['words'])
        rng.shuffle(order)
        taken: set[str] = set()

        def pick(cond):
            for w in order:
                if w.lower() not in taken and w.lower() not in self.no_vocab and cond(w):
                    taken.add(w.lower())
                    return w
            return None

        n_meaning, n_choose, n_type = self.vocab_counts
        plan = ([('choose_hr', lambda w: not self.ambiguous(w))] * n_choose
                + [('type', lambda w: not self.ambiguous(w) and typable(w))] * n_type
                + [('meaning', lambda w: True)] * n_meaning)
        picked = []
        for kind, cond in plan:
            w = pick(cond)
            if w is None and kind != 'meaning':
                kind, w = 'meaning', pick(lambda w: True)
            if w is None:
                self.errors.append(f'{self.name(key)}: не вистачає слів для вправи {kind}')
                continue
            picked.append((kind, w))
        rank = {'meaning': 0, 'choose_hr': 1, 'type': 2}
        out: list[dict] = []
        for kind, w in sorted(picked, key=lambda x: rank[x[0]]):
            lemma = self.lemma_of(w)
            if kind == 'meaning':
                ds = self.distractors(key, w, lambda x: fold_ua(self.display_ua(x)), rng)
                answer = self.display_ua(w)
                out.append(dict(type='multiple_choice', word=w, question=f'Що означає «{lemma}»?', answer=answer,
                                options=shuffled([answer, *[self.display_ua(d) for d in ds]], f'{key}:{w}'),
                                skill='vocabulary', n_opts=len(ds) + 1))
            elif kind == 'choose_hr':
                ds = self.distractors(key, w, lambda x: self.lemma_of(x).lower(), rng)
                out.append(dict(type='multiple_choice', word=w, question=f'Як хорватською «{self.display_ua(w)}»?', answer=lemma,
                                options=shuffled([lemma, *[self.lemma_of(d) for d in ds]], f'{key}:{w}'),
                                skill='vocabulary', n_opts=len(ds) + 1))
            else:
                out.append(dict(type='type_answer', word=w, question=f'Напишіть хорватською: «{self.display_ua(w)}»',
                                answer=lemma, options=None, skill='writing'))
        for ex in out:
            if ex.get('n_opts', 4) != 4:
                self.errors.append(f'{self.name(key)}: для «{ex["word"]}» лише {ex["n_opts"]} варіанти')
        return out

    def lesson_exercises(self, key) -> list[dict]:
        if not hasattr(self, '_ex_cache'):
            self._ex_cache = {}
        if key in self._ex_cache:
            return self._ex_cache[key]
        L = self.lessons[key]
        question, answer, wrong = L['fill']
        out = [dict(type='fill_in_the_blank', question=question, answer=answer, options=shuffled([answer, *wrong], f'f{key}'), skill='grammar')]
        out += self.vocab_exercises(key)
        for hint, sentence in L['build']:
            out.append(dict(type='sentence_builder', question=hint, answer=sentence,
                            options=shuffled(sentence.split(' '), f'b{key}:{sentence}'), skill='writing'))
        sentence = L['listen']
        out.append(dict(type='listening', question='Прослухайте і складіть фразу', answer=sentence,
                        options=shuffled(sentence.split(' '), f'l{key}:{sentence}'), skill='listening'))
        t = listening_task(L)
        out.append(dict(type='listening_dialogue', question=LISTEN_Q[t['kind']], answer=listening_answer(t)[:500], options=None,
                        skill='listening', task=t))
        for ua, hr in L['speak']:
            out.append(dict(type='speaking', question=ua, answer=hr, options=None, skill='speaking'))
        self._ex_cache[key] = out
        return out

    def validate_lesson(self, key):
        L = self.lessons[key]
        w = self.name(key)
        t_ua, t_hr = L['title']
        self.check_ua(t_ua, w)
        self.check_hr(t_hr, w)
        for o in L['objectives']:
            self.check_ua(o, w + '.objective')
        if len(L['objectives']) < 2:
            self.errors.append(f'{w}: менше двох цілей')
        if L['situation'] not in self.situations:
            self.errors.append(f'{w}: невідома ситуація {L["situation"]!r}')
        if L['grammar'] not in D.GRAMMAR:
            self.errors.append(f'{w}: невідома граматика {L["grammar"]!r}')
        words = L['words']
        lo, hi = self.words_range
        if not (lo <= len(words) <= hi):
            self.errors.append(f'{w}: слів {len(words)} (має бути {lo}–{hi})')
        if len({x.lower() for x in words}) != len(words):
            self.errors.append(f'{w}: слова повторюються')
        for word in words:
            if word.lower() not in self.lex:
                self.errors.append(f'{w}: слова «{word}» немає ні в знімку бази, ні серед нових')
        if len(L['scenes']) != 2:
            self.errors.append(f'{w}: потрібні 2 діалоги')
        texts = []
        for si, (s_ua, s_hr, turns) in enumerate(L['scenes'], 1):
            sw = f'{w}.scene{si}'
            self.check_ua(s_ua, sw)
            self.check_hr(s_hr, sw)
            if not (4 <= len(turns) <= 6):
                self.errors.append(f'{sw}: {len(turns)} реплік (має бути 4–6)')
            for speaker, hr, ua in turns:
                self.check_hr(speaker, sw + '.speaker')
                self.check_hr(hr, sw + '.turn')
                self.check_ua(ua, sw + '.turn')
                if '  ' in hr or hr != hr.strip():
                    self.errors.append(f'{sw}: зайві пробіли в репліці {hr!r}')
            texts.append(' '.join(hr for _, hr, _ in turns))
        question, answer, wrong = L['fill']
        if '___' not in question:
            self.errors.append(f'{w}.fill: немає пропуску ___')
        self.check_hr(question, w + '.fill')
        if len({answer, *wrong}) != 4 or len(wrong) != 3:
            self.errors.append(f'{w}.fill: потрібно 4 різні варіанти')
        if len(L['build']) != 2 or len(L['speak']) != 2 or not isinstance(L['listen'], str):
            self.errors.append(f'{w}: потрібно 2 «складіть», 1 «прослухайте і складіть», 2 «скажіть»')
        for hint, sentence in L['build']:
            self.check_ua(hint, w + '.build')
            self.check_hr(sentence, w + '.build')
            self.tokens(sentence, w + '.build')
        self.check_hr(L['listen'], w + '.listen')
        self.tokens(L['listen'], w + '.listen')
        if not any(L['listen'] in t for t in texts):
            self.errors.append(f'{w}: «прослухайте і складіть» не з діалогу: {L["listen"]!r}')
        for ua, hr in L['speak']:
            self.check_ua(ua, w + '.speak')
            self.check_hr(hr, w + '.speak')
        self.errors += [f'{w}.listening: {e}' for e in check_listening(listening_task(L), key[0])]


def listening_task(L: dict) -> dict:
    s = L['listening']
    script = [({'speaker': x[0], 'hr': x[1], 'ua': x[2]} if len(x) == 3 else {'hr': x[0], 'ua': x[1]}) for x in s['script']]
    questions = []
    for qq in s['questions']:
        if len(qq) == 4 and isinstance(qq[1], list):        # (питання, варіанти, правильний, репліка)
            questions.append({'q_ua': qq[0], 'options': qq[1], 'correct': qq[2], 'answer_turn': qq[3]})
        else:                                               # (питання, відповідь, [інші написання], репліка)
            questions.append({'q_ua': qq[0], 'answer_text': qq[1], 'accept': qq[2], 'answer_turn': qq[3]})
    return {'kind': s['kind'], 'situation_ua': s['situation'], 'script': script, 'questions': questions, 'max_plays': 3}


def listening_answer(t: dict) -> str:
    return '; '.join(qq['options'][qq['correct']] if 'options' in qq else qq['answer_text'] for qq in t['questions'])


def check_listening(t: dict, module: int) -> list[str]:
    e = []
    if t['kind'] not in LISTEN_Q:
        e.append(f'невідомий вид {t["kind"]}')
    if not CYR.search(t['situation_ua']):
        e.append('ситуація не українською')
    if not 3 <= len(t['script']) <= 7:
        e.append(f'реплік {len(t["script"])} (3–7)')
    for line in t['script']:
        if CYR.search(line['hr']) or not line['hr'].strip():
            e.append(f'хорватська репліка: {line["hr"]!r}')
        if len(line['hr']) > 180:
            e.append(f'репліка довша за 180: {line["hr"][:40]}…')
        if not CYR.search(line['ua']):
            e.append(f'переклад не українською: {line["ua"]!r}')
        if t['kind'] == 'dialogue' and not line.get('speaker'):
            e.append('у діалозі потрібен мовець')
    if not 2 <= len(t['questions']) <= 3:
        e.append('потрібно 2–3 запитання')
    correct = []
    for qq in t['questions']:
        if not CYR.search(qq['q_ua']):
            e.append(f'запитання не українською: {qq["q_ua"]!r}')
        if not 0 <= qq['answer_turn'] < len(t['script']):
            e.append(f'answer_turn поза записом: {qq["q_ua"]}')
        if 'options' in qq:
            if len(qq['options']) != 3 or len(set(qq['options'])) != 3 or not 0 <= qq['correct'] < 3:
                e.append(f'варіанти: {qq["q_ua"]}')
            correct.append(qq['correct'])
        elif not qq['answer_text'].strip():
            e.append(f'порожня коротка відповідь: {qq["q_ua"]}')
    shorts = sum('answer_text' in qq for qq in t['questions'])
    if module >= SHORT_FROM and shorts != 1:
        e.append(f'з A2.{SHORT_FROM} одне запитання — коротка відповідь (зараз {shorts})')
    if module < SHORT_FROM and shorts:
        e.append(f'коротка відповідь — лише з A2.{SHORT_FROM}')
    if len(correct) >= 2 and len(set(correct)) < 2:
        e.append('правильна відповідь завжди на тому самому місці')
    return e


def build_course(m: int) -> CourseA2:
    lessons = lessons_of(m)
    places = {k: Place(k[0], k[1], PLACE[k]) for k in lessons}
    pool = [w for mm in MODULES if mm < m for L in lessons_of(mm).values() for w in L['words']]
    extra = {mm: [w for L in lessons_of(mm).values() for w in L['words']] for mm in MODULES if mm < m}
    return CourseA2(level=LEVEL, lessons=lessons, place=places, lex=lex_base(m), situations=SITUATIONS,
                    grammar_keys=set(D.GRAMMAR), seed_prefix='a2v2', extra_pool=pool, extra_module_words=extra,
                    words_range=WORDS_RANGE, vocab_counts=(3, 2, 3))


# ----------------------------------------------------------------------------- письмо й переказ
def writing_ns(m: int) -> SimpleNamespace:
    out = {}
    for (mm, o), L in lessons_of(m).items():
        med = dict(L['mediation'])
        med.setdefault('direction', 'ua_hr')
        med.setdefault('source', med['friend'])
        out[lesson_id(mm, o)] = dict(title=f'A2 урок {PLACE[(mm, o)]} {L["title"][0]}', level=LEVEL, write=L['write'], mediation=med)
    return SimpleNamespace(LESSONS=out, DATE=DATE, TITLE=f'модуль A2.{m}', LEVELS={LEVEL}, MEDIATION_SITUATION=MEDIATION_SITUATION)


def writing_rows(m: int) -> dict[str, list[dict]]:
    by_lesson: dict[str, list[dict]] = {}
    for r in GW.rows(writing_ns(m)):
        by_lesson.setdefault(r['lesson'], []).append(r)
    return by_lesson


# ----------------------------------------------------------------------------- SQL: структура й граматика
def version_sql(entity: str, table: str, ident: str, reason: str) -> str:
    return (f"  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)\n"
            f"  select {q(entity)}, x.id, coalesce((select max(version) from public.content_versions where entity_type = {q(entity)} and entity_id = x.id), 0) + 1,\n"
            f"         to_jsonb(x), {q(reason)} from public.{table} x where x.id = {q(ident)};")


FIX_NOTE = 'curriculum_a2_v2: переклад слова уточнено під значення в уроках A2 — стара версія'
GRAMMAR_NOTE = 'Бета: тема граматики A2 за програмою A2 v2 (рішення власника 2026-11-12). Потрібна перевірка носієм.'


def structure_sql() -> str:
    reason = 'curriculum_a2_v2: нова програма A2 (14 модулів) — стара версія'
    guard = unit_id(1)
    new_mods = [m for m in D.PROGRAM if not D.PROGRAM[m]['old']]
    s = [f"""-- =====================================================================
-- Програма A2 v2 · структура: 14 модулів, юніти, тексти для читання, 22 теми граматики · 2026-11-12
-- Згенеровано: python3 -B scripts/gen_curriculum_a2_v2.py structure (не редагуйте вручну).
--
-- Програма погоджена власником 2026-11-12 (content/reviews/2026-11-12_curriculum_a2_v2_program.md):
--   * 10 DRAFT-модулів A2 (без уроків) — нові місця й назви (id лишається з темою); нові модулі A2.{', A2.'.join(map(str, new_mods))};
--     у кожного модуля — юніт. Модулі лишаються DRAFT: PUBLISHED їх робить SQL модуля разом з уроками.
--   * Тексти для читання A2 (20, бета) — за своїм модулем (module_order → новий номер).
--   * Граматика: 11 тем A2 у базі (DRAFT, 0 правил) — правила, 5 тем — нова назва («нагадування з A1 + розширення A2»);
--     11 нових тем; усі 22 — PUBLISHED (бета), {sum(len(g['rules']) for g in D.GRAMMAR.values())} правил.
--   * Нічого не видаляє; стара версія модулів — у backup.modules_a2_20261112, тем граматики й текстів — у content_versions.
--     Повторний запуск нічого не змінює.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника. Очікуване повідомлення: «Готово: …».
-- Далі: {DATE}_curriculum_a2_v2_m01.sql (модуль A2.1).
-- =====================================================================

begin;

create schema if not exists backup;
create table if not exists backup.modules_a2_20261112 (like public.modules including defaults);
do $$ begin
  if not exists (select 1 from pg_constraint where conname = 'modules_a2_20261112_pkey') then
    alter table backup.modules_a2_20261112 add constraint modules_a2_20261112_pkey primary key (id);
  end if;
end $$;
revoke all on backup.modules_a2_20261112 from anon, authenticated;

do $$
begin
  if exists (select 1 from public.units where id = {q(guard)}) then
    raise notice 'Структуру A2 v2 уже застосовано — пропускаю';
    return;
  end if;
  if (select count(*) from public.modules where level_code = {q(LEVEL)}) <> 10
     or exists (select 1 from public.lessons where level_code = {q(LEVEL)}) then
    raise exception 'Очікувалось 10 модулів A2 без уроків — спершу звірте базу';
  end if;
  -- 1. стара версія модулів — копія в backup; тексти для читання — у content_versions
  insert into backup.modules_a2_20261112 select x.* from public.modules x where x.level_code = {q(LEVEL)} on conflict (id) do nothing;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'reading_text', x.id, coalesce((select max(version) from public.content_versions where entity_type = 'reading_text' and entity_id = x.id), 0) + 1,
         to_jsonb(x), {q(reason)} from public.reading_texts x where x.cefr = {q(LEVEL)};
  -- 2. модулі: тимчасово +100 (unique (level_code, order_index)), потім — нові місця й назви
  update public.modules set order_index = order_index + 100 where level_code = {q(LEVEL)} and order_index < 100;
  -- тексти для читання: старий номер групи → новий модуль (один update)
  update public.reading_texts set module_order = case module_order {' '.join(f'when {g} then {m}' for m in D.PROGRAM for g in D.PROGRAM[m]['reading'])} end
   where cefr = {q(LEVEL)} and module_order between 1 and 10;"""]
    for m in sorted(D.PROGRAM):
        P = D.PROGRAM[m]
        t_ua, t_hr = module_title(m)
        u_ua, u_hr = P['title']
        if P['old']:
            s.append(f"  update public.modules set order_index = {m}, title_ua = {q(t_ua)}, title_hr = {q(t_hr)}, description = {q(P['desc'])}\n"
                     f"   where id = {q(module_id(m))};")
        else:
            s.append("  insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)\n"
                     f"  values ({q(module_id(m))}, {q(LEVEL)}, {q(t_ua)}, {q(t_hr)}, {q(P['desc'])}, {m}, 'DRAFT');")
        s.append("  insert into public.units (id, module_id, title_ua, title_hr, objectives, order_index, status)\n"
                 f"  values ({q(unit_id(m))}, {q(module_id(m))}, {q(u_ua)}, {q(u_hr)}, {qj(P['goals'])}, 1, 'DRAFT');")
    s.append('end $$;\n')
    # граматика
    s.append(f'-- Граматика A2: {len(D.GRAMMAR)} тем')
    for code, g in D.GRAMMAR.items():
        gid = topic_id(code)
        if g['db']:
            s.append(f"""do $$
begin
  if not exists (select 1 from public.grammar_topics where id = {q(gid)}) then raise exception 'Немає теми граматики A2 {code}'; end if;
  if exists (select 1 from public.grammar_rules where topic_id = {q(gid)}) then return; end if;
{version_sql('grammar_topic', 'grammar_topics', gid, 'curriculum_a2_v2: тема A2 отримує правила (нова назва й опис) — стара версія')}
  update public.grammar_topics set title_ua = {q(g['title_ua'])}, title_hr = {q(g['title_hr'])}, description = {q(g['description'])}, status = {q(STATUS)}
   where id = {q(gid)};
end $$;""")
        else:
            s.append('insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)\n'
                     f"values ({q(gid)}, {q(LEVEL)}, {q(g['title_ua'])}, {q(g['title_hr'])}, {q(g['description'])}, {q(STATUS)})\n"
                     'on conflict (id) do nothing;')
        for i, (title, expl, pattern, examples) in enumerate(g['rules'], 1):
            ex = [{'hr': hr, 'ua': ua} for hr, ua in examples]
            s.append('insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)\n'
                     f"values ({q(uid('grammar_rule_a2v2', LEVEL, code, i))}, {q(gid)}, {q(title)}, {q(expl)}, {q(pattern)}, {qj(ex)}, {i})\n"
                     'on conflict (id) do nothing;')
        s.append('insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)\n'
                 f"select 'grammar_topic', {q(gid)}, null, {q(STATUS)}, 'auto_passed', 'ai', '[]'::jsonb, {q(GRAMMAR_NOTE)}\n"
                 f'where not exists (select 1 from public.content_reviews where entity_id = {q(gid)} and notes = {q(GRAMMAR_NOTE)});')
    s.append(f'-- Переклади наявних слів під значення уроків A2 ({len(D.FIX_TRANSLATIONS)}): лише якщо переклад той самий; стара версія — у content_versions')
    for lemma, old_ua, new_ua in D.FIX_TRANSLATIONS:
        s.append(f"""do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = {q(lemma.lower())} and ukrainian_translation = {q(old_ua)} loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), {q(FIX_NOTE)});
    update public.lexemes set ukrainian_translation = {q(new_ua)} where id = r.id;
  end loop;
end $$;""")
    ids = ', '.join(q(topic_id(c)) for c in D.GRAMMAR)
    n_rules = sum(len(g['rules']) for g in D.GRAMMAR.values())
    places = ', '.join(f"({q(module_id(m))}::uuid, {m})" for m in D.PROGRAM)
    s.append(f"""
-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_mod int; v_units int; v_topics int; v_rules int; v_read int;
begin
  select count(*) into v_mod from (values {places}) as t(id, o) join public.modules md on md.id = t.id and md.order_index = t.o and md.level_code = {q(LEVEL)};
  select count(*) into v_units from public.units u join public.modules md on md.id = u.module_id where md.level_code = {q(LEVEL)};
  select count(*) into v_topics from public.grammar_topics where id in ({ids}) and status = {q(STATUS)} and cefr = {q(LEVEL)};
  select count(*) into v_rules from public.grammar_rules where topic_id in ({ids});
  select count(*) into v_read from public.reading_texts where cefr = {q(LEVEL)} and module_order not between 1 and {len(D.PROGRAM)};
  if v_mod <> {len(D.PROGRAM)} then raise exception 'A2: на своїх місцях % модулів з {len(D.PROGRAM)}', v_mod; end if;
  if v_units <> {len(D.PROGRAM)} then raise exception 'A2: юнітів %, очікувалось {len(D.PROGRAM)}', v_units; end if;
  if v_topics <> {len(D.GRAMMAR)} then raise exception 'A2: опублікованих тем граматики % з {len(D.GRAMMAR)}', v_topics; end if;
  if v_rules < {n_rules} then raise exception 'A2: правил граматики % (очікувалось {n_rules})', v_rules; end if;
  if v_read > 0 then raise exception 'A2: % текстів без модуля', v_read; end if;
  raise notice 'Готово: програма A2 v2 — {len(D.PROGRAM)} модулів, {len(D.GRAMMAR)} тем граматики, правил %', v_rules;
end $$;

commit;
""")
    return '\n'.join(s)


# ----------------------------------------------------------------------------- SQL: модуль
HELPER_TASK = """create or replace function pg_temp.ex_task(p_lesson uuid, p_pos int, p_id uuid, p_type text, p_question text, p_answer text,
                                           p_level text, p_status text, p_task jsonb, p_required boolean, p_skill text) returns int language plpgsql as $f$
begin
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, task)
  values (p_id, p_type, p_question, p_answer, null, p_level, 0, p_status, p_task) on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, required, target_skill)
  values (p_lesson, 'exercise', p_id, p_pos + 1, p_required, p_skill);
  return p_pos + 1;
end $f$;
"""
NEW_NOTE = 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.'
WRITING_NOTE = 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.'
LISTEN_NOTE = 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.'


def lexemes_sql(m: int) -> list[str]:
    rows = new_lexemes(m)
    data = [dict(lemma=r['lemma'], normalized=r['normalized'], pos=r['part_of_speech'], ua=r['ukrainian_translation'],
                 vtype=r['vocabulary_type'], forms=r['forms'], examples=r['examples']) for r in rows]
    return [f'-- 1. Слова уроків A2.{m} ({len(rows)}): нові — PUBLISHED (бета); наявні в словнику не змінюються',
            'insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)',
            f"select t.lemma, t.normalized, 'hr', t.pos, {q(LEVEL)}, t.ua, t.vtype, t.forms, t.examples, {q(STATUS)}, {q(SOURCE)}",
            f'  from jsonb_to_recordset({qj(data)})',
            '    as t(lemma text, normalized text, pos text, ua text, vtype text, forms jsonb, examples jsonb)',
            ' where not exists (select 1 from public.lexemes x where lower(x.lemma) = lower(t.lemma))',
            'on conflict do nothing;', '']


def lesson_sql(c: CourseA2, key, wrows: dict) -> list[str]:
    L = c.lessons[key]
    m, o = key
    n = PLACE[key]
    t_ua, t_hr = L['title']
    lid = lesson_id(m, o)
    s = [f'-- A2.{m} · урок {n}: {t_ua} — {len(L["words"])} слів, 2 діалоги, 15 вправ + письмо й переказ',
         'do $$', 'declare', f'  v_unit constant uuid := {q(unit_id(m))};', f'  v_lesson constant uuid := {q(lid)};',
         f'  v_gid constant uuid := {q(topic_id(L["grammar"]))};', '  v_pos int := 0;', 'begin',
         '  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено',
         f"  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики {L['grammar']}'; end if;",
         f'  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = {o}) then',
         f"    raise exception 'A2.{m}: місце {o} зайняте іншим уроком';", '  end if;',
         '  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)',
         f"  values (v_lesson, v_unit, {q(LEVEL)}, {q(f'Урок {n}: {t_ua}')}, {q(f'Lekcija {n}: {t_hr}')}, {qj(L['objectives'])}, {MINUTES}, {q(STATUS)}, {o});",
         '  -- слова']
    for word in L['words']:
        s.append(f'  v_pos := pg_temp.word(v_lesson, {q(word)}, v_pos);')
    s += ['  -- граматика', '  v_pos := v_pos + 1;',
          "  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');",
          '  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;', '  -- вправи']
    for ei, ex in enumerate(c.lesson_exercises(key), 1):
        eid = uid('exercise_a2v2', LEVEL, m, o, ei)
        if ex['type'] == 'listening_dialogue':
            s.append(f"  v_pos := pg_temp.ex_task(v_lesson, v_pos, {q(eid)}, 'listening_dialogue', {q(ex['question'])}, {q(ex['answer'])}, "
                     f"{q(LEVEL)}, {q(STATUS)}, {qj(ex['task'])}, true, 'listening');")
            s.append('  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)')
            s.append(f"  values ('exercise', {q(eid)}, null, {q(STATUS)}, 'auto_passed', 'ai', '[]'::jsonb, {q(LISTEN_NOTE)});")
            continue
        opts = qj(ex['options']) if ex['options'] is not None else 'null'
        lemma = q(ex['word']) if ex.get('word') else 'null'
        s.append(f"  v_pos := pg_temp.ex(v_lesson, v_pos, {q(eid)}, {q(ex['type'])}, {q(ex['question'])}, "
                 f"{q(ex['answer'])}, {opts}, {q(LEVEL)}, {ei}, {q(STATUS)}, {lemma}, {q(ex['skill'])});")
    s.append('  -- письмо й переказ (необов’язкові)')
    for r in wrows[lid]:
        s.append(f"  v_pos := pg_temp.ex_task(v_lesson, v_pos, {q(r['id'])}, {q(r['type'])}, {q(r['question'])}, {q(r['answer'])}, "
                 f"{q(LEVEL)}, {q(STATUS)}, {qj(r['task'])}, false, {q(r['skill'])});")
        s.append('  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)')
        s.append(f"  values ('exercise', {q(r['id'])}, null, {q(STATUS)}, 'auto_passed', 'ai', '[]'::jsonb, {q(WRITING_NOTE)});")
    for si, (s_ua, s_hr, turns) in enumerate(L['scenes'], 1):
        cid = uid('conversation_a2v2', LEVEL, m, o, si)
        s.append(f'  -- діалог {si}')
        s.append('  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)')
        s.append(f"  values ({q(cid)}, v_lesson, {q(s_ua)}, {q(s_hr)}, {5000 + n * 10 + si}, {q(LEVEL)}, {q(L['situation'])}, {q(STATUS)}, {q(SOURCE)}) on conflict (id) do nothing;")
        for ti, (speaker, hr, ua) in enumerate(turns, 1):
            s.append(f"  perform pg_temp.turn({q(uid('turn_a2v2', LEVEL, m, o, si, ti))}, {q(cid)}, {q(speaker)}, {q(hr)}, {q(ua)}, {ti});")
    s += ['  -- журнал перевірки',
          '  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)',
          f"  values ('lesson', v_lesson, null, {q(STATUS)}, 'auto_passed', 'ai', '[]'::jsonb, {q(NEW_NOTE)});", 'end $$;', '']
    return s


def module_out(m: int) -> Path:
    return FIXES / f'{DATE}_curriculum_a2_v2_m{m:02d}.sql'


def build_module(c: CourseA2, m: int) -> str:
    keys = sorted(c.lessons)
    lo, hi = WORDS_RANGE
    words_total = sum(len(c.lessons[k]['words']) for k in keys)
    first, last = PLACE[keys[0]], PLACE[keys[-1]]
    ids = ', '.join(q(lesson_id(*k)) for k in keys)
    titles = ', '.join(f"({q(lesson_id(*k))}::uuid, {q(f'Урок {PLACE[k]}:%')}, {k[1]})" for k in keys)
    t_ua, t_hr = module_title(m)
    wrows = writing_rows(m)
    out = [f"""-- =====================================================================
-- Програма A2 v2 · модуль A2.{m} «{D.PROGRAM[m]['title'][0]}» · 2026-11-12
-- Згенеровано: python3 -B scripts/gen_curriculum_a2_v2.py {m} (не редагуйте вручну).
--
-- Рішення власника 2026-11-12: 20–25 нових слів на урок, 90–95 % слів — нові для рівня, діалоги під тему,
-- частіше Даша / Дар’я; «Прослухайте діалог чи оголошення» в кожному уроці; бета (PUBLISHED).
--   * Уроки {first}–{last} ({len(keys)}): слів у них {words_total}. Кожен: {lo}–{hi} слів, 2 діалоги, 15 вправ
--     (одна — «Прослухайте діалог чи оголошення»), «Напишіть повідомлення» і «Перекажіть другу» (ua → hr, необов’язкові), {MINUTES} хв.
--   * Слова: {len(new_lexemes(m))} (нові — PUBLISHED; ті, що вже є в словнику, не змінюються).
--   * Модуль і юніт A2.{m} → PUBLISHED. Потрібен уже запущений {STRUCTURE_OUT.name}.
--   * Нічого не видаляє. Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

do $$ begin
  if not exists (select 1 from public.units where id = {q(unit_id(m))}) then
    raise exception 'Спершу запустіть {STRUCTURE_OUT.name} (структура A2 v2)';
  end if;
  if not exists (select 1 from pg_constraint where conname = 'exercises_type_check' and conrelid = 'public.exercises'::regclass
                  and pg_get_constraintdef(oid) like '%listening_dialogue%') then
    raise exception 'Спершу потрібна міграція M23 (listening_dialogue)';
  end if;
end $$;
""", HELPERS_SQL, HELPER_TASK]
    out += lexemes_sql(m)
    out.append(f'-- 2. Уроки модуля A2.{m}')
    for key in keys:
        out += lesson_sql(c, key, wrows)
    out.append(f"""-- 3. Модуль і юніт — опубліковані
update public.modules set status = 'PUBLISHED', title_ua = {q(t_ua)}, title_hr = {q(t_hr)} where id = {q(module_id(m))};
update public.units set status = 'PUBLISHED' where id = {q(unit_id(m))};

-- 4. Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_bad int; v_titles int; v_words int;
begin
  select count(*) into v_bad from public.lessons l
   where l.id in ({ids})
     and ((select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'lexeme') not between {lo} and {hi}
          or (select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') <> 2
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED' and li.required) <> 15
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED' and not li.required
                 and e.exercise_type in ('write_message', 'mediation')) <> 2
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and e.exercise_type = 'listening_dialogue' and e.status = 'PUBLISHED') <> 1
          or (select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'grammar') <> 1
          or (select count(*) from public.lesson_grammar lg where lg.lesson_id = l.id) <> 1
          or l.status <> 'PUBLISHED' or l.estimated_minutes <> {MINUTES} or l.unit_id <> {q(unit_id(m))});
  select count(*) into v_titles from (values {titles}) as t(id, pat, o)
    left join public.lessons l on l.id = t.id and l.title_ua like t.pat and l.order_index = t.o
   where l.id is null;
  select count(*) into v_words from (
     select li.item_id from public.lesson_items li join public.lessons l on l.id = li.lesson_id
      where l.level_code = {q(LEVEL)} and l.status = 'PUBLISHED' and li.item_type = 'lexeme'
      group by 1 having count(*) > 1) d;
  if v_bad > 0 then raise exception 'Модуль A2.{m}: % уроків з неправильним складом', v_bad; end if;
  if v_titles > 0 then raise exception 'Модуль A2.{m}: % уроків не на своєму місці чи з неправильним номером', v_titles; end if;
  if v_words > 0 then raise exception 'A2: % слів повторюються в кількох уроках', v_words; end if;
  if (select status from public.modules where id = {q(module_id(m))}) <> 'PUBLISHED' then raise exception 'Модуль A2.{m} не опубліковано'; end if;
  raise notice 'Готово: модуль A2.{m} — {len(keys)} {'уроки' if len(keys) in (2, 3, 4) else 'уроків'}, слів {words_total}';
end $$;

commit;
""")
    return '\n'.join(out)


# ----------------------------------------------------------------------------- перевірки
def validate(c: CourseA2, m: int):
    old = set(SNAPSHOT['lesson_words'])
    for key in sorted(c.lessons):
        c.validate_lesson(key)
        c.lesson_exercises(key)
        L = c.lessons[key]
        n = PLACE[key]
        types = {ex['type'] for ex in c.lesson_exercises(key)}
        if len(types) < 7:
            c.errors.append(f'урок {n}: лише {len(types)} типи вправ з 7 (бракує однозначних слів для «напишіть»)')
        if len(c.lesson_exercises(key)) != 15:
            c.errors.append(f'урок {n}: {len(c.lesson_exercises(key))} вправ (має бути 15)')
        from_old = [w for w in L['words'] if w.lower() in old]
        if len(from_old) > OLD_MAX:
            c.errors.append(f'урок {n}: слів з уроків A0 / A1 {len(from_old)} (не більше {OLD_MAX}): {from_old}')
    if len(c.lessons) != D.PROGRAM[m]['lessons']:
        c.errors.append(f'A2.{m}: уроків {len(c.lessons)}, у програмі {D.PROGRAM[m]["lessons"]}')
    rows = new_lexemes(m)
    errors, _warn = check_batch(rows)
    c.errors += [f'слова: {e}' for e in errors]
    seen: dict = {}
    for key in sorted(c.lessons):
        for w in c.lessons[key]['words']:
            if w.lower() in seen:
                c.errors.append(f'«{w}» є і в уроці {PLACE[seen[w.lower()]]}, і в уроці {PLACE[key]}')
            seen[w.lower()] = key
    earlier = {w.lower(): mm for mm in MODULES if mm < m for L in lessons_of(mm).values() for w in L['words']}
    for w, key in seen.items():
        if w in earlier:
            c.errors.append(f'«{w}» (урок {PLACE[key]}) уже є в модулі A2.{earlier[w]}')
    c.errors += GW.validate(f'a2v2_m{m:02d}', writing_ns(m))


def warnings(m: int) -> list[str]:
    _e, w = check_batch(new_lexemes(m))
    return w


def review(c: CourseA2, m: int) -> str:
    keys = sorted(c.lessons)
    old = set(SNAPSHOT['lesson_words'])
    mod = MODULES[m]
    prod = D.PROD_EXISTING | set(SNAPSHOT.get('lexicon_words', []))
    out = [f'# Програма A2 v2 — модуль A2.{m} «{D.PROGRAM[m]["title"][0]}», звіт для перевірки', '',
           f'> Згенеровано `scripts/gen_curriculum_a2_v2.py --review {m}` 2026-11-12. Бета за рішенням власника 2026-11-12: 20–25 нових слів '
           'за темою, 90–95 % нових для рівня, діалоги під тему, «Прослухайте діалог чи оголошення», письмо й переказ (ua → hr).', '',
           'Порядок уроків: ' + ' → '.join(f'{PLACE[k]} «{c.lessons[k]["title"][0]}»' for k in keys) + '.', '',
           '## Що варто глянути носію', '', *getattr(mod, 'REVIEW_NOTES', ['- Усе як звичайно: слова, діалоги, оголошення.']), '']
    for key in keys:
        L = c.lessons[key]
        n = PLACE[key]
        from_old = [w for w in L['words'] if w.lower() in old]
        in_prod = [w for w in L['words'] if w.lower() in prod]
        out += [f'## Урок {n}: {L["title"][0]} · {L["title"][1]}', '', f'Граматика: «{D.GRAMMAR[L["grammar"]]["title_ua"]}».', '',
                f'**Слова ({len(L["words"])}' + (f'; з уроків A0 / A1: {", ".join(from_old)}' if from_old else '')
                + (f'; уже були в словнику: {", ".join(in_prod)}' if in_prod else '') + '):**', '',
                '| Слово | Переклад | Приклад |', '|---|---|---|']
        examples = {v[0]: v[4] for v in L['vocab']}
        for w in L['words']:
            out.append(f'| {c.lemma_of(w)} | {c.display_ua(w)} | {examples.get(w, "")} |')
        out.append('')
        for s_ua, s_hr, turns in L['scenes']:
            out += [f'**Діалог «{s_hr}»** ({s_ua})', '']
            out += [f'- *{sp}:* {hr} — {ua}' for sp, hr, ua in turns]
            out.append('')
        t = listening_task(L)
        out += [f'**{LISTEN_Q[t["kind"]]}** — {t["situation_ua"]}', '']
        out += [f'- {(ln["speaker"] + ": ") if ln.get("speaker") else ""}{ln["hr"]} — {ln["ua"]}' for ln in t['script']]
        out += [f'- ❓ {qq["q_ua"]} → **{qq["options"][qq["correct"]] if "options" in qq else qq["answer_text"]}**' for qq in t['questions']]
        out += ['', '| Тип | Питання | Відповідь | Варіанти |', '|---|---|---|---|']
        for ex in c.lesson_exercises(key):
            if ex['type'] == 'listening_dialogue':
                continue
            opts = ' · '.join(ex['options']) if ex['options'] else ''
            out.append(f"| {ex['type']} | {ex['question']} | {ex['answer']} | {opts} |")
        w, md = L['write'], L['mediation']
        out += ['', f'**Напишіть повідомлення:** {w["situation"]} Зразок: *{w["models"][0]}*', '',
                f'**Перекажіть другу (ua → hr):** «{md["friend"]}» Зразок: *{md["models"][0]}*', '']
    return '\n'.join(out) + '\n'


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    if args == ['structure']:
        STRUCTURE_OUT.write_text(structure_sql(), encoding='utf-8')
        print(f'{STRUCTURE_OUT.relative_to(ROOT)}: {STRUCTURE_OUT.stat().st_size // 1024} КБ; уроків у програмі: {TOTAL}')
        return
    modules = [int(a) for a in args] or sorted(MODULES)
    courses, errors = {}, []
    for m in modules:
        if m not in MODULES:
            sys.exit(f'Немає даних модуля A2.{m} (scripts/curriculum_a2_v2_m{m:02d}.py)')
        c = build_course(m)
        validate(c, m)
        errors += [f'A2.{m}: {e}' for e in c.errors]
        courses[m] = c
    if errors:
        print('Перевірка не пройдена:', *errors, sep='\n  ', file=sys.stderr)
        sys.exit(1)
    if '--warnings' in sys.argv:
        for m in modules:
            print(*warnings(m), sep='\n')
        return
    if '--review' in sys.argv:
        for m in modules:
            out = REVIEWS / f'2026-11-12_curriculum_a2_v2_m{m:02d}.md'
            out.write_text(review(courses[m], m), encoding='utf-8')
            print(out.relative_to(ROOT))
        return
    for m in modules:
        sql = build_module(courses[m], m)
        out = module_out(m)
        out.write_text(sql, encoding='utf-8')
        print(f'{out.relative_to(ROOT)}: {len(sql.encode()) // 1024} КБ')


if __name__ == '__main__':
    main()
