"""
Тексти для читання A2 v2 (§6 ТЗ «Extensive Reading»), 36 нових текстів · 2026-11-13.

Програма A2 v2 (content/reviews/2026-11-12_curriculum_a2_v2_program.md): 4 тексти на модуль, 56 разом.
20 наявних текстів (RD-A2-001…020) уже розкладено по модулях A2.1, 3, 4, 5, 6, 7, 9, 10, 13, 14 (по 2);
тут — по 2 у ці модулі й по 4 у модулі без текстів: A2.2 «Навчання», A2.8 «Авто в Хорватії»,
A2.11 «Хорватія: краї», A2.12 «Українці в Хорватії».

Формат запису:
  key       — короткий ключ (коди RD-A2-021… генератор дає за порядком: модуль, потім порядок у файлі);
  type, situation (код з lib/situations.ts або None), module (1–14), title (ua, hr), hr, ua,
  questions — 3 питання: (питання, [3 варіанти українською], відповідь).
Словничок форм кожного тексту — scripts/reading_lexicon_a2_v2.py (TEXT_ANN[key]).
Генератор: python3 -B scripts/gen_reading_a2_v2.py. Установи, люди й заклади — вигадані; факти — загальні,
без конкретних сум і норм законів (крім загальновідомих: 112, знижка 50 % за оплату штрафу протягом 8 днів).
"""

TEXTS: list = []

# ===================================================================== A2.1 Туризм і подорожі: Адріатика
TEXTS += [
    dict(key='m01_complaint', type='email', situation='travel', module=1,
         title=('Скарга на апартаменти', 'Prigovor na apartman'),
         hr='''Poštovani gospodine Babiću,
jučer smo stigli u vaš apartman u Makarskoj. Lokacija je odlična i plaža je blizu, ali imamo nekoliko problema. Klima-uređaj ne funkcionira, a u kupaonici curi voda iz tuš kabine. Također, na prozoru nema mrežice protiv komaraca, pa noću ne možemo spavati. U oglasu je pisalo da je doručak uključen, ali danas ujutro nitko nije došao. Molim vas da riješite problem što prije ili da nas premjestite u drugi apartman. Ako to nije moguće, htjeli bismo dobiti povrat predujma.
Unaprijed hvala,
Darja Kovalenko''',
         ua='''Шановний пане Бабичу!
Учора ми приїхали до ваших апартаментів у Макарській. Розташування чудове, і пляж поруч, але в нас є кілька проблем. Кондиціонер не працює, а у ванній з душової кабіни тече вода. Також на вікні немає сітки від комарів, тож уночі ми не можемо спати. В оголошенні було написано, що сніданок включено, але сьогодні вранці ніхто не прийшов. Прошу вас якнайшвидше розв'язати проблему або переселити нас в інші апартаменти. Якщо це неможливо, ми хотіли б отримати назад передоплату.
Заздалегідь дякую,
Дар'я Коваленко''',
         questions=[
             ('Що не працює в апартаментах?', ['Кондиціонер', 'Холодильник', 'Телевізор'], 'Кондиціонер'),
             ('Чого бракує на вікні?', ['Сітки від комарів', 'Штор', 'Ручки'], 'Сітки від комарів'),
             ('Чого хоче Дар’я, якщо проблему не розв’яжуть?', ['Повернути передоплату', 'Знижку на вечерю', 'Новий ключ'], 'Повернути передоплату'),
         ],),
    dict(key='m01_ferry', type='notice', situation='travel', module=1,
         title=('Пором сьогодні не ходить', 'Obavijest putnicima'),
         hr='''OBAVIJEST PUTNICIMA
Zbog nevremena i bure danas je prekid plovidbe na trajektnoj liniji Split – Supetar. Trajekti neće voziti od 14 do 18 sati. Katamaran za Hvar također ne vozi. Putnici koji su kupili kartu mogu s njom putovati sutra ili kartu vratiti na blagajni. Vozači koji čekaju u koloni neka ostanu u autima i prate obavijesti. Kad bura prođe, linija će opet raditi prema redu vožnje. Više o tome pročitajte na stranici Jadrolinije ili pitajte u lučkoj kapetaniji.
Hvala na razumijevanju!''',
         ua='''ОГОЛОШЕННЯ ДЛЯ ПАСАЖИРІВ
Через негоду й буру сьогодні припинено рух на поромній лінії Спліт – Супетар. Пороми не ходитимуть із 14 до 18 години. Катамаран на Хвар теж не ходить. Пасажири, які купили квиток, можуть поїхати з ним завтра або здати квиток у касі. Водії, які чекають у черзі, нехай залишаються в машинах і стежать за оголошеннями. Коли бура мине, лінія знову працюватиме за розкладом. Докладніше про це читайте на сторінці «Ядролінії» або питайте в капітанаті порту.
Дякуємо за розуміння!''',
         questions=[
             ('Чому скасовано рейси?', ['Через негоду й буру', 'Через ремонт порома', 'Через страйк'], 'Через негоду й буру'),
             ('Що можуть зробити пасажири з квитком?', ['Поїхати з ним завтра або здати його в касі', 'Поміняти його на автобус', 'Нічого'], 'Поїхати з ним завтра або здати його в касі'),
             ('Що мають робити водії в черзі?', ['Залишатися в машинах і стежити за оголошеннями', 'Їхати до іншого порту', 'Чекати в кафе'], 'Залишатися в машинах і стежити за оголошеннями'),
         ],),
]

