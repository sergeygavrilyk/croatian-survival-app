# Доповнення A1: +40 уроків (curriculum_a1_v2)

Дата: 2026-10-13. Запит власника: «A1 — менше половини. Щоб дійти до ~1000 слів, треба ще приблизно 40 уроків A1. Щоб SQL пройшов нормально, розбий нову партію на 4 SQL-запити».

## Файли

- SQL — чотири частини по 10 уроків (кожна ~130 КБ, SQL Editor приймає):
  1. `supabase/data_fixes/20261013_curriculum_a1_v2_part1.sql`
  2. `supabase/data_fixes/20261013_curriculum_a1_v2_part2.sql`
  3. `supabase/data_fixes/20261013_curriculum_a1_v2_part3.sql`
  4. `supabase/data_fixes/20261013_curriculum_a1_v2_part4.sql`
- тест: `supabase/tests/curriculum_a1_v2.test.sql` (запускати після всіх чотирьох частин);
- дані: `scripts/curriculum_a1_v2_data.py`, генератор: `scripts/gen_curriculum_a1_v2.py` (`--review` — таблиця вправ, `--stats` — підрахунок слів), знімок перекладів робочої бази: `scripts/curriculum_a1_v2_snapshot.json`.

Потрібна програма A1 v1 (`20261013_curriculum_a1_v1_part1.sql` і `_part2.sql`). Частини v2 незалежні одна від одної, але запускати краще по черзі 1 → 4. Повторний запуск безпечний.

## Що додано

| Що | Скільки |
|---|---|
| Нові уроки | 40: по 4 у кожен модуль (місця 6–9), ~12 хв кожен |
| Уроків A1 разом | 89 (8–9 у модулі) |
| Діалоги | 80 (по 2 в уроці), 413 реплік |
| Вправи | 480 (по 12 в уроці, усі 6 типів) |
| Нові слова в уроках | 560 (по 14 в уроці, жодне не повторює слова уроків A0 і A1 v1) |
| Нові слова у словнику | 305 (решта 255 — уже були в базі, звірено 2026-10-13) |
| Виправлення словника | 17 перекладів + 3 написання леми (стара версія — у `content_versions`) |

**Обсяг слів A1 тепер:** в уроках A1 **994 різні слова, яких немає в уроках A0** (було 434). План ТЗ §14 — ~1000. ✅

Назви всіх уроків A1 перенумеровано підряд («Урок 1» … «Урок 89»), старі назви — у `content_versions`. Пройдені уроки лишаються пройденими: прогрес прив’язаний до уроку, а не до номера.

## Нові уроки за модулями

| № | Модуль | Урок | Граматика | Частина SQL |
|---|---|---|---|---|
| 6 | A1.1 Повсякденне життя | Сон і відпочинок / *San i odmor* | теперішній час | 1 |
| 7 | A1.1 Повсякденне життя | З дитиною вдома / *S djetetom kod kuće* | наказовий спосіб | 1 |
| 8 | A1.1 Повсякденне життя | Домашній улюбленець / *Kućni ljubimac* | знахідний відмінок | 1 |
| 9 | A1.1 Повсякденне життя | Мій тиждень / *Moj tjedan* | модальні дієслова | 1 |
| 15 | A1.2 Їжа й ресторани | Що на сніданок? / *Što za doručak?* | знахідний відмінок | 1 |
| 16 | A1.2 Їжа й ресторани | Готуємо суп / *Kuhamo juhu* | наказовий спосіб | 1 |
| 17 | A1.2 Їжа й ресторани | У м’ясника й на рибному ринку / *U mesnici i ribarnici* | родовий відмінок | 1 |
| 18 | A1.2 Їжа й ресторани | Обід на роботі / *Gablec i marenda* | питання | 1 |
| 24 | A1.3 Покупки | Зимовий одяг / *Zimska odjeća* | ступені порівняння | 1 |
| 25 | A1.3 Покупки | Меблі для квартири / *Namještaj za stan* | місцевий відмінок | 1 |
| 26 | A1.3 Покупки | Магазин електроніки / *Trgovina elektronike* | питання | 2 |
| 27 | A1.3 Покупки | Покупки в інтернеті / *Kupnja preko interneta* | заперечення | 2 |
| 33 | A1.4 Транспорт | Велосипед і самокат / *Bicikl i romobil* | місцевий відмінок | 2 |
| 34 | A1.4 Транспорт | На автомагістралі / *Na autocesti* | родовий відмінок | 2 |
| 35 | A1.4 Транспорт | В автосервісі / *Na servisu* | модальні дієслова | 2 |
| 36 | A1.4 Транспорт | Міжміський автобус / *Međugradski autobus* | присвійні займенники | 2 |
| 41 | A1.5 Житло | Переїзд / *Selidba* | сполучники | 2 |
| 42 | A1.5 Житло | Правила будинку / *Kućni red* | заперечення | 2 |
| 43 | A1.5 Житло | Опалення й холод / *Grijanje i hladnoća* | правильні дієслова | 2 |
| 44 | A1.5 Житло | Дрібний ремонт / *Mali popravci* | наказовий спосіб | 2 |
| 50 | A1.6 Робота | Професії / *Zanimanja* | теперішній час | 3 |
| 51 | A1.6 Робота | Шукаю роботу / *Tražim posao* | питання | 3 |
| 52 | A1.6 Робота | Перший робочий день / *Prvi radni dan* | модальні дієслова | 3 |
| 53 | A1.6 Робота | В офісі / *U uredu* | правильні дієслова | 3 |
| 59 | A1.7 Здоров’я | Травма / *Ozljeda* | неправильні дієслова | 3 |
| 60 | A1.7 Здоров’я | Аналізи й обстеження / *Pretrage i nalazi* | родовий відмінок | 3 |
| 61 | A1.7 Здоров’я | Здоровий спосіб життя / *Zdrav život* | ступені порівняння | 3 |
| 62 | A1.7 Здоров’я | У педіатра / *Kod pedijatra* | наказовий спосіб | 3 |
| 68 | A1.8 Друзі й вільний час | Кохання й стосунки / *Ljubav i veze* | присвійні займенники | 3 |
| 69 | A1.8 Друзі й вільний час | Спорт і матчі / *Sport i utakmice* | теперішній час | 3 |
| 70 | A1.8 Друзі й вільний час | Театр і концерти / *Kazalište i koncerti* | місцевий відмінок | 4 |
| 71 | A1.8 Друзі й вільний час | Соцмережі / *Društvene mreže* | сполучники | 4 |
| 77 | A1.9 Хорватія | Хорватська кухня / *Hrvatska kuhinja* | знахідний відмінок | 4 |
| 78 | A1.9 Хорватія | Національні парки / *Nacionalni parkovi* | місцевий відмінок | 4 |
| 79 | A1.9 Хорватія | Старе місто / *Stari grad* | ступені порівняння | 4 |
| 80 | A1.9 Хорватія | Свята й неробочі дні / *Blagdani i neradni dani* | присвійні займенники | 4 |
| 86 | A1.10 Підсумок A1 | Продовження перебування / *Produljenje boravka* | родовий відмінок | 4 |
| 87 | A1.10 Підсумок A1 | Навчання й мовні курси / *Učenje jezika* | неправильні дієслова | 4 |
| 88 | A1.10 Підсумок A1 | Надзвичайні ситуації / *Hitne situacije* | заперечення | 4 |
| 89 | A1.10 Підсумок A1 | Нове життя в Хорватії / *Novi život u Hrvatskoj* | сполучники | 4 |

Граматика — лише теми A1 (теперішній час, відмінки, наказовий спосіб…). Минулого й майбутнього часу немає: це A2. Тому в діалогах майбутнє передано теперішнім часом («Sutra idemo…»), як це звично в розмовній хорватській.

## Виправлення словника

| Слово | Було | Стало |
|---|---|---|
| ekran | екрані / дисплей | екран; дисплей |
| kvačilo | Зчеплення | зчеплення |
| povodac | Повідець | повідець |
| obiteljski liječnik | Сімейний лікар | сімейний лікар |
| spoj | з'єднання | побачення; з'єднання |
| mir | мир | спокій; мир |
| preuzeti | завантажити; взяти | забрати; отримати; завантажити |
| peći | випікати, смажити | пекти; запікати |
| prijaviti se | зареєструватися | зареєструватися; подати заявку |
| točan | правильний / точний | точний; пунктуальний |
| mijenjati | змінювати | міняти; змінювати |
| miješati | мішати | мішати; перемішувати |
| obveza | зобов'язання | обов'язок; справа |
| izgubiti | загубити / втратити | загубити; втратити; програти |
| prijevoz | транспорт | транспорт; перевезення |
| boravište | тимчасове перебування / реєстрація | місце тимчасового проживання |
| prebivalište | постійне місце проживання / прописка | місце постійного проживання |
| kvačilo (лема) | Kvačilo | kvačilo |
| povodac (лема) | Povodac | povodac |
| obiteljski liječnik (лема) | Obiteljski liječnik | obiteljski liječnik |

## Мовна перевірка (AI)

Під час перевірки виправлено: *Uključi se* → *Uključuje se* (про колонку); *Je.* → *Jest.*; вік палацу Діоклетіана (не «майже дві тисячі», а «близько сімнадцяти століть»); порада при землетрусі *Stani ispod stola* → *Sakrij se ispod stola*.

Що варто глянути носію в першу чергу:

1. Регіональні слова: *gablec* (Загреб) і *marenda* (Далмація) — обидва подано як «обід на роботі»; чи природно це пояснено?
2. *Prvo ga kupamo, a onda ga presvuci* (урок «З дитиною вдома») — змішано «ми» і наказовий спосіб; чи звучить природно?
3. *Rana nije duboka, ali krv ne staje* — чи не краще *krv ne prestaje*?
4. *Papiri traju dugo* (про бюрократію) — розмовно; чи зрозуміло?
5. *Za Božić pečemo fritule* (приклад) — фрітуле смажать, але кажуть і «peći fritule»; лишити?
6. Факти: Dan državnosti — 30 травня; сирени перевіряють щопершої суботи місяця; у Хорватії 8 національних парків; мури в Стоні довші за дубровницькі.

## Уроки: діалоги, «вставте слово», «складіть», «скажіть уголос»

### Урок 6 — Сон і відпочинок / San i odmor (A1.1, теперішній час)

Слова: *san*, *sanjati*, *jastuk*, *pokrivač*, *plahta*, *budilica*, *zvoniti*, *drijemati*, *nesanica*, *hrkati*, *zijevati*, *leći*, *odmoran*, *tišina*

*Погана ніч / Loša noć*

- Marija: *Izgledaš umorno. Zašto stalno zijevaš?* — Ти виглядаєш утомленою. Чому ти весь час позіхаєш?
- Olena: *Imam nesanicu. Ne mogu zaspati prije dva sata.* — У мене безсоння. Не можу заснути до другої години.
- Marija: *A što radiš kad ležiš u krevetu?* — А що ти робиш, коли лежиш у ліжку?
- Olena: *Gledam mobitel. A muž glasno hrče.* — Дивлюся в телефон. А чоловік голосно хропе.
- Marija: *Lezi ranije i ostavi mobitel u kuhinji.* — Лягай раніше і залишай телефон на кухні.

*Субота вранці / Subota ujutro*

- Taras: *Budilica zvoni! Ustaješ li?* — Будильник дзвонить! Ти встаєш?
- Ana: *Ne, danas je subota. Još malo drijemam.* — Ні, сьогодні субота. Я ще трохи подрімаю.
- Taras: *Sanjaš li često?* — Тобі часто сняться сни?
- Ana: *Da, svaku noć. Najbolje spavam u tišini.* — Так, щоночі. Найкраще я сплю в тиші.
- Taras: *Dobro, idem po kruh. Spavaj!* — Добре, я піду по хліб. Спи!
- Ana: *Hvala! Kad sam odmorna, imam više energije.* — Дякую! Коли я відпочила, у мене більше енергії.

- Вставте слово: *Moj muž glasno ___.* → **hrče** (хибні: hrčem, hrčeš, hrčemo)
- Складіть: «Мені потрібна нова подушка.» → *Trebam novi jastuk.*
- Складіть: «Будильник дзвонить о шостій.» → *Budilica zvoni u šest.*
- Скажіть уголос: *Dobar san je jako važan.* (Добрий сон дуже важливий.); *Trebam novi pokrivač i plahtu.* (Мені потрібні нова ковдра й простирадло.)

### Урок 7 — З дитиною вдома / S djetetom kod kuće (A1.1, наказовий спосіб)

Слова: *igračka*, *igralište*, *ljuljačka*, *tobogan*, *kupati*, *bajka*, *crtić*, *dječja kolica*, *presvući*, *plakati*, *smijati se*, *pijesak*, *dadilja*, *uspavati*

*На майданчику / Na igralištu*

- Olena: *Sofija, pazi! Ne trči kod ljuljačke.* — Софіє, обережно! Не бігай біля гойдалки.
- Sofija: *Mama, mogu li na tobogan?* — Мамо, можна мені на гірку?
- Olena: *Možeš. Ali prvo obuci jaknu.* — Можна. Але спершу вдягни куртку.
- Sofija: *Mama, u cipelama imam pijesak!* — Мамо, в мене в черевиках пісок!
- Olena: *Nema veze. Igraj se još pet minuta.* — Нічого страшного. Пограйся ще п’ять хвилин.

*Вечір удома / Večer kod kuće*

- Taras: *Mali plače. Što mu je?* — Малий плаче. Що з ним?
- Olena: *Umoran je. Prvo ga kupamo, a onda ga presvuci.* — Він утомився. Спочатку його скупаємо, а потім перевдягни його.
- Taras: *Može li gledati crtić prije spavanja?* — Можна йому подивитися мультик перед сном?
- Olena: *Ne, čitaj mu bajku. Tako ga lakše uspavaš.* — Ні, почитай йому казку. Так його легше приспати.
- Taras: *Dobro. Gle, već se smije!* — Добре. Дивись, він уже сміється!

- Вставте слово: *Molim te, ___ dijete, mokro je.* → **presvuci** (хибні: presvući, presvučeš, presvlačim)
- Складіть: «Почитай йому казку.» → *Čitaj mu bajku.*
- Складіть: «Няня приходить о восьмій.» → *Dadilja dolazi u osam.*
- Скажіть уголос: *Ne plači, sve je u redu.* (Не плач, усе добре.); *Stavi igračke u dječja kolica.* (Поклади іграшки у візочок.)

### Урок 8 — Домашній улюбленець / Kućni ljubimac (A1.1, знахідний відмінок)

Слова: *kućni ljubimac*, *mačka*, *hraniti*, *veterinar*, *povodac*, *zdjelica*, *dlaka*, *šapa*, *rep*, *lajati*, *granule*, *štene*, *mačić*, *cijepiti*

*У ветеринара / Kod veterinara*

