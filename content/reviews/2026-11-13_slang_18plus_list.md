# Сленг і модуль «18+»: список слів зі звіркою з базою (2026-11-13)

> Статус: **кандидати на перевірку** (власник → носій). У базі нічого не змінено; звірка — запит лише на читання до робочої бази (2026-11-13 16:49).
> Рішення власника 2026-11-13: сленг — окремі модулі B1 / B2, не менше 300 одиниць, 5–7 уроків по 20–25, решта — тексти; модуль «18+» — 5 уроків у кінці B1, образливі слова про групи людей — включено (лише впізнавання), бета. План — `docs/proposals/2026-11-12_b1_b2_dialogues_reading_situations.md` §3а, §3б.
> Таблиці генерує `python3 -B scripts/gen_live_lexicon_20261113.py` (не редагуйте вручну); знімок бази — `scripts/live_lexicon_20261113_snapshot.json`.

## Коротко

| | Одиниць | Нових | Уже в базі | DEPRECATED у базі | Схоже написання |
|---|---|---|---|---|---|
| B1 · Сленг (6 уроків) | 138 | 129 | 7 | 2 | 0 |
| B2 · Živi hrvatski I (4 уроки) | 86 | 83 | 3 | 0 | 0 |
| Решта (тексти, діалоги, рубрика) | 80 | 64 | 16 | 0 | 0 |
| **Сленг і розмовне разом** | **304** | 276 | 26 | 2 | 0 |
| Сумнівні з прикладу власника (носію) | 22 | 22 | 0 | 0 | 0 |
| B1 · 18+ (5 уроків) | 109 | 106 | 3 | 0 | 0 |

- **«Уже в базі»** — лема є в `lexemes`. З іншим значенням (8: *stari*, *postati*, *hodati*, *riba*, *ono*, *konj*, *krava*, *komad*) — нове значення додаємо до наявної лексеми через `content_versions`, а не нову лему (`lower(lemma)` унікальний). З тим самим значенням — слово в уроці стає нагадуванням; розмітку звірити (у базі ще старі `regional` — їх нормалізує M24).
- **«нз», але в базі немає** (*lik, top, legenda, brijati…*) — нова лема одразу з обома значеннями: стандартне першим, сленгове — з позначкою.
- **DEPRECATED у базі** (*Kužiš?*, *nemam pojma* — колись прибрані як речення): повертаємо новою версією наявного рядка, а не новою лемою. У *Kužiš?* поле `normalized` з діакритиками й «?» (`kužiš?`) — помилка даних, виправити тим самим пакетом.
- **«?»** у примітці — 45 слів: перевірити носієм (чи вживають, значення, написання). Група «Сумнівні» — кальки з англійської з прикладу власника; у модулі — лише після «так» носія.
- Розмітка — модель §4.1 (`register` / `regionality` / `usage_tags`); `vulgar` — лише в модулі «18+», який видно після ввімкнення «Показувати контент 18+».
- Образи (тег `offensive`, затверджено 2026-11-13) — лише впізнавання: позначка «образа» на картці, чому образливо, нейтральний відповідник у примітці.
- Що змінено проти прикладу власника: прибрано стандартні слова (*žlica, kapa, kafić, dečko, teta, smijati se, kupanje, kartica, blokirati*); виправлено *Purger, katrida, buksna, kompir, pomidor*; додано розмовні слова, яких у прикладі не було (*fuš, rintati, nacvrcan, gablec, cajt…*), і лексику «18+».
- Далі: власник і носій переглядають список → батч слів (`croatian-lexeme-batch`: приклади, пояснення, форми) → уроки модулів (`lesson-topic-rebuild` / `level-build-croatia`).

## Список за уроками

### S1 · B1 · Сленг: живий хорватський — 1. Реакції й вигуки між друзями · 22

| № | Слово | Переклад | Частина мови | register | regionality | usage_tags | У базі | Примітка |
|---|---|---|---|---|---|---|---|---|
| 1 | *ajde* | давай; ну; ходімо | interjection | `informal` | `general` | {} | немає | вживати |
| 2 | *ma daj* | та ну; не може бути | phrase | `colloquial` | `general` | {} | немає | вживати |
| 3 | *ma nemoj* | та невже; не кажи | phrase | `colloquial` | `general` | {} | немає |  |
| 4 | *nema šanse* | нізащо; без шансів | phrase | `colloquial` | `general` | {} | немає | вживати |
| 5 | *nema frke* | без проблем; не хвилюйся | phrase | `colloquial` | `general` | {} | немає | вживати |
| 6 | *kako god* | як скажеш; байдуже | phrase | `colloquial` | `general` | {} | немає |  |
| 7 | *nemam pojma* | гадки не маю | phrase | `colloquial` | `general` | {} | DEPRECATED A1: «Я не маю гадки / По без поняття» → повернути новою версією (`content_versions`), не нова лема | вживати |
| 8 | *sve pet* | усе чудово; на п'ять | phrase | `colloquial` | `general` | {} | немає |  |
| 9 | *fakat* | справді; реально | adverb | `colloquial` | `general` | {} | немає |  |
| 10 | *joj* | ой | interjection | `informal` | `general` | {} | немає |  |
| 11 | *ajme* | ой леле; ой | interjection | `colloquial` | `general` | {} | немає |  |
| 12 | *bome* | ще й як; авжеж | particle | `colloquial` | `general` | {} | немає |  |
| 13 | *kužiti* | розуміти; «шарити» | verb | `colloquial` | `general` | {} | немає |  |
| 14 | *skužiti* | допетрати; зрозуміти | verb | `colloquial` | `general` | {} | немає |  |
| 15 | *kužiš?* | розумієш?; шариш? | phrase | `colloquial` | `general` | {} | DEPRECATED A0: «Січеш? / Розумієш?» → повернути новою версією (`content_versions`), не нова лема |  |
| 16 | *strava* | жах; жахіття | noun | `colloquial` | `general` | {} | немає | ? у молоді буває й «супер» |
| 17 | *koma* | кошмар; жах (про стан, ситуацію) | noun | `slang` | `general` | youth_slang | немає → одна лема з обома значеннями (стандартне першим) | нз (кома) |
| 18 | *bezveze* | безглуздо; ні про що | adverb | `colloquial` | `general` | {} | немає |  |
| 19 | *svaka čast* | респект; молодець | phrase | `colloquial` | `general` | {} | немає | вживати |
| 20 | *boli me briga* | мені байдуже | phrase | `colloquial` | `general` | {} | немає | пом'якшене (грубе — у «18+») |
| 21 | *ma pusti* | та облиш; не зважай | phrase | `colloquial` | `general` | {} | немає |  |
| 22 | *opusti se* | розслабся; не нервуй | phrase | `informal` | `general` | {} | немає |  |

### S2 · B1 · Сленг: живий хорватський — 2. Люди й звертання · 23

