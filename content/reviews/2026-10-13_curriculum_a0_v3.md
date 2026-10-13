# Перевірка контенту: доповнення A0 (curriculum_a0_v3)

**Дата:** 2026-10-13  
**Хто перевіряв:** AI (Claude) + автоматичні перевірки генератора. Носій мови — ще ні.  
**Статус:** PUBLISHED як **бета**, як решта A0.

**Рішення власника:** «+1–2 уроки в кожен модуль, якщо модуль не повний по суті (наприклад, у модулі з днями тижня немає слова «вчора»)».

Файли:

- дані: `scripts/curriculum_a0_v3_data.py`;
- знімок слів робочої бази: `scripts/curriculum_a0_v3_snapshot.json` (+ знімки v2 і A1);
- генератор: `scripts/gen_curriculum_a0_v3.py`, спільна логіка уроку — `scripts/full_lessons.py`;
- SQL: `supabase/data_fixes/20261013_curriculum_a0_v3.sql`;
- тест: `supabase/tests/curriculum_a0_v3.test.sql`.

## Чого бракувало і що додано

| Модуль | Чого бракувало по суті | Нові уроки |
|---|---|---|
| A0.1 Pozdrav | прощання й ввічливість: vidimo se, do sutra, sretno, ispričavam se | «Прощання і ввічливість» |
| A0.2 Ja sam… | де ви живете; мови й національності | «Де ви живете?», «Мови й національності» |
| A0.3 Brojevi | числа 11–19 і 60–100, номер телефону | «Числа від 11 до 19», «До ста і номер телефону» |
| A0.4 Vrijeme | **jučer**, prekjučer, prekosutra, частини дня; з 12 місяців було 4 | «Учора, сьогодні, завтра», «Місяці й дати» |
| A0.5 Obitelj | родичі й стосунки | «Родичі й стосунки» |
| A0.6 Moj dom | спальня, коридор, туалет, техніка | «Кімнати й техніка» |
| A0.7 Hrana | напої; вечеря й смаки | «Напої», «Вечеря» |
| A0.8 Kupovina | кількість (deka, litra, pola kile); кольори | «Скільки вам?», «Кольори» |
| A0.9 Grad | місця в місті; як пройти | «Місця в місті», «Як пройти?» |
| A0.10 Survival | документи в MUP; загублений гаманець і поліція | «Документи в MUP», «Не можу знайти гаманець» |

Разом:

- **+17 уроків**, у A0 тепер 47;
- 34 діалоги (149 реплік) і 204 вправи;
- нова тема граматики **«Порядок слів»** (§21 ТЗ: basic word order) з трьома правилами;
- **49 нових слів** у словнику;
- в уроках A0 тепер **461 різне слово** (було 283; план ТЗ — ~500).

Назви всіх уроків A0 перенумеровано підряд («Урок 1» … «Урок 47»); старі назви збережено в `content_versions`.

**Виправлення словника** (стара версія — у `content_versions`):

- *evo* — «тут» → «ось; ось тут»;
- *kuća* — «дім» → «будинок; дім»;
- *drag* — «дорогий» → «дорогий; милий, приємний»;
- *tek* — «тільки-но, щойно» → «лише; тільки-но, щойно»;
- лема *mUP* → *MUP*;
- *hrvat* → *Hrvat*, *ukrajinac* → *Ukrajinac* (національності в хорватській пишуться з великої літери).

## Автоматичні перевірки

- [x] ті самі, що для A1 (див. `2026-10-13_curriculum_a1_v1.md`);
- [x] в A0 є всі 12 місяців і *jučer* (тест);
- [x] у кожному модулі A0 тепер 4–5 уроків;
- [x] номери в назвах уроків A0 йдуть підряд;
- [x] локально: SQL застосовано двічі без дублів, в обох порядках з A1; усі 12 SQL-тестів проходять.

## Мовна перевірка (AI)

Що варто глянути носію:

1. *Trideset deka ovog sira* і *pola kile šunke* — так кажуть у магазині, але це розмовні форми (*deka*, *kila*).
2. *Jučer posao, danas tečaj, a sutra more!* — речення без дієслова. На A0 ще немає минулого часу, тому «вчора» вжито так.
3. *Oprostite, je li blizu neka trgovina?* — чи природніше *Ima li u blizini neka trgovina?*
4. *Nemam kopiju. Gdje je mogu napraviti?* — порядок коротких слів (*je mogu*).
5. *Danas je trinaesti listopada.* — форма дати.

## Нові уроки: діалоги, «вставте слово», «скажіть уголос»

### A0.1

**Урок 4 — Прощання і ввічливість / Pozdravi i pristojnost** · граматика: polite · новий

