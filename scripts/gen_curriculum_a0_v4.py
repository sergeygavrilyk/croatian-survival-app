#!/usr/bin/env python3
"""
Генератор SQL для перебудови уроків A0 за темою (curriculum_a0_v4, 2026-10-15).

  python3 scripts/gen_curriculum_a0_v4.py            →  supabase/data_fixes/20261015_curriculum_a0_v4_m01.sql
  python3 scripts/gen_curriculum_a0_v4.py --review   →  звіт для перевірки (слова, діалоги, вправи на слова)
  python3 scripts/gen_curriculum_a0_v4.py --sync     →  supabase/data_fixes/20261015_curriculum_a0_v4_names.sql
                                                        (оновлення вже опублікованих реплік і прикладів під поточні дані)

Пілот — модуль A0.1 (уроки 1–4). Дані: scripts/curriculum_a0_v4_data.py; переклади наявних слів —
знімок робочої бази (reading_lexicon_snapshot.json + EXTRA_SNAPSHOT у файлі даних).

Що робить SQL для кожного уроку (нічого не видаляє без копії):
  1. знімок старої версії уроку (рядок уроку, усі кроки, id діалогів) — у content_versions;
     копія кроків уроку — у backup.lesson_items_20261015;
  2. старі вправи й діалоги уроку → DEPRECATED (лишаються в базі, у застосунку не видно);
  3. кроки уроку (lesson_items) замінюються новими: 20–25 слів, та сама тема граматики, 15 вправ, 2 нові діалоги;
  4. назва, цілі й тривалість уроку оновлюються; запис у журналі перевірки.
Нові слова — у lexemes (PUBLISHED, бета). SQL ідемпотентний: перебудований урок пропускається.
"""
import json
import re
import sys
from pathlib import Path

sys.dont_write_bytecode = True  # без __pycache__ у репозиторії
sys.path.insert(0, str(Path(__file__).parent))
import curriculum_a0_v4_data as D  # noqa: E402
from full_lessons import Course, Place, q, qj, uid  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
HERE = Path(__file__).parent
OUT = ROOT / 'supabase' / 'data_fixes' / '20261015_curriculum_a0_v4_m01.sql'
SNAP = json.loads((HERE / 'reading_lexicon_snapshot.json').read_text(encoding='utf-8'))['lexemes']
SOURCE = 'claude_curriculum_a0_v4'
LEVEL = 'A0'
MINUTES = 15
STATUS = 'PUBLISHED'  # бета за рішенням власника 2026-10-15
REVIEW_NOTE = 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.'
VERSION_NOTE = 'curriculum_a0_v4: урок перебудовано за темою — стара версія (слова, вправи, діалоги)'
LESSON1_ID = 'c0000000-0000-0000-0000-000000000001'
BACKUP = 'backup.lesson_items_20261015'
SITUATIONS = set(re.findall(r"code: '([a-z_]+)'", (ROOT / 'lib' / 'situations.ts').read_text(encoding='utf-8')))
PREV_NUMBER = {(1, 1): 1, (1, 2): 2, (1, 3): 3, (1, 4): 4}  # наскрізні номери уроків не змінюються


def lesson_id(m: int, o: int) -> str:
    return LESSON1_ID if (m, o) == (1, 1) else uid('lesson', LEVEL, m, o)


def build_course() -> Course:
    lex = {k: (v[0], v[1]) for k, v in SNAP.items()}
    lex.update({k: v for k, v in D.EXTRA_SNAPSHOT.items()})
    for lemma, _n, ua, *_ in D.NEW_LEXEMES:
        lex[lemma.lower()] = (lemma, ua)
    places = {k: Place(k[0], k[1], PREV_NUMBER[k]) for k in D.LESSONS}
    # пастки для «що означає» — і зі старих уроків A0 (слова, яких у нових уроках модуля немає)
    pool = [v[0] for v in SNAP.values() if v[2] == 'A0']
    return Course(level=LEVEL, lessons=D.LESSONS, place=places, lex=lex, situations=SITUATIONS, grammar_keys={None},
                  seed_prefix='a0v4', no_vocab=D.NO_VOCAB, extra_pool=pool, words_range=(20, 25), vocab_counts=(3, 2, 3))


