# Decisões de Modelagem e Limitações Conhecidas

## 1. Decisões de Modelagem

- **Uso de Records em `Partida` e `Linha`:** Em vez de representar partidas ou linhas da tabela com tuplas posicionais, optamos por *records* com campos nomeados (`mandante`, `golsMandante`, `golsVisitante`, `visitante`). Isso evita trocas acidentais entre gols marcados e sofridos, já que o compilador verifica os nomes dos campos.
- **Tipos Soma Fechados (`Resultado` e `Erro`):** Modelar o desfecho de um jogo como `Vitoria | Empate | Derrota` impede valores inválidos em tempo de compilação e garante verificação exaustiva de padrões com `-Wall`. Da mesma forma, o tipo `Erro` carrega o número da linha ou da rodada onde a falha ocorreu.
- **Acumulação com `foldl` em `linhaDoTime`:** Como a ordem cronológica das partidas não altera os totais acumulados de pontos, vitórias, empates, derrotas e gols de uma equipe, usamos `foldl` sobre a lista já filtrada com `filter (participou t)`.
- **Ordenação Multicritério com `Monoid` (`<>`):** Em vez de encadear chamadas sucessivas de `sortBy`, combinamos os critérios de desempate em uma única função usando `comparing`, `Down` e `<>` (pontos, vitórias, saldo de gols, gols pró e ordem alfabética).
- **Validação Monádica com `Either` e `traverse`:** Em `lerPartida`, o bloco `do` sobre `Either` elimina o aninhamento de `case` e interrompe a leitura no primeiro campo inválido. Em `lerCampeonato`, `traverse` aplica essa validação a todas as linhas mantendo a rastreabilidade da numeração original (calculada com `zip [1..] (lines texto)` antes de descartar comentários e linhas vazias).
- **Separação entre Núcleo Puro e `IO`:** Toda a lógica de domínio, cálculo, validação e formatação foi mantida em funções puras; apenas `main` realiza operações de `IO`.

## 2. Limitações Conhecidas

- **Sensibilidade a Maiúsculas/Minúsculas e Acentos nos Nomes:** A comparação entre nomes de times usa igualdade exata de `String` (`==`). Se um mesmo clube for digitado como `"Coritiba"` em uma rodada e `"coritiba"` em outra, será tratado como duas equipes distintas.
- **Ausência de Validação de Tabela Completa (Turno Único/Returno):** O sistema valida que nenhum time joga duas vezes na mesma rodada e que não enfrenta a si mesmo, mas não exige que todas as equipes tenham exatamente o mesmo número de jogos ou que todos os confrontos possíveis tenham ocorrido.
- **Separador Fixo na Entrada Textual:** O formato de entrada assume `;` como delimitador único e não suporta escape de ponto e vírgula dentro do nome de um time.
- **Formatação de Colunas com Largura Fixa:** A função `tabelaFormatada` reserva 16 caracteres para o nome do time; nomes muito longos são truncados visualmente na exibição, embora o cálculo interno permaneça intacto.