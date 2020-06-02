module GridTest exposing (..)

import Array
import Expect exposing (Expectation)
import Fuzz exposing (intRange)
import Grid exposing (..)
import Test exposing (Test, describe, fuzz2, test)


suite : Test
suite =
    describe "Morpion game"
        [ describe "Grid"
            [ fuzz2 (intRange 0 2) (intRange 0 2) "should update grid with cross" <|
                \x y ->
                    let
                        emptyGrid =
                            createGrid

                        updatedGrid =
                            updateGrid Cross { x = x, y = y } emptyGrid

                        updatedCell =
                            Array.get y updatedGrid
                                |> Maybe.andThen (\row -> Array.get x row)
                    in
                    Expect.equal (Just (Cell { x = x, y = y } Cross)) updatedCell
            , test "should update grid with circle" <|
                \_ ->
                    let
                        emptyGrid =
                            createGrid

                        updatedGrid =
                            updateGrid Circle { x = 1, y = 0 } emptyGrid

                        updatedCell =
                            Array.get 0 updatedGrid
                                |> Maybe.andThen (\row -> Array.get 1 row)
                    in
                    Expect.equal (Just (Cell { x = 1, y = 0 } Circle)) updatedCell
            ]
        ]
