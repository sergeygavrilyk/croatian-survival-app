"""
Словничок для текстів читання (§56: переклад слова за дотиком). Дані для scripts/gen_reading.py.

  FORMS      — форма слова в тексті (нижній регістр) → лема (з уроків A0–A1 або з EXTRA);
  EXTRA      — леми, яких немає в уроках, і службові слова: лема → переклад;
  KNOWN      — леми з EXTRA, які вважаємо знайомими (граматика A0: займенники, biti, прийменники, сполучники…);
  NAMES      — власні назви (як у тексті) → пояснення;
  TEXT_FORMS — значення в конкретному тексті: код → {форма: (лема, переклад)}.
Леми з уроків беруть переклад зі знімка бази (reading_lexicon_snapshot.json).
"""

FORMS: dict[str, str] = {}
EXTRA: dict[str, str] = {}
KNOWN: set[str] = set()
NAMES: dict[str, str] = {}
NAMES_LOWER: dict[str, str] = {}
TEXT_FORMS: dict[str, dict[str, tuple[str, str]]] = {}

# ---------------------------------------------------------------- службові слова й інше поза уроками
EXTRA.update({
    'a': 'а; і', 'i': 'і; та', 'ako': 'якщо', 'bez': 'без', 'biti': 'бути; є', 'nije': 'не є; немає (заперечення biti)',
    'do': 'до', 'iz': 'з (звідки)', 'između': 'між', 'kao': 'як', 'li': 'чи (питальна частка)', 'na': 'на', 'o': 'про',
    'od': 'від; з', 'po': 'по; за (чимось)', 'prema': 'до; у напрямку; відповідно до', 'prije': 'до; перед; раніше',
    'poslije': 'після', 'protiv': 'проти; від (ліки)', 's': 'з (разом із)', 'u': 'у; в', 'uz': 'біля; уздовж; разом із',
    'za': 'для; за', 'zbog': 'через (причина)', 'kod': 'у; біля; в (когось)', 'zato': 'тому', 'onda': 'потім; тоді',
    'sada': 'зараз', 'samo': 'тільки; лише', 'već': 'вже', 'vrlo': 'дуже', 'tko': 'хто', 'što': 'що',
    'se': 'себе; -ся (частка дієслова)', 'ga': 'його (займенник)', 'joj': 'їй (займенник)', 'te': 'тебе (займенник)',
    'nam': 'нам (займенник)', 'mi': 'ми; мені', 'vas': 'вас; вам (займенник)', 'sebe': 'себе', 'ona': 'вона',
    'neka': 'нехай', 'nema': 'немає', 'moj': 'мій', 'svaki': 'кожен', 'sve': 'все; усе', 'dan': 'день',
    'dva': 'два', 'dvjesto': 'двісті', 'trideseti': 'тридцятий', 'pol': 'половина («šest i pol» — пів на сьому)',
    'hvala': 'дякую', 'dobar': 'добрий; гарний', 'pozdrav': 'привіт; вітання', 'super': 'чудово', 'prvo': 'спочатку',
    'drugi': 'другий; інший', 'vidjeti': 'бачити', 'ljudi': 'люди', 'cijel': 'цілий; весь', 'jak': 'сильний',
    'lak': 'легкий', 'čist': 'чистий', 'svjež': 'свіжий', 'potreban': 'потрібний', 'prekrasan': 'чудовий; прекрасний',
    'srdačan': 'сердечний («Srdačan pozdrav» — з повагою)', 'poštovani': 'шановний', 'glavni': 'головний',
    'dnevni': 'денний; щоденний', 'jutarnji': 'ранковий', 'popodnevni': 'післяобідній; денний (зміна)', 'radni': 'робочий',
    'obiteljski': 'сімейний', 'zdravstveni': 'медичний; страховий (про картку)', 'policijski': 'поліцейський',
    'gradski': 'міський', 'dječji': 'дитячий', 'zimski': 'зимовий', 'lokalan': 'місцевий', 'originalan': 'оригінальний',
    'privremeni': 'тимчасовий', 'ograničen': 'обмежений', 'besplatan': 'безкоштовний', 'besplatno': 'безкоштовно',
    'osobno': 'особисто', 'oblačno': 'хмарно', 'sunčano': 'сонячно', 'ljeti': 'улітку', 'ranije': 'раніше',
    'dulje': 'довше', 'najduže': 'найдовше', 'najkasnije': 'найпізніше', 'jedva': 'ледве', 'van': 'надвір; назовні',
    'minus': 'мінус', 'ostalo': 'інше; решта',
    # іменники
    'brašno': 'борошно', 'cesta': 'дорога', 'cijev': 'труба', 'cvijeće': 'квіти', 'državljanstvo': 'громадянство',
    'gram': 'грам', 'ideja': 'ідея', 'iskaznica': 'посвідчення; картка', 'jugo': 'юго (теплий південний вітер)',
    'kanta': 'відро; контейнер', 'kantina': 'їдальня (на роботі)', 'karton': 'картон', 'klizalište': 'ковзанка',
    'kovanica': 'монета', 'kroasan': 'круасан', 'kuhanje': 'готування (їжі)', 'kupanje': 'купання', 'kupnja': 'покупка',
    'kućica': 'будиночок; кіоск', 'limenka': 'бляшанка', 'medicina': 'медицина', 'mjesec': 'місяць',
    'obavijest': 'оголошення; повідомлення', 'odgojiteljica': 'вихователька', 'odjeća': 'одяг', 'odrasli': 'дорослі',
    'odvoz': 'вивезення (сміття)', 'ordinacija': 'кабінет лікаря', 'orkestar': 'оркестр', 'ostatak': 'залишок; решта',
    'otpad': 'відходи', 'otvaranje': 'відкриття', 'palačinka': 'млинець', 'parkiranje': 'паркування',
    'pitanje': 'питання', 'plastika': 'пластик', 'plaćanje': 'оплата', 'početak': 'початок', 'početnik': 'початківець',
    'povrat': 'повернення', 'praznik': 'свято', 'prijava': 'заявка; реєстрація', 'prijavnica': 'анкета; заявка',
    'put': 'раз; дорога («dva puta» — двічі)', 'radovi': 'роботи (ремонтні)', 'raspoloženje': 'настрій',
    'razumijevanje': 'розуміння', 'recepcija': 'рецепція', 'riječ': 'слово', 'roba': 'товар', 'sirup': 'сироп',
    'slučaj': 'випадок', 'smjesa': 'суміш; тісто', 'sms': 'SMS-повідомлення', 'sniženje': 'розпродаж; знижка',
    'staklo': 'скло', 'stanar': 'мешканець', 'stanovanje': 'проживання', 'strana': 'бік; сторона', 'svijet': 'світ',
    'šetnja': 'прогулянка', 'turist': 'турист', 'uprava': 'управління', 'volja': 'воля («dobra volja» — гарний настрій)',
    'zamjena': 'обмін; заміна', 'zdjela': 'миска', 'znanje': 'знання', 'čišćenje': 'прибирання', 'čokolada': 'шоколад',
    'g': 'г (грам)', 'kg': 'кг (кілограм)', 'l': 'л (літр)', 'm': 'м (метр)', 'dr': 'лікар (скорочення «доктор»)',
    # дієслова
    'brati': 'зривати; збирати', 'davati': 'давати', 'grliti': 'обіймати', 'hodati': 'ходити', 'kretati': 'вирушати; рушати',
    'kupovati': 'купувати', 'odabrati': 'вибрати', 'odvajati': 'відокремлювати; сортувати', 'organizirati': 'організовувати',
    'padati': 'падати («pada kiša» — іде дощ)', 'podsjećati': 'нагадувати', 'poništiti': 'прокомпостувати; скасувати',
    'prevoditi': 'перекладати', 'pripremiti': 'підготувати', 'puhati': 'дути (про вітер)', 'svirati': 'грати (на інструменті)',
    'vraćati': 'повертати («vraćati se» — повертатися)', 'vrijediti': 'бути дійсним; коштувати', 'zbuniti se': 'розгубитися; заплутатися',
    'čuvati': 'берегти', 'klizati se': 'кататися на ковзанах', 'dvosoban': 'двокімнатний', 'nju': 'її (займенник)',
})

