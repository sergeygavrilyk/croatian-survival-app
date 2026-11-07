"""
Письмо й переказ (§57, §58) у модулях A0.2–A0.5 · 2026-11-07 — по 2 вправи на урок (33 уроки).

Рішення власника 2026-11-07: «пілот підходить, додавай письмо й переказ у решту модулів A0 і A1».
Формат — як у пілоті (scripts/writing_pilot_20261105_data.py): пункт = (що має бути — українською, [ключі]);
ключ — основи слів, які всі мають бути в тексті (lib/writing.ts): основа збігається з початком слова,
«=» в кінці — ціле слово; хорватські ключі — без урахування діакритик.
Слова — переважно з уроку і попередніх уроків A0. Генератор: python3 -B scripts/gen_writing.py a0_m02_m05.
"""

DATE = '20261107'
TITLE = 'модулі A0.2–A0.5'
LEVELS = {'A0'}
MEDIATION_SITUATION = 'Друг не знає хорватської. Перекажіть йому українською головне.'

LESSONS = {
    # ------------------------------------------------------------------ A0.2 Ja sam…
    '2b6ed342-cc80-5bd9-baf0-b66109624d62': dict(
        title='A0 урок 5 Як тебе звати?', level='A0',
        write=dict(
            situation='Нова колега пише вам у робочий чат: «Bok, ja sam Ana. Kako se zoveš?» Відповідайте: привітайтеся, '
                      'назвіть своє ім’я і скажіть, що вам приємно познайомитися.',
            points=[('привітайтеся', [['bok'], ['zdravo'], ['dobar dan'], ['dobro jutro'], ['dobra večer']]),
                    ('назвіть своє ім’я', [['zovem se'], ['ja sam'], ['moje ime']]),
                    ('приємно познайомитися', [['drago'], ['milo mi']])],
            hints=['bok', 'zovem se', 'ja sam', 'drago mi je', 'i meni'],
            models=['Bok, Ana! Zovem se Olena. Drago mi je!', 'Bok! Ja sam Taras. Drago mi je, Ana.']),
        mediation=dict(
            source='Dobar dan! Zovem se Marija Horvat, ja sam vaša nova susjeda. Drago mi je!',
            friend='Хто це? Що вона сказала?',
            points=[('її звати Марія', [['марі']]),
                    ('вона нова сусідка', [['сусід']])],
            models=['Її звати Марія Горват, вона наша нова сусідка. Каже, що їй приємно познайомитися.'])),
    '8abb83d8-ec02-5921-ac9b-814489816fcd': dict(
        title='A0 урок 6 Я, ти, він: особові займенники', level='A0',
        write=dict(
            situation='Даша дивиться ваше фото з роботи й питає: «Tko je to?» Напишіть: це ви, це ваш колега, а це ваша колега '
                      '(назвіть їх на ім’я).',
            points=[('це ви', [['to sam ja'], ['ovo sam ja'], ['ja sam']]),
                    ('ваш колега', [['kolega'], ['on je']]),
                    ('ваша колега', [['kolegic'], ['ona je']])],
            hints=['to sam ja', 'on je', 'ona je', 'kolega', 'kolegica'],
            models=['To sam ja. On je kolega Ivan, a ona je kolegica Ana.',
                    'Ovo sam ja, ovo je kolega Marko, a ovo je kolegica Petra.']),
        mediation=dict(
            source='Mi smo novi susjedi. Ja sam Ivana, a on je Luka. Svi smo iz Splita.',
            friend='Хто вони такі?',
            points=[('нові сусіди', [['сусід']]),
                    ('Івана і Лука', [['іван', 'лук']]),
                    ('зі Спліта', [['спліт']])],
            models=['Це нові сусіди — Івана і Лука, вони зі Спліта.'])),
    '8f6439a9-c6ac-5271-99c8-1f0adc5d7599': dict(
        title='A0 урок 7 Питальні слова', level='A0',
        write=dict(
            situation='На роботі з’явилася нова колега. Напишіть Даші три короткі запитання про неї: хто вона, звідки вона '
                      'і як її звати.',
            points=[('хто вона', [['tko']]),
                    ('звідки вона', [['odakle']]),
                    ('як її звати', [['kako se zove'], ['ime']])],
            hints=['tko', 'odakle', 'kako se zove', 'je li'],
            models=['Tko je ona? Odakle je? Kako se zove?', 'Dašo, tko je nova kolegica? Kako se zove i odakle je?']),
        mediation=dict(
            source='Gdje si? Zašto ne odgovaraš? Kada dolaziš?',
            friend='Що пише Даша?',
            points=[('де ти', [['де='], ['куди']]),
                    ('чому не відповідаєш', [['чому']]),
                    ('коли прийдеш', [['коли']])],
            models=['Питає, де ти, чому не відповідаєш і коли прийдеш.'])),
    '04167753-db83-5163-a91c-9f71dac18ab5': dict(
        title='A0 урок 8 Звідки ви?', level='A0',
        write=dict(
            situation='На курсі мови вас просять коротко написати про себе: звідки ви, де живете зараз і відколи ви тут.',
            points=[('звідки ви', [['iz='], ['rodom']]),
                    ('де живете зараз', [['živim'], ['stanujem']]),
                    ('відколи ви тут', [['prije'], ['već'], ['presel']])],
            hints=['ja sam iz', 'rodom sam iz', 'sada živim u', 'prije godinu dana', 'već'],
            models=['Ja sam iz Ukrajine, iz Harkiva. Sada živim u Zagrebu. Preselila sam se prije godinu dana.',
                    'Rodom sam iz Odese. Sada živim u Splitu, ovdje sam već dvije godine.']),
        mediation=dict(
            source='Ja sam rodom iz Zadra, ali već deset godina živim u Zagrebu.',
            friend='Звідки вона?',
            points=[('родом із Задара', [['задар']]),
                    ('живе в Загребі', [['загреб']]),
                    ('уже 10 років', [['10'], ['десят']])],
            models=['Вона родом із Задара, але вже десять років живе в Загребі.'])),
    '479784bc-54ab-522d-9c77-55887ae68e33': dict(
        title='A0 урок 9 Країни й континенти', level='A0',
        write=dict(
            situation='Даша готує з донькою урок географії й просить допомогти. Напишіть хорватською: Хорватія — у Європі; '
                      'на півночі — Словенія й Угорщина; на сході — Сербія, Боснія і Герцеговина.',
            points=[('Хорватія в Європі', [['europ']]),
                    ('на півночі — Словенія й Угорщина', [['sloven', 'mađar']]),
                    ('на сході — Сербія, Боснія і Герцеговина', [['srbij', 'bosn']])],
            hints=['Hrvatska je u Europi', 'na sjeveru', 'na istoku', 'Slovenija', 'Mađarska', 'Srbija', 'Bosna i Hercegovina'],
            models=['Hrvatska je u Europi. Na sjeveru su Slovenija i Mađarska, a na istoku Srbija i Bosna i Hercegovina.']),
        mediation=dict(
            source='GRANICA SA SLOVENIJOM\n2 km',
            friend='Що на табличці біля дороги?',
            points=[('кордон зі Словенією', [['кордон', 'словені']]),
                    ('через 2 км', [['2'], ['два']])],
            models=['Через два кілометри — кордон зі Словенією.'])),
    'a9944193-2dfb-5944-b94c-41c41fdb7ca1': dict(
        title='A0 урок 10 Мови й національності', level='A0',
        write=dict(
            situation='Ви записуєтеся на курс хорватської. Напишіть викладачці: хто ви за національністю, яка ваша рідна мова '
                      'і що ви вчите хорватську.',
            points=[('хто ви за національністю', [['ukrajin']]),
                    ('рідна мова', [['materinsk']]),
                    ('вчите хорватську', [['uči', 'hrvatsk'], ['govor', 'hrvatsk']])],
            hints=['Ja sam Ukrajinka', 'Ja sam Ukrajinac', 'materinski jezik', 'učim hrvatski', 'još ne govorim tečno'],
            models=['Ja sam Ukrajinka. Moj materinski jezik je ukrajinski. Učim hrvatski, ali još ne govorim tečno.',
                    'Ja sam Ukrajinac, materinski jezik mi je ukrajinski. Hrvatski učim tek dva mjeseca.']),
        mediation=dict(
            source='Tečaj hrvatskog jezika za strance. Profesorica govori i ukrajinski!',
            friend='Що це за курс? А викладачка?',
            points=[('курс хорватської для іноземців', [['курс', 'хорват']]),
                    ('викладачка говорить українською', [['українськ']])],
            models=['Це курс хорватської мови для іноземців, і викладачка говорить українською!'])),
    'adf335ee-0cba-5c9a-b86a-8baac868edbc': dict(
        title='A0 урок 11 Де ви живете?', level='A0',
        write=dict(
            situation='Кур’єр не може знайти вашу квартиру. Напишіть йому адресу (вулиця й номер), поверх '
                      'і що написано на дзвонику або який вхід.',
            points=[('вулиця й номер', [['ulic'], ['adres']]),
                    ('поверх', [['kat'], ['prizemlj']]),
                    ('дзвоник або вхід', [['zvon'], ['ulaz']])],
            hints=['moja adresa je', 'ulica', 'kućni broj', 'kat', 'ulaz', 'zvono'],
            models=['Adresa: Ilica 25, 3. kat, ulaz B. Na zvonu piše Kovalenko.',
                    'Živim u Ulici kralja Tomislava 8, na drugom katu. Zvono je Petrenko.']),
        mediation=dict(
            source='Lift danas ne radi. Molimo, koristite ulaz B.',
            friend='Що написано в під’їзді?',
            points=[('ліфт не працює', [['ліфт', 'не працю'], ['ліфт', 'злам']]),
                    ('заходити через вхід B', [['вхід'], ['b=']])],
            models=['Сьогодні ліфт не працює, просять заходити через вхід B.'])),
    '2fa5fa38-9641-5dc5-9156-6a3f7fe8035b': dict(
        title='A0 урок 12 Ким ви працюєте?', level='A0',
        write=dict(
            situation='Ви заповнюєте анкету в бюро з працевлаштування (HZZ). Напишіть: ким ви за професією, '
                      'чи працюєте зараз і який у вас досвід.',
            points=[('ким ви за професією', [['po zanimanju'], ['zanimanje'], ['radim kao']]),
                    ('чи працюєте зараз', [['radim'], ['nezaposlen']]),
                    ('досвід', [['iskustv']])],
            hints=['po zanimanju sam', 'radim kao', 'nezaposlen / nezaposlena', 'iskustvo', 'tvrtka'],
            models=['Po zanimanju sam medicinska sestra. Sada sam nezaposlena, ali imam deset godina iskustva.',
                    'Po zanimanju sam programer. Radim u jednoj tvrtki, imam pet godina iskustva.']),
        mediation=dict(
            source='Tražimo konobara ili konobaricu. Iskustvo nije potrebno.',
            friend='Що за оголошення на дверях кафе?',
            points=[('шукають офіціанта або офіціантку', [['офіціант']]),
                    ('досвід не потрібен', [['досвід', 'не='], ['без досвід']])],
            models=['Шукають офіціанта або офіціантку, досвід не потрібен.'])),
    '3b51b1bf-47f4-5709-96d9-c518d36440e6': dict(
        title='A0 урок 13 Як ви почуваєтеся?', level='A0',
        write=dict(
            situation='Колега питає в чаті, чому вас сьогодні немає на роботі. Напишіть: вам погано, болить голова, '
                      'ви сьогодні вдома.',
            points=[('вам погано / ви хворі', [['loše'], ['boles'], ['nije mi dobro']]),
                    ('болить голова', [['glav']]),
                    ('ви вдома', [['kod kuće'], ['doma'], ['kući']])],
            hints=['loše mi je', 'boli me glava', 'bolestan / bolesna', 'kod kuće sam', 'bolje'],
            models=['Loše mi je i boli me glava. Danas sam kod kuće.', 'Bolesna sam, boli me glava. Ostajem doma.']),
        mediation=dict(
            source='Dašo, jako mi nedostaješ. Ovdje mi je dosadno i usamljena sam.',
            friend='Що пише Дашина подруга?',
            points=[('дуже сумує за Дашею', [['сум'], ['скуча']]),
                    ('їй нудно й самотньо', [['нудн'], ['самотн']])],
            models=['Пише, що дуже сумує за Дашею, їй там нудно й самотньо.'])),

    # ------------------------------------------------------------------ A0.3 Brojevi
    'c0941bd8-57b5-5e7e-981f-9be423f24208': dict(
        title='A0 урок 14 Числа від 0 до 10', level='A0',
        write=dict(
            situation='Даша питає код від вхідних дверей. Напишіть його хорватською словами: 4 – 0 – 9 – 2.',
            points=[('4', [['četiri']]), ('0', [['nula']]), ('9', [['devet']]), ('2', [['dva']])],
            hints=['četiri', 'nula', 'devet', 'dva', 'broj'],
            models=['Kod je četiri, nula, devet, dva.']),
        mediation=dict(
            source='Uzmite broj i čekajte. Vaš broj je sedam.',
            friend='Що треба робити?',
            points=[('взяти номерок і чекати', [['номер']]),
                    ('наш номер — 7', [['7'], ['сім']])],
            models=['Треба взяти номерок і чекати. Наш номер — сім.'])),
    'e30c65f2-1a30-5b51-85e7-6a460cd1799f': dict(
        title='A0 урок 15 Числа від 11 до 20', level='A0',
        write=dict(
            situation='Ви бронюєте стіл у ресторані на день народження. Напишіть: привітайтеся, скажіть, що вас буде дванадцять осіб, '
                      'і спитайте, чи є вільний стіл.',
            points=[('привітайтеся', [['dobar dan'], ['dobra večer'], ['bok'], ['pozdrav']]),
                    ('нас дванадцять осіб', [['dvanaest']]),
                    ('чи є вільний стіл', [['imate li'], ['ima li'], ['slobod']])],
            hints=['nas je', 'dvanaest', 'osoba', 'ukupno', 'imate li'],
            models=['Dobar dan! Nas je dvanaest osoba. Imate li slobodan stol?']),
        mediation=dict(
            source='Lift: najviše 13 osoba ili 1000 kg.',
            friend='Скільки людей можна в ліфт?',
            points=[('не більше 13 людей', [['13'], ['тринадцят']]),
                    ('або 1000 кг', [['1000'], ['тисяч']])],
            models=['Не більше 13 людей або 1000 кг.'])),
    'ffb92726-2fb1-5070-bf5c-5d2fb3b9393a': dict(
        title='A0 урок 16 Десятки й номер телефону', level='A0',
        write=dict(
            situation='Майстер просить ваш номер телефону. Напишіть хорватською: «Мій номер телефону…» '
                      'і продиктуйте словами: 091 – 45 – 63 – 80.',
            points=[('мій номер телефону', [['broj']]),
                    ('45', [['četrdeset pet']]),
                    ('63', [['šezdeset tri']]),
                    ('80', [['osamdeset']])],
            hints=['broj telefona', 'nula devedeset jedan', 'četrdeset', 'šezdeset', 'osamdeset'],
            models=['Moj broj telefona je nula devedeset jedan, četrdeset pet, šezdeset tri, osamdeset.']),
        mediation=dict(
            source='Nazvali ste krivi broj. Molimo, ponovite poziv.',
            friend='Що каже автовідповідач?',
            points=[('неправильний номер', [['неправильн'], ['не той номер'], ['хибн']]),
                    ('подзвонити ще раз', [['ще раз'], ['повтор'], ['знову']])],
            models=['Ви набрали неправильний номер, просять подзвонити ще раз.'])),
    'c0d7b467-acb2-581a-975b-497e63f45aa7': dict(
        title='A0 урок 17 Сотні: від 100 до 1000', level='A0',
        write=dict(
            situation='Друг питає, далеко чи ні їхати з Загреба. Напишіть: до Спліта — чотириста кілометрів, '
                      'а до Задара — двісті вісімдесят.',
            points=[('до Спліта — 400', [['četiristo']]),
                    ('до Задара — 280', [['dvjesto osamdeset']]),
                    ('кілометрів', [['kilomet']])],
            hints=['od Zagreba do Splita', 'četiristo', 'dvjesto osamdeset', 'kilometara'],
            models=['Od Zagreba do Splita je četiristo kilometara, a do Zadra dvjesto osamdeset.']),
        mediation=dict(
            source='Plaža 300 m\nParkiralište 500 m',
            friend='Що на вказівнику?',
            points=[('до пляжу 300 м', [['300', 'пляж'], ['триста', 'пляж']]),
                    ('парковка — 500 м', [['500', 'парк'], ["п'ятсот", 'парк']])],
            models=['До пляжу 300 метрів, а парковка — за 500 метрів.'])),
    '1f41cb75-1ce5-57ba-a56f-58561ee1d983': dict(
        title='A0 урок 18 Тисячі, мільйони, мільярди', level='A0',
        write=dict(
            situation='Для уроку Дашиної доньки напишіть: у Хорватії майже чотири мільйони жителів, '
                      'а в Загребі — майже вісімсот тисяч.',
            points=[('майже 4 мільйони в Хорватії', [['četiri milijun']]),
                    ('Загреб — майже 800 тисяч', [['osamsto tisuć']]),
                    ('жителів', [['stanovni']])],
            hints=['gotovo', 'četiri milijuna', 'osamsto tisuća', 'stanovnika'],
            models=['Hrvatska ima gotovo četiri milijuna stanovnika, a Zagreb gotovo osamsto tisuća.']),
        mediation=dict(
            source='Plaća: 1500 eura mjesečno, neto.',
            friend='Скільки там платять?',
            points=[('1500 євро', [['1500'], ['тисяч', "п'ятсот"]]),
                    ('на місяць', [['місяц'], ['щомісяч']])],
            models=['Зарплата 1500 євро на місяць, чистими.'])),
    '40f7c64a-ad42-5fe2-a230-7b1e98607112': dict(
        title='A0 урок 19 Перший, другий, третій', level='A0',
        write=dict(
            situation='Ви стоїте в черзі в банку. Напишіть Даші: ви п’яті в черзі, перед вами ще чотири людини.',
            points=[('ви п’яті', [['peta='], ['peti=']]),
                    ('у черзі', [['red']]),
                    ('ще чотири людини', [['četiri']])],
            hints=['ja sam peta / peti', 'u redu', 'ispred mene', 'još četiri osobe'],
            models=['Ja sam peta u redu, ispred mene su još četiri osobe.',
                    'Ja sam peti u redu. Ispred mene su još četiri osobe.']),
        mediation=dict(
            source='Ured je na prvom katu, soba 3. Prvo uzmite broj.',
            friend='Куди нам іти?',
            points=[('перший поверх', [['перш', 'повер']]),
                    ('кімната 3', [['3'], ['трет']]),
                    ('спершу взяти номерок', [['номер']])],
            models=['Офіс на першому поверсі, кімната 3. Спершу треба взяти номерок.'])),
    'ba35964d-f0d8-5d15-9566-ef44d37e6d12': dict(
        title='A0 урок 20 Рахуємо: плюс, мінус, помножити', level='A0',
        write=dict(
            situation='Ви допомагаєте Дашиній доньці з математикою. Напишіть хорватською словами: 7 + 5 = 12 і 20 − 8 = 12.',
            points=[('7 + 5', [['sedam plus pet']]),
                    ('20 − 8', [['dvadeset minus osam']]),
                    ('= 12', [['jednako dvanaest'], ['je dvanaest']])],
            hints=['plus', 'minus', 'jednako', 'dvanaest'],
            models=['Sedam plus pet jednako je dvanaest. Dvadeset minus osam je dvanaest.']),
        mediation=dict(
            source='Ana ima deset jabuka. Tri daje prijateljici. Koliko jabuka joj ostaje?',
            friend='Що в задачі? Я не розумію.',
            points=[('в Ані 10 яблук', [['10', 'яблук'], ['десят', 'яблук']]),
                    ('3 віддає подрузі', [['3'], ['три']]),
                    ('скільки залишилося', [['скільки', 'залиш']])],
            models=['В Ані десять яблук, три вона віддає подрузі. Скільки яблук у неї залишається?'])),
    '22dd7878-4fa8-5e1c-909e-71c70ffd9918': dict(
        title='A0 урок 21 Приблизно, половина, відсотки', level='A0',
        write=dict(
            situation='Даша питає про вашу групу на курсі. Напишіть: у групі приблизно двадцять людей, половина — з України.',
            points=[('приблизно 20', [['dvadesetak'], ['otprilike dvadeset']]),
                    ('половина', [['pola'], ['polovic']]),
                    ('з України', [['ukrajin']])],
            hints=['dvadesetak', 'otprilike', 'pola', 'iz Ukrajine'],
            models=['U grupi je dvadesetak ljudi, a pola ih je iz Ukrajine.']),
        mediation=dict(
            source='SNIŽENJE 30 % NA SVE!\nSamo ovaj vikend.',
            friend='Що там за знижки?',
            points=[('знижка 30 %', [['30']]),
                    ('на все', [['все'], ['усе']]),
                    ('лише ці вихідні', [['вихідн']])],
            models=['Знижка 30 % на все, тільки ці вихідні.'])),
    '4c5db9c0-aa58-55c5-b647-7f7cfc8396c2': dict(
        title='A0 урок 22 Скільки вам років?', level='A0',
        write=dict(
            situation='Напишіть Даші двома реченнями: скільки вам років і хто з ваших рідних старший або молодший за вас.',
            points=[('скільки вам років', [['imam', 'godin']]),
                    ('хтось старший або молодший', [['mlađ'], ['stariji'], ['starija']])],
            hints=['imam … godina', 'stariji / starija', 'mlađi / mlađa', 'rođendan'],
            models=['Imam trideset četiri godine. Moja sestra je mlađa, ona ima trideset godina.']),
        mediation=dict(
            source='Ulaz u klub: samo punoljetne osobe (18+).',
            friend='Нас пустять із сином? Йому шістнадцять.',
            points=[('лише повнолітні', [['повнолітн'], ['18']]),
                    ('сину не можна', [['не можна'], ['не пустять'], ['ні=']])],
            models=['Ні, тільки повнолітнім, від 18 років. Сину ще не можна.'])),
    '427e5058-7381-58a0-8f21-bd170866dbae': dict(
        title='A0 урок 23 Скільки це коштує?', level='A0',
        write=dict(
            situation='Ви продаєте дитячий велосипед через оголошення. Покупець питає ціну. Напишіть, скільки він коштує '
                      '(у євро) і що це недорого.',
            points=[('скільки коштує', [['košta'], ['cijen']]),
                    ('у євро', [['eur']]),
                    ('це недорого', [['jeftin'], ['nije skup']])],
            hints=['košta', 'cijena je', 'eura', 'jeftino', 'nije skupo'],
            models=['Bicikl košta četrdeset pet eura. To je jeftino!', 'Cijena je četrdeset eura, nije skupo.']),
        mediation=dict(
            source='Ulaz u muzej: odrasli 10 €, djeca besplatno.',
            friend='Скільки коштує вхід? А для дітей?',
            points=[('дорослі — 10 €', [['10'], ['десят']]),
                    ('діти — безкоштовно', [['безкоштовн'], ['безплатн']])],
            models=['Дорослим 10 євро, а діти — безкоштовно.'])),

    # ------------------------------------------------------------------ A0.4 Vrijeme
    '8e372ece-ae10-50ae-9cf3-07b52ef2f72d': dict(
        title='A0 урок 24 Дні тижня', level='A0',
        write=dict(
            situation='Колега хоче зустрітися. Напишіть: у понеділок і вівторок ви зайняті, а в середу вільні.',
            points=[('пн і вт ви зайняті', [['ponedjelj', 'zauzet'], ['utor', 'zauzet']]),
                    ('у середу ви вільні', [['srijed', 'slobod']])],
            hints=['u ponedjeljak', 'u utorak', 'u srijedu', 'zauzet / zauzeta', 'slobodan / slobodna'],
            models=['U ponedjeljak i utorak sam zauzeta, a u srijedu sam slobodna.']),
        mediation=dict(
            source='Ordinacija ne radi petkom.\nRadno vrijeme: ponedjeljak – četvrtak.',
            friend='Коли працює кабінет лікаря?',
            points=[('з понеділка до четверга', [['понеділ', 'четвер']]),
                    ('у п’ятницю не працює', [["п'ятниц"]])],
            models=['З понеділка до четверга, а в п’ятницю не працює.'])),
    '238d9508-3c2e-5ee6-910f-0ae8863c2dc7': dict(
        title='A0 урок 25 Учора, сьогодні, завтра', level='A0',
        write=dict(
            situation='Даша кличе вас сьогодні ввечері в кіно. Напишіть: сьогодні ввечері ви не можете, а завтра вранці — можете.',
            points=[('сьогодні ввечері', [['večeras'], ['danas navečer'], ['danas uvečer']]),
                    ('не можете', [['ne mogu']]),
                    ('завтра вранці', [['sutra ujutro'], ['sutra prijepodne']])],
            hints=['večeras', 'ne mogu', 'sutra ujutro', 'kasnije'],
            models=['Večeras ne mogu, ali sutra ujutro mogu.', 'Dašo, danas navečer ne mogu. Može sutra prijepodne?']),
        mediation=dict(
            source='Paket stiže prekosutra prijepodne.',
            friend='Коли привезуть посилку?',
            points=[('післязавтра', [['післязавтра']]),
                    ('до обіду', [['до обід'], ['зранку'], ['вранці'], ['першій половині']])],
            models=['Післязавтра, у першій половині дня.'])),
    '39b1e31f-b573-5000-9713-1660688c3cc9': dict(
        title='A0 урок 26 Котра година?', level='A0',
        write=dict(
            situation='Напишіть Даші, що потяг запізнюється: він приходить не о восьмій, а о пів на дев’яту.',
            points=[('потяг запізнюється', [['kasni'], ['kašnjenj']]),
                    ('о пів на дев’яту', [['osam i pol'], ['pola devet']])],
            hints=['vlak kasni', 'dolazi', 'u osam i pol', 'kašnjenje'],
            models=['Vlak kasni. Dolazi u osam i pol.']),
        mediation=dict(
            source='Radno vrijeme: pon – pet 8 – 16 h, sub 8 – 12 h.\nPauza: 12 – 12:30 h.',
            friend='Коли вони працюють?',
            points=[('у будні 8–16', [['8', '16'], ['восьм', 'четвер']]),
                    ('у суботу до 12', [['субот']]),
                    ('перерва 12–12:30', [['перерв']])],
            models=['У будні з 8 до 16, у суботу з 8 до 12. Перерва з 12:00 до 12:30.'])),
    '036fc4fb-1bf2-5100-9fd0-6f6a612554a1': dict(
        title='A0 урок 27 Місяці й пори року', level='A0',
        write=dict(
            situation='Колега питає про вашу відпустку. Напишіть: відпустка у вас у серпні, а взимку ви їдете в Україну.',
            points=[('відпустка в серпні', [['odmor', 'kolovoz']]),
                    ('взимку — в Україну', [['zimi', 'ukrajin']])],
            hints=['godišnji odmor', 'u kolovozu', 'zimi', 'idem u Ukrajinu'],
            models=['Imam godišnji odmor u kolovozu. Zimi idem u Ukrajinu.']),
        mediation=dict(
            source='Bazen je otvoren od lipnja do rujna.',
            friend='Коли працює басейн?',
            points=[('з червня', [['червн']]), ('до вересня', [['вересн']])],
            models=['Басейн відкритий з червня до вересня.'])),
    'b36b4550-ff36-50cb-89fb-8246b351c8d6': dict(
        title='A0 урок 28 Яке сьогодні число?', level='A0',
        write=dict(
            situation='Напишіть у MUP: ваш дозвіл на перебування дійсний до 4 березня, і ви хочете його продовжити.',
            points=[('дозвіл на перебування', [['boravišn']]),
                    ('дійсний до…', [['vrijedi do'], ['istje'], ['ističe']]),
                    ('хочете продовжити', [['produž']])],
            hints=['boravišna dozvola', 'vrijedi do', 'četvrtog ožujka', 'produžiti'],
            models=['Moja boravišna dozvola vrijedi do četvrtog ožujka. Želim je produžiti.',
                    'Boravišna dozvola mi istječe 4. ožujka i trebam je produžiti.']),
        mediation=dict(
            source='Rok trajanja: 15. 11. 2026.\nČuvati u hladnjaku.',
            friend='До якого числа можна їсти цей йогурт?',
            points=[('до 15 листопада', [['15']]),
                    ('зберігати в холодильнику', [['холодильник']])],
            models=['До 15 листопада 2026 року. І треба зберігати в холодильнику.'])),
    'efcf49e0-c058-5986-9cf7-aee921887a81': dict(
        title='A0 урок 29 Яка сьогодні погода?', level='A0',
        write=dict(
            situation='Даша хоче сьогодні на пляж. Напишіть їй: сьогодні холодно й дме бура, а завтра буде сонячно.',
            points=[('холодно', [['hladno']]),
                    ('дме бура', [['bura']]),
                    ('завтра сонячно', [['sutra', 'sunčan']])],
            hints=['hladno je', 'puše bura', 'sutra', 'bit će sunčano'],
            models=['Danas je hladno i puše bura. Sutra će biti sunčano.']),
        mediation=dict(
            source='Prognoza za sutra: kiša i jak vjetar, oko 12 stupnjeva.',
            friend='Яка завтра погода?',
            points=[('дощ', [['дощ']]), ('сильний вітер', [['вітер']]), ('близько 12 градусів', [['12']])],
            models=['Завтра дощ і сильний вітер, близько 12 градусів.'])),
    'd7cf3059-0d92-5215-8ef4-ad699e317b10': dict(
        title='A0 урок 30 Свята й привітання', level='A0',
        write=dict(
            situation='Напишіть хорватській сусідці листівку: привітайте з Різдвом і Новим роком, побажайте всього найкращого.',
            points=[('з Різдвом', [['božić']]),
                    ('з Новим роком', [['nov', 'godin']]),
                    ('всього найкращого', [['najbolj']])],
            hints=['sretan Božić', 'sretna Nova godina', 'sve najbolje', 'želim vam'],
            models=['Sretan Božić i sretna Nova godina! Sve najbolje!',
                    'Draga susjedo, sretan Božić! Želim vam sve najbolje u Novoj godini.']),
        mediation=dict(
            source='25. i 26. prosinca zatvoreno.\nSretni blagdani!',
            friend='Вони працюють на свята?',
            points=[('25 і 26 грудня зачинено', [['зачин'], ['не працю']]),
                    ('вітають зі святами', [['свят']])],
            models=['Ні, 25 і 26 грудня зачинено. Вітають усіх зі святами.'])),

    # ------------------------------------------------------------------ A0.5 Obitelj
    '4e003796-1ce0-5a02-8a2d-59a0de38f3dd': dict(
        title='A0 урок 31 Моя сім’я', level='A0',
        write=dict(
            situation='Напишіть новій колезі коротко про свою сім’ю: хто у вас є і де ці люди живуть.',
            points=[('хто у вас є', [['muž'], ['suprug'], ['sin'], ['kći'], ['kćer'], ['mam'], ['tat'], ['brat'], ['sestr'],
                                     ['roditelj'], ['djec'], ['dijete'], ['bak'], ['djed']]),
                    ('де вони живуть', [['živ']])],
            hints=['imam', 'muž', 'sin', 'kći', 'roditelji', 'žive u'],
            models=['Imam muža i sina. Moja mama i tata žive u Ukrajini.']),
        mediation=dict(
            source='Ovo je moja obitelj: baka, djed, mama i ja. Ja sam jedinica.',
            friend='Що вона розповідає?',
            points=[('бабуся, дідусь і мама', [['бабус', 'дід']]),
                    ('вона єдина дитина', [['єдин'], ['одна дитин'], ['без брат']])],
            models=['Це її сім’я: бабуся, дідусь і мама. Вона єдина дитина в сім’ї.'])),
    '18efed0f-53a5-5717-9c4e-319627da2360': dict(
        title='A0 урок 32 Чиє це?', level='A0',
        write=dict(
            situation='На спільній кухні гуртожитку хтось бере ваші речі. Напишіть записку: це ваші речі, вони не спільні, '
                      'будь ласка, не беріть їх.',
            points=[('це ваші речі', [['moj']]),
                    ('вони не спільні', [['nisu zajedničk'], ['nije zajedničk'], ['nisu vaš'], ['nije vaš'], ['nije tvoj']]),
                    ('не беріть', [['ne uzim'], ['nemoj']])],
            hints=['moje stvari', 'nisu zajedničke', 'ne uzimajte', 'molim'],
            models=['Ovo su moje stvari, nisu zajedničke. Molim, ne uzimajte ih.']),
        mediation=dict(
            source='Čiji je ovo kišobran? Stoji u uredu od ponedjeljka.',
            friend='Що за оголошення?',
            points=[('чия це парасолька', [['чия', 'парасол'], ['чий', 'парасол']]),
                    ('вона в офісі', [['офіс']])],
            models=['Питають, чия це парасолька — вона в офісі з понеділка.'])),
    'f9ca38e4-3a61-56a6-b5f5-060933516c9a': dict(
        title='A0 урок 33 Шлюб і стосунки', level='A0',
        write=dict(
            situation='В анкеті треба написати сімейний стан. Напишіть: ви заміжня / одружений (або інакше) '
                      'і як звати чоловіка, дружину чи партнера.',
            points=[('сімейний стан', [['udan'], ['oženjen'], ['razveden'], ['samac'], ['zaručen'], ['udovic']]),
                    ('чоловік, дружина чи партнер', [['muž'], ['suprug'], ['partner'], ['dečk'], ['cur'], ['zaručni']]),
                    ('як звати', [['zove'], ['ime']])],
            hints=['udana sam', 'oženjen sam', 'muž', 'supruga', 'zove se'],
            models=['Udana sam. Moj muž se zove Andrij.', 'Oženjen sam, supruga mi se zove Irina.']),
        mediation=dict(
            source='Ana i Marko se vjenčavaju 12. lipnja! Pozivamo vas na proslavu.',
            friend='Що це за запрошення?',
            points=[('Ана і Марко одружуються', [['одруж'], ['весілл']]),
                    ('12 червня', [['12'], ['червн']]),
                    ('запрошують на святкування', [['запрош']])],
            models=['Ана і Марко одружуються 12 червня й запрошують нас на святкування.'])),
    'cec08ff0-a97d-5847-88cc-dee22fed2f8c': dict(
        title='A0 урок 34 Родичі', level='A0',
        write=dict(
            situation='Поясніть хорватській колезі, хто приїжджає до вас у гості: ваша свекруха (або теща) і двоюрідна сестра.',
            points=[('свекруха або теща', [['svekrv'], ['punic']]),
                    ('двоюрідна сестра', [['sestričn'], ['rođakinj']]),
                    ('приїжджають', [['dolaz'], ['stiž'], ['u posjet']])],
            hints=['svekrva', 'punica', 'sestrična', 'rođakinja', 'dolaze'],
            models=['U subotu dolaze moja svekrva i sestrična.', 'Dolazi mi punica, a s njom i rođakinja iz Kijeva.']),
        mediation=dict(
            source='Sutra je rođendan mog nećaka. Dolazi cijela rodbina.',
            friend='Що в неї завтра?',
            points=[('день народження племінника', [['племінник']]),
                    ('прийде вся рідня', [['рідн'], ['родич']])],
            models=['Завтра день народження її племінника, прийде вся рідня.'])),
    '2b0e9742-99e1-57e1-a574-67ffb78d2607': dict(
        title='A0 урок 35 Діти й друзі', level='A0',
        write=dict(
            situation='Напишіть мамі однокласника вашої дитини: запросіть її сина на день народження в суботу о 15:00 '
                      'на дитячий майданчик біля школи.',
            points=[('запросіть', [['poziv'], ['pozv'], ['dođi'], ['dođe']]),
                    ('на день народження', [['rođendan']]),
                    ('коли', [['subot'], ['petnaest'], ['15']]),
                    ('де', [['igrališt'], ['škol']])],
            hints=['pozivamo', 'na rođendan', 'u subotu', 'igralište', 'kod škole'],
            models=['Pozivamo vašeg sina na rođendan u subotu u 15 sati, na igralište kod škole.']),
        mediation=dict(
            source='Dragi roditelji, vrtić je u petak zatvoren. Djeca ostaju kod kuće.',
            friend='Що пишуть із садочка?',
            points=[('у п’ятницю садок зачинений', [["п'ятниц"]]),
                    ('діти лишаються вдома', [['вдома'], ['дома']])],
            models=['У п’ятницю садочок зачинений, діти залишаються вдома.'])),
    '60130364-d731-5f5a-8b12-ac4d8d6d92e9': dict(
        title='A0 урок 36 Зовнішність і характер', level='A0',
        write=dict(
            situation='Ви зустрічаєте Дашину подругу на вокзалі, але вона вас ніколи не бачила. Напишіть, як ви виглядаєте: '
                      'зріст і волосся.',
            points=[('зріст', [['visok'], ['nizak'], ['nisk']]),
                    ('волосся', [['kos']]),
                    ('колір чи вигляд волосся', [['plav'], ['smeđ'], ['crn'], ['sijed'], ['kovrčav'], ['dug'], ['kratk']])],
            hints=['visok / visoka', 'nizak / niska', 'imam … kosu', 'plavu', 'smeđu', 'kovrčavu'],
            models=['Visoka sam i imam dugu plavu kosu.', 'Nizak sam, imam kratku smeđu kosu i bradu.']),
        mediation=dict(
            source='Tražimo dadilju: strpljivu, vrijednu i veselu, s iskustvom rada s djecom.',
            friend='Яку няню вони шукають?',
            points=[('терплячу', [['терпляч']]),
                    ('працьовиту', [['працьовит'], ['старанн']]),
                    ('з досвідом роботи з дітьми', [['досвід']])],
            models=['Шукають терплячу, працьовиту й веселу няню з досвідом роботи з дітьми.'])),
    '40b9da1d-1686-5b78-8317-0439067d5f8e': dict(
        title='A0 урок 37 Домашні тварини', level='A0',
        write=dict(
            situation='Ви їдете на вихідні. Ввічливо попросіть сусідку погодувати вашу кішку в суботу й неділю.',
            points=[('ввічливо попросіть', [['molim'], ['možete li'], ['možeš li']]),
                    ('погодувати', [['hran']]),
                    ('кішку', [['mačk'], ['mačak'], ['mače']]),
                    ('у суботу й неділю', [['subot'], ['nedjelj'], ['vikend']])],
            hints=['možete li', 'hraniti', 'moju mačku', 'u subotu i nedjelju', 'hvala'],
            models=['Možete li, molim vas, hraniti moju mačku u subotu i nedjelju? Hvala!']),
        mediation=dict(
            source='Psi samo na povodcu! Molimo, čistite za svojim ljubimcem.',
            friend='Що написано на табличці в парку?',
            points=[('собак — лише на повідку', [['повід']]),
                    ('прибирати за твариною', [['прибира']])],
            models=['Собак можна лише на повідку, і треба прибирати за своєю твариною.'])),
}
