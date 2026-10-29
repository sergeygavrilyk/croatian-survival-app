"""
Дані для чистки словника lexemes (2026-10-21): частина мови, рід, вид дієслова, normalized.
Генератор: scripts/gen_lexemes_quality_20261021.py.

Правила (застосовує SQL, ключ — lower(lemma)):
  1. POS: лема в POS_OVERRIDES → це значення.
     Інакше, якщо part_of_speech порожній або службовий ('word', 'other', 'formulaic', 'chunk'):
       «X-ti se» / «X-ći se» або одне слово на -ti / -ći → verb;
       кілька слів → phrase;
       одне слово → noun.
  2. Дієслово → forms.aspect з ASPECT (ipfv / pfv / biasp); кожне дієслово мусить мати вид.
  3. Іменник → forms.gender: GENDER_OVERRIDES, інакше наявний m/f/n/…_pl, інакше за закінченням
     (-ost → f; -a → f; -o / -e → n; приголосний / -u → m). Кожен іменник мусить мати рід.
  4. Не іменник і не вираз → ключ gender прибирається з forms (залишок старої помилки).
  5. normalized = lower(lemma) без діакритик (як normalizeCroatian у lib/srs.ts: č ć → c, đ → d, š → s, ž → z).
"""

SERVICE_POS = ('word', 'other', 'formulaic', 'chunk')

_POS_TEXT = {
    'adjective': """
        bijelo crno crveno plavo sivo zeleno žuto smeđe čisto novo staro veliko lijepo ružno prljavo toplo svježe
        slano slatko pokvareno moderno klasično bitan bučan cijeli čvrst dnevni dodatan drag gladak glup hrabar hrapav
        iskren jasan javan klasičan kompliciran kreativan kukavan lagan leden lijen lokalan lud marljiv mastan
        međunarodni mekan moguć mokar nacionalan nejasan neobičan neovisan nepoznat nesiguran netočan neuspješan nevin
        ništavan novom običan očigledan odgovoran odličan osoban oštar ovisan ozbiljan pažljiv plitak pojedini ponosan
        poseban posljednji pošten poznat prav prazan simpatičan širok siv slavan složen smeđ smiješan sporedni sposoban
        spoznatljiv sramežljiv srednji strpljiv stručan suh svijetao svjež tajanstven taman temeljni tradicionalan tup
        tvrd učinkovit ukupan umjetan uredan uzak vlastit vlažan vrijedan živ prometna isti opći pametan
        sljedeći engleski hrvatski mali veliki zajednički prošli
    """,
    'adverb': """
        dobro drago grozno hladno izvrsno jamačno jednostavno jedva jeftino još kamo kasnije katkad konačno manje
        nadesno naglas nalijevo namjerno napokon naprijed naprimjer naprosto naprotiv natrag navečer navlaš navodno
        netočno nikada odakle odmah okolo okruglo onda opasno opet pješice polako popodne posvuda prekjučer prekosutra
        prije slučajno skupo svugdje tako također točno ujutro ukusno umalo unaokolo uostalom uskoro više vjerojatno
        vruće zacijelo zajedno zamalo zapravo zasigurno štoviše dapače iskreno otvoreno zatvoreno svejedno odlično
        puta posto već vani
    """,
    'particle': 'bi čak evo tek valjda',
    'conjunction': 'dok kao međutim pa ali ili',
    'preposition': 'nakon preko protiv umjesto zbog',
    'pronoun': 'ga neke nitko njen one onaj onom ovaj sav svoj taj štogod sami sam se čiji ti vi mi oni koji',
    'number': """
        prvi drugi treći četvrti peti šesti sedmi osmi deveti deseti dvadeseti stoti nulti
        jedanaest dvanaest trinaest četrnaest petnaest šesnaest sedamnaest osamnaest devetnaest
        dvadeset trideset četrdeset pedeset šezdeset sedamdeset osamdeset devedeset
        sto dvjesto tristo petsto tisuća tisuću milijun pola tri četiri
    """,
    'interjection': 'bok super',
    'noun': 'vijesti kći hobi taksi roditelji',
    'phrase': 'čekaj dobrodošli izvoli izvolite može pazi stani idemo oprosti oprostite živjeli',
    'verb': """
        hoćemo je jesi moram trebam vidimo volim želim želiš znam znaš vidio
        braniti čuvati dokazati gubiti izjaviti liječiti napadati napredovati nastajati nastojati nestajati
        obećavati obuhvaćati ocjenjivati odrediti opravdati opstati otkrivati ovisiti ozlijediti patiti pojasniti
        postizati postojati povjerovati prepoznati preživljavati raspravljati rušiti sadržavati savjetovati sličiti
        strahovati suditi sumnjati tvrditi upozoravati zabraniti zahtijevati zaključiti zamišljati
    """,
}

