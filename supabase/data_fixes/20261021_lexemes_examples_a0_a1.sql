-- =====================================================================
-- Приклади для слів A0 / A1 без прикладів · 2026-10-21
-- Згенеровано: python3 -B scripts/gen_lexemes_examples_20261021.py (не редагуйте вручну).
--
--   * 570 слів (A0 / A1), у яких не було жодного прикладу, отримують одне природне речення.
--   * Змінюється лише слово, у якого прикладів досі немає (examples = '[]'): наявні приклади не чіпаємо,
--     повторний запуск нічого не змінює. Стара версія → content_versions, запис у content_reviews.
--   * Бета, як уроки A0 / A1 (рішення власника 2026-10-12): носій перевіряє після публікації.
-- Спершу має бути запущено 20261021_lexemes_grammar_fields.sql.
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

do $fix$
declare
  d record;
  r record;
  v_changed int := 0;
  v_missing text := '';
begin
  if exists (select 1 from public.lexemes where lower(lemma) in ('vzdahnuti', 'ravnatitelj')) then
    raise exception 'Спершу запустіть supabase/data_fixes/20261021_lexemes_grammar_fields.sql';
  end if;
  for d in select * from jsonb_to_recordset('[
{
"k": "aerodrom",
"e": "Autobus za aerodrom polazi svakih pola sata."
},
{
"k": "ambulanta",
"e": "Ambulanta radi od sedam do tri."
},
{
"k": "aplikacija",
"e": "Kartu možeš kupiti preko aplikacije."
},
{
"k": "arhitektura",
"e": "Volim staru arhitekturu Splita."
},
{
"k": "australski ovčar",
"e": "Naš pas je australski ovčar."
},
{
"k": "automobil",
"e": "Moj automobil je na servisu."
},
{
"k": "autor",
"e": "Tko je autor ove knjige?"
},
{
"k": "benzin",
"e": "Moram natočiti benzin."
},
{
"k": "bez šećera",
"e": "Kavu uvijek pijem bez šećera."
},
{
"k": "bi",
"e": "Bi li mi mogao pomoći?"
},
{
"k": "bicikl",
"e": "Na posao idem biciklom."
},
{
"k": "bijeli",
"e": "Kupio sam bijeli kruh i mlijeko."
},
{
"k": "bijelo",
"e": "Bijelo vino ide uz ribu."
},
{
"k": "biljka",
"e": "Zalij biljku na balkonu."
},
{
"k": "bježati",
"e": "Djeca bježe od kiše pod krov."
},
{
"k": "bogat",
"e": "Njegov stric je jako bogat."
},
{
"k": "boja",
"e": "Koja ti je omiljena boja?"
},
{
"k": "bok",
"e": "Bok, kako si?"
},
{
"k": "brinuti se",
"e": "Ne brini se, sve će biti dobro."
},
{
"k": "brod",
"e": "Brod za Hvar polazi u devet."
},
{
"k": "brojka",
"e": "Napiši brojku sedam."
},
{
"k": "buditi se",
"e": "Svako jutro se budim u šest."
},
{
"k": "budućnost",
"e": "Planiramo budućnost u Hrvatskoj."
},
{
"k": "buka",
"e": "Na ulici je velika buka."
},
{
"k": "cijeniti",
"e": "Jako cijenim tvoju pomoć."
},
{
"k": "cilj",
"e": "Moj cilj je govoriti hrvatski bez straha."
},
{
"k": "cjepivo",
"e": "Cjepivo protiv gripe možete dobiti u ambulanti."
},
{
"k": "crni",
"e": "Uzet ću crni kaput."
},
{
"k": "crno",
"e": "Volim crno vino."
},
{
"k": "crtati",
"e": "Moja kći voli crtati životinje."
},
{
"k": "crveni",
"e": "Vidiš onaj crveni auto ispred kuće?"
},
{
"k": "crveno",
"e": "Stani, na semaforu je crveno."
},
{
"k": "deset",
"e": "Trgovina se otvara u deset sati."
},
{
"k": "deseti",
"e": "Danas je deseti dan našeg odmora."
},
{
"k": "devedeset",
"e": "Moj djed ima devedeset godina."
},
{
"k": "devet",
"e": "Na posao dolazim u devet sati."
},
{
"k": "deveti",
"e": "Ured je na devetom katu."
},
{
"k": "devetnaest",
"e": "Autobus broj devetnaest vozi do centra."
},
{
"k": "devizni račun",
"e": "Želim otvoriti devizni račun u banci."
},
{
"k": "dijalog",
"e": "Pročitajte dijalog naglas."
},
{
"k": "dizel",
"e": "Moj auto ide na dizel."
},
{
"k": "dizne",
"e": "Mehaničar kaže da treba očistiti dizne."
},
{
"k": "djevojka",
"e": "Ovo je moja djevojka Darja."
},
{
"k": "djevojčica",
"e": "Ta djevojčica ima pet godina."
},
{
"k": "dječak",
"e": "Dječak se igra loptom u parku."
},
{
"k": "dlaka",
"e": "Na kauču je puno pseće dlake."
},
{
"k": "dnevni",
"e": "Dnevni limit za podizanje novca je petsto eura."
},
{
"k": "dnevni sastanak",
"e": "Dnevni sastanak traje petnaest minuta."
},
{
"k": "dobitak",
"e": "Na lotu je osvojio veliki dobitak."
},
{
"k": "dobro",
"e": "Hvala, dobro sam."
},
{
"k": "dobro došli",
"e": "Dobro došli u Zagreb!"
},
{
"k": "dobro jutro svima",
"e": "Dobro jutro svima, počinjemo sastanak."
},
{
"k": "dobrodošli",
"e": "Dobrodošli u naš hotel!"
},
{
"k": "dodatan",
"e": "Za dodatan krevet plaća se deset eura."
},
{
"k": "dodati",
"e": "Možeš li dodati malo soli?"
},
{
"k": "događaj",
"e": "Koncert je bio događaj godine."
},
{
"k": "dok",
"e": "Čekaj me ovdje dok ne dođem."
},
{
"k": "dolaziti",
"e": "Autobus dolazi svakih deset minuta."
},
{
"k": "dolje",
"e": "Čekam te dolje, ispred zgrade."
},
{
"k": "donijeti",
"e": "Možete li nam donijeti jelovnik?"
},
{
"k": "donositi",
"e": "Poštar donosi pisma ujutro."
},
{
"k": "dozvola za boravak",
"e": "Dozvola za boravak vrijedi godinu dana."
},
{
"k": "dozvoliti",
"e": "Ne mogu ti to dozvoliti."
},
{
"k": "drag",
"e": "Ti si mi jako drag prijatelj."
},
{
"k": "drago",
"e": "Drago mi je što si došla."
},
{
"k": "drago mi je",
"e": "Drago mi je, ja sam Darja."
},
{
"k": "drugi",
"e": "Ovo je moj drugi tjedan u Zagrebu."
},
{
"k": "držati",
"e": "Drži se za ogradu, stepenice su klizave."
},
{
"k": "dva",
"e": "Molim vas dva kruha."
},
{
"k": "dvadeset",
"e": "Do stanice ima dvadeset minuta pješice."
},
{
"k": "dvadeset dva",
"e": "Moja soba je broj dvadeset dva."
},
{
"k": "dvadeset jedan",
"e": "Ovdje sam već dvadeset jedan dan."
},
{
"k": "dvanaest",
"e": "Ručamo u dvanaest sati."
},
{
"k": "dvjesto",
"e": "Let do Splita košta dvjesto eura."
},
{
"k": "elektronika",
"e": "Elektronika je na drugom katu trgovine."
},
{
"k": "gdje je apoteka",
"e": "Oprostite, gdje je apoteka?"
},
{
"k": "gdje je autobusni kolodvor",
"e": "Oprostite, gdje je autobusni kolodvor?"
},
{
"k": "gdje je banka",
"e": "Gdje je banka? Moram podići novac."
},
{
"k": "gdje je bankomat",
"e": "Gdje je bankomat? Nemam gotovine."
},
{
"k": "gdje je blagajna",
"e": "Gdje je blagajna? Htjela bih platiti."
},
{
"k": "gdje je izlaz",
"e": "Oprostite, gdje je izlaz?"
},
{
"k": "gdje je kabina",
"e": "Gdje je kabina? Želim probati ove hlače."
},
{
"k": "gdje je ljekarna",
"e": "Gdje je ljekarna? Boli me glava."
},
{
"k": "gdje je ulaz",
"e": "Gdje je ulaz u muzej?"
},
{
"k": "gdje je wc",
"e": "Oprostite, gdje je WC?"
},
{
"k": "gdje je zahod",
"e": "Oprostite, gdje je zahod?"
},
{
"k": "gdje je željeznički kolodvor",
"e": "Gdje je željeznički kolodvor? Moram stići na vlak."
},
{
"k": "gdje mogu kupiti kartu",
"e": "Gdje mogu kupiti kartu za autobus?"
},
{
"k": "gladan sam",
"e": "Gladan sam, idemo nešto pojesti."
},
{
"k": "gladna sam",
"e": "Mama, gladna sam!"
},
{
"k": "glas",
"e": "Imaš lijep glas."
},
{
"k": "gore",
"e": "Kupaonica je gore, na prvom katu."
},
{
"k": "gospodin",
"e": "Gospodin Kovač vas čeka."
},
{
"k": "gospođa",
"e": "Gospođa Horvat je naša susjeda."
},
{
"k": "govedina",
"e": "Danas za ručak imamo govedinu s krumpirom."
},
{
"k": "govorite li engleski",
"e": "Oprostite, govorite li engleski?"
},
{
"k": "govoriti tiho",
"e": "U knjižnici treba govoriti tiho."
},
{
"k": "graditi",
"e": "Grad gradi novi most."
},
{
"k": "gramatika",
"e": "Hrvatska gramatika nije laka."
},
{
"k": "greška",
"e": "Ispričavam se, to je moja greška."
},
{
"k": "grijanje",
"e": "Grijanje ne radi, hladno je."
},
{
"k": "grupa",
"e": "Naša grupa ima deset učenika."
},
{
"k": "guma",
"e": "Pukla mi je guma na autu."
},
{
"k": "higijena",
"e": "Higijena ruku je važna."
},
{
"k": "hladno",
"e": "Vani je jako hladno."
},
{
"k": "hrana za pse",
"e": "Kupi hranu za pse u trgovini."
},
{
"k": "idemo",
"e": "Idemo, zakasnit ćemo!"
},
{
"k": "igra",
"e": "Djeca vole ovu igru."
},
{
"k": "igrati se",
"e": "Djeca se igraju u parku."
},
{
"k": "igrač",
"e": "On je najbolji igrač u momčadi."
},
{
"k": "imam rezervaciju",
"e": "Dobar dan, imam rezervaciju na ime Petrenko."
},
{
"k": "imate li sitno",
"e": "Imate li sitno? Imam samo novčanicu od pedeset eura."
},
{
"k": "imate li slobodnu sobu",
"e": "Dobra večer, imate li slobodnu sobu za dvije noći?"
},
{
"k": "imate li wifi",
"e": "Imate li wifi u sobama?"
},
{
"k": "iskaznica",
"e": "Pokažite osobnu iskaznicu, molim."
},
{
"k": "iskreno",
"e": "Iskreno, ne sviđa mi se ovaj film."
},
{
"k": "isporuka",
"e": "Isporuka traje tri dana."
},
{
"k": "ispričavam se",
"e": "Ispričavam se, zakasnio sam."
},
{
"k": "isti",
"e": "Imamo isti mobitel."
},
{
"k": "izbor",
"e": "Ovdje je velik izbor voća."
},
{
"k": "izgubila sam se",
"e": "Oprostite, izgubila sam se. Gdje je glavni trg?"
},
{
"k": "izgubio sam se",
"e": "Izgubio sam se, možete li mi pomoći?"
},
{
"k": "iznenađenje",
"e": "Imam iznenađenje za tebe!"
},
{
"k": "iznositi",
"e": "Tko danas iznosi smeće?"
},
{
"k": "izvoli",
"e": "Izvoli, ovo je za tebe."
},
{
"k": "izvolite",
"e": "Izvolite, vaša kava."
},
{
"k": "ja bih vodu",
"e": "Ja bih vodu, molim."
},
{
"k": "ja sam gladan",
"e": "Ja sam gladan, a ti?"
},
{
"k": "ja sam iz ukrajine",
"e": "Zovem se Daša, ja sam iz Ukrajine."
},
{
"k": "ja sam umoran",
"e": "Ja sam umoran, idem spavati."
},
{
"k": "ja sam žedan",
"e": "Ja sam žedan, imaš li vode?"
},
{
"k": "jahta",
"e": "U luci je velika jahta."
},
{
"k": "jak",
"e": "Danas puše jak vjetar."
},
{
"k": "javan",
"e": "Ovaj park je javan i otvoren svima."
},
{
"k": "jedan",
"e": "Molim vas jedan kruh."
},
{
"k": "jedan smjer",
"e": "Trebam kartu samo u jedan smjer."
},
{
"k": "jedanaest",
"e": "Vlak polazi u jedanaest sati."
},
{
"k": "jeftino",
"e": "Ovdje se jede dobro i jeftino."
},
{
"k": "jelo",
"e": "Koje je vaše omiljeno jelo?"
},
{
"k": "jelovnik",
"e": "Možemo li dobiti jelovnik?"
},
{
"k": "još",
"e": "Još malo, molim."
},
{
"k": "kajati",
"e": "Kajem se što nisam došao."
},
{
"k": "kako da dođem do",
"e": "Kako da dođem do glavnog trga?"
},
{
"k": "kako se kaže",
"e": "Kako se kaže „hvala“ na hrvatskom?"
},
{
"k": "kako se zovete",
"e": "Dobar dan, kako se zovete?"
},
{
"k": "kako se zoveš",
"e": "Bok, kako se zoveš?"
},
{
"k": "kamo",
"e": "Kamo ideš?"
},
{
"k": "kamo idete",
"e": "Kamo idete ovog vikenda?"
},
{
"k": "kanta",
"e": "Baci to u kantu za smeće."
},
{
"k": "kao",
"e": "Govoriš hrvatski kao pravi Hrvat!"
},
{
"k": "karta u jednom smjeru",
"e": "Jedna karta u jednom smjeru do Splita, molim."
},
{
"k": "karta za zagreb",
"e": "Jedna karta za Zagreb, molim."
},
{
"k": "karta, molim",
"e": "Jedna karta, molim."
},
{
"k": "karticom ili gotovinom",
"e": "Plaćate karticom ili gotovinom?"
},
{
"k": "kasnije",
"e": "Nazvat ću te kasnije."
},
{
"k": "kasniti",
"e": "Vlak kasni dvadeset minuta."
},
{
"k": "kazati",
"e": "Što ti je kazao liječnik?"
},
{
"k": "klijent",
"e": "Klijent čeka na recepciji."
},
{
"k": "kod",
"e": "Unesite kod za vrata."
},
{
"k": "koja je lozinka",
"e": "Koja je lozinka za wifi?"
},
{
"k": "koji broj",
"e": "Koji broj cipela nosite?"
},
{
"k": "koji je danas dan",
"e": "Koji je danas dan, srijeda ili četvrtak?"
},
{
"k": "koliko godina imate",
"e": "Oprostite, koliko godina imate?"
},
{
"k": "koliko je sati",
"e": "Oprostite, koliko je sati?"
},
{
"k": "koliko je to",
"e": "Koliko je to ukupno?"
},
{
"k": "koliko košta noćenje",
"e": "Koliko košta noćenje s doručkom?"
},
{
"k": "koliko to košta",
"e": "Koliko to košta?"
},
{
"k": "kolovoz",
"e": "U kolovozu idemo na more."
},
{
"k": "komad",
"e": "Mogu li dobiti komad torte?"
},
{
"k": "kontejner",
"e": "Plastiku baci u žuti kontejner."
},
{
"k": "korisnik",
"e": "Korisnik je zaboravio lozinku."
},
{
"k": "korist",
"e": "Kakva je korist od toga?"
},
{
"k": "kotač",
"e": "Kotač na koferu je slomljen."
},
{
"k": "kovanica",
"e": "Za kolica u trgovini treba kovanica."
},
{
"k": "kočnica",
"e": "Kočnica na biciklu ne radi."
},
{
"k": "kultura",
"e": "Zanima me hrvatska kultura."
},
{
"k": "kusur",
"e": "Zaboravili ste kusur!"
},
{
"k": "kuća",
"e": "Moja kuća je blizu mora."
},
{
"k": "kvačilo",
"e": "Polako pusti kvačilo."
},
{
"k": "lagan",
"e": "Kofer je lagan, mogu ga sama nositi."
},
{
"k": "lajati",
"e": "Susjedov pas laje cijelu noć."
},
{
"k": "letjeti",
"e": "Ne volim letjeti avionom."
},
{
"k": "li",
"e": "Govorite li hrvatski?"
},
{
"k": "lijepo",
"e": "Kakvo lijepo more!"
},
{
"k": "liječenje",
"e": "Liječenje traje dva tjedna."
},
{
"k": "limun",
"e": "Stavi malo limuna u čaj."
},
{
"k": "lipanj",
"e": "Škola završava u lipnju."
},
{
"k": "listopad",
"e": "Rođena sam u listopadu."
},
{
"k": "ljubav",
"e": "Ovo je ljubav na prvi pogled."
},
{
"k": "lokalan",
"e": "Ovaj sir je lokalan proizvod s otoka."
},
{
"k": "lopov",
"e": "Lopov je ukrao bicikl ispred zgrade."
},
{
"k": "lopta",
"e": "Dječak baca loptu psu."
},
{
"k": "luka",
"e": "Trajekt stiže u luku u podne."
},
{
"k": "mama",
"e": "Mama, gdje su moje cipele?"
},
{
"k": "manje",
"e": "Pij manje kave!"
},
{
"k": "matematika",
"e": "Matematika mi je bila najteži predmet."
},
{
"k": "medalja",
"e": "Osvojila je zlatnu medalju."
},
{
"k": "medicina",
"e": "Moja sestra studira medicinu."
},
{
"k": "mehaničar",
"e": "Mehaničar je popravio auto."
},
{
"k": "meni je hladno",
"e": "Možeš zatvoriti prozor? Meni je hladno."
},
{
"k": "meni je vruće",
"e": "Meni je vruće, otvori prozor."
},
{
"k": "međunarodni",
"e": "Ovo je međunarodni aerodrom."
},
{
"k": "milijun",
"e": "Ovaj stan košta pola milijuna eura."
},
{
"k": "mišljenje",
"e": "Kakvo je tvoje mišljenje?"
},
{
"k": "mjesto",
"e": "Je li ovo mjesto slobodno?"
},
{
"k": "mobilno bankarstvo",
"e": "Račune plaćam preko mobilnog bankarstva."
},
{
"k": "mogu li platiti karticom",
"e": "Dobar dan, mogu li platiti karticom?"
},
{
"k": "mogu li probati",
"e": "Ova haljina je lijepa, mogu li probati?"
},
{
"k": "moguć",
"e": "Je li moguć popust?"
},
{
"k": "molim račun",
"e": "Konobaru, molim račun!"
},
{
"k": "molim te",
"e": "Molim te, zatvori vrata."
},
{
"k": "molim vas",
"e": "Molim vas, gdje je stanica?"
},
{
"k": "molim vas jednu kavu",
"e": "Molim vas jednu kavu s mlijekom."
},
{
"k": "molim vas vode",
"e": "Molim vas vode, jako sam žedna."
},
{
"k": "moliti",
"e": "Moram vas moliti za pomoć."
},
{
"k": "motor",
"e": "Motor ne pali."
},
{
"k": "može",
"e": "Može, vidimo se u pet."
},
{
"k": "možete li mi pomoći",
"e": "Oprostite, možete li mi pomoći?"
},
{
"k": "možete li ponoviti",
"e": "Ne razumijem, možete li ponoviti?"
},
{
"k": "mreža",
"e": "Nema mreže, ne mogu nazvati."
},
{
"k": "muškarac",
"e": "Taj muškarac je moj šef."
},
{
"k": "nacionalan",
"e": "Ovo jelo je naš nacionalni ponos."
},
{
"k": "najmodavac",
"e": "Najmodavac traži polog od dvije stanarine."
},
{
"k": "napamet",
"e": "Naučila sam pjesmu napamet."
},
{
"k": "napisati",
"e": "Moram napisati mail šefu."
},
{
"k": "napraviti",
"e": "Što ćemo napraviti za večeru?"
},
{
"k": "naprijed",
"e": "Idite ravno naprijed."
},
{
"k": "naprimjer",
"e": "Volim voće, naprimjer jabuke i kruške."
},
{
"k": "naranča",
"e": "Za doručak pojedem jednu naranču."
},
{
"k": "narod",
"e": "Hrvati su gostoljubiv narod."
},
{
"k": "nastaviti",
"e": "Nastavite ravno do semafora."
},
{
"k": "natrag",
"e": "Vratit ću se natrag za sat vremena."
},
{
"k": "navečer",
"e": "Navečer volim šetati uz more."
},
{
"k": "navijač",
"e": "On je veliki navijač Hajduka."
},
{
"k": "ne govorim hrvatski",
"e": "Žao mi je, ne govorim hrvatski."
},
{
"k": "ne radi",
"e": "Lift ne radi, idemo stepenicama."
},
{
"k": "ne razumijem",
"e": "Ne razumijem, govorite polako, molim vas."
},
{
"k": "ne znam",
"e": "Ne znam gdje je pošta."
},
{
"k": "nedjelja",
"e": "U nedjelju su trgovine zatvorene."
},
{
"k": "nema problema",
"e": "Nema problema, pomoći ću ti."
},
{
"k": "nemam novca",
"e": "Ne mogu ići s vama, nemam novca."
},
{
"k": "nemam vremena",
"e": "Danas nemam vremena, žurim se."
},
{
"k": "nemati",
"e": "Teško je nemati posao."
},
{
"k": "nigdje",
"e": "Nigdje ne mogu naći ključeve."
},
{
"k": "nikada",
"e": "Nikada nisam bio u Dubrovniku."
},
{
"k": "nitko",
"e": "Nitko nije odgovorio."
},
{
"k": "njen",
"e": "Ovo je njen auto."
},
{
"k": "nos",
"e": "Curi mi nos."
},
{
"k": "novo",
"e": "Kupili smo novo računalo."
},
{
"k": "novčanica",
"e": "Imate li manju novčanicu?"
},
{
"k": "nula",
"e": "Vani je nula stupnjeva."
},
{
"k": "obiteljski liječnik",
"e": "Moj obiteljski liječnik radi do podne."
},
{
"k": "objaviti",
"e": "Fotografije ćemo objaviti sutra."
},
{
"k": "obrisati",
"e": "Obriši stol, molim te."
},
{
"k": "odabrati",
"e": "Odaberite jezik."
},
{
"k": "odakle",
"e": "Odakle si?"
},
{
"k": "odakle ste",
"e": "Odakle ste? Iz Ukrajine?"
},
{
"k": "odgovarati",
"e": "Ova veličina mi ne odgovara."
},
{
"k": "odjeća",
"e": "Odjeća je u ormaru."
},
{
"k": "odličan",
"e": "Ovo je odličan restoran."
},
{
"k": "odlično",
"e": "Odlično, vidimo se sutra!"
},
{
"k": "odmah",
"e": "Dolazim odmah!"
},
{
"k": "odmarati",
"e": "Vikendom odmaram kod kuće."
},
{
"k": "odmoriti se",
"e": "Trebam se malo odmoriti."
},
{
"k": "odnijeti",
"e": "Možete li odnijeti tanjure?"
},
{
"k": "ogrlica",
"e": "Ova ogrlica je poklon od mame."
},
{
"k": "oib",
"e": "Za ugovor trebate OIB."
},
{
"k": "okrenuti",
"e": "Okreni se, iza tebe je Daša!"
},
{
"k": "ona (pl)",
"e": "Djeca su vani, ona se igraju u dvorištu."
},
{
"k": "onaj",
"e": "Daj mi onaj crveni."
},
{
"k": "onda",
"e": "Prvo jedemo, onda idemo u šetnju."
},
{
"k": "one",
"e": "Gdje su djevojke? One su u kafiću."
},
{
"k": "opasno",
"e": "Ovdje je opasno plivati."
},
{
"k": "opet",
"e": "Opet kasniš!"
},
{
"k": "oprez",
"e": "Oprez, pod je mokar!"
},
{
"k": "oprezan",
"e": "Budi oprezan na cesti."
},
{
"k": "oprostite, gdje je",
"e": "Oprostite, gdje je glavni trg?"
},
{
"k": "osam",
"e": "Radim od osam do četiri."
},
{
"k": "osamdeset",
"e": "Baka ima osamdeset godina."
},
{
"k": "osamnaest",
"e": "Vozačku dozvolu možeš dobiti s osamnaest godina."
},
{
"k": "osmi",
"e": "Moj sin ide u osmi razred."
},
{
"k": "osoban",
"e": "To je jako osobno pitanje."
},
{
"k": "otići",
"e": "Moram otići u trgovinu."
},
{
"k": "otvoreno",
"e": "Je li otvoreno nedjeljom?"
},
{
"k": "ovaj",
"e": "Ide li ovaj autobus u centar?"
},
{
"k": "ovdje je moj pasoš",
"e": "Ovdje je moj pasoš, izvolite."
},
{
"k": "očekivati",
"e": "Očekujem paket danas."
},
{
"k": "ožujak",
"e": "U ožujku je već toplije."
},
{
"k": "pa",
"e": "Bio sam umoran, pa sam ostao kod kuće."
},
{
"k": "pad",
"e": "Zbog pada sustava nismo mogli raditi."
},
{
"k": "padati",
"e": "Vani pada kiša."
},
{
"k": "pamtiti",
"e": "Ne pamtim dobro imena."
},
{
"k": "papar",
"e": "Dodaj sol i papar."
},
{
"k": "papuče",
"e": "Gdje su moje papuče?"
},
{
"k": "parking",
"e": "Parking je iza hotela."
},
{
"k": "pasta",
"e": "Trebam pastu za zube."
},
{
"k": "pasti",
"e": "Pazi, možeš pasti!"
},
{
"k": "pazi",
"e": "Pazi, auto!"
},
{
"k": "pažnja",
"e": "Hvala na pažnji."
},
{
"k": "pedeset",
"e": "Ova jakna košta pedeset eura."
},
{
"k": "pet",
"e": "Vidimo se u pet."
},
{
"k": "petak",
"e": "U petak idemo u kino."
},
{
"k": "peti",
"e": "Danas je peti dan tečaja."
},
{
"k": "petnaest",
"e": "Autobus dolazi za petnaest minuta."
},
{
"k": "petsto",
"e": "Najam stana je petsto eura mjesečno."
},
{
"k": "piletina",
"e": "Za ručak imamo piletinu s rižom."
},
{
"k": "pivo točeno",
"e": "Imate li pivo točeno?"
},
{
"k": "piće",
"e": "Što želite za piće?"
},
{
"k": "pjevati",
"e": "Volim pjevati pod tušem."
},
{
"k": "pješice",
"e": "Idemo pješice, blizu je."
},
{
"k": "plakati",
"e": "Dijete plače jer je gladno."
},
{
"k": "plan",
"e": "Kakav je plan za vikend?"
},
{
"k": "plavi",
"e": "Kupila sam plavi džemper."
},
{
"k": "plavo",
"e": "More je danas jako plavo."
},
{
"k": "plesati",
"e": "Idemo plesati u subotu!"
},
{
"k": "po noći",
"e": "Po noći je ovdje jako tiho."
},
{
"k": "pogledati",
"e": "Možeš li pogledati moj mail?"
},
{
"k": "pokazati",
"e": "Možete li mi pokazati put do stanice?"
},
{
"k": "pokvareno",
"e": "Meso je pokvareno, nemoj ga jesti."
},
{
"k": "polako",
"e": "Govorite polako, molim vas."
},
{
"k": "police",
"e": "Police u kuhinji su pune."
},
{
"k": "političar",
"e": "Taj političar često je na televiziji."
},
{
"k": "poljubac",
"e": "Daj mi poljubac!"
},
{
"k": "pomirenje",
"e": "Nakon svađe došlo je do pomirenja."
},
{
"k": "ponedjeljak",
"e": "U ponedjeljak počinjem novi posao."
},
{
"k": "ponos",
"e": "Ti si naš ponos!"
},
{
"k": "ponovno",
"e": "Molim vas, pokušajte ponovno."
},
{
"k": "popodne",
"e": "Popodne idemo na plažu."
},
{
"k": "popravak",
"e": "Popravak auta trajat će tri dana."
},
{
"k": "posjetitelj",
"e": "Muzej svaki dan ima puno posjetitelja."
},
{
"k": "posljednji",
"e": "Ovo je posljednji autobus večeras."
},
{
"k": "poslovna kartica",
"e": "Troškove puta plaćam poslovnom karticom."
},
{
"k": "poslužitelj",
"e": "Poslužitelj ne radi, stranica se ne otvara."
},
{
"k": "postavke",
"e": "Promijeni jezik u postavkama."
},
{
"k": "posuđe",
"e": "Ja ću oprati posuđe."
},
{
"k": "povodac",
"e": "Pas mora biti na povocu."
},
{
"k": "početi",
"e": "Film će početi za pet minuta."
},
{
"k": "pratiti",
"e": "Pratite znakove za izlaz."
},
{
"k": "prazna mi je baterija",
"e": "Ne mogu te nazvati, prazna mi je baterija."
},
{
"k": "prekjučer",
"e": "Prekjučer sam bila kod liječnika."
},
{
"k": "prekosutra",
"e": "Vraćam se prekosutra."
},
{
"k": "preporučiti",
"e": "Možete li nam preporučiti dobar restoran?"
},
{
"k": "prije",
"e": "Prije jela operi ruke."
},
{
"k": "prijelaz",
"e": "Prijeđite cestu na pješačkom prijelazu."
},
{
"k": "prijevod",
"e": "Trebam službeni prijevod dokumenta."
},
{
"k": "prijevoz",
"e": "Javni prijevoz u Zagrebu je dobar."
},
{
"k": "prirodan",
"e": "Ovaj sok je potpuno prirodan."
},
{
"k": "pristup",
"e": "Nemam pristup internetu."
},
{
"k": "priča",
"e": "To je duga priča."
},
{
"k": "prljavo",
"e": "Nakon zabave sve je bilo prljavo."
},
{
"k": "procjena",
"e": "Procjena za ovaj zadatak je dva dana."
},
{
"k": "prometna dozvola",
"e": "Policajac je tražio vozačku i prometnu dozvolu."
},
{
"k": "pronaći",
"e": "Ne mogu pronaći ključeve."
},
{
"k": "prosinac",
"e": "U prosincu slavimo Božić."
},
{
"k": "prtljažnik",
"e": "Stavi kofere u prtljažnik."
},
{
"k": "prvi",
"e": "Ovo mi je prvi put u Hrvatskoj."
},
{
"k": "pumpa",
"e": "Moramo stati na pumpi, nemamo goriva."
},
{
"k": "put",
"e": "Sretan put!"
},
{
"k": "rad",
"e": "Rad od kuće mi odgovara."
},
{
"k": "radio",
"e": "Upali radio, molim te."
},
{
"k": "razgovarati",
"e": "Moramo razgovarati."
},
{
"k": "recepcija",
"e": "Ključ ostavite na recepciji."
},
{
"k": "red",
"e": "Stani u red, molim te."
},
{
"k": "rep",
"e": "Pas maše repom."
},
{
"k": "riječ",
"e": "Kako se izgovara ova riječ?"
},
{
"k": "rok",
"e": "Rok za predaju je petak."
},
{
"k": "rođak",
"e": "Moj rođak živi u Zadru."
},
{
"k": "rođendan",
"e": "Sretan rođendan!"
},
{
"k": "rub",
"e": "Ne stoj na rubu, opasno je."
},
{
"k": "rujan",
"e": "Škola počinje u rujnu."
},
{
"k": "ručnik",
"e": "Trebam još jedan ručnik, molim."
},
{
"k": "ružno",
"e": "Vrijeme je danas ružno."
},
{
"k": "s mlijekom",
"e": "Kavu pijem s mlijekom."
},
{
"k": "samo gledam",
"e": "Hvala, samo gledam."
},
{
"k": "sapun",
"e": "U kupaonici nema sapuna."
},
{
"k": "sav",
"e": "Pojeo je sav kruh."
},
{
"k": "se",
"e": "Kako se zoveš?"
},
{
"k": "sedam",
"e": "Ustajem u sedam."
},
{
"k": "sedamdeset",
"e": "Djed ima sedamdeset godina."
},
{
"k": "sedamnaest",
"e": "Sestra ima sedamnaest godina."
},
{
"k": "sedmi",
"e": "Živimo na sedmom katu."
},
{
"k": "signal",
"e": "Ovdje nema signala."
},
{
"k": "siječanj",
"e": "U siječnju je jako hladno."
},
{
"k": "sila",
"e": "Za ovo treba puno sile."
},
{
"k": "simptom",
"e": "Koji su simptomi gripe?"
},
{
"k": "siromašan",
"e": "Bio je siromašan, ali sretan."
},
{
"k": "sirup",
"e": "Liječnik mi je prepisao sirup za kašalj."
},
{
"k": "sitniš",
"e": "Imate li sitniša?"
},
{
"k": "siv",
"e": "Grad je danas siv i kišovit."
},
{
"k": "sivi",
"e": "Uzmi sivi kaput, vani je hladno."
},
{
"k": "sivo",
"e": "Nebo je danas sivo."
},
{
"k": "sjediti",
"e": "Mogu li sjediti ovdje?"
},
{
"k": "sjetiti se",
"e": "Ne mogu se sjetiti njegova imena."
},
{
"k": "skaliranje",
"e": "Skaliranje sustava planiramo za idući mjesec."
},
{
"k": "skupo",
"e": "U ovom restoranu je skupo."
},
{
"k": "slab",
"e": "Signal je ovdje slab."
},
{
"k": "slano",
"e": "Ovo jelo je jako slano."
},
{
"k": "slatko",
"e": "Volim nešto slatko nakon ručka."
},
{
"k": "slaviti",
"e": "Kako slavite Božić u Ukrajini?"
},
{
"k": "slikar",
"e": "Moj djed je bio slikar."
},
{
"k": "slovo",
"e": "Kako se piše ovo slovo?"
},
{
"k": "smeće",
"e": "Iznesi smeće, molim te."
},
{
"k": "smeđe",
"e": "Ona ima smeđe oči."
},
{
"k": "smeđi",
"e": "Kupio sam smeđi remen."
},
{
"k": "smijati se",
"e": "Zašto se smiješ?"
},
{
"k": "smjer",
"e": "U kojem smjeru je centar?"
},
{
"k": "spasiti",
"e": "Liječnici su mu spasili život."
},
{
"k": "sportski",
"e": "Gledamo sportski program."
},
{
"k": "sredina",
"e": "Stan je u samoj sredini grada."
},
{
"k": "sretan božić",
"e": "Sretan Božić i sretna Nova godina!"
},
{
"k": "sretna nova godina",
"e": "Sretna Nova godina svima!"
},
{
"k": "srijeda",
"e": "U srijedu imam tečaj hrvatskog."
},
{
"k": "srpanj",
"e": "U srpnju je jako vruće."
},
{
"k": "stajati",
"e": "Koliko stoji ova jakna?"
},
{
"k": "staklo",
"e": "Pazi, na podu je razbijeno staklo."
},
{
"k": "stani",
"e": "Stani, crveno je!"
},
{
"k": "stanovnik",
"e": "Svaki stanovnik zgrade ima svoj ključ."
},
{
"k": "staro",
"e": "Ovo je jako staro selo."
},
{
"k": "stati",
"e": "Možete li stati ovdje?"
},
{
"k": "sto",
"e": "Do mora ima sto metara."
},
{
"k": "struja",
"e": "Nema struje u cijeloj zgradi."
},
{
"k": "stručan",
"e": "Trebamo stručan savjet."
},
{
"k": "studeni",
"e": "U studenom često pada kiša."
},
{
"k": "stvar",
"e": "Imam još jednu stvar za tebe."
},
{
"k": "subota",
"e": "U subotu idemo na tržnicu."
},
{
"k": "super",
"e": "Super, vidimo se sutra!"
},
{
"k": "supermarket",
"e": "Supermarket je otvoren do devet."
},
{
"k": "suprug",
"e": "Ovo je moj suprug Ivan."
},
{
"k": "supruga",
"e": "Moja supruga radi u bolnici."
},
{
"k": "susresti",
"e": "Jučer sam susreo starog prijatelja."
},
{
"k": "sustav",
"e": "Sustav je trenutno nedostupan."
},
{
"k": "svaki dan",
"e": "Svaki dan učim nove riječi."
},
{
"k": "sve je u redu",
"e": "Ne brini, sve je u redu."
},
{
"k": "svejedno",
"e": "Meni je svejedno, odaberi ti."
},
{
"k": "svibanj",
"e": "U svibnju je sve zeleno."
},
{
"k": "svijet",
"e": "Želim putovati po svijetu."
},
{
"k": "svinjetina",
"e": "Ne jedem svinjetinu."
},
{
"k": "sviđati se",
"e": "Sviđa mi se ovaj grad."
},
{
"k": "svjetlo",
"e": "Ugasi svjetlo, molim te."
},
{
"k": "svježe",
"e": "Ovo voće je svježe."
},
{
"k": "svoj",
"e": "Svatko plaća svoj račun."
},
{
"k": "taj",
"e": "Taj film je dosadan."
},
{
"k": "tako",
"e": "Nemoj tako brzo voziti!"
},
{
"k": "također",
"e": "Ja također volim more."
},
{
"k": "tek",
"e": "Tek sam stigla."
},
{
"k": "tekst",
"e": "Pročitajte tekst i odgovorite na pitanja."
},
{
"k": "tema",
"e": "Koja je tema današnjeg sata?"
},
{
"k": "teren",
"e": "Igrači izlaze na teren."
},
{
"k": "terminal",
"e": "Autobus vozi do putničkog terminala."
},
{
"k": "testirati",
"e": "Moramo testirati novu aplikaciju."
},
{
"k": "ticati",
"e": "To se tebe ne tiče!"
},
{
"k": "tijelo",
"e": "Boli me cijelo tijelo."
},
{
"k": "tim",
"e": "Naš tim radi od kuće."
},
{
"k": "tisuću",
"e": "Ovaj telefon košta tisuću eura."
},
{
"k": "tko je to",
"e": "Tko je to na vratima?"
},
{
"k": "toaletni papir",
"e": "U kupaonici nema toaletnog papira."
},
{
"k": "toplo",
"e": "More je danas toplo."
},
{
"k": "torbica",
"e": "Zaboravila sam torbicu u taksiju."
},
{
"k": "točno",
"e": "Točno, to je pravi odgovor!"
},
{
"k": "tramvaj",
"e": "Tramvaj broj šest vozi do kolodvora."
},
{
"k": "traperice",
"e": "Ove traperice su mi preuske."
},
{
"k": "travanj",
"e": "U travnju često pada kiša."
},
{
"k": "trebam doktora",
"e": "Trebam doktora, jako me boli trbuh."
},
{
"k": "trebam policiju",
"e": "Trebam policiju, ukrali su mi novčanik."
},
{
"k": "trebam pomoć",
"e": "Oprostite, trebam pomoć."
},
{
"k": "trebam promijeniti novac",
"e": "Trebam promijeniti novac, gdje je mjenjačnica?"
},
{
"k": "trebam punjač",
"e": "Trebam punjač za mobitel."
},
{
"k": "trebam sobu",
"e": "Trebam sobu za dvije osobe."
},
{
"k": "trebam taksi",
"e": "Trebam taksi do aerodroma."
},
{
"k": "trebam vrećicu",
"e": "Trebam vrećicu, molim vas."
},
{
"k": "trener",
"e": "Trener je zadovoljan našom igrom."
},
{
"k": "trening",
"e": "Trening počinje u šest."
},
{
"k": "treći",
"e": "Ovo je treći put da kasniš!"
},
{
"k": "trgovac",
"e": "Trgovac mi je dao popust."
},
{
"k": "tri",
"e": "Imam tri brata."
},
{
"k": "trideset",
"e": "Ovdje čekamo već trideset minuta."
},
{
"k": "trideset pet",
"e": "Imam trideset pet godina."
},
{
"k": "trinaest",
"e": "Kći ima trinaest godina."
},
{
"k": "tristo",
"e": "Let do Dubrovnika košta tristo eura."
},
{
"k": "tuga",
"e": "U očima joj se vidjela tuga."
},
{
"k": "tuš",
"e": "Tuš u kupaonici ne radi."
},
{
"k": "u principu",
"e": "U principu se slažem s tobom."
},
{
"k": "ugodan dan",
"e": "Hvala i ugodan dan!"
},
{
"k": "uhvatiti",
"e": "Moram uhvatiti zadnji autobus."
},
{
"k": "ujutro",
"e": "Ujutro pijem kavu."
},
{
"k": "ukrali su mi torbu",
"e": "Upomoć, ukrali su mi torbu!"
},
{
"k": "ukusno",
"e": "Ovo je jako ukusno!"
},
{
"k": "ulje u mjenjaču",
"e": "Mehaničar je promijenio ulje u mjenjaču."
},
{
"k": "umoran sam",
"e": "Umoran sam, idem kući."
},
{
"k": "umorna sam",
"e": "Umorna sam nakon posla."
},
{
"k": "upaliti",
"e": "Upali svjetlo, mrak je."
},
{
"k": "uskoro",
"e": "Uskoro dolazimo."
},
{
"k": "usta",
"e": "Otvorite usta, molim."
},
{
"k": "utorak",
"e": "U utorak imam sastanak."
},
{
"k": "uvjet",
"e": "Koji su uvjeti za dobivanje vize?"
},
{
"k": "uzica",
"e": "Drži psa na uzici."
},
{
"k": "uzrok",
"e": "Uzrok kvara još nije poznat."
},
{
"k": "ući",
"e": "Mogu li ući?"
},
{
"k": "učim hrvatski",
"e": "Učim hrvatski već tri mjeseca."
},
{
"k": "učiniti",
"e": "Što mogu učiniti za vas?"
},
{
"k": "veliko",
"e": "Imaju veliko dvorište."
},
{
"k": "veljača",
"e": "U veljači je karneval."
},
{
"k": "veterinar",
"e": "Moramo odvesti mačku veterinaru."
},
{
"k": "veza",
"e": "Internetska veza je spora."
},
{
"k": "već",
"e": "Već sam jela, hvala."
},
{
"k": "viza",
"e": "Trebam li vizu za Hrvatsku?"
},
{
"k": "više",
"e": "Trebam više vremena."
},
{
"k": "vlastit",
"e": "Svaka soba ima vlastitu kupaonicu."
},
{
"k": "voda bez plina",
"e": "Molim vas jednu vodu bez plina."
},
{
"k": "voda s plinom",
"e": "Želite li vodu s plinom ili bez plina?"
},
{
"k": "vodič",
"e": "Vodič nam je pokazao stari grad."
},
{
"k": "volan",
"e": "Sjedni za volan, ti voziš."
},
{
"k": "vrsta",
"e": "Koja vrsta kruha vam treba?"
},
{
"k": "vruć",
"e": "Pazi, čaj je vruć!"
},
{
"k": "vruće",
"e": "Danas je jako vruće."
},
{
"k": "zadatak",
"e": "Domaći zadatak je na stranici deset."
},
{
"k": "zadržati",
"e": "Zadržite kopiju računa."
},
{
"k": "zadržite kusur",
"e": "Hvala, zadržite kusur."
},
{
"k": "zahod",
"e": "Zahod je na kraju hodnika."
},
{
"k": "zajedno",
"e": "Idemo zajedno na kavu?"
},
{
"k": "započeti",
"e": "Sastanak ćemo započeti u devet."
},
{
"k": "zapravo",
"e": "Zapravo, nisam gladan."
},
{
"k": "zaraditi",
"e": "Ljeti mogu zaraditi više novca."
},
{
"k": "zastoj",
"e": "Imamo zastoj, čekamo odgovor drugog tima."
},
{
"k": "zatvoreno",
"e": "Nedjeljom je zatvoreno."
},
{
"k": "završiti",
"e": "Kad završiš posao?"
},
{
"k": "zeleni",
"e": "Volim zeleni čaj."
},
{
"k": "zeleno",
"e": "U proljeće je sve zeleno."
},
{
"k": "zemlja",
"e": "Iz koje zemlje dolazite?"
},
{
"k": "znati",
"e": "Želim znati više o Hrvatskoj."
},
{
"k": "zovem se",
"e": "Zovem se Daša, a ti?"
},
{
"k": "zovi policiju",
"e": "Zovi policiju, brzo!"
},
{
"k": "zovite hitnu",
"e": "Zovite hitnu, čovjeku je loše!"
},
{
"k": "zovite policiju",
"e": "Zovite policiju, netko je provalio u stan!"
},
{
"k": "zvono",
"e": "Zvono na vratima ne radi."
},
{
"k": "zvuk",
"e": "Utišaj zvuk, molim te."
},
{
"k": "čaj s limunom",
"e": "Molim vas jedan čaj s limunom."
},
{
"k": "čak",
"e": "Čak i djeca to znaju."
},
{
"k": "čašu vode",
"e": "Mogu li dobiti čašu vode?"
},
{
"k": "čekaj",
"e": "Čekaj, nisam još gotova!"
},
{
"k": "četiri",
"e": "Naš stan ima četiri sobe."
},
{
"k": "četkica",
"e": "Zaboravila sam četkicu za zube."
},
{
"k": "četrdeset",
"e": "Karta za koncert košta četrdeset eura."
},
{
"k": "četrnaest",
"e": "Moja kći ima četrnaest godina."
},
{
"k": "četvrtak",
"e": "Vidimo se u četvrtak navečer."
},
{
"k": "četvrti",
"e": "Živim na četvrtom katu."
},
{
"k": "čiji",
"e": "Čiji je ovo mobitel?"
},
{
"k": "činiti",
"e": "Čini mi se da će padati kiša."
},
{
"k": "čisto",
"e": "Nakon čišćenja sve je čisto i uredno."
},
{
"k": "čistoća",
"e": "U hotelu je čistoća na prvom mjestu."
},
{
"k": "čujemo se",
"e": "Hvala na pozivu, čujemo se sutra!"
},
{
"k": "šampon",
"e": "Trebam šampon za suhu kosu."
},
{
"k": "šapa",
"e": "Pas je ozlijedio šapu."
},
{
"k": "šesnaest",
"e": "Ovo je soba broj šesnaest."
},
{
"k": "šest",
"e": "Večera je u šest."
},
{
"k": "šesti",
"e": "Ovo je već šesti put da te zovem!"
},
{
"k": "šezdeset",
"e": "Moja mama ima šezdeset godina."
},
{
"k": "što je ovo",
"e": "Oprostite, što je ovo na jelovniku?"
},
{
"k": "žao mi je",
"e": "Žao mi je, ne mogu doći."
},
{
"k": "žedan sam",
"e": "Žedan sam, možeš li mi dati vode?"
},
{
"k": "žedna sam",
"e": "Žedna sam, idemo po vodu."
},
{
"k": "želim platiti",
"e": "Želim platiti, molim vas."
},
{
"k": "želja",
"e": "Moja najveća želja je putovati."
},
{
"k": "željeti",
"e": "Što biste željeli popiti?"
},
{
"k": "žiro račun",
"e": "Plaća mi stiže na žiro račun."
},
{
"k": "život",
"e": "Život na moru je lijep."
},
{
"k": "životinja",
"e": "Koja je tvoja omiljena životinja?"
},
{
"k": "žurim se",
"e": "Oprostite, žurim se."
},
{
"k": "žuti",
"e": "Kupila sam žuti kišobran."
},
{
"k": "žuto",
"e": "Svjetlo na semaforu je žuto."
}
]'::jsonb) as t(k text, e text)
  loop
    select * into r from public.lexemes
     where lower(lemma) = d.k and status <> 'DEPRECATED';
    if not found then
      v_missing := v_missing || d.k || '; ';
      continue;
    end if;
    if coalesce(r.examples, '[]'::jsonb) <> '[]'::jsonb then
      continue;
    end if;
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', r.id,
            coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
            to_jsonb(r), 'lexemes_examples_20261021_a0_a1: додано приклад — стара версія');
    update public.lexemes set examples = jsonb_build_array(d.e), version = coalesce(version, 1) + 1 where id = r.id;
    insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
    values ('lexeme', r.id, r.status, r.status, 'auto_passed', 'ai', '[]'::jsonb, 'Приклад додано 2026-10-21 (A0 / A1; scripts/lexemes_examples_data.py). Бета, як уроки A0 / A1 (рішення власника 2026-10-12): носій перевіряє після публікації. Потрібна перевірка носієм: content/reviews/2026-10-21_lexemes_examples.md.');
    v_changed := v_changed + 1;
  end loop;
  if v_missing <> '' then raise notice 'Немає в словнику (пропущено): %', v_missing; end if;
  raise notice 'Додано прикладів зараз: %', v_changed;
