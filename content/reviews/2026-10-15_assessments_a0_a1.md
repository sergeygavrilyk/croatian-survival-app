# Тести рівня A0 і A1 (assessment_v1) — звіт для перевірки

> Згенеровано `scripts/gen_assessment.py` 2026-10-15. Хорватське взято з опублікованих уроків і текстів для читання;
> нових хорватських речень немає. Нове — лише **поєднання**: які варіанти стоять поруч як «неправильні».

## Що варто глянути носію

1. **«Спілкуюся»** — чи не підходить одна з «неправильних» відповідей теж (тоді тест несправедливий).
   Пастки взято з діалогів інших модулів; загальні відповіді (*Hvala*, *Može*, *U redu*…) відкинуто.
2. **«Переказую»** — чи переклад відповіді в діалозі точний (його взято з уроку).
3. **«Складіть речення»** — чи немає іншого правильного порядку слів (зараз приймається лише один).
4. **`a1-mid` #10** (і урок-джерело): *Umoran je. Prvo ga kupamo, a onda ga presvuci.* — «ми купаємо», але «ти переодягни»: чи природно, чи краще *…a onda ga presvučemo*.

## Склад

| Тест | Завдань | Розумію | Спілкуюся | Переказую | Кажу |
|---|---|---|---|---|---|
| `a0-m01` Перевірка модуля A0.1 | 10 | 3 | 2 | 2 | 3 |
| `a0-m02` Перевірка модуля A0.2 | 10 | 3 | 2 | 2 | 3 |
| `a0-m03` Перевірка модуля A0.3 | 10 | 3 | 2 | 2 | 3 |
| `a0-m04` Перевірка модуля A0.4 | 10 | 3 | 2 | 2 | 3 |
| `a0-m05` Перевірка модуля A0.5 | 10 | 3 | 2 | 2 | 3 |
| `a0-mid` Перевірка середини рівня A0 | 20 | 5 | 5 | 5 | 5 |
| `a0-m06` Перевірка модуля A0.6 | 10 | 3 | 2 | 2 | 3 |
| `a0-m07` Перевірка модуля A0.7 | 10 | 3 | 2 | 2 | 3 |
| `a0-m08` Перевірка модуля A0.8 | 10 | 3 | 2 | 2 | 3 |
| `a0-m09` Перевірка модуля A0.9 | 10 | 3 | 2 | 2 | 3 |
| `a0-m10` Перевірка модуля A0.10 | 10 | 3 | 2 | 2 | 3 |
| `a0-final` Фінальна перевірка рівня A0 | 30 | 8 | 7 | 7 | 8 |
| `a1-m01` Перевірка модуля A1.1 | 10 | 3 | 2 | 2 | 3 |
| `a1-m02` Перевірка модуля A1.2 | 10 | 3 | 2 | 2 | 3 |
| `a1-m03` Перевірка модуля A1.3 | 10 | 3 | 2 | 2 | 3 |
| `a1-m04` Перевірка модуля A1.4 | 10 | 3 | 2 | 2 | 3 |
| `a1-m05` Перевірка модуля A1.5 | 10 | 3 | 2 | 2 | 3 |
| `a1-mid` Перевірка середини рівня A1 | 20 | 5 | 5 | 5 | 5 |
| `a1-m06` Перевірка модуля A1.6 | 10 | 3 | 2 | 2 | 3 |
| `a1-m07` Перевірка модуля A1.7 | 10 | 3 | 2 | 2 | 3 |
| `a1-m08` Перевірка модуля A1.8 | 10 | 3 | 2 | 2 | 3 |
| `a1-m09` Перевірка модуля A1.9 | 10 | 3 | 2 | 2 | 3 |
| `a1-m10` Перевірка модуля A1.10 | 10 | 3 | 2 | 2 | 3 |
| `a1-final` Фінальна перевірка рівня A1 | 30 | 8 | 7 | 7 | 8 |

## Завдання «Спілкуюся» A0 (усі)

