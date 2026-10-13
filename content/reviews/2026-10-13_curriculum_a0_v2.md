# Перевірка контенту: розширення уроків A0 (curriculum_a0_v2)

**Дата:** 2026-10-13  
**Хто перевіряв:** AI (Claude) + автоматичні перевірки генератора. Носій мови — ще ні.  
**Статус:** PUBLISHED як **бета** — рішення власника 2026-10-13 («повна структура уроку, одразу всі 30 уроків, 10–15 хв»).

Файли:

- дані: `scripts/curriculum_a0_v2_data.py`;
- знімок слів і перекладів робочої бази: `scripts/curriculum_a0_v2_snapshot.json`;
- генератор: `scripts/gen_curriculum_a0_v2.py` (`--review` друкує таблицю вправ на слова);
- SQL: `supabase/data_fixes/20261013_curriculum_a0_v2.sql` (потрібна міграція M13);
- тести: `supabase/tests/curriculum_v2.test.sql`.

## Чому

Уроки v1 були на 3–5 хвилин: 1 діалог, 5–7 слів, 3 вправи. Цього замало, щоб слово запам’яталося і щоб учень сам щось сказав.

## Що додано

| Що | Скільки | Статус |
|---|---|---|
| Слова в уроках | +139 зв’язків «урок — слово» (разом 10–12 слів в уроці) | PUBLISHED |
| Нові слова у словнику | 13: *kako si, kako ste, hvala lijepa, jagoda, tjestenina, preko puta, nažalost, u redu, ukupno, napojnica, datum rođenja, termin, sladak* | PUBLISHED |
| Друга сцена діалогу | 30 (147 реплік) — та сама тема в іншій життєвій ситуації | PUBLISHED |
| Нові вправи | 272: у кожному уроці +9 (урок 1: +11) | PUBLISHED |
| Виправлені переклади | 4: *skupo* «дороге» → «дорого», *jeftino* «дешеве» → «дешево», *vruće* «гаряче» → «гаряче; спекотно», *piće* «напої» → «напій» (стара версія — у `content_versions`) | PUBLISHED |

Нові вправи в кожному уроці:

1. 2 × «Що означає «…»?» — вибір перекладу (4 варіанти);
2. 1 × «Як хорватською «…»?» — вибір хорватського слова;
3. 2 × «Напишіть хорватською: «…»» — новий тип `type_answer` (перевірка як у тренажері: діакритики й одна одруківка — зараховано);
4. «Складіть речення» і «Аудіювання» — з другої сцени;
5. 2 × «Скажіть уголос» — новий тип `speaking` (розпізнавання браузером, як у VS-003; без мікрофона вправу можна пропустити).

Разом в уроці: 10–12 слів, 2 діалоги, граматика, 12 вправ — приблизно **12 хвилин** (`lessons.estimated_minutes = 12`).

## Як побудовані вправи на слова

- Беруться слова самого уроку; спершу — нові слова v2.
- Хибні варіанти — з цього уроку, потім з модуля, потім з усього A0.
- Генератор не ставить поруч переклади, що перетинаються («рахунок / чек» і «рахунок, будь ласка») чи синоніми (тато / батько, мама / мати).
- Слова з однаковим перекладом (*ovaj / taj* — «цей», *imati / majka* — «мати») не бувають відповіддю в «Як хорватською» і «Напишіть».
- *da* і *molim* не використовуються: у них кілька далеких значень.
- «Напишіть» — лише для слів до 14 літер і до двох слів.

## Автоматичні перевірки

Генератор зупиняється, якщо щось не так:

- [x] у хорватському тексті немає кирилиці, в українському вона є;
- [x] кожне слово уроку є в словнику (знімок бази) або серед нових слів;
- [x] у кожному уроці 8–12 слів;
- [x] сцена має 4–6 реплік;
- [x] «аудіювання» взято з другої сцени;
- [x] у «складіть» і «аудіюванні» слова не повторюються;
- [x] у кожній вправі з вибором 4 різні варіанти;
- [x] `normalized` нових слів = лема без діакритик.

Локально (Postgres 16, baseline + міграції + дані v1):

- [x] SQL застосовано двічі поспіль — без дублів;
- [x] самоперевірка в кінці файла пройшла;
- [x] усі 10 SQL-тестів проходять, зокрема новий `curriculum_v2.test.sql` (19 перевірок).

## Мовна перевірка (AI)

Що варто глянути носію в першу чергу:

1. **Урок 21:** *Izvolite dvadeset pet. U redu je.* перекладено як «Ось двадцять п’ять. Решти не треба». Чи природно так сказати офіціанту? Альтернатива — *Zadržite ostatak.*
2. **Урок 4:** *Izvolite sjesti.* — чи не краще *Izvolite, sjednite.*?
3. **Урок 22:** *Kilu jagoda* — розмовне (замість *kilogram*). Залишили, бо так кажуть на ринку.
4. Форми роду:
   - *Umorna sam* (урок 1, говорить жінка);
   - *Izgubio sam se* (урок 28, чоловіча форма; жінка скаже *Izgubila sam se*).

   Розпізнавання мовлення прийме обидві, якщо вимова зрозуміла. Підказку про жіночу форму варто додати в граматику.
5. **Урок 10, *termin*:** переклад «(вільний) час; запис (до лікаря, перукаря)» довгий для варіанта відповіді, але точний.

Мовлення («скажіть уголос») оцінюється так само, як у розділі «Говоріння»: розпізнавання браузера hr-HR + `lib/speaking.ts`. Аудіо не зберігається.

## Нові сцени і фрази «скажіть уголос»

**Урок 1 — У сусідки / Kod susjede**

- Ivana: *Dobar dan, gospodine Petrenko! Kako ste?* — Добрий день, пане Петренко! Як ви?
- Petrenko: *Dobro, hvala. A Vi?* — Добре, дякую. А ви?
- Ivana: *Ne baš dobro. Umorna sam.* — Не дуже добре. Я втомлена.
- Petrenko: *Žao mi je.* — Мені шкода.
- Ivana: *Hvala. Doviđenja!* — Дякую. До побачення!
- Скажіть уголос: *Bok! Kako si?* (Привіт! Як справи?); *Žao mi je.* (Мені шкода.)

**Урок 2 — Увечері в готелі / Navečer u hotelu**

