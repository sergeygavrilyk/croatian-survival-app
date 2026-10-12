"""Генерує supabase/data_fixes/20261012_move_sentences_to_phrases_conversations.sql

Структура (які рядки — діалог, у якому порядку, яка ситуація) задається тут;
тексти й переклади SQL бере безпосередньо з public.lexemes за точним значенням lemma.
"""
import sys

DIALOGUES = [
    # (title_hr, title_ua, situation, level, [lemma у lexemes, у порядку реплік])
    ("Pozdrav", "Привітання", "basics", "A1", [
        "A: Dobar dan! Kako ste?",
        "B: Dobar dan. Hvala, dobro. A vi?",
        "A: I ja sam dobro, hvala.",
        "B: Doviđenja i ugodan dan!",
    ]),
    ("Na tržnici", "На ринку", "shopping", "A1", [
        "A: Dobar dan. Mogu li dobiti pola kile jabuka?",
        "B: Izvolite. Trebate li još nešto?",
        "A: Ne, to je sve. Koliko sam dužan?",
        "B: To je tri eura. Želite li vrećicu?",
    ]),
    ("U kafiću", "У кафе", "cafe_restaurant", "A1", [
        "Konobar: Izvolite, što ćete popiti?",
        "Gost: Molim vas jednu kavu s mlijekom i čaj.",
        "Konobar: Želite li nešto za pojesti?",
        "Gost: Ne, hvala. Samo račun poslije.",
    ]),
    ("Parkiranje u gradu", "Паркування в місті", "transport", "A1", [
        "Vozač: Oprostite, gdje mogu parkirati auto ovdje blizu?",
        "Prolaznik: Idite pravo i onda skrenite lijevo. Tamo je veliki parking.",
        "Vozač: Je li se plaća?",
        "Prolaznik: Da, jedan euro po satu. Možete platiti preko SMS-a.",
    ]),
    ("Problem u stanu", "Проблема в квартирі", "housing", "A1", [
        "Stanar: Dobar dan. Imamo problem u stanu. Internet uopće ne radi.",
        "Najmodavac: Jeste li probali resetirati ruter?",
        "Stanar: Jesam, ali ne pomaže. Radim od kuće pa mi hitno treba.",
        "Najmodavac: Razumijem. Nazvat ću operatera i javiti vam.",
    ]),
    ("U ljekarni", "В аптеці", "health", "A1", [
        "Pacijent: Dobar dan. Trebam nešto protiv bolova u grlu.",
        "Ljekarnik: Imate li visoku temperaturu?",
        "Pacijent: Ne, samo me malo boli kad gutam.",
        "Ljekarnik: Uzmite ove pastile. Tri puta dnevno poslije jela.",
    ]),
    ("Dnevni sastanak", "Щоденний мітинг (IT)", "it_work", "A1", [
        "Scrum Master: Dobro jutro svima. Krenimo s dnevnim sastankom.",
        "Developer: Završio sam backend dio. Danas radim na testiranju.",
        "Scrum Master: Imaš li kakvih zastoja?",
    ]),
    ("Na servisu", "На СТО", "car_service", "A1", [
        "Vlasnik: Dobar dan. Želim dogovoriti servis za Smart Forfour.",
        "Mehaničar: Koji je problem?",
        "Vlasnik: Treba mi provjera dizni i zamjena ulja u mjenjaču.",
        # рішення власника: приклад ситуації на СТО — частина діалогу
        ("Vlasnik", "Možete li provjeriti motor OM639?"),
    ]),
    ("Kod veterinara", "У ветеринара", "vet", "A1", [
        "Vlasnik: Dobar dan, naručeni smo za pregled.",
        "Veterinar: Kako se zove pas? Je li to australski ovčar?",
        "Vlasnik: Da, tako je. Došli smo na redovno cijepljenje.",
    ]),
    ("U MUP-u", "У MUP (міграційна служба)", "administration", "A1", [
        "Osoba: Dobar dan. Došao sam po novu dozvolu za boravak.",
        "Službenik: Vaša putovnica i potvrdnica, molim.",
        "Osoba: Izvolite. Trebam li potpisati ovdje?",
    ]),
    ("Tehnički sastanak", "Технічна нарада (IT)", "it_work", "A1", [
        "Arhitekt: Moramo migrirati bazu u oblak.",
        "DevOps: Provjerit ću CI/CD pipeline i resurse.",
    ]),
]

