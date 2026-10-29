# Приклади для слів словника — перевірка носієм (2026-10-21)

Пакет: `scripts/lexemes_examples_data.py` → `supabase/data_fixes/20261021_lexemes_examples_a0_a1.sql` (бета, A0/A1) і `20261021_lexemes_examples_a2_b1.sql` (A2/B1, після «ок» власника).
Усього: 570 речень A0/A1 і 1631 речень A2/B1. Кожне слово, у якого не було прикладу, отримало одне речення; наявні приклади не змінювались.

## Що варто глянути носію насамперед

- Речення, де слово стоїть у формі, далекій від леми (автоматична перевірка не знайшла основу леми) — список нижче.
- Розмовні / регіональні слова: *kusur*, *pasoš*, *apoteka*, *greška*, *onak* — речення природні, але слово не стандартне.
- Вид дієслова в реченні (доконаний / недоконаний) — особливо для пар на кшталт *dogovarati / dogovoriti*.

### Основу леми в реченні не знайдено автоматично

Переглянуто вручну 2026-10-21: усі нижче — звичайні відмінкові чи особові форми (lipnju, drži, plače, kišem…), слово в реченні є. *glatak* — варіант стандартного *gladak* (у словнику обидва; у реченні — *gladak*).

| Лема | Речення |
|---|---|
| lipanj | Škola završava u lipnju. |
| srpanj | U srpnju je jako vruće. |
| držati | Drži se za ogradu, stepenice su klizave. |
| kajati | Kajem se što nisam došao. |
| lajati | Susjedov pas laje cijelu noć. |
| plakati | Dijete plače jer je gladno. |
| stajati | Koliko stoji ova jakna? |
| ticati | To se tebe ne tiče! |
| davati | Ova banka daje dobre kredite. |
| isteći | Putovnica mi uskoro ističe. |
| kihati | Stalno kišem zbog alergije. |
| rezati | Nož ne reže dobro. |
| smjeti | Smijem li ovdje pušiti? |
| šutjeti | Zašto šutiš? |
| ulagati | Ulažemo u obrazovanje djece. |
| disati | Dišite duboko, molim vas. |
| dugovati | Koliko ti dugujem? |
| gibak | Mačka je gipka i brza životinja. |
| glatak | Kamen je gladak od mora. |
| mastan | Ova hrana je previše masna. |
| miriti se | Brat i sestra se brzo mire nakon svađe. |
| plesti | Baka plete džemper. |
| predak | Moji preci su došli iz Like. |
| složiti se | Slažem se s tobom. |
| suditi se | Susjedi se sude zbog ograde. |
| tugovati | Obitelj tuguje za djedom. |
| vagati | Prodavačica važe voće. |
| važiti | Ta pravila važe za sve. |
| žalovati | Cijelo selo žaluje za njim. |

## A0 / A1 (бета)

