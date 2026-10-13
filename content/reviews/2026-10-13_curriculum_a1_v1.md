# Перевірка контенту: програма A1 (curriculum_a1_v1)

**Дата:** 2026-10-13  
**Хто перевіряв:** AI (Claude) + автоматичні перевірки генератора. Носій мови — ще ні.  
**Статус:** PUBLISHED як **бета**. Запит власника — «зроби для A1 те, що ми робили для A0»; A0 теж опубліковано як бету. Щоб тримати A1 у чернетках до перевірки носієм, у генераторі є перемикач `STATUS = 'DRAFT'`.

Того ж дня власник вирішив додати по +1–2 уроки в модулі, де тема неповна по суті. Тому в програмі 49 уроків: 30 базових + 19 додаткових (у таблицях позначено «новий»).

Файли:

- дані: `scripts/curriculum_a1_data.py`;
- знімок слів і перекладів робочої бази: `scripts/curriculum_a1_snapshot.json`;
- генератор: `scripts/gen_curriculum_a1.py`, спільна логіка уроку — `scripts/full_lessons.py`. Ключ `--review` друкує таблицю вправ на слова;
- SQL: дві частини — `supabase/data_fixes/20261013_curriculum_a1_v1_part1.sql` (модулі A1.1–A1.5), потім `…_part2.sql` (A1.6–A1.10 і публікація). Цілий файл (~1 МБ) SQL Editor не приймав. Потрібна міграція M13 — уже застосована;
- тест: `supabase/tests/curriculum_a1.test.sql`.

## Що додано

| Що | Скільки | Статус |
|---|---|---|
| Модулі A1 | 10 (були в каркасі як DRAFT) + опис і юніт з метою | PUBLISHED |
| Уроки A1 | 49: по 3–5 у модулі, ~12 хв кожен | PUBLISHED |
| Граматичні теми A1 | 13 (були DRAFT без правил) → 39 правил, по 3 приклади | PUBLISHED |
| Діалоги | 98 (по 2 в уроці), 474 репліки | PUBLISHED |
| Вправи | 588 (по 12 в уроці, усі 6 типів) | PUBLISHED |
| Слова в уроках | 579 зв’язків «урок — слово»: 534 різні слова, з них 434 нові відносно A0 | — |
| Нові слова у словнику | 104 | PUBLISHED |
| Виправлення словника | 11 перекладів + 3 написання леми (див. нижче). Стара версія — у `content_versions` | PUBLISHED |

**Додаткові уроки (по модулях):**

- A1.1 — домашні справи; ранкові збори;
- A1.2 — кафе й пекарня; алергія і смаки;
- A1.3 — дрогерія; мобільний зв’язок;
- A1.4 — таксі; заправка й паркування;
- A1.5 — рахунки й інтернет;
- A1.6 — договір і зарплата; дзвінок на роботу;
- A1.7 — що болить (тіло); у стоматолога;
- A1.8 — почуття; домовляємося про зустріч;
- A1.9 — краї Хорватії; хорватські звичаї;
- A1.10 — дитячий садок і школа; у банку.

**Виправлення словника:**

| Слово | Було | Стало |
|---|---|---|
| *luk* | «цибуля / часник» | «цибуля» |
| *slobodno vrijeme* | «віільний час» | «вільний час» |
| *uho* | «вхо» | «вухо» |
| *polica* | «страховий поліс» | «полиця; страховий поліс» |
| *spremati* | «зберігати» | «прибирати; готувати; зберігати» |
| *kraj* | «кінець» | «кінець; край, місцевість» |
| *hladno* | «холодне» | «холодно; холодне» |
| *dokaz* | «доказ» | «доказ; підтвердження» |
| *živjeli* | «Будьмо! (Тост)» | «будьмо! (тост)» |
| *mobilno bankarstvo*, *prtljažnik* | переклади з великої літери | з малої |
| *Vozačka dozvola*, *Mobilno bankarstvo*, *Prtljažnik* | лема з великої літери | з малої |

## Відповідність ТЗ

| | ТЗ | A1 |
|---|---|---|
| Модулі | 10, теми §28 | ✅ 10, ті самі теми |
| Граматика | 13 тем §22 | ✅ 13, кожна у 2–5 уроках |
| Нові слова | ~1 000 (план, §14) | ⚠️ 434 нових відносно A0. Щоб вийти на план, потрібно 6–7 уроків у модулі |

## Автоматичні перевірки

Генератор зупиняється, якщо щось не так:

- [x] у хорватському тексті немає кирилиці, в українському вона є;
- [x] кожне слово є в знімку бази (звірено з робочою базою 2026-10-13) або серед нових;
- [x] у кожному уроці 10–14 слів без повторів;
- [x] 2 діалоги по 4–6 реплік;
- [x] «аудіювання» взято з діалогів уроку;
- [x] у «складіть» і «аудіюванні» слова не повторюються;
- [x] «вставте слово»: 4 різні варіанти, правильний серед них;
- [x] у кожній темі граматики ≥ 2 правила по ≥ 2 приклади; кожна тема використана в уроках;
- [x] вправи на слова:
  - хибні варіанти не перетинаються за змістом із правильним і не є синонімами;
  - у «Як хорватською» і «Напишіть» немає слів, переклад яких збігається з перекладом іншого слова.

Локально (Postgres 16: baseline + усі міграції + A0 v1/v2/v3):

- [x] SQL застосовано двічі поспіль — без дублів;
- [x] працює в будь-якому порядку з `20261013_curriculum_a0_v3.sql`;
- [x] усі 12 SQL-тестів проходять.

## Мовна перевірка (AI)

Під час перевірки виправлено:

- *Nemoj brinuti* → *Nemoj se brinuti*;
- *Prvo skuhaj vodu* → *Prvo zakuhaj vodu*;
- *Je li ovdje blizu neki bankomat? — Jest…* → *Ima li ovdje blizu neki bankomat? — Ima…*;
- *trebam taksi u Ilicu deset* → *trebam taksi na adresu Ilica deset*;
- *javiti se na videopoziv* → *uključiti se na videopoziv*;
- *Koji dokumenti trebaju?* → *Koji su dokumenti potrebni?*;
- два пояснення граматики, які були лише хорватськими словами, переписано українською.

Що варто глянути носію в першу чергу:

1. Теперішній час замість майбутнього (майбутній — це A2):
   - *Sutra šaljem majstora* (житло);
   - *Razumijem, odmah gasim* (сусід; можливо, краще *odmah stišavam*);
   - *Super, njih probam* (покупки);
   - *Sutra šaljemo tehničara* (інтернет).
2. *Ozdravite brzo!* — чи природніше *Brzo ozdravite!*?
3. *Gdje spavate na otoku?* — розмовне; нейтральніше *Gdje ste smješteni?*
4. Порівняння: у правилі — *nego*, у вправі — *toplija od plave*. Обидва варіанти правильні; чи не заплутає це на A1?
5. Факти, які варто звірити:
   - людям із тимчасовим захистом не потрібен дозвіл на роботу (урок «Договір і зарплата»);
   - огляд у стоматолога зі страховкою безкоштовний;
   - документи для запису в садок: свідоцтво про народження, щеплення, OIB.
6. Розмовні слова: *bon* (передплачена картка), *dvadeset giga*, *kava za van*.

## Уроки: діалоги, «вставте слово», «скажіть уголос»

### A1.1 — Повсякденне життя / Svakodnevni život

**Урок 1 — Мій звичайний день / Moj običan dan** · граматика: present

*Ранок Тараса / Tarasovo jutro*

- Ana: *Kada se obično budiš?* — Коли ти зазвичай прокидаєшся?
- Taras: *Budim se u šest i pol.* — Я прокидаюся о пів на сьому.
- Ana: *Tako rano! Zašto?* — Так рано! Чому?
- Taras: *Radim od osam. Prvo se tuširam, onda doručkujem.* — Я працюю з восьмої. Спочатку приймаю душ, потім снідаю.
- Ana: *A kada ideš spavati?* — А коли ти лягаєш спати?
- Taras: *Obično u jedanaest.* — Зазвичай об одинадцятій.

*Робочий день Олени / Olenin radni dan*

- Marija: *Gdje ručaš?* — Де ти обідаєш?
- Olena: *Ručam na poslu, u dvanaest.* — Обідаю на роботі, о дванадцятій.
- Marija: *Kada završavaš?* — Коли ти закінчуєш?
- Olena: *U četiri. Onda kuham večeru.* — О четвертій. Потім готую вечерю.
- Marija: *Večeraš li kasno?* — Ти пізно вечеряєш?
- Olena: *Ne, večeramo u sedam.* — Ні, ми вечеряємо о сьомій.

- Вставте слово: *Ja se ___ u šest.* → **budim** (хибні: budiš, budi, budimo)
- Скажіть уголос: *Budim se u sedam.* (Я прокидаюся о сьомій.); *Obično ručam u dvanaest.* (Зазвичай я обідаю о дванадцятій.)

**Урок 2 — Вихідні / Vikend** · граматика: regular

*Плани на суботу / Planovi za subotu*

- Ivan: *Što radiš u subotu?* — Що ти робиш у суботу?
- Iryna: *Ujutro šetam u parku, a popodne čitam.* — Зранку гуляю в парку, а після обіду читаю.
- Ivan: *Što čitaš?* — Що ти читаєш?
- Iryna: *Knjigu na hrvatskom. Polako, ali čitam!* — Книжку хорватською. Повільно, але читаю!
- Ivan: *Bravo! Ja gledam film s prijateljima.* — Браво! А я дивлюся фільм із друзями.

*Спокійні вихідні / Miran vikend*

- Petra: *Kako provodiš vikend?* — Як ти проводиш вихідні?
- Andrij: *Odmaram se. Kuham i slušam glazbu.* — Відпочиваю. Готую і слухаю музику.
- Petra: *Koju glazbu slušaš?* — Яку музику ти слухаєш?
- Andrij: *Hrvatsku i ukrajinsku.* — Хорватську й українську.
- Petra: *I ja volim hrvatsku glazbu!* — Я теж люблю хорватську музику!

- Вставте слово: *Mi ___ film.* → **gledamo** (хибні: gledam, gledaš, gledaju)
- Скажіть уголос: *Što radiš u subotu?* (Що ти робиш у суботу?); *Čitam knjigu.* (Я читаю книжку.)

**Урок 3 — Як часто? / Koliko često?** · граматика: irregular

*Спорт / Sport*

- Luka: *Ideš li često na trening?* — Ти часто ходиш на тренування?
- Oksana: *Idem dva puta tjedno. A ti?* — Ходжу двічі на тиждень. А ти?
- Luka: *Ja trčim svaki dan, ujutro.* — Я бігаю щодня, зранку.
- Oksana: *Svaki dan? Ja to ne mogu!* — Щодня? Я так не можу!
- Luka: *Možeš! Hoćeš li trčati sa mnom?* — Можеш! Хочеш бігати зі мною?

*Кава чи чай? / Kava ili čaj?*

- Marta: *Piješ li kavu?* — Ти п’єш каву?
- Taras: *Rijetko. Obično pijem čaj.* — Рідко. Зазвичай я п’ю чай.
- Marta: *A što jedeš za doručak?* — А що ти їси на сніданок?
- Taras: *Uvijek jedem kruh i jaja.* — Я завжди їм хліб і яйця.
- Marta: *Ja nikad ne jedem ujutro.* — А я ніколи не їм зранку.

- Вставте слово: *Ja ___ u grad.* → **idem** (хибні: ideš, ide, idu)
- Скажіть уголос: *Često idem u park.* (Я часто ходжу в парк.); *Nikad ne pijem kavu.* (Я ніколи не п’ю каву.)

**Урок 4 — Домашні справи / Kućanski poslovi** · граматика: present · новий

*Субота вдома / Subota kod kuće*

- Mama: *Danas je subota. Čistimo stan!* — Сьогодні субота. Прибираємо квартиру!
- Sin: *Opet? Što ja radim?* — Знову? А що роблю я?
- Mama: *Ti usisavaš sobe, a tata pere suđe.* — Ти пилососиш кімнати, а тато миє посуд.
- Sin: *A ti?* — А ти?
- Mama: *Ja perem rublje i peglam.* — Я перу білизну й прасую.

*Сусідка по квартирі / Cimerica*

- Olena: *Tko danas sprema kuhinju?* — Хто сьогодні прибирає кухню?
- Lana: *Ja spremam kuhinju ponedjeljkom i srijedom.* — Я прибираю кухню по понеділках і середах.
- Olena: *Dobro, onda ja čistim kupaonicu i brišem prašinu.* — Добре, тоді я мию ванну й витираю пил.
- Lana: *I iznosiš smeće?* — І виносиш сміття?
- Olena: *Može. Hvala ti što pomažeš!* — Добре. Дякую, що допомагаєш!

- Вставте слово: *Tata ___ suđe.* → **pere** (хибні: perem, pereš, peru)
- Скажіть уголос: *Perem suđe.* (Я мию посуд.); *Tko sprema kuhinju?* (Хто прибирає кухню?)

