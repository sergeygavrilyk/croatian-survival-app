# Розмітка всіх слів і речень — звіт (2026-11-13)

Пакет `supabase/data_fixes/20261113_lexeme_labels.sql` (генератор `scripts/gen_lexeme_labels_20261113.py`, знімок робочої бази `scripts/lexeme_labels_20261113_snapshot.json`). Модель — `docs/LEARNING_SPEC.md` §18; крок 2 плану `docs/proposals/2026-11-12_b1_b2_dialogues_reading_situations.md` §4.3.

## 1. Підсумок

- Слів у базі: **6451** (без міток до пакета — 6442); речень (`phrases`): **86**.
- Явно, за списком: **204** слів. Решта **6247** слів — `standard` / `general` / `{}`.
- Речення: за списком **3**, решта 83 — `standard` / `general` / `{}`.
- Кожна зміна — стара версія в `content_versions`, запис у `content_reviews` (`script`).

| Регістр (явні) | Слів |
|---|---|
| `colloquial` | 43 |
| `informal` | 39 |
| `slang` | 2 |
| `standard` | 120 |

| Регіон (явні) | Слів |
|---|---|
| `Dalmatia` | 14 |
| `Istria` | 2 |
| `Zagreb` | 2 |
| `general` | 186 |

| Ознака | Слів |
|---|---|
| `anglicism` | 45 |
| `germanism` | 19 |
| `idiom` | 13 |
| `italianism` | 27 |
| `kajkavian` | 1 |
| `turkism` | 4 |

Разом з типовими: `standard` ≈ 6367 слів, `general` ≈ 6433.

## 2. Що змінилося в правилах

- Старі значення: `regional` → `colloquial` (*kapula, pomidor, šugaman* — + `italianism`, регіон `Dalmatia` уже був); `non_standard` → `colloquial` (*da li govorite engleski*, DEPRECATED).
- DEPRECATED слова теж розмічено (рішення 2026-11-13: «і PUBLISHED, і DEPRECATED»): звертання на «ти» (*kako provodiš vikend, što radiš, zovi policiju*) — `informal`.
- Межа для ознак походження: запозичення, яке учень чує як іншомовне чи розмовне (*vikend, šlag, šugaman, kusur*); давні повністю засвоєні слова (*kuhinja, krumpir, šunka, čarape*) — без ознаки.

## 3. Слова з явними мітками

