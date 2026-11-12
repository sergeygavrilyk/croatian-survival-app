-- =====================================================================
-- Програма A2 v2 · модуль A2.13 «Плани, мрії й домовленості» · 2026-11-12
-- Згенеровано: python3 -B scripts/gen_curriculum_a2_v2.py 13 (не редагуйте вручну).
--
-- Рішення власника 2026-11-12: 20–25 нових слів на урок, 90–95 % слів — нові для рівня, діалоги під тему,
-- частіше Даша / Дар’я; «Прослухайте діалог чи оголошення» в кожному уроці; бета (PUBLISHED).
--   * Уроки 78–83 (6): слів у них 121. Кожен: 20–25 слів, 2 діалоги, 15 вправ
--     (одна — «Прослухайте діалог чи оголошення»), «Напишіть повідомлення» і «Перекажіть другу» (ua → hr, необов’язкові), 20 хв.
--   * Слова: 121 (нові — PUBLISHED; ті, що вже є в словнику, не змінюються).
--   * Модуль і юніт A2.13 → PUBLISHED. Потрібен уже запущений 20261112_curriculum_a2_v2_00_structure.sql.
--   * Нічого не видаляє. Усе в одній транзакції; повторний запуск безпечний.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

do $$ begin
  if not exists (select 1 from public.units where id = '55b7d23a-2c46-5ea6-bd0c-df533308d66e') then
    raise exception 'Спершу запустіть 20261112_curriculum_a2_v2_00_structure.sql (структура A2 v2)';
  end if;
  if not exists (select 1 from pg_constraint where conname = 'exercises_type_check' and conrelid = 'public.exercises'::regclass
                  and pg_get_constraintdef(oid) like '%listening_dialogue%') then
    raise exception 'Спершу потрібна міграція M23 (listening_dialogue)';
  end if;
end $$;

-- Допоміжні функції (тимчасові: зникають після запуску)
create or replace function pg_temp.word(p_lesson uuid, p_lemma text, p_pos int) returns int language plpgsql as $f$
declare v_id uuid;
begin
  select id into v_id from public.lexemes where lower(lemma) = lower(p_lemma) and status = 'PUBLISHED' order by created_at limit 1;
  if v_id is null then raise exception 'Немає опублікованого слова «%»', p_lemma; end if;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (p_lesson, 'lexeme', v_id, p_pos + 1, 'vocabulary');
  return p_pos + 1;
end $f$;

create or replace function pg_temp.ex(p_lesson uuid, p_pos int, p_id uuid, p_type text, p_question text, p_answer text, p_options jsonb,
                                      p_level text, p_order int, p_status text, p_lemma text, p_skill text) returns int language plpgsql as $f$
declare v_id uuid;
begin
  if p_lemma is not null then
    select id into v_id from public.lexemes where lower(lemma) = lower(p_lemma) and status = 'PUBLISHED' order by created_at limit 1;
  end if;
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, lexeme_id)
  values (p_id, p_type, p_question, p_answer, p_options, p_level, p_order, p_status, v_id) on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (p_lesson, 'exercise', p_id, p_pos + 1, p_skill);
  return p_pos + 1;
end $f$;

create or replace function pg_temp.turn(p_id uuid, p_conv uuid, p_speaker text, p_hr text, p_ua text, p_order int) returns void language sql as $f$
  insert into public.conversation_turns (id, conversation_id, speaker_name, hr_text, ua_translation, order_index)
  values (p_id, p_conv, p_speaker, p_hr, p_ua, p_order) on conflict (id) do nothing;
$f$;

create or replace function pg_temp.ex_task(p_lesson uuid, p_pos int, p_id uuid, p_type text, p_question text, p_answer text,
                                           p_level text, p_status text, p_task jsonb, p_required boolean, p_skill text) returns int language plpgsql as $f$
begin
  insert into public.exercises (id, exercise_type, question_text, correct_answer, options, level, order_index, status, task)
  values (p_id, p_type, p_question, p_answer, null, p_level, 0, p_status, p_task) on conflict (id) do nothing;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, required, target_skill)
  values (p_lesson, 'exercise', p_id, p_pos + 1, p_required, p_skill);
  return p_pos + 1;
end $f$;