**Урок 5 — Збираємося зранку / Jutarnje spremanje** · граматика: imperative · новий

*Вставай! / Ustani!*

- Mama: *Dino, ustani! Kasnimo!* — Діно, вставай! Ми запізнюємося!
- Dino: *Još pet minuta, molim te.* — Ще п’ять хвилин, будь ласка.
- Mama: *Ne! Umij se i operi zube.* — Ні! Умийся й почисть зуби.
- Dino: *Gdje je moja četkica za zube?* — Де моя зубна щітка?
- Mama: *U kupaonici, pored sapuna. Brzo!* — У ванній, біля мила. Швидко!

*Що вдягнути? / Što obući?*

- Dino: *Mama, što da obučem?* — Мамо, що мені вдягнути?
- Mama: *Obuci plave hlače i bijelu majicu.* — Вдягни сині штани й білу футболку.
- Dino: *A jaknu?* — А куртку?
- Mama: *Da, vani je hladno. Počešljaj se i idemo!* — Так, надворі холодно. Причешися — і ходімо!
- Dino: *Spreman sam!* — Я готовий!

- Вставте слово: *___ zube, molim te!* → **Operi** (хибні: Perem, Pere, Oprati)
- Скажіть уголос: *Moram se žuriti.* (Мені треба поспішати.); *Gdje je ručnik?* (Де рушник?)

### A1.2 — Їжа й ресторани / Hrana i restorani

**Урок 6 — Столик на двох / Stol za dvoje** · граматика: akuzativ

*Бронювання / Rezervacija*

- Konobar: *Restoran Lavanda, izvolite.* — Ресторан «Лаванда», слухаю.
- Andrij: *Dobar dan. Želim rezervirati stol za dvoje.* — Добрий день. Я хочу забронювати столик на двох.
- Konobar: *Za kada?* — На коли?
- Andrij: *Za petak u osam.* — На п’ятницю на восьму.
- Konobar: *U redu. Na koje ime?* — Добре. На яке ім’я?
- Andrij: *Na ime Kovalenko.* — На ім’я Коваленко.

*Замовлення / Narudžba*

- Konobarica: *Što želite naručiti?* — Що бажаєте замовити?
- Iryna: *Za predjelo juhu, a za glavno jelo ribu.* — На закуску суп, а на основну страву рибу.
- Konobarica: *A za piće?* — А що питимете?
- Iryna: *Čašu bijelog vina, molim.* — Келих білого вина, будь ласка.
- Konobarica: *Želite li desert?* — Бажаєте десерт?
- Iryna: *Ne, hvala. Samo račun, molim.* — Ні, дякую. Тільки рахунок, будь ласка.

- Вставте слово: *Želim ___, molim.* → **juhu** (хибні: juha, juhe, juhom)
- Скажіть уголос: *Želim ribu i salatu.* (Я хочу рибу і салат.); *Mogu li dobiti jelovnik?* (Можна меню?)

**Урок 7 — Готуємо вдома / Kuhamo kod kuće** · граматика: imperative

*Рецепт пасти / Recept za tjesteninu*

- Baka: *Prvo zakuhaj vodu.* — Спочатку закип’яти воду.
- Dino: *A onda?* — А потім?
- Baka: *Nareži luk i češnjak.* — Наріж цибулю й часник.
- Dino: *Koliko ulja?* — Скільки олії?
- Baka: *Malo. Dodaj rajčice, sol i papar.* — Трохи. Додай помідори, сіль і перець.
- Dino: *Mmm, miriše odlično!* — Ммм, чудово пахне!

*Накриваємо на стіл / Postavljamo stol*

- Mama: *Molim te, donesi tanjure.* — Будь ласка, принеси тарілки.
- Sofija: *Koliko tanjura?* — Скільки тарілок?
- Mama: *Četiri. I vilice, noževe i žlice.* — Чотири. І виделки, ножі й ложки.
- Sofija: *Evo. Mogu li probati?* — Ось. Можна скуштувати?
- Mama: *Možeš. Pazi, vruće je!* — Можна. Обережно, гаряче!

- Вставте слово: *___ sol, molim te!* → **Dodaj** (хибні: Dodam, Doda, Dodati)
- Скажіть уголос: *Dodaj sol, molim te.* (Додай сіль, будь ласка.); *Mogu li probati?* (Можна скуштувати?)

**Урок 8 — На ринку / Na tržnici** · граматика: genitiv

*Фрукти / Voće*

- Prodavačica: *Izvolite, sve je svježe!* — Прошу, усе свіже!
- Olena: *Kilogram grožđa i pola kilograma krušaka, molim.* — Кілограм винограду й півкілограма груш, будь ласка.
- Prodavačica: *Još nešto? Breskve su danas jako slatke.* — Ще щось? Персики сьогодні дуже солодкі.
- Olena: *Dobro, i tri breskve.* — Добре, і три персики.
- Prodavačica: *To je sedam eura.* — Це сім євро.

*Сир і молоко / Sir i mlijeko*

- Kupac: *Imate li domaćeg sira?* — У вас є домашній сир?
- Prodavač: *Imam. Koliko želite?* — Є. Скільки бажаєте?
- Kupac: *Jedan komad. I bocu mlijeka.* — Один шматок. І пляшку молока.
- Prodavač: *Mlijeka danas nemam, nažalost.* — Молока сьогодні, на жаль, немає.
- Kupac: *Nema problema. Hvala!* — Нічого страшного. Дякую!

- Вставте слово: *Kilogram ___, molim.* → **grožđa** (хибні: grožđe, grožđem, grožđu)
- Скажіть уголос: *Bocu vode, molim.* (Пляшку води, будь ласка.); *Koliko košta kilogram?* (Скільки коштує кілограм?)

**Урок 9 — У кафе й пекарні / U kafiću i pekari** · граматика: akuzativ · новий

*У кафе / U kafiću*

- Konobar: *Dobar dan! Što želite?* — Добрий день! Що бажаєте?
- Iryna: *Jednu kavu s mlijekom i čaj od mente, molim.* — Одну каву з молоком і м’ятний чай, будь ласка.
- Konobar: *Želite li nešto slatko? Imamo domaće kolače.* — Бажаєте щось солодке? У нас домашні тістечка.
- Iryna: *Može jedan kolač od čokolade.* — Можна одне шоколадне тістечко.
- Konobar: *Šećer je na stolu.* — Цукор на столі.

*У пекарні / U pekari*

- Prodavačica: *Izvolite?* — Слухаю вас?
- Taras: *Jedan burek sa sirom i dva peciva, molim.* — Один бурек із сиром і дві булочки, будь ласка.
- Prodavačica: *Još nešto? Jogurt?* — Ще щось? Йогурт?
- Taras: *Da, jedan jogurt. I kavu za van.* — Так, один йогурт. І каву з собою.
- Prodavačica: *Ukupno pet eura.* — Разом п’ять євро.

- Вставте слово: *Molim jednu ___.* → **kavu** (хибні: kava, kave, kavom)
- Скажіть уголос: *Kavu za van, molim.* (Каву з собою, будь ласка.); *Čaj bez šećera, molim.* (Чай без цукру, будь ласка.)

**Урок 10 — Алергія і смаки / Alergija i okusi** · граматика: negation · новий

*Я вегетаріанка / Ja sam vegetarijanka*

- Konobarica: *Preporučujem gulaš, jako je ukusan.* — Раджу гуляш, він дуже смачний.
- Oksana: *Hvala, ali ja ne jedem meso. Vegetarijanka sam.* — Дякую, але я не їм м’яса. Я вегетаріанка.
- Konobarica: *Onda rižoto s povrćem?* — Тоді різото з овочами?
- Oksana: *Može. Ima li u njemu oraha? Alergična sam na orahe.* — Можна. У ньому є горіхи? У мене алергія на горіхи.
- Konobarica: *Nema, ne brinite.* — Немає, не хвилюйтеся.

*Надто солоно / Previše slano*

- Andrij: *Oprostite, juha je previše slana.* — Перепрошую, суп надто солоний.
- Konobar: *Žao mi je! Odmah donosim novu.* — Мені шкода! Зараз принесу новий.
- Andrij: *I ovo jelo je jako ljuto.* — І ця страва дуже гостра.
- Konobar: *Nema problema, mogu ga zamijeniti.* — Без проблем, можу її замінити.

- Вставте слово: *Juha ___ slana.* → **nije** (хибні: ne, nisam, nema)
- Скажіть уголос: *Alergičan sam na orahe.* (У мене алергія на горіхи.); *Ovo je jako ukusno!* (Це дуже смачно!)

### A1.3 — Покупки / Kupovina

**Урок 11 — Яка краща? / Koja je bolja?** · граматика: comparison

*Куртка / Jakna*

- Iryna: *Koja jakna je bolja, plava ili crna?* — Яка куртка краща, синя чи чорна?
- Lana: *Plava je ljepša, ali crna je toplija.* — Синя гарніша, але чорна тепліша.
- Iryna: *Crna je i skuplja.* — Чорна ще й дорожча.
- Lana: *Da, ali je bolja za zimu.* — Так, але вона краща для зими.
- Iryna: *Dobro, uzimam crnu.* — Добре, беру чорну.

*У примірочній / U kabini*

- Andrij: *Ove traperice su mi male.* — Ці джинси мені малі.
- Prodavačica: *Probajte veće. Ovo je veličina trideset dva.* — Поміряйте більші. Це розмір тридцять два.
- Andrij: *Imate li jeftinije?* — У вас є дешевші?
- Prodavačica: *Imamo. Ove su na popustu.* — Є. Ці зі знижкою.
- Andrij: *Super, njih probam.* — Чудово, їх і поміряю.

- Вставте слово: *Crna jakna je ___ od plave.* → **toplija** (хибні: topla, topliji, najtoplija)
- Скажіть уголос: *Ova haljina je jeftinija.* (Ця сукня дешевша.); *Mogu li probati?* (Можна поміряти?)

**Урок 12 — У супермаркеті / U supermarketu** · граматика: modal

*Список покупок / Popis za kupovinu*

- Taras: *Moram kupiti mlijeko i kruh.* — Мені треба купити молоко й хліб.
- Olena: *Trebamo i jaja.* — Нам ще потрібні яйця.
- Taras: *Možeš li uzeti košaricu?* — Можеш узяти кошик?
- Olena: *Mogu. Gdje je mlijeko?* — Можу. Де молоко?
- Taras: *Tamo, lijevo.* — Там, ліворуч.

*На касі / Na blagajni*

- Blagajnica: *Trebate li vrećicu?* — Вам потрібен пакет?
- Olena: *Da, jednu. Mogu li platiti karticom?* — Так, один. Можна заплатити карткою?
- Blagajnica: *Naravno. Unesite PIN.* — Звісно. Введіть PIN.
- Olena: *Evo. Hvala!* — Ось. Дякую!
- Blagajnica: *Hvala Vama! Ugodan dan!* — Дякую вам! Гарного дня!

- Вставте слово: *Ja ___ kupiti kruh.* → **moram** (хибні: moraš, mora, moraju)
- Скажіть уголос: *Trebam vrećicu.* (Мені потрібен пакет.); *Moram li platiti gotovinom?* (Мені треба платити готівкою?)

**Урок 13 — Повернення товару / Povrat robe** · граматика: negation

*Зарядка не працює / Punjač ne radi*

- Prodavač: *Izvolite, kako mogu pomoći?* — Прошу, чим можу допомогти?
- Andrij: *Ovaj punjač ne radi.* — Цей зарядний пристрій не працює.
- Prodavač: *Imate li račun?* — У вас є чек?
- Andrij: *Imam, evo ga.* — Є, ось він.
- Prodavač: *Možemo ga zamijeniti ili vratiti novac.* — Можемо його обміняти або повернути гроші.
- Andrij: *Molim Vas, vratite novac.* — Поверніть, будь ласка, гроші.

*Нічого не подобається / Ništa mi se ne sviđa*

- Lana: *Kupuješ li nešto?* — Ти щось купуєш?
- Oksana: *Ne, ništa mi se ne sviđa.* — Ні, мені нічого не подобається.
- Lana: *A ova haljina?* — А ця сукня?
- Oksana: *Nema moje veličine.* — Немає мого розміру.
- Lana: *Ni ja nikad ne nalazim ništa ovdje!* — Я теж ніколи нічого тут не знаходжу!

- Вставте слово: *Punjač ___ radi.* → **ne** (хибні: nije, ni, nema)
- Скажіть уголос: *Ovo ne radi.* (Це не працює.); *Ništa ne kupujem.* (Я нічого не купую.)

**Урок 14 — У дрогерії / U drogeriji** · граматика: genitiv · новий

*Для малюка / Za bebu*

- Olena: *Oprostite, gdje su pelene?* — Вибачте, де підгузки?
- Prodavačica: *Na kraju, desno, pored kreme za bebe.* — У кінці, праворуч, біля дитячого крему.
- Olena: *Imate li veći paket?* — У вас є більша упаковка?
- Prodavačica: *Imamo, i danas je na akciji.* — Є, і сьогодні вона по акції.

*Немає шампуню / Nema šampona*