# ===================================================================== A2.2 Навчання: курси, університет, школа
TEXTS += [
    dict(key='m02_course', type='ad', situation=None, module=2,
         title=('Курси хорватської для дорослих', 'Tečajevi hrvatskog jezika za odrasle'),
         hr='''TEČAJEVI HRVATSKOG JEZIKA ZA ODRASLE
Pučko otvoreno učilište poziva polaznike na upis u zimski semestar.
Nudimo:
– početni tečaj za početnike – dva puta tjedno, večernji tečaj od 18 do 20 sati;
– napredni tečaj – ponedjeljkom i srijedom;
– individualnu nastavu po dogovoru.
Radimo u malim grupama, najviše deset polaznika. Prije upisa svi polaznici pišu besplatan test razine. Školarina je 300 eura po tečaju, a moguće je i plaćanje u ratama. Na kraju tečaja dobivate potvrdu o pohađanju, a možete polagati i ispit iz hrvatskog.
Upisi traju do 15. siječnja.''',
         ua='''КУРСИ ХОРВАТСЬКОЇ МОВИ ДЛЯ ДОРОСЛИХ
Народний відкритий університет запрошує слухачів записатися на зимовий семестр.
Пропонуємо:
– початковий курс для початківців – двічі на тиждень, вечірній курс із 18 до 20 години;
– курс для просунутих – по понеділках і середах;
– індивідуальні заняття за домовленістю.
Працюємо в малих групах, щонайбільше десять слухачів. Перед записом усі слухачі пишуть безкоштовний тест рівня. Вартість навчання – 300 євро за курс, можна платити й частинами. Наприкінці курсу ви отримуєте довідку про відвідування, а також можете скласти іспит з хорватської.
Запис триває до 15 січня.''',
         questions=[
             ('Скільки щонайбільше слухачів у групі?', ['Десять', 'П’ять', 'Двадцять'], 'Десять'),
             ('Що пишуть усі перед записом?', ['Безкоштовний тест рівня', 'Твір', 'Заяву'], 'Безкоштовний тест рівня'),
             ('Як можна платити за курс?', ['Частинами', 'Тільки готівкою', 'Платити не треба'], 'Частинами'),
         ],),
    dict(key='m02_diploma', type='email', situation='administration', module=2,
         title=('Визнання диплома: бракує документів', 'Priznavanje diplome'),
         hr='''Predmet: Priznavanje inozemne kvalifikacije
Poštovana gospođo Petrenko,
primili smo Vaš zahtjev za akademsko priznavanje diplome. Nažalost, u zahtjevu nedostaju neki dokumenti. Molimo Vas da ga dopunite i priložite sljedeće dokumente:
– ovjerenu presliku diplome s apostille pečatom,
– dodatak diplomi ili prijepis ocjena,
– ovjereni prijevod na hrvatski jezik.
Dokumente možete poslati poštom ili donijeti osobno u ured za priznavanje. Odgovor ćete dobiti u roku od 60 dana. Prije izdavanja rješenja trebate platiti upravnu pristojbu.
S poštovanjem,
Ured za akademsko priznavanje''',
         ua='''Тема: Визнання іноземної кваліфікації
Шановна пані Петренко!
Ми отримали вашу заяву про академічне визнання диплома. На жаль, у заяві бракує деяких документів. Просимо вас доповнити її й додати такі документи:
– завірену копію диплома з апостилем,
– додаток до диплома або виписку оцінок,
– завірений переклад хорватською мовою.
Документи можна надіслати поштою або принести особисто до відділу визнання. Відповідь ви отримаєте протягом 60 днів. Перед видачею рішення вам треба сплатити адміністративний збір.
З повагою,
Відділ академічного визнання''',
         questions=[
             ('Чому заява неповна?', ['Бракує документів', 'Неправильна адреса', 'Заява запізнилася'], 'Бракує документів'),
             ('Що потрібно додати?', ['Завірену копію диплома, додаток і переклад', 'Фото й паспорт', 'Рекомендаційний лист'], 'Завірену копію диплома, додаток і переклад'),
             ('Як можна надіслати документи?', ['Поштою або принести особисто', 'Лише електронною поштою', 'Через друга'], 'Поштою або принести особисто'),
         ],),
    dict(key='m02_school', type='message', situation=None, module=2,
         title=('Повідомлення від класної керівниці', 'Poruka razrednice'),
         hr='''Poštovani roditelji,
podsjećam vas da je u petak izlet razreda na Plitvička jezera. Polazak je u 7:30 ispred škole, a povratak oko 18 sati. Djeca trebaju ponijeti marendu, vodu i udobnu obuću. Za izlet je potrebna potpisana suglasnost roditelja. Molim vas da suglasnost pošaljete do srijede. Također vas obavještavam da su ocjene iz prvog polugodišta upisane u e-Dnevnik. Neki učenici imaju izostanke koji još nisu opravdani. Liječničku ispričnicu treba donijeti u roku od tjedan dana.
Srdačan pozdrav,
razrednica Maja Božić''',
         ua='''Шановні батьки!
Нагадую вам, що в п'ятницю класна екскурсія на Плітвицькі озера. Відправлення о 7:30 перед школою, а повернення близько 18 години. Діти мають узяти з собою перекус, воду й зручне взуття. Для екскурсії потрібна підписана згода батьків. Прошу вас надіслати згоду до середи. Також повідомляю вам, що оцінки за перше півріччя внесено в «e-Dnevnik». Деякі учні мають пропуски, які ще не виправдано. Довідку від лікаря треба принести протягом тижня.
З повагою,
класна керівниця Мая Божич''',
         questions=[
             ('Куди їде клас?', ['На Плітвицькі озера', 'До Загреба', 'На море'], 'На Плітвицькі озера'),
             ('Що потрібно надіслати до середи?', ['Підписану згоду батьків', 'Гроші', 'Фото'], 'Підписану згоду батьків'),
             ('Що треба зробити з невиправданими пропусками?', ['Принести довідку від лікаря протягом тижня', 'Нічого', 'Подзвонити директору'], 'Принести довідку від лікаря протягом тижня'),
         ],),
    dict(key='m02_activities', type='chat', situation='small_talk', module=2,
         title=('Гуртки для дітей', 'Izvanškolske aktivnosti'),
         hr='''Darja: Ivana, u koje izvanškolske aktivnosti ide tvoja kći?
Ivana: Lucija ide u glazbenu školu i na rukomet. A Maks?
Darja: Želi se upisati u vaterpolo klub, ali ne znam kolika je članarina.
Ivana: Mislim da je oko 30 eura mjesečno. Treninzi su tri puta tjedno.
Darja: To je u redu. Još tražim i pomoć u učenju, jer ima problema s gramatikom.
Ivana: U školi imaju dopunsku nastavu i ona je besplatna. Pitaj razrednika.
Darja: Super, nisam to znala! A ide li Lucija u cjelodnevni boravak?
Ivana: Ide. Tamo ručaju, pišu zadaću i igraju se do četiri.
Darja: Hvala ti na informacijama!''',
         ua='''Дар'я: Івано, на які позашкільні заняття ходить твоя донька?
Івана: Луція ходить у музичну школу і на гандбол. А Макс?
Дар'я: Хоче записатися в клуб водного поло, але я не знаю, який членський внесок.
Івана: Здається, близько 30 євро на місяць. Тренування тричі на тиждень.
Дар'я: Це нормально. А ще я шукаю допомогу з навчанням, бо в нього проблеми з граматикою.
Івана: У школі є додаткові заняття, і вони безкоштовні. Спитай класного керівника.
Дар'я: Чудово, я цього не знала! А Луція ходить на продовжений день?
Івана: Ходить. Там вони обідають, роблять домашнє завдання й граються до четвертої.
Дар'я: Дякую тобі за інформацію!''',
         questions=[
             ('У який клуб хоче записатися Макс?', ['Водного поло', 'Гандбольний', 'Футбольний'], 'Водного поло'),
             ('Скільки приблизно коштує членський внесок?', ['Близько 30 євро на місяць', '100 євро на місяць', 'Він безкоштовний'], 'Близько 30 євро на місяць'),
             ('Що Івана радить для допомоги з навчанням?', ['Безкоштовні додаткові заняття в школі', 'Приватного репетитора', 'Онлайн-курс'], 'Безкоштовні додаткові заняття в школі'),
         ],),
]

# ===================================================================== A2.3 Моє минуле: дитинство й спогади
TEXTS += [
    dict(key='m03_childhood', type='story', situation='small_talk', module=3,
         title=('Моє дитинство', 'Moje djetinjstvo'),
         hr='''Odrastala sam u malom gradu blizu Odese. U djetinjstvu sam ljeta provodila kod bake na selu. Cijele dane smo se igrali vani: skrivača, lovice i školica bile su naše omiljene igre. Bila sam nestašna djevojčica i stalno sam se penjala na drveće. Jednom sam pala i ogrebala koljeno, ali nisam plakala. Navečer nam je baka pričala priče za laku noć. Nismo imali mobitele, ali bili smo bezbrižni i sretni. Danas moja kći Daša odrasta u Zagrebu. Kad joj pričam o svom djetinjstvu, ona ne vjeruje da nismo imali internet.''',
         ua='''Я виросла в маленькому місті біля Одеси. У дитинстві я проводила літо в бабусі в селі. Цілими днями ми гралися надворі: хованки, квач і класики були нашими улюбленими іграми. Я була пустотливою дівчинкою і постійно лазила по деревах. Одного разу я впала й подряпала коліно, але не плакала. Увечері бабуся розповідала нам казки на ніч. У нас не було мобільних, але ми були безтурботні й щасливі. Сьогодні моя донька Даша росте в Загребі. Коли я розповідаю їй про своє дитинство, вона не вірить, що в нас не було інтернету.''',
         questions=[
             ('Де вона проводила літо в дитинстві?', ['У бабусі в селі', 'У таборі', 'У Загребі'], 'У бабусі в селі'),
             ('Що з нею сталося одного разу?', ['Впала й подряпала коліно', 'Загубилася в лісі', 'Захворіла'], 'Впала й подряпала коліно'),
             ('Де росте її донька?', ['У Загребі', 'В Одесі', 'У селі'], 'У Загребі'),
         ],),
    dict(key='m03_moving', type='story', situation='small_talk', module=3,
         title=('Переїзд, що змінив усе', 'Preseljenje koje je sve promijenilo'),
         hr='''Prije tri godine spakirala sam jedan kofer i napustila rodno mjesto. Bilo je teško ostaviti iza sebe kuću, prijatelje i posao. Prvi mjeseci u Hrvatskoj bili su puni neizvjesnosti. Nisam znala jezik i često sam se osjećala izgubljeno. Ponekad mi je bilo teško zbog samoće. Ali susjedi su mi bili velika podrška: susjeda Marija pomogla mi je naći stan, a njezin muž mi je pokazao grad. Polako sam se priviknula na novi život. Kad sam našla posao, osjetila sam veliko olakšanje. Danas mislim da je preseljenje bilo prekretnica u mom životu. Ponosna sam na sebe i na svoju hrabrost.''',
         ua='''Три роки тому я спакувала одну валізу й покинула рідне місто. Було важко залишити позаду дім, друзів і роботу. Перші місяці в Хорватії були сповнені невизначеності. Я не знала мови й часто почувалася розгубленою. Іноді мені було важко через самотність. Але сусіди дуже мене підтримали: сусідка Марія допомогла мені знайти квартиру, а її чоловік показав мені місто. Поступово я звикла до нового життя. Коли я знайшла роботу, то відчула велике полегшення. Сьогодні я думаю, що переїзд став поворотним моментом у моєму житті. Я пишаюся собою і своєю сміливістю.''',
         questions=[
             ('Що вона взяла з собою?', ['Одну валізу', 'Дві валізи', 'Нічого'], 'Одну валізу'),
             ('Хто допоміг їй знайти квартиру?', ['Сусідка Марія', 'Колега з роботи', 'Агенція'], 'Сусідка Марія'),
             ('Що вона відчула, коли знайшла роботу?', ['Велике полегшення', 'Страх', 'Сум'], 'Велике полегшення'),
         ],),
]

