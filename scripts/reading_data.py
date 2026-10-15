"""
Тексти для читання A1 (§6 ТЗ «Extensive Reading», §55: на A1 — мікротексти), v1 · 2026-10-14.

Текст: dict(
  code='RD-A1-001', type=<text_type з M15>, situation=<код ситуації або None>, module=<1–10, модуль A1, після якого читати>,
  title=(ua, hr), hr='''хорватський текст''', ua='''повний переклад''',
  questions=[(питання_ua, [3 варіанти_ua], правильний), …] — 3 питання на розуміння,
)
Граматика — A1: теперішній час, наказовий спосіб, модальні дієслова (минулий і майбутній час — A2).
Слова — переважно з уроків A0–A1; решту пояснює словничок (FORMS / EXTRA / NAMES), щоб кожне слово
можна було натиснути й побачити переклад (§56). Генератор: scripts/gen_reading.py.
"""

TEXTS: list = []

# =============================================================================
# A1.1 Повсякденне життя
# =============================================================================
TEXTS += [
    dict(code='RD-A1-001', type='message', situation='small_talk', module=1,
         title=('Повідомлення від подруги', 'Poruka od prijateljice'),
         hr='''Bok, Olena! Jesi li slobodna u subotu ujutro? Idem na tržnicu po voće i povrće, a onda na kavu. Hoćeš li sa mnom? Možemo se naći u devet ispred pekare. Javi mi! Ana''',
         ua='''Привіт, Олено! Ти вільна в суботу вранці? Я йду на ринок по фрукти й овочі, а потім на каву. Підеш зі мною? Можемо зустрітися о дев’ятій перед пекарнею. Дай знати! Ана''',
         questions=[
             ('Куди Ана йде в суботу?', ['На ринок і на каву', 'На роботу', 'До лікаря'], 'На ринок і на каву'),
             ('О котрій вони можуть зустрітися?', ['О восьмій', 'О дев’ятій', 'Опівдні'], 'О дев’ятій'),
             ('Де вони можуть зустрітися?', ['Перед пекарнею', 'На ринку', 'У кафе'], 'Перед пекарнею'),
         ]),
    dict(code='RD-A1-002', type='chat', situation='small_talk', module=1,
         title=('Сімейний чат', 'Obiteljska grupa'),
         hr='''Mama: Tko danas kupuje kruh?
Danilo: Ja ne mogu, imam trening do sedam.
Tata: Ja kupujem kruh i mlijeko poslije posla.
Mama: Hvala! Večera je u osam. Danilo, ne zaboravi: danas ti pereš suđe!
Danilo: Dobro, mama 🙂''',
         ua='''Мама: Хто сьогодні купує хліб?
Данило: Я не можу, у мене тренування до сьомої.
Тато: Я куплю хліб і молоко після роботи.
Мама: Дякую! Вечеря о восьмій. Данило, не забудь: сьогодні ти миєш посуд!
Данило: Добре, мамо 🙂''',
         questions=[
             ('Хто купує хліб?', ['Тато', 'Данило', 'Мама'], 'Тато'),
             ('Чому Данило не може?', ['Він має тренування', 'Він хворий', 'Він на роботі'], 'Він має тренування'),
             ('Що сьогодні робить Данило вдома?', ['Миє посуд', 'Готує вечерю', 'Прибирає кімнату'], 'Миє посуд'),
         ]),
    dict(code='RD-A1-003', type='notice', situation='housing', module=1,
         title=('Записка на холодильнику', 'Poruka na hladnjaku'),
         hr='''Dragi Tarase,
danas radim do kasno. Molim te:
– izvadi rublje iz perilice i objesi ga na balkon;
– iznesi smeće;
– nahrani mačku.
Ručak je u hladnjaku, samo ga zagrij. Vidimo se navečer!
Olena''',
         ua='''Дорогий Тарасе,
сьогодні я працюю допізна. Будь ласка:
– вийми білизну з пральної машини й повісь її на балкон;
– винеси сміття;
– погодуй кішку.
Обід у холодильнику, тільки розігрій його. Побачимося ввечері!
Олена''',
         questions=[
             ('Чому Олена пише записку?', ['Вона працює допізна', 'Вона в лікарні', 'Вона на морі'], 'Вона працює допізна'),
             ('Куди треба повісити білизну?', ['На балкон', 'У ванну', 'У кімнату'], 'На балкон'),
             ('Де обід?', ['У холодильнику', 'На столі', 'У духовці'], 'У холодильнику'),
         ]),
    dict(code='RD-A1-004', type='story', situation='small_talk', module=1,
         title=('Звичайний день Тараса', 'Tarasov običan dan'),
         hr='''Taras živi u Zagrebu. Svaki dan se budi u šest i pol. Prvo se tušira, a onda doručkuje s obitelji. Na posao ide tramvajem. Radi u skladištu od osam do četiri. Poslije posla ide u trgovinu ili u park sa psom. Navečer obično čita ili gleda film. Spava u jedanaest, jer je ujutro opet rano.''',
         ua='''Тарас живе в Загребі. Щодня він прокидається о пів на сьому. Спочатку приймає душ, а потім снідає з родиною. На роботу їде трамваєм. Працює на складі з восьмої до четвертої. Після роботи йде в магазин або в парк із собакою. Увечері зазвичай читає або дивиться фільм. Лягає спати об одинадцятій, бо вранці знову рано.''',
         questions=[
             ('Як Тарас їде на роботу?', ['Трамваєм', 'Автобусом', 'Пішки'], 'Трамваєм'),
             ('Де працює Тарас?', ['На складі', 'У школі', 'У готелі'], 'На складі'),
             ('Що він робить увечері?', ['Читає або дивиться фільм', 'Працює', 'Тренується'], 'Читає або дивиться фільм'),
         ]),
]

