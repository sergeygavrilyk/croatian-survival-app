#!/usr/bin/env python3
"""
Мовна перевірка A2 v2 після публікації (2026-11-12): пакет змін до вже запущених SQL A2 v2.

  python3 -B scripts/gen_curriculum_a2_v2_fix.py            →  supabase/data_fixes/20261112_curriculum_a2_v2_u1_review_fix.sql
  python3 -B scripts/gen_curriculum_a2_v2_fix.py --report   →  що змінено (у консоль)

Пакети 20261112_curriculum_a2_v2_00…m14 і _t1_assessments уже запущено в робочій базі (PR #19, коміт b4fee5f). Дані модулів
(scripts/curriculum_a2_v2_m*.py) після мовної перевірки змінено, тож генератор тепер дав би інший SQL — уже запущені файли
не перезаписуємо. Цей скрипт будує вміст уроків двічі — за даними коміту b4fee5f (як у базі) і за поточними — і пише SQL лише з різницею:
  * нові слова — PUBLISHED; у кожному уроці слово на тому самому місці замінено (копія зв’язків — у backup);
  * слова пакета A2 v2 з іншим перекладом / прикладом / родом-видом — оновлено (стара версія — у content_versions);
  * вправи, письмо й переказ, репліки діалогів, завдання перевірок рівня — оновлено за id (стара версія — у content_versions);
  * слова пакета A2 v2, яких більше немає в жодному уроці й вправі, — DEPRECATED (не видаляються).
"""
from __future__ import annotations

import json
import subprocess
import sys
import tarfile
import tempfile
from io import BytesIO
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BASE_COMMIT = 'b4fee5f'  # мерж PR #19 — саме ці SQL A2 v2 запущено в робочій базі 2026-11-12
OUT = ROOT / 'supabase' / 'data_fixes' / '20261112_curriculum_a2_v2_u1_review_fix.sql'
SOURCE = 'claude_curriculum_a2_v2'
REASON = 'curriculum_a2_v2: мовна перевірка 2026-11-12 — стара версія'
NOTE = 'curriculum_a2_v2: мовна перевірка 2026-11-12 (content/reviews/2026-11-12_a2_v2_content_review.md). Бета, потрібна перевірка носієм.'


# ----------------------------------------------------------------------------- знімок даних
def dump() -> dict:
    """Запускається в підпроцесі з потрібною копією scripts/ на sys.path; друкує JSON."""
    import gen_curriculum_a2_v2 as V
    import gen_assessment_a2_v2 as G
    out = {'lessons': {}, 'lexemes': {}, 'items': {}}
    for m in sorted(V.D.PROGRAM):
        c = V.build_course(m)
        wrows = V.writing_rows(m)
        for r in V.new_lexemes(m):
            out['lexemes'][r['lemma'].lower()] = {k: r[k] for k in ('lemma', 'normalized', 'part_of_speech', 'ukrainian_translation',
                                                                     'vocabulary_type', 'forms', 'examples')}
        for key in sorted(c.lessons):
            mm, o = key
            L = c.lessons[key]
            lid = V.lesson_id(mm, o)
            exs = []
            for ei, ex in enumerate(c.lesson_exercises(key), 1):
                exs.append({'id': V.uid('exercise_a2v2', V.LEVEL, mm, o, ei), 'type': ex['type'], 'question': ex['question'],
                            'answer': ex['answer'], 'options': ex.get('options'), 'word': ex.get('word'), 'task': ex.get('task'),
                            'skill': ex.get('skill')})
            for r in wrows[lid]:
                exs.append({'id': r['id'], 'type': r['type'], 'question': r['question'], 'answer': r['answer'], 'options': None,
                            'word': None, 'task': r['task'], 'skill': r['skill']})
            turns = []
            for si, (_s_ua, _s_hr, ts) in enumerate(L['scenes'], 1):
                for ti, (speaker, hr, ua) in enumerate(ts, 1):
                    turns.append({'id': V.uid('turn_a2v2', V.LEVEL, mm, o, si, ti), 'speaker': speaker, 'hr': hr, 'ua': ua})
            out['lessons'][lid] = {'place': V.PLACE[key], 'words': L['words'], 'exercises': exs, 'turns': turns}
    for t in G.tests():
        for it in t['items']:
            out['items'][it['id']] = {k: it[k] for k in ('prompt_ua', 'prompt_hr', 'options', 'correct_index', 'answer_text',
                                                         'audio_hr', 'passage_hr', 'passage_ua', 'explanation_ua', 'lesson')}
    return out