| Слово | Статус | register | regionality | usage_tags | Чому |
|---|---|---|---|---|---|
| *a cappella* | P | `standard` | `general` | `italianism` | ознаки за перевіркою словника |
| *a ti* | P | `informal` | `general` | — | регістр уже був |
| *advokat* | P | `standard` | `general` | — | за правилами регістру |
| *ae* | P | `slang` | `Dalmatia` | — | регістр уже був; регіон уже був |
| *aerodrom* | P | `standard` | `general` | — | за правилами регістру |
| *apoteka* | D | `colloquial` | `general` | — | регістр уже був |
| *backup* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *bakalar* | P | `standard` | `general` | `italianism` | ознаки за перевіркою словника |
| *bend* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *benzinac* | P | `colloquial` | `general` | — | регістр уже був |
| *bevanda* | P | `standard` | `Dalmatia` | `italianism` | далматинське слово; у перекладі «Далмація» |
| *bilježnik* | P | `standard` | `general` | — | за правилами регістру |
| *bok* | P | `informal` | `general` | — | регістр уже був |
| *brancin* | P | `standard` | `general` | `italianism` | ознаки за перевіркою словника |
| *brudet* | P | `standard` | `general` | `italianism` | ознаки за перевіркою словника |
| *brzo ozdravi* | P | `informal` | `general` | — | регістр уже був |
| *bura* | P | `standard` | `Dalmatia` | — | регіон уже був |
| *burek* | P | `standard` | `general` | `turkism` | ознаки за перевіркою словника |
| *buvljak* | P | `colloquial` | `general` | — | регістр уже був |
| *cimerica* | P | `colloquial` | `general` | `germanism` | регістр уже був |
| *crni rižot* | P | `standard` | `general` | `italianism` | ознаки за перевіркою словника |
| *crtić* | P | `colloquial` | `general` | — | регістр уже був |
| *crtići* | P | `colloquial` | `general` | — | регістр уже був |
| *cura* | P | `colloquial` | `general` | — | регістр уже був |
| *da li govorite engleski* | D | `colloquial` | `general` | — | старе non_standard → colloquial |
| *deka* | P | `colloquial` | `general` | — | регістр уже був |
| *dernjati se* | P | `colloquial` | `general` | — | регістр уже був |
| *dečko* | P | `standard` | `general` | — | за правилами регістру |
| *dizajn* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *dizajnirati* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *dogovor je dogovor* | P | `standard` | `general` | `idiom` | ознаки за перевіркою словника |
| *doktor* | P | `standard` | `general` | — | за правилами регістру |
| *drži se* | P | `informal` | `general` | — | регістр уже був |
| *dućan* | P | `standard` | `general` | — | за правилами регістру |
| *džem* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *džemper* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *facebook grupa* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *fen* | P | `standard` | `general` | `germanism` | ознаки за перевіркою словника |
| *feniranje* | P | `standard` | `general` | `germanism` | ознаки за перевіркою словника |
| *fiš paprikaš* | P | `standard` | `general` | — | за правилами регістру |
| *fjaka* | P | `colloquial` | `Dalmatia` | — | регістр уже був; регіон уже був |
| *flaster* | P | `standard` | `general` | `germanism` | ознаки за перевіркою словника |
| *fritule* | P | `standard` | `general` | `italianism` | ознаки за перевіркою словника |
| *fuži* | P | `standard` | `Istria` | `italianism` | істрійська паста; у перекладі «істрійська» |
| *gablec* | P | `colloquial` | `Zagreb` | `germanism`, `kajkavian` | регістр уже був; загребське (кайкавське) слово; у перекладі «загреб.» |
| *gemišt* | P | `standard` | `general` | `germanism` | ознаки за перевіркою словника |
| *grupni chat* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *gušt* | P | `colloquial` | `Dalmatia` | `italianism` | регістр уже був; регіон уже був |
| *haker* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *hardver* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *hitna* | P | `standard` | `general` | — | за правилами регістру |
| *hobi* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *hostel* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *i tebi* | P | `informal` | `general` | — | регістр уже був |
| *intervju* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *izaći na kraj* | P | `standard` | `general` | `idiom` | ознаки за перевіркою словника |
| *izaći u susret* | P | `standard` | `general` | `idiom` | ознаки за перевіркою словника |
| *izvoli* | P | `informal` | `general` | — | регістр уже був |
| *javi se* | P | `informal` | `general` | — | регістр уже був |
| *javit ću ti* | P | `informal` | `general` | — | регістр уже був |
| *jugo* | P | `standard` | `Dalmatia` | — | регіон уже був |
| *kako provodiš vikend* | D | `informal` | `general` | — | звертання на «ти» в самому виразі (офіційно — на «ви») |
| *kako se osjećaš* | P | `informal` | `general` | — | регістр уже був |
| *kako se zoveš* | P | `informal` | `general` | — | регістр уже був |
| *kako si* | P | `informal` | `general` | — | регістр уже був |
| *kapula* | P | `colloquial` | `Dalmatia` | `italianism` | старе regional → colloquial; регіон уже був |
| *kauč* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *kemijska* | P | `colloquial` | `general` | — | регістр уже був |
| *kesa* | P | `standard` | `general` | — | за правилами регістру |
| *kifla* | P | `standard` | `general` | `germanism` | ознаки за перевіркою словника |
| *kila* | P | `colloquial` | `general` | — | регістр уже був |
| *klamerica* | P | `standard` | `general` | — | за правилами регістру |
| *kliknuti* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *klima* | P | `colloquial` | `general` | — | регістр уже був |
| *kofer* | P | `standard` | `general` | `germanism` | ознаки за перевіркою словника |
| *koliko imaš godina* | P | `informal` | `general` | — | регістр уже був |
| *kompjuter* | D | `colloquial` | `general` | `anglicism` | регістр уже був |
| *kontrolni* | P | `colloquial` | `general` | — | регістр уже був |
| *kremšnita* | P | `standard` | `general` | `germanism` | ознаки за перевіркою словника |
| *kusur* | P | `colloquial` | `general` | `turkism` | регістр уже був |
| *kužiš?* | D | `colloquial` | `general` | — | форма від kužiti (colloquial за правилами); DEPRECATED |
| *kvadrat* | P | `standard` | `general` | — | за правилами регістру |
| *kvart* | P | `colloquial` | `general` | — | регістр уже був |
| *laptop* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *last minute ponuda* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *lift* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *lijepo se provedi* | P | `informal` | `general` | — | регістр уже був |
| *link* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *maestral* | P | `standard` | `Dalmatia` | — | вітер Адріатики — як bura, jugo (у базі вже Dalmatia) |
| *mail* | P | `colloquial` | `general` | `anglicism` | регістр уже був |
| *maneštra* | P | `standard` | `Istria` | `italianism` | істрійська (і кварнерська) страва |
| *maraskino* | P | `standard` | `general` | `italianism` | ознаки за перевіркою словника |
| *marenda* | P | `colloquial` | `Dalmatia` | `italianism` | регістр уже був; регіон уже був |
| *markirati* | P | `colloquial` | `general` | — | регістр уже був |
| *menadžer* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *mikrovalna* | P | `colloquial` | `general` | — | регістр уже був |
| *mislim...* | D | `standard` | `general` | — | за правилами регістру |
| *molim te* | P | `informal` | `general` | — | регістр уже був |
| *motel* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *može* | P | `informal` | `general` | — | регістр уже був |
| *mušterija* | P | `colloquial` | `general` | `turkism` | регістр уже був |
| *na buzaru* | P | `standard` | `general` | `italianism` | ознаки за перевіркою словника |
| *na licu mjesta* | P | `standard` | `general` | `idiom` | ознаки за перевіркою словника |
| *napuniti baterije* | P | `standard` | `general` | `idiom` | ознаки за перевіркою словника |
| *naručiti termin online* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *ne da mi se* | P | `standard` | `general` | — | за правилами регістру |
| *ne propusti* | P | `informal` | `general` | — | регістр уже був |
| *nedostaješ mi* | P | `informal` | `general` | — | регістр уже був |
| *nemoj mi otkriti kraj* | P | `informal` | `general` | — | регістр уже був |
| *nestati bez traga* | P | `standard` | `general` | `idiom` | ознаки за перевіркою словника |
| *nikad ne reci nikad* | P | `standard` | `general` | `idiom` | ознаки за перевіркою словника |
| *nisam te čuo* | P | `informal` | `general` | — | регістр уже був |
| *nisi u pravu* | P | `informal` | `general` | — | регістр уже був |
| *odakle si* | P | `informal` | `general` | — | регістр уже був |
| *odgovara li ti* | P | `informal` | `general` | — | регістр уже був |
| *onak* | P | `slang` | `Zagreb` | — | регістр уже був; регіон уже був |
| *online kupnja* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *online sastanak* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *online škola* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *opet sam na nogama* | P | `standard` | `general` | `idiom` | ознаки за перевіркою словника |
| *oprosti* | P | `informal` | `general` | — | регістр уже був |
| *orada* | P | `standard` | `general` | `italianism` | ознаки за перевіркою словника |
| *osjećati se kao kod kuće* | P | `standard` | `general` | `idiom` | ознаки за перевіркою словника |
| *pa...* | D | `standard` | `general` | — | за правилами регістру |
| *papirologija* | P | `colloquial` | `general` | — | регістр уже був |
| *parking* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *pauk* | P | `standard` | `general` | — | за правилами регістру |
| *pazi* | P | `informal` | `general` | — | регістр уже був |
| *pašticada* | P | `standard` | `general` | `italianism` | ознаки за перевіркою словника |
| *pegla* | P | `colloquial` | `general` | `germanism` | регістр уже був |
| *peglati* | P | `colloquial` | `general` | `germanism` | регістр уже був |
| *pekara* | P | `standard` | `general` | — | за правилами регістру |
| *persirati* | P | `standard` | `general` | — | за правилами регістру |
| *pizzerija* | P | `standard` | `general` | `italianism` | ознаки за перевіркою словника |
| *piši mi* | P | `informal` | `general` | — | регістр уже був |
| *podcast* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *pola kile* | P | `colloquial` | `general` | — | регістр уже був |
| *pomalo* | P | `standard` | `Dalmatia` | — | регіон уже був |
| *pomidor* | P | `colloquial` | `Dalmatia` | `italianism` | старе regional → colloquial; регіон уже був |
| *popust za rani booking* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *poslovni e-mail* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *potvrdi mi* | P | `informal` | `general` | — | регістр уже був |
| *pozdravi* | P | `informal` | `general` | — | регістр уже був |
| *prenositi s koljena na koljeno* | P | `standard` | `general` | `idiom` | ознаки за перевіркою словника |
| *pršut* | P | `standard` | `general` | `italianism` | ознаки за перевіркою словника |
| *pumpa* | P | `standard` | `general` | — | за правилами регістру |
| *rent-a-car* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *riva* | P | `standard` | `Dalmatia` | `italianism` | регіон уже був |
| *roming* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *ruksak* | P | `standard` | `general` | `germanism` | ознаки за перевіркою словника |
| *ruter* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *sendvič* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *skitati se* | P | `colloquial` | `general` | — | регістр уже був |
| *skoro* | P | `standard` | `general` | — | за правилами регістру |
| *skriveni dragulj* | P | `standard` | `general` | `idiom` | ознаки за перевіркою словника |
| *slikati* | P | `standard` | `general` | — | за правилами регістру |
| *softver* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *spiza* | P | `colloquial` | `Dalmatia` | `italianism` | регістр уже був; регіон уже був |
| *srdela* | P | `standard` | `general` | `italianism` | ознаки за перевіркою словника |
| *srdele* | P | `standard` | `general` | `italianism` | ознаки за перевіркою словника |
| *stani* | P | `informal` | `general` | — | регістр уже був |
| *stres* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *super* | P | `colloquial` | `general` | — | регістр уже був |
| *supermarket* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *tablet* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *tako-tako* | P | `informal` | `general` | — | регістр уже був |
| *tartuf* | P | `standard` | `general` | `italianism` | ознаки за перевіркою словника |
| *tartufi* | P | `standard` | `general` | `italianism` | ознаки за перевіркою словника |
| *tastatura* | P | `colloquial` | `general` | — | регістр уже був |
| *tegla* | P | `colloquial` | `general` | — | регістр уже був |
| *tinejdžer* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *tost* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *trailer* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *trenirka* | P | `colloquial` | `general` | — | регістр уже був |
| *u dobre ruke* | P | `standard` | `general` | `idiom` | ознаки за перевіркою словника |
| *u pravu si* | P | `informal` | `general` | — | регістр уже був |
| *u zadnji čas* | P | `standard` | `general` | `idiom` | ознаки за перевіркою словника |
| *vidimo se* | P | `informal` | `general` | — | регістр уже був |
| *vikend* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *web-stranica* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *za van* | P | `standard` | `general` | — | за правилами регістру |
| *zaslužio si* | P | `informal` | `general` | — | регістр уже був |
| *zdravo* | P | `informal` | `general` | — | регістр уже був |
| *zlonamjerni softver* | P | `standard` | `general` | `anglicism` | ознаки за перевіркою словника |
| *znači...* | D | `standard` | `general` | — | за правилами регістру |
| *zovi policiju* | D | `informal` | `general` | — | звертання на «ти» в самому виразі (офіційно — на «ви») |
| *zubar* | P | `standard` | `general` | — | за правилами регістру |
| *ćevapi* | P | `standard` | `general` | `turkism` | ознаки за перевіркою словника |
| *čekaj* | P | `informal` | `general` | — | регістр уже був |
| *čika* | P | `colloquial` | `general` | — | регістр уже був |
| *čujemo se* | P | `informal` | `general` | — | регістр уже був |
| *šalabahter* | P | `colloquial` | `general` | — | регістр уже був |
| *škampi* | P | `standard` | `general` | `italianism` | ознаки за перевіркою словника |
| *šlag* | P | `standard` | `general` | `germanism` | ознаки за перевіркою словника |
| *šminka* | P | `standard` | `general` | `germanism` | ознаки за перевіркою словника |
| *šogor* | P | `standard` | `general` | `germanism` | ознаки за перевіркою словника |
| *šogorica* | P | `standard` | `general` | `germanism` | ознаки за перевіркою словника |
| *šprica* | P | `colloquial` | `general` | `germanism` | регістр уже був |
| *štand* | P | `standard` | `general` | `germanism` | ознаки за перевіркою словника |
| *što radiš* | D | `informal` | `general` | — | звертання на «ти» в самому виразі (офіційно — на «ви») |
| *štrudla* | P | `standard` | `general` | `germanism` | ознаки за перевіркою словника |
| *šugaman* | P | `colloquial` | `Dalmatia` | `italianism` | старе regional → colloquial; регіон уже був |
| *želim ti* | P | `informal` | `general` | — | регістр уже був |
| *žmigavac* | P | `colloquial` | `general` | — | регістр уже був |