- Recepcionarka: *Dobra večer! Izvolite?* — Добрий вечір! Слухаю вас?
- Olena: *Dobra večer. Imam rezervaciju.* — Добрий вечір. У мене бронювання.
- Recepcionarka: *Da, izvolite ključ. Soba broj dvanaest.* — Так, ось ключ. Кімната номер дванадцять.
- Olena: *Hvala lijepa. Laku noć!* — Щиро дякую. На добраніч!
- Recepcionarka: *Laku noć i ugodan boravak!* — На добраніч і приємного перебування!
- Скажіть уголос: *Jednu kavu, molim.* (Одну каву, будь ласка.); *Imam rezervaciju.* (У мене бронювання.)

**Урок 3 — У магазині / U trgovini**

- Prodavačica: *Trebate li vrećicu?* — Вам потрібен пакет?
- Olena: *Oprostite, ne razumijem. Možete li ponoviti?* — Вибачте, не розумію. Можете повторити?
- Prodavačica: *Vrećicu? Trebate li vrećicu?* — Пакет? Вам потрібен пакет?
- Olena: *Ah, da. Jednu, molim.* — А, так. Один, будь ласка.
- Prodavačica: *Izvolite.* — Прошу.
- Olena: *Hvala!* — Дякую!
- Скажіть уголос: *Možete li govoriti polako?* (Можете говорити повільно?); *Možete li ponoviti?* (Можете повторити?)

**Урок 4 — На прийомі в лікаря / Kod liječnika**

- Medicinska sestra: *Dobar dan. Kako se zovete?* — Добрий день. Як вас звати?
- Oleg: *Zovem se Oleg.* — Мене звати Олег.
- Medicinska sestra: *A Vaše prezime?* — А ваше прізвище?
- Oleg: *Petrenko.* — Петренко.
- Medicinska sestra: *Hvala, gospodine Petrenko. Izvolite sjesti.* — Дякую, пане Петренко. Сідайте, будь ласка.
- Скажіть уголос: *Zovem se Oleg.* (Мене звати Олег.); *Drago mi je.* (Приємно познайомитися.)

**Урок 5 — На каві з колегою / S kolegom na kavi**

- Marko: *Odakle si?* — Звідки ти?
- Iryna: *Iz Ukrajine, iz Lavova. A ti?* — З України, зі Львова. А ти?
- Marko: *Ja sam iz Splita, ali živim u Zagrebu.* — Я зі Спліта, але живу в Загребі.
- Iryna: *Zagreb je lijep grad.* — Загреб — гарне місто.
- Marko: *Da, ali more je daleko!* — Так, але море далеко!
- Скажіть уголос: *Ja sam iz Ukrajine.* (Я з України.); *Živim u Zagrebu.* (Я живу в Загребі.)

**Урок 6 — Співбесіда / Razgovor za posao**

- Direktorica: *Dobar dan. Što ste po zanimanju?* — Добрий день. Хто ви за фахом?
- Oksana: *Ja sam medicinska sestra.* — Я медсестра.
- Direktorica: *Imate li iskustva?* — У вас є досвід?
- Oksana: *Da, pet godina.* — Так, п’ять років.
- Direktorica: *Odlično. Govorite li hrvatski?* — Чудово. Ви говорите хорватською?
- Oksana: *Malo. Učim hrvatski.* — Трохи. Я вчу хорватську.
- Скажіть уголос: *Ja sam programer.* (Я програміст.); *Učim hrvatski.* (Я вчу хорватську.)

**Урок 7 — Доставка / Dostava**

- Dostavljač: *Dobar dan! Koji je Vaš kućni broj?* — Добрий день! Який номер вашого будинку?
- Ana: *Broj sedam.* — Номер сім.
- Dostavljač: *A stan?* — А квартира?
- Ana: *Stan broj tri, na drugom katu.* — Квартира номер три, на другому поверсі.
- Dostavljač: *Hvala! Stižem za pet minuta.* — Дякую! Буду за п’ять хвилин.
- Скажіть уголос: *Ponovi, molim te.* (Повтори, будь ласка.); *Broj sedam.* (Номер сім.)

**Урок 8 — У парку / U parku**

- Luka: *Koliko imaš godina?* — Скільки тобі років?
- Sofija: *Imam šest godina. A ti?* — Мені шість років. А тобі?
- Luka: *Ja imam sedam. Ovo je moj pas.* — Мені сім. Це мій пес.
- Sofija: *Koliko godina ima pas?* — Скільки років собаці?
- Luka: *Dvije.* — Два.
- Скажіть уголос: *Imam trideset pet godina.* (Мені тридцять п’ять років.); *Koliko imaš godina?* (Скільки тобі років?)

**Урок 9 — У пекарні / U pekari**

- Prodavačica: *Dobro jutro! Izvolite?* — Доброго ранку! Що бажаєте?
- Kupac: *Jedan kruh i dva kroasana, molim.* — Одну хлібину й два круасани, будь ласка.
- Prodavačica: *Još nešto?* — Ще щось?
- Kupac: *Ne, hvala. Koliko je to?* — Ні, дякую. Скільки з мене?
- Prodavačica: *Četiri eura i dvadeset centi.* — Чотири євро двадцять центів.
- Скажіть уголос: *Koliko to košta?* (Скільки це коштує?); *Jedan kruh, molim.* (Один хліб, будь ласка.)

**Урок 10 — Запис до перукаря / Kod frizera**

- Frizerka: *Frizerski salon, izvolite.* — Перукарня, слухаю.
- Marta: *Dobar dan. Imate li slobodan termin u četvrtak?* — Добрий день. У вас є вільний час у четвер?
- Frizerka: *U četvrtak ne, ali u petak da.* — У четвер ні, а в п’ятницю так.
- Marta: *Petak je dobro. Hvala!* — П’ятниця підходить. Дякую!
- Frizerka: *U redu, vidimo se u petak.* — Добре, побачимося в п’ятницю.
- Скажіть уголос: *Danas je srijeda.* (Сьогодні середа.); *Vidimo se u petak!* (Побачимося в п’ятницю!)

**Урок 11 — Вранці вдома / Ujutro kod kuće**

- Mama: *Ustani, kasno je!* — Вставай, уже пізно!
- Dino: *Koliko je sati?* — Котра година?
- Mama: *Sedam i pol.* — Пів на восьму.
- Dino: *Škola počinje u osam. Imam vremena!* — Школа починається о восьмій. У мене є час!
- Mama: *Nemaš! Autobus ide u sedam i četrdeset.* — Немає! Автобус їде о сьомій сорок.
- Скажіть уголос: *Koliko je sati?* (Котра година?); *U jedanaest sati.* (Об одинадцятій.)

**Урок 12 — Плани на відпустку / Planovi za godišnji**

