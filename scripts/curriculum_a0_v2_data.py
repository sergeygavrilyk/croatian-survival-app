"""
Програма A0, версія 2 (2026-10-13): розширення уроків до 10–15 хвилин.
Рішення власника: «повна структура уроку», одразу всі 30 уроків, 10–15 хв.

Що додає кожен урок (поверх v1 — scripts/curriculum_a0_data.py, нічого не видаляється):
  * words    — додаткові слова (разом з v1 — 10–12 слів на урок; лише слова, які є в словнику
               або в NEW_LEXEMES нижче);
  * scene    — друга сцена діалогу (4–6 реплік): (назва_ua, назва_hr, [(мовець, hr, ua), ...]);
  * build    — «склади речення» з репліки другої сцени: (підказка_ua, речення_hr);
  * listen   — «аудіювання»: речення з другої сцени;
  * speak    — 2 фрази «скажіть уголос»: [(переклад_ua, речення_hr), ...] (з обох сцен).
Вправи на слова (2 × «що означає», 1 × «як сказати», 2 × «напишіть») генератор
будує сам зі слів уроку — переклади беруться з бази під час запуску SQL.

Правила (CLAUDE.md → «Хорватський контент»): стандартна хорватська (ijekavica),
природні фрази; у «склади речення» / «аудіюванні» слова в реченні не повторюються.
"""

# ----------------------------------------------------------------------------
# Нові слова (A0). (lemma, normalized, переклад, частина мови, vocabulary_type, forms, приклад)
# ----------------------------------------------------------------------------
NEW_LEXEMES = [
    ('kako si', 'kako si', 'як ти?; як справи? (до друга)', 'phrase', 'formulaic', {}, 'Bok, Marko! Kako si?'),
    ('kako ste', 'kako ste', 'як ви?; як справи? (ввічливо)', 'phrase', 'formulaic', {}, 'Dobar dan, gospođo! Kako ste?'),
    ('hvala lijepa', 'hvala lijepa', 'щиро дякую', 'phrase', 'formulaic', {}, 'Hvala lijepa na pomoći!'),
    ('jagoda', 'jagoda', 'полуниця', 'noun', 'core', {'gender': 'f'}, 'Ove jagode su jako slatke.'),
    ('tjestenina', 'tjestenina', 'макарони; паста', 'noun', 'core', {'gender': 'f'}, 'Za ručak imamo tjesteninu.'),
    ('preko puta', 'preko puta', 'навпроти', 'adverb', 'chunk', {}, 'Stanica je preko puta.'),
    ('nažalost', 'nazalost', 'на жаль', 'adverb', 'function_word', {}, 'Nažalost, nemam vremena.'),
    ('u redu', 'u redu', 'гаразд; добре', 'phrase', 'formulaic', {}, 'U redu, vidimo se sutra.'),
    ('ukupno', 'ukupno', 'разом; загалом', 'adverb', 'core', {}, 'Ukupno je dvadeset eura.'),
    ('napojnica', 'napojnica', 'чайові', 'noun', 'core', {'gender': 'f'}, 'Konobaru smo ostavili napojnicu.'),
    ('datum rođenja', 'datum rodenja', 'дата народження', 'phrase', 'collocation', {}, 'Upišite datum rođenja ovdje.'),
    ('termin', 'termin', '(вільний) час; запис (до лікаря, перукаря)', 'noun', 'core', {'gender': 'm'}, 'Imate li slobodan termin u petak?'),
    ('sladak', 'sladak', 'солодкий', 'adjective', 'core', {}, 'Ove jagode su slatke.'),
]

# Урок 1 створено до v1 (c0000000-…-0001): його слова в базі — bok, hvala
LESSON1_BASE_WORDS = ['bok', 'hvala']

