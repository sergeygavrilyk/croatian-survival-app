#!/usr/bin/env python3
"""
Сленг і модуль «18+» (рішення власника 2026-11-13) — список кандидатів зі звіркою з робочою базою.

  python3 -B scripts/gen_live_lexicon_20261113.py --query   → SQL для звірки (лише читання, select)
  python3 -B scripts/gen_live_lexicon_20261113.py           → content/reviews/2026-11-13_slang_18plus_list.md
                                                             (знімок бази — scripts/live_lexicon_20261113_snapshot.json)

Основа: рішення власника 2026-11-13 (сленг — окремі модулі B1 / B2, не менше 300 одиниць; модуль «18+» —
5 уроків, образливі слова про групи людей — включено, лише впізнавання), приклад списку від власника
(Загреб / Далмація / молодіжний, 300 слів), модель маркування docs/proposals/2026-11-12_b1_b2_dialogues_reading_situations.md §4.1.
Це ще не SQL-пакет: після перевірки списку — батч слів (croatian-lexeme-batch) з прикладами й поясненнями.

Позначки в примітці: «нз» — у базі, мабуть, є це слово з іншим значенням (нове значення, не нова лема);
«?» — перевірити носієм (чи вживають так, значення, написання).
Перевірки: латиниця в лемі, українське в перекладі, дублікати лем (без урахування регістру), значення
register / regionality / usage_tags / part_of_speech — з переліків, 20–25 одиниць в уроці модулів, ≥ 300 сленгу.
"""
from __future__ import annotations

import json
import re
import sys
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / 'content' / 'reviews' / '2026-11-13_slang_18plus_list.md'
SNAP = ROOT / 'scripts' / 'live_lexicon_20261113_snapshot.json'

REGISTERS = {'standard', 'formal', 'informal', 'colloquial', 'slang', 'vulgar'}
REGIONS = {'general', 'Zagreb', 'Zagorje', 'Dalmatia', 'Istria', 'Kvarner', 'Slavonia', 'Lika', 'Dubrovnik'}
TAGS = {'youth_slang', 'internet_slang', 'professional_jargon', 'anglicism', 'italianism', 'germanism',
        'turkism', 'idiom', 'kajkavian', 'chakavian'}
POS = {'noun', 'verb', 'adjective', 'adverb', 'pronoun', 'preposition', 'conjunction', 'particle',
       'interjection', 'number', 'phrase'}

# код уроку → (модуль, назва уроку)
LESSONS = {
    'S1': ('B1 · Сленг: живий хорватський', '1. Реакції й вигуки між друзями'),
    'S2': ('B1 · Сленг: живий хорватський', '2. Люди й звертання'),
    'S3': ('B1 · Сленг: живий хорватський', '3. Гроші, робота, навчання'),
    'S4': ('B1 · Сленг: живий хорватський', '4. Вечірка, їжа, напої'),
    'S5': ('B1 · Сленг: живий хорватський', '5. Загреб: пургерський сленг'),
    'S6': ('B1 · Сленг: живий хорватський', '6. Далмація: сленг узбережжя'),
    'Z1': ('B2 · Živi hrvatski I', '1. Інтернет і соцмережі'),
    'Z2': ('B2 · Živi hrvatski I', '2. Молодіжний сленг'),
    'Z3': ('B2 · Živi hrvatski I', '3. Почуття, оцінки, стосунки'),
    'Z4': ('B2 · Živi hrvatski I', '4. Англіцизми в розмові й на роботі'),
    'R':  ('Тексти, діалоги, рубрика «Živi hrvatski»', 'Решта: регіональні слова, нагадування, розмовне'),
    'Q':  ('На перевірку носієм', 'Сумнівні слова з прикладу власника — чи вживають так у хорватській'),
    'X1': ('B1 · 18+', '1. Як і чому лаються: найчастіші слова'),
    'X2': ('B1 · 18+', '2. Вигуки, підсилювачі й пом\'якшені замінники'),
    'X3': ('B1 · 18+', '3. Образи — розпізнати й відреагувати'),
    'X4': ('B1 · 18+', '4. Лайка з релігійними словами'),
    'X5': ('B1 · 18+', '5. Сталі вирази й діалоги'),
}

