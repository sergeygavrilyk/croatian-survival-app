"""
6 старих текстів для читання A2 наново (A2 v2, 2026-11-15): RD-A2-007, 008, 010, 013, 018, 019.

Аудит A2 (content/reviews/2026-11-12_a2_audit.md): у цих текстах < 90 % знайомих слів. Тексти переписано словами уроків
A0, A1 і уроків A2 до модуля тексту (module = modules.order_index у базі), тема й код тексту — ті самі.
Формат запису — як у reading_data_a2_v2.py (+ code). Словничок форм — TEXT_ANN (формат reading_lexicon_a2_v2.py).
Генератор: python3 -B scripts/gen_reading_a2_old_fix.py. Установи, люди й заклади — вигадані; факти — загальні, без сум і норм.
"""

TEXTS: list = [
    dict(key='old07_bank', code='RD-A2-007', type='instruction', situation='bank', module=6,
         title=('Як відкрити рахунок у банку', 'Kako otvoriti račun u banci'),
         hr='''Želite otvoriti tekući račun u našoj banci? Evo kako. Prvo dogovorite termin na našoj web-stranici ili telefonom. Ako ne želite čekati termin, dođite u banku, uzmite broj u redu i pričekajte na šalteru. Ponesite putovnicu ili osobnu iskaznicu, potvrdu o OIB-u i potvrdu o prebivalištu. Ako radite, ponesite i ugovor s poslodavcem. Službenik će vam objasniti koje račune imamo i koliko mjesečno košta svaki račun. Kad potpišete ugovor, karticu ćete primiti poštom za sedam do deset dana, a PIN dolazi u drugom pismu. Internetsko i mobilno bankarstvo možete uključiti odmah. Za sva pitanja nazovite nas ili pišite na našu e-poštu.''',
         ua='''Хочете відкрити поточний рахунок у нашому банку? Ось як. Спершу домовтеся про час на нашому сайті або телефоном. Якщо не хочете чекати запису, приходьте в банк, візьміть номерок у черзі й зачекайте біля віконця. Візьміть паспорт або посвідчення особи, довідку про OIB і довідку про місце проживання. Якщо працюєте, візьміть і договір з роботодавцем. Службовець пояснить вам, які рахунки в нас є і скільки щомісяця коштує кожен рахунок. Коли підпишете договір, картку отримаєте поштою за сім–десять днів, а PIN-код прийде в іншому листі. Інтернет-банкінг і мобільний банкінг можна ввімкнути одразу. З усіх питань телефонуйте нам або пишіть на нашу електронну пошту.''',
         questions=[
             ('Як можна домовитися про час?', ['На сайті або телефоном', 'Лише листом', 'Лише в банку'], 'На сайті або телефоном'),
             ('Що ще треба взяти, якщо ви працюєте?', ['Договір з роботодавцем', 'Медичну довідку', 'Диплом'], 'Договір з роботодавцем'),
             ('Як прийде картка?', ['Поштою за сім–десять днів', 'Одразу в банку', 'Електронною поштою'], 'Поштою за сім–десять днів'),
         ]),
    dict(key='old08_missing', code='RD-A2-008', type='email', situation='administration', module=6,
         title=('У заяві бракує документа', 'Nedostaje dokument'),
         hr='''Poštovani gospodine Melnyk,
primili smo Vaš zahtjev za privremeni boravak. Nažalost, u prilogu zahtjeva nedostaje potvrda o zdravstvenom osiguranju. Ovim putem tražimo dopunu zahtjeva. Potvrdu možete predati u pisarnici ili poslati poštom. Na omotnicu upišite urudžbeni broj predmeta. Pošaljite original ili presliku koju je ovjerio javni bilježnik. Rok za dopunu je osam dana. Ako dokument ne stigne na vrijeme, Vaš zahtjev nećemo moći odobriti. Za pitanja nazovite službenu osobu radnim danom od 8 do 12 sati.
S poštovanjem,
Odjel za strance''',
         ua='''Шановний пане Мельник!
Ми отримали вашу заяву на тимчасове перебування. На жаль, у додатках до заяви бракує довідки про медичне страхування. Цим листом просимо доповнити заяву. Довідку можна подати в канцелярії або надіслати поштою. На конверті впишіть реєстраційний номер справи. Надішліть оригінал або копію, засвідчену нотаріусом. Строк для доповнення — вісім днів. Якщо документ не надійде вчасно, ми не зможемо схвалити вашу заяву. З питаннями телефонуйте посадовій особі в робочі дні з 8 до 12 години.
З повагою,
Відділ у справах іноземців''',
         questions=[
             ('Якого документа бракує?', ['Довідки про медичне страхування', 'Паспорта', 'Фотографії'], 'Довідки про медичне страхування'),
             ('Скільки днів є на доповнення заяви?', ['Вісім днів', 'Тридцять днів', 'Три дні'], 'Вісім днів'),
             ('Що треба вписати на конверті?', ['Реєстраційний номер справи', 'Адресу роботи', 'Номер телефону'], 'Реєстраційний номер справи'),
         ]),
    dict(key='old10_winter', code='RD-A2-010', type='article', situation='health', module=7,
         title=('Як не захворіти взимку', 'Kako ne biti bolestan zimi'),
         hr='''Zimi se puno ljudi prehladi. Liječnici govore da je najvažnije često prati ruke, a obvezno poslije javnog prijevoza i prije jela. Zdrava prehrana također pomaže: jedite puno voća i povrća i pijte puno tekućine, najbolje vodu i čaj. Svaki dan prošetajte na svježem zraku, čak i kad je hladno. Spavajte barem sedam sati, jer se tijelo tako lakše oporavi. Ako se razbolite, ostanite kod kuće i ležite. Gripa je zarazna, pa ne idite na posao ni u školu. Ako imate visoku temperaturu dulje od tri dana, nazovite svog izabranog liječnika.''',
         ua='''Узимку багато людей застуджується. Лікарі кажуть, що найважливіше — часто мити руки, а обов’язково — після громадського транспорту й перед їжею. Здорове харчування теж допомагає: їжте багато фруктів і овочів і пийте багато рідини, найкраще воду й чай. Щодня прогулюйтеся на свіжому повітрі, навіть коли холодно. Спіть щонайменше сім годин, бо так тіло легше відновлюється. Якщо захворієте, залишайтеся вдома й лежіть. Грип заразний, тож не йдіть ні на роботу, ні до школи. Якщо висока температура тримається понад три дні, зателефонуйте своєму сімейному лікареві.''',
         questions=[
             ('Коли обов’язково треба мити руки?', ['Після громадського транспорту й перед їжею', 'Лише вранці', 'Після сну'], 'Після громадського транспорту й перед їжею'),
             ('Скільки годин радять спати?', ['Щонайменше сім', 'П’ять', 'Десять'], 'Щонайменше сім'),
             ('Кому телефонувати, якщо температура тримається понад три дні?', ['Своєму сімейному лікареві', 'Сусідові', 'На роботу'], 'Своєму сімейному лікареві'),
         ]),
    dict(key='old13_flat', code='RD-A2-013', type='email', situation='housing', module=9,
         title=('Проблема в квартирі', 'Problem u stanu'),
         hr='''Poštovani gospodine Horvat,
pišem Vam jer već tri dana u kupaonici curi voda ispod umivaonika. Zatvorila sam slavinu, ali voda opet kapa, a odvod je začepljen. Na podu je stalno voda i strah me je da će proći do susjeda ispod nas. Također, perilica rublja se pokvarila prošle subote, a u spremištu u podrumu ima puno vlage i plijesni. Molim Vas da što prije pošaljete vodoinstalatera. Kod kuće sam svaki dan poslije 16 sati, a u subotu cijeli dan. Ako je kvar hitan, nazvat ću hitnu intervenciju, a račun ću Vam poslati.
Unaprijed hvala.
Lijep pozdrav,
Olena Kovalenko''',
         ua='''Шановний пане Хорвате!
Пишу вам, бо вже три дні у ванній тече вода під умивальником. Я закрила кран, але вода знову капає, а злив засмічений. На підлозі постійно вода, і я боюся, що вона протече до сусідів під нами. Також минулої суботи зламалася пральна машина, а в коморі в підвалі багато вогкості й плісняви. Прошу вас якнайшвидше надіслати сантехніка. Я вдома щодня після 16-ї години, а в суботу — цілий день. Якщо поломка термінова, я викличу аварійну службу, а рахунок надішлю вам.
Заздалегідь дякую.
З найкращими побажаннями,
Олена Коваленко''',
         questions=[
             ('Що сталося у ванній?', ['Під умивальником тече вода', 'Не працює світло', 'Розбилося дзеркало'], 'Під умивальником тече вода'),
             ('Що ще не так?', ['Зламалася пральна машина, а в коморі пліснява', 'Не зачиняються вікна', 'Немає опалення'], 'Зламалася пральна машина, а в коморі пліснява'),
             ('Коли Олена вдома?', ['Щодня після 16-ї, а в суботу цілий день', 'Лише в неділю', 'Щоранку до 8-ї'], 'Щодня після 16-ї, а в суботу цілий день'),
         ]),
    dict(key='old18_likes', code='RD-A2-018', type='story', situation='small_talk', module=10,
         title=('Що мені подобається в Хорватії', 'Što mi se sviđa u Hrvatskoj'),
         hr='''Živim u Hrvatskoj dvije godine i često me pitaju što mi se ovdje najviše sviđa. Prvo, more! Nikad prije nisam vidjela tako čisto i plavo more. Drugo, čini mi se da se ljudi ovdje manje žure. Kava s prijateljima može trajati dva sata i to nikome ne smeta. Osim toga, hrana je odlična: riba, maslinovo ulje, domaće povrće. Naravno, nije sve tako lijepo. Papiri u uredima ponekad idu sporo, a ljeti je previše turista. Iako mi nekad nedostaje dom, uvjerena sam da je dobro što sam došla baš ovdje.''',
         ua='''Я живу в Хорватії два роки, і мене часто питають, що мені тут найбільше подобається. По-перше, море! Ніколи раніше я не бачила такого чистого й синього моря. По-друге, мені здається, що люди тут менше поспішають. Кава з друзями може тривати дві години, і це нікому не заважає. Крім того, їжа чудова: риба, оливкова олія, домашні овочі. Звісно, не все таке гарне. Папери в установах іноді рухаються повільно, а влітку забагато туристів. Хоча іноді я сумую за домом, я переконана, що добре, що я приїхала саме сюди.''',
         questions=[
             ('Що вона каже про людей у Хорватії?', ['Вони менше поспішають', 'Вони дуже серйозні', 'Вони мало говорять'], 'Вони менше поспішають'),
             ('Скільки може тривати кава з друзями?', ['Дві години', 'Десять хвилин', 'Цілий день'], 'Дві години'),
             ('Що їй не подобається?', ['Повільні папери в установах і забагато туристів улітку', 'Їжа', 'Море'], 'Повільні папери в установах і забагато туристів улітку'),
         ]),
    dict(key='old19_festival', code='RD-A2-019', type='news', situation='cafe_restaurant', module=14,
         title=('Фестиваль у Загребі', 'Festival u Zagrebu'),
         hr='''Ovog vikenda u Zagrebu je Festival hrane i vina. Na Trgu bana Jelačića bit će više od pedeset štandova s domaćim proizvodima iz cijele Hrvatske. Posjetitelji će moći probati sireve, pršut, med i vina iz Istre, Slavonije i Dalmacije. Za djecu će biti predstave i društvene igre, a navečer koncert tamburaša i klape. Festival je otvoren od petka do nedjelje, od 10 do 22 sata, a ulaz je besplatan. Prema najavi, doći će više od dvadeset tisuća posjetitelja. Ako vrijeme bude loše, festival se seli na tržnicu Dolac.''',
         ua='''Цими вихідними в Загребі — Фестиваль їжі й вина. На площі бана Єлачича буде понад п’ятдесят стендів із домашніми продуктами з усієї Хорватії. Відвідувачі зможуть скуштувати сири, пршут, мед і вина з Істрії, Славонії та Далмації. Для дітей будуть вистави й настільні ігри, а ввечері — концерт тамбурашів і клапи. Фестиваль працює з п’ятниці до неділі, з 10 до 22 години, а вхід безкоштовний. За анонсом, прийде понад двадцять тисяч відвідувачів. Якщо погода буде погана, фестиваль переїде на ринок Долац.''',
         questions=[
             ('Скільки буде стендів?', ['Понад п’ятдесят', 'Десять', 'Двісті'], 'Понад п’ятдесят'),
             ('Скільки коштує вхід?', ['Вхід безкоштовний', 'П’ять євро', 'Десять євро'], 'Вхід безкоштовний'),
             ('Що буде, якщо погода буде погана?', ['Фестиваль переїде на ринок Долац', 'Фестиваль скасують', 'Фестиваль перенесуть на понеділок'], 'Фестиваль переїде на ринок Долац'),
         ]),
]