# =============================================================================
# A1.2 Їжа й ресторани
# =============================================================================
TEXTS += [
    dict(code='RD-A1-005', type='menu', situation='cafe_restaurant', module=2,
         title=('Денне меню', 'Dnevni meni'),
         hr='''DNEVNI MENI – 9 €
Juha od rajčice
Pečena piletina, krumpir i salata
ili
Varivo od graha s kobasicom
Kolač dana
Kruh i voda su besplatni. Kavu plaćate posebno.
Radimo od 11 do 16 sati.''',
         ua='''ДЕННЕ МЕНЮ – 9 €
Томатний суп
Запечена курка, картопля й салат
або
Рагу з квасолі з ковбаскою
Тістечко дня
Хліб і вода безкоштовні. За каву платите окремо.
Працюємо з 11 до 16 години.''',
         questions=[
             ('Скільки коштує денне меню?', ['9 €', '11 €', '16 €'], '9 €'),
             ('Що безкоштовне?', ['Хліб і вода', 'Кава', 'Тістечко'], 'Хліб і вода'),
             ('До котрої працює ресторан?', ['До 16 години', 'До 11 години', 'До 20 години'], 'До 16 години'),
         ]),
    dict(code='RD-A1-006', type='instruction', situation='cafe_restaurant', module=2,
         title=('Рецепт: млинці', 'Recept: palačinke'),
         hr='''Trebate: dva jaja, pola litre mlijeka, dvjesto grama brašna, malo soli i ulja.
U zdjelu stavite jaja i mlijeko. Dodajte brašno i sol i dobro miješajte. Zagrijte tavu s malo ulja. Stavite malo smjese u tavu i pecite minutu sa svake strane. Palačinke jedite s pekmezom, medom ili čokoladom. Dobar tek!''',
         ua='''Вам потрібно: два яйця, пів літра молока, двісті грамів борошна, трохи солі й олії.
У миску покладіть яйця й молоко. Додайте борошно й сіль і добре перемішайте. Розігрійте сковорідку з невеликою кількістю олії. Налийте трохи тіста на сковорідку й смажте хвилину з кожного боку. Млинці їжте з джемом, медом або шоколадом. Смачного!''',
         questions=[
             ('Скільки яєць потрібно?', ['Два', 'Три', 'Одне'], 'Два'),
             ('Скільки часу пекти кожен бік?', ['Хвилину', 'П’ять хвилин', 'Пів години'], 'Хвилину'),
             ('З чим їсти млинці?', ['З джемом, медом або шоколадом', 'Із сиром і шинкою', 'З рибою'], 'З джемом, медом або шоколадом'),
         ]),
    dict(code='RD-A1-007', type='ad', situation='shopping', module=2,
         title=('Нова пекарня', 'Nova pekara'),
         hr='''NOVA PEKARA U VAŠEM KVARTU!
Svaki dan svježi kruh, peciva i burek.
Otvoreno od 6 do 20 sati, nedjeljom od 7 do 13.
Ovaj tjedan: kava za van i kroasan samo 2 €!
Imamo i integralni kruh bez šećera.
Dođite i probajte!''',
         ua='''НОВА ПЕКАРНЯ У ВАШОМУ РАЙОНІ!
Щодня свіжий хліб, булочки й бурек.
Відчинено з 6 до 20 години, у неділю з 7 до 13.
Цього тижня: кава з собою і круасан лише 2 €!
У нас є й цільнозерновий хліб без цукру.
Приходьте й скуштуйте!''',
         questions=[
             ('До котрої пекарня працює в неділю?', ['До 13 години', 'До 20 години', 'Не працює'], 'До 13 години'),
             ('Що коштує 2 € цього тижня?', ['Кава з собою і круасан', 'Бурек', 'Хліб'], 'Кава з собою і круасан'),
             ('Який хліб є без цукру?', ['Цільнозерновий', 'Білий', 'Домашній'], 'Цільнозерновий'),
         ]),
    dict(code='RD-A1-008', type='email', situation='cafe_restaurant', module=2,
         title=('Підтвердження бронювання', 'Potvrda rezervacije'),
         hr='''Poštovana gospođo Kovalenko,
hvala na rezervaciji. Vaš stol za četiri osobe je u petak u 19 sati, na terasi.
Ako trebate dječju stolicu ili imate alergiju, javite nam.
Ako ne možete doći, molimo Vas da otkažete rezervaciju dan prije.
Srdačan pozdrav,
Restoran Lungomare''',
         ua='''Шановна пані Коваленко,
дякуємо за бронювання. Ваш столик на чотирьох — у п’ятницю о 19 годині, на терасі.
Якщо вам потрібен дитячий стілець або у вас алергія, повідомте нам.
Якщо ви не можете прийти, просимо скасувати бронювання за день до того.
З повагою,
Ресторан «Lungomare»''',
         questions=[
             ('На скільки осіб столик?', ['На чотирьох', 'На двох', 'На шістьох'], 'На чотирьох'),
             ('Де столик?', ['На терасі', 'Біля вікна', 'У залі'], 'На терасі'),
             ('Коли треба скасувати бронювання?', ['За день до того', 'За годину', 'Не можна скасувати'], 'За день до того'),
         ]),
]