G, Z, D = 'general', 'Zagreb', 'Dalmatia'
# (лема, переклад, частина мови, register, regionality, usage_tags, примітка)
DATA: dict[str, list[tuple]] = {
'S1': [
    ('ajde', 'давай; ну; ходімо', 'interjection', 'informal', G, (), 'вживати'),
    ('ma daj', 'та ну; не може бути', 'phrase', 'colloquial', G, (), 'вживати'),
    ('ma nemoj', 'та невже; не кажи', 'phrase', 'colloquial', G, (), ''),
    ('nema šanse', 'нізащо; без шансів', 'phrase', 'colloquial', G, (), 'вживати'),
    ('nema frke', 'без проблем; не хвилюйся', 'phrase', 'colloquial', G, (), 'вживати'),
    ('kako god', 'як скажеш; байдуже', 'phrase', 'colloquial', G, (), ''),
    ('nemam pojma', 'гадки не маю', 'phrase', 'colloquial', G, (), 'вживати'),
    ('sve pet', 'усе чудово; на п\'ять', 'phrase', 'colloquial', G, (), ''),
    ('fakat', 'справді; реально', 'adverb', 'colloquial', G, (), ''),
    ('joj', 'ой', 'interjection', 'informal', G, (), ''),
    ('ajme', 'ой леле; ой', 'interjection', 'colloquial', G, (), ''),
    ('bome', 'ще й як; авжеж', 'particle', 'colloquial', G, (), ''),
    ('kužiti', 'розуміти; «шарити»', 'verb', 'colloquial', G, (), ''),
    ('skužiti', 'допетрати; зрозуміти', 'verb', 'colloquial', G, (), ''),
    ('kužiš?', 'розумієш?; шариш?', 'phrase', 'colloquial', G, (), ''),
    ('strava', 'жах; жахіття', 'noun', 'colloquial', G, (), '? у молоді буває й «супер»'),
    ('koma', 'кошмар; жах (про стан, ситуацію)', 'noun', 'slang', G, ('youth_slang',), 'нз (кома)'),
    ('bezveze', 'безглуздо; ні про що', 'adverb', 'colloquial', G, (), ''),
    ('svaka čast', 'респект; молодець', 'phrase', 'colloquial', G, (), 'вживати'),
    ('boli me briga', 'мені байдуже', 'phrase', 'colloquial', G, (), 'пом\'якшене (грубе — у «18+»)'),
    ('ma pusti', 'та облиш; не зважай', 'phrase', 'colloquial', G, (), ''),
    ('opusti se', 'розслабся; не нервуй', 'phrase', 'informal', G, (), ''),
],
'S2': [
    ('stari', 'старий; чувак (звертання до друга)', 'noun', 'colloquial', G, (), 'нз (stari — старий)'),
    ('stara', 'мама; подруга (розм.)', 'noun', 'colloquial', G, (), 'нз'),
    ('starci', 'батьки; «предки»', 'noun', 'colloquial', G, (), ''),
    ('buraz', 'братан; бро', 'noun', 'slang', G, ('turkism',), ''),
    ('brate', 'брате; братан (звертання)', 'interjection', 'colloquial', G, (), 'кличний від brat'),
    ('frend', 'друг; кореш', 'noun', 'slang', G, ('youth_slang', 'anglicism'), ''),
    ('frendica', 'подруга', 'noun', 'slang', G, ('youth_slang', 'anglicism'), ''),
    ('ekipa', 'компанія друзів; тусовка', 'noun', 'colloquial', G, (), 'нз (команда)'),
    ('škvadra', 'компанія; банда (друзів)', 'noun', 'colloquial', G, ('italianism',), ''),
    ('lik', 'тип; персонаж (про людину)', 'noun', 'slang', G, (), 'нз (образ, фігура)'),
    ('tip', 'чувак; хлопець', 'noun', 'colloquial', G, (), 'нз (тип)'),
    ('cura', 'дівчина; кохана', 'noun', 'colloquial', G, (), ''),
    ('klinac', 'малий; дитина', 'noun', 'colloquial', G, (), ''),
    ('klinka', 'мала; дівчинка', 'noun', 'colloquial', G, (), ''),
    ('frajer', 'крутий хлопець; хлопець', 'noun', 'colloquial', G, ('germanism',), ''),
    ('faca', 'важна персона; «фейс»', 'noun', 'colloquial', G, ('italianism',), ''),
    ('štreber', 'зубрила; ботанік', 'noun', 'colloquial', G, ('germanism',), ''),
    ('papak', 'лох; селюк', 'noun', 'slang', Z, (), 'образливе'),
    ('papučar', 'підкаблучник', 'noun', 'colloquial', G, (), ''),
    ('šminker', 'модник; мажор', 'noun', 'slang', Z, ('germanism',), ''),
    ('gazda', 'хазяїн; бос', 'noun', 'colloquial', G, (), ''),
    ('legenda', 'молодець; легенда (про людину)', 'noun', 'colloquial', G, (), 'нз (легенда)'),
    ('kralj', 'красень; король (похвала)', 'noun', 'colloquial', G, (), 'нз (король)'),
],
'S3': [
    ('lova', 'гроші; бабло', 'noun', 'slang', G, (), ''),
    ('kinta', 'гроші; копійки', 'noun', 'slang', G, (), ''),
    ('keš', 'готівка; кеш', 'noun', 'slang', G, ('anglicism',), ''),
    ('som', 'тисяча (євро)', 'noun', 'slang', G, (), 'нз (сом)'),
    ('cener', 'десятка (десять євро)', 'noun', 'slang', Z, ('germanism',), ''),
    ('šljaka', 'робота; гарування', 'noun', 'slang', G, (), ''),
    ('šljakati', 'працювати; гарувати', 'verb', 'slang', G, (), ''),
    ('rintati', 'тяжко працювати; горбатитися', 'verb', 'colloquial', G, (), ''),
    ('fuš', 'халтура; підробіток', 'noun', 'colloquial', G, ('germanism',), ''),
    ('fušati', 'халтурити; підробляти', 'verb', 'colloquial', G, ('germanism',), ''),
    ('šverc', 'контрабанда; «чорна» торгівля', 'noun', 'colloquial', G, ('germanism',), ''),
    ('na crno', 'неофіційно; «в чорну»', 'phrase', 'colloquial', G, ('idiom',), ''),
    ('bauštela', 'будова; будмайданчик', 'noun', 'colloquial', G, ('germanism',), ''),
    ('faks', 'університет; факультет', 'noun', 'colloquial', G, (), ''),
    ('štrebati', 'зубрити', 'verb', 'colloquial', G, ('germanism',), ''),
    ('markirati', 'прогулювати (уроки, пари)', 'verb', 'colloquial', G, (), 'у базі вже це значення'),
    ('kiks', 'промах; провал', 'noun', 'slang', G, (), ''),
    ('fulati', 'схибити; помилитися', 'verb', 'colloquial', G, (), ''),
    ('zeznuti', 'напартачити; обдурити', 'verb', 'colloquial', G, (), ''),
    ('zeznuti se', 'помилитися; схибити', 'verb', 'colloquial', G, (), ''),
    ('mobić', 'мобільник', 'noun', 'colloquial', G, (), ''),
    ('kompić', 'комп; компік', 'noun', 'colloquial', G, (), ''),
],
'S4': [
    ('cuga', 'випивка; алкоголь', 'noun', 'slang', G, ('germanism',), ''),
    ('cugati', 'випивати; бухати', 'verb', 'slang', G, ('germanism',), ''),
    ('tulum', 'вечірка (вдома); тусовка', 'noun', 'colloquial', G, (), ''),
    ('tulumariti', 'гуляти на вечірці; тусуватися', 'verb', 'colloquial', G, (), ''),
    ('klopa', 'їжа; харчі', 'noun', 'slang', G, (), ''),
    ('klopati', 'їсти; хавати', 'verb', 'slang', G, (), ''),
    ('pljuga', 'цигарка', 'noun', 'slang', G, (), ''),
    ('birtija', 'забігайлівка; простий бар', 'noun', 'colloquial', G, ('germanism',), ''),
    ('špricer', 'вино з содовою', 'noun', 'colloquial', G, ('germanism',), ''),
    ('runda', 'коло (випивки за рахунок одного)', 'noun', 'colloquial', G, (), ''),
    ('mamuran', 'з похмілля', 'adjective', 'colloquial', G, (), ''),
    ('pijan kao čep', 'п\'яний як чіп', 'phrase', 'colloquial', G, ('idiom',), ''),
    ('nacvrcan', 'підпилий; напідпитку', 'adjective', 'colloquial', G, (), ''),
    ('ludnica', 'шалено; божевілля (весело)', 'noun', 'colloquial', G, (), ''),
    ('đuskati', 'танцювати; витанцьовувати', 'verb', 'colloquial', G, (), ''),
    ('kavica', 'кавочка', 'noun', 'informal', G, (), 'вживати (Idemo na kavicu)'),
    ('pivce', 'пивко', 'noun', 'informal', G, (), ''),
    ('zezati', 'підколювати; жартувати з когось', 'verb', 'colloquial', G, (), ''),
    ('zezancija', 'прикол; жарти', 'noun', 'colloquial', G, (), ''),
    ('fora', 'прикол; фішка', 'noun', 'slang', G, (), ''),
    ('štos', 'прикол; фокус; дотеп', 'noun', 'colloquial', G, ('germanism',), ''),
],
'S5': [
    ('kaj', 'що', 'pronoun', 'colloquial', Z, ('kajkavian',), ''),
    ('kaj ima?', 'що нового?; як справи?', 'phrase', 'colloquial', Z, ('kajkavian',), ''),
    ('kak', 'як', 'adverb', 'colloquial', Z, ('kajkavian',), ''),
    ('kam', 'куди', 'adverb', 'colloquial', Z, ('kajkavian',), ''),
    ('purger', 'корінний загребчанин', 'noun', 'colloquial', Z, ('germanism',), 'у списку власника — «Perger», правильно Purger'),
    ('špica', 'суботня прогулянка в центрі Загреба', 'noun', 'colloquial', Z, (), 'нз (вершина; час пік)'),
    ('gablec', 'ранній обід; перекус', 'noun', 'colloquial', Z, ('kajkavian',), ''),
    ('gemišt', 'біле вино з газованою водою', 'noun', 'colloquial', Z, (), ''),
    ('fajn', 'гарно; добре; файно', 'adverb', 'colloquial', Z, ('germanism',), ''),
    ('ziher', 'точно; напевно', 'adverb', 'colloquial', Z, ('germanism',), ''),
    ('cug', 'потяг; протяг', 'noun', 'colloquial', Z, ('germanism',), ''),
    ('cajt', 'час', 'noun', 'colloquial', Z, ('germanism',), 'Nemam cajta.'),
    ('fertik', 'готово; закінчено', 'adjective', 'colloquial', Z, ('germanism',), ''),
    ('šlampav', 'неохайний; недбалий', 'adjective', 'colloquial', G, ('germanism',), ''),
    ('šlag', 'збиті вершки', 'noun', 'colloquial', Z, ('germanism',), ''),
    ('špajza', 'комора', 'noun', 'colloquial', Z, ('germanism',), ''),
    ('vešmašina', 'пральна машина', 'noun', 'colloquial', Z, ('germanism',), ''),
    ('šparati', 'економити; відкладати', 'verb', 'colloquial', Z, ('germanism',), ''),
    ('flaša', 'пляшка', 'noun', 'colloquial', G, ('germanism',), ''),
    ('pajdaš', 'приятель; дружбан', 'noun', 'colloquial', Z, (), ''),
    ('čaga', 'танці; вечірка', 'noun', 'slang', Z, (), ''),
    ('brija', 'тема; настрій; тусовка', 'noun', 'slang', Z, (), ''),
    ('brijati', 'думати, вважати; тусуватися', 'verb', 'slang', Z, (), 'нз (голити)'),
    ('špreha', 'балачка; вміння заговорити', 'noun', 'slang', Z, ('germanism',), '?'),
    ('dečec', 'хлопчик', 'noun', 'colloquial', 'Zagorje', ('kajkavian',), ''),
],
'S6': [
    ('ča', 'що', 'pronoun', 'colloquial', D, ('chakavian',), 'також Істрія, Кварнер, острови'),
    ('di', 'де', 'adverb', 'colloquial', D, (), 'також по всій країні в розмові (Di si)'),
    ('đir', 'прогулянка; коло; поїздка', 'noun', 'colloquial', D, ('italianism',), ''),
    ('ćakula', 'балачка; плітки', 'noun', 'colloquial', D, ('italianism',), ''),
    ('ćakulati', 'базікати', 'verb', 'colloquial', D, ('italianism',), ''),
    ('šoldi', 'гроші', 'noun', 'colloquial', D, ('italianism',), ''),
    ('fešta', 'свято; гулянка', 'noun', 'colloquial', D, ('italianism',), ''),
    ('bevanda', 'вино, розбавлене водою', 'noun', 'colloquial', D, ('italianism',), ''),
    ('balun', 'м\'яч; футбол', 'noun', 'colloquial', D, ('italianism',), ''),
    ('furešti', 'туристи; чужинці', 'noun', 'colloquial', D, ('italianism',), ''),
    ('vlaj', 'житель Загори (не з узбережжя)', 'noun', 'colloquial', D, (), 'буває зневажливо'),
    ('bodul', 'острів\'янин', 'noun', 'colloquial', D, (), ''),
    ('barba', 'дядько; звертання до старшого чоловіка', 'noun', 'colloquial', D, ('italianism',), ''),
    ('nono', 'дідусь', 'noun', 'colloquial', D, ('italianism',), ''),
    ('nona', 'бабуся', 'noun', 'colloquial', D, ('italianism',), ''),
    ('ćaća', 'тато', 'noun', 'colloquial', D, (), ''),
    ('mulac', 'хлопчина; шибеник', 'noun', 'colloquial', D, (), ''),
    ('mandrilo', 'бовдур (жартома)', 'noun', 'colloquial', D, (), ''),
    ('priša', 'поспіх', 'noun', 'colloquial', D, ('italianism',), ''),
    ('nema priše', 'не поспішай; немає поспіху', 'phrase', 'colloquial', D, ('italianism',), ''),
    ('lipo', 'гарно', 'adverb', 'colloquial', D, (), 'ікавське: стандартно lijepo'),
    ('škovace', 'сміття', 'noun', 'colloquial', D, ('italianism',), ''),
    ('bonaca', 'штиль (на морі)', 'noun', 'colloquial', D, ('italianism',), ''),
    ('kaleta', 'вузька кам\'яна вуличка', 'noun', 'colloquial', D, (), ''),
    ('peškarija', 'рибний ринок', 'noun', 'colloquial', D, ('italianism',), ''),
],
'Z1': [
    ('lajk', 'лайк; вподобайка', 'noun', 'slang', G, ('internet_slang', 'anglicism'), ''),
    ('lajkati', 'лайкати; вподобати', 'verb', 'slang', G, ('internet_slang', 'anglicism'), ''),
    ('šerati', 'поширювати; шерити', 'verb', 'slang', G, ('internet_slang', 'anglicism'), ''),
    ('folovati', 'підписатися (у соцмережі)', 'verb', 'slang', G, ('internet_slang', 'anglicism'), ''),
    ('anfolovati', 'відписатися', 'verb', 'slang', G, ('internet_slang', 'anglicism'), ''),
    ('skrolati', 'гортати стрічку', 'verb', 'slang', G, ('internet_slang', 'anglicism'), ''),
    ('postati', 'публікувати допис; постити', 'verb', 'slang', G, ('internet_slang', 'anglicism'), 'нз (стати)'),
    ('storij', 'сторіз (в Instagram)', 'noun', 'slang', G, ('internet_slang', 'anglicism'), '? написання'),
    ('mem', 'мем', 'noun', 'slang', G, ('internet_slang', 'anglicism'), '? написання'),
    ('viralan', 'вірусний (популярний у мережі)', 'adjective', 'colloquial', G, ('internet_slang',), ''),
    ('influenser', 'інфлюенсер', 'noun', 'colloquial', G, ('anglicism',), ''),
    ('trol', 'троль (в інтернеті)', 'noun', 'slang', G, ('internet_slang', 'anglicism'), ''),
    ('trolati', 'тролити', 'verb', 'slang', G, ('internet_slang', 'anglicism'), ''),
    ('hejt', 'хейт; цькування', 'noun', 'slang', G, ('internet_slang', 'anglicism'), ''),
    ('hejtati', 'хейтити', 'verb', 'slang', G, ('internet_slang', 'anglicism'), ''),
    ('hejter', 'хейтер', 'noun', 'slang', G, ('internet_slang', 'anglicism'), ''),
    ('gejmati', 'грати у відеоігри', 'verb', 'slang', G, ('youth_slang', 'anglicism'), '? написання (gamati)'),
    ('gejmer', 'геймер', 'noun', 'slang', G, ('youth_slang', 'anglicism'), ''),
    ('nub', 'нуб; новачок', 'noun', 'slang', G, ('internet_slang', 'anglicism'), ''),
    ('čekirati', 'перевірити; зачекінитись', 'verb', 'slang', G, ('anglicism',), ''),
    ('guglati', 'гуглити', 'verb', 'colloquial', G, ('internet_slang', 'anglicism'), '? guglati / guglati'),
    ('apdejt', 'оновлення; апдейт', 'noun', 'slang', G, ('internet_slang', 'anglicism'), '? написання'),
],
'Z2': [
    ('krindž', 'кринж; іспанський сором', 'noun', 'slang', G, ('youth_slang', 'anglicism'), ''),
    ('fleksati', 'хизуватися; понтуватися', 'verb', 'slang', G, ('youth_slang', 'anglicism'), ''),
    ('čilati', 'чілити; відпочивати', 'verb', 'slang', G, ('youth_slang', 'anglicism'), ''),
    ('vajb', 'вайб; атмосфера', 'noun', 'slang', G, ('youth_slang', 'anglicism'), ''),
    ('hajp', 'хайп; ажіотаж', 'noun', 'slang', G, ('youth_slang', 'anglicism'), ''),
    ('fejk', 'фейк; підробка', 'noun', 'slang', G, ('internet_slang', 'anglicism'), 'є в рубриці B1.7'),
    ('random', 'випадковий; рандомний', 'adjective', 'slang', G, ('youth_slang', 'anglicism'), ''),
    ('kraš', 'краш; об\'єкт симпатії', 'noun', 'slang', G, ('youth_slang', 'anglicism'), ''),
    ('gaser', 'гасер (хлопець у брендовому спортивному, реп)', 'noun', 'slang', G, ('youth_slang',), ''),
    ('gaserka', 'гасерка', 'noun', 'slang', G, ('youth_slang',), ''),
    ('smor', 'нудьга; нудна людина', 'noun', 'slang', G, ('youth_slang',), ''),
    ('smarati', 'набридати; занудствувати', 'verb', 'slang', G, ('youth_slang',), ''),
    ('bro', 'бро; братан', 'noun', 'slang', G, ('youth_slang', 'anglicism'), ''),
    ('toksičan', 'токсичний (про людину, стосунки)', 'adjective', 'colloquial', G, ('youth_slang',), ''),
    ('ludilo', 'супер; божевілля (захват)', 'noun', 'colloquial', G, (), 'нз (божевілля)'),
    ('top', 'топ; найкраще', 'adjective', 'slang', G, ('youth_slang', 'anglicism'), 'нз (гармата)'),
    ('šema', 'тема; схема; план', 'noun', 'slang', G, (), ''),
    ('daj gas', 'давай, жени; погнали', 'phrase', 'slang', G, ('youth_slang',), ''),
    ('zbediran', 'пригнічений; засмучений', 'adjective', 'slang', G, ('youth_slang',), ''),
    ('depra', 'депресуха; поганий настрій', 'noun', 'slang', G, ('youth_slang',), ''),
    ('bejsik', 'банальний; звичайний', 'adjective', 'slang', G, ('youth_slang', 'anglicism'), '?'),
    ('izblamirati se', 'зганьбитися; осоромитися', 'verb', 'colloquial', G, (), ''),
],
'Z3': [
    ('blam', 'ганьба; сором', 'noun', 'slang', G, ('youth_slang',), ''),
    ('puknuti', 'зірватися; не витримати', 'verb', 'colloquial', G, (), 'нз (тріснути)'),
    ('štanga', 'облом; невдача', 'noun', 'slang', G, (), 'нз (штанга)'),
    ('nabrijan', 'заведений; налаштований', 'adjective', 'slang', G, (), ''),
    ('skulirati se', 'заспокоїтися; охолонути', 'verb', 'slang', G, ('anglicism',), ''),
    ('kul', 'круто; спокійно', 'adjective', 'slang', G, ('youth_slang', 'anglicism'), ''),
    ('furati', 'носити (стиль); гнати', 'verb', 'slang', G, (), ''),
    ('fura', 'стиль; фішка', 'noun', 'slang', G, (), ''),
    ('frik', 'фанат; «фрік» (чогось)', 'noun', 'slang', G, ('anglicism',), ''),
    ('muvati', 'клеїти; фліртувати', 'verb', 'slang', G, (), ''),
    ('smuvati', 'закадрити', 'verb', 'slang', G, (), ''),
    ('hodati', 'зустрічатися (з кимось)', 'verb', 'colloquial', G, (), 'нз (ходити)'),
    ('šutnuti', 'кинути (хлопця, дівчину)', 'verb', 'colloquial', G, (), 'нз (копнути)'),
    ('ljubakati se', 'цілуватися; обійматися', 'verb', 'colloquial', G, (), ''),
    ('riba', 'гарна дівчина', 'noun', 'slang', G, (), 'нз (риба); може звучати зневажливо'),
    ('frajerski', 'круто; по-пацанськи', 'adverb', 'colloquial', G, (), ''),
    ('zeznut', 'складний; хитрий', 'adjective', 'colloquial', G, (), ''),
    ('ljut kao ris', 'злий як чорт', 'phrase', 'colloquial', G, ('idiom',), ''),
    ('crknuti', 'здохнути (від утоми); зламатися', 'verb', 'colloquial', G, (), ''),
    ('krepati', 'здохнути; дуже втомитися', 'verb', 'colloquial', G, ('italianism',), ''),
    ('ispaliti', 'підвести; не прийти', 'verb', 'colloquial', G, (), 'нз (вистрілити)'),
],
'Z4': [
    ('mejl', 'імейл; лист', 'noun', 'colloquial', G, ('professional_jargon', 'anglicism'), ''),
    ('mejlati', 'писати імейл', 'verb', 'colloquial', G, ('professional_jargon', 'anglicism'), ''),
    ('miting', 'нарада; мітинг', 'noun', 'colloquial', G, ('professional_jargon', 'anglicism'), ''),
    ('dedlajn', 'дедлайн; крайній строк', 'noun', 'colloquial', G, ('professional_jargon', 'anglicism'), ''),
    ('fidbek', 'відгук; фідбек', 'noun', 'colloquial', G, ('professional_jargon', 'anglicism'), ''),
    ('task', 'завдання; таска', 'noun', 'slang', G, ('professional_jargon', 'anglicism'), '?'),
    ('brifing', 'брифінг; короткий інструктаж', 'noun', 'colloquial', G, ('professional_jargon', 'anglicism'), ''),
    ('kol', 'дзвінок; відеодзвінок (call)', 'noun', 'slang', G, ('professional_jargon', 'anglicism'), '?'),
    ('hendlati', 'розрулювати; впоратися', 'verb', 'slang', G, ('professional_jargon', 'anglicism'), ''),
    ('brejnstorming', 'мозковий штурм', 'noun', 'colloquial', G, ('professional_jargon', 'anglicism'), '? написання'),
    ('netvorking', 'нетворкінг', 'noun', 'colloquial', G, ('professional_jargon', 'anglicism'), ''),
    ('frilenser', 'фрилансер', 'noun', 'colloquial', G, ('professional_jargon', 'anglicism'), ''),
    ('startap', 'стартап', 'noun', 'colloquial', G, ('professional_jargon', 'anglicism'), ''),
    ('dil', 'угода; домовленість', 'noun', 'slang', G, ('anglicism',), ''),
    ('apgrejd', 'апгрейд; покращення', 'noun', 'slang', G, ('anglicism',), ''),
    ('kopipejstati', 'копіювати й вставляти', 'verb', 'slang', G, ('anglicism',), ''),
    ('printati', 'друкувати (на принтері)', 'verb', 'colloquial', G, ('anglicism',), ''),
    ('lajv', 'наживо; прямий ефір', 'noun', 'slang', G, ('anglicism',), ''),
    ('biznis', 'бізнес; справа', 'noun', 'colloquial', G, ('anglicism',), ''),
    ('event', 'захід; івент', 'noun', 'colloquial', G, ('professional_jargon', 'anglicism'), ''),
    ('koučing', 'коучинг', 'noun', 'colloquial', G, ('professional_jargon', 'anglicism'), ''),
],
'R': [
    # Далмація — для текстів і діалогів
    ('furešt', 'приїжджий; чужинець', 'noun', 'colloquial', D, ('italianism',), ''),
    ('škura', 'віконниця', 'noun', 'colloquial', D, ('italianism',), ''),
    ('pjat', 'тарілка', 'noun', 'colloquial', D, ('italianism',), '? pjat / pijat'),
    ('pirun', 'виделка', 'noun', 'colloquial', D, ('italianism',), ''),
    ('kušin', 'подушка', 'noun', 'colloquial', D, ('italianism',), ''),
    ('bičve', 'шкарпетки', 'noun', 'colloquial', D, (), ''),
    ('postole', 'туфлі; взуття', 'noun', 'colloquial', D, ('italianism',), ''),
    ('takujin', 'гаманець', 'noun', 'colloquial', D, ('italianism',), ''),
    ('katrida', 'стілець', 'noun', 'colloquial', D, ('italianism',), 'у списку власника — «Katridu»'),
    ('mula', 'дівчисько', 'noun', 'colloquial', D, (), ''),
    ('libar', 'книжка', 'noun', 'colloquial', D, ('italianism',), ''),
    ('škifo', 'гидота; бридко', 'noun', 'colloquial', D, ('italianism',), ''),
    ('kužina', 'кухня', 'noun', 'colloquial', D, ('italianism',), ''),
    ('šporko', 'брудно', 'adverb', 'colloquial', D, ('italianism',), ''),
    ('armerun', 'шафа', 'noun', 'colloquial', D, ('italianism',), ''),
    ('kantun', 'кут; ріг (вулиці)', 'noun', 'colloquial', D, ('italianism',), ''),
    ('ponistra', 'вікно', 'noun', 'colloquial', D, ('italianism',), ''),
    ('skala', 'сходи', 'noun', 'colloquial', D, ('italianism',), 'нз (шкала)'),
    ('tovar', 'осел', 'noun', 'colloquial', D, (), 'нз (вантаж)'),
    ('mudante', 'труси', 'noun', 'colloquial', D, ('italianism',), ''),
    ('kompir', 'картопля', 'noun', 'colloquial', D, (), 'у списку власника — «Kumpir» (так радше на континенті)'),
    ('mater', 'мати; мама', 'noun', 'colloquial', G, (), ''),
    ('pazar', 'ринок; базар', 'noun', 'colloquial', G, ('turkism',), ''),
    ('banak', 'прилавок; барна стійка', 'noun', 'colloquial', D, ('italianism',), ''),
    ('lešo', 'варений (про м\'ясо, рибу)', 'adjective', 'colloquial', D, ('italianism',), ''),
    # уже в базі — нагадування в рубриці
    ('fjaka', 'солодка лінь; млявість', 'noun', 'colloquial', D, ('italianism',), 'нагадування'),
    ('pomalo', 'потихеньку; без поспіху', 'adverb', 'colloquial', D, (), 'нагадування'),
    ('gušt', 'задоволення; кайф', 'noun', 'colloquial', D, ('italianism',), 'нагадування'),
    ('marenda', 'другий сніданок; перекус', 'noun', 'colloquial', D, ('italianism',), 'нагадування'),
    ('spiza', 'продукти; харчі', 'noun', 'colloquial', D, ('italianism',), 'нагадування'),
    ('riva', 'набережна', 'noun', 'standard', D, ('italianism',), 'нагадування'),
    ('bura', 'бура (північний вітер)', 'noun', 'standard', D, (), 'нагадування'),
    ('jugo', 'юг (південний вітер)', 'noun', 'standard', D, (), 'нагадування'),
    ('ae', 'так; ну давай', 'interjection', 'slang', D, (), 'нагадування'),
    ('kapula', 'цибуля', 'noun', 'colloquial', D, ('italianism',), 'нагадування'),
    ('pomidor', 'помідор', 'noun', 'colloquial', D, ('italianism',), 'нагадування; у списку власника — «Pomidora»'),
    ('šugaman', 'рушник', 'noun', 'colloquial', D, ('italianism',), 'нагадування'),
    # Загреб і північ
    ('murja', 'поліція; копи', 'noun', 'slang', G, (), ''),
    ('pandur', 'мент; поліцейський', 'noun', 'slang', G, (), ''),
    ('trafika', 'газетний кіоск', 'noun', 'colloquial', Z, ('germanism',), ''),
    ('cinkati', 'стукати; здавати когось', 'verb', 'slang', G, (), ''),
    ('cinker', 'стукач', 'noun', 'slang', G, (), ''),
    ('zbrisati', 'втекти; звалити', 'verb', 'colloquial', G, (), 'нз (стерти)'),
    ('magla!', 'вали звідси!; зникни!', 'interjection', 'slang', Z, (), 'нз (туман)'),
    ('kvart', 'район (міста)', 'noun', 'colloquial', G, (), 'у базі вже це значення'),
    ('gajba', 'хата; квартира', 'noun', 'slang', G, (), 'нз (ящик)'),
    ('šora', 'бійка', 'noun', 'slang', Z, (), ''),
    ('šiht', 'зміна (на роботі)', 'noun', 'colloquial', Z, ('germanism',), ''),
    ('rikverc', 'задній хід', 'noun', 'colloquial', Z, ('germanism',), ''),
    ('štengice', 'сходинки; сходи', 'noun', 'colloquial', Z, ('germanism',), ''),
    ('auspuh', 'вихлопна труба', 'noun', 'colloquial', G, ('germanism',), ''),
    ('bremze', 'гальма', 'noun', 'colloquial', Z, ('germanism',), ''),
    ('cvikeri', 'окуляри', 'noun', 'colloquial', Z, ('germanism',), ''),
    ('šnajder', 'кравець', 'noun', 'colloquial', Z, ('germanism',), ''),
    ('štrample', 'панчохи; колготки', 'noun', 'colloquial', Z, ('germanism',), ''),
    ('fiškal', 'адвокат (розм.)', 'noun', 'colloquial', G, (), ''),
    ('bajs', 'велик', 'noun', 'slang', G, ('youth_slang', 'anglicism'), ''),
    ('trenirka', 'спортивний костюм', 'noun', 'colloquial', G, (), ''),
    ('šlapice', 'шльопанці', 'noun', 'colloquial', G, (), ''),
    # загальне розмовне — для діалогів «між друзями»
    ('frka', 'паніка; метушня; проблема', 'noun', 'colloquial', G, (), ''),
    ('grdo', 'дуже; страшенно (розм.)', 'adverb', 'colloquial', G, (), ''),
    ('skroz', 'зовсім; повністю', 'adverb', 'colloquial', G, (), ''),
    ('fino', 'гарно; приємно', 'adverb', 'colloquial', G, (), ''),
    ('ono', 'ну; типу (слово-заповнювач)', 'particle', 'colloquial', G, (), 'нз (воно)'),
    ('jel', 'хіба ні?; правда ж?', 'particle', 'colloquial', G, (), ''),
    ('e pa', 'ну, що ж', 'interjection', 'colloquial', G, (), ''),
    ('ma', 'та; ой та', 'particle', 'colloquial', G, (), ''),
    ('nek', 'нехай', 'particle', 'colloquial', G, (), ''),
    ('evo', 'ось; ну от', 'particle', 'colloquial', G, (), ''),
    ('čuješ', 'слухай (на початку фрази)', 'phrase', 'colloquial', G, (), ''),
    ('ništa zato', 'нічого страшного', 'phrase', 'colloquial', G, (), ''),
    ('ma kakvi', 'та де там; та ні', 'phrase', 'colloquial', G, (), ''),
    ('ma da', 'та ну; невже', 'phrase', 'colloquial', G, (), ''),
    ('ne pitaj', 'краще не питай', 'phrase', 'colloquial', G, (), ''),
    ('ajd bok', 'ну все, бувай', 'phrase', 'informal', G, (), ''),
    # вулиця й безпека — для текстів B2
    ('drogaš', 'наркоман', 'noun', 'slang', G, (), 'образливе'),
    ('trava', 'трава (марихуана)', 'noun', 'slang', G, (), 'нз (трава)'),
    ('džoint', 'косяк', 'noun', 'slang', G, ('anglicism',), ''),
    ('buksna', 'косяк', 'noun', 'slang', Z, (), 'у списку власника — «схованка»: ні, це косяк'),
    ('dilati', 'торгувати наркотиками', 'verb', 'slang', G, ('anglicism',), ''),
],
'Q': [
    ('kap', 'брехня (cap)', 'noun', 'slang', G, ('youth_slang', 'anglicism'), '? чи вживають'),
    ('no kap', 'без брехні; чесно', 'phrase', 'slang', G, ('youth_slang', 'anglicism'), '? чи вживають'),
    ('bet', 'домовились; ок', 'interjection', 'slang', G, ('youth_slang', 'anglicism'), '? чи вживають'),
    ('spilati ti', 'розповісти плітки', 'phrase', 'slang', G, ('youth_slang', 'anglicism'), '? чи вживають'),
    ('kvin', 'королева (про подругу)', 'noun', 'slang', G, ('youth_slang', 'anglicism'), '? чи вживають'),
    ('sis', 'сестричка; подруга', 'noun', 'slang', G, ('youth_slang', 'anglicism'), '? чи вживають'),
    ('besti', 'найкращий друг; подруга', 'noun', 'slang', G, ('youth_slang', 'anglicism'), '? чи вживають'),
    ('grin fleg', 'хороша ознака (в людині)', 'phrase', 'slang', G, ('youth_slang', 'anglicism'), '? чи вживають'),
    ('red fleg', 'тривожний дзвіночок (в людині)', 'phrase', 'slang', G, ('youth_slang', 'anglicism'), '? чи вживають'),
    ('ril', 'реально; правда', 'adverb', 'slang', G, ('youth_slang', 'anglicism'), '? чи вживають'),
    ('slejati', 'виглядати неперевершено', 'verb', 'slang', G, ('youth_slang', 'anglicism'), '? чи вживають'),
    ('goustati', 'раптово зникнути (ghosting)', 'verb', 'slang', G, ('youth_slang', 'anglicism'), '? чи вживають'),
    ('sinati', 'прочитати й не відповісти', 'verb', 'slang', G, ('internet_slang', 'anglicism'), '? чи вживають'),
    ('overthinkati', 'накручувати себе', 'verb', 'slang', G, ('youth_slang', 'anglicism'), '? чи вживають'),
    ('gaslajtati', 'маніпулювати (газлайтинг)', 'verb', 'slang', G, ('youth_slang', 'anglicism'), '? чи вживають'),
    ('kenslati', 'скасувати (людину)', 'verb', 'slang', G, ('internet_slang', 'anglicism'), '? чи вживають'),
    ('rils', 'рілс (коротке відео)', 'noun', 'slang', G, ('internet_slang', 'anglicism'), '? написання'),
    ('autfit', 'образ; одяг', 'noun', 'slang', G, ('youth_slang', 'anglicism'), '? написання'),
    ('drip', 'крутий стиль одягу', 'noun', 'slang', G, ('youth_slang', 'anglicism'), '? чи вживають'),
    ('simp', 'хлопець, що надто догоджає', 'noun', 'slang', G, ('youth_slang', 'anglicism'), '? чи вживають'),
    ('lero', 'на халяву', 'adverb', 'slang', D, (), '? чи є таке слово'),
    ('šup', 'сарай; глушина', 'noun', 'slang', Z, (), '? радше šupa'),
],
'X1': [
    ('psovka', 'лайка; лайливе слово', 'noun', 'standard', G, (), 'метамова уроку'),
    ('psovati', 'лаятися', 'verb', 'standard', G, (), 'метамова уроку'),
    ('opsovati', 'вилаяти; облаяти', 'verb', 'standard', G, (), 'метамова уроку'),
    ('jebiga', 'ну що ж; нічого не вдієш', 'interjection', 'vulgar', G, (), 'вигук, не образа'),
    ('jebote', 'ох нічого собі; чорт забирай', 'interjection', 'vulgar', G, (), 'вигук'),
    ('jebem ti sunce', 'бляха-муха', 'phrase', 'vulgar', G, (), 'пом\'якшена форма'),
    ('kurac', 'хер; член', 'noun', 'vulgar', G, (), ''),
    ('koji kurac', 'якого хріна', 'phrase', 'vulgar', G, (), ''),
    ('pička', 'пизда', 'noun', 'vulgar', G, (), 'і як образа'),
    ('sranje', 'лайно; лажа', 'noun', 'vulgar', G, (), ''),
    ('govno', 'гівно', 'noun', 'vulgar', G, (), ''),
    ('srati', 'срати; молоти дурниці', 'verb', 'vulgar', G, (), ''),
    ('ne seri', 'не неси дурниць', 'phrase', 'vulgar', G, (), ''),
    ('sjebati', 'зіпсувати; облажати', 'verb', 'vulgar', G, (), ''),
    ('sjeban', 'розбитий; у лайні', 'adjective', 'vulgar', G, (), ''),
    ('zajebati', 'обдурити; напартачити', 'verb', 'vulgar', G, (), ''),
    ('zajebavati', 'підколювати; стьобати', 'verb', 'vulgar', G, (), ''),
    ('zajebancija', 'прикол; стьоб', 'noun', 'vulgar', G, (), 'між друзями — легко'),
    ('jebeno', 'охрінено; дуже', 'adverb', 'vulgar', G, (), 'підсилювач'),
    ('jebeni', 'довбаний', 'adjective', 'vulgar', G, (), ''),
    ('jebati', 'трахати', 'verb', 'vulgar', G, (), ''),
    ('odjebi', 'відвали', 'phrase', 'vulgar', G, (), 'грубо'),
    ('popušiti', 'програти; обламатися', 'verb', 'vulgar', G, (), ''),
    ('pušiona', 'повний провал', 'noun', 'vulgar', G, (), ''),
],
'X2': [
    ('k vragu', 'до біса', 'phrase', 'colloquial', G, (), 'замінник'),
    ('dovraga', 'дідько; до дідька', 'interjection', 'colloquial', G, (), 'замінник'),
    ('koji vrag', 'якого біса', 'phrase', 'colloquial', G, (), 'замінник «koji kurac»'),
    ('vrag te odnio', 'щоб тебе чорт забрав', 'phrase', 'colloquial', G, (), 'замінник'),
    ('sto mu gromova', 'тисяча чортів', 'phrase', 'colloquial', G, ('idiom',), 'замінник'),
    ('majko mila', 'матінко рідна', 'phrase', 'colloquial', G, (), 'замінник'),
    ('bože dragi', 'боже милий', 'phrase', 'colloquial', G, (), 'замінник'),
    ('ajme meni', 'ой лишенько', 'phrase', 'colloquial', G, (), 'замінник'),
    ('šipak', 'дуля; дзузьки', 'noun', 'colloquial', G, (), 'замінник; нз (шипшина)'),
    ('baš me briga', 'а мені байдуже', 'phrase', 'colloquial', G, (), 'замінник «boli me kurac»'),
    ('boli me kurac', 'мені пох', 'phrase', 'vulgar', G, (), ''),
    ('boli me đon', 'мені по барабану', 'phrase', 'colloquial', G, (), '?'),
    ('majku mu', 'бляха; щоб його', 'phrase', 'vulgar', G, (), 'скорочено від «jebem mu majku»'),
    ('pas mater', 'бляха; собача мати', 'phrase', 'vulgar', D, (), '?'),
    ('jebo te pas', 'та щоб тебе', 'phrase', 'vulgar', G, (), '?'),
    ('jebem ti miša', 'бляха-муха', 'phrase', 'vulgar', G, (), 'пом\'якшена форма'),
    ('jebem ti život', 'чорт забирай (таке життя)', 'phrase', 'vulgar', G, (), ''),
    ('sunce ti', 'бляха; та ну', 'phrase', 'colloquial', G, (), '? замінник'),
    ('ma jebeš to', 'та забий на це', 'phrase', 'vulgar', G, (), ''),
    ('jebeš ga', 'та й біс із ним', 'phrase', 'vulgar', G, (), ''),
    ('kvragu sve', 'до біса все', 'phrase', 'colloquial', G, (), 'замінник'),
],
'X3': [
    ('budala', 'дурень', 'noun', 'colloquial', G, (), 'образа, легка'),
    ('glupan', 'дурень; тупак', 'noun', 'colloquial', G, (), 'образа'),
    ('kreten', 'кретин', 'noun', 'colloquial', G, (), 'образа'),
    ('debil', 'дебіл', 'noun', 'vulgar', G, (), 'образа; зачіпає людей з інвалідністю'),
    ('konj', 'бовдур; дурень', 'noun', 'colloquial', G, (), 'образа; нз (кінь)'),
    ('đubre', 'покидьок', 'noun', 'vulgar', G, (), 'образа'),
    ('šupak', 'мудак', 'noun', 'vulgar', G, (), 'образа'),
    ('seronja', 'пустобрех; мудак', 'noun', 'vulgar', G, (), 'образа'),
    ('kurva', 'повія; шльондра', 'noun', 'vulgar', G, (), 'образа; і як вигук'),
    ('kurvin sin', 'сучий син', 'phrase', 'vulgar', G, (), 'образа'),
    ('jebi se', 'пішов ти', 'phrase', 'vulgar', G, (), 'образа'),
    ('marš', 'геть!; марш!', 'interjection', 'colloquial', G, (), 'грубо'),
    ('gubi se', 'забирайся; зникни', 'phrase', 'colloquial', G, (), 'грубо'),
    # образливі слова про групи людей (рішення власника 2026-11-13: включаємо, лише впізнавання)
    ('peder', 'педик', 'noun', 'vulgar', G, (), 'образа за орієнтацією; нейтрально — gej'),
    ('lezba', 'образливо про лесбійку', 'noun', 'vulgar', G, (), 'образа за орієнтацією; нейтрально — lezbijka'),
    ('Cigan', 'образливо про рома', 'noun', 'vulgar', G, (), 'образа за національністю; нейтрально — Rom'),
    ('Šiptar', 'образливо про албанця', 'noun', 'vulgar', G, (), 'образа за національністю; нейтрально — Albanac'),
    ('balija', 'образливо про босняка-мусульманина', 'noun', 'vulgar', G, (), 'образа за національністю й релігією; нейтрально — Bošnjak'),
    ('četnik', 'четник (образа для серба)', 'noun', 'vulgar', G, (), 'образа; історичне слово — ?'),
    ('ustaša', 'усташ (образа для хорвата)', 'noun', 'vulgar', G, (), 'образа; історичне слово — ?'),
    ('crnčuga', 'образливо про темношкірого', 'noun', 'vulgar', G, (), 'расистська образа; нейтрально — crnac (застаріває), tamnoput'),
    ('retardiran', 'відсталий (образа)', 'adjective', 'vulgar', G, (), 'образа людей з інвалідністю'),
    ('seljačina', 'селюк; бидло', 'noun', 'vulgar', G, (), 'образа'),
],
'X4': [
    ('jebem ti boga', 'найгрубіша блюзнірська лайка', 'phrase', 'vulgar', G, (), 'ображає вірян'),
    ('jebem ti sveca', 'блюзнірська лайка (про святого)', 'phrase', 'vulgar', G, (), 'ображає вірян'),
    ('jebem ti križ', 'блюзнірська лайка (про хрест)', 'phrase', 'vulgar', G, (), '?'),
    ('jebote bog', 'чорт забирай (блюзнірське)', 'phrase', 'vulgar', G, (), '?'),
    ('boga ti', 'бляха; та ти що', 'phrase', 'vulgar', D, (), 'скорочене блюзнірство'),
    ('bogati', 'та ти що!; о боже!', 'interjection', 'colloquial', D, (), ''),
    ('bogarati', 'лаятися блюзнірськи', 'verb', 'colloquial', D, (), ''),
    ('isusa ti', 'та ти що (блюзнірське)', 'phrase', 'vulgar', G, (), '?'),
    ('sveca ti', 'бляха (скорочене)', 'phrase', 'vulgar', G, (), '?'),
    ('Gospe moja', 'матір Божа!', 'phrase', 'colloquial', D, (), 'не лайка — вигук'),
    ('Isuse Bože', 'Господи Боже!', 'phrase', 'colloquial', G, (), 'не лайка — вигук'),
    ('bog te mazo', 'ну й ну; щоб тебе', 'phrase', 'colloquial', G, ('idiom',), ''),
    ('bog te pita', 'хто його знає', 'phrase', 'colloquial', G, ('idiom',), ''),
    ('boga mi', 'їй-богу', 'phrase', 'colloquial', G, (), ''),
    ('tako mi Boga', 'клянуся Богом', 'phrase', 'colloquial', G, (), ''),
    ('da Bog da crko', 'щоб ти здох (прокльон)', 'phrase', 'vulgar', G, ('idiom',), 'прокльон'),
    ('Bože sačuvaj', 'Боже борони', 'phrase', 'standard', G, (), 'не лайка'),
    ('idi k vragu', 'іди к бісу', 'phrase', 'colloquial', G, (), 'замінник'),
],
'X5': [
    ('jebem ti mater', 'класична лайка «про матір»', 'phrase', 'vulgar', G, (), 'між друзями — вигук, до незнайомого — тяжка образа'),
    ('pasji sin', 'собачий син', 'phrase', 'vulgar', G, (), 'образа'),
    ('glupača', 'дурепа', 'noun', 'colloquial', G, (), 'образа'),
    ('majmun', 'бовдур; мавпа (образа)', 'noun', 'colloquial', G, (), 'образа; нз (мавпа)'),
    ('krava', 'корова (образа для жінки)', 'noun', 'vulgar', G, (), 'образа; нз (корова)'),
    ('drolja', 'шльондра', 'noun', 'vulgar', G, (), 'образа'),
    ('komad', 'красуня; «шматочок»', 'noun', 'vulgar', G, (), 'зневажливо, про жінку; нз (шматок)'),
    ('treba', 'дівчина (зневажливо)', 'noun', 'vulgar', G, (), 'зневажливо; нз (треба)'),
    ('u kurac', 'до біса; пропало', 'phrase', 'vulgar', G, (), ''),
    ('u pičku materinu', 'до біса; хай йому', 'phrase', 'vulgar', G, (), ''),
    ('jebe mi se', 'мені пох', 'phrase', 'vulgar', G, (), ''),
    ('zajebi', 'забий; не зважай', 'phrase', 'vulgar', G, (), ''),
    ('popizditi', 'оскаженіти; знавіснiти', 'verb', 'vulgar', G, (), ''),
    ('pizdarija', 'дурня; фігня', 'noun', 'vulgar', G, (), ''),
    ('kurčiti se', 'випендрюватися', 'verb', 'vulgar', G, (), ''),
    ('guzica', 'дупа', 'noun', 'vulgar', G, (), ''),
    ('dupe', 'дупа', 'noun', 'colloquial', G, (), ''),
    ('lizati dupe', 'підлизуватися', 'phrase', 'vulgar', G, ('idiom',), ''),
    ('pun mi je kurac', 'мене дістало', 'phrase', 'vulgar', G, ('idiom',), ''),
    ('boli me ona stvar', 'мені по цимбалах', 'phrase', 'colloquial', G, (), '? замінник'),
    ('mamlaz', 'бовдур; йолоп', 'noun', 'colloquial', G, (), 'образа, легка'),
    ('tikvan', 'йолоп; бевзь', 'noun', 'colloquial', G, (), 'образа, легка'),
    ('smotan', 'недотепа; незграбний', 'adjective', 'colloquial', G, (), ''),
],
}