def snapshot(scripts_dir: Path) -> dict:
    code = (f'import sys, json; sys.path.insert(0, {str(scripts_dir)!r}); sys.argv = ["x"]; '
            f'sys.path.append({str(Path(__file__).parent)!r}); import gen_curriculum_a2_v2_fix as F; '
            f'print(json.dumps(F.dump(), ensure_ascii=False))')
    res = subprocess.run([sys.executable, '-B', '-c', code], cwd=scripts_dir, capture_output=True, text=True)
    if res.returncode:
        raise SystemExit(res.stderr[-3000:])
    return json.loads(res.stdout)


def base_scripts(tmp: Path) -> Path:
    data = subprocess.run(['git', 'archive', BASE_COMMIT, 'scripts', 'lib'], cwd=ROOT, capture_output=True, check=True).stdout
    with tarfile.open(fileobj=BytesIO(data)) as tf:
        tf.extractall(tmp, filter='data')
    return tmp / 'scripts'


# ----------------------------------------------------------------------------- SQL
def q(s) -> str:
    return 'null' if s is None else "'" + str(s).replace("'", "''") + "'"


def qj(v) -> str:
    return 'null' if v is None else q(json.dumps(v, ensure_ascii=False)) + '::jsonb'


def version(entity: str, table: str, ident: str, cond: str = 'true') -> str:
    """Стара версія — у content_versions, лише якщо рядок ще не такий (повторний запуск нічого не додає)."""
    return (f"insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)\n"
            f"select {q(entity)}, x.id, coalesce((select max(version) from public.content_versions where entity_type = {q(entity)} and entity_id = x.id), 0) + 1,\n"
            f"       to_jsonb(x), {q(REASON)} from public.{table} x where x.id = {ident} and ({cond});")


def differs(pairs: list[tuple[str, str]]) -> str:
    return '(' + ', '.join(c for c, _ in pairs) + ') is distinct from (' + ', '.join(v for _, v in pairs) + ')'


def diff(old: dict, new: dict) -> dict:
    d = {'new_lex': [], 'upd_lex': [], 'relink': [], 'ex': [], 'turns': [], 'items': [], 'gone': []}
    used_new = set()
    for lid, nl in new['lessons'].items():
        ol = old['lessons'][lid]
        if len(ol['words']) != len(nl['words']):
            raise SystemExit(f'урок {nl["place"]}: інша кількість слів — потрібен інший пакет')
        for pos, (a, b) in enumerate(zip(ol['words'], nl['words']), 1):
            used_new.add(b.lower())
            if a.lower() != b.lower():
                d['relink'].append((lid, nl['place'], pos, a, b))
        oex = {e['id']: e for e in ol['exercises']}
        for e in nl['exercises']:
            if e['word']:
                used_new.add(e['word'].lower())
            o = oex.get(e['id'])
            if o is None:
                raise SystemExit(f'урок {nl["place"]}: інший склад вправ ({e["id"]})')
            if o['type'] != e['type']:
                d.setdefault('retype', []).append((nl['place'], o['type'], e['type'], o['skill'], e['skill']))
            if any(o[k] != e[k] for k in ('type', 'question', 'answer', 'options', 'word', 'task', 'skill')):
                d['ex'].append((nl['place'], e))
        oturn = {t['id']: t for t in ol['turns']}
        for t in nl['turns']:
            o = oturn[t['id']]
            if (o['speaker'], o['hr'], o['ua']) != (t['speaker'], t['hr'], t['ua']):
                d['turns'].append((nl['place'], t))
    for lem, r in new['lexemes'].items():
        o = old['lexemes'].get(lem)
        if o is None:
            d['new_lex'].append(r)
        elif o != r:
            d['upd_lex'].append(r)
    d['gone'] = sorted(r['lemma'] for lem, r in old['lexemes'].items() if lem not in new['lexemes'] and lem not in used_new)
    for iid, it in new['items'].items():
        if old['items'].get(iid) != it:
            d['items'].append((iid, old['items'].get(iid), it))
    return d