-- 1. Слова уроків A2.13 (121): нові — PUBLISHED (бета); наявні в словнику не змінюються
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source)
select t.lemma, t.normalized, 'hr', t.pos, 'A2', t.ua, t.vtype, t.forms, t.examples, 'PUBLISHED', 'claude_curriculum_a2_v2'
  from jsonb_to_recordset('[{"lemma": "postaviti cilj", "normalized": "postaviti cilj", "pos": "phrase", "ua": "поставити мету", "vtype": "chunk", "forms": {}, "examples": ["Svake godine postavim tri cilja."]}, {"lemma": "ostvariti cilj", "normalized": "ostvariti cilj", "pos": "phrase", "ua": "досягти мети", "vtype": "chunk", "forms": {}, "examples": ["Prošle godine sam ostvarila svoj cilj."]}, {"lemma": "novogodišnja odluka", "normalized": "novogodisnja odluka", "pos": "phrase", "ua": "новорічна обіцянка (рішення)", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Moja novogodišnja odluka je više čitati."]}, {"lemma": "dugoročni plan", "normalized": "dugorocni plan", "pos": "phrase", "ua": "довгостроковий план", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Dugoročni plan nam je kupiti stan."]}, {"lemma": "kratkoročni", "normalized": "kratkorocni", "pos": "adjective", "ua": "короткостроковий", "vtype": "core", "forms": {}, "examples": ["Kratkoročni cilj je položiti B1."]}, {"lemma": "uštedjeti", "normalized": "ustedjeti", "pos": "verb", "ua": "заощадити", "vtype": "core", "forms": {"aspect": "pfv", "pair": "štedjeti"}, "examples": ["Do ljeta ću uštedjeti za more."]}, {"lemma": "štedjeti za", "normalized": "stedjeti za", "pos": "phrase", "ua": "відкладати гроші на", "vtype": "chunk", "forms": {}, "examples": ["Štedimo za novi auto."]}, {"lemma": "motivacija", "normalized": "motivacija", "pos": "noun", "ua": "мотивація", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Nedostaje mi motivacije zimi."]}, {"lemma": "ustrajnost", "normalized": "ustrajnost", "pos": "noun", "ua": "наполегливість", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Za jezik treba ustrajnosti."]}, {"lemma": "zacrtati", "normalized": "zacrtati", "pos": "verb", "ua": "накреслити, запланувати", "vtype": "core", "forms": {"aspect": "pfv", "pair": "zacrtavati"}, "examples": ["Zacrtala sam plan za cijelu godinu."]}, {"lemma": "ispuniti obećanje", "normalized": "ispuniti obecanje", "pos": "phrase", "ua": "виконати обіцянку", "vtype": "chunk", "forms": {}, "examples": ["Ispunit ću obećanje koje sam dala djeci."]}, {"lemma": "do kraja godine", "normalized": "do kraja godine", "pos": "phrase", "ua": "до кінця року", "vtype": "chunk", "forms": {}, "examples": ["Do kraja godine želim promijeniti posao."]}, {"lemma": "štednja", "normalized": "stednja", "pos": "noun", "ua": "заощадження", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Štednja za stan traje godinama."]}, {"lemma": "odustati", "normalized": "odustati", "pos": "verb", "ua": "відмовитися (від мети), здатися", "vtype": "core", "forms": {"aspect": "pfv", "pair": "odustajati"}, "examples": ["Nemoj odustati u veljači!"]}, {"lemma": "certifikat", "normalized": "certifikat", "pos": "noun", "ua": "сертифікат", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Nakon ispita dobit ćete certifikat B1."]}, {"lemma": "dobiti povišicu", "normalized": "dobiti povisicu", "pos": "phrase", "ua": "отримати підвищення зарплати", "vtype": "chunk", "forms": {}, "examples": ["Nadam se da ću dobiti povišicu."]}, {"lemma": "vozački za motor", "normalized": "vozacki za motor", "pos": "phrase", "ua": "права на мотоцикл", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Želim položiti vozački za motor."]}, {"lemma": "vrijedno raditi", "normalized": "vrijedno raditi", "pos": "phrase", "ua": "старанно працювати", "vtype": "chunk", "forms": {}, "examples": ["Vrijedno radim na svom hrvatskom."]}, {"lemma": "vidjet ćemo", "normalized": "vidjet cemo", "pos": "phrase", "ua": "побачимо", "vtype": "chunk", "forms": {}, "examples": ["Hoću li uspjeti? Vidjet ćemo."]}, {"lemma": "planer", "normalized": "planer", "pos": "noun", "ua": "планер, щоденник планів", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Ciljeve zapisujem u planer."]}, {"lemma": "lista ciljeva", "normalized": "lista ciljeva", "pos": "phrase", "ua": "список цілей", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Lista ciljeva visi na hladnjaku."]}, {"lemma": "ostvariti san", "normalized": "ostvariti san", "pos": "phrase", "ua": "здійснити мрію", "vtype": "chunk", "forms": {}, "examples": ["Jednog dana ću ostvariti san."]}, {"lemma": "volio bih", "normalized": "volio bih", "pos": "phrase", "ua": "я б дуже хотів", "vtype": "chunk", "forms": {}, "examples": ["Volio bih naučiti svirati gitaru."]}, {"lemma": "da imam", "normalized": "da imam", "pos": "phrase", "ua": "якби я мав", "vtype": "chunk", "forms": {}, "examples": ["Da imam više vremena, slikala bih."]}, {"lemma": "kad bih mogla", "normalized": "kad bih mogla", "pos": "phrase", "ua": "якби я могла", "vtype": "chunk", "forms": {}, "examples": ["Kad bih mogla, putovala bih oko svijeta."]}, {"lemma": "putovati oko svijeta", "normalized": "putovati oko svijeta", "pos": "phrase", "ua": "подорожувати навколо світу", "vtype": "chunk", "forms": {}, "examples": ["Mladi često sanjaju o putovanju oko svijeta."]}, {"lemma": "dobiti na lutriji", "normalized": "dobiti na lutriji", "pos": "phrase", "ua": "виграти в лотерею", "vtype": "chunk", "forms": {}, "examples": ["Što bi napravio da dobiješ na lutriji?"]}, {"lemma": "jedrilica", "normalized": "jedrilica", "pos": "noun", "ua": "вітрильник", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Kad bih imao novca, kupio bih jedrilicu."]}, {"lemma": "slikati", "normalized": "slikati", "pos": "verb", "ua": "малювати (фарбами)", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Volim slikati more."]}, {"lemma": "svirati", "normalized": "svirati", "pos": "verb", "ua": "грати (на інструменті)", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Sin svira gitaru."]}, {"lemma": "maštarija", "normalized": "mastarija", "pos": "noun", "ua": "фантазія, мрія", "vtype": "core", "forms": {"gender": "f"}, "examples": ["To je samo maštarija."]}, {"lemma": "nedostižan", "normalized": "nedostizan", "pos": "adjective", "ua": "недосяжний", "vtype": "core", "forms": {}, "examples": ["Taj san mi se činio nedostižan."]}, {"lemma": "realan", "normalized": "realan", "pos": "adjective", "ua": "реальний", "vtype": "core", "forms": {}, "examples": ["Je li taj plan realan?"]}, {"lemma": "zašto ne", "normalized": "zasto ne", "pos": "phrase", "ua": "чому б і ні", "vtype": "chunk", "forms": {}, "examples": ["Kupiti kuću na selu? Zašto ne!"]}, {"lemma": "mirno starenje", "normalized": "mirno starenje", "pos": "phrase", "ua": "спокійна старість", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Želim mirno starenje uz more."]}, {"lemma": "vlastiti posao", "normalized": "vlastiti posao", "pos": "phrase", "ua": "власна справа", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Moj san je vlastiti posao."]}, {"lemma": "nikad ne reci nikad", "normalized": "nikad ne reci nikad", "pos": "phrase", "ua": "ніколи не кажи «ніколи»", "vtype": "chunk", "forms": {}, "examples": ["Nikad ne reci nikad!"]}, {"lemma": "jedriti", "normalized": "jedriti", "pos": "verb", "ua": "ходити під вітрилом", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Ljeti jedrimo po Kornatima."]}, {"lemma": "polarna svjetlost", "normalized": "polarna svjetlost", "pos": "phrase", "ua": "північне сяйво", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Voljela bih vidjeti polarnu svjetlost."]}, {"lemma": "lutrija", "normalized": "lutrija", "pos": "noun", "ua": "лотерея", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Igram lutriju svaki tjedan."]}, {"lemma": "kad odrastem", "normalized": "kad odrastem", "pos": "phrase", "ua": "коли виросту", "vtype": "chunk", "forms": {}, "examples": ["Kad odrastem, bit ću pilot."]}, {"lemma": "iskrsnulo mi je nešto", "normalized": "iskrsnulo mi je nesto", "pos": "phrase", "ua": "у мене дещо непередбачене", "vtype": "chunk", "forms": {}, "examples": ["Oprosti, iskrsnulo mi je nešto na poslu."]}, {"lemma": "pomaknuti dogovor", "normalized": "pomaknuti dogovor", "pos": "phrase", "ua": "перенести зустріч", "vtype": "chunk", "forms": {}, "examples": ["Možemo li pomaknuti dogovor na petak?"]}, {"lemma": "otkazati sastanak", "normalized": "otkazati sastanak", "pos": "phrase", "ua": "скасувати зустріч", "vtype": "chunk", "forms": {}, "examples": ["Moram otkazati sastanak, bolesna sam."]}, {"lemma": "premjestiti termin", "normalized": "premjestiti termin", "pos": "phrase", "ua": "перенести час (запису)", "vtype": "chunk", "forms": {}, "examples": ["Premjestila sam termin kod frizerke."]}, {"lemma": "novi termin", "normalized": "novi termin", "pos": "phrase", "ua": "новий час", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Predložite mi novi termin."]}, {"lemma": "odgovara li ti", "normalized": "odgovara li ti", "pos": "phrase", "ua": "тобі підходить?", "vtype": "chunk", "forms": {}, "examples": ["Odgovara li ti u četvrtak?"]}, {"lemma": "ne stižem", "normalized": "ne stizem", "pos": "phrase", "ua": "я не встигаю", "vtype": "chunk", "forms": {}, "examples": ["Ne stižem do šest, kasnim."]}, {"lemma": "kasnit ću", "normalized": "kasnit cu", "pos": "phrase", "ua": "я запізнюся", "vtype": "chunk", "forms": {}, "examples": ["Kasnit ću desetak minuta."]}, {"lemma": "javit ću ti", "normalized": "javit cu ti", "pos": "phrase", "ua": "я тобі повідомлю", "vtype": "chunk", "forms": {}, "examples": ["Javit ću ti čim budem znala."]}, {"lemma": "vidimo se onda", "normalized": "vidimo se onda", "pos": "phrase", "ua": "тоді побачимося", "vtype": "chunk", "forms": {}, "examples": ["Dobro, vidimo se onda u subotu."]}, {"lemma": "ispričavam se zbog otkazivanja", "normalized": "ispricavam se zbog otkazivanja", "pos": "phrase", "ua": "перепрошую за скасування", "vtype": "chunk", "forms": {}, "examples": ["Ispričavam se zbog otkazivanja u zadnji čas."]}, {"lemma": "u zadnji čas", "normalized": "u zadnji cas", "pos": "phrase", "ua": "в останню хвилину", "vtype": "chunk", "forms": {}, "examples": ["Otkazao je u zadnji čas."]}, {"lemma": "dogovorimo se za", "normalized": "dogovorimo se za", "pos": "phrase", "ua": "домовмося на", "vtype": "chunk", "forms": {}, "examples": ["Dogovorimo se za iduću srijedu."]}, {"lemma": "potvrdi mi", "normalized": "potvrdi mi", "pos": "phrase", "ua": "підтверди мені", "vtype": "chunk", "forms": {}, "examples": ["Potvrdi mi do večeras."]}, {"lemma": "nema problema", "normalized": "nema problema", "pos": "phrase", "ua": "без проблем", "vtype": "chunk", "forms": {}, "examples": ["Nema problema, razumijem."]}, {"lemma": "veseliti se", "normalized": "veseliti se", "pos": "verb", "ua": "радіти, чекати з нетерпінням", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Veselim se našem susretu."]}, {"lemma": "susret", "normalized": "susret", "pos": "noun", "ua": "зустріч", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Susret je pomaknut na sljedeći tjedan."]}, {"lemma": "raspored mi je pun", "normalized": "raspored mi je pun", "pos": "phrase", "ua": "у мене щільний розклад", "vtype": "chunk", "forms": {}, "examples": ["Ovaj tjedan raspored mi je pun."]}, {"lemma": "odgađati", "normalized": "odgadati", "pos": "verb", "ua": "відкладати, переносити (знову й знову)", "vtype": "core", "forms": {"aspect": "ipfv", "pair": "odgoditi"}, "examples": ["Stalno odgađamo kavu."]}, {"lemma": "promjena plana", "normalized": "promjena plana", "pos": "phrase", "ua": "зміна плану", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Imamo promjenu plana."]}, {"lemma": "dopuštenje", "normalized": "dopustenje", "pos": "noun", "ua": "дозвіл", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Za to trebate dopuštenje roditelja."]}, {"lemma": "zatražiti dopuštenje", "normalized": "zatraziti dopustenje", "pos": "phrase", "ua": "попросити дозволу", "vtype": "chunk", "forms": {}, "examples": ["Zatražila sam dopuštenje od šefa."]}, {"lemma": "bi li bilo moguće", "normalized": "bi li bilo moguce", "pos": "phrase", "ua": "чи можна було б", "vtype": "chunk", "forms": {}, "examples": ["Bi li bilo moguće doći ranije?"]}, {"lemma": "smjela bih", "normalized": "smjela bih", "pos": "phrase", "ua": "чи можна мені (ввічливо)", "vtype": "chunk", "forms": {}, "examples": ["Bih li smjela otvoriti prozor?"]}, {"lemma": "morali biste", "normalized": "morali biste", "pos": "phrase", "ua": "вам довелося б", "vtype": "chunk", "forms": {}, "examples": ["Morali biste ispuniti obrazac."]}, {"lemma": "dužnost", "normalized": "duznost", "pos": "noun", "ua": "обов’язок", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Moja dužnost je zaključati ured."]}, {"lemma": "obvezan", "normalized": "obvezan", "pos": "adjective", "ua": "обов’язковий", "vtype": "core", "forms": {}, "examples": ["Ovaj sastanak je obvezan za sve."]}, {"lemma": "preporučeno", "normalized": "preporuceno", "pos": "adverb", "ua": "рекомендовано", "vtype": "core", "forms": {}, "examples": ["Preporučeno je doći ranije."]}, {"lemma": "strogo zabranjeno", "normalized": "strogo zabranjeno", "pos": "phrase", "ua": "суворо заборонено", "vtype": "chunk", "forms": {}, "examples": ["Pušenje je strogo zabranjeno."]}, {"lemma": "iznimka", "normalized": "iznimka", "pos": "noun", "ua": "виняток", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Za djecu postoji iznimka."]}, {"lemma": "pravila kuće", "normalized": "pravila kuce", "pos": "phrase", "ua": "правила дому", "vtype": "chunk", "forms": {"gender": "n_pl"}, "examples": ["Pravila kuće su na vratima."]}, {"lemma": "pridržavati se", "normalized": "pridrzavati se", "pos": "verb", "ua": "дотримуватися", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Molimo da se pridržavate pravila."]}, {"lemma": "kršiti pravila", "normalized": "krsiti pravila", "pos": "phrase", "ua": "порушувати правила", "vtype": "chunk", "forms": {}, "examples": ["Tko krši pravila, plaća kaznu."]}, {"lemma": "imati pravo na", "normalized": "imati pravo na", "pos": "phrase", "ua": "мати право на", "vtype": "chunk", "forms": {}, "examples": ["Imate pravo na pauzu od pola sata."]}, {"lemma": "ne bi trebalo", "normalized": "ne bi trebalo", "pos": "phrase", "ua": "не слід було б", "vtype": "chunk", "forms": {}, "examples": ["To ne bi trebalo biti problem."]}, {"lemma": "odobrenje", "normalized": "odobrenje", "pos": "noun", "ua": "схвалення, дозвіл (офіційний)", "vtype": "core", "forms": {"gender": "n"}, "examples": ["Za gradnju terase treba odobrenje."]}, {"lemma": "na vlastitu odgovornost", "normalized": "na vlastitu odgovornost", "pos": "phrase", "ua": "на власну відповідальність", "vtype": "chunk", "forms": {}, "examples": ["Kupanje je na vlastitu odgovornost."]}, {"lemma": "ulaz zabranjen", "normalized": "ulaz zabranjen", "pos": "phrase", "ua": "вхід заборонено", "vtype": "chunk", "forms": {}, "examples": ["Na vratima piše: ulaz zabranjen."]}, {"lemma": "zabrana", "normalized": "zabrana", "pos": "noun", "ua": "заборона", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Zabrana parkiranja vrijedi i vikendom."]}, {"lemma": "propis", "normalized": "propis", "pos": "noun", "ua": "норма, припис (закону)", "vtype": "core", "forms": {"gender": "m"}, "examples": ["Po propisu, kaciga je obvezna."]}, {"lemma": "pod uvjetom da", "normalized": "pod uvjetom da", "pos": "phrase", "ua": "за умови, що", "vtype": "chunk", "forms": {}, "examples": ["Doći ću, pod uvjetom da ne pada kiša."]}, {"lemma": "u slučaju da", "normalized": "u slucaju da", "pos": "phrase", "ua": "у разі, якщо", "vtype": "chunk", "forms": {}, "examples": ["U slučaju da kasnim, počnite bez mene."]}, {"lemma": "osim ako", "normalized": "osim ako", "pos": "phrase", "ua": "хіба що, якщо тільки не", "vtype": "chunk", "forms": {}, "examples": ["Dolazim, osim ako me šef ne zadrži."]}, {"lemma": "ako bude", "normalized": "ako bude", "pos": "phrase", "ua": "якщо буде", "vtype": "chunk", "forms": {}, "examples": ["Ako bude lijepo vrijeme, idemo na izlet."]}, {"lemma": "kad budem imala vremena", "normalized": "kad budem imala vremena", "pos": "phrase", "ua": "коли матиму час", "vtype": "chunk", "forms": {}, "examples": ["Kad budem imala vremena, nazvat ću te."]}, {"lemma": "čim budem znao", "normalized": "cim budem znao", "pos": "phrase", "ua": "щойно знатиму", "vtype": "chunk", "forms": {}, "examples": ["Čim budem znao, javit ću ti."]}, {"lemma": "dogovoreno", "normalized": "dogovoreno", "pos": "interjection", "ua": "домовилися", "vtype": "formulaic", "forms": {}, "examples": ["Dogovoreno, vidimo se u osam!"]}, {"lemma": "rezervni plan", "normalized": "rezervni plan", "pos": "phrase", "ua": "запасний план", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Ako pada kiša, imamo rezervni plan."]}, {"lemma": "ovisno o", "normalized": "ovisno o", "pos": "phrase", "ua": "залежно від", "vtype": "chunk", "forms": {}, "examples": ["Ovisno o vremenu, idemo na more ili u kino."]}, {"lemma": "obećati", "normalized": "obecati", "pos": "verb", "ua": "пообіцяти", "vtype": "core", "forms": {"aspect": "pfv", "pair": "obećavati"}, "examples": ["Obećala sam djeci izlet."]}, {"lemma": "održati riječ", "normalized": "odrzati rijec", "pos": "phrase", "ua": "дотримати слова", "vtype": "chunk", "forms": {}, "examples": ["Uvijek održim riječ."]}, {"lemma": "zauzvrat", "normalized": "zauzvrat", "pos": "adverb", "ua": "натомість, у відповідь", "vtype": "core", "forms": {}, "examples": ["Pomoći ću ti, a ti mi zauzvrat pričuvaj psa."]}, {"lemma": "pošteno", "normalized": "posteno", "pos": "adverb", "ua": "чесно, справедливо", "vtype": "core", "forms": {}, "examples": ["To je pošteno za sve."]}, {"lemma": "dogovor je dogovor", "normalized": "dogovor je dogovor", "pos": "phrase", "ua": "домовленість є домовленість", "vtype": "chunk", "forms": {}, "examples": ["Dogovor je dogovor, ne mijenjamo."]}, {"lemma": "posljedica", "normalized": "posljedica", "pos": "noun", "ua": "наслідок", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Ako ne učiš, posljedica je loša ocjena."]}, {"lemma": "pričuvati", "normalized": "pricuvati", "pos": "verb", "ua": "доглянути, наглянути (недовго)", "vtype": "core", "forms": {"aspect": "pfv", "pair": "čuvati"}, "examples": ["Možeš li mi pričuvati djecu sat vremena?"]}, {"lemma": "kako bude", "normalized": "kako bude", "pos": "phrase", "ua": "як буде", "vtype": "chunk", "forms": {}, "examples": ["Vidjet ćemo kako bude."]}, {"lemma": "ako se išta promijeni", "normalized": "ako se ista promijeni", "pos": "phrase", "ua": "якщо щось зміниться", "vtype": "chunk", "forms": {}, "examples": ["Ako se išta promijeni, javi mi."]}, {"lemma": "prihvatiti uvjete", "normalized": "prihvatiti uvjete", "pos": "phrase", "ua": "прийняти умови", "vtype": "chunk", "forms": {}, "examples": ["Prihvatila sam uvjete ugovora."]}, {"lemma": "nagodba", "normalized": "nagodba", "pos": "noun", "ua": "угода, компроміс", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Postigli smo nagodbu."]}, {"lemma": "organizirati", "normalized": "organizirati", "pos": "verb", "ua": "організувати", "vtype": "core", "forms": {"aspect": "biasp"}, "examples": ["Organiziram rođendan za Dašu."]}, {"lemma": "popis gostiju", "normalized": "popis gostiju", "pos": "phrase", "ua": "список гостей", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Na popisu gostiju je dvadeset ljudi."]}, {"lemma": "proslava", "normalized": "proslava", "pos": "noun", "ua": "святкування", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Proslava je u subotu u osam."]}, {"lemma": "podijeliti troškove", "normalized": "podijeliti troskove", "pos": "phrase", "ua": "поділити витрати", "vtype": "chunk", "forms": {}, "examples": ["Troškove ćemo podijeliti na pola."]}, {"lemma": "iznajmiti prostor", "normalized": "iznajmiti prostor", "pos": "phrase", "ua": "орендувати приміщення", "vtype": "chunk", "forms": {}, "examples": ["Iznajmili smo prostor u kafiću."]}, {"lemma": "grupni chat", "normalized": "grupni chat", "pos": "phrase", "ua": "груповий чат", "vtype": "chunk", "forms": {"gender": "m"}, "examples": ["Sve detalje pišem u grupni chat."]}, {"lemma": "anketa", "normalized": "anketa", "pos": "noun", "ua": "опитування", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Napravila sam anketu za datum."]}, {"lemma": "većina", "normalized": "vecina", "pos": "noun", "ua": "більшість", "vtype": "core", "forms": {"gender": "f"}, "examples": ["Većini odgovara subota."]}, {"lemma": "glasati", "normalized": "glasati", "pos": "verb", "ua": "голосувати", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Glasajte do petka!"]}, {"lemma": "rođendanska torta", "normalized": "rodendanska torta", "pos": "phrase", "ua": "святковий торт (на день народження)", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Rođendansku tortu radi Darja."]}, {"lemma": "ukrasi", "normalized": "ukrasi", "pos": "noun", "ua": "прикраси", "vtype": "core", "forms": {"gender": "m_pl"}, "examples": ["Darja će donijeti ukrase."]}, {"lemma": "baloni", "normalized": "baloni", "pos": "noun", "ua": "повітряні кульки", "vtype": "core", "forms": {"gender": "m_pl"}, "examples": ["Djeca su napuhala balone."]}, {"lemma": "društvene igre", "normalized": "drustvene igre", "pos": "phrase", "ua": "настільні ігри", "vtype": "chunk", "forms": {"gender": "f_pl"}, "examples": ["Navečer igramo društvene igre."]}, {"lemma": "raspremiti", "normalized": "raspremiti", "pos": "verb", "ua": "прибрати (після свята)", "vtype": "core", "forms": {"aspect": "pfv", "pair": "raspremati"}, "examples": ["Tko će raspremiti nakon zabave?"]}, {"lemma": "dobro raspoloženje", "normalized": "dobro raspolozenje", "pos": "phrase", "ua": "гарний настрій", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Najvažnije je dobro raspoloženje."]}, {"lemma": "na otvorenom", "normalized": "na otvorenom", "pos": "phrase", "ua": "просто неба", "vtype": "chunk", "forms": {}, "examples": ["Ako bude toplo, druženje je na otvorenom."]}, {"lemma": "zabavljati se", "normalized": "zabavljati se", "pos": "verb", "ua": "розважатися", "vtype": "core", "forms": {"aspect": "ipfv"}, "examples": ["Djeca su se zabavljala cijelu večer."]}, {"lemma": "glazbena lista", "normalized": "glazbena lista", "pos": "phrase", "ua": "плейлист, добірка музики", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Marko je složio glazbenu listu za zabavu."]}, {"lemma": "zabava iznenađenja", "normalized": "zabava iznenadenja", "pos": "phrase", "ua": "вечірка-сюрприз", "vtype": "chunk", "forms": {"gender": "f"}, "examples": ["Spremamo zabavu iznenađenja za Dašu."]}, {"lemma": "piće za sve", "normalized": "pice za sve", "pos": "phrase", "ua": "напої для всіх", "vtype": "chunk", "forms": {"gender": "n"}, "examples": ["Ivan donosi piće za sve."]}]'::jsonb)
    as t(lemma text, normalized text, pos text, ua text, vtype text, forms jsonb, examples jsonb)
 where not exists (select 1 from public.lexemes x where lower(x.lemma) = lower(t.lemma))
