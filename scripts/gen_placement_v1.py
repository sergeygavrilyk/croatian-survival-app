"""
Генератор SQL для тесту рівня v1 (assessment `placement-v1`, 24 питання: по 4 на A0–B1 і 8 на B2).

Запуск: python scripts/gen_placement_v1.py > supabase/data_fixes/20261012_placement_v1.sql
Питання — тут, у вигляді даних; правильна відповідь у списку завжди перша,
а в SQL варіанти перемішуються детерміновано (той самий порядок при кожному запуску).

Статус: NEEDS_REVIEW (згенеровано й перевірено AI, чекає рішення власника).
Публікація — окремим блоком після перегляду (див. docs/PROJECT_STATE.md).
"""
import hashlib
import json
import re
import sys

ITEMS = [
    # (cefr, skill, prompt_ua, prompt_hr, [правильна, ...дистрактори], explanation_ua)
    ('A0', 'vocabulary', 'Як хорватською «дякую»?', None,
     ['hvala', 'molim', 'bok', 'oprostite'],
     '«Hvala» — дякую. «Molim» — будь ласка / прошу, «bok» — привіт / бувай, «oprostite» — вибачте.'),
    ('A0', 'vocabulary', 'Що означає ця фраза?', 'Dobar dan!',
     ['Добрий день!', 'Добраніч!', 'До побачення!', 'Доброго ранку!'],
     '«Dobar dan» — добрий день. Добраніч — «laku noć», до побачення — «doviđenja», доброго ранку — «dobro jutro».'),
    ('A0', 'vocabulary', 'Як хорватською «ні»?', None,
     ['ne', 'da', 'nije', 'nema'],
     '«Ne» — ні. «Da» — так, «nije» — (він/вона) не є, «nema» — немає.'),
    ('A0', 'reading', 'Вас питають: «Kako se zovete?» Що саме питають?', 'Kako se zovete?',
     ['Як вас звати?', 'Скільки вам років?', 'Звідки ви?', 'Де ви живете?'],
     '«Kako se zovete?» — як вас звати? (ввічлива форма). Звідки ви — «Odakle ste?».'),

    ('A1', 'grammar', 'Оберіть правильне слово.', 'Ja ___ iz Ukrajine.',
     ['sam', 'si', 'je', 'smo'],
     'Дієслово biti: ja sam, ti si, on/ona je, mi smo.'),
    ('A1', 'vocabulary', 'Ви в кафе й хочете розрахуватися. Що скажете офіціанту?', None,
     ['Račun, molim.', 'Jelovnik, molim.', 'Dobar tek!', 'Živjeli!'],
     '«Račun» — рахунок. «Jelovnik» — меню, «Dobar tek!» — смачного, «Živjeli!» — будьмо (тост).'),
    ('A1', 'grammar', 'Оберіть правильну форму слова «brat».', 'Imam dva ___.',
     ['brata', 'brat', 'braća', 'braće'],
     'Після dva, tri, četiri вживається родовий відмінок однини: dva brata.'),
    ('A1', 'reading', 'Коли працює аптека?', 'Ljekarna radi od 8 do 20 sati.',
     ['з 8:00 до 20:00', 'з 8:00 до 12:00', 'лише у вихідні', 'цілодобово'],
     '«Od 8 do 20 sati» — з восьмої до двадцятої години.'),

    ('A2', 'grammar', 'Як сказати «Учора я ходив у кіно»?', 'Jučer ___ u kino.',
     ['sam išao', 'idem', 'ću ići', 'bih išao'],
     'Минулий час: sam + дієприкметник (išao / išla). «Idem» — теперішній, «ću ići» — майбутній, «bih išao» — умовний спосіб.'),
    ('A2', 'grammar', 'Оберіть правильну форму слова «Zagreb».', 'Živim u ___.',
     ['Zagrebu', 'Zagreb', 'Zagreba', 'Zagrebom'],
     'Де? — «u» + місцевий відмінок: u Zagrebu.'),
    ('A2', 'vocabulary', 'Що сталося?', 'Zaboravio sam ključ.',
     ['Я забув ключ.', 'Я загубив гаманець.', 'Я знайшов ключ.', 'Я зачинив двері.'],
     '«Zaboraviti» — забути, «ključ» — ключ. Загубити — «izgubiti», знайти — «naći».'),
    ('A2', 'reading', 'Лікар пояснює, як приймати ліки. Як саме?', 'Uzimajte tablete dva puta dnevno nakon jela.',
     ['двічі на день після їжі', 'двічі на тиждень до їжі', 'раз на день натщесерце', 'два дні поспіль'],
     '«Dva puta dnevno» — двічі на день, «nakon jela» — після їжі.'),

    ('B1', 'grammar', 'Оберіть правильну форму.', 'Kad bih imao više vremena, ___ hrvatski svaki dan.',
     ['učio bih', 'učim', 'učit ću', 'sam učio'],
     'Умовний спосіб в обох частинах: «Kad bih imao…, učio bih…» — якби я мав…, я б учив…'),
    ('B1', 'grammar', 'Оберіть правильне слово.', 'To je kolega ___ sam ti pričao.',
     ['o kojem', 'koji', 'kojeg', 'kojem'],
     '«Pričati o nekome» — розповідати про когось: o kojem (місцевий відмінок).'),
    ('B1', 'vocabulary', 'Як ввічливо попросити колегу перенести зустріч на завтра?', None,
     ['Bismo li mogli pomaknuti sastanak za sutra?', 'Pomakni sastanak!', 'Sastanak je sutra.', 'Nema sastanka sutra.'],
     '«Bismo li mogli…?» — чи не могли б ми…? Умовний спосіб робить прохання ввічливим.'),
    ('B1', 'reading', 'Що сталося з матчем?', 'Unatoč kiši, utakmica je održana prema planu.',
     ['Матч відбувся за планом, попри дощ.', 'Матч скасували через дощ.', 'Матч перенесли на завтра.', 'Дощу не було.'],
     '«Unatoč kiši» — попри дощ, «održana prema planu» — відбулася за планом.'),

    # B2: 8 питань (поріг «пройдено» 75 % = 6 з 8) — граматика, словник / регістр, розуміння тексту
    ('B2', 'grammar', 'Оберіть правильну форму дієслова.', 'Dok sam ___ izvještaj, netko mi je ukrao bicikl.',
     ['pisao', 'napisao', 'pišem', 'bih pisao'],
     '«Dok» + тривала дія → недоконаний вид: dok sam pisao. Доконаний «napisao» означає завершену дію і з «dok» тут не вживається.'),
    ('B2', 'grammar', 'Оберіть правильну форму.', 'Da sam to znao ranije, ___ drugačije.',
     ['postupio bih', 'postupio sam', 'postupit ću', 'postupam'],
     'Нереальна умова в минулому: «Da sam znao…, postupio bih…» — якби я знав…, я б учинив…'),
    ('B2', 'grammar', 'Оберіть правильне слово.', 'To je susjeda ___ sin radi u bolnici.',
     ['čiji', 'čija', 'koja', 'kojoj'],
     '«Čiji» узгоджується з тим, що належить (sin — чоловічий рід), а не з власником: susjeda čiji sin…'),
    ('B2', 'grammar', 'Оберіть сполучник, що пояснює причину.', '___ je vlak kasnio, propustili smo sastanak.',
     ['Budući da', 'Iako', 'Kako bi', 'Unatoč tome što'],
     '«Budući da» — оскільки, через те що. «Iako» і «unatoč tome što» — хоча, попри те що; «kako bi» — щоб.'),
    ('B2', 'vocabulary', 'Що означає ця фраза?', 'Ta buka mi ide na živce.',
     ['Цей шум мене дратує.', 'Цей шум мене заспокоює.', 'Я не чую цього шуму.', 'Шум іде з вулиці.'],
     '«Ići nekome na živce» — дратувати когось (дослівно «йти на нерви»).'),
    ('B2', 'vocabulary', 'Яке речення підходить для офіційного листа до установи?', None,
     ['Molimo Vas da nam dostavite traženu dokumentaciju.', 'Pošalji nam te papire.', 'Daj, javi se kad stigneš.', 'Ej, treba nam ono od jučer.'],
     'Офіційний стиль: «Molimo Vas da…», звертання «Vi» з великої літери, нейтральна лексика (dokumentacija). Решта — розмовні.'),
    ('B2', 'reading', 'Чому оренда цієї квартири нижча, ніж зазвичай?',
     'Iako je stan u centru i ima pogled na more, najamnina je niža nego inače jer vlasnik želi dugoročnog najmoprimca.',
     ['Власник хоче довгострокового орендаря.', 'Квартира далеко від центру.', 'З квартири не видно моря.', 'Квартира потребує ремонту.'],
     '«Jer vlasnik želi dugoročnog najmoprimca» — бо власник хоче довгострокового орендаря. «Najamnina» — орендна плата.'),
    ('B2', 'reading', 'Що сталося після ухвалення нового закону?',
     'Novi zakon trebao je pojednostaviti postupak, no u praksi su se rokovi dodatno produžili.',
     ['Процедура на практиці стала довшою.', 'Процедура стала простішою і швидшою.', 'Закон скасували.', 'Терміни скоротилися вдвічі.'],
     '«Trebao je pojednostaviti» — мав спростити (але не спростив); «rokovi su se dodatno produžili» — терміни ще більше подовжилися.'),
]

