#!/usr/bin/env python3
"""
Модуль A0.6 «Kućni ljubimci» (домашні тварини) · 2026-11-17 — рішення власника 2026-11-17
(план docs/proposals/2026-11-16_lesson_duplicates.md, §6а і §7, PR 2а).

  python3 -B scripts/gen_a0_pets_module.py              →  supabase/data_fixes/20261117_a0_pets_module.sql
  python3 -B scripts/gen_a0_pets_module.py --check      →  лише перевірка даних (нічого не пише)
  python3 -B scripts/gen_a0_pets_module.py --review     →  content/reviews/2026-11-17_a0_pets_module.md (для носія)
  python3 -B scripts/gen_a0_pets_module.py assessments  →  supabase/data_fixes/20261117_a0_pets_assessments.sql
                                                          (знімок після пакета — scripts/assessment_a0_pets_snapshot.json)

Дані — scripts/curriculum_a0_pets_data.py. Знімок робочої бази — scripts/curriculum_a0_pets_snapshot.json
(уроки A0 і слова всіх уроків; запит — scripts/a0_pets_source.sql).

Пакет 1 (структура й уроки):
  1. модулі A0.6–A0.10 → A0.7–A0.11 (номер у назві теж); новий модуль A0.6 і його юніт; урок A0-37 «Домашні тварини» —
     першим у новий модуль; тексти для читання A0 — за своїм модулем (module_order + 1 для модулів ≥ 6);
     копії — backup.modules_a0_20261117, backup.reading_texts_a0_20261117; стара версія уроку 37 — у content_versions;
  2. нова тема граматики «Можна чи не можна? Smjeti і команди»;
  3. нові слова (з мітками register / regionality / usage_tags; PUBLISHED — бета);
  4. 6 нових уроків (38–43): 20–22 слова, 2 діалоги по 6–8 реплік, 15 вправ, письмо й переказ (необов’язкові);
  5. урок 37: другий діалог «Kod veterinara» → «Koga ćemo uzeti?» (старий — DEPRECATED), вправа «Прослухайте» з нового
     діалогу замість «Je li cijepljen?» (стара — DEPRECATED, копія кроку — backup.lesson_items_a0pets_20261117);
  6. наскрізні номери всіх уроків A0 («Урок N» / «Lekcija N»; 66 → 72), порядок діалогів v4 за новим номером.
Пакет 2 (перевірки): тести модулів a0-m06…a0-m10 → a0-m07…a0-m11; новий тест a0-m06 (14 завдань); тест a0-m05 — наново
(12 завдань: у модулі 6 уроків). Середина (a0-mid, модулі A0.1–A0.5) і фінал не змінюються.
Повторний запуск обох пакетів нічого не змінює.
"""
from __future__ import annotations

import json
import random
import re
import sys
import uuid
from pathlib import Path
from types import SimpleNamespace

sys.dont_write_bytecode = True
HERE = Path(__file__).parent
sys.path.insert(0, str(HERE))
import curriculum_a0_pets_data as D  # noqa: E402
import gen_writing as GW  # noqa: E402
from full_lessons import CYR, HELPERS_SQL, Course, Place, q, qj, shuffled, uid  # noqa: E402
from lexeme_checks import check_batch, normalize  # noqa: E402

ROOT = HERE.resolve().parent
FIXES = ROOT / 'supabase' / 'data_fixes'
REVIEWS = ROOT / 'content' / 'reviews'
SNAPSHOT = json.loads((HERE / 'curriculum_a0_pets_snapshot.json').read_text(encoding='utf-8'))
OUT = FIXES / '20261117_a0_pets_module.sql'
OUT_ASSESS = FIXES / '20261117_a0_pets_assessments.sql'
REVIEW_OUT = REVIEWS / '2026-11-17_a0_pets_module.md'
LEVEL = 'A0'
MOD = 6                     # новий модуль
STATUS = 'PUBLISHED'        # бета (A0 — рішення власника 2026-10-15)
SOURCE = 'claude_curriculum_a0_pets'
MINUTES = 15
OLD_TOTAL, NEW_TOTAL = 66, 72
SITUATIONS = set(re.findall(r"code: '([a-z_]+)'", (ROOT / 'lib' / 'situations.ts').read_text(encoding='utf-8')))
POS = {'n': 'noun', 'v': 'verb', 'adj': 'adjective', 'adv': 'adverb', 'ph': 'phrase', 'prep': 'preposition', 'int': 'interjection'}
MODULE_ID = uid('module_a0pets', LEVEL, MOD)
UNIT_ID = uid('unit_a0pets', LEVEL, MOD, 1)
GRAMMAR_A0 = {  # теми граматики A0 у робочій базі (2026-11-17)
    'Ввічливість: ti і Vi', 'Великі числа: сотні, тисячі, мільйони', 'Вимова: хорватські літери', 'Де? Прийменники місця',
    'Дешевше чи дорожче? Порівняння', 'Дієслово «imati» (мати)', 'Заперечення і питання з «biti»',
    'Особові займенники та дієслово BITI', 'Питальні слова', 'Погода: безособові речення', 'Порядкові числівники', 'Порядок слів',
    'Прикметники: узгодження з іменником', 'Присвійні займенники', 'Рід, множина і «мій / моя / моє»',
    'Цей, той, он той: ovaj, taj, onaj', 'Час: дні, години, місяці', 'Числа 0–100', 'Що болить? Boli me…, bole me…',
}
NEW_GRAMMAR_TITLES = {g['title_ua'] for g in D.NEW_GRAMMAR.values()}
REVIEW_NOTE = ('Бета: новий урок модуля A0.6 «Kućni ljubimci» за схемою уроків за темою (curriculum_a0_v4: 20–25 слів, 2 діалоги, '
               '15 вправ) + письмо й переказ, за рішенням власника 2026-11-17. Потрібна перевірка носієм.')
WRITING_NOTE = ('a0_pets 20261117: «Напишіть повідомлення» і «Перекажіть другу» (§57, §58) у новому уроці модуля A0.6. '
                'Бета, потрібна перевірка носієм.')
GRAMMAR_NOTE = 'Бета: нова тема граматики A0 для уроку «Собака в місті» (модуль A0.6, рішення власника 2026-11-17). Потрібна перевірка носієм.'
L37_NOTE = ('a0_pets 20261117: урок перенесено в модуль A0.6; другий діалог «Kod veterinara» замінено на «Koga ćemo uzeti?» '
            '(ветеринар — окремий урок модуля), вправу «Прослухайте» — з нового діалогу.')
WRITING_NS = uuid.uuid5(uuid.NAMESPACE_URL, 'croatia-survival/writing-pilot-20261105')   # той самий простір, що в gen_writing.py

KEYS = [(MOD, o) for o in range(2, 2 + len(D.LESSONS))]       # (6, 2)…(6, 7); (6, 1) — урок 37
NUMBER = {k: 36 + k[1] for k in KEYS}                         # 38…43