# Багатослівні винятки з правила «кілька слів → phrase» і хибні іменники-словосполучення
_POS_MULTI = {
    'number': ['dvadeset dva', 'dvadeset jedan', 'trideset pet'],
    'pronoun': ['bilo što', 'bilo tko', 'ma tko', 'ona (pl)'],
    'adverb': ['po noći', 'jedva da'],
    'phrase': ['zlonamjerni softver', 'rodni list', 'vozni red', 'kvačica za rublje'],
    'verb': ['diviti se', 'dogovarati se', 'kretati se', 'pretvarati se', 'prisjetiti se', 'razlikovati se',
             'sastojati se', 'zaustavljati se'],
}

POS_OVERRIDES: dict[str, str] = {}
for _pos, _text in _POS_TEXT.items():
    for _w in _text.split():
        POS_OVERRIDES[_w] = _pos
for _pos, _items in _POS_MULTI.items():
    for _w in _items:
        POS_OVERRIDES[_w] = _pos

# Вид дієслова: i = недоконаний (ipfv), p = доконаний (pfv), b = двовидове (biasp)
_ASPECT_TEXT = """
analizirati b; baciti p; bankrotirati b; baviti i; birati i; biti i; bježati i; blokirati b; bojati se i; boljeti i;
boriti se i; brinuti i; brinuti se i; brisati i; brojati i; buditi se i; častiti i; čekati i; češljati se i;
čestitati b; cijeniti i; cijepiti i; činiti i; čistiti i; čitati i; cjenkati se i; crtati i; curiti i; čuti b;
darivati i; darovati b; dati p; davati i; debljati se i; dernjati se i; dijeliti i; disati i; dizajnirati b;
djelovati i; dobiti p; dobivati i; doći p; dodati p; dodirnuti p; događati i; dogoditi p; dogovarati i;
dogovoriti p; dogovoriti se p; dokazivati i; dolaziti i; doletjeti p; donijeti p; donirati b; donositi i;
dopuštati i; dopustiti p; doputovati p; doručkovati i; dosjetiti se p; dostaviti p; dotrčati p; dovršiti p;
doživjeti p; doznati p; dozvoliti p; drijemati i; družiti i; družiti se i; držati i; dugovati i; financirati b;
fotografirati b; glasati i; gledati i; glumiti i; gorjeti i; gostovati i; govoriti i; graditi i; gurnuti p;
hodati i; hraniti i; hrkati i; htjeti i; hvaliti i; ići i; igrati i; igrati se i; imati i; informirati b;
investirati b; iseliti se p; isključiti p; isključivati i; iskorištavati i; iskoristiti p; ispisati p; isplatiti p;
isplatiti se p; isplivati p; isporučiti p; ispraviti p; ispravljati i; ispričati se p; ispuniti p; ispunjavati i;
isteći p; isticati i; istjecati i; istražiti p; istraživati i; istrčati p; izabrati p; izaći p; izazivati i;
izbaviti p; izbivati i; izbjeći p; izbjegavati i; izbjegnuti p; izbrisati p; izdati p; izdavati i; izdržati p;
izgledati i; izgraditi p; izgubiti p; izliječiti p; izmjeriti p; iznajmiti p; iznajmljivati i; iznenaditi p;
iznenađivati i; iznositi i; izračunati p; izražavati i; izvaditi p; izvesti p; izvršavati i; izvršiti p; javiti p;
javiti se p; jesti i; kajati i; kapati i; kašljati i; kasniti i; kazati b; kazniti p; kihati i; klasificirati b;
kliknuti p; kočiti i; kolebati se i; komentirati b; komunicirati i; kontaktirati b; kontrolirati i; kopirati b;
koristiti i; koštati i; krasti i; krenuti p; kretati i; kritizirati i; kršiti i; krvariti i; kuhati i; kupati i;
kupati se i; kupiti p; kupovati i; lagati i; lajati i; leći p; letjeti i; ličiti i; ljutiti se i; lutati i;
maknuti p; maziti i; mijenjati i; miješati i; mirisati i; miriti se i; mirovati i; misliti i; mjeriti i; moći i;
modernizirati b; moliti i; montirati b; morati i; mršaviti i; mrziti i; mučiti i; naći p; naći se p; nadati se i;
naglašavati i; naglasiti p; nagraditi p; nalaziti se i; namjestiti p; napasti p; napisati p; naplaćivati i;
naplatiti p; napraviti p; narezati p; naručiti p; naručiti se p; nasmijati p; nastati p; nastaviti p;
nastavljati i; natjecati se i; naučiti p; navići p; navijati i; naviknuti se p; nazadovati i; nazočiti i;
nazvati p; nedostajati i; nemati i; nestati p; nositi i; obavijestiti p; obavještavati i; obećati p; objasniti p;
objaviti p; objesiti p; obnavljati i; obnoviti p; obožavati i; obrisati p; obući se p; obuhvatiti p; očarati p;
očekivati i; ocijeniti p; očistiti p; odabrati p; odbaciti p; odbijati i; odbiti p; odblokirati p; odgađati i;
odgoditi p; odgovarati i; odgovoriti p; odjaviti p; odjaviti se p; odlaziti i; odletjeti p; odlučiti p;
odlučivati i; odmarati i; odmarati se i; odmoriti se p; odnijeti p; odobravati i; odobriti p; održati p;
održavati i; odsjesti p; oduševiti p; odustajati i; odustati p; oduzeti p; odvajati i; oguliti p; ohrabriti p;
okititi p; oklijevati i; okrenuti p; okriviti p; okusiti p; olakšati p; omesti p; omogućavati i; omogućiti p;
onesvijestiti se p; operirati b; opisati p; opisivati i; oporaviti se p; opraštati i; oprati p; oprostiti p;
optužiti p; opustiti se p; organizirati b; osjećati i; osjećati se i; osjetiti p; osloboditi p; osloboditi se p;
osmisliti p; ostajati i; ostati p; ostaviti p; ostvariti p; osuditi p; osuđivati i; osvetiti se p; otežati p;
otići p; otkazati p; otključati p; otkriti p; otputovati p; otrčati p; otvarati i; otvoriti p; ovjeriti p;
ozdraviti p; oženiti se p; ozlijediti se p; padati i; pakirati i; pamtiti i; parkirati b; pasti p; paziti i;
peći i; peglati i; pisati i; pitati i; piti i; pješačiti i; pjevati i; plaćati i; plakati i; planinariti i;
planirati i; platiti p; plesati i; plesti i; plivati i; pobijediti p; pobjeći p; poboljšati p; poboljšavati i;
početi p; poći p; počinjati i; podići p; podijeliti p; podizati i; podnijeti p; podržati p; pogledati p;
pogoršati p; pohađati i; pohvaliti p; pohvaljivati i; pojaviti se p; pokazati p; pokazivati i; pokloniti p;
pokopati p; pokušati p; pokušavati i; polagati i; polaziti i; pomagati i; pomaknuti p; pomilovati p;
pomiriti se p; pomnožiti p; pomoći p; ponašati se i; ponijeti p; ponoviti p; ponuditi p; popiti p; popraviti p;
popravljati i; poricati i; posati p; posjećivati i; posjetiti p; poslati p; posoliti p; postati p; postići p;
poštovati i; posuditi p; posuđivati i; posvađati se p; posvetiti se p; potjecati i; potonuti p; potpisati p;
potvrditi p; poučavati i; povećati se p; povećavati i; povezati p; povraćati i; povući p; pozdraviti p;
pozivati i; požuriti p; požurivati i; pozvati p; prati i; pratiti i; preboljeti p; predati p; predložiti p;
predomisliti se p; predstaviti se p; predstavljati i; predviđati i; predvidjeti p; preferirati i; pregledati p;
pregovarati i; prekinuti p; prelaziti i; prenoćiti p; preporučiti p; preporučivati i; preseliti se p;
presjedati i; presjesti p; prespavati p; prestrašiti p; presvući p; pretjecati i; pretpostaviti p;
pretpostavljati i; preuzeti p; preuzimati i; prevariti p; prezirati i; preživjeti p; pričati i; prihvaćati i;
prihvatiti p; prijaviti p; prijaviti se p; prijeći p; prilagođavati i; prilagoditi p; prilagoditi se p;
primijetiti p; primiti p; primjećivati i; primjenjivati i; pripadati i; pripremiti p; pristajati i;
prisustvovati i; pritisnuti p; privući p; priznati p; probati p; probuditi se p; proći p; procijeniti p;
pročitati p; prodati p; prodavati i; produžiti p; programirati i; proizvoditi i; projektirati b; promijeniti p;
promijeniti se p; promisliti p; pronaći p; pronalaziti i; propasti p; propisati p; propustiti p; proputovati p;
prošetati se p; proširiti p; proširivati i; proslaviti p; proslijediti p; provesti p; provjeriti p; provoditi i;
prozračiti p; pržiti i; puniti i; pušiti i; pustiti p; putovati i; računati i; raditi i; radovati se i;
rasplakati p; raspršiti p; rastati se p; rastaviti p; rasti i; razboljeti se p; razdijeliti p; razdvojiti p;
razgledati i; razgovarati i; razljutiti p; razmisliti p; razmišljati i; razočarati p; razumjeti i; razviti p;
razviti se p; razvrstati p; reagirati b; reći p; registrirati b; rezati i; rezervirati b; režirati b; riješiti p;
roditi se p; ručati i; sakriti p; sakriti se p; sanjati i; šaputati i; sastaviti p; saznati p; seliti se i;
šetati i; shvatiti p; šivati i; sjediti i; sjesti p; sjetiti se p; skakati i; skenirati b; skitati se i;
sklopiti p; skočiti p; skrenuti p; skriti se p; skrivati i; skupiti p; slagati p; slaviti i; sletjeti p;
slikati i; slomiti p; složiti se p; slušati i; smanjiti p; smanjiti se p; smanjivati i; smatrati i;
smijati se i; smijeti i; smiriti se p; smjeti i; smrznuti se p; snaći se p; snimiti p; šokirati b; spajati i;
spašavati i; spasiti p; spavati i; spojiti p; spominjati i; sponzorirati b; spoznati p; spremati i; spremiti p;
sprijateljiti se p; spriječiti p; sresti p; srušiti p; srušiti se p; stagnirati i; stajati i; stanovati i;
stati p; staviti p; štedjeti i; štetiti i; stići p; strmoglaviti se p; stvarati i; stvoriti p; suditi se i;
sudjelovati i; surađivati i; sušiti i; susresti p; šutjeti i; svađati se i; sviđati se i; svidjeti se p;
svirati i; testirati b; ticati i; tješiti i; trajati i; tražiti i; trčati i; trebati i; trošiti i; tugovati i;
tumačiti i; tuširati se i; tužiti i; ubijati i; ubrzati p; ući p; učiniti p; učiti i; udati se p; uganuti p;
ugasiti p; ugraditi p; ugristi p; uhititi p; uhvatiti p; uključiti p; uključivati i; ukrasiti p; ukrasti p;
ulagati i; uložiti p; umiriti p; umiti se p; umrijeti p; unajmiti p; upaliti p; upisati p; uplašiti p;
uplašiti se p; uplatiti p; upoznati p; upoznavati i; upravljati i; uputiti p; urediti p; useliti se p;
usisavati i; uskladiti p; uspavati p; uspjeti p; usporediti p; usporiti p; ustajati i; ustati p; uštedjeti p;
utjecati i; utješiti p; utopiti se p; uzdisati i; uzeti p; uzimati i; uživati i; uznemiriti se p; vagati i;
varati i; važiti i; večerati i; veseliti se i; vezati b; vidjeti b; vikati i; vjenčati se p; vjerovati i;
vježbati i; voditi i; voljeti i; voziti i; vratiti p; vratiti se p; vrijediti i; uzdahnuti p; zabaviti se p;
zabavljati i; zaboraviti p; zadržati p; zagrijati p; zahvaliti p; zakasniti p; zaključati p; zaljubiti se p;
žalovati i; zamijeniti p; zamisliti p; zapanjiti p; zapisati p; zaplivati p; započeti p; zaposliti se p;
zaraditi p; zarađivati i; zarobiti p; zaštititi p; zatajiti p; zatvarati i; zatvoriti p; zavidjeti i;
završavati i; završiti p; zbrojiti p; željeti i; zijevati i; živjeti i; značiti i; znati i; žuriti se i;
zvati i; zvati se i; zvoniti i; zvučati i;
braniti i; čuvati i; diviti se i; dogovarati se i; dokazati p; gubiti i; izjaviti p; kretati se i; liječiti i;
napadati i; napredovati i; nastajati i; nastojati i; nestajati i; obećavati i; obuhvaćati i; ocjenjivati i;
odrediti p; opravdati p; opstati p; otkrivati i; ovisiti i; ozlijediti p; patiti i; pojasniti p; postizati i;
postojati i; povjerovati p; prepoznati p; pretvarati se i; preživljavati i; prisjetiti se p; raspravljati i;
razlikovati se i; rušiti i; sadržavati i; sastojati se i; savjetovati i; sličiti i; strahovati i; suditi i;
sumnjati i; tvrditi i; upozoravati i; zabraniti p; zahtijevati i; zaključiti p; zamišljati i; zaustavljati se i;
hoćemo i; je i; jesi i; moram i; trebam i; vidimo b; volim i; želim i; želiš i; znam i; znaš i; vidio b
"""