*Після роботи / Poslije posla*

- Marija: *Ja idem. Vidimo se sutra!* — Я йду. Побачимося завтра!
- Taras: *Do sutra! Ugodna večer!* — До завтра! Гарного вечора!
- Marija: *Hvala, i tebi. Pozdravi obitelj!* — Дякую, і тобі. Передавай привіт родині!
- Taras: *Hoću. Bok!* — Обов’язково. Бувай!

*Перепрошую! / Ispričavam se!*

- Olena: *Ispričavam se, kasnim pet minuta.* — Перепрошую, я запізнююся на п’ять хвилин.
- Gospođa Horvat: *Nema problema. Sjednite.* — Нічого страшного. Сідайте.
- Olena: *Hvala Vam. Čestitam na novom poslu!* — Дякую вам. Вітаю з новою роботою!
- Gospođa Horvat: *Hvala! Sretno i Vama!* — Дякую! Успіхів і вам!

- Вставте слово: *Hvala ___, gospođo Horvat!* → **Vam** (хибні: ti, Vas, tebe)
- Скажіть уголос: *Sretno!* (Успіхів!); *Pozdravi obitelj!* (Передавай привіт родині!)

### A0.2

**Урок 8 — Де ви живете? / Gdje živite?** · граматика: place · новий

*Яка ваша адреса? / Koja je Vaša adresa?*

- Službenica: *Gdje živite?* — Де ви живете?
- Oleg: *Živim u Zagrebu, u Vukovarskoj ulici.* — Я живу в Загребі, на Вуковарській вулиці.
- Službenica: *Koji je kućni broj?* — Який номер будинку?
- Oleg: *Dvadeset dva, treći kat.* — Двадцять два, третій поверх.
- Službenica: *A poštanski broj?* — А поштовий індекс?
- Oleg: *Deset tisuća.* — Десять тисяч.

*Будинок чи квартира? / Kuća ili stan?*

- Ana: *Živiš li u kući ili u stanu?* — Ти живеш у будинку чи в квартирі?
- Oksana: *U stanu, u velikoj zgradi.* — У квартирі, у великому будинку.
- Ana: *Je li kvart miran?* — Район спокійний?
- Oksana: *Jest, i susjedi su dragi.* — Так, і сусіди приємні.

- Вставте слово: *Živim ___ Zagrebu.* → **u** (хибні: na, iz, od)
- Скажіть уголос: *Gdje živite?* (Де ви живете?); *Živim na drugom katu.* (Я живу на другому поверсі.)

**Урок 9 — Мови й національності / Jezici i narodnosti** · граматика: biti · новий

*Ти українка? / Jesi li Ukrajinka?*

- Petra: *Jesi li ti Ukrajinka?* — Ти українка?
- Olena: *Da, ja sam Ukrajinka. A ti si Hrvatica?* — Так, я українка. А ти хорватка?
- Petra: *Jesam. Govoriš li hrvatski?* — Так. Ти говориш хорватською?
- Olena: *Malo. Govorim ukrajinski i engleski.* — Трохи. Я говорю українською й англійською.

*Іноземці на курсі / Stranci na tečaju*

- Profesorica: *Koje jezike govorite?* — Якими мовами ви говорите?
- Andrij: *Ukrajinski, poljski i malo njemački.* — Українською, польською і трохи німецькою.
- Profesorica: *Odlično! A razumijete li talijanski?* — Чудово! А італійську ви розумієте?
- Andrij: *Ne razumijem, nažalost.* — На жаль, не розумію.

- Вставте слово: *Ja ___ Ukrajinka.* → **sam** (хибні: si, je, smo)
- Скажіть уголос: *Ja sam Ukrajinac.* (Я українець.); *Koje jezike govorite?* (Якими мовами ви говорите?)

### A0.3

**Урок 13 — Числа від 11 до 19 / Brojevi od 11 do 19** · граматика: numbers · новий

*Скільки вас? / Koliko vas je?*

- Konobar: *Dobra večer! Koliko vas je?* — Добрий вечір! Скільки вас?
- Marko: *Dvanaest. Imate li stol za dvanaest osoba?* — Дванадцять. У вас є стіл на дванадцять осіб?
- Konobar: *Imamo stol za četrnaest, na terasi.* — У нас є стіл на чотирнадцять, на терасі.
- Marko: *Odlično, hvala!* — Чудово, дякую!

*Який автобус? / Koji autobus?*

- Turistkinja: *Koji autobus ide u centar?* — Який автобус їде в центр?
- Gospodin: *Sedamnaest ili devetnaest.* — Сімнадцятий або дев’ятнадцятий.
- Turistkinja: *Koliko minuta do centra?* — Скільки хвилин до центру?
- Gospodin: *Otprilike petnaest minuta.* — Приблизно п’ятнадцять хвилин.

