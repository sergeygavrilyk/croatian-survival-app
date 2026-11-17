"""
Дублі A1 · 2026-11-17 — дані для scripts/gen_a1_dupes.py (план docs/proposals/2026-11-16_lesson_duplicates.md, PR 3).

Рішення власника 2026-11-17 (дослівно — docs/DECISIONS.md):
  A1-105 «Надзвичайні ситуації» → модуль A1.8 «Здоров’я», одразу після «Здоровий спосіб життя» (стане уроком 76; 76–104 → 77–105);
  Д2  — урок 101 «Навчання й мовні курси» = запис на курс і перше заняття: прибрати polagati, položiti, svjedodžba, uvjerenje,
        priznavanje (іспит і визнання — в A2-11, A2-12, A2-13); діалог «Poslije ispita» → «Prvi sat»;
  Д3  — урок 54 «Договір і зарплата»: прибрати bruto, neto, porez, doprinosi, platna lista (зарплату пояснює A2-34);
        діалог «Prva plaća» → «Pitanja o ugovoru»;
  Д13 — урок 93 «Дубровник і Спліт: історія й архітектура»: прибрати katedrala, zidine (вони в A0 «Старе місто»);
  Д12 — урок 70 «В аптеці: як приймати ліки»: прибрати tableta, lijek protiv bolova (аптека A0) — дозування й форми ліків;
  A1.11 «Хорватська культура» — +3 уроки: «Символи й винаходи», «Фестивалі й карнавали», «Казки й легенди» (теми — «окей»).
Назви діалогів (§5 плану): однакова назва → перейменовуємо діалог у пізнішому уроці; тексти прочитано — зміст різний
(лише сценарій «спортзал» в уроці 67 схожий на A0, але слова інші — органи), тому лише назва.

Слово не зникає з курсу (принцип 1): svjedodžba → A2-11 «Визнання диплома»; porez, platna lista → A2-34 «Зарплата»
(там лише bruto plaća, neto plaća, porez na dohodak); polagati, položiti — уже в A2-12, uvjerenje — в A2-13.
bruto, neto, doprinosi, priznavanje, lijek protiv bolova — лише в словнику (в A2-34 — bruto plaća, neto plaća,
mirovinski doprinos; в A2-11 — priznavanje diplome; в A0 «В аптеці» — lijek, protiv bolova).
upisati se, test razine, početni tečaj — з A2-9 «Курси для дорослих» в A1-101 (запис на курс — зміст A1-101; з A2-9 їх приберемо в PR 4).

Формат: заміна слова — на тому самому місці уроку (lesson_items.item_id), нове слово — (лема, переклад, частина мови,
рід / вид, приклад[, ознаки]); заміна вправи — за відповіддю старої вправи (тип той самий, місце те саме).
Імена — частіше Даша / Дар’я.
"""

DATE = '20261117'

# Слова словника, яких немає в жодному уроці (переклад, рівень — з робочої бази 2026-11-17): рівень → A1
EXISTING = {
    'kravata': ('краватка', 'A1'), 'vojnik': ('солдат', 'A2'), 'izum': ('винахід', 'B1'), 'izumitelj': ('винахідник', 'B1'),
    'znanstvenik': ('науковець', 'B1'), 'otkriće': ('відкриття', 'B1'), 'slavan': ('славетний', 'B1'), 'ponos': ('гордість', 'A1'),
    'ples': ('танець', 'A2'), 'šala': ('жарт', 'A2'), 'smijeh': ('сміх', 'A2'),
    'priča': ('розповідь, історія', 'A1'), 'junak': ('герой', 'B1'), 'hrabar': ('сміливий', 'B1'), 'zlo': ('зло', 'B1'),
    'rječnik': ('словник', 'A1'), 'vježba': ('вправа / тренування', 'A1'), 'ugovor o radu': ('трудовий договір', 'B1'),
}
# Слова уроку A2-9 «Курси для дорослих», які тепер учать в A1-101 (рівень → A1)
FROM_A2_9 = {'upisati se': 'записатися', 'test razine': 'тест на рівень', 'početni tečaj': 'курс для початківців'}
# Слова, прибрані з уроків A1, які тепер учать лише в A2 (рівень → A2)
TO_A2 = {'polagati': 'A2-12', 'položiti': 'A2-12', 'uvjerenje': 'A2-13', 'svjedodžba': 'A2-11', 'porez': 'A2-34', 'platna lista': 'A2-34'}
# Слова, яких не було в A2-11 / A2-34: додаємо в кінець уроку
A2_ADD = {
    'dd6c5f39-f66e-5acb-8255-932f822ddcc5': ('A2 урок 11 «Визнання диплома»', ['svjedodžba']),
    'b9bcea21-08a3-56cf-be72-edf6b6c7b03f': ('A2 урок 34 «Зарплата: бруто, нето, податки»', ['porez', 'platna lista']),
}
# Прибрані слова, які лишаються лише в словнику (в уроках — ширші вирази)
DICT_ONLY = ['bruto', 'neto', 'doprinosi', 'priznavanje', 'lijek protiv bolova']

