#!/usr/bin/env python3
"""
Генератор SQL для перебудови уроків A0 за темою (curriculum_a0_v4, 2026-10-15).

  python3 scripts/gen_curriculum_a0_v4.py              →  SQL усіх модулів: supabase/data_fixes/20261015_curriculum_a0_v4_m01.sql,
                                                          20261019_curriculum_a0_v4_m02.sql
  python3 scripts/gen_curriculum_a0_v4.py --review 2   →  звіт для перевірки модуля (слова, діалоги, вправи)
  python3 scripts/gen_curriculum_a0_v4.py --sync       →  supabase/data_fixes/20261015_curriculum_a0_v4_names.sql
                                                          (оновлення вже опублікованих реплік і прикладів пілоту A0.1)

Модулі: A0.1 (пілот, уроки 1–4), A0.2 (уроки 5–13: 5 перебудованих + 4 нові), A0.3 (уроки 14–23), A0.4 (уроки 24–30: 5 + 2 нові),
A0.5 (уроки 31–37: 4 + 3 нові), A0.6 (уроки 38–43: 4 + 2 нові), A0.7 (уроки 44–48: 5 перебудованих),
A0.8 (уроки 49–54: 5 + 1 новий), A0.9 (уроки 55–59: 5 перебудованих), A0.10 (уроки 60–66: 5 + 2 нові). Дані: scripts/curriculum_a0_v4_data.py;
переклади наявних слів — знімок робочої бази scripts/curriculum_a0_v4_snapshot.json (base — для пасток пілоту, не змінювати;
extra — модуль A0.2) + EXTRA_SNAPSHOT у файлі даних.
Модуль A0.2 ще й: створює нові уроки, змінює порядок уроків у модулі, перенумеровує назви всіх уроків A0 («Урок N»).

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
SNAPSHOT = json.loads((HERE / 'curriculum_a0_v4_snapshot.json').read_text(encoding='utf-8'))
SNAP = SNAPSHOT['base']  # копія reading_lexicon_snapshot.json на 2026-10-15: від неї залежать пастки вправ пілоту
SOURCE = 'claude_curriculum_a0_v4'
LEVEL = 'A0'
MINUTES = 15
STATUS = 'PUBLISHED'  # бета за рішенням власника 2026-10-15
REVIEW_NOTE = 'Бета: урок перебудовано за темою (20–25 слів, нові діалоги) за рішенням власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.'
VERSION_NOTE = 'curriculum_a0_v4: урок перебудовано за темою — стара версія (слова, вправи, діалоги)'
LESSON1_ID = 'c0000000-0000-0000-0000-000000000001'
BACKUP = 'backup.lesson_items_20261015'
SITUATIONS = set(re.findall(r"code: '([a-z_]+)'", (ROOT / 'lib' / 'situations.ts').read_text(encoding='utf-8')))
PREV_NUMBER = {(1, 1): 1, (1, 2): 2, (1, 3): 3, (1, 4): 4}  # наскрізні номери уроків A0.1 не змінюються
# Модуль A0.2: 9 уроків (5 перебудованих + 4 нові) → номери 5–13; далі всі уроки A0 зсуваються на +4 (47 → 51)
NUMBER = {**PREV_NUMBER, **{(2, o): 4 + o for o in range(1, 10)}, **{(3, o): 13 + o for o in range(1, 11)},
          **{(4, o): 23 + o for o in range(1, 8)}, **{(5, o): 30 + o for o in range(1, 8)},
          **{(6, o): 37 + o for o in range(1, 7)}, **{(7, o): 43 + o for o in range(1, 6)},
          **{(8, o): 48 + o for o in range(1, 7)}, **{(9, o): 54 + o for o in range(1, 6)},
          **{(10, o): 59 + o for o in range(1, 8)}}
A0_TOTAL = {1: 47, 2: 51, 3: 56, 4: 58, 5: 61, 6: 63, 7: 63, 8: 64, 9: 64, 10: 66}  # скільки уроків A0 після модуля
MODULES = {
    1: dict(lessons=D.LESSONS, new_lexemes=D.NEW_LEXEMES, no_vocab=D.NO_VOCAB,
            out=ROOT / 'supabase' / 'data_fixes' / '20261015_curriculum_a0_v4_m01.sql'),
    2: dict(lessons=D.LESSONS_M02, new_lexemes=D.NEW_LEXEMES_M02, no_vocab=D.NO_VOCAB_M02,
            out=ROOT / 'supabase' / 'data_fixes' / '20261019_curriculum_a0_v4_m02.sql'),
    # A0.3 «Brojevi»: 10 уроків, слів — скільки потрібно темі (рішення власника 2026-10-19), дві нові теми граматики
    3: dict(lessons=D.LESSONS_M03, new_lexemes=D.NEW_LEXEMES_M03, no_vocab=D.NO_VOCAB_M03, new_grammar=D.NEW_GRAMMAR_M03,
            words=D.WORDS_RANGE_M03, out=ROOT / 'supabase' / 'data_fixes' / '20261019_curriculum_a0_v4_m03.sql'),
    # A0.4 «Vrijeme»: 5 перебудованих + 2 нові уроки (погода; свята й привітання), нова тема граматики «Погода»
    4: dict(lessons=D.LESSONS_M04, new_lexemes=D.NEW_LEXEMES_M04, no_vocab=D.NO_VOCAB_M04, new_grammar=D.NEW_GRAMMAR_M04,
            out=ROOT / 'supabase' / 'data_fixes' / '20261019_curriculum_a0_v4_m04.sql'),
    # A0.5 «Obitelj»: 4 перебудовані + 3 нові уроки (присвійні займенники; зовнішність і характер; домашні тварини),
    # нова тема граматики «Присвійні займенники»
    5: dict(lessons=D.LESSONS_M05, new_lexemes=D.NEW_LEXEMES_M05, no_vocab=D.NO_VOCAB_M05, new_grammar=D.NEW_GRAMMAR_M05,
            out=ROOT / 'supabase' / 'data_fixes' / '20261019_curriculum_a0_v4_m05.sql'),
    # A0.6 «Moj dom»: 4 перебудовані + 2 нові уроки (прийменники місця; прикметники-протилежності)
    6: dict(lessons=D.LESSONS_M06, new_lexemes=D.NEW_LEXEMES_M06, no_vocab=D.NO_VOCAB_M06,
            out=ROOT / 'supabase' / 'data_fixes' / '20261019_curriculum_a0_v4_m06.sql'),
    # A0.7 «Hrana»: 5 перебудованих уроків; виправлено переклад ljut («гострий» — про їжу)
    7: dict(lessons=D.LESSONS_M07, new_lexemes=D.NEW_LEXEMES_M07, no_vocab=D.NO_VOCAB_M07, fix_translations=D.FIX_TRANSLATIONS_M07,
            out=ROOT / 'supabase' / 'data_fixes' / '20261019_curriculum_a0_v4_m07.sql'),
    # A0.8 «Kupovina»: 5 перебудованих + 1 новий урок (узгодження ціни), нова тема граматики «Порівняння»
    8: dict(lessons=D.LESSONS_M08, new_lexemes=D.NEW_LEXEMES_M08, no_vocab=D.NO_VOCAB_M08, new_grammar=D.NEW_GRAMMAR_M08,
            out=ROOT / 'supabase' / 'data_fixes' / '20261019_curriculum_a0_v4_m08.sql'),
    # A0.9 «Grad»: 5 перебудованих уроків; «Як пройти?» — урок «показати дорогу» з плану
    9: dict(lessons=D.LESSONS_M09, new_lexemes=D.NEW_LEXEMES_M09, no_vocab=D.NO_VOCAB_M09,
            out=ROOT / 'supabase' / 'data_fixes' / '20261019_curriculum_a0_v4_m09.sql'),
    # A0.10 «Survival»: 5 перебудованих + 2 нові уроки (частини тіла; «Допоможіть!» — фрази для надзвичайних ситуацій),
    # урок 1 — «У готелі»; нова тема граматики «Що болить?»; виправлено переклад nesreća («аварія, нещасний випадок»)
    10: dict(lessons=D.LESSONS_M10, new_lexemes=D.NEW_LEXEMES_M10, no_vocab=D.NO_VOCAB_M10, new_grammar=D.NEW_GRAMMAR_M10,
             fix_translations=D.FIX_TRANSLATIONS_M10,
             out=ROOT / 'supabase' / 'data_fixes' / '20261020_curriculum_a0_v4_m10.sql'),
}
WORDS_DEFAULT = (20, 25)
GRAMMAR_TITLES = {L['grammar'] for M in MODULES.values() for L in M['lessons'].values()}
NEW_GRAMMAR_TITLES = {g['title_ua'] for M in MODULES.values() for g in M.get('new_grammar', {}).values()}


def lesson_id(m: int, o: int) -> str:
    if (m, o) == (1, 1):
        return LESSON1_ID
    if m == 1:
        return uid('lesson', LEVEL, m, o)
    L = MODULES[m]['lessons'][(m, o)]
    # наявний урок — id за місцем, з яким його створено; новий — за slug (не залежить від порядку)
    return uid('lesson', LEVEL, m, L['old']) if 'old' in L else uid('lesson_v4', LEVEL, m, L['slug'])


def build_course(module: int = 1) -> Course:
    """Окремий Course на модуль: пастки й неоднозначність рахуються як у пілоті (вихід A0.1 не змінюється)."""
    M = MODULES[module]
    lex = {k: (v[0], v[1]) for k, v in SNAP.items()}
    lex.update({k: v for k, v in D.EXTRA_SNAPSHOT.items()})
    if module > 1:
        lex.update({k: tuple(v) for k, v in SNAPSHOT['extra'].items()})
        for m in range(1, module):
            for lemma, _n, ua, *_ in MODULES[m]['new_lexemes']:
                lex[lemma.lower()] = (lemma, ua)
    for lemma, _n, ua, *_ in M['new_lexemes']:
        lex[lemma.lower()] = (lemma, ua)
    places = {k: Place(k[0], k[1], NUMBER[k]) for k in M['lessons']}
    # пастки для «що означає» — і зі старих уроків A0 (слова, яких у нових уроках модуля немає)
    pool = [v[0] for v in SNAP.values() if v[2] == 'A0']
    if module > 1:  # слова вже перебудованих модулів
        pool += [w for m in range(1, module) for L in MODULES[m]['lessons'].values() for w in L['words']]
    return Course(level=LEVEL, lessons=M['lessons'], place=places, lex=lex, situations=SITUATIONS,
                  grammar_keys={None} if module == 1 else GRAMMAR_TITLES,
                  seed_prefix='a0v4', no_vocab=M['no_vocab'], extra_pool=pool, words_range=M.get('words', WORDS_DEFAULT),
                  vocab_counts=(3, 2, 3))


def lexemes_sql(new_lexemes=None) -> list[str]:
    out = ['-- 1. Нові слова й вирази A0 (наявні не змінюються)']
    seen = set()
    for lemma, norm, ua, pos, vtype, forms, example in (D.NEW_LEXEMES if new_lexemes is None else new_lexemes):
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
    """Перебудова наявного уроку (стара версія — у content_versions і backup)."""
    L = c.lessons[key]
    m, o = key
    n = NUMBER[key]
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


REVIEW_NOTES = {
    1: ['1. Чи природні нові діалоги (особливо «Kod susjede», «Na tečaju hrvatskog», «Rođendan»).',
        '2. *zdravo* — у словнику з приміткою «у Хорватії частіше кажуть bok»: чи погоджується носій.',
        '3. *nisam razumio*, *nisam te čuo* — подано в чоловічому роді з жіночою формою в перекладі.',
        '4. *slobodno* у значенні «прошу, можна» (відповідь на «Smijem li…?»).'],
    2: ['1. Чи природні нові діалоги, особливо «U banci», «Na poslu», «Razgovor sa susjedom», «Tečaj za strance», «Kod liječnice».',
        '2. Назви міст: *Harkiv* (з Харкова — *iz Harkiva*), *Lviv*, *Odesa* (*iz Odese*), *Kijev* (*u Kijevu*) — чи так пишуть у Хорватії (можливо, *Lavov*).',
        '3. *gospođica* — чи доречно сьогодні (переклад «панна»).',
        '4. *prizemlje* — «партер; нижній поверх (в Україні — перший)»; *kat* у Хорватії рахують від партеру — у діалозі «Na trećem katu» перекладено дослівно.',
        '5. *Darja, Ukrajinka sam.*, *Materinski jezik mi je ukrajinski.*, *Izgledaš tužno.*, *Bit će ti bolje.* — чи звучить природно.',
        '6. *Učim ga svaki dan* (ga = hrvatski) — чи природно в розмові.',
        '7. Переклади наявних слів, що трапляються у вправах: *ljut* «злий / сердитий» (в A0.7 буде «гострий» про їжу), *čovjek* «людина, чоловік», *prije* «перед, раніше».'],
    3: ['1. Нові теми граматики «Великі числа: сотні, тисячі, мільйони» і «Порядкові числівники» — правила й приклади (особливо *tisuću eura*, *devedeset drugo* (godište), *jednako je*).',
        '2. Читання чисел: *Nula devet osam, pedeset tri, sedamdeset dva…* (номер телефону парами), *Koliko je kilometara od Zagreba do Splita? — Otprilike četiristo.*',
        '3. *šesto* — «шістсот» (збігається з *šesto* «шосте»): чи не варто давати *šeststo*.',
        '4. Арифметика: *Sto minus pedeset šest je četrdeset četiri?*, *Šezdeset podijeljeno s tri je dvadeset.*, *Tri puta četiri je dvanaest.* — чи так кажуть у школі.',
        '5. *Nas je dvanaest*, *Nas je troje*, *Koje ste godište? — Devedeset drugo.*, *Koliki je popust?*, *Evo četiri eura ostatka.* — чи природно.',
        '6. Факти в діалогах: Хорватія — «malo manje od četiri milijuna», Загреб — «gotovo osamsto tisuća», Київ — «gotovo tri milijuna», Загреб — Спліт ≈ 400 км, Загреб — Дубровник ≈ 600 км.',
        '7. *par* «пара; кілька», *posto* «відсоток» як окремі слова словника; *dvije* окремо від *dva*.'],
    4: ['1. Нова тема граматики «Погода: безособові речення» — правила й приклади (*Pada kiša*, *Puše bura*, *Bit će kiše*, *Sutra će puhati jugo*).',
        '2. Час: *u deset i petnaest*, *u jedan i pol* (13:30), *četvrt sata*, *sat vremena*, *Ima li kašnjenja?* — чи так кажуть на вокзалі.',
        '3. Дати: *Danas je dvadeseti listopada*, *Vrijedi do četvrtog ožujka sljedeće godine*, *Rođena sam petog svibnja*, *početkom veljače*.',
        '4. Діалог «Boravišna dozvola» — загальний приклад; чи природне *Dozvolu morate produžiti prije nego što istekne*.',
        '5. Свята: *Na Badnjak … jedemo bakalar*, *Kitimo bor*, *gdje dočekuješ Novu godinu*, *Prvi siječnja je neradni dan*, *Sretni blagdani!*.',
        '6. Звертання: *Ivana, što radite za Božić?* (кличний *Ivana* чи *Ivano*), *Mia, budilica zvoni!*.',
        '7. Переклади наявних слів у словнику (не змінювалися): *toplo* — «тепле» (у погоді — «тепло»), *temperatura* не взято (у базі — «жар»), '
        '*vrijedi do* — «діє до», *čestitati* — «вітати», *sretan božić* / *sretna nova godina* — леми з малої літери.'],
    5: ['1. Нова тема граматики «Присвійні займенники» — правила й приклади (особливо *svoj* і *Marko voli njegovu ženu* — «дружину іншого чоловіка»).',
        '2. Споріднення: *stric* / *ujak* / *tetak*, *strina* / *ujna*, *šogor* / *šogorica* (переклад «шурин, дівер; чоловік сестри» — '
        'чи не спростити), *kum* / *kuma* — «хрещений; свідок на весіллі».',
        '3. *jedinac* / *jedinica* (*jedinica* — ще й оцінка «одиниця»), *blizanci*, *braća* (збірне: *Moja braća žive…*).',
        '4. *oženiti se* (про чоловіка), *udati se* (про жінку), *vjenčati se* (про пару); *samac* — «неодружений чоловік; холостяк».',
        '5. Діалоги: *Kako ste slični!*, *Imaju četiri unuka i dvije unuke*, *To je Markov* (про парасольку), *Možda pripada gospođi Kovač?*, '
        '*Uvijek donese poklone unucima*, *Tko je sretnik?*, *evo njegove knjižice cijepljenja*.',
        '6. *kod mene* / *kod nas* як окремі вирази словника; *zec* — «кролик; заєць» (домашній кролик — *zec* чи *kunić*?).',
        '7. Переклади наявних слів у словнику (не змінювалися): *oko* — «око» (у діалогах *oči*), *plav* — «синій / блакитний» '
        '(*plava kosa* — світле волосся), *smeđ* — «коричневий» (*smeđa kosa* — каштанове), *vrijedan* — «цінний, працьовитий», '
        '*dlaka* — «шерсть», *cijepiti* — «вакцинувати», *roditelji* — «батьки».'],
    6: ['1. Оренда: *dvosoban stan*, *garsonijera*, *kvadrat* (розмовно «м²»), *kaucija*, *unajmiti* / *iznajmiti* '
        '(у словнику *iznajmiti* — «орендувати / здати в оренду»), *Najamnina je petsto eura, a režije posebno*.',
        '2. Прийменники: *uz zid* (переклад «під стіну»), *u kutu*, *na vrhu*, *na dnu*, *na sredini*; *Kamo stavljamo ormar?*; '
        '*Na prvom katu* — «на першому поверсі над партером».',
        '3. Техніка: *perilica* (у словнику — «пральна машина»), *mikrovalna*, *glačalo*, *bojler*, *topla voda* — «гаряча вода»; '
        '*Ne pali se*, *Troši malo struje*.',
        '4. Прикметники: *mali* (у словнику замість *malen*), *svijetao* / *taman*, *čvrst*, *prostran*, *pretežak*.',
        '5. Звертання: *gospodine Horvat*, *Gospođo*, *Danilo* (кличний), *Mia*.',
        '6. *ravno* і *preko puta* лишили для уроку «Показати дорогу» (A0.9); *voda* — для модуля «Hrana».'],
}
REVIEW_NOTES[7] = [
    '1. *ljut* у словнику тепер «злий, сердитий; гострий (про їжу)» (раніше лише «злий / сердитий»). В уроці смаку — нове *pikantan*; '
    'у діалозі й вправах — *Pazi, ljut je!*, *Umak je jako ljut.*, *Je li ovo ljuto?* Чи природно.',
    '2. Кафе: *bijela kava* («кава з молоком»), *kroasan* (написання), *šlag*, *kuglica*, *za van*, *Odmah stiže.*',
    '3. Напої: *gemišt* — біле вино з газованою мінеральною водою, *bevanda* — вино зі звичайною водою (Далмація); *gazirani sok*. '
    'Чи точні пояснення.',
    '4. Ресторан: *častiti* («Danas ja častim!»), *Plaćate li zajedno ili odvojeno?*, *Ostatak je za vas.*, *Što nam preporučujete?*',
    '5. Страви: *škampi* («скампі, креветки»), *pržen* (на пательні) / *pečen* (у духовці), *Kakva je govedina?*, '
    '*Tri obroka dnevno su važna.*, *jutros su ulovljene*.',
    '6. *voda* (залишена з A0.6) — в уроці «Напої»; фрукти, овочі й кількості — у модулі A0.8.',
]
REVIEW_NOTES[8] = [
    '1. Новий урок «Može li jeftinije?» (узгодження ціни): *cjenkati se*, *buvljak*, *spustiti cijenu*, *zadnja cijena*, *dogovoreno*, '
    '*Dajem vam dvadeset, u gotovini.*, *Isplati vam se!*, *Je li bicikl još na prodaju?*',
    '2. Нова тема граматики «Дешевше чи дорожче? Порівняння» (4 правила): *skup → skuplji*, *drag → draži*, *tih → tiši*, '
    '*nego* / *od* + родовий, *naj-*. Перевірити правила й приклади.',
    '3. Кольори: *tamnoplav*, *svijetloplav* («блакитний»), *bež* (не змінюється), *zlatan*, *srebrn*, *na pruge*, *na točkice*. '
    '*plav* і *smeđ* уже вивчено в A0.5 («Зовнішність»), тому тут їх немає серед слів.',
    '4. Кількості: *Dvadeset deka šunke, molim. Možete li je narezati?*, *pola kile*, *staklenka*, *limenka*, *Ovu ili onu?*',
    '5. Каса: *Prislonite karticu ovdje.*, *beskontaktno*, *samoposlužna blagajna*, *Radije bih je zamijenila za manju veličinu.*',
    '6. Ринок і одяг: *Jesu li domaće?*, *kilu jabuka*, *dvije mrkve, jedan luk*, *Trideset osam.* (розмір), *premalen* / *prevelik*.',
]
REVIEW_NOTES[9] = [
    '1. «Як пройти?» — тепер це урок «Показати дорогу» з плану: *Idite ravno do kraja ulice, pa skrenite lijevo.*, '
    '*kolodvor je tamo, odmah preko puta mosta*, *Ovdje na semaforu prijeđite cestu.*, *Nastavite ravno do raskrižja*, *odmah iza ugla*, *Ne možete ga promašiti.* Чи природно.',
    '2. Нові вирази: *kako doći do*, *koliko je daleko*, *do kraja ulice*, *nedaleko*, *u blizini*, *najbliži*, *karta grada*, '
    '*stari grad*, *obilazak* («екскурсія»), *mjesečna karta* («місячний проїзний»), *presjesti*, *kontrolor*.',
    '3. Транспорт: *Šestica, ali moraš presjesti na trgu.*, *Na kiosku ili kod vozača. Uđi na prednja vrata.*, '
    '*Bez karte se plaća kazna.*, *s petog perona*, *U jednom smjeru ili povratnu?*',
    '4. Місто й пам’ятки: *Ima li ovdje negdje teretana?*, *ići na bazen*, *Kod zidina su suveniri skupi.*, *bez bljeskalice*, '
    '*S vidikovca se vidi cijeli grad.*; переклад *pogled* у словнику — «вид (з вікна)», *općina* — «муніципалітет, громада».',
    '5. Таксі й авто: *Vežite pojas, molim.*, *Ima li gužve u ovo doba?*, *Moram zamijeniti vozačku dozvolu.*, '
    '*Gdje se ovdje može parkirati?*, *Na autocesti se plaća cestarina.*',
    '6. *policija*, *ljekarna*, *hotel*, *izgubiti se* лишили для модуля A0.10 «Survival»; *lijevo*, *desno*, *daleko*, '
    '*ulica*, *vozni red*, *polazak*, *dolazak* уже вивчено в A0.2–A0.6.',
]
REVIEW_NOTES[10] = [
    '1. Нова тема граматики «Що болить? Boli me…, bole me…» (3 правила): *Dašu boli koljeno*, *Bole me leđa / prsa* (лише множина), '
    '*Što vas boli?*, *Više me ne boli.* Перевірити правила й приклади; вправа *Bole me ___.* → *leđa*.',
    '2. Новий урок «Допоможіть!»: *Centar 112, izvolite. Što se dogodilo?*, *Dogodila se prometna nesreća!*, *U Ilici, kod broja deset.*, '
    '*Hitna pomoć stiže za pet minuta. Smirite se i ostanite s njim.*, *mobitel mi se ugasio*, *Ovdje gori kuća!*, *Brzo zovite vatrogasce!*',
    '3. Переклади: *nesreća* тепер «нещастя; аварія, нещасний випадок»; *prijava* — «реєстрація; заява (в поліцію, установу)» '
    '(було «… / донос»). Нові слова: *odsjesti*, *prenoćiti*, *džeparoš*, *zapisnik*, *provala* («квартирна крадіжка, злам»), '
    '*rubrika* («графа»), *tiskanim slovima*, *ovjeriti*, *obvezno* (не *obavezno*), *e-pošta*, *privremeni boravak*, *uplatiti*.',
    '4. Лікар і аптека: *Što vas muči?*, *otvorit ću vam bolovanje*, *Uzimajte ga tri puta dnevno nakon jela.*, *nešto protiv bolova*, '
    '*Želim se naručiti kod liječnika.*, *Hvala, doktorice.*',
    '5. Готель і установи: *Do kada je odjava?*, *Piše na kartici pored kreveta.*, *s ulice se čuje velika buka*, '
    '*Kopiju, ali mora biti ovjerena.*, *Kod javnog bilježnika.*, *Nedostaje vam potvrda o smještaju.*, *Uzmite broj i čekajte u čekaonici.*',
    '6. Поліція: *Što vam je ukradeno?*, *Bila je gužva i odjednom je novčanik nestao.*, *s crnom kapom*, *U tramvaju ima kamera.* '
    '*izgubiti*, *naći*, *novčanik* уже вивчено в уроці 41; *ime*, *prezime*, *adresa*, *datum rođenja*, *boravišna dozvola* — в A0.2 / A0.4.',
]
REVIEW_DATE = {1: '2026-10-15', 2: '2026-10-19', 3: '2026-10-19', 4: '2026-10-19', 5: '2026-10-19', 6: '2026-10-19', 7: '2026-10-19', 8: '2026-10-19', 9: '2026-10-19', 10: '2026-10-20'}


def review(c: Course, module: int = 1) -> str:
    M = MODULES[module]
    keys = sorted(M['lessons'])
    out = [f'# Уроки A0 за темою (curriculum_a0_v4) — модуль A0.{module}, звіт для перевірки', '',
           f'> Згенеровано `scripts/gen_curriculum_a0_v4.py` {REVIEW_DATE[module]}. Бета за рішенням власника: слова за темою, 20–25 на урок, діалоги під тему.', '']
    if module > 1:
        out += [f'Порядок уроків модуля: ' + ' → '.join(f'{NUMBER[k]} «{M["lessons"][k]["title"][0]}»' + ('' if 'old' in M['lessons'][k] else ' (новий)')
                                                    for k in keys) + '.', '']
    out += ['## Що варто глянути носію', '', *REVIEW_NOTES[module], '',
            '## Нові слова', '', '| Лема | Переклад | Приклад |', '|---|---|---|']
    for lemma, _n, ua, _p, _v, _f, ex in M['new_lexemes']:
        out.append(f'| {lemma} | {ua} | {ex} |')
    for key in keys:
        L = M['lessons'][key]
        n = NUMBER[key]
        out += ['', f'## Урок {n}: {L["title"][0]} · {L["title"][1]}' + ('' if module == 1 or 'old' in L else ' (новий урок)'), '',
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


# ----------------------------------------------------------------------------- модуль A0.2 і далі
def unit_lookup(m: int) -> str:
    return ('select u.id into v_unit from public.units u join public.modules m on m.id = u.module_id\n'
            f"   where m.level_code = {q(LEVEL)} and m.order_index = {m} and u.order_index = 1;")


def content_sql(c: Course, key, s: list[str]):
    """Слова, граматика, вправи, діалоги уроку (спільне для перебудованого й нового уроку)."""
    L = c.lessons[key]
    m, o = key
    n = NUMBER[key]
    s.append('  -- слова')
    for word in L['words']:
        s.append(f'  v_pos := pg_temp.word(v_lesson, {q(word)}, v_pos);')
    s += ['  -- граматика',
          '  if v_gid is not null then',
          '    v_pos := v_pos + 1;',
          "    insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');",
          '    insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;',
          '  end if;',
          '  -- вправи']
    for ei, ex in enumerate(c.lesson_exercises(key), 1):
        opts = qj(ex['options']) if ex['options'] is not None else 'null'
        lemma = q(ex['word']) if ex.get('word') else 'null'
        s.append(f"  v_pos := pg_temp.ex(v_lesson, v_pos, {q(uid('exercise_v4', LEVEL, m, o, ei))}, {q(ex['type'])}, {q(ex['question'])}, "
                 f"{q(ex['answer'])}, {opts}, {q(LEVEL)}, {ei}, {q(STATUS)}, {lemma}, {q(ex['skill'])});")
    for si, (s_ua, s_hr, turns) in enumerate(L['scenes'], 1):
        cid = uid('conversation_v4', LEVEL, m, o, si)
        s.append(f'  -- діалог {si}')
        s.append('  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)')
        s.append(f"  values ({q(cid)}, v_lesson, {q(s_ua)}, {q(s_hr)}, {2000 + n * 10 + si}, {q(LEVEL)}, {q(L['situation'])}, {q(STATUS)}, {q(SOURCE)}) on conflict (id) do nothing;")
        for ti, (speaker, hr, ua) in enumerate(turns, 1):
            s.append(f"  perform pg_temp.turn({q(uid('turn_v4', LEVEL, m, o, si, ti))}, {q(cid)}, {q(speaker)}, {q(hr)}, {q(ua)}, {ti});")


def rebuild_sql(c: Course, key) -> list[str]:
    """Перебудова наявного уроку: стара версія — у content_versions і backup; старі вправи й діалоги — DEPRECATED."""
    L = c.lessons[key]
    m, o = key
    n = NUMBER[key]
    lid = lesson_id(m, o)
    t_ua, t_hr = L['title']
    first_conv = uid('conversation_v4', LEVEL, m, o, 1)
    s = [f'-- {LEVEL}.{m} · урок {n}: {t_ua} — перебудова: {len(L["words"])} слів, 2 нові діалоги, {len(c.lesson_exercises(key))} вправ',
         'do $$', 'declare',
         f'  v_lesson constant uuid := {q(lid)};', '  v_gid uuid;', '  v_pos int := 0;', '  v_payload jsonb;', 'begin',
         f"  if not exists (select 1 from public.lessons where id = v_lesson) then raise exception 'Урок «{t_ua}» не знайдено'; end if;",
         f'  if exists (select 1 from public.conversations where id = {q(first_conv)}) then return; end if;  -- уже перебудовано',
         '  -- стара версія: знімок і копія кроків',
         "  select jsonb_build_object('lesson', to_jsonb(l),",
         "         'items', (select coalesce(jsonb_agg(to_jsonb(li) order by li.order_index), '[]'::jsonb) from public.lesson_items li where li.lesson_id = v_lesson),",
         "         'conversations', (select coalesce(jsonb_agg(c.id order by c.order_index), '[]'::jsonb) from public.conversations c where c.lesson_id = v_lesson and c.status = 'PUBLISHED'))",
         '    into v_payload from public.lessons l where l.id = v_lesson;',
         '  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)',
         "  values ('lesson', v_lesson, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = v_lesson), 0) + 1,",
         f'          v_payload, {q(VERSION_NOTE)});',
         f'  insert into {BACKUP} select li.* from public.lesson_items li where li.lesson_id = v_lesson on conflict (id) do nothing;',
         '  -- старі вправи й діалоги — застарілі (не видаляються)',
         "  update public.exercises e set status = 'DEPRECATED'",
         "   where e.status = 'PUBLISHED' and e.id in (select item_id from public.lesson_items where lesson_id = v_lesson and item_type = 'exercise')",
         "     and not exists (select 1 from public.lesson_items x where x.item_id = e.id and x.item_type = 'exercise' and x.lesson_id <> v_lesson);",
         "  update public.conversations set status = 'DEPRECATED' where lesson_id = v_lesson and status = 'PUBLISHED';",
         '  -- новий склад уроку (тема граматики та сама)',
         "  select grammar_topic_id into v_gid from public.lesson_grammar where lesson_id = v_lesson limit 1;",
         "  if v_gid is null then select item_id into v_gid from public.lesson_items where lesson_id = v_lesson and item_type = 'grammar' limit 1; end if;"]
    if L.get('grammar'):  # у наявного уроку теми граматики не було — додаємо з даних
        s.append(f"  if v_gid is null then select id into v_gid from public.grammar_topics where cefr = {q(LEVEL)} and title_ua = {q(L['grammar'])} "
                 "and status = 'PUBLISHED' order by created_at limit 1; end if;")
    s += ['  delete from public.lesson_items where lesson_id = v_lesson;',
          f"  update public.lessons set title_ua = {q(f'Урок {n}: {t_ua}')}, title_hr = {q(f'Lekcija {n}: {t_hr}')},",
          f"         objectives = {qj(L['objectives'])}, estimated_minutes = {MINUTES} where id = v_lesson;"]
    content_sql(c, key, s)
    s += ['  -- журнал перевірки',
          '  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)',
          f"  values ('lesson', v_lesson, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, {q(REVIEW_NOTE)});",
          'end $$;', '']
    return s


NEW_NOTE = 'Бета: новий тематичний урок (20–25 слів, 2 діалоги, 15 вправ) за списком власника 2026-10-15 (curriculum_a0_v4). Потрібна перевірка носієм.'


def create_sql(c: Course, key) -> list[str]:
    """Новий тематичний урок у своєму модулі (місце в юніті — з даних)."""
    L = c.lessons[key]
    m, o = key
    n = NUMBER[key]
    lid = lesson_id(m, o)
    t_ua, t_hr = L['title']
    s = [f'-- {LEVEL}.{m} · урок {n}: {t_ua} — новий урок: {len(L["words"])} слів, 2 діалоги, {len(c.lesson_exercises(key))} вправ',
         'do $$', 'declare',
         '  v_unit uuid;', f'  v_lesson constant uuid := {q(lid)};', '  v_gid uuid;', '  v_pos int := 0;', 'begin',
         f'  {unit_lookup(m)}',
         f"  if v_unit is null then raise exception 'Немає юніта для модуля {LEVEL}.{m}'; end if;",
         '  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено',
         f'  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = {o}) then',
         f"    raise exception '{LEVEL}.{m}: місце {o} зайняте іншим уроком';",
         '  end if;',
         f"  select id into v_gid from public.grammar_topics where cefr = {q(LEVEL)} and title_ua = {q(L['grammar'])} and status = 'PUBLISHED' order by created_at limit 1;",
         f"  if v_gid is null then raise exception 'Немає теми граматики «{L['grammar']}»'; end if;",
         '  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)',
         f"  values (v_lesson, v_unit, {q(LEVEL)}, {q(f'Урок {n}: {t_ua}')}, {q(f'Lekcija {n}: {t_hr}')}, {qj(L['objectives'])}, {MINUTES}, {q(STATUS)}, {o});"]
    content_sql(c, key, s)
    s += ['  -- журнал перевірки',
          '  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)',
          f"  values ('lesson', v_lesson, null, {q(STATUS)}, 'auto_passed', 'ai', '[]'::jsonb, {q(NEW_NOTE)});",
          'end $$;', '']
    return s


def order_sql(module: int, keys, final: bool) -> str:
    """Новий порядок наявних уроків модуля. Спершу — тимчасово +100 (звільнити місця для нових уроків), у кінці — -100."""
    if final:
        return f"""-- 5. Наявні уроки модуля A0.{module} — на нові місця
