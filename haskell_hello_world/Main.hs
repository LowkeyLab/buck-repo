{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.Aeson (Value, encode, object, (.=))

message :: Value
message = object ["message" .= ("Hello from Buck2, Haskell, Nix, and Aeson!" :: String)]

main :: IO ()
main = print (encode message)