- Veterinarka: *Dobar dan. Koga imamo danas?* — Добрий день. Кого ми маємо сьогодні?
- Andrij: *Ovo je Max, naše štene. Ima tri mjeseca.* — Це Макс, наше цуценя. Йому три місяці.
- Veterinarka: *Danas ga cijepimo. Držite ga, molim.* — Сьогодні ми його щепимо. Потримайте його, будь ласка.
- Andrij: *Stalno liže šapu. Je li to problem?* — Він постійно лиже лапу. Це проблема?
- Veterinarka: *Da vidimo. Ne, šapa je u redu.* — Подивимося. Ні, з лапою все гаразд.

*Нове кошеня / Novi mačić*

- Ana: *Imaš li kućnog ljubimca?* — У тебе є домашній улюбленець?
- Oksana: *Imam mačića. Djeca ga jako vole.* — У мене є кошеня. Діти його дуже люблять.
- Ana: *Što jede?* — Що він їсть?
- Oksana: *Jede granule i malo mesa. Vodu ima u zdjelici.* — Їсть сухий корм і трохи м’яса. Вода в нього в мисочці.
- Ana: *A dlaka po kauču?* — А шерсть на дивані?
- Oksana: *Da, usisavam svaki dan!* — Так, пилососю щодня!

- Вставте слово: *Svako jutro hranim ___.* → **mačku** (хибні: mačka, mački, mačke)
- Складіть: «Пес гавкає на сусіда.» → *Pas laje na susjeda.*
- Складіть: «Візьми повідець і мисочку.» → *Uzmi povodac i zdjelicu.*
- Скажіть уголос: *Moj pas maše repom.* (Мій пес махає хвостом.); *Kada treba cijepiti mačića?* (Коли треба щепити кошеня?)

### Урок 9 — Мій тиждень / Moj tjedan (A1.1, модальні дієслова)

Слова: *raspored*, *obveza*, *kalendar*, *podsjetnik*, *zaboraviti*, *sjetiti se*, *dogovoriti se*, *otkazati*, *odgoditi*, *planirati*, *plan*, *zapisati*, *dvaput*, *tjedno*

*Коли ти вільний? / Kada si slobodan?*

- Ivan: *Možemo li se naći ovaj tjedan?* — Можемо зустрітися цього тижня?
- Taras: *Moram pogledati raspored. Imam puno obveza.* — Мушу подивитися розклад. У мене багато справ.
- Ivan: *Može u četvrtak navečer?* — Можна в четвер увечері?
- Taras: *Ne mogu, četvrtkom imam tečaj. Dvaput tjedno.* — Не можу, по четвергах у мене курси. Двічі на тиждень.
- Ivan: *Dobro, onda se dogovorimo za subotu.* — Добре, тоді домовмося на суботу.

*Нагадування / Podsjetnik*

- Olena: *Joj, ne mogu se sjetiti kada je termin kod zubara.* — Ой, не можу згадати, коли прийом у стоматолога.
- Marija: *Pogledaj u kalendar u mobitelu.* — Подивися в календар у телефоні.
- Olena: *Nije tamo. Uvijek zaboravim zapisati.* — Там немає. Я завжди забуваю записати.
- Marija: *Nazovi ordinaciju. Termin možeš odgoditi ili otkazati.* — Подзвони в кабінет. Прийом можна перенести або скасувати.
- Olena: *Dobra ideja. I odmah stavljam podsjetnik!* — Гарна ідея. І одразу ставлю нагадування!

- Вставте слово: *Ja ne ___ doći u četvrtak.* → **mogu** (хибні: može, možemo, možeš)
- Складіть: «Мушу подивитися розклад.» → *Moram pogledati raspored.*
- Складіть: «Я тренуюся двічі на тиждень.» → *Treniram dvaput tjedno.*
- Скажіть уголос: *Koji je tvoj plan za vikend?* (Який у тебе план на вихідні?); *Želim planirati tjedan.* (Я хочу спланувати тиждень.)

### Урок 15 — Що на сніданок? / Što za doručak? (A1.2, знахідний відмінок)

Слова: *maslac*, *med*, *pekmez*, *pahuljice*, *kobasica*, *salama*, *kajgana*, *tost*, *keks*, *kakao*, *vrhnje*, *namaz*, *krafna*, *integralni*

*Сніданок удома / Doručak kod kuće*

- Mama: *Što želiš za doručak? Pahuljice ili kajganu?* — Що хочеш на сніданок? Пластівці чи яєчню?
- Danilo: *Kajganu i tost, molim.* — Яєчню й тост, будь ласка.
- Mama: *Tost s maslacem ili s pekmezom?* — Тост з маслом чи з джемом?
- Danilo: *S medom! I topli kakao.* — З медом! І гаряче какао.
- Mama: *Evo. Jedi polako.* — Ось. Їж повільно.

*У пекарні / U pekari*

- Prodavačica: *Izvolite?* — Прошу?
- Oksana: *Jedan integralni kruh i dvije krafne.* — Одну цільнозернову хлібину і два пончики.
- Prodavačica: *Krafne s čokoladom ili s marmeladom?* — Пончики з шоколадом чи з мармеладом?
- Oksana: *S čokoladom. Imate li i neki slani namaz?* — З шоколадом. А у вас є якась солона намазка?
- Prodavačica: *Imamo namaz od sira i salamu.* — Є сирна намазка і салямі.

- Вставте слово: *Za doručak jedem ___.* → **kajganu** (хибні: kajgana, kajgani, kajganom)
- Складіть: «Я п’ю каву з вершками.» → *Pijem kavu s vrhnjem.*
- Складіть: «Діти їдять пластівці з молоком.» → *Djeca jedu pahuljice s mlijekom.*
- Скажіть уголос: *Kupi, molim te, kobasice i kekse.* (Купи, будь ласка, сосиски й печиво.); *Ne jedem slatko za doručak.* (Я не їм солодкого на сніданок.)

### Урок 16 — Готуємо суп / Kuhamo juhu (A1.2, наказовий спосіб)

Слова: *lonac*, *tava*, *rezati*, *miješati*, *pržiti*, *peći*, *oguliti*, *mrkva*, *kupus*, *grah*, *zagrijati*, *dodati*, *posoliti*, *poklopac*

*Бабусин рецепт / Bakin recept*

- Baka: *Prvo oguli mrkvu i krumpir.* — Спочатку почисть моркву й картоплю.
- Ivana: *Gotovo. Što sada?* — Готово. Що тепер?
- Baka: *Reži ih na male komade i stavi u lonac.* — Наріж їх маленькими шматками й поклади в каструлю.
- Ivana: *Trebam li dodati grah?* — Мені додати квасолю?
- Baka: *Da. Kuhaj pola sata, miješaj i stavi poklopac.* — Так. Вари пів години, помішуй і накрий кришкою.
- Ivana: *I posolim na kraju, zar ne?* — І посолю наприкінці, так?

*Вечеря на сковороді / Večera u tavi*

- Taras: *Što danas kuhamo?* — Що сьогодні готуємо?
- Olena: *Pržimo kupus s lukom u tavi.* — Смажимо капусту з цибулею на сковороді.
- Taras: *A meso?* — А м’ясо?
- Olena: *Meso pečemo u pećnici. Zagrij je na dvjesto stupnjeva.* — М’ясо запікаємо в духовці. Розігрій її до двохсот градусів.
- Taras: *Dobro. Već je vruće!* — Добре. Уже гаряче!

- Вставте слово: *___ mrkvu na male komade.* → **Reži** (хибні: Rezati, Režem, Reže)
- Складіть: «Спочатку почисть картоплю.» → *Prvo oguli krumpir.*
- Складіть: «Посоли суп наприкінці.» → *Posoli juhu na kraju.*
- Скажіть уголос: *Promiješaj i stavi poklopac.* (Перемішай і накрий кришкою.); *Zagrij juhu, molim te.* (Розігрій суп, будь ласка.)

### Урок 17 — У м’ясника й на рибному ринку / U mesnici i ribarnici (A1.2, родовий відмінок)

Слова: *mesnica*, *ribarnica*, *govedina*, *janjetina*, *puretina*, *mljeveno meso*, *odrezak*, *lignja*, *srdela*, *dagnja*, *kost*, *file*, *očistiti*, *plodovi mora*

*У м’ясника / U mesnici*

- Mesar: *Dobar dan, izvolite.* — Добрий день, прошу.
- Olena: *Trebam pola kile mljevenog mesa.* — Мені потрібно пів кілограма фаршу.
- Mesar: *Govedine ili svinjetine?* — Яловичого чи свинячого?
- Olena: *Govedine. I dva odreska od puretine, molim.* — Яловичого. І дві відбивні з індички, будь ласка.
- Mesar: *Još nešto? Danas imamo i janjetinu.* — Ще щось? Сьогодні в нас є й баранина.
- Olena: *Ne, hvala. To je sve.* — Ні, дякую. Це все.

*На рибному ринку / U ribarnici*

- Taras: *Koliko košta kilogram srdela?* — Скільки коштує кілограм сардин?
- Prodavač: *Pet eura. Svježe su, od jutros.* — П’ять євро. Свіжі, з самого ранку.
- Taras: *Možete li ih očistiti?* — Можете їх почистити?
- Prodavač: *Naravno. Želite li i malo lignji ili dagnji?* — Звісно. Хочете ще трохи кальмарів чи мідій?
- Taras: *Ne, žena ne voli plodove mora. Ali uzimam file bez kostiju.* — Ні, дружина не любить морепродукти. Але візьму філе без кісток.

- Вставте слово: *Trebam kilogram ___.* → **govedine** (хибні: govedina, govedinu, govedini)
- Складіть: «Мені потрібно пів кілограма фаршу.» → *Trebam pola kile mljevenog mesa.*
- Складіть: «Ця риба без кісток.» → *Ova riba je bez kostiju.*
- Скажіть уголос: *Koliko košta kilogram lignji?* (Скільки коштує кілограм кальмарів?); *Gdje je ovdje mesnica?* (Де тут м’ясна крамниця?)

### Урок 18 — Обід на роботі / Gablec i marenda (A1.2, питання)

Слова: *gablec*, *marenda*, *menza*, *varivo*, *dnevni meni*, *porcija*, *prilog*, *pečen*, *kuhan*, *pohan*, *pire*, *mahune*, *pladanj*, *grašak*

*У їдальні / U menzi*

- Kuharica: *Izvolite, što želite?* — Прошу, що бажаєте?
- Andrij: *Što je danas dnevni meni?* — Що сьогодні в денному меню?
- Kuharica: *Pohana piletina ili varivo od mahuna.* — Курка в паніровці або рагу зі стручкової квасолі.
- Andrij: *Piletinu, molim. Koji je prilog?* — Курку, будь ласка. Який гарнір?
- Kuharica: *Pire ili kuhani krumpir. Uzmite pladanj.* — Пюре або варена картопля. Візьміть тацю.
- Andrij: *Pire, molim. Koliko to košta?* — Пюре, будь ласка. Скільки це коштує?

*Перерва на обід / Pauza za gablec*

- Ivan: *Kamo ideš na gablec?* — Куди ти йдеш обідати?
- Taras: *Što je gablec?* — Що таке «габлец»?
- Ivan: *U Zagrebu tako zovemo topli obrok na poslu. U Dalmaciji je to marenda.* — У Загребі так називаємо гарячу їжу на роботі. У Далмації це «маренда».
- Taras: *Zanimljivo! Gdje jedemo?* — Цікаво! Де поїмо?
- Ivan: *Ovdje blizu. Imaju pečenu piletinu s graškom.* — Тут поруч. У них є запечена курка з горошком.

- Вставте слово: *___ košta jedna porcija?* → **Koliko** (хибні: Tko, Kamo, Čiji)
- Складіть: «Який сьогодні гарнір?» → *Koji je danas prilog?*
- Складіть: «Візьміть тацю, будь ласка.» → *Uzmite pladanj, molim.*
- Скажіть уголос: *Jednu porciju variva, molim.* (Одну порцію рагу, будь ласка.); *Gdje je ovdje menza?* (Де тут їдальня?)

### Урок 24 — Зимовий одяг / Zimska odjeća (A1.3, ступені порівняння)

Слова: *kaput*, *šal*, *kapa*, *rukavice*, *čizme*, *džemper*, *čarape*, *tenisice*, *pidžama*, *debeo*, *tanak*, *vuna*, *nepromočiv*, *suknja*

*Що вдягти? / Što obući?*

- Ana: *Sutra je minus pet. Obuci kaput, ne jaknu!* — Завтра мінус п’ять. Вдягни пальто, а не куртку!
- Olena: *Kaput je topliji, ali jakna je udobnija.* — Пальто тепліше, але куртка зручніша.
- Ana: *Onda jaknu i debeli džemper. I kapu i šal!* — Тоді куртку й товстий светр. І шапку, і шарф!
- Olena: *A rukavice? Gdje su mi rukavice?* — А рукавички? Де мої рукавички?
- Ana: *U ladici, pored čarapa.* — У шухляді, біля шкарпеток.

*Купуємо чоботи / Kupujemo čizme*

- Prodavač: *Trebate li pomoć?* — Вам допомогти?
- Taras: *Tražim nepromočive čizme za kćer.* — Шукаю непромокальні чоботи для доньки.
- Prodavač: *Ove su najbolje. A ove su jeftinije, ali tanje.* — Ці найкращі. А ці дешевші, але тонші.
- Taras: *Uzimam bolje. I jednu pidžamu od pamuka.* — Беру кращі. І одну бавовняну піжаму.
- Prodavač: *Pidžame su lijevo, kod suknji.* — Піжами ліворуч, біля спідниць.

- Вставте слово: *Kaput je ___ od jakne.* → **topliji** (хибні: topao, najtopliji, toplo)
- Складіть: «Цей светр з вовни.» → *Ovaj džemper je od vune.*
- Складіть: «Кросівки зручніші за чоботи.» → *Tenisice su udobnije od čizama.*
- Скажіть уголос: *Trebam toplu kapu i šal.* (Мені потрібні тепла шапка й шарф.); *Ova suknja je kraća od one.* (Ця спідниця коротша за ту.)

### Урок 25 — Меблі для квартири / Namještaj za stan (A1.3, місцевий відмінок)

Слова: *madrac*, *zavjesa*, *posteljina*, *ladica*, *komoda*, *vješalica*, *stolić*, *naslonjač*, *sklopiti*, *vijak*, *montirati*, *dostaviti*, *širok*, *uzak*

*У меблевому магазині / U trgovini namještajem*

- Prodavačica: *Izvolite, što tražite?* — Прошу, що шукаєте?
- Oksana: *Trebamo madrac i komodu za spavaću sobu.* — Нам потрібні матрац і комод для спальні.
- Prodavačica: *Kolika je soba? Ova komoda je široka, a ona je uska.* — Яка у вас кімната? Цей комод широкий, а той вузький.
- Oksana: *Soba je mala. Uzimamo usku. Možete li je dostaviti?* — Кімната маленька. Беремо вузький. Можете його доставити?
- Prodavačica: *Da, u subotu. Za deset eura je i montiramo.* — Так, у суботу. За десять євро ми його й зберемо.

