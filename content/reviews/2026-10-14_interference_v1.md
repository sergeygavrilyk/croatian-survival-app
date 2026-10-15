# Типові помилки українців (interference_v1)

Дата: 2026-10-14. Запит власника: §19 ТЗ «Ukrainian Interference Engine» — каталог типових помилок українців у хорватській, 12 категорій, коди `UKR-HR-NNNN`.

## Файли

- міграція: `supabase/migrations/20261013160000_m14_linguistic_errors.sql` — таблиця `linguistic_errors` + колонка `user_errors.linguistic_error_id`;
- дані (SQL): `supabase/data_fixes/20261013_interference_v1.sql` (63 КБ, 74 помилки, наприкінці самоперевірка);
- тест: `supabase/tests/interference.test.sql`;
- дані: `scripts/interference_data.py`, генератор: `scripts/gen_interference.py` (`--review` — таблиця нижче).

Порядок запуску в SQL Editor: M14 → `20261013_interference_v1.sql` → `interference.test.sql`. Повторний запуск безпечний.

## Де це видно в застосунку

| Місце | Що там |
|---|---|
| `/mistakes/typical` («Помилки» → «Типові помилки») | тренування: 8 питань «як правильно?», фільтр за категорією; хибна відповідь → картка з поясненням і запис у «Мої помилки» |
| `/mistakes` | помилки з тренування позначено «Типова помилка:» і повторюються разом з іншими |
| урок, етап граматики | до 2 карток «Українці часто помиляються» за темою граматики або словом уроку |

Аналітика: `exercise_completed` (`exercise_type: typical_error`), `review_started` / `review_completed` (`source: typical_errors`).

## Скільки

| Категорія | Помилок |
|---|---|
| Відмінки (`cases`) | 7 |
| Рід (`gender`) | 5 |
| Вид дієслова (`aspect`) | 2 |
| Порядок слів (`word_order`) | 6 |
| Прийменники (`prepositions`) | 7 |
| Оманливі слова (`false_friends`) | 17 |
| Вимова (`pronunciation`) | 5 |
| Дієслівні конструкції (`verb_patterns`) | 9 |
| Множина (`plural`) | 4 |
| Артиклі (`articles`) | 1 |
| Наголос (`stress`) | 4 |
| Сталі сполучення (`collocations`) | 7 |
| **Разом** | **74** |

За рівнем: A0 — 29, A1 — 42, A2 — 3. Прив’язані до теми граматики — 55, до слова словника — 18 (за ними картки з’являються в уроках).

Артиклі — лише 1 помилка: в українській теж немає артиклів, тож тут помиляються рідко (здебільшого ті, хто вчив англійську).

## Що варто глянути носію

Статус у базі — `PUBLISHED` як бета, за аналогією з уроками A0/A1 (рішення власника про бету стосувалось уроків; для каталогу це треба підтвердити — відкрите рішення в `PROJECT_STATE.md`). Якщо спершу потрібна перевірка носієм — у генераторі `STATUS = 'DRAFT'`, і каталог бачитиме лише адмін. Перед масовим запуском варто показати носію:

- **UKR-HR-0063** — правило «наголос ніколи не на останньому складі» спрощене: у стандарті так, але є запозичення й розмовні винятки;
- **UKR-HR-0064 / 0065 / 0066** — підказки наголосу кирилицею (без тонів: хорватські наголоси мають ще й висоту тону, у картці це не передано);
- **UKR-HR-0058–0062** — підказки вимови кирилицею («ґрад», «кутя») — це наближення;
- **UKR-HR-0072** — «izvaditi krv» (у мові часто кажуть «vaditi krv»: обидва варіанти правильні);
- **UKR-HR-0056** — «Imam sedamdeset kila» (природно розмовне; книжне — «Težak sam sedamdeset kilograma»).

## Каталог

