# Базові слова, нові правила, довші пояснення — що варто глянути носію · 2026-11-04

Пакет: `supabase/data_fixes/20261104_core_words_grammar.sql` (генератор — `scripts/gen_core_words_grammar_20261104.py`,
дані — `scripts/core_words_grammar_20261104_data.py`), тест — `supabase/tests/core_words_grammar.test.sql`.
За аудитом `content/reviews/2026-11-04_a0_a1_audit.md` і рішеннями власника 2026-11-04 (1 — cefr = рівень уроку, 2 — базові слова в уроки).

**Що змінено (бета, як A0 / A1):**

1. **34 базові слова** — у списки слів уроків, де вони вже звучать у діалогах (*slušati* і нове *vrlo* — у тематичні «Хобі» й «Корисні слова»).
   Нові в словнику: *svaki*, *vrlo*. Виправлено: *dom* («гуртожиток» → «дім, оселя; заклад…»), *roditelj*, *jer*, *trebati*, *kao*, *dok*, *ili*,
   приклади-словосполучення (*Lak test iz hrvatskog.* → *Ovaj test je lak.*), по другому прикладу дієсловам.
2. **3 нові правила:** *grad → gradovi* (A0 «Rod, množina»), *ruka — u ruci* (A1 «Lokativ»), *kod nas, o tebi* (A1 «Genitiv»).
3. **101 правило A0 / A1:** пояснення 150–320 знаків, у кожному щонайменше 4 приклади; виправлено помилки в прикладах:
   у «Дієслова на -am» стояло *Gdje radiš?* (це -im), у «Дієслова на -im» — *Kada ručaš?* (це -am) — поміняно місцями;
   у «Кличний: множина» — «збігається з називним: *Djeco!*» → пояснено винятки *Djeco!*, *Gospodo!*.
4. **Мітка `cefr`** 692 слів (у робочій базі — до ≈ 1020) = рівень уроку, де слово вперше вчать.

**Носію — окремо:**

- **«Instrumental» A1, правило «Pred, pod, nad, između + орудний»:** у хорватській нормі *između* зазвичай з родовим (*između kuće i škole*);
  з орудним — розмовно / сербська норма. Пакет це правило **не змінює** — потрібне рішення носія.
- Нові пояснення про норму: «*Gdje ideš?* — розмовно, правильно *Kamo ideš?*», «*Da li…?* — розмовно, у нормі дієслово + *li*»,
  «*želim da idem* — норма не радить, краще *Želim ići*», «розмовно *njen*, у нормі *njezin*» — чи так це подати?
- *ć* — «щось середнє між ч і ть», *đ* — «близький до дь»: чи зрозуміло для українця?

### Слова в уроки