## 4. Речення з мітками поза типовими

| Речення | register | usage_tags | Чому |
|---|---|---|---|
| *imamo li blokada za ovaj sprint?* | `standard` | `professional_jargon`, `anglicism` | ІТ-жаргон: sprint, blokada (блокер) |
| *kužiš?* | `colloquial` | — | kužiti — розмовне |
| *predao sam zahtjev online.* | `standard` | `anglicism` | online |

## 5. Що варто глянути носію

**Сумнівний регістр** (поставлено `standard`; якщо носій скаже «розмовне» — змінимо окремим пакетом через `content_versions`):

- *advokat* — standard; стандартно odvjetnik (теж є в словнику); розмовне чи сербізм? носію
- *aerodrom* — standard; стандартно zračna luka (теж є в словнику); у мовленні звичайне — розмовне? носію
- *bilježnik* — standard; у перекладі «(розм.)», але (javni) bilježnik — офіційний термін; прибрати позначку? носію
- *dečko* — standard; «хлопець (романтично)» — у мовленні нейтральне; чи розмовне — носію
- *doktor* — standard; «лікар» — у мовленні звичайне, стандартно liječnik; розмовне? носію
- *dućan* — standard; у перекладі «(розмовно)», але dućan — стандартне слово; прибрати позначку з перекладу? носію
- *hitna* — standard; скорочення від hitna pomoć — розмовне? носію
- *kesa* — standard; у перекладі «(регіонально)»; стандартно — vrećica; яке регіон і регістр? носію
- *klamerica* — standard; «степлер» — стандартно spajalica / klamarica? носію
- *kofer* — standard; «валіза» — стандартно kovčeg; розмовне? носію
- *kvadrat* — standard; омонім: «квадратний метр» — розмовне, «квадрат» — стандартне
- *link* — standard; англіцизм, стандартно poveznica; розмовне? носію
- *ne da mi se* — standard; літературна конструкція, але неофіційна? носію
- *parking* — standard; стандартно parkiralište (теж є в словнику); розмовне? носію
- *pauk* — standard; омонім: «евакуатор» — розмовне, «павук» — стандартне; одна лема на обидва значення
- *pekara* — standard; стандартно pekarnica; розмовне? носію
- *persirati* — standard; «звертатися на Ви» — розмовне? (поруч tikati) носію
- *pomalo* — standard; стандартне «потроху»; далматинське «не поспішай» — розмовне? носію
- *pumpa* — standard; омонім: «заправка» — розмовне, «насос» — стандартне
- *skoro* — standard; омонім: «скоро» — стандартне, «майже» — розмовне (стандартно gotovo)
- *slikati* — standard; омонім: «малювати» — стандартне, «фотографувати» — розмовне
- *za van* — standard; «навинос» — стандартно za ponijeti; розмовне? носію
- *zubar* — standard; «стоматолог» — у мовленні звичайне, стандартно stomatolog; розмовне? носію
- *šlag* — standard; «збиті вершки» — стандартно tučeno vrhnje; розмовне? носію
- *štand* — standard; «ятка» (з нім.) — розмовне? носію