*Збираємо шафу / Sklapamo ormar*

- Taras: *U uputama piše dvadeset vijaka. Ja imam devetnaest!* — В інструкції написано двадцять гвинтів. А в мене дев’ятнадцять!
- Olena: *Pogledaj u kutiji. Možda je na dnu.* — Подивися в коробці. Може, він на дні.
- Taras: *Nije. Gdje je odvijač?* — Нема. Де викрутка?
- Olena: *Na stoliću, pored zavjese.* — На столику, біля штори.
- Taras: *Evo ga! Vijak je u naslonjaču.* — Ось він! Гвинт у кріслі.

- Вставте слово: *Ključevi su u ___.* → **ladici** (хибні: ladica, ladicu, ladice)
- Складіть: «Повісь пальто на вішалку.» → *Objesi kaput na vješalicu.*
- Складіть: «Постіль лежить у комоді.» → *Posteljina je u komodi.*
- Скажіть уголос: *Ormar moramo sami sklopiti.* (Шафу треба зібрати самим.); *Daljinski je na stoliću.* (Пульт лежить на столику.)

### Урок 26 — Магазин електроніки / Trgovina elektronike (A1.3, питання)

Слова: *slušalice*, *baterija*, *laptop*, *kabel*, *jamstvo*, *ekran*, *tipkovnica*, *miš*, *zvučnik*, *tablet*, *uključiti*, *isključiti*, *ispravan*, *bežični*

*Купую ноутбук / Kupujem laptop*

- Prodavač: *Kakav laptop tražite?* — Який ноутбук шукаєте?
- Andrij: *Za posao. Koliko traje baterija?* — Для роботи. Скільки тримає батарея?
- Prodavač: *Do deset sati. Ekran je velik, a tipkovnica ima svjetlo.* — До десяти годин. Екран великий, а клавіатура з підсвіткою.
- Andrij: *Koliko je jamstvo?* — Яка гарантія?
- Prodavač: *Dvije godine. Bežični miš dobivate gratis.* — Два роки. Бездротову мишку отримуєте в подарунок.

*Не працює! / Ne radi!*

- Oksana: *Ovaj zvučnik ne radi. Imam račun.* — Ця колонка не працює. У мене є чек.
- Prodavačica: *Koji je problem? Ne može se uključiti?* — Яка проблема? Не вмикається?
- Oksana: *Uključuje se, ali nema zvuka. Ni kabel ne pomaže.* — Вмикається, але немає звуку. І кабель не допомагає.
- Prodavačica: *Dobro, provjeravamo. Ako nije ispravan, dobivate novi.* — Добре, перевіримо. Якщо вона несправна, отримаєте нову.
- Oksana: *Hvala. A imate li slušalice za tablet?* — Дякую. А у вас є навушники для планшета?

- Вставте слово: *___ tipkovnicu želite, bežičnu ili s kabelom?* → **Kakvu** (хибні: Kakav, Kakvo, Kakva)
- Складіть: «Яка гарантія на ноутбук?» → *Koliko je jamstvo za laptop?*
- Складіть: «У мене бездротові навушники.» → *Imam bežične slušalice.*
- Скажіть уголос: *Isključi mobitel, molim te.* (Вимкни телефон, будь ласка.); *Je li ovaj tablet ispravan?* (Чи справний цей планшет?)

### Урок 27 — Покупки в інтернеті / Kupnja preko interneta (A1.3, заперечення)

Слова: *narudžba*, *paketomat*, *kurir*, *pošiljka*, *dostava*, *internetska trgovina*, *pratiti*, *oštećen*, *reklamacija*, *povrat novca*, *pouzećem*, *kupac*, *pakiranje*, *praćenje pošiljke*

*Де моє замовлення? / Gdje je moja narudžba?*

- Olena: *Čekam narudžbu već tjedan dana.* — Я чекаю на замовлення вже тиждень.
- Marija: *Imaš li broj za praćenje pošiljke?* — У тебе є номер для відстеження посилки?
- Olena: *Imam. Pratim pošiljku, piše: kod kurira.* — Є. Відстежую посилку, написано: у кур’єра.
- Marija: *Onda stiže danas. Plaćaš li pouzećem?* — Тоді прийде сьогодні. Ти платиш післяплатою?
- Olena: *Ne, karticom. I dostava nije na adresu, nego u paketomat.* — Ні, карткою. І доставка не на адресу, а в поштомат.

*Пошкоджена посилка / Oštećena pošiljka*

- Taras: *Dobar dan, zovem zbog reklamacije.* — Добрий день, дзвоню щодо скарги.
- Službenica: *Recite, koji je problem?* — Скажіть, яка проблема?
- Taras: *Pakiranje je oštećeno, a šalica unutra je razbijena.* — Упаковка пошкоджена, а чашка всередині розбита.
- Službenica: *Žao mi je. Želite li novu šalicu ili povrat novca?* — Мені шкода. Хочете нову чашку чи повернення грошей?
- Taras: *Povrat novca. Ne kupujem više u toj internetskoj trgovini.* — Повернення грошей. Більше не купую в цьому інтернет-магазині.

- Вставте слово: *Kurir ___ dolazi danas.* → **ne** (хибні: ni, nije, nema)
- Складіть: «Я плачу післяплатою.» → *Plaćam pouzećem.*
- Складіть: «Упаковка не пошкоджена.» → *Pakiranje nije oštećeno.*
- Скажіть уголос: *Kupac nije zadovoljan.* (Покупець не задоволений.); *Ne trebam dostavu.* (Мені не потрібна доставка.)

### Урок 33 — Велосипед і самокат / Bicikl i romobil (A1.4, місцевий відмінок)

Слова: *romobil*, *kaciga*, *biciklistička staza*, *kotač*, *lanac*, *lokot*, *iznajmiti*, *pješak*, *kočiti*, *kočnica*, *pločnik*, *opasno*, *pažljivo*, *električni*

*Прокат велосипеда / Najam bicikla*

- Andrij: *Mogu li iznajmiti bicikl na jedan dan?* — Можна орендувати велосипед на один день?
- Djelatnik: *Može. Običan ili električni?* — Можна. Звичайний чи електричний?
- Andrij: *Običan. Imate li i kacigu?* — Звичайний. А шолом у вас є?
- Djelatnik: *Imamo. Lokot je u torbi na biciklu.* — Є. Замок у сумці на велосипеді.
- Andrij: *Gdje je biciklistička staza?* — Де велодоріжка?
- Djelatnik: *Uz rijeku, na lijevoj strani.* — Уздовж річки, з лівого боку.

*Не на тротуарі! / Ne po pločniku!*

- Policajac: *Stanite! Ne smijete voziti romobil po pločniku.* — Зупиніться! Не можна їздити на самокаті по тротуару.
- Taras: *Oprostite, ne znam pravila.* — Вибачте, я не знаю правил.
- Policajac: *Na pločniku su pješaci. To je opasno.* — На тротуарі пішоходи. Це небезпечно.
- Taras: *Razumijem. A gdje mogu voziti?* — Зрозумів. А де можна їздити?
- Policajac: *Na stazi ili na cesti. I vozite pažljivo, kočnica Vam ne radi dobro.* — На доріжці або на дорозі. І їдьте обережно, у вас погано працює гальмо.

- Вставте слово: *Pješaci hodaju po ___.* → **pločniku** (хибні: pločnik, pločnika, pločnikom)
- Складіть: «Їдь обережно по велодоріжці.» → *Vozi pažljivo po biciklističkoj stazi.*
- Складіть: «Колесо й ланцюг у порядку.» → *Kotač i lanac su u redu.*
- Скажіть уголос: *Koči polako, cesta je mokra.* (Гальмуй повільно, дорога мокра.); *Bez kacige je opasno.* (Без шолома небезпечно.)

### Урок 34 — На автомагістралі / Na autocesti (A1.4, родовий відмінок)

Слова: *autocesta*, *cestarina*, *naplatna kućica*, *izlaz*, *smjer*, *kružni tok*, *ograničenje brzine*, *brzina*, *prometna nesreća*, *odmorište*, *obilaznica*, *prometni znak*, *kolona*, *pretjecati*

*Дорога до Спліта / Prema Splitu*

- Olena: *Koliko kilometara ima do Splita?* — Скільки кілометрів до Спліта?
- Taras: *Oko četiristo. Autocestom treba četiri sata.* — Близько чотирьохсот. Магістраллю — чотири години.
- Olena: *Koliko košta cestarina?* — Скільки коштує проїзд?
- Taras: *Oko trideset eura. Plaćamo na naplatnoj kućici.* — Близько тридцяти євро. Платимо на пункті оплати.
- Olena: *Stanimo na odmorištu, trebam kavu.* — Зупинімося на зоні відпочинку, мені треба кави.

*Затор / Kolona*

- Radio: *Zbog prometne nesreće kod izlaza Karlovac je kolona od tri kilometra.* — Через ДТП біля виїзду Карловац затор три кілометри.
- Taras: *Opet kolona! Ima li obilaznica?* — Знову затор! Є об’їзна дорога?
- Olena: *Ima. Na kružnom toku skreni u smjeru Zagreba.* — Є. На кільці поверни в напрямку Загреба.
- Taras: *Pazi, ograničenje brzine je pedeset.* — Обережно, обмеження швидкості — п’ятдесят.
- Olena: *Vidim prometni znak. I ne pretječi ovdje!* — Бачу дорожній знак. І не обганяй тут!

- Вставте слово: *Kolona je duga tri ___.* → **kilometra** (хибні: kilometar, kilometru, kilometrom)
- Складіть: «Візьми наступний виїзд.» → *Uzmi sljedeći izlaz.*
- Складіть: «Скільки коштує проїзд до Рієки?» → *Koliko košta cestarina do Rijeke?*
- Скажіть уголос: *Koje je ovdje ograničenje brzine?* (Яке тут обмеження швидкості?); *Vozi sporije, brzina je velika.* (Їдь повільніше, швидкість велика.)

### Урок 35 — В автосервісі / Na servisu (A1.4, модальні дієслова)

Слова: *servis*, *mehaničar*, *akumulator*, *motor*, *svjetlo*, *tehnički pregled*, *registracija*, *mijenjati*, *kvačilo*, *mjenjač*, *filter*, *popravak*, *gotov*, *zvuk*

*Дивний звук / Čudan zvuk*

- Taras: *Dobar dan. Motor ima neki čudan zvuk.* — Добрий день. Двигун якось дивно звучить.
- Mehaničar: *Kada? Kad mijenjate brzine?* — Коли? Коли перемикаєте передачі?
- Taras: *Da. Mislim da je problem kvačilo ili mjenjač.* — Так. Думаю, проблема в зчепленні або коробці передач.
- Mehaničar: *Moram pogledati. Možete li ostaviti auto do sutra?* — Мушу подивитися. Можете залишити авто до завтра?
- Taras: *Mogu. Koliko košta popravak?* — Можу. Скільки коштує ремонт?
- Mehaničar: *Ne znam još. Zovem Vas kad je gotov.* — Ще не знаю. Подзвоню вам, коли буде готовий.

*Техогляд / Tehnički pregled*

- Olena: *Trebam tehnički pregled i registraciju.* — Мені потрібні техогляд і реєстрація.
- Službenik: *Svjetla ne rade dobro. Morate promijeniti žarulju.* — Фари погано працюють. Треба поміняти лампочку.
- Olena: *Može li to napraviti servis ovdje?* — Чи може це зробити сервіс тут?
- Službenik: *Može. I akumulator je star, a filter je prljav.* — Може. І акумулятор старий, а фільтр брудний.
- Olena: *Dobro, mijenjajte sve. Ne smijem voziti bez registracije.* — Добре, міняйте все. Мені не можна їздити без реєстрації.

- Вставте слово: *Auto ___ na tehnički pregled svake godine.* → **mora** (хибні: moram, moraju, moraš)
- Складіть: «Акумулятор розряджений.» → *Akumulator je prazan.*
- Складіть: «Коли машина буде готова?» → *Kada je auto gotov?*
- Скажіть уголос: *Treba promijeniti filter.* (Треба поміняти фільтр.); *Mehaničar popravlja motor.* (Механік ремонтує двигун.)

### Урок 36 — Міжміський автобус / Međugradski autobus (A1.4, присвійні займенники)

Слова: *autobusni kolodvor*, *međugradski*, *polazak*, *sjedalo*, *prtljažni prostor*, *vožnja*, *trajati*, *relacija*, *putnik*, *pojas*, *vezati*, *presjedanje*, *izravan*, *noćni*

*На автовокзалі / Na autobusnom kolodvoru*

- Oksana: *Jednu kartu za Split, molim. Kada je sljedeći polazak?* — Один квиток до Спліта, будь ласка. Коли наступне відправлення?
- Blagajnica: *U deset. Ili noćni autobus u jedanaest navečer.* — О десятій. Або нічний автобус об одинадцятій вечора.
- Oksana: *Je li to izravna linija?* — Це прямий рейс?
- Blagajnica: *Da, bez presjedanja. Vožnja traje pet sati.* — Так, без пересадок. Поїздка триває п’ять годин.
- Oksana: *Koje je moje sjedalo?* — Яке моє місце?
- Blagajnica: *Vaše sjedalo je broj četrnaest.* — Ваше місце — номер чотирнадцять.

*В автобусі / U autobusu*

- Vozač: *Vaš kofer stavite u prtljažni prostor.* — Вашу валізу покладіть у багажне відділення.
- Andrij: *Je li ovo autobus na relaciji Zagreb – Zadar?* — Це автобус за маршрутом Загреб – Задар?
- Vozač: *Da. Vaša karta, molim.* — Так. Ваш квиток, будь ласка.
- Putnica: *Oprostite, je li ovo Vaše mjesto ili moje?* — Перепрошую, це ваше місце чи моє?
- Vozač: *Dragi putnici, vežite pojas. Krećemo!* — Шановні пасажири, пристебніть паски. Вирушаємо!

- Вставте слово: *Je li ovo ___ sjedalo, gospođo?* → **Vaše** (хибні: Vaš, Vaša, Vaši)
- Складіть: «Поїздка триває п’ять годин.» → *Vožnja traje pet sati.*
- Складіть: «Пристебніть пасок, будь ласка.» → *Vežite pojas, molim.*
- Скажіть уголос: *Gdje su međugradski autobusi?* (Де міжміські автобуси?); *Kada je polazak noćnog autobusa?* (Коли відправлення нічного автобуса?)

### Урок 41 — Переїзд / Selidba (A1.5, сполучники)

Слова: *selidba*, *seliti se*, *kutija*, *nositi*, *pakirati*, *kombi*, *iseliti se*, *predati*, *preuzeti*, *stvar*, *lomljiv*, *težak*, *prazan*, *prijevoz*

*Пакуємо речі / Pakiramo stvari*

