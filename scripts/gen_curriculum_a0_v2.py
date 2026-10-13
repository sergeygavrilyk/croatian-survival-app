#!/usr/bin/env python3
"""
Генератор SQL для розширення уроків A0 (curriculum_a0_v2, 2026-10-13).

  python3 scripts/gen_curriculum_a0_v2.py  →  supabase/data_fixes/20261013_curriculum_a0_v2.sql

Дані: scripts/curriculum_a0_v2_data.py (нові слова, друга сцена, вправи)
      scripts/curriculum_a0_v2_snapshot.json (слова уроків v1 і переклади з робочої бази).

Кожен урок A0 отримує: додаткові слова (разом 10–12), другу сцену діалогу,
«склади речення», «аудіювання», 2 × «скажіть уголос» і 5 вправ на слова
(2 × «що означає», 1 × «як хорватською», 2 × «напишіть»). Разом — 12 вправ, ~12 хвилин.

Скрипт спершу перевіряє дані й зупиняється з помилкою, якщо щось не так.
SQL ідемпотентний (детерміновані id, повторний запуск нічого не дублює).
Потребує міграції M13 (типи вправ type_answer і speaking).
"""
import json
import random
import re
import sys
import uuid
from pathlib import Path

sys.dont_write_bytecode = True  # без __pycache__ у репозиторії
sys.path.insert(0, str(Path(__file__).parent))
import curriculum_a0_v2_data as D  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / 'supabase' / 'data_fixes' / '20261013_curriculum_a0_v2.sql'
SNAPSHOT = json.loads((Path(__file__).parent / 'curriculum_a0_v2_snapshot.json').read_text(encoding='utf-8'))
SOURCE = 'claude_curriculum_v2'
NS = uuid.UUID('6f1c7a52-9a43-4b0e-9d1e-0c2a0a0a0a01')  # той самий, що у v1
REVIEW_NOTE = 'Бета: розширення уроку за рішенням власника 2026-10-13 (curriculum_a0_v2). Потрібна перевірка носієм.'
LESSON1_ID = 'c0000000-0000-0000-0000-000000000001'
MINUTES = 12

SITUATIONS = set(re.findall(r"code: '([a-z_]+)'", (ROOT / 'lib' / 'situations.ts').read_text(encoding='utf-8')))
CYR = re.compile(r'[Ѐ-ӿ]')

errors: list[str] = []


def uid(*parts) -> str:
    return str(uuid.uuid5(NS, ':'.join(str(p) for p in parts)))


def q(s) -> str:
    if s is None:
        return 'null'
    return "'" + str(s).replace("'", "''") + "'"


def qj(v) -> str:
    return q(json.dumps(v, ensure_ascii=False)) + '::jsonb'