| Лема | Приклад |
|---|---|
| aerodrom | Autobus za aerodrom polazi svakih pola sata. |
| ambulanta | Ambulanta radi od sedam do tri. |
| aplikacija | Kartu možeš kupiti preko aplikacije. |
| arhitektura | Volim staru arhitekturu Splita. |
| australski ovčar | Naš pas je australski ovčar. |
| automobil | Moj automobil je na servisu. |
| autor | Tko je autor ove knjige? |
| benzin | Moram natočiti benzin. |
| bez šećera | Kavu uvijek pijem bez šećera. |
| bi | Bi li mi mogao pomoći? |
| bicikl | Na posao idem biciklom. |
| bijeli | Kupio sam bijeli kruh i mlijeko. |
| bijelo | Bijelo vino ide uz ribu. |
| biljka | Zalij biljku na balkonu. |
| bježati | Djeca bježe od kiše pod krov. |
| bogat | Njegov stric je jako bogat. |
| boja | Koja ti je omiljena boja? |
| bok | Bok, kako si? |
| brinuti se | Ne brini se, sve će biti dobro. |
| brod | Brod za Hvar polazi u devet. |
| brojka | Napiši brojku sedam. |
| buditi se | Svako jutro se budim u šest. |
| budućnost | Planiramo budućnost u Hrvatskoj. |
| buka | Na ulici je velika buka. |
| cijeniti | Jako cijenim tvoju pomoć. |
| cilj | Moj cilj je govoriti hrvatski bez straha. |
| cjepivo | Cjepivo protiv gripe možete dobiti u ambulanti. |
| crni | Uzet ću crni kaput. |
| crno | Volim crno vino. |
| crtati | Moja kći voli crtati životinje. |
| crveni | Vidiš onaj crveni auto ispred kuće? |
| crveno | Stani, na semaforu je crveno. |
| deset | Trgovina se otvara u deset sati. |
| deseti | Danas je deseti dan našeg odmora. |
| devedeset | Moj djed ima devedeset godina. |
| devet | Na posao dolazim u devet sati. |
| deveti | Ured je na devetom katu. |
| devetnaest | Autobus broj devetnaest vozi do centra. |
| devizni račun | Želim otvoriti devizni račun u banci. |
| dijalog | Pročitajte dijalog naglas. |
| dizel | Moj auto ide na dizel. |
| dizne | Mehaničar kaže da treba očistiti dizne. |
| djevojka | Ovo je moja djevojka Darja. |
| djevojčica | Ta djevojčica ima pet godina. |
| dječak | Dječak se igra loptom u parku. |
| dlaka | Na kauču je puno pseće dlake. |
| dnevni | Dnevni limit za podizanje novca je petsto eura. |
| dnevni sastanak | Dnevni sastanak traje petnaest minuta. |
| dobitak | Na lotu je osvojio veliki dobitak. |
| dobro | Hvala, dobro sam. |
| dobro došli | Dobro došli u Zagreb! |
| dobro jutro svima | Dobro jutro svima, počinjemo sastanak. |
| dobrodošli | Dobrodošli u naš hotel! |
| dodatan | Za dodatan krevet plaća se deset eura. |
| dodati | Možeš li dodati malo soli? |
| događaj | Koncert je bio događaj godine. |
| dok | Čekaj me ovdje dok ne dođem. |
| dolaziti | Autobus dolazi svakih deset minuta. |
| dolje | Čekam te dolje, ispred zgrade. |
| donijeti | Možete li nam donijeti jelovnik? |
| donositi | Poštar donosi pisma ujutro. |
| dozvola za boravak | Dozvola za boravak vrijedi godinu dana. |
| dozvoliti | Ne mogu ti to dozvoliti. |
| drag | Ti si mi jako drag prijatelj. |
| drago | Drago mi je što si došla. |
| drago mi je | Drago mi je, ja sam Darja. |
| drugi | Ovo je moj drugi tjedan u Zagrebu. |
| držati | Drži se za ogradu, stepenice su klizave. |
| dva | Molim vas dva kruha. |
| dvadeset | Do stanice ima dvadeset minuta pješice. |
| dvadeset dva | Moja soba je broj dvadeset dva. |
| dvadeset jedan | Ovdje sam već dvadeset jedan dan. |
| dvanaest | Ručamo u dvanaest sati. |
| dvjesto | Let do Splita košta dvjesto eura. |
| elektronika | Elektronika je na drugom katu trgovine. |
| gdje je apoteka | Oprostite, gdje je apoteka? |
| gdje je autobusni kolodvor | Oprostite, gdje je autobusni kolodvor? |
| gdje je banka | Gdje je banka? Moram podići novac. |
| gdje je bankomat | Gdje je bankomat? Nemam gotovine. |
| gdje je blagajna | Gdje je blagajna? Htjela bih platiti. |
| gdje je izlaz | Oprostite, gdje je izlaz? |
| gdje je kabina | Gdje je kabina? Želim probati ove hlače. |
| gdje je ljekarna | Gdje je ljekarna? Boli me glava. |
| gdje je ulaz | Gdje je ulaz u muzej? |
| gdje je wc | Oprostite, gdje je WC? |
| gdje je zahod | Oprostite, gdje je zahod? |
| gdje je željeznički kolodvor | Gdje je željeznički kolodvor? Moram stići na vlak. |
| gdje mogu kupiti kartu | Gdje mogu kupiti kartu za autobus? |
| gladan sam | Gladan sam, idemo nešto pojesti. |
| gladna sam | Mama, gladna sam! |
| glas | Imaš lijep glas. |
| gore | Kupaonica je gore, na prvom katu. |
| gospodin | Gospodin Kovač vas čeka. |
| gospođa | Gospođa Horvat je naša susjeda. |
| govedina | Danas za ručak imamo govedinu s krumpirom. |
| govorite li engleski | Oprostite, govorite li engleski? |
| govoriti tiho | U knjižnici treba govoriti tiho. |
| graditi | Grad gradi novi most. |
| gramatika | Hrvatska gramatika nije laka. |
| greška | Ispričavam se, to je moja greška. |
| grijanje | Grijanje ne radi, hladno je. |
| grupa | Naša grupa ima deset učenika. |
| guma | Pukla mi je guma na autu. |
| higijena | Higijena ruku je važna. |
| hladno | Vani je jako hladno. |
| hrana za pse | Kupi hranu za pse u trgovini. |
| idemo | Idemo, zakasnit ćemo! |
| igra | Djeca vole ovu igru. |
| igrati se | Djeca se igraju u parku. |
| igrač | On je najbolji igrač u momčadi. |
| imam rezervaciju | Dobar dan, imam rezervaciju na ime Petrenko. |
| imate li sitno | Imate li sitno? Imam samo novčanicu od pedeset eura. |
| imate li slobodnu sobu | Dobra večer, imate li slobodnu sobu za dvije noći? |
| imate li wifi | Imate li wifi u sobama? |
| iskaznica | Pokažite osobnu iskaznicu, molim. |
| iskreno | Iskreno, ne sviđa mi se ovaj film. |
| isporuka | Isporuka traje tri dana. |
| ispričavam se | Ispričavam se, zakasnio sam. |
| isti | Imamo isti mobitel. |
| izbor | Ovdje je velik izbor voća. |
| izgubila sam se | Oprostite, izgubila sam se. Gdje je glavni trg? |
| izgubio sam se | Izgubio sam se, možete li mi pomoći? |
| iznenađenje | Imam iznenađenje za tebe! |
| iznositi | Tko danas iznosi smeće? |
| izvoli | Izvoli, ovo je za tebe. |
| izvolite | Izvolite, vaša kava. |
| ja bih vodu | Ja bih vodu, molim. |
| ja sam gladan | Ja sam gladan, a ti? |
| ja sam iz ukrajine | Zovem se Daša, ja sam iz Ukrajine. |
| ja sam umoran | Ja sam umoran, idem spavati. |
| ja sam žedan | Ja sam žedan, imaš li vode? |
| jahta | U luci je velika jahta. |
| jak | Danas puše jak vjetar. |
| javan | Ovaj park je javan i otvoren svima. |
| jedan | Molim vas jedan kruh. |
| jedan smjer | Trebam kartu samo u jedan smjer. |
| jedanaest | Vlak polazi u jedanaest sati. |
| jeftino | Ovdje se jede dobro i jeftino. |
| jelo | Koje je vaše omiljeno jelo? |
| jelovnik | Možemo li dobiti jelovnik? |
| još | Još malo, molim. |
| kajati | Kajem se što nisam došao. |
| kako da dođem do | Kako da dođem do glavnog trga? |
| kako se kaže | Kako se kaže „hvala“ na hrvatskom? |
| kako se zovete | Dobar dan, kako se zovete? |
| kako se zoveš | Bok, kako se zoveš? |
| kamo | Kamo ideš? |
| kamo idete | Kamo idete ovog vikenda? |
| kanta | Baci to u kantu za smeće. |
| kao | Govoriš hrvatski kao pravi Hrvat! |
| karta u jednom smjeru | Jedna karta u jednom smjeru do Splita, molim. |
| karta za zagreb | Jedna karta za Zagreb, molim. |
| karta, molim | Jedna karta, molim. |
| karticom ili gotovinom | Plaćate karticom ili gotovinom? |
| kasnije | Nazvat ću te kasnije. |
| kasniti | Vlak kasni dvadeset minuta. |
| kazati | Što ti je kazao liječnik? |
| klijent | Klijent čeka na recepciji. |
| kod | Unesite kod za vrata. |
| koja je lozinka | Koja je lozinka za wifi? |
| koji broj | Koji broj cipela nosite? |
| koji je danas dan | Koji je danas dan, srijeda ili četvrtak? |
| koliko godina imate | Oprostite, koliko godina imate? |
| koliko je sati | Oprostite, koliko je sati? |
| koliko je to | Koliko je to ukupno? |
| koliko košta noćenje | Koliko košta noćenje s doručkom? |
| koliko to košta | Koliko to košta? |
| kolovoz | U kolovozu idemo na more. |
| komad | Mogu li dobiti komad torte? |
| kontejner | Plastiku baci u žuti kontejner. |
| korisnik | Korisnik je zaboravio lozinku. |
| korist | Kakva je korist od toga? |
| kotač | Kotač na koferu je slomljen. |
| kovanica | Za kolica u trgovini treba kovanica. |
| kočnica | Kočnica na biciklu ne radi. |
| kultura | Zanima me hrvatska kultura. |
| kusur | Zaboravili ste kusur! |
| kuća | Moja kuća je blizu mora. |
| kvačilo | Polako pusti kvačilo. |
| lagan | Kofer je lagan, mogu ga sama nositi. |
| lajati | Susjedov pas laje cijelu noć. |
| letjeti | Ne volim letjeti avionom. |
| li | Govorite li hrvatski? |
| lijepo | Kakvo lijepo more! |
| liječenje | Liječenje traje dva tjedna. |
| limun | Stavi malo limuna u čaj. |
| lipanj | Škola završava u lipnju. |
| listopad | Rođena sam u listopadu. |
| ljubav | Ovo je ljubav na prvi pogled. |
| lokalan | Ovaj sir je lokalan proizvod s otoka. |
| lopov | Lopov je ukrao bicikl ispred zgrade. |
| lopta | Dječak baca loptu psu. |
| luka | Trajekt stiže u luku u podne. |
| mama | Mama, gdje su moje cipele? |
| manje | Pij manje kave! |
| matematika | Matematika mi je bila najteži predmet. |
| medalja | Osvojila je zlatnu medalju. |
| medicina | Moja sestra studira medicinu. |
| mehaničar | Mehaničar je popravio auto. |
| meni je hladno | Možeš zatvoriti prozor? Meni je hladno. |
| meni je vruće | Meni je vruće, otvori prozor. |
| međunarodni | Ovo je međunarodni aerodrom. |
| milijun | Ovaj stan košta pola milijuna eura. |
| mišljenje | Kakvo je tvoje mišljenje? |
| mjesto | Je li ovo mjesto slobodno? |
| mobilno bankarstvo | Račune plaćam preko mobilnog bankarstva. |
| mogu li platiti karticom | Dobar dan, mogu li platiti karticom? |
| mogu li probati | Ova haljina je lijepa, mogu li probati? |
| moguć | Je li moguć popust? |
| molim račun | Konobaru, molim račun! |
| molim te | Molim te, zatvori vrata. |
| molim vas | Molim vas, gdje je stanica? |
| molim vas jednu kavu | Molim vas jednu kavu s mlijekom. |
| molim vas vode | Molim vas vode, jako sam žedna. |
| moliti | Moram vas moliti za pomoć. |
| motor | Motor ne pali. |
| može | Može, vidimo se u pet. |
| možete li mi pomoći | Oprostite, možete li mi pomoći? |
| možete li ponoviti | Ne razumijem, možete li ponoviti? |
| mreža | Nema mreže, ne mogu nazvati. |
| muškarac | Taj muškarac je moj šef. |
| nacionalan | Ovo jelo je naš nacionalni ponos. |
| najmodavac | Najmodavac traži polog od dvije stanarine. |
| napamet | Naučila sam pjesmu napamet. |
| napisati | Moram napisati mail šefu. |
| napraviti | Što ćemo napraviti za večeru? |
| naprijed | Idite ravno naprijed. |
| naprimjer | Volim voće, naprimjer jabuke i kruške. |
| naranča | Za doručak pojedem jednu naranču. |
| narod | Hrvati su gostoljubiv narod. |
| nastaviti | Nastavite ravno do semafora. |
| natrag | Vratit ću se natrag za sat vremena. |
| navečer | Navečer volim šetati uz more. |
| navijač | On je veliki navijač Hajduka. |
| ne govorim hrvatski | Žao mi je, ne govorim hrvatski. |
| ne radi | Lift ne radi, idemo stepenicama. |
| ne razumijem | Ne razumijem, govorite polako, molim vas. |
| ne znam | Ne znam gdje je pošta. |
| nedjelja | U nedjelju su trgovine zatvorene. |
| nema problema | Nema problema, pomoći ću ti. |
| nemam novca | Ne mogu ići s vama, nemam novca. |
| nemam vremena | Danas nemam vremena, žurim se. |
| nemati | Teško je nemati posao. |
| nigdje | Nigdje ne mogu naći ključeve. |
| nikada | Nikada nisam bio u Dubrovniku. |
| nitko | Nitko nije odgovorio. |
| njen | Ovo je njen auto. |
| nos | Curi mi nos. |
| novo | Kupili smo novo računalo. |
| novčanica | Imate li manju novčanicu? |
| nula | Vani je nula stupnjeva. |
| obiteljski liječnik | Moj obiteljski liječnik radi do podne. |
| objaviti | Fotografije ćemo objaviti sutra. |
| obrisati | Obriši stol, molim te. |
| odabrati | Odaberite jezik. |
| odakle | Odakle si? |
| odakle ste | Odakle ste? Iz Ukrajine? |
| odgovarati | Ova veličina mi ne odgovara. |
| odjeća | Odjeća je u ormaru. |
| odličan | Ovo je odličan restoran. |
| odlično | Odlično, vidimo se sutra! |
| odmah | Dolazim odmah! |
| odmarati | Vikendom odmaram kod kuće. |
| odmoriti se | Trebam se malo odmoriti. |
| odnijeti | Možete li odnijeti tanjure? |
| ogrlica | Ova ogrlica je poklon od mame. |
| oib | Za ugovor trebate OIB. |
| okrenuti | Okreni se, iza tebe je Daša! |
| ona (pl) | Djeca su vani, ona se igraju u dvorištu. |
| onaj | Daj mi onaj crveni. |
| onda | Prvo jedemo, onda idemo u šetnju. |
| one | Gdje su djevojke? One su u kafiću. |
| opasno | Ovdje je opasno plivati. |
| opet | Opet kasniš! |
| oprez | Oprez, pod je mokar! |
| oprezan | Budi oprezan na cesti. |
| oprostite, gdje je | Oprostite, gdje je glavni trg? |
| osam | Radim od osam do četiri. |
| osamdeset | Baka ima osamdeset godina. |
| osamnaest | Vozačku dozvolu možeš dobiti s osamnaest godina. |
| osmi | Moj sin ide u osmi razred. |
| osoban | To je jako osobno pitanje. |
| otići | Moram otići u trgovinu. |
| otvoreno | Je li otvoreno nedjeljom? |
| ovaj | Ide li ovaj autobus u centar? |
| ovdje je moj pasoš | Ovdje je moj pasoš, izvolite. |
| očekivati | Očekujem paket danas. |
| ožujak | U ožujku je već toplije. |
| pa | Bio sam umoran, pa sam ostao kod kuće. |
| pad | Zbog pada sustava nismo mogli raditi. |
| padati | Vani pada kiša. |
| pamtiti | Ne pamtim dobro imena. |
| papar | Dodaj sol i papar. |
| papuče | Gdje su moje papuče? |
| parking | Parking je iza hotela. |
| pasta | Trebam pastu za zube. |
| pasti | Pazi, možeš pasti! |
| pazi | Pazi, auto! |
| pažnja | Hvala na pažnji. |
| pedeset | Ova jakna košta pedeset eura. |
| pet | Vidimo se u pet. |
| petak | U petak idemo u kino. |
| peti | Danas je peti dan tečaja. |
| petnaest | Autobus dolazi za petnaest minuta. |
| petsto | Najam stana je petsto eura mjesečno. |
| piletina | Za ručak imamo piletinu s rižom. |
| pivo točeno | Imate li pivo točeno? |
| piće | Što želite za piće? |
| pjevati | Volim pjevati pod tušem. |
| pješice | Idemo pješice, blizu je. |
| plakati | Dijete plače jer je gladno. |
| plan | Kakav je plan za vikend? |
| plavi | Kupila sam plavi džemper. |
| plavo | More je danas jako plavo. |
| plesati | Idemo plesati u subotu! |
| po noći | Po noći je ovdje jako tiho. |
| pogledati | Možeš li pogledati moj mail? |
| pokazati | Možete li mi pokazati put do stanice? |
| pokvareno | Meso je pokvareno, nemoj ga jesti. |
| polako | Govorite polako, molim vas. |
| police | Police u kuhinji su pune. |
| političar | Taj političar često je na televiziji. |
| poljubac | Daj mi poljubac! |
| pomirenje | Nakon svađe došlo je do pomirenja. |
| ponedjeljak | U ponedjeljak počinjem novi posao. |
| ponos | Ti si naš ponos! |
| ponovno | Molim vas, pokušajte ponovno. |
| popodne | Popodne idemo na plažu. |
| popravak | Popravak auta trajat će tri dana. |
| posjetitelj | Muzej svaki dan ima puno posjetitelja. |
| posljednji | Ovo je posljednji autobus večeras. |
| poslovna kartica | Troškove puta plaćam poslovnom karticom. |
| poslužitelj | Poslužitelj ne radi, stranica se ne otvara. |
| postavke | Promijeni jezik u postavkama. |
| posuđe | Ja ću oprati posuđe. |
| povodac | Pas mora biti na povocu. |
| početi | Film će početi za pet minuta. |
| pratiti | Pratite znakove za izlaz. |
| prazna mi je baterija | Ne mogu te nazvati, prazna mi je baterija. |
| prekjučer | Prekjučer sam bila kod liječnika. |
| prekosutra | Vraćam se prekosutra. |
| preporučiti | Možete li nam preporučiti dobar restoran? |
| prije | Prije jela operi ruke. |
| prijelaz | Prijeđite cestu na pješačkom prijelazu. |
| prijevod | Trebam službeni prijevod dokumenta. |
| prijevoz | Javni prijevoz u Zagrebu je dobar. |
| prirodan | Ovaj sok je potpuno prirodan. |
| pristup | Nemam pristup internetu. |
| priča | To je duga priča. |
| prljavo | Nakon zabave sve je bilo prljavo. |
| procjena | Procjena za ovaj zadatak je dva dana. |
| prometna dozvola | Policajac je tražio vozačku i prometnu dozvolu. |
| pronaći | Ne mogu pronaći ključeve. |
| prosinac | U prosincu slavimo Božić. |
| prtljažnik | Stavi kofere u prtljažnik. |
| prvi | Ovo mi je prvi put u Hrvatskoj. |
| pumpa | Moramo stati na pumpi, nemamo goriva. |
| put | Sretan put! |
| rad | Rad od kuće mi odgovara. |
| radio | Upali radio, molim te. |
| razgovarati | Moramo razgovarati. |
| recepcija | Ključ ostavite na recepciji. |
| red | Stani u red, molim te. |
| rep | Pas maše repom. |
| riječ | Kako se izgovara ova riječ? |
| rok | Rok za predaju je petak. |
| rođak | Moj rođak živi u Zadru. |
| rođendan | Sretan rođendan! |
| rub | Ne stoj na rubu, opasno je. |
| rujan | Škola počinje u rujnu. |
| ručnik | Trebam još jedan ručnik, molim. |
| ružno | Vrijeme je danas ružno. |
| s mlijekom | Kavu pijem s mlijekom. |
| samo gledam | Hvala, samo gledam. |
| sapun | U kupaonici nema sapuna. |
| sav | Pojeo je sav kruh. |
| se | Kako se zoveš? |
| sedam | Ustajem u sedam. |
| sedamdeset | Djed ima sedamdeset godina. |
| sedamnaest | Sestra ima sedamnaest godina. |
| sedmi | Živimo na sedmom katu. |
| signal | Ovdje nema signala. |
| siječanj | U siječnju je jako hladno. |
| sila | Za ovo treba puno sile. |
| simptom | Koji su simptomi gripe? |
| siromašan | Bio je siromašan, ali sretan. |
| sirup | Liječnik mi je prepisao sirup za kašalj. |
| sitniš | Imate li sitniša? |
| siv | Grad je danas siv i kišovit. |
| sivi | Uzmi sivi kaput, vani je hladno. |
| sivo | Nebo je danas sivo. |
| sjediti | Mogu li sjediti ovdje? |
| sjetiti se | Ne mogu se sjetiti njegova imena. |
| skaliranje | Skaliranje sustava planiramo za idući mjesec. |
| skupo | U ovom restoranu je skupo. |
| slab | Signal je ovdje slab. |
| slano | Ovo jelo je jako slano. |
| slatko | Volim nešto slatko nakon ručka. |
| slaviti | Kako slavite Božić u Ukrajini? |
| slikar | Moj djed je bio slikar. |
| slovo | Kako se piše ovo slovo? |
| smeće | Iznesi smeće, molim te. |
| smeđe | Ona ima smeđe oči. |
| smeđi | Kupio sam smeđi remen. |
| smijati se | Zašto se smiješ? |
| smjer | U kojem smjeru je centar? |
| spasiti | Liječnici su mu spasili život. |
| sportski | Gledamo sportski program. |
| sredina | Stan je u samoj sredini grada. |
| sretan božić | Sretan Božić i sretna Nova godina! |
| sretna nova godina | Sretna Nova godina svima! |
| srijeda | U srijedu imam tečaj hrvatskog. |
| srpanj | U srpnju je jako vruće. |
| stajati | Koliko stoji ova jakna? |
| staklo | Pazi, na podu je razbijeno staklo. |
| stani | Stani, crveno je! |
| stanovnik | Svaki stanovnik zgrade ima svoj ključ. |
| staro | Ovo je jako staro selo. |
| stati | Možete li stati ovdje? |
| sto | Do mora ima sto metara. |
| struja | Nema struje u cijeloj zgradi. |
| stručan | Trebamo stručan savjet. |
| studeni | U studenom često pada kiša. |
| stvar | Imam još jednu stvar za tebe. |
| subota | U subotu idemo na tržnicu. |
| super | Super, vidimo se sutra! |
| supermarket | Supermarket je otvoren do devet. |
| suprug | Ovo je moj suprug Ivan. |
| supruga | Moja supruga radi u bolnici. |
| susresti | Jučer sam susreo starog prijatelja. |
| sustav | Sustav je trenutno nedostupan. |
| svaki dan | Svaki dan učim nove riječi. |
| sve je u redu | Ne brini, sve je u redu. |
| svejedno | Meni je svejedno, odaberi ti. |
| svibanj | U svibnju je sve zeleno. |
| svijet | Želim putovati po svijetu. |
| svinjetina | Ne jedem svinjetinu. |
| sviđati se | Sviđa mi se ovaj grad. |
| svjetlo | Ugasi svjetlo, molim te. |
| svježe | Ovo voće je svježe. |
| svoj | Svatko plaća svoj račun. |
| taj | Taj film je dosadan. |
| tako | Nemoj tako brzo voziti! |
| također | Ja također volim more. |
| tek | Tek sam stigla. |
| tekst | Pročitajte tekst i odgovorite na pitanja. |
| tema | Koja je tema današnjeg sata? |
| teren | Igrači izlaze na teren. |
| terminal | Autobus vozi do putničkog terminala. |
| testirati | Moramo testirati novu aplikaciju. |
| ticati | To se tebe ne tiče! |
| tijelo | Boli me cijelo tijelo. |
| tim | Naš tim radi od kuće. |
| tisuću | Ovaj telefon košta tisuću eura. |
| tko je to | Tko je to na vratima? |
| toaletni papir | U kupaonici nema toaletnog papira. |
| toplo | More je danas toplo. |
| torbica | Zaboravila sam torbicu u taksiju. |
| točno | Točno, to je pravi odgovor! |
| tramvaj | Tramvaj broj šest vozi do kolodvora. |
| traperice | Ove traperice su mi preuske. |
| travanj | U travnju često pada kiša. |
| trebam doktora | Trebam doktora, jako me boli trbuh. |
| trebam policiju | Trebam policiju, ukrali su mi novčanik. |
| trebam pomoć | Oprostite, trebam pomoć. |
| trebam promijeniti novac | Trebam promijeniti novac, gdje je mjenjačnica? |
| trebam punjač | Trebam punjač za mobitel. |
| trebam sobu | Trebam sobu za dvije osobe. |
| trebam taksi | Trebam taksi do aerodroma. |
| trebam vrećicu | Trebam vrećicu, molim vas. |
| trener | Trener je zadovoljan našom igrom. |
| trening | Trening počinje u šest. |
| treći | Ovo je treći put da kasniš! |
| trgovac | Trgovac mi je dao popust. |
| tri | Imam tri brata. |
| trideset | Ovdje čekamo već trideset minuta. |
| trideset pet | Imam trideset pet godina. |
| trinaest | Kći ima trinaest godina. |
| tristo | Let do Dubrovnika košta tristo eura. |
| tuga | U očima joj se vidjela tuga. |
| tuš | Tuš u kupaonici ne radi. |
| u principu | U principu se slažem s tobom. |
| ugodan dan | Hvala i ugodan dan! |
| uhvatiti | Moram uhvatiti zadnji autobus. |
| ujutro | Ujutro pijem kavu. |
| ukrali su mi torbu | Upomoć, ukrali su mi torbu! |
| ukusno | Ovo je jako ukusno! |
| ulje u mjenjaču | Mehaničar je promijenio ulje u mjenjaču. |
| umoran sam | Umoran sam, idem kući. |
| umorna sam | Umorna sam nakon posla. |
| upaliti | Upali svjetlo, mrak je. |
| uskoro | Uskoro dolazimo. |
| usta | Otvorite usta, molim. |
| utorak | U utorak imam sastanak. |
| uvjet | Koji su uvjeti za dobivanje vize? |
| uzica | Drži psa na uzici. |
| uzrok | Uzrok kvara još nije poznat. |
| ući | Mogu li ući? |
| učim hrvatski | Učim hrvatski već tri mjeseca. |
| učiniti | Što mogu učiniti za vas? |
| veliko | Imaju veliko dvorište. |
| veljača | U veljači je karneval. |
| veterinar | Moramo odvesti mačku veterinaru. |
| veza | Internetska veza je spora. |
| već | Već sam jela, hvala. |
| viza | Trebam li vizu za Hrvatsku? |
| više | Trebam više vremena. |
| vlastit | Svaka soba ima vlastitu kupaonicu. |
| voda bez plina | Molim vas jednu vodu bez plina. |
| voda s plinom | Želite li vodu s plinom ili bez plina? |
| vodič | Vodič nam je pokazao stari grad. |
| volan | Sjedni za volan, ti voziš. |
| vrsta | Koja vrsta kruha vam treba? |
| vruć | Pazi, čaj je vruć! |
| vruće | Danas je jako vruće. |
| zadatak | Domaći zadatak je na stranici deset. |
| zadržati | Zadržite kopiju računa. |
| zadržite kusur | Hvala, zadržite kusur. |
| zahod | Zahod je na kraju hodnika. |
| zajedno | Idemo zajedno na kavu? |
| započeti | Sastanak ćemo započeti u devet. |
| zapravo | Zapravo, nisam gladan. |
| zaraditi | Ljeti mogu zaraditi više novca. |
| zastoj | Imamo zastoj, čekamo odgovor drugog tima. |
| zatvoreno | Nedjeljom je zatvoreno. |
| završiti | Kad završiš posao? |
| zeleni | Volim zeleni čaj. |
| zeleno | U proljeće je sve zeleno. |
| zemlja | Iz koje zemlje dolazite? |
| znati | Želim znati više o Hrvatskoj. |
| zovem se | Zovem se Daša, a ti? |
| zovi policiju | Zovi policiju, brzo! |
| zovite hitnu | Zovite hitnu, čovjeku je loše! |
| zovite policiju | Zovite policiju, netko je provalio u stan! |
| zvono | Zvono na vratima ne radi. |
| zvuk | Utišaj zvuk, molim te. |
| čaj s limunom | Molim vas jedan čaj s limunom. |
| čak | Čak i djeca to znaju. |
| čašu vode | Mogu li dobiti čašu vode? |
| čekaj | Čekaj, nisam još gotova! |
| četiri | Naš stan ima četiri sobe. |
| četkica | Zaboravila sam četkicu za zube. |
| četrdeset | Karta za koncert košta četrdeset eura. |
| četrnaest | Moja kći ima četrnaest godina. |
| četvrtak | Vidimo se u četvrtak navečer. |
| četvrti | Živim na četvrtom katu. |
| čiji | Čiji je ovo mobitel? |
| činiti | Čini mi se da će padati kiša. |
| čisto | Nakon čišćenja sve je čisto i uredno. |
| čistoća | U hotelu je čistoća na prvom mjestu. |
| čujemo se | Hvala na pozivu, čujemo se sutra! |
| šampon | Trebam šampon za suhu kosu. |
| šapa | Pas je ozlijedio šapu. |
| šesnaest | Ovo je soba broj šesnaest. |
| šest | Večera je u šest. |
| šesti | Ovo je već šesti put da te zovem! |
| šezdeset | Moja mama ima šezdeset godina. |
| što je ovo | Oprostite, što je ovo na jelovniku? |
| žao mi je | Žao mi je, ne mogu doći. |
| žedan sam | Žedan sam, možeš li mi dati vode? |
| žedna sam | Žedna sam, idemo po vodu. |
| želim platiti | Želim platiti, molim vas. |
| želja | Moja najveća želja je putovati. |
| željeti | Što biste željeli popiti? |
| žiro račun | Plaća mi stiže na žiro račun. |
| život | Život na moru je lijep. |
| životinja | Koja je tvoja omiljena životinja? |
| žurim se | Oprostite, žurim se. |
| žuti | Kupila sam žuti kišobran. |
| žuto | Svjetlo na semaforu je žuto. |