| Урок | Слово | Переклад | Приклади |
|---|---|---|---|
| A0.1 Привітання та подяка | *puno* | багато | Ovdje ima puno ljudi. / Puno hvala na pomoći! |
| A0.1 Привітання та подяка | *tako* | так, таким чином | Nemoj tako brzo voziti! / Tako je, imaš pravo. |
| A0.1 Добрий день і до побачення | *vidjeti* | бачити | Ne vidim dobro. / Jesi li vidjela moje ključeve? |
| A0.1 Добрий день і до побачення | *čuti* | чути | Čuješ li me? / Ne čujem te dobro, govori glasnije. |
| A0.1 Вибачте, я не розумію | *reći* | сказати | Što si rekao? / Možete li mi reći gdje je pošta? |
| A0.1 Ввічливі слова | *ili* | або; чи | Kava ili čaj? / Platit ću karticom ili gotovinom. |
| A0.1 Ввічливі слова | *problem* | проблема | Imamo mali problem. / Nema problema. |
| A0.2 Як тебе звати? | *dobar* | хороший; добрий | Ovo je dobar restoran. / Kava je dobra. |
| A0.2 Як тебе звати? | *pisati* | писати | Pišem poruku prijatelju. / Kako se piše vaše prezime? |
| A0.2 Звідки ви? | *ali* | але | Razumijem, ali ne govorim. / Stan je mali, ali lijep. |
| A0.2 Питальні слова | *kada* | коли (також kad) | Kada počinje predavanje? / Javi mi kad stigneš. |
| A0.2 Ким ви працюєте? | *kao* | як; у ролі (radim kao — працюю ким) | Govoriš hrvatski kao pravi Hrvat! / Radim kao konobarica. |
| A0.2 Ким ви працюєте? | *možda* | можливо | Možda ću doći sutra. / Možda je u pravu. |
| A0.2 Як ви почуваєтеся? | *loš* | поганий | Danas je loše vrijeme. / Osjećam se loše. |
| A0.2 Як ви почуваєтеся? | *trebati* | потребувати; бути потрібним (treba mi — мені треба) | Trebam pomoć. / Što trebate? |
| A0.2 Як ви почуваєтеся? | *željeti* | бажати; хотіти | Što biste željeli popiti? / Želim ti sretan put! |
| A0.3 Приблизно, половина, відсотки | *sve* | усе | Sve je u redu. / Znam sve o tome. |
| A0.4 Місяці й пори року | *topao* | теплий | Danas je topao dan. / More je toplo u kolovozu. |
| A0.4 Свята й привітання | *važan* | важливий | Imam važan sastanak u uredu. / Obitelj mi je jako važna. |
| A0.5 Моя сім’я | *roditelj* | один із батьків; roditelji — батьки | Svaki roditelj želi najbolje za dijete. / Moji roditelji žive u Kijevu. |
| A0.5 Діти й друзі | *sjediti* | сидіти | Mogu li sjediti ovdje? / Djeca sjede za stolom. |
| A0.6 Моя квартира | *ako* | якщо | Ako želiš, idemo na kavu. / Ako pada kiša, ostajem kod kuće. |
| A1.1 Мій звичайний день | *čitati* | читати | Volim čitati knjige uvečer. / Ujutro čitam vijesti na mobitelu. |
| A1.1 Як часто? | *svaki* (нове) | кожен | Svaki dan idem na posao. / Svaka soba ima balkon. |
| A1.1 Як часто? | *trčati* | бігати | Trčim u parku svako jutro. |
| A1.1 З дитиною вдома | *gledati* | дивитися | Gledam televiziju svake večeri. / Djeca gledaju crtiće. |
| A1.1 Сон і відпочинок | *jer* | бо; тому що | Ne radim jer sam bolestan. / Idem kući jer je kasno. |
| A1.1 Корисні слова: навіть, саме, знову, ще не | *lak* | легкий | Ovaj test je lak. / Hrvatski nije lak, ali je lijep. |
| A1.1 Корисні слова: навіть, саме, знову, ще не | *vrlo* (нове) | дуже | Vrlo je lijepo vrijeme. / Hvala, vrlo ste ljubazni. |
| A1.6 Професії: хто де працює | *dom* | дім, оселя; заклад (dom za starije — будинок для літніх людей, dom zdravlja — поліклініка, studentski dom — гуртожиток) | Ona radi u domu za starije. / Studenti žive u studentskom domu. |
| A1.6 Мій робочий день | *razgovarati* | розмовляти | Moramo razgovarati. / Na pauzi razgovaram s kolegama. |
| A1.9 Хобі | *slušati* | слухати | Slušam glazbu u autu. / Koju glazbu voliš slušati? |
| A1.9 Хтось, щось, десь | *dok* | поки; доки | Čekaj me ovdje dok ne dođem. / Dok kuham, slušam radio. |
| A1.13 Нове життя: мої плани | *život* | життя | Život na moru je lijep. / Ovdje počinjem novi život. |

### Нові правила

**Rod, množina i posvojne zamjenice → Короткі слова: grad → gradovi**

Більшість односкладових іменників чоловічого роду в множині отримують -ovi: grad → gradovi, stol → stolovi, sin → sinovi, vlak → vlakovi. Якщо слово закінчується на м’який приголосний (č, ć, š, ž, đ, j, lj, nj), то -evi: muž → muževi, ključ → ključevi, broj → brojevi. «Gradi» чи «stoli» — помилка. Винятки: dan → dani, zub → zubi, konj → konji.

- *Svi stolovi su zauzeti.* — Усі столики зайняті.
- *Gdje su moji ključevi?* — Де мої ключі?
- *Vlakovi za Split su puni.* — Поїзди до Спліта переповнені.
- *Moji sinovi idu u školu.* — Мої сини ходять до школи.
- *Ovi brojevi nisu točni.* — Ці номери неправильні.

**Lokativ → Ruka — u ruci: зміна k, g, h**

