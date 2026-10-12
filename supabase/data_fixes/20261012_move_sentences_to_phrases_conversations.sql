-- =====================================================================
-- 2026-10-12 · Перенесення речень і реплік з lexemes у conversations / phrases
-- Рішення власника: репліки діалогів → conversations + conversation_turns,
-- корисні фрази → phrases; «Možete li provjeriti motor OM639?» → діалог «Na servisu».
-- Потрібна міграція M6 (20261012180000_m6_phrases_conversation_meta.sql).
-- Згенеровано scripts/gen_move_phrases.py. Тексти і переклади беруться з lexemes.
-- Рядки в lexemes НЕ видаляються: status → 'DEPRECATED' (прогрес і історія зберігаються).
-- Резервна копія lexemes до змін: backup.lexemes_20261012_phrases.
-- Скрипт ідемпотентний і перевіряє себе: якщо щось не так — нічого не застосується.
-- =====================================================================
begin;

create schema if not exists backup;
create table if not exists backup.lexemes_20261012_phrases as table public.lexemes;

-- 0. Усі рядки, які переносимо, мають існувати в lexemes
do $$
declare missing text;
begin
  select string_agg(x, ' | ') into missing from unnest(array[
    'A: Dobar dan! Kako ste?',
    'B: Dobar dan. Hvala, dobro. A vi?',
    'A: I ja sam dobro, hvala.',
    'B: Doviđenja i ugodan dan!',
    'A: Dobar dan. Mogu li dobiti pola kile jabuka?',
    'B: Izvolite. Trebate li još nešto?',
    'A: Ne, to je sve. Koliko sam dužan?',
    'B: To je tri eura. Želite li vrećicu?',
    'Konobar: Izvolite, što ćete popiti?',
    'Gost: Molim vas jednu kavu s mlijekom i čaj.',
    'Konobar: Želite li nešto za pojesti?',
    'Gost: Ne, hvala. Samo račun poslije.',
    'Vozač: Oprostite, gdje mogu parkirati auto ovdje blizu?',
    'Prolaznik: Idite pravo i onda skrenite lijevo. Tamo je veliki parking.',
    'Vozač: Je li se plaća?',
    'Prolaznik: Da, jedan euro po satu. Možete platiti preko SMS-a.',
    'Stanar: Dobar dan. Imamo problem u stanu. Internet uopće ne radi.',
    'Najmodavac: Jeste li probali resetirati ruter?',
    'Stanar: Jesam, ali ne pomaže. Radim od kuće pa mi hitno treba.',
    'Najmodavac: Razumijem. Nazvat ću operatera i javiti vam.',
    'Pacijent: Dobar dan. Trebam nešto protiv bolova u grlu.',
    'Ljekarnik: Imate li visoku temperaturu?',
    'Pacijent: Ne, samo me malo boli kad gutam.',
    'Ljekarnik: Uzmite ove pastile. Tri puta dnevno poslije jela.',
    'Scrum Master: Dobro jutro svima. Krenimo s dnevnim sastankom.',
    'Developer: Završio sam backend dio. Danas radim na testiranju.',
    'Scrum Master: Imaš li kakvih zastoja?',
    'Vlasnik: Dobar dan. Želim dogovoriti servis za Smart Forfour.',
    'Mehaničar: Koji je problem?',
    'Vlasnik: Treba mi provjera dizni i zamjena ulja u mjenjaču.',
    'Možete li provjeriti motor OM639?',
    'Vlasnik: Dobar dan, naručeni smo za pregled.',
    'Veterinar: Kako se zove pas? Je li to australski ovčar?',
    'Vlasnik: Da, tako je. Došli smo na redovno cijepljenje.',
    'Osoba: Dobar dan. Došao sam po novu dozvolu za boravak.',
    'Službenik: Vaša putovnica i potvrdnica, molim.',
    'Osoba: Izvolite. Trebam li potpisati ovdje?',
    'Arhitekt: Moramo migrirati bazu u oblak.',
    'DevOps: Provjerit ću CI/CD pipeline i resurse.',
    'Drago mi je.',
    'Hvala lijepa.',
    'Kako se kaže... na hrvatskom?',
    'Oprostite, ne razumijem.',
    'Kada mogu doći?',
    'laku noć i sanjajte lijepo',
    'Dajte mi jednu vrećicu.',
    'Gdje je blagajna?',
    'Gdje mogu naći voće?',
    'Imate li sitnog?',
    'Plaćam gotovinom.',
    'To je preskupo.',
    'Trebam hranu za psa.',
    'Trebam račun, molim.',
    'imate li ovo u drugoj veličini',
    'Bilo je jako ukusno.',
    'Imate li slobodan stol?',
    'Kavu s mlijekom, molim.',
    'Mogu li dobiti jelovnik?',
    'Mogu li platiti odvojeno?',
    'Ovo nije ono što sam naručio.',
    'Račun, molim vas.',
    'Što preporučujete?',
    'Zadržite ostatak.',
    'Želim naručiti.',
    'Gdje je autobusni kolodvor?',
    'Gdje je najbliža benzinska postaja?',
    'Imam mali auto.',
    'Jednu kartu u jednom smjeru.',
    'Kada polazi autobus?',
    'Kako doći do centra?',
    'Možete li mi pokazati na karti?',
    'Skrenite desno na semaforu.',
    'Trebam mehaničara za auto.',
    'Trebam zamjenu ulja u mjenjaču.',
    'Bojler ne radi.',
    'Gdje je prekidač za struju?',
    'Internet je jako spor.',
    'Izgubio sam ključ.',
    'Kada možete doći popraviti?',
    'Klima uređaj curi.',
    'Možete li mi pomoći s ugovorom?',
    'Nema tople vode.',
    'Trebam platiti račune za režije.',
    'Boli me glava.',
    'Gdje je dežurna ljekarna?',
    'Imam alergiju na penicilin.',
    'Koliko puta dnevno?',
    'Ne osjećam se dobro.',
    'Pozovite hitnu pomoć!',
    'Trebam ići doktoru.',
    'Trebam li recept za ovo?',
    'Trebam nešto protiv prehlade.',
    'Trebam termin kod doktora.',
    'Imam visoku temperaturu.',
    'Trebam uputnicu za specijalista.',
    'Ovo je moja zdravstvena iskaznica.',
    'Imam jake bolove.',
    'Ovo je hitan slučaj.',
    'Radim od kuće.',
    'Bavim se IT uslugama.',
    'Treba mi bolovanje.',
    'Imamo li blokada za ovaj sprint?',
    'Koji je status ovog zadatka?',
    'Imamo li problem s memorijom na poslužitelju?',
    'Imate li hranu bez žitarica?',
    'Moj pas treba godišnje cjepivo.',
    'Koji broj trebam uzeti za MUP?',
    'Predao sam zahtjev online.',
    'Otvaram paušalni obrt.',
    'Ovo je rješenje o obrtu.',
    'Pečat mi ne treba.',
    'Izvolite dokumente.',
    'Ovo su papiri od auta.',
    'Samo smo u tranzitu.',
    'Nemam ništa za prijaviti.',
    'Ovo su moje osobne stvari.',
    'Želim otvoriti poslovni račun.',
    'Koja je mjesečna naknada?',
    'Putujem u Zadar.',
    'Idem na odmor.',
    'Znači...',
    'Mislim...',
    'Kužiš?',
    'Kako se zove...',
    'Pa...'
  ]) as x where not exists (select 1 from public.lexemes l where l.lemma = x);
  if missing is not null then raise exception 'Не знайдено в lexemes: %', missing; end if;