**Непевне походження й регістр:**

- *fjaka* — походження: італізм (fiacca)? грецьке? — ознаку italianism не ставлю, доки носій не підтвердить
- *žmigavac* — походження (германізм?) — ознаку не ставлю
- *šalabahter* — походження (германізм?) — ознаку не ставлю
- *deka* — австрійське Deka (германізм?) — ознаку не ставлю
- *sjesti na račun* — розмовне «надійти на рахунок»? — зараз standard
- *mislim...* — слово-заповнювач (DEPRECATED, також у phrases) — informal? зараз standard
- *znači...* — слово-заповнювач (DEPRECATED, також у phrases) — colloquial? зараз standard
- *pa...* — слово-заповнювач (DEPRECATED, також у phrases) — зараз standard
- *zadržite kusur* — містить туркізм kusur (colloquial) — фраза зараз standard без ознак
- *gdje je apoteka* — apoteka — розмовне / сербізм (DEPRECATED слово) — фраза зараз standard

## 6. Помилки даних, помічені під час перегляду (окремим пакетом)

- *budilika* — одруківка (*budilica* теж є в словнику) — DEPRECATED?
- *pijesok* — одруківка (*pijesak* теж є); *taoc*, *suhozid* — уже у звіті 2026-11-12
- *kužiš?*, *mislim...*, *znači...*, *pa...* — леми зі знаками й трикрапкою (DEPRECATED; ті самі — у phrases)
- леми-речення з репліками діалогу (*a: dobar dan! kako ste?*, *developer: završio sam backend dio…*, *arhitekt: …*) — мають бути в conversations; позначено standard без ознак
- *dijaloz -> dijalog* — лема зі стрілкою
