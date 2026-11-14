"""
Словничок для 36 нових текстів A2 v2 (scripts/gen_reading_a2_v2.py) · 2026-11-13.

  TEXT_ANN — форми кожного тексту (ключ — key тексту в reading_data_a2_v2.py), по рядку:
             «форма = лема | граматика | переклад»; граматика й переклад — необов'язкові.
             Лема — як у словнику застосунку (lexemes), разом зі сталими виразами («tuš kabina»).
             Коди граматики — як у reading_grammar.py (G.sg, pr3p, lp.f.sg, im2p, pauc, fut1s…) і ще:
             mw — частина сталого виразу; «G.sg+mw» — відмінок і частина виразу; inf — інфінітив;
             comp / sup — вищий / найвищий ступінь; adv — прислівник; cond1s…cond3p — умовний спосіб; im1p.
             Після « | » у коді граматики можна дописати пояснення українською.
  COMMON   — форми, однакові в багатьох текстах (той самий формат).
  EXTRA    — леми, яких немає в уроках A0–A2 (або потрібне інше значення): лема → переклад;
  KNOWN    — леми з EXTRA, які вважаємо знайомими (службові слова й прозорі інтернаціоналізми);
  POS      — частина мови для лем без неї в reading_grammar.py і в знімку бази;
  NAMES    — власні назви: як у тексті → (частина мови, пояснення).
Переклади слів уроків — зі знімка бази (reading_a2_v2_snapshot.json), тут їх не повторюємо.
"""

COMMON = '''
je = biti | pr3s
su = biti | pr3p
sam = biti | pr1s
smo = biti | pr1p
ste = biti | pr2p
si = biti | pr2s
nisam = nije | pr1s | не (я не …; заперечення biti)
nismo = nije | pr1p | не (ми не …; заперечення biti)
nisu = nije | pr3p | не (вони не …; заперечення biti)
'''

