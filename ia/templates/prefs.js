/**
 * prefs.js — preferências de leitura (tema + tamanho de fonte).
 *
 * Uso: incluir no <head> ANTES dos stylesheets, como classic script (sem defer):
 *   <script src="prefs.js"></script>
 * Rodar no <head> aplica tema/escala antes do primeiro paint => sem flash (FOUC).
 *
 * Tema:    segue prefers-color-scheme; se o usuário escolher, a escolha persiste
 *          e passa a mandar sobre o SO.   localStorage: arch-theme = "light"|"dark"
 * Escala:  5 níveis de font-size do :root. localStorage: arch-scale = índice 0..4
 *
 * Expõe window.ArchPrefs para o sidebar.js (controles) consumir.
 */
(function () {
  "use strict";

  var THEME_KEY = "arch-theme";
  var SCALE_KEY = "arch-scale";
  var SCALES = [85, 92, 100, 115, 130]; // % do tamanho base (16px)
  var DEFAULT_SCALE = 2;                 // 100%
  var root = document.documentElement;

  function lsGet(k) { try { return localStorage.getItem(k); } catch (e) { return null; } }
  function lsSet(k, v) { try { localStorage.setItem(k, v); } catch (e) {} }

  function systemTheme() {
    return (window.matchMedia &&
      window.matchMedia("(prefers-color-scheme: light)").matches) ? "light" : "dark";
  }
  function storedTheme() {
    var t = lsGet(THEME_KEY);
    return (t === "light" || t === "dark") ? t : null;
  }
  function effectiveTheme() { return storedTheme() || systemTheme(); }
  function applyTheme(t) {
    if (t === "light") root.setAttribute("data-theme", "light");
    else root.removeAttribute("data-theme");
  }

  function clampIdx(i) { return Math.max(0, Math.min(SCALES.length - 1, i)); }
  function currentScaleIdx() {
    var v = parseInt(lsGet(SCALE_KEY), 10);
    return isNaN(v) ? DEFAULT_SCALE : clampIdx(v);
  }
  function applyScale(i) { root.style.fontSize = SCALES[clampIdx(i)] + "%"; }

  /* aplica o mais cedo possível (head, antes do paint) */
  applyTheme(effectiveTheme());
  applyScale(currentScaleIdx());

  /* acompanha o SO em tempo real só enquanto o usuário não tiver escolhido */
  try {
    var mq = window.matchMedia("(prefers-color-scheme: light)");
    var onSys = function () { if (!storedTheme()) applyTheme(systemTheme()); };
    if (mq.addEventListener) mq.addEventListener("change", onSys);
    else if (mq.addListener) mq.addListener(onSys);
  } catch (e) {}

  window.ArchPrefs = {
    SCALES: SCALES,
    getTheme: effectiveTheme,
    isExplicitTheme: function () { return !!storedTheme(); },
    toggleTheme: function () {
      var next = (effectiveTheme() === "light") ? "dark" : "light";
      lsSet(THEME_KEY, next);
      applyTheme(next);
      return next;
    },
    getScaleIdx: currentScaleIdx,
    getScalePct: function () { return SCALES[currentScaleIdx()]; },
    setScaleIdx: function (i) {
      i = clampIdx(i);
      lsSet(SCALE_KEY, String(i));
      applyScale(i);
      return i;
    },
    scaleUp: function () { return this.setScaleIdx(currentScaleIdx() + 1); },
    scaleDown: function () { return this.setScaleIdx(currentScaleIdx() - 1); }
  };
})();