def build(d: dict) -> str:
    s = [f"""-- =====================================================================
-- Мовна перевірка A2 v2 після публікації · 2026-11-12
-- Згенеровано: python3 -B scripts/gen_curriculum_a2_v2_fix.py (не редагуйте вручну). Звіт — content/reviews/2026-11-12_a2_v2_content_review.md.
--
-- Пакети 20261112_curriculum_a2_v2_00…m14 і _t1 уже запущено (PR #19). Тут лише різниця з ними:
--   * нових слів {len(d['new_lex'])} (PUBLISHED; ті, що вже є в словнику, — лише зв’язок); замін слова в уроці {len(d['relink'])}
--     (те саме місце; копія зв’язків — у backup.lesson_items_a2_review_20261112);
--   * оновлено слів пакета A2 v2 {len(d['upd_lex'])}, вправ {len(d['ex'])}, реплік {len(d['turns'])}, завдань перевірок {len(d['items'])}
--     (стара версія кожного — у content_versions);
--   * DEPRECATED слів пакета A2 v2, яких більше немає в уроках: {len(d['gone'])}. Нічого не видаляє.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

do $$ begin
  if not exists (select 1 from public.lessons where id = {q(d['relink'][0][0] if d['relink'] else None)}) then
    raise exception 'Спершу мають бути запущені пакети 20261112_curriculum_a2_v2_00…m14';
  end if;
end $$;

-- 1. Нові слова
"""]
    if d['new_lex']:
        data = [dict(lemma=r['lemma'], normalized=r['normalized'], pos=r['part_of_speech'], ua=r['ukrainian_translation'],
                     vtype=r['vocabulary_type'], forms=r['forms'], examples=r['examples']) for r in d['new_lex']]
        s += ['insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)',
              f"select t.lemma, t.normalized, 'hr', t.pos, 'A2', t.ua, t.vtype, t.forms, t.examples, 'PUBLISHED', {q(SOURCE)}",
              f'  from jsonb_to_recordset({qj(data)})',
              '    as t(lemma text, normalized text, pos text, ua text, vtype text, forms jsonb, examples jsonb)',
              ' where not exists (select 1 from public.lexemes x where lower(x.lemma) = lower(t.lemma));', '']
    s.append('-- 2. Слова пакета A2 v2 з уточненим перекладом / прикладом (лише ті, що створив пакет A2 v2)')
    for r in d['upd_lex']:
        pairs = [('x.part_of_speech', q(r['part_of_speech'])), ('x.ukrainian_translation', q(r['ukrainian_translation'])),
                 ('x.forms', qj(r['forms'])), ('x.examples', qj(r['examples'])), ('x.normalized', q(r['normalized']))]
        sets = ', '.join(f"{c[2:]} = {v}" for c, v in pairs)
        s.append('do $$ declare v_id uuid; begin')
        s.append(f"  select id into v_id from public.lexemes where lower(lemma) = lower({q(r['lemma'])}) and source = {q(SOURCE)} order by created_at limit 1;")
        s.append('  if v_id is null then return; end if;  -- слово було в словнику раніше — не змінюємо')
        s.append('  ' + version('lexeme', 'lexemes', 'v_id', differs(pairs)).replace('\n', '\n  '))
        s.append(f"  update public.lexemes x set {sets}, version = x.version + 1, updated_at = now() where x.id = v_id and {differs(pairs)};")
        s.append('end $$;')
    s += ['', '-- 3. Слова в уроках: те саме місце, нове слово',
          'create table if not exists backup.lesson_items_a2_review_20261112 as select * from public.lesson_items where false;']
    for lid, place, pos, a, b in d['relink']:
        s.append(f'do $$ declare v_old uuid; v_new uuid; begin  -- урок {place}, слово {pos}: {a} → {b}')
        s.append(f"  select id into v_new from public.lexemes where lower(lemma) = lower({q(b)}) and status = 'PUBLISHED' order by created_at limit 1;")
        s.append(f"  if v_new is null then raise exception 'Немає опублікованого слова «%»', {q(b)}; end if;")
        s.append(f"  select li.item_id into v_old from public.lesson_items li join public.lexemes x on x.id = li.item_id"
                 f" where li.lesson_id = {q(lid)} and li.item_type = 'lexeme' and lower(x.lemma) = lower({q(a)}) limit 1;")
        s.append('  if v_old is null then return; end if;  -- уже замінено')
        s.append(f"  insert into backup.lesson_items_a2_review_20261112 select * from public.lesson_items where lesson_id = {q(lid)} and item_type = 'lexeme' and item_id = v_old;")
        s.append(f"  update public.lesson_items set item_id = v_new where lesson_id = {q(lid)} and item_type = 'lexeme' and item_id = v_old;")
        s.append('end $$;')
    s += ['', '-- 4. Вправи, письмо й переказ (за id)']
    for place, e in d['ex']:
        lex = (f"(select id from public.lexemes where lower(lemma) = lower({q(e['word'])}) and status = 'PUBLISHED' order by created_at limit 1)"
               if e['word'] else 'null::uuid')
        pairs = [('x.exercise_type', q(e['type'])), ('x.question_text', q(e['question'])), ('x.correct_answer', q(e['answer'])),
                 ('x.options', qj(e['options'])), ('x.task', qj(e['task'])), ('x.lexeme_id', lex)]
        sets = ', '.join(f"{c[2:]} = {v}" for c, v in pairs)
        s.append(f'-- урок {place}, {e["type"]}')
        s.append(version('exercise', 'exercises', q(e['id']), differs(pairs)))
        s.append(f"update public.exercises x set {sets} where x.id = {q(e['id'])} and {differs(pairs)};")
        s.append(f"update public.lesson_items set target_skill = {q(e['skill'])} where item_type = 'exercise' and item_id = {q(e['id'])}"
                 f" and target_skill is distinct from {q(e['skill'])};")
    s += ['', '-- 5. Репліки діалогів (за id)']
    for place, t in d['turns']:
        pairs = [('x.speaker_name', q(t['speaker'])), ('x.hr_text', q(t['hr'])), ('x.ua_translation', q(t['ua']))]
        sets = ', '.join(f"{c[2:]} = {v}" for c, v in pairs)
        s.append(f'-- урок {place}')
        s.append(version('conversation_turn', 'conversation_turns', q(t['id']), differs(pairs)))
        s.append(f"update public.conversation_turns x set {sets} where x.id = {q(t['id'])} and {differs(pairs)};")
    s += ['', '-- 6. Завдання перевірок рівня A2 (за id)']
    for iid, _old, it in d['items']:
        lesson = f"(select id from public.lessons where id = {q(it['lesson'])})" if it['lesson'] else 'null::uuid'
        pairs = [('x.prompt_ua', q(it['prompt_ua'])), ('x.prompt_hr', q(it['prompt_hr'])), ('x.options', qj(it['options'])),
                 ('x.correct_index', str(it['correct_index']) if it['correct_index'] is not None else 'null::int'),
                 ('x.answer_text', q(it['answer_text'])), ('x.audio_hr', q(it['audio_hr'])), ('x.passage_hr', q(it['passage_hr'])),
                 ('x.passage_ua', q(it['passage_ua'])), ('x.explanation_ua', q(it['explanation_ua'])), ('x.lesson_id', lesson)]
        sets = ', '.join(f"{c[2:]} = {v}" for c, v in pairs)
        s.append(version('assessment_item', 'assessment_items', q(iid), differs(pairs)))
        s.append(f"update public.assessment_items x set {sets} where x.id = {q(iid)} and {differs(pairs)};")
    s += ['', '-- 7. Слова пакета A2 v2, яких більше немає в уроках і вправах, — DEPRECATED']
    if d['gone']:
        lst = ', '.join(q(x.lower()) for x in d['gone'])
        s += ['insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)',
              "select 'lexeme', x.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = x.id), 0) + 1,",
              f'       to_jsonb(x), {q(REASON)} from public.lexemes x',
              f" where lower(x.lemma) in ({lst}) and x.source = {q(SOURCE)} and x.status = 'PUBLISHED'",
              "   and not exists (select 1 from public.lesson_items li where li.item_type = 'lexeme' and li.item_id = x.id)",
              '   and not exists (select 1 from public.exercises e where e.lexeme_id = x.id);',
              "update public.lexemes x set status = 'DEPRECATED', updated_at = now()",
              f" where lower(x.lemma) in ({lst}) and x.source = {q(SOURCE)} and x.status = 'PUBLISHED'",
              "   and not exists (select 1 from public.lesson_items li where li.item_type = 'lexeme' and li.item_id = x.id)",
              '   and not exists (select 1 from public.exercises e where e.lexeme_id = x.id);']
    new_words = sorted({b.lower() for _l, _p, _pos, _a, b in d['relink']})
    s += ['', '-- журнал перевірки',
          'insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)',
          f"select 'lesson', l.id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, {q(NOTE)} from public.lessons l",
          f" where l.id in ({', '.join(q(x) for x in sorted({r[0] for r in d['relink']} | set()))})",
          f"   and not exists (select 1 from public.content_reviews r where r.entity_id = l.id and r.notes = {q(NOTE)});", '']
    bad_words = ', '.join(q(x) for x in new_words) or "''"
    s.append(f"""-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_missing int; v_bad int; v_dup int;
begin
  select count(*) into v_missing from unnest(array[{bad_words}]) w
   where not exists (select 1 from public.lexemes x join public.lesson_items li on li.item_id = x.id and li.item_type = 'lexeme'
                     where lower(x.lemma) = w and x.status = 'PUBLISHED');
  select count(*) into v_bad from public.lessons l join public.units u on u.id = l.unit_id join public.modules m on m.id = u.module_id
   where m.level_code = 'A2' and (select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'lexeme') not between 20 and 25;
  select count(*) into v_dup from (select li.item_id from public.lesson_items li join public.lessons l on l.id = li.lesson_id
    where l.level_code = 'A2' and li.item_type = 'lexeme' group by li.item_id having count(*) > 1) t;
  if v_missing > 0 then raise exception 'Мовна перевірка A2: % нових слів не в уроках', v_missing; end if;
  if v_bad > 0 then raise exception 'Мовна перевірка A2: % уроків не з 20–25 словами', v_bad; end if;
  if v_dup > 0 then raise exception 'Мовна перевірка A2: % слів повторюються між уроками', v_dup; end if;
  raise notice 'Готово: мовна перевірка A2 — замін слів {len(d['relink'])}, вправ {len(d['ex'])}, реплік {len(d['turns'])}, завдань перевірок {len(d['items'])}';
end $$;

commit;
""")
    return '\n'.join(s)


def main():
    with tempfile.TemporaryDirectory() as tmp:
        old = snapshot(base_scripts(Path(tmp)))
    new = snapshot(Path(__file__).resolve().parent)
    d = diff(old, new)
    if '--report' in sys.argv:
        print(f"нових слів {len(d['new_lex'])}, оновлених {len(d['upd_lex'])}, замін {len(d['relink'])}, вправ {len(d['ex'])}, "
              f"реплік {len(d['turns'])}, завдань перевірок {len(d['items'])}, DEPRECATED {len(d['gone'])}")
        for iid, o, n in d['items']:
            print('ITEM', iid, '|', (o or {}).get('prompt_ua'), '→', n['prompt_ua'])
        print('GONE', d['gone'])
        print('RETYPE', d.get('retype'))
        return
    sql = build(d)
    OUT.write_text(sql, encoding='utf-8')
    print(f'{OUT.relative_to(ROOT)}: {len(sql.encode()) // 1024} КБ')


if __name__ == '__main__':
    main()