Перед закінченням -i в місцевому (і давальному) відмінку жіночого роду k, g, h змінюються на c, z, s: ruka → u ruci, knjiga → u knjizi, Rijeka → u Rijeci, noga → na nozi. Так само, як в українському «рука — в руці, нога — на нозі». Винятки — деякі слова про людей і тварин: baka → baki, mačka → mački.

- *Živim u Rijeci.* — Я живу в Рієці.
- *Što imaš u ruci?* — Що в тебе в руці?
- *Čitam o tome u knjizi.* — Я читаю про це в книжці.
- *Na nozi imam flaster.* — На нозі в мене пластир.

**Genitiv: osnove → Od mene, kod nas, o tebi: займенники після прийменників**

Після прийменників особові займенники мають повні форми. Родовий (після od, do, kod, iz, bez): mene, tebe, njega, nje, nas, vas, njih — kod nas, od tebe, bez njega. Місцевий (після o, u, na, po): meni, tebi, njemu, njoj, nama, vama, njima — o meni, o njoj. Короткі форми (me, te, ga) після прийменника не вживаються.

- *Kod nas je danas toplo.* — У нас сьогодні тепло.
- *Ovo je poklon od mene.* — Це подарунок від мене.
- *Ne mogu bez tebe.* — Я не можу без тебе.
- *Što misliš o njemu?* — Що ти думаєш про нього?
- *Pričamo o tebi.* — Ми говоримо про тебе.

### Оновлені правила (нові приклади)

