-- =====================================================================
-- Тест рівня v1 (placement-v1): 24 питання — по 4 на A0, A1, A2, B1 і 8 на B2.
-- Якщо перші 16 питань уже додано, повторний запуск додасть лише нові (B2).
-- Згенеровано: scripts/gen_placement_v1.py. Перевірено: content/reviews/2026-10-12_placement_v1.md
-- Статус: NEEDS_REVIEW — користувачі НЕ бачать, доки власник не опублікує.
-- Ідемпотентно: повторний запуск нічого не дублює. Потребує M7.
-- =====================================================================
begin;

insert into public.assessments (slug, kind, title_ua, version, status, source)
values ('placement-v1', 'placement', 'Тест рівня', 1, 'NEEDS_REVIEW', 'claude_placement_v1')
on conflict (slug) do nothing;

insert into public.assessment_items (assessment_id, order_index, cefr, skill, prompt_ua, prompt_hr, options, correct_index, explanation_ua, status, source)
select a.id, 1, 'A0', 'vocabulary', 'Як хорватською «дякую»?', null, '["molim", "oprostite", "hvala", "bok"]'::jsonb, 2, '«Hvala» — дякую. «Molim» — будь ласка / прошу, «bok» — привіт / бувай, «oprostite» — вибачте.', 'NEEDS_REVIEW', 'claude_placement_v1'
from public.assessments a where a.slug = 'placement-v1'
on conflict (assessment_id, order_index) do nothing;
insert into public.assessment_items (assessment_id, order_index, cefr, skill, prompt_ua, prompt_hr, options, correct_index, explanation_ua, status, source)
select a.id, 2, 'A0', 'vocabulary', 'Що означає ця фраза?', 'Dobar dan!', '["Добраніч!", "Доброго ранку!", "До побачення!", "Добрий день!"]'::jsonb, 3, '«Dobar dan» — добрий день. Добраніч — «laku noć», до побачення — «doviđenja», доброго ранку — «dobro jutro».', 'NEEDS_REVIEW', 'claude_placement_v1'
from public.assessments a where a.slug = 'placement-v1'
on conflict (assessment_id, order_index) do nothing;
insert into public.assessment_items (assessment_id, order_index, cefr, skill, prompt_ua, prompt_hr, options, correct_index, explanation_ua, status, source)
select a.id, 3, 'A0', 'vocabulary', 'Як хорватською «ні»?', null, '["nema", "nije", "da", "ne"]'::jsonb, 3, '«Ne» — ні. «Da» — так, «nije» — (він/вона) не є, «nema» — немає.', 'NEEDS_REVIEW', 'claude_placement_v1'
from public.assessments a where a.slug = 'placement-v1'
on conflict (assessment_id, order_index) do nothing;
insert into public.assessment_items (assessment_id, order_index, cefr, skill, prompt_ua, prompt_hr, options, correct_index, explanation_ua, status, source)
select a.id, 4, 'A0', 'reading', 'Вас питають: «Kako se zovete?» Що саме питають?', 'Kako se zovete?', '["Звідки ви?", "Скільки вам років?", "Де ви живете?", "Як вас звати?"]'::jsonb, 3, '«Kako se zovete?» — як вас звати? (ввічлива форма). Звідки ви — «Odakle ste?».', 'NEEDS_REVIEW', 'claude_placement_v1'
from public.assessments a where a.slug = 'placement-v1'
on conflict (assessment_id, order_index) do nothing;
insert into public.assessment_items (assessment_id, order_index, cefr, skill, prompt_ua, prompt_hr, options, correct_index, explanation_ua, status, source)
select a.id, 5, 'A1', 'grammar', 'Оберіть правильне слово.', 'Ja ___ iz Ukrajine.', '["smo", "si", "sam", "je"]'::jsonb, 2, 'Дієслово biti: ja sam, ti si, on/ona je, mi smo.', 'NEEDS_REVIEW', 'claude_placement_v1'
from public.assessments a where a.slug = 'placement-v1'
on conflict (assessment_id, order_index) do nothing;
insert into public.assessment_items (assessment_id, order_index, cefr, skill, prompt_ua, prompt_hr, options, correct_index, explanation_ua, status, source)
select a.id, 6, 'A1', 'vocabulary', 'Ви в кафе й хочете розрахуватися. Що скажете офіціанту?', null, '["Jelovnik, molim.", "Živjeli!", "Račun, molim.", "Dobar tek!"]'::jsonb, 2, '«Račun» — рахунок. «Jelovnik» — меню, «Dobar tek!» — смачного, «Živjeli!» — будьмо (тост).', 'NEEDS_REVIEW', 'claude_placement_v1'
from public.assessments a where a.slug = 'placement-v1'
on conflict (assessment_id, order_index) do nothing;
insert into public.assessment_items (assessment_id, order_index, cefr, skill, prompt_ua, prompt_hr, options, correct_index, explanation_ua, status, source)
select a.id, 7, 'A1', 'grammar', 'Оберіть правильну форму слова «brat».', 'Imam dva ___.', '["brat", "braće", "brata", "braća"]'::jsonb, 2, 'Після dva, tri, četiri вживається родовий відмінок однини: dva brata.', 'NEEDS_REVIEW', 'claude_placement_v1'
from public.assessments a where a.slug = 'placement-v1'
on conflict (assessment_id, order_index) do nothing;
insert into public.assessment_items (assessment_id, order_index, cefr, skill, prompt_ua, prompt_hr, options, correct_index, explanation_ua, status, source)
select a.id, 8, 'A1', 'reading', 'Коли працює аптека?', 'Ljekarna radi od 8 do 20 sati.', '["лише у вихідні", "з 8:00 до 20:00", "з 8:00 до 12:00", "цілодобово"]'::jsonb, 1, '«Od 8 do 20 sati» — з восьмої до двадцятої години.', 'NEEDS_REVIEW', 'claude_placement_v1'
from public.assessments a where a.slug = 'placement-v1'
on conflict (assessment_id, order_index) do nothing;
insert into public.assessment_items (assessment_id, order_index, cefr, skill, prompt_ua, prompt_hr, options, correct_index, explanation_ua, status, source)
select a.id, 9, 'A2', 'grammar', 'Як сказати «Учора я ходив у кіно»?', 'Jučer ___ u kino.', '["sam išao", "ću ići", "bih išao", "idem"]'::jsonb, 0, 'Минулий час: sam + дієприкметник (išao / išla). «Idem» — теперішній, «ću ići» — майбутній, «bih išao» — умовний спосіб.', 'NEEDS_REVIEW', 'claude_placement_v1'
from public.assessments a where a.slug = 'placement-v1'
on conflict (assessment_id, order_index) do nothing;
insert into public.assessment_items (assessment_id, order_index, cefr, skill, prompt_ua, prompt_hr, options, correct_index, explanation_ua, status, source)
select a.id, 10, 'A2', 'grammar', 'Оберіть правильну форму слова «Zagreb».', 'Živim u ___.', '["Zagrebom", "Zagreb", "Zagreba", "Zagrebu"]'::jsonb, 3, 'Де? — «u» + місцевий відмінок: u Zagrebu.', 'NEEDS_REVIEW', 'claude_placement_v1'
from public.assessments a where a.slug = 'placement-v1'
on conflict (assessment_id, order_index) do nothing;
insert into public.assessment_items (assessment_id, order_index, cefr, skill, prompt_ua, prompt_hr, options, correct_index, explanation_ua, status, source)
select a.id, 11, 'A2', 'vocabulary', 'Що сталося?', 'Zaboravio sam ključ.', '["Я зачинив двері.", "Я знайшов ключ.", "Я забув ключ.", "Я загубив гаманець."]'::jsonb, 2, '«Zaboraviti» — забути, «ključ» — ключ. Загубити — «izgubiti», знайти — «naći».', 'NEEDS_REVIEW', 'claude_placement_v1'
from public.assessments a where a.slug = 'placement-v1'
on conflict (assessment_id, order_index) do nothing;
insert into public.assessment_items (assessment_id, order_index, cefr, skill, prompt_ua, prompt_hr, options, correct_index, explanation_ua, status, source)
select a.id, 12, 'A2', 'reading', 'Лікар пояснює, як приймати ліки. Як саме?', 'Uzimajte tablete dva puta dnevno nakon jela.', '["двічі на тиждень до їжі", "два дні поспіль", "двічі на день після їжі", "раз на день натщесерце"]'::jsonb, 2, '«Dva puta dnevno» — двічі на день, «nakon jela» — після їжі.', 'NEEDS_REVIEW', 'claude_placement_v1'
from public.assessments a where a.slug = 'placement-v1'
on conflict (assessment_id, order_index) do nothing;
insert into public.assessment_items (assessment_id, order_index, cefr, skill, prompt_ua, prompt_hr, options, correct_index, explanation_ua, status, source)
select a.id, 13, 'B1', 'grammar', 'Оберіть правильну форму.', 'Kad bih imao više vremena, ___ hrvatski svaki dan.', '["učim", "sam učio", "učit ću", "učio bih"]'::jsonb, 3, 'Умовний спосіб в обох частинах: «Kad bih imao…, učio bih…» — якби я мав…, я б учив…', 'NEEDS_REVIEW', 'claude_placement_v1'
from public.assessments a where a.slug = 'placement-v1'
on conflict (assessment_id, order_index) do nothing;
insert into public.assessment_items (assessment_id, order_index, cefr, skill, prompt_ua, prompt_hr, options, correct_index, explanation_ua, status, source)
select a.id, 14, 'B1', 'grammar', 'Оберіть правильне слово.', 'To je kolega ___ sam ti pričao.', '["kojem", "o kojem", "koji", "kojeg"]'::jsonb, 1, '«Pričati o nekome» — розповідати про когось: o kojem (місцевий відмінок).', 'NEEDS_REVIEW', 'claude_placement_v1'
from public.assessments a where a.slug = 'placement-v1'
on conflict (assessment_id, order_index) do nothing;
insert into public.assessment_items (assessment_id, order_index, cefr, skill, prompt_ua, prompt_hr, options, correct_index, explanation_ua, status, source)
select a.id, 15, 'B1', 'vocabulary', 'Як ввічливо попросити колегу перенести зустріч на завтра?', null, '["Nema sastanka sutra.", "Sastanak je sutra.", "Bismo li mogli pomaknuti sastanak za sutra?", "Pomakni sastanak!"]'::jsonb, 2, '«Bismo li mogli…?» — чи не могли б ми…? Умовний спосіб робить прохання ввічливим.', 'NEEDS_REVIEW', 'claude_placement_v1'
from public.assessments a where a.slug = 'placement-v1'
on conflict (assessment_id, order_index) do nothing;
insert into public.assessment_items (assessment_id, order_index, cefr, skill, prompt_ua, prompt_hr, options, correct_index, explanation_ua, status, source)
select a.id, 16, 'B1', 'reading', 'Що сталося з матчем?', 'Unatoč kiši, utakmica je održana prema planu.', '["Дощу не було.", "Матч перенесли на завтра.", "Матч скасували через дощ.", "Матч відбувся за планом, попри дощ."]'::jsonb, 3, '«Unatoč kiši» — попри дощ, «održana prema planu» — відбулася за планом.', 'NEEDS_REVIEW', 'claude_placement_v1'
from public.assessments a where a.slug = 'placement-v1'
on conflict (assessment_id, order_index) do nothing;
insert into public.assessment_items (assessment_id, order_index, cefr, skill, prompt_ua, prompt_hr, options, correct_index, explanation_ua, status, source)
select a.id, 17, 'B2', 'grammar', 'Оберіть правильну форму дієслова.', 'Dok sam ___ izvještaj, netko mi je ukrao bicikl.', '["pišem", "bih pisao", "napisao", "pisao"]'::jsonb, 3, '«Dok» + тривала дія → недоконаний вид: dok sam pisao. Доконаний «napisao» означає завершену дію і з «dok» тут не вживається.', 'NEEDS_REVIEW', 'claude_placement_v1'
from public.assessments a where a.slug = 'placement-v1'
on conflict (assessment_id, order_index) do nothing;
insert into public.assessment_items (assessment_id, order_index, cefr, skill, prompt_ua, prompt_hr, options, correct_index, explanation_ua, status, source)
select a.id, 18, 'B2', 'grammar', 'Оберіть правильну форму.', 'Da sam to znao ranije, ___ drugačije.', '["postupam", "postupio bih", "postupit ću", "postupio sam"]'::jsonb, 1, 'Нереальна умова в минулому: «Da sam znao…, postupio bih…» — якби я знав…, я б учинив…', 'NEEDS_REVIEW', 'claude_placement_v1'
from public.assessments a where a.slug = 'placement-v1'
on conflict (assessment_id, order_index) do nothing;
insert into public.assessment_items (assessment_id, order_index, cefr, skill, prompt_ua, prompt_hr, options, correct_index, explanation_ua, status, source)
select a.id, 19, 'B2', 'grammar', 'Оберіть правильне слово.', 'To je susjeda ___ sin radi u bolnici.', '["čija", "kojoj", "koja", "čiji"]'::jsonb, 3, '«Čiji» узгоджується з тим, що належить (sin — чоловічий рід), а не з власником: susjeda čiji sin…', 'NEEDS_REVIEW', 'claude_placement_v1'
from public.assessments a where a.slug = 'placement-v1'
on conflict (assessment_id, order_index) do nothing;
insert into public.assessment_items (assessment_id, order_index, cefr, skill, prompt_ua, prompt_hr, options, correct_index, explanation_ua, status, source)
select a.id, 20, 'B2', 'grammar', 'Оберіть сполучник, що пояснює причину.', '___ je vlak kasnio, propustili smo sastanak.', '["Kako bi", "Budući da", "Unatoč tome što", "Iako"]'::jsonb, 1, '«Budući da» — оскільки, через те що. «Iako» і «unatoč tome što» — хоча, попри те що; «kako bi» — щоб.', 'NEEDS_REVIEW', 'claude_placement_v1'
from public.assessments a where a.slug = 'placement-v1'
on conflict (assessment_id, order_index) do nothing;
insert into public.assessment_items (assessment_id, order_index, cefr, skill, prompt_ua, prompt_hr, options, correct_index, explanation_ua, status, source)
select a.id, 21, 'B2', 'vocabulary', 'Що означає ця фраза?', 'Ta buka mi ide na živce.', '["Цей шум мене заспокоює.", "Шум іде з вулиці.", "Цей шум мене дратує.", "Я не чую цього шуму."]'::jsonb, 2, '«Ići nekome na živce» — дратувати когось (дослівно «йти на нерви»).', 'NEEDS_REVIEW', 'claude_placement_v1'
from public.assessments a where a.slug = 'placement-v1'
on conflict (assessment_id, order_index) do nothing;
insert into public.assessment_items (assessment_id, order_index, cefr, skill, prompt_ua, prompt_hr, options, correct_index, explanation_ua, status, source)
select a.id, 22, 'B2', 'vocabulary', 'Яке речення підходить для офіційного листа до установи?', null, '["Pošalji nam te papire.", "Daj, javi se kad stigneš.", "Ej, treba nam ono od jučer.", "Molimo Vas da nam dostavite traženu dokumentaciju."]'::jsonb, 3, 'Офіційний стиль: «Molimo Vas da…», звертання «Vi» з великої літери, нейтральна лексика (dokumentacija). Решта — розмовні.', 'NEEDS_REVIEW', 'claude_placement_v1'
from public.assessments a where a.slug = 'placement-v1'
on conflict (assessment_id, order_index) do nothing;
insert into public.assessment_items (assessment_id, order_index, cefr, skill, prompt_ua, prompt_hr, options, correct_index, explanation_ua, status, source)
select a.id, 23, 'B2', 'reading', 'Чому оренда цієї квартири нижча, ніж зазвичай?', 'Iako je stan u centru i ima pogled na more, najamnina je niža nego inače jer vlasnik želi dugoročnog najmoprimca.', '["Власник хоче довгострокового орендаря.", "Квартира потребує ремонту.", "Квартира далеко від центру.", "З квартири не видно моря."]'::jsonb, 0, '«Jer vlasnik želi dugoročnog najmoprimca» — бо власник хоче довгострокового орендаря. «Najamnina» — орендна плата.', 'NEEDS_REVIEW', 'claude_placement_v1'
from public.assessments a where a.slug = 'placement-v1'
on conflict (assessment_id, order_index) do nothing;
insert into public.assessment_items (assessment_id, order_index, cefr, skill, prompt_ua, prompt_hr, options, correct_index, explanation_ua, status, source)
select a.id, 24, 'B2', 'reading', 'Що сталося після ухвалення нового закону?', 'Novi zakon trebao je pojednostaviti postupak, no u praksi su se rokovi dodatno produžili.', '["Процедура стала простішою і швидшою.", "Закон скасували.", "Процедура на практиці стала довшою.", "Терміни скоротилися вдвічі."]'::jsonb, 2, '«Trebao je pojednostaviti» — мав спростити (але не спростив); «rokovi su se dodatno produžili» — терміни ще більше подовжилися.', 'NEEDS_REVIEW', 'claude_placement_v1'
from public.assessments a where a.slug = 'placement-v1'
on conflict (assessment_id, order_index) do nothing;

-- Журнал перевірки (§124): AI-рев'ю, рішення про публікацію — за власником
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, notes)
select 'assessment_item', i.id, 'AI_GENERATED', 'NEEDS_REVIEW', 'auto_passed', 'ai',
       'croatian-content-review: правопис, діакритики, хорватська норма, рівень, переклад — OK; див. content/reviews/2026-10-12_placement_v1.md'
from public.assessment_items i join public.assessments a on a.id = i.assessment_id
where a.slug = 'placement-v1'
  and not exists (select 1 from public.content_reviews r where r.entity_type = 'assessment_item' and r.entity_id = i.id);

-- Самоперевірка
do $$
declare n int;
begin
  select count(*) into n from public.assessment_items i join public.assessments a on a.id = i.assessment_id where a.slug = 'placement-v1';
  if n <> 24 then raise exception 'placement-v1: очікувалось 24 питання, є %', n; end if;
end $$;

commit;
