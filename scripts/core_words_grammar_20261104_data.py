"""
Дані пакета 2026-11-04 (аудит A0 + A1, рішення власника 2026-11-04): базові слова в уроки, нові правила граматики,
довші пояснення з 4–5 прикладами. Генератор — scripts/gen_core_words_grammar_20261104.py (не редагуйте SQL вручну).

Звіт аудиту — content/reviews/2026-11-04_a0_a1_audit.md. Усе — бета (як A0 / A1), потрібна перевірка носієм.
"""

# ---------------------------------------------------------------- 1. Базові слова → урок, де вони вже звучать у діалогах
# Лема → (id уроку, назва уроку для звіту). Порядок у списку слів уроку — після наявних слів.
LESSONS = {
    'c0000000-0000-0000-0000-000000000001': 'A0.1 Привітання та подяка',
    'd8cffb46-8a62-538a-b864-e227a6d8b863': 'A0.1 Добрий день і до побачення',
    'a17f2f16-1be9-50f2-8e16-2bebfcced33b': 'A0.1 Вибачте, я не розумію',
    'e704760a-f743-5762-9c1a-027b10ca030a': 'A0.1 Ввічливі слова',
    '2b6ed342-cc80-5bd9-baf0-b66109624d62': 'A0.2 Як тебе звати?',
    '04167753-db83-5163-a91c-9f71dac18ab5': 'A0.2 Звідки ви?',
    '8f6439a9-c6ac-5271-99c8-1f0adc5d7599': 'A0.2 Питальні слова',
    '2fa5fa38-9641-5dc5-9156-6a3f7fe8035b': 'A0.2 Ким ви працюєте?',
    '3b51b1bf-47f4-5709-96d9-c518d36440e6': 'A0.2 Як ви почуваєтеся?',
    '22dd7878-4fa8-5e1c-909e-71c70ffd9918': 'A0.3 Приблизно, половина, відсотки',
    '036fc4fb-1bf2-5100-9fd0-6f6a612554a1': 'A0.4 Місяці й пори року',
    'd7cf3059-0d92-5215-8ef4-ad699e317b10': 'A0.4 Свята й привітання',
    '4e003796-1ce0-5a02-8a2d-59a0de38f3dd': 'A0.5 Моя сім’я',
    '2b0e9742-99e1-57e1-a574-67ffb78d2607': 'A0.5 Діти й друзі',
    '78f28f85-dd8b-5e81-8a52-1b2dbce4eb34': 'A0.6 Моя квартира',
    '4bf48151-be83-5108-bc92-645c0603a1a3': 'A1.1 Мій звичайний день',
    '959e879f-a28d-5bed-9c09-16cff91ef456': 'A1.1 Як часто?',
    'd43d6c65-1ce3-5c72-9ecd-cce2ed200fc2': 'A1.1 З дитиною вдома',
    '63a4a6d8-1cae-5e0e-90ff-98efcfe8b4c7': 'A1.1 Сон і відпочинок',
    'ad0bc1f4-2808-5b24-969d-9da64d4a7a4d': 'A1.1 Корисні слова: навіть, саме, знову, ще не',
    'b369f01f-4a84-57b4-98cb-150d236f4d7f': 'A1.6 Професії: хто де працює',
    'd813e9c0-2331-59d8-90f1-cea7e9a61c7d': 'A1.6 Мій робочий день',
    '1c16ceee-5f42-536a-98b4-7dcabaa3be6d': 'A1.9 Хобі',
    '3f440ad8-f057-5898-b773-6aa8816fa8a3': 'A1.9 Хтось, щось, десь',
    'dbb91fa1-4a97-5c04-99a8-8ac1d508b952': 'A1.13 Нове життя: мої плани',
}

