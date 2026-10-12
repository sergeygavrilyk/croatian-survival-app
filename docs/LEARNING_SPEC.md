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