# =============================================================================
# A1.3 Покупки
# =============================================================================
TEXTS += [
    dict(code='RD-A1-009', type='ad', situation='shopping', module=3,
         title=('Знижки в супермаркеті', 'Akcija u supermarketu'),
         hr='''AKCIJA OD PONEDJELJKA DO SUBOTE!
Mlijeko 1 l – 0,99 €
Jabuke 1 kg – 1,49 €
Sir 500 g – 3,99 €
Deterdžent za rublje – minus 30 %
Za kupnju veću od 50 € dobivate vrećicu besplatno.
Plaćanje karticom ili gotovinom.''',
         ua='''АКЦІЯ З ПОНЕДІЛКА ДО СУБОТИ!
Молоко 1 л – 0,99 €
Яблука 1 кг – 1,49 €
Сир 500 г – 3,99 €
Пральний засіб – мінус 30 %
За покупку понад 50 € отримуєте пакет безкоштовно.
Оплата карткою або готівкою.''',
         questions=[
             ('Скільки коштує кілограм яблук?', ['1,49 €', '0,99 €', '3,99 €'], '1,49 €'),
             ('На що знижка 30 %?', ['На пральний засіб', 'На сир', 'На молоко'], 'На пральний засіб'),
             ('Коли пакет безкоштовний?', ['Якщо покупка понад 50 €', 'Завжди', 'У суботу'], 'Якщо покупка понад 50 €'),
         ]),
    dict(code='RD-A1-010', type='notice', situation='shopping', module=3,
         title=('Повернення товару', 'Povrat robe'),
         hr='''POVRAT I ZAMJENA ROBE
Robu možete vratiti ili zamijeniti u roku od 14 dana.
Trebate račun i originalno pakiranje.
Odjeću ne smijete nositi prije povrata.
Novac vraćamo na karticu ili u gotovini.
Pitajte prodavača na blagajni.''',
         ua='''ПОВЕРНЕННЯ Й ОБМІН ТОВАРУ
Товар можна повернути або обміняти протягом 14 днів.
Потрібні чек і оригінальна упаковка.
Одяг не можна носити до повернення.
Гроші повертаємо на картку або готівкою.
Запитайте продавця на касі.''',
         questions=[
             ('За скільки днів можна повернути товар?', ['14 днів', '7 днів', '30 днів'], '14 днів'),
             ('Що потрібно для повернення?', ['Чек і упаковка', 'Паспорт', 'Нічого'], 'Чек і упаковка'),
             ('Що не можна робити з одягом до повернення?', ['Носити його', 'Приміряти його', 'Прати його'], 'Носити його'),
         ]),
    dict(code='RD-A1-011', type='message', situation='shopping', module=3,
         title=('SMS від кур’єра', 'SMS od kurira'),
         hr='''Poštovani, Vaša pošiljka stiže danas između 14 i 17 sati. Kurir Vas zove prije dostave. Ako niste kod kuće, paket ostavljamo u paketomatu na adresi Ilica 25. Kod za otvaranje dobivate u novoj poruci. Za praćenje pošiljke posjetite našu stranicu.''',
         ua='''Шановний(-а), ваша посилка прибуде сьогодні між 14 і 17 годиною. Кур’єр подзвонить вам перед доставкою. Якщо вас немає вдома, посилку залишимо в поштоматі за адресою Іліца, 25. Код для відкриття отримаєте в новому повідомленні. Щоб відстежити посилку, відвідайте наш сайт.''',
         questions=[
             ('Коли прибуде посилка?', ['Сьогодні між 14 і 17', 'Завтра вранці', 'У понеділок'], 'Сьогодні між 14 і 17'),
             ('Що буде, якщо вас немає вдома?', ['Посилку залишать у поштоматі', 'Посилку повернуть', 'Кур’єр прийде завтра'], 'Посилку залишать у поштоматі'),
             ('Як отримати код?', ['У новому повідомленні', 'У кур’єра', 'На пошті'], 'У новому повідомленні'),
         ]),
    dict(code='RD-A1-012', type='chat', situation='shopping', module=3,
         title=('Яку куртку купити?', 'Koju jaknu kupiti?'),
         hr='''Oksana: Trebam zimsku jaknu za sina. Imaš li ideju?
Marija: Probaj u centru, tamo je sada sniženje.
Oksana: Vidim dvije jakne. Plava je jeftinija, a crna je toplija.
Marija: Uzmi topliju! Zima u Zagrebu je hladna.
Oksana: Imaš pravo. Uzimam crnu i nove rukavice.''',
         ua='''Оксана: Мені потрібна зимова куртка для сина. Маєш ідею?
Марія: Спробуй у центрі, там зараз розпродаж.
Оксана: Бачу дві куртки. Синя дешевша, а чорна тепліша.
Марія: Бери теплішу! Зима в Загребі холодна.
Оксана: Маєш рацію. Беру чорну і нові рукавички.''',
         questions=[
             ('Для кого куртка?', ['Для сина', 'Для чоловіка', 'Для Марії'], 'Для сина'),
             ('Яка куртка дешевша?', ['Синя', 'Чорна', 'Обидві однакові'], 'Синя'),
             ('Що ще купує Оксана?', ['Рукавички', 'Шапку', 'Черевики'], 'Рукавички'),
         ]),
]

# =============================================================================
# A1.4 Транспорт
# =============================================================================
TEXTS += [
    dict(code='RD-A1-013', type='notice', situation='transport', module=4,
         title=('Зміна маршруту трамвая', 'Promjena linije tramvaja'),
         hr='''OBAVIJEST PUTNICIMA
Zbog radova na cesti tramvaj broj 6 od ponedjeljka ne vozi do Glavnog kolodvora.
Putnici mogu presjedati na autobus broj 109 na stanici Trg bana Jelačića.
Karta vrijedi za tramvaj i za autobus.
Hvala na razumijevanju!''',
         ua='''ОГОЛОШЕННЯ ДЛЯ ПАСАЖИРІВ
Через дорожні роботи трамвай номер 6 з понеділка не їздить до Головного вокзалу.
Пасажири можуть пересісти на автобус номер 109 на зупинці «Площа бана Єлачича».
Квиток дійсний і для трамвая, і для автобуса.
Дякуємо за розуміння!''',
         questions=[
             ('Чому трамвай змінює маршрут?', ['Через дорожні роботи', 'Через снігопад', 'Через свято'], 'Через дорожні роботи'),
             ('На який автобус можна пересісти?', ['109', '6', '25'], '109'),
             ('Чи потрібен новий квиток на автобус?', ['Ні, квиток дійсний', 'Так, треба купити', 'Так, у водія'], 'Ні, квиток дійсний'),
         ]),
    dict(code='RD-A1-014', type='instruction', situation='transport', module=4,
         title=('Як купити квиток в автоматі', 'Kako kupiti kartu na automatu'),
         hr='''1. Odaberite jezik.
2. Odaberite kartu: jednosmjernu ili povratnu.
3. Upišite broj putnika.
4. Platite karticom ili kovanicama.
5. Uzmite kartu i ostatak novca.
Karta vrijedi 90 minuta. Poništite je u tramvaju ili autobusu.''',
         ua='''1. Виберіть мову.
2. Виберіть квиток: в один бік чи туди й назад.
3. Введіть кількість пасажирів.
4. Заплатіть карткою або монетами.
5. Заберіть квиток і решту.
Квиток дійсний 90 хвилин. Прокомпостуйте його в трамваї чи автобусі.''',
         questions=[
             ('Скільки часу дійсний квиток?', ['90 хвилин', 'Один день', '30 хвилин'], '90 хвилин'),
             ('Як можна заплатити?', ['Карткою або монетами', 'Лише готівкою', 'Лише карткою'], 'Карткою або монетами'),
             ('Що треба зробити з квитком у трамваї?', ['Прокомпостувати', 'Віддати водієві', 'Нічого'], 'Прокомпостувати'),
         ]),
    dict(code='RD-A1-015', type='notice', situation='car_service', module=4,
         title=('Паркування в місті', 'Parkiranje u gradu'),
         hr='''ZONA 1 – PARKIRANJE SE PLAĆA
Ponedjeljak – petak: od 7 do 21 sat
Subota: od 7 do 15 sati
Nedjeljom i praznikom parkiranje je besplatno.
Najduže dva sata. Cijena: 1,60 € na sat.
Platite na automatu ili SMS-om. Bez karte – kazna!''',
         ua='''ЗОНА 1 – ПАРКУВАННЯ ПЛАТНЕ
Понеділок – п’ятниця: з 7 до 21 години
Субота: з 7 до 15 години
У неділю та у свята паркування безкоштовне.
Найдовше дві години. Ціна: 1,60 € за годину.
Платіть в автоматі або через SMS. Без квитка — штраф!''',
         questions=[
             ('Коли паркування безкоштовне?', ['У неділю та у свята', 'У суботу', 'Щодня після 15'], 'У неділю та у свята'),
             ('Скільки максимум можна паркуватися?', ['Дві години', 'Одну годину', 'Цілий день'], 'Дві години'),
             ('Скільки коштує година?', ['1,60 €', '2 €', '1 €'], '1,60 €'),
         ]),
    dict(code='RD-A1-016', type='news', situation='travel', module=4,
         title=('Літній розклад поромів', 'Ljetni red plovidbe'),
         hr='''Od lipnja do rujna trajekti iz Splita za Brač voze svaki sat, od pet ujutro do ponoći. Ljeti je velika gužva, zato putnici trebaju kupiti karte na internetu. Auti moraju biti u luci pola sata prije polaska. Pješaci mogu doći petnaest minuta prije.''',
         ua='''З червня до вересня пороми зі Спліта на Брач ходять щогодини, з п’ятої ранку до опівночі. Улітку велика черга, тому пасажирам треба купувати квитки в інтернеті. Автомобілі мають бути в порту за пів години до відправлення. Пішоходи можуть прийти за п’ятнадцять хвилин до відправлення.''',
         questions=[
             ('Як часто влітку ходять пороми на Брач?', ['Щогодини', 'Двічі на день', 'Щопівгодини'], 'Щогодини'),
             ('Де краще купувати квитки?', ['В інтернеті', 'На поромі', 'У водія'], 'В інтернеті'),
             ('Коли авто має бути в порту?', ['За пів години до відправлення', 'За п’ять хвилин', 'За дві години'], 'За пів години до відправлення'),
         ]),
]

