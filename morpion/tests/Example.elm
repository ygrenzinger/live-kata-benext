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
            [ fuzz2 (intRange 0 2) (intRange 0 2) "should update grid with cross because first player" <|
                \x y ->
                    let
                        emptyGrid =
                            createGrid

                        player =
                            FirstPlayer

                        updatedGrid =
                            updateGrid player x y emptyGrid

                        updatedCell =
                            Array.get y updatedGrid
                                |> Maybe.andThen (\row -> Array.get x row)
                    in
                    Expect.equal (Just (Cell x y Cross)) updatedCell
            , test "should with circle because second player" <|
                \_ ->
                    let
                        emptyGrid =
                            createGrid

                        player =
                            SecondPlayer

                        updatedGrid =
                            updateGrid player 1 0 emptyGrid

                        updatedCell =
                            Array.get 0 updatedGrid
                                |> Maybe.andThen (\row -> Array.get 1 row)
                    in
                    Expect.equal (Just (Cell 1 0 Circle)) updatedCell
            , test "should switch player" <|
                \_ ->
                    let
                        initGame =
                            Game FirstPlayer createGrid

                        (Game player _) =
                            playerTurn 0 1 initGame
                    in
                    Expect.equal SecondPlayer player
            , test "Should not update Game state if player tries to click on a non empty cell" <|
                \_ ->
                    let
                        initGame =
                            Game FirstPlayer createGrid

                        firstPlayerTurn =
                            playerTurn 0 1 initGame

                        noChange =
                            playerTurn 0 1 firstPlayerTurn
                    in
                    Expect.equal firstPlayerTurn noChange
            ]
        ]
