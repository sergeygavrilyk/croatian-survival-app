#!/usr/bin/env python3
"""
Стандартні відповідники (`standard_lexeme_id`) і чистка позначок у перекладах · 2026-11-13.

Останній крок «перед B1» плану маркування (docs/PROJECT_STATE.md, план діалогів §4.3; модель — LEARNING_SPEC §18):
  1. Розмовне чи регіональне слово, у якого в словнику є стандартний відповідник, отримує зв'язок
     standard_lexeme_id (pomidor → rajčica). Застосунок уже показує «стандартно: rajčica» (PR #28).
  2. Позначки, які дублюють мітки, прибираються з перекладу: «помідор (регіонально: Далмація, діалект; стандартно —
     rajčica)» → «помідор». Регістр і регіон — у register / regionality, відповідник — у зв'язку, пояснення
     (ukrainian_explanation) не змінюється.
  Не прибираємо: позначку одного зі значень багатозначного слова (kvadrat «квадратний метр (розмовно); квадрат»,
  pauk «евакуатор (розм.); павук» — мітки описують усе слово) і уточнення змісту (Donji grad «(Загреб)», fuži
  «(істрійська паста)», klapa «(далматинський … спів)», kajkavski «(діалект)»).
  3. Вправи, де старий переклад стоїть як відповідь, варіант чи в питанні «…«кілограм (розм.)»?», — той самий текст
     замінюється новим.
  Зв'язок — лише до PUBLISHED-слова з register = standard і regionality = general; лише від слова, яке саме не
  standard + general. Переклад міняється, лише якщо він дорівнює старому (чужу правку не перезаписує).
  Кожна зміна — стара версія в content_versions, запис у content_reviews, копія рядка до зміни — у backup
  (backup.lexemes_standard_links_20261113, backup.exercises_standard_links_20261113; skill croatian-content-review).
  Повторний запуск нічого не змінює.

Рішення власника 2026-11-13 (тести): «Ок, замінюй» — 3 перевірки в vocab_a2_fix.test.sql і lexemes_fix_20261020.test.sql
переходять з тексту перекладу на мітки й зв'язок standard_lexeme_id.

  python3 -B scripts/gen_lexeme_standard_links_20261113.py          → supabase/data_fixes/20261113_lexeme_standard_links.sql
                                                                     + content/reviews/2026-11-13_lexeme_standard_links.md
  python3 -B scripts/gen_lexeme_standard_links_20261113.py --check  → лише перевірка
Старі значення (old) — знімок робочої бази 2026-11-13 (лише читання, select).
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
sys.path.insert(0, str(HERE))
from lexeme_checks import translation_markers  # noqa: E402

SQL_OUT = ROOT / 'supabase' / 'data_fixes' / '20261113_lexeme_standard_links.sql'
REVIEW_OUT = ROOT / 'content' / 'reviews' / '2026-11-13_lexeme_standard_links.md'
TAG = 'lexeme_standard_links 2026-11-13'

# (лема, стандартний відповідник або None, старий переклад, новий переклад або None, новий register або None, чому)
ITEMS: list[tuple] = [
    ('pomidor', 'rajčica', 'помідор (регіонально: Далмація, діалект; стандартно — rajčica)', 'помідор', None,
     'далматинське слово; регіон і регістр — у мітках'),
    ('kapula', 'luk', 'цибуля (регіонально: Далмація, діалект; стандартно — luk)', 'цибуля', None,
     'далматинське слово; регіон і регістр — у мітках'),
    ('šugaman', 'ručnik', 'рушник (регіонально: Далмація, діалект; стандартно — ručnik)', 'рушник', None,
     'далматинське слово; регіон і регістр — у мітках'),
    ('ae', 'da', 'так, ага (регіонально: Далмація; сленг)', 'так, ага', None,
     'далматинський сленг; нейтрально — da (пояснення)'),
    ('onak', None, 'ну, типу; якось так (регіонально: Загреб; сленг)', 'ну, типу; якось так', None,
     'загребський сленг; onako в словнику немає — відповідник лише в поясненні'),
    ('kila', 'kilogram', 'кілограм (розм.)', 'кілограм', None, 'розмовне — у мітці colloquial'),
    ('gablec', None, 'гарячий обід на роботі (загреб.)', 'гарячий обід на роботі', None,
     'загребське слово — у мітці regionality = Zagreb; відповідника одним словом немає'),
    ('kesa', 'vrećica', 'пакет (регіонально)', 'пакет', 'colloquial',
     'у перекладі «регіонально», мітка була standard → colloquial; стандартно — vrećica; регіон — носію'),
    ('dućan', None, 'магазин (розмовно)', 'магазин', None,
     'dućan — стандартне слово (мітка standard); позначка «розмовно» суперечила мітці'),
    ('bilježnik', None, 'нотаріус (розм.)', 'нотаріус', None,
     '(javni) bilježnik — офіційний термін (мітка standard); позначка «розм.» суперечила мітці'),
    ('apoteka', 'ljekarna', 'аптека (розмовне; стандартно — ljekarna)', 'аптека', None,
     'DEPRECATED; розмовне — у мітці, відповідник — зв\'язок'),
    ('kompjuter', 'računalo', 'комп’ютер (розмовне; стандартно — računalo)', 'комп’ютер', None,
     'DEPRECATED; розмовне — у мітці, відповідник — зв\'язок'),
    ('da li govorite engleski', 'govorite li engleski',
     'чи розмовляєте ви англійською (сербська конструкція; хорватською — Govorite li engleski?)',
     'чи розмовляєте ви англійською', None, 'DEPRECATED; «сербська конструкція» — у поясненні, відповідник — зв\'язок'),
    # лише зв'язок — переклад уже без позначок
    ('cura', 'djevojka', None, None, None, 'розмовне «дівчина»'),
    ('pegla', 'glačalo', None, None, None, 'розмовне (германізм)'),
    ('tastatura', 'tipkovnica', None, None, None, 'розмовне'),
    ('tegla', 'staklenka', None, None, None, 'розмовне'),
    ('kusur', 'ostatak', None, None, None, 'розмовне (туркізм) «решта»'),
    ('mušterija', 'kupac', None, None, None, 'розмовне (туркізм) «клієнт, покупець»'),
    ('mail', 'e-pošta', None, None, None, 'розмовне (англіцизм)'),
    ('kvart', 'gradska četvrt', None, None, None, 'розмовне «район міста»'),
    ('marenda', 'užina', None, None, None, 'далматинське «перекус»'),
]

# Для звіту: розмовні / регіональні слова, стандартного відповідника яких у словнику ще немає
NO_STANDARD_YET = [
    ('onak', 'onako'), ('gušt', 'užitak'), ('spiza', 'namirnice'), ('žmigavac', 'pokazivač smjera'),
    ('klima', 'klima-uređaj'), ('mikrovalna', 'mikrovalna pećnica'), ('kemijska', 'kemijska olovka'),
    ('crtić', 'crtani film'), ('deka', 'dekagram'), ('trenirka', 'trenerka'), ('šprica', 'štrcaljka'),
    ('pola kile', 'pola kilograma'), ('peglati', 'glačati'),
]
# Для звіту: у словнику є пара, але слово позначене standard (сумнівний регістр, звіт 2026-11-13_lexeme_labels.md §5)
DOUBT_PAIRS = [('advokat', 'odvjetnik'), ('aerodrom', 'zračna luka'), ('parking', 'parkiralište'),
               ('doktor', 'liječnik'), ('zubar', 'stomatolog')]
REGISTERS = {'standard', 'formal', 'informal', 'colloquial', 'slang', 'vulgar'}


def check() -> list[str]:
    errors = []
    seen = set()
    for k, std, old, new, reg, why in ITEMS:
        if k in seen:
            errors.append(f'{k}: повтор')
        seen.add(k)
        if k != k.lower() or (std and std != std.lower()):
            errors.append(f'{k}: ключі — малими (lower(lemma))')
        if std == k:
            errors.append(f'{k}: відповідник — саме слово')
        if (old is None) != (new is None):
            errors.append(f'{k}: old і new — разом')
        if new is not None:
            if new == old:
                errors.append(f'{k}: новий переклад = старий')
            if translation_markers(new):
                errors.append(f'{k}: у новому перекладі лишилась позначка: {translation_markers(new)}')
            if not translation_markers(old):
                errors.append(f'{k}: у старому перекладі немає позначки — навіщо міняти?')
            if not re.search(r'[Ѐ-ӿ]', new) or re.search(r'[A-Za-z]', new):
                errors.append(f'{k}: новий переклад — українською, без латиниці')
        if reg is not None and reg not in REGISTERS:
            errors.append(f'{k}: register {reg}')
        if not std and new is None:
            errors.append(f'{k}: нічого не змінює')
        if not why:
            errors.append(f'{k}: без причини')
    for kvadrat in ('квадратний метр (розмовно); квадрат', 'евакуатор (розм.); павук'):
        if translation_markers(kvadrat):
            errors.append(f'translation_markers не має чіпати позначку одного зі значень: {kvadrat}')
    return errors


def q(s: str) -> str:
    return s.replace("'", "''")


def build_sql() -> str:
    data = json.dumps([{'k': k, 'std': std, 'old_tr': old, 'new_tr': new, 'reg': reg, 'why': why}
                       for k, std, old, new, reg, why in ITEMS], ensure_ascii=False)
    n_links = sum(1 for i in ITEMS if i[1])
    n_tr = sum(1 for i in ITEMS if i[3])
    n_reg = sum(1 for i in ITEMS if i[4])
    reason = (f'{TAG}: стандартний відповідник (standard_lexeme_id) і переклад без позначок, які дублюють мітки '
              f'(LEARNING_SPEC §18); скрипт scripts/gen_lexeme_standard_links_20261113.py')
    return f"""-- =====================================================================
