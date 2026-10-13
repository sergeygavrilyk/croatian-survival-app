"""
Програма A0, версія 3 (2026-10-13): +17 уроків у модулі, де тема неповна по суті.
Рішення власника: «+1–2 уроки в кожен модуль, якщо модуль не повний по суті
(наприклад, у модулі з днями тижня немає слова «вчора»)».

Кожен урок — повна структура (як A1 і розширені уроки A0):
мета → 10–12 слів → 2 діалоги → граматика → 12 вправ (~12 хв).
Ключ 'модуль.місце': новий урок стає 4-м або 5-м у юніті модуля; наскрізні номери
«Урок N» генератор перераховує для всіх уроків A0.

A0 — без минулого й майбутнього часу: діалоги в теперішньому часі й короткі фрази.
"""

# ----------------------------------------------------------------------------
# Нові слова (яких немає у словнику). (lemma, normalized, переклад, частина мови, vocabulary_type, forms, приклад)
# Заповнюється після звірки з робочою базою.
# ----------------------------------------------------------------------------
NEW_LEXEMES = [
    # A0.1
    ('do sutra', 'do sutra', 'до завтра', 'phrase', 'formulaic', {}, 'Hvala na svemu, do sutra!'),
    ('ugodna večer', 'ugodna vecer', 'гарного вечора', 'phrase', 'formulaic', {}, 'Laku noć i ugodna večer!'),
    ('sretno', 'sretno', 'успіхів; щасти', 'interjection', 'formulaic', {}, 'Sutra imaš ispit? Sretno!'),
    ('čestitam', 'cestitam', 'вітаю (з чимось)', 'phrase', 'formulaic', {}, 'Čestitam na rođendanu!'),
    ('i tebi', 'i tebi', 'і тобі (теж)', 'phrase', 'formulaic', {}, 'Ugodan dan! — Hvala, i tebi!'),
    # A0.2
    ('kvart', 'kvart', 'район (міста)', 'noun', 'core', {'gender': 'm'}, 'Naš kvart ima lijep park.'),
    ('kućni broj', 'kucni broj', 'номер будинку', 'phrase', 'collocation', {}, 'Napišite ulicu i kućni broj.'),
    ('poštanski broj', 'postanski broj', 'поштовий індекс', 'phrase', 'collocation', {}, 'Poštanski broj Splita je 21000.'),
    ('Ukrajinka', 'ukrajinka', 'українка', 'noun', 'core', {'gender': 'f'}, 'Moja susjeda je Ukrajinka.'),
    ('Hrvatica', 'hrvatica', 'хорватка', 'noun', 'core', {'gender': 'f'}, 'Ana je Hrvatica iz Zadra.'),
    ('ukrajinski', 'ukrajinski', 'українська (мова); український', 'adjective', 'core', {}, 'Djeca doma govore ukrajinski.'),
    ('njemački', 'njemacki', 'німецька (мова); німецький', 'adjective', 'core', {}, 'Moj brat govori njemački.'),
    ('poljski', 'poljski', 'польська (мова); польський', 'adjective', 'core', {}, 'Razumijem malo poljski.'),
    ('talijanski', 'talijanski', 'італійська (мова); італійський', 'adjective', 'core', {}, 'U Istri mnogi govore talijanski.'),
    ('profesorica', 'profesorica', 'викладачка; вчителька', 'noun', 'core', {'gender': 'f'}, 'Profesorica govori polako.'),
    # A0.3
    ('broj telefona', 'broj telefona', 'номер телефону', 'phrase', 'collocation', {}, 'Napišite ovdje svoj broj telefona.'),
    # A0.4
    ('prijepodne', 'prijepodne', 'до обіду; першу половину дня', 'adverb', 'core', {}, 'Prijepodne radim, a poslijepodne učim.'),
    ('podne', 'podne', 'полудень', 'noun', 'core', {'gender': 'n'}, 'Ručak je u podne.'),
    ('poslijepodne', 'poslijepodne', 'після обіду; пополудні', 'adverb', 'core', {}, 'Poslijepodne idemo u park.'),
    ('ponoć', 'ponoc', 'північ (час)', 'noun', 'core', {'gender': 'f'}, 'Kafić radi do ponoći.'),
    ('praznici', 'praznici', 'канікули; свята', 'noun', 'core', {'gender': 'm'}, 'Djeca su na praznicima.'),
    # A0.5
    ('teta', 'teta', 'тітка', 'noun', 'core', {'gender': 'f'}, 'Moja teta živi u Zagrebu.'),
    ('ujak', 'ujak', 'дядько (брат матері)', 'noun', 'core', {'gender': 'm'}, 'Ujak ima veliku kuću na moru.'),
    ('bratić', 'bratic', 'двоюрідний брат', 'noun', 'core', {'gender': 'm'}, 'Moj bratić ima deset godina.'),
    ('sestrična', 'sestricna', 'двоюрідна сестра', 'noun', 'core', {'gender': 'f'}, 'Sestrična dolazi k nama u petak.'),
    ('oženjen', 'ozenjen', 'одружений (про чоловіка)', 'adjective', 'core', {}, 'Moj brat je oženjen.'),
    ('udana', 'udana', 'заміжня', 'adjective', 'core', {}, 'Moja sestra je udana i ima sina.'),
    # A0.6
    ('spavaća soba', 'spavaca soba', 'спальня', 'phrase', 'collocation', {}, 'Spavaća soba je mala, ali mirna.'),
    # A0.7
    ('limunada', 'limunada', 'лимонад', 'noun', 'core', {'gender': 'f'}, 'Ljeti pijem hladnu limunadu.'),
    ('riža', 'riza', 'рис', 'noun', 'core', {'gender': 'f'}, 'Kupi kilu riže, molim te.'),
    ('pomfrit', 'pomfrit', 'картопля фрі', 'noun', 'core', {'gender': 'm'}, 'Djeca vole pomfrit.'),
    ('umak', 'umak', 'соус', 'noun', 'core', {'gender': 'm'}, 'Tjestenina s umakom od rajčice.'),
    ('slan', 'slan', 'солоний', 'adjective', 'core', {}, 'Sir je malo previše slan.'),
    # A0.8
    ('deka', 'deka', 'десять грамів (у кількостях: deset deka = 100 г)', 'noun', 'core', {'gender': 'f'}, 'Dvadeset deka sira, molim.'),
    ('kila', 'kila', 'кілограм (розм.)', 'noun', 'core', {'gender': 'f'}, 'Kila jabuka košta dva eura.'),
    ('litra', 'litra', 'літр', 'noun', 'core', {'gender': 'f'}, 'Trebam litru mlijeka.'),
    ('šunka', 'sunka', 'шинка', 'noun', 'core', {'gender': 'f'}, 'Za doručak jedem kruh i šunku.'),
    ('dosta', 'dosta', 'досить; достатньо', 'adverb', 'core', {}, 'Imamo dosta vremena.'),
    ('popis', 'popis', 'список', 'noun', 'core', {'gender': 'm'}, 'Napiši popis za trgovinu.'),
    ('ružičast', 'ruzicast', 'рожевий', 'adjective', 'core', {}, 'Kći voli ružičastu haljinu.'),
    ('narančast', 'narancast', 'помаранчевий', 'adjective', 'core', {}, 'Autobus je narančast.'),
    ('ljubičast', 'ljubicast', 'фіолетовий', 'adjective', 'core', {}, 'Imam ljubičastu torbu.'),
    ('omiljen', 'omiljen', 'улюблений', 'adjective', 'core', {}, 'Ovo je moj omiljeni kafić.'),
    # A0.9
    ('ugao', 'ugao', 'ріг (вулиці); кут', 'noun', 'core', {'gender': 'm'}, 'Pekara je iza ugla.'),
    ('skrenuti', 'skrenuti', 'повернути (ліворуч, праворуч)', 'verb', 'core', {'aspect': 'pfv'}, 'Na semaforu skrenite lijevo.'),
    ('prijeći', 'prijeci', 'перейти', 'verb', 'core', {'aspect': 'pfv'}, 'Prijeđite cestu na zebri.'),
    ('pješački prijelaz', 'pjesacki prijelaz', 'пішохідний перехід', 'phrase', 'collocation', {}, 'Pješački prijelaz je kod škole.'),
    ('gužva', 'guzva', 'затор; тиснява', 'noun', 'core', {'gender': 'f'}, 'Ujutro je u gradu velika gužva.'),
    # A0.10
    ('kožni', 'kozni', 'шкіряний', 'adjective', 'core', {}, 'Imam crnu kožnu jaknu.'),
]

