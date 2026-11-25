module Main where

import Tipos
import Classificacao
import Leitura
import Dados (dadosCampeonato, dadosComErros)

-- Funcao auxiliar de teste conforme especificado no enunciado
testar :: (Eq a, Show a) => String -> a -> a -> IO ()
testar nome obtido esperado
  | obtido == esperado = putStrLn ("OK     - " ++ nome)
  | otherwise          = putStrLn ("FALHOU - " ++ nome ++ ": obtido " ++ show obtido ++ ", esperado " ++ show esperado)

-- Partida auxiliar para testes unitarios da Camada 1
partidaExemplo :: Partida
partidaExemplo = Partida 1 "Coritiba" 2 1 "Athletico"

-- Classificacao final esperada do campeonato de teste (conferida manualmente)
tabelaFinalEsperada :: [Linha]
tabelaFinalEsperada =
  [ Linha "Coritiba"  5 4 1 0 11 3
  , Linha "Athletico" 5 2 2 1 9  5
  , Linha "Maringa"   5 2 1 2 4  8
  , Linha "Parana"    5 2 0 3 6  6
  , Linha "Londrina"  5 1 3 1 5  4
  , Linha "Operario"  5 0 1 4 3  12
  ]

-- Classificacao esperada apos a 3a rodada
tabelaRodada3Esperada :: [Linha]
tabelaRodada3Esperada =
  [ Linha "Athletico" 3 2 1 0 7 2
  , Linha "Coritiba"  3 2 1 0 6 1
  , Linha "Londrina"  3 1 2 0 3 1
  , Linha "Maringa"   3 1 1 1 2 4
  , Linha "Operario"  3 0 1 2 2 7
  , Linha "Parana"    3 0 0 3 1 6
  ]

main :: IO ()
main = do
  putStrLn "=== TESTES DA CAMADA 1 ==="
  testar "resultadoPara mandante"
    (resultadoPara "Coritiba" partidaExemplo)
    (Just Vitoria)
  testar "resultadoPara visitante"
    (resultadoPara "Athletico" partidaExemplo)
    (Just Derrota)
  testar "resultadoPara time fora da partida"
    (resultadoPara "Parana" partidaExemplo)
    Nothing
  testar "times em ordem alfabetica e sem repeticao"
    (fmap times (lerCampeonato dadosCampeonato))
    (Right ["Athletico", "Coritiba", "Londrina", "Maringa", "Operario", "Parana"])

  putStrLn "\n=== TESTES DA CAMADA 2 ==="
  testar "classificacao final completa"
    (fmap classificacao (lerCampeonato dadosCampeonato))
    (Right tabelaFinalEsperada)
  testar "desempate por vitorias (Parana 6pts/2V > Londrina 6pts/1V)"
    (fmap (map time . take 2 . drop 3 . classificacao) (lerCampeonato dadosCampeonato))
    (Right ["Parana", "Londrina"])
  testar "classificacao ate a 3a rodada (diferente da final)"
    (fmap (classificacao . ateRodada 3) (lerCampeonato dadosCampeonato))
    (Right tabelaRodada3Esperada)
  testar "maiorGoleada lista vazia"
    (maiorGoleada [])
    Nothing
  testar "mediaGols lista vazia"
    (mediaGols [])
    Nothing
  testar "maiorGoleada do campeonato"
    (fmap maiorGoleada (lerCampeonato dadosCampeonato))
    (Right (Just (Partida 1 "Athletico" 4 0 "Operario")))
  testar "aproveitamento sem jogos"
    (aproveitamento (Linha "Vazio" 0 0 0 0 0 0))
    0.0

  putStrLn "\n=== TESTES DA CAMADA 3 ==="
  testar "lerCampeonato entrada valida retorna Right com 15 partidas"
    (fmap length (lerCampeonato dadosCampeonato))
    (Right 15)
  testar "Erro CamposInvalidos"
    (lerPartida 1 "1; Coritiba; 2; 1")
    (Left (CamposInvalidos 1))
  testar "Erro NumeroInvalido"
    (lerPartida 2 "2; Londrina; dois; 1; Maringa")
    (Left (NumeroInvalido 2 "dois"))
  testar "Erro PlacarNegativo"
    (lerPartida 3 "3; Operario; -1; 2; Parana")
    (Left (PlacarNegativo 3))
  testar "Erro MesmoTime"
    (lerPartida 4 "4; Athletico; 1; 1; Athletico")
    (Left (MesmoTime 4 "Athletico"))
  testar "Erro TimeRepetidoNaRodada"
    (lerCampeonato "1; Coritiba; 2; 1; Athletico\n1; Coritiba; 0; 0; Parana")
    (Left (TimeRepetidoNaRodada 1 "Coritiba"))
  testar "todosOsErros lista todos os problemas do texto"
    (todosOsErros dadosComErros)
    [ NumeroInvalido 4 "dois"
    , PlacarNegativo 5
    , MesmoTime 6 "Athletico"
    , CamposInvalidos 7
    , TimeRepetidoNaRodada 1 "Coritiba"
    ]