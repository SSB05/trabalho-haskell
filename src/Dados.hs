module Dados
  ( dadosCampeonato
  , dadosComErros
  ) where

-- Campeonato de teste valido (6 times, 5 rodadas, 15 partidas)
-- Inclui empate 0x0, goleada >= 3 gols e empate final em pontos (Parana e Londrina com 6 pts)
dadosCampeonato :: String
dadosCampeonato = unlines
  [ "# Campeonato Paranaense - Fase Classificatoria"
  , "# rodada; mandante; gols mandante; gols visitante; visitante"
  , ""
  , "# Rodada 1"
  , "1; Coritiba; 2; 0; Parana"
  , "1; Athletico; 4; 0; Operario"
  , "1; Londrina; 0; 0; Maringa"
  , ""
  , "# Rodada 2"
  , "2; Parana; 1; 2; Athletico"
  , "2; Operario; 1; 1; Londrina"
  , "2; Maringa; 0; 3; Coritiba"
  , ""
  , "# Rodada 3"
  , "3; Athletico; 1; 1; Coritiba"
  , "3; Londrina; 2; 0; Parana"
  , "3; Maringa; 2; 1; Operario"
  , ""
  , "# Rodada 4"
  , "4; Coritiba; 2; 1; Londrina"
  , "4; Maringa; 2; 1; Athletico"
  , "4; Parana; 2; 0; Operario"
  , ""
  , "# Rodada 5"
  , "5; Operario; 1; 3; Coritiba"
  , "5; Athletico; 1; 1; Londrina"
  , "5; Parana; 3; 0; Maringa"
  ]

-- Entrada com erros propositais cobrindo todos os construtores de Erro
dadosComErros :: String
dadosComErros = unlines
  [ "# Arquivo de teste com linhas invalidas"
  , "1; Coritiba; 2; 1; Athletico"
  , "1; Coritiba; 0; 0; Parana"
  , "2; Londrina; dois; 1; Maringa"
  , "2; Operario; -1; 2; Parana"
  , "3; Athletico; 1; 1; Athletico"
  , "3; linha malformada sem separadores"
  ]