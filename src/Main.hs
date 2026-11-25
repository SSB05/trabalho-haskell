module Main where

import Tipos (Partida(..), times)
import Classificacao (ateRodada, classificacao, maiorGoleada, mediaGols)
import Leitura (Erro(..), lerCampeonato, tabelaFormatada, todosOsErros)
import Dados (dadosCampeonato, dadosComErros)

-- Converte um Erro em mensagem legivel indicando a linha ou rodada
descreverErro :: Erro -> String
descreverErro (CamposInvalidos linha) =
  "Linha " ++ show linha ++ ": formato ou quantidade de campos invalidos."
descreverErro (NumeroInvalido linha valor) =
  "Linha " ++ show linha ++ ": numero invalido ('" ++ valor ++ "')."
descreverErro (PlacarNegativo linha) =
  "Linha " ++ show linha ++ ": placar negativo nao permitido."
descreverErro (MesmoTime linha nomeTime) =
  "Linha " ++ show linha ++ ": o time '" ++ nomeTime ++ "' nao pode jogar contra si mesmo."
descreverErro (TimeRepetidoNaRodada numRodada nomeTime) =
  "Rodada " ++ show numRodada ++ ": o time '" ++ nomeTime ++ "' aparece mais de uma vez."

-- Formata uma partida em texto simples
formatarPartida :: Partida -> String
formatarPartida p =
  "Rodada " ++ show (rodada p) ++ ": "
    ++ mandante p ++ " " ++ show (golsMandante p)
    ++ " x " ++ show (golsVisitante p) ++ " " ++ visitante p

-- Monta o texto das estatisticas da Camada 2 sem usar IO
resumoEstatisticas :: [Partida] -> String
resumoEstatisticas partidas =
  unlines
    [ "Maior goleada: " ++ maybe "Nenhuma partida" formatarPartida (maiorGoleada partidas)
    , "Media de gols por partida: " ++ maybe "N/A" show (mediaGols partidas)
    ]

-- Unica funcao com IO: executa e exibe as tres camadas em sequencia
main :: IO ()
main = do
  putStrLn "=== CAMADA 1 & 2: CLASSIFICACAO FINAL ==="
  case lerCampeonato dadosCampeonato of
    Left err -> putStrLn ("Erro inesperado: " ++ descreverErro err)
    Right partidas -> do
      putStrLn ("Times participantes: " ++ show (times partidas))
      putStrLn ""
      putStr (tabelaFormatada (classificacao partidas))
      putStrLn "=== CAMADA 2: CLASSIFICACAO APOS A 3a RODADA ==="
      putStr (tabelaFormatada (classificacao (ateRodada 3 partidas)))
      putStrLn "=== CAMADA 2: ESTATISTICAS DO CAMPEONATO ==="
      putStr (resumoEstatisticas partidas)

  putStrLn "=== CAMADA 3: TRATAMENTO DE ENTRADA COM ERROS ==="
  case lerCampeonato dadosComErros of
    Right _  -> putStrLn "Nenhum erro encontrado."
    Left err -> putStrLn ("Primeiro erro (lerCampeonato): " ++ descreverErro err)

  putStrLn ""
  putStrLn "Todos os erros detectados (todosOsErros):"
  putStr (unlines (map (\e -> "- " ++ descreverErro e) (todosOsErros dadosComErros)))