end $$;

-- 1. Діалоги
do $$
declare conv uuid;
begin
  -- Привітання
  select id into conv from public.conversations where title_hr = 'Pozdrav' and lesson_id is null and source = 'migrated_from_lexemes';
  if conv is null then
    insert into public.conversations (lesson_id, title_ua, title_hr, level, situation, status, source, order_index)
    values (null, 'Привітання', 'Pozdrav', 'A1', 'basics', 'PUBLISHED', 'migrated_from_lexemes', 0)
    returning id into conv;
    insert into public.conversation_turns (conversation_id, speaker_name, hr_text, ua_translation, order_index)
    select conv, 'A', 'Dobar dan! Kako ste?', regexp_replace(l.ukrainian_translation, '^[^:]{1,20}:\s*', ''), 1
    from public.lexemes l where l.lemma = 'A: Dobar dan! Kako ste?';
    insert into public.conversation_turns (conversation_id, speaker_name, hr_text, ua_translation, order_index)
    select conv, 'B', 'Dobar dan. Hvala, dobro. A vi?', regexp_replace(l.ukrainian_translation, '^[^:]{1,20}:\s*', ''), 2
    from public.lexemes l where l.lemma = 'B: Dobar dan. Hvala, dobro. A vi?';
    insert into public.conversation_turns (conversation_id, speaker_name, hr_text, ua_translation, order_index)
    select conv, 'A', 'I ja sam dobro, hvala.', regexp_replace(l.ukrainian_translation, '^[^:]{1,20}:\s*', ''), 3
    from public.lexemes l where l.lemma = 'A: I ja sam dobro, hvala.';
    insert into public.conversation_turns (conversation_id, speaker_name, hr_text, ua_translation, order_index)
    select conv, 'B', 'Doviđenja i ugodan dan!', regexp_replace(l.ukrainian_translation, '^[^:]{1,20}:\s*', ''), 4
    from public.lexemes l where l.lemma = 'B: Doviđenja i ugodan dan!';
  end if;
  -- На ринку
  select id into conv from public.conversations where title_hr = 'Na tržnici' and lesson_id is null and source = 'migrated_from_lexemes';
  if conv is null then
    insert into public.conversations (lesson_id, title_ua, title_hr, level, situation, status, source, order_index)
    values (null, 'На ринку', 'Na tržnici', 'A1', 'shopping', 'PUBLISHED', 'migrated_from_lexemes', 0)
    returning id into conv;
    insert into public.conversation_turns (conversation_id, speaker_name, hr_text, ua_translation, order_index)
    select conv, 'A', 'Dobar dan. Mogu li dobiti pola kile jabuka?', regexp_replace(l.ukrainian_translation, '^[^:]{1,20}:\s*', ''), 1
    from public.lexemes l where l.lemma = 'A: Dobar dan. Mogu li dobiti pola kile jabuka?';
    insert into public.conversation_turns (conversation_id, speaker_name, hr_text, ua_translation, order_index)
    select conv, 'B', 'Izvolite. Trebate li još nešto?', regexp_replace(l.ukrainian_translation, '^[^:]{1,20}:\s*', ''), 2
    from public.lexemes l where l.lemma = 'B: Izvolite. Trebate li još nešto?';
    insert into public.conversation_turns (conversation_id, speaker_name, hr_text, ua_translation, order_index)
    select conv, 'A', 'Ne, to je sve. Koliko sam dužan?', regexp_replace(l.ukrainian_translation, '^[^:]{1,20}:\s*', ''), 3
    from public.lexemes l where l.lemma = 'A: Ne, to je sve. Koliko sam dužan?';
    insert into public.conversation_turns (conversation_id, speaker_name, hr_text, ua_translation, order_index)
    select conv, 'B', 'To je tri eura. Želite li vrećicu?', regexp_replace(l.ukrainian_translation, '^[^:]{1,20}:\s*', ''), 4
    from public.lexemes l where l.lemma = 'B: To je tri eura. Želite li vrećicu?';
  end if;
  -- У кафе
  select id into conv from public.conversations where title_hr = 'U kafiću' and lesson_id is null and source = 'migrated_from_lexemes';
  if conv is null then
    insert into public.conversations (lesson_id, title_ua, title_hr, level, situation, status, source, order_index)
    values (null, 'У кафе', 'U kafiću', 'A1', 'cafe_restaurant', 'PUBLISHED', 'migrated_from_lexemes', 0)
    returning id into conv;
    insert into public.conversation_turns (conversation_id, speaker_name, hr_text, ua_translation, order_index)
    select conv, 'Konobar', 'Izvolite, što ćete popiti?', regexp_replace(l.ukrainian_translation, '^[^:]{1,20}:\s*', ''), 1
    from public.lexemes l where l.lemma = 'Konobar: Izvolite, što ćete popiti?';
    insert into public.conversation_turns (conversation_id, speaker_name, hr_text, ua_translation, order_index)
    select conv, 'Gost', 'Molim vas jednu kavu s mlijekom i čaj.', regexp_replace(l.ukrainian_translation, '^[^:]{1,20}:\s*', ''), 2
    from public.lexemes l where l.lemma = 'Gost: Molim vas jednu kavu s mlijekom i čaj.';
    insert into public.conversation_turns (conversation_id, speaker_name, hr_text, ua_translation, order_index)
    select conv, 'Konobar', 'Želite li nešto za pojesti?', regexp_replace(l.ukrainian_translation, '^[^:]{1,20}:\s*', ''), 3
    from public.lexemes l where l.lemma = 'Konobar: Želite li nešto za pojesti?';
    insert into public.conversation_turns (conversation_id, speaker_name, hr_text, ua_translation, order_index)
    select conv, 'Gost', 'Ne, hvala. Samo račun poslije.', regexp_replace(l.ukrainian_translation, '^[^:]{1,20}:\s*', ''), 4
    from public.lexemes l where l.lemma = 'Gost: Ne, hvala. Samo račun poslije.';
  end if;
  -- Паркування в місті
  select id into conv from public.conversations where title_hr = 'Parkiranje u gradu' and lesson_id is null and source = 'migrated_from_lexemes';
  if conv is null then
    insert into public.conversations (lesson_id, title_ua, title_hr, level, situation, status, source, order_index)
    values (null, 'Паркування в місті', 'Parkiranje u gradu', 'A1', 'transport', 'PUBLISHED', 'migrated_from_lexemes', 0)
    returning id into conv;
    insert into public.conversation_turns (conversation_id, speaker_name, hr_text, ua_translation, order_index)
    select conv, 'Vozač', 'Oprostite, gdje mogu parkirati auto ovdje blizu?', regexp_replace(l.ukrainian_translation, '^[^:]{1,20}:\s*', ''), 1
    from public.lexemes l where l.lemma = 'Vozač: Oprostite, gdje mogu parkirati auto ovdje blizu?';
    insert into public.conversation_turns (conversation_id, speaker_name, hr_text, ua_translation, order_index)
    select conv, 'Prolaznik', 'Idite pravo i onda skrenite lijevo. Tamo je veliki parking.', regexp_replace(l.ukrainian_translation, '^[^:]{1,20}:\s*', ''), 2
    from public.lexemes l where l.lemma = 'Prolaznik: Idite pravo i onda skrenite lijevo. Tamo je veliki parking.';
    insert into public.conversation_turns (conversation_id, speaker_name, hr_text, ua_translation, order_index)
    select conv, 'Vozač', 'Je li se plaća?', regexp_replace(l.ukrainian_translation, '^[^:]{1,20}:\s*', ''), 3
    from public.lexemes l where l.lemma = 'Vozač: Je li se plaća?';
    insert into public.conversation_turns (conversation_id, speaker_name, hr_text, ua_translation, order_index)
    select conv, 'Prolaznik', 'Da, jedan euro po satu. Možete platiti preko SMS-a.', regexp_replace(l.ukrainian_translation, '^[^:]{1,20}:\s*', ''), 4
    from public.lexemes l where l.lemma = 'Prolaznik: Da, jedan euro po satu. Možete platiti preko SMS-a.';
  end if;
  -- Проблема в квартирі
  select id into conv from public.conversations where title_hr = 'Problem u stanu' and lesson_id is null and source = 'migrated_from_lexemes';
  if conv is null then
    insert into public.conversations (lesson_id, title_ua, title_hr, level, situation, status, source, order_index)
    values (null, 'Проблема в квартирі', 'Problem u stanu', 'A1', 'housing', 'PUBLISHED', 'migrated_from_lexemes', 0)
    returning id into conv;
    insert into public.conversation_turns (conversation_id, speaker_name, hr_text, ua_translation, order_index)
    select conv, 'Stanar', 'Dobar dan. Imamo problem u stanu. Internet uopće ne radi.', regexp_replace(l.ukrainian_translation, '^[^:]{1,20}:\s*', ''), 1
    from public.lexemes l where l.lemma = 'Stanar: Dobar dan. Imamo problem u stanu. Internet uopće ne radi.';
    insert into public.conversation_turns (conversation_id, speaker_name, hr_text, ua_translation, order_index)
    select conv, 'Najmodavac', 'Jeste li probali resetirati ruter?', regexp_replace(l.ukrainian_translation, '^[^:]{1,20}:\s*', ''), 2
    from public.lexemes l where l.lemma = 'Najmodavac: Jeste li probali resetirati ruter?';
    insert into public.conversation_turns (conversation_id, speaker_name, hr_text, ua_translation, order_index)
    select conv, 'Stanar', 'Jesam, ali ne pomaže. Radim od kuće pa mi hitno treba.', regexp_replace(l.ukrainian_translation, '^[^:]{1,20}:\s*', ''), 3
    from public.lexemes l where l.lemma = 'Stanar: Jesam, ali ne pomaže. Radim od kuće pa mi hitno treba.';
    insert into public.conversation_turns (conversation_id, speaker_name, hr_text, ua_translation, order_index)
    select conv, 'Najmodavac', 'Razumijem. Nazvat ću operatera i javiti vam.', regexp_replace(l.ukrainian_translation, '^[^:]{1,20}:\s*', ''), 4
    from public.lexemes l where l.lemma = 'Najmodavac: Razumijem. Nazvat ću operatera i javiti vam.';
  end if;
  -- В аптеці
  select id into conv from public.conversations where title_hr = 'U ljekarni' and lesson_id is null and source = 'migrated_from_lexemes';
  if conv is null then
    insert into public.conversations (lesson_id, title_ua, title_hr, level, situation, status, source, order_index)
    values (null, 'В аптеці', 'U ljekarni', 'A1', 'health', 'PUBLISHED', 'migrated_from_lexemes', 0)
    returning id into conv;
    insert into public.conversation_turns (conversation_id, speaker_name, hr_text, ua_translation, order_index)
    select conv, 'Pacijent', 'Dobar dan. Trebam nešto protiv bolova u grlu.', regexp_replace(l.ukrainian_translation, '^[^:]{1,20}:\s*', ''), 1
    from public.lexemes l where l.lemma = 'Pacijent: Dobar dan. Trebam nešto protiv bolova u grlu.';
    insert into public.conversation_turns (conversation_id, speaker_name, hr_text, ua_translation, order_index)
    select conv, 'Ljekarnik', 'Imate li visoku temperaturu?', regexp_replace(l.ukrainian_translation, '^[^:]{1,20}:\s*', ''), 2
    from public.lexemes l where l.lemma = 'Ljekarnik: Imate li visoku temperaturu?';
    insert into public.conversation_turns (conversation_id, speaker_name, hr_text, ua_translation, order_index)
    select conv, 'Pacijent', 'Ne, samo me malo boli kad gutam.', regexp_replace(l.ukrainian_translation, '^[^:]{1,20}:\s*', ''), 3
    from public.lexemes l where l.lemma = 'Pacijent: Ne, samo me malo boli kad gutam.';
    insert into public.conversation_turns (conversation_id, speaker_name, hr_text, ua_translation, order_index)
    select conv, 'Ljekarnik', 'Uzmite ove pastile. Tri puta dnevno poslije jela.', regexp_replace(l.ukrainian_translation, '^[^:]{1,20}:\s*', ''), 4
    from public.lexemes l where l.lemma = 'Ljekarnik: Uzmite ove pastile. Tri puta dnevno poslije jela.';
  end if;
  -- Щоденний мітинг (IT)
  select id into conv from public.conversations where title_hr = 'Dnevni sastanak' and lesson_id is null and source = 'migrated_from_lexemes';
  if conv is null then
    insert into public.conversations (lesson_id, title_ua, title_hr, level, situation, status, source, order_index)
    values (null, 'Щоденний мітинг (IT)', 'Dnevni sastanak', 'A1', 'it_work', 'PUBLISHED', 'migrated_from_lexemes', 0)
    returning id into conv;
    insert into public.conversation_turns (conversation_id, speaker_name, hr_text, ua_translation, order_index)
    select conv, 'Scrum Master', 'Dobro jutro svima. Krenimo s dnevnim sastankom.', regexp_replace(l.ukrainian_translation, '^[^:]{1,20}:\s*', ''), 1
    from public.lexemes l where l.lemma = 'Scrum Master: Dobro jutro svima. Krenimo s dnevnim sastankom.';
    insert into public.conversation_turns (conversation_id, speaker_name, hr_text, ua_translation, order_index)
    select conv, 'Developer', 'Završio sam backend dio. Danas radim na testiranju.', regexp_replace(l.ukrainian_translation, '^[^:]{1,20}:\s*', ''), 2
    from public.lexemes l where l.lemma = 'Developer: Završio sam backend dio. Danas radim na testiranju.';
    insert into public.conversation_turns (conversation_id, speaker_name, hr_text, ua_translation, order_index)
    select conv, 'Scrum Master', 'Imaš li kakvih zastoja?', regexp_replace(l.ukrainian_translation, '^[^:]{1,20}:\s*', ''), 3
    from public.lexemes l where l.lemma = 'Scrum Master: Imaš li kakvih zastoja?';
  end if;
  -- На СТО
  select id into conv from public.conversations where title_hr = 'Na servisu' and lesson_id is null and source = 'migrated_from_lexemes';
  if conv is null then
    insert into public.conversations (lesson_id, title_ua, title_hr, level, situation, status, source, order_index)
    values (null, 'На СТО', 'Na servisu', 'A1', 'car_service', 'PUBLISHED', 'migrated_from_lexemes', 0)
    returning id into conv;
    insert into public.conversation_turns (conversation_id, speaker_name, hr_text, ua_translation, order_index)
    select conv, 'Vlasnik', 'Dobar dan. Želim dogovoriti servis za Smart Forfour.', regexp_replace(l.ukrainian_translation, '^[^:]{1,20}:\s*', ''), 1
    from public.lexemes l where l.lemma = 'Vlasnik: Dobar dan. Želim dogovoriti servis za Smart Forfour.';
    insert into public.conversation_turns (conversation_id, speaker_name, hr_text, ua_translation, order_index)
    select conv, 'Mehaničar', 'Koji je problem?', regexp_replace(l.ukrainian_translation, '^[^:]{1,20}:\s*', ''), 2
    from public.lexemes l where l.lemma = 'Mehaničar: Koji je problem?';
    insert into public.conversation_turns (conversation_id, speaker_name, hr_text, ua_translation, order_index)
    select conv, 'Vlasnik', 'Treba mi provjera dizni i zamjena ulja u mjenjaču.', regexp_replace(l.ukrainian_translation, '^[^:]{1,20}:\s*', ''), 3
    from public.lexemes l where l.lemma = 'Vlasnik: Treba mi provjera dizni i zamjena ulja u mjenjaču.';
    insert into public.conversation_turns (conversation_id, speaker_name, hr_text, ua_translation, order_index)
    select conv, 'Vlasnik', l.lemma, l.ukrainian_translation, 4 from public.lexemes l where l.lemma = 'Možete li provjeriti motor OM639?';
  end if;
  -- У ветеринара
  select id into conv from public.conversations where title_hr = 'Kod veterinara' and lesson_id is null and source = 'migrated_from_lexemes';
  if conv is null then
    insert into public.conversations (lesson_id, title_ua, title_hr, level, situation, status, source, order_index)
    values (null, 'У ветеринара', 'Kod veterinara', 'A1', 'vet', 'PUBLISHED', 'migrated_from_lexemes', 0)
    returning id into conv;
    insert into public.conversation_turns (conversation_id, speaker_name, hr_text, ua_translation, order_index)
    select conv, 'Vlasnik', 'Dobar dan, naručeni smo za pregled.', regexp_replace(l.ukrainian_translation, '^[^:]{1,20}:\s*', ''), 1
    from public.lexemes l where l.lemma = 'Vlasnik: Dobar dan, naručeni smo za pregled.';
    insert into public.conversation_turns (conversation_id, speaker_name, hr_text, ua_translation, order_index)
    select conv, 'Veterinar', 'Kako se zove pas? Je li to australski ovčar?', regexp_replace(l.ukrainian_translation, '^[^:]{1,20}:\s*', ''), 2
    from public.lexemes l where l.lemma = 'Veterinar: Kako se zove pas? Je li to australski ovčar?';
    insert into public.conversation_turns (conversation_id, speaker_name, hr_text, ua_translation, order_index)
    select conv, 'Vlasnik', 'Da, tako je. Došli smo na redovno cijepljenje.', regexp_replace(l.ukrainian_translation, '^[^:]{1,20}:\s*', ''), 3
    from public.lexemes l where l.lemma = 'Vlasnik: Da, tako je. Došli smo na redovno cijepljenje.';
  end if;
  -- У MUP (міграційна служба)
  select id into conv from public.conversations where title_hr = 'U MUP-u' and lesson_id is null and source = 'migrated_from_lexemes';
  if conv is null then
    insert into public.conversations (lesson_id, title_ua, title_hr, level, situation, status, source, order_index)
    values (null, 'У MUP (міграційна служба)', 'U MUP-u', 'A1', 'administration', 'PUBLISHED', 'migrated_from_lexemes', 0)
    returning id into conv;
    insert into public.conversation_turns (conversation_id, speaker_name, hr_text, ua_translation, order_index)
    select conv, 'Osoba', 'Dobar dan. Došao sam po novu dozvolu za boravak.', regexp_replace(l.ukrainian_translation, '^[^:]{1,20}:\s*', ''), 1
    from public.lexemes l where l.lemma = 'Osoba: Dobar dan. Došao sam po novu dozvolu za boravak.';
    insert into public.conversation_turns (conversation_id, speaker_name, hr_text, ua_translation, order_index)
    select conv, 'Službenik', 'Vaša putovnica i potvrdnica, molim.', regexp_replace(l.ukrainian_translation, '^[^:]{1,20}:\s*', ''), 2
    from public.lexemes l where l.lemma = 'Službenik: Vaša putovnica i potvrdnica, molim.';
    insert into public.conversation_turns (conversation_id, speaker_name, hr_text, ua_translation, order_index)
    select conv, 'Osoba', 'Izvolite. Trebam li potpisati ovdje?', regexp_replace(l.ukrainian_translation, '^[^:]{1,20}:\s*', ''), 3
    from public.lexemes l where l.lemma = 'Osoba: Izvolite. Trebam li potpisati ovdje?';
  end if;
  -- Технічна нарада (IT)
  select id into conv from public.conversations where title_hr = 'Tehnički sastanak' and lesson_id is null and source = 'migrated_from_lexemes';
  if conv is null then
    insert into public.conversations (lesson_id, title_ua, title_hr, level, situation, status, source, order_index)
    values (null, 'Технічна нарада (IT)', 'Tehnički sastanak', 'A1', 'it_work', 'PUBLISHED', 'migrated_from_lexemes', 0)
    returning id into conv;
    insert into public.conversation_turns (conversation_id, speaker_name, hr_text, ua_translation, order_index)
    select conv, 'Arhitekt', 'Moramo migrirati bazu u oblak.', regexp_replace(l.ukrainian_translation, '^[^:]{1,20}:\s*', ''), 1
    from public.lexemes l where l.lemma = 'Arhitekt: Moramo migrirati bazu u oblak.';
    insert into public.conversation_turns (conversation_id, speaker_name, hr_text, ua_translation, order_index)
    select conv, 'DevOps', 'Provjerit ću CI/CD pipeline i resurse.', regexp_replace(l.ukrainian_translation, '^[^:]{1,20}:\s*', ''), 2
    from public.lexemes l where l.lemma = 'DevOps: Provjerit ću CI/CD pipeline i resurse.';
  end if;
