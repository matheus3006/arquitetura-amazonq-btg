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
  `;

  root.innerHTML = html;
})();
