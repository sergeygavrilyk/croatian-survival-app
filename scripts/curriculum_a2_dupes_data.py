"""
Дублі A2 · 2026-11-19 — дані для scripts/gen_a2_dupes.py (план docs/proposals/2026-11-16_lesson_duplicates.md, PR 4).

Рішення власника 2026-11-17 (дослівно — docs/DECISIONS.md): Д1–Д10, Д13, Д6 (міняємо A2-29) — «ок»; новий урок A2.11
«Далмація: Задар і околиці» — без слів і діалогів A1-89 (тепер A1-90); дозвіл прибирати слова з уроків (копія в backup).
  Д1 — урок 27 «Аргументи й компроміс»: без «згоден / не згоден / ти правий» (є в A1 «Що ти думаєш?»), + аргументація;
  Д2 — урок 9 «Курси хорватської для дорослих» = уже на курсі: прогрес, розмовна практика, довідка; запис на курс — в A1-105;
       діалог «Upis na tečaj» → «Kako napredujem?»;
  Д5 — урок 38 «Майстер удома: кошторис і гарантія»: без «тече кран» і «немає світла» (A1-45); 2 нові діалоги;
  Д6 — урок 29 → «Сусіди: збори й шкода»: без шуму (A1-48); діалог «Buka navečer» → «Poplavio nas je susjed»;
  Д7 — урок 70 «Звичаї й етикет»: без «ти чи Ви» (A1-77); діалог «Ti ili Vi?» → обід у гостях;
  Д8 — урок 44 = документи лікарняного (+ otvoriti / zatvoriti bolovanje, javiti se bolestan з уроку 33; без симптомів A1-74);
       урок 33 → «Відпустка й вихідні дні» (лише відпустка); діалоги «Dijete je bolesno» і «Bolesna sam» — нові.
Назви діалогів (§5 плану): однакова назва → перейменовуємо діалог у пізнішому уроці (тексти прочитано — зміст різний;
в A2-3 «Na recepciji» дві репліки схожі на A0 «У готелі», але далі — картки й wi-fi, тому лише назва).

Слово не зникає з курсу (принцип 1): прибрані слова лишаються в інших уроках (A1-105 — početni tečaj, test razine, upisati se;
A1-48 — smetati; A1-45 — kapati; A1-74 — povraćati, proljev; A1-77 — persirati, tikati) або лише в словнику, коли в уроках A1
є ширший чи синонімічний вираз (A1-85: složiti se, u pravu, po mom mišljenju; A1-105: napredni, polaznik; A1-45: osigurač,
začepljen; A1-48: glasno, tiho) — DICT_ONLY.

Формат: заміна слова — на тому самому місці уроку (lesson_items.item_id); нове слово — (лема, переклад, частина мови,
рід / вид, приклад[, мітки]); заміна вправи — за відповіддю старої вправи або за її типом (fill_in_the_blank, listening_dialogue,
write_message, mediation — по одній в уроці); тип і місце ті самі. Імена — частіше Даша / Дар’я.
"""

DATE = '20261119'

# Наявні слова словника без уроку (переклад і рівень — з робочої бази 2026-11-19): рівень → A2 (їх уперше вчать в A2)
EXISTING = ['dokaz', 'ispravljati', 'sudjelovati', 'morska sol']
# Слова, прибрані з уроків A2, які лишаються лише в словнику (в уроках A1 — ширший чи синонімічний вираз)
DICT_ONLY = ['slagati se', 'ne slažem se', 'u pravu si', 'nisi u pravu', 'po meni', 'napredni tečaj', 'upisivati', 'polaznica',
             'glasna glazba', 'lupati', 'utišati', 'iskočio je osigurač', 'začepiti se', 'biti na bolovanju']
# Прибрані слова, які лишаються в інших уроках (урок — для звіту)
ELSEWHERE = {'početni tečaj': 'A1 Урок 105', 'test razine': 'A1 Урок 105', 'upisati se': 'A1 Урок 105', 'smetati': 'A1 Урок 48',
             'kapati': 'A1 Урок 45', 'povraćati': 'A1 Урок 74', 'proljev': 'A1 Урок 74', 'persirati': 'A1 Урок 77', 'tikati': 'A1 Урок 77'}
# Переносимо з уроку 33 в урок 44 (Д8)
MOVE_33_44 = ['otvoriti bolovanje', 'zatvoriti bolovanje', 'javiti se bolestan']