- Ana: *Kada ideš na godišnji odmor?* — Коли ти йдеш у відпустку?
- Ivan: *U kolovozu. Idem na more.* — У серпні. Їду на море.
- Ana: *Ja idem u rujnu. Tada nije tako vruće.* — Я йду у вересні. Тоді не так спекотно.
- Ivan: *Imaš pravo.* — Ти маєш рацію.
- Скажіть уголос: *Volim ljeto.* (Я люблю літо.); *Rođendan mi je u srpnju.* (Мій день народження в липні.)

**Урок 13 — Фото на телефоні / Slika na mobitelu**

- Maja: *Je li ovo tvoja mama?* — Це твоя мама?
- Oleg: *Da, to je moja mama, a ovo je moj tata.* — Так, це моя мама, а це мій тато.
- Maja: *Gdje žive?* — Де вони живуть?
- Oleg: *U Kijevu. Baka i djed žive na selu.* — У Києві. Бабуся й дідусь живуть у селі.
- Maja: *Lijepa obitelj!* — Гарна родина!
- Скажіть уголос: *Ovo je moja obitelj.* (Це моя родина.); *Tko je to?* (Хто це?)

**Урок 14 — На дні народження / Na rođendanu**

- Petra: *Tko je ovo?* — Хто це?
- Andrij: *Ovo je moja žena Olga.* — Це моя дружина Ольга.
- Petra: *Drago mi je! Imate li djecu?* — Приємно познайомитися! У вас є діти?
- Olga: *Imamo jednog sina. Zove se Maksim.* — У нас один син. Його звати Максим.
- Petra: *Koliko ima godina?* — Скільки йому років?
- Olga: *Četiri.* — Чотири.
- Скажіть уголос: *Imam jednu sestru.* (У мене одна сестра.); *Imate li djecu?* (У вас є діти?)

**Урок 15 — Після школи / Poslije škole**

- Teta: *Kako je bilo u školi?* — Як було в школі?
- Tin: *Dobro! Imam novog prijatelja.* — Добре! У мене новий друг.
- Teta: *Kako se zove?* — Як його звати?
- Tin: *Zove se Bohdan. On je iz Ukrajine.* — Його звати Богдан. Він з України.
- Teta: *Super! Pozovi ga k nama.* — Супер! Запроси його до нас.
- Скажіть уголос: *Imam sina i kćer.* (У мене син і донька.); *Kako se zove?* (Як його звати?)

**Урок 16 — Оренда квартири / Najam stana**

- Oleg: *Koliko je najam?* — Скільки коштує оренда?
- Agentica: *Petsto eura mjesečno.* — П’ятсот євро на місяць.
- Oleg: *Je li uključena struja?* — Електрика входить у ціну?
- Agentica: *Ne, režije se plaćaju posebno.* — Ні, комунальні оплачуються окремо.
- Oleg: *U redu. Mogu li doći sutra?* — Добре. Можу прийти завтра?
- Скажіть уголос: *Gdje je kuhinja?* (Де кухня?); *Mogu li doći sutra?* (Можу прийти завтра?)

**Урок 17 — Де телефон? / Gdje je mobitel?**

- Ivan: *Vidiš li moj mobitel?* — Ти бачиш мій телефон?
- Ana: *Je li na krevetu?* — Він на ліжку?
- Ivan: *Nije.* — Ні.
- Ana: *Evo ga, pored televizora!* — Ось він, біля телевізора!
- Ivan: *Hvala!* — Дякую!
- Скажіть уголос: *Gdje su moji ključevi?* (Де мої ключі?); *Evo ih!* (Ось вони!)

**Урок 18 — У меблевому магазині / U trgovini namještajem**

- Prodavač: *Trebate li pomoć?* — Вам допомогти?
- Kupac: *Da. Tražim stol i četiri stolice.* — Так. Шукаю стіл і чотири стільці.
- Prodavač: *Ovaj stol je od drva.* — Цей стіл дерев’яний.
- Kupac: *Lijep je. Koliko košta?* — Гарний. Скільки коштує?
- Prodavač: *Tristo eura.* — Триста євро.
- Скажіть уголос: *Što ima u tvojoj sobi?* (Що є у твоїй кімнаті?); *Koliko košta?* (Скільки коштує?)

**Урок 19 — Сніданок / Doručak**

- Mama: *Što želiš za doručak?* — Що хочеш на сніданок?
- Dino: *Jaja i kruh.* — Яйця і хліб.
- Mama: *A za piće? Mlijeko ili sok?* — А пити? Молоко чи сік?
- Dino: *Sok od naranče, molim.* — Апельсиновий сік, будь ласка.
- Скажіть уголос: *Jako sam gladan.* (Я дуже голодний.); *Jaja i kruh.* (Яйця і хліб.)

**Урок 20 — Замовлення їжі / Narudžba**

- Konobar: *Želite li nešto jesti?* — Бажаєте щось поїсти?
- Gost: *Što preporučujete?* — Що порадите?
- Konobar: *Danas imamo dobru juhu i tjesteninu.* — Сьогодні в нас смачний суп і паста.
- Gost: *Onda juhu, molim.* — Тоді суп, будь ласка.
- Konobar: *Odmah stiže.* — Зараз принесу.
- Скажіть уголос: *Kavu s mlijekom, molim.* (Каву з молоком, будь ласка.); *Što preporučujete?* (Що порадите?)

**Урок 21 — Розрахунок / Plaćanje**

- Konobarica: *Ukupno dvadeset dva eura.* — Разом двадцять два євро.
- Gost: *Izvolite dvadeset pet. U redu je.* — Ось двадцять п’ять. Решти не треба.
- Konobarica: *Hvala lijepa! Doviđenja!* — Щиро дякую! До побачення!
- Gost: *Doviđenja!* — До побачення!
- Скажіть уголос: *Molim vas, račun.* (Рахунок, будь ласка.); *Mogu li platiti karticom?* (Можна заплатити карткою?)

**Урок 22 — Полуниці / Jagode**

- Kupac: *Jesu li jagode slatke?* — Полуниці солодкі?
- Prodavač: *Jako slatke! Probajte.* — Дуже солодкі! Спробуйте.
- Kupac: *Odlične su. Kilu jagoda, molim.* — Чудові. Кілограм полуниць, будь ласка.
- Prodavač: *Pet eura. Još nešto?* — П’ять євро. Ще щось?
- Kupac: *Ne, to je sve.* — Ні, це все.
- Скажіть уголос: *Kilu jabuka, molim.* (Кілограм яблук, будь ласка.); *Ne, to je sve.* (Ні, це все.)