def lesson_id(key) -> str:
    return uid('lesson_a0pets', LEVEL, MOD, D.LESSONS[key[1] - 2]['slug'])


def lessons() -> dict:
    out = {}
    for key, L in zip(KEYS, D.LESSONS):
        L = dict(L)
        L['words'] = [v[0] for v in L['vocab']] + list(L['known'])
        out[key] = L
    return out


LESSONS = lessons()


def forms_of(code: str) -> dict:
    if not code:
        return {}
    if code.split(':')[0] in ('ipfv', 'pfv', 'biasp'):
        a, _, pair = code.partition(':')
        return {'aspect': a, **({'pair': pair} if pair else {})}
    return {'gender': code}


def vtype_of(pos: str, lemma: str) -> str:
    if pos == 'interjection' or lemma in ('daj šapu', 'što mu je'):
        return 'formulaic'
    return {'phrase': 'chunk', 'preposition': 'function_word', 'adverb': 'core'}.get(pos, 'core')


def new_lexemes() -> list[dict]:
    rows = []
    for L in D.LESSONS:
        for v in L['vocab']:
            lemma, ua, pos, forms, example = v[:5]
            register = v[5] if len(v) > 5 else 'standard'
            p = POS[pos]
            rows.append(dict(lemma=lemma, normalized=normalize(lemma), ukrainian_translation=ua, part_of_speech=p, cefr=LEVEL,
                             vocabulary_type=vtype_of(p, lemma), forms=forms_of(forms), examples=[example],
                             register=register, regionality='general', usage_tags=[],
                             **({'proper_noun': True} if lemma[:1].isupper() else {})))
    return rows


def lex_map() -> dict:
    lex = {}
    for L in SNAPSHOT['a0']:
        for lemma, ua in L['words']:
            lex[lemma.lower()] = (lemma, ua)
    for lemma, (ua, _cefr) in D.EXISTING.items():
        lex[lemma.lower()] = (lemma, ua)
    for r in new_lexemes():
        lex[r['lemma'].lower()] = (r['lemma'], r['ukrainian_translation'])
    return lex


L37 = next(L for L in SNAPSHOT['a0'] if L['id'] == D.LESSON37_ID)


class CourseA0Pets(Course):
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
        if L['grammar'] not in self.grammar_keys:
            self.errors.append(f'{w}: невідома граматика {L["grammar"]!r}')
        words = L['words']
        if not 20 <= len(words) <= 25:
            self.errors.append(f'{w}: слів {len(words)} (має бути 20–25)')
        if len({x.lower() for x in words}) != len(words):
            self.errors.append(f'{w}: слова повторюються')
        texts = []
        if len(L['scenes']) != 2:
            self.errors.append(f'{w}: потрібні 2 діалоги')
        for si, (s_ua, s_hr, turns) in enumerate(L['scenes'], 1):
            sw = f'{w}.scene{si}'
            self.check_ua(s_ua, sw)
            self.check_hr(s_hr, sw)
            if not 6 <= len(turns) <= 8:
                self.errors.append(f'{sw}: {len(turns)} реплік (має бути 6–8)')
            for speaker, hr, ua in turns:
                self.check_hr(speaker, sw + '.speaker')
                self.check_hr(hr, sw + '.turn')
                self.check_ua(ua, sw + '.turn')
                if '  ' in hr or hr != hr.strip():
                    self.errors.append(f'{sw}: зайві пробіли в {hr!r}')
            texts.append(' '.join(hr for _, hr, _ in turns))
        question, answer, wrong = L['fill']
        if '___' not in question:
            self.errors.append(f'{w}.fill: немає пропуску ___')
        if len({answer, *wrong}) != 4:
            self.errors.append(f'{w}.fill: потрібно 4 різні варіанти')
        if len(L['build']) != 2 or len(L['listen']) != 2 or len(L['speak']) != 2:
            self.errors.append(f'{w}: потрібно по 2 «складіть», «прослухайте», «скажіть»')
        for hint, sentence in L['build']:
            self.check_ua(hint, w + '.build')
            self.check_hr(sentence, w + '.build')
            self.tokens(sentence, w + '.build')
        for li, sentence in enumerate(L['listen']):
            self.check_hr(sentence, w + '.listen')
            self.tokens(sentence, w + '.listen')
            if sentence not in texts[li]:
                self.errors.append(f'{w}: «прослухайте» {li + 1} не з діалогу {li + 1}: {sentence!r}')
        for ua, hr in L['speak']:
            self.check_ua(ua, w + '.speak')
            self.check_hr(hr, w + '.speak')


# без вправ на слово: «літак» — і zrakoplov, і avion (слово уроку A1) — дві правильні відповіді
NO_VOCAB = {'zrakoplov'}


def build_course() -> CourseA0Pets:
    places = {k: Place(MOD, k[1], NUMBER[k]) for k in KEYS}
    pool = [w for L in SNAPSHOT['a0'] for w, _ua in L['words']]
    return CourseA0Pets(level=LEVEL, lessons=LESSONS, place=places, lex=lex_map(), situations=SITUATIONS,
                        grammar_keys=GRAMMAR_A0 | NEW_GRAMMAR_TITLES, seed_prefix='a0pets', extra_pool=pool, no_vocab=NO_VOCAB,
                        extra_module_words={MOD: [w for w, _ua in L37['words']]}, words_range=(20, 25), vocab_counts=(3, 2, 3))


def writing_d() -> SimpleNamespace:
    return SimpleNamespace(
        DATE=D.DATE, TITLE='модуль A0.6 «Kućni ljubimci»', LEVELS={LEVEL},
        MEDIATION_SITUATION='Друг не знає хорватської. Перекажіть йому українською головне.',
        LESSONS={lesson_id(k): dict(title=f'A0 урок {NUMBER[k]} {LESSONS[k]["title"][0]}', level=LEVEL,
                                    write=LESSONS[k]['write'], mediation=LESSONS[k]['mediation']) for k in KEYS})