on conflict do nothing;

-- 2. Уроки модуля A2.13
-- A2.13 · урок 78: Мої цілі на рік — 21 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '55b7d23a-2c46-5ea6-bd0c-df533308d66e';
  v_lesson constant uuid := 'f2760130-fd69-5932-978c-cc424aaefafa';
  v_gid constant uuid := '17b75bc6-fca0-5f09-830c-ab7f37279022';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики FUT'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 1) then
    raise exception 'A2.13: місце 1 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 78: Мої цілі на рік', 'Lekcija 78: Moji ciljevi za ovu godinu', '["Розповісти про цілі на рік і як їх досягти", "Futur I доконаного виду: naučit ću, položit ću, uštedjet ću"]'::jsonb, 20, 'PUBLISHED', 1);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'postaviti cilj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ostvariti cilj', v_pos);
  v_pos := pg_temp.word(v_lesson, 'novogodišnja odluka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dugoročni plan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kratkoročni', v_pos);
  v_pos := pg_temp.word(v_lesson, 'uštedjeti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'štedjeti za', v_pos);
  v_pos := pg_temp.word(v_lesson, 'motivacija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ustrajnost', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zacrtati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ispuniti obećanje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'do kraja godine', v_pos);
  v_pos := pg_temp.word(v_lesson, 'štednja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odustati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'certifikat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dobiti povišicu', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vozački za motor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vrijedno raditi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vidjet ćemo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'planer', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lista ciljeva', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '5eb1b29e-6d23-570f-984c-08b70a111127', 'fill_in_the_blank', 'Do ljeta ___ uštedjeti za more.', 'ću', '["sam", "budem", "bih", "ću"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '40f9d55a-c626-5658-84e5-b8c93e901b71', 'multiple_choice', 'Що означає «vozački za motor»?', 'права на мотоцикл', '["відмовитися (від мети), здатися", "старанно працювати", "досягти мети", "права на мотоцикл"]'::jsonb, 'A2', 2, 'PUBLISHED', 'vozački za motor', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e1b30636-5f62-5b62-97f6-ffc8be3bbe62', 'multiple_choice', 'Що означає «štedjeti za»?', 'відкладати гроші на', '["відмовитися (від мети), здатися", "відкладати гроші на", "виконати обіцянку", "заощадити"]'::jsonb, 'A2', 3, 'PUBLISHED', 'štedjeti za', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5cf596bb-68bf-5fb9-bb2a-c6b745549606', 'multiple_choice', 'Що означає «planer»?', 'планер, щоденник планів', '["відмовитися (від мети), здатися", "побачимо", "планер, щоденник планів", "отримати підвищення зарплати"]'::jsonb, 'A2', 4, 'PUBLISHED', 'planer', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '940636ed-120f-5175-88f1-75402e82d6d7', 'multiple_choice', 'Як хорватською «накреслити, запланувати»?', 'zacrtati', '["odustati", "štedjeti za", "zacrtati", "certifikat"]'::jsonb, 'A2', 5, 'PUBLISHED', 'zacrtati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8e67bb53-0b3e-51b4-9c71-f2db5a3a594a', 'multiple_choice', 'Як хорватською «старанно працювати»?', 'vrijedno raditi', '["certifikat", "zacrtati", "štedjeti za", "vrijedno raditi"]'::jsonb, 'A2', 6, 'PUBLISHED', 'vrijedno raditi', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6d9bec0a-28de-5040-98ac-ab9e7c5e8105', 'type_answer', 'Напишіть хорватською: «заощадження»', 'štednja', null, 'A2', 7, 'PUBLISHED', 'štednja', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8fcbc935-e168-56c2-8ef9-1b9148e63899', 'type_answer', 'Напишіть хорватською: «мотивація»', 'motivacija', null, 'A2', 8, 'PUBLISHED', 'motivacija', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6cf982e1-8aca-557e-9211-4195e7e57eaf', 'type_answer', 'Напишіть хорватською: «досягти мети»', 'ostvariti cilj', null, 'A2', 9, 'PUBLISHED', 'ostvariti cilj', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1c7f5357-7081-53aa-923c-5d15543d8e29', 'sentence_builder', 'Складіть: «Цього року я складу іспит B1.»', 'Ove godine položit ću ispit B1.', '["godine", "ću", "B1.", "položit", "ispit", "Ove"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b7baad1b-0919-5d1c-a92f-9b181984801c', 'sentence_builder', 'Складіть: «Не здавайся в лютому!»', 'Nemoj odustati u veljači!', '["veljači!", "Nemoj", "odustati", "u"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '02078ecd-b72c-596e-baa5-8749a26fee3b', 'listening', 'Прослухайте і складіть фразу', 'Svaki dan po pola sata. Napredak pratim u bilježnici.', '["pola", "sata.", "u", "po", "dan", "pratim", "Napredak", "bilježnici.", "Svaki"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '47080256-768c-5640-a15f-b0db172fcbd8', 'listening_dialogue', 'Прослухайте голосове повідомлення', 'італійську; 4; в Італію', 'A2', 'PUBLISHED', '{"kind": "voicemail", "situation_ua": "Даша надіслала вам голосове з планами.", "script": [{"hr": "Bok! Odlučila sam: ove godine upisujem tečaj talijanskog.", "ua": "Привіт! Я вирішила: цього року записуюся на курс італійської."}, {"hr": "Tečaj počinje u ožujku i traje četiri mjeseca.", "ua": "Курс починається в березні й триває чотири місяці."}, {"hr": "Uštedjet ću za ljeto u Italiji. Ideš sa mnom?", "ua": "Заощаджу на літо в Італії. Поїдеш зі мною?"}], "questions": [{"q_ua": "Яку мову вчитиме Даша?", "options": ["італійську", "англійську", "німецьку"], "correct": 0, "answer_turn": 0}, {"q_ua": "Скільки місяців триває курс?", "answer_text": "4", "accept": ["чотири", "4 місяці"], "answer_turn": 1}, {"q_ua": "Куди Даша хоче влітку?", "options": ["до Хорватії", "в Італію", "в Україну"], "correct": 1, "answer_turn": 2}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '47080256-768c-5640-a15f-b0db172fcbd8', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '34b60af3-4061-5171-b606-e0e8a14c7707', 'speaking', 'Моя мета — поміняти роботу.', 'Moj cilj je promijeniti posao.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ee1131d5-b857-57ef-9cc9-7d7a5bf5b835', 'speaking', 'Ми відкладаємо гроші на новий автомобіль.', 'Štedimo za novi auto.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '907c3e4e-7522-5f9b-af4f-1e75593fe75c', 'write_message', 'Напишіть подрузі три свої цілі на рік (майбутній час).', 'Ove godine imam tri cilja: položit ću ispit B1, uštedjet ću za more i naći ću novi posao do kraja godine.', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть подрузі три свої цілі на рік (майбутній час).", "points": [{"ua": "мета 1", "keys": [["ću"]]}, {"ua": "цілі", "keys": [["cilj"], ["ću"]]}, {"ua": "до кінця року", "keys": [["godin"]]}], "hints": ["ove godine", "položit ću", "uštedjet ću", "naći ću novi posao"], "models": ["Ove godine imam tri cilja: položit ću ispit B1, uštedjet ću za more i naći ću novi posao do kraja godine."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '907c3e4e-7522-5f9b-af4f-1e75593fe75c', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'ea60f5db-5783-56ec-ac0d-5600a3840aa7', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'I ona želi učiti talijanski i ići će s tobom.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи Даші, що я теж хочу вчити італійську і поїду з нею.", "direction": "ua_hr", "points": [{"ua": "вчити італійську", "keys": [["talijansk"]]}, {"ua": "поїде з нею", "keys": [["s tobom"], ["ići"]]}], "hints": [], "models": ["I ona želi učiti talijanski i ići će s tobom."], "source_ua": "Скажи Даші, що я теж хочу вчити італійську і поїду з нею."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'ea60f5db-5783-56ec-ac0d-5600a3840aa7', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('c14227d5-60dd-5732-98ce-5efe391bda6f', v_lesson, 'Новорічні обіцянки', 'Novogodišnje odluke', 5781, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('0d5144f2-8b98-5d60-95fa-4ebb36a84fd5', 'c14227d5-60dd-5732-98ce-5efe391bda6f', 'Daša', 'Darja, imaš li novogodišnju odluku?', 'Дар’є, у тебе є новорічна обіцянка?', 1);
  perform pg_temp.turn('88c39f05-bdcf-539a-a815-a928c906bee7', 'c14227d5-60dd-5732-98ce-5efe391bda6f', 'Darja', 'Imam tri cilja. Položit ću ispit B1, uštedjet ću za more i promijenit ću posao.', 'У мене три цілі. Складу іспит B1, заощаджу на море й поміняю роботу.', 2);
  perform pg_temp.turn('836c5e2c-7830-55d1-9ddd-cef8a433c99c', 'c14227d5-60dd-5732-98ce-5efe391bda6f', 'Daša', 'Ambiciozno! Kako ćeš ostvariti cilj s ispitom?', 'Амбітно! Як ти досягнеш мети з іспитом?', 3);
  perform pg_temp.turn('c54442f7-bad5-54a2-a972-25a7b57b8380', 'c14227d5-60dd-5732-98ce-5efe391bda6f', 'Darja', 'Svaki dan po pola sata. Napredak pratim u bilježnici.', 'Щодня по пів години. За прогресом стежу в зошиті.', 4);
  perform pg_temp.turn('bc8f9034-3b21-55c7-8d84-8007ca756af8', 'c14227d5-60dd-5732-98ce-5efe391bda6f', 'Daša', 'Samo nemoj odustati u veljači!', 'Тільки не здайся в лютому!', 5);
  perform pg_temp.turn('855ca826-26a6-540b-8ace-81ab1623e9b1', 'c14227d5-60dd-5732-98ce-5efe391bda6f', 'Darja', 'Vidjet ćemo. Treba ustrajnosti.', 'Побачимо. Потрібна наполегливість.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('e7cb2f53-f4a0-52a4-8e93-9bab35d715a4', v_lesson, 'Довгий план', 'Dugoročni plan', 5782, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('25761b75-1f57-5da0-85f0-b4d77b97d5fa', 'e7cb2f53-f4a0-52a4-8e93-9bab35d715a4', 'Ivan', 'Što vam je dugoročni plan?', 'Який у вас довгостроковий план?', 1);
  perform pg_temp.turn('9291a1d9-bc4a-5562-ad10-6ff6914a315d', 'e7cb2f53-f4a0-52a4-8e93-9bab35d715a4', 'Marko', 'Kupiti stan. Štedimo svaki mjesec po malo.', 'Купити квартиру. Відкладаємо щомісяця потроху.', 2);
  perform pg_temp.turn('eb8cf3dc-896e-5097-9e6f-7d44671537d6', 'e7cb2f53-f4a0-52a4-8e93-9bab35d715a4', 'Ivan', 'A kratkoročni?', 'А короткостроковий?', 3);
  perform pg_temp.turn('05700701-8989-5966-a7f0-ae1c59c20c82', 'e7cb2f53-f4a0-52a4-8e93-9bab35d715a4', 'Marko', 'Do kraja godine dobit ću povišicu, nadam se. Onda ćemo brže štedjeti.', 'До кінця року я отримаю підвищення, сподіваюся. Тоді швидше відкладатимемо.', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.13 · урок 79: Якби я міг… Мрії — 20 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '55b7d23a-2c46-5ea6-bd0c-df533308d66e';
  v_lesson constant uuid := '00cd6ab0-29c4-5eab-94a4-5319d76fbce4';
  v_gid constant uuid := '0c68352a-803a-5410-a59b-91f2c1ddc49f';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики KOND'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 2) then
    raise exception 'A2.13: місце 2 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 79: Якби я міг… Мрії', 'Lekcija 79: Kad bih mogao… Snovi', '["Розповісти про мрії: Volio bih…, Da imam…, Kad bih mogla…", "Kondicional бажання й нереальної умови"]'::jsonb, 20, 'PUBLISHED', 2);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'ostvariti san', v_pos);
  v_pos := pg_temp.word(v_lesson, 'volio bih', v_pos);
  v_pos := pg_temp.word(v_lesson, 'da imam', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kad bih mogla', v_pos);
  v_pos := pg_temp.word(v_lesson, 'putovati oko svijeta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dobiti na lutriji', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jedrilica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'slikati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'svirati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'maštarija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nedostižan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'realan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zašto ne', v_pos);
  v_pos := pg_temp.word(v_lesson, 'mirno starenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vlastiti posao', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nikad ne reci nikad', v_pos);
  v_pos := pg_temp.word(v_lesson, 'jedriti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'polarna svjetlost', v_pos);
  v_pos := pg_temp.word(v_lesson, 'lutrija', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kad odrastem', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '651cad0b-2654-5488-8dbc-4061db5f13e4', 'fill_in_the_blank', 'Da imam više novca, ___ bih jedrilicu.', 'kupio', '["kupim", "kupujem", "kupiti", "kupio"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '98e0e894-7e10-5ba4-a05a-0ecb0f4b8528', 'multiple_choice', 'Що означає «volio bih»?', 'я б дуже хотів', '["я б дуже хотів", "фантазія, мрія", "подорожувати навколо світу", "якби я мав"]'::jsonb, 'A2', 2, 'PUBLISHED', 'volio bih', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a4d80bba-5b5e-596f-b64a-01243098bee9', 'multiple_choice', 'Що означає «svirati»?', 'грати (на інструменті)', '["спокійна старість", "малювати (фарбами)", "власна справа", "грати (на інструменті)"]'::jsonb, 'A2', 3, 'PUBLISHED', 'svirati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'bb613aa9-37ff-5735-aadf-a8caf654c211', 'multiple_choice', 'Що означає «kad odrastem»?', 'коли виросту', '["ніколи не кажи «ніколи»", "якби я могла", "здійснити мрію", "коли виросту"]'::jsonb, 'A2', 4, 'PUBLISHED', 'kad odrastem', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '07579e57-2575-5d8c-ae01-59ae8385ccfa', 'multiple_choice', 'Як хорватською «виграти в лотерею»?', 'dobiti na lutriji', '["dobiti na lutriji", "vlastiti posao", "nikad ne reci nikad", "volio bih"]'::jsonb, 'A2', 5, 'PUBLISHED', 'dobiti na lutriji', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fe06db7f-5613-551a-8001-d9f87dde193a', 'multiple_choice', 'Як хорватською «ніколи не кажи «ніколи»»?', 'nikad ne reci nikad', '["realan", "zašto ne", "da imam", "nikad ne reci nikad"]'::jsonb, 'A2', 6, 'PUBLISHED', 'nikad ne reci nikad', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '5fce383a-7550-5a23-aaec-c1987b03b83f', 'type_answer', 'Напишіть хорватською: «реальний»', 'realan', null, 'A2', 7, 'PUBLISHED', 'realan', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e7fab21c-bb51-563c-9047-4e58a2a8f8f5', 'type_answer', 'Напишіть хорватською: «ходити під вітрилом»', 'jedriti', null, 'A2', 8, 'PUBLISHED', 'jedriti', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6410e484-85eb-5612-9cc6-50db9445fd40', 'type_answer', 'Напишіть хорватською: «недосяжний»', 'nedostižan', null, 'A2', 9, 'PUBLISHED', 'nedostižan', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'b8c18d9c-abaf-55bd-8815-0ddb577e5eeb', 'sentence_builder', 'Складіть: «Моя мрія — жити біля моря.»', 'Moj san je živjeti uz more.', '["je", "živjeti", "san", "Moj", "more.", "uz"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ee4a1ed3-52dd-5e19-99c3-ec2d382866e6', 'sentence_builder', 'Складіть: «Якби я могла, я б подорожувала.»', 'Kad bih mogla, putovala bih.', '["Kad", "bih", "bih.", "putovala", "mogla,"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f1b734a3-a008-513f-afe4-d205e1979c20', 'listening', 'Прослухайте і складіть фразу', 'Volio bih naučiti svirati gitaru.', '["svirati", "naučiti", "gitaru.", "Volio", "bih"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'de910417-ae46-55da-8b07-7d6bac29a149', 'listening_dialogue', 'Прослухайте розмову', 'пілотом; до Києва; 3', 'A2', 'PUBLISHED', '{"kind": "dialogue", "situation_ua": "Діти Дар’ї розповідають про мрії.", "script": [{"speaker": "Darja", "hr": "Filipe, što bi volio biti kad odrasteš?", "ua": "Філіпе, ким би ти хотів бути, коли виростеш?"}, {"speaker": "Filip", "hr": "Volio bih biti pilot i letjeti u Kijev.", "ua": "Я б хотів бути пілотом і літати до Києва."}, {"speaker": "Darja", "hr": "A ti, Ana?", "ua": "А ти, Ано?"}, {"speaker": "Ana", "hr": "Ja bih imala veliku kuću sa psom i tri mačke.", "ua": "А я б мала великий будинок із собакою і трьома котами."}], "questions": [{"q_ua": "Ким хоче бути Філіп?", "options": ["пілотом", "лікарем", "вчителем"], "correct": 0, "answer_turn": 1}, {"q_ua": "Куди він хоче літати?", "options": ["до Загреба", "до Києва", "до Лондона"], "correct": 1, "answer_turn": 1}, {"q_ua": "Скільки котів хоче Ана?", "answer_text": "3", "accept": ["три", "трьох"], "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'de910417-ae46-55da-8b07-7d6bac29a149', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '1a53eea1-0fa0-5b6a-8894-94a46d06e310', 'speaking', 'Що б ти зробив, якби виграв у лотерею?', 'Što bi napravio da dobiješ na lutriji?', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2e32dab2-2541-5344-b2ef-0ed6d55c82b0', 'speaking', 'Я б дуже хотіла побачити північне сяйво.', 'Voljela bih vidjeti polarnu svjetlost.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '596db53a-a8aa-59c7-b0c6-ce4029d75be6', 'write_message', 'Напишіть, що б ви зробили, якби мали рік вільного часу й достатньо грошей.', 'Da imam godinu dana slobodno, putovala bih po Južnoj Americi i naučila bih španjolski.', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть, що б ви зробили, якби мали рік вільного часу й достатньо грошей.", "points": [{"ua": "якби", "keys": [["da imam"], ["kad bih"]]}, {"ua": "кондиціонал", "keys": [["bih"]]}], "hints": ["da imam godinu dana", "putovala bih", "naučila bih", "otvorila bih"], "models": ["Da imam godinu dana slobodno, putovala bih po Južnoj Americi i naučila bih španjolski."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '596db53a-a8aa-59c7-b0c6-ce4029d75be6', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '5035b0fd-194f-5736-92ce-6f7f00e2a9ab', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'I ona bi voljela naučiti svirati gitaru zajedno s tobom.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи Марку, що я б теж хотіла навчитися грати на гітарі разом з ним.", "direction": "ua_hr", "points": [{"ua": "теж хотіла б", "keys": [["voljela"], ["htjela"]]}, {"ua": "грати на гітарі", "keys": [["gitar"]]}, {"ua": "разом", "keys": [["zajedno"], ["s tobom"]]}], "hints": [], "models": ["I ona bi voljela naučiti svirati gitaru zajedno s tobom."], "source_ua": "Скажи Марку, що я б теж хотіла навчитися грати на гітарі разом з ним."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '5035b0fd-194f-5736-92ce-6f7f00e2a9ab', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('498f35b5-b010-5867-b048-8af671d19fa7', v_lesson, 'Якби ти виграла в лотерею', 'Da dobiješ na lutriji', 5791, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('8c29ffd3-5e14-577c-9886-2ad3c5db6b9d', '498f35b5-b010-5867-b048-8af671d19fa7', 'Ivan', 'Darja, što bi napravila da dobiješ na lutriji?', 'Дар’є, що б ти зробила, якби виграла в лотерею?', 1);
  perform pg_temp.turn('fd4935c5-2f5c-5966-9aec-bbdb8da84aef', '498f35b5-b010-5867-b048-8af671d19fa7', 'Darja', 'Kupila bih vikendicu na otoku i putovala bih oko svijeta.', 'Я б купила будиночок на острові й подорожувала б навколо світу.', 2);
  perform pg_temp.turn('08ab7c81-3ff3-5097-bb15-504212211c07', '498f35b5-b010-5867-b048-8af671d19fa7', 'Ivan', 'A posao?', 'А робота?', 3);
  perform pg_temp.turn('a020f054-7d75-5829-b378-848490bd2966', '498f35b5-b010-5867-b048-8af671d19fa7', 'Darja', 'Otvorila bih vlastiti posao, malu galeriju. Slikala bih more.', 'Я б відкрила власну справу, маленьку галерею. Малювала б море.', 4);
  perform pg_temp.turn('83c0280b-7b14-580a-8f6a-3d76d083c344', '498f35b5-b010-5867-b048-8af671d19fa7', 'Ivan', 'Lijepa maštarija!', 'Гарна фантазія!', 5);
  perform pg_temp.turn('5e5bc9b6-55ee-52df-99b3-1f9733d69d3a', '498f35b5-b010-5867-b048-8af671d19fa7', 'Darja', 'Nikad ne reci nikad!', 'Ніколи не кажи «ніколи»!', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('70479b5b-f4f2-5c02-8ba6-635e62b6b351', v_lesson, 'Реальна мрія', 'Realan san', 5792, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('16839b39-b7b6-5152-bd8e-29a7c30b36f8', '70479b5b-f4f2-5c02-8ba6-635e62b6b351', 'Daša', 'Marko, imaš li neki san koji je realan?', 'Марку, у тебе є якась реальна мрія?', 1);
  perform pg_temp.turn('f0f23956-f41d-58d4-9bae-233677b4f6e7', '70479b5b-f4f2-5c02-8ba6-635e62b6b351', 'Marko', 'Volio bih naučiti svirati gitaru.', 'Я б дуже хотів навчитися грати на гітарі.', 2);
  perform pg_temp.turn('6b6b2434-ef7e-5f07-8a57-15d2a5672a65', '70479b5b-f4f2-5c02-8ba6-635e62b6b351', 'Daša', 'Pa zašto ne? To nije nedostižno.', 'То чому б і ні? Це не недосяжно.', 3);
  perform pg_temp.turn('f2f9783e-fa57-5496-9922-0b8ff2cc7651', '70479b5b-f4f2-5c02-8ba6-635e62b6b351', 'Marko', 'Da imam više vremena, već bih svirao.', 'Якби я мав більше часу, я б уже грав.', 4);
  perform pg_temp.turn('ab30e0bd-5d1f-572e-9d5f-c550401ab684', '70479b5b-f4f2-5c02-8ba6-635e62b6b351', 'Daša', 'Kad bi svirao pola sata dnevno, za godinu bi svirao odlično.', 'Якби ти грав пів години на день, через рік грав би чудово.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.13 · урок 80: Переносимо й скасовуємо зустріч — 20 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '55b7d23a-2c46-5ea6-bd0c-df533308d66e';
  v_lesson constant uuid := '0b054356-d4b4-5f6e-b7e9-3dc8f3c9d4ff';
  v_gid constant uuid := '17b75bc6-fca0-5f09-830c-ab7f37279022';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики FUT'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 3) then
    raise exception 'A2.13: місце 3 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 80: Переносимо й скасовуємо зустріч', 'Lekcija 80: Pomičemo i otkazujemo dogovor', '["Перенести чи скасувати зустріч і запропонувати інший час", "Майбутній час: javit ću ti, vidjet ćemo se, nazvat ću"]'::jsonb, 20, 'PUBLISHED', 3);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'iskrsnulo mi je nešto', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pomaknuti dogovor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'otkazati sastanak', v_pos);
  v_pos := pg_temp.word(v_lesson, 'premjestiti termin', v_pos);
  v_pos := pg_temp.word(v_lesson, 'novi termin', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odgovara li ti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ne stižem', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kasnit ću', v_pos);
  v_pos := pg_temp.word(v_lesson, 'javit ću ti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'vidimo se onda', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ispričavam se zbog otkazivanja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'u zadnji čas', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dogovorimo se za', v_pos);
  v_pos := pg_temp.word(v_lesson, 'potvrdi mi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nema problema', v_pos);
  v_pos := pg_temp.word(v_lesson, 'veseliti se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'susret', v_pos);
  v_pos := pg_temp.word(v_lesson, 'raspored mi je pun', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odgađati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'promjena plana', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '14eef8b5-9c9b-5bac-a44e-5d66ab40a712', 'fill_in_the_blank', 'Ne znam još, ___ ti se sutra.', 'javit ću', '["javila sam", "javit ću", "javit bih", "javim ću"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd385e5a4-6d5c-58ad-82e0-0f78eb5e1afd', 'multiple_choice', 'Що означає «otkazati sastanak»?', 'скасувати зустріч', '["я не встигаю", "я запізнюся", "скасувати зустріч", "домовмося на"]'::jsonb, 'A2', 2, 'PUBLISHED', 'otkazati sastanak', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7aa30de9-06dc-5781-a934-5242b69a9951', 'multiple_choice', 'Що означає «iskrsnulo mi je nešto»?', 'у мене дещо непередбачене', '["тобі підходить?", "в останню хвилину", "у мене дещо непередбачене", "тоді побачимося"]'::jsonb, 'A2', 3, 'PUBLISHED', 'iskrsnulo mi je nešto', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4c2d39a6-f1d6-5d6a-a665-b5729f712dbd', 'multiple_choice', 'Що означає «premjestiti termin»?', 'перенести час (запису)', '["перенести час (запису)", "я запізнюся", "зміна плану", "зустріч"]'::jsonb, 'A2', 4, 'PUBLISHED', 'premjestiti termin', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '00de14f5-96ea-51a2-909a-31148415edd2', 'multiple_choice', 'Як хорватською «в останню хвилину»?', 'u zadnji čas', '["pomaknuti dogovor", "kasnit ću", "odgađati", "u zadnji čas"]'::jsonb, 'A2', 5, 'PUBLISHED', 'u zadnji čas', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd425c122-878e-5f69-a4b4-beb5935c6cc8', 'multiple_choice', 'Як хорватською «без проблем»?', 'nema problema', '["potvrdi mi", "susret", "nema problema", "odgovara li ti"]'::jsonb, 'A2', 6, 'PUBLISHED', 'nema problema', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9f68bb91-cf7a-55e1-9b91-e20b0816a95c', 'type_answer', 'Напишіть хорватською: «підтверди мені»', 'potvrdi mi', null, 'A2', 7, 'PUBLISHED', 'potvrdi mi', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6aa88fdf-9762-5f6a-bc5e-25386be5a304', 'type_answer', 'Напишіть хорватською: «я запізнюся»', 'kasnit ću', null, 'A2', 8, 'PUBLISHED', 'kasnit ću', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2ab2ed98-0136-58d3-a0ff-bc3443d3e927', 'type_answer', 'Напишіть хорватською: «я не встигаю»', 'ne stižem', null, 'A2', 9, 'PUBLISHED', 'ne stižem', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'ea44a71b-0d81-5e18-9265-d29e420665b9', 'sentence_builder', 'Складіть: «Можемо перенести зустріч на п’ятницю?»', 'Možemo li pomaknuti dogovor na petak?', '["li", "dogovor", "petak?", "pomaknuti", "Možemo", "na"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e16444b2-8e58-5e89-b23f-a4d4fbaec4a6', 'sentence_builder', 'Складіть: «Він скасував в останню хвилину.»', 'Otkazao je u zadnji čas.', '["Otkazao", "zadnji", "u", "je", "čas."]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7c233033-db19-591c-82b7-71aff3ee7c00', 'listening', 'Прослухайте і складіть фразу', 'Odgovara. Šteta za danas, ali nadoknadit ćemo.', '["Šteta", "Odgovara.", "ali", "nadoknadit", "ćemo.", "danas,", "za"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '535b1d7b-de20-5609-ad7a-04d48a613d71', 'listening_dialogue', 'Прослухайте голосове повідомлення', 'на четвер; 10.30; у малій залі', 'A2', 'PUBLISHED', '{"kind": "voicemail", "situation_ua": "Колега залишив вам повідомлення про зустріч.", "script": [{"hr": "Bok Darja, ovdje Tomislav.", "ua": "Привіт, Дар’є, це Томіслав."}, {"hr": "Sastanak s klijentom je pomaknut s utorka na četvrtak.", "ua": "Зустріч із клієнтом перенесли з вівторка на четвер."}, {"hr": "Počinje u deset i trideset, u maloj sali.", "ua": "Починається о десятій тридцять, у малій залі."}, {"hr": "Potvrdi mi do sutra, molim te.", "ua": "Підтверди мені до завтра, будь ласка."}], "questions": [{"q_ua": "На який день перенесли зустріч?", "options": ["на четвер", "на вівторок", "на п’ятницю"], "correct": 0, "answer_turn": 1}, {"q_ua": "О котрій зустріч?", "answer_text": "10.30", "accept": ["10:30", "10,30", "пів на одинадцяту"], "answer_turn": 2}, {"q_ua": "Де зустріч?", "options": ["у великій залі", "у малій залі", "у кафе"], "correct": 1, "answer_turn": 2}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '535b1d7b-de20-5609-ad7a-04d48a613d71', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2e84f39c-f56c-55f2-8b3c-79ea0b33ad5e', 'speaking', 'Вибач, у мене дещо непередбачене.', 'Oprosti, iskrsnulo mi je nešto.', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f9aa5e02-6193-5bb5-9ec2-90d1c98438f8', 'speaking', 'Тобі підходить у четвер?', 'Odgovara li ti u četvrtak?', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '87ec4c8d-12dc-5a74-b082-db77ad53c0c4', 'write_message', 'Напишіть подрузі: вибачтеся, ви не встигаєте на зустріч сьогодні, і запропонуйте суботу.', 'Oprosti, iskrsnulo mi je nešto i ne stižem danas. Može u subotu?', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть подрузі: вибачтеся, ви не встигаєте на зустріч сьогодні, і запропонуйте суботу.", "points": [{"ua": "вибачення", "keys": [["oprosti"], ["ispričav"]]}, {"ua": "не встигаєте", "keys": [["ne stižem"], ["ne mogu"]]}, {"ua": "субота", "keys": [["subot"]]}], "hints": ["oprosti", "iskrsnulo mi je nešto", "ne stižem danas", "može u subotu?"], "models": ["Oprosti, iskrsnulo mi je nešto i ne stižem danas. Može u subotu?"]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '87ec4c8d-12dc-5a74-b082-db77ad53c0c4', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'bb43dda7-e0cd-593c-8ce9-dee8d47c586f', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Kasnit će deset minuta jer autobus nije došao.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи медсестрі, що я запізнюся на десять хвилин, бо автобус не прийшов.", "direction": "ua_hr", "points": [{"ua": "запізниться", "keys": [["kasn"]]}, {"ua": "десять хвилин", "keys": [["deset"]]}, {"ua": "автобус", "keys": [["autobus"]]}], "hints": [], "models": ["Kasnit će deset minuta jer autobus nije došao."], "source_ua": "Скажи медсестрі, що я запізнюся на десять хвилин, бо автобус не прийшов."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'bb43dda7-e0cd-593c-8ce9-dee8d47c586f', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('98708d7a-575a-54cc-b052-79fa25890dd4', v_lesson, 'Переносимо каву', 'Pomičemo kavu', 5801, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('fed52d78-8a5a-5ab9-8269-ce236d2f368b', '98708d7a-575a-54cc-b052-79fa25890dd4', 'Daša', 'Darja, oprosti, iskrsnulo mi je nešto na poslu. Ne stižem danas na kavu.', 'Дар’є, вибач, у мене дещо непередбачене на роботі. Не встигаю сьогодні на каву.', 1);
  perform pg_temp.turn('570de0f3-437a-5840-b008-545ac288645a', '98708d7a-575a-54cc-b052-79fa25890dd4', 'Darja', 'Nema problema. Možemo li pomaknuti dogovor?', 'Без проблем. Можемо перенести зустріч?', 2);
  perform pg_temp.turn('297c02fb-3372-5143-8ea3-20749c7f616a', '98708d7a-575a-54cc-b052-79fa25890dd4', 'Daša', 'Odgovara li ti u četvrtak u pet?', 'Тобі підходить у четвер о п’ятій?', 3);
  perform pg_temp.turn('02d806d9-0760-535b-b36a-45359b62d842', '98708d7a-575a-54cc-b052-79fa25890dd4', 'Darja', 'Odgovara. Šteta za danas, ali nadoknadit ćemo.', 'Підходить. Шкода, що не сьогодні, але надолужимо.', 4);
  perform pg_temp.turn('1de777f4-732e-566a-8f62-bfb8cf611f9d', '98708d7a-575a-54cc-b052-79fa25890dd4', 'Daša', 'Hvala! Vidimo se onda u četvrtak.', 'Дякую! Тоді побачимося в четвер.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('6c4768c0-e6c4-5ac0-b4d3-953f655a0cb4', v_lesson, 'Скасування в лікаря', 'Otkazivanje termina', 5802, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('92e0bf7e-a1ef-5d58-a817-c324456bf50b', '6c4768c0-e6c4-5ac0-b4d3-953f655a0cb4', 'Ivan', 'Dobar dan, moram otkazati termin za sutra. Bolestan sam.', 'Добрий день, мушу скасувати запис на завтра. Я хворий.', 1);
  perform pg_temp.turn('5ef2a671-a1ee-5fd3-88c0-f15b7308345a', '6c4768c0-e6c4-5ac0-b4d3-953f655a0cb4', 'Sestra', 'U redu. Želite li novi termin?', 'Гаразд. Бажаєте новий час?', 2);
  perform pg_temp.turn('a9e8e36f-5d81-5604-bcc9-8c18d43645f7', '6c4768c0-e6c4-5ac0-b4d3-953f655a0cb4', 'Ivan', 'Želim. Ispričavam se zbog otkazivanja u zadnji čas.', 'Так. Перепрошую за скасування в останню хвилину.', 3);
  perform pg_temp.turn('13f64857-2720-5e82-990e-928c16ce781e', '6c4768c0-e6c4-5ac0-b4d3-953f655a0cb4', 'Sestra', 'Nema problema. Može idući ponedjeljak u devet?', 'Без проблем. Можна наступного понеділка о дев’ятій?', 4);
  perform pg_temp.turn('dd661c29-bc4d-5fc3-9270-07347a6ce2a0', '6c4768c0-e6c4-5ac0-b4d3-953f655a0cb4', 'Ivan', 'Može. Javit ću Vam ako se nešto promijeni.', 'Можна. Я вам повідомлю, якщо щось зміниться.', 5);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.13 · урок 81: Можна чи не можна? Дозволи й обов’язки — 20 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '55b7d23a-2c46-5ea6-bd0c-df533308d66e';
  v_lesson constant uuid := 'b8615bf1-2cc2-5cc1-b89a-ed065a4b9c28';
  v_gid constant uuid := '0c68352a-803a-5410-a59b-91f2c1ddc49f';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики KOND'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 4) then
    raise exception 'A2.13: місце 4 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 81: Можна чи не можна? Дозволи й обов’язки', 'Lekcija 81: Smije li se? Dozvole i obveze', '["Запитати дозволу й пояснити обов’язки", "Ввічливо: Bi li bilo moguće…? Smjela bih…? Morali biste…"]'::jsonb, 20, 'PUBLISHED', 4);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'dopuštenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zatražiti dopuštenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'bi li bilo moguće', v_pos);
  v_pos := pg_temp.word(v_lesson, 'smjela bih', v_pos);
  v_pos := pg_temp.word(v_lesson, 'morali biste', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dužnost', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obvezan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'preporučeno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'strogo zabranjeno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'iznimka', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pravila kuće', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pridržavati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kršiti pravila', v_pos);
  v_pos := pg_temp.word(v_lesson, 'imati pravo na', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ne bi trebalo', v_pos);
  v_pos := pg_temp.word(v_lesson, 'odobrenje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'na vlastitu odgovornost', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ulaz zabranjen', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zabrana', v_pos);
  v_pos := pg_temp.word(v_lesson, 'propis', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '6c9654e1-c01d-5c94-8a59-e9ccfde352d0', 'fill_in_the_blank', '___ li bilo moguće doći u subotu?', 'Bi', '["Bih", "Bi", "Biste", "Bismo"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '73e731f9-df7b-5bea-a29f-288973903f31', 'multiple_choice', 'Що означає «dopuštenje»?', 'дозвіл', '["чи можна мені (ввічливо)", "дозвіл", "не слід було б", "обов’язок"]'::jsonb, 'A2', 2, 'PUBLISHED', 'dopuštenje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd3a1748e-8f82-595f-9667-0a0242251e9a', 'multiple_choice', 'Що означає «kršiti pravila»?', 'порушувати правила', '["порушувати правила", "дотримуватися", "суворо заборонено", "виняток"]'::jsonb, 'A2', 3, 'PUBLISHED', 'kršiti pravila', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '83041586-f9b8-5d35-859a-841e50634ce0', 'multiple_choice', 'Що означає «imati pravo na»?', 'мати право на', '["порушувати правила", "обов’язок", "вам довелося б", "мати право на"]'::jsonb, 'A2', 4, 'PUBLISHED', 'imati pravo na', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'cb98ab2c-1a08-5d85-beb8-1d531b0ea72a', 'multiple_choice', 'Що означає «zatražiti dopuštenje»?', 'попросити дозволу', '["обов’язковий", "виняток", "правила дому", "попросити дозволу"]'::jsonb, 'A2', 5, 'PUBLISHED', 'zatražiti dopuštenje', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '22fd78a6-2b41-55f1-8751-9e261e1cb989', 'multiple_choice', 'Як хорватською «норма, припис (закону)»?', 'propis', '["bi li bilo moguće", "pridržavati se", "dopuštenje", "propis"]'::jsonb, 'A2', 6, 'PUBLISHED', 'propis', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '4efca85d-a69f-59a6-86da-51e81f80d54f', 'multiple_choice', 'Як хорватською «рекомендовано»?', 'preporučeno', '["ulaz zabranjen", "iznimka", "preporučeno", "zabrana"]'::jsonb, 'A2', 7, 'PUBLISHED', 'preporučeno', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'e560a864-e71f-5ac9-89bc-29070eb6104f', 'type_answer', 'Напишіть хорватською: «дотримуватися»', 'pridržavati se', null, 'A2', 8, 'PUBLISHED', 'pridržavati se', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9c08b7d7-f4a7-55b2-b2c4-d93d31acfadb', 'type_answer', 'Напишіть хорватською: «виняток»', 'iznimka', null, 'A2', 9, 'PUBLISHED', 'iznimka', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '724e9f2a-937a-5a97-8884-46e5660b4e97', 'sentence_builder', 'Складіть: «Куріння суворо заборонено.»', 'Pušenje je strogo zabranjeno.', '["je", "Pušenje", "zabranjeno.", "strogo"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '48cdd96b-f442-5cb8-86d5-9ad3a427f276', 'sentence_builder', 'Складіть: «Ви маєте право на перерву.»', 'Imate pravo na pauzu.', '["pravo", "Imate", "pauzu.", "na"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '140276f9-4e97-574d-858c-caf437819cb3', 'listening', 'Прослухайте і складіть фразу', 'Za djecu do šest godina postoji iznimka. I molim da se pridržavate pravila.', '["do", "djecu", "postoji", "I", "da", "šest", "se", "godina", "iznimka.", "pridržavate", "molim", "pravila.", "Za"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '2d0d077e-faac-5cf1-b190-4305a712b51d', 'listening_dialogue', 'Прослухайте оголошення', 'для всіх старших 6 років; їжа й напої; 12', 'A2', 'PUBLISHED', '{"kind": "announcement", "situation_ua": "Оголошення на вході до міського басейну.", "script": [{"hr": "Dobro došli na gradski bazen.", "ua": "Ласкаво просимо до міського басейну."}, {"hr": "Kapa za plivanje je obvezna za sve starije od šest godina.", "ua": "Шапочка для плавання обов’язкова для всіх, кому більше шести років."}, {"hr": "Hrana i piće u bazenskoj dvorani strogo su zabranjeni.", "ua": "Їжа й напої в залі басейну суворо заборонені."}, {"hr": "Djeca do dvanaest godina moraju biti u pratnji odrasle osobe.", "ua": "Діти до дванадцяти років мають бути в супроводі дорослого."}], "questions": [{"q_ua": "Для кого обов’язкова шапочка?", "options": ["для всіх старших 6 років", "лише для дорослих", "для всіх"], "correct": 0, "answer_turn": 1}, {"q_ua": "Що заборонено в залі?", "options": ["фотографувати", "їжа й напої", "плавати без окулярів"], "correct": 1, "answer_turn": 2}, {"q_ua": "До скількох років діти мають бути з дорослим?", "answer_text": "12", "accept": ["дванадцяти", "12 років"], "answer_turn": 3}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '2d0d077e-faac-5cf1-b190-4305a712b51d', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'fc94dbac-d54a-54c1-b6da-58a2aa80a741', 'speaking', 'Чи можна мені відчинити вікно?', 'Bih li smjela otvoriti prozor?', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8af6592d-28a2-5c2e-a3ea-f9310f17c72e', 'speaking', 'Це не обов’язково, але рекомендовано.', 'Nije obvezno, ali je preporučeno.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'e2a790bf-7ab4-509b-af28-d3f845e8b85e', 'write_message', 'Напишіть ввічливо керівникові: чи можна було б завтра працювати з дому, бо дитина хвора.', 'Poštovani, bi li bilo moguće da sutra radim od kuće? Dijete mi je bolesno.', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть ввічливо керівникові: чи можна було б завтра працювати з дому, бо дитина хвора.", "points": [{"ua": "чи можна було б", "keys": [["bi li bilo"], ["bih li"]]}, {"ua": "з дому", "keys": [["kuć"]]}, {"ua": "дитина хвора", "keys": [["bolesn"]]}], "hints": ["bi li bilo moguće", "sutra raditi od kuće", "dijete mi je bolesno"], "models": ["Poštovani, bi li bilo moguće da sutra radim od kuće? Dijete mi je bolesno."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'e2a790bf-7ab4-509b-af28-d3f845e8b85e', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'ba7f788c-804e-5319-8a5a-5142154116d5', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Smije li njezina kći, ima pet godina, plivati bez kape?', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Спитай рятувальника, чи можна моїй доньці (5 років) плавати без шапочки.", "direction": "ua_hr", "points": [{"ua": "донька 5 років", "keys": [["pet"], ["kći"], ["kćer"]]}, {"ua": "без шапочки", "keys": [["kap"]]}, {"ua": "чи можна", "keys": [["smije"], ["može"]]}], "hints": [], "models": ["Smije li njezina kći, ima pet godina, plivati bez kape?"], "source_ua": "Спитай рятувальника, чи можна моїй доньці (5 років) плавати без шапочки."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'ba7f788c-804e-5319-8a5a-5142154116d5', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('6f4aa1e9-7b2e-5e30-9f1f-1bb1ca01a398', v_lesson, 'Чи можна раніше?', 'Može li ranije?', 5811, 'A2', 'basics', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('52f3f2d7-b462-5423-b560-9c24c66942c1', '6f4aa1e9-7b2e-5e30-9f1f-1bb1ca01a398', 'Darja', 'Šefe, bi li bilo moguće da sutra odem sat ranije?', 'Шефе, чи можна було б, щоб я завтра пішла на годину раніше?', 1);
  perform pg_temp.turn('1d200898-ca1a-5f0d-ab5a-82e63efec1c0', '6f4aa1e9-7b2e-5e30-9f1f-1bb1ca01a398', 'Šef', 'Iznimno može. Ali tko će zaključati ured?', 'Як виняток — можна. Але хто замкне офіс?', 2);
  perform pg_temp.turn('49cd341e-1f96-5ece-905f-8ef0fec1e227', '6f4aa1e9-7b2e-5e30-9f1f-1bb1ca01a398', 'Darja', 'Daša je rekla da će ona. To je inače moja dužnost.', 'Даша сказала, що вона. Взагалі це мій обов’язок.', 3);
  perform pg_temp.turn('588e967e-af2c-5a9f-885a-3298aabd40b2', '6f4aa1e9-7b2e-5e30-9f1f-1bb1ca01a398', 'Šef', 'U redu. A sastanak u devet je obvezan.', 'Гаразд. А нарада о дев’ятій — обов’язкова.', 4);
  perform pg_temp.turn('11f75171-3eb3-5cab-9d2f-a3765bd19297', '6f4aa1e9-7b2e-5e30-9f1f-1bb1ca01a398', 'Darja', 'Naravno, bit ću tamo.', 'Звісно, я там буду.', 5);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('870a0d7d-aec9-588e-bdcc-ce4ceacdb1df', v_lesson, 'Правила в басейні', 'Pravila na bazenu', 5812, 'A2', 'basics', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('926204aa-b4e4-5884-b8e2-58426219d199', '870a0d7d-aec9-588e-bdcc-ce4ceacdb1df', 'Ivan', 'Oprostite, smijem li ući bez kape?', 'Перепрошую, мені можна зайти без шапочки?', 1);
  perform pg_temp.turn('80be9dc1-9ee7-5a20-be3b-723425d0d37c', '870a0d7d-aec9-588e-bdcc-ce4ceacdb1df', 'Spasilac', 'Ne smijete, kapa je obvezna. Morali biste je kupiti na blagajni.', 'Не можна, шапочка обов’язкова. Вам довелося б купити її в касі.', 2);
  perform pg_temp.turn('94f007c5-251f-54db-ba2f-88a993f22889', '870a0d7d-aec9-588e-bdcc-ce4ceacdb1df', 'Ivan', 'A djeca?', 'А діти?', 3);
  perform pg_temp.turn('95770aa9-671d-5465-a3d2-cf8afc26d820', '870a0d7d-aec9-588e-bdcc-ce4ceacdb1df', 'Spasilac', 'Za djecu do šest godina postoji iznimka. I molim da se pridržavate pravila.', 'Для дітей до шести років є виняток. І прошу дотримуватися правил.', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.13 · урок 82: Якщо… то: умови й домовленості — 20 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '55b7d23a-2c46-5ea6-bd0c-df533308d66e';
  v_lesson constant uuid := 'f5189d33-5f78-51d5-a1ec-5712c5c87a88';
  v_gid constant uuid := '20fd9d75-7bef-51c3-9711-f09462b61b82';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики FUT2'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 5) then
    raise exception 'A2.13: місце 5 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 82: Якщо… то: умови й домовленості', 'Lekcija 82: Ako…, onda: uvjeti i dogovori', '["Домовитися з умовами: ako, u slučaju da, pod uvjetom da", "Впізнавати futur II: Kad budem imala vremena…"]'::jsonb, 20, 'PUBLISHED', 5);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'pod uvjetom da', v_pos);
  v_pos := pg_temp.word(v_lesson, 'u slučaju da', v_pos);
  v_pos := pg_temp.word(v_lesson, 'osim ako', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ako bude', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kad budem imala vremena', v_pos);
  v_pos := pg_temp.word(v_lesson, 'čim budem znao', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dogovoreno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rezervni plan', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ovisno o', v_pos);
  v_pos := pg_temp.word(v_lesson, 'obećati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'održati riječ', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zauzvrat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pošteno', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dogovor je dogovor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'posljedica', v_pos);
  v_pos := pg_temp.word(v_lesson, 'pričuvati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'kako bude', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ako se išta promijeni', v_pos);
  v_pos := pg_temp.word(v_lesson, 'prihvatiti uvjete', v_pos);
  v_pos := pg_temp.word(v_lesson, 'nagodba', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '60858beb-4d7a-50b0-9c56-16967e10d746', 'fill_in_the_blank', 'Kad ___ imala vremena, nazvat ću te.', 'budem', '["bih", "ću", "budem", "bude"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f7b5e8d1-536d-5d3a-a7f6-9eb66b9f16fa', 'multiple_choice', 'Що означає «čim budem znao»?', 'щойно знатиму', '["наслідок", "як буде", "щойно знатиму", "коли матиму час"]'::jsonb, 'A2', 2, 'PUBLISHED', 'čim budem znao', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9ec023ef-2633-554d-84a5-9573df1300fc', 'multiple_choice', 'Що означає «kad budem imala vremena»?', 'коли матиму час', '["домовленість є домовленість", "якщо щось зміниться", "коли матиму час", "запасний план"]'::jsonb, 'A2', 3, 'PUBLISHED', 'kad budem imala vremena', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd255bd7b-bf1a-5758-9eb9-ef1d13766228', 'multiple_choice', 'Що означає «u slučaju da»?', 'у разі, якщо', '["натомість, у відповідь", "дотримати слова", "у разі, якщо", "запасний план"]'::jsonb, 'A2', 4, 'PUBLISHED', 'u slučaju da', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '08bc5d82-f0bf-5a0a-94ea-3132c43f61dd', 'multiple_choice', 'Як хорватською «дотримати слова»?', 'održati riječ', '["kad budem imala vremena", "rezervni plan", "ako bude", "održati riječ"]'::jsonb, 'A2', 5, 'PUBLISHED', 'održati riječ', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '2218e3c5-6313-5ec8-b3b9-ab47c85ad73f', 'multiple_choice', 'Як хорватською «чесно, справедливо»?', 'pošteno', '["dogovoreno", "u slučaju da", "prihvatiti uvjete", "pošteno"]'::jsonb, 'A2', 6, 'PUBLISHED', 'pošteno', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0cb173dd-44e6-5814-9b07-0f34c7b360c4', 'type_answer', 'Напишіть хорватською: «пообіцяти»', 'obećati', null, 'A2', 7, 'PUBLISHED', 'obećati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f235b9fa-7ac4-55bc-b7a3-952654bc337b', 'type_answer', 'Напишіть хорватською: «домовилися»', 'dogovoreno', null, 'A2', 8, 'PUBLISHED', 'dogovoreno', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '3abe767c-9e20-5246-aa7f-dc08ce14aa16', 'type_answer', 'Напишіть хорватською: «доглянути, наглянути (недовго)»', 'pričuvati', null, 'A2', 9, 'PUBLISHED', 'pričuvati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '46ee8c04-80ae-5227-a95e-98ee6ec0a666', 'sentence_builder', 'Складіть: «Я прийду, за умови, що не буде дощу.»', 'Doći ću, pod uvjetom da ne pada kiša.', '["pada", "da", "kiša.", "pod", "ne", "uvjetom", "Doći", "ću,"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0999dd8e-e513-5776-bfbe-667e5b1d260a', 'sentence_builder', 'Складіть: «Якщо щось зміниться, дай мені знати.»', 'Ako se išta promijeni, javi mi.', '["mi.", "promijeni,", "Ako", "išta", "javi", "se"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '6998bf8d-78d2-58a1-871e-5c3a95021f56', 'listening', 'Прослухайте і складіть фразу', 'To je pošteno. Čim budem znao raspored, javit ću ti.', '["raspored,", "ću", "pošteno.", "To", "budem", "ti.", "Čim", "javit", "znao", "je"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '32865222-fafc-59d6-9c5e-199b3f8f6bcb', 'listening_dialogue', 'Прослухайте голосове повідомлення', 'на Ярун; у Даші; соки', 'A2', 'PUBLISHED', '{"kind": "voicemail", "situation_ua": "Даша залишила повідомлення про пікнік.", "script": [{"hr": "Bok! Za nedjelju: ako bude lijepo vrijeme, idemo na piknik na Jarun.", "ua": "Привіт! Про неділю: якщо буде гарна погода, йдемо на пікнік на Ярун."}, {"hr": "U slučaju da pada kiša, nalazimo se kod mene.", "ua": "У разі, якщо буде дощ, збираємося в мене."}, {"hr": "Svatko neka donese nešto za jelo. Ja nosim sokove.", "ua": "Хай кожен принесе щось поїсти. Я несу соки."}], "questions": [{"q_ua": "Куди підуть у гарну погоду?", "options": ["на Ярун", "у кіно", "до Даші"], "correct": 0, "answer_turn": 0}, {"q_ua": "Де зустрінуться, якщо буде дощ?", "options": ["у кафе", "у Даші", "у парку"], "correct": 1, "answer_turn": 1}, {"q_ua": "Що принесе Даша?", "answer_text": "соки", "accept": ["сік", "напої", "sokove"], "answer_turn": 2}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '32865222-fafc-59d6-9c5e-199b3f8f6bcb', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a5058d55-3818-59d5-b19d-9ca325633861', 'speaking', 'Домовилися, побачимося о восьмій!', 'Dogovoreno, vidimo se u osam!', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '140faa14-e549-5901-99cb-83d73f8c8554', 'speaking', 'У разі, якщо я запізнюся, починайте без мене.', 'U slučaju da kasnim, počnite bez mene.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'abbc4a2e-0eb0-508a-baed-dc90a6609b4e', 'write_message', 'Напишіть другові: допоможете йому з переїздом у суботу, за умови, що він натомість догляне вашого кота наступного тижня.', 'Pomoći ću ti s preseljenjem u subotu, pod uvjetom da mi idući tjedan pričuvaš mačku.', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть другові: допоможете йому з переїздом у суботу, за умови, що він натомість догляне вашого кота наступного тижня.", "points": [{"ua": "допоможете з переїздом", "keys": [["preseljenj"], ["pomoći"]]}, {"ua": "за умови", "keys": [["pod uvjetom"], ["ako"]]}, {"ua": "кіт", "keys": [["mačk"], ["mač"]]}], "hints": ["pomoći ću ti s preseljenjem", "pod uvjetom da", "pričuvaš mačku", "idući tjedan"], "models": ["Pomoći ću ti s preseljenjem u subotu, pod uvjetom da mi idući tjedan pričuvaš mačku."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'abbc4a2e-0eb0-508a-baed-dc90a6609b4e', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '2db0d7cf-56b8-550d-9e72-9ffe929bccd3', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Doći će, osim ako je šef ne zadrži.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи Іванові, що я прийду, хіба що мене затримає шеф.", "direction": "ua_hr", "points": [{"ua": "прийде", "keys": [["doći"], ["dolazi"]]}, {"ua": "хіба що", "keys": [["osim ako"]]}, {"ua": "шеф", "keys": [["šef"]]}], "hints": [], "models": ["Doći će, osim ako je šef ne zadrži."], "source_ua": "Скажи Іванові, що я прийду, хіба що мене затримає шеф."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '2db0d7cf-56b8-550d-9e72-9ffe929bccd3', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('bc1803d7-3448-5b45-a4cb-1969887c3dec', v_lesson, 'Домовляємося з дітьми', 'Dogovor s djecom', 5821, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('20ae6211-95d1-5e56-bb1b-e0d568df3655', 'bc1803d7-3448-5b45-a4cb-1969887c3dec', 'Filip', 'Mama, možemo li u subotu na izlet?', 'Мамо, можна нам у суботу на екскурсію?', 1);
  perform pg_temp.turn('247ab7c0-4af7-5a2c-a607-d52d23dec478', 'bc1803d7-3448-5b45-a4cb-1969887c3dec', 'Darja', 'Možemo, pod uvjetom da napišeš zadaću u petak.', 'Можна, за умови, що ти зробиш домашнє в п’ятницю.', 2);
  perform pg_temp.turn('b6a06417-d7d8-5583-ab8c-dea7b207e475', 'bc1803d7-3448-5b45-a4cb-1969887c3dec', 'Filip', 'A ako bude padala kiša?', 'А якщо буде дощ?', 3);
  perform pg_temp.turn('12f3f82f-d828-5cb9-bd45-f8c4484a9a45', 'bc1803d7-3448-5b45-a4cb-1969887c3dec', 'Darja', 'Imamo rezervni plan: kino. Ovisno o vremenu.', 'У нас запасний план: кіно. Залежно від погоди.', 4);
  perform pg_temp.turn('b7867f1e-6e1e-5f77-87ee-53aa55657ed2', 'bc1803d7-3448-5b45-a4cb-1969887c3dec', 'Filip', 'Dogovoreno! Obećaješ?', 'Домовилися! Обіцяєш?', 5);
  perform pg_temp.turn('765ea12d-d9a2-5a33-9dcc-09d86dd7f981', 'bc1803d7-3448-5b45-a4cb-1969887c3dec', 'Darja', 'Obećajem. Dogovor je dogovor.', 'Обіцяю. Домовленість є домовленість.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('1b404be8-3c57-5c3f-b25c-99f67b8d2a57', v_lesson, 'Допомога за допомогу', 'Pomoć za pomoć', 5822, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('54960194-a225-52c5-8c9e-d75f9e63449a', '1b404be8-3c57-5c3f-b25c-99f67b8d2a57', 'Daša', 'Ivane, možeš li mi u subotu pričuvati psa?', 'Іване, можеш у суботу наглянути за моїм псом?', 1);
  perform pg_temp.turn('e0972d27-082c-5cd3-a013-74b7c0136887', '1b404be8-3c57-5c3f-b25c-99f67b8d2a57', 'Ivan', 'Mogu, osim ako me ne pozovu na posao.', 'Можу, хіба що мене не викличуть на роботу.', 2);
  perform pg_temp.turn('e4774c04-1124-51ea-8f6b-72765d39600d', '1b404be8-3c57-5c3f-b25c-99f67b8d2a57', 'Daša', 'Super. Zauzvrat ću ti pomoći s preseljenjem.', 'Супер. Натомість я допоможу тобі з переїздом.', 3);
  perform pg_temp.turn('9a729a0a-54b9-5040-af49-17557b57237b', '1b404be8-3c57-5c3f-b25c-99f67b8d2a57', 'Ivan', 'To je pošteno. Čim budem znao raspored, javit ću ti.', 'Це чесно. Щойно знатиму розклад, повідомлю тобі.', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- A2.13 · урок 83: Організуємо зустріч друзів — 20 слів, 2 діалоги, 15 вправ + письмо й переказ
do $$
declare
  v_unit constant uuid := '55b7d23a-2c46-5ea6-bd0c-df533308d66e';
  v_lesson constant uuid := '7595b9eb-8f9a-5772-8bae-259a79428d33';
  v_gid constant uuid := '17b75bc6-fca0-5f09-830c-ab7f37279022';
  v_pos int := 0;
begin
  if exists (select 1 from public.lessons where id = v_lesson) then return; end if;  -- уже створено
  if not exists (select 1 from public.grammar_topics where id = v_gid and status = 'PUBLISHED') then raise exception 'Немає теми граматики FUT'; end if;
  if exists (select 1 from public.lessons where unit_id = v_unit and order_index = 6) then
    raise exception 'A2.13: місце 6 зайняте іншим уроком';
  end if;
  insert into public.lessons (id, unit_id, level_code, title_ua, title_hr, objectives, estimated_minutes, status, order_index)
  values (v_lesson, v_unit, 'A2', 'Урок 83: Організуємо зустріч друзів', 'Lekcija 83: Organiziramo druženje s prijateljima', '["Організувати зустріч: дата, місце, хто що принесе, витрати", "Майбутній час: tko će donijeti, bit će, vidjet ćemo se"]'::jsonb, 20, 'PUBLISHED', 6);
  -- слова
  v_pos := pg_temp.word(v_lesson, 'organizirati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'popis gostiju', v_pos);
  v_pos := pg_temp.word(v_lesson, 'proslava', v_pos);
  v_pos := pg_temp.word(v_lesson, 'podijeliti troškove', v_pos);
  v_pos := pg_temp.word(v_lesson, 'iznajmiti prostor', v_pos);
  v_pos := pg_temp.word(v_lesson, 'grupni chat', v_pos);
  v_pos := pg_temp.word(v_lesson, 'anketa', v_pos);
  v_pos := pg_temp.word(v_lesson, 'većina', v_pos);
  v_pos := pg_temp.word(v_lesson, 'glasati', v_pos);
  v_pos := pg_temp.word(v_lesson, 'rođendanska torta', v_pos);
  v_pos := pg_temp.word(v_lesson, 'ukrasi', v_pos);
  v_pos := pg_temp.word(v_lesson, 'baloni', v_pos);
  v_pos := pg_temp.word(v_lesson, 'društvene igre', v_pos);
  v_pos := pg_temp.word(v_lesson, 'raspremiti', v_pos);
  v_pos := pg_temp.word(v_lesson, 'dobro raspoloženje', v_pos);
  v_pos := pg_temp.word(v_lesson, 'na otvorenom', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zabavljati se', v_pos);
  v_pos := pg_temp.word(v_lesson, 'glazbena lista', v_pos);
  v_pos := pg_temp.word(v_lesson, 'zabava iznenađenja', v_pos);
  v_pos := pg_temp.word(v_lesson, 'piće za sve', v_pos);
  -- граматика
  v_pos := v_pos + 1;
  insert into public.lesson_items (lesson_id, item_type, item_id, order_index, target_skill) values (v_lesson, 'grammar', v_gid, v_pos, 'grammar');
  insert into public.lesson_grammar (lesson_id, grammar_topic_id) values (v_lesson, v_gid) on conflict do nothing;
  -- вправи
  v_pos := pg_temp.ex(v_lesson, v_pos, '43b9d019-a204-5e0a-8354-3928161e5050', 'fill_in_the_blank', 'Tko ___ donijeti glazbu?', 'će', '["bude", "će", "je", "bi"]'::jsonb, 'A2', 1, 'PUBLISHED', null, 'grammar');
  v_pos := pg_temp.ex(v_lesson, v_pos, '8d6a4fce-27a0-5d35-b182-938565d01d39', 'multiple_choice', 'Що означає «podijeliti troškove»?', 'поділити витрати', '["святковий торт (на день народження)", "поділити витрати", "список гостей", "просто неба"]'::jsonb, 'A2', 2, 'PUBLISHED', 'podijeliti troškove', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'a8809b0c-5881-5996-bc9f-9775992a7439', 'multiple_choice', 'Що означає «proslava»?', 'святкування', '["організувати", "святковий торт (на день народження)", "святкування", "більшість"]'::jsonb, 'A2', 3, 'PUBLISHED', 'proslava', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9293d39a-f625-5fad-869c-939f812089f4', 'multiple_choice', 'Що означає «piće za sve»?', 'напої для всіх', '["вечірка-сюрприз", "прикраси", "повітряні кульки", "напої для всіх"]'::jsonb, 'A2', 4, 'PUBLISHED', 'piće za sve', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, '9e6826f2-e0f8-5ffe-9911-e82ce310679c', 'multiple_choice', 'Як хорватською «організувати»?', 'organizirati', '["piće za sve", "na otvorenom", "organizirati", "grupni chat"]'::jsonb, 'A2', 5, 'PUBLISHED', 'organizirati', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'd9ee2a1a-3481-56aa-9467-3890fb0ea870', 'multiple_choice', 'Як хорватською «прибрати (після свята)»?', 'raspremiti', '["glazbena lista", "dobro raspoloženje", "glasati", "raspremiti"]'::jsonb, 'A2', 6, 'PUBLISHED', 'raspremiti', 'vocabulary');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'f1bb45ea-4808-521c-9009-7f01dc85150c', 'type_answer', 'Напишіть хорватською: «більшість»', 'većina', null, 'A2', 7, 'PUBLISHED', 'većina', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '7d7ada43-e7fe-5735-a781-cbb4c010c2f8', 'type_answer', 'Напишіть хорватською: «повітряні кульки»', 'baloni', null, 'A2', 8, 'PUBLISHED', 'baloni', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, 'aeddff13-5d4c-5be7-8a43-657016e38608', 'type_answer', 'Напишіть хорватською: «голосувати»', 'glasati', null, 'A2', 9, 'PUBLISHED', 'glasati', 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '99386408-7c8f-591d-92bd-48e9f7d266ac', 'sentence_builder', 'Складіть: «Кожен приносить щось поїсти.»', 'Svatko donosi nešto za jelo.', '["Svatko", "nešto", "jelo.", "donosi", "za"]'::jsonb, 'A2', 10, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '0a8851fe-ac8c-5637-8fd7-f225749fafad', 'sentence_builder', 'Складіть: «Більшості підходить субота.»', 'Većini odgovara subota.', '["odgovara", "subota.", "Većini"]'::jsonb, 'A2', 11, 'PUBLISHED', null, 'writing');
  v_pos := pg_temp.ex(v_lesson, v_pos, '99f028a2-fe82-5137-8199-3d1c918007e6', 'listening', 'Прослухайте і складіть фразу', 'Ja ću donijeti društvene igre i balone.', '["i", "ću", "društvene", "balone.", "Ja", "igre", "donijeti"]'::jsonb, 'A2', 12, 'PUBLISHED', null, 'listening');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '544d27a5-4146-599a-8ad4-e931256950fc', 'listening_dialogue', 'Прослухайте голосове повідомлення', '7; торт; бо це сюрприз', 'A2', 'PUBLISHED', '{"kind": "voicemail", "situation_ua": "Дар’я залишила голосове в груповому чаті.", "script": [{"hr": "Bok svima! Druženje je u subotu u sedam, kod mene.", "ua": "Привіт усім! Зустріч у суботу о сьомій, у мене."}, {"hr": "Svatko neka donese nešto za jelo, ja radim tortu.", "ua": "Хай кожен принесе щось поїсти, я роблю торт."}, {"hr": "Pazite, to je iznenađenje za Dašu, ništa joj ne govorite!", "ua": "Обережно, це сюрприз для Даші, нічого їй не кажіть!"}], "questions": [{"q_ua": "О котрій зустріч?", "answer_text": "7", "accept": ["19", "19:00", "сьомій", "7:00"], "answer_turn": 0}, {"q_ua": "Що робить Дар’я?", "options": ["торт", "салат", "піцу"], "correct": 0, "answer_turn": 1}, {"q_ua": "Чому нічого не казати Даші?", "options": ["бо вона захворіла", "бо це сюрприз", "бо вона не прийде"], "correct": 1, "answer_turn": 2}], "max_plays": 3}'::jsonb, true, 'listening');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '544d27a5-4146-599a-8ad4-e931256950fc', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Прослухайте діалог чи оголошення» в уроці A2 (рішення власника 2026-11-12). Бета, потрібна перевірка носієм.');
  v_pos := pg_temp.ex(v_lesson, v_pos, '60b66f29-aec0-5377-911f-ae1fdb503392', 'speaking', 'Хто принесе їжу?', 'Tko će donijeti hranu?', null, 'A2', 14, 'PUBLISHED', null, 'speaking');
  v_pos := pg_temp.ex(v_lesson, v_pos, '25f20daa-c1ba-54c6-a410-fd04fa545f57', 'speaking', 'Витрати поділимо.', 'Troškove ćemo podijeliti.', null, 'A2', 15, 'PUBLISHED', null, 'speaking');
  -- письмо й переказ (необов’язкові)
  v_pos := pg_temp.ex_task(v_lesson, v_pos, 'a7df87a3-828a-54ce-8965-5edda8cb3721', 'write_message', 'Напишіть у груповий чат: зустріч у суботу о 18:00 у парку, кожен приносить щось поїсти, а витрати на напої поділимо.', 'Druženje je u subotu u 18 sati u parku. Svatko donosi nešto za jelo, a troškove za piće ćemo podijeliti.', 'A2', 'PUBLISHED', '{"situation_ua": "Напишіть у груповий чат: зустріч у суботу о 18:00 у парку, кожен приносить щось поїсти, а витрати на напої поділимо.", "points": [{"ua": "субота 18:00", "keys": [["subot"], ["18"]]}, {"ua": "у парку", "keys": [["park"]]}, {"ua": "кожен приносить", "keys": [["svatko"]]}, {"ua": "поділимо витрати", "keys": [["podijel"]]}], "hints": ["druženje je u subotu u 18 sati", "u parku", "svatko donosi nešto", "podijelit ćemo troškove"], "models": ["Druženje je u subotu u 18 sati u parku. Svatko donosi nešto za jelo, a troškove za piće ćemo podijeliti."]}'::jsonb, false, 'writing');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', 'a7df87a3-828a-54ce-8965-5edda8cb3721', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  v_pos := pg_temp.ex_task(v_lesson, v_pos, '91477bd3-c470-50a1-b62c-d064d85d274a', 'mediation', 'Ваш друг не говорить хорватською. Передайте його слова хорватською.', 'Ona će donijeti balone i ukrase.', 'A2', 'PUBLISHED', '{"situation_ua": "Ваш друг не говорить хорватською. Передайте його слова хорватською.", "friend_ua": "Скажи всім у чаті, що я принесу кульки й прикраси.", "direction": "ua_hr", "points": [{"ua": "кульки", "keys": [["balon"]]}, {"ua": "прикраси", "keys": [["ukras"]]}], "hints": [], "models": ["Ona će donijeti balone i ukrase."], "source_ua": "Скажи всім у чаті, що я принесу кульки й прикраси."}'::jsonb, false, 'mediation');
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('exercise', '91477bd3-c470-50a1-b62c-d064d85d274a', null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'curriculum_a2_v2: «Напишіть повідомлення» і «Перекажіть другу» (ua → hr) в уроці A2. Бета (рішення власника 2026-11-12), потрібна перевірка носієм.');
  -- діалог 1
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('9f442227-a4a3-5c94-b0e0-db82cba9ba78', v_lesson, 'Плануємо вечірку', 'Planiramo zabavu', 5831, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('2f630930-50f3-5589-8d83-e8763c1017a0', '9f442227-a4a3-5c94-b0e0-db82cba9ba78', 'Darja', 'Organiziram druženje za Dašin rođendan. Iznenađenje za nju!', 'Я організовую вечірку на день народження Даші. Сюрприз для неї!', 1);
  perform pg_temp.turn('b1c0fabe-7ae4-59fe-b607-13a06e67ca1b', '9f442227-a4a3-5c94-b0e0-db82cba9ba78', 'Ivan', 'Super! Kada?', 'Супер! Коли?', 2);
  perform pg_temp.turn('3612423b-143b-5a87-88a0-3231ac00d1fc', '9f442227-a4a3-5c94-b0e0-db82cba9ba78', 'Darja', 'Napravila sam anketu u grupnom chatu. Većini odgovara subota.', 'Я зробила опитування в груповому чаті. Більшості підходить субота.', 3);
  perform pg_temp.turn('fbdbb7b4-f63d-515b-a38e-09c4630b5256', '9f442227-a4a3-5c94-b0e0-db82cba9ba78', 'Ivan', 'Tko će donijeti hranu?', 'Хто принесе їжу?', 4);
  perform pg_temp.turn('b0abdaaf-ca61-5000-862c-982e016ce1b5', '9f442227-a4a3-5c94-b0e0-db82cba9ba78', 'Darja', 'Svatko donosi nešto. Troškove za torte ćemo podijeliti.', 'Кожен приносить щось. Витрати на торти поділимо.', 5);
  perform pg_temp.turn('c12d3df1-e42d-52c9-978c-e5d91e040db0', '9f442227-a4a3-5c94-b0e0-db82cba9ba78', 'Ivan', 'Ja ću donijeti društvene igre i balone.', 'Я принесу настільні ігри й кульки.', 6);
  -- діалог 2
  insert into public.conversations (id, lesson_id, title_ua, title_hr, order_index, level, situation, status, source)
  values ('1df68246-b02f-5e0d-8e5a-3bd1430055b0', v_lesson, 'Після вечірки', 'Nakon zabave', 5832, 'A2', 'small_talk', 'PUBLISHED', 'claude_curriculum_a2_v2') on conflict (id) do nothing;
  perform pg_temp.turn('fbfea00c-01e8-5946-bc31-a3dc5f70c38c', '1df68246-b02f-5e0d-8e5a-3bd1430055b0', 'Marko', 'Bilo je super! Tko će raspremiti?', 'Було супер! Хто прибиратиме?', 1);
  perform pg_temp.turn('dbc2f464-997b-569c-aec5-79be9498259d', '1df68246-b02f-5e0d-8e5a-3bd1430055b0', 'Darja', 'Raspremit ćemo zajedno, brzo će ići.', 'Приберемо разом, швидко впораємося.', 2);
  perform pg_temp.turn('3417c7e0-63cf-5815-89f3-496d3ab0c419', '1df68246-b02f-5e0d-8e5a-3bd1430055b0', 'Marko', 'Daša je bila jako iznenađena.', 'Даша була дуже здивована.', 3);
  perform pg_temp.turn('502b4075-7080-50d3-9f98-fd50435bd20a', '1df68246-b02f-5e0d-8e5a-3bd1430055b0', 'Darja', 'Najvažnije je dobro raspoloženje. Sljedeći put na otvorenom!', 'Найважливіше — гарний настрій. Наступного разу — просто неба!', 4);
  -- журнал перевірки
  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  values ('lesson', v_lesson, null, 'PUBLISHED', 'auto_passed', 'ai', '[]'::jsonb, 'Бета: новий урок програми A2 v2 (20–25 нових слів за темою, 2 діалоги, 15 вправ, письмо й переказ) за рішенням власника 2026-11-12. Потрібна перевірка носієм.');
end $$;

-- 3. Модуль і юніт — опубліковані
update public.modules set status = 'PUBLISHED', title_ua = 'Модуль A2.13 — Плани, мрії й домовленості', title_hr = 'Modul A2.13 — Planovi, želje i dogovori' where id = '47c98d89-5811-5425-af88-26e8249d361b';
update public.units set status = 'PUBLISHED' where id = '55b7d23a-2c46-5ea6-bd0c-df533308d66e';

-- 4. Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_bad int; v_titles int; v_words int;
begin
  select count(*) into v_bad from public.lessons l
   where l.id in ('f2760130-fd69-5932-978c-cc424aaefafa', '00cd6ab0-29c4-5eab-94a4-5319d76fbce4', '0b054356-d4b4-5f6e-b7e9-3dc8f3c9d4ff', 'b8615bf1-2cc2-5cc1-b89a-ed065a4b9c28', 'f5189d33-5f78-51d5-a1ec-5712c5c87a88', '7595b9eb-8f9a-5772-8bae-259a79428d33')
     and ((select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'lexeme') not between 20 and 25
          or (select count(*) from public.conversations c where c.lesson_id = l.id and c.status = 'PUBLISHED') <> 2
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED' and li.required) <> 15
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and li.item_type = 'exercise' and e.status = 'PUBLISHED' and not li.required
                 and e.exercise_type in ('write_message', 'mediation')) <> 2
          or (select count(*) from public.lesson_items li join public.exercises e on e.id = li.item_id
               where li.lesson_id = l.id and e.exercise_type = 'listening_dialogue' and e.status = 'PUBLISHED') <> 1
          or (select count(*) from public.lesson_items li where li.lesson_id = l.id and li.item_type = 'grammar') <> 1
          or (select count(*) from public.lesson_grammar lg where lg.lesson_id = l.id) <> 1
          or l.status <> 'PUBLISHED' or l.estimated_minutes <> 20 or l.unit_id <> '55b7d23a-2c46-5ea6-bd0c-df533308d66e');
  select count(*) into v_titles from (values ('f2760130-fd69-5932-978c-cc424aaefafa'::uuid, 'Урок 78:%', 1), ('00cd6ab0-29c4-5eab-94a4-5319d76fbce4'::uuid, 'Урок 79:%', 2), ('0b054356-d4b4-5f6e-b7e9-3dc8f3c9d4ff'::uuid, 'Урок 80:%', 3), ('b8615bf1-2cc2-5cc1-b89a-ed065a4b9c28'::uuid, 'Урок 81:%', 4), ('f5189d33-5f78-51d5-a1ec-5712c5c87a88'::uuid, 'Урок 82:%', 5), ('7595b9eb-8f9a-5772-8bae-259a79428d33'::uuid, 'Урок 83:%', 6)) as t(id, pat, o)
    left join public.lessons l on l.id = t.id and l.title_ua like t.pat and l.order_index = t.o
   where l.id is null;
  select count(*) into v_words from (
     select li.item_id from public.lesson_items li join public.lessons l on l.id = li.lesson_id
      where l.level_code = 'A2' and l.status = 'PUBLISHED' and li.item_type = 'lexeme'
      group by 1 having count(*) > 1) d;
  if v_bad > 0 then raise exception 'Модуль A2.13: % уроків з неправильним складом', v_bad; end if;
  if v_titles > 0 then raise exception 'Модуль A2.13: % уроків не на своєму місці чи з неправильним номером', v_titles; end if;
  if v_words > 0 then raise exception 'A2: % слів повторюються в кількох уроках', v_words; end if;
  if (select status from public.modules where id = '47c98d89-5811-5425-af88-26e8249d361b') <> 'PUBLISHED' then raise exception 'Модуль A2.13 не опубліковано'; end if;
  raise notice 'Готово: модуль A2.13 — 6 уроків, слів 121';
end $$;

commit;