# ===================================================================== A2.4 Люди й стосунки
TEXTS += [
    dict(key='m04_wedding', type='story', situation='small_talk', module=4,
         title=('Весілля в Далмації', 'Svadba u Dalmaciji'),
         hr='''Prošlog mjeseca Darja je bila na svadbi svoje kolegice Ane u Šibeniku. Mladenka je imala dugu bijelu haljinu, a mladoženja tamnoplavo odijelo. Vjenčanje je bilo u staroj crkvi, a slavlje u restoranu uz more. Bilo je više od dvjesto svatova! Prema običaju, gosti su mladencima dali omotnicu s novcem. Kum je održao zdravicu, a svi su podigli čaše i viknuli: «Živjeli!» Mladenci su otvorili ples, a poslije su svi plesali do jutra. Darja je bila umorna, ali sretna. Kaže da je to bila najljepša svadba na kojoj je ikad bila.''',
         ua='''Минулого місяця Дар'я була на весіллі своєї колеги Ани в Шибенику. Наречена була в довгій білій сукні, а наречений – у темно-синьому костюмі. Вінчання було в старій церкві, а святкування – у ресторані біля моря. Гостей було понад двісті! За звичаєм гості подарували молодятам конверт із грошима. Кум виголосив тост, а всі підняли келихи й вигукнули: «Будьмо!» Молодята відкрили танці, а потім усі танцювали до ранку. Дар'я була втомлена, але щаслива. Каже, що це було найгарніше весілля, на якому вона будь-коли була.''',
         questions=[
             ('Де було весільне святкування?', ['У ресторані біля моря', 'У церкві', 'Удома'], 'У ресторані біля моря'),
             ('Що гості подарували молодятам?', ['Конверт із грошима', 'Квіти', 'Посуд'], 'Конверт із грошима'),
             ('Скільки було гостей?', ['Понад двісті', 'П’ятдесят', 'Сто'], 'Понад двісті'),
         ],),
    dict(key='m04_tenants', type='notice', situation='housing', module=4,
         title=('Збори мешканців', 'Sastanak stanara'),
         hr='''OBAVIJEST STANARIMA
Poštovani suvlasnici,
sastanak stanara bit će u četvrtak, 20. studenoga, u 19 sati, u prizemlju zgrade.
Na sastanku ćemo razgovarati o ovome:
– glasna glazba noću: molimo stanare da poslije 22 sata utišaju glazbu;
– auti u dvorištu: neki stanari parkiraju se ispred ulaza u zgradu;
– vlaga u stanu na drugom katu;
– zajednički prostor: tko ga i kada čisti.
Ako ne možete doći, svoje prijedloge ostavite na oglasnoj ploči ili ih pošaljite e-mailom.
Predstavnik suvlasnika
Ivan Perić''',
         ua='''ОГОЛОШЕННЯ ДЛЯ МЕШКАНЦІВ
Шановні співвласники!
збори мешканців відбудуться в четвер, 20 листопада, о 19 годині, на першому поверсі будинку.
На зборах ми поговоримо про таке:
– гучна музика вночі: просимо мешканців після 22 години робити музику тихіше;
– машини у дворі: деякі мешканці паркуються перед входом у будинок;
– вологість у квартирі на третьому поверсі;
– спільні приміщення: хто й коли їх прибирає.
Якщо не можете прийти, залиште свої пропозиції на дошці оголошень або надішліть їх електронною поштою.
Представник співвласників
Іван Перич''',
         questions=[
             ('Коли відбудуться збори?', ['У четвер о 19:00', 'У понеділок уранці', 'У суботу о 10:00'], 'У четвер о 19:00'),
             ('Про що просять мешканців після 22 години?', ['Робити музику тихіше', 'Не паркуватися у дворі', 'Прибирати під’їзд'], 'Робити музику тихіше'),
             ('Що робити, якщо ви не можете прийти?', ['Залишити пропозиції на дошці оголошень', 'Подзвонити в поліцію', 'Нічого'], 'Залишити пропозиції на дошці оголошень'),
         ],),
]

# ===================================================================== A2.5 Робота й кар'єра
TEXTS += [
    dict(key='m05_deadline', type='email', situation='work', module=5,
         title=('Прохання перенести термін', 'Pomak roka'),
         hr='''Predmet: Novi krajnji rok
Poštovana gospođo Horvat,
vezano uz novu internetsku stranicu Vaše tvrtke, ispričavam se zbog kašnjenja. Nažalost, kasnimo s rokom jer klijent još nije poslao sve fotografije. Molim Vas da pomaknemo krajnji rok s petka na sljedeću srijedu. Do tada ću sve završiti i poslati Vam kratak sažetak. U privitku je novi plan. Ako imate dodatna pitanja, stojim na raspolaganju. Unaprijed zahvaljujem.
S poštovanjem,
Darja Melnyk
voditeljica projekta''',
         ua='''Тема: Новий кінцевий термін
Шановна пані Горват!
Щодо нового вебсайту вашої фірми – перепрошую за затримку. На жаль, ми не встигаємо до терміну, бо клієнт ще не надіслав усіх фотографій. Прошу вас перенести кінцевий термін із п'ятниці на наступну середу. До того часу я все закінчу й надішлю вам короткий підсумок. У додатку – новий план. Якщо маєте додаткові запитання, я до ваших послуг. Заздалегідь дякую.
З повагою,
Дар'я Мельник
керівниця проєкту''',
         questions=[
             ('Чому проєкт затримується?', ['Клієнт не надіслав усіх фото', 'Дар’я хворіє', 'Зламався комп’ютер'], 'Клієнт не надіслав усіх фото'),
             ('На коли Дар’я просить перенести термін?', ['На наступну середу', 'На понеділок', 'На наступний місяць'], 'На наступну середу'),
             ('Що вона надсилає в додатку?', ['Новий план', 'Рахунок', 'Фотографії'], 'Новий план'),
         ],),
    dict(key='m05_obrt', type='article', situation='administration', module=5,
         title=('Як відкрити обрт?', 'Kako otvoriti obrt?'),
         hr='''Puno stranaca u Hrvatskoj želi raditi za sebe. Za samozapošljavanje najčešće se otvara obrt. Prvo trebate imati poslovni plan: što ćete raditi, koliki će biti prihod i koliki troškovi. Obrt se danas može otvoriti i online. Svaki obrt ima sjedište i djelatnost, a upisuje se u obrtni registar. Početnici često izaberu paušalni obrt jer je porez manji i nema puno papira. Važno je znati da obrtnik mora izdati račun za svaki posao i poštovati pravila fiskalizacije. Ako ste nezaposleni, Zavod za zapošljavanje može vam dati potporu za samozapošljavanje.''',
         ua='''Багато іноземців у Хорватії хочуть працювати на себе. Для самозайнятості найчастіше відкривають обрт (реєстрацію ремесла чи послуг). Спершу треба мати бізнес-план: що ви робитимете, який буде дохід і які витрати. Обрт сьогодні можна відкрити й онлайн. Кожен обрт має юридичну адресу й вид діяльності, і його вносять до реєстру обртів. Початківці часто обирають паушальний обрт, бо податок менший і паперів небагато. Важливо знати, що власник обрту мусить видавати рахунок за кожну роботу й дотримуватися правил фіскалізації. Якщо ви безробітні, Служба зайнятості може дати вам підтримку на самозайнятість.''',
         questions=[
             ('Що треба мати спочатку?', ['Бізнес-план', 'Квартиру', 'Машину'], 'Бізнес-план'),
             ('Чому початківці часто обирають паушальний обрт?', ['Менший податок і небагато паперів', 'Податків немає зовсім', 'Можна не видавати рахунків'], 'Менший податок і небагато паперів'),
             ('Хто може отримати підтримку на самозайнятість?', ['Безробітні', 'Студенти', 'Пенсіонери'], 'Безробітні'),
         ],),
]

# ===================================================================== A2.6 Установи, послуги й гроші
TEXTS += [
    dict(key='m06_hairdresser', type='dialogue', situation=None, module=6,
         title=('У перукарні', 'U frizerskom salonu'),
         hr='''Frizerka: Dobar dan! Jeste li naručeni?
Darja: Jesam, u deset sati. Darja Kovalenko.
Frizerka: Da, tu ste. Što želite danas?
Darja: Htjela bih se ošišati. Samo malo skratite, oko tri centimetra. I šiške, molim.
Frizerka: Može. Želite li i bojanje kose ili pramenove?
Darja: Ne, hvala, danas samo šišanje i feniranje. Koliko će to koštati?
Frizerka: Šišanje i feniranje su trideset pet eura.
Darja: U redu. Mogu li platiti karticom?
Frizerka: Naravno. Sjednite ovdje, molim.''',
         ua='''Перукарка: Добрий день! Ви записані?
Дар'я: Так, на десяту. Дар'я Коваленко.
Перукарка: Так, ось ви. Чого бажаєте сьогодні?
Дар'я: Я хотіла б підстригтися. Тільки трохи вкоротіть, приблизно на три сантиметри. І чубчик, будь ласка.
Перукарка: Можна. Бажаєте ще фарбування волосся чи пасма?
Дар'я: Ні, дякую, сьогодні тільки стрижка й укладання феном. Скільки це коштуватиме?
Перукарка: Стрижка й укладання – тридцять п'ять євро.
Дар'я: Гаразд. Можна заплатити карткою?
Перукарка: Звісно. Сідайте сюди, будь ласка.''',
         questions=[
             ('Що Дар’я хоче сьогодні?', ['Підстригтися й укласти волосся', 'Пофарбувати волосся', 'Зробити манікюр'], 'Підстригтися й укласти волосся'),
             ('Наскільки вкоротити волосся?', ['Приблизно на три сантиметри', 'На десять сантиметрів', 'Зовсім коротко'], 'Приблизно на три сантиметри'),
             ('Скільки коштує послуга?', ['35 євро', '20 євро', '50 євро'], '35 євро'),
         ],),
    dict(key='m06_notary', type='instruction', situation='administration', module=6,
         title=('Як завірити підпис у нотаріуса?', 'Kako ovjeriti potpis kod javnog bilježnika?'),
         hr='''Ponekad trebate ovjeriti potpis, na primjer na punomoći, izjavi ili suglasnosti za putovanje djeteta. To se radi u javnobilježničkom uredu.
1. Ponesite važeći osobni dokument: osobnu iskaznicu, putovnicu ili iskaznicu stranca.
2. Dokument ne potpisujte kod kuće. Potpisat ćete ga vlastoručno pred bilježnikom.
3. Ako je dokument na stranom jeziku, možda će trebati i ovjera prijevoda.
4. Bilježnik će provjeriti Vaš dokument i staviti pečat.
5. Platite javnobilježničku pristojbu. Cijena je različita za različite dokumente.
Savjet: nazovite ured unaprijed i pitajte trebate li se naručiti.''',
         ua='''Іноді вам треба завірити підпис, наприклад на довіреності, заяві чи згоді на подорож дитини. Це роблять у нотаріальній конторі.
1. Візьміть із собою дійсний документ, що посвідчує особу: посвідчення особи, паспорт або посвідку іноземця.
2. Не підписуйте документ удома. Ви підпишете його власноруч перед нотаріусом.
3. Якщо документ іноземною мовою, може знадобитися ще й завірення перекладу.
4. Нотаріус перевірить ваш документ і поставить печатку.
5. Сплатіть нотаріальний збір. Ціна різна для різних документів.
Порада: зателефонуйте в контору заздалегідь і запитайте, чи треба записуватися.''',
         questions=[
             ('Що треба взяти з собою?', ['Дійсний документ, що посвідчує особу', 'Фотографію', 'Рахунок за світло'], 'Дійсний документ, що посвідчує особу'),
             ('Де треба підписати документ?', ['Перед нотаріусом', 'Удома', 'На пошті'], 'Перед нотаріусом'),
             ('Що радять зробити заздалегідь?', ['Зателефонувати в контору', 'Заплатити онлайн', 'Перекласти паспорт'], 'Зателефонувати в контору'),
         ],),
]