- Taras: *Trebam šampon i pastu za zube.* — Мені потрібні шампунь і зубна паста.
- Prodavač: *Pasta za zube je ovdje. Šampona za suhu kosu danas nema.* — Зубна паста тут. Шампуню для сухого волосся сьогодні немає.
- Taras: *Ima li deterdženta za rublje?* — А засіб для прання є?
- Prodavač: *Ima, na zadnjoj polici. I toaletni papir je tamo.* — Є, на останній полиці. Туалетний папір теж там.

- Вставте слово: *Danas nema ___.* → **šampona** (хибні: šampon, šamponu, šamponom)
- Скажіть уголос: *Gdje je toaletni papir?* (Де туалетний папір?); *Je li ovo na akciji?* (Це по акції?)

**Урок 15 — Мобільний зв’язок / Mobilna mreža** · граматика: questions · новий

*Нова SIM-картка / Nova SIM kartica*

- Andrij: *Dobar dan, trebam SIM karticu.* — Добрий день, мені потрібна SIM-картка.
- Prodavačica: *Želite li bon ili tarifu s ugovorom?* — Бажаєте передплачену картку чи тариф із договором?
- Andrij: *Bon. Koliko košta internet?* — Передплачену. Скільки коштує інтернет?
- Prodavačica: *Deset eura mjesečno za dvadeset giga.* — Десять євро на місяць за двадцять гігабайтів.
- Andrij: *Mogu li zvati u Ukrajinu?* — Чи можу я дзвонити в Україну?

*Телефон не заряджається / Mobitel se ne puni*

- Iryna: *Moj mobitel se ne puni.* — Мій телефон не заряджається.
- Prodavač: *Koji punjač imate?* — Який у вас зарядний пристрій?
- Iryna: *Ovaj. Kada mogu doći po mobitel?* — Ось цей. Коли я можу прийти по телефон?
- Prodavač: *Sutra poslijepodne. Ostavite broj mobitela, molim.* — Завтра після обіду. Залиште, будь ласка, номер телефону.

- Вставте слово: *___ košta internet?* → **Koliko** (хибні: Kada, Koji, Gdje)
- Скажіть уголос: *Koliko košta internet?* (Скільки коштує інтернет?); *Trebam punjač.* (Мені потрібен зарядний пристрій.)

### A1.4 — Транспорт / Prijevoz

**Урок 16 — У трамваї / U tramvaju** · граматика: lokativ

*Де купити квиток? / Gdje kupiti kartu?*

- Olena: *Oprostite, gdje mogu kupiti kartu?* — Вибачте, де я можу купити квиток?
- Gospođa: *Na kiosku ili u tramvaju, kod vozača.* — У кіоску або в трамваї, у водія.
- Olena: *Koliko košta?* — Скільки коштує?
- Gospođa: *Kod vozača dva eura. Ne zaboravite je poništiti!* — У водія два євро. Не забудьте її прокомпостувати!
- Olena: *Hvala na pomoći!* — Дякую за допомогу!

*Пересадка / Presjedanje*

- Taras: *Ide li ovaj tramvaj do kolodvora?* — Цей трамвай їде до вокзалу?
- Mladić: *Ne ide. Morate presjesti na Trgu bana Jelačića.* — Не їде. Вам треба пересісти на площі бана Єлачича.
- Taras: *Na kojoj stanici?* — На якій зупинці?
- Mladić: *Na sljedećoj. Onda uzmite šesticu.* — На наступній. Потім сідайте на шістку.
- Taras: *Hvala!* — Дякую!

- Вставте слово: *Čekam na ___.* → **stanici** (хибні: stanica, stanicu, stanice)
- Скажіть уголос: *U tramvaju sam.* (Я в трамваї.); *Čekam na stanici.* (Я чекаю на зупинці.)

**Урок 17 — Розклад поїздів / Vozni red** · граматика: questions

*На вокзалі / Na kolodvoru*

- Andrij: *Kada polazi vlak za Rijeku?* — Коли відправляється поїзд до Рієки?
- Službenica: *U četrnaest i dvadeset, s trećeg perona.* — О чотирнадцятій двадцять, з третьої платформи.
- Andrij: *Koliko traje vožnja?* — Скільки триває поїздка?
- Službenica: *Oko četiri sata.* — Близько чотирьох годин.
- Andrij: *Jednu povratnu kartu, molim.* — Один квиток туди й назад, будь ласка.

*Поїзд запізнюється / Vlak kasni*

- Putnica: *Zašto vlak još nije ovdje?* — Чому поїзда досі немає?
- Kondukter: *Kasni dvadeset minuta.* — Він запізнюється на двадцять хвилин.
- Putnica: *Kada stiže?* — Коли він прибуває?
- Kondukter: *U pola tri.* — О пів на третю.
- Putnica: *Gdje mogu popiti kavu?* — Де можна випити кави?
- Kondukter: *U kafiću pored izlaza.* — У кафе біля виходу.

- Вставте слово: *___ polazi vlak? — U tri.* → **Kada** (хибні: Gdje, Tko, Koliko)
- Скажіть уголос: *Koliko traje vožnja?* (Скільки триває поїздка?); *S kojeg perona?* (З якої платформи?)

**Урок 18 — В аеропорту / U zračnoj luci** · граматика: possessives

*Реєстрація / Prijava za let*

- Službenik: *Vašu putovnicu, molim.* — Ваш паспорт, будь ласка.
- Iryna: *Izvolite.* — Прошу.
- Službenik: *Je li ovo Vaš kofer?* — Це ваша валіза?
- Iryna: *Da, moj. A ova torba je ručna prtljaga.* — Так, моя. А ця сумка — ручна поклажа.
- Službenik: *Želite li sjedalo do prozora?* — Бажаєте місце біля вікна?
- Iryna: *Da, molim.* — Так, будь ласка.

*Чия це сумка? / Čija je ovo torba?*

- Djevojka: *Oprostite, je li ovo Vaša torba?* — Вибачте, це ваша сумка?
- Taras: *Nije moja. Moja je crna.* — Не моя. Моя чорна.
- Djevojka: *Možda je njegova?* — Може, це його?
- Muškarac: *Da, moja je! Hvala Vam.* — Так, моя! Дякую вам.
- Djevojka: *Nema na čemu.* — Нема за що.

- Вставте слово: *Je li ovo ___ kofer? — Da, moj.* → **Vaš** (хибні: Vaša, Vaše, Vašu)
- Скажіть уголос: *Ovo je moja putovnica.* (Це мій паспорт.); *Gdje je izlaz za ukrcaj?* (Де вихід на посадку?)

**Урок 19 — Таксі / Taksi** · граматика: imperative · новий

*Виклик таксі / Naručivanje taksija*

- Oksana: *Dobar dan, trebam taksi na adresu Ilica deset.* — Добрий день, мені потрібне таксі на адресу Іліца, 10.
- Dispečerica: *Kada?* — Коли?
- Oksana: *Odmah, molim. Idem na kolodvor.* — Негайно, будь ласка. Я їду на вокзал.
- Dispečerica: *Taksi stiže za pet minuta. Bijela Škoda.* — Таксі приїде за п’ять хвилин. Біла «Шкода».

*У таксі / U taksiju*

- Taksist: *Stavite kofer u prtljažnik.* — Покладіть валізу в багажник.
- Oksana: *Hvala. Možete li voziti malo brže? Žurim se.* — Дякую. Можете їхати трохи швидше? Я поспішаю.
- Taksist: *Ima gužve, ali stižemo na vrijeme.* — Є затор, але ми встигаємо вчасно.
- Oksana: *Stanite ovdje, molim. Koliko plaćam?* — Зупиніться тут, будь ласка. Скільки з мене?
- Taksist: *Dvanaest eura.* — Дванадцять євро.

- Вставте слово: *___ ovdje, molim!* → **Stanite** (хибні: Stanem, Stane, Stati)
- Скажіть уголос: *Stavite kofer u prtljažnik.* (Покладіть валізу в багажник.); *Koliko plaćam?* (Скільки з мене?)

**Урок 20 — Заправка й паркування / Benzinska i parkiranje** · граматика: modal · новий

*На заправці / Na benzinskoj*

- Radnik: *Dobar dan! Benzin ili dizel?* — Добрий день! Бензин чи дизель?
- Taras: *Dizel, pun rezervoar, molim.* — Дизель, повний бак, будь ласка.
- Radnik: *Plaćate unutra, na blagajni.* — Платите всередині, на касі.
- Taras: *Mogu li ovdje provjeriti gume?* — Чи можу я тут перевірити шини?
- Radnik: *Možete, zrak je iza postaje.* — Можете, повітря — за заправкою.

*Де можна паркуватися? / Gdje smijem parkirati?*

- Iryna: *Oprostite, smijem li ovdje parkirati?* — Вибачте, мені можна тут паркуватися?
- Prolaznik: *Smijete, ali morate platiti. Ovo je druga zona.* — Можна, але треба заплатити. Це друга зона.
- Iryna: *Gdje je automat?* — Де паркомат?
- Prolaznik: *Tamo. Ili platite SMS-om.* — Он там. Або заплатіть через SMS.
- Iryna: *Hvala! Ne želim kaznu.* — Дякую! Не хочу штрафу.

- Вставте слово: *Mi ___ platiti parking.* → **moramo** (хибні: moram, moraš, moraju)
- Скажіть уголос: *Gdje je benzinska postaja?* (Де заправка?); *Moram li ovdje platiti?* (Тут треба платити?)

### A1.5 — Житло / Stanovanje

**Урок 21 — Шукаю квартиру / Tražim stan** · граматика: conjunctions

*Дзвінок щодо оголошення / Poziv zbog oglasa*

- Oksana: *Dobar dan, zovem zbog oglasa za stan.* — Добрий день, я телефоную щодо оголошення про квартиру.
- Stanodavac: *Da, stan je još slobodan.* — Так, квартира ще вільна.
- Oksana: *Je li namješten?* — Вона мебльована?
- Stanodavac: *Jest, ali nema perilice.* — Так, але немає пральної машини.
- Oksana: *Koliko je najamnina?* — Скільки коштує оренда?
- Stanodavac: *Petsto pedeset eura i režije.* — П’ятсот п’ятдесят євро плюс комунальні.

*Огляд квартири / Razgled stana*

- Stanodavac: *Stan je na trećem katu, a dizalo radi.* — Квартира на третьому поверсі, і ліфт працює.
- Oksana: *Sviđa mi se jer je svijetao.* — Мені подобається, бо вона світла.
- Stanodavac: *Polog je jedna najamnina.* — Застава — одна місячна оплата.
- Oksana: *Mogu li se useliti prvog?* — Чи можу я в’їхати першого числа?
- Stanodavac: *Možete. Ugovor potpisujemo sutra.* — Можете. Договір підписуємо завтра.

- Вставте слово: *Stan je lijep, ___ je skup.* → **ali** (хибні: jer, ili, i)
- Скажіть уголос: *Koliko je najamnina?* (Скільки коштує оренда?); *Stan je lijep, ali skup.* (Квартира гарна, але дорога.)

**Урок 22 — Щось не працює / Nešto ne radi** · граматика: lokativ

*Дзвінок орендодавцю / Poziv stanodavcu*

- Andrij: *Dobar dan, gospodine Horvat. U kupaonici nešto ne radi.* — Добрий день, пане Горват. У ванній щось не працює.
- Stanodavac: *Što točno?* — Що саме?
- Andrij: *Tuš. Nema tople vode.* — Душ. Немає гарячої води.
- Stanodavac: *Sutra šaljem majstora.* — Завтра надішлю майстра.
- Andrij: *Hvala. Ja sam doma poslije pet.* — Дякую. Я вдома після п’ятої.

*Майстер / Majstor*

- Majstor: *Gdje je problem?* — Де проблема?
- Andrij: *U kuhinji. Hladnjak ne hladi.* — На кухні. Холодильник не охолоджує.
- Majstor: *A struja? Je li utičnica u redu?* — А електрика? Розетка в порядку?
- Andrij: *Mislim da jest.* — Думаю, що так.
- Majstor: *Dobro, sad gledam.* — Добре, зараз подивлюся.

- Вставте слово: *Problem je u ___.* → **kuhinji** (хибні: kuhinja, kuhinju, kuhinje)
- Скажіть уголос: *Hladnjak ne radi.* (Холодильник не працює.); *Doma sam poslije pet.* (Я вдома після п’ятої.)

**Урок 23 — Новий сусід / Novi susjed** · граматика: imperative

*Знайомство на сходах / Na stepenicama*

- Susjeda: *Dobar dan! Vi ste novi susjed?* — Добрий день! Ви новий сусід?
- Taras: *Da, ja sam Taras. Živim na drugom katu.* — Так, я Тарас. Живу на другому поверсі.
- Susjeda: *Ja sam Ana, iz stana pet. Drago mi je!* — Я Ана, з п’ятої квартири. Приємно познайомитися!
- Taras: *I meni. Gdje bacamo smeće?* — Мені теж. Куди ми викидаємо сміття?
- Susjeda: *Dolje, pored parkirališta. Plava kanta je za papir.* — Унизу, біля парковки. Синій бак — для паперу.