def validate(c: CourseA0Pets) -> list[str]:
    for k in KEYS:
        c.validate_lesson(k)
        c.lesson_exercises(k)
    errors = list(c.errors)
    taken = SNAPSHOT['lessons']                           # lower(лема) → перший урок, де вона є (усі рівні)
    seen: dict[str, str] = {}
    new = {r['lemma'].lower() for r in new_lexemes()}
    for k in KEYS:
        L = LESSONS[k]
        for w in L['words']:
            lw = w.lower()
            if lw in taken:
                errors.append(f'урок {NUMBER[k]}: «{w}» уже є в уроці {taken[lw]}')
            if lw in seen:
                errors.append(f'урок {NUMBER[k]}: «{w}» уже є в уроці {seen[lw]} цього модуля')
            seen[lw] = str(NUMBER[k])
        for w in L['known']:
            if w not in D.EXISTING:
                errors.append(f'урок {NUMBER[k]}: «{w}» немає в EXISTING')
            if w.lower() in new:
                errors.append(f'урок {NUMBER[k]}: «{w}» і серед нових, і серед наявних')
        if len(L['vocab']) < 12:
            errors.append(f'урок {NUMBER[k]}: нових слів лише {len(L["vocab"])}')
    if set(D.EXISTING) - {w for L in D.LESSONS for w in L['known']}:
        errors.append(f'EXISTING без уроку: {sorted(set(D.EXISTING) - {w for L in D.LESSONS for w in L["known"]})}')
    e, warnings = check_batch(new_lexemes(), existing={k: v for k, v in taken.items()})
    errors += e
    errors += GW.validate('a0_pets', writing_d())
    # урок 37: новий діалог і «прослухайте»
    s_ua, s_hr, situation, turns = D.LESSON37_SCENE
    if situation not in SITUATIONS or not 6 <= len(turns) <= 8:
        errors.append('урок 37: ситуація чи кількість реплік нового діалогу')
    for speaker, hr, ua in turns:
        if CYR.search(hr) or not CYR.search(ua):
            errors.append(f'урок 37: мова репліки {hr!r}')
    if D.LESSON37_LISTEN not in ' '.join(hr for _, hr, _ in turns):
        errors.append('урок 37: «прослухайте» не з нового діалогу')
    if len(D.LESSON37_LISTEN.split(' ')) != len(set(D.LESSON37_LISTEN.split(' '))):
        errors.append('урок 37: слова «прослухайте» повторюються')
    validate.warnings = warnings
    return errors


# ----------------------------------------------------------------------------- SQL
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


def backup_sql() -> str:
    return """-- 0. Копії до змін (схема backup без доступу для anon / authenticated)
create schema if not exists backup;
create table if not exists backup.modules_a0_20261117 (like public.modules including defaults);
create table if not exists backup.reading_texts_a0_20261117 (id uuid primary key, code text, module_order smallint);
create table if not exists backup.lesson_items_a0pets_20261117 (like public.lesson_items including defaults);
do $$ begin
  if not exists (select 1 from pg_constraint where conname = 'modules_a0_20261117_pkey') then
    alter table backup.modules_a0_20261117 add constraint modules_a0_20261117_pkey primary key (id);
  end if;
  if not exists (select 1 from pg_constraint where conname = 'lesson_items_a0pets_20261117_pkey') then
    alter table backup.lesson_items_a0pets_20261117 add constraint lesson_items_a0pets_20261117_pkey primary key (id);
  end if;
end $$;
revoke all on backup.modules_a0_20261117, backup.reading_texts_a0_20261117, backup.lesson_items_a0pets_20261117 from anon, authenticated;
"""


def structure_sql() -> str:
    t_ua, t_hr = D.MODULE['title']
    u_ua, u_hr = D.MODULE['unit']
    return f"""-- 1. Новий модуль A0.6: модулі A0.6–A0.10 → A0.7–A0.11, урок 37 — у новий модуль, тексти для читання — за модулем
do $$
declare
  v_module constant uuid := {q(MODULE_ID)};
  v_unit constant uuid := {q(UNIT_ID)};
  v_l37 constant uuid := {q(D.LESSON37_ID)};
begin
  if exists (select 1 from public.modules where id = v_module) then return; end if;  -- уже зроблено
  if (select count(*) from public.modules where level_code = 'A0') <> 10 then
    raise exception 'Очікувалось 10 модулів A0 — звірте базу';
  end if;
  if (select m.order_index from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
       where l.id = v_l37) is distinct from 5 then
    raise exception 'Урок 37 «Домашні тварини» не в модулі A0.5 — звірте базу';
  end if;
  insert into backup.modules_a0_20261117 select * from public.modules where level_code = 'A0' on conflict (id) do nothing;
  insert into backup.reading_texts_a0_20261117 select id, code, module_order from public.reading_texts where cefr = 'A0'
  on conflict (id) do nothing;
  -- місця 6–10 → 7–11 через 100+ (unique (level_code, order_index)); номер у назві — за новим місцем
  update public.modules set order_index = order_index + 100 where level_code = 'A0' and order_index >= 6;
  update public.modules
     set order_index = order_index - 99,
         title_ua = regexp_replace(title_ua, '^Модуль A0\\.[0-9]+', 'Модуль A0.' || (order_index - 99)),
         title_hr = regexp_replace(title_hr, '^Modul A0\\.[0-9]+', 'Modul A0.' || (order_index - 99))
   where level_code = 'A0' and order_index > 100;
  insert into public.modules (id, level_code, title_ua, title_hr, description, order_index, status)
  values (v_module, 'A0', {q(f'Модуль A0.{MOD} — {t_ua}')}, {q(f'Modul A0.{MOD} — {t_hr}')}, {q(D.MODULE['description'])}, {MOD}, {q(STATUS)});
  insert into public.units (id, module_id, title_ua, title_hr, objectives, order_index, status)
  values (v_unit, v_module, {q(u_ua)}, {q(u_hr)}, {qj(D.MODULE['objectives'])}, 1, {q(STATUS)});
  -- урок 37 — першим у новий модуль (стара версія — у content_versions)
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'lesson', l.id, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = l.id), 0) + 1,
         to_jsonb(l), 'a0_pets: урок перенесено з модуля A0.5 у новий модуль A0.6 — стара версія'
    from public.lessons l where l.id = v_l37;
  update public.lessons set unit_id = v_unit, order_index = 1 where id = v_l37;
  -- тексти для читання A0 — за своїм модулем
  update public.reading_texts set module_order = module_order + 1 where cefr = 'A0' and module_order >= 6;
end $$;
"""


def grammar_sql() -> list[str]:
    out = [f'-- 2. Нова тема граматики A0 ({len(D.NEW_GRAMMAR)})']
    for key, g in D.NEW_GRAMMAR.items():
        gid = uid('grammar_a0pets', LEVEL, key)
        out.append(
            'insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)\n'
            f"select {q(gid)}, {q(LEVEL)}, {q(g['title_ua'])}, {q(g['title_hr'])}, {q(g['description'])}, {q(STATUS)}\n"
            f"where not exists (select 1 from public.grammar_topics where cefr = {q(LEVEL)} and title_ua = {q(g['title_ua'])});")
        for i, (title, expl, pattern, examples) in enumerate(g['rules'], 1):
            ex = [{'hr': hr, 'ua': ua} for hr, ua in examples]
            out.append(
                'insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)\n'
                f"select {q(uid('grammar_rule_a0pets', LEVEL, key, i))}, {q(gid)}, {q(title)}, {q(expl)}, {q(pattern)}, {qj(ex)}, {i}\n"
                f'where exists (select 1 from public.grammar_topics where id = {q(gid)})\n'
                'on conflict (id) do nothing;')
        out.append(
            'insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)\n'
            f"select 'grammar_topic', {q(gid)}, null, {q(STATUS)}, 'auto_passed', 'ai', '[]'::jsonb, {q(GRAMMAR_NOTE)}\n"
            f'where exists (select 1 from public.grammar_topics where id = {q(gid)})\n'
            f'  and not exists (select 1 from public.content_reviews where entity_id = {q(gid)} and notes = {q(GRAMMAR_NOTE)});')
    out.append('')
    return out