# Нові слова (їх немає в словнику робочої бази): лема, переклад, частина мови, рід / вид, приклад[, dict(мітки)]
NEW_LEXEMES = {
    27: [
        ('uvjerljiv', 'переконливий', 'adj', '', 'Tvoj argument nije baš uvjerljiv.'),
        ('popustiti', 'поступитися', 'v', 'pfv:popuštati', 'Na kraju je šef popustio i pristao na kompromis.'),
        ('inzistirati', 'наполягати', 'v', 'ipfv', 'Zašto stalno inzistiraš na svome?'),
        ('opravdan', 'обґрунтований, виправданий', 'adj', '', 'Mislim da je tvoj zahtjev potpuno opravdan.'),
    ],
    9: [
        ('razina znanja', 'рівень знань', 'ph', 'f', 'Na kraju tečaja provjeravamo razinu znanja.'),
        ('konverzacija', 'розмовна практика', 'n', 'f', 'Utorkom imamo sat konverzacije.'),
        ('zaostajati', 'відставати', 'v', 'ipfv:zaostati', 'Ne želim zaostajati za grupom.'),
        ('samostalno učiti', 'вчитися самостійно', 'ph', '', 'Kod kuće samostalno učim nove riječi.'),
    ],
    29: [
        ('procuriti', 'протекти', 'v', 'pfv', 'Voda je procurila kroz strop u kupaonici.'),
        ('fasada', 'фасад', 'n', 'f', 'Fasada zgrade je stara i treba je obnoviti.'),
        ('popravak krova', 'ремонт даху', 'ph', 'm', 'Na sastanku stanara dogovorili smo popravak krova.'),
        ('nadoknada štete', 'відшкодування збитків', 'ph', 'f', 'Susjed je platio nadoknadu štete za poplavljenu kupaonicu.'),
    ],
    33: [
        ('zamjena smjene', 'обмін змінами', 'ph', 'f', 'Kolega me pitao za zamjenu smjene u subotu.'),
        ('kolektivni godišnji odmor', 'колективна відпустка (уся фірма)', 'ph', 'm', 'U kolovozu je u tvrtki kolektivni godišnji odmor.'),
        ('prenijeti dane', 'перенести дні (відпустки)', 'ph', '', 'Neiskorištene dane mogu prenijeti u iduću godinu.'),
        ('pravo na godišnji', 'право на відпустку', 'ph', 'n', 'Svaki radnik ima pravo na godišnji od najmanje četiri tjedna.'),
    ],
    38: [
        ('rok završetka', 'термін завершення (робіт)', 'ph', 'm', 'Koji je rok završetka radova u kupaonici?'),
        ('kašnjenje radova', 'затримка робіт', 'ph', 'n', 'Zbog kiše je došlo do kašnjenja radova.'),
        ('plaćanje gotovinom', 'оплата готівкою', 'ph', 'n', 'Je li moguće plaćanje gotovinom ili samo karticom?'),
    ],
    70: [
        ('gostoprimstvo', 'гостинність', 'n', 'n', 'Hvala vam na gostoprimstvu!'),
        ('nutkati', 'припрошувати (їсти, пити)', 'v', 'ipfv', 'Domaćica nas je cijelu večer nutkala kolačima.'),
    ],
    'zadar': [
        ('zadarski', 'задарський', 'adj', '', 'Zadarska riva je najljepša pri zalasku sunca.'),
        ('solana', 'солеварня', 'n', 'f', 'U Ninu je stara solana u kojoj se sol i danas skuplja ručno.'),
        ('ljekovito blato', 'лікувальна грязь', 'ph', 'n', 'Ljudi dolaze u Nin zbog ljekovitog blata.'),
        ('crkvica', 'церковця, маленька церква', 'n', 'f', 'Na brdu iznad sela je mala kamena crkvica.'),
        ('kraljevski grad', 'королівське місто', 'ph', 'm', 'Nin je stari hrvatski kraljevski grad.'),
        ('starohrvatski', 'давньохорватський', 'adj', '', 'U muzeju su izloženi starohrvatski nakit i oružje.'),
        ('arheološko nalazište', 'археологічна пам’ятка (місце розкопок)', 'ph', 'n', 'Pokraj crkve je veliko arheološko nalazište.'),
        ('penjač', 'скелелаз', 'n', 'm', 'U proljeće u Paklenicu dolaze penjači iz cijele Europe.'),
        ('penjalište', 'місце для скелелазіння', 'n', 'n', 'Penjalište je samo deset minuta od parkirališta.'),
        ('stijena', 'скеля', 'n', 'f', 'Penjač se polako penje uz stijenu.'),
        ('uže', 'мотузка (страхувальна)', 'n', 'n', 'Bez užeta i kacige ne smiješ se penjati.'),
        ('slobodno penjanje', 'скелелазіння', 'ph', 'n', 'Slobodno penjanje je popularno u Paklenici.'),
        ('marina', 'марина (пристань для яхт)', 'n', 'f', 'Biograd ima veliku marinu punu jedrilica.'),
        ('izletnički brod', 'прогулянковий корабель', 'ph', 'm', 'Izletnički brod polazi u devet ujutro.'),
        ('cjelodnevni izlet', 'одноденна екскурсія', 'ph', 'm', 'Cjelodnevni izlet na Kornate traje do šest navečer.'),
        ('ribarska brodica', 'рибальський човен', 'ph', 'f', 'U luci su ribarske brodice i jahte.'),
        ('ulov', 'улов', 'n', 'm', 'Ribari prodaju jutarnji ulov na ribarnici.'),
        ('turistička sezona', 'туристичний сезон', 'ph', 'f', 'Za vrijeme turističke sezone Zadar je pun ljudi.'),
        ('izvan sezone', 'поза сезоном', 'ph', '', 'Izvan sezone su cijene smještaja niže.'),
        ('tempo života', 'темп життя', 'ph', 'm', 'U Zadru je tempo života sporiji nego u Zagrebu.'),
        ('sezonski posao', 'сезонна робота', 'ph', 'm', 'Mnogi studenti ljeti rade sezonski posao na moru.'),
        # далматинське розмовне слово — лише впізнавати (рішення 2026-11-17: «далматинська говірка — лише впізнавання»)
        ('đir', 'прогулянка (щоб розвіятися)', 'n', 'm', 'Navečer idemo na đir po rivi.',
         dict(register='colloquial', regionality='Dalmatia', usage_tags=['italianism'])),  # нейтрально — šetnja (у ukrainian_interference)
    ],
}
FORMULAIC: set[str] = set()
INTERFERENCE = {
    'uže': 'не «вуж» і не «вже»: uže — мотузка',
    'đir': 'розмовне далматинське слово (з італ. giro); нейтрально — šetnja; ići na đir — піти прогулятися',
    'marina': 'не жіноче ім’я: marina — пристань для яхт',
}
RECOGNITION = {'đir'}   # слова, які в уроці лише впізнаємо (lesson_items.target_skill = 'recognition')