# =============================================================================
# A1.5 Житло
# =============================================================================
TEXTS += [
    dict(code='RD-A1-017', type='ad', situation='housing', module=5,
         title=('Оголошення: квартира в оренду', 'Oglas: stan za najam'),
         hr='''IZNAJMLJUJEM STAN
Dvosoban stan, 55 m², drugi kat, Trešnjevka.
Namješten, s balkonom i perilicom rublja.
Najamnina: 650 € mjesečno + režije.
Polog: jedna najamnina.
Blizu tramvaja, škole i trgovine.
Kućni ljubimci nisu dopušteni.
Zovite na 091 234 5678.''',
         ua='''ЗДАЮ КВАРТИРУ
Двокімнатна квартира, 55 м², другий поверх, Трешнєвка.
Мебльована, з балконом і пральною машиною.
Орендна плата: 650 € на місяць + комунальні.
Застава: одна орендна плата.
Поруч трамвай, школа й магазин.
Домашні тварини заборонені.
Телефонуйте на 091 234 5678.''',
         questions=[
             ('Скільки кімнат у квартирі?', ['Дві', 'Одна', 'Три'], 'Дві'),
             ('Що входить у ціну 650 €?', ['Лише оренда, комунальні окремо', 'Оренда й комунальні', 'Оренда й інтернет'], 'Лише оренда, комунальні окремо'),
             ('Чи можна жити з собакою?', ['Ні', 'Так', 'Лише з маленькою'], 'Ні'),
         ]),
    dict(code='RD-A1-018', type='notice', situation='housing', module=5,
         title=('У будинку не буде води', 'Obavijest: bez vode'),
         hr='''OBAVIJEST STANARIMA
U srijedu, 15. listopada, od 9 do 14 sati zgrada nema vode zbog popravka cijevi u podrumu.
Molimo stanare da pripreme vodu za piće i kuhanje.
Ako imate pitanja, zovite upravitelja zgrade.
Hvala na razumijevanju!''',
         ua='''ОГОЛОШЕННЯ ДЛЯ МЕШКАНЦІВ
У середу, 15 жовтня, з 9 до 14 години в будинку не буде води через ремонт труб у підвалі.
Просимо мешканців підготувати воду для пиття й готування.
Якщо у вас є питання, телефонуйте управителю будинку.
Дякуємо за розуміння!''',
         questions=[
             ('Чому не буде води?', ['Ремонт труб у підвалі', 'Борг за воду', 'Прибирання'], 'Ремонт труб у підвалі'),
             ('Скільки годин не буде води?', ['П’ять', 'Дві', 'Цілий день'], 'П’ять'),
             ('Кому дзвонити з питаннями?', ['Управителю будинку', 'Сусідові', 'Поліції'], 'Управителю будинку'),
         ]),
    dict(code='RD-A1-019', type='message', situation='housing', module=5,
         title=('Повідомлення орендодавцю', 'Poruka stanodavcu'),
         hr='''Dobar dan, gospodine Horvat,
grijanje u stanu opet ne radi. Radijatori su hladni od jučer, a vani je vrlo hladno. Djeca su bolesna. Možete li danas poslati majstora? Mi smo kod kuće cijeli dan.
Hvala,
Olena Kovalenko, stan broj 4''',
         ua='''Добрий день, пане Горват,
опалення в квартирі знову не працює. Батареї холодні з учорашнього дня, а надворі дуже холодно. Діти хворі. Чи можете ви сьогодні прислати майстра? Ми вдома цілий день.
Дякую,
Олена Коваленко, квартира номер 4''',
         questions=[
             ('Що не працює?', ['Опалення', 'Пральна машина', 'Ліфт'], 'Опалення'),
             ('Про що просить Олена?', ['Прислати майстра', 'Знизити оренду', 'Дати ключ'], 'Прислати майстра'),
             ('Коли Олена вдома?', ['Цілий день', 'Лише ввечері', 'Лише вранці'], 'Цілий день'),
         ]),
    dict(code='RD-A1-020', type='notice', situation='housing', module=5,
         title=('Сміття й переробка', 'Odvajanje otpada'),
         hr='''ODVAJAJTE OTPAD!
Plava kanta: papir i karton.
Žuta kanta: plastika i limenke.
Zelena kanta: staklo.
Smeđa kanta: ostaci hrane.
Crna kanta: ostalo smeće.
Smeće iznosimo navečer, prije osam sati. Velike stvari ne ostavljajte pored kanti.''',
         ua='''СОРТУЙТЕ ВІДХОДИ!
Синій контейнер: папір і картон.
Жовтий контейнер: пластик і бляшанки.
Зелений контейнер: скло.
Коричневий контейнер: залишки їжі.
Чорний контейнер: інше сміття.
Сміття виносимо ввечері, до восьмої години. Великих речей не залишайте біля контейнерів.''',
         questions=[
             ('Куди викидати пляшку зі скла?', ['У зелений контейнер', 'У жовтий', 'У синій'], 'У зелений контейнер'),
             ('Що кидати в синій контейнер?', ['Папір і картон', 'Залишки їжі', 'Пластик'], 'Папір і картон'),
             ('Коли виносити сміття?', ['Увечері, до восьмої', 'Уранці в неділю', 'Будь-коли'], 'Увечері, до восьмої'),
         ]),
]