def lesson_id(n: int) -> str:
    if n == 1:
        return LESSON1_ID
    return uid('lesson', 'A0', (n - 1) // 3 + 1, (n - 1) % 3 + 1)


# ---------------------------------------------------------------- переклади
NEW = {lex[0].lower(): lex for lex in D.NEW_LEXEMES}
TRANSLATIONS: dict[str, str] = dict(SNAPSHOT['translations'])
for low, lex in NEW.items():
    TRANSLATIONS[low] = lex[2]
for low, (old, new) in D.TRANSLATION_FIXES.items():
    if TRANSLATIONS.get(low) == old:
        TRANSLATIONS[low] = new
LEMMA_CASE = {w.lower(): w for ws in SNAPSHOT['lesson_words'].values() for w in ws}
LEMMA_CASE.update({'hrvatska': 'Hrvatska'})
LEMMA_CASE.update({low: lex[0] for low, lex in NEW.items()})


def lemma_of(word: str) -> str:
    return LEMMA_CASE.get(word.lower(), word)


def display_ua(word: str) -> str:
    """Переклад для вправи: без крапки в кінці; з малої літери, якщо слово не власна назва."""
    t = TRANSLATIONS[word.lower()].strip().rstrip('.')
    if lemma_of(word)[:1].islower():
        t = ' / '.join(seg[:1].lower() + seg[1:] for seg in t.split(' / '))
    return t


def fold_ua(t: str) -> str:
    return re.sub(r'[^\w]+', ' ', t.lower()).strip()


# ---------------------------------------------------------------- перевірки
def check_hr(text: str, where: str):
    if not text or not text.strip():
        errors.append(f'{where}: порожній хорватський текст')
    elif CYR.search(text):
        errors.append(f'{where}: кирилиця в хорватському тексті: {text!r}')


def check_ua(text: str, where: str):
    if not text or not CYR.search(text):
        errors.append(f'{where}: український текст без кирилиці: {text!r}')


def tokens(sentence: str, where: str) -> list[str]:
    toks = sentence.split(' ')
    if any(t == '' for t in toks):
        errors.append(f'{where}: подвійний пробіл у {sentence!r}')
    if len(toks) != len(set(toks)):
        errors.append(f'{where}: слова повторюються: {sentence!r}')
    if len(toks) < 2:
        errors.append(f'{where}: замало слів для вправи: {sentence!r}')
    return toks


def lesson_words(n: int) -> tuple[list[str], list[str]]:
    """(усі слова уроку, нові слова v2) — без повторів, у порядку показу."""
    base = D.LESSON1_BASE_WORDS if n == 1 else SNAPSHOT['lesson_words'][str(n)]
    seen = {w.lower() for w in base}
    extra = []
    for w in D.LESSONS[n]['words']:
        if w.lower() not in seen:
            seen.add(w.lower())
            extra.append(w)
    return [*base, *extra], extra


def validate():
    if sorted(D.LESSONS) != list(range(1, 31)):
        errors.append(f'потрібні уроки 1..30, а є {sorted(D.LESSONS)}')
    for lemma, norm, ua, pos, vtype, forms, example in D.NEW_LEXEMES:
        w = f'lexeme {lemma}'
        check_hr(lemma, w)
        check_ua(ua, w)
        check_hr(example, w)
        if vtype not in ('core', 'function_word', 'formulaic', 'collocation', 'chunk'):
            errors.append(f'{w}: vocabulary_type {vtype!r}')
        plain = lemma.lower().translate(str.maketrans('čćđšž', 'ccdsz'))
        if norm != plain:
            errors.append(f'{w}: normalized {norm!r}, а має бути {plain!r}')
    for low, (old, new) in D.TRANSLATION_FIXES.items():
        if SNAPSHOT['translations'].get(low) != old:
            errors.append(f'виправлення перекладу {low}: у знімку не {old!r}')
        check_ua(new, f'виправлення {low}')

    for n, L in D.LESSONS.items():
        w = f'урок {n}'
        situation = SNAPSHOT['lesson_situation'][str(n)]
        if situation not in SITUATIONS:
            errors.append(f'{w}: невідома ситуація {situation!r}')
        for word in L['words']:
            if word.lower() not in TRANSLATIONS:
                errors.append(f'{w}: слова «{word}» немає ні в знімку бази, ні в NEW_LEXEMES')
        all_words, _ = lesson_words(n)
        if not (8 <= len(all_words) <= 12):
            errors.append(f'{w}: слів {len(all_words)} (має бути 8–12)')
        t_ua, t_hr, turns = L['scene']
        check_ua(t_ua, w + '.scene')
        check_hr(t_hr, w + '.scene')
        if not (4 <= len(turns) <= 6):
            errors.append(f'{w}: у сцені {len(turns)} реплік (має бути 4–6)')
        for speaker, hr, ua in turns:
            check_hr(speaker, w + '.speaker')
            check_hr(hr, w + '.turn')
            check_ua(ua, w + '.turn')
        scene_text = ' '.join(hr for _, hr, _ in turns)
        hint, sentence = L['build']
        check_ua(hint, w + '.build')
        check_hr(sentence, w + '.build')
        tokens(sentence, w + '.build')
        check_hr(L['listen'], w + '.listen')
        tokens(L['listen'], w + '.listen')
        if L['listen'] not in scene_text:
            errors.append(f'{w}: «аудіювання» не з другої сцени: {L["listen"]!r}')
        if len(L['speak']) != 2:
            errors.append(f'{w}: потрібно 2 фрази «скажіть уголос»')
        for ua, hr in L['speak']:
            check_ua(ua, w + '.speak')
            check_hr(hr, w + '.speak')
        for ex in L.get('extra', []):
            if ex[0] == 'build':
                check_ua(ex[1], w + '.extra')
                check_hr(ex[2], w + '.extra')
                tokens(ex[2], w + '.extra')
            elif ex[0] == 'listen':
                check_hr(ex[1], w + '.extra')
                tokens(ex[1], w + '.extra')
            else:
                errors.append(f'{w}: невідомий тип додаткової вправи {ex[0]!r}')


# ---------------------------------------------------------------- вправи на слова
ALL_POOL: list[str] = []
for _n in range(1, 31):
    for _w in (D.LESSON1_BASE_WORDS if _n == 1 else SNAPSHOT['lesson_words'][str(_n)]) + D.LESSONS[_n]['words']:
        if _w.lower() not in {x.lower() for x in ALL_POOL}:
            ALL_POOL.append(_w)


STOP_UA = {'я', 'ви', 'ти', 'мені', 'чи', 'з', 'в', 'у', 'на', 'до', 'це', 'будь', 'ласка', 'мова', 'що', 'як'}
SYNONYMS_UA = [{'тато', 'батько'}, {'мама', 'мати'}]


def ua_tokens(word: str) -> set[str]:
    return {t for t in fold_ua(display_ua(word)).split() if t not in STOP_UA}


def too_close(a: str, b: str) -> bool:
    """Переклади перетинаються («рахунок / чек» і «рахунок, будь ласка») або це синоніми (тато / батько)."""
    ta, tb = ua_tokens(a), ua_tokens(b)
    if ta & tb:
        return True
    return any(ta & g and tb & g for g in SYNONYMS_UA)


def ambiguous(word: str) -> bool:
    """Переклад збігається з перекладом іншого слова (ovaj/taj — «цей») — для «як хорватською» не годиться."""
    f = fold_ua(display_ua(word))
    return any(fold_ua(display_ua(o)) == f for o in ALL_POOL if o.lower() != word.lower())


def distractors(n: int, target: str, key, rng: random.Random) -> list[str]:
    """3 інші слова: спершу з цього уроку, потім з модуля, потім з усього A0. key — що має відрізнятися."""
    module = (n - 1) // 3
    lessons_same_module = [x for x in range(module * 3 + 1, module * 3 + 4) if x != n]
    tiers = [lesson_words(n)[0]]
    tiers.append([w for x in lessons_same_module for w in lesson_words(x)[0]])
    tiers.append(ALL_POOL)
    used = {key(target)}
    out: list[str] = []
    for tier in tiers:
        cands = [w for w in tier if w.lower() != target.lower()]
        rng.shuffle(cands)
        for c in cands:
            k = key(c)
            if k in used or not k or too_close(target, c) or any(too_close(c, o) for o in out):
                continue
            used.add(k)
            out.append(c)
            if len(out) == 3:
                return out
    return out


def shuffled(items: list[str], seed: str) -> list[str]:
    if len(set(items)) < 2:
        return list(items)
    for i in range(50):
        out = list(items)
        random.Random(f'{seed}:{i}').shuffle(out)
        if out != items:
            return out
    return list(reversed(items))


def typable(word: str) -> bool:
    return len(word) <= 14 and len(word.split()) <= 2


def vocab_exercises(n: int) -> list[dict]:
    """5 вправ на слова уроку. Детерміновано (seed — номер уроку)."""
    rng = random.Random(f'a0v2:{n}')
    all_words, extra = lesson_words(n)
    order = list(all_words)
    rng.shuffle(order)
    # нові слова — першими: їх учень бачить уперше
    order.sort(key=lambda w: 0 if w in extra else 1)
    taken: set[str] = set()

    def pick(cond) -> str | None:
        for w in order:
            if w.lower() not in taken and w.lower() not in D.NO_VOCAB_EXERCISE and cond(w):
                taken.add(w.lower())
                return w
        return None

    out: list[dict] = []
    plan = [('meaning', lambda w: True), ('meaning', lambda w: True),
            ('choose_hr', lambda w: not ambiguous(w)),
            ('type', lambda w: not ambiguous(w) and typable(w)), ('type', lambda w: not ambiguous(w) and typable(w))]
    for kind, cond in plan:
        w = pick(cond)
        if w is None:
            errors.append(f'урок {n}: не вистачає слів для вправи {kind}')
            continue
        lemma = lemma_of(w)
        if kind == 'meaning':
            ds = distractors(n, w, lambda x: fold_ua(display_ua(x)), rng)
            answer = display_ua(w)
            out.append(dict(type='multiple_choice', word=w, question=f'Що означає «{lemma}»?', answer=answer,
                            options=shuffled([answer, *[display_ua(d) for d in ds]], f'{n}:{w}'), skill='vocabulary', n_opts=len(ds) + 1))
        elif kind == 'choose_hr':
            ds = distractors(n, w, lambda x: lemma_of(x).lower(), rng)
            out.append(dict(type='multiple_choice', word=w, question=f'Як хорватською «{display_ua(w)}»?', answer=lemma,
                            options=shuffled([lemma, *[lemma_of(d) for d in ds]], f'{n}:{w}'), skill='vocabulary', n_opts=len(ds) + 1))
        else:
            out.append(dict(type='type_answer', word=w, question=f'Напишіть хорватською: «{display_ua(w)}»', answer=lemma,
                            options=None, skill='writing'))
    for ex in out:
        if ex.get('n_opts', 4) != 4:
            errors.append(f'урок {n}: для «{ex["word"]}» лише {ex["n_opts"]} варіанти')
    return out


def lesson_exercises(n: int) -> list[dict]:
    L = D.LESSONS[n]
    out: list[dict] = []
    builds = [('build', *L['build'])] + [e for e in L.get('extra', []) if e[0] == 'build']
    listens = [('listen', L['listen'])] + [e for e in L.get('extra', []) if e[0] == 'listen']
    for _, hint, sentence in builds:
        out.append(dict(type='sentence_builder', question=hint, answer=sentence,
                        options=shuffled(sentence.split(' '), f'b{n}:{sentence}'), skill='writing'))
    for _, sentence in listens:
        out.append(dict(type='listening', question='Прослухайте і складіть фразу', answer=sentence,
                        options=shuffled(sentence.split(' '), f'l{n}:{sentence}'), skill='listening'))
    for ua, hr in L['speak']:
        out.append(dict(type='speaking', question=ua, answer=hr, options=None, skill='speaking'))
    return vocab_exercises(n) + out


# ---------------------------------------------------------------- SQL
def lexemes_sql(out: list[str]):
    out.append('-- 1. Нові слова A0 (яких ще немає у словнику)')
    for lemma, norm, ua, pos, vtype, forms, example in D.NEW_LEXEMES:
        out.append(
            'insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)\n'
            f"values ({q(lemma)}, {q(norm)}, 'hr', {q(pos)}, 'A0', {q(ua)}, {q(vtype)}, {qj(forms)}, {qj([example])}, 'PUBLISHED', {q(SOURCE)})\n"
            'on conflict do nothing;'
        )
    out.append('')


def fixes_sql(out: list[str]):
    out.append('-- 2. Виправлення перекладів (старий варіант зберігається в content_versions)')
    for low, (old, new) in D.TRANSLATION_FIXES.items():
        note = f'curriculum_a0_v2: переклад «{old}» → «{new}»'
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
    out.append('')


def lesson_sql(out: list[str], n: int):
    L = D.LESSONS[n]
    lid = lesson_id(n)
    _, extra = lesson_words(n)
    t_ua, t_hr, turns = L['scene']
    cid = uid('conversation_v2', 'A0', n)
    situation = SNAPSHOT['lesson_situation'][str(n)]
    s = [f'-- Урок {n}: +{len(extra)} слів, сцена «{t_ua}», 9 нових вправ',
         'do $$', 'declare',
         f'  v_lesson constant uuid := {q(lid)};',
         '  v_id uuid;', '  v_pos int;', 'begin',
         "  if not exists (select 1 from public.lessons where id = v_lesson) then",
         f"    raise notice 'Урок {n} не знайдено — пропускаю'; return;",
         '  end if;',
         f'  if exists (select 1 from public.conversations where id = {q(cid)}) then return; end if;  -- уже розширено',
         '  select coalesce(max(order_index), 0) into v_pos from public.lesson_items where lesson_id = v_lesson;',
         '']
    if extra:
        s.append('  -- нові слова')
    for word in extra:
        s.append(f"  select id into v_id from public.lexemes where lower(lemma) = lower({q(word)}) and status = 'PUBLISHED' order by created_at limit 1;")
        s.append(f"  if v_id is null then raise exception 'Немає опублікованого слова «%»', {q(word)}; end if;")
        s.append("  if not exists (select 1 from public.lesson_items where lesson_id = v_lesson and item_type = 'lexeme' and item_id = v_id) then")
        s.append("    v_pos := v_pos + 1;")
        s.append("    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');")
        s.append('  end if;')
    s.append('  -- вправи')
    for ei, ex in enumerate(lesson_exercises(n), 1):
        eid = uid('exercise_v2', 'A0', n, ei)
        lex = 'null'
        if ex.get('word'):
            s.append(f"  select id into v_id from public.lexemes where lower(lemma) = lower({q(ex['word'])}) and status = 'PUBLISHED' order by created_at limit 1;")
            lex = 'v_id'
        opts = qj(ex['options']) if ex['options'] is not None else 'null'
        s.append('  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)')
        s.append(f"  values ({q(eid)}, {q(ex['type'])}, {q(ex['question'])}, {q(ex['answer'])}, {opts}, 'A0', {10 + ei}, 'PUBLISHED', {lex}) on conflict (id) do nothing;")
        s.append('  v_pos := v_pos + 1;')
        s.append(f"  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', {q(eid)}, v_pos, {q(ex['skill'])});")
    s.append('  -- друга сцена діалогу')
    s.append('  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)')
    s.append(f"  values ({q(cid)}, v_lesson, {q(t_ua)}, {q(t_hr)}, {100 + n}, 'A0', {q(situation)}, 'PUBLISHED', {q(SOURCE)});")
    for ti, (speaker, hr, ua) in enumerate(turns, 1):
        s.append('  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)')
        s.append(f"  values ({q(uid('turn_v2', 'A0', n, ti))}, {q(cid)}, {q(speaker)}, {q(hr)}, {q(ua)}, {ti}) on conflict (id) do nothing;")
    if n == 1:
        s.append("  -- перший діалог уроку 1 створено до v1: доповнюємо рівень і ситуацію")
        s.append("  update public.conversations set level = coalesce(level, 'A0'), situation = coalesce(situation, 'basics')")
        s.append("   where lesson_id = v_lesson and id <> " + q(cid) + ' and (level is null or situation is null);')
    s.append(f'  update public.lessons set estimated_minutes = {MINUTES} where id = v_lesson;')
    s.append('  -- журнал перевірки')
    s.append('  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)')
    s.append(f"  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, {q(REVIEW_NOTE)}),")
    s.append(f"         ('conversation', {q(cid)}, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, {q(REVIEW_NOTE)});")
    s.append('end $$;')
    s.append('')
    out.extend(s)


def build() -> str:
    out: list[str] = [f"""-- =====================================================================
-- Розширення уроків A0 · curriculum_a0_v2 · 2026-10-13
-- Згенеровано: python3 scripts/gen_curriculum_a0_v2.py (не редагуйте вручну).
--
--   * Кожен з 30 уроків A0: +слова (разом 10–12), друга сцена діалогу, 9 нових вправ
--     (склади речення, аудіювання, 2 × скажіть уголос, 5 вправ на слова) → ~{MINUTES} хв.
--   * Нові слова: {len(D.NEW_LEXEMES)}. Виправлення перекладів: {len(D.TRANSLATION_FIXES)} (старі — у content_versions).
--   * Статус PUBLISHED: бета за рішенням власника (як і A0 v1).
--   * Наявні вправи, слова й діалоги НЕ видаляються. Повторний запуск безпечний.
--   * Потрібна міграція M13 (20261013140000_m13_exercise_types.sql).
--   * Нові типи вправ (type_answer, speaking, multiple_choice) показує лише новий екран уроку
--     (components/lesson/LessonPlayer.tsx). Старий LessonView на сайті їх не вміє — після запуску
--     перевірте на localhost і оновіть сайт (push).
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
end $$;
"""]
    lexemes_sql(out)
    fixes_sql(out)
    out.append('-- 3. Уроки')
    for n in range(1, 31):
        lesson_sql(out, n)
    out.append("""-- 4. Самоперевірка: якщо щось не так — усе відкочується
do $$
declare
  v_short int; v_one_scene int; v_few_words int;
begin
  select count(*) into v_short from public.lessons l
   where l.level_code = 'A0' and l.status = 'PUBLISHED'
     and (select count(*) from public.lesson_items i where i.lesson_id = l.id and i.item_type = 'exercise') < 12;
  select count(*) into v_one_scene from public.lessons l
   where l.level_code = 'A0' and l.status = 'PUBLISHED'
     and (select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') < 2;
  select count(*) into v_few_words from public.lessons l
   where l.level_code = 'A0' and l.status = 'PUBLISHED'
     and (select count(*) from public.lesson_items i where i.lesson_id = l.id and i.item_type = 'lexeme') < 8;
  if v_short > 0 then raise exception 'A0: % уроків мають менше 12 вправ', v_short; end if;
  if v_one_scene > 0 then raise exception 'A0: % уроків без другої сцени', v_one_scene; end if;
  if v_few_words > 0 then raise exception 'A0: % уроків мають менше 8 слів', v_few_words; end if;
  raise notice 'Готово: усі 30 уроків A0 розширено';
end $$;

commit;

-- Перевірка (окремим запитом після запуску):
-- select l.title_ua, l.estimated_minutes as хв,
--   (select count(*) from public.lesson_items i where i.lesson_id = l.id and i.item_type = 'lexeme') as слів,
--   (select count(*) from public.lesson_items i where i.lesson_id = l.id and i.item_type = 'exercise') as вправ,
--   (select count(*) from public.conversations c where c.lesson_id = l.id) as діалогів
-- from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
-- where l.level_code = 'A0' order by m.order_index, l.order_index;
""")
    return '\n'.join(out)


def review_table() -> str:
    """Таблиця вправ на слова — для звіту content/reviews (python3 … --review)."""
    rows = []
    for n in range(1, 31):
        for ex in lesson_exercises(n):
            opts = ' · '.join(ex['options']) if ex['type'] == 'multiple_choice' else ''
            rows.append(f"| {n} | {ex['type']} | {ex['question']} | {ex['answer']} | {opts} |")
    return '| Урок | Тип | Завдання | Відповідь | Варіанти |\n|---|---|---|---|---|\n' + '\n'.join(rows)


if __name__ == '__main__':
    validate()
    if errors:
        print('ПОМИЛКИ В ДАНИХ:', *errors, sep='\n  ')
        sys.exit(1)
    sql = build()  # вправи на слова теж перевіряються під час побудови
    if errors:
        print('ПОМИЛКИ В ДАНИХ:', *errors, sep='\n  ')
        sys.exit(1)
    if '--review' in sys.argv:
        print(review_table())
        sys.exit(0)
    OUT.write_text(sql, encoding='utf-8')
    print(f'OK → {OUT.relative_to(ROOT)}')
