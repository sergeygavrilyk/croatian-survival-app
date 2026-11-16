# «Складіть речення» в перевірках рівня: інші порядки слів — для носія

> Згенеровано `scripts/gen_sentence_orders_20261116.py` 2026-11-16. Рішення власника 2026-11-15: «Складіть» приймає кілька
> порядків слів. Інші порядки записав Claude вручну (`scripts/sentence_order_alternatives.py`) — **потрібна перевірка носієм**.

## Що глянути

1. Чи кожен «інший порядок» природний і має те саме значення (переклад завдання лишається правильним).
2. Де записано «лише один порядок» — чи немає ще одного звичного порядку (тоді учневі зарахують помилку несправедливо).
3. Свідомо не записано порядки з наголосом чи протиставленням (*Zahtjev želim predati.*, *Na posao idem.*) — чи погоджуєтеся.

| Перевірка | Завдання (переклад) | Головна відповідь | Інші порядки |
|---|---|---|---|
| `a0-m01` | З днем народження! | *Sretan rođendan!* | лише один порядок |
| `a0-m02` | Він мій сусід. | *On je moj susjed.* | лише один порядок |
| `a0-m02` | Моя рідна мова — українська. | *Moj materinski jezik je ukrajinski.* | *Ukrajinski je moj materinski jezik.* |
| `a0-m03` | Хто останній у черзі? | *Tko je zadnji u redu?* | лише один порядок |
| `a0-m03` | П’ять плюс три — вісім. | *Pet plus tri je osam.* | лише один порядок |
| `a0-m03` | Скільки тут яблук? | *Koliko ima jabuka?* | *Koliko jabuka ima?* |
| `a0-m04` | Яка сьогодні погода? | *Kakvo je danas vrijeme?* | *Kakvo je vrijeme danas?* |
| `a0-m05` | Моя кішка спить цілий день. | *Moja mačka spava cijeli dan.* | *Moja mačka cijeli dan spava.* |
| `a0-m06` | Квартира велика й світла. | *Stan je velik i svijetao.* | лише один порядок |
| `a0-m07` | Я не їм м’яса. | *Ne jedem meso.* | *Meso ne jedem.* |
| `a0-m08` | Можна дешевше? | *Može li jeftinije?* | лише один порядок |
| `a0-m09` | Пошта навпроти банку. | *Pošta je preko puta banke.* | *Preko puta banke je pošta.* |
| `a0-m10` | Я хочу подати заяву. | *Želim predati zahtjev.* | лише один порядок |
| `a0-mid` | Моє повне ім’я — Дар’я. | *Moje puno ime je Darja.* | *Darja je moje puno ime.* |
| `a0-mid` | Побачимося пізніше! | *Vidimo se kasnije!* | *Kasnije se vidimo!* |
| `a0-mid` | Ви набрали не той номер. | *Nazvali ste krivi broj.* | лише один порядок |
| `a0-final` | Скільки коштує вхідний квиток? | *Koliko košta ulaznica?* | *Koliko ulaznica košta?* |
| `a0-final` | У вас є столик на двох? | *Imate li stol za dvoje?* | лише один порядок |
| `a0-final` | Де ти зараз живеш? | *Gdje sada živiš?* | *Gdje živiš sada?* |
| `a0-final` | Добре, дякую. А ти? | *Dobro, hvala. A ti?* | *Hvala, dobro. A ti?* |
| `a0-final` | Пральна машина не працює. | *Perilica ne radi.* | лише один порядок |
| `a1-m01` | Дай їй соску, будь ласка. | *Daj joj dudu, molim te.* | *Molim te, daj joj dudu.* |
| `a1-m01` | Потім я збираюся на роботу. | *Zatim se spremam za posao.* | лише один порядок |
| `a1-m01` | Я вигулюю пса в парку. | *Šetam psa u parku.* | *U parku šetam psa.* |
| `a1-m02` | Розігрій духовку до двохсот градусів. | *Zagrij pećnicu na dvjesto stupnjeva.* | *Pećnicu zagrij na dvjesto stupnjeva.* |
| `a1-m02` | Принеси тацю з кухні. | *Donesi pladanj iz kuhinje.* | *Iz kuhinje donesi pladanj.* |
| `a1-m02` | Де відкривачка для пляшок? | *Gdje je otvarač za boce?* | лише один порядок |
| `a1-m03` | Мені подобається твій стиль. | *Sviđa mi se tvoj stil.* | *Tvoj stil mi se sviđa.* |
| `a1-m03` | У нас немає гелю для душу. | *Nemamo gela za tuširanje.* | *Gela za tuširanje nemamo.* |
| `a1-m04` | Коли прибуває потяг? | *Kada stiže vlak?* | *Kada vlak stiže?* |
| `a1-m04` | Це моя валіза. | *Ovo je moj kofer.* | лише один порядок |
| `a1-m04` | Мені треба заправити бак. | *Moram natočiti gorivo.* | лише один порядок |
| `a1-m05` | Потримай драбину, будь ласка. | *Drži ljestve, molim te.* | *Molim te, drži ljestve.* |
| `a1-m05` | Треба провітрити ванну. | *Treba prozračiti kupaonicu.* | *Kupaonicu treba prozračiti.* |
| `a1-m05` | Подай мені викрутку. | *Dodaj mi odvijač.* | лише один порядок |
| `a1-m06` | Він працює на будові. | *On radi na gradilištu.* | лише один порядок |
| `a1-m06` | Я працюю на рецепції. | *Radim na recepciji.* | лише один порядок |
| `a1-m07` | Спершу зарядь телефон. | *Prvo napuni mobitel.* | *Napuni prvo mobitel.* |
| `a1-m08` | Приймайте натщесерце. | *Uzimajte lijek natašte.* | *Lijek uzimajte natašte.* |
| `a1-m08` | Дитина блює з ранку. | *Dijete povraća od jutra.* | *Od jutra dijete povraća.* |
| `a1-m08` | Який діагноз? | *Kakva je dijagnoza?* | лише один порядок |
| `a1-m09` | Я вболіваю за Хорватію. | *Navijam za Hrvatsku.* | лише один порядок |
| `a1-m09` | Яке в тебе хобі? | *Koji je tvoj hobi?* | лише один порядок |
| `a1-m09` | Дякую за запрошення! | *Hvala na pozivu!* | лише один порядок |
| `a1-m10` | Коли відправляється пором? | *Kada polazi trajekt?* | *Kada trajekt polazi?* |
| `a1-m11` | Пршут смачніший за шинку. | *Pršut je ukusniji od šunke.* | лише один порядок |
| `a1-m12` | Я хочу відкрити рахунок. | *Želim otvoriti račun.* | лише один порядок |
| `a1-m12` | У будинку пожежа! | *U zgradi je požar!* | *Požar je u zgradi!* |
| `a1-m13` | Я виросла в Києві. | *Odrasla sam u Kijevu.* | *U Kijevu sam odrasla.* |
| `a1-mid` | Я йду на роботу. | *Idem na posao.* | лише один порядок |
| `a1-mid` | Нам треба перенести зустріч. | *Moramo odgoditi sastanak.* | *Sastanak moramo odgoditi.* |
| `a1-mid` | Ми живемо біля школи. | *Živimo blizu škole.* | *Blizu škole živimo.* |
| `a1-final` | Де зустрічаємося? | *Gdje se nalazimo sutra?* | *Gdje se sutra nalazimo?* |
| `a1-final` | Я прийшла здати кров. | *Došla sam vaditi krv.* | лише один порядок |
| `a1-final` | Наступного тижня я працюю з дому. | *Sljedeći tjedan radim od kuće.* | *Radim od kuće sljedeći tjedan.* |
| `a1-final` | Мені потрібен новий акумулятор. | *Trebam novi akumulator.* | лише один порядок |
| `a1-final` | Я не отримала лист. | *Nisam primila mail.* | *Mail nisam primila.* |
| `a2-final` |  | *Tvoja poruka me jako obradovala.* | *Tvoja me poruka jako obradovala.* · *Jako me obradovala tvoja poruka.* |
| `a2-final` |  | *Zabranjeno je hraniti životinje.* | *Hraniti životinje je zabranjeno.* |
| `a2-final` |  | *Na sljedećem izlazu skrenite desno.* | *Skrenite desno na sljedećem izlazu.* |
| `a2-final` |  | *Danas mu je već bolje.* | лише один порядок |
| `a2-final` |  | *Potpišite suglasnost za izlet.* | лише один порядок |
| `a2-m01` |  | *Katamaran ne prevozi automobile.* | лише один порядок |
| `a2-m01` |  | *U posezoni su cijene niže.* | *Cijene su niže u posezoni.* |
| `a2-m02` |  | *Za nezaposlene je tečaj besplatan.* | *Tečaj je besplatan za nezaposlene.* |
| `a2-m02` |  | *Iz matematike ide na instrukcije.* | *Ide na instrukcije iz matematike.* |
| `a2-m03` |  | *Izgubili smo se u starom gradu.* | *U starom gradu smo se izgubili.* |
| `a2-m04` |  | *Zahtijevam povrat novca.* | лише один порядок |
| `a2-m05` |  | *Svakom kupcu treba izdati račun.* | *Račun treba izdati svakom kupcu.* |
| `a2-m06` |  | *Slavina kapa cijelu noć.* | *Slavina cijelu noć kapa.* |
| `a2-m07` |  | *Na pregled dođite natašte.* | *Dođite na pregled natašte.* |
| `a2-m08` |  | *Parking možete platiti SMS-om.* | *Možete platiti parking SMS-om.* |
| `a2-m09` |  | *Moramo čuvati okoliš.* | *Okoliš moramo čuvati.* |
| `a2-m10` |  | *Nemoj mi otkriti kraj!* | лише один порядок |
| `a2-m11` |  | *Starijima se persira.* | *Persira se starijima.* |
| `a2-m12` |  | *Mama je primila novac jučer.* | *Mama je jučer primila novac.* · *Jučer je mama primila novac.* |
| `a2-m13` |  | *Doći ću, pod uvjetom da ne pada kiša.* | *Pod uvjetom da ne pada kiša, doći ću.* |
| `a2-m14` |  | *Jako mi nedostaješ.* | лише один порядок |
| `a2-mid` |  | *Natječaj se objavljuje u svibnju.* | *U svibnju se objavljuje natječaj.* |
| `a2-mid` |  | *Nisam te htjela uvrijediti.* | лише один порядок |
| `a2-mid` |  | *Brzo smo se priviknuli na novi grad.* | *Na novi grad smo se brzo priviknuli.* |

Разом: 81 завдань «Складіть», з іншими порядками — 48.