def lexemes_sql() -> list[str]:
    out = ['-- 1. Нові слова й вирази A0 (наявні не змінюються)']
    seen = set()
    for lemma, norm, ua, pos, vtype, forms, example in D.NEW_LEXEMES:
        if lemma.lower() in seen:
            raise SystemExit(f'Дублікат нового слова: {lemma}')
        seen.add(lemma.lower())
        out.append(
            'insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)\n'
            f"values ({q(lemma)}, {q(norm)}, 'hr', {q(pos)}, 'A0', {q(ua)}, {q(vtype)}, {qj(forms)}, {qj([example])}, {q(STATUS)}, {q(SOURCE)})\n"
            'on conflict do nothing;')
    out.append('')
    return out


def lesson_sql(c: Course, key) -> list[str]:
    L = D.LESSONS[key]
    m, o = key
    n = PREV_NUMBER[key]
    lid = lesson_id(m, o)
    t_ua, t_hr = L['title']
    conv_ids = [uid('conversation_v4', LEVEL, m, o, si) for si in (1, 2)]
    s = [f'-- {LEVEL}.{m} · урок {n}: {t_ua} — {len(L["words"])} слів, 2 нові діалоги, {len(c.lesson_exercises(key))} вправ',
         'do $$', 'declare',
         f'  v_lesson constant uuid := {q(lid)};', '  v_id uuid;', '  v_gid uuid;', '  v_pos int := 0;', '  v_payload jsonb;', 'begin',
         f"  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок {n} не знайдено'; end if;",
         f'  if exists (select 1 from public.conversations where id = {q(conv_ids[0])}) then return; end if;  -- уже перебудовано',
         '  -- 1. стара версія: знімок і копія кроків',
         "  select jsonb_build_object('lesson', to_jsonb(l),",
         "         'items', (select coalesce(jsonb_agg(to_jsonb(li) order by li.order_index), '[]'::jsonb) from public.lesson_items li where li.lesson_id = v_lesson),",
         "         'conversations', (select coalesce(jsonb_agg(c.id order by c.order_index), '[]'::jsonb) from public.conversations c where c.lesson_id = v_lesson and c.status = 'PUBLISHED'))",
         '    into v_payload from public.lessons l where l.id = v_lesson;',
         '  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)',
         "  values ('lesson', v_lesson, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = v_lesson), 0) + 1,",
         f'          v_payload, {q(VERSION_NOTE)});',
         f'  insert into {BACKUP} select li.* from public.lesson_items li where li.lesson_id = v_lesson on conflict (id) do nothing;',
         '  -- 2. старі вправи й діалоги — застарілі (не видаляються)',
         "  update public.exercises e set status = 'DEPRECATED'",
         "   where e.status = 'PUBLISHED' and e.id in (select item_id from public.lesson_items where lesson_id = v_lesson and item_type = 'exercise')",
         "     and not exists (select 1 from public.lesson_items x where x.item_id = e.id and x.item_type = 'exercise' and x.lesson_id <> v_lesson);",
         "  update public.conversations set status = 'DEPRECATED' where lesson_id = v_lesson and status = 'PUBLISHED';",
         '  -- 3. новий склад уроку (тема граматики та сама)',
         "  select grammar_topic_id into v_gid from public.lesson_grammar where lesson_id = v_lesson limit 1;",
         "  if v_gid is null then select item_id into v_gid from public.lesson_items where lesson_id = v_lesson and item_type = 'grammar' limit 1; end if;",
         '  delete from public.lesson_items where lesson_id = v_lesson;',
         f"  update public.lessons set title_ua = {q(f'Урок {n}: {t_ua}')}, title_hr = {q(f'Lekcija {n}: {t_hr}')},",
         f"         objectives = {qj(L['objectives'])}, estimated_minutes = {MINUTES} where id = v_lesson;",
         '  -- слова']
    for word in L['words']:
        s.append(f'  v_pos := pg_temp.word(v_lesson, {q(word)}, v_pos);')
    s += ['  -- граматика',
          '  if v_gid is not null then',
          '    v_pos := v_pos + 1;',
          "    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');",
          '  end if;',
          '  -- вправи']
    for ei, ex in enumerate(c.lesson_exercises(key), 1):
        opts = qj(ex['options']) if ex['options'] is not None else 'null'
        lemma = q(ex['word']) if ex.get('word') else 'null'
        s.append(f"  v_pos := pg_temp.ex(v_lesson, v_pos, {q(uid('exercise_v4', LEVEL, m, o, ei))}, {q(ex['type'])}, {q(ex['question'])}, "
                 f"{q(ex['answer'])}, {opts}, {q(LEVEL)}, {ei}, {q(STATUS)}, {lemma}, {q(ex['skill'])});")
    for si, (s_ua, s_hr, turns) in enumerate(L['scenes'], 1):
        cid = conv_ids[si - 1]
        s.append(f'  -- діалог {si}')
        s.append('  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)')
        s.append(f"  values ({q(cid)}, v_lesson, {q(s_ua)}, {q(s_hr)}, {2000 + n * 10 + si}, {q(LEVEL)}, {q(L['situation'])}, {q(STATUS)}, {q(SOURCE)}) on conflict (id) do nothing;")
        for ti, (speaker, hr, ua) in enumerate(turns, 1):
            s.append(f"  perform pg_temp.turn({q(uid('turn_v4', LEVEL, m, o, si, ti))}, {q(cid)}, {q(speaker)}, {q(hr)}, {q(ua)}, {ti});")
    s += ['  -- журнал перевірки',
          '  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)',
          f"  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, {q(REVIEW_NOTE)});",
          'end $$;', '']
    return s


