#!/usr/bin/env python3
"""
Чистка словника A0 / A1 і ввічливе «htio bih» як готовий вираз · 2026-11-04 (рішення власника за аудитом, питання 5 і 6).

  python3 -B scripts/gen_vocab_cleanup_20261104.py  →  supabase/data_fixes/20261104_vocab_cleanup.sql

1. Готові вирази (kondicional — граматика A2): htio bih, htjela bih → «У кафе»; ja bih → «У ресторані»;
   biste li mogli → «На касі» (A0).
2. obaveza (сербська форма): з уроку A1 «Мій робочий день» (obveza — з A0), у 3 вправах → obveza; obavezno → obvezno у 3 прикладах.
   Виправлено форми htjeti (теперішній час: hoću, hoćeš, hoće — не «želim»).
3. DEPRECATED (не видаляємо — приховуємо): obaveza, njen (→ njezin), «ona (pl)», nulti і старі леми-речення першої версії
   в запасі словника (не в уроках, без прогресу користувачів).
Стара версія — у content_versions, запис — у content_reviews. Повторний запуск нічого не змінює.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).parent))
from lexeme_checks import check_example, normalize  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / 'supabase' / 'data_fixes' / '20261104_vocab_cleanup.sql'
SOURCE = 'claude_vocab_cleanup_20261104'
NOTE_NEW = 'vocab_cleanup 2026-11-04: ввічливий готовий вираз (умовний спосіб — граматика A2), рішення власника. Потрібна перевірка носієм.'
NOTE_FIX = 'vocab_cleanup 2026-11-04: obaveza / obavezno → obveza / obvezno (хорватська норма); форми htjeti. Рішення власника.'
NOTE_DEP = 'vocab_cleanup 2026-11-04: DEPRECATED за рішенням власника — сербська / розмовна форма, помилковий запис або лема-речення першої версії.'

CAFE, RESTAURANT, CASH = ('c9e045fb-91ff-52a2-9916-1b698d30eb19', '8b30911e-4e57-5648-9ff6-bd11c1b0e27e',
                          '28913ad6-490f-5d89-bad7-9b303c673fcd')
WORKDAY_A1 = 'd813e9c0-2331-59d8-90f1-cea7e9a61c7d'  # A1 «Мій робочий день»

EXPL = 'Готовий вираз: запам’ятайте цілим. Ввічливіше, ніж želim. Граматика умовного способу (bih, bi, biste) — на рівні A2.'
NEW = [
    dict(lemma='htio bih', tr='я хотів би (каже чоловік)', lesson=CAFE,
         expl=EXPL + ' Так каже чоловік; жінка — htjela bih.',
         ex=['Htio bih jednu kavu s mlijekom.', 'Htio bih platiti, molim.']),
    dict(lemma='htjela bih', tr='я хотіла б (каже жінка)', lesson=CAFE,
         expl=EXPL + ' Так каже жінка; чоловік — htio bih.',
         ex=['Htjela bih čaj s limunom.', 'Htjela bih komad torte, molim.']),
    dict(lemma='ja bih', tr='я б (узяв / узяла)… — ввічливе замовлення', lesson=RESTAURANT,
         expl='Готовий вираз для замовлення: «Ja bih…» + що саме (знахідний відмінок). Однаково для чоловіка й жінки. '
              'Граматика умовного способу — на рівні A2.',
         ex=['Ja bih jednu kavu, molim.', 'Ja bih juhu i ribu.']),
    dict(lemma='biste li mogli', tr='чи не могли б ви…', lesson=CASH,
         expl='Ввічливе прохання до незнайомих (на «Vi»). Після нього — інфінітив: Biste li mi mogli dati…? '
              'Простіше й теж ввічливо — Možete li…? Граматика умовного способу — на рівні A2.',
         ex=['Biste li mi mogli dati vrećicu?', 'Biste li mogli ponoviti, molim?']),
]

# Виправлення прикладів (стара → нова) і форм
EXAMPLE_FIX = {
    'zdravstveno osiguranje': ('Obavezno zdravstveno osiguranje.', 'Obvezno zdravstveno osiguranje.'),
    'reciklaža': ('Reciklaža je obavezna u našoj zgradi.', 'Reciklaža je obvezna u našoj zgradi.'),
    'polog': ('Obavezno je platiti polog pri useljenju.', 'Obvezno je platiti polog pri useljenju.'),
}
HTJETI = dict(forms={'past': 'htio', 'aspect': 'ipfv', 'present': {'1s': 'hoću', '2s': 'hoćeš', '3s': 'hoće'},
                     'negative': 'neću'},
              ex=['Hoćeš li kavu?', 'Hoću ići kući.'])
# Вправи уроку A1 «Мій робочий день» (id — з пакетів curriculum_a1_v3): поле → (старе, нове)
EXERCISE_FIX = {
    '78a3e5c1-cf18-54ee-8983-cca2c638c394': {'options': (['obaveza', 'prekovremeno', 'izvještaj', 'završavati'],
                                                         ['obveza', 'prekovremeno', 'izvještaj', 'završavati'])},
    '1513ecb0-59e5-5043-9345-be4c7b7d4ebc': {'correct_answer': ('Imaš li puno obaveza?', 'Imaš li puno obveza?'),
                                             'options': (['puno', 'obaveza?', 'Imaš', 'li'], ['puno', 'obveza?', 'Imaš', 'li'])},
    'f9261f71-41d4-5410-8a10-7e49d7ae24ed': {'question_text': ('Ne ___ raditi u subotu, to nije obavezno.',
                                                               'Ne ___ raditi u subotu, to nije obvezno.')},
}

# DEPRECATED: лише в запасі (не в уроках, без прогресу користувачів) — пакет перевіряє це ще раз
DEPRECATE_WORDS = ['obaveza', 'njen', 'ona (pl)', 'nulti']
DEPRECATE_SENTENCES = [
    # A0, перша версія: цілі репліки записані як «слова»
    'dobro jutro svima', 'gdje je', 'gdje je apoteka', 'gdje je autobusni kolodvor', 'gdje je banka', 'gdje je bankomat',
    'gdje je blagajna', 'gdje je izlaz', 'gdje je kabina', 'gdje je ljekarna', 'gdje je ulaz', 'gdje je wc', 'gdje je zahod',
    'gdje je željeznički kolodvor', 'gdje mogu kupiti kartu', 'gdje mogu naći', 'gladan sam', 'gladna sam', 'imam rezervaciju',
    'imate li', 'imate li sitno', 'imate li slobodnu sobu', 'imate li wifi', 'izgubila sam se', 'ja bih vodu', 'ja sam gladan',
    'ja sam iz Ukrajine', 'ja sam umoran', 'ja sam žedan', 'kako da dođem do', 'kamo idete', 'karta, molim', 'koja je lozinka',
    'koji broj', 'koliko je to', 'koliko košta noćenje', 'meni je hladno', 'meni je vruće', 'mogu li', 'mogu li platiti karticom',
    'mogu li probati', 'molim vas jednu kavu', 'molim vas vode', 'može račun', 'ne govorim hrvatski', 'ne radi', 'nemam novca',
    'oprostite, gdje je', 'ovdje je moj pasoš', 'prazna mi je baterija', 'samo gledam', 'samo malo', 'što je ovo',
    'trebam doktora', 'trebam policiju', 'trebam promijeniti novac', 'trebam punjač', 'trebam sobu', 'trebam taksi',
    'trebam vrećicu', 'učim hrvatski', 'ukrali su mi torbu', 'umoran sam', 'umorna sam', 'zadržite kusur', 'žedan sam',
    'žedna sam', 'želim platiti', 'zovi policiju', 'žurim se',
    # A1 / A2
    'hvala na posjeti', 'kako ide', 'kako provodiš vikend', 'koliko košta', 'mogu li dobiti račun', 'naravno da da',
    'nemam pojma', 'račun molim', 'sretan povratok', 'što radiš', 'ugodan ostatak dana', 'kavu s mlijekom',
    # «da li govorite engleski» лишаємо: 2026-10-20 його свідомо позначено як сербську форму (A2, register) — тест lexemes_fix_20261020
]
DEPRECATE = DEPRECATE_WORDS + DEPRECATE_SENTENCES


def q(s) -> str:
    return 'null' if s is None else "'" + str(s).replace("'", "''") + "'"


def qj(v) -> str:
    return q(json.dumps(v, ensure_ascii=False)) + '::jsonb'


def validate() -> list[str]:
    errors = []
    lows = [w.lower() for w in DEPRECATE]
    if len(lows) != len(set(lows)):
        errors.append('повтори в DEPRECATE')
    for n in NEW:
        if n['lemma'] in lows:
            errors.append(f'{n["lemma"]}: і новий, і DEPRECATED')
        for e in n['ex']:
            errors += [f'{n["lemma"]}: «{e}» — {m}' for m in check_example(n['lemma'], e)]
    for lemma, (_, new) in EXAMPLE_FIX.items():
        errors += [f'{lemma}: «{new}» — {m}' for m in check_example(lemma, new)]
    for e in HTJETI['ex']:
        errors += [f'htjeti: «{e}» — {m}' for m in check_example('htjeti', e)]
    return errors


def sql() -> str:
    new = [{'lemma': n['lemma'], 'norm': normalize(n['lemma']), 'tr': n['tr'], 'expl': n['expl'], 'ex': n['ex'],
            'lesson': n['lesson']} for n in NEW]
    exfix = [{'lemma': k, 'old': o, 'new': v} for k, (o, v) in EXAMPLE_FIX.items()]
    exercises = [{'id': i, 'field': f, 'old': (json.dumps(o, ensure_ascii=False) if isinstance(o, list) else o),
                  'new': (json.dumps(v, ensure_ascii=False) if isinstance(v, list) else v)}
                 for i, fields in EXERCISE_FIX.items() for f, (o, v) in fields.items()]
    dep = qj([w.lower() for w in DEPRECATE])
    lessons = ', '.join(q(x) + '::uuid' for x in (CAFE, RESTAURANT, CASH, WORKDAY_A1))
    return f"""-- =====================================================================