# Знайомі службові слова (граматика A0: займенники, biti, прийменники, сполучники, частки)
KNOWN.update({
    'a', 'i', 'ako', 'bez', 'biti', 'nije', 'do', 'iz', 'kao', 'li', 'na', 'o', 'od', 'po', 'prije', 'poslije', 's', 'u',
    'za', 'zbog', 'kod', 'zato', 'onda', 'sada', 'samo', 'već', 'vrlo', 'tko', 'što', 'se', 'ga', 'joj', 'te', 'nam', 'mi',
    'vas', 'sebe', 'ona', 'neka', 'nema', 'moj', 'svaki', 'sve', 'dan', 'dva', 'hvala', 'dobar', 'pozdrav', 'super', 'prvo',
    'vidjeti', 'ljudi', 'mjesec', 'g', 'kg', 'l', 'm', 'dr', 'minus', 'sms', 'pitanje', 'nju',
})

# ---------------------------------------------------------------- форми → леми
FORMS.update({
    'je': 'biti', 'su': 'biti', 'sam': 'biti', 'smo': 'biti', 'jesi': 'biti', 'niste': 'nije', 'nisu': 'nije',
    'adresi': 'adresa', 'alergiju': 'alergija', 'auti': 'auto', 'autobusu': 'autobus', 'automata': 'automat', 'automatu': 'automat',
    'balkonom': 'balkon', 'banci': 'banka', 'berite': 'brati', 'besplatni': 'besplatan', 'blagajni': 'blagajna',
    'bolesna': 'bolestan', 'brašna': 'brašno', 'brojem': 'broj', 'budi': 'buditi se', 'centru': 'centar', 'cesti': 'cesta',
    'cijeli': 'cijel', 'cijelog': 'cijel', 'cijevi': 'cijev', 'crna': 'crn', 'crnu': 'crn', 'daje': 'davati', 'dana': 'dan',
    'dječju': 'dječji', 'dobivate': 'dobiti', 'dobru': 'dobar', 'dodajte': 'dodati', 'dogovorite': 'dogovoriti se',
    'dokumente': 'dokument', 'dolazi': 'dolaziti', 'dolazite': 'dolaziti', 'donesite': 'donijeti', 'dopušteni': 'dopušteno',
    'doručkuje': 'doručkovati', 'dostave': 'dostava', 'dođite': 'doći', 'došli': 'doći', 'draga': 'drag', 'dragi': 'drag',
    'drugima': 'drugi', 'dvije': 'dva', 'e-mailom': 'mail', 'engleskog': 'engleski', 'fotografiju': 'fotografija',
    'glavnog': 'glavni', 'gleda': 'gledati', 'godine': 'godina', 'godinu': 'godina', 'gospodine': 'gospodin',
    'gospođe': 'gospođa', 'gospođo': 'gospođa', 'gotovini': 'gotovina', 'gotovinom': 'gotovina', 'govorim': 'govoriti',
    'grada': 'grad', 'gradskoj': 'gradski', 'graha': 'grah', 'grama': 'gram', 'grli': 'grliti', 'hitni': 'hitan',
    'hladna': 'hladan', 'hladni': 'hladan', 'hladnije': 'hladan', 'hladnjaku': 'hladnjak', 'hodajte': 'hodati',
    'hoćeš': 'htjeti', 'hrane': 'hrana', 'hranom': 'hrana', 'hranu': 'hrana', 'hranite': 'hraniti', 'nahrani': 'hraniti',
    'hrvatskog': 'hrvatski', 'hrvatskoga': 'hrvatski', 'ide': 'ići', 'idem': 'ići', 'idemo': 'ići', 'idu': 'ići',
    'ideju': 'ideja', 'ima': 'imati', 'imam': 'imati', 'imamo': 'imati', 'imate': 'imati', 'imaš': 'imati',
    'internetu': 'internet', 'iskaznicu': 'iskaznica', 'iznajmljujem': 'iznajmiti', 'iznesi': 'iznositi',
    'iznosimo': 'iznositi', 'izvadi': 'izvaditi', 'jabuke': 'jabuka', 'jaja': 'jaje', 'jakne': 'jakna', 'jaknu': 'jakna',
    'javi': 'javiti se', 'javite': 'javiti se', 'jedemo': 'jesti', 'jedite': 'jesti', 'jedu': 'jesti', 'jedna': 'jedan',
    'jedni': 'jedan', 'jednosmjernu': 'jednosmjerna karta', 'jela': 'jelo', 'jezerima': 'jezero', 'jezika': 'jezik',
    'jeziku': 'jezik', 'jutarnja': 'jutarnji', 'kad': 'kada', 'kafiću': 'kafić', 'kanti': 'kanta', 'kantini': 'kantina',
    'karte': 'karta', 'kartu': 'karta', 'karticom': 'kartica', 'karticu': 'kartica', 'katu': 'kat', 'kavu': 'kava',
    'kazalištu': 'kazalište', 'kašlja': 'kašalj', 'kašlje': 'kašljati', 'klizalištu': 'klizalište', 'kližu': 'klizati se',
    'knjižnici': 'knjižnica', 'kobasice': 'kobasica', 'kobasicom': 'kobasica', 'kolodvora': 'kolodvor',
    'kovanicama': 'kovanica', 'krajem': 'kraj', 'kraju': 'kraj', 'krećemo': 'kretati', 'kuha': 'kuhati', 'kuhano': 'kuhan',
    'kupamo': 'kupati se', 'kupnju': 'kupnja', 'kupuje': 'kupovati', 'kupujem': 'kupovati', 'kuće': 'kuća',
    'kućice': 'kućica', 'kućni': 'kućni ljubimac', 'ljubimci': 'kućni ljubimac', 'kvartu': 'kvart', 'lijekove': 'lijek',
    'liječnika': 'liječnik', 'liječniku': 'liječnik', 'limenke': 'limenka', 'lipnja': 'lipanj', 'listopada': 'listopad',
    'litre': 'litra', 'ljubazni': 'ljubazan', 'lokalni': 'lokalan', 'luci': 'luka', 'majstora': 'majstor', 'male': 'mali',
    'mačku': 'mačka', 'medicine': 'medicina', 'medom': 'med', 'miješajte': 'miješati', 'minutu': 'minuta',
    'mjeseca': 'mjesec', 'mjesta': 'mjesto', 'mjestu': 'mjesto', 'mlađa': 'mlad', 'mlijeka': 'mlijeko', 'mnom': 'ja',
    'meni': 'ja', 'mobitela': 'mobitel', 'mogu': 'moći', 'može': 'moći', 'možemo': 'moći', 'možete': 'moći', 'moja': 'moj',
    'molimo': 'molim', 'moraju': 'morati', 'moru': 'more', 'nacionalni': 'nacionalni park', 'nalaze': 'nalaziti se',
    'nalazimo': 'nalaziti se', 'naručite': 'naručiti se', 'našem': 'naš', 'našu': 'naš', 'nedjeljom': 'nedjelja',
    'nedjelju': 'nedjelja', 'nedostaje': 'nedostajati', 'njom': 'ona', 'nosite': 'nositi', 'nova': 'nov', 'nove': 'nov',
    'novoj': 'nov', 'novca': 'novac', 'obitelji': 'obitelj', 'obiteljske': 'obiteljski', 'objesi': 'objesiti',
    'odaberite': 'odabrati', 'odjeću': 'odjeća', 'odmara': 'odmarati se', 'odvajajte': 'odvajati', 'odvoza': 'odvoz',
    'originalno': 'originalan', 'osobe': 'osoba', 'osobnu': 'osobna iskaznica', 'ostaci': 'ostatak',
    'ostavljajte': 'ostaviti', 'ostavljamo': 'ostaviti', 'otkažete': 'otkazati', 'otkažite': 'otkazati',
    'otvoreno': 'otvoren', 'organizira': 'organizirati', 'pada': 'padati', 'palačinke': 'palačinka',
    'paketomatu': 'paketomat', 'parku': 'park', 'pecite': 'peći', 'peciva': 'pecivo', 'pedijatra': 'pedijatar',
    'pekare': 'pekara', 'pekmezom': 'pekmez', 'pereš': 'prati', 'perilice': 'perilica', 'perilicom': 'perilica',
    'pečena': 'pečen', 'pijte': 'piti', 'piju': 'piti', 'pitajte': 'pitati', 'pitanja': 'pitanje', 'pićem': 'piće',
    'pješaci': 'pješak', 'planinama': 'planina', 'plava': 'plav', 'plaćate': 'plaćati', 'plaže': 'plaža',
    'podrumu': 'podrum', 'podsjećamo': 'podsjećati', 'polaska': 'polazak', 'policijskoj': 'policijski',
    'pomažu': 'pomagati', 'ponedjeljka': 'ponedjeljak', 'ponesite': 'ponijeti', 'poništite': 'poništiti',
    'ponoći': 'ponoć', 'popodnevna': 'popodnevni', 'popravka': 'popravak', 'poruci': 'poruka', 'posjetite': 'posjetiti',
    'posla': 'posao', 'potrebno': 'potreban', 'potvrdu': 'potvrda', 'povodcu': 'povodac', 'povrata': 'povrat',
    'povratnu': 'povratna karta', 'početka': 'početak', 'početku': 'početak', 'početnike': 'početnik',
    'počinje': 'počinjati', 'pošaljite': 'poslati', 'pošiljke': 'pošiljka', 'poštovana': 'poštovani',
    'praznikom': 'praznik', 'praćenje': 'praćenje pošiljke', 'predajete': 'predati', 'prekrasne': 'prekrasan',
    'prevodi': 'prevoditi', 'prijatelja': 'prijatelj', 'prijatelji': 'prijatelj', 'prijave': 'prijava',
    'pripreme': 'pripremiti', 'prirodu': 'priroda', 'priča': 'pričati', 'pričaju': 'pričati', 'probaj': 'probati',
    'probajte': 'probati', 'prodavača': 'prodavač', 'prvom': 'prvi', 'psi': 'pas', 'psom': 'pas', 'puta': 'put',
    'putnici': 'putnik', 'putnicima': 'putnik', 'putnika': 'putnik', 'putovnicu': 'putovnica', 'puše': 'puhati',
    'radi': 'raditi', 'radim': 'raditi', 'radimo': 'raditi', 'radijatori': 'radijator', 'radno': 'radno vrijeme',
    'radnu': 'radna odjeća', 'radova': 'radovi', 'rajčice': 'rajčica', 'razumijem': 'razumjeti',
    'razumijevanju': 'razumijevanje', 'računa': 'račun', 'recepciji': 'recepcija', 'recepte': 'recept', 'redu': 'u redu',
    'rezervaciji': 'rezervacija', 'rezervaciju': 'rezervacija', 'ribu': 'riba', 'riječi': 'riječ', 'rivu': 'riva',
    'robe': 'roba', 'robu': 'roba', 'roku': 'rok', 'rođenja': 'datum rođenja', 'rublja': 'rublje', 'rujna': 'rujan',
    'sa': 's', 'sata': 'sat', 'sati': 'sat', 'siječnja': 'siječanj', 'sina': 'sin', 'sjeveru': 'sjever',
    'skladištu': 'skladište', 'slavim': 'slaviti', 'slobodna': 'slobodan', 'slučajevi': 'slučaj', 'smeđa': 'smeđ',
    'smijete': 'smjeti', 'smiju': 'smijati se', 'smjene': 'smjena', 'smjese': 'smjesa', 'smještaju': 'smještaj',
    'sms-om': 'sms', 'sobaricu': 'sobarica', 'sobom': 'sebe', 'soli': 'sol', 'spava': 'spavati', 'srijedu': 'srijeda',
    'stanare': 'stanar', 'stanarima': 'stanar', 'stanici': 'stanica', 'stanovanja': 'stanovanje', 'stanu': 'stan',
    'stavite': 'staviti', 'stazama': 'staza', 'stiže': 'stići', 'stolicu': 'stolica', 'strance': 'stranac',
    'strane': 'strana', 'stranici': 'stranica', 'stranicu': 'stranica', 'strpljivi': 'strpljiv', 'studenoga': 'studeni',
    'stupnjeva': 'stupanj', 'stvari': 'stvar', 'subote': 'subota', 'subotu': 'subota', 'sudski': 'sudski tumač',
    'tumač': 'sudski tumač', 'svake': 'svaki', 'svako': 'svaki', 'svijeta': 'svijet', 'svira': 'svirati',
    'svjedodžbu': 'svjedodžba', 'svjetla': 'svjetlo', 'svježi': 'svjež', 'svježu': 'svjež', 'tavu': 'tava',
    'telefonom': 'telefon', 'temperaturu': 'temperatura', 'terasi': 'terasa', 'tečaju': 'tečaj', 'toplija': 'topao',
    'topliju': 'topao', 'toplo': 'topao', 'traje': 'trajati', 'trajekti': 'trajekt', 'trajektom': 'trajekt',
    'tramvaja': 'tramvaj', 'tramvajem': 'tramvaj', 'tramvaju': 'tramvaj', 'traži': 'tražiti', 'trebaju': 'trebati',
    'trebam': 'trebati', 'trebamo': 'trebati', 'trebate': 'trebati', 'trgovima': 'trg', 'trgovine': 'trgovina',
    'trgovinu': 'trgovina', 'tržnicu': 'tržnica', 'turista': 'turist', 'tušira': 'tuširati se', 'tvrtku': 'tvrtka',
    'udobne': 'udoban', 'ukrajinsko': 'ukrajinski', 'ukrajinskom': 'ukrajinski', 'ulja': 'ulje', 'upisuje': 'upisati',
    'upišite': 'upisati', 'upoznaje': 'upoznati', 'upravi': 'uprava', 'upravitelja': 'upravitelj zgrade',
    'uputnice': 'uputnica', 'uputnicu': 'uputnica', 'uvjeti': 'uvjet', 'uzimajte': 'uzimati', 'uzimam': 'uzimati',
    'uzmi': 'uzeti', 'uzmite': 'uzeti', 'uči': 'učiti', 'učim': 'učiti', 'vaša': 'vaš', 'vašem': 'vaš',
    'važeću': 'važeći', 'velika': 'velik', 'velike': 'velik', 'veću': 'velik', 'vidim': 'vidjeti', 'vidimo': 'vidjeti',
    'vode': 'voda', 'vodu': 'voda', 'voditeljem': 'voditelj', 'voditelju': 'voditelj', 'voditeljica': 'voditelj',
    'voli': 'voljeti', 'volju': 'volja', 'voze': 'voziti', 'vozi': 'voziti', 'vrati': 'vratiti', 'vraćamo': 'vratiti', 'jeftinija': 'jeftin', 'platite': 'platiti', 'svibnja': 'svibanj', 'hotelu': 'hotel',
    'vrećicu': 'vrećica', 'vrijedi': 'vrijediti', 'zaboravi': 'zaboraviti', 'zagrij': 'zagrijati', 'zagrijte': 'zagrijati',
    'zamjenu': 'zamjena', 'zbunim': 'zbuniti se', 'zdjelu': 'zdjela', 'zdravstveno': 'zdravstveno osiguranje',
    'zdravstvenu': 'zdravstveni', 'zelena': 'zelen', 'zgrade': 'zgrada', 'zimsku': 'zimski', 'zove': 'zvati',
    'zovem': 'zvati', 'zovite': 'zvati', 'čeka': 'čekati', 'čekam': 'čekati', 'četvrtka': 'četvrtak', 'čisto': 'čist',
    'čita': 'čitati', 'čokoladom': 'čokolada', 'čuvate': 'čuvati', 'šetamo': 'šetati', 'šetnju': 'šetnja',
    'šećera': 'šećer', 'škole': 'škola', 'školu': 'škola', 'žao': 'žao mi je', 'želim': 'željeti', 'živi': 'živjeti',
    'živim': 'živjeti', 'životinje': 'životinja', 'žlice': 'žlica', 'žuta': 'žut',
})

