# Prompt — TDD Disciplinado

> ## STATUS
>
> Parte da **trilha de engenharia** do pack. Referenciado pela rule da trilha `engenharia` § 1
> (`.amazonq/rules/engenharia-style.md` ou `.github/instructions/engenharia-style.instructions.md`, conforme a ferramenta).
>
> Disciplina por **etapa de código** — aplica-se dentro de cada etapa do plano que o
> `executor-de-plano.md` executa, e em todo bugfix.

Clona o comportamento da skill `superpowers:test-driven-development`, destilado para
serviços .NET (xUnit/NUnit).

## A lei de ferro

```
NENHUM CÓDIGO DE PRODUÇÃO SEM UM TESTE FALHANDO ANTES
```

Escreveu código antes do teste? **Delete e recomece pelo teste.** Não guarde "como
referência", não "adapte enquanto escreve os testes" — deletar é deletar. Violar a letra
da regra é violar o espírito da regra.

## Quando usar

**Sempre:** feature nova · bugfix · refactor · mudança de comportamento.
**Exceções (somente com permissão explícita do usuário):** protótipo descartável ·
código gerado · arquivo de configuração. Pensou "pular o TDD só dessa vez"? Pare —
isso é racionalização.

## O ciclo — RED → GREEN → REFACTOR

### RED — escreva UM teste que falha
Um comportamento por teste, nome que descreve o comportamento, código real (mock só
quando inevitável).

```csharp
[Fact]
public async Task Reprocessa_operacao_falha_ate_3_tentativas()
{
    var tentativas = 0;
    Task<string> Operacao() =>
        ++tentativas < 3 ? throw new TransientException() : Task.FromResult("ok");

    var resultado = await Retry.ExecutarAsync(Operacao);

    Assert.Equal("ok", resultado);
    Assert.Equal(3, tentativas);
}
```

### Verifique o RED — OBRIGATÓRIO, nunca pule
`dotnet test --filter <NomeDoTeste>` e confirme: o teste **falha** (não erra de compilação),
a mensagem de falha é a esperada, e falha porque a feature não existe (não por typo).
- Passou de primeira? Você está testando comportamento que já existe — conserte o teste.
- Erro em vez de falha? Conserte o erro e rode de novo até falhar direito.

### GREEN — código mínimo
O código mais simples que faz o teste passar. Sem parâmetro opcional especulativo, sem
refactor de código vizinho, sem "melhorar" além do que o teste pede (YAGNI).
Verifique: o teste passa, os demais continuam passando, output limpo.
Falhou? Conserte o **código**, não o teste.

### REFACTOR — só depois do verde
Remova duplicação, melhore nomes, extraia helpers. Testes continuam verdes. Sem
comportamento novo. Depois: próximo teste falhando para o próximo comportamento.

## Racionalizações comuns (e a realidade)

| Desculpa | Realidade |
|---|---|
| "Simples demais pra testar" | Código simples quebra. O teste leva 30 segundos. |
| "Escrevo os testes depois" | Teste que nasce passando não prova nada — você nunca o viu pegar o bug. |
| "Já testei manualmente" | Ad-hoc ≠ sistemático: sem registro, não re-executa, esquece caso de borda. |
| "Deletar X horas de código é desperdício" | Custo afundado. Manter código sem prova é dívida técnica. |
| "TDD me atrasa" | TDD é mais rápido que debugar em produção. Pragmático = test-first. |
| "Preciso explorar primeiro" | Explore à vontade — depois **jogue fora** a exploração e recomece pelo teste. |

## Red flags — pare e recomece

Código antes do teste · teste que passa de primeira · não sabe explicar por que o teste
falhou · "depois eu adiciono os testes" · "dessa vez é diferente porque…". Qualquer um
desses → delete o código, recomece pelo teste.

## Teste difícil de escrever = design ruim

| Problema | Solução |
|---|---|
| Não sei como testar | Escreva primeiro a API que você gostaria de usar; comece pelo assert. |
| Teste complicado demais | O design está complicado. Simplifique a interface. |
| Preciso mockar tudo | Código acoplado demais. Injete dependências. |
| Setup gigante | Extraia helpers; se continuar gigante, simplifique o design. |

## Integração com o resto da trilha

- **Bugfix:** escreva o teste que REPRODUZ o bug (vermelho) antes do fix — o
  `depurador-sistematico.md` entrega a causa raiz; este prompt prova a correção e
  previne regressão. Nunca corrija bug sem teste.
- **Etapa de plano:** cada etapa do `executor-de-plano.md` que produz código = um ou
  mais ciclos RED→GREEN→REFACTOR; a verificação da etapa inclui a suíte verde.

## Checklist antes de declarar a etapa concluída

- [ ] Toda função/método novo tem teste?
- [ ] Vi cada teste **falhar** antes de implementar (pelo motivo certo)?
- [ ] Código mínimo para passar (nada especulativo)?
- [ ] Suíte inteira verde, output limpo?
- [ ] Casos de borda e de erro cobertos?

Não marcou todas? Você pulou o TDD — recomece.

## Exemplo de invocação

> Vou implementar a etapa 3 do plano (validação de CPF no cadastro). Use
> `prompts/engenharia/tdd-disciplinado.md`: teste falhando primeiro, código mínimo,
> refactor com suíte verde — me mostre o output de cada fase.

| Ferramenta | Como invocar |
|---|---|
| Amazon Q (IDE ou `q chat`) | Mensagem nomeando o prompt, como acima |
| Copilot (VS Code / Visual Studio / JetBrains) | `/tdd-disciplinado` |
| Copilot CLI | Gatilho natural ("test-first", "TDD") — a instruction roteia |
| Kiro (IDE / CLI) | Gatilho natural — a Agent Skill ativa por descrição |

## Referências
- Disciplina de conclusão (output real na mesma resposta): `engenharia-style.md` § 2.
- Causa raiz antes do fix: `prompts/engenharia/depurador-sistematico.md`.
- Onde o ciclo se encaixa no plano: `prompts/engenharia/executor-de-plano.md`.