# ----------------------------------------------------------------------------
# Номер уроку (1–30) → розширення
# ----------------------------------------------------------------------------
LESSONS = {
    1: dict(
        words=['kako si', 'kako ste', 'dobro', 'loše', 'umoran', 'žao mi je', 'hvala lijepa', 'da', 'ne'],
        scene=('У сусідки', 'Kod susjede', [
            ('Ivana', 'Dobar dan, gospodine Petrenko! Kako ste?', 'Добрий день, пане Петренко! Як ви?'),
            ('Petrenko', 'Dobro, hvala. A Vi?', 'Добре, дякую. А ви?'),
            ('Ivana', 'Ne baš dobro. Umorna sam.', 'Не дуже добре. Я втомлена.'),
            ('Petrenko', 'Žao mi je.', 'Мені шкода.'),
            ('Ivana', 'Hvala. Doviđenja!', 'Дякую. До побачення!'),
        ]),
        build=('Складіть: «Добре, дякую. А ви?»', 'Dobro, hvala. A Vi?'),
        listen='Ne baš dobro. Umorna sam.',
        speak=[('Привіт! Як справи?', 'Bok! Kako si?'), ('Мені шкода.', 'Žao mi je.')],
        extra=[('build', 'Складіть: «Привіт! Як справи?»', 'Bok! Kako si?'),
               ('listen', 'Dobro sam, hvala.')],
    ),
    2: dict(
        words=['kava', 'hvala lijepa', 'ključ', 'soba', 'rezervacija'],
        scene=('Увечері в готелі', 'Navečer u hotelu', [
            ('Recepcionarka', 'Dobra večer! Izvolite?', 'Добрий вечір! Слухаю вас?'),
            ('Olena', 'Dobra večer. Imam rezervaciju.', 'Добрий вечір. У мене бронювання.'),
            ('Recepcionarka', 'Da, izvolite ključ. Soba broj dvanaest.', 'Так, ось ключ. Кімната номер дванадцять.'),
            ('Olena', 'Hvala lijepa. Laku noć!', 'Щиро дякую. На добраніч!'),
            ('Recepcionarka', 'Laku noć i ugodan boravak!', 'На добраніч і приємного перебування!'),
        ]),
        build=('Складіть: «Добрий вечір. У мене бронювання.»', 'Dobra večer. Imam rezervaciju.'),
        listen='Hvala lijepa. Laku noć!',
        speak=[('Одну каву, будь ласка.', 'Jednu kavu, molim.'), ('У мене бронювання.', 'Imam rezervaciju.')],
    ),
    3: dict(
        words=['polako', 'malo', 'govoriti', 'engleski', 'vrećica'],
        scene=('У магазині', 'U trgovini', [
            ('Prodavačica', 'Trebate li vrećicu?', 'Вам потрібен пакет?'),
            ('Olena', 'Oprostite, ne razumijem. Možete li ponoviti?', 'Вибачте, не розумію. Можете повторити?'),
            ('Prodavačica', 'Vrećicu? Trebate li vrećicu?', 'Пакет? Вам потрібен пакет?'),
            ('Olena', 'Ah, da. Jednu, molim.', 'А, так. Один, будь ласка.'),
            ('Prodavačica', 'Izvolite.', 'Прошу.'),
            ('Olena', 'Hvala!', 'Дякую!'),
        ]),
        build=('Складіть: «Вибачте, не розумію.»', 'Oprostite, ne razumijem.'),
        listen='Trebate li vrećicu?',
        speak=[('Можете говорити повільно?', 'Možete li govoriti polako?'), ('Можете повторити?', 'Možete li ponoviti?')],
    ),
    4: dict(
        words=['gospodin', 'gospođa', 'bok', 'ja', 'ti', 'vi'],
        scene=('На прийомі в лікаря', 'Kod liječnika', [
            ('Medicinska sestra', 'Dobar dan. Kako se zovete?', 'Добрий день. Як вас звати?'),
            ('Oleg', 'Zovem se Oleg.', 'Мене звати Олег.'),
            ('Medicinska sestra', 'A Vaše prezime?', 'А ваше прізвище?'),
            ('Oleg', 'Petrenko.', 'Петренко.'),
            ('Medicinska sestra', 'Hvala, gospodine Petrenko. Izvolite sjesti.', 'Дякую, пане Петренко. Сідайте, будь ласка.'),
        ]),
        build=('Складіть: «Добрий день. Як вас звати?»', 'Dobar dan. Kako se zovete?'),
        listen='A Vaše prezime?',
        speak=[('Мене звати Олег.', 'Zovem se Oleg.'), ('Приємно познайомитися.', 'Drago mi je.')],
    ),
    5: dict(
        words=['Hrvatska', 'more', 'lijep', 'ali', 'daleko'],
        scene=('На каві з колегою', 'S kolegom na kavi', [
            ('Marko', 'Odakle si?', 'Звідки ти?'),
            ('Iryna', 'Iz Ukrajine, iz Lavova. A ti?', 'З України, зі Львова. А ти?'),
            ('Marko', 'Ja sam iz Splita, ali živim u Zagrebu.', 'Я зі Спліта, але живу в Загребі.'),
            ('Iryna', 'Zagreb je lijep grad.', 'Загреб — гарне місто.'),
            ('Marko', 'Da, ali more je daleko!', 'Так, але море далеко!'),
        ]),
        build=('Складіть: «Загреб — гарне місто.»', 'Zagreb je lijep grad.'),
        listen='Da, ali more je daleko!',
        speak=[('Я з України.', 'Ja sam iz Ukrajine.'), ('Я живу в Загребі.', 'Živim u Zagrebu.')],
    ),
    6: dict(
        words=['medicinska sestra', 'iskustvo', 'učiti', 'hrvatski', 'odlično'],
        scene=('Співбесіда', 'Razgovor za posao', [
            ('Direktorica', 'Dobar dan. Što ste po zanimanju?', 'Добрий день. Хто ви за фахом?'),
            ('Oksana', 'Ja sam medicinska sestra.', 'Я медсестра.'),
            ('Direktorica', 'Imate li iskustva?', 'У вас є досвід?'),
            ('Oksana', 'Da, pet godina.', 'Так, п’ять років.'),
            ('Direktorica', 'Odlično. Govorite li hrvatski?', 'Чудово. Ви говорите хорватською?'),
            ('Oksana', 'Malo. Učim hrvatski.', 'Трохи. Я вчу хорватську.'),
        ]),
        build=('Складіть: «Я медсестра.»', 'Ja sam medicinska sestra.'),
        listen='Malo. Učim hrvatski.',
        speak=[('Я програміст.', 'Ja sam programer.'), ('Я вчу хорватську.', 'Učim hrvatski.')],
    ),
    7: dict(
        words=[],
        scene=('Доставка', 'Dostava', [
            ('Dostavljač', 'Dobar dan! Koji je Vaš kućni broj?', 'Добрий день! Який номер вашого будинку?'),
            ('Ana', 'Broj sedam.', 'Номер сім.'),
            ('Dostavljač', 'A stan?', 'А квартира?'),
            ('Ana', 'Stan broj tri, na drugom katu.', 'Квартира номер три, на другому поверсі.'),
            ('Dostavljač', 'Hvala! Stižem za pet minuta.', 'Дякую! Буду за п’ять хвилин.'),
        ]),
        build=('Складіть: «Квартира номер три.»', 'Stan broj tri.'),
        listen='Stižem za pet minuta.',
        speak=[('Повтори, будь ласка.', 'Ponovi, molim te.'), ('Номер сім.', 'Broj sedam.')],
    ),
    8: dict(
        words=['pas', 'star', 'dvadeset', 'četrdeset', 'pedeset'],
        scene=('У парку', 'U parku', [
            ('Luka', 'Koliko imaš godina?', 'Скільки тобі років?'),
            ('Sofija', 'Imam šest godina. A ti?', 'Мені шість років. А тобі?'),
            ('Luka', 'Ja imam sedam. Ovo je moj pas.', 'Мені сім. Це мій пес.'),
            ('Sofija', 'Koliko godina ima pas?', 'Скільки років собаці?'),
            ('Luka', 'Dvije.', 'Два.'),
        ]),
        build=('Складіть: «Скільки тобі років?»', 'Koliko imaš godina?'),
        listen='Ovo je moj pas.',
        speak=[('Мені тридцять п’ять років.', 'Imam trideset pet godina.'), ('Скільки тобі років?', 'Koliko imaš godina?')],
    ),
    9: dict(
        words=['kruh', 'pekara', 'skupo', 'jeftino'],
        scene=('У пекарні', 'U pekari', [
            ('Prodavačica', 'Dobro jutro! Izvolite?', 'Доброго ранку! Що бажаєте?'),
            ('Kupac', 'Jedan kruh i dva kroasana, molim.', 'Одну хлібину й два круасани, будь ласка.'),
            ('Prodavačica', 'Još nešto?', 'Ще щось?'),
            ('Kupac', 'Ne, hvala. Koliko je to?', 'Ні, дякую. Скільки з мене?'),
            ('Prodavačica', 'Četiri eura i dvadeset centi.', 'Чотири євро двадцять центів.'),
        ]),
        build=('Складіть: «Ні, дякую. Скільки з мене?»', 'Ne, hvala. Koliko je to?'),
        listen='Četiri eura i dvadeset centi.',
        speak=[('Скільки це коштує?', 'Koliko to košta?'), ('Один хліб, будь ласка.', 'Jedan kruh, molim.')],
    ),
    10: dict(
        words=['termin', 'u redu'],
        scene=('Запис до перукаря', 'Kod frizera', [
            ('Frizerka', 'Frizerski salon, izvolite.', 'Перукарня, слухаю.'),
            ('Marta', 'Dobar dan. Imate li slobodan termin u četvrtak?', 'Добрий день. У вас є вільний час у четвер?'),
            ('Frizerka', 'U četvrtak ne, ali u petak da.', 'У четвер ні, а в п’ятницю так.'),
            ('Marta', 'Petak je dobro. Hvala!', 'П’ятниця підходить. Дякую!'),
            ('Frizerka', 'U redu, vidimo se u petak.', 'Добре, побачимося в п’ятницю.'),
        ]),
        build=('Складіть: «Добре, побачимося в п’ятницю.»', 'U redu, vidimo se u petak.'),
        listen='Petak je dobro.',
        speak=[('Сьогодні середа.', 'Danas je srijeda.'), ('Побачимося в п’ятницю!', 'Vidimo se u petak!')],
    ),
    11: dict(
        words=['jutro', 'vrijeme', 'škola', 'noć'],
        scene=('Вранці вдома', 'Ujutro kod kuće', [
            ('Mama', 'Ustani, kasno je!', 'Вставай, уже пізно!'),
            ('Dino', 'Koliko je sati?', 'Котра година?'),
            ('Mama', 'Sedam i pol.', 'Пів на восьму.'),
            ('Dino', 'Škola počinje u osam. Imam vremena!', 'Школа починається о восьмій. У мене є час!'),
            ('Mama', 'Nemaš! Autobus ide u sedam i četrdeset.', 'Немає! Автобус їде о сьомій сорок.'),
        ]),
        build=('Складіть: «Школа починається о восьмій.»', 'Škola počinje u osam.'),
        listen='Ustani, kasno je!',
        speak=[('Котра година?', 'Koliko je sati?'), ('Об одинадцятій.', 'U jedanaest sati.')],
    ),
    12: dict(
        words=['kolovoz', 'rujan', 'vruće', 'godišnji odmor'],
        scene=('Плани на відпустку', 'Planovi za godišnji', [
            ('Ana', 'Kada ideš na godišnji odmor?', 'Коли ти йдеш у відпустку?'),
            ('Ivan', 'U kolovozu. Idem na more.', 'У серпні. Їду на море.'),
            ('Ana', 'Ja idem u rujnu. Tada nije tako vruće.', 'Я йду у вересні. Тоді не так спекотно.'),
            ('Ivan', 'Imaš pravo.', 'Ти маєш рацію.'),
        ]),
        build=('Складіть: «У серпні. Їду на море.»', 'U kolovozu. Idem na more.'),
        listen='Tada nije tako vruće.',
        speak=[('Я люблю літо.', 'Volim ljeto.'), ('Мій день народження в липні.', 'Rođendan mi je u srpnju.')],
    ),
    13: dict(
        words=['mama', 'tata', 'baka', 'djed', 'selo'],
        scene=('Фото на телефоні', 'Slika na mobitelu', [
            ('Maja', 'Je li ovo tvoja mama?', 'Це твоя мама?'),
            ('Oleg', 'Da, to je moja mama, a ovo je moj tata.', 'Так, це моя мама, а це мій тато.'),
            ('Maja', 'Gdje žive?', 'Де вони живуть?'),
            ('Oleg', 'U Kijevu. Baka i djed žive na selu.', 'У Києві. Бабуся й дідусь живуть у селі.'),
            ('Maja', 'Lijepa obitelj!', 'Гарна родина!'),
        ]),
        build=('Складіть: «Бабуся й дідусь живуть у селі.»', 'Baka i djed žive na selu.'),
        listen='Je li ovo tvoja mama?',
        speak=[('Це моя родина.', 'Ovo je moja obitelj.'), ('Хто це?', 'Tko je to?')],
    ),
    14: dict(
        words=['djeca', 'sin', 'drago mi je', 'koliko'],
        scene=('На дні народження', 'Na rođendanu', [
            ('Petra', 'Tko je ovo?', 'Хто це?'),
            ('Andrij', 'Ovo je moja žena Olga.', 'Це моя дружина Ольга.'),
            ('Petra', 'Drago mi je! Imate li djecu?', 'Приємно познайомитися! У вас є діти?'),
            ('Olga', 'Imamo jednog sina. Zove se Maksim.', 'У нас один син. Його звати Максим.'),
            ('Petra', 'Koliko ima godina?', 'Скільки йому років?'),
            ('Olga', 'Četiri.', 'Чотири.'),
        ]),
        build=('Складіть: «У нас один син.»', 'Imamo jednog sina.'),
        listen='Ovo je moja žena Olga.',
        speak=[('У мене одна сестра.', 'Imam jednu sestru.'), ('У вас є діти?', 'Imate li djecu?')],
    ),
    15: dict(
        words=['prijateljica', 'učitelj', 'igrati', 'škola'],
        scene=('Після школи', 'Poslije škole', [
            ('Teta', 'Kako je bilo u školi?', 'Як було в школі?'),
            ('Tin', 'Dobro! Imam novog prijatelja.', 'Добре! У мене новий друг.'),
            ('Teta', 'Kako se zove?', 'Як його звати?'),
            ('Tin', 'Zove se Bohdan. On je iz Ukrajine.', 'Його звати Богдан. Він з України.'),
            ('Teta', 'Super! Pozovi ga k nama.', 'Супер! Запроси його до нас.'),
        ]),
        build=('Складіть: «У мене новий друг.»', 'Imam novog prijatelja.'),
        listen='Kako je bilo u školi?',
        speak=[('У мене син і донька.', 'Imam sina i kćer.'), ('Як його звати?', 'Kako se zove?')],
    ),
    16: dict(
        words=['najam', 'režije', 'balkon', 'prozor'],
        scene=('Оренда квартири', 'Najam stana', [
            ('Oleg', 'Koliko je najam?', 'Скільки коштує оренда?'),
            ('Agentica', 'Petsto eura mjesečno.', 'П’ятсот євро на місяць.'),
            ('Oleg', 'Je li uključena struja?', 'Електрика входить у ціну?'),
            ('Agentica', 'Ne, režije se plaćaju posebno.', 'Ні, комунальні оплачуються окремо.'),
            ('Oleg', 'U redu. Mogu li doći sutra?', 'Добре. Можу прийти завтра?'),
        ]),
        build=('Складіть: «Скільки коштує оренда?»', 'Koliko je najam?'),
        listen='Petsto eura mjesečno.',
        speak=[('Де кухня?', 'Gdje je kuhinja?'), ('Можу прийти завтра?', 'Mogu li doći sutra?')],
    ),
    17: dict(
        words=['mobitel', 'naočale', 'vrata', 'prozor'],
        scene=('Де телефон?', 'Gdje je mobitel?', [
            ('Ivan', 'Vidiš li moj mobitel?', 'Ти бачиш мій телефон?'),
            ('Ana', 'Je li na krevetu?', 'Він на ліжку?'),
            ('Ivan', 'Nije.', 'Ні.'),
            ('Ana', 'Evo ga, pored televizora!', 'Ось він, біля телевізора!'),
            ('Ivan', 'Hvala!', 'Дякую!'),
        ]),
        build=('Складіть: «Ти бачиш мій телефон?»', 'Vidiš li moj mobitel?'),
        listen='Evo ga, pored televizora!',
        speak=[('Де мої ключі?', 'Gdje su moji ključevi?'), ('Ось вони!', 'Evo ih!')],
    ),
    18: dict(
        words=['lampa', 'tepih', 'namještaj', 'tražiti'],
        scene=('У меблевому магазині', 'U trgovini namještajem', [
            ('Prodavač', 'Trebate li pomoć?', 'Вам допомогти?'),
            ('Kupac', 'Da. Tražim stol i četiri stolice.', 'Так. Шукаю стіл і чотири стільці.'),
            ('Prodavač', 'Ovaj stol je od drva.', 'Цей стіл дерев’яний.'),
            ('Kupac', 'Lijep je. Koliko košta?', 'Гарний. Скільки коштує?'),
            ('Prodavač', 'Tristo eura.', 'Триста євро.'),
        ]),
        build=('Складіть: «Шукаю стіл і чотири стільці.»', 'Tražim stol i četiri stolice.'),
        listen='Ovaj stol je od drva.',
        speak=[('Що є у твоїй кімнаті?', 'Što ima u tvojoj sobi?'), ('Скільки коштує?', 'Koliko košta?')],
    ),
    19: dict(
        words=['doručak', 'jaje', 'piće', 'naranča', 'ručak'],
        scene=('Сніданок', 'Doručak', [
            ('Mama', 'Što želiš za doručak?', 'Що хочеш на сніданок?'),
            ('Dino', 'Jaja i kruh.', 'Яйця і хліб.'),
            ('Mama', 'A za piće? Mlijeko ili sok?', 'А пити? Молоко чи сік?'),
            ('Dino', 'Sok od naranče, molim.', 'Апельсиновий сік, будь ласка.'),
        ]),
        build=('Складіть: «Що хочеш на сніданок?»', 'Što želiš za doručak?'),
        listen='Sok od naranče, molim.',
        speak=[('Я дуже голодний.', 'Jako sam gladan.'), ('Яйця і хліб.', 'Jaja i kruh.')],
    ),
    20: dict(
        words=['juha', 'tjestenina', 'salata', 'meso', 'riba', 'jesti'],
        scene=('Замовлення їжі', 'Narudžba', [
            ('Konobar', 'Želite li nešto jesti?', 'Бажаєте щось поїсти?'),
            ('Gost', 'Što preporučujete?', 'Що порадите?'),
            ('Konobar', 'Danas imamo dobru juhu i tjesteninu.', 'Сьогодні в нас смачний суп і паста.'),
            ('Gost', 'Onda juhu, molim.', 'Тоді суп, будь ласка.'),
            ('Konobar', 'Odmah stiže.', 'Зараз принесу.'),
        ]),
        build=('Складіть: «Тоді суп, будь ласка.»', 'Onda juhu, molim.'),
        listen='Što preporučujete?',
        speak=[('Каву з молоком, будь ласка.', 'Kavu s mlijekom, molim.'), ('Що порадите?', 'Što preporučujete?')],
    ),
    21: dict(
        words=['ukupno', 'napojnica', 'gotovina', 'kartica', 'hvala lijepa', 'doviđenja'],
        scene=('Розрахунок', 'Plaćanje', [
            ('Konobarica', 'Ukupno dvadeset dva eura.', 'Разом двадцять два євро.'),
            ('Gost', 'Izvolite dvadeset pet. U redu je.', 'Ось двадцять п’ять. Решти не треба.'),
            ('Konobarica', 'Hvala lijepa! Doviđenja!', 'Щиро дякую! До побачення!'),
            ('Gost', 'Doviđenja!', 'До побачення!'),
        ]),
        build=('Складіть: «Разом двадцять два євро.»', 'Ukupno dvadeset dva eura.'),
        listen='Izvolite dvadeset pet.',
        speak=[('Рахунок, будь ласка.', 'Molim vas, račun.'), ('Можна заплатити карткою?', 'Mogu li platiti karticom?')],
    ),
    22: dict(
        words=['jagoda', 'banana', 'krumpir', 'sladak'],
        scene=('Полуниці', 'Jagode', [
            ('Kupac', 'Jesu li jagode slatke?', 'Полуниці солодкі?'),
            ('Prodavač', 'Jako slatke! Probajte.', 'Дуже солодкі! Спробуйте.'),
            ('Kupac', 'Odlične su. Kilu jagoda, molim.', 'Чудові. Кілограм полуниць, будь ласка.'),
            ('Prodavač', 'Pet eura. Još nešto?', 'П’ять євро. Ще щось?'),
            ('Kupac', 'Ne, to je sve.', 'Ні, це все.'),
        ]),
        build=('Складіть: «Полуниці солодкі?»', 'Jesu li jagode slatke?'),
        listen='Ne, to je sve.',
        speak=[('Кілограм яблук, будь ласка.', 'Kilu jabuka, molim.'), ('Ні, це все.', 'Ne, to je sve.')],
    ),
    23: dict(
        words=['hlače', 'cipele', 'veličina', 'mali', 'crven'],
        scene=('Примірочна', 'U kabini', [
            ('Kupac', 'Mogu li probati ovu majicu?', 'Можна приміряти цю футболку?'),
            ('Prodavačica', 'Naravno, kabina je lijevo.', 'Звісно, примірочна ліворуч.'),
            ('Kupac', 'Ova je mala. Imate li veću?', 'Ця мала. Є більша?'),
            ('Prodavačica', 'Imamo. Izvolite, veličina L.', 'Є. Прошу, розмір L.'),
        ]),
        build=('Складіть: «Можна приміряти цю футболку?»', 'Mogu li probati ovu majicu?'),
        listen='Ova je mala. Imate li veću?',
        speak=[('Скільки коштує ця футболка?', 'Koliko košta ova majica?'), ('Візьму синю.', 'Uzet ću plavu.')],
    ),
    24: dict(
        words=['kartica', 'gotovina', 'nažalost', 'račun'],
        scene=('Картку не приймає', 'Kartica ne prolazi', [
            ('Blagajnik', 'Dvadeset eura, molim.', 'Двадцять євро, будь ласка.'),
            ('Kupac', 'Izvolite karticu.', 'Ось картка.'),
            ('Blagajnik', 'Nažalost, kartica ne prolazi.', 'На жаль, картка не проходить.'),
            ('Kupac', 'Onda gotovinom.', 'Тоді готівкою.'),
            ('Blagajnik', 'Hvala. Izvolite račun.', 'Дякую. Ось чек.'),
        ]),
        build=('Складіть: «На жаль, картка не проходить.»', 'Nažalost, kartica ne prolazi.'),
        listen='Onda gotovinom.',
        speak=[('Готівкою чи карткою?', 'Gotovinom ili karticom?'), ('Тоді готівкою.', 'Onda gotovinom.')],
    ),
    25: dict(
        words=['stanica', 'centar', 'preko puta', 'tamo', 'ovdje'],
        scene=('На зупинці', 'Na stanici', [
            ('Turist', 'Oprostite, koji autobus ide do centra?', 'Вибачте, який автобус їде до центру?'),
            ('Gospođa', 'Broj šest.', 'Номер шість.'),
            ('Turist', 'Gdje je stanica?', 'Де зупинка?'),
            ('Gospođa', 'Tamo, preko puta.', 'Там, навпроти.'),
            ('Turist', 'Hvala Vam!', 'Дякую вам!'),
        ]),
        build=('Складіть: «Який автобус їде до центру?»', 'Koji autobus ide do centra?'),
        listen='Tamo, preko puta.',
        speak=[('Це далеко?', 'Je li daleko?'), ('Де зупинка?', 'Gdje je stanica?')],
    ),
    26: dict(
        words=['ulaznica', 'student', 'trg', 'ulica', 'otvoren'],
        scene=('У музеї', 'U muzeju', [
            ('Ana', 'Dvije ulaznice, molim.', 'Два квитки, будь ласка.'),
            ('Blagajnica', 'Šesnaest eura. Studenti imaju popust.', 'Шістнадцять євро. Студенти мають знижку.'),
            ('Ana', 'Nismo studenti.', 'Ми не студенти.'),
            ('Blagajnica', 'U redu. Muzej radi do šest.', 'Добре. Музей працює до шостої.'),
        ]),
        build=('Складіть: «Два квитки, будь ласка.»', 'Dvije ulaznice, molim.'),
        listen='Muzej radi do šest.',
        speak=[('Ходімо в музей!', 'Idemo u muzej!'), ('Два квитки, будь ласка.', 'Dvije ulaznice, molim.')],
    ),
    27: dict(
        words=['vlak', 'putovati', 'kolodvor', 'dolazak', 'sat'],
        scene=('У поїзді', 'U vlaku', [
            ('Kondukter', 'Karte, molim.', 'Квитки, будь ласка.'),
            ('Putnica', 'Izvolite.', 'Прошу.'),
            ('Kondukter', 'Hvala. Presjedate u Zagrebu.', 'Дякую. У вас пересадка в Загребі.'),
            ('Putnica', 'Koliko traje vožnja?', 'Скільки триває поїздка?'),
            ('Kondukter', 'Oko dva sata.', 'Близько двох годин.'),
        ]),
        build=('Складіть: «Скільки триває поїздка?»', 'Koliko traje vožnja?'),
        listen='Oko dva sata.',
        speak=[('Один квиток до Спліта, будь ласка.', 'Jednu kartu za Split, molim.'), ('Коли їде автобус?', 'Kada ide autobus?')],
    ),
    28: dict(
        words=['noć', 'slobodan', 'soba', 'recepcija', 'putovnica'],
        scene=('На рецепції', 'Na recepciji', [
            ('Oleg', 'Dobra večer. Imate li slobodnu sobu?', 'Добрий вечір. У вас є вільний номер?'),
            ('Recepcionar', 'Imamo. Za koliko noći?', 'Є. На скільки ночей?'),
            ('Oleg', 'Za dvije noći.', 'На дві ночі.'),
            ('Recepcionar', 'Može. Trebam Vašu putovnicu.', 'Можна. Мені потрібен ваш паспорт.'),
        ]),
        build=('Складіть: «У вас є вільний номер?»', 'Imate li slobodnu sobu?'),
        listen='Za dvije noći.',
        speak=[('Можете мені допомогти?', 'Možete li mi pomoći?'), ('Я заблукав.', 'Izgubio sam se.')],
    ),
    29: dict(
        words=['glava', 'temperatura', 'recept', 'ljekarna', 'liječnik'],
        scene=('У лікаря', 'Kod liječnice', [
            ('Liječnica', 'Što Vas boli?', 'Що у вас болить?'),
            ('Pacijent', 'Boli me glava.', 'У мене болить голова.'),
            ('Liječnica', 'Imate li temperaturu?', 'У вас є температура?'),
            ('Pacijent', 'Da, malo.', 'Так, трохи.'),
            ('Liječnica', 'Izvolite recept. Pijte puno vode.', 'Ось рецепт. Пийте багато води.'),
        ]),
        build=('Складіть: «У мене болить голова.»', 'Boli me glava.'),
        listen='Imate li temperaturu?',
        speak=[('Мені потрібна допомога.', 'Trebam pomoć.'), ('У мене болить голова.', 'Boli me glava.')],
    ),
    30: dict(
        words=['obrazac', 'zahtjev', 'datum rođenja', 'potpis', 'jezik'],
        scene=('В установі', 'U uredu', [
            ('Službenik', 'Sljedeći, molim!', 'Наступний, будь ласка!'),
            ('Oleg', 'Dobar dan. Gdje mogu predati zahtjev?', 'Добрий день. Де можна подати заяву?'),
            ('Službenik', 'Ovdje. Ispunite ovaj obrazac.', 'Тут. Заповніть цю форму.'),
            ('Oleg', 'Na kojem jeziku?', 'Якою мовою?'),
            ('Službenik', 'Na hrvatskom. Datum rođenja pišite ovdje.', 'Хорватською. Дату народження пишіть тут.'),
        ]),
        build=('Складіть: «Де можна подати заяву?»', 'Gdje mogu predati zahtjev?'),
        listen='Ispunite ovaj obrazac.',
        speak=[('Підпишіть тут, будь ласка.', 'Potpišite ovdje, molim.'), ('Якою мовою?', 'Na kojem jeziku?')],
    ),
}

# ----------------------------------------------------------------------------
# Виправлення перекладів опублікованих слів (їх видно в картках і у вправах v2).
# lemma → (старий переклад, новий). Застосовується, лише якщо в базі ще старий.
# ----------------------------------------------------------------------------
TRANSLATION_FIXES = {
    'skupo': ('дороге', 'дорого'),
    'jeftino': ('дешеве', 'дешево'),
    'vruće': ('гаряче', 'гаряче; спекотно'),
    'piće': ('напої', 'напій'),
}

# Слова, з яких не робимо вправ на слова: переклад має кілька далеких значень
# (da — «так» і «що»; molim — «прошу / будь ласка / що?»), учня це заплутає.
NO_VOCAB_EXERCISE = {'da', 'molim'}