TEXT_ANN: dict[str, str] = {
    'm01_complaint': '''
poštovani = poštovani | V.sg.m
gospodine = gospodin | V.sg
babiću = Babić | V.sg
stigli = stići | lp.m.pl
makarskoj = Makarska | L.sg
odlična = odličan | N.sg.f
problema = problem | G.pl
klima-uređaj = klima-uređaj
funkcionira = ne funkcionira | mw
kupaonici = kupaonica | L.sg
curi = curiti | pr3s
kabine = tuš kabina | G.sg+mw
prozoru = prozor | L.sg
mrežice = mrežica protiv komaraca | G.sg+mw
komaraca = komarac | G.pl
možemo = moći | pr1p
oglasu = oglas | L.sg
pisalo = pisati | lp.n.sg
došao = doći | lp.m.sg
riješite = riješiti problem | pr2p+mw
premjestite = premjestiti | pr2p
drugi = drugi | A.sg.m
moguće = moguć | N.sg.n
htjeli = htjeti | lp.m.pl
bismo = biti | cond1p
predujma = predujam | G.sg
nas = mi | A.pl | нас
''',
    'm01_ferry': '''
putnicima = putnik | D.pl
nevremena = nevrijeme | G.sg
prekid = prekid plovidbe | mw
plovidbe = prekid plovidbe | G.sg+mw
trajektnoj = trajektna linija | L.sg.f+mw
liniji = trajektna linija | L.sg+mw
trajekti = trajekt | N.pl
neće = htjeti | fut3p | ~заперечення: «neće» = ne + će
putnici = putnik | N.pl
kupili = kupiti | lp.m.pl
kartu = karta | A.sg
mogu = moći | pr3p
blagajni = blagajna | L.sg
vozači = vozač | N.pl
čekaju = čekati u koloni | pr3p+mw
koloni = čekati u koloni | L.sg+mw
ostanu = ostati | pr3p
prate = pratiti | pr3p
obavijesti = obavijest | A.pl
kad = kada | коротка форма від «kada» — коли
će = htjeti | fut3s
redu = red vožnje | D.sg+mw
vožnje = red vožnje | G.sg+mw
jadrolinije = Jadrolinija | G.sg
pitajte = pitati | im2p
lučkoj = lučka kapetanija | L.sg.f+mw
kapetaniji = lučka kapetanija | L.sg+mw
razumijevanju = razumijevanje | L.sg
bure = bura | G.sg
vozi = voziti | pr3s
njom = ona | I.sg | з ним (тут — з квитком: karta — ж. р.)
autima = auto | L.pl
prođe = proći | pr3s
više = više | adv | більше («više o tome» — докладніше про це)
tome = to | L.sg | про це
pročitajte = pročitati | im2p
stranici = stranica | L.sg
''',
    'm02_course': '''
tečajevi = tečaj | N.pl
hrvatskog = hrvatski | G.sg.m
jezika = jezik | G.sg
odrasle = odrasli | A.pl
pučko = pučko otvoreno učilište | mw
otvoreno = pučko otvoreno učilište | mw
učilište = pučko otvoreno učilište | mw
poziva = pozivati | pr3s
polaznike = polaznik | A.pl
nudimo = nuditi | pr1p
početni = početni tečaj | mw
početnike = početnik | A.pl
puta = put | pauc
sati = sat | G.pl
večernji = večernji tečaj | mw
napredni = napredni tečaj | mw
ponedjeljkom = ponedjeljak | I.sg | по понеділках
srijedom = srijeda | I.sg | по середах
individualnu = individualna nastava | A.sg.f+mw
nastavu = individualna nastava | A.sg+mw
dogovoru = dogovor | L.sg
radimo = raditi | pr1p
malim = mala grupa | L.pl.f+mw
grupama = mala grupa | L.pl+mw
polaznika = polaznik | G.pl
upisa = upis | G.sg
svi = sav | N.pl.m
polaznici = polaznik | N.pl
pišu = pisati | pr3p
test = test razine | mw
razine = test razine | G.sg+mw
eura = euro | G.pl
tečaju = tečaj | L.sg
moguće = moguć | N.sg.n
plaćanje = plaćanje u ratama | mw
ratama = plaćanje u ratama | L.pl+mw
kraju = kraj | L.sg
tečaja = tečaj | G.sg
dobivate = dobiti | pr2p | отримувати (недоконаний вид: dobivati)
potvrdu = potvrda o pohađanju | A.sg+mw
pohađanju = potvrda o pohađanju | L.sg+mw
možete = moći | pr2p
upisi = upis | N.pl
traju = trajati | pr3p
siječnja = siječanj | G.sg
''',
    'm02_diploma': '''
inozemne = inozemna kvalifikacija | G.sg.f+mw
kvalifikacije = inozemna kvalifikacija | G.sg+mw
poštovana = poštovani | V.sg.f
gospođo = gospođa | V.sg
vaš = vaš | A.sg.m
akademsko = akademsko priznavanje | A.sg.n+mw
diplome = diploma | G.sg
molimo = molim | pr1p | просимо (molimo Vas — просимо Вас)
vas = vi | A.pl | Вас (ввічливо)
dopunite = dopuniti | pr2p
priložite = priložiti | pr2p
sljedeće = sljedeći | A.pl.m
dokumente = dokument | A.pl
ovjerenu = ovjerena preslika | A.sg.f+mw
presliku = ovjerena preslika | A.sg+mw
pečatom = pečat | I.sg
dodatak = dodatak diplomi | mw
diplomi = dodatak diplomi | D.sg+mw
prijepis = prijepis ocjena | mw
ocjena = prijepis ocjena | G.pl+mw
ovjereni = ovjereni prijevod | mw
možete = moći | pr2p
poštom = pošta | I.sg
dana = dan | G.pl
rješenja = rješenje | G.sg
trebate = trebati | pr2p
upravnu = upravna pristojba | A.sg.f+mw
pristojbu = upravna pristojba | A.sg+mw
poštovanjem = s poštovanjem | I.sg+mw
primili = primiti | lp.m.pl
zahtjevu = zahtjev | L.sg
nedostaju = nedostajati | pr3p
neki = neki | N.pl.m
dokumenti = dokument | N.pl
ćete = htjeti | fut2p
roku = rok | L.sg
izdavanja = izdavanje | G.sg
''',
    'm02_school': '''
poštovani = poštovani | N.pl.m
roditelji = roditelj | N.pl
podsjećam = podsjećati | pr1s
izlet = izlet razreda | mw
razreda = izlet razreda | G.sg+mw
plitvička = Plitvička jezera | mw
jezera = Plitvička jezera | A.pl+mw
škole = škola | G.sg
sati = sat | G.pl
djeca = dijete | N.pl | діти (множина від dijete)
trebaju = trebati | pr3p
marendu = marenda | A.sg
vodu = voda | A.sg
udobnu = udobna obuća | A.sg.f+mw
obuću = udobna obuća | A.sg+mw
potrebna = potreban | N.sg.f
potpisana = potpisati | N.sg.f | ~дієприкметник від «potpisati»: підписана
suglasnost = suglasnost roditelja | mw
roditelja = suglasnost roditelja | G.pl+mw
pošaljete = poslati | pr2p
srijede = srijeda | G.sg
obavještavam = obavještavati | pr1s
ocjene = ocjena | N.pl
prvog = prvi | G.sg.n
polugodišta = polugodište | G.sg
upisane = upisati | N.pl.f | ~дієприкметник від «upisati»: внесені
neki = neki | N.pl.m
učenici = učenik | N.pl
imaju = imati | pr3p
izostanke = izostanak | A.pl
opravdani = opravdati | N.pl.m | ~дієприкметник від «opravdati»: виправдані
liječničku = liječnička ispričnica | A.sg.f+mw
ispričnicu = liječnička ispričnica | A.sg+mw
treba = trebati | pr3s
roku = rok | L.sg
dana = dan | G.pl | ~«tjedan dana» — тиждень
''',
    'm02_activities': '''
koje = koji | A.pl.f
izvanškolske = izvanškolske aktivnosti | A.pl+mw
aktivnosti = izvanškolske aktivnosti | A.pl+mw
ide = ići | pr3s
tvoja = tvoj | N.sg.f
glazbenu = glazbena škola | A.sg.f+mw
školu = škola | A.sg
želi = željeti | pr3s
upisati = upisati se | inf
znam = znati | pr1s
kolika = koliki | N.sg.f
eura = euro | G.pl
mislim = misliti | pr1s
treninzi = trening | N.pl
puta = put | pauc
redu = u redu | mw
tražim = tražiti | pr1s
učenju = pomoć u učenju | L.sg+mw
ima = imati | pr3s
problema = problem | G.pl
gramatikom = gramatika | I.sg
školi = škola | L.sg
besplatna = besplatan | N.sg.f
pitaj = pitati | im2s
razrednika = razrednik | A.sg
znala = znati | lp.f.sg
cjelodnevni = cjelodnevni boravak | A.sg.m+mw
boravak = cjelodnevni boravak | mw
ručaju = ručati | pr3p
pišu = pisati | pr3p
zadaću = zadaća | A.sg
igraju = igrati se | pr3p
informacijama = informacije | L.pl | інформація (у школі «informacije» — ще й день консультацій з учителем)
imaju = imati | pr3p
dopunsku = dopunska nastava | A.sg.f+mw
nastavu = dopunska nastava | A.sg+mw
''',
    'm03_childhood': '''
odrastala = odrastati | lp.f.sg
malom = mali | L.sg.m
gradu = grad | L.sg
odese = Odesa | G.sg
djetinjstvu = djetinjstvo | L.sg
ljeta = ljeto | A.pl
provodila = provoditi | lp.f.sg
bake = baka | G.sg
selu = selo | L.sg
cijele = cijele dane | mw
dane = cijele dane | mw
igrali = igrati se | lp.m.pl
bile = biti | lp.f.pl
naše = naš | N.pl.f
omiljene = omiljen | N.pl.f
igre = igra | N.pl
bila = biti | lp.f.sg
nestašna = nestašan | N.sg.f
penjala = penjati se | lp.f.sg
pala = pasti | lp.f.sg
ogrebala = ogrebati se | lp.f.sg | ~тут без se: «ogrebati koljeno» — подряпати коліно
plakala = plakati | lp.f.sg
nam = mi | D.pl | нам
pričala = pričati | lp.f.sg
priče = priča za laku noć | A.pl+mw
laku = priča za laku noć | A.sg.f+mw
imali = imati | lp.m.pl
mobitele = mobitel | A.pl
bili = biti | lp.m.pl
bezbrižni = bezbrižan | N.pl.m
sretni = sretan | N.pl.m
moja = moj | N.sg.f
odrasta = odrastati | pr3s
zagrebu = Zagreb | L.sg
kad = kada | коротка форма від «kada» — коли
pričam = pričati | pr1s
svom = svoj | L.sg.n
vjeruje = vjerovati | pr3s
''',
    'm03_moving': '''
godine = godina | pauc
spakirala = spakirati | lp.f.sg
napustila = napustiti | lp.f.sg
rodno = rodno mjesto | A.sg.n+mw
mjesto = rodno mjesto | mw
bilo = biti | lp.n.sg
kuću = kuća | A.sg
prijatelje = prijatelj | A.pl
prvi = prvi mjeseci | mw
mjeseci = prvi mjeseci | N.pl+mw
hrvatskoj = Hrvatska | L.sg
bili = biti | lp.m.pl
puni = pun | N.pl.m
neizvjesnosti = neizvjesnost | G.sg
znala = znati | lp.f.sg
osjećala = osjećati se izgubljeno | lp.f.sg+mw
izgubljeno = osjećati se izgubljeno | mw
samoće = samoća | G.sg
susjedi = susjed | N.pl
velika = velik | N.sg.f
pomogla = pomoći | lp.f.sg
pokazao = pokazati | lp.m.sg
priviknula = priviknuti se | lp.f.sg
novi = nov | A.sg.m
kad = kada | коротка форма від «kada» — коли
našla = naći | lp.f.sg
osjetila = osjetiti | lp.f.sg
veliko = velik | A.sg.n
mom = moj | L.sg.m
životu = život | L.sg
ponosna = ponosan | N.sg.f
svoju = svoj | A.sg.f
''',
    'm04_wedding': '''
prošlog = prošli | G.sg.m
mjeseca = mjesec | G.sg
bila = biti | lp.f.sg
svadbi = svadba | L.sg
svoje = svoj | G.sg.f
kolegice = kolegica | G.sg
ane = Ana | G.sg
šibeniku = Šibenik | L.sg
imala = imati | lp.f.sg
dugu = dug | A.sg.f
bijelu = bijel | A.sg.f
haljinu = haljina | A.sg
tamnoplavo = tamnoplav | A.sg.n
bilo = biti | lp.n.sg
staroj = star | L.sg.f
crkvi = crkva | L.sg
restoranu = restoran | L.sg
svatova = svatovi | G.pl
običaju = običaj | D.sg
gosti = gost | N.pl
mladencima = mladenci | D.pl
dali = dati | lp.m.pl
omotnicu = omotnica s novcem | A.sg+mw
novcem = omotnica s novcem | I.sg+mw
održao = održati | lp.m.sg
zdravicu = zdravica | A.sg
svi = sav | N.pl.m
podigli = podići čašu | lp.m.pl+mw
čaše = podići čašu | A.pl+mw
viknuli = viknuti | lp.m.pl
otvorili = otvoriti | lp.m.pl
plesali = plesati | lp.m.pl
jutra = jutro | G.sg
umorna = umoran | N.sg.f
sretna = sretan | N.sg.f
kaže = kazati | pr3s
najljepša = lijep | N.sg.f | ~найвищий ступінь: найгарніша
kojoj = koji | L.sg.f
''',
    'm04_tenants': '''
stanarima = stanar | D.pl
poštovani = poštovani | N.pl.m
stanara = sastanak stanara | G.pl+mw
studenoga = studeni | G.sg
sati = sat | G.pl
prizemlju = prizemlje | L.sg
glasna = glasna glazba | N.sg.f+mw
molimo = molim | pr1p | просимо
stanare = stanar | A.pl
sata = sat | pauc
utišaju = utišati | pr3p
dvorištu = dvorište | L.sg
neki = neki | N.pl.m
stanari = stanar | N.pl
parkiraju = parkirati se | pr3p
ulaza = ulaz u zgradu | G.sg+mw
zgradu = ulaz u zgradu | A.sg+mw
stanu = vlaga u stanu | L.sg+mw
drugom = drugi | L.sg.m
katu = kat | L.sg
možete = moći | pr2p
svoje = svoj | A.pl.m
prijedloge = prijedlog | A.pl
ih = oni | A.pl | їх
pošaljite = poslati | im2p
predstavnik = predstavnik suvlasnika | mw
suvlasnika = predstavnik suvlasnika | G.pl+mw
bit = biti | inf | ~без -i перед «će»: «bit će» — буде
će = htjeti | fut3s
zgrade = zgrada | G.sg
sastanku = sastanak | L.sg
ćemo = htjeti | fut1p
ovome = ovaj | L.sg.n | про це, про таке
glazbu = glasna glazba | A.sg+mw
glazba = glasna glazba | mw
auti = auto | N.pl
zajednički = zajednički prostor | mw
prostor = zajednički prostor | mw
ga = on | A.sg | його
čisti = čistiti | pr3s
ostavite = ostaviti | im2p
oglasnoj = oglasna ploča | L.sg.f+mw
ploči = oglasna ploča | L.sg+mw
e-mailom = mail | I.sg
''',
    'm05_deadline': '''
poštovana = poštovani | V.sg.f
gospođo = gospođa | V.sg
vezano = vezano uz | mw
novu = nov | A.sg.f
internetsku = internetski | A.sg.f
stranicu = stranica | A.sg
ispričavam = ispričavam se zbog kašnjenja | mw
kašnjenja = ispričavam se zbog kašnjenja | G.sg+mw
kasnimo = kasniti s rokom | pr1p+mw
rokom = kasniti s rokom | I.sg+mw
poslao = poslati | lp.m.sg
fotografije = fotografija | A.pl
vas = vi | A.pl | Вас (ввічливо)
pomaknemo = pomaknuti rok | pr1p+mw
krajnji = krajnji rok | mw
petka = petak | G.sg
sljedeću = sljedeći | A.sg.f
srijedu = srijeda | A.sg
ću = htjeti | fut1s
vam = vi | D.pl | Вам (ввічливо)
kratak = kratak sažetak | mw
sažetak = kratak sažetak | mw
privitku = u privitku | mw
imate = imati | pr2p
dodatna = dodatna pitanja | A.pl.n+mw
pitanja = dodatna pitanja | mw
stojim = stojim na raspolaganju | mw
raspolaganju = stojim na raspolaganju | mw
zahvaljujem = unaprijed zahvaljujem | mw
poštovanjem = s poštovanjem | I.sg+mw
novi = nov | N.sg.m
vaše = vaš | G.sg.f
tvrtke = tvrtka | G.sg
voditeljica = voditelj projekta | N.sg+mw | ~жіноча форма: voditeljica — керівниця
projekta = voditelj projekta | G.sg+mw
''',
    'm05_obrt': '''
hrvatskoj = Hrvatska | L.sg
trebate = trebati | pr2p
poslovni = poslovni plan | A.sg.m+mw
ćete = htjeti | fut2p
koliki = koliki | N.sg.m
će = htjeti | fut3s
troškovi = trošak | N.pl
može = moći | pr3s
upisuje = upisivati | pr3s
obrtni = obrtni registar | A.sg.m+mw
registar = obrtni registar | mw
početnici = početnik | N.pl
paušalni = paušalni obrt | mw
manji = mali | N.sg.m | ~вищий ступінь від «mali»: менший
važno = važan | N.sg.n
mora = morati | pr3s
izdati = izdati račun | mw
nezaposleni = nezaposlen | N.pl.m
potporu = potpora | A.sg
stranaca = stranac | G.pl
želi = željeti | pr3s | ~«puno stranaca želi» — після «puno» дієслово в однині
najčešće = često | sup | найчастіше
otvara = otvarati | pr3s | ~«otvara se» — відкривають
izaberu = izabrati | pr3p
papira = papir | G.sg
pravila = pravilo | A.pl
fiskalizacije = fiskalizacija | G.sg
vam = vi | D.pl | вам
zavod = Zavod za zapošljavanje | mw
zapošljavanje = Zavod za zapošljavanje | mw
''',
    'm06_hairdresser': '''
jeste = biti | pr2p | ~наголошена форма в питанні: «Jeste li …?» — Ви …?
naručeni = naručiti se | N.pl.m | ~дієприкметник: записані (на прийом)
jesam = biti | pr1s | ~наголошена форма: «Jesam» — так (відповідь)
želite = željeti | pr2p
htjela = htjeti | lp.f.sg
bih = biti | cond1s
ošišati = ošišati se | inf
skratite = skratiti | im2p
centimetra = centimetar | pauc
može = moći | pr3s
bojanje = bojanje kose | mw
kose = bojanje kose | G.sg+mw
pramenove = pramenovi | A.pl
će = htjeti | fut3s
eura = euro | G.pl
redu = u redu | mw
mogu = moći | pr1s
karticom = kartica | I.sg
sjednite = sjesti | im2p
''',
    'm06_notary': '''
trebate = trebati | pr2p
primjer = na primjer | mw
punomoći = punomoć | L.sg
izjavi = izjava | L.sg
suglasnosti = suglasnost za putovanje djeteta | L.sg+mw
putovanje = suglasnost za putovanje djeteta | mw
djeteta = dijete | G.sg
radi = raditi | pr3s
javnobilježničkom = javnobilježnički ured | L.sg.m+mw
uredu = ured | L.sg
ponesite = ponijeti | im2p
važeći = važeći | A.sg.m
osobnu = osobna iskaznica | A.sg.f+mw
iskaznicu = iskaznica | A.sg
putovnicu = putovnica | A.sg
stranca = stranac | G.sg
potpisujte = potpisivati | im2p
kuće = kuća | G.sg
potpisat = potpisati | inf | ~без -i перед «ćete»: «potpisat ćete» — ви підпишете
ćete = htjeti | fut2p
bilježnikom = bilježnik | I.sg
stranom = strani jezik | L.sg.m+mw
jeziku = jezik | L.sg
će = htjeti | fut3s
ovjera = ovjera prijevoda | mw
prijevoda = ovjera prijevoda | G.sg+mw
vaš = vaš | A.sg.m
platite = platiti | im2p
javnobilježničku = javnobilježnička pristojba | A.sg.f+mw
pristojbu = javnobilježnička pristojba | A.sg+mw
različita = različit | N.sg.f
različite = različit | A.pl.m
dokumente = dokument | A.pl
nazovite = nazvati | im2p
pitajte = pitati | im2p
naručiti = naručiti se | inf
''',
    'm07_sickchild': '''
gospodine = gospodin | V.sg
moj = moj | N.sg.m
crijevnu = crijevna viroza | A.sg.f+mw
virozu = crijevna viroza | A.sg+mw
povraćao = povraćati | lp.m.sg
cijelu = cijel | A.sg.f
temperaturu = temperatura | A.sg
mogu = moći | pr1s
ostanite = ostati | im2p
njim = on | I.sg | ним (з ним)
kaže = kazati | pr3s
smije = smjeti | pr3s
dana = dan | pauc
zarazna = zarazan | N.sg.f
otvorit = otvoriti bolovanje | inf+mw | ~без -i перед «ću»: «otvorit ću» — я відкрию
ću = htjeti | fut1s
radi = bolovanje radi njege djeteta | mw | ~тут прийменник «radi» — заради, для (+ родовий)
njege = njega djeteta | G.sg+mw
djeteta = dijete | G.sg
redu = u redu | mw
javite = javiti se | im2p
saznate = saznati | pr2p
ćete = htjeti | fut2p
odsutni = odsutan | N.pl.m | ~тут увічливе «Ви»
hoću = htjeti | pr1s | ~«Hoću» — добре, так і зроблю
kuće = kuća | G.sg
najvažnije = važan | A.pl.m | ~найвищий ступінь: найважливіші
e-mailove = mail | A.pl
potrebe = potreba | G.sg
odmorite = odmoriti se | im2p
ozdravi = brzo ozdravi | mw
vam = vi | D.pl | Вам (ввічливо)
''',
    'm07_stress': '''
više = sve više | mw
ljudi = ljudi | N.pl
živi = živjeti | pr3s
stresom = pod stresom | I.sg+mw
takvi = takav | N.pl.m
spavaju = loše spavati | pr3p+mw
bude = buditi se noću | pr3p+mw
premoreni = premoren | N.pl.m
usredotočiti = usredotočiti se | inf
postaju = postajati | pr3p
napeti = napet | N.pl.m
razdražljivi = razdražljiv | N.pl.m
traje = trajati | pr3s
može = moći | pr3s
izgaranja = izgaranje na poslu | G.sg+mw
poslu = posao | L.sg
liječnici = liječnik | N.pl
savjetuju = savjetovati | pr3p
isključite = isključiti mobitel | pr2p+mw
čitate = čitati | pr2p
poslovne = poslovni | A.pl.m
e-mailove = mail | A.pl
važna = važan | N.sg.f
ravnoteža = ravnoteža posla i života | mw
posla = posao | G.sg
života = život | G.sg
boravak = boravak u prirodi | mw
prirodi = priroda | L.sg
pomažu = pomagati | pr3p
napunimo = napuniti baterije | pr1p+mw
baterije = napuniti baterije | A.pl+mw
vam = vi | D.pl | вам
nemojte = nemoj | im2p | ~«nemojte + інфінітив» — не робіть
psihoterapeutom = psihoterapeut | I.sg
sramiti = sramiti se | inf
zatražiti = zatražiti pomoć | inf+mw
savjetovalištu = savjetovalište | L.sg
mjesecima = mjesec | I.pl | місяцями
im = oni | D.pl | їм
''',
    'm08_licence': '''
živite = živjeti | pr2p
hrvatskoj = Hrvatska | L.sg
stranu = strana vozačka dozvola | A.sg.f+mw
vozačku = strana vozačka dozvola | A.sg.f+mw
dozvolu = dozvola | A.sg
ćete = htjeti | fut2p
hrvatskom = hrvatski | I.sg.f
predaje = predavati | pr3s
policijskoj = policijska uprava | L.sg.f+mw
upravi = policijska uprava | L.sg+mw
mjestu = mjesto | D.sg
boravka = boravak | G.sg
trebate = trebati | pr2p
liječničko = liječničko uvjerenje | N.sg.n+mw
medicine = medicina rada | G.sg+mw
rada = medicina rada | G.sg+mw
fotografiju = fotografija za dokumente | A.sg+mw
dokumente = fotografija za dokumente | A.pl+mw
iskaznicu = iskaznica | A.sg
stranca = stranac | G.sg
putovnicu = putovnica | A.sg
plaćenoj = platiti | L.sg.f | ~дієприкметник: сплаченому (про збір)
pristojbi = pristojba | L.sg
kad = kada | коротка форма від «kada» — коли
predate = predati | pr2p
dobit = dobiti | inf | ~без -i перед «ćete»: «dobit ćete» — ви отримаєте
privremenu = privremena potvrda | A.sg.f+mw
potvrdu = privremena potvrda | A.sg+mw
kojom = koji | I.sg.f
smijete = smjeti | pr2p
novu = nov | A.sg.f
možete = moći | pr2p
tjedana = tjedan | G.pl
pazite = paziti | im2p
istek = istek valjanosti | mw
valjanosti = istek valjanosti | G.sg+mw
strane = strani | G.sg.f
dozvole = dozvola | G.sg
neke = neki | A.pl.f
zemlje = zemlja | A.pl
vrijede = vrijediti | pr3p
posebna = poseban | N.pl.n
pravila = pravilo | N.pl
raspitajte = raspitati se | im2p
''',
    'm08_accident': '''
imala = imati | lp.f.sg
malu = mali | A.sg.f
prometnu = prometna nezgoda | A.sg.f+mw
nezgodu = prometna nezgoda | A.sg+mw
izlazila = izlaziti | lp.f.sg
parkirališta = parkiralište | G.sg
trgovine = trgovina | G.sg
ju = ona | A.sg | її (коротка форма)
udario = udariti straga | lp.m.sg+mw
straga = udariti straga | mw
bio = biti | lp.m.sg
darjinom = Darjin | L.sg.m
autu = auto | L.sg
drugog = drugi | G.sg.m
auta = auto | G.sg
stariji = star | N.sg.m | ~вищий ступінь від «star»: старший, літній
izašao = izaći iz vozila | lp.m.sg+mw
vozila = izaći iz vozila | G.sg+mw
ispričao = ispričati se | lp.m.sg
morali = morati | lp.m.pl
pozvati = pozvati policiju | mw
policiju = pozvati policiju | A.sg+mw
bila = biti | lp.f.sg
materijalna = materijalna šteta | N.sg.f+mw
licu = na licu mjesta | mw
mjesta = na licu mjesta | mw
ispunili = ispuniti | lp.m.pl
europsko = europsko izvješće | A.sg.n+mw
izvješće = europsko izvješće | mw
fotografirala = fotografirati štetu | lp.f.sg+mw
štetu = šteta | A.sg
jedna = jedan | N.sg.f
koja = koji | N.sg.f
vidjela = vidjeti | lp.f.sg
napisala = napisati | lp.f.sg
izjavu = izjava svjedoka | A.sg+mw
svjedoka = izjava svjedoka | G.sg+mw
priznao = priznati | lp.m.sg
platilo = platiti | lp.n.sg
vozača = vozač | G.sg
''',
    'm08_fine': '''
autu = auto | L.sg
prometnog = prometni redar | G.sg.m+mw
redara = prometni redar | G.sg+mw
znači = značiti | pr3s
daj = dati | im2s
vidim = vidjeti | pr1s
nepropisno = nepropisno parkiran | mw
parkirao = parkirati se | lp.m.sg
mjestu = mjesto za invalide | L.sg+mw
invalide = mjesto za invalide | A.pl+mw
vidio = vidjeti | lp.m.sg
velika = velik | N.sg.f
mala = mali | N.sg.f
platiš = platiti | pr2s
roku = rok | L.sg
dana = dan | G.pl
plaćaš = plaćati | pr2s
upola = upola manje | mw
manje = upola manje | mw
smio = smjeti | lp.m.sg
parkirati = parkirati se | inf
parkirnoj = parkirna zona | L.sg.f+mw
zoni = parkirna zona | L.sg+mw
trebaš = trebati | pr2s
parkirnu = parkirna karta | A.sg.f+mw
kartu = karta | A.sg
automatu = automat | L.sg
parking = platiti parking SMS-om | mw
sms-om = platiti parking SMS-om | I.sg+mw
ću = htjeti | fut1s
želim = željeti | pr1s
odvezu = odvesti auto | pr3p+mw
''',
    'm08_usedcar': '''
zovem = zvati | pr1s
oglasa = oglas za auto | G.sg+mw
prodaju = prodaja | A.sg
godine = godina | G.sg
prvi = prvi vlasnik | mw
ima = imati | pr3s
prijeđenih = prijeđeni kilometri | G.pl+mw
kilometara = kilometar | G.pl
tisuća = tisuća | G.pl
imam = imati | pr1s
servisnu = servisna knjižica | A.sg.f+mw
knjižicu = servisna knjižica | A.sg+mw
hrđe = hrđa | G.sg
malu = mali | A.sg.f
ogrebotinu = ogrebotina na braniku | A.sg+mw
braniku = branik | L.sg
registriran = registriran do | mw
svibnja = svibanj | G.sg
kolika = koliki | N.sg.f
potrošnja = potrošnja goriva | mw
goriva = potrošnja goriva | G.sg+mw
litara = litra | G.pl
mogu = moći | pr1s
probnu = probna vožnja | A.sg.f+mw
vožnju = probna vožnja | A.sg+mw
htjela = htjeti | lp.f.sg
bih = biti | cond1s
dovesti = dovesti na pregled | mw
svog = svoj | G.sg.m
mehaničara = mehaničar | G.sg
eura = euro | G.pl
možemo = moći | pr1p
pogađati = pogađati se | inf
''',
    'm09_waste': '''
odvajanje = odvajanje otpada | mw
otpada = otpad | G.sg
našem = naš | L.sg.m
gradu = grad | L.sg
siječnja = siječanj | G.sg
svako = svaki | N.sg.n
mora = morati | pr3s
koristite = koristiti | im2p
ove = ovaj | A.pl.m
spremnike = spremnik | A.pl
žuta = žuta vreća | mw
vreća = žuta vreća | mw
boce = boca | N.pl
limenke = limenka | N.pl
mlijeka = mlijeko | G.sg
plava = plav | N.sg.f
smeđa = smeđa kanta | mw
ostaci = ostaci hrane | mw
hrane = ostaci hrane | G.sg+mw
zeleni = zelen | N.sg.m
crna = crn | N.sg.f
miješani = miješani komunalni otpad | mw
komunalni = miješani komunalni otpad | mw
ambalažu = ambalaža | A.sg
bacanja = bacanje | G.sg
ispraznite = isprazniti | im2p
zgnječite = zgnječiti | im2p
istrošene = istrošene baterije | A.pl.f+mw
baterije = istrošene baterije | A.pl+mw
elektronički = elektronički otpad | mw
glomazni = glomazni otpad | mw
odnesite = odnijeti | im2p
reciklažno = reciklažno dvorište | A.sg.n+mw
dvorište = reciklažno dvorište | mw
raspored = raspored odvoza | mw
odvoza = raspored odvoza | G.sg+mw
nalazi = nalaziti se | pr3s
aplikaciji = aplikacija grada | L.sg+mw
grada = aplikacija grada | G.sg+mw
neodvajanje = kazna za neodvajanje | A.sg+mw
plaća = plaćati | pr3s
''',
    'm09_storm': '''
narančasto = narančasto upozorenje | A.sg.n+mw
upozorenje = narančasto upozorenje | mw
dalmaciju = Dalmacija | A.sg
olujnog = olujni vjetar | G.sg.m+mw
vjetra = vjetar | G.sg
moru = more | L.sg
valovi = val | N.pl
metra = metar | pauc
prekid = prekid plovidbe | mw
plovidbe = prekid plovidbe | G.sg+mw
trebaju = trebati | pr3p
skloniti = skloniti se | inf
sigurno = sigurno mjesto | A.sg.n+mw
mjesto = sigurno mjesto | mw
suhog = suh | G.sg.n
vremena = vrijeme | G.sg
velika = velik | N.sg.f
šumskih = šumski požar | G.pl.m+mw
požara = šumski požar | G.pl+mw
vrijedi = vrijediti | pr3s
zabrana = zabrana loženja vatre | mw
loženja = zabrana loženja vatre | G.sg+mw
vatre = zabrana loženja vatre | G.sg+mw
nazovite = nazvati | im2p
hitne = hitne službe | A.pl.f+mw
službe = hitne službe | A.pl+mw
izdano = izdati | N.sg.n | ~дієприкметник: видано (оголошено)
dolazi = dolaziti | pr3s
će = htjeti | fut3s
problema = problem | G.pl
autocesti = autocesta | L.sg
zatvorite = zatvoriti | im2p
prozore = prozor | A.pl
ostavljajte = ostaviti | im2p | залишайте (недоконаний вид: ostavljati)
stvari = stvar | A.pl
balkonu = balkon | L.sg
opasnosti = opasnost | L.sg
''',
    'm10_review': '''
novi = nov | N.sg.m
ane = Ana | G.sg
govori = govoriti | pr3s
obitelji = obitelj | L.sg
koja = koji | N.sg.f
malom = mali | L.sg.m
otoku = otok | L.sg
glavni = glavni lik | mw
lik = glavni lik | mw
njezinu = njezin | A.sg.f
baku = baka | A.sg
glumi = glumiti | pr3s
poznata = poznat | N.sg.f
početku = na početku | mw
međuvremenu = u međuvremenu | mw
iznenađujući = iznenađujući kraj | mw
neću = htjeti | fut1s | заперечення: «neću» = ne + ću
vam = vi | D.pl | вам
dirljiva = dirljiv | N.sg.f
jedina = jedini | N.sg.f
bolji = bolji nego što sam očekivao | mw
očekivao = bolji nego što sam očekivao | lp.m.sg+mw
volite = voljeti | pr2p
toplo = toplo preporučujem | mw
preporučujem = toplo preporučujem | mw
jedno = jedan | A.sg.n
živi = živjeti | pr3s
više = sve više | mw
napetosti = napetost | G.sg
lijepa = lijep | N.sg.f
vrijedi = vrijediti | pr3s | варто («vrijedi pogledati» — варто подивитися)
''',
    'm10_ads': '''
prodajem = prodavati | pr1s
korišten = malo korišten | mw
eura = euro | G.pl
dogovoru = po dogovoru | mw
sati = sat | G.pl
mačiće = mačić | A.pl
dobre = u dobre ruke | mw
ruke = u dobre ruke | mw
imaju = imati | pr3p
mjeseca = mjesec | pauc
zdravi = zdrav | N.pl.m
veseli = veseo | N.pl.m
hitno = hitno prodajem | mw
osobe = osoba | pauc
preseljenja = preseljenje | G.sg
ozbiljni = ozbiljni kupci | mw
kupci = ozbiljni kupci | mw
javite = javiti se | im2p
porukom = poruka | I.sg
ženu = žena | A.sg
djeteta = dijete | G.sg
puta = put | pauc
centru = centar | L.sg
rijeke = Rijeka | G.sg
matematike = matematika | G.sg
učenike = učenik | A.pl
osnovne = osnovna škola | G.sg.f+mw
škole = osnovna škola | G.sg+mw
''',
    'm11_istria': '''
njezin = njezin | N.sg.m
proveli = provesti | lp.m.pl
produženi = produženi vikend | A.sg.m+mw
istri = Istra | L.sg
smjestili = smjestiti se | lp.m.pl
staroj = star | L.sg.f
kamenoj = kamena kuća | L.sg.f+mw
kući = kamena kuća | L.sg+mw
malom = mali | L.sg.m
brdskom = brdski gradić | L.sg.m+mw
gradiću = brdski gradić | L.sg+mw
motovunu = Motovun | L.sg
terase = terasa | G.sg
gledali = gledati | lp.m.pl
dolinu = dolina | A.sg
rijeke = rijeka | G.sg
mirne = Mirna | G.sg
šume = šuma | A.pl
kojima = koji | L.pl.f
rastu = rasti | pr3p
posjetili = posjetiti | lp.m.pl
pulu = Pula | A.sg
rovinju = Rovinj | L.sg
šetali = šetati | lp.m.pl
uskim = uzak | I.pl.f
uličicama = uličica | I.pl
išli = ići | lp.m.pl
vinskom = vinska cesta | I.sg.f+mw
cestom = vinska cesta | I.sg+mw
jednom = jedan | L.sg.m
agroturizmu = agroturizam | L.sg
probali = probati | lp.m.pl
domaće = domaći | A.pl.m
fuže = fuži | A.pl
tartufima = tartufi | I.pl
maneštru = maneštra | A.sg
večeru = večera | A.sg
pili = piti | lp.m.pl
malvaziju = malvazija | A.sg
im = oni | D.pl | їм
objasnio = objasniti | lp.m.sg
mnogi = mnogi | N.pl.m
istrani = Istranin | N.pl
dvojezični = dvojezičan | N.pl.m
govore = govoriti | pr3p
kaže = kazati | pr3s
vraćaju = vraćati | pr3p | ~«vraćati se» — повертатися
''',
    'm11_slavonia': '''
istoku = istok | L.sg
hrvatske = Hrvatska | G.sg
rijeka = rijeka | G.pl
save = Sava | G.sg
drave = Drava | G.sg
dunava = Dunav | G.sg
žitna = žitna polja | N.pl.n+mw
polja = žitna polja | N.pl+mw
slavonci = Slavonac | N.pl
poznati = poznat | N.pl.m
gostoljubivi = gostoljubiv | N.pl.m
mora = morati | pr3s
poznata = poznat | N.sg.f | ~«poznata jela» — відомі страви (с. р., множина); «Slavonija je poznata» — відома
jela = jelo | N.pl
domaća = domaća kobasica | N.sg.f+mw
fiš = fiš paprikaš | mw
paprikaš = fiš paprikaš | mw
kuha = kuhati | pr3s
kotliću = kotlić | L.sg
vatri = vatra | L.sg
mnogim = mnogi | L.pl.f
obiteljima = obitelj | L.pl
održava = održavati | pr3s
berbe = berba grožđa | G.sg+mw
grožđa = berba grožđa | G.sg+mw
tamburašima = tamburaši | L.pl
tamburice = tamburica | G.sg
slavlja = slavlje | G.sg
najveći = velik | N.sg.m | ~найвищий ступінь: найбільший
uzgajaju = uzgajati | pr3p
konji = konj | N.pl
lipicanci = lipicanac | N.pl
vrijedi = vrijediti | pr3s | варто («vrijedi posjetiti» — варто відвідати)
''',
    'm11_manners': '''
hrvati = Hrvat | N.pl
pozovu = pozvati | pr3p
obiteljski = obiteljski ručak | A.sg.m+mw
ručak = obiteljski ručak | mw
velika = velik | N.sg.f
savjeta = savjet | G.pl
lijepo = lijepo ponašanje | A.sg.n+mw
ponašanje = lijepo ponašanje | mw
praznih = prazan | G.pl.f
ruku = ruka | G.pl
poklon = poklon za domaćina | mw
domaćina = poklon za domaćina | G.sg+mw
može = moći | pr3s
kad = kada | коротка форма від «kada» — коли
uđete = ući | pr2p
kuću = kuća | A.sg
pitajte = pitati | im2p
trebate = trebati | pr2p
cipele = cipela | A.pl
papuče = papuče za goste | mw
goste = papuče za goste | A.pl+mw
poljupcem = poljubac | I.sg
obraz = poljubiti u obraz | A.sg+mw
puta = put | pauc
starije = star | A.pl.m | ~вищий ступінь від «star»: старших
ljude = ljudi | A.pl
persiramo = persirati | pr1p
nam = mi | D.pl | нам
ponude = ponuditi | pr3p
ih = oni | A.pl | їх
tikamo = tikati | pr1p
stolom = stol | I.sg
pristojno = pristojno | adv | чемно; пристойно
sva = sav | A.pl.n
jela = jelo | A.pl
nepristojno = nepristojno | adv | нечемно
ručka = ručak | G.sg
satima = sat | I.pl
stvar = stvar | N.sg
dolazite = dolaziti | im2p
obitelji = obitelj | G.pl
ima = imati | pr3s | ~«puno obitelji ima» — після «puno» дієслово в однині
prijatelje = prijatelj | A.pl
pozdravljamo = pozdravljati se | pr1p | ~тут без se: «pozdravljati koga» — вітати
ponudi = ponuditi | pr3s
vam = vi | D.pl | вам
pijemo = piti | pr1p
dugu = dug | A.sg.f
razgovaramo = razgovarati | pr1p
''',
    'm11_advent': '''
ove = ovaj | G.sg.f
godine = godina | G.sg
posjetitelja = posjetitelj | G.pl
sajam = božićni sajam | mw
donjem = Donji grad | L.sg.m+mw
gornjem = Gornji grad | L.sg.m+mw
gradu = grad | L.sg
siječnja = siječanj | G.sg
sajmu = božićni sajam | L.sg+mw
prodaju = prodavati | pr3p
licitarska = licitarsko srce | N.pl.n+mw
srca = licitarsko srce | N.pl+mw
ručni = ručni rad | N.pl.m+mw
radovi = ručni rad | N.pl+mw
posjetitelji = posjetitelj | N.pl
piju = piti | pr3p
kuhano = kuhano vino | A.sg.n+mw
jedu = jesti | pr3p
kobasice = kobasica | A.pl
vozi = voziti | pr3s
trgovima = trg | L.pl
tradicionalne = tradicionalan | G.sg.f
hrane = hrana | G.sg
mlincima = purica s mlincima | I.pl+mw
tržnice = tržnica Dolac | G.sg+mw
dolac = tržnica Dolac | mw
javnim = javni prijevoz | I.sg.m+mw
prijevozom = javni prijevoz | I.sg+mw
centru = centar | L.sg
božićni = božićni sajam | mw
drugi = drugi | N.pl.m
koncerti = koncert | N.pl
turista = turist | G.pl
dolazi = dolaziti | pr3s | ~«puno turista dolazi» — після «puno» дієслово в однині
purica = purica s mlincima | mw
sir = sir i vrhnje | mw
vrhnje = sir i vrhnje | mw
najbolje = dobro | sup | найкраще
''',
    'm12_protection': '''
osobe = osoba | N.pl
statusom = status privremene zaštite | I.sg+mw
privremene = status privremene zaštite | G.sg.f+mw
zaštite = status privremene zaštite | G.sg+mw
imaju = imati | pr3p
rokom = rok važenja | I.sg+mw
važenja = rok važenja | G.sg+mw
isteka = istek valjanosti iskaznice | G.sg+mw
valjanosti = istek valjanosti iskaznice | G.sg+mw
iskaznice = istek valjanosti iskaznice | G.sg+mw
provjerite = provjeriti | im2p
treba = trebati | pr3s
stranicama = stranica | L.pl
novu = nov | A.sg.f
trebate = trebati | pr2p
ukrajinsku = ukrajinska putovnica | A.sg.f+mw
putovnicu = ukrajinska putovnica | A.sg+mw
biometrijsku = biometrijska fotografija | A.sg.f+mw
fotografiju = biometrijska fotografija | A.sg+mw
staru = star | A.sg.f
policijskoj = policijska uprava | L.sg.f+mw
upravi = policijska uprava | L.sg+mw
uzet = uzeti | inf | ~без -i перед «će»: «uzet će» — візьмуть
će = htjeti | fut3s
vam = vi | D.pl | вам
otisak = otisak prsta | mw
prsta = otisak prsta | G.sg+mw
promijenili = promijeniti | lp.m.pl
adresu = adresa | A.sg
prijavite = prijaviti adresu | im2p+mw
obavijestite = obavijestiti | im2p
odjel = odjel za strance | mw
strance = odjel za strance | A.pl+mw
maloljetno = maloljetno dijete | A.sg.n+mw
predaje = predavati | pr3s
pravo = pravo na rad | mw
dozvole = dozvola | G.sg
iskaznicu = iskaznica stranca | A.sg+mw
stranca = iskaznica stranca | G.sg+mw
mup-a = MUP | G.sg
može = moći | pr3s
tim = taj | I.sg.m
imate = imati | pr2p
rad = rad | A.sg | робота, праця («pravo na rad» — право на роботу, «dozvola za rad» — дозвіл на роботу)
''',
    'm12_community': '''
zajednica = ukrajinska zajednica | mw
ukrajinska = ukrajinski | N.sg.f
zagrebu = Zagreb | L.sg
poziva = pozivati | pr3s
sve = sav | A.pl.m
ukrajince = Ukrajinac | A.pl
njihove = njihov | A.pl.m
prijatelje = prijatelj | A.pl
dana = Dan neovisnosti Ukrajine | G.sg+mw
neovisnosti = Dan neovisnosti Ukrajine | G.sg+mw
ukrajine = Ukrajina | G.sg
kolovoza = kolovoz | G.sg
sati = sat | G.pl
kulturnog = kulturno društvo | G.sg.n+mw
društva = kulturno društvo | G.sg+mw
idemo = ići | pr1p
grkokatoličku = grkokatolička crkva | A.sg.f+mw
crkvu = grkokatolička crkva | A.sg+mw
djeca = dijete | N.pl | діти (множина від dijete)
subotnje = subotnja škola | G.sg.f+mw
škole = subotnja škola | G.sg+mw
imaju = imati | pr3p
pjesmama = pjesma | I.pl
plesovima = ples | I.pl
goste = gost | A.pl
će = htjeti | fut3s
hrvatska = hrvatski | N.sg.f
traži = tražiti | pr3s
nove = nov | A.pl.m
volontere = volonter | A.pl
znate = znati | pr2p
možete = moći | pr2p
prevoditelj = prevoditelj volonter | mw
novopridošlim = novopridošli | D.pl
obiteljima = obitelj | D.pl
dođite = doći | im2p
upoznajte = upoznati | im2p
ljude = ljudi | A.pl
osjećajte = osjećati se kao kod kuće | im2p+mw
kuće = osjećati se kao kod kuće | G.sg+mw
''',
    'm12_parcel': '''
poslala = poslati paket | lp.f.sg+mw
kurirskom = kurirska služba | I.sg.f+mw
službom = kurirska služba | I.sg+mw
dušo = duša | V.sg | ласкаве звертання: доню, серденько
stavila = staviti | lp.f.sg
kavu = kava | A.sg
čokoladu = čokolada | A.sg
maslinovo = maslinovo ulje | A.sg.n+mw
toplu = topao | A.sg.f
majicu = majica | A.sg
tatu = tata | A.sg
morala = morati | lp.f.sg
carinsku = carinska deklaracija | A.sg.f+mw
deklaraciju = carinska deklaracija | A.sg+mw
sadržaj = sadržaj paketa | mw
paketa = paket | G.sg
platila = platiti | lp.f.sg
dostavu = dostava | A.sg
težina = težina paketa | mw
kilograma = kilogram | G.pl
eura = euro | G.pl
bilo = biti | lp.n.sg
rok = rok dostave | mw
dostave = rok dostave | G.sg+mw
dana = dan | G.pl | ~«tjedan dana» — тиждень
ću = htjeti | fut1s
poslat = poslati | inf | ~без -i перед «ću»: «poslat ću» — я надішлю
praćenje = broj za praćenje | mw
možeš = moći | pr2s
pošiljku = pošiljka | A.sg
internetu = internet | L.sg
jesam = biti | pr1s | ~наголошена форма: «Jesam» — так (відповідь)
aplikacije = aplikacija za plaćanje | G.sg+mw
naknada = naknada za prijenos | mw
prijenos = naknada za prijenos | A.sg+mw
mala = mali | N.sg.f
stigne = stići | pr3s
''',
    'm12_bilingual': '''
moj = moj | N.sg.m
ima = imati | pr3s
godina = godina | G.pl
hrvatskoj = Hrvatska | L.sg
živi = živjeti | pr3s
svoje = svoj | G.sg.f
pete = peti | G.sg.f
godine = godina | G.sg
školi = škola | L.sg
prijateljima = prijatelj | I.pl
razreda = razred | G.sg
govori = govoriti | pr3s
kuće = kuća | G.sg
imamo = imati | pr1p
obiteljsko = obiteljsko pravilo | A.sg.n+mw
pravilo = obiteljsko pravilo | mw
razgovaramo = razgovarati | pr1p
materinji = materinji jezik | mw
želimo = željeti | pr1p
zaboravi = zaboraviti | pr3s
subotom = subota | I.sg | по суботах
ide = ići | pr3s
ukrajinsku = ukrajinski | A.sg.f
školu = škola | A.sg
uči = učiti | pr3s
ćirilicu = ćirilica | A.sg
naglaska = naglasak | G.sg
prevodi = prevoditi | pr3s
roditeljima = roditelj | D.pl
liječnika = liječnik | G.sg
miješa = miješati jezike | pr3s+mw
jezike = miješati jezike | A.pl+mw
istoj = isti | L.sg.f
rečenici = rečenica | L.sg
nas = mi | A.pl | нас
nasmije = nasmijati se | pr3s | ~тут без se: «nasmijati koga» — розсмішити
mu = on | D.sg | йому
korijeni = korijeni | N.pl
ukrajini = Ukrajina | L.sg
''',
    'm13_reschedule': '''
ispričavam = ispričavati se | pr1s
iskrsnulo = iskrsnulo mi je nešto | mw
stižem = ne stižem | mw
kavu = kava | A.sg
problema = nema problema | mw
možemo = moći | pr1p
pomaknuti = pomaknuti dogovor | mw
raspored = raspored mi je pun | mw
pun = raspored mi je pun | mw
odgovara = odgovara li ti | mw
recimo = reći | im1p | «recimo» — скажімо
trgu = trg | L.sg
promijeni = promijeniti se | pr3s
javit = javit ću ti | mw
ću = htjeti | fut1s
važi = važiti | pr3s | «Važi» — гаразд, домовились (розм.)
nemoj = nemoj | im2s | ~«nemoj + інфінітив» — не роби
zadnji = u zadnji čas | mw
čas = u zadnji čas | mw
prošli = prošli | A.sg.m
neću = htjeti | fut1s | заперечення: «neću» = ne + ću
obećavam = obećavati | pr1s
veselim = veseliti se | pr1s
vidimo = vidimo se onda | mw
subotu = subota | A.sg
poslu = posao | L.sg
''',
    'm13_goals': '''
svake = svaki | G.sg.f
godine = godina | G.sg
postavim = postaviti cilj | pr1s+mw
ciljeva = cilj | G.pl
ih = oni | A.pl | їх
ostvarim = ostvariti cilj | pr1s+mw
ove = ovaj | G.sg.f
želim = željeti | pr1s
realna = realan | N.sg.f
napravila = napraviti | lp.f.sg
listu = lista ciljeva | A.sg+mw
planeru = planer | L.sg
kraja = do kraja godine | mw
ću = htjeti | fut1s
štednju = štednja | A.sg
eura = euro | G.pl
dugoročni = dugoročni plan | mw
jednog = jednog dana | mw
dana = jednog dana | mw
vlastiti = vlastiti posao | A.sg.m+mw
znam = znati | pr1s
će = htjeti | fut3s
neću = htjeti | fut1s | заперечення: «neću» = ne + ću
vidjet = vidjet ćemo | mw
ćemo = vidjet ćemo | mw
hrvatskog = hrvatski | G.sg.m | ~«ispit iz hrvatskog» — іспит з хорватської
treba = trebati | pr3s | ~«treba motivacija» — потрібна мотивація
''',
    'm14_school_letter': '''
poštovana = poštovani | V.sg.f
gospođo = gospođa | V.sg
pišem = pišem Vam zbog | mw
vam = vi | D.pl | Вам (ввічливо)
svog = svoj | G.sg.m
sina = sin | G.sg
maksima = Maksim | G.sg
trećeg = treći | G.sg.m
razreda = razred | G.sg
ponedjeljka = ponedjeljak | G.sg
srijede = srijeda | G.sg
moramo = morati | pr1p
ukrajinu = Ukrajina | A.sg
obiteljskih = obiteljski | G.pl.m
razloga = razlog | G.pl
molila = molila bih | mw
bih = biti | cond1s
vas = vi | A.pl | Вас (ввічливо)
opravdate = opravdati | pr2p
će = htjeti | fut3s
zadaću = zadaća | A.sg
lektiru = lektira | A.sg
puta = put | G.sg
zamolila = zamoliti za pojašnjenje | lp.f.sg+mw
pojašnjenje = zamoliti za pojašnjenje | mw
točno = što točno | mw
treba = trebati | pr3s
matematike = matematika | G.sg
trebate = trebati | pr2p
javite = javiti se | pr2p
bila = bila bih Vam zahvalna | mw
zahvalna = bila bih Vam zahvalna | mw
brzom = brz | L.sg.m
odgovoru = odgovor | L.sg
iščekivanju = u iščekivanju odgovora | mw
odgovora = u iščekivanju odgovora | G.sg+mw
poštovanjem = s poštovanjem | I.sg+mw
''',
    'm14_friend_letter': '''
draga = drag | V.sg.f
pismu = pismo | L.sg
nedostaješ = nedostaješ mi | mw
imam = imati | pr1s
položila = položiti | lp.f.sg
hrvatskog = hrvatski | G.sg.m
bolje = dobro | comp | краще
snalazim = snalaziti se | pr1s
svakodnevnim = svakodnevna situacija | L.pl.f+mw
situacijama = svakodnevna situacija | L.pl+mw
bila = biti | lp.f.sg
liječnika = liječnik | G.sg
sama = sam | N.sg.f | сама
opisala = opisati simptome | lp.f.sg+mw
simptome = opisati simptome | A.pl+mw
prevoditelja = bez prevoditelja | G.sg+mw
poslu = posao | L.sg
dogovorila = dogovoriti se sa šefom | lp.f.sg+mw
šefom = dogovoriti se sa šefom | I.sg+mw
godišnjeg = godišnji odmor | G.sg.m+mw
odmora = godišnji odmor | G.sg+mw
godine = godina | pauc
mogla = moći | lp.f.sg
griješim = griješiti | pr1s
učim = učiti | pr1s
pogrešaka = naučiti iz pogrešaka | G.pl+mw
samopouzdanja = samopouzdanje | G.sg
osjećam = osjećati | pr1s
novo = novo poglavlje | mw
poglavlje = novo poglavlje | mw
mom = moj | L.sg.m
životu = život | L.sg
kad = kada | коротка форма від «kada» — коли
dolaziš = dolaziti | pr2s
jedva = jedva čekam | mw
čekam = jedva čekam | mw
vidim = vidjeti | pr1s
piši = piši mi | mw
svoje = svoj | A.pl.m | своїх (рідних)
tvoja = tvoj | N.sg.f
dvije = dva | форма для ж. р.: «dvije godine» — два роки
ovo = ovaj | N.sg.n
''',
}

