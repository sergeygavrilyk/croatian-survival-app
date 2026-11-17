"""
Модуль A0.6 «Kućni ljubimci» (домашні тварини) · 2026-11-17 — дані для scripts/gen_a0_pets_module.py.

Рішення власника 2026-11-17 (план docs/proposals/2026-11-16_lesson_duplicates.md, §6а): новий модуль A0.6 одразу після A0.5;
урок A0-37 «Домашні тварини» переходить у нього першим; 6 нових уроків: «Собака в місті», «Кішки», «У ветеринара»,
«Тварини на фермі», «Подорож з улюбленцем», «Притулок і загублена тварина». Модулі A0.6–A0.10 стають A0.7–A0.11.

Урок: title (ua, hr), slug, situation (lib/situations.ts), grammar (назва теми граматики A0), objectives,
vocab — [(лема, переклад, частина мови, рід / вид, приклад[, регістр])] — нові слова (їх немає в словнику);
known — наявні в словнику слова, яких ще немає в жодному уроці (переклад — з робочої бази, EXISTING);
scenes — 2 діалоги по 6–8 реплік; fill, build ×2, listen ×2 (з діалогу 1 і 2), speak ×2;
write / mediation — «Напишіть повідомлення» і «Перекажіть другу» (формат scripts/gen_writing.py; переказ у A0 — hr → ua).
Слова не повторюють слів уроків A0 (і жодного іншого уроку — перевірка за знімком робочої бази в генераторі).
Імена: частіше Даша / Дар’я.
"""

DATE = '20261117'

MODULE = dict(
    title=('Kućni ljubimci (домашні тварини)', 'Kućni ljubimci'),
    description='Собака й кішка в місті, ветеринар, ферма, подорож з улюбленцем, притулок і загублена тварина.',
    unit=('Домашні тварини', 'Kućni ljubimci'),
    objectives=['Розповісти про свою тварину', 'Порозумітися з ветеринаром', 'Подорожувати з улюбленцем і знайти загублену тварину'],
)

# Урок A0-37 «Домашні тварини» (уже в робочій базі) — лише новий другий діалог замість «Kod veterinara»
# (ветеринар тепер — окремий урок) і нова вправа «Прослухайте і складіть» з нового діалогу замість «Je li cijepljen?».
LESSON37_ID = '40b9da1d-1686-5b78-8317-0439067d5f8e'
LESSON37_OLD_CONV = '0e3f3dab-4cd9-5f9c-a4f5-7a1525c83f38'
LESSON37_OLD_LISTEN = 'fcca6bae-5d7c-5a25-82ad-f868a53dc5f4'
LESSON37_SCENE = ('Кого візьмемо?', 'Koga ćemo uzeti?', 'small_talk', [
    ('Darja', 'Dašo, djeca žele kućnog ljubimca. Što misliš?', 'Дашо, діти хочуть домашнього улюбленця. Що думаєш?'),
    ('Daša', 'Može, ali koga? Psa ili mačku?', 'Можна, але кого? Собаку чи кішку?'),
    ('Darja', 'Psa treba šetati svaki dan, a mi radimo cijeli dan.', 'Собаку треба вигулювати щодня, а ми працюємо цілий день.'),
    ('Daša', 'Onda mače? Ili hrčka, on je mali.', 'Тоді кошеня? Або хом’ячка, він маленький.'),
    ('Darja', 'Ne znam, Marko je alergičan na dlaku.', 'Не знаю, у Марка алергія на шерсть.'),
    ('Daša', 'Onda kornjača ili ribica! One nemaju dlaku.', 'Тоді черепаха або рибка! У них немає шерсті.'),
])
LESSON37_LISTEN = 'Onda kornjača ili ribica!'

# Нова тема граматики A0 для уроку «Собака в місті»
NEW_GRAMMAR = {
    'smjeti': dict(
        title_ua='Можна чи не можна? Smjeti і команди',
        title_hr='Smije li? Glagol smjeti i naredbe',
        description='Дієслово smjeti («можна, мати дозвіл»): smijem, smiješ, smije… + інфінітив; заборона — ne smije. '
                    'Команди собаці — наказовий спосіб: Sjedi! Lezi! Dođi!',
        rules=[
            ('Smjeti — «можна, мати дозвіл»',
             'Smjeti кажуть про дозвіл: чи можна щось робити за правилами. Після нього — інфінітив: smijem ući — мені можна '
             'увійти. Питання ставимо так: Smije li…? Smijem li…? Відповідь: Smije. / Ne smije. Форми: smijem, smiješ, smije.',
             'smijem, smiješ, smije, smijemo, smijete, smiju + інфінітив',
             [('Smije li pas ući?', 'Чи можна собаці увійти?'), ('Ovdje smijemo pustiti psa.', 'Тут нам можна відпустити собаку.'),
              ('Smijem li sjesti ovdje?', 'Можна мені сісти тут?'), ('Smijemo li parkirati ovdje?', 'Нам можна тут паркуватися?')]),
            ('Заборона: ne smije',
             'Заперечення ne пишемо окремо: ne smijem, ne smiješ, ne smije, ne smiju. Так звучать заборони на табличках і в '
             'правилах: Psi ne smiju ući. Не плутайте з ne mogu — «не можу» (немає змоги), а ne smijem — «мені не можна».',
             'ne + smjeti + інфінітив',
             [('Psi ne smiju ući u trgovinu.', 'Собакам не можна заходити в магазин.'),
              ('Ne smiješ hraniti psa čokoladom.', 'Не можна годувати собаку шоколадом.'),
              ('Ovdje ne smijete pušiti.', 'Тут вам не можна курити.'),
              ('Pas ne smije na kauč.', 'Собаці не можна на диван.')]),
            ('Команди: Sjedi! Lezi! Dođi!',
             'Команда собаці (і будь-яке коротке прохання до «ти») — наказовий спосіб однини. Його треба запам’ятати разом із '
             'дієсловом: sjediti → sjedi, leći → lezi, doći → dođi, dati → daj, čekati → čekaj. До «ви» додаємо -te: Sjedite!',
             'Sjedi! · Lezi! · Dođi! · Daj šapu! · Čekaj!',
             [('Bruno, sjedi!', 'Бруно, сидіти!'), ('Lola, dođi ovamo!', 'Лоло, до мене!'),
              ('Lezi i čekaj!', 'Лежати й чекати!'), ('Daj šapu, Medo!', 'Дай лапу, Медо!')]),
        ]),
}

