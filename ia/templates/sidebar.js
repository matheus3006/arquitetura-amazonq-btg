/**
 * sidebar.js — renderiza a navegação lateral consistente em todas as páginas.
 * Uso:
 *   <aside id="sidebar"></aside>
 *   <script src="sidebar.js"></script>
 *
 * Edite o objeto NAV abaixo para refletir a estrutura real do seu serviço.
 * O item ativo é detectado automaticamente pelo nome do arquivo atual.
 */

const NAV = {
  brand: {
    mark: "L",                       // letra única ou inicial do serviço
    name: "Liquidação Transacional"  // nome exibido ao lado
  },
  sections: [
    {
      title: "Arquitetura",
      icon: "diamond",
      items: [
        { label: "Início",             href: "index.html" },
        { label: "Visão Geral",        href: "01-visao-geral.html" },
        { label: "Padrões e Camadas",  href: "02-padroes.html" },
        { label: "Dados Trafegados",   href: "03-dados.html" },
        { label: "Configurações",      href: "04-configuracoes.html" },
        { label: "Guia: Nova Feature", href: "05-nova-funcionalidade.html" },
        { label: "Infraestrutura",     href: "06-infraestrutura.html" }
      ]
    },
    {
      title: "Fluxos Transacionais",
      icon: "circle",
      items: [
        { label: "Autorização",   href: "07-fluxo-autorizacao.html" },
        { label: "Estorno",       href: "08-fluxo-estorno.html" },
        { label: "Contingência",  href: "09-fluxo-contingencia.html" }
      ]
    },
    {
      title: "Modelo de Dados",
      icon: "bar",
      items: [
        { label: "Dicionário",     href: "13-dicionario.html" },
        { label: "Enums e Códigos",href: "14-enums.html" }
      ]
    }
  ]
};

(function renderSidebar() {
  const root = document.getElementById("sidebar");
  if (!root) return;

  const here = (location.pathname.split("/").pop() || "index.html").toLowerCase();

  const sectionClass = (icon) => {
    if (icon === "circle") return "sidebar__section sidebar__section--circle";
    if (icon === "bar")    return "sidebar__section sidebar__section--bar";
    return "sidebar__section";
  };

  const html = `
    <a class="skip-link" href="#main">Pular para o conteúdo</a>
    <div class="sidebar__brand">
      <div class="sidebar__brand-mark" aria-hidden="true">${NAV.brand.mark}</div>
      <div class="sidebar__brand-name">${NAV.brand.name}</div>
    </div>
    ${NAV.sections.map(sec => `
      <nav class="${sectionClass(sec.icon)}" aria-label="${sec.title}">
        <div class="sidebar__section-title">${sec.title}</div>
        <ul>
          ${sec.items.map(it => {
            const isActive = it.href.toLowerCase() === here;
            return `<li><a class="sidebar__link" href="${it.href}"${isActive ? ' aria-current="page"' : ""}>${it.label}</a></li>`;
          }).join("")}
        </ul>
      </nav>
    `).join("")}
    <div class="sidebar__tools">
      <button class="sidebar__tool-btn" id="arch-theme-toggle" type="button"></button>
      <div class="sidebar__tools-group" role="group" aria-label="Tamanho do texto">
        <button class="sidebar__tool-btn" id="arch-font-dec" type="button" aria-label="Diminuir tamanho do texto">A&minus;</button>
        <span class="sidebar__scale-label" id="arch-font-level" aria-live="polite"></span>
        <button class="sidebar__tool-btn" id="arch-font-inc" type="button" aria-label="Aumentar tamanho do texto">A+</button>
      </div>
    </div>
  `;

  root.innerHTML = html;

  // ── Controles de leitura: tema + tamanho de fonte (consome window.ArchPrefs) ──
  const prefs = window.ArchPrefs;
  const themeBtn = root.querySelector("#arch-theme-toggle");
  if (!prefs || !themeBtn) return; // prefs.js ausente: degrada sem quebrar a nav

  const SUN = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"/></svg>';
  const MOON = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 3a6 6 0 0 0 9 9 9 9 0 1 1-9-9Z"/></svg>';

  const dec = root.querySelector("#arch-font-dec");
  const inc = root.querySelector("#arch-font-inc");
  const level = root.querySelector("#arch-font-level");

  function syncTheme() {
    const isLight = prefs.getTheme() === "light";
    themeBtn.innerHTML = isLight ? MOON : SUN;
    themeBtn.setAttribute("aria-label", isLight ? "Mudar para tema escuro" : "Mudar para tema claro");
  }
  function syncScale() {
    const idx = prefs.getScaleIdx();
    level.textContent = prefs.getScalePct() + "%";
    dec.disabled = idx <= 0;
    inc.disabled = idx >= prefs.SCALES.length - 1;
  }

  themeBtn.addEventListener("click", () => { prefs.toggleTheme(); syncTheme(); });
  dec.addEventListener("click", () => { prefs.scaleDown(); syncScale(); });
  inc.addEventListener("click", () => { prefs.scaleUp(); syncScale(); });

  syncTheme();
  syncScale();
})();