# ---------------------------------------------------------------- власні назви
NAMES.update({
    'Ana': 'Ана (ім’я)', 'Andrij': 'Андрій (ім’я)', 'Babić': 'Бабич (прізвище)', 'Brač': 'Брач (острів)',
    'Danilo': 'Данило (ім’я)', 'Horvat': 'Горват (прізвище)', 'Ilica': 'Іліца (вулиця в Загребі)', 'Ivana': 'Івана (ім’я)',
    'Jurić': 'Юрич (прізвище)', 'Kovalenko': 'Коваленко (прізвище)', 'Lungomare': '«Лунгомаре» (назва ресторану)',
    'Marija': 'Марія (ім’я)', 'Marko': 'Марко (ім’я)', 'Marina': '«Марина» (назва готелю)', 'Melnyk': 'Мельник (прізвище)',
    'Oksana': 'Оксана (ім’я)', 'Olena': 'Олена (ім’я)', 'Perić': 'Перич (прізвище)', 'Sofija': 'Софія (ім’я)',
    'Sljeme': 'Слєме (гора біля Загреба)', 'Taras': 'Тарас (ім’я)', 'Trešnjevka': 'Трешнєвка (район Загреба)',
    'Zagreb': 'Загреб', 'Zrinjevac': 'Зриньовац (парк у Загребі)', 'B': 'B (літера, позначення входу)',
})
NAMES_LOWER.update({
    'annu': 'Анна (ім’я)', 'bana': 'бан (титул; «Trg bana Jelačića» — площа в Загребі)',
    'jelačića': 'Єлачич (прізвище; «Trg bana Jelačića» — площа в Загребі)', 'hvara': 'Хвар (острів)',
    'jadranu': 'Адріатика (Адріатичне море)', 'marije': 'Марія (ім’я)', 'marka': 'Марко (ім’я)', 'poljske': 'Польща',
    'rijeci': 'Рієка (місто)', 'splita': 'Спліт (місто)', 'tarase': 'Тарас (ім’я, кличний відмінок)',
    'zagreba': 'Загреб', 'zagrebu': 'Загреб', 'glavnog': 'головний',
})