do $$
declare v_unit uuid;
begin
  {unit_lookup(module)}
  update public.lessons set order_index = order_index - 100 where unit_id = v_unit and order_index > 100;
end $$;
"""
    rows = ',\n    '.join(f"({q(lesson_id(*k))}::uuid, {k[1]})" for k in keys if 'old' in MODULES[module]['lessons'][k])
    return f"""-- 3. Новий порядок уроків у модулі A0.{module}: наявні уроки тимчасово переносяться на місця 100+
--    (unique (unit_id, order_index)), щоб звільнити місця для нових; у кроці 5 — на остаточні місця
do $$
declare v_unit uuid;
begin
  {unit_lookup(module)}
  update public.lessons l set order_index = t.o + 100
    from (values
    {rows}
    ) as t(id, o)
   where l.id = t.id and l.unit_id = v_unit and l.order_index <> t.o and l.order_index < 100;
end $$;
"""


RENUMBER_SQL = f"""-- 6. Наскрізні номери всіх уроків A0 («Урок N: …» / «Lekcija N: …»); стара назва — у content_versions
do $$
declare r record; v_payload jsonb; v_new_ua text; v_new_hr text;
begin
  for r in select l.id, l.title_ua, l.title_hr,
                  row_number() over (order by m.order_index, u.order_index, l.order_index) as n
             from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
            where m.level_code = {q(LEVEL)} and l.status = 'PUBLISHED' loop
    v_new_ua := regexp_replace(r.title_ua, '^Урок [0-9]+:', 'Урок ' || r.n || ':');
    v_new_hr := regexp_replace(r.title_hr, '^Lekcija [0-9]+:', 'Lekcija ' || r.n || ':');
    if v_new_ua is not distinct from r.title_ua and v_new_hr is not distinct from r.title_hr then continue; end if;
    select to_jsonb(l) into v_payload from public.lessons l where l.id = r.id;
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lesson', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lesson' and entity_id = r.id), 0) + 1,
            v_payload, 'curriculum_a0_v4: новий номер уроку ' || r.n);
    update public.lessons set title_ua = v_new_ua, title_hr = v_new_hr where id = r.id;
  end loop;