**Урок 23 — Примірочна / U kabini**

- Kupac: *Mogu li probati ovu majicu?* — Можна приміряти цю футболку?
- Prodavačica: *Naravno, kabina je lijevo.* — Звісно, примірочна ліворуч.
- Kupac: *Ova je mala. Imate li veću?* — Ця мала. Є більша?
- Prodavačica: *Imamo. Izvolite, veličina L.* — Є. Прошу, розмір L.
- Скажіть уголос: *Koliko košta ova majica?* (Скільки коштує ця футболка?); *Uzet ću plavu.* (Візьму синю.)

**Урок 24 — Картку не приймає / Kartica ne prolazi**

- Blagajnik: *Dvadeset eura, molim.* — Двадцять євро, будь ласка.
- Kupac: *Izvolite karticu.* — Ось картка.
- Blagajnik: *Nažalost, kartica ne prolazi.* — На жаль, картка не проходить.
- Kupac: *Onda gotovinom.* — Тоді готівкою.
- Blagajnik: *Hvala. Izvolite račun.* — Дякую. Ось чек.
- Скажіть уголос: *Gotovinom ili karticom?* (Готівкою чи карткою?); *Onda gotovinom.* (Тоді готівкою.)

**Урок 25 — На зупинці / Na stanici**

- Turist: *Oprostite, koji autobus ide do centra?* — Вибачте, який автобус їде до центру?
- Gospođa: *Broj šest.* — Номер шість.
- Turist: *Gdje je stanica?* — Де зупинка?
- Gospođa: *Tamo, preko puta.* — Там, навпроти.
- Turist: *Hvala Vam!* — Дякую вам!
- Скажіть уголос: *Je li daleko?* (Це далеко?); *Gdje je stanica?* (Де зупинка?)

**Урок 26 — У музеї / U muzeju**

- Ana: *Dvije ulaznice, molim.* — Два квитки, будь ласка.
- Blagajnica: *Šesnaest eura. Studenti imaju popust.* — Шістнадцять євро. Студенти мають знижку.
- Ana: *Nismo studenti.* — Ми не студенти.
- Blagajnica: *U redu. Muzej radi do šest.* — Добре. Музей працює до шостої.
- Скажіть уголос: *Idemo u muzej!* (Ходімо в музей!); *Dvije ulaznice, molim.* (Два квитки, будь ласка.)

**Урок 27 — У поїзді / U vlaku**

- Kondukter: *Karte, molim.* — Квитки, будь ласка.
- Putnica: *Izvolite.* — Прошу.
- Kondukter: *Hvala. Presjedate u Zagrebu.* — Дякую. У вас пересадка в Загребі.
- Putnica: *Koliko traje vožnja?* — Скільки триває поїздка?
- Kondukter: *Oko dva sata.* — Близько двох годин.
- Скажіть уголос: *Jednu kartu za Split, molim.* (Один квиток до Спліта, будь ласка.); *Kada ide autobus?* (Коли їде автобус?)

**Урок 28 — На рецепції / Na recepciji**

- Oleg: *Dobra večer. Imate li slobodnu sobu?* — Добрий вечір. У вас є вільний номер?
- Recepcionar: *Imamo. Za koliko noći?* — Є. На скільки ночей?
- Oleg: *Za dvije noći.* — На дві ночі.
- Recepcionar: *Može. Trebam Vašu putovnicu.* — Можна. Мені потрібен ваш паспорт.
- Скажіть уголос: *Možete li mi pomoći?* (Можете мені допомогти?); *Izgubio sam se.* (Я заблукав.)

**Урок 29 — У лікаря / Kod liječnice**

- Liječnica: *Što Vas boli?* — Що у вас болить?
- Pacijent: *Boli me glava.* — У мене болить голова.
- Liječnica: *Imate li temperaturu?* — У вас є температура?
- Pacijent: *Da, malo.* — Так, трохи.
- Liječnica: *Izvolite recept. Pijte puno vode.* — Ось рецепт. Пийте багато води.
- Скажіть уголос: *Trebam pomoć.* (Мені потрібна допомога.); *Boli me glava.* (У мене болить голова.)

**Урок 30 — В установі / U uredu**

- Službenik: *Sljedeći, molim!* — Наступний, будь ласка!
- Oleg: *Dobar dan. Gdje mogu predati zahtjev?* — Добрий день. Де можна подати заяву?
- Službenik: *Ovdje. Ispunite ovaj obrazac.* — Тут. Заповніть цю форму.
- Oleg: *Na kojem jeziku?* — Якою мовою?
- Službenik: *Na hrvatskom. Datum rođenja pišite ovdje.* — Хорватською. Дату народження пишіть тут.
- Скажіть уголос: *Potpišite ovdje, molim.* (Підпишіть тут, будь ласка.); *Na kojem jeziku?* (Якою мовою?)


## Вправи на слова (усі 150)