def lexemes_sql() -> list[str]:
    rows = new_lexemes()
    data = [dict(lemma=r['lemma'], normalized=r['normalized'], pos=r['part_of_speech'], ua=r['ukrainian_translation'],
                 vtype=r['vocabulary_type'], forms=r['forms'], examples=r['examples'], register=r['register'],
                 regionality=r['regionality'], usage_tags=r['usage_tags']) for r in rows]
    return [f'-- 3. Нові слова модуля ({len(rows)}): PUBLISHED (бета), з мітками; наявні в словнику не змінюються',
            'insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples,',
            '                            register, regionality, usage_tags, status, source)',
            f"select t.lemma, t.normalized, 'hr', t.pos, {q(LEVEL)}, t.ua, t.vtype, t.forms, t.examples,",
            "       t.register, t.regionality, array(select jsonb_array_elements_text(t.usage_tags)), " f"{q(STATUS)}, {q(SOURCE)}",
            f'  from jsonb_to_recordset({qj(data)})',
            '    as t(lemma text, normalized text, pos text, ua text, vtype text, forms jsonb, examples jsonb, register text, regionality text, usage_tags jsonb)',
            ' where not exists (select 1 from public.lexemes x where lower(x.lemma) = lower(t.lemma))',
            'on conflict do nothing;', '']


def cefr_sql() -> str:
    lemmas = ', '.join(q(w.lower()) for w in D.EXISTING)
    return f"""-- 3а. Наявні слова, які вперше вчать в уроках модуля A0.6 ({len(D.EXISTING)}): рівень слова — A0 (cefr = рівень першого уроку);
--     стара версія — у content_versions
do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) in ({lemmas}) and status = 'PUBLISHED' and cefr is distinct from 'A0' loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'a0_pets: рівень слова A0 — його вперше вчать в уроці модуля A0.6 — стара версія');
    update public.lexemes set cefr = 'A0', version = version + 1 where id = r.id;
  end loop;
end $$;
"""


def writing_rows() -> dict:
    out: dict = {}
    for r in GW.rows(writing_d()):
        out.setdefault(r['lesson'], []).append(r)
    return out


def lesson_sql(c: CourseA0Pets, key, wrows: dict) -> list[str]:
    L = c.lessons[key]
    m, o = key
    n = NUMBER[key]
    t_ua, t_hr = L['title']
    lid = lesson_id(key)
    s = [f'-- {LEVEL}.{m} · урок {n}: {t_ua} — {len(L["words"])} слів, 2 діалоги, {len(c.lesson_exercises(key))} вправ + письмо й переказ',
         'do $$', 'declare', f'  v_unit constant uuid := {q(UNIT_ID)};', f'  v_lesson constant uuid := {q(lid)};', '  v_gid uuid;',
         '  v_pos int := 0;', 'begin',
         '  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено',
         f'  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = {o}) then',
         f"    raise exception '{LEVEL}.{m}: місце {o} зайняте іншим уроком';", '  end if;',
         f"  select id into v_gid from public.grammar_topics where cefr = {q(LEVEL)} and title_ua = {q(L['grammar'])} and status = 'PUBLISHED' order by created_at limit 1;",
         f"  if v_gid is null then raise exception 'Немає теми граматики «{L['grammar']}»'; end if;",
         '  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)',
         f"  values (v_lesson, v_unit, {q(LEVEL)}, {q(f'Урок {n}: {t_ua}')}, {q(f'Lekcija {n}: {t_hr}')}, {qj(L['objectives'])}, {MINUTES}, {q(STATUS)}, {o});",
         '  -- слова']
    for word in L['words']:
        s.append(f'  v_pos := pg_temp.word(v_lesson, {q(word)}, v_pos);')
    s += ['  -- граматика', '  v_pos := v_pos + 1;',
          "  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');",
          '  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;', '  -- вправи']
    for ei, ex in enumerate(c.lesson_exercises(key), 1):
        opts = qj(ex['options']) if ex['options'] is not None else 'null'
        lemma = q(ex['word']) if ex.get('word') else 'null'
        s.append(f"  v_pos := pg_temp.ex(v_lesson, v_pos, {q(uid('exercise_a0pets', LEVEL, m, o, ei))}, {q(ex['type'])}, {q(ex['question'])}, "
                 f"{q(ex['answer'])}, {opts}, {q(LEVEL)}, {ei}, {q(STATUS)}, {lemma}, {q(ex['skill'])});")
    s.append('  -- письмо й переказ (необов’язкові)')
    for r in wrows[lid]:
        s.append(f"  v_pos := pg_temp.ex_task(v_lesson, v_pos, {q(r['id'])}, {q(r['type'])}, {q(r['question'])}, {q(r['answer'])}, "
                 f"{q(LEVEL)}, {q(STATUS)}, {qj(r['task'])}, false, {q(r['skill'])});")
        s.append('  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)')
        s.append(f"  values ('exercise', {q(r['id'])}, null, {q(STATUS)}, 'auto_passed', 'ai', '[]'::jsonb, {q(WRITING_NOTE)});")
    for si, (s_ua, s_hr, turns) in enumerate(L['scenes'], 1):
        cid = uid('conversation_a0pets', LEVEL, m, o, si)
        s.append(f'  -- діалог {si}')
        s.append('  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)')
        s.append(f"  values ({q(cid)}, v_lesson, {q(s_ua)}, {q(s_hr)}, {2000 + n * 10 + si}, {q(LEVEL)}, {q(L['situation'])}, {q(STATUS)}, {q(SOURCE)}) on conflict (id) do nothing;")
        for ti, (speaker, hr, ua) in enumerate(turns, 1):
            s.append(f"  perform pg_temp.turn({q(uid('turn_a0pets', LEVEL, m, o, si, ti))}, {q(cid)}, {q(speaker)}, {q(hr)}, {q(ua)}, {ti});")
    s += ['  -- журнал перевірки',
          '  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)',
          f"  values ('lesson', v_lesson, null, {q(STATUS)}, 'auto_passed', 'ai', '[]'::jsonb, {q(REVIEW_NOTE)});",
          'end $$;', '']
    return s


L37_CONV = uid('conversation_a0pets', LEVEL, MOD, 1, 2)
L37_LISTEN_ID = uid('exercise_a0pets', LEVEL, MOD, 1, 'listen2')


