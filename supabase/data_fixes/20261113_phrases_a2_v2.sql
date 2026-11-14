-- =====================================================================
-- Фрази A2 (public.phrases) · програма A2 v2 · phrases_a2_v2 · 2026-11-13
-- Згенеровано: python3 -B scripts/gen_phrases_a2.py (не редагуйте вручну).
-- Запускає workflow «Apply SQL (production)» після мержу й Approve власника.
--   * 56 фраз рівня A2, по 4 на кожен із 14 модулів: готові висловлювання для туризму, навчання,
--     роботи, установ, здоров'я, авто, неприємностей, звичаїв, життя українців у Хорватії, планів.
--   * Ситуація — код з lib/situations.ts (фрази з'являються в розділі «Ситуації»).
--   * Мітки (LEARNING_SPEC §18): register, regionality = general, usage_tags.
--   * Статус PUBLISHED — бета, як уроки A2. Наявні фрази не змінюються; повторний запуск нічого не додає.
-- =====================================================================

begin;

do $phr$
declare v_new int;
begin
  insert into public.phrases (id, text_hr, normalized, ukrainian_translation, cefr, situation, phrase_type, examples,
                              status, source, register, regionality, usage_tags, published_at)
  select x.id, x.text_hr, x.normalized, x.ukrainian_translation, 'A2', x.situation, x.phrase_type, '[]'::jsonb,
         'PUBLISHED', 'claude_phrases_a2_v2', x.register, x.regionality, x.usage_tags, now()
  from jsonb_to_recordset($json$[
 {
  "id": "16c366e5-b5fb-5c8d-aba0-9d084dde9cbf",
  "text_hr": "Je li doručak uključen u cijenu?",
  "normalized": "je li dorucak ukljucen u cijenu?",
  "ukrainian_translation": "Сніданок включено у вартість?",
  "situation": "travel",
  "phrase_type": "question",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "a807c025-2b1e-57ee-b033-8ac88bfe0020",
  "text_hr": "Možemo li se odjaviti malo kasnije?",
  "normalized": "mozemo li se odjaviti malo kasnije?",
  "ukrainian_translation": "Чи можемо ми виселитися трохи пізніше?",
  "situation": "travel",
  "phrase_type": "question",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "15252bed-2ac7-5910-b1bc-c9cf4ff5458e",
  "text_hr": "Klima-uređaj u sobi ne funkcionira.",
  "normalized": "klima-uredaj u sobi ne funkcionira.",
  "ukrainian_translation": "Кондиціонер у номері не працює.",
  "situation": "travel",
  "phrase_type": "phrase",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "8ae65528-4a61-5e26-8a94-637b8554818e",
  "text_hr": "Kada polazi sljedeći trajekt za Hvar?",
  "normalized": "kada polazi sljedeci trajekt za hvar?",
  "ukrainian_translation": "Коли відходить наступний пором на Хвар?",
  "situation": "travel",
  "phrase_type": "question",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "4d558853-6530-54c6-b57e-698a6ef6cc4c",
  "text_hr": "Želio bih se upisati na tečaj hrvatskog.",
  "normalized": "zelio bih se upisati na tecaj hrvatskog.",
  "ukrainian_translation": "Я хотів би записатися на курс хорватської.",
  "situation": "administration",
  "phrase_type": "phrase",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "0316cbaf-3347-51d6-9920-300958b365f4",
  "text_hr": "Kako mogu priznati svoju diplomu?",
  "normalized": "kako mogu priznati svoju diplomu?",
  "ukrainian_translation": "Як мені визнати свій диплом?",
  "situation": "administration",
  "phrase_type": "question",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "c62a4f9d-a3df-5bb8-9e50-3f6f24cb08c0",
  "text_hr": "Moje dijete danas neće doći u školu.",
  "normalized": "moje dijete danas nece doci u skolu.",
  "ukrainian_translation": "Моя дитина сьогодні не прийде до школи.",
  "situation": "basics",
  "phrase_type": "phrase",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "fc596fd4-e0a8-570f-a52e-c705a86a4861",
  "text_hr": "Možete li ponoviti malo sporije?",
  "normalized": "mozete li ponoviti malo sporije?",
  "ukrainian_translation": "Чи можете повторити трохи повільніше?",
  "situation": "basics",
  "phrase_type": "question",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "d83d3ecc-670b-545a-8850-41d6f8003bfb",
  "text_hr": "Kad sam bila mala, živjela sam na selu.",
  "normalized": "kad sam bila mala, zivjela sam na selu.",
  "ukrainian_translation": "Коли я була маленькою, я жила в селі.",
  "situation": "small_talk",
  "phrase_type": "phrase",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "ca5ce20a-fd6f-58ce-8781-1b8cd5228a49",
  "text_hr": "Sjećaš li se kad smo se upoznali?",
  "normalized": "sjecas li se kad smo se upoznali?",
  "ukrainian_translation": "Пам’ятаєш, коли ми познайомилися?",
  "situation": "small_talk",
  "phrase_type": "question",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "3ac49ae1-e040-508b-a3ba-5934e0c2e888",
  "text_hr": "U Hrvatskoj živim već tri godine.",
  "normalized": "u hrvatskoj zivim vec tri godine.",
  "ukrainian_translation": "Я живу в Хорватії вже три роки.",
  "situation": "small_talk",
  "phrase_type": "phrase",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "d36f2d34-e4b0-50c5-94c5-1f085ec7993b",
  "text_hr": "Nikad to neću zaboraviti.",
  "normalized": "nikad to necu zaboraviti.",
  "ukrainian_translation": "Я ніколи цього не забуду.",
  "situation": "small_talk",
  "phrase_type": "phrase",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "dc1f9015-81ff-5353-b2dc-88ce1d8d243f",
  "text_hr": "Čestitam od srca!",
  "normalized": "cestitam od srca!",
  "ukrainian_translation": "Щиро вітаю!",
  "situation": "small_talk",
  "phrase_type": "phrase",
  "register": "standard",
  "regionality": "general",
  "usage_tags": [
   "idiom"
  ]
 },
 {
  "id": "ec6cbf7a-fa19-525f-90d2-5f3116c68c97",
  "text_hr": "Iskrena sućut.",
  "normalized": "iskrena sucut.",
  "ukrainian_translation": "Щирі співчуття.",
  "situation": "small_talk",
  "phrase_type": "phrase",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "67243969-c3ac-5239-b615-1355116ca6ca",
  "text_hr": "Ispričavam se, nisam to tako mislio.",
  "normalized": "ispricavam se, nisam to tako mislio.",
  "ukrainian_translation": "Перепрошую, я не це мав на увазі.",
  "situation": "small_talk",
  "phrase_type": "phrase",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "e270a39f-b1da-5aed-94fe-8fbc36b8165e",
  "text_hr": "Možete li, molim vas, utišati glazbu?",
  "normalized": "mozete li, molim vas, utisati glazbu?",
  "ukrainian_translation": "Чи не могли б ви, будь ласка, зробити музику тихіше?",
  "situation": "housing",
  "phrase_type": "question",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "90621590-9684-541c-88f4-d2c565e8c1eb",
  "text_hr": "Možemo li pomaknuti rok na petak?",
  "normalized": "mozemo li pomaknuti rok na petak?",
  "ukrainian_translation": "Чи можемо ми перенести термін на п’ятницю?",
  "situation": "work",
  "phrase_type": "question",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "42eaf6d8-1b3c-5d4d-b69a-4523e0c83eda",
  "text_hr": "U privitku Vam šaljem traženi dokument.",
  "normalized": "u privitku vam saljem trazeni dokument.",
  "ukrainian_translation": "У вкладенні надсилаю вам потрібний документ.",
  "situation": "work",
  "phrase_type": "phrase",
  "register": "formal",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "391f9145-b35a-564e-abcf-e6c9466e95f6",
  "text_hr": "Mogu li razgovarati s gospođom Horvat?",
  "normalized": "mogu li razgovarati s gospodom horvat?",
  "ukrainian_translation": "Чи можу я поговорити з пані Горват?",
  "situation": "work",
  "phrase_type": "question",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "b6b1a755-fe62-583a-887b-d427c448c511",
  "text_hr": "Želio bih iskoristiti preostale dane godišnjeg.",
  "normalized": "zelio bih iskoristiti preostale dane godisnjeg.",
  "ukrainian_translation": "Я хотів би використати решту днів відпустки.",
  "situation": "work",
  "phrase_type": "phrase",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "461d161c-6412-5a3b-9a8d-9a66eb2bc99e",
  "text_hr": "Htjela bih se naručiti za šišanje.",
  "normalized": "htjela bih se naruciti za sisanje.",
  "ukrainian_translation": "Я хотіла б записатися на стрижку.",
  "situation": "shopping",
  "phrase_type": "phrase",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "de9ac870-b3d1-598f-b675-bf456f66cc54",
  "text_hr": "Kada će biti gotovo?",
  "normalized": "kada ce biti gotovo?",
  "ukrainian_translation": "Коли буде готово?",
  "situation": "shopping",
  "phrase_type": "question",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "107bd477-4eb8-5123-a558-c06242bd05cf",
  "text_hr": "Trebam ovjeriti potpis kod javnog bilježnika.",
  "normalized": "trebam ovjeriti potpis kod javnog biljeznika.",
  "ukrainian_translation": "Мені треба засвідчити підпис у нотаріуса.",
  "situation": "administration",
  "phrase_type": "phrase",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "5a3dc035-3266-5662-a254-45977d831c5c",
  "text_hr": "Gdje mogu dobiti potvrdu o OIB-u?",
  "normalized": "gdje mogu dobiti potvrdu o oib-u?",
  "ukrainian_translation": "Де я можу отримати довідку про OIB?",
  "situation": "administration",
  "phrase_type": "question",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "d4460d6b-d0fb-5070-8d7f-8f99e865ecd2",
  "text_hr": "Trebam se naručiti kod izabranog liječnika.",
  "normalized": "trebam se naruciti kod izabranog lijecnika.",
  "ukrainian_translation": "Мені треба записатися до свого сімейного лікаря.",
  "situation": "health",
  "phrase_type": "phrase",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "abed4ae8-c1fb-537c-bb4f-b5db73a2ea5d",
  "text_hr": "Vrti mi se u glavi.",
  "normalized": "vrti mi se u glavi.",
  "ukrainian_translation": "У мене паморочиться в голові.",
  "situation": "health",
  "phrase_type": "phrase",
  "register": "standard",
  "regionality": "general",
  "usage_tags": [
   "idiom"
  ]
 },
 {
  "id": "6e85f708-c21f-57ce-80bb-81851b4349c8",
  "text_hr": "Moram otvoriti bolovanje radi njege djeteta.",
  "normalized": "moram otvoriti bolovanje radi njege djeteta.",
  "ukrainian_translation": "Мені треба відкрити лікарняний по догляду за дитиною.",
  "situation": "health",
  "phrase_type": "phrase",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "4a3938f2-adbe-5cef-a8b9-4ebcb6050446",
  "text_hr": "Kada mogu doći po nalaze?",
  "normalized": "kada mogu doci po nalaze?",
  "ukrainian_translation": "Коли можна прийти по результати аналізів?",
  "situation": "health",
  "phrase_type": "question",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "66156e21-c3a5-5c72-b90b-843a87d3335b",
  "text_hr": "Kako mogu zamijeniti stranu vozačku dozvolu?",
  "normalized": "kako mogu zamijeniti stranu vozacku dozvolu?",
  "ukrainian_translation": "Як мені обміняти іноземне посвідчення водія?",
  "situation": "administration",
  "phrase_type": "question",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "eb7571c5-d1c6-58fc-b00b-7db60ac8e477",
  "text_hr": "Netko mi je udario auto na parkiralištu.",
  "normalized": "netko mi je udario auto na parkiralistu.",
  "ukrainian_translation": "Хтось ударив мою машину на парковці.",
  "situation": "transport",
  "phrase_type": "phrase",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "5d703220-b9b5-58f5-b5c8-be0bfa102930",
  "text_hr": "Kada auto mora na tehnički pregled?",
  "normalized": "kada auto mora na tehnicki pregled?",
  "ukrainian_translation": "Коли машина має проходити техогляд?",
  "situation": "car_service",
  "phrase_type": "question",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "234c2798-2f6e-5e95-b361-db453df3fafc",
  "text_hr": "Gdje se plaća cestarina?",
  "normalized": "gdje se placa cestarina?",
  "ukrainian_translation": "Де платять за проїзд автомагістраллю?",
  "situation": "transport",
  "phrase_type": "question",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "f1d610af-fe19-5d3b-ad24-fa71e1650767",
  "text_hr": "Gdje mogu prijaviti gubitak dokumenata?",
  "normalized": "gdje mogu prijaviti gubitak dokumenata?",
  "ukrainian_translation": "Де я можу заявити про втрату документів?",
  "situation": "administration",
  "phrase_type": "question",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "37f6c320-7add-5083-b193-2d1440435191",
  "text_hr": "Ukrali su mi torbu.",
  "normalized": "ukrali su mi torbu.",
  "ukrainian_translation": "У мене вкрали сумку.",
  "situation": "basics",
  "phrase_type": "phrase",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "bac2e252-bfc2-5399-b8db-358a473c89a6",
  "text_hr": "U koju kantu ide plastika?",
  "normalized": "u koju kantu ide plastika?",
  "ukrainian_translation": "У який контейнер викидати пластик?",
  "situation": "housing",
  "phrase_type": "question",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "ab09e82f-877a-548e-94b1-2fbd120aee32",
  "text_hr": "U našoj ulici nema struje.",
  "normalized": "u nasoj ulici nema struje.",
  "ukrainian_translation": "На нашій вулиці немає світла.",
  "situation": "housing",
  "phrase_type": "phrase",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "c5627ae6-67f0-5576-af32-a912eb291f87",
  "text_hr": "Po meni, film je bio odličan.",
  "normalized": "po meni, film je bio odlican.",
  "ukrainian_translation": "На мою думку, фільм був чудовий.",
  "situation": "small_talk",
  "phrase_type": "phrase",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "89e24de3-1055-5b73-8c2b-0a110e044206",
  "text_hr": "Ne slažem se s tobom.",
  "normalized": "ne slazem se s tobom.",
  "ukrainian_translation": "Я з тобою не згоден.",
  "situation": "small_talk",
  "phrase_type": "phrase",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "ce59f8c3-aac7-5c57-a09d-9b980c1a7d2b",
  "text_hr": "Je li oglas još aktualan?",
  "normalized": "je li oglas jos aktualan?",
  "ukrainian_translation": "Оголошення ще актуальне?",
  "situation": "shopping",
  "phrase_type": "question",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "8107c12f-8df6-5dcb-88cb-09ac685dfe59",
  "text_hr": "Što ti misliš o tome?",
  "normalized": "sto ti mislis o tome?",
  "ukrainian_translation": "А ти що про це думаєш?",
  "situation": "small_talk",
  "phrase_type": "question",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "5d8d02cc-9fba-5358-a657-96833a6aef4d",
  "text_hr": "Možemo li se tikati?",
  "normalized": "mozemo li se tikati?",
  "ukrainian_translation": "Можемо перейти на «ти»?",
  "situation": "small_talk",
  "phrase_type": "question",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "0d122ccd-8903-544c-aeef-62c791e90086",
  "text_hr": "Hvala na gostoprimstvu!",
  "normalized": "hvala na gostoprimstvu!",
  "ukrainian_translation": "Дякую за гостинність!",
  "situation": "small_talk",
  "phrase_type": "phrase",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "8e0f9dc5-d1dc-54dd-afde-1a408ddf7ca1",
  "text_hr": "Što mi preporučujete posjetiti u Istri?",
  "normalized": "sto mi preporucujete posjetiti u istri?",
  "ukrainian_translation": "Що порадите відвідати в Істрії?",
  "situation": "travel",
  "phrase_type": "question",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "85674999-2f22-5367-be37-ae132dcb6630",
  "text_hr": "Ovo je tipično slavonsko jelo.",
  "normalized": "ovo je tipicno slavonsko jelo.",
  "ukrainian_translation": "Це типова славонська страва.",
  "situation": "cafe_restaurant",
  "phrase_type": "phrase",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "d53065b0-f99e-5226-8d9d-4d0342aa808f",
  "text_hr": "Imam status privremene zaštite.",
  "normalized": "imam status privremene zastite.",
  "ukrainian_translation": "Я маю статус тимчасового захисту.",
  "situation": "administration",
  "phrase_type": "phrase",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "1d744850-1791-5ccc-a360-4af6d2739523",
  "text_hr": "Moram produljiti iskaznicu stranca.",
  "normalized": "moram produljiti iskaznicu stranca.",
  "ukrainian_translation": "Мені треба продовжити посвідку іноземця.",
  "situation": "administration",
  "phrase_type": "phrase",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "96cc378d-27fd-50d3-aaea-426bc1d1c760",
  "text_hr": "Koliko košta slanje paketa u Ukrajinu?",
  "normalized": "koliko kosta slanje paketa u ukrajinu?",
  "ukrainian_translation": "Скільки коштує надіслати посилку в Україну?",
  "situation": "shopping",
  "phrase_type": "question",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "554bd433-44d9-591d-9a17-6d9b0618c3f1",
  "text_hr": "Moja djeca govore hrvatski bolje od mene.",
  "normalized": "moja djeca govore hrvatski bolje od mene.",
  "ukrainian_translation": "Мої діти говорять хорватською краще за мене.",
  "situation": "small_talk",
  "phrase_type": "phrase",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "2f17f897-3010-5124-aa83-508198f19707",
  "text_hr": "Odgovara li ti u subotu u deset?",
  "normalized": "odgovara li ti u subotu u deset?",
  "ukrainian_translation": "Тобі підходить у суботу о десятій?",
  "situation": "small_talk",
  "phrase_type": "question",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "3391fb43-67d2-5a37-b33a-b50ecff49502",
  "text_hr": "Možemo li to pomaknuti na sutra?",
  "normalized": "mozemo li to pomaknuti na sutra?",
  "ukrainian_translation": "Можемо перенести це на завтра?",
  "situation": "small_talk",
  "phrase_type": "question",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "6bce598d-afff-519c-a226-b46d1c0d0243",
  "text_hr": "Javit ću ti čim budem znao.",
  "normalized": "javit cu ti cim budem znao.",
  "ukrainian_translation": "Я тобі напишу, щойно знатиму.",
  "situation": "small_talk",
  "phrase_type": "phrase",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "f2802515-87af-540f-9fc5-f61cb57f5648",
  "text_hr": "Volio bih jednog dana otvoriti vlastiti posao.",
  "normalized": "volio bih jednog dana otvoriti vlastiti posao.",
  "ukrainian_translation": "Я хотів би колись відкрити власну справу.",
  "situation": "work",
  "phrase_type": "phrase",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "b8552991-4120-521b-aebf-b776aa35a8fe",
  "text_hr": "Oprostite, možete li mi to objasniti jednostavnije?",
  "normalized": "oprostite, mozete li mi to objasniti jednostavnije?",
  "ukrainian_translation": "Перепрошую, можете пояснити мені це простіше?",
  "situation": "basics",
  "phrase_type": "question",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "6725e144-3b6a-58fd-b62b-4e5cad661389",
  "text_hr": "Jesam li vas dobro razumio?",
  "normalized": "jesam li vas dobro razumio?",
  "ukrainian_translation": "Я вас правильно зрозумів?",
  "situation": "basics",
  "phrase_type": "question",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "7470b6c1-e4a8-52ad-ac2c-50e00722c3ec",
  "text_hr": "Kome se mogu obratiti za pomoć?",
  "normalized": "kome se mogu obratiti za pomoc?",
  "ukrainian_translation": "До кого я можу звернутися по допомогу?",
  "situation": "administration",
  "phrase_type": "question",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 },
 {
  "id": "4eafb6e9-f123-5e52-b323-aed2f3d7fafe",
  "text_hr": "Snalazim se sve bolje.",
  "normalized": "snalazim se sve bolje.",
  "ukrainian_translation": "Я даю собі раду дедалі краще.",
  "situation": "small_talk",
  "phrase_type": "phrase",
  "register": "standard",
  "regionality": "general",
  "usage_tags": []
 }
]$json$::jsonb)
       as x(id uuid, text_hr text, normalized text, ukrainian_translation text, situation text, phrase_type text,
            register text, regionality text, usage_tags text[])
  on conflict do nothing;
  get diagnostics v_new = row_count;
  raise notice 'Додано фраз: %', v_new;
end $phr$;

-- Журнал перевірки (один запис на фразу)
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'phrase', p.id, null, p.status, 'auto_passed', 'ai', '[]'::jsonb, 'Бета: фрази A2 за програмою A2 v2 (4 на модуль), phrases_a2_v2 2026-11-13. Потрібна перевірка носієм.'
from public.phrases p
where p.id in ('16c366e5-b5fb-5c8d-aba0-9d084dde9cbf', 'a807c025-2b1e-57ee-b033-8ac88bfe0020', '15252bed-2ac7-5910-b1bc-c9cf4ff5458e', '8ae65528-4a61-5e26-8a94-637b8554818e', '4d558853-6530-54c6-b57e-698a6ef6cc4c', '0316cbaf-3347-51d6-9920-300958b365f4', 'c62a4f9d-a3df-5bb8-9e50-3f6f24cb08c0', 'fc596fd4-e0a8-570f-a52e-c705a86a4861', 'd83d3ecc-670b-545a-8850-41d6f8003bfb', 'ca5ce20a-fd6f-58ce-8781-1b8cd5228a49', '3ac49ae1-e040-508b-a3ba-5934e0c2e888', 'd36f2d34-e4b0-50c5-94c5-1f085ec7993b', 'dc1f9015-81ff-5353-b2dc-88ce1d8d243f', 'ec6cbf7a-fa19-525f-90d2-5f3116c68c97', '67243969-c3ac-5239-b615-1355116ca6ca', 'e270a39f-b1da-5aed-94fe-8fbc36b8165e', '90621590-9684-541c-88f4-d2c565e8c1eb', '42eaf6d8-1b3c-5d4d-b69a-4523e0c83eda', '391f9145-b35a-564e-abcf-e6c9466e95f6', 'b6b1a755-fe62-583a-887b-d427c448c511', '461d161c-6412-5a3b-9a8d-9a66eb2bc99e', 'de9ac870-b3d1-598f-b675-bf456f66cc54', '107bd477-4eb8-5123-a558-c06242bd05cf', '5a3dc035-3266-5662-a254-45977d831c5c', 'd4460d6b-d0fb-5070-8d7f-8f99e865ecd2', 'abed4ae8-c1fb-537c-bb4f-b5db73a2ea5d', '6e85f708-c21f-57ce-80bb-81851b4349c8', '4a3938f2-adbe-5cef-a8b9-4ebcb6050446', '66156e21-c3a5-5c72-b90b-843a87d3335b', 'eb7571c5-d1c6-58fc-b00b-7db60ac8e477', '5d703220-b9b5-58f5-b5c8-be0bfa102930', '234c2798-2f6e-5e95-b361-db453df3fafc', 'f1d610af-fe19-5d3b-ad24-fa71e1650767', '37f6c320-7add-5083-b193-2d1440435191', 'bac2e252-bfc2-5399-b8db-358a473c89a6', 'ab09e82f-877a-548e-94b1-2fbd120aee32', 'c5627ae6-67f0-5576-af32-a912eb291f87', '89e24de3-1055-5b73-8c2b-0a110e044206', 'ce59f8c3-aac7-5c57-a09d-9b980c1a7d2b', '8107c12f-8df6-5dcb-88cb-09ac685dfe59', '5d8d02cc-9fba-5358-a657-96833a6aef4d', '0d122ccd-8903-544c-aeef-62c791e90086', '8e0f9dc5-d1dc-54dd-afde-1a408ddf7ca1', '85674999-2f22-5367-be37-ae132dcb6630', 'd53065b0-f99e-5226-8d9d-4d0342aa808f', '1d744850-1791-5ccc-a360-4af6d2739523', '96cc378d-27fd-50d3-aaea-426bc1d1c760', '554bd433-44d9-591d-9a17-6d9b0618c3f1', '2f17f897-3010-5124-aa83-508198f19707', '3391fb43-67d2-5a37-b33a-b50ecff49502', '6bce598d-afff-519c-a226-b46d1c0d0243', 'f2802515-87af-540f-9fc5-f61cb57f5648', 'b8552991-4120-521b-aebf-b776aa35a8fe', '6725e144-3b6a-58fd-b62b-4e5cad661389', '7470b6c1-e4a8-52ad-ac2c-50e00722c3ec', '4eafb6e9-f123-5e52-b323-aed2f3d7fafe')
  and not exists (select 1 from public.content_reviews c where c.entity_id = p.id and c.notes = 'Бета: фрази A2 за програмою A2 v2 (4 на модуль), phrases_a2_v2 2026-11-13. Потрібна перевірка носієм.');

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_total int; v_bad int;
begin
  select count(*) into v_total from public.phrases
   where id in ('16c366e5-b5fb-5c8d-aba0-9d084dde9cbf', 'a807c025-2b1e-57ee-b033-8ac88bfe0020', '15252bed-2ac7-5910-b1bc-c9cf4ff5458e', '8ae65528-4a61-5e26-8a94-637b8554818e', '4d558853-6530-54c6-b57e-698a6ef6cc4c', '0316cbaf-3347-51d6-9920-300958b365f4', 'c62a4f9d-a3df-5bb8-9e50-3f6f24cb08c0', 'fc596fd4-e0a8-570f-a52e-c705a86a4861', 'd83d3ecc-670b-545a-8850-41d6f8003bfb', 'ca5ce20a-fd6f-58ce-8781-1b8cd5228a49', '3ac49ae1-e040-508b-a3ba-5934e0c2e888', 'd36f2d34-e4b0-50c5-94c5-1f085ec7993b', 'dc1f9015-81ff-5353-b2dc-88ce1d8d243f', 'ec6cbf7a-fa19-525f-90d2-5f3116c68c97', '67243969-c3ac-5239-b615-1355116ca6ca', 'e270a39f-b1da-5aed-94fe-8fbc36b8165e', '90621590-9684-541c-88f4-d2c565e8c1eb', '42eaf6d8-1b3c-5d4d-b69a-4523e0c83eda', '391f9145-b35a-564e-abcf-e6c9466e95f6', 'b6b1a755-fe62-583a-887b-d427c448c511', '461d161c-6412-5a3b-9a8d-9a66eb2bc99e', 'de9ac870-b3d1-598f-b675-bf456f66cc54', '107bd477-4eb8-5123-a558-c06242bd05cf', '5a3dc035-3266-5662-a254-45977d831c5c', 'd4460d6b-d0fb-5070-8d7f-8f99e865ecd2', 'abed4ae8-c1fb-537c-bb4f-b5db73a2ea5d', '6e85f708-c21f-57ce-80bb-81851b4349c8', '4a3938f2-adbe-5cef-a8b9-4ebcb6050446', '66156e21-c3a5-5c72-b90b-843a87d3335b', 'eb7571c5-d1c6-58fc-b00b-7db60ac8e477', '5d703220-b9b5-58f5-b5c8-be0bfa102930', '234c2798-2f6e-5e95-b361-db453df3fafc', 'f1d610af-fe19-5d3b-ad24-fa71e1650767', '37f6c320-7add-5083-b193-2d1440435191', 'bac2e252-bfc2-5399-b8db-358a473c89a6', 'ab09e82f-877a-548e-94b1-2fbd120aee32', 'c5627ae6-67f0-5576-af32-a912eb291f87', '89e24de3-1055-5b73-8c2b-0a110e044206', 'ce59f8c3-aac7-5c57-a09d-9b980c1a7d2b', '8107c12f-8df6-5dcb-88cb-09ac685dfe59', '5d8d02cc-9fba-5358-a657-96833a6aef4d', '0d122ccd-8903-544c-aeef-62c791e90086', '8e0f9dc5-d1dc-54dd-afde-1a408ddf7ca1', '85674999-2f22-5367-be37-ae132dcb6630', 'd53065b0-f99e-5226-8d9d-4d0342aa808f', '1d744850-1791-5ccc-a360-4af6d2739523', '96cc378d-27fd-50d3-aaea-426bc1d1c760', '554bd433-44d9-591d-9a17-6d9b0618c3f1', '2f17f897-3010-5124-aa83-508198f19707', '3391fb43-67d2-5a37-b33a-b50ecff49502', '6bce598d-afff-519c-a226-b46d1c0d0243', 'f2802515-87af-540f-9fc5-f61cb57f5648', 'b8552991-4120-521b-aebf-b776aa35a8fe', '6725e144-3b6a-58fd-b62b-4e5cad661389', '7470b6c1-e4a8-52ad-ac2c-50e00722c3ec', '4eafb6e9-f123-5e52-b323-aed2f3d7fafe') and cefr = 'A2' and status = 'PUBLISHED' and source = 'claude_phrases_a2_v2';
  select count(*) into v_bad from public.phrases
   where id in ('16c366e5-b5fb-5c8d-aba0-9d084dde9cbf', 'a807c025-2b1e-57ee-b033-8ac88bfe0020', '15252bed-2ac7-5910-b1bc-c9cf4ff5458e', '8ae65528-4a61-5e26-8a94-637b8554818e', '4d558853-6530-54c6-b57e-698a6ef6cc4c', '0316cbaf-3347-51d6-9920-300958b365f4', 'c62a4f9d-a3df-5bb8-9e50-3f6f24cb08c0', 'fc596fd4-e0a8-570f-a52e-c705a86a4861', 'd83d3ecc-670b-545a-8850-41d6f8003bfb', 'ca5ce20a-fd6f-58ce-8781-1b8cd5228a49', '3ac49ae1-e040-508b-a3ba-5934e0c2e888', 'd36f2d34-e4b0-50c5-94c5-1f085ec7993b', 'dc1f9015-81ff-5353-b2dc-88ce1d8d243f', 'ec6cbf7a-fa19-525f-90d2-5f3116c68c97', '67243969-c3ac-5239-b615-1355116ca6ca', 'e270a39f-b1da-5aed-94fe-8fbc36b8165e', '90621590-9684-541c-88f4-d2c565e8c1eb', '42eaf6d8-1b3c-5d4d-b69a-4523e0c83eda', '391f9145-b35a-564e-abcf-e6c9466e95f6', 'b6b1a755-fe62-583a-887b-d427c448c511', '461d161c-6412-5a3b-9a8d-9a66eb2bc99e', 'de9ac870-b3d1-598f-b675-bf456f66cc54', '107bd477-4eb8-5123-a558-c06242bd05cf', '5a3dc035-3266-5662-a254-45977d831c5c', 'd4460d6b-d0fb-5070-8d7f-8f99e865ecd2', 'abed4ae8-c1fb-537c-bb4f-b5db73a2ea5d', '6e85f708-c21f-57ce-80bb-81851b4349c8', '4a3938f2-adbe-5cef-a8b9-4ebcb6050446', '66156e21-c3a5-5c72-b90b-843a87d3335b', 'eb7571c5-d1c6-58fc-b00b-7db60ac8e477', '5d703220-b9b5-58f5-b5c8-be0bfa102930', '234c2798-2f6e-5e95-b361-db453df3fafc', 'f1d610af-fe19-5d3b-ad24-fa71e1650767', '37f6c320-7add-5083-b193-2d1440435191', 'bac2e252-bfc2-5399-b8db-358a473c89a6', 'ab09e82f-877a-548e-94b1-2fbd120aee32', 'c5627ae6-67f0-5576-af32-a912eb291f87', '89e24de3-1055-5b73-8c2b-0a110e044206', 'ce59f8c3-aac7-5c57-a09d-9b980c1a7d2b', '8107c12f-8df6-5dcb-88cb-09ac685dfe59', '5d8d02cc-9fba-5358-a657-96833a6aef4d', '0d122ccd-8903-544c-aeef-62c791e90086', '8e0f9dc5-d1dc-54dd-afde-1a408ddf7ca1', '85674999-2f22-5367-be37-ae132dcb6630', 'd53065b0-f99e-5226-8d9d-4d0342aa808f', '1d744850-1791-5ccc-a360-4af6d2739523', '96cc378d-27fd-50d3-aaea-426bc1d1c760', '554bd433-44d9-591d-9a17-6d9b0618c3f1', '2f17f897-3010-5124-aa83-508198f19707', '3391fb43-67d2-5a37-b33a-b50ecff49502', '6bce598d-afff-519c-a226-b46d1c0d0243', 'f2802515-87af-540f-9fc5-f61cb57f5648', 'b8552991-4120-521b-aebf-b776aa35a8fe', '6725e144-3b6a-58fd-b62b-4e5cad661389', '7470b6c1-e4a8-52ad-ac2c-50e00722c3ec', '4eafb6e9-f123-5e52-b323-aed2f3d7fafe') and (register is null or regionality is null or usage_tags is null or situation is null);
  if v_total <> 56 then
    raise exception 'Фраз A2 з цього пакета %, очікувалось 56 (така фраза вже є з іншим id?)', v_total;
  end if;
  if v_bad > 0 then raise exception '% фраз без міток чи ситуації', v_bad; end if;
  raise notice 'Готово: фраз A2 — % (по 4 на модуль)', v_total;
end $$;

commit;