## A2 / B1 (після «ок» власника)

| Лема | Приклад |
|---|---|
| administracija | Administracija na fakultetu radi samo ujutro. |
| akcija | Ovaj tjedan je akcija na sir i jogurt. |
| aktivan | Djed je i u osamdesetoj godini jako aktivan. |
| aktivno | Aktivno tražim posao u Zagrebu. |
| aktualan | To pitanje je i danas aktualno. |
| akustika | Ova dvorana ima odličnu akustiku. |
| akutan | Liječnik kaže da je upala akutna. |
| alat | Imaš li alat za popravak bicikla? |
| alergija | Imam alergiju na mačke. |
| alergičan | Alergičan sam na orašaste plodove. |
| algebra | Algebra mi u školi nije išla. |
| ambiciozan | Ona je mlada i jako ambiciozna. |
| ambijent | Restoran ima ugodan ambijent. |
| amnestija | Vlada je proglasila amnestiju za manje prekršaje. |
| analiza | Liječnik je naručio analizu krvi. |
| analizirati | Moramo analizirati rezultate ankete. |
| anestezija | Zahvat se radi pod lokalnom anestezijom. |
| aparat | Aparat za kavu ne radi. |
| apsolvent | Apsolvent je i uskoro diplomira. |
| argument | To je dobar argument. |
| arhiva | Stari dokumenti čuvaju se u arhivi. |
| astronomija | Moj sin se zanima za astronomiju. |
| atmosfera | Na koncertu je bila odlična atmosfera. |
| atom | Sve se sastoji od atoma. |
| automatski | Vrata se otvaraju automatski. |
| autoritet | Profesor ima velik autoritet među studentima. |
| avenija | Hotel se nalazi na glavnoj aveniji. |
| baciti | Možeš li baciti ovu bocu u kantu? |
| backup | Napravi backup prije ažuriranja. |
| bajka | Mama djeci svake večeri čita bajku. |
| bankarstvo | Radi u bankarstvu već deset godina. |
| bankovni | Pošaljite mi svoj bankovni račun. |
| bankrot | Tvrtka je pred bankrotom. |
| bankrotirati | Mala trgovina je bankrotirala zbog krize. |
| barem | Pričekaj barem pet minuta. |
| bazen | Hotel ima veliki bazen. |
| beba | Beba spava, budite tiho. |
| beskoristan | Ovaj stari punjač je beskoristan. |
| besplodan | Razgovor je bio besplodan. |
| bijes | Nije mogao sakriti bijes. |
| bilo tko | Bilo tko može naučiti hrvatski. |
| bilo što | Možeš me pitati bilo što. |
| biologija | Kći studira biologiju. |
| birati | Teško mi je birati između ova dva stana. |
| birokracija | Birokracija u uredu je spora. |
| bitan | Ovaj dokument je jako bitan. |
| bitka | Ovdje se vodila poznata bitka. |
| blagajnik | Blagajnik mi je vratio krivi kusur. |
| blizak | On mi je blizak prijatelj. |
| bogatstvo | Priroda je najveće bogatstvo ove zemlje. |
| bonus | Na kraju godine dobili smo bonus. |
| boravak | Ugodan boravak u našem hotelu! |
| borba | Borba protiv bolesti je bila duga. |
| boriti se | Moramo se boriti za svoja prava. |
| brak | Moji roditelji su u braku trideset godina. |
| branitelj | Branitelj je tražio oslobađajuću presudu. |
| braniti | Odvjetnik brani optuženog. |
| brava | Brava na vratima je pokvarena. |
| brašno | Za kolač trebamo pola kile brašna. |
| briga | Hvala na brizi. |
| brinuti | Tko će brinuti o psu dok smo na moru? |
| brisati | Nemoj brisati te fotografije! |
| brojati | Moj sin već zna brojati do sto. |
| broš | Na kaputu nosi lijep broš. |
| brošura | Uzmite brošuru o izletima. |
| brzina | Ograničenje brzine je pedeset kilometara na sat. |
| bunt | Studenti su digli bunt protiv novih pravila. |
| burza | Cijene dionica na burzi su pale. |
| bučan | Ovaj kafić je previše bučan. |
| carina | Na granici smo dugo čekali na carini. |
| carinik | Carinik je pregledao naš prtljag. |
| cijeli | Cijeli dan sam radila. |
| cijepiti | Dijete moramo cijepiti protiv ospica. |
| cjelina | Grad i okolica čine jednu cjelinu. |
| dakle | Dakle, vidimo se u osam. |
| daleki | To je bilo u dalekoj prošlosti. |
| dapače | Nije mi teško, dapače, rado ću pomoći. |
| dar | Ovo je mali dar za tebe. |
| darovati | Kuću je darovao svojoj kćeri. |
| daska | Daska za glačanje je iza vrata. |
| datum | Koji je danas datum? |
| davati | Ova banka daje dobre kredite. |
| demokracija | Sloboda govora važna je za demokraciju. |
| dernjati se | Nemoj se dernjati, sve čujem. |
| detalj | Pošaljite mi sve detalje mailom. |
| dežurstvo | Liječnica ima dežurstvo ovaj vikend. |
| digitalizacija | Digitalizacija ureda trajala je godinu dana. |
| dijagnoza | Liječnik još nije postavio dijagnozu. |
| dijeliti | Stan dijelim s prijateljicom. |
| dimenzija | Koje su dimenzije ormara? |
| dio | Ovo je najljepši dio grada. |
| dionica | Kupio je dionice jedne tvrtke. |
| diploma | Diplomu sam dobila prošle godine. |
| diplomata | Njezin otac je diplomata. |
| dirigent | Dirigent je ušao na pozornicu. |
| disanje | Duboko disanje pomaže kod stresa. |
| disati | Dišite duboko, molim vas. |
| distribucija | Tvrtka se bavi distribucijom hrane. |
| diviti se | Divim se tvojoj hrabrosti. |
| dizajn | Sviđa mi se dizajn ovog stana. |
| dizajnirati | Ona dizajnira odjeću. |
| djeca | Djeca su u školi do dva. |
| djelatnost | Glavna djelatnost tvrtke je turizam. |
| djelo | Ovo je najpoznatije djelo hrvatske književnosti. |
| djelovati | Lijek počinje djelovati nakon pola sata. |
| dob | Upišite svoju dob u obrazac. |
| dobit | Tvrtka je ove godine imala veću dobit. |
| dobivati | Svaki dan dobivam puno mailova. |
| dodatak | Ljeti dobivamo dodatak na plaću. |
| dodir | Ekran reagira na dodir. |
| dodirnuti | Ne dodirujte izloške, molim. |
| dogovarati | Još dogovaramo termin sastanka. |
| dogovarati se | Još se dogovaramo oko cijene. |
| dogovor | Imamo dogovor, vidimo se u osam. |
| dogovoriti | Moramo dogovoriti cijenu. |
| dogovoriti se | Dogovorili smo se za petak. |
| dohodak | Porez na dohodak plaća se svake godine. |
| dokaz | Sačuvajte račun kao dokaz kupnje. |
| dokazati | Možete li dokazati da ste platili? |
| dokazivati | Ne moraš nikome ništa dokazivati. |
| dolazak | Javite nam vrijeme dolaska. |
| doletjeti | Ptica je doletjela na prozor. |
| dom | Studenti žive u studentskom domu. |
| domaćica | Domaćica nam je pripremila večeru. |
| domaćin | Domaćin nas je dočekao s rakijom. |
| domišljat | Moj sin je jako domišljat. |
| donirati | Odlučili smo donirati odjeću. |
| dopustiti | Neću dopustiti da kasniš. |
| doputovati | Doputovali smo u Zagreb u ponoć. |
| dopuštati | Roditelji mu ne dopuštaju izlaziti noću. |
| dosjetiti se | Napokon sam se dosjetila odgovora. |
| dostava | Dostava je besplatna za narudžbe iznad pedeset eura. |
| dostaviti | Paket će vam dostaviti sutra. |
| dostojanstvo | Svaki čovjek ima pravo na dostojanstvo. |
| dostupan | Liječnik je dostupan od osam do dva. |
| dotrčati | Pas je dotrčao do mene. |
| dovoljan | Je li ovo dovoljan iznos? |
| dovoljno | Imamo dovoljno vremena. |
| dovršiti | Moram dovršiti izvještaj do petka. |
| doza | Uzmite jednu dozu lijeka ujutro. |
| doznati | Kako si to doznala? |
| doživljaj | Putovanje na Vis bilo je pravi doživljaj. |
| društven | Daša je jako društvena osoba. |
| društvene mreže | Previše vremena provodim na društvenim mrežama. |
| društveni | Ovo je velik društveni problem. |
| društvo | Ugodno mi je u vašem društvu. |
| državljanin | On je hrvatski državljanin. |
| državljanstvo | Zatražio je hrvatsko državljanstvo. |
| dubina | Dubina bazena je dva metra. |
| dubok | Ovdje je more jako duboko. |
| dugovati | Koliko ti dugujem? |
| duhovit | Tvoj brat je jako duhovit. |
| duljina | Kolika je duljina ovog stola? |
| duša | Ona je dobra duša. |
| dužina | Dužina staze je pet kilometara. |
| dužnost | Moja dužnost je pomoći. |
| dvorište | Djeca se igraju u dvorištu. |
| džemper | Obuci džemper, hladno je. |
| ekologija | Ekologija je važna tema u školama. |
| ekonomija | Studirao je ekonomiju u Zagrebu. |
| ekonomist | Moj brat radi kao ekonomist. |
| ekonomski | Zemlja je u ekonomskoj krizi. |
| ekran na dodir | Novi mobitel ima veći ekran na dodir. |
| eksperiment | Učenici rade eksperiment iz kemije. |
| elastičan | Ovaj materijal je elastičan. |
| element | Voda je važan element života. |
| emisija | Gledam emisiju o kuhanju. |
| emocija | Teško mi je pokazati emocije. |
| enciklopedija | Taj podatak sam našao u enciklopediji. |
| energija | Nakon odmora imam puno energije. |
| epoha | To je bila zanimljiva epoha u povijesti. |
| etika | Liječnici moraju poštovati etiku. |
| evakuacija | Evakuacija zgrade počela je odmah. |
| evo | Evo, ovo je tvoja soba. |
| evolucija | U školi učimo o evoluciji. |
| faktura | Pošaljite nam fakturu za uslugu. |
| fenomen | Bura je poseban prirodni fenomen. |
| fiksan | Cijena je fiksna, nema popusta. |
| filozofija | Studirala sam filozofiju. |
| financije | Brine o financijama tvrtke. |
| financirati | Projekt financira Europska unija. |
| fizika | Fizika mi je bila teška u školi. |
| flaster | Stavi flaster na ranu. |
| fleksibilan | Imam fleksibilno radno vrijeme. |
| fond | Novac ide u fond za pomoć djeci. |
| formalni | Za razgovor za posao trebam formalnu odjeću. |
| formula | Ne sjećam se formule. |
| formular | Ispunite formular na šalteru. |
| fotograf | Fotograf nas je slikao na vjenčanju. |
| frekvencija | Na kojoj frekvenciji je radio stanica? |
| funkcija | Ova funkcija u aplikaciji je nova. |
| ga | Vidiš li ga? |
| galerija | U galeriji je nova izložba. |
| generacija | Moja generacija je odrasla bez mobitela. |
| general | General je obišao vojnike. |
| geografija | Geografija mi je bila omiljeni predmet. |
| geometrija | Sin ima zadaću iz geometrije. |
| gibak | Mačka je gipka i brza životinja. |
| gladak | Pod je gladak i sjajan. |
| glasanje | Glasanje traje do sedam navečer. |
| glasina | To je samo glasina. |
| glasovanje | Glasovanje je tajno. |
| glatak | Kamen je gladak od mora. |
| glazbenik | Na trgu svira ulični glazbenik. |
| globalni | Ovo je globalni problem. |
| globalno zatopljenje | Globalno zatopljenje mijenja klimu. |
| glumiti | Ona glumi u kazalištu. |
| glup | To je bilo glupo pitanje. |
| gorivo | Ponestalo nam je goriva. |
| gospodarstvo | Turizam je važan za hrvatsko gospodarstvo. |
| gostovati | Kazalište iz Splita gostuje u Zagrebu. |
| gotovo | Gotovo smo stigli. |
| govor | Gradonačelnik je održao kratak govor. |
| govoriti istinu | Uvijek treba govoriti istinu. |
| gradnja | Gradnja nove bolnice traje dvije godine. |
| gradonačelnik | Gradonačelnik je otvorio novi park. |
| granica | Na granici smo čekali sat vremena. |
| gravitacija | Gravitacija drži Mjesec u orbiti. |
| građanin | Svaki građanin ima pravo glasa. |
| građevinarstvo | Radi u građevinarstvu. |
| gripa | Imam gripu i ostajem kod kuće. |
| grlo | Boli me grlo. |
| grom | Grom je udario u drvo. |
| groznica | Dijete ima groznicu. |
| grozno | Vrijeme je danas grozno. |
| gubitak | Tvrtka je imala velik gubitak. |
| gubiti | Nemoj gubiti vrijeme. |
| gubitnik | Nemoj se osjećati kao gubitnik. |
| gurnuti | Vrata treba gurnuti, ne povući. |
| gust | Magla je gusta, vozi polako. |
| haker | Haker je ukrao podatke korisnika. |
| hardver | Problem nije u softveru, nego u hardveru. |
| heroj | Vatrogasci su pravi heroji. |
| hipoteza | Znanstvenici su provjerili hipotezu. |
| hitnost | Liječnik je odmah shvatio hitnost situacije. |
| hladnoća | Ne podnosim hladnoću. |
| hlađenje | Hlađenje u autu ne radi. |
| hostel | Spavali smo u hostelu blizu kolodvora. |
| hoćemo | Hoćemo li na kavu? |
| hrabar | Bio si jako hrabar. |
| hrabrost | Trebalo je puno hrabrosti za to. |
| hrapav | Zid je hrapav. |
| hvaliti | Svi hvale tvoju kuhinju. |
| ideja | Imam dobru ideju! |
| indeks | Profesor je upisao ocjenu u indeks. |
| industrija | Turizam je najvažnija industrija na obali. |
| infekcija | Liječnik mi je dao antibiotik za infekciju. |
| inflacija | Inflacija je ove godine visoka. |
| informacija | Gdje mogu dobiti informacije o vlakovima? |
| informirati | Molimo vas da nas informirate o promjenama. |
| injekcija | Medicinska sestra mi je dala injekciju. |
| inovacija | Tvrtka ulaže u inovacije. |
| insekt | Imaš li sprej protiv insekata? |
| instrument | Svirate li neki instrument? |
| interakcija | Učenje jezika traži interakciju s ljudima. |
| interes | Pokazali su velik interes za naš projekt. |
| intervju | Sutra imam intervju za posao. |
| invalid | Ovo je parkirno mjesto za invalide. |
| invalidnost | Dobiva mirovinu zbog invalidnosti. |
| inventura | Trgovina je zatvorena zbog inventure. |
| investicija | Stan je dobra investicija. |
| investirati | Želimo investirati u turizam. |
| investitor | Investitor je kupio stari hotel. |
| ishod | Ishod utakmice je neizvjestan. |
| isključiti | Molim vas, isključite mobitele. |
| isključivati | Ne zaboravi isključivati svjetlo kad izlaziš. |
| iskoristiti | Moramo iskoristiti lijepo vrijeme. |
| iskorištavati | Ne dopusti da te iskorištavaju. |
| iskren | Budi iskren sa mnom. |
| iskrenost | Cijenim tvoju iskrenost. |
| iskustvo | Imate li iskustva u prodaji? |
| isplata | Isplata plaće je petnaestog u mjesecu. |
| isplatiti | Plaću će nam isplatiti petnaestog. |
| isplivati | Istina će isplivati na površinu. |
| isporučiti | Robu ćemo isporučiti u roku od tri dana. |
| ispraviti | Možete li ispraviti moju pogrešku? |
| ispravljati | Učiteljica nam ispravlja zadaće. |
| ispričati se | Moram se ispričati Daši. |
| ispuniti | Ispunite obrazac i potpišite ga. |
| ispunjavati | Ispunjavam obrazac za vizu. |
| istek | Nakon isteka ugovora moram se iseliti. |
| isteći | Putovnica mi uskoro ističe. |
| isticati | Liječnik ističe da je odmor važan. |
| istinit | Film je snimljen prema istinitoj priči. |
| istovjetnost | Policija je utvrdila istovjetnost potpisa. |
| istraga | Policija je pokrenula istragu. |
| istražiti | Želimo istražiti otok biciklom. |
| istraživanje | Istraživanje pokazuje da ljudi manje čitaju. |
| istraživati | Volim istraživati nove gradove. |
| istraživač | On je istraživač na institutu. |
| istrčati | Dijete je istrčalo na cestu. |
| izabrati | Ne znam koju haljinu izabrati. |
| izazivati | Šećer izaziva karijes. |
| izazov | Život u novoj zemlji je velik izazov. |
| izbaviti | Vatrogasci su izbavili obitelj iz zgrade. |
| izbivati | Često izbiva s posla zbog bolesti. |
| izbjegavati | Liječnik kaže da izbjegavam slanu hranu. |
| izbjegnuti | Nesreću je bilo nemoguće izbjegnuti. |
| izbjeći | Krenuli smo rano da izbjegnemo gužvu. |
| izbori | Izbori su u svibnju. |
| izdati | Knjigu je izdala mala izdavačka kuća. |
| izdavati | Ljeti izdajemo apartman turistima. |
| izdavač | Izdavač je objavio novi roman. |
| izdržati | Ne mogu više izdržati ovu vrućinu. |
| izgledati | Izgledaš umorno. |
| izgovor | Hrvatski izgovor nije jako težak. |
| izgraditi | Ovdje će izgraditi novu školu. |
| izjava | Svjedok je dao izjavu policiji. |
| izjaviti | Ministar je izjavio da će cijene pasti. |
| izlet | U subotu idemo na izlet na Plitvice. |
| izliječiti | Ovaj lijek će izliječiti infekciju. |
| izložba | Idemo na izložbu fotografija. |
| izmišljen | Ova priča je potpuno izmišljena. |
| izmjeriti | Sestra mi je izmjerila tlak. |
| iznajmljivati | Ljeti iznajmljujemo sobe turistima. |
| iznenaditi | Htjeli smo te iznenaditi. |
| iznenađivati | Ovaj grad me stalno iznenađuje. |
| iznimka | Ovo je iznimka, a ne pravilo. |
| izraz | Ne razumijem ovaj izraz. |
| izračunati | Možete li izračunati ukupnu cijenu? |
| izum | Telefon je bio velik izum. |
| izumitelj | Nikola Tesla bio je slavni izumitelj. |
| izvještaj | Šef čeka moj izvještaj. |
| izvor | Ovo je izvor pitke vode. |
| izvor informacija | Internet je moj glavni izvor informacija. |
| izvoz | Izvoz vina raste svake godine. |
| izvrsno | Izvrsno, sve je spremno! |
| izvršavati | Uvijek izvršava zadatke na vrijeme. |
| izvršenje | Sud je odgodio izvršenje kazne. |
| izvršiti | Uplatu možete izvršiti u banci. |
| jamačno | Jamačno će doći, obećao je. |
| jamstvo | Ovaj uređaj ima dvije godine jamstva. |
| jasan | Je li vam sve jasno? |
| java | To se dogodilo na javi, a ne u snu. |
| javiti | Javit ću ti kad stignem. |
| javni | Javni prijevoz je ovdje jeftin. |
| je | Gdje je pošta? |
| jedinstven | Ovo je jedinstvena prilika. |
| jednobojan | Tražim jednobojnu majicu. |
| jednostavan | Recept je jako jednostavan. |
| jednostavno | Jednostavno nemam vremena. |
| jednostavnost | Volim jednostavnost ovog dizajna. |
| jedva | Jedva sam stigla na vlak. |
| jedva da | Jedva da ga poznajem. |
| jesi | Jesi li gladan? |
| jezikoslovlje | Hrvatsko jezikoslovlje ima dugu tradiciju. |
| junak | On je junak ove priče. |
| kamata | Kamata na kredit je četiri posto. |
| kamera | Na ulazu je kamera. |
| kamp | Ljeti spavamo u kampu kraj mora. |
| kampanja | Počela je predizborna kampanja. |
| kanal | Na kojem kanalu je utakmica? |
| kandidat | Na izborima je pet kandidata. |
| kapetan | Kapetan broda pozdravio je putnike. |
| kapital | Za otvaranje tvrtke treba kapital. |
| kapuljača | Stavi kapuljaču, pada kiša. |
| karakter | Ima jak karakter. |
| karijera | Gradi karijeru u inozemstvu. |
| katastrofa | Poplava je bila prava katastrofa. |
| kategorija | Hotel ima četiri zvjezdice, to je visoka kategorija. |
| katkad | Katkad idem na posao biciklom. |
| kazniti | Policija ga je kaznila zbog brze vožnje. |
| kašljati | Već tjedan dana kašljem. |
| kemija | Kemija mi nikad nije bila jača strana. |
| kihati | Stalno kišem zbog alergije. |
| kipar | Ivan Meštrović bio je poznati hrvatski kipar. |
| kiparstvo | Zanima me moderno kiparstvo. |
| kirurg | Kirurg je uspješno obavio operaciju. |
| kišan | Bio je to hladan i kišan dan. |
| klasificirati | Otpad treba klasificirati prije recikliranja. |
| klasičan | Volim klasičnu glazbu. |
| klasično | Uređenje stana je klasično i jednostavno. |
| klimatske promjene | Klimatske promjene utječu na poljoprivredu. |
| klimatski | Klimatski uvjeti na otoku su blagi. |
| klinika | Operacija je bila u privatnoj klinici. |
| klupa | Sjeli smo na klupu u parku. |
| književnost | Volim hrvatsku književnost. |
| knjižničar | Knjižničar mi je pomogao naći knjigu. |
| koalicija | Stranke su sklopile koaliciju. |
| kolebati se | Još se kolebam oko posla. |
| kolektiv | Imamo dobar radni kolektiv. |
| količina | Kolika je količina vode u boci? |
| koljeno | Boli me koljeno nakon trčanja. |
| komentar | Napiši komentar ispod fotografije. |
| komentirati | Ne želim to komentirati. |
| kompleksnost | Kompleksnost problema nas je iznenadila. |
| kompliciran | Ovaj obrazac je jako kompliciran. |
| kompromis | Moramo naći kompromis. |
| komunicirati | S kolegama komuniciramo mailom. |
| komunikacija | Dobra komunikacija je ključ uspjeha. |
| konačno | Konačno smo stigli! |
| koncept | Koncept restorana je zanimljiv. |
| kondukter | Kondukter je provjerio karte. |
| konferencija | Idem na konferenciju u Zagreb. |
| konkurencija | Na tržištu je velika konkurencija. |
| konkurent | Naš konkurent ima niže cijene. |
| kontaktirati | Za više informacija kontaktirajte recepciju. |
| kontrolirati | Moram kontrolirati šećer u krvi. |
| konzulat | Za vizu se javite u konzulat. |
| kopija | Trebam kopiju putovnice. |
| kopno | Trajekt vozi s otoka na kopno. |
| korak | Ovo je prvi korak. |
| koristan | Ovaj savjet je jako koristan. |
| koristiti | Smijem li koristiti vaš telefon? |
| korištenje | Korištenje mobitela u avionu nije dopušteno. |
| koža | Imam osjetljivu kožu. |
| krajolik | Krajolik u Lici je prekrasan. |
| krasti | Krasti je zločin. |
| krađa | Prijavila sam krađu policiji. |
| kreativan | Moja kći je jako kreativna. |
| kreativnost | Ovaj posao traži puno kreativnosti. |
| krema | Ne zaboravi kremu za sunčanje. |
| kretati se | Morate se više kretati. |
| krhak | Pazi, ova vaza je krhka. |
| krik | Čuo se krik iz šume. |
| kriminalac | Policija je uhvatila kriminalca. |
| kriptiranje | Kriptiranje štiti vaše podatke. |
| kritizirati | Nemoj stalno kritizirati. |
| krivica | To nije tvoja krivica. |
| krivnja | Osjećam krivnju što nisam nazvala. |
| kriza | Ekonomska kriza je pogodila sve. |
| krpa | Obriši stol mokrom krpom. |
| krut | Ova kožna jakna je još kruta. |
| krvarenje | Pritisnite ranu da zaustavite krvarenje. |
| krvariti | Rana još krvari. |
| kršiti | Ne smijete kršiti pravila. |
| kukavan | Bio je previše kukavan da kaže istinu. |
| kupac | Kupac uvijek ima pravo. |
| kustos | Kustos nas je proveo kroz muzej. |
| kvaliteta | Kvaliteta ove robe je odlična. |
| kvantiteta | Važnija je kvaliteta od kvantitete. |
| lagati | Nemoj mi lagati. |
| lakoća | Govori hrvatski s lakoćom. |
| lavina | Lavina je zatrpala cestu. |
| laž | To je laž! |
| lažan | Ovo je lažan račun. |
| led | Želite li led u piće? |
| leden | Popio sam ledeni čaj. |
| leći | Moram leći, boli me glava. |
| lice | Operi lice hladnom vodom. |
| lift | Uzmimo lift do petog kata. |
| lijen | Danas sam jako lijen. |
| liječiti | Ovaj liječnik liječi alergije. |
| lingvistika | Zanima me lingvistika. |
| list | Daj mi jedan list papira. |
| literatura | Profesor nam je dao popis literature. |
| ljepota | Ljepota ovog otoka je nevjerojatna. |
| ljubazan | Konobar je bio jako ljubazan. |
| ljubaznost | Hvala vam na ljubaznosti. |
| ljudi | Ovdje su ljudi jako ljubazni. |
| ljutiti se | Nemoj se ljutiti na mene. |
| ljutnja | Njegova ljutnja brzo je prošla. |
| logika | Ne razumijem logiku ovog pravila. |
| lokalni | Kupujemo voće na lokalnoj tržnici. |
| lom | Rendgen je pokazao lom kosti. |
| lonac | Stavi lonac s vodom na štednjak. |
| lud | Jesi li lud? Vani je oluja! |
| ludost | To je čista ludost! |
| lukav | Lisica je lukava. |
| lutati | Satima smo lutali starim gradom. |
| ma tko | Ma tko to zvoni u ponoć? |
| majstor | Zvali smo majstora da popravi bojler. |
| mana | Svatko ima neku manu. |
| manifestacija | Ljeti grad organizira mnogo kulturnih manifestacija. |
| manjina | U gradu živi i mala talijanska manjina. |
| marljiv | Ona je marljiva učenica. |
| masa | Kolač treba miješati dok masa ne postane glatka. |
| mast | Liječnik mi je prepisao mast za kožu. |
| mastan | Ova hrana je previše masna. |
| mat | Želim mat boju za zidove. |
| materijal | Od kojeg je materijala ova jakna? |
| mašta | Djeca imaju bujnu maštu. |
| maštovit | Ovo je jako maštovit crtić. |
| medij | Internet je danas najvažniji medij. |
| mediji | O tome su pisali svi mediji. |
| mehanika | Studira strojarstvo i mehaniku. |
| mekan | Ovaj krevet je jako mekan. |
| menadžer | Menadžer hotela nas je pozdravio. |
| metal | Ograda je od metala. |
| metla | Uzmi metlu i pometi pod. |
| metoda | Ovo je dobra metoda učenja. |
| metodologija | Metodologija istraživanja je jasna. |
| međutim | Htjela sam doći, međutim nisam stigla. |
| mijenjati | Mijenjam posao od sljedećeg mjeseca. |
| miješati | Miješajte juhu da ne zagori. |
| mikrofon | Govorite u mikrofon, molim vas. |
| mikrovalna | Podgrij ručak u mikrovalnoj. |
| milost | Molio je za milost. |
| ministar | Ministar zdravstva je posjetio bolnicu. |
| ministarstvo | Zahtjev treba poslati ministarstvu. |
| mir | Ostavi me na miru. |
| miran | Ovo je miran kvart. |
| miris | Volim miris kave ujutro. |
| mirisati | Kruh lijepo miriše. |
| miriti se | Brat i sestra se brzo mire nakon svađe. |
| mirovati | Nakon operacije morate mirovati. |
| misao | To je lijepa misao. |
| misija | Njegova misija je pomagati drugima. |
| misterija | Njegov nestanak je i dalje misterija. |
| mjera | Vlada je uvela nove mjere. |
| mjeriti | Mjeri sobu prije kupnje namještaja. |
| mjeriti temperaturu | Moram djetetu mjeriti temperaturu svaka tri sata. |
| mještanin | Jedan mještanin nam je pokazao put. |
| mladić | Mladić mi je pomogao s koferom. |
| mladost | U mladosti sam puno putovao. |
| model | Koji model auta voziš? |
| modernizacija | Modernizacija željeznice je počela. |
| modernizirati | Žele modernizirati staru tvornicu. |
| moderno | Stan je moderno uređen. |
| mogućnost | Postoji mogućnost da padne kiša. |
| mokar | Kosa mi je još mokra. |
| molba | Predao sam molbu za posao. |
| molekula | Molekula vode ima tri atoma. |
| momak | Tko je onaj momak? |
| momčad | Naša momčad je pobijedila. |
| monolog | Glumac je izveo dugi monolog. |
| moral | Ova priča ima jasan moral. |
| moram | Moram ići, kasnim. |
| mornar | Mornar je radio na brodu dvadeset godina. |
| motel | Prenoćili smo u motelu uz autocestu. |
| moć | Novac ne daje uvijek moć. |
| moćan | Ovo je moćno računalo. |
| mrak | Vani je već mrak. |
| mrtav | Nakon puta bio sam mrtav umoran. |
| mrziti | Mrzim čekati. |
| mržnja | Mržnja ništa ne rješava. |
| mudar | Moj djed je bio mudar čovjek. |
| mudrost | Starost donosi mudrost. |
| mučiti | Muči me jedan problem. |
| mušterija | Konobar je donio račun mušteriji. |
| nabava | Nabava novih računala kasni. |
| nacija | Cijela nacija je slavila pobjedu. |
| nacionalni | Plitvice su nacionalni park. |
| nacrt | Arhitekt nam je pokazao nacrt kuće. |
| nada | Nada umire posljednja. |
| nadati se | Nadam se da ćeš doći. |
| nadesno | Na raskrižju skrenite nadesno. |
| nadležnost | To nije u nadležnosti ovog ureda. |
| naglas | Pročitaj tekst naglas. |
| naglasak | Gdje je naglasak u ovoj riječi? |
| naglasiti | Želim naglasiti jednu stvar. |
| naglašavati | Šef stalno naglašava važnost točnosti. |
| nagrada | Dobila je nagradu za najbolju priču. |
| nagraditi | Šef nas je nagradio slobodnim danom. |
| naivan | Bio sam naivan i povjerovao mu. |
| nakit | Ne nosim puno nakita. |
| nakon | Nakon ručka idemo na kavu. |
| nalijevo | Kod crkve skrenite nalijevo. |
| namjera | Nisam imala namjeru te uvrijediti. |
| namjerno | Nisam to namjerno napravio. |
| namjestiti | Moram namjestiti sat na mobitelu. |
| napad | Napad je bio iznenadan. |
| napadati | Pas ne napada ljude. |
| napasti | Lopov ga je napao na ulici. |
| napet | Film je bio jako napet. |
| napokon | Napokon je stiglo ljeto! |
| napor | Uložila je puno napora u projekt. |
| napredak | Vidim velik napredak u tvom hrvatskom. |
| napredovanje | Čekam napredovanje na poslu. |
| napredovati | Brzo napreduješ u učenju. |
| naprosto | To je naprosto nemoguće. |
| naprotiv | Nisam umorna, naprotiv! |
| narukvica | Ovu narukvicu sam kupila u Dubrovniku. |
| nasilje | Nasilje nikad nije rješenje. |
| naslov | Kako glasi naslov knjige? |
| nasmijati | Uvijek me uspiješ nasmijati. |
| nastajati | Gužve nastaju svako jutro. |
| nastati | Problem je nastao zbog kvara. |
| nastavljati | Unatoč kiši, nastavljamo šetnju. |
| nastojati | Nastojim svaki dan čitati na hrvatskom. |
| natjecanje | Pobijedila je na natjecanju. |
| natjecatelj | Natjecatelji su spremni. |
| natjecati se | Natječemo se za prvo mjesto. |
| natječaj | Prijavila sam se na natječaj za posao. |
| naučiti | Želim naučiti hrvatski. |
| naušnice | Lijepe su ti naušnice! |
| navlaš | Navlaš me ne slušaš! |
| navodno | Navodno će sutra padati kiša. |
| nazadovati | Bez vježbe znanje nazaduje. |
| nazočiti | Ministar će nazočiti otvaranju. |
| neboder | Ured je na desetom katu nebodera. |
| nedostajati | Nedostaješ mi. |
| nedostatak | Jedini nedostatak stana je buka. |
| nedostupan | Broj koji ste birali je nedostupan. |
| neformalan | Sastanak je bio neformalan. |
| neiskren | Njegov osmijeh je neiskren. |
| nejasan | Odgovor je nejasan. |
| neke | Neke trgovine rade nedjeljom. |
| neljubazan | Prodavač je bio neljubazan. |
| nemoćan | Osjećao sam se nemoćno. |
| neobičan | Imaš neobično ime. |
| neodlučan | Kad kupujem odjeću, jako sam neodlučna. |
| neophodan | Za ulaz je neophodan dokument. |
| neoprezan | Bio je neoprezan na cesti. |
| neovisan | Želim biti financijski neovisan. |
| nepažljiv | Bio sam nepažljiv i razbio čašu. |
| nepoznat | Ovaj broj mi je nepoznat. |
| nepošten | To je nepošten postupak. |
| nepravda | To je velika nepravda. |
| neprijatelj | Nemaš ovdje neprijatelja. |
| neproziran | Kupila sam neprozirne zavjese. |
| nerazuman | To je nerazuman zahtjev. |
| nered | U sobi je strašan nered. |
| nesiguran | Još sam nesigurna u hrvatskom. |
| nesposoban | Osjećao se nesposobnim za taj posao. |
| nespreman | Bila sam potpuno nespremna za ispit. |
| nesreća | Na autocesti se dogodila prometna nesreća. |
| nestabilan | Vrijeme je ovih dana nestabilno. |
| nestajati | Nestaje mi strpljenja. |
| nestati | Struja je nestala na sat vremena. |
| nestrpljiv | Ne budi tako nestrpljiv. |
| nesvijest | Pala je u nesvijest od vrućine. |
| nesvjestica | Na vrućini sam osjetila nesvjesticu. |
| netočan | Ovaj podatak je netočan. |
| netočno | Odgovorio je netočno na pitanje. |
| neugodan | Imao sam neugodan razgovor sa šefom. |
| neuredan | Stol mu je uvijek neuredan. |
| neuspjeh | Neuspjeh je dio učenja. |
| neuspješan | Prvi pokušaj je bio neuspješan. |
| neučinkovit | Stari sustav je bio neučinkovit. |
| nevin | Sud je zaključio da je nevin. |
| nevinost | Odvjetnik je dokazao njegovu nevinost. |
| nevjerojatan | Pogled s brda je nevjerojatan. |
| nezadovoljan | Gost je bio nezadovoljan sobom. |
| nezaposlenost | Nezaposlenost je ove godine manja. |
| nezreo | Ove breskve su još nezrele. |
| nizina | Slavonija je velika nizina. |
| ništavan | Ugovor je proglašen ništavnim. |
| norma | Pravopis propisuje jezičnu normu. |
| novinarstvo | Studira novinarstvo. |
| novine | Djed svako jutro čita novine. |
| noćenje | Noćenje s doručkom košta osamdeset eura. |
| obavijest | Na vratima je obavijest o radnom vremenu. |
| obavijestiti | Molim vas, obavijestite me o promjenama. |
| obavještavati | Redovito vas obavještavamo o novostima. |
| obećanje | Održao je obećanje. |
| obećavati | Ne obećavaj ono što ne možeš ispuniti. |
| običaj | To je stari dalmatinski običaj. |
| običan | Bio je to običan dan. |
| objava | Pročitao sam tvoju objavu na Facebooku. |
| objašnjenje | Hvala na objašnjenju. |
| objekt | Objekt je pod videonadzorom. |
| oblik | Kolač je u obliku srca. |
| obnavljati | Grad obnavlja stari most. |
| obnoviti | Moram obnoviti osobnu iskaznicu. |
| obožavati | Obožavam more. |
| obrana | Naša obrana je danas igrala odlično. |
| obrazovanje | Obrazovanje je besplatno. |
| obrt | Otvorio je obrt za popravak računala. |
| obrtnik | Obrtnik je popravio krov. |
| obuhvatiti | Izvještaj mora obuhvatiti sve troškove. |
| obuhvaćati | Cijena obuhvaća prijevoz i smještaj. |
| obujam | Obujam posla se povećao. |
| obuća | Na plaži trebate udobnu obuću. |
| obveza | Danas imam puno obveza. |
| ocean | Nikad nisam vidjela ocean. |
| ocijeniti | Molimo vas da ocijenite našu uslugu. |
| ocjenjivati | Profesor ocjenjuje ispite. |
| odbaciti | Nemoj odmah odbaciti tu ideju. |
| odbijati | Dijete odbija jesti povrće. |
| odbijenica | Dobio sam odbijenicu za posao. |
| odbiti | Morala sam odbiti poziv. |
| odbojan | Njegovo ponašanje je odbojno. |
| odgađati | Ne odgađaj posjet liječniku. |
| odgoditi | Moramo odgoditi sastanak. |
| odgovoran | Tko je odgovoran za ovo? |
| odgovornost | Preuzimam punu odgovornost. |
| odjava | Odjava iz hotela je do jedanaest sati. |
| odjaviti | Moram odjaviti stari auto. |
| odjaviti se | Moramo se odjaviti iz hotela do podne. |
| odlazak | Moj odlazak je u nedjelju. |
| odlaziti | Kad odlaziš na godišnji? |
| odletjeti | Avion je odletio na vrijeme. |
| odluka | To je bila teška odluka. |
| odlučan | Odlučna je da uspije. |
| odlučiti | Odlučila sam ostati u Zagrebu. |
| odlučivati | O tome ne odlučujem ja. |
| odmoran | Nakon godišnjeg sam odmoran. |
| odnos | Imamo dobar odnos sa susjedima. |
| odobravati | Roditelji ne odobravaju moj plan. |
| odobrenje | Za gradnju trebate odobrenje. |
| odobriti | Banka mi je odobrila kredit. |
| odredba | Prema odredbi zakona morate platiti porez. |
| odrediti | Liječnik će odrediti terapiju. |
| odredište | Stigli ste na odredište. |
| održati | Sastanak ćemo održati u petak. |
| održavati | Tko održava zgradu? |
| održivost | Tvrtka brine o održivosti. |
| odustajati | Nemoj odustajati! |
| odustati | Ne smiješ sada odustati. |
| oduševiti | Predstava je oduševila publiku. |
| odvajati | Odvajamo otpad za recikliranje. |
| odvjetnik | Trebam dobrog odvjetnika. |
| odvjetništvo | Radi u odvjetništvu. |
| odvojeno | Možemo li platiti odvojeno? |
| odvojenost | Odvojenost od obitelji je teška. |
| odšteta | Dobili smo odštetu za izgubljenu prtljagu. |
| ogledalo | Pogledaj se u ogledalo. |
| ograda | Pas je preskočio ogradu. |
| ohol | Njegov ohol stav smeta kolegama. |
| ohrabriti | Tvoje riječi su me ohrabrile. |
| oklijevati | Nemoj oklijevati, nazovi ga. |
| okolica | Okolica Zagreba je lijepa za izlete. |
| okolina | Djeca se brzo prilagode novoj okolini. |
| okoliš | Moramo čuvati okoliš. |
| okolnost | Zbog nepredviđenih okolnosti let je otkazan. |
| okolo | Moramo ići okolo, cesta je zatvorena. |
| okriviti | Okrivili su ga za nesreću. |
| okruglo | Taj stan košta okruglo sto tisuća eura. |
| okruženje | Radim u ugodnom okruženju. |
| okus | Ovaj sladoled ima okus jagode. |
| okusiti | Okusi ovu juhu. |
| olakšanje | Kakvo olakšanje! |
| olakšati | Ova aplikacija može olakšati život. |
| omesti | Buka me može omesti u radu. |
| omogućavati | Ova aplikacija omogućava plaćanje mobitelom. |
| omogućiti | Stipendija mi je omogućila studij. |
| onak | Bilo je onak, ništa posebno. |
| opeklina | Ova krema pomaže kod opekline. |
| operacija | Operacija je prošla dobro. |
| operirati | Sutra ga operiraju. |
| opisati | Možete li opisati lopova? |
| opisivati | Knjiga opisuje život na otoku. |
| oporavak | Oporavak će trajati mjesec dana. |
| oporaviti se | Brzo se oporavi! |
| oporba | Oporba je kritizirala vladu. |
| oprati | Moram oprati kosu. |
| opravdati | Kako ćeš opravdati izostanak? |
| opraštati | Teško mi je opraštati laži. |
| oprostiti | Možeš li mi oprostiti? |
| opskrba | Opskrba vodom je prekinuta. |
| opstati | Mali dućani teško opstaju. |
| optika | Naočale sam kupila u optici. |
| optuženi | Optuženi se nije pojavio na sudu. |
| optužiti | Optužili su ga za krađu. |
| opustiti se | Sjedni i opusti se. |
| opuštanje | Ovaj vikend je samo za opuštanje. |
| opušten | Na moru sam uvijek opušten. |
| opći | Imam opći dojam da je sve u redu. |
| općina | Općina je obnovila cestu. |
| ordinacija | Ordinacija radi popodne. |
| organizacija | Organizacija putovanja trajala je tjednima. |
| organizator | Organizator koncerta je otkazao nastup. |
| organizirati | Organiziramo zabavu za Dašin rođendan. |
| osiguranje | Trebam zdravstveno osiguranje. |
| osjetiti | Osjetila sam miris mora. |
| osjetiti bol | Pri hodanju sam osjetila bol u nozi. |
| osjećaj | Imam dobar osjećaj u vezi s tim. |
| osjećati | Osjećam se bolje. |
| osloboditi | Policija je oslobodila taoce. |
| osloboditi se | Moram se osloboditi stresa. |
| oslonac | Obitelj mi je najveći oslonac. |
| osmijeh | Imaš lijep osmijeh. |
| osmisliti | Moramo osmisliti novu kampanju. |
| osoba | Stol za četiri osobe, molim. |
| osoblje | Osoblje hotela je jako ljubazno. |
| osposobljen | Osoblje je osposobljeno za prvu pomoć. |
| ostajati | Ne ostajem dugo, samo pet minuta. |
| ostaviti | Gdje mogu ostaviti prtljagu? |
| ostvariti | Ostvarila sam svoj san. |
| osuditi | Sud ga je osudio na dvije godine. |
| osuđivati | Nemoj osuđivati ljude. |
| osvetiti se | Htio se osvetiti, ali se predomislio. |
| otežati | Kiša će otežati promet. |
| otkaz | Dao je otkaz na poslu. |
| otkazati | Moram otkazati rezervaciju. |
| otključati | Ne mogu otključati vrata. |
| otkriti | Ne smiješ nikome otkriti tajnu. |
| otkrivati | Svaki dan otkrivam nešto novo. |
| otkriće | Ovo otkriće je promijenilo medicinu. |
| otpad | Otpad odvajamo po bojama kontejnera. |
| otpor | Plan je naišao na otpor. |
| otpremnica | Otpremnica je u paketu. |
| otputovati | Sutra otputujem na more. |
| otrčati | Dijete je otrčalo do mame. |
| otvarati | Trgovina se otvara u osam. |
| ovisan | Previše sam ovisan o mobitelu. |
| ovisiti | Sve ovisi o vremenu. |
| ozbiljan | Ovo je ozbiljan problem. |
| ozdraviti | Nadam se da ćeš brzo ozdraviti. |
| ozlijediti | Pazi da ne ozlijediš ruku. |
| ozljeda | Ozljeda koljena nije teška. |
| očaj | U očaju je nazvao policiju. |
| očarati | Dubrovnik će te očarati. |
| očekivanje | Film je ispunio moja očekivanja. |
| očigledan | Odgovor je očigledan. |
| oštar | Pazi, nož je oštar! |
| pacijent | Pacijent čeka u čekaonici. |
| pakirati | Sutra putujem, moram pakirati kofer. |
| pakt | Države su potpisale pakt. |
| pametan | Tvoj sin je jako pametan. |
| pamćenje | Imam loše pamćenje za imena. |
| papirologija | Papirologija za boravak traje mjesecima. |
| paragraf | Pročitaj prvi paragraf. |
| parkirati | Gdje mogu parkirati? |
| parlament | Parlament je izglasao novi zakon. |
| partner | Moj partner radi u Splitu. |
| partnerica | Ovo je moja partnerica Darja. |
| partnerstvo | Dvije tvrtke su sklopile partnerstvo. |
| pasivnost | Njegova pasivnost me ljuti. |
| pasti u nesvijest | Od vrućine je mogla pasti u nesvijest. |
| patiti | Pati od glavobolje. |
| pauza | Napravimo pauzu od deset minuta. |
| paziti | Pazite na stepenice! |
| pažljiv | Budi pažljiv s tim staklom. |
| pedagogija | Studirala je pedagogiju. |
| pegla | Pegla je u ormaru. |
| peglati | Ne volim peglati košulje. |
| periferija | Živimo na periferiji grada. |
| peći | Baka peče kruh svake subote. |
| pečat | Na dokumentu nedostaje pečat. |
| pijesak | Djeca se igraju u pijesku. |
| pilot | Pilot je najavio slijetanje. |
| pisac | On je poznati hrvatski pisac. |
| pista | Avion je na pisti. |
| pjesma | Ova pjesma mi se jako sviđa. |
| pjesnik | Tin Ujević je poznati hrvatski pjesnik. |
| pješak | Pješak ima prednost na zebri. |
| pješačiti | Volimo pješačiti po planinama. |
| plah | Mačka je jako plaha. |
| plakanje | Nakon plakanja dijete je zaspalo. |
| plastika | Plastiku bacamo u žuti kontejner. |
| plaćati | Režije plaćam preko aplikacije. |
| plač | Iz sobe se čuo plač djeteta. |
| plašljiv | Naš pas je plašljiv. |
| ples | Idemo na tečaj plesa. |
| plesti | Baka plete džemper. |
| plin | Osjećam miris plina! |
| plitak | Ovdje je more plitko, idealno za djecu. |
| plitkoća | Zbog plitkoće uvale brodovi ne mogu ući. |
| plod | Ovo drvo daje slatke plodove. |
| plodonosan | Bio je to plodonosan sastanak. |
| pobijediti | Naša momčad je pobijedila tri nula. |
| pobjednik | Tko je pobjednik utakmice? |
| pobjeći | Pas je pobjegao iz dvorišta. |
| poboljšati | Želim poboljšati svoj hrvatski. |
| poboljšavati | Svaki dan poboljšavam svoj hrvatski. |
| pod | Pod je mokar, pazi! |
| podaci | Unesite svoje podatke u obrazac. |
| podijeliti | Podijelimo račun na pola. |
| podizati | Ne smijem podizati teške stvari. |
| podići | Moram podići novac na bankomatu. |
| podnijeti | Ne mogu podnijeti ovu buku. |
| podrška | Hvala vam na podršci. |
| podržati | Uvijek ću te podržati. |
| podsvijest | Strah se skriva u podsvijesti. |
| poduzetnik | Moj otac je poduzetnik. |
| poduzetništvo | Država potiče malo poduzetništvo. |
| poduzeće | Radim u malom poduzeću. |
| poglavlje | Pročitaj prvo poglavlje do sutra. |
| pogled | Soba ima pogled na more. |
| pogoršati | Hladnoća može pogoršati kašalj. |
| pogrešan | Ušli smo u pogrešan autobus. |
| pogreška | Ispričavam se, to je moja pogreška. |
| pohrana | Fotografije su na pohrani u oblaku. |
| pohvaliti | Šef me pohvalio za projekt. |
| pohvaljivati | Učiteljica često pohvaljuje mog sina. |
| pojasniti | Možete li pojasniti ovo pravilo? |
| pojaviti se | Problem se pojavio nakon ažuriranja. |
| pojedini | Pojedini vlakovi ne voze nedjeljom. |
| pokazivati | Navigacija pokazuje krivi put. |
| poklon | Kupila sam poklon za mamu. |
| pokloniti | Što ćemo pokloniti Daši za rođendan? |
| poklopac | Stavi poklopac na lonac. |
| pokopati | Djeda su pokopali u rodnom selu. |
| pokus | Na satu kemije radili smo pokus. |
| pokušavati | Već sat vremena pokušavam nazvati. |
| pokvaren | Hladnjak je pokvaren. |
| pola | Vidimo se u pola osam. |
| polaziti | Vlak polazi s drugog perona. |
| polica | Knjige su na gornjoj polici. |
| politika | Ne zanima me politika. |
| politički | To je politički problem. |
| poljoprivreda | Slavonija je poznata po poljoprivredi. |
| položaj | Kuća ima odličan položaj uz more. |
| pomaknuti | Možete li pomaknuti auto? |
| pomilovanje | Predsjednik je odbio zahtjev za pomilovanje. |
| pomilovati | Dijete je pomilovalo mačku. |
| pomiriti se | Napokon su se pomirili. |
| pomorac | Moj djed je bio pomorac. |
| pomoć | Hvala vam na pomoći. |
| ponašanje | Njegovo ponašanje je neprihvatljivo. |
| ponašati se | Djeca se lijepo ponašaju. |
| ponijeti | Ne zaboravi ponijeti kišobran. |
| ponosan | Ponosan sam na tebe. |
| ponuda | Imamo posebnu ponudu za obitelji. |
| popiti | Idemo popiti kavu. |
| poplava | Poplava je uništila polja. |
| porast | Bilježimo porast broja turista. |
| poraz | Ovaj poraz je bio težak. |
| porez | Porez je uključen u cijenu. |
| poricati | Optuženi poriče krađu. |
| porota | Porota je donijela odluku. |
| poseban | Danas je poseban dan. |
| posjećivati | Ljeti često posjećujem baku na otoku. |
| posljedica | To je posljedica loše odluke. |
| poslodavac | Poslodavac mi je dao slobodan dan. |
| poslodavatelj | Poslodavatelj mora prijaviti radnika. |
| poslovanje | Tvrtka je proširila poslovanje. |
| poslušan | Naš pas je jako poslušan. |
| postizati | Učenici postižu dobre rezultate. |
| postići | Želim postići razinu B1. |
| postojati | Postoji li jeftiniji let? |
| posuditi | Možeš li mi posuditi olovku? |
| posuđivati | Ne volim posuđivati novac. |
| posvađati se | Jučer sam se posvađala s bratom. |
| posvetiti se | Želim se posvetiti obitelji. |
| posvuda | Posvuda je bilo turista. |
| potez | To je bio pametan potez. |
| potomak | On je potomak poznate obitelji. |
| potonuti | Brod je potonuo kraj otoka. |
| potražnja | Potražnja za stanovima je velika. |
| potreba | Nema potrebe za brigom. |
| potreban | Je li potreban dokument s fotografijom? |
| potres | Potres se osjetio u cijelom gradu. |
| potrošač | Potrošači traže niže cijene. |
| potvrditi | Molim vas, potvrdite rezervaciju. |
| poučavati | Ona poučava djecu engleski. |
| povezanost | Povezanost otoka s kopnom je dobra. |
| povezati | Povezat ću vas s kolegom. |
| povećati se | Broj stanovnika se povećao. |
| povećavati | Grad povećava broj autobusa. |
| povijest | Zanima me hrvatska povijest. |
| povjerenje | Imam povjerenja u tebe. |
| povjerovati | Nisam mogla povjerovati. |
| povod | Koji je povod za proslavu? |
| povući | Vrata treba povući prema sebi. |
| pozivati | Pozivamo vas na našu proslavu. |
| pozivnica | Dobili smo pozivnicu za vjenčanje. |
| poznanik | On nije prijatelj, samo poznanik. |
| poznat | Ovaj restoran je poznat po ribi. |
| pozornica | Glumci su izašli na pozornicu. |
| pozvati hitnu pomoć | Brzo, moramo pozvati hitnu pomoć! |
| poći | Moram poći ranije. |
| pošten | On je pošten čovjek. |
| poštenje | Cijenim njegovo poštenje. |
| poštovanje | S poštovanjem, Darja Petrenko. |
| poštovati | Treba poštovati pravila. |
| požar | Požar je izbio u šumi. |
| požuriti | Moramo požuriti, vlak polazi! |
| požurivati | Nemoj me požurivati! |
| prag | Ostavi cipele na pragu. |
| praksa | Ljeti radim praksu u hotelu. |
| prav | Ovaj zid nije prav. |
| prava | Svi imamo jednaka prava. |
| pravda | Tražimo pravdu. |
| pravednost | Pravednost je važna u svakom sudu. |
| pravilo | Ovo pravilo vrijedi za sve. |
| pravilo igre | Objasni mi pravilo igre. |
| pravnik | Moja sestra je pravnik. |
| pravomoćnost | Presuda je postala pravomoćna. |
| pravopis | Provjeri pravopis u tekstu. |
| prazan | Hladnjak je prazan. |
| praznik | Sutra je praznik, banke ne rade. |
| preboljeti | Trebalo mi je vremena da preboljem rastanak. |
| predak | Moji preci su došli iz Like. |
| predati | Morate predati zahtjev do petka. |
| predavač | Predavač je kasnio deset minuta. |
| predložiti | Mogu li nešto predložiti? |
| prednost | Pješaci imaju prednost. |
| predomisliti se | Predomislila sam se, ostajem. |
| predsjednik | Predsjednik je održao govor. |
| predstava | Predstava počinje u osam. |
| predstaviti se | Dopustite da se predstavim. |
| predstavljati | Ovaj projekt predstavlja velik izazov. |
| predstavnik | Razgovarao sam s predstavnikom tvrtke. |
| predvidjeti | Nitko nije mogao predvidjeti ovu situaciju. |
| predviđati | Prognoza predviđa kišu. |
| preferirati | Preferiram čaj umjesto kave. |
| pregledati | Liječnik mora pregledati dijete. |
| pregovarati | Sindikat pregovara s upravom. |
| pregovor | Pregovor o cijeni trajao je dugo. |
| pregovori | Pregovori traju već tjedan dana. |
| prekinuti | Ne prekidaj me dok govorim. |
| preko | Idemo preko mosta. |
| prekršaj | Prolazak kroz crveno je prekršaj. |
| prelaziti | Djeca prelaze cestu na zebri. |
| premijer | Premijer je posjetio poplavljena područja. |
| preporuka | Imate li preporuku za dobar restoran? |
| prepoznati | Nisam te prepoznala! |
| prespavati | Možemo li prespavati kod vas? |
| prestrašiti | Prestrašio si me! |
| presuda | Presuda će biti izrečena sutra. |
| pretpostaviti | Pretpostavimo da vlak kasni sat vremena. |
| pretpostavljati | Pretpostavljam da ćeš doći kasnije. |
| pretvarati se | Ne pretvaraj se da spavaš. |
| preuzeti | Paket možete preuzeti na pošti. |
| preuzimanje | Preuzimanje paketa je moguće do šest. |
| preuzimati | Aplikacija se predugo preuzima. |
| prevariti | Prodavač me prevario. |
| prevoditelj | Trebam sudskog prevoditelja. |
| prezentacija | Sutra imam prezentaciju na poslu. |
| prezirati | Prezirem laž. |
| preživjeti | Svi putnici su preživjeli nesreću. |
| preživljavati | Mnoge obitelji teško preživljavaju. |
| prigovor | Imam prigovor na račun. |
| prihod | Prihod od turizma je porastao. |
| prihvatiti | Prihvatila sam ponudu za posao. |
| prihvaćati | Prihvaćate li kartice? |
| prijateljstvo | Naše prijateljstvo traje dvadeset godina. |
| prijaviti | Moram prijaviti boravak u policiji. |
| prijaviti se | Prijavila sam se na tečaj hrvatskog. |
| prijenos | Prijenos utakmice je na prvom programu. |
| prijetnja | Policija je shvatila prijetnju ozbiljno. |
| prilagoditi | Prilagodit ćemo plan vašim željama. |
| prilagoditi se | Brzo sam se prilagodila novom poslu. |
| prilagođavati | Polako se prilagođavamo životu ovdje. |
| primijetiti | Nisam primijetio da si se ošišala. |
| primiti | Jeste li primili moj mail? |
| primjer | Možete li dati primjer? |
| primjećivati | Počinjem primjećivati razlike u naglasku. |
| princip | Iz principa ne radim nedjeljom. |
| prioritet | Zdravlje mi je prioritet. |
| pripadati | Kome pripada ovaj kaput? |
| priručnik | Pročitaj priručnik za uređaj. |
| prisjetiti se | Pokušaj se prisjetiti gdje si ostavio ključeve. |
| pristojba | Za putovnicu se plaća pristojba. |
| pristojnost | Pristojnost ništa ne košta. |
| prisustvovati | Moram prisustvovati sastanku. |
| pritisak | Na poslu sam pod velikim pritiskom. |
| pritisnuti | Pritisnite zeleni gumb. |
| privatan | Ovo je privatan parking. |
| privatni | Ovo je privatni posjed. |
| privlačan | Ponuda je jako privlačna. |
| privući | Moramo privući više turista. |
| priznati | Priznajem, pogriješio sam. |
| proces | Proces dobivanja vize je dug. |
| procijeniti | Teško je procijeniti cijenu. |
| produženje | Zatražio sam produženje vize. |
| profil | Ažuriraj svoj profil. |
| programirati | Moj sin zna programirati. |
| proizvod | Ovo je domaći proizvod. |
| proizvoditi | Ova tvornica proizvodi namještaj. |
| proizvodnja | Proizvodnja maslinova ulja je porasla. |
| projektirati | Arhitekt projektira novu školu. |
| promet | U centru je gust promet. |
| promijeniti | Želim promijeniti rezervaciju. |
| promijeniti se | Grad se jako promijenio. |
| promisliti | Promisli prije nego što odgovoriš. |
| pronalaziti | Uvijek pronalaziš izgovor. |
| propasti | Plan je propao. |
| propis | Prema propisima, pušenje je zabranjeno. |
| propisati | Liječnik mi je propisao antibiotik. |
| proputovati | Proputovali smo cijelu Dalmaciju. |
| proračun | Proračun za putovanje je ograničen. |
| proslava | Proslava je u subotu u osam. |
| prostor | U autu nema prostora za kofer. |
| prosvjed | Na trgu je bio prosvjed. |
| protiv | Jesi li za ili protiv? |
| protivnik | Protivnik je bio jak. |
| protudjelovanje | Svaka akcija izaziva protudjelovanje. |
| provesti | Želim provesti ljeto na moru. |
| provizija | Banka naplaćuje proviziju. |
| provoditi | Vikende provodim s obitelji. |
| proziran | Voda je prozirna poput stakla. |
| prošetati se | Idemo se prošetati uz more. |
| proširivati | Tvrtka proširuje poslovanje. |
| prošlost | To je sada prošlost. |
| prsten | Dobila je zaručnički prsten. |
| pružiti prvu pomoć | Svi bi trebali znati pružiti prvu pomoć. |
| prvenstvo | Gledamo svjetsko prvenstvo u nogometu. |
| pržiti | Ribu ćemo pržiti na maslinovom ulju. |
| psihologija | Studiram psihologiju. |
| publika | Publika je pljeskala pet minuta. |
| puls | Liječnik mi je izmjerio puls. |
| pustiti | Pusti me da prođem. |
| radišan | Naš novi kolega je radišan. |
| radnik | Radnici popravljaju cestu. |
| radno mjesto | Ovo je moje radno mjesto. |
| radost | Djeca su s radošću otvorila poklone. |
| raketa | Raketa je poletjela u svemir. |
| rana | Rana brzo zacjeljuje. |
| rashod | Rashodi su veći od prihoda. |
| raskid | Raskid ugovora mora biti pisan. |
| raskrižje | Na raskrižju skrenite lijevo. |
| rasplakati | Film me rasplakao. |
| raspoloženje | Danas sam dobrog raspoloženja. |
| rasprava | Rasprava je trajala satima. |
| raspravljati | O tome ćemo raspravljati sutra. |
| rasprodaja | Na rasprodaji sam kupila jaknu. |
| raspršiti | Vjetar je raspršio oblake. |
| rastaviti | Moramo rastaviti ormar prije selidbe. |
| rasti | Cijene stalno rastu. |
| rat | Rat je završio prije više od trideset godina. |
| rata | Mjesečna rata kredita je tristo eura. |
| ravnatelj | Ravnatelj škole je razgovarao s roditeljima. |
| ravnateljstvo | Ravnateljstvo škole je donijelo odluku. |
| ravnoteža | Izgubio je ravnotežu i pao. |
| razboljeti se | Razboljela sam se nakon puta. |
| razdijeliti | Razdijelite letke prolaznicima. |
| razdoblje | To je bilo teško razdoblje. |
| razdvojiti | Razdvojite bijelo i šareno rublje. |
| razina | Na kojoj ste razini hrvatskog? |
| razlika | Koja je razlika između ove dvije riječi? |
| razlikovati se | Dijalekti se jako razlikuju. |
| različitost | Poštujemo različitost. |
| razljutiti | Njegov odgovor me razljutio. |
| razmisliti | Moram razmisliti o tome. |
| razmišljati | Razmišljam o selidbi u Split. |
| razmjena | Bio sam na razmjeni studenata u Zagrebu. |
| raznolikost | Hrvatska je poznata po raznolikosti krajolika. |
| razočaranje | Film je bio pravo razočaranje. |
| razočarati | Nemoj me razočarati. |
| razred | U razredu ima dvadeset učenika. |
| razviti | Tvrtka je razvila novu aplikaciju. |
| razviti se | Grad se brzo razvio. |
| razvod | Nakon razvoda se preselila u Split. |
| razvoj | Razvoj djeteta je brz. |
| razvrstati | Razvrstajte otpad po vrsti. |
| računati | Možeš računati na mene. |
| računovođa | Računovođa priprema godišnji izvještaj. |
| reakcija | Kakva je bila njegova reakcija? |
| reciklaža | Reciklaža je obavezna u našoj zgradi. |
| recikliranje | Recikliranje plastike je važno. |
| redak | Pročitajte treći redak. |
| redatelj | Redatelj je dobio nagradu. |
| referendum | Održan je referendum o ulasku u Europsku uniju. |
| reforma | Vlada najavljuje reformu zdravstva. |
| registar | Tvrtka je upisana u sudski registar. |
| registrirati | Moram registrirati auto. |
| reklama | Na televiziji ima previše reklama. |
| resurs | Voda je dragocjen resurs. |
| revolucija | Internet je bio prava revolucija. |
| rezati | Nož ne reže dobro. |
| rezultat | Kakvi su rezultati pretrage? |
| rečenica | Prevedite ovu rečenicu. |
| režirati | Film je režirala poznata redateljica. |
| ribar | Ribar je ujutro donio svježu ribu. |
| ribarstvo | Ribarstvo je važno za otoke. |
| rijedak | Ovo je rijedak cvijet. |
| riješiti | Moramo riješiti ovaj problem. |
| rizik | Ne želim preuzeti taj rizik. |
| rješenje problema | Našli smo rješenje problema. |
| rob | Ne želim biti rob svog posla. |
| roba | Roba stiže u ponedjeljak. |
| robot | Robot usisava stan. |
| rodbina | Za Božić dolazi sva rodbina. |
| roditelj | Svaki roditelj želi najbolje za dijete. |
| roditi se | Rodila sam se u Kijevu. |
| rodni list | Za putovnicu trebate rodni list. |
| roman | Čitam novi roman. |
| ropstvo | Ropstvo je davno ukinuto. |
| rođakinja | Moja rođakinja živi u Rijeci. |
| rođenje | Datum rođenja upišite ovdje. |
| rudarstvo | Labin ima dugu tradiciju rudarstva. |
| rukovodstvo | Rukovodstvo je promijenilo pravila. |
| ruksak | Spakiraj ruksak za izlet. |
| rušiti | Ovu staru zgradu će rušiti. |
| ružnoća | Ružnoća betona kvari pogled na more. |
| sadašnjost | Živi u sadašnjosti. |
| sadržaj | Provjerite sadržaj paketa. |
| sadržavati | Ovaj proizvod sadrži orašaste plodove. |
| sakriti | Gdje si sakrila ključ? |
| sakriti se | Mačka se sakrila ispod kreveta. |
| sam | Večeras sam sam kod kuće. |
| sami | Djeca su sama kod kuće. |
| san | Imala sam čudan san. |
| sandale | Ljeti nosim sandale. |
| sanjati | Sanjam o kući uz more. |
| sastaviti | Moramo sastaviti popis gostiju. |
| sastojati se | Ispit se sastoji od tri dijela. |
| savez | Hrvatska je članica saveza NATO. |
| saveznik | Uvijek si mi bio saveznik. |
| savjest | Imam mirnu savjest. |
| savjetovati | Što mi savjetuješ? |
| saznati | Kako mogu saznati rezultate? |
| sekunda | Čekaj sekundu! |
| seljak | Seljak prodaje sir na tržnici. |
| semestar | Semestar počinje u listopadu. |
| seminar | Sutra imamo seminar iz povijesti. |
| servis | Auto je na servisu. |
| shvatiti | Nisam shvatila pitanje. |
| sigurnost | Sigurnost putnika je na prvom mjestu. |
| simpatičan | Tvoj prijatelj je jako simpatičan. |
| sindikat | Sindikat traži veće plaće. |
| sinteza | Rad završava sintezom rezultata. |
| sirena | Čula se sirena hitne pomoći. |
| siromaštvo | Siromaštvo je velik problem. |
| sirovina | Drvo je važna sirovina. |
| sistem | Sistem je pao, pokušajte kasnije. |
| situacija | Situacija je ozbiljna. |
| sjajan | Imam sjajnu ideju! |
| sjednica | Sjednica vijeća počinje u deset. |
| sjesti | Gdje mogu sjesti? |
| sjećanje | Imam lijepa sjećanja na to ljeto. |
| skakati | Djeca vole skakati u more. |
| skitati se | Cijeli dan se skitao po gradu. |
| sklad | Boje su u skladu. |
| skladatelj | Skladatelj je napisao novu operu. |
| skladište | Roba je u skladištu. |
| sklapanje | Sklapanje ugovora je u petak. |
| sklonište | Za vrijeme oluje bili smo u skloništu. |
| skočiti | Skočio je s mola u more. |
| skriti se | Mačka se skrila u ormar. |
| skrivati | Što skrivaš iza leđa? |
| skroman | On je skroman čovjek. |
| skupina | Turisti su došli u velikoj skupini. |
| skupiti | Moramo skupiti novac za poklon. |
| slagati | Slagao mi je da je bolestan. |
| slavan | Postala je slavna pjevačica. |
| slavlje | Nakon pobjede bilo je veliko slavlje. |
| sletjeti | Avion je sletio u Zagreb. |
| slikarstvo | Zanima me slikarstvo. |
| sličiti | Jako sličiš mami. |
| sličnost | Postoji velika sličnost između ova dva jezika. |
| sloboda | Sloboda je najvažnija. |
| slobodno vrijeme | U slobodno vrijeme čitam. |
| slomiti | Slomila sam ruku. |
| složen | Ovo je složen problem. |
| složenost | Ne podcjenjuj složenost zadatka. |
| složiti se | Slažem se s tobom. |
| slučaj | U slučaju požara nazovite 112. |
| slučajno | Slučajno sam ga sreo u gradu. |
| slušalice | Zaboravila sam slušalice kod kuće. |
| smanjenje | Najavljeno je smanjenje cijena. |
| smanjiti | Smanjite brzinu! |
| smanjiti se | Gužva se smanjila poslije šest. |
| smanjivati | Polako smanjujem kavu. |
| smatrati | Smatram da je to dobra ideja. |
| smeđ | Ima kratku smeđu kosu. |
| smijeh | Iz dvorišta se čuo smijeh djece. |
| smiješan | Film je bio jako smiješan. |
| smiriti se | Smiri se, sve će biti u redu. |
| smisao | Nema smisla čekati. |
| smjeti | Smijem li ovdje pušiti? |
| smještaj | Tražimo smještaj za tjedan dana. |
| smrt | Vijest o njegovoj smrti nas je potresla. |
| smrtni list | Za nasljedstvo treba smrtni list. |
| snaga | Nemam snage za trening danas. |
| snage | Na teren su stigle snage policije. |
| snaći se | Brzo sam se snašla u novom gradu. |
| snimiti | Snimi video za baku. |
| snimka | Pogledaj ovu snimku. |
| sociologija | Studira sociologiju. |
| softver | Moramo ažurirati softver. |
| spajati | Most spaja otok s kopnom. |
| spas | To je bio pravi spas! |
| spasitelj | Spasitelj je izvukao dijete iz mora. |
| spasiti život | Brza reakcija može spasiti život. |
| spašavanje | Akcija spašavanja trajala je cijelu noć. |
| spašavati | Spasioci spašavaju turiste s otoka. |
| spektar | Nudimo širok spektar usluga. |
| spisi | Svi spisi su u arhivi suda. |
| spoj | Večeras imam spoj. |
| spojiti | Spoji mobitel na wifi. |
| spominjati | Stalno spominješ tog dečka. |
| spona | Jezik je spona među ljudima. |
| sponzorirati | Tvrtka sponzorira lokalni klub. |
| sporazum | Potpisali su sporazum. |
| sporedni | To je sporedni problem. |
| sportaš | On je profesionalni sportaš. |
| sposoban | Sposoban je za taj posao. |
| sposobnost | Ima sposobnost brzo učiti. |
| spoznaja | Došao je do važne spoznaje. |
| spoznati | Tek u inozemstvu sam spoznala vrijednost obitelji. |
| spoznatljiv | Svijet je spoznatljiv kroz iskustvo. |
| spremati | Spremam ručak za sutra. |
| spremiti | Ne zaboravi spremiti dokument. |
| sprijateljiti se | Brzo smo se sprijateljili. |
| spriječiti | Kako spriječiti prehladu? |
| sram | Nije te sram? |
| sramežljiv | Sin je jako sramežljiv. |
| srednji | Imate li ovu majicu u srednjoj veličini? |
| sredstvo | Treba mi sredstvo za čišćenje. |
| srušiti | Oluja je srušila drvo. |
| srušiti se | Most se srušio za vrijeme potresa. |
| stabilan | Pacijent je u stabilnom stanju. |
| stabilnost | Banka jamči stabilnost. |
| stadion | Stadion je pun navijača. |
| stagnirati | Plaće stagniraju već godinama. |
| standard | Životni standard raste. |
| stanje | Kakvo je stanje na cestama? |
| starac | Starac sjedi na klupi. |
| starost | U starosti želim živjeti uz more. |
| statistika | Prema statistici, broj turista raste. |
| status | Kakav je status moje prijave? |
| stav | Imaš pozitivan stav. |
| stečaj | Tvrtka je otišla u stečaj. |
| stih | Naučila sam nekoliko stihova napamet. |
| stoljeće | Crkva je iz petnaestog stoljeća. |
| stomatolog | Sutra idem stomatologu. |
| strah | Imam strah od visine. |
| strahovati | Strahujem za njegovo zdravlje. |
| stranica | Otvorite knjigu na stranici dvadeset. |
| stranka | Za koju stranku glasaš? |
| strast | Glazba je njegova strast. |
| strategija | Trebamo novu strategiju. |
| stres | Na poslu imam puno stresa. |
| strmoglaviti se | Auto se strmoglavio s ceste. |
| strojovođa | Strojovođa je zaustavio vlak. |
| strop | Strop u kupaonici je mokar. |
| strpljenje | Hvala na strpljenju. |
| strpljiv | Budi strpljiv. |
| struktura | Struktura teksta je jasna. |
| stručnjak | Treba nam stručnjak za porez. |
| studij | Moj studij traje pet godina. |
| stup | Auto je udario u stup. |
| stupanj | Vani je trideset stupnjeva. |
| stvaran | Ovo je stvaran problem. |
| stvarati | Djeca stvaraju buku. |
| stvari | Spakiraj svoje stvari. |
| stvarnost | San je postao stvarnost. |
| stvoriti | Želimo stvoriti bolju budućnost. |
| sud | Slučaj ide na sud. |
| sudac | Sudac je dosudio penal. |
| sudar | Na raskrižju se dogodio sudar. |
| sudionik | Svaki sudionik dobiva potvrdu. |
| suditi | Ne sudi ljudima po izgledu. |
| suditi se | Susjedi se sude zbog ograde. |
| sudjelovati | Želim sudjelovati u projektu. |
| sudoper | Posuđe je u sudoperu. |
| sudstvo | Neovisno sudstvo je temelj demokracije. |
| suh | Ovaj zrak je jako suh. |
| suhoća | Suhoća kože je česta zimi. |
| sukob | Izbjegavam sukobe na poslu. |
| sumnja | Nema sumnje, on je kriv. |
| sumnjati | Sumnjam da će doći. |
| suprotan | Imamo suprotna mišljenja. |
| suradnik | Moj suradnik je na godišnjem. |
| suradnja | Hvala na suradnji. |
| surađivati | Rado ćemo surađivati s vama. |
| suvlasnik | On je suvlasnik restorana. |
| suvremen | Stan je opremljen suvremenim uređajima. |
| suvremeni | Zanima me suvremeni ples. |
| suđenje | Suđenje počinje u ponedjeljak. |
| suša | Ljetna suša uništila je usjeve. |
| sušilo | Sušilo za kosu je u kupaonici. |
| suživot | U ovom gradu suživot je moguć. |
| svađa | Nakon svađe su se pomirili. |
| svađati se | Susjedi se svađaju svaku večer. |
| svemir | Svemir je beskonačan. |
| sveučilište | Studiram na Sveučilištu u Zagrebu. |
| svijest | Pacijent je pri svijesti. |
| svijetao | Stan je velik i svijetao. |
| svirati | Brat svira gitaru. |
| svjedok | Bio sam svjedok nesreće. |
| svjedočenje | Njegovo svjedočenje je bilo ključno. |
| svjetiljka | Upali svjetiljku pokraj kreveta. |
| svjetlost | U ovoj sobi ima malo svjetlosti. |
| svjež | Kupila sam svjež kruh. |
| svojeglav | Dijete je svojeglavo. |
| svrha | Koja je svrha vašeg putovanja? |
| svugdje | Svugdje sam tražila ključeve. |
| tajanstven | Dobila sam tajanstveno pismo. |
| tajna | To je naša tajna. |
| tajnica | Tajnica će vas nazvati. |
| taktika | Trener je promijenio taktiku. |
| talenat | Ima talenta za jezike. |
| tama | U tami ništa nisam vidjela. |
| taman | Nosi taman kaput. |
| tanjurić | Stavi šalicu na tanjurić. |
| taoc | Svi taoci su oslobođeni. |
| tata | Tata je u garaži. |
| tava | Zagrij ulje u tavi. |
| tehnički | Imamo tehnički problem. |
| tehnologija | Tehnologija se brzo razvija. |
| televizija | Što ima na televiziji? |
| temelj | Zdrava prehrana je temelj zdravlja. |
| temeljni | Ovo je temeljni zakon države. |
| teorija | U teoriji je jednostavno. |
| tepsija | Stavi krumpir u tepsiju. |
| terapija | Terapija traje deset dana. |
| termometar | Termometar pokazuje trideset stupnjeva. |
| težina | Kolika je težina kofera? |
| tisak | Vijest se pojavila u tisku. |
| tisuća | Na koncertu je bilo tisuću ljudi. |
| tišina | Molim tišinu! |
| tjeskoba | Osjećam tjeskobu prije ispita. |
| tješiti | Prijateljica me tješi. |
| tkanina | Ova tkanina je mekana. |
| tlak | Imam visok tlak. |
| tlo | Tlo je ovdje jako suho. |
| ton | Ne sviđa mi se tvoj ton. |
| toplina | Volim toplinu ljetnih večeri. |
| tradicija | Ovo je stara obiteljska tradicija. |
| tradicionalan | Pripremili smo tradicionalan ručak. |
| trajati | Koliko traje vožnja do Splita? |
| trajekt | Trajekt za Brač polazi svaki sat. |
| transakcija | Transakcija je odbijena. |
| trebam | Trebam tvoju pomoć. |
| trofej | Momčad je osvojila trofej. |
| trovanje | Imao sam trovanje hranom. |
| trošak | Troškovi stanovanja su visoki. |
| trud | Trud se isplatio. |
| tržište | Tržište nekretnina raste. |
| tugovati | Obitelj tuguje za djedom. |
| tumačiti | Svatko tumači pravila na svoj način. |
| tup | Nož je tup. |
| turizam | Turizam je važan za Hrvatsku. |
| tuča | Na ulici je izbila tuča. |
| tužba | Podnio je tužbu protiv tvrtke. |
| tužitelj | Tužitelj je iznio dokaze. |
| tužiteljstvo | Tužiteljstvo je pokrenulo istragu. |
| tužiti | Prijete da će nas tužiti. |
| tvar | Ova tvar je otrovna. |
| tvrd | Krevet je pretvrd. |
| tvrditi | Tvrdi da nije ništa vidio. |
| tvrdoglav | Ne budi tvrdoglav. |
| ubijati | Sunce ubija bakterije. |
| ubojica | Policija je uhitila ubojicu. |
| ubrzanje | Novi auto ima brzo ubrzanje. |
| ubrzati | Možemo li ubrzati proces? |
| udruga | Učlanila sam se u udrugu Ukrajinaca. |
| ugasiti | Ugasi televizor, molim te. |
| ugled | Restoran ima dobar ugled. |
| ugostiteljstvo | Ljeti radim u ugostiteljstvu. |
| ugovor o radu | Potpisala sam ugovor o radu na godinu dana. |
| uhititi | Policija je uhitila lopova. |
| uključivati | Cijena uključuje doručak. |
| ukras | Djeca prave ukrase za bor. |
| ukrasiti | Ukrasit ćemo stan za Božić. |
| ukupan | Ukupan iznos je sto eura. |
| ulaganje | Ulaganje u obrazovanje se isplati. |
| ulagati | Ulažemo u obrazovanje djece. |
| uložiti | Uložila je sav novac u stan. |
| um | Imaš bistar um. |
| umalo | Umalo sam zakasnila. |
| umiriti | Pokušao je umiriti dijete. |
| umirovljenik | Moj susjed je umirovljenik. |
| umjesto | Umjesto kave pijem čaj. |
| umjetan | Ovo je umjetan cvijet. |
| umjetnik | On je poznati umjetnik. |
| umjetnost | Zanima me moderna umjetnost. |
| umrijeti | Biljka će umrijeti bez vode. |
| unaokolo | Unaokolo je samo more. |
| uništenje | Šumi prijeti uništenje. |
| unuk | Unuk me posjećuje svake nedjelje. |
| unuka | Moja unuka ide u vrtić. |
| uostalom | Uostalom, to nije tvoj problem. |
| uplata | Uplata je stigla na račun. |
| uplašiti | Nemoj me tako uplašiti! |
| uplašiti se | Uplašila sam se psa. |
| uporan | Ako si uporan, uspjet ćeš. |
| upoznavati | Polako upoznajemo grad. |
| upozoravati | Liječnici upozoravaju na vrućinu. |
| upozorenje | Izdano je upozorenje zbog oluje. |
| uprava | Uprava je odobrila projekt. |
| upravitelj | Upravitelj zgrade je popravio lift. |
| upravljanje | Studira upravljanje u turizmu. |
| upravljati | Tko upravlja ovom tvrtkom? |
| upute | Pročitajte upute prije upotrebe. |
| uputnica | Za specijalista trebate uputnicu. |
| uragan | Uragan je pogodio obalu. |
| uredan | Stan je čist i uredan. |
| uredba | Vlada je donijela novu uredbu. |
| urediti | Moramo urediti dvorište. |
| urednik | Urednik je pročitao članak. |
| uređaj | Isključite sve uređaje. |
| usisavati | Subotom usisavam stan. |
| uskladiti | Moramo uskladiti termine. |
| usluga | Usluga u restoranu je bila spora. |
| usluge | Cijene usluga su na stranici. |
| uspjeh | Puno uspjeha na ispitu! |
| uspješan | Bio je to uspješan sastanak. |
| usporediti | Usporedite cijene prije kupnje. |
| usporiti | Usporite, ovdje je škola. |
| ustanova | Ovo je javna ustanova. |
| ustav | Ustav jamči slobodu govora. |
| utakmica | Utakmica počinje u osam. |
| utisak | Ostavio je dobar utisak. |
| utjecaj | Roditelji imaju velik utjecaj na djecu. |
| utjecati | Vrijeme utječe na moje raspoloženje. |
| utješiti | Nisam ga mogla utješiti. |
| utopiti se | Pazi da se dijete ne utopi. |
| uvjerenje | Trebam uvjerenje o nekažnjavanju. |
| uvoz | Uvoz voća raste. |
| uzak | Ovaj hodnik je jako uzak. |
| uzbuna | Kad se oglasila uzbuna, svi su izašli iz zgrade. |
| uzbuđenje | Djeca ne mogu sakriti uzbuđenje. |
| uzdah | Odgovorio je s uzdahom. |
| uzdahnuti | Duboko je uzdahnula i počela govoriti. |
| uzdisati | Zašto stalno uzdišeš? |
| uzeti lijek | Ne zaboravi uzeti lijek. |
| uznemiriti se | Nemoj se uznemiriti, sve je u redu. |
| učenik | Učenik je zaboravio zadaću. |
| učinak | Lijek ima brz učinak. |
| učinkovit | Ovaj lijek je jako učinkovit. |
| učinkovitost | Učinkovitost novog sustava je veća. |
| učionica | Učionica je na prvom katu. |
| uštedjeti | Uštedjela sam za putovanje. |
| užina | Djeca nose užinu u školu. |
| uživati | Uživamo u odmoru. |
| vagati | Prodavačica važe voće. |
| valjanost | Provjerite valjanost putovnice. |
| valjda | Valjda će sutra biti sunčano. |
| valuta | Koja je valuta u Hrvatskoj? |
| varati | Ne varaj na ispitu! |
| vatra | Zapalili smo vatru na plaži. |
| vaza | Stavi cvijeće u vazu. |
| važiti | Ta pravila važe za sve. |
| važnost | Ne shvaćaš važnost ovoga. |
| veleposlanstvo | Ukrajinsko veleposlanstvo je u Zagrebu. |
| veseliti se | Veselim se moru. |
| većina | Većina ljudi radi do pet. |
| video | Pogledaj ovaj video. |
| vidimo | Vidimo se sutra! |
| vidio | Jesi li vidio moje ključeve? |
| vijest | Imam dobru vijest! |
| vijesti | Gledam vijesti svaku večer. |
| vika | Iz stana se čula vika. |
| vikati | Nemoj vikati na mene! |
| virus | Imam neki virus. |
| visina | Kolika je visina stropa? |
| vizija | Imamo jasnu viziju budućnosti. |
| vjenčani list | Za prijavu trebate vjenčani list. |
| vjenčanje | Vjenčanje je u lipnju. |
| vjerojatan | Vjerojatan uzrok je kvar. |
| vjerojatno | Vjerojatno ću zakasniti. |
| vječnost | Čekanje je trajalo cijelu vječnost. |
| vještina | Komunikacija je važna vještina. |
| vlada | Vlada je donijela nove mjere. |
| vlasnik | Vlasnik stana živi u Njemačkoj. |
| vlast | Lokalna vlast je obnovila trg. |
| vlažan | Zrak je vlažan. |
| vlažnost | Vlažnost zraka je visoka. |
| voditelj | Voditelj tečaja je jako strpljiv. |
| voditi | Ova cesta vodi do mora. |
| vodstvo | Naša momčad je u vodstvu. |
| vojnik | Moj djed je bio vojnik. |
| vojska | Brat je u vojsci. |
| volim | Volim te. |
| vozilo | Vozilo je parkirano na krivom mjestu. |
| vođa | On je vođa tima. |
| vratiti | Moram vratiti knjigu u knjižnicu. |
| vratiti se | Vratit ću se za pet minuta. |
| vrijedan | Ovo je vrijedan sat. |
| vrijediti | Ova karta vrijedi za sve autobuse. |
| vrijednost | Vrijednost stana je porasla. |
| zaborav | Mnoge stare riječi pale su u zaborav. |
| zabrana | Na plaži je zabrana pušenja. |
| zabraniti | Zabranili su vožnju kroz centar. |
| zacijelo | Zacijelo si umoran nakon puta. |
| zadaća | Jesi li napisao zadaću? |
| zagađenje | Zagađenje zraka u gradu je visoko. |
| zagonetka | Ovo je prava zagonetka. |
| zahtijevati | Posao zahtijeva puno strpljenja. |
| zahtjev | Predala sam zahtjev za boravak. |
| zajam | Uzeo je zajam od banke. |
| zajednica | Ukrajinska zajednica u Zagrebu je velika. |
| zajednički | Imamo zajednički cilj. |
| zaklada | Zaklada pomaže djeci. |
| zaključak | Koji je vaš zaključak? |
| zaključati | Ne zaboravi zaključati vrata. |
| zaključiti | Možemo zaključiti da je plan uspio. |
| zaliha | Imamo zalihu vode za tri dana. |
| zaljubiti se | Zaljubila sam se u Split. |
| zamalo | Zamalo sam pala. |
| zamijeniti | Mogu li zamijeniti ovu majicu? |
| zamisliti | Zamisli da živiš na otoku. |
| zamišljati | Zamišljam kako će izgledati naša kuća. |
| zamrzivač | Sladoled je u zamrzivaču. |
| zanatlija | Zanatlija je popravio stolicu. |
| zapanjiti | Cijena nas je zapanjila. |
| zaplivati | Napokon sam zaplivala bez pomoći. |
| zapošljavanje | Tvrtka najavljuje zapošljavanje novih radnika. |
| zarađivati | Koliko zarađuješ mjesečno? |
| zarobiti | Vojnici su zarobili neprijatelja. |
| zasigurno | Zasigurno ćeš uspjeti. |
| zastarjelost | Zbog zastarjelosti slučaj je odbačen. |
| zatajiti | Pokušao je zatajiti istinu. |
| zatvor | Lopov je završio u zatvoru. |
| zaustavljati se | Ovaj vlak se ne zaustavlja u Karlovcu. |
| zavidjeti | Zavidim ti na tvom poslu. |
| zavjesa | Zatvori zavjese, sunce mi smeta. |
| zavoj | Medicinska sestra mi je promijenila zavoj. |
| zaštita | Ne zaboravi zaštitu od sunca. |
| zaštititi | Kremom zaštitite kožu od sunca. |
| zbog | Zakasnila sam zbog prometa. |
| zdravstvo | Radi u zdravstvu kao medicinska sestra. |
| zid | Objesi sliku na zid. |
| zlo | Nije sve zlo za zlo. |
| zlonamjerni softver | Antivirus je pronašao zlonamjerni softver. |
| zločin | Policija istražuje zločin. |
| znak | Pazite na znak za stop. |
| znam | Ne znam, pitaj Dašu. |
| znanje | Tvoje znanje hrvatskog je odlično. |
| znanost | Zanima me znanost. |
| znanstvenik | Znanstvenici su otkrili novu vrstu. |
| značaj | Ovaj događaj ima velik značaj za grad. |
| značajan | To je značajan napredak. |
| značenje | Koje je značenje ove riječi? |
| značiti | Što znači ova riječ? |
| znaš | Znaš li gdje je pošta? |
| zračenje | Sunčevo zračenje je jako u podne. |
| zreo | Ova lubenica je zrela. |
| čamac | Iznajmili smo čamac na jedan dan. |
| časnik | Moj djed je bio časnik u vojsci. |
| čast | Čast mi je upoznati vas. |
| čekanje | Čekanje kod liječnika traje satima. |
| čestica | U zraku ima puno čestica prašine. |
| činjenica | To je činjenica, a ne mišljenje. |
| činovnik | Činovnik mi je rekao da dođem sutra. |
| čizme | Zimi nosim tople čizme. |
| član | Postao sam član planinarskog društva. |
| članak | Pročitao sam zanimljiv članak o Zadru. |
| čudan | Imao sam čudan san. |
| čuvati | Čuvaj se! |
| čvrst | Ovaj stol je jako čvrst. |
| šal | Uzmi šal, puše bura. |
| šala | To je bila samo šala. |
| šansa | Daj mi još jednu šansu. |
| šapat | Govorio je šapatom. |
| šaputati | Ne šapući, svi te čujemo. |
| šaren | Kupila je šarenu haljinu. |
| šešir | Ljeti nosim šešir zbog sunca. |
| širina | Kolika je širina ormara? |
| širok | Ova cesta je jako široka. |
| šivati | Baka zna šivati haljine. |
| šok | Vijest je bila pravi šok. |
| šokirati | Cijena me šokirala. |
| šprica | Medicinska sestra je pripremila špricu. |
| štedjeti | Štedimo za novi auto. |
| štednja | Štednja je važna za budućnost. |
| štetan | Pušenje je štetno za zdravlje. |
| štetiti | Previše sunca šteti koži. |
| štogod | Uzmi štogod želiš. |
| štoviše | Nije skupo, štoviše, jako je povoljno. |
| štrajk | Zbog štrajka ne voze vlakovi. |
| šum | Čuje se šum mora. |
| šumarstvo | Brat radi u šumarstvu. |
| šutjeti | Zašto šutiš? |
| žalba | Podnio sam žalbu na odluku. |
| žalost | Na žalost, ne mogu doći. |
| žalovati | Cijelo selo žaluje za njim. |
| želim | Želim kavu, molim. |
| želiš | Što želiš za večeru? |
| živ | Riba je još živa. |
| životni vijek | Životni vijek ljudi je sve duži. |
| životopis | Pošaljite životopis na mail. |
| žrtva | U nesreći nema žrtava. |
| županija | Zadar je središte Zadarske županije. |