| Код | Категорія | Рівень | Помилка | Неправильно | Правильно |
|---|---|---|---|---|---|
| UKR-HR-0001 | Дієслівні конструкції | A0 | Дієслово biti не пропускаємо | ~~Ja student.~~ | **Ja sam student.** |
| UKR-HR-0002 | Дієслівні конструкції | A0 | Не «ne je», а «nije» | ~~To ne je problem.~~ | **To nije problem.** |
| UKR-HR-0003 | Дієслівні конструкції | A0 | Вік: «imam», а не «meni je» | ~~Meni je trideset godina.~~ | **Imam trideset godina.** |
| UKR-HR-0004 | Дієслівні конструкції | A0 | «У мене є» — це «imam» | ~~U mene je auto.~~ | **Imam auto.** |
| UKR-HR-0005 | Дієслівні конструкції | A0 | «Мене звати» — «zovem se» | ~~Mene zovu Olena.~~ | **Zovem se Olena.** |
| UKR-HR-0006 | Дієслівні конструкції | A1 | «У мене болить» — «boli me» | ~~Kod mene boli glava.~~ | **Boli me glava.** |
| UKR-HR-0007 | Дієслівні конструкції | A1 | «Що» після «думаю, знаю» — це «da» | ~~Mislim što je to dobro.~~ | **Mislim da je to dobro.** |
| UKR-HR-0008 | Дієслівні конструкції | A1 | «Мені подобається» — «sviđa mi se» | ~~Ja sviđam ovaj grad.~~ | **Sviđa mi se ovaj grad.** |
| UKR-HR-0009 | Дієслівні конструкції | A2 | Майбутній час: «ću», а не «budu» | ~~Sutra ja budu raditi.~~ | **Sutra ću raditi.** |
| UKR-HR-0010 | Відмінки | A1 | Куди? — u + знахідний | ~~Idem u školi.~~ | **Idem u školu.** |
| UKR-HR-0011 | Відмінки | A1 | Де? — u + місцевий | ~~Živim u Zagreb.~~ | **Živim u Zagrebu.** |
| UKR-HR-0012 | Відмінки | A1 | Euro відмінюється | ~~Kava košta dva euro.~~ | **Kava košta dva eura.** |
| UKR-HR-0013 | Відмінки | A1 | Puno, malo, koliko + родовий | ~~Imam puno posao.~~ | **Imam puno posla.** |
| UKR-HR-0014 | Відмінки | A1 | Знахідний: kavu, vodu, sobu | ~~Želim kava.~~ | **Želim kavu.** |
| UKR-HR-0015 | Відмінки | A1 | Мови: «govorim hrvatski» | ~~Govorim hrvatskim.~~ | **Govorim hrvatski.** |
| UKR-HR-0016 | Відмінки | A1 | «Про» — o + місцевий | ~~Pričamo o posao.~~ | **Pričamo o poslu.** |
| UKR-HR-0017 | Порядок слів | A0 | Se, mi, ti — на другому місці | ~~Ja zovem se Olena.~~ | **Ja se zovem Olena.** |
| UKR-HR-0018 | Порядок слів | A0 | Речення не починається з «sam», «je» | ~~Sam umoran.~~ | **Umoran sam.** |
| UKR-HR-0019 | Порядок слів | A0 | Li — після дієслова | ~~Li imate sobu?~~ | **Imate li sobu?** |
| UKR-HR-0020 | Порядок слів | A1 | Спершу mi, потім ga | ~~Daj ga mi.~~ | **Daj mi ga.** |
| UKR-HR-0021 | Порядок слів | A1 | «Kako ti je ime?», а не «je ti» | ~~Kako je ti ime?~~ | **Kako ti je ime?** |
| UKR-HR-0022 | Порядок слів | A1 | «Ne bojim se», а не «ne se bojim» | ~~Ne se bojim.~~ | **Ne bojim se.** |
| UKR-HR-0023 | Рід | A0 | Auto — чоловічий рід | ~~Moje auto je novo.~~ | **Moj auto je nov.** |
| UKR-HR-0024 | Рід | A0 | Vrijeme — середній рід | ~~Vrijeme je lijep.~~ | **Vrijeme je lijepo.** |
| UKR-HR-0025 | Рід | A0 | Слова на -ište — середній рід | ~~Kazalište je velik.~~ | **Kazalište je veliko.** |
| UKR-HR-0026 | Рід | A0 | Prtljaga — жіночий рід | ~~Moj prtljaga je težak.~~ | **Moja prtljaga je teška.** |
| UKR-HR-0027 | Рід | A0 | Tata, kolega — чоловічий рід, хоч і на -a | ~~Moja tata je liječnik.~~ | **Moj tata je liječnik.** |
| UKR-HR-0028 | Множина | A0 | Короткі слова: -ovi / -evi | ~~Ovdje su lijepi gradi.~~ | **Ovdje su lijepi gradovi.** |
| UKR-HR-0029 | Множина | A0 | Djeca, braća — як жіночий рід однини | ~~Mali djeca spavaju.~~ | **Mala djeca spavaju.** |
| UKR-HR-0030 | Множина | A0 | Після 2, 3, 4 — закінчення -a | ~~Imam dva brati.~~ | **Imam dva brata.** |
| UKR-HR-0031 | Множина | A1 | Множина: oko → oči, uho → uši | ~~Bole me oke.~~ | **Bole me oči.** |
| UKR-HR-0032 | Вид дієслова | A1 | Те, що зараз, — лише недоконаний вид | ~~Sada napišem pismo.~~ | **Sada pišem pismo.** |
| UKR-HR-0033 | Вид дієслова | A2 | Після «kad» — доконаний вид, а не «ću» | ~~Kad ću doći kući, nazvat ću te.~~ | **Kad dođem kući, nazvat ću te.** |
| UKR-HR-0034 | Прийменники | A1 | «У лікаря» — «kod liječnika» | ~~Ja sam u liječnika.~~ | **Ja sam kod liječnika.** |
| UKR-HR-0035 | Прийменники | A1 | Ігри — без «u» | ~~Igram u nogomet.~~ | **Igram nogomet.** |
| UKR-HR-0036 | Прийменники | A1 | «Залежить від» — «ovisi o» | ~~To ovisi od tebe.~~ | **To ovisi o tebi.** |
| UKR-HR-0037 | Прийменники | A1 | «Думаю про тебе» — «mislim na tebe» | ~~Stalno mislim o tebi.~~ | **Stalno mislim na tebe.** |
| UKR-HR-0038 | Прийменники | A1 | «Сміятися з когось» — без прийменника | ~~Ne smij se s mene.~~ | **Ne smij se meni.** |
| UKR-HR-0039 | Прийменники | A1 | «На факультеті», «на пошті» | ~~Studiram u fakultetu.~~ | **Studiram na fakultetu.** |
| UKR-HR-0040 | Прийменники | A1 | «З роботи» — «s posla» | ~~Dolazim iz posla.~~ | **Dolazim s posla.** |
| UKR-HR-0041 | Оманливі слова | A0 | Godina — це «рік», а не «година» | ~~Film traje dvije godine.~~ | **Film traje dva sata.** |
| UKR-HR-0042 | Оманливі слова | A0 | Čas — це «мить», а «час» — vrijeme | ~~Nemam čas.~~ | **Nemam vremena.** |
| UKR-HR-0043 | Оманливі слова | A1 | Magazin — це журнал | ~~Idem u magazin po kruh.~~ | **Idem u trgovinu po kruh.** |
| UKR-HR-0044 | Оманливі слова | A1 | Ponos — це «гордість» | ~~Dijete ima ponos.~~ | **Dijete ima proljev.** |
| UKR-HR-0045 | Оманливі слова | A0 | Slovo — це «літера» | ~~Ne znam to slovo.~~ | **Ne znam tu riječ.** |
| UKR-HR-0046 | Оманливі слова | A1 | «Лист» (пошта) — pismo | ~~Pišem list mami.~~ | **Pišem pismo mami.** |
| UKR-HR-0047 | Оманливі слова | A1 | «Любити» — voljeti, а ljubiti — «цілувати» | ~~Ljubim kavu.~~ | **Volim kavu.** |
| UKR-HR-0048 | Оманливі слова | A1 | Jagoda — це лише полуниця | ~~Jagode su zdrave: borovnice, maline, kupine.~~ | **Bobice su zdrave: borovnice, maline, kupine.** |
| UKR-HR-0049 | Оманливі слова | A1 | «Правда» — istina | ~~Je li to pravda?~~ | **Je li to istina?** |
| UKR-HR-0050 | Оманливі слова | A0 | Stolica — це стілець | ~~Zagreb je stolica Hrvatske.~~ | **Zagreb je glavni grad Hrvatske.** |
| UKR-HR-0051 | Оманливі слова | A1 | Trudna — це «вагітна» | ~~Ispit je jako trudan.~~ | **Ispit je jako težak.** |
| UKR-HR-0052 | Оманливі слова | A1 | Zavod — це установа, а не завод | ~~Radim na zavodu za automobile.~~ | **Radim u tvornici automobila.** |
| UKR-HR-0053 | Оманливі слова | A1 | Život — це «життя», а живіт — trbuh | ~~Boli me život.~~ | **Boli me trbuh.** |
| UKR-HR-0054 | Оманливі слова | A1 | Stan — це квартира, а «стан» — stanje | ~~Bolesnik je u teškom stanu.~~ | **Bolesnik je u teškom stanju.** |
| UKR-HR-0055 | Оманливі слова | A1 | Brak — це шлюб | ~~Ovaj stol ima brak.~~ | **Ovaj stol je oštećen.** |
| UKR-HR-0056 | Оманливі слова | A1 | Vaga — це терези, а вага — težina | ~~Moja vaga je sedamdeset kila.~~ | **Imam sedamdeset kila.** |
| UKR-HR-0057 | Оманливі слова | A1 | Šutjeti — це «мовчати» | ~~Ne šuti, to je ozbiljno!~~ | **Ne šali se, to je ozbiljno!** |
| UKR-HR-0058 | Вимова | A0 | H — як українське «х» | ~~Hrvatska — «Грватська»~~ | **Hrvatska — «Хрватська»** |
| UKR-HR-0059 | Вимова | A0 | G — тверде «ґ» | ~~grad — «град» (як «гора»)~~ | **grad — «ґрад» (як «ґанок»)** |
| UKR-HR-0060 | Вимова | A0 | Č і ć — різні звуки | ~~kuća — тверде «ч», як у слові «чай»~~ | **kuća — м’яке «ć», майже «кутя»** |
| UKR-HR-0061 | Вимова | A0 | Lj і nj — один м’який звук | ~~ljubav — «л-йубав»~~ | **ljubav — «любав»** |
| UKR-HR-0062 | Вимова | A0 | R без голосної: trg, vrt | ~~trg — «тирг»~~ | **trg — «трг» (протяжне «р»)** |
| UKR-HR-0063 | Наголос | A0 | Наголос ніколи не на останньому складі | ~~voda — «вода́»~~ | **voda — «во́да»** |
| UKR-HR-0064 | Наголос | A0 | Ukrajina — наголос на першому складі | ~~Ukrajina — «Украї́на»~~ | **Ukrajina — «У́країна»** |
| UKR-HR-0065 | Наголос | A0 | Zagreb — наголос на «Za» | ~~Zagreb — «Загре́б»~~ | **Zagreb — «За́греб»** |
| UKR-HR-0066 | Наголос | A1 | Sestra, zima, glava — наголос на першому складі | ~~sestra — «сестра́»~~ | **sestra — «се́стра»** |
| UKR-HR-0067 | Сталі сполучення | A1 | «Приймати душ» — tuširati se | ~~Primam tuš ujutro.~~ | **Tuširam se ujutro.** |
| UKR-HR-0068 | Сталі сполучення | A1 | «Приймати ліки» — uzimati | ~~Primam lijek tri puta dnevno.~~ | **Uzimam lijek tri puta dnevno.** |
| UKR-HR-0069 | Сталі сполучення | A1 | «Поставити питання» — postaviti | ~~Mogu li zadati pitanje?~~ | **Mogu li postaviti pitanje?** |
| UKR-HR-0070 | Сталі сполучення | A1 | «Скласти іспит» — položiti | ~~Moram složiti ispit.~~ | **Moram položiti ispit.** |
| UKR-HR-0071 | Сталі сполучення | A2 | «Прийняти рішення» — donijeti odluku | ~~Moram primiti odluku.~~ | **Moram donijeti odluku.** |
| UKR-HR-0072 | Сталі сполучення | A1 | «Здати кров» — vaditi krv | ~~Moram predati analizu krvi.~~ | **Moram izvaditi krv.** |
| UKR-HR-0073 | Сталі сполучення | A1 | «Сидіти на дієті» — biti na dijeti | ~~Sjedim na dijeti.~~ | **Na dijeti sam.** |
| UKR-HR-0074 | Артиклі | A0 | Артиклів немає — «jedan» не потрібен | ~~Ja sam jedan student iz Ukrajine.~~ | **Ja sam student iz Ukrajine.** |

## Як додати нові помилки

1. Дописати запис у **кінець** `ERRORS` у `scripts/interference_data.py` (коди присвоюються за порядком — старі не змінюються).
2. `python3 scripts/gen_interference.py` → новий SQL; запустити його й тест.
3. Батч не перезаписує наявні коди (`on conflict (code) do nothing`). Виправити вже опубліковану помилку — окремим файлом у `supabase/data_fixes/`: спершу знімок старої версії в `content_versions`, потім `update` і запис у `content_reviews`.
