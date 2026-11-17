"""
Дублі A0 · 2026-11-17 — дані для scripts/gen_a0_dupes.py (план docs/proposals/2026-11-16_lesson_duplicates.md, PR 2б).

Рішення власника 2026-11-17 (дослівно — docs/DECISIONS.md):
  Д4  — урок 64 «Квиток на автобус»: прибрати mjesečna karta, presjesti, kontrolor (вони — зміст A1-31 «Проїзний»);
  Д9  — урок 58 «Одяг: що купити?»: прибрати kabina, probati, pristajati, prevelik, premalen (зміст A1-24 «У приміряльні»);
  Д10 — урок 30 «Свята й привітання»: лише привітання — прибрати Dan državnosti, neradni dan, pisanica (є в A1-96, A1-97),
        діалог «Prije Božića» → «Sretan rođendan, Dašo!»;
  Д11 — урок 69 «Допоможіть!»: лишає «допоможіть, пожежа» й «викличте пожежників», + вираз zovite vatrogasce;
  Д12 — варіант Б: урок 68 «У лікаря й в аптеці» → два уроки: «У лікаря» (68) і новий «В аптеці» (69); далі номери +1 (72 → 73).
Назви діалогів: «Na kolodvoru» — в уроках 7 і 26; другий (урок 26) → «Vlak za Rijeku» (зміст інший — лише назва).

Слово не зникає з курсу (принцип 1 плану): kabina, probati, pristajati є лише в уроці 58 — переходять в A1-24
«У приміряльні» (там 17 слів → 20). mjesečna karta, presjesti, kontrolor — в A1-31 уже є mjesečna pokazna karta, presjedati,
kontrolor karata; prevelik, premalen — в A1-24; Dan državnosti, neradni dan, pisanica — в A1-96 / A1-97.

Формат: заміна слова — на тому самому місці уроку (lesson_items.item_id), нове слово — (лема, переклад, частина мови,
рід / вид, приклад); заміна вправи — за відповіддю старої вправи (тип той самий, місце те саме). Імена — частіше Даша / Дар’я.
"""

DATE = '20261117'

# Слова словника, яких ще немає в жодному уроці (переклад, рівень — з робочої бази 2026-11-17)
EXISTING = {
    'odijelo': ('костюм', 'A1'), 'glavobolja': ('головний біль', 'A1'), 'bolest': ('хвороба', 'A1'), 'slab': ('слабкий', 'A1'),
    'jak': ('сильний', 'A1'), 'izmjeriti': ('виміряти', 'A2'), 'sredstvo': ('засіб', 'A2'),
}