CYR = re.compile('[Ѐ-ӿ]')


def norm(s: str) -> str:
    """normalizeCroatian: без діакритик, малими (č ć → c, đ → d, š → s, ž → z)."""
    s = s.lower().replace('đ', 'd')
    return ''.join(c for c in unicodedata.normalize('NFD', s) if unicodedata.category(c) != 'Mn')


def rows():
    for code, items in DATA.items():
        for lemma, ua, pos, reg, region, tags, note in items:
            yield code, lemma, ua, pos, reg, region, tags, note


def check() -> list[str]:
    errors, seen = [], {}
    for code, lemma, ua, pos, reg, region, tags, note in rows():
        key = lemma.lower()
        if key in seen:
            errors.append(f'дублікат: {lemma} ({seen[key]} і {code})')
        seen[key] = code
        if CYR.search(lemma):
            errors.append(f'кирилиця в лемі: {lemma}')
        if not CYR.search(ua):
            errors.append(f'переклад не українською: {lemma}')
        if pos not in POS:
            errors.append(f'частина мови {pos}: {lemma}')
        if reg not in REGISTERS:
            errors.append(f'register {reg}: {lemma}')
        if region not in REGIONS:
            errors.append(f'regionality {region}: {lemma}')
        bad = set(tags) - TAGS
        if bad:
            errors.append(f'usage_tags {bad}: {lemma}')
    for code, items in DATA.items():
        if code[0] in 'SZX' and not 17 <= len(items) <= 25:
            errors.append(f'урок {code}: {len(items)} одиниць (потрібно 20–25, мінімум 17 — з урахуванням відсіву)')
    slang = sum(len(v) for k, v in DATA.items() if k[0] in 'SZR')
    if slang < 300:
        errors.append(f'сленгу й розмовного разом {slang} < 300 (рішення власника)')
    return errors