- Вставте слово: *Deset i pet je ___.* → **petnaest** (хибні: pedeset, pet, dvadeset pet)
- Скажіть уголос: *Imam osamnaest godina.* (Мені вісімнадцять років.); *Autobus broj jedanaest.* (Автобус номер одинадцять.)

**Урок 14 — До ста і номер телефону / Do sto i broj telefona** · граматика: numbers · новий

*Номер телефону / Broj telefona*

- Službenica: *Koji je Vaš broj telefona?* — Який ваш номер телефону?
- Iryna: *Nula devedeset jedan, šezdeset sedam, osamdeset dva, sedamdeset tri.* — Нуль дев’яносто один, шістдесят сім, вісімдесят два, сімдесят три.
- Službenica: *Možete li ponoviti polako?* — Можете повторити повільно?
- Iryna: *Naravno. Evo, ovdje piše.* — Звісно. Ось, тут написано.

*Скільки коштує? / Koliko košta?*

- Kupac: *Koliko košta ova jakna?* — Скільки коштує ця куртка?
- Prodavačica: *Devedeset eura.* — Дев’яносто євро.
- Kupac: *A ona plava?* — А он та синя?
- Prodavačica: *Sedamdeset pet. Danas je sve na popustu.* — Сімдесят п’ять. Сьогодні на все знижка.
- Kupac: *Uzimam plavu. Evo sto eura.* — Беру синю. Ось сто євро.

- Вставте слово: *Pedeset i deset je ___.* → **šezdeset** (хибні: šesnaest, šest, sedamdeset)
- Скажіть уголос: *Sto eura.* (Сто євро.); *Recite mi, molim, Vaš broj telefona.* (Скажіть, будь ласка, ваш номер телефону.)

### A0.4

**Урок 18 — Учора, сьогодні, завтра / Jučer, danas, sutra** · граматика: time · новий

*Коли зустрінемося? / Kada se vidimo?*

- Ana: *Imaš li vremena sutra poslijepodne?* — Маєш час завтра після обіду?
- Taras: *Sutra ne, radim do večeri. Prekosutra može.* — Завтра ні, працюю до вечора. Післязавтра можна.
- Ana: *Prekosutra je subota. Prijepodne ili poslijepodne?* — Післязавтра субота. До обіду чи після обіду?
- Taras: *Prijepodne, u deset.* — До обіду, о десятій.

*Мій тиждень / Moj tjedan*

- Marko: *Koliko dugo si u Hrvatskoj?* — Як довго ти в Хорватії?
- Iryna: *Tek tjedan dana.* — Лише тиждень.
- Marko: *I kakav ti je tjedan?* — І який у тебе тиждень?
- Iryna: *Pun! Jučer posao, danas tečaj, a sutra more!* — Насичений! Учора робота, сьогодні курс, а завтра — море!
- Marko: *A navečer?* — А ввечері?
- Iryna: *Navečer spavam!* — Увечері сплю!

- Вставте слово: *Danas je petak, a sutra je ___.* → **subota** (хибні: četvrtak, nedjelja, ponedjeljak)
- Скажіть уголос: *Jučer, danas, sutra.* (Учора, сьогодні, завтра.); *Vidimo se prekosutra!* (Побачимося післязавтра!)

**Урок 19 — Місяці й дати / Mjeseci i datumi** · граматика: time · новий

*Коли твій день народження? / Kada ti je rođendan?*

- Lana: *Kada ti je rođendan?* — Коли в тебе день народження?
- Oleg: *Dvadeset prvog ožujka. A tvoj?* — Двадцять першого березня. А твій?
- Lana: *Trećeg studenog.* — Третього листопада.
- Oleg: *Znači, u jesen. A koji je danas datum?* — Отже, восени. А яке сьогодні число?
- Lana: *Danas je trinaesti listopada.* — Сьогодні тринадцяте жовтня.

*Шкільний рік / Školska godina*

- Mama: *Kada počinje škola u Hrvatskoj?* — Коли в Хорватії починається школа?
- Učiteljica: *Početkom rujna, a završava u lipnju.* — На початку вересня, а закінчується в червні.
- Mama: *A zimski praznici?* — А зимові канікули?
- Učiteljica: *Od kraja prosinca do sredine siječnja.* — З кінця грудня до середини січня.

- Вставте слово: *Rođendan mi je u ___.* → **svibnju** (хибні: svibanj, svibnja, svibnjem)
- Скажіть уголос: *Rođendan mi je u svibnju.* (Мій день народження в травні.); *Danas je prvi travnja.* (Сьогодні перше квітня.)