# =============================================================================
# A1.6 Робота
# =============================================================================
TEXTS += [
    dict(code='RD-A1-021', type='ad', situation='work', module=6,
         title=('Вакансія: покоївка в готелі', 'Oglas: sobarica u hotelu'),
         hr='''HOTEL MARINA TRAŽI SOBARICU
Posao: čišćenje soba i kupaonica.
Uvjeti: sezonski posao od svibnja do listopada, puno radno vrijeme.
Satnica: 7 € neto. Smještaj i hrana su besplatni.
Iskustvo nije potrebno, znanje engleskog je prednost.
Životopis pošaljite na posao@hotelmarina.hr.''',
         ua='''ГОТЕЛЬ «МАРИНА» ШУКАЄ ПОКОЇВКУ
Робота: прибирання номерів і ванних кімнат.
Умови: сезонна робота з травня до жовтня, повний робочий день.
Погодинна оплата: 7 € чистими. Житло й харчування безкоштовні.
Досвід не потрібен, знання англійської — перевага.
Резюме надсилайте на posao@hotelmarina.hr.''',
         questions=[
             ('Яка це робота?', ['Сезонна', 'Постійна', 'Лише у вихідні'], 'Сезонна'),
             ('Що безкоштовне?', ['Житло й харчування', 'Транспорт', 'Курси англійської'], 'Житло й харчування'),
             ('Чи потрібен досвід?', ['Ні', 'Так, два роки', 'Так, у готелі'], 'Ні'),
         ]),
    dict(code='RD-A1-022', type='email', situation='work', module=6,
         title=('Лист від роботодавця', 'Mail od poslodavca'),
         hr='''Poštovani gospodine Melnyk,
dobro došli u našu tvrtku! Vaš prvi radni dan je u ponedjeljak. Dođite u osam sati na ulaz B. Na recepciji Vas čeka voditeljica smjene, gospođa Babić. Ponesite osobnu iskaznicu, OIB i broj računa u banci. Radnu odjeću dobivate prvi dan.
Lijep pozdrav,
Ana Perić, ured za ljudske resurse''',
         ua='''Шановний пане Мельник,
ласкаво просимо до нашої компанії! Ваш перший робочий день — у понеділок. Приходьте о восьмій годині до входу B. На рецепції на вас чекатиме керівниця зміни, пані Бабич. Візьміть із собою посвідчення особи, OIB і номер банківського рахунку. Робочий одяг отримаєте першого дня.
З повагою,
Ана Перич, відділ кадрів''',
         questions=[
             ('Коли перший робочий день?', ['У понеділок', 'У п’ятницю', 'Завтра'], 'У понеділок'),
             ('Хто чекає на рецепції?', ['Керівниця зміни', 'Директор', 'Охоронець'], 'Керівниця зміни'),
             ('Що треба взяти з собою?', ['Посвідчення особи, OIB і номер рахунку', 'Робочий одяг', 'Диплом'], 'Посвідчення особи, OIB і номер рахунку'),
         ]),
    dict(code='RD-A1-023', type='notice', situation='work', module=6,
         title=('Розклад змін', 'Raspored smjena'),
         hr='''RASPORED SMJENA – SKLADIŠTE
Jutarnja smjena: od 6 do 14 sati.
Popodnevna smjena: od 14 do 22 sata.
Pauza: 30 minuta, u kantini na prvom katu.
Zamjenu smjene dogovorite s voditeljem najkasnije dan prije.
Bolovanje javite voditelju prije početka smjene.''',
         ua='''РОЗКЛАД ЗМІН – СКЛАД
Ранкова зміна: з 6 до 14 години.
Денна зміна: з 14 до 22 години.
Перерва: 30 хвилин, у їдальні на першому поверсі.
Обмін змінами погоджуйте з керівником не пізніше ніж за день.
Про лікарняний повідомте керівника до початку зміни.''',
         questions=[
             ('Коли починається ранкова зміна?', ['О 6', 'О 8', 'О 14'], 'О 6'),
             ('Скільки триває перерва?', ['30 хвилин', '15 хвилин', 'Годину'], '30 хвилин'),
             ('Коли повідомити про лікарняний?', ['До початку зміни', 'Після зміни', 'За тиждень'], 'До початку зміни'),
         ]),
    dict(code='RD-A1-024', type='story', situation='work', module=6,
         title=('Оксана на роботі', 'Oksana na poslu'),
         hr='''Oksana radi kao njegovateljica. Svako jutro dolazi kod gospođe Marije. Gospođa Marija ima osamdeset godina i živi sama. Oksana joj kuha ručak, ide s njom u šetnju i daje joj lijekove. Gospođa Marija joj priča o Zagrebu, a Oksana uči nove riječi. Posao nije lak, ali Oksana ga voli.''',
         ua='''Оксана працює доглядальницею. Щоранку вона приходить до пані Марії. Пані Марії вісімдесят років, і вона живе сама. Оксана готує їй обід, ходить з нею на прогулянку й дає їй ліки. Пані Марія розповідає їй про Загреб, а Оксана вивчає нові слова. Робота не легка, але Оксана її любить.''',
         questions=[
             ('Ким працює Оксана?', ['Доглядальницею', 'Кухаркою', 'Прибиральницею'], 'Доглядальницею'),
             ('Скільки років пані Марії?', ['Вісімдесят', 'Шістдесят', 'Дев’яносто'], 'Вісімдесят'),
             ('Що Оксана вчить від пані Марії?', ['Нові слова', 'Готувати', 'Водити машину'], 'Нові слова'),
         ]),
]