TEXT_ANN: dict[str, str] = {
    'old07_bank': '''
tekući = tekući račun | A.sg.m+mw
web-stranici = web-stranica | L.sg
redu = broj u redu | L.sg+mw
pričekajte = pričekati | im2p
potvrdu = potvrda | A.sg
osobnu = osobna iskaznica | A.sg.f+mw
iskaznicu = osobna iskaznica | A.sg+mw
oib-u = potvrda o OIB-u | L.sg+mw
prebivalištu = prebivalište | L.sg
poslodavcem = poslodavac | I.sg
drugom = drugi | L.sg.n
pismu = pismo | L.sg
internetsko = internetsko bankarstvo | N.sg.n+mw
mobilno = mobilno bankarstvo | N.sg.n+mw
bankarstvo = mobilno bankarstvo | mw
e-poštu = e-pošta | A.sg
''',
    'old08_missing': '''
primili = primiti | lp.m.pl
privremeni = privremeni boravak | A.sg.m+mw
boravak = privremeni boravak | mw
prilogu = u prilogu | mw
zahtjeva = zahtjev | G.sg
nedostaje = nedostajati | pr3s
zdravstvenom = zdravstveno osiguranje | L.sg.n+mw
osiguranju = zdravstveno osiguranje | L.sg+mw
ovim = ovim putem | mw
putem = ovim putem | mw
tražimo = tražiti | pr1p
dopunu = dopuna zahtjeva | A.sg+mw
pisarnici = pisarnica | L.sg
omotnicu = omotnica | A.sg
upišite = upisati | im2p
urudžbeni = urudžbeni broj | A.sg.m+mw
predmeta = predmet | G.sg | справа (в установі)
pošaljite = poslati | im2p
presliku = preslika | A.sg
koju = koji | A.sg.f
ovjerio = ovjeriti | lp.m.sg
javni = javni bilježnik | N.sg.m+mw
bilježnik = javni bilježnik | mw
dopunu = dopuna zahtjeva | A.sg+mw
stigne = stići | pr3s
nećemo = htjeti | fut1p | ~заперечення: «nećemo» = ne + ćemo
nazovite = nazvati | im2p
službenu = službena osoba | A.sg.f+mw
osobu = službena osoba | A.sg+mw
radnim = radnim danom | mw
danom = radnim danom | mw
strance = stranac | A.pl
s = s poštovanjem | mw
poštovanjem = s poštovanjem | I.sg+mw
''',
    'old10_winter': '''
prehladi = prehladiti se | pr3s
govore = govoriti | pr3p
najvažnije = važan | sup
javnog = javni prijevoz | G.sg.m+mw
prijevoza = javni prijevoz | G.sg+mw
zdrava = zdrava prehrana | N.sg.f+mw
prehrana = zdrava prehrana | mw
pomaže = pomagati | pr3s
voća = voće | G.sg
povrća = povrće | G.sg
tekućine = piti puno tekućine | G.sg+mw
najbolje = dobar | sup
prošetajte = prošetati | im2p
svježem = svježi zrak | L.sg.m+mw
zraku = svježi zrak | L.sg+mw
lakše = lak | comp
oporavi = oporaviti se | pr3s
razbolite = razboljeti se | pr2p
ležite = ležati | im2p
zarazna = zarazan | N.sg.f
visoku = visok | A.sg.f
dulje = dug | comp | ~довше
svog = svoj | G.sg.m
izabranog = izabrani liječnik | G.sg.m+mw
liječnika = izabrani liječnik | G.sg+mw
''',
    'old13_flat': '''
pišem = pisati | pr1s
umivaonika = umivaonik | G.sg
zatvorila = zatvoriti | lp.f.sg
slavinu = slavina | A.sg
kapa = kapati | pr3s
podu = pod | L.sg
strah = strah me je | mw
me = strah me je | mw
susjeda = susjed | G.sg
perilica = perilica rublja | mw
rublja = perilica rublja | G.sg+mw
pokvarila = pokvariti se | lp.f.sg
subote = subota | G.sg
spremištu = spremište | L.sg
podrumu = podrum | L.sg
vlage = vlaga | G.sg
plijesni = plijesan | G.sg
pošaljete = poslati | pr2p
vodoinstalatera = vodoinstalater | A.sg
cijeli = cijeli | A.sg.m
nazvat = nazvati | fut1s | ~«nazvat ću» = nazvati ću
hitnu = hitna intervencija | A.sg.f+mw
intervenciju = hitna intervencija | A.sg+mw
''',
    'old18_likes': '''
čini = čini mi se da | mw
žure = žuriti se | pr3p
nikome = nitko | D.sg
smeta = smetati | pr3s
osim = osim toga | mw
toga = osim toga | mw
odlična = odličan | N.sg.f
maslinovo = maslinovo ulje | N.sg.n+mw
ulje = maslinovo ulje | mw
domaće = domaći | N.pl.n
lijepo = lijep | N.sg.n
papiri = papir | N.pl
uredima = ured | L.pl
sporo = spor | adv
turista = turist | G.pl
čisto = čist | A.sg.n
plavo = plav | A.sg.n
uvjerena = uvjeren sam da | N.sg.f+mw
''',
    'old19_festival': '''
ovog = ovaj | G.sg.m
vikenda = vikend | G.sg
zagrebu = Zagreb | L.sg
hrane = hrana | G.sg
vina = vino | родовий відмінок однини («festival vina»); тут також знахідний множини («probati vina»)
trgu = Trg bana Jelačića | L.sg+mw
bana = Trg bana Jelačića | mw
jelačića = Trg bana Jelačića | mw
štandova = štand | G.pl
domaćim = domaći | I.pl
proizvodima = proizvod | I.pl
cijele = cijeli | G.sg.f
posjetitelji = posjetitelj | N.pl
sireve = sir | A.pl
istre = Istra | G.sg
slavonije = Slavonija | G.sg
dalmacije = Dalmacija | G.sg
djecu = djeca | A.sg
predstave = predstava | N.pl
društvene = društvene igre | N.pl.f+mw
igre = društvene igre | mw
tamburaša = tamburaši | G.pl
klape = klapa | G.sg
petka = petak | G.sg
nedjelje = nedjelja | G.sg
sata = sat | pauc
prema = prema najavi | mw
najavi = prema najavi | L.sg+mw
tisuća = tisuća | G.pl
posjetitelja = posjetitelj | G.pl
bude = biti | ~«ako bude» — якщо буде (майбутній час після «ako»)
loše = loš | N.sg.n
seli = seliti se | pr3s
tržnicu = tržnica | A.sg
''',
}

# Власні назви, яких немає в reading_lexicon_a2_v2.NAMES: як у тексті → (частина мови, пояснення)
NAMES: dict = {'Trg bana Jelačića': ('place', 'площа бана Єлачича — головна площа Загреба')}
