// Chave "anon" é pública por natureza: a segurança fica nas regras (RLS) do supabase/schema.sql.
window.SUPABASE_URL = 'https://sysbkjdrszisizpaphei.supabase.co';
window.SUPABASE_ANON = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN5c2JramRyc3ppc2l6cGFwaGVpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTI2MDI0MjksImV4cCI6MjEwODE3ODQyOX0.GtkihfrvL6IqxKdtcj2IdwUK2E560t2MjZplZUhH4W0';
window.WHATS = '5541992329582';

window.sb = window.supabase.createClient(window.SUPABASE_URL, window.SUPABASE_ANON);

window.IMV = {
  tipos: {casa:'Casa', apartamento:'Apartamento', terreno:'Terreno', area_rural:'Área rural', sala_comercial:'Sala comercial', barracao:'Barracão', outro:'Outro'},
  preco(i){
    if (i.preco == null) return 'Consulte';
    const v = Number(i.preco).toLocaleString('pt-BR', {style:'currency', currency:'BRL', maximumFractionDigits:0});
    return i.finalidade === 'locacao' ? v + '/mês' : v;
  },
  feats(i){
    const f = [];
    if (i.area_construida_m2) f.push(fmt(i.area_construida_m2) + ' m² construídos');
    else if (i.area_m2) f.push(fmt(i.area_m2) + ' m²');
    if (i.quartos) f.push(i.quartos + (i.quartos > 1 ? ' quartos' : ' quarto') + (i.suites ? ' · ' + i.suites + (i.suites > 1 ? ' suítes' : ' suíte') : ''));
    if (i.banheiros) f.push(i.banheiros + (i.banheiros > 1 ? ' banheiros' : ' banheiro'));
    if (i.vagas) f.push(i.vagas + (i.vagas > 1 ? ' vagas' : ' vaga'));
    return f;
  },
  whats(msg){ return 'https://wa.me/' + window.WHATS + '?text=' + encodeURIComponent(msg); },
  esc(s){ return String(s ?? '').replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c])); }
};
function fmt(n){ return Number(n).toLocaleString('pt-BR'); }