| № | Слово | Переклад | Частина мови | register | regionality | usage_tags | У базі | Примітка |
|---|---|---|---|---|---|---|---|---|
| 1 | *stari* | старий; чувак (звертання до друга) | noun | `colloquial` | `general` | {} | є з іншим значенням — A1: «старий» → додати значення до наявної лексеми | нз (stari — старий) |
| 2 | *stara* | мама; подруга (розм.) | noun | `colloquial` | `general` | {} | немає → одна лема з обома значеннями (стандартне першим) | нз |
| 3 | *starci* | батьки; «предки» | noun | `colloquial` | `general` | {} | немає |  |
| 4 | *buraz* | братан; бро | noun | `slang` | `general` | turkism | немає |  |
| 5 | *brate* | брате; братан (звертання) | interjection | `colloquial` | `general` | {} | немає | кличний від brat |
| 6 | *frend* | друг; кореш | noun | `slang` | `general` | youth_slang, anglicism | немає |  |
| 7 | *frendica* | подруга | noun | `slang` | `general` | youth_slang, anglicism | немає |  |
| 8 | *ekipa* | компанія друзів; тусовка | noun | `colloquial` | `general` | {} | немає → одна лема з обома значеннями (стандартне першим) | нз (команда) |
| 9 | *škvadra* | компанія; банда (друзів) | noun | `colloquial` | `general` | italianism | немає |  |
| 10 | *lik* | тип; персонаж (про людину) | noun | `slang` | `general` | {} | немає → одна лема з обома значеннями (стандартне першим) | нз (образ, фігура) |
| 11 | *tip* | чувак; хлопець | noun | `colloquial` | `general` | {} | немає → одна лема з обома значеннями (стандартне першим) | нз (тип) |
| 12 | *cura* | дівчина; кохана | noun | `colloquial` | `general` | {} | є — A0: «дівчина (романтично)» · `colloquial` → нагадування; розмітку звірити |  |
| 13 | *klinac* | малий; дитина | noun | `colloquial` | `general` | {} | немає |  |
| 14 | *klinka* | мала; дівчинка | noun | `colloquial` | `general` | {} | немає |  |
| 15 | *frajer* | крутий хлопець; хлопець | noun | `colloquial` | `general` | germanism | немає |  |
| 16 | *faca* | важна персона; «фейс» | noun | `colloquial` | `general` | italianism | немає |  |
| 17 | *štreber* | зубрила; ботанік | noun | `colloquial` | `general` | germanism | немає |  |
| 18 | *papak* | лох; селюк | noun | `slang` | `Zagreb` | offensive | немає | образливе |
| 19 | *papučar* | підкаблучник | noun | `colloquial` | `general` | {} | немає |  |
| 20 | *šminker* | модник; мажор | noun | `slang` | `Zagreb` | germanism | немає |  |
| 21 | *gazda* | хазяїн; бос | noun | `colloquial` | `general` | {} | немає |  |
| 22 | *legenda* | молодець; легенда (про людину) | noun | `colloquial` | `general` | {} | немає → одна лема з обома значеннями (стандартне першим) | нз (легенда) |
| 23 | *kralj* | красень; король (похвала) | noun | `colloquial` | `general` | {} | немає → одна лема з обома значеннями (стандартне першим) | нз (король) |

### S3 · B1 · Сленг: живий хорватський — 3. Гроші, робота, навчання · 22

| № | Слово | Переклад | Частина мови | register | regionality | usage_tags | У базі | Примітка |
|---|---|---|---|---|---|---|---|---|
| 1 | *lova* | гроші; бабло | noun | `slang` | `general` | {} | немає |  |
| 2 | *kinta* | гроші; копійки | noun | `slang` | `general` | {} | немає |  |
| 3 | *keš* | готівка; кеш | noun | `slang` | `general` | anglicism | немає |  |
| 4 | *som* | тисяча (євро) | noun | `slang` | `general` | {} | немає → одна лема з обома значеннями (стандартне першим) | нз (сом) |
| 5 | *cener* | десятка (десять євро) | noun | `slang` | `Zagreb` | germanism | немає |  |
| 6 | *šljaka* | робота; гарування | noun | `slang` | `general` | {} | немає |  |
| 7 | *šljakati* | працювати; гарувати | verb | `slang` | `general` | {} | немає |  |
| 8 | *rintati* | тяжко працювати; горбатитися | verb | `colloquial` | `general` | {} | немає |  |
| 9 | *fuš* | халтура; підробіток | noun | `colloquial` | `general` | germanism | немає |  |
| 10 | *fušati* | халтурити; підробляти | verb | `colloquial` | `general` | germanism | немає |  |
| 11 | *šverc* | контрабанда; «чорна» торгівля | noun | `colloquial` | `general` | germanism | немає |  |
| 12 | *na crno* | неофіційно; «в чорну» | phrase | `colloquial` | `general` | idiom | немає |  |
| 13 | *bauštela* | будова; будмайданчик | noun | `colloquial` | `general` | germanism | немає |  |
| 14 | *faks* | університет; факультет | noun | `colloquial` | `general` | {} | немає |  |
| 15 | *štrebati* | зубрити | verb | `colloquial` | `general` | germanism | немає |  |
| 16 | *markirati* | прогулювати (уроки, пари) | verb | `colloquial` | `general` | {} | є — A2: «прогулювати (уроки)» · `colloquial` → нагадування; розмітку звірити | у базі вже це значення |
| 17 | *kiks* | промах; провал | noun | `slang` | `general` | {} | немає |  |
| 18 | *fulati* | схибити; помилитися | verb | `colloquial` | `general` | {} | немає |  |
| 19 | *zeznuti* | напартачити; обдурити | verb | `colloquial` | `general` | {} | немає |  |
| 20 | *zeznuti se* | помилитися; схибити | verb | `colloquial` | `general` | {} | немає |  |
| 21 | *mobić* | мобільник | noun | `colloquial` | `general` | {} | немає |  |
| 22 | *kompić* | комп; компік | noun | `colloquial` | `general` | {} | немає |  |

### S4 · B1 · Сленг: живий хорватський — 4. Вечірка, їжа, напої · 21

| № | Слово | Переклад | Частина мови | register | regionality | usage_tags | У базі | Примітка |
|---|---|---|---|---|---|---|---|---|
| 1 | *cuga* | випивка; алкоголь | noun | `slang` | `general` | germanism | немає |  |
| 2 | *cugati* | випивати; бухати | verb | `slang` | `general` | germanism | немає |  |
| 3 | *tulum* | вечірка (вдома); тусовка | noun | `colloquial` | `general` | {} | немає |  |
| 4 | *tulumariti* | гуляти на вечірці; тусуватися | verb | `colloquial` | `general` | {} | немає |  |
| 5 | *klopa* | їжа; харчі | noun | `slang` | `general` | {} | немає |  |
| 6 | *klopati* | їсти; хавати | verb | `slang` | `general` | {} | немає |  |
| 7 | *pljuga* | цигарка | noun | `slang` | `general` | {} | немає |  |
| 8 | *birtija* | забігайлівка; простий бар | noun | `colloquial` | `general` | germanism | немає |  |
| 9 | *špricer* | вино з содовою | noun | `colloquial` | `general` | germanism | немає |  |
| 10 | *runda* | коло (випивки за рахунок одного) | noun | `colloquial` | `general` | {} | немає |  |
| 11 | *mamuran* | з похмілля | adjective | `colloquial` | `general` | {} | немає |  |
| 12 | *pijan kao čep* | п'яний як чіп | phrase | `colloquial` | `general` | idiom | немає |  |
| 13 | *nacvrcan* | підпилий; напідпитку | adjective | `colloquial` | `general` | {} | немає |  |
| 14 | *ludnica* | шалено; божевілля (весело) | noun | `colloquial` | `general` | {} | немає |  |
| 15 | *đuskati* | танцювати; витанцьовувати | verb | `colloquial` | `general` | {} | немає |  |
| 16 | *kavica* | кавочка | noun | `informal` | `general` | {} | немає | вживати (Idemo na kavicu) |
| 17 | *pivce* | пивко | noun | `informal` | `general` | {} | немає |  |
| 18 | *zezati* | підколювати; жартувати з когось | verb | `colloquial` | `general` | {} | немає |  |
| 19 | *zezancija* | прикол; жарти | noun | `colloquial` | `general` | {} | немає |  |
| 20 | *fora* | прикол; фішка | noun | `slang` | `general` | {} | немає |  |
| 21 | *štos* | прикол; фокус; дотеп | noun | `colloquial` | `general` | germanism | немає |  |

### S5 · B1 · Сленг: живий хорватський — 5. Загреб: пургерський сленг · 25

