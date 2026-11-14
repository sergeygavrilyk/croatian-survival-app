"""
Фрази A2 (public.phrases), програма A2 v2: 4 фрази на модуль, 56 разом · 2026-11-13.

Формат: (модуль, ситуація з lib/situations.ts, хорватською, українською, register, usage_tags).
regionality — усюди 'general' (регіональних фраз тут немає). Тип фрази генератор визначає сам:
'question', якщо в кінці «?», інакше 'phrase'. Фрази — готові висловлювання для життя в Хорватії,
зі словами уроків модуля. Генератор: python3 -B scripts/gen_phrases_a2.py.
"""

PHRASES: list[tuple] = [
    # A2.1 Туризм і подорожі: Адріатика
    (1, 'travel', 'Je li doručak uključen u cijenu?', 'Сніданок включено у вартість?', 'standard', []),
    (1, 'travel', 'Možemo li se odjaviti malo kasnije?', 'Чи можемо ми виселитися трохи пізніше?', 'standard', []),
    (1, 'travel', 'Klima-uređaj u sobi ne funkcionira.', 'Кондиціонер у номері не працює.', 'standard', []),
    (1, 'travel', 'Kada polazi sljedeći trajekt za Hvar?', 'Коли відходить наступний пором на Хвар?', 'standard', []),
    # A2.2 Навчання: курси, університет, школа
    (2, 'administration', 'Želio bih se upisati na tečaj hrvatskog.', 'Я хотів би записатися на курс хорватської.', 'standard', []),
    (2, 'administration', 'Kako mogu priznati svoju diplomu?', 'Як мені визнати свій диплом?', 'standard', []),
    (2, 'basics', 'Moje dijete danas neće doći u školu.', 'Моя дитина сьогодні не прийде до школи.', 'standard', []),
    (2, 'basics', 'Možete li ponoviti malo sporije?', 'Чи можете повторити трохи повільніше?', 'standard', []),
    # A2.3 Моє минуле: дитинство й спогади
    (3, 'small_talk', 'Kad sam bila mala, živjela sam na selu.', 'Коли я була маленькою, я жила в селі.', 'standard', []),
    (3, 'small_talk', 'Sjećaš li se kad smo se upoznali?', 'Пам’ятаєш, коли ми познайомилися?', 'standard', []),
    (3, 'small_talk', 'U Hrvatskoj živim već tri godine.', 'Я живу в Хорватії вже три роки.', 'standard', []),
    (3, 'small_talk', 'Nikad to neću zaboraviti.', 'Я ніколи цього не забуду.', 'standard', []),
    # A2.4 Люди й стосунки: характер, свята, конфлікти
    (4, 'small_talk', 'Čestitam od srca!', 'Щиро вітаю!', 'standard', ['idiom']),
    (4, 'small_talk', 'Iskrena sućut.', 'Щирі співчуття.', 'standard', []),
    (4, 'small_talk', 'Ispričavam se, nisam to tako mislio.', 'Перепрошую, я не це мав на увазі.', 'standard', []),
    (4, 'housing', 'Možete li, molim vas, utišati glazbu?', 'Чи не могли б ви, будь ласка, зробити музику тихіше?', 'standard', []),
    # A2.5 Робота й кар'єра
    (5, 'work', 'Možemo li pomaknuti rok na petak?', 'Чи можемо ми перенести термін на п’ятницю?', 'standard', []),
    (5, 'work', 'U privitku Vam šaljem traženi dokument.', 'У вкладенні надсилаю вам потрібний документ.', 'formal', []),
    (5, 'work', 'Mogu li razgovarati s gospođom Horvat?', 'Чи можу я поговорити з пані Горват?', 'standard', []),
    (5, 'work', 'Želio bih iskoristiti preostale dane godišnjeg.', 'Я хотів би використати решту днів відпустки.', 'standard', []),
    # A2.6 Установи, послуги й гроші
    (6, 'shopping', 'Htjela bih se naručiti za šišanje.', 'Я хотіла б записатися на стрижку.', 'standard', []),
    (6, 'shopping', 'Kada će biti gotovo?', 'Коли буде готово?', 'standard', []),
    (6, 'administration', 'Trebam ovjeriti potpis kod javnog bilježnika.', 'Мені треба засвідчити підпис у нотаріуса.', 'standard', []),
    (6, 'administration', 'Gdje mogu dobiti potvrdu o OIB-u?', 'Де я можу отримати довідку про OIB?', 'standard', []),
    # A2.7 Здоров'я: система й самопочуття
    (7, 'health', 'Trebam se naručiti kod izabranog liječnika.', 'Мені треба записатися до свого сімейного лікаря.', 'standard', []),
    (7, 'health', 'Vrti mi se u glavi.', 'У мене паморочиться в голові.', 'standard', ['idiom']),
    (7, 'health', 'Moram otvoriti bolovanje radi njege djeteta.', 'Мені треба відкрити лікарняний по догляду за дитиною.', 'standard', []),
    (7, 'health', 'Kada mogu doći po nalaze?', 'Коли можна прийти по результати аналізів?', 'standard', []),
    # A2.8 Авто в Хорватії
    (8, 'administration', 'Kako mogu zamijeniti stranu vozačku dozvolu?', 'Як мені обміняти іноземне посвідчення водія?', 'standard', []),
    (8, 'transport', 'Netko mi je udario auto na parkiralištu.', 'Хтось ударив мою машину на парковці.', 'standard', []),
    (8, 'car_service', 'Kada auto mora na tehnički pregled?', 'Коли машина має проходити техогляд?', 'standard', []),
    (8, 'transport', 'Gdje se plaća cestarina?', 'Де платять за проїзд автомагістраллю?', 'standard', []),
    # A2.9 Неприємності в місті й довкілля
    (9, 'administration', 'Gdje mogu prijaviti gubitak dokumenata?', 'Де я можу заявити про втрату документів?', 'standard', []),
    (9, 'basics', 'Ukrali su mi torbu.', 'У мене вкрали сумку.', 'standard', []),
    (9, 'housing', 'U koju kantu ide plastika?', 'У який контейнер викидати пластик?', 'standard', []),
    (9, 'housing', 'U našoj ulici nema struje.', 'На нашій вулиці немає світла.', 'standard', []),
    # A2.10 Медіа, культура й думки
    (10, 'small_talk', 'Po meni, film je bio odličan.', 'На мою думку, фільм був чудовий.', 'standard', []),
    (10, 'small_talk', 'Ne slažem se s tobom.', 'Я з тобою не згоден.', 'standard', []),
    (10, 'shopping', 'Je li oglas još aktualan?', 'Оголошення ще актуальне?', 'standard', []),
    (10, 'small_talk', 'Što ti misliš o tome?', 'А ти що про це думаєш?', 'standard', []),
    # A2.11 Хорватія: краї, звичаї, культура
    (11, 'small_talk', 'Možemo li se tikati?', 'Можемо перейти на «ти»?', 'standard', []),
    (11, 'small_talk', 'Hvala na gostoprimstvu!', 'Дякую за гостинність!', 'standard', []),
    (11, 'travel', 'Što mi preporučujete posjetiti u Istri?', 'Що порадите відвідати в Істрії?', 'standard', []),
    (11, 'cafe_restaurant', 'Ovo je tipično slavonsko jelo.', 'Це типова славонська страва.', 'standard', []),
    # A2.12 Українці в Хорватії
    (12, 'administration', 'Imam status privremene zaštite.', 'Я маю статус тимчасового захисту.', 'standard', []),
    (12, 'administration', 'Moram produljiti iskaznicu stranca.', 'Мені треба продовжити посвідку іноземця.', 'standard', []),
    (12, 'shopping', 'Koliko košta slanje paketa u Ukrajinu?', 'Скільки коштує надіслати посилку в Україну?', 'standard', []),
    (12, 'small_talk', 'Moja djeca govore hrvatski bolje od mene.', 'Мої діти говорять хорватською краще за мене.', 'standard', []),
    # A2.13 Плани, мрії й домовленості
    (13, 'small_talk', 'Odgovara li ti u subotu u deset?', 'Тобі підходить у суботу о десятій?', 'standard', []),
    (13, 'small_talk', 'Možemo li to pomaknuti na sutra?', 'Можемо перенести це на завтра?', 'standard', []),
    (13, 'small_talk', 'Javit ću ti čim budem znao.', 'Я тобі напишу, щойно знатиму.', 'standard', []),
    (13, 'work', 'Volio bih jednog dana otvoriti vlastiti posao.', 'Я хотів би колись відкрити власну справу.', 'standard', []),
    # A2.14 Підсумок A2: моє життя в Хорватії
    (14, 'basics', 'Oprostite, možete li mi to objasniti jednostavnije?', 'Перепрошую, можете пояснити мені це простіше?', 'standard', []),
    (14, 'basics', 'Jesam li vas dobro razumio?', 'Я вас правильно зрозумів?', 'standard', []),
    (14, 'administration', 'Kome se mogu obratiti za pomoć?', 'До кого я можу звернутися по допомогу?', 'standard', []),
    (14, 'small_talk', 'Snalazim se sve bolje.', 'Я даю собі раду дедалі краще.', 'standard', []),
]