### A0.5

**Урок 23 — Родичі й стосунки / Rodbina i veze** · граматика: imati · новий

*Родичі в Хорватії / Rodbina u Hrvatskoj*

- Ana: *Imaš li rodbinu u Hrvatskoj?* — У тебе є родичі в Хорватії?
- Oksana: *Imam. Moja teta i ujak žive u Rijeci.* — Так. Моя тітка й дядько живуть у Рієці.
- Ana: *Imaju li djecu?* — У них є діти?
- Oksana: *Imaju. Moj bratić ima dvadeset godina, a sestrična petnaest.* — Так. Моєму двоюрідному братові двадцять років, а двоюрідній сестрі п’ятнадцять.

*Ти одружений? / Jesi li oženjen?*

- Marko: *Jesi li oženjen?* — Ти одружений?
- Andrij: *Nisam, ali imam curu. A ti?* — Ні, але в мене є дівчина. А ти?
- Marko: *Ja sam oženjen i imam unuka!* — Я одружений, і в мене є онук!
- Andrij: *Unuka? Pa ti si mlad!* — Онука? Та ти ж молодий!

- Вставте слово: *Oni ___ dvoje djece.* → **imaju** (хибні: imam, imaš, ima)
- Скажіть уголос: *Imam dečka.* (У мене є хлопець.); *Moja sestra je udana.* (Моя сестра заміжня.)

### A0.6

**Урок 27 — Кімнати й техніка / Prostorije i aparati** · граматика: place · новий

*Огляд квартири / Razgledavanje stana*

- Agentica: *Ovo je hodnik. Lijevo je spavaća soba.* — Це коридор. Ліворуч — спальня.
- Iryna: *A gdje je zahod?* — А де туалет?
- Agentica: *Pored kupaonice. Kupaonica ima i perilicu.* — Поруч із ванною. У ванній є й пральна машина.
- Iryna: *Super! Ima li kuhinja pećnicu?* — Чудово! На кухні є духовка?
- Agentica: *Ima, i štednjak i hladnjak.* — Є, і плита, і холодильник.

*Будинок із садом / Kuća s vrtom*

- Baka: *Naša kuća ima vrt i dvorište.* — У нашого будинку є сад і подвір’я.
- Unuk: *Gdje je moja soba?* — Де моя кімната?
- Baka: *Gore, na katu, pored velikog ogledala.* — Нагорі, на поверсі, біля великого дзеркала.
- Unuk: *Super, vidim more!* — Супер, я бачу море!

- Вставте слово: *Perilica je ___ kupaonici.* → **u** (хибні: na, iz, do)
- Скажіть уголос: *Gdje je kupaonica?* (Де ванна кімната?); *Nemam pećnice.* (У мене немає духовки.)

### A0.7

**Урок 31 — Напої / Pića** · граматика: questions · новий

*Що будете пити? / Što želite piti?*

- Konobar: *Dobra večer! Što želite piti?* — Добрий вечір! Що будете пити?
- Oleg: *Jedno pivo, molim. Veliko.* — Одне пиво, будь ласка. Велике.
- Olga: *Za mene čašu bijelog vina.* — Мені келих білого вина.
- Konobar: *Može. Još nešto?* — Добре. Ще щось?
- Olga: *Bocu mineralne vode, molim.* — Пляшку мінеральної води, будь ласка.

*Чай чи кава? / Čaj ili kava?*

- Ana: *Želiš li čaj ili kavu?* — Хочеш чаю чи кави?
- Iryna: *Čaj, molim. Šalicu toplog čaja.* — Чай, будь ласка. Чашку гарячого чаю.
- Ana: *Sa šećerom?* — З цукром?
- Iryna: *Ne, bez šećera. A ti?* — Ні, без цукру. А ти?
- Ana: *Ja pijem limunadu s ledom.* — Я п’ю лимонад з льодом.

- Вставте слово: *___ želite piti?* → **Što** (хибні: Tko, Gdje, Kada)
- Скажіть уголос: *Čašu vode, molim.* (Склянку води, будь ласка.); *Ne pijem kavu.* (Я не п’ю каву.)

**Урок 32 — Вечеря / Večera** · граматика: adjectives · новий

*Що на вечерю? / Što je za večeru?*

- Sin: *Mama, što je za večeru?* — Мамо, що на вечерю?
- Mama: *Piletina s rižom i salatom.* — Курятина з рисом і салатом.
- Sin: *Opet piletina? Ima li pomfrita?* — Знову курятина? А картопля фрі є?
- Mama: *Nema. Ali ima kolača za desert!* — Немає. Зате є тістечка на десерт!

