# TASK — 2026-06-17-ajuste-paleta-temas

- **fase:** concluida
- **tipo:** normal
- **pedido:** tema claro com fundo OFF-WHITE em vez de branco puro + letras mais escuras;
  tema escuro (night) com as letras brancas mais CLARAS. Fonte canonica de cor = tokens.css;
  todos os templates + COMO-USAR consomem via var(), entao a mudanca e global.

## Restricao herdada (task contraste-templates-html)
- Piso AA pra todo texto sobre sua superficie. Toda mudanca foi recalculada (script WCAG) e
  mantem AA/AAA. Letras mais escuras (claro) e mais claras (escuro) => contraste SOBE, nunca cai.

## Decisao do usuario (grill)
- Off-white no claro: "completo" — cards viram off-white E o fundo geral fica um pouco mais
  acinzentado, pra os cards continuarem saltando (escala de superficies remanejada, monotonica).
- Intensidade dos textos: perceptivel, mantendo AA (calibrada por contraste, nao por chute).

## Paleta nova (validada — script WCAG + monotonia de luminancia)
TEMA ESCURO (:root) — letras mais claras:
- text-primary   #f4f6f9 -> #fbfcff   (19.1 / 17.5  AAA)
- text-secondary #aeb6c6 -> #c4cbd8   (12.0 / 11.0  AAA; era 9.6/8.8)
- text-muted     #7d8698 -> #949dae   (7.2 / 6.6   AA;  era 5.3/4.9)

TEMA CLARO ([data-theme=light]) — off-white + letras mais escuras:
- bg               #f5f7fa -> #e9edf3
- bg-gradient-from #f5f7fa -> #e9edf3
- bg-gradient-to   #eef1f6 -> #e1e7ef
- surface          #ffffff -> #f8fafc   (off-white; cards deixam de ser branco puro)
- surface-2        #eef1f6 -> #e1e7ef
- surface-hover    #e8edf4 -> #d9e0ea
- surface-active   #dde4ee -> #cfd8e6
- text-primary     #11151c -> #0e1219   (16.0 / 17.9  AAA)
- text-secondary   #4a5263 -> #3a4150   (8.7 / 9.8   AAA; era 7.3/7.8)
- text-muted       #646d7e -> #525a6a   (5.9 / 6.6   AA;  era 4.9/5.2)
- mark-text        #11151c -> #0e1219   (acompanha o primary)

NAO muda (fora do pedido, ja AA): accent (#1c5fb8 = 5.3/5.9 AA sobre o novo fundo), semanticas,
borders, code, shadows, text-inverse.

## Criterios de aceite
- [x] tokens.css :root e [data-theme=light] com a paleta acima, exatamente.
- [x] Comentarios inline de contraste atualizados (20,21,166,167,168) pros novos numeros.
- [x] Escala clara monotonica: [0.954,0.844,0.794,0.74,0.681] surface>bg>surf2>hover>active.
- [x] Recalculo WCAG nos valores GRAVADOS: todo texto >= AA nos dois temas (ver LEDGER).
- [x] Chaves CSS 4/4; unico valor antigo restante = text-inverse #ffffff (intencional, fora de
      escopo); git diff toca SO tokens.css (15+/15-).

## Checklist de execucao
- [x] tokens.css :root — 3 textos do tema escuro (+ comentarios 20/21)
- [x] tokens.css [data-theme=light] — 7 superficies + 3 textos + mark-text (+ comentarios 166/167/168)
- [x] verificacao: grep dos valores, recalculo WCAG (dark+light), escala monotonica, chaves 4/4, escopo=1 arquivo
