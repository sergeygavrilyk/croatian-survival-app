"""
Дані для перебудови уроків A0 за темою (curriculum_a0_v4, 2026-10-15) — пілот: модуль A0.1 «Pozdrav!».

Рішення власника 2026-10-15:
  * слова уроку мають відповідати темі уроку (раніше їх брали зі сценки: «ключ» і «кімната» в уроці
    «Добрий день і до побачення», «пакет» в уроці «Вибачте, я не розумію»);
  * діалоги переписуємо під тему; 20–25 слів і виразів на урок (крім «Числа від 0 до 10»);
  * бета: PUBLISHED одразу, носій перевіряє після; стара версія уроку — у content_versions.

Імена в діалогах (побажання власника 2026-10-15): частіше — українка Даша (Daša, кличний відмінок Dašo) / Дар'я (Darja).

Формат уроку — як у full_lessons.py (title, situation, grammar, objectives, words, scenes, fill, build, listen, speak).
"""

# Нові слова й вирази (яких немає в словнику):
#   (лема, normalized, переклад, частина мови, vocabulary_type, forms, приклад)
NEW_LEXEMES = [
    ('zdravo', 'zdravo', 'привіт (у Хорватії частіше кажуть «bok»)', 'interjection', 'formulaic', {}, 'Zdravo, kako si?'),
    ('puno hvala', 'puno hvala', 'дуже дякую', 'phrase', 'formulaic', {}, 'Puno hvala na pomoći!'),
    ('ne baš dobro', 'ne bas dobro', 'не дуже добре', 'phrase', 'chunk', {}, 'Kako si? — Ne baš dobro, malo sam bolestan.'),
    ('tako-tako', 'tako-tako', 'так собі', 'phrase', 'formulaic', {}, 'Kako ide posao? — Tako-tako.'),
    ('a ti', 'a ti', 'а ти? (зустрічне питання)', 'phrase', 'chunk', {}, 'Dobro sam, hvala. A ti?'),
    ('a vi', 'a vi', 'а ви? (ввічливо)', 'phrase', 'chunk', {}, 'Dobro, hvala. A Vi?'),
    ('i ja', 'i ja', 'і я; я теж', 'phrase', 'chunk', {}, 'Umoran sam. — I ja.'),
    ('ugodan vikend', 'ugodan vikend', 'гарних вихідних', 'phrase', 'formulaic', {}, 'Doviđenja i ugodan vikend!'),
    ('vidimo se kasnije', 'vidimo se kasnije', 'побачимося пізніше', 'phrase', 'formulaic', {}, 'Sad moram ići, vidimo se kasnije!'),
    ('do skorog viđenja', 'do skorog videnja', 'до скорої зустрічі', 'phrase', 'formulaic', {}, 'Hvala na svemu i do skorog viđenja!'),
    ('pozdrav', 'pozdrav', 'привіт; вітання', 'noun', 'core', {'gender': 'm', 'plural': 'pozdravi'}, 'Pozdrav, Ivane! Kako si?'),
    ('lijep pozdrav', 'lijep pozdrav', 'щирий привіт; з повагою (наприкінці листа)', 'phrase', 'formulaic', {}, 'Vidimo se u ponedjeljak. Lijep pozdrav, Daša'),
    ('oprosti', 'oprosti', 'вибач (на «ти»)', 'verb', 'formulaic', {}, 'Oprosti, nisam te čuo.'),
    ('nisam razumio', 'nisam razumio', 'я не зрозумів (жін.: nisam razumjela)', 'phrase', 'chunk', {}, 'Oprostite, nisam razumio. Možete li ponoviti?'),
    ('nisam te čuo', 'nisam te cuo', 'я тебе не почув (жін.: nisam te čula)', 'phrase', 'chunk', {}, 'Oprosti, nisam te čuo. Što si rekla?'),
    ('sporije', 'sporije', 'повільніше', 'adverb', 'core', {}, 'Možete li govoriti sporije?'),
    ('glasnije', 'glasnije', 'голосніше', 'adverb', 'core', {}, 'Ne čujem Vas. Govorite glasnije, molim.'),
    ('što znači', 'sto znaci', 'що означає', 'phrase', 'chunk', {}, 'Što znači ova riječ?'),
    ('možete li napisati', 'mozete li napisati', 'можете написати?', 'phrase', 'chunk', {}, 'Možete li napisati adresu?'),
    ('jasno', 'jasno', 'зрозуміло; ясно', 'adverb', 'function_word', {}, 'Aha, sad mi je jasno.'),
    ('hvala na pomoći', 'hvala na pomoci', 'дякую за допомогу', 'phrase', 'formulaic', {}, 'Hvala na pomoći, jako ste ljubazni.'),
    ('i vama', 'i vama', 'і вам (теж)', 'phrase', 'formulaic', {}, 'Ugodan dan! — Hvala, i Vama.'),
    ('slobodno', 'slobodno', 'прошу, можна (дозвіл); вільно', 'adverb', 'formulaic', {}, 'Smijem li sjesti? — Slobodno.'),
    ('smijem li', 'smijem li', 'чи можна мені…?', 'phrase', 'chunk', {}, 'Smijem li otvoriti prozor?'),
    ('svakako', 'svakako', 'обов’язково; неодмінно', 'adverb', 'function_word', {}, 'Doći ćeš na rođendan? — Svakako!'),
    ('na zdravlje', 'na zdravlje', 'будьмо! (тост); будь здоров (коли чхають)', 'phrase', 'formulaic', {}, 'Podignimo čaše. Na zdravlje!'),
    ('pristojan', 'pristojan', 'ввічливий; пристойний', 'adjective', 'core', {'f': 'pristojna', 'n': 'pristojno'}, 'Naš susjed je uvijek pristojan.'),
]