| № | Слово | Переклад | Частина мови | register | regionality | usage_tags | У базі | Примітка |
|---|---|---|---|---|---|---|---|---|
| 1 | *kaj* | що | pronoun | `colloquial` | `Zagreb` | kajkavian | немає |  |
| 2 | *kaj ima?* | що нового?; як справи? | phrase | `colloquial` | `Zagreb` | kajkavian | немає |  |
| 3 | *kak* | як | adverb | `colloquial` | `Zagreb` | kajkavian | немає |  |
| 4 | *kam* | куди | adverb | `colloquial` | `Zagreb` | kajkavian | немає |  |
| 5 | *purger* | корінний загребчанин | noun | `colloquial` | `Zagreb` | germanism | немає | у списку власника — «Perger», правильно Purger |
| 6 | *špica* | суботня прогулянка в центрі Загреба | noun | `colloquial` | `Zagreb` | {} | немає → одна лема з обома значеннями (стандартне першим) | нз (вершина; час пік) |
| 7 | *gablec* | ранній обід; перекус | noun | `colloquial` | `Zagreb` | kajkavian | є — A1: «гарячий обід на роботі (загреб.)» · `colloquial` → нагадування; розмітку звірити |  |
| 8 | *gemišt* | біле вино з газованою водою | noun | `colloquial` | `Zagreb` | {} | є — A0: «гемішт (біле вино з газованою мінеральною водою)» → нагадування; розмітку звірити |  |
| 9 | *fajn* | гарно; добре; файно | adverb | `colloquial` | `Zagreb` | germanism | немає |  |
| 10 | *ziher* | точно; напевно | adverb | `colloquial` | `Zagreb` | germanism | немає |  |
| 11 | *cug* | потяг; протяг | noun | `colloquial` | `Zagreb` | germanism | немає |  |
| 12 | *cajt* | час | noun | `colloquial` | `Zagreb` | germanism | немає | Nemam cajta. |
| 13 | *fertik* | готово; закінчено | adjective | `colloquial` | `Zagreb` | germanism | немає |  |
| 14 | *šlampav* | неохайний; недбалий | adjective | `colloquial` | `general` | germanism | немає |  |
| 15 | *šlag* | збиті вершки | noun | `colloquial` | `Zagreb` | germanism | є — A0: «збиті вершки» → нагадування; розмітку звірити |  |
| 16 | *špajza* | комора | noun | `colloquial` | `Zagreb` | germanism | немає |  |
| 17 | *vešmašina* | пральна машина | noun | `colloquial` | `Zagreb` | germanism | немає |  |
| 18 | *šparati* | економити; відкладати | verb | `colloquial` | `Zagreb` | germanism | немає |  |
| 19 | *flaša* | пляшка | noun | `colloquial` | `general` | germanism | немає |  |
| 20 | *pajdaš* | приятель; дружбан | noun | `colloquial` | `Zagreb` | {} | немає |  |
| 21 | *čaga* | танці; вечірка | noun | `slang` | `Zagreb` | {} | немає |  |
| 22 | *brija* | тема; настрій; тусовка | noun | `slang` | `Zagreb` | {} | немає |  |
| 23 | *brijati* | думати, вважати; тусуватися | verb | `slang` | `Zagreb` | {} | немає → одна лема з обома значеннями (стандартне першим) | нз (голити) |
| 24 | *špreha* | балачка; вміння заговорити | noun | `slang` | `Zagreb` | germanism | немає | ? |
| 25 | *dečec* | хлопчик | noun | `colloquial` | `Zagorje` | kajkavian | немає |  |

### S6 · B1 · Сленг: живий хорватський — 6. Далмація: сленг узбережжя · 25

| № | Слово | Переклад | Частина мови | register | regionality | usage_tags | У базі | Примітка |
|---|---|---|---|---|---|---|---|---|
| 1 | *ča* | що | pronoun | `colloquial` | `Dalmatia` | chakavian | немає | також Істрія, Кварнер, острови |
| 2 | *di* | де | adverb | `colloquial` | `Dalmatia` | {} | немає | також по всій країні в розмові (Di si) |
| 3 | *đir* | прогулянка; коло; поїздка | noun | `colloquial` | `Dalmatia` | italianism | немає |  |
| 4 | *ćakula* | балачка; плітки | noun | `colloquial` | `Dalmatia` | italianism | немає |  |
| 5 | *ćakulati* | базікати | verb | `colloquial` | `Dalmatia` | italianism | немає |  |
| 6 | *šoldi* | гроші | noun | `colloquial` | `Dalmatia` | italianism | немає |  |
| 7 | *fešta* | свято; гулянка | noun | `colloquial` | `Dalmatia` | italianism | немає |  |
| 8 | *bevanda* | вино, розбавлене водою | noun | `colloquial` | `Dalmatia` | italianism | є — A0: «беванда (вино зі звичайною водою; Далмація)» → нагадування; розмітку звірити |  |
| 9 | *balun* | м'яч; футбол | noun | `colloquial` | `Dalmatia` | italianism | немає |  |
| 10 | *furešti* | туристи; чужинці | noun | `colloquial` | `Dalmatia` | italianism | немає |  |
| 11 | *vlaj* | житель Загори (не з узбережжя) | noun | `colloquial` | `Dalmatia` | {} | немає | буває зневажливо |
| 12 | *bodul* | острів'янин | noun | `colloquial` | `Dalmatia` | {} | немає |  |
| 13 | *barba* | дядько; звертання до старшого чоловіка | noun | `colloquial` | `Dalmatia` | italianism | немає |  |
| 14 | *nono* | дідусь | noun | `colloquial` | `Dalmatia` | italianism | немає |  |
| 15 | *nona* | бабуся | noun | `colloquial` | `Dalmatia` | italianism | немає |  |
| 16 | *ćaća* | тато | noun | `colloquial` | `Dalmatia` | {} | немає |  |
| 17 | *mulac* | хлопчина; шибеник | noun | `colloquial` | `Dalmatia` | {} | немає |  |
| 18 | *mandrilo* | бовдур (жартома) | noun | `colloquial` | `Dalmatia` | {} | немає |  |
| 19 | *priša* | поспіх | noun | `colloquial` | `Dalmatia` | italianism | немає |  |
| 20 | *nema priše* | не поспішай; немає поспіху | phrase | `colloquial` | `Dalmatia` | italianism | немає |  |
| 21 | *lipo* | гарно | adverb | `colloquial` | `Dalmatia` | {} | немає | ікавське: стандартно lijepo |
| 22 | *škovace* | сміття | noun | `colloquial` | `Dalmatia` | italianism | немає |  |
| 23 | *bonaca* | штиль (на морі) | noun | `colloquial` | `Dalmatia` | italianism | немає |  |
| 24 | *kaleta* | вузька кам'яна вуличка | noun | `colloquial` | `Dalmatia` | {} | немає |  |
| 25 | *peškarija* | рибний ринок | noun | `colloquial` | `Dalmatia` | italianism | немає |  |

### Z1 · B2 · Živi hrvatski I — 1. Інтернет і соцмережі · 22