*Тихіше, будь ласка / Malo tiše, molim*

- Susjed: *Oprostite, molim Vas, stišajte glazbu.* — Перепрошую, будь ласка, зробіть музику тихіше.
- Iryna: *Oprostite! Je li preglasna?* — Вибачте! Занадто гучно?
- Susjed: *Jest. Djeca već spavaju.* — Так. Діти вже сплять.
- Iryna: *Razumijem, odmah gasim.* — Розумію, зараз вимкну.
- Susjed: *Hvala i laku noć!* — Дякую і на добраніч!

- Вставте слово: *Molim Vas, ___ glazbu.* → **stišajte** (хибні: stišam, stišaju, stišati)
- Скажіть уголос: *Ja sam Vaš novi susjed.* (Я ваш новий сусід.); *Molim Vas, nemojte parkirati ovdje.* (Не паркуйтеся тут, будь ласка.)

**Урок 24 — Рахунки й інтернет / Računi i internet** · граматика: possessives · новий

*Рахунок за електрику / Račun za struju*

- Oksana: *Gospodine Horvat, imam račun za struju. Tko ga plaća?* — Пане Горват, у мене рахунок за електрику. Хто його оплачує?
- Stanodavac: *Vi plaćate struju i plin, a ja vodu.* — Ви платите за електрику й газ, а я — за воду.
- Oksana: *Kako mogu platiti uplatnicu?* — Як я можу оплатити квитанцію?
- Stanodavac: *U banci, na pošti ili mobilnim bankarstvom.* — У банку, на пошті або через мобільний банкінг.
- Oksana: *Koji je rok?* — Який термін?
- Stanodavac: *Do petnaestog u mjesecu.* — До п’ятнадцятого числа.

*Інтернет не працює / Internet ne radi*

- Taras: *Dobar dan, naš internet ne radi od jutra.* — Добрий день, наш інтернет не працює з ранку.
- Operaterka: *Je li ruter uključen?* — Роутер увімкнений?
- Taras: *Jest, ali lampica je crvena. I lozinka ne radi.* — Так, але лампочка червона. І пароль не підходить.
- Operaterka: *Sutra šaljemo tehničara. Vaš broj korisnika, molim?* — Завтра надішлемо техніка. Ваш номер абонента, будь ласка?

- Вставте слово: *___ internet ne radi.* → **Naš** (хибні: Naša, Naše, Našu)
- Скажіть уголос: *Kako mogu platiti?* (Як я можу заплатити?); *Ruter ne radi.* (Роутер не працює.)

### A1.6 — Робота / Posao

**Урок 25 — Мій робочий день / Moj radni dan** · граматика: present

*Перший день / Prvi dan*

- Šefica: *Dobrodošli! Ovo je Vaš stol.* — Ласкаво просимо! Це ваш стіл.
- Oleg: *Hvala. Kada počinje radno vrijeme?* — Дякую. Коли починається робочий день?
- Šefica: *U osam. Završavamo u četiri.* — О восьмій. Закінчуємо о четвертій.
- Oleg: *A pauza za ručak?* — А обідня перерва?
- Šefica: *U podne, pola sata.* — Опівдні, пів години.

*Кава з колегою / Kava s kolegicom*

- Kolegica: *Gdje radiš, u kojem odjelu?* — Де ти працюєш, у якому відділі?
- Oleg: *U prodaji. Radim s klijentima.* — У відділі продажів. Працюю з клієнтами.
- Kolegica: *Sviđa li ti se?* — Тобі подобається?
- Oleg: *Da, kolege su jako dragi.* — Так, колеги дуже приємні.
- Kolegica: *Imamo danas sastanak u deset.* — Сьогодні в нас нарада о десятій.

- Вставте слово: *Mi ___ u četiri.* → **završavamo** (хибні: završavam, završava, završavaju)
- Скажіть уголос: *Radim u uredu.* (Я працюю в офісі.); *Sastanak je u deset.* (Нарада о десятій.)

**Урок 26 — Правила на роботі / Pravila na poslu** · граматика: modal

*Що можна, а що ні / Što smijem, a što ne*

- Oleg: *Smijem li ovdje pušiti?* — Тут можна курити?
- Kolega: *Ne smiješ. Moraš izaći van.* — Не можна. Треба вийти надвір.
- Oleg: *A smijem li raditi od kuće?* — А можна працювати з дому?
- Kolega: *Petkom smiješ, ali moraš pitati šefa.* — По п’ятницях можна, але треба спитати шефа.

*Лікарняний / Bolovanje*

- Oksana: *Dobro jutro. Bolesna sam i danas ne mogu doći.* — Доброго ранку. Я захворіла й сьогодні не можу прийти.
- Šef: *Žao mi je. Morate ići liječniku.* — Мені шкода. Вам треба піти до лікаря.
- Oksana: *Znam. Trebam li donijeti potvrdu?* — Знаю. Мені треба принести довідку?
- Šef: *Da, za bolovanje. Ozdravite brzo!* — Так, для лікарняного. Одужуйте швидше!

- Вставте слово: *Vi ovdje ne ___ pušiti.* → **smijete** (хибні: smijem, smije, smiju)
- Скажіть уголос: *Moram ići liječniku.* (Мені треба йти до лікаря.); *Smijem li raditi od kuće?* (Можна працювати з дому?)

**Урок 27 — Співбесіда / Razgovor za posao** · граматика: questions

*Досвід / Iskustvo*

- Direktor: *Odakle ste i koliko dugo živite u Hrvatskoj?* — Звідки ви і як довго живете в Хорватії?
- Taras: *Iz Ukrajine. Živim ovdje dvije godine.* — З України. Живу тут два роки.
- Direktor: *Kakvo iskustvo imate?* — Який у вас досвід?
- Taras: *Radim kao vozač već pet godina.* — Я працюю водієм уже п’ять років.
- Direktor: *Imate li vozačku dozvolu za kamion?* — У вас є посвідчення на вантажівку?
- Taras: *Imam, kategoriju C.* — Так, категорії C.

*Умови / Uvjeti*

- Taras: *Kada mogu početi?* — Коли я можу почати?
- Direktor: *Od prvog. Ugovor je na godinu dana.* — З першого числа. Договір на рік.
- Taras: *Kolika je plaća?* — Яка зарплата?
- Direktor: *Tisuću dvjesto eura neto.* — Тисяча двісті євро чистими.
- Taras: *To mi odgovara. Hvala!* — Мене це влаштовує. Дякую!

- Вставте слово: *___ dugo živite ovdje?* → **Koliko** (хибні: Kada, Gdje, Tko)
- Скажіть уголос: *Kakvo iskustvo imate?* (Який у вас досвід?); *Govorim ukrajinski i engleski.* (Я говорю українською й англійською.)

**Урок 28 — Договір і зарплата / Ugovor i plaća** · граматика: modal · новий

*Договір / Ugovor o radu*

- Šefica: *Ovo je Vaš ugovor. Prvo je probni rad, tri mjeseca.* — Це ваш договір. Спочатку випробувальний термін, три місяці.
- Oleg: *Je li puno radno vrijeme?* — Це повний робочий день?
- Šefica: *Da, osam sati dnevno. Radimo u dvije smjene.* — Так, вісім годин на день. Працюємо у дві зміни.
- Oleg: *Trebam li radnu dozvolu?* — Мені потрібен дозвіл на роботу?
- Šefica: *Ne trebate, imate privremenu zaštitu.* — Не потрібен, у вас тимчасовий захист.

*Зарплата / Plaća*

- Oleg: *Je li plaća bruto ili neto?* — Зарплата брутто чи нетто?
- Računovotkinja: *Neto, poslije poreza. Isplata je do desetog u mjesecu.* — Нетто, після податків. Виплата — до десятого числа.
- Oleg: *A prekovremeni sati?* — А понаднормові години?
- Računovotkinja: *Plaćaju se posebno. Sve piše na platnoj listi.* — Оплачуються окремо. Усе написано в розрахунковому листку.

- Вставте слово: *Trebate li radnu dozvolu? — Ne, ne ___.* → **trebam** (хибні: trebaš, treba, trebaju)
- Скажіть уголос: *Trebam li radnu dozvolu?* (Мені потрібен дозвіл на роботу?); *Kada je isplata?* (Коли виплата?)

**Урок 29 — Дзвінок на роботу / Telefonski poziv** · граматика: irregular · новий

*Дзвінок в офіс / Poziv u ured*

- Tajnica: *Tvrtka Adria, dobar dan.* — Компанія «Адрія», добрий день.
- Oleg: *Dobar dan, ovdje Oleg Kovalenko. Mogu li razgovarati s gospodinom Babićem?* — Добрий день, це Олег Коваленко. Можу я поговорити з паном Бабичем?
- Tajnica: *Nažalost, sada je zauzet. Možete li nazvati kasnije?* — На жаль, зараз він зайнятий. Можете подзвонити пізніше?
- Oleg: *Mogu. Ili mu ostavite poruku da me nazove.* — Можу. Або передайте йому, щоб він мені передзвонив.
- Tajnica: *Naravno. Koji je Vaš broj?* — Звісно. Який ваш номер?

*Повідомлення колезі / Poruka kolegi*

- Iryna: *Bok Marko, ne mogu doći na sastanak. Bolesna sam.* — Привіт, Марку, я не можу прийти на нараду. Я захворіла.
- Marko: *Nema problema. Možeš li se uključiti na videopoziv?* — Без проблем. Можеш підключитися відеодзвінком?
- Iryna: *Mogu, pošalji mi link.* — Можу, надішли мені посилання.
- Marko: *Šaljem ti mail. Javi se ako nešto trebaš.* — Надсилаю тобі мейл. Озвися, якщо щось треба.

- Вставте слово: *Oni ___ razgovarati s Vama.* → **hoće** (хибні: hoću, hoćeš, hoćemo)
- Скажіть уголос: *Mogu li razgovarati s gospodinom Babićem?* (Можу я поговорити з паном Бабичем?); *Nazovite me, molim.* (Подзвоніть мені, будь ласка.)

### A1.7 — Здоров’я / Zdravlje

**Урок 30 — Запис до лікаря / Naručivanje kod liječnika** · граматика: akuzativ

*Телефоном / Telefonom*

- Sestra: *Dom zdravlja, izvolite.* — Поліклініка, слухаю.
- Olena: *Dobar dan, trebam termin kod doktorice Babić.* — Добрий день, мені потрібен запис до лікарки Бабич.
- Sestra: *Imate li zdravstveno osiguranje?* — У вас є медичне страхування?
- Olena: *Imam.* — Так.
- Sestra: *Može sutra u devet i petnaest.* — Можна завтра о дев’ятій п’ятнадцять.
- Olena: *Odlično, hvala.* — Чудово, дякую.

*У кабінеті / U ordinaciji*

- Doktorica: *Što Vas boli?* — Що у вас болить?
- Olena: *Boli me grlo i imam kašalj.* — У мене болить горло і кашель.
- Doktorica: *Imate li temperaturu?* — У вас є температура?
- Olena: *Malo, trideset sedam i pet.* — Трохи, тридцять сім і п’ять.
- Doktorica: *Otvorite usta, molim. Da vidim.* — Відкрийте рот, будь ласка. Подивимося.

- Вставте слово: *Boli ___ glava.* → **me** (хибні: ja, moja, meni)
- Скажіть уголос: *Bole me leđa.* (У мене болить спина.); *Imam kašalj.* (У мене кашель.)

**Урок 31 — В аптеці / U ljekarni** · граматика: imperative

*Ліки від застуди / Lijek za prehladu*

- Ljekarnica: *Izvolite?* — Слухаю вас?
- Andrij: *Imate li nešto za prehladu?* — У вас є щось від застуди?
- Ljekarnica: *Imamo ove tablete i sirup protiv kašlja.* — Є ці таблетки й сироп від кашлю.
- Andrij: *Trebam li recept?* — Мені потрібен рецепт?
- Ljekarnica: *Ne, ne trebate.* — Ні, не потрібен.

*Як приймати / Kako uzimati*

- Andrij: *Kako trebam uzimati tablete?* — Як мені приймати таблетки?
- Ljekarnica: *Uzmite jednu tabletu tri puta dnevno.* — Приймайте одну таблетку тричі на день.
- Andrij: *Prije ili poslije jela?* — До чи після їжі?
- Ljekarnica: *Poslije jela. I pijte puno vode.* — Після їжі. І пийте багато води.
- Andrij: *Hvala, doviđenja!* — Дякую, до побачення!

- Вставте слово: *___ jednu tabletu dnevno.* → **Uzmite** (хибні: Uzmem, Uzme, Uzeti)
- Скажіть уголос: *Trebam lijek protiv bolova.* (Мені потрібні ліки від болю.); *Pijte puno vode.* (Пийте багато води.)

**Урок 32 — Як ви почуваєтеся? / Kako se osjećate?** · граматика: negation

*Другові недобре / Prijatelju nije dobro*