SLUG = 'placement-v1'
SOURCE = 'claude_placement_v1'
STATUS = 'NEEDS_REVIEW'


def q(s):
    return 'null' if s is None else "'" + s.replace("'", "''") + "'"


def shuffled(options, key):
    """Детерміноване перемішування: правильна відповідь не завжди перша."""
    order = sorted(range(len(options)), key=lambda i: hashlib.sha256(f'{key}:{i}'.encode()).hexdigest())
    return [options[i] for i in order], order.index(0)


def check():
    assert len(ITEMS) == 24
    for lvl, n in (('A0', 4), ('A1', 4), ('A2', 4), ('B1', 4), ('B2', 8)):
        assert sum(1 for it in ITEMS if it[0] == lvl) == n, lvl
    seen = set()
    for cefr, skill, pua, phr, opts, expl in ITEMS:
        assert len(opts) == len(set(opts)) == 4, opts
        assert pua and expl
        assert re.search('[а-яіїєґ]', pua.lower()), pua            # підказка українською
        assert not re.search(r'\d{2,}_|osnovni_pojam|Primjer', pua + (phr or '') + ''.join(opts))
        if phr:
            assert not re.search('[а-яіїєґ]', phr.lower()), phr   # хорватський текст без кирилиці
        key = (pua, phr)
        assert key not in seen, key
        seen.add(key)


def main():
    check()
    out = [
        '-- =====================================================================',
        '-- Тест рівня v1 (placement-v1): 24 питання — по 4 на A0, A1, A2, B1 і 8 на B2.',
        '-- Якщо перші 16 питань уже додано, повторний запуск додасть лише нові (B2).',
        '-- Згенеровано: scripts/gen_placement_v1.py. Перевірено: content/reviews/2026-10-12_placement_v1.md',
        f'-- Статус: {STATUS} — користувачі НЕ бачать, доки власник не опублікує.',
        '-- Ідемпотентно: повторний запуск нічого не дублює. Потребує M7.',
        '-- =====================================================================',
        'begin;',
        '',
        "insert into public.assessments (slug, kind, title_ua, version, status, source)",
        f"values ({q(SLUG)}, 'placement', 'Тест рівня', 1, {q(STATUS)}, {q(SOURCE)})",
        'on conflict (slug) do nothing;',
        '',
    ]
    for n, (cefr, skill, pua, phr, opts, expl) in enumerate(ITEMS, start=1):
        opts_sh, correct = shuffled(opts, f'{SLUG}:{n}')
        out.append(
            'insert into public.assessment_items (assessment_id, order_index, cefr, skill, prompt_ua, prompt_hr, options, correct_index, explanation_ua, status, source)\n'
            f"select a.id, {n}, {q(cefr)}, {q(skill)}, {q(pua)}, {q(phr)}, {q(json.dumps(opts_sh, ensure_ascii=False))}::jsonb, {correct}, {q(expl)}, {q(STATUS)}, {q(SOURCE)}\n"
            f"from public.assessments a where a.slug = {q(SLUG)}\n"
            'on conflict (assessment_id, order_index) do nothing;'
        )
    out += [
        '',
        "-- Журнал перевірки (§124): AI-рев'ю, рішення про публікацію — за власником",
        'insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, notes)',
        f"select 'assessment_item', i.id, 'AI_GENERATED', {q(STATUS)}, 'auto_passed', 'ai',",
        "       'croatian-content-review: правопис, діакритики, хорватська норма, рівень, переклад — OK; див. content/reviews/2026-10-12_placement_v1.md'",
        f"from public.assessment_items i join public.assessments a on a.id = i.assessment_id",
        f"where a.slug = {q(SLUG)}",
        "  and not exists (select 1 from public.content_reviews r where r.entity_type = 'assessment_item' and r.entity_id = i.id);",
        '',
        '-- Самоперевірка',
        'do $$',
        'declare n int;',
        'begin',
        f"  select count(*) into n from public.assessment_items i join public.assessments a on a.id = i.assessment_id where a.slug = {q(SLUG)};",
        "  if n <> 24 then raise exception 'placement-v1: очікувалось 24 питання, є %', n; end if;",
        'end $$;',
        '',
        'commit;',
    ]
    sys.stdout.write('\n'.join(out) + '\n')


if __name__ == '__main__':
    main()