LESSON_IDS = {
    9: '8190831a-549a-544a-962b-4f716a895a32', 27: 'f029711f-710e-5327-be4d-2310435e6eac', 29: '5252662a-abfc-517a-9bde-8683121a53c5',
    33: '0e0d07a2-2a6c-5090-ab84-3089f20a48b8', 38: 'bf43b6bd-d547-596b-8981-55a4043cf238', 44: '8f08356b-8efa-5ebc-906e-f409fbaadaf3',
    70: '7d3c3501-a381-5b3c-a0a2-b269f3dff137',
}
UNIT_11 = '3fbc4d9b-4366-5f0f-b785-eb3f750240be'     # юніт модуля A2.11 «Хорватія: краї, звичаї, культура»
NEW_ORDER = 5                                         # місце в A2.11: після «Загреб і Загор’є» (4); 5 → 6, 6 → 7

# ---------------------------------------------------------------------------------------------- зміни наявних уроків
# swap — (стара лема, нова лема) на тому самому місці; add — слова в кінець; convs — [(id старого діалогу, новий діалог)];
# ex — (відповідь старої вправи або її тип, нова вправа); title — нова назва (без «Урок N:»).
# Вправа: type, question, answer, options (для вибору), word (лема — для вправ на слово); listening_dialogue — listening;
# write_message — write; mediation — mediation (формат — як у curriculum_a2_v2_mNN.py).
CHANGES = {
    9: dict(
        note='Д2',
        objectives=['Розповісти, як іде навчання на курсі: прогрес, розмовна практика, довідка про відвідування',
                    'Розрізняти вид: ispravljati — ispraviti, vježbati — izvježbati'],
        swap=[('početni tečaj', 'razina znanja'), ('napredni tečaj', 'konverzacija'), ('test razine', 'zaostajati'),
              ('polaznica', 'sudjelovati'), ('upisivati', 'ispravljati'), ('upisati se', 'samostalno učiti')],
        convs=[('d198b0f9-0676-53cf-87d3-3c1468482649',
                ('Як я просуваюся?', 'Kako napredujem?', 'small_talk', [
                    ('Daša', 'Profesorice, imate li minutu? Zanima me kako napredujem.',
                     'Пані викладачко, у вас є хвилинка? Мені цікаво, як я просуваюся.'),
                    ('Predavačica', 'Napredujete dobro. Vaša razina znanja je sada bolja nego u rujnu.',
                     'Ви робите добрі успіхи. Ваш рівень знань тепер кращий, ніж у вересні.'),
                    ('Daša', 'Ali na konverzaciji još malo zaostajem za grupom.', 'Але на розмовній практиці я ще трохи відстаю від групи.'),
                    ('Predavačica', 'Zato više sudjelujte na satu. Nemojte se bojati pogrešaka.',
                     'Тому більше беріть участь на занятті. Не бійтеся помилок.'),
                    ('Daša', 'Hoćete li me ispravljati kad pogriješim?', 'Ви виправлятимете мене, коли я помилятимуся?'),
                    ('Predavačica', 'Naravno. A kod kuće samostalno učite riječi i čitajte naglas.',
                     'Звісно. А вдома самостійно вчіть слова й читайте вголос.'),
                ]))],
        ex=[('fill_in_the_blank', dict(type='fill_in_the_blank', question='Cijelu večer sam ___ pogreške u zadaći.', answer='ispravljala',
                                       options=['ispravljala', 'ispravila', 'ispraviti', 'ispravljati'])),
            ('робити успіхи, прогресувати', dict(type='multiple_choice', question='Що означає «napredovati»?', answer='робити успіхи, прогресувати',
                                                 options=['робити успіхи, прогресувати', 'рівень знань', 'вчитися самостійно', 'плата за навчання'],
                                                 word='napredovati')),
            ('оплата частинами', dict(type='multiple_choice', question='Що означає «plaćanje u ratama»?', answer='оплата частинами',
                                      options=['оплата частинами', 'розмовна практика', 'вимова', 'відставати'], word='plaćanje u ratama')),
            ('test razine', dict(type='multiple_choice', question='Як хорватською «розмовна практика»?', answer='konverzacija',
                                 options=['konverzacija', 'školarina', 'izgovor', 'mala grupa'], word='konverzacija')),
            ('izgovor', dict(type='multiple_choice', question='Як хорватською «вимова»?', answer='izgovor',
                             options=['izgovor', 'razina znanja', 'sudjelovati', 'večernji tečaj'], word='izgovor')),
            ('Kolika je školarina? Je li moguće plaćanje u ratama?',
             dict(type='listening', question='Прослухайте і складіть фразу', answer='Hoćete li me ispravljati kad pogriješim?')),
            ('listening_dialogue', dict(type='listening_dialogue', listening=dict(
                kind='voicemail', situation='Мовна школа залишила вам повідомлення.', script=[
                    ('Dobar dan, ovdje škola stranih jezika Lingua.', 'Добрий день, це школа іноземних мов «Лінгва».'),
                    ('Vaša potvrda o pohađanju je gotova, možete je podići u tajništvu.',
                     'Ваша довідка про відвідування готова, можете забрати її в секретаріаті.'),
                    ('Tajništvo radi od ponedjeljka do petka, od deset do šesnaest sati.',
                     'Секретаріат працює з понеділка до п’ятниці, з десятої до шістнадцятої.'),
                    ('Za potvrdu ponesite osobnu iskaznicu.', 'По довідку візьміть із собою посвідчення особи.'),
                ], questions=[
                    ('Що готово?', ['сертифікат про рівень', 'довідка про відвідування', 'розклад занять'], 1, 1),
                    ('Коли працює секретаріат?', ['лише в суботу', 'щодня з 8 до 20', 'з понеділка до п’ятниці, з 10 до 16'], 2, 2),
                    ('Що треба взяти із собою?', ['посвідчення особи', 'фотографію', 'квитанцію про оплату'], 0, 3),
                ]))),
            ('Zanima me večernji tečaj.', dict(type='speaking', question='Я відстаю на розмовній практиці.', answer='Zaostajem na konverzaciji.')),
            ('write_message', dict(type='write_message', write=dict(
                situation='Напишіть викладачці: у четвер ви не прийдете на заняття через роботу й питаєте, що повторити самостійно.',
                points=[('не прийдете на заняття', [['neću'], ['ne mogu'], ['propust']]), ('у четвер', [['četvrt']]),
                        ('що повторити самостійно', [['ponovi'], ['samostal']])],
                hints=['u četvrtak neću moći doći', 'zbog posla', 'što trebam ponoviti?'],
                models=['Poštovana profesorice, u četvrtak neću moći doći na sat zbog posla. Što trebam samostalno ponoviti?']))),
            ('mediation', dict(type='mediation', mediation=dict(
                friend='Спитай у школі, чи є заняття з розмовної практики в малій групі.',
                points=[('розмовна практика', [['konverzacij']]), ('мала група', [['mal', 'grup']])],
                models=['Imate li sate konverzacije u maloj grupi?']))),
            ],
    ),
    27: dict(
        note='Д1',
        objectives=['Аргументувати думку й шукати компроміс: argument, dokaz, uvjerljiv, popustiti, inzistirati',
                    'Вживати орудний: slažem se s tobom / s kolegama, ne slažem se s njima'],
        swap=[('slagati se', 'uvjerljiv'), ('ne slažem se', 'popustiti'), ('u pravu si', 'inzistirati'), ('nisi u pravu', 'opravdan'),
              ('po meni', 'dokaz')],
        ex=[('ти маєш рацію', dict(type='multiple_choice', question='Що означає «opravdan»?', answer='обґрунтований, виправданий',
                                   options=['обґрунтований, виправданий', 'контраргумент', 'перевага', 'певною мірою'], word='opravdan')),
            ('дискусія, суперечка', dict(type='multiple_choice', question='Що означає «rasprava»?', answer='обговорення, дискусія',
                                         options=['обговорення, дискусія', 'пропозиція', 'переконливий', 'доказ; підтвердження'], word='rasprava')),
            ('ти не маєш рації', dict(type='multiple_choice', question='Що означає «popustiti»?', answer='поступитися',
                                      options=['поступитися', 'аргумент', 'компроміс', 'з одного боку'], word='popustiti')),
            ('ne slažem se', dict(type='multiple_choice', question='Як хорватською «переконливий»?', answer='uvjerljiv',
                                  options=['uvjerljiv', 'nikako', 'stav', 'prijedlog'], word='uvjerljiv')),
            ('po meni', dict(type='type_answer', question='Напишіть хорватською: «наполягати»', answer='inzistirati', word='inzistirati')),
            ('Ne slažem se s tobom.', dict(type='sentence_builder', question='Складіть: «Твій аргумент не дуже переконливий.»',
                                           answer='Tvoj argument nije baš uvjerljiv.')),
            ('Po meni, to je loša ideja.', dict(type='speaking', question='Твоя вимога цілком обґрунтована.',
                                                answer='Tvoj zahtjev je potpuno opravdan.')),
            ],
    ),
    29: dict(
        note='Д6',
        title=('Сусіди: збори й шкода', 'Susjedi: sastanak stanara i šteta'),
        objectives=['Поговорити із сусідом про шкоду: протекла вода, страховка, відшкодування',
                    'Збори мешканців: дах, фасад, спільне приміщення, паркування',
                    'Вживати орудний: razgovarati sa susjedima, pred zgradom, među stanarima'],
        swap=[('glasna glazba', 'procuriti'), ('lupati', 'fasada'), ('smetati', 'popravak krova'), ('utišati', 'nadoknada štete')],
        convs=[('318010bf-019c-5e76-86ff-4cb83577f32c',
                ('Сусід нас затопив', 'Poplavio nas je susjed', 'housing', [
                    ('Darja', 'Dobar dan, ja sam Darja iz stana ispod Vas. Imamo problem.', 'Добрий день, я Дар’я з квартири під вами. У нас проблема.'),
                    ('Susjed', 'Dobar dan. Što se dogodilo?', 'Добрий день. Що сталося?'),
                    ('Darja', 'Voda je procurila kroz strop u našoj kupaonici.', 'Вода протекла крізь стелю в нашій ванній.'),
                    ('Susjed', 'Joj, oprostite! Jutros mi je pukla cijev ispod umivaonika.', 'Ой, перепрошую! Сьогодні вранці в мене лопнула труба під умивальником.'),
                    ('Darja', 'Imate li osiguranje stana? Trebat će nam nadoknada štete.', 'У вас є страховка квартири? Нам знадобиться відшкодування збитків.'),
                    ('Susjed', 'Imam. Zvat ću osiguravajuće društvo i platit ću štetu.', 'Є. Зателефоную в страхову компанію й оплачу збитки.'),
                ]))],
        ex=[('fill_in_the_blank', dict(type='fill_in_the_blank', question='Dogovorila sam se ___ susjedima oko popravka krova.', answer='sa',
                                       options=['sa', 's', 'od', 'kod'])),
            ('дошка оголошень', dict(type='multiple_choice', question='Що означає «oglasna ploča»?', answer='дошка оголошень',
                                     options=['дошка оголошень', 'фасад', 'під’їзд', 'затопити'], word='oglasna ploča')),
            ('glasna glazba', dict(type='type_answer', question='Напишіть хорватською: «фасад»', answer='fasada', word='fasada')),
            ('Oprostite što smetam.', dict(type='sentence_builder', question='Складіть: «На зборах ми домовилися про ремонт даху.»',
                                           answer='Na sastanku smo dogovorili popravak krova.')),
            ('Oh, oprostite, nisam znao da se čuje. Utišat ću.',
             dict(type='listening', question='Прослухайте і складіть фразу', answer='Jutros mi je pukla cijev ispod umivaonika.')),
            ('Glazba je jako glasna.', dict(type='speaking', question='У нас зі стелі тече вода.', answer='Kod nas curi voda sa stropa.')),
            ('write_message', dict(type='write_message', write=dict(
                situation='Напишіть оголошення на дошку: у п’ятницю о 19:00 збори мешканців, тема — ремонт даху й фасаду.',
                points=[('у п’ятницю', [['petak']]), ('збори мешканців', [['sastan']]), ('о 19:00', [['19'], ['devetnaest'], ['sedam']]),
                        ('дах і фасад', [['krov'], ['fasad']])],
                hints=['poštovani stanari', 'sastanak stanara je u petak', 'popravak krova i fasade'],
                models=['Poštovani stanari, sastanak stanara je u petak u 19 sati. Tema je popravak krova i fasade.']))),
            ],
    ),
    33: dict(
        note='Д8',
        title=('Відпустка й вихідні дні', 'Godišnji odmor i slobodni dani'),
        objectives=['Попросити відпустку й домовитися про заміну чи обмін змінами',
                    'Колективна відпустка, перенесені дні, право на відпустку',
                    'Ввічливо: Bih li mogla uzeti…? Htjela bih iskoristiti…'],
        swap=[('otvoriti bolovanje', 'zamjena smjene'), ('zatvoriti bolovanje', 'kolektivni godišnji odmor'),
              ('biti na bolovanju', 'prenijeti dane'), ('javiti se bolestan', 'pravo na godišnji')],
        convs=[('b5b1477b-4b6a-54e0-84a7-be89bf1dd927',
                ('Відпустка в серпні', 'Godišnji u kolovozu', 'work', [
                    ('Daša', 'Ivane, znaš li kad je ove godine kolektivni godišnji odmor?', 'Іване, знаєш, коли цього року колективна відпустка?'),
                    ('Ivan', 'Prva dva tjedna u kolovozu. Tvrtka je tada zatvorena.', 'Перші два тижні серпня. Фірма тоді зачинена.'),
                    ('Daša', 'Super. A imam još pet dana od prošle godine.', 'Супер. А в мене ще п’ять днів з минулого року.'),
                    ('Ivan', 'Prenesene dane moraš iskoristiti do kraja lipnja.', 'Перенесені дні треба використати до кінця червня.'),
                    ('Daša', 'Onda ću uzeti produženi vikend u svibnju. A tko radi umjesto mene u subotu?',
                     'Тоді візьму довгі вихідні в травні. А хто працює замість мене в суботу?'),
                    ('Ivan', 'Mogu ja. Dogovorit ćemo zamjenu smjene.', 'Можу я. Домовимося про обмін змінами.'),
                ]))],
        ex=[('заява на відпустку', dict(type='multiple_choice', question='Що означає «zahtjev za godišnji»?', answer='заява на відпустку',
                                        options=['заява на відпустку', 'передача справ', 'право на відпустку', 'відпустка по догляду за дитиною'],
                                        word='zahtjev za godišnji')),
            ('декретна відпустка (у пологах)', dict(type='multiple_choice', question='Що означає «rodiljni dopust»?',
                                                    answer='декретна відпустка (у пологах)',
                                                    options=['декретна відпустка (у пологах)', 'погодити заяву', 'обмін змінами', 'дні відпустки'],
                                                    word='rodiljni dopust')),
            ('javiti se bolestan', dict(type='multiple_choice', question='Як хорватською «обмін змінами»?', answer='zamjena smjene',
                                        options=['zamjena smjene', 'primopredaja', 'neplaćeni dopust', 'vratiti se na posao'], word='zamjena smjene')),
            ('Marko je na bolovanju do petka.', dict(type='sentence_builder', question='Складіть: «У серпні в нас колективна відпустка.»',
                                                     answer='U kolovozu imamo kolektivni godišnji odmor.')),
            ('Idem danas. Otvorit će mi bolovanje.',
             dict(type='listening', question='Прослухайте і складіть фразу', answer='Prva dva tjedna u kolovozu. Tvrtka je tada zatvorena.')),
            ('Javljam se bolesna.', dict(type='speaking', question='Я хочу перенести дні на наступний рік.',
                                         answer='Želim prenijeti dane u iduću godinu.')),
            ('mediation', dict(type='mediation', mediation=dict(
                friend='Скажи шефу, що я хочу перенести решту днів відпустки на наступний рік.',
                points=[('перенести', [['prenije'], ['prenes']]), ('решту днів', [['preostal'], ['dan']]), ('наступний рік', [['iduć'], ['sljedeć']])],
                models=['Moja kolegica želi prenijeti preostale dane godišnjeg u iduću godinu.']))),
            ],
    ),
    44: dict(
        note='Д8',
        objectives=['Оформити лікарняний для себе й по догляду за дитиною: otvoriti, zatvoriti, produžiti bolovanje',
                    'Описати стан безособово: Muka mi je, Djetetu je loše'],
        swap=[('povraćati', 'otvoriti bolovanje'), ('proljev', 'zatvoriti bolovanje')],
        add=['javiti se bolestan'],
        convs=[('c590ba13-4ead-5ddf-a528-f7ed37bbf8be',
                ('Довідка для садочка', 'Ispričnica za vrtić', 'health', [
                    ('Darja', 'Dobar dan, Filip je bio bolestan tjedan dana. Danas mu je bolje.', 'Добрий день, Філіп хворів тиждень. Сьогодні йому краще.'),
                    ('Pedijatrica', 'Drago mi je. Ima li još temperaturu?', 'Я рада. У нього ще є температура?'),
                    ('Darja', 'Nema već dva dana. Može li se vratiti u vrtić?', 'Уже два дні немає. Він може повернутися в садочок?'),
                    ('Pedijatrica', 'Može od ponedjeljka. Evo ispričnice za vrtić.', 'Може з понеділка. Ось довідка для садочка.'),
                    ('Darja', 'Hvala. Moram li i ja nešto napraviti zbog posla?', 'Дякую. Мені теж треба щось зробити через роботу?'),
                    ('Pedijatrica', 'Da, Vaša liječnica Vam mora zatvoriti bolovanje radi njege djeteta.',
                     'Так, ваша лікарка має закрити вам лікарняний по догляду за дитиною.'),
                ]))],
        ex=[('довідка про тимчасову непрацездатність',
             dict(type='multiple_choice', question='Що означає «potvrda o privremenoj nesposobnosti»?', answer='довідка про тимчасову непрацездатність',
                  options=['довідка про тимчасову непрацездатність', 'пити багато рідини', 'закрити лікарняний', 'мене нудить'],
                  word='potvrda o privremenoj nesposobnosti')),
            ('zarazan', dict(type='multiple_choice', question='Як хорватською «заразний»?', answer='zarazan',
                             options=['zarazan', 'javiti poslodavcu', 'vratiti se u vrtić', 'otvoriti bolovanje'], word='zarazan')),
            ('proljev', dict(type='multiple_choice', question='Як хорватською «закрити лікарняний»?', answer='zatvoriti bolovanje',
                             options=['zatvoriti bolovanje', 'dehidracija', 'njega djeteta', 'ležati'], word='zatvoriti bolovanje')),
            ('povraćati', dict(type='type_answer', question='Напишіть хорватською: «дитяча лікарка, педіатриня»', answer='pedijatrica',
                               word='pedijatrica')),
            ],
    ),
    38: dict(
        note='Д5',
        objectives=['Домовитися з майстром про кошторис, термін, оплату й гарантію',
                    'Родовий: bez dijelova, zbog kašnjenja, umjesto stare brave'],
        swap=[('kapati', 'rok završetka'), ('iskočio je osigurač', 'kašnjenje radova'), ('začepiti se', 'plaćanje gotovinom')],
        convs=[('3b36368a-5bfe-5451-a5a1-b345a714350f',
                ('Міняємо замок', 'Mijenjamo bravu', 'housing', [
                    ('Darja', 'Dobar dan, zovem zbog brave na ulaznim vratima. Ključ se teško okreće.',
                     'Добрий день, телефоную щодо замка на вхідних дверях. Ключ важко повертається.'),
                    ('Bravar', 'Najbolje je zamijeniti bravu. Mogu doći sutra ujutro.', 'Найкраще замінити замок. Можу приїхати завтра вранці.'),
                    ('Darja', 'Koliko košta izlazak na teren?', 'Скільки коштує виїзд майстра?'),
                    ('Bravar', 'Trideset eura, a nova brava s ugradnjom oko sto.', 'Тридцять євро, а новий замок зі встановленням — близько ста.'),
                    ('Darja', 'Je li moguće plaćanje gotovinom?', 'Можна оплатити готівкою?'),
                    ('Bravar', 'Može gotovinom ili karticom. Dobit ćete račun i jamstvo na radove.',
                     'Можна готівкою або карткою. Отримаєте рахунок і гарантію на роботи.'),
                ])),
               ('83c1bbe5-d130-5039-bf75-94e1be89f88a',
                ('Кошторис на плитку', 'Predračun za pločice', 'housing', [
                    ('Ivan', 'Dobar dan, dobili smo Vaš predračun za pločice u kupaonici.', 'Добрий день, ми отримали ваш кошторис на плитку у ванній.'),
                    ('Keramičar', 'Odlično. Imate li pitanja?', 'Чудово. Маєте запитання?'),
                    ('Ivan', 'Koji je rok završetka radova?', 'Який термін завершення робіт?'),
                    ('Keramičar', 'Deset radnih dana, ako materijal stigne na vrijeme.', 'Десять робочих днів, якщо матеріал прибуде вчасно.'),
                    ('Ivan', 'A ako dođe do kašnjenja radova?', 'А якщо буде затримка робіт?'),
                    ('Keramičar', 'Javit ću Vam odmah. Za svaki tjedan kašnjenja dajem popust.', 'Я одразу вам повідомлю. За кожен тиждень затримки даю знижку.'),
                ]))],
        ex=[('fill_in_the_blank', dict(type='fill_in_the_blank', question='Majstor je došao bez ___.', answer='dijelova',
                                       options=['dijelova', 'dijelovi', 'dijelove', 'dijelovima'])),
            ('замок', dict(type='multiple_choice', question='Що означає «brava»?', answer='замок (дверний)',
                           options=['замок (дверний)', 'маляр (стін)', 'затримка робіт', 'матеріал'], word='brava')),
            ('soboslikar', dict(type='multiple_choice', question='Як хорватською «маляр (стін)»?', answer='soboslikar',
                                options=['soboslikar', 'stolar', 'rok završetka', 'procjena'], word='soboslikar')),
            ('Slavina kapa cijelu noć.', dict(type='sentence_builder', question='Складіть: «Який термін завершення робіт?»',
                                              answer='Koji je rok završetka radova?')),
            ('Opet iskače zbog perilice.', dict(type='listening', question='Прослухайте і складіть фразу', answer='Je li moguće plaćanje gotovinom?')),
            ('Začepio se odvod u kuhinji.', dict(type='speaking', question='Чи буде затримка робіт?', answer='Hoće li biti kašnjenja radova?')),
            ('write_message', dict(type='write_message', write=dict(
                situation='Напишіть майстрові: попросіть кошторис на плитку у ванній і спитайте про термін завершення робіт.',
                points=[('кошторис', [['predračun'], ['procjen']]), ('плитка у ванній', [['pločic']]), ('термін завершення', [['rok'], ['završ'], ['kada']])],
                hints=['molim Vas predračun', 'pločice u kupaonici', 'rok završetka radova'],
                models=['Dobar dan, molim Vas predračun za pločice u kupaonici. Koji je rok završetka radova?']))),
            ],
    ),
    70: dict(
        note='Д7',
        objectives=['Знати, як поводитися в гостях і за столом: gostoprimstvo, nutkati, poklon za domaćina',
                    'Присвійні: domaćičin kolač, Ivanov rođendan, tuđa kuća'],
        swap=[('persirati', 'gostoprimstvo'), ('tikati', 'nutkati')],
        convs=[('4b330410-5e4a-5b9e-9470-0f20bcc5f475',
                ('Обід у батьків Івани', 'Ručak kod Ivaninih roditelja', 'small_talk', [
                    ('Gospođa Horvat', 'Izvolite, sjednite. Danas imamo juhu, pečenu piletinu i kolač.', 'Прошу, сідайте. Сьогодні маємо суп, печене курча й пиріг.'),
                    ('Darja', 'Hvala, sve izgleda prekrasno. Hvala na gostoprimstvu!', 'Дякую, усе виглядає чудово. Дякую за гостинність!'),
                    ('Gospođa Horvat', 'Uzmite još malo piletine, nemojte se sramiti.', 'Візьміть ще трохи курятини, не соромтеся.'),
                    ('Darja', 'Hvala, stvarno sam sita. Bilo je jako ukusno.', 'Дякую, я справді сита. Було дуже смачно.'),
                    ('Ivana', 'Mama, nemoj je toliko nutkati!', 'Мамо, не припрошуй її так!'),
                    ('Gospođa Horvat', 'Dobro, dobro. Ali kolač morate probati, to je običaj u ovoj kući.',
                     'Добре, добре. Але пиріг мусите скуштувати, такий звичай у цьому домі.'),
                ]))],
        ex=[('Starijima se persira.', dict(type='sentence_builder', question='Складіть: «Дякую за гостинність!»', answer='Hvala na gostoprimstvu!')),
            ('listening_dialogue', dict(type='listening_dialogue', listening=dict(
                kind='dialogue', situation='Дар’я питає Івану, як поводитися на святковому обіді.', script=[
                    ('Darja', 'Kada se počinje jesti, odmah ili kad svi sjednu?', 'Коли починають їсти — одразу чи коли всі сядуть?'),
                    ('Ivana', 'Kad domaćica kaže „Dobar tek!“. Prije toga se čeka.', 'Коли господиня скаже «Смачного!». До того чекають.'),
                    ('Darja', 'A smijem li odbiti drugi tanjur?', 'А можна відмовитися від добавки?'),
                    ('Ivana', 'Smiješ, ali pohvali hranu. Domaćica će te ionako nutkati.', 'Можна, але похвали їжу. Господиня все одно тебе припрошуватиме.'),
                ], questions=[
                    ('Коли починають їсти?', ['коли господиня скаже «Смачного!»', 'одразу, як принесуть їжу', 'після тосту'], 0, 1),
                    ('Що треба зробити, якщо відмовляєшся від добавки?', 'похвалити їжу', ['похвалити', 'похвалити страву', 'похвалити господиню'], 3),
                    ('Що все одно робитиме господиня?', ['принесе десерт', 'припрошуватиме', 'образиться'], 1, 3),
                ]))),
            ],
    ),
}

