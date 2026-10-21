-- Claudinea Imóveis · rode este arquivo inteiro no Supabase: SQL Editor > New query > Run

create table if not exists public.imoveis (
  id           uuid primary key default gen_random_uuid(),
  codigo       text unique not null,
  titulo       text not null,
  tipo         text not null default 'casa'   check (tipo in ('casa','apartamento','terreno','area_rural','sala_comercial','barracao','outro')),
  finalidade   text not null default 'venda'  check (finalidade in ('venda','locacao')),
  bairro       text,
  cidade       text not null default 'Contenda',
  preco        numeric(14,2),
  area_m2      numeric(12,2),
  area_construida_m2 numeric(12,2),
  quartos      int,
  suites       int,
  banheiros    int,
  vagas        int,
  financia     boolean not null default false,
  aceita_fgts  boolean not null default false,
  aceita_permuta boolean not null default false,
  descricao    text,
  caracteristicas text[] not null default '{}',
  fotos        text[] not null default '{}',
  destaque     boolean not null default false,
  publicado    boolean not null default true,
  ordem        int not null default 0,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

create or replace function public.set_updated_at() returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end $$;

drop trigger if exists imoveis_updated_at on public.imoveis;
create trigger imoveis_updated_at before update on public.imoveis
  for each row execute function public.set_updated_at();

-- Quem pode usar o painel: só os e-mails desta tabela (estar logado não basta).
create table if not exists public.admins (email text primary key);
alter table public.admins enable row level security;
insert into public.admins (email) values ('claudineia@admin.com') on conflict do nothing;

create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.admins where lower(email) = lower(auth.jwt() ->> 'email'));
$$;

-- Segurança: o site público só lê anúncios publicados; só admins editam.
alter table public.imoveis enable row level security;

drop policy if exists "publico le publicados" on public.imoveis;
create policy "publico le publicados" on public.imoveis
  for select using (publicado or public.is_admin());

drop policy if exists "admin insere" on public.imoveis;
create policy "admin insere" on public.imoveis
  for insert to authenticated with check (public.is_admin());

drop policy if exists "admin edita" on public.imoveis;
create policy "admin edita" on public.imoveis
  for update to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists "admin apaga" on public.imoveis;
create policy "admin apaga" on public.imoveis
  for delete to authenticated using (public.is_admin());

-- Fotos: bucket público para leitura, upload só pelo painel.
insert into storage.buckets (id, name, public)
values ('imoveis', 'imoveis', true)
on conflict (id) do update set public = true;

drop policy if exists "fotos leitura publica" on storage.objects;
create policy "fotos leitura publica" on storage.objects
  for select using (bucket_id = 'imoveis');

drop policy if exists "fotos upload admin" on storage.objects;
create policy "fotos upload admin" on storage.objects
  for insert to authenticated with check (bucket_id = 'imoveis' and public.is_admin());

drop policy if exists "fotos edita admin" on storage.objects;
create policy "fotos edita admin" on storage.objects
  for update to authenticated using (bucket_id = 'imoveis' and public.is_admin());

drop policy if exists "fotos apaga admin" on storage.objects;
create policy "fotos apaga admin" on storage.objects
  for delete to authenticated using (bucket_id = 'imoveis' and public.is_admin());

-- Imóveis que já estavam no site (fotos do imobibrasil). Pode editar/apagar depois pelo painel.
insert into public.imoveis (codigo, titulo, tipo, finalidade, bairro, preco, area_construida_m2, quartos, banheiros, vagas, area_m2, financia, destaque, ordem, fotos) values
 ('CA019','Casa de esquina com 3 vagas','casa','venda','Itaperubá',320000,155,2,null,3,null,false,true,1,'{https://imgs2.cdn-imobibrasil.com.br/imagens/imoveis/202603311711439141.jpg}'),
 ('CA020','Casa em terreno de 1.215 m²','casa','venda','Mato Branco',270000,null,2,2,null,1215,false,true,2,'{https://imgs2.cdn-imobibrasil.com.br/imagens/imoveis/202605052021242831.png}'),
 ('CA012','Casa em condomínio','casa','venda','Centro',280000,null,2,null,1,null,false,true,3,'{https://imgs2.cdn-imobibrasil.com.br/imagens/imoveis/202503181413579579.jpg}'),
 ('CA004','Casa alto padrão mobiliada','casa','venda','Centro',2300000,288,4,null,null,null,false,true,4,'{https://imgs2.cdn-imobibrasil.com.br/imagens/imoveis/202509091646071141.jpg}'),
 ('TE012','Terreno no Cond. Castel Sant''Angelo','terreno','venda','Centro',196000,null,null,null,null,252,false,true,5,'{https://imgs2.cdn-imobibrasil.com.br/imagens/imoveis/202509111530433117.jpg}'),
 ('TE018','Área rural de 4,4 hectares','area_rural','venda','Campestre, Lagoão e Turvo',430000,null,null,null,null,44921,false,true,6,'{https://imgs2.cdn-imobibrasil.com.br/imagens/imoveis/202604262256282725.png}'),
 ('SL015L','Sala comercial com mezanino','sala_comercial','locacao','Centro',1800,null,null,1,null,53,false,true,7,'{https://imgs2.cdn-imobibrasil.com.br/imagens/imoveis/202512161519285094.jpg}')
on conflict (codigo) do nothing;
