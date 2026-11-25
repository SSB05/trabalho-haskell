module Tipos
  ( Time
  , Resultado(..)
  , Partida(..)
  , Linha(..)
  , participou
  , resultadoPara
  , times
  ) where

import Data.List (nub, sort)

-- Sinônimo de tipo para o nome de uma equipe.
type Time = String

-- Considera o resultado possível de uma partida olhando de um time.
data Resultado
  = Vitoria
  | Empate
  | Derrota
  deriving (Show, Eq)

-- Representa uma partida disputada no campeonato.
data Partida = Partida
  { rodada        :: Int
  , mandante      :: Time
  , golsMandante  :: Int
  , golsVisitante :: Int
  , visitante     :: Time
  } deriving (Show, Eq)

-- Representa uma linha da tabela de classificação.
data Linha = Linha
  { time       :: Time
  , jogos      :: Int
  , vitorias   :: Int
  , empates    :: Int
  , derrotas   :: Int
  , golsPro    :: Int
  , golsContra :: Int
  } deriving (Show, Eq)

-- Faz a verificação se um time participou da partida (como mandante ou visitante).
participou :: Time -> Partida -> Bool
participou t p = t == mandante p || t == visitante p

-- Retorna o resultado da partida do ponto de vista do time informado,
-- ou Nothing caso ele não tenha participado.
resultadoPara :: Time -> Partida -> Maybe Resultado
resultadoPara t p
  | t == mandante p  = Just (avaliarPlacar (golsMandante p) (golsVisitante p))
  | t == visitante p = Just (avaliarPlacar (golsVisitante p) (golsMandante p))
  | otherwise        = Nothing
  where
    avaliarPlacar :: Int -> Int -> Resultado
    avaliarPlacar pro contra
      | pro > contra = Vitoria
      | pro < contra = Derrota
      | otherwise    = Empate

-- Extrai todos os times participantes das partidas, sem repetição e em ordem alfabética.
times :: [Partida] -> [Time]
times partidas = nub (sort (concatMap extrairTimes partidas))
  where
    extrairTimes :: Partida -> [Time]
    extrairTimes p = [mandante p, visitante p]