def helpers_sql() -> str:
    from full_lessons import HELPERS_SQL
    return HELPERS_SQL


def build(c: Course) -> str:
    keys = sorted(D.LESSONS)
    words_total = sum(len(D.LESSONS[k]['words']) for k in keys)
    out = [f"""-- =====================================================================
-- Уроки A0 за темою · curriculum_a0_v4 · модуль A0.1 «Pozdrav!» (уроки 1–4) · 2026-10-15
-- Згенеровано: python3 scripts/gen_curriculum_a0_v4.py (не редагуйте вручну).
--
-- Рішення власника 2026-10-15: слова уроку — за темою уроку, 20–25 слів і виразів, діалоги під тему; бета.
--   * Нові слова й вирази: {len(D.NEW_LEXEMES)}. Уроків: {len(keys)}, слів у них: {words_total}.
--   * Стара версія кожного уроку — у content_versions; копія кроків — у {BACKUP};
--     старі вправи й діалоги → DEPRECATED (не видаляються).
--   * Безпечно запускати повторно: перебудований урок пропускається.
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run.
-- =====================================================================

create schema if not exists backup;
create table if not exists {BACKUP} (like public.lesson_items including defaults);
do $$ begin
  if not exists (select 1 from pg_constraint where conname = 'lesson_items_20261015_pkey') then
    alter table {BACKUP} add constraint lesson_items_20261015_pkey primary key (id);
  end if;
end $$;
revoke all on {BACKUP} from anon, authenticated;
""", helpers_sql()]
    out += lexemes_sql()
    out.append('-- 2. Уроки')
    for key in keys:
        out += lesson_sql(c, key)
    ids = ', '.join(q(lesson_id(*k)) for k in keys)
    out.append(f"""-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_bad int;
begin
  select count(*) into v_bad from public.lessons l
   where l.id in ({ids})
     and ((select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'lexeme') not between 20 and 25
          or (select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') <> 2
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED') <> 15);
  if v_bad > 0 then raise exception 'Перебудова не вдалася: % уроків з неправильним складом', v_bad; end if;
  raise notice 'Готово: уроки A0.1 перебудовано (20–25 слів, 2 діалоги, 15 вправ)';
end $$;
""")
    return '\n'.join(out)