# Нові слова (їх немає в словнику): лема, переклад, частина мови, рід / вид, приклад
NEW_LEXEMES = {
    30: [
        ('hvala na čestitki', 'дякую за привітання', 'ph', '', 'Hvala na čestitki, Dašo! Baš si draga.'),
        ('poželjeti', 'побажати', 'v', 'pfv:željeti', 'Svi su mi poželjeli sretan rođendan.'),
        ('zaželjeti želju', 'загадати бажання', 'ph', '', 'Ugasi svjećice i zaželi želju!'),
    ],
    58: [
        ('obući', 'одягнути, вдягнути', 'v', 'pfv:oblačiti', 'Što ćeš obući na vjenčanje?'),
        ('izlog', 'вітрина', 'n', 'm', 'Ona crvena haljina u izlogu je jako lijepa.'),
        ('bluza', 'блузка', 'n', 'f', 'Kupila sam bijelu bluzu za posao.'),
        ('donje rublje', 'нижня білизна', 'ph', 'n', 'Donje rublje je na drugom katu.'),
    ],
    64: [
        ('sljedeća stanica', 'наступна зупинка', 'ph', 'f', 'Sljedeća stanica je Glavni kolodvor.'),
        ('automat za karte', 'квитковий автомат', 'ph', 'm', 'Kartu možete kupiti na automatu za karte.'),
        ('slobodno mjesto', 'вільне місце', 'ph', 'n', 'U tramvaju nema nijednog slobodnog mjesta.'),
    ],
    68: [
        ('dežurni liječnik', 'черговий лікар', 'ph', 'm', 'Subotom u domu zdravlja radi dežurni liječnik.'),
        ('ostati u krevetu', 'залишатися в ліжку, лежати (коли хворий)', 'ph', '', 'Liječnica kaže da trebam ostati u krevetu dva dana.'),
        ('tekućina', 'рідина', 'n', 'f', 'Kad imate temperaturu, pijte puno tekućine.'),
    ],
    69: [  # новий урок «В аптеці»
        ('ljekarnica', 'фармацевтка (жінка-провізор)', 'n', 'f', 'Ljekarnica mi je objasnila kako uzimati lijek.'),
        ('na recept', 'за рецептом', 'ph', '', 'Ovaj lijek možete kupiti samo na recept.'),
        ('dežurna ljekarna', 'чергова аптека', 'ph', 'f', 'Noću radi samo dežurna ljekarna.'),
        ('paracetamol', 'парацетамол', 'n', 'm', 'Za temperaturu uzmite paracetamol.'),
        ('tablete za grlo', 'таблетки для горла', 'ph', 'f_pl', 'Kupila sam tablete za grlo bez šećera.'),
        ('grlobolja', 'біль у горлі', 'n', 'f', 'Imam grlobolju i teško govorim.'),
        ('uputa', 'інструкція (до ліків)', 'n', 'f', 'Prije uzimanja lijeka pročitajte uputu.'),
        ('za djecu', 'для дітей', 'ph', '', 'Imate li sirup za djecu?'),
        ('dječji', 'дитячий', 'adj', '', 'Trebam dječji sirup protiv kašlja.'),
        ('maska', 'маска', 'n', 'f', 'U ljekarni možete kupiti masku za lice.'),
        ('sve zajedno', 'усе разом', 'ph', '', 'Koliko košta sve zajedno?'),
    ],
    70: [  # урок 69 «Допоможіть!» (після нового уроку — 70)
        ('zovite vatrogasce', 'викликайте пожежників', 'ph', '', 'Kuća gori, zovite vatrogasce!'),
    ],
}
FORMULAIC = {'hvala na čestitki', 'zaželjeti želju', 'zovite vatrogasce', 'sve zajedno'}

LESSON_IDS = {
    26: '39b1e31f-b573-5000-9713-1660688c3cc9', 30: 'd7cf3059-0d92-5215-8ef4-ad699e317b10', 58: 'b01e2f67-3e7a-5ab6-99bb-fae374f431e0',
    64: 'e5b81eb1-8ea8-5ff4-a987-e5e46421302b', 68: 'fbc71f82-e715-5bab-a990-b8542fb0fe01', 69: '48f26e9d-96c5-5189-8ec6-db1f9d58e200',
}
A1_24 = '7fb1b6e5-93b4-5776-b82b-25e7769fd32d'   # A1 урок 24 «У приміряльні: розмір і фасон»
TO_A1_24 = ['kabina', 'probati', 'pristajati']   # слова, яких більше немає в жодному уроці A0 і яких немає в A1