end
$fix$;

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_empty int; v_done int;
begin
  select count(*) into v_empty from public.lexemes l
   where l.status <> 'DEPRECATED' and l.examples = '[]'::jsonb
     and lower(l.lemma) in (select t.k from jsonb_to_recordset('[{"k": "aerodrom"}, {"k": "ambulanta"}, {"k": "aplikacija"}, {"k": "arhitektura"}, {"k": "australski ovčar"}, {"k": "automobil"}, {"k": "autor"}, {"k": "benzin"}, {"k": "bez šećera"}, {"k": "bi"}, {"k": "bicikl"}, {"k": "bijeli"}, {"k": "bijelo"}, {"k": "biljka"}, {"k": "bježati"}, {"k": "bogat"}, {"k": "boja"}, {"k": "bok"}, {"k": "brinuti se"}, {"k": "brod"}, {"k": "brojka"}, {"k": "buditi se"}, {"k": "budućnost"}, {"k": "buka"}, {"k": "cijeniti"}, {"k": "cilj"}, {"k": "cjepivo"}, {"k": "crni"}, {"k": "crno"}, {"k": "crtati"}, {"k": "crveni"}, {"k": "crveno"}, {"k": "deset"}, {"k": "deseti"}, {"k": "devedeset"}, {"k": "devet"}, {"k": "deveti"}, {"k": "devetnaest"}, {"k": "devizni račun"}, {"k": "dijalog"}, {"k": "dizel"}, {"k": "dizne"}, {"k": "djevojka"}, {"k": "djevojčica"}, {"k": "dječak"}, {"k": "dlaka"}, {"k": "dnevni"}, {"k": "dnevni sastanak"}, {"k": "dobitak"}, {"k": "dobro"}, {"k": "dobro došli"}, {"k": "dobro jutro svima"}, {"k": "dobrodošli"}, {"k": "dodatan"}, {"k": "dodati"}, {"k": "događaj"}, {"k": "dok"}, {"k": "dolaziti"}, {"k": "dolje"}, {"k": "donijeti"}, {"k": "donositi"}, {"k": "dozvola za boravak"}, {"k": "dozvoliti"}, {"k": "drag"}, {"k": "drago"}, {"k": "drago mi je"}, {"k": "drugi"}, {"k": "držati"}, {"k": "dva"}, {"k": "dvadeset"}, {"k": "dvadeset dva"}, {"k": "dvadeset jedan"}, {"k": "dvanaest"}, {"k": "dvjesto"}, {"k": "elektronika"}, {"k": "gdje je apoteka"}, {"k": "gdje je autobusni kolodvor"}, {"k": "gdje je banka"}, {"k": "gdje je bankomat"}, {"k": "gdje je blagajna"}, {"k": "gdje je izlaz"}, {"k": "gdje je kabina"}, {"k": "gdje je ljekarna"}, {"k": "gdje je ulaz"}, {"k": "gdje je wc"}, {"k": "gdje je zahod"}, {"k": "gdje je željeznički kolodvor"}, {"k": "gdje mogu kupiti kartu"}, {"k": "gladan sam"}, {"k": "gladna sam"}, {"k": "glas"}, {"k": "gore"}, {"k": "gospodin"}, {"k": "gospođa"}, {"k": "govedina"}, {"k": "govorite li engleski"}, {"k": "govoriti tiho"}, {"k": "graditi"}, {"k": "gramatika"}, {"k": "greška"}, {"k": "grijanje"}, {"k": "grupa"}, {"k": "guma"}, {"k": "higijena"}, {"k": "hladno"}, {"k": "hrana za pse"}, {"k": "idemo"}, {"k": "igra"}, {"k": "igrati se"}, {"k": "igrač"}, {"k": "imam rezervaciju"}, {"k": "imate li sitno"}, {"k": "imate li slobodnu sobu"}, {"k": "imate li wifi"}, {"k": "iskaznica"}, {"k": "iskreno"}, {"k": "isporuka"}, {"k": "ispričavam se"}, {"k": "isti"}, {"k": "izbor"}, {"k": "izgubila sam se"}, {"k": "izgubio sam se"}, {"k": "iznenađenje"}, {"k": "iznositi"}, {"k": "izvoli"}, {"k": "izvolite"}, {"k": "ja bih vodu"}, {"k": "ja sam gladan"}, {"k": "ja sam iz ukrajine"}, {"k": "ja sam umoran"}, {"k": "ja sam žedan"}, {"k": "jahta"}, {"k": "jak"}, {"k": "javan"}, {"k": "jedan"}, {"k": "jedan smjer"}, {"k": "jedanaest"}, {"k": "jeftino"}, {"k": "jelo"}, {"k": "jelovnik"}, {"k": "još"}, {"k": "kajati"}, {"k": "kako da dođem do"}, {"k": "kako se kaže"}, {"k": "kako se zovete"}, {"k": "kako se zoveš"}, {"k": "kamo"}, {"k": "kamo idete"}, {"k": "kanta"}, {"k": "kao"}, {"k": "karta u jednom smjeru"}, {"k": "karta za zagreb"}, {"k": "karta, molim"}, {"k": "karticom ili gotovinom"}, {"k": "kasnije"}, {"k": "kasniti"}, {"k": "kazati"}, {"k": "klijent"}, {"k": "kod"}, {"k": "koja je lozinka"}, {"k": "koji broj"}, {"k": "koji je danas dan"}, {"k": "koliko godina imate"}, {"k": "koliko je sati"}, {"k": "koliko je to"}, {"k": "koliko košta noćenje"}, {"k": "koliko to košta"}, {"k": "kolovoz"}, {"k": "komad"}, {"k": "kontejner"}, {"k": "korisnik"}, {"k": "korist"}, {"k": "kotač"}, {"k": "kovanica"}, {"k": "kočnica"}, {"k": "kultura"}, {"k": "kusur"}, {"k": "kuća"}, {"k": "kvačilo"}, {"k": "lagan"}, {"k": "lajati"}, {"k": "letjeti"}, {"k": "li"}, {"k": "lijepo"}, {"k": "liječenje"}, {"k": "limun"}, {"k": "lipanj"}, {"k": "listopad"}, {"k": "ljubav"}, {"k": "lokalan"}, {"k": "lopov"}, {"k": "lopta"}, {"k": "luka"}, {"k": "mama"}, {"k": "manje"}, {"k": "matematika"}, {"k": "medalja"}, {"k": "medicina"}, {"k": "mehaničar"}, {"k": "meni je hladno"}, {"k": "meni je vruće"}, {"k": "međunarodni"}, {"k": "milijun"}, {"k": "mišljenje"}, {"k": "mjesto"}, {"k": "mobilno bankarstvo"}, {"k": "mogu li platiti karticom"}, {"k": "mogu li probati"}, {"k": "moguć"}, {"k": "molim račun"}, {"k": "molim te"}, {"k": "molim vas"}, {"k": "molim vas jednu kavu"}, {"k": "molim vas vode"}, {"k": "moliti"}, {"k": "motor"}, {"k": "može"}, {"k": "možete li mi pomoći"}, {"k": "možete li ponoviti"}, {"k": "mreža"}, {"k": "muškarac"}, {"k": "nacionalan"}, {"k": "najmodavac"}, {"k": "napamet"}, {"k": "napisati"}, {"k": "napraviti"}, {"k": "naprijed"}, {"k": "naprimjer"}, {"k": "naranča"}, {"k": "narod"}, {"k": "nastaviti"}, {"k": "natrag"}, {"k": "navečer"}, {"k": "navijač"}, {"k": "ne govorim hrvatski"}, {"k": "ne radi"}, {"k": "ne razumijem"}, {"k": "ne znam"}, {"k": "nedjelja"}, {"k": "nema problema"}, {"k": "nemam novca"}, {"k": "nemam vremena"}, {"k": "nemati"}, {"k": "nigdje"}, {"k": "nikada"}, {"k": "nitko"}, {"k": "njen"}, {"k": "nos"}, {"k": "novo"}, {"k": "novčanica"}, {"k": "nula"}, {"k": "obiteljski liječnik"}, {"k": "objaviti"}, {"k": "obrisati"}, {"k": "odabrati"}, {"k": "odakle"}, {"k": "odakle ste"}, {"k": "odgovarati"}, {"k": "odjeća"}, {"k": "odličan"}, {"k": "odlično"}, {"k": "odmah"}, {"k": "odmarati"}, {"k": "odmoriti se"}, {"k": "odnijeti"}, {"k": "ogrlica"}, {"k": "oib"}, {"k": "okrenuti"}, {"k": "ona (pl)"}, {"k": "onaj"}, {"k": "onda"}, {"k": "one"}, {"k": "opasno"}, {"k": "opet"}, {"k": "oprez"}, {"k": "oprezan"}, {"k": "oprostite, gdje je"}, {"k": "osam"}, {"k": "osamdeset"}, {"k": "osamnaest"}, {"k": "osmi"}, {"k": "osoban"}, {"k": "otići"}, {"k": "otvoreno"}, {"k": "ovaj"}, {"k": "ovdje je moj pasoš"}, {"k": "očekivati"}, {"k": "ožujak"}, {"k": "pa"}, {"k": "pad"}, {"k": "padati"}, {"k": "pamtiti"}, {"k": "papar"}, {"k": "papuče"}, {"k": "parking"}, {"k": "pasta"}, {"k": "pasti"}, {"k": "pazi"}, {"k": "pažnja"}, {"k": "pedeset"}, {"k": "pet"}, {"k": "petak"}, {"k": "peti"}, {"k": "petnaest"}, {"k": "petsto"}, {"k": "piletina"}, {"k": "pivo točeno"}, {"k": "piće"}, {"k": "pjevati"}, {"k": "pješice"}, {"k": "plakati"}, {"k": "plan"}, {"k": "plavi"}, {"k": "plavo"}, {"k": "plesati"}, {"k": "po noći"}, {"k": "pogledati"}, {"k": "pokazati"}, {"k": "pokvareno"}, {"k": "polako"}, {"k": "police"}, {"k": "političar"}, {"k": "poljubac"}, {"k": "pomirenje"}, {"k": "ponedjeljak"}, {"k": "ponos"}, {"k": "ponovno"}, {"k": "popodne"}, {"k": "popravak"}, {"k": "posjetitelj"}, {"k": "posljednji"}, {"k": "poslovna kartica"}, {"k": "poslužitelj"}, {"k": "postavke"}, {"k": "posuđe"}, {"k": "povodac"}, {"k": "početi"}, {"k": "pratiti"}, {"k": "prazna mi je baterija"}, {"k": "prekjučer"}, {"k": "prekosutra"}, {"k": "preporučiti"}, {"k": "prije"}, {"k": "prijelaz"}, {"k": "prijevod"}, {"k": "prijevoz"}, {"k": "prirodan"}, {"k": "pristup"}, {"k": "priča"}, {"k": "prljavo"}, {"k": "procjena"}, {"k": "prometna dozvola"}, {"k": "pronaći"}, {"k": "prosinac"}, {"k": "prtljažnik"}, {"k": "prvi"}, {"k": "pumpa"}, {"k": "put"}, {"k": "rad"}, {"k": "radio"}, {"k": "razgovarati"}, {"k": "recepcija"}, {"k": "red"}, {"k": "rep"}, {"k": "riječ"}, {"k": "rok"}, {"k": "rođak"}, {"k": "rođendan"}, {"k": "rub"}, {"k": "rujan"}, {"k": "ručnik"}, {"k": "ružno"}, {"k": "s mlijekom"}, {"k": "samo gledam"}, {"k": "sapun"}, {"k": "sav"}, {"k": "se"}, {"k": "sedam"}, {"k": "sedamdeset"}, {"k": "sedamnaest"}, {"k": "sedmi"}, {"k": "signal"}, {"k": "siječanj"}, {"k": "sila"}, {"k": "simptom"}, {"k": "siromašan"}, {"k": "sirup"}, {"k": "sitniš"}, {"k": "siv"}, {"k": "sivi"}, {"k": "sivo"}, {"k": "sjediti"}, {"k": "sjetiti se"}, {"k": "skaliranje"}, {"k": "skupo"}, {"k": "slab"}, {"k": "slano"}, {"k": "slatko"}, {"k": "slaviti"}, {"k": "slikar"}, {"k": "slovo"}, {"k": "smeće"}, {"k": "smeđe"}, {"k": "smeđi"}, {"k": "smijati se"}, {"k": "smjer"}, {"k": "spasiti"}, {"k": "sportski"}, {"k": "sredina"}, {"k": "sretan božić"}, {"k": "sretna nova godina"}, {"k": "srijeda"}, {"k": "srpanj"}, {"k": "stajati"}, {"k": "staklo"}, {"k": "stani"}, {"k": "stanovnik"}, {"k": "staro"}, {"k": "stati"}, {"k": "sto"}, {"k": "struja"}, {"k": "stručan"}, {"k": "studeni"}, {"k": "stvar"}, {"k": "subota"}, {"k": "super"}, {"k": "supermarket"}, {"k": "suprug"}, {"k": "supruga"}, {"k": "susresti"}, {"k": "sustav"}, {"k": "svaki dan"}, {"k": "sve je u redu"}, {"k": "svejedno"}, {"k": "svibanj"}, {"k": "svijet"}, {"k": "svinjetina"}, {"k": "sviđati se"}, {"k": "svjetlo"}, {"k": "svježe"}, {"k": "svoj"}, {"k": "taj"}, {"k": "tako"}, {"k": "također"}, {"k": "tek"}, {"k": "tekst"}, {"k": "tema"}, {"k": "teren"}, {"k": "terminal"}, {"k": "testirati"}, {"k": "ticati"}, {"k": "tijelo"}, {"k": "tim"}, {"k": "tisuću"}, {"k": "tko je to"}, {"k": "toaletni papir"}, {"k": "toplo"}, {"k": "torbica"}, {"k": "točno"}, {"k": "tramvaj"}, {"k": "traperice"}, {"k": "travanj"}, {"k": "trebam doktora"}, {"k": "trebam policiju"}, {"k": "trebam pomoć"}, {"k": "trebam promijeniti novac"}, {"k": "trebam punjač"}, {"k": "trebam sobu"}, {"k": "trebam taksi"}, {"k": "trebam vrećicu"}, {"k": "trener"}, {"k": "trening"}, {"k": "treći"}, {"k": "trgovac"}, {"k": "tri"}, {"k": "trideset"}, {"k": "trideset pet"}, {"k": "trinaest"}, {"k": "tristo"}, {"k": "tuga"}, {"k": "tuš"}, {"k": "u principu"}, {"k": "ugodan dan"}, {"k": "uhvatiti"}, {"k": "ujutro"}, {"k": "ukrali su mi torbu"}, {"k": "ukusno"}, {"k": "ulje u mjenjaču"}, {"k": "umoran sam"}, {"k": "umorna sam"}, {"k": "upaliti"}, {"k": "uskoro"}, {"k": "usta"}, {"k": "utorak"}, {"k": "uvjet"}, {"k": "uzica"}, {"k": "uzrok"}, {"k": "ući"}, {"k": "učim hrvatski"}, {"k": "učiniti"}, {"k": "veliko"}, {"k": "veljača"}, {"k": "veterinar"}, {"k": "veza"}, {"k": "već"}, {"k": "viza"}, {"k": "više"}, {"k": "vlastit"}, {"k": "voda bez plina"}, {"k": "voda s plinom"}, {"k": "vodič"}, {"k": "volan"}, {"k": "vrsta"}, {"k": "vruć"}, {"k": "vruće"}, {"k": "zadatak"}, {"k": "zadržati"}, {"k": "zadržite kusur"}, {"k": "zahod"}, {"k": "zajedno"}, {"k": "započeti"}, {"k": "zapravo"}, {"k": "zaraditi"}, {"k": "zastoj"}, {"k": "zatvoreno"}, {"k": "završiti"}, {"k": "zeleni"}, {"k": "zeleno"}, {"k": "zemlja"}, {"k": "znati"}, {"k": "zovem se"}, {"k": "zovi policiju"}, {"k": "zovite hitnu"}, {"k": "zovite policiju"}, {"k": "zvono"}, {"k": "zvuk"}, {"k": "čaj s limunom"}, {"k": "čak"}, {"k": "čašu vode"}, {"k": "čekaj"}, {"k": "četiri"}, {"k": "četkica"}, {"k": "četrdeset"}, {"k": "četrnaest"}, {"k": "četvrtak"}, {"k": "četvrti"}, {"k": "čiji"}, {"k": "činiti"}, {"k": "čisto"}, {"k": "čistoća"}, {"k": "čujemo se"}, {"k": "šampon"}, {"k": "šapa"}, {"k": "šesnaest"}, {"k": "šest"}, {"k": "šesti"}, {"k": "šezdeset"}, {"k": "što je ovo"}, {"k": "žao mi je"}, {"k": "žedan sam"}, {"k": "žedna sam"}, {"k": "želim platiti"}, {"k": "želja"}, {"k": "željeti"}, {"k": "žiro račun"}, {"k": "život"}, {"k": "životinja"}, {"k": "žurim se"}, {"k": "žuti"}, {"k": "žuto"}]'::jsonb) as t(k text));
  select count(*) into v_done from public.content_reviews where notes = 'Приклад додано 2026-10-21 (A0 / A1; scripts/lexemes_examples_data.py). Бета, як уроки A0 / A1 (рішення власника 2026-10-12): носій перевіряє після публікації. Потрібна перевірка носієм: content/reviews/2026-10-21_lexemes_examples.md.';
  if v_empty > 0 then raise exception 'Лишилось слів без прикладу: %', v_empty; end if;
  raise notice 'Готово: приклади (A0 / A1) додано (записів у журналі перевірки: %)', v_done;
end $$;

commit;
