<!-- Джерело: Croatia_survival_UPDATED.docx (ТЗ). Розділи збережені з оригінальною нумерацією. Редагуйте тут — це тепер джерело правди. -->

# Методика навчання і словник

Наукова основа (CEFR, retrieval, spacing, extensive reading), learning loop, рівні, цілі по лексиці, алгоритм відбору слів, типи лексики, база типових помилок українців.

## 3. Методологічна основа

Система використовує комбінацію перевірених підходів, а не одну «чарівну методику».

**3.1 CEFR**

CEFR використовується для:
- визначення learning outcomes;
- progression;
- assessment;
- skill descriptors;
- level mapping.

CEFR Companion Volume розширює класичну модель, включаючи interaction, online interaction та mediation.

Тому система повинна розвивати не лише:

Vocabulary

Grammar

а:

- Reception
- Production
- Interaction
- Mediation

## 4. Learning Science

**4.1 Retrieval Practice**

Користувач повинен регулярно **витягувати інформацію з пам'яті**, а не лише повторно її читати.

Приклад:

Погано:

Croatian: račun

Ukrainian: рахунок

Краще:

«Як сказати "рахунок" у ресторані?»

Ще краще:

Audio → user identifies → produces phrase → uses in sentence.

## 5. Spaced Practice

Кожен важливий learning item має власну історію засвоєння.

Spacing має значний позитивний ефект для L2 learning; метааналіз 48 експериментів і 3 411 учасників показав medium-to-large effect spaced practice.

Тому:

Learn → Recall → Review → Delayed Recall → Production → Long-term Retention

## 6. Extensive Reading

Починаючи приблизно з A1/A2, користувач отримує адаптовані тексти. Матеріали:
- діалоги;
- повідомлення;
- оголошення;
- короткі статті;
- історії;
- побутові тексти;
- хорватські новини відповідного рівня;
- інструкції;
- email;
- чати.

Extensive reading має позитивні ефекти не лише на reading, а й на vocabulary, writing, oral proficiency та загальну мовну компетентність.

## 7. Основний Learning Loop

INPUT → UNDERSTAND → RETRIEVE → REPEAT → PRODUCE → COMMUNICATE → FEEDBACK → SRS → REAL-LIFE USE

## 11. Learning Architecture

Навчання складається з 8 parallel dimensions:

- Vocabulary
- Grammar
- Listening
- Reading
- Speaking
- Writing
- Interaction
- Mediation

Користувач не обов'язково проходить їх однаково швидко.

## 12. Levels

**A0**

Survival Croatian.

**A1**

Basic everyday communication.

**A2**

Independent everyday communication.

**B1**

Functional independent communication.

**B2**

Upper-intermediate communication, argumentation and complex interaction.

## 13. Target Vocabulary

Ціль:

**~10 000 high-value lexical items**

Але database повинна відрізняти:

- lemma
- inflected form
- lexical family
- phrase
- collocation
- multiword expression
- proper noun
- function word

Наприклад:

- raditi
- radi
- radim
- radio
- radila
- radili

не повинні рахуватися як шість незалежних vocabulary concepts.

## 14. Vocabulary Distribution

Початковий planning target:

**Level New lexical**

**concepts**

- A0 500
- A1 1 000
- A2 2 000
- B1 2 750
- B2 3 750

**Total 10 000**

Це planning target, а не жорстка вимога.

Фактичний розподіл визначається frequency + coverage + curriculum.

## 15. Vocabulary Selection Algorithm

Кожен candidate item отримує:

frequency + dispersion + usefulness + CEFR relevance + spoken relevance + Croatia relevance + topic relevance + collocation value

+

learner difficulty

AI не може просто взяти перші 10 000 слів словника.

## 16. Coverage Validation

Створити corpus coverage engine.

Він повинен оцінювати:

- Coverage(all words)
- Coverage(spoken)
- Coverage(everyday)
- Coverage(news)
- Coverage(work)
- Coverage(administration)

Окремо:

- lemma coverage
- token coverage
- unknown-token rate

Ціль:

максимально збільшувати practical comprehension coverage, а не просто кількість слів.

## 18. Vocabulary Types

Database повинна мати окремі типи:

**Core vocabulary**

Основні слова.

**Function words**
- je;
- sam;
- i;
- ali;
- da;
- ne;
- se;
- etc.

**Formulaic language**
- kako si;
- nema problema;
- nema veze;
- vidimo se;
- čujemo se.

**Collocations**
- donijeti odluku;
- platiti račun;
- imati vremena.

**Chunks**

Слова, які краще запам'ятовувати як конструкцію.

**Маркування живої лексики** (рішення власника 2026-11-12: «Мені подобається ідея з додаванням категорії лексики»; модель — документ власника від 2026-11-12 з уточненнями, `docs/proposals/2026-11-12_b1_b2_dialogues_reading_situations.md` §4; схема — міграція M24, PROPOSE). Незалежні виміри, а не одна категорія:

- `register` — **як** уживають: `standard`, `formal`, `informal` (літературне, але неофіційне), `colloquial` (розмовне, нелітературне), `slang` (мова групи), `vulgar` (лише впізнавати, B2);
- `regionality` — **де**: `general` (загальне), `Zagreb`, `Zagorje`, `Dalmatia`, `Istria`, `Kvarner`, `Slavonia`, `Lika`, `Dubrovnik`;
- `usage_tags` — **додаткові ознаки** (кілька; `{}` — ознак немає): `youth_slang`, `internet_slang`, `professional_jargon`, `anglicism`, `italianism`, `germanism`, `turkism`, `idiom`, `kajkavian`, `chakavian`;
- `vocabulary_type` — структура (вище), **без змін**; стандартний відповідник — зв'язок з іншою лексемою (`standard_lexeme_id`);
- «вживати чи лише впізнавати» — властивість **уроку**, не слова: `lesson_items.target_skill = 'recognition'`; дата перевірки актуальності сленгу — `content_reviews`;
- ті самі `register`, `regionality`, `usage_tags` — і для речень у `phrases`;
- **явні значення в кожному слові й реченні** (рішення власника 2026-11-13): порожнє — лише «ще не розмічено» на час переходу; після розмітки всіх наявних слів (до B1) поля **обов'язкові, без значення за замовчуванням**; стара версія кожної позначки — `content_versions`.

## 19. Ukrainian Interference Engine

Для українців створюється окрема база типових помилок. Категорії:

- Cases
- Gender
- Aspect
- Word order
- Prepositions
- False friends
- Pronunciation
- Verb patterns
- Plural
- Articles/absence of articles
- Stress
- Collocations

Приклад:

```yaml
error:
id: UKR-HR-0001
type: false_friend
incorrect:
```

...

correct:

...

explanation_uk:

...

examples:

...