PHRASES = {
    "basics": ["Drago mi je.", "Hvala lijepa.", "Kako se kaže... na hrvatskom?", "Oprostite, ne razumijem.",
               "Kada mogu doći?", "laku noć i sanjajte lijepo"],
    "shopping": ["Dajte mi jednu vrećicu.", "Gdje je blagajna?", "Gdje mogu naći voće?", "Imate li sitnog?",
                 "Plaćam gotovinom.", "To je preskupo.", "Trebam hranu za psa.", "Trebam račun, molim.",
                 "imate li ovo u drugoj veličini"],
    "cafe_restaurant": ["Bilo je jako ukusno.", "Imate li slobodan stol?", "Kavu s mlijekom, molim.",
                        "Mogu li dobiti jelovnik?", "Mogu li platiti odvojeno?", "Ovo nije ono što sam naručio.",
                        "Račun, molim vas.", "Što preporučujete?", "Zadržite ostatak.", "Želim naručiti."],
    "transport": ["Gdje je autobusni kolodvor?", "Gdje je najbliža benzinska postaja?", "Imam mali auto.",
                  "Jednu kartu u jednom smjeru.", "Kada polazi autobus?", "Kako doći do centra?",
                  "Možete li mi pokazati na karti?", "Skrenite desno na semaforu."],
    "car_service": ["Trebam mehaničara za auto.", "Trebam zamjenu ulja u mjenjaču."],
    "housing": ["Bojler ne radi.", "Gdje je prekidač za struju?", "Internet je jako spor.", "Izgubio sam ključ.",
                "Kada možete doći popraviti?", "Klima uređaj curi.", "Možete li mi pomoći s ugovorom?",
                "Nema tople vode.", "Trebam platiti račune za režije."],
    "health": ["Boli me glava.", "Gdje je dežurna ljekarna?", "Imam alergiju na penicilin.", "Koliko puta dnevno?",
               "Ne osjećam se dobro.", "Pozovite hitnu pomoć!", "Trebam ići doktoru.", "Trebam li recept za ovo?",
               "Trebam nešto protiv prehlade.", "Trebam termin kod doktora.", "Imam visoku temperaturu.",
               "Trebam uputnicu za specijalista.", "Ovo je moja zdravstvena iskaznica.", "Imam jake bolove.",
               "Ovo je hitan slučaj."],
    "work": ["Radim od kuće.", "Bavim se IT uslugama.", "Treba mi bolovanje."],
    "it_work": ["Imamo li blokada za ovaj sprint?", "Koji je status ovog zadatka?",
                "Imamo li problem s memorijom na poslužitelju?"],
    "vet": ["Imate li hranu bez žitarica?", "Moj pas treba godišnje cjepivo."],
    "administration": ["Koji broj trebam uzeti za MUP?", "Predao sam zahtjev online.", "Otvaram paušalni obrt.",
                       "Ovo je rješenje o obrtu.", "Pečat mi ne treba."],
    "border": ["Izvolite dokumente.", "Ovo su papiri od auta.", "Samo smo u tranzitu.",
               "Nemam ništa za prijaviti.", "Ovo su moje osobne stvari."],
    "bank": ["Želim otvoriti poslovni račun.", "Koja je mjesečna naknada?"],
    "travel": ["Putujem u Zadar.", "Idem na odmor."],
    "small_talk": ["Znači...", "Mislim...", "Kužiš?", "Kako se zove...", "Pa..."],
}

EXPECTED_TOTAL = 125  # кількість рядків-речень у lexemes на 2026-10-12 (перевірено запитом)


def q(s: str) -> str:
    return "'" + s.replace("'", "''") + "'"


def phrase_type(lemma: str) -> str:
    if lemma.endswith("..."):
        return "filler"
    if lemma.endswith("?"):
        return "question"
    if lemma == lemma.lower() and not lemma[-1] in ".!?":
        return "chunk"
    return "phrase"