-- Стандартні відповідники (standard_lexeme_id) і чистка позначок у перекладах · 2026-11-13
-- Згенеровано: python3 -B scripts/gen_lexeme_standard_links_20261113.py (не редагуйте вручну).
-- Модель — docs/LEARNING_SPEC.md §18; останній крок «перед B1» плану маркування (docs/PROJECT_STATE.md).
-- Потрібні M24 (standard_lexeme_id) і M25 (мітки обов'язкові).
-- Що робить:
--   1. {n_links} зв'язків «розмовне / регіональне → стандартне» (pomidor → rajčica, kila → kilogram, tegla → staklenka…).
--      Зв'язок — лише до PUBLISHED-слова з register = standard і regionality = general.
--   2. {n_tr} перекладів без позначок, які дублюють мітки («помідор (регіонально: Далмація…; стандартно — rajčica)» →
--      «помідор»); переклад міняється, лише якщо він дорівнює старому. Пояснення (ukrainian_explanation) не змінює.
--   3. {n_reg} регістр: kesa standard → colloquial (у перекладі було «регіонально»).
--   4. Вправи: старий переклад у відповіді, варіантах чи питанні («…«кілограм (розм.)»?») → новий.
--   Кожна зміна — стара версія в content_versions, запис у content_reviews; копія рядка до зміни — у
--   backup.lexemes_standard_links_20261113 / backup.exercises_standard_links_20261113. Повторний запуск нічого не змінює.
-- Звіт: content/reviews/2026-11-13_lexeme_standard_links.md. Тест: supabase/tests/lexeme_standard_links.test.sql.
-- Очікуване повідомлення (робоча база): «Готово: слів змінено {len(ITEMS)}, зв'язків {n_links}, перекладів {n_tr},
--   регістр {n_reg}, вправ 4, уже було 0, немає в базі 0, немає відповідника 0, переклад змінено раніше 0».
-- =====================================================================

begin;

create schema if not exists backup;
create table if not exists backup.lexemes_standard_links_20261113 as select * from public.lexemes where false;
create table if not exists backup.exercises_standard_links_20261113 as select * from public.exercises where false;

do $fix$
declare
  w record;
  x public.lexemes%rowtype;
  e public.exercises%rowtype;
  v_std uuid;
  v_new_std uuid;
  v_tr text;
  v_reg text;
  v_opts jsonb;
  v_changed int := 0;
  v_links int := 0;
  v_tr_n int := 0;
  v_reg_n int := 0;
  v_ex int := 0;
  v_same int := 0;
  v_missing int := 0;
  v_std_missing int := 0;
  v_tr_other int := 0;
  v_bad int;
  c_reason constant text := '{q(reason)}';
begin
  if not exists (select 1 from information_schema.columns where table_schema = 'public' and table_name = 'lexemes'
                   and column_name = 'standard_lexeme_id') then
    raise exception 'Спершу міграція M24 (20261113100000_m24_lexeme_labels.sql): колонки standard_lexeme_id ще немає';
  end if;

  for w in select * from jsonb_to_recordset('{q(data)}'::jsonb)
             as t(k text, std text, old_tr text, new_tr text, reg text, why text)
  loop
    select * into x from public.lexemes where lower(lemma) = w.k;
    if x.id is null then
      v_missing := v_missing + 1;
      continue;
    end if;

    -- стандартний відповідник
    v_std := null;
    if w.std is not null then
      select id into v_std from public.lexemes
       where lower(lemma) = w.std and status = 'PUBLISHED' and register = 'standard' and regionality = 'general';
      if v_std is null then
        v_std_missing := v_std_missing + 1;
      end if;
    end if;
    v_new_std := coalesce(v_std, x.standard_lexeme_id);

    -- переклад: лише якщо він досі той, що в знімку
    v_tr := x.ukrainian_translation;
    if w.new_tr is not null then
      if x.ukrainian_translation = w.old_tr then
        v_tr := w.new_tr;
      elsif x.ukrainian_translation is distinct from w.new_tr then
        v_tr_other := v_tr_other + 1;
      end if;
    end if;

    -- регістр: лише якщо слово ще standard
    v_reg := x.register;
    if w.reg is not null and x.register = 'standard' then
      v_reg := w.reg;
    end if;

    if v_new_std is not distinct from x.standard_lexeme_id and v_tr is not distinct from x.ukrainian_translation
       and v_reg is not distinct from x.register then
      v_same := v_same + 1;
      continue;
    end if;

    insert into backup.lexemes_standard_links_20261113 select * from public.lexemes where id = x.id;
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', x.id, coalesce((select max(version) from public.content_versions
                                      where entity_type = 'lexeme' and entity_id = x.id), 0) + 1,
            to_jsonb(x), c_reason || ' — ' || w.why);
    update public.lexemes
       set standard_lexeme_id = v_new_std, ukrainian_translation = v_tr, register = v_reg,
           version = coalesce(version, 1) + 1, updated_at = now()
     where id = x.id;
    insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
    values ('lexeme', x.id, x.status, x.status, 'auto_passed', 'script',
            jsonb_build_array(jsonb_build_object('standard_lemma', w.std, 'ukrainian_translation', v_tr, 'register', v_reg)),
            c_reason || ' — ' || w.why);
    v_changed := v_changed + 1;
    if v_new_std is distinct from x.standard_lexeme_id then v_links := v_links + 1; end if;
    if v_reg is distinct from x.register then v_reg_n := v_reg_n + 1; end if;

    -- вправи зі старим перекладом
    if v_tr is distinct from x.ukrainian_translation then
      v_tr_n := v_tr_n + 1;
      for e in select * from public.exercises ex
                where ex.correct_answer = x.ukrainian_translation
                   or (jsonb_typeof(ex.options) = 'array' and ex.options ? x.ukrainian_translation)
                   or ex.question_text like '%«' || x.ukrainian_translation || '»%'
      loop
        v_opts := e.options;
        if jsonb_typeof(e.options) = 'array' then
          select jsonb_agg(case when o.value = to_jsonb(x.ukrainian_translation) then to_jsonb(v_tr) else o.value end
                           order by o.ord)
            into v_opts
            from jsonb_array_elements(e.options) with ordinality as o(value, ord);
          if (select count(*) from jsonb_array_elements(v_opts)) <> (select count(distinct value) from jsonb_array_elements(v_opts)) then
            raise exception 'Вправа %: після заміни перекладу «%» варіанти повторюються', e.id, x.ukrainian_translation;
          end if;
        end if;
        insert into backup.exercises_standard_links_20261113 select * from public.exercises where id = e.id;
        insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
        values ('exercise', e.id, coalesce((select max(version) from public.content_versions
                                            where entity_type = 'exercise' and entity_id = e.id), 0) + 1,
                to_jsonb(e), c_reason || ' — переклад слова ' || x.lemma || ' без позначки');
        update public.exercises
           set correct_answer = case when correct_answer = x.ukrainian_translation then v_tr else correct_answer end,
               options = v_opts,
               question_text = replace(question_text, '«' || x.ukrainian_translation || '»', '«' || v_tr || '»')
         where id = e.id;
        insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
        values ('exercise', e.id, e.status, e.status, 'auto_passed', 'script', '[]'::jsonb,
                c_reason || ' — переклад слова ' || x.lemma || ' без позначки');
        v_ex := v_ex + 1;
      end loop;
    end if;
  end loop;

  -- Самоперевірка: зв'язок — лише «нестандартне → стандартне опубліковане»
  select count(*) into v_bad
    from public.lexemes l join public.lexemes s on s.id = l.standard_lexeme_id
   where s.status <> 'PUBLISHED' or s.register <> 'standard' or s.regionality <> 'general'
      or (l.register = 'standard' and l.regionality = 'general');
  if v_bad > 0 then
    raise exception 'Зв''язків standard_lexeme_id не за правилом: %', v_bad;
  end if;
  raise notice 'Готово: слів змінено %, зв''язків %, перекладів %, регістр %, вправ %, уже було %, немає в базі %, немає відповідника %, переклад змінено раніше %',
    v_changed, v_links, v_tr_n, v_reg_n, v_ex, v_same, v_missing, v_std_missing, v_tr_other;