# ---------------------------------------------------------------------------------------------- зміни наявних уроків
# swap — (стара лема, нова лема) на тому самому місці; conv — (id старого діалогу, новий діалог); ex — (відповідь старої
# вправи, нова вправа); вправа: type, question, answer, options (для вибору), word (лема — для вправ на слово),
# task (для письма й переказу — формат scripts/gen_writing.py).
CHANGES = {
    30: dict(
        note='Д10',
        objectives=['Назвати головні свята в Хорватії: Božić, Uskrs, Nova godina',
                    'Привітати зі святом і з днем народження: Sretan Božić! Sve najbolje!',
                    'Подякувати за привітання й побажати щось: hvala na čestitki, želim ti…'],
        swap=[('neradni dan', 'hvala na čestitki'), ('pisanica', 'poželjeti'), ('Dan državnosti', 'zaželjeti želju')],
        conv=('131ad945-b721-555a-9dcd-bb89a6d97acd',
              ('З днем народження, Дашо!', 'Sretan rođendan, Dašo!', 'small_talk', [
                  ('Ivana', 'Sretan rođendan, Dašo! Sve najbolje!', 'З днем народження, Дашо! Всього найкращого!'),
                  ('Daša', 'Hvala, Ivana! Uđi, torta je na stolu.', 'Дякую, Івано! Заходь, торт на столі.'),
                  ('Ivana', 'Evo, mali poklon za tebe. Želim ti puno sreće!', 'Ось маленький подарунок для тебе. Бажаю тобі багато щастя!'),
                  ('Daša', 'Kako lijepo! Hvala na čestitki i na poklonu.', 'Як гарно! Дякую за привітання й за подарунок.'),
                  ('Ivana', 'A sad zaželi želju!', 'А тепер загадай бажання!'),
                  ('Daša', 'Već sam je zaželjela. Ali to je tajna!', 'Я вже загадала. Але це таємниця!'),
              ])),
        ex=[('pisanica', dict(type='type_answer', question='Напишіть хорватською: «побажати»', answer='poželjeti', word='poželjeti')),
            ('Na Badnjak smo kod mojih roditelja.', dict(type='listening', question='Прослухайте і складіть фразу', answer='A sad zaželi želju!'))],
    ),
    58: dict(
        note='Д9',
        objectives=['Назвати одяг і взуття: majica, hlače, haljina, bluza, odijelo',
                    'Показати, що купити: ovaj, taj, onaj («ova bluza», «ono odijelo»)',
                    'Сказати, що ви вдягнете: «Što ćeš obući?»'],
        swap=[('probati', 'obući'), ('kabina', 'izlog'), ('pristajati', 'bluza'), ('prevelik', 'odijelo'), ('premalen', 'donje rublje')],
        conv=('0119ff02-cf85-577b-8109-b72609a0212e',
              ('Біля вітрини', 'Ispred izloga', 'shopping', [
                  ('Darja', 'Dašo, vidi ovu bluzu u izlogu!', 'Дашо, глянь на цю блузку у вітрині!'),
                  ('Daša', 'Lijepa je! A sviđa li ti se ono odijelo?', 'Гарна! А тобі подобається он той костюм?'),
                  ('Darja', 'Sviđa mi se. Marku treba odijelo za vjenčanje.', 'Подобається. Маркові потрібен костюм на весілля.'),
                  ('Daša', 'A što ćeš ti obući na vjenčanje?', 'А що вдягнеш ти на весілля?'),
                  ('Darja', 'Ovu plavu haljinu i crne cipele.', 'Цю синю сукню й чорні туфлі.'),
                  ('Daša', 'Super! Uđimo, imaju i donje rublje na popustu.', 'Чудово! Заходьмо, у них і нижня білизна зі знижкою.'),
              ])),
        ex=[('пасувати, личити; підходити за розміром',
             dict(type='multiple_choice', question='Що означає «izlog»?', answer='вітрина',
                  options=['сорочка', 'вітрина', 'пальто', 'спідниця'], word='izlog')),
            ('Mogu li probati ovu haljinu?',
             dict(type='sentence_builder', question='Складіть: «Мені подобається он та блузка у вітрині.»', answer='Sviđa mi se ona bluza u izlogu.')),
            ('Ove hlače su mi prevelike.',
             dict(type='sentence_builder', question='Складіть: «Що ти вдягнеш завтра?»', answer='Što ćeš obući sutra?')),
            ('Koju veličinu nosite?', dict(type='listening', question='Прослухайте і складіть фразу', answer='Ovu plavu haljinu i crne cipele.')),
            ('Ona crna. Ova je premalena za tebe.', dict(type='listening', question='Прослухайте і складіть фразу', answer='Trebam čarape i topli džemper.')),
            ('Gdje je kabina?', dict(type='speaking', question='Скільки коштує ця блузка?', answer='Koliko košta ova bluza?')),
            ('Ova košulja mi pristaje.', dict(type='speaking', question='Мені подобається той светр.', answer='Sviđa mi se taj džemper.')),
            ('Traperice su prevelike. Mogu li ih zamijeniti za manju veličinu?', dict(type='write_message', write=dict(
                situation='Ви в торговому центрі. Напишіть Дар’ї в чат, що ви купили: білу блузку й теплий светр, а Маркові — костюм.',
                points=[('блузка', [['bluz']]), ('светр', [['džemper']]), ('костюм для Марка', [['odijel']])],
                hints=['kupila sam', 'bluza', 'džemper', 'odijelo'],
                models=['Kupila sam bijelu bluzu i topli džemper. Marku sam kupila odijelo.',
                        'Kupio sam bluzu i džemper, a za Marka odijelo.']))),
            ('Примірочні на першому поверсі, можна взяти не більше трьох речей.', dict(type='mediation', mediation=dict(
                source='SNIŽENJE!\nSva odjeća –30 %.\nDonje rublje je na drugom katu.',
                friend='Що тут написано? Є знижки?',
                points=[('знижка 30 % на весь одяг', [['30'], ['знижк']]), ('білизна — на другому поверсі', [['білизн', 'друг']])],
                models=['Так, на весь одяг знижка 30 %. Нижня білизна — на другому поверсі.']))),
            ],
    ),
    64: dict(
        note='Д4',
        objectives=['Купити квиток: povratna karta, karta u jednom smjeru, automat za karte',
                    'Запитати, який автобус чи трамвай їде і де виходити',
                    'Зрозуміти, з якого перону відправлення і яка наступна зупинка'],
        swap=[('mjesečna karta', 'sljedeća stanica'), ('presjesti', 'automat za karte'), ('kontrolor', 'slobodno mjesto')],
        conv=('d7497f57-33d8-51d1-bb45-c01cad0a2698',
              ('Яка наступна зупинка?', 'Koja je sljedeća stanica?', 'transport', [
                  ('Darja', 'Oprostite, je li ovo mjesto slobodno?', 'Перепрошую, це місце вільне?'),
                  ('Gospođa', 'Jest, izvolite sjesti.', 'Так, сідайте.'),
                  ('Darja', 'Hvala. Koja je sljedeća stanica?', 'Дякую. Яка наступна зупинка?'),
                  ('Gospođa', 'Glavni kolodvor. Gdje vi izlazite?', 'Головний вокзал. А ви де виходите?'),
                  ('Darja', 'Na kolodvoru. Kartu sam kupila na automatu.', 'На вокзалі. Квиток я купила в автоматі.'),
                  ('Gospođa', 'Onda izađite sada, evo stanice!', 'Тоді виходьте зараз, ось зупинка!'),
              ])),
        ex=[('presjesti', dict(type='multiple_choice', question='Як хорватською «наступна зупинка»?', answer='sljedeća stanica',
                               options=['peron', 'linija', 'sljedeća stanica', 'putnik'], word='sljedeća stanica')),
            ('Gdje mogu kupiti kartu?', dict(type='listening', question='Прослухайте і складіть фразу', answer='Koja je sljedeća stanica?'))],
    ),
    68: dict(
        note='Д12',
        title=('У лікаря', 'Kod liječnika'),
        objectives=['Записатися до лікаря й розповісти про симптоми: imam temperaturu, kašalj, glavobolju',
                    'Зрозуміти лікаря: pregled, uputnica, bolovanje, «ostanite u krevetu»',
                    'Знайти чергового лікаря ввечері чи у вихідні'],
        swap=[('ljekarna', 'glavobolja'), ('ljekarnik', 'bolest'), ('recept', 'slab'), ('lijek', 'jak'), ('tableta', 'izmjeriti'),
              ('sirup', 'dežurni liječnik'), ('protiv bolova', 'ostati u krevetu'), ('dnevno', 'tekućina')],
        # діалог «U ljekarni» переходить у новий урок «В аптеці»; на його місці — новий
        move_conv='1e4899ae-60f8-5de7-91fb-9517b913cbda',
        conv=(None,
              ('У чергового лікаря', 'Kod dežurnog liječnika', 'health', [
                  ('Liječnik', 'Dobra večer. Kako vam mogu pomoći?', 'Добрий вечір. Чим можу допомогти?'),
                  ('Darja', 'Imam jaku glavobolju i osjećam se slabo.', 'У мене сильний головний біль, і я почуваюся слабкою.'),
                  ('Liječnik', 'Sjednite, molim. Da vam izmjerim tlak i temperaturu.', 'Сідайте, будь ласка. Зараз виміряю вам тиск і температуру.'),
                  ('Darja', 'Je li to nešto opasno?', 'Це щось небезпечне?'),
                  ('Liječnik', 'Nije, to je prehlada. Ostanite u krevetu dva dana i pijte puno tekućine.',
                   'Ні, це застуда. Полежте в ліжку два дні й пийте багато рідини.'),
                  ('Darja', 'Hvala, doktore.', 'Дякую, лікарю.'),
              ])),
        ex=[('рецепт', dict(type='multiple_choice', question='Що означає «glavobolja»?', answer='головний біль',
                            options=['кашель', 'тиск', 'головний біль', 'поліклініка'], word='glavobolja')),
            ('tableta', dict(type='multiple_choice', question='Як хорватською «рідина»?', answer='tekućina',
                             options=['gripa', 'tekućina', 'uputnica', 'tlak'], word='tekućina')),
            ('sirup', dict(type='type_answer', question='Напишіть хорватською: «виміряти»', answer='izmjeriti', word='izmjeriti')),
            ('Imate li i nešto protiv bolova?', dict(type='listening', question='Прослухайте і складіть фразу',
                                                     answer='Ostanite u krevetu dva dana i pijte puno tekućine.')),
            ('Gdje je najbliža ljekarna?', dict(type='speaking', question='У мене сильний головний біль.', answer='Imam jaku glavobolju.')),
            ('По одній таблетці тричі на день після їжі, і не пити алкоголь.', dict(type='mediation', mediation=dict(
                source='DEŽURNI LIJEČNIK\nSubota i nedjelja: 8 – 20 h\nUlaz B',
                friend='Що тут написано? Лікар працює у вихідні?',
                points=[('черговий лікар', [['чергов']]), ('у суботу й неділю', [['субот'], ['неділ'], ['вихідн']]),
                        ('з 8 до 20', [['8', '20']])],
                models=['Так, тут написано: черговий лікар працює в суботу й неділю з 8 до 20, вхід B.']))),
            ],
    ),
    69: dict(note='Д11', add=['zovite vatrogasce']),
}