# Початкова форма для відмінкових форм імен і назв (у словничку показуємо «Zagreb», а не «zagrebu»)
NAMES_LEMMA = {
    'annu': 'Anna', 'bana': 'ban', 'jelačića': 'Jelačić', 'hvara': 'Hvar', 'jadranu': 'Jadran',
    'marije': 'Marija', 'marka': 'Marko', 'poljske': 'Poljska', 'rijeci': 'Rijeka', 'splita': 'Split',
    'tarase': 'Taras', 'zagreba': 'Zagreb', 'zagrebu': 'Zagreb', 'glavnog': 'glavni',
}

# Видові пари й точніші леми (виправлено 2026-10-15 разом із граматичними підказками):
# форма тексту має належати саме цьому дієслову (dobivate — від dobivati, а не від dobiti)
FORMS.update({
    'dobivate': 'dobivati', 'iznesi': 'iznijeti', 'nahrani': 'nahraniti', 'molimo': 'moliti',
    'ostavljamo': 'ostavljati', 'ostavljajte': 'ostavljati', 'predajete': 'predavati',
    'iznajmljujem': 'iznajmljivati', 'upisuje': 'upisivati se', 'upoznaje': 'upoznavati',
    'voditeljica': 'voditeljica', 'vraćamo': 'vraćati', 'nisu': 'biti', 'niste': 'biti',
    'stiže': 'stizati',
})
EXTRA.update({
    'dobivati': 'отримувати', 'iznijeti': 'винести', 'nahraniti': 'нагодувати', 'moliti': 'просити («molimo» — просимо)',
    'ostavljati': 'залишати', 'predavati': 'подавати; здавати (документи)', 'iznajmljivati': 'здавати в оренду',
    'upisivati se': 'записуватися', 'upoznavati': 'знайомитися (з кимось)', 'voditeljica': 'керівниця',
    'stizati': 'прибувати; надходити',
})