*Смачного! / Dobar tek!*

- Ana: *Dobar tek!* — Смачного!
- Taras: *Hvala! Meso je jako ukusno.* — Дякую! М’ясо дуже смачне.
- Ana: *To je svinjetina u umaku. Nije previše ljuto?* — Це свинина в соусі. Не надто гостро?
- Taras: *Nije, odlično je. Malo je slano, ali dobro.* — Ні, чудово. Трохи солоне, але добре.

- Вставте слово: *Meso je jako ___.* → **ukusno** (хибні: ukusan, ukusna, ukusni)
- Скажіть уголос: *Što je za večeru?* (Що на вечерю?); *Ovo je jako ukusno!* (Це дуже смачно!)

### A0.8

**Урок 36 — Скільки вам? / Koliko trebate?** · граматика: demonstratives · новий

*За прилавком / Za pultom*

- Prodavačica: *Izvolite?* — Слухаю вас?
- Olena: *Trideset deka ovog sira, molim.* — Триста грамів цього сиру, будь ласка.
- Prodavačica: *Može malo više?* — Можна трохи більше?
- Olena: *Može. I pola kile šunke.* — Можна. І півкіло шинки.
- Prodavačica: *Još nešto?* — Ще щось?
- Olena: *Ne, dosta je, hvala.* — Ні, досить, дякую.

*Список покупок / Popis za trgovinu*

- Taras: *Što trebamo?* — Що нам треба?
- Olena: *Litru mlijeka, paket tjestenine i šest jaja.* — Літр молока, пачку макаронів і шість яєць.
- Taras: *Koliko kruha?* — Скільки хліба?
- Olena: *Jedan. I puno voća za djecu!* — Одну хлібину. І багато фруктів для дітей!

- Вставте слово: *Pola kile ___ sira, molim.* → **ovog** (хибні: ovaj, ova, ovo)
- Скажіть уголос: *Litru mlijeka, molim.* (Літр молока, будь ласка.); *Malo više, molim.* (Трохи більше, будь ласка.)

**Урок 37 — Кольори / Boje** · граматика: adjectives · новий

*Яку сукню? / Koju haljinu?*

- Prodavačica: *Koju boju želite?* — Який колір бажаєте?
- Oksana: *Zelenu ili žutu.* — Зелену або жовту.
- Prodavačica: *Imamo zelenu, ali žute nema. Može ružičasta?* — Є зелена, а жовтої немає. Може, рожева?
- Oksana: *Ne, hvala. Zelena je lijepa.* — Ні, дякую. Зелена гарна.

*Шукаю куртку / Tražim jaknu*

- Andrij: *Imate li ovu jaknu u crnoj boji?* — У вас є ця куртка чорного кольору?
- Prodavač: *Nemamo crnu. Imamo sivu i smeđu.* — Чорної немає. Є сіра й коричнева.
- Andrij: *Siva je dobra. A bijele majice?* — Сіра підійде. А білі футболки?
- Prodavač: *Bijele su tamo, pored narančastih.* — Білі он там, біля помаранчевих.

- Вставте слово: *Želim ___ jaknu.* → **crnu** (хибні: crn, crna, crni)
- Скажіть уголос: *Moja omiljena boja je plava.* (Мій улюблений колір — синій.); *Imate li bijelu?* (У вас є біла?)

### A0.9

**Урок 41 — Місця в місті / Mjesta u gradu** · граматика: place · новий

*Що тут поруч? / Što je blizu?*

- Iryna: *Oprostite, je li blizu neka trgovina?* — Вибачте, тут поруч є якийсь магазин?
- Gospođa: *Jest, pored pošte, a pošta je preko puta banke.* — Так, біля пошти, а пошта навпроти банку.
- Iryna: *A bolnica?* — А лікарня?
- Gospođa: *Bolnica je daleko. Ali ljekarna je ovdje, iza ugla.* — Лікарня далеко. Але аптека тут, за рогом.

*Вихідні з дітьми / Vikend s djecom*

- Tata: *Idemo u park ili u kino?* — Підемо в парк чи в кіно?
- Kći: *U park! A onda u knjižnicu.* — У парк! А потім у бібліотеку.
- Tata: *Knjižnica nije otvorena nedjeljom.* — Бібліотека в неділю не працює.
- Kći: *Onda kafić i sladoled!* — Тоді кафе й морозиво!

- Вставте слово: *Pošta je ___ puta banke.* → **preko** (хибні: pored, iza, ispod)
- Скажіть уголос: *Gdje je bolnica?* (Де лікарня?); *Je li blizu neka banka?* (Тут поруч є банк?)

**Урок 42 — Як пройти? / Kako doći do…?** · граматика: word_order · новий