- Lana: *Kako se osjećaš danas?* — Як ти сьогодні почуваєшся?
- Taras: *Nisam dobro. Ne spavam dobro i nemam apetita.* — Мені недобре. Погано сплю, і немає апетиту.
- Lana: *Imaš li temperaturu?* — У тебе є температура?
- Taras: *Nemam, samo sam jako umoran.* — Немає, просто дуже втомлений.
- Lana: *Odmaraj se i pij čaj!* — Відпочивай і пий чай!

*Через тиждень / Tjedan dana kasnije*

- Lana: *Kako si sada?* — Як ти зараз?
- Taras: *Puno bolje! Više nisam bolestan.* — Набагато краще! Я вже не хворий.
- Lana: *Super! Idemo u šetnju?* — Супер! Підемо на прогулянку?
- Taras: *Može. Treba mi svježeg zraka.* — Давай. Мені потрібне свіже повітря.

- Вставте слово: *Ja danas ___ dobro.* → **nisam** (хибні: ne, nemam, nema)
- Скажіть уголос: *Nije mi dobro.* (Мені недобре.); *Ne spavam dobro.* (Я погано сплю.)

**Урок 33 — Що болить? / Što boli?** · граматика: akuzativ · новий

*Після футболу / Poslije nogometa*

- Liječnik: *Što Vas boli?* — Що у вас болить?
- Taras: *Boli me koljeno, a i rame.* — У мене болить коліно, а ще плече.
- Liječnik: *Od kada?* — Відколи?
- Taras: *Od subote, od nogometa.* — Із суботи, після футболу.
- Liječnik: *Možete li pomaknuti ruku?* — Можете поворушити рукою?
- Taras: *Mogu, ali boli.* — Можу, але болить.

*Дитина хворіє / Dijete je bolesno*

- Mama: *Doktorice, sinu je loše. Boli ga trbuh i uho.* — Лікарко, синові погано. У нього болить живіт і вухо.
- Doktorica: *Ima li temperaturu?* — У нього є температура?
- Mama: *Ima, trideset osam.* — Є, тридцять вісім.
- Doktorica: *Otvori usta i pokaži jezik.* — Відкрий рот і покажи язик.

- Вставте слово: *Bole me ___.* → **oči** (хибні: oko, oka, okom)
- Скажіть уголос: *Boli me ruka.* (У мене болить рука.); *Bole me oči.* (У мене болять очі.)

**Урок 34 — У стоматолога / Kod zubara** · граматика: questions · новий

*Терміновий запис / Hitan termin*

- Iryna: *Dobar dan, imam jaku zubobolju. Trebam hitan termin.* — Добрий день, у мене сильно болить зуб. Мені потрібен терміновий запис.
- Sestra: *Možete li doći danas u tri?* — Можете прийти сьогодні о третій?
- Iryna: *Mogu. Koliko košta pregled?* — Можу. Скільки коштує огляд?
- Sestra: *S osiguranjem ne plaćate ništa.* — Зі страховкою ви нічого не платите.

*У кріслі / U stolici*

- Zubar: *Koji zub Vas boli?* — Який зуб у вас болить?
- Iryna: *Ovaj gore, lijevo. Osjetljiv je na hladno.* — Ось цей угорі ліворуч. Він чутливий до холодного.
- Zubar: *Trebate plombu. Želite li injekciju?* — Вам потрібна пломба. Хочете укол?
- Iryna: *Da, molim! Morate li ga izvaditi?* — Так, будь ласка! Його треба видаляти?
- Zubar: *Ne, samo ga popravljamo.* — Ні, тільки лікуємо.

- Вставте слово: *___ zub Vas boli?* → **Koji** (хибні: Koja, Koje, Koju)
- Скажіть уголос: *Trebam zubara.* (Мені потрібен стоматолог.); *Koliko košta pregled?* (Скільки коштує огляд?)

### A1.8 — Соціальне життя / Društveni život

**Урок 35 — Запрошення / Poziv** · граматика: modal

*День народження / Rođendan*

- Marko: *U subotu slavim rođendan. Hoćeš li doći?* — У суботу я святкую день народження. Прийдеш?
- Iryna: *Hoću, rado! U koliko sati?* — Так, із радістю! О котрій?
- Marko: *U osam, kod mene.* — О восьмій, у мене.
- Iryna: *Trebam li nešto donijeti?* — Мені щось принести?
- Marko: *Ne trebaš, samo dobro raspoloženje!* — Не треба, тільки гарний настрій!

*Не можу / Ne mogu*

- Ana: *Idemo u kino večeras?* — Підемо сьогодні ввечері в кіно?
- Taras: *Nažalost, ne mogu. Moram raditi.* — На жаль, не можу. Мушу працювати.
- Ana: *A sutra?* — А завтра?
- Taras: *Sutra mogu. Vidimo se u sedam!* — Завтра можу. Побачимося о сьомій!

- Вставте слово: *Nažalost, ja ne ___ doći.* → **mogu** (хибні: možeš, može, moći)
- Скажіть уголос: *Hoćeš li ići u kino?* (Хочеш піти в кіно?); *S veseljem!* (Із задоволенням!)

**Урок 36 — Хобі / Hobiji** · граматика: regular

*Що ти любиш робити? / Što voliš raditi?*

- Petra: *Što voliš raditi u slobodno vrijeme?* — Що ти любиш робити у вільний час?
- Andrij: *Volim plivati i fotografirati.* — Я люблю плавати й фотографувати.
- Petra: *Gdje plivaš?* — Де ти плаваєш?
- Andrij: *Ljeti na moru, a zimi na bazenu.* — Влітку в морі, а взимку в басейні.
- Petra: *Ja više volim plesati.* — А я більше люблю танцювати.

*Футбол / Nogomet*

- Luka: *Igraš li nogomet?* — Ти граєш у футбол?
- Taras: *Igram, svake nedjelje s kolegama.* — Граю, щонеділі з колегами.
- Luka: *Mogu li i ja igrati s vama?* — Можна й мені грати з вами?
- Taras: *Naravno! Dođi u nedjelju u deset.* — Звісно! Приходь у неділю о десятій.

- Вставте слово: *Ja ___ plivati.* → **volim** (хибні: voliš, voli, vole)
- Скажіть уголос: *Volim pjevati.* (Я люблю співати.); *Što voliš raditi?* (Що ти любиш робити?)

**Урок 37 — Що ти думаєш? / Što misliš?** · граматика: conjunctions

*Після кіно / Poslije kina*

- Ana: *Kako ti se sviđa film?* — Як тобі фільм?
- Oleg: *Zanimljiv je, ali predug.* — Цікавий, але задовгий.
- Ana: *Meni je dosadan.* — А мені нудний.
- Oleg: *Zašto?* — Чому?
- Ana: *Zato što znam kraj od početka!* — Бо я знаю кінець від самого початку!

*Порада / Preporuka*

- Iryna: *Što da čitam na hrvatskom?* — Що мені почитати хорватською?
- Marko: *Probaj stripove jer su laki.* — Спробуй комікси, бо вони легкі.
- Iryna: *Misliš li da je to dobro za učenje?* — Думаєш, це добре для навчання?
- Marko: *Mislim da jest. Ili gledaj filmove s titlovima.* — Думаю, що так. Або дивись фільми із субтитрами.

- Вставте слово: *Volim ovaj film ___ je zanimljiv.* → **jer** (хибні: ali, ili, a)
- Скажіть уголос: *Mislim da je to zanimljivo.* (Я думаю, що це цікаво.); *Sviđa mi se jer je lako.* (Мені подобається, бо це легко.)

**Урок 38 — Почуття / Osjećaji** · граматика: conjunctions · новий

*Що з тобою? / Što ti je?*

- Ana: *Što ti je? Izgledaš tužno.* — Що з тобою? Ти сумно виглядаєш.
- Oksana: *Nedostaje mi obitelj. Ponekad sam usamljena.* — Я сумую за родиною. Іноді мені самотньо.
- Ana: *Razumijem. Hoćeš li doći k meni na kavu?* — Розумію. Хочеш прийти до мене на каву?
- Oksana: *Hoću, hvala. Sretna sam jer te imam.* — Так, дякую. Я щаслива, що ти в мене є.

*Перед співбесідою / Prije razgovora za posao*

- Taras: *Jako sam nervozan.* — Я дуже нервую.
- Marko: *Zašto? Ti si odličan!* — Чому? Ти чудовий!
- Taras: *Zabrinut sam jer ne govorim dobro hrvatski.* — Я хвилююся, бо погано говорю хорватською.
- Marko: *Govoriš sasvim dobro. Ne brini!* — Ти говориш цілком добре. Не хвилюйся!

- Вставте слово: *Sretna sam ___ si ovdje.* → **jer** (хибні: ali, ili, a)
- Скажіть уголос: *Danas sam sretan.* (Я сьогодні щасливий.); *Ne brini!* (Не хвилюйся!)

**Урок 39 — Домовляємося про зустріч / Dogovor** · граматика: questions · новий

*Плани на неділю / Planovi za nedjelju*

- Luka: *Bok! Jesi li slobodna u nedjelju?* — Привіт! Ти вільна в неділю?
- Iryna: *Jesam. Zašto?* — Так. А що?
- Luka: *Idemo na izlet na Sljeme. Hoćeš s nama?* — Ми йдемо в похід на Слеме. Хочеш з нами?
- Iryna: *Hoću! Gdje se nalazimo?* — Хочу! Де зустрічаємося?
- Luka: *Ispred kolodvora, u devet točno.* — Перед вокзалом, рівно о дев’ятій.

*Що взяти? / Što ponijeti?*

- Iryna: *Što trebam ponijeti?* — Що мені взяти з собою?
- Luka: *Vodu, sendvič i udobne cipele.* — Воду, сендвіч і зручне взуття.
- Iryna: *Je li daleko do vrha planine?* — Далеко до вершини гори?
- Luka: *Oko dva sata hoda.* — Близько двох годин пішки.

- Вставте слово: *___ se nalazimo? — Ispred kolodvora.* → **Gdje** (хибні: Kada, Kako, Tko)
- Скажіть уголос: *Gdje se nalazimo?* (Де зустрічаємося?); *U koliko sati?* (О котрій?)

### A1.9 — Хорватія / Hrvatska

**Урок 40 — Погода / Vrijeme** · граматика: comparison

*Прогноз / Prognoza*

- Ivan: *Kakva je prognoza za sutra?* — Який прогноз на завтра?
- Olena: *Kiša i vjetar.* — Дощ і вітер.
- Ivan: *Opet kiša? Danas je ljepše.* — Знову дощ? Сьогодні гарніше.
- Olena: *Ponesi sutra kišobran!* — Візьми завтра парасолю!

*Найкраща пора року / Najljepše godišnje doba*

- Maja: *Koje godišnje doba voliš najviše?* — Яку пору року ти любиш найбільше?
- Taras: *Proljeće. Toplije je nego zimi, a nije prevruće.* — Весну. Тепліше, ніж узимку, і не надто спекотно.
- Maja: *Ja volim jesen jer je najmirnija.* — А я люблю осінь, бо вона найспокійніша.
- Taras: *U Zagrebu je zima hladnija nego u Splitu.* — У Загребі зима холодніша, ніж у Спліті.

- Вставте слово: *Danas je ___ nego jučer.* → **toplije** (хибні: toplo, topao, najtoplije)
- Скажіть уголос: *Danas je hladnije nego jučer.* (Сьогодні холодніше, ніж учора.); *Ponesi kišobran!* (Візьми парасолю!)

**Урок 41 — На острів / Na otok** · граматика: lokativ

*Квиток на пором / Karta za trajekt*

- Oksana: *Dvije karte za Brač i jedan auto, molim.* — Два квитки на Брач і одне авто, будь ласка.
- Blagajnik: *Trajekt polazi u deset sati.* — Пором відправляється о десятій.
- Oksana: *Koliko dugo traje vožnja?* — Скільки триває поїздка?
- Blagajnik: *Pedeset minuta. Čekajte u drugom redu.* — П’ятдесят хвилин. Чекайте в другому ряду.

*На пляжі / Na plaži*

- Andrij: *Gdje spavate na otoku?* — Де ви ночуєте на острові?
- Petra: *U malom apartmanu u Bolu.* — У маленьких апартаментах у Болі.
- Andrij: *I mi smo u Bolu! Na kojoj plaži ste?* — Ми теж у Болі! На якому ви пляжі?
- Petra: *Na Zlatnom ratu. More je predivno, kupamo se svaki dan!* — На Златному Раті. Море чудове, ми купаємося щодня!

- Вставте слово: *Ljeti živimo na ___.* → **otoku** (хибні: otok, otoka, otokom)
- Скажіть уголос: *Na plaži smo.* (Ми на пляжі.); *Odmaramo se na otoku.* (Ми відпочиваємо на острові.)

**Урок 42 — Свята / Blagdani** · граматика: possessives

*Різдво / Božić*