# Видова пара до дієслова з уроків вважається знайомою (у частці знайомих слів), але в тренажер не зберігається
ASPECT_PAIRS = {
    'dobivati': 'dobiti', 'iznijeti': 'iznositi', 'nahraniti': 'hraniti', 'ostavljati': 'ostaviti',
    'predavati': 'predati', 'iznajmljivati': 'iznajmiti', 'upisivati se': 'upisati', 'upoznavati': 'upoznati',
    'vraćati': 'vratiti', 'stizati': 'stići',
}
KNOWN.update(ASPECT_PAIRS)

# ---------------------------------------------------------------- значення в конкретному тексті
TEXT_FORMS.update({
    'RD-A1-005': {'meni': ('dnevni meni', 'денне меню'), 'dnevni': ('dnevni meni', 'денне меню')},
    'RD-A1-011': {'kod': ('kod', 'у, біля («kod kuće» — вдома); також іменник «код» («kod za otvaranje»)')},
    'RD-A1-015': {'plaća': ('plaćati', 'платити («parkiranje se plaća» — паркування платне)')},
    'RD-A1-012': {'pravo': ('imati pravo', 'мати рацію')},
    'RD-A1-014': {'je': ('nju', 'її (займенник)')},
    'RD-A1-022': {'ljudske': ('ljudski resursi', 'людські ресурси (відділ кадрів)'), 'resurse': ('ljudski resursi', 'людські ресурси (відділ кадрів)')},
    'RD-A1-024': {'sama': ('sam', 'сама (одна)')},
    'RD-A1-020': {'kanta': ('kanta za smeće', 'контейнер для сміття'), 'kanti': ('kanta za smeće', 'контейнер для сміття')},
    'RD-A1-030': {'deku': ('deka', 'ковдра; плед')},
    'RD-A1-036': {'vraćamo': ('vraćati se', 'повертатися')},
    'RD-A1-032': {'sam': ('sam', 'сам (один)')},
    'RD-A1-037': {'stranom': ('stran', 'іноземний')},
    'RD-A1-040': {'zovem': ('zovem se', 'мене звати')},
})

# =============================================================================
# A0 (вивіски) і A2 (тексти) · 2026-10-15
# =============================================================================
NAMES.update({
    'Ira': 'Іра (ім’я)', 'Ivo': 'Іво (ім’я)', 'Kovač': 'Ковач (прізвище)', 'Dubrovnik': 'Дубровник (місто)',
    'Lokrum': 'Локрум (острів біля Дубровника)', 'Krk': 'Крк (острів)', 'Dolac': 'Долац (ринок у Загребі)',
})
NAMES_LOWER.update({
    'rijeku': 'Рієка (місто)', 'splitu': 'Спліт (місто)', 'plitvicama': 'Плітвицькі озера (національний парк)',
    'istre': 'Істрія (півострів)', 'slavonije': 'Славонія (край на сході Хорватії)', 'dalmacije': 'Далмація (край на узбережжі)',
    'opatiju': 'Опатія (місто біля моря)', 'jurićem': 'Юрич (прізвище)',
})
NAMES_LEMMA.update({
    'rijeku': 'Rijeka', 'splitu': 'Split', 'plitvicama': 'Plitvice', 'istre': 'Istra', 'slavonije': 'Slavonija',
    'dalmacije': 'Dalmacija', 'opatiju': 'Opatija', 'jurićem': 'Jurić',
})