| № | Слово | Переклад | Частина мови | register | regionality | usage_tags | У базі | Примітка |
|---|---|---|---|---|---|---|---|---|
| 1 | *lajk* | лайк; вподобайка | noun | `slang` | `general` | internet_slang, anglicism | немає |  |
| 2 | *lajkati* | лайкати; вподобати | verb | `slang` | `general` | internet_slang, anglicism | немає |  |
| 3 | *šerati* | поширювати; шерити | verb | `slang` | `general` | internet_slang, anglicism | немає |  |
| 4 | *folovati* | підписатися (у соцмережі) | verb | `slang` | `general` | internet_slang, anglicism | немає |  |
| 5 | *anfolovati* | відписатися | verb | `slang` | `general` | internet_slang, anglicism | немає |  |
| 6 | *skrolati* | гортати стрічку | verb | `slang` | `general` | internet_slang, anglicism | немає |  |
| 7 | *postati* | публікувати допис; постити | verb | `slang` | `general` | internet_slang, anglicism | є з іншим значенням — A1: «стати (кимось, чимось)» → додати значення до наявної лексеми | нз (стати) |
| 8 | *storij* | сторіз (в Instagram) | noun | `slang` | `general` | internet_slang, anglicism | немає | ? написання |
| 9 | *mem* | мем | noun | `slang` | `general` | internet_slang, anglicism | немає | ? написання |
| 10 | *viralan* | вірусний (популярний у мережі) | adjective | `colloquial` | `general` | internet_slang | немає |  |
| 11 | *influenser* | інфлюенсер | noun | `colloquial` | `general` | anglicism | немає |  |
| 12 | *trol* | троль (в інтернеті) | noun | `slang` | `general` | internet_slang, anglicism | немає |  |
| 13 | *trolati* | тролити | verb | `slang` | `general` | internet_slang, anglicism | немає |  |
| 14 | *hejt* | хейт; цькування | noun | `slang` | `general` | internet_slang, anglicism | немає |  |
| 15 | *hejtati* | хейтити | verb | `slang` | `general` | internet_slang, anglicism | немає |  |
| 16 | *hejter* | хейтер | noun | `slang` | `general` | internet_slang, anglicism | немає |  |
| 17 | *gejmati* | грати у відеоігри | verb | `slang` | `general` | youth_slang, anglicism | немає | ? написання (gamati) |
| 18 | *gejmer* | геймер | noun | `slang` | `general` | youth_slang, anglicism | немає |  |
| 19 | *nub* | нуб; новачок | noun | `slang` | `general` | internet_slang, anglicism | немає |  |
| 20 | *čekirati* | перевірити; зачекінитись | verb | `slang` | `general` | anglicism | немає |  |
| 21 | *guglati* | гуглити | verb | `colloquial` | `general` | internet_slang, anglicism | немає | ? guglati / guglati |
| 22 | *apdejt* | оновлення; апдейт | noun | `slang` | `general` | internet_slang, anglicism | немає | ? написання |

### Z2 · B2 · Živi hrvatski I — 2. Молодіжний сленг · 22

| № | Слово | Переклад | Частина мови | register | regionality | usage_tags | У базі | Примітка |
|---|---|---|---|---|---|---|---|---|
| 1 | *krindž* | кринж; іспанський сором | noun | `slang` | `general` | youth_slang, anglicism | немає |  |
| 2 | *fleksati* | хизуватися; понтуватися | verb | `slang` | `general` | youth_slang, anglicism | немає |  |
| 3 | *čilati* | чілити; відпочивати | verb | `slang` | `general` | youth_slang, anglicism | немає |  |
| 4 | *vajb* | вайб; атмосфера | noun | `slang` | `general` | youth_slang, anglicism | немає |  |
| 5 | *hajp* | хайп; ажіотаж | noun | `slang` | `general` | youth_slang, anglicism | немає |  |
| 6 | *fejk* | фейк; підробка | noun | `slang` | `general` | internet_slang, anglicism | немає | є в рубриці B1.7 |
| 7 | *random* | випадковий; рандомний | adjective | `slang` | `general` | youth_slang, anglicism | немає |  |
| 8 | *kraš* | краш; об'єкт симпатії | noun | `slang` | `general` | youth_slang, anglicism | немає |  |
| 9 | *gaser* | гасер (хлопець у брендовому спортивному, реп) | noun | `slang` | `general` | youth_slang | немає |  |
| 10 | *gaserka* | гасерка | noun | `slang` | `general` | youth_slang | немає |  |
| 11 | *smor* | нудьга; нудна людина | noun | `slang` | `general` | youth_slang | немає |  |
| 12 | *smarati* | набридати; занудствувати | verb | `slang` | `general` | youth_slang | немає |  |
| 13 | *bro* | бро; братан | noun | `slang` | `general` | youth_slang, anglicism | немає |  |
| 14 | *toksičan* | токсичний (про людину, стосунки) | adjective | `colloquial` | `general` | youth_slang | немає |  |
| 15 | *ludilo* | супер; божевілля (захват) | noun | `colloquial` | `general` | {} | немає → одна лема з обома значеннями (стандартне першим) | нз (божевілля) |
| 16 | *top* | топ; найкраще | adjective | `slang` | `general` | youth_slang, anglicism | немає → одна лема з обома значеннями (стандартне першим) | нз (гармата) |
| 17 | *šema* | тема; схема; план | noun | `slang` | `general` | {} | немає |  |
| 18 | *daj gas* | давай, жени; погнали | phrase | `slang` | `general` | youth_slang | немає |  |
| 19 | *zbediran* | пригнічений; засмучений | adjective | `slang` | `general` | youth_slang | немає |  |
| 20 | *depra* | депресуха; поганий настрій | noun | `slang` | `general` | youth_slang | немає |  |
| 21 | *bejsik* | банальний; звичайний | adjective | `slang` | `general` | youth_slang, anglicism | немає | ? |
| 22 | *izblamirati se* | зганьбитися; осоромитися | verb | `colloquial` | `general` | {} | немає |  |

### Z3 · B2 · Živi hrvatski I — 3. Почуття, оцінки, стосунки · 21

| № | Слово | Переклад | Частина мови | register | regionality | usage_tags | У базі | Примітка |
|---|---|---|---|---|---|---|---|---|
| 1 | *blam* | ганьба; сором | noun | `slang` | `general` | youth_slang | немає |  |
| 2 | *puknuti* | зірватися; не витримати | verb | `colloquial` | `general` | {} | немає → одна лема з обома значеннями (стандартне першим) | нз (тріснути) |
| 3 | *štanga* | облом; невдача | noun | `slang` | `general` | {} | немає → одна лема з обома значеннями (стандартне першим) | нз (штанга) |
| 4 | *nabrijan* | заведений; налаштований | adjective | `slang` | `general` | {} | немає |  |
| 5 | *skulirati se* | заспокоїтися; охолонути | verb | `slang` | `general` | anglicism | немає |  |
| 6 | *kul* | круто; спокійно | adjective | `slang` | `general` | youth_slang, anglicism | немає |  |
| 7 | *furati* | носити (стиль); гнати | verb | `slang` | `general` | {} | немає |  |
| 8 | *fura* | стиль; фішка | noun | `slang` | `general` | {} | немає |  |
| 9 | *frik* | фанат; «фрік» (чогось) | noun | `slang` | `general` | anglicism | немає |  |
| 10 | *muvati* | клеїти; фліртувати | verb | `slang` | `general` | {} | немає |  |
| 11 | *smuvati* | закадрити | verb | `slang` | `general` | {} | немає |  |
| 12 | *hodati* | зустрічатися (з кимось) | verb | `colloquial` | `general` | {} | є з іншим значенням — A1: «ходити» → додати значення до наявної лексеми | нз (ходити) |
| 13 | *šutnuti* | кинути (хлопця, дівчину) | verb | `colloquial` | `general` | {} | немає → одна лема з обома значеннями (стандартне першим) | нз (копнути) |
| 14 | *ljubakati se* | цілуватися; обійматися | verb | `colloquial` | `general` | {} | немає |  |
| 15 | *riba* | гарна дівчина | noun | `slang` | `general` | {} | є з іншим значенням — A0: «риба» → додати значення до наявної лексеми | нз (риба); може звучати зневажливо |
| 16 | *frajerski* | круто; по-пацанськи | adverb | `colloquial` | `general` | {} | немає |  |
| 17 | *zeznut* | складний; хитрий | adjective | `colloquial` | `general` | {} | немає |  |
| 18 | *ljut kao ris* | злий як чорт | phrase | `colloquial` | `general` | idiom | немає |  |
| 19 | *crknuti* | здохнути (від утоми); зламатися | verb | `colloquial` | `general` | {} | немає |  |
| 20 | *krepati* | здохнути; дуже втомитися | verb | `colloquial` | `general` | italianism | немає |  |
| 21 | *ispaliti* | підвести; не прийти | verb | `colloquial` | `general` | {} | немає → одна лема з обома значеннями (стандартне першим) | нз (вистрілити) |

### Z4 · B2 · Živi hrvatski I — 4. Англіцизми в розмові й на роботі · 21