# Слово: lemma, pos, cefr (до вирівнювання), переклад, vocabulary_type, forms, examples, урок.
# Рядки вже є в робочій базі (тут — для локальної бази / CI: insert … on conflict do nothing);
# fix_tr / fix_ex — виправлення перекладу чи прикладу, які застосовуються і в робочій базі (нова версія).
WORDS = [
    # A0.1
    dict(lemma='puno', pos='adverb', tr='багато', vt='function_word', forms={},
         ex=['Ovdje ima puno ljudi.', 'Puno hvala na pomoći!'], lesson='c0000000-0000-0000-0000-000000000001'),
    dict(lemma='tako', pos='adverb', tr='так, таким чином', vt='core', forms={},
         ex=['Nemoj tako brzo voziti!'], lesson='c0000000-0000-0000-0000-000000000001',
         fix_ex=['Nemoj tako brzo voziti!', 'Tako je, imaš pravo.']),
    dict(lemma='vidjeti', pos='verb', tr='бачити', vt='core',
         forms={'past': 'vidio', 'aspect': 'biasp', 'present': {'1s': 'vidim', '2s': 'vidiš', '3s': 'vidi'}},
         ex=['Ne vidim dobro.', 'Jesi li vidjela moje ključeve?'], lesson='d8cffb46-8a62-538a-b864-e227a6d8b863'),
    dict(lemma='čuti', pos='verb', tr='чути', vt='core',
         forms={'aspect': 'biasp', 'present': {'1s': 'čujem', '2s': 'čuješ', '3s': 'čuje'}},
         ex=['Čuješ li me?', 'Ne čujem te dobro, govori glasnije.'], lesson='d8cffb46-8a62-538a-b864-e227a6d8b863'),
    dict(lemma='reći', pos='verb', tr='сказати', vt='core',
         forms={'past': 'rekao', 'aspect': 'pfv', 'present': {'1s': 'kažem', '2s': 'kažeš', '3s': 'kaže'}},
         ex=['Što si rekao?', 'Kako se kaže...?'], lesson='a17f2f16-1be9-50f2-8e16-2bebfcced33b',
         fix_ex=['Što si rekao?', 'Možete li mi reći gdje je pošta?']),
    dict(lemma='ili', pos='conjunction', tr='або; чи', vt='function_word', forms={},
         ex=['Kava ili čaj?'], lesson='e704760a-f743-5762-9c1a-027b10ca030a',
         fix_tr='або; чи', fix_ex=['Kava ili čaj?', 'Platit ću karticom ili gotovinom.']),
    dict(lemma='problem', pos='noun', tr='проблема', vt='core', forms={'gender': 'm', 'plural': 'problemi'},
         ex=['Imamo mali problem.', 'Nema problema.'], lesson='e704760a-f743-5762-9c1a-027b10ca030a'),
    # A0.2
    dict(lemma='dobar', pos='adjective', tr='хороший, добрий', vt='core', forms={'f': 'dobra', 'n': 'dobro'},
         ex=['Ovo je dobar restoran.', 'Kava je dobra.'], lesson='2b6ed342-cc80-5bd9-baf0-b66109624d62',
         fix_tr='хороший; добрий'),
    dict(lemma='pisati', pos='verb', tr='писати', vt='core',
         forms={'past': 'pisao', 'aspect': 'ipfv',
                'present': {'1s': 'pišem', '2s': 'pišeš', '3s': 'piše', '1p': 'pišemo', '2p': 'pišete', '3p': 'pišu'}},
         ex=['Pišem poruku prijatelju.'], lesson='2b6ed342-cc80-5bd9-baf0-b66109624d62',
         fix_ex=['Pišem poruku prijatelju.', 'Kako se piše vaše prezime?']),
    dict(lemma='ali', pos='conjunction', tr='але', vt='function_word', forms={},
         ex=['Razumijem, ali ne govorim.'], lesson='04167753-db83-5163-a91c-9f71dac18ab5',
         fix_ex=['Razumijem, ali ne govorim.', 'Stan je mali, ali lijep.']),
    dict(lemma='kada', pos='adverb', tr='коли (також kad)', vt='function_word', forms={},
         ex=['Kada počinje predavanje?'], lesson='8f6439a9-c6ac-5271-99c8-1f0adc5d7599',
         fix_tr='коли (також kad)', fix_ex=['Kada počinje predavanje?', 'Javi mi kad stigneš.']),
    dict(lemma='kao', pos='conjunction', tr='як', vt='core', forms={},
         ex=['Govoriš hrvatski kao pravi Hrvat!'], lesson='2fa5fa38-9641-5dc5-9156-6a3f7fe8035b',
         fix_tr='як; у ролі (radim kao — працюю ким)',
         fix_ex=['Govoriš hrvatski kao pravi Hrvat!', 'Radim kao konobarica.']),
    dict(lemma='možda', pos='adverb', tr='можливо', vt='function_word', forms={},
         ex=['Možda ću doći sutra.', 'Možda je u pravu.'], lesson='2fa5fa38-9641-5dc5-9156-6a3f7fe8035b'),
    dict(lemma='loš', pos='adjective', tr='поганий', vt='core', forms={'f': 'loša', 'n': 'loše', 'plural': 'loši'},
         ex=['Danas je loše vrijeme.'], lesson='3b51b1bf-47f4-5709-96d9-c518d36440e6',
         fix_ex=['Danas je loše vrijeme.', 'Osjećam se loše.']),
    dict(lemma='trebati', pos='verb', tr='потребувати', vt='core',
         forms={'aspect': 'ipfv', 'present': {'1s': 'trebam', '2s': 'trebaš', '3s': 'treba'}},
         ex=['Trebam pomoć.', 'Što trebate?'], lesson='3b51b1bf-47f4-5709-96d9-c518d36440e6',
         fix_tr='потребувати; бути потрібним (treba mi — мені треба)'),
    dict(lemma='željeti', pos='verb', tr='бажати', vt='core', forms={'aspect': 'ipfv'},
         ex=['Što biste željeli popiti?'], lesson='3b51b1bf-47f4-5709-96d9-c518d36440e6',
         fix_tr='бажати; хотіти', fix_ex=['Što biste željeli popiti?', 'Želim ti sretan put!']),
    # A0.3–A0.6
    dict(lemma='sve', pos='pronoun', tr='все', vt='function_word', forms={},
         ex=['Sve je u redu.', 'Znam sve o tome.'], lesson='22dd7878-4fa8-5e1c-909e-71c70ffd9918', fix_tr='усе'),
    dict(lemma='topao', pos='adjective', tr='теплий', vt='core', forms={'f': 'topla', 'n': 'toplo', 'plural': 'topli'},
         ex=['Toplo more i sunčan dan.'], lesson='036fc4fb-1bf2-5100-9fd0-6f6a612554a1',
         fix_ex=['Danas je topao dan.', 'More je toplo u kolovozu.']),
    dict(lemma='važan', pos='adjective', tr='важливий', vt='core', forms={'f': 'važna', 'n': 'važno', 'plural': 'važni'},
         ex=['Imam važan sastanak u uredu.'], lesson='d7cf3059-0d92-5215-8ef4-ad699e317b10',
         fix_ex=['Imam važan sastanak u uredu.', 'Obitelj mi je jako važna.']),
    dict(lemma='roditelj', pos='noun', tr='батько/мати', vt='core', forms={'gender': 'm', 'plural': 'roditelji'},
         ex=['Svaki roditelj želi najbolje za dijete.'], lesson='4e003796-1ce0-5a02-8a2d-59a0de38f3dd',
         fix_tr='один із батьків; roditelji — батьки',
         fix_forms={'gender': 'm', 'plural': 'roditelji'},
         fix_ex=['Svaki roditelj želi najbolje za dijete.', 'Moji roditelji žive u Kijevu.']),
    dict(lemma='sjediti', pos='verb', tr='сидіти', vt='core', forms={'aspect': 'ipfv'},
         ex=['Mogu li sjediti ovdje?'], lesson='2b0e9742-99e1-57e1-a574-67ffb78d2607',
         fix_forms={'aspect': 'ipfv', 'present': {'1s': 'sjedim', '2s': 'sjediš', '3s': 'sjedi'}},
         fix_ex=['Mogu li sjediti ovdje?', 'Djeca sjede za stolom.']),
    dict(lemma='ako', pos='conjunction', tr='якщо', vt='function_word', forms={},
         ex=['Ako želiš, idemo na kavu.', 'Ako pada kiša, ostajem kod kuće.'], lesson='78f28f85-dd8b-5e81-8a52-1b2dbce4eb34'),
    # A1.1
    dict(lemma='čitati', pos='verb', tr='читати', vt='core',
         forms={'past': 'čitao', 'aspect': 'ipfv',
                'present': {'1s': 'čitam', '2s': 'čitaš', '3s': 'čita', '1p': 'čitamo', '2p': 'čitate', '3p': 'čitaju'}},
         ex=['Volim čitati knjige uvečer.'], lesson='4bf48151-be83-5108-bc92-645c0603a1a3',
         fix_ex=['Volim čitati knjige uvečer.', 'Ujutro čitam vijesti na mobitelu.']),
    dict(lemma='svaki', pos='pronoun', tr='кожен', vt='function_word', forms={'f': 'svaka', 'n': 'svako'}, cefr='A1', new=True,
         ex=['Svaki dan idem na posao.', 'Svaka soba ima balkon.'], lesson='959e879f-a28d-5bed-9c09-16cff91ef456'),
    dict(lemma='trčati', pos='verb', tr='бігати', vt='core',
         forms={'past': 'trčao', 'aspect': 'ipfv',
                'present': {'1s': 'trčim', '2s': 'trčiš', '3s': 'trči', '1p': 'trčimo', '2p': 'trčite', '3p': 'trče'}},
         ex=['Trčim u parku svako jutro.'], lesson='959e879f-a28d-5bed-9c09-16cff91ef456'),
    dict(lemma='gledati', pos='verb', tr='дивитися', vt='core',
         forms={'past': 'gledao', 'aspect': 'ipfv',
                'present': {'1s': 'gledam', '2s': 'gledaš', '3s': 'gleda', '1p': 'gledamo', '2p': 'gledate', '3p': 'gledaju'}},
         ex=['Gledam televiziju svake večeri.'], lesson='d43d6c65-1ce3-5c72-9ecd-cce2ed200fc2',
         fix_ex=['Gledam televiziju svake večeri.', 'Djeca gledaju crtiće.']),
    dict(lemma='jer', pos='conjunction', tr='тому що / бо', vt='function_word', forms={},
         ex=['Ne radim jer sam bolestan.', 'Idem kući jer je kasno.'], lesson='63a4a6d8-1cae-5e0e-90ff-98efcfe8b4c7',
         fix_tr='бо; тому що'),
    dict(lemma='lak', pos='adjective', tr='легкий', vt='core', forms={'f': 'laka', 'n': 'lako', 'plural': 'laki'},
         ex=['Lak test iz hrvatskog.'], lesson='ad0bc1f4-2808-5b24-969d-9da64d4a7a4d',
         fix_ex=['Ovaj test je lak.', 'Hrvatski nije lak, ali je lijep.']),
    dict(lemma='vrlo', pos='adverb', tr='дуже', vt='function_word', forms={}, cefr='A1', new=True,
         ex=['Vrlo je lijepo vrijeme.', 'Hvala, vrlo ste ljubazni.'], lesson='ad0bc1f4-2808-5b24-969d-9da64d4a7a4d'),
    # A1.6, A1.9, A1.13
    dict(lemma='dom', pos='noun', tr='гуртожиток', vt='core', forms={'gender': 'm'},
         ex=['Studenti žive u studentskom domu.'], lesson='b369f01f-4a84-57b4-98cb-150d236f4d7f',
         fix_tr='дім, оселя; заклад (dom za starije — будинок для літніх людей, dom zdravlja — поліклініка, studentski dom — гуртожиток)',
         fix_forms={'gender': 'm', 'plural': 'domovi'},
         fix_ex=['Ona radi u domu za starije.', 'Studenti žive u studentskom domu.']),
    dict(lemma='razgovarati', pos='verb', tr='розмовляти', vt='core', forms={'aspect': 'ipfv'},
         ex=['Moramo razgovarati.'], lesson='d813e9c0-2331-59d8-90f1-cea7e9a61c7d',
         fix_forms={'aspect': 'ipfv', 'present': {'1s': 'razgovaram', '2s': 'razgovaraš', '3s': 'razgovara'}},
         fix_ex=['Moramo razgovarati.', 'Na pauzi razgovaram s kolegama.']),
    dict(lemma='slušati', pos='verb', tr='слухати', vt='core',
         forms={'past': 'slušao', 'aspect': 'ipfv',
                'present': {'1s': 'slušam', '2s': 'slušaš', '3s': 'sluša', '1p': 'slušamo', '2p': 'slušate', '3p': 'slušaju'}},
         ex=['Slušam glazbu u autu.'], lesson='1c16ceee-5f42-536a-98b4-7dcabaa3be6d',
         fix_ex=['Slušam glazbu u autu.', 'Koju glazbu voliš slušati?']),
    dict(lemma='dok', pos='conjunction', tr='поки, доки', vt='core', forms={},
         ex=['Čekaj me ovdje dok ne dođem.'], lesson='3f440ad8-f057-5898-b773-6aa8816fa8a3',
         fix_tr='поки; доки', fix_ex=['Čekaj me ovdje dok ne dođem.', 'Dok kuham, slušam radio.']),
    dict(lemma='život', pos='noun', tr='життя', vt='core', forms={'gender': 'm'},
         ex=['Život na moru je lijep.'], lesson='dbb91fa1-4a97-5c04-99a8-8ac1d508b952',
         fix_forms={'gender': 'm', 'plural': 'životi'},
         fix_ex=['Život na moru je lijep.', 'Ovdje počinjem novi život.']),
]