- Olena: *Selimo se u subotu, a imamo puno stvari!* — Ми переїжджаємо в суботу, а в нас багато речей!
- Taras: *Ne brini. Danas pakiram knjige, a sutra kuhinju.* — Не хвилюйся. Сьогодні пакую книжки, а завтра кухню.
- Olena: *Ova kutija je preteška. Ne mogu je nositi.* — Ця коробка заважка. Не можу її нести.
- Taras: *Onda stavi manje knjiga. Gdje su čaše?* — Тоді поклади менше книжок. Де склянки?
- Olena: *U onoj kutiji. Napiši na nju "lomljivo", jer su čaše unutra.* — У тій коробці. Напиши на ній «крихке», бо там склянки.

*Віддаємо ключі / Predajemo ključeve*

- Stanodavac: *Kad se iselite, stan mora biti prazan i čist.* — Коли виїдете, квартира має бути порожня й чиста.
- Taras: *Naravno. Kombi dolazi u devet, a ključeve predajemo u podne.* — Звісно. Бус приїжджає о дев’ятій, а ключі віддаємо опівдні.
- Stanodavac: *Dobro. A polog?* — Добре. А застава?
- Taras: *Polog preuzimam kad Vi pregledate stan.* — Заставу заберу, коли ви оглянете квартиру.
- Stanodavac: *Može. Kako ide selidba?* — Добре. Як іде переїзд?
- Taras: *Teško, ali prijevoz je jeftin jer prijatelj ima kombi.* — Важко, але перевезення дешеве, бо в друга є бус.

- Вставте слово: *Napiši "lomljivo", ___ su čaše unutra.* → **jer** (хибні: ali, ili, nego)
- Складіть: «Ми переїжджаємо в нову квартиру.» → *Selimo se u novi stan.*
- Складіть: «Коробка велика, але не важка.» → *Kutija je velika, ali nije teška.*
- Скажіть уголос: *Kada je selidba?* (Коли переїзд?); *Pazi, ovo je lomljivo!* (Обережно, це крихке!)

### Урок 42 — Правила будинку / Kućni red (A1.5, заперечення)

Слова: *kućni red*, *upravitelj zgrade*, *pričuva*, *zajednički*, *podrum*, *tavan*, *sušiti*, *mir*, *poštanski sandučić*, *ulaz*, *zabranjeno*, *dopušteno*, *poštovati*, *pravilo*

*Правила будинку / Kućni red*

- Upravitelj: *Dobro došli! Ovo je kućni red zgrade.* — Ласкаво просимо! Це правила будинку.
- Oksana: *Što nije dopušteno?* — Що не дозволено?
- Upravitelj: *Od deset navečer do šest ujutro mora biti mir. Pušenje u ulazu je zabranjeno.* — З десятої вечора до шостої ранку має бути тиша. Курити в під’їзді заборонено.
- Oksana: *Smijem li sušiti rublje na balkonu?* — Чи можна сушити білизну на балконі?
- Upravitelj: *Ne na balkonu prema ulici. Za to je zajednički prostor na tavanu.* — Не на балконі з боку вулиці. Для цього є спільне приміщення на горищі.

*Сусідка / Susjeda*

- Susjeda: *Vi ste novi? Ja sam Vesna s drugog kata.* — Ви нові? Я Весна з другого поверху.
- Taras: *Drago mi je. Gdje je naš poštanski sandučić?* — Приємно познайомитися. Де наша поштова скринька?
- Susjeda: *Dolje kod ulaza. A bicikl ne ostavljajte u hodniku, nego u podrumu.* — Внизу біля входу. А велосипед не залишайте в коридорі, а в підвалі.
- Taras: *Hvala. Plaćamo li pričuvu upravitelju zgrade?* — Дякую. Внесок на будинок платимо управителю?
- Susjeda: *Ne, plaćate je uplatnicom. Svi ovdje poštuju pravila.* — Ні, платите за квитанцією. Тут усі дотримуються правил.

- Вставте слово: *Pušenje u ulazu ___ dopušteno.* → **nije** (хибні: ne, nisu, nema)
- Складіть: «Не залишайте велосипед у коридорі.» → *Ne ostavljajte bicikl u hodniku.*
- Складіть: «Старі речі на горищі.» → *Stare stvari su na tavanu.*
- Скажіть уголос: *Ovdje je zabranjeno pušiti.* (Тут заборонено курити.); *Poštujemo kućni red.* (Ми поважаємо правила будинку.)

### Урок 43 — Опалення й холод / Grijanje i hladnoća (A1.5, правильні дієслова)

Слова: *radijator*, *klima*, *peć*, *drva*, *prozračiti*, *vlaga*, *plijesan*, *štedjeti*, *hladnoća*, *termostat*, *stupanj*, *smrznuti se*, *potrošnja*, *brojilo*

*Холодно в квартирі / Hladno je u stanu*

- Olena: *Radijatori su hladni! Smrzavam se.* — Батареї холодні! Я мерзну.
- Taras: *Termostat je na osamnaest stupnjeva. Stavljam dvadeset dva.* — Термостат на вісімнадцяти градусах. Ставлю двадцять два.
- Olena: *A klima? Grije li i ona?* — А кондиціонер? Він теж гріє?
- Taras: *Grije, ali potrošnja struje je velika. Moramo štedjeti.* — Гріє, але споживання електрики велике. Мусимо економити.
- Olena: *Dobro, onda pijem čaj i nosim džemper.* — Добре, тоді п’ю чай і вдягаю светр.

*Пліснява у ванній / Plijesan u kupaonici*

- Oksana: *Na zidu u kupaonici je plijesan.* — На стіні у ванній пліснява.
- Stanodavac: *To je od vlage. Prozračujete li stan?* — Це від вологи. Ви провітрюєте квартиру?
- Oksana: *Rijetko, zbog hladnoće.* — Рідко, через холод.
- Stanodavac: *Prozračujte svako jutro deset minuta. I pošaljite mi stanje brojila za plin.* — Провітрюйте щоранку десять хвилин. І надішліть мені показники лічильника газу.
- Oksana: *Dobro. Kod moje bake na selu grije peć na drva i nema vlage.* — Добре. У моєї бабусі в селі гріє піч на дровах, і вологи немає.

- Вставте слово: *Mi zimi ___ stan svako jutro.* → **prozračujemo** (хибні: prozračujem, prozračuju, prozračuješ)
- Складіть: «Провітри кімнату десять хвилин.» → *Prozrači sobu deset minuta.*
- Складіть: «Лічильник у підвалі.» → *Brojilo je u podrumu.*
- Скажіть уголос: *Bez kape se brzo smrznem.* (Без шапки я швидко замерзну.); *Moramo štedjeti plin.* (Нам треба економити газ.)

### Урок 44 — Дрібний ремонт / Mali popravci (A1.5, наказовий спосіб)

Слова: *zid*, *strop*, *brtva*, *pločica*, *čavao*, *čekić*, *bušilica*, *odvijač*, *alat*, *ličiti*, *objesiti*, *slavina*, *kapati*, *žarulja*

*Вішаємо полицю / Vješamo policu*

- Taras: *Gdje je bušilica? Želim objesiti policu.* — Де дриль? Хочу повісити полицю.
- Olena: *U kutiji s alatom, pored čekića.* — У ящику з інструментами, біля молотка.
- Taras: *Zid je tvrd. Daj mi i odvijač, molim te.* — Стіна тверда. Дай мені ще викрутку, будь ласка.
- Olena: *Evo. Pazi, ne buši blizu utičnice!* — Ось. Обережно, не свердли біля розетки!
- Taras: *Znam. A sliku vješam na čavao.* — Знаю. А картину вішаю на цвях.

*Кран капає / Slavina kaplje*

- Oksana: *Majstore, slavina u kupaonici stalno kaplje.* — Майстре, кран у ванній постійно капає.
- Majstor: *Pokažite mi. Aha, treba nova brtva.* — Покажіть. Ага, потрібна нова прокладка.
- Oksana: *I jedna pločica na podu je razbijena.* — І одна плитка на підлозі розбита.
- Majstor: *Nema problema. Imate li još pločica?* — Без проблем. У вас є ще плитки?
- Oksana: *Imam. I promijenite, molim Vas, žarulju na stropu.* — Є. І поміняйте, будь ласка, лампочку на стелі.

- Вставте слово: *___ sliku na zid, molim te.* → **Objesi** (хибні: Objesiti, Objesim, Objesio)
- Складіть: «Дай мені молоток і цвях.» → *Daj mi čekić i čavao.*
- Складіть: «Поміняй лампочку в коридорі.» → *Promijeni žarulju u hodniku.*
- Скажіть уголос: *Ovaj vikend ličimo dnevni boravak.* (Цими вихідними ми фарбуємо вітальню.); *Slavina u kuhinji kaplje.* (Кран на кухні капає.)

### Урок 50 — Професії / Zanimanja (A1.6, теперішній час)

Слова: *kuhar*, *čistačica*, *električar*, *vodoinstalater*, *zidar*, *njegovateljica*, *frizerka*, *blagajnica*, *skladištar*, *recepcioner*, *sobarica*, *radnik*, *gradilište*, *skladište*

*Ким ти працюєш? / Što radiš?*

- Marko: *Što radiš u Hrvatskoj?* — Ким ти працюєш у Хорватії?
- Oksana: *Radim kao sobarica u hotelu. Moj muž je kuhar.* — Я працюю покоївкою в готелі. Мій чоловік — кухар.
- Marko: *A tvoja sestra?* — А твоя сестра?
- Oksana: *Ona je njegovateljica. Brine o starijoj gospođi.* — Вона доглядальниця. Доглядає літню пані.
- Marko: *Ja sam električar. Radim na gradilištu.* — Я електрик. Працюю на будівництві.

*Вакансії / Slobodna radna mjesta*

- Ana: *Trgovina traži blagajnicu i skladištara.* — Магазин шукає касирку й комірника.
- Taras: *Je li skladište daleko?* — Склад далеко?
- Ana: *Ne, blizu. A hotel traži recepcionera i čistačicu.* — Ні, близько. А готель шукає адміністратора й прибиральницю.
- Taras: *Znam engleski, mogu raditi na recepciji.* — Я знаю англійську, можу працювати на рецепції.
- Ana: *Super! A tvoj brat je zidar, zar ne?* — Чудово! А твій брат муляр, так?
- Taras: *Da, ali sada radi kao vodoinstalater.* — Так, але зараз працює сантехніком.

- Вставте слово: *Moj muž ___ kao kuhar.* → **radi** (хибні: radim, radiš, rade)
- Складіть: «Я працюю покоївкою в готелі.» → *Radim kao sobarica u hotelu.*
- Складіть: «Вона доглядає літню пані.» → *Ona brine o starijoj gospođi.*
- Скажіть уголос: *Moja prijateljica je frizerka.* (Моя подруга — перукарка.); *Na gradilištu radi puno radnika.* (На будівництві працює багато робітників.)

### Урок 51 — Шукаю роботу / Tražim posao (A1.6, питання)

Слова: *oglas*, *životopis*, *poslodavac*, *uvjet*, *satnica*, *smještaj*, *sezonski*, *radno mjesto*, *zavod za zapošljavanje*, *nezaposlen*, *prijaviti se*, *preporuka*, *stalan*, *plaćen*

*Оголошення / Oglas za posao*

- Andrij: *Dobar dan, zovem zbog oglasa. Je li radno mjesto još slobodno?* — Добрий день, дзвоню щодо оголошення. Посада ще вільна?
- Poslodavac: *Jest. Tražimo konobara za sezonu. Imate li iskustva?* — Так. Шукаємо офіціанта на сезон. У вас є досвід?
- Andrij: *Imam dvije godine iskustva. Kakvi su uvjeti?* — Маю два роки досвіду. Які умови?
- Poslodavac: *Satnica je osam eura. Smještaj i hrana su besplatni.* — Погодинна оплата — вісім євро. Житло й харчування безкоштовні.
- Andrij: *Je li posao sezonski ili stalan?* — Робота сезонна чи постійна?
- Poslodavac: *Sezonski, do listopada. Pošaljite mi životopis.* — Сезонна, до жовтня. Надішліть мені резюме.

*У центрі зайнятості / Na Zavodu za zapošljavanje*

- Službenica: *Jeste li nezaposleni?* — Ви безробітні?
- Olena: *Da. Kako se mogu prijaviti na Zavod za zapošljavanje?* — Так. Як мені зареєструватися в центрі зайнятості?
- Službenica: *Trebate osobni dokument i OIB.* — Вам потрібні документ, що посвідчує особу, і OIB.
- Olena: *Imate li preporuku za neki tečaj?* — Можете порадити якісь курси?
- Službenica: *Imamo tečaj hrvatskog za strance. Za Vas je plaćen.* — У нас є курс хорватської для іноземців. Для вас він оплачений.

- Вставте слово: *___ su uvjeti rada?* → **Kakvi** (хибні: Kakav, Kakva, Kakvo)
- Складіть: «Надішліть мені резюме.» → *Pošaljite mi životopis.*
- Складіть: «Я шукаю постійну роботу.» → *Tražim stalan posao.*
- Скажіть уголос: *Kolika je satnica?* (Яка погодинна оплата?); *Tko je poslodavac?* (Хто роботодавець?)

### Урок 52 — Перший робочий день / Prvi radni dan (A1.6, модальні дієслова)

Слова: *radna odjeća*, *svlačionica*, *ormarić*, *pauza*, *zaštitna oprema*, *sigurnost*, *upute*, *voditelj*, *zadatak*, *naučiti*, *objasniti*, *tim*, *odgovoran*, *točan*

*Ласкаво просимо в команду / Dobro došla u tim*

- Maja: *Dobro došla u naš tim! Ja sam Maja, voditeljica smjene.* — Ласкаво просимо в нашу команду! Я Мая, керівниця зміни.
- Oksana: *Drago mi je. Što moram danas naučiti?* — Приємно познайомитися. Що мені сьогодні треба вивчити?
- Maja: *Prvo svlačionica. Tamo su tvoj ormarić i radna odjeća.* — Спочатку роздягальня. Там твоя шафка й робочий одяг.
- Oksana: *Kada je pauza?* — Коли перерва?
- Maja: *U deset i u dva, po petnaest minuta. Moraš biti točna.* — О десятій і о другій, по п’ятнадцять хвилин. Треба бути пунктуальною.

*Безпека на складі / Sigurnost u skladištu*

- Voditelj: *Ovdje je sigurnost najvažnija. Bez zaštitne opreme ne smiješ ući.* — Тут безпека найважливіша. Без захисного спорядження заходити не можна.
- Andrij: *Razumijem. Možete li mi objasniti upute?* — Розумію. Можете пояснити мені інструкції?
- Voditelj: *Naravno. Tvoj zadatak je slagati pakete na police.* — Звісно. Твоє завдання — складати пакунки на полиці.
- Andrij: *Koga trebam zvati ako imam problem?* — Кому мені дзвонити, якщо є проблема?
- Voditelj: *Mene. Ja sam odgovoran za cijeli tim.* — Мені. Я відповідаю за всю команду.