# Наявні слова словника, яких ще немає в жодному уроці (переклад, рівень — з робочої бази 2026-11-17)
EXISTING = {
    'pustiti': ('відпустити', 'B1'), 'oprez': ('обережно', 'A0'), 'opasan': ('небезпечний', 'A0'), 'bojati se': ('боятися', 'A1'),
    'skočiti': ('стрибнути', 'A2'), 'pobjeći': ('втекти', 'B1'), 'sakriti se': ('сховатися', 'B1'),
    'operacija': ('операція', 'B1'), 'čokolada': ('шоколад', 'A1'), 'protiv': ('проти', 'A2'),
    'krava': ('корова', 'A1'), 'konj': ('кінь', 'A1'), 'ovca': ('вівця', 'A1'), 'koza': ('кіза', 'A1'), 'svinja': ('свиня', 'A1'),
    'kokoš': ('курка', 'A1'), 'patka': ('качка', 'A1'), 'seljak': ('селянин', 'A2'), 'livada': ('луг / галявина', 'A1'),
    'dopustiti': ('дозволити', 'B1'), 'plašljiv': ('боязкий', 'B1'), 'šansa': ('шанс', 'A2'), 'prepoznati': ('впізнати', 'B1'),
}

LESSONS = [
    # ------------------------------------------------------------------ 38
    dict(
        slug='dog_city', title=('Собака в місті', 'Pas u gradu'), situation='small_talk',
        grammar='Можна чи не можна? Smjeti і команди',
        objectives=['Зрозуміти таблички про собак у місті', 'Запитати, чи можна із собакою', 'Дати собаці прості команди'],
        vocab=[
            ('brnjica', 'намордник', 'n', 'f', 'U autobusu pas mora nositi brnjicu.'),
            ('park za pse', 'парк для собак', 'ph', 'm', 'Navečer vodim psa u park za pse.'),
            ('počistiti', 'прибрати', 'v', 'pfv:čistiti', 'Molimo, počistite za svojim psom.'),
            ('loptica', 'м’ячик', 'n', 'f', 'Daša baca psu lopticu u parku.'),
            ('pasmina', 'порода', 'n', 'f', 'Koje je pasmine tvoj pas?'),
            ('mješanac', 'метис; безпородний собака', 'n', 'm', 'Naš pas nije čiste pasmine, on je mješanac.'),
            ('njušiti', 'нюхати', 'v', 'ipfv:onjušiti', 'Pas njuši svako drvo u parku.'),
            ('mahati', 'махати', 'v', 'ipfv:mahnuti', 'Kad me vidi, pas veselo maše repom.'),
            ('gristi', 'кусатися; гризти', 'v', 'ipfv:ugristi', 'Ne bojte se, moj pas ne grize.'),
            ('pseći', 'собачий', 'adj', '', 'U dućanu kupujem pseću hranu.'),
            ('pas vodič', 'собака-поводир', 'ph', 'm', 'Pas vodič smije ući u svaku trgovinu.'),
            ('zabranjen', 'заборонений', 'adj', '', 'Ulaz psima je zabranjen.'),
            ('dozvoljen', 'дозволений', 'adj', '', 'Na terasi kafića psi su dozvoljeni.'),
            ('daj šapu', 'дай лапу', 'ph', '', 'Lola, sjedi i daj šapu!'),
            ('naredba', 'команда; наказ', 'n', 'f', 'Moj pas zna pet naredbi.'),
            ('povesti', 'взяти з собою (кого-небудь)', 'v', 'pfv', 'Mogu li povesti psa u restoran?'),
            ('trgovina za kućne ljubimce', 'зоомагазин', 'ph', 'f', 'Lopticu sam kupila u trgovini za kućne ljubimce.'),
            ('zavezati', 'прив’язати', 'v', 'pfv:vezati', 'Zavežite psa ispred trgovine, molim.'),
        ],
        known=['pustiti', 'oprez', 'opasan', 'bojati se'],
        scenes=[
            ('У парку для собак', 'U parku za pse', [
                ('Luka', 'Dobar dan! Smije li moj pas ovdje bez povodca?', 'Добрий день! Моєму собаці тут можна без повідця?'),
                ('Daša', 'Smije, ovo je park za pse. Ovdje ga možete pustiti.', 'Можна, це парк для собак. Тут його можна відпустити.'),
                ('Luka', 'Super! Bruno, idi se igrati! Koje je pasmine vaš pas?', 'Чудово! Бруно, йди погратися! Якої породи ваш собака?'),
                ('Daša', 'Nije čiste pasmine, mješanac je. Zove se Medo.', 'Не породистий, це метис. Його звати Медо.'),
                ('Luka', 'Medo njuši Bruna. Grize li?', 'Медо обнюхує Бруно. Він кусається?'),
                ('Daša', 'Ne, ne grize. Vidite, maše repom! Ne bojte se.', 'Ні, не кусається. Бачите, махає хвостом! Не бійтеся.'),
            ]),
            ('Чи можна собаці всередину?', 'Smije li pas unutra?', [
                ('Darja', 'Oprostite, smije li pas unutra?', 'Перепрошую, собаці можна всередину?'),
                ('Konobar', 'Nažalost, ulaz psima je zabranjen. Samo pas vodič smije ući.', 'На жаль, вхід собакам заборонено. Заходити може лише собака-поводир.'),
                ('Darja', 'Šteta. A na terasi?', 'Шкода. А на терасі?'),
                ('Konobar', 'Na terasi su psi dozvoljeni. Donijet ću mu vode.', 'На терасі собаки дозволені. Я принесу йому води.'),
                ('Darja', 'Hvala! Lola, sjedi! Bravo, daj šapu!', 'Дякую! Лоло, сидіти! Молодець, дай лапу!'),
                ('Konobar', 'Kako je poslušna! Zna li još neku naredbu?', 'Яка слухняна! Вона знає ще якусь команду?'),
                ('Darja', 'Zna: lezi i dođi!', 'Знає: «лежати» і «до мене»!'),
            ]),
        ],
        fill=('Psi ne ___ ući u trgovinu.', 'smiju', ['smije', 'smijem', 'smijemo']),
        build=[('Собакам не можна заходити.', 'Psi ne smiju ući.'), ('Мій собака не кусається.', 'Moj pas ne grize.')],
        listen=['Vidite, maše repom!', 'Samo pas vodič smije ući.'],
        speak=[('Собаці можна всередину?', 'Smije li pas unutra?'), ('Не бійтеся, він не кусається.', 'Ne bojte se, on ne grize.')],
        write=dict(
            situation='Подруга Дар’я питає в чаті: «Smije li moj pas doći k tebi?» Відповідайте: так, можна; собаці не можна '
                      'на диван; у вас є для нього м’ячик.',
            points=[('можна прийти', [['smije'], ['može'], ['naravno'], ['da']]),
                    ('на диван не можна', [['ne smije', 'kauč'], ['ne smije', 'krevet']]),
                    ('у вас є м’ячик для собаки', [['loptic']])],
            hints=['smije', 'ne smije', 'kauč', 'loptica', 'imam'],
            models=['Naravno, smije! Ali ne smije na kauč. Imam lopticu za njega.',
                    'Da, može doći. Pas ne smije na kauč. Imam novu lopticu.']),
        mediation=dict(
            source='OPREZ, PAS!\nUlaz psima zabranjen.\nPsi vodiči smiju ući.',
            friend='Що тут написано? Можна з собакою?',
            points=[('собакам заходити не можна', [['не можна'], ['заборон']]),
                    ('можна лише собакам-поводирям', [['поводир']])],
            models=['Тут написано: обережно, собака! Собакам заходити заборонено, можна лише собакам-поводирям.'])),
    # ------------------------------------------------------------------ 39
    dict(
        slug='cats', title=('Кішки', 'Mačke'), situation='housing',
        grammar='Прикметники: узгодження з іменником',
        objectives=['Описати кішку: колір і характер', 'Розповісти, що робить кішка', 'Попросити сусідів допомогти знайти кішку'],
        vocab=[
            ('mačak', 'кіт', 'n', 'm', 'Naš mačak cijeli dan spava na suncu.'),
            ('maca', 'киця', 'n', 'f', 'Maca čeka večeru ispred vrata.', 'informal'),
            ('mic mic', 'кис-кис', 'int', '', 'Mic mic, dođi ovamo!', 'informal'),
            ('presti', 'муркотіти', 'v', 'ipfv', 'Mačka prede kad je sretna.'),
            ('mijaukati', 'нявкати', 'v', 'ipfv', 'Mačak glasno mijauče kad je gladan.'),
            ('kandža', 'кіготь (у кішки)', 'n', 'f', 'Mačka ima oštre kandže.'),
            ('krzno', 'хутро', 'n', 'n', 'Ova maca ima mekano bijelo krzno.'),
            ('loviti', 'ловити; полювати', 'v', 'ipfv:uloviti', 'Mačke vole loviti ptice.'),
            ('grebalica', 'дряпка (кігтеточка)', 'n', 'f', 'Kupili smo mački novu grebalicu.'),
            ('ogrebati', 'подряпати', 'v', 'pfv:grebati', 'Mače me ogrebalo po ruci.'),
            ('lizati', 'лизати', 'v', 'ipfv:polizati', 'Mačka liže svoje krzno.'),
            ('umiljat', 'лагідний; ласкавий', 'adj', '', 'Moja mačka je jako umiljata.'),
            ('prugast', 'смугастий', 'adj', '', 'Tražim sivog prugastog mačka.'),
            ('zaštitna mreža', 'захисна сітка', 'ph', 'f', 'Na balkonu imamo zaštitnu mrežu za mačku.'),
            ('mačji', 'котячий', 'adj', '', 'Molim te, kupi mačju hranu.'),
            ('klupko', 'клубок', 'n', 'n', 'Mače se igra s klupkom vune.'),
            ('sklupčati se', 'згорнутися клубочком', 'v', 'pfv:sklupčavati se', 'Mačka se sklupčala na kauču.'),
        ],
        known=['skočiti', 'pobjeći', 'sakriti se'],
        scenes=[
            ('Нова киця', 'Nova maca', [
                ('Ana', 'Dašo, je li to vaša nova maca?', 'Дашо, це ваша нова киця?'),
                ('Daša', 'Nije maca, to je mačak! Zove se Tigar.', 'Це не киця, це кіт! Його звати Тигр.'),
                ('Ana', 'Lijep je! Siv je i prugast.', 'Гарний! Сірий і смугастий.'),
                ('Daša', 'I jako umiljat. Kad ga mazim, prede.', 'І дуже лагідний. Коли я його гладжу, він муркоче.'),
                ('Ana', 'A grebe li namještaj?', 'А меблі він дряпає?'),
                ('Daša', 'Ne, ima grebalicu. Ali često skoči na stol!', 'Ні, у нього є дряпка. Але часто стрибає на стіл!'),
            ]),
            ('Кішка втекла', 'Mačka je pobjegla', [
                ('Darja', 'Dobar dan, susjede! Jeste li vidjeli moju mačku?', 'Добрий день, сусіде! Ви не бачили мою кішку?'),
                ('Susjed', 'Kakva je?', 'Яка вона?'),
                ('Darja', 'Mala je, crna, s bijelim šapama. Pobjegla je s balkona.', 'Маленька, чорна, з білими лапками. Втекла з балкона.'),
                ('Susjed', 'Zar na balkonu nema zaštitne mreže?', 'Хіба на балконі немає захисної сітки?'),
                ('Darja', 'Ima, ali u mreži je mala rupa.', 'Є, але в сітці маленька дірка.'),
                ('Susjed', 'Mačke se često sakriju ispod auta. Mic mic!', 'Кішки часто ховаються під машинами. Кис-кис!'),
                ('Darja', 'Eno je! Mijauče ispod auta!', 'Он вона! Нявкає під машиною!'),
            ]),
        ],
        fill=('Moja mačka je ___.', 'prugasta', ['prugast', 'prugasto', 'prugasti']),
        build=[('Мій кіт дуже лагідний.', 'Moj mačak je jako umiljat.'), ('Кішка лиже лапу.', 'Mačka liže šapu.')],
        listen=['Siv je i prugast.', 'Pobjegla je s balkona.'],
        speak=[('Ви не бачили мою кішку?', 'Jeste li vidjeli moju mačku?'), ('Мій кіт сірий і смугастий.', 'Moj mačak je siv i prugast.')],
        write=dict(
            situation='Ваш кіт утік. Напишіть у чат будинку: кіт утік, якого він кольору, і попросіть сусідів зателефонувати.',
            points=[('кіт утік / зник', [['pobjeg'], ['nesta']]),
                    ('колір кота', [['siv'], ['crn'], ['bijel'], ['prugast'], ['riđ']]),
                    ('попросіть зателефонувати', [['nazov'], ['zovite'], ['javi']])],
            hints=['pobjegao je', 'mačak', 'siv', 'prugast', 'nazovite me'],
            models=['Pobjegao je moj mačak Tigar! Siv je i prugast. Molim vas, nazovite me!',
                    'Moja mačka je nestala. Crna je, s bijelim šapama. Javite se, molim vas!']),
        mediation=dict(
            source='Poštovani stanari,\nmolimo vas da ne hranite mačke na stubištu.\nHvala!',
            friend='Що тут написано?',
            points=[('не годувати кішок', [['не году', 'кіш'], ['не году', 'кот']]),
                    ('на сходах / у під’їзді', [['сход'], ['під']])],
            models=['Мешканців просять не годувати кішок на сходах.'])),
    # ------------------------------------------------------------------ 40
    dict(
        slug='vet', title=('У ветеринара', 'Kod veterinara'), situation='vet',
        grammar='Що болить? Boli me…, bole me…',
        objectives=['Пояснити ветеринару, що з твариною', 'Зрозуміти поради ветеринара', 'Записатися на огляд'],
        vocab=[
            ('veterinarska ambulanta', 'ветеринарна клініка', 'ph', 'f', 'Veterinarska ambulanta radi i subotom.'),
            ('čip', 'мікрочип', 'n', 'm', 'Svaki pas u Hrvatskoj mora imati čip.'),
            ('krpelj', 'кліщ', 'n', 'm', 'Nakon šetnje sam našla krpelja na psu.'),
            ('parazit', 'паразит', 'n', 'm', 'Ove tablete štite psa od parazita.'),
            ('kastrirati', 'каструвати', 'v', 'biasp', 'Našeg mačka ćemo kastrirati na proljeće.'),
            ('sterilizirati', 'стерилізувати', 'v', 'biasp', 'Našu mačku smo sterilizirali prošle godine.'),
            ('vaga', 'ваги', 'n', 'f', 'Stavite psa na vagu, molim.'),
            ('otrov', 'отрута', 'n', 'm', 'Neke biljke su otrov za mačke.'),
            ('apetit', 'апетит', 'n', 'm', 'Mačak nema apetita već dva dana.'),
            ('što mu je', 'що з ним?', 'ph', '', 'Što mu je? Cijeli dan samo leži.'),
            ('šepati', 'кульгати', 'v', 'ipfv', 'Pas šepa na lijevu nogu.'),
            ('zaštitni ovratnik', 'захисний комір', 'ph', 'm', 'Nakon operacije pas mora nositi zaštitni ovratnik.'),
            ('dežurni veterinar', 'черговий ветеринар', 'ph', 'm', 'Noću zovemo dežurnog veterinara.'),
            ('cijepljen', 'щеплений', 'adj', '', 'Je li vaš pas cijepljen?'),
            ('podrezati', 'підрізати; підстригти', 'v', 'pfv:podrezivati', 'Veterinar će psu podrezati nokte.'),
            ('nokat', 'ніготь; кіготь (у собаки)', 'n', 'm', 'Psu je nokat predug.'),
            ('mirno', 'спокійно', 'adv', '', 'Držite psa mirno, molim vas.'),
        ],
        known=['operacija', 'čokolada', 'protiv'],
        scenes=[
            ('У ветеринара', 'Kod veterinara', [
                ('Veterinarka', 'Dobar dan! Što mu je?', 'Добрий день! Що з ним?'),
                ('Daša', 'Šepa od jučer. Mislim da ga boli šapa.', 'Кульгає з учора. Думаю, у нього болить лапа.'),
                ('Veterinarka', 'Stavite ga na vagu, molim. Držite ga mirno.', 'Поставте його на ваги, будь ласка. Тримайте його спокійно.'),
                ('Daša', 'Dobro. Mirno, Medo!', 'Добре. Спокійно, Медо!'),
                ('Veterinarka', 'Aha, nokat mu je predug. Podrezat ću ga.', 'Ага, кіготь у нього задовгий. Я його підріжу.'),
                ('Daša', 'Hvala! Treba li mu i cijepljenje?', 'Дякую! Йому ще потрібне щеплення?'),
                ('Veterinarka', 'Ne, cijepljen je. Ali ima li čip?', 'Ні, він щеплений. А чип у нього є?'),
                ('Daša', 'Ima, evo broja čipa.', 'Є, ось номер чипа.'),
            ]),
            ('Кліщ', 'Krpelj', [
                ('Darja', 'Dobar dan, je li to dežurni veterinar?', 'Добрий день, це черговий ветеринар?'),
                ('Veterinar', 'Da, izvolite.', 'Так, слухаю.'),
                ('Darja', 'Moja mačka nema apetita i samo leži.', 'Моя кішка не має апетиту й тільки лежить.'),
                ('Veterinar', 'Je li pojela nešto čudno? Čokolada je otrov za mačke.', 'Вона не з’їла чогось дивного? Шоколад — отрута для котів.'),
                ('Darja', 'Ne znam. Ali danas sam našla krpelja na njoj.', 'Не знаю. Але сьогодні я знайшла на ній кліща.'),
                ('Veterinar', 'Dođite odmah. Krpelji su opasni paraziti.', 'Приїжджайте негайно. Кліщі — небезпечні паразити.'),
                ('Darja', 'Dolazim! Imate li sredstvo protiv krpelja?', 'Їду! У вас є засіб проти кліщів?'),
                ('Veterinar', 'Imamo. Vidimo se za pola sata.', 'Є. Побачимося за пів години.'),
            ]),
        ],
        fill=('Psa ___ šapa.', 'boli', ['bole', 'boljeti', 'bolim']),
        build=[('Що з ним?', 'Što mu je?'), ('Шоколад — отрута для собак.', 'Čokolada je otrov za pse.')],
        listen=['Šepa od jučer.', 'Krpelji su opasni paraziti.'],
        speak=[('Що з ним? Він кульгає.', 'Što mu je? Šepa.'), ('У вас є засіб проти кліщів?', 'Imate li sredstvo protiv krpelja?')],
        write=dict(
            situation='Напишіть у ветеринарну клініку: ваш собака кульгає; попросіть записати вас на огляд завтра.',
            points=[('собака кульгає', [['šep']]),
                    ('попросіть термін або огляд', [['termin'], ['pregled'], ['mogu li doći'], ['možemo li doći']]),
                    ('коли: завтра', [['sutra']])],
            hints=['moj pas šepa', 'termin', 'sutra', 'molim vas'],
            models=['Dobar dan! Moj pas šepa. Imate li termin za sutra? Hvala!',
                    'Poštovani, pas mi šepa od jučer. Možemo li doći sutra ujutro na pregled?']),
        mediation=dict(
            source='VETERINARSKA AMBULANTA\nRadno vrijeme: pon – pet 8 – 19, sub 8 – 12\nHitni slučajevi: 091 555 0101',
            friend='Коли працює ця клініка?',
            points=[('у будні з 8 до 19', [['понеділ', '19'], ['будн', '19']]),
                    ('у суботу з 8 до 12', [['субот', '12']])],
            models=['Клініка працює з понеділка по п’ятницю з 8 до 19, а в суботу з 8 до 12. Для термінових випадків є телефон.'])),
    # ------------------------------------------------------------------ 41
    dict(
        slug='farm', title=('Тварини на фермі', 'Životinje na farmi'), situation='travel',
        grammar='Рід, множина і «мій / моя / моє»',
        objectives=['Назвати тварин на фермі', 'Сказати, скільки тварин: одна корова — дві корови', 'Розповісти про село й ферму'],
        vocab=[
            ('farma', 'ферма', 'n', 'f', 'Baka ima malu farmu blizu Osijeka.'),
            ('tele', 'теля', 'n', 'n', 'Tele spava pokraj mame u štali.'),
            ('magarac', 'віслюк', 'n', 'm', 'Na otoku smo vidjeli magarca.'),
            ('janje', 'ягня', 'n', 'n', 'Malo janje trči za ovcom.'),
            ('pijetao', 'півень', 'n', 'm', 'Pijetao nas budi svako jutro.'),
            ('guska', 'гуска', 'n', 'f', 'Guske plivaju u jezeru.'),
            ('štala', 'стайня; хлів', 'n', 'f', 'Krave su navečer u štali.'),
            ('sijeno', 'сіно', 'n', 'n', 'Konji jedu sijeno.'),
            ('trava', 'трава', 'n', 'f', 'Ovce jedu travu na livadi.'),
            ('musti', 'доїти', 'v', 'ipfv:pomusti', 'Baka ujutro muze kravu.'),
            ('jahati', 'їздити верхи', 'v', 'ipfv', 'Darja voli jahati konja.'),
            ('mukati', 'мукати', 'v', 'ipfv', 'Krava muče u štali.'),
        ],
        known=['krava', 'konj', 'ovca', 'koza', 'svinja', 'kokoš', 'patka', 'seljak', 'livada'],
        scenes=[
            ('У бабусі на селі', 'Kod bake na selu', [
                ('Daša', 'Bako, koliko životinja imaš na farmi?', 'Бабусю, скільки тварин у тебе на фермі?'),
                ('Baka', 'Imam jednu kravu, dvije koze i deset kokoši.', 'У мене одна корова, дві кози й десять курей.'),
                ('Daša', 'A tko to tako rano viče?', 'А хто це так рано кричить?'),
                ('Baka', 'To je pijetao! Svako jutro u pet sati.', 'Це півень! Щоранку о п’ятій.'),
                ('Daša', 'Mogu li vidjeti tele u štali?', 'Можна подивитися на теля в стайні?'),
                ('Baka', 'Možeš. Ali prvo moram pomusti kravu.', 'Можна. Але спершу мені треба подоїти корову.'),
                ('Daša', 'Mogu li ja probati musti?', 'А можна я спробую доїти?'),
            ]),
            ('Їзда верхи', 'Jahanje', [
                ('Darja', 'Gledaj, Dašo, konji na livadi!', 'Дивись, Дашо, коні на лузі!'),
                ('Daša', 'I magarac! Jede travu.', 'І віслюк! Їсть траву.'),
                ('Seljak', 'Dobar dan! Želite li jahati?', 'Добрий день! Хочете поїздити верхи?'),
                ('Darja', 'Želimo, ali nikad nismo jahale.', 'Хочемо, але ми ніколи не їздили верхи.'),
                ('Seljak', 'Nema problema, ovaj konj je miran.', 'Без проблем, цей кінь спокійний.'),
                ('Daša', 'Koliko košta jahanje?', 'Скільки коштує їзда верхи?'),
                ('Seljak', 'Deset eura za pola sata.', 'Десять євро за пів години.'),
            ]),
        ],
        fill=('Na farmi su dvije ___.', 'krave', ['krava', 'kravu', 'kravi']),
        build=[('У бабусі є корова й кози.', 'Baka ima kravu i koze.'), ('Півень співає щоранку.', 'Pijetao pjeva svako jutro.')],
        listen=['To je pijetao!', 'Deset eura za pola sata.'],
        speak=[('Можна поїздити верхи?', 'Mogu li jahati?'), ('Скільки тварин у тебе на фермі?', 'Koliko životinja imaš na farmi?')],
        write=dict(
            situation='Ви на вихідних у бабусі на фермі. Напишіть Даші: де ви, які тварини тут є, і запросіть її приїхати.',
            points=[('де ви: на фермі чи в селі', [['farm'], ['sel']]),
                    ('які тварини тут є', [['krav'], ['konj'], ['koz'], ['ovc'], ['svinj'], ['kokoš'], ['patk'], ['gusk']]),
                    ('запросіть приїхати', [['dođi'], ['dođite']])],
            hints=['na farmi sam', 'krave', 'konji', 'dođi'],
            models=['Bok, Dašo! Na farmi sam kod bake. Ovdje su krave, koze i konji. Dođi i ti!',
                    'Ja sam na selu. Imamo kokoši i jednu kravu. Dođi sutra!']),
        mediation=dict(
            source='Farma Zeleni Gaj\nSvježe mlijeko i jaja svaki dan.\nJahanje: subotom i nedjeljom.',
            friend='Що тут продають і що можна робити?',
            points=[('молоко і яйця', [['молок', 'яй']]),
                    ('у вихідні можна їздити верхи', [['верхи']])],
            models=['Тут щодня продають свіже молоко і яйця. А в суботу й неділю можна їздити верхи.'])),
    # ------------------------------------------------------------------ 42
    dict(
        slug='pet_travel', title=('Подорож з улюбленцем', 'Putovanje s ljubimcem'), situation='border',
        grammar='Питальні слова',
        objectives=['Дізнатися, які документи потрібні тварині в подорожі', 'Запитати в житлі, чи можна з собакою',
                    'Зрозуміти правила перевезення тварин'],
        vocab=[
            ('putovnica za kućne ljubimce', 'паспорт домашньої тварини', 'ph', 'f', 'Za put u Italiju pas treba putovnicu za kućne ljubimce.'),
            ('bjesnoća', 'сказ', 'n', 'f', 'Pas mora biti cijepljen protiv bjesnoće.'),
            ('veterinarska potvrda', 'ветеринарна довідка', 'ph', 'f', 'Na granici su tražili veterinarsku potvrdu.'),
            ('transporter', 'переноска (для тварини)', 'n', 'm', 'Mačka putuje u transporteru.'),
            ('plaža za pse', 'пляж для собак', 'ph', 'f', 'Blizu apartmana je plaža za pse.'),
            ('doplata', 'доплата', 'n', 'f', 'Za psa je doplata deset eura po noći.'),
            ('pansion za pse', 'готель для собак', 'ph', 'm', 'Dok smo na moru, pas je u pansionu za pse.'),
            ('sigurnosni pojas', 'ремінь безпеки', 'ph', 'm', 'U autu pas nosi poseban sigurnosni pojas.'),
            ('aviokompanija', 'авіакомпанія', 'n', 'f', 'Ova aviokompanija prevozi male pse u kabini.'),
            ('sredstvo za smirenje', 'заспокійливий засіб', 'ph', 'n', 'Veterinar nam je dao sredstvo za smirenje za put.'),
            ('ograničenje', 'обмеження', 'n', 'n', 'Postoji ograničenje: pas može imati najviše osam kilograma.'),
            ('čipiran', 'чипований', 'adj', '', 'Je li vaš pas čipiran?'),
            ('zrakoplov', 'літак', 'n', 'm', 'Mačka je prvi put letjela zrakoplovom.'),
            ('Europska unija', 'Європейський Союз', 'ph', 'f', 'Pas putuje po Europskoj uniji s putovnicom.'),
            ('najmanje', 'щонайменше', 'adv', '', 'Cijepljenje mora biti najmanje tri tjedna prije puta.'),
            ('noćiti', 'ночувати', 'v', 'ipfv:prenoćiti', 'Na putu ćemo noćiti u hotelu koji prima pse.'),
            ('granična policija', 'прикордонна поліція', 'ph', 'f', 'Granična policija je provjerila psa i dokumente.'),
            ('dobrodošao', 'бажаний (гість); ласкаво просимо', 'adj', '', 'U našem hotelu kućni ljubimci su dobrodošli.'),
            ('pojilica', 'поїлка', 'n', 'f', 'Na put uvijek nosim pojilicu za psa.'),
        ],
        known=['dopustiti'],
        scenes=[
            ('На кордоні із собакою', 'Na granici sa psom', [
                ('Policajac', 'Dobar dan. Putujete li sa životinjom?', 'Добрий день. Ви подорожуєте з твариною?'),
                ('Daša', 'Da, sa psom. Evo njegove putovnice za kućne ljubimce.', 'Так, із собакою. Ось його паспорт домашньої тварини.'),
                ('Policajac', 'Je li čipiran?', 'Він чипований?'),
                ('Daša', 'Jest, i cijepljen je protiv bjesnoće.', 'Так, і щеплений від сказу.'),
                ('Policajac', 'Kada je bilo cijepljenje?', 'Коли було щеплення?'),
                ('Daša', 'Prije dva mjeseca. Imam i veterinarsku potvrdu.', 'Два місяці тому. Ще в мене є ветеринарна довідка.'),
                ('Policajac', 'U redu, sretan put!', 'Гаразд, щасливої дороги!'),
            ]),
            ('Житло із собакою', 'Smještaj sa psom', [
                ('Darja', 'Dobar dan, imate li slobodan apartman za vikend?', 'Добрий день, у вас є вільні апартаменти на вихідні?'),
                ('Domaćica', 'Imamo. Koliko osoba?', 'Є. На скільки осіб?'),
                ('Darja', 'Dvije osobe i jedan mali pas. Je li to problem?', 'Дві особи й маленький собака. Це проблема?'),
                ('Domaćica', 'Nije. Psi su dobrodošli, ali je doplata pet eura po noći.', 'Ні. Собакам раді, але доплата п’ять євро за ніч.'),
                ('Darja', 'Može. Gdje je najbliža plaža za pse?', 'Добре. Де найближчий пляж для собак?'),
                ('Domaćica', 'Deset minuta pješice. Tamo pas smije bez povodca.', 'Десять хвилин пішки. Там собаці можна без повідця.'),
                ('Darja', 'Odlično, hvala!', 'Чудово, дякую!'),
            ]),
        ],
        fill=('___ košta doplata za psa?', 'Koliko', ['Gdje', 'Tko', 'Kada']),
        build=[('Мій собака подорожує в переносці.', 'Moj pas putuje u transporteru.'), ('Де пляж для собак?', 'Gdje je plaža za pse?')],
        listen=['Je li čipiran?', 'Dvije osobe i jedan mali pas.'],
        speak=[('Можна приїхати до вас із собакою?', 'Smijem li doći sa psom?'), ('Ось паспорт мого собаки.', 'Evo putovnice mog psa.')],
        write=dict(
            situation='Ви бронюєте апартаменти на морі. Напишіть господарю: ви приїдете із собакою; запитайте, чи можна, і скільки коштує доплата.',
            points=[('ви приїдете із собакою', [['psom'], ['psa'], ['pas'], ['psi']]),
                    ('запитайте, чи можна', [['smije'], ['može li'], ['je li u redu'], ['dozvoljen']]),
                    ('скільки доплата', [['koliko', 'doplat'], ['koliko košta']])],
            hints=['dolazimo sa psom', 'smije li', 'koliko košta', 'doplata'],
            models=['Dobar dan! Dolazimo sa psom. Smije li pas u apartman? Koliko košta doplata?',
                    'Poštovani, imamo malog psa. Može li i on doći? Koliko je doplata?']),
        mediation=dict(
            source='Poštovani gosti,\nkućni ljubimci su dobrodošli uz doplatu od 10 € po noći.\nPsi ne smiju u bazen.',
            friend='Що тут написано про тварин?',
            points=[('тварин приймають, доплата 10 євро за ніч', [['10'], ['десять']]),
                    ('собакам не можна в басейн', [['басейн']])],
            models=['Тварин приймають, але треба доплатити 10 євро за ніч. І собакам не можна в басейн.'])),
    # ------------------------------------------------------------------ 43
    dict(
        slug='shelter', title=('Притулок і загублена тварина', 'Sklonište i izgubljena životinja'), situation='small_talk',
        grammar='Цей, той, он той: ovaj, taj, onaj',
        objectives=['Запитати про тварин у притулку', 'Розповісти, що ви загубили чи знайшли тварину',
                    'Описати тварину: самець чи самка, вік, характер'],
        vocab=[
            ('sklonište za životinje', 'притулок для тварин', 'ph', 'n', 'U skloništu za životinje čeka pedeset pasa.'),
            ('udomiti', 'взяти тварину з притулку; прихистити', 'v', 'pfv:udomljavati', 'Prošle godine smo udomili mačku.'),
            ('udomljavanje', 'прилаштування тварини (з притулку)', 'n', 'n', 'Udomljavanje u skloništu je besplatno.'),
            ('napušten', 'покинутий', 'adj', '', 'Našli smo napuštenog psa pokraj ceste.'),
            ('lutalica', 'безпритульна тварина', 'n', 'f', 'Ova mačka je prije bila lutalica.'),
            ('izgubljen', 'загублений', 'adj', '', 'Na stupu je oglas za izgubljenog psa.'),
            ('novi dom', 'новий дім', 'ph', 'm', 'Ovaj mačić traži novi dom.'),
            ('zbrinuti', 'прилаштувати; подбати (про кого)', 'v', 'pfv:zbrinjavati', 'Volonteri su zbrinuli sve mačiće.'),
            ('udomitelj', 'новий господар (тварини з притулку)', 'n', 'm', 'Sklonište traži dobrog udomitelja za Belu.'),
            ('boks', 'вольєр', 'n', 'm', 'Svaki pas u skloništu ima svoj boks.'),
            ('privremeni smještaj', 'тимчасова перетримка', 'ph', 'm', 'Štene je kod nas na privremenom smještaju.'),
            ('pronađen', 'знайдений', 'adj', '', 'Pronađen pas! Vlasnik se može javiti skloništu.'),
            ('dobrovoljac', 'доброволець', 'n', 'm', 'Luka je dobrovoljac u skloništu.'),
            ('nahraniti', 'нагодувати', 'v', 'pfv:hraniti', 'Možeš li nahraniti mačku večeras?'),
            ('zalutati', 'заблукати', 'v', 'pfv', 'Mače je zalutalo u naš vrt.'),
            ('ženka', 'самка', 'n', 'f', 'Ova mačka je ženka, ima dvije godine.'),
            ('mužjak', 'самець', 'n', 'm', 'Je li tvoj hrčak mužjak ili ženka?'),
        ],
        known=['plašljiv', 'šansa', 'prepoznati'],
        scenes=[
            ('У притулку', 'U skloništu', [
                ('Daša', 'Dobar dan! Želimo udomiti psa.', 'Добрий день! Ми хочемо взяти собаку з притулку.'),
                ('Volonterka', 'Divno! Ovaj crni je mužjak, ima tri godine.', 'Чудово! Цей чорний — самець, йому три роки.'),
                ('Daša', 'A onaj mali u boksu?', 'А он той маленький у вольєрі?'),
                ('Volonterka', 'To je ženka, Bela. Bila je lutalica, pa je malo plašljiva.', 'Це самка, Бела. Вона була безпритульною, тож трохи полохлива.'),
                ('Daša', 'Jadna! Smijemo li je prošetati?', 'Бідолашна! Можна нам її вигуляти?'),
                ('Volonterka', 'Naravno. Ako vam se svidi, Bela dobiva novi dom.', 'Звісно. Якщо вона вам сподобається, Бела отримає новий дім.'),
                ('Daša', 'Svaki pas zaslužuje drugu šansu.', 'Кожен собака заслуговує на другий шанс.'),
            ]),
            ('Загублений собака', 'Izgubljeni pas', [
                ('Darja', 'Susjede, jeste li vidjeli ovog psa? Izgubljen je.', 'Сусіде, ви не бачили цього собаки? Він загубився.'),
                ('Susjed', 'Mislim da jesam. Jutros je jedan pas zalutao u naše dvorište.', 'Здається, бачив. Сьогодні вранці якийсь собака заблукав у наше подвір’я.'),
                ('Darja', 'Stvarno? Je li imao ogrlicu?', 'Справді? На ньому був нашийник?'),
                ('Susjed', 'Imao je. Nahranio sam ga i nazvao sklonište za životinje.', 'Був. Я його нагодував і подзвонив у притулок для тварин.'),
                ('Darja', 'Hvala vam! Je li sada u skloništu?', 'Дякую вам! Він зараз у притулку?'),
                ('Susjed', 'Da, tamo je na sigurnom. Pronađeni psi čekaju vlasnika.', 'Так, там він у безпеці. Знайдені собаки чекають на власника.'),
                ('Darja', 'Idem odmah! Moj Bruno će me sigurno prepoznati.', 'Іду негайно! Мій Бруно мене точно впізнає.'),
            ]),
        ],
        fill=('Želim udomiti ___ psa, a ne onog.', 'ovog', ['ovaj', 'ova', 'ovo']),
        build=[('Цей собака загубився.', 'Ovaj pas je izgubljen.'), ('Ми хочемо взяти кішку з притулку.', 'Želimo udomiti mačku.')],
        listen=['Ovaj crni je mužjak, ima tri godine.', 'Je li imao ogrlicu?'],
        speak=[('Ми хочемо взяти собаку з притулку.', 'Želimo udomiti psa.'), ('Ви не бачили цього собаки?', 'Jeste li vidjeli ovog psa?')],
        write=dict(
            situation='Ви знайшли на вулиці собаку без власника. Напишіть у чат району: де знайшли, який він, і попросіть власника зателефонувати.',
            points=[('ви знайшли собаку', [['našl', 'ps'], ['našao', 'ps'], ['pronađen']]),
                    ('який він', [['mal'], ['velik'], ['crn'], ['bijel'], ['smeđ'], ['siv']]),
                    ('власник, зателефонуйте', [['vlasni']])],
            hints=['našla sam psa', 'mali', 'crni', 'vlasnik', 'nazovite me'],
            models=['Našla sam psa u parku! Mali je i crni. Vlasniče, nazovite me!',
                    'Pronađen pas kod škole! Velik je i bijel. Neka me vlasnik nazove.']),
        mediation=dict(
            source='IZGUBLJEN PAS!\nIme: Bruno. Mali, smeđi, s crvenom ogrlicom.\nNagrada za pronalazača! Tel. 098 123 456',
            friend='Що тут написано?',
            points=[('загубився собака Бруно', [['загуб', 'бруно']]),
                    ('маленький, коричневий', [['коричнев'], ['малень']]),
                    ('є винагорода', [['винагород'], ['нагород']])],
            models=['Загубився собака на ім’я Бруно. Він маленький, коричневий, із червоним нашийником. '
                    'Тому, хто знайде, обіцяють винагороду.'])),
]