# ---------------------------------------------------------------- 2. Нові правила граматики (3)
# topic — grammar_topics.title_hr; after — правило, після якого вставити (місця далі зсуваються).
NEW_RULES = [
    dict(topic='Rod, množina i posvojne zamjenice', after='Множина', title='Короткі слова: grad → gradovi',
         expl='Більшість односкладових іменників чоловічого роду в множині отримують -ovi: grad → gradovi, '
              'stol → stolovi, sin → sinovi, vlak → vlakovi. Якщо слово закінчується на м’який приголосний '
              '(č, ć, š, ž, đ, j, lj, nj), то -evi: muž → muževi, ključ → ključevi, broj → brojevi. '
              '«Gradi» чи «stoli» — помилка. Винятки: dan → dani, zub → zubi, konj → konji.',
         pattern='grad → gradovi · stol → stolovi · ključ → ključevi',
         ex=[('Svi stolovi su zauzeti.', 'Усі столики зайняті.'),
             ('Gdje su moji ključevi?', 'Де мої ключі?'),
             ('Vlakovi za Split su puni.', 'Поїзди до Спліта переповнені.'),
             ('Moji sinovi idu u školu.', 'Мої сини ходять до школи.'),
             ('Ovi brojevi nisu točni.', 'Ці номери неправильні.')]),
    dict(topic='Lokativ', after='O + місцевий: про кого, про що', title='Ruka — u ruci: зміна k, g, h',
         expl='Перед закінченням -i в місцевому (і давальному) відмінку жіночого роду k, g, h змінюються на c, z, s: '
              'ruka → u ruci, knjiga → u knjizi, Rijeka → u Rijeci, noga → na nozi. Так само, як в українському '
              '«рука — в руці, нога — на нозі». Винятки — деякі слова про людей і тварин: baka → baki, mačka → mački.',
         pattern='ruka → u ruci · knjiga → o knjizi · Rijeka → u Rijeci',
         ex=[('Živim u Rijeci.', 'Я живу в Рієці.'),
             ('Što imaš u ruci?', 'Що в тебе в руці?'),
             ('Čitam o tome u knjizi.', 'Я читаю про це в книжці.'),
             ('Na nozi imam flaster.', 'На нозі в мене пластир.')]),
    dict(topic='Genitiv: osnove', after=None, title='Od mene, kod nas, o tebi: займенники після прийменників',
         expl='Після прийменників особові займенники мають повні форми. Родовий (після od, do, kod, iz, bez): '
              'mene, tebe, njega, nje, nas, vas, njih — kod nas, od tebe, bez njega. Місцевий (після o, u, na, po): '
              'meni, tebi, njemu, njoj, nama, vama, njima — o meni, o njoj. Короткі форми (me, te, ga) після прийменника не вживаються.',
         pattern='kod nas · od mene · bez tebe · o njoj',
         ex=[('Kod nas je danas toplo.', 'У нас сьогодні тепло.'),
             ('Ovo je poklon od mene.', 'Це подарунок від мене.'),
             ('Ne mogu bez tebe.', 'Я не можу без тебе.'),
             ('Što misliš o njemu?', 'Що ти думаєш про нього?'),
             ('Pričamo o tebi.', 'Ми говоримо про тебе.')]),
]