# Однакові назви діалогів (§5 плану): нова назва діалогу в пізнішому уроці A2 (id → (урок, стара назва, (title_ua, title_hr)))
RENAME_CONVS = {
    '2c8cd7ee-e3d3-58d3-8ffe-420bf19fdb8e': ('A2 3', 'Na recepciji', ('Реєстрація в готелі', 'Prijava u hotel')),
    '9140c599-ceba-5bbb-8214-54c16f55a70c': ('A2 4', 'Račun', ('Помилка в рахунку', 'Pogreška u računu')),
    'dc69dcd8-ddd4-5c6c-b7c8-2d9b9d770f84': ('A2 10', 'Rezultati', ('Рейтинговий список', 'Rang-lista')),
    '14d9a946-c3e1-58cf-bff8-0c2cca867149': ('A2 35', 'Loša vijest', ('Мене звільнили', 'Dobio sam otkaz')),
    '82cdf22b-ae0c-5783-898e-bed827a54a1e': ('A2 48', 'U policijskoj upravi', ('Обмін водійського посвідчення', 'Zamjena vozačke dozvole')),
    'b4dd1542-9a39-5b6b-b285-9b12c3a68061': ('A2 65', 'Rad od kuće', ('Робота з дому: за і проти', 'Rad od kuće: za i protiv')),
}

