insert into public.lexemes (lemma, normalized, language, cefr, ukrainian_translation, status)
select w, translate(w,'čćđšž','ccdsz'), 'hr', 'A1', 'тест', 'PUBLISHED'
from unnest(array['brak','godina','istina','jagoda','pismo','proljev','riječ','stan','stolica','težak','težina','trbuh','trgovina','voljeti','vrijeme','zavod za zapošljavanje','šutjeti']) w
where not exists (select 1 from public.lexemes l where lower(l.lemma) = w);