end $$;

-- 2. Фрази
-- basics
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'basics', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Drago mi je.'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'basics', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Hvala lijepa.'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'basics', 'question', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Kako se kaže... na hrvatskom?'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'basics', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Oprostite, ne razumijem.'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'basics', 'question', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Kada mogu doći?'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'basics', 'chunk', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'laku noć i sanjajte lijepo'
on conflict (lower(text_hr)) do nothing;
-- shopping
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'shopping', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Dajte mi jednu vrećicu.'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'shopping', 'question', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Gdje je blagajna?'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'shopping', 'question', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Gdje mogu naći voće?'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'shopping', 'question', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Imate li sitnog?'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'shopping', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Plaćam gotovinom.'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'shopping', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'To je preskupo.'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'shopping', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Trebam hranu za psa.'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'shopping', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Trebam račun, molim.'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'shopping', 'chunk', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'imate li ovo u drugoj veličini'
on conflict (lower(text_hr)) do nothing;
-- cafe_restaurant
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'cafe_restaurant', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Bilo je jako ukusno.'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'cafe_restaurant', 'question', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Imate li slobodan stol?'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'cafe_restaurant', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Kavu s mlijekom, molim.'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'cafe_restaurant', 'question', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Mogu li dobiti jelovnik?'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'cafe_restaurant', 'question', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Mogu li platiti odvojeno?'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'cafe_restaurant', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Ovo nije ono što sam naručio.'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'cafe_restaurant', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Račun, molim vas.'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'cafe_restaurant', 'question', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Što preporučujete?'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'cafe_restaurant', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Zadržite ostatak.'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'cafe_restaurant', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Želim naručiti.'
on conflict (lower(text_hr)) do nothing;
-- transport
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'transport', 'question', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Gdje je autobusni kolodvor?'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'transport', 'question', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Gdje je najbliža benzinska postaja?'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'transport', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Imam mali auto.'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'transport', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Jednu kartu u jednom smjeru.'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'transport', 'question', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Kada polazi autobus?'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'transport', 'question', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Kako doći do centra?'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'transport', 'question', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Možete li mi pokazati na karti?'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'transport', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Skrenite desno na semaforu.'
on conflict (lower(text_hr)) do nothing;
-- car_service
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'car_service', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Trebam mehaničara za auto.'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'car_service', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Trebam zamjenu ulja u mjenjaču.'
on conflict (lower(text_hr)) do nothing;
-- housing
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'housing', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Bojler ne radi.'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'housing', 'question', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Gdje je prekidač za struju?'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'housing', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Internet je jako spor.'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'housing', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Izgubio sam ključ.'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'housing', 'question', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Kada možete doći popraviti?'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'housing', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Klima uređaj curi.'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'housing', 'question', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Možete li mi pomoći s ugovorom?'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'housing', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Nema tople vode.'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'housing', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Trebam platiti račune za režije.'
on conflict (lower(text_hr)) do nothing;
-- health
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'health', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Boli me glava.'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'health', 'question', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Gdje je dežurna ljekarna?'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'health', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Imam alergiju na penicilin.'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'health', 'question', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Koliko puta dnevno?'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'health', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Ne osjećam se dobro.'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'health', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Pozovite hitnu pomoć!'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'health', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Trebam ići doktoru.'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'health', 'question', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Trebam li recept za ovo?'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'health', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Trebam nešto protiv prehlade.'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'health', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Trebam termin kod doktora.'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'health', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Imam visoku temperaturu.'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'health', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Trebam uputnicu za specijalista.'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'health', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Ovo je moja zdravstvena iskaznica.'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'health', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Imam jake bolove.'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'health', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Ovo je hitan slučaj.'
on conflict (lower(text_hr)) do nothing;
-- work
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'work', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Radim od kuće.'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'work', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Bavim se IT uslugama.'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'work', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Treba mi bolovanje.'
on conflict (lower(text_hr)) do nothing;
-- it_work
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'it_work', 'question', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Imamo li blokada za ovaj sprint?'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'it_work', 'question', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Koji je status ovog zadatka?'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'it_work', 'question', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Imamo li problem s memorijom na poslužitelju?'
on conflict (lower(text_hr)) do nothing;
-- vet
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'vet', 'question', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Imate li hranu bez žitarica?'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'vet', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Moj pas treba godišnje cjepivo.'
on conflict (lower(text_hr)) do nothing;
-- administration
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'administration', 'question', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Koji broj trebam uzeti za MUP?'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'administration', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Predao sam zahtjev online.'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'administration', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Otvaram paušalni obrt.'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'administration', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Ovo je rješenje o obrtu.'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'administration', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Pečat mi ne treba.'
on conflict (lower(text_hr)) do nothing;
-- border
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'border', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Izvolite dokumente.'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'border', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Ovo su papiri od auta.'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'border', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Samo smo u tranzitu.'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'border', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Nemam ništa za prijaviti.'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'border', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Ovo su moje osobne stvari.'
on conflict (lower(text_hr)) do nothing;
-- bank
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'bank', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Želim otvoriti poslovni račun.'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'bank', 'question', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Koja je mjesečna naknada?'
on conflict (lower(text_hr)) do nothing;
-- travel
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'travel', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Putujem u Zadar.'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'travel', 'phrase', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Idem na odmor.'
on conflict (lower(text_hr)) do nothing;
-- small_talk
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'small_talk', 'filler', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Znači...'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'small_talk', 'filler', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Mislim...'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'small_talk', 'question', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Kužiš?'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'small_talk', 'filler', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Kako se zove...'
on conflict (lower(text_hr)) do nothing;
insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)
select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, 'small_talk', 'filler', coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id
from public.lexemes l where l.lemma = 'Pa...'
on conflict (lower(text_hr)) do nothing;

