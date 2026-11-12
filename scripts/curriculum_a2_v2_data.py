"""
Дані програми A2 v2 (погоджено власником 2026-11-12): content/reviews/2026-11-12_curriculum_a2_v2_program.md.

  PROGRAM   — 14 модулів: назва, DRAFT-модуль у базі, який стає цим модулем (id лишається), опис, цілі, кількість уроків,
              групи текстів для читання (module_order наявних текстів A2 → новий номер модуля).
  GRAMMAR   — 22 теми граматики A2: 11 тем у базі (DRAFT, без правил; 5 — «нагадування з A1 + розширення A2»,
              нова назва) і 11 нових. Правило: (назва, пояснення ≥ 150 знаків, зразок, [(hr, ua) × 4–5]).
Уроки модулів — у scripts/curriculum_a2_v2_mNN.py (LESSONS, REVIEW_NOTES). Генератор — scripts/gen_curriculum_a2_v2.py.

Рішення власника 2026-11-12: 14 модулів (12 + 2 «для українців»), 86 уроків, 20–25 нових слів на урок (не зменшувати),
11 нових тем граматики + нагадування з інших рівнів, бета (PUBLISHED одразу).
"""

# DRAFT-модулі A2 у робочій базі (порядок → id), звірено 2026-11-12
OLD_MODULES = {
    1: '38b2ee69-f7d3-5de2-8208-b1fa31501558',   # Досвід
    2: '2cfdcacf-767e-5f3f-bb15-9b245bd598c9',   # Подорожі
    3: 'aa10630b-c7e4-5d3a-b3dc-739e9eea9e06',   # Робота
    4: 'f811eff6-8d8a-5fac-8ae7-6b78020976f1',   # Установи й документи
    5: 'd66361ac-89bc-5021-99ad-c3f61c71145c',   # Здоров’я
    6: '8fad33b4-f461-5119-b5e5-f94b700e283c',   # Стосунки
    7: 'a198575a-bafc-51b5-b325-95aa7d6c9d8a',   # Проблеми
    8: '47c98d89-5811-5425-af88-26e8249d361b',   # Плани
    9: '285d2a27-68a4-5302-afc3-9595d071647a',   # Думки
    10: 'a22f1345-0879-5cde-ad47-4a76556dcf7e',  # Підсумок A2
}

PROGRAM = {
    1: dict(title=('Туризм і подорожі: Адріатика', 'Turizam i putovanja: Jadran'), old=2, lessons=8, reading=[2],
            desc='Відпустка на узбережжі: житло, ресторан, пором, пляж, нацпарки, оренда. Kondicional — ввічливо; ako-речення.',
            goals=['Забронювати житло й розв’язати проблему в номері', 'Ввічливо попросити й замовити: htio bih, biste li mogli',
                   'Зрозуміти оголошення в порту й правила нацпарку']),
    2: dict(title=('Навчання: курси, університет, школа', 'Obrazovanje: tečajevi, fakultet, škola'), old=None, lessons=8, reading=[],
            desc='Курси мови, вступ, визнання диплома, пари й іспити, школа дітей. Вид дієслова, пасив із se, мета da bih.',
            goals=['Записатися на курс чи до університету', 'Розповісти про навчання й іспити', 'Поговорити з учителем дитини']),
    3: dict(title=('Моє минуле: дитинство й спогади', 'Moja prošlost: djetinjstvo i sjećanja'), old=1, lessons=6, reading=[1],
            desc='Дитинство, школа, переїзд, історії й дати. Perfekt і вид, sjećati se, kad / dok / čim, числа й дати.',
            goals=['Розповісти про дитинство й шкільні роки', 'Розповісти історію по порядку', 'Назвати важливі дати свого життя']),
    4: dict(title=('Люди й стосунки: характер, свята, конфлікти', 'Ljudi i odnosi: karakter, slavlja, sukobi'), old=6, lessons=7, reading=[6],
            desc='Характер, весілля й свята, побажання, суперечки й вибачення, думка, скарга, сусіди. Займенники, орудний множини.',
            goals=['Описати характер людини', 'Привітати, побажати, вибачитися', 'Висловити згоду чи незгоду й поскаржитися']),
    5: dict(title=('Робота й кар’єра', 'Posao i karijera'), old=3, lessons=7, reading=[3],
            desc='Наради, ділові листи, телефон, відпустка, зарплата, звільнення, власна справа. Порядок коротких слів, kondicional.',
            goals=['Написати діловий лист і поговорити телефоном', 'Домовитися про відпустку й лікарняний', 'Розібратися із зарплатою й договором']),
    6: dict(title=('Установи, послуги й гроші', 'Ustanove, usluge i novac'), old=4, lessons=6, reading=[4],
            desc='Перукарня й ремонт, майстер удома, нотаріус, податкова й OIB, страховка, офіційна заява. Родовий множини, пасив.',
            goals=['Замовити послугу й домовитися з майстром', 'Засвідчити документ і оформити страховку', 'Написати заяву до установи']),
    7: dict(title=('Здоров’я: система й самопочуття', 'Zdravlje: sustav i dobrobit'), old=5, lessons=5, reading=[5],
            desc='Сімейний лікар і направлення, лікарняний, хронічна хвороба, стрес, розповідь про хворобу. Звукові зміни, безособові речення.',
            goals=['Отримати направлення до фахівця', 'Оформити лікарняний для себе й дитини', 'Розповісти, як ви почуваєтеся']),
    8: dict(title=('Авто в Хорватії', 'Automobil u Hrvatskoj'), old=None, lessons=6, reading=[],
            desc='Посвідчення водія, реєстрація й техогляд, ДТП, штрафи, платні дороги, вживане авто. Дієслова руху з префіксами.',
            goals=['Обміняти посвідчення й зареєструвати авто', 'Пояснити, що сталося на дорозі', 'Купити вживане авто']),
    9: dict(title=('Неприємності в місті й довкілля', 'Nevolje u gradu i okoliš'), old=7, lessons=6, reading=[7],
            desc='Бюро знахідок, сортування сміття, великі речі, природа, попередження про негоду, сад і балкон. Множина D / L / I.',
            goals=['Заявити про загублену річ', 'Правильно сортувати сміття', 'Зрозуміти попередження про негоду']),
    10: dict(title=('Медіа, культура й думки', 'Mediji, kultura i mišljenja'), old=9, lessons=6, reading=[9],
             desc='Новини, оголошення, книги, фільми, рекомендації, власна думка. Порівняльні конструкції, da / što, koji.',
             goals=['Розповісти новину чи сюжет фільму', 'Порадити книгу, фільм чи місце', 'Висловити й обґрунтувати думку']),
    11: dict(title=('Хорватія: краї, звичаї, культура', 'Hrvatska: krajevi, običaji, kultura'), old=None, lessons=6, reading=[],
             desc='Істрія, Славонія, Ліка й Горський Котар, Загреб і Загор’є, етикет, клапа й спадщина. Присвійні прикметники.',
             goals=['Розповісти про край Хорватії', 'Знати звичаї й етикет', 'Поговорити про музику й спадщину']),
    12: dict(title=('Українці в Хорватії', 'Ukrajinci u Hrvatskoj'), old=None, lessons=6, reading=[],
             desc='Статус і документи, громада, волонтерство, посилки й перекази, двомовна родина, порівняння країн. Давальний — розширення.',
             goals=['Продовжити перебування й розповісти про свій статус', 'Надіслати посилку чи переказ в Україну',
                    'Порівняти життя в Хорватії й Україні']),
    13: dict(title=('Плани, мрії й домовленості', 'Planovi, želje i dogovori'), old=8, lessons=6, reading=[8],
             desc='Цілі, мрії, перенесення зустрічі, дозволи й обов’язки, умови, зустріч друзів. Kondicional, futur I і II.',
             goals=['Розповісти про цілі й мрії', 'Перенести чи скасувати зустріч', 'Домовитися про умови й організувати зустріч']),
    14: dict(title=('Підсумок A2: моє життя в Хорватії', 'Sažetak A2: moj život u Hrvatskoj'), old=10, lessons=3, reading=[10],
             desc='Повторення A2: моя історія, ситуації без підказок, листи другові й до установи.',
             goals=['Розповісти свою історію в минулому, теперішньому й майбутньому', 'Впоратися з ситуацією в установі, у лікаря, на роботі',
                    'Написати особистий і офіційний лист']),
}

MID_AFTER = 7   # середина рівня — після A2.7

