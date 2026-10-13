"""
Спільна логіка «повного уроку» (структура v2, ~12 хв) для генераторів програм:
  scripts/gen_curriculum_a1.py (A1) і scripts/gen_curriculum_a0_v3.py (доповнення A0).

Урок (dict у файлі даних):
  title=(ua, hr), situation, grammar (ключ теми), objectives=[…],
  words=[10–14 лем зі словника], scenes=[(назва_ua, назва_hr, [(мовець, hr, ua), …]) × 2],
  fill=(речення з ___, відповідь, [3 хибні]), build=[(підказка_ua, hr) × 2],
  listen=[репліка з діалогу 1, репліка з діалогу 2], speak=[(ua, hr) × 2].

Вправи (12): вставте слово, 2 × «що означає», «як хорватською», 2 × «напишіть»,
2 × «складіть», 2 × аудіювання, 2 × «скажіть уголос».

Ключ уроку — будь-яке значення; місце в програмі (модуль, місце в юніті, номер) задає Course.place.
"""
from __future__ import annotations

import json
import random
import re
import uuid
from dataclasses import dataclass, field
from typing import Callable

NS = uuid.UUID('6f1c7a52-9a43-4b0e-9d1e-0c2a0a0a0a01')  # той самий простір, що в A0 v1 і каркасі
CYR = re.compile(r'[Ѐ-ӿ]')
VOCAB_TYPES = ('core', 'function_word', 'formulaic', 'collocation', 'chunk')
STOP_UA = {'я', 'ви', 'ти', 'мені', 'чи', 'з', 'в', 'у', 'на', 'до', 'це', 'будь', 'ласка', 'мова', 'що', 'як', 'для', 'від'}
SYNONYMS_UA = [{'лікар', 'лікарка'}, {'колега'}, {'відпочинок', 'відпочивати', 'відпустка'}, {'запізнюватися', 'запізнення'},
               {'квиток'}, {'подобатися', 'любити'}, {'дзвінок'}, {'тато', 'батько'}, {'мама', 'мати'},
               {'вітаю', 'привітати', 'вітати'}]

# Короткий запис уроку (compact=True): допоміжні функції живуть лише до кінця сеансу SQL Editor.
# Так файл утричі менший — SQL Editor Supabase не приймає запити понад ~0,5–1 МБ.
HELPERS_SQL = """-- Допоміжні функції (тимчасові: зникають після запуску)
create or replace function pg_temp.word(p_lesson uuid, p_lemma text, p_pos int) returns int language plpgsql as $f$
declare v_id uuid;
begin
  select id into v_id from public.lexemes where lower(lemma) = lower(p_lemma) and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', p_lemma; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (p_lesson, 'lexeme', v_id, p_pos + 1, 'vocabulary');
  return p_pos + 1;
end $f$;

create or replace function pg_temp.ex(p_lesson uuid, p_pos int, p_id uuid, p_type text, p_question text, p_answer text, p_options jsonb,
                                      p_level text, p_order int, p_status text, p_lemma text, p_skill text) returns int language plpgsql as $f$
declare v_id uuid;
begin
  if p_lemma is not null then
    select id into v_id from public.lexemes where lower(lemma) = lower(p_lemma) and status = 'PUBLISHED' order by created_at limit 1;
  end if;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values (p_id, p_type, p_question, p_answer, p_options, p_level, p_order, p_status, v_id) on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (p_lesson, 'exercise', p_id, p_pos + 1, p_skill);
  return p_pos + 1;
end $f$;

create or replace function pg_temp.turn(p_id uuid, p_conv uuid, p_speaker text, p_hr text, p_ua text, p_order int) returns void language sql as $f$
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values (p_id, p_conv, p_speaker, p_hr, p_ua, p_order) on conflict (id) do nothing;
$f$;
"""


def uid(*parts) -> str:
    return str(uuid.uuid5(NS, ':'.join(str(p) for p in parts)))


def q(s) -> str:
    if s is None:
        return 'null'
    return "'" + str(s).replace("'", "''") + "'"


def qj(v) -> str:
    return q(json.dumps(v, ensure_ascii=False)) + '::jsonb'


def fold_ua(t: str) -> str:
    return re.sub(r'[^\w]+', ' ', t.lower()).strip()


def shuffled(items: list[str], seed: str) -> list[str]:
    """Детерміноване перемішування, гарантовано відмінне від оригіналу."""
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


@dataclass
class Place:
    module: int
    order: int      # місце в юніті (1…)
    number: int     # наскрізний номер уроку на рівні (для назви)


