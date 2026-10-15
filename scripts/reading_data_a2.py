"""
Тексти для читання A2 (§6 ТЗ «Extensive Reading», §55: на A2 — короткі історії, чати, інструкції, прості новини), v1 · 2026-10-15.

Формат — як у reading_data.py. module — тема A2 (1–10, за модулями A2 у БД: Досвід, Подорожі, Робота,
Установи й документи, Здоров’я, Стосунки, Проблеми, Плани, Думки, Підсумок).
Граматика A2: минулий час (perfekt), майбутній час (futur I), вищий ступінь, «da» + теперішній час, умовний спосіб (bih).
Слова — з уроків A0–A1, нові пояснює словничок (переклад за дотиком). Генератор: scripts/gen_reading.py.
Факти про установи — загальні, без конкретних законів і сум; установи й заклади в текстах вигадані.
"""

TEXTS: list = []

TEXTS += [
    # ------------------------------------------------------------ A2.1 Досвід
    dict(code='RD-A2-001', type='story', situation='work', module=1,
         title=('Як я знайшла роботу', 'Kako sam našla posao'),
         hr='''Kad sam došla u Hrvatsku, nisam znala ni riječ hrvatskog. Prva tri mjeseca bila su teška. Svaki dan sam učila nove riječi i gledala hrvatske serije s titlovima. Onda sam počela tražiti posao. Poslala sam životopis u deset hotela, ali nitko mi nije odgovorio. Jednog dana nazvala me voditeljica jednog malog hotela u Splitu i pozvala me na razgovor. Bila sam jako nervozna, ali sve je prošlo dobro. Razgovarale smo pola na hrvatskom, pola na engleskom. Sljedeći tjedan počela sam raditi na recepciji. Danas tamo radim već dvije godine i hrvatski mi više nije problem.''',
         ua='''Коли я приїхала до Хорватії, я не знала жодного слова хорватською. Перші три місяці були важкими. Щодня я вчила нові слова й дивилася хорватські серіали із субтитрами. Потім я почала шукати роботу. Я надіслала резюме в десять готелів, але ніхто мені не відповів. Одного дня мені зателефонувала керівниця одного маленького готелю в Спліті й запросила мене на співбесіду. Я дуже хвилювалася, але все пройшло добре. Ми розмовляли наполовину хорватською, наполовину англійською. Наступного тижня я почала працювати на рецепції. Сьогодні я працюю там уже два роки, і хорватська для мене більше не проблема.''',
         questions=[
             ('Як вона вчила хорватську спочатку?', ['Вчила слова й дивилася серіали', 'Ходила на курси', 'Ніяк не вчила'], 'Вчила слова й дивилася серіали'),
             ('У скільки готелів вона надіслала резюме?', ['У десять', 'У три', 'У два'], 'У десять'),
             ('Де вона працює зараз?', ['На рецепції готелю', 'У ресторані', 'У школі'], 'На рецепції готелю'),
         ]),
    dict(code='RD-A2-002', type='chat', situation='small_talk', module=1,
         title=('Як минули вихідні?', 'Kako je bilo za vikend?'),
         hr='''Ivana: Bok, Taras! Kako je bilo za vikend?
Taras: Super! U subotu smo bili na Plitvicama. Hodali smo pet sati.
Ivana: Prekrasno! Jeste li vidjeli velike slapove?
Taras: Jesmo. Bilo je puno ljudi, ali vrijedilo je. A ti?
Ivana: Ja sam bila kod kuće. Bila sam bolesna, pa sam samo spavala i gledala filmove.
Taras: Joj, žao mi je! Je li ti sada bolje?
Ivana: Bolje mi je, hvala. Sljedeći put idem s vama!
Taras: Dogovoreno!''',
         ua='''Івана: Привіт, Тарасе! Як минули вихідні?
Тарас: Чудово! У суботу ми були на Плітвицьких озерах. Ходили п’ять годин.
Івана: Чудово! Ви бачили великі водоспади?
Тарас: Бачили. Було багато людей, але воно того було варте. А ти?
Івана: Я була вдома. Я хворіла, тож тільки спала й дивилася фільми.
Тарас: Ой, шкода! Тобі вже краще?
Івана: Краще, дякую. Наступного разу піду з вами!
Тарас: Домовилися!''',
         questions=[
             ('Де був Тарас у суботу?', ['На Плітвицьких озерах', 'Удома', 'На морі'], 'На Плітвицьких озерах'),
             ('Скільки годин вони ходили?', ['П’ять', 'Дві', 'Десять'], 'П’ять'),
             ('Чому Івана була вдома?', ['Вона хворіла', 'Вона працювала', 'Ішов дощ'], 'Вона хворіла'),
         ]),
    # ------------------------------------------------------------ A2.2 Подорожі
    dict(code='RD-A2-003', type='email', situation='travel', module=2,
         title=('Зміна бронювання', 'Promjena rezervacije'),
         hr='''Poštovani,
rezervirala sam kod vas apartman od 10. do 17. srpnja za dvije odrasle osobe i jedno dijete. Nažalost, moramo promijeniti datum jer moj muž ne može dobiti godišnji odmor u srpnju. Možemo li doći od 7. do 14. kolovoza? Ako taj termin nije slobodan, molim vas da mi javite koji je tjedan u kolovozu slobodan. Također bih htjela pitati imate li parkiralište i je li plaža blizu.
Unaprijed hvala na odgovoru.
Srdačan pozdrav,
Oksana Melnyk''',
         ua='''Шановні!
Я забронювала у вас апартаменти з 10 по 17 липня для двох дорослих і однієї дитини. На жаль, ми мусимо змінити дату, бо мій чоловік не може отримати відпустку в липні. Чи можемо ми приїхати з 7 по 14 серпня? Якщо ці дати не вільні, прошу, повідомте мені, який тиждень у серпні вільний. Також я хотіла б запитати, чи є у вас паркування і чи близько пляж.
Заздалегідь дякую за відповідь.
З повагою,
Оксана Мельник''',
         questions=[
             ('Чому родина змінює дати?', ['Чоловік не отримає відпустку в липні', 'Дитина захворіла', 'Апартаменти дорогі'], 'Чоловік не отримає відпустку в липні'),
             ('На який місяць вони хочуть перенести поїздку?', ['На серпень', 'На червень', 'На вересень'], 'На серпень'),
             ('Про що ще питає Оксана?', ['Про паркування й пляж', 'Про сніданок', 'Про таксі'], 'Про паркування й пляж'),
         ]),
    dict(code='RD-A2-004', type='story', situation='travel', module=2,
         title=('Поїздка до Дубровника', 'Izlet u Dubrovnik'),
         hr='''Prošlog ljeta Andrij i njegova sestra putovali su u Dubrovnik. Iz Zagreba su išli autobusom, a put je trajao skoro deset sati. Bili su umorni, ali grad ih je oduševio. Prvi dan šetali su po gradskim zidinama i gledali more i crvene krovove. Drugi dan otišli su brodom na otok Lokrum. Tamo su se kupali i jeli sladoled. Navečer su probali ribu u malom restoranu u Starom gradu. Bilo je skupo, ali jako ukusno. Sestra je napravila sto fotografija. Andrij kaže da će se sigurno vratiti, ali sljedeći put putovat će avionom.''',
         ua='''Минулого літа Андрій і його сестра їздили до Дубровника. Із Загреба вони їхали автобусом, і дорога тривала майже десять годин. Вони були втомлені, але місто їх зачарувало. Першого дня вони гуляли міськими мурами й дивилися на море та червоні дахи. Другого дня вони попливли кораблем на острів Локрум. Там вони купалися й їли морозиво. Увечері вони скуштували рибу в маленькому ресторані в Старому місті. Було дорого, але дуже смачно. Сестра зробила сто фотографій. Андрій каже, що неодмінно повернеться, але наступного разу полетить літаком.''',
         questions=[
             ('Чим вони їхали до Дубровника?', ['Автобусом', 'Поїздом', 'Літаком'], 'Автобусом'),
             ('Що вони робили на Локрумі?', ['Купалися й їли морозиво', 'Ходили в музей', 'Працювали'], 'Купалися й їли морозиво'),
             ('Як Андрій хоче подорожувати наступного разу?', ['Літаком', 'Автобусом', 'Машиною'], 'Літаком'),
         ]),
    # ------------------------------------------------------------ A2.3 Робота
    dict(code='RD-A2-005', type='story', situation='work', module=3,
         title=('Перший тиждень на новій роботі', 'Prvi tjedan na novom poslu'),
         hr='''Danilo je prošli tjedan počeo raditi u velikom skladištu blizu Zagreba. Prvi dan mu je voditelj pokazao cijelo skladište i objasnio pravila. Radno vrijeme je od šest do dva, pa Danilo mora ustati u pet. Prva dva dana bila su teška: nije razumio sve što su kolege govorili, a bilo ga je sram pitati. Treći dan jedan kolega, Marko, ponudio mu je pomoć. Sada mu Marko polako objašnjava riječi koje ne zna. Danilo je zadovoljan: plaća je dobra, a kolege su ljubazni. Sljedeći mjesec dobit će ugovor na godinu dana.''',
         ua='''Минулого тижня Данило почав працювати на великому складі біля Загреба. Першого дня керівник показав йому весь склад і пояснив правила. Робочий час — із шостої до другої, тому Данило мусить вставати о п’ятій. Перші два дні були важкими: він не розумів усього, що говорили колеги, а питати соромився. Третього дня один колега, Марко, запропонував йому допомогу. Тепер Марко повільно пояснює йому слова, яких він не знає. Данило задоволений: зарплата хороша, а колеги привітні. Наступного місяця він отримає договір на рік.''',
         questions=[
             ('О котрій Данило мусить вставати?', ['О п’ятій', 'О шостій', 'О сьомій'], 'О п’ятій'),
             ('Чому перші дні були важкими?', ['Він не все розумів і соромився питати', 'Було холодно', 'Не було роботи'], 'Він не все розумів і соромився питати'),
             ('Що він отримає наступного місяця?', ['Договір на рік', 'Відпустку', 'Нову квартиру'], 'Договір на рік'),
         ]),
    dict(code='RD-A2-006', type='email', situation='work', module=3,
         title=('Прохання про відпустку', 'Molba za godišnji odmor'),
         hr='''Poštovana gospođo Babić,
htio bih uzeti godišnji odmor od 4. do 15. kolovoza. U to vrijeme moja obitelj dolazi iz Ukrajine i želio bih provesti nekoliko dana s njima. Razgovarao sam s kolegom Jurićem i on me može zamijeniti na smjenama. Sve zadatke završit ću do kraja srpnja. Ako taj termin nije moguć, molim vas da mi predložite drugi.
Hvala na razumijevanju.
S poštovanjem,
Taras Kovalenko''',
         ua='''Шановна пані Бабич!
Я хотів би взяти відпустку з 4 по 15 серпня. У цей час до мене приїжджає родина з України, і я хотів би провести з ними кілька днів. Я поговорив із колегою Юричем, і він може замінити мене на змінах. Усі завдання я закінчу до кінця липня. Якщо ці дати неможливі, прошу запропонувати мені інші.
Дякую за розуміння.
З повагою,
Тарас Коваленко''',
         questions=[
             ('Чому Тарас хоче відпустку?', ['Приїжджає родина з України', 'Він хворий', 'Він переїжджає'], 'Приїжджає родина з України'),
             ('Хто його замінить?', ['Колега Юрич', 'Пані Бабич', 'Ніхто'], 'Колега Юрич'),
             ('Що він зробить до кінця липня?', ['Закінчить усі завдання', 'Поїде в Україну', 'Знайде нову роботу'], 'Закінчить усі завдання'),
         ]),
    # ------------------------------------------------------------ A2.4 Установи й документи
    dict(code='RD-A2-007', type='instruction', situation='bank', module=4,
         title=('Як відкрити рахунок у банку', 'Kako otvoriti račun u banci'),
         hr='''Želite otvoriti tekući račun u našoj banci? To je jednostavno. Prvo dogovorite termin preko naše stranice ili telefonom. Na termin ponesite putovnicu ili osobnu iskaznicu, OIB i dokaz o adresi. Ako radite, ponesite i ugovor o radu. Savjetnik će vam objasniti kakve račune imamo i koliko koštaju. Kad potpišete ugovor, karticu ćete dobiti poštom za sedam do deset dana. Mobilno bankarstvo možete aktivirati odmah. Za sva pitanja nazovite nas ili nam pišite.''',
         ua='''Хочете відкрити поточний рахунок у нашому банку? Це просто. Спочатку домовтеся про зустріч через наш сайт або телефоном. На зустріч візьміть паспорт або посвідчення особи, OIB і підтвердження адреси. Якщо ви працюєте, візьміть також трудовий договір. Консультант пояснить вам, які рахунки в нас є і скільки вони коштують. Коли ви підпишете договір, картку отримаєте поштою за сім–десять днів. Мобільний банкінг можна активувати одразу. З усіх питань телефонуйте нам або пишіть.''',
         questions=[
             ('Що треба зробити спочатку?', ['Домовитися про зустріч', 'Прийти без запису', 'Надіслати гроші'], 'Домовитися про зустріч'),
             ('Що ще потрібно, якщо ви працюєте?', ['Трудовий договір', 'Диплом', 'Фото'], 'Трудовий договір'),
             ('Як і коли прийде картка?', ['Поштою за 7–10 днів', 'Одразу в банку', 'Через місяць'], 'Поштою за 7–10 днів'),
         ]),
    dict(code='RD-A2-008', type='email', situation='administration', module=4,
         title=('У заяві бракує документа', 'Nedostaje dokument'),
         hr='''Poštovani gospodine Melnyk,
primili smo vaš zahtjev za produženje boravka. Nažalost, zahtjev nije potpun: nedostaje potvrda o zdravstvenom osiguranju. Molimo vas da je donesete osobno ili pošaljete poštom najkasnije do 30. listopada. Ako dokument ne dobijemo na vrijeme, nećemo moći riješiti vaš zahtjev. Ako imate pitanja, možete nas nazvati radnim danom od 8 do 12 sati.
Hvala na razumijevanju.
S poštovanjem,
Ured za strance''',
         ua='''Шановний пане Мельник!
Ми отримали вашу заяву про продовження перебування. На жаль, заява неповна: бракує підтвердження медичного страхування. Просимо принести його особисто або надіслати поштою не пізніше 30 жовтня. Якщо ми не отримаємо документ вчасно, ми не зможемо розглянути вашу заяву. Якщо у вас є запитання, можете зателефонувати нам у робочі дні з 8 до 12 години.
Дякуємо за розуміння.
З повагою,
Відділ для іноземців''',
         questions=[
             ('Якого документа бракує?', ['Підтвердження медичного страхування', 'Паспорта', 'Фото'], 'Підтвердження медичного страхування'),
             ('До якої дати треба його принести?', ['До 30 жовтня', 'До 30 вересня', 'До кінця року'], 'До 30 жовтня'),
             ('Коли можна зателефонувати?', ['У робочі дні з 8 до 12', 'Щодня до 20', 'Тільки в суботу'], 'У робочі дні з 8 до 12'),
         ]),
    # ------------------------------------------------------------ A2.5 Здоров’я
    dict(code='RD-A2-009', type='story', situation='health', module=5,
         title=('Олена застудилася', 'Olena se prehladila'),
         hr='''Prošli tjedan Olena se jako prehladila. Imala je temperaturu, boljelo ju je grlo i stalno je kašljala. Prva dva dana pila je čaj s medom i ležala u krevetu, ali nije joj bilo bolje. U srijedu je nazvala svoju liječnicu i naručila se na pregled. Liječnica ju je pregledala i rekla da ima upalu grla. Dala joj je recept za antibiotik i bolovanje do petka. Olena je kupila lijek u ljekarni i uzimala ga je dva puta dnevno. U subotu se već osjećala puno bolje. Sljedeći put odmah će nazvati liječnicu.''',
         ua='''Минулого тижня Олена сильно застудилася. У неї була температура, боліло горло, і вона постійно кашляла. Перші два дні вона пила чай із медом і лежала в ліжку, але їй не ставало краще. У середу вона зателефонувала своїй лікарці й записалася на огляд. Лікарка оглянула її й сказала, що в неї запалення горла. Вона дала їй рецепт на антибіотик і лікарняний до п’ятниці. Олена купила ліки в аптеці й приймала їх двічі на день. У суботу вона почувалася вже набагато краще. Наступного разу вона одразу зателефонує лікарці.''',
         questions=[
             ('Що боліло в Олени?', ['Горло', 'Нога', 'Зуб'], 'Горло'),
             ('Що сказала лікарка?', ['Що в неї запалення горла', 'Що вона здорова', 'Що треба в лікарню'], 'Що в неї запалення горла'),
             ('Коли Олені стало краще?', ['У суботу', 'У середу', 'У понеділок'], 'У суботу'),
         ]),
    dict(code='RD-A2-010', type='article', situation='health', module=5,
         title=('Як не захворіти взимку', 'Kako ne biti bolestan zimi'),
         hr='''Zimi je puno ljudi prehlađeno. Liječnici kažu da je najvažnije često prati ruke, osobito poslije javnog prijevoza i prije jela. Trebamo piti dovoljno vode i jesti puno voća i povrća. Dobro je svaki dan šetati na svježem zraku, čak i kad je hladno. Spavajte najmanje sedam sati. Ako ste bolesni, ostanite kod kuće i ne idite na posao ili u školu, jer tako možete zaraziti druge. Ako imate visoku temperaturu dulje od tri dana, javite se svom liječniku.''',
         ua='''Узимку багато людей застуджені. Лікарі кажуть, що найважливіше — часто мити руки, особливо після громадського транспорту й перед їжею. Треба пити достатньо води й їсти багато фруктів і овочів. Добре щодня гуляти на свіжому повітрі, навіть коли холодно. Спіть щонайменше сім годин. Якщо ви хворі, залишайтеся вдома й не йдіть на роботу чи до школи, бо так можна заразити інших. Якщо висока температура тримається довше трьох днів, зверніться до свого лікаря.''',
         questions=[
             ('Коли треба мити руки?', ['Після транспорту й перед їжею', 'Тільки вранці', 'Раз на тиждень'], 'Після транспорту й перед їжею'),
             ('Скільки годин радять спати?', ['Щонайменше сім', 'П’ять', 'Десять'], 'Щонайменше сім'),
             ('Що робити, якщо температура тримається понад три дні?', ['Звернутися до лікаря', 'Піти на роботу', 'Більше гуляти'], 'Звернутися до лікаря'),
         ]),
    # ------------------------------------------------------------ A2.6 Стосунки
    dict(code='RD-A2-011', type='email', situation='small_talk', module=6,
         title=('Лист подрузі в Україну', 'Pismo prijateljici u Ukrajini'),
         hr='''Draga Ira,
dugo ti se nisam javila, oprosti! Ovdje je sve dobro. Djeca su se navikla na školu i već imaju prijatelje. Sofija je u razredu najbolja iz matematike, a Danilo igra nogomet. Ja sam promijenila posao: sada radim u vrtiću kao pomoćnica odgojiteljice. Posao mi se jako sviđa, iako je plaća mala. Hrvatski mi ide sve bolje, ali još uvijek griješim. Puno mislim na tebe i na naš grad. Kad ćeš doći u posjet? Imamo mali stan, ali za tebe ćemo naći mjesto.
Grlim te,
Olena''',
         ua='''Люба Іро!
Я давно тобі не писала, вибач! Тут усе добре. Діти звикли до школи й уже мають друзів. Софія найкраща в класі з математики, а Данило грає у футбол. Я змінила роботу: тепер працюю в дитячому садку помічницею вихователя. Робота мені дуже подобається, хоча зарплата маленька. Хорватська дається мені дедалі краще, але я досі помиляюся. Я багато думаю про тебе і про наше місто. Коли ти приїдеш у гості? У нас маленька квартира, але для тебе ми знайдемо місце.
Обіймаю тебе,
Олена''',
         questions=[
             ('Що нового в роботі Олени?', ['Вона працює в дитсадку', 'Вона не працює', 'Вона працює в готелі'], 'Вона працює в дитсадку'),
             ('Хто грає у футбол?', ['Данило', 'Софія', 'Олена'], 'Данило'),
             ('Що Олена пропонує подрузі?', ['Приїхати в гості', 'Надіслати гроші', 'Вчити хорватську'], 'Приїхати в гості'),
         ]),
    dict(code='RD-A2-012', type='dialogue', situation='housing', module=6,
         title=('Нова сусідка', 'Nova susjeda'),
         hr='''Marija: Dobar dan! Vi ste nova susjeda iz stana 5, zar ne?
Oksana: Da, dobar dan! Ja sam Oksana. Doselili smo se prošli tjedan.
Marija: Drago mi je! Ja sam Marija, živim ovdje već dvadeset godina. Kako vam se sviđa zgrada?
Oksana: Jako nam se sviđa, mirna je. Samo još ne znamo gdje se odvaja smeće.
Marija: Kante su iza zgrade, pokraj garaže. Ako vam nešto treba, slobodno pozvonite.
Oksana: Hvala vam puno! Dođite na kavu u nedjelju, ako imate vremena.
Marija: Rado ću doći!''',
         ua='''Марія: Добрий день! Ви нова сусідка з квартири 5, правда?
Оксана: Так, добрий день! Я Оксана. Ми переїхали минулого тижня.
Марія: Приємно познайомитися! Я Марія, живу тут уже двадцять років. Як вам подобається будинок?
Оксана: Дуже подобається, він тихий. Тільки ми ще не знаємо, де сортують сміття.
Марія: Контейнери за будинком, біля гаража. Якщо вам щось потрібно, сміливо дзвоніть у двері.
Оксана: Щиро дякую! Приходьте на каву в неділю, якщо матимете час.
Марія: Із радістю прийду!''',
         questions=[
             ('Скільки Марія живе в будинку?', ['Двадцять років', 'Тиждень', 'Рік'], 'Двадцять років'),
             ('Де контейнери для сміття?', ['За будинком, біля гаража', 'Перед входом', 'У підвалі'], 'За будинком, біля гаража'),
             ('Куди Оксана запрошує Марію?', ['На каву в неділю', 'На вечерю в суботу', 'На прогулянку'], 'На каву в неділю'),
         ]),
    # ------------------------------------------------------------ A2.7 Проблеми
    dict(code='RD-A2-013', type='email', situation='housing', module=7,
         title=('Проблема в квартирі', 'Problem u stanu'),
         hr='''Poštovani gospodine Horvat,
javljam vam se jer već tri dana u kupaonici curi voda iz cijevi ispod umivaonika. Pokušala sam sama zatvoriti ventil, ali voda i dalje curi. Pod je stalno mokar i bojim se da će se oštetiti stan ispod nas. Osim toga, perilica rublja ne radi od prošle subote. Molim vas da što prije pošaljete majstora. Kod kuće sam svaki dan poslije 16 sati, a u subotu cijeli dan.
Unaprijed hvala.
Lijep pozdrav,
Olena Kovalenko''',
         ua='''Шановний пане Горват!
Пишу вам, бо вже три дні у ванній тече вода з труби під умивальником. Я пробувала сама закрити вентиль, але вода й далі тече. Підлога весь час мокра, і я боюся, що пошкодиться квартира під нами. Крім того, пральна машина не працює з минулої суботи. Прошу якомога швидше надіслати майстра. Я вдома щодня після 16 години, а в суботу — цілий день.
Заздалегідь дякую.
З повагою,
Олена Коваленко''',
         questions=[
             ('Що сталося у ванній?', ['Тече вода з труби', 'Не горить світло', 'Зламалися двері'], 'Тече вода з труби'),
             ('Що ще не працює?', ['Пральна машина', 'Холодильник', 'Опалення'], 'Пральна машина'),
             ('Коли Олена вдома?', ['Щодня після 16 і в суботу', 'Тільки вранці', 'Тільки в неділю'], 'Щодня після 16 і в суботу'),
         ]),
    dict(code='RD-A2-014', type='story', situation='transport', module=7,
         title=('Загублений гаманець', 'Izgubljeni novčanik'),
         hr='''U utorak je Taras putovao tramvajem na posao. Kad je izašao na svojoj stanici, shvatio je da nema novčanika. U novčaniku su bili osobna iskaznica, bankovna kartica i dvadeset eura. Odmah je nazvao banku i blokirao karticu. Zatim je otišao u ured za izgubljene stvari, ali novčanika tamo nije bilo. Navečer ga je nazvala nepoznata žena. Rekla je da je našla novčanik u tramvaju, a broj telefona pronašla je na posjetnici. Sljedeći dan Taras joj je donio kutiju čokolade i lijepo joj se zahvalio. Novac je bio unutra!''',
         ua='''У вівторок Тарас їхав трамваєм на роботу. Коли він вийшов на своїй зупинці, то зрозумів, що в нього немає гаманця. У гаманці були посвідчення особи, банківська картка і двадцять євро. Він одразу зателефонував у банк і заблокував картку. Потім пішов у бюро знахідок, але гаманця там не було. Увечері йому зателефонувала незнайома жінка. Вона сказала, що знайшла гаманець у трамваї, а номер телефону знайшла на візитівці. Наступного дня Тарас приніс їй коробку цукерок і щиро подякував. Гроші були всередині!''',
         questions=[
             ('Що було в гаманці?', ['Посвідчення, картка й 20 євро', 'Тільки гроші', 'Ключі й телефон'], 'Посвідчення, картка й 20 євро'),
             ('Що Тарас зробив одразу?', ['Зателефонував у банк', 'Пішов додому', 'Купив новий гаманець'], 'Зателефонував у банк'),
             ('Як жінка знайшла його номер?', ['На візитівці в гаманці', 'В інтернеті', 'У поліції'], 'На візитівці в гаманці'),
         ]),
    # ------------------------------------------------------------ A2.8 Плани
    dict(code='RD-A2-015', type='chat', situation='travel', module=8,
         title=('Плани на літо', 'Planovi za ljeto'),
         hr='''Marko: Što ćete raditi ovo ljeto?
Oksana: U srpnju ćemo ostati u Zagrebu jer radim. U kolovozu ćemo otići na more na tjedan dana.
Marko: Kamo idete?
Oksana: Na Krk. Već smo rezervirali mali apartman blizu plaže. Djeca će se kupati cijeli dan!
Marko: Super! Mi ćemo ići u planine, u Gorski kotar. Tamo je ljeti svježe i nema gužve.
Oksana: To zvuči lijepo. Hoćete li spavati u šatoru?
Marko: Hoćemo, prve dvije noći. Poslije ćemo spavati u maloj kući kod prijatelja.''',
         ua='''Марко: Що ви робитимете цього літа?
Оксана: У липні ми залишимося в Загребі, бо я працюю. У серпні поїдемо на море на тиждень.
Марко: Куди їдете?
Оксана: На Крк. Ми вже забронювали маленькі апартаменти біля пляжу. Діти купатимуться цілий день!
Марко: Чудово! А ми поїдемо в гори, у Горскі-Котар. Там улітку свіжо й немає натовпу.
Оксана: Звучить гарно. Ви спатимете в наметі?
Марко: Так, перші дві ночі. Потім спатимемо в маленькому будиночку в друзів.''',
         questions=[
             ('Куди Оксана поїде в серпні?', ['На острів Крк', 'У гори', 'В Україну'], 'На острів Крк'),
             ('Чому Марко обрав гори?', ['Там свіжо й немає натовпу', 'Там дешево', 'Там живуть батьки'], 'Там свіжо й немає натовпу'),
             ('Де Марко спатиме перші дві ночі?', ['У наметі', 'У готелі', 'В апартаментах'], 'У наметі'),
         ]),
    dict(code='RD-A2-016', type='notice', situation='work', module=8,
         title=('Курс хорватської: план на осінь', 'Tečaj hrvatskog: plan za jesen'),
         hr='''Dragi polaznici,
u listopadu počinje novi tečaj hrvatskog jezika za razinu A2. Nastava će biti utorkom i četvrtkom od 18 do 20 sati, a trajat će do kraja siječnja. Učit ćemo prošlo i buduće vrijeme, pisati e-mailove i razgovarati o poslu i svakodnevnom životu. Na kraju tečaja pisat ćete test, a tko ga položi, dobit će potvrdu. Prijave primamo do 25. rujna. Broj mjesta je ograničen, zato se prijavite na vrijeme!
Vaša škola stranih jezika''',
         ua='''Шановні слухачі!
У жовтні починається новий курс хорватської мови для рівня A2. Заняття будуть щовівторка й щочетверга з 18 до 20 години і триватимуть до кінця січня. Ми вчитимемо минулий і майбутній час, писатимемо листи й говоритимемо про роботу та повсякденне життя. Наприкінці курсу ви писатимете тест, і хто його складе, отримає підтвердження. Заявки приймаємо до 25 вересня. Кількість місць обмежена, тож записуйтеся вчасно!
Ваша школа іноземних мов''',
         questions=[
             ('Коли будуть заняття?', ['Щовівторка й щочетверга ввечері', 'Щодня вранці', 'По суботах'], 'Щовівторка й щочетверга ввечері'),
             ('До коли триватиме курс?', ['До кінця січня', 'До Нового року', 'До травня'], 'До кінця січня'),
             ('Що отримає той, хто складе тест?', ['Підтвердження (сертифікат)', 'Гроші', 'Знижку'], 'Підтвердження (сертифікат)'),
         ]),
    # ------------------------------------------------------------ A2.9 Думки
    dict(code='RD-A2-017', type='article', situation='housing', module=9,
         title=('Місто чи село?', 'Grad ili selo?'),
         hr='''Mnogi ljudi u Hrvatskoj sele se iz malih mjesta u veće gradove, osobito u Zagreb. U gradu je lakše naći posao, a ima i više škola, bolnica i kafića. Ali život u gradu je skuplji: stanovi su skupi, a promet je gust. Na selu je mirnije i zrak je čišći. Kuće su jeftinije, a ljudi se bolje poznaju. S druge strane, autobus ponekad vozi samo dva puta dnevno, a do najbliže bolnice treba voziti pola sata. Što je bolje? Mislim da to ovisi o tome što vam je u životu važnije.''',
         ua='''Багато людей у Хорватії переїжджають із маленьких населених пунктів у більші міста, особливо в Загреб. У місті легше знайти роботу, а ще там більше шкіл, лікарень і кафе. Але життя в місті дорожче: квартири дорогі, а рух щільний. На селі спокійніше й повітря чистіше. Будинки дешевші, а люди краще знають одне одного. З іншого боку, автобус іноді їздить лише двічі на день, а до найближчої лікарні треба їхати пів години. Що краще? Я думаю, це залежить від того, що для вас важливіше в житті.''',
         questions=[
             ('Чому люди переїжджають у місто?', ['Там легше знайти роботу', 'Там чистіше повітря', 'Там дешевше'], 'Там легше знайти роботу'),
             ('Що краще на селі?', ['Спокійніше й чистіше повітря', 'Більше лікарень', 'Частіше ходить автобус'], 'Спокійніше й чистіше повітря'),
             ('Яка думка автора?', ['Залежить від того, що вам важливіше', 'Місто краще', 'Село краще'], 'Залежить від того, що вам важливіше'),
         ]),
    dict(code='RD-A2-018', type='story', situation='small_talk', module=9,
         title=('Що мені подобається в Хорватії', 'Što mi se sviđa u Hrvatskoj'),
         hr='''Živim u Hrvatskoj dvije godine i često me pitaju što mi se ovdje najviše sviđa. Prvo, more! Nikad prije nisam vidjela tako čisto i plavo more. Drugo, ljudi nikamo ne žure. Kava s prijateljima može trajati dva sata i to je normalno. Treće, hrana je jednostavna, ali odlična: riba, maslinovo ulje, svježe povrće. Naravno, nije sve savršeno. Papirologija je ponekad spora, a ljeti je previše turista. Ali kad sve usporedim, mislim da sam imala sreće što sam došla baš ovdje.''',
         ua='''Я живу в Хорватії два роки, і мене часто питають, що мені тут найбільше подобається. По-перше, море! Ніколи раніше я не бачила такого чистого й синього моря. По-друге, люди нікуди не поспішають. Кава з друзями може тривати дві години, і це нормально. По-третє, їжа проста, але чудова: риба, оливкова олія, свіжі овочі. Звісно, не все ідеально. Паперова тяганина іноді повільна, а влітку забагато туристів. Але коли я все порівнюю, думаю, мені пощастило, що я приїхала саме сюди.''',
         questions=[
             ('Що авторці найбільше подобається?', ['Море, люди та їжа', 'Погода взимку', 'Ціни'], 'Море, люди та їжа'),
             ('Скільки може тривати кава з друзями?', ['Дві години', 'П’ять хвилин', 'Цілий день'], 'Дві години'),
             ('Що їй не подобається?', ['Повільна бюрократія й натовпи туристів', 'Море', 'Їжа'], 'Повільна бюрократія й натовпи туристів'),
         ]),
    # ------------------------------------------------------------ A2.10 Підсумок
    dict(code='RD-A2-019', type='news', situation='cafe_restaurant', module=10,
         title=('Фестиваль у Загребі', 'Festival u Zagrebu'),
         hr='''Ovog vikenda u Zagrebu se održava Festival hrane i vina. Na Trgu bana Jelačića bit će više od pedeset štandova s domaćim proizvodima iz cijele Hrvatske. Posjetitelji će moći probati sireve, pršut, med i vina iz Istre, Slavonije i Dalmacije. Za djecu su organizirane radionice i predstave. Festival je otvoren od petka do nedjelje, od 10 do 22 sata, a ulaz je besplatan. Organizatori očekuju više od dvadeset tisuća posjetitelja. Ako bude padala kiša, program će se preseliti na tržnicu Dolac.''',
         ua='''Цими вихідними в Загребі проходить Фестиваль їжі та вина. На площі бана Єлачича буде понад п’ятдесят наметів із домашніми продуктами з усієї Хорватії. Відвідувачі зможуть скуштувати сири, пршут, мед і вина з Істрії, Славонії та Далмації. Для дітей підготували майстер-класи й вистави. Фестиваль відкритий із п’ятниці до неділі, з 10 до 22 години, вхід безкоштовний. Організатори очікують понад двадцять тисяч відвідувачів. Якщо йтиме дощ, програму перенесуть на ринок Долац.''',
         questions=[
             ('Скільки буде стендів?', ['Понад п’ятдесят', 'Двадцять', 'Десять'], 'Понад п’ятдесят'),
             ('Скільки коштує вхід?', ['Безкоштовно', '5 євро', '10 євро'], 'Безкоштовно'),
             ('Що буде, якщо піде дощ?', ['Програму перенесуть на ринок Долац', 'Фестиваль скасують', 'Його перенесуть на понеділок'], 'Програму перенесуть на ринок Долац'),
         ]),
    dict(code='RD-A2-020', type='story', situation='work', module=10,
         title=('Два роки в Хорватії', 'Dvije godine u Hrvatskoj'),
         hr='''Prije dvije godine Andrij je došao u Rijeku s jednim koferom i bez znanja hrvatskog. Prvih mjeseci radio je na gradilištu, a navečer je učio jezik. Danas radi kao električar u maloj tvrtki i sam razgovara s klijentima. Prošle godine položio je ispit iz hrvatskog za razinu A2, a ove godine želi upisati tečaj za B1. Unajmio je stan s balkonom i pogledom na more. Kaže da mu najviše nedostaju mama i bakini kolači. Sljedećeg ljeta mama će ga prvi put posjetiti. Andrij je već napravio plan: pokazat će joj Opatiju, Krk i Plitvička jezera.''',
         ua='''Два роки тому Андрій приїхав до Рієки з однією валізою і без знання хорватської. Перші місяці він працював на будівництві, а ввечері вчив мову. Сьогодні він працює електриком у маленькій фірмі й сам розмовляє з клієнтами. Минулого року він склав іспит із хорватської на рівень A2, а цього року хоче записатися на курс B1. Він винайняв квартиру з балконом і видом на море. Каже, що найбільше йому бракує мами й бабусиних тістечок. Наступного літа мама вперше приїде до нього. Андрій уже склав план: він покаже їй Опатію, Крк і Плітвицькі озера.''',
         questions=[
             ('Де Андрій працював спочатку?', ['На будівництві', 'У готелі', 'У школі'], 'На будівництві'),
             ('Ким він працює зараз?', ['Електриком', 'Кухарем', 'Водієм'], 'Електриком'),
             ('Хто приїде до нього наступного літа?', ['Мама', 'Сестра', 'Друг'], 'Мама'),
         ]),
]