| Урок | Тип | Завдання | Відповідь | Варіанти |
|---|---|---|---|---|
| 1 | multiple_choice | Що означає «loše»? | погано | добре · погано · привіт / бувай · втомлений |
| 1 | multiple_choice | Що означає «kako si»? | як ти?; як справи? (до друга) | як ти?; як справи? (до друга) · ні · втомлений · мені шкода |
| 1 | multiple_choice | Як хорватською «ні»? | ne | hvala lijepa · ne · bok · umoran |
| 1 | type_answer | Напишіть хорватською: «втомлений» | umoran |  |
| 1 | type_answer | Напишіть хорватською: «добре» | dobro |  |
| 1 | sentence_builder | Складіть: «Добре, дякую. А ви?» | Dobro, hvala. A Vi? |  |
| 1 | sentence_builder | Складіть: «Привіт! Як справи?» | Bok! Kako si? |  |
| 1 | listening | Прослухайте і складіть фразу | Ne baš dobro. Umorna sam. |  |
| 1 | listening | Прослухайте і складіть фразу | Dobro sam, hvala. |  |
| 1 | speaking | Привіт! Як справи? | Bok! Kako si? |  |
| 1 | speaking | Мені шкода. | Žao mi je. |  |
| 2 | multiple_choice | Що означає «soba»? | кімната | надобраніч · кімната · бронювання / резерв · ключ |
| 2 | multiple_choice | Що означає «rezervacija»? | бронювання / резерв | доброго ранку · добрий день · надобраніч · бронювання / резерв |
| 2 | multiple_choice | Як хорватською «ключ»? | ključ | kava · ugodan dan · ključ · dobar dan |
| 2 | type_answer | Напишіть хорватською: «кава» | kava |  |
| 2 | type_answer | Напишіть хорватською: «щиро дякую» | hvala lijepa |  |
| 2 | sentence_builder | Складіть: «Добрий вечір. У мене бронювання.» | Dobra večer. Imam rezervaciju. |  |
| 2 | listening | Прослухайте і складіть фразу | Hvala lijepa. Laku noć! |  |
| 2 | speaking | Одну каву, будь ласка. | Jednu kavu, molim. |  |
| 2 | speaking | У мене бронювання. | Imam rezervaciju. |  |
| 3 | multiple_choice | Що означає «malo»? | мало / трохи | прошу / будь ласка / що (ви сказали)? · мало / трохи · можете повторити · пакет |
| 3 | multiple_choice | Що означає «govoriti»? | говорити | звісно / звичайно · вибачте / перепрошую · говорити · англійська (мова) |
| 3 | multiple_choice | Як хорватською «англійська (мова)»? | engleski | možete li ponoviti · ne razumijem · engleski · malo |
| 3 | type_answer | Напишіть хорватською: «повільно» | polako |  |
| 3 | type_answer | Напишіть хорватською: «пакет» | vrećica |  |
| 3 | sentence_builder | Складіть: «Вибачте, не розумію.» | Oprostite, ne razumijem. |  |
| 3 | listening | Прослухайте і складіть фразу | Trebate li vrećicu? |  |
| 3 | speaking | Можете говорити повільно? | Možete li govoriti polako? |  |
| 3 | speaking | Можете повторити? | Možete li ponoviti? |  |
| 4 | multiple_choice | Що означає «vi»? | ви | як тебе звати · прізвище · привіт / бувай · ви |
| 4 | multiple_choice | Що означає «gospodin»? | пан | ти · пан · ім'я · як вас звати |
| 4 | multiple_choice | Як хорватською «ти»? | ti | ti · zovem se · gospođa · drago mi je |
| 4 | type_answer | Напишіть хорватською: «пані» | gospođa |  |
| 4 | type_answer | Напишіть хорватською: «я» | ja |  |
| 4 | sentence_builder | Складіть: «Добрий день. Як вас звати?» | Dobar dan. Kako se zovete? |  |
| 4 | listening | Прослухайте і складіть фразу | A Vaše prezime? |  |
| 4 | speaking | Мене звати Олег. | Zovem se Oleg. |  |
| 4 | speaking | Приємно познайомитися. | Drago mi je. |  |
| 5 | multiple_choice | Що означає «Hrvatska»? | Хорватія | українець · звідки ви · море · Хорватія |
| 5 | multiple_choice | Що означає «ali»? | але | море · звідки ви · хорват · але |
| 5 | multiple_choice | Як хорватською «далеко»? | daleko | lijep · Hrvatska · daleko · ukrajinac |
| 5 | type_answer | Напишіть хорватською: «красивий» | lijep |  |
| 5 | type_answer | Напишіть хорватською: «море» | more |  |
| 5 | sentence_builder | Складіть: «Загреб — гарне місто.» | Zagreb je lijep grad. |  |
| 5 | listening | Прослухайте і складіть фразу | Da, ali more je daleko! |  |
| 5 | speaking | Я з України. | Ja sam iz Ukrajine. |  |
| 5 | speaking | Я живу в Загребі. | Živim u Zagrebu. |  |
| 6 | multiple_choice | Що означає «medicinska sestra»? | медична сестра | робота / справа · програміст · досвід · медична сестра |
| 6 | multiple_choice | Що означає «odlično»? | відмінно | школа · досвід · відмінно · медична сестра |
| 6 | multiple_choice | Як хорватською «хорватська (мова)»? | hrvatski | raditi · profesor · zanimanje · hrvatski |
| 6 | type_answer | Напишіть хорватською: «досвід» | iskustvo |  |
| 6 | type_answer | Напишіть хорватською: «вчити (ся)» | učiti |  |
| 6 | sentence_builder | Складіть: «Я медсестра.» | Ja sam medicinska sestra. |  |
| 6 | listening | Прослухайте і складіть фразу | Malo. Učim hrvatski. |  |
| 6 | speaking | Я програміст. | Ja sam programer. |  |
| 6 | speaking | Я вчу хорватську. | Učim hrvatski. |  |
| 7 | multiple_choice | Що означає «dva»? | два | вісім · два · один · шість |
| 7 | multiple_choice | Що означає «broj»? | номер / число | сім · номер / число · дев'ять · чотири |
| 7 | multiple_choice | Як хорватською «три»? | tri | dva · deset · tri · nula |
| 7 | type_answer | Напишіть хорватською: «нуль» | nula |  |
| 7 | type_answer | Напишіть хорватською: «п'ять» | pet |  |
| 7 | sentence_builder | Складіть: «Квартира номер три.» | Stan broj tri. |  |
| 7 | listening | Прослухайте і складіть фразу | Stižem za pet minuta. |  |
| 7 | speaking | Повтори, будь ласка. | Ponovi, molim te. |  |
| 7 | speaking | Номер сім. | Broj sedam. |  |
| 8 | multiple_choice | Що означає «star»? | старий | тридцять · собака · старий · скільки вам років |
| 8 | multiple_choice | Що означає «pedeset»? | п'ятдесят | двадцять · п'ятдесят · мати · тридцять |
| 8 | multiple_choice | Як хорватською «собака»? | pas | trideset · koliko godina imate · dvadeset · pas |
| 8 | type_answer | Напишіть хорватською: «двадцять» | dvadeset |  |
| 8 | type_answer | Напишіть хорватською: «сорок» | četrdeset |  |
| 8 | sentence_builder | Складіть: «Скільки тобі років?» | Koliko imaš godina? |  |
| 8 | listening | Прослухайте і складіть фразу | Ovo je moj pas. |  |
| 8 | speaking | Мені тридцять п’ять років. | Imam trideset pet godina. |  |
| 8 | speaking | Скільки тобі років? | Koliko imaš godina? |  |
| 9 | multiple_choice | Що означає «pekara»? | пекарня | дорого · пекарня · сік · хліб |
| 9 | multiple_choice | Що означає «jeftino»? | дешево | ціна · кава · коштувати · дешево |
| 9 | multiple_choice | Як хорватською «дорого»? | skupo | cijena · sok · euro · skupo |
| 9 | type_answer | Напишіть хорватською: «хліб» | kruh |  |
| 9 | type_answer | Напишіть хорватською: «цент» | cent |  |
| 9 | sentence_builder | Складіть: «Ні, дякую. Скільки з мене?» | Ne, hvala. Koliko je to? |  |
| 9 | listening | Прослухайте і складіть фразу | Četiri eura i dvadeset centi. |  |
| 9 | speaking | Скільки це коштує? | Koliko to košta? |  |
| 9 | speaking | Один хліб, будь ласка. | Jedan kruh, molim. |  |
| 10 | multiple_choice | Що означає «u redu»? | гаразд; добре | гаразд; добре · середа · понеділок · четвер |
| 10 | multiple_choice | Що означає «termin»? | (вільний) час; запис (до лікаря, перукаря) | вівторок · четвер · завтра · (вільний) час; запис (до лікаря, перукаря) |
| 10 | multiple_choice | Як хорватською «який сьогодні день»? | koji je danas dan | sutra · termin · koji je danas dan · srijeda |
| 10 | type_answer | Напишіть хорватською: «неділя» | nedjelja |  |
| 10 | type_answer | Напишіть хорватською: «п'ятниця» | petak |  |
| 10 | sentence_builder | Складіть: «Добре, побачимося в п’ятницю.» | U redu, vidimo se u petak. |  |
| 10 | listening | Прослухайте і складіть фразу | Petak je dobro. |  |
| 10 | speaking | Сьогодні середа. | Danas je srijeda. |  |
| 10 | speaking | Побачимося в п’ятницю! | Vidimo se u petak! |  |
| 11 | multiple_choice | Що означає «noć»? | ніч | автобус · рано · школа · ніч |
| 11 | multiple_choice | Що означає «vrijeme»? | погода / час | котра година · ніч · погода / час · автобус |
| 11 | multiple_choice | Як хорватською «ранок»? | jutro | jutro · sat · noć · kasno |
| 11 | type_answer | Напишіть хорватською: «школа» | škola |  |
| 11 | type_answer | Напишіть хорватською: «автобус» | autobus |  |
| 11 | sentence_builder | Складіть: «Школа починається о восьмій.» | Škola počinje u osam. |  |
| 11 | listening | Прослухайте і складіть фразу | Ustani, kasno je! |  |
| 11 | speaking | Котра година? | Koliko je sati? |  |
| 11 | speaking | Об одинадцятій. | U jedanaest sati. |  |
| 12 | multiple_choice | Що означає «godišnji odmor»? | щорічна відпустка | осінь · любити, подобатися · день народження · щорічна відпустка |
| 12 | multiple_choice | Що означає «vruće»? | гаряче; спекотно | вересень · гаряче; спекотно · любити, подобатися · липень |
| 12 | multiple_choice | Як хорватською «серпень»? | kolovoz | proljeće · kolovoz · jesen · voljeti |
| 12 | type_answer | Напишіть хорватською: «вересень» | rujan |  |
| 12 | type_answer | Напишіть хорватською: «літо» | ljeto |  |
| 12 | sentence_builder | Складіть: «У серпні. Їду на море.» | U kolovozu. Idem na more. |  |
| 12 | listening | Прослухайте і складіть фразу | Tada nije tako vruće. |  |
| 12 | speaking | Я люблю літо. | Volim ljeto. |  |
| 12 | speaking | Мій день народження в липні. | Rođendan mi je u srpnju. |  |
| 13 | multiple_choice | Що означає «tata»? | тато | бабуся · тато · мати · дідусь |
| 13 | multiple_choice | Що означає «djed»? | дідусь | батьки · дідусь · батько · брат |
| 13 | multiple_choice | Як хорватською «бабуся»? | baka | mama · roditelji · baka · djed |
| 13 | type_answer | Напишіть хорватською: «мама» | mama |  |
| 13 | type_answer | Напишіть хорватською: «село» | selo |  |
| 13 | sentence_builder | Складіть: «Бабуся й дідусь живуть у селі.» | Baka i djed žive na selu. |  |
| 13 | listening | Прослухайте і складіть фразу | Je li ovo tvoja mama? |  |
| 13 | speaking | Це моя родина. | Ovo je moja obitelj. |  |
| 13 | speaking | Хто це? | Tko je to? |  |
| 14 | multiple_choice | Що означає «koliko»? | скільки | син · жінка, дружина · брат · скільки |
| 14 | multiple_choice | Що означає «djeca»? | діти | брат · діти · син · дуже приємно |
| 14 | multiple_choice | Як хорватською «дуже приємно»? | drago mi je | koliko · sestra · brat · drago mi je |
| 14 | type_answer | Напишіть хорватською: «син» | sin |  |
| 14 | type_answer | Напишіть хорватською: «сестра» | sestra |  |
| 14 | sentence_builder | Складіть: «У нас один син.» | Imamo jednog sina. |  |
| 14 | listening | Прослухайте і складіть фразу | Ovo je moja žena Olga. |  |
| 14 | speaking | У мене одна сестра. | Imam jednu sestru. |  |
| 14 | speaking | У вас є діти? | Imate li djecu? |  |
| 15 | multiple_choice | Що означає «učitelj»? | вчитель | вчитель · дитина · дівчинка · хлопчик |
| 15 | multiple_choice | Що означає «igrati»? | грати | друг · дитина · грати · син |
| 15 | multiple_choice | Як хорватською «подруга»? | prijateljica | igrati · prijatelj · dječak · prijateljica |
| 15 | type_answer | Напишіть хорватською: «школа» | škola |  |
| 15 | type_answer | Напишіть хорватською: «друг» | prijatelj |  |
| 15 | sentence_builder | Складіть: «У мене новий друг.» | Imam novog prijatelja. |  |
| 15 | listening | Прослухайте і складіть фразу | Kako je bilo u školi? |  |
| 15 | speaking | У мене син і донька. | Imam sina i kćer. |  |
| 15 | speaking | Як його звати? | Kako se zove? |  |
| 16 | multiple_choice | Що означає «balkon»? | балкон | ванна кімната · наліво / ліворуч · балкон · направо / праворуч |
| 16 | multiple_choice | Що означає «režije»? | комунальні послуги / рахунки | балкон · комунальні послуги / рахунки · наліво / ліворуч · ванна кімната |
| 16 | multiple_choice | Як хорватською «вікно»? | prozor | režije · balkon · prozor · soba |
| 16 | type_answer | Напишіть хорватською: «оренда» | najam |  |
| 16 | type_answer | Напишіть хорватською: «вітальня» | dnevni boravak |  |
| 16 | sentence_builder | Складіть: «Скільки коштує оренда?» | Koliko je najam? |  |
| 16 | listening | Прослухайте і складіть фразу | Petsto eura mjesečno. |  |
| 16 | speaking | Де кухня? | Gdje je kuhinja? |  |
| 16 | speaking | Можу прийти завтра? | Mogu li doći sutra? |  |
| 17 | multiple_choice | Що означає «mobitel»? | мобільний телефон | над · двері · мобільний телефон · вікно |
| 17 | multiple_choice | Що означає «prozor»? | вікно | вікно · мобільний телефон · над · сумка |
| 17 | multiple_choice | Як хорватською «окуляри»? | naočale | iznad · prozor · naočale · torba |
| 17 | type_answer | Напишіть хорватською: «двері» | vrata |  |
| 17 | type_answer | Напишіть хорватською: «поруч» | pored |  |
| 17 | sentence_builder | Складіть: «Ти бачиш мій телефон?» | Vidiš li moj mobitel? |  |
| 17 | listening | Прослухайте і складіть фразу | Evo ga, pored televizora! |  |
| 17 | speaking | Де мої ключі? | Gdje su moji ključevi? |  |
| 17 | speaking | Ось вони! | Evo ih! |  |
| 18 | multiple_choice | Що означає «namještaj»? | меблі | стіл · меблі · шафа · телевізор |
| 18 | multiple_choice | Що означає «tražiti»? | шукати | шукати · картина / фотографія · телевізор · стіл |
| 18 | multiple_choice | Як хорватською «лампа»? | lampa | stolica · lampa · ormar · kauč |
| 18 | type_answer | Напишіть хорватською: «килим» | tepih |  |
| 18 | type_answer | Напишіть хорватською: «телевізор» | televizor |  |
| 18 | sentence_builder | Складіть: «Шукаю стіл і чотири стільці.» | Tražim stol i četiri stolice. |  |
| 18 | listening | Прослухайте і складіть фразу | Ovaj stol je od drva. |  |
| 18 | speaking | Що є у твоїй кімнаті? | Što ima u tvojoj sobi? |  |
| 18 | speaking | Скільки коштує? | Koliko košta? |  |
| 19 | multiple_choice | Що означає «jaje»? | яйце | яйце · сніданок · спраглий · обід |
| 19 | multiple_choice | Що означає «piće»? | напій | обід · напій · яблуко · апельсин |
| 19 | multiple_choice | Як хорватською «обід»? | ručak | jaje · ručak · sir · piće |
| 19 | type_answer | Напишіть хорватською: «апельсин» | naranča |  |
| 19 | type_answer | Напишіть хорватською: «сніданок» | doručak |  |
| 19 | sentence_builder | Складіть: «Що хочеш на сніданок?» | Što želiš za doručak? |  |
| 19 | listening | Прослухайте і складіть фразу | Sok od naranče, molim. |  |
| 19 | speaking | Я дуже голодний. | Jako sam gladan. |  |
| 19 | speaking | Яйця і хліб. | Jaja i kruh. |  |
| 20 | multiple_choice | Що означає «meso»? | м'ясо | макарони; паста · меню · м'ясо · з молоком |
| 20 | multiple_choice | Що означає «riba»? | риба | з молоком · кава · меню · риба |
| 20 | multiple_choice | Як хорватською «суп / юшка»? | juha | juha · mlijeko · jesti · kava |
| 20 | type_answer | Напишіть хорватською: «макарони; паста» | tjestenina |  |
| 20 | type_answer | Напишіть хорватською: «їсти» | jesti |  |
| 20 | sentence_builder | Складіть: «Тоді суп, будь ласка.» | Onda juhu, molim. |  |
| 20 | listening | Прослухайте і складіть фразу | Što preporučujete? |  |
| 20 | speaking | Каву з молоком, будь ласка. | Kavu s mlijekom, molim. |  |
| 20 | speaking | Що порадите? | Što preporučujete? |  |
| 21 | multiple_choice | Що означає «ukupno»? | разом; загалом | до побачення · разом; загалом · щиро дякую · рахунок, будь ласка |
| 21 | multiple_choice | Що означає «gotovina»? | готівка | готівка · щиро дякую · рахунок, будь ласка · до побачення |
| 21 | multiple_choice | Як хорватською «банківська картка»? | kartica | kartica · mogu li platiti karticom · ukupno · gotovina |
| 21 | type_answer | Напишіть хорватською: «до побачення» | doviđenja |  |
| 21 | type_answer | Напишіть хорватською: «щиро дякую» | hvala lijepa |  |
| 21 | sentence_builder | Складіть: «Разом двадцять два євро.» | Ukupno dvadeset dva eura. |  |
| 21 | listening | Прослухайте і складіть фразу | Izvolite dvadeset pet. |  |
| 21 | speaking | Рахунок, будь ласка. | Molim vas, račun. |  |
| 21 | speaking | Можна заплатити карткою? | Mogu li platiti karticom? |  |
| 22 | multiple_choice | Що означає «jagoda»? | полуниця | полуниця · солодкий · банан · овочі |
| 22 | multiple_choice | Що означає «sladak»? | солодкий | полуниця · фрукти · яблуко · солодкий |
| 22 | multiple_choice | Як хорватською «банан»? | banana | krumpir · banana · voće · koliko to košta |
| 22 | type_answer | Напишіть хорватською: «картопля» | krumpir |  |
| 22 | type_answer | Напишіть хорватською: «помідор» | rajčica |  |
| 22 | sentence_builder | Складіть: «Полуниці солодкі?» | Jesu li jagode slatke? |  |
| 22 | listening | Прослухайте і складіть фразу | Ne, to je sve. |  |
| 22 | speaking | Кілограм яблук, будь ласка. | Kilu jabuka, molim. |  |
| 22 | speaking | Ні, це все. | Ne, to je sve. |  |
| 23 | multiple_choice | Що означає «hlače»? | штани | штани · цей · той · малий |
| 23 | multiple_choice | Що означає «cipele»? | взуття / туфлі | цей · синій / блакитний · взуття / туфлі · червоний |
| 23 | multiple_choice | Як хорватською «малий»? | mali | onaj · hlače · mali · taj |
| 23 | type_answer | Напишіть хорватською: «розмір (одягу/взуття)» | veličina |  |
| 23 | type_answer | Напишіть хорватською: «червоний» | crven |  |
| 23 | sentence_builder | Складіть: «Можна приміряти цю футболку?» | Mogu li probati ovu majicu? |  |
| 23 | listening | Прослухайте і складіть фразу | Ova je mala. Imate li veću? |  |
| 23 | speaking | Скільки коштує ця футболка? | Koliko košta ova majica? |  |
| 23 | speaking | Візьму синю. | Uzet ću plavu. |  |
| 24 | multiple_choice | Що означає «kartica»? | банківська картка | пакет · на жаль · банківська картка · євро |
| 24 | multiple_choice | Що означає «nažalost»? | на жаль | пакет · на жаль · карткою чи готівкою · до побачення |
| 24 | multiple_choice | Як хорватською «готівка»? | gotovina | doviđenja · kartica · vrećica · gotovina |
| 24 | type_answer | Напишіть хорватською: «рахунок / чек» | račun |  |
| 24 | type_answer | Напишіть хорватською: «цент» | cent |  |
| 24 | sentence_builder | Складіть: «На жаль, картка не проходить.» | Nažalost, kartica ne prolazi. |  |
| 24 | listening | Прослухайте і складіть фразу | Onda gotovinom. |  |
| 24 | speaking | Готівкою чи карткою? | Gotovinom ili karticom? |  |
| 24 | speaking | Тоді готівкою. | Onda gotovinom. |  |
| 25 | multiple_choice | Що означає «centar»? | центр | прямо · вокзал · центр · пішки |
| 25 | multiple_choice | Що означає «preko puta»? | навпроти | навпроти · прямо · вокзал · направо / праворуч |
| 25 | multiple_choice | Як хорватською «там»? | tamo | tamo · lijevo · desno · ovdje |
| 25 | type_answer | Напишіть хорватською: «тут» | ovdje |  |
| 25 | type_answer | Напишіть хорватською: «зупинка / станція» | stanica |  |
| 25 | sentence_builder | Складіть: «Який автобус їде до центру?» | Koji autobus ide do centra? |  |
| 25 | listening | Прослухайте і складіть фразу | Tamo, preko puta. |  |
| 25 | speaking | Це далеко? | Je li daleko? |  |
| 25 | speaking | Де зупинка? | Gdje je stanica? |  |
| 26 | multiple_choice | Що означає «ulica»? | вулиця | великий · площа · студент · вулиця |
| 26 | multiple_choice | Що означає «student»? | студент | вхідний квиток · місто · площа · студент |
| 26 | multiple_choice | Як хорватською «площа»? | trg | trg · student · nov · ulica |
| 26 | type_answer | Напишіть хорватською: «вхідний квиток» | ulaznica |  |
| 26 | type_answer | Напишіть хорватською: «відчинений / відкритий» | otvoren |  |
| 26 | sentence_builder | Складіть: «Два квитки, будь ласка.» | Dvije ulaznice, molim. |  |
| 26 | listening | Прослухайте і складіть фразу | Muzej radi do šest. |  |
| 26 | speaking | Ходімо в музей! | Idemo u muzej! |  |
| 26 | speaking | Два квитки, будь ласка. | Dvije ulaznice, molim. |  |
| 27 | multiple_choice | Що означає «dolazak»? | прибуття | перон · вокзал · прибуття · поїзд |
| 27 | multiple_choice | Що означає «putovati»? | подорожувати | подорожувати · годинник / година · поїзд · квиток / карта |
| 27 | multiple_choice | Як хорватською «поїзд»? | vlak | autobus · kolodvor · vlak · karta |
| 27 | type_answer | Напишіть хорватською: «вокзал» | kolodvor |  |
| 27 | type_answer | Напишіть хорватською: «годинник / година» | sat |  |
| 27 | sentence_builder | Складіть: «Скільки триває поїздка?» | Koliko traje vožnja? |  |
| 27 | listening | Прослухайте і складіть фразу | Oko dva sata. |  |
| 27 | speaking | Один квиток до Спліта, будь ласка. | Jednu kartu za Split, molim. |  |
| 27 | speaking | Коли їде автобус? | Kada ide autobus? |  |
| 28 | multiple_choice | Що означає «noć»? | ніч | ніч · готель · вільний · закордонний паспорт |
| 28 | multiple_choice | Що означає «slobodan»? | вільний | чи можете ви мені допомогти · рецепція · вільний · ніч |
| 28 | multiple_choice | Як хорватською «рецепція»? | recepcija | recepcija · soba · hotel · pomoći |
| 28 | type_answer | Напишіть хорватською: «закордонний паспорт» | putovnica |  |
| 28 | type_answer | Напишіть хорватською: «кімната» | soba |  |
| 28 | sentence_builder | Складіть: «У вас є вільний номер?» | Imate li slobodnu sobu? |  |
| 28 | listening | Прослухайте і складіть фразу | Za dvije noći. |  |
| 28 | speaking | Можете мені допомогти? | Možete li mi pomoći? |  |
| 28 | speaking | Я заблукав. | Izgubio sam se. |  |
| 29 | multiple_choice | Що означає «glava»? | голова | лікар · температура (жар) · голова · викликайте поліцію |
| 29 | multiple_choice | Що означає «temperatura»? | температура (жар) | температура (жар) · лікар · викликайте поліцію · мені потрібна допомога |
| 29 | multiple_choice | Як хорватською «рецепт»? | recept | upomoć · glava · trebam doktora · recept |
| 29 | type_answer | Напишіть хорватською: «аптека» | ljekarna |  |
| 29 | type_answer | Напишіть хорватською: «лікар» | liječnik |  |
| 29 | sentence_builder | Складіть: «У мене болить голова.» | Boli me glava. |  |
| 29 | listening | Прослухайте і складіть фразу | Imate li temperaturu? |  |
| 29 | speaking | Мені потрібна допомога. | Trebam pomoć. |  |
| 29 | speaking | У мене болить голова. | Boli me glava. |  |
| 30 | multiple_choice | Що означає «zahtjev»? | запит / заявка | адреса · закордонний паспорт · підпис · запит / заявка |
| 30 | multiple_choice | Що означає «jezik»? | мова | закордонний паспорт · прізвище · підписати · мова |
| 30 | multiple_choice | Як хорватською «підпис»? | potpis | potpis · zahtjev · potpisati · jezik |
| 30 | type_answer | Напишіть хорватською: «дата народження» | datum rođenja |  |
| 30 | type_answer | Напишіть хорватською: «бланк / анкета» | obrazac |  |
| 30 | sentence_builder | Складіть: «Де можна подати заяву?» | Gdje mogu predati zahtjev? |  |
| 30 | listening | Прослухайте і складіть фразу | Ispunite ovaj obrazac. |  |
| 30 | speaking | Підпишіть тут, будь ласка. | Potpišite ovdje, molim. |  |
| 30 | speaking | Якою мовою? | Na kojem jeziku? |  |