# =============================================================================
# A1.7 Здоров’я
# =============================================================================
TEXTS += [
    dict(code='RD-A1-025', type='notice', situation='health', module=7,
         title=('Години роботи ординації', 'Radno vrijeme ordinacije'),
         hr='''ORDINACIJA OBITELJSKE MEDICINE
dr. Ivana Jurić
Ponedjeljak, srijeda, petak: 7 – 14 sati
Utorak, četvrtak: 13 – 20 sati
Na pregled se naručite telefonom ili e-mailom.
Recepte i uputnice možete tražiti e-mailom.
Hitni slučajevi: zovite 194 ili 112.''',
         ua='''КАБІНЕТ СІМЕЙНОЇ МЕДИЦИНИ
лікарка Івана Юрич
Понеділок, середа, п’ятниця: 7 – 14 година
Вівторок, четвер: 13 – 20 година
На огляд записуйтеся телефоном або електронною поштою.
Рецепти й направлення можна попросити електронною поштою.
Невідкладні випадки: телефонуйте 194 або 112.''',
         questions=[
             ('Коли лікарка працює ввечері?', ['У вівторок і четвер', 'У понеділок', 'У п’ятницю'], 'У вівторок і четвер'),
             ('Як записатися на огляд?', ['Телефоном або поштою', 'Лише особисто', 'Через аптеку'], 'Телефоном або поштою'),
             ('Що робити в невідкладному випадку?', ['Дзвонити 194 або 112', 'Писати лист', 'Чекати до ранку'], 'Дзвонити 194 або 112'),
         ]),
    dict(code='RD-A1-026', type='instruction', situation='health', module=7,
         title=('Як приймати ліки', 'Uputa o lijeku'),
         hr='''SIRUP PROTIV KAŠLJA
Odrasli: jedna žlica tri puta dnevno.
Djeca od 6 do 12 godina: pola žlice tri puta dnevno.
Djeca mlađa od 6 godina: pitajte liječnika.
Lijek uzimajte poslije jela. Ne pijte alkohol.
Ako kašalj traje dulje od tjedan dana, javite se liječniku.''',
         ua='''СИРОП ВІД КАШЛЮ
Дорослі: одна ложка тричі на день.
Діти від 6 до 12 років: пів ложки тричі на день.
Діти до 6 років: запитайте лікаря.
Ліки приймайте після їжі. Не пийте алкоголь.
Якщо кашель триває довше за тиждень, зверніться до лікаря.''',
         questions=[
             ('Скільки сиропу дорослому за раз?', ['Одна ложка', 'Пів ложки', 'Дві ложки'], 'Одна ложка'),
             ('Коли приймати ліки?', ['Після їжі', 'Перед сном', 'Натщесерце'], 'Після їжі'),
             ('Коли звернутися до лікаря?', ['Якщо кашель довше за тиждень', 'Одразу', 'Через місяць'], 'Якщо кашель довше за тиждень'),
         ]),
    dict(code='RD-A1-027', type='message', situation='health', module=7,
         title=('Нагадування про прийом', 'Podsjetnik za pregled'),
         hr='''Poštovana, podsjećamo Vas na pregled kod dr. Jurić sutra u 10:30. Ponesite zdravstvenu iskaznicu i uputnicu. Ako ne možete doći, otkažite termin na broj 01 456 7890. Molimo dođite deset minuta ranije.''',
         ua='''Шановна, нагадуємо вам про огляд у лікарки Юрич завтра о 10:30. Візьміть медичну картку страхування й направлення. Якщо не можете прийти, скасуйте прийом за номером 01 456 7890. Просимо прийти на десять хвилин раніше.''',
         questions=[
             ('Коли огляд?', ['Завтра о 10:30', 'Сьогодні о 10:30', 'Завтра о 13:00'], 'Завтра о 10:30'),
             ('Що треба взяти?', ['Картку страхування й направлення', 'Паспорт', 'Результати аналізів'], 'Картку страхування й направлення'),
             ('На скільки раніше прийти?', ['На десять хвилин', 'На годину', 'На пів години'], 'На десять хвилин'),
         ]),
    dict(code='RD-A1-028', type='chat', situation='health', module=7,
         title=('Дитина хворіє', 'Dijete je bolesno'),
         hr='''Olena: Dobro jutro, Sofija danas ne dolazi u vrtić. Ima temperaturu i kašlje.
Odgojiteljica: Dobro jutro! Žao mi je. Neka se odmara.
Olena: Hvala. Trebam li donijeti potvrdu od liječnika?
Odgojiteljica: Da, kad se vrati u vrtić, trebamo potvrdu od pedijatra.
Olena: U redu. Hvala i lijep dan!''',
         ua='''Олена: Доброго ранку, Софія сьогодні не прийде в садок. У неї температура і кашель.
Вихователька: Доброго ранку! Мені шкода. Нехай відпочиває.
Олена: Дякую. Мені потрібно принести довідку від лікаря?
Вихователька: Так, коли вона повернеться в садок, нам потрібна довідка від педіатра.
Олена: Гаразд. Дякую і гарного дня!''',
         questions=[
             ('Чому Софія не йде в садок?', ['Вона хвора', 'Вона на морі', 'Садок зачинено'], 'Вона хвора'),
             ('Що потрібно, коли Софія повернеться?', ['Довідка від педіатра', 'Новий одяг', 'Оплата'], 'Довідка від педіатра'),
             ('Кому пише Олена?', ['Виховательці', 'Лікареві', 'Чоловікові'], 'Виховательці'),
         ]),
]