*Як дійти до вокзалу? / Kako do kolodvora?*

- Turist: *Oprostite, kako mogu doći do kolodvora?* — Вибачте, як мені дійти до вокзалу?
- Gospodin: *Idite ravno do semafora, pa skrenite desno.* — Ідіть прямо до світлофора, потім поверніть праворуч.
- Turist: *Je li to daleko?* — Це далеко?
- Gospodin: *Nije. Prijeđite most i tamo je.* — Ні. Перейдіть міст — і ви там.

*Пішки чи трамваєм? / Pješice ili tramvajem?*

- Oksana: *Idemo pješice ili tramvajem?* — Ідемо пішки чи трамваєм?
- Ivan: *Tramvajem, autom je gužva. Stanica je na raskrižju.* — Трамваєм, машиною — затор. Зупинка на перехресті.
- Oksana: *Gdje je pješački prijelaz?* — Де пішохідний перехід?
- Ivan: *Tamo, kod semafora. Pazi na bicikle!* — Он там, біля світлофора. Обережно, велосипеди!

- Вставте слово: *Gdje ___ stanica?* → **je** (хибні: sam, se, li)
- Скажіть уголос: *Kako mogu doći do centra?* (Як мені дійти до центру?); *Idite ravno.* (Ідіть прямо.)

### A0.10

**Урок 46 — Документи в MUP / U MUP-u** · граматика: questions · новий

*У черзі / U redu*

- Oleg: *Oprostite, je li ovo red za boravak?* — Вибачте, це черга щодо дозволу на проживання?
- Gospođa: *Jest. Uzmite broj na automatu.* — Так. Візьміть номерок в автоматі.
- Oleg: *Koliko dugo čekamo?* — Скільки ми чекаємо?
- Gospođa: *Oko sat vremena. Ja čekam od osam.* — Близько години. Я чекаю з восьмої.

*На віконці / Na šalteru*

- Službenica: *Sljedeći! Izvolite, Vaše dokumente.* — Наступний! Прошу ваші документи.
- Oleg: *Evo putovnice, fotografije i OIB-a.* — Ось паспорт, фотографія й OIB.
- Službenica: *Trebam i kopiju putovnice.* — Мені потрібна ще копія паспорта.
- Oleg: *Nemam kopiju. Gdje je mogu napraviti?* — У мене немає копії. Де її можна зробити?
- Službenica: *Preko puta, u knjižari.* — Навпроти, у книгарні.

- Вставте слово: *___ dugo čekamo?* → **Koliko** (хибні: Kada, Gdje, Tko)
- Скажіть уголос: *Gdje je red?* (Де черга?); *Evo moje putovnice.* (Ось мій паспорт.)

**Урок 47 — Не можу знайти гаманець / Ne mogu naći novčanik** · граматика: negation · новий

*Де мій гаманець? / Gdje je moj novčanik?*

- Taras: *Ne mogu naći novčanik!* — Не можу знайти гаманець!
- Olena: *Nije u torbi?* — Його немає в сумці?
- Taras: *Nije. Ni u jakni. Unutra su kartice i osobna iskaznica!* — Ні. І в куртці немає. А в ньому картки й посвідчення особи!
- Olena: *Idemo odmah u policiju.* — Ходімо одразу в поліцію.

*У поліції / U policiji*

- Policajac: *Izvolite, kako Vam mogu pomoći?* — Прошу, чим можу допомогти?
- Taras: *Nema mog novčanika. Želim to prijaviti.* — Мого гаманця немає. Хочу про це заявити.
- Policajac: *Kakav je novčanik?* — Який гаманець?
- Taras: *Smeđi, kožni. Unutra nema novca, samo dokumenti.* — Коричневий, шкіряний. Грошей там немає, тільки документи.
- Policajac: *Dobro. Ispunite ovaj obrazac.* — Добре. Заповніть цей бланк.

- Вставте слово: *Novčanik ___ u torbi.* → **nije** (хибні: ne, nema, nisam)
- Скажіть уголос: *Trebam pomoć policije.* (Мені потрібна допомога поліції.); *Nema moje putovnice.* (Мого паспорта немає.)

## Вправи на слова