EXTRA: dict[str, str] = {
    # значення саме в цих текстах (у словнику застосунку — інше значення того самого слова)
    'oko': 'близько; приблизно (+ родовий: «oko 30 eura»)', 'izdati': 'видати (документ, рахунок, попередження)',
    # слова поза уроками A0–A2
    'klima-uređaj': 'кондиціонер', 'ploviti': 'плисти; ходити (про судно)', 'prestati': 'припинитися; ущухнути',
    'zaprimiti': 'отримати (офіційно, про установу)', 'postupak': 'процедура', 'predaja': 'подання (документів)',
    'izdavanje': 'видача (документа)', 'povratak': 'повернення', 'neki': 'деякий; якийсь', 'klub': 'клуб',
    'koliki': 'який (за розміром); скільки', 'drveće': 'дерева', 'teško': 'важко', 'viknuti': 'вигукнути',
    'prostorija': 'приміщення', 'pomak': 'перенесення (строку)', 'internetski': 'інтернетний («internetska stranica» — вебсайт)',
    'slati': 'надсилати', 'online': 'онлайн', 'knjigovodstvo': 'бухгалтерія', 'tu': 'тут', 'centimetar': 'сантиметр',
    'na primjer': 'наприклад', 'potpisivati': 'підписувати', 'pred': 'перед', 'viroza': 'вірусна інфекція',
    'takav': 'такий', 'postajati': 'ставати', 'poslovni': 'діловий; робочий', 'sramiti se': 'соромитися',
    'strani': 'іноземний', 'raspitati se': 'розпитати', 'prometna nezgoda': 'дорожня пригода, ДТП', 'prodaja': 'продаж',
    'kućanstvo': 'домогосподарство', 'bacanje': 'викидання', 'isprazniti': 'спорожнити', 'meteorolog': 'метеоролог',
    'stablo': 'дерево', 'redateljica': 'режисерка', 'jedini': 'єдиний', 'predug': 'задовгий', 'nego': 'ніж',
    'čuvanje': 'догляд; нагляд (за дитиною)', 'poželjno': 'бажано', 'smjestiti se': 'зупинитися; розміститися',
    'pojesti': 'з’їсти', 'izuti': 'зняти (взуття), роззутися', 'cipela': 'черевик; туфля', 'pozdravljati se': 'вітатися',
    'slijediti': 'іти слідом; бути далі', 'božićni': 'різдвяний', 'poput': 'як-от; подібно до', 'produljiti': 'продовжити (строк)',
    'objavljivati': 'публікувати', 'unutarnji': 'внутрішній', 'obilježavanje': 'відзначення (свята)',
    'ispričavati se': 'перепрошувати', 'išta': 'будь-що; щось', 'mirno': 'спокійно; тихо', 'ne': 'не (заперечення); ні',
    'nemoj': 'не (заборона: «nemoj / nemojte + інфінітив» — не роби / не робіть)',
}
# Прозорі й службові слова поза уроками, які вважаємо знайомими
KNOWN: set[str] = {'evo', 'nemoj', 'neki', 'koliki', 'takav', 'tu', 'nego', 'pred', 'išta', 'teško', 'online', 'klub', 'centimetar',
                   'jedini', 'strani', 'klima-uređaj', 'oko', 'izdati'}