end $$;
"""


GRAMMAR_NOTE = 'Бета: нова тема граматики A0 для уроків за темою (curriculum_a0_v4) за запитом власника 2026-10-19. Потрібна перевірка носієм.'


def grammar_sql(module: int) -> list[str]:
    """Нові теми граматики модуля (якщо є): тема + правила з прикладами; наявну тему з такою назвою не дублює."""
    G = MODULES[module].get('new_grammar', {})
    if not G:
        return []
    out = [f'-- 1а. Нові теми граматики A0 ({len(G)})']
    for key, g in G.items():
        gid = uid('grammar', LEVEL, key)
        out.append(
            'insert into public.grammar_topics (id, cefr, title_ua, title_hr, description, status)\n'
            f"select {q(gid)}, {q(LEVEL)}, {q(g['title_ua'])}, {q(g['title_hr'])}, {q(g['description'])}, {q(STATUS)}\n"
            f"where not exists (select 1 from public.grammar_topics where cefr = {q(LEVEL)} and title_ua = {q(g['title_ua'])});")
        for i, (title, expl, pattern, examples) in enumerate(g['rules'], 1):
            ex = [{'hr': hr, 'ua': ua} for hr, ua in examples]
            out.append(
                'insert into public.grammar_rules (id, topic_id, title_ua, explanation_ua, pattern_hr, examples, order_index)\n'
                f"select {q(uid('grammar_rule', LEVEL, key, i))}, {q(gid)}, {q(title)}, {q(expl)}, {q(pattern)}, {qj(ex)}, {i}\n"
                f'where exists (select 1 from public.grammar_topics where id = {q(gid)})\n'
                'on conflict (id) do nothing;')
        out.append(
            'insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)\n'
            f"select 'grammar_topic', {q(gid)}, null, {q(STATUS)}, 'auto_passed', 'ai', '[]'::jsonb, {q(GRAMMAR_NOTE)}\n"
            f'where exists (select 1 from public.grammar_topics where id = {q(gid)})\n'
            f'  and not exists (select 1 from public.content_reviews where entity_id = {q(gid)} and notes = {q(GRAMMAR_NOTE)});')
    out.append('')
    return out


FIX_NOTE = 'curriculum_a0_v4: виправлено переклад слова (додано значення за темою уроку) — стара версія'


def fix_translations_sql(module: int) -> list[str]:
    """Виправлення перекладу наявних слів: лише якщо переклад досі старий; стара версія — у content_versions."""
    F = MODULES[module].get('fix_translations', [])
    if not F:
        return []
    out = [f'-- 1б. Виправлені переклади наявних слів ({len(F)}); повторний запуск нічого не змінює']
    for lemma, old, new in F:
        out.append(f"""do $$