FORMS.update({
    # biti / htjeti / займенники
    'bih': 'biti', 'bila': 'biti', 'bili': 'biti', 'bilo': 'biti', 'bio': 'biti', 'bit': 'biti', 'bude': 'biti',
    'jesmo': 'biti', 'jeste': 'biti', 'nisam': 'biti', 'ste': 'biti',
    'će': 'htjeti', 'ću': 'htjeti', 'ćeš': 'htjeti', 'ćemo': 'htjeti', 'ćete': 'htjeti', 'nećemo': 'htjeti',
    'hoćemo': 'htjeti', 'hoćete': 'htjeti', 'htio': 'htjeti', 'htjela': 'htjeti',
    'me': 'ja', 'tebe': 'ti', 'mu': 'on', 'ju': 'ona', 'ih': 'oni', 'njima': 'oni', 'nas': 'mi', 'vam': 'vi', 'vama': 'vi',
    'koje': 'koji', 'naše': 'naš', 'našoj': 'naš', 'ove': 'ovaj', 'ovo': 'ovaj', 'ovog': 'ovaj',
    'svojoj': 'svoj', 'svoju': 'svoj', 'svom': 'svoj', 'tvoji': 'tvoj', 'njegova': 'njegov', 'sva': 'sav', 'svi': 'sav',
    'toga': 'to', 'tome': 'to', 'sama': 'sam',
    # дієслова
    'blokirao': 'blokirati', 'bojim': 'bojati se', 'boljelo': 'boljeti', 'curi': 'curiti', 'dala': 'dati',
    'dirajte': 'dirati', 'dobijemo': 'dobiti', 'dobit': 'dobiti', 'donesete': 'donijeti', 'donio': 'donijeti',
    'doselili': 'doseliti se', 'došao': 'doći', 'došla': 'doći', 'gledala': 'gledati', 'gledali': 'gledati',
    'govorili': 'govoriti', 'griješim': 'griješiti', 'grlim': 'grliti', 'guraj': 'gurati', 'hodali': 'hodati',
    'idete': 'ići', 'idite': 'ići', 'išli': 'ići', 'igra': 'igrati', 'imaju': 'imati', 'imala': 'imati',
    'izašao': 'izaći', 'javila': 'javiti se', 'javljam': 'javljati se', 'jeli': 'jesti', 'kašljala': 'kašljati',
    'kaže': 'kazati', 'kažu': 'kazati', 'koštaju': 'koštati', 'kupali': 'kupati se', 'kupila': 'kupiti',
    'ležala': 'ležati', 'mislim': 'misliti', 'mora': 'morati', 'moramo': 'morati', 'naginji': 'naginjati se',
    'napravila': 'napraviti', 'napravio': 'napraviti', 'naručila': 'naručiti se', 'navikla': 'naviknuti se',
    'nazovite': 'nazvati', 'nazvala': 'nazvati', 'nazvao': 'nazvati', 'našla': 'naći', 'nedostaju': 'nedostajati',
    'objasnio': 'objasniti', 'objašnjava': 'objašnjavati', 'odgovorio': 'odgovoriti', 'održava': 'održavati se',
    'oduševio': 'oduševiti', 'odvaja': 'odvajati', 'oprosti': 'oprostiti', 'organizirane': 'organizirati',
    'osjećala': 'osjećati se', 'ostanite': 'ostati', 'otišao': 'otići', 'otišli': 'otići', 'ovisi': 'ovisiti',
    'očekuju': 'očekivati', 'padala': 'padati', 'pazi': 'paziti', 'pazite': 'paziti', 'pila': 'piti',
    'pisat': 'pisati', 'pišite': 'pisati', 'pitaju': 'pitati', 'pokazao': 'pokazati', 'pokazat': 'pokazati',
    'pokucajte': 'pokucati', 'pokušala': 'pokušati', 'položi': 'položiti', 'položio': 'položiti', 'ponudio': 'ponuditi',
    'poslala': 'poslati', 'pošaljete': 'poslati', 'potpišete': 'potpisati', 'poznaju': 'poznavati', 'pozvala': 'pozvati',
    'pozvonite': 'pozvoniti', 'počela': 'početi', 'počeo': 'početi', 'predložite': 'predložiti',
    'pregledala': 'pregledati', 'prehladila': 'prehladiti se', 'preseliti': 'preseliti se', 'prijavite': 'prijaviti se',
    'primamo': 'primati', 'primili': 'primiti', 'probali': 'probati', 'promijenila': 'promijeniti', 'pronašla': 'pronaći',
    'putovali': 'putovati', 'putovao': 'putovati', 'putovat': 'putovati', 'radio': 'raditi', 'radite': 'raditi',
    'razgovara': 'razgovarati', 'razgovarale': 'razgovarati', 'razgovarao': 'razgovarati', 'razumio': 'razumjeti',
    'rekla': 'reći', 'rezervirala': 'rezervirati', 'rezervirali': 'rezervirati', 'sele': 'seliti se',
    'shvatio': 'shvatiti', 'spavajte': 'spavati', 'spavala': 'spavati', 'sviđa': 'sviđati se', 'trajao': 'trajati',
    'trajat': 'trajati', 'treba': 'trebati', 'unajmio': 'unajmiti', 'usporedim': 'usporediti', 'uzimala': 'uzimati',
    'učila': 'učiti', 'učio': 'učiti', 'učit': 'učiti', 'vidjela': 'vidjeti', 'vidjeli': 'vidjeti', 'volimo': 'voljeti',
    'vrijedilo': 'vrijediti', 'vuci': 'vući', 'zahvalio': 'zahvaliti se', 'zatvorite': 'zatvoriti', 'završit': 'završiti',
    'zna': 'znati', 'znala': 'znati', 'znamo': 'znati', 'zvuči': 'zvučati', 'šetali': 'šetati', 'želi': 'željeti',
    'želio': 'željeti', 'želite': 'željeti', 'žure': 'žuriti', 'oštetiti': 'oštetiti se',
    # іменники
    'autobusom': 'autobus', 'avionom': 'avion', 'banku': 'banka', 'bolnice': 'bolnica', 'boravka': 'boravak',
    'brodom': 'brod', 'danom': 'dan', 'djecu': 'djeca', 'e-mailove': 'mail', 'eura': 'euro', 'filmove': 'film',
    'garaže': 'garaža', 'gradilištu': 'gradilište', 'gradove': 'grad', 'gradu': 'grad', 'grla': 'grlo', 'gužve': 'gužva',
    'hotela': 'hotel', 'jezera': 'jezero', 'kafića': 'kafić', 'kante': 'kanta', 'kartice': 'kartica',
    'klijentima': 'klijent', 'koferom': 'kofer', 'kolači': 'kolač', 'kolege': 'kolega', 'kolegom': 'kolega',
    'kolovoza': 'kolovoz', 'kolovozu': 'kolovoz', 'komada': 'komad', 'kraja': 'kraj', 'krevetu': 'krevet',
    'krovove': 'krov', 'kruške': 'kruška', 'kupaonici': 'kupaonica', 'kupnji': 'kupnja', 'kutiju': 'kutija',
    'kući': 'kuća', 'liječnici': 'liječnik', 'liječnicu': 'liječnica', 'listopadu': 'listopad', 'ljekarni': 'ljekarna',
    'ljeta': 'ljeto', 'matematike': 'matematika', 'mjeseci': 'mjesec', 'mlijekom': 'mlijeko', 'nedjelje': 'nedjelja',
    'novčanika': 'novčanik', 'novčaniku': 'novčanik', 'noći': 'noć', 'odgojiteljice': 'odgojiteljica',
    'odgovoru': 'odgovor', 'organizatori': 'organizator', 'osiguranju': 'osiguranje', 'peroni': 'peron',
    'petka': 'petak', 'pića': 'piće', 'planine': 'planina', 'pogledom': 'pogled', 'polasci': 'polazak',
    'polaznici': 'polaznik', 'posjetitelja': 'posjetitelj', 'posjetitelji': 'posjetitelj', 'posjetnici': 'posjetnica',
    'poslu': 'posao', 'povrća': 'povrće', 'poštom': 'pošta', 'poštovanjem': 'poštovanje', 'pravila': 'pravilo',
    'predstave': 'predstava', 'prijatelje': 'prijatelj', 'prijateljima': 'prijatelj', 'prijevoza': 'prijevoz',
    'proizvodima': 'proizvod', 'radionice': 'radionica', 'radu': 'rad', 'razinu': 'razina', 'razredu': 'razred',
    'račune': 'račun', 'restoranu': 'restoran', 'ruke': 'ruka', 'selu': 'selo', 'serije': 'serija', 'sireve': 'sir',
    'sirom': 'sir', 'slapove': 'slap', 'smjenama': 'smjena', 'sobe': 'soba', 'srpnja': 'srpanj', 'srpnju': 'srpanj',
    'stana': 'stan', 'stanovi': 'stan', 'stolu': 'stol', 'stranice': 'stranica', 'sreće': 'sreća',
    'telefona': 'telefon', 'tečaja': 'tečaj', 'titlovima': 'titl', 'trgu': 'trg', 'tvrtki': 'tvrtka',
    'ukrajine': 'Ukrajina', 'umivaonika': 'umivaonik', 'upalu': 'upala', 'utorkom': 'utorak', 'vatrogasci': 'vatrogasac',
    'vikenda': 'vikend', 'vikendom': 'vikend', 'vina': 'vino', 'voća': 'voće', 'vremena': 'vrijeme', 'vrtiću': 'vrtić',
    'zadatke': 'zadatak', 'zidinama': 'zidine', 'znanja': 'znanje', 'zraku': 'zrak', 'četvrtkom': 'četvrtak',
    'čokolade': 'čokolada', 'šatoru': 'šator', 'štandova': 'štand', 'životu': 'život',
    'hrvatskoj': 'Hrvatska', 'hrvatsku': 'Hrvatska',
    # прикметники й прислівники
    'bakini': 'bakin', 'bankovna': 'bankovni', 'bijeli': 'bijel', 'bolesni': 'bolestan', 'buduće': 'budući',
    'cijele': 'cijel', 'cijelo': 'cijel', 'crni': 'crn', 'crvene': 'crven', 'dječje': 'dječji', 'dobra': 'dobar',
    'domaćim': 'domaći', 'druge': 'drugi', 'drugo': 'drugi', 'engleskom': 'engleski', 'gradskim': 'gradski',
    'hrvatske': 'hrvatski', 'hrvatskom': 'hrvatski', 'izgubljene': 'izgubljen', 'javnog': 'javni', 'jednim': 'jedan',
    'jedno': 'jedan', 'jednog': 'jedan', 'jednostavna': 'jednostavan', 'jeftinije': 'jeftin', 'kakve': 'kakav',
    'lakše': 'lak', 'mala': 'mali', 'malih': 'mali', 'malog': 'mali', 'maloj': 'mali', 'malom': 'mali',
    'maslinovo': 'maslinov', 'mirna': 'miran', 'mirnije': 'miran', 'najbliže': 'najbliži', 'najbolja': 'najbolji',
    'nepoznata': 'nepoznat', 'nervozna': 'nervozan', 'novi': 'nov', 'odlična': 'odličan', 'odrasle': 'odrasli',
    'osobna': 'osobna iskaznica', 'plavo': 'plav', 'prehlađeno': 'prehlađen', 'prekrasno': 'prekrasan',
    'prošle': 'prošli', 'prošlog': 'prošli', 'prošlo': 'prošli', 'prva': 'prvi', 'prve': 'prvi', 'prvih': 'prvi',
    'radnim': 'radni', 'savršeno': 'savršen', 'skupi': 'skup', 'skuplji': 'skup', 'sljedećeg': 'sljedeći',
    'spora': 'spor', 'starom': 'star', 'stranih': 'stran', 'svakodnevnom': 'svakodnevni', 'svježem': 'svjež',
    'teška': 'težak', 'treće': 'treći', 'ukusno': 'ukusan', 'umorni': 'umoran', 'važnije': 'važan', 'velikom': 'velik',
    'veće': 'velik', 'visoku': 'visok', 'zatvoreno': 'zatvoren', 'zdravstvenom': 'zdravstveni', 'čišći': 'čist',
    'mobilno': 'mobilno bankarstvo', 'bankarstvo': 'mobilno bankarstvo', 'drago': 'drago mi je',
    'godišnji': 'godišnji odmor',
})