- Вставте слово: *Ti bez zaštitne opreme ne ___ ući.* → **smiješ** (хибні: smijem, smije, smijemo)
- Складіть: «Сумку залиш у шафці.» → *Torbu ostavi u ormariću.*
- Складіть: «Що мені треба вивчити?» → *Što moram naučiti?*
- Скажіть уголос: *Gdje je svlačionica?* (Де роздягальня?); *Ja sam odgovoran za sigurnost.* (Я відповідаю за безпеку.)

### Урок 53 — В офісі / U uredu (A1.6, правильні дієслова)

Слова: *pisač*, *ispisati*, *skenirati*, *datoteka*, *privitak*, *mapa*, *računalo*, *kopirati*, *spremiti*, *obrisati*, *odgovoriti*, *proslijediti*, *papir*, *tablica*

*Принтер не друкує / Pisač ne radi*

- Ivana: *Pisač opet ne radi! Trebam ispisati ugovor.* — Принтер знову не працює! Мені треба роздрукувати договір.
- Taras: *Nema papira. Evo, stavljam papir.* — Немає паперу. Ось, кладу папір.
- Ivana: *Hvala! Možeš li mi skenirati i ovu putovnicu?* — Дякую! Можеш мені ще відсканувати цей паспорт?
- Taras: *Mogu. Datoteku spremam u mapu Klijenti.* — Можу. Файл зберігаю в папку «Клієнти».
- Ivana: *Super. Kopiraj je i na moje računalo.* — Чудово. Скопіюй його й на мій комп’ютер.

*Пошта на роботі / Mail na poslu*

- Šef: *Molim Vas, odgovorite danas klijentu iz Splita.* — Будь ласка, дайте сьогодні відповідь клієнту зі Спліта.
- Oksana: *Naravno. Što mu šaljem?* — Звісно. Що йому надіслати?
- Šef: *Tablicu s cijenama. Ona je u privitku mog maila.* — Таблицю з цінами. Вона у вкладенні мого листа.
- Oksana: *Dobro, prosljeđujem mu Vaš mail.* — Добре, пересилаю йому ваш лист.
- Šef: *I obrišite stare datoteke iz zajedničke mape.* — І видаліть старі файли зі спільної папки.

- Вставте слово: *Ja ___ dokumente u mapu.* → **spremam** (хибні: spremaš, sprema, spremaju)
- Складіть: «Договір у вкладенні.» → *Ugovor je u privitku.*
- Складіть: «Роздрукуй мені цей документ.» → *Ispiši mi ovaj dokument.*
- Скажіть уголос: *Proslijedi mi taj mail.* (Перешли мені цей лист.); *Podaci su u tablici.* (Дані в таблиці.)

### Урок 59 — Травма / Ozljeda (A1.7, неправильні дієслова)

Слова: *ozljeda*, *ozlijediti se*, *pasti*, *slomiti*, *rana*, *krv*, *zavoj*, *flaster*, *gips*, *modrica*, *otečen*, *krvariti*, *uganuti*, *hitni prijem*

*Поріз на роботі / Ozljeda na poslu*

- Kolega: *Što ti je? Ruka ti krvari!* — Що з тобою? У тебе кровить рука!
- Andrij: *Nož. Rana nije duboka, ali krv ne staje.* — Ніж. Рана неглибока, але кров не зупиняється.
- Kolega: *Evo flaster. Ne, trebaš zavoj!* — Ось пластир. Ні, тобі потрібен бинт!
- Andrij: *Hvala. Daj mi i malo vode.* — Дякую. Дай мені ще трохи води.
- Kolega: *Sjedni. Zovem šefa, to je ozljeda na radu.* — Сідай. Кличу шефа, це травма на роботі.

*У приймальному відділенні / Na hitnom prijemu*

- Liječnica: *Što Vas boli?* — Що у вас болить?
- Olena: *Gležanj. Jako je otečen i plav.* — Щиколотка. Дуже набрякла й синя.
- Liječnica: *Imate veliku modricu. Možete li hodati?* — У вас великий синець. Можете ходити?
- Olena: *Jedva. Je li slomljen?* — Ледве. Вона зламана?
- Liječnica: *Ne znam još. Idemo na rendgen. Ako je slomljen, dobivate gips.* — Ще не знаю. Ідемо на рентген. Якщо зламана, отримаєте гіпс.

- Вставте слово: *Dijete često ___ na igralištu.* → **padne** (хибні: pasti, padnem, padnu)
- Складіть: «Рана кровить.» → *Rana krvari.*
- Складіть: «У мене синець на коліні.» → *Imam modricu na koljenu.*
- Скажіть уголос: *Pazi, možeš se ozlijediti!* (Обережно, можеш травмуватися!); *Gdje je hitni prijem?* (Де приймальне відділення?)

### Урок 60 — Аналізи й обстеження / Pretrage i nalazi (A1.7, родовий відмінок)

Слова: *uputnica*, *specijalist*, *laboratorij*, *nalaz krvi*, *pretraga*, *tlak*, *natašte*, *kontrola*, *rendgen*, *čekaonica*, *obiteljski liječnik*, *ultrazvuk*, *naručiti se*, *mjeriti*

*У сімейного лікаря / Kod obiteljskog liječnika*

- Liječnik: *Sada Vam mjerim tlak.* — Зараз виміряю вам тиск.
- Taras: *Je li visok?* — Він високий?
- Liječnik: *Malo. Trebate pretragu krvi i ultrazvuk srca.* — Трохи. Вам треба здати аналіз крові й зробити УЗД серця.
- Taras: *Trebam li uputnicu?* — Мені потрібне направлення?
- Liječnik: *Da, evo uputnice za laboratorij i za specijalista.* — Так, ось направлення до лабораторії і до спеціаліста.

*У лабораторії / U laboratoriju*

- Sestra: *Dobro jutro. Jeste li natašte?* — Доброго ранку. Ви натщесерце?
- Olena: *Jesam, ništa ne jedem od jučer.* — Так, нічого не їм з учорашнього дня.
- Sestra: *Dobro. Sjednite u čekaonicu, zovem Vas.* — Добре. Сядьте в залі очікування, я вас покличу.
- Olena: *Kada dobivam nalaz krvi?* — Коли я отримаю результат аналізу крові?
- Sestra: *Sutra. S nalazom se naručite kod liječnika na kontrolu.* — Завтра. З результатом запишіться до лікаря на контрольний огляд.

- Вставте слово: *Trebam uputnicu od obiteljskog ___.* → **liječnika** (хибні: liječnik, liječniku, liječnikom)
- Складіть: «Кров здаємо натщесерце.» → *Krv vadimo natašte.*
- Складіть: «Мені треба записатися до спеціаліста.» → *Moram se naručiti kod specijalista.*
- Скажіть уголос: *Trebam rendgen pluća.* (Мені потрібен рентген легенів.); *Gdje je čekaonica?* (Де зал очікування?)

### Урок 61 — Здоровий спосіб життя / Zdrav život (A1.7, ступені порівняння)

Слова: *zdrav život*, *teretana*, *vježbati*, *težina*, *mršaviti*, *debljati se*, *dijeta*, *alkohol*, *pušenje*, *redovito*, *kretanje*, *pravilna prehrana*, *stres*, *navika*

*У спортзалі / U teretani*

- Trener: *Koliko često vježbate?* — Як часто ви тренуєтеся?
- Taras: *Rijetko. Zimi se debljam.* — Рідко. Взимку я гладшаю.
- Trener: *Dolazite redovito, tri puta tjedno. To je bolje od dijete.* — Приходьте регулярно, тричі на тиждень. Це краще за дієту.
- Taras: *A trčanje ili plivanje, što je zdravije?* — А біг чи плавання — що здоровіше?
- Trener: *Plivanje je lakše za koljena, a s trčanjem brže mršavite.* — Плавання легше для колін, а з бігом ви швидше худнете.

*Здорові звички / Zdrave navike*

- Liječnica: *Pušite li?* — Ви курите?
- Andrij: *Da, ali manje nego prije.* — Так, але менше, ніж раніше.
- Liječnica: *Pušenje i alkohol su najgore navike. Imate li puno stresa?* — Куріння й алкоголь — найгірші звички. У вас багато стресу?
- Andrij: *Imam. I težina mi raste.* — Так. І вага в мене росте.
- Liječnica: *Važni su pravilna prehrana i kretanje. Hodajte više!* — Важливі правильне харчування й рух. Ходіть більше!

- Вставте слово: *Plivanje je ___ od trčanja za koljena.* → **bolje** (хибні: dobro, najbolje, dobar)
- Складіть: «Я тренуюся тричі на тиждень.» → *Vježbam tri puta tjedno.*
- Складіть: «Здоровий спосіб життя — це звичка.» → *Zdrav život je navika.*
- Скажіть уголос: *Želim mršaviti, ali ne volim dijete.* (Я хочу схуднути, але не люблю дієт.); *Koliko često ideš u teretanu?* (Як часто ти ходиш у спортзал?)

### Урок 62 — У педіатра / Kod pedijatra (A1.7, наказовий спосіб)

Слова: *pedijatar*, *osip*, *povraćati*, *proljev*, *kihati*, *curiti*, *nos*, *toplomjer*, *upala*, *kapi*, *pregledati*, *dojenče*, *kašljati*, *mast*

*Дитина хворіє / Dijete je bolesno*

- Olena: *Doktorice, mala ima temperaturu i kašlje.* — Лікарко, мала має температуру й кашляє.
- Pedijatrica: *Kolika je temperatura na toplomjeru?* — Яка температура на термометрі?
- Olena: *Trideset osam. I stalno kiše, curi joj nos.* — Тридцять вісім. І постійно чхає, у неї тече з носа.
- Pedijatrica: *Da je pregledam. Aha, ima upalu uha.* — Дайте я її огляну. Ага, у неї запалення вуха.
- Olena: *Što da radim?* — Що мені робити?
- Pedijatrica: *Dajte joj kapi za uho i sirup. Neka pije puno vode.* — Давайте їй краплі у вухо і сироп. Нехай п’є багато води.

*Висип у немовляти / Osip kod dojenčeta*

- Taras: *Naše dojenče ima osip po tijelu.* — У нашого немовляти висип по тілу.
- Pedijatar: *Povraća li? Ima li proljev?* — Він блює? Має пронос?
- Taras: *Ne, samo je nemiran i plače.* — Ні, тільки неспокійний і плаче.
- Pedijatar: *To je alergija. Stavljajte ovu mast na osip dvaput dnevno.* — Це алергія. Наносьте цю мазь на висип двічі на день.
- Taras: *Hvala, doktore.* — Дякую, лікарю.

- Вставте слово: *___ joj kapi tri puta dnevno.* → **Dajte** (хибні: Dati, Dajem, Daju)
- Складіть: «У дитини запалення вуха.» → *Dijete ima upalu uha.*
- Складіть: «У мене тече з носа.» → *Curi mi nos.*
- Скажіть уголос: *Trebam se naručiti kod pedijatra.* (Мені треба записатися до педіатра.); *Dijete kašlje noću.* (Дитина кашляє вночі.)

### Урок 68 — Кохання й стосунки / Ljubav i veze (A1.8, присвійні займенники)

Слова: *zaljubiti se*, *spoj*, *ljubav*, *poljubac*, *zagrljaj*, *vjenčanje*, *zaručen*, *rastati se*, *partner*, *djevojka*, *zgodan*, *romantičan*, *prsten*, *godišnjica*

*Побачення / Spoj*

- Ana: *Imaš li večeras spoj?* — У тебе сьогодні ввечері побачення?
- Ivana: *Imam! S Markom iz teretane.* — Так! З Марком із спортзалу.
- Ana: *Je li zgodan?* — Він гарний?
- Ivana: *Jako. I romantičan je, vodi me na večeru uz more.* — Дуже. І романтичний, веде мене на вечерю біля моря.
- Ana: *Mislim da se zaljubljuješ!* — Думаю, ти закохуєшся!

*Річниця / Godišnjica*

- Olena: *Sutra nam je godišnjica braka. Deset godina!* — Завтра в нас річниця шлюбу. Десять років!
- Marija: *Čestitam! Što ti tvoj muž kupuje?* — Вітаю! Що тобі купує твій чоловік?
- Olena: *Ne znam. Možda prsten. A kako je tvoj partner?* — Не знаю. Може, каблучку. А як твій партнер?
- Marija: *Dobro. Zaručeni smo! Vjenčanje je u lipnju.* — Добре. Ми заручені! Весілля в червні.
- Olena: *Divno! Ljubav je najvažnija.* — Чудово! Кохання найважливіше.

- Вставте слово: *Kako je ___ partner?* → **tvoj** (хибні: tvoja, tvoje, tvoju)
- Складіть: «Це моя дівчина Ана.» → *Ovo je moja djevojka Ana.*
- Складіть: «Наше весілля в червні.» → *Naše vjenčanje je u lipnju.*
- Скажіть уголос: *Zagrljaj i poljubac!* (Обійми й поцілунок!); *Ne želim se rastati od tebe.* (Я не хочу з тобою розлучатися.)

### Урок 69 — Спорт і матчі / Sport i utakmice (A1.8, теперішній час)

Слова: *trener*, *trening*, *utakmica*, *momčad*, *navijati*, *gol*, *pobijediti*, *izgubiti*, *košarka*, *tenis*, *odbojka*, *rukomet*, *igrač*, *lopta*

*За кого вболіваєш? / Za koga navijaš?*

- Marko: *Večeras je utakmica. Za koga navijaš?* — Сьогодні ввечері матч. За кого ти вболіваєш?
- Taras: *Za Hajduk, naravno! A ti?* — За «Хайдук», звісно! А ти?
- Marko: *Ja za Dinamo. Mislim da Dinamo danas pobjeđuje.* — Я за «Динамо». Думаю, «Динамо» сьогодні переможе.
- Taras: *Nema šanse! Hajduk ima bolju momčad.* — Без шансів! У «Хайдука» краща команда.
- Marko: *Dobro, gledamo zajedno u kafiću?* — Добре, дивимося разом у кафе?

*Тренування / Trening*

- Trener: *Dobro došao! Igraš li rukomet?* — Ласкаво просимо! Ти граєш у гандбол?
- Danilo: *Ne, igram košarku i odbojku.* — Ні, я граю в баскетбол і волейбол.
- Trener: *Nema veze. Trening je utorkom i četvrtkom.* — Нічого страшного. Тренування по вівторках і четвергах.
- Danilo: *Trebam li svoju loptu?* — Мені потрібен свій м’яч?
- Trener: *Ne. Svaki igrač dobiva dres i loptu.* — Ні. Кожен гравець отримує форму і м’яч.

- Вставте слово: *Za koga ___ ti?* → **navijaš** (хибні: navijam, navija, navijaju)
- Складіть: «Хорватія сильна в гандболі.» → *Hrvatska je jaka u rukometu.*
- Складіть: «Мій брат грає в теніс.» → *Moj brat igra tenis.*
- Скажіть уголос: *Ne želimo izgubiti.* (Ми не хочемо програти.); *Kakav lijep gol!* (Який гарний гол!)

