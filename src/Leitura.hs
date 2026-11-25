module Leitura
  ( Erro(..)
  , separar
  , lerPartida
  , lerCampeonato
  , todosOsErros
  , tabelaFormatada
  ) where

import Data.Char (isSpace)
import Data.Either (lefts, rights)
import Text.Read (readMaybe)
import Tipos
import Classificacao (pontosLinha, saldo)

-- Erros possiveis na leitura e validacao das partidas
data Erro
  = CamposInvalidos Int
  | NumeroInvalido Int String
  | PlacarNegativo Int
  | MesmoTime Int Time
  | TimeRepetidoNaRodada Int Time
  deriving (Show, Eq)

-- Remove espacos em branco no inicio e no fim de uma string
limparEspacos :: String -> String
limparEspacos = dropWhile isSpace . reverse . dropWhile isSpace . reverse

-- Quebra uma string toda vez que encontra o caractere separador
separar :: Char -> String -> [String]
separar sep = foldr passo [[]]
  where
    passo c acc = case acc of
      (atual:resto)
        | c == sep  -> [] : atual : resto
        | otherwise -> (c : atual) : resto
      [] -> [[c]]

-- Converte texto para Int usando readMaybe e Maybe como functor/eliminador
lerInteiro :: Int -> String -> Either Erro Int
lerInteiro numLinha texto =
  maybe (Left (NumeroInvalido numLinha texto)) Right (readMaybe texto)

-- Converte uma linha numerada em Partida usando a monada Either
lerPartida :: Int -> String -> Either Erro Partida
lerPartida numLinha linha =
  case map limparEspacos (separar ';' linha) of
    [rStr, mand, gmStr, gvStr, vis]
      | null mand || null vis -> Left (CamposInvalidos numLinha)
      | otherwise -> do
          r  <- lerInteiro numLinha rStr
          gm <- lerInteiro numLinha gmStr
          gv <- lerInteiro numLinha gvStr
          if r <= 0
            then Left (NumeroInvalido numLinha rStr)
            else if gm < 0 || gv < 0
              then Left (PlacarNegativo numLinha)
              else if mand == vis
                then Left (MesmoTime numLinha mand)
                else Right (Partida r mand gm gv vis)
    _ -> Left (CamposInvalidos numLinha)

-- Filtra linhas em branco e comentarios (#), mantendo o numero original da linha
linhasRelevantes :: String -> [(Int, String)]
linhasRelevantes texto = filter (not . ignorar . snd) (zip [1..] (lines texto))
  where
    ignorar s = case dropWhile isSpace s of
      []      -> True
      ('#':_) -> True
      _       -> False

-- Verifica se algum time jogou mais de uma vez na mesma rodada
verificarRodadas :: [Partida] -> Either Erro ()
verificarRodadas partidas =
  fmap (const ()) (foldl checarPartida (Right []) partidas)
  where
    checarPartida acc p = do
      vistos <- acc
      let r = rodada p
      let m = mandante p
      let v = visitante p
      if (r, m) `elem` vistos
        then Left (TimeRepetidoNaRodada r m)
        else if (r, v) `elem` vistos
          then Left (TimeRepetidoNaRodada r v)
          else Right ((r, m) : (r, v) : vistos)

-- Le todo o texto do campeonato e para no primeiro erro encontrado
lerCampeonato :: String -> Either Erro [Partida]
lerCampeonato texto = do
  partidas <- traverse (uncurry lerPartida) (linhasRelevantes texto)
  verificarRodadas partidas
  Right partidas

-- Coleta todos os erros de partidas repetidas na mesma rodada
errosDeRodada :: [Partida] -> [Erro]
errosDeRodada partidas = snd (foldl checar ([], []) partidas)
  where
    checar (vistos, errs) p =
      let r    = rodada p
          m    = mandante p
          v    = visitante p
          errM = [TimeRepetidoNaRodada r m | (r, m) `elem` vistos, TimeRepetidoNaRodada r m `notElem` errs]
          errV = [TimeRepetidoNaRodada r v | (r, v) `elem` vistos, TimeRepetidoNaRodada r v `notElem` errs]
      in ((r, m) : (r, v) : vistos, errs ++ errM ++ errV)

-- Retorna uma lista com todos os erros presentes no texto
todosOsErros :: String -> [Erro]
todosOsErros texto =
  let resultados = map (uncurry lerPartida) (linhasRelevantes texto)
  in lefts resultados ++ errosDeRodada (rights resultados)

-- Formata a tabela de classificacao para exibicao no terminal
tabelaFormatada :: [Linha] -> String
tabelaFormatada [] = "Nenhuma partida registrada no campeonato."
tabelaFormatada linhas =
  unlines (cabecalho : separador : zipWith formatarLinha [1..] linhas)
  where
    cabecalho =
      alinharEsq 4 "Pos"
        ++ alinharEsq 16 "Time"
        ++ alinharDir 4 "P"
        ++ alinharDir 4 "J"
        ++ alinharDir 4 "V"
        ++ alinharDir 4 "E"
        ++ alinharDir 4 "D"
        ++ alinharDir 5 "SG"
    separador = replicate (length cabecalho) '-'

    formatarLinha :: Int -> Linha -> String
    formatarLinha pos l =
      alinharEsq 4 (show pos ++ "o")
        ++ alinharEsq 16 (time l)
        ++ alinharDir 4 (show (pontosLinha l))
        ++ alinharDir 4 (show (jogos l))
        ++ alinharDir 4 (show (vitorias l))
        ++ alinharDir 4 (show (empates l))
        ++ alinharDir 4 (show (derrotas l))
        ++ alinharDir 5 (show (saldo l))

    alinharEsq n s = take n (s ++ repeat ' ')
    alinharDir n s = replicate (max 0 (n - length s)) ' ' ++ s