POS: dict[str, str] = {
    'oko': 'прислівник «близько»; прийменник + родовий («oko 30 eura»)', 'izdati': 'v.pf',
    'klima-uređaj': 'n.m', 'ploviti': 'v.ipf', 'prestati': 'v.pf', 'zaprimiti': 'v.pf', 'postupak': 'n.m',
    'predaja': 'n.f', 'izdavanje': 'n.n', 'povratak': 'n.m', 'neki': 'займенник', 'klub': 'n.m', 'koliki': 'займенник',
    'drveće': 'n.n', 'teško': 'adv', 'viknuti': 'v.pf', 'prostorija': 'n.f', 'pomak': 'n.m', 'internetski': 'adj',
    'slati': 'v.ipf', 'online': 'незмінне слово «онлайн»', 'knjigovodstvo': 'n.n', 'tu': 'adv', 'centimetar': 'n.m',
    'na primjer': 'phr', 'potpisivati': 'v.ipf', 'pred': 'prep:I', 'viroza': 'n.f', 'takav': 'займенник',
    'postajati': 'v.ipf', 'poslovni': 'adj', 'nemoj': 'частка заборони: «nemoj / nemojte + інфінітив» — не роби / не робіть',
    'sramiti se': 'v.ipf', 'strani': 'adj', 'raspitati se': 'v.pf', 'prometna nezgoda': 'phr', 'prodaja': 'n.f',
    'kućanstvo': 'n.n', 'bacanje': 'n.n', 'isprazniti': 'v.pf', 'meteorolog': 'n.m', 'stablo': 'n.n',
    'redateljica': 'n.f', 'činiti se': 'v.ipf', 'jedini': 'adj', 'predug': 'adj', 'nego': 'conj', 'čuvanje': 'n.n',
    'poželjno': 'adv', 'smjestiti se': 'v.pf', 'pojesti': 'v.pf', 'izuti': 'v.pf', 'cipela': 'n.f',
    'pozdravljati se': 'v.ipf', 'slijediti': 'v.ipf', 'božićni': 'adj', 'poput': 'prep:G', 'produljiti': 'v.pf',
    'objavljivati': 'v.ipf', 'unutarnji': 'adj', 'obilježavanje': 'n.n', 'ispričavati se': 'v.ipf', 'išta': 'займенник', 'mirno': 'adv',
    # вид, якого бракує або який хибний у reading_grammar.py
    'odmoriti se': 'v.pf', 'ispričati se': 'v.pf',
}