# ===================================================================== A2.7 Здоров'я: система й самопочуття
TEXTS += [
    dict(key='m07_sickchild', type='chat', situation='health', module=7,
         title=('Дитина захворіла', 'Dijete je bolesno'),
         hr='''Darja: Dobro jutro, gospodine Novak. Moj sin Maks ima crijevnu virozu. Povraćao je cijelu noć i ima temperaturu. Danas ne mogu doći na posao.
Šef: Dobro jutro, Darja. Žao mi je! Naravno, ostanite s njim.
Darja: Hvala. Pedijatrica kaže da ne smije ići u vrtić najmanje tri dana jer je viroza zarazna. Otvorit ću bolovanje radi njege djeteta.
Šef: U redu. Javite mi kad saznate koliko ćete biti odsutni.
Darja: Hoću. Danas ću od kuće odgovoriti na najvažnije e-mailove.
Šef: Nema potrebe, odmorite se. Neka Maks brzo ozdravi!
Darja: Hvala Vam puno!''',
         ua='''Дар'я: Доброго ранку, пане Новак. У мого сина Макса кишкова інфекція. Його всю ніч нудило, і в нього температура. Сьогодні я не можу прийти на роботу.
Шеф: Доброго ранку, Дар'є. Мені шкода! Звісно, залишайтеся з ним.
Дар'я: Дякую. Педіатриня каже, що йому не можна ходити в садок щонайменше три дні, бо інфекція заразна. Я відкрию лікарняний по догляду за дитиною.
Шеф: Гаразд. Повідомте мені, коли дізнаєтеся, скільки вас не буде.
Дар'я: Добре. Сьогодні я з дому відповім на найважливіші листи.
Шеф: Не треба, відпочиньте. Нехай Макс швидко одужує!
Дар'я: Щиро дякую вам!''',
         questions=[
             ('Що з Максом?', ['Кишкова інфекція й температура', 'Він зламав руку', 'Звичайна застуда'], 'Кишкова інфекція й температура'),
             ('Скільки днів він не може ходити в садок?', ['Щонайменше три дні', 'Один день', 'Тиждень'], 'Щонайменше три дні'),
             ('Що шеф каже про роботу з дому?', ['Що не треба, краще відпочити', 'Що це обов’язково', 'Нічого не каже'], 'Що не треба, краще відпочити'),
         ],),
    dict(key='m07_stress', type='article', situation='health', module=7,
         title=('Коли роботи забагато', 'Kad je posla previše'),
         hr='''Sve više ljudi živi pod stresom. Takvi ljudi loše spavaju, bude se noću i ujutro su premoreni. Teško im je usredotočiti se na posao, a postaju i napeti i razdražljivi. Ako to traje mjesecima, može doći do izgaranja na poslu. Kako to promijeniti? Liječnici savjetuju da navečer isključite mobitel i ne čitate poslovne e-mailove. Važna je ravnoteža posla i života: šetnja, sport i boravak u prirodi pomažu nam da napunimo baterije. Ako vam je još uvijek teško, nemojte se sramiti zatražiti pomoć. Razgovor s psihoterapeutom ili u savjetovalištu može puno pomoći.''',
         ua='''Дедалі більше людей живуть у стресі. Такі люди погано сплять, прокидаються вночі, а вранці вони перевтомлені. Їм важко зосередитися на роботі, і вони стають напруженими й дратівливими. Якщо це триває місяцями, може статися професійне вигорання. Як це змінити? Лікарі радять увечері вимикати мобільний і не читати робочих листів. Важливий баланс роботи й життя: прогулянка, спорт і час на природі допомагають нам зарядити батарейки. Якщо вам усе ще важко, не соромтеся попросити допомоги. Розмова з психотерапевтом або в консультаційному центрі може дуже допомогти.''',
         questions=[
             ('Що відбувається з людьми в стресі?', ['Погано сплять і стають дратівливими', 'Більше їдять', 'Нічого'], 'Погано сплять і стають дратівливими'),
             ('Що радять робити ввечері?', ['Вимикати мобільний', 'Читати робочу пошту', 'Пити каву'], 'Вимикати мобільний'),
             ('До кого можна звернутися по допомогу?', ['До психотерапевта або в консультаційний центр', 'До перукаря', 'До сусіда'], 'До психотерапевта або в консультаційний центр'),
         ],),
]

