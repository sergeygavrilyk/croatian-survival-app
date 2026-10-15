/**
 * «Ситуації» → «Пісні» (рішення власника 2026-10-15): хорватські пісні, які чують на святах, фештах і стадіонах.
 *
 * Авторське право: повний текст подаємо лише для творів у суспільному надбанні — гімн «Lijepa naša domovino»
 * (слова Антуна Міхановича, 1835) і «Sretan rođendan» (мелодія «Happy Birthday», народний текст).
 * Для інших пісень — лише назва, виконавець, про що пісня (своїми словами), ключові слова і посилання,
 * де послухати. Тексти авторських пісень у застосунок не копіюємо.
 *
 * Факти перевірено 2026-10-15 (Вікіпедія, diskografija.com, сервіси музики). Хорватські рядки — бета, носій перевіряє.
 */

export interface SongWord {
  hr: string;
  ua: string;
}

export interface SongLine {
  hr: string;
  ua: string;
}

export interface Song {
  slug: string;
  title: string;
  /** Переклад назви українською */
  title_ua: string;
  performer: string;
  /** Коли / звідки (лише перевірені факти) */
  origin: string;
  /** Про що пісня і коли її співають — своїми словами */
  about: string;
  /** Ключові слова з назви й теми пісні */
  words: SongWord[];
  /** Повний текст — лише для суспільного надбання */
  lyrics?: SongLine[];
  /** Пошуковий запит для «Послухати» (YouTube) */
  listen_query: string;
}