# =============================================================================
# A1.8 Друзі й вільний час
# =============================================================================
TEXTS += [
    dict(code='RD-A1-029', type='message', situation='small_talk', module=8,
         title=('Запрошення на день народження', 'Pozivnica za rođendan'),
         hr='''Dragi prijatelji!
U subotu slavim trideseti rođendan i želim vas vidjeti. Zabava je u našem stanu od osam navečer. Imamo hranu i piće, vi donesite dobro raspoloženje! Ako dolazite, javite mi do četvrtka.
Vidimo se,
Ivana''',
         ua='''Дорогі друзі!
У суботу я святкую тридцятий день народження і хочу вас побачити. Вечірка в нашій квартирі з восьмої вечора. У нас є їжа й напої, а ви принесіть гарний настрій! Якщо прийдете, дайте мені знати до четверга.
До зустрічі,
Івана''',
         questions=[
             ('Скільки років виповнюється Івані?', ['Тридцять', 'Двадцять', 'Сорок'], 'Тридцять'),
             ('Де вечірка?', ['У квартирі Івани', 'У ресторані', 'У парку'], 'У квартирі Івани'),
             ('До коли треба відповісти?', ['До четверга', 'До суботи', 'До понеділка'], 'До четверга'),
         ]),
    dict(code='RD-A1-030', type='ad', situation='small_talk', module=8,
         title=('Концерт у парку', 'Koncert u parku'),
         hr='''KONCERT U PARKU ZRINJEVAC
Subota, 20 sati
Svira lokalni bend.
Ulaz je besplatan!
Ako pada kiša, koncert je u kazalištu.
Ponesite deku i dobru volju.''',
         ua='''КОНЦЕРТ У ПАРКУ ЗРИНЄВАЦ
Субота, 20 година
Грає місцевий гурт.
Вхід вільний!
Якщо йде дощ, концерт відбудеться в театрі.
Візьміть ковдру й гарний настрій.''',
         questions=[
             ('Скільки коштує вхід?', ['Безкоштовно', '5 €', '10 €'], 'Безкоштовно'),
             ('Що буде, якщо йде дощ?', ['Концерт у театрі', 'Концерт скасують', 'Концерт у неділю'], 'Концерт у театрі'),
             ('Що радять узяти?', ['Ковдру', 'Парасольку', 'Квиток'], 'Ковдру'),
         ]),
    dict(code='RD-A1-031', type='chat', situation='small_talk', module=8,
         title=('Плануємо похід', 'Planiramo izlet'),
         hr='''Marko: Idemo li u nedjelju na Sljeme?
Taras: Može! Kada krećemo?
Marko: Rano, u osam. Nalazimo se na stanici tramvaja.
Taras: Što trebam ponijeti?
Marko: Udobne cipele, vodu i sendvič. Gore je hladnije, uzmi i jaknu.
Taras: Super, vidimo se!''',
         ua='''Марко: Підемо в неділю на Слєме?
Тарас: Можна! Коли вирушаємо?
Марко: Рано, о восьмій. Зустрічаємося на трамвайній зупинці.
Тарас: Що мені взяти?
Марко: Зручне взуття, воду й сендвіч. Нагорі холодніше, візьми й куртку.
Тарас: Чудово, до зустрічі!''',
         questions=[
             ('Коли вони йдуть у похід?', ['У неділю', 'У суботу', 'У п’ятницю'], 'У неділю'),
             ('Де вони зустрічаються?', ['На трамвайній зупинці', 'Біля кафе', 'На вокзалі'], 'На трамвайній зупинці'),
             ('Чому треба взяти куртку?', ['Нагорі холодніше', 'Буде дощ', 'Ввечері концерт'], 'Нагорі холодніше'),
         ]),
    dict(code='RD-A1-032', type='story', situation='small_talk', module=8,
         title=('Нові друзі', 'Novi prijatelji'),
         hr='''Andrij živi u Rijeci godinu dana. U početku nema prijatelja i često je usamljen. Onda se upisuje na tečaj hrvatskog. Na tečaju upoznaje Marka iz Zagreba i Annu iz Poljske. Sada se nalaze svaki petak u kafiću. Pričaju hrvatski, smiju se i pomažu jedni drugima. Andrij više nije sam.''',
         ua='''Андрій живе в Рієці вже рік. Спочатку в нього немає друзів, і він часто самотній. Потім він записується на курс хорватської. На курсі знайомиться з Марком із Загреба та Анною з Польщі. Тепер вони зустрічаються щоп’ятниці в кафе. Розмовляють хорватською, сміються й допомагають одне одному. Андрій більше не сам.''',
         questions=[
             ('Де живе Андрій?', ['У Рієці', 'У Загребі', 'У Спліті'], 'У Рієці'),
             ('Де він знайомиться з друзями?', ['На курсі хорватської', 'На роботі', 'У спортзалі'], 'На курсі хорватської'),
             ('Коли вони зустрічаються?', ['Щоп’ятниці', 'Щонеділі', 'Щодня'], 'Щоп’ятниці'),
         ]),
]

# =============================================================================
# A1.9 Хорватія
# =============================================================================
TEXTS += [
    dict(code='RD-A1-033', type='news', situation='travel', module=9,
         title=('Прогноз погоди', 'Vremenska prognoza'),
         hr='''Sutra je na moru sunčano i toplo, do 28 stupnjeva. U Zagrebu i na sjeveru je oblačno, a poslijepodne pada kiša. Temperatura je od 15 do 20 stupnjeva. U planinama puše jak vjetar. Na Jadranu puše jugo, zato trajekti mogu kasniti.''',
         ua='''Завтра на морі сонячно й тепло, до 28 градусів. У Загребі й на півночі хмарно, а після обіду йде дощ. Температура від 15 до 20 градусів. У горах дме сильний вітер. На Адріатиці дме юго, тому пороми можуть запізнюватися.''',
         questions=[
             ('Яка погода завтра на морі?', ['Сонячно й тепло', 'Дощ', 'Сніг'], 'Сонячно й тепло'),
             ('Що буде в Загребі після обіду?', ['Дощ', 'Сонце', 'Туман'], 'Дощ'),
             ('Чому пороми можуть запізнюватися?', ['Через вітер юго', 'Через свято', 'Через туман'], 'Через вітер юго'),
         ]),
    dict(code='RD-A1-034', type='notice', situation='travel', module=9,
         title=('Правила в національному парку', 'Pravila u nacionalnom parku'),
         hr='''DOBRO DOŠLI U NACIONALNI PARK!
Hodajte samo po stazama.
Kupanje u jezerima je zabranjeno.
Ne hranite životinje i ne berite cvijeće.
Smeće nosite sa sobom.
Psi moraju biti na povodcu.
Hvala što čuvate prirodu!''',
         ua='''ЛАСКАВО ПРОСИМО ДО НАЦІОНАЛЬНОГО ПАРКУ!
Ходіть лише стежками.
Купатися в озерах заборонено.
Не годуйте тварин і не зривайте квітів.
Сміття забирайте з собою.
Собаки мають бути на повідку.
Дякуємо, що бережете природу!''',
         questions=[
             ('Чи можна купатися в озерах?', ['Ні, заборонено', 'Так', 'Лише влітку'], 'Ні, заборонено'),
             ('Де можна ходити?', ['Лише стежками', 'Де завгодно', 'Лише біля озер'], 'Лише стежками'),
             ('Що зробити зі сміттям?', ['Забрати з собою', 'Залишити біля стежки', 'Спалити'], 'Забрати з собою'),
         ]),
    dict(code='RD-A1-035', type='article', situation='travel', module=9,
         title=('Адвент у Загребі', 'Advent u Zagrebu'),
         hr='''Advent u Zagrebu počinje krajem studenoga i traje do početka siječnja. Grad je pun svjetla, a na trgovima su male kućice s hranom i pićem. Ljudi piju kuhano vino i jedu fritule i kobasice. Na klizalištu se kližu djeca i odrasli. Svake godine dolazi puno turista iz cijelog svijeta.''',
         ua='''Адвент у Загребі починається наприкінці листопада й триває до початку січня. Місто сповнене вогнів, а на площах — маленькі будиночки з їжею та напоями. Люди п’ють глінтвейн і їдять фрітуле та ковбаски. На ковзанці катаються діти й дорослі. Щороку приїжджає багато туристів з усього світу.''',
         questions=[
             ('Коли починається адвент?', ['Наприкінці листопада', 'У січні', 'Улітку'], 'Наприкінці листопада'),
             ('Що п’ють люди?', ['Глінтвейн', 'Пиво', 'Сік'], 'Глінтвейн'),
             ('Хто катається на ковзанці?', ['Діти й дорослі', 'Лише діти', 'Лише туристи'], 'Діти й дорослі'),
         ]),
    dict(code='RD-A1-036', type='message', situation='travel', module=9,
         title=('Листівка з острова', 'Razglednica s otoka'),
         hr='''Draga Marija,
pozdrav s Hvara! More je toplo i čisto, a plaže su prekrasne. Svaki dan se kupamo i jedemo svježu ribu. Navečer šetamo uz rivu. Grad je mali, ali ima puno ljudi. Vraćamo se u nedjelju trajektom. Jedva čekam da se vidimo!
Grli te Oksana''',
         ua='''Дорога Маріє,
привіт із Хвару! Море тепле й чисте, а пляжі чудові. Щодня ми купаємося і їмо свіжу рибу. Увечері гуляємо набережною. Місто маленьке, але людей багато. Повертаємося в неділю поромом. Не можу дочекатися нашої зустрічі!
Обіймаю, Оксана''',
         questions=[
             ('Де Оксана?', ['На острові Хвар', 'У Загребі', 'У горах'], 'На острові Хвар'),
             ('Що вони роблять увечері?', ['Гуляють набережною', 'Дивляться фільм', 'Працюють'], 'Гуляють набережною'),
             ('Як вони повертаються?', ['Поромом', 'Літаком', 'Автобусом'], 'Поромом'),
         ]),
]