def query_sql() -> str:
    lemmas = sorted({r[1].lower() for r in rows()})
    norms = sorted({norm(r[1]) for r in rows()})
    arr = lambda xs: 'array[' + ', '.join("'" + x.replace("'", "''") + "'" for x in xs) + ']'
    return ('select lemma, normalized, cefr, status, register, regionality, ukrainian_translation\n'
            'from public.lexemes\n'
            f'where lower(lemma) = any({arr(lemmas)})\n'
            f'   or normalized = any({arr(norms)})\n'
            'order by lower(lemma);')


def main() -> int:
    errors = check()
    if errors:
        print('ПОМИЛКИ:\n- ' + '\n- '.join(errors))
        return 1
    if '--query' in sys.argv:
        print(query_sql())
        return 0
    snap = json.loads(SNAP.read_text(encoding='utf-8'))
    by_lemma, by_norm = {}, {}
    for r in snap['rows']:
        by_lemma.setdefault(r['lemma'].lower(), []).append(r)
        by_norm.setdefault(r['normalized'] or norm(r['lemma']), []).append(r)

    def db_status(lemma: str, note: str) -> tuple[str, str]:
        hits = by_lemma.get(lemma.lower())
        kind = 'same'
        if not hits:
            hits = [h for h in by_norm.get(norm(lemma), []) if h['lemma'].lower() != lemma.lower()]
            kind = 'similar'
        if not hits:
            if 'нз' in note:
                return 'new', 'немає → одна лема з обома значеннями (стандартне першим)'
            return 'new', 'немає'
        h = hits[0]
        txt = f"{h['cefr'] or '—'}: «{h['ukrainian_translation']}»"
        if h.get('register'):
            txt += f" · `{h['register']}`"
        if kind == 'similar':
            return 'similar', f"схоже написання *{h['lemma']}* — {txt}"
        if h['status'] == 'DEPRECATED':
            return 'deprecated', f"DEPRECATED {txt} → повернути новою версією (`content_versions`), не нова лема"
        if 'нз' in note:
            return 'exists', f"є з іншим значенням — {txt} → додати значення до наявної лексеми"
        return 'exists', f"є — {txt} → нагадування; розмітку звірити"

    out = []
    stats = {}
    other: list[str] = []
    for code, items in DATA.items():
        module, title = LESSONS[code]
        out.append(f'\n### {code} · {module} — {title} · {len(items)}\n')
        out.append('| № | Слово | Переклад | Частина мови | register | regionality | usage_tags | У базі | Примітка |')
        out.append('|---|---|---|---|---|---|---|---|---|')
        for i, (lemma, ua, pos, reg, region, tags, note) in enumerate(items, 1):
            st, txt = db_status(lemma, note)
            stats.setdefault(code, {'new': 0, 'exists': 0, 'similar': 0, 'deprecated': 0})[st] += 1
            if st == 'exists' and 'нз' in note:
                other.append(lemma)
            tg = ', '.join(tags) if tags else '{}'
            out.append(f'| {i} | *{lemma}* | {ua} | {pos} | `{reg}` | `{region}` | {tg} | {txt} | {note} |')

    def total(prefixes: str, st: str | None = None) -> int:
        return sum((sum(v.values()) if st is None else v[st]) for k, v in stats.items() if k[0] in prefixes)

    nz = sum(1 for r in rows() if 'нз' in r[7])
    q = sum(1 for r in rows() if '?' in r[7])
    head = f'''# Сленг і модуль «18+»: список слів зі звіркою з базою (2026-11-13)

> Статус: **кандидати на перевірку** (власник → носій). У базі нічого не змінено; звірка — запит лише на читання до робочої бази ({snap['taken_at']}).
> Рішення власника 2026-11-13: сленг — окремі модулі B1 / B2, не менше 300 одиниць, 5–7 уроків по 20–25, решта — тексти; модуль «18+» — 5 уроків у кінці B1, образливі слова про групи людей — включено (лише впізнавання), бета. План — `docs/proposals/2026-11-12_b1_b2_dialogues_reading_situations.md` §3а, §3б.
> Таблиці генерує `python3 -B scripts/gen_live_lexicon_20261113.py` (не редагуйте вручну); знімок бази — `scripts/live_lexicon_20261113_snapshot.json`.

## Коротко

| | Одиниць | Нових | Уже в базі | DEPRECATED у базі | Схоже написання |
|---|---|---|---|---|---|
| B1 · Сленг (6 уроків) | {total('S')} | {total('S', 'new')} | {total('S', 'exists')} | {total('S', 'deprecated')} | {total('S', 'similar')} |
| B2 · Živi hrvatski I (4 уроки) | {total('Z')} | {total('Z', 'new')} | {total('Z', 'exists')} | {total('Z', 'deprecated')} | {total('Z', 'similar')} |
| Решта (тексти, діалоги, рубрика) | {total('R')} | {total('R', 'new')} | {total('R', 'exists')} | {total('R', 'deprecated')} | {total('R', 'similar')} |
| **Сленг і розмовне разом** | **{total('SZR')}** | {total('SZR', 'new')} | {total('SZR', 'exists')} | {total('SZR', 'deprecated')} | {total('SZR', 'similar')} |
| Сумнівні з прикладу власника (носію) | {total('Q')} | {total('Q', 'new')} | {total('Q', 'exists')} | {total('Q', 'deprecated')} | {total('Q', 'similar')} |
| B1 · 18+ (5 уроків) | {total('X')} | {total('X', 'new')} | {total('X', 'exists')} | {total('X', 'deprecated')} | {total('X', 'similar')} |

- **«Уже в базі»** — лема є в `lexemes`. З іншим значенням ({len(other)}: {', '.join('*' + x + '*' for x in other)}) — нове значення додаємо до наявної лексеми через `content_versions`, а не нову лему (`lower(lemma)` унікальний). З тим самим значенням — слово в уроці стає нагадуванням; розмітку звірити (у базі ще старі `regional` — їх нормалізує M24).
- **«нз», але в базі немає** (*lik, top, legenda, brijati…*) — нова лема одразу з обома значеннями: стандартне першим, сленгове — з позначкою.
- **DEPRECATED у базі** (*Kužiš?*, *nemam pojma* — колись прибрані як речення): повертаємо новою версією наявного рядка, а не новою лемою. У *Kužiš?* поле `normalized` з діакритиками й «?» (`kužiš?`) — помилка даних, виправити тим самим пакетом.
- **«?»** у примітці — {q} слів: перевірити носієм (чи вживають, значення, написання). Група «Сумнівні» — кальки з англійської з прикладу власника; у модулі — лише після «так» носія.
- Розмітка — модель §4.1 (`register` / `regionality` / `usage_tags`); `vulgar` — лише в модулі «18+», який видно після ввімкнення «Показувати контент 18+».
- Образливі слова про групи людей (урок X3) — лише впізнавання: позначка «образа», чому образливо, нейтральний відповідник у примітці.
- Що змінено проти прикладу власника: прибрано стандартні слова (*žlica, kapa, kafić, dečko, teta, smijati se, kupanje, kartica, blokirati*); виправлено *Purger, katrida, buksna, kompir, pomidor*; додано розмовні слова, яких у прикладі не було (*fuš, rintati, nacvrcan, gablec, cajt…*), і лексику «18+».
- Далі: власник і носій переглядають список → батч слів (`croatian-lexeme-batch`: приклади, пояснення, форми) → уроки модулів (`lesson-topic-rebuild` / `level-build-croatia`).
'''
    text = head + '\n## Список за уроками\n' + '\n'.join(out) + '\n'
    OUT.write_text(text, encoding='utf-8')
    print(f'OK: сленг {total("SZR")} (нових {total("SZR", "new")}), сумнівних {total("Q")}, 18+ {total("X")} '
          f'(нових {total("X", "new")}); нз {nz}, ? {q} → {OUT.relative_to(ROOT)}')
    return 0


if __name__ == '__main__':
    sys.exit(main())