- `a0-m01` #4: *Vrećicu? Trebate li vrećicu?* → Početkom rujna, a završava u lipnju. / Ovo je moja žena Olga. / **Ah, da. Jednu, molim.**
- `a0-m01` #5: *Dobro, hvala. A Vi?* → Dvadeset dva, treći kat. / **Ne baš dobro. Umorna sam.** / Ja imam sedam. Ovo je moj pas.
- `a0-m02` #4: *Imate li iskustva?* → Piletina s rižom i salatom. / **Da, pet godina.** / Čaj, molim. Šalicu toplog čaja.
- `a0-m02` #5: *Jesam. Govoriš li hrvatski?* → **Malo. Govorim ukrajinski i engleski.** / Ta majica košta dvadeset eura. / Zove se Bohdan. On je iz Ukrajine.
- `a0-m03` #4: *Koji je Vaš broj telefona?* → Malo. Učim hrvatski. / Ja pijem limunadu s ledom. / **Nula devedeset jedan, šezdeset sedam, osamdeset dva, sedamdeset tri.**
- `a0-m03` #5: *Koliko košta ova jakna?* → Izgubio sam se. Tražim hotel Central. / **Devedeset eura.** / Ja sam profesorica. Radim u školi.
- `a0-m04` #4: *U srpnju. A ti?* → Tramvajem, autom je gužva. Stanica je na raskrižju. / **U siječnju. Volim zimu!** / Izgubio sam se. Tražim hotel Central.
- `a0-m04` #5: *Kada ideš na godišnji odmor?* → Ja sam medicinska sestra. / Krevet, stol, stolica i ormar. / **U kolovozu. Idem na more.**
- `a0-m05` #4: *Imaš li brata ili sestru?* → Ukrajinski, poljski i malo njemački. / Danas je srijeda. / **Imam jednu sestru. Ona živi u Kijevu.**
- `a0-m05` #5: *Imaš li djecu?* → Ja sam profesorica. Radim u školi. / **Da, imam sina i kćer.** / Devedeset eura.
- `a0-mid` #6: *Koliko imaju godina?* → Bok, Ivane! Zovem se Maja. / **Deset i dvanaest.** / U siječnju. Volim zimu!
- `a0-mid` #7: *Koliko minuta do centra?* → Piletina s rižom i salatom. / **Otprilike petnaest minuta.** / Tramvajem, autom je gužva. Stanica je na raskrižju.
- `a0-mid` #8: *Oprostite, koliko je sati?* → **Deset sati.** / U park! A onda u knjižnicu. / Čaj, molim. Šalicu toplog čaja.
- `a0-mid` #9: *Ne razumijem dobro hrvatski. Možete li govoriti polako?* → **Naravno. Dobro došli u Zagreb!** / Ja sam iz Splita, ali živim u Zagrebu. / Na stolu.
- `a0-mid` #10: *Koji je kućni broj?* → **Dvadeset dva, treći kat.** / Ja sam oženjen i imam unuka! / Jako slatke! Probajte.
- `a0-m06` #4: *Gdje je moja soba?* → Dva eura. / Dobro! Imam novog prijatelja. / **Gore, na katu, pored velikog ogledala.**
- `a0-m06` #5: *Koliko soba ima stan?* → Idite ravno do semafora, pa skrenite desno. / Zelenu ili žutu. / **Dvije sobe.**
- `a0-m07` #4: *Mama, što je za večeru?* → Ja sam oženjen i imam unuka! / **Piletina s rižom i salatom.** / Ja sam medicinska sestra.
- `a0-m07` #5: *Želiš li čaj ili kavu?* → U kolovozu. Idem na more. / Izgubio sam se. Tražim hotel Central. / **Čaj, molim. Šalicu toplog čaja.**
- `a0-m08` #4: *Može malo više?* → U park! A onda u knjižnicu. / Idite ravno do semafora, pa skrenite desno. / **Može. I pola kile šunke.**
- `a0-m08` #5: *Koju boju želite?* → Moj prijatelj je pao. Boli ga noga. / Dvadeset dva, treći kat. / **Zelenu ili žutu.**
- `a0-m09` #4: *U jednom smjeru. Kada ide autobus?* → Izgubio sam se. Tražim hotel Central. / **U devet sati, s perona tri.** / Ukrajinski, poljski i malo njemački.
- `a0-m09` #5: *Idemo u park ili u kino?* → Ovo je moja žena Olga. / Tek tjedan dana. / **U park! A onda u knjižnicu.**
- `a0-m10` #4: *Koliko dugo čekamo?* → **Oko sat vremena. Ja čekam od osam.** / Piletina s rižom i salatom. / U stanu, u velikoj zgradi.
- `a0-m10` #5: *Što se dogodilo?* → **Moj prijatelj je pao. Boli ga noga.** / U siječnju. Volim zimu! / U kolovozu. Idem na more.
- `a0-final` #9: *Oprostite, koliko košta ova kava?* → Dobro! Imam novog prijatelja. / Jako slatke! Probajte. / **Dva eura.**
- `a0-final` #10: *Imaš li rodbinu u Hrvatskoj?* → Petsto eura mjesečno. / Devedeset eura. / **Imam. Moja teta i ujak žive u Rijeci.**
- `a0-final` #11: *Imate li temperaturu?* → Nula, devet, jedan, dva, tri, četiri, pet. / Sin ima pet, a kći osam godina. / **Da, malo.**
- `a0-final` #12: *Je li daleko?* → Čaj, molim. Šalicu toplog čaja. / **Ne, blizu je. Pet minuta pješice.** / Ja sam profesorica. Radim u školi.
- `a0-final` #13: *Što ima u tvojoj sobi?* → **Krevet, stol, stolica i ormar.** / Početkom rujna, a završava u lipnju. / Oko dva sata.
- `a0-final` #14: *Dobar dan! Koji je Vaš kućni broj?* → Malo. Govorim ukrajinski i engleski. / Tramvajem, autom je gužva. Stanica je na raskrižju. / **Broj sedam.**
- `a0-final` #15: *Je li ovo tvoja mama?* → Nula, devet, jedan, dva, tri, četiri, pet. / Dvije sobe. / **Da, to je moja mama, a ovo je moj tata.**