# Виправлення перекладів опублікованих слів: lemma → (старий, новий)
TRANSLATION_FIXES = {
    'evo': ('тут', 'ось; ось тут'),
    'kuća': ('дім', 'будинок; дім'),
    'drag': ('дорогий', 'дорогий; милий, приємний'),
    'tek': ('тільки-но, щойно', 'лише; тільки-но, щойно'),
}

# Виправлення написання лем (лише регістр): lemma → (старе, нове)
LEMMA_FIXES = {
    'mup': ('mUP', 'MUP'),
    'hrvat': ('hrvat', 'Hrvat'),            # національності в хорватській — з великої літери
    'ukrajinac': ('ukrajinac', 'Ukrajinac'),
}

# Слова, з яких не робимо вправ на слова
NO_VOCAB_EXERCISE = {'i tebi', 'deka', 'pozdraviti'}

# ----------------------------------------------------------------------------
# Граматика. Наявні теми A0 шукаємо за назвою; нова тема — «Порядок слів» (§21 ТЗ: basic word order).
# ----------------------------------------------------------------------------
EXISTING_GRAMMAR = {
    'biti': 'Особові займенники та дієслово BITI',
    'polite': 'Ввічливість: ti і Vi',
    'pronunciation': 'Вимова: хорватські літери',
    'negation': 'Заперечення і питання з «biti»',
    'numbers': 'Числа 0–100',
    'time': 'Час: дні, години, місяці',
    'gender': 'Рід, множина і «мій / моя / моє»',
    'place': 'Де? Прийменники місця',
    'imati': 'Дієслово «imati» (мати)',
    'demonstratives': 'Цей, той, он той: ovaj, taj, onaj',
    'adjectives': 'Прикметники: узгодження з іменником',
    'questions': 'Питальні слова',
}

NEW_GRAMMAR = {
    'word_order': {
        'title_ua': 'Порядок слів',
        'title_hr': 'Red riječi',
        'description': 'Як будувати речення: звичайний порядок, короткі слова на другому місці, питання.',
        'rules': [
            ('Звичайний порядок',
             'Як і в українській: хто — що робить — що. Порядок вільний, але найважливіше зазвичай у кінці речення.',
             'Ja pijem kavu.',
             [('Ja pijem kavu.', 'Я п’ю каву.'),
              ('Ana radi u banci.', 'Ана працює в банку.'),
              ('Kavu pijem ujutro.', 'Каву я п’ю зранку.')]),
            ('Короткі слова — на другому місці',
             'Короткі слова sam, si, je, se, me, li стоять на другому місці в реченні, а не на початку: Zovem se Ana. Umoran sam.',
             'Zovem se… · Gdje je…?',
             [('Zovem se Ana.', 'Мене звати Ана.'),
              ('Umoran sam.', 'Я втомлений.'),
              ('Gdje je stanica?', 'Де зупинка?')]),
            ('Питання',
             'Питання «так / ні»: дієслово + li на початку (Imate li…? Govorite li…?) або Je li…? Питальне слово стоїть першим: Gdje…? Kada…?',
             'Imate li…? · Je li…?',
             [('Imate li vodu?', 'У вас є вода?'),
              ('Je li to daleko?', 'Це далеко?'),
              ('Kada polazi vlak?', 'Коли відправляється поїзд?')]),
        ],
    },
}