# Нові слова (їх немає в словнику): лема, переклад, частина мови, рід / вид, приклад[, ознаки usage_tags]
NEW_LEXEMES = {
    54: [
        ('potpisati ugovor', 'підписати договір', 'ph', '', 'Sutra idem potpisati ugovor u novoj firmi.'),
        ('raditi vikendom', 'працювати у вихідні', 'ph', '', 'U trgovini često moram raditi vikendom.'),
        ('opis posla', 'опис посадових обов’язків', 'ph', 'm', 'U oglasu piše kratak opis posla.'),
        ('uvjeti rada', 'умови праці', 'ph', 'm_pl', 'Uvjeti rada u ovoj tvrtki su jako dobri.'),
    ],
    70: [
        ('prije jela', 'перед їжею', 'ph', '', 'Sirup uzimajte tri puta dnevno prije jela.'),
        ('dvaput dnevno', 'двічі на день', 'ph', '', 'Kapi stavljajte dvaput dnevno, ujutro i navečer.'),
    ],
    93: [
        ('gotički', 'готичний', 'adj', '', 'Gotičke crkve imaju visoke tornjeve i velike prozore.'),
        ('renesansni', 'ренесансний', 'adj', '', 'U starom gradu ima mnogo renesansnih palača.'),
    ],
    'symbols': [
        ('simbol', 'символ', 'n', 'm', 'Licitarsko srce je simbol Zagreba.'),
        ('šahovnica', 'шахівниця (червоно-білий хорватський герб)', 'n', 'f', 'Na dresu reprezentacije je crveno-bijela šahovnica.'),
        ('grb', 'герб', 'n', 'm', 'Na hrvatskom grbu je dvadeset pet polja.'),
        ('crveno-bijeli', 'червоно-білий', 'adj', '', 'Navijači su nosili crveno-bijele majice.'),
        ('vezati kravatu', 'зав’язувати краватку', 'ph', '', 'Tata me naučio vezati kravatu.'),
        ('Dan kravate', 'День краватки (18 жовтня)', 'ph', 'm', 'Osamnaestog listopada slavimo Dan kravate.'),
        ('marama', 'хустка (на шию, на голову)', 'n', 'f', 'Oko vrata je nosila svilenu maramu.'),
        ('izumiti', 'винайти', 'v', 'pfv:izumljivati', 'Moj sin želi izumiti robota koji pere suđe.'),
        ('patent', 'патент', 'n', 'm', 'Izumitelj je prijavio patent za novi stroj.'),
        ('tehnička olovka', 'механічний олівець', 'ph', 'f', 'Za crtanje koristim tehničku olovku.'),
        ('nalivpero', 'авторучка (перова)', 'n', 'n', 'Ugovor je potpisao starim nalivperom.'),
        ('padobran', 'парашут', 'n', 'm', 'Skočio je iz aviona s padobranom.'),
        ('dalmatinac', 'далматинець (порода собак)', 'n', 'm', 'Naš susjed ima dalmatinca s crnim točkama.'),
        ('svjetski poznat', 'всесвітньо відомий', 'ph', '', 'Dubrovnik je svjetski poznat grad.'),
    ],
    'carnival': [
        ('karneval', 'карнавал', 'n', 'm', 'Riječki karneval je najveći u Hrvatskoj.'),
        ('maškare', 'маскарад; ряджені (на карнавалі)', 'n', 'f_pl', 'Djeca jedva čekaju maškare u vrtiću.', ['italianism']),
        ('poklade', 'карнавальні дні перед Великим постом (масниця)', 'n', 'f_pl', 'Za vrijeme poklada ljudi se maskiraju i zabavljaju.'),
        ('Pepelnica', 'Попільна середа (початок Великого посту)', 'n', 'f', 'Na Pepelnicu završavaju poklade.'),
        ('kostim', 'костюм (карнавальний, сценічний)', 'n', 'm', 'Mama mi je sašila kostim za maškare.'),
        ('maskirati se', 'перевдягатися (на карнавал), маскуватися', 'v', 'biasp', 'Na maškare se svi u uredu maskiramo.'),
        ('prerušiti se', 'перевдягнутися (в когось)', 'v', 'pfv:prerušavati se', 'Brat se prerušio u policajca.'),
        ('gusar', 'пірат', 'n', 'm', 'Sin želi kostim gusara s crnim šeširom.'),
        ('povorka', 'хода, процесія', 'n', 'f', 'Karnevalska povorka prolazi glavnom ulicom.'),
        ('zvončari', 'дзвонарі (ряджені з дзвонами з околиць Рієки)', 'n', 'm_pl', 'Zvončari zimi obilaze sela oko Rijeke.'),
        ('ovčja koža', 'овеча шкура', 'ph', 'f', 'Zvončari nose ovčje kože i velika zvona.'),
        ('rog', 'ріг', 'n', 'm', 'Maska ima dva velika roga.'),
        ('tjerati', 'проганяти, гнати', 'v', 'ipfv:otjerati', 'Kažu da buka zvona tjera zle duhove.'),
        ('spaliti', 'спалити', 'v', 'pfv:spaljivati', 'Na kraju karnevala ljudi spale veliku lutku.'),
        ('maskenbal', 'бал-маскарад', 'n', 'm', 'U subotu idemo na maskenbal u hotelu.', ['germanism']),
        ('konfeti', 'конфеті', 'n', 'm_pl', 'Djeca bacaju konfete po ulici.'),
        ('bubanj', 'барабан', 'n', 'm', 'Dječak glasno udara u bubanj.'),
        ('nastupati', 'виступати (на сцені)', 'v', 'ipfv:nastupiti', 'Na festivalu nastupaju bendovi iz cijele Europe.'),
        ('šaliti se', 'жартувати', 'v', 'ipfv:našaliti se', 'Ne ljuti se, samo se šalim!'),
    ],
    'tales': [
        ('legenda', 'легенда', 'n', 'f', 'Prema legendi, u ovoj špilji živio je zmaj.'),
        ('pripovijedati', 'розповідати (історію, казку)', 'v', 'ipfv:ispripovijedati', 'Baka nam je pripovijedala stare priče.'),
        ('bilo jednom', 'колись давно; жили-були (початок казки)', 'ph', '', 'Bilo jednom jedno malo selo pokraj velike šume.'),
        ('za laku noć', 'на ніч (казка, поцілунок)', 'ph', '', 'Svaku večer čitam kćeri priču za laku noć.'),
        ('kraljević', 'королевич, принц', 'n', 'm', 'Kraljević je jahao na bijelom konju.'),
        ('kraljevna', 'королівна, принцеса', 'n', 'f', 'Kraljevna je živjela u visokom tornju.'),
        ('vila', 'фея; вілла', 'n', 'f', 'Dobra vila pomogla je siromašnoj djevojci.'),
        ('zmaj', 'дракон; повітряний змій', 'n', 'm', 'Zmaj je čuvao zlato u planini.'),
        ('vještica', 'відьма', 'n', 'f', 'Zla vještica živjela je duboko u šumi.'),
        ('div', 'велетень', 'n', 'm', 'Regoč je div iz priče Ivane Brlić-Mažuranić.'),
        ('patuljak', 'гном, карлик', 'n', 'm', 'Snjeguljica je živjela sa sedam patuljaka.'),
        ('čarobni', 'чарівний, магічний', 'adj', '', 'Starac mu je dao čarobni prsten.'),
        ('čarolija', 'чари, заклинання', 'n', 'f', 'Vještica je tiho izgovorila čaroliju.'),
        ('začarati', 'зачарувати', 'v', 'pfv:začaravati', 'Zla vila začarala je cijeli dvorac.'),
        ('pretvoriti se', 'перетворитися', 'v', 'pfv:pretvarati se', 'Žaba se pretvorila u lijepog kraljevića.'),
        ('zao', 'злий', 'adj', '', 'U priči je bio jedan zao čarobnjak.'),
        ('dobrota', 'доброта', 'n', 'f', 'Kraljevnu su svi voljeli zbog njezine dobrote.'),
        ('pouka', 'мораль, повчання (казки)', 'n', 'f', 'Pouka ove priče je da treba govoriti istinu.'),
        ('sretan kraj', 'щасливий кінець', 'ph', 'm', 'Volim filmove sa sretnim krajem.'),
    ],
}
FORMULAIC = {'bilo jednom', 'za laku noć'}
INTERFERENCE = {
    'dalmatinac': 'з малої — порода собак; Dalmatinac з великої — житель Далмації',
    'vila': 'два значення: «фея» (у казці) і «вілла» (будинок)',
    'zmaj': 'ще й «повітряний змій» (puštati zmaja)',
    'pretvoriti se': 'видова пара pretvarati se має ще значення «прикидатися»',
    'kostim': 'діловий костюм — odijelo; kostim — карнавальний, сценічний; kupaći kostim — купальник',
    'div': 'не «диво»: div — велетень (čudo — диво)',
    'pouka': 'не «наука»: pouka — мораль, повчання казки',
}