declare r record;
begin
  for r in select * from public.lexemes where lower(lemma) = {q(lemma.lower())} and ukrainian_translation = {q(old)} loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), {q(FIX_NOTE)});
    update public.lexemes set ukrainian_translation = {q(new)} where id = r.id;
  end loop;
end $$;""")
    out.append('')
    return out


def build_module(c: Course, module: int) -> str:
    M = MODULES[module]
    keys = sorted(M['lessons'])
    rebuilt = [k for k in keys if 'old' in M['lessons'][k]]
    created = [k for k in keys if 'old' not in M['lessons'][k]]
    words_total = sum(len(M['lessons'][k]['words']) for k in keys)
    first, last = NUMBER[keys[0]], NUMBER[keys[-1]]
    total = A0_TOTAL[module]
    ids = ', '.join(q(lesson_id(*k)) for k in keys)
    order_check = ', '.join(f"({q(lesson_id(*k))}::uuid, {k[1]})" for k in keys)
    lo, hi = M.get('words', WORDS_DEFAULT)
    G = M.get('new_grammar', {})
    F = M.get('fix_translations', [])
    fix_line = (f"\n--   * Виправлено переклад: {', '.join(f'{l} — «{n}»' for l, _o, n in F)} (стара версія — у content_versions)." if F else '')
    grammar_line = (f"\n--   * Нові теми граматики: {', '.join('«' + g['title_ua'] + '»' for g in G.values())}." if G else '')
    out = [f"""-- =====================================================================