- Ana: *Koji je najveći blagdan u vašoj obitelji?* — Яке найбільше свято у вашій родині?
- Iryna: *Božić. Naša obitelj slavi dvadeset petog prosinca.* — Різдво. Наша родина святкує двадцять п’ятого грудня.
- Ana: *I mi! Što je vaše tradicionalno jelo?* — І ми! Яка ваша традиційна страва?
- Iryna: *Kutja. A vaše?* — Кутя. А ваша?
- Ana: *Bakalar i sarma. Moja baka kuha najbolju sarmu!* — Тріска й сарма. Моя бабуся готує найкращу сарму!

*Подарунок / Poklon*

- Marko: *Ovo je za tebe i tvoju djecu.* — Це для тебе і твоїх дітей.
- Taras: *Hvala puno! Naša djeca vole čokoladu.* — Дуже дякую! Наші діти люблять шоколад.
- Marko: *Sretan Božić vama i vašoj obitelji!* — Щасливого Різдва вам і вашій родині!
- Taras: *Hvala, i tebi i tvojima!* — Дякую, і тобі, і твоїм рідним!

- Вставте слово: *Ovo je ___ obitelj.* → **naša** (хибні: naš, naše, našu)
- Скажіть уголос: *Sretan Božić!* (Щасливого Різдва!); *To je naša tradicija.* (Це наша традиція.)

**Урок 43 — Краї Хорватії / Hrvatski krajevi** · граматика: comparison · новий

*Звідки ти? / Odakle si?*

- Iryna: *Marko, ti si iz Dalmacije?* — Марку, ти з Далмації?
- Marko: *Da, iz Splita. To je na jugu, na moru.* — Так, зі Спліта. Це на півдні, біля моря.
- Iryna: *A Ana je iz Slavonije?* — А Ана зі Славонії?
- Marko: *Da, iz Osijeka, na istoku. Tamo su ravnice i rijeke.* — Так, з Осієка, на сході. Там рівнини й річки.
- Iryna: *Koji je kraj najljepši?* — Який край найкрасивіший?
- Marko: *Svaki je lijep na svoj način!* — Кожен гарний по-своєму!

*Поїздка в Істрію / Izlet u Istru*

- Taras: *Je li Istra daleko od Zagreba?* — Істрія далеко від Загреба?
- Lana: *Oko tri sata autom. Na zapadu je.* — Близько трьох годин машиною. Вона на заході.
- Taras: *Po čemu je Istra poznata?* — Чим відома Істрія?
- Lana: *Po tartufima, maslinovom ulju i starim gradovima.* — Трюфелями, оливковою олією і старими містечками.
- Taras: *Zvuči odlično!* — Звучить чудово!

- Вставте слово: *Split je ___ od Osijeka.* → **veći** (хибні: velik, najveći, veliki)
- Скажіть уголос: *Zagreb je glavni grad Hrvatske.* (Загреб — столиця Хорватії.); *Živim na sjeveru.* (Я живу на півночі.)

**Урок 44 — Хорватські звичаї / Hrvatski običaji** · граматика: irregular · новий

*Кава — це зустріч / Kava je druženje*

- Iryna: *Zašto Hrvati piju kavu tako dugo?* — Чому хорвати так довго п’ють каву?
- Ivan: *Kava nije samo piće. To je druženje!* — Кава — це не просто напій. Це спілкування!
- Iryna: *Sat vremena za jednu kavu?* — Година на одну каву?
- Ivan: *Naravno! Sjedimo na terasi i pričamo.* — Звісно! Сидимо на терасі й розмовляємо.

*Недільний обід / Nedjeljni ručak*

- Baka: *Dobro došli! Sjednite, ručak je spreman.* — Ласкаво просимо! Сідайте, обід готовий.
- Taras: *Hvala! Ovo vino je za Vas.* — Дякую! Це вино для вас.
- Baka: *Hvala, dušo! Živjeli!* — Дякую, любий! Будьмо!
- Taras: *Živjeli! U Ukrajini kažemo «Budmo!».* — Будьмо! В Україні кажемо «Будьмо!».

- Вставте слово: *Hrvati ___ kavu na terasi.* → **piju** (хибні: pijem, piješ, pije)
- Скажіть уголос: *Živjeli!* (Будьмо!); *Dobro došli!* (Ласкаво просимо!)

### A1.10 — Підсумок A1 / Ponavljanje i provjera A1

**Урок 45 — Розкажіть про себе / Recite nešto o sebi** · граматика: questions

*На курсі / Na tečaju*

- Profesorica: *Recite nešto o sebi.* — Розкажіть щось про себе.
- Oleg: *Zovem se Oleg. Imam četrdeset godina i živim u Rijeci.* — Мене звати Олег. Мені сорок років, і я живу в Рієці.
- Profesorica: *Čime se bavite?* — Чим ви займаєтеся?
- Oleg: *Radim u luci. Imam ženu i dvoje djece.* — Працюю в порту. У мене дружина і двоє дітей.
- Profesorica: *Zašto učite hrvatski?* — Чому ви вчите хорватську?
- Oleg: *Zato što želim razgovarati s kolegama.* — Тому що хочу розмовляти з колегами.

*Нова знайома / Nova poznanica*

- Iva: *Koliko dugo si u Hrvatskoj?* — Як довго ти в Хорватії?
- Oksana: *Tri godine. Volim Rijeku, ali mi nedostaje dom.* — Три роки. Люблю Рієку, але сумую за домом.
- Iva: *Razumijem. Što radiš vikendom?* — Розумію. Що ти робиш на вихідних?
- Oksana: *Šetam uz more i učim kuhati hrvatska jela.* — Гуляю вздовж моря і вчуся готувати хорватські страви.

- Вставте слово: *___ učite hrvatski? — Zato što radim ovdje.* → **Zašto** (хибні: Kada, Gdje, Kako)
- Скажіть уголос: *Učim hrvatski jer radim ovdje.* (Я вчу хорватську, бо працюю тут.); *Čime se bavite?* (Чим ви займаєтеся?)

**Урок 46 — Пошта і банкомат / Pošta i bankomat** · граматика: genitiv

*На пошті / Na pošti*

- Službenica: *Sljedeći, molim.* — Наступний, будь ласка.
- Taras: *Želim poslati ovaj paket u Ukrajinu.* — Я хочу надіслати цю посилку в Україну.
- Službenica: *Ispunite ovaj obrazac, molim.* — Заповніть цей бланк, будь ласка.
- Taras: *Koliko dugo putuje?* — Скільки часу вона йде?
- Službenica: *Oko deset dana.* — Близько десяти днів.

*Де банкомат? / Gdje je bankomat?*

- Olena: *Oprostite, ima li ovdje blizu neki bankomat?* — Вибачте, тут поблизу є якийсь банкомат?
- Prolaznik: *Ima, kod banke, preko puta pošte.* — Є, біля банку, навпроти пошти.
- Olena: *Je li daleko od tržnice?* — Це далеко від ринку?
- Prolaznik: *Nije, dvije minute pješice.* — Ні, дві хвилини пішки.

- Вставте слово: *Bankomat je preko puta ___.* → **pošte** (хибні: pošta, poštu, pošti)
- Скажіть уголос: *Gdje je najbliža pošta?* (Де найближча пошта?); *Želim otvoriti račun.* (Я хочу відкрити рахунок.)

**Урок 47 — Моє життя в Хорватії / Moj život u Hrvatskoj** · граматика: irregular

*Плани на літо / Planovi za ljeto*

- Ivan: *Ideš li ljeti u Ukrajinu?* — Ти їдеш улітку в Україну?
- Iryna: *Ne idem. Moja mama dolazi k meni.* — Ні. Моя мама приїжджає до мене.
- Ivan: *Super! Što želite vidjeti?* — Чудово! Що ви хочете побачити?
- Iryna: *Želim joj pokazati Plitvice i more.* — Хочу показати їй Плітвіце й море.
- Ivan: *Ako hoćete, mogu vas voziti.* — Якщо хочете, можу вас повозити.

*Рік у Хорватії / Godina u Hrvatskoj*

- Ana: *Jesi li sretna ovdje?* — Ти щаслива тут?
- Iryna: *Jesam. Imam posao, stan i prijatelje.* — Так. У мене є робота, квартира й друзі.
- Ana: *A jezik?* — А мова?
- Iryna: *Svaki dan razumijem više. Sada mogu razgovarati s tobom!* — Щодня розумію більше. Тепер можу розмовляти з тобою!

- Вставте слово: *Moja mama ___ k meni.* → **dolazi** (хибні: dolazim, dolaziš, dolaze)
- Скажіть уголос: *Dobro mi je ovdje.* (Мені тут добре.); *Sada mogu razgovarati na hrvatskom.* (Тепер я можу розмовляти хорватською.)

**Урок 48 — Дитячий садок і школа / Vrtić i škola** · граматика: genitiv · новий

*Запис у садок / Upis u vrtić*

- Mama: *Dobar dan, želim upisati sina u vrtić.* — Добрий день, я хочу записати сина в садок.
- Ravnateljica: *Koliko ima godina?* — Скільки йому років?
- Mama: *Četiri. Koji su dokumenti potrebni?* — Чотири. Які документи потрібні?
- Ravnateljica: *Rodni list, potvrda o cijepljenju i Vaš OIB.* — Свідоцтво про народження, довідка про щеплення і ваш OIB.
- Mama: *Ima li mjesta od rujna?* — Чи є місце з вересня?

*Розмова з учителькою / Razgovor s učiteljicom*

- Učiteljica: *Vaša kći je dobra učenica, ali ne piše zadaću.* — Ваша донька хороша учениця, але не робить домашнього завдання.
- Tata: *Hm. Ona još slabo čita hrvatski.* — Хм. Вона ще погано читає хорватською.
- Učiteljica: *Razumijem. Može ostati u produženom boravku i učiti s nama.* — Розумію. Вона може лишатися на продовженому дні й вчитися з нами.
- Tata: *Odlično, hvala. Kada je roditeljski sastanak?* — Чудово, дякую. Коли батьківські збори?

- Вставте слово: *Ima li ___ u vrtiću?* → **mjesta** (хибні: mjesto, mjestu, mjestom)
- Скажіть уголос: *Moj sin ide u vrtić.* (Мій син ходить у садок.); *Što je za zadaću?* (Що задали додому?)

**Урок 49 — У банку / U banci** · граматика: akuzativ · новий

*Відкрити рахунок / Otvaranje računa*

- Službenica: *Izvolite, kako Vam mogu pomoći?* — Прошу, чим можу допомогти?
- Andrij: *Želim otvoriti tekući račun.* — Я хочу відкрити поточний рахунок.
- Službenica: *Trebam Vašu putovnicu, OIB i dokaz o adresi.* — Мені потрібні ваш паспорт, OIB і підтвердження адреси.
- Andrij: *Kolika je mjesečna naknada?* — Яка щомісячна плата?
- Službenica: *Dva eura. Karticu dobivate za deset dana.* — Два євро. Картку отримаєте за десять днів.

*Картку заблоковано / Kartica je blokirana*

- Oksana: *Moja kartica ne radi. Bankomat ne daje novac.* — Моя картка не працює. Банкомат не видає гроші.
- Službenik: *Kartica je blokirana zbog krivog PIN-a.* — Картку заблоковано через неправильний PIN.
- Oksana: *Možete li je odblokirati?* — Можете її розблокувати?
- Službenik: *Mogu. Novi PIN dobivate u aplikaciji.* — Можу. Новий PIN отримаєте в застосунку.

- Вставте слово: *Želim otvoriti ___ račun.* → **tekući** (хибні: tekuća, tekuće, tekućem)
- Скажіть уголос: *Trebam podići novac.* (Мені потрібно зняти гроші.); *Koji je Vaš IBAN?* (Який ваш IBAN?)

## Вправи на слова