# =============================================================================
# A1.10 Підсумок
# =============================================================================
TEXTS += [
    dict(code='RD-A1-037', type='notice', situation='administration', module=10,
         title=('Документи в MUP', 'Obavijest MUP-a'),
         hr='''OBAVIJEST ZA STRANCE
Zahtjev za privremeni boravak predajete u policijskoj upravi prema mjestu stanovanja.
Trebate: važeću putovnicu, fotografiju, dokaz o smještaju i zdravstveno osiguranje.
Dokumente na stranom jeziku prevodi sudski tumač.
Na šalter dolazite s brojem iz automata. Radno vrijeme: 8 – 15 sati.''',
         ua='''ОГОЛОШЕННЯ ДЛЯ ІНОЗЕМЦІВ
Заяву на тимчасове перебування подаєте в поліцейському управлінні за місцем проживання.
Потрібно: чинний паспорт, фотографія, підтвердження житла й медичне страхування.
Документи іноземною мовою перекладає присяжний перекладач.
До віконця підходите з номером з автомата. Години роботи: 8 – 15 година.''',
         questions=[
             ('Де подавати заяву?', ['У поліцейському управлінні', 'У банку', 'На пошті'], 'У поліцейському управлінні'),
             ('Хто перекладає документи?', ['Присяжний перекладач', 'Будь-хто', 'Сам заявник'], 'Присяжний перекладач'),
             ('Що треба взяти з автомата?', ['Номер черги', 'Квиток', 'Бланк'], 'Номер черги'),
         ]),
    dict(code='RD-A1-038', type='form', situation='administration', module=10,
         title=('Анкета на курс', 'Prijavnica za tečaj'),
         hr='''PRIJAVNICA ZA TEČAJ HRVATSKOGA JEZIKA
Ime i prezime: Olena Kovalenko
Datum rođenja: 12. 3. 1990.
Državljanstvo: ukrajinsko
Adresa: Ilica 25, Zagreb
Broj mobitela: 091 765 4321
Razina: A1
Termin: utorak i četvrtak, 18 – 20 sati
Potpis: Olena Kovalenko''',
         ua='''АНКЕТА НА КУРС ХОРВАТСЬКОЇ МОВИ
Ім’я та прізвище: Олена Коваленко
Дата народження: 12.03.1990
Громадянство: українське
Адреса: Іліца, 25, Загреб
Номер мобільного: 091 765 4321
Рівень: A1
Час занять: вівторок і четвер, 18 – 20 година
Підпис: Олена Коваленко''',
         questions=[
             ('Яке громадянство в Олени?', ['Українське', 'Хорватське', 'Польське'], 'Українське'),
             ('Який рівень курсу?', ['A1', 'A2', 'B1'], 'A1'),
             ('Коли заняття?', ['У вівторок і четвер', 'У понеділок і середу', 'У суботу'], 'У вівторок і четвер'),
         ]),
    dict(code='RD-A1-039', type='ad', situation='administration', module=10,
         title=('Безкоштовний курс хорватської', 'Besplatni tečaj hrvatskog'),
         hr='''BESPLATNI TEČAJ HRVATSKOG ZA STRANCE
Grad Zagreb organizira tečaj za početnike.
Nastava je dva puta tjedno, navečer, u gradskoj knjižnici.
Tečaj traje tri mjeseca. Na kraju dobivate svjedodžbu.
Broj mjesta je ograničen.
Prijave: osobno u knjižnici ili na stranici grada.''',
         ua='''БЕЗКОШТОВНИЙ КУРС ХОРВАТСЬКОЇ ДЛЯ ІНОЗЕМЦІВ
Місто Загреб організовує курс для початківців.
Заняття двічі на тиждень, увечері, у міській бібліотеці.
Курс триває три місяці. Наприкінці отримуєте свідоцтво.
Кількість місць обмежена.
Реєстрація: особисто в бібліотеці або на сайті міста.''',
         questions=[
             ('Де відбуваються заняття?', ['У міській бібліотеці', 'У школі', 'Онлайн'], 'У міській бібліотеці'),
             ('Скільки триває курс?', ['Три місяці', 'Рік', 'Місяць'], 'Три місяці'),
             ('Що отримують наприкінці?', ['Свідоцтво', 'Гроші', 'Книжку'], 'Свідоцтво'),
         ]),
    dict(code='RD-A1-040', type='story', situation='small_talk', module=10,
         title=('Мій рік у Хорватії', 'Moja godina u Hrvatskoj'),
         hr='''Zovem se Olena i živim u Zagrebu već godinu dana. Radim u hotelu, a moja djeca idu u školu i u vrtić. Hrvatski je sličan ukrajinskom, ali često se zbunim. Ljudi su ljubazni i strpljivi kad govorim polako. Nedostaje mi domovina i moja obitelj, ali ovdje imamo mir. Svaki dan učim nove riječi i sve više razumijem.''',
         ua='''Мене звати Олена, і я живу в Загребі вже рік. Я працюю в готелі, а мої діти ходять до школи й у садок. Хорватська схожа на українську, але я часто плутаюся. Люди привітні й терплячі, коли я говорю повільно. Мені бракує батьківщини й моєї родини, але тут у нас мир. Щодня я вчу нові слова й розумію дедалі більше.''',
         questions=[
             ('Скільки Олена живе в Загребі?', ['Рік', 'Місяць', 'П’ять років'], 'Рік'),
             ('Де працює Олена?', ['У готелі', 'У школі', 'У лікарні'], 'У готелі'),
             ('Які люди, коли вона говорить повільно?', ['Привітні й терплячі', 'Сердиті', 'Нетерплячі'], 'Привітні й терплячі'),
         ]),
]