def lesson37_sql() -> str:
    s_ua, s_hr, situation, turns = D.LESSON37_SCENE
    opts = shuffled(D.LESSON37_LISTEN.split(' '), f'l37:{D.LESSON37_LISTEN}')
    rows = '\n'.join(f"  perform pg_temp.turn({q(uid('turn_a0pets', LEVEL, MOD, 1, 2, ti))}, v_conv, {q(sp)}, {q(hr)}, {q(ua)}, {ti});"
                     for ti, (sp, hr, ua) in enumerate(turns, 1))
    return f"""-- 5. Урок 37 «Домашні тварини»: новий другий діалог і нова вправа «Прослухайте» з нього
do $$
declare
  v_lesson constant uuid := {q(D.LESSON37_ID)};
  v_conv constant uuid := {q(L37_CONV)};
  v_old_ex constant uuid := {q(D.LESSON37_OLD_LISTEN)};
  v_new_ex constant uuid := {q(L37_LISTEN_ID)};
  v_payload jsonb;
begin
  if exists (select 1 from public.conversations where id = v_conv) then return; end if;  -- уже зроблено
  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'exercise' and item_id = v_old_ex) then
    raise exception 'В уроці 37 немає вправи «Je li cijepljen?» — звірте базу';
  end if;
  select jsonb_build_object('lesson', to_jsonb(l),
         'items', (select coalesce(jsonb_agg(to_jsonb(li) order by li.order_index), '[]'::jsonb) from public.lesson_items li where li.lesson_id = v_lesson),
         'conversations', (select coalesce(jsonb_agg(c.id order by c.order_index), '[]'::jsonb) from public.conversations c where c.lesson_id = v_lesson and c.status = 'PUBLISHED'))
    into v_payload from public.lessons l where l.id = v_lesson;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  values ('lesson', v_lesson, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = v_lesson), 0) + 1,
          v_payload, 'a0_pets: новий другий діалог і вправа «Прослухайте» — стара версія');
  insert into backup.lesson_items_a0pets_20261117 select li.* from public.lesson_items li where li.lesson_id = v_lesson and li.item_id = v_old_ex
  on conflict (id) do nothing;
  -- старий діалог «Kod veterinara» — застарілий (не видаляється)
  update public.conversations set status = 'DEPRECATED' where id = {q(D.LESSON37_OLD_CONV)} and status = 'PUBLISHED';
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  -- source — як в інших діалогів уроку 37 (урок програми curriculum_a0_v4); звідки діалог — у content_reviews
  values (v_conv, v_lesson, {q(s_ua)}, {q(s_hr)}, {2000 + 37 * 10 + 2}, {q(LEVEL)}, {q(situation)}, {q(STATUS)}, 'claude_curriculum_a0_v4');
{rows}
  -- нова вправа «Прослухайте і складіть фразу» на місці старої
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status)
  select v_new_ex, 'listening', 'Прослухайте і складіть фразу', {q(D.LESSON37_LISTEN)}, {qj(opts)}, {q(LEVEL)}, e.order_index, {q(STATUS)}
    from public.exercises e where e.id = v_old_ex
  on conflict (id) do nothing;
  update public.lesson_items set item_id = v_new_ex where lesson_id = v_lesson and item_type = 'exercise' and item_id = v_old_ex;
  update public.exercises e set status = 'DEPRECATED' where e.id = v_old_ex and e.status = 'PUBLISHED'
     and not exists (select 1 from public.lesson_items x where x.item_type = 'exercise' and x.item_id = e.id);
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, {q(L37_NOTE)});
end $$;
"""


RENUMBER_SQL = """-- 6. Наскрізні номери всіх уроків A0 («Урок N: …» / «Lekcija N: …»); стара назва — у content_versions;
--    порядок діалогів уроків v4 (2000 + N·10 + k) — за новим номером
do $$
declare r record; v_payload jsonb; v_new_ua text; v_new_hr text;
begin
  for r in select l.id, l.title_ua, l.title_hr,
                  row_number() over (order by m.order_index, u.order_index, l.order_index) as n
             from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
            where m.level_code = 'A0' and l.status = 'PUBLISHED' loop
    update public.conversations set order_index = 2000 + r.n * 10 + order_index % 10
     where lesson_id = r.id and order_index between 2000 and 2999 and order_index / 10 <> 200 + r.n;
    v_new_ua := regexp_replace(r.title_ua, '^Урок [0-9]+:', 'Урок ' || r.n || ':');
    v_new_hr := regexp_replace(r.title_hr, '^Lekcija [0-9]+:', 'Lekcija ' || r.n || ':');
    if v_new_ua is not distinct from r.title_ua and v_new_hr is not distinct from r.title_hr then continue; end if;
    select to_jsonb(l) into v_payload from public.lessons l where l.id = r.id;
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lesson', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = r.id), 0) + 1,
            v_payload, 'a0_pets: новий номер уроку ' || r.n || ' (новий модуль A0.6)');
    update public.lessons set title_ua = v_new_ua, title_hr = v_new_hr where id = r.id;
  end loop;
end $$;
"""