| Тема | Правило | Нове пояснення? | Нові / виправлені приклади |
|---|---|---|---|
| Osobne zamjenice i glagol BITI | Особові займенники (однина) | так | *On je moj brat.* — Він мій брат.; *Iz Kijeva sam.* — Я з Києва. |
| Osobne zamjenice i glagol BITI | Дієслово BITI (бути) - короткі форми | так | *Ja sam dobro.* — У мене все добре.; *Kako si?* — Як ти?; *Mi smo iz Ukrajine.* — Ми з України.; *Oni su u Zagrebu.* — Вони в Загребі. |
| Glagol imati | Imam, imaš, ima… | так | *Imamo mali stan.* — У нас маленька квартира.; *Ana ima dva psa.* — В Ани два собаки. |
| Glagol imati | Nemam, nemaš, nema… | так | *Danas nema autobusa.* — Сьогодні немає автобуса. |
| Glagol imati | Питання: дієслово + li | так | *Imate li sobu za dvije osobe?* — У вас є кімната на двох? |
| Pokazne zamjenice: ovaj, taj, onaj | Ovaj / ova / ovo — біля мене | так | *Ovaj autobus ide u centar.* — Цей автобус їде в центр. |
| Pokazne zamjenice: ovaj, taj, onaj | Taj / ta / to — біля співрозмовника | так | *Tko je to?* — Хто це? |
| Pokazne zamjenice: ovaj, taj, onaj | Onaj / ona / ono — далеко | так | *Vidiš li onu crkvu tamo?* — Бачиш он ту церкву? |
| Pridjevi: slaganje s imenicom | Перед іменником: -i / -a / -o | так | *Ovo je svježe mlijeko.* — Це свіже молоко. |
| Pridjevi: slaganje s imenicom | Після «je»: коротка форма | так | *Hotel je skup, ali dobar.* — Готель дорогий, але хороший. |
| Upitne riječi | Основні питання | так | *Kako se zoveš?* — Як тебе звати? |
| Upitne riječi | Де? Куди? Звідки? | так | *Kamo idemo večeras?* — Куди ми підемо сьогодні ввечері? |
| Upitne riječi | Коли ви не зрозуміли | так | *Oprostite, ne razumijem.* — Вибачте, я не розумію. |
| Gdje? Prijedlozi mjesta | U і na + місцевий відмінок | так | *Slika je na zidu.* — Картина на стіні. |
| Gdje? Prijedlozi mjesta | Ispod, iznad, pored + родовий відмінок | так | *Auto je ispred zgrade.* — Машина перед будинком. |
| Gdje? Prijedlozi mjesta | Ліворуч, праворуч, прямо | так | *Skrenite desno kod pošte.* — Поверніть праворуч біля пошти. |
| Persiranje: ti i Vi | Ti — своїм, Vi — незнайомим | так | *Možete li mi pomoći?* — Ви можете мені допомогти? |
| Persiranje: ti i Vi | Molim — на всі випадки | так | *Račun, molim.* — Рахунок, будь ласка. |
| Izgovor: hrvatska slova | Одна літера — один звук | так | *Hvala, cijena je dobra.* — Дякую, ціна хороша. |
| Izgovor: hrvatska slova | Č і Ć | так | *Laku noć, idem kući.* — На добраніч, я йду додому. |
| Izgovor: hrvatska slova | Š, Ž, Đ, Dž, Lj, Nj | так | *Moja žena voli šetati.* — Моя дружина любить гуляти. |
| Niječni i upitni oblici glagola biti | Заперечення: nisam, nisi, nije… | так | *Nisu kod kuće.* — Їх немає вдома. |
| Niječni i upitni oblici glagola biti | Питання з «li» | так | *Je li restoran otvoren?* — Ресторан відкритий? |
| Niječni i upitni oblici glagola biti | Коротка відповідь | так | *Imate li sobu? — Imamo.* — У вас є кімната? — Є.; *Je li Daša kod kuće? — Nije.* — Даша вдома? — Ні. |
| Brojevi od 0 do 100 | 0–10 | так | *Imam jednu sestru i dva brata.* — У мене одна сестра і два брати.; *Soba broj pet je slobodna.* — Кімната номер п’ять вільна. |
| Brojevi od 0 do 100 | 11–19: «-naest» | так | *Autobus dolazi za petnaest minuta.* — Автобус приїде за п’ятнадцять хвилин. |
| Brojevi od 0 do 100 | Десятки й сто | — | *To košta sto eura.* — Це коштує сто євро. |
| Brojevi od 0 do 100 | Число + іменник | так | *Dvije kave, molim.* — Дві кави, будь ласка. |
| Vrijeme: dani, sati, mjeseci | У який день? — u + день | так | *Subotom idemo na tržnicu.* — По суботах ми ходимо на ринок. |
| Vrijeme: dani, sati, mjeseci | Учора, сьогодні, завтра | так | *Vidimo se sutra navečer.* — Побачимося завтра ввечері. |
| Vrijeme: dani, sati, mjeseci | Котра година? О котрій? | так | *U koliko sati počinje film?* — О котрій починається фільм?; *Trgovina radi do osam sati.* — Магазин працює до восьмої. |
| Vrijeme: dani, sati, mjeseci | У якому місяці? — u + місцевий відмінок | так | *Škola počinje u rujnu.* — Школа починається у вересні. |
| Rod, množina i posvojne zamjenice | Три роди | так | *Moj brat živi u Splitu.* — Мій брат живе в Спліті.; *Sestra je u školi.* — Сестра в школі.; *More je toplo.* — Море тепле.; *Ovo je moj tata.* — Це мій тато. |
| Rod, množina i posvojne zamjenice | Мій / моя / моє | так | *Gdje je moj mobitel?* — Де мій мобільний? |
| Rod, množina i posvojne zamjenice | Множина | так | *Ljudi su ovdje ljubazni.* — Люди тут привітні. |
| Red riječi | Звичайний порядок | так | *U subotu idemo u kino.* — У суботу ми йдемо в кіно. |
| Red riječi | Короткі слова — на другому місці | так | *Danas sam kod kuće.* — Сьогодні я вдома. |
| Red riječi | Питання | так | *Zašto si tužan?* — Чому ти сумний? |
| Redni brojevi | Перший … десятий | — | *Ovo mi je prvi dan na poslu.* — Це мій перший день на роботі.; *Živim u drugoj ulici lijevo.* — Я живу на другій вулиці ліворуч. |
| Redni brojevi | Як прикметник | так | *Moj ured je na petom katu.* — Мій офіс на п’ятому поверсі. |
| Redni brojevi | Цифра з крапкою | так | *Ured je na 4. katu.* — Офіс на 4-му поверсі. |
| Veliki brojevi: stotine, tisuće, milijuni | Сотні | — | *Stan košta petsto eura mjesečno.* — Квартира коштує п’ятсот євро на місяць. |
| Veliki brojevi: stotine, tisuće, milijuni | Тисячі, мільйони, мільярди | — | *Zagreb ima oko osamsto tisuća stanovnika.* — У Загребі близько вісімсот тисяч жителів. |
| Veliki brojevi: stotine, tisuće, milijuni | Як читати довге число | так | *Telefon košta tisuću dvjesto eura.* — Телефон коштує тисячу двісті євро. |
| Veliki brojevi: stotine, tisuće, milijuni | Рахуємо вголос | так | *Treniram tri puta tjedno.* — Я тренуюся тричі на тиждень. |
| Veliki brojevi: stotine, tisuće, milijuni | Приблизно, частини, відсотки | — | *Popust je dvadeset posto.* — Знижка двадцять відсотків. |
| Vrijeme: bezlične rečenice | Холодно, тепло: прислівник + je | — | *Ljeti je u Splitu vruće.* — Влітку в Спліті спекотно. |
| Vrijeme: bezlične rečenice | Дощ «падає», вітер «дме» | так | *Puše jugo, more je nemirno.* — Дме юго, море неспокійне. |
| Vrijeme: bezlične rečenice | Було й буде: bilo je, bit će | так | *Prošli tjedan bilo je jako vruće.* — Минулого тижня було дуже спекотно. |
| Posvojne zamjenice | Мій, твій, наш, ваш | — | *Vaša putovnica, molim.* — Ваш паспорт, будь ласка. |
| Posvojne zamjenice | Його, її, їхній | — | *Njegov sin živi u Rijeci.* — Його син живе в Рієці. |
| Posvojne zamjenice | Svoj — «свій» | — | *Marko voli svoju ženu.* — Марко любить свою дружину. |
| Posvojne zamjenice | Чий? Чия? Чиє? | так | *Čije su ovo cipele?* — Чиї це черевики? |
| Komparativ: jeftiniji, skuplji | Дешевший, дорожчий: -iji і -ji | — | *Ovaj stan je jeftiniji.* — Ця квартира дешевша. |
| Komparativ: jeftiniji, skuplji | Дешевше, дорожче, більше | — | *Danas je sve skuplje.* — Сьогодні все дорожче. |
| Komparativ: jeftiniji, skuplji | Ніж: nego або od | — | *Vlak je brži od autobusa.* — Поїзд швидший за автобус. |
| Komparativ: jeftiniji, skuplji | Найдешевший: naj- | так | *Zagreb je najveći grad u Hrvatskoj.* — Загреб — найбільше місто Хорватії. |
| Što te boli? Boli me…, bole me… | Мене болить: boli me | — | *Boli ga glava.* — У нього болить голова. |
| Što te boli? Boli me…, bole me… | Болить чи болять: boli / bole | так | *Boli me noga.* — У мене болить нога. |
| Što te boli? Boli me…, bole me… | Що болить? Питання й заперечення | так | *Boli li vas ovdje?* — Вам тут болить? |
| Veznici | I, a, ali | так | *Volim more, ali ne volim vrućinu.* — Я люблю море, але не люблю спеку. |
| Veznici | Ili — або, чи | так | *Idemo autom ili vlakom?* — Їдемо машиною чи поїздом? |
| Veznici | Jer, zato što — бо, тому що | так | *Ne idem zato što sam umorna.* — Я не йду, бо втомилася.; *Zašto kasniš? — Zato što nema autobusa.* — Чому ти запізнюєшся? — Бо немає автобуса. |
| Pravilni glagoli | Інфінітив: -ti або -ći | так | *Moram kupiti kruh.* — Мені треба купити хліб. |
| Pravilni glagoli | Дієслово + інфінітив | так | *Znaš li plivati?* — Ти вмієш плавати? |
| Pravilni glagoli | Питання і заперечення | так | *Radite li u subotu? — Ne radimo.* — Ви працюєте в суботу? — Ні. |
| Česti nepravilni glagoli | Ići — іти, їхати | так | *Idemo na kavu!* — Ходімо на каву! |
| Česti nepravilni glagoli | Htjeti і moći | — | *Hoćete li još nešto?* — Бажаєте ще щось? |
| Česti nepravilni glagoli | Jesti і piti | — | *Pijete li kavu sa šećerom?* — Ви п’єте каву з цукром? |
| Akuzativ | Жіночий рід: -a → -u | так | *Trebam kartu za Split.* — Мені потрібен квиток до Спліта. |
| Akuzativ | Чоловічий рід: неживе не змінюється, живе → -a | так | *Tražim liječnika.* — Я шукаю лікаря. |
| Akuzativ | Займенники: me, te, ga, je | так | *Čekam tebe, a ne njega.* — Я чекаю тебе, а не його. |
| Prezent | Дієслова на -am: čitati | так | *Kada ručaš?* — Коли ти обідаєш?; *Čekamo autobus.* — Ми чекаємо автобус. |
| Prezent | Дієслова на -im: govoriti | так | *Gdje radiš?* — Де ти працюєш?; *Vidim more s balkona.* — Я бачу море з балкона. |
| Prezent | Дієслова на -em: pisati, piti, doručkovati | так | *Djeca piju sok.* — Діти п’ють сік. |
| Genitiv: osnove | Кількість + родовий | так | *Šalicu čaja, molim.* — Чашку чаю, будь ласка. |
| Genitiv: osnove | Nema + родовий | так | *Nemam novca kod sebe.* — У мене немає з собою грошей. |
| Genitiv: osnove | Iz, od, do, kod, preko puta + родовий | так | *Večeras smo kod prijatelja.* — Сьогодні ввечері ми в друзів. |
| Lokativ | Де? — u / na + місцевий | так | *Djeca su u vrtiću.* — Діти в садочку. |
| Lokativ | U чи na? | так | *Kupujem marke na pošti.* — Я купую марки на пошті. |
| Lokativ | O + місцевий: про кого, про що | так | *O čemu razgovarate?* — Про що ви розмовляєте? |
| Posvojne zamjenice | Naš, vaš | так | *Naši susjedi su iz Osijeka.* — Наші сусіди з Осієка. |
| Posvojne zamjenice | Njegov, njezin, njihov | так | *Njihov sin studira u Zagrebu.* — Їхній син навчається в Загребі. |
| Posvojne zamjenice | Čiji? — чий? | так | *Čiji su ovo ključevi?* — Чиї це ключі?; *Čije je ovo dijete?* — Чия це дитина? |
| Modalni glagoli | Moći — могти | так | *Možemo li sjesti ovdje?* — Можна нам сісти тут? |
| Modalni glagoli | Morati і trebati | так | *Treba mi tvoj broj.* — Мені потрібен твій номер. |
| Modalni glagoli | Smjeti — можна (дозвіл) | так | *Smijem li otvoriti prozor?* — Можна відчинити вікно? |
| Imperativ | Ти: -i / -j | так | *Uzmi kišobran, pada kiša.* — Візьми парасольку, іде дощ. |
| Imperativ | Ви: -ite / -jte | так | *Ispunite ovaj obrazac, molim.* — Заповніть цю форму, будь ласка. |
| Imperativ | Не роби: nemoj / nemojte + інфінітив | так | *Nemojte se brinuti, sve je u redu.* — Не хвилюйтеся, усе гаразд. |
| Komparacija pridjeva | Вищий ступінь: -iji, -ji | так | *Ova soba je tiša.* — Ця кімната тихіша. |
| Komparacija pridjeva | Ніж: nego | так | *Ovaj telefon je puno jeftiniji od onog.* — Цей телефон набагато дешевший за той. |
| Komparacija pridjeva | Найвищий ступінь: naj- | так | *Ljeto je najtoplije godišnje doba.* — Літо — найтепліша пора року.; *Ovo je najljepša plaža u Hrvatskoj.* — Це найкрасивіший пляж у Хорватії. |
| Upitne rečenice | Питання з li | так | *Možete li mi pokazati put?* — Можете показати мені дорогу? |
| Upitne rečenice | Питальні слова | так | *Kako se ovo kaže na hrvatskom?* — Як це сказати хорватською? |
| Upitne rečenice | Koji і kakav — який? | так | *Koja je tvoja omiljena boja?* — Який твій улюблений колір? |
| Nijekanje | Ne + дієслово | так | *Ne razumijem, možete li ponoviti?* — Не розумію, можете повторити? |
| Nijekanje | Nisam, nemam, neću, nema | так | *Danas nije hladno.* — Сьогодні не холодно. |
| Nijekanje | Подвійне заперечення | так | *Nigdje ne mogu naći ključeve.* — Я ніде не можу знайти ключі. |
| Neodređene zamjenice: netko, nešto, negdje | Sve-: svatko, sve, svugdje | так | *Svugdje je gužva.* — Скрізь людно. |
| Vokativ: Dašo! Ivane! Gospodine! | Множина: Djeco! Dragi prijatelji! | так |  |