| Урок | Тип | Завдання | Відповідь | Варіанти |
|---|---|---|---|---|
| 4 | multiple_choice | Що означає «nema problema»? | немає проблем | гарного вечора · запізнюватися · немає проблем · успіхів; щасти |
| 4 | multiple_choice | Що означає «čestitam»? | вітаю (з чимось) | вітаю (з чимось) · до завтра · і тобі (теж) · успіхів; щасти |
| 4 | multiple_choice | Як хорватською «побачимося»? | vidimo se | do sutra · sretno · čestitam · vidimo se |
| 4 | type_answer | Напишіть хорватською: «успіхів; щасти» | sretno |  |
| 4 | type_answer | Напишіть хорватською: «запізнюватися» | kasniti |  |
| 8 | multiple_choice | Що означає «poštanski broj»? | поштовий індекс | поштовий індекс · дорогий; милий, приємний · спокійний · район (міста) |
| 8 | multiple_choice | Що означає «susjed»? | сусід | дорогий; милий, приємний · сусід · тисяча · поштовий індекс |
| 8 | multiple_choice | Як хорватською «спокійний»? | miran | miran · susjed · zgrada · poštanski broj |
| 8 | type_answer | Напишіть хорватською: «будинок; дім» | kuća |  |
| 8 | type_answer | Напишіть хорватською: «поверх» | kat |  |
| 9 | multiple_choice | Що означає «Hrvatica»? | хорватка | хорватка · німецька (мова); німецький · викладачка; вчителька · розуміти |
| 9 | multiple_choice | Що означає «njemački»? | німецька (мова); німецький | українка · німецька (мова); німецький · хорватка · викладачка; вчителька |
| 9 | multiple_choice | Як хорватською «польська (мова); польський»? | poljski | Ukrajinka · poljski · talijanski · njemački |
| 9 | type_answer | Напишіть хорватською: «викладачка; вчителька» | profesorica |  |
| 9 | type_answer | Напишіть хорватською: «курс (навчальний / валютний)» | tečaj |  |
| 13 | multiple_choice | Що означає «otprilike»? | приблизно | дев'ятнадцять · сімнадцять · приблизно · вісімнадцять |
| 13 | multiple_choice | Що означає «osamnaest»? | вісімнадцять | одинадцять · п'ятнадцять · тринадцять · вісімнадцять |
| 13 | multiple_choice | Як хорватською «особа»? | osoba | dvanaest · četrnaest · osamnaest · osoba |
| 13 | type_answer | Напишіть хорватською: «чотирнадцять» | četrnaest |  |
| 13 | type_answer | Напишіть хорватською: «одинадцять» | jedanaest |  |
| 14 | multiple_choice | Що означає «telefon»? | телефон | номер телефону · шістдесят · писати · телефон |
| 14 | multiple_choice | Що означає «ponoviti»? | повторити | повторити · номер телефону · телефон · вісімдесят |
| 14 | multiple_choice | Як хорватською «сто»? | sto | telefon · broj telefona · pisati · sto |
| 14 | type_answer | Напишіть хорватською: «сімдесят» | sedamdeset |  |
| 14 | type_answer | Напишіть хорватською: «вісімдесят» | osamdeset |  |
| 18 | multiple_choice | Що означає «ponoć»? | північ (час) | ввечері · тиждень · вранці · північ (час) |
| 18 | multiple_choice | Що означає «prekosutra»? | післязавтра | після обіду; пополудні · полудень · вчора · післязавтра |
| 18 | multiple_choice | Як хорватською «ввечері»? | navečer | podne · navečer · tek · prekjučer |
| 18 | type_answer | Напишіть хорватською: «вчора» | jučer |  |
| 18 | type_answer | Напишіть хорватською: «тиждень» | tjedan |  |
| 19 | multiple_choice | Що означає «listopad»? | жовтень | квітень · канікули; свята · жовтень · березень |
| 19 | multiple_choice | Що означає «treći»? | третій | травень · лютий · грудень · третій |
| 19 | multiple_choice | Як хорватською «перший»? | prvi | datum · prvi · listopad · svibanj |
| 19 | type_answer | Напишіть хорватською: «червень» | lipanj |  |
| 19 | type_answer | Напишіть хорватською: «травень» | svibanj |  |
| 23 | multiple_choice | Що означає «mlad»? | молодий | родичі · хлопець (романтично) · онук · молодий |
| 23 | multiple_choice | Що означає «dečko»? | хлопець (романтично) | онук · двоюрідний брат · хлопець (романтично) · двоюрідна сестра |
| 23 | multiple_choice | Як хорватською «заміжня»? | udana | udana · mlad · rodbina · bratić |
| 23 | type_answer | Напишіть хорватською: «тітка» | teta |  |
| 23 | type_answer | Напишіть хорватською: «одружений (про чоловіка)» | oženjen |  |
| 27 | multiple_choice | Що означає «hodnik»? | коридор | туалет · дзеркало · духовка · коридор |
| 27 | multiple_choice | Що означає «hladnjak»? | холодильник | спальня · холодильник · плита (для готування) · коридор |
| 27 | multiple_choice | Як хорватською «спальня»? | spavaća soba | perilica · štednjak · spavaća soba · pećnica |
| 27 | type_answer | Напишіть хорватською: «туалет» | zahod |  |
| 27 | type_answer | Напишіть хорватською: «дзеркало» | ogledalo |  |
| 31 | multiple_choice | Що означає «čaša»? | склянка / келих | мінеральна вода · лід · склянка / келих · пиво |
| 31 | multiple_choice | Що означає «topao»? | теплий | мінеральна вода · теплий · лід · пиво |
| 31 | multiple_choice | Як хорватською «лід»? | led | topao · led · šećer · šalica |
| 31 | type_answer | Напишіть хорватською: «пляшка» | boca |  |
| 31 | type_answer | Напишіть хорватською: «вино» | vino |  |
| 32 | multiple_choice | Що означає «pomfrit»? | картопля фрі | смачний · картопля фрі · солоний · соус |
| 32 | multiple_choice | Що означає «večera»? | вечеря | свинина · тістечко / пиріг · соус · вечеря |
| 32 | multiple_choice | Як хорватською «соус»? | umak | pomfrit · umak · večera · opet |
| 32 | type_answer | Напишіть хорватською: «знову» | opet |  |
| 32 | type_answer | Напишіть хорватською: «рис» | riža |  |
| 36 | multiple_choice | Що означає «puno»? | багато | список · багато · шинка · більше |
| 36 | multiple_choice | Що означає «dosta»? | досить; достатньо | літр · половина · досить; достатньо · шинка |
| 36 | multiple_choice | Як хорватською «кілограм (розм.)»? | kila | šunka · više · kila · pola |
| 36 | type_answer | Напишіть хорватською: «літр» | litra |  |
| 36 | type_answer | Напишіть хорватською: «шинка» | šunka |  |
| 37 | multiple_choice | Що означає «ljubičast»? | фіолетовий | фіолетовий · білий · зелений · помаранчевий |
| 37 | multiple_choice | Що означає «boja»? | колір | колір · зелений · жовтий · чорний |
| 37 | multiple_choice | Як хорватською «чорний»? | crn | žut · siv · omiljen · crn |
| 37 | type_answer | Напишіть хорватською: «зелений» | zelen |  |
| 37 | type_answer | Напишіть хорватською: «коричневий» | smeđ |  |
| 41 | multiple_choice | Що означає «park»? | парк | морозиво · лікарня · парк · кінотеатр |
| 41 | multiple_choice | Що означає «sladoled»? | морозиво | банк · кафе / кав'ярня · бібліотека · морозиво |
| 41 | multiple_choice | Як хорватською «кінотеатр»? | kino | banka · kino · knjižnica · park |
| 41 | type_answer | Напишіть хорватською: «ріг (вулиці); кут» | ugao |  |
| 41 | type_answer | Напишіть хорватською: «лікарня» | bolnica |  |
| 42 | multiple_choice | Що означає «semafor»? | світлофор | повернути (ліворуч, праворуч) · світлофор · затор; тиснява · перейти |
| 42 | multiple_choice | Що означає «raskrižje»? | перехрестя | велосипед · перейти · перехрестя · затор; тиснява |
| 42 | multiple_choice | Як хорватською «міст»? | most | raskrižje · most · semafor · pješački prijelaz |
| 42 | type_answer | Напишіть хорватською: «перейти» | prijeći |  |
| 42 | type_answer | Напишіть хорватською: «автомобіль» | auto |  |
| 46 | multiple_choice | Що означає «dokument»? | документ | Ідентифікаційний номер (OIB) · документ · чекати · черга |
| 46 | multiple_choice | Що означає «čekati»? | чекати | чекати · МВС / Міністерство внутрішніх справ · черга · Ідентифікаційний номер (OIB) |
| 46 | multiple_choice | Як хорватською «перебування; проживання»? | boravak | red · boravak · šalter · čekati |
| 46 | type_answer | Напишіть хорватською: «копія» | kopija |  |
| 46 | type_answer | Напишіть хорватською: «віконце (в установі)» | šalter |  |
| 47 | multiple_choice | Що означає «prijaviti»? | зареєструвати; повідомити | всередині / всередину · гаманець · посвідчення особи · зареєструвати; повідомити |
| 47 | multiple_choice | Що означає «naći»? | знайти | знайти · одразу · зареєструвати; повідомити · поліція |
| 47 | multiple_choice | Як хорватською «поліція»? | policija | kožni · odmah · osobna iskaznica · policija |
| 47 | type_answer | Напишіть хорватською: «шкіряний» | kožni |  |
| 47 | type_answer | Напишіть хорватською: «одразу» | odmah |  |