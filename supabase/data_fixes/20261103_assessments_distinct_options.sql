-- =====================================================================
-- Перевірки рівня A0 / A1: хибні варіанти без повторів у тесті · 2026-11-03
-- Згенеровано: python3 -B scripts/gen_assessment_dedupe_20261103.py (не редагуйте вручну).
--
--   * 18 завдань у 13 тестах (a0-final, a0-m01, a0-m02, a0-m10, a1-m02, a1-m03, a1-m04, a1-m05, a1-m07, a1-m08, a1-m11, a1-m12, a1-m13):
--     хибний варіант повторював хибний варіант іншого завдання або правильну відповідь іншого завдання.
--   * Повтор замінено запасним хибним варіантом того самого завдання (ті самі правила добору, що й у генераторі).
--   * Змінюються лише варіанти (options); id, місце, правильна відповідь і решта тесту — ті самі, старі спроби чинні.
--     Стара версія завдання → content_versions, запис у content_reviews. Нічого не видаляється.
--   * Повторний запуск безпечний: завдання з новими варіантами пропускається.
-- Після нього тест supabase/tests/assessments_distinct_options.test.sql має пройти («ALL TESTS PASSED»).
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

do $fix$
declare
  d record;
  r public.assessment_items%rowtype;
  v_changed int := 0;
  v_skipped int := 0;