-- 3. У lexemes — DEPRECATED (не видаляємо)
update public.lexemes set status = 'DEPRECATED', version = coalesce(version, 1) + 1
where status is distinct from 'DEPRECATED' and lemma = any (array[
  'A: Dobar dan! Kako ste?',
  'B: Dobar dan. Hvala, dobro. A vi?',
  'A: I ja sam dobro, hvala.',
  'B: Doviđenja i ugodan dan!',
  'A: Dobar dan. Mogu li dobiti pola kile jabuka?',
  'B: Izvolite. Trebate li još nešto?',
  'A: Ne, to je sve. Koliko sam dužan?',
  'B: To je tri eura. Želite li vrećicu?',
  'Konobar: Izvolite, što ćete popiti?',
  'Gost: Molim vas jednu kavu s mlijekom i čaj.',
  'Konobar: Želite li nešto za pojesti?',
  'Gost: Ne, hvala. Samo račun poslije.',
  'Vozač: Oprostite, gdje mogu parkirati auto ovdje blizu?',
  'Prolaznik: Idite pravo i onda skrenite lijevo. Tamo je veliki parking.',
  'Vozač: Je li se plaća?',
  'Prolaznik: Da, jedan euro po satu. Možete platiti preko SMS-a.',
  'Stanar: Dobar dan. Imamo problem u stanu. Internet uopće ne radi.',
  'Najmodavac: Jeste li probali resetirati ruter?',
  'Stanar: Jesam, ali ne pomaže. Radim od kuće pa mi hitno treba.',
  'Najmodavac: Razumijem. Nazvat ću operatera i javiti vam.',
  'Pacijent: Dobar dan. Trebam nešto protiv bolova u grlu.',
  'Ljekarnik: Imate li visoku temperaturu?',
  'Pacijent: Ne, samo me malo boli kad gutam.',
  'Ljekarnik: Uzmite ove pastile. Tri puta dnevno poslije jela.',
  'Scrum Master: Dobro jutro svima. Krenimo s dnevnim sastankom.',
  'Developer: Završio sam backend dio. Danas radim na testiranju.',
  'Scrum Master: Imaš li kakvih zastoja?',
  'Vlasnik: Dobar dan. Želim dogovoriti servis za Smart Forfour.',
  'Mehaničar: Koji je problem?',
  'Vlasnik: Treba mi provjera dizni i zamjena ulja u mjenjaču.',
  'Možete li provjeriti motor OM639?',
  'Vlasnik: Dobar dan, naručeni smo za pregled.',
  'Veterinar: Kako se zove pas? Je li to australski ovčar?',
  'Vlasnik: Da, tako je. Došli smo na redovno cijepljenje.',
  'Osoba: Dobar dan. Došao sam po novu dozvolu za boravak.',
  'Službenik: Vaša putovnica i potvrdnica, molim.',
  'Osoba: Izvolite. Trebam li potpisati ovdje?',
  'Arhitekt: Moramo migrirati bazu u oblak.',
  'DevOps: Provjerit ću CI/CD pipeline i resurse.',
  'Drago mi je.',
  'Hvala lijepa.',
  'Kako se kaže... na hrvatskom?',
  'Oprostite, ne razumijem.',
  'Kada mogu doći?',
  'laku noć i sanjajte lijepo',
  'Dajte mi jednu vrećicu.',
  'Gdje je blagajna?',
  'Gdje mogu naći voće?',
  'Imate li sitnog?',
  'Plaćam gotovinom.',
  'To je preskupo.',
  'Trebam hranu za psa.',
  'Trebam račun, molim.',
  'imate li ovo u drugoj veličini',
  'Bilo je jako ukusno.',
  'Imate li slobodan stol?',
  'Kavu s mlijekom, molim.',
  'Mogu li dobiti jelovnik?',
  'Mogu li platiti odvojeno?',
  'Ovo nije ono što sam naručio.',
  'Račun, molim vas.',
  'Što preporučujete?',
  'Zadržite ostatak.',
  'Želim naručiti.',
  'Gdje je autobusni kolodvor?',
  'Gdje je najbliža benzinska postaja?',
  'Imam mali auto.',
  'Jednu kartu u jednom smjeru.',
  'Kada polazi autobus?',
  'Kako doći do centra?',
  'Možete li mi pokazati na karti?',
  'Skrenite desno na semaforu.',
  'Trebam mehaničara za auto.',
  'Trebam zamjenu ulja u mjenjaču.',
  'Bojler ne radi.',
  'Gdje je prekidač za struju?',
  'Internet je jako spor.',
  'Izgubio sam ključ.',
  'Kada možete doći popraviti?',
  'Klima uređaj curi.',
  'Možete li mi pomoći s ugovorom?',
  'Nema tople vode.',
  'Trebam platiti račune za režije.',
  'Boli me glava.',
  'Gdje je dežurna ljekarna?',
  'Imam alergiju na penicilin.',
  'Koliko puta dnevno?',
  'Ne osjećam se dobro.',
  'Pozovite hitnu pomoć!',
  'Trebam ići doktoru.',
  'Trebam li recept za ovo?',
  'Trebam nešto protiv prehlade.',
  'Trebam termin kod doktora.',
  'Imam visoku temperaturu.',
  'Trebam uputnicu za specijalista.',
  'Ovo je moja zdravstvena iskaznica.',
  'Imam jake bolove.',
  'Ovo je hitan slučaj.',
  'Radim od kuće.',
  'Bavim se IT uslugama.',
  'Treba mi bolovanje.',
  'Imamo li blokada za ovaj sprint?',
  'Koji je status ovog zadatka?',
  'Imamo li problem s memorijom na poslužitelju?',
  'Imate li hranu bez žitarica?',
  'Moj pas treba godišnje cjepivo.',
  'Koji broj trebam uzeti za MUP?',
  'Predao sam zahtjev online.',
  'Otvaram paušalni obrt.',
  'Ovo je rješenje o obrtu.',
  'Pečat mi ne treba.',
  'Izvolite dokumente.',
  'Ovo su papiri od auta.',
  'Samo smo u tranzitu.',
  'Nemam ništa za prijaviti.',
  'Ovo su moje osobne stvari.',
  'Želim otvoriti poslovni račun.',
  'Koja je mjesečna naknada?',
  'Putujem u Zadar.',
  'Idem na odmor.',
  'Znači...',
  'Mislim...',
  'Kužiš?',
  'Kako se zove...',
  'Pa...'
]);