# --------------------------------------------------------------------------------------------- граматика
# db — id теми в робочій базі (DRAFT, 0 правил); None — нова тема.
GRAMMAR = {
    'KOND': dict(
        db='0c68352a-803a-5410-a59b-91f2c1ddc49f', title_ua='Умовний спосіб: kondicional I', title_hr='Kondicional I.',
        description='Kondicional I для ввічливих прохань (htio bih, biste li mogli), бажань (volio bih) і мети (da bih): форми bih, bi, '
                    'bismo, biste, bi + дієслівна форма на -o / -la; місце bih у реченні; типові помилки українців.',
        rules=[
            ('Як утворюється kondicional',
             'Kondicional I = коротка форма bih, bi, bi, bismo, biste, bi + та сама форма на -o / -la / -lo / -li, що в perfekt: '
             'ja bih htio / htjela, ti bi došao, mi bismo išli, vi biste platili. В українській це «б» + минулий час: «я б хотів». '
             'Bih змінюється за особою — не кажіть «ja bi htio».',
             'ja bih htio · ti bi htio · on bi htio · mi bismo htjeli · vi biste htjeli · oni bi htjeli',
             [('Htio bih sobu s pogledom na more.', 'Я хотів би номер з видом на море.'),
              ('Bismo li mogli platiti karticom?', 'Чи могли б ми заплатити карткою?'),
              ('Darja bi radije išla vlakom.', 'Дар’я радше поїхала б потягом.'),
              ('Što biste vi preporučili?', 'Що б ви порадили?')]),
            ('Ввічливе прохання',
             'Kondicional робить прохання м’якшим: замість Hoću kavu (хочу каву) кажемо Htio bih kavu / Htjela bih kavu. '
             'Питання з Biste li mogli…? — найввічливіше: Biste li mogli ponoviti? Зверніть увагу: bih / biste стоять на другому місці, '
             'після першого слова: Molim Vas, mogli biste li… — ні; правильно: Biste li mi, molim Vas, pomogli?',
             'Htio / Htjela bih… · Biste li mogli…? · Bi li bilo moguće…?',
             [('Htjela bih rezervirati stol za četvero.', 'Я хотіла б забронювати столик на чотирьох.'),
              ('Biste li mogli ponoviti, molim Vas?', 'Чи не могли б ви повторити, будь ласка?'),
              ('Bi li bilo moguće ranije se prijaviti?', 'Чи можна було б заселитися раніше?'),
              ('Trebao bih Vašu pomoć.', 'Мені була б потрібна ваша допомога.')]),
            ('Бажання й мета: volio bih, da bih',
             'Volio bih / Voljela bih — «я б дуже хотів», про мрії й бажання: Volio bih živjeti uz more. Мета — da + kondicional: '
             'Učim hrvatski da bih našla bolji posao (щоб знайти). Типова помилка українця — «da ja nađem» замість da bih našla; '
             'якщо мета стосується іншої людини, кажемо da + теперішній час: Govorim polako da me razumiješ.',
             'Volio / Voljela bih… · da bih / da bismo + -o / -la',
             [('Voljela bih jednog dana otvoriti kafić.', 'Я б хотіла колись відкрити кав’ярню.'),
              ('Upisao sam tečaj da bih lakše našao posao.', 'Я записався на курс, щоб легше знайти роботу.'),
              ('Štedimo da bismo kupili stan.', 'Ми заощаджуємо, щоб купити квартиру.'),
              ('Govori polako da te razumijem.', 'Говори повільно, щоб я тебе зрозумів.')]),
            ('Якби…: ako і kad з kondicionalom',
             'Нереальна умова: Da imam vremena, išao bih na more (якби мав час, поїхав би). У розмові також: Kad bih imao novca, kupio bih auto. '
             'Після da в умові — теперішній час (Da imam…, Da znam…), а в головній частині — kondicional. Не плутайте з реальною умовою '
             'ako + теперішній: Ako imam vremena, idem na more.',
             'Da imam…, išao bih… · Kad bih imao…, kupio bih…',
             [('Da imam više vremena, učila bih talijanski.', 'Якби я мала більше часу, вчила б італійську.'),
              ('Kad bih dobio taj posao, preselio bih se u Split.', 'Якби я отримав ту роботу, переїхав би до Спліта.'),
              ('Da znam, rekla bih ti.', 'Якби я знала, сказала б тобі.'),
              ('Da je ljeto, kupali bismo se.', 'Якби було літо, ми б купалися.')]),
        ]),
    'ZAV': dict(
        db='59c6c708-59b5-5781-bf5d-4ecd5aa8b7dc', title_ua='Підрядні речення: ako, kad, dok, čim, da, što', title_hr='Zavisne rečenice',
        description='Складні речення з ako (якщо), kad (коли), dok (поки), čim (щойно), nakon što (після того як), da (що) і što (що, тому що): '
                    'порядок слів, час у підрядній частині, кома.',
        rules=[
            ('Ako — реальна умова',
             'Ako + теперішній час — умова, яка може виконатися: Ako pada kiša, ostajemo kod kuće. Про майбутнє в підрядній частині '
             'теж теперішній час або futur: Ako stigneš ranije, nazovi me. Українці часто ставлять тут «budem» — на A2 краще просто '
             'теперішній час доконаного дієслова: Ako dođeš, …',
             'Ako + теперішній, (головне речення)',
             [('Ako je more mirno, idemo brodicom.', 'Якщо море спокійне, поїдемо човном.'),
              ('Ako stigneš ranije, nazovi me.', 'Якщо приїдеш раніше, подзвони мені.'),
              ('Ako ne platite predujam, rezervacija se otkazuje.', 'Якщо ви не внесете передоплату, бронювання скасовується.'),
              ('Što ćemo raditi ako trajekt kasni?', 'Що ми робитимемо, якщо пором запізниться?')]),
            ('Kad, dok, čim, nakon što — час',
             'Kad — коли; dok — поки, тоді як (дві дії одночасно): Dok ja kuham, ti postavi stol. Čim — щойно: Čim stignem, javit ću ti se. '
             'Nakon što — після того як: Nakon što sam završio školu, preselio sam se. Prije nego što — перед тим як. '
             'Підрядна частина може стояти першою — тоді після неї кома.',
             'kad · dok · čim · nakon što · prije nego što',
             [('Kad sam bila mala, živjeli smo na selu.', 'Коли я була маленька, ми жили в селі.'),
              ('Dok je baka kuhala, djed je čitao novine.', 'Поки бабуся готувала, дідусь читав газету.'),
              ('Čim je zazvonilo, djeca su istrčala van.', 'Щойно задзвонило, діти вибігли надвір.'),
              ('Nakon što smo se preselili, sve se promijenilo.', 'Після того як ми переїхали, усе змінилося.')]),
            ('Da і što — «що»',
             'Da вводить зміст думки чи слів: Mislim da je to dobra ideja. Rekla je da kasni. Što — «що» як займенник або «тому що, що» після '
             'почуттів: Drago mi je što si došao (радий, що ти прийшов). Типова помилка — «Mislim što…»: після misliti, reći, znati, čuti — '
             'завжди da.',
             'Mislim da… · Rekao je da… · Drago mi je što…',
             [('Mislim da je film predugačak.', 'Я думаю, що фільм задовгий.'),
              ('Čula sam da se otvara nova knjižnica.', 'Я чула, що відкривається нова бібліотека.'),
              ('Drago mi je što ste nas posjetili.', 'Мені приємно, що ви нас відвідали.'),
              ('Žao mi je što nisam mogla doći.', 'Мені шкода, що я не змогла прийти.')]),
        ]),
    'VID': dict(
        db='0b2de584-05a6-5570-a129-366fcb94766d', title_ua='Вид дієслова: недоконаний і доконаний', title_hr='Glagolski vid',
        description='Пари недоконаного й доконаного виду (upisivati / upisati, kupovati / kupiti, dolaziti / doći): процес і результат, '
                    'повторення й одна дія, вид у минулому, майбутньому й наказовому способі.',
        rules=[
            ('Процес чи результат',
             'Як в українській, більшість дієслів мають пару: недоконаний вид — процес або повторення (upisivati — записувати, записуватися), '
             'доконаний — одна завершена дія з результатом (upisati — записати, записатися). Пари утворюються префіксом (pisati → napisati), '
             'суфіксом (upisati → upisivati) або різними словами (dolaziti → doći).',
             'pisati / napisati · upisivati / upisati · kupovati / kupiti · dolaziti / doći',
             [('Svake godine upisujem novi tečaj.', 'Щороку я записуюся на новий курс.'),
              ('Ove godine sam upisala fakultet.', 'Цього року я вступила до університету.'),
              ('Pišem zadaću već sat vremena.', 'Я пишу домашнє завдання вже годину.'),
              ('Napisala sam zadaću i idem van.', 'Я написала домашнє завдання й іду надвір.')]),
            ('Вид у теперішньому часі',
             'Доконане дієслово в теперішньому часі не означає «зараз»: воно вживається після da, ako, kad, čim і в майбутньому. '
             'Kupim kruh — так не кажуть про «зараз»; кажуть Kupujem kruh (купую). Але: Moram kupiti kruh. Ako kupiš kruh, … Типова '
             'помилка українців — доконане дієслово для дії, що відбувається зараз.',
             'Sad pišem e-mail. · Moram napisati e-mail. · Čim napišem e-mail, …',
             [('Trebam predati zahtjev do petka.', 'Мені треба подати заяву до п’ятниці.'),
              ('Upravo predajem zahtjev na šalteru.', 'Я якраз подаю заяву у віконці.'),
              ('Čim dobijem potvrdu, javit ću Vam.', 'Щойно отримаю довідку, повідомлю вам.'),
              ('Ako položiš ispit, slavimo!', 'Якщо складеш іспит, святкуємо!')]),
            ('Вид у наказовому способі й майбутньому',
             'У проханні про одну конкретну дію — доконаний вид: Pošaljite mi ponudu. Pričekajte trenutak. Недоконаний — про постійну дію або '
             'заборону: Šaljite izvještaje svaki petak. Ne pušite ovdje. У futur: Napisat ću ti sutra (одна дія) — Pisat ću ti često (повторення).',
             'Pošaljite! — Šaljite svaki tjedan! · Napisat ću. — Pisat ću.',
             [('Pošaljite mi, molim Vas, izvještaj do podne.', 'Надішліть мені, будь ласка, звіт до обіду.'),
              ('Šaljite mi izvještaje svakog petka.', 'Надсилайте мені звіти щоп’ятниці.'),
              ('Nazvat ću te kad stignem.', 'Я подзвоню тобі, коли приїду.'),
              ('Zvat ću te svaki dan.', 'Я дзвонитиму тобі щодня.')]),
        ]),
    'ZAM': dict(
        db='2d4021eb-fd3e-5388-a44b-3f541c5990f8', title_ua='Займенники: повні й короткі форми', title_hr='Zamjenice: naglašeni i nenaglašeni oblici',
        description='Повні (mene, tebe, njega, nju…) і короткі (me, te, ga, je, mi, ti, mu, joj…) форми особових займенників у родовому, '
                    'давальному й знахідному відмінках: коли яку вживати, де стоїть коротка форма.',
        rules=[
            ('Знахідний: mene / me, njega / ga, nju / je',
             'Коротка форма — звичайна: Vidim ga. Zovem te sutra. Повна — для наголосу, протиставлення й після прийменника: Vidim njega, a ne '
             'nju. Čekam na tebe. Za mene je to važno. Жіночий рід: nju / je (і ju перед je: Vidio ju je). Не кажіть «Vidim njega» без наголосу — '
             'це звучить як «саме його».',
             'me · te · ga · je (ju) · nas · vas · ih — mene · tebe · njega · nju · nas · vas · njih',
             [('Poznaješ li Ivu? — Poznajem ga od škole.', 'Ти знаєш Іву? — Знаю його зі школи.'),
              ('To je za tebe, ne za mene.', 'Це для тебе, а не для мене.'),
              ('Darja nas je pozvala na rođendan.', 'Дар’я запросила нас на день народження.'),
              ('Čekam vas ispred škole.', 'Чекаю вас перед школою.')]),
            ('Давальний: meni / mi, njemu / mu, njoj / joj',
             'Короткі форми давального: mi, ti, mu, joj, nam, vam, im — Daj mi. Reci mu. Sviđa mi se. Повні — meni, tebi, njemu, njoj, nama, vama, '
             'njima — для наголосу й після prema, k: Meni se sviđa, a tebi? Idem k njoj. В українській «йому / їй» звучить однаково — '
             'у хорватській коротка форма mu / joj значно частіша.',
             'mi · ti · mu · joj · nam · vam · im — meni · tebi · njemu · njoj · nama · vama · njima',
             [('Reci joj da sam stigla.', 'Скажи їй, що я приїхала.'),
              ('Meni je ovaj film dosadan, a tebi?', 'Мені цей фільм нудний, а тобі?'),
              ('Pomozi mu s torbom, molim te.', 'Допоможи йому із сумкою, будь ласка.'),
              ('Šef nam je dao slobodan dan.', 'Шеф дав нам вільний день.')]),
            ('Родовий і прийменники',
             'Родовий займенників збігається зі знахідним: mene / me, tebe / te, njega / ga, nje / je, nas, vas, njih / ih. Після прийменників '
             '(od, do, kod, bez, osim) — лише повна форма: kod mene, bez njega, od nje. Типова помилка — «kod me» чи «od ga»: після прийменника '
             'коротких форм не буває.',
             'kod mene · bez tebe · od njega · do nje · osim nas · kod njih',
             [('Ključ je kod mene.', 'Ключ у мене.'), ('Bez tebe ne idem.', 'Без тебе я не піду.'),
              ('Dobila sam poruku od njega.', 'Я отримала від нього повідомлення.'),
              ('Svi su došli osim njih.', 'Усі прийшли, крім них.')]),
        ]),
    'POR': dict(
        db='926638d7-1396-512e-8a05-065c4464b85a', title_ua='Порівняльні конструкції', title_hr='Poredbene konstrukcije',
        description='Порівняння: bolji od, više od, manje nego, isti kao, kao i, sve više, što prije to bolje, najviše; '
                    'прислівники bolje, gore, više, manje.',
        rules=[
            ('Od і nego',
             'Після вищого ступеня — od + родовий: Split je veći od Zadra. Ova knjiga je zanimljivija od filma. Nego — коли порівнюємо '
             'не іменники, а дії, прислівники чи цілі частини: Radije čitam nego gledam televiziju. Bolje je sada nego nikad. '
             'Типова помилка — «veći kao Zadar»: kao лише для рівності.',
             'veći od + G · više nego · radije … nego …',
             [('Film je bio bolji od knjige.', 'Фільм був кращий за книжку.'),
              ('Više volim radio nego televiziju.', 'Я більше люблю радіо, ніж телевізор.'),
              ('Danas je toplije nego jučer.', 'Сьогодні тепліше, ніж учора.'),
              ('Ova serija je napetija od prve.', 'Цей серіал напруженіший за перший.')]),
            ('Isti kao, kao i, jednako',
             'Рівність: isti kao (такий самий, як), kao i (як і), jednako + прикметник + kao: Moj stav je isti kao tvoj. I ja mislim kao i ti. '
             'Ova emisija je jednako dobra kao prošla. Заперечення: nije tako dobar kao… (не такий добрий, як…).',
             'isti kao · kao i · jednako … kao · nije tako … kao',
             [('Imam isti telefon kao ti.', 'У мене такий самий телефон, як у тебе.'),
              ('Nastavak nije tako dobar kao prvi dio.', 'Продовження не таке добре, як перша частина.'),
              ('I ja volim jazz, kao i moj otac.', 'Я теж люблю джаз, як і мій батько.'),
              ('Cijene su jednako visoke kao lani.', 'Ціни такі самі високі, як торік.')]),
            ('Sve više, što prije to bolje',
             'Sve + вищий ступінь — «дедалі»: sve više ljudi (дедалі більше людей), sve skuplje (дедалі дорожче). Što + вищий ступінь — '
             '«якнайшвидше»: što prije, što više. Što…, to… — «чим…, тим…»: Što više čitaš, to bolje pišeš.',
             'sve više · što prije · što …, to …',
             [('Sve više ljudi čita vijesti na mobitelu.', 'Дедалі більше людей читає новини на мобільному.'),
              ('Javite mi se što prije.', 'Озвіться до мене якнайшвидше.'),
              ('Što više slušaš, to bolje razumiješ.', 'Що більше слухаєш, то краще розумієш.'),
              ('Karte su sve skuplje.', 'Квитки дедалі дорожчі.')]),
        ]),
    'GEN': dict(
        db='b7103d09-8e69-53f7-8f17-a90c771fa1a2', title_ua='Родовий відмінок: множина й прийменники', title_hr='Genitiv: množina i prijedlozi',
        description='Родовий множини (-a, -i, -iju: dokumenata, stvari, ljudi) і прийменники з родовим: zbog, umjesto, tijekom, osim, nakon, '
                    'prije, bez, preko, iz, od, do, kod.',
        rules=[
            ('Родовий множини',
             'Чоловічий і середній рід — -a (часто з рухомим a): dokument → dokumenata, mjesec → mjeseci (виняток), prozor → prozora. '
             'Жіночий на -a — -a: usluga → usluga, potvrda → potvrda; на приголосний — -i: stvar → stvari. Після puno, malo, koliko, '
             'nekoliko і чисел від 5 — родовий множини: pet dokumenata, puno ljudi.',
             'puno dokumenata · nekoliko usluga · pet stvari · koliko ljudi?',
             [('Trebam nekoliko dokumenata.', 'Мені потрібно кілька документів.'),
              ('Na šalteru je bilo puno ljudi.', 'Біля віконця було багато людей.'),
              ('Koliko potvrda moram donijeti?', 'Скільки довідок я маю принести?'),
              ('Pet godina radim u Hrvatskoj.', 'П’ять років я працюю в Хорватії.')]),
            ('Zbog, umjesto, tijekom, osim, nakon',
             'Ці прийменники завжди з родовим: zbog kiše (через дощ), umjesto mene (замість мене), tijekom ljeta (протягом літа), '
             'osim nedjelje (крім неділі), nakon posla (після роботи), prije ručka (перед обідом). В українській «через» буває і з '
             'знахідним — у хорватській причина лише zbog + G.',
             'zbog + G · umjesto + G · tijekom + G · osim + G · nakon / prije + G',
             [('Ured je zatvoren zbog praznika.', 'Офіс зачинено через свято.'),
              ('Može li doći netko umjesto mene?', 'Чи може прийти хтось замість мене?'),
              ('Tijekom ljeta radimo do dva.', 'Протягом літа ми працюємо до другої.'),
              ('Otvoreno je svaki dan osim nedjelje.', 'Відчинено щодня, крім неділі.')]),
            ('Кількість і час',
             'Родовий відповідає на «скільки?» і «котрого числа?»: dva sata, pet eura, trećeg svibnja (третього травня), prošle godine '
             '(минулого року), svakog mjeseca. Типова помилка — «u prošlu godinu»: про час без прийменника кажемо родовий: '
             'Prošle godine sam se preselila.',
             'prošle godine · svakog mjeseca · trećeg svibnja · do kraja tjedna',
             [('Porez se plaća do kraja mjeseca.', 'Податок сплачують до кінця місяця.'),
              ('Prošle godine sam otvorila obrt.', 'Минулого року я відкрила власну справу.'),
              ('Rok je petnaestog ožujka.', 'Строк — п’ятнадцятого березня.'),
              ('Svakog mjeseca plaćam osiguranje.', 'Щомісяця я плачу страховку.')]),
        ]),
    'PERF': dict(
        db='feaaa674-66e6-5521-ba6e-b5d1507cd351', title_ua='Perfekt: нагадування й вид у минулому', title_hr='Perfekt: podsjetnik i glagolski vid',
        description='Нагадування A1 (sam, si, je + -o / -la) і нове для A2: недоконаний і доконаний вид у минулому (čitao sam / pročitao sam), '
                    'заперечення nisam, питання jesi li, порядок слів.',
        rules=[
            ('Нагадування: як утворюється perfekt',
             'Perfekt = коротка форма biti (sam, si, je, smo, ste, su) + форма на -o / -la / -lo / -li: radio sam, radila sam, radili smo. '
             'Коротка форма стоїть на другому місці: Jučer sam radila. Якщо речення починається з дієслова — Radila sam jučer. '
             'Заперечення: nisam, nisi, nije… radio. Питання: Jesi li radio? Je li Darja došla?',
             'radio / radila sam · nisam radio · Jesi li radio?',
             [('Jučer sam dugo radila.', 'Учора я довго працювала.'), ('Nismo bili kod kuće.', 'Нас не було вдома.'),
              ('Jesi li vidio Dašu?', 'Ти бачив Дашу?'), ('Djeca su se igrala u parku.', 'Діти гралися в парку.')]),
            ('Вид у минулому: čitao sam — pročitao sam',
             'Недоконаний вид у perfekt — процес, тривалість, повторення в минулому: Kao dijete sam puno čitao (багато читав). '
             'Доконаний — завершена дія з результатом: Pročitao sam knjigu (прочитав до кінця). Тому з «svaki dan, često, dugo» — '
             'недоконаний, а з «jednom, konačno, napokon» — найчастіше доконаний.',
             'Gledala sam film (процес). — Pogledala sam film (до кінця).',
             [('Ljeti smo svaki dan išli na more.', 'Улітку ми щодня ходили на море.'),
              ('Jednom smo otišli na Hvar.', 'Одного разу ми поїхали на Хвар.'),
              ('Dugo sam tražila stan.', 'Я довго шукала квартиру.'),
              ('Napokon sam našla stan.', 'Нарешті я знайшла квартиру.')]),
            ('Розповідь у минулому',
             'У розповіді недоконаний вид дає «фон» (що відбувалося), доконаний — події, що йдуть одна за одною: Padala je kiša i čekala sam '
             'autobus. Odjednom je stao auto i izašao je Marko. Типова помилка українців — забута коротка форма: «Ja išao u školu» замість '
             'Išao sam u školu.',
             'fon: bio je, padala je… · події: došao je, rekao je, otišao je',
             [('Sjedili smo u kafiću kad je počela oluja.', 'Ми сиділи в кафе, коли почалася буря.'),
              ('Ušla sam, pozdravila i sjela.', 'Я ввійшла, привіталася й сіла.'),
              ('Išao sam u školu pješice.', 'Я ходив до школи пішки.'),
              ('Odjednom je nestala struja.', 'Раптом зникло світло.')]),
        ]),
    'POV': dict(
        db='4101ee05-3efe-5a98-a9e5-f0f327436268', title_ua='Зворотні дієслова: sjećati se, baviti se', title_hr='Povratni glagoli: sjećati se, baviti se',
        description='Нагадування A1 (se на другому місці) і нове для A2: керування зворотних дієслів (sjećati se + G, baviti se + I, '
                    'bojati se + G, nadati se + D), se в perfekt (probudio sam se), дієслова із se без «-ся».',
        rules=[
            ('Se на другому місці — і в perfekt',
             'У perfekt se стоїть після sam / si / smo / ste / su: Probudio sam se rano. Jesi li se odmorila? Лише в 3-й особі однини je '
             'випадає: Ona se probudila (не «se je»). Типова помилка українців — «Ja sam probudio se»: коротке слово завжди на другому місці.',
             'Probudio sam se. · Ona se probudila. · Jesmo li se upoznali?',
             [('Jutros sam se probudila u pet.', 'Сьогодні вранці я прокинулася о п’ятій.'),
              ('Luka se preselio u Zagreb.', 'Лука переїхав до Загреба.'),
              ('Jeste li se dobro odmorili?', 'Ви добре відпочили?'),
              ('Upoznali smo se na fakultetu.', 'Ми познайомилися в університеті.')]),
            ('Керування: sjećati se + родовий',
             'Деякі дієслова із se вимагають певного відмінка: sjećati se + G (згадувати, пам’ятати): sjećam se djetinjstva; bojati se + G: '
             'bojim se pasa; baviti se + I (займатися): bavim se sportom; nadati se + D (сподіватися): nadam se odgovoru. Українською '
             '«пам’ятаю дитинство» — знахідний, а хорватською — родовий.',
             'sjećati se + G · bojati se + G · baviti se + I · nadati se + D',
             [('Sjećam se prvog dana u školi.', 'Я пам’ятаю перший день у школі.'),
              ('Kao dijete sam se bojala mraka.', 'У дитинстві я боялася темряви.'),
              ('Čime se baviš?', 'Чим ти займаєшся?'), ('Nadamo se brzom odgovoru.', 'Сподіваємося на швидку відповідь.')]),
            ('Se є, а «-ся» немає (і навпаки)',
             'Часто se не збігається з українським «-ся»: smijati se — сміятися, але vratiti se — повернутися, sviđati se — подобатися, '
             'odlučiti se — наважитися, вирішити; razboljeti se — захворіти (без «-ся»!), dogoditi se — статися, odmarati se — відпочивати. '
             'Без se: početi — початися (Film je počeo).',
             'razboljeti se — захворіти · dogoditi se — статися · početi — початися',
             [('Razboljela sam se prošli tjedan.', 'Я захворіла минулого тижня.'),
              ('Što se dogodilo?', 'Що сталося?'), ('Odmaramo se na selu.', 'Ми відпочиваємо в селі.'),
              ('Koncert je počeo u devet.', 'Концерт почався о дев’ятій.')]),
        ]),
    'INS': dict(
        db='d777c847-266e-57ef-a5a2-f417f12f1b3e', title_ua='Орудний відмінок: множина й pred, iza, među', title_hr='Instrumental: množina i prijedlozi',
        description='Нагадування A1 (s prijateljem, autobusom) і нове для A2: орудний множини (s prijateljima, s djecom), прийменники '
                    'pred, iza, među, nad, pod + орудний (де?), орудний займенників (sa mnom, s njim).',
        rules=[
            ('Орудний множини: -ima, -ama',
             'Чоловічий і середній рід у множині — -ima: s prijateljima, s kolegama (на -a — -ama), pred vratima. Жіночий — -ama: '
             's ženama, sa sestrama. Неправильні: s ljudima, s djecom (діти — однина жін. роду: djeca → djecom), s braćom. '
             'Ці закінчення такі самі в давальному й місцевому множини.',
             's prijateljima · s kolegama · sa sestrama · s djecom · s ljudima',
             [('Ljeto provodim s prijateljima.', 'Літо я проводжу з друзями.'),
              ('Došla je s djecom.', 'Вона прийшла з дітьми.'),
              ('Dobro se slažem s kolegama.', 'Я добре ладнаю з колегами.'),
              ('Razgovarali smo s ljudima iz udruge.', 'Ми поговорили з людьми з асоціації.')]),
            ('Pred, iza, među, nad, pod — де?',
             'На питання gdje? ці прийменники — з орудним: pred kućom (перед будинком), iza zgrade (iza — з родовим!), među prijateljima '
             '(серед друзів), nad stolom, pod stolom. Куди? — зі знахідним: Stavi torbu pod stol. Типова помилка: iza — завжди родовий '
             '(iza kuće), а pred, među, nad, pod — орудний.',
             'pred + I · među + I · nad + I · pod + I · iza + G',
             [('Čekam te pred kinom.', 'Чекаю тебе перед кінотеатром.'),
              ('Među gostima je bilo puno djece.', 'Серед гостей було багато дітей.'),
              ('Mačka spava pod stolom.', 'Кіт спить під столом.'),
              ('Parkiralište je iza zgrade.', 'Парковка за будинком.')]),
            ('Займенники: sa mnom, s njim, s njom',
             'Орудний займенників: mnom, tobom, njim, njom, nama, vama, njima. З приголосним s → sa перед mnom: sa mnom. '
             'Idi s njim. Razgovarala sam s njom. Ne mogu bez tebe — це родовий; s tobom — орудний.',
             'sa mnom · s tobom · s njim · s njom · s nama · s vama · s njima',
             [('Hoćeš li ići sa mnom?', 'Підеш зі мною?'), ('Svađala sam se s njim.', 'Я сварилася з ним.'),
              ('Drago mi je raditi s vama.', 'Мені приємно працювати з вами.'), ('Pričaj s njom.', 'Поговори з нею.')]),
        ]),
    'DAT': dict(
        db='78491f05-4871-51e6-aa8e-7f81fe2f6099', title_ua='Давальний відмінок: повні форми й множина', title_hr='Dativ: puni oblici i množina',
        description='Нагадування A1 (mi, ti, mu, joj) і нове для A2: давальний іменників в однині й множині (mami, bratu, ljudima, djeci), '
                    'дієслова з давальним (pomoći, poslati, vjerovati), прийменники prema, k.',
        rules=[
            ('Кому? Давальний іменників',
             'Однина: чоловічий і середній — -u (bratu, Ivanu, djetetu), жіночий — -i (mami, Darji, prijateljici). Множина — -ima / -ama '
             '(ljudima, kolegama, sestrama), djeca → djeci. Давальний — адресат дії: Šaljem paket mami. Pomažem susjedu. '
             'Типова помилка — «Pomažem susjeda» (знахідний): pomagati / pomoći — з давальним.',
             'mami · bratu · Darji · djeci · ljudima · sestrama',
             [('Šaljem paket mami u Kijev.', 'Надсилаю посилку мамі до Києва.'),
              ('Pomogli smo susjedima s preseljenjem.', 'Ми допомогли сусідам з переїздом.'),
              ('Kupila sam djeci nove knjige.', 'Я купила дітям нові книжки.'),
              ('Vjerujem prijateljima.', 'Я довіряю друзям.')]),
            ('Дієслова з давальним',
             'З давальним: pomoći / pomagati (допомогти), poslati (надіслати кому), dati, reći, objasniti, vjerovati (вірити кому), '
             'zahvaliti (дякувати кому), čestitati (вітати кого), javiti (повідомити). Українською «вітаю маму» — знахідний, а хорватською '
             'Čestitam mami — давальний.',
             'pomoći + D · čestitati + D · zahvaliti + D · javiti se + D',
             [('Čestitala sam baki rođendan.', 'Я привітала бабусю з днем народження.'),
              ('Zahvaljujemo svim volonterima.', 'Дякуємо всім волонтерам.'),
              ('Javi se roditeljima.', 'Озвися до батьків.'),
              ('Objasnite mi, molim Vas, kako to funkcionira.', 'Поясніть мені, будь ласка, як це працює.')]),
            ('Prema і k (ka)',
             'Prema + давальний — «до, у напрямку» і «щодо, згідно з»: Idemo prema moru. Prema zakonu… Ljubazan je prema svima. '
             'K / ka + давальний — «до (людини)»: Idem k liječniku. Ka — перед k, g і перед meni: ka kući, ka meni. У розмові частіше '
             'kod / do / na, але prema в офіційних текстах — дуже часто.',
             'prema moru · prema zakonu · k liječniku · ka meni',
             [('Prema novom zakonu, rok je trideset dana.', 'Згідно з новим законом строк — тридцять днів.'),
              ('Hodali smo prema centru.', 'Ми йшли в бік центру.'),
              ('Bila je vrlo ljubazna prema nama.', 'Вона була дуже привітна з нами.'),
              ('Sutra idem k zubaru.', 'Завтра я йду до стоматолога.')]),
        ]),
    'FUT': dict(
        db='17b75bc6-fca0-5f09-830c-ab7f37279022', title_ua='Futur I: нагадування й доконаний вид', title_hr='Futur I.: podsjetnik i svršeni glagoli',
        description='Нагадування A1 (ću, ćeš, će + інфінітив; ići ću) і нове для A2: доконаний вид у майбутньому (nazvat ću, javit ću se), '
                    'вирази vidjet ćemo se, bit će, порядок слів.',
        rules=[
            ('Нагадування: ću + інфінітив',
             'Futur I = ću, ćeš, će, ćemo, ćete, će + інфінітив. Якщо дієслово стоїть першим, інфінітив втрачає -i і пишеться разом: '
             'radit ću, nazvat ćemo (але на -ći — ići ću, doći ću). Якщо першим стоїть інше слово — Sutra ću raditi. Заперечення: neću, '
             'nećeš… — Neću doći.',
             'Radit ću. — Sutra ću raditi. — Neću raditi. — Hoćeš li raditi?',
             [('Sutra ću ti poslati poruku.', 'Завтра надішлю тобі повідомлення.'),
              ('Javit ću se kad stignem.', 'Я озвуся, коли приїду.'), ('Nećemo stići na vrijeme.', 'Ми не встигнемо вчасно.'),
              ('Hoćeš li doći na zabavu?', 'Ти прийдеш на вечірку?')]),
            ('Доконаний чи недоконаний у майбутньому',
             'Доконане дієслово — одна дія з результатом: Završit ću projekt do petka. Недоконане — процес чи повторення: Radit ću na '
             'projektu cijeli tjedan. Типова помилка — «Ja budu raditi» (як українське «буду працювати»): у хорватському futur I завжди '
             'ću + інфінітив; budem — лише у futur II.',
             'Napisat ću (один раз). — Pisat ću (часто, довго).',
             [('Završit ću tečaj do lipnja.', 'Я закінчу курс до червня.'),
              ('Učit ću svaki dan po pola sata.', 'Я вчитимуся щодня по пів години.'),
              ('Pomoći ću ti s preseljenjem.', 'Я допоможу тобі з переїздом.'),
              ('Gledat ćemo seriju cijeli vikend.', 'Ми дивитимемося серіал усі вихідні.')]),
            ('Сталі вирази',
             'Vidjet ćemo (побачимо), Vidimo se! / Vidjet ćemo se (побачимося), Bit će (буде), Bit će bolje (буде краще), Javit ću ti '
             '(повідомлю), Bit ću tamo (я там буду). Bit će часто означає здогад: Bit će da je zaboravio (мабуть, він забув).',
             'Vidjet ćemo. · Bit će bolje. · Bit će da…',
             [('Ne znam još, vidjet ćemo.', 'Ще не знаю, побачимо.'),
              ('Ne brini, bit će sve u redu.', 'Не хвилюйся, усе буде гаразд.'),
              ('Vidjet ćemo se sutra na poslu.', 'Побачимося завтра на роботі.'),
              ('Bit ću kod kuće iza šest.', 'Я буду вдома після шостої.')]),
        ]),
    # ---------------------------------------------------------------- 11 нових тем
    'PL': dict(
        db=None, title_ua='Множина: давальний, місцевий, орудний', title_hr='Množina: dativ, lokativ, instrumental',
        description='Однакові закінчення множини в давальному, місцевому й орудному: -ima для чоловічого й середнього роду (u gradovima, '
                    's ljudima), -ama для жіночого (u školama), неправильні djeci, ljudima, braći.',
        rules=[
            ('Одне закінчення на три відмінки',
             'У множині давальний, місцевий і орудний збігаються: чоловічий і середній рід — -ima (gradovima, selima, ljudima), жіночий на -a '
             '— -ama (školama, ulicama), жіночий на приголосний — -ima (stvarima). Отже: pomoći ljudima, živjeti među ljudima, razgovarati '
             's ljudima — одна форма.',
             'D = L = I: gradovima · ulicama · stvarima · ljudima',
             [('U većim gradovima ima puno buke.', 'У великих містах багато шуму.'),
              ('Pomažemo starijim ljudima.', 'Ми допомагаємо літнім людям.'),
              ('Na ulicama je bilo smeća.', 'На вулицях було сміття.'),
              ('Razgovarala sam sa susjedima.', 'Я поговорила із сусідами.')]),
            ('Прикметники в множині: -im, -ima',
             'Прикметник у D / L / I множини — -im або -ima для всіх родів: u velikim gradovima / u velikima, s novim susjedima, '
             'u starim kućama. Займенники: mojim prijateljima, ovim ljudima, tim ulicama. Типова помилка — «u veliki gradovi» '
             '(називний замість місцевого).',
             'u velikim gradovima · s novim susjedima · u starim kućama',
             [('Smeće se odvaja u posebnim kantama.', 'Сміття сортують в окремих контейнерах.'),
              ('U starim kućama je hladno zimi.', 'У старих будинках узимку холодно.'),
              ('Pišem svojim prijateljima u Ukrajini.', 'Я пишу своїм друзям в Україні.'),
              ('Na ovim plažama nema hlada.', 'На цих пляжах немає тіні.')]),
            ('Неправильні форми',
             'Деякі слова мають особливу множину: ljudi → ljudima, djeca → djeci (D, L), djecom (I) — бо djeca відмінюється як жіночий рід однини; '
             'braća → braći, braćom; oči → očima, uši → ušima; prsti → prstima. Na rukama, na nogama — регулярно.',
             'djeci / djecom · braći / braćom · očima · ušima',
             [('Pričam djeci priču prije spavanja.', 'Я розповідаю дітям казку перед сном.'),
              ('Idem na izlet s djecom.', 'Я йду на екскурсію з дітьми.'),
              ('Vidjela sam to svojim očima.', 'Я бачила це на власні очі.'),
              ('Nosim rukavice na rukama.', 'Я ношу рукавички на руках.')]),
        ]),
    'GLAS': dict(
        db=None, title_ua='Звукові зміни: рухоме a, u ruci, mlađi', title_hr='Glasovne promjene',
        description='Найчастіші звукові зміни, без яких важко відмінювати: рухоме a (momak – momka), сибіляризація (ruka – u ruci, noga – na nozi), '
                    'йотування у вищому ступені (mlad – mlađi, brz – brži), k / g / h перед i.',
        rules=[
            ('Рухоме a',
             'У багатьох іменниках чоловічого роду a в останньому складі зникає, коли додаємо закінчення: momak → momka, pas → psa, '
             'novac → novca, lakat → lakta, vrabac → vrapca. І навпаки, у родовому множини a з’являється: djevojka → djevojaka, '
             'pismo → pisama. Схоже на українське «сон — сну».',
             'pas → psa · novac → novca · lakat → lakta · djevojka → djevojaka',
             [('Boli me ruka od lakta do ramena.', 'У мене болить рука від ліктя до плеча.'),
              ('Nemam dovoljno novca za taj lijek.', 'У мене не вистачає грошей на ці ліки.'),
              ('Bojim se psa od susjeda.', 'Я боюся сусідського собаки.'),
              ('Na tečaju je bilo deset djevojaka.', 'На курсі було десять дівчат.')]),
            ('K, g, h → c, z, s: u ruci, na nozi',
             'Перед -i в давальному й місцевому однини жіночого роду k, g, h змінюються: ruka → u ruci, noga → na nozi, knjiga → u knjizi, '
             'majka → majci. У множині чоловічого роду: liječnik → liječnici, bubreg → bubrezi. Як в українському '
             '«рука — у руці, нога — на нозі».',
             'ruka → u ruci · noga → na nozi · knjiga → u knjizi · liječnik → liječnici',
             [('Imam ranu na nozi.', 'У мене рана на нозі.'),
              ('Drži lijekove u ruci.', 'Він тримає ліки в руці.'),
              ('Liječnici rade i vikendom.', 'Лікарі працюють і на вихідних.'),
              ('Pročitala sam to u knjizi.', 'Я прочитала це в книжці.')]),
            ('Йотування: mlađi, brži, skuplji',
             'У вищому ступені прикметника j зливається з приголосним: mlad → mlađi, brz → brži, skup → skuplji, tih → tiši, drag → draži, '
             'jak → jači, visok → viši. Тому «mladiji» чи «skupiji» — помилка. Те саме у формах дієслів: pisati → pišem, kazati → kažem.',
             'mlad → mlađi · skup → skuplji · jak → jači · tih → tiši',
             [('Moj brat je dvije godine mlađi.', 'Мій брат на два роки молодший.'),
              ('Bol je danas jača nego jučer.', 'Біль сьогодні сильніший, ніж учора.'),
              ('Privatni pregled je skuplji.', 'Приватний огляд дорожчий.'),
              ('Ovdje je tiše, možemo razgovarati.', 'Тут тихіше, можемо поговорити.')]),
        ]),
    'PROS': dict(
        db=None, title_ua='Множина з розширенням: gradovi, djeca, braća', title_hr='Množina s proširenjem: gradovi, djeca, braća',
        description='Множина односкладових іменників з -ov- / -ev- (grad – gradovi, muž – muževi), неправильні множини (čovjek – ljudi, '
                    'dijete – djeca, brat – braća), середній рід із розширенням (ime – imena, rame – ramena).',
        rules=[
            ('Gradovi, muževi: -ovi / -evi',
             'Більшість односкладових іменників чоловічого роду в множині отримують -ov- або -ev- (-ev- після č, ć, đ, š, ž, j, lj, nj, c): '
             'grad → gradovi, stol → stolovi, sin → sinovi, muž → muževi, kralj → kraljevi, nož → noževi. Виняток: zub → zubi, '
             'gost → gosti, konj → konji.',
             'grad → gradovi · sin → sinovi · muž → muževi · gost → gosti',
             [('Moji sinovi idu u istu školu.', 'Мої сини ходять до тієї самої школи.'),
              ('Gosti dolaze u sedam.', 'Гості приходять о сьомій.'),
              ('Muževi su kuhali, a žene su plesale.', 'Чоловіки куховарили, а жінки танцювали.'),
              ('U sobi su dva stola.', 'У кімнаті два столи.')]),
            ('Ljudi, djeca, braća',
             'Неправильні множини: čovjek → ljudi (люди), dijete → djeca (діти), brat → braća (брати), gospodin → gospoda. Djeca і braća '
             'відмінюються як жіночий рід однини, але дієслово — у множині: Djeca su sretna. Braća su došla. Типова помилка — «djeca je»: '
             'дієслово завжди в множині.',
             'čovjek → ljudi · dijete → djeca · brat → braća · gospodin → gospoda',
             [('Djeca su se igrala u dvorištu.', 'Діти гралися у дворі.'),
              ('Moja braća žive u Lavovu.', 'Мої брати живуть у Львові.'),
              ('Na svadbi je bilo dvjesto ljudi.', 'На весіллі було двісті людей.'),
              ('Dame i gospodo, dobrodošli!', 'Пані й панове, ласкаво просимо!')]),
            ('Ime – imena: середній рід із розширенням',
             'Деякі іменники середнього роду мають у відмінках -en- або -et-: ime → imena (ім’я — імені), rame → ramena, vrijeme → vremena, '
             'dijete → djeteta, tele → teleta. Як в українському «ім’я — імені, теля — теляти».',
             'ime → imena · vrijeme → vremena · rame → ramena · dijete → djeteta',
             [('Kako se piše tvoje ime?', 'Як пишеться твоє ім’я?'),
              ('Nemam vremena za kavu.', 'У мене немає часу на каву.'),
              ('Upisali smo imena svih gostiju.', 'Ми записали імена всіх гостей.'),
              ('Boli me rame.', 'У мене болить плече.')]),
        ]),
    'POSV': dict(
        db=None, title_ua='Присвійні прикметники й прикметники від назв місць', title_hr='Posvojni pridjevi',
        description='Присвійні прикметники від імен і людей (Ivanov, Darjin, mamin, bratov) і прикметники від назв місць (istarski, slavonski, '
                    'zagrebački, dalmatinski): утворення, рід, мала літера.',
        rules=[
            ('Ivanov, Darjin: чий?',
             'Від імен і слів про людей утворюємо прикметник: на приголосний — -ov / -ev (Ivan → Ivanov, Marko → Markov, Luka → Lukin), '
             'на -a — -in (Darja → Darjin, mama → mamin, sestra → sestrin). Він узгоджується з іменником: Darjin auto, Darjina kuća, '
             'Darjino dijete. В українській є те саме: Іванів, мамин.',
             'Ivan → Ivanov · Darja → Darjin · mama → mamin · brat → bratov',
             [('Ovo je Darjin bicikl.', 'Це Дар’їн велосипед.'),
              ('Bakina kuća je u Slavoniji.', 'Бабусин будинок у Славонії.'),
              ('Probaj mamine kolače!', 'Скуштуй маминих тістечок!'),
              ('Markov otac je ribar.', 'Марків батько — рибалка.')]),
            ('Istarski, slavonski: прикметники від місць',
             'Від назв країв і міст — -ski / -ški / -čki: Istra → istarski, Slavonija → slavonski, Dalmacija → dalmatinski, Zagreb → zagrebački, '
             'Split → splitski, Rijeka → riječki. Пишуться з малої літери: istarski pršut, slavonski kulen. Лише в назвах — з великої: '
             'Istarska županija.',
             'Istra → istarski · Zagreb → zagrebački · Lika → lički · Zagorje → zagorski',
             [('Probali smo istarski tartuf.', 'Ми скуштували істрійський трюфель.'),
              ('Slavonski kulen je jako ljut.', 'Славонський кулен дуже гострий.'),
              ('Zagrebačka katedrala se obnavlja.', 'Загребський собор реставрують.'),
              ('Ovo je tipična dalmatinska kuća.', 'Це типовий далматинський будинок.')]),
            ('Відмінювання',
             'Присвійні прикметники відмінюються як звичайні: u Darjinom stanu, s maminim autom, iz bakine kuhinje. Прикметники від місць — '
             'так само: u istarskim selima, na zagrebačkoj tržnici. Типова помилка — '
             'родовий «auto od Darje» замість Darjin auto: це можливо в розмові, але природніше прикметник.',
             'u Darjinom stanu · s maminim autom · na zagrebačkoj tržnici',
             [('Spavali smo u bakinoj sobi.', 'Ми спали в бабусиній кімнаті.'),
              ('Vozim se bratovim autom.', 'Я їжджу братовою машиною.'),
              ('U istarskim selima je mirno.', 'В істрійських селах тихо.'),
              ('Kupila sam sir na zagrebačkoj tržnici.', 'Я купила сир на загребському ринку.')]),
        ]),
    'NUM': dict(
        db=None, title_ua='Числа: 2–4, збірні, oba / obje, дати', title_hr='Brojevi: 2–4, zbirni brojevi, datumi',
        description='Іменник після 2, 3, 4 (dva brata, tri sestre), збірні числівники для людей і дітей (dvoje djece, troje), oba / obje / '
                    'oboje, порядкові числа в датах і роках (rođena sam 1990. godine).',
        rules=[
            ('2, 3, 4 + іменник',
             'Після dva / dvije, tri, četiri: чоловічий і середній рід — форма на -a (dva brata, tri sela), жіночий — -e (dvije sestre, '
             'četiri kuće). Dva — для чоловічого й середнього, dvije — для жіночого роду. Від 5 — родовий множини: pet braće, pet sestara. '
             'Прикметник: dva mala grada, dvije male kuće.',
             'dva brata · dvije sestre · tri godine · četiri sela · pet godina',
             [('Imam dva brata i dvije sestre.', 'У мене два брати й дві сестри.'),
              ('Živjeli smo tamo tri godine.', 'Ми жили там три роки.'),
              ('Preselili smo se prije četiri mjeseca.', 'Ми переїхали чотири місяці тому.'),
              ('U razredu je dvadeset dva učenika.', 'У класі двадцять два учні.')]),
            ('Збірні: dvoje, troje, četvero',
             'Для дітей, змішаних груп (чоловік і жінка) і слів у множині — збірні числівники + родовий множини: dvoje djece, troje ljudi, '
             'četvero unučadi; stol za četvero. Oba (обидва), obje (обидві), oboje (обоє — він і вона): Oboje rade u Zagrebu. '
             'Українською: «двоє дітей» — те саме.',
             'dvoje djece · troje · četvero · oba / obje / oboje',
             [('Imamo dvoje djece.', 'У нас двоє дітей.'),
              ('Rezervirala sam stol za četvero.', 'Я забронювала столик на чотирьох.'),
              ('Oboje smo završili fakultet u Kijevu.', 'Ми обоє закінчили університет у Києві.'),
              ('Obje sestre žive u Splitu.', 'Обидві сестри живуть у Спліті.')]),
            ('Дати й роки',
             'Дата — порядкове число в родовому: Rođen sam petog svibnja (п’ятого травня). Рік: tisuću devetsto devedesete (1990.) або '
             'dvije tisuće dvadeset druge (2022.); на письмі після числа — крапка: 1990. godine, 5. 5. 2022. Коли? — u + місцевий для '
             'місяця (u svibnju), godine + родовий для року.',
             'petog svibnja · 1990. godine · u svibnju · od 2022. do 2024.',
             [('Rođena sam dvadeset prvog travnja.', 'Я народилася двадцять першого квітня.'),
              ('U Hrvatsku smo došli 2022. godine.', 'До Хорватії ми приїхали 2022 року.'),
              ('Vjenčali smo se u lipnju.', 'Ми одружилися в червні.'),
              ('Prvog rujna djeca kreću u školu.', 'Першого вересня діти йдуть до школи.')]),
        ]),
    'KRET': dict(
        db=None, title_ua='Дієслова руху з префіксами', title_hr='Glagoli kretanja s prefiksima',
        description='Префікси при ići і voziti: doći, otići, ući, izaći, prijeći, proći, zaći, obići; dovesti, odvesti, prevesti; '
                    'пари доконаного й недоконаного виду (dolaziti / doći), прийменники після них.',
        rules=[
            ('Do-, od-, u-, iz-: прийти, піти, увійти, вийти',
             'Від ići: doći (прийти, приїхати), otići (піти, поїхати), ući (увійти, заїхати), izaći (вийти, виїхати), prijeći (перейти), '
             'proći (пройти, проїхати), obići (обійти, оглянути). Теперішній час: dođem, odem, uđem, izađem, prijeđem, prođem. '
             'Недоконаний вид: dolaziti, odlaziti, ulaziti, izlaziti, prelaziti, prolaziti.',
             'doći · otići · ući · izaći · prijeći · proći — dolaziti · odlaziti · ulaziti …',
             [('Izađite na drugom izlazu.', 'Виїжджайте на другому з’їзді.'),
              ('Prošli smo kroz crveno?', 'Ми проїхали на червоне?'),
              ('Pazi kad prelaziš cestu.', 'Будь уважний, коли переходиш дорогу.'),
              ('Ušao je u raskrižje prebrzo.', 'Він заїхав на перехрестя надто швидко.')]),
            ('Звідки й куди після префікса',
             'Префікс підказує прийменник: ući u + знахідний (ući u auto), izaći iz + родовий (izaći iz auta), doći do + родовий (doći do '
             'granice) або na / u + знахідний (doći na posao), otići od + родовий (otići od kuće), prijeći preko + родовий (prijeći preko mosta). '
             'Українці часто кажуть «izaći s auta» — правильно iz auta.',
             'ući u + A · izaći iz + G · doći do + G · prijeći preko + G',
             [('Izašla sam iz auta i nazvala policiju.', 'Я вийшла з машини й подзвонила в поліцію.'),
              ('Kako da dođem do granice?', 'Як мені доїхати до кордону?'),
              ('Prijeđite preko mosta i skrenite lijevo.', 'Переїдьте міст і поверніть ліворуч.'),
              ('Uđite u traku za Rijeku.', 'Займіть смугу на Рієку.')]),
            ('Voziti, vesti, nositi з префіксами',
             'Ті самі префікси при voziti (їхати, везти), voditi / vesti (вести), nositi (нести): dovesti (привести, привезти), odvesti '
             '(відвезти), prevesti (перевезти), donijeti (принести), odnijeti (віднести). Vozilo su odvezli na parkiralište. '
             'Pauk je odvezao auto — евакуатор забрав машину.',
             'dovesti · odvesti · prevesti · donijeti · odnijeti · zaobići',
             [('Pauk mi je odvezao auto.', 'Евакуатор забрав мою машину.'),
              ('Možete li me odvesti do servisa?', 'Чи можете ви відвезти мене до сервісу?'),
              ('Donesite prometnu dozvolu.', 'Принесіть свідоцтво про реєстрацію.'),
              ('Zaobiđite centar zbog radova.', 'Об’їдьте центр через ремонтні роботи.')]),
        ]),
    'BEZL': dict(
        db=None, title_ua='Безособові речення: Muka mi je, Ne da mi se', title_hr='Bezlične rečenice',
        description='Безособові конструкції з давальним (Muka mi je, Hladno mi je, Teško mi je, Ne da mi se, Spava mi se) і з se '
                    '(Čini mi se, Ovdje se dobro jede); дієслово в 3-й особі однини середнього роду в минулому.',
        rules=[
            ('Muka mi je, hladno mi je',
             'Стан людини: давальний + je + прислівник: Muka mi je (мене нудить), Hladno mi je (мені холодно), Teško mi je (мені важко), '
             'Bolje mi je (мені краще), Žao mi je (мені шкода). Без займенника «ja»: не «Ja sam hladno». У минулому — bilo je: '
             'Bilo mi je loše. Буде — bit će: Bit će ti bolje.',
             'Muka mi je. · Bilo mi je loše. · Bit će ti bolje.',
             [('Muka mi je od vožnje.', 'Мене нудить від їзди.'), ('Jučer mi je bilo jako loše.', 'Учора мені було дуже погано.'),
              ('Je li ti hladno?', 'Тобі холодно?'), ('Danas mi je puno bolje.', 'Сьогодні мені набагато краще.')]),
            ('Ne da mi se, spava mi se',
             'Ne da mi se + інфінітив — «мені не хочеться, лінь»: Ne da mi se kuhati. Spava mi se — хочеться спати, jede mi se — хочеться '
             'їсти, plače mi se — хочеться плакати. Зверніть увагу: дієслово в 3-й особі однини + se + давальний: Djeci se spava.',
             'Ne da mi se… · Spava mi se. · Ide mi se van.',
             [('Ne da mi se danas ići na trening.', 'Мені сьогодні не хочеться йти на тренування.'),
              ('Spava mi se, rano sam ustala.', 'Мені хочеться спати, я рано встала.'),
              ('Djeci se ne spava.', 'Дітям не хочеться спати.'),
              ('Pije mi se nešto hladno.', 'Мені хочеться випити чогось холодного.')]),
            ('Čini mi se, ovdje se…',
             'Čini mi se da… (мені здається, що…), Čuje se (чути), Vidi se (видно), Zna se (відомо). Ovdje se dobro jede (тут добре годують). '
             'Kako se kaže…? (Як сказати…?). Дієслово — у 3-й особі однини. Типова помилка — «Mi se čini»: коротке mi не стоїть на початку.',
             'Čini mi se da… · Vidi se da… · Kako se kaže…?',
             [('Čini mi se da imam temperaturu.', 'Мені здається, що в мене температура.'),
              ('Vidi se da si umorna.', 'Видно, що ти втомлена.'),
              ('Kako se kaže «лікарняний» na hrvatskom?', 'Як сказати «лікарняний» хорватською?'),
              ('Ovdje se ne puši.', 'Тут не курять.')]),
        ]),
    'PAS': dict(
        db=None, title_ua='Пасив із se: Zahtjev se predaje…', title_hr='Pasiv sa se',
        description='Безособовий пасив із se для правил, інструкцій і оголошень (Zahtjev se predaje na šalteru, Ovdje se plaća karticom): '
                    'дієслово узгоджується з іменником; пасивний дієприкметник (zatvoreno, otvoren, potpisan).',
        rules=[
            ('Se для правил і інструкцій',
             'Коли не важливо, хто робить дію, хорвати кажуть дієслово + se: Zahtjev se predaje na šalteru (заяву подають у віконці). '
             'Prijava se šalje e-mailom. Ovdje se plaća karticom. Дієслово узгоджується з іменником: Dokumenti se predaju… (множина). '
             'Українською — «подають», «подається».',
             'Zahtjev se predaje… · Dokumenti se predaju… · Ovdje se ne parkira.',
             [('Upisnina se plaća unaprijed.', 'Вступний внесок сплачують наперед.'),
              ('Prijave se primaju do petka.', 'Заявки приймають до п’ятниці.'),
              ('Kako se ispunjava ovaj obrazac?', 'Як заповнюють цей бланк?'),
              ('U knjižnici se ne razgovara glasno.', 'У бібліотеці не розмовляють голосно.')]),
            ('Zatvoreno, otvoren: дієприкметник',
             'На вивісках і в документах — пасивний дієприкметник: otvoreno / zatvoreno, potpisan ugovor (підписаний договір), plaćeno '
             '(оплачено), zabranjeno pušenje. З biti: Ugovor je potpisan. Zahtjev je odbijen. Ured je zatvoren zbog praznika.',
             'zatvoreno · plaćeno · potpisan · odobren · odbijen',
             [('Vaš zahtjev je odobren.', 'Вашу заяву схвалено.'),
              ('Račun je plaćen jučer.', 'Рахунок оплачено вчора.'),
              ('Diploma mora biti ovjerena.', 'Диплом має бути засвідчений.'),
              ('Trgovina je zatvorena nedjeljom.', 'Магазин зачинений у неділю.')]),
            ('Se чи особа?',
             'Порівняйте: Predajem zahtjev (я подаю) — Zahtjev se predaje (заяву подають). Na tečaju se puno govori (на курсі багато '
             'говорять). Типова помилка — «Zahtjev predaje se»: se — на другому місці, після першого слова чи групи: Zahtjev se predaje.',
             'Predajem zahtjev. — Zahtjev se predaje. — Na tečaju se govori.',
             [('Na ovom tečaju se puno piše.', 'На цьому курсі багато пишуть.'),
              ('Ispit se polaže u lipnju.', 'Іспит складають у червні.'),
              ('Na fakultetu se upisuje u srpnju.', 'До університету вступають у липні.'),
              ('Ovdje se predaju molbe za stipendiju.', 'Тут подають заяви на стипендію.')]),
        ]),
    'ENK': dict(
        db=None, title_ua='Порядок коротких слів (енклітик)', title_hr='Red riječi: enklitike',
        description='Короткі ненаголошені слова (li, bih / sam / ću, mi / ti / mu, me / te / ga, se, je) стоять на другому місці в '
                    'певному порядку: Dao sam mu ga. Javit ću ti se. Je li ti rekao?',
        rules=[
            ('Друге місце',
             'Усі короткі слова збираються після першого слова чи першої групи: Jučer sam mu poslala e-mail. Moj šef mi je rekao… '
             'Якщо першим стоїть дієслово — після нього: Poslala sam mu e-mail. Типова помилка українців — ставити коротке слово перед '
             'дієсловом, як «я йому сказала»: «Ja mu sam rekla» — неправильно; правильно Ja sam mu rekla.',
             '1-е слово + li + bih / sam / ću + mi / mu + me / ga + se + je',
             [('Jučer sam mu poslala ponudu.', 'Учора я надіслала йому пропозицію.'),
              ('Šef mi je odobrio godišnji.', 'Шеф погодив мені відпустку.'),
              ('Ja sam mu to već rekla.', 'Я йому це вже сказала.'),
              ('Poslat ću Vam ugovor danas.', 'Я надішлю вам договір сьогодні.')]),
            ('Порядок: sam / ću — mi — ga — se — je',
             'Якщо коротких слів кілька, порядок такий: li → дієслово-допоміжне (sam, si, smo, ste, su, ću, bih) → давальний (mi, ti, mu) → '
             'знахідний (me, te, ga) → se → je. Dao sam mu ga (я дав йому це). Javit ću ti se (я тобі озвуся). Je стоїть останнім: '
             'Dao mu ga je.',
             'Dao sam mu ga. · Javit ću ti se. · Dao mu ga je.',
             [('Javit ću Vam se sutra.', 'Я озвуся до вас завтра.'),
              ('Ugovor? Poslala sam ti ga jučer.', 'Договір? Я надіслала тобі його вчора.'),
              ('Kolega mi ga je dao.', 'Колега дав мені його.'),
              ('Bih li Vas mogla nešto pitati?', 'Чи могла б я вас дещо запитати?')]),
            ('Li у питаннях',
             'Li стоїть після першого слова (найчастіше дієслова) і перед іншими короткими словами: Jesi li mu rekao? Možeš li mi pomoći? '
             'Hoćete li mi poslati račun? Je li ti šef odgovorio? Типова помилка — «Li možeš…» або «Možeš mi li…».',
             'Možeš li mi…? · Jesi li mu…? · Je li ti…?',
             [('Možeš li mi poslati prezentaciju?', 'Можеш надіслати мені презентацію?'),
              ('Jeste li mu javili za sastanak?', 'Ви повідомили йому про нараду?'),
              ('Je li ti platio?', 'Він тобі заплатив?'),
              ('Hoćete li nam potvrditi termin?', 'Ви підтвердите нам дату?')]),
        ]),
    'KOJI': dict(
        db=None, title_ua='Відносний займенник koji', title_hr='Odnosna zamjenica koji',
        description='Koji, koja, koje — «який, котрий» у підрядних реченнях: рід і число — як в іменника, відмінок — за роллю в підрядній частині '
                    '(film koji sam gledao, žena kojoj sam pomogao); što у розмові; кома.',
        rules=[
            ('Koji, koja, koje',
             'Koji вводить речення, що описує іменник: Film koji sam gledala je odličan. Рід і число — як в іменника: knjiga koja…, '
             'dijete koje…, ljudi koji… Відмінок — за роллю в підрядному реченні: Knjiga koju čitam (знахідний — читаю що?). '
             'Перед koji — кома (якщо речення не на початку).',
             'film koji… · serija koja… · dijete koje… · knjigu koju…',
             [('To je knjiga koju ti preporučujem.', 'Це книжка, яку я тобі раджу.'),
              ('Gledali smo film koji je dobio nagradu.', 'Ми дивилися фільм, який отримав нагороду.'),
              ('Znaš li ženu koja vodi emisiju?', 'Ти знаєш жінку, яка веде передачу?'),
              ('Ljudi koji žive ovdje su ljubazni.', 'Люди, які тут живуть, привітні.')]),
            ('Відмінки koji',
             'Koji відмінюється як прикметник: kojeg / kojega (Г, З для істот), kojem / kojemu (Д, М), kojim (О). Čovjek kojem sam pomogao. '
             'Grad u kojem živim. Prijatelj s kojim radim. Українською: «місто, в якому я живу» — так само.',
             'u kojem · s kojim · kojem · kojeg · o kojoj',
             [('Grad u kojem živim je malen.', 'Місто, в якому я живу, маленьке.'),
              ('To je kolega s kojim radim.', 'Це колега, з яким я працюю.'),
              ('Članak o kojem pričam je na portalu.', 'Стаття, про яку я розповідаю, на порталі.'),
              ('Susjed kojem smo pomogli zahvalio nam je.', 'Сусід, якому ми допомогли, подякував нам.')]),
            ('Što замість koji у розмові',
             'У розмовній мові іноді кажуть što замість koji в називному й знахідному: Film što smo gledali… На письмі й у навчанні краще '
             'koji. Ne miješajte: što у «Drago mi je što si došao» — це сполучник, а не відносний займенник.',
             'Film koji smo gledali (книжно) — film što smo gledali (розмовно)',
             [('Jesi li pročitala poruku koju sam ti poslala?', 'Ти прочитала повідомлення, яке я тобі надіслала?'),
              ('Serija koju gledam ima tri sezone.', 'Серіал, який я дивлюся, має три сезони.'),
              ('Pjesma koju sviraju je stara.', 'Пісня, яку грають, стара.'),
              ('Restoran koji si preporučio je zatvoren.', 'Ресторан, який ти порадив, зачинений.')]),
        ]),
    'FUT2': dict(
        db=None, title_ua='Futur II — лише впізнавати', title_hr='Futur II. — prepoznavanje',
        description='Futur II (budem, budeš, bude + -o / -la) у підрядних реченнях після kad, ako, čim, dok про майбутнє: Kad budem imao '
                    'vremena… Вживати не обов’язково — на A2 досить впізнавати; замість нього — теперішній час доконаного дієслова.',
        rules=[
            ('Що таке futur II',
             'Futur II = budem, budeš, bude, budemo, budete, budu + форма на -o / -la: budem imao, bude došla. Він уживається лише в '
             'підрядному реченні після kad, ako, čim, dok, prije nego što, коли йдеться про майбутнє: Kad budem imao vremena, nazvat ću te. '
             'Головне речення — futur I.',
             'Kad budem imao…, nazvat ću… · Ako bude padala kiša, …',
             [('Kad budem imala vremena, nazvat ću te.', 'Коли матиму час, подзвоню тобі.'),
              ('Ako bude lijepo vrijeme, idemo na izlet.', 'Якщо буде гарна погода, поїдемо на екскурсію.'),
              ('Čim budemo znali datum, javit ćemo vam.', 'Щойно знатимемо дату, повідомимо вам.'),
              ('Kad bude gotovo, reci mi.', 'Коли буде готово, скажи мені.')]),
            ('Як сказати простіше',
             'Замість futur II можна сказати теперішній час доконаного дієслова: Kad završim posao, nazvat ću te = Kad budem završio posao… '
             'Ako dođeš ranije, … = Ako budeš došao ranije… Для A2 цього досить. Типова помилка — «Kad ću imati vremena…»: після kad / ako '
             'про майбутнє ću не ставимо.',
             'Kad završim… = Kad budem završio… · Ako dođeš… = Ako budeš došao…',
             [('Kad završim tečaj, tražit ću posao.', 'Коли закінчу курс, шукатиму роботу.'),
              ('Ako dobijem vizu, putujem u ljeto.', 'Якщо отримаю візу, улітку поїду.'),
              ('Čim stignem kući, poslat ću ti slike.', 'Щойно приїду додому, надішлю тобі фото.'),
              ('Kad se vratiš, idemo na večeru.', 'Коли повернешся, підемо на вечерю.')]),
            ('Budem у сталих виразах',
             'Budem трапляється й поза futur II: Ne znam hoću li moći, ako budem mogla, doći ću. Kako bude (як буде), Što bude, bit će (що буде, '
             'те буде). Bude li… — «якщо буде»: Bude li problema, zovite. Такі вирази варто впізнавати на слух.',
             'kako bude · što bude, bit će · bude li…',
             [('Vidjet ćemo kako bude.', 'Побачимо, як буде.'),
              ('Što bude, bit će.', 'Що буде, те буде.'),
              ('Bude li problema, nazovite nas.', 'Якщо будуть проблеми, телефонуйте нам.'),
              ('Ako budem mogla, doći ću.', 'Якщо зможу, прийду.')]),
        ]),
}