# ===================================================================== A2.8 Авто в Хорватії
TEXTS += [
    dict(key='m08_licence', type='instruction', situation='administration', module=8,
         title=('Обмін іноземного посвідчення водія', 'Zamjena strane vozačke dozvole'),
         hr='''Ako živite u Hrvatskoj, stranu vozačku dozvolu ćete možda morati zamijeniti hrvatskom. Zahtjev se predaje u policijskoj upravi prema mjestu boravka.
Što trebate:
– stranu vozačku dozvolu i njezin prijevod,
– liječničko uvjerenje iz medicine rada,
– fotografiju za dokumente,
– iskaznicu stranca ili putovnicu,
– dokaz o plaćenoj pristojbi.
Kad predate zahtjev, dobit ćete privremenu potvrdu s kojom smijete voziti. Novu dozvolu možete podići za nekoliko tjedana. Pazite na istek valjanosti strane dozvole. Za neke zemlje vrijede posebna pravila, pa se na vrijeme raspitajte u policijskoj upravi.''',
         ua='''Якщо ви живете в Хорватії, іноземне посвідчення водія, можливо, доведеться обміняти на хорватське. Заяву подають у поліцейському управлінні за місцем проживання.
Що потрібно:
– іноземне посвідчення водія та його переклад,
– медична довідка з медицини праці,
– фотографія на документи,
– посвідка іноземця або паспорт,
– підтвердження сплати збору.
Коли ви подасте заяву, отримаєте тимчасову довідку, з якою можна керувати автомобілем. Нове посвідчення можна забрати за кілька тижнів. Стежте за закінченням терміну дії іноземного посвідчення. Для деяких країн діють особливі правила, тож завчасно розпитайте в поліцейському управлінні.''',
         questions=[
             ('Де подають заяву?', ['У поліцейському управлінні', 'В автошколі', 'На пошті'], 'У поліцейському управлінні'),
             ('Що ви отримаєте, коли подасте заяву?', ['Тимчасову довідку', 'Новий паспорт', 'Штраф'], 'Тимчасову довідку'),
             ('Яка довідка потрібна від лікаря?', ['Довідка з медицини праці', 'Виписка з лікарні', 'Рецепт'], 'Довідка з медицини праці'),
         ],),
    dict(key='m08_accident', type='story', situation='transport', module=8,
         title=('Аварія на парковці', 'Nezgoda na parkiralištu'),
         hr='''Prošli tjedan Darja je imala malu prometnu nezgodu. Izlazila je s parkirališta ispred trgovine, a jedan auto ju je udario straga. Nitko nije bio ozlijeđen, ali branik na Darjinom autu bio je udubljen. Vozač drugog auta, stariji gospodin, odmah je izašao iz vozila i ispričao se. Nisu morali pozvati policiju jer je bila samo materijalna šteta. Na licu mjesta zajedno su ispunili europsko izvješće, a Darja je fotografirala štetu. Jedna žena koja je sve vidjela napisala je izjavu svjedoka. Gospodin je priznao da je on krivac. Popravak je platilo osiguranje drugog vozača.''',
         ua='''Минулого тижня Дар'я потрапила в невелику дорожню пригоду. Вона виїжджала з парковки перед магазином, і одна машина вдарила її ззаду. Ніхто не постраждав, але бампер на машині Дар'ї був прим'ятий. Водій другої машини, літній пан, одразу вийшов з авто й вибачився. Їм не довелося викликати поліцію, бо була лише матеріальна шкода. На місці вони разом заповнили європротокол, а Дар'я сфотографувала пошкодження. Одна жінка, яка все бачила, написала свідчення. Пан визнав, що винен він. Ремонт оплатила страхова компанія другого водія.''',
         questions=[
             ('Що пошкоджено в машині Дар’ї?', ['Бампер', 'Двері', 'Фара'], 'Бампер'),
             ('Чому не викликали поліцію?', ['Була лише матеріальна шкода', 'Поліція не відповідала', 'Водій утік'], 'Була лише матеріальна шкода'),
             ('Хто заплатив за ремонт?', ['Страхова компанія іншого водія', 'Дар’я', 'Магазин'], 'Страхова компанія іншого водія'),
         ],),
    dict(key='m08_fine', type='chat', situation='transport', module=8,
         title=('Штраф за паркування', 'Kazna za parkiranje'),
         hr='''Maks: Darja, upomoć! Na autu mi je papir od prometnog redara. Što to znači?
Darja: Daj da vidim. Pa to je kazna za nepropisno parkiranje. Parkirao si na mjestu za invalide!
Maks: Joj, nisam vidio znak. Je li kazna velika?
Darja: Nije mala. Ali ako platiš u roku od osam dana, plaćaš upola manje.
Maks: Dobro je to znati. A gdje sam smio parkirati?
Darja: U parkirnoj zoni, ali onda trebaš kupiti parkirnu kartu na automatu ili platiti parking SMS-om.
Maks: Hvala ti. Ubuduće ću paziti, ne želim da mi odvezu auto!''',
         ua='''Макс: Дар'є, рятуй! На моїй машині папірець від інспектора з паркування. Що це означає?
Дар'я: Дай гляну. Та це штраф за неправильне паркування. Ти припаркувався на місці для людей з інвалідністю!
Макс: Ой, я не бачив знака. Штраф великий?
Дар'я: Немаленький. Але якщо заплатиш протягом восьми днів, платиш удвічі менше.
Макс: Добре знати. А де мені можна було паркуватися?
Дар'я: У зоні паркування, але тоді треба купити паркувальний квиток в автоматі або заплатити за паркування через SMS.
Макс: Дякую тобі. Надалі буду уважнішим, не хочу, щоб мені евакуювали машину!''',
         questions=[
             ('Чому Макс отримав штраф?', ['Припаркувався на місці для людей з інвалідністю', 'Перевищив швидкість', 'Проїхав на червоне'], 'Припаркувався на місці для людей з інвалідністю'),
             ('Що буде, якщо заплатити протягом восьми днів?', ['Платиш удвічі менше', 'Штраф скасують', 'Нічого'], 'Платиш удвічі менше'),
             ('Як заплатити за паркування в зоні?', ['Квитком з автомата або повідомленням із телефона', 'Тільки в банку', 'Платити не треба'], 'Квитком з автомата або повідомленням із телефона'),
         ],),
    dict(key='m08_usedcar', type='dialogue', situation='transport', module=8,
         title=('Купую вживане авто', 'Kupujem rabljeni auto'),
         hr='''Darja: Dobar dan, zovem zbog oglasa za auto. Je li još na prodaju?
Prodavač: Je. Golf iz 2015. godine, prvi vlasnik.
Darja: Koliko ima prijeđenih kilometara?
Prodavač: Sto četrdeset tisuća. Imam i servisnu knjižicu.
Darja: Je li auto udaren? Ima li hrđe?
Prodavač: Nije udaren, samo ima malu ogrebotinu na braniku. Registriran je do svibnja.
Darja: Kolika je potrošnja goriva?
Prodavač: Oko šest litara na sto kilometara.
Darja: Mogu li doći na probnu vožnju? Htjela bih ga i dovesti na pregled kod svog mehaničara.
Prodavač: Naravno. Cijena je osam tisuća eura, ali možemo se malo pogađati.''',
         ua='''Дар'я: Добрий день, я телефоную щодо оголошення про авто. Воно ще продається?
Продавець: Так. «Гольф» 2015 року, перший власник.
Дар'я: Який у нього пробіг?
Продавець: Сто сорок тисяч. У мене є й сервісна книжка.
Дар'я: Авто було в аварії? Є іржа?
Продавець: В аварії не було, лише невелика подряпина на бампері. Зареєстроване до травня.
Дар'я: Яка витрата пального?
Продавець: Близько шести літрів на сто кілометрів.
Дар'я: Можна приїхати на тест-драйв? Я ще хотіла б відвезти його на огляд до свого механіка.
Продавець: Звісно. Ціна – вісім тисяч євро, але можемо трохи поторгуватися.''',
         questions=[
             ('Який пробіг має авто?', ['140 000 кілометрів', '14 000 кілометрів', '40 000 кілометрів'], '140 000 кілометрів'),
             ('Що не так з авто?', ['Невелика подряпина на бампері', 'Багато іржі', 'Зламаний двигун'], 'Невелика подряпина на бампері'),
             ('Куди Дар’я хоче відвезти авто?', ['На огляд до свого механіка', 'На мийку', 'На кордон'], 'На огляд до свого механіка'),
         ],),
]

# ===================================================================== A2.9 Неприємності в місті й довкілля
TEXTS += [
    dict(key='m09_waste', type='notice', situation='housing', module=9,
         title=('Як сортувати сміття', 'Odvajanje otpada u našem gradu'),
         hr='''ODVAJANJE OTPADA U NAŠEM GRADU
Od 1. siječnja svako kućanstvo mora odvajati otpad. Koristite ove spremnike:
– žuta vreća: plastika, metal i tetrapak (boce, limenke, ambalaža od mlijeka);
– plava kanta: papir i karton;
– smeđa kanta: biootpad i ostaci hrane;
– zeleni spremnik: staklo;
– crna kanta: miješani komunalni otpad.
Ambalažu prije bacanja ispraznite i zgnječite. Istrošene baterije, elektronički otpad i glomazni otpad odnesite u reciklažno dvorište. Raspored odvoza nalazi se u aplikaciji grada. Za neodvajanje otpada plaća se kazna.''',
         ua='''СОРТУВАННЯ ВІДХОДІВ У НАШОМУ МІСТІ
З 1 січня кожне домогосподарство мусить сортувати відходи. Користуйтеся такими контейнерами:
– жовтий мішок: пластик, метал і тетрапак (пляшки, бляшанки, упаковки від молока);
– синій контейнер: папір і картон;
– коричневий контейнер: біовідходи й рештки їжі;
– зелений контейнер: скло;
– чорний контейнер: змішані побутові відходи.
Упаковку перед тим, як викинути, спорожніть і зімніть. Використані батарейки, електронні та великогабаритні відходи віднесіть на пункт приймання відходів. Розклад вивезення є в застосунку міста. За несортування відходів сплачують штраф.''',
         questions=[
             ('Куди класти пластик і бляшанки?', ['У жовтий мішок', 'У коричневий контейнер', 'У чорний контейнер'], 'У жовтий мішок'),
             ('Куди віднести використані батарейки?', ['На пункт приймання відходів', 'У зелений контейнер', 'У магазин'], 'На пункт приймання відходів'),
             ('Де розклад вивезення сміття?', ['У застосунку міста', 'На пошті', 'У газеті'], 'У застосунку міста'),
         ],),
    dict(key='m09_storm', type='news', situation=None, module=9,
         title=('Помаранчеве попередження', 'Narančasto upozorenje za Dalmaciju'),
         hr='''Za Dalmaciju je izdano narančasto upozorenje zbog olujnog vjetra. Sutra dolazi bura, a na moru će biti valovi do četiri metra. Možda će biti prekid plovidbe i problema na autocesti. Ljudi trebaju izbjegavati boravak vani i skloniti se na sigurno mjesto. Zatvorite prozore i ne ostavljajte stvari na balkonu. Zbog suhog vremena opasnost od šumskih požara je velika, pa vrijedi zabrana loženja vatre. Ako ste u opasnosti, nazovite hitne službe na broj 112.''',
         ua='''Для Далмації оголошено помаранчеве попередження через штормовий вітер. Завтра прийде бура, а на морі будуть хвилі до чотирьох метрів. Можливі припинення руху суден і проблеми на автомагістралі. Людям слід уникати перебування надворі й сховатися в безпечному місці. Зачиніть вікна й не залишайте речей на балконі. Через суху погоду небезпека лісових пожеж велика, тож діє заборона розпалювати вогонь. Якщо ви в небезпеці, телефонуйте до екстрених служб за номером 112.''',
         questions=[
             ('Чому оголошено помаранчеве попередження?', ['Через штормовий вітер', 'Через спеку', 'Через сніг'], 'Через штормовий вітер'),
             ('Що радять людям?', ['Уникати перебування надворі', 'Їхати на море', 'Відчинити вікна'], 'Уникати перебування надворі'),
             ('На який номер телефонувати в разі небезпеки?', ['112', '192', '194'], '112'),
         ],),
]