def selfcheck_sql(c: CourseA0Pets) -> str:
    ids = ', '.join(q(lesson_id(k)) for k in KEYS)
    nlex = len(new_lexemes())
    lemmas = ', '.join(q(r['lemma'].lower()) for r in new_lexemes())
    return f"""-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_bad int; v_lex int;
begin
  -- 11 модулів A0 на місцях 1–11, номер у назві = місце; у новому модулі — 7 уроків (37–43)
  select count(*) into v_bad from public.modules
   where level_code = 'A0' and (title_ua !~ ('^Модуль A0\\.' || order_index || ' ') or coalesce(title_hr, '') !~ ('^Modul A0\\.' || order_index || ' '));
  if v_bad > 0 or (select count(*) from public.modules where level_code = 'A0') <> 11
     or (select max(order_index) from public.modules where level_code = 'A0') <> 11 then
    raise exception 'Модулі A0: очікувалось 11 на місцях 1–11 з правильними назвами (помилок %)', v_bad;
  end if;
  if (select count(*) from public.lessons l join public.units u on u.id = l.unit_id where u.module_id = {q(MODULE_ID)} and l.status = 'PUBLISHED') <> 7
     or (select order_index from public.lessons where id = {q(D.LESSON37_ID)}) <> 1 then
    raise exception 'Модуль A0.6: очікувалось 7 уроків, урок 37 — першим';
  end if;
  -- нові уроки: 20–25 слів, 2 діалоги по 6–8 реплік, 15 вправ + письмо й переказ
  select count(*) into v_bad from public.lessons l
   where l.id in ({ids})
     and ((select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'lexeme') not between 20 and 25
          or (select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') <> 2
          or exists (select 1 from public.conversations c where c.lesson_id = l.id
                      and (select count(*) from public.conversation_turns t where t.conversation_id = c.id) not between 6 and 8)
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED' and li.required) <> 15
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED' and not li.required
                 and e.exercise_type in ('write_message', 'mediation')) <> 2);
  if v_bad > 0 then raise exception 'Нові уроки: % з неправильним складом', v_bad; end if;
  -- урок 37: 2 опубліковані діалоги, новий — «Koga ćemo uzeti?»
  if (select count(*) from public.conversations where lesson_id = {q(D.LESSON37_ID)} and status = 'PUBLISHED') <> 2
     or not exists (select 1 from public.conversations where id = {q(L37_CONV)} and status = 'PUBLISHED') then
    raise exception 'Урок 37: діалоги не замінено';
  end if;
  -- наскрізна нумерація A0: 1…{NEW_TOTAL} без пропусків
  if (select count(*) from public.lessons where level_code = 'A0' and status = 'PUBLISHED') <> {NEW_TOTAL}
     or exists (select 1 from (select l.title_ua, row_number() over (order by m.order_index, u.order_index, l.order_index) n
                                 from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
                                where m.level_code = 'A0' and l.status = 'PUBLISHED') t
                 where t.title_ua !~ ('^Урок ' || t.n || ':')) then
    raise exception 'Уроки A0: очікувалось {NEW_TOTAL} з номерами 1…{NEW_TOTAL}';
  end if;
  -- нові слова: опубліковані, з мітками
  select count(*) into v_lex from public.lexemes where lower(lemma) in ({lemmas}) and status = 'PUBLISHED'
     and register is not null and regionality is not null and usage_tags is not null;
  if v_lex <> {nlex} then raise exception 'Нових слів: % (очікувалось {nlex})', v_lex; end if;
  if exists (select 1 from public.lexemes where lower(lemma) in ({', '.join(q(w.lower()) for w in D.EXISTING)}) and status = 'PUBLISHED'
              and cefr <> 'A0') then
    raise exception 'Наявні слова модуля — не рівня A0';
  end if;
  -- тексти для читання A0 — за своїм модулем (модуль A0.6 поки без текстів)
  if exists (select 1 from public.reading_texts where cefr = 'A0' and module_order = {MOD}) then
    raise exception 'Тексти A0 не зсунуто за модулями';
  end if;
  raise notice 'Готово: 20261117_a0_pets_module.sql — модуль A0.6 «Kućni ljubimci» (7 уроків), {nlex} нових слів, уроків A0 — {NEW_TOTAL}';
end $$;
"""


def build(c: CourseA0Pets) -> str:
    wrows = writing_rows()
    words = sum(len(LESSONS[k]['words']) for k in KEYS)
    head = f"""-- =====================================================================
-- Модуль A0.6 «Kućni ljubimci» (домашні тварини) · 2026-11-17
-- Згенеровано: python3 -B scripts/gen_a0_pets_module.py (не редагуйте вручну).
--
-- Рішення власника 2026-11-17: новий модуль A0.6 одразу після A0.5; урок 37 «Домашні тварини» — першим у ньому;
-- 6 нових уроків (38–43): «Собака в місті», «Кішки», «У ветеринара», «Тварини на фермі», «Подорож з улюбленцем»,
-- «Притулок і загублена тварина». Модулі A0.6–A0.10 → A0.7–A0.11; уроків A0 {OLD_TOTAL} → {NEW_TOTAL}.
--   * Нові слова: {len(new_lexemes())} (з мітками). Нових уроків: {len(KEYS)}, слів у них: {words}. Нова тема граматики: 1.
--   * Нічого не видаляється: старий діалог і вправа уроку 37 → DEPRECATED; копії — backup.modules_a0_20261117,
--     backup.reading_texts_a0_20261117, backup.lesson_items_a0pets_20261117; старі версії уроків — у content_versions.
--   * Перевірки модулів — окремим пакетом 20261117_a0_pets_assessments.sql (запускати після цього).
--   * Повторний запуск нічого не змінює. Бета: PUBLISHED.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника.
-- Очікуване повідомлення: «Готово: 20261117_a0_pets_module.sql — модуль A0.6 …».
-- =====================================================================

begin;
"""
    out = [head, backup_sql(), HELPERS_SQL, HELPER_TASK, structure_sql()]
    out += grammar_sql()
    out += lexemes_sql()
    out.append(cefr_sql())
    out.append('-- 4. Нові уроки модуля A0.6')
    for k in KEYS:
        out += lesson_sql(c, k, wrows)
    out.append(lesson37_sql())
    out.append(RENUMBER_SQL)
    out.append(selfcheck_sql(c))
    out.append('commit;\n')
    return '\n'.join(out)


# ----------------------------------------------------------------------------- звіт для носія
def review(c: CourseA0Pets) -> str:
    out = ['# Модуль A0.6 «Kućni ljubimci» — для носія мови (2026-11-17)', '',
           'Згенеровано: `python3 -B scripts/gen_a0_pets_module.py --review`. Бета (опубліковано одразу). '
           'Позначте рядок і напишіть, як краще.', '',
           '## Що варто глянути носію', '',
           '1. **Команди собаці** (урок 38): *Sjedi! Lezi! Dođi! Daj šapu!* — чи так кажуть хорвати собаці; *naredba* чи *komanda*.',
           '2. **Тварини**: *mješanac* (метис), *lutalica* (безпритульна тварина), *grebalica* (дряпка), *transporter* (переноска), '
           '*pansion za pse*, *privremeni smještaj* (тимчасова перетримка), *udomitelj* — чи природно.',
           '3. **Вид і пари**: *podrezati / podrezivati*, *zbrinuti / zbrinjavati*, *sklupčati se / sklupčavati se*, *noćiti / prenoćiti*.',
           '4. **Переклад** *nokat* «ніготь; кіготь (у собаки)» і *kandža* «кіготь (у кішки)».',
           '5. Факти в прикладах: «Svaki pas u Hrvatskoj mora imati čip», «Cijepljenje mora biti najmanje tri tjedna prije puta» '
           '(щеплення від сказу — щонайменше за 21 день до поїздки).', '',
           '## Урок 37 «Домашні тварини» — новий другий діалог', '']
    s_ua, s_hr, situation, turns = D.LESSON37_SCENE
    out += [f'**{s_hr}** ({s_ua})', ''] + [f'- **{sp}:** {hr} — {ua}' for sp, hr, ua in turns]
    out += ['', f'«Прослухайте і складіть фразу»: *{D.LESSON37_LISTEN}*', '']
    newlex = {r['lemma']: r for r in new_lexemes()}
    for k in KEYS:
        L = LESSONS[k]
        out += [f'## Урок {NUMBER[k]}: {L["title"][0]} ({L["title"][1]})', '',
                f'Граматика: {L["grammar"]}. Ситуація діалогів: `{L["situation"]}`.', '',
                '| Слово | Переклад | Рід / вид | Мітки | Приклад |', '|---|---|---|---|---|']
        for w in L['words']:
            r = newlex.get(w)
            if r:
                f = r['forms']
                fv = f.get('gender') or (f.get('aspect', '') + (f' / {f["pair"]}' if f.get('pair') else ''))
                out.append(f"| *{w}* | {r['ukrainian_translation']} | {fv} | {r['register']} | {r['examples'][0]} |")
            else:
                out.append(f'| *{w}* | {c.lex[w.lower()][1]} | (є в словнику) | | |')
        for si, (s_ua, s_hr, turns) in enumerate(L['scenes'], 1):
            out += ['', f'**Діалог {si}: {s_hr}** ({s_ua})', ''] + [f'- **{sp}:** {hr} — {ua}' for sp, hr, ua in turns]
        out += ['', '**Вправи**', '', '| Тип | Завдання | Відповідь | Варіанти |', '|---|---|---|---|']
        for ex in c.lesson_exercises(k):
            opts = ' · '.join(ex['options']) if ex['options'] and ex['type'] not in ('sentence_builder', 'listening') else ''
            out.append(f"| {ex['type']} | {ex['question']} | {ex['answer']} | {opts} |")
        out.append('')
    out.append(GW.review('a0_pets', writing_d()).split('\n', 6)[-1])
    return '\n'.join(out) + '\n'