_ASPECT_CODE = {'i': 'ipfv', 'p': 'pfv', 'b': 'biasp'}
ASPECT: dict[str, str] = {}
for _item in _ASPECT_TEXT.replace('\n', ' ').split(';'):
    _item = _item.strip()
    if not _item:
        continue
    _lemma, _code = _item.rsplit(' ', 1)
    ASPECT[_lemma.strip()] = _ASPECT_CODE[_code]

# Рід іменників, які не вгадуються за закінченням (а також множинні: *_pl)
_GENDER_TEXT = {
    'f': """čast dob dobit mast moć momčad riječ stvar strast tvar vlast savjest svijest podsvijest nesvijest
            obavijest vijest laž ljubav misao smrt pomoć povijest noć sol krv kost jesen glad pamet zvijer čeljust
            obitelj mladež perad ćud mikrovalna korist kći""",
    'm': """diplomata strojovođa vođa ubojica zanatlija tata računovođa radio auto bistro optuženi studeni
            kolega sluga gazda smisao hobi taksi""",
    'f_pl': """financije papuče novine slušalice snage stvari traperice upute usluge čizme dizne naušnice police
               postavke sandale vijesti""",
    'm_pl': 'podaci pregovori spisi izbori ljudi mediji roditelji',
    'n_pl': 'prava usta',
}
GENDER_OVERRIDES: dict[str, str] = {}
for _g, _text in _GENDER_TEXT.items():
    for _w in _text.split():
        GENDER_OVERRIDES[_w] = _g

