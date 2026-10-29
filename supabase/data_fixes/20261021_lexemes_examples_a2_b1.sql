-- =====================================================================
-- Приклади для слів A2 / B1 без прикладів · 2026-10-21
-- Згенеровано: python3 -B scripts/gen_lexemes_examples_20261021.py (не редагуйте вручну).
--
--   * 1631 слів (A2 / B1), у яких не було жодного прикладу, отримують одне природне речення.
--   * Змінюється лише слово, у якого прикладів досі немає (examples = '[]'): наявні приклади не чіпаємо,
--     повторний запуск нічого не змінює. Стара версія → content_versions, запис у content_reviews.
--   * Запускати лише після «ок» власника (A2+ — не бета).
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
"k": "administracija",
"e": "Administracija na fakultetu radi samo ujutro."
},
{
"k": "akcija",
"e": "Ovaj tjedan je akcija na sir i jogurt."
},
{
"k": "aktivan",
"e": "Djed je i u osamdesetoj godini jako aktivan."
},
{
"k": "aktivno",
"e": "Aktivno tražim posao u Zagrebu."
},
{
"k": "aktualan",
"e": "To pitanje je i danas aktualno."
},
{
"k": "akustika",
"e": "Ova dvorana ima odličnu akustiku."
},
{
"k": "akutan",
"e": "Liječnik kaže da je upala akutna."
},
{
"k": "alat",
"e": "Imaš li alat za popravak bicikla?"
},
{
"k": "alergija",
"e": "Imam alergiju na mačke."
},
{
"k": "alergičan",
"e": "Alergičan sam na orašaste plodove."
},
{
"k": "algebra",
"e": "Algebra mi u školi nije išla."
},
{
"k": "ambiciozan",
"e": "Ona je mlada i jako ambiciozna."
},
{
"k": "ambijent",
"e": "Restoran ima ugodan ambijent."
},
{
"k": "amnestija",
"e": "Vlada je proglasila amnestiju za manje prekršaje."
},
{
"k": "analiza",
"e": "Liječnik je naručio analizu krvi."
},
{
"k": "analizirati",
"e": "Moramo analizirati rezultate ankete."
},
{
"k": "anestezija",
"e": "Zahvat se radi pod lokalnom anestezijom."
},
{
"k": "aparat",
"e": "Aparat za kavu ne radi."
},
{
"k": "apsolvent",
"e": "Apsolvent je i uskoro diplomira."
},
{
"k": "argument",
"e": "To je dobar argument."
},
{
"k": "arhiva",
"e": "Stari dokumenti čuvaju se u arhivi."
},
{
"k": "astronomija",
"e": "Moj sin se zanima za astronomiju."
},
{
"k": "atmosfera",
"e": "Na koncertu je bila odlična atmosfera."
},
{
"k": "atom",
"e": "Sve se sastoji od atoma."
},
{
"k": "automatski",
"e": "Vrata se otvaraju automatski."
},
{
"k": "autoritet",
"e": "Profesor ima velik autoritet među studentima."
},
{
"k": "avenija",
"e": "Hotel se nalazi na glavnoj aveniji."
},
{
"k": "baciti",
"e": "Možeš li baciti ovu bocu u kantu?"
},
{
"k": "backup",
"e": "Napravi backup prije ažuriranja."
},
{
"k": "bajka",
"e": "Mama djeci svake večeri čita bajku."
},
{
"k": "bankarstvo",
"e": "Radi u bankarstvu već deset godina."
},
{
"k": "bankovni",
"e": "Pošaljite mi svoj bankovni račun."
},
{
"k": "bankrot",
"e": "Tvrtka je pred bankrotom."
},
{
"k": "bankrotirati",
"e": "Mala trgovina je bankrotirala zbog krize."
},
{
"k": "barem",
"e": "Pričekaj barem pet minuta."
},
{
"k": "bazen",
"e": "Hotel ima veliki bazen."
},
{
"k": "beba",
"e": "Beba spava, budite tiho."
},
{
"k": "beskoristan",
"e": "Ovaj stari punjač je beskoristan."
},
{
"k": "besplodan",
"e": "Razgovor je bio besplodan."
},
{
"k": "bijes",
"e": "Nije mogao sakriti bijes."
},
{
"k": "bilo tko",
"e": "Bilo tko može naučiti hrvatski."
},
{
"k": "bilo što",
"e": "Možeš me pitati bilo što."
},
{
"k": "biologija",
"e": "Kći studira biologiju."
},
{
"k": "birati",
"e": "Teško mi je birati između ova dva stana."
},
{
"k": "birokracija",
"e": "Birokracija u uredu je spora."
},
{
"k": "bitan",
"e": "Ovaj dokument je jako bitan."
},
{
"k": "bitka",
"e": "Ovdje se vodila poznata bitka."
},
{
"k": "blagajnik",
"e": "Blagajnik mi je vratio krivi kusur."
},
{
"k": "blizak",
"e": "On mi je blizak prijatelj."
},
{
"k": "bogatstvo",
"e": "Priroda je najveće bogatstvo ove zemlje."
},
{
"k": "bonus",
"e": "Na kraju godine dobili smo bonus."
},
{
"k": "boravak",
"e": "Ugodan boravak u našem hotelu!"
},
{
"k": "borba",
"e": "Borba protiv bolesti je bila duga."
},
{
"k": "boriti se",
"e": "Moramo se boriti za svoja prava."
},
{
"k": "brak",
"e": "Moji roditelji su u braku trideset godina."
},
{
"k": "branitelj",
"e": "Branitelj je tražio oslobađajuću presudu."
},
{
"k": "braniti",
"e": "Odvjetnik brani optuženog."
},
{
"k": "brava",
"e": "Brava na vratima je pokvarena."
},
{
"k": "brašno",
"e": "Za kolač trebamo pola kile brašna."
},
{
"k": "briga",
"e": "Hvala na brizi."
},
{
"k": "brinuti",
"e": "Tko će brinuti o psu dok smo na moru?"
},
{
"k": "brisati",
"e": "Nemoj brisati te fotografije!"
},
{
"k": "brojati",
"e": "Moj sin već zna brojati do sto."
},
{
"k": "broš",
"e": "Na kaputu nosi lijep broš."
},
{
"k": "brošura",
"e": "Uzmite brošuru o izletima."
},
{
"k": "brzina",
"e": "Ograničenje brzine je pedeset kilometara na sat."
},
{
"k": "bunt",
"e": "Studenti su digli bunt protiv novih pravila."
},
{
"k": "burza",
"e": "Cijene dionica na burzi su pale."
},
{
"k": "bučan",
"e": "Ovaj kafić je previše bučan."
},
{
"k": "carina",
"e": "Na granici smo dugo čekali na carini."
},
{
"k": "carinik",
"e": "Carinik je pregledao naš prtljag."
},
{
"k": "cijeli",
"e": "Cijeli dan sam radila."
},
{
"k": "cijepiti",
"e": "Dijete moramo cijepiti protiv ospica."
},
{
"k": "cjelina",
"e": "Grad i okolica čine jednu cjelinu."
},
{
"k": "dakle",
"e": "Dakle, vidimo se u osam."
},
{
"k": "daleki",
"e": "To je bilo u dalekoj prošlosti."
},
{
"k": "dapače",
"e": "Nije mi teško, dapače, rado ću pomoći."
},
{
"k": "dar",
"e": "Ovo je mali dar za tebe."
},
{
"k": "darovati",
"e": "Kuću je darovao svojoj kćeri."
},
{
"k": "daska",
"e": "Daska za glačanje je iza vrata."
},
{
"k": "datum",
"e": "Koji je danas datum?"
},
{
"k": "davati",
"e": "Ova banka daje dobre kredite."
},
{
"k": "demokracija",
"e": "Sloboda govora važna je za demokraciju."
},
{
"k": "dernjati se",
"e": "Nemoj se dernjati, sve čujem."
},
{
"k": "detalj",
"e": "Pošaljite mi sve detalje mailom."
},
{
"k": "dežurstvo",
"e": "Liječnica ima dežurstvo ovaj vikend."
},
{
"k": "digitalizacija",
"e": "Digitalizacija ureda trajala je godinu dana."
},
{
"k": "dijagnoza",
"e": "Liječnik još nije postavio dijagnozu."
},
{
"k": "dijeliti",
"e": "Stan dijelim s prijateljicom."
},
{
"k": "dimenzija",
"e": "Koje su dimenzije ormara?"
},
{
"k": "dio",
"e": "Ovo je najljepši dio grada."
},
{
"k": "dionica",
"e": "Kupio je dionice jedne tvrtke."
},
{
"k": "diploma",
"e": "Diplomu sam dobila prošle godine."
},
{
"k": "diplomata",
"e": "Njezin otac je diplomata."
},
{
"k": "dirigent",
"e": "Dirigent je ušao na pozornicu."
},
{
"k": "disanje",
"e": "Duboko disanje pomaže kod stresa."
},
{
"k": "disati",
"e": "Dišite duboko, molim vas."
},
{
"k": "distribucija",
"e": "Tvrtka se bavi distribucijom hrane."
},
{
"k": "diviti se",
"e": "Divim se tvojoj hrabrosti."
},
{
"k": "dizajn",
"e": "Sviđa mi se dizajn ovog stana."
},
{
"k": "dizajnirati",
"e": "Ona dizajnira odjeću."
},
{
"k": "djeca",
"e": "Djeca su u školi do dva."
},
{
"k": "djelatnost",
"e": "Glavna djelatnost tvrtke je turizam."
},
{
"k": "djelo",
"e": "Ovo je najpoznatije djelo hrvatske književnosti."
},
{
"k": "djelovati",
"e": "Lijek počinje djelovati nakon pola sata."
},
{
"k": "dob",
"e": "Upišite svoju dob u obrazac."
},
{
"k": "dobit",
"e": "Tvrtka je ove godine imala veću dobit."
},
{
"k": "dobivati",
"e": "Svaki dan dobivam puno mailova."
},
{
"k": "dodatak",
"e": "Ljeti dobivamo dodatak na plaću."
},
{
"k": "dodir",
"e": "Ekran reagira na dodir."
},
{
"k": "dodirnuti",
"e": "Ne dodirujte izloške, molim."
},
{
"k": "dogovarati",
"e": "Još dogovaramo termin sastanka."
},
{
"k": "dogovarati se",
"e": "Još se dogovaramo oko cijene."
},
{
"k": "dogovor",
"e": "Imamo dogovor, vidimo se u osam."
},
{
"k": "dogovoriti",
"e": "Moramo dogovoriti cijenu."
},
{
"k": "dogovoriti se",
"e": "Dogovorili smo se za petak."
},
{
"k": "dohodak",
"e": "Porez na dohodak plaća se svake godine."
},
{
"k": "dokaz",
"e": "Sačuvajte račun kao dokaz kupnje."
},
{
"k": "dokazati",
"e": "Možete li dokazati da ste platili?"
},
{
"k": "dokazivati",
"e": "Ne moraš nikome ništa dokazivati."
},
{
"k": "dolazak",
"e": "Javite nam vrijeme dolaska."
},
{
"k": "doletjeti",
"e": "Ptica je doletjela na prozor."
},
{
"k": "dom",
"e": "Studenti žive u studentskom domu."
},
{
"k": "domaćica",
"e": "Domaćica nam je pripremila večeru."
},
{
"k": "domaćin",
"e": "Domaćin nas je dočekao s rakijom."
},
{
"k": "domišljat",
"e": "Moj sin je jako domišljat."
},
{
"k": "donirati",
"e": "Odlučili smo donirati odjeću."
},
{
"k": "dopustiti",
"e": "Neću dopustiti da kasniš."
},
{
"k": "doputovati",
"e": "Doputovali smo u Zagreb u ponoć."
},
{
"k": "dopuštati",
"e": "Roditelji mu ne dopuštaju izlaziti noću."
},
{
"k": "dosjetiti se",
"e": "Napokon sam se dosjetila odgovora."
},
{
"k": "dostava",
"e": "Dostava je besplatna za narudžbe iznad pedeset eura."
},
{
"k": "dostaviti",
"e": "Paket će vam dostaviti sutra."
},
{
"k": "dostojanstvo",
"e": "Svaki čovjek ima pravo na dostojanstvo."
},
{
"k": "dostupan",
"e": "Liječnik je dostupan od osam do dva."
},
{
"k": "dotrčati",
"e": "Pas je dotrčao do mene."
},
{
"k": "dovoljan",
"e": "Je li ovo dovoljan iznos?"
},
{
"k": "dovoljno",
"e": "Imamo dovoljno vremena."
},
{
"k": "dovršiti",
"e": "Moram dovršiti izvještaj do petka."
},
{
"k": "doza",
"e": "Uzmite jednu dozu lijeka ujutro."
},
{
"k": "doznati",
"e": "Kako si to doznala?"
},
{
"k": "doživljaj",
"e": "Putovanje na Vis bilo je pravi doživljaj."
},
{
"k": "društven",
"e": "Daša je jako društvena osoba."
},
{
"k": "društvene mreže",
"e": "Previše vremena provodim na društvenim mrežama."
},
{
"k": "društveni",
"e": "Ovo je velik društveni problem."
},
{
"k": "društvo",
"e": "Ugodno mi je u vašem društvu."
},
{
"k": "državljanin",
"e": "On je hrvatski državljanin."
},
{
"k": "državljanstvo",
"e": "Zatražio je hrvatsko državljanstvo."
},
{
"k": "dubina",
"e": "Dubina bazena je dva metra."
},
{
"k": "dubok",
"e": "Ovdje je more jako duboko."
},
{
"k": "dugovati",
"e": "Koliko ti dugujem?"
},
{
"k": "duhovit",
"e": "Tvoj brat je jako duhovit."
},
{
"k": "duljina",
"e": "Kolika je duljina ovog stola?"
},
{
"k": "duša",
"e": "Ona je dobra duša."
},
{
"k": "dužina",
"e": "Dužina staze je pet kilometara."
},
{
"k": "dužnost",
"e": "Moja dužnost je pomoći."
},
{
"k": "dvorište",
"e": "Djeca se igraju u dvorištu."
},
{
"k": "džemper",
"e": "Obuci džemper, hladno je."
},
{
"k": "ekologija",
"e": "Ekologija je važna tema u školama."
},
{
"k": "ekonomija",
"e": "Studirao je ekonomiju u Zagrebu."
},
{
"k": "ekonomist",
"e": "Moj brat radi kao ekonomist."
},
{
"k": "ekonomski",
"e": "Zemlja je u ekonomskoj krizi."
},
{
"k": "ekran na dodir",
"e": "Novi mobitel ima veći ekran na dodir."
},
{
"k": "eksperiment",
"e": "Učenici rade eksperiment iz kemije."
},
{
"k": "elastičan",
"e": "Ovaj materijal je elastičan."
},
{
"k": "element",
"e": "Voda je važan element života."
},
{
"k": "emisija",
"e": "Gledam emisiju o kuhanju."
},
{
"k": "emocija",
"e": "Teško mi je pokazati emocije."
},
{
"k": "enciklopedija",
"e": "Taj podatak sam našao u enciklopediji."
},
{
"k": "energija",
"e": "Nakon odmora imam puno energije."
},
{
"k": "epoha",
"e": "To je bila zanimljiva epoha u povijesti."
},
{
"k": "etika",
"e": "Liječnici moraju poštovati etiku."
},
{
"k": "evakuacija",
"e": "Evakuacija zgrade počela je odmah."
},
{
"k": "evo",
"e": "Evo, ovo je tvoja soba."
},
{
"k": "evolucija",
"e": "U školi učimo o evoluciji."
},
{
"k": "faktura",
"e": "Pošaljite nam fakturu za uslugu."
},
{
"k": "fenomen",
"e": "Bura je poseban prirodni fenomen."
},
{
"k": "fiksan",
"e": "Cijena je fiksna, nema popusta."
},
{
"k": "filozofija",
"e": "Studirala sam filozofiju."
},
{
"k": "financije",
"e": "Brine o financijama tvrtke."
},
{
"k": "financirati",
"e": "Projekt financira Europska unija."
},
{
"k": "fizika",
"e": "Fizika mi je bila teška u školi."
},
{
"k": "flaster",
"e": "Stavi flaster na ranu."
},
{
"k": "fleksibilan",
"e": "Imam fleksibilno radno vrijeme."
},
{
"k": "fond",
"e": "Novac ide u fond za pomoć djeci."
},
{
"k": "formalni",
"e": "Za razgovor za posao trebam formalnu odjeću."
},
{
"k": "formula",
"e": "Ne sjećam se formule."
},
{
"k": "formular",
"e": "Ispunite formular na šalteru."
},
{
"k": "fotograf",
"e": "Fotograf nas je slikao na vjenčanju."
},
{
"k": "frekvencija",
"e": "Na kojoj frekvenciji je radio stanica?"
},
{
"k": "funkcija",
"e": "Ova funkcija u aplikaciji je nova."
},
{
"k": "ga",
"e": "Vidiš li ga?"
},
{
"k": "galerija",
"e": "U galeriji je nova izložba."
},
{
"k": "generacija",
"e": "Moja generacija je odrasla bez mobitela."
},
{
"k": "general",
"e": "General je obišao vojnike."
},
{
"k": "geografija",
"e": "Geografija mi je bila omiljeni predmet."
},
{
"k": "geometrija",
"e": "Sin ima zadaću iz geometrije."
},
{
"k": "gibak",
"e": "Mačka je gipka i brza životinja."
},
{
"k": "gladak",
"e": "Pod je gladak i sjajan."
},
{
"k": "glasanje",
"e": "Glasanje traje do sedam navečer."
},
{
"k": "glasina",
"e": "To je samo glasina."
},
{
"k": "glasovanje",
"e": "Glasovanje je tajno."
},
{
"k": "glatak",
"e": "Kamen je gladak od mora."
},
{
"k": "glazbenik",
"e": "Na trgu svira ulični glazbenik."
},
{
"k": "globalni",
"e": "Ovo je globalni problem."
},
{
"k": "globalno zatopljenje",
"e": "Globalno zatopljenje mijenja klimu."
},
{
"k": "glumiti",
"e": "Ona glumi u kazalištu."
},
{
"k": "glup",
"e": "To je bilo glupo pitanje."
},
{
"k": "gorivo",
"e": "Ponestalo nam je goriva."
},
{
"k": "gospodarstvo",
"e": "Turizam je važan za hrvatsko gospodarstvo."
},
{
"k": "gostovati",
"e": "Kazalište iz Splita gostuje u Zagrebu."
},
{
"k": "gotovo",
"e": "Gotovo smo stigli."
},
{
"k": "govor",
"e": "Gradonačelnik je održao kratak govor."
},
{
"k": "govoriti istinu",
"e": "Uvijek treba govoriti istinu."
},
{
"k": "gradnja",
"e": "Gradnja nove bolnice traje dvije godine."
},
{
"k": "gradonačelnik",
"e": "Gradonačelnik je otvorio novi park."
},
{
"k": "granica",
"e": "Na granici smo čekali sat vremena."
},
{
"k": "gravitacija",
"e": "Gravitacija drži Mjesec u orbiti."
},
{
"k": "građanin",
"e": "Svaki građanin ima pravo glasa."
},
{
"k": "građevinarstvo",
"e": "Radi u građevinarstvu."
},
{
"k": "gripa",
"e": "Imam gripu i ostajem kod kuće."
},
{
"k": "grlo",
"e": "Boli me grlo."
},
{
"k": "grom",
"e": "Grom je udario u drvo."
},
{
"k": "groznica",
"e": "Dijete ima groznicu."
},
{
"k": "grozno",
"e": "Vrijeme je danas grozno."
},
{
"k": "gubitak",
"e": "Tvrtka je imala velik gubitak."
},
{
"k": "gubiti",
"e": "Nemoj gubiti vrijeme."
},
{
"k": "gubitnik",
"e": "Nemoj se osjećati kao gubitnik."
},
{
"k": "gurnuti",
"e": "Vrata treba gurnuti, ne povući."
},
{
"k": "gust",
"e": "Magla je gusta, vozi polako."
},
{
"k": "haker",
"e": "Haker je ukrao podatke korisnika."
},
{
"k": "hardver",
"e": "Problem nije u softveru, nego u hardveru."
},
{
"k": "heroj",
"e": "Vatrogasci su pravi heroji."
},
{
"k": "hipoteza",
"e": "Znanstvenici su provjerili hipotezu."
},
{
"k": "hitnost",
"e": "Liječnik je odmah shvatio hitnost situacije."
},
{
"k": "hladnoća",
"e": "Ne podnosim hladnoću."
},
{
"k": "hlađenje",
"e": "Hlađenje u autu ne radi."
},
{
"k": "hostel",
"e": "Spavali smo u hostelu blizu kolodvora."
},
{
"k": "hoćemo",
"e": "Hoćemo li na kavu?"
},
{
"k": "hrabar",
"e": "Bio si jako hrabar."
},
{
"k": "hrabrost",
"e": "Trebalo je puno hrabrosti za to."
},
{
"k": "hrapav",
"e": "Zid je hrapav."
},
{
"k": "hvaliti",
"e": "Svi hvale tvoju kuhinju."
},
{
"k": "ideja",
"e": "Imam dobru ideju!"
},
{
"k": "indeks",
"e": "Profesor je upisao ocjenu u indeks."
},
{
"k": "industrija",
"e": "Turizam je najvažnija industrija na obali."
},
{
"k": "infekcija",
"e": "Liječnik mi je dao antibiotik za infekciju."
},
{
"k": "inflacija",
"e": "Inflacija je ove godine visoka."
},
{
"k": "informacija",
"e": "Gdje mogu dobiti informacije o vlakovima?"
},
{
"k": "informirati",
"e": "Molimo vas da nas informirate o promjenama."
},
{
"k": "injekcija",
"e": "Medicinska sestra mi je dala injekciju."
},
{
"k": "inovacija",
"e": "Tvrtka ulaže u inovacije."
},
{
"k": "insekt",
"e": "Imaš li sprej protiv insekata?"
},
{
"k": "instrument",
"e": "Svirate li neki instrument?"
},
{
"k": "interakcija",
"e": "Učenje jezika traži interakciju s ljudima."
},
{
"k": "interes",
"e": "Pokazali su velik interes za naš projekt."
},
{
"k": "intervju",
"e": "Sutra imam intervju za posao."
},
{
"k": "invalid",
"e": "Ovo je parkirno mjesto za invalide."
},
{
"k": "invalidnost",
"e": "Dobiva mirovinu zbog invalidnosti."
},
{
"k": "inventura",
"e": "Trgovina je zatvorena zbog inventure."
},
{
"k": "investicija",
"e": "Stan je dobra investicija."
},
{
"k": "investirati",
"e": "Želimo investirati u turizam."
},
{
"k": "investitor",
"e": "Investitor je kupio stari hotel."
},
{
"k": "ishod",
"e": "Ishod utakmice je neizvjestan."
},
{
"k": "isključiti",
"e": "Molim vas, isključite mobitele."
},
{
"k": "isključivati",
"e": "Ne zaboravi isključivati svjetlo kad izlaziš."
},
{
"k": "iskoristiti",
"e": "Moramo iskoristiti lijepo vrijeme."
},
{
"k": "iskorištavati",
"e": "Ne dopusti da te iskorištavaju."
},
{
"k": "iskren",
"e": "Budi iskren sa mnom."
},
{
"k": "iskrenost",
"e": "Cijenim tvoju iskrenost."
},
{
"k": "iskustvo",
"e": "Imate li iskustva u prodaji?"
},
{
"k": "isplata",
"e": "Isplata plaće je petnaestog u mjesecu."
},
{
"k": "isplatiti",
"e": "Plaću će nam isplatiti petnaestog."
},
{
"k": "isplivati",
"e": "Istina će isplivati na površinu."
},
{
"k": "isporučiti",
"e": "Robu ćemo isporučiti u roku od tri dana."
},
{
"k": "ispraviti",
"e": "Možete li ispraviti moju pogrešku?"
},
{
"k": "ispravljati",
"e": "Učiteljica nam ispravlja zadaće."
},
{
"k": "ispričati se",
"e": "Moram se ispričati Daši."
},
{
"k": "ispuniti",
"e": "Ispunite obrazac i potpišite ga."
},
{
"k": "ispunjavati",
"e": "Ispunjavam obrazac za vizu."
},
{
"k": "istek",
"e": "Nakon isteka ugovora moram se iseliti."
},
{
"k": "isteći",
"e": "Putovnica mi uskoro ističe."
},
{
"k": "isticati",
"e": "Liječnik ističe da je odmor važan."
},
{
"k": "istinit",
"e": "Film je snimljen prema istinitoj priči."
},
{
"k": "istovjetnost",
"e": "Policija je utvrdila istovjetnost potpisa."
},
{
"k": "istraga",
"e": "Policija je pokrenula istragu."
},
{
"k": "istražiti",
"e": "Želimo istražiti otok biciklom."
},
{
"k": "istraživanje",
"e": "Istraživanje pokazuje da ljudi manje čitaju."
},
{
"k": "istraživati",
"e": "Volim istraživati nove gradove."
},
{
"k": "istraživač",
"e": "On je istraživač na institutu."
},
{
"k": "istrčati",
"e": "Dijete je istrčalo na cestu."
},
{
"k": "izabrati",
"e": "Ne znam koju haljinu izabrati."
},
{
"k": "izazivati",
"e": "Šećer izaziva karijes."
},
{
"k": "izazov",
"e": "Život u novoj zemlji je velik izazov."
},
{
"k": "izbaviti",
"e": "Vatrogasci su izbavili obitelj iz zgrade."
},
{
"k": "izbivati",
"e": "Često izbiva s posla zbog bolesti."
},
{
"k": "izbjegavati",
"e": "Liječnik kaže da izbjegavam slanu hranu."
},
{
"k": "izbjegnuti",
"e": "Nesreću je bilo nemoguće izbjegnuti."
},
{
"k": "izbjeći",
"e": "Krenuli smo rano da izbjegnemo gužvu."
},
{
"k": "izbori",
"e": "Izbori su u svibnju."
},
{
"k": "izdati",
"e": "Knjigu je izdala mala izdavačka kuća."
},
{
"k": "izdavati",
"e": "Ljeti izdajemo apartman turistima."
},
{
"k": "izdavač",
"e": "Izdavač je objavio novi roman."
},
{
"k": "izdržati",
"e": "Ne mogu više izdržati ovu vrućinu."
},
{
"k": "izgledati",
"e": "Izgledaš umorno."
},
{
"k": "izgovor",
"e": "Hrvatski izgovor nije jako težak."
},
{
"k": "izgraditi",
"e": "Ovdje će izgraditi novu školu."
},
{
"k": "izjava",
"e": "Svjedok je dao izjavu policiji."
},
{
"k": "izjaviti",
"e": "Ministar je izjavio da će cijene pasti."
},
{
"k": "izlet",
"e": "U subotu idemo na izlet na Plitvice."
},
{
"k": "izliječiti",
"e": "Ovaj lijek će izliječiti infekciju."
},
{
"k": "izložba",
"e": "Idemo na izložbu fotografija."
},
{
"k": "izmišljen",
"e": "Ova priča je potpuno izmišljena."
},
{
"k": "izmjeriti",
"e": "Sestra mi je izmjerila tlak."
},
{
"k": "iznajmljivati",
"e": "Ljeti iznajmljujemo sobe turistima."
},
{
"k": "iznenaditi",
"e": "Htjeli smo te iznenaditi."
},
{
"k": "iznenađivati",
"e": "Ovaj grad me stalno iznenađuje."
},
{
"k": "iznimka",
"e": "Ovo je iznimka, a ne pravilo."
},
{
"k": "izraz",
"e": "Ne razumijem ovaj izraz."
},
{
"k": "izračunati",
"e": "Možete li izračunati ukupnu cijenu?"
},
{
"k": "izum",
"e": "Telefon je bio velik izum."
},
{
"k": "izumitelj",
"e": "Nikola Tesla bio je slavni izumitelj."
},
{
"k": "izvještaj",
"e": "Šef čeka moj izvještaj."
},
{
"k": "izvor",
"e": "Ovo je izvor pitke vode."
},
{
"k": "izvor informacija",
"e": "Internet je moj glavni izvor informacija."
},
{
"k": "izvoz",
"e": "Izvoz vina raste svake godine."
},
{
"k": "izvrsno",
"e": "Izvrsno, sve je spremno!"
},
{
"k": "izvršavati",
"e": "Uvijek izvršava zadatke na vrijeme."
},
{
"k": "izvršenje",
"e": "Sud je odgodio izvršenje kazne."
},
{
"k": "izvršiti",
"e": "Uplatu možete izvršiti u banci."
},
{
"k": "jamačno",
"e": "Jamačno će doći, obećao je."
},
{
"k": "jamstvo",
"e": "Ovaj uređaj ima dvije godine jamstva."
},
{
"k": "jasan",
"e": "Je li vam sve jasno?"
},
{
"k": "java",
"e": "To se dogodilo na javi, a ne u snu."
},
{
"k": "javiti",
"e": "Javit ću ti kad stignem."
},
{
"k": "javni",
"e": "Javni prijevoz je ovdje jeftin."
},
{
"k": "je",
"e": "Gdje je pošta?"
},
{
"k": "jedinstven",
"e": "Ovo je jedinstvena prilika."
},
{
"k": "jednobojan",
"e": "Tražim jednobojnu majicu."
},
{
"k": "jednostavan",
"e": "Recept je jako jednostavan."
},
{
"k": "jednostavno",
"e": "Jednostavno nemam vremena."
},
{
"k": "jednostavnost",
"e": "Volim jednostavnost ovog dizajna."
},
{
"k": "jedva",
"e": "Jedva sam stigla na vlak."
},
{
"k": "jedva da",
"e": "Jedva da ga poznajem."
},
{
"k": "jesi",
"e": "Jesi li gladan?"
},
{
"k": "jezikoslovlje",
"e": "Hrvatsko jezikoslovlje ima dugu tradiciju."
},
{
"k": "junak",
"e": "On je junak ove priče."
},
{
"k": "kamata",
"e": "Kamata na kredit je četiri posto."
},
{
"k": "kamera",
"e": "Na ulazu je kamera."
},
{
"k": "kamp",
"e": "Ljeti spavamo u kampu kraj mora."
},
{
"k": "kampanja",
"e": "Počela je predizborna kampanja."
},
{
"k": "kanal",
"e": "Na kojem kanalu je utakmica?"
},
{
"k": "kandidat",
"e": "Na izborima je pet kandidata."
},
{
"k": "kapetan",
"e": "Kapetan broda pozdravio je putnike."
},
{
"k": "kapital",
"e": "Za otvaranje tvrtke treba kapital."
},
{
"k": "kapuljača",
"e": "Stavi kapuljaču, pada kiša."
},
{
"k": "karakter",
"e": "Ima jak karakter."
},
{
"k": "karijera",
"e": "Gradi karijeru u inozemstvu."
},
{
"k": "katastrofa",
"e": "Poplava je bila prava katastrofa."
},
{
"k": "kategorija",
"e": "Hotel ima četiri zvjezdice, to je visoka kategorija."
},
{
"k": "katkad",
"e": "Katkad idem na posao biciklom."
},
{
"k": "kazniti",
"e": "Policija ga je kaznila zbog brze vožnje."
},
{
"k": "kašljati",
"e": "Već tjedan dana kašljem."
},
{
"k": "kemija",
"e": "Kemija mi nikad nije bila jača strana."
},
{
"k": "kihati",
"e": "Stalno kišem zbog alergije."
},
{
"k": "kipar",
"e": "Ivan Meštrović bio je poznati hrvatski kipar."
},
{
"k": "kiparstvo",
"e": "Zanima me moderno kiparstvo."
},
{
"k": "kirurg",
"e": "Kirurg je uspješno obavio operaciju."
},
{
"k": "kišan",
"e": "Bio je to hladan i kišan dan."
},
{
"k": "klasificirati",
"e": "Otpad treba klasificirati prije recikliranja."
},
{
"k": "klasičan",
"e": "Volim klasičnu glazbu."
},
{
"k": "klasično",
"e": "Uređenje stana je klasično i jednostavno."
},
{
"k": "klimatske promjene",
"e": "Klimatske promjene utječu na poljoprivredu."
},
{
"k": "klimatski",
"e": "Klimatski uvjeti na otoku su blagi."
},
{
"k": "klinika",
"e": "Operacija je bila u privatnoj klinici."
},
{
"k": "klupa",
"e": "Sjeli smo na klupu u parku."
},
{
"k": "književnost",
"e": "Volim hrvatsku književnost."
},
{
"k": "knjižničar",
"e": "Knjižničar mi je pomogao naći knjigu."
},
{
"k": "koalicija",
"e": "Stranke su sklopile koaliciju."
},
{
"k": "kolebati se",
"e": "Još se kolebam oko posla."
},
{
"k": "kolektiv",
"e": "Imamo dobar radni kolektiv."
},
{
"k": "količina",
"e": "Kolika je količina vode u boci?"
},
{
"k": "koljeno",
"e": "Boli me koljeno nakon trčanja."
},
{
"k": "komentar",
"e": "Napiši komentar ispod fotografije."
},
{
"k": "komentirati",
"e": "Ne želim to komentirati."
},
{
"k": "kompleksnost",
"e": "Kompleksnost problema nas je iznenadila."
},
{
"k": "kompliciran",
"e": "Ovaj obrazac je jako kompliciran."
},
{
"k": "kompromis",
"e": "Moramo naći kompromis."
},
{
"k": "komunicirati",
"e": "S kolegama komuniciramo mailom."
},
{
"k": "komunikacija",
"e": "Dobra komunikacija je ključ uspjeha."
},
{
"k": "konačno",
"e": "Konačno smo stigli!"
},
{
"k": "koncept",
"e": "Koncept restorana je zanimljiv."
},
{
"k": "kondukter",
"e": "Kondukter je provjerio karte."
},
{
"k": "konferencija",
"e": "Idem na konferenciju u Zagreb."
},
{
"k": "konkurencija",
"e": "Na tržištu je velika konkurencija."
},
{
"k": "konkurent",
"e": "Naš konkurent ima niže cijene."
},
{
"k": "kontaktirati",
"e": "Za više informacija kontaktirajte recepciju."
},
{
"k": "kontrolirati",
"e": "Moram kontrolirati šećer u krvi."
},
{
"k": "konzulat",
"e": "Za vizu se javite u konzulat."
},
{
"k": "kopija",
"e": "Trebam kopiju putovnice."
},
{
"k": "kopno",
"e": "Trajekt vozi s otoka na kopno."
},
{
"k": "korak",
"e": "Ovo je prvi korak."
},
{
"k": "koristan",
"e": "Ovaj savjet je jako koristan."
},
{
"k": "koristiti",
"e": "Smijem li koristiti vaš telefon?"
},
{
"k": "korištenje",
"e": "Korištenje mobitela u avionu nije dopušteno."
},
{
"k": "koža",
"e": "Imam osjetljivu kožu."
},
{
"k": "krajolik",
"e": "Krajolik u Lici je prekrasan."
},
{
"k": "krasti",
"e": "Krasti je zločin."
},
{
"k": "krađa",
"e": "Prijavila sam krađu policiji."
},
{
"k": "kreativan",
"e": "Moja kći je jako kreativna."
},
{
"k": "kreativnost",
"e": "Ovaj posao traži puno kreativnosti."
},
{
"k": "krema",
"e": "Ne zaboravi kremu za sunčanje."
},
{
"k": "kretati se",
"e": "Morate se više kretati."
},
{
"k": "krhak",
"e": "Pazi, ova vaza je krhka."
},
{
"k": "krik",
"e": "Čuo se krik iz šume."
},
{
"k": "kriminalac",
"e": "Policija je uhvatila kriminalca."
},
{
"k": "kriptiranje",
"e": "Kriptiranje štiti vaše podatke."
},
{
"k": "kritizirati",
"e": "Nemoj stalno kritizirati."
},
{
"k": "krivica",
"e": "To nije tvoja krivica."
},
{
"k": "krivnja",
"e": "Osjećam krivnju što nisam nazvala."
},
{
"k": "kriza",
"e": "Ekonomska kriza je pogodila sve."
},
{
"k": "krpa",
"e": "Obriši stol mokrom krpom."
},
{
"k": "krut",
"e": "Ova kožna jakna je još kruta."
},
{
"k": "krvarenje",
"e": "Pritisnite ranu da zaustavite krvarenje."
},
{
"k": "krvariti",
"e": "Rana još krvari."
},
{
"k": "kršiti",
"e": "Ne smijete kršiti pravila."
},
{
"k": "kukavan",
"e": "Bio je previše kukavan da kaže istinu."
},
{
"k": "kupac",
"e": "Kupac uvijek ima pravo."
},
{
"k": "kustos",
"e": "Kustos nas je proveo kroz muzej."
},
{
"k": "kvaliteta",
"e": "Kvaliteta ove robe je odlična."
},
{
"k": "kvantiteta",
"e": "Važnija je kvaliteta od kvantitete."
},
{
"k": "lagati",
"e": "Nemoj mi lagati."
},
{
"k": "lakoća",
"e": "Govori hrvatski s lakoćom."
},
{
"k": "lavina",
"e": "Lavina je zatrpala cestu."
},
{
"k": "laž",
"e": "To je laž!"
},
{
"k": "lažan",
"e": "Ovo je lažan račun."
},
{
"k": "led",
"e": "Želite li led u piće?"
},
{
"k": "leden",
"e": "Popio sam ledeni čaj."
},
{
"k": "leći",
"e": "Moram leći, boli me glava."
},
{
"k": "lice",
"e": "Operi lice hladnom vodom."
},
{
"k": "lift",
"e": "Uzmimo lift do petog kata."
},
{
"k": "lijen",
"e": "Danas sam jako lijen."
},
{
"k": "liječiti",
"e": "Ovaj liječnik liječi alergije."
},
{
"k": "lingvistika",
"e": "Zanima me lingvistika."
},
{
"k": "list",
"e": "Daj mi jedan list papira."
},
{
"k": "literatura",
"e": "Profesor nam je dao popis literature."
},
{
"k": "ljepota",
"e": "Ljepota ovog otoka je nevjerojatna."
},
{
"k": "ljubazan",
"e": "Konobar je bio jako ljubazan."
},
{
"k": "ljubaznost",
"e": "Hvala vam na ljubaznosti."
},
{
"k": "ljudi",
"e": "Ovdje su ljudi jako ljubazni."
},
{
"k": "ljutiti se",
"e": "Nemoj se ljutiti na mene."
},
{
"k": "ljutnja",
"e": "Njegova ljutnja brzo je prošla."
},
{
"k": "logika",
"e": "Ne razumijem logiku ovog pravila."
},
{
"k": "lokalni",
"e": "Kupujemo voće na lokalnoj tržnici."
},
{
"k": "lom",
"e": "Rendgen je pokazao lom kosti."
},
{
"k": "lonac",
"e": "Stavi lonac s vodom na štednjak."
},
{
"k": "lud",
"e": "Jesi li lud? Vani je oluja!"
},
{
"k": "ludost",
"e": "To je čista ludost!"
},
{
"k": "lukav",
"e": "Lisica je lukava."
},
{
"k": "lutati",
"e": "Satima smo lutali starim gradom."
},
{
"k": "ma tko",
"e": "Ma tko to zvoni u ponoć?"
},
{
"k": "majstor",
"e": "Zvali smo majstora da popravi bojler."
},
{
"k": "mana",
"e": "Svatko ima neku manu."
},
{
"k": "manifestacija",
"e": "Ljeti grad organizira mnogo kulturnih manifestacija."
},
{
"k": "manjina",
"e": "U gradu živi i mala talijanska manjina."
},
{
"k": "marljiv",
"e": "Ona je marljiva učenica."
},
{
"k": "masa",
"e": "Kolač treba miješati dok masa ne postane glatka."
},
{
"k": "mast",
"e": "Liječnik mi je prepisao mast za kožu."
},
{
"k": "mastan",
"e": "Ova hrana je previše masna."
},
{
"k": "mat",
"e": "Želim mat boju za zidove."
},
{
"k": "materijal",
"e": "Od kojeg je materijala ova jakna?"
},
{
"k": "mašta",
"e": "Djeca imaju bujnu maštu."
},
{
"k": "maštovit",
"e": "Ovo je jako maštovit crtić."
},
{
"k": "medij",
"e": "Internet je danas najvažniji medij."
},
{
"k": "mediji",
"e": "O tome su pisali svi mediji."
},
{
"k": "mehanika",
"e": "Studira strojarstvo i mehaniku."
},
{
"k": "mekan",
"e": "Ovaj krevet je jako mekan."
},
{
"k": "menadžer",
"e": "Menadžer hotela nas je pozdravio."
},
{
"k": "metal",
"e": "Ograda je od metala."
},
{
"k": "metla",
"e": "Uzmi metlu i pometi pod."
},
{
"k": "metoda",
"e": "Ovo je dobra metoda učenja."
},
{
"k": "metodologija",
"e": "Metodologija istraživanja je jasna."
},
{
"k": "međutim",
"e": "Htjela sam doći, međutim nisam stigla."
},
{
"k": "mijenjati",
"e": "Mijenjam posao od sljedećeg mjeseca."
},
{
"k": "miješati",
"e": "Miješajte juhu da ne zagori."
},
{
"k": "mikrofon",
"e": "Govorite u mikrofon, molim vas."
},
{
"k": "mikrovalna",
"e": "Podgrij ručak u mikrovalnoj."
},
{
"k": "milost",
"e": "Molio je za milost."
},
{
"k": "ministar",
"e": "Ministar zdravstva je posjetio bolnicu."
},
{
"k": "ministarstvo",
"e": "Zahtjev treba poslati ministarstvu."
},
{
"k": "mir",
"e": "Ostavi me na miru."
},
{
"k": "miran",
"e": "Ovo je miran kvart."
},
{
"k": "miris",
"e": "Volim miris kave ujutro."
},
{
"k": "mirisati",
"e": "Kruh lijepo miriše."
},
{
"k": "miriti se",
"e": "Brat i sestra se brzo mire nakon svađe."
},
{
"k": "mirovati",
"e": "Nakon operacije morate mirovati."
},
{
"k": "misao",
"e": "To je lijepa misao."
},
{
"k": "misija",
"e": "Njegova misija je pomagati drugima."
},
{
"k": "misterija",
"e": "Njegov nestanak je i dalje misterija."
},
{
"k": "mjera",
"e": "Vlada je uvela nove mjere."
},
{
"k": "mjeriti",
"e": "Mjeri sobu prije kupnje namještaja."
},
{
"k": "mjeriti temperaturu",
"e": "Moram djetetu mjeriti temperaturu svaka tri sata."
},
{
"k": "mještanin",
"e": "Jedan mještanin nam je pokazao put."
},
{
"k": "mladić",
"e": "Mladić mi je pomogao s koferom."
},
{
"k": "mladost",
"e": "U mladosti sam puno putovao."
},
{
"k": "model",
"e": "Koji model auta voziš?"
},
{
"k": "modernizacija",
"e": "Modernizacija željeznice je počela."
},
{
"k": "modernizirati",
"e": "Žele modernizirati staru tvornicu."
},
{
"k": "moderno",
"e": "Stan je moderno uređen."
},
{
"k": "mogućnost",
"e": "Postoji mogućnost da padne kiša."
},
{
"k": "mokar",
"e": "Kosa mi je još mokra."
},
{
"k": "molba",
"e": "Predao sam molbu za posao."
},
{
"k": "molekula",
"e": "Molekula vode ima tri atoma."
},
{
"k": "momak",
"e": "Tko je onaj momak?"
},
{
"k": "momčad",
"e": "Naša momčad je pobijedila."
},
{
"k": "monolog",
"e": "Glumac je izveo dugi monolog."
},
{
"k": "moral",
"e": "Ova priča ima jasan moral."
},
{
"k": "moram",
"e": "Moram ići, kasnim."
},
{
"k": "mornar",
"e": "Mornar je radio na brodu dvadeset godina."
},
{
"k": "motel",
"e": "Prenoćili smo u motelu uz autocestu."
},
{
"k": "moć",
"e": "Novac ne daje uvijek moć."
},
{
"k": "moćan",
"e": "Ovo je moćno računalo."
},
{
"k": "mrak",
"e": "Vani je već mrak."
},
{
"k": "mrtav",
"e": "Nakon puta bio sam mrtav umoran."
},
{
"k": "mrziti",
"e": "Mrzim čekati."
},
{
"k": "mržnja",
"e": "Mržnja ništa ne rješava."
},
{
"k": "mudar",
"e": "Moj djed je bio mudar čovjek."
},
{
"k": "mudrost",
"e": "Starost donosi mudrost."
},
{
"k": "mučiti",
"e": "Muči me jedan problem."
},
{
"k": "mušterija",
"e": "Konobar je donio račun mušteriji."
},
{
"k": "nabava",
"e": "Nabava novih računala kasni."
},
{
"k": "nacija",
"e": "Cijela nacija je slavila pobjedu."
},
{
"k": "nacionalni",
"e": "Plitvice su nacionalni park."
},
{
"k": "nacrt",
"e": "Arhitekt nam je pokazao nacrt kuće."
},
{
"k": "nada",
"e": "Nada umire posljednja."
},
{
"k": "nadati se",
"e": "Nadam se da ćeš doći."
},
{
"k": "nadesno",
"e": "Na raskrižju skrenite nadesno."
},
{
"k": "nadležnost",
"e": "To nije u nadležnosti ovog ureda."
},
{
"k": "naglas",
"e": "Pročitaj tekst naglas."
},
{
"k": "naglasak",
"e": "Gdje je naglasak u ovoj riječi?"
},
{
"k": "naglasiti",
"e": "Želim naglasiti jednu stvar."
},
{
"k": "naglašavati",
"e": "Šef stalno naglašava važnost točnosti."
},
{
"k": "nagrada",
"e": "Dobila je nagradu za najbolju priču."
},
{
"k": "nagraditi",
"e": "Šef nas je nagradio slobodnim danom."
},
{
"k": "naivan",
"e": "Bio sam naivan i povjerovao mu."
},
{
"k": "nakit",
"e": "Ne nosim puno nakita."
},
{
"k": "nakon",
"e": "Nakon ručka idemo na kavu."
},
{
"k": "nalijevo",
"e": "Kod crkve skrenite nalijevo."
},
{
"k": "namjera",
"e": "Nisam imala namjeru te uvrijediti."
},
{
"k": "namjerno",
"e": "Nisam to namjerno napravio."
},
{
"k": "namjestiti",
"e": "Moram namjestiti sat na mobitelu."
},
{
"k": "napad",
"e": "Napad je bio iznenadan."
},
{
"k": "napadati",
"e": "Pas ne napada ljude."
},
{
"k": "napasti",
"e": "Lopov ga je napao na ulici."
},
{
"k": "napet",
"e": "Film je bio jako napet."
},
{
"k": "napokon",
"e": "Napokon je stiglo ljeto!"
},
{
"k": "napor",
"e": "Uložila je puno napora u projekt."
},
{
"k": "napredak",
"e": "Vidim velik napredak u tvom hrvatskom."
},
{
"k": "napredovanje",
"e": "Čekam napredovanje na poslu."
},
{
"k": "napredovati",
"e": "Brzo napreduješ u učenju."
},
{
"k": "naprosto",
"e": "To je naprosto nemoguće."
},
{
"k": "naprotiv",
"e": "Nisam umorna, naprotiv!"
},
{
"k": "narukvica",
"e": "Ovu narukvicu sam kupila u Dubrovniku."
},
{
"k": "nasilje",
"e": "Nasilje nikad nije rješenje."
},
{
"k": "naslov",
"e": "Kako glasi naslov knjige?"
},
{
"k": "nasmijati",
"e": "Uvijek me uspiješ nasmijati."
},
{
"k": "nastajati",
"e": "Gužve nastaju svako jutro."
},
{
"k": "nastati",
"e": "Problem je nastao zbog kvara."
},
{
"k": "nastavljati",
"e": "Unatoč kiši, nastavljamo šetnju."
},
{
"k": "nastojati",
"e": "Nastojim svaki dan čitati na hrvatskom."
},
{
"k": "natjecanje",
"e": "Pobijedila je na natjecanju."
},
{
"k": "natjecatelj",
"e": "Natjecatelji su spremni."
},
{
"k": "natjecati se",
"e": "Natječemo se za prvo mjesto."
},
{
"k": "natječaj",
"e": "Prijavila sam se na natječaj za posao."
},
{
"k": "naučiti",
"e": "Želim naučiti hrvatski."
},
{
"k": "naušnice",
"e": "Lijepe su ti naušnice!"
},
{
"k": "navlaš",
"e": "Navlaš me ne slušaš!"
},
{
"k": "navodno",
"e": "Navodno će sutra padati kiša."
},
{
"k": "nazadovati",
"e": "Bez vježbe znanje nazaduje."
},
{
"k": "nazočiti",
"e": "Ministar će nazočiti otvaranju."
},
{
"k": "neboder",
"e": "Ured je na desetom katu nebodera."
},
{
"k": "nedostajati",
"e": "Nedostaješ mi."
},
{
"k": "nedostatak",
"e": "Jedini nedostatak stana je buka."
},
{
"k": "nedostupan",
"e": "Broj koji ste birali je nedostupan."
},
{
"k": "neformalan",
"e": "Sastanak je bio neformalan."
},
{
"k": "neiskren",
"e": "Njegov osmijeh je neiskren."
},
{
"k": "nejasan",
"e": "Odgovor je nejasan."
},
{
"k": "neke",
"e": "Neke trgovine rade nedjeljom."
},
{
"k": "neljubazan",
"e": "Prodavač je bio neljubazan."
},
{
"k": "nemoćan",
"e": "Osjećao sam se nemoćno."
},
{
"k": "neobičan",
"e": "Imaš neobično ime."
},
{
"k": "neodlučan",
"e": "Kad kupujem odjeću, jako sam neodlučna."
},
{
"k": "neophodan",
"e": "Za ulaz je neophodan dokument."
},
{
"k": "neoprezan",
"e": "Bio je neoprezan na cesti."
},
{
"k": "neovisan",
"e": "Želim biti financijski neovisan."
},
{
"k": "nepažljiv",
"e": "Bio sam nepažljiv i razbio čašu."
},
{
"k": "nepoznat",
"e": "Ovaj broj mi je nepoznat."
},
{
"k": "nepošten",
"e": "To je nepošten postupak."
},
{
"k": "nepravda",
"e": "To je velika nepravda."
},
{
"k": "neprijatelj",
"e": "Nemaš ovdje neprijatelja."
},
{
"k": "neproziran",
"e": "Kupila sam neprozirne zavjese."
},
{
"k": "nerazuman",
"e": "To je nerazuman zahtjev."
},
{
"k": "nered",
"e": "U sobi je strašan nered."
},
{
"k": "nesiguran",
"e": "Još sam nesigurna u hrvatskom."
},
{
"k": "nesposoban",
"e": "Osjećao se nesposobnim za taj posao."
},
{
"k": "nespreman",
"e": "Bila sam potpuno nespremna za ispit."
},
{
"k": "nesreća",
"e": "Na autocesti se dogodila prometna nesreća."
},
{
"k": "nestabilan",
"e": "Vrijeme je ovih dana nestabilno."
},
{
"k": "nestajati",
"e": "Nestaje mi strpljenja."
},
{
"k": "nestati",
"e": "Struja je nestala na sat vremena."
},
{
"k": "nestrpljiv",
"e": "Ne budi tako nestrpljiv."
},
{
"k": "nesvijest",
"e": "Pala je u nesvijest od vrućine."
},
{
"k": "nesvjestica",
"e": "Na vrućini sam osjetila nesvjesticu."
},
{
"k": "netočan",
"e": "Ovaj podatak je netočan."
},
{
"k": "netočno",
"e": "Odgovorio je netočno na pitanje."
},
{
"k": "neugodan",
"e": "Imao sam neugodan razgovor sa šefom."
},
{
"k": "neuredan",
"e": "Stol mu je uvijek neuredan."
},
{
"k": "neuspjeh",
"e": "Neuspjeh je dio učenja."
},
{
"k": "neuspješan",
"e": "Prvi pokušaj je bio neuspješan."
},
{
"k": "neučinkovit",
"e": "Stari sustav je bio neučinkovit."
},
{
"k": "nevin",
"e": "Sud je zaključio da je nevin."
},
{
"k": "nevinost",
"e": "Odvjetnik je dokazao njegovu nevinost."
},
{
"k": "nevjerojatan",
"e": "Pogled s brda je nevjerojatan."
},
{
"k": "nezadovoljan",
"e": "Gost je bio nezadovoljan sobom."
},
{
"k": "nezaposlenost",
"e": "Nezaposlenost je ove godine manja."
},
{
"k": "nezreo",
"e": "Ove breskve su još nezrele."
},
{
"k": "nizina",
"e": "Slavonija je velika nizina."
},
{
"k": "ništavan",
"e": "Ugovor je proglašen ništavnim."
},
{
"k": "norma",
"e": "Pravopis propisuje jezičnu normu."
},
{
"k": "novinarstvo",
"e": "Studira novinarstvo."
},
{
"k": "novine",
"e": "Djed svako jutro čita novine."
},
{
"k": "noćenje",
"e": "Noćenje s doručkom košta osamdeset eura."
},
{
"k": "obavijest",
"e": "Na vratima je obavijest o radnom vremenu."
},
{
"k": "obavijestiti",
"e": "Molim vas, obavijestite me o promjenama."
},
{
"k": "obavještavati",
"e": "Redovito vas obavještavamo o novostima."
},
{
"k": "obećanje",
"e": "Održao je obećanje."
},
{
"k": "obećavati",
"e": "Ne obećavaj ono što ne možeš ispuniti."
},
{
"k": "običaj",
"e": "To je stari dalmatinski običaj."
},
{
"k": "običan",
"e": "Bio je to običan dan."
},
{
"k": "objava",
"e": "Pročitao sam tvoju objavu na Facebooku."
},
{
"k": "objašnjenje",
"e": "Hvala na objašnjenju."
},
{
"k": "objekt",
"e": "Objekt je pod videonadzorom."
},
{
"k": "oblik",
"e": "Kolač je u obliku srca."
},
{
"k": "obnavljati",
"e": "Grad obnavlja stari most."
},
{
"k": "obnoviti",
"e": "Moram obnoviti osobnu iskaznicu."
},
{
"k": "obožavati",
"e": "Obožavam more."
},
{
"k": "obrana",
"e": "Naša obrana je danas igrala odlično."
},
{
"k": "obrazovanje",
"e": "Obrazovanje je besplatno."
},
{
"k": "obrt",
"e": "Otvorio je obrt za popravak računala."
},
{
"k": "obrtnik",
"e": "Obrtnik je popravio krov."
},
{
"k": "obuhvatiti",
"e": "Izvještaj mora obuhvatiti sve troškove."
},
{
"k": "obuhvaćati",
"e": "Cijena obuhvaća prijevoz i smještaj."
},
{
"k": "obujam",
"e": "Obujam posla se povećao."
},
{
"k": "obuća",
"e": "Na plaži trebate udobnu obuću."
},
{
"k": "obveza",
"e": "Danas imam puno obveza."
},
{
"k": "ocean",
"e": "Nikad nisam vidjela ocean."
},
{
"k": "ocijeniti",
"e": "Molimo vas da ocijenite našu uslugu."
},
{
"k": "ocjenjivati",
"e": "Profesor ocjenjuje ispite."
},
{
"k": "odbaciti",
"e": "Nemoj odmah odbaciti tu ideju."
},
{
"k": "odbijati",
"e": "Dijete odbija jesti povrće."
},
{
"k": "odbijenica",
"e": "Dobio sam odbijenicu za posao."
},
{
"k": "odbiti",
"e": "Morala sam odbiti poziv."
},
{
"k": "odbojan",
"e": "Njegovo ponašanje je odbojno."
},
{
"k": "odgađati",
"e": "Ne odgađaj posjet liječniku."
},
{
"k": "odgoditi",
"e": "Moramo odgoditi sastanak."
},
{
"k": "odgovoran",
"e": "Tko je odgovoran za ovo?"
},
{
"k": "odgovornost",
"e": "Preuzimam punu odgovornost."
},
{
"k": "odjava",
"e": "Odjava iz hotela je do jedanaest sati."
},
{
"k": "odjaviti",
"e": "Moram odjaviti stari auto."
},
{
"k": "odjaviti se",
"e": "Moramo se odjaviti iz hotela do podne."
},
{
"k": "odlazak",
"e": "Moj odlazak je u nedjelju."
},
{
"k": "odlaziti",
"e": "Kad odlaziš na godišnji?"
},
{
"k": "odletjeti",
"e": "Avion je odletio na vrijeme."
},
{
"k": "odluka",
"e": "To je bila teška odluka."
},
{
"k": "odlučan",
"e": "Odlučna je da uspije."
},
{
"k": "odlučiti",
"e": "Odlučila sam ostati u Zagrebu."
},
{
"k": "odlučivati",
"e": "O tome ne odlučujem ja."
},
{
"k": "odmoran",
"e": "Nakon godišnjeg sam odmoran."
},
{
"k": "odnos",
"e": "Imamo dobar odnos sa susjedima."
},
{
"k": "odobravati",
"e": "Roditelji ne odobravaju moj plan."
},
{
"k": "odobrenje",
"e": "Za gradnju trebate odobrenje."
},
{
"k": "odobriti",
"e": "Banka mi je odobrila kredit."
},
{
"k": "odredba",
"e": "Prema odredbi zakona morate platiti porez."
},
{
"k": "odrediti",
"e": "Liječnik će odrediti terapiju."
},
{
"k": "odredište",
"e": "Stigli ste na odredište."
},
{
"k": "održati",
"e": "Sastanak ćemo održati u petak."
},
{
"k": "održavati",
"e": "Tko održava zgradu?"
},
{
"k": "održivost",
"e": "Tvrtka brine o održivosti."
},
{
"k": "odustajati",
"e": "Nemoj odustajati!"
},
{
"k": "odustati",
"e": "Ne smiješ sada odustati."
},
{
"k": "oduševiti",
"e": "Predstava je oduševila publiku."
},
{
"k": "odvajati",
"e": "Odvajamo otpad za recikliranje."
},
{
"k": "odvjetnik",
"e": "Trebam dobrog odvjetnika."
},
{
"k": "odvjetništvo",
"e": "Radi u odvjetništvu."
},
{
"k": "odvojeno",
"e": "Možemo li platiti odvojeno?"
},
{
"k": "odvojenost",
"e": "Odvojenost od obitelji je teška."
},
{
"k": "odšteta",
"e": "Dobili smo odštetu za izgubljenu prtljagu."
},
{
"k": "ogledalo",
"e": "Pogledaj se u ogledalo."
},
{
"k": "ograda",
"e": "Pas je preskočio ogradu."
},
{
"k": "ohol",
"e": "Njegov ohol stav smeta kolegama."
},
{
"k": "ohrabriti",
"e": "Tvoje riječi su me ohrabrile."
},
{
"k": "oklijevati",
"e": "Nemoj oklijevati, nazovi ga."
},
{
"k": "okolica",
"e": "Okolica Zagreba je lijepa za izlete."
},
{
"k": "okolina",
"e": "Djeca se brzo prilagode novoj okolini."
},
{
"k": "okoliš",
"e": "Moramo čuvati okoliš."
},
{
"k": "okolnost",
"e": "Zbog nepredviđenih okolnosti let je otkazan."
},
{
"k": "okolo",
"e": "Moramo ići okolo, cesta je zatvorena."
},
{
"k": "okriviti",
"e": "Okrivili su ga za nesreću."
},
{
"k": "okruglo",
"e": "Taj stan košta okruglo sto tisuća eura."
},
{
"k": "okruženje",
"e": "Radim u ugodnom okruženju."
},
{
"k": "okus",
"e": "Ovaj sladoled ima okus jagode."
},
{
"k": "okusiti",
"e": "Okusi ovu juhu."
},
{
"k": "olakšanje",
"e": "Kakvo olakšanje!"
},
{
"k": "olakšati",
"e": "Ova aplikacija može olakšati život."
},
{
"k": "omesti",
"e": "Buka me može omesti u radu."
},
{
"k": "omogućavati",
"e": "Ova aplikacija omogućava plaćanje mobitelom."
},
{
"k": "omogućiti",
"e": "Stipendija mi je omogućila studij."
},
{
"k": "onak",
"e": "Bilo je onak, ništa posebno."
},
{
"k": "opeklina",
"e": "Ova krema pomaže kod opekline."
},
{
"k": "operacija",
"e": "Operacija je prošla dobro."
},
{
"k": "operirati",
"e": "Sutra ga operiraju."
},
{
"k": "opisati",
"e": "Možete li opisati lopova?"
},
{
"k": "opisivati",
"e": "Knjiga opisuje život na otoku."
},
{
"k": "oporavak",
"e": "Oporavak će trajati mjesec dana."
},
{
"k": "oporaviti se",
"e": "Brzo se oporavi!"
},
{
"k": "oporba",
"e": "Oporba je kritizirala vladu."
},
{
"k": "oprati",
"e": "Moram oprati kosu."
},
{
"k": "opravdati",
"e": "Kako ćeš opravdati izostanak?"
},
{
"k": "opraštati",
"e": "Teško mi je opraštati laži."
},
{
"k": "oprostiti",
"e": "Možeš li mi oprostiti?"
},
{
"k": "opskrba",
"e": "Opskrba vodom je prekinuta."
},
{
"k": "opstati",
"e": "Mali dućani teško opstaju."
},
{
"k": "optika",
"e": "Naočale sam kupila u optici."
},
{
"k": "optuženi",
"e": "Optuženi se nije pojavio na sudu."
},
{
"k": "optužiti",
"e": "Optužili su ga za krađu."
},
{
"k": "opustiti se",
"e": "Sjedni i opusti se."
},
{
"k": "opuštanje",
"e": "Ovaj vikend je samo za opuštanje."
},
{
"k": "opušten",
"e": "Na moru sam uvijek opušten."
},
{
"k": "opći",
"e": "Imam opći dojam da je sve u redu."
},
{
"k": "općina",
"e": "Općina je obnovila cestu."
},
{
"k": "ordinacija",
"e": "Ordinacija radi popodne."
},
{
"k": "organizacija",
"e": "Organizacija putovanja trajala je tjednima."
},
{
"k": "organizator",
"e": "Organizator koncerta je otkazao nastup."
},
{
"k": "organizirati",
"e": "Organiziramo zabavu za Dašin rođendan."
},
{
"k": "osiguranje",
"e": "Trebam zdravstveno osiguranje."
},
{
"k": "osjetiti",
"e": "Osjetila sam miris mora."
},
{
"k": "osjetiti bol",
"e": "Pri hodanju sam osjetila bol u nozi."
},
{
"k": "osjećaj",
"e": "Imam dobar osjećaj u vezi s tim."
},
{
"k": "osjećati",
"e": "Osjećam se bolje."
},
{
"k": "osloboditi",
"e": "Policija je oslobodila taoce."
},
{
"k": "osloboditi se",
"e": "Moram se osloboditi stresa."
},
{
"k": "oslonac",
"e": "Obitelj mi je najveći oslonac."
},
{
"k": "osmijeh",
"e": "Imaš lijep osmijeh."
},
{
"k": "osmisliti",
"e": "Moramo osmisliti novu kampanju."
},
{
"k": "osoba",
"e": "Stol za četiri osobe, molim."
},
{
"k": "osoblje",
"e": "Osoblje hotela je jako ljubazno."
},
{
"k": "osposobljen",
"e": "Osoblje je osposobljeno za prvu pomoć."
},
{
"k": "ostajati",
"e": "Ne ostajem dugo, samo pet minuta."
},
{
"k": "ostaviti",
"e": "Gdje mogu ostaviti prtljagu?"
},
{
"k": "ostvariti",
"e": "Ostvarila sam svoj san."
},
{
"k": "osuditi",
"e": "Sud ga je osudio na dvije godine."
},
{
"k": "osuđivati",
"e": "Nemoj osuđivati ljude."
},
{
"k": "osvetiti se",
"e": "Htio se osvetiti, ali se predomislio."
},
{
"k": "otežati",
"e": "Kiša će otežati promet."
},
{
"k": "otkaz",
"e": "Dao je otkaz na poslu."
},
{
"k": "otkazati",
"e": "Moram otkazati rezervaciju."
},
{
"k": "otključati",
"e": "Ne mogu otključati vrata."
},
{
"k": "otkriti",
"e": "Ne smiješ nikome otkriti tajnu."
},
{
"k": "otkrivati",
"e": "Svaki dan otkrivam nešto novo."
},
{
"k": "otkriće",
"e": "Ovo otkriće je promijenilo medicinu."
},
{
"k": "otpad",
"e": "Otpad odvajamo po bojama kontejnera."
},
{
"k": "otpor",
"e": "Plan je naišao na otpor."
},
{
"k": "otpremnica",
"e": "Otpremnica je u paketu."
},
{
"k": "otputovati",
"e": "Sutra otputujem na more."
},
{
"k": "otrčati",
"e": "Dijete je otrčalo do mame."
},
{
"k": "otvarati",
"e": "Trgovina se otvara u osam."
},
{
"k": "ovisan",
"e": "Previše sam ovisan o mobitelu."
},
{
"k": "ovisiti",
"e": "Sve ovisi o vremenu."
},
{
"k": "ozbiljan",
"e": "Ovo je ozbiljan problem."
},
{
"k": "ozdraviti",
"e": "Nadam se da ćeš brzo ozdraviti."
},
{
"k": "ozlijediti",
"e": "Pazi da ne ozlijediš ruku."
},
{
"k": "ozljeda",
"e": "Ozljeda koljena nije teška."
},
{
"k": "očaj",
"e": "U očaju je nazvao policiju."
},
{
"k": "očarati",
"e": "Dubrovnik će te očarati."
},
{
"k": "očekivanje",
"e": "Film je ispunio moja očekivanja."
},
{
"k": "očigledan",
"e": "Odgovor je očigledan."
},
{
"k": "oštar",
"e": "Pazi, nož je oštar!"
},
{
"k": "pacijent",
"e": "Pacijent čeka u čekaonici."
},
{
"k": "pakirati",
"e": "Sutra putujem, moram pakirati kofer."
},
{
"k": "pakt",
"e": "Države su potpisale pakt."
},
{
"k": "pametan",
"e": "Tvoj sin je jako pametan."
},
{
"k": "pamćenje",
"e": "Imam loše pamćenje za imena."
},
{
"k": "papirologija",
"e": "Papirologija za boravak traje mjesecima."
},
{
"k": "paragraf",
"e": "Pročitaj prvi paragraf."
},
{
"k": "parkirati",
"e": "Gdje mogu parkirati?"
},
{
"k": "parlament",
"e": "Parlament je izglasao novi zakon."
},
{
"k": "partner",
"e": "Moj partner radi u Splitu."
},
{
"k": "partnerica",
"e": "Ovo je moja partnerica Darja."
},
{
"k": "partnerstvo",
"e": "Dvije tvrtke su sklopile partnerstvo."
},
{
"k": "pasivnost",
"e": "Njegova pasivnost me ljuti."
},
{
"k": "pasti u nesvijest",
"e": "Od vrućine je mogla pasti u nesvijest."
},
{
"k": "patiti",
"e": "Pati od glavobolje."
},
{
"k": "pauza",
"e": "Napravimo pauzu od deset minuta."
},
{
"k": "paziti",
"e": "Pazite na stepenice!"
},
{
"k": "pažljiv",
"e": "Budi pažljiv s tim staklom."
},
{
"k": "pedagogija",
"e": "Studirala je pedagogiju."
},
{
"k": "pegla",
"e": "Pegla je u ormaru."
},
{
"k": "peglati",
"e": "Ne volim peglati košulje."
},
{
"k": "periferija",
"e": "Živimo na periferiji grada."
},
{
"k": "peći",
"e": "Baka peče kruh svake subote."
},
{
"k": "pečat",
"e": "Na dokumentu nedostaje pečat."
},
{
"k": "pijesak",
"e": "Djeca se igraju u pijesku."
},
{
"k": "pilot",
"e": "Pilot je najavio slijetanje."
},
{
"k": "pisac",
"e": "On je poznati hrvatski pisac."
},
{
"k": "pista",
"e": "Avion je na pisti."
},
{
"k": "pjesma",
"e": "Ova pjesma mi se jako sviđa."
},
{
"k": "pjesnik",
"e": "Tin Ujević je poznati hrvatski pjesnik."
},
{
"k": "pješak",
"e": "Pješak ima prednost na zebri."
},
{
"k": "pješačiti",
"e": "Volimo pješačiti po planinama."
},
{
"k": "plah",
"e": "Mačka je jako plaha."
},
{
"k": "plakanje",
"e": "Nakon plakanja dijete je zaspalo."
},
{
"k": "plastika",
"e": "Plastiku bacamo u žuti kontejner."
},
{
"k": "plaćati",
"e": "Režije plaćam preko aplikacije."
},
{
"k": "plač",
"e": "Iz sobe se čuo plač djeteta."
},
{
"k": "plašljiv",
"e": "Naš pas je plašljiv."
},
{
"k": "ples",
"e": "Idemo na tečaj plesa."
},
{
"k": "plesti",
"e": "Baka plete džemper."
},
{
"k": "plin",
"e": "Osjećam miris plina!"
},
{
"k": "plitak",
"e": "Ovdje je more plitko, idealno za djecu."
},
{
"k": "plitkoća",
"e": "Zbog plitkoće uvale brodovi ne mogu ući."
},
{
"k": "plod",
"e": "Ovo drvo daje slatke plodove."
},
{
"k": "plodonosan",
"e": "Bio je to plodonosan sastanak."
},
{
"k": "pobijediti",
"e": "Naša momčad je pobijedila tri nula."
},
{
"k": "pobjednik",
"e": "Tko je pobjednik utakmice?"
},
{
"k": "pobjeći",
"e": "Pas je pobjegao iz dvorišta."
},
{
"k": "poboljšati",
"e": "Želim poboljšati svoj hrvatski."
},
{
"k": "poboljšavati",
"e": "Svaki dan poboljšavam svoj hrvatski."
},
{
"k": "pod",
"e": "Pod je mokar, pazi!"
},
{
"k": "podaci",
"e": "Unesite svoje podatke u obrazac."
},
{
"k": "podijeliti",
"e": "Podijelimo račun na pola."
},
{
"k": "podizati",
"e": "Ne smijem podizati teške stvari."
},
{
"k": "podići",
"e": "Moram podići novac na bankomatu."
},
{
"k": "podnijeti",
"e": "Ne mogu podnijeti ovu buku."
},
{
"k": "podrška",
"e": "Hvala vam na podršci."
},
{
"k": "podržati",
"e": "Uvijek ću te podržati."
},
{
"k": "podsvijest",
"e": "Strah se skriva u podsvijesti."
},
{
"k": "poduzetnik",
"e": "Moj otac je poduzetnik."
},
{
"k": "poduzetništvo",
"e": "Država potiče malo poduzetništvo."
},
{
"k": "poduzeće",
"e": "Radim u malom poduzeću."
},
{
"k": "poglavlje",
"e": "Pročitaj prvo poglavlje do sutra."
},
{
"k": "pogled",
"e": "Soba ima pogled na more."
},
{
"k": "pogoršati",
"e": "Hladnoća može pogoršati kašalj."
},
{
"k": "pogrešan",
"e": "Ušli smo u pogrešan autobus."
},
{
"k": "pogreška",
"e": "Ispričavam se, to je moja pogreška."
},
{
"k": "pohrana",
"e": "Fotografije su na pohrani u oblaku."
},
{
"k": "pohvaliti",
"e": "Šef me pohvalio za projekt."
},
{
"k": "pohvaljivati",
"e": "Učiteljica često pohvaljuje mog sina."
},
{
"k": "pojasniti",
"e": "Možete li pojasniti ovo pravilo?"
},
{
"k": "pojaviti se",
"e": "Problem se pojavio nakon ažuriranja."
},
{
"k": "pojedini",
"e": "Pojedini vlakovi ne voze nedjeljom."
},
{
"k": "pokazivati",
"e": "Navigacija pokazuje krivi put."
},
{
"k": "poklon",
"e": "Kupila sam poklon za mamu."
},
{
"k": "pokloniti",
"e": "Što ćemo pokloniti Daši za rođendan?"
},
{
"k": "poklopac",
"e": "Stavi poklopac na lonac."
},
{
"k": "pokopati",
"e": "Djeda su pokopali u rodnom selu."
},
{
"k": "pokus",
"e": "Na satu kemije radili smo pokus."
},
{
"k": "pokušavati",
"e": "Već sat vremena pokušavam nazvati."
},
{
"k": "pokvaren",
"e": "Hladnjak je pokvaren."
},
{
"k": "pola",
"e": "Vidimo se u pola osam."
},
{
"k": "polaziti",
"e": "Vlak polazi s drugog perona."
},
{
"k": "polica",
"e": "Knjige su na gornjoj polici."
},
{
"k": "politika",
"e": "Ne zanima me politika."
},
{
"k": "politički",
"e": "To je politički problem."
},
{
"k": "poljoprivreda",
"e": "Slavonija je poznata po poljoprivredi."
},
{
"k": "položaj",
"e": "Kuća ima odličan položaj uz more."
},
{
"k": "pomaknuti",
"e": "Možete li pomaknuti auto?"
},
{
"k": "pomilovanje",
"e": "Predsjednik je odbio zahtjev za pomilovanje."
},
{
"k": "pomilovati",
"e": "Dijete je pomilovalo mačku."
},
{
"k": "pomiriti se",
"e": "Napokon su se pomirili."
},
{
"k": "pomorac",
"e": "Moj djed je bio pomorac."
},
{
"k": "pomoć",
"e": "Hvala vam na pomoći."
},
{
"k": "ponašanje",
"e": "Njegovo ponašanje je neprihvatljivo."
},
{
"k": "ponašati se",
"e": "Djeca se lijepo ponašaju."
},
{
"k": "ponijeti",
"e": "Ne zaboravi ponijeti kišobran."
},
{
"k": "ponosan",
"e": "Ponosan sam na tebe."
},
{
"k": "ponuda",
"e": "Imamo posebnu ponudu za obitelji."
},
{
"k": "popiti",
"e": "Idemo popiti kavu."
},
{
"k": "poplava",
"e": "Poplava je uništila polja."
},
{
"k": "porast",
"e": "Bilježimo porast broja turista."
},
{
"k": "poraz",
"e": "Ovaj poraz je bio težak."
},
{
"k": "porez",
"e": "Porez je uključen u cijenu."
},
{
"k": "poricati",
"e": "Optuženi poriče krađu."
},
{
"k": "porota",
"e": "Porota je donijela odluku."
},
{
"k": "poseban",
"e": "Danas je poseban dan."
},
{
"k": "posjećivati",
"e": "Ljeti često posjećujem baku na otoku."
},
{
"k": "posljedica",
"e": "To je posljedica loše odluke."
},
{
"k": "poslodavac",
"e": "Poslodavac mi je dao slobodan dan."
},
{
"k": "poslodavatelj",
"e": "Poslodavatelj mora prijaviti radnika."
},
{
"k": "poslovanje",
"e": "Tvrtka je proširila poslovanje."
},
{
"k": "poslušan",
"e": "Naš pas je jako poslušan."
},
{
"k": "postizati",
"e": "Učenici postižu dobre rezultate."
},
{
"k": "postići",
"e": "Želim postići razinu B1."
},
{
"k": "postojati",
"e": "Postoji li jeftiniji let?"
},
{
"k": "posuditi",
"e": "Možeš li mi posuditi olovku?"
},
{
"k": "posuđivati",
"e": "Ne volim posuđivati novac."
},
{
"k": "posvađati se",
"e": "Jučer sam se posvađala s bratom."
},
{
"k": "posvetiti se",
"e": "Želim se posvetiti obitelji."
},
{
"k": "posvuda",
"e": "Posvuda je bilo turista."
},
{
"k": "potez",
"e": "To je bio pametan potez."
},
{
"k": "potomak",
"e": "On je potomak poznate obitelji."
},
{
"k": "potonuti",
"e": "Brod je potonuo kraj otoka."
},
{
"k": "potražnja",
"e": "Potražnja za stanovima je velika."
},
{
"k": "potreba",
"e": "Nema potrebe za brigom."
},
{
"k": "potreban",
"e": "Je li potreban dokument s fotografijom?"
},
{
"k": "potres",
"e": "Potres se osjetio u cijelom gradu."
},
{
"k": "potrošač",
"e": "Potrošači traže niže cijene."
},
{
"k": "potvrditi",
"e": "Molim vas, potvrdite rezervaciju."
},
{
"k": "poučavati",
"e": "Ona poučava djecu engleski."
},
{
"k": "povezanost",
"e": "Povezanost otoka s kopnom je dobra."
},
{
"k": "povezati",
"e": "Povezat ću vas s kolegom."
},
{
"k": "povećati se",
"e": "Broj stanovnika se povećao."
},
{
"k": "povećavati",
"e": "Grad povećava broj autobusa."
},
{
"k": "povijest",
"e": "Zanima me hrvatska povijest."
},
{
"k": "povjerenje",
"e": "Imam povjerenja u tebe."
},
{
"k": "povjerovati",
"e": "Nisam mogla povjerovati."
},
{
"k": "povod",
"e": "Koji je povod za proslavu?"
},
{
"k": "povući",
"e": "Vrata treba povući prema sebi."
},
{
"k": "pozivati",
"e": "Pozivamo vas na našu proslavu."
},
{
"k": "pozivnica",
"e": "Dobili smo pozivnicu za vjenčanje."
},
{
"k": "poznanik",
"e": "On nije prijatelj, samo poznanik."
},
{
"k": "poznat",
"e": "Ovaj restoran je poznat po ribi."
},
{
"k": "pozornica",
"e": "Glumci su izašli na pozornicu."
},
{
"k": "pozvati hitnu pomoć",
"e": "Brzo, moramo pozvati hitnu pomoć!"
},
{
"k": "poći",
"e": "Moram poći ranije."
},
{
"k": "pošten",
"e": "On je pošten čovjek."
},
{
"k": "poštenje",
"e": "Cijenim njegovo poštenje."
},
{
"k": "poštovanje",
"e": "S poštovanjem, Darja Petrenko."
},
{
"k": "poštovati",
"e": "Treba poštovati pravila."
},
{
"k": "požar",
"e": "Požar je izbio u šumi."
},
{
"k": "požuriti",
"e": "Moramo požuriti, vlak polazi!"
},
{
"k": "požurivati",
"e": "Nemoj me požurivati!"
},
{
"k": "prag",
"e": "Ostavi cipele na pragu."
},
{
"k": "praksa",
"e": "Ljeti radim praksu u hotelu."
},
{
"k": "prav",
"e": "Ovaj zid nije prav."
},
{
"k": "prava",
"e": "Svi imamo jednaka prava."
},
{
"k": "pravda",
"e": "Tražimo pravdu."
},
{
"k": "pravednost",
"e": "Pravednost je važna u svakom sudu."
},
{
"k": "pravilo",
"e": "Ovo pravilo vrijedi za sve."
},
{
"k": "pravilo igre",
"e": "Objasni mi pravilo igre."
},
{
"k": "pravnik",
"e": "Moja sestra je pravnik."
},
{
"k": "pravomoćnost",
"e": "Presuda je postala pravomoćna."
},
{
"k": "pravopis",
"e": "Provjeri pravopis u tekstu."
},
{
"k": "prazan",
"e": "Hladnjak je prazan."
},
{
"k": "praznik",
"e": "Sutra je praznik, banke ne rade."
},
{
"k": "preboljeti",
"e": "Trebalo mi je vremena da preboljem rastanak."
},
{
"k": "predak",
"e": "Moji preci su došli iz Like."
},
{
"k": "predati",
"e": "Morate predati zahtjev do petka."
},
{
"k": "predavač",
"e": "Predavač je kasnio deset minuta."
},
{
"k": "predložiti",
"e": "Mogu li nešto predložiti?"
},
{
"k": "prednost",
"e": "Pješaci imaju prednost."
},
{
"k": "predomisliti se",
"e": "Predomislila sam se, ostajem."
},
{
"k": "predsjednik",
"e": "Predsjednik je održao govor."
},
{
"k": "predstava",
"e": "Predstava počinje u osam."
},
{
"k": "predstaviti se",
"e": "Dopustite da se predstavim."
},
{
"k": "predstavljati",
"e": "Ovaj projekt predstavlja velik izazov."
},
{
"k": "predstavnik",
"e": "Razgovarao sam s predstavnikom tvrtke."
},
{
"k": "predvidjeti",
"e": "Nitko nije mogao predvidjeti ovu situaciju."
},
{
"k": "predviđati",
"e": "Prognoza predviđa kišu."
},
{
"k": "preferirati",
"e": "Preferiram čaj umjesto kave."
},
{
"k": "pregledati",
"e": "Liječnik mora pregledati dijete."
},
{
"k": "pregovarati",
"e": "Sindikat pregovara s upravom."
},
{
"k": "pregovor",
"e": "Pregovor o cijeni trajao je dugo."
},
{
"k": "pregovori",
"e": "Pregovori traju već tjedan dana."
},
{
"k": "prekinuti",
"e": "Ne prekidaj me dok govorim."
},
{
"k": "preko",
"e": "Idemo preko mosta."
},
{
"k": "prekršaj",
"e": "Prolazak kroz crveno je prekršaj."
},
{
"k": "prelaziti",
"e": "Djeca prelaze cestu na zebri."
},
{
"k": "premijer",
"e": "Premijer je posjetio poplavljena područja."
},
{
"k": "preporuka",
"e": "Imate li preporuku za dobar restoran?"
},
{
"k": "prepoznati",
"e": "Nisam te prepoznala!"
},
{
"k": "prespavati",
"e": "Možemo li prespavati kod vas?"
},
{
"k": "prestrašiti",
"e": "Prestrašio si me!"
},
{
"k": "presuda",
"e": "Presuda će biti izrečena sutra."
},
{
"k": "pretpostaviti",
"e": "Pretpostavimo da vlak kasni sat vremena."
},
{
"k": "pretpostavljati",
"e": "Pretpostavljam da ćeš doći kasnije."
},
{
"k": "pretvarati se",
"e": "Ne pretvaraj se da spavaš."
},
{
"k": "preuzeti",
"e": "Paket možete preuzeti na pošti."
},
{
"k": "preuzimanje",
"e": "Preuzimanje paketa je moguće do šest."
},
{
"k": "preuzimati",
"e": "Aplikacija se predugo preuzima."
},
{
"k": "prevariti",
"e": "Prodavač me prevario."
},
{
"k": "prevoditelj",
"e": "Trebam sudskog prevoditelja."
},
{
"k": "prezentacija",
"e": "Sutra imam prezentaciju na poslu."
},
{
"k": "prezirati",
"e": "Prezirem laž."
},
{
"k": "preživjeti",
"e": "Svi putnici su preživjeli nesreću."
},
{
"k": "preživljavati",
"e": "Mnoge obitelji teško preživljavaju."
},
{
"k": "prigovor",
"e": "Imam prigovor na račun."
},
{
"k": "prihod",
"e": "Prihod od turizma je porastao."
},
{
"k": "prihvatiti",
"e": "Prihvatila sam ponudu za posao."
},
{
"k": "prihvaćati",
"e": "Prihvaćate li kartice?"
},
{
"k": "prijateljstvo",
"e": "Naše prijateljstvo traje dvadeset godina."
},
{
"k": "prijaviti",
"e": "Moram prijaviti boravak u policiji."
},
{
"k": "prijaviti se",
"e": "Prijavila sam se na tečaj hrvatskog."
},
{
"k": "prijenos",
"e": "Prijenos utakmice je na prvom programu."
},
{
"k": "prijetnja",
"e": "Policija je shvatila prijetnju ozbiljno."
},
{
"k": "prilagoditi",
"e": "Prilagodit ćemo plan vašim željama."
},
{
"k": "prilagoditi se",
"e": "Brzo sam se prilagodila novom poslu."
},
{
"k": "prilagođavati",
"e": "Polako se prilagođavamo životu ovdje."
},
{
"k": "primijetiti",
"e": "Nisam primijetio da si se ošišala."
},
{
"k": "primiti",
"e": "Jeste li primili moj mail?"
},
{
"k": "primjer",
"e": "Možete li dati primjer?"
},
{
"k": "primjećivati",
"e": "Počinjem primjećivati razlike u naglasku."
},
{
"k": "princip",
"e": "Iz principa ne radim nedjeljom."
},
{
"k": "prioritet",
"e": "Zdravlje mi je prioritet."
},
{
"k": "pripadati",
"e": "Kome pripada ovaj kaput?"
},
{
"k": "priručnik",
"e": "Pročitaj priručnik za uređaj."
},
{
"k": "prisjetiti se",
"e": "Pokušaj se prisjetiti gdje si ostavio ključeve."
},
{
"k": "pristojba",
"e": "Za putovnicu se plaća pristojba."
},
{
"k": "pristojnost",
"e": "Pristojnost ništa ne košta."
},
{
"k": "prisustvovati",
"e": "Moram prisustvovati sastanku."
},
{
"k": "pritisak",
"e": "Na poslu sam pod velikim pritiskom."
},
{
"k": "pritisnuti",
"e": "Pritisnite zeleni gumb."
},
{
"k": "privatan",
"e": "Ovo je privatan parking."
},
{
"k": "privatni",
"e": "Ovo je privatni posjed."
},
{
"k": "privlačan",
"e": "Ponuda je jako privlačna."
},
{
"k": "privući",
"e": "Moramo privući više turista."
},
{
"k": "priznati",
"e": "Priznajem, pogriješio sam."
},
{
"k": "proces",
"e": "Proces dobivanja vize je dug."
},
{
"k": "procijeniti",
"e": "Teško je procijeniti cijenu."
},
{
"k": "produženje",
"e": "Zatražio sam produženje vize."
},
{
"k": "profil",
"e": "Ažuriraj svoj profil."
},
{
"k": "programirati",
"e": "Moj sin zna programirati."
},
{
"k": "proizvod",
"e": "Ovo je domaći proizvod."
},
{
"k": "proizvoditi",
"e": "Ova tvornica proizvodi namještaj."
},
{
"k": "proizvodnja",
"e": "Proizvodnja maslinova ulja je porasla."
},
{
"k": "projektirati",
"e": "Arhitekt projektira novu školu."
},
{
"k": "promet",
"e": "U centru je gust promet."
},
{
"k": "promijeniti",
"e": "Želim promijeniti rezervaciju."
},
{
"k": "promijeniti se",
"e": "Grad se jako promijenio."
},
{
"k": "promisliti",
"e": "Promisli prije nego što odgovoriš."
},
{
"k": "pronalaziti",
"e": "Uvijek pronalaziš izgovor."
},
{
"k": "propasti",
"e": "Plan je propao."
},
{
"k": "propis",
"e": "Prema propisima, pušenje je zabranjeno."
},
{
"k": "propisati",
"e": "Liječnik mi je propisao antibiotik."
},
{
"k": "proputovati",
"e": "Proputovali smo cijelu Dalmaciju."
},
{
"k": "proračun",
"e": "Proračun za putovanje je ograničen."
},
{
"k": "proslava",
"e": "Proslava je u subotu u osam."
},
{
"k": "prostor",
"e": "U autu nema prostora za kofer."
},
{
"k": "prosvjed",
"e": "Na trgu je bio prosvjed."
},
{
"k": "protiv",
"e": "Jesi li za ili protiv?"
},
{
"k": "protivnik",
"e": "Protivnik je bio jak."
},
{
"k": "protudjelovanje",
"e": "Svaka akcija izaziva protudjelovanje."
},
{
"k": "provesti",
"e": "Želim provesti ljeto na moru."
},
{
"k": "provizija",
"e": "Banka naplaćuje proviziju."
},
{
"k": "provoditi",
"e": "Vikende provodim s obitelji."
},
{
"k": "proziran",
"e": "Voda je prozirna poput stakla."
},
{
"k": "prošetati se",
"e": "Idemo se prošetati uz more."
},
{
"k": "proširivati",
"e": "Tvrtka proširuje poslovanje."
},
{
"k": "prošlost",
"e": "To je sada prošlost."
},
{
"k": "prsten",
"e": "Dobila je zaručnički prsten."
},
{
"k": "pružiti prvu pomoć",
"e": "Svi bi trebali znati pružiti prvu pomoć."
},
{
"k": "prvenstvo",
"e": "Gledamo svjetsko prvenstvo u nogometu."
},
{
"k": "pržiti",
"e": "Ribu ćemo pržiti na maslinovom ulju."
},
{
"k": "psihologija",
"e": "Studiram psihologiju."
},
{
"k": "publika",
"e": "Publika je pljeskala pet minuta."
},
{
"k": "puls",
"e": "Liječnik mi je izmjerio puls."
},
{
"k": "pustiti",
"e": "Pusti me da prođem."
},
{
"k": "radišan",
"e": "Naš novi kolega je radišan."
},
{
"k": "radnik",
"e": "Radnici popravljaju cestu."
},
{
"k": "radno mjesto",
"e": "Ovo je moje radno mjesto."
},
{
"k": "radost",
"e": "Djeca su s radošću otvorila poklone."
},
{
"k": "raketa",
"e": "Raketa je poletjela u svemir."
},
{
"k": "rana",
"e": "Rana brzo zacjeljuje."
},
{
"k": "rashod",
"e": "Rashodi su veći od prihoda."
},
{
"k": "raskid",
"e": "Raskid ugovora mora biti pisan."
},
{
"k": "raskrižje",
"e": "Na raskrižju skrenite lijevo."
},
{
"k": "rasplakati",
"e": "Film me rasplakao."
},
{
"k": "raspoloženje",
"e": "Danas sam dobrog raspoloženja."
},
{
"k": "rasprava",
"e": "Rasprava je trajala satima."
},
{
"k": "raspravljati",
"e": "O tome ćemo raspravljati sutra."
},
{
"k": "rasprodaja",
"e": "Na rasprodaji sam kupila jaknu."
},
{
"k": "raspršiti",
"e": "Vjetar je raspršio oblake."
},
{
"k": "rastaviti",
"e": "Moramo rastaviti ormar prije selidbe."
},
{
"k": "rasti",
"e": "Cijene stalno rastu."
},
{
"k": "rat",
"e": "Rat je završio prije više od trideset godina."
},
{
"k": "rata",
"e": "Mjesečna rata kredita je tristo eura."
},
{
"k": "ravnatelj",
"e": "Ravnatelj škole je razgovarao s roditeljima."
},
{
"k": "ravnateljstvo",
"e": "Ravnateljstvo škole je donijelo odluku."
},
{
"k": "ravnoteža",
"e": "Izgubio je ravnotežu i pao."
},
{
"k": "razboljeti se",
"e": "Razboljela sam se nakon puta."
},
{
"k": "razdijeliti",
"e": "Razdijelite letke prolaznicima."
},
{
"k": "razdoblje",
"e": "To je bilo teško razdoblje."
},
{
"k": "razdvojiti",
"e": "Razdvojite bijelo i šareno rublje."
},
{
"k": "razina",
"e": "Na kojoj ste razini hrvatskog?"
},
{
"k": "razlika",
"e": "Koja je razlika između ove dvije riječi?"
},
{
"k": "razlikovati se",
"e": "Dijalekti se jako razlikuju."
},
{
"k": "različitost",
"e": "Poštujemo različitost."
},
{
"k": "razljutiti",
"e": "Njegov odgovor me razljutio."
},
{
"k": "razmisliti",
"e": "Moram razmisliti o tome."
},
{
"k": "razmišljati",
"e": "Razmišljam o selidbi u Split."
},
{
"k": "razmjena",
"e": "Bio sam na razmjeni studenata u Zagrebu."
},
{
"k": "raznolikost",
"e": "Hrvatska je poznata po raznolikosti krajolika."
},
{
"k": "razočaranje",
"e": "Film je bio pravo razočaranje."
},
{
"k": "razočarati",
"e": "Nemoj me razočarati."
},
{
"k": "razred",
"e": "U razredu ima dvadeset učenika."
},
{
"k": "razviti",
"e": "Tvrtka je razvila novu aplikaciju."
},
{
"k": "razviti se",
"e": "Grad se brzo razvio."
},
{
"k": "razvod",
"e": "Nakon razvoda se preselila u Split."
},
{
"k": "razvoj",
"e": "Razvoj djeteta je brz."
},
{
"k": "razvrstati",
"e": "Razvrstajte otpad po vrsti."
},
{
"k": "računati",
"e": "Možeš računati na mene."
},
{
"k": "računovođa",
"e": "Računovođa priprema godišnji izvještaj."
},
{
"k": "reakcija",
"e": "Kakva je bila njegova reakcija?"
},
{
"k": "reciklaža",
"e": "Reciklaža je obavezna u našoj zgradi."
},
{
"k": "recikliranje",
"e": "Recikliranje plastike je važno."
},
{
"k": "redak",
"e": "Pročitajte treći redak."
},
{
"k": "redatelj",
"e": "Redatelj je dobio nagradu."
},
{
"k": "referendum",
"e": "Održan je referendum o ulasku u Europsku uniju."
},
{
"k": "reforma",
"e": "Vlada najavljuje reformu zdravstva."
},
{
"k": "registar",
"e": "Tvrtka je upisana u sudski registar."
},
{
"k": "registrirati",
"e": "Moram registrirati auto."
},
{
"k": "reklama",
"e": "Na televiziji ima previše reklama."
},
{
"k": "resurs",
"e": "Voda je dragocjen resurs."
},
{
"k": "revolucija",
"e": "Internet je bio prava revolucija."
},
{
"k": "rezati",
"e": "Nož ne reže dobro."
},
{
"k": "rezultat",
"e": "Kakvi su rezultati pretrage?"
},
{
"k": "rečenica",
"e": "Prevedite ovu rečenicu."
},
{
"k": "režirati",
"e": "Film je režirala poznata redateljica."
},
{
"k": "ribar",
"e": "Ribar je ujutro donio svježu ribu."
},
{
"k": "ribarstvo",
"e": "Ribarstvo je važno za otoke."
},
{
"k": "rijedak",
"e": "Ovo je rijedak cvijet."
},
{
"k": "riješiti",
"e": "Moramo riješiti ovaj problem."
},
{
"k": "rizik",
"e": "Ne želim preuzeti taj rizik."
},
{
"k": "rješenje problema",
"e": "Našli smo rješenje problema."
},
{
"k": "rob",
"e": "Ne želim biti rob svog posla."
},
{
"k": "roba",
"e": "Roba stiže u ponedjeljak."
},
{
"k": "robot",
"e": "Robot usisava stan."
},
{
"k": "rodbina",
"e": "Za Božić dolazi sva rodbina."
},
{
"k": "roditelj",
"e": "Svaki roditelj želi najbolje za dijete."
},
{
"k": "roditi se",
"e": "Rodila sam se u Kijevu."
},
{
"k": "rodni list",
"e": "Za putovnicu trebate rodni list."
},
{
"k": "roman",
"e": "Čitam novi roman."
},
{
"k": "ropstvo",
"e": "Ropstvo je davno ukinuto."
},
{
"k": "rođakinja",
"e": "Moja rođakinja živi u Rijeci."
},
{
"k": "rođenje",
"e": "Datum rođenja upišite ovdje."
},
{
"k": "rudarstvo",
"e": "Labin ima dugu tradiciju rudarstva."
},
{
"k": "rukovodstvo",
"e": "Rukovodstvo je promijenilo pravila."
},
{
"k": "ruksak",
"e": "Spakiraj ruksak za izlet."
},
{
"k": "rušiti",
"e": "Ovu staru zgradu će rušiti."
},
{
"k": "ružnoća",
"e": "Ružnoća betona kvari pogled na more."
},
{
"k": "sadašnjost",
"e": "Živi u sadašnjosti."
},
{
"k": "sadržaj",
"e": "Provjerite sadržaj paketa."
},
{
"k": "sadržavati",
"e": "Ovaj proizvod sadrži orašaste plodove."
},
{
"k": "sakriti",
"e": "Gdje si sakrila ključ?"
},
{
"k": "sakriti se",
"e": "Mačka se sakrila ispod kreveta."
},
{
"k": "sam",
"e": "Večeras sam sam kod kuće."
},
{
"k": "sami",
"e": "Djeca su sama kod kuće."
},
{
"k": "san",
"e": "Imala sam čudan san."
},
{
"k": "sandale",
"e": "Ljeti nosim sandale."
},
{
"k": "sanjati",
"e": "Sanjam o kući uz more."
},
{
"k": "sastaviti",
"e": "Moramo sastaviti popis gostiju."
},
{
"k": "sastojati se",
"e": "Ispit se sastoji od tri dijela."
},
{
"k": "savez",
"e": "Hrvatska je članica saveza NATO."
},
{
"k": "saveznik",
"e": "Uvijek si mi bio saveznik."
},
{
"k": "savjest",
"e": "Imam mirnu savjest."
},
{
"k": "savjetovati",
"e": "Što mi savjetuješ?"
},
{
"k": "saznati",
"e": "Kako mogu saznati rezultate?"
},
{
"k": "sekunda",
"e": "Čekaj sekundu!"
},
{
"k": "seljak",
"e": "Seljak prodaje sir na tržnici."
},
{
"k": "semestar",
"e": "Semestar počinje u listopadu."
},
{
"k": "seminar",
"e": "Sutra imamo seminar iz povijesti."
},
{
"k": "servis",
"e": "Auto je na servisu."
},
{
"k": "shvatiti",
"e": "Nisam shvatila pitanje."
},
{
"k": "sigurnost",
"e": "Sigurnost putnika je na prvom mjestu."
},
{
"k": "simpatičan",
"e": "Tvoj prijatelj je jako simpatičan."
},
{
"k": "sindikat",
"e": "Sindikat traži veće plaće."
},
{
"k": "sinteza",
"e": "Rad završava sintezom rezultata."
},
{
"k": "sirena",
"e": "Čula se sirena hitne pomoći."
},
{
"k": "siromaštvo",
"e": "Siromaštvo je velik problem."
},
{
"k": "sirovina",
"e": "Drvo je važna sirovina."
},
{
"k": "sistem",
"e": "Sistem je pao, pokušajte kasnije."
},
{
"k": "situacija",
"e": "Situacija je ozbiljna."
},
{
"k": "sjajan",
"e": "Imam sjajnu ideju!"
},
{
"k": "sjednica",
"e": "Sjednica vijeća počinje u deset."
},
{
"k": "sjesti",
"e": "Gdje mogu sjesti?"
},
{
"k": "sjećanje",
"e": "Imam lijepa sjećanja na to ljeto."
},
{
"k": "skakati",
"e": "Djeca vole skakati u more."
},
{
"k": "skitati se",
"e": "Cijeli dan se skitao po gradu."
},
{
"k": "sklad",
"e": "Boje su u skladu."
},
{
"k": "skladatelj",
"e": "Skladatelj je napisao novu operu."
},
{
"k": "skladište",
"e": "Roba je u skladištu."
},
{
"k": "sklapanje",
"e": "Sklapanje ugovora je u petak."
},
{
"k": "sklonište",
"e": "Za vrijeme oluje bili smo u skloništu."
},
{
"k": "skočiti",
"e": "Skočio je s mola u more."
},
{
"k": "skriti se",
"e": "Mačka se skrila u ormar."
},
{
"k": "skrivati",
"e": "Što skrivaš iza leđa?"
},
{
"k": "skroman",
"e": "On je skroman čovjek."
},
{
"k": "skupina",
"e": "Turisti su došli u velikoj skupini."
},
{
"k": "skupiti",
"e": "Moramo skupiti novac za poklon."
},
{
"k": "slagati",
"e": "Slagao mi je da je bolestan."
},
{
"k": "slavan",
"e": "Postala je slavna pjevačica."
},
{
"k": "slavlje",
"e": "Nakon pobjede bilo je veliko slavlje."
},
{
"k": "sletjeti",
"e": "Avion je sletio u Zagreb."
},
{
"k": "slikarstvo",
"e": "Zanima me slikarstvo."
},
{
"k": "sličiti",
"e": "Jako sličiš mami."
},
{
"k": "sličnost",
"e": "Postoji velika sličnost između ova dva jezika."
},
{
"k": "sloboda",
"e": "Sloboda je najvažnija."
},
{
"k": "slobodno vrijeme",
"e": "U slobodno vrijeme čitam."
},
{
"k": "slomiti",
"e": "Slomila sam ruku."
},
{
"k": "složen",
"e": "Ovo je složen problem."
},
{
"k": "složenost",
"e": "Ne podcjenjuj složenost zadatka."
},
{
"k": "složiti se",
"e": "Slažem se s tobom."
},
{
"k": "slučaj",
"e": "U slučaju požara nazovite 112."
},
{
"k": "slučajno",
"e": "Slučajno sam ga sreo u gradu."
},
{
"k": "slušalice",
"e": "Zaboravila sam slušalice kod kuće."
},
{
"k": "smanjenje",
"e": "Najavljeno je smanjenje cijena."
},
{
"k": "smanjiti",
"e": "Smanjite brzinu!"
},
{
"k": "smanjiti se",
"e": "Gužva se smanjila poslije šest."
},
{
"k": "smanjivati",
"e": "Polako smanjujem kavu."
},
{
"k": "smatrati",
"e": "Smatram da je to dobra ideja."
},
{
"k": "smeđ",
"e": "Ima kratku smeđu kosu."
},
{
"k": "smijeh",
"e": "Iz dvorišta se čuo smijeh djece."
},
{
"k": "smiješan",
"e": "Film je bio jako smiješan."
},
{
"k": "smiriti se",
"e": "Smiri se, sve će biti u redu."
},
{
"k": "smisao",
"e": "Nema smisla čekati."
},
{
"k": "smjeti",
"e": "Smijem li ovdje pušiti?"
},
{
"k": "smještaj",
"e": "Tražimo smještaj za tjedan dana."
},
{
"k": "smrt",
"e": "Vijest o njegovoj smrti nas je potresla."
},
{
"k": "smrtni list",
"e": "Za nasljedstvo treba smrtni list."
},
{
"k": "snaga",
"e": "Nemam snage za trening danas."
},
{
"k": "snage",
"e": "Na teren su stigle snage policije."
},
{
"k": "snaći se",
"e": "Brzo sam se snašla u novom gradu."
},
{
"k": "snimiti",
"e": "Snimi video za baku."
},
{
"k": "snimka",
"e": "Pogledaj ovu snimku."
},
{
"k": "sociologija",
"e": "Studira sociologiju."
},
{
"k": "softver",
"e": "Moramo ažurirati softver."
},
{
"k": "spajati",
"e": "Most spaja otok s kopnom."
},
{
"k": "spas",
"e": "To je bio pravi spas!"
},
{
"k": "spasitelj",
"e": "Spasitelj je izvukao dijete iz mora."
},
{
"k": "spasiti život",
"e": "Brza reakcija može spasiti život."
},
{
"k": "spašavanje",
"e": "Akcija spašavanja trajala je cijelu noć."
},
{
"k": "spašavati",
"e": "Spasioci spašavaju turiste s otoka."
},
{
"k": "spektar",
"e": "Nudimo širok spektar usluga."
},
{
"k": "spisi",
"e": "Svi spisi su u arhivi suda."
},
{
"k": "spoj",
"e": "Večeras imam spoj."
},
{
"k": "spojiti",
"e": "Spoji mobitel na wifi."
},
{
"k": "spominjati",
"e": "Stalno spominješ tog dečka."
},
{
"k": "spona",
"e": "Jezik je spona među ljudima."
},
{
"k": "sponzorirati",
"e": "Tvrtka sponzorira lokalni klub."
},
{
"k": "sporazum",
"e": "Potpisali su sporazum."
},
{
"k": "sporedni",
"e": "To je sporedni problem."
},
{
"k": "sportaš",
"e": "On je profesionalni sportaš."
},
{
"k": "sposoban",
"e": "Sposoban je za taj posao."
},
{
"k": "sposobnost",
"e": "Ima sposobnost brzo učiti."
},
{
"k": "spoznaja",
"e": "Došao je do važne spoznaje."
},
{
"k": "spoznati",
"e": "Tek u inozemstvu sam spoznala vrijednost obitelji."
},
{
"k": "spoznatljiv",
"e": "Svijet je spoznatljiv kroz iskustvo."
},
{
"k": "spremati",
"e": "Spremam ručak za sutra."
},
{
"k": "spremiti",
"e": "Ne zaboravi spremiti dokument."
},
{
"k": "sprijateljiti se",
"e": "Brzo smo se sprijateljili."
},
{
"k": "spriječiti",
"e": "Kako spriječiti prehladu?"
},
{
"k": "sram",
"e": "Nije te sram?"
},
{
"k": "sramežljiv",
"e": "Sin je jako sramežljiv."
},
{
"k": "srednji",
"e": "Imate li ovu majicu u srednjoj veličini?"
},
{
"k": "sredstvo",
"e": "Treba mi sredstvo za čišćenje."
},
{
"k": "srušiti",
"e": "Oluja je srušila drvo."
},
{
"k": "srušiti se",
"e": "Most se srušio za vrijeme potresa."
},
{
"k": "stabilan",
"e": "Pacijent je u stabilnom stanju."
},
{
"k": "stabilnost",
"e": "Banka jamči stabilnost."
},
{
"k": "stadion",
"e": "Stadion je pun navijača."
},
{
"k": "stagnirati",
"e": "Plaće stagniraju već godinama."
},
{
"k": "standard",
"e": "Životni standard raste."
},
{
"k": "stanje",
"e": "Kakvo je stanje na cestama?"
},
{
"k": "starac",
"e": "Starac sjedi na klupi."
},
{
"k": "starost",
"e": "U starosti želim živjeti uz more."
},
{
"k": "statistika",
"e": "Prema statistici, broj turista raste."
},
{
"k": "status",
"e": "Kakav je status moje prijave?"
},
{
"k": "stav",
"e": "Imaš pozitivan stav."
},
{
"k": "stečaj",
"e": "Tvrtka je otišla u stečaj."
},
{
"k": "stih",
"e": "Naučila sam nekoliko stihova napamet."
},
{
"k": "stoljeće",
"e": "Crkva je iz petnaestog stoljeća."
},
{
"k": "stomatolog",
"e": "Sutra idem stomatologu."
},
{
"k": "strah",
"e": "Imam strah od visine."
},
{
"k": "strahovati",
"e": "Strahujem za njegovo zdravlje."
},
{
"k": "stranica",
"e": "Otvorite knjigu na stranici dvadeset."
},
{
"k": "stranka",
"e": "Za koju stranku glasaš?"
},
{
"k": "strast",
"e": "Glazba je njegova strast."
},
{
"k": "strategija",
"e": "Trebamo novu strategiju."
},
{
"k": "stres",
"e": "Na poslu imam puno stresa."
},
{
"k": "strmoglaviti se",
"e": "Auto se strmoglavio s ceste."
},
{
"k": "strojovođa",
"e": "Strojovođa je zaustavio vlak."
},
{
"k": "strop",
"e": "Strop u kupaonici je mokar."
},
{
"k": "strpljenje",
"e": "Hvala na strpljenju."
},
{
"k": "strpljiv",
"e": "Budi strpljiv."
},
{
"k": "struktura",
"e": "Struktura teksta je jasna."
},
{
"k": "stručnjak",
"e": "Treba nam stručnjak za porez."
},
{
"k": "studij",
"e": "Moj studij traje pet godina."
},
{
"k": "stup",
"e": "Auto je udario u stup."
},
{
"k": "stupanj",
"e": "Vani je trideset stupnjeva."
},
{
"k": "stvaran",
"e": "Ovo je stvaran problem."
},
{
"k": "stvarati",
"e": "Djeca stvaraju buku."
},
{
"k": "stvari",
"e": "Spakiraj svoje stvari."
},
{
"k": "stvarnost",
"e": "San je postao stvarnost."
},
{
"k": "stvoriti",
"e": "Želimo stvoriti bolju budućnost."
},
{
"k": "sud",
"e": "Slučaj ide na sud."
},
{
"k": "sudac",
"e": "Sudac je dosudio penal."
},
{
"k": "sudar",
"e": "Na raskrižju se dogodio sudar."
},
{
"k": "sudionik",
"e": "Svaki sudionik dobiva potvrdu."
},
{
"k": "suditi",
"e": "Ne sudi ljudima po izgledu."
},
{
"k": "suditi se",
"e": "Susjedi se sude zbog ograde."
},
{
"k": "sudjelovati",
"e": "Želim sudjelovati u projektu."
},
{
"k": "sudoper",
"e": "Posuđe je u sudoperu."
},
{
"k": "sudstvo",
"e": "Neovisno sudstvo je temelj demokracije."
},
{
"k": "suh",
"e": "Ovaj zrak je jako suh."
},
{
"k": "suhoća",
"e": "Suhoća kože je česta zimi."
},
{
"k": "sukob",
"e": "Izbjegavam sukobe na poslu."
},
{
"k": "sumnja",
"e": "Nema sumnje, on je kriv."
},
{
"k": "sumnjati",
"e": "Sumnjam da će doći."
},
{
"k": "suprotan",
"e": "Imamo suprotna mišljenja."
},
{
"k": "suradnik",
"e": "Moj suradnik je na godišnjem."
},
{
"k": "suradnja",
"e": "Hvala na suradnji."
},
{
"k": "surađivati",
"e": "Rado ćemo surađivati s vama."
},
{
"k": "suvlasnik",
"e": "On je suvlasnik restorana."
},
{
"k": "suvremen",
"e": "Stan je opremljen suvremenim uređajima."
},
{
"k": "suvremeni",
"e": "Zanima me suvremeni ples."
},
{
"k": "suđenje",
"e": "Suđenje počinje u ponedjeljak."
},
{
"k": "suša",
"e": "Ljetna suša uništila je usjeve."
},
{
"k": "sušilo",
"e": "Sušilo za kosu je u kupaonici."
},
{
"k": "suživot",
"e": "U ovom gradu suživot je moguć."
},
{
"k": "svađa",
"e": "Nakon svađe su se pomirili."
},
{
"k": "svađati se",
"e": "Susjedi se svađaju svaku večer."
},
{
"k": "svemir",
"e": "Svemir je beskonačan."
},
{
"k": "sveučilište",
"e": "Studiram na Sveučilištu u Zagrebu."
},
{
"k": "svijest",
"e": "Pacijent je pri svijesti."
},
{
"k": "svijetao",
"e": "Stan je velik i svijetao."
},
{
"k": "svirati",
"e": "Brat svira gitaru."
},
{
"k": "svjedok",
"e": "Bio sam svjedok nesreće."
},
{
"k": "svjedočenje",
"e": "Njegovo svjedočenje je bilo ključno."
},
{
"k": "svjetiljka",
"e": "Upali svjetiljku pokraj kreveta."
},
{
"k": "svjetlost",
"e": "U ovoj sobi ima malo svjetlosti."
},
{
"k": "svjež",
"e": "Kupila sam svjež kruh."
},
{
"k": "svojeglav",
"e": "Dijete je svojeglavo."
},
{
"k": "svrha",
"e": "Koja je svrha vašeg putovanja?"
},
{
"k": "svugdje",
"e": "Svugdje sam tražila ključeve."
},
{
"k": "tajanstven",
"e": "Dobila sam tajanstveno pismo."
},
{
"k": "tajna",
"e": "To je naša tajna."
},
{
"k": "tajnica",
"e": "Tajnica će vas nazvati."
},
{
"k": "taktika",
"e": "Trener je promijenio taktiku."
},
{
"k": "talenat",
"e": "Ima talenta za jezike."
},
{
"k": "tama",
"e": "U tami ništa nisam vidjela."
},
{
"k": "taman",
"e": "Nosi taman kaput."
},
{
"k": "tanjurić",
"e": "Stavi šalicu na tanjurić."
},
{
"k": "taoc",
"e": "Svi taoci su oslobođeni."
},
{
"k": "tata",
"e": "Tata je u garaži."
},
{
"k": "tava",
"e": "Zagrij ulje u tavi."
},
{
"k": "tehnički",
"e": "Imamo tehnički problem."
},
{
"k": "tehnologija",
"e": "Tehnologija se brzo razvija."
},
{
"k": "televizija",
"e": "Što ima na televiziji?"
},
{
"k": "temelj",
"e": "Zdrava prehrana je temelj zdravlja."
},
{
"k": "temeljni",
"e": "Ovo je temeljni zakon države."
},
{
"k": "teorija",
"e": "U teoriji je jednostavno."
},
{
"k": "tepsija",
"e": "Stavi krumpir u tepsiju."
},
{
"k": "terapija",
"e": "Terapija traje deset dana."
},
{
"k": "termometar",
"e": "Termometar pokazuje trideset stupnjeva."
},
{
"k": "težina",
"e": "Kolika je težina kofera?"
},
{
"k": "tisak",
"e": "Vijest se pojavila u tisku."
},
{
"k": "tisuća",
"e": "Na koncertu je bilo tisuću ljudi."
},
{
"k": "tišina",
"e": "Molim tišinu!"
},
{
"k": "tjeskoba",
"e": "Osjećam tjeskobu prije ispita."
},
{
"k": "tješiti",
"e": "Prijateljica me tješi."
},
{
"k": "tkanina",
"e": "Ova tkanina je mekana."
},
{
"k": "tlak",
"e": "Imam visok tlak."
},
{
"k": "tlo",
"e": "Tlo je ovdje jako suho."
},
{
"k": "ton",
"e": "Ne sviđa mi se tvoj ton."
},
{
"k": "toplina",
"e": "Volim toplinu ljetnih večeri."
},
{
"k": "tradicija",
"e": "Ovo je stara obiteljska tradicija."
},
{
"k": "tradicionalan",
"e": "Pripremili smo tradicionalan ručak."
},
{
"k": "trajati",
"e": "Koliko traje vožnja do Splita?"
},
{
"k": "trajekt",
"e": "Trajekt za Brač polazi svaki sat."
},
{
"k": "transakcija",
"e": "Transakcija je odbijena."
},
{
"k": "trebam",
"e": "Trebam tvoju pomoć."
},
{
"k": "trofej",
"e": "Momčad je osvojila trofej."
},
{
"k": "trovanje",
"e": "Imao sam trovanje hranom."
},
{
"k": "trošak",
"e": "Troškovi stanovanja su visoki."
},
{
"k": "trud",
"e": "Trud se isplatio."
},
{
"k": "tržište",
"e": "Tržište nekretnina raste."
},
{
"k": "tugovati",
"e": "Obitelj tuguje za djedom."
},
{
"k": "tumačiti",
"e": "Svatko tumači pravila na svoj način."
},
{
"k": "tup",
"e": "Nož je tup."
},
{
"k": "turizam",
"e": "Turizam je važan za Hrvatsku."
},
{
"k": "tuča",
"e": "Na ulici je izbila tuča."
},
{
"k": "tužba",
"e": "Podnio je tužbu protiv tvrtke."
},
{
"k": "tužitelj",
"e": "Tužitelj je iznio dokaze."
},
{
"k": "tužiteljstvo",
"e": "Tužiteljstvo je pokrenulo istragu."
},
{
"k": "tužiti",
"e": "Prijete da će nas tužiti."
},
{
"k": "tvar",
"e": "Ova tvar je otrovna."
},
{
"k": "tvrd",
"e": "Krevet je pretvrd."
},
{
"k": "tvrditi",
"e": "Tvrdi da nije ništa vidio."
},
{
"k": "tvrdoglav",
"e": "Ne budi tvrdoglav."
},
{
"k": "ubijati",
"e": "Sunce ubija bakterije."
},
{
"k": "ubojica",
"e": "Policija je uhitila ubojicu."
},
{
"k": "ubrzanje",
"e": "Novi auto ima brzo ubrzanje."
},
{
"k": "ubrzati",
"e": "Možemo li ubrzati proces?"
},
{
"k": "udruga",
"e": "Učlanila sam se u udrugu Ukrajinaca."
},
{
"k": "ugasiti",
"e": "Ugasi televizor, molim te."
},
{
"k": "ugled",
"e": "Restoran ima dobar ugled."
},
{
"k": "ugostiteljstvo",
"e": "Ljeti radim u ugostiteljstvu."
},
{
"k": "ugovor o radu",
"e": "Potpisala sam ugovor o radu na godinu dana."
},
{
"k": "uhititi",
"e": "Policija je uhitila lopova."
},
{
"k": "uključivati",
"e": "Cijena uključuje doručak."
},
{
"k": "ukras",
"e": "Djeca prave ukrase za bor."
},
{
"k": "ukrasiti",
"e": "Ukrasit ćemo stan za Božić."
},
{
"k": "ukupan",
"e": "Ukupan iznos je sto eura."
},
{
"k": "ulaganje",
"e": "Ulaganje u obrazovanje se isplati."
},
{
"k": "ulagati",
"e": "Ulažemo u obrazovanje djece."
},
{
"k": "uložiti",
"e": "Uložila je sav novac u stan."
},
{
"k": "um",
"e": "Imaš bistar um."
},
{
"k": "umalo",
"e": "Umalo sam zakasnila."
},
{
"k": "umiriti",
"e": "Pokušao je umiriti dijete."
},
{
"k": "umirovljenik",
"e": "Moj susjed je umirovljenik."
},
{
"k": "umjesto",
"e": "Umjesto kave pijem čaj."
},
{
"k": "umjetan",
"e": "Ovo je umjetan cvijet."
},
{
"k": "umjetnik",
"e": "On je poznati umjetnik."
},
{
"k": "umjetnost",
"e": "Zanima me moderna umjetnost."
},
{
"k": "umrijeti",
"e": "Biljka će umrijeti bez vode."
},
{
"k": "unaokolo",
"e": "Unaokolo je samo more."
},
{
"k": "uništenje",
"e": "Šumi prijeti uništenje."
},
{
"k": "unuk",
"e": "Unuk me posjećuje svake nedjelje."
},
{
"k": "unuka",
"e": "Moja unuka ide u vrtić."
},
{
"k": "uostalom",
"e": "Uostalom, to nije tvoj problem."
},
{
"k": "uplata",
"e": "Uplata je stigla na račun."
},
{
"k": "uplašiti",
"e": "Nemoj me tako uplašiti!"
},
{
"k": "uplašiti se",
"e": "Uplašila sam se psa."
},
{
"k": "uporan",
"e": "Ako si uporan, uspjet ćeš."
},
{
"k": "upoznavati",
"e": "Polako upoznajemo grad."
},
{
"k": "upozoravati",
"e": "Liječnici upozoravaju na vrućinu."
},
{
"k": "upozorenje",
"e": "Izdano je upozorenje zbog oluje."
},
{
"k": "uprava",
"e": "Uprava je odobrila projekt."
},
{
"k": "upravitelj",
"e": "Upravitelj zgrade je popravio lift."
},
{
"k": "upravljanje",
"e": "Studira upravljanje u turizmu."
},
{
"k": "upravljati",
"e": "Tko upravlja ovom tvrtkom?"
},
{
"k": "upute",
"e": "Pročitajte upute prije upotrebe."
},
{
"k": "uputnica",
"e": "Za specijalista trebate uputnicu."
},
{
"k": "uragan",
"e": "Uragan je pogodio obalu."
},
{
"k": "uredan",
"e": "Stan je čist i uredan."
},
{
"k": "uredba",
"e": "Vlada je donijela novu uredbu."
},
{
"k": "urediti",
"e": "Moramo urediti dvorište."
},
{
"k": "urednik",
"e": "Urednik je pročitao članak."
},
{
"k": "uređaj",
"e": "Isključite sve uređaje."
},
{
"k": "usisavati",
"e": "Subotom usisavam stan."
},
{
"k": "uskladiti",
"e": "Moramo uskladiti termine."
},
{
"k": "usluga",
"e": "Usluga u restoranu je bila spora."
},
{
"k": "usluge",
"e": "Cijene usluga su na stranici."
},
{
"k": "uspjeh",
"e": "Puno uspjeha na ispitu!"
},
{
"k": "uspješan",
"e": "Bio je to uspješan sastanak."
},
{
"k": "usporediti",
"e": "Usporedite cijene prije kupnje."
},
{
"k": "usporiti",
"e": "Usporite, ovdje je škola."
},
{
"k": "ustanova",
"e": "Ovo je javna ustanova."
},
{
"k": "ustav",
"e": "Ustav jamči slobodu govora."
},
{
"k": "utakmica",
"e": "Utakmica počinje u osam."
},
{
"k": "utisak",
"e": "Ostavio je dobar utisak."
},
{
"k": "utjecaj",
"e": "Roditelji imaju velik utjecaj na djecu."
},
{
"k": "utjecati",
"e": "Vrijeme utječe na moje raspoloženje."
},
{
"k": "utješiti",
"e": "Nisam ga mogla utješiti."
},
{
"k": "utopiti se",
"e": "Pazi da se dijete ne utopi."
},
{
"k": "uvjerenje",
"e": "Trebam uvjerenje o nekažnjavanju."
},
{
"k": "uvoz",
"e": "Uvoz voća raste."
},
{
"k": "uzak",
"e": "Ovaj hodnik je jako uzak."
},
{
"k": "uzbuna",
"e": "Kad se oglasila uzbuna, svi su izašli iz zgrade."
},
{
"k": "uzbuđenje",
"e": "Djeca ne mogu sakriti uzbuđenje."
},
{
"k": "uzdah",
"e": "Odgovorio je s uzdahom."
},
{
"k": "uzdahnuti",
"e": "Duboko je uzdahnula i počela govoriti."
},
{
"k": "uzdisati",
"e": "Zašto stalno uzdišeš?"
},
{
"k": "uzeti lijek",
"e": "Ne zaboravi uzeti lijek."
},
{
"k": "uznemiriti se",
"e": "Nemoj se uznemiriti, sve je u redu."
},
{
"k": "učenik",
"e": "Učenik je zaboravio zadaću."
},
{
"k": "učinak",
"e": "Lijek ima brz učinak."
},
{
"k": "učinkovit",
"e": "Ovaj lijek je jako učinkovit."
},
{
"k": "učinkovitost",
"e": "Učinkovitost novog sustava je veća."
},
{
"k": "učionica",
"e": "Učionica je na prvom katu."
},
{
"k": "uštedjeti",
"e": "Uštedjela sam za putovanje."
},
{
"k": "užina",
"e": "Djeca nose užinu u školu."
},
{
"k": "uživati",
"e": "Uživamo u odmoru."
},
{
"k": "vagati",
"e": "Prodavačica važe voće."
},
{
"k": "valjanost",
"e": "Provjerite valjanost putovnice."
},
{
"k": "valjda",
"e": "Valjda će sutra biti sunčano."
},
{
"k": "valuta",
"e": "Koja je valuta u Hrvatskoj?"
},
{
"k": "varati",
"e": "Ne varaj na ispitu!"
},
{
"k": "vatra",
"e": "Zapalili smo vatru na plaži."
},
{
"k": "vaza",
"e": "Stavi cvijeće u vazu."
},
{
"k": "važiti",
"e": "Ta pravila važe za sve."
},
{
"k": "važnost",
"e": "Ne shvaćaš važnost ovoga."
},
{
"k": "veleposlanstvo",
"e": "Ukrajinsko veleposlanstvo je u Zagrebu."
},
{
"k": "veseliti se",
"e": "Veselim se moru."
},
{
"k": "većina",
"e": "Većina ljudi radi do pet."
},
{
"k": "video",
"e": "Pogledaj ovaj video."
},
{
"k": "vidimo",
"e": "Vidimo se sutra!"
},
{
"k": "vidio",
"e": "Jesi li vidio moje ključeve?"
},
{
"k": "vijest",
"e": "Imam dobru vijest!"
},
{
"k": "vijesti",
"e": "Gledam vijesti svaku večer."
},
{
"k": "vika",
"e": "Iz stana se čula vika."
},
{
"k": "vikati",
"e": "Nemoj vikati na mene!"
},
{
"k": "virus",
"e": "Imam neki virus."
},
{
"k": "visina",
"e": "Kolika je visina stropa?"
},
{
"k": "vizija",
"e": "Imamo jasnu viziju budućnosti."
},
{
"k": "vjenčani list",
"e": "Za prijavu trebate vjenčani list."
},
{
"k": "vjenčanje",
"e": "Vjenčanje je u lipnju."
},
{
"k": "vjerojatan",
"e": "Vjerojatan uzrok je kvar."
},
{
"k": "vjerojatno",
"e": "Vjerojatno ću zakasniti."
},
{
"k": "vječnost",
"e": "Čekanje je trajalo cijelu vječnost."
},
{
"k": "vještina",
"e": "Komunikacija je važna vještina."
},
{
"k": "vlada",
"e": "Vlada je donijela nove mjere."
},
{
"k": "vlasnik",
"e": "Vlasnik stana živi u Njemačkoj."
},
{
"k": "vlast",
"e": "Lokalna vlast je obnovila trg."
},
{
"k": "vlažan",
"e": "Zrak je vlažan."
},
{
"k": "vlažnost",
"e": "Vlažnost zraka je visoka."
},
{
"k": "voditelj",
"e": "Voditelj tečaja je jako strpljiv."
},
{
"k": "voditi",
"e": "Ova cesta vodi do mora."
},
{
"k": "vodstvo",
"e": "Naša momčad je u vodstvu."
},
{
"k": "vojnik",
"e": "Moj djed je bio vojnik."
},
{
"k": "vojska",
"e": "Brat je u vojsci."
},
{
"k": "volim",
"e": "Volim te."
},
{
"k": "vozilo",
"e": "Vozilo je parkirano na krivom mjestu."
},
{
"k": "vođa",
"e": "On je vođa tima."
},
{
"k": "vratiti",
"e": "Moram vratiti knjigu u knjižnicu."
},
{
"k": "vratiti se",
"e": "Vratit ću se za pet minuta."
},
{
"k": "vrijedan",
"e": "Ovo je vrijedan sat."
},
{
"k": "vrijediti",
"e": "Ova karta vrijedi za sve autobuse."
},
{
"k": "vrijednost",
"e": "Vrijednost stana je porasla."
},
{
"k": "zaborav",
"e": "Mnoge stare riječi pale su u zaborav."
},
{
"k": "zabrana",
"e": "Na plaži je zabrana pušenja."
},
{
"k": "zabraniti",
"e": "Zabranili su vožnju kroz centar."
},
{
"k": "zacijelo",
"e": "Zacijelo si umoran nakon puta."
},
{
"k": "zadaća",
"e": "Jesi li napisao zadaću?"
},
{
"k": "zagađenje",
"e": "Zagađenje zraka u gradu je visoko."
},
{
"k": "zagonetka",
"e": "Ovo je prava zagonetka."
},
{
"k": "zahtijevati",
"e": "Posao zahtijeva puno strpljenja."
},
{
"k": "zahtjev",
"e": "Predala sam zahtjev za boravak."
},
{
"k": "zajam",
"e": "Uzeo je zajam od banke."
},
{
"k": "zajednica",
"e": "Ukrajinska zajednica u Zagrebu je velika."
},
{
"k": "zajednički",
"e": "Imamo zajednički cilj."
},
{
"k": "zaklada",
"e": "Zaklada pomaže djeci."
},
{
"k": "zaključak",
"e": "Koji je vaš zaključak?"
},
{
"k": "zaključati",
"e": "Ne zaboravi zaključati vrata."
},
{
"k": "zaključiti",
"e": "Možemo zaključiti da je plan uspio."
},
{
"k": "zaliha",
"e": "Imamo zalihu vode za tri dana."
},
{
"k": "zaljubiti se",
"e": "Zaljubila sam se u Split."
},
{
"k": "zamalo",
"e": "Zamalo sam pala."
},
{
"k": "zamijeniti",
"e": "Mogu li zamijeniti ovu majicu?"
},
{
"k": "zamisliti",
"e": "Zamisli da živiš na otoku."
},
{
"k": "zamišljati",
"e": "Zamišljam kako će izgledati naša kuća."
},
{
"k": "zamrzivač",
"e": "Sladoled je u zamrzivaču."
},
{
"k": "zanatlija",
"e": "Zanatlija je popravio stolicu."
},
{
"k": "zapanjiti",
"e": "Cijena nas je zapanjila."
},
{
"k": "zaplivati",
"e": "Napokon sam zaplivala bez pomoći."
},
{
"k": "zapošljavanje",
"e": "Tvrtka najavljuje zapošljavanje novih radnika."
},
{
"k": "zarađivati",
"e": "Koliko zarađuješ mjesečno?"
},
{
"k": "zarobiti",
"e": "Vojnici su zarobili neprijatelja."
},
{
"k": "zasigurno",
"e": "Zasigurno ćeš uspjeti."
},
{
"k": "zastarjelost",
"e": "Zbog zastarjelosti slučaj je odbačen."
},
{
"k": "zatajiti",
"e": "Pokušao je zatajiti istinu."
},
{
"k": "zatvor",
"e": "Lopov je završio u zatvoru."
},
{
"k": "zaustavljati se",
"e": "Ovaj vlak se ne zaustavlja u Karlovcu."
},
{
"k": "zavidjeti",
"e": "Zavidim ti na tvom poslu."
},
{
"k": "zavjesa",
"e": "Zatvori zavjese, sunce mi smeta."
},
{
"k": "zavoj",
"e": "Medicinska sestra mi je promijenila zavoj."
},
{
"k": "zaštita",
"e": "Ne zaboravi zaštitu od sunca."
},
{
"k": "zaštititi",
"e": "Kremom zaštitite kožu od sunca."
},
{
"k": "zbog",
"e": "Zakasnila sam zbog prometa."
},
{
"k": "zdravstvo",
"e": "Radi u zdravstvu kao medicinska sestra."
},
{
"k": "zid",
"e": "Objesi sliku na zid."
},
{
"k": "zlo",
"e": "Nije sve zlo za zlo."
},
{
"k": "zlonamjerni softver",
"e": "Antivirus je pronašao zlonamjerni softver."
},
{
"k": "zločin",
"e": "Policija istražuje zločin."
},
{
"k": "znak",
"e": "Pazite na znak za stop."
},
{
"k": "znam",
"e": "Ne znam, pitaj Dašu."
},
{
"k": "znanje",
"e": "Tvoje znanje hrvatskog je odlično."
},
{
"k": "znanost",
"e": "Zanima me znanost."
},
{
"k": "znanstvenik",
"e": "Znanstvenici su otkrili novu vrstu."
},
{
"k": "značaj",
"e": "Ovaj događaj ima velik značaj za grad."
},
{
"k": "značajan",
"e": "To je značajan napredak."
},
{
"k": "značenje",
"e": "Koje je značenje ove riječi?"
},
{
"k": "značiti",
"e": "Što znači ova riječ?"
},
{
"k": "znaš",
"e": "Znaš li gdje je pošta?"
},
{
"k": "zračenje",
"e": "Sunčevo zračenje je jako u podne."
},
{
"k": "zreo",
"e": "Ova lubenica je zrela."
},
{
"k": "čamac",
"e": "Iznajmili smo čamac na jedan dan."
},
{
"k": "časnik",
"e": "Moj djed je bio časnik u vojsci."
},
{
"k": "čast",
"e": "Čast mi je upoznati vas."
},
{
"k": "čekanje",
"e": "Čekanje kod liječnika traje satima."
},
{
"k": "čestica",
"e": "U zraku ima puno čestica prašine."
},
{
"k": "činjenica",
"e": "To je činjenica, a ne mišljenje."
},
{
"k": "činovnik",
"e": "Činovnik mi je rekao da dođem sutra."
},
{
"k": "čizme",
"e": "Zimi nosim tople čizme."
},
{
"k": "član",
"e": "Postao sam član planinarskog društva."
},
{
"k": "članak",
"e": "Pročitao sam zanimljiv članak o Zadru."
},
{
"k": "čudan",
"e": "Imao sam čudan san."
},
{
"k": "čuvati",
"e": "Čuvaj se!"
},
{
"k": "čvrst",
"e": "Ovaj stol je jako čvrst."
},
{
"k": "šal",
"e": "Uzmi šal, puše bura."
},
{
"k": "šala",
"e": "To je bila samo šala."
},
{
"k": "šansa",
"e": "Daj mi još jednu šansu."
},
{
"k": "šapat",
"e": "Govorio je šapatom."
},
{
"k": "šaputati",
"e": "Ne šapući, svi te čujemo."
},
{
"k": "šaren",
"e": "Kupila je šarenu haljinu."
},
{
"k": "šešir",
"e": "Ljeti nosim šešir zbog sunca."
},
{
"k": "širina",
"e": "Kolika je širina ormara?"
},
{
"k": "širok",
"e": "Ova cesta je jako široka."
},
{
"k": "šivati",
"e": "Baka zna šivati haljine."
},
{
"k": "šok",
"e": "Vijest je bila pravi šok."
},
{
"k": "šokirati",
"e": "Cijena me šokirala."
},
{
"k": "šprica",
"e": "Medicinska sestra je pripremila špricu."
},
{
"k": "štedjeti",
"e": "Štedimo za novi auto."
},
{
"k": "štednja",
"e": "Štednja je važna za budućnost."
},
{
"k": "štetan",
"e": "Pušenje je štetno za zdravlje."
},
{
"k": "štetiti",
"e": "Previše sunca šteti koži."
},
{
"k": "štogod",
"e": "Uzmi štogod želiš."
},
{
"k": "štoviše",
"e": "Nije skupo, štoviše, jako je povoljno."
},
{
"k": "štrajk",
"e": "Zbog štrajka ne voze vlakovi."
},
{
"k": "šum",
"e": "Čuje se šum mora."
},
{
"k": "šumarstvo",
"e": "Brat radi u šumarstvu."
},
{
"k": "šutjeti",
"e": "Zašto šutiš?"
},
{
"k": "žalba",
"e": "Podnio sam žalbu na odluku."
},
{
"k": "žalost",
"e": "Na žalost, ne mogu doći."
},
{
"k": "žalovati",
"e": "Cijelo selo žaluje za njim."
},
{
"k": "želim",
"e": "Želim kavu, molim."
},
{
"k": "želiš",
"e": "Što želiš za večeru?"
},
{
"k": "živ",
"e": "Riba je još živa."
},
{
"k": "životni vijek",
"e": "Životni vijek ljudi je sve duži."
},
{
"k": "životopis",
"e": "Pošaljite životopis na mail."
},
{
"k": "žrtva",
"e": "U nesreći nema žrtava."
},
{
"k": "županija",
"e": "Zadar je središte Zadarske županije."
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
            to_jsonb(r), 'lexemes_examples_20261021_a2_b1: додано приклад — стара версія');
    update public.lexemes set examples = jsonb_build_array(d.e), version = coalesce(version, 1) + 1 where id = r.id;
    insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
    values ('lexeme', r.id, r.status, r.status, 'auto_passed', 'ai', '[]'::jsonb, 'Приклад додано 2026-10-21 (A2 / B1; scripts/lexemes_examples_data.py). Запускати лише після «ок» власника (A2+ — не бета). Потрібна перевірка носієм: content/reviews/2026-10-21_lexemes_examples.md.');
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
     and lower(l.lemma) in (select t.k from jsonb_to_recordset('[{"k": "administracija"}, {"k": "akcija"}, {"k": "aktivan"}, {"k": "aktivno"}, {"k": "aktualan"}, {"k": "akustika"}, {"k": "akutan"}, {"k": "alat"}, {"k": "alergija"}, {"k": "alergičan"}, {"k": "algebra"}, {"k": "ambiciozan"}, {"k": "ambijent"}, {"k": "amnestija"}, {"k": "analiza"}, {"k": "analizirati"}, {"k": "anestezija"}, {"k": "aparat"}, {"k": "apsolvent"}, {"k": "argument"}, {"k": "arhiva"}, {"k": "astronomija"}, {"k": "atmosfera"}, {"k": "atom"}, {"k": "automatski"}, {"k": "autoritet"}, {"k": "avenija"}, {"k": "baciti"}, {"k": "backup"}, {"k": "bajka"}, {"k": "bankarstvo"}, {"k": "bankovni"}, {"k": "bankrot"}, {"k": "bankrotirati"}, {"k": "barem"}, {"k": "bazen"}, {"k": "beba"}, {"k": "beskoristan"}, {"k": "besplodan"}, {"k": "bijes"}, {"k": "bilo tko"}, {"k": "bilo što"}, {"k": "biologija"}, {"k": "birati"}, {"k": "birokracija"}, {"k": "bitan"}, {"k": "bitka"}, {"k": "blagajnik"}, {"k": "blizak"}, {"k": "bogatstvo"}, {"k": "bonus"}, {"k": "boravak"}, {"k": "borba"}, {"k": "boriti se"}, {"k": "brak"}, {"k": "branitelj"}, {"k": "braniti"}, {"k": "brava"}, {"k": "brašno"}, {"k": "briga"}, {"k": "brinuti"}, {"k": "brisati"}, {"k": "brojati"}, {"k": "broš"}, {"k": "brošura"}, {"k": "brzina"}, {"k": "bunt"}, {"k": "burza"}, {"k": "bučan"}, {"k": "carina"}, {"k": "carinik"}, {"k": "cijeli"}, {"k": "cijepiti"}, {"k": "cjelina"}, {"k": "dakle"}, {"k": "daleki"}, {"k": "dapače"}, {"k": "dar"}, {"k": "darovati"}, {"k": "daska"}, {"k": "datum"}, {"k": "davati"}, {"k": "demokracija"}, {"k": "dernjati se"}, {"k": "detalj"}, {"k": "dežurstvo"}, {"k": "digitalizacija"}, {"k": "dijagnoza"}, {"k": "dijeliti"}, {"k": "dimenzija"}, {"k": "dio"}, {"k": "dionica"}, {"k": "diploma"}, {"k": "diplomata"}, {"k": "dirigent"}, {"k": "disanje"}, {"k": "disati"}, {"k": "distribucija"}, {"k": "diviti se"}, {"k": "dizajn"}, {"k": "dizajnirati"}, {"k": "djeca"}, {"k": "djelatnost"}, {"k": "djelo"}, {"k": "djelovati"}, {"k": "dob"}, {"k": "dobit"}, {"k": "dobivati"}, {"k": "dodatak"}, {"k": "dodir"}, {"k": "dodirnuti"}, {"k": "dogovarati"}, {"k": "dogovarati se"}, {"k": "dogovor"}, {"k": "dogovoriti"}, {"k": "dogovoriti se"}, {"k": "dohodak"}, {"k": "dokaz"}, {"k": "dokazati"}, {"k": "dokazivati"}, {"k": "dolazak"}, {"k": "doletjeti"}, {"k": "dom"}, {"k": "domaćica"}, {"k": "domaćin"}, {"k": "domišljat"}, {"k": "donirati"}, {"k": "dopustiti"}, {"k": "doputovati"}, {"k": "dopuštati"}, {"k": "dosjetiti se"}, {"k": "dostava"}, {"k": "dostaviti"}, {"k": "dostojanstvo"}, {"k": "dostupan"}, {"k": "dotrčati"}, {"k": "dovoljan"}, {"k": "dovoljno"}, {"k": "dovršiti"}, {"k": "doza"}, {"k": "doznati"}, {"k": "doživljaj"}, {"k": "društven"}, {"k": "društvene mreže"}, {"k": "društveni"}, {"k": "društvo"}, {"k": "državljanin"}, {"k": "državljanstvo"}, {"k": "dubina"}, {"k": "dubok"}, {"k": "dugovati"}, {"k": "duhovit"}, {"k": "duljina"}, {"k": "duša"}, {"k": "dužina"}, {"k": "dužnost"}, {"k": "dvorište"}, {"k": "džemper"}, {"k": "ekologija"}, {"k": "ekonomija"}, {"k": "ekonomist"}, {"k": "ekonomski"}, {"k": "ekran na dodir"}, {"k": "eksperiment"}, {"k": "elastičan"}, {"k": "element"}, {"k": "emisija"}, {"k": "emocija"}, {"k": "enciklopedija"}, {"k": "energija"}, {"k": "epoha"}, {"k": "etika"}, {"k": "evakuacija"}, {"k": "evo"}, {"k": "evolucija"}, {"k": "faktura"}, {"k": "fenomen"}, {"k": "fiksan"}, {"k": "filozofija"}, {"k": "financije"}, {"k": "financirati"}, {"k": "fizika"}, {"k": "flaster"}, {"k": "fleksibilan"}, {"k": "fond"}, {"k": "formalni"}, {"k": "formula"}, {"k": "formular"}, {"k": "fotograf"}, {"k": "frekvencija"}, {"k": "funkcija"}, {"k": "ga"}, {"k": "galerija"}, {"k": "generacija"}, {"k": "general"}, {"k": "geografija"}, {"k": "geometrija"}, {"k": "gibak"}, {"k": "gladak"}, {"k": "glasanje"}, {"k": "glasina"}, {"k": "glasovanje"}, {"k": "glatak"}, {"k": "glazbenik"}, {"k": "globalni"}, {"k": "globalno zatopljenje"}, {"k": "glumiti"}, {"k": "glup"}, {"k": "gorivo"}, {"k": "gospodarstvo"}, {"k": "gostovati"}, {"k": "gotovo"}, {"k": "govor"}, {"k": "govoriti istinu"}, {"k": "gradnja"}, {"k": "gradonačelnik"}, {"k": "granica"}, {"k": "gravitacija"}, {"k": "građanin"}, {"k": "građevinarstvo"}, {"k": "gripa"}, {"k": "grlo"}, {"k": "grom"}, {"k": "groznica"}, {"k": "grozno"}, {"k": "gubitak"}, {"k": "gubiti"}, {"k": "gubitnik"}, {"k": "gurnuti"}, {"k": "gust"}, {"k": "haker"}, {"k": "hardver"}, {"k": "heroj"}, {"k": "hipoteza"}, {"k": "hitnost"}, {"k": "hladnoća"}, {"k": "hlađenje"}, {"k": "hostel"}, {"k": "hoćemo"}, {"k": "hrabar"}, {"k": "hrabrost"}, {"k": "hrapav"}, {"k": "hvaliti"}, {"k": "ideja"}, {"k": "indeks"}, {"k": "industrija"}, {"k": "infekcija"}, {"k": "inflacija"}, {"k": "informacija"}, {"k": "informirati"}, {"k": "injekcija"}, {"k": "inovacija"}, {"k": "insekt"}, {"k": "instrument"}, {"k": "interakcija"}, {"k": "interes"}, {"k": "intervju"}, {"k": "invalid"}, {"k": "invalidnost"}, {"k": "inventura"}, {"k": "investicija"}, {"k": "investirati"}, {"k": "investitor"}, {"k": "ishod"}, {"k": "isključiti"}, {"k": "isključivati"}, {"k": "iskoristiti"}, {"k": "iskorištavati"}, {"k": "iskren"}, {"k": "iskrenost"}, {"k": "iskustvo"}, {"k": "isplata"}, {"k": "isplatiti"}, {"k": "isplivati"}, {"k": "isporučiti"}, {"k": "ispraviti"}, {"k": "ispravljati"}, {"k": "ispričati se"}, {"k": "ispuniti"}, {"k": "ispunjavati"}, {"k": "istek"}, {"k": "isteći"}, {"k": "isticati"}, {"k": "istinit"}, {"k": "istovjetnost"}, {"k": "istraga"}, {"k": "istražiti"}, {"k": "istraživanje"}, {"k": "istraživati"}, {"k": "istraživač"}, {"k": "istrčati"}, {"k": "izabrati"}, {"k": "izazivati"}, {"k": "izazov"}, {"k": "izbaviti"}, {"k": "izbivati"}, {"k": "izbjegavati"}, {"k": "izbjegnuti"}, {"k": "izbjeći"}, {"k": "izbori"}, {"k": "izdati"}, {"k": "izdavati"}, {"k": "izdavač"}, {"k": "izdržati"}, {"k": "izgledati"}, {"k": "izgovor"}, {"k": "izgraditi"}, {"k": "izjava"}, {"k": "izjaviti"}, {"k": "izlet"}, {"k": "izliječiti"}, {"k": "izložba"}, {"k": "izmišljen"}, {"k": "izmjeriti"}, {"k": "iznajmljivati"}, {"k": "iznenaditi"}, {"k": "iznenađivati"}, {"k": "iznimka"}, {"k": "izraz"}, {"k": "izračunati"}, {"k": "izum"}, {"k": "izumitelj"}, {"k": "izvještaj"}, {"k": "izvor"}, {"k": "izvor informacija"}, {"k": "izvoz"}, {"k": "izvrsno"}, {"k": "izvršavati"}, {"k": "izvršenje"}, {"k": "izvršiti"}, {"k": "jamačno"}, {"k": "jamstvo"}, {"k": "jasan"}, {"k": "java"}, {"k": "javiti"}, {"k": "javni"}, {"k": "je"}, {"k": "jedinstven"}, {"k": "jednobojan"}, {"k": "jednostavan"}, {"k": "jednostavno"}, {"k": "jednostavnost"}, {"k": "jedva"}, {"k": "jedva da"}, {"k": "jesi"}, {"k": "jezikoslovlje"}, {"k": "junak"}, {"k": "kamata"}, {"k": "kamera"}, {"k": "kamp"}, {"k": "kampanja"}, {"k": "kanal"}, {"k": "kandidat"}, {"k": "kapetan"}, {"k": "kapital"}, {"k": "kapuljača"}, {"k": "karakter"}, {"k": "karijera"}, {"k": "katastrofa"}, {"k": "kategorija"}, {"k": "katkad"}, {"k": "kazniti"}, {"k": "kašljati"}, {"k": "kemija"}, {"k": "kihati"}, {"k": "kipar"}, {"k": "kiparstvo"}, {"k": "kirurg"}, {"k": "kišan"}, {"k": "klasificirati"}, {"k": "klasičan"}, {"k": "klasično"}, {"k": "klimatske promjene"}, {"k": "klimatski"}, {"k": "klinika"}, {"k": "klupa"}, {"k": "književnost"}, {"k": "knjižničar"}, {"k": "koalicija"}, {"k": "kolebati se"}, {"k": "kolektiv"}, {"k": "količina"}, {"k": "koljeno"}, {"k": "komentar"}, {"k": "komentirati"}, {"k": "kompleksnost"}, {"k": "kompliciran"}, {"k": "kompromis"}, {"k": "komunicirati"}, {"k": "komunikacija"}, {"k": "konačno"}, {"k": "koncept"}, {"k": "kondukter"}, {"k": "konferencija"}, {"k": "konkurencija"}, {"k": "konkurent"}, {"k": "kontaktirati"}, {"k": "kontrolirati"}, {"k": "konzulat"}, {"k": "kopija"}, {"k": "kopno"}, {"k": "korak"}, {"k": "koristan"}, {"k": "koristiti"}, {"k": "korištenje"}, {"k": "koža"}, {"k": "krajolik"}, {"k": "krasti"}, {"k": "krađa"}, {"k": "kreativan"}, {"k": "kreativnost"}, {"k": "krema"}, {"k": "kretati se"}, {"k": "krhak"}, {"k": "krik"}, {"k": "kriminalac"}, {"k": "kriptiranje"}, {"k": "kritizirati"}, {"k": "krivica"}, {"k": "krivnja"}, {"k": "kriza"}, {"k": "krpa"}, {"k": "krut"}, {"k": "krvarenje"}, {"k": "krvariti"}, {"k": "kršiti"}, {"k": "kukavan"}, {"k": "kupac"}, {"k": "kustos"}, {"k": "kvaliteta"}, {"k": "kvantiteta"}, {"k": "lagati"}, {"k": "lakoća"}, {"k": "lavina"}, {"k": "laž"}, {"k": "lažan"}, {"k": "led"}, {"k": "leden"}, {"k": "leći"}, {"k": "lice"}, {"k": "lift"}, {"k": "lijen"}, {"k": "liječiti"}, {"k": "lingvistika"}, {"k": "list"}, {"k": "literatura"}, {"k": "ljepota"}, {"k": "ljubazan"}, {"k": "ljubaznost"}, {"k": "ljudi"}, {"k": "ljutiti se"}, {"k": "ljutnja"}, {"k": "logika"}, {"k": "lokalni"}, {"k": "lom"}, {"k": "lonac"}, {"k": "lud"}, {"k": "ludost"}, {"k": "lukav"}, {"k": "lutati"}, {"k": "ma tko"}, {"k": "majstor"}, {"k": "mana"}, {"k": "manifestacija"}, {"k": "manjina"}, {"k": "marljiv"}, {"k": "masa"}, {"k": "mast"}, {"k": "mastan"}, {"k": "mat"}, {"k": "materijal"}, {"k": "mašta"}, {"k": "maštovit"}, {"k": "medij"}, {"k": "mediji"}, {"k": "mehanika"}, {"k": "mekan"}, {"k": "menadžer"}, {"k": "metal"}, {"k": "metla"}, {"k": "metoda"}, {"k": "metodologija"}, {"k": "međutim"}, {"k": "mijenjati"}, {"k": "miješati"}, {"k": "mikrofon"}, {"k": "mikrovalna"}, {"k": "milost"}, {"k": "ministar"}, {"k": "ministarstvo"}, {"k": "mir"}, {"k": "miran"}, {"k": "miris"}, {"k": "mirisati"}, {"k": "miriti se"}, {"k": "mirovati"}, {"k": "misao"}, {"k": "misija"}, {"k": "misterija"}, {"k": "mjera"}, {"k": "mjeriti"}, {"k": "mjeriti temperaturu"}, {"k": "mještanin"}, {"k": "mladić"}, {"k": "mladost"}, {"k": "model"}, {"k": "modernizacija"}, {"k": "modernizirati"}, {"k": "moderno"}, {"k": "mogućnost"}, {"k": "mokar"}, {"k": "molba"}, {"k": "molekula"}, {"k": "momak"}, {"k": "momčad"}, {"k": "monolog"}, {"k": "moral"}, {"k": "moram"}, {"k": "mornar"}, {"k": "motel"}, {"k": "moć"}, {"k": "moćan"}, {"k": "mrak"}, {"k": "mrtav"}, {"k": "mrziti"}, {"k": "mržnja"}, {"k": "mudar"}, {"k": "mudrost"}, {"k": "mučiti"}, {"k": "mušterija"}, {"k": "nabava"}, {"k": "nacija"}, {"k": "nacionalni"}, {"k": "nacrt"}, {"k": "nada"}, {"k": "nadati se"}, {"k": "nadesno"}, {"k": "nadležnost"}, {"k": "naglas"}, {"k": "naglasak"}, {"k": "naglasiti"}, {"k": "naglašavati"}, {"k": "nagrada"}, {"k": "nagraditi"}, {"k": "naivan"}, {"k": "nakit"}, {"k": "nakon"}, {"k": "nalijevo"}, {"k": "namjera"}, {"k": "namjerno"}, {"k": "namjestiti"}, {"k": "napad"}, {"k": "napadati"}, {"k": "napasti"}, {"k": "napet"}, {"k": "napokon"}, {"k": "napor"}, {"k": "napredak"}, {"k": "napredovanje"}, {"k": "napredovati"}, {"k": "naprosto"}, {"k": "naprotiv"}, {"k": "narukvica"}, {"k": "nasilje"}, {"k": "naslov"}, {"k": "nasmijati"}, {"k": "nastajati"}, {"k": "nastati"}, {"k": "nastavljati"}, {"k": "nastojati"}, {"k": "natjecanje"}, {"k": "natjecatelj"}, {"k": "natjecati se"}, {"k": "natječaj"}, {"k": "naučiti"}, {"k": "naušnice"}, {"k": "navlaš"}, {"k": "navodno"}, {"k": "nazadovati"}, {"k": "nazočiti"}, {"k": "neboder"}, {"k": "nedostajati"}, {"k": "nedostatak"}, {"k": "nedostupan"}, {"k": "neformalan"}, {"k": "neiskren"}, {"k": "nejasan"}, {"k": "neke"}, {"k": "neljubazan"}, {"k": "nemoćan"}, {"k": "neobičan"}, {"k": "neodlučan"}, {"k": "neophodan"}, {"k": "neoprezan"}, {"k": "neovisan"}, {"k": "nepažljiv"}, {"k": "nepoznat"}, {"k": "nepošten"}, {"k": "nepravda"}, {"k": "neprijatelj"}, {"k": "neproziran"}, {"k": "nerazuman"}, {"k": "nered"}, {"k": "nesiguran"}, {"k": "nesposoban"}, {"k": "nespreman"}, {"k": "nesreća"}, {"k": "nestabilan"}, {"k": "nestajati"}, {"k": "nestati"}, {"k": "nestrpljiv"}, {"k": "nesvijest"}, {"k": "nesvjestica"}, {"k": "netočan"}, {"k": "netočno"}, {"k": "neugodan"}, {"k": "neuredan"}, {"k": "neuspjeh"}, {"k": "neuspješan"}, {"k": "neučinkovit"}, {"k": "nevin"}, {"k": "nevinost"}, {"k": "nevjerojatan"}, {"k": "nezadovoljan"}, {"k": "nezaposlenost"}, {"k": "nezreo"}, {"k": "nizina"}, {"k": "ništavan"}, {"k": "norma"}, {"k": "novinarstvo"}, {"k": "novine"}, {"k": "noćenje"}, {"k": "obavijest"}, {"k": "obavijestiti"}, {"k": "obavještavati"}, {"k": "obećanje"}, {"k": "obećavati"}, {"k": "običaj"}, {"k": "običan"}, {"k": "objava"}, {"k": "objašnjenje"}, {"k": "objekt"}, {"k": "oblik"}, {"k": "obnavljati"}, {"k": "obnoviti"}, {"k": "obožavati"}, {"k": "obrana"}, {"k": "obrazovanje"}, {"k": "obrt"}, {"k": "obrtnik"}, {"k": "obuhvatiti"}, {"k": "obuhvaćati"}, {"k": "obujam"}, {"k": "obuća"}, {"k": "obveza"}, {"k": "ocean"}, {"k": "ocijeniti"}, {"k": "ocjenjivati"}, {"k": "odbaciti"}, {"k": "odbijati"}, {"k": "odbijenica"}, {"k": "odbiti"}, {"k": "odbojan"}, {"k": "odgađati"}, {"k": "odgoditi"}, {"k": "odgovoran"}, {"k": "odgovornost"}, {"k": "odjava"}, {"k": "odjaviti"}, {"k": "odjaviti se"}, {"k": "odlazak"}, {"k": "odlaziti"}, {"k": "odletjeti"}, {"k": "odluka"}, {"k": "odlučan"}, {"k": "odlučiti"}, {"k": "odlučivati"}, {"k": "odmoran"}, {"k": "odnos"}, {"k": "odobravati"}, {"k": "odobrenje"}, {"k": "odobriti"}, {"k": "odredba"}, {"k": "odrediti"}, {"k": "odredište"}, {"k": "održati"}, {"k": "održavati"}, {"k": "održivost"}, {"k": "odustajati"}, {"k": "odustati"}, {"k": "oduševiti"}, {"k": "odvajati"}, {"k": "odvjetnik"}, {"k": "odvjetništvo"}, {"k": "odvojeno"}, {"k": "odvojenost"}, {"k": "odšteta"}, {"k": "ogledalo"}, {"k": "ograda"}, {"k": "ohol"}, {"k": "ohrabriti"}, {"k": "oklijevati"}, {"k": "okolica"}, {"k": "okolina"}, {"k": "okoliš"}, {"k": "okolnost"}, {"k": "okolo"}, {"k": "okriviti"}, {"k": "okruglo"}, {"k": "okruženje"}, {"k": "okus"}, {"k": "okusiti"}, {"k": "olakšanje"}, {"k": "olakšati"}, {"k": "omesti"}, {"k": "omogućavati"}, {"k": "omogućiti"}, {"k": "onak"}, {"k": "opeklina"}, {"k": "operacija"}, {"k": "operirati"}, {"k": "opisati"}, {"k": "opisivati"}, {"k": "oporavak"}, {"k": "oporaviti se"}, {"k": "oporba"}, {"k": "oprati"}, {"k": "opravdati"}, {"k": "opraštati"}, {"k": "oprostiti"}, {"k": "opskrba"}, {"k": "opstati"}, {"k": "optika"}, {"k": "optuženi"}, {"k": "optužiti"}, {"k": "opustiti se"}, {"k": "opuštanje"}, {"k": "opušten"}, {"k": "opći"}, {"k": "općina"}, {"k": "ordinacija"}, {"k": "organizacija"}, {"k": "organizator"}, {"k": "organizirati"}, {"k": "osiguranje"}, {"k": "osjetiti"}, {"k": "osjetiti bol"}, {"k": "osjećaj"}, {"k": "osjećati"}, {"k": "osloboditi"}, {"k": "osloboditi se"}, {"k": "oslonac"}, {"k": "osmijeh"}, {"k": "osmisliti"}, {"k": "osoba"}, {"k": "osoblje"}, {"k": "osposobljen"}, {"k": "ostajati"}, {"k": "ostaviti"}, {"k": "ostvariti"}, {"k": "osuditi"}, {"k": "osuđivati"}, {"k": "osvetiti se"}, {"k": "otežati"}, {"k": "otkaz"}, {"k": "otkazati"}, {"k": "otključati"}, {"k": "otkriti"}, {"k": "otkrivati"}, {"k": "otkriće"}, {"k": "otpad"}, {"k": "otpor"}, {"k": "otpremnica"}, {"k": "otputovati"}, {"k": "otrčati"}, {"k": "otvarati"}, {"k": "ovisan"}, {"k": "ovisiti"}, {"k": "ozbiljan"}, {"k": "ozdraviti"}, {"k": "ozlijediti"}, {"k": "ozljeda"}, {"k": "očaj"}, {"k": "očarati"}, {"k": "očekivanje"}, {"k": "očigledan"}, {"k": "oštar"}, {"k": "pacijent"}, {"k": "pakirati"}, {"k": "pakt"}, {"k": "pametan"}, {"k": "pamćenje"}, {"k": "papirologija"}, {"k": "paragraf"}, {"k": "parkirati"}, {"k": "parlament"}, {"k": "partner"}, {"k": "partnerica"}, {"k": "partnerstvo"}, {"k": "pasivnost"}, {"k": "pasti u nesvijest"}, {"k": "patiti"}, {"k": "pauza"}, {"k": "paziti"}, {"k": "pažljiv"}, {"k": "pedagogija"}, {"k": "pegla"}, {"k": "peglati"}, {"k": "periferija"}, {"k": "peći"}, {"k": "pečat"}, {"k": "pijesak"}, {"k": "pilot"}, {"k": "pisac"}, {"k": "pista"}, {"k": "pjesma"}, {"k": "pjesnik"}, {"k": "pješak"}, {"k": "pješačiti"}, {"k": "plah"}, {"k": "plakanje"}, {"k": "plastika"}, {"k": "plaćati"}, {"k": "plač"}, {"k": "plašljiv"}, {"k": "ples"}, {"k": "plesti"}, {"k": "plin"}, {"k": "plitak"}, {"k": "plitkoća"}, {"k": "plod"}, {"k": "plodonosan"}, {"k": "pobijediti"}, {"k": "pobjednik"}, {"k": "pobjeći"}, {"k": "poboljšati"}, {"k": "poboljšavati"}, {"k": "pod"}, {"k": "podaci"}, {"k": "podijeliti"}, {"k": "podizati"}, {"k": "podići"}, {"k": "podnijeti"}, {"k": "podrška"}, {"k": "podržati"}, {"k": "podsvijest"}, {"k": "poduzetnik"}, {"k": "poduzetništvo"}, {"k": "poduzeće"}, {"k": "poglavlje"}, {"k": "pogled"}, {"k": "pogoršati"}, {"k": "pogrešan"}, {"k": "pogreška"}, {"k": "pohrana"}, {"k": "pohvaliti"}, {"k": "pohvaljivati"}, {"k": "pojasniti"}, {"k": "pojaviti se"}, {"k": "pojedini"}, {"k": "pokazivati"}, {"k": "poklon"}, {"k": "pokloniti"}, {"k": "poklopac"}, {"k": "pokopati"}, {"k": "pokus"}, {"k": "pokušavati"}, {"k": "pokvaren"}, {"k": "pola"}, {"k": "polaziti"}, {"k": "polica"}, {"k": "politika"}, {"k": "politički"}, {"k": "poljoprivreda"}, {"k": "položaj"}, {"k": "pomaknuti"}, {"k": "pomilovanje"}, {"k": "pomilovati"}, {"k": "pomiriti se"}, {"k": "pomorac"}, {"k": "pomoć"}, {"k": "ponašanje"}, {"k": "ponašati se"}, {"k": "ponijeti"}, {"k": "ponosan"}, {"k": "ponuda"}, {"k": "popiti"}, {"k": "poplava"}, {"k": "porast"}, {"k": "poraz"}, {"k": "porez"}, {"k": "poricati"}, {"k": "porota"}, {"k": "poseban"}, {"k": "posjećivati"}, {"k": "posljedica"}, {"k": "poslodavac"}, {"k": "poslodavatelj"}, {"k": "poslovanje"}, {"k": "poslušan"}, {"k": "postizati"}, {"k": "postići"}, {"k": "postojati"}, {"k": "posuditi"}, {"k": "posuđivati"}, {"k": "posvađati se"}, {"k": "posvetiti se"}, {"k": "posvuda"}, {"k": "potez"}, {"k": "potomak"}, {"k": "potonuti"}, {"k": "potražnja"}, {"k": "potreba"}, {"k": "potreban"}, {"k": "potres"}, {"k": "potrošač"}, {"k": "potvrditi"}, {"k": "poučavati"}, {"k": "povezanost"}, {"k": "povezati"}, {"k": "povećati se"}, {"k": "povećavati"}, {"k": "povijest"}, {"k": "povjerenje"}, {"k": "povjerovati"}, {"k": "povod"}, {"k": "povući"}, {"k": "pozivati"}, {"k": "pozivnica"}, {"k": "poznanik"}, {"k": "poznat"}, {"k": "pozornica"}, {"k": "pozvati hitnu pomoć"}, {"k": "poći"}, {"k": "pošten"}, {"k": "poštenje"}, {"k": "poštovanje"}, {"k": "poštovati"}, {"k": "požar"}, {"k": "požuriti"}, {"k": "požurivati"}, {"k": "prag"}, {"k": "praksa"}, {"k": "prav"}, {"k": "prava"}, {"k": "pravda"}, {"k": "pravednost"}, {"k": "pravilo"}, {"k": "pravilo igre"}, {"k": "pravnik"}, {"k": "pravomoćnost"}, {"k": "pravopis"}, {"k": "prazan"}, {"k": "praznik"}, {"k": "preboljeti"}, {"k": "predak"}, {"k": "predati"}, {"k": "predavač"}, {"k": "predložiti"}, {"k": "prednost"}, {"k": "predomisliti se"}, {"k": "predsjednik"}, {"k": "predstava"}, {"k": "predstaviti se"}, {"k": "predstavljati"}, {"k": "predstavnik"}, {"k": "predvidjeti"}, {"k": "predviđati"}, {"k": "preferirati"}, {"k": "pregledati"}, {"k": "pregovarati"}, {"k": "pregovor"}, {"k": "pregovori"}, {"k": "prekinuti"}, {"k": "preko"}, {"k": "prekršaj"}, {"k": "prelaziti"}, {"k": "premijer"}, {"k": "preporuka"}, {"k": "prepoznati"}, {"k": "prespavati"}, {"k": "prestrašiti"}, {"k": "presuda"}, {"k": "pretpostaviti"}, {"k": "pretpostavljati"}, {"k": "pretvarati se"}, {"k": "preuzeti"}, {"k": "preuzimanje"}, {"k": "preuzimati"}, {"k": "prevariti"}, {"k": "prevoditelj"}, {"k": "prezentacija"}, {"k": "prezirati"}, {"k": "preživjeti"}, {"k": "preživljavati"}, {"k": "prigovor"}, {"k": "prihod"}, {"k": "prihvatiti"}, {"k": "prihvaćati"}, {"k": "prijateljstvo"}, {"k": "prijaviti"}, {"k": "prijaviti se"}, {"k": "prijenos"}, {"k": "prijetnja"}, {"k": "prilagoditi"}, {"k": "prilagoditi se"}, {"k": "prilagođavati"}, {"k": "primijetiti"}, {"k": "primiti"}, {"k": "primjer"}, {"k": "primjećivati"}, {"k": "princip"}, {"k": "prioritet"}, {"k": "pripadati"}, {"k": "priručnik"}, {"k": "prisjetiti se"}, {"k": "pristojba"}, {"k": "pristojnost"}, {"k": "prisustvovati"}, {"k": "pritisak"}, {"k": "pritisnuti"}, {"k": "privatan"}, {"k": "privatni"}, {"k": "privlačan"}, {"k": "privući"}, {"k": "priznati"}, {"k": "proces"}, {"k": "procijeniti"}, {"k": "produženje"}, {"k": "profil"}, {"k": "programirati"}, {"k": "proizvod"}, {"k": "proizvoditi"}, {"k": "proizvodnja"}, {"k": "projektirati"}, {"k": "promet"}, {"k": "promijeniti"}, {"k": "promijeniti se"}, {"k": "promisliti"}, {"k": "pronalaziti"}, {"k": "propasti"}, {"k": "propis"}, {"k": "propisati"}, {"k": "proputovati"}, {"k": "proračun"}, {"k": "proslava"}, {"k": "prostor"}, {"k": "prosvjed"}, {"k": "protiv"}, {"k": "protivnik"}, {"k": "protudjelovanje"}, {"k": "provesti"}, {"k": "provizija"}, {"k": "provoditi"}, {"k": "proziran"}, {"k": "prošetati se"}, {"k": "proširivati"}, {"k": "prošlost"}, {"k": "prsten"}, {"k": "pružiti prvu pomoć"}, {"k": "prvenstvo"}, {"k": "pržiti"}, {"k": "psihologija"}, {"k": "publika"}, {"k": "puls"}, {"k": "pustiti"}, {"k": "radišan"}, {"k": "radnik"}, {"k": "radno mjesto"}, {"k": "radost"}, {"k": "raketa"}, {"k": "rana"}, {"k": "rashod"}, {"k": "raskid"}, {"k": "raskrižje"}, {"k": "rasplakati"}, {"k": "raspoloženje"}, {"k": "rasprava"}, {"k": "raspravljati"}, {"k": "rasprodaja"}, {"k": "raspršiti"}, {"k": "rastaviti"}, {"k": "rasti"}, {"k": "rat"}, {"k": "rata"}, {"k": "ravnatelj"}, {"k": "ravnateljstvo"}, {"k": "ravnoteža"}, {"k": "razboljeti se"}, {"k": "razdijeliti"}, {"k": "razdoblje"}, {"k": "razdvojiti"}, {"k": "razina"}, {"k": "razlika"}, {"k": "razlikovati se"}, {"k": "različitost"}, {"k": "razljutiti"}, {"k": "razmisliti"}, {"k": "razmišljati"}, {"k": "razmjena"}, {"k": "raznolikost"}, {"k": "razočaranje"}, {"k": "razočarati"}, {"k": "razred"}, {"k": "razviti"}, {"k": "razviti se"}, {"k": "razvod"}, {"k": "razvoj"}, {"k": "razvrstati"}, {"k": "računati"}, {"k": "računovođa"}, {"k": "reakcija"}, {"k": "reciklaža"}, {"k": "recikliranje"}, {"k": "redak"}, {"k": "redatelj"}, {"k": "referendum"}, {"k": "reforma"}, {"k": "registar"}, {"k": "registrirati"}, {"k": "reklama"}, {"k": "resurs"}, {"k": "revolucija"}, {"k": "rezati"}, {"k": "rezultat"}, {"k": "rečenica"}, {"k": "režirati"}, {"k": "ribar"}, {"k": "ribarstvo"}, {"k": "rijedak"}, {"k": "riješiti"}, {"k": "rizik"}, {"k": "rješenje problema"}, {"k": "rob"}, {"k": "roba"}, {"k": "robot"}, {"k": "rodbina"}, {"k": "roditelj"}, {"k": "roditi se"}, {"k": "rodni list"}, {"k": "roman"}, {"k": "ropstvo"}, {"k": "rođakinja"}, {"k": "rođenje"}, {"k": "rudarstvo"}, {"k": "rukovodstvo"}, {"k": "ruksak"}, {"k": "rušiti"}, {"k": "ružnoća"}, {"k": "sadašnjost"}, {"k": "sadržaj"}, {"k": "sadržavati"}, {"k": "sakriti"}, {"k": "sakriti se"}, {"k": "sam"}, {"k": "sami"}, {"k": "san"}, {"k": "sandale"}, {"k": "sanjati"}, {"k": "sastaviti"}, {"k": "sastojati se"}, {"k": "savez"}, {"k": "saveznik"}, {"k": "savjest"}, {"k": "savjetovati"}, {"k": "saznati"}, {"k": "sekunda"}, {"k": "seljak"}, {"k": "semestar"}, {"k": "seminar"}, {"k": "servis"}, {"k": "shvatiti"}, {"k": "sigurnost"}, {"k": "simpatičan"}, {"k": "sindikat"}, {"k": "sinteza"}, {"k": "sirena"}, {"k": "siromaštvo"}, {"k": "sirovina"}, {"k": "sistem"}, {"k": "situacija"}, {"k": "sjajan"}, {"k": "sjednica"}, {"k": "sjesti"}, {"k": "sjećanje"}, {"k": "skakati"}, {"k": "skitati se"}, {"k": "sklad"}, {"k": "skladatelj"}, {"k": "skladište"}, {"k": "sklapanje"}, {"k": "sklonište"}, {"k": "skočiti"}, {"k": "skriti se"}, {"k": "skrivati"}, {"k": "skroman"}, {"k": "skupina"}, {"k": "skupiti"}, {"k": "slagati"}, {"k": "slavan"}, {"k": "slavlje"}, {"k": "sletjeti"}, {"k": "slikarstvo"}, {"k": "sličiti"}, {"k": "sličnost"}, {"k": "sloboda"}, {"k": "slobodno vrijeme"}, {"k": "slomiti"}, {"k": "složen"}, {"k": "složenost"}, {"k": "složiti se"}, {"k": "slučaj"}, {"k": "slučajno"}, {"k": "slušalice"}, {"k": "smanjenje"}, {"k": "smanjiti"}, {"k": "smanjiti se"}, {"k": "smanjivati"}, {"k": "smatrati"}, {"k": "smeđ"}, {"k": "smijeh"}, {"k": "smiješan"}, {"k": "smiriti se"}, {"k": "smisao"}, {"k": "smjeti"}, {"k": "smještaj"}, {"k": "smrt"}, {"k": "smrtni list"}, {"k": "snaga"}, {"k": "snage"}, {"k": "snaći se"}, {"k": "snimiti"}, {"k": "snimka"}, {"k": "sociologija"}, {"k": "softver"}, {"k": "spajati"}, {"k": "spas"}, {"k": "spasitelj"}, {"k": "spasiti život"}, {"k": "spašavanje"}, {"k": "spašavati"}, {"k": "spektar"}, {"k": "spisi"}, {"k": "spoj"}, {"k": "spojiti"}, {"k": "spominjati"}, {"k": "spona"}, {"k": "sponzorirati"}, {"k": "sporazum"}, {"k": "sporedni"}, {"k": "sportaš"}, {"k": "sposoban"}, {"k": "sposobnost"}, {"k": "spoznaja"}, {"k": "spoznati"}, {"k": "spoznatljiv"}, {"k": "spremati"}, {"k": "spremiti"}, {"k": "sprijateljiti se"}, {"k": "spriječiti"}, {"k": "sram"}, {"k": "sramežljiv"}, {"k": "srednji"}, {"k": "sredstvo"}, {"k": "srušiti"}, {"k": "srušiti se"}, {"k": "stabilan"}, {"k": "stabilnost"}, {"k": "stadion"}, {"k": "stagnirati"}, {"k": "standard"}, {"k": "stanje"}, {"k": "starac"}, {"k": "starost"}, {"k": "statistika"}, {"k": "status"}, {"k": "stav"}, {"k": "stečaj"}, {"k": "stih"}, {"k": "stoljeće"}, {"k": "stomatolog"}, {"k": "strah"}, {"k": "strahovati"}, {"k": "stranica"}, {"k": "stranka"}, {"k": "strast"}, {"k": "strategija"}, {"k": "stres"}, {"k": "strmoglaviti se"}, {"k": "strojovođa"}, {"k": "strop"}, {"k": "strpljenje"}, {"k": "strpljiv"}, {"k": "struktura"}, {"k": "stručnjak"}, {"k": "studij"}, {"k": "stup"}, {"k": "stupanj"}, {"k": "stvaran"}, {"k": "stvarati"}, {"k": "stvari"}, {"k": "stvarnost"}, {"k": "stvoriti"}, {"k": "sud"}, {"k": "sudac"}, {"k": "sudar"}, {"k": "sudionik"}, {"k": "suditi"}, {"k": "suditi se"}, {"k": "sudjelovati"}, {"k": "sudoper"}, {"k": "sudstvo"}, {"k": "suh"}, {"k": "suhoća"}, {"k": "sukob"}, {"k": "sumnja"}, {"k": "sumnjati"}, {"k": "suprotan"}, {"k": "suradnik"}, {"k": "suradnja"}, {"k": "surađivati"}, {"k": "suvlasnik"}, {"k": "suvremen"}, {"k": "suvremeni"}, {"k": "suđenje"}, {"k": "suša"}, {"k": "sušilo"}, {"k": "suživot"}, {"k": "svađa"}, {"k": "svađati se"}, {"k": "svemir"}, {"k": "sveučilište"}, {"k": "svijest"}, {"k": "svijetao"}, {"k": "svirati"}, {"k": "svjedok"}, {"k": "svjedočenje"}, {"k": "svjetiljka"}, {"k": "svjetlost"}, {"k": "svjež"}, {"k": "svojeglav"}, {"k": "svrha"}, {"k": "svugdje"}, {"k": "tajanstven"}, {"k": "tajna"}, {"k": "tajnica"}, {"k": "taktika"}, {"k": "talenat"}, {"k": "tama"}, {"k": "taman"}, {"k": "tanjurić"}, {"k": "taoc"}, {"k": "tata"}, {"k": "tava"}, {"k": "tehnički"}, {"k": "tehnologija"}, {"k": "televizija"}, {"k": "temelj"}, {"k": "temeljni"}, {"k": "teorija"}, {"k": "tepsija"}, {"k": "terapija"}, {"k": "termometar"}, {"k": "težina"}, {"k": "tisak"}, {"k": "tisuća"}, {"k": "tišina"}, {"k": "tjeskoba"}, {"k": "tješiti"}, {"k": "tkanina"}, {"k": "tlak"}, {"k": "tlo"}, {"k": "ton"}, {"k": "toplina"}, {"k": "tradicija"}, {"k": "tradicionalan"}, {"k": "trajati"}, {"k": "trajekt"}, {"k": "transakcija"}, {"k": "trebam"}, {"k": "trofej"}, {"k": "trovanje"}, {"k": "trošak"}, {"k": "trud"}, {"k": "tržište"}, {"k": "tugovati"}, {"k": "tumačiti"}, {"k": "tup"}, {"k": "turizam"}, {"k": "tuča"}, {"k": "tužba"}, {"k": "tužitelj"}, {"k": "tužiteljstvo"}, {"k": "tužiti"}, {"k": "tvar"}, {"k": "tvrd"}, {"k": "tvrditi"}, {"k": "tvrdoglav"}, {"k": "ubijati"}, {"k": "ubojica"}, {"k": "ubrzanje"}, {"k": "ubrzati"}, {"k": "udruga"}, {"k": "ugasiti"}, {"k": "ugled"}, {"k": "ugostiteljstvo"}, {"k": "ugovor o radu"}, {"k": "uhititi"}, {"k": "uključivati"}, {"k": "ukras"}, {"k": "ukrasiti"}, {"k": "ukupan"}, {"k": "ulaganje"}, {"k": "ulagati"}, {"k": "uložiti"}, {"k": "um"}, {"k": "umalo"}, {"k": "umiriti"}, {"k": "umirovljenik"}, {"k": "umjesto"}, {"k": "umjetan"}, {"k": "umjetnik"}, {"k": "umjetnost"}, {"k": "umrijeti"}, {"k": "unaokolo"}, {"k": "uništenje"}, {"k": "unuk"}, {"k": "unuka"}, {"k": "uostalom"}, {"k": "uplata"}, {"k": "uplašiti"}, {"k": "uplašiti se"}, {"k": "uporan"}, {"k": "upoznavati"}, {"k": "upozoravati"}, {"k": "upozorenje"}, {"k": "uprava"}, {"k": "upravitelj"}, {"k": "upravljanje"}, {"k": "upravljati"}, {"k": "upute"}, {"k": "uputnica"}, {"k": "uragan"}, {"k": "uredan"}, {"k": "uredba"}, {"k": "urediti"}, {"k": "urednik"}, {"k": "uređaj"}, {"k": "usisavati"}, {"k": "uskladiti"}, {"k": "usluga"}, {"k": "usluge"}, {"k": "uspjeh"}, {"k": "uspješan"}, {"k": "usporediti"}, {"k": "usporiti"}, {"k": "ustanova"}, {"k": "ustav"}, {"k": "utakmica"}, {"k": "utisak"}, {"k": "utjecaj"}, {"k": "utjecati"}, {"k": "utješiti"}, {"k": "utopiti se"}, {"k": "uvjerenje"}, {"k": "uvoz"}, {"k": "uzak"}, {"k": "uzbuna"}, {"k": "uzbuđenje"}, {"k": "uzdah"}, {"k": "uzdahnuti"}, {"k": "uzdisati"}, {"k": "uzeti lijek"}, {"k": "uznemiriti se"}, {"k": "učenik"}, {"k": "učinak"}, {"k": "učinkovit"}, {"k": "učinkovitost"}, {"k": "učionica"}, {"k": "uštedjeti"}, {"k": "užina"}, {"k": "uživati"}, {"k": "vagati"}, {"k": "valjanost"}, {"k": "valjda"}, {"k": "valuta"}, {"k": "varati"}, {"k": "vatra"}, {"k": "vaza"}, {"k": "važiti"}, {"k": "važnost"}, {"k": "veleposlanstvo"}, {"k": "veseliti se"}, {"k": "većina"}, {"k": "video"}, {"k": "vidimo"}, {"k": "vidio"}, {"k": "vijest"}, {"k": "vijesti"}, {"k": "vika"}, {"k": "vikati"}, {"k": "virus"}, {"k": "visina"}, {"k": "vizija"}, {"k": "vjenčani list"}, {"k": "vjenčanje"}, {"k": "vjerojatan"}, {"k": "vjerojatno"}, {"k": "vječnost"}, {"k": "vještina"}, {"k": "vlada"}, {"k": "vlasnik"}, {"k": "vlast"}, {"k": "vlažan"}, {"k": "vlažnost"}, {"k": "voditelj"}, {"k": "voditi"}, {"k": "vodstvo"}, {"k": "vojnik"}, {"k": "vojska"}, {"k": "volim"}, {"k": "vozilo"}, {"k": "vođa"}, {"k": "vratiti"}, {"k": "vratiti se"}, {"k": "vrijedan"}, {"k": "vrijediti"}, {"k": "vrijednost"}, {"k": "zaborav"}, {"k": "zabrana"}, {"k": "zabraniti"}, {"k": "zacijelo"}, {"k": "zadaća"}, {"k": "zagađenje"}, {"k": "zagonetka"}, {"k": "zahtijevati"}, {"k": "zahtjev"}, {"k": "zajam"}, {"k": "zajednica"}, {"k": "zajednički"}, {"k": "zaklada"}, {"k": "zaključak"}, {"k": "zaključati"}, {"k": "zaključiti"}, {"k": "zaliha"}, {"k": "zaljubiti se"}, {"k": "zamalo"}, {"k": "zamijeniti"}, {"k": "zamisliti"}, {"k": "zamišljati"}, {"k": "zamrzivač"}, {"k": "zanatlija"}, {"k": "zapanjiti"}, {"k": "zaplivati"}, {"k": "zapošljavanje"}, {"k": "zarađivati"}, {"k": "zarobiti"}, {"k": "zasigurno"}, {"k": "zastarjelost"}, {"k": "zatajiti"}, {"k": "zatvor"}, {"k": "zaustavljati se"}, {"k": "zavidjeti"}, {"k": "zavjesa"}, {"k": "zavoj"}, {"k": "zaštita"}, {"k": "zaštititi"}, {"k": "zbog"}, {"k": "zdravstvo"}, {"k": "zid"}, {"k": "zlo"}, {"k": "zlonamjerni softver"}, {"k": "zločin"}, {"k": "znak"}, {"k": "znam"}, {"k": "znanje"}, {"k": "znanost"}, {"k": "znanstvenik"}, {"k": "značaj"}, {"k": "značajan"}, {"k": "značenje"}, {"k": "značiti"}, {"k": "znaš"}, {"k": "zračenje"}, {"k": "zreo"}, {"k": "čamac"}, {"k": "časnik"}, {"k": "čast"}, {"k": "čekanje"}, {"k": "čestica"}, {"k": "činjenica"}, {"k": "činovnik"}, {"k": "čizme"}, {"k": "član"}, {"k": "članak"}, {"k": "čudan"}, {"k": "čuvati"}, {"k": "čvrst"}, {"k": "šal"}, {"k": "šala"}, {"k": "šansa"}, {"k": "šapat"}, {"k": "šaputati"}, {"k": "šaren"}, {"k": "šešir"}, {"k": "širina"}, {"k": "širok"}, {"k": "šivati"}, {"k": "šok"}, {"k": "šokirati"}, {"k": "šprica"}, {"k": "štedjeti"}, {"k": "štednja"}, {"k": "štetan"}, {"k": "štetiti"}, {"k": "štogod"}, {"k": "štoviše"}, {"k": "štrajk"}, {"k": "šum"}, {"k": "šumarstvo"}, {"k": "šutjeti"}, {"k": "žalba"}, {"k": "žalost"}, {"k": "žalovati"}, {"k": "želim"}, {"k": "želiš"}, {"k": "živ"}, {"k": "životni vijek"}, {"k": "životopis"}, {"k": "žrtva"}, {"k": "županija"}]'::jsonb) as t(k text));
  select count(*) into v_done from public.content_reviews where notes = 'Приклад додано 2026-10-21 (A2 / B1; scripts/lexemes_examples_data.py). Запускати лише після «ок» власника (A2+ — не бета). Потрібна перевірка носієм: content/reviews/2026-10-21_lexemes_examples.md.';
  if v_empty > 0 then raise exception 'Лишилось слів без прикладу: %', v_empty; end if;
  raise notice 'Готово: приклади (A2 / B1) додано (записів у журналі перевірки: %)', v_done;
end $$;

commit;