# ===================================================================== A2.10 Медіа, культура й думки
TEXTS += [
    dict(key='m10_review', type='article', situation=None, module=10,
         title=('Фільм тижня', 'Film tjedna: «Ljeto na otoku»'),
         hr='''Novi film Ane Kovač govori o obitelji koja jedno ljeto živi na malom otoku. Glavni lik je djevojčica Lea, a njezinu baku glumi poznata glumica. Na početku je sve mirno, ali u međuvremenu ima sve više napetosti, a kraj je iznenađujući. Kraj vam neću reći! Atmosfera je jako lijepa i dirljiva. Jedina mana: film je malo predug. Moj dojam: bolji nego što sam očekivao. Vrijedi pogledati, a ako volite more, film je za vas. Toplo preporučujem!''',
         ua='''Новий фільм Ани Ковач розповідає про родину, яка одне літо живе на маленькому острові. Головна героїня – дівчинка Леа, а її бабусю грає відома акторка. Спочатку все спокійно, але тим часом напруги дедалі більше, а кінець несподіваний. Кінця я вам не скажу! Атмосфера дуже гарна й зворушлива. Єдиний недолік: фільм трохи задовгий. Моє враження: кращий, ніж я очікував. Варто подивитися, а якщо ви любите море, цей фільм для вас. Щиро раджу!''',
         questions=[
             ('Про що фільм?', ['Про родину, що одне літо живе на острові', 'Про поліцейського', 'Про футбол'], 'Про родину, що одне літо живе на острові'),
             ('Який недолік фільму називає автор?', ['Він трохи задовгий', 'Поганий кінець', 'Погана гра акторів'], 'Він трохи задовгий'),
             ('Чи радить автор фільм?', ['Так, щиро радить', 'Ні, не радить', 'Не знає'], 'Так, щиро радить'),
         ],),
    dict(key='m10_ads', type='ad', situation='shopping', module=10,
         title=('Малі оголошення', 'Mali oglasi'),
         hr='''Prodajem dječji bicikl, malo korišten, kao nov. Cijena 60 eura, po dogovoru. Zvati poslije 17 sati.
Poklanjam mačiće u dobre ruke. Imaju dva mjeseca, zdravi su i veseli. Kontakt: Daša.
Hitno prodajem kauč i stol za četiri osobe zbog preseljenja. Ozbiljni kupci, javite se porukom.
Tražim ženu za čuvanje djeteta dva puta tjedno, popodne, u centru Rijeke. Iskustvo je poželjno.
Nudim instrukcije iz matematike za učenike osnovne škole. Prvi sat je besplatan!''',
         ua='''Продаю дитячий велосипед, мало користувалися, як новий. Ціна 60 євро, можна домовитися. Дзвонити після 17 години.
Віддаю кошенят у добрі руки. Їм два місяці, вони здорові й веселі. Контакт: Даша.
Терміново продаю диван і стіл на чотирьох через переїзд. Серйозні покупці, пишіть повідомлення.
Шукаю жінку доглядати дитину двічі на тиждень, по обіді, у центрі Рієки. Досвід бажаний.
Пропоную репетиторство з математики для учнів початкової школи. Перше заняття безкоштовне!''',
         questions=[
             ('Скільки коштує дитячий велосипед?', ['60 євро', '16 євро', '600 євро'], '60 євро'),
             ('Чому продають диван і стіл?', ['Через переїзд', 'Бо вони старі', 'Бо купили нові'], 'Через переїзд'),
             ('Що безкоштовно в оголошенні про репетиторство?', ['Перше заняття', 'Підручник', 'Усі заняття'], 'Перше заняття'),
         ],),
]

# ===================================================================== A2.11 Хорватія: краї, звичаї, культура
TEXTS += [
    dict(key='m11_istria', type='story', situation='travel', module=11,
         title=('Вихідні в Істрії', 'Vikend u Istri'),
         hr='''Darja i njezin muž proveli su produženi vikend u Istri. Smjestili su se u staroj kamenoj kući u malom brdskom gradiću Motovunu. S terase su gledali dolinu rijeke Mirne i šume u kojima rastu tartufi. Prvi dan posjetili su Pulu i amfiteatar, a navečer su u Rovinju šetali uskim uličicama. Drugi dan išli su vinskom cestom. Na jednom agroturizmu probali su domaće fuže s tartufima i maneštru, a uz večeru pili su malvaziju i teran. Domaćin im je objasnio da su mnogi Istrani dvojezični: govore hrvatski i talijanski. Darja kaže da se sigurno vraćaju na jesen.''',
         ua='''Дар'я та її чоловік провели подовжені вихідні в Істрії. Вони зупинилися в старому кам'яному будинку в маленькому гірському містечку Мотовун. З тераси вони дивилися на долину річки Мірни й ліси, у яких ростуть трюфелі. Першого дня вони відвідали Пулу й амфітеатр, а ввечері гуляли вузькими вуличками Ровиня. Другого дня вони їздили винною дорогою. На одному агротуристичному господарстві вони скуштували домашні фужі з трюфелями й манештру, а до вечері пили мальвазію й теран. Господар пояснив їм, що багато істрійців двомовні: говорять хорватською та італійською. Дар'я каже, що вони неодмінно повернуться восени.''',
         questions=[
             ('Де вони жили?', ['У старому кам’яному будинку в Мотовуні', 'У готелі в Пулі', 'У наметі'], 'У старому кам’яному будинку в Мотовуні'),
             ('Що вони куштували в агротуристичному господарстві?', ['Фужі з трюфелями й манештру', 'Піцу', 'Рибний суп'], 'Фужі з трюфелями й манештру'),
             ('Якими мовами говорять багато істрійців?', ['Хорватською та італійською', 'Тільки хорватською', 'Німецькою'], 'Хорватською та італійською'),
         ],),
    dict(key='m11_slavonia', type='article', situation=None, module=11,
         title=('Славонія – край пшеничних полів', 'Slavonija – zemlja žitnih polja'),
         hr='''Slavonija je ravničarski kraj na istoku Hrvatske, između rijeka Save, Drave i Dunava. Ljeti su posvuda žitna polja, kukuruz i suncokret. Slavonci su poznati kao vrlo gostoljubivi ljudi: gost uvijek mora nešto pojesti i popiti. Poznata jela su domaća kobasica, kulen i fiš paprikaš, koji se kuha u kotliću na vatri. Zimi se u mnogim obiteljima još održava svinjokolja, a jesen je vrijeme berbe grožđa. Slavonija je poznata i po tamburašima: bez tamburice nema slavlja. Najveći grad je Osijek, a vrijedi posjetiti i Vukovar i Đakovo, gdje se uzgajaju konji lipicanci.''',
         ua='''Славонія – рівнинний край на сході Хорватії, між річками Сава, Драва й Дунай. Улітку всюди пшеничні поля, кукурудза й соняшник. Славонці відомі як дуже гостинні люди: гість завжди мусить щось з'їсти й випити. Відомі страви – домашня ковбаса, кулен і фіш-паприкаш, який варять у казанку на вогні. Узимку в багатьох родинах ще влаштовують забій свиней, а осінь – час збору винограду. Славонія відома й своїми тамбурашами: без тамбурици немає свята. Найбільше місто – Осієк, а ще варто відвідати Вуковар і Джаково, де розводять коней-ліпіцанців.''',
         questions=[
             ('Де розташована Славонія?', ['На сході Хорватії', 'На півдні Хорватії', 'На островах'], 'На сході Хорватії'),
             ('У чому готують фіш-паприкаш?', ['У казанку на вогні', 'У духовці', 'У мікрохвильовці'], 'У казанку на вогні'),
             ('Що розводять у Джакові?', ['Коней-ліпіцанців', 'Овець', 'Рибу'], 'Коней-ліпіцанців'),
         ],),
    dict(key='m11_manners', type='article', situation='small_talk', module=11,
         title=('Як поводитися в гостях?', 'Kako se ponašati u gostima?'),
         hr='''Kad vas Hrvati pozovu na obiteljski ručak, to je velika stvar. Evo nekoliko savjeta za lijepo ponašanje. Ne dolazite praznih ruku: poklon za domaćina može biti vino, kolač ili cvijeće. Kad uđete u kuću, pitajte trebate li izuti cipele. Puno obitelji ima papuče za goste. Prijatelje pozdravljamo poljupcem u obraz, obično dva puta. Starije ljude persiramo dok nam ne ponude da ih tikamo. Za stolom je pristojno probati sva jela. Ako vam domaćica ponudi još, nije nepristojno reći: «Hvala, sit sam.» Poslije ručka obično pijemo dugu kavu i razgovaramo satima.''',
         ua='''Коли хорвати запрошують вас на сімейний обід, це важлива подія. Ось кілька порад щодо гарної поведінки. Не приходьте з порожніми руками: подарунком для господаря може бути вино, тістечко чи квіти. Коли зайдете в дім, запитайте, чи треба роззутися. Багато родин мають капці для гостей. Друзів вітають поцілунком у щоку, зазвичай двічі. До старших людей звертаються на «Ви», доки вони не запропонують перейти на «ти». За столом чемно скуштувати всі страви. Якщо господиня пропонує вам ще, не буде нечемно сказати: «Дякую, я наївся.» Після обіду зазвичай довго п'ють каву й розмовляють годинами.''',
         questions=[
             ('Що можна принести господарям?', ['Вино, тістечко або квіти', 'Гроші', 'Нічого'], 'Вино, тістечко або квіти'),
             ('Як вітаються з друзями?', ['Поцілунком у щоку', 'Поклоном', 'Лише словами'], 'Поцілунком у щоку'),
             ('Як звертаються до старших людей?', ['На «Ви», доки вони не запропонують «ти»', 'Одразу на «ти»', 'Лише на ім’я'], 'На «Ви», доки вони не запропонують «ти»'),
         ],),
    dict(key='m11_advent', type='news', situation=None, module=11,
         title=('Адвент у Загребі', 'Advent u Zagrebu'),
         hr='''Zagreb je i ove godine pun posjetitelja. Božićni sajam u Donjem i Gornjem gradu otvoren je do 6. siječnja. Na sajmu se prodaju licitarska srca i drugi ručni radovi. Posjetitelji piju kuhano vino i jedu fritule i kobasice. Uspinjača vozi do kasno navečer, a na trgovima su koncerti. Puno turista dolazi i zbog tradicionalne hrane, kao što su purica s mlincima ili sir i vrhnje s tržnice Dolac. Najbolje je u centar doći javnim prijevozom, jer se u centru teško parkirati.''',
         ua='''Загреб і цього року повний відвідувачів. Різдвяний ярмарок у Нижньому та Верхньому місті працює до 6 січня. На ярмарку продають ліцитарські серця й інші вироби ручної роботи. Відвідувачі п'ють глінтвейн і їдять фрітули та ковбаски. Фунікулер ходить до пізнього вечора, а на площах – концерти. Багато туристів приїжджають і заради традиційної їжі, як-от індичка з млинцями чи сир зі сметаною з ринку Долац. До центру найкраще добиратися громадським транспортом, бо паркуватися в центрі важко.''',
         questions=[
             ('Що продають на ярмарку?', ['Ліцитарські серця й інші ручні вироби', 'Машини', 'Квитки на поїзд'], 'Ліцитарські серця й інші ручні вироби'),
             ('Що п’ють відвідувачі?', ['Глінтвейн', 'Сік', 'Чай'], 'Глінтвейн'),
             ('Як найкраще добиратися до центру?', ['Громадським транспортом', 'Машиною', 'Таксі'], 'Громадським транспортом'),
         ],),
]