# Назва діалогу уроку 26 (така сама, як у уроці 7: «Na kolodvoru»)
RENAME_CONV = ('31f40ede-635a-54e2-9a86-c6b199479205', ('Потяг до Рієки', 'Vlak za Rijeku'))

# ---------------------------------------------------------------------------------------------- новий урок «В аптеці»
PHARMACY = dict(
    slug='pharmacy', title=('В аптеці', 'U ljekarni'), situation='health', grammar='Ввічливість: ti і Vi',
    objectives=['Купити ліки в аптеці: lijek, tableta, sirup, protiv bolova',
                'Запитати, чи потрібен рецепт, і зрозуміти інструкцію',
                'Знайти чергову аптеку вночі й купити щось для дитини'],
    moved=['ljekarna', 'ljekarnik', 'recept', 'lijek', 'tableta', 'sirup', 'protiv bolova', 'dnevno'],   # з уроку 68
    known=['sredstvo'],
    scene2=('Чергова аптека', 'Dežurna ljekarna', [
        ('Daša', 'Dobra večer. Je li ovo dežurna ljekarna?', 'Добрий вечір. Це чергова аптека?'),
        ('Ljekarnica', 'Jest, izvolite. Što trebate?', 'Так, прошу. Що вам потрібно?'),
        ('Daša', 'Kći ima grlobolju i temperaturu. Imate li nešto za djecu?', 'У доньки болить горло й температура. У вас є щось для дітей?'),
        ('Ljekarnica', 'Imamo dječji sirup s paracetamolom. Nije na recept, ali prije uzimanja pročitajte uputu.',
         'Є дитячий сироп з парацетамолом. Він без рецепта, але перед прийомом прочитайте інструкцію.'),
        ('Daša', 'Dobro. I tablete za grlo, molim. Koliko je sve zajedno?', 'Добре. І таблетки для горла, будь ласка. Скільки все разом?'),
        ('Ljekarnica', 'Dvanaest eura. Neka kći brzo ozdravi!', 'Дванадцять євро. Хай донька швидко одужує!'),
    ]),
    fill=('Gospođo, ___ li recept?', 'imate', ['imaš', 'ima', 'imam']),
    build=[('Де чергова аптека?', 'Gdje je dežurna ljekarna?'), ('Мені потрібні таблетки від болю.', 'Trebam tablete protiv bolova.')],
    listen=['Imate li i nešto protiv bolova?', 'Imamo dječji sirup s paracetamolom.'],
    speak=[('Де найближча аптека?', 'Gdje je najbliža ljekarna?'), ('Цей сироп продають за рецептом?', 'Je li ovaj sirup na recept?')],
    write=dict(
        situation='Дар’я пише в чаті: «Idem u ljekarnu. Trebaš li nešto?» Відповідайте: так, купи, будь ласка, таблетки від болю '
                  'й дитячий сироп.',
        points=[('таблетки від болю', [['tablet', 'bolov'], ['lijek', 'bolov'], ['paracetamol']]), ('дитячий сироп', [['sirup']])],
        hints=['molim te', 'kupi', 'tablete', 'protiv bolova', 'dječji sirup'],
        models=['Da, molim te, kupi tablete protiv bolova i dječji sirup.', 'Trebam lijek protiv bolova i sirup za djecu. Hvala!']),
    mediation=dict(
        source='DEŽURNA LJEKARNA\nOtvoreno 0 – 24 h\nNoću pozvonite na zvono.',
        friend='Що тут написано? Аптека відчинена вночі?',
        points=[('працює цілодобово', [['цілодоб'], ['24']]), ('уночі треба подзвонити', [['дзвін'], ['дзвон'], ['подзвон']])],
        models=['Так, це чергова аптека, вона відчинена цілодобово. Уночі треба подзвонити в дзвінок.']),
)