| Урок | Тип | Завдання | Відповідь | Варіанти |
|---|---|---|---|---|
| 1 | multiple_choice | Що означає «rano»? | рано | пізно · рано · обідати · вечеряти |
| 1 | multiple_choice | Що означає «ustajati»? | вставати (прокидатися і підніматися) | приймати душ · вставати (прокидатися і підніматися) · працювати, робити · рано |
| 1 | multiple_choice | Як хорватською «зазвичай»? | obično | kasno · buditi se · tuširati se · obično |
| 1 | type_answer | Напишіть хорватською: «вечеряти» | večerati |  |
| 1 | type_answer | Напишіть хорватською: «снідати» | doručkovati |  |
| 2 | multiple_choice | Що означає «šetati»? | прогулюватися / гуляти | книга · відпочивати · прогулюватися / гуляти · фільм |
| 2 | multiple_choice | Що означає «prijatelj»? | друг | слухати · дивитися · читати · друг |
| 2 | multiple_choice | Як хорватською «музика»? | glazba | čitati · glazba · knjiga · film |
| 2 | type_answer | Напишіть хорватською: «фільм» | film |  |
| 2 | type_answer | Напишіть хорватською: «слухати» | slušati |  |
| 3 | multiple_choice | Що означає «sport»? | спорт | спорт · пити · іноді / часом · могти |
| 3 | multiple_choice | Що означає «moći»? | могти | ніколи · могти · завжди · спорт |
| 3 | multiple_choice | Як хорватською «їсти»? | jesti | često · ponekad · jesti · rijetko |
| 3 | type_answer | Напишіть хорватською: «ніколи» | nikad |  |
| 3 | type_answer | Напишіть хорватською: «бігати» | trčati |  |
| 4 | multiple_choice | Що означає «kućanski poslovi»? | домашні справи | пилососити · домашні справи · прибирати; готувати; зберігати · виносити |
| 4 | multiple_choice | Що означає «usisavati»? | пилососити | пилососити · прасувати · прибирати; готувати; зберігати · білизна (для прання) |
| 4 | multiple_choice | Як хорватською «допомагати»? | pomagati | pomagati · prati · peglati · prašina |
| 4 | type_answer | Напишіть хорватською: «мити / прати» | prati |  |
| 4 | type_answer | Напишіть хорватською: «посуд» | suđe |  |
| 5 | multiple_choice | Що означає «obući se»? | одягнутися | поспішати · рушник · надворі · одягнутися |
| 5 | multiple_choice | Що означає «spreman»? | готовий | зубна щітка · мило · умитися · готовий |
| 5 | multiple_choice | Як хорватською «причісуватися»? | češljati se | češljati se · ručnik · sapun · oprati |
| 5 | type_answer | Напишіть хорватською: «рушник» | ručnik |  |
| 5 | type_answer | Напишіть хорватською: «надворі» | vani |  |
| 6 | multiple_choice | Що означає «vino»? | вино | головна страва · закуска · вино · меню |
| 6 | multiple_choice | Що означає «desert»? | десерт | суп / юшка · головна страва · замовити · десерт |
| 6 | multiple_choice | Як хорватською «ресторан»? | restoran | riba · salata · predjelo · restoran |
| 6 | type_answer | Напишіть хорватською: «забронювати» | rezervirati |  |
| 6 | type_answer | Напишіть хорватською: «замовити» | naručiti |  |
| 7 | multiple_choice | Що означає «ulje»? | олія | сіль · олія · часник · ніж |
| 7 | multiple_choice | Що означає «kuhati»? | варити / готувати їжу | перець · цибуля · ложка · варити / готувати їжу |
| 7 | multiple_choice | Як хорватською «цибуля»? | luk | sol · tanjur · luk · rajčica |
| 7 | type_answer | Напишіть хорватською: «помідор» | rajčica |  |
| 7 | type_answer | Напишіть хорватською: «тарілка» | tanjur |  |
| 8 | multiple_choice | Що означає «voće»? | фрукти | груша · фрукти · виноград · кілограм |
| 8 | multiple_choice | Що означає «komad»? | шматок, штука | кілограм · груша · шматок, штука · овочі |
| 8 | multiple_choice | Як хорватською «сир»? | sir | sir · grožđe · komad · kilogram |
| 8 | type_answer | Напишіть хорватською: «ринок / базар» | tržnica |  |
| 8 | type_answer | Напишіть хорватською: «овочі» | povrće |  |
| 9 | multiple_choice | Що означає «šećer»? | цукор | кафе / кав'ярня · домашній · цукор · тістечко / пиріг |
| 9 | multiple_choice | Що означає «burek»? | бурек (листковий пиріг) | офіціант · йогурт · кафе / кав'ярня · бурек (листковий пиріг) |
| 9 | multiple_choice | Як хорватською «офіціант»? | konobar | kava za van · slatko · burek · konobar |
| 9 | type_answer | Напишіть хорватською: «кафе / кав'ярня» | kafić |  |
| 9 | type_answer | Напишіть хорватською: «йогурт» | jogurt |  |
| 10 | multiple_choice | Що означає «previše»? | надто; забагато | алергія · вегетаріанець · принести · надто; забагато |
| 10 | multiple_choice | Що означає «orah»? | горіх | вегетаріанець · горіх · алергічний · смак |
| 10 | multiple_choice | Як хорватською «кислий»? | kiseo | okus · jelo · orah · kiseo |
| 10 | type_answer | Напишіть хорватською: «злий / сердитий» | ljut |  |
| 10 | type_answer | Напишіть хорватською: «смачний» | ukusan |  |
| 11 | multiple_choice | Що означає «jeftin»? | дешевий | дешевий · примірочна / кабінка · сорочка · сукня |
| 11 | multiple_choice | Що означає «jakna»? | куртка | дешевий · куртка · джинси · примірочна / кабінка |
| 11 | multiple_choice | Як хорватською «сорочка»? | košulja | mali · košulja · jakna · haljina |
| 11 | type_answer | Напишіть хорватською: «малий» | mali |  |
| 11 | type_answer | Напишіть хорватською: «джинси» | traperice |  |
| 12 | multiple_choice | Що означає «platiti»? | заплатити | черга · мусити / бути зобов'язаним · потребувати · заплатити |
| 12 | multiple_choice | Що означає «kupiti»? | купити | взяти · купити · пакет · заплатити |
| 12 | multiple_choice | Як хорватською «мусити / бути зобов'язаним»? | morati | vrećica · željeti · morati · kartica |
| 12 | type_answer | Напишіть хорватською: «кошик (для покупок)» | košarica |  |
| 12 | type_answer | Напишіть хорватською: «черга» | red |  |
| 13 | multiple_choice | Що означає «vratiti»? | повернути | ніколи · повернути · продавець · рахунок / чек |
| 13 | multiple_choice | Що означає «račun»? | рахунок / чек | повернути · ніхто · продавець · рахунок / чек |
| 13 | multiple_choice | Як хорватською «продавець»? | prodavač | prodavač · ništa · sviđati se · nikad |
| 13 | type_answer | Напишіть хорватською: «несправність / поломка» | kvar |  |
| 13 | type_answer | Напишіть хорватською: «замінити» | zamijeniti |  |
| 14 | multiple_choice | Що означає «krema»? | крем | зубна паста · шампунь · крем · акція; спеціальна пропозиція |
| 14 | multiple_choice | Що означає «pelene»? | підгузки | волосся · шампунь · полиця; страховий поліс · підгузки |
| 14 | multiple_choice | Як хорватською «магазин побутової хімії й косметики»? | drogerija | drogerija · deterdžent · krema · polica |
| 14 | type_answer | Напишіть хорватською: «шампунь» | šampon |  |
| 14 | type_answer | Напишіть хорватською: «сухий» | suh |  |
| 15 | multiple_choice | Що означає «poruka»? | повідомлення | передплата (поповнення рахунку) · SIM-картка · повідомлення · дзвонити; кликати |
| 15 | multiple_choice | Що означає «zvati»? | дзвонити; кликати | дзвонити; кликати · номер мобільного телефону · повідомлення · SIM-картка |
| 15 | multiple_choice | Як хорватською «інтернет»? | internet | internet · ostaviti · bon · aplikacija |
| 15 | type_answer | Напишіть хорватською: «додаток (app)» | aplikacija |  |
| 15 | type_answer | Напишіть хорватською: «зарядний пристрій» | punjač |  |
| 16 | multiple_choice | Що означає «presjedati»? | робити пересадку | трамвай · контролер · робити пересадку · зупинка / станція |
| 16 | multiple_choice | Що означає «vozač»? | водій | водій · зупинка / станція · квиток / карта · робити пересадку |
| 16 | multiple_choice | Як хорватською «громадський транспорт»? | javni prijevoz | poništač karata · kontrolor karata · javni prijevoz · sljedeći |
| 16 | type_answer | Напишіть хорватською: «автобус» | autobus |  |
| 16 | type_answer | Напишіть хорватською: «наступний» | sljedeći |  |
| 17 | multiple_choice | Що означає «vlak»? | поїзд | скільки · запізнення · поїзд · квиток туди і назад |
| 17 | multiple_choice | Що означає «kada»? | коли | поїзд · запізнення · коли · вокзал |
| 17 | multiple_choice | Як хорватською «перон»? | peron | dolazak · kada · peron · vozni red |
| 17 | type_answer | Напишіть хорватською: «відправлятися» | polaziti |  |
| 17 | type_answer | Напишіть хорватською: «вокзал» | kolodvor |  |
| 18 | multiple_choice | Що означає «avion»? | літак | аеропорт · вихід на посадку · валіза · літак |
| 18 | multiple_choice | Що означає «torba»? | сумка | ручна поклажа · аеропорт · посадковий талон · сумка |
| 18 | multiple_choice | Як хорватською «закордонний паспорт»? | putovnica | prtljaga · putovnica · izlaz za ukrcaj · sjedalo do prozora |
| 18 | type_answer | Напишіть хорватською: «ручна поклажа» | ručna prtljaga |  |
| 18 | type_answer | Напишіть хорватською: «рейс / політ» | let |  |
| 19 | multiple_choice | Що означає «stići»? | прибути / доїхати | прибути / доїхати · таксі · таксист · водити (авто) / везти |
| 19 | multiple_choice | Що означає «taksi»? | таксі | платити · водити (авто) / везти · прибути / доїхати · таксі |
| 19 | multiple_choice | Як хорватською «вчасно»? | na vrijeme | plaćati · stići · gužva · na vrijeme |
| 19 | type_answer | Напишіть хорватською: «зупинитися» | stati |  |
| 19 | type_answer | Напишіть хорватською: «платити» | plaćati |  |
| 20 | multiple_choice | Що означає «rezervoar»? | бак (паливний) | автомат (паркомат, автомат з продажу) · бак (паливний) · перевірити · штраф / покарання |
| 20 | multiple_choice | Що означає «automat»? | автомат (паркомат, автомат з продажу) | штраф / покарання · зона · паркуватися · автомат (паркомат, автомат з продажу) |
| 20 | multiple_choice | Як хорватською «паркуватися»? | parkirati | benzinska postaja · parkirati · dizel · auto |
| 20 | type_answer | Напишіть хорватською: «штраф / покарання» | kazna |  |
| 20 | type_answer | Напишіть хорватською: «зона» | zona |  |
| 21 | multiple_choice | Що означає «stanodavac»? | власник житла / орендодавець | власник житла / орендодавець · комунальні послуги / рахунки · договір / контракт · в'їхати (в житло) |
| 21 | multiple_choice | Що означає «režije»? | комунальні послуги / рахунки | поверх · комунальні послуги / рахунки · орендна плата / квартплата · оренда |
| 21 | multiple_choice | Як хорватською «гараж»? | garaža | useliti se · garaža · režije · namješten |
| 21 | type_answer | Напишіть хорватською: «поверх» | kat |  |
| 21 | type_answer | Напишіть хорватською: «застава / депозит» | polog |  |
| 22 | multiple_choice | Що означає «perilica»? | пральна машина | кухня · майстер · ванна кімната · пральна машина |
| 22 | multiple_choice | Що означає «voda»? | вода | холодильник · опалення · вода · пральна машина |
| 22 | multiple_choice | Як хорватською «опалення»? | grijanje | hladnjak · utičnica · kvar · grijanje |
| 22 | type_answer | Напишіть хорватською: «кухня» | kuhinja |  |
| 22 | type_answer | Напишіть хорватською: «холодильник» | hladnjak |  |
| 23 | multiple_choice | Що означає «smeće»? | сміття | сусід · голосно · шум · сміття |
| 23 | multiple_choice | Що означає «parkiralište»? | автостоянка / парковка | шум · познайомитися / пізнати · автостоянка / парковка · тихо |
| 23 | multiple_choice | Як хорватською «шум»? | buka | vrata · glasno · smeće · buka |
| 23 | type_answer | Напишіть хорватською: «познайомитися / пізнати» | upoznati |  |
| 23 | type_answer | Напишіть хорватською: «двері» | vrata |  |
| 24 | multiple_choice | Що означає «korisnik»? | користувач | рахунок за електрику · користувач · пароль · увімкнений; включений |
| 24 | multiple_choice | Що означає «rok»? | дедлайн / термін | платіжна квитанція · дедлайн / термін · мобільний банкінг · роутер |
| 24 | multiple_choice | Як хорватською «увімкнений; включений»? | uključen | mobilno bankarstvo · uključen · uplatnica · tehničar |
| 24 | type_answer | Напишіть хорватською: «газ» | plin |  |
| 24 | type_answer | Напишіть хорватською: «пароль» | lozinka |  |
| 25 | multiple_choice | Що означає «ured»? | офіс / кабінет | заробітна плата · закінчувати · офіс / кабінет · робочий час |
| 25 | multiple_choice | Що означає «klijent»? | клієнт | колега (жінка) · клієнт · робочий час · офіс / кабінет |
| 25 | multiple_choice | Як хорватською «починати»? | počinjati | šef · ured · plaća · počinjati |
| 25 | type_answer | Напишіть хорватською: «закінчувати» | završavati |  |
| 25 | type_answer | Напишіть хорватською: «начальник / шеф» | šef |  |
| 26 | multiple_choice | Що означає «pitati»? | питати | вихідний день · питати · начальник / шеф · довідка / підтвердження |
| 26 | multiple_choice | Що означає «pušiti»? | курити | курити · мусити / бути зобов'язаним · вихідний день · сміти, мати дозвіл |
| 26 | multiple_choice | Як хорватською «мусити / бути зобов'язаним»? | morati | šef · godišnji odmor · potvrda · morati |
| 26 | type_answer | Напишіть хорватською: «начальник / шеф» | šef |  |
| 26 | type_answer | Напишіть хорватською: «лікарняний» | bolovanje |  |
| 27 | multiple_choice | Що означає «vozačka dozvola»? | водійське посвідчення | водійське посвідчення · почати · досвід · розмова / бесіда |
| 27 | multiple_choice | Що означає «plaća»? | заробітна плата | говорити · знати · досвід · заробітна плата |
| 27 | multiple_choice | Як хорватською «розмова / бесіда»? | razgovor | govoriti · ugovor · razgovor · vozač |
| 27 | type_answer | Напишіть хорватською: «водій» | vozač |  |
| 27 | type_answer | Напишіть хорватською: «говорити» | govoriti |  |
| 28 | multiple_choice | Що означає «prekovremeni sati»? | понаднормові години | понаднормові години · окремо; особливо · повний робочий день · тимчасовий захист |
| 28 | multiple_choice | Що означає «probni rad»? | випробувальний термін | виплата / зняття · випробувальний термін · зміна (на роботі) · повний робочий день |
| 28 | multiple_choice | Як хорватською «розрахунковий листок»? | platna lista | privremena zaštita · platna lista · radna dozvola · posebno |
| 28 | type_answer | Напишіть хорватською: «податок» | porez |  |
| 28 | type_answer | Напишіть хорватською: «зміна (на роботі)» | smjena |  |
| 29 | multiple_choice | Що означає «javiti se»? | обізватися; відповісти (на дзвінок); зголоситися | електронний лист; імейл · подзвонити / назвати · обізватися; відповісти (на дзвінок); зголоситися · відеодзвінок |
| 29 | multiple_choice | Що означає «videopoziv»? | відеодзвінок | повідомлення · залишити · відеодзвінок · пізніше |
| 29 | multiple_choice | Як хорватською «хворий»? | bolestan | link · videopoziv · bolestan · javiti se |
| 29 | type_answer | Напишіть хорватською: «залишити» | ostaviti |  |
| 29 | type_answer | Напишіть хорватською: «повідомлення» | poruka |  |
| 30 | multiple_choice | Що означає «pregled»? | медичний огляд / обстеження | медичне страхування · температура (жар) · медичний огляд / обстеження · біль |
| 30 | multiple_choice | Що означає «glava»? | голова | медичне страхування · голова · горло · біль |
| 30 | multiple_choice | Як хорватською «болити»? | boljeti | leđa · boljeti · zdravstveno osiguranje · termin |
| 30 | type_answer | Напишіть хорватською: «спина» | leđa |  |
| 30 | type_answer | Напишіть хорватською: «кашель» | kašalj |  |
| 31 | multiple_choice | Що означає «sirup protiv kašlja»? | сироп від кашлю | сироп від кашлю · аптека · ліки / медикамент · застуда |
| 31 | multiple_choice | Що означає «lijek protiv bolova»? | знеболювальне | знеболювальне · щодня; на день · аптека · вода |
| 31 | multiple_choice | Як хорватською «рецепт»? | recept | ljekarnik · ljekarna · recept · tableta |
| 31 | type_answer | Напишіть хорватською: «таблетка» | tableta |  |
| 31 | type_answer | Напишіть хорватською: «застуда» | prehlada |  |
| 32 | multiple_choice | Що означає «spavati»? | спати | спати · втомлений · добре · вітамін |
| 32 | multiple_choice | Що означає «zdrav»? | здоровий | здоровий · почуватися · відпочивати · втомлений |
| 32 | multiple_choice | Як хорватською «добре»? | dobro | svježi zrak · loše · zdrav · dobro |
| 32 | type_answer | Напишіть хорватською: «вітамін» | vitamin |  |
| 32 | type_answer | Напишіть хорватською: «почуватися» | osjećati se |  |
| 33 | multiple_choice | Що означає «usta»? | рот | вухо · рот · око · палець |
| 33 | multiple_choice | Що означає «prst»? | палець | коліно · око · палець · плече |
| 33 | multiple_choice | Як хорватською «вухо»? | uho | rame · oko · uho · vrat |
| 33 | type_answer | Напишіть хорватською: «серце» | srce |  |
| 33 | type_answer | Напишіть хорватською: «тіло» | tijelo |  |
| 34 | multiple_choice | Що означає «dolje»? | внизу | внизу · терміновий · зубний біль · пломба (зубна) |
| 34 | multiple_choice | Що означає «popravljati»? | ремонтувати (процес) | укол · ремонтувати (процес) · вгорі · пломба (зубна) |
| 34 | multiple_choice | Як хорватською «терміновий»? | hitan | hitan · osiguranje · zubobolja · zubar |
| 34 | type_answer | Напишіть хорватською: «стоматолог» | zubar |  |
| 34 | type_answer | Напишіть хорватською: «вгорі» | gore |  |
| 35 | multiple_choice | Що означає «slaviti»? | святкувати | святкувати · запросити · сьогодні ввечері · день народження |
| 35 | multiple_choice | Що означає «poziv»? | дзвінок / запрошення | побачимося · день народження · могти · дзвінок / запрошення |
| 35 | multiple_choice | Як хорватською «побачимося»? | vidimo se | slaviti · htjeti · poziv · vidimo se |
| 35 | type_answer | Напишіть хорватською: «могти» | moći |  |
| 35 | type_answer | Напишіть хорватською: «сьогодні ввечері» | večeras |  |
| 36 | multiple_choice | Що означає «fotografirati»? | фотографувати | плавати · танцювати · фотографувати · вільний час |
| 36 | multiple_choice | Що означає «igrati»? | грати | хобі / улюблена справа · грати · співати · футбол |
| 36 | multiple_choice | Як хорватською «плавати»? | plivati | fotografirati · slobodno vrijeme · plivati · igrati |
| 36 | type_answer | Напишіть хорватською: «співати» | pjevati |  |
| 36 | type_answer | Напишіть хорватською: «спорт» | sport |  |
| 37 | multiple_choice | Що означає «mišljenje»? | думка | але · подобатися · думка · цікавий |
| 37 | multiple_choice | Що означає «zato što»? | тому що | подобатися · фільм · тому що · нудний |
| 37 | multiple_choice | Як хорватською «рекомендувати»? | preporučiti | mišljenje · dosadan · preporučiti · misliti |
| 37 | type_answer | Напишіть хорватською: «або» | ili |  |
| 37 | type_answer | Напишіть хорватською: «нудний» | dosadan |  |
| 38 | multiple_choice | Що означає «nervozan»? | знервований; схвильований | турбуватися · почуття · знепокоєний / стурбований · знервований; схвильований |
| 38 | multiple_choice | Що означає «ljut»? | злий / сердитий | злий / сердитий · знервований; схвильований · здивований · самотній |
| 38 | multiple_choice | Як хорватською «самотній»? | usamljen | usamljen · iznenađen · izgledati · ljut |
| 38 | type_answer | Напишіть хорватською: «почуття» | osjećaj |  |
| 38 | type_answer | Напишіть хорватською: «турбуватися» | brinuti se |  |
| 39 | multiple_choice | Що означає «izlet»? | поїздка; екскурсія | домовленість · вершина · поїздка; екскурсія · перед |
| 39 | multiple_choice | Що означає «točno»? | точно, правильно | за / позаду · точно, правильно · сендвіч · зручний |
| 39 | multiple_choice | Як хорватською «зручний»? | udoban | ponijeti · nalaziti se · sendvič · udoban |
| 39 | type_answer | Напишіть хорватською: «вершина» | vrh |  |
| 39 | type_answer | Напишіть хорватською: «сендвіч» | sendvič |  |
| 40 | multiple_choice | Що означає «hladan»? | холодний | вітер · хмара · холодний · осінь |
| 40 | multiple_choice | Що означає «topao»? | теплий | теплий · дощ · сніг · прогноз погоди |
| 40 | multiple_choice | Як хорватською «дощ»? | kiša | kiša · godišnja doba · kišobran · oblak |
| 40 | type_answer | Напишіть хорватською: «пори року» | godišnja doba |  |
| 40 | type_answer | Напишіть хорватською: «хмара» | oblak |  |
| 41 | multiple_choice | Що означає «obala»? | берег / узбережжя | подорож · берег / узбережжя · апартаменти / квартира · поромний порт |
| 41 | multiple_choice | Що означає «trajekt»? | пором | апартаменти / квартира · літо · поромний порт · пором |
| 41 | multiple_choice | Як хорватською «поромний порт»? | trajektna luka | apartman · odmor · ljeto · trajektna luka |
| 41 | type_answer | Напишіть хорватською: «купатися» | kupati se |  |
| 41 | type_answer | Напишіть хорватською: «сонце» | sunce |  |
| 42 | multiple_choice | Що означає «naš»? | наш | сім'я, родина · традиція · наш · їхній |
| 42 | multiple_choice | Що означає «njihov»? | їхній | Різдво · свято · подарунок · їхній |
| 42 | multiple_choice | Як хорватською «ваш»? | vaš | njihov · tradicija · zajedno · vaš |
| 42 | type_answer | Напишіть хорватською: «традиція» | tradicija |  |
| 42 | type_answer | Напишіть хорватською: «щасливий» | sretan |  |
| 43 | multiple_choice | Що означає «rijeka»? | річка | річка · південь · рівнина · схід |
| 43 | multiple_choice | Що означає «glavni grad»? | столиця | південь · спосіб · схід · столиця |
| 43 | multiple_choice | Як хорватською «північ»? | sjever | način · maslinovo ulje · sjever · rijeka |
| 43 | type_answer | Напишіть хорватською: «схід» | istok |  |
| 43 | type_answer | Напишіть хорватською: «південь» | jug |  |
| 44 | multiple_choice | Що означає «živjeli»? | будьмо! (тост) | напій · будьмо! (тост) · сидіти · звичай |
| 44 | multiple_choice | Що означає «gost»? | гість / відвідувач | будьмо! (тост) · довго · гість / відвідувач · розповідати; розмовляти |
| 44 | multiple_choice | Як хорватською «ласкаво просимо»? | dobro došli | dobro došli · pričati · živjeli · običaj |
| 44 | type_answer | Напишіть хорватською: «традиційний» | tradicionalan |  |
| 44 | type_answer | Напишіть хорватською: «тераса» | terasa |  |
| 45 | multiple_choice | Що означає «grad»? | місто | робота / справа · місто · квартира · розмовляти |
| 45 | multiple_choice | Що означає «godina»? | рік | квартира · рік · сім'я, родина · мова |
| 45 | multiple_choice | Як хорватською «жити»? | živjeti | raditi · godina · živjeti · učiti |
| 45 | type_answer | Напишіть хорватською: «вчити (ся)» | učiti |  |
| 45 | type_answer | Напишіть хорватською: «діти» | djeca |  |
| 46 | multiple_choice | Що означає «poslati»? | надіслати / відправити | пошта · надіслати / відправити · банк · черга |
| 46 | multiple_choice | Що означає «blizu»? | поруч / близько | банкомат · поруч / близько · бланк / анкета · гроші |
| 46 | multiple_choice | Як хорватською «бланк / анкета»? | obrazac | pismo · obrazac · red · poslati |
| 46 | type_answer | Напишіть хорватською: «черга» | red |  |
| 46 | type_answer | Напишіть хорватською: «пошта» | pošta |  |
| 47 | multiple_choice | Що означає «život»? | життя | життя · хотіти · щасливий · приходити |
| 47 | multiple_choice | Що означає «sretan»? | щасливий | життя · щасливий · друг · море |
| 47 | multiple_choice | Як хорватською «разом»? | zajedno | pokazati · ići · život · zajedno |
| 47 | type_answer | Напишіть хорватською: «місто» | grad |  |
| 47 | type_answer | Напишіть хорватською: «прийти» | doći |  |
| 48 | multiple_choice | Що означає «učiteljica»? | учителька | слабо; погано · дитячий садок · учителька · домашнє завдання |
| 48 | multiple_choice | Що означає «zadaća»? | домашнє завдання | директорка (школи, садка) · дитячий садок · місце · домашнє завдання |
| 48 | multiple_choice | Як хорватською «щеплення»? | cijepljenje | rodni list · učiteljica · vrtić · cijepljenje |
| 48 | type_answer | Напишіть хорватською: «директорка (школи, садка)» | ravnateljica |  |
| 48 | type_answer | Напишіть хорватською: «учениця» | učenica |  |
| 49 | multiple_choice | Що означає «kriv»? | неправильний / винний | неправильний / винний · підняти; зняти гроші · поточний рахунок у банку · відчинити / відкрити |
| 49 | multiple_choice | Що означає «PIN»? | PIN-код | PIN-код · підняти; зняти гроші · додаток (app) · заблокований |
| 49 | multiple_choice | Як хорватською «розблокувати»? | odblokirati | blokiran · tekući račun · odblokirati · dobiti |
| 49 | type_answer | Напишіть хорватською: «додаток (app)» | aplikacija |  |
| 49 | type_answer | Напишіть хорватською: «заблокований» | blokiran |  |