### Урок 70 — Театр і концерти / Kazalište i koncerti (A1.8, місцевий відмінок)

Слова: *kazalište*, *koncert*, *predstava*, *pjevač*, *glumac*, *bend*, *nastup*, *izložba*, *galerija*, *publika*, *pozornica*, *rasprodan*, *festival*, *umjetnost*

*Квитки на концерт / Karte za koncert*

- Ana: *U subotu je koncert mog omiljenog benda!* — У суботу концерт мого улюбленого гурту!
- Oksana: *Gdje je koncert?* — Де концерт?
- Ana: *Na festivalu u Puli, u Areni.* — На фестивалі в Пулі, на Арені.
- Oksana: *Ima li još karata?* — Ще є квитки?
- Ana: *Nažalost, koncert je rasprodan. Ali nastup gledam na televiziji.* — На жаль, концерт розпроданий. Але виступ дивлюся по телевізору.

*У театрі / U kazalištu*

- Taras: *Kakva je predstava?* — Яка вистава?
- Marija: *Odlična! Glumac u glavnoj ulozi je fantastičan.* — Чудова! Актор у головній ролі фантастичний.
- Taras: *I publika je oduševljena.* — І публіка в захваті.
- Marija: *Gledaj, pjevač izlazi na pozornicu!* — Дивись, співак виходить на сцену!
- Taras: *Super. Sutra idemo i na izložbu u galeriji?* — Чудово. Завтра підемо ще й на виставку в галерею?

- Вставте слово: *Pjevač je na ___.* → **pozornici** (хибні: pozornica, pozornicu, pozornice)
- Складіть: «Я люблю сучасне мистецтво.» → *Volim modernu umjetnost.*
- Складіть: «Виставка в галереї.» → *Izložba je u galeriji.*
- Скажіть уголос: *Karte za predstavu su rasprodane.* (Квитки на виставу розпродані.); *Sjedimo u kazalištu.* (Ми сидимо в театрі.)

### Урок 71 — Соцмережі / Društvene mreže (A1.8, сполучники)

Слова: *društvene mreže*, *objaviti*, *komentar*, *dijeliti*, *profil*, *grupa*, *pratitelj*, *video*, *stranica*, *vijest*, *snimiti*, *pročitati*, *odgovor*, *privatan*

*Відео з моря / Video s mora*

- Ivana: *Ovaj video snimam za Instagram.* — Це відео знімаю для інстаграму.
- Oksana: *Objavljuješ li sve na društvenim mrežama?* — Ти все публікуєш у соцмережах?
- Ivana: *Ne sve, jer mi je profil javan. Imam puno pratitelja.* — Не все, бо мій профіль публічний. У мене багато підписників.
- Oksana: *Moj je privatan, ali često dijelim fotografije s obitelji.* — Мій приватний, але я часто ділюся фотографіями з родиною.
- Ivana: *Pošalji mi link pa te pratim!* — Надішли мені посилання, і я на тебе підпишуся!

*Група для українців / Grupa za Ukrajince*

- Taras: *Znaš li grupu za Ukrajince u Zagrebu?* — Ти знаєш групу для українців у Загребі?
- Olena: *Znam. Tamo su sve važne vijesti i savjeti.* — Знаю. Там усі важливі новини й поради.
- Taras: *Pitam za vrtić, ali nema odgovora.* — Я питаю про садок, але відповіді немає.
- Olena: *Pročitaj komentare ispod ili napiši na stranici grada.* — Прочитай коментарі нижче або напиши на сторінці міста.

- Вставте слово: *Moj profil je privatan, ___ tvoj je javan.* → **a** (хибні: jer, ili, da)
- Складіть: «Я ділюся відео з родиною.» → *Dijelim video s obitelji.*
- Складіть: «Прочитай новину на сторінці.» → *Pročitaj vijest na stranici.*
- Скажіть уголос: *Ne objavljujem fotografije djece.* (Я не публікую фото дітей.); *Koliko imaš pratitelja?* (Скільки в тебе підписників?)

### Урок 77 — Хорватська кухня / Hrvatska kuhinja (A1.9, знахідний відмінок)

Слова: *pršut*, *paški sir*, *sarma*, *štrukli*, *fritule*, *peka*, *brudet*, *blitva*, *maslina*, *rakija*, *kremšnita*, *ćevapi*, *specijalitet*, *tartuf*

*У коноби / U konobi*

- Konobar: *Preporučujem specijalitet kuće: janjetinu ispod peke.* — Раджу фірмову страву: баранину під пекою.
- Taras: *Što je peka?* — Що таке пека?
- Konobar: *Meso i krumpir pečemo pod metalnim poklopcem, na žaru.* — М’ясо й картоплю печемо під металевою кришкою на жару.
- Taras: *Odlično, uzimam peku. A za predjelo?* — Чудово, беру пеку. А на закуску?
- Konobar: *Pršut, paški sir i masline.* — Пршут, паґський сир і оливки.
- Taras: *Može. I čašicu rakije na kraju!* — Можна. І чарочку ракії наприкінці!

*Що спробувати? / Što probati?*

- Olena: *Što moram probati u Hrvatskoj?* — Що я мушу спробувати в Хорватії?
- Ivan: *U Zagrebu štrukle, u Istri tartufe, a na moru brudet i blitvu.* — У Загребі штрукли, в Істрії трюфелі, а на морі брудет і мангольд.
- Olena: *A slatko?* — А солодке?
- Ivan: *Kremšnitu iz Samobora i fritule za Božić.* — Кремшніту із Самобора і фрітуле на Різдво.
- Olena: *A sarmu i ćevape?* — А сарму й чевапі?
- Ivan: *Sarmu zimi, a ćevape kad god želiš!* — Сарму взимку, а чевапі — коли захочеш!

- Вставте слово: *Moram probati ___ iz Samobora.* → **kremšnitu** (хибні: kremšnita, kremšnite, kremšniti)
- Складіть: «Раджу фірмову страву закладу.» → *Preporučujem specijalitet kuće.*
- Складіть: «Я люблю оливки й пршут.» → *Volim masline i pršut.*
- Скажіть уголос: *Jednu porciju ćevapa, molim.* (Одну порцію чевапі, будь ласка.); *Sarma je zimsko jelo.* (Сарма — це зимова страва.)

### Урок 78 — Національні парки / Nacionalni parkovi (A1.9, місцевий відмінок)

Слова: *nacionalni park*, *slap*, *jezero*, *šuma*, *staza*, *planinariti*, *priroda*, *park prirode*, *životinja*, *medvjed*, *zaštićen*, *vidikovac*, *brod*, *špilja*

*На Плітвіцьких озерах / Na Plitvičkim jezerima*

- Vodič: *Dobro došli u Nacionalni park Plitvička jezera!* — Ласкаво просимо до Національного парку Плітвіцькі озера!
- Andrij: *Koliko dugo traje obilazak?* — Скільки триває екскурсія?
- Vodič: *Ova staza traje četiri sata. Idemo pješice i brodom preko jezera.* — Цей маршрут триває чотири години. Ідемо пішки і кораблем через озеро.
- Andrij: *Gdje je najveći slap?* — Де найбільший водоспад?
- Vodič: *Na kraju staze. S vidikovca je pogled prekrasan.* — Наприкінці стежки. З оглядового майданчика вид чудовий.

*У горах / U planini*

- Ivan: *Vikendom planinarim na Velebitu. Ideš sa mnom?* — На вихідних ходжу в гори на Велебіт. Підеш зі мною?
- Taras: *Rado! Ima li u šumi medvjeda?* — Охоче! А в лісі є ведмеді?
- Ivan: *Ima, ali rijetko. Medvjed je zaštićena životinja.* — Є, але рідко. Ведмідь — захищена тварина.
- Taras: *A što još vidimo?* — А що ще побачимо?
- Ivan: *Jednu veliku špilju. Priroda je tamo divna.* — Одну велику печеру. Природа там чудова.

- Вставте слово: *Medvjedi žive u ___.* → **šumi** (хибні: šuma, šumu, šume)
- Складіть: «Ця стежка веде до озера.» → *Ova staza vodi do jezera.*
- Складіть: «З оглядового майданчика видно водоспад.» → *S vidikovca vidimo slap.*
- Скажіть уголос: *Velebit je park prirode.* (Велебіт — природний парк.); *U špilji je hladno.* (У печері холодно.)

### Урок 79 — Старе місто / Stari grad (A1.9, ступені порівняння)

Слова: *zidine*, *palača*, *katedrala*, *toranj*, *luka*, *riva*, *stara jezgra*, *spomenik*, *znamenitost*, *kula*, *razgledati*, *turistički vodič*, *stoljeće*, *povijest*

*У Дубровнику / U Dubrovniku*

- Vodička: *Ovo su gradske zidine iz trinaestog stoljeća.* — Це міські мури тринадцятого століття.
- Oksana: *Jesu li duže od zidina u Stonu?* — Вони довші за мури в Стоні?
- Vodička: *Ne, zidine u Stonu su duže, ali ove su poznatije.* — Ні, мури в Стоні довші, але ці відоміші.
- Oksana: *Možemo li se popeti na kulu?* — Можна піднятися на вежу?
- Vodička: *Možete. S kule je najljepši pogled na luku.* — Можна. З вежі найкращий вид на порт.

*У Спліті / U Splitu*

- Andrij: *Koja je najvažnija znamenitost Splita?* — Яка найголовніша пам’ятка Спліта?
- Turistički vodič: *Dioklecijanova palača. Stara je oko sedamnaest stoljeća.* — Палац Діоклетіана. Йому близько сімнадцяти століть.
- Andrij: *A katedrala?* — А собор?
- Turistički vodič: *U palači je. Toranj katedrale je viši od svih zgrada u staroj jezgri.* — Він у палаці. Дзвіниця собору вища за всі будівлі в старому місті.
- Andrij: *Super! Prvo razgledamo palaču, a onda pijemo kavu na rivi.* — Чудово! Спочатку оглянемо палац, а потім вип’ємо кави на набережній.

- Вставте слово: *Zidine u Stonu su ___ od zidina u Dubrovniku.* → **duže** (хибні: dugo, duga, najduže)
- Складіть: «Сьогодні оглядаємо старе місто.» → *Danas razgledamo staru jezgru.*
- Складіть: «З вежі найкращий вид.» → *S kule je najljepši pogled.*
- Скажіть уголос: *Hrvatska ima dugu povijest.* (Хорватія має довгу історію.); *Spomenik je stariji od katedrale.* (Пам’ятник старіший за собор.)

### Урок 80 — Свята й неробочі дні / Blagdani i neradni dani (A1.9, присвійні займенники)

Слова: *Uskrs*, *Nova godina*, *Badnjak*, *Dan državnosti*, *neradni dan*, *vatromet*, *slavlje*, *misa*, *advent*, *pisanica*, *darivati*, *čestitka*, *okititi*, *bor*

*Різдво в Хорватії / Božić u Hrvatskoj*

- Marija: *Kako slavite Božić u vašoj obitelji?* — Як ви святкуєте Різдво у вашій родині?
- Olena: *Kod nas je Božić sada isto dvadeset petog prosinca. A vi?* — У нас Різдво тепер теж двадцять п’ятого грудня. А у вас?
- Marija: *Na Badnjak kitimo bor, a navečer idemo na misu.* — На Святвечір прикрашаємо ялинку, а ввечері йдемо на месу.
- Olena: *I mi darujemo djecu.* — І ми обдаровуємо дітей.
- Marija: *Naš advent u Zagrebu je prekrasan, dođite!* — Наш адвент у Загребі чудовий, приходьте!

*Неробочі дні / Neradni dani*

- Taras: *Radi li trgovina na Dan državnosti?* — Чи працює магазин у День державності?
- Ivan: *Ne, to je neradni dan. Trideseti svibnja.* — Ні, це неробочий день. Тридцяте травня.
- Taras: *A Nova godina? Gdje je najbolji vatromet?* — А Новий рік? Де найкращий феєрверк?
- Ivan: *Na trgu u centru. Slavlje traje do jutra!* — На площі в центрі. Святкування триває до ранку!
- Taras: *Super. A za Uskrs djeca boje pisanice, kao kod nas.* — Чудово. А на Великдень діти фарбують писанки, як у нас.

- Вставте слово: *Kako slavite Božić u ___ obitelji?* → **vašoj** (хибні: vaša, vašu, vaše)
- Складіть: «Наш адвент у Загребі чудовий.» → *Naš advent u Zagrebu je prekrasan.*
- Складіть: «Це неробочий день.» → *To je neradni dan.*
- Скажіть уголос: *Pišem čestitku baki.* (Я пишу листівку бабусі.); *Okiti bor s djecom!* (Прикрась ялинку з дітьми!)

### Урок 86 — Продовження перебування / Produljenje boravka (A1.10, родовий відмінок)

Слова: *produljenje*, *rješenje*, *boravište*, *prebivalište*, *ovjera*, *javni bilježnik*, *prijevod*, *sudski tumač*, *preslika*, *upravna pristojba*, *biljeg*, *važeći*, *istjecati*, *dozvola*

*Документи для продовження / Dokumenti za produljenje*

- Službenica: *Dozvola Vam istječe za mjesec dana. Trebate zahtjev za produljenje.* — Ваш дозвіл спливає через місяць. Потрібна заява на продовження.
- Oksana: *Koji su dokumenti potrebni?* — Які документи потрібні?
- Službenica: *Važeća putovnica, preslika putovnice i dokaz o prebivalištu ili boravištu.* — Чинний паспорт, копія паспорта й підтвердження місця проживання.
- Oksana: *A rodni list djeteta?* — А свідоцтво про народження дитини?
- Službenica: *Treba prijevod sudskog tumača. I platite upravnu pristojbu.* — Потрібен переклад присяжного перекладача. І сплатіть адміністративний збір.

*У нотаріуса / Kod javnog bilježnika*

- Andrij: *Dobar dan, trebam ovjeru potpisa.* — Добрий день, мені потрібно засвідчити підпис.
- Bilježnica: *Imate li osobni dokument?* — У вас є документ, що посвідчує особу?
- Andrij: *Imam putovnicu. Koliko košta ovjera?* — Є паспорт. Скільки коштує засвідчення?
- Bilježnica: *Nekoliko eura. Ovjeru dobivate odmah.* — Кілька євро. Засвідчення отримаєте одразу.
- Andrij: *Hvala. Rješenje o boravku čekam već dva mjeseca.* — Дякую. Рішення про перебування я чекаю вже два місяці.

- Вставте слово: *Trebate presliku ___.* → **putovnice** (хибні: putovnica, putovnicu, putovnici)
- Складіть: «Мій дозвіл спливає в березні.» → *Moja dozvola istječe u ožujku.*
- Складіть: «Потрібен переклад присяжного перекладача.» → *Treba prijevod sudskog tumača.*
- Скажіть уголос: *Gdje mogu kupiti biljeg?* (Де можна купити гербову марку?); *Predajem zahtjev za produljenje boravka.* (Подаю заяву на продовження перебування.)