# ---------------------------------------------------------------------------------------------- тексти для читання A0.6
# Слова: (форма, лема, частина мови, граматика або None, переклад). Позначка «з уроку» й частка знайомих — з уроків A0.
READING = [
    dict(code='RD-A0-021', type='sign', situation='small_talk', title=('Табличка в парку для собак', 'Natpis u parku za pse'),
         body_hr='PARK ZA PSE\nOvdje psi smiju bez povodca.\nMolimo, počistite za svojim psom!\nOpasni psi – samo s brnjicom.',
         body_ua='ПАРК ДЛЯ СОБАК\nТут собакам можна без повідця.\nПросимо, прибирайте за своїм собакою!\nНебезпечні собаки — лише в наморднику.',
         gloss=[
             ('park', 'park za pse', 'сталий вираз', 'частина виразу «park za pse»', 'парк для собак'),
             ('za', 'za', 'прийменник: + знахідний — для, за («za strance» — для іноземців)',
              'у «park za pse» — «для»; у «za svojim psom» — + орудний: «за (своїм собакою)»', 'для; за'),
             ('pse', 'pas', 'іменник, чоловічий рід', 'знахідний відмінок (кого? що?), множина', 'собака; пес'),
             ('ovdje', 'ovdje', 'прислівник', None, 'тут'),
             ('psi', 'pas', 'іменник, чоловічий рід', 'називний відмінок (хто? що?), множина', 'собака; пес'),
             ('smiju', 'smjeti', 'дієслово, недоконаний вид (що робити?)', 'теперішній час: вони. «smiju» — їм можна', 'можна, мати дозвіл'),
             ('bez', 'bez', 'прийменник + родовий відмінок', None, 'без'),
             ('povodca', 'povodac', 'іменник, чоловічий рід', 'родовий відмінок (кого? чого?), однина (після «bez»)', 'повідець'),
             ('molimo', 'molimo', 'сталий вираз «просимо»', 'теперішній час: ми (від moliti). На табличках — «просимо»', 'просимо'),
             ('počistite', 'počistiti', 'дієслово, доконаний вид (що зробити?)', 'наказовий спосіб: ви (зробіть!)', 'прибрати'),
             ('svojim', 'svoj', 'присвійний займенник «свій»', 'орудний відмінок (ким? чим?), однина, ч. р.', 'свій'),
             ('psom', 'pas', 'іменник, чоловічий рід', 'орудний відмінок (ким? чим?), однина: «za psom» — за собакою', 'собака; пес'),
             ('opasni', 'opasan', 'прикметник', 'називний відмінок (хто? що?), множина, ч. р.', 'небезпечний'),
             ('samo', 'samo', 'прислівник «тільки»', None, 'тільки; лише'),
             ('s', 's', 'прийменник «з»: + орудний — разом із («s obitelji»); + родовий — звідки («s Hvara», «s posla»)', None, 'з (разом із)'),
             ('brnjicom', 'brnjica', 'іменник, жіночий рід', 'орудний відмінок (ким? чим?), однина: «s brnjicom» — у наморднику', 'намордник'),
         ],
         questions=[('Чи можна тут відпустити собаку з повідця?', 'Так', ['Так', 'Ні', 'Лише вранці']),
                    ('Що треба робити після свого собаки?', 'Прибирати за ним', ['Прибирати за ним', 'Платити за вхід', 'Чекати біля входу']),
                    ('Яким собакам треба бути в наморднику?', 'Небезпечним', ['Небезпечним', 'Усім', 'Маленьким'])]),
    dict(code='RD-A0-022', type='notice', situation='housing', title=('Оголошення: загубилася кішка', 'Oglas: izgubljena mačka'),
         body_hr='IZGUBLJENA MAČKA\nZove se Mica. Siva je i prugasta.\nPobjegla je u petak s balkona.\nAko je vidite, javite se!\nNagrada!',
         body_ua='ЗАГУБИЛАСЯ КІШКА\nЇї звати Міца. Вона сіра й смугаста.\nВтекла в п’ятницю з балкона.\nЯкщо побачите її, дайте знати!\nВинагорода!',
         gloss=[
             ('izgubljena', 'izgubljen', 'прикметник', 'називний відмінок (хто? що?), однина, ж. р.', 'загублений'),
             ('mačka', 'mačka', 'іменник, жіночий рід', None, 'кішка'),
             ('zove', 'zovem se', 'сталий вираз «мене звати» (від zvati se)', 'теперішній час: вона. «zove se» — її звати', 'мене звати'),
             ('se', 'se', 'зворотний займенник «себе / -ся» (коротка форма; стоїть на другому місці в реченні)', None, 'себе; -ся (частка дієслова)'),
             ('mica', 'Mica', 'ім’я (кличка кішки)', None, 'Міца (кличка кішки)'),
             ('siva', 'siv', 'прикметник', 'називний відмінок (хто? що?), однина, ж. р.', 'сірий'),
             ('je', 'biti', 'дієслово «бути» (недоконаний вид); короткі форми sam, si, je, smo, ste, su',
              'теперішній час: він / вона / воно. У «pobjegla je» — допоміжне дієслово минулого часу; у «ako je vidite» — «її» (знахідний від ona)',
              'бути; є'),
             ('i', 'i', 'сполучник', None, 'і; та'),
             ('prugasta', 'prugast', 'прикметник', 'називний відмінок (хто? що?), однина, ж. р.', 'смугастий'),
             ('pobjegla', 'pobjeći', 'дієслово, доконаний вид (що зробити?)', 'минулий час, ж. р.: «pobjegla je» — втекла', 'втекти'),
             ('u', 'u', 'прийменник: + знахідний — куди? («u školu»), + місцевий — де? («u Zagrebu»)', 'у «u petak» — коли? (знахідний)', 'у; в'),
             ('petak', 'petak', 'іменник, чоловічий рід', 'знахідний відмінок: «u petak» — у п’ятницю', 'п’ятниця'),
             ('s', 's', 'прийменник «з»: + орудний — разом із («s obitelji»); + родовий — звідки («s Hvara», «s posla»)', None, 'з (звідки)'),
             ('balkona', 'balkon', 'іменник, чоловічий рід', 'родовий відмінок (кого? чого?), однина: «s balkona» — з балкона', 'балкон'),
             ('ako', 'ako', 'сполучник', None, 'якщо'),
             ('vidite', 'vidjeti', 'дієслово, доконаний і недоконаний вид', 'теперішній час: ви', 'бачити'),
             ('javite', 'javiti se', 'дієслово, доконаний вид (що зробити?)', 'наказовий спосіб: ви (зробіть!). «Javite se!» — дайте знати, озвіться', 'дати знати; озватися'),
             ('nagrada', 'nagrada', 'іменник, жіночий рід', None, 'нагорода; винагорода'),
         ],
         questions=[('Яка кішка загубилася?', 'Сіра й смугаста', ['Сіра й смугаста', 'Чорна', 'Біла з плямами']),
                    ('Коли вона втекла?', 'У п’ятницю', ['У п’ятницю', 'У неділю', 'Сьогодні вранці']),
                    ('Що отримає той, хто знайде кішку?', 'Винагороду', ['Винагороду', 'Кошеня', 'Квиток у кіно'])]),
]