export const SONGS: readonly Song[] = [
  {
    slug: 'sretan-rodendan',
    title: 'Sretan rođendan ti',
    title_ua: 'З днем народження тебе',
    performer: 'народна (мелодія «Happy Birthday»)',
    origin: 'Співають на кожному дні народження',
    about:
      'Хорватська версія «Happy Birthday». Співають усі разом, коли виносять торт; у третьому рядку називають ім’я іменинника у кличному відмінку: «draga Dašo», «dragi Marko».',
    words: [
      { hr: 'sretan', ua: 'щасливий' },
      { hr: 'rođendan', ua: 'день народження' },
      { hr: 'dragi / draga', ua: 'дорогий / дорога' },
      { hr: 'čestitam', ua: 'вітаю' },
      { hr: 'torta', ua: 'торт' },
    ],
    lyrics: [
      { hr: 'Sretan rođendan ti,', ua: 'З днем народження тебе,' },
      { hr: 'sretan rođendan ti,', ua: 'з днем народження тебе,' },
      { hr: 'sretan rođendan, draga Dašo,', ua: 'з днем народження, люба Дашо,' },
      { hr: 'sretan rođendan ti!', ua: 'з днем народження тебе!' },
    ],
    listen_query: 'Sretan rođendan ti pjesma',
  },
  {
    slug: 'lijepa-nasa-domovino',
    title: 'Lijepa naša domovino',
    title_ua: 'Прекрасна наша батьківщино',
    performer: 'державний гімн Хорватії',
    origin: 'Слова — Антун Міханович (1835)',
    about:
      'Гімн Хорватії. Звучить на державних святах, у школах і перед матчами збірної — тоді його співає весь стадіон. Під час гімну встають. Нижче — перші дві строфи.',
    words: [
      { hr: 'lijep', ua: 'гарний, прекрасний' },
      { hr: 'domovina', ua: 'батьківщина' },
      { hr: 'zemlja', ua: 'земля, країна' },
      { hr: 'mio / mila', ua: 'милий / мила, дорога' },
      { hr: 'slava', ua: 'слава' },
      { hr: 'sretan', ua: 'щасливий' },
    ],
    lyrics: [
      { hr: 'Lijepa naša domovino,', ua: 'Прекрасна наша батьківщино,' },
      { hr: 'oj junačka zemljo mila,', ua: 'о геройська земле мила,' },
      { hr: 'stare slave djedovino,', ua: 'давньої слави дідівщино,' },
      { hr: 'da bi vazda sretna bila!', ua: 'щоб ти завжди щаслива була!' },
      { hr: 'Mila, kano si nam slavna,', ua: 'Мила, як ти нам славна,' },
      { hr: 'mila si nam ti jedina,', ua: 'мила ти нам, єдина,' },
      { hr: 'mila kuda si nam ravna,', ua: 'мила там, де ти рівнина,' },
      { hr: 'mila kuda si planina!', ua: 'мила там, де ти гори!' },
    ],
    listen_query: 'Lijepa naša domovino himna',
  },
  {
    slug: 'veceras-je-nasa-festa',
    title: 'Večeras je naša fešta',
    title_ua: 'Сьогодні ввечері наше свято',
    performer: 'Tomislav Ivčić',
    origin: 'Музика й слова — Tomislav Ivčić (Задар)',
    about:
      'Пісня для гулянь: її називають неофіційним гімном Далмації. Звучить, коли збирається компанія — на фештах і весіллях. «Fešta» — далматинське слово «свято, гулянка».',
    words: [
      { hr: 'večeras', ua: 'сьогодні ввечері' },
      { hr: 'fešta', ua: 'свято, гулянка (Далмація)' },
      { hr: 'naš / naša', ua: 'наш / наша' },
      { hr: 'pjevati', ua: 'співати' },
      { hr: 'veselje', ua: 'радість, веселощі' },
    ],
    listen_query: 'Tomislav Ivčić Večeras je naša fešta',
  },
  {
    slug: 'kalelarga',
    title: 'Kalelarga',
    title_ua: 'Калеларга (головна вулиця Задара)',
    performer: 'Tomislav Ivčić',
    origin: 'Музика й слова — Tomislav Ivčić; уперше на альбомі «Dalmatinske noći» (1981)',
    about:
      'Пісня про Kalelargu — головну пішохідну вулицю старого Задара, де ввечері гуляють, зустрічаються й п’ють каву. Назва від італійського «calle larga» — «широка вулиця»; офіційно — Široka ulica.',
    words: [
      { hr: 'ulica', ua: 'вулиця' },
      { hr: 'širok / široka', ua: 'широкий / широка' },
      { hr: 'šetati', ua: 'гуляти, прогулюватися' },
      { hr: 'stari grad', ua: 'старе місто' },
      { hr: 'Zadar', ua: 'Задар' },
    ],
    listen_query: 'Tomislav Ivčić Kalelarga',
  },
  {
    slug: 'zadar-je-u-srcu-mome',
    title: 'Zadar je u srcu mome',
    title_ua: 'Задар у моєму серці',
    performer: 'Tomislav Bralić i Klapa Intrade (з Oliverom Dragojevićem — у парі з «Kalelargom»)',
    origin: 'Клапа — традиційний далматинський спів кількома голосами',
    about:
      'Пісня-освідчення рідному місту. Її часто співають разом із «Kalelargom», а виконує клапа — далматинський хор, який співає a cappella. Клапський спів внесено до списку нематеріальної спадщини ЮНЕСКО.',
    words: [
      { hr: 'srce', ua: 'серце' },
      { hr: 'u srcu mome', ua: 'у моєму серці' },
      { hr: 'grad', ua: 'місто' },
      { hr: 'klapa', ua: 'клапа (далматинський хор)' },
      { hr: 'more', ua: 'море' },
    ],
    listen_query: 'Zadar je u srcu mome Klapa Intrade',
  },
  {
    slug: 'croatio-iz-duse-te-ljubim',
    title: 'Croatio, iz duše te ljubim',
    title_ua: 'Хорватіє, всією душею тебе люблю',
    performer: 'Tomislav Bralić i Klapa Intrade',
    origin: 'Клапська пісня',
    about:
      'Патріотична пісня-освідчення Хорватії. Її співають на святах і концертах клап. «Iz duše» — дослівно «з душі», тобто щиро, всім серцем.',
    words: [
      { hr: 'duša', ua: 'душа' },
      { hr: 'iz duše', ua: 'від душі, щиро' },
      { hr: 'ljubiti', ua: 'любити; цілувати' },
      { hr: 'Hrvatska', ua: 'Хорватія' },
      { hr: 'domovina', ua: 'батьківщина' },
    ],
    listen_query: 'Croatio iz duše te ljubim Klapa Intrade',
  },
  {
    slug: 'da-te-mogu-pismom-zvati',
    title: 'Da te mogu pismom zvati',
    title_ua: 'Якби я міг кликати тебе піснею',
    performer: 'Klapa Maslina та інші клапи',
    origin: 'Далматинська лірична пісня',
    about:
      'Ніжна пісня про кохання. «Pisma» — далматинською «пісня» (літературною — «pjesma»): у Далмації часто кажуть «i» замість «je»: pisma, lipo, vik.',
    words: [
      { hr: 'pisma (pjesma)', ua: 'пісня (далм. / літ.)' },
      { hr: 'zvati', ua: 'кликати; називати' },
      { hr: 'lipo (lijepo)', ua: 'гарно (далм. / літ.)' },
      { hr: 'ljubav', ua: 'кохання' },
      { hr: 'more', ua: 'море' },
    ],
    listen_query: 'Da te mogu pismom zvati klapa',
  },
];

export function songBySlug(slug: unknown): Song | null {
  return typeof slug === 'string' ? SONGS.find((s) => s.slug === slug) ?? null : null;
}

/** Посилання «Послухати»: пошук на YouTube (не вбудовуємо чужі записи). */
export function listenUrl(song: Pick<Song, 'listen_query'>): string {
  return `https://www.youtube.com/results?search_query=${encodeURIComponent(song.listen_query)}`;
}