| № | Слово | Переклад | Частина мови | register | regionality | usage_tags | У базі | Примітка |
|---|---|---|---|---|---|---|---|---|
| 1 | *mejl* | імейл; лист | noun | `colloquial` | `general` | professional_jargon, anglicism | немає |  |
| 2 | *mejlati* | писати імейл | verb | `colloquial` | `general` | professional_jargon, anglicism | немає |  |
| 3 | *miting* | нарада; мітинг | noun | `colloquial` | `general` | professional_jargon, anglicism | немає |  |
| 4 | *dedlajn* | дедлайн; крайній строк | noun | `colloquial` | `general` | professional_jargon, anglicism | немає |  |
| 5 | *fidbek* | відгук; фідбек | noun | `colloquial` | `general` | professional_jargon, anglicism | немає |  |
| 6 | *task* | завдання; таска | noun | `slang` | `general` | professional_jargon, anglicism | немає | ? |
| 7 | *brifing* | брифінг; короткий інструктаж | noun | `colloquial` | `general` | professional_jargon, anglicism | немає |  |
| 8 | *kol* | дзвінок; відеодзвінок (call) | noun | `slang` | `general` | professional_jargon, anglicism | немає | ? |
| 9 | *hendlati* | розрулювати; впоратися | verb | `slang` | `general` | professional_jargon, anglicism | немає |  |
| 10 | *brejnstorming* | мозковий штурм | noun | `colloquial` | `general` | professional_jargon, anglicism | немає | ? написання |
| 11 | *netvorking* | нетворкінг | noun | `colloquial` | `general` | professional_jargon, anglicism | немає |  |
| 12 | *frilenser* | фрилансер | noun | `colloquial` | `general` | professional_jargon, anglicism | немає |  |
| 13 | *startap* | стартап | noun | `colloquial` | `general` | professional_jargon, anglicism | немає |  |
| 14 | *dil* | угода; домовленість | noun | `slang` | `general` | anglicism | немає |  |
| 15 | *apgrejd* | апгрейд; покращення | noun | `slang` | `general` | anglicism | немає |  |
| 16 | *kopipejstati* | копіювати й вставляти | verb | `slang` | `general` | anglicism | немає |  |
| 17 | *printati* | друкувати (на принтері) | verb | `colloquial` | `general` | anglicism | немає |  |
| 18 | *lajv* | наживо; прямий ефір | noun | `slang` | `general` | anglicism | немає |  |
| 19 | *biznis* | бізнес; справа | noun | `colloquial` | `general` | anglicism | немає |  |
| 20 | *event* | захід; івент | noun | `colloquial` | `general` | professional_jargon, anglicism | немає |  |
| 21 | *koučing* | коучинг | noun | `colloquial` | `general` | professional_jargon, anglicism | немає |  |

### R · Тексти, діалоги, рубрика «Živi hrvatski» — Решта: регіональні слова, нагадування, розмовне · 80