# ----------------------------------------------------------------------------- перевірки (пакет 2)
def assessments_main():
    import gen_assessment_a0_a1_v5 as V5   # noqa: PLC0415
    import gen_assessment as A              # noqa: PLC0415
    snap = json.loads((HERE / 'assessment_a0_pets_snapshot.json').read_text(encoding='utf-8'))
    a0 = next(L for L in snap['levels'] if L['level'] == 'A0')
    if [m['order'] for m in a0['modules']] != list(range(1, 12)) or a0['modules'][MOD - 1]['id'] != MODULE_ID:
        raise SystemExit('Знімок перевірок — не після пакета 20261117_a0_pets_module.sql')
    V5.LEVEL_DATA['A0'] = a0
    # речення середини й фіналу A0 (не змінюються) — не повторюємо в нових тестах модулів
    old = json.loads((HERE / 'assessment_a0_a1_v5_snapshot.json').read_text(encoding='utf-8'))
    seen_level: set[str] = set()
    saved = V5.LEVEL_DATA['A0']
    V5.LEVEL_DATA['A0'] = next(L for L in old['levels'] if L['level'] == 'A0')
    V5._CACHE.clear()
    for t in V5.tests('A0'):
        if t['db_kind'] != 'module':
            seen_level |= {x for it in t['items'] for x in V5.shown(it)}
    V5._CACHE.clear()
    V5.LEVEL_DATA['A0'] = saved
    _pools = A.Pools

    class PrunedPools(_pools):
        def __init__(self, data):
            super().__init__(data)
            V5.prune(self, seen_level)

    A.Pools = PrunedPools
    VER = 'v5pets'
    tests = []
    for m in (5, 6):
        slug = f'a0-m{m:02d}'
        items, plan = V5.module_test('A0', m)
        A.PLAN[slug] = plan
        for i, it in enumerate(items, 1):
            it['module'] = m
            it['order'] = i
            it['id'] = A.uid('assessment', slug, VER, 'item', i)
        tests.append({'slug': slug, 'kind': slug, 'db_kind': 'module', 'module': m, 'title_ua': f'Перевірка модуля A0.{m}', 'items': items})
    A.Pools = _pools
    tests = V5.with_alternatives(A.finalize(tests, 'A0'))
    problems = []
    for t in tests:
        want = V5.n_items('A0', t['module'])
        if len(t['items']) != want:
            problems.append(f"{t['slug']}: {len(t['items'])} завдань, а за схемою {want}")
        if any(it['lesson'] and it['module'] != t['module'] for it in t['items']):
            problems.append(f"{t['slug']}: завдання з іншого модуля")
    problems += V5.check_alternatives(it['answer_text'] for t in tests for it in t['items'] if it['item_type'] == 'sentence_builder')
    if problems:
        raise SystemExit('Перевірка не пройдена:\n' + '\n'.join(problems))
    if '--check' in sys.argv:
        for t in tests:
            print(t['slug'], len(t['items']))
        return tests
    OUT_ASSESS.write_text(assess_sql(V5, A, tests), encoding='utf-8')
    print(f'{OUT_ASSESS.relative_to(ROOT)}: {len(OUT_ASSESS.read_bytes()) // 1024} КБ')
    return tests


ASSESS_NOTE = ('Бета: перевірки рівня A0 за схемою 2026-11-07 (модуль — 2 завдання на урок): тест модуля A0.{m} після нового модуля '
               'A0.6 «Kućni ljubimci» (рішення власника 2026-11-17). Завдання — з діалогів, вправ і текстів уроків модуля. '
               'Потрібна перевірка носієм.')