@dataclass
class Course:
    level: str
    lessons: dict                       # ключ → урок
    place: dict                         # ключ → Place
    lex: dict                           # lower(лема) → (лема, переклад)
    situations: set
    grammar_keys: set
    seed_prefix: str                    # 'a1' — для детермінованих вправ
    no_vocab: set = field(default_factory=set)
    extra_pool: list = field(default_factory=list)   # слова наявних уроків (для хибних варіантів і неоднозначності)
    extra_module_words: dict = field(default_factory=dict)  # модуль → слова наявних уроків модуля
    words_range: tuple = (10, 12)
    errors: list = field(default_factory=list)

    # ------------------------------------------------------------ переклади
    def lemma_of(self, word: str) -> str:
        return self.lex[word.lower()][0]

    def display_ua(self, word: str) -> str:
        """Переклад для вправи: без крапки в кінці; з малої літери, якщо слово не власна назва."""
        t = self.lex[word.lower()][1].strip().rstrip('.')
        if self.lemma_of(word)[:1].islower():
            t = ' / '.join(seg[:1].lower() + seg[1:] for seg in t.split(' / '))
        return t

    # ------------------------------------------------------------ перевірки
    def check_hr(self, text: str, where: str):
        if not text or not text.strip():
            self.errors.append(f'{where}: порожній хорватський текст')
        elif CYR.search(text):
            self.errors.append(f'{where}: кирилиця в хорватському тексті: {text!r}')

    def check_ua(self, text: str, where: str):
        if not text or not CYR.search(text):
            self.errors.append(f'{where}: український текст без кирилиці: {text!r}')

    def tokens(self, sentence: str, where: str):
        toks = sentence.split(' ')
        if any(t == '' for t in toks):
            self.errors.append(f'{where}: подвійний пробіл у {sentence!r}')
        if len(toks) != len(set(toks)):
            self.errors.append(f'{where}: слова повторюються: {sentence!r}')
        if len(toks) < 2:
            self.errors.append(f'{where}: замало слів для вправи: {sentence!r}')

    def name(self, key) -> str:
        p = self.place[key]
        return f'{self.level}.{p.module} урок {p.number}'

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
            texts.append(' '.join(hr for _, hr, _ in turns))
        question, answer, wrong = L['fill']
        if '___' not in question:
            self.errors.append(f'{w}.fill: немає пропуску ___')
        self.check_hr(question, w + '.fill')
        if len({answer, *wrong}) != 4 or len(wrong) != 3:
            self.errors.append(f'{w}.fill: потрібно 4 різні варіанти')
        if len(L['build']) != 2 or len(L['listen']) != 2 or len(L['speak']) != 2:
            self.errors.append(f'{w}: потрібно по 2 «складіть», «аудіювання», «скажіть»')
        for hint, sentence in L['build']:
            self.check_ua(hint, w + '.build')
            self.check_hr(sentence, w + '.build')
            self.tokens(sentence, w + '.build')
        for li, sentence in enumerate(L['listen']):
            self.check_hr(sentence, w + '.listen')
            self.tokens(sentence, w + '.listen')
            if li < len(texts) and sentence not in texts[li]:
                self.errors.append(f'{w}: «аудіювання» {li + 1} не з діалогу {li + 1}: {sentence!r}')
        for ua, hr in L['speak']:
            self.check_ua(ua, w + '.speak')
            self.check_hr(hr, w + '.speak')

    # ------------------------------------------------------------ вправи на слова
    def all_pool(self) -> list[str]:
        if not hasattr(self, '_pool'):
            pool: list[str] = []
            seen: set[str] = set()
            for w in [*self.extra_pool, *(x for L in self.lessons.values() for x in L['words'])]:
                if w.lower() not in seen and w.lower() in self.lex:
                    seen.add(w.lower())
                    pool.append(w)
            self._pool = pool
        return self._pool

    def ua_tokens(self, word: str) -> set[str]:
        return {t for t in fold_ua(self.display_ua(word)).split() if t not in STOP_UA}

    def too_close(self, a: str, b: str) -> bool:
        """Переклади перетинаються («рахунок / чек» і «банківський рахунок») або це близькі слова (лікар / лікарка)."""
        ta, tb = self.ua_tokens(a), self.ua_tokens(b)
        if ta & tb:
            return True
        return any(ta & g and tb & g for g in SYNONYMS_UA)

    def ambiguous(self, word: str) -> bool:
        """Переклад збігається чи перетинається з перекладом іншого слова — для «як хорватською» і «напишіть»
        таке слово не годиться: правильних відповідей було б дві."""
        f = fold_ua(self.display_ua(word))
        return any(fold_ua(self.display_ua(o)) == f or self.too_close(word, o)
                   for o in self.all_pool() if o.lower() != word.lower())

    def distractors(self, key, target: str, keyf: Callable[[str], str], rng: random.Random) -> list[str]:
        module = self.place[key].module
        same_module = [w for k, p in self.place.items() if p.module == module and k != key for w in self.lessons[k]['words']]
        same_module += self.extra_module_words.get(module, [])
        tiers = [self.lessons[key]['words'], same_module, self.all_pool()]
        used = {keyf(target)}
        out: list[str] = []
        for tier in tiers:
            cands = [w for w in tier if w.lower() != target.lower() and w.lower() in self.lex]
            rng.shuffle(cands)
            for c in cands:
                k = keyf(c)
                if k in used or not k or self.too_close(target, c) or any(self.too_close(c, o) for o in out):
                    continue
                used.add(k)
                out.append(c)
                if len(out) == 3:
                    return out
        return out

    def vocab_exercises(self, key) -> list[dict]:
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

        out: list[dict] = []
        plan = [('meaning', lambda w: True), ('meaning', lambda w: True),
                ('choose_hr', lambda w: not self.ambiguous(w)),
                ('type', lambda w: not self.ambiguous(w) and typable(w)),
                ('type', lambda w: not self.ambiguous(w) and typable(w))]
        for kind, cond in plan:
            w = pick(cond)
            if w is None:
                self.errors.append(f'{self.name(key)}: не вистачає слів для вправи {kind}')
                continue
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
        out = [dict(type='fill_in_the_blank', question=question, answer=answer,
                    options=shuffled([answer, *wrong], f'f{key}'), skill='grammar')]
        out += self.vocab_exercises(key)
        for hint, sentence in L['build']:
            out.append(dict(type='sentence_builder', question=hint, answer=sentence,
                            options=shuffled(sentence.split(' '), f'b{key}:{sentence}'), skill='writing'))
        for sentence in L['listen']:
            out.append(dict(type='listening', question='Прослухайте і складіть фразу', answer=sentence,
                            options=shuffled(sentence.split(' '), f'l{key}:{sentence}'), skill='listening'))
        for ua, hr in L['speak']:
            out.append(dict(type='speaking', question=ua, answer=hr, options=None, skill='speaking'))
        self._ex_cache[key] = out
        return out

    # ------------------------------------------------------------ SQL
    def lesson_sql(self, key, *, status: str, source: str, note: str, minutes: int, grammar_lookup: str,
                   compact: bool = False) -> list[str]:
        """DO-блок, що створює урок. grammar_lookup — SQL, який кладе id теми граматики у v_gid.
        compact=True — короткий запис через HELPERS_SQL (їх треба вставити на початок файлу); результат у БД той самий."""
        L = self.lessons[key]
        p = self.place[key]
        m, o, n = p.module, p.order, p.number
        lv = self.level
        lid = uid('lesson', lv, m, o)
        t_ua, t_hr = L['title']
        s = [f'-- {lv}.{m} · урок {n}: {t_ua}', 'do $$', 'declare',
             '  v_unit uuid;', f'  v_lesson constant uuid := {q(lid)};', '  v_id uuid;', '  v_gid uuid;', '  v_pos int := 0;', 'begin',
             '  select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id',
             f"   where m.level_code = {q(lv)} and m.order_index = {m} and u.order_index = 1;",
             f"  if v_unit is null then raise exception 'Немає юніта для модуля {lv}.{m}'; end if;",
             '  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено',
             f'  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = {o}) then',
             f"    raise exception '{lv}.{m}: місце уроку {o} вже зайняте іншим уроком';",
             '  end if;',
             f'  {grammar_lookup}',
             f"  if v_gid is null then raise exception 'Немає граматичної теми для уроку {lv}.{m}.{o}'; end if;",
             '  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)',
             f"  values (v_lesson, v_unit, {q(lv)}, {q(f'Урок {n}: {t_ua}')}, {q(f'Lekcija {n}: {t_hr}')}, {qj(L['objectives'])}, {minutes}, {q(status)}, {o});",
             '  -- слова']
        if compact:
            return self._lesson_sql_compact(s, key, status=status, source=source, note=note)
        for word in L['words']:
            s.append(f"  select id into v_id from public.lexemes where lower(lemma) = lower({q(word)}) and status = 'PUBLISHED' order by created_at limit 1;")
            s.append(f"  if v_id is null then raise exception 'Немає опублікованого слова «%»', {q(word)}; end if;")
            s.append('  v_pos := v_pos + 1;')
            s.append("  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'lexeme', v_id, v_pos, 'vocabulary');")
        s.append('  -- граматика')
        s.append('  v_pos := v_pos + 1;')
        s.append("  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');")
        s.append('  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;')
        s.append('  -- вправи')
        for ei, ex in enumerate(self.lesson_exercises(key), 1):
            eid = uid('exercise', lv, m, o, ei)
            lex = 'null'
            if ex.get('word'):
                s.append(f"  select id into v_id from public.lexemes where lower(lemma) = lower({q(ex['word'])}) and status = 'PUBLISHED' order by created_at limit 1;")
                lex = 'v_id'
            opts = qj(ex['options']) if ex['options'] is not None else 'null'
            s.append('  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)')
            s.append(f"  values ({q(eid)}, {q(ex['type'])}, {q(ex['question'])}, {q(ex['answer'])}, {opts}, {q(lv)}, {ei}, {q(status)}, {lex}) on conflict (id) do nothing;")
            s.append('  v_pos := v_pos + 1;')
            s.append(f"  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'exercise', {q(eid)}, v_pos, {q(ex['skill'])});")
        for si, (s_ua, s_hr, turns) in enumerate(L['scenes'], 1):
            cid = uid('conversation', lv, m, o, si)
            s.append(f'  -- діалог {si}')
            s.append('  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)')
            s.append(f"  values ({q(cid)}, v_lesson, {q(s_ua)}, {q(s_hr)}, {1000 + n * 10 + si}, {q(lv)}, {q(L['situation'])}, {q(status)}, {q(source)}) on conflict (id) do nothing;")
            for ti, (speaker, hr, ua) in enumerate(turns, 1):
                s.append('  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)')
                s.append(f"  values ({q(uid('turn', lv, m, o, si, ti))}, {q(cid)}, {q(speaker)}, {q(hr)}, {q(ua)}, {ti}) on conflict (id) do nothing;")
        s.append('  -- журнал перевірки')
        s.append('  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)')
        s.append(f"  values ('lesson', v_lesson, null, {q(status)}, 'auto_passed', 'ai', '[]'::jsonb, {q(note)});")
        s.append('end $$;')
        s.append('')
        return s

    def _lesson_sql_compact(self, s: list[str], key, *, status: str, source: str, note: str) -> list[str]:
        L = self.lessons[key]
        p = self.place[key]
        m, o, n = p.module, p.order, p.number
        lv = self.level
        s.append('  -- слова')
        for word in L['words']:
            s.append(f'  v_pos := pg_temp.word(v_lesson, {q(word)}, v_pos);')
        s.append('  -- граматика')
        s.append('  v_pos := v_pos + 1;')
        s.append("  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');")
        s.append('  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;')
        s.append('  -- вправи')
        for ei, ex in enumerate(self.lesson_exercises(key), 1):
            opts = qj(ex['options']) if ex['options'] is not None else 'null'
            lemma = q(ex['word']) if ex.get('word') else 'null'
            s.append(f"  v_pos := pg_temp.ex(v_lesson, v_pos, {q(uid('exercise', lv, m, o, ei))}, {q(ex['type'])}, {q(ex['question'])}, "
                     f"{q(ex['answer'])}, {opts}, {q(lv)}, {ei}, {q(status)}, {lemma}, {q(ex['skill'])});")
        for si, (s_ua, s_hr, turns) in enumerate(L['scenes'], 1):
            cid = uid('conversation', lv, m, o, si)
            s.append(f'  -- діалог {si}')
            s.append('  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)')
            s.append(f"  values ({q(cid)}, v_lesson, {q(s_ua)}, {q(s_hr)}, {1000 + n * 10 + si}, {q(lv)}, {q(L['situation'])}, {q(status)}, {q(source)}) on conflict (id) do nothing;")
            for ti, (speaker, hr, ua) in enumerate(turns, 1):
                s.append(f"  perform pg_temp.turn({q(uid('turn', lv, m, o, si, ti))}, {q(cid)}, {q(speaker)}, {q(hr)}, {q(ua)}, {ti});")
        s.append('  -- журнал перевірки')
        s.append('  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)')
        s.append(f"  values ('lesson', v_lesson, null, {q(status)}, 'auto_passed', 'ai', '[]'::jsonb, {q(note)});")
        s.append('end $$;')
        s.append('')
        return s

    def review_rows(self, keys) -> list[str]:
        rows = []
        for key in keys:
            n = self.place[key].number
            for ex in self.lesson_exercises(key):
                if ex['type'] not in ('multiple_choice', 'type_answer'):
                    continue
                opts = ' · '.join(ex['options']) if ex['options'] else ''
                rows.append(f"| {n} | {ex['type']} | {ex['question']} | {ex['answer']} | {opts} |")
        return rows


def ordered_places(level_lessons: dict, base_order: Callable) -> dict:
    """Ключі уроків → Place з наскрізною нумерацією за (модуль, місце)."""
    items = sorted(level_lessons, key=base_order)
    out = {}
    for n, key in enumerate(items, 1):
        m, o = base_order(key)
        out[key] = Place(m, o, n)
    return out
