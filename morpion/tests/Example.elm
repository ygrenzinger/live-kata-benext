module Example exposing (..)

import Array exposing (Array)
import Expect exposing (Expectation)
import Fuzz exposing (intRange)
import Main exposing (..)
import Test exposing (..)


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
                            updateGrid x y emptyGrid

                        updatedCell =
                            Array.get y updatedGrid
                                |> Maybe.andThen (\row -> Array.get x row)
                    in
                    Expect.equal (Just (Cell x y Cross)) updatedCell
            ]
        ]