def main(out_path: str) -> None:
    dialogue_lemmas = []
    for _, _, _, _, turns in DIALOGUES:
        for t in turns:
            dialogue_lemmas.append(t[1] if isinstance(t, tuple) else t)
    phrase_lemmas = [l for items in PHRASES.values() for l in items]
    all_lemmas = dialogue_lemmas + phrase_lemmas
    assert len(all_lemmas) == len(set(all_lemmas)), "дублікати в специфікації"
    assert len(all_lemmas) == EXPECTED_TOTAL, f"очікувалось {EXPECTED_TOTAL}, у специфікації {len(all_lemmas)}"

    L = []
    w = L.append
    w("-- =====================================================================")
    w("-- 2026-10-12 · Перенесення речень і реплік з lexemes у conversations / phrases")
    w("-- Рішення власника: репліки діалогів → conversations + conversation_turns,")
    w("-- корисні фрази → phrases; «Možete li provjeriti motor OM639?» → діалог «Na servisu».")
    w("-- Потрібна міграція M6 (20261012180000_m6_phrases_conversation_meta.sql).")
    w("-- Згенеровано scripts/gen_move_phrases.py. Тексти і переклади беруться з lexemes.")
    w("-- Рядки в lexemes НЕ видаляються: status → 'DEPRECATED' (прогрес і історія зберігаються).")
    w("-- Резервна копія lexemes до змін: backup.lexemes_20261012_phrases.")
    w("-- Скрипт ідемпотентний і перевіряє себе: якщо щось не так — нічого не застосується.")
    w("-- =====================================================================")
    w("begin;")
    w("")
    w("create schema if not exists backup;")
    w("create table if not exists backup.lexemes_20261012_phrases as table public.lexemes;")
    w("")
    w("-- 0. Усі рядки, які переносимо, мають існувати в lexemes")
    w("do $$")
    w("declare missing text;")
    w("begin")
    w("  select string_agg(x, ' | ') into missing from unnest(array[")
    w("    " + ",\n    ".join(q(l) for l in all_lemmas))
    w("  ]) as x where not exists (select 1 from public.lexemes l where l.lemma = x);")
    w("  if missing is not null then raise exception 'Не знайдено в lexemes: %', missing; end if;")
    w("end $$;")
    w("")
    w("-- 1. Діалоги")
    w("do $$")
    w("declare conv uuid;")
    w("begin")
    for title_hr, title_ua, situation, level, turns in DIALOGUES:
        w(f"  -- {title_ua}")
        w(f"  select id into conv from public.conversations where title_hr = {q(title_hr)} and lesson_id is null and source = 'migrated_from_lexemes';")
        w("  if conv is null then")
        w("    insert into public.conversations (lesson_id, title_ua, title_hr, level, situation, status, source, order_index)")
        w(f"    values (null, {q(title_ua)}, {q(title_hr)}, {q(level)}, {q(situation)}, 'PUBLISHED', 'migrated_from_lexemes', 0)")
        w("    returning id into conv;")
        for i, t in enumerate(turns, start=1):
            if isinstance(t, tuple):
                speaker, lemma = t
                w("    insert into public.conversation_turns (conversation_id, speaker_name, hr_text, ua_translation, order_index)")
                w(f"    select conv, {q(speaker)}, l.lemma, l.ukrainian_translation, {i} from public.lexemes l where l.lemma = {q(lemma)};")
            else:
                speaker, text = t.split(": ", 1)
                w("    insert into public.conversation_turns (conversation_id, speaker_name, hr_text, ua_translation, order_index)")
                w(f"    select conv, {q(speaker)}, {q(text)}, regexp_replace(l.ukrainian_translation, '^[^:]{{1,20}}:\\s*', ''), {i}")
                w(f"    from public.lexemes l where l.lemma = {q(t)};")
        w("  end if;")
    w("end $$;")
    w("")
    w("-- 2. Фрази")
    for situation, items in PHRASES.items():
        w(f"-- {situation}")
        for lemma in items:
            w("insert into public.phrases (text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples, status, source, source_lexeme_id)")
            w(f"select l.lemma, l.normalized, l.ukrainian_translation, l.cefr, {q(situation)}, {q(phrase_type(lemma))}, coalesce(l.examples, '[]'::jsonb), 'PUBLISHED', 'migrated_from_lexemes', l.id")
            w(f"from public.lexemes l where l.lemma = {q(lemma)}")
            w("on conflict (lower(text_hr)) do nothing;")
    w("")
    w("-- 3. У lexemes — DEPRECATED (не видаляємо)")
    w("update public.lexemes set status = 'DEPRECATED', version = coalesce(version, 1) + 1")
    w("where status is distinct from 'DEPRECATED' and lemma = any (array[")
    w("  " + ",\n  ".join(q(l) for l in all_lemmas))
    w("]);")
    w("")
    w("-- 4. Самоперевірка: інакше відкат усієї транзакції")
    w("do $$")
    w("declare left_over int; n_phr int; n_conv int; n_turns int;")
    w("begin")
    w("  select count(*) into left_over from public.lexemes")
    w("  where status is distinct from 'DEPRECATED'")
    w("    and (lemma ~ ':' or lemma ~ '[.?!]$' or array_length(regexp_split_to_array(trim(lemma), '\\s+'), 1) > 4);")
    w("  select count(*) into n_phr from public.phrases where source = 'migrated_from_lexemes';")
    w("  select count(*) into n_conv from public.conversations where source = 'migrated_from_lexemes';")
    w("  select count(*) into n_turns from public.conversation_turns t join public.conversations c on c.id = t.conversation_id where c.source = 'migrated_from_lexemes';")
    w(f"  if left_over <> 0 then raise exception 'FAIL: у lexemes лишилось % речень', left_over; end if;")
    w(f"  if n_phr <> {len(phrase_lemmas)} then raise exception 'FAIL: фраз %, очікувалось {len(phrase_lemmas)}', n_phr; end if;")
    w(f"  if n_conv <> {len(DIALOGUES)} then raise exception 'FAIL: діалогів %, очікувалось {len(DIALOGUES)}', n_conv; end if;")
    w(f"  if n_turns <> {len(dialogue_lemmas)} then raise exception 'FAIL: реплік %, очікувалось {len(dialogue_lemmas)}', n_turns; end if;")
    w("  raise notice 'OK: % фраз, % діалогів, % реплік; речень у lexemes не лишилось', n_phr, n_conv, n_turns;")
    w("end $$;")
    w("")
    w("commit;")
    w("")
    w(f"select 'OK: {len(phrase_lemmas)} фраз, {len(DIALOGUES)} діалогів, {len(dialogue_lemmas)} реплік' as result;")

    with open(out_path, "w", encoding="utf-8", newline="\r\n") as f:
        f.write("\n".join(L) + "\n")
    print(f"dialogues={len(DIALOGUES)} turns={len(dialogue_lemmas)} phrases={len(phrase_lemmas)} total={len(all_lemmas)}")


if __name__ == "__main__":
    main(sys.argv[1])