-- Уроки A0 за темою · curriculum_a0_v4 · модуль A0.{module} · {REVIEW_DATE[module]}
-- Згенеровано: python3 scripts/gen_curriculum_a0_v4.py (не редагуйте вручну).
--
-- Рішення власника 2026-10-15: слова уроку — за темою уроку, 20–25 слів і виразів, діалоги під тему; бета (PUBLISHED).
--   * Уроки {first}–{last}: {len(rebuilt)} наявних перебудовано, {len(created)} нових тематичних уроків. Слів у них: {words_total}.
--     Кожен: {lo}–{hi} слів, 2 діалоги, 15 вправ, {MINUTES} хв.
--   * Нові слова й вирази: {len(M['new_lexemes'])}.{grammar_line}{fix_line}
--   * Новий порядок уроків у модулі; назви всіх уроків A0 перенумеровано підряд (разом {total}).
--   * Стара версія кожного зміненого уроку — у content_versions; копія кроків — у {BACKUP};
--     старі вправи й діалоги → DEPRECATED (не видаляються).
--   * Усе в одній транзакції; безпечно запускати повторно (зроблене пропускається).
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

create schema if not exists backup;
create table if not exists {BACKUP} (like public.lesson_items including defaults);
do $$ begin
  if not exists (select 1 from pg_constraint where conname = 'lesson_items_20261015_pkey') then
    alter table {BACKUP} add constraint lesson_items_20261015_pkey primary key (id);
  end if;