# ---------------------------------------------------------------- 3. Довші пояснення й приклади
# Ключ — (тема title_hr, правило title_ua). e — нове пояснення (None — лишити); fix — {номер прикладу: (hr, ua)};
# add — нові приклади в кінець (разом ≥ 4).
RULES = {
    # ---------------- A0
    ('Osobne zamjenice i glagol BITI', 'Особові займенники (однина)'): dict(
        e='Особові займенники однини: ja (я), ti (ти), on (він), ona (вона), ono (воно). Їх часто пропускають, '
          'бо форма дієслова вже показує особу: «Ja sam iz Ukrajine» = «Iz Ukrajine sam». Займенник лишаємо, '
          'коли хочемо підкреслити або протиставити: Ja sam Daša, a ti?',
        add=[('On je moj brat.', 'Він мій брат.'), ('Iz Kijeva sam.', 'Я з Києва.')]),
    ('Osobne zamjenice i glagol BITI', 'Дієслово BITI (бути) - короткі форми'): dict(
        e='Biti («бути») у теперішньому часі має короткі форми: sam, si, je, smo, ste, su. В українській «є» зазвичай '
          'пропускаємо, а в хорватській — ні: «Я втомлений» — Umoran sam. Короткі форми не стоять першими в реченні: '
          'Ja sam Ana або Ana sam, але не «Sam Ana».',
        fix={0: ('Ja sam dobro.', 'У мене все добре.'), 1: ('Kako si?', 'Як ти?')},
        add=[('Mi smo iz Ukrajine.', 'Ми з України.'), ('Oni su u Zagrebu.', 'Вони в Загребі.')]),
    ('Glagol imati', 'Imam, imaš, ima…'): dict(
        e='Imati — «мати». Де українською кажемо «у мене є», хорватською кажуть «я маю»: Imam auto — «У мене є машина». '
          'Форми: imam, imaš, ima, imamo, imate, imaju. Те, що маємо, стоїть у знахідному відмінку: Imam sestru.',
        add=[('Imamo mali stan.', 'У нас маленька квартира.'), ('Ana ima dva psa.', 'В Ани два собаки.')]),
    ('Glagol imati', 'Nemam, nemaš, nema…'): dict(
        e='Заперечення від imati пишемо одним словом: ne + imam = nemam, далі nemaš, nema, nemamo, nemate, nemaju. '
          'Те, чого немає, стоїть у родовому відмінку: nemam vremena, nema mlijeka. «Nema» також означає «немає» '
          'взагалі: Nema problema.',
        add=[('Danas nema autobusa.', 'Сьогодні немає автобуса.')]),
    ('Glagol imati', 'Питання: дієслово + li'): dict(
        e='Питання «так / ні» з imati: li ставимо одразу після дієслова — Imate li…? Imaš li…? Ima li…? Відповідь — '
          'коротко тим самим дієсловом: Imam / Nemam (або Ima / Nema). Так само з іншими дієсловами: '
          'Govorite li…? Znaš li…?',
        add=[('Imate li sobu za dvije osobe?', 'У вас є кімната на двох?')]),
    ('Pokazne zamjenice: ovaj, taj, onaj', 'Ovaj / ova / ovo — біля мене'): dict(
        e='Ovaj (ч. р.), ova (ж. р.), ovo (с. р.) — «цей, ця, це» про те, що поруч із тим, хто говорить: ovaj kruh, '
          'який я тримаю. Займенник узгоджується з іменником за родом. Ovo без іменника означає «це»: Ovo je moj stan.',
        add=[('Ovaj autobus ide u centar.', 'Цей автобус їде в центр.')]),
    ('Pokazne zamjenice: ovaj, taj, onaj', 'Taj / ta / to — біля співрозмовника'): dict(
        e='Taj (ч. р.), ta (ж. р.), to (с. р.) — «цей, той» про те, що поруч зі співрозмовником, або про те, '
          'про що щойно говорили. To без іменника — «це, то»: To je točno. Tko je to? — так питаємо і про людей.',
        add=[('Tko je to?', 'Хто це?')]),
    ('Pokazne zamjenice: ovaj, taj, onaj', 'Onaj / ona / ono — далеко'): dict(
        e='Onaj (ч. р.), ona (ж. р.), ono (с. р.) — «он той, он та, он те» про те, що далеко і від мене, і від '
          'співрозмовника. Часто разом із tamo (там): onaj čovjek tamo. Ona «та» і ona «вона» пишуться однаково — '
          'різницю видно з речення.',
        add=[('Vidiš li onu crkvu tamo?', 'Бачиш он ту церкву?')]),
    ('Pridjevi: slaganje s imenicom', 'Перед іменником: -i / -a / -o'): dict(
        e='Прикметник узгоджується з іменником за родом. Перед іменником чоловічий рід зазвичай має -i (novi stan), '
          'жіночий -a (nova kuća), середній -o або -e (novo kino, svježe mlijeko). У множині: novi stanovi, '
          'nove kuće, nova sela.',
        add=[('Ovo je svježe mlijeko.', 'Це свіже молоко.')]),
    ('Pridjevi: slaganje s imenicom', 'Після «je»: коротка форма'): dict(
        e='Коли прикметник стоїть після je і просто описує предмет, у чоловічому роді вживаємо коротку форму без -i: '
          'Stan je nov. Grad je velik. Жіночий і середній рід не змінюються: Kuća je nova. Kino je novo. '
          'Перед іменником — довга форма: novi stan.',
        add=[('Hotel je skup, ali dobar.', 'Готель дорогий, але хороший.')]),
    ('Upitne riječi', 'Основні питання'): dict(
        e='Питальне слово ставимо на початок: tko (хто), što (що), gdje (де), kada або kad (коли), kako (як), '
          'koliko (скільки), zašto (чому). Після нього — дієслово: Gdje je hotel? Kako se zoveš? Koliko košta?',
        add=[('Kako se zoveš?', 'Як тебе звати?')]),
    ('Upitne riječi', 'Де? Куди? Звідки?'): dict(
        e='Gdje — де (місце): Gdje si? Kamo (або kuda) — куди (напрямок): Kamo ideš? Odakle — звідки: Odakle ste? '
          'Як і в українській, «де» і «куди» — різні слова. Розмовно часто чути «Gdje ideš?», але правильно — '
          'Kamo ideš?',
        add=[('Kamo idemo večeras?', 'Куди ми підемо сьогодні ввечері?')]),
    ('Upitne riječi', 'Коли ви не зрозуміли'): dict(
        e='Коли щось не зрозуміли, не мовчіть: Molim? (Перепрошую?), Možete li ponoviti? (Можете повторити?), '
          'Polako, molim vas (Повільніше, будь ласка), Što znači…? (Що означає…?). Хорвати охоче повторять і пояснять, '
          'якщо попросити ввічливо.',
        add=[('Oprostite, ne razumijem.', 'Вибачте, я не розумію.')]),
    ('Gdje? Prijedlozi mjesta', 'U і na + місцевий відмінок'): dict(
        e='U — всередині чогось: u sobi, u torbi, u gradu. Na — на поверхні або на відкритому місці: na stolu, '
          'na zidu, na plaži. Після обох на питання «де?» іменник у місцевому відмінку: ч. і с. рід мають -u '
          '(na stolu, u selu), ж. рід -i (u sobi). Детальніше — в A1.',
        add=[('Slika je na zidu.', 'Картина на стіні.')]),
    ('Gdje? Prijedlozi mjesta', 'Ispod, iznad, pored + родовий відмінок'): dict(
        e='Після ispod (під), iznad (над), pored і pokraj (біля), ispred (перед) та iza (за) іменник стоїть у родовому '
          'відмінку: ч. і с. рід мають -a (ispod stola, iza kina), ж. рід -e (pored kuće). В українському «біля столу» '
          '— теж родовий, тож логіка знайома.',
        add=[('Auto je ispred zgrade.', 'Машина перед будинком.')]),
    ('Gdje? Prijedlozi mjesta', 'Ліворуч, праворуч, прямо'): dict(
        e='Lijevo (ліворуч), desno (праворуч), ravno (прямо), gore (нагорі, вгору), dolje (внизу, вниз) — прислівники, '
          'вони не змінюються. Часто зі skrenite (поверніть): Skrenite lijevo. «З лівого боку» — na lijevoj strani.',
        add=[('Skrenite desno kod pošte.', 'Поверніть праворуч біля пошти.')]),
    ('Persiranje: ti i Vi', 'Ti — своїм, Vi — незнайомим'): dict(
        e='До друзів, родини, дітей і ровесників у неформальній обстановці звертаємося на ti. До незнайомих, старших, '
          'у магазині, банку, у лікаря чи в установі — на Vi, і дієслово тоді в множині: Kako ste? Možete li…? '
          'На письмі ввічливе Vi пишуть з великої літери.',
        add=[('Možete li mi pomoći?', 'Ви можете мені допомогти?')]),
    ('Persiranje: ti i Vi', 'Molim — на всі випадки'): dict(
        e='Molim — одне з найпотрібніших слів. Це «будь ласка» в проханні (Molim vas, jednu kavu), «прошу» у відповідь '
          'на «дякую» (Hvala! — Molim.) і «перепрошую?», коли не почули (Molim?). Коли щось подаєте, кажуть Izvolite.',
        add=[('Račun, molim.', 'Рахунок, будь ласка.')]),
    ('Izgovor: hrvatska slova', 'Одна літера — один звук'): dict(
        e='Хорватські слова читаємо так, як написано: кожна літера — один звук, нічого не «ковтаємо». Літери h, c, j '
          'читаємо як «х», «ц», «й»: hvala, cijena, jaje. Наголос на письмі не позначають — його запам’ятовуємо, '
          'коли слухаємо.',
        add=[('Hvala, cijena je dobra.', 'Дякую, ціна хороша.')]),
    ('Izgovor: hrvatska slova', 'Č і Ć'): dict(
        e='Č — тверде «ч», як в українському «час»: čaj, čovjek. Ć — м’якше, щось середнє між «ч» і «ть»: kuća, noć. '
          'Багато хорватів у розмові їх майже не розрізняють, але на письмі різниця важлива: kuća, а не «kuča».',
        add=[('Laku noć, idem kući.', 'На добраніч, я йду додому.')]),
    ('Izgovor: hrvatska slova', 'Š, Ž, Đ, Dž, Lj, Nj'): dict(
        e='Š = «ш», ž = «ж», đ — м’який звук, близький до «дь» (đak), dž = «дж», lj = «ль», nj = «нь». Lj, nj і dž — '
          'це одна літера, хоч і з двох знаків: ljubav, konj, džep. Без діакритик значення змінюється, тому завжди '
          'пишемо š, ž, č, ć, đ.',
        add=[('Moja žena voli šetati.', 'Моя дружина любить гуляти.')]),
    ('Niječni i upitni oblici glagola biti', 'Заперечення: nisam, nisi, nije…'): dict(
        e='Заперечну форму biti пишемо одним словом: ne + sam = nisam, ne + si = nisi, ne + je = nije, далі nismo, niste, '
          'nisu. На відміну від sam, ці форми можуть стояти першими: Nisam umorna. «Nije» також означає «його / її '
          'немає»: Ana nije ovdje.',
        add=[('Nisu kod kuće.', 'Їх немає вдома.')]),
    ('Niječni i upitni oblici glagola biti', 'Питання з «li»'): dict(
        e='Питання «так / ні» з biti будуємо з повною формою: jesam, jesi, jesmo, jeste, jesu + li: Jesi li dobro? '
          'Jeste li iz Ukrajine? Для третьої особи однини кажемо просто Je li…? Порядок: спершу дієслово, потім li, '
          'потім решта.',
        add=[('Je li restoran otvoren?', 'Ресторан відкритий?')]),
    ('Niječni i upitni oblici glagola biti', 'Коротка відповідь'): dict(
        e='На питання з li хорвати часто відповідають не «da / ne», а повною формою дієслова: Jesi li umoran? — '
          'Jesam (так) або Nisam (ні). Так само з іншими дієсловами: Imaš li vremena? — Imam. / Nemam.',
        add=[('Imate li sobu? — Imamo.', 'У вас є кімната? — Є.'), ('Je li Daša kod kuće? — Nije.', 'Даша вдома? — Ні.')]),
    ('Brojevi od 0 do 100', '0–10'): dict(
        e='Nula, jedan, dva, tri, četiri, pet, šest, sedam, osam, devet, deset — основа всіх чисел. Jedan змінюється '
          'за родом: jedan brat, jedna sestra, jedno dijete; dva теж: dva brata, але dvije sestre. Номер телефону '
          'диктують по одній цифрі.',
        add=[('Imam jednu sestru i dva brata.', 'У мене одна сестра і два брати.'),
             ('Soba broj pet je slobodna.', 'Кімната номер п’ять вільна.')]),
    ('Brojevi od 0 do 100', '11–19: «-naest»'): dict(
        e='Числа від 11 до 19 мають «-naest»: jedanaest, dvanaest, trinaest, četrnaest, petnaest, šesnaest, sedamnaest, '
          'osamnaest, devetnaest. Зверніть увагу: četrnaest і šesnaest (без «t»). Після них іменник у родовому '
          'множини: petnaest eura.',
        add=[('Autobus dolazi za petnaest minuta.', 'Автобус приїде за п’ятнадцять хвилин.')]),
    ('Brojevi od 0 do 100', 'Десятки й сто'): dict(
        e=None, add=[('To košta sto eura.', 'Це коштує сто євро.')]),
    ('Brojevi od 0 do 100', 'Число + іменник'): dict(
        e='Після 1 іменник у називному відмінку: jedan euro, jedna kava. Після 2, 3, 4 — у формі родового однини: '
          'dva eura, tri kave. Після 5 і більше — родовий множини: pet eura, deset godina. Так само після 21, 22…: '
          'dvadeset jedan euro, dvadeset dva eura.',
        add=[('Dvije kave, molim.', 'Дві кави, будь ласка.')]),
    ('Vrijeme: dani, sati, mjeseci', 'У який день? — u + день'): dict(
        e='На питання «коли? у який день?» кажемо u + день у знахідному відмінку: ponedjeljak → u ponedjeljak, '
          'srijeda → u srijedu, subota → u subotu, nedjelja → u nedjelju. Якщо щось буває щотижня, кажемо subotom, '
          'nedjeljom — «по суботах, по неділях».',
        add=[('Subotom idemo na tržnicu.', 'По суботах ми ходимо на ринок.')]),
    ('Vrijeme: dani, sati, mjeseci', 'Учора, сьогодні, завтра'): dict(
        e='Prekjučer (позавчора), jučer (учора), danas (сьогодні), sutra (завтра), prekosutra (післязавтра) — '
          'прислівники, без прийменника. Частини дня: ujutro (зранку), popodne (по обіді), navečer (увечері), '
          'noću (вночі): sutra ujutro — завтра зранку.',
        add=[('Vidimo se sutra navečer.', 'Побачимося завтра ввечері.')]),
    ('Vrijeme: dani, sati, mjeseci', 'Котра година? О котрій?'): dict(
        e='Котра година? — Koliko je sati? Відповідь: jedan sat, dva / tri / četiri sata, від п’яти — sati: Sada je pet '
          'sati. О котрій? — U koliko sati? → u osam (sati). Пів години: pola devet = 8:30 (пів на дев’яту).',
        add=[('U koliko sati počinje film?', 'О котрій починається фільм?'),
             ('Trgovina radi do osam sati.', 'Магазин працює до восьмої.')]),
    ('Vrijeme: dani, sati, mjeseci', 'У якому місяці? — u + місцевий відмінок'): dict(
        e='Місяці мають власні хорватські назви: siječanj, veljača, ožujak, travanj, svibanj, lipanj, srpanj, kolovoz, '
          'rujan, listopad, studeni, prosinac. «У якому місяці?» — u + місцевий відмінок: u siječnju, u svibnju, '
          'u studenome. Назви місяців пишуть з малої літери.',
        add=[('Škola počinje u rujnu.', 'Школа починається у вересні.')]),
    ('Rod, množina i posvojne zamjenice', 'Три роди'): dict(
        e='Рід іменника зазвичай видно із закінчення: чоловічий — на приголосний (brat, grad, stol), жіночий — на -a '
          '(sestra, kuća), середній — на -o або -e (selo, more). Винятки: tata і kolega — чоловічого роду, хоч на -a. '
          'Від роду залежать прикметник і займенник: moj brat, moja sestra.',
        fix={0: ('Moj brat živi u Splitu.', 'Мій брат живе в Спліті.'), 1: ('Sestra je u školi.', 'Сестра в школі.'),
             2: ('More je toplo.', 'Море тепле.')},
        add=[('Ovo je moj tata.', 'Це мій тато.')]),
    ('Rod, množina i posvojne zamjenice', 'Мій / моя / моє'): dict(
        e='Присвійний займенник має той самий рід, що й іменник: moj brat, moja sestra, moje dijete. Так само tvoj / '
          'tvoja / tvoje. Рід визначає річ, а не власник: і Daša, і Marko кажуть «moj brat» і «moja sestra».',
        add=[('Gdje je moj mobitel?', 'Де мій мобільний?')]),
    ('Rod, množina i posvojne zamjenice', 'Множина'): dict(
        e='Множина: чоловічий рід отримує -i (prijatelj → prijatelji), жіночий -a → -e (kuća → kuće), середній -o / -e '
          '→ -a (selo → sela, more → mora). Більшість коротких (односкладових) слів чоловічого роду мають -ovi / -evi: '
          'grad → gradovi (див. наступне правило). Особливі: brat → braća, dijete → djeca, čovjek → ljudi.',
        add=[('Ljudi su ovdje ljubazni.', 'Люди тут привітні.')]),
    ('Red riječi', 'Звичайний порядок'): dict(
        e='Як і в українській, звичайний порядок — хто, що робить, що / де: Ja pijem kavu. Ana radi u banci. Порядок '
          'досить вільний, і найважливіше часто ставлять у кінець: Kavu pijem ujutro (наголос на «коли»). Головне '
          'правило — короткі слова на другому місці (див. далі).',
        add=[('U subotu idemo u kino.', 'У суботу ми йдемо в кіно.')]),
    ('Red riječi', 'Короткі слова — на другому місці'): dict(
        e='Короткі (ненаголошені) слова — sam, si, je, smo, ste, su, se, me, te, li — стоять на другому місці в '
          'реченні: після першого слова або першої групи слів. Тому Zovem se Ana, а не «Se zovem Ana»; Umoran sam, '
          'а не «Sam umoran».',
        add=[('Danas sam kod kuće.', 'Сьогодні я вдома.')]),
    ('Red riječi', 'Питання'): dict(
        e='Питання «так / ні» починаємо з дієслова + li: Imate li…? Govorite li…? З biti — Je li…? Jesi li…? '
          'Розмовно чути й «Da li…?», але в хорватській нормі краще дієслово + li. Якщо є питальне слово, воно стоїть '
          'першим: Gdje…? Kada…?',
        add=[('Zašto si tužan?', 'Чому ти сумний?')]),
    ('Redni brojevi', 'Перший … десятий'): dict(
        e=None, fix={0: ('Ovo mi je prvi dan na poslu.', 'Це мій перший день на роботі.')},
        add=[('Živim u drugoj ulici lijevo.', 'Я живу на другій вулиці ліворуч.')]),
    ('Redni brojevi', 'Як прикметник'): dict(
        e='Порядкове число узгоджується з іменником і відмінюється, як прикметник: prvi kat, prva ulica, prvo mjesto. '
          '«На якому поверсі?» — na prvom, drugom, trećem katu; «у першому класі» — u prvom razredu.', add=[('Moj ured je na petom katu.', 'Мій офіс на п’ятому поверсі.')]),
    ('Redni brojevi', 'Цифра з крапкою'): dict(
        e='Порядкове число цифрою пишемо з крапкою після цифри: 3. kat = treći kat, 5. razred = peti razred. Так само '
          'в датах: 1. svibnja = prvi svibnja (місяць у родовому відмінку). Крапка тут обов’язкова, без неї це '
          'звичайне число.',
        add=[('Ured je na 4. katu.', 'Офіс на 4-му поверсі.')]),
    ('Veliki brojevi: stotine, tisuće, milijuni', 'Сотні'): dict(
        e=None, add=[('Stan košta petsto eura mjesečno.', 'Квартира коштує п’ятсот євро на місяць.')]),
    ('Veliki brojevi: stotine, tisuće, milijuni', 'Тисячі, мільйони, мільярди'): dict(
        e=None, add=[('Zagreb ima oko osamsto tisuća stanovnika.', 'У Загребі близько вісімсот тисяч жителів.')]),
    ('Veliki brojevi: stotine, tisuće, milijuni', 'Як читати довге число'): dict(
        e='Довге число читаємо зліва направо: тисячі, сотні, десятки, одиниці — без «і» між ними: 2026 — dvije tisuće '
          'dvadeset šest. Рік народження часто кажуть коротко порядковим числом: devedeset druge — 1992-го (godište).', add=[('Telefon košta tisuću dvjesto eura.', 'Телефон коштує тисячу двісті євро.')]),
    ('Veliki brojevi: stotine, tisuće, milijuni', 'Рахуємо вголос'): dict(
        e='Арифметика вголос: plus (плюс), minus (мінус), puta (помножити на), podijeljeno s (поділити на). «Дорівнює» '
          '— je або jednako je: Dva plus dva je četiri. Puta означає також «разів»: tri puta tjedno — тричі на тиждень.',
        add=[('Treniram tri puta tjedno.', 'Я тренуюся тричі на тиждень.')]),
    ('Veliki brojevi: stotine, tisuće, milijuni', 'Приблизно, частини, відсотки'): dict(
        e=None, add=[('Popust je dvadeset posto.', 'Знижка двадцять відсотків.')]),
    ('Vrijeme: bezlične rečenice', 'Холодно, тепло: прислівник + je'): dict(
        e=None, add=[('Ljeti je u Splitu vruće.', 'Влітку в Спліті спекотно.')]),
    ('Vrijeme: bezlične rečenice', 'Дощ «падає», вітер «дме»'): dict(
        e='Про опади хорвати кажуть «падає»: pada kiša (іде дощ), pada snijeg (іде сніг). Про вітер — «дме»: puše '
          'vjetar, puše bura (холодний північний вітер), puše jugo (теплий південний). Українське «іде дощ» '
          'дослівно перекладати не можна.',
        add=[('Puše jugo, more je nemirno.', 'Дме юго, море неспокійне.')]),
    ('Vrijeme: bezlične rečenice', 'Було й буде: bilo je, bit će'): dict(
        e='Минуле про погоду: bilo je + прислівник: Jučer je bilo hladno (учора було холодно). Майбутнє: bit će: '
          'Sutra će biti toplo. Bit će kiše — «буде дощ» (kiša в родовому). Минулий і майбутній час докладно — '
          'в A1, тут це готові вирази.',
        add=[('Prošli tjedan bilo je jako vruće.', 'Минулого тижня було дуже спекотно.')]),
    ('Posvojne zamjenice', 'Мій, твій, наш, ваш'): dict(
        e=None, add=[('Vaša putovnica, molim.', 'Ваш паспорт, будь ласка.')]),
    ('Posvojne zamjenice', 'Його, її, їхній'): dict(
        e=None, add=[('Njegov sin živi u Rijeci.', 'Його син живе в Рієці.')]),
    ('Posvojne zamjenice', 'Svoj — «свій»'): dict(
        e=None, add=[('Marko voli svoju ženu.', 'Марко любить свою дружину.')]),
    ('Posvojne zamjenice', 'Чий? Чия? Чиє?'): dict(
        e='Питання про власника теж узгоджується з річчю: čiji (ч. р.), čija (ж. р.), čije (с. р.), у множині — čiji, '
          'čije, čija. Відповідаємо присвійним займенником: Čija je ovo torba? — Moja. Čiji je ovo mobitel? — Njegov.', add=[('Čije su ovo cipele?', 'Чиї це черевики?')]),
    ('Komparativ: jeftiniji, skuplji', 'Дешевший, дорожчий: -iji і -ji'): dict(
        e=None, add=[('Ovaj stan je jeftiniji.', 'Ця квартира дешевша.')]),
    ('Komparativ: jeftiniji, skuplji', 'Дешевше, дорожче, більше'): dict(
        e=None, add=[('Danas je sve skuplje.', 'Сьогодні все дорожче.')]),
    ('Komparativ: jeftiniji, skuplji', 'Ніж: nego або od'): dict(
        e=None, add=[('Vlak je brži od autobusa.', 'Поїзд швидший за автобус.')]),
    ('Komparativ: jeftiniji, skuplji', 'Найдешевший: naj-'): dict(
        e='Найвищий ступінь: naj- + вищий ступінь: jeftiniji → najjeftiniji, skuplji → najskuplji, bolji → najbolji, '
          'veći → najveći. Він узгоджується з іменником, як прикметник: najbolja cijena, najveći grad. «З усіх» — '
          'od svih: najjeftiniji od svih.',
        add=[('Zagreb je najveći grad u Hrvatskoj.', 'Загреб — найбільше місто Хорватії.')]),
    ('Što te boli? Boli me…, bole me…', 'Мене болить: boli me'): dict(
        e=None, add=[('Boli ga glava.', 'У нього болить голова.')]),
    ('Što te boli? Boli me…, bole me…', 'Болить чи болять: boli / bole'): dict(
        e='Дієслово узгоджується з тим, що болить: одна річ — boli (boli me noga), кілька — bole (bole me noge). Leđa '
          '(спина) і prsa (груди) мають лише множину, тому кажуть bole me leđa, bole me prsa, хоча українською '
          '«болить спина».', add=[('Boli me noga.', 'У мене болить нога.')]),
    ('Što te boli? Boli me…, bole me…', 'Що болить? Питання й заперечення'): dict(
        e='Лікар запитає: Što vas boli? або Gdje vas boli? (до знайомих — te). Відповідаємо: Boli me ovdje. Заперечення — '
          'ne перед дієсловом: Ne boli me. Više me ne boli — «уже не болить». Питання з li: Boli li vas glava?', add=[('Boli li vas ovdje?', 'Вам тут болить?')]),
    # ---------------- A1
    ('Veznici', 'I, a, ali'): dict(
        e='I — «і» (з’єднує): brat i sestra. A — «а» (протиставляє двох людей чи дві речі): Ja radim, a on spava. '
          'Ali — «але» (обмеження, несподіванка): Mali je, ali lijep. Перед a і ali ставимо кому, перед i — ні.',
        add=[('Volim more, ali ne volim vrućinu.', 'Я люблю море, але не люблю спеку.')]),
    ('Veznici', 'Ili — або, чи'): dict(
        e='Ili — «або, чи»: вибір між варіантами. У питанні: Kava ili čaj? У проханні: Platite karticom ili gotovinom. '
          '«Або… або…» — ili… ili…: Doći ću ili danas ili sutra. Перед ili кома зазвичай не потрібна.',
        add=[('Idemo autom ili vlakom?', 'Їдемо машиною чи поїздом?')]),
    ('Veznici', 'Jer, zato što — бо, тому що'): dict(
        e='Причину пояснюємо словами jer або zato što — «бо, тому що»: Ne dolazim jer sam bolestan. На питання Zašto? '
          '(чому?) зазвичай відповідають Zato što…: Zašto učiš hrvatski? — Zato što živim ovdje. Обидва слова '
          'означають те саме.',
        fix={1: ('Ne idem zato što sam umorna.', 'Я не йду, бо втомилася.')},
        add=[('Zašto kasniš? — Zato što nema autobusa.', 'Чому ти запізнюєшся? — Бо немає автобуса.')]),
    ('Pravilni glagoli', 'Інфінітив: -ti або -ći'): dict(
        e='У словнику дієслово стоїть в інфінітиві. Більшість мають -ti (raditi, gledati, piti), частина — -ći (ići, moći, '
          'doći, peći). Від інфінітива утворюємо теперішній час: gledati → gledam, raditi → radim. У майбутньому '
          'часі -i відпадає: radit ću (див. Futur I).',
        add=[('Moram kupiti kruh.', 'Мені треба купити хліб.')]),
    ('Pravilni glagoli', 'Дієслово + інфінітив'): dict(
        e='Після voljeti (любити), željeti (бажати), htjeti (хотіти), moći (могти), morati (мусити), znati (уміти) і '
          'učiti (вчитися) друге дієслово стоїть в інфінітиві — як в українському «люблю плавати». Конструкцію '
          '«želim da idem» хорватська норма не радить — кажіть Želim ići.',
        add=[('Znaš li plivati?', 'Ти вмієш плавати?')]),
    ('Pravilni glagoli', 'Питання і заперечення'): dict(
        e='Питання «так / ні»: дієслово + li на початку: Čitaš li? Radite li danas? Заперечення: ne окремо перед '
          'дієсловом: Ne čitam. Ne radimo. Коротка відповідь — тим самим дієсловом: Radiš li sutra? — Radim. / '
          'Ne radim.',
        add=[('Radite li u subotu? — Ne radimo.', 'Ви працюєте в суботу? — Ні.')]),
    ('Česti nepravilni glagoli', 'Ići — іти, їхати'): dict(
        e='Ići означає і «йти пішки», і «їхати»: Idem na posao (пішки чи автобусом — не важливо). Як саме — додаємо: '
          'idem pješice, idem autobusom. Теперішній час: idem, ideš, ide, idemo, idete, idu. «Ходімо!» — Idemo!',
        add=[('Idemo na kavu!', 'Ходімо на каву!')]),
    ('Česti nepravilni glagoli', 'Htjeti і moći'): dict(
        e=None, add=[('Hoćete li još nešto?', 'Бажаєте ще щось?')]),
    ('Česti nepravilni glagoli', 'Jesti і piti'): dict(
        e=None, add=[('Pijete li kavu sa šećerom?', 'Ви п’єте каву з цукром?')]),
    ('Akuzativ', 'Жіночий рід: -a → -u'): dict(
        e='Знахідний відмінок відповідає на питання «кого? що?» після дієслів imati, trebati, vidjeti, kupovati, '
          'voljeti. Іменники жіночого роду на -a мають -u — як в українському «кава — каву»: Pijem kavu. Trebam kartu. '
          'Прикметник теж: novu kartu.',
        add=[('Trebam kartu za Split.', 'Мені потрібен квиток до Спліта.')]),
    ('Akuzativ', 'Чоловічий рід: неживе не змінюється, живе → -a'): dict(
        e='Неживі іменники чоловічого роду в знахідному не змінюються: Trebam ključ. Kupujem kruh. Живі (люди й тварини) '
          'отримують -a: Čekam prijatelja. Imam psa. Середній рід теж не змінюється: Pijem vino. Як в українському '
          '«бачу стіл — бачу брата».', add=[('Tražim liječnika.', 'Я шукаю лікаря.')]),
    ('Akuzativ', 'Займенники: me, te, ga, je'): dict(
        e='Короткі форми займенників у знахідному: me (мене), te (тебе), ga (його), je (її), nas, vas, ih (їх). Вони '
          'стоять на другому місці: Vidim te. Zovem ga sutra. Повні форми (mene, tebe, njega, nju) — для наголосу '
          'або після прийменника: Čekam tebe, ne njega.',
        add=[('Čekam tebe, a ne njega.', 'Я чекаю тебе, а не його.')]),
    ('Prezent', 'Дієслова на -am: čitati'): dict(
        e='Дієслова на -ati здебільшого відмінюються як čitati: -am, -aš, -a, -amo, -ate, -aju. Так само gledati, slušati, '
          'čekati, ručati. Основа не змінюється — це найлегша група. Але частина дієслів на -ati має -em: '
          'pisati → pišem (див. далі).',
        fix={1: ('Kada ručaš?', 'Коли ти обідаєш?')},
        add=[('Čekamo autobus.', 'Ми чекаємо автобус.')]),
    ('Prezent', 'Дієслова на -im: govoriti'): dict(
        e='Дієслова на -iti і більшість на -jeti мають -im, -iš, -i, -imo, -ite, -e: govoriti → govorim, raditi → radim, '
          'živjeti → živim, vidjeti → vidim. У третій особі множини — -e: oni govore, oni rade, oni žive.',
        fix={1: ('Gdje radiš?', 'Де ти працюєш?')},
        add=[('Vidim more s balkona.', 'Я бачу море з балкона.')]),
    ('Prezent', 'Дієслова на -em: pisati, piti, doručkovati'): dict(
        e='Решта дієслів мають -em, -eš, -e, -emo, -ete, -u. Основа часто змінюється, тому форму «я …» варто вчити разом '
          'з інфінітивом: pisati → pišem, piti → pijem, doručkovati → doručkujem, jesti → jedem. У третій особі '
          'множини — -u: oni pišu.', add=[('Djeca piju sok.', 'Діти п’ють сік.')]),
    ('Genitiv: osnove', 'Кількість + родовий'): dict(
        e='Після слів кількості — kilogram, litra, boca, šalica, komad, malo, puno — іменник стоїть у родовому відмінку: '
          'жіночий рід -a → -e (boca vode), чоловічий і середній отримують -a (kilogram sira, malo mlijeka). '
          'Українською так само: пляшка води, трохи сиру.',
        add=[('Šalicu čaja, molim.', 'Чашку чаю, будь ласка.')]),
    ('Genitiv: osnove', 'Nema + родовий'): dict(
        e='Nema — «немає»: те, чого немає, стоїть у родовому відмінку: nema mlijeka, nema autobusa. Nemam — «у мене '
          'немає»: nemam vremena, nemam novca. Так само в минулому: nije bilo vode — не було води.',
        add=[('Nemam novca kod sebe.', 'У мене немає з собою грошей.')]),
    ('Genitiv: osnove', 'Iz, od, do, kod, preko puta + родовий'): dict(
        e='Після iz (з, зсередини), od (від), do (до), kod (біля; у когось) і preko puta (навпроти) іменник стоїть у '
          'родовому відмінку: iz Ukrajine, od kuće, do centra, kod liječnika, preko puta pošte. Kod часто означає '
          '«у когось удома чи в кабінеті»: kod mame, kod zubara.',
        add=[('Večeras smo kod prijatelja.', 'Сьогодні ввечері ми в друзів.')]),
    ('Lokativ', 'Де? — u / na + місцевий'): dict(
        e='На питання «де?» після u і na — місцевий відмінок. Чоловічий і середній рід отримують -u: grad → u gradu, '
          'more → na moru. Жіночий рід на -a має -i: kuća → u kući, plaža → na plaži. Прикметник: u novom stanu, '
          'na velikoj plaži.',
        add=[('Djeca su u vrtiću.', 'Діти в садочку.')]),
    ('Lokativ', 'U чи na?'): dict(
        e='U — всередині закритого простору: u stanu, u trgovini, u gradu. Na — на поверхні, на відкритому місці і в '
          'сталих виразах, які треба запам’ятати: na moru, na poslu, na tržnici, na otoku, na pošti, na fakultetu, '
          'na koncertu. Українське «на роботі» — теж na poslu.',
        add=[('Kupujem marke na pošti.', 'Я купую марки на пошті.')]),
    ('Lokativ', 'O + місцевий: про кого, про що'): dict(
        e='Після o («про») — теж місцевий відмінок: pričamo o poslu, čitam o Hrvatskoj. Так само після po (по): '
          'šetamo po gradu. Питання — O čemu? (про що?) O kome? (про кого?). Займенники після o — повні: o meni, '
          'o tebi, o njoj.',
        add=[('O čemu razgovarate?', 'Про що ви розмовляєте?')]),
    ('Posvojne zamjenice', 'Naš, vaš'): dict(
        e='Naš — «наш», vaš — «ваш». Закінчення — як у прикметника і залежать від речі: naš stan, naša kuća, naše '
          'dijete; множина: naši prijatelji, naše kuće. Ввічливе Vaš (до однієї людини на «Ви») пишуть з великої '
          'літери: Je li ovo Vaša torba?',
        add=[('Naši susjedi su iz Osijeka.', 'Наші сусіди з Осієка.')]),
    ('Posvojne zamjenice', 'Njegov, njezin, njihov'): dict(
        e='Njegov — «його», njezin — «її», njihov — «їхній». На відміну від української, вони змінюються за родом і '
          'числом речі: njegov auto, njegova kuća; njezin brat, njezina sestra; njihovo dijete. Розмовно чути njen, '
          'але в хорватській нормі — njezin.',
        add=[('Njihov sin studira u Zagrebu.', 'Їхній син навчається в Загребі.')]),
    ('Posvojne zamjenice', 'Čiji? — чий?'): dict(
        e='Питання про власника: čiji (ч. р.), čija (ж. р.), čije (с. р.) — узгоджується з річчю, а не з власником: '
          'Čiji je ovo ključ? Čija je ovo torba? У множині: Čiji su ovo ključevi? Відповідаємо присвійним займенником: '
          'Moj. Njezina.',
        fix={2: ('Čiji su ovo ključevi?', 'Чиї це ключі?')},
        add=[('Čije je ovo dijete?', 'Чия це дитина?')]),
    ('Modalni glagoli', 'Moći — могти'): dict(
        e='Moći — «могти»: mogu, možeš, može, možemo, možete, mogu. Mogu li…? — найпростіше ввічливе прохання: Mogu li '
          'platiti karticom? (Можна карткою?) Možete li…? — прохання до когось: Možete li mi pomoći? Після moći — '
          'інфінітив.',
        add=[('Možemo li sjesti ovdje?', 'Можна нам сісти тут?')]),
    ('Modalni glagoli', 'Morati і trebati'): dict(
        e='Morati — «мусити»: Moram ići (мені треба йти). Trebati + іменник — «мені потрібне щось»: Trebam liječnika, '
          'Trebam vrećicu. Також кажуть безособово: Treba mi pomoć — «мені потрібна допомога». Ne moraš означає '
          '«не обов’язково», а не «не можна» (див. далі).',
        add=[('Treba mi tvoj broj.', 'Мені потрібен твій номер.')]),
    ('Modalni glagoli', 'Smjeti — можна (дозвіл)'): dict(
        e='Smjeti — «мати дозвіл»: smijem, smiješ, smije, smijemo, smijete, smiju. Smijem li…? — «Чи можна мені…?»: '
          'Smijem li ući? Ne smijete — «вам не можна» (заборона): Ovdje ne smijete pušiti. На табличках пишуть '
          'Zabranjeno pušenje.',
        add=[('Smijem li otvoriti prozor?', 'Можна відчинити вікно?')]),
    ('Imperativ', 'Ти: -i / -j'): dict(
        e='Наказ або прохання до однієї людини на «ти». Дієслова на -ati: основа + -j: čekati → čekaj, dodati → dodaj. '
          'Більшість інших: основа теперішнього часу + -i: uzeti (uzmem) → uzmi, pisati (pišem) → piši, doći (dođem) → '
          'dođi. З molim te звучить м’якше: Dodaj mi sol, molim te.',
        add=[('Uzmi kišobran, pada kiša.', 'Візьми парасольку, іде дощ.')]),
    ('Imperativ', 'Ви: -ite / -jte'): dict(
        e='До кількох людей або ввічливо до однієї на «Vi» додаємо -te: čekaj → čekajte, uzmi → uzmite, dođi → dođite. '
          'Так звучать інструкції: Ispunite obrazac. Uzmite broj. Pričekajte. Izvolite — «прошу» (коли щось '
          'пропонують).',
        add=[('Ispunite ovaj obrazac, molim.', 'Заповніть цю форму, будь ласка.')]),
    ('Imperativ', 'Не роби: nemoj / nemojte + інфінітив'): dict(
        e='Щоб сказати «не роби», хорвати зазвичай вживають nemoj (до «ти») або nemojte (до «Vi») + інфінітив: '
          'Nemoj kasniti! Nemojte parkirati ovdje. Це звучить м’якше, ніж «Ne kasni!». На табличках — '
          'Zabranjeno… (заборонено).',
        add=[('Nemojte se brinuti, sve je u redu.', 'Не хвилюйтеся, усе гаразд.')]),
    ('Komparacija pridjeva', 'Вищий ступінь: -iji, -ji'): dict(
        e='Вищий ступінь найчастіше має -iji: jeftin → jeftiniji, nov → noviji, topao → topliji. Деякі прикметники мають '
          '-ji і змінюють приголосний: skup → skuplji, drag → draži, tih → tiši, brz → brži. Неправильні треба '
          'запам’ятати: velik → veći, mali → manji, dobar → bolji, loš → gori.',
        add=[('Ova soba je tiša.', 'Ця кімната тихіша.')]),
    ('Komparacija pridjeva', 'Ніж: nego'): dict(
        e='Порівнюємо дві речі: X je … nego Y — «X …-іший, ніж Y»: Split je topliji nego Zagreb. Після nego слово не '
          'змінюється. Можна сказати й od + родовий: topliji od Zagreba. «Набагато» — puno або mnogo: puno jeftiniji.',
        add=[('Ovaj telefon je puno jeftiniji od onog.', 'Цей телефон набагато дешевший за той.')]),
    ('Komparacija pridjeva', 'Найвищий ступінь: naj-'): dict(
        e='Найвищий ступінь: naj- + вищий ступінь: najbolji, najjeftiniji, najveći, najljepši. Він узгоджується з '
          'іменником: najbolja pekara, najveći grad. «Найкращий у…» — u + місцевий: najbolji u gradu; «з усіх» — '
          'od svih.',
        fix={1: ('Ljeto je najtoplije godišnje doba.', 'Літо — найтепліша пора року.')},
        add=[('Ovo je najljepša plaža u Hrvatskoj.', 'Це найкрасивіший пляж у Хорватії.')]),
    ('Upitne rečenice', 'Питання з li'): dict(
        e='Питання «так / ні»: дієслово + li на початку речення: Imate li…? Možete li…? Govorite li…? З biti: Je li…? '
          'Jesi li…? Jeste li…? Розмовно ви почуєте й «Da li…?», але в хорватській нормі краще дієслово + li.',
        add=[('Možete li mi pokazati put?', 'Можете показати мені дорогу?')]),
    ('Upitne rečenice', 'Питальні слова'): dict(
        e='Основні питальні слова: kada (коли), koliko (скільки), zašto (чому), kako (як), odakle (звідки), kamo (куди), '
          'gdje (де), tko (хто), što (що). Вони стоять на початку питання, після них — дієслово: Koliko košta? '
          'Zašto kasniš? Kamo ideš?',
        add=[('Kako se ovo kaže na hrvatskom?', 'Як це сказати хорватською?')]),
    ('Upitne rečenice', 'Koji і kakav — який?'): dict(
        e='Koji — «який саме» (вибір з кількох): Koji autobus ide u centar? Kakav — «який, якої якості, на вигляд»: '
          'Kakvo je vrijeme? Kakav je stan? Обидва узгоджуються з іменником: koja ulica, kakva kuća, koje dijete.',
        add=[('Koja je tvoja omiljena boja?', 'Який твій улюблений колір?')]),
    ('Nijekanje', 'Ne + дієслово'): dict(
        e='Заперечення: ne ставимо окремо перед дієсловом: ne razumijem, ne znam, ne radi. Разом пишемо лише кілька '
          'злитих форм (nisam, nemam, neću — далі). Якщо в реченні є короткі слова, ne стоїть перед ними: '
          'Ne sviđa mi se.',
        add=[('Ne razumijem, možete li ponoviti?', 'Не розумію, можете повторити?')]),
    ('Nijekanje', 'Nisam, nemam, neću, nema'): dict(
        e='Три дієслова зливаються з ne в одне слово: biti → nisam, nisi, nije…; imati → nemam, nemaš, nema…; '
          'htjeti → neću, nećeš, neće… «Nema» також означає «немає» взагалі: Nema problema. Neću часто означає '
          '«не буду» (майбутнє): Neću doći.',
        add=[('Danas nije hladno.', 'Сьогодні не холодно.')]),
    ('Nijekanje', 'Подвійне заперечення'): dict(
        e='Як і в українській, nitko (ніхто), ništa (нічого), nikad (ніколи), nigdje (ніде) вимагають ще й ne перед '
          'дієсловом: Nitko ne zna. Ništa ne vidim. Nikad ne kasnim. Сказати «Nitko zna» — помилка.',
        add=[('Nigdje ne mogu naći ključeve.', 'Я ніде не можу знайти ключі.')]),
    ('Neodređene zamjenice: netko, nešto, negdje', 'Sve-: svatko, sve, svugdje'): dict(
        e='Слова на sve- і svi означають «усі, кожен»: svatko — кожен (Svatko može doći), svi — усі (Svi su tu?), '
          'sve — усе (Sve je u redu), svugdje — всюди, uvijek — завжди. Svatko — однина: Svatko zna; svi — множина: '
          'Svi znaju.',
        fix={2: ('Svugdje je gužva.', 'Скрізь людно.')}),
    ('Vokativ: Dašo! Ivane! Gospodine!', 'Множина: Djeco! Dragi prijatelji!'): dict(
        e='У множині кличний здебільшого такий самий, як називний: Prijatelji!, Kolege!, Dragi prijatelji! Але є два '
          'часті винятки, які варто запам’ятати: djeca → Djeco! і gospoda → Gospodo! (Dame i gospodo!).'),
}