# ----------------------------------------------------------------------------
# Нові уроки
# ----------------------------------------------------------------------------
LESSONS = {
    # ----------------------------------------------------- A0.1 Pozdrav!
    '1.4': dict(
        title=('Прощання і ввічливість', 'Pozdravi i pristojnost'), situation='basics', grammar='polite',
        objectives=['Попрощатися з колегою чи сусідом', 'Перепросити й відповісти на вибачення', 'Привітати й побажати успіху'],
        words=['vidimo se', 'do sutra', 'ugodna večer', 'pozdraviti', 'sretno', 'ispričavam se', 'nema problema', 'čestitam', 'i tebi', 'kasniti'],
        scenes=[
            ('Після роботи', 'Poslije posla', [
                ('Marija', 'Ja idem. Vidimo se sutra!', 'Я йду. Побачимося завтра!'),
                ('Taras', 'Do sutra! Ugodna večer!', 'До завтра! Гарного вечора!'),
                ('Marija', 'Hvala, i tebi. Pozdravi obitelj!', 'Дякую, і тобі. Передавай привіт родині!'),
                ('Taras', 'Hoću. Bok!', 'Обов’язково. Бувай!'),
            ]),
            ('Перепрошую!', 'Ispričavam se!', [
                ('Olena', 'Ispričavam se, kasnim pet minuta.', 'Перепрошую, я запізнююся на п’ять хвилин.'),
                ('Gospođa Horvat', 'Nema problema. Sjednite.', 'Нічого страшного. Сідайте.'),
                ('Olena', 'Hvala Vam. Čestitam na novom poslu!', 'Дякую вам. Вітаю з новою роботою!'),
                ('Gospođa Horvat', 'Hvala! Sretno i Vama!', 'Дякую! Успіхів і вам!'),
            ]),
        ],
        fill=('Hvala ___, gospođo Horvat!', 'Vam', ['ti', 'Vas', 'tebe']),
        build=[('Складіть: «Побачимося завтра!»', 'Vidimo se sutra!'),
               ('Складіть: «Перепрошую, я запізнююся.»', 'Ispričavam se, kasnim.')],
        listen=['Do sutra! Ugodna večer!', 'Nema problema. Sjednite.'],
        speak=[('Успіхів!', 'Sretno!'), ('Передавай привіт родині!', 'Pozdravi obitelj!')],
    ),
    # ----------------------------------------------------- A0.2 Ja sam…
    '2.4': dict(
        title=('Де ви живете?', 'Gdje živite?'), situation='administration', grammar='place',
        objectives=['Назвати свою адресу', 'Сказати, на якому поверсі ви живете', 'Розповісти про свій будинок і район'],
        words=['kuća', 'zgrada', 'kat', 'kvart', 'miran', 'susjed', 'poštanski broj', 'kućni broj', 'tisuća', 'drag'],
        scenes=[
            ('Яка ваша адреса?', 'Koja je Vaša adresa?', [
                ('Službenica', 'Gdje živite?', 'Де ви живете?'),
                ('Oleg', 'Živim u Zagrebu, u Vukovarskoj ulici.', 'Я живу в Загребі, на Вуковарській вулиці.'),
                ('Službenica', 'Koji je kućni broj?', 'Який номер будинку?'),
                ('Oleg', 'Dvadeset dva, treći kat.', 'Двадцять два, третій поверх.'),
                ('Službenica', 'A poštanski broj?', 'А поштовий індекс?'),
                ('Oleg', 'Deset tisuća.', 'Десять тисяч.'),
            ]),
            ('Будинок чи квартира?', 'Kuća ili stan?', [
                ('Ana', 'Živiš li u kući ili u stanu?', 'Ти живеш у будинку чи в квартирі?'),
                ('Oksana', 'U stanu, u velikoj zgradi.', 'У квартирі, у великому будинку.'),
                ('Ana', 'Je li kvart miran?', 'Район спокійний?'),
                ('Oksana', 'Jest, i susjedi su dragi.', 'Так, і сусіди приємні.'),
            ]),
        ],
        fill=('Živim ___ Zagrebu.', 'u', ['na', 'iz', 'od']),
        build=[('Складіть: «Я живу в Загребі.»', 'Živim u Zagrebu.'),
               ('Складіть: «Район спокійний?»', 'Je li kvart miran?')],
        listen=['Dvadeset dva, treći kat.', 'U stanu, u velikoj zgradi.'],
        speak=[('Де ви живете?', 'Gdje živite?'), ('Я живу на другому поверсі.', 'Živim na drugom katu.')],
    ),
    '2.5': dict(
        title=('Мови й національності', 'Jezici i narodnosti'), situation='small_talk', grammar='biti',
        objectives=['Сказати, хто ви за національністю', 'Назвати мови, якими говорите', 'Запитати співрозмовника про мови'],
        words=['Ukrajinka', 'Hrvatica', 'ukrajinski', 'njemački', 'poljski', 'talijanski', 'stranac', 'razumjeti', 'tečaj', 'profesorica'],
        scenes=[
            ('Ти українка?', 'Jesi li Ukrajinka?', [
                ('Petra', 'Jesi li ti Ukrajinka?', 'Ти українка?'),
                ('Olena', 'Da, ja sam Ukrajinka. A ti si Hrvatica?', 'Так, я українка. А ти хорватка?'),
                ('Petra', 'Jesam. Govoriš li hrvatski?', 'Так. Ти говориш хорватською?'),
                ('Olena', 'Malo. Govorim ukrajinski i engleski.', 'Трохи. Я говорю українською й англійською.'),
            ]),
            ('Іноземці на курсі', 'Stranci na tečaju', [
                ('Profesorica', 'Koje jezike govorite?', 'Якими мовами ви говорите?'),
                ('Andrij', 'Ukrajinski, poljski i malo njemački.', 'Українською, польською і трохи німецькою.'),
                ('Profesorica', 'Odlično! A razumijete li talijanski?', 'Чудово! А італійську ви розумієте?'),
                ('Andrij', 'Ne razumijem, nažalost.', 'На жаль, не розумію.'),
            ]),
        ],
        fill=('Ja ___ Ukrajinka.', 'sam', ['si', 'je', 'smo']),
        build=[('Складіть: «Я говорю українською й англійською.»', 'Govorim ukrajinski i engleski.'),
               ('Складіть: «А ти хорватка?»', 'A ti si Hrvatica?')],
        listen=['Jesam. Govoriš li hrvatski?', 'Ne razumijem, nažalost.'],
        speak=[('Я українець.', 'Ja sam Ukrajinac.'), ('Якими мовами ви говорите?', 'Koje jezike govorite?')],
    ),
    # ----------------------------------------------------- A0.3 Brojevi
    '3.4': dict(
        title=('Числа від 11 до 19', 'Brojevi od 11 do 19'), situation='basics', grammar='numbers',
        objectives=['Рахувати від 11 до 19', 'Сказати, скільки вас людей', 'Зрозуміти номер автобуса й час у хвилинах'],
        words=['jedanaest', 'dvanaest', 'trinaest', 'četrnaest', 'petnaest', 'šesnaest', 'sedamnaest', 'osamnaest', 'devetnaest', 'otprilike', 'osoba'],
        scenes=[
            ('Скільки вас?', 'Koliko vas je?', [
                ('Konobar', 'Dobra večer! Koliko vas je?', 'Добрий вечір! Скільки вас?'),
                ('Marko', 'Dvanaest. Imate li stol za dvanaest osoba?', 'Дванадцять. У вас є стіл на дванадцять осіб?'),
                ('Konobar', 'Imamo stol za četrnaest, na terasi.', 'У нас є стіл на чотирнадцять, на терасі.'),
                ('Marko', 'Odlično, hvala!', 'Чудово, дякую!'),
            ]),
            ('Який автобус?', 'Koji autobus?', [
                ('Turistkinja', 'Koji autobus ide u centar?', 'Який автобус їде в центр?'),
                ('Gospodin', 'Sedamnaest ili devetnaest.', 'Сімнадцятий або дев’ятнадцятий.'),
                ('Turistkinja', 'Koliko minuta do centra?', 'Скільки хвилин до центру?'),
                ('Gospodin', 'Otprilike petnaest minuta.', 'Приблизно п’ятнадцять хвилин.'),
            ]),
        ],
        fill=('Deset i pet je ___.', 'petnaest', ['pedeset', 'pet', 'dvadeset pet']),
        build=[('Складіть: «Приблизно п’ятнадцять хвилин.»', 'Otprilike petnaest minuta.'),
               ('Складіть: «У нас є стіл на чотирнадцять.»', 'Imamo stol za četrnaest.')],
        listen=['Imamo stol za četrnaest, na terasi.', 'Sedamnaest ili devetnaest.'],
        speak=[('Мені вісімнадцять років.', 'Imam osamnaest godina.'), ('Автобус номер одинадцять.', 'Autobus broj jedanaest.')],
    ),
    '3.5': dict(
        title=('До ста і номер телефону', 'Do sto i broj telefona'), situation='basics', grammar='numbers',
        objectives=['Рахувати десятками до 100', 'Продиктувати номер телефону', 'Зрозуміти ціну до 100 євро'],
        words=['šezdeset', 'sedamdeset', 'osamdeset', 'devedeset', 'sto', 'broj telefona', 'ponoviti', 'pisati', 'telefon', 'evo'],
        scenes=[
            ('Номер телефону', 'Broj telefona', [
                ('Službenica', 'Koji je Vaš broj telefona?', 'Який ваш номер телефону?'),
                ('Iryna', 'Nula devedeset jedan, šezdeset sedam, osamdeset dva, sedamdeset tri.', 'Нуль дев’яносто один, шістдесят сім, вісімдесят два, сімдесят три.'),
                ('Službenica', 'Možete li ponoviti polako?', 'Можете повторити повільно?'),
                ('Iryna', 'Naravno. Evo, ovdje piše.', 'Звісно. Ось, тут написано.'),
            ]),
            ('Скільки коштує?', 'Koliko košta?', [
                ('Kupac', 'Koliko košta ova jakna?', 'Скільки коштує ця куртка?'),
                ('Prodavačica', 'Devedeset eura.', 'Дев’яносто євро.'),
                ('Kupac', 'A ona plava?', 'А он та синя?'),
                ('Prodavačica', 'Sedamdeset pet. Danas je sve na popustu.', 'Сімдесят п’ять. Сьогодні на все знижка.'),
                ('Kupac', 'Uzimam plavu. Evo sto eura.', 'Беру синю. Ось сто євро.'),
            ]),
        ],
        fill=('Pedeset i deset je ___.', 'šezdeset', ['šesnaest', 'šest', 'sedamdeset']),
        build=[('Складіть: «Який ваш номер телефону?»', 'Koji je Vaš broj telefona?'),
               ('Складіть: «Ось сто євро.»', 'Evo sto eura.')],
        listen=['Možete li ponoviti polako?', 'Devedeset eura.'],
        speak=[('Сто євро.', 'Sto eura.'), ('Скажіть, будь ласка, ваш номер телефону.', 'Recite mi, molim, Vaš broj telefona.')],
    ),
    # ----------------------------------------------------- A0.4 Vrijeme
    '4.4': dict(
        title=('Учора, сьогодні, завтра', 'Jučer, danas, sutra'), situation='small_talk', grammar='time',
        objectives=['Вживати jučer, prekjučer, prekosutra', 'Назвати частину дня: ujutro, poslijepodne, navečer', 'Домовитися про день і час'],
        words=['jučer', 'prekjučer', 'prekosutra', 'tjedan', 'ujutro', 'prijepodne', 'podne', 'poslijepodne', 'navečer', 'ponoć', 'tek'],
        scenes=[
            ('Коли зустрінемося?', 'Kada se vidimo?', [
                ('Ana', 'Imaš li vremena sutra poslijepodne?', 'Маєш час завтра після обіду?'),
                ('Taras', 'Sutra ne, radim do večeri. Prekosutra može.', 'Завтра ні, працюю до вечора. Післязавтра можна.'),
                ('Ana', 'Prekosutra je subota. Prijepodne ili poslijepodne?', 'Післязавтра субота. До обіду чи після обіду?'),
                ('Taras', 'Prijepodne, u deset.', 'До обіду, о десятій.'),
            ]),
            ('Мій тиждень', 'Moj tjedan', [
                ('Marko', 'Koliko dugo si u Hrvatskoj?', 'Як довго ти в Хорватії?'),
                ('Iryna', 'Tek tjedan dana.', 'Лише тиждень.'),
                ('Marko', 'I kakav ti je tjedan?', 'І який у тебе тиждень?'),
                ('Iryna', 'Pun! Jučer posao, danas tečaj, a sutra more!', 'Насичений! Учора робота, сьогодні курс, а завтра — море!'),
                ('Marko', 'A navečer?', 'А ввечері?'),
                ('Iryna', 'Navečer spavam!', 'Увечері сплю!'),
            ]),
        ],
        fill=('Danas je petak, a sutra je ___.', 'subota', ['četvrtak', 'nedjelja', 'ponedjeljak']),
        build=[('Складіть: «Післязавтра можна.»', 'Prekosutra može.'),
               ('Складіть: «Учора робота, сьогодні курс.»', 'Jučer posao, danas tečaj.')],
        listen=['Prijepodne, u deset.', 'A navečer?'],
        speak=[('Учора, сьогодні, завтра.', 'Jučer, danas, sutra.'), ('Побачимося післязавтра!', 'Vidimo se prekosutra!')],
    ),
    '4.5': dict(
        title=('Місяці й дати', 'Mjeseci i datumi'), situation='small_talk', grammar='time',
        objectives=['Назвати всі місяці', 'Сказати дату свого дня народження', 'Запитати, яке сьогодні число'],
        words=['veljača', 'ožujak', 'travanj', 'svibanj', 'lipanj', 'listopad', 'studeni', 'prosinac', 'datum', 'prvi', 'treći', 'praznici'],
        scenes=[
            ('Коли твій день народження?', 'Kada ti je rođendan?', [
                ('Lana', 'Kada ti je rođendan?', 'Коли в тебе день народження?'),
                ('Oleg', 'Dvadeset prvog ožujka. A tvoj?', 'Двадцять першого березня. А твій?'),
                ('Lana', 'Trećeg studenog.', 'Третього листопада.'),
                ('Oleg', 'Znači, u jesen. A koji je danas datum?', 'Отже, восени. А яке сьогодні число?'),
                ('Lana', 'Danas je trinaesti listopada.', 'Сьогодні тринадцяте жовтня.'),
            ]),
            ('Шкільний рік', 'Školska godina', [
                ('Mama', 'Kada počinje škola u Hrvatskoj?', 'Коли в Хорватії починається школа?'),
                ('Učiteljica', 'Početkom rujna, a završava u lipnju.', 'На початку вересня, а закінчується в червні.'),
                ('Mama', 'A zimski praznici?', 'А зимові канікули?'),
                ('Učiteljica', 'Od kraja prosinca do sredine siječnja.', 'З кінця грудня до середини січня.'),
            ]),
        ],
        fill=('Rođendan mi je u ___.', 'svibnju', ['svibanj', 'svibnja', 'svibnjem']),
        build=[('Складіть: «Коли в тебе день народження?»', 'Kada ti je rođendan?'),
               ('Складіть: «Яке сьогодні число?»', 'Koji je danas datum?')],
        listen=['Trećeg studenog.', 'A zimski praznici?'],
        speak=[('Мій день народження в травні.', 'Rođendan mi je u svibnju.'), ('Сьогодні перше квітня.', 'Danas je prvi travnja.')],
    ),
    # ----------------------------------------------------- A0.5 Obitelj
    '5.4': dict(
        title=('Родичі й стосунки', 'Rodbina i veze'), situation='small_talk', grammar='imati',
        objectives=['Назвати родичів: тітка, дядько, двоюрідні брати й сестри', 'Сказати, чи ви одружені', 'Розповісти про свою родину в Хорватії'],
        words=['rodbina', 'teta', 'ujak', 'bratić', 'sestrična', 'oženjen', 'udana', 'cura', 'dečko', 'unuk', 'mlad'],
        scenes=[
            ('Родичі в Хорватії', 'Rodbina u Hrvatskoj', [
                ('Ana', 'Imaš li rodbinu u Hrvatskoj?', 'У тебе є родичі в Хорватії?'),
                ('Oksana', 'Imam. Moja teta i ujak žive u Rijeci.', 'Так. Моя тітка й дядько живуть у Рієці.'),
                ('Ana', 'Imaju li djecu?', 'У них є діти?'),
                ('Oksana', 'Imaju. Moj bratić ima dvadeset godina, a sestrična petnaest.', 'Так. Моєму двоюрідному братові двадцять років, а двоюрідній сестрі п’ятнадцять.'),
            ]),
            ('Ти одружений?', 'Jesi li oženjen?', [
                ('Marko', 'Jesi li oženjen?', 'Ти одружений?'),
                ('Andrij', 'Nisam, ali imam curu. A ti?', 'Ні, але в мене є дівчина. А ти?'),
                ('Marko', 'Ja sam oženjen i imam unuka!', 'Я одружений, і в мене є онук!'),
                ('Andrij', 'Unuka? Pa ti si mlad!', 'Онука? Та ти ж молодий!'),
            ]),
        ],
        fill=('Oni ___ dvoje djece.', 'imaju', ['imam', 'imaš', 'ima']),
        build=[('Складіть: «Моя тітка живе в Рієці.»', 'Moja teta živi u Rijeci.'),
               ('Складіть: «Ти одружений?»', 'Jesi li oženjen?')],
        listen=['Imaju li djecu?', 'Unuka? Pa ti si mlad!'],
        speak=[('У мене є хлопець.', 'Imam dečka.'), ('Моя сестра заміжня.', 'Moja sestra je udana.')],
    ),
    # ----------------------------------------------------- A0.6 Moj dom
    '6.4': dict(
        title=('Кімнати й техніка', 'Prostorije i aparati'), situation='housing', grammar='place',
        objectives=['Назвати кімнати: спальня, коридор, туалет', 'Назвати побутову техніку', 'Сказати, де що стоїть'],
        words=['hodnik', 'spavaća soba', 'zahod', 'perilica', 'pećnica', 'štednjak', 'hladnjak', 'vrt', 'dvorište', 'ogledalo'],
        scenes=[
            ('Огляд квартири', 'Razgledavanje stana', [
                ('Agentica', 'Ovo je hodnik. Lijevo je spavaća soba.', 'Це коридор. Ліворуч — спальня.'),
                ('Iryna', 'A gdje je zahod?', 'А де туалет?'),
                ('Agentica', 'Pored kupaonice. Kupaonica ima i perilicu.', 'Поруч із ванною. У ванній є й пральна машина.'),
                ('Iryna', 'Super! Ima li kuhinja pećnicu?', 'Чудово! На кухні є духовка?'),
                ('Agentica', 'Ima, i štednjak i hladnjak.', 'Є, і плита, і холодильник.'),
            ]),
            ('Будинок із садом', 'Kuća s vrtom', [
                ('Baka', 'Naša kuća ima vrt i dvorište.', 'У нашого будинку є сад і подвір’я.'),
                ('Unuk', 'Gdje je moja soba?', 'Де моя кімната?'),
                ('Baka', 'Gore, na katu, pored velikog ogledala.', 'Нагорі, на поверсі, біля великого дзеркала.'),
                ('Unuk', 'Super, vidim more!', 'Супер, я бачу море!'),
            ]),
        ],
        fill=('Perilica je ___ kupaonici.', 'u', ['na', 'iz', 'do']),
        build=[('Складіть: «Ліворуч — спальня.»', 'Lijevo je spavaća soba.'),
               ('Складіть: «А де туалет?»', 'A gdje je zahod?')],
        listen=['Pored kupaonice.', 'Gdje je moja soba?'],
        speak=[('Де ванна кімната?', 'Gdje je kupaonica?'), ('У мене немає духовки.', 'Nemam pećnice.')],
    ),
    # ----------------------------------------------------- A0.7 Hrana
    '7.4': dict(
        title=('Напої', 'Pića'), situation='cafe_restaurant', grammar='questions',
        objectives=['Замовити напій: пиво, вино, чай', 'Сказати, з цукром чи без', 'Назвати посуд: склянка, чашка, пляшка'],
        words=['pivo', 'vino', 'čaj', 'šećer', 'čaša', 'šalica', 'boca', 'mineralna voda', 'limunada', 'led', 'topao'],
        scenes=[
            ('Що будете пити?', 'Što želite piti?', [
                ('Konobar', 'Dobra večer! Što želite piti?', 'Добрий вечір! Що будете пити?'),
                ('Oleg', 'Jedno pivo, molim. Veliko.', 'Одне пиво, будь ласка. Велике.'),
                ('Olga', 'Za mene čašu bijelog vina.', 'Мені келих білого вина.'),
                ('Konobar', 'Može. Još nešto?', 'Добре. Ще щось?'),
                ('Olga', 'Bocu mineralne vode, molim.', 'Пляшку мінеральної води, будь ласка.'),
            ]),
            ('Чай чи кава?', 'Čaj ili kava?', [
                ('Ana', 'Želiš li čaj ili kavu?', 'Хочеш чаю чи кави?'),
                ('Iryna', 'Čaj, molim. Šalicu toplog čaja.', 'Чай, будь ласка. Чашку гарячого чаю.'),
                ('Ana', 'Sa šećerom?', 'З цукром?'),
                ('Iryna', 'Ne, bez šećera. A ti?', 'Ні, без цукру. А ти?'),
                ('Ana', 'Ja pijem limunadu s ledom.', 'Я п’ю лимонад з льодом.'),
            ]),
        ],
        fill=('___ želite piti?', 'Što', ['Tko', 'Gdje', 'Kada']),
        build=[('Складіть: «Одне пиво, будь ласка.»', 'Jedno pivo, molim.'),
               ('Складіть: «Ні, без цукру.»', 'Ne, bez šećera.')],
        listen=['Za mene čašu bijelog vina.', 'Sa šećerom?'],
        speak=[('Склянку води, будь ласка.', 'Čašu vode, molim.'), ('Я не п’ю каву.', 'Ne pijem kavu.')],
    ),
    '7.5': dict(
        title=('Вечеря', 'Večera'), situation='cafe_restaurant', grammar='adjectives',
        objectives=['Назвати страви на вечерю', 'Сказати, що смачно, солоно чи гостро', 'Побажати смачного'],
        words=['večera', 'piletina', 'svinjetina', 'riža', 'pomfrit', 'umak', 'kolač', 'dobar tek', 'ukusan', 'slan', 'ljut', 'opet'],
        scenes=[
            ('Що на вечерю?', 'Što je za večeru?', [
                ('Sin', 'Mama, što je za večeru?', 'Мамо, що на вечерю?'),
                ('Mama', 'Piletina s rižom i salatom.', 'Курятина з рисом і салатом.'),
                ('Sin', 'Opet piletina? Ima li pomfrita?', 'Знову курятина? А картопля фрі є?'),
                ('Mama', 'Nema. Ali ima kolača za desert!', 'Немає. Зате є тістечка на десерт!'),
            ]),
            ('Смачного!', 'Dobar tek!', [
                ('Ana', 'Dobar tek!', 'Смачного!'),
                ('Taras', 'Hvala! Meso je jako ukusno.', 'Дякую! М’ясо дуже смачне.'),
                ('Ana', 'To je svinjetina u umaku. Nije previše ljuto?', 'Це свинина в соусі. Не надто гостро?'),
                ('Taras', 'Nije, odlično je. Malo je slano, ali dobro.', 'Ні, чудово. Трохи солоне, але добре.'),
            ]),
        ],
        fill=('Meso je jako ___.', 'ukusno', ['ukusan', 'ukusna', 'ukusni']),
        build=[('Складіть: «Курятина з рисом і салатом.»', 'Piletina s rižom i salatom.'),
               ('Складіть: «М’ясо дуже смачне.»', 'Meso je jako ukusno.')],
        listen=['Opet piletina? Ima li pomfrita?', 'Dobar tek!'],
        speak=[('Що на вечерю?', 'Što je za večeru?'), ('Це дуже смачно!', 'Ovo je jako ukusno!')],
    ),
    # ----------------------------------------------------- A0.8 Kupovina
    '8.4': dict(
        title=('Скільки вам?', 'Koliko trebate?'), situation='shopping', grammar='demonstratives',
        objectives=['Купити продукти на вагу: deka, pola kile', 'Сказати «більше», «досить», «багато»', 'Скласти список покупок'],
        words=['deka', 'kila', 'pola', 'litra', 'paket', 'šunka', 'dosta', 'više', 'puno', 'popis'],
        scenes=[
            ('За прилавком', 'Za pultom', [
                ('Prodavačica', 'Izvolite?', 'Слухаю вас?'),
                ('Olena', 'Trideset deka ovog sira, molim.', 'Триста грамів цього сиру, будь ласка.'),
                ('Prodavačica', 'Može malo više?', 'Можна трохи більше?'),
                ('Olena', 'Može. I pola kile šunke.', 'Можна. І півкіло шинки.'),
                ('Prodavačica', 'Još nešto?', 'Ще щось?'),
                ('Olena', 'Ne, dosta je, hvala.', 'Ні, досить, дякую.'),
            ]),
            ('Список покупок', 'Popis za trgovinu', [
                ('Taras', 'Što trebamo?', 'Що нам треба?'),
                ('Olena', 'Litru mlijeka, paket tjestenine i šest jaja.', 'Літр молока, пачку макаронів і шість яєць.'),
                ('Taras', 'Koliko kruha?', 'Скільки хліба?'),
                ('Olena', 'Jedan. I puno voća za djecu!', 'Одну хлібину. І багато фруктів для дітей!'),
            ]),
        ],
        fill=('Pola kile ___ sira, molim.', 'ovog', ['ovaj', 'ova', 'ovo']),
        build=[('Складіть: «Півкіло шинки, будь ласка.»', 'Pola kile šunke, molim.'),
               ('Складіть: «Ні, досить, дякую.»', 'Ne, dosta je, hvala.')],
        listen=['Može malo više?', 'Koliko kruha?'],
        speak=[('Літр молока, будь ласка.', 'Litru mlijeka, molim.'), ('Трохи більше, будь ласка.', 'Malo više, molim.')],
    ),
    '8.5': dict(
        title=('Кольори', 'Boje'), situation='shopping', grammar='adjectives',
        objectives=['Назвати основні кольори', 'Попросити річ іншого кольору', 'Узгоджувати колір з іменником: crna jakna, crni kaput'],
        words=['boja', 'bijel', 'crn', 'zelen', 'žut', 'siv', 'smeđ', 'ružičast', 'narančast', 'ljubičast', 'omiljen'],
        scenes=[
            ('Яку сукню?', 'Koju haljinu?', [
                ('Prodavačica', 'Koju boju želite?', 'Який колір бажаєте?'),
                ('Oksana', 'Zelenu ili žutu.', 'Зелену або жовту.'),
                ('Prodavačica', 'Imamo zelenu, ali žute nema. Može ružičasta?', 'Є зелена, а жовтої немає. Може, рожева?'),
                ('Oksana', 'Ne, hvala. Zelena je lijepa.', 'Ні, дякую. Зелена гарна.'),
            ]),
            ('Шукаю куртку', 'Tražim jaknu', [
                ('Andrij', 'Imate li ovu jaknu u crnoj boji?', 'У вас є ця куртка чорного кольору?'),
                ('Prodavač', 'Nemamo crnu. Imamo sivu i smeđu.', 'Чорної немає. Є сіра й коричнева.'),
                ('Andrij', 'Siva je dobra. A bijele majice?', 'Сіра підійде. А білі футболки?'),
                ('Prodavač', 'Bijele su tamo, pored narančastih.', 'Білі он там, біля помаранчевих.'),
            ]),
        ],
        fill=('Želim ___ jaknu.', 'crnu', ['crn', 'crna', 'crni']),
        build=[('Складіть: «Який колір бажаєте?»', 'Koju boju želite?'),
               ('Складіть: «Сіра підійде.»', 'Siva je dobra.')],
        listen=['Zelenu ili žutu.', 'Nemamo crnu. Imamo sivu i smeđu.'],
        speak=[('Мій улюблений колір — синій.', 'Moja omiljena boja je plava.'), ('У вас є біла?', 'Imate li bijelu?')],
    ),
    # ----------------------------------------------------- A0.9 Grad
    '9.4': dict(
        title=('Місця в місті', 'Mjesta u gradu'), situation='basics', grammar='place',
        objectives=['Назвати місця в місті: пошта, банк, лікарня', 'Запитати, чи є щось поруч', 'Пояснити, де розташоване місце'],
        words=['trgovina', 'pošta', 'banka', 'bolnica', 'park', 'kino', 'knjižnica', 'kafić', 'sladoled', 'ugao'],
        scenes=[
            ('Що тут поруч?', 'Što je blizu?', [
                ('Iryna', 'Oprostite, je li blizu neka trgovina?', 'Вибачте, тут поруч є якийсь магазин?'),
                ('Gospođa', 'Jest, pored pošte, a pošta je preko puta banke.', 'Так, біля пошти, а пошта навпроти банку.'),
                ('Iryna', 'A bolnica?', 'А лікарня?'),
                ('Gospođa', 'Bolnica je daleko. Ali ljekarna je ovdje, iza ugla.', 'Лікарня далеко. Але аптека тут, за рогом.'),
            ]),
            ('Вихідні з дітьми', 'Vikend s djecom', [
                ('Tata', 'Idemo u park ili u kino?', 'Підемо в парк чи в кіно?'),
                ('Kći', 'U park! A onda u knjižnicu.', 'У парк! А потім у бібліотеку.'),
                ('Tata', 'Knjižnica nije otvorena nedjeljom.', 'Бібліотека в неділю не працює.'),
                ('Kći', 'Onda kafić i sladoled!', 'Тоді кафе й морозиво!'),
            ]),
        ],
        fill=('Pošta je ___ puta banke.', 'preko', ['pored', 'iza', 'ispod']),
        build=[('Складіть: «Аптека за рогом.»', 'Ljekarna je iza ugla.'),
               ('Складіть: «Підемо в парк чи в кіно?»', 'Idemo u park ili kino?')],
        listen=['A bolnica?', 'Knjižnica nije otvorena nedjeljom.'],
        speak=[('Де лікарня?', 'Gdje je bolnica?'), ('Тут поруч є банк?', 'Je li blizu neka banka?')],
    ),
    '9.5': dict(
        title=('Як пройти?', 'Kako doći do…?'), situation='transport', grammar='word_order',
        objectives=['Запитати дорогу', 'Зрозуміти: прямо, поверніть, перейдіть міст', 'Вирішити: пішки чи трамваєм'],
        words=['skrenuti', 'semafor', 'most', 'prijeći', 'raskrižje', 'pješački prijelaz', 'tramvaj', 'bicikl', 'auto', 'gužva'],
        scenes=[
            ('Як дійти до вокзалу?', 'Kako do kolodvora?', [
                ('Turist', 'Oprostite, kako mogu doći do kolodvora?', 'Вибачте, як мені дійти до вокзалу?'),
                ('Gospodin', 'Idite ravno do semafora, pa skrenite desno.', 'Ідіть прямо до світлофора, потім поверніть праворуч.'),
                ('Turist', 'Je li to daleko?', 'Це далеко?'),
                ('Gospodin', 'Nije. Prijeđite most i tamo je.', 'Ні. Перейдіть міст — і ви там.'),
            ]),
            ('Пішки чи трамваєм?', 'Pješice ili tramvajem?', [
                ('Oksana', 'Idemo pješice ili tramvajem?', 'Ідемо пішки чи трамваєм?'),
                ('Ivan', 'Tramvajem, autom je gužva. Stanica je na raskrižju.', 'Трамваєм, машиною — затор. Зупинка на перехресті.'),
                ('Oksana', 'Gdje je pješački prijelaz?', 'Де пішохідний перехід?'),
                ('Ivan', 'Tamo, kod semafora. Pazi na bicikle!', 'Он там, біля світлофора. Обережно, велосипеди!'),
            ]),
        ],
        fill=('Gdje ___ stanica?', 'je', ['sam', 'se', 'li']),
        build=[('Складіть: «Поверніть праворуч.»', 'Skrenite desno.'),
               ('Складіть: «Де пішохідний перехід?»', 'Gdje je pješački prijelaz?')],
        listen=['Je li to daleko?', 'Tramvajem, autom je gužva.'],
        speak=[('Як мені дійти до центру?', 'Kako mogu doći do centra?'), ('Ідіть прямо.', 'Idite ravno.')],
    ),
    # ----------------------------------------------------- A0.10 Survival Croatian
    '10.4': dict(
        title=('Документи в MUP', 'U MUP-u'), situation='administration', grammar='questions',
        objectives=['Стати в чергу й узяти номерок', 'Подати документи на віконці', 'Зрозуміти, яких документів бракує'],
        words=['MUP', 'boravak', 'red', 'čekati', 'dokument', 'fotografija', 'OIB', 'kopija', 'šalter', 'sljedeći'],
        scenes=[
            ('У черзі', 'U redu', [
                ('Oleg', 'Oprostite, je li ovo red za boravak?', 'Вибачте, це черга щодо дозволу на проживання?'),
                ('Gospođa', 'Jest. Uzmite broj na automatu.', 'Так. Візьміть номерок в автоматі.'),
                ('Oleg', 'Koliko dugo čekamo?', 'Скільки ми чекаємо?'),
                ('Gospođa', 'Oko sat vremena. Ja čekam od osam.', 'Близько години. Я чекаю з восьмої.'),
            ]),
            ('На віконці', 'Na šalteru', [
                ('Službenica', 'Sljedeći! Izvolite, Vaše dokumente.', 'Наступний! Прошу ваші документи.'),
                ('Oleg', 'Evo putovnice, fotografije i OIB-a.', 'Ось паспорт, фотографія й OIB.'),
                ('Službenica', 'Trebam i kopiju putovnice.', 'Мені потрібна ще копія паспорта.'),
                ('Oleg', 'Nemam kopiju. Gdje je mogu napraviti?', 'У мене немає копії. Де її можна зробити?'),
                ('Službenica', 'Preko puta, u knjižari.', 'Навпроти, у книгарні.'),
            ]),
        ],
        fill=('___ dugo čekamo?', 'Koliko', ['Kada', 'Gdje', 'Tko']),
        build=[('Складіть: «Візьміть номерок в автоматі.»', 'Uzmite broj na automatu.'),
               ('Складіть: «Мені потрібна копія паспорта.»', 'Trebam kopiju putovnice.')],
        listen=['Koliko dugo čekamo?', 'Preko puta, u knjižari.'],
        speak=[('Де черга?', 'Gdje je red?'), ('Ось мій паспорт.', 'Evo moje putovnice.')],
    ),
    '10.5': dict(
        title=('Не можу знайти гаманець', 'Ne mogu naći novčanik'), situation='administration', grammar='negation',
        objectives=['Сказати, що ви не можете щось знайти', 'Заявити в поліцію', 'Описати річ: колір, матеріал'],
        words=['novčanik', 'naći', 'policija', 'policajac', 'prijaviti', 'osobna iskaznica', 'unutra', 'kožni', 'pomoć', 'odmah'],
        scenes=[
            ('Де мій гаманець?', 'Gdje je moj novčanik?', [
                ('Taras', 'Ne mogu naći novčanik!', 'Не можу знайти гаманець!'),
                ('Olena', 'Nije u torbi?', 'Його немає в сумці?'),
                ('Taras', 'Nije. Ni u jakni. Unutra su kartice i osobna iskaznica!', 'Ні. І в куртці немає. А в ньому картки й посвідчення особи!'),
                ('Olena', 'Idemo odmah u policiju.', 'Ходімо одразу в поліцію.'),
            ]),
            ('У поліції', 'U policiji', [
                ('Policajac', 'Izvolite, kako Vam mogu pomoći?', 'Прошу, чим можу допомогти?'),
                ('Taras', 'Nema mog novčanika. Želim to prijaviti.', 'Мого гаманця немає. Хочу про це заявити.'),
                ('Policajac', 'Kakav je novčanik?', 'Який гаманець?'),
                ('Taras', 'Smeđi, kožni. Unutra nema novca, samo dokumenti.', 'Коричневий, шкіряний. Грошей там немає, тільки документи.'),
                ('Policajac', 'Dobro. Ispunite ovaj obrazac.', 'Добре. Заповніть цей бланк.'),
            ]),
        ],
        fill=('Novčanik ___ u torbi.', 'nije', ['ne', 'nema', 'nisam']),
        build=[('Складіть: «Не можу знайти гаманець!»', 'Ne mogu naći novčanik!'),
               ('Складіть: «Хочу про це заявити.»', 'Želim to prijaviti.')],
        listen=['Nije u torbi?', 'Kakav je novčanik?'],
        speak=[('Мені потрібна допомога поліції.', 'Trebam pomoć policije.'), ('Мого паспорта немає.', 'Nema moje putovnice.')],
    ),
}