| № | Слово | Переклад | Частина мови | register | regionality | usage_tags | У базі | Примітка |
|---|---|---|---|---|---|---|---|---|
| 1 | *furešt* | приїжджий; чужинець | noun | `colloquial` | `Dalmatia` | italianism | немає |  |
| 2 | *škura* | віконниця | noun | `colloquial` | `Dalmatia` | italianism | немає |  |
| 3 | *pjat* | тарілка | noun | `colloquial` | `Dalmatia` | italianism | немає | ? pjat / pijat |
| 4 | *pirun* | виделка | noun | `colloquial` | `Dalmatia` | italianism | немає |  |
| 5 | *kušin* | подушка | noun | `colloquial` | `Dalmatia` | italianism | немає |  |
| 6 | *bičve* | шкарпетки | noun | `colloquial` | `Dalmatia` | {} | немає |  |
| 7 | *postole* | туфлі; взуття | noun | `colloquial` | `Dalmatia` | italianism | немає |  |
| 8 | *takujin* | гаманець | noun | `colloquial` | `Dalmatia` | italianism | немає |  |
| 9 | *katrida* | стілець | noun | `colloquial` | `Dalmatia` | italianism | немає | у списку власника — «Katridu» |
| 10 | *mula* | дівчисько | noun | `colloquial` | `Dalmatia` | {} | немає |  |
| 11 | *libar* | книжка | noun | `colloquial` | `Dalmatia` | italianism | немає |  |
| 12 | *škifo* | гидота; бридко | noun | `colloquial` | `Dalmatia` | italianism | немає |  |
| 13 | *kužina* | кухня | noun | `colloquial` | `Dalmatia` | italianism | немає |  |
| 14 | *šporko* | брудно | adverb | `colloquial` | `Dalmatia` | italianism | немає |  |
| 15 | *armerun* | шафа | noun | `colloquial` | `Dalmatia` | italianism | немає |  |
| 16 | *kantun* | кут; ріг (вулиці) | noun | `colloquial` | `Dalmatia` | italianism | немає |  |
| 17 | *ponistra* | вікно | noun | `colloquial` | `Dalmatia` | italianism | немає |  |
| 18 | *skala* | сходи | noun | `colloquial` | `Dalmatia` | italianism | немає → одна лема з обома значеннями (стандартне першим) | нз (шкала) |
| 19 | *tovar* | осел | noun | `colloquial` | `Dalmatia` | {} | немає → одна лема з обома значеннями (стандартне першим) | нз (вантаж) |
| 20 | *mudante* | труси | noun | `colloquial` | `Dalmatia` | italianism | немає |  |
| 21 | *kompir* | картопля | noun | `colloquial` | `Dalmatia` | {} | немає | у списку власника — «Kumpir» (так радше на континенті) |
| 22 | *mater* | мати; мама | noun | `colloquial` | `general` | {} | немає |  |
| 23 | *pazar* | ринок; базар | noun | `colloquial` | `general` | turkism | немає |  |
| 24 | *banak* | прилавок; барна стійка | noun | `colloquial` | `Dalmatia` | italianism | немає |  |
| 25 | *lešo* | варений (про м'ясо, рибу) | adjective | `colloquial` | `Dalmatia` | italianism | немає |  |
| 26 | *fjaka* | солодка лінь; млявість | noun | `colloquial` | `Dalmatia` | italianism | є — A1: «фяка (стан ліні через спеку)» · `colloquial` → нагадування; розмітку звірити | нагадування |
| 27 | *pomalo* | потихеньку; без поспіху | adverb | `colloquial` | `Dalmatia` | {} | є — A0: «помаленьку / не поспішай» → нагадування; розмітку звірити | нагадування |
| 28 | *gušt* | задоволення; кайф | noun | `colloquial` | `Dalmatia` | italianism | є — A0: «задоволення / кайф» · `colloquial` → нагадування; розмітку звірити | нагадування |
| 29 | *marenda* | другий сніданок; перекус | noun | `colloquial` | `Dalmatia` | italianism | є — A1: «перекус / пізній сніданок» · `colloquial` → нагадування; розмітку звірити | нагадування |
| 30 | *spiza* | продукти; харчі | noun | `colloquial` | `Dalmatia` | italianism | є — A0: «продукти / їжа» · `colloquial` → нагадування; розмітку звірити | нагадування |
| 31 | *riva* | набережна | noun | `standard` | `Dalmatia` | italianism | є — A0: «набережна» → нагадування; розмітку звірити | нагадування |
| 32 | *bura* | бура (північний вітер) | noun | `standard` | `Dalmatia` | {} | є — A0: «бура (сильний північний вітер)» → нагадування; розмітку звірити | нагадування |
| 33 | *jugo* | юг (південний вітер) | noun | `standard` | `Dalmatia` | {} | є — A0: «юго (південний вітер)» → нагадування; розмітку звірити | нагадування |
| 34 | *ae* | так; ну давай | interjection | `slang` | `Dalmatia` | {} | є — A2: «так, ага (регіонально: Далмація; сленг)» · `slang` → нагадування; розмітку звірити | нагадування |
| 35 | *kapula* | цибуля | noun | `colloquial` | `Dalmatia` | italianism | є — A2: «цибуля (регіонально: Далмація, діалект; стандартно — luk)» · `regional` → нагадування; розмітку звірити | нагадування |
| 36 | *pomidor* | помідор | noun | `colloquial` | `Dalmatia` | italianism | є — A2: «помідор (регіонально: Далмація, діалект; стандартно — rajčica)» · `regional` → нагадування; розмітку звірити | нагадування; у списку власника — «Pomidora» |
| 37 | *šugaman* | рушник | noun | `colloquial` | `Dalmatia` | italianism | є — A2: «рушник (регіонально: Далмація, діалект; стандартно — ručnik)» · `regional` → нагадування; розмітку звірити | нагадування |
| 38 | *murja* | поліція; копи | noun | `slang` | `general` | {} | немає |  |
| 39 | *pandur* | мент; поліцейський | noun | `slang` | `general` | {} | немає |  |
| 40 | *trafika* | газетний кіоск | noun | `colloquial` | `Zagreb` | germanism | немає |  |
| 41 | *cinkati* | стукати; здавати когось | verb | `slang` | `general` | {} | немає |  |
| 42 | *cinker* | стукач | noun | `slang` | `general` | {} | немає |  |
| 43 | *zbrisati* | втекти; звалити | verb | `colloquial` | `general` | {} | немає → одна лема з обома значеннями (стандартне першим) | нз (стерти) |
| 44 | *magla!* | вали звідси!; зникни! | interjection | `slang` | `Zagreb` | {} | немає → одна лема з обома значеннями (стандартне першим) | нз (туман) |
| 45 | *kvart* | район (міста) | noun | `colloquial` | `general` | {} | є — A0: «район (міста)» · `colloquial` → нагадування; розмітку звірити | у базі вже це значення |
| 46 | *gajba* | хата; квартира | noun | `slang` | `general` | {} | немає → одна лема з обома значеннями (стандартне першим) | нз (ящик) |
| 47 | *šora* | бійка | noun | `slang` | `Zagreb` | {} | немає |  |
| 48 | *šiht* | зміна (на роботі) | noun | `colloquial` | `Zagreb` | germanism | немає |  |
| 49 | *rikverc* | задній хід | noun | `colloquial` | `Zagreb` | germanism | немає |  |
| 50 | *štengice* | сходинки; сходи | noun | `colloquial` | `Zagreb` | germanism | немає |  |
| 51 | *auspuh* | вихлопна труба | noun | `colloquial` | `general` | germanism | немає |  |
| 52 | *bremze* | гальма | noun | `colloquial` | `Zagreb` | germanism | немає |  |
| 53 | *cvikeri* | окуляри | noun | `colloquial` | `Zagreb` | germanism | немає |  |
| 54 | *šnajder* | кравець | noun | `colloquial` | `Zagreb` | germanism | немає |  |
| 55 | *štrample* | панчохи; колготки | noun | `colloquial` | `Zagreb` | germanism | немає |  |
| 56 | *fiškal* | адвокат (розм.) | noun | `colloquial` | `general` | {} | немає |  |
| 57 | *bajs* | велик | noun | `slang` | `general` | youth_slang, anglicism | немає |  |
| 58 | *trenirka* | спортивний костюм | noun | `colloquial` | `general` | {} | є — A1: «спортивний костюм» · `colloquial` → нагадування; розмітку звірити |  |
| 59 | *šlapice* | шльопанці | noun | `colloquial` | `general` | {} | немає |  |
| 60 | *frka* | паніка; метушня; проблема | noun | `colloquial` | `general` | {} | немає |  |
| 61 | *grdo* | дуже; страшенно (розм.) | adverb | `colloquial` | `general` | {} | немає |  |
| 62 | *skroz* | зовсім; повністю | adverb | `colloquial` | `general` | {} | немає |  |
| 63 | *fino* | гарно; приємно | adverb | `colloquial` | `general` | {} | немає |  |
| 64 | *ono* | ну; типу (слово-заповнювач) | particle | `colloquial` | `general` | {} | є з іншим значенням — A0: «воно» → додати значення до наявної лексеми | нз (воно) |
| 65 | *jel* | хіба ні?; правда ж? | particle | `colloquial` | `general` | {} | немає |  |
| 66 | *e pa* | ну, що ж | interjection | `colloquial` | `general` | {} | немає |  |
| 67 | *ma* | та; ой та | particle | `colloquial` | `general` | {} | немає |  |
| 68 | *nek* | нехай | particle | `colloquial` | `general` | {} | немає |  |
| 69 | *evo* | ось; ну от | particle | `colloquial` | `general` | {} | є — B1: «ось; ось тут» → нагадування; розмітку звірити |  |
| 70 | *čuješ* | слухай (на початку фрази) | phrase | `colloquial` | `general` | {} | немає |  |
| 71 | *ništa zato* | нічого страшного | phrase | `colloquial` | `general` | {} | немає |  |
| 72 | *ma kakvi* | та де там; та ні | phrase | `colloquial` | `general` | {} | немає |  |
| 73 | *ma da* | та ну; невже | phrase | `colloquial` | `general` | {} | немає |  |
| 74 | *ne pitaj* | краще не питай | phrase | `colloquial` | `general` | {} | немає |  |
| 75 | *ajd bok* | ну все, бувай | phrase | `informal` | `general` | {} | немає |  |
| 76 | *drogaš* | наркоман | noun | `slang` | `general` | offensive | немає | образливе |
| 77 | *trava* | трава (марихуана) | noun | `slang` | `general` | {} | немає → одна лема з обома значеннями (стандартне першим) | нз (трава) |
| 78 | *džoint* | косяк | noun | `slang` | `general` | anglicism | немає |  |
| 79 | *buksna* | косяк | noun | `slang` | `Zagreb` | {} | немає | у списку власника — «схованка»: ні, це косяк |
| 80 | *dilati* | торгувати наркотиками | verb | `slang` | `general` | anglicism | немає |  |

### Q · На перевірку носієм — Сумнівні слова з прикладу власника — чи вживають так у хорватській · 22

| № | Слово | Переклад | Частина мови | register | regionality | usage_tags | У базі | Примітка |
|---|---|---|---|---|---|---|---|---|
| 1 | *kap* | брехня (cap) | noun | `slang` | `general` | youth_slang, anglicism | немає | ? чи вживають |
| 2 | *no kap* | без брехні; чесно | phrase | `slang` | `general` | youth_slang, anglicism | немає | ? чи вживають |
| 3 | *bet* | домовились; ок | interjection | `slang` | `general` | youth_slang, anglicism | немає | ? чи вживають |
| 4 | *spilati ti* | розповісти плітки | phrase | `slang` | `general` | youth_slang, anglicism | немає | ? чи вживають |
| 5 | *kvin* | королева (про подругу) | noun | `slang` | `general` | youth_slang, anglicism | немає | ? чи вживають |
| 6 | *sis* | сестричка; подруга | noun | `slang` | `general` | youth_slang, anglicism | немає | ? чи вживають |
| 7 | *besti* | найкращий друг; подруга | noun | `slang` | `general` | youth_slang, anglicism | немає | ? чи вживають |
| 8 | *grin fleg* | хороша ознака (в людині) | phrase | `slang` | `general` | youth_slang, anglicism | немає | ? чи вживають |
| 9 | *red fleg* | тривожний дзвіночок (в людині) | phrase | `slang` | `general` | youth_slang, anglicism | немає | ? чи вживають |
| 10 | *ril* | реально; правда | adverb | `slang` | `general` | youth_slang, anglicism | немає | ? чи вживають |
| 11 | *slejati* | виглядати неперевершено | verb | `slang` | `general` | youth_slang, anglicism | немає | ? чи вживають |
| 12 | *goustati* | раптово зникнути (ghosting) | verb | `slang` | `general` | youth_slang, anglicism | немає | ? чи вживають |
| 13 | *sinati* | прочитати й не відповісти | verb | `slang` | `general` | internet_slang, anglicism | немає | ? чи вживають |
| 14 | *overthinkati* | накручувати себе | verb | `slang` | `general` | youth_slang, anglicism | немає | ? чи вживають |
| 15 | *gaslajtati* | маніпулювати (газлайтинг) | verb | `slang` | `general` | youth_slang, anglicism | немає | ? чи вживають |
| 16 | *kenslati* | скасувати (людину) | verb | `slang` | `general` | internet_slang, anglicism | немає | ? чи вживають |
| 17 | *rils* | рілс (коротке відео) | noun | `slang` | `general` | internet_slang, anglicism | немає | ? написання |
| 18 | *autfit* | образ; одяг | noun | `slang` | `general` | youth_slang, anglicism | немає | ? написання |
| 19 | *drip* | крутий стиль одягу | noun | `slang` | `general` | youth_slang, anglicism | немає | ? чи вживають |
| 20 | *simp* | хлопець, що надто догоджає | noun | `slang` | `general` | youth_slang, anglicism | немає | ? чи вживають |
| 21 | *lero* | на халяву | adverb | `slang` | `Dalmatia` | {} | немає | ? чи є таке слово |
| 22 | *šup* | сарай; глушина | noun | `slang` | `Zagreb` | {} | немає | ? радше šupa |

### X1 · B1 · 18+ — 1. Як і чому лаються: найчастіші слова · 24

| № | Слово | Переклад | Частина мови | register | regionality | usage_tags | У базі | Примітка |
|---|---|---|---|---|---|---|---|---|
| 1 | *psovka* | лайка; лайливе слово | noun | `standard` | `general` | {} | немає | метамова уроку |
| 2 | *psovati* | лаятися | verb | `standard` | `general` | {} | немає | метамова уроку |
| 3 | *opsovati* | вилаяти; облаяти | verb | `standard` | `general` | {} | немає | метамова уроку |
| 4 | *jebiga* | ну що ж; нічого не вдієш | interjection | `vulgar` | `general` | {} | немає | вигук, не образа |
| 5 | *jebote* | ох нічого собі; чорт забирай | interjection | `vulgar` | `general` | {} | немає | вигук |
| 6 | *jebem ti sunce* | бляха-муха | phrase | `vulgar` | `general` | {} | немає | пом'якшена форма |
| 7 | *kurac* | хер; член | noun | `vulgar` | `general` | {} | немає |  |
| 8 | *koji kurac* | якого хріна | phrase | `vulgar` | `general` | {} | немає |  |
| 9 | *pička* | пизда | noun | `vulgar` | `general` | {} | немає | і як образа |
| 10 | *sranje* | лайно; лажа | noun | `vulgar` | `general` | {} | немає |  |
| 11 | *govno* | гівно | noun | `vulgar` | `general` | {} | немає |  |
| 12 | *srati* | срати; молоти дурниці | verb | `vulgar` | `general` | {} | немає |  |
| 13 | *ne seri* | не неси дурниць | phrase | `vulgar` | `general` | {} | немає |  |
| 14 | *sjebati* | зіпсувати; облажати | verb | `vulgar` | `general` | {} | немає |  |
| 15 | *sjeban* | розбитий; у лайні | adjective | `vulgar` | `general` | {} | немає |  |
| 16 | *zajebati* | обдурити; напартачити | verb | `vulgar` | `general` | {} | немає |  |
| 17 | *zajebavati* | підколювати; стьобати | verb | `vulgar` | `general` | {} | немає |  |
| 18 | *zajebancija* | прикол; стьоб | noun | `vulgar` | `general` | {} | немає | між друзями — легко |
| 19 | *jebeno* | охрінено; дуже | adverb | `vulgar` | `general` | {} | немає | підсилювач |
| 20 | *jebeni* | довбаний | adjective | `vulgar` | `general` | {} | немає |  |
| 21 | *jebati* | трахати | verb | `vulgar` | `general` | {} | немає |  |
| 22 | *odjebi* | відвали | phrase | `vulgar` | `general` | {} | немає | грубо |
| 23 | *popušiti* | програти; обламатися | verb | `vulgar` | `general` | {} | немає |  |
| 24 | *pušiona* | повний провал | noun | `vulgar` | `general` | {} | немає |  |

### X2 · B1 · 18+ — 2. Вигуки, підсилювачі й пом'якшені замінники · 21

| № | Слово | Переклад | Частина мови | register | regionality | usage_tags | У базі | Примітка |
|---|---|---|---|---|---|---|---|---|
| 1 | *k vragu* | до біса | phrase | `colloquial` | `general` | {} | немає | замінник |
| 2 | *dovraga* | дідько; до дідька | interjection | `colloquial` | `general` | {} | немає | замінник |
| 3 | *koji vrag* | якого біса | phrase | `colloquial` | `general` | {} | немає | замінник «koji kurac» |
| 4 | *vrag te odnio* | щоб тебе чорт забрав | phrase | `colloquial` | `general` | {} | немає | замінник |
| 5 | *sto mu gromova* | тисяча чортів | phrase | `colloquial` | `general` | idiom | немає | замінник |
| 6 | *majko mila* | матінко рідна | phrase | `colloquial` | `general` | {} | немає | замінник |
| 7 | *bože dragi* | боже милий | phrase | `colloquial` | `general` | {} | немає | замінник |
| 8 | *ajme meni* | ой лишенько | phrase | `colloquial` | `general` | {} | немає | замінник |
| 9 | *šipak* | дуля; дзузьки | noun | `colloquial` | `general` | {} | немає → одна лема з обома значеннями (стандартне першим) | замінник; нз (шипшина) |
| 10 | *baš me briga* | а мені байдуже | phrase | `colloquial` | `general` | {} | немає | замінник «boli me kurac» |
| 11 | *boli me kurac* | мені пох | phrase | `vulgar` | `general` | {} | немає |  |
| 12 | *boli me đon* | мені по барабану | phrase | `colloquial` | `general` | {} | немає | ? |
| 13 | *majku mu* | бляха; щоб його | phrase | `vulgar` | `general` | {} | немає | скорочено від «jebem mu majku» |
| 14 | *pas mater* | бляха; собача мати | phrase | `vulgar` | `Dalmatia` | {} | немає | ? |
| 15 | *jebo te pas* | та щоб тебе | phrase | `vulgar` | `general` | {} | немає | ? |
| 16 | *jebem ti miša* | бляха-муха | phrase | `vulgar` | `general` | {} | немає | пом'якшена форма |
| 17 | *jebem ti život* | чорт забирай (таке життя) | phrase | `vulgar` | `general` | {} | немає |  |
| 18 | *sunce ti* | бляха; та ну | phrase | `colloquial` | `general` | {} | немає | ? замінник |
| 19 | *ma jebeš to* | та забий на це | phrase | `vulgar` | `general` | {} | немає |  |
| 20 | *jebeš ga* | та й біс із ним | phrase | `vulgar` | `general` | {} | немає |  |
| 21 | *kvragu sve* | до біса все | phrase | `colloquial` | `general` | {} | немає | замінник |

### X3 · B1 · 18+ — 3. Образи — розпізнати й відреагувати · 23

| № | Слово | Переклад | Частина мови | register | regionality | usage_tags | У базі | Примітка |
|---|---|---|---|---|---|---|---|---|
| 1 | *budala* | дурень | noun | `colloquial` | `general` | offensive | немає | образа, легка |
| 2 | *glupan* | дурень; тупак | noun | `colloquial` | `general` | offensive | немає | образа |
| 3 | *kreten* | кретин | noun | `colloquial` | `general` | offensive | немає | образа |
| 4 | *debil* | дебіл | noun | `vulgar` | `general` | offensive | немає | образа; зачіпає людей з інвалідністю |
| 5 | *konj* | бовдур; дурень | noun | `colloquial` | `general` | offensive | є з іншим значенням — A1: «кінь» → додати значення до наявної лексеми | образа; нз (кінь) |
| 6 | *đubre* | покидьок | noun | `vulgar` | `general` | offensive | немає | образа |
| 7 | *šupak* | мудак | noun | `vulgar` | `general` | offensive | немає | образа |
| 8 | *seronja* | пустобрех; мудак | noun | `vulgar` | `general` | offensive | немає | образа |
| 9 | *kurva* | повія; шльондра | noun | `vulgar` | `general` | offensive | немає | образа; і як вигук |
| 10 | *kurvin sin* | сучий син | phrase | `vulgar` | `general` | offensive | немає | образа |
| 11 | *jebi se* | пішов ти | phrase | `vulgar` | `general` | offensive | немає | образа |
| 12 | *marš* | геть!; марш! | interjection | `colloquial` | `general` | {} | немає | грубо |
| 13 | *gubi se* | забирайся; зникни | phrase | `colloquial` | `general` | {} | немає | грубо |
| 14 | *peder* | педик | noun | `vulgar` | `general` | offensive | немає | образа за орієнтацією; нейтрально — gej |
| 15 | *lezba* | образливо про лесбійку | noun | `vulgar` | `general` | offensive | немає | образа за орієнтацією; нейтрально — lezbijka |
| 16 | *Cigan* | образливо про рома | noun | `vulgar` | `general` | offensive | немає | образа за національністю; нейтрально — Rom |
| 17 | *Šiptar* | образливо про албанця | noun | `vulgar` | `general` | offensive | немає | образа за національністю; нейтрально — Albanac |
| 18 | *balija* | образливо про босняка-мусульманина | noun | `vulgar` | `general` | offensive | немає | образа за національністю й релігією; нейтрально — Bošnjak |
| 19 | *četnik* | четник (образа для серба) | noun | `vulgar` | `general` | offensive | немає | образа; історичне слово — ? |
| 20 | *ustaša* | усташ (образа для хорвата) | noun | `vulgar` | `general` | offensive | немає | образа; історичне слово — ? |
| 21 | *crnčuga* | образливо про темношкірого | noun | `vulgar` | `general` | offensive | немає | расистська образа; нейтрально — crnac (застаріває), tamnoput |
| 22 | *retardiran* | відсталий (образа) | adjective | `vulgar` | `general` | offensive | немає | образа людей з інвалідністю |
| 23 | *seljačina* | селюк; бидло | noun | `vulgar` | `general` | offensive | немає | образа |

### X4 · B1 · 18+ — 4. Лайка з релігійними словами · 18

| № | Слово | Переклад | Частина мови | register | regionality | usage_tags | У базі | Примітка |
|---|---|---|---|---|---|---|---|---|
| 1 | *jebem ti boga* | найгрубіша блюзнірська лайка | phrase | `vulgar` | `general` | {} | немає | ображає вірян |
| 2 | *jebem ti sveca* | блюзнірська лайка (про святого) | phrase | `vulgar` | `general` | {} | немає | ображає вірян |
| 3 | *jebem ti križ* | блюзнірська лайка (про хрест) | phrase | `vulgar` | `general` | {} | немає | ? |
| 4 | *jebote bog* | чорт забирай (блюзнірське) | phrase | `vulgar` | `general` | {} | немає | ? |
| 5 | *boga ti* | бляха; та ти що | phrase | `vulgar` | `Dalmatia` | {} | немає | скорочене блюзнірство |
| 6 | *bogati* | та ти що!; о боже! | interjection | `colloquial` | `Dalmatia` | {} | немає |  |
| 7 | *bogarati* | лаятися блюзнірськи | verb | `colloquial` | `Dalmatia` | {} | немає |  |
| 8 | *isusa ti* | та ти що (блюзнірське) | phrase | `vulgar` | `general` | {} | немає | ? |
| 9 | *sveca ti* | бляха (скорочене) | phrase | `vulgar` | `general` | {} | немає | ? |
| 10 | *Gospe moja* | матір Божа! | phrase | `colloquial` | `Dalmatia` | {} | немає | не лайка — вигук |
| 11 | *Isuse Bože* | Господи Боже! | phrase | `colloquial` | `general` | {} | немає | не лайка — вигук |
| 12 | *bog te mazo* | ну й ну; щоб тебе | phrase | `colloquial` | `general` | idiom | немає |  |
| 13 | *bog te pita* | хто його знає | phrase | `colloquial` | `general` | idiom | немає |  |
| 14 | *boga mi* | їй-богу | phrase | `colloquial` | `general` | {} | немає |  |
| 15 | *tako mi Boga* | клянуся Богом | phrase | `colloquial` | `general` | {} | немає |  |
| 16 | *da Bog da crko* | щоб ти здох (прокльон) | phrase | `vulgar` | `general` | idiom | немає | прокльон |
| 17 | *Bože sačuvaj* | Боже борони | phrase | `standard` | `general` | {} | немає | не лайка |
| 18 | *idi k vragu* | іди к бісу | phrase | `colloquial` | `general` | {} | немає | замінник |

### X5 · B1 · 18+ — 5. Сталі вирази й діалоги · 23

| № | Слово | Переклад | Частина мови | register | regionality | usage_tags | У базі | Примітка |
|---|---|---|---|---|---|---|---|---|
| 1 | *jebem ti mater* | класична лайка «про матір» | phrase | `vulgar` | `general` | {} | немає | між друзями — вигук, до незнайомого — тяжка образа |
| 2 | *pasji sin* | собачий син | phrase | `vulgar` | `general` | offensive | немає | образа |
| 3 | *glupača* | дурепа | noun | `colloquial` | `general` | offensive | немає | образа |
| 4 | *majmun* | бовдур; мавпа (образа) | noun | `colloquial` | `general` | offensive | немає → одна лема з обома значеннями (стандартне першим) | образа; нз (мавпа) |
| 5 | *krava* | корова (образа для жінки) | noun | `vulgar` | `general` | offensive | є з іншим значенням — A1: «корова» → додати значення до наявної лексеми | образа; нз (корова) |
| 6 | *drolja* | шльондра | noun | `vulgar` | `general` | offensive | немає | образа |
| 7 | *komad* | красуня; «шматочок» | noun | `vulgar` | `general` | offensive | є з іншим значенням — A0: «шматок, штука» → додати значення до наявної лексеми | зневажливо, про жінку; нз (шматок) |
| 8 | *treba* | дівчина (зневажливо) | noun | `vulgar` | `general` | offensive | немає → одна лема з обома значеннями (стандартне першим) | зневажливо; нз (треба) |
| 9 | *u kurac* | до біса; пропало | phrase | `vulgar` | `general` | {} | немає |  |
| 10 | *u pičku materinu* | до біса; хай йому | phrase | `vulgar` | `general` | {} | немає |  |
| 11 | *jebe mi se* | мені пох | phrase | `vulgar` | `general` | {} | немає |  |
| 12 | *zajebi* | забий; не зважай | phrase | `vulgar` | `general` | {} | немає |  |
| 13 | *popizditi* | оскаженіти; знавіснiти | verb | `vulgar` | `general` | {} | немає |  |
| 14 | *pizdarija* | дурня; фігня | noun | `vulgar` | `general` | {} | немає |  |
| 15 | *kurčiti se* | випендрюватися | verb | `vulgar` | `general` | {} | немає |  |
| 16 | *guzica* | дупа | noun | `vulgar` | `general` | {} | немає |  |
| 17 | *dupe* | дупа | noun | `colloquial` | `general` | {} | немає |  |
| 18 | *lizati dupe* | підлизуватися | phrase | `vulgar` | `general` | idiom | немає |  |
| 19 | *pun mi je kurac* | мене дістало | phrase | `vulgar` | `general` | idiom | немає |  |
| 20 | *boli me ona stvar* | мені по цимбалах | phrase | `colloquial` | `general` | {} | немає | ? замінник |
| 21 | *mamlaz* | бовдур; йолоп | noun | `colloquial` | `general` | offensive | немає | образа, легка |
| 22 | *tikvan* | йолоп; бевзь | noun | `colloquial` | `general` | offensive | немає | образа, легка |
| 23 | *smotan* | недотепа; незграбний | adjective | `colloquial` | `general` | {} | немає |  |