# Нормалізація наявних кодів виду
ASPECT_CODE_FIXES = {'impfv': 'ipfv', 'ipf': 'ipfv', 'pf': 'pfv', 'ipfv/pfv': 'biasp'}

# Леми з великої літери, що не є власними назвами → з малої (lower(lemma) той самий — унікальний індекс не зачіпає).
# Переклад теж з малої, якщо він з великої.
LOWERCASE_LEMMAS = [
    'australski ovčar', 'devizni račun', 'dnevni sastanak', 'dozvola za boravak', 'hrana za pse', 'poslovna kartica',
    'prometna dozvola', 'u principu', 'ulje u mjenjaču', 'žiro račun', 'iskreno', 'isporuka', 'procjena', 'skaliranje',
    'zastoj', 'zapravo', 'dizne',
]

# Точкові виправлення лем і перекладів (очевидні одруківки; старе значення — для захисту від повторного запуску)
LEMMA_FIXES = [
    # key (lower(lemma) зараз), нова лема, старий переклад, новий переклад
    ('vzdahnuti', 'uzdahnuti', 'зівтнути', 'зітхнути'),
    ('ravnatitelj', 'ravnatelj', 'директор, керівник', 'директор, керівник'),
    ('sretan božić', 'sretan Božić', 'щасливого різдва', 'щасливого Різдва'),
    ('sretna nova godina', 'sretna Nova godina', 'з новим роком', 'з Новим роком'),
    ('ja sam iz ukrajine', 'ja sam iz Ukrajine', 'я з україни', 'я з України'),
    ('karta za zagreb', 'karta za Zagreb', 'квиток до загреба', 'квиток до Загреба'),
    # хибні переклади
    ('znaš', 'znaš', 'ви знаєте', 'ти знаєш'),
    ('predak', 'predak', 'предк', 'предок'),
    ('vidio', 'vidio', 'пила', 'бачив (минулий час від vidjeti)'),
]