-- Чистка словника A0 / A1 і ввічливе «htio bih» як готовий вираз · 2026-11-04
-- Згенеровано: python3 -B scripts/gen_vocab_cleanup_20261104.py (не редагуйте вручну).
-- Рішення власника 2026-11-04 (аудит content/reviews/2026-11-04_a0_a1_audit.md, питання 5 і 6):
--
--   1. {len(new)} готові вирази в уроки A0 (умовний спосіб як граматика — на A2):
--      htio bih, htjela bih → «У кафе»; ja bih → «У ресторані»; biste li mogli → «На касі».
--   2. obaveza (сербська форма) — з уроку A1 «Мій робочий день» (obveza вже вчать в A0; зв’язок — у backup.lesson_items_20261104),
--      у 3 вправах цього уроку obaveza → obveza;
--      obavezno / obavezna → obvezno / obvezna в 3 прикладах; форми htjeti — hoću, hoćeš, hoće (було «želim»).
--   3. DEPRECATED (приховати, НЕ видалити) {len(DEPRECATE)} записів запасу: obaveza, njen (→ njezin), «ona (pl)», nulti
--      і {len(DEPRECATE_SENTENCES)} старих лем-речень першої версії (gdje je banka, trebam taksi…).
--      Лише ті, що не стоять у жодному уроці й не мають прогресу користувачів — інакше файл зупиниться.
--   Стара версія — у content_versions, запис — у content_reviews. Повторний запуск нічого не змінює.
-- Після нього: тест supabase/tests/vocab_cleanup.test.sql → «ALL TESTS PASSED».
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

