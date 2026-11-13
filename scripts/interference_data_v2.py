"""
Типові помилки українців, пакет v2 · 2026-11-13 (борг PROJECT_STATE: «вимова — підказки кирилицею;
мало «артиклів» і «виду дієслова»»).

Формат запису — як у interference_data.py (v1), але тема граматики — «A0:<назва>» або «A1:<назва>»
так, як вона записана в grammar_topics.title_ua (A1 v3 має інші теми, ніж GRAMMAR_A1 v1).
Коди продовжують v1: UKR-HR-0075… — порядок не змінювати, нові записи лише в кінець.
v1 (interference_data.py) не змінюємо: файл 20261013_interference_v1.sql уже запущено.
"""

G_PRON = 'A0:Вимова: хорватські літери'
G_DEM = 'A0:Цей, той, он той: ovaj, taj, onaj'
G_FUT = 'A1:Майбутній час: ići ću, bit će'
G_PAST = 'A1:Минулий час: radio sam, bila sam'
G_MODAL = 'A1:Модальні дієслова'
G_IMP = 'A1:Наказовий спосіб'

ERRORS = [
    # ------------------------------------------------------------ вид дієслова
    ('aspect', 'A1', G_FUT, 'kupiti', 'Майбутнє — «kupit ću», а не «kupim»',
     'Sutra kupim karte.', 'Sutra ću kupiti karte.',
     'Українською «куплю», «напишу» вже означають майбутнє. У хорватській доконане kupim, napišem саме по собі майбутнього не означає — воно стоїть після kad, ako, čim, da. Майбутнє — з ću: kupit ću, napisat ću. У розмові іноді чуєте «javim ti se sutra», але в стандартній мові й на письмі — з ću.',
     [('Nazvat ću te večeras.', 'Я подзвоню тобі ввечері.'), ('Kad kupim karte, javit ću ti.', 'Коли куплю квитки, дам тобі знати.')]),
    ('aspect', 'A1', G_MODAL, 'dodati', 'Прохання про одну дію — доконаний вид',
     'Možeš li mi dodavati sol?', 'Možeš li mi dodati sol?',
     'Коли просимо зробити щось один раз, після moći, htjeti, trebati ставимо доконане дієслово: dodati, otvoriti, pomoći. Недоконане (dodavati, otvarati) — про дію, що повторюється або триває.',
     [('Možete li otvoriti prozor?', 'Можете відчинити вікно?'), ('Trebam platiti račun.', 'Мені треба оплатити рахунок.')]),
    ('aspect', 'A1', G_PAST, 'platiti', 'Справу зроблено — доконаний вид',
     'Jesi li već plaćao račun?', 'Jesi li već platio račun?',
     'Коли питаємо чи кажемо, що справу завершено і є результат, — доконаний вид: platio, kupio, završio. Недоконаний (plaćao, kupovao) — про процес або звичку: «оплачував», «купував».',
     [('Već sam kupila kruh.', 'Я вже купила хліб.'), ('Jesi li završio posao?', 'Ти закінчив роботу?')]),
    ('aspect', 'A1', G_PAST, 'pisati', 'Скільки тривало — недоконаний вид',
     'Cijelo jutro sam napisao izvještaj.', 'Cijelo jutro sam pisao izvještaj.',
     'Зі словами cijeli dan, cijelo jutro, dva sata, dugo дія тривала — потрібен недоконаний вид: pisao, čekao, učio. Доконаний (napisao) показує результат: Napisao sam izvještaj za dva sata — за дві години.',
     [('Dva sata smo čekali autobus.', 'Ми дві години чекали автобус.'), ('Cijelu večer je učila hrvatski.', 'Увесь вечір вона вчила хорватську.')]),
    ('aspect', 'A2', None, 'početi', 'Після početi і prestati — недоконаний вид',
     'Počela sam naučiti hrvatski.', 'Počela sam učiti hrvatski.',
     'Після početi, prestati, nastaviti — лише недоконане дієслово: početi raditi, prestati pušiti, nastaviti učiti. Так само українською: «почала вчити», а не «почала вивчити».',
     [('Prestao je pušiti prošle godine.', 'Він кинув курити минулого року.'), ('Kada počinješ raditi?', 'Коли ти починаєш працювати?')]),
    ('aspect', 'A1', G_IMP, 'zvati', 'Робіть регулярно — наказ від недоконаного',
     'Nazovi me ponekad!', 'Zovi me ponekad!',
     'Наказ від доконаного дієслова (nazovi, napiši) — про одну конкретну дію. Якщо дія повторюється (ponekad, svaki dan, uvijek), наказ — від недоконаного: zovi, piši, dolazi.',
     [('Napiši mi kad stigneš!', 'Напиши мені, коли доїдеш!'), ('Zovi me kad god ti nešto treba.', 'Дзвони мені щоразу, коли тобі щось треба.')]),
    # ------------------------------------------------------------ артиклі
    ('articles', 'A0', G_DEM, 'taj', 'Taj — не англійське the',
     'Taj život je lijep.', 'Život je lijep.',
     'Taj означає «той / цей» — коли показуємо на щось або про нього вже йшлося. Загальні поняття (život, ljubav, novac) і речі взагалі — без жодного слова перед ними, як в українській.',
     [('Novac nije najvažniji.', 'Гроші — не найголовніше.'), ('Volim more.', 'Я люблю море.')]),
    ('articles', 'A0', G_DEM, 'centar', '«У центр» — просто «u centar»',
     'Idem u taj centar.', 'Idem u centar.',
     'Англійське the city centre не перекладаємо словом taj. «Іду в центр» — Idem u centar. U taj centar означає «саме в той центр», про який уже говорили.',
     [('Je li ovo autobus za centar?', 'Це автобус до центру?'), ('Pošta je u centru.', 'Пошта в центрі.')]),
    ('articles', 'A0', None, 'kao', 'Після kao — без jedan',
     'Radim kao jedan programer.', 'Radim kao programer.',
     'Англійське I work as a programmer не потребує jedan. Після kao професію чи роль ставимо саму: radim kao konobar, kao vozač, kao učiteljica.',
     [('Darja radi kao medicinska sestra.', 'Дар’я працює медсестрою.'), ('Ljeti radim kao konobar.', 'Улітку я працюю офіціантом.')]),
    # ------------------------------------------------------------ вимова
    ('pronunciation', 'A0', G_PRON, 'cijena', 'C — це «ц», а не «к»',
     'cijena — «кієна»', 'cijena — «цієна»',
     'Хорватська c завжди читається як «ц»: cijena, centar, crkva. Не читайте її як англійське «к».',
     [('Kolika je cijena?', 'Яка ціна? [цієна]'), ('Centar je blizu.', 'Центр поруч. [центар]')]),
    ('pronunciation', 'A0', G_PRON, 'jutro', 'J — це «й», а не «дж»',
     'jutro — «джутро»', 'jutro — «ютро»',
     'Хорватська j — завжди «й»: ja — «я», jutro — «ютро», Jelena — «Єлена». Не читайте її як англійське «дж».',
     [('Dobro jutro!', 'Доброго ранку! [добро ютро]'), ('Jelena je moja prijateljica.', 'Єлена — моя подруга. [єлена]')]),
    ('pronunciation', 'A0', G_PRON, 'rođendan', 'Đ і dž — різні звуки',
     'rođendan — тверде «дж», як у слові «джміль»', 'rođendan — м’якше «дж» (між «дж» і «дь»)',
     'dž — тверде «дж», як в українській: džep (кишеня). đ — м’якша пара до ć: rođendan, međutim, Đurđa. Різниця між dž і đ така сама, як між č і ć.',
     [('Sretan rođendan!', 'З днем народження!'), ('Ključ je u džepu.', 'Ключ у кишені.')]),
]

# Виправлення вже опублікованих записів v1 (через content_versions). code → нові значення полів.
FIXES = {
    # «майже «кутя»» читається як «т» — плутає. Порівняння з «ч» і «ть» — як у поясненні цього ж запису.
    'UKR-HR-0060': {'correct_text': 'kuća — м’якше «ч» (між «ч» і «ть»)'},
}
