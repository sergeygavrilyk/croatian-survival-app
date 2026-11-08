"""
Письмо й переказ (§57, §58) у модулях A0.6–A0.10 · 2026-11-07 — по 2 вправи на урок (29 уроків).

Рішення власника 2026-11-07: «пілот підходить, додавай письмо й переказ у решту модулів A0 і A1».
Формат — як у пілоті й партії A0.2–A0.5 (scripts/writing_data_a0_m02_m05.py). Генератор: python3 -B scripts/gen_writing.py a0_m06_m10.
"""

DATE = '20261107'
TITLE = 'модулі A0.6–A0.10'
LEVELS = {'A0'}
MEDIATION_SITUATION = 'Друг не знає хорватської. Перекажіть йому українською головне.'

LESSONS = {
    # ------------------------------------------------------------------ A0.6 Moj dom
    '78f28f85-dd8b-5e81-8a52-1b2dbce4eb34': dict(
        title='A0 урок 38 Моя квартира', level='A0',
        write=dict(
            situation='Ви шукаєте житло. Напишіть власнику за оголошенням: вас цікавить квартира, спитайте, скільки коштує оренда '
                      'і чи потрібна застава.',
            points=[('вас цікавить квартира', [['stan'], ['oglas']]),
                    ('скільки коштує оренда', [['najamnin'], ['najam'], ['koliko košta']]),
                    ('чи потрібна застава', [['kaucij']])],
            hints=['zanima me stan', 'oglas', 'najamnina', 'kaucija', 'je li namješten?'],
            models=['Dobar dan, zanima me stan iz oglasa. Kolika je najamnina i trebam li platiti kauciju?',
                    'Poštovani, javljam se na oglas za dvosoban stan. Koliko košta najam? Je li potrebna kaucija?']),
        mediation=dict(
            source='Iznajmljujem namješten dvosoban stan, 55 m², 600 € + režije.\nKaucija: jedna najamnina.',
            friend='Що за квартира? Скільки коштує?',
            points=[('двокімнатна', [['двокімнатн'], ['дві кімнат']]),
                    ('600 € + комунальні', [['600']]),
                    ('застава — одна місячна оплата', [['застав']])],
            models=['Здають мебльовану двокімнатну квартиру, 55 м², 600 євро плюс комунальні. Застава — одна місячна оплата.'])),
    '1436c20e-0aea-550a-b66d-fb3149a1c2e2': dict(
        title='A0 урок 39 Що є в кімнаті?', level='A0',
        write=dict(
            situation='Після переїзду ви продаєте меблі. Напишіть оголошення: продаєте ліжко, шафу й письмовий стіл.',
            points=[('продаєте', [['prodaj']]), ('ліжко', [['krevet']]), ('шафа', [['ormar']]), ('письмовий стіл', [['stol']])],
            hints=['prodajem', 'krevet', 'ormar', 'radni stol', 'jeftino'],
            models=['Prodajem krevet, ormar i radni stol. Jeftino!']),
        mediation=dict(
            source='U sobi su krevet, ormar i stol. Plahte i jastuci nisu uključeni.',
            friend='Що є в кімнаті? Постіль дадуть?',
            points=[('ліжко, шафа і стіл', [['ліжк', 'шаф']]),
                    ('простирадла й подушки не входять', [['не вход'], ['не включ'], ['свої']])],
            models=['У кімнаті є ліжко, шафа і стіл. Простирадла й подушки не входять — треба свої.'])),
    '32f5d97b-d6c0-57af-9e48-86f9ee9a932d': dict(
        title='A0 урок 40 Де це? Прийменники місця', level='A0',
        write=dict(
            situation='Ви залишили Даші подарунок у квартирі. Напишіть, де що лежить: пакет — на столі біля вікна, '
                      'а листівка — під лампою.',
            points=[('на столі', [['na stol']]),
                    ('біля вікна', [['pored prozor'], ['pokraj prozor'], ['uz prozor'], ['kod prozor']]),
                    ('під лампою', [['ispod lamp'], ['pod lamp']])],
            hints=['na stolu', 'pored prozora', 'ispod lampe', 'iza vrata', 'u kutu'],
            models=['Paket je na stolu pored prozora, a čestitka je ispod lampe.']),
        mediation=dict(
            source='Ključ je ispod tepiha ispred vrata, a pošta je na stolu u hodniku.',
            friend='Де ключ?',
            points=[('під килимом перед дверима', [['під килим']]),
                    ('пошта на столі в коридорі', [['пошт', 'стол']])],
            models=['Ключ під килимом перед дверима, а пошта — на столі в коридорі.'])),
    '0ecb6f19-2630-533d-9f1b-85102442af08': dict(
        title='A0 урок 41 Де мої ключі?', level='A0',
        write=dict(
            situation='Ви були в гостях у Даші й тепер не можете знайти окуляри. Напишіть їй: не можете знайти окуляри, '
                      'може, вони в неї?',
            points=[('не можете знайти', [['ne mogu', 'nać'], ['ne mogu', 'pronać'], ['izgub']]),
                    ('окуляри', [['naočal']]),
                    ('може, вони в неї', [['kod tebe'], ['jesu li'], ['možda']])],
            hints=['ne mogu naći', 'naočale', 'jesu li kod tebe?', 'možda', 'na stolu', 'u torbi'],
            models=['Ne mogu naći naočale. Jesu li možda kod tebe, na stolu ili u torbi?']),
        mediation=dict(
            source='Ostavila sam ti ključ kod susjede. Ne zaboravi zaključati vrata!',
            friend='Що пише сусідка по квартирі?',
            points=[('ключ у сусідки', [['ключ', 'сусід']]),
                    ('не забути замкнути двері', [['замкн'], ['закри']])],
            models=['Вона залишила ключ у сусідки і просить не забути замкнути двері.'])),
    'e8f4a2ca-af87-5d99-9f9e-a24cfadf73c9': dict(
        title='A0 урок 42 Техніка й комунальні послуги', level='A0',
        write=dict(
            situation='Напишіть орендодавцю: бойлер не працює, немає гарячої води; попросіть прислати майстра.',
            points=[('бойлер не працює', [['bojler']]),
                    ('немає гарячої води', [['topl', 'vod']]),
                    ('потрібен майстер', [['majstor']])],
            hints=['bojler ne radi', 'nemamo tople vode', 'kvar', 'majstor', 'možete li poslati'],
            models=['Poštovani, bojler ne radi i nemamo tople vode. Možete li poslati majstora?']),
        mediation=dict(
            source='Obavijest: sutra od 9 do 13 sati nema struje zbog radova.',
            friend='Що за оголошення в під’їзді?',
            points=[('завтра не буде світла', [['світл'], ['електр'], ['струм']]),
                    ('з 9 до 13', [['9', '13']])],
            models=['Завтра з 9 до 13 не буде світла через ремонтні роботи.'])),
    'f51692d8-cb95-5f2e-8263-f3728f5e10c0': dict(
        title='A0 урок 43 Велике й маленьке', level='A0',
        write=dict(
            situation='Друг питає про вашу нову квартиру. Напишіть: квартира невелика, але світла й тиха; кухня маленька.',
            points=[('квартира невелика', [['stan', 'mal'], ['stan', 'nije velik']]),
                    ('світла й тиха', [['svijet', 'tih']]),
                    ('кухня маленька', [['kuhinj', 'mal']])],
            hints=['mali / mala', 'svijetao', 'tih', 'udoban', 'ali'],
            models=['Stan je mali, ali svijetao i tih. Kuhinja je mala.']),
        mediation=dict(
            source='Prodajem kauč: star, ali udoban i čist. Težak je — trebate auto.',
            friend='Що за диван продають?',
            points=[('зручний і чистий', [['зручн', 'чист']]),
                    ('потрібна машина', [['машин'], ['авто']])],
            models=['Старий, але зручний і чистий диван. Він важкий, тож потрібна машина.'])),

    # ------------------------------------------------------------------ A0.7 Hrana
    '7bbaf7ff-10bb-512a-91c5-798b59ec92a5': dict(
        title='A0 урок 44 Я голодний', level='A0',
        write=dict(
            situation='Даша питає, що ви зазвичай їсте на сніданок. Напишіть одне-два речення.',
            points=[('на сніданок', [['doruč']]),
                    ('що їсте', [['kruh'], ['jaj'], ['sir'], ['jogurt'], ['pecivo'], ['sendvič'], ['džem'], ['maslac'], ['med=']])],
            hints=['za doručak', 'obično jedem', 'kruh', 'jaje', 'jogurt', 'sir'],
            models=['Za doručak obično jedem kruh sa sirom i jaje.']),
        mediation=dict(
            source='Doručak u hotelu: od 7 do 10 sati. Ručak i večera nisu uključeni.',
            friend='Що з їжею в готелі?',
            points=[('сніданок з 7 до 10', [['сніданок', '7']]),
                    ('обід і вечеря не включені', [['не включ'], ['не вход'], ['окремо']])],
            models=['Сніданок з 7 до 10, а обід і вечеря не включені.'])),
    'c9e045fb-91ff-52a2-9916-1b698d30eb19': dict(
        title='A0 урок 45 У кафе', level='A0',
        write=dict(
            situation='Ви в кафе. Напишіть, що замовляєте: каву з молоком без цукру і шматок торта.',
            points=[('кава з молоком', [['kav', 'mlijek'], ['bijel', 'kav']]),
                    ('без цукру', [['bez šećer']]),
                    ('торт або тістечко', [['tort'], ['kolač']]),
                    ('ввічливо', [['molim'], ['htio bih'], ['htjela bih'], ['može']])],
            hints=['htio bih / htjela bih', 'kavu s mlijekom', 'bez šećera', 'komad torte', 'molim'],
            models=['Htjela bih kavu s mlijekom bez šećera i komad torte, molim.']),
        mediation=dict(
            source='Kava za van: 1,50 €.\nUz svaki kolač — kava besplatno!',
            friend='Що там написано на дошці?',
            points=[('кава з собою — 1,50 €', [['1', '50'], ['півтора']]),
                    ('з тістечком кава безкоштовно', [['безкоштовн'], ['безплатн'], ['в подарунок']])],
            models=['Кава з собою — 1,50 €, а до кожного тістечка кава безкоштовно.'])),
    '8b30911e-4e57-5648-9ff6-bd11c1b0e27e': dict(
        title='A0 урок 46 У ресторані', level='A0',
        write=dict(
            situation='Напишіть у ресторан: ви хочете забронювати стіл на двох у суботу о 20:00.',
            points=[('забронювати стіл', [['rezerv']]),
                    ('на двох', [['dvoje'], ['dvije osob']]),
                    ('у суботу', [['subot']]),
                    ('о 20:00', [['dvadeset'], ['20'], ['osam navečer']])],
            hints=['htio bih rezervirati', 'stol za dvoje', 'u subotu', 'u 20 sati'],
            models=['Dobar dan, htio bih rezervirati stol za dvoje u subotu u 20 sati.']),
        mediation=dict(
            source='Riba dana: orada na žaru s blitvom — 18 €.',
            friend='Що сьогодні радять?',
            points=[('риба дня на грилі', [['риб']]), ('18 €', [['18']])],
            models=['Риба дня — дорада на грилі з мангольдом, 18 євро.'])),
    '77d640c4-4190-544a-8094-4e699f9a0a10': dict(
        title='A0 урок 47 Напої', level='A0',
        write=dict(
            situation='Напишіть Даші, що ви принесете на вечірку: дві пляшки вина і воду без газу.',
            points=[('вино', [['vin']]), ('дві пляшки', [['dvije', 'boc']]), ('вода без газу', [['bez plin']])],
            hints=['donosim', 'dvije boce vina', 'vodu bez plina', 'sok'],
            models=['Ja donosim dvije boce vina i vodu bez plina.']),
        mediation=dict(
            source='Pivo 0,5 l — 3 €.\nTočeno pivo samo do 23 sata.',
            friend='Скільки коштує пиво?',
            points=[('0,5 л — 3 €', [['3']]), ('розливне — до 23:00', [['23']])],
            models=['Пиво 0,5 л — 3 євро. Розливне — тільки до 23:00.'])),
    'e6925fe5-e7fb-5594-9d3f-87fab1b5598d': dict(
        title='A0 урок 48 Що на вечерю?', level='A0',
        write=dict(
            situation='Подруга-хорватка питає, що ви готуєте на вечерю. Напишіть: курку на грилі з рисом і салат.',
            points=[('курка', [['piletin']]),
                    ('як приготовано', [['na žaru'], ['pečen'], ['pržen'], ['kuhan']]),
                    ('гарнір', [['riž'], ['krumpir'], ['tjestenin'], ['pomfrit'], ['salat']])],
            hints=['za večeru', 'piletina', 'na žaru', 's rižom', 'salata'],
            models=['Za večeru je piletina na žaru s rižom i salatom.']),
        mediation=dict(
            source='Pazi, umak je jako ljut! Riba je bez umaka.',
            friend='Що вона каже про соус?',
            points=[('соус дуже гострий', [['гостр']]), ('риба без соусу', [['риб', 'без']])],
            models=['Каже, що соус дуже гострий, а риба — без соусу.'])),

    # ------------------------------------------------------------------ A0.8 Kupovina
    'e495a4dd-a963-5a5f-af8c-09b2ea6a2ea0': dict(
        title='A0 урок 49 На ринку', level='A0',
        write=dict(
            situation='Ви на ринку. Напишіть, що просите: кілограм помідорів і два огірки, і спитайте, чи свіжа полуниця.',
            points=[('помідори', [['rajčic']]), ('огірки', [['krastav']]), ('чи свіжа полуниця', [['jagod', 'svjež']])],
            hints=['kilogram', 'rajčice', 'krastavac', 'jagode', 'jesu li svježe?'],
            models=['Kilogram rajčica i dva krastavca, molim. Jesu li jagode svježe?']),
        mediation=dict(
            source='Domaće jabuke — 1,20 €/kg.\nBreskve: 2 € za kilu.',
            friend='Почім яблука й персики?',
            points=[('яблука 1,20 €', [['яблук', '1']]), ('персики 2 € за кіло', [['персик', '2']])],
            models=['Домашні яблука — 1,20 € за кілограм, персики — 2 € за кіло.'])),
    '0e925295-2766-5931-b031-2412682bc6f8': dict(
        title='A0 урок 50 Скільки вам?', level='A0',
        write=dict(
            situation='Ви в м’ясному відділі. Напишіть, що просите: двадцять дека шинки (нарізати), пів кіло фаршу — і це все.',
            points=[('шинка', [['šunk']]), ('нарізати', [['narez'], ['narež']]), ('фарш', [['mljeven']]), ('це все', [['to je sve']])],
            hints=['dvadeset deka', 'šunka', 'narežite', 'pola kile mljevenog mesa', 'to je sve'],
            models=['Dvadeset deka šunke, narežite, molim. I pola kile mljevenog mesa. To je sve.']),
        mediation=dict(
            source='Popis: litra mlijeka, kruh, 6 jaja i staklenka meda.',
            friend='Що треба купити за списком?',
            points=[('молоко', [['молок']]), ('хліб', [['хліб']]), ('6 яєць', [['6'], ['шість']]), ('мед', [['мед']])],
            models=['Літр молока, хліб, шість яєць і банку меду.'])),
    '28913ad6-490f-5d89-bad7-9b303c673fcd': dict(
        title='A0 урок 51 На касі', level='A0',
        write=dict(
            situation='Ви купили електрочайник, а він не працює. Напишіть у магазин: чайник не працює, чек є, хочете повернути гроші.',
            points=[('не працює', [['ne radi'], ['pokvaren']]),
                    ('є чек', [['račun']]),
                    ('повернути гроші', [['povrat'], ['vrat', 'novac']])],
            hints=['ne radi', 'imam račun', 'povrat novca', 'reklamacija', 'jamstvo'],
            models=['Kupila sam kuhalo, ali ne radi. Imam račun i želim povrat novca.']),
        mediation=dict(
            source='Plaćanje samo karticom. Bankomat je pored ulaza.',
            friend='Можна заплатити готівкою?',
            points=[('лише карткою', [['картк']]), ('банкомат біля входу', [['банкомат']])],
            models=['Ні, тільки карткою. Банкомат — біля входу.'])),
    'b01e2f67-3e7a-5ab6-99bb-fae374f431e0': dict(
        title='A0 урок 52 Скільки коштує ця футболка?', level='A0',
        write=dict(
            situation='Ви купили онлайн джинси, вони завеликі. Напишіть у магазин: джинси завеликі, чи можна поміняти на менший розмір?',
            points=[('джинси', [['traperic']]), ('завеликі', [['prevelik']]), ('поміняти на менший розмір', [['veličin'], ['zamijen']])],
            hints=['traperice', 'prevelike', 'zamijeniti', 'manju veličinu'],
            models=['Traperice su prevelike. Mogu li ih zamijeniti za manju veličinu?']),
        mediation=dict(
            source='Kabine za probu su na prvom katu. Najviše 3 komada.',
            friend='Де примірочні? Скільки речей можна взяти?',
            points=[('на першому поверсі', [['перш', 'повер']]), ('не більше трьох речей', [['3'], ['три'], ['трьох']])],
            models=['Примірочні на першому поверсі, можна взяти не більше трьох речей.'])),
    '288e7610-99c8-5696-989a-86f60ce38b0a': dict(
        title='A0 урок 53 Кольори', level='A0',
        write=dict(
            situation='Ви загубили сумку в автобусі. Напишіть у бюро знахідок: ви загубили сумку, якого вона кольору і з яким візерунком.',
            points=[('загубили сумку', [['izgub', 'torb']]),
                    ('колір', [['crn'], ['crven'], ['smeđ'], ['plav'], ['zelen'], ['siv'], ['bijel'], ['bež'], ['žut'], ['ružičast']]),
                    ('візерунок або розмір', [['prug'], ['točkic'], ['jednobojn'], ['šaren'], ['velik'], ['mal']])],
            hints=['izgubila sam', 'torba', 'crna', 'na točkice', 'na pruge'],
            models=['Izgubila sam torbu u autobusu. Torba je crna, na bijele točkice.']),
        mediation=dict(
            source='Izgubljen smeđi pas s crvenom ogrlicom. Molimo, javite se!',
            friend='Що за оголошення на стовпі?',
            points=[('загубився коричневий пес', [['пес'], ['собак']]),
                    ('червоний нашийник', [['червон']]),
                    ('просять повідомити', [['повідом'], ['подзвон'], ['звернут']])],
            models=['Загубився коричневий пес у червоному нашийнику. Просять повідомити, якщо побачите.'])),
    '6836e57c-030c-59f8-9818-b44c08b126a6': dict(
        title='A0 урок 54 Можна дешевше?', level='A0',
        write=dict(
            situation='Ви на барахолці. Велосипед коштує 80 €. Напишіть продавцю: це дорого, чи можна дешевше — ви даєте 60 €.',
            points=[('дорого', [['skup']]), ('дешевше', [['jeftinij'], ['spust']]), ('60 €', [['šezdeset'], ['60']])],
            hints=['to je skupo', 'može li jeftinije?', 'dajem', 'zadnja cijena', 'dogovoreno'],
            models=['To je skupo. Može li jeftinije? Dajem šezdeset eura.']),
        mediation=dict(
            source='Rasprodaja! Sve majice 50 % jeftinije.\nSamo do nedjelje.',
            friend='Що за розпродаж?',
            points=[('футболки на 50 % дешевші', [['50']]), ('до неділі', [['неділ']])],
            models=['Розпродаж: усі футболки на 50 % дешевші, тільки до неділі.'])),

    # ------------------------------------------------------------------ A0.9 Grad
    '0addd5be-230b-582f-baed-a5d18eb1d619': dict(
        title='A0 урок 55 Місця в місті', level='A0',
        write=dict(
            situation='Даша питає, що є біля вашого дому. Напишіть: поруч є пошта, банк і парк, а найближчий басейн — далеко.',
            points=[('пошта', [['pošt']]), ('банк', [['bank']]), ('басейн далеко', [['bazen', 'dalek']])],
            hints=['u blizini', 'pošta', 'banka', 'park', 'najbliži'],
            models=['U blizini su pošta, banka i park. Najbliži bazen je daleko.']),
        mediation=dict(
            source='Pošta je zatvorena zbog renoviranja.\nNajbliža pošta: Trg bana Jelačića 5.',
            friend='Пошта сьогодні працює?',
            points=[('пошта зачинена', [['зачин'], ['не працю']]),
                    ('найближча — на площі бана Єлачича', [['площ'], ['єлачич']])],
            models=['Ні, пошта зачинена на ремонт. Найближча — на площі бана Єлачича, 5.'])),
    '55af257e-e4d1-51ed-9637-388a7e0b4baf': dict(
        title='A0 урок 56 Як пройти?', level='A0',
        write=dict(
            situation='Поясніть Даші дорогу від зупинки до вас: прямо до світлофора, потім праворуч, ваш будинок — навпроти парку.',
            points=[('прямо', [['ravno']]), ('до світлофора', [['semafor']]), ('праворуч', [['desno']]), ('навпроти парку', [['preko puta']])],
            hints=['idi ravno', 'do semafora', 'skreni desno', 'preko puta parka'],
            models=['Idi ravno do semafora, onda skreni desno. Moja zgrada je preko puta parka.']),
        mediation=dict(
            source='Idite ravno do kraja ulice, pa lijevo. Muzej je pored crkve.',
            friend='Куди нам іти до музею?',
            points=[('прямо до кінця вулиці', [['прямо'], ['кінц']]),
                    ('потім ліворуч', [['ліворуч'], ['наліво'], ['вліво']]),
                    ('музей біля церкви', [['церкв']])],
            models=['Прямо до кінця вулиці, потім ліворуч. Музей — біля церкви.'])),
    '1e0384e5-6097-56ed-ab56-cf530f02ab73': dict(
        title='A0 урок 57 Старе місто', level='A0',
        write=dict(
            situation='Напишіть подрузі, що варто подивитися в Дубровнику: міські мури, собор і оглядовий майданчик; '
                      'квиток на мури — дорогий.',
            points=[('мури', [['zidin']]), ('собор', [['katedral']]), ('оглядовий майданчик', [['vidikov']]),
                    ('квиток дорогий', [['ulaznic', 'skup']])],
            hints=['moraš vidjeti', 'zidine', 'katedrala', 'vidikovac', 'ulaznica je skupa'],
            models=['U Dubrovniku moraš vidjeti zidine, katedralu i vidikovac. Ulaznica za zidine je skupa.']),
        mediation=dict(
            source='Obilazak starog grada s vodičem: svaki dan u 10 sati, ispred katedrale. Cijena: 15 €.',
            friend='Що там про екскурсію?',
            points=[('щодня о 10', [['10']]), ('біля собору', [['собор']]), ('15 €', [['15']])],
            models=['Екскурсія старим містом з гідом — щодня о 10:00 перед собором, коштує 15 €.'])),
    'e5b81eb1-8ea8-5ff4-a987-e5e46421302b': dict(
        title='A0 урок 58 Квиток на автобус', level='A0',
        write=dict(
            situation='Ви на автовокзалі. Напишіть, що просите в касі: один квиток до Задара на завтра, туди й назад.',
            points=[('квиток до Задара', [['kart', 'zadar']]), ('туди й назад', [['povratn']]), ('на завтра', [['sutra']])],
            hints=['jednu kartu', 'povratnu kartu', 'za Zadar', 'za sutra', 'molim'],
            models=['Jednu povratnu kartu za Zadar za sutra, molim.']),
        mediation=dict(
            source='Autobus za Split kasni 20 minuta. Polazak s perona 5.',
            friend='Що оголосили?',
            points=[('автобус до Спліта запізнюється на 20 хв', [['20']]), ('платформа 5', [['5'], ["п'ят"]])],
            models=['Автобус до Спліта запізнюється на 20 хвилин, відправлення з платформи 5.'])),
    'e0b9d742-0418-597b-9482-b6e2d82469da': dict(
        title='A0 урок 59 Таксі, авто чи велосипед?', level='A0',
        write=dict(
            situation='Напишіть у службу таксі: вам потрібне таксі до аеропорту завтра о шостій ранку.',
            points=[('таксі', [['taksi']]), ('до аеропорту', [['zračn'], ['aerodrom']]), ('завтра о 6', [['sutra', 'šest'], ['sutra', '6']])],
            hints=['trebam taksi', 'do zračne luke', 'sutra u šest', 'ujutro'],
            models=['Trebam taksi do zračne luke sutra u šest ujutro.']),
        mediation=dict(
            source='Parkiranje: 1,60 € po satu. Plaćanje SMS-om ili na automatu.\nKazna: 40 €.',
            friend='Скільки коштує паркування?',
            points=[('1,60 € за годину', [['годин']]), ('оплата SMS або в автоматі', [['sms'], ['автомат']]), ('штраф 40 €', [['штраф']])],
            models=['Паркування — 1,60 € за годину, оплата через SMS або в автоматі. Штраф — 40 €.'])),

    # ------------------------------------------------------------------ A0.10 Survival
    'edbae9ca-c4f4-575d-b876-d50b0a1fd9b5': dict(
        title='A0 урок 60 У готелі', level='A0',
        write=dict(
            situation='Напишіть у готель: у вас бронювання на ваше прізвище, ви приїдете пізно, о 23:00 — чи працює рецепція?',
            points=[('бронювання', [['rezervacij']]), ('приїдете пізно', [['kasno'], ['23'], ['dvadeset tri']]),
                    ('чи працює рецепція', [['recepcij']])],
            hints=['imam rezervaciju', 'na ime', 'dolazim kasno', 'radi li recepcija?'],
            models=['Imam rezervaciju na ime Kovalenko. Dolazim kasno, u 23 sata. Radi li recepcija?']),
        mediation=dict(
            source='Odjava do 10 sati. Doručak je uključen u cijenu.\nLozinka za Wi-Fi: more2026',
            friend='Що треба знати про готель?',
            points=[('виїзд до 10', [['10']]), ('сніданок входить у ціну', [['сніданок']]), ('пароль від Wi-Fi', [['пароль']])],
            models=['Виїзд до 10:00, сніданок входить у ціну, пароль від Wi-Fi — more2026.'])),
    '599fba4f-4cee-5a88-9f9b-5ce32a445554': dict(
        title='A0 урок 61 Частини тіла', level='A0',
        write=dict(
            situation='Напишіть тренерці: у вас болять спина й коліно, сьогодні ви не можете тренуватися.',
            points=[('спина', [['leđa']]), ('коліно', [['koljen']]), ('не можете', [['ne mogu']])],
            hints=['bole me leđa', 'boli me koljeno', 'danas ne mogu', 'trenirati'],
            models=['Bole me leđa i koljeno. Danas ne mogu trenirati.']),
        mediation=dict(
            source='Vaš sin se ne osjeća dobro, boli ga trbuh. Molimo, dođite po njega.',
            friend='Що пишуть зі школи?',
            points=[('синові погано, болить живіт', [['живіт'], ['живот']]), ('просять забрати', [['забра']])],
            models=['Синові погано, у нього болить живіт. Просять приїхати й забрати його.'])),
    'fbc71f82-e715-5bab-a990-b8542fb0fe01': dict(
        title='A0 урок 62 У лікаря й в аптеці', level='A0',
        write=dict(
            situation='Напишіть у дім здоров’я: ви хочете записатися на огляд, у вас температура й кашель уже три дні.',
            points=[('записатися на огляд', [['naruč'], ['pregled']]), ('температура', [['temperatur']]), ('кашель', [['kašal'], ['kašlj']])],
            hints=['htjela bih se naručiti', 'na pregled', 'imam temperaturu', 'kašalj', 'već tri dana'],
            models=['Htjela bih se naručiti na pregled. Imam temperaturu i kašalj već tri dana.']),
        mediation=dict(
            source='Uzimati 1 tabletu 3 puta dnevno, nakon jela. Ne piti alkohol.',
            friend='Як приймати ці ліки?',
            points=[('тричі на день', [['3', 'раз'], ['тричі']]), ('після їжі', [['після', 'їж']]), ('без алкоголю', [['алкогол']])],
            models=['По одній таблетці тричі на день після їжі, і не пити алкоголь.'])),
    '48f26e9d-96c5-5189-8ec6-db1f9d58e200': dict(
        title='A0 урок 63 Допоможіть!', level='A0',
        write=dict(
            situation='Ви бачите аварію і дзвоните на 112. Напишіть, що скажете: сталася аварія, людина поранена, '
                      'потрібна швидка, адреса — Ilica 10.',
            points=[('аварія', [['nesreć']]), ('людина поранена', [['ozlijeđen']]), ('потрібна швидка', [['hitn']]),
                    ('адреса', [['ilic'], ['adres'], ['ulic']])],
            hints=['nesreća', 'ozlijeđen / ozlijeđena', 'trebamo hitnu pomoć', 'adresa je'],
            models=['Dogodila se nesreća. Jedna osoba je ozlijeđena. Trebamo hitnu pomoć, Ilica 10.']),
        mediation=dict(
            source='U slučaju požara: ne koristite lift, idite stepenicama.',
            friend='Що на табличці біля ліфта?',
            points=[('у разі пожежі', [['пожеж']]), ('не користуватися ліфтом', [['ліфт']]), ('йти сходами', [['сход']])],
            models=['У разі пожежі не користуватися ліфтом, а йти сходами.'])),
    'd2689a70-cb73-515f-9d81-6bb0f0fc1cff': dict(
        title='A0 урок 64 У поліції', level='A0',
        write=dict(
            situation='Напишіть заяву в поліцію: у трамваї у вас вкрали гаманець, у ньому були картка й посвідчення особи.',
            points=[('вкрали', [['ukra'], ['krađ']]), ('гаманець', [['novčanik']]), ('картка або посвідчення', [['kartic'], ['osobn'], ['iskaznic']])],
            hints=['ukrali su mi', 'novčanik', 'u tramvaju', 'kartica', 'osobna iskaznica'],
            models=['U tramvaju su mi ukrali novčanik. U njemu su bili kartica i osobna iskaznica.']),
        mediation=dict(
            source='Pazite na džeparoše! Torbe i novčanike držite uz sebe.',
            friend='Що оголошують у трамваї?',
            points=[('обережно, кишенькові злодії', [['злоді'], ['кишеньков']]),
                    ('тримати сумки й гаманці при собі', [['при собі'], ['біля себе'], ['ближче']])],
            models=['Попереджають про кишенькових злодіїв: сумки й гаманці треба тримати при собі.'])),
    'b095637e-0644-507e-8f3d-d323483dd3e4': dict(
        title='A0 урок 65 Заповнюємо анкету', level='A0',
        write=dict(
            situation='Ви заповнюєте анкету. Напишіть хорватською: ім’я й прізвище, місце народження і сімейний стан.',
            points=[('ім’я й прізвище', [['prezime'], ['ime='], ['zovem se']]),
                    ('місце народження', [['mjesto rođenj'], ['rođen']]),
                    ('сімейний стан', [['bračno stanj'], ['udan'], ['oženjen'], ['razveden'], ['neudan'], ['neoženjen']])],
            hints=['ime i prezime', 'mjesto rođenja', 'bračno stanje', 'tiskanim slovima'],
            models=['Ime i prezime: Olena Kovalenko. Mjesto rođenja: Kijev. Bračno stanje: udana.',
                    'Zovem se Taras Bondar, rođen sam u Lavovu, oženjen sam.']),
        mediation=dict(
            source='Obrazac ispunite tiskanim slovima i potpišite. Obvezno priložite kopiju putovnice.',
            friend='Що треба зробити з анкетою?',
            points=[('друкованими літерами', [['друкован']]), ('підписати', [['підпис']]), ('копія паспорта', [['копі', 'паспорт']])],
            models=['Заповнити друкованими літерами, підписати і обов’язково додати копію паспорта.'])),
    '19df3241-90f3-5450-94ac-642d79fb2869': dict(
        title='A0 урок 66 Документи в MUP', level='A0',
        write=dict(
            situation='Напишіть у MUP: ви хочете подати заяву на тимчасове перебування, спитайте, які документи потрібні.',
            points=[('подати заяву', [['zahtjev']]), ('тимчасове перебування', [['privremen', 'boravak']]), ('які документи', [['dokument']])],
            hints=['predati zahtjev', 'privremeni boravak', 'koji dokumenti', 'potrebni su'],
            models=['Poštovani, želim predati zahtjev za privremeni boravak. Koji dokumenti su potrebni?']),
        mediation=dict(
            source='Rješenje možete preuzeti osobno na šalteru 4, od ponedjeljka do petka, 8–12 h.',
            friend='Коли й де забрати рішення?',
            points=[('віконце 4', [['4']]), ('з понеділка до п’ятниці', [['понеділ', "п'ятниц"]]), ('з 8 до 12', [['8', '12']])],
            models=['Рішення можна забрати особисто у віконці 4, з понеділка до п’ятниці, з 8 до 12.'])),
}