EXTRA.update({
    # службові слова, займенники
    'kako': 'як', 'gdje': 'де', 'kamo': 'куди', 'nikamo': 'нікуди', 'to': 'це; те', 'on': 'він', 'oni': 'вони',
    'koji': 'який; котрий', 'svoj': 'свій', 'tvoj': 'твій', 'njegov': 'його (присвійний)', 'sav': 'весь; усі',
    'nešto': 'щось', 'još': 'ще («još uvijek» — досі)', 'tako': 'так; такий', 'jako': 'дуже', 'ni': 'ні; навіть (не)',
    'pa': 'тож; тому; а потім', 'iako': 'хоча', 'kroz': 'крізь; через', 'preko': 'через (сайт, телефон)',
    'pokraj': 'біля', 'osim': 'крім («osim toga» — крім того)', 'zatim': 'потім', 'također': 'також',
    'baš': 'саме; якраз', 'čak': 'навіть', 'zar': 'хіба («…, zar ne?» — правда ж?)', 'dalje': 'далі («i dalje» — і далі)',
    'kakav': 'який (якого типу)', 'nekoliko': 'кілька',
    # дієслова
    'aktivirati': 'активувати', 'blokirati': 'заблокувати', 'bojati se': 'боятися', 'boljeti': 'боліти',
    'curiti': 'текти, капати', 'dati': 'дати', 'dirati': 'чіпати, торкатися', 'doseliti se': 'переїхати (на нове місце)',
    'griješiti': 'помилятися', 'gurati': 'штовхати («guraj» — від себе)', 'izaći': 'вийти', 'javljati se': 'писати, озиватися',
    'kazati': 'казати', 'ležati': 'лежати', 'naginjati se': 'нахилятися, вихилятися', 'napraviti': 'зробити',
    'naviknuti se': 'звикнути', 'nazvati': 'зателефонувати', 'objasniti': 'пояснити', 'objašnjavati': 'пояснювати',
    'odgovoriti': 'відповісти', 'održavati se': 'відбуватися, проходити (про подію)', 'oduševiti': 'захопити, зачарувати',
    'oprostiti': 'вибачити («oprosti» — вибач)', 'osjećati se': 'почуватися', 'ostati': 'залишитися',
    'otići': 'піти; поїхати', 'ovisiti': 'залежати', 'očekivati': 'очікувати', 'oštetiti se': 'пошкодитися',
    'paziti': 'стежити, наглядати; остерігатися («pazi!» — обережно!)', 'pisati': 'писати', 'pokazati': 'показати',
    'pokucati': 'постукати', 'pokušati': 'спробувати', 'položiti': 'скласти (іспит)', 'ponuditi': 'запропонувати',
    'potpisati': 'підписати', 'poznavati': 'знати (когось), бути знайомим', 'pozvati': 'запросити',
    'pozvoniti': 'подзвонити (у двері)', 'predložiti': 'запропонувати', 'pregledati': 'оглянути',
    'prehladiti se': 'застудитися', 'preseliti se': 'переїхати, перенестися', 'prijaviti se': 'записатися, зареєструватися',
    'primati': 'приймати', 'primiti': 'отримати', 'promijeniti': 'змінити', 'pronaći': 'знайти',
    'provesti': 'провести (час)', 'putovati': 'подорожувати, їхати', 'razgovarati': 'розмовляти', 'reći': 'сказати',
    'rezervirati': 'забронювати', 'riješiti': 'вирішити; розглянути (заяву)', 'seliti se': 'переїжджати',
    'shvatiti': 'зрозуміти', 'unajmiti': 'винайняти', 'usporediti': 'порівняти', 'ustati': 'встати',
    'vući': 'тягти («vuci» — на себе)', 'zahvaliti se': 'подякувати', 'zaraziti': 'заразити', 'zatvoriti': 'зачинити; закрити',
    'završiti': 'закінчити', 'zvučati': 'звучати', 'žuriti': 'поспішати',
    # іменники
    'antibiotik': 'антибіотик', 'cjenik': 'ціни, прайс', 'kanta': 'контейнер; відро', 'konobarica': 'офіціантка',
    'krov': 'дах', 'lift': 'ліфт', 'matematika': 'математика', 'organizator': 'організатор', 'papirologija': 'паперова тяганина',
    'pod': 'підлога', 'pogled': 'вид; погляд', 'polaznik': 'слухач (курсу)', 'pomoćnica': 'помічниця',
    'posjet': 'візит («u posjet» — у гості)', 'posjetitelj': 'відвідувач', 'posjetnica': 'візитівка',
    'poštovanje': 'повага («S poštovanjem» — з повагою)', 'prizemlje': 'партер (поверх біля входу)',
    'problem': 'проблема', 'produženje': 'продовження', 'program': 'програма', 'proizvod': 'продукт, виріб',
    'rad': 'праця, робота («ugovor o radu» — трудовий договір)', 'radionica': 'майстер-клас; майстерня',
    'razred': 'клас (у школі)', 'savjetnik': 'консультант', 'serija': 'серіал', 'sram': 'сором («bilo ga je sram» — йому було соромно)',
    'sreća': 'щастя; удача («imati sreće» — пощастило)', 'susjeda': 'сусідка', 'test': 'тест', 'titl': 'субтитр',
    'umivaonik': 'умивальник', 'ventil': 'вентиль', 'wc': 'туалет', 'wi-fi': 'Wi-Fi (бездротовий інтернет)',
    'zrak': 'повітря', 'šator': 'намет', 'štand': 'стенд, намет (на ярмарку)', 'Ukrajina': 'Україна',
    'h': 'скорочення: sat (година)', 'km': 'скорочення: kilometar (кілометр)',
    # прикметники й прислівники
    'bakin': 'бабусин', 'bankovni': 'банківський', 'budući': 'майбутній', 'dogovoreno': 'домовилися', 'dovoljno': 'достатньо',
    'gust': 'густий; щільний', 'izgubljen': 'загублений («ured za izgubljene stvari» — бюро знахідок)', 'javni': 'громадський',
    'jednostavan': 'простий', 'jednostavno': 'просто', 'lijepo': 'гарно; щиро', 'maslinov': 'оливковий',
    'mokar': 'мокрий', 'moguć': 'можливий', 'najbliži': 'найближчий', 'najbolji': 'найкращий', 'najmanje': 'щонайменше',
    'najviše': 'найбільше', 'najvažnije': 'найважливіше', 'nepoznat': 'незнайомий', 'normalno': 'нормально',
    'odličan': 'чудовий', 'osobito': 'особливо', 'potpun': 'повний', 'prehlađen': 'застуджений', 'prošli': 'минулий',
    'savršen': 'ідеальний', 'sigurno': 'неодмінно; напевно', 'skoro': 'майже', 'slobodno': 'сміливо; вільно',
    'spor': 'повільний', 'stalno': 'постійно', 'svakodnevni': 'повсякденний', 'tekući': 'поточний («tekući račun»)',
    'ugodan': 'приємний', 'unaprijed': 'заздалегідь', 'visok': 'високий', 'važan': 'важливий', 'zatvoren': 'зачинений',
    'zimi': 'узимку', 'bolje': 'краще', 'mnogi': 'багато (хто)',
})