LESSON_IDS = {
    54: '4d6f3498-2cc5-54a0-b4e4-c66add71ef12', 70: '123e68fa-291f-5ad6-8403-51db7020d641', 93: 'd9ef1de4-f4db-590e-bafd-474f84c8e03f',
    101: '11b565a4-1e2a-50d2-8d9d-c05e84371402', 105: '692e9310-7a5b-5adf-9f0a-a66b72fc5459',
}
UNITS = {8: '2eec2289-6a8a-5fb2-9988-e52433d5a242', 11: '1fb51162-343f-5587-89cf-d2594a3091db', 12: 'e0fc94e0-c41d-5f59-adf7-db0c97c4575c'}
MOVE = dict(lesson=105, to_module=8, to_order=11)   # A1-105 → A1.8, місце 11 (після «Здоровий спосіб життя»)

# ---------------------------------------------------------------------------------------------- зміни наявних уроків
# swap — (стара лема, нова лема) на тому самому місці; conv — (id старого діалогу, новий діалог); ex — (відповідь старої
# вправи, нова вправа); вправа: type, question, answer, options (для вибору), word (лема — для вправ на слово).
# Вправа з тим самим питанням і відповіддю — лише нові хибні варіанти (серед старих було прибране слово).
CHANGES = {
    54: dict(
        note='Д3',
        objectives=['Розпитати про договір: na određeno, na neodređeno, probni rad, otkazni rok',
                    'Поставити питання перед підписанням: «Moram li raditi vikendom?», «Gdje je opis posla?»',
                    'Модальні дієслова: moram, ne moraš, smijem li…'],
        swap=[('bruto', 'potpisati ugovor'), ('neto', 'raditi vikendom'), ('porez', 'ugovor o radu'), ('doprinosi', 'opis posla'),
              ('platna lista', 'uvjeti rada')],
        conv=('d683d4c9-6d44-5479-966f-dfd350782ec6',
              ('Запитання про договір', 'Pitanja o ugovoru', 'work', [
                  ('Daša', 'Prije nego što potpišem ugovor, imam nekoliko pitanja.', 'Перш ніж я підпишу договір, у мене є кілька запитань.'),
                  ('Gospodin Babić', 'Naravno, slobodno pitajte.', 'Звісно, питайте.'),
                  ('Daša', 'Moram li raditi vikendom?', 'Чи мушу я працювати у вихідні?'),
                  ('Gospodin Babić', 'Samo jednu subotu u mjesecu, a prekovremeni sati plaćaju se posebno.',
                   'Лише одну суботу на місяць, а понаднормові години оплачуються окремо.'),
                  ('Daša', 'Gdje mogu vidjeti opis posla i uvjete rada?', 'Де я можу подивитися опис обов’язків і умови праці?'),
                  ('Gospodin Babić', 'U ugovoru o radu, na drugoj stranici. Kad pročitate, potpišite ovdje.',
                   'У трудовому договорі, на другій сторінці. Коли прочитаєте, підпишіть ось тут.'),
              ])),
        ex=[('doprinosi', dict(type='multiple_choice', question='Як хорватською «працювати у вихідні»?', answer='raditi vikendom',
                               options=['raditi vikendom', 'probni rad', 'regres', 'otkazni rok'], word='raditi vikendom')),
            ('platna lista', dict(type='type_answer', question='Напишіть хорватською: «опис посадових обов’язків»', answer='opis posla',
                                  word='opis posla')),
            ('porez', dict(type='type_answer', question='Напишіть хорватською: «умови праці»', answer='uvjeti rada', word='uvjeti rada')),
            ('Kada je isplata?', dict(type='listening', question='Прослухайте і складіть фразу', answer='Moram li raditi vikendom?')),
            ('Kolika je neto plaća?', dict(type='speaking', question='Де мені підписати договір?', answer='Gdje da potpišem ugovor?')),
            ('зміна (на роботі)', dict(type='multiple_choice', question='Що означає «smjena»?', answer='зміна (на роботі)',
                                        options=['відпускні (виплата до відпустки)', 'випробувальний термін',
                                                 'строк попередження про звільнення', 'зміна (на роботі)'], word='smjena')),
            ('строковий договір', dict(type='multiple_choice', question='Що означає «ugovor na određeno»?', answer='строковий договір',
                                       options=['строковий договір', 'різдвяна премія', 'понаднормові години', 'випробувальний термін'],
                                       word='ugovor na određeno'))],
    ),
    70: dict(
        note='Д12',
        swap=[('lijek protiv bolova', 'prije jela'), ('tableta', 'dvaput dnevno')],
        ex=[('знеболювальне', dict(type='multiple_choice', question='Що означає «prije jela»?', answer='перед їжею',
                                   options=['перед їжею', 'мазь', 'побічна дія', 'краплі'], word='prije jela')),
            ('tableta', dict(type='multiple_choice', question='Як хорватською «двічі на день»?', answer='dvaput dnevno',
                             options=['dvaput dnevno', 'natašte', 'kapsula', 'doza'], word='dvaput dnevno')),
            ('брати; приймати (ліки)', dict(type='multiple_choice', question='Що означає «uzimati»?', answer='брати; приймати (ліки)',
                                             options=['спрей для носа', 'проковтнути', 'натщесерце', 'брати; приймати (ліки)'], word='uzimati')),
            ('без рецепта', dict(type='multiple_choice', question='Що означає «bez recepta»?', answer='без рецепта',
                                 options=['капсула', 'без рецепта', 'розчинити', 'доза'], word='bez recepta')),
            ('otopiti', dict(type='multiple_choice', question='Як хорватською «розчинити»?', answer='otopiti',
                             options=['mast', 'kapi', 'uzimati', 'otopiti'], word='otopiti'))],
    ),
    93: dict(
        note='Д13',
        swap=[('zidine', 'gotički'), ('katedrala', 'renesansni')],
        objectives=['Розповісти про Дубровник і Спліт: tvrđava, toranj, gradska vrata, palača',
                    'Назвати стилі: srednjovjekovni, gotički, renesansni, barokni',
                    'Минулий час: šetala sam, izgradili su'],
        ex=[('міські мури', dict(type='multiple_choice', question='Що означає «gotički»?', answer='готичний',
                                 options=['готичний', 'бароковий', 'вуличка', 'руїни'], word='gotički')),
            ('Kada su izgradili ove zidine?', dict(type='speaking', question='Ця церква готична.', answer='Ova crkva je gotička.'))],
    ),
    101: dict(
        note='Д2',
        swap=[('polagati', 'upisati se'), ('položiti', 'test razine'), ('uvjerenje', 'početni tečaj'), ('svjedodžba', 'rječnik'),
              ('priznavanje', 'vježba')],
        objectives=['Записатися на мовний курс: razina, test razine, početni tečaj, intenzivni tečaj',
                    'Перше заняття: učionica, vježba, rječnik, gradivo',
                    'Родовий відмінок: tečaj hrvatskog, od rujna do prosinca'],
        conv=('8334cf71-db86-5617-87b7-e8a7d9921162',
              ('Перше заняття', 'Prvi sat', 'small_talk', [
                  ('Profesorica', 'Dobro došli na početni tečaj! Ja sam vaša profesorica Ana.',
                   'Ласкаво просимо на курс для початківців! Я ваша викладачка Ана.'),
                  ('Daša', 'Dobar dan! Upisala sam se jučer, ali još nemam udžbenik.', 'Добрий день! Я записалася вчора, але ще не маю підручника.'),
                  ('Profesorica', 'Nema problema, danas radimo vježbe na listićima.', 'Нічого страшного, сьогодні робимо вправи на аркушах.'),
                  ('Daša', 'Smijem li koristiti rječnik na mobitelu?', 'Можна користуватися словником у телефоні?'),
                  ('Profesorica', 'Smijete, ali prvo pokušajte bez njega. Sljedeći sat je u četvrtak.',
                   'Можна, але спершу спробуйте без нього. Наступне заняття — у четвер.'),
                  ('Daša', 'Dobro, hvala! Vidimo se u četvrtak.', 'Добре, дякую! Побачимося в четвер.'),
              ])),
        ex=[('свідоцтво (про закінчення курсу); довідка',
             dict(type='multiple_choice', question='Що означає «test razine»?', answer='тест на рівень',
                  options=['тест на рівень', 'стипендія', 'лекція', 'клас, аудиторія'], word='test razine')),
            ('priznavanje', dict(type='type_answer', question='Напишіть хорватською: «словник»', answer='rječnik', word='rječnik')),
            ('Položila sam ispit.', dict(type='sentence_builder', question='Складіть: «Я записалася на курс для початківців.»',
                                          answer='Upisala sam se na početni tečaj.')),
            ('Dobivam li uvjerenje na kraju?', dict(type='listening', question='Прослухайте і складіть фразу',
                                                     answer='Onda prvo napišite kratki test.')),
            ('Bravo! Što ćeš sada?', dict(type='listening', question='Прослухайте і складіть фразу',
                                          answer='Smijem li koristiti rječnik na mobitelu?')),
            ('просунутий (рівень)', dict(type='multiple_choice', question='Що означає «napredni»?', answer='просунутий (рівень)',
                                         options=['навчальний матеріал', 'початківець', 'слухач (курсу)', 'просунутий (рівень)'],
                                         word='napredni')),
            ('заняття; навчання (уроки)', dict(type='multiple_choice', question='Що означає «nastava»?', answer='заняття; навчання (уроки)',
                                                options=['клас, аудиторія', 'стипендія', 'рівень', 'заняття; навчання (уроки)'], word='nastava')),
            ('predavanje', dict(type='multiple_choice', question='Як хорватською «лекція»?', answer='predavanje',
                                options=['učionica', 'gradivo', 'nastava', 'predavanje'], word='predavanje')),
            ('početnik', dict(type='multiple_choice', question='Як хорватською «початківець»?', answer='početnik',
                              options=['gradivo', 'stipendija', 'polaznik', 'početnik'], word='početnik'))],
    ),
}

