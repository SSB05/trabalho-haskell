# PjBL2 — Tabela de Classificação de Campeonato (Haskell)

Implementação funcional do cálculo e validação da tabela de classificação de um campeonato de futebol em Haskell, dividida em três camadas: tipos algébricos, funções de ordem superior e validação/formatação com `Maybe` e `Either`.

## Ambiente Utilizado

- **Compilador:** GHC 9.10.3 instalado localmente via **GHCup** (Windows).
- **Bibliotecas:** Apenas módulos da biblioteca padrão (`base`): `Data.List`, `Data.Char`, `Data.Either`, `Data.Ord` e `Text.Read`.

## Estrutura do Projeto

```text
trabalho-haskell/
├── src/
│   ├── Tipos.hs           # Camada 1: tipos algébricos e consultas básicas
│   ├── Classificacao.hs   # Camada 2: pontuação, desempates e estatísticas
│   ├── Leitura.hs         # Camada 3: leitura, validação com Either/Maybe e tabela
│   ├── Dados.hs           # Dados do campeonato de teste e exemplos com erro
│   └── Main.hs            # Demonstração das três camadas (único módulo com IO)
├── tests/
│   └── Testes.hs          # Bateria de testes automatizados das três camadas
├── docs/
│   └── decisoes.md        # Decisões de modelagem e limitações conhecidas
└── README.md