def review(c: Course) -> str:
    keys = sorted(D.LESSONS)
    out = ['# Уроки A0 за темою (curriculum_a0_v4) — модуль A0.1, звіт для перевірки', '',
           f'> Згенеровано `scripts/gen_curriculum_a0_v4.py` 2026-10-15. Бета за рішенням власника: слова за темою, 20–25 на урок, діалоги під тему.', '',
           '## Що варто глянути носію', '',
           '1. Чи природні нові діалоги (особливо «Kod susjede», «Na tečaju hrvatskog», «Rođendan»).',
           '2. *zdravo* — у словнику з приміткою «у Хорватії частіше кажуть bok»: чи погоджується носій.',
           '3. *nisam razumio*, *nisam te čuo* — подано в чоловічому роді з жіночою формою в перекладі.',
           '4. *slobodno* у значенні «прошу, можна» (відповідь на «Smijem li…?»).', '',
           '## Нові слова', '', '| Лема | Переклад | Приклад |', '|---|---|---|']
    for lemma, _n, ua, _p, _v, _f, ex in D.NEW_LEXEMES:
        out.append(f'| {lemma} | {ua} | {ex} |')
    for key in keys:
        L = D.LESSONS[key]
        n = PREV_NUMBER[key]
        out += ['', f'## Урок {n}: {L["title"][0]} · {L["title"][1]}', '',
                '**Слова (' + str(len(L['words'])) + '):** ' + ', '.join(f'{c.lemma_of(w)} — {c.display_ua(w)}' for w in L['words']), '']
        for s_ua, s_hr, turns in L['scenes']:
            out.append(f'**Діалог «{s_hr}»** ({s_ua})')
            out.append('')
            for sp, hr, ua in turns:
                out.append(f'- *{sp}:* {hr} — {ua}')
            out.append('')
        out.append('| Тип | Питання | Відповідь | Варіанти |')
        out.append('|---|---|---|---|')
        for ex in c.lesson_exercises(key):
            opts = ' · '.join(ex['options']) if ex['options'] else ''
            out.append(f"| {ex['type']} | {ex['question']} | {ex['answer']} | {opts} |")
    return '\n'.join(out) + '\n'


SYNC_OUT = ROOT / 'supabase' / 'data_fixes' / '20261015_curriculum_a0_v4_names.sql'