# Службові слова й займенники граматики A0–A1 — знайомі
KNOWN.update({'kako', 'gdje', 'kamo', 'to', 'on', 'oni', 'koji', 'svoj', 'tvoj', 'njegov', 'sav', 'nešto', 'još', 'tako',
              'jako', 'ni', 'pa', 'kroz', 'zatim', 'također', 'kakav', 'nekoliko'})

TEXT_FORMS.update({
    'RD-A2-001': {'prošlo': ('proći', 'пройти; минути («sve je prošlo dobro» — усе пройшло добре)')},
    'RD-A2-003': {'odmor': ('godišnji odmor', 'щорічна відпустка')},
    'RD-A2-006': {'odmor': ('godišnji odmor', 'щорічна відпустка')},
    'RD-A2-015': {'gorski': ('Gorski kotar', 'Горскі-Котар (гірський край)'), 'kotar': ('Gorski kotar', 'Горскі-Котар (гірський край)')},
    'RD-A2-019': {'hrvatske': ('Hrvatska', 'Хорватія')},
    'RD-A2-020': {'plitvička': ('Plitvička jezera', 'Плітвицькі озера (національний парк)'),
                  'jezera': ('Plitvička jezera', 'Плітвицькі озера (національний парк)')},
})
EXTRA.update({'proći': 'пройти; минути', 'ući': 'увійти', 'sam': 'сам; самотній', 'stran': 'іноземний', 'promet': 'рух (транспорту)'})
TEXT_FORMS.update({
    'RD-A0-003': {'zovem': ('zovem se', 'мене звати')},
    'RD-A0-010': {'smiju': ('smjeti', 'сміти, мати дозвіл («ne smiju» — не можна)')},
    'RD-A2-002': {'joj': ('joj', 'ой! (вигук)')},
    'RD-A2-008': {'je': ('nju', 'її (займенник)')},
})
TEXT_FORMS['RD-A2-020']['sam'] = ('sam', 'сам (самостійно)')
for _code in ('RD-A0-001', 'RD-A0-012'):  # «Dobro došli!» — сталий вираз (є в уроках A1)
    TEXT_FORMS.setdefault(_code, {}).update({'dobro': ('dobro došli', 'ласкаво просимо'), 'došli': ('dobro došli', 'ласкаво просимо')})