# Знімок перекладів робочої бази для наявних слів, яких немає в reading_lexicon_snapshot.json (2026-10-15)
EXTRA_SNAPSHOT = {
    'super': ('super', 'супер'),
    'čujemo se': ('čujemo se', 'зідзвонимось'),
    'sretan put': ('sretan put', 'щасливої дороги'),
    'dan': ('dan', 'день'),
    'večer': ('večer', 'вечір'),
    'govorite li engleski': ('govorite li engleski', 'ви розмовляєте англійською'),
    'kako se kaže': ('kako se kaže', 'як сказати'),
    'riječ': ('riječ', 'слово'),
    'ne znam': ('ne znam', 'я не знаю'),
    'pitanje': ('pitanje', 'запитання'),
    'molim vas': ('molim vas', 'будь ласка (до вас)'),
    'može': ('može', 'можна / згода'),
    'sretan rođendan': ('sretan rođendan', 'З днем народження!'),
}

# Слова, для яких не робимо вправ «напишіть» / «як хорватською» (кілька правильних відповідей або службові)
NO_VOCAB = {'da', 'ne', 'a ti', 'a vi', 'i ja', 'i tebi', 'i vama', 'molim'}

# Уроки модуля A0.1: ключ — (модуль, місце в юніті)
LESSONS = {
    (1, 1): dict(
        title=('Привітання та подяка', 'Pozdravi i zahvale'), situation='basics', grammar=None,
        objectives=['Привітатися з другом і з незнайомою людиною', 'Запитати «Як справи?» і відповісти', 'Подякувати й відповісти на подяку'],
        words=['bok', 'zdravo', 'dobro došli', 'hvala', 'hvala lijepa', 'puno hvala', 'molim', 'nema na čemu',
               'kako si', 'kako ste', 'dobro', 'odlično', 'super', 'loše', 'ne baš dobro', 'tako-tako', 'umoran',
               'a ti', 'a vi', 'i ja', 'da', 'ne', 'žao mi je'],
        scenes=[
            ('Зустріч на вулиці', 'Susret na ulici', [
                ('Daša', 'Bok, Marko! Kako si?', 'Привіт, Марку! Як справи?'),
                ('Marko', 'Bok, Dašo! Super, hvala. A ti?', 'Привіт, Дашо! Чудово, дякую. А ти?'),
                ('Daša', 'Ne baš dobro. Umorna sam.', 'Не дуже добре. Я втомлена.'),
                ('Marko', 'Žao mi je. I ja sam malo umoran.', 'Мені шкода. Я теж трохи втомлений.'),
                ('Daša', 'Hvala ti. Bok!', 'Дякую тобі. Бувай!'),
            ]),
            ('У гостях у сусідки', 'Kod susjede', [
                ('Gospođa Horvat', 'Dobro došli! Izvolite.', 'Ласкаво просимо! Заходьте.'),
                ('Petro', 'Hvala lijepa! Kako ste?', 'Щиро дякую! Як ви?'),
                ('Gospođa Horvat', 'Odlično, hvala. A Vi?', 'Відмінно, дякую. А ви?'),
                ('Petro', 'Tako-tako. Imam puno posla.', 'Так собі. У мене багато роботи.'),
                ('Gospođa Horvat', 'Onda sjednite i odmorite se.', 'Тоді сідайте й відпочиньте.'),
                ('Petro', 'Puno hvala!', 'Дуже дякую!'),
            ]),
        ],
        fill=('Ja ___ umorna.', 'sam', ['si', 'je', 'smo']),
        build=[('Складіть: «Добре, дякую. А ти?»', 'Dobro, hvala. A ti?'),
               ('Складіть: «Я теж трохи втомлений.»', 'I ja sam malo umoran.')],
        listen=['Žao mi je. I ja sam malo umoran.', 'Odlično, hvala. A Vi?'],
        speak=[('Як справи? (до друга)', 'Kako si?'), ('Дуже дякую!', 'Puno hvala!')],
    ),
    (1, 2): dict(
        title=('Добрий день і до побачення', 'Dobar dan i doviđenja'), situation='basics', grammar=None,
        objectives=['Вітатися зранку, вдень і ввечері', 'Прощатися й бажати гарного дня, вечора чи вихідних', 'Казати «до завтра» і «побачимося пізніше»'],
        words=['dobro jutro', 'dobar dan', 'dobra večer', 'laku noć', 'doviđenja', 'ugodan dan', 'ugodna večer',
               'ugodan vikend', 'vidimo se', 'do sutra', 'vidimo se kasnije', 'do skorog viđenja', 'čujemo se',
               'sretan put', 'pozdrav', 'lijep pozdrav', 'pozdraviti', 'jutro', 'dan', 'večer', 'noć'],
        scenes=[
            ('Ранок у під’їзді', 'Jutro u zgradi', [
                ('Gospodin Kovač', 'Dobro jutro, Dašo!', 'Доброго ранку, Дашо!'),
                ('Daša', 'Dobro jutro, gospodine Kovač! Kako ste?', 'Доброго ранку, пане Ковач! Як ви?'),
                ('Gospodin Kovač', 'Dobro, hvala. Idem na posao.', 'Добре, дякую. Іду на роботу.'),
                ('Daša', 'I ja. Ugodan dan!', 'Я теж. Гарного дня!'),
                ('Gospodin Kovač', 'Hvala, i Vama. Doviđenja!', 'Дякую, і вам. До побачення!'),
            ]),
            ('Увечері після курсу', 'Navečer poslije tečaja', [
                ('Maja', 'Ja idem kući. Vidimo se sutra?', 'Я йду додому. Побачимося завтра?'),
                ('Ivan', 'Sutra ne mogu. Čujemo se!', 'Завтра не можу. Зідзвонимося!'),
                ('Maja', 'Dobro. Ugodna večer i ugodan vikend!', 'Добре. Гарного вечора й гарних вихідних!'),
                ('Ivan', 'Hvala, i tebi. Pozdravi mamu!', 'Дякую, і тобі. Передавай привіт мамі!'),
                ('Maja', 'Hoću. Laku noć!', 'Обов’язково. На добраніч!'),
            ]),
        ],
        fill=('Hvala, i ___, gospodine Kovač!', 'Vama', ['tebi', 'ti', 'Vas']),
        build=[('Складіть: «Гарного дня!»', 'Ugodan dan!'),
               ('Складіть: «Побачимося пізніше!»', 'Vidimo se kasnije!')],
        listen=['Hvala, i Vama. Doviđenja!', 'Hoću. Laku noć!'],
        speak=[('Доброго ранку!', 'Dobro jutro!'), ('Гарних вихідних!', 'Ugodan vikend!')],
    ),
    (1, 3): dict(
        title=('Вибачте, я не розумію', 'Oprostite, ne razumijem'), situation='basics', grammar=None,
        objectives=['Сказати, що ви не зрозуміли чи не почули', 'Попросити повторити, говорити повільніше чи голосніше', 'Запитати, що означає слово і як щось сказати'],
        words=['oprostite', 'oprosti', 'ne razumijem', 'razumjeti', 'nisam razumio', 'nisam te čuo', 'možete li ponoviti',
               'polako', 'sporije', 'glasnije', 'malo', 'govoriti', 'govorite li engleski', 'engleski', 'što znači',
               'kako se kaže', 'riječ', 'možete li napisati', 'ne znam', 'naravno', 'pitanje', 'jasno'],
        scenes=[
            ('Турист у Загребі', 'Turist u Zagrebu', [
                ('Turist', 'Oprostite, govorite li engleski?', 'Вибачте, ви розмовляєте англійською?'),
                ('Prolaznik', 'Malo. Izvolite?', 'Трохи. Слухаю вас?'),
                ('Turist', 'Ne razumijem dobro hrvatski. Možete li govoriti polako?', 'Я погано розумію хорватську. Можете говорити повільно?'),
                ('Prolaznik', 'Naravno. Tramvaj broj šest ide u centar.', 'Звісно. Трамвай номер шість їде в центр.'),
                ('Turist', 'Oprostite, nisam razumio. Možete li ponoviti?', 'Вибачте, я не зрозумів. Можете повторити?'),
                ('Prolaznik', 'Tramvaj broj šest. Šest!', 'Трамвай номер шість. Шість!'),
            ]),
            ('На курсі хорватської', 'Na tečaju hrvatskog', [
                ('Daša', 'Oprostite, što znači »sutra«?', 'Вибачте, що означає «sutra»?'),
                ('Profesorica', 'Danas je ponedjeljak, a sutra je utorak.', 'Сьогодні понеділок, а завтра вівторок.'),
                ('Daša', 'Aha, jasno! A kako se kaže »thank you«?', 'А, зрозуміло! А як сказати «thank you»?'),
                ('Profesorica', 'Kaže se: hvala.', 'Кажуть: «hvala».'),
                ('Daša', 'Oprostite, nisam Vas čula. Možete li ponoviti glasnije?', 'Вибачте, я вас не почула. Можете повторити голосніше?'),
                ('Profesorica', 'Naravno. Hvala!', 'Звісно. «Hvala»!'),
            ]),
        ],
        fill=('Oprostite, ___ razumijem.', 'ne', ['ni', 'nije', 'nisam']),
        build=[('Складіть: «Що означає це слово?»', 'Što znači ova riječ?'),
               ('Складіть: «Можете написати?»', 'Možete li napisati?')],
        listen=['Oprostite, nisam razumio. Možete li ponoviti?', 'Aha, jasno!'],
        speak=[('Я не розумію.', 'Ne razumijem.'), ('Говоріть повільніше, будь ласка.', 'Govorite sporije, molim.')],
    ),
    (1, 4): dict(
        title=('Ввічливі слова', 'Pristojne riječi'), situation='basics', grammar=None,
        objectives=['Перепросити й відповісти на вибачення', 'Попросити дозволу й дозволити', 'Привітати з днем народження й побажати успіху'],
        words=['izvolite', 'molim vas', 'ispričavam se', 'nema problema', 'u redu', 'može', 'slobodno', 'smijem li',
               'svakako', 'sretno', 'čestitam', 'sretan rođendan', 'i tebi', 'i vama', 'hvala na pomoći', 'kasniti',
               'na zdravlje', 'dobar tek', 'nažalost', 'pristojan', 'ljubazan'],
        scenes=[
            ('Перепрошую!', 'Ispričavam se!', [
                ('Daša', 'Ispričavam se, kasnim pet minuta.', 'Перепрошую, я запізнююся на п’ять хвилин.'),
                ('Gospođa Horvat', 'Nema problema. Izvolite, sjednite.', 'Нічого страшного. Прошу, сідайте.'),
                ('Daša', 'Hvala. Smijem li otvoriti prozor?', 'Дякую. Можна відчинити вікно?'),
                ('Gospođa Horvat', 'Slobodno.', 'Прошу, відчиняйте.'),
                ('Daša', 'Hvala, jako ste ljubazni.', 'Дякую, ви дуже люб’язні.'),
                ('Gospođa Horvat', 'Molim, nema na čemu.', 'Прошу, нема за що.'),
            ]),
            ('День народження', 'Rođendan', [
                ('Marko', 'Sretan rođendan, Dašo! Čestitam!', 'З днем народження, Дашо! Вітаю!'),
                ('Daša', 'Hvala, Marko! Izvoli, sok ili vino?', 'Дякую, Марку! Прошу, сік чи вино?'),
                ('Marko', 'Vino, molim. Na zdravlje!', 'Вино, будь ласка. Будьмо!'),
                ('Daša', 'Na zdravlje! I sretno na novom poslu!', 'Будьмо! І успіхів на новій роботі!'),
                ('Marko', 'Hvala, i tebi!', 'Дякую, і тобі!'),
            ]),
        ],
        fill=('Ispričavam ___, kasnim.', 'se', ['si', 'te', 'me']),
        build=[('Складіть: «Перепрошую, я запізнююся.»', 'Ispričavam se, kasnim.'),
               ('Складіть: «З днем народження!»', 'Sretan rođendan!')],
        listen=['Nema problema. Izvolite, sjednite.', 'Vino, molim. Na zdravlje!'],
        speak=[('Можна? (просимо дозволу)', 'Smijem li?'), ('Дякую за допомогу!', 'Hvala na pomoći!')],
    ),
}