-- 4. Самоперевірка: інакше відкат усієї транзакції
do $$
declare left_over int; n_phr int; n_conv int; n_turns int;
begin
  select count(*) into left_over from public.lexemes
  where status is distinct from 'DEPRECATED'
    and (lemma ~ ':' or lemma ~ '[.?!]$' or array_length(regexp_split_to_array(trim(lemma), '\s+'), 1) > 4);
  select count(*) into n_phr from public.phrases where source = 'migrated_from_lexemes';
  select count(*) into n_conv from public.conversations where source = 'migrated_from_lexemes';
  select count(*) into n_turns from public.conversation_turns t join public.conversations c on c.id = t.conversation_id where c.source = 'migrated_from_lexemes';
  if left_over <> 0 then raise exception 'FAIL: у lexemes лишилось % речень', left_over; end if;
  if n_phr <> 86 then raise exception 'FAIL: фраз %, очікувалось 86', n_phr; end if;
  if n_conv <> 11 then raise exception 'FAIL: діалогів %, очікувалось 11', n_conv; end if;
  if n_turns <> 39 then raise exception 'FAIL: реплік %, очікувалось 39', n_turns; end if;
  raise notice 'OK: % фраз, % діалогів, % реплік; речень у lexemes не лишилось', n_phr, n_conv, n_turns;
end $$;

commit;

select 'OK: 86 фраз, 11 діалогів, 39 реплік' as result;