# Однакові назви діалогів (§5 плану): нова назва діалогу в пізнішому уроці (id → (title_ua, title_hr))
RENAME_CONVS = {
    '1515f889-130f-5476-8851-938106d3700a': ('A1 5', 'Na igralištu', ('Гірка й гойдалка', 'Tobogan i ljuljačka')),
    '6a218fb4-4e02-5825-8744-f5d9813cffa4': ('A1 35', 'U taksiju', ('Найкоротшим шляхом', 'Najkraćim putem')),
    '1344654b-470d-5676-b47e-b0001240b17d': ('A1 40', 'Razgledavanje stana', ('Квартира з мансардою', 'Stan s potkrovljem')),
    '514923a7-f17e-52bd-bf86-ddfff3e51b51': ('A1 42', 'U trgovini namještajem', ('Кутовий диван зі знижкою', 'Garnitura na akciji')),
    '14858aec-7921-527f-b3c3-e839da3fb494': ('A1 50', 'Tko što radi?', ('Хто де працює?', 'Tko gdje radi?')),
    '0a6b020d-ea8a-52dd-9cba-22cda92936e5': ('A1 53', 'Razgovor za posao', ('Де ви працювали раніше?', 'Gdje ste radili prije?')),
    'fe918e0d-21ff-5dc9-b37a-fbf2af2bfccd': ('A1 67', 'Poslije treninga', ('М’язи й суглоби', 'Mišići i zglobovi')),
    'b2e86525-a790-5cf3-87ce-734d9e063a43': ('A1 78', 'Poziv na rođendan', ('Приходь на мій день народження!', 'Dođi na moj rođendan!')),
    'b9fa04a2-e778-57c5-95d9-106b6058ad98': ('A1 106', 'Razgovor za posao', ('Розкажіть про себе', 'Recite nam nešto o sebi')),
}

