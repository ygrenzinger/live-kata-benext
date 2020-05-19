module Example exposing (..)

import Array exposing (Array)
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Main exposing (..)
import Test exposing (..)


suite : Test
suite =
    describe "Morpion game"
        [ describe "Grid"
            [ test "should update grid with cross" <|
                \_ ->
                    let
                        emptyGrid =
                            createGrid

                        updatedGrid =
                            updateGrid 1 2 emptyGrid

                        updatedCell =
                            Array.get 1 updatedGrid
                                |> Maybe.andThen (\row -> Array.get 2 row)
                    in
                    Expect.equal (Just (Cell 1 2 Cross)) updatedCell
            ]
        ]