def sync_sql() -> str:
    """Оновлення вже опублікованих реплік і прикладів пілоту під поточні дані (імена Даша — 2026-10-15).
    Один DO-блок: оновлює лише те, що відрізняється; стара версія — у content_versions."""
    turns = []
    for key in sorted(D.LESSONS):
        m, o = key
        for si, (_s_ua, _s_hr, tt) in enumerate(D.LESSONS[key]['scenes'], 1):
            for ti, (speaker, hr, ua) in enumerate(tt, 1):
                turns.append({'id': uid('turn_v4', LEVEL, m, o, si, ti), 'speaker': speaker, 'hr': hr, 'ua': ua})
    examples = [{'lemma': lemma, 'example': ex} for lemma, _n, _ua, _p, _v, _f, ex in D.NEW_LEXEMES]
    note = 'curriculum_a0_v4: імена в діалогах (Даша) — стара версія'
    return f"""-- =====================================================================
-- Уроки A0.1 (curriculum_a0_v4): імена в діалогах — частіше Даша (Daša, кличний Dašo) · 2026-10-15
-- Згенеровано: python3 scripts/gen_curriculum_a0_v4.py --sync (не редагуйте вручну).
-- Потрібен уже запущений 20261015_curriculum_a0_v4_m01.sql. Оновлює лише репліки й приклади, що відрізняються;
-- стара версія кожної — у content_versions. Безпечно запускати повторно.
-- =====================================================================
do $$
declare
  r record;
  v_old jsonb;
  v_turns int := 0;
  v_examples int := 0;
begin
  for r in select * from jsonb_to_recordset({qj(turns)}) as x(id uuid, speaker text, hr text, ua text) loop
    select to_jsonb(t) into v_old from public.conversation_turns t
     where t.id = r.id and (t.speaker_name, t.hr_text, t.ua_translation) is distinct from (r.speaker, r.hr, r.ua);
    if v_old is null then continue; end if;
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('conversation_turn', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'conversation_turn' and entity_id = r.id), 0) + 1,
            v_old, {q(note)});
    update public.conversation_turns set speaker_name = r.speaker, hr_text = r.hr, ua_translation = r.ua where id = r.id;
    v_turns := v_turns + 1;
  end loop;
  for r in select * from jsonb_to_recordset({qj(examples)}) as x(lemma text, example text) loop
    select to_jsonb(l) into v_old from public.lexemes l
     where lower(l.lemma) = lower(r.lemma) and l.source = {q(SOURCE)} and l.examples is distinct from jsonb_build_array(r.example);
    if v_old is null then continue; end if;
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', (v_old->>'id')::uuid, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = (v_old->>'id')::uuid), 0) + 1,
            v_old, {q(note)});
    update public.lexemes set examples = jsonb_build_array(r.example) where id = (v_old->>'id')::uuid;
    v_examples := v_examples + 1;
  end loop;
  raise notice 'Готово: оновлено реплік — %, прикладів — %', v_turns, v_examples;
end $$;
"""


def main():
    c = build_course()
    for key in sorted(D.LESSONS):
        c.validate_lesson(key)
        c.lesson_exercises(key)
    # нові слова: діакритика в normalized прибрана, леми без кирилиці, є приклад
    for lemma, norm, ua, pos, vtype, forms, ex in D.NEW_LEXEMES:
        if re.search(r'[čćđšž]', norm) or norm != norm.lower():
            c.errors.append(f'{lemma}: normalized має бути без діакритики й малими літерами')
        if re.search(r'[Ѐ-ӿ]', lemma + ex):
            c.errors.append(f'{lemma}: кирилиця в лемі чи прикладі')
        if not re.search(r'[Ѐ-ӿ]', ua):
            c.errors.append(f'{lemma}: переклад без кирилиці')
        if vtype not in ('core', 'function_word', 'formulaic', 'collocation', 'chunk'):
            c.errors.append(f'{lemma}: невідомий vocabulary_type')
    # слово не повторюється в кількох уроках модуля
    seen: dict = {}
    for key in sorted(D.LESSONS):
        for w in D.LESSONS[key]['words']:
            if w.lower() in seen:
                c.errors.append(f'«{w}» є і в уроці {PREV_NUMBER[seen[w.lower()]]}, і в уроці {PREV_NUMBER[key]}')
            seen[w.lower()] = key
    if c.errors:
        print('Перевірка не пройдена:', *c.errors, sep='\n  ', file=sys.stderr)
        sys.exit(1)
    if '--sync' in sys.argv:
        SYNC_OUT.write_text(sync_sql(), encoding='utf-8')
        print(f'{SYNC_OUT.relative_to(ROOT)}: {SYNC_OUT.stat().st_size // 1024} КБ')
        return
    if '--review' in sys.argv:
        sys.stdout.write(review(c))
        return
    sql = build(c)
    OUT.write_text(sql, encoding='utf-8')
    print(f'{OUT.relative_to(ROOT)}: {len(sql.encode()) // 1024} КБ')


if __name__ == '__main__':
    main()