# ===================================================================== A2.12 Українці в Хорватії
TEXTS += [
    dict(key='m12_protection', type='instruction', situation='administration', module=12,
         title=('Тимчасовий захист: що варто знати', 'Status privremene zaštite: što treba znati'),
         hr='''Osobe sa statusom privremene zaštite imaju iskaznicu stranca s rokom važenja. Prije isteka valjanosti iskaznice provjerite treba li iskaznicu produljiti. Informacije su na stranicama MUP-a. Za novu iskaznicu obično trebate:
– ukrajinsku putovnicu ili drugi dokument,
– biometrijsku fotografiju,
– staru iskaznicu stranca.
U policijskoj upravi uzet će vam i otisak prsta. Ako ste promijenili adresu, prijavite adresu i obavijestite odjel za strance. Termin se često može naručiti online. Za maloljetno dijete zahtjev predaje roditelj. S tim statusom imate i pravo na rad bez dozvole za rad.''',
         ua='''Особи зі статусом тимчасового захисту мають посвідку іноземця з терміном дії. Перед закінченням терміну дії посвідки перевірте, чи треба посвідку продовжити. Інформація є на сторінках МВС (MUP). Для нової посвідки зазвичай потрібні:
– український паспорт або інший документ,
– біометрична фотографія,
– стара посвідка іноземця.
У поліцейському управлінні у вас також візьмуть відбитки пальців. Якщо ви змінили адресу, зареєструйте адресу й повідомте відділ у справах іноземців. Часто можна записатися онлайн. За неповнолітню дитину заяву подає батько чи мати. З цим статусом ви маєте й право на роботу без дозволу на роботу.''',
         questions=[
             ('Що мають особи з тимчасовим захистом?', ['Посвідку іноземця з терміном дії', 'Хорватський паспорт', 'Нічого'], 'Посвідку іноземця з терміном дії'),
             ('Що треба зробити, якщо ви змінили адресу?', ['Зареєструвати адресу й повідомити відділ у справах іноземців', 'Нічого', 'Купити нову посвідку'], 'Зареєструвати адресу й повідомити відділ у справах іноземців'),
             ('Яке право дає статус?', ['Право на роботу без дозволу на роботу', 'Право голосувати', 'Безкоштовне житло назавжди'], 'Право на роботу без дозволу на роботу'),
         ],),
    dict(key='m12_community', type='notice', situation='small_talk', module=12,
         title=('День Незалежності України в Загребі', 'Dan neovisnosti Ukrajine u Zagrebu'),
         hr='''Ukrajinska zajednica u Zagrebu poziva sve Ukrajince i njihove prijatelje na obilježavanje Dana neovisnosti Ukrajine 24. kolovoza. Okupljanje je u 11 sati ispred kulturnog društva, a zatim idemo zajedno u grkokatoličku crkvu. Poslije podne djeca iz subotnje škole imaju nastup s pjesmama i plesovima. Za goste će biti ukrajinska i hrvatska hrana. Udruga traži i nove volontere: ako znate hrvatski, možete pomoći kao prevoditelj volonter novopridošlim obiteljima. Dođite, upoznajte nove ljude i osjećajte se kao kod kuće! Ulaz je slobodan.''',
         ua='''Українська громада в Загребі запрошує всіх українців та їхніх друзів відзначити День Незалежності України 24 серпня. Збір об 11 годині перед культурним товариством, а потім ідемо разом до греко-католицької церкви. По обіді діти з суботньої школи виступлять із піснями й танцями. Для гостей буде українська й хорватська їжа. Об'єднання також шукає нових волонтерів: якщо ви знаєте хорватську, можете допомагати як перекладач-волонтер новоприбулим родинам. Приходьте, знайомтеся з новими людьми й почувайтеся як удома! Вхід вільний.''',
         questions=[
             ('Коли свято?', ['24 серпня', '1 січня', '9 травня'], '24 серпня'),
             ('Хто виступатиме по обіді?', ['Діти із суботньої школи', 'Відомий співак', 'Клапа'], 'Діти із суботньої школи'),
             ('Кого шукає об’єднання?', ['Нових волонтерів', 'Нових учителів', 'Кухарів'], 'Нових волонтерів'),
         ],),
    dict(key='m12_parcel', type='chat', situation=None, module=12,
         title=('Посилка додому', 'Paket za Ukrajinu'),
         hr='''Darja: Mama, danas sam ti poslala paket kurirskom službom.
Mama: Hvala, dušo! Što si stavila unutra?
Darja: Kavu, čokoladu, maslinovo ulje i toplu majicu za tatu. Morala sam ispuniti carinsku deklaraciju i napisati sadržaj paketa.
Mama: A koliko si platila dostavu?
Darja: Težina paketa je pet kilograma, pa je bilo trideset eura. Rok dostave je oko tjedan dana.
Mama: Kako ću znati gdje je paket?
Darja: Poslat ću ti broj za praćenje, pa možeš pratiti pošiljku na internetu.
Mama: Super. A novac si mi poslala?
Darja: Jesam, preko aplikacije za plaćanje. Naknada za prijenos je mala, a novac stigne odmah.''',
         ua='''Дар'я: Мамо, сьогодні я надіслала тобі посилку кур'єрською службою.
Мама: Дякую, доню! Що ти поклала всередину?
Дар'я: Каву, шоколад, оливкову олію й теплу кофту для тата. Мені довелося заповнити митну декларацію і написати вміст посилки.
Мама: А скільки ти заплатила за доставку?
Дар'я: Вага посилки п'ять кілограмів, тож вийшло тридцять євро. Термін доставки – близько тижня.
Мама: Як я знатиму, де посилка?
Дар'я: Я надішлю тобі номер для відстеження, і ти зможеш стежити за відправленням в інтернеті.
Мама: Чудово. А гроші ти мені надіслала?
Дар'я: Так, через платіжний застосунок. Комісія за переказ невелика, а гроші приходять одразу.''',
         questions=[
             ('Що Дар’я поклала в посилку?', ['Каву, шоколад, олію й теплу кофту', 'Ліки', 'Гроші'], 'Каву, шоколад, олію й теплу кофту'),
             ('Скільки триває доставка?', ['Близько тижня', 'Один день', 'Місяць'], 'Близько тижня'),
             ('Як Дар’я надіслала гроші?', ['Через платіжний застосунок', 'Поштою', 'У посилці'], 'Через платіжний застосунок'),
         ],),
    dict(key='m12_bilingual', type='story', situation='small_talk', module=12,
         title=('Наша двомовна родина', 'Naša dvojezična obitelj'),
         hr='''Moj sin Danilo ima osam godina i u Hrvatskoj živi od svoje pete godine. U školi i s prijateljima iz razreda govori hrvatski, a kod kuće imamo obiteljsko pravilo: razgovaramo samo ukrajinski. Ukrajinski je njegov materinji jezik i ne želimo da ga zaboravi. Subotom ide u ukrajinsku online školu i uči ćirilicu. Hrvatski govori tečno i bez naglaska, a ponekad prevodi roditeljima kod liječnika. Ponekad miješa jezike u istoj rečenici i to nas uvijek nasmije. Za nas je dvojezičnost bogatstvo, a ne problem. Danilo zna da su mu korijeni u Ukrajini, a dom u Hrvatskoj.''',
         ua='''Моєму синові Данилові вісім років, і в Хорватії він живе з п'яти років. У школі й з друзями з класу він говорить хорватською, а вдома в нас родинне правило: розмовляємо лише українською. Українська – його рідна мова, і ми не хочемо, щоб він її забув. По суботах він ходить в українську онлайн-школу й вивчає кирилицю. Хорватською він говорить вільно й без акценту, а іноді перекладає батькам у лікаря. Інколи він змішує мови в одному реченні, і це нас завжди смішить. Для нас двомовність – це багатство, а не проблема. Данило знає, що його корені в Україні, а дім – у Хорватії.''',
         questions=[
             ('Якою мовою родина розмовляє вдома?', ['Українською', 'Хорватською', 'Англійською'], 'Українською'),
             ('Що Данило робить по суботах?', ['Ходить в українську онлайн-школу', 'Грає у футбол', 'Працює'], 'Ходить в українську онлайн-школу'),
             ('Як родина ставиться до двомовності?', ['Як до багатства', 'Як до проблеми', 'Байдуже'], 'Як до багатства'),
         ],),
]