def assess_sql(V5, A, tests) -> str:
    blocks = []
    for t in tests:
        m = t['module']
        desc, minutes = V5.description('A0', t)
        rows = ',\n'.join(V5.item_row('A0', it) for it in t['items'])
        mod_id = MODULE_ID if m == MOD else '03537c9e-b657-5004-a254-389abb5c8dfc'
        blocks.append(f"""-- {t['title_ua']} · {len(t['items'])} завдань
do $$
declare v_aid uuid; v_payload jsonb; v_shift int;
begin
  select id into v_aid from public.assessments where slug = {q(t['slug'])} and cefr = 'A0';
  if v_aid is null then raise exception 'Немає тесту {t['slug']} — звірте базу'; end if;
  if exists (select 1 from public.assessment_items where id = {q(t['items'][0]['id'])}) then return; end if;  -- уже оновлено
  if (select module_id from public.assessments where id = v_aid) is distinct from {q(mod_id)}::uuid then
    raise exception 'Тест {t['slug']} прив’язаний не до модуля A0.{m} — звірте базу';
  end if;
  select jsonb_build_object('assessment', to_jsonb(a),
         'items', (select coalesce(jsonb_agg(to_jsonb(i) order by i.order_index), '[]'::jsonb)
                     from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED'))
    into v_payload from public.assessments a where a.id = v_aid;
  if jsonb_array_length(v_payload -> 'items') > 0 then
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('assessment', v_aid, coalesce((select max(version) from public.content_versions where entity_type = 'assessment' and entity_id = v_aid), 0) + 1,
            v_payload, 'a0_pets: перевірку модуля оновлено після нового модуля A0.6 — старі завдання');
  end if;
  select (coalesce(max(order_index), 0) / 100 + 1) * 100 into v_shift from public.assessment_items where assessment_id = v_aid;
  update public.assessment_items set status = 'DEPRECATED', order_index = order_index + v_shift
   where assessment_id = v_aid and status = 'PUBLISHED';
  update public.assessments set description_ua = {q(desc)}, estimated_minutes = {minutes} where id = v_aid;
  insert into public.assessment_items (id, assessment_id, order_index, cefr, skill, area, item_type, prompt_ua, prompt_hr, options,
    correct_index, answer_text, answer_alternatives, audio_hr, passage_hr, passage_ua, explanation_ua, lesson_id, status, source) values
{rows};
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('assessment', v_aid, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, {q(ASSESS_NOTE.format(m=m))});
end $$;
""")
    ids = ', '.join(q(it['id']) for t in tests for it in t['items'])
    total = sum(len(t['items']) for t in tests)
    new_aid = A.uid('assessment', 'a0-m06', 'a0pets')
    return f"""-- =====================================================================
-- Перевірки рівня A0 після нового модуля A0.6 «Kućni ljubimci» · 2026-11-17
-- Згенеровано: python3 -B scripts/gen_a0_pets_module.py assessments (не редагуйте вручну).
--
-- Запускати після 20261117_a0_pets_module.sql. Схема 2026-11-07: модуль — 2 завдання на урок (12–20).
--   * Тести модулів a0-m06…a0-m10 → a0-m07…a0-m11 (назва «Перевірка модуля A0.N» і місце — теж); спроби користувачів
--     прив’язані до id тесту й не змінюються. Копія рядків тестів — backup.assessments_a0_20261117.
--   * Новий тест a0-m06 «Перевірка модуля A0.6» — {len(tests[1]['items'])} завдань (7 уроків).
--   * Тест a0-m05 — наново: {len(tests[0]['items'])} завдань (у модулі A0.5 тепер 6 уроків; 5 старих завдань були з уроку 37).
--   * Завдання — з діалогів, вправ і текстів уроків модуля; нових хорватських речень немає. Старі завдання a0-m05 —
--     у content_versions і DEPRECATED. Середина (a0-mid) і фінал (a0-final) не змінюються.
--   * Повторний запуск нічого не змінює.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника.
-- Очікуване повідомлення: «Готово: 20261117_a0_pets_assessments.sql — …».
-- =====================================================================

begin;

create schema if not exists backup;
create table if not exists backup.assessments_a0_20261117 (like public.assessments including defaults);
do $$ begin
  if not exists (select 1 from pg_constraint where conname = 'assessments_a0_20261117_pkey') then
    alter table backup.assessments_a0_20261117 add constraint assessments_a0_20261117_pkey primary key (id);
  end if;
end $$;
revoke all on backup.assessments_a0_20261117 from anon, authenticated;

-- 1. Тести модулів a0-m06…a0-m10 → a0-m07…a0-m11 і новий тест a0-m06
do $$
declare r record;
begin
  if exists (select 1 from public.assessments where id = {q(new_aid)}) then return; end if;  -- уже зроблено
  if not exists (select 1 from public.modules where id = {q(MODULE_ID)} and order_index = {MOD}) then
    raise exception 'Спершу пакет 20261117_a0_pets_module.sql (модуль A0.6)';
  end if;
  insert into backup.assessments_a0_20261117 select * from public.assessments where cefr = 'A0' on conflict (id) do nothing;
  -- з кінця, щоб не зайняти slug наступного тесту (slug унікальний)
  for r in select a.id, m.order_index as mo from public.assessments a join public.modules m on m.id = a.module_id
            where a.cefr = 'A0' and a.kind = 'module' and a.slug ~ '^a0-m(0[6-9]|10)$' order by a.slug desc loop
    update public.assessments
       set slug = 'a0-m' || lpad(r.mo::text, 2, '0'), title_ua = 'Перевірка модуля A0.' || r.mo, order_index = r.mo
     where id = r.id;
  end loop;
  insert into public.assessments (id, slug, kind, title_ua, version, status, source, cefr, module_id, order_index,
                                  pass_ratio, area_min_ratio, estimated_minutes, description_ua)
  select {q(new_aid)}, 'a0-m06', 'module', 'Перевірка модуля A0.6', 1, 'PUBLISHED', a.source, 'A0', {q(MODULE_ID)}, {MOD},
         a.pass_ratio, a.area_min_ratio, a.estimated_minutes, a.description_ua
    from public.assessments a where a.slug = 'a0-m05';
  if exists (select 1 from public.assessments a join public.modules m on m.id = a.module_id
              where a.cefr = 'A0' and a.kind = 'module' and a.slug <> 'a0-m' || lpad(m.order_index::text, 2, '0')) then
    raise exception 'Адреса тесту не збігається з номером модуля';
  end if;
end $$;

{chr(10).join(blocks)}
-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_new int; v_bad int;
begin
  select count(*) into v_new from public.assessment_items where id in ({ids}) and status = 'PUBLISHED';
  select count(*) into v_bad from public.assessments a join public.modules m on m.id = a.module_id
   where a.cefr = 'A0' and a.kind = 'module' and a.status = 'PUBLISHED'
     and (a.slug <> 'a0-m' || lpad(m.order_index::text, 2, '0') or a.title_ua <> 'Перевірка модуля A0.' || m.order_index
          or (select count(*) from public.assessment_items i where i.assessment_id = a.id and i.status = 'PUBLISHED')
             <> greatest(12, least(20, 2 * (select count(*) from public.lessons l join public.units u on u.id = l.unit_id
                                              where u.module_id = m.id and l.status = 'PUBLISHED'))));
  if v_new <> {total} or v_bad > 0 or (select count(*) from public.assessments where cefr = 'A0' and kind = 'module') <> 11 then
    raise exception 'Перевірки A0: нових завдань % (очікувалось {total}), тестів з помилкою %', v_new, v_bad;
  end if;
  raise notice 'Готово: 20261117_a0_pets_assessments.sql — 11 тестів модулів A0, % нових завдань (a0-m05, a0-m06)', v_new;
end $$;

commit;
"""


def main():
    if 'assessments' in sys.argv:
        assessments_main()
        return
    c = build_course()
    errors = validate(c)
    if errors:
        raise SystemExit('ПОМИЛКИ:\n  ' + '\n  '.join(errors))
    for w in validate.warnings:
        print('попередження:', w)
    if '--check' in sys.argv:
        print('OK: уроків', len(KEYS), '; нових слів', len(new_lexemes()))
        return
    if '--review' in sys.argv:
        REVIEW_OUT.write_text(review(c), encoding='utf-8')
        print(f'OK → {REVIEW_OUT.relative_to(ROOT)}')
        return
    sql = build(c)
    OUT.write_text(sql, encoding='utf-8')
    print(f'OK → {OUT.relative_to(ROOT)}: {len(sql.encode()) // 1024} КБ; нових слів {len(new_lexemes())}')


if __name__ == '__main__':
    main()
