/**
 * diagram-viewer.js — leitor estático de diagramas Mermaid.
 *
 * Sem ES modules: funciona em file:// (Chrome bloqueia módulos via file://).
 * Carrega Mermaid e Panzoom via classic <script> tags injetados.
 *
 * Fonte do diagrama:
 *   1) INLINE  — recomendado p/ file://
 *      <div class="diagram-viewer" data-diagram="meu-id"></div>
 *      <script type="text/mermaid" data-id="meu-id">flowchart LR ...</script>
 *
 *   2) EXTERNO — requer HTTP server (não funciona em file://)
 *      <div class="diagram-viewer" data-src="diagrams/x.mmd"></div>
 */

(function () {
  'use strict';

  var MERMAID_URL = 'https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js';
  var PANZOOM_URL = 'https://cdn.jsdelivr.net/npm/panzoom@9.4.3/dist/panzoom.min.js';

  /* ========================================================================
   * Util: carregar script externo via <script> tag (não usa import).
   * ====================================================================== */
  function loadScript(src) {
    return new Promise(function (resolve, reject) {
      var s = document.createElement('script');
      s.src = src;
      s.async = true;
      s.onload  = function () { resolve(); };
      s.onerror = function () { reject(new Error('Falha ao carregar ' + src)); };
      document.head.appendChild(s);
    });
  }

  /* ========================================================================
   * Templates de HTML interno do viewer.
   * ====================================================================== */
  function viewerHTML(svgString) {
    return '' +
      '<div class="diagram-viewer__canvas">' + svgString + '</div>' +
      '<div class="diagram-viewer__controls" role="toolbar" aria-label="Controles do diagrama">' +
        '<button class="diagram-viewer__btn" type="button" data-action="zoom-in"  aria-label="Aumentar zoom"  title="Aumentar zoom">+</button>' +
        '<button class="diagram-viewer__btn" type="button" data-action="zoom-out" aria-label="Diminuir zoom"  title="Diminuir zoom">−</button>' +
        '<button class="diagram-viewer__btn" type="button" data-action="reset"    aria-label="Resetar"         title="Resetar (tecla 0)">⟲</button>' +
      '</div>' +
      '<div class="diagram-viewer__hint">Arraste · Scroll para zoom · Duplo clique amplia</div>';
  }

  function loadingHTML() {
    return '<div class="diagram-viewer__loading">Carregando diagrama…</div>';
  }

  function errorHTML(title, body) {
    return '<div class="diagram-viewer__error" role="alert">' +
             '<div class="diagram-viewer__error-title">' + title + '</div>' +
             '<div class="diagram-viewer__error-body">' + body + '</div>' +
           '</div>';
  }

  /* ========================================================================
   * Localiza a fonte do diagrama (inline ou arquivo).
   * ====================================================================== */
  function getSource(viewer) {
    return new Promise(function (resolve, reject) {
      /* Modo INLINE — script type="text/mermaid" com data-id correspondente */
      if (viewer.dataset.diagram) {
        var id = viewer.dataset.diagram;
        var script = document.querySelector(
          'script[type="text/mermaid"][data-id="' + id + '"]'
        );
        if (!script) {
          reject({
            title: 'Diagrama não encontrado',
            body: 'Não há <code>&lt;script type="text/mermaid" data-id="' + id + '"&gt;</code> nesta página.'
          });
          return;
        }
        resolve(script.textContent.trim());
        return;
      }

      /* Modo EXTERNO — fetch de arquivo .mmd (requer HTTP) */
      if (viewer.dataset.src) {
        var path = viewer.dataset.src;
        fetch(path).then(function (res) {
          if (!res.ok) throw new Error('HTTP ' + res.status);
          return res.text();
        }).then(resolve).catch(function (err) {
          var isFile = location.protocol === 'file:';
          reject({
            title: 'Não foi possível carregar ' + path,
            body: isFile
              ? '<p>Você abriu via <code>file://</code>, que bloqueia <code>fetch()</code>. ' +
                'Use <code>data-diagram</code> com <code>&lt;script type="text/mermaid"&gt;</code> em vez de <code>data-src</code>.</p>'
              : '<p>' + err.message + '</p>'
          });
        });
        return;
      }

      reject({
        title: 'Fonte do diagrama ausente',
        body: 'Defina <code>data-diagram</code> (inline) ou <code>data-src</code> (arquivo) no <code>.diagram-viewer</code>.'
      });
    });
  }

  /* ========================================================================
   * Render + panzoom para um único viewer.
   * ====================================================================== */
  function setupViewer(viewer, idx) {
    return new Promise(function (resolve) {
      var sourceCopy = '';

      getSource(viewer)
        .then(function (source) {
          sourceCopy = source;
          var id = 'mmd-' + idx + '-' + Date.now().toString(36);
          return window.mermaid.render(id, source);
        })
        .then(function (result) {
          /* Injetar HTML do viewer */
          viewer.innerHTML = viewerHTML(result.svg);

          var canvas = viewer.querySelector('.diagram-viewer__canvas');
          var svg    = canvas && canvas.querySelector('svg');
          if (!svg) {
            viewer.innerHTML = errorHTML('SVG não gerada', 'Mermaid retornou OK mas SVG não está no DOM.');
            resolve();
            return;
          }

          /* Normalizar dimensões da SVG */
          svg.style.maxWidth   = 'none';
          svg.style.background = 'transparent';
          svg.style.display    = 'block';

          /* Aplicar panzoom */
          var instance = window.panzoom(canvas, {
            maxZoom:              6,
            minZoom:              0.2,
            bounds:               false,
            zoomDoubleClickSpeed: 1.4,
            smoothScroll:         false,
            beforeMouseDown: function (e) {
              return e.target.closest('.diagram-viewer__controls') !== null;
            }
          });

          /* Centralizar canvas no primeiro frame */
          requestAnimationFrame(function () {
            var vr = viewer.getBoundingClientRect();
            var sr = svg.getBoundingClientRect();
            instance.moveTo(
              Math.max(0, (vr.width  - sr.width)  / 2),
              Math.max(0, (vr.height - sr.height) / 2)
            );
          });

          /* Controles */
          function center() { return { x: viewer.clientWidth / 2, y: viewer.clientHeight / 2 }; }
          function btn(action) { return viewer.querySelector('[data-action="' + action + '"]'); }

          var zin = btn('zoom-in');
          if (zin)  zin.addEventListener('click',  function () { var c = center(); instance.smoothZoom(c.x, c.y, 1.4); });
          var zout = btn('zoom-out');
          if (zout) zout.addEventListener('click', function () { var c = center(); instance.smoothZoom(c.x, c.y, 0.7); });
          var rst  = btn('reset');
          if (rst)  rst.addEventListener('click',  function () { instance.moveTo(0, 0); instance.zoomAbs(0, 0, 1); });

          /* Teclado */
          viewer.tabIndex = 0;
          viewer.addEventListener('keydown', function (e) {
            var c = center();
            if (e.key === '+' || e.key === '=') { instance.smoothZoom(c.x, c.y, 1.4); e.preventDefault(); }
            if (e.key === '-' || e.key === '_') { instance.smoothZoom(c.x, c.y, 0.7); e.preventDefault(); }
            if (e.key === '0')                  { instance.moveTo(0, 0); instance.zoomAbs(0, 0, 1); e.preventDefault(); }
          });

          resolve();
        })
        .catch(function (err) {
          var title = (err && err.title) || 'Mermaid não renderizou';
          var body  = (err && err.body)  || ('<p>' + ((err && err.message) || String(err)) + '</p>');
          if (sourceCopy && !err.title) {
            var snippet = sourceCopy.length > 280 ? sourceCopy.substring(0, 280) + '…' : sourceCopy;
            body += '<pre>' + snippet.replace(/</g, '&lt;') + '</pre>';
          }
          viewer.innerHTML = errorHTML(title, body);
          if (window.console) console.error('[diagram-viewer]', err);
          resolve();
        });
    });
  }

  /* ========================================================================
   * Bootstrap.
   * ====================================================================== */
  function boot() {
    var viewers = document.querySelectorAll('.diagram-viewer');
    if (viewers.length === 0) return;

    /* Mostrar estado "carregando" imediatamente */
    for (var i = 0; i < viewers.length; i++) {
      viewers[i].innerHTML = loadingHTML();
    }

    /* Carregar libs em paralelo (classic scripts, não modules) */
    var libs = Promise.all([
      window.mermaid ? Promise.resolve() : loadScript(MERMAID_URL),
      window.panzoom ? Promise.resolve() : loadScript(PANZOOM_URL)
    ]);

    libs.then(function () {
      if (!window.mermaid) throw new Error('window.mermaid não definido após carregar a CDN');
      if (!window.panzoom) throw new Error('window.panzoom não definido após carregar a CDN');

      window.mermaid.initialize({
        startOnLoad:   false,
        theme:         'neutral',
        securityLevel: 'loose',
        fontFamily:    'Inter, system-ui, sans-serif',
        flowchart:     { useMaxWidth: false, htmlLabels: true, curve: 'basis' },
        sequence:      { useMaxWidth: false, actorMargin: 60, mirrorActors: false }
      });

      var jobs = [];
      for (var i = 0; i < viewers.length; i++) {
        jobs.push(setupViewer(viewers[i], i));
      }
      return Promise.all(jobs);
    }).catch(function (err) {
      var msg = (err && err.message) || String(err);
      for (var i = 0; i < viewers.length; i++) {
        viewers[i].innerHTML = errorHTML(
          'Bibliotecas externas não carregaram',
          '<p>' + msg + '</p>' +
          '<p>Mermaid e Panzoom vêm de <code>cdn.jsdelivr.net</code>. ' +
          'Verifique conexão com internet ou se um proxy está bloqueando.</p>'
        );
      }
      if (window.console) console.error('[diagram-viewer] boot:', err);
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', boot);
  } else {
    boot();
  }
})();