NAMES: dict[str, tuple[str, str]] = {
    'Babić': ('surname', 'Бабич (прізвище)'),
    'Makarska': ('place', 'Макарська (місто на узбережжі Далмації)'),
    'Darja': ('name.f', 'Дар’я (ім’я)'),
    'Daša': ('name.f', 'Даша (ім’я)'),
    'Kovalenko': ('surname', 'Коваленко (прізвище)'),
    'Melnyk': ('surname', 'Мельник (прізвище)'),
    'Supetar': ('place', 'Супетар (місто на острові Брач)'),
    'Hvar': ('place', 'Хвар (острів і місто)'),
    'Petrenko': ('surname', 'Петренко (прізвище)'),
    'Plitvička jezera': ('place', 'Плітвицькі озера (національний парк)'),
    'Maja': ('name.f', 'Мая (ім’я)'),
    'Božić': ('surname', 'Божич (прізвище)'),
    'Ivana': ('name.f', 'Івана (ім’я)'),
    'Lucija': ('name.f', 'Луція (ім’я)'),
    'Maks': ('name.m', 'Макс (ім’я)'),
    'Odesa': ('place', 'Одеса'),
    'Marija': ('name.f', 'Марія (ім’я)'),
    'Ana': ('name.f', 'Ана (ім’я)'),
    'Šibenik': ('place', 'Шибеник (місто в Далмації)'),
    'Ivan': ('name.m', 'Іван (ім’я)'),
    'Perić': ('surname', 'Перич (прізвище)'),
    'Horvat': ('surname', 'Горват (прізвище)'),
    'Zavod za zapošljavanje': ('place', 'Хорватська служба зайнятості (Zavod)'),
    'Novak': ('surname', 'Новак (прізвище)'),
    'Darjin': ('adj', 'Дар’їн (присвійний прикметник від Darja)'),
    'Golf': ('name.m', '«Гольф» (модель автомобіля)'),
    'Dalmacija': ('place', 'Далмація (історичний край на півдні Хорватії)'),
    'Kovač': ('surname', 'Ковач (прізвище)'),
    'Lea': ('name.f', 'Леа (ім’я)'),
    'Rijeka': ('place', 'Рієка (місто на півночі Адріатики)'),
    'Istra': ('place', 'Істрія (півострів на заході Хорватії)'),
    'Motovun': ('place', 'Мотовун (містечко на пагорбі в Істрії)'),
    'Mirna': ('place', 'Мірна (річка в Істрії)'),
    'Pula': ('place', 'Пула (місто в Істрії)'),
    'Rovinj': ('place', 'Ровинь (місто в Істрії)'),
    'Istranin': ('name.m', 'істрієць, мешканець Істрії'),
    'Slavonija': ('place', 'Славонія (край на сході Хорватії)'),
    'Sava': ('place', 'Сава (річка)'),
    'Drava': ('place', 'Драва (річка)'),
    'Slavonac': ('name.m', 'славонець, мешканець Славонії'),
    'Osijek': ('place', 'Осієк (найбільше місто Славонії)'),
    'Vukovar': ('place', 'Вуковар (місто на Дунаї)'),
    'Đakovo': ('place', 'Джаково (місто в Славонії)'),
    'Hrvat': ('name.m', 'хорват'),
    'Zagreb': ('place', 'Загреб (столиця Хорватії)'),
    'Hrvatska': ('place', 'Хорватія'),
    'Ukrajina': ('place', 'Україна'),
    'Ukrajinac': ('name.m', 'українець'),
    'Danilo': ('name.m', 'Данило (ім’я)'),
    'Jurić': ('surname', 'Юрич (прізвище)'),
    'Maksim': ('name.m', 'Максим (ім’я)'),
    'Olena': ('name.f', 'Олена (ім’я)'),
    'Bondar': ('surname', 'Бондар (прізвище)'),
    'Oksana': ('name.f', 'Оксана (ім’я)'),
    'Split': ('place', 'Спліт (місто в Далмації)'),
    'MUP': ('place', 'MUP — Міністерство внутрішніх справ Хорватії (і його відділи)'),
}
