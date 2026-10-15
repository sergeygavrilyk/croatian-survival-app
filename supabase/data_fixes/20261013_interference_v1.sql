-- =====================================================================
-- Типові помилки українців (§19 ТЗ) · interference_v1 · 2026-10-13
-- Згенеровано: python3 scripts/gen_interference.py (не редагуйте вручну).
-- Запуск: Supabase → SQL Editor → вставити ВЕСЬ файл → Run. Потрібна міграція M14.
--
--   * 74 помилок, коди UKR-HR-0001…UKR-HR-0074; рівні: A0 29, A1 42, A2 3.
--   * Категорії: cases 7, gender 5, aspect 2, word_order 6, prepositions 7, false_friends 17, pronunciation 5, verb_patterns 9, plural 4, articles 1, stress 4, collocations 7.
--   * Прив'язка до тем граматики A0/A1 і слів — картка «Українці часто помиляються» в уроці.
--   * Статус PUBLISHED: бета, як уроки A0/A1 (носій ще не перевіряв). Повторний запуск безпечний.
-- =====================================================================

begin;

do $$
begin
  if to_regclass('public.linguistic_errors') is null then
    raise exception 'Спершу запустіть міграцію M14 (20261013160000_m14_linguistic_errors.sql)';
  end if;
end $$;

insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0001', 'verb_patterns', 'A0', 'Дієслово biti не пропускаємо', 'Ja student.', 'Ja sam student.', 'В українській «є» в теперішньому часі зазвичай пропускаємо: «Я студент». У хорватській biti обов’язкове: sam, si, je, smo, ste, su.', '[{"hr": "Ona je liječnica.", "ua": "Вона лікарка."}, {"hr": "Mi smo iz Ukrajine.", "ua": "Ми з України."}]'::jsonb,
        (select id from public.grammar_topics where cefr = 'A0' and title_ua = 'Особові займенники та дієслово BITI' order by created_at limit 1), null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0002', 'verb_patterns', 'A0', 'Не «ne je», а «nije»', 'To ne je problem.', 'To nije problem.', 'Заперечення дієслова biti — одним словом: nisam, nisi, nije, nismo, niste, nisu. «Ne je» і «ne sam» — помилка.', '[{"hr": "Nisam umoran.", "ua": "Я не втомлений."}, {"hr": "Ana nije kod kuće.", "ua": "Ани немає вдома."}]'::jsonb,
        (select id from public.grammar_topics where cefr = 'A0' and title_ua = 'Заперечення і питання з «biti»' order by created_at limit 1), null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0003', 'verb_patterns', 'A0', 'Вік: «imam», а не «meni je»', 'Meni je trideset godina.', 'Imam trideset godina.', 'Українською кажемо «мені тридцять років». Хорвати кажуть «маю тридцять років» — з дієсловом imati.', '[{"hr": "Koliko imaš godina?", "ua": "Скільки тобі років?"}, {"hr": "Sin ima pet godina.", "ua": "Синові п’ять років."}]'::jsonb,
        (select id from public.grammar_topics where cefr = 'A0' and title_ua = 'Дієслово «imati» (мати)' order by created_at limit 1), (select id from public.lexemes where lower(lemma) = lower('godina') and status = 'PUBLISHED' order by created_at limit 1), 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0004', 'verb_patterns', 'A0', '«У мене є» — це «imam»', 'U mene je auto.', 'Imam auto.', 'Конструкції «у мене є» в хорватській немає. Кажіть imam, imaš, ima. «U mene je» звучить як калька з української.', '[{"hr": "Imate li djecu?", "ua": "У вас є діти?"}, {"hr": "Nemam vremena.", "ua": "У мене немає часу."}]'::jsonb,
        (select id from public.grammar_topics where cefr = 'A0' and title_ua = 'Дієслово «imati» (мати)' order by created_at limit 1), null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0005', 'verb_patterns', 'A0', '«Мене звати» — «zovem se»', 'Mene zovu Olena.', 'Zovem se Olena.', 'Хорвати кажуть «я називаюся»: zovem se, zoveš se, zove se. «Mene zovu» зрозуміють, але так не кажуть, коли знайомляться.', '[{"hr": "Kako se zoveš?", "ua": "Як тебе звати?"}, {"hr": "Moj sin se zove Danilo.", "ua": "Мого сина звати Данило."}]'::jsonb,
        (select id from public.grammar_topics where cefr = 'A0' and title_ua = 'Особові займенники та дієслово BITI' order by created_at limit 1), null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0006', 'verb_patterns', 'A1', '«У мене болить» — «boli me»', 'Kod mene boli glava.', 'Boli me glava.', 'Біль описують знахідним відмінком особи: boli me (мене), boli te, boli ga — без «kod» і без «u».', '[{"hr": "Bole me leđa.", "ua": "У мене болить спина."}, {"hr": "Boli li te zub?", "ua": "У тебе болить зуб?"}]'::jsonb,
        '0db658cb-b2ed-5719-bced-f95a93cf15ce'::uuid, null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0007', 'verb_patterns', 'A1', '«Що» після «думаю, знаю» — це «da»', 'Mislim što je to dobro.', 'Mislim da je to dobro.', 'Після mislim, znam, kažem, vidim українське «що» перекладаємо як da. Što — це «що?» у питанні.', '[{"hr": "Znam da kasnim.", "ua": "Я знаю, що запізнююся."}, {"hr": "Kaže da ne može doći.", "ua": "Каже, що не може прийти."}]'::jsonb,
        '765ac66f-d54b-505b-9b11-c48e5ad26018'::uuid, null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0008', 'verb_patterns', 'A1', '«Мені подобається» — «sviđa mi se»', 'Ja sviđam ovaj grad.', 'Sviđa mi se ovaj grad.', 'Як і українською: те, що подобається, — підмет, а людина — у давальному: sviđa mi se. Можна й простіше: volim.', '[{"hr": "Sviđaju mi se tvoje cipele.", "ua": "Мені подобаються твої черевики."}, {"hr": "Volim more.", "ua": "Я люблю море."}]'::jsonb,
        '387f7bea-839e-56ae-bbfd-213aacbe7c26'::uuid, null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0009', 'verb_patterns', 'A2', 'Майбутній час: «ću», а не «budu»', 'Sutra ja budu raditi.', 'Sutra ću raditi.', 'Українське «буду працювати» хорватською — ću / ćeš / će + інфінітив: radit ću, ići ćemo. Форма budem — лише в особливих реченнях.', '[{"hr": "Sutra ću te nazvati.", "ua": "Завтра я тобі подзвоню."}, {"hr": "Ljeti ćemo ići na more.", "ua": "Улітку ми поїдемо на море."}]'::jsonb,
        null, null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0010', 'cases', 'A1', 'Куди? — u + знахідний', 'Idem u školi.', 'Idem u školu.', 'Як і в українській: куди? — знахідний (u školu), де? — місцевий (u školi). Не плутайте закінчення -u і -i.', '[{"hr": "Sutra idemo u Split.", "ua": "Завтра їдемо в Спліт."}, {"hr": "Djeca su u školi.", "ua": "Діти в школі."}]'::jsonb,
        '0db658cb-b2ed-5719-bced-f95a93cf15ce'::uuid, null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0011', 'cases', 'A1', 'Де? — u + місцевий', 'Živim u Zagreb.', 'Živim u Zagrebu.', 'Після u і na на питання «де?» потрібне закінчення місцевого відмінка: u Zagrebu, u Splitu, na moru.', '[{"hr": "Radim u hotelu.", "ua": "Я працюю в готелі."}, {"hr": "Ljeti smo na moru.", "ua": "Улітку ми на морі."}]'::jsonb,
        'f891e65a-d7be-5542-ae6e-dbee5bfe415c'::uuid, null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0012', 'cases', 'A1', 'Euro відмінюється', 'Kava košta dva euro.', 'Kava košta dva eura.', 'Українське «євро» не змінюється, а хорватське змінюється: jedan euro, dva / tri / četiri eura, pet eura.', '[{"hr": "To je pedeset eura.", "ua": "Це п’ятдесят євро."}, {"hr": "Karta košta jedan euro.", "ua": "Квиток коштує одне євро."}]'::jsonb,
        'd27ae527-a8d6-512f-acd2-a6cfec39c01f'::uuid, null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0013', 'cases', 'A1', 'Puno, malo, koliko + родовий', 'Imam puno posao.', 'Imam puno posla.', 'Після puno, malo, dosta, koliko іменник стоїть у родовому: puno posla, malo vremena, koliko novca.', '[{"hr": "Nemam puno vremena.", "ua": "У мене небагато часу."}, {"hr": "Koliko novca trebaš?", "ua": "Скільки грошей тобі треба?"}]'::jsonb,
        'd27ae527-a8d6-512f-acd2-a6cfec39c01f'::uuid, null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0014', 'cases', 'A1', 'Знахідний: kavu, vodu, sobu', 'Želim kava.', 'Želim kavu.', 'Іменники на -a у знахідному відмінку мають -u: kavu, vodu, sobu — як в українській «каву». Не залишайте початкову форму.', '[{"hr": "Trebam kartu za Split.", "ua": "Мені потрібен квиток до Спліта."}, {"hr": "Imate li slobodnu sobu?", "ua": "У вас є вільна кімната?"}]'::jsonb,
        '0db658cb-b2ed-5719-bced-f95a93cf15ce'::uuid, null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0015', 'cases', 'A1', 'Мови: «govorim hrvatski»', 'Govorim hrvatskim.', 'Govorim hrvatski.', 'Українською «говорю хорватською» (орудний). Хорвати кажуть govorim hrvatski, engleski — без -im. Але: «Kako se kaže na hrvatskom?»', '[{"hr": "Govorite li engleski?", "ua": "Ви говорите англійською?"}, {"hr": "Kako se to kaže na hrvatskom?", "ua": "Як це сказати хорватською?"}]'::jsonb,
        '387f7bea-839e-56ae-bbfd-213aacbe7c26'::uuid, null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0016', 'cases', 'A1', '«Про» — o + місцевий', 'Pričamo o posao.', 'Pričamo o poslu.', 'Українське «про» вимагає знахідного: «про роботу». Хорватське o — місцевого: o poslu, o djeci, o Hrvatskoj.', '[{"hr": "Razgovaramo o djeci.", "ua": "Ми говоримо про дітей."}, {"hr": "Knjiga je o Hrvatskoj.", "ua": "Книжка про Хорватію."}]'::jsonb,
        'f891e65a-d7be-5542-ae6e-dbee5bfe415c'::uuid, null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0017', 'word_order', 'A0', 'Se, mi, ti — на другому місці', 'Ja zovem se Olena.', 'Ja se zovem Olena.', 'Короткі слова (se, mi, ti, je, sam…) стоять на другому місці в реченні — одразу після першого слова чи групи слів.', '[{"hr": "Kako se zoveš?", "ua": "Як тебе звати?"}, {"hr": "Ja se zovem Taras.", "ua": "Мене звати Тарас."}]'::jsonb,
        (select id from public.grammar_topics where cefr = 'A0' and title_ua = 'Порядок слів' order by created_at limit 1), null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0018', 'word_order', 'A0', 'Речення не починається з «sam», «je»', 'Sam umoran.', 'Umoran sam.', 'Коротка форма biti (sam, si, je, smo…) не може стояти першою. Кажіть «Umoran sam» або «Ja sam umoran».', '[{"hr": "Gladna sam.", "ua": "Я голодна."}, {"hr": "Ja sam iz Kijeva.", "ua": "Я з Києва."}]'::jsonb,
        (select id from public.grammar_topics where cefr = 'A0' and title_ua = 'Порядок слів' order by created_at limit 1), null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0019', 'word_order', 'A0', 'Li — після дієслова', 'Li imate sobu?', 'Imate li sobu?', 'Частка li стоїть після першого слова речення — зазвичай дієслова: Imate li…? Govorite li…? Je li…?', '[{"hr": "Govorite li engleski?", "ua": "Ви говорите англійською?"}, {"hr": "Je li ovo Vaš ključ?", "ua": "Це ваш ключ?"}]'::jsonb,
        (select id from public.grammar_topics where cefr = 'A0' and title_ua = 'Заперечення і питання з «biti»' order by created_at limit 1), null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0020', 'word_order', 'A1', 'Спершу mi, потім ga', 'Daj ga mi.', 'Daj mi ga.', 'Якщо поруч два короткі займенники, спершу давальний (mi, ti, mu), потім знахідний (ga, je, ih): daj mi ga, pošalji mi je.', '[{"hr": "Pošalji mi ga.", "ua": "Надішли мені його."}, {"hr": "Možeš li mi ih dati?", "ua": "Можеш мені їх дати?"}]'::jsonb,
        '45c5cb39-daf7-5dab-8413-9a5302b33553'::uuid, null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0021', 'word_order', 'A1', '«Kako ti je ime?», а не «je ti»', 'Kako je ti ime?', 'Kako ti je ime?', 'Коли коротких слів кілька, порядок сталий: mi / ti / mu → ga / je → se → je. Тому «ti je», «mi je».', '[{"hr": "Što ti je?", "ua": "Що з тобою?"}, {"hr": "Kako mu je ime?", "ua": "Як його звати?"}]'::jsonb,
        '1435d343-6721-5eb7-8dc2-af7f9a027716'::uuid, null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0022', 'word_order', 'A1', '«Ne bojim se», а не «ne se bojim»', 'Ne se bojim.', 'Ne bojim se.', 'Після заперечення ne коротке se не ставимо: спершу дієслово, потім se — ne bojim se, ne sjećam se.', '[{"hr": "Ne sjećam se.", "ua": "Я не пам’ятаю."}, {"hr": "Ne osjećam se dobro.", "ua": "Я погано почуваюся."}]'::jsonb,
        'b89a9004-2c03-567a-b23e-31db18f92dea'::uuid, null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0023', 'gender', 'A0', 'Auto — чоловічий рід', 'Moje auto je novo.', 'Moj auto je nov.', 'Українське «авто» — середнього роду, а хорватське auto — чоловічого: moj auto, novi auto.', '[{"hr": "Gdje je tvoj auto?", "ua": "Де твоє авто?"}, {"hr": "Imamo novi auto.", "ua": "У нас нове авто."}]'::jsonb,
        (select id from public.grammar_topics where cefr = 'A0' and title_ua = 'Рід, множина і «мій / моя / моє»' order by created_at limit 1), null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0024', 'gender', 'A0', 'Vrijeme — середній рід', 'Vrijeme je lijep.', 'Vrijeme je lijepo.', 'Vrijeme (час; погода) — середнього роду, як ime чи rame, хоча українське «час» — чоловічого: lijepo vrijeme, ružno vrijeme.', '[{"hr": "Kakvo je vrijeme danas?", "ua": "Яка сьогодні погода?"}, {"hr": "Danas je lijepo vrijeme.", "ua": "Сьогодні гарна погода."}]'::jsonb,
        (select id from public.grammar_topics where cefr = 'A0' and title_ua = 'Прикметники: узгодження з іменником' order by created_at limit 1), null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0025', 'gender', 'A0', 'Слова на -ište — середній рід', 'Kazalište je velik.', 'Kazalište je veliko.', 'Іменники на -ište (kazalište, igralište, parkiralište) — середнього роду, навіть якщо українською «театр», «майданчик» — чоловічого.', '[{"hr": "Igralište je blizu.", "ua": "Майданчик поруч."}, {"hr": "Ovo parkiralište je skupo.", "ua": "Ця парковка дорога."}]'::jsonb,
        (select id from public.grammar_topics where cefr = 'A0' and title_ua = 'Прикметники: узгодження з іменником' order by created_at limit 1), null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0026', 'gender', 'A0', 'Prtljaga — жіночий рід', 'Moj prtljaga je težak.', 'Moja prtljaga je teška.', 'Українське «багаж» — чоловічого роду, а хорватське prtljaga — жіночого: moja prtljaga, ručna prtljaga.', '[{"hr": "Gdje je Vaša prtljaga?", "ua": "Де ваш багаж?"}, {"hr": "Ručna prtljaga je mala.", "ua": "Ручна поклажа маленька."}]'::jsonb,
        (select id from public.grammar_topics where cefr = 'A0' and title_ua = 'Рід, множина і «мій / моя / моє»' order by created_at limit 1), null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0027', 'gender', 'A0', 'Tata, kolega — чоловічий рід, хоч і на -a', 'Moja tata je liječnik.', 'Moj tata je liječnik.', 'Слова на -a, що означають чоловіків (tata, kolega), — чоловічого роду: moj tata, dobar kolega.', '[{"hr": "Moj kolega je iz Splita.", "ua": "Мій колега зі Спліта."}, {"hr": "Naš tata radi u Njemačkoj.", "ua": "Наш тато працює в Німеччині."}]'::jsonb,
        (select id from public.grammar_topics where cefr = 'A0' and title_ua = 'Рід, множина і «мій / моя / моє»' order by created_at limit 1), null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0028', 'plural', 'A0', 'Короткі слова: -ovi / -evi', 'Ovdje su lijepi gradi.', 'Ovdje su lijepi gradovi.', 'Односкладові іменники чоловічого роду в множині часто мають -ovi / -evi: grad → gradovi, stol → stolovi, muž → muževi.', '[{"hr": "Stolovi su u dvorištu.", "ua": "Столи надворі."}, {"hr": "Muževi čekaju vani.", "ua": "Чоловіки чекають надворі."}]'::jsonb,
        (select id from public.grammar_topics where cefr = 'A0' and title_ua = 'Рід, множина і «мій / моя / моє»' order by created_at limit 1), null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0029', 'plural', 'A0', 'Djeca, braća — як жіночий рід однини', 'Mali djeca spavaju.', 'Mala djeca spavaju.', 'Djeca (діти) і braća (брати) за формою як жіночий рід однини: mala djeca, moja braća. Дієслово — у множині: djeca spavaju.', '[{"hr": "Moja djeca idu u vrtić.", "ua": "Мої діти ходять у садок."}, {"hr": "Moja braća žive u Kijevu.", "ua": "Мої брати живуть у Києві."}]'::jsonb,
        (select id from public.grammar_topics where cefr = 'A0' and title_ua = 'Рід, множина і «мій / моя / моє»' order by created_at limit 1), null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0030', 'plural', 'A0', 'Після 2, 3, 4 — закінчення -a', 'Imam dva brati.', 'Imam dva brata.', 'Після dva, tri, četiri іменник чоловічого роду має -a: dva brata, tri grada, četiri sata. Після pet і більше — родовий множини: pet gradova.', '[{"hr": "Imamo dva sina.", "ua": "У нас два сини."}, {"hr": "Radim osam sati.", "ua": "Я працюю вісім годин."}]'::jsonb,
        (select id from public.grammar_topics where cefr = 'A0' and title_ua = 'Числа 0–100' order by created_at limit 1), null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0031', 'plural', 'A1', 'Множина: oko → oči, uho → uši', 'Bole me oke.', 'Bole me oči.', 'Oko й uho мають особливу множину: oči, uši — як українські «очі», «вуха». Форм «oke», «uhe» немає.', '[{"hr": "Ima plave oči.", "ua": "У неї блакитні очі."}, {"hr": "Bole me uši.", "ua": "У мене болять вуха."}]'::jsonb,
        '0db658cb-b2ed-5719-bced-f95a93cf15ce'::uuid, null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0032', 'aspect', 'A1', 'Те, що зараз, — лише недоконаний вид', 'Sada napišem pismo.', 'Sada pišem pismo.', 'Доконані дієслова (napisati, kupiti, popiti) у теперішньому часі не означають «зараз». Що відбувається зараз — недоконаний вид: pišem, kupujem, pijem.', '[{"hr": "Što sada radiš?", "ua": "Що ти зараз робиш?"}, {"hr": "Upravo kuham ručak.", "ua": "Я саме готую обід."}]'::jsonb,
        '387f7bea-839e-56ae-bbfd-213aacbe7c26'::uuid, null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0033', 'aspect', 'A2', 'Після «kad» — доконаний вид, а не «ću»', 'Kad ću doći kući, nazvat ću te.', 'Kad dođem kući, nazvat ću te.', 'Після kad і ako про майбутнє ставимо доконане дієслово в теперішньому часі (dođem, završim), а не ću.', '[{"hr": "Kad završim posao, idem u trgovinu.", "ua": "Коли закінчу роботу, піду в магазин."}, {"hr": "Ako stignem, javit ću ti.", "ua": "Якщо встигну, дам тобі знати."}]'::jsonb,
        null, null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0034', 'prepositions', 'A1', '«У лікаря» — «kod liječnika»', 'Ja sam u liječnika.', 'Ja sam kod liječnika.', 'Українське «у кого?» (у лікаря, у мами) хорватською — kod: kod liječnika, kod mame. «U» означає «всередині».', '[{"hr": "Večeras smo kod prijatelja.", "ua": "Сьогодні ввечері ми в друзів."}, {"hr": "Djeca su kod bake.", "ua": "Діти в бабусі."}]'::jsonb,
        'd27ae527-a8d6-512f-acd2-a6cfec39c01f'::uuid, null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0035', 'prepositions', 'A1', 'Ігри — без «u»', 'Igram u nogomet.', 'Igram nogomet.', 'Види спорту й ігри — у знахідному без прийменника: igram nogomet, tenis, šah. «Igrati u» — калька з української.', '[{"hr": "Djeca igraju košarku.", "ua": "Діти грають у баскетбол."}, {"hr": "Igraš li šah?", "ua": "Ти граєш у шахи?"}]'::jsonb,
        '0db658cb-b2ed-5719-bced-f95a93cf15ce'::uuid, null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0036', 'prepositions', 'A1', '«Залежить від» — «ovisi o»', 'To ovisi od tebe.', 'To ovisi o tebi.', 'Ovisiti (залежати) вживаємо з o + місцевий: ovisi o vremenu, ovisi o tebi.', '[{"hr": "Sve ovisi o cijeni.", "ua": "Усе залежить від ціни."}, {"hr": "Ovisi o vremenu.", "ua": "Залежить від погоди."}]'::jsonb,
        'f891e65a-d7be-5542-ae6e-dbee5bfe415c'::uuid, null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0037', 'prepositions', 'A1', '«Думаю про тебе» — «mislim na tebe»', 'Stalno mislim o tebi.', 'Stalno mislim na tebe.', 'Думати про людину, згадувати — misliti na + знахідний. Misliti o — розмірковувати про тему: «Što misliš o tome?»', '[{"hr": "Mislim na tebe.", "ua": "Думаю про тебе."}, {"hr": "Što misliš o ovom stanu?", "ua": "Що ти думаєш про цю квартиру?"}]'::jsonb,
        '0db658cb-b2ed-5719-bced-f95a93cf15ce'::uuid, null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0038', 'prepositions', 'A1', '«Сміятися з когось» — без прийменника', 'Ne smij se s mene.', 'Ne smij se meni.', 'Сміятися з когось — smijati se komu (давальний відмінок), без прийменника.', '[{"hr": "Svi se smiju njegovoj šali.", "ua": "Усі сміються з його жарту."}, {"hr": "Zašto mi se smiješ?", "ua": "Чому ти з мене смієшся?"}]'::jsonb,
        null, null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0039', 'prepositions', 'A1', '«На факультеті», «на пошті»', 'Studiram u fakultetu.', 'Studiram na fakultetu.', 'Частину місць хорвати називають з na: na fakultetu, na poslu, na pošti. Інші — з u: u banci, u školi, u bolnici. Запам’ятовуйте разом зі словом.', '[{"hr": "Moja kći je na fakultetu.", "ua": "Моя донька в університеті."}, {"hr": "Čekam te na pošti.", "ua": "Чекаю тебе на пошті."}]'::jsonb,
        'f891e65a-d7be-5542-ae6e-dbee5bfe415c'::uuid, null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0040', 'prepositions', 'A1', '«З роботи» — «s posla»', 'Dolazim iz posla.', 'Dolazim s posla.', 'Якщо «куди» — na (na posao, na more), то «звідки» — s (s posla, s mora). Якщо «куди» — u (u školu), то «звідки» — iz (iz škole).', '[{"hr": "Vraćam se s mora.", "ua": "Я повертаюся з моря."}, {"hr": "Djeca dolaze iz škole.", "ua": "Діти приходять зі школи."}]'::jsonb,
        'd27ae527-a8d6-512f-acd2-a6cfec39c01f'::uuid, null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0041', 'false_friends', 'A0', 'Godina — це «рік», а не «година»', 'Film traje dvije godine.', 'Film traje dva sata.', 'Godina — «рік». Година — sat (і годинник теж sat).', '[{"hr": "Imam trideset godina.", "ua": "Мені тридцять років."}, {"hr": "Sastanak traje jedan sat.", "ua": "Нарада триває одну годину."}]'::jsonb,
        (select id from public.grammar_topics where cefr = 'A0' and title_ua = 'Час: дні, години, місяці' order by created_at limit 1), (select id from public.lexemes where lower(lemma) = lower('godina') and status = 'PUBLISHED' order by created_at limit 1), 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0042', 'false_friends', 'A0', 'Čas — це «мить», а «час» — vrijeme', 'Nemam čas.', 'Nemam vremena.', 'Українське «час» — vrijeme. Хорватське čas — «мить»: «Samo čas!» — «Хвилинку!»', '[{"hr": "Samo čas, molim.", "ua": "Хвилинку, будь ласка."}, {"hr": "Imaš li vremena?", "ua": "У тебе є час?"}]'::jsonb,
        null, (select id from public.lexemes where lower(lemma) = lower('vrijeme') and status = 'PUBLISHED' order by created_at limit 1), 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0043', 'false_friends', 'A1', 'Magazin — це журнал', 'Idem u magazin po kruh.', 'Idem u trgovinu po kruh.', 'Магазин — trgovina або dućan. Magazin хорватською — журнал.', '[{"hr": "Trgovina radi do devet.", "ua": "Магазин працює до дев’ятої."}, {"hr": "Čitam modni magazin.", "ua": "Читаю модний журнал."}]'::jsonb,
        null, (select id from public.lexemes where lower(lemma) = lower('trgovina') and status = 'PUBLISHED' order by created_at limit 1), 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0044', 'false_friends', 'A1', 'Ponos — це «гордість»', 'Dijete ima ponos.', 'Dijete ima proljev.', 'Ponos — «гордість». Пронос — proljev.', '[{"hr": "Ti si naš ponos.", "ua": "Ти наша гордість."}, {"hr": "Kod proljeva pijte puno vode.", "ua": "При проносі пийте багато води."}]'::jsonb,
        null, (select id from public.lexemes where lower(lemma) = lower('proljev') and status = 'PUBLISHED' order by created_at limit 1), 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0045', 'false_friends', 'A0', 'Slovo — це «літера»', 'Ne znam to slovo.', 'Ne znam tu riječ.', 'Слово — riječ. Slovo хорватською — літера: «slovo po slovo» — по літерах.', '[{"hr": "Što znači ova riječ?", "ua": "Що означає це слово?"}, {"hr": "Hrvatska abeceda ima trideset slova.", "ua": "У хорватській абетці тридцять літер."}]'::jsonb,
        null, (select id from public.lexemes where lower(lemma) = lower('riječ') and status = 'PUBLISHED' order by created_at limit 1), 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0046', 'false_friends', 'A1', '«Лист» (пошта) — pismo', 'Pišem list mami.', 'Pišem pismo mami.', 'Лист, який пишуть і надсилають, — pismo. List — аркуш паперу або листок дерева.', '[{"hr": "Iz banke stiže pismo.", "ua": "З банку приходить лист."}, {"hr": "Daj mi list papira.", "ua": "Дай мені аркуш паперу."}]'::jsonb,
        null, (select id from public.lexemes where lower(lemma) = lower('pismo') and status = 'PUBLISHED' order by created_at limit 1), 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0047', 'false_friends', 'A1', '«Любити» — voljeti, а ljubiti — «цілувати»', 'Ljubim kavu.', 'Volim kavu.', '«Любити» — voljeti: volim kavu, volim te. Ljubiti — «цілувати»: «Ljubim te» в кінці листа — «цілую».', '[{"hr": "Volim more i sunce.", "ua": "Я люблю море й сонце."}, {"hr": "Mama ljubi dijete za laku noć.", "ua": "Мама цілує дитину на добраніч."}]'::jsonb,
        '387f7bea-839e-56ae-bbfd-213aacbe7c26'::uuid, (select id from public.lexemes where lower(lemma) = lower('voljeti') and status = 'PUBLISHED' order by created_at limit 1), 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0048', 'false_friends', 'A1', 'Jagoda — це лише полуниця', 'Jagode su zdrave: borovnice, maline, kupine.', 'Bobice su zdrave: borovnice, maline, kupine.', 'Ягоди загалом — bobice. Jagoda — полуниця.', '[{"hr": "Kilogram jagoda košta četiri eura.", "ua": "Кілограм полуниці коштує чотири євро."}, {"hr": "Djeca vole šumske bobice.", "ua": "Діти люблять лісові ягоди."}]'::jsonb,
        null, (select id from public.lexemes where lower(lemma) = lower('jagoda') and status = 'PUBLISHED' order by created_at limit 1), 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0049', 'false_friends', 'A1', '«Правда» — istina', 'Je li to pravda?', 'Je li to istina?', 'Правда як «те, що є насправді», — istina. Pravda — справедливість.', '[{"hr": "To nije istina!", "ua": "Це неправда!"}, {"hr": "Traže pravdu na sudu.", "ua": "Шукають справедливості в суді."}]'::jsonb,
        null, (select id from public.lexemes where lower(lemma) = lower('istina') and status = 'PUBLISHED' order by created_at limit 1), 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0050', 'false_friends', 'A0', 'Stolica — це стілець', 'Zagreb je stolica Hrvatske.', 'Zagreb je glavni grad Hrvatske.', 'Столиця — glavni grad. Stolica — стілець.', '[{"hr": "Sjedni na stolicu.", "ua": "Сідай на стілець."}, {"hr": "Kijev je glavni grad Ukrajine.", "ua": "Київ — столиця України."}]'::jsonb,
        null, (select id from public.lexemes where lower(lemma) = lower('stolica') and status = 'PUBLISHED' order by created_at limit 1), 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0051', 'false_friends', 'A1', 'Trudna — це «вагітна»', 'Ispit je jako trudan.', 'Ispit je jako težak.', 'Важкий, трудний — težak. Trudna — вагітна!', '[{"hr": "Moja sestra je trudna.", "ua": "Моя сестра вагітна."}, {"hr": "Hrvatski nije težak.", "ua": "Хорватська не складна."}]'::jsonb,
        null, (select id from public.lexemes where lower(lemma) = lower('težak') and status = 'PUBLISHED' order by created_at limit 1), 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0052', 'false_friends', 'A1', 'Zavod — це установа, а не завод', 'Radim na zavodu za automobile.', 'Radim u tvornici automobila.', 'Завод, фабрика — tvornica. Zavod — державна установа: Zavod za zapošljavanje.', '[{"hr": "Prijavite se na Zavod za zapošljavanje.", "ua": "Зареєструйтеся в центрі зайнятості."}, {"hr": "Tvornica je izvan grada.", "ua": "Фабрика за містом."}]'::jsonb,
        null, (select id from public.lexemes where lower(lemma) = lower('zavod za zapošljavanje') and status = 'PUBLISHED' order by created_at limit 1), 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0053', 'false_friends', 'A1', 'Život — це «життя», а живіт — trbuh', 'Boli me život.', 'Boli me trbuh.', 'Живіт — trbuh. Život — життя.', '[{"hr": "Život u Hrvatskoj je miran.", "ua": "Життя в Хорватії спокійне."}, {"hr": "Dijete ima bolove u trbuhu.", "ua": "У дитини болить живіт."}]'::jsonb,
        null, (select id from public.lexemes where lower(lemma) = lower('trbuh') and status = 'PUBLISHED' order by created_at limit 1), 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0054', 'false_friends', 'A1', 'Stan — це квартира, а «стан» — stanje', 'Bolesnik je u teškom stanu.', 'Bolesnik je u teškom stanju.', 'Стан — stanje. Stan — квартира.', '[{"hr": "Tražimo stan s dvije sobe.", "ua": "Шукаємо двокімнатну квартиру."}, {"hr": "Stanje je dobro.", "ua": "Стан добрий."}]'::jsonb,
        null, (select id from public.lexemes where lower(lemma) = lower('stan') and status = 'PUBLISHED' order by created_at limit 1), 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0055', 'false_friends', 'A1', 'Brak — це шлюб', 'Ovaj stol ima brak.', 'Ovaj stol je oštećen.', 'Брак (дефект) — oštećenje, greška. Brak — шлюб: «sretan brak».', '[{"hr": "U braku su deset godina.", "ua": "Вони в шлюбі десять років."}, {"hr": "Vratite proizvod ako je oštećen.", "ua": "Поверніть товар, якщо він пошкоджений."}]'::jsonb,
        null, (select id from public.lexemes where lower(lemma) = lower('brak') and status = 'PUBLISHED' order by created_at limit 1), 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0056', 'false_friends', 'A1', 'Vaga — це терези, а вага — težina', 'Moja vaga je sedamdeset kila.', 'Imam sedamdeset kila.', 'Вага (скільки важите) — težina, а «я важу 70 кг» — imam 70 kila. Vaga — терези.', '[{"hr": "Stani na vagu.", "ua": "Стань на терези."}, {"hr": "Težina prtljage je dvadeset kila.", "ua": "Вага багажу — двадцять кілограмів."}]'::jsonb,
        null, (select id from public.lexemes where lower(lemma) = lower('težina') and status = 'PUBLISHED' order by created_at limit 1), 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0057', 'false_friends', 'A1', 'Šutjeti — це «мовчати»', 'Ne šuti, to je ozbiljno!', 'Ne šali se, to je ozbiljno!', 'Жартувати — šaliti se. Šutjeti — мовчати.', '[{"hr": "Zašto šutiš?", "ua": "Чому ти мовчиш?"}, {"hr": "Samo se šalim.", "ua": "Я просто жартую."}]'::jsonb,
        null, (select id from public.lexemes where lower(lemma) = lower('šutjeti') and status = 'PUBLISHED' order by created_at limit 1), 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0058', 'pronunciation', 'A0', 'H — як українське «х»', 'Hrvatska — «Грватська»', 'Hrvatska — «Хрватська»', 'Хорватська h — це українське «х». В українській латинці h означає «г», тому так легко прочитати неправильно.', '[{"hr": "Hvala!", "ua": "Дякую! [хвала]"}, {"hr": "Hrana je ukusna.", "ua": "Їжа смачна. [храна]"}]'::jsonb,
        (select id from public.grammar_topics where cefr = 'A0' and title_ua = 'Вимова: хорватські літери' order by created_at limit 1), null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0059', 'pronunciation', 'A0', 'G — тверде «ґ»', 'grad — «град» (як «гора»)', 'grad — «ґрад» (як «ґанок»)', 'Хорватська g завжди тверда, як українське «ґ»: grad, govoriti, glava.', '[{"hr": "Govorim hrvatski.", "ua": "Я говорю хорватською. [ґоворім]"}, {"hr": "Gdje je grad?", "ua": "Де місто? [ґдє]"}]'::jsonb,
        (select id from public.grammar_topics where cefr = 'A0' and title_ua = 'Вимова: хорватські літери' order by created_at limit 1), null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0060', 'pronunciation', 'A0', 'Č і ć — різні звуки', 'kuća — тверде «ч», як у слові «чай»', 'kuća — м’яке «ć», майже «кутя»', 'č — тверде «ч» (čaj — чай). ć — м’якше, між «ч» і «ть»: kuća, noć, sreća.', '[{"hr": "Laku noć!", "ua": "На добраніч!"}, {"hr": "Čaj bez šećera.", "ua": "Чай без цукру."}]'::jsonb,
        (select id from public.grammar_topics where cefr = 'A0' and title_ua = 'Вимова: хорватські літери' order by created_at limit 1), null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0061', 'pronunciation', 'A0', 'Lj і nj — один м’який звук', 'ljubav — «л-йубав»', 'ljubav — «любав»', 'lj і nj — по одному звуку: lj = «ль», nj = «нь». Не вимовляйте «л» і «й» окремо.', '[{"hr": "Ljudi su ljubazni.", "ua": "Люди привітні."}, {"hr": "Nedjelja je neradni dan.", "ua": "Неділя — неробочий день."}]'::jsonb,
        (select id from public.grammar_topics where cefr = 'A0' and title_ua = 'Вимова: хорватські літери' order by created_at limit 1), null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0062', 'pronunciation', 'A0', 'R без голосної: trg, vrt', 'trg — «тирг»', 'trg — «трг» (протяжне «р»)', 'r може бути голосним звуком: trg, vrt, prst, Hrvatska. Не вставляйте «и» чи «е» — просто протягніть «р».', '[{"hr": "Trg je u centru.", "ua": "Площа в центрі."}, {"hr": "Imam mali vrt.", "ua": "У мене маленький садок."}]'::jsonb,
        (select id from public.grammar_topics where cefr = 'A0' and title_ua = 'Вимова: хорватські літери' order by created_at limit 1), null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0063', 'stress', 'A0', 'Наголос ніколи не на останньому складі', 'voda — «вода́»', 'voda — «во́да»', 'У хорватській наголос не падає на останній склад слова з кількох складів. Тому vòda, rúka, nòga — з наголосом на першому складі, хоч українською вода́, рука́, нога́.', '[{"hr": "Čaša vode, molim.", "ua": "Склянку води, будь ласка."}, {"hr": "Boli me noga.", "ua": "У мене болить нога."}]'::jsonb,
        (select id from public.grammar_topics where cefr = 'A0' and title_ua = 'Вимова: хорватські літери' order by created_at limit 1), null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0064', 'stress', 'A0', 'Ukrajina — наголос на першому складі', 'Ukrajina — «Украї́на»', 'Ukrajina — «У́країна»', 'Назви країн і міст часто мають інший наголос, ніж українською: Ùkrajina, Hr̀vatska.', '[{"hr": "Ja sam iz Ukrajine.", "ua": "Я з України."}, {"hr": "Ukrajina je velika zemlja.", "ua": "Україна — велика країна."}]'::jsonb,
        (select id from public.grammar_topics where cefr = 'A0' and title_ua = 'Вимова: хорватські літери' order by created_at limit 1), null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0065', 'stress', 'A0', 'Zagreb — наголос на «Za»', 'Zagreb — «Загре́б»', 'Zagreb — «За́греб»', 'Хорвати кажуть Zàgreb — з наголосом на першому складі. Так само Split — один склад, Zadar — «За́дар».', '[{"hr": "Živim u Zagrebu.", "ua": "Я живу в Загребі."}, {"hr": "Zagreb je glavni grad.", "ua": "Загреб — столиця."}]'::jsonb,
        (select id from public.grammar_topics where cefr = 'A0' and title_ua = 'Вимова: хорватські літери' order by created_at limit 1), null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0066', 'stress', 'A1', 'Sestra, zima, glava — наголос на першому складі', 'sestra — «сестра́»', 'sestra — «се́стра»', 'Багато спільних з українською слів у хорватській мають наголос на першому складі: sèstra, zíma, glàva.', '[{"hr": "Moja sestra živi u Splitu.", "ua": "Моя сестра живе в Спліті."}, {"hr": "Zimi je hladno.", "ua": "Узимку холодно."}]'::jsonb,
        (select id from public.grammar_topics where cefr = 'A0' and title_ua = 'Вимова: хорватські літери' order by created_at limit 1), null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0067', 'collocations', 'A1', '«Приймати душ» — tuširati se', 'Primam tuš ujutro.', 'Tuširam se ujutro.', '«Приймати душ» — одне дієслово tuširati se. Primati — «отримувати» (primam plaću).', '[{"hr": "Tuširam se navečer.", "ua": "Я приймаю душ увечері."}, {"hr": "Kupam se u moru.", "ua": "Я купаюся в морі."}]'::jsonb,
        '387f7bea-839e-56ae-bbfd-213aacbe7c26'::uuid, null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0068', 'collocations', 'A1', '«Приймати ліки» — uzimati', 'Primam lijek tri puta dnevno.', 'Uzimam lijek tri puta dnevno.', 'Ліки «беремо»: uzimati lijek, popiti tabletu. Primati lijek звучить як «отримувати ліки».', '[{"hr": "Uzimajte tablete poslije jela.", "ua": "Приймайте таблетки після їжі."}, {"hr": "Popij tabletu s vodom.", "ua": "Випий таблетку з водою."}]'::jsonb,
        '45c5cb39-daf7-5dab-8413-9a5302b33553'::uuid, null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0069', 'collocations', 'A1', '«Поставити питання» — postaviti', 'Mogu li zadati pitanje?', 'Mogu li postaviti pitanje?', 'Питання «ставлять»: postaviti pitanje. Zadati — задати завдання: zadati zadaću.', '[{"hr": "Imam jedno pitanje.", "ua": "У мене одне запитання."}, {"hr": "Profesorica zadaje zadaću.", "ua": "Викладачка задає домашнє завдання."}]'::jsonb,
        '1435d343-6721-5eb7-8dc2-af7f9a027716'::uuid, null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0070', 'collocations', 'A1', '«Скласти іспит» — položiti', 'Moram složiti ispit.', 'Moram položiti ispit.', 'Скласти іспит — položiti ispit, складати — polagati. Složiti — скласти речі: složiti odjeću.', '[{"hr": "Sutra polažem ispit.", "ua": "Завтра я складаю іспит."}, {"hr": "Složi odjeću u ormar.", "ua": "Склади одяг у шафу."}]'::jsonb,
        '6ba7fa0f-46cc-5679-85bb-23c1329bfa18'::uuid, null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0071', 'collocations', 'A2', '«Прийняти рішення» — donijeti odluku', 'Moram primiti odluku.', 'Moram donijeti odluku.', 'Рішення «приносять»: donijeti odluku. Primiti — отримати.', '[{"hr": "Odluku donosimo zajedno.", "ua": "Рішення ухвалюємо разом."}, {"hr": "Teško je donijeti odluku.", "ua": "Важко ухвалити рішення."}]'::jsonb,
        null, null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0072', 'collocations', 'A1', '«Здати кров» — vaditi krv', 'Moram predati analizu krvi.', 'Moram izvaditi krv.', 'Здати аналіз крові — izvaditi krv (у лабораторії vade krv). Результат аналізу — nalaz.', '[{"hr": "Sutra vadim krv natašte.", "ua": "Завтра здаю кров натщесерце."}, {"hr": "Kada dobivam nalaz?", "ua": "Коли я отримаю результат?"}]'::jsonb,
        'd27ae527-a8d6-512f-acd2-a6cfec39c01f'::uuid, null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0073', 'collocations', 'A1', '«Сидіти на дієті» — biti na dijeti', 'Sjedim na dijeti.', 'Na dijeti sam.', 'Хорвати «є на дієті»: biti na dijeti. Sjediti — лише «сидіти» буквально.', '[{"hr": "Sestra je na dijeti.", "ua": "Сестра на дієті."}, {"hr": "Ne jedem kolače, na dijeti sam.", "ua": "Я не їм тістечок, я на дієті."}]'::jsonb,
        'b58103b4-a259-5384-aa65-ffc0e2a195c8'::uuid, null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;
insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)
values ('UKR-HR-0074', 'articles', 'A0', 'Артиклів немає — «jedan» не потрібен', 'Ja sam jedan student iz Ukrajine.', 'Ja sam student iz Ukrajine.', 'У хорватській, як і в українській, артиклів немає. Не перекладайте англійські a / the словами jedan чи taj: jedan — це «один» або «якийсь».', '[{"hr": "Imam pitanje.", "ua": "У мене є питання."}, {"hr": "Ovo je kava za tebe.", "ua": "Це кава для тебе."}]'::jsonb,
        (select id from public.grammar_topics where cefr = 'A0' and title_ua = 'Особові займенники та дієслово BITI' order by created_at limit 1), null, 'PUBLISHED', 'claude_interference_v1')
on conflict (code) do nothing;

-- Журнал перевірки (один запис на кожну помилку)
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'linguistic_error', e.id, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: каталог типових помилок українців (§19) за запитом власника 2026-10-13 (interference_v1). Потрібна перевірка носієм.'
from public.linguistic_errors e
where e.source = 'claude_interference_v1'
  and not exists (select 1 from public.content_reviews r where r.entity_id = e.id and r.notes = 'Бета: каталог типових помилок українців (§19) за запитом власника 2026-10-13 (interference_v1). Потрібна перевірка носієм.');

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_total int; v_cats int; v_no_link int;
begin
  select count(*), count(distinct category) into v_total, v_cats from public.linguistic_errors where source = 'claude_interference_v1' and status = 'PUBLISHED';
  select count(*) into v_no_link from public.linguistic_errors
   where source = 'claude_interference_v1' and grammar_topic_id is null and lexeme_id is null and cefr in ('A0', 'A1')
     and code in ('UKR-HR-0001', 'UKR-HR-0002', 'UKR-HR-0003', 'UKR-HR-0004', 'UKR-HR-0005', 'UKR-HR-0006', 'UKR-HR-0007', 'UKR-HR-0008', 'UKR-HR-0010', 'UKR-HR-0011', 'UKR-HR-0012', 'UKR-HR-0013', 'UKR-HR-0014', 'UKR-HR-0015', 'UKR-HR-0016', 'UKR-HR-0017', 'UKR-HR-0018', 'UKR-HR-0019', 'UKR-HR-0020', 'UKR-HR-0021', 'UKR-HR-0022', 'UKR-HR-0023', 'UKR-HR-0024', 'UKR-HR-0025', 'UKR-HR-0026', 'UKR-HR-0027', 'UKR-HR-0028', 'UKR-HR-0029', 'UKR-HR-0030', 'UKR-HR-0031', 'UKR-HR-0032', 'UKR-HR-0034', 'UKR-HR-0035', 'UKR-HR-0036', 'UKR-HR-0037', 'UKR-HR-0039', 'UKR-HR-0040', 'UKR-HR-0041', 'UKR-HR-0042', 'UKR-HR-0043', 'UKR-HR-0044', 'UKR-HR-0045', 'UKR-HR-0046', 'UKR-HR-0047', 'UKR-HR-0048', 'UKR-HR-0049', 'UKR-HR-0050', 'UKR-HR-0051', 'UKR-HR-0052', 'UKR-HR-0053', 'UKR-HR-0054', 'UKR-HR-0055', 'UKR-HR-0056', 'UKR-HR-0057', 'UKR-HR-0058', 'UKR-HR-0059', 'UKR-HR-0060', 'UKR-HR-0061', 'UKR-HR-0062', 'UKR-HR-0063', 'UKR-HR-0064', 'UKR-HR-0065', 'UKR-HR-0066', 'UKR-HR-0067', 'UKR-HR-0068', 'UKR-HR-0069', 'UKR-HR-0070', 'UKR-HR-0072', 'UKR-HR-0073', 'UKR-HR-0074');
  if v_total < 74 then raise exception 'Типових помилок %, очікувалось 74', v_total; end if;
  if v_cats < 12 then raise exception 'Категорій %, очікувалось 12', v_cats; end if;
  if v_no_link > 0 then raise exception '% помилок не знайшли свою тему граматики чи слово', v_no_link; end if;
  raise notice 'Готово: типових помилок — %, категорій — %', v_total, v_cats;
end $$;

commit;