end $$;
revoke all on {BACKUP} from anon, authenticated;
""", helpers_sql()]
    out += lexemes_sql(M['new_lexemes'])
    out += grammar_sql(module)
    out += fix_translations_sql(module)
    out.append(f'-- 2. Перебудова наявних уроків модуля A0.{module}')
    for key in rebuilt:
        out += rebuild_sql(c, key)
    out.append(order_sql(module, keys, final=False))
    out.append(f'-- 4. Нові тематичні уроки модуля A0.{module}')
    for key in created:
        out += create_sql(c, key)
    out.append(order_sql(module, keys, final=True))
    out.append(RENUMBER_SQL)
    out.append(f"""-- 7. Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_bad int; v_lessons int; v_titles int; v_order int; v_module int; v_words int;
begin
  select count(*) into v_bad from public.lessons l
   where l.id in ({ids})
     and ((select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'lexeme') not between {lo} and {hi}
          or (select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') <> 2
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED') <> 15
          or not exists (select 1 from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'grammar')
             and exists (select 1 from public.lesson_grammar lg where lg.lesson_id = l.id)
          or l.status <> 'PUBLISHED' or l.estimated_minutes <> {MINUTES});
  select count(*) into v_module from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
   where m.level_code = {q(LEVEL)} and m.order_index = {module};
  select count(*) into v_order from (values {order_check}) as t(id, o) join public.lessons l on l.id = t.id and l.order_index = t.o;
  select count(*) into v_lessons from public.lessons where level_code = {q(LEVEL)} and status = 'PUBLISHED';
  select count(*) into v_titles from (
     select l.title_ua, l.title_hr, row_number() over (order by m.order_index, u.order_index, l.order_index) as n
       from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
      where m.level_code = {q(LEVEL)} and l.status = 'PUBLISHED') t
   where t.title_ua not like 'Урок ' || t.n || ':%' or t.title_hr not like 'Lekcija ' || t.n || ':%';
  select count(*) into v_words from (
     select li.item_id from public.lesson_items li where li.lesson_id in ({ids}) and li.item_type = 'lexeme'
      group by 1 having count(*) > 1) d;
  if v_bad > 0 then raise exception 'Модуль A0.{module}: % уроків з неправильним складом', v_bad; end if;
  if v_module <> {len(keys)} or v_order <> {len(keys)} then raise exception 'Модуль A0.{module}: уроків %, на своїх місцях % (очікувалось {len(keys)})', v_module, v_order; end if;
  if v_lessons < {total} then raise exception 'A0: уроків %, очікувалось щонайменше {total}', v_lessons; end if;  -- наступні модулі додають уроки
  if v_titles > 0 then raise exception 'A0: % уроків з неправильним номером у назві', v_titles; end if;
  if v_words > 0 then raise exception 'Модуль A0.{module}: % слів повторюються в кількох уроках', v_words; end if;
  raise notice 'Готово: модуль A0.{module} — {len(keys)} уроків ({first}–{last}) за темою; уроків A0 — %', v_lessons;
end $$;

commit;
""")
    return '\n'.join(out)


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


def validate(c: Course, module: int):
    M = MODULES[module]
    for key in sorted(M['lessons']):
        c.validate_lesson(key)
        c.lesson_exercises(key)
    # нові слова: діакритика в normalized прибрана, леми без кирилиці, є приклад
    for lemma, norm, ua, pos, vtype, forms, ex in M['new_lexemes']:
        if re.search(r'[čćđšž]', norm) or norm != norm.lower():
            c.errors.append(f'{lemma}: normalized має бути без діакритики й малими літерами')
        if re.search(r'[Ѐ-ӿ]', lemma + ex):
            c.errors.append(f'{lemma}: кирилиця в лемі чи прикладі')
        if not re.search(r'[Ѐ-ӿ]', ua):
            c.errors.append(f'{lemma}: переклад без кирилиці')
        if vtype not in ('core', 'function_word', 'formulaic', 'collocation', 'chunk'):
            c.errors.append(f'{lemma}: невідомий vocabulary_type')
        if module > 1 and (lemma.lower() in SNAP or lemma.lower() in SNAPSHOT['extra'] or lemma.lower() in D.EXTRA_SNAPSHOT):
            c.errors.append(f'{lemma}: уже є в робочій базі — не додавайте як нове слово')
    # слово не повторюється в кількох уроках модуля
    seen: dict = {}
    for key in sorted(M['lessons']):
        for w in M['lessons'][key]['words']:
            if w.lower() in seen:
                c.errors.append(f'«{w}» є і в уроці {NUMBER[seen[w.lower()]]}, і в уроці {NUMBER[key]}')
            seen[w.lower()] = key
    if module > 1:
        # не повторюємо слів уже перебудованих модулів; нове слово не дублює нове слово іншого модуля
        earlier = {w.lower(): m for m in range(1, module) for L in MODULES[m]['lessons'].values() for w in L['words']}
        for w, key in seen.items():
            if w in earlier:
                c.errors.append(f'«{w}» (урок {NUMBER[key]}) уже є в модулі A0.{earlier[w]}')
        olds = sorted(L['old'] for L in M['lessons'].values() if 'old' in L)
        if olds != list(range(1, len(olds) + 1)):
            c.errors.append(f'A0.{module}: наявні уроки (old) мають бути 1…{len(olds)}, а не {olds}')
        for key, L in M['lessons'].items():
            if ('old' in L) == ('slug' in L):
                c.errors.append(f'{key}: потрібне одне з old / slug')
            if 'old' not in L and not L['grammar']:
                c.errors.append(f'{key}: новому уроку потрібна тема граматики')
        earlier_new = {l[0].lower(): m for m in range(1, module) for l in MODULES[m]['new_lexemes']}
        for l in M['new_lexemes']:
            if l[0].lower() in earlier_new:
                c.errors.append(f'{l[0]}: уже нове слово модуля A0.{earlier_new[l[0].lower()]}')
        if sorted(k[1] for k in M['lessons']) != list(range(1, len(M['lessons']) + 1)):
            c.errors.append(f'A0.{module}: місця уроків мають іти 1…{len(M["lessons"])}')


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    modules = [int(a) for a in args] or sorted(MODULES)
    courses = {}
    errors = []
    for module in modules:
        c = build_course(module)
        validate(c, module)
        errors += [f'A0.{module}: {e}' for e in c.errors]
        courses[module] = c
    if errors:
        print('Перевірка не пройдена:', *errors, sep='\n  ', file=sys.stderr)
        sys.exit(1)
    if '--sync' in sys.argv:
        SYNC_OUT.write_text(sync_sql(), encoding='utf-8')
        print(f'{SYNC_OUT.relative_to(ROOT)}: {SYNC_OUT.stat().st_size // 1024} КБ')
        return
    if '--review' in sys.argv:
        for module in modules:
            sys.stdout.write(review(courses[module], module))
        return
    for module in modules:
        sql = build(courses[module]) if module == 1 else build_module(courses[module], module)
        out = MODULES[module]['out']
        out.write_text(sql, encoding='utf-8')
        print(f'{out.relative_to(ROOT)}: {len(sql.encode()) // 1024} КБ')


if __name__ == '__main__':
    main()
