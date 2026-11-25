module Classificacao
  ( pontos
  , linhaDoTime
  , pontosLinha
  , saldo
  , aproveitamento
  , classificacao
  , ateRodada
  , maiorGoleada
  , mediaGols
  ) where

import Data.List (sortBy)
import Data.Ord (Down(..), comparing)
import Tipos

-- Pontos obtidos conforme o resultado da partida
pontos :: Resultado -> Int
pontos Vitoria = 3
pontos Empate  = 1
pontos Derrota = 0

-- Monta a linha de classificacao de um time acumulando suas partidas com foldl
linhaDoTime :: [Partida] -> Time -> Linha
linhaDoTime partidas t = foldl acumular linhaInicial jogosDoTime
  where
    linhaInicial = Linha t 0 0 0 0 0 0
    jogosDoTime  = filter (participou t) partidas

    acumular :: Linha -> Partida -> Linha
    acumular acc p =
      let (gp, gc) = if t == mandante p
                     then (golsMandante p, golsVisitante p)
                     else (golsVisitante p, golsMandante p)
      in case resultadoPara t p of
           Just Vitoria -> acc
             { jogos      = jogos acc + 1
             , vitorias   = vitorias acc + 1
             , golsPro    = golsPro acc + gp
             , golsContra = golsContra acc + gc
             }
           Just Empate -> acc
             { jogos      = jogos acc + 1
             , empates    = empates acc + 1
             , golsPro    = golsPro acc + gp
             , golsContra = golsContra acc + gc
             }
           Just Derrota -> acc
             { jogos      = jogos acc + 1
             , derrotas   = derrotas acc + 1
             , golsPro    = golsPro acc + gp
             , golsContra = golsContra acc + gc
             }
           Nothing -> acc

-- Total de pontos ganhos na linha
pontosLinha :: Linha -> Int
pontosLinha l = vitorias l * pontos Vitoria + empates l * pontos Empate

-- Saldo de gols (gols pro menos gols contra)
saldo :: Linha -> Int
saldo l = golsPro l - golsContra l

-- Percentual de aproveitamento dos pontos disputados (0.0 se nao jogou)
aproveitamento :: Linha -> Double
aproveitamento l
  | jogos l == 0 = 0.0
  | otherwise    = (fromIntegral (pontosLinha l) / fromIntegral (jogos l * 3)) * 100.0

-- Tabela completa ordenada pelos criterios do campeonato:
-- pontos, vitorias, saldo de gols, gols pro e ordem alfabetica
classificacao :: [Partida] -> [Linha]
classificacao partidas = sortBy compararLinhas linhas
  where
    linhas = map (linhaDoTime partidas) (times partidas)
    compararLinhas =
      comparing (Down . pontosLinha)
        <> comparing (Down . vitorias)
        <> comparing (Down . saldo)
        <> comparing (Down . golsPro)
        <> comparing time

-- Filtra apenas as partidas disputadas ate a rodada informada
ateRodada :: Int -> [Partida] -> [Partida]
ateRodada r = filter (\p -> rodada p <= r)

-- Partida com a maior diferenca de gols (Nothing se a lista estiver vazia)
maiorGoleada :: [Partida] -> Maybe Partida
maiorGoleada []     = Nothing
maiorGoleada (p:ps) = Just (foldl escolherMaior p ps)
  where
    diferenca x = abs (golsMandante x - golsVisitante x)
    escolherMaior atual candidata
      | diferenca candidata > diferenca atual = candidata
      | otherwise                             = atual

-- Media de gols por partida (Nothing se a lista estiver vazia)
mediaGols :: [Partida] -> Maybe Double
mediaGols []       = Nothing
mediaGols partidas = Just (fromIntegral totalGols / fromIntegral (length partidas))
  where
    golsPartida p = golsMandante p + golsVisitante p
    totalGols     = sum (map golsPartida partidas)