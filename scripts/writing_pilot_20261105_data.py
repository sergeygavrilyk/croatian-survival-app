"""
Пілот «Напишіть повідомлення» і «Перекажіть другу» (§57, §58) · 2026-11-05 — модулі A0.1 і A1.1, по 2 вправи на урок.

Рішення власника 2026-11-05: перевірка без AI; вправи можна пропустити; переказ хорватське → українське до A1.10,
навпаки — з A1.11; зберігаємо лише текст відповіді.
Пункт: (що має бути — українською, [ключі]); ключ — основи слів, які всі мають бути в тексті (lib/writing.ts):
основа збігається з початком слова, «=» в кінці — ціле слово; хорватські ключі — без урахування діакритик.
Генератор: scripts/gen_writing_pilot_20261105.py.
"""

MEDIATION_SITUATION = 'Друг не знає хорватської. Перекажіть йому українською головне.'

# id уроку → (назва для звіту, рівень, write_message, mediation)
LESSONS = {
    # ------------------------------------------------------------------ A0.1 Знайомство й ввічливість
    'c0000000-0000-0000-0000-000000000001': dict(
        title='A0.1.1 Привітання та подяка', level='A0',
        write=dict(
            situation='Даша пише вам: «Bok! Kako si?» Відповідайте їй: привітайтеся, скажіть, як ви, і спитайте, як справи в неї.',
            points=[('привітайтеся', [['bok'], ['zdravo'], ['dobar dan']]),
                    ('скажіть, як ви', [['dobro'], ['odlično'], ['super'], ['loše'], ['tako-tako'], ['umor'], ['ne baš']]),
                    ('спитайте, як вона', [['a ti'], ['kako si'], ['kako ste']])],
            hints=['bok', 'dobro', 'hvala', 'a ti?', 'kako si?'],
            models=['Bok, Dašo! Dobro sam, hvala. A ti?', 'Bok! Super, hvala. Kako si ti?']),
        mediation=dict(
            source='Bok, Olena! Kako si? Ja sam dobro, samo malo umorna.',
            friend='Що вона пише? Як у неї справи?',
            points=[('у неї все добре', [['добре'], ['нормально'], ['гаразд']]),
                    ('трохи втомилася', [['втомил'], ['втомлен'], ['втома']])],
            models=['Пише, що в неї все добре, тільки трохи втомилася.'])),
    'd8cffb46-8a62-538a-b864-e227a6d8b863': dict(
        title='A0.1.2 Добрий день і до побачення', level='A0',
        write=dict(
            situation='Ви йдете з роботи в п’ятницю ввечері. Напишіть колезі в чат: попрощайтеся й побажайте гарних вихідних.',
            points=[('попрощайтеся', [['doviđenja'], ['bok'], ['vidimo se'], ['laku noć'], ['pozdrav'], ['čujemo se']]),
                    ('побажайте гарних вихідних', [['ugodan vikend']])],
            hints=['doviđenja', 'vidimo se', 'ugodan vikend', 'dobra večer'],
            models=['Doviđenja i ugodan vikend! Vidimo se!', 'Bok, vidimo se u ponedjeljak! Ugodan vikend!']),
        mediation=dict(
            source='Dobar dan! Danas radimo do 15 sati.\nVidimo se sutra u 8.\nLijep pozdrav!',
            friend='Що там на дверях? Вони сьогодні працюють?',
            points=[('сьогодні — до 15:00', [['15'], ['третьої'], ['трьох']]),
                    ('завтра — з 8:00', [['завтра', '8'], ['завтра', 'восьм']])],
            models=['Сьогодні працюють до 15:00, а завтра відкриються о 8:00.'])),
    'a17f2f16-1be9-50f2-8e16-2bebfcced33b': dict(
        title='A0.1.3 Вибачте, я не розумію', level='A0',
        write=dict(
            situation='Сусідка-хорватка дуже швидко пише голосові повідомлення. Напишіть їй: вибачтеся, скажіть, що не розумієте, '
                      'і попросіть говорити повільніше.',
            points=[('вибачтеся', [['oprost']]),
                    ('скажіть, що не розумієте', [['ne razum'], ['nisam razum']]),
                    ('попросіть повільніше', [['polako'], ['sporije']])],
            hints=['oprostite', 'ne razumijem', 'polako', 'sporije', 'govoriti'],
            models=['Oprostite, ne razumijem. Možete li govoriti sporije?', 'Oprostite, ne razumijem. Polako, molim.']),
        mediation=dict(
            source='Oprostite, ne govorim engleski. Možete li napisati?',
            friend='Що вона каже?',
            points=[('не говорить англійською', [['англ']]),
                    ('просить написати', [['напис']])],
            models=['Каже, що не говорить англійською, і просить написати.'])),
    'e704760a-f743-5762-9c1a-027b10ca030a': dict(
        title='A0.1.4 Ввічливі слова', level='A0',
        write=dict(
            situation='Колега допоміг вам із документами, а ви запізнюєтеся на зустріч з ним. Напишіть йому: подякуйте за допомогу '
                      'і вибачтеся, що запізнюєтеся.',
            points=[('подякуйте за допомогу', [['hvala', 'pomo']]),
                    ('вибачтеся, що запізнюєтеся', [['isprič', 'kasn'], ['oprost', 'kasn']])],
            hints=['hvala na pomoći', 'ispričavam se', 'kasnim'],
            models=['Hvala na pomoći! Ispričavam se što kasnim.', 'Puno hvala na pomoći! Oprosti, malo kasnim.']),
        mediation=dict(
            source='Izvolite, vaša kava. Dobar tek!',
            friend='Що сказав офіціант?',
            points=[('ось ваша кава', [['кав']]),
                    ('смачного', [['смачн']])],
            models=['Каже: «Ось ваша кава. Смачного!»'])),

    # ------------------------------------------------------------------ A1.1 Повсякденне життя
    '4bf48151-be83-5108-bc92-645c0603a1a3': dict(
        title='A1.1.1 Мій звичайний день', level='A1',
        write=dict(
            situation='Даша питає, який у вас звичайний ранок. Напишіть 2–3 речення: коли прокидаєтеся, що робите потім '
                      'і коли йдете з дому.',
            points=[('коли прокидаєтеся / встаєте', [['budim'], ['ustaj'], ['ustanem'], ['probudim']]),
                    ('що робите потім', [['zatim'], ['nakon toga'], ['tušir'], ['doručk'], ['sprem']]),
                    ('коли йдете з дому', [['odlaz'], ['krenem'], ['krećem'], ['idem']])],
            hints=['obično', 'budim se', 'zatim', 'tuširam se', 'odlazim na posao'],
            models=['Obično se budim u sedam. Zatim se tuširam i doručkujem. U osam odlazim na posao.']),
        mediation=dict(
            source='Sutra ustajem u pet, zato se tuširam navečer. Molim te, ne budi me!',
            friend='Що написала сусідка по квартирі?',
            points=[('завтра встає о 5:00', [['5'], ["п'ят"]]),
                    ('просить її не будити', [['не буд']])],
            models=['Завтра вона встає о п’ятій, тому просить її не будити.'])),
    '54f17cf7-3c17-5978-b400-b6b6888c9f84': dict(
        title='A1.1.2 Збираємося зранку', level='A1',
        write=dict(
            situation='Ви з сином запізнюєтеся до садка. Напишіть йому записку: умийся, почисти зуби, одягнися — поспішаємо!',
            points=[('умийся', [['umij']]),
                    ('почисти зуби', [['zub']]),
                    ('одягнися', [['obuci'], ['obuc']]),
                    ('поспішаємо', [['požur'], ['brzo'], ['kasnimo']])],
            hints=['umij se', 'operi zube', 'obuci se', 'požuri se'],
            models=['Umij se, operi zube i obuci se. Požuri se, kasnimo!']),
        mediation=dict(
            source='Za izlet ponesite četkicu i pastu za zube, češalj i ručnik.',
            friend='Що треба взяти на екскурсію?',
            points=[('зубну щітку й пасту', [['щітк', 'паст']]),
                    ('гребінець', [['гребін'], ['гребінц']]),
                    ('рушник', [['рушник']])],
            models=['Треба взяти зубну щітку й пасту, гребінець і рушник.'])),
    '959e879f-a28d-5bed-9c09-16cff91ef456': dict(
        title='A1.1.3 Як часто?', level='A1',
        write=dict(
            situation='Друг питає, як часто ви займаєтеся спортом і готуєте вдома. Напишіть 2 речення зі словами про частоту.',
            points=[('про спорт', [['sport'], ['trč'], ['teretan'], ['plivam']]),
                    ('про готування вдома', [['kuh']]),
                    ('як часто', [['često'], ['rijetko'], ['nikad'], ['katkad'], ['jednom'], ['dvaput'], ['triput'], ['svaki'],
                                  ['vikendom'], ['svakodnevno'], ['stalno']])],
            hints=['često', 'rijetko', 'dvaput', 'vikendom', 'kuham', 'trčim'],
            models=['Trčim dvaput tjedno, vikendom. Kuham rijetko, obično jedem vani.']),
        mediation=dict(
            source='Teretana radi svaki dan od 6 do 22 sata.\nVikendom: od 8 do 20 sati.',
            friend='Коли працює спортзал? А у вихідні?',
            points=[('щодня з 6:00 до 22:00', [['6', '22'], ['шост', 'двадцять друг']]),
                    ('у вихідні з 8:00 до 20:00', [['8', '20'], ['восьм', 'двадцят']])],
            models=['Щодня з 6:00 до 22:00, а у вихідні — з 8:00 до 20:00.'])),
    '9c38f909-9275-5194-9a6e-f799c6e416ce': dict(
        title='A1.1.4 Домашні справи', level='A1',
        write=dict(
            situation='Ви живете з сусідкою по квартирі. Напишіть їй записку: сьогодні ви пилососите й прасуєте, '
                      'а вона хай винесе сміття й помиє посуд.',
            points=[('що робите ви', [['usis'], ['pegl']]),
                    ('хай винесе сміття', [['smeć']]),
                    ('хай помиє посуд', [['suđ']])],
            hints=['usisavam', 'peglam', 'iznesi smeće', 'operi suđe'],
            models=['Danas ja usisavam i peglam. Molim te, iznesi smeće i operi suđe. Hvala!']),
        mediation=dict(
            source='Perilica rublja ne radi do petka.\nMolimo, ne ostavljajte rublje u perilici.',
            friend='Що там написано на дверях пральні?',
            points=[('пральна машина не працює', [['не працю'], ['злама'], ['не прац']]),
                    ('до п’ятниці', [["п'ятниц"]]),
                    ('не залишати білизну', [['не залиш'], ['забира'], ['не лиш']])],
            models=['Пральна машина не працює до п’ятниці, і просять не залишати в ній білизну.'])),
    'd43d6c65-1ce3-5c72-9ecd-cce2ed200fc2': dict(
        title='A1.1.5 З дитиною вдома', level='A1',
        write=dict(
            situation='Бабуся сьогодні доглядає вашу доньку. Напишіть їй: мала спить о 13:00, увечері її треба скупати, '
                      'а перед сном — почитати казку.',
            points=[('сон о 13:00', [['13']]),
                    ('увечері скупати', [['kupa'], ['okupa']]),
                    ('почитати казку', [['bajk'], ['slikovnic']])],
            hints=['spava', 'okupaj je', 'pročitaj joj bajku', 'navečer'],
            models=['Bako, mala spava u 13 sati. Navečer je okupaj, a prije spavanja joj pročitaj bajku.']),
        mediation=dict(
            source='Vaš sin danas ne jede i malo plače.\nMolimo, nazovite vrtić.',
            friend='Що пишуть із садка?',
            points=[('син не їсть і плаче', [['плач']]),
                    ('просять зателефонувати', [['зателефон'], ['подзвон'], ['дзвон']])],
            models=['Пишуть, що син сьогодні не їсть і трохи плаче, і просять зателефонувати в садок.'])),
    '1968c7d5-4e3a-5b1e-92f6-88df711e9c54': dict(
        title='A1.1.6 Догляд за улюбленцем', level='A1',
        write=dict(
            situation='Сусід доглядатиме вашого пса на вихідних. Напишіть йому: вигулювати двічі на день, корм — у шафі, '
                      'воду міняти щодня.',
            points=[('вигулювати', [['šeta'], ['izved']]),
                    ('де корм', [['hran'], ['granul']]),
                    ('вода щодня', [['vod']])],
            hints=['šetati psa', 'hrana za pse', 'zdjelica', 'voda', 'dvaput dnevno'],
            models=['Molim te, šetaj psa dvaput dnevno. Hrana za pse je u ormaru. Svaki dan mu daj svježu vodu.']),
        mediation=dict(
            source='Psi u parku moraju biti na uzici.\nMolimo, čistite iza svog psa.',
            friend='Що написано на табличці в парку?',
            points=[('собака — на повідку', [['повід']]),
                    ('прибирати за собакою', [['прибир'], ['чист']])],
            models=['Собаки мають бути на повідку, і треба прибирати за своїм собакою.'])),
    '458b73de-d6b3-5bd3-98ad-c243a2fff03f': dict(
        title='A1.1.7 Вихідні', level='A1',
        write=dict(
            situation='Колега питає про ваші плани на вихідні. Напишіть 2–3 речення: що робите в суботу і що в неділю.',
            points=[('субота', [['subot']]),
                    ('неділя', [['nedjelj']]),
                    ('що робите', [['izlet'], ['šetn'], ['šeta'], ['roštilj'], ['piknik'], ['izložb'], ['odmar'], ['opust'],
                                   ['sajam'], ['planinar']])],
            hints=['u subotu', 'u nedjelju', 'idemo na izlet', 'roštilj', 'opustiti se'],
            models=['U subotu idemo na izlet na selo. U nedjelju imamo roštilj kod prijatelja.']),
        mediation=dict(
            source='Sajam u parku: subota i nedjelja od 10 do 18 sati.\nUlaz je besplatan!',
            friend='Що це за оголошення? Коли й скільки коштує?',
            points=[('ярмарок у парку', [['ярмар']]),
                    ('у вихідні з 10:00 до 18:00', [['10', '18'], ['десят', 'вісімнадцят']]),
                    ('вхід безкоштовний', [['безкоштов'], ['безплат']])],
            models=['У парку ярмарок у суботу й неділю з 10:00 до 18:00, вхід безкоштовний.'])),
    '63a4a6d8-1cae-5e0e-90ff-98efcfe8b4c7': dict(
        title='A1.1.8 Сон і відпочинок', level='A1',
        write=dict(
            situation='Ви запізнюєтеся на роботу. Напишіть керівниці: вибачтеся, скажіть, що запізнюєтеся, і поясніть чому '
                      '(погано спите, дуже втомлені).',
            points=[('вибачтеся', [['isprič'], ['oprost'], ['žao mi']]),
                    ('скажіть, що запізнюєтеся', [['kasn']]),
                    ('поясніть чому', [['nesanic'], ['iscrplj'], ['umor'], ['spava'], ['san']])],
            hints=['ispričavam se', 'kasnim', 'jer', 'imam nesanicu', 'umorna / umoran'],
            models=['Ispričavam se, kasnim jer imam nesanicu. Danas sam jako umorna.',
                    'Ispričavam se, kasnim jer imam nesanicu. Danas sam jako umoran.']),
        mediation=dict(
            source='Molimo tišinu od 22 do 7 sati.\nHvala!',
            friend='Що там написано біля ліфта?',
            points=[('просять тиші', [['тиш'], ['тихо'], ['не шум']]),
                    ('з 22:00 до 7:00', [['22', '7'], ['десят', 'сьом']])],
            models=['Просять тиші з 22:00 до 7:00.'])),
    '3365f423-e694-5b55-baa1-3205fba11aff': dict(
        title='A1.1.9 Мій тиждень', level='A1',
        write=dict(
            situation='Вам треба перенести зустріч із колегою. Напишіть йому: вибачтеся, скажіть, що в середу не можете, '
                      'і запропонуйте четвер.',
            points=[('вибачтеся', [['isprič'], ['oprost'], ['žao mi']]),
                    ('у середу не можете', [['srijed', 'ne mog'], ['srijed', 'ne=']]),
                    ('запропонуйте четвер', [['četvrt']])],
            hints=['sastanak', 'u srijedu', 'ne mogu', 'pomaknuti', 'na četvrtak'],
            models=['Oprosti, u srijedu ne mogu doći na sastanak. Možemo li ga pomaknuti na četvrtak?']),
        mediation=dict(
            source='Sastanak je odgođen za sljedeći tjedan.\nNovi termin: utorak u 9 sati.',
            friend='Що пишуть про зустріч?',
            points=[('перенесли на наступний тиждень', [['наступн']]),
                    ('у вівторок о 9:00', [['вівтор', '9'], ['вівтор', "дев'ят"]])],
            models=['Зустріч перенесли на наступний тиждень — у вівторок о 9:00.'])),
    'ad0bc1f4-2808-5b24-969d-9da64d4a7a4d': dict(
        title='A1.1.10 Корисні слова: навіть, саме, знову, ще не', level='A1',
        write=dict(
            situation='Подруга питає, чи ви вже знайшли роботу. Напишіть: ще ні, але саме зараз шукаєте, '
                      'і в п’ятницю навіть маєте співбесіду.',
            points=[('ще ні', [['još ne'], ['još nis'], ['još uvijek ne']]),
                    ('саме зараз шукаєте', [['traž']]),
                    ('співбесіда в п’ятницю', [['petak'], ['petk']])],
            hints=['još ne', 'upravo', 'tražim posao', 'čak', 'razgovor za posao', 'u petak'],
            models=['Još ne, ali upravo tražim posao. U petak čak imam razgovor za posao!']),
        mediation=dict(
            source='Opet kasnim, oprosti!\nAutobus još ne dolazi. Stižem za 15 minuta.',
            friend='Що вона пише? Коли буде?',
            points=[('знову запізнюється', [['запізн']]),
                    ('автобуса ще немає', [['автобус']]),
                    ('буде за 15 хвилин', [['15'], ["п'ятнадцят"]])],
            models=['Пише, що знову запізнюється: автобуса ще немає, буде за 15 хвилин.'])),
}