## Завдання «Спілкуюся» A1 (усі)

- `a1-m01` #4: *Možemo li se naći ovaj tjedan?* → Na festivalu u Puli, u Areni. / **Moram pogledati raspored. Imam puno obveza.** / Na trgu u centru. Slavlje traje do jutra!
- `a1-m01` #5: *Opet? Što ja radim?* → Trebamo madrac i komodu za spavaću sobu. / S osiguranjem ne plaćate ništa. / **Ti usisavaš sobe, a tata pere suđe.**
- `a1-m02` #4: *S čokoladom. Imate li i neki slani namaz?* → Rijetko, zbog hladnoće. / Smijete, ali morate platiti. Ovo je druga zona. / **Imamo namaz od sira i salamu.**
- `a1-m02` #5: *Evo. Mogu li probati?* → **Možeš. Pazi, vruće je!** / Umoran je. Prvo ga kupamo, a onda ga presvuci. / Nekoliko eura. Ovjeru dobivate odmah.
- `a1-m03` #4: *A rukavice? Gdje su mi rukavice?* → **U ladici, pored čarapa.** / Oko tri sata autom. Na zapadu je. / Jako. I romantičan je, vodi me na večeru uz more.
- `a1-m03` #5: *Da, jednu. Mogu li platiti karticom?* → Tisuću dvjesto eura neto. / **Naravno. Unesite PIN.** / Rijetko, zbog hladnoće.
- `a1-m04` #4: *Opet kolona! Ima li obilaznica?* → Na Zlatnom ratu. More je predivno, kupamo se svaki dan! / **Ima. Na kružnom toku skreni u smjeru Zagreba.** / Obuci plave hlače i bijelu majicu.
- `a1-m04` #5: *Mogu. Koliko košta popravak?* → Pržimo kupus s lukom u tavi. / **Ne znam još. Zovem Vas kad je gotov.** / Svaki je lijep na svoj način!
- `a1-m05` #4: *Mogu li se useliti prvog?* → U kupaonici, pored sapuna. Brzo! / Na sljedećoj. Onda uzmite šesticu. / **Možete. Ugovor potpisujemo sutra.**
- `a1-m05` #5: *Nema problema. Imate li još pločica?* → **Imam. I promijenite, molim Vas, žarulju na stropu.** / U osam, kod mene. / Igram, svake nedjelje s kolegama.
- `a1-mid` #6: *Koliko traje vožnja?* → **Oko četiri sata.** / Uključuje se, ali nema zvuka. Ni kabel ne pomaže. / Kajganu i tost, molim.
- `a1-mid` #7: *Koliko je najamnina?* → Smijete, ali morate platiti. Ovo je druga zona. / Rodni list, potvrda o cijepljenju i Vaš OIB. / **Petsto pedeset eura i režije.**
- `a1-mid` #8: *Izvolite, što tražite?* → Oko četiristo. Autocestom treba četiri sata. / Dragi putnici, vežite pojas. Krećemo! / **Trebamo madrac i komodu za spavaću sobu.**
- `a1-mid` #9: *Što danas kuhamo?* → Uzmite jednu tabletu tri puta dnevno. / **Pržimo kupus s lukom u tavi.** / Treba. Donesite diplomu i prijevod.
- `a1-mid` #10: *Mali plače. Što mu je?* → **Umoran je. Prvo ga kupamo, a onda ga presvuci.** / Dva eura. Karticu dobivate za deset dana. / U deset. Ili noćni autobus u jedanaest navečer.
- `a1-m06` #4: *Hvala! Možeš li mi skenirati i ovu putovnicu?* → **Mogu. Datoteku spremam u mapu Klijenti.** / Pedeset minuta. Čekajte u drugom redu. / Pakiranje je oštećeno, a šalica unutra je razbijena.
- `a1-m06` #5: *Znam. Trebam li donijeti potvrdu?* → Odlična! Glumac u glavnoj ulozi je fantastičan. / **Da, za bolovanje. Ozdravite brzo!** / U deset. Ili noćni autobus u jedanaest navečer.
- `a1-m07` #4: *Dobro jutro. Jeste li natašte?* → **Jesam, ništa ne jedem od jučer.** / Trebamo madrac i komodu za spavaću sobu. / Odlična! Glumac u glavnoj ulozi je fantastičan.
- `a1-m07` #5: *Kolika je temperatura na toplomjeru?* → Na trgu u centru. Slavlje traje do jutra! / Ja za Dinamo. Mislim da Dinamo danas pobjeđuje. / **Trideset osam. I stalno kiše, curi joj nos.**
- `a1-m08` #4: *Što voliš raditi u slobodno vrijeme?* → U četrnaest i dvadeset, s trećeg perona. / U ladici, pored čarapa. / **Volim plivati i fotografirati.**
- `a1-m08` #5: *Hoću! Gdje se nalazimo?* → Moram pogledati raspored. Imam puno obveza. / Mene. Ja sam odgovoran za cijeli tim. / **Ispred kolodvora, u devet točno.**
- `a1-m09` #4: *Sat vremena za jednu kavu?* → Obuci plave hlače i bijelu majicu. / Oko deset dana. / **Naravno! Sjedimo na terasi i pričamo.**
- `a1-m09` #5: *Marko, ti si iz Dalmacije?* → Nažalost, ne mogu. Moram raditi. / Tri godine. Volim Rijeku, ali mi nedostaje dom. / **Da, iz Splita. To je na jugu, na moru.**
- `a1-m10` #4: *Jesu li potrebne i ocjene s fakulteta?* → Kajganu i tost, molim. / **Jesu, i popis predavanja.** / Na Badnjak kitimo bor, a navečer idemo na misu.
- `a1-m10` #5: *Super! Što želite vidjeti?* → Odlična! Glumac u glavnoj ulozi je fantastičan. / **Želim joj pokazati Plitvice i more.** / Na stoliću, pored zavjese.
- `a1-final` #9: *Oprostite, gdje mogu kupiti kartu?* → Radim kao vozač već pet godina. / Sutra poslijepodne. Ostavite broj mobitela, molim. / **Na kiosku ili u tramvaju, kod vozača.**
- `a1-final` #10: *Zašto učite hrvatski?* → **Zato što želim razgovarati s kolegama.** / Poslije jela. I pijte puno vode. / Pire ili kuhani krumpir. Uzmite pladanj.
- `a1-final` #11: *Govedine ili svinjetine?* → U prodaji. Radim s klijentima. / **Govedine. I dva odreska od puretine, molim.** / Ujutro šetam u parku, a popodne čitam.
- `a1-final` #12: *Kako si sada?* → Do petnaestog u mjesecu. / Oko tri sata autom. Na zapadu je. / **Puno bolje! Više nisam bolestan.**
- `a1-final` #13: *Može. Kako ide selidba?* → Vodu, sendvič i udobne cipele. / Tablicu s cijenama. Ona je u privitku mog maila. / **Teško, ali prijevoz je jeftin jer prijatelj ima kombi.**
- `a1-final` #14: *Mogu li ovdje provjeriti gume?* → Odlična! Glumac u glavnoj ulozi je fantastičan. / **Možete, zrak je iza postaje.** / Sličan je, ali i jako različit. Treba biti strpljiv.
- `a1-final` #15: *Imam putovnicu. Koliko košta ovjera?* → Radim kao sobarica u hotelu. Moj muž je kuhar. / **Nekoliko eura. Ovjeru dobivate odmah.** / U ladici, pored čarapa.