begin
  for d in select * from jsonb_to_recordset('[
{
"id": "562c650a-a7fb-5603-aced-823a529bae8f",
"slug": "a0-m01",
"ord": 2,
"old": [
"Дякую, ви дуже люб’язні.",
"Тоді сідайте й відпочиньте.",
"Дякую, і тобі. Передавай привіт мамі!"
],
"new": [
"Два роки тому.",
"Тоді сідайте й відпочиньте.",
"Дякую, і тобі. Передавай привіт мамі!"
]
},
{
"id": "2c55c6c0-05c2-5192-96f0-bb99d979b4c8",
"slug": "a0-m02",
"ord": 5,
"old": [
"Da, ali polako. Ne brinite!",
"Čaj, molim. Šalicu toplog čaja.",
"Deset i dvanaest."
],
"new": [
"Da, ali polako. Ne brinite!",
"Sedamnaest ili devetnaest.",
"Deset i dvanaest."
]
},
{
"id": "ca6df188-4ef1-5c52-b99c-bf69d1357901",
"slug": "a0-m10",
"ord": 2,
"old": [
"До готелю «Парк», але в мене вимкнувся телефон.",
"Копія, але засвідчена.",
"Перепрошую! Зараз вам їх принесу."
],
"new": [
"Чудово, побачимося в понеділок!",
"Копія, але засвідчена.",
"Перепрошую! Зараз вам їх принесу."
]
},
{
"id": "17d4dad9-146a-59de-ae29-592ae85c537d",
"slug": "a0-m10",
"ord": 5,
"old": [
"Dogodila se prometna nesreća! Jedan čovjek je ozlijeđen.",
"Vani, ispred zgrade.",
"Otprilike četiristo."
],
"new": [
"Dogodila se prometna nesreća! Jedan čovjek je ozlijeđen.",
"Vani, ispred zgrade.",
"On je moj susjed Marko. A ona je njegova žena."
]
},
{
"id": "adb9f6f3-4143-52da-96b4-efac02ed3b3a",
"slug": "a0-final",
"ord": 12,
"old": [
"U subotu radim, ali u nedjelju sam slobodna.",
"Ne, nazvali ste krivi broj.",
"Dosta je. Hvala ti!"
],
"new": [
"U subotu radim, ali u nedjelju sam slobodna.",
"Ne, nazvali ste krivi broj.",
"Sladoled ovdje, a tortu za van."
]
},
{
"id": "95c4f649-4976-5def-ac0c-16fe13a13234",
"slug": "a1-m02",
"ord": 5,
"old": [
"U ladici. Stavi i salvete pored tanjura.",
"Svaki drugi dan, a vikendom trčim uz more.",
"Subotom se izležavam, a nedjeljom idem na izlet."
],
"new": [
"U ladici. Stavi i salvete pored tanjura.",
"Treba. Uzmi metlu i krpu, hvala što mi pomažeš!",
"Subotom se izležavam, a nedjeljom idem na izlet."
]
},
{
"id": "0fd92cef-7905-521f-bfcd-6d8f2a652b39",
"slug": "a1-m02",
"ord": 7,
"old": [
"Daj mi žličicu.",
"Što je danas sezonsko?",
"Imate li plodove mora?"
],
"new": [
"Možemo li se dogovoriti za ponedjeljak?",
"Što je danas sezonsko?",
"Imate li plodove mora?"
]
},
{
"id": "8f9ffa20-4e01-555d-84ec-bd9194b44090",
"slug": "a1-m03",
"ord": 2,
"old": [
"Івано, тобі подобається ця сукня?",
"Гарна ідея. А татові наручний годинник?",
"Шарф теж треба?"
],
"new": [
"Івано, тобі подобається ця сукня?",
"Івано, як мені ця куртка?",
"Шарф теж треба?"
]
},
{
"id": "f913c8de-abde-56cc-a435-6755ccdd25ca",
"slug": "a1-m04",
"ord": 1,
"old": [
"Є, але він дорожчий — двадцять п’ять євро.",
"Зазвичай завтра. Ми надішлемо її на вашу адресу.",
"Так, квиток в один бік і бронювання місця."
],
"new": [
"Це нормально, воно ще мале. Купіть йому дряпку.",
"Зазвичай завтра. Ми надішлемо її на вашу адресу.",
"Так, квиток в один бік і бронювання місця."
]
},
{
"id": "579a2465-46c1-5ab8-a2e3-0a71ec339d9e",
"slug": "a1-m05",
"ord": 2,
"old": [
"Де ти хочеш полицю — над ліжком?",
"Дякую вам. А вам, може, допомогти зі сходами?",
"Добрий день, де можна прочитати правила будинку?"
],
"new": [
"Можна мені взяти м’яч у садок?",
"Дякую вам. А вам, може, допомогти зі сходами?",
"Добрий день, де можна прочитати правила будинку?"
]
},
{
"id": "232f77b8-7a58-5fd7-be96-cd9a3a2188db",
"slug": "a1-m07",
"ord": 3,
"old": [
"Клацни мишкою на налаштування, а потім на «Оновлення».",
"Не потрібен, кабель у коробці.",
"Пише, що його треба перезавантажити."
],
"new": [
"Клацни мишкою на налаштування, а потім на «Оновлення».",
"І поставте мені зимові шини, будь ласка.",
"Пише, що його треба перезавантажити."
]
},
{
"id": "fa315a4e-fbd0-59b3-933f-e86972fa3cba",
"slug": "a1-m07",
"ord": 7,
"old": [
"Zaboravila sam lozinku.",
"Poslao sam ti mail.",
"Učitajte dokument."
],
"new": [
"Zaboravila sam lozinku.",
"Poslao sam ti mail.",
"Koliki je polog?"
]
},
{
"id": "3b746ef7-ea26-5d3c-a6cb-58d817451b2d",
"slug": "a1-m08",
"ord": 7,
"old": [
"Posjekao sam se.",
"Ovo je hitan slučaj.",
"Vježbajte svaki dan."
],
"new": [
"Sviđa li ti se ova haljina?",
"Ovo je hitan slučaj.",
"Vježbajte svaki dan."
]
},
{
"id": "531b44bc-6f6f-5c14-825e-6c2dc7bfb9d3",
"slug": "a1-m11",
"ord": 6,
"old": [
"Дякую! У нас звичай роззуватися.",
"І в нас так, але господиня завжди дасть тобі тапочки.",
"Чоловіки тиснуть руки, а друзі цілуються двічі в щоку."
],
"new": [
"А Тіла Христового? Воно завжди в четвер.",
"І в нас так, але господиня завжди дасть тобі тапочки.",
"Чоловіки тиснуть руки, а друзі цілуються двічі в щоку."
]
},
{
"id": "d95b4a9e-15f2-59b0-a183-0886922b8976",
"slug": "a1-m12",
"ord": 1,
"old": [
"Улітку є й безкоштовні лекції в університеті.",
"Запишуся на курс просунутого рівня, а ще мені потрібне визнання атестата.",
"Не панікуємо. Ховаємося під стіл і чекаємо, поки скінчиться."
],
"new": [
"Улітку є й безкоштовні лекції в університеті.",
"Добрий день, я телефоную щодо оголошення про трикімнатну квартиру.",
"Не панікуємо. Ховаємося під стіл і чекаємо, поки скінчиться."
]
},
{
"id": "d9ba1a4c-1b8b-5bc3-9df9-01ecc08e319c",
"slug": "a1-m12",
"ord": 3,
"old": [
"Засвідчити можна в нотаріуса, це поруч.",
"Добрий день, мені потрібні робочі зошити для другого класу.",
"Я склала! Перед іспитом я вчилася щодня."
],
"new": [
"Засвідчити можна в нотаріуса, це поруч.",
"Скріплю їх скріпкою й покладу в синю папку.",
"Я склала! Перед іспитом я вчилася щодня."
]
},
{
"id": "b70f1bcd-21e5-5a45-bf23-dd257c6dd6de",
"slug": "a1-m12",
"ord": 6,
"old": [
"Запишуся на курс просунутого рівня, а ще мені потрібне визнання атестата.",
"Чудово, так я повторю матеріал.",
"Я склала! Перед іспитом я вчилася щодня."
],
"new": [
"Запишуся на курс просунутого рівня, а ще мені потрібне визнання атестата.",
"Чудово, так я повторю матеріал.",
"Так, після курсу всі слухачі складають іспит."
]
},
{
"id": "e3f181ef-42c9-5997-a9a2-16b705f64a55",
"slug": "a1-m13",
"ord": 6,
"old": [
"Перше Різдво з новими друзями, ми були як сім’я.",
"Дуже. Іноді в мене ностальгія, я згадую маму й наш сад.",
"Я волонтерила в організації, а там чудова спільнота."
],
"new": [
"Перше Різдво з новими друзями, ми були як сім’я.",
"Дуже. Іноді в мене ностальгія, я згадую маму й наш сад.",
"Вчіть мову з першого дня. За рік вам буде набагато легше!"
]
}
]'::jsonb) as t(id uuid, slug text, ord int, old jsonb, new jsonb)
  loop
    select * into r from public.assessment_items where id = d.id;
    if not found or r.status <> 'PUBLISHED' then
      raise exception 'Завдання % #% (%) не знайдено серед опублікованих — спершу пакети перевірок A0 v4 / A1 v3', d.slug, d.ord, d.id;
    end if;
    if r.options = d.new then
      v_skipped := v_skipped + 1;
      continue;
    end if;
    if r.options is distinct from d.old then
      raise exception 'Завдання % #%: варіанти не такі, як очікувалось (%), — нічого не змінено', d.slug, d.ord, r.options;
    end if;
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('assessment_item', r.id,
            coalesce((select max(version) from public.content_versions where entity_type = 'assessment_item' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'assessments_distinct_options_20261103: хибний варіант повторювався в тесті — стара версія завдання');
    update public.assessment_items
       set options = d.new, version = coalesce(version, 1) + 1, updated_at = now()
     where id = r.id;
    insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
    values ('assessment_item', r.id, r.status, r.status, 'auto_passed', 'script',
            jsonb_build_array(jsonb_build_object('old', d.old, 'new', d.new)), 'Хибний варіант повторювався в тесті (в іншому завданні або як правильна відповідь іншого завдання) — замінено запасним варіантом того самого завдання (scripts/gen_assessment_dedupe_20261103.py). Потрібна перевірка носієм.');
    v_changed := v_changed + 1;
  end loop;
  raise notice 'Замінено варіантів у завданнях: %, уже були нові: %', v_changed, v_skipped;
end
$fix$;

-- Самоперевірка: у жодному опублікованому тесті модуля / середини / фіналу хибний варіант не повторюється
-- (ні як хибний варіант іншого завдання, ні як правильна відповідь іншого завдання). Інакше — усе відкочується.
do $$
declare v_bad int;
begin
  select count(*) into v_bad from (
    select w.assessment_id, w.opt
      from (select i.id, i.assessment_id, lower(btrim(e)) as opt
              from public.assessment_items i join public.assessments a on a.id = i.assessment_id,
                   jsonb_array_elements_text(i.options) with ordinality as x(e, n)
             where a.status = 'PUBLISHED' and i.status = 'PUBLISHED' and a.kind in ('module', 'mid', 'final') and a.cefr in ('A0', 'A1')
               and i.item_type = 'multiple_choice' and n - 1 <> i.correct_index
               and i.skill <> 'reading') w
     group by w.assessment_id, w.opt
    having count(*) > 1
    union all
    select w.assessment_id, w.opt
      from (select i.id, i.assessment_id, lower(btrim(e)) as opt
              from public.assessment_items i join public.assessments a on a.id = i.assessment_id,
                   jsonb_array_elements_text(i.options) with ordinality as x(e, n)
             where a.status = 'PUBLISHED' and i.status = 'PUBLISHED' and a.kind in ('module', 'mid', 'final') and a.cefr in ('A0', 'A1')
               and i.item_type = 'multiple_choice' and n - 1 <> i.correct_index
               and i.skill <> 'reading') w
      join (select i.id, i.assessment_id,
                   lower(btrim(case when i.item_type = 'multiple_choice' then i.options ->> i.correct_index else i.answer_text end)) as ans
              from public.assessment_items i
             where i.status = 'PUBLISHED') c
        on c.assessment_id = w.assessment_id and c.id <> w.id and c.ans = w.opt
  ) bad;
  if v_bad > 0 then raise exception 'Лишились повтори хибних варіантів у тестах: %', v_bad; end if;
  raise notice 'Готово: хибні варіанти в перевірках рівня A0 / A1 не повторюються';
end $$;

commit;
