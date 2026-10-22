-- Troca os links das fotos da Imobibrasil pelas cópias que ficam no próprio site (pasta /fotos).
-- Rode no Supabase: SQL Editor > New query > cole tudo > Run. Pode rodar mais de uma vez.
-- Só mexe nas fotos que ainda apontam para a Imobibrasil; fotos enviadas pelo painel não mudam.

update public.imoveis i
set fotos = (
  select array_agg(regexp_replace(f, '^https?://imgs2\.cdn-imobibrasil\.com\.br/imagens/imoveis/', '/fotos/') order by n)
  from unnest(i.fotos) with ordinality as t(f, n)
)
where exists (select 1 from unnest(i.fotos) f where f like '%cdn-imobibrasil.com.br/%');

-- Conferência: deve voltar 0
select count(*) as fotos_ainda_na_imobibrasil
from public.imoveis, unnest(fotos) f
where f like '%cdn-imobibrasil.com.br/%';
