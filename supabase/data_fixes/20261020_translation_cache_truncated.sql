-- =====================================================================
-- «Мені потрібно сказати…»: прибрати з кешу обірвані переклади · 2026-10-20
--
-- Причина: модель gemini-3.6-flash «думає» перед відповіддю, і ці токени входили в ліміт 200 —
-- переклад обривався: «Ваша собачка дуже красива.» → «Vaš je», «Ваша собачка дуже гарна» → «Vaš je psić jako».
-- Обірвані переклади потрапили в translation_cache, і застосунок показував їх знову з кешу.
-- Код виправлено (lib/ai-fallback.ts, lib/ai-gemini.ts): запас токенів на роздуми + обірвана відповідь не зберігається.
--
-- Що робить файл: копіює рядки кешу від gemini-3.6-flash, створені до 2026-10-20, у backup.translation_cache_20261020
-- і видаляє їх із кешу (у робочій базі на 2026-10-20 таких рядків 2). Наступного разу фразу перекладе AI заново.
-- Видалення погоджує власник (CLAUDE.md): запуск цього файлу = згода. Повторний запуск нічого не змінює.
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

create schema if not exists backup;
create table if not exists backup.translation_cache_20261020 (like public.translation_cache including defaults);
do $$ begin
  if not exists (select 1 from pg_constraint where conname = 'translation_cache_20261020_pkey') then
    alter table backup.translation_cache_20261020 add constraint translation_cache_20261020_pkey primary key (id);
  end if;
end $$;
revoke all on backup.translation_cache_20261020 from anon, authenticated;

insert into backup.translation_cache_20261020
select * from public.translation_cache
 where model = 'gemini-3.6-flash' and created_at < '2026-10-20'
on conflict (id) do nothing;

delete from public.translation_cache c
 where c.model = 'gemini-3.6-flash' and c.created_at < '2026-10-20'
   and exists (select 1 from backup.translation_cache_20261020 b where b.id = c.id);

do $$
declare v_left int; v_saved int;
begin
  select count(*) into v_left from public.translation_cache where model = 'gemini-3.6-flash' and created_at < '2026-10-20';
  select count(*) into v_saved from backup.translation_cache_20261020;
  if v_left > 0 then raise exception 'У кеші лишилось обірваних перекладів: %', v_left; end if;
  raise notice 'Готово: обірвані переклади прибрано з кешу (копія — backup.translation_cache_20261020, рядків: %)', v_saved;
end $$;

commit;
