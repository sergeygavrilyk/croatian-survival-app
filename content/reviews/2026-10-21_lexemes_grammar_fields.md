# Словник `lexemes`: частина мови, рід, вид, normalized — звіт чистки (2026-10-21)

Пакет: `scripts/lexemes_quality_data.py` + `scripts/gen_lexemes_quality_20261021.py` → `supabase/data_fixes/20261021_lexemes_grammar_fields.sql`, тест `supabase/tests/lexemes_grammar_fields.test.sql`.
Приклади — окремий звіт: `content/reviews/2026-10-21_lexemes_examples.md`.

## Зведення (робоча база, 4 074 активних слова, план звірено запитом 2026-10-21)

| Проблема | Було | Після пакета |
|---|---|---|
| Без частини мови або службова мітка (`word`, `other`, `formulaic`, `chunk`) | 1 379 | 0 |
| Хибна частина мови (*čuvati* — «noun», числівники — «noun», *pametan* — «noun», *čiji* — «noun»…) | ~80 | 0 |
| Дієслово без виду або з кодом `unspecified` / `impfv` / `ipf` / `pf` / `ipfv/pfv` | 145 + ~110 | 0 (коди лише `ipfv` / `pfv` / `biasp`) |
| Дієслово з хибним видом (*dogovarati, izgledati, smatrati, uživati, pripadati* — «pfv») | 49 | 0 |
| Іменник без роду | 330 + 724 нових іменники | 0 |
| `normalized` з діакритикою або не з леми (*domaćin, hitna pomod, dogadjaj*) | 633 | 0 (як `normalizeCroatian`: đ → d) |
| Лема з великої, хоча це не власна назва (*Devizni račun, Zastoj, Iskreno*…) | 17 | 0 |
| Слів змінено загалом | — | ≈ 2 160 |

Правила (усе — в `scripts/lexemes_quality_data.py`): ручний список частин мови для ~370 слів; решта службових — за формою (*-ti / -ći*, *-ti se* → дієслово; кілька слів → вираз; одне слово → іменник). Вид — ручний список для всіх ~780 дієслів. Рід — за закінченням (*-ost*, *-a* → ж.; *-o / -e* → с.; приголосний → ч.) + ~80 винятків (*čast, riječ, ljubav, smrt, misao, korist* — ж.; *tata, vođa, sudac, smisao* — ч.; *ljudi, podaci* — ч. мн.; *novine, traperice* — ж. мн.; *usta, prava* — с. мн.).

Точкові виправлення: *vzdahnuti* → **uzdahnuti** («зітхнути»), *ravnatitelj* → **ravnatelj**, *sretan Božić*, *sretna Nova godina*, *ja sam iz Ukrajine*, *karta za Zagreb* (великі літери в лемі й перекладі); переклади *znaš* («ти знаєш», було «ви знаєте»), *predak* («предок», було «предк»), *vidio* («бачив», було «пила»).

Стара версія кожного зміненого слова — у `content_versions`, копія таблиці — `backup.lexemes_20261021`, журнал — `content_reviews`.

## Що варто глянути носію (сумнівне, §81)

- **Двовидові дієслова** (`biasp`): *čuti, vidjeti, kazati, čestitati, vezati, darovati* і запозичення на *-irati* (*organizirati, parkirati, rezervirati, testirati…*). *ručati, večerati, doručkovati, razumjeti* позначено як недоконані — у деяких словниках вони двовидові.
- **Порядкові числівники** (*prvi, drugi, četvrti, deseti…*) — «числівник», як в українській граматиці (у хорватській — *redni brojevi*, відмінюються як прикметники).
- **bi** — «частка» (насправді форма дієслова *biti* для умовного способу); **posto**, **puta** — «прислівник».
- **Форми слів як окремі леми**: *je, jesi, moram, trebam, volim, želim, želiš, znam, znaš, vidimo, vidio, hoćemo* — позначено «дієслово» з видом інфінітива.
- **bijelo, crno, crveno, plavo, sivo, zeleno, žuto, staro, novo…** — «прикметник» (форма середнього роду); переклад у словнику — чоловічого роду («білий»).

## Потрібне рішення власника (не змінено — видалення лише DEPRECATED і з дозволу)

Дублікати, одруківки й форми слів, яких немає в уроках і прогресі користувачів (перевірено 2026-10-21: `lesson_items` = 0, `user_progress` = 0):

| Лема | Що не так | Пропозиція |
|---|---|---|
| *budilika* | одруківка, є *budilica* | DEPRECATED |
| *dijaloz -> dijalog* | сміття в лемі, є *dijalog* | DEPRECATED |
| *posati* | одруківка, є *poslati* | DEPRECATED |
| *smijeti* | нестандартна форма, є *smjeti* | DEPRECATED |
| *novom*, *onom*, *restoranu*, *tisuću* | відмінкові форми, є *novi*, *onaj*, *restoran*, *tisuća* | DEPRECATED |
| *stvari*, *police* | множина, є *stvar*, *polica* | DEPRECATED |
| *prometna* | «трафік» — обрізане словосполучення | DEPRECATED |
| *glatak* | варіант стандартного *gladak* | DEPRECATED або лишити з позначкою |

Також у фразах A0 є розмовні слова: *gdje je apoteka* (стандартно *ljekarna*), *ovdje je moj pasoš* (*putovnica*), *zadržite kusur* (*ostatak*) — лишити з позначкою чи замінити.