# ---------------------------------------------------------------------------------------------- новий урок A2.11 (місце 5)
NEW_LESSON = dict(
    slug='zadar', title=('Далмація: Задар і околиці', 'Dalmacija: Zadar i okolica'), situation='travel', grammar='POSV',
    objectives=['Розповісти про Задар і околиці: Нін, Паклениця, Біоград, острови',
                'Прикметники від назв місць: zadarski, ninski, biogradski',
                'Впізнати далматинське розмовне слово: ići na đir'],
    words=['zadarski', 'solana', 'morska sol', 'ljekovito blato', 'crkvica', 'kraljevski grad', 'starohrvatski', 'arheološko nalazište',
           'penjač', 'penjalište', 'stijena', 'uže', 'slobodno penjanje', 'marina', 'izletnički brod', 'cjelodnevni izlet',
           'ribarska brodica', 'ulov', 'turistička sezona', 'izvan sezone', 'tempo života', 'sezonski posao', 'đir'],
    scenes=[
        ('Вихідні в Ніні', 'Vikend u Ninu', [
            ('Darja', 'Dašo, što da vidim blizu Zadra ako imam samo jedan dan?', 'Дашо, що мені подивитися біля Задара, якщо в мене лише один день?'),
            ('Daša', 'Idi u Nin. To je stari kraljevski grad, pola sata od Zadra.', 'Їдь у Нін. Це давнє королівське місто, пів години від Задара.'),
            ('Darja', 'Što ima tamo?', 'Що там є?'),
            ('Daša', 'Malu starohrvatsku crkvicu, solanu i plažu s ljekovitim blatom.', 'Маленьку давньохорватську церковцю, солеварню й пляж із лікувальною грязю.'),
            ('Darja', 'Može li se kupiti sol iz solane?', 'А можна купити сіль із солеварні?'),
            ('Daša', 'Može, ninska morska sol je odličan suvenir.', 'Можна, нінська морська сіль — чудовий сувенір.'),
        ]),
        ('Жити в Задарі', 'Živjeti u Zadru', [
            ('Marko', 'Darja, kako ti je život u Zadru?', 'Дар’є, як тобі живеться в Задарі?'),
            ('Darja', 'Lijepo. Tempo života je sporiji nego u Zagrebu.', 'Гарно. Темп життя повільніший, ніж у Загребі.'),
            ('Marko', 'A ljeti, za vrijeme turističke sezone?', 'А влітку, під час туристичного сезону?'),
            ('Darja', 'Tada je gužva, a ja radim sezonski posao na izletničkom brodu.', 'Тоді тиснява, а я працюю на сезонній роботі на прогулянковому кораблі.'),
            ('Marko', 'Što radiš izvan sezone?', 'Що робиш поза сезоном?'),
            ('Darja', 'Vikendom idem u Paklenicu na slobodno penjanje, a navečer na đir po rivi.',
             'На вихідних їжджу в Пакленицю на скелелазіння, а ввечері — прогулятися набережною.'),
        ]),
    ],
    fill=('U ___ solani sol se i danas skuplja ručno.', 'ninskoj', ['Ninu', 'ninski', 'Nina']),
    build=[('Складіть: «У Задарі темп життя повільніший.»', 'U Zadru je tempo života sporiji.'),
           ('Складіть: «Прогулянковий корабель відпливає о дев’ятій.»', 'Izletnički brod polazi u devet.')],
    listen='Idi u Nin. To je stari kraljevski grad, pola sata od Zadra.',
    speak=[('Де тут можна займатися скелелазінням?', 'Gdje se ovdje može slobodno penjati?'),
           ('Поза сезоном ціни нижчі.', 'Izvan sezone su cijene niže.')],
    listening=dict(kind='announcement', situation='Оголошення на прогулянковому кораблі в Задарі.', script=[
        ('Dobro došli na cjelodnevni izlet na Kornate!', 'Ласкаво просимо на одноденну екскурсію на Корнати!'),
        ('Prvo stajemo u uvali Lojena, gdje se možete kupati sat vremena.', 'Спершу зупиняємося в бухті Лоєна, де можна купатися годину.'),
        ('Ručak je na brodu oko jedan sat.', 'Обід на кораблі близько першої.'),
        ('U Zadar se vraćamo u šest sati navečer.', 'До Задара повертаємося о шостій вечора.'),
    ], questions=[
        ('Скільки годин можна купатися в бухті?', '1', ['одну', 'годину', '1 годину', 'одна'], 1),
        ('Де обід?', ['у ресторані на острові', 'на кораблі', 'у Задарі'], 1, 2),
        ('Коли повернуться до Задара?', ['о 16:00', 'о 20:00', 'о 18:00'], 2, 3),
    ]),
    write=dict(situation='Напишіть подрузі: ви в Ніні, купили морську сіль у солеварні, а завтра йдете на скелелазіння в Пакленицю.',
               points=[('Нін', [['nin']]), ('морська сіль', [['sol']]), ('скелелазіння в Паклениці', [['penja'], ['paklenic']])],
               hints=['pozdrav iz Nina', 'kupila sam morsku sol', 'sutra idem na slobodno penjanje'],
               models=['Pozdrav iz Nina! U solani sam kupila morsku sol, a sutra idem na slobodno penjanje u Paklenicu.']),
    mediation=dict(friend='Спитай у порту, о котрій відпливає прогулянковий корабель на Корнати і скільки коштує квиток.',
                   points=[('прогулянковий корабель', [['brod']]), ('о котрій', [['kad'], ['sat']]), ('скільки коштує', [['košt'], ['cijen']])],
                   models=['Kada polazi izletnički brod na Kornate i koliko košta karta?']),
)