create schema if not exists backup;
create table if not exists backup.lesson_items_20261104 (like public.lesson_items including defaults);
do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'lesson_items_20261104_pkey') then
    alter table backup.lesson_items_20261104 add constraint lesson_items_20261104_pkey primary key (id);
  end if;
end $$;
revoke all on backup.lesson_items_20261104 from anon, authenticated;

do $cleanup$
declare
  w record;
  x public.lexemes%rowtype;
  e public.exercises%rowtype;
  v_ord int;
  v_obveza uuid;
  v_new int := 0;
  v_fix int := 0;
  v_ex int := 0;
  v_dep int := 0;
  v_dep_list jsonb := {dep};
begin
  if (select count(*) from public.lessons where id in ({lessons}) and status = 'PUBLISHED') <> 4 then
    raise exception 'Не знайдено уроків «У кафе», «У ресторані», «На касі» (A0) і «Мій робочий день» (A1)';
  end if;

  -- 1. Готові вирази → уроки
  for w in select * from jsonb_to_recordset({qj(new)}) as t(lemma text, norm text, tr text, expl text, ex jsonb, lesson uuid)
  loop
    insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, ukrainian_explanation,
                                vocabulary_type, forms, examples, status, source)
    values (w.lemma, w.norm, 'hr', 'phrase', 'A0', w.tr, w.expl, 'formulaic', '{{}}'::jsonb, w.ex, 'PUBLISHED', {q(SOURCE)})
    on conflict do nothing;
    select * into x from public.lexemes where lower(lemma) = lower(w.lemma);
    if x.id is null or x.status <> 'PUBLISHED' then
      raise exception 'Вираз % є в словнику, але не опублікований — перевірте', w.lemma;
    end if;
    if not exists (select 1 from public.content_reviews where entity_id = x.id and notes = {q(NOTE_NEW)}) then
      insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
      values ('lexeme', x.id, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, {q(NOTE_NEW)});
    end if;
    if not exists (select 1 from public.lesson_items where lesson_id = w.lesson and item_type = 'lexeme' and item_id = x.id) then
      select coalesce(max(order_index), 0) + 1 into v_ord from public.lesson_items where lesson_id = w.lesson;
      insert into public.lesson_items (id, lesson_id, item_type, item_id, order_index, required, target_skill)
      values (gen_random_uuid(), w.lesson, 'lexeme', x.id, v_ord, true, 'vocabulary');
      v_new := v_new + 1;
    end if;
  end loop;

  -- 2a. obaveza — з уроку A1 «Мій робочий день» (obveza вчать в A0 «Дні тижня»; в уроці v3 — не більше 2 слів з A0);
  --     зв’язок «урок — слово» спершу копіюємо в backup.lesson_items_20261104
  select id into v_obveza from public.lexemes where lower(lemma) = 'obveza' and status = 'PUBLISHED';
  if v_obveza is null then raise exception 'Немає опублікованого слова obveza'; end if;
  insert into backup.lesson_items_20261104
  select li.* from public.lesson_items li
   where li.lesson_id = {q(WORKDAY_A1)}::uuid and li.item_type = 'lexeme'
     and li.item_id in (select id from public.lexemes where lower(lemma) = 'obaveza')
  on conflict do nothing;
  delete from public.lesson_items li
   where li.lesson_id = {q(WORKDAY_A1)}::uuid and li.item_type = 'lexeme'
     and li.item_id in (select id from public.lexemes where lower(lemma) = 'obaveza')
     and exists (select 1 from backup.lesson_items_20261104 b where b.id = li.id);
  if found then v_fix := v_fix + 1; end if;

  -- 2b. Приклади: obavezno → obvezno
  for w in select * from jsonb_to_recordset({qj(exfix)}) as t(lemma text, old text, new text)
  loop
    select * into x from public.lexemes where lower(lemma) = w.lemma and examples ? w.old;
    if x.id is not null then
      insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
      values ('lexeme', x.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = x.id), 0) + 1,
              to_jsonb(x), {q(NOTE_FIX)});
      update public.lexemes set examples = (select jsonb_agg(case when v = to_jsonb(w.old) then to_jsonb(w.new) else v end)
                                              from jsonb_array_elements(examples) v),
             version = coalesce(version, 1) + 1 where id = x.id;
      v_fix := v_fix + 1;
    end if;
  end loop;

  -- 2c. htjeti: правильні форми теперішнього часу й приклади
  select * into x from public.lexemes where lower(lemma) = 'htjeti' and status = 'PUBLISHED';
  if x.id is not null and (x.forms is distinct from {qj(HTJETI['forms'])} or x.examples is distinct from {qj(HTJETI['ex'])}) then
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', x.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = x.id), 0) + 1,
            to_jsonb(x), {q(NOTE_FIX)});
    update public.lexemes set forms = {qj(HTJETI['forms'])}, examples = {qj(HTJETI['ex'])}, version = coalesce(version, 1) + 1
     where id = x.id;
    v_fix := v_fix + 1;
  end if;

  -- 2d. Вправи уроку A1 «Мій робочий день»: obaveza → obveza
  for w in select * from jsonb_to_recordset({qj(exercises)}) as t(id uuid, field text, old text, new text)
  loop
    select * into e from public.exercises where id = w.id;
    continue when e.id is null;
    if (w.field = 'options' and e.options = w.old::jsonb) or (w.field = 'correct_answer' and e.correct_answer = w.old)
       or (w.field = 'question_text' and e.question_text = w.old) then
      insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
      values ('exercise', e.id, coalesce((select max(version) from public.content_versions where entity_type = 'exercise' and entity_id = e.id), 0) + 1,
              to_jsonb(e), {q(NOTE_FIX)})
      on conflict do nothing;
      update public.exercises set
        options = case when w.field = 'options' then w.new::jsonb else options end,
        correct_answer = case when w.field = 'correct_answer' then w.new else correct_answer end,
        question_text = case when w.field = 'question_text' then w.new else question_text end
       where id = e.id;
      v_ex := v_ex + 1;
    end if;
  end loop;

  -- 3. DEPRECATED: лише запас (не в уроці, не у вправі, без прогресу користувачів)
  if exists (select 1 from public.lexemes lx
              where lower(lx.lemma) in (select jsonb_array_elements_text(v_dep_list)) and lx.status = 'PUBLISHED'
                and (exists (select 1 from public.lesson_items li where li.item_type = 'lexeme' and li.item_id = lx.id)
                     or exists (select 1 from public.exercises ex where ex.lexeme_id = lx.id and ex.status = 'PUBLISHED')
                     or exists (select 1 from public.user_progress up where up.lexeme_id = lx.id))) then
    raise exception 'Слово зі списку DEPRECATED стоїть в уроці, у вправі або в повтореннях користувача: %',
      (select string_agg(lx.lemma, ', ') from public.lexemes lx
        where lower(lx.lemma) in (select jsonb_array_elements_text(v_dep_list)) and lx.status = 'PUBLISHED'
          and (exists (select 1 from public.lesson_items li where li.item_type = 'lexeme' and li.item_id = lx.id)
               or exists (select 1 from public.exercises ex where ex.lexeme_id = lx.id and ex.status = 'PUBLISHED')
               or exists (select 1 from public.user_progress up where up.lexeme_id = lx.id)));
  end if;
  for x in select * from public.lexemes
            where lower(lemma) in (select jsonb_array_elements_text(v_dep_list)) and status = 'PUBLISHED'
  loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', x.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = x.id), 0) + 1,
            to_jsonb(x), {q(NOTE_DEP)});
    update public.lexemes set status = 'DEPRECATED', version = coalesce(version, 1) + 1 where id = x.id;
    insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
    values ('lexeme', x.id, 'PUBLISHED', 'DEPRECATED', 'approved', 'human', '[]'::jsonb, {q(NOTE_DEP)});
    v_dep := v_dep + 1;
  end loop;

  -- Самоперевірка
  if (select count(*) from public.lesson_items li join public.lexemes lx on lx.id = li.item_id
       where li.item_type = 'lexeme' and lower(lx.lemma) in ({', '.join(q(n['lemma']) for n in NEW)}) and lx.status = 'PUBLISHED') < {len(NEW)} then
    raise exception 'Не всі готові вирази стоять в уроках';
  end if;
  if exists (select 1 from public.lesson_items li join public.lexemes lx on lx.id = li.item_id
              where li.item_type = 'lexeme' and lx.status <> 'PUBLISHED') then
    raise exception 'В уроці лишилося неопубліковане слово';
  end if;
  if exists (select 1 from public.lexemes where lower(lemma) in (select jsonb_array_elements_text(v_dep_list)) and status = 'PUBLISHED') then
    raise exception 'Не всі записи зі списку стали DEPRECATED';
  end if;
  if exists (select 1 from public.exercises ex join public.lesson_items li on li.item_type = 'exercise' and li.item_id = ex.id
              where ex.status = 'PUBLISHED' and (ex.question_text || coalesce(ex.correct_answer, '') || coalesce(ex.options::text, '')) ~* 'obavez') then
    raise exception 'У вправах уроків лишилося obavez…';
  end if;
  raise notice 'Готово: вирази в уроках +%, виправлено слів %, вправ %, DEPRECATED %', v_new, v_fix, v_ex, v_dep;
end
$cleanup$;

commit;
"""


def main():
    errors = validate()
    if errors:
        print('ПОМИЛКИ:', *errors, sep='\n  ')
        sys.exit(1)
    s = sql()
    OUT.write_text(s, encoding='utf-8')
    print(f'OK → {OUT.relative_to(ROOT)}: {len(s.encode()) // 1024} КБ, нових виразів {len(NEW)}, DEPRECATED {len(DEPRECATE)}')


if __name__ == '__main__':
    main()