# ---------------------------------------------------------------------------------------------- нові уроки A1.11 (місця 6–8)
NEW_LESSONS = [
    dict(
        slug='symbols', order=6, title=('Символи й винаходи', 'Simboli i izumi'), situation='small_talk', grammar='Побудова питань',
        objectives=['Назвати символи Хорватії: šahovnica, grb, kravata, dalmatinac',
                    'Розповісти про хорватські винаходи: tehnička olovka, nalivpero, padobran',
                    'Поставити питання: Tko je izumio…? Odakle je…? Zašto se tako zove?'],
        words=['simbol', 'šahovnica', 'grb', 'crveno-bijeli', 'kravata', 'vezati kravatu', 'Dan kravate', 'marama', 'vojnik', 'izum',
               'izumitelj', 'izumiti', 'patent', 'tehnička olovka', 'nalivpero', 'padobran', 'znanstvenik', 'otkriće', 'dalmatinac',
               'slavan', 'svjetski poznat', 'ponos'],
        scenes=[
            ('Звідки краватка?', 'Odakle je kravata?', [
                ('Marko', 'Dašo, znaš li da je kravata hrvatski izum?', 'Дашо, знаєш, що краватка — хорватський винахід?'),
                ('Daša', 'Stvarno? Mislila sam da je iz Francuske.', 'Справді? Я думала, що вона з Франції.'),
                ('Marko', 'Hrvatski vojnici nosili su marame oko vrata, a Francuzi su ih tako nazvali.',
                 'Хорватські солдати носили хустки на шиї, а французи так їх і назвали.'),
                ('Daša', 'Zato se kravata tako zove?', 'Тому краватка так називається?'),
                ('Marko', 'Da, po Hrvatima. Osamnaestog listopada je Dan kravate.', 'Так, на честь хорватів. Вісімнадцятого жовтня — День краватки.'),
                ('Daša', 'Onda ću tati kupiti kravatu. Ali ne znam je vezati!', 'Тоді куплю татові краватку. Але я не вмію її зав’язувати!'),
            ]),
            ('Хорватські винаходи', 'Hrvatski izumi', [
                ('Ana', 'Dobro došli! Ovdje su izumi poznatih hrvatskih znanstvenika i izumitelja.',
                 'Ласкаво просимо! Тут винаходи відомих хорватських учених і винахідників.'),
                ('Darja', 'Tko je izumio tehničku olovku?', 'Хто винайшов механічний олівець?'),
                ('Ana', 'Slavoljub Penkala. Imao je i patent za nalivpero.', 'Славолюб Пенкала. У нього був і патент на авторучку.'),
                ('Darja', 'A ovaj crtež? Izgleda kao padobran.', 'А цей малюнок? Схожий на парашут.'),
                ('Ana', 'Jest. Faust Vrančić nacrtao ga je prije više od četiristo godina.', 'Так. Фауст Вранчич намалював його понад чотириста років тому.'),
                ('Darja', 'Nevjerojatno! Na takva otkrića možete biti ponosni.', 'Неймовірно! Такими відкриттями можна пишатися.'),
            ]),
        ],
        fill=('___ je kravata? — Iz Hrvatske.', 'Odakle', ['Kada', 'Tko', 'Koliko']),
        build=[('Складіть: «Краватка — хорватський винахід.»', 'Kravata je hrvatski izum.'),
               ('Складіть: «Хто винайшов парашут?»', 'Tko je izumio padobran?')],
        listen=['Zato se kravata tako zove?', 'Tko je izumio tehničku olovku?'],
        speak=[('Я не вмію зав’язувати краватку.', 'Ne znam vezati kravatu.'), ('Звідки цей символ?', 'Odakle je ovaj simbol?')],
    ),
    dict(
        slug='carnival', order=7, title=('Фестивалі й карнавали', 'Festivali i karnevali'), situation='small_talk',
        grammar='Орудний відмінок: autobusom, s prijateljem',
        objectives=['Розповісти про карнавал: maškare, kostim, povorka, zvončari',
                    'Домовитися піти на карнавал чи фестиваль: «Idemo li na karneval?»',
                    'Орудний відмінок: s kolegama, s maskama, sa zvonima'],
        words=['karneval', 'maškare', 'poklade', 'Pepelnica', 'kostim', 'maskirati se', 'prerušiti se', 'gusar', 'povorka', 'zvončari',
               'ovčja koža', 'rog', 'tjerati', 'spaliti', 'maskenbal', 'konfeti', 'bubanj', 'ples', 'nastupati', 'šala', 'šaliti se',
               'smijeh'],
        scenes=[
            ('Підемо на карнавал?', 'Idemo na karneval?', [
                ('Daša', 'Darja, idemo li u nedjelju na Riječki karneval?', 'Дар’є, підемо в неділю на Рієцький карнавал?'),
                ('Darja', 'Može! Idem s kolegama s posla. Imaš li kostim?', 'Можна! Я йду з колегами з роботи. У тебе є костюм?'),
                ('Daša', 'Imam. Maskirat ću se u gusaricu s crnim šeširom.', 'Є. Я перевдягнуся на піратку в чорному капелюсі.'),
                ('Darja', 'A ja ću biti mačka, s ušima i repom.', 'А я буду кішкою, з вушками й хвостом.'),
                ('Daša', 'Super! Povorka kreće u podne, s bubnjevima i konfetima.', 'Чудово! Хода рушає опівдні, з барабанами й конфеті.'),
                ('Darja', 'Onda se nađemo u jedanaest ispred kazališta.', 'Тоді зустрінемося об одинадцятій перед театром.'),
            ]),
            ('Дзвонарі', 'Zvončari', [
                ('Marko', 'Dašo, čuješ li ova zvona? Dolaze zvončari!', 'Дашо, чуєш ці дзвони? Ідуть дзвонарі!'),
                ('Daša', 'Tko su zvončari?', 'Хто такі дзвонарі?'),
                ('Marko', 'Muškarci s velikim zvonima i maskama s rogovima. Nose ovčje kože.',
                 'Чоловіки з великими дзвонами й масками з рогами. Вони вдягнені в овечі шкури.'),
                ('Daša', 'Zašto toliko zvone?', 'Чому вони так дзвонять?'),
                ('Marko', 'To je stari običaj. Tjeraju zimu i zle duhove.', 'Це давній звичай. Вони проганяють зиму й злих духів.'),
                ('Daša', 'Malo su strašni, ali i smiješni!', 'Трохи страшні, але й кумедні!'),
            ]),
        ],
        fill=('Na karneval idem ___.', 's prijateljima', ['prijatelji', 'prijateljima', 's prijatelje']),
        build=[('Складіть: «Я перевдягнуся на пірата.»', 'Maskirat ću se u gusara.'),
               ('Складіть: «Хода йде головною вулицею.»', 'Povorka ide glavnom ulicom.')],
        listen=['A ja ću biti mačka, s ušima i repom.', 'Tko su zvončari?'],
        speak=[('Я йду на карнавал з колегами.', 'Idem na karneval s kolegama.'), ('Я просто жартую!', 'Samo se šalim!')],
    ),
    dict(
        slug='tales', order=8, title=('Казки й легенди', 'Bajke i legende'), situation='small_talk',
        grammar='Минулий час: radio sam, bila sam',
        objectives=['Назвати героїв казок: vila, zmaj, div, vještica, kraljević, kraljevna',
                    'Розповісти коротку казку в минулому часі: «Bilo jednom…», «spasio je…»',
                    'Знати «Priče iz davnine» Івани Брлич-Мажуранич (1916)'],
        words=['priča', 'legenda', 'pripovijedati', 'bilo jednom', 'za laku noć', 'junak', 'hrabar', 'kraljević', 'kraljevna', 'vila',
               'zmaj', 'vještica', 'div', 'patuljak', 'čarobni', 'čarolija', 'začarati', 'pretvoriti se', 'zao', 'zlo', 'dobrota', 'pouka',
               'sretan kraj'],
        scenes=[
            ('Казка на ніч', 'Priča za laku noć', [
                ('Mia', 'Mama, pročitaj mi priču za laku noć!', 'Мамо, прочитай мені казку на ніч!'),
                ('Daša', 'Može. Koju želiš, o zmaju ili o dobroj vili?', 'Добре. Яку хочеш: про дракона чи про добру фею?'),
                ('Mia', 'O zmaju! I neka ima sretan kraj.', 'Про дракона! І щоб був щасливий кінець.'),
                ('Daša', 'Bilo jednom jedno kraljevstvo. Zli zmaj oteo je kraljevnu.', 'Колись давно було одне королівство. Злий дракон викрав королівну.'),
                ('Mia', 'Je li ju hrabri kraljević spasio?', 'А сміливий королевич її врятував?'),
                ('Daša', 'Jest, i svi su živjeli sretno. A sada zatvori oči!', 'Так, і всі жили щасливо. А тепер заплющ очі!'),
            ]),
            ('Казки з давнини', 'Priče iz davnine', [
                ('Darja', 'Ivana, koju hrvatsku knjigu bajki da kupim kćeri?', 'Івано, яку хорватську книжку казок купити доньці?'),
                ('Ivana', '„Priče iz davnine“ Ivane Brlić-Mažuranić. Djeca ih vole već više od sto godina.',
                 '«Казки з давнини» Івани Брлич-Мажуранич. Діти люблять їх уже понад сто років.'),
                ('Darja', 'O čemu su te priče?', 'Про що ці казки?'),
                ('Ivana', 'O hrabrim junacima, vilama i divovima iz starih slavenskih legendi.',
                 'Про сміливих героїв, фей і велетнів зі старих слов’янських легенд.'),
                ('Darja', 'Imaju li te priče neku pouku?', 'У цих казок є якась мораль?'),
                ('Ivana', 'Imaju. Dobrota i hrabrost uvijek pobjeđuju zlo.', 'Так. Доброта й сміливість завжди перемагають зло.'),
            ]),
        ],
        fill=('Zmaj je ___ kraljevnu.', 'oteo', ['oteli', 'otela', 'oteti']),
        build=[('Складіть: «Фея перетворилася на пташку.»', 'Vila se pretvorila u pticu.'),
               ('Складіть: «Королевич урятував королівну.»', 'Kraljević je spasio kraljevnu.')],
        listen=['Je li ju hrabri kraljević spasio?', 'O čemu su te priče?'],
        speak=[('Прочитай мені казку на ніч!', 'Pročitaj mi priču za laku noć!'), ('Яка мораль цієї казки?', 'Koja je pouka ove priče?')],
    ),
]