### Урок 87 — Навчання й мовні курси / Učenje jezika (A1.10, неправильні дієслова)

Слова: *nastava*, *razina*, *ispit*, *svjedodžba*, *diploma*, *priznavanje*, *fakultet*, *predavanje*, *učionica*, *polagati*, *gradivo*, *vježba*, *ocjena*, *rječnik*

*Курс хорватської / Tečaj hrvatskoga*

- Profesorica: *Dobro došli! Ovo je razina A1. Nastava je ponedjeljkom i srijedom.* — Ласкаво просимо! Це рівень A1. Заняття по понеділках і середах.
- Oksana: *Trebam li rječnik?* — Мені потрібен словник?
- Profesorica: *Ne, sve gradivo dobivate od mene. Doma pišete vježbe.* — Ні, весь матеріал отримуєте від мене. Вдома пишете вправи.
- Oksana: *Ima li na kraju ispit?* — А наприкінці є іспит?
- Profesorica: *Ima. Ako ga položite, dobivate svjedodžbu.* — Є. Якщо складете, отримаєте свідоцтво.

*Визнання диплома / Priznavanje diplome*

- Andrij: *Želim raditi kao inženjer. Treba li mi priznavanje diplome?* — Хочу працювати інженером. Мені потрібне визнання диплома?
- Službenica: *Treba. Donesite diplomu i prijevod.* — Потрібне. Принесіть диплом і переклад.
- Andrij: *Jesu li potrebne i ocjene s fakulteta?* — Потрібні також оцінки з університету?
- Službenica: *Jesu, i popis predavanja.* — Так, і перелік предметів.
- Andrij: *Dobro. Idem po dokumente.* — Добре. Піду по документи.

- Вставте слово: *Sutra ___ ispit iz hrvatskog.* → **polažem** (хибні: polagam, polažim, polagati)
- Складіть: «Заняття починаються о восьмій.» → *Nastava počinje u osam.*
- Складіть: «Я хочу вищий рівень.» → *Želim višu razinu.*
- Скажіть уголос: *Naša učionica je na drugom katu.* (Наш клас на другому поверсі.); *Idem na predavanje.* (Я йду на лекцію.)

### Урок 88 — Надзвичайні ситуації / Hitne situacije (A1.10, заперечення)

Слова: *požar*, *vatrogasac*, *dim*, *poplava*, *potres*, *evakuacija*, *opasnost*, *sklonište*, *upozorenje*, *spasiti*, *gorjeti*, *uzbuna*, *baterijska svjetiljka*, *izlaz u nuždi*

*Пожежа! / Požar!*

- Susjed: *Osjećate li dim? Nešto gori!* — Відчуваєте дим? Щось горить!
- Olena: *Gori u podrumu! Zovite 112!* — Горить у підвалі! Дзвоніть 112!
- Susjed: *Ne koristite dizalo! Idemo stepenicama.* — Не користуйтеся ліфтом! Ідемо сходами.
- Olena: *Gdje je izlaz u nuždi?* — Де аварійний вихід?
- Susjed: *Ondje, lijevo. Vatrogasci već dolaze.* — Там, ліворуч. Пожежники вже їдуть.

*Сирена й землетрус / Uzbuna i potres*

- Ivana: *Čuješ li sirenu? To je samo proba uzbune, svake prve subote u mjesecu.* — Чуєш сирену? Це лише перевірка сигналу тривоги, щопершої суботи місяця.
- Taras: *Dobro. A što radimo kod potresa?* — Добре. А що робимо під час землетрусу?
- Ivana: *Ne bježi van! Sakrij se ispod stola, dalje od prozora.* — Не вибігай надвір! Сховайся під стіл, подалі від вікон.
- Taras: *Trebamo li imati baterijsku svjetiljku i vodu?* — Нам треба мати ліхтарик і воду?
- Ivana: *Da. I pratite upozorenja na mobitelu.* — Так. І стежте за попередженнями на телефоні.

- Вставте слово: *___ koristite dizalo za vrijeme požara!* → **Ne** (хибні: Nije, Nemojte, Nema)
- Складіть: «Пожежники рятують людей.» → *Vatrogasci spašavaju ljude.*
- Складіть: «Тут немає небезпеки.» → *Ovdje nema opasnosti.*
- Скажіть уголос: *Za vrijeme poplave ne vozi auto.* (Під час повені не їдь машиною.); *Gdje je najbliže sklonište?* (Де найближче укриття?)

### Урок 89 — Нове життя в Хорватії / Novi život u Hrvatskoj (A1.10, сполучники)

Слова: *razlika*, *sličan*, *različit*, *naviknuti se*, *domovina*, *savjet*, *prednost*, *nedostatak*, *mentalitet*, *strpljiv*, *ljubazan*, *opušten*, *zajednica*, *nada*

*Різниця / Razlike*

- Ivan: *Koja je najveća razlika između Ukrajine i Hrvatske?* — Яка найбільша різниця між Україною і Хорватією?
- Olena: *Ljudi su ovdje opušteni, a kod nas svi žure.* — Люди тут розслаблені, а в нас усі поспішають.
- Ivan: *A jezik? Je li sličan ukrajinskom?* — А мова? Схожа на українську?
- Olena: *Sličan je, ali i jako različit. Treba biti strpljiv.* — Схожа, але й дуже відмінна. Треба бути терплячим.
- Ivan: *Polako se navikneš na sve.* — Поступово звикаєш до всього.

*Порада новачкові / Savjet za nove*

- Taras: *Moja sestra dolazi u Hrvatsku. Imaš li neki savjet?* — Моя сестра приїжджає до Хорватії. Маєш якусь пораду?
- Oksana: *Neka uči jezik i upoznaje ljude, jer je to najveća prednost.* — Нехай учить мову і знайомиться з людьми, бо це найбільша перевага.
- Taras: *A nedostaci?* — А недоліки?
- Oksana: *Papiri traju dugo. Ali ljudi su ljubazni, a ukrajinska zajednica je velika.* — Документи оформлюються довго. Але люди привітні, а українська громада велика.
- Taras: *Hvala! Domovina joj nedostaje, ali ima nadu.* — Дякую! Їй бракує батьківщини, але вона має надію.

- Вставте слово: *Jezik je sličan, ___ i jako različit.* → **ali** (хибні: jer, ili, da)
- Складіть: «Люди тут привітні й розслаблені.» → *Ljudi su ovdje ljubazni i opušteni.*
- Складіть: «Яка найбільша перевага?» → *Koja je najveća prednost?*
- Скажіть уголос: *Mentalitet je ovdje drukčiji.* (Менталітет тут інший.); *Navikavam se na novi život.* (Я звикаю до нового життя.)

## Вправи на слова (згенеровано з перекладів бази)