end
$fix$;

commit;
"""


def build_review() -> str:
    lines = [
        '# Стандартні відповідники й переклади без позначок — звіт (2026-11-13)',
        '',
        'Пакет `supabase/data_fixes/20261113_lexeme_standard_links.sql` (генератор '
        '`scripts/gen_lexeme_standard_links_20261113.py`). Модель — `docs/LEARNING_SPEC.md` §18: регістр і регіон — '
        'у мітках, стандартний відповідник — зв\'язок `standard_lexeme_id` (на картці й у слові уроку — '
        '«стандартно: *rajčica*»), переклад — лише значення.',
        '',
        '## 1. Що змінюється',
        '',
        '| Слово | Стандартно | Переклад було → стало | Чому |',
        '|---|---|---|---|',
    ]
    for k, std, old, new, reg, why in ITEMS:
        tr = f'{old} → **{new}**' if new else '—'
        if reg:
            tr += f'; регістр standard → `{reg}`'
        lines.append(f'| *{k}* | {"*" + std + "*" if std else "—"} | {tr} | {why} |')
    lines += [
        '',
        f'Разом: зв\'язків {sum(1 for i in ITEMS if i[1])}, перекладів {sum(1 for i in ITEMS if i[3])}, '
        f'регістр {sum(1 for i in ITEMS if i[4])}. Вправи зі старим перекладом (відповідь, варіант, питання) — '
        'той самий текст замінено новим (у робочій базі 4: *gablec* ×2, *bilježnik*, *kila*).',
        '',
        '## 2. Що лишається в перекладі',
        '',
        '- Позначка **одного зі значень** багатозначного слова: *kvadrat* «квадратний метр (розмовно); квадрат», '
        '*pauk* «евакуатор (розм.); павук» — мітки описують усе слово, тож позначку значення лишаємо.',
        '- Уточнення змісту: *Donji grad* «(Загреб)», *fuži* «(істрійська паста)», *klapa* «(далматинський … спів)», '
        '*kajkavski* «(діалект)», *čika* «(до старшого чоловіка, дитяче)».',
        '- Пояснення (`ukrainian_explanation`) не змінюється: «Регіонально (Далмація), діалектне слово. У стандартній '
        'хорватській — rajčica».',
        '',
        '## 3. Відповідника в словнику ще немає',
        '',
        'Розмовні й регіональні слова, стандартного відповідника яких немає серед опублікованих слів — зв\'язок '
        'з\'явиться, коли відповідник додадуть (наприклад, у B1): '
        + ', '.join(f'*{a}* → *{b}*' for a, b in NO_STANDARD_YET) + '. Без відповідника за змістом: *fjaka*, *gablec*, '
        '*buvljak*, *papirologija*, *šalabahter*, *benzinac*.',
        '',
        '## 4. Що варто глянути носію',
        '',
        '- *kesa* — у перекладі було «регіонально», мітка `standard`; поставлено `colloquial` + «стандартно: *vrećica*». '
        'Який регіон (Славонія?) і чи розмовне — носію.',
        '- *dućan*, *bilježnik* — позначку «розмовно» / «розм.» прибрано, бо обидва — стандартні слова (мітка `standard`, '
        'звіт `2026-11-13_lexeme_labels.md` §5). Якщо носій скаже інакше — окремим пакетом.',
        '- *mail* → *e-pošta*: у мовленні *mail* означає й лист, а *e-pošta* — і пошту, і лист; чи краще *e-poruka*?',
        '- Пари, де слово позначене `standard` (сумнівний регістр), **без зв\'язку**: '
        + ', '.join(f'*{a}* — *{b}*' for a, b in DOUBT_PAIRS)
        + '. Якщо носій скаже «розмовне» — змінимо регістр і додамо зв\'язок одним пакетом.',
        '',
    ]
    return '\n'.join(lines)


def main() -> None:
    errors = check()
    if errors:
        print('ПОМИЛКИ:\n' + '\n'.join(errors))
        sys.exit(1)
    print(f'Перевірка: {len(ITEMS)} слів, помилок 0')
    if '--check' in sys.argv:
        return
    SQL_OUT.write_text(build_sql(), encoding='utf-8')
    REVIEW_OUT.write_text(build_review(), encoding='utf-8')
    print(f'Записано: {SQL_OUT.relative_to(ROOT)}, {REVIEW_OUT.relative_to(ROOT)}')


if __name__ == '__main__':
    main()