# ===================================================================== A2.13 Плани, мрії й домовленості
TEXTS += [
    dict(key='m13_reschedule', type='chat', situation='small_talk', module=13,
         title=('Переносимо зустріч', 'Pomaknimo dogovor'),
         hr='''Daša: Bok, Ivana! Ispričavam se, ali iskrsnulo mi je nešto na poslu. Ne stižem danas na kavu u pet.
Ivana: Nema problema! Možemo li pomaknuti dogovor na sutra?
Daša: Sutra mi je raspored pun. Odgovara li ti subota ujutro?
Ivana: Subota je super. Recimo u deset na Trgu?
Daša: Dogovoreno! Ako se išta promijeni, javit ću ti.
Ivana: Važi. I nemoj otkazati u zadnji čas kao prošli put!
Daša: Neću, obećavam! Veselim se, vidimo se onda u subotu.
Ivana: Vidimo se!''',
         ua='''Даша: Привіт, Івано! Перепрошую, але в мене дещо трапилося на роботі. Я не встигаю сьогодні на каву о п'ятій.
Івана: Без проблем! Можемо перенести зустріч на завтра?
Даша: Завтра в мене щільний розклад. Тобі підходить субота вранці?
Івана: Субота – чудово. Скажімо, о десятій на Площі?
Даша: Домовилися! Якщо щось зміниться, я тобі напишу.
Івана: Гаразд. І не скасовуй в останню мить, як минулого разу!
Даша: Не скасую, обіцяю! Чекаю з радістю, тоді побачимося в суботу.
Івана: До зустрічі!''',
         questions=[
             ('Чому Даша не прийде сьогодні?', ['Щось трапилося на роботі', 'Вона захворіла', 'Вона забула'], 'Щось трапилося на роботі'),
             ('Коли вони домовилися зустрітися?', ['У суботу о десятій', 'Завтра о п’ятій', 'У неділю'], 'У суботу о десятій'),
             ('Про що просить Івана?', ['Не скасовувати в останню мить', 'Прийти раніше', 'Принести торт'], 'Не скасовувати в останню мить'),
         ],),
    dict(key='m13_goals', type='story', situation='small_talk', module=13,
         title=('Мої новорічні рішення', 'Moje novogodišnje odluke'),
         hr='''Svake godine postavim nekoliko ciljeva, ali ih često ne ostvarim. Ove godine želim biti realna. Napravila sam listu ciljeva u planeru. Prvi cilj: do kraja godine položiti ispit iz hrvatskog i dobiti certifikat. Drugi cilj: uštedjeti za ljetovanje, pa ću svaki mjesec staviti sto eura na štednju. Treći cilj je dugoročni plan: jednog dana otvoriti vlastiti posao. Znam da će biti teško, ali neću odustati. Za uspjeh treba motivacija, ali još više ustrajnost. Vidjet ćemo kako će ići!''',
         ua='''Щороку я ставлю собі кілька цілей, але часто їх не досягаю. Цього року я хочу бути реалісткою. Я склала список цілей у планері. Перша мета: до кінця року скласти іспит з хорватської й отримати сертифікат. Друга мета: заощадити на літню відпустку, тож щомісяця я відкладатиму сто євро. Третя мета – довгостроковий план: одного дня відкрити власну справу. Я знаю, що буде важко, але не здамся. Для успіху потрібна мотивація, але ще більше – наполегливість. Побачимо, як піде!''',
         questions=[
             ('Де вона склала список цілей?', ['У планері', 'На холодильнику', 'У телефоні'], 'У планері'),
             ('Скільки грошей вона відкладатиме щомісяця?', ['Сто євро', 'П’ятдесят євро', 'Двісті євро'], 'Сто євро'),
             ('Яка її довгострокова мета?', ['Відкрити власну справу', 'Купити машину', 'Переїхати'], 'Відкрити власну справу'),
         ],),
]

# ===================================================================== A2.14 Підсумок A2: моє життя в Хорватії
TEXTS += [
    dict(key='m14_school_letter', type='email', situation=None, module=14,
         title=('Лист класній керівниці', 'Pismo razrednici'),
         hr='''Poštovana gospođo Jurić,
pišem Vam zbog svog sina Maksima iz trećeg razreda. Sljedeći tjedan, od ponedjeljka do srijede, moramo putovati u Ukrajinu zbog obiteljskih razloga. Molila bih Vas da opravdate njegov izostanak. Maksim će zadaću i lektiru napraviti za vrijeme puta. Također bih Vas zamolila za pojašnjenje: što točno treba ponoviti za sljedeći ispit iz matematike? Ako trebate neki dokument, molim Vas da mi javite. Bila bih Vam zahvalna na brzom odgovoru.
U iščekivanju odgovora, s poštovanjem,
Olena Bondar''',
         ua='''Шановна пані Юрич!
Пишу вам щодо свого сина Максима з третього класу. Наступного тижня, з понеділка до середи, ми мусимо поїхати в Україну через сімейні обставини. Прошу вас виправдати його пропуск. Максим зробить домашнє завдання й прочитає твір із позакласного читання під час поїздки. Також прошу вас пояснити: що саме треба повторити до наступної контрольної з математики? Якщо вам потрібен якийсь документ, прошу повідомити мене. Буду вдячна за швидку відповідь.
Чекаю на відповідь, з повагою,
Олена Бондар''',
         questions=[
             ('Чому Максим не буде в школі?', ['Родина їде в Україну', 'Він хворіє', 'Він переходить в іншу школу'], 'Родина їде в Україну'),
             ('Про що мама просить учительку?', ['Виправдати пропуск і пояснити, що повторити', 'Дати додаткове завдання', 'Змінити розклад'], 'Виправдати пропуск і пояснити, що повторити'),
             ('Що Максим зробить під час поїздки?', ['Домашнє завдання й позакласне читання', 'Нічого', 'Контрольну роботу'], 'Домашнє завдання й позакласне читання'),
         ],),
    dict(key='m14_friend_letter', type='email', situation='small_talk', module=14,
         title=('Лист подрузі: я даю собі раду', 'Pismo prijateljici'),
         hr='''Draga Oksana,
hvala ti na pismu, jako mi nedostaješ! Imam puno novosti. Ukratko: napokon sam položila ispit iz hrvatskog! Sada se puno bolje snalazim u svakodnevnim situacijama. Prošli tjedan sam bila kod liječnika i sama sam opisala simptome, bez prevoditelja. Na poslu sam se samostalno dogovorila sa šefom oko godišnjeg odmora. Prije dvije godine to nisam mogla ni zamisliti. Naravno, još uvijek griješim, ali učim iz pogrešaka. Imam više samopouzdanja i osjećam da je ovo novo poglavlje u mom životu. Kad dolaziš u posjet? Jedva čekam da te vidim!
Piši mi i pozdravi svoje!
Tvoja Darja''',
         ua='''Дорога Оксано!
Дякую тобі за листа, я дуже за тобою сумую! У мене багато новин. Коротко: нарешті я склала іспит з хорватської! Тепер я набагато краще даю собі раду в щоденних ситуаціях. Минулого тижня я була в лікаря й сама описала симптоми, без перекладача. На роботі я самостійно домовилася з шефом про відпустку. Два роки тому я не могла навіть уявити цього. Звісно, я ще помиляюся, але вчуся на помилках. Я стала впевненішою в собі й відчуваю, що це новий розділ у моєму житті. Коли ти приїдеш у гості? Не можу дочекатися, щоб тебе побачити!
Пиши мені й передавай вітання своїм!
Твоя Дар'я''',
         questions=[
             ('Яку новину Дар’я повідомляє спочатку?', ['Склала іспит з хорватської', 'Знайшла нову роботу', 'Переїхала'], 'Склала іспит з хорватської'),
             ('Що вона зробила сама в лікаря?', ['Описала симптоми без перекладача', 'Записалася онлайн', 'Купила ліки'], 'Описала симптоми без перекладача'),
             ('Що вона відчуває тепер?', ['Більше впевненості в собі', 'Сум', 'Страх'], 'Більше впевненості в собі'),
         ],),
]