| Урок | Тип | Завдання | Відповідь | Варіанти |
|---|---|---|---|---|
| 6 | multiple_choice | Що означає «san»? | сон | відпочилий · сон · тиша · мріяти, бачити сни |
| 6 | multiple_choice | Що означає «leći»? | лягти | лягти · хропіти · відпочилий · простирадло |
| 6 | multiple_choice | Як хорватською «дрімати»? | drijemati | san · drijemati · hrkati · zvoniti |
| 6 | type_answer | Напишіть хорватською: «хропіти» | hrkati |  |
| 6 | type_answer | Напишіть хорватською: «безсоння» | nesanica |  |
| 7 | multiple_choice | Що означає «igračka»? | іграшка | іграшка · купати · няня · сміятися |
| 7 | multiple_choice | Що означає «ljuljačka»? | гойдалка | пісок · гойдалка · няня · іграшка |
| 7 | multiple_choice | Як хорватською «купати»? | kupati | dječja kolica · kupati · smijati se · crtić |
| 7 | type_answer | Напишіть хорватською: «няня» | dadilja |  |
| 7 | type_answer | Напишіть хорватською: «сміятися» | smijati se |  |
| 8 | multiple_choice | Що означає «štene»? | цуценя | кошеня · годувати · ветеринар · цуценя |
| 8 | multiple_choice | Що означає «povodac»? | повідець | цуценя · мисочка · повідець · ветеринар |
| 8 | multiple_choice | Як хорватською «кошеня»? | mačić | mačić · dlaka · kućni ljubimac · zdjelica |
| 8 | type_answer | Напишіть хорватською: «хвіст» | rep |  |
| 8 | type_answer | Напишіть хорватською: «вакцинувати» | cijepiti |  |
| 9 | multiple_choice | Що означає «tjedno»? | щотижня; на тиждень | відкласти · розклад · щотижня; на тиждень · скасувати |
| 9 | multiple_choice | Що означає «kalendar»? | календар | обов'язок; справа · домовитися · розклад · календар |
| 9 | multiple_choice | Як хорватською «домовитися»? | dogovoriti se | odgoditi · dogovoriti se · obveza · dvaput |
| 9 | type_answer | Напишіть хорватською: «двічі» | dvaput |  |
| 9 | type_answer | Напишіть хорватською: «відкласти» | odgoditi |  |
| 15 | multiple_choice | Що означає «med»? | мед | пластівці · салямі · цільнозерновий · мед |
| 15 | multiple_choice | Що означає «tost»? | тост | сосиска; ковбаска · тост · какао · пластівці |
| 15 | multiple_choice | Як хорватською «джем; повидло»? | pekmez | pekmez · keks · kajgana · salama |
| 15 | type_answer | Напишіть хорватською: «цільнозерновий» | integralni |  |
| 15 | type_answer | Напишіть хорватською: «пончик» | krafna |  |
| 16 | multiple_choice | Що означає «tava»? | сковорідка | смажити · додати · розігріти; нагріти · сковорідка |
| 16 | multiple_choice | Що означає «miješati»? | мішати; перемішувати | кришка · каструля · розігріти; нагріти · мішати; перемішувати |
| 16 | multiple_choice | Як хорватською «смажити»? | pržiti | oguliti · grah · kupus · pržiti |
| 16 | type_answer | Напишіть хорватською: «пекти; запікати» | peći |  |
| 16 | type_answer | Напишіть хорватською: «кришка» | poklopac |  |
| 17 | multiple_choice | Що означає «odrezak»? | відбивна; стейк | ринок риби · відбивна; стейк · фарш · баранина (ягнятина) |
| 17 | multiple_choice | Що означає «mljeveno meso»? | фарш | фарш · яловичина · баранина (ягнятина) · відбивна; стейк |
| 17 | multiple_choice | Як хорватською «філе»? | file | ribarnica · mesnica · file · janjetina |
| 17 | type_answer | Напишіть хорватською: «мідія» | dagnja |  |
| 17 | type_answer | Напишіть хорватською: «кальмар» | lignja |  |
| 18 | multiple_choice | Що означає «pladanj»? | таця | запечений; смажений (у духовці) · їдальня · варений · таця |
| 18 | multiple_choice | Що означає «varivo»? | рагу (густа страва з овочів) | рагу (густа страва з овочів) · денне меню · порція · таця |
| 18 | multiple_choice | Як хорватською «перекус / пізній сніданок»? | marenda | gablec · marenda · dnevni meni · prilog |
| 18 | type_answer | Напишіть хорватською: «горошок» | grašak |  |
| 18 | type_answer | Напишіть хорватською: «гарнір» | prilog |  |
| 24 | multiple_choice | Що означає «vuna»? | вовна | непромокальний · спідниця · рукавички · вовна |
| 24 | multiple_choice | Що означає «čarape»? | шкарпетки | светр · тонкий · спідниця · шкарпетки |
| 24 | multiple_choice | Як хорватською «спідниця»? | suknja | tanak · suknja · džemper · vuna |
| 24 | type_answer | Напишіть хорватською: «непромокальний» | nepromočiv |  |
| 24 | type_answer | Напишіть хорватською: «тонкий» | tanak |  |
| 25 | multiple_choice | Що означає «ladica»? | шухляда | шухляда · постільна білизна · широкий · завіса, штора |
| 25 | multiple_choice | Що означає «širok»? | широкий | столик · постільна білизна · широкий · гвинт; шуруп |
| 25 | multiple_choice | Як хорватською «вузький»? | uzak | širok · uzak · zavjesa · stolić |
| 25 | type_answer | Напишіть хорватською: «гвинт; шуруп» | vijak |  |
| 25 | type_answer | Напишіть хорватською: «монтувати; встановлювати» | montirati |  |
| 26 | multiple_choice | Що означає «ispravan»? | справний | вимкнути; виключити · кабель · екран; дисплей · справний |
| 26 | multiple_choice | Що означає «kabel»? | кабель | кабель · навушники · планшет · батарея / акумулятор |
| 26 | multiple_choice | Як хорватською «планшет»? | tablet | ekran · tablet · bežični · isključiti |
| 26 | type_answer | Напишіть хорватською: «миша» | miš |  |
| 26 | type_answer | Напишіть хорватською: «клавіатура» | tipkovnica |  |
| 27 | multiple_choice | Що означає «pratiti»? | стежити, супроводжувати | післяплатою · кур’єр · стежити, супроводжувати · покупець |
| 27 | multiple_choice | Що означає «narudžba»? | замовлення | повернення грошей · інтернет-магазин · упаковка · замовлення |
| 27 | multiple_choice | Як хорватською «кур’єр»? | kurir | pouzećem · kupac · pakiranje · kurir |
| 27 | type_answer | Напишіть хорватською: «доставка» | dostava |  |
| 27 | type_answer | Напишіть хорватською: «пошкоджений» | oštećen |  |
| 33 | multiple_choice | Що означає «pločnik»? | тротуар | шолом · тротуар · електричний · пішохід |
| 33 | multiple_choice | Що означає «kaciga»? | шолом | шолом · пішохід · гальмо · небезпечно |
| 33 | multiple_choice | Як хорватською «обережно; уважно»? | pažljivo | lanac · pažljivo · lokot · kaciga |
| 33 | type_answer | Напишіть хорватською: «гальмо» | kočnica |  |
| 33 | type_answer | Напишіть хорватською: «гальмувати» | kočiti |  |
| 34 | multiple_choice | Що означає «ograničenje brzine»? | обмеження швидкості | швидкість · обмеження швидкості · дорожній знак · напрямок |
| 34 | multiple_choice | Що означає «izlaz»? | вихід; виїзд | автомагістраль · вихід; виїзд · плата за проїзд (на магістралі) · зона відпочинку (на трасі) |
| 34 | multiple_choice | Як хорватською «пункт оплати проїзду»? | naplatna kućica | pretjecati · autocesta · cestarina · naplatna kućica |
| 34 | type_answer | Напишіть хорватською: «автомагістраль» | autocesta |  |
| 34 | type_answer | Напишіть хорватською: «об’їзна дорога» | obilaznica |  |
| 35 | multiple_choice | Що означає «motor»? | двигун | механік · фільтр · двигун · ремонт |
| 35 | multiple_choice | Що означає «popravak»? | ремонт | фільтр · коробка передач · механік · ремонт |
| 35 | multiple_choice | Як хорватською «звук»? | zvuk | zvuk · tehnički pregled · servis · motor |
| 35 | type_answer | Напишіть хорватською: «зчеплення» | kvačilo |  |
| 35 | type_answer | Напишіть хорватською: «сервіс; майстерня» | servis |  |
| 36 | multiple_choice | Що означає «sjedalo»? | сидіння; місце | сидіння; місце · маршрут; напрямок (рейсу) · автовокзал · відправлення |
| 36 | multiple_choice | Що означає «noćni»? | нічний | багажне відділення · міжміський · нічний · зав’язувати; пристібати |
| 36 | multiple_choice | Як хорватською «зав’язувати; пристібати»? | vezati | presjedanje · prtljažni prostor · vezati · pojas |
| 36 | type_answer | Напишіть хорватською: «міжміський» | međugradski |  |
| 36 | type_answer | Напишіть хорватською: «пересадка (на транспорті)» | presjedanje |  |
| 41 | multiple_choice | Що означає «selidba»? | переїзд | переїзд · носити / одягати · коробка · порожній |
| 41 | multiple_choice | Що означає «lomljiv»? | крихкий | здати, передати · переїзд · транспорт; перевезення · крихкий |
| 41 | multiple_choice | Як хорватською «мікроавтобус; бус»? | kombi | kombi · predati · nositi · iseliti se |
| 41 | type_answer | Напишіть хорватською: «переїжджати» | seliti se |  |
| 41 | type_answer | Напишіть хорватською: «носити / одягати» | nositi |  |
| 42 | multiple_choice | Що означає «kućni red»? | правила будинку | правила будинку · спокій; мир · сушити · підвал |
| 42 | multiple_choice | Що означає «dopušteno»? | дозволено | дозволено · сушити · поважати · вхід; під’їзд |
| 42 | multiple_choice | Як хорватською «спільний»? | zajednički | pravilo · zabranjeno · zajednički · ulaz |
| 42 | type_answer | Напишіть хорватською: «сушити» | sušiti |  |
| 42 | type_answer | Напишіть хорватською: «підвал» | podrum |  |
| 43 | multiple_choice | Що означає «plijesan»? | пліснява | термостат · споживання; витрати · ступінь, градус · пліснява |
| 43 | multiple_choice | Що означає «termostat»? | термостат | радіатор; батарея (опалення) · пліснява · лічильник · термостат |
| 43 | multiple_choice | Як хорватською «вологість; сирість»? | vlaga | peć · klima · potrošnja · vlaga |
| 43 | type_answer | Напишіть хорватською: «дрова» | drva |  |
| 43 | type_answer | Напишіть хорватською: «піч; обігрівач» | peć |  |
| 44 | multiple_choice | Що означає «ličiti»? | фарбувати (стіни) | фарбувати (стіни) · стеля · інструмент · повісити |
| 44 | multiple_choice | Що означає «strop»? | стеля | стеля · фарбувати (стіни) · інструмент · цвях |
| 44 | multiple_choice | Як хорватською «стіна»? | zid | pločica · zid · objesiti · brtva |
| 44 | type_answer | Напишіть хорватською: «кран (водопровідний)» | slavina |  |
| 44 | type_answer | Напишіть хорватською: «капати» | kapati |  |
| 50 | multiple_choice | Що означає «zidar»? | муляр; будівельник | муляр; будівельник · склад · електрик · будівельний майданчик |
| 50 | multiple_choice | Що означає «sobarica»? | покоївка | будівельний майданчик · покоївка · перукарка · робітник |
| 50 | multiple_choice | Як хорватською «комірник; працівник складу»? | skladištar | frizerka · vodoinstalater · blagajnica · skladištar |
| 50 | type_answer | Напишіть хорватською: «прибиральниця» | čistačica |  |
| 50 | type_answer | Напишіть хорватською: «кухар» | kuhar |  |
| 51 | multiple_choice | Що означає «preporuka»? | рекомендація | постійний · зареєструватися; подати заявку · рекомендація · умова |
| 51 | multiple_choice | Що означає «nezaposlen»? | безробітний | оплачуваний; оплачений · погодинна оплата · роботодавець · безробітний |
| 51 | multiple_choice | Як хорватською «постійний»? | stalan | prijaviti se · životopis · sezonski · stalan |
| 51 | type_answer | Напишіть хорватською: «умова» | uvjet |  |
| 51 | type_answer | Напишіть хорватською: «зареєструватися; подати заявку» | prijaviti se |  |
| 52 | multiple_choice | Що означає «sigurnost»? | безпека | команда · безпека · перерва · завдання |
| 52 | multiple_choice | Що означає «radna odjeća»? | робочий одяг | шафка · керівник, ведучий · відповідальний · робочий одяг |
| 52 | multiple_choice | Як хорватською «інструкції»? | upute | radna odjeća · voditelj · upute · ormarić |
| 52 | type_answer | Напишіть хорватською: «точний; пунктуальний» | točan |  |
| 52 | type_answer | Напишіть хорватською: «відповідальний» | odgovoran |  |
| 53 | multiple_choice | Що означає «ispisati»? | роздрукувати | папір · роздрукувати · видалити · принтер |
| 53 | multiple_choice | Що означає «odgovoriti»? | відповісти | принтер · відповісти · копіювати · переслати |
| 53 | multiple_choice | Як хорватською «копіювати»? | kopirati | kopirati · skenirati · papir · proslijediti |
| 53 | type_answer | Напишіть хорватською: «таблиця» | tablica |  |
| 53 | type_answer | Напишіть хорватською: «переслати» | proslijediti |  |
| 59 | multiple_choice | Що означає «rana»? | рана | набряклий; опухлий · кров · підвернути; вивихнути · рана |
| 59 | multiple_choice | Що означає «flaster»? | пластир | приймальне відділення (невідкладна допомога) · підвернути; вивихнути · травмуватися; поранитися · пластир |
| 59 | multiple_choice | Як хорватською «кров»? | krv | modrica · krv · flaster · slomiti |
| 59 | type_answer | Напишіть хорватською: «травма» | ozljeda |  |
| 59 | type_answer | Напишіть хорватською: «травмуватися; поранитися» | ozlijediti se |  |
| 60 | multiple_choice | Що означає «pretraga»? | обстеження; аналіз | записатися (на прийом) · обстеження; аналіз · лабораторія · тиск |
| 60 | multiple_choice | Що означає «ultrazvuk»? | ультразвук (УЗД) | записатися (на прийом) · вимірювати · ультразвук (УЗД) · зал очікування |
| 60 | multiple_choice | Як хорватською «записатися (на прийом)»? | naručiti se | čekaonica · tlak · naručiti se · mjeriti |
| 60 | type_answer | Напишіть хорватською: «рентген» | rendgen |  |
| 60 | type_answer | Напишіть хорватською: «натщесерце» | natašte |  |
| 61 | multiple_choice | Що означає «težina»? | вага, складність | правильне харчування · гладшати; набирати вагу · вага, складність · регулярно |
| 61 | multiple_choice | Що означає «redovito»? | регулярно | регулярно · дієта · тренуватися; виконувати вправи · алкоголь |
| 61 | multiple_choice | Як хорватською «куріння»? | pušenje | pravilna prehrana · pušenje · težina · redovito |
| 61 | type_answer | Напишіть хорватською: «худнути» | mršaviti |  |
| 61 | type_answer | Напишіть хорватською: «алкоголь» | alkohol |  |
| 62 | multiple_choice | Що означає «curiti»? | текти; протікати | текти; протікати · краплі · немовля · ніс |
| 62 | multiple_choice | Що означає «kihati»? | чхати | термометр · пронос; діарея · чхати · краплі |
| 62 | multiple_choice | Як хорватською «педіатр»? | pedijatar | osip · pedijatar · proljev · kašljati |
| 62 | type_answer | Напишіть хорватською: «висип» | osip |  |
| 62 | type_answer | Напишіть хорватською: «запалення» | upala |  |
| 68 | multiple_choice | Що означає «vjenčanje»? | весілля | каблучка · дівчина · весілля · річниця |
| 68 | multiple_choice | Що означає «rastati se»? | розлучитися; розійтися | весілля · партнер · гарний (на вигляд); привабливий · розлучитися; розійтися |
| 68 | multiple_choice | Як хорватською «поцілунок»? | poljubac | poljubac · spoj · prsten · vjenčanje |
| 68 | type_answer | Напишіть хорватською: «каблучка» | prsten |  |
| 68 | type_answer | Напишіть хорватською: «обійми» | zagrljaj |  |
| 69 | multiple_choice | Що означає «gol»? | гол | команда (спортивна) · м'яч · гол · перемогти |
| 69 | multiple_choice | Що означає «izgubiti»? | загубити; втратити; програти | волейбол · гандбол · баскетбол · загубити; втратити; програти |
| 69 | multiple_choice | Як хорватською «волейбол»? | odbojka | odbojka · izgubiti · trening · pobijediti |
| 69 | type_answer | Напишіть хорватською: «гандбол» | rukomet |  |
| 69 | type_answer | Напишіть хорватською: «гравець» | igrač |  |
| 70 | multiple_choice | Що означає «festival»? | фестиваль | розпроданий · виступ · фестиваль · публіка |
| 70 | multiple_choice | Що означає «kazalište»? | театр | галерея · театр · гурт (музичний) · вистава |
| 70 | multiple_choice | Як хорватською «гурт (музичний)»? | bend | predstava · bend · koncert · publika |
| 70 | type_answer | Напишіть хорватською: «публіка» | publika |  |
| 70 | type_answer | Напишіть хорватською: «галерея» | galerija |  |
| 71 | multiple_choice | Що означає «privatan»? | приватний | коментар · прочитати · соціальні мережі · приватний |
| 71 | multiple_choice | Що означає «video»? | відео | профіль · група · відео · відповідь |
| 71 | multiple_choice | Як хорватською «соціальні мережі»? | društvene mreže | privatan · vijest · društvene mreže · objaviti |
| 71 | type_answer | Напишіть хорватською: «прочитати» | pročitati |  |
| 71 | type_answer | Напишіть хорватською: «ділитися» | dijeliti |  |
| 77 | multiple_choice | Що означає «sarma»? | сарма (голубці з квашеної капусти) | сарма (голубці з квашеної капусти) · пека (страва під залізною кришкою на жару) · паґський сир (овечий, з острова Паґ) · пршут (в’ялена шинка) |
| 77 | multiple_choice | Що означає «tartuf»? | трюфель | трюфель · фірмова страва; специалітет · ракія (фруктовий самогон) · фрітуле (маленькі пончики) |
| 77 | multiple_choice | Як хорватською «мангольд»? | blitva | paški sir · blitva · sarma · maslina |
| 77 | type_answer | Напишіть хорватською: «оливка» | maslina |  |
| 77 | type_answer | Напишіть хорватською: «фрітуле (маленькі пончики)» | fritule |  |
| 78 | multiple_choice | Що означає «brod»? | корабель | природа · природний парк · стежка; доріжка · корабель |
| 78 | multiple_choice | Що означає «šuma»? | ліс | озеро · ліс · природний парк · тварина |
| 78 | multiple_choice | Як хорватською «природа»? | priroda | jezero · priroda · nacionalni park · slap |
| 78 | type_answer | Напишіть хорватською: «водоспад» | slap |  |
| 78 | type_answer | Напишіть хорватською: «тварина» | životinja |  |
| 79 | multiple_choice | Що означає «znamenitost»? | визначна пам'ятка | порт · набережна · собор · визначна пам'ятка |
| 79 | multiple_choice | Що означає «razgledati»? | оглядати (пам’ятки) | туристичний гід · оглядати (пам’ятки) · старе місто · історія |
| 79 | multiple_choice | Як хорватською «палац»? | palača | razgledati · turistički vodič · kula · palača |
| 79 | type_answer | Напишіть хорватською: «століття» | stoljeće |  |
| 79 | type_answer | Напишіть хорватською: «набережна» | riva |  |
| 80 | multiple_choice | Що означає «slavlje»? | святкування | меса (церковна служба) · писанка · святкування · Святвечір (24 грудня) |
| 80 | multiple_choice | Що означає «Badnjak»? | Святвечір (24 грудня) | Святвечір (24 грудня) · меса (церковна служба) · сосна; ялинка (різдвяна) · неробочий день |
| 80 | multiple_choice | Як хорватською «сосна; ялинка (різдвяна)»? | bor | vatromet · Badnjak · Uskrs · bor |
| 80 | type_answer | Напишіть хорватською: «писанка» | pisanica |  |
| 80 | type_answer | Напишіть хорватською: «меса (церковна служба)» | misa |  |
| 86 | multiple_choice | Що означає «preslika»? | копія (ксерокопія) | місце постійного проживання · засвідчення (підпису, копії) · продовження (терміну) · копія (ксерокопія) |
| 86 | multiple_choice | Що означає «sudski tumač»? | присяжний перекладач | засвідчення (підпису, копії) · присяжний перекладач · чинний; дійсний · гербова марка (збір) |
| 86 | multiple_choice | Як хорватською «продовження (терміну)»? | produljenje | produljenje · upravna pristojba · rješenje · važeći |
| 86 | type_answer | Напишіть хорватською: «чинний; дійсний» | važeći |  |
| 86 | type_answer | Напишіть хорватською: «офіційне рішення» | rješenje |  |
| 87 | multiple_choice | Що означає «razina»? | рівень | диплом · свідоцтво; атестат · рівень · клас, аудиторія |
| 87 | multiple_choice | Що означає «vježba»? | вправа / тренування | клас, аудиторія · визнання · вправа / тренування · свідоцтво; атестат |
| 87 | multiple_choice | Як хорватською «визнання»? | priznavanje | nastava · predavanje · učionica · priznavanje |
| 87 | type_answer | Напишіть хорватською: «лекція» | predavanje |  |
| 87 | type_answer | Напишіть хорватською: «словник» | rječnik |  |
| 88 | multiple_choice | Що означає «poplava»? | повінь | ліхтарик · землетрус · повінь · небезпека |
| 88 | multiple_choice | Що означає «baterijska svjetiljka»? | ліхтарик | повінь · ліхтарик · горіти · евакуація |
| 88 | multiple_choice | Як хорватською «сховище / укриття»? | sklonište | gorjeti · uzbuna · sklonište · potres |
| 88 | type_answer | Напишіть хорватською: «землетрус» | potres |  |
| 88 | type_answer | Напишіть хорватською: «пожежа» | požar |  |
| 89 | multiple_choice | Що означає «razlika»? | різниця | різниця · батьківщина · менталітет · надія |
| 89 | multiple_choice | Що означає «ljubazan»? | ввічливий; добрий | ввічливий; добрий · схожий · різний; відмінний · недолік; нестача |
| 89 | multiple_choice | Як хорватською «схожий»? | sličan | opušten · domovina · sličan · savjet |
| 89 | type_answer | Напишіть хорватською: «терплячий» | strpljiv |  |
| 89 | type_answer | Напишіть хорватською: «звикнути» | naviknuti